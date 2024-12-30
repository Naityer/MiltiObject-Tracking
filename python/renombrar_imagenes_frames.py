import os
import json
import re

# Ruta principal del directorio de las carpetas
base_dir = r"C:\Users\tiand\OneDrive\Escritorio\VA_Object Tracking & Human Pose\python"
pic_test_dir = os.path.join(base_dir, "pic_test")  # Solo trabajamos con las carpetas de pic_test

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

def renombrar_imagenes(carpeta_destino, inicio):
    """Renombra las imágenes en la carpeta destino para continuar la numeración."""
    archivos = os.listdir(carpeta_destino)
    num = inicio
    imagenes_renombradas = 0  # Contador para asegurarnos de que todas las imágenes se renombren correctamente

    for archivo in archivos:
        extension = archivo.split('.')[-1].lower()
        if extension in ['jpg', 'png', 'jpeg']:
            # Si la imagen ya tiene el prefijo "frame" y la numeración correcta, no la renombramos
            if archivo.startswith("frame"):
                match = re.match(r"frame_(\d+)\.", archivo)
                if match:
                    numero_actual = int(match.group(1))
                    if numero_actual >= num:
                        num = numero_actual + 1  # Si la numeración es correcta, seguimos desde el siguiente número
                    else:
                        # Si la numeración está desordenada, la renombramos correctamente
                        nuevo_nombre = f"frame_{num}.{extension}"
                        ruta_destino = os.path.join(carpeta_destino, nuevo_nombre)
                        os.rename(os.path.join(carpeta_destino, archivo), ruta_destino)
                        print(f"{archivo} -> {nuevo_nombre}")
                        num += 1
                        imagenes_renombradas += 1
                else:
                    # Si no tiene el formato adecuado, renombramos la imagen
                    nuevo_nombre = f"frame_{num}.{extension}"
                    ruta_destino = os.path.join(carpeta_destino, nuevo_nombre)
                    os.rename(os.path.join(carpeta_destino, archivo), ruta_destino)
                    print(f"{archivo} -> {nuevo_nombre}")
                    num += 1
                    imagenes_renombradas += 1
            else:
                # Si no tiene el prefijo "frame", renombramos la imagen
                nuevo_nombre = f"frame_{num}.{extension}"
                ruta_destino = os.path.join(carpeta_destino, nuevo_nombre)
                os.rename(os.path.join(carpeta_destino, archivo), ruta_destino)
                print(f"{archivo} -> {nuevo_nombre}")
                num += 1
                imagenes_renombradas += 1

    return num, imagenes_renombradas

def main():
    # Cargar estado actual
    estado = cargar_estado(estado_path)

    for carpeta_contar, carpeta_renombrar in carpetas_categorias.items():
        ruta_destino = os.path.join(pic_test_dir, carpeta_renombrar)  # Solo trabajar en pic_test_dir

        # Inicializar categoría en el estado si no existe
        if carpeta_contar not in estado:
            estado[carpeta_contar] = {'frames_guardados': 0, 'imagenes_renombradas': 0}
        
        # Obtener el número inicial de frames de la carpeta desde el JSON
        inicio = estado[carpeta_contar]['frames_guardados']

        # Renombrar imágenes en la carpeta de destino
        nuevo_total, imagenes_renombradas = renombrar_imagenes(ruta_destino, inicio)

        # Asegurarse de que la cantidad de imágenes renombradas sea la misma que la cantidad de imágenes en la carpeta
        archivos_restantes = [f for f in os.listdir(ruta_destino) if f.endswith(('.jpg', '.png', '.jpeg'))]
        if len(archivos_restantes) != imagenes_renombradas:
            print(f"Advertencia: El número de imágenes renombradas ({imagenes_renombradas}) no coincide con el número de imágenes originales ({len(archivos_restantes)}) en la carpeta {ruta_destino}.")
        else:
            print(f"Se han renombrado correctamente {imagenes_renombradas} imágenes en {ruta_destino}.")
        
        # Actualizar el estado con el nuevo total de imágenes renombradas
        estado[carpeta_contar]['frames_guardados'] = nuevo_total
        estado[carpeta_contar]['imagenes_renombradas'] = imagenes_renombradas

    # Guardar estado actualizado
    guardar_estado(estado, estado_path)

if __name__ == "__main__":
    main()
