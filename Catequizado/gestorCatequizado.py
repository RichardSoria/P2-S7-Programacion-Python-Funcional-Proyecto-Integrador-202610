import connection as conexion

# Clase para gestionar las operaciones CRUD de un catequizado
class GestorCatequizado:
    def __init__(self, idParroquiaPertenece=None, nombres=None, apellidos=None, cedulaIdentidad=None, 
                 fechaNacimiento=None, direccionDomicilio=None, nombreRepresentante=None, telefonoRepresentante=None, 
                 emailRepresentante=None, fechaBautismo=None, parroquiaBautismo=None):
        
        self.idParroquiaPertenece = idParroquiaPertenece
        self.nombres = nombres
        self.apellidos = apellidos
        self.cedulaIdentidad = cedulaIdentidad
        self.fechaNacimiento = fechaNacimiento
        self.direccionDomicilio = direccionDomicilio
        self.nombreRepresentante = nombreRepresentante
        self.telefonoRepresentante = telefonoRepresentante
        self.emailRepresentante = emailRepresentante
        self.fechaBautismo = fechaBautismo
        self.parroquiaBautismo = parroquiaBautismo
        
    # Método para registrar un nuevo catequizado en la base de datos
    def registrarCatequizado(self):
        # Definir la sentencia SQL para llamar al procedimiento almacenado
        SENTENCIA_SQL = """
        DECLARE @msg VARCHAR(500)
        {CALL Proceso.sp_RegistrarCatequizado(?,?,?,?,?,?,?,?,?,?,?,@msg OUTPUT)}
        SELECT @msg AS mensaje_resultado"""
        # Valores a insertar
        values = (
            self.idParroquiaPertenece,
            self.nombres,
            self.apellidos,
            self.cedulaIdentidad,
            self.fechaNacimiento,
            self.direccionDomicilio,
            self.nombreRepresentante,
            self.telefonoRepresentante,
            self.emailRepresentante,
            self.fechaBautismo,
            self.parroquiaBautismo
        )
        
        # Inicializar las variables de conexión
        database = None
        cursor = None
        
        # Establecer la conexión y ejecutar la consulta
        try:
            connect = conexion.create_db_connection()
        except Exception as e:
            print("Error durante la ejecución de la consulta:", e)
        else:
            # Obtener la base de datos y el cursor
            database, cursor = connect
            # Ejecutar la sentencia SQL con los valores proporcionados
            cursor.execute(SENTENCIA_SQL, values)
            # Obtener el mensaje de resultado del procedimiento almacenado
            row = cursor.fetchone()
            
            # Procesar el mensaje de resultado
            if row:
                mensaje_resultado = row.mensaje_resultado
                if mensaje_resultado.startswith('OK:'):
                    print(mensaje_resultado)
                    print(f'CATEQUIZADO {self.nombres} {self.apellidos} REGISTRADO EXITOSAMENTE.\n')
                    database.commit()
                else:
                    print(mensaje_resultado,"\n")
                    database.rollback()
            else:
                print("\nNo se recibió ningún mensaje de resultado.\n")
                database.rollback()
        finally:
            if cursor:
                cursor.close()
            if database:
                database.close()
            print("Conexión cerrada.\n")
            
    # Método para listar todos los catequizados
    def listarCatequizados(self):
        # Definir la sentencia SQL para llamar al procedimiento almacenado
        SENTENCIA_SQL = "{CALL Proceso.sp_ListarCatequizados}"
        
        # Inicializar las variables de conexión
        database = None
        cursor = None
        
        # Establecer la conexión y ejecutar la consulta
        try:
            connect = conexion.create_db_connection()
        except Exception as e:
            print("\nError durante la ejecución de la consulta:", e)
        else:
            # Obtener la base de datos y el cursor
            database, cursor = connect
            # Ejecutar la sentencia SQL
            cursor.execute(SENTENCIA_SQL)
            # Obtener todos los registros devueltos por el procedimiento almacenado
            rows = cursor.fetchall()
            
            print("\n---------- LISTA DE CATEQUIZADOS ----------")
            for row in rows:
                for idx, column in enumerate(cursor.description):
                    print(f"{column[0]}: {row[idx]}")
                print("-------------------------------------------")
        finally:
            if cursor:
                cursor.close()
            if database:
                database.close()
            print("\nConexión cerrada.\n")
    
    # Método para buscar un catequizado por su cédula de identidad
    def buscarCatequizadoPorCedula(self, cedulaIdentidad):
        # Definir la sentencia SQL para llamar al procedimiento almacenado
        SENTENCIA_SQL = """
        DECLARE @msg VARCHAR(500)
        {CALL Proceso.sp_BuscarCatequizadoPorCedula(?,@msg OUTPUT)}
        SELECT @msg AS mensaje_resultado
        """
        
        # Inicializar las variables de conexión
        database = None
        cursor = None
        
        # Establecer la conexión y ejecutar la consulta
        try:
            connect = conexion.create_db_connection()
        except Exception as e:
            print("\nError durante la ejecución de la consulta:", e)
        else:
            # Obtener la base de datos y el cursor
            database, cursor = connect
            # Ejecutar la sentencia SQL con los valores proporcionados
            cursor.execute(SENTENCIA_SQL, cedulaIdentidad)
            # Obtener el mensaje de resultado del procedimiento almacenado
            row = cursor.fetchone()
            
            if len(row) > 1:
                print("\n---------- CATEQUIZADO ENCONTRADO ----------")
                for idx, column in enumerate(cursor.description):
                    print(f"{column[0]}: {row[idx]}")
                print("-------------------------------------------\n")
                return row
            else:
                mensaje_resultado = row.mensaje_resultado
                print(mensaje_resultado,"\n")
                return None
        finally:
            if cursor:
                cursor.close()
            if database:
                database.close()
            print("Conexión cerrada.\n")
            
    # Método para actualizar los datos de un catequizado
    def actualizarCatequizado(self, cedulaIdentidadActualizar):
        SENTENCIA_SQL = """
        DECLARE @msg VARCHAR(500)
        {CALL Proceso.sp_ActualizarCatequizado(?,?,?,?,?,?,?,?,?,?,?,?,@msg OUTPUT)}
        SELECT @msg AS mensaje_resultado"""
        values = (
            cedulaIdentidadActualizar,
            self.idParroquiaPertenece,
            self.nombres,
            self.apellidos,
            self.cedulaIdentidad,
            self.fechaNacimiento,
            self.direccionDomicilio,
            self.nombreRepresentante,
            self.telefonoRepresentante,
            self.emailRepresentante,
            self.fechaBautismo,
            self.parroquiaBautismo
        )
        
        # Inicializar las variables de conexión
        database = None
        cursor = None
        
        # Establecer la conexión y ejecutar la consulta
        try:
            connect = conexion.create_db_connection()
        except Exception as e:
            print("Error durante la ejecución de la consulta:", e)
        else:
            # Obtener la base de datos y el cursor
            database, cursor = connect
            # Ejecutar la sentencia SQL con los valores proporcionados
            cursor.execute(SENTENCIA_SQL, values)
            # Obtener el mensaje de resultado del procedimiento almacenado
            row = cursor.fetchone()
            
            # Procesar el mensaje de resultado
            if row:
                mensaje_resultado = row.mensaje_resultado
                if mensaje_resultado.startswith('OK:'):
                    print(mensaje_resultado)
                    print(f'CATEQUIZADO {self.nombres} {self.apellidos} ACTUALIZADO EXITOSAMENTE.\n')
                    database.commit()
                else:
                    print(mensaje_resultado,"\n")
                    database.rollback()
            else:
                print("\nNo se recibió ningún mensaje de resultado.\n")
                database.rollback()
        finally:
            if cursor:
                cursor.close()
            if database:
                database.close()
            print("Conexión cerrada.\n")
            
    # Método para eliminar un catequizado por su cédula de identidad
    def eliminarCatequizado(self, cedulaIdentidad):
        SENTENCIA_SQL = """
        DECLARE @msg VARCHAR(500)
        {CALL Proceso.sp_EliminarCatequizadoPorCedula(?,@msg OUTPUT)}
        SELECT @msg AS mensaje_resultado"""
        
        # Inicializar las variables de conexión
        database = None
        cursor = None
        
        # Establecer la conexión y ejecutar la consulta
        try:
            connect = conexion.create_db_connection()
        except Exception as e:
            print("Error durante la ejecución de la consulta:", e)
        else:
            # Obtener la base de datos y el cursor
            database, cursor = connect
            # Ejecutar la sentencia SQL con los valores proporcionados
            cursor.execute(SENTENCIA_SQL, cedulaIdentidad)
            # Obtener el mensaje de resultado del procedimiento almacenado
            row = cursor.fetchone()
            
            # Procesar el mensaje de resultado
            if row:
                mensaje_resultado = row.mensaje_resultado
                if mensaje_resultado.startswith('OK:'):
                    print(mensaje_resultado, "\n")
                    print(f'CATEQUIZADO CON CÉDULA {cedulaIdentidad} ELIMINADO EXITOSAMENTE.\n')
                    database.commit()
                else:
                    print(mensaje_resultado,"\n")
                    database.rollback()
            else:
                print("\nNo se recibió ningún mensaje de resultado.\n")
                database.rollback()
        finally:
            if cursor:
                cursor.close()
            if database:
                database.close()
            print("Conexión cerrada.\n")