function box = helperDetectObjects(detector, frame, detectionThreshold, frameCount, skipFrame, minDetectionSize)
    box = [];
    if mod(frameCount, skipFrame) == 0
        % Detectar utilizando el modelo YOLOv4
        [bboxes, scores] = detect(detector, frame, Threshold=detectionThreshold);
        valid = scores > detectionThreshold;
        box = bboxes(valid, :);
    end
end
