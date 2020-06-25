/* 
Explicacion: Tenemos una variable agregada a la tabla equipos que se llama Tiempo_Turno, que al estar entre 1 y 30 nos está indicando que es el turno de ese equipo concreto para esa partida.
Una vez aclarado eso, utilizamos un evento para decrementar esa variable y así simular el tiempo disminuyendo de cada turno. seria algo asi como 30,60,120,150. Se van decrementando gradual y paralelamente las variables. 
*/


DELIMITER | 
CREATE EVENT turnos_tiempo
ON SCHEDULE EVERY 1 SECOND
DO BEGIN	
	UPDATE Equipo SET Tiempo_Turno = Tiempo_Turno - 1
WHERE EnJuego = ‘Si’;
END
| DELIMITER ;

/* SISTEMA DE TURNOS */

CREATE TRIGGER turno_terminado
    BEFORE UPDATE 
    ON Equipo FOR EACH ROW
    BEGIN

    DECLARE suma INT;
        IF (new.Tiempo_Turno <= 0 )
            --sumar los segundos del resto de registros del equipo + 30
            suma = SELECT SUM(Tiempo_Turno)
    FROM Equipo
    WHERE EnJuego = ‘Si’ 
    AND Equipo_ID = old.Equipo_ID;
            new.Tiempo_Turno = suma + 30;
        ENDIF;
END;


/*tener en cuenta que, cada vez que un equipo realice una acción (en este caso tirar el burro o utilizar la cuerda bungee),
 hay que actualizar los segundos manualmente porque ya se cambia de turno antes de que se termine el tiempo.*/

CREATE PROCEDURE Terminar_Turno_Manualmente(IN equipoID INT)
BEGIN
    DECLARE resto INT;
    resto = SELECT Tiempo_Turno 
        FROM Equipo
        WHERE Equipo_ID =equipoID;

    IF (resto > 0 AND resto < 30)
    UPDATE Equipo SET Tiempo_Turno = Tiempo_Turno - resto 
    WHERE EnJuego = ‘Si’ 
    AND Equipo_ID = equipoID;
    END;
    ELSE 
        SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'No se puede terminar un turno sin iniciar';
    END IF
END
