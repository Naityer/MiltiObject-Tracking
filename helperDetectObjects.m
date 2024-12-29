function box = helperDetectObjects(detector, frame, detectionThreshold, frameCount, skipFrame, minDetectionSize)
    box = [];
    if mod(frameCount, skipFrame) == 0
        % Detectar utilizando el modelo YOLOv4
        [bboxes, scores] = detect(detector, frame, 'Threshold', detectionThreshold);
        
        % Verificar las detecciones
        disp('Bboxes:');
        disp(bboxes);  % Mostrar las cajas detectadas
        disp('Scores:');
        disp(scores);  % Mostrar las puntuaciones

        % Obtener las dimensiones de la imagen
        [frameHeight, frameWidth, ~] = size(frame);
        
        % Convertir minDetectionSize a valores normalizados
        normalizedMinWidth = minDetectionSize(1) / frameWidth;
        normalizedMinHeight = minDetectionSize(2) / frameHeight;

        % Validar las detecciones, asegurando que las cajas sean mayores que el tamaño mínimo
        valid = scores > detectionThreshold & ...
                (bboxes(:, 3) >= normalizedMinWidth) & ...
                (bboxes(:, 4) >= normalizedMinHeight);
        
        box = bboxes(valid, :);
        
        disp(['Valid detections: ', num2str(sum(valid))]);  % Verificar la cantidad de detecciones válidas
    end
end
