% MULTI-OBJECT TRACKING AND HUMAN POSE ESTIMATION
% Archivo principal

% Paso 1: Configuración Inicial
import vision.*
import fusion.*

% Crear el detector de personas utilizando YOLOv4
peopleDet = yolov4ObjectDetector('tiny-yolov4-coco'); % Cambiar a 'yolov4-coco' si necesitas mayor precisión

% Crear el detector de puntos clave
keyPtDetector = hrnetObjectKeypointDetector;
keyPtDetector.Threshold = 0.3; % Establecer el umbral

% Leer datos del video
videoFile = "PedestrianTrackingVideo.avi"; % Cambiar si es necesario
reader = VideoReader(videoFile);

% Configurar el rastreador GNN
tracker = trackerGNN(MaxNumSensors=1, MaxNumTracks=10);
tracker.ConfirmationThreshold = [2 5];
tracker.DeletionThreshold = [23 23];
tracker.AssignmentThreshold = 30*[5 inf];

% Inicializar filtro de Kalman para seguimiento de cajas delimitadoras
frameRate = reader.FrameRate;
frameSize = [reader.Width reader.Height];
tracker.FilterInitializationFcn = @(detection)initvisionbboxkf(detection, FrameRate=frameRate, FrameSize=frameSize);

% Configurar parámetros de detección
skipFrame = 2;
detectionThreshold = 0.5;
minDetectionSize = [5 5];

% Inicializar reproductor de video
player = vision.VideoPlayer(Position=[20 400 700 400]);

% Variables para contar cuadros
frameCount = 0;

% Bucle principal para procesamiento de video
while hasFrame(reader)
    frame = readFrame(reader);
    frameCount = frameCount + 1;

    % Paso 1: Detectar personas y predecir cajas delimitadoras
    bboxes = helperDetectObjects(peopleDet, frame, detectionThreshold, frameCount, skipFrame, minDetectionSize);

    % Paso 2: Rastrear personas entre cuadros
    [trackBboxes, labels] = helperTrackBoundingBoxes(tracker, reader.FrameRate, frameCount, bboxes);

    % Paso 3: Detectar puntos clave y estimar posturas
    [keypoints, validity] = helperDetectKeypointsUsingHRNet(frame, keyPtDetector, trackBboxes);

    % Paso 4: Visualizar resultados
    frame = helperDisplayResults(frame, keyPtDetector.KeypointConnections, keypoints, validity, trackBboxes, labels, frameCount);

    % Mostrar video
    player(frame);
end

% Cerrar el reproductor de video
release(player);
