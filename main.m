% MULTI-OBJECT TRACKING AND HUMAN POSE ESTIMATION
% Archivo principal

% Paso 1: Configuración Inicial
import vision.*;
import fusion.*;

% Crear el detector de personas utilizando YOLOv4
peopleDet = yolov4ObjectDetector('tiny-yolov4-coco'); % Cambiar a 'yolov4-coco' si necesitas mayor precisión

% Crear el detector de puntos clave
keyPtDetector = hrnetObjectKeypointDetector;
keyPtDetector.Threshold = 0.3; % Establecer el umbral

% Leer datos del video
videoFile = 'videos/Car_Bike_People.mp4';
reader = VideoReader(videoFile);

% Configurar el rastreador GNN
tracker = trackerGNN(MaxNumSensors=1, MaxNumTracks=10);
tracker.ConfirmationThreshold = [2 5];
tracker.DeletionThreshold = [23 23];
tracker.AssignmentThreshold = 30 * [5 inf];

% Inicializar filtro de Kalman para seguimiento de cajas delimitadoras
frameRate = reader.FrameRate;  % Obtener la tasa de fotogramas del video
frameSize = [reader.Width reader.Height];
tracker.FilterInitializationFcn = @(detection) initvisionbboxkf(detection, FrameRate=frameRate, FrameSize=frameSize);

% Configurar parámetros de detección
skipFrame = 2;  % Procesar todos los cuadros, si no deseas saltarte ningún cuadro
detectionThreshold = 0.5;
minDetectionSize = [5 5];

% Inicializar reproductor de video
player = vision.VideoPlayer(Position=[20 400 700 400]);

% Abrir archivo para almacenar los resultados
logFile = fopen('execution_log.csv', 'w');
fprintf(logFile, 'Frame,NumDetections,NumTracks,NumKeypoints\n'); % Cabecera del archivo CSV

% Variables para contar cuadros
frameCount = 0;

% Bucle principal para procesamiento de video
while hasFrame(reader)
    frame = readFrame(reader);
    frameCount = frameCount + 1;

    try
        % Paso 1: Detectar personas y predecir cajas delimitadoras
        bboxes = helperDetectObjects(peopleDet, frame, detectionThreshold, frameCount, skipFrame, minDetectionSize);
        disp(['Bboxes size: ', num2str(size(bboxes))]);  % Mostrar el tamaño de las bboxes

        if ~isempty(bboxes)  % Solo proceder si hay cajas delimitadoras
            try
                % Paso 2: Rastrear personas entre cuadros
                [trackBboxes, labels] = helperTrackBoundingBoxes(tracker, reader.FrameRate, frameCount, bboxes);
                disp(['Track Bboxes size: ', num2str(size(trackBboxes))]);  % Mostrar el tamaño de trackBboxes

                % Paso 3: Detectar puntos clave y estimar posturas
                if ~isempty(trackBboxes)  % Solo proceder si hay cajas de seguimiento
                    [keypoints, validity] = helperDetectKeypointsUsingHRNet(frame, keyPtDetector, trackBboxes);
                    disp(['Keypoints size: ', num2str(size(keypoints))]);  % Mostrar el tamaño de los keypoints
                else
                    keypoints = [];
                    validity = [];
                end

                % Paso 4: Guardar resultados en el archivo
                % Guardamos el número de detecciones, el número de rastreos y el número de puntos clave
                numDetections = size(bboxes, 1);
                numTracks = size(trackBboxes, 1);
                numKeypoints = size(keypoints, 1);
                fprintf(logFile, '%d,%d,%d,%d\n', frameCount, numDetections, numTracks, numKeypoints);  % Escribir en el archivo CSV

            catch bboxError
                % Utilizar el identificador de la excepción con el especificador de formato
                warning('MultiObjectTracking:TrackingError', '%s', bboxError.message);
                trackBboxes = [];
                labels = [];
                keypoints = [];
                validity = [];
            end


            try
                % Paso 5: Visualizar resultados
                frame = helperDisplayResults(frame, keyPtDetector.KeypointConnections, keypoints, validity, trackBboxes, labels, frameCount);
            catch displayError
                % Utilizar un identificador y un especificador de formato
                warning('MultiObjectTracking:DisplayError', '%s', displayError.message);
            end


            % Mostrar video
            player(frame);

        else
            disp('No detections found in this frame.');
        end

    catch detectError
        % Utilizar un identificador y un especificador de formato
        warning('MultiObjectTracking:DetectionError', '%s', detectError.message);
        bboxes = [];
        trackBboxes = [];
        labels = [];
        keypoints = [];
        validity = [];
    end


    % Pausa entre cuadros para que se reproduzca a la misma velocidad que el video original
    pause(1 / frameRate);  % Pausa para igualar la tasa de cuadros del video
end

% Cerrar el archivo de registro
fclose(logFile);

% Cerrar el reproductor de video
release(player);
