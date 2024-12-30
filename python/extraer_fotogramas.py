import os
import json
import cv2

# Archivo JSON para almacenar datos de estado
estado_path = 'estado_procesamiento.json'

# Directorio base del proyecto (obtiene el directorio del archivo actual)
base_dir = os.path.dirname(__file__)

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

# Función para extraer fotogramas de un video
def extract_frames(video_path, output_folder, frame_interval=30, saved_frame_count=0):
    # Abrir el video
    cap = cv2.VideoCapture(video_path)
    frame_count = 0

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        # Guardar fotogramas cada "frame_interval" frames
        if frame_count % frame_interval == 0:
            filename = os.path.join(output_folder, f"frame_{saved_frame_count}.jpg")
            cv2.imwrite(filename, frame)
            saved_frame_count += 1

        frame_count += 1

    cap.release()
    return saved_frame_count  # Devuelves el número total de frames guardados

# Función para verificar la cantidad de frames en cada carpeta
def verificar_frames(carpeta, frames_guardados_almacenados):
    """Verifica la cantidad de frames en una carpeta y devuelve el número correcto de frames."""
    archivos = [f for f in os.listdir(carpeta) if f.startswith('frame_') and f.endswith('.jpg')]
    frames_actuales = len(archivos)
    
    if frames_actuales != frames_guardados_almacenados:
        print(f"Advertencia: La cantidad de frames en '{carpeta}' ({frames_actuales}) no coincide con el número almacenado en el JSON ({frames_guardados_almacenados}).")
        # Actualizar el estado si es necesario
        frames_guardados_almacenados = frames_actuales
    
    return frames_guardados_almacenados

# Rutas relativas de las carpetas por categoría
carpetas_categorias = {
    'frames_de_pie': os.path.join(base_dir, "extract_frames/enpie"),
    'frames_sentado': os.path.join(base_dir, "extract_frames/sentado"),
    'frames_tumbado': os.path.join(base_dir, "extract_frames/tumbado")
}

# Directorio de salida base
output_base_dir = os.path.join(base_dir, "datasets")

# Cargar estado actual
estado = cargar_estado(estado_path)

# Procesar cada categoría
for categoria, carpeta in carpetas_categorias.items():
    # Crear la carpeta de la categoría si no existe
    output_folder = os.path.join(output_base_dir, categoria)
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    # Inicializar datos de la categoría en el estado si no existe
    if categoria not in estado:
        estado[categoria] = {'videos_procesados': [], 'frames_guardados': 0}

    saved_frame_count = estado[categoria]['frames_guardados']
    
    # Listar todos los videos en la carpeta
    try:
        videos = [os.path.join(carpeta, f) for f in os.listdir(carpeta) if f.endswith(('.mp4', '.avi', '.mov'))]
    except FileNotFoundError:
        print(f"Carpeta no encontrada: {carpeta}. Asegúrate de que exista.")
        continue

    # Procesar todos los videos en la carpeta
    for video_path in videos:
        # Omitir videos ya procesados
        if video_path in estado[categoria]['videos_procesados']:
            print(f"Video ya procesado: {video_path}")
            continue

        # Extraer fotogramas del video
        saved_frame_count = extract_frames(video_path, output_folder, saved_frame_count=saved_frame_count)
        print(f"Frames extraídos para: {categoria} - {os.path.basename(video_path)}")
        
        # Actualizar estado
        estado[categoria]['videos_procesados'].append(video_path)
        estado[categoria]['frames_guardados'] = saved_frame_count

    # Verificar la cantidad de frames en la carpeta y actualizar el estado si es necesario
    estado[categoria]['frames_guardados'] = verificar_frames(output_folder, estado[categoria]['frames_guardados'])

# Guardar estado actualizado
guardar_estado(estado, estado_path)
