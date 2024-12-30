import os
import json

# Ruta principal del directorio de las carpetas
base_dir = r"C:\Users\tiand\OneDrive\Escritorio\VA_Object Tracking & Human Pose\python"
datasets_dir = os.path.join(base_dir, "datasets")
pic_test_dir = os.path.join(base_dir, "pic_test")

# Archivo JSON para el estado
estado_path = os.path.join(base_dir, 'estado_procesamiento.json')

# Carpetas para renombrar imágenes
carpetas_categorias = {
    "frames_de_pie": "dePie_pic",
    "frames_sentado": "sentado_pic",
    "frames_tumbado": "tumbado_pic"
}

# Leer el estado desde el archivo JSON
def cargar_estado(estado_path):
    if os.path.exists(estado_path):
        with open(estado_path, 'r') as file:
            return json.load(file)
    return {}

# Guardar el estado en el archivo JSON
def guardar_estado(estado, estado_path):
    with open(estado_path, 'w') as file:
        json.dump(estado, file, indent=4)

def renombrar_imagenes(carpeta_origen, carpeta_destino, inicio):
    """Renombra las imágenes en la carpeta de origen para continuar la numeración en la carpeta destino."""
    if not os.path.exists(carpeta_destino):
        print(f"La carpeta destino {carpeta_destino} no existe. Creándola...")
        os.makedirs(carpeta_destino)
    
    archivos = os.listdir(carpeta_origen)
    num = inicio
    imagenes_renombradas = 0  # Contador de imágenes renombradas
    for archivo in archivos:
        extension = archivo.split('.')[-1].lower()
        if extension in ['jpg', 'png', 'jpeg'] and not archivo.startswith("frame_"):
            nuevo_nombre = f"frame_{num}.{extension}"
            ruta_origen = os.path.join(carpeta_origen, archivo)
            ruta_destino = os.path.join(carpeta_destino, nuevo_nombre)
            os.rename(ruta_origen, ruta_destino)
            print(f"{archivo} -> {nuevo_nombre}")
            num += 1
            imagenes_renombradas += 1
    return num, imagenes_renombradas

def main():
    # Cargar estado actual
    estado = cargar_estado(estado_path)

    # Agregar un nuevo campo en el JSON para contar las imágenes renombradas
    if "imagenes_renombradas" not in estado:
        estado["imagenes_renombradas"] = {}

    for carpeta_contar, carpeta_renombrar in carpetas_categorias.items():
        ruta_origen = os.path.join(datasets_dir, carpeta_contar)
        ruta_destino = os.path.join(pic_test_dir, carpeta_renombrar)

        # Inicializar categoría en el estado si no existe
        if carpeta_contar not in estado:
            estado[carpeta_contar] = {'frames_guardados': 0}

        # Obtener el número inicial de frames
        inicio = estado[carpeta_contar]['frames_guardados']

        # Renombrar imágenes en la carpeta de origen
        nuevo_total, imagenes_renombradas = renombrar_imagenes(ruta_origen, ruta_destino, inicio)

        # Actualizar el estado con el nuevo total
        estado[carpeta_contar]['frames_guardados'] = nuevo_total
        estado["imagenes_renombradas"][carpeta_contar] = imagenes_renombradas

    # Guardar estado actualizado
    guardar_estado(estado, estado_path)

if __name__ == "__main__":
    main()
