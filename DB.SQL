Use gestión_de_inscripciones;

CREATE TABLE USUARIO (
    ID_Usuario INT AUTO_INCREMENT PRIMARY KEY
);

CREATE TABLE RESERVA (
    ID_Reserva INT AUTO_INCREMENT PRIMARY KEY,
    ID_Disponibilidad_Unidad_Recurso  INT unique not null ,
    ID_Unidad_Recurso INT unique not null ,
    ID_Usuario INT unique not null,
    FOREIGN KEY (ID_Disponibilidad_Unidad_Recurso) REFERENCES DISPONIBILIDAD_UNIDAD_RECURSO(ID_Disponibilidad_Unidad_Recurso),
    FOREIGN KEY (ID_Unidad_Recurso) REFERENCES UNIDAD_RECURSO(ID_Unidad_Recurso),
    FOREIGN KEY (ID_Usuario) REFERENCES USUARIO(ID_Usuario)
);

CREATE TABLE HISTORIAL_RESERVA (
    ID_Historial_Reserva INT AUTO_INCREMENT PRIMARY KEY,
    ID_Reserva INT unique not null,
    Fecha_reserva DATE,
    Estado_Reserva ENUM('Activa', 'Cancelada'),
    FOREIGN KEY (ID_Reserva) REFERENCES RESERVA(ID_Reserva)
);

CREATE TABLE UNIDAD_RECURSO (
    ID_Unidad_Recurso INT AUTO_INCREMENT PRIMARY KEY,
    ID_Recurso INT unique not null ,
    Detalle varchar(100) not null, 
    FOREIGN KEY (ID_Recurso) REFERENCES RECURSO(ID_Recurso)
);

CREATE TABLE RECURSO (
    ID_Recurso INT AUTO_INCREMENT PRIMARY KEY,
    Nombre_recurso VARCHAR(255) not null,
    Descripcion VARCHAR(255) not null

);

CREATE TABLE DISPONIBILIDAD_UNIDAD_RECURSO (
    ID_Disponibilidad_Unidad_Recurso INT AUTO_INCREMENT PRIMARY KEY,
    ID_Unidad_Recurso INT unique not null,
    Estado_Unidad_Recurso ENUM('Activa', 'Cancelada'),
    Horario_Uni_Re_Inicio TIME,
    Horario_Uni_Re_Fin TIME,
    CHECK (Horario_Uni_Re_Inicio IN ('08:00:00', '10:00:00', '12:00:00', '14:00:00', '16:00:00', '18:00:00', '20:00:00')),
    CHECK (Horario_Uni_Re_Fin IN ('10:00:00', '12:00:00', '14:00:00', '16:00:00', '18:00:00', '20:00:00', '22:00:00')),
    FOREIGN KEY (ID_Unidad_Recurso) REFERENCES UNIDAD_RECURSO(ID_Unidad_Recurso)
);

CREATE TABLE GESTION_BIBLIOTECARIO_UNIDAD (
    ID_Bibliotecario INT,
    ID_Unidad_Recurso INT,
    FOREIGN KEY (ID_Bibliotecario) REFERENCES BIBLIOTECARIO(ID_Bibliotecario),
    FOREIGN KEY (ID_Unidad_Recurso) REFERENCES UNIDAD_RECURSO(ID_Unidad_Recurso)
);

CREATE TABLE Bibliotecario (
    id_bibliotecario INT AUTO_INCREMENT PRIMARY KEY,
    Nombre_Bibliotecario VARCHAR(50) NOT NULL,
    Apellido_Bibliotecario VARCHAR(50) NOT NULL,
    Fech_Ingreso_Bibliotecario DATE,
    Correo_Insti_Bibliotecario VARCHAR(100) NOT NULL UNIQUE,
    Tel_Bibliotecario VARCHAR(15)
);

#Registro y configuración de recursos (alta de un nuevo recurso)
INSERT INTO RECURSO (Titulo, Tipo)
VALUES ('Sala de Estudio 101', 'Sala');

#Consulta de detalles específicos de un recurso:
SELECT r.Titulo, r.Tipo, ur.ID_Unidad_Recurso
FROM RECURSO r
LEFT JOIN UNIDAD_RECURSO ur ON r.ID_Recurso = ur.ID_Recurso
WHERE r.Titulo = 'Sala de Estudio 101';

#Reservar un recurso en un horario específico:
INSERT INTO RESERVA (ID_Disponibilidad_Unidad_Recurso, ID_Unidad_Recurso, ID_Usuario)
VALUES (
    (SELECT ID_Disponibilidad_Unidad_Recurso 
     FROM DISPONIBILIDAD_UNIDAD_RECURSO 
     WHERE ID_Unidad_Recurso = 1 AND ID_Horario = 3), -- Reemplazar con IDs reales
    1, -- ID_Unidad_Recurso
    101 -- ID_Usuario
);



#FUNCIONALIDADES:

#Cancelar una reserva activa:
DELETE FROM RESERVA
WHERE ID_Reserva = 15; -- Reemplazar con el ID de la reserva

#Consultar el historial de reservas de un usuario:
SELECT hr.Fecha, r.Titulo, du.Horario_Inicio, du.Horario_Fin
FROM HISTORIAL_RESERVA hr
JOIN RESERVA re ON hr.ID_Reserva = re.ID_Reserva
JOIN DISPONIBILIDAD_UNIDAD_RECURSO du ON re.ID_Disponibilidad_Unidad_Recurso = du.ID_Disponibilidad_Unidad_Recurso
JOIN UNIDAD_RECURSO ur ON du.ID_Unidad_Recurso = ur.ID_Unidad_Recurso
JOIN RECURSO r ON ur.ID_Recurso = r.ID_Recurso
WHERE re.ID_Usuario = 101; -- Reemplazar con el ID del usuario

#Buscar recursos disponibles por tipo y horario:
SELECT r.Titulo, du.Horario_Inicio, du.Horario_Fin
FROM RECURSO r
JOIN UNIDAD_RECURSO ur ON r.ID_Recurso = ur.ID_Recurso
JOIN DISPONIBILIDAD_UNIDAD_RECURSO du ON ur.ID_Unidad_Recurso = du.ID_Unidad_Recurso
WHERE r.Tipo = 'Sala' AND du.Horario_Inicio <= '10:00:00' AND du.Horario_Fin >= '12:00:00'
AND du.ID_Disponibilidad_Unidad_Recurso NOT IN (
    SELECT ID_Disponibilidad_Unidad_Recurso FROM RESERVA
);

#Buscar reservas activas:
SELECT re.ID_Reserva, r.Titulo, du.Horario_Inicio, du.Horario_Fin, u.Nombre
FROM RESERVA re
JOIN DISPONIBILIDAD_UNIDAD_RECURSO du ON re.ID_Disponibilidad_Unidad_Recurso = du.ID_Disponibilidad_Unidad_Recurso
JOIN UNIDAD_RECURSO ur ON du.ID_Unidad_Recurso = ur.ID_Unidad_Recurso
JOIN RECURSO r ON ur.ID_Recurso = r.ID_Recurso
JOIN USUARIO u ON re.ID_Usuario = u.ID_Usuario
WHERE re.ID_Reserva NOT IN (
    SELECT ID_Reserva FROM HISTORIAL_RESERVA WHERE Estado = 'Cancelada'
);

#Consultar disponibilidad de recursos en un horario específico:
SELECT r.Titulo, du.Horario_Inicio, du.Horario_Fin, du.ID_Disponibilidad_Unidad_Recurso
FROM RECURSO r
JOIN UNIDAD_RECURSO ur ON r.ID_Recurso = ur.ID_Recurso
JOIN DISPONIBILIDAD_UNIDAD_RECURSO du ON ur.ID_Unidad_Recurso = du.ID_Unidad_Recurso
WHERE du.Horario_Inicio <= '08:00:00' AND du.Horario_Fin >= '10:00:00'
AND du.ID_Disponibilidad_Unidad_Recurso NOT IN (
    SELECT ID_Disponibilidad_Unidad_Recurso FROM RESERVA
);

#Actualizar disponibilidad después de una reserva:
UPDATE DISPONIBILIDAD_UNIDAD_RECURSO
SET Estado = 'Reservado'
WHERE ID_Disponibilidad_Unidad_Recurso = 10; -- Reemplazar con el ID específico
