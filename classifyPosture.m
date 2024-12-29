function posture = classifyPosture(keypoints, validity)
    % Clasificar postura basada en los keypoints detectados
    
    % Verificar que los puntos clave son válidos
    if isempty(keypoints) || isempty(validity)
        posture = 'Unknown';
        return;
    end
    
    % Definir los índices de los puntos clave que nos interesan
    % Suponiendo que las siguientes posiciones están disponibles:
    % 1: cuello, 2: hombro izquierdo, 3: codo izquierdo, 4: muñeca izquierda, ...
    % 5: hombro derecho, 6: codo derecho, 7: muñeca derecha, ...
    % 11: cadera izquierda, 12: rodilla izquierda, 13: tobillo izquierdo, ...
    % 14: cadera derecha, 15: rodilla derecha, 16: tobillo derecho

    if validity(1) == 1 % Si el cuello es válido
        % Obtener las coordenadas de los puntos clave
        neck = keypoints(1, :);  % Coordenada (x, y) del cuello
        leftShoulder = keypoints(2, :); % Hombro izquierdo
        rightShoulder = keypoints(5, :); % Hombro derecho
        leftKnee = keypoints(12, :); % Rodilla izquierda
        rightKnee = keypoints(15, :); % Rodilla derecha
        leftAnkle = keypoints(13, :); % Tobillo izquierdo
        rightAnkle = keypoints(16, :); % Tobillo derecho
        leftWrist = keypoints(4, :); % Muñeca izquierda
        rightWrist = keypoints(7, :); % Muñeca derecha

        % Calcular distancias y ángulos relevantes
        % Distancia entre los tobillos y las rodillas para evaluar si está de pie o sentado
        kneeDist = norm(leftKnee - rightKnee);
        ankleDist = norm(leftAnkle - rightAnkle);
        
        % Clasificar la postura
        if ankleDist < kneeDist  % Si la distancia entre los tobillos es menor que entre las rodillas, está de pie
            posture = 'Standing';
        elseif kneeDist > ankleDist && neck(2) > leftKnee(2) && neck(2) > rightKnee(2)  % Si las rodillas están flexionadas y la cabeza está más arriba que las rodillas
            posture = 'Sitting';
        elseif leftKnee(2) > leftAnkle(2) && rightKnee(2) > rightAnkle(2) % Si las rodillas están más altas que los tobillos, probablemente está tumbado
            posture = 'Lying Down';
        elseif abs(leftWrist(2) - rightWrist(2)) > 0.2 * (leftShoulder(2) - neck(2))  % Si las muñecas están muy alejadas de la cabeza
            posture = 'Hand Raised';
        else
            posture = 'Unknown'; % No se puede determinar
        end
    else
        posture = 'Unknown';
    end
end
