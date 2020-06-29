-- --------------------------------------------- TABLAS

DROP TABLE IF EXISTS `Prototipo`;
CREATE TABLE Prototipo(
	TipoID INT(3) PRIMARY KEY,
	Alto INT(8) NOT NULL CHECK(Alto >=0 ),
	Ancho INT(3) NOT NULL CHECK(Ancho >=0 )
);

DROP TABLE IF EXISTS `Terreno_Tipo`;
CREATE TABLE Terreno_Tipo(
Terreno_ID INT(8) PRIMARY KEY,
TipoID INT(8) NOT NULL REFERENCES Prototipo(TipoID)
);

DROP TABLE IF EXISTS `Terreno`;
CREATE TABLE Terreno(
Terreno_ID INT(8) NOT NULL REFERENCES Terreno_Tipo(Terreno_ID),
Cord_X INT(3) NOT NULL,
Cord_Y INT(3) NOT NULL,
Celda VARCHAR(1) NOT NULL CHECK(Celda IN (‘A’,’T’,’*’,’P’,’B’,‘A’,’W’,’R’,’L’,’H’)),
PRIMARY KEY (Terreno_ID, Cord_X, Cord_Y)
);

DROP TABLE IF EXISTS `Configuracion`;
CREATE TABLE Configuracion(
Config_ID INT(3) PRIMARY KEY,
Seg_por_Tueno INT(2) NOT NULL,
Duracion_Partida INT(4) NOT NULL CHECK(Duracion_Partida IN (15,20,25)),
Dificultad VARCHAR(30) NOT NULL CHECK(Dificultad IN(‘Facil’,’Intermedio’,’Dificil’))
);


DROP TABLE IF EXISTS `Partida`;
CREATE TABLE Partida(
 Partida_ID INT(8) PRIMARY KEY,
 Config_ID INT(3) NOT NULL REFERENCES Configuracion(Config_ID),  
 Terreno_ID  INT(6) NOT NULL REFERENCES Terreno(Terreno_ID),
  Estado VARCHAR(30) NOT NULL CHECK(Estado IN(‘SinEmpezar’,’EnCurso’,’Terminado’))
);

DROP TABLE IF EXISTS `Partida_Equipo`;
CREATE TABLE Partida_Equipo(
Partida_ID INT(8) NOT NULL REFERENCES Partida(Partida_ID) ,
Equipo_ID INT(8) NOT NULL,
PRIMARY KEY (Partida_ID, Equipo_ID)
);

DROP TABLE IF EXISTS `Equipo`;
CREATE TABLE Equipo(
Equipo_ID INT(8) REFERENCES Partida_Equipo(Equipo_ID),
EnJuego VARCHAR(30) NOT NULL CHECK(EnJuego IN(‘Si’,’No’)),
Control VARCHAR(30) NOT NULL CHECK(Control IN(‘Humano’,’IA’)),
Tiempo_Turno INT(3) NOT NULL
);

DROP TABLE IF EXISTS `Equipo_Gusanos`;
CREATE TABLE Equipo_Gusanos(
Gusano_ID INT(8) NOT NULL,
Equipo_ID INT(8) NOT NULL REFERENCES Partida_Equipo(Equipo_ID),
PRIMARY KEY (Gusano_ID, Equipo_ID) 
);



DROP TABLE IF EXISTS `Arma`;
CREATE TABLE Arma(
	Arma_ID INT(4) PRIMARY KEY ,
	Nombre VARCHAR(30) NOT NULL,
	Tipo VARCHAR(30) NOT NULL,
	Daño INT(4) NOT NULL,
	Destruccion_X INT(3) NOT NULL,
	Destruccion_Y INT(3) NOT NULL
);

DROP TABLE IF EXISTS `Equipo_Arma`;
CREATE TABLE Equipo_Arma(
Arma_ID INT(4) NOT NULL REFERENCES Arma(Arma_ID) ,
Equipo_ID INT(8) NOT NULL REFERENCES Partida_Equipo(Equipo_ID),
PRIMARY KEY (Arma_ID, Equipo_ID)
);

DROP TABLE IF EXISTS ´Gusano´;
CREATE TABLE Gusano(
	Gusano_ID INT(8) NOT NULL REFERENCES Equipo_Gusanos(Gusano_ID),
	Salud INT NOT NULL CHECK(Salud >= 0 AND Salud <= 100),
	Arma_ID INT(4) NOT NULL REFERENCES Arma(Arma_ID),
	Pos_X INT(3) NOT NULL CHECK (POS_X >= 0),
	Pos_Y INT(3) NOT NULL CHECK (POS_Y >= 0),
	PRIMARY KEY (Gusano_ID)
);
	

DROP TABLE IF EXISTS `Marcadores_Partida`;
CREATE TABLE Marcadores_Partida(
	Equipo_ID INT(8) NOT NULL REFERENCES Partida_Equipo(Equipo_ID),
	Deaths INT(2) NOT NULL CHECK(Deaths >= 0 AND Deaths <= 8),
	Kills INT(2) NOT NULL CHECK(Kills >= 0 ),
	Partida_ID INT(8) NOT NULL REFERENCES Partida(Partida_ID),
	PRIMARY KEY (Equipo_ID, Partida_ID)
);

-- --------------------------------------------- FUNCIONES

DELIMITER //
CREATE FUNCTION Get_Ultima_IDPartida() 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE id INT;
    IF ((SELECT COUNT(Partida_ID) FROM partida) = 0 ) THEN
		SET id = 1;
    ELSEIF ((SELECT COUNT(Partida_ID) FROM partida) > 0) THEN
      SET id = (SELECT COUNT(Partida_ID) FROM partida);
    END IF;
    RETURN id;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION ConversorBoolHumano(humano BOOL)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
	DECLARE retorno VARCHAR(10);
	IF humano = TRUE THEN SET retorno = 'Humano';
	ELSE SET retorno = 'IA';
	END IF;
	RETURN retorno;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION Get_UltimoTerrenoID()
RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE id INT;
        IF ((SELECT COUNT(Terreno_ID) FROM terreno_tipo) = 0 ) THEN
            SET id = 1;
        ELSEIF ((SELECT COUNT(Terreno_ID) FROM terreno_tipo) > 0) THEN
            SET id = (SELECT COUNT(Terreno_ID) FROM terreno_tipo);
        END IF;
        RETURN id;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION Ultimo_GusanoID()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE id INT;
    IF ((SELECT COUNT(Gusano_ID) FROM gusano) = 0 ) THEN
		SET id = 1;
    ELSEIF ((SELECT COUNT(Gusano_ID) FROM gusano) > 0) THEN
      SET id = (SELECT COUNT(Gusano_ID) FROM gusano);
    END IF;
    RETURN id;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION Get_UltimoEquipoID()
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE id INT;
    IF ((SELECT COUNT(Equipo_ID) FROM partida_equipo) = 0 ) THEN
		SET id = 1;
    ELSEIF ((SELECT COUNT(Equipo_ID) FROM partida_equipo) > 0) THEN
      SET id = (SELECT MAX(Equipo_ID) FROM partida_equipo);
    END IF;
	RETURN id;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION GetPartidaID(equipoID INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE ID INT;
  SET ID = (SELECT Partida_ID FROM partida_equipo
            WHERE Equipo_ID = equipoID);

  RETURN ID;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION Get_LimiteXTerrenoActual(equipoID INT)
RETURNS INT
DETERMINISTIC
BEGIN

  DECLARE Ancho INT;

  SET Ancho = (SELECT Ancho FROM prototipo p, terreno t, terreno_tipo tt, partida par
              WHERE TipoID = tt.TipoID
              AND tt.Terreno_ID = par.Terreno_ID
              AND par.Partida_ID = GeTPartidaID(equipoID));

  RETURN  Ancho;

END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION Es_Turno_De(equipoID INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE Tiempo BOOLEAN;
  SET Tiempo = (SELECT Tiempo_Turno FROM equipo
                WHERE Equipo_ID = equipoID);
  IF (Tiempo > 0 AND Tiempo <= 30)
    THEN RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION GetTerrenoID_delGusano(gusanoID INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE ID INT;

  SET ID = (SELECT Terreno_ID FROM partida p , partida_Equipo pe, equipo_gusanos
            WHERE p.Partida_ID = pe.Equipo_ID
            AND pe.Gusano_ID = gusanoID);
RETURN ID;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION GetTerrenoID(partidaID INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE ID INT;

    SET ID = (SELECT Terreno_ID FROM partida 
            WHERE Partida_ID = partidaID);
    RETURN ID;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION PartidaEnCurso(partidaID INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE estado VARCHAR(15);
  SET estado = (SELECT Estado FROM partida 
              WHERE Partida_ID = partidaID);
  IF (estado = 'EnCurso')
    THEN RETURN TRUE;
  ELSE 
    RETURN FALSE;
  END IF;

END; //
DELIMITER ;

-- --------------------------------------------- TRIGGERS

DELIMITER //
CREATE TRIGGER NO_MODIFICAR_ARMAS
BEFORE UPDATE ON arma
FOR EACH ROW
BEGIN
	
	signal SQLSTATE '45001' SET message_text = 'No se puede modificar el inventario de armas!';     
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER NO_ELIMINAR_ARMAS
BEFORE DELETE ON arma
FOR EACH ROW
BEGIN
	
	signal SQLSTATE '45002' SET message_text = 'No se puede modificar el inventario de armas!';     
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER NO_MODIFICAR_CONFIGURACION
BEFORE UPDATE ON configuracion
FOR EACH ROW
BEGIN
	
	signal SQLSTATE '45001' SET message_text = 'No se puede modificar las opciones de configuración!';     
END; //
DELIMITER ;

DELIMITER //
CREATE TRIGGER NO_ELIMINAR_CONFIGURACION
BEFORE DELETE ON configuracion
FOR EACH ROW
BEGIN
	
	signal SQLSTATE '45002' SET message_text = 'No se puede eliminar las opciones de configuración!';     
END; //
DELIMITER ;


DELIMITER //
CREATE TRIGGER PartidaEnCurso_Terreno
BEFORE UPDATE ON terreno
FOR EACH ROW
BEGIN
	DECLARE partidaID INT;
	SET partidaID = (SELECT p.Partida_ID FROM partida p , terreno t
					WHERE p.Terreno_ID = t.Terreno_ID 
					AND t.Terreno_ID = OLD.Terreno_ID);
 
	IF (NOT PartidaEnCurso(partidaID))
			THEN signal SQLSTATE '45003' SET message_text = 'La partida no esta en curso'; 
	END IF;
END; //
DELIMITER ;


DELIMITER //
CREATE TRIGGER PartidaEnCurso_Equipo
BEFORE UPDATE ON equipo
FOR EACH ROW
BEGIN
	DECLARE partidaID INT;
	SET partidaID = GetPartidaID(new.Equipo_ID);

	IF (NOT PartidaEnCurso(partidaID))
			THEN signal SQLSTATE '45004' SET message_text = 'La partida no esta en curso'; 
	END IF;
END; //
DELIMITER ;


DELIMITER //
CREATE TRIGGER PartidaEnCurso_Gusano
BEFORE UPDATE ON gusano
FOR EACH ROW
BEGIN
	DECLARE partidaID INT;
	SET partidaID = GetPartidaID((SELECT Equipo_ID FROM Equipo_Gusanos WHERE Gusano_ID = new.Gusano_ID));

	IF (NOT PartidaEnCurso(partidaID))
			THEN signal SQLSTATE '45005' SET message_text = 'La partida no esta en curso';
	END IF;
END; //
DELIMITER ;

-- Atributo control en tabla equipo

DELIMITER //
CREATE TRIGGER AttrControl_TablaEquipo
BEFORE UPDATE ON Equipo
FOR EACH ROW
BEGIN
	IF (new.Control != old.Control)
		THEN signal SQLSTATE '45006' SET message_text = 'No se puede cambiar quien controla el equipo';
	END IF;
END; //
DELIMITER ;

-- Update en qeuipoGusano = error



DELIMITER //
CREATE TRIGGER EquipoGusano_NoUpdate
BEFORE UPDATE ON equipo_gusanos
FOR EACH ROW
BEGIN
	signal SQLSTATE '45007' SET message_text = 'No se puede hacer update en la tabla equipo gusano';
END; //
DELIMITER ;


DELIMITER //
CREATE TRIGGER NoQuitarAgua_Terreno
BEFORE UPDATE ON terreno
FOR EACH ROW
BEGIN
		IF (old.Celda = 'A' AND new.Celda != 'A')
			THEN signal SQLSTATE '45008' SET message_text = 'No puede quitarse el agua del terreno';
		END IF;
END; //
DELIMITER ;	


-- --------------------------------------------- PROCEDIMIENTOS


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



DELIMITER //
CREATE EVENT turnos_tiempo
ON SCHEDULE EVERY 1 SECOND
DO BEGIN	
	UPDATE Equipo SET Tiempo_Turno = Tiempo_Turno - 1
WHERE EnJuego = ‘Si’;
END; //
DELIMITER ;


/* SISTEMA DE TURNOS */
DELIMITER //
CREATE TRIGGER turno_terminado
    BEFORE UPDATE ON equipo
    FOR EACH ROW
    BEGIN
    DECLARE suma INT;
        IF (new.Tiempo_Turno <= 0 ) THEN 
            -- sumar los segundos del resto de registros del equipo + 30
           SET suma = (SELECT SUM(Tiempo_Turno)
	    FROM equipo
	    WHERE EnJuego = ‘Si’ 
	    AND Equipo_ID = old.Equipo_ID AND 
		    new.Tiempo_Turno = suma + 30);
        END IF;
END; //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE Terminar_Turno_Manualmente(IN equipoID INT)
BEGIN
    DECLARE resto INT;
    SET resto = (SELECT Tiempo_Turno 
        FROM Equipo
        WHERE Equipo_ID =equipoID);

    IF (resto > 0 AND resto < 30) THEN 
    UPDATE Equipo SET Tiempo_Turno = Tiempo_Turno - resto 
    WHERE EnJuego = ‘Si’ 
    AND Equipo_ID = equipoID;
    ELSE 
        SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No se puede terminar un turno sin iniciar';
    END IF;
END; //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE Inicializar_Partida (IN nro_config INT, IN cantPersonas INT)
BEGIN
    DECLARE terrenoID INT;
    DECLARE PartidaID INT;

    SET terrenoID = Get_UltimoTerrenoID()+1;
    SET PartidaID = Get_Ultima_IDPartida()+1;

    INSERT INTO partida (Partida_ID, Config_ID, Terreno_ID, Estado)
    VALUES (PartidaID , nro_config, terrenoID,"Sin Empezar");
    
    CALL Iniciar_Terreno_Tipo_Uno(terrenoID);
    CALL Inicializar_Equipos(PartidaID,cantPersonas); 
    CALL Iniciar_MarcadorPartida(idPartida);
END; //
DELIMITER ;

 
DELIMITER //
CREATE PROCEDURE Tirar_Burro(IN equipoID INT,IN X INT)
BEGIN

    DECLARE Y INT;
    DECLARE partidaID INT;
    DECLARE terrenoID INT;
    	

    IF (NOT Es_Turno_De(equipoID)) THEN 
      signal SQLSTATE '45009' SET message_text = 'No es el turno del equipo seleccionado';
    END IF;

    IF (X <= 0 OR (X+4) > Get_LimiteXTerrenoActual(equipoID)) THEN
        signal SQLSTATE '45010' SET message_text = 'Las coordenadas no son correctas';
    END IF;

    SET partidaID = GetPartidaID(equipoID);
    SET terrenoID = GetTerrenoID(partidaID);

    SET Y = 1;
    WHILE Y <= 15 DO
        CALL Aniquilar_Gusanos_De_la_linea(X,Y,terrenoID);
        CALL Borrar_Linea_Terreno_Ancho_Cinco(X,Y,terrenoID);
        SET Y = Y + 1;
    END WHILE;
    CALL Terminar_Turno_Manualmente(equipoID);
END; //
DELIMITER ;



DELIMITER //
CREATE PROCEDURE Salto_Bungee(IN gusanoID INT,IN posFinalX INT, IN posFinalY INT)
pr: BEGIN
    DECLARE X INT;
    DECLARE Y INT;
    DECLARE terernoID INT;
    DECLARE caracter_gusano VARCHAR(1);

    DECLARE celda_objetivo VARCHAR(1);
    DECLARE celda_abajo VARCHAR(1);
    
    START TRANSACTION; 
    
    SET terernoID = GetTerrenoID_delGusano(gusanoID);
    
    SET X = (SELECT POS_X FROM Gusano WHERE Gusano_ID = gusanoID);
    SET Y = (SELECT POS_Y FROM Gusano WHERE Gusano_ID = gusanoID);
    
    SET caracter_gusano = (SELECT Celda 
                        FROM Terreno 
                        WHERE Cord_x = X
                        AND Cord_y = Y
                        AND Terreno_ID = terrenoID);
   
    SET celda_objetivo = (SELECT Celda 
                FROM terreno 
                WHERE 
                Terreno_ID = terrenoID
                AND Cord_x = posFinalX
                AND Cord_y = posFinalY);
    

    IF (celda_objetivo != '*') THEN
        
        signal SQLSTATE '45011' SET message_text = 'No se puede mover a un gusano en espacios ocupados'; 
        ROLLBACK; 
 
    END IF;


    SET celda_abajo = (SELECT Celda 
                FROM terreno 
                WHERE 
                Terreno_ID = terrenoID
                AND Cord_x = posFinalX
                AND Cord_y = posFinalY-1);

    IF (celda_abajo = '*') THEN
        CALL Salto_Bungee(gusanoID,posFinalX,posFinalY-1);    
    ELSEIF (celda_abajo = 'W' OR celda_abajo = 'R' OR celda_abajo ='L' OR celda_abajo='H') THEN 
        ROLLBACK;
        LEAVE pr;
    ELSEIF (celda_abajo = 'A') THEN
        CALL Eliminar_Gusano(X,Y,terrenoID);
        
    ELSEIF (celda_abajo = 'B') THEN 
        CALL Eliminar_Gusano(X,Y,terrenoID); 
        CALL Explotar_barril(posFinalX, posFinalY-1,terrenoID);  
        
    ELSEIF (celda_abajo = 'T' OR celda_abajo='P') THEN
        CALL Mover_Gusano(gusanoID,posFinalX,posfinalY);
        
    END IF;
    /*
    Cuando se actualiza la posición de un gusano:	
    -Controlar que en esa celda haya aire
    -Si abajo hay aire, hacerlo bajar hasta toparse con algo
        -Si el piso es roca o tierra, termina aquí.
        -Si en lugar de tierra o roca, hay una bomba abajo muere el gusano y se llama al procedimiento explotar_barril(pos_x,pos_y). 
        -Si abajo hay Agua el gusano muere.
        -Si abajo hay un gusano se cancela la transaccion
    */
    CALL Terminar_Turno_Manualmente(equipoID);
    COMMIT;
END; //
DELIMITER ;