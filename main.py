# Importa la clase del archivo 'app.py'
from Catequizado.operacionesCatequizado import OperacionesCatequizado

if __name__ == "__main__":
    # 1. Crea el objeto "Volante"
    app = OperacionesCatequizado()
    # 2. Arranca el menú
    app.iniciar_operaciones()