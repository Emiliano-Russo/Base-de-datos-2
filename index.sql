-- Aqui estan los procedimientos principales, por asi decirlo publicos

--perparar_partida
CREATE PROCEDURE Inicializar_Partida (IN nro_config INT, IN cantPersonas INT)
BEGIN
    DECLARE terrenoID INT;
    DECLARE PartidaID INT;

    SET terrenoID = Get_UltimoTerrenoID()+1;
    SET PartidaID = Get_Ultima_IDPartida()+1;

    INSERT INTO Partida(Partida ID,config_ID,Terreno _ID,Estado)
    VALUES (PartidaID ,nro _config,terrenoID,’Sin Empezar’);
    CALL Iniciar_Terreno(terrenoID);
    CALL Inicializar_Equipos(PartidaID,cantPersonas) 
    CALL Iniciar_MarcadorPartida(idPartida);
END;


--Tirar Burro
CREATE PROCEDURE Tirar_Burro(IN equipoID INT,IN x1 INT, IN x2 INT)
BEGIN
    DECLARE y INT;
    DECLARE partidaID INT;
    DECLARE terrenoID INT;
    IF (x1 > x2 OR x1 <= 0 OR x2 > 55)
        RAISE_APPLICATION_ERROR(-20001,"Las coordenadas no son correctas") ;
    END IF

    SET terrenoID = Get_Terreno_ID(partidaID);
    SET partidaID = GetPartidaID(IN equipoID INT);

    SET y = 1;
    WHILE y <= 15 DO
        CALL Aniquilar_Gusanos(x1,x2,y,terrenoID );
        CALL Borrar_Linea_Terreno(x1,x2,y,terrenoID );
    SET y = y + 1;
    END WHILE
    CALL Terminar_Turno_Manualmente(equipoID);
END;


--Salto bungee
CREATE PROCEDURE Salto_Bungee(IN gusanoID INT,IN posFinalX INT, IN pos FinalY INT)
BEGIN
--completar
CALL Terminar_Turno_Manualmente(equipoID);
END;

--Terminar Partida
CREATE PROCEDURE terminar_partida (IN PartidaID INT)
BEGIN
/*
completar:
-Mostrar resumen del marcador de la partida
-Eliminar todo lo asociado con esta partida
*/
END;


