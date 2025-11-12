-- =======================================================================
-- SCRIPT DE CREACIÓN DE BASE DE DATOS: CATEQUESIS 
-- SITIO: Microsoft SQL Server (T-SQL)
-- ESQUEMAS: Configuracion, Proceso, Seguridad
-- =======================================================================

USE master
GO

CREATE DATABASE CATEQUESIS
GO

USE CATEQUESIS
GO

-- ========= CREACIÓN DE ESQUEMAS =========
CREATE SCHEMA Configuracion;
GO
CREATE SCHEMA Proceso;
GO
CREATE SCHEMA Seguridad;
GO

-- ========= CREACIÓN DE TABLAS CATÁLOGO Y DE CONFIGURACIÓN =========

CREATE TABLE Configuracion.Rol (
    idRol INTEGER NOT NULL,
    nombreRol VARCHAR(255) NOT NULL,
    descripcionPermisos VARCHAR(255) NOT NULL,
    CONSTRAINT Rol_PK PRIMARY KEY (idRol),
    CONSTRAINT UQ_Rol_nombreRol UNIQUE (nombreRol),
    CONSTRAINT CK_Rol_nombreRol CHECK (nombreRol IN ('Administrador Diocesano', 'Coordinador Parroquial', 'Catequista Principal', 'Joven de Apoyo'))
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Tabla catálogo que define los diferentes perfiles y niveles de permiso de los usuarios del sistema.', 'SCHEMA', 'Configuracion', 'TABLE', 'Rol';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único del rol.', 'SCHEMA', 'Configuracion', 'TABLE', 'Rol', 'COLUMN', 'idRol';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Nombre del rol (Ej: ''Administrador Diocesano'', ''Coordinador Parroquial'', ''Catequista Principal'', ''Joven de Apoyo'').', 'SCHEMA', 'Configuracion', 'TABLE', 'Rol', 'COLUMN', 'nombreRol';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Un texto que describe qué puede hacer este rol.', 'SCHEMA', 'Configuracion', 'TABLE', 'Rol', 'COLUMN', 'descripcionPermisos';
GO

CREATE TABLE Configuracion.Parroquia (
    idParroquia INTEGER NOT NULL,
    nombreParroquia VARCHAR(255) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    telefonoContacto CHAR(10) NOT NULL,
    emailContacto VARCHAR(255) NOT NULL,
    CONSTRAINT Parroquia_PK PRIMARY KEY (idParroquia),
    CONSTRAINT UQ_Parroquia_email UNIQUE (emailContacto)
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Almacena la información de las sedes eclesiales (parroquias) que administran los programas de catequesis.', 'SCHEMA', 'Configuracion', 'TABLE', 'Parroquia';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único de la parroquia.', 'SCHEMA', 'Configuracion', 'TABLE', 'Parroquia', 'COLUMN', 'idParroquia';
GO

CREATE TABLE Configuracion.Sacramento (
    idSacramento INTEGER NOT NULL,
    nombreSacramento VARCHAR(255) NOT NULL,
    descripcionSacramento VARCHAR(255) NOT NULL,
    CONSTRAINT Sacramento_PK PRIMARY KEY (idSacramento),
    CONSTRAINT UQ_Sacramento_nombre UNIQUE (nombreSacramento)
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Tabla catálogo que almacena los sacramentos que se otorgan al finalizar un ciclo de formación.', 'SCHEMA', 'Configuracion', 'TABLE', 'Sacramento';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único del sacramento.', 'SCHEMA', 'Configuracion', 'TABLE', 'Sacramento', 'COLUMN', 'idSacramento';
GO

CREATE TABLE Configuracion.Nivel (
    idNivel INTEGER NOT NULL,
    nombreNivel VARCHAR(255) NOT NULL,
    descripcionNivel VARCHAR(255) NOT NULL,
    ordenProgresion INTEGER NOT NULL,
    idSacramentoOtorga INTEGER NOT NULL,
    CONSTRAINT Nivel_PK PRIMARY KEY (idNivel),
    CONSTRAINT Nivel_Sacramento_FK FOREIGN KEY (idSacramentoOtorga) REFERENCES Configuracion.Sacramento (idSacramento),
    CONSTRAINT UQ_Nivel_nombre UNIQUE (nombreNivel),
    CONSTRAINT CK_Nivel_ordenProgresion CHECK (ordenProgresion > 0)
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Define la estructura académica. Almacena los distintos niveles o etapas de la formación.', 'SCHEMA', 'Configuracion', 'TABLE', 'Nivel';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único del nivel de formación.', 'SCHEMA', 'Configuracion', 'TABLE', 'Nivel', 'COLUMN', 'idNivel';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Sacramento) El sacramento que se obtiene al finalizar este nivel.', 'SCHEMA', 'Configuracion', 'TABLE', 'Nivel', 'COLUMN', 'idSacramentoOtorga';
GO

-- ========= CREACIÓN DE TABLAS DE ACTORES (USUARIOS Y CATEQUIZADOS) =========

CREATE TABLE Seguridad.Usuario (
    idUsuario INTEGER NOT NULL,
    nombres VARCHAR(255) NOT NULL,
    apellidos VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    passwordHash VARCHAR(255) NOT NULL,
    estadoUsuario BIT NOT NULL,
    idRol INTEGER NOT NULL,
    CONSTRAINT Usuario_PK PRIMARY KEY (idUsuario),
    CONSTRAINT Usuario_Rol_FK FOREIGN KEY (idRol) REFERENCES Configuracion.Rol (idRol),
    CONSTRAINT UQ_Usuario_email UNIQUE (email)
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Almacena las cuentas de todos los usuarios que pueden acceder al sistema (administradores, coordinadores, catequistas).', 'SCHEMA', 'Seguridad', 'TABLE', 'Usuario';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único para todos los usuarios del sistema.', 'SCHEMA', 'Seguridad', 'TABLE', 'Usuario', 'COLUMN', 'idUsuario';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Rol) El rol que tiene este usuario (Coordinador, Catequista, etc.).', 'SCHEMA', 'Seguridad', 'TABLE', 'Usuario', 'COLUMN', 'idRol';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Estado de la cuenta (1=Activo, 0=Inactivo).', 'SCHEMA', 'Seguridad', 'TABLE', 'Usuario', 'COLUMN', 'estadoUsuario';
GO


CREATE TABLE Proceso.Catequizado (
    idCatequizado INTEGER NOT NULL,
    idParroquiaPertenece INTEGER NOT NULL,
    nombres VARCHAR(255) NOT NULL,
    apellidos VARCHAR(255) NOT NULL,
    cedulaIdentidad VARCHAR(10) NOT NULL,
    fechaNacimiento DATE NOT NULL,
    direccionDomicilio VARCHAR(255) NOT NULL,
    nombreRepresentante VARCHAR(255) NOT NULL,
    telefonoRepresentante VARCHAR(255) NOT NULL,
    emailRepresentante VARCHAR(255) NOT NULL,
    fechaBautismo DATE NOT NULL,
    parroquiaBautismo VARCHAR(255) NOT NULL,
    CONSTRAINT Catequizado_PK PRIMARY KEY (idCatequizado),
    CONSTRAINT Catequizado_Parroquia_FK FOREIGN KEY (idParroquiaPertenece) REFERENCES Configuracion.Parroquia (idParroquia),
    CONSTRAINT UQ_Catequizado_cedula UNIQUE (cedulaIdentidad)
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Entidad central que almacena los datos demográficos y de contacto de los estudiantes (catequizados).', 'SCHEMA', 'Proceso', 'TABLE', 'Catequizado';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único del estudiante.', 'SCHEMA', 'Proceso', 'TABLE', 'Catequizado', 'COLUMN', 'idCatequizado';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Parroquia) Indica la parroquia hogar actual del estudiante.', 'SCHEMA', 'Proceso', 'TABLE', 'Catequizado', 'COLUMN', 'idParroquiaPertenece';
GO

-- ========= CREACIÓN DE TABLAS DE PROCESO =========

CREATE TABLE Proceso.Grupo (
    idGrupo INTEGER NOT NULL,
    idNivelPrepara INTEGER NOT NULL,
    idUsuarioCatequista INTEGER NOT NULL,
    idParroquiaPertenece INTEGER NOT NULL,
    nombreGrupo VARCHAR(255) NOT NULL,
    horarioClases VARCHAR(255) NOT NULL,
    aulaAsignada VARCHAR(255) NOT NULL,
    anioLectivo VARCHAR(9) NOT NULL,
    cuposMaximos INTEGER NOT NULL,
    CONSTRAINT Grupo_PK PRIMARY KEY (idGrupo),
    CONSTRAINT Grupo_Nivel_FK FOREIGN KEY (idNivelPrepara) REFERENCES Configuracion.Nivel (idNivel),
    CONSTRAINT Grupo_Usuario_FK FOREIGN KEY (idUsuarioCatequista) REFERENCES Seguridad.Usuario (idUsuario),
    CONSTRAINT Grupo_Parroquia_FK FOREIGN KEY (idParroquiaPertenece) REFERENCES Configuracion.Parroquia (idParroquia),
    CONSTRAINT CK_Grupo_cuposMaximos CHECK (cuposMaximos > 0)
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Almacena las instancias de clase específicas para un nivel. Define el horario, el catequista responsable y la parroquia donde se imparte.', 'SCHEMA', 'Proceso', 'TABLE', 'Grupo';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Nivel) El nivel que este grupo está cursando.', 'SCHEMA', 'Proceso', 'TABLE', 'Grupo', 'COLUMN', 'idNivelPrepara';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Usuario) El ID del usuario (con rol Catequista Principal) que instruye este grupo.', 'SCHEMA', 'Proceso', 'TABLE', 'Grupo', 'COLUMN', 'idUsuarioCatequista';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Parroquia) La parroquia donde se imparte este grupo', 'SCHEMA', 'Proceso', 'TABLE', 'Grupo', 'COLUMN', 'idParroquiaPertenece';
GO

CREATE TABLE Proceso.Traslado (
    idTraslado INTEGER NOT NULL,
    idCatequizadoSolicita INTEGER NOT NULL,
    idParroquiaOrigen INTEGER NOT NULL,
    idParroquiaDestino INTEGER NOT NULL,
    fechaSolicitud DATE NOT NULL,
    fechaAprobacion DATE,
    motivoTraslado VARCHAR(255) NOT NULL,
    estadoTraslado VARCHAR(10) NOT NULL,
    documentoConstanciaPath VARCHAR(1024) NOT NULL,
    CONSTRAINT Traslado_PK PRIMARY KEY (idTraslado),
    CONSTRAINT Traslado_Catequizado_FK FOREIGN KEY (idCatequizadoSolicita) REFERENCES Proceso.Catequizado (idCatequizado),
    CONSTRAINT Traslado_Parroquia_Origen_FK FOREIGN KEY (idParroquiaOrigen) REFERENCES Configuracion.Parroquia (idParroquia),
    CONSTRAINT Traslado_Parroquia_Destino_FK FOREIGN KEY (idParroquiaDestino) REFERENCES Configuracion.Parroquia (idParroquia),
    CONSTRAINT CK_Traslado_estado CHECK (estadoTraslado IN ('Pendiente', 'Aprobado', 'Rechazado'))
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Entidad de evento que registra el historial de movimientos de un catequizado entre parroquias.', 'SCHEMA', 'Proceso', 'TABLE', 'Traslado';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Catequizado) El estudiante que realiza el traslado.', 'SCHEMA', 'Proceso', 'TABLE', 'Traslado', 'COLUMN', 'idCatequizadoSolicita';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Parroquia) La parroquia desde donde sale el estudiante.', 'SCHEMA', 'Proceso', 'TABLE', 'Traslado', 'COLUMN', 'idParroquiaOrigen';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Parroquia) La parroquia a la que llega el estudiante.', 'SCHEMA', 'Proceso', 'TABLE', 'Traslado', 'COLUMN', 'idParroquiaDestino';
GO

CREATE TABLE Proceso.Inscripcion (
    idInscripcion INTEGER NOT NULL,
    idCatequizadoRealiza INTEGER NOT NULL,
    idGrupoPertenece INTEGER NOT NULL,
    fechaInscripcion DATE NOT NULL,
    estadoInscripcion VARCHAR(10) NOT NULL,
    presentoFeBautismo BIT NOT NULL,
    estadoPago VARCHAR(9) NOT NULL,
    montoPago DECIMAL(6,2) NOT NULL,
    CONSTRAINT Inscripcion_PK PRIMARY KEY (idInscripcion),
    CONSTRAINT Inscripcion_Catequizado_FK FOREIGN KEY (idCatequizadoRealiza) REFERENCES Proceso.Catequizado (idCatequizado),
    CONSTRAINT Inscripcion_Grupo_FK FOREIGN KEY (idGrupoPertenece) REFERENCES Proceso.Grupo (idGrupo),
    CONSTRAINT UQ_Inscripcion_AlumnoGrupo UNIQUE (idCatequizadoRealiza, idGrupoPertenece),
    CONSTRAINT CK_Inscripcion_estado CHECK (estadoInscripcion IN ('Cursando', 'Aprobado', 'Reprobado', 'Retirado')),
    CONSTRAINT CK_Inscripcion_estadoPago CHECK (estadoPago IN ('Pendiente', 'Pagado', 'Exonerado')),
    CONSTRAINT CK_Inscripcion_montoPago CHECK (montoPago >= 0)
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Entidad asociativa central. Conecta a un catequizado con un grupo específico.', 'SCHEMA', 'Proceso', 'TABLE', 'Inscripcion';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Catequizado) El estudiante que se inscribe.', 'SCHEMA', 'Proceso', 'TABLE', 'Inscripcion', 'COLUMN', 'idCatequizadoRealiza';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Grupo) El grupo al que se inscribe.', 'SCHEMA', 'Proceso', 'TABLE', 'Inscripcion', 'COLUMN', 'idGrupoPertenece';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Valor booleano (1=Sí, 0=No) que confirma la entrega del requisito.', 'SCHEMA', 'Proceso', 'TABLE', 'Inscripcion', 'COLUMN', 'presentoFeBautismo';
GO

-- ========= CREACIÓN DE TABLAS TRANSACCIONALES (DEPENDIENTES DE INSCRIPCION) =========

CREATE TABLE Proceso.Asistencia (
    idAsistencia INTEGER NOT NULL,
    idInscripcionRegistra INTEGER NOT NULL,
    fechaClase DATE NOT NULL,
    estadoAsistencia VARCHAR(11) NOT NULL,
    CONSTRAINT Asistencia_PK PRIMARY KEY (idAsistencia),
    CONSTRAINT Asistencia_Inscripcion_FK FOREIGN KEY (idInscripcionRegistra) REFERENCES Proceso.Inscripcion (idInscripcion),
    CONSTRAINT CK_Asistencia_estado CHECK (estadoAsistencia IN ('Presente', 'Ausente', 'Justificado'))
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Almacena el registro transaccional de la asistencia de un estudiante para una fecha de clase específica.', 'SCHEMA', 'Proceso', 'TABLE', 'Asistencia';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único del registro de asistencia.', 'SCHEMA', 'Proceso', 'TABLE', 'Asistencia', 'COLUMN', 'idAsistencia';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Inscripcion) La inscripción a la que pertenece esta asistencia.', 'SCHEMA', 'Proceso', 'TABLE', 'Asistencia', 'COLUMN', 'idInscripcionRegistra';
GO

CREATE TABLE Proceso.Calificacion (
    idCalificacion INTEGER NOT NULL,
    idInscripcionAcumula INTEGER NOT NULL,
    descripcionCalificacion VARCHAR(255) NOT NULL,
    notaObtenida DECIMAL(4,2) NOT NULL,
    -- notaSobre DECIMAL(4,2) NOT NULL, -- Columna ELIMINADA
    fechaCalificacion DATE NOT NULL,
    CONSTRAINT Calificacion_PK PRIMARY KEY (idCalificacion),
    CONSTRAINT Calificacion_Inscripcion_FK FOREIGN KEY (idInscripcionAcumula) REFERENCES Proceso.Inscripcion (idInscripcion),
    CONSTRAINT CK_Calificacion_nota CHECK (notaObtenida >= 0 AND notaObtenida <= 10.00) -- Restricción AJUSTADA (asume sobre 10)
    -- CONSTRAINT CK_Calificacion_notaSobre CHECK (notaSobre > 0) -- Restricción ELIMINADA
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Almacena el registro transaccional de las calificaciones (parciales, deberes, finales) obtenidas por un estudiante en una inscripción.', 'SCHEMA', 'Proceso', 'TABLE', 'Calificacion';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único del registro de calificación.', 'SCHEMA', 'Proceso', 'TABLE', 'Calificacion', 'COLUMN', 'idCalificacion';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Inscripcion) La inscripción a la que pertenece esta nota.', 'SCHEMA', 'Proceso', 'TABLE', 'Calificacion', 'COLUMN', 'idInscripcionAcumula';
GO
-- EXEC sp_addextendedproperty 'MS_Description', 'El valor máximo de la nota (Ej: 10).', 'SCHEMA', 'Proceso', 'TABLE', 'Calificacion', 'COLUMN', 'notaSobre'; -- Comentario ELIMINADO
GO

CREATE TABLE Proceso.Certificado (
    idCertificado INTEGER NOT NULL,
    idInscripcionValida INTEGER NOT NULL,
    idUsuarioEmisor INTEGER NOT NULL,
    fechaEmision DATE NOT NULL,
    codigoVerificacionUnico CHAR(36) NOT NULL,
    CONSTRAINT Certificado_PK PRIMARY KEY (idCertificado),
    CONSTRAINT Certificado_Inscripcion_FK FOREIGN KEY (idInscripcionValida) REFERENCES Proceso.Inscripcion (idInscripcion),
    CONSTRAINT Certificado_Usuario_FK FOREIGN KEY (idUsuarioEmisor) REFERENCES Seguridad.Usuario (idUsuario),
    CONSTRAINT UQ_Certificado_Inscripcion UNIQUE (idInscripcionValida),
    CONSTRAINT UQ_Certificado_codigo UNIQUE (codigoVerificacionUnico)
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Almacena la información de los certificados emitidos, validando la aprobación de una inscripción por parte de un coordinador.', 'SCHEMA', 'Proceso', 'TABLE', 'Certificado';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único del certificado emitido.', 'SCHEMA', 'Proceso', 'TABLE', 'Certificado', 'COLUMN', 'idCertificado';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Inscripcion) La inscripción que este certificado está validando (confirma la aprobación).', 'SCHEMA', 'Proceso', 'TABLE', 'Certificado', 'COLUMN', 'idInscripcionValida';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Usuario) El ID del usuario (Coordinador) que generó el documento.', 'SCHEMA', 'Proceso', 'TABLE', 'Certificado', 'COLUMN', 'idUsuarioEmisor';
GO

-- ========= CREACIÓN DE TABLAS DE SISTEMA =========

CREATE TABLE Seguridad.Auditoria (
    idAuditoria INTEGER NOT NULL,
    idUsuarioRealiza INTEGER NOT NULL,
    fechaHoraAccion DATETIME NOT NULL,
    accionRealizada VARCHAR(10) NOT NULL,
    tablaAfectada VARCHAR(255) NOT NULL,
    idRegistroAfectado INTEGER NOT NULL,
    datosNuevos VARCHAR(MAX) NOT NULL,
    datosAntiguos VARCHAR(MAX) NOT NULL,
    CONSTRAINT Auditoria_PK PRIMARY KEY (idAuditoria),
    CONSTRAINT Auditoria_Usuario_FK FOREIGN KEY (idUsuarioRealiza) REFERENCES Seguridad.Usuario (idUsuario)
);
GO
EXEC sp_addextendedproperty 'MS_Description', 'Registra un historial de todas las acciones críticas (INSERT, UPDATE, DELETE) realizadas en el sistema para fines de trazabilidad.', 'SCHEMA', 'Seguridad', 'TABLE', 'Auditoria';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Identificador numérico único del registro de auditoría.', 'SCHEMA', 'Seguridad', 'TABLE', 'Auditoria', 'COLUMN', 'idAuditoria';
GO
EXEC sp_addextendedproperty 'MS_Description', '(Apunta a Usuario) El usuario que realizó la acción.', 'SCHEMA', 'Seguridad', 'TABLE', 'Auditoria', 'COLUMN', 'idUsuarioRealiza';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Un texto (JSON o XML) con los datos después del cambio.', 'SCHEMA', 'Seguridad', 'TABLE', 'Auditoria', 'COLUMN', 'datosNuevos';
GO
EXEC sp_addextendedproperty 'MS_Description', 'Un texto (JSON o XML) con los datos antes del cambio.', 'SCHEMA', 'Seguridad', 'TABLE', 'Auditoria', 'COLUMN', 'datosAntiguos';
GO

-- =======================================================================
-- SCRIPT DE INSERCIÓN DE DATOS DE PRUEBA: CATEQUESIS (CORREGIDO Y SIN notaSobre)
-- =======================================================================

-- ========= TABLAS DE CONFIGURACIÓN =========

INSERT INTO Configuracion.Rol (idRol, nombreRol, descripcionPermisos) VALUES
(1, 'Administrador Diocesano', 'Acceso total al sistema y configuración global.'),
(2, 'Coordinador Parroquial', 'Gestiona inscripciones, certificados y grupos de su parroquia.'),
(3, 'Catequista Principal', 'Registra asistencias, calificaciones y seguimiento de sus grupos.'),
(4, 'Joven de Apoyo', 'Consulta información y apoya en el registro de asistencia.');
GO

INSERT INTO Configuracion.Parroquia (idParroquia, nombreParroquia, direccion, telefonoContacto, emailContacto) VALUES
(1, 'Parroquia La Dolorosa', 'Av. América 123, Quito', '022555111', 'dolorosa@email.com'),
(2, 'Parroquia San José', 'Calle Flores 456, Quito', '022555222', 'sanjose@email.com'),
(3, 'Parroquia Santa Teresita', 'Av. 10 de Agosto 789, Quito', '022555333', 'santateresita@email.com'),
(4, 'Parroquia El Carmelo', 'Calle Guayaquil 101, Quito', '022555444', 'carmelo@email.com'),
(5, 'Parroquia La Magdalena', 'Av. Maldonado 202, Quito', '022555555', 'magdalena@email.com');
GO

INSERT INTO Configuracion.Sacramento (idSacramento, nombreSacramento, descripcionSacramento) VALUES
(1, 'Reconciliación', 'Sacramento del perdón de los pecados.'),
(2, 'Primera Comunión', 'Sacramento de la Eucaristía recibido por primera vez.'),
(3, 'Confirmación', 'Sacramento que perfecciona la gracia bautismal.'),
(4, 'Bautismo', 'Sacramento de iniciación cristiana.'),
(5, 'Matrimonio', 'Sacramento de unión entre un hombre y una mujer.');
GO

INSERT INTO Configuracion.Nivel (idNivel, nombreNivel, descripcionNivel, ordenProgresion, idSacramentoOtorga) VALUES
(1, 'Iniciación Comunión', 'Primer año de preparación para la Primera Comunión.', 1, 2),
(2, 'Culminación Comunión', 'Segundo año, culmina con la Primera Comunión y Reconciliación.', 2, 2),
(3, 'Confirmación Año 1', 'Primer año de preparación para la Confirmación.', 3, 3),
(4, 'Confirmación Año 2', 'Segundo año, culmina con la Confirmación.', 4, 3),
(5, 'Catequesis Adultos - Comunión', 'Preparación acelerada para adultos.', 5, 2);
GO

-- ========= TABLAS DE ACTORES =========

INSERT INTO Seguridad.Usuario (idUsuario, nombres, apellidos, email, passwordHash, estadoUsuario, idRol) VALUES
(1, 'Richard', 'Soria', 'richard.admin@email.com', 'hashed_pass_1', 1, 1),
(2, 'Mateo', 'Morales', 'mateo.coord@email.com', 'hashed_pass_2', 1, 2),
(3, 'Sebastián', 'Vallejo', 'sebas.cateq@email.com', 'hashed_pass_3', 1, 3),
(4, 'Ana', 'Pérez', 'ana.apoyo@email.com', 'hashed_pass_4', 1, 4),
(5, 'Luis', 'García', 'luis.coord2@email.com', 'hashed_pass_5', 1, 2);
GO

INSERT INTO Proceso.Catequizado (idCatequizado, idParroquiaPertenece, nombres, apellidos, cedulaIdentidad, fechaNacimiento, direccionDomicilio, nombreRepresentante, telefonoRepresentante, emailRepresentante, fechaBautismo, parroquiaBautismo) VALUES
(1, 1, 'Juan David', 'López', '1711111111', '2015-03-10', 'Calle A #1-10', 'Carlos López', '0991111111', 'carlos.lopez@email.com', '2015-06-15', 'Parroquia La Dolorosa'),
(2, 1, 'María José', 'Gómez', '1722222222', '2016-07-22', 'Av. B #2-20', 'Elena Gómez', '0992222222', 'elena.gomez@email.com', '2016-10-01', 'Parroquia San José'),
(3, 2, 'Pedro Pablo', 'Martínez', '1733333333', '2014-11-05', 'Calle C #3-30', 'Sofía Martínez', '0993333333', 'sofia.martinez@email.com', '2015-02-12', 'Parroquia San José'),
(4, 2, 'Lucía Fernanda', 'Ramírez', '1744444444', '2017-01-18', 'Av. D #4-40', 'Andrés Ramírez', '0994444444', 'andres.ramirez@email.com', '2017-04-25', 'Parroquia Santa Teresita'),
(5, 1, 'Andrés Felipe', 'Sánchez', '1755555555', '2015-09-30', 'Calle E #5-50', 'Verónica Sánchez', '0995555555', 'veronica.sanchez@email.com', '2015-12-05', 'Parroquia El Carmelo');
GO

-- ========= TABLAS DE PROCESO =========

INSERT INTO Proceso.Grupo (idGrupo, idNivelPrepara, idUsuarioCatequista, idParroquiaPertenece, nombreGrupo, horarioClases, aulaAsignada, anioLectivo, cuposMaximos) VALUES
(1, 1, 3, 1, 'Comunión 1 - Sábados AM', 'Sábados 09:00 - 10:30', 'Salón 1A', '2025-2026', 25),
(2, 2, 3, 1, 'Comunión 2 - Sábados AM', 'Sábados 10:30 - 12:00', 'Salón 1A', '2025-2026', 25),
(3, 1, 3, 1, 'Comunión 1 - Domingos AM', 'Domingos 10:00 - 11:30', 'Salón 1B', '2025-2026', 20),
(4, 3, 3, 1, 'Confirmación 1 - Viernes PM', 'Viernes 16:00 - 17:30', 'Salón 2A', '2025-2026', 30),
(5, 1, 3, 2, 'Comunión 1 - Parroquia 2', 'Sábados 10:00 - 11:30', 'Salón P2-A', '2025-2026', 25);
GO

INSERT INTO Proceso.Traslado (idTraslado, idCatequizadoSolicita, idParroquiaOrigen, idParroquiaDestino, fechaSolicitud, fechaAprobacion, motivoTraslado, estadoTraslado, documentoConstanciaPath) VALUES
(1, 2, 2, 1, '2025-09-01', '2025-09-05', 'Cambio de domicilio', 'Aprobado', '/docs/traslados/constancia_mjg.pdf'),
(2, 3, 2, 1, '2025-10-10', NULL, 'Reagrupación familiar', 'Pendiente', '/docs/traslados/constancia_ppm.pdf'),
(3, 1, 1, 3, '2025-08-15', '2025-08-20', 'Cambio de colegio', 'Aprobado', '/docs/traslados/constancia_jdl.pdf'),
(4, 5, 4, 1, '2025-09-20', '2025-09-25', 'Acercamiento a lugar de trabajo del representante', 'Aprobado', '/docs/traslados/constancia_afs.pdf'),
(5, 4, 3, 2, '2025-10-01', NULL, 'Cambio de domicilio', 'Pendiente', '/docs/traslados/constancia_lfr.pdf');
GO

INSERT INTO Proceso.Inscripcion (idInscripcion, idCatequizadoRealiza, idGrupoPertenece, fechaInscripcion, estadoInscripcion, presentoFeBautismo, estadoPago, montoPago) VALUES
(1, 1, 1, '2025-02-15', 'Cursando', 1, 'Pagado', 50.00),
(2, 2, 1, '2025-02-20', 'Cursando', 1, 'Pagado', 50.00),
(3, 5, 3, '2025-03-01', 'Cursando', 1, 'Pendiente', 50.00),
(4, 1, 2, '2026-02-10', 'Cursando', 1, 'Pagado', 60.00),
(5, 3, 1, '2025-02-25', 'Cursando', 0, 'Pagado', 45.00);
GO

-- ========= TABLAS TRANSACCIONALES (DEPENDIENTES DE INSCRIPCION) =========

INSERT INTO Proceso.Asistencia (idAsistencia, idInscripcionRegistra, fechaClase, estadoAsistencia) VALUES
(1, 1, '2025-10-04', 'Presente'),
(2, 2, '2025-10-04', 'Presente'),
(3, 1, '2025-10-11', 'Ausente'),
(4, 2, '2025-10-11', 'Presente'),
(5, 1, '2025-10-18', 'Justificado');
GO

INSERT INTO Proceso.Calificacion (idCalificacion, idInscripcionAcumula, descripcionCalificacion, notaObtenida, fechaCalificacion) VALUES
(1, 1, 'Lección 1', 8.50, '2025-09-15'),
(2, 2, 'Lección 1', 9.00, '2025-09-15'),
(3, 1, 'Deber 1', 7.00, '2025-09-30'),
(4, 2, 'Deber 1', 10.00, '2025-09-30'),
(5, 1, 'Examen Parcial 1', 7.50, '2025-10-20');
GO

INSERT INTO Proceso.Certificado (idCertificado, idInscripcionValida, idUsuarioEmisor, fechaEmision, codigoVerificacionUnico) VALUES
(1, 4, 2, '2027-07-15', 'CERT-ABCD-1234-EFGH-5678'),
(2, 1, 2, '2026-07-20', 'CERT-IJKL-9012-MNOP-3456'),
(3, 2, 5, '2026-07-22', 'CERT-QRST-7890-UVWX-123Y'),
(4, 3, 2, '2026-07-25', 'CERT-AAAA-BBBB-CCCC-DDDD'),
(5, 5, 5, '2026-07-30', 'CERT-EEEE-FFFF-GGGG-HHHH');
GO

-- ========= TABLA DE SISTEMA =========

INSERT INTO Seguridad.Auditoria (idAuditoria, idUsuarioRealiza, fechaHoraAccion, accionRealizada, tablaAfectada, idRegistroAfectado, datosNuevos, datosAntiguos) VALUES
(1, 2, '2025-10-20 10:00:00', 'INSERT', 'Proceso.Inscripcion', 5, '{"idCatequizado": 3, "idGrupo": 1, ...}', '{}'),
(2, 3, '2025-10-20 11:30:00', 'INSERT', 'Proceso.Calificacion', 5, '{"idInscripcion": 1, "nota": 7.50}', '{}'),
(3, 4, '2025-10-18 09:05:00', 'INSERT', 'Proceso.Asistencia', 5, '{"idInscripcion": 1, "estado": "Justificado"}', '{}'),
(4, 1, '2025-10-19 15:00:00', 'UPDATE', 'Configuracion.Parroquia', 2, '{"telefono": "022555999"}', '{"telefono": "022555222"}'),
(5, 2, '2025-09-05 14:00:00', 'UPDATE', 'Proceso.Traslado', 1, '{"estado": "Aprobado", "fechaAprobacion": "2025-09-05"}', '{"estado": "Pendiente", "fechaAprobacion": null}');
GO