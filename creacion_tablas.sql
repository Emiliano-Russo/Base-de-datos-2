DROP TABLE IF EXISTS `Prototipo`;
CREATE TABLE Prototipo(
	TipoID INT(3) PRIMARY KEY,
	Alto INT(8) NOT NULL CHECK(Alto >=0 ),
	Ancho INT(3) NOT NULL CHECK(Ancho >=0 )
);

DROP TABLE IF EXISTS `Terreno_Tipo`;
CREATE TABLE Terreno_Tipo(
Terreno_ID INT(8) PRIMARY KEY,
TipoID INT(8) NOT NULL REFERENCES Prototipo(TipoID)
);

DROP TABLE IF EXISTS `Terreno`;
CREATE TABLE Terreno(
Terreno_ID INT(8) NOT NULL REFERENCES Terreno_Tipo(Terreno_ID),
Cord_X INT(3) NOT NULL,
Cord_Y INT(3) NOT NULL,
Celda VARCHAR(1) NOT NULL CHECK(Celda IN (‘A’,’T’,’*’,’P’,’B’,‘A’,’W’,’R’,’L’,’H’)),
PRIMARY KEY (Terreno_ID, Cord_X, Cord_Y)
);

DROP TABLE IF EXISTS `Configuracion`;
CREATE TABLE Configuracion(
Config_ID INT(3) PRIMARY KEY,
Seg_por_Tueno INT(2) NOT NULL,
Duracion_Partida INT(4) NOT NULL CHECK(Duracion_Partida IN (15,20,25)),
Dificultad VARCHAR(30) NOT NULL CHECK(Dificultad IN(‘Facil’,’Intermedio’,’Dificil’))
);


DROP TABLE IF EXISTS `Partida`;
CREATE TABLE Partida(
 Partida_ID INT(8) PRIMARY KEY,
 Config_ID INT(3) NOT NULL REFERENCES Configuracion(Config_ID),  
 Terreno_ID  INT(6) NOT NULL REFERENCES Terreno(Terreno_ID),
  Estado VARCHAR(30) NOT NULL CHECK(Estado IN(‘SinEmpezar’,’EnCurso’,’Terminado’))
);

DROP TABLE IF EXISTS `Partida_Equipo`;
CREATE TABLE Partida_Equipo(
Partida_ID INT(8) NOT NULL REFERENCES Partida(Partida_ID) ,
Equipo_ID INT(8) NOT NULL,
PRIMARY KEY (Partida_ID, Equipo_ID)
);

DROP TABLE IF EXISTS `Equipo`;
CREATE TABLE Equipo(
Equipo_ID INT(8) REFERENCES Partida_Equipo(Equipo_ID),
EnJuego VARCHAR(30) NOT NULL CHECK(EnJuego IN(‘Si’,’No’)),
Control VARCHAR(30) NOT NULL CHECK(Control IN(‘Humano’,’IA’)),
Tiempo_Turno INT(3) NOT NULL
);

DROP TABLE IF EXISTS `Equipo_Gusanos`;
CREATE TABLE Equipo_Gusanos(
Gusano_ID INT(8) NOT NULL,
Equipo_ID INT(8) NOT NULL REFERENCES Partida_Equipo(Equipo_ID),
PRIMARY KEY (Gusano_ID, Equipo_ID) 
);



DROP TABLE IF EXISTS `Arma`;
CREATE TABLE Arma(
	Arma_ID INT(4) PRIMARY KEY ,
	Nombre VARCHAR(30) NOT NULL,
	Tipo VARCHAR(30) NOT NULL,
	Daño INT(4) NOT NULL,
	Destruccion_X INT(3) NOT NULL,
	Destruccion_Y INT(3) NOT NULL
);

DROP TABLE IF EXISTS `Equipo_Arma`;
CREATE TABLE Equipo_Arma(
Arma_ID INT(4) NOT NULL REFERENCES Arma(Arma_ID) ,
Equipo_ID INT(8) NOT NULL REFERENCES Partida_Equipo(Equipo_ID),
PRIMARY KEY (Arma_ID, Equipo_ID)
);

DROP TABLE IF EXISTS ´Gusano´;
CREATE TABLE Gusano(
	Gusano_ID INT(8) NOT NULL REFERENCES Equipo_Gusanos(Gusano_ID),
	Salud INT NOT NULL CHECK(Salud >= 0 AND Salud <= 100),
	Arma_ID INT(4) NOT NULL REFERENCES Arma(Arma_ID),
	Pos_X INT(3) NOT NULL CHECK (POS_X >= 0),
	Pos_Y INT(3) NOT NULL CHECK (POS_Y >= 0),
	PRIMARY KEY (Gusano_ID)
);
	

DROP TABLE IF EXISTS `Marcadores_Partida`;
CREATE TABLE Marcadores_Partida(
	Equipo_ID INT(8) NOT NULL REFERENCES Partida_Equipo(Equipo_ID),
	Deaths INT(2) NOT NULL CHECK(Deaths >= 0 AND Deaths <= 8),
	Kills INT(2) NOT NULL CHECK(Kills >= 0 ),
	Partida_ID INT(8) NOT NULL REFERENCES Partida(Partida_ID),
	PRIMARY KEY (Equipo_ID, Partida_ID)
);