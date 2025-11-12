# Sistema de Gestión de Catequesis

Este proyecto es una aplicación de consola en Python para gestionar los registros de catequizados (estudiantes) en una base de datos de Microsoft SQL Server. La aplicación permite realizar operaciones CRUD (Crear, Leer, Actualizar, Eliminar) de forma interactiva y segura, validando los datos tanto en la capa de aplicación (Python) como en la capa de base de datos (Stored Procedures).

## 🚀 Características

* **Registro de Catequizados:** Permite registrar nuevos estudiantes con validación completa de campos.
* **Búsqueda por Cédula:** Busca y muestra la información detallada de un catequizado.
* **Actualización de Datos:** Permite actualizar la información de un registro existente, mostrando los valores actuales como sugerencia.
* **Eliminación Segura:** Elimina un registro de la base de datos previa confirmación del usuario.
* **Listado Completo:** Muestra una lista de todos los catequizados registrados y su parroquia.
* **Arquitectura de 3 Capas:** Separa la interfaz (`operacionesCatequizado.py`), la lógica de negocio (`gestorCatequizado.py`) y la base de datos (SQL Server).
* **Seguridad:** Toda la lógica de negocio está encapsulada en **Stored Procedures** de SQL Server, previniendo inyección SQL y centralizando las reglas de negocio (validaciones de formato, duplicados, etc.).

---

## 🏗️ Arquitectura del Proyecto

El sistema está diseñado siguiendo una arquitectura de 3 capas para separar responsabilidades:

1.  **Capa de Presentación (Interfaz):** `operacionesCatequizado.py`
    * Es el "Volante" del sistema.
    * Maneja la lógica del menú interactivo.
    * Se encarga de pedir datos al usuario (`input()`).
    * Realiza las validaciones de cliente (campos vacíos, formato de fechas).
2.  **Capa de Lógica/Datos (Motor):** `gestorCatequizado.py`
    * Actúa como el Data Access Layer (DAL) o "Motor".
    * Contiene la clase `GestorCatequizado`.
    * Su trabajo es traducir las peticiones del usuario en llamadas a la base de datos.
    * Construye y ejecuta las llamadas a los Stored Procedures.
3.  **Capa de Base de Datos (SQL Server):** `*.sql`
    * Es la fuente única de verdad.
    * Los scripts SQL definen el esquema, los datos de prueba, los procedimientos almacenados y la seguridad.

---

## 📋 Prerrequisitos

* Python 3.x
* Microsoft SQL Server (Express, Standard, etc.)
* Microsoft SQL Server Management Studio (SSMS) (Recomendado)
* La librería `pyodbc` de Python.

---

## ⚙️ Guía de Instalación y Puesta en Marcha

Siga estos pasos para ejecutar el proyecto en un entorno local:

### 1. Configuración de la Base de Datos

1.  Abra SSMS y conéctese a la instancia de SQL Server.
2.  Ejecute el script `catequesis_script.sql`. Esto creará la base de datos `CATEQUESIS`, todos los esquemas, tablas, y añadirá datos de prueba.
3.  Ejecute el script `P2-S6-CreacionLogins...sql`. Esto creará el login `pythonconnectCatequesis` con los permisos necesarios para que Python se conecte.
4.  Ejecute el script `Script-Stored-Procedures-CRUD-Catequizado.sql`. Esto creará los 5 Stored Procedures (`sp_Registrar`, `sp_Buscar`, etc.) que la aplicación necesita para funcionar.

### 2. Configuración del Entorno Python

1.  **Instalar dependencias:**
    ```bash
    pip install pyodbc
    ```
2.  **Configurar la conexión:**
    Abra el archivo `config.json` y llene los campos con las credenciales. Se debe usar el login creado en el paso 3 de la configuración de la BD:
    ```json
    {
        "sql_server": {
          "database": "CATEQUESIS",
          "name_server": "NOMBRE_DE_SU_SERVIDOR_SQL", 
          "user": "USUARIO_PYTHON",
          "password": "PASSWORD_PYTHON"
        }
    }
    ```
    (El `name_server` se puede encontrar en la pantalla de conexión de SSMS).

### 3. Ejecutar la Aplicación

Una vez configurada la base de datos y el archivo `config.json`, ejecute el archivo `main.py` desde la terminal:
```bash
py main.py

Aparecerá el menú interactivo para empezar a gestionar los catequizados.

---

## 📂 Descripción de Archivos

* **main.py:** Punto de entrada de la aplicación. Importa `OperacionesCatequizado` y arranca el menú (`iniciar_operaciones()`).

* **operacionesCatequizado.py:** (Capa de Presentación) Contiene la clase `OperacionesCatequizado`. Maneja el menú, pide los datos (`input()`) y llama al gestor.

* **gestorCatequizado.py:** (Capa de Lógica) Contiene la clase `GestorCatequizado`. Se conecta a la BD y ejecuta los Stored Procedures.

* **connection.py:** Módulo de utilidad. Lee `config.json` y provee la función `create_db_connection()` para crear una conexión `pyodbc`.

* **config.json:** (Plantilla) Almacena las credenciales de la BD para no "quemarlas" en el código.

* **catequesis_script.sql:** (SQL) Script de creación de la base de datos completa, esquemas, tablas y datos de prueba.

* **Script-Stored-Procedures-CRUD-Catequizado.sql:** (SQL) Contiene los 5 Stored Procedures del CRUD para la tabla `Catequizado`.

* **P2-S6-CreacionLogins...sql:** (SQL) Script de seguridad para crear el login y usuario `pythonconnectCatequesis` que usa la app.
