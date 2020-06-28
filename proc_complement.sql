DELIMITER //
CREATE PROCEDURE Iniciar_Terreno_Tipo_Uno (IN terrenoID INT)
BEGIN
	INSERT INTO terreno_tipo(Terreno_ID,TipoID)
		VALUES (terrenoID,1);
	CALL Crear_Terreno_Tipo_Uno(id);
END; //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE Crear_Terreno_Tipo_Uno (IN id INT)
BEGIN
DECLARE X  INT;
DECLARE Y  INT;
SET X = 0;
SET Y = 0;
-- Pongo 2 lineas de agua
    WHILE Y <= 1 DO
		WHILE X < 15 DO
        	INSERT INTO terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, X, Y,"A");
        	SET X = X + 1;
		END WHILE;
		SET X = 0;
		SET Y = Y + 1;
    END WHILE;
-- Pongo 4 Lineas de Tierra
	SET X = 0;
	WHILE Y <= 5 DO
		WHILE X < 15 DO
        	INSERT INTO terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, X, Y,"T");
        	SET X = X + 1;
		END WHILE;
		SET X = 0;
		SET Y = Y + 1;
    END WHILE;
-- Pongo 2 Lineas de Piedra
	SET X = 0;
	WHILE Y <= 7 DO
		WHILE X < 15 DO
        	INSERT INTO terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, X, Y,"P");
        	SET X = X + 1;
		END WHILE;
		SET X = 0;
		SET Y = Y + 1;
    END WHILE;
-- Pongo 2 Lineas de Aire
	SET X = 0;
	WHILE Y <= 9 DO
		WHILE X < 15 DO
        	INSERT INTO terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, X, Y,".");
        	SET X = X + 1;
		END WHILE;
		SET X = 0;
		SET Y = Y + 1;
    END WHILE;
-- Pongo 2 Lineas de Piedra
	SET X = 0;
	WHILE Y <= 11 DO
		WHILE X < 15 DO
        	INSERT INTO terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, X, Y,"P");
        	SET X = X + 1;
		END WHILE;
		SET X = 0;
		SET Y = Y + 1;
    END WHILE;
-- Pongo 3 Lineas de Aire
	SET X = 0;
	WHILE Y <= 14 DO
		WHILE X < 15 DO
        	INSERT INTO terreno (Terreno_ID, Cord_x, Cord_y,Celda) VALUES (id, X, Y,"P");
        	SET X = X + 1;
		END WHILE;
		SET X = 0;
		SET Y = Y + 1;
    END WHILE;
END; //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE Inicializar_Equipos(IN IDPartida INT,IN cantPersonas INT)
BEGIN
	DECLARE X INT;
	DECLARE ultimo_equipoID INT;
	DECLARE segundos INT;

	SET segundos = 30;
	SET X = 1;

	WHILE X <= 4 DO
		SET  X = X + 1;
		SET ultimo_equipoID = Get_UltimoEquipoID(); -- Tabla: Partida_Equipo
		INSERT INTO Partida_Equipo (Partida_ID, Equipo_ID)
		VALUES (IDPartida, ultimo_equipoID +1); 
		CALL Registrar_Equipo(ultimo_equipoID +1,segundos,cantPersonas > 0);
		SET segundos = segundos +30;
	END WHILE;
END; //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE Registrar_Equipo(IN equipoID INT,IN segundos INT, IN Humano BOOLEAN)
BEGIN
	DECLARE X INT;
	SET X = 1;

	INSERT INTO equipo(Equipo_ID, EnJuego, Control ,TiempoTurno)
		VALUES (equipoID, "NO", ConversorBoolHumano(Humano),segundos);
	
	WHILE X <= 30 DO
		SET X = X + 1;
		INSERT INTO equipo_arma(Equipo_ID, Arma_ID)
		VALUES (equipoID, 1);
	END WHILE;
	CALL Crear_GusanosParaEquipo(equipoID); -- aca siguen recorriendo tablas
END; //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE Crear_GusanosParaEquipo(IN equipoID INT)
BEGIN
	DECLARE X INT;
	DECLARE gusanoID INT;
	SET X = 1;
	WHILE X <= 8 DO
		SET gusanoID = Ultimo_GusanoID()+1;
		INSERT INTO equipo_gusanos( Equipo_ID, Gusano_ID)
		VALUES (equipoID,gusanoID );
		SET X = X + 1;
		CALL RegistrarGusano(gusanoID);
	END WHILE;
END; //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE RegistrarGusano(IN gusanoID INT)
BEGIN
	DECLARE gusanoInsertado BOOLEAN;
	DECLARE terrenoID INT;
	DECLARE lugarEncontrado BOOLEAN;
	DECLARE X INT;
	DECLARE Y INT;
	DECLARE celda VARCHAR(2);
	SET terrenoID = GetTerrenoID_delGusano(gusanoID);
	SET lugarEncontrado = FALSE;
	
	WHILE lugarEncontrado = FALSE DO
		SET Y = 9;
		SET X = (SELECT FLOOR(RAND()*(55-1+1))+1);
		SET celda = (SELECT Celda FROM Terreno 
					WHERE Terreno_ID = terrenoID 
					AND Cord_Y = Y
					AND Cord_X = X);
		IF (celda = '*')
			THEN SET lugarEncontrado = TRUE;
		END IF;
	END WHILE;
	

	INSERT INTO gusano(Gusano_ID, Salud, Arma_ID, POS_X, POS_Y)
	VALUES(gusanoID, 100, 1, X, Y);
END; //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE Iniciar_MarcadorPartida(IN IDPartida INT)
BEGIN
	DECLARE X INT;
	DECLARE equipoID INT;
	SET equipoID  = Get_UltimoEquipoID()-3;
	SET X = 1;

	WHILE X <= 4 DO
		SET X = X + 1;
		INSERT INTO marcadores_partida(Partida_ID, Equipo_ID, Kills, Deaths)
			VALUES(IDPartida, equipoID, 0, 0);
		SET equipoID = equipoID + 1;
	END WHILE;
		
END; //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE Aniquilar_Gusanos_De_la_linea(IN X INT,IN Y INT,IN terrenoID INT)
BEGIN

	DECLARE i INT;
	DECLARE celda VARCHAR(2);

	SET i = 0;

	WHILE i <= 4 DO
	SET celda = (SELECT Celda 
			FROM terreno 
			WHERE 
			Terreno_ID = terrenoID
			AND Cord_x = (Cord_x+i)
			AND Cord_y = Y);
		IF (celda = 'W' OR celda = 'R' OR celda ='L' OR celda='H') THEN 
			CALL Eliminar_Gusano(X,Y,terrenoID);
		END IF;
	SET i = i +1;
	END WHILE;

END; //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE Eliminar_Gusano(IN X INT,IN Y INT,IN terrenoID INT)
BEGIN
	DECLARE partidaID INT;
	
	UPDATE Gusano 
	SET Salud = 0 , POS_X = NULL , POS_Y = NULL
	WHERE
	Gusano.GusanoID = Equipo_Gusanos.Gusano_ID
	AND Gusano.POS_X = X
	AND Gusano.POS_Y = Y
	AND Equipo_Gusanos.Equipo_ID = Partida_Equipo.Equipo_ID
	AND Partida_Equipo.Partida_ID = Partida.Partida_ID
	AND Partida.Terreno_ID = terrenoID;
	
	UPDATE Terreno SET Celda = '*' WHERE Cord_x = X AND Cord_y = Y AND Terreno_ID = terrenoID;

	SET partidaID = (SELECT Partida_ID FROM partida p, terreno_tipo tt
						WHERE p.Partida_ID = tt.Terreno_ID 
						AND tt.Terreno_ID = terrenoID);
	CALL Check_SiguePartidaEnJuego(partidaID);
END; //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE Check_SiguePartidaEnJuego(IN partidaID INT)
BEGIN
	DECLARE EquiposEnJuego INT;
	SET EquiposEnJuego =  (SELECT COUNT(EnJuego) FROM Equipo e, Partida_Equipo pe
								WHERE e.EnJuego = "Si"
								AND e.Equipo_ID = pe.Equipo_ID
								AND pe.Partida_ID = partidaID);
	IF (EquiposEnJuego <= 1) THEN
		CALL Terminar_PartidaTerminar_Partida(partidaID);
	END IF;
END; //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE Borrar_Linea_Terreno_Ancho_Cinco(IN X INT,IN Y INT,IN terrenoID INT)
BEGIN
	DECLARE i INT;
	SET i = 0;
	WHILE i <= 4 DO
		SET i = i+1;
		IF ((SELECT Celda FROM Terreno WHERE Terreno_ID = terrenoID AND Cord_x = X AND Cord_y = Y) = 'A') THEN
		UPDATE Terreno
		SET celda = '*'
		WHERE 
			Terreno_ID = terrenoID
			AND Cord_x = X+i
			AND Cord_y = Y;
		END IF;
	END WHILE;
END; //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE Explotar_barril(IN posX INT, IN posY INT,IN terrenoID INT)
BEGIN
	UPDATE terreno SET Celda = '*'
	WHERE Terreno_ID = terrenoID
	AND Cord_X = posX
	AND Cord_Y = posY;
END; //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE Mover_Gusano(IN gusanoID INT ,IN  XFinal INT,IN YFinal INT)
BEGIN
	DECLARE XActual INT;	
	DECLARE YActual INT;
	DECLARE terrenoID INT;
	DECLARE letra VARCHAR(2);
	SET XActual = (SELECT POS_X FROM gusano WHERE Gusano_ID = gusanoID);
	SET YActual = (SELECT POS_Y FROM gusano WHERE Gusano_ID = gusanoID);
	SET terrenoID = GetTerrenoID_delGusano(gusanoID);

	UPDATE Gusano SET POS_X = XFinal , POS_Y = YFinal
	WHERE Gusano_ID = gusanoID;

	SET letra = (SELECT Celda FROM terreno
				WHERE Terreno_ID = terrenoID 
				AND  Cord_X = XActual 
				AND Cord_Y = YActual);

	UPDATE Terreno SET Celda = '*'
	WHERE Terreno_ID = terrenoID 
	AND  Cord_X = XActual 
	AND Cord_Y = YActual;

	UPDATE Terreno SET Celda = letra
	WHERE Terreno_ID = terrenoID
	AND Cord_x = XFinal
	AND Cord_y = YFinal;

END; //
DELIMITER ;



