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

CREATE TRIGGER NO_MODIFICAR_ARMAS
BEFORE UPDATE OR DELETE ON ARMA
BEGIN
	RAISE_APPLICATION_ERROR(-20001,'No se puede modificar el inventario de armas') ;
END;

CREATE TRIGGER NO_MODIFICAR_CONFIGURACION
BEFORE UPDATE OR DELETE ON CONFIGURACION
BEGIN
	RAISE_APPLICATION_ERROR(-20001,'No se puede modificar las opciones de configuración') ;
END;


--2

CREATE TRIGGER PartidaEnCurso_Terreno
BEFORE UPDATE ON Terreno
BEGIN
	DECLARE partidaID INT;
	SET partidaID = SELECT Partida_ID FROM Partida p , Terreno_Tipo tt
					WHERE p.Terreno_ID = tt.Terreno_ID 
					AND tt.Terreno_ID = new.Terreno_ID;

	IF (NOT PartidaEnCurso(partidaID))
			RAISE_APPLICATION_ERROR(-20001,'La partida no esta en curso') ;
END;



CREATE TRIGGER PartidaEnCurso_Equipo
BEFORE UPDATE ON Equipo
BEGIN
	DECLARE partidaID INT;
	SET partidaID = GetPartidaID(new.Equipo_ID);

	IF (NOT PartidaEnCurso(partidaID))
			RAISE_APPLICATION_ERROR(-20001,'La partida no esta en curso') ;
END;


CREATE TRIGGER PartidaEnCurso_Gusano
BEFORE UPDATE ON Gusano
BEGIN
	DECLARE partidaID INT;
	SET partidaID = GetPartidaID((SELECT Equipo_ID FROM Equipo_Gusanos WHERE Gusano_ID = new.Gusano_ID));

	IF (NOT PartidaEnCurso(partidaID))
			RAISE_APPLICATION_ERROR(-20001,'La partida no esta en curso') ;
END;

--Atributo control en tabla equipo

CREATE TRIGGER AttrControl_TablaEquipo
BEFORE UPDATE ON Equipo
BEGIN
	IF (new.Control != old.Control)
		RAISE_APPLICATION_ERROR(-20001,'No se puede cambiar quien controla el equipo');
END;

--Update en qeuipoGusano = error



CREATE TRIGGER EquipoGusano_NoUpdate
BEFORE UPDATE ON Equipo_Gusanos
BEGIN
		RAISE_APPLICATION_ERROR(-20001,'No se puede hacer update en la tabla equipo gusano');
END;



CREATE TRIGGER NoQuitarAgua_Terreno
BEFORE UPDATE ON Terreno
BEGIN
		IF (old.Celda = 'A' AND new.Celda != 'A')
			RAISE_APPLICATION_ERROR(-20001,'No puede quitarse el agua del terreno');
END;	
