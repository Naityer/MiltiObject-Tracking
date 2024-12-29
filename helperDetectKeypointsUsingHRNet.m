function [keypoints, validity] = helperDetectKeypointsUsingHRNet(frame, keyPtDet, boxes)
    if ~isempty(boxes)
        if ~any(boxes <= 0, "all")
            [keypoints, ~, validity] = detect(keyPtDet, frame, boxes);
        else
            keypoints = [];
            validity = [];
        end
    else
        keypoints = [];
        validity = [];
    end
end
