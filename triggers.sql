/*
                            Triggers

Cuando intento modificar las tablas “Arma” o “Configuracion” me salte un error de prohibido la modificación de las mismas
Cuando modifico algo de la partida (terreno, variables de gusano,etc) verificar que la partida esté ‘En curso’, de lo contrario es un error. (capas son muchos triggers por tabla que verifican lo mismo)

Cuando yo modifico la posición del gusano en tabla gusano, se activa un trigger (after update), el cual también actualiza la posición del mismo gusano en la tabla terreno.

Cuando se modifica la salud del gusano hasta 0:
	-posX y posY quedan en null.

Cuando se intenta cambiar a ‘No’ el valor del atributo ‘EnJuego’ de la tabla Equipo, verificar que efectivamente a ese equipo no le quedan
gusanos con vida y actualizar en la tabla de marcadores para ese equipo que tiene 8 deaths (eso se cumple siempre).

Cuando se hace update en la tabla Equipo de la columna ‘control’ exponer un error!

Cuando se hace update de la tabla Equipo_Arma de cualquier valor, exponer un error!

Cuando se hacer un update de la tabla Equipo_Gusanos de cualquier valor, exponer un error!

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


