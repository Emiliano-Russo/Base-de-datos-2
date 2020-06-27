-- Aqui estan los procedimientos principales, por asi decirlo publicos

--perparar_partida
CREATE PROCEDURE Inicializar_Partida (IN nro_config INT, IN cantPersonas INT)
BEGIN
    DECLARE terrenoID INT;
    DECLARE PartidaID INT;

    SET terrenoID = Get_UltimoTerrenoID()+1;
    SET PartidaID = Get_Ultima_IDPartida()+1;

    INSERT INTO Partida(Partida ID, Config_ID, Terreno _ID, Estado)
    VALUES (PartidaID , nro _config, terrenoID,"Sin Empezar");
    CALL Iniciar_Terreno_Tipo_Uno(terrenoID);
    CALL Inicializar_Equipos(PartidaID,cantPersonas); 
    CALL Iniciar_MarcadorPartida(idPartida);
END;


--Tirar Burro
CREATE PROCEDURE Tirar_Burro(IN equipoID INT,IN x INT)
BEGIN
    IF (NOT Es_Turno_De(equipoID))
      RAISE_APPLICATION_ERROR(-20001,"No es el turno del equipo seleccionado");
    END IF

    DECLARE y INT;
    DECLARE partidaID INT;
    DECLARE terrenoID INT;
    
    IF (x <= 0 OR (x+4) > Get_LimiteXTerrenoActual(equipoID))
        RAISE_APPLICATION_ERROR(-20001,"Las coordenadas no son correctas");
    END IF

    SET partidaID = GetPartidaID(equipoID);
    SET terrenoID = GetTerrenoID(partidaID);

    SET y = 1;
    WHILE y <= 15 DO
        CALL Aniquilar_Gusanos_De_la_linea(x,y,terrenoID);
        CALL Borrar_Linea_Terreno_Ancho_Cinco(x,y,terrenoID);
        SET y = y + 1;
    END WHILE
    CALL Terminar_Turno_Manualmente(equipoID);
END;


--Salto bungee
CREATE PROCEDURE Salto_Bungee(IN gusanoID INT,IN posFinalX INT, IN posFinalY INT)
BEGIN
    START TRANSACTION 

    DECLARE terernoID = GetTerrenoID_delGusano(gusanoID);
    DECLARE X = (SELECT POS_X FROM Gusano WHERE Gusano_ID = gusanoID);
    DECLARE Y = (SELECT POS_Y FROM Gusano WHERE Gusano_ID = gusanoID);

    DECLARE caracter_gusano = (SELECT Celda 
                        FROM Terreno 
                        WHERE Cord_x = X
                        AND Cord_y = Y
                        AND Terreno_ID = terrenoID;)
    DECLARE celda;
    DECLARE celda_abajo;

    SET celda = (SELECT Celda 
                FROM terreno 
                WHERE 
                Terreno_ID = terrenoID
                AND Cord_x = posFinalX
                AND Cord_y = posFinalY;)
    

    IF (celda != '*')
        ROLLBACK
        RAISE_APPLICATION_ERROR('No se puede mover a un gusano en espacios ocupados');        
    END IF


    SET celda_abajo = SELECT Celda 
                FROM terreno 
                WHERE 
                Terreno_ID = terrenoID
                AND Cord_x = posFinalX
                AND Cord_y = posFinalY-1;

    IF (celda_abajo = '*')
        CALL Salto_Bungee(gusanoID,posFinalX,posFinalY);    
    ELSE IF (celda_abajo = 'W' OR celda_abajo = 'R' OR celda_abajo ='L' OR celda_abajo='H')
        ROLLBACK
        LEAVE pr;
    ELSE IF (celda_abajo = 'A')
        CALL Eliminar_Gusano(X,Y,terrenoID);
        COMMIT
    ELSE IF (celda_abajo = 'B')
        CALL Eliminar_Gusano(X,Y,terrenoID) 
        CALL Explotar_barril(posFinalX, posFinalY-1);  
        COMMIT
    ELSE IF (celda_abajo = 'T' OR celda_abajo='P')
        CALL Mover_Gusano(gusanoID,posFinalX,posfinalY);
        COMMIT
    END IF;
    	--checkear si no era el penultimo equipo sin vida, donde lo hacemos?
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
    END;

--Terminar Partida
CREATE PROCEDURE Terminar_Partida (IN PartidaID INT)
BEGIN
/*
completar:
-Mostrar resumen del marcador de la partida
-Eliminar todo lo asociado con esta partida
*/
END;


