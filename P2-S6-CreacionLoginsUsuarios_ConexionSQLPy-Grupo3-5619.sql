-- TEMA 1: CONTROL DE ACCESO A DATOS (DCL) 

-- Ejercicio 1: Creación 2 Login (Create Login) de acceso al Servidor SQL SERVER con contraseña segura.
USE master
GO

-- 1. Creación del login para el nuevo usuario sasuperadmin
CREATE LOGIN [sagrupo3] WITH PASSWORD='Gr3@Sa', DEFAULT_DATABASE=[master]
GO
-- 2. Habilitar el login del nuevo usuario
ALTER LOGIN [sagrupo3] ENABLE
GO
-- 3. Añadir al ROL sysadmin máximos privilegios
ALTER SERVER ROLE [sysadmin] ADD MEMBER [sagrupo3]

-- 4. Creación del login para el nuevo usuario consultor
CREATE LOGIN [cogrupo3] WITH PASSWORD='Gr3@Co'
GO

-- Consulta que permite la visualización de todos los inicios de sesión del servidor
SELECT name, type_desc FROM sys.server_principals
GO

-- TEMA 2: CREAR USUARIO DE CONEXIÓN DESDE PYTHON A SQL SERVER.

--Crear usuario y Otorgar permiso en SQL SERVER, para conexión a la Base de Datos de su Proyecto Integrador desde Python

-- 1. Creación del login para el nuevo usuario que se conectara a través de Python
CREATE LOGIN [pythonconnectCatequesis] WITH PASSWORD='Py.Cnnt-Sql@Ctqs', DEFAULT_DATABASE=CATEQUESIS,
-- 2. Establecer el idioma para el usuario, la contraseña nunca expira, desactiva la directiva de contraseña de Windows
DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
-- 3. Añadir al ROL sysadmin maximos privilegios
ALTER SERVER ROLE [sysadmin] ADD MEMBER [pythonconnectCatequesis]
GO
-- 4. Asignar o Crear Usuario de Base de Datos
USE CATEQUESIS;
CREATE USER [pythonconnectCatequesis] FOR LOGIN [pythonconnectCatequesis]
GO
-- 5. Asignar un Rol dbowner
USE CATEQUESIS;
ALTER ROLE [db_owner] ADD MEMBER [pythonconnectCatequesis]
GO

-- Cambiar el contexto de la base de datos
USE [master]
GO
-- 6. Conceder el permiso de Conexion SQL Server
GRANT CONNECT SQL TO [pythonconnectCatequesis]
GO

-- Consulta que permite la visualización de todos los inicios de sesión del servidor
SELECT name, type_desc FROM sys.server_principals
GO

-- Cambiar el contexto de la base de datos
USE [CATEQUESIS]
GO
-- Ver usuarios creados de laS bases de datos
SELECT name, type_desc FROM sys.database_principals
GO
