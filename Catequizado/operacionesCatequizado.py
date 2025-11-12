from datetime import datetime
# Importamos la clase GestorCatequizado
from Catequizado.gestorCatequizado import GestorCatequizado

# Clase que maneja las operaciones del menú para catequizados
class OperacionesCatequizado:
    
    def __init__(self):
        self.gestor_herramienta = GestorCatequizado()

    def mostrar_menu(self):
        print("\n--- Sistema de Gestión de Catequesis ---")
        print("1. Registrar nuevo catequizado")
        print("2. Buscar catequizado por cédula")
        print("3. Actualizar catequizado")
        print("4. Eliminar catequizado")
        print("5. Listar todos los catequizados")
        print("6. Salir")
        return input("Seleccione una opción: ")
    
    # Método principal para iniciar las operaciones
    def iniciar_operaciones(self):
        while True:
            opcion = self.mostrar_menu()
            
            if opcion == '1':
                self.operacion_registrar()
            elif opcion == '2':
                self.operacion_buscar()
            elif opcion == '3':
                self.operacion_actualizar()
            elif opcion == '4':
                self.operacion_eliminar()
            elif opcion == '5':
                self.operacion_listar()
            elif opcion == '6':
                print("Saliendo del sistema...")
                break # Rompe el bucle while True
            else:
                print("Opción no válida. Intente de nuevo.")

    # --- MÉTODO PRIVADO DE VALIDACIÓN ---
    
    def _validar_campos(self, datos):
        # 1. Validación de campos vacíos
        for campo, valor in datos.items():
            if not str(valor).strip(): # .strip() quita espacios en blanco
                return False, f"[ERROR] El campo '{campo}' no puede estar vacío."

        # 2. Validación de formatos
        try:
            # a) ID de Parroquia
            datos["idParroquiaPertenece"] = int(datos["idParroquiaPertenece"])
            
            # b) Fechas (YYYY-MM-DD)
            fecha_nac = datetime.strptime(datos["fechaNacimiento"], '%Y-%m-%d')
            fecha_baut = datetime.strptime(datos["fechaBautismo"], '%Y-%m-%d')
            
            # c) Lógica de Fechas
            if fecha_baut < fecha_nac:
                return False, "[ERROR] La fecha de bautismo no puede ser anterior a la de nacimiento."
            

        except ValueError:
            return False, "[ERROR] ID de Parroquia o Formato de Fecha incorrecto. Use YYYY-MM-DD."
        
        return True, "OK" # Si todo pasó, es válido

    # --- OPERACIONES DEL MENÚ ---

    def operacion_registrar(self):
        print("\n--- 1. Registrar Nuevo Catequizado ---")
        
        # Pedir todos los datos por consola
        datos_nuevos = {
            "idParroquiaPertenece": input("ID de la Parroquia: "),
            "nombres": input("Nombres: "),
            "apellidos": input("Apellidos: "),
            "cedulaIdentidad": input("Cédula de Identidad: "),
            "fechaNacimiento": input("Fecha de Nacimiento (YYYY-MM-DD): "),
            "direccionDomicilio": input("Dirección de Domicilio: "),
            "nombreRepresentante": input("Nombre del Representante: "),
            "telefonoRepresentante": input("Teléfono del Representante: "),
            "emailRepresentante": input("Email del Representante: "),
            "fechaBautismo": input("Fecha de Bautismo (YYYY-MM-DD): "),
            "parroquiaBautismo": input("Parroquia de Bautismo: ")
        }
        
        # Validar los datos
        es_valido, mensaje = self._validar_campos(datos_nuevos)
        if not es_valido:
            print(mensaje)
            return # Detiene la operación

        # Si es válido, crear el objeto Gestor "lleno"
        catequizado_nuevo = GestorCatequizado(
            idParroquiaPertenece=datos_nuevos["idParroquiaPertenece"],
            nombres=datos_nuevos["nombres"],
            apellidos=datos_nuevos["apellidos"],
            cedulaIdentidad=datos_nuevos["cedulaIdentidad"],
            fechaNacimiento=datos_nuevos["fechaNacimiento"],
            direccionDomicilio=datos_nuevos["direccionDomicilio"],
            nombreRepresentante=datos_nuevos["nombreRepresentante"],
            telefonoRepresentante=datos_nuevos["telefonoRepresentante"],
            emailRepresentante=datos_nuevos["emailRepresentante"],
            fechaBautismo=datos_nuevos["fechaBautismo"],
            parroquiaBautismo=datos_nuevos["parroquiaBautismo"]
        )
        
        # Usar el gestor "herramienta" para registrar el nuevo catequizado
        catequizado_nuevo.registrarCatequizado()

    def operacion_buscar(self):
        print("\n--- 2. Buscar Catequizado ---")
        cedula = input("Ingrese la cédula a buscar: ")
        if not cedula.strip():
            print("[ERROR] La cédula no puede estar vacía.")
            return
            
        # Usar el gestor "herramienta"
        self.gestor_herramienta.buscarCatequizadoPorCedula(cedula)
        
    def operacion_actualizar(self):
        print("\n--- 3. Actualizar Catequizado ---")
        
        # --- PASO 1: BUSCAR ---
        cedula_actual = input("Ingrese la CÉDULA ACTUAL del catequizado a editar: ")
        if not cedula_actual.strip():
            print("[ERROR] La cédula no puede estar vacía.")
            return
        
        # Obtener los datos actuales del catequizado
        datos_actuales = self.gestor_herramienta.buscarCatequizadoPorCedula(cedula_actual)
        
        if not datos_actuales:
            print("No se puede actualizar un registro que no existe.")
            return

        # --- PASO 2: PEDIR NUEVOS DATOS ---
        print("\nIngrese los nuevos datos (Presione Enter para dejar el valor actual):")
        
        datos_actualizados = {
            "idParroquiaPertenece": input(f"ID Parroquia [{datos_actuales[2]}]: ") or datos_actuales[1],
            "nombres": input(f"Nombres [{datos_actuales[3]}]: ") or datos_actuales[3],
            "apellidos": input(f"Apellidos [{datos_actuales[4]}]: ") or datos_actuales[4],
            "cedulaIdentidad": input(f"Cédula [{datos_actuales[5]}]: ") or datos_actuales[5],
            "fechaNacimiento": input(f"Fecha Nacimiento [{datos_actuales[6]}]: ") or datos_actuales[6],
            "direccionDomicilio": input(f"Dirección [{datos_actuales[7]}]: ") or datos_actuales[7],
            "nombreRepresentante": input(f"Representante [{datos_actuales[8]}]: ") or datos_actuales[8],
            "telefonoRepresentante": input(f"Teléfono [{datos_actuales[9]}]: ") or datos_actuales[9],
            "emailRepresentante": input(f"Email [{datos_actuales[10]}]: ") or datos_actuales[10],
            "fechaBautismo": input(f"Fecha Bautismo [{datos_actuales[11]}]: ") or datos_actuales[11],
            "parroquiaBautismo": input(f"Parroquia Bautismo [{datos_actuales[12]}]: ") or datos_actuales[12]
        }
        
        # Validar los datos nuevos
        es_valido, mensaje = self._validar_campos(datos_actualizados)
        if not es_valido:
            print(mensaje)
            return

        # --- PASO 3: GUARDAR ---
        gestor_actualizado = GestorCatequizado(
            idParroquiaPertenece=datos_actualizados["idParroquiaPertenece"],
            nombres=datos_actualizados["nombres"],
            apellidos=datos_actualizados["apellidos"],
            cedulaIdentidad=datos_actualizados["cedulaIdentidad"],
            fechaNacimiento=datos_actualizados["fechaNacimiento"],
            direccionDomicilio=datos_actualizados["direccionDomicilio"],
            nombreRepresentante=datos_actualizados["nombreRepresentante"],
            telefonoRepresentante=datos_actualizados["telefonoRepresentante"],
            emailRepresentante=datos_actualizados["emailRepresentante"],
            fechaBautismo=datos_actualizados["fechaBautismo"],
            parroquiaBautismo=datos_actualizados["parroquiaBautismo"]
        )
        
        # Usar el gestor "herramienta" para actualizar
        gestor_actualizado.actualizarCatequizado(cedula_actual)

    def operacion_eliminar(self):
        print("\n--- 4. Eliminar Catequizado ---")
        
        # Pedir la cédula
        cedula = input("Ingrese la cédula a eliminar: ")
        if not cedula.strip():
            print("[ERROR] La cédula no puede estar vacía.")
            return
        
        # Preguntar si está seguro de eliminar
        confirmar = input(f"¿Está seguro que desea eliminar al catequizado con cédula {cedula}? (s/n): ")
        
        # Preguntar confirmación
        if confirmar.lower() == 's':
            # Usar el gestor "herramienta" para eliminar el catequizado
            self.gestor_herramienta.eliminarCatequizado(cedula)
        else:
            print("Operación cancelada.")

    def operacion_listar(self):
        print("\n--- 5. Listado de Catequizados ---")
        # Usar el gestor "herramienta" para listar todos los catequizados
        self.gestor_herramienta.listarCatequizados()