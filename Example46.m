% Load ECG signal and annotation data
load('100m.mat');
fid = fopen('100.atr');
atrData = textscan(fid, '%d %d %s');
fclose(fid);

% Threshold method parameters
th = 0.5; % Threshold value
n = 30; % Window size

% Initialize variables
annotations = zeros(size(val));
true_positives = 0;
false_positives = 0;
true_negatives = 0;
false_negatives = 0;

% Apply threshold method
for i = n+1:length(val)-n
    % Calculate threshold value
    threshold = th*mean(val(i-n:i+n));
    
    % Detect R-peak
    if val(i) > threshold
        annotations(i) = 1;
    end
end

% Calculate performance metrics
for i = 1:length(annotations)
    if annotations(i) == 1 && val(i) == 1
        true_positives = true_positives + 1;
    elseif annotations(i) == 1 && val(i) == 0
        false_positives = false_positives + 1;
    elseif annotations(i) == 0 && val(i) == 0
        true_negatives = true_negatives + 1;
    elseif annotations(i) == 0 && val(i) == 1
        false_negatives = false_negatives + 1;
    end
end

sensitivity = true_positives / (true_positives + false_negatives);
specificity = true_negatives / (true_negatives + false_positives);
accuracy = (true_positives + true_negatives) / length(annotations);

disp(['Sensitivity: ' num2str(sensitivity)]);
disp(['Specificity: ' num2str(specificity)]);
disp(['Accuracy: ' num2str(accuracy)]);
