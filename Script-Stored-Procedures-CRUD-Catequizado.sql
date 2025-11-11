/* Establece el contexto de la base de datos a 'CATEQUESIS' */
USE CATEQUESIS
GO

/* --------------------------------------------------------------------------
-- SP para Registrar un Catequizado
-- Inserta un nuevo registro en Proceso.Catequizado.
-- Realiza validaciones de campos obligatorios, formato y reglas de negocio.
--------------------------------------------------------------------------
*/
CREATE OR ALTER PROCEDURE Proceso.sp_RegistrarCatequizado
    /* Parámetros de entrada que coinciden con las columnas de la tabla */
    @idParroquiaPertenece INTEGER,
    @nombres VARCHAR(255),
    @apellidos VARCHAR(255),
    @cedulaIdentidad VARCHAR(10),
    @fechaNacimiento DATE,
    @direccionDomicilio VARCHAR(255),
    @nombreRepresentante VARCHAR(255),
    @telefonoRepresentante VARCHAR(255),
    @emailRepresentante VARCHAR(255),
    @fechaBautismo DATE,
    @parroquiaBautismo VARCHAR(255),
    /* Parámetro de salida para devolver el resultado (OK/ERROR) al cliente. */
    @MensajeSalida VARCHAR(500) OUTPUT
AS
BEGIN
    /* Evita que SQL Server devuelva el conteo de filas afectadas al cliente. */
    SET NOCOUNT ON;

    /* 1. VALIDACIÓN DE CAMPOS OBLIGATORIOS */
    /* Verifica que ninguno de los campos de texto o fecha obligatorios sea nulo o esté vacío. */
    IF ISNULL(LTRIM(RTRIM(@nombres)), '') = '' OR 
       ISNULL(LTRIM(RTRIM(@apellidos)), '') = '' OR
       ISNULL(LTRIM(RTRIM(@cedulaIdentidad)), '') = '' OR
       @fechaNacimiento IS NULL OR
       ISNULL(LTRIM(RTRIM(@direccionDomicilio)), '') = '' OR
       ISNULL(LTRIM(RTRIM(@nombreRepresentante)), '') = '' OR
       ISNULL(LTRIM(RTRIM(@telefonoRepresentante)), '') = '' OR
       ISNULL(LTRIM(RTRIM(@emailRepresentante)), '') = '' OR
       @fechaBautismo IS NULL OR
       ISNULL(LTRIM(RTRIM(@parroquiaBautismo)), '') = ''
    BEGIN
        /* Si falla la validación, asigna el mensaje de error y detiene la ejecución. */
        SET @MensajeSalida = 'ERROR: Todos los campos son obligatorios. Por favor, complete la información faltante.';
        RETURN;
    END

    /* 2. VALIDACIONES DE FORMATO */
    /* 2a. Cédula: Valida que tenga 10 caracteres y sean solo numéricos. */
    IF LEN(@cedulaIdentidad) != 10 OR @cedulaIdentidad LIKE '%[^0-9]%'
    BEGIN
        SET @MensajeSalida = 'ERROR: La cédula debe tener 10 dígitos numéricos.';
        RETURN;
    END

    /* 2b. Teléfono: Valida el formato de celular de Ecuador (10 dígitos, empieza con '09'). */
    IF LEN(@telefonoRepresentante) != 10 OR @telefonoRepresentante NOT LIKE '09%' OR @telefonoRepresentante LIKE '%[^0-9]%'
    BEGIN
        SET @MensajeSalida = 'ERROR: El teléfono celular debe empezar con 09 y tener 10 dígitos.';
        RETURN;
    END

    /* 2c. Email: Validación básica de formato (debe contener '@' y '.'). */
    IF @emailRepresentante NOT LIKE '%_@__%.__%'
    BEGIN
        SET @MensajeSalida = 'ERROR: El formato del correo electrónico no es válido.';
        RETURN;
    END

    /* 3. VALIDACIONES DE NEGOCIO (Integridad de Datos) */
    /* 3a. Parroquia: Asegura que el ID de la parroquia exista en la tabla de configuración. */
    IF NOT EXISTS (SELECT 1 FROM Configuracion.Parroquia WHERE idParroquia = @idParroquiaPertenece)
    BEGIN
        SET @MensajeSalida = 'ERROR: La parroquia seleccionada no existe en el sistema.';
        RETURN;
    END

    /* 3b. Duplicidad de Cédula: Asegura que la cédula no esté registrada previamente. */
    IF EXISTS (SELECT 1 FROM Proceso.Catequizado WHERE cedulaIdentidad = @cedulaIdentidad)
    BEGIN
        SET @MensajeSalida = 'ERROR: El estudiante con cédula ' + @cedulaIdentidad + ' ya se encuentra registrado.';
        RETURN;
    END

    /* 4. BLOQUE DE INSERCIÓN */
    /* Inicia un bloque try-catch para manejar errores durante la escritura. */
    BEGIN TRY
        /* Calcula manualmente el siguiente ID (ya que la columna no es IDENTITY). */
        DECLARE @NuevoID INTEGER;
        SELECT @NuevoID = ISNULL(MAX(idCatequizado), 0) + 1 FROM Proceso.Catequizado;

        /* Ejecuta la inserción de los datos. Usa TRIM() y LOWER() para limpiar la entrada. */
        INSERT INTO Proceso.Catequizado (
            idCatequizado, idParroquiaPertenece, nombres, apellidos, cedulaIdentidad,
            fechaNacimiento, direccionDomicilio, nombreRepresentante, telefonoRepresentante,
            emailRepresentante, fechaBautismo, parroquiaBautismo
        )
        VALUES (
            @NuevoID, @idParroquiaPertenece, TRIM(@nombres), TRIM(@apellidos), @cedulaIdentidad,
            @fechaNacimiento, TRIM(@direccionDomicilio), TRIM(@nombreRepresentante), 
            TRIM(@telefonoRepresentante), LOWER(TRIM(@emailRepresentante)), @fechaBautismo, TRIM(@parroquiaBautismo)
        );

        /* Asigna el mensaje de éxito si la inserción es correcta. */
        SET @MensajeSalida = 'OK: Registro exitoso. Código asignado: ' + CAST(@NuevoID AS VARCHAR);
    END TRY
    BEGIN CATCH
        /* En caso de un error inesperado (ej. fallo de constraint), captura el error. */
        SET @MensajeSalida = 'ERROR CRÍTICO SQL: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/* --------------------------------------------------------------------------
-- SP para Listar todos los Catequizados
-- Devuelve un listado de todos los catequizados con el nombre de su parroquia.
--------------------------------------------------------------------------
*/
CREATE OR ALTER PROCEDURE Proceso.sp_ListarCatequizados
AS
BEGIN
    SET NOCOUNT ON;

    /* Selecciona explícitamente las columnas deseadas. */
    SELECT 
        idCatequizado AS ID_Catequizado,
        CPA.nombreParroquia AS Nombre_Parroquia, /* Usa un alias para la columna de la parroquia. */
        nombres AS Nombres,
        apellidos AS Apellidos,
        cedulaIdentidad AS Cedula,
        fechaNacimiento AS Fecha_Nacimiento,
        direccionDomicilio AS Direccion,
        nombreRepresentante AS Nombre_Representante,
        telefonoRepresentante AS Telefono_Representante,
        emailRepresentante AS Email_Representante,
        fechaBautismo AS Fecha_Bautismo,
        parroquiaBautismo AS Parroquia_Bautismo
    FROM 
        Proceso.Catequizado
    /* Utiliza LEFT JOIN para incluir a los catequizados incluso si su parroquia (FK) es nula o no existe. */
    LEFT JOIN Configuracion.Parroquia AS CPA ON CPA.idParroquia = idParroquiaPertenece
END
GO

/* --------------------------------------------------------------------------
-- SP para Buscar Catequizado por Cédula
-- Busca y devuelve un catequizado específico por su cédula.
-- Realiza validaciones de formato y existencia.
--------------------------------------------------------------------------
*/
CREATE OR ALTER PROCEDURE Proceso.sp_BuscarCatequizadoPorCedula
    @cedulaIdentidad VARCHAR(10),
    @MensajeSalida VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    /* 1. Validación de campo obligatorio (cédula). */
    IF ISNULL(LTRIM(RTRIM(@cedulaIdentidad)), '') = ''
    BEGIN
        SET @MensajeSalida = 'ERROR: El campo cédula de identidad es obligatorio. Por favor, complete la información faltante.';
        RETURN;
    END

    /* 2. Validación de formato de cédula (10 dígitos numéricos). */
    IF LEN(@cedulaIdentidad) != 10 OR @cedulaIdentidad LIKE '%[^0-9]%'
    BEGIN
        SET @MensajeSalida = 'ERROR: La cédula debe tener 10 dígitos numéricos.';
        RETURN;
    END
    
    /* 3. Validación de existencia: Verifica que el catequizado exista. */
    IF NOT EXISTS (SELECT 1 FROM Proceso.Catequizado WHERE cedulaIdentidad = @cedulaIdentidad)
    BEGIN
        /* Si no existe, asigna el error y detiene la ejecución. */
        SET @MensajeSalida = 'ERROR: No existe ningún catequizado registrado con la cédula ' + @cedulaIdentidad;
        RETURN;
    END
    
    /* Si pasa todas las validaciones, selecciona y devuelve la fila completa del catequizado. */
    SELECT 
        idCatequizado AS ID_Catequizado,
        idParroquiaPertenece AS ID_Parroquia,
        CPA.nombreParroquia AS Nombre_Parroquia,
        nombres AS Nombres,
        apellidos AS Apellidos,
        cedulaIdentidad AS Cedula,
        fechaNacimiento AS Fecha_Nacimiento,
        direccionDomicilio AS Direccion,
        nombreRepresentante AS Nombre_Representante,
        telefonoRepresentante AS Telefono_Representante,
        emailRepresentante AS Email_Representante,
        fechaBautismo AS Fecha_Bautismo,
        parroquiaBautismo AS Parroquia_Bautismo
    FROM 
        Proceso.Catequizado
    LEFT JOIN Configuracion.Parroquia AS CPA ON CPA.idParroquia = idParroquiaPertenece
    WHERE 
        cedulaIdentidad = @cedulaIdentidad;
END
GO

/* --------------------------------------------------------------------------
-- SP para Actualizar un Catequizado
-- Actualiza un registro existente, buscándolo por su cédula actual.
-- Valida los datos nuevos y la integridad de la base de datos.
--------------------------------------------------------------------------
*/
CREATE OR ALTER PROCEDURE Proceso.sp_ActualizarCatequizado
    @cedulaIdentidadActualizar VARCHAR(10), /* Parámetro que identifica el registro a modificar. */
    /* Parámetros para todos los datos nuevos (o sin cambios) */
    @idParroquiaPertenece INTEGER,
    @nombres VARCHAR(255),
    @apellidos VARCHAR(255),
    @cedulaIdentidad VARCHAR(10), /* Este es el valor nuevo (o el mismo) de la cédula. */
    @fechaNacimiento DATE,
    @direccionDomicilio VARCHAR(255),
    @nombreRepresentante VARCHAR(255),
    @telefonoRepresentante VARCHAR(255),
    @emailRepresentante VARCHAR(255),
    @fechaBautismo DATE,
    @parroquiaBautismo VARCHAR(255),
    @MensajeSalida VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    /* 1. VALIDACIÓN DE CAMPOS OBLIGATORIOS (Datos nuevos) */
    IF ISNULL(LTRIM(RTRIM(@cedulaIdentidadActualizar)), '') = '' OR
       ISNULL(LTRIM(RTRIM(@nombres)), '') = '' OR 
       ISNULL(LTRIM(RTRIM(@apellidos)), '') = '' OR
       ISNULL(LTRIM(RTRIM(@cedulaIdentidad)), '') = '' OR
       @fechaNacimiento IS NULL OR
       ISNULL(LTRIM(RTRIM(@direccionDomicilio)), '') = '' OR
       ISNULL(LTRIM(RTRIM(@nombreRepresentante)), '') = '' OR
       ISNULL(LTRIM(RTRIM(@telefonoRepresentante)), '') = '' OR
       ISNULL(LTRIM(RTRIM(@emailRepresentante)), '') = '' OR
       @fechaBautismo IS NULL OR
       ISNULL(LTRIM(RTRIM(@parroquiaBautismo)), '') = ''
    BEGIN
        SET @MensajeSalida = 'ERROR: Todos los campos son obligatorios. Por favor, complete la información faltante.';
        RETURN;
    END

    /* 2. VALIDACIONES DE FORMATO */
    /* 2a. Cédula a Actualizar: Valida el formato de la cédula de búsqueda. */
    IF LEN(@cedulaIdentidadActualizar) != 10 OR @cedulaIdentidadActualizar LIKE '%[^0-9]%'
    BEGIN
        SET @MensajeSalida = 'ERROR: La cédula a actualizar debe tener 10 dígitos numéricos.';
        RETURN;
    END

    /* 2b. Cédula Nueva: Valida el formato de la nueva cédula. */
    IF LEN(@cedulaIdentidad) != 10 OR @cedulaIdentidad LIKE '%[^0-9]%'
    BEGIN
        SET @MensajeSalida = 'ERROR: La cédula debe tener 10 dígitos numéricos.';
        RETURN;
    END

    /* 2c. Teléfono: Valida el formato del nuevo teléfono. */
    IF LEN(@telefonoRepresentante) != 10 OR @telefonoRepresentante NOT LIKE '09%' OR @telefonoRepresentante LIKE '%[^0-9]%'
    BEGIN
        SET @MensajeSalida = 'ERROR: El teléfono celular debe empezar con 09 y tener 10 dígitos.';
        RETURN;
    END

    /* 2d. Email: Valida el formato del nuevo email. */
    IF @emailRepresentante NOT LIKE '%_@__%.__%'
    BEGIN
        SET @MensajeSalida = 'ERROR: El formato del correo electrónico no es válido.';
        RETURN;
    END

    /* 3. VALIDACIÓN DE NEGOCIO (Integridad) */

    /* Variable local para almacenar el ID del registro a actualizar. */
    DECLARE @idCatequizado INT;

    /* 3a. Búsqueda: Obtiene el ID interno usando la cédula actual proporcionada. */
    SELECT @idCatequizado = idCatequizado 
    FROM Proceso.Catequizado 
    WHERE cedulaIdentidad = @cedulaIdentidadActualizar;

    /* 3b. Existencia: Si no se encuentra el ID, devuelve error y termina. */
    IF @idCatequizado IS NULL
    BEGIN
        SET @MensajeSalida = 'ERROR: No se encontró ningún catequizado con la cédula ' + @cedulaIdentidadActualizar;
        RETURN;
    END
    
    /* 3c. Duplicidad: Verifica que la *nueva* cédula no esté en uso por OTRO registro (excluyendo el actual). */
    IF EXISTS (SELECT 1 FROM Proceso.Catequizado 
               WHERE cedulaIdentidad = @cedulaIdentidad
                 AND idCatequizado != @idCatequizado)
    BEGIN
        SET @MensajeSalida = 'ERROR: La cédula ya está registrada con otro estudiante.';
        RETURN;
    END

    /* 3d. Integridad: Valida que la parroquia exista. */
    IF NOT EXISTS (SELECT 1 FROM Configuracion.Parroquia WHERE idParroquia = @idParroquiaPertenece)
    BEGIN
        SET @MensajeSalida = 'ERROR: La parroquia seleccionada no existe en el sistema.';
        RETURN;
    END

    /* 4. BLOQUE DE ACTUALIZACIÓN */
    BEGIN TRY
        /* Ejecuta el UPDATE en la fila identificada por el ID. */
        UPDATE Proceso.Catequizado
        SET 
            idParroquiaPertenece = @idParroquiaPertenece,
            nombres = TRIM(@nombres),
            apellidos = TRIM(@apellidos),
            cedulaIdentidad = @cedulaIdentidad,
            fechaNacimiento = @fechaNacimiento,
            direccionDomicilio = TRIM(@direccionDomicilio),
            nombreRepresentante = TRIM(@nombreRepresentante),
            telefonoRepresentante = TRIM(@telefonoRepresentante),
            emailRepresentante = LOWER(TRIM(@emailRepresentante)),
            fechaBautismo = @fechaBautismo,
            parroquiaBautismo = TRIM(@parroquiaBautismo)
        /* Filtra el UPDATE usando la Primary Key (ID) para máxima eficiencia. */
        WHERE 
            idCatequizado = @idCatequizado;

        SET @MensajeSalida = 'OK: Catequizado actualizado exitosamente.';

    END TRY
    BEGIN CATCH
        /* Captura errores en caso de fallo del UPDATE. */
        SET @MensajeSalida = 'ERROR CRÍTICO SQL: ' + ERROR_MESSAGE();
    END CATCH
END
GO

/* --------------------------------------------------------------------------
-- SP para Eliminar Catequizado por Cédula
-- Elimina un registro de Catequizado usando la cédula.
-- Incluye validaciones y manejo de errores de FK.
--------------------------------------------------------------------------
*/
CREATE OR ALTER PROCEDURE Proceso.sp_EliminarCatequizadoPorCedula
    @cedulaIdentidad VARCHAR(10),
    @MensajeSalida VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    /* 1. Validación de campo obligatorio (cédula). */
    IF ISNULL(LTRIM(RTRIM(@cedulaIdentidad)), '') = ''
    BEGIN
        SET @MensajeSalida = 'ERROR: El campo cédula de identidad es obligatorio. Por favor, complete la información faltante.';
        RETURN;
    END

    /* 2. Validación de formato de cédula (10 dígitos numéricos). */
    IF LEN(@cedulaIdentidad) != 10 OR @cedulaIdentidad LIKE '%[^0-9]%'
    BEGIN
        SET @MensajeSalida = 'ERROR: La cédula debe tener 10 dígitos numéricos.';
        RETURN;
    END
    
    /* 3. Validación de existencia (no se puede borrar lo que no existe). */
    IF NOT EXISTS (SELECT 1 FROM Proceso.Catequizado WHERE cedulaIdentidad = @cedulaIdentidad)
    BEGIN
        SET @MensajeSalida = 'ERROR: No existe ningún catequizado registrado con la cédula ' + @cedulaIdentidad;
        RETURN;
    END
    
    /* 4. BLOQUE DE ELIMINACIÓN */
    BEGIN TRY
        /* Ejecuta la eliminación del registro. */
        DELETE FROM Proceso.Catequizado WHERE cedulaIdentidad = @cedulaIdentidad;
        
        /* Asigna el mensaje de éxito. */
        SET @MensajeSalida = 'OK: Catequizado eliminado exitosamente.';
        
    END TRY
    BEGIN CATCH
        /* Captura errores, especialmente de llaves foráneas (FK). */
        SET @MensajeSalida = 'ERROR SQL: No se pudo eliminar. Es posible que tenga registros asociados (inscripciones, etc.). Detalles: ' + ERROR_MESSAGE();
    END CATCH
END
GO