CREATE PROCEDURE Iniciar_Terreno (IN id INT)
BEGIN
--completar
END;

CREATE PROCEDURE Inicializar_Equipos(IN IDPartida INT,IN cantPersonas INT)
BEGIN
DECALRE x INT;
DECALRE ultimo_equipoID INT;
DECALRE segundos INT;

SET segundos = 30;
SET x = 1;

WHILE x <= 4 DO
SET  x = x + 1;
SET ultimo_equipoID = Get_UltimoEquipoID(); -- Tabla:  Partida_Equipo
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

	INSERT INTO Equipo(Equipo_ID, EnJuego, Control,TiempoTurno)
		VALUES (equipoID, “NO”, ConversorBoolHumano(Humano),segundos);
	
WHILE x <= 30 DO
	x = x+1;
	INSERT INTO Equipo_Arma(Equipo_ID, Arma_ID)
	VALUES (equipoID, 1);
END WHILE;
CALL Crear_GusanosParaEquipo(equipoID); --aca siguen recorriendo tablas
END;


CREATE PROCEDURE Crear_GusanosParaEquipo(IN equipoID INT)
BEGIN
DECALRE x INT;
	SET x = 1;
	WHILE x <= 8 DO
	DECALRE gusanoID = Ultimo_GusanoID()+1;
	INSERT INTO Equipo_Gusanos( Equipo_ID, Gusano_ID)
VALUES (equipoID,gusanoID );
SET x = x + 1;
	CALL RegistrarGusano(gusanoID);
	ENDWHILE
END;


CREATE PROCEDURE RegistrarGusano(IN gusanoID INT)
BEGIN
	INSERT INTO Gusano(Gusano_ID, Salud, Arma_ID, POS_X, POS_Y)
		VALUES(gusanoID, 100, 1, POS_X, POS_Y);
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



CREATE PROCEDURE Aniquilar_Gusanos(IN x1 INT, IN x2 INT,IN y INT,IN terrenoIDINT)
BEGIN
--completar
END;

CREATE PROCEDURE Borrar_Linea_Terreno(IN x1 INT, IN x2 INT,IN y INT,IN terrenoIDINT)
BEGIN
--completar
END;

CREATE PROCEDURE explotar_barril(IN posX INT, IN posY INT)
BEGIN
/*
completar:
-Verificar que en esa posición hay una ‘B’
-identifica los gusanos afectados por la explosion y actualiza sus datos.
-modifica el terreno del radio explosivo.
*/
END;


