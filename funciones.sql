
CREATE FUNCTION Get_Ultima_IDPartida() 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE id INT;
    IF ((SELECT COUNT(´Partida_ID´) FROM Partida) = 0 ) THEN
		SET id = 1;
    ELSEIF ((SELECT COUNT(´Partida_ID´) FROM partida) > 0) THEN
      SET id = (SELECT COUNT(´Partida_ID´) FROM partida);
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
        IF ((SELECT COUNT(´Terreno_ID´) FROM terreno_tipo) = 0 ) THEN
            SET id = 1;
        ELSEIF ((SELECT COUNT(´Terreno_ID´) FROM terreno_tipo) > 0) THEN
            SET id = (SELECT COUNT(´Terreno_ID´) FROM terreno_tipo);
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
    IF ((SELECT COUNT(´Gusano_ID´) FROM gusano) = 0 ) THEN
		SET id = 1;
    ELSEIF ((SELECT COUNT(´Gusano_ID´) FROM gusano) > 0) THEN
      SET id = (SELECT COUNT(´Gusano_ID´) FROM gusano);
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
    IF ((SELECT COUNT(´Equipo_ID´) FROM partida_equipo) = 0 ) THEN
		SET id = 1;
    ELSEIF ((SELECT COUNT(´Equipo_ID´) FROM partida_equipo) > 0) THEN
      SET id = (SELECT MAX(´Equipo_ID´) FROM partida_equipo);
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
  SET ID = (SELECT ´Partida_ID´ FROM partida_equipo
            WHERE ´Equipo_ID´ = equipoID);

  RETURN ID;
END; //
DELIMITER ;

DELIMITER //
CREATE FUNCTION Get_LimiteXTerrenoActual(equipoID INT)
RETURNS INT
DETERMINISTIC
BEGIN

  DECLARE Ancho INT;

  SET Ancho = (SELECT ´Ancho´ FROM prototipo p, terreno t, terreno_tipo tt, partida par
              WHERE ´TipoID´ = tt.TipoID
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
  SET Tiempo = (SELECT ´Tiempo_Turno´ FROM equipo
                WHERE ´Equipo_ID´ = equipoID);
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

  SET ID = (SELECT ´Terreno_ID´ FROM partida p , partida_Equipo pe, equipo_gusanos
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

    SET ID = (SELECT ´Terreno_ID´ FROM partida 
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
  SET estado = (SELECT ´Estado´ FROM partida 
              WHERE Partida_ID = partidaID);
  IF (estado = 'EnCurso')
    THEN RETURN TRUE;
  ELSE 
    RETURN FALSE;
  END IF;

END; //
DELIMITER ;

