function posture = classifyPosture(keypoints, validity)
    % Clasificar postura basada en los keypoints detectados
    
    % Verificar que los puntos clave son válidos
    if isempty(keypoints) || isempty(validity)
        posture = 'Unknown';
        return;
    end
    
    % Definir los índices de los puntos clave que nos interesan
    % Puntos clave según la descripción:
    % 1: cabeza (cuello), 6: hombro izquierdo, 7: hombro derecho, 
    % 12: cadera izquierda, 13: cadera derecha, 14: rodilla izquierda, 
    % 15: rodilla derecha, 16: tobillo izquierdo, 17: tobillo derecho
    
    if validity(1) == 1 % Si el cuello es válido
        % Obtener las coordenadas de los puntos clave
        neck = keypoints(1, :);  % Coordenada (x, y) del cuello
        leftShoulder = keypoints(6, :); % Hombro izquierdo
        rightShoulder = keypoints(7, :); % Hombro derecho
        leftHip = keypoints(12, :); % Cadera izquierda
        rightHip = keypoints(13, :); % Cadera derecha
        leftKnee = keypoints(14, :); % Rodilla izquierda
        rightKnee = keypoints(15, :); % Rodilla derecha
        leftAnkle = keypoints(16, :); % Tobillo izquierdo
        rightAnkle = keypoints(17, :); % Tobillo derecho
        
        % Calcular distancias relevantes para clasificar las posturas
        kneeDist = norm(leftKnee - rightKnee); % Distancia entre las rodillas
        ankleDist = norm(leftAnkle - rightAnkle); % Distancia entre los tobillos
        hipDist = norm(leftHip - rightHip); % Distancia entre las caderas
        shoulderDist = norm(leftShoulder - rightShoulder); % Distancia entre los hombros
        
        % Clasificación de la postura basada en las distancias y la altura
        % De pie (Standing)
        % Mejora para considerar la posición vertical de la cabeza y el alineamiento de hombros y caderas
        if ankleDist > kneeDist && abs(leftKnee(2) - rightKnee(2)) < 60 && ...
           neck(2) > max(leftKnee(2), rightKnee(2)) && hipDist > shoulderDist && ...
           abs(leftHip(2) - rightHip(2)) < 50 && neck(2) < leftShoulder(2) && neck(2) < rightShoulder(2)
            posture = 'Standing';  % Los tobillos más separados que las rodillas, cabeza sobre las rodillas, alineación de hombros y caderas

        % Sentado (Sitting)
        elseif kneeDist > ankleDist && abs(leftKnee(2) - rightKnee(2)) < 60 && ...
               neck(2) > max(leftKnee(2), rightKnee(2)) && neck(2) > leftKnee(2) && neck(2) > rightKnee(2) && hipDist < shoulderDist
            posture = 'Sitting';  % Rodillas más separadas, tobillos más cercanos, y caderas a la altura de los hombros

        % Sentado de lado (Sitting sideways)
        % La persona sentada de lado tendrá rodillas y tobillos alineados horizontalmente
        elseif kneeDist < ankleDist && abs(leftKnee(1) - rightKnee(1)) < 60 && ...
               abs(leftKnee(2) - rightKnee(2)) < 50 && hipDist < shoulderDist
            posture = 'Sitting';  % Alineación horizontal de las rodillas y tobillos con la cabeza a la altura de las rodillas

        % Tumbado (Lying Down)
        elseif leftKnee(2) > leftAnkle(2) && rightKnee(2) > rightAnkle(2) % Rodillas por encima de los tobillos
            posture = 'Lying Down';  

        % Se puede agregar más clasificación si es necesario
        else
            posture = 'Unknown'; % No se puede determinar
        end
    else
        posture = 'Unknown'; % Si no se detecta el cuello
    end
end
