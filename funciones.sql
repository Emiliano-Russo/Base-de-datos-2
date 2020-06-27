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
--completar
END



CREATE FUNCTION Get_LimiteTerrenoActual(IN equipoID INT)
RETURNS INT
DETERMINISTIC
BEGIN
--completar
END


CREATE FUNCTION Es_Turno_De(IN equipoID INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
--completar
END


CREATE FUNCTION GetTerrenoID_delGusano(IN gusanoID INT)
RETURNS INT
DETERMINISTIC
BEGIN
--completar
END



