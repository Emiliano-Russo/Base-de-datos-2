CREATE TABLE Terreno(
Terreno_ID INT NOT NULL REFERENCE Terreno_Tipo(Terreno_ID),
Cord_X INT NOT NULL,
Cord_Y INT NOT NULL,
Celda VARCHAR(1) NOT NULL CHECK(Celda IN (‘A’,’T’,’*’,’P’,’B’,‘A’,’W’,’R’,’L’,’H’)),
PRIMARY KEY (Terreno_ID,Cord_X ,Cord_Y)
);
CREATE TABLE Terreno_Tipo(
Terreno_IDINT PRIMARY KEY,
TipoID INT NOT NULL REFERENCE Prototipo(TipoID),
);

CREATE TABLE Configuracion(
Config_ID INT PRIMARY KEY,
Seg_por_Tueno INT NOT NULL,
Duracion_Partida INT NOT NULL CHECK(Duracion_Partida IN (15,20,25)),
Dificultad VARCHAR(30) NOT NULL CHECK(Dificultad IN(‘Facil’,’Intermedio’,’Dificil’))
);





CREATE TABLE Partida(
Partida_ID INT PRIMARY KEY,
Config_ID INT REFERENCES Configuracion(Config_ID) NOT NULL,
Terreno_ID NUMBER(6)REFERENCES Terreno(Terreno_ID) NOT NULL,
Estado VARCHAR(30) NOT NULL  CHECK(Estado IN(‘Sin empezar’,’En curso’,’Terminado’))
);
CREATE TABLE Equipo(
PRIMARY KEY (autogereada)
Equipo_ID INT REFERENCES Partida_Equipo(Equipo_ID),
EnJuego VARCAR(30) NOT NULL CHECK(EnJuego IN(‘Si’,’No’)),
Control VARCAR(30) NOT NULL CHECK(Control IN(‘Humano’,’IA’)),
Tiempo_Turno INT NOT NULL
);

CREATE TABLE Partida_Equipo(
Partida_ID INT REFERENCES Partida(Partida_ID) NOT NULL,
Equipo_ID INT PRIMARY KEY,
);

CREATE TABLE Equipo_Gusanos(
Gusano_ID INT PRIMARY KEY,
Equipo_ID INT REFERENCES Partida_Equipo(Equipo_ID) NOT NULL,
);



CREATE TABLE Equipo_Arma(
PRIMARY KEY (autogereada)
Arma_ID INT REFERENCES Arma(Arma_ID) NOT NULL,
Equipo_ID INT REFERENCES Partida_Equipo(Equipo_ID) NOT NULL,
);
CREATE TABLE Gusano(
PRIMARY KEY (autogereada)
	Gusano_ID INT REFERENCES Equipo_Gusano(Gusano_ID),
	Salud INT NOT NULL CHECK(Salud >=0 AND Salud <=100),
	Arma_ID INT REFERENCES Arma(Arma_ID) NOT NULL,
	POS_X INT NOT NULL CHECK(POS_X >=0 ),
POS_Y INT NOT NULL CHECK(POS_Y >=0)
);

CREATE TABLE Arma(
	Arma_ID INT PRIMARY KEY ,
	Nombre VARCHAR(30) NOT NULL,
	Tipo VARCHAR(30) NOT NULL,
Daño INT NOT NULL,
 Destruccion_X INT NOT NULL,
Destruccion_Y INT NOT NULL
);





CREATE TABLE Prototipo(
	TipoID INT PRIMARY KEY,
	Alto INT NOT NULL CHECK(Alto >=0 ),
Ancho INT NOT NULL CHECK(Ancho >=0 )
);
CREATE TABLE Marcadores_Partida(
PRIMARY KEY (autogereada)
	Equipo_ID INT REFERENCES Partida_Equipo(Equipo_ID) NOT NULL,
	Deaths INT NOT NULL CHECK(Deaths >= 0 AND Deaths <= 8),
	Kills INT NOT NULL CHECK(Kills >= 0 ),
Partida_ID INT REFERENCES Partida(Partida_ID) NOT NULL
);
