CREATE PROCEDURE Iniciar_Terreno_Tipo_Uno (IN terrenoID INT)
BEGIN
	INSERT INTO Terreno_Tipo(Terreno_ID,TipoID)
		VALUES (terrenoID,1);
	CALL Crear_Terreno_Tipo_Uno(id);
END;


CREATE PROCEDURE Crear_Terreno_Tipo_Uno (IN id INT)
BEGIN
DECLARE x  INT;
DECLARE y  INT;
SET x = 0;
SET y = 0;
--Pongo 2 lineas de agua
    WHILE y <= 1 DO
		WHILE x < 15 DO
        	INSERT INTO Terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, x, y,"A");
        	SET x = x + 1;
		END WHILE;
		SET x = 0;
		SET y = y + 1;
    END WHILE;
--Pongo 4 Lineas de Tierra
	SET x = 0;
	WHILE y <= 5 DO
		WHILE x < 15 DO
        	INSERT INTO Terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, x, y,"T");
        	SET x = x + 1;
		END WHILE;
		SET x = 0;
		SET y = y + 1;
    END WHILE;
--Pongo 2 Lineas de Piedra
	SET x = 0;
	WHILE y <= 7 DO
		WHILE x < 15 DO
        	INSERT INTO Terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, x, y,"P");
        	SET x = x + 1;
		END WHILE;
		SET x = 0;
		SET y = y + 1;
    END WHILE;
--Pongo 2 Lineas de Aire
	SET x = 0;
	WHILE y <= 9 DO
		WHILE x < 15 DO
        	INSERT INTO Terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, x, y,".");
        	SET x = x + 1;
		END WHILE;
		SET x = 0;
		SET y = y + 1;
    END WHILE;
--Pongo 2 Lineas de Piedra
	SET x = 0;
	WHILE y <= 11 DO
		WHILE x < 15 DO
        	INSERT INTO Terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, x, y,"P");
        	SET x = x + 1;
		END WHILE;
		SET x = 0;
		SET y = y + 1;
    END WHILE;
--Pongo 3 Lineas de Aire
	SET x = 0;
	WHILE y <= 14 DO
		WHILE x < 15 DO
        	INSERT INTO Terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, x, y,"P");
        	SET x = x + 1;
		END WHILE;
		SET x = 0;
		SET y = y + 1;
    END WHILE;
END;

CREATE PROCEDURE Inicializar_Equipos(IN IDPartida INT,IN cantPersonas INT)
BEGIN
	DECLARE x INT;
	DECLARE ultimo_equipoID INT;
	DECLARE segundos INT;

	SET segundos = 30;
	SET x = 1;

	WHILE x <= 4 DO
		SET  x = x + 1;
		SET ultimo_equipoID = Get_UltimoEquipoID(); -- Tabla: Partida_Equipo
		INSERT INTO Partida_Equipo (Partida_ID, Equipo_ID)
		VALUES (IDPartida, ultimo_equipoID +1); 
		CALL Registrar_Equipo(ultimo_equipoID +1,segundos,cantPersonas > 0);
		SET segundos = segundos +30;
	END WHILE;
END

CREATE PROCEDURE Registrar_Equipo(IN equipoID INT,IN segundos INT, IN Humano BOOLEAN,)
BEGIN
	DECLARE x INT;
	SET x = 1;

	INSERT INTO Equipo(Equipo_ID, EnJuego, Control ,TiempoTurno)
		VALUES (equipoID, "NO", ConversorBoolHumano(Humano),segundos);
	
	WHILE x <= 30 DO
		x = x+1;
		INSERT INTO Equipo_Arma(Equipo_ID, Arma_ID)
		VALUES (equipoID, 1);
	END WHILE;
	CALL Crear_GusanosParaEquipo(equipoID); --aca siguen recorriendo tablas
END;


CREATE PROCEDURE Crear_GusanosParaEquipo(IN equipoID INT)
BEGIN
	DECLARE x INT;
	SET x = 1;
	WHILE x <= 8 DO
		DECLARE gusanoID = Ultimo_GusanoID()+1;
		INSERT INTO Equipo_Gusanos( Equipo_ID, Gusano_ID)
		VALUES (equipoID,gusanoID );
		SET x = x + 1;
		CALL RegistrarGusano(gusanoID);
	END WHILE
END;


CREATE PROCEDURE RegistrarGusano(IN gusanoID INT)
BEGIN
	DECLARE gusanoInsertado BOOLEAN;
	DECLARE terrenoID INT
	DECLARE X INT;
	DECLARE Y INT;
	DECLARE celda VarChar(2);
	SET terrenoID = GetTerrenoID_delGusano(gusanoID);
	SET lugarEncontrado = FALSE;

	WHILE lugarEncontrado = FALSE DO
		SET Y = 9;
		SET X = (SELECT FLOOR(RAND()*(55-1+1))+1;);
		SET celda = SELECT Celda FROM Terreno 
					WHERE Terreno_ID = terrenoID 
					AND Cord_Y = Y; -- aqui creo que hay una linea de aire segun el terreno de diego
					AND Cord_X = X;
		IF (celda = '*')
			lugarEncontrado = TRUE;
		ENDIF;
	END WHILE;

	INSERT INTO Gusano(Gusano_ID, Salud, Arma_ID, POS_X, POS_Y)
	VALUES(gusanoID, 100, 1, X, Y);
END;


CREATE PROCEDURE Iniciar_MarcadorPartida(IN IDPartida INT)
BEGIN
	DECLARE x INT;
	DECLARE equipoID = Get_UltimoEquipoID()-3;

	SET x = 1;

	WHILE x <= 4 DO
		SET x = x + 1;
		INSERT INTO Marcadores_Partida(Partida_ID, Equipo_ID, Kills, Deaths)
			VALUES(IDPartida, equipoID, 0, 0);
		SET equipoID = equipoID + 1;
	END WHILE
		
END;



CREATE PROCEDURE Aniquilar_Gusanos_De_la_linea(IN x INT,IN y INT,IN terrenoID INT)
BEGIN

	DECLARE i INT;
	DECLARE celda Varchar(2);

	SET i = 0;

	WHILE i <= 4 DO
	SET celda = (SELECT Celda 
			FROM terreno 
			WHERE 
			Terreno_ID = terrenoID
			AND Cord_x = Cord_x+i;
			AND Cord_y = y;)
		IF (celda = 'W' OR celda = 'R' OR celda ='L' OR celda='H')
			CALL Eliminar_Gusano(x,y,terrenoID);
		END IF;
	SET i = i +1;
	END WHILE

END;

CREATE PROCEDURE Eliminar_Gusano(IN x INT,IN y INT,IN terrenoID INT)
BEGIN

	UPDATE Gusano 
	SET Salud = 0 , POS_X = null , POS_Y = null;
	WHERE
	Gusano.GusanoID = Equipo_Gusanos.Gusano_ID
	AND Gusano.POS_X = x;
	AND Gusano.POS_Y = y;
	AND Equipo_Gusanos.Equipo_ID = Partida_Equipo.Equipo_ID
	AND Partida_Equipo.Partida_ID = Partida.Partida_ID
	AND Partida.Terreno_ID = terrenoID;
	UPDATE Terreno SET Celda = '*' WHERE Cord_x = x AND Cord_y = y AND Terreno_ID = terrenoID;

	DECLARE partidaID = SELECT Partida_ID FROM Partida p, Terreno_Tipo tt
						WHERE p.Partida_ID = tt.Terreno_ID 
						AND tt.Terreno_ID = terrenoID;
	CALL Check_SiguePartidaEnJuego(partidaID);
END;


CREATE PROCEDURE Check_SiguePartidaEnJuego(IN partidaID INT)
BEGIN
	DECLARE EquiposEnJuego =  SELECT COUNT(EnJuego) FROM Equipo e, Partida_Equipo pe
								WHERE e.EnJuego = "Si"
								AND e.Equipo_ID = pe.Equipo_ID
								AND pe.Partida_ID = partidaID;
	IF (EquiposEnJuego <= 1)
		CALL Terminar_PartidaTerminar_Partida(partidaID);
END

CREATE PROCEDURE Borrar_Linea_Terreno_Ancho_Cinco(IN x INT,IN y INT,IN terrenoID INT)
BEGIN
	DECLARE i INT;
	SET i = 0;
	WHILE i <= 4 DO
		SET i = i+1;
		UPDATE Terreno
		SET celda = '*'
		WHERE 
			Terreno_ID = terrenoID
			AND Cord_x = x+i;
			AND Cord_y = y;
	END WHILE
END;

CREATE PROCEDURE Explotar_barril(IN posX INT, IN posY INT)
BEGIN
/*
completar:
-Verificar que en esa posición hay una ‘B’
-identifica los gusanos afectados por la explosion y actualiza sus datos.
-modifica el terreno del radio explosivo.
*/
END;


CREATE PROCEDURE Mover_Gusano(IN gusanoID INT ,IN  X INT, INT Y INT );
BEGIN
--completar(NO HAY QUE VERIFICAR NADA, solo moverlo)
END;




