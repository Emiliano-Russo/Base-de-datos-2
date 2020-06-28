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