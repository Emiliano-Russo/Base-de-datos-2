CREATE FUNCTION Get_Ultima_IDPartida() 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE id int;
    IF ((SELECT COUNT(Partida _ID) FROM Partida) = 0 ) THEN
		SET id = 1;
    ELSE IF ((SELECT COUNT(Partida _ID) FROM Partida) > 0) THEN
      SET id = (SELECT MAX(Partida _ID) FROM Partida)
    END IF;
	-- return 
	RETURN (id);
END$$
DELIMITER ;


CREATE FUNCTION Get_UltimoTerrenoID()
RETURNS INT
DETERMINISTIC
BEGIN
        DECLARE id int;
        IF ((SELECT COUNT(Terreno _ID) FROM Terreno_Tipo) = 0 ) THEN
            SET id = 1;
        ELSE IF ((SELECT COUNT(Terreno _ID) FROM Terreno_Tipo) > 0) THEN
            SET id = (SELECT MAX(Terreno_ID) FROM Terreno_Tipo)
        END IF;
        -- return 
        RETURN (id);
END;


CREATE FUNCTION ConversorBoolHumano(IN Humano BOOL)
RETURNS VARCHAR
DETERMINISTIC
BEGIN
	IF (Humano = True)
		RETURN “Humano”
	ELSE 
		RETURN “IA”;
END;


CREATE FUNCTION Ultimo_GusanoID()
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE id int;
    IF ((SELECT COUNT(Gusano _ID) FROM Gusano) = 0 ) THEN
		SET id = 1;
    ELSE IF ((SELECT COUNT(Gusano _ID) FROM Gusano) > 0) THEN
      SET id = (SELECT MAX(Gusano_ID) FROM Gusano)
    END IF;
	-- return 
	RETURN (id);
END;



CREATE FUNCTION Get_UltimoEquipoID()
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE id int;
    IF ((SELECT COUNT(Equipo _ID) FROM Partida_Equipo) = 0 ) THEN
		SET id = 1;
    ELSE IF ((SELECT COUNT(Equipo _ID) FROM Partida_Equipo) > 0) THEN
      SET id = (SELECT MAX(Equipo_ID) FROM Partida_Equipo)
    END IF;
	-- return 
	RETURN (id);
END;


CREATE FUNCTION GetPartidaID(IN equipoID INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE ID INT;
  SET ID = SELECT Partida_ID FROM Partida_Equipo
            WHERE Equipo_ID = equipoID;

  return ID;
END



CREATE FUNCTION Get_LimiteXTerrenoActual(IN equipoID INT)
RETURNS INT
DETERMINISTIC
BEGIN

  DECLARE Ancho INT;

  SET Ancho = SELECT Ancho FROM Prototipo p, Terreno t, Terreno_Tipo tt, Partida par--Especificar todas las tablas en uso
              WHERE TipoID = tt.TipoID
              AND tt.Terreno_ID = par.Terreno_ID
              AND par.Partida_ID = GeTPartidaID(equipoID);

  RETURN  Ancho;

END


CREATE FUNCTION Es_Turno_De(IN equipoID INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE Tiempo BOOLEAN;
  SET Tiempo = SELECT Tiempo_Turno FROM Equipo
                WHERE Equipo_ID = equipoID;
  IF (Tiempo > 0 AND Tiempo <= 30)
    RETURN TRUE;
  ELSE
    RETURN FALSE;
END


CREATE FUNCTION GetTerrenoID_delGusano(IN gusanoID INT)
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE ID INT;

  SET ID = SELECT Terreno_ID FROM Partida p , Partida_Equipo pe, Equipo_Gusanos
            WHERE p.Partida_ID = pe.Equipo_ID
            AND pe.Gusano_ID =gusanoID;
  RETURN ID;
  END


CREATE FUNCTION GetTerrenoID(IN partidaID INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE ID INT;

    SET ID = SELECT Terreno_ID FROM Partida 
            WHERE Partida_ID = partidaID;
END


CREATE FUNCTION PartidaEnCurso(IN partidaID INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
  DECLARE estado VarChar('15');
  SET estado = SELECT estado FROM Partida 
              WHERE Partida_ID = partidaID;
  IF (estado = 'En curso')
    RETURN TRUE;
  ELSE 
    RETURN FALSE;
  END IF;

END;



