import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import VGG16

# Preparar generadores de datos (data augmentation)
train_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=40,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True,
    fill_mode='nearest',
    validation_split=0.2  # Para dividir los datos en entrenamiento y validación
)

train_generator = train_datagen.flow_from_directory(
    'datasets',  # Ruta de tus datos
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical',  # Como hay 3 clases (de pie, sentado, tumbado)
    subset='training'  # Para usar el 80% de los datos para entrenamiento
)

validation_generator = train_datagen.flow_from_directory(
    'datasets',
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical',
    subset='validation'  # Para usar el 20% de los datos para validación
)

# Cargar el modelo VGG16 preentrenado (sin las capas superiores)
base_model = VGG16(weights='imagenet', include_top=False, input_shape=(224, 224, 3))

# Congelar todas las capas del modelo base
base_model.trainable = False

# Crear el modelo con la parte base preentrenada y nuevas capas personalizadas
model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dense(256, activation='relu'),  # Añadir una capa densa intermedia
    layers.Dense(3, activation='softmax')  # Tres clases de salida
])

# Compilar el modelo
optimizer = tf.keras.optimizers.Adam(learning_rate=1e-4)  # Ajustar la tasa de aprendizaje
model.compile(optimizer=optimizer, loss='categorical_crossentropy', metrics=['accuracy'])

# Usar EarlyStopping para evitar el sobreajuste
early_stopping = tf.keras.callbacks.EarlyStopping(
    monitor='val_loss', patience=5, restore_best_weights=True
)

# Entrenar el modelo
history = model.fit(
    train_generator, 
    epochs=50, 
    validation_data=validation_generator, 
    callbacks=[early_stopping]
)

# Guardar el modelo entrenado
model.save('modelo_posicionesv2.1.h5')
model.save('my_model.keras')

