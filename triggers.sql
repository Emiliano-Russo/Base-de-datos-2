/*
                            Triggers

-Cuando intento modificar las tablas “Arma” o “Configuracion” me salte un error de prohibido la modificación de las mismas ✓

-Cuando modifico algo de la partida (terreno, variables de gusano,etc) verificar que la partida esté ‘En curso’, de lo contrario es un error. 
(capas son muchos triggers por tabla que verifican lo mismo)  ✓

-Cuando se modifica la salud del gusano hasta 0:
	-posX y posY quedan en null. (ya esta hecho por un Eliminar_Gusano)

-Cuando se intenta cambiar a ‘No’ el valor del atributo ‘EnJuego’ de la tabla Equipo, verificar que efectivamente
 a ese equipo no le quedan gusanos con vida 
 y actualizar en la tabla de marcadores para ese equipo que tiene 8 deaths (eso se cumple siempre).

-Cuando se hace update en la tabla Equipo de la columna ‘control’ exponer un error! ✓

-Cuando se hacer un update de la tabla Equipo_Gusanos de cualquier valor, exponer un error! ✓

El caracter agua ‘A’ en el terreno es inmodificable, verificar eso
*/

/*
                            Triggers

-Cuando intento modificar las tablas “Arma” o “Configuracion” me salte un error de prohibido la modificación de las mismas ✓

-Cuando modifico algo de la partida (terreno, variables de gusano,etc) verificar que la partida esté ‘En curso’, de lo contrario es un error. 
(capas son muchos triggers por tabla que verifican lo mismo)  ✓

-Cuando se modifica la salud del gusano hasta 0:
	-posX y posY quedan en null. (ya esta hecho por un Eliminar_Gusano)

-Cuando se intenta cambiar a ‘No’ el valor del atributo ‘EnJuego’ de la tabla Equipo, verificar que efectivamente
 a ese equipo no le quedan gusanos con vida 
 y actualizar en la tabla de marcadores para ese equipo que tiene 8 deaths (eso se cumple siempre).

-Cuando se hace update en la tabla Equipo de la columna ‘control’ exponer un error! ✓

-Cuando se hacer un update de la tabla Equipo_Gusanos de cualquier valor, exponer un error! ✓

El caracter agua ‘A’ en el terreno es inmodificable, verificar eso
*/

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