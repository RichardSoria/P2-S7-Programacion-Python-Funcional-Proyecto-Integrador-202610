# Importar las librerías para trabjar con JSONs y conexión de BBD
import json
import pyodbc

# Función para leer el archivo de configuración y devolver los parámetros de conexión
def get_db_config(config_file='config.json'):
    with open(config_file, 'r') as file:
        config = json.load(file)
    return config['sql_server']

# Función para establecer la conexión a la base de datos SQL Server
def create_db_connection():
    config = get_db_config()
    connection_string = (
        f"DRIVER={{SQL Server}};"
        f"SERVER={config['name_server']};"
        f"DATABASE={config['database']};"
        f"UID={config['user']};"
        f"PWD={config['password']}"
    )
    
    try:
        # Establecer la conexión
        database = pyodbc.connect(connection_string)
    except Exception as e:
        print("\nError al conectar a la base de datos:", e)
        raise
    else:
        # Crear un cursor para ejecutar consultas
        cursor = database.cursor()
        print("\nConexión exitosa a la base de datos.\n")
        return database, cursor


