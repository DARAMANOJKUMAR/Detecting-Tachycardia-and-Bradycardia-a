% Load ECG signal and annotation data
load('100m.mat');
fid = fopen('100.atr');
atrData = textscan(fid, '%d %d %s');
fclose(fid);

% Extract data from the loaded files
ecg = val;
fs = 360;
ann = zeros(length(ecg), 1);
for i = 1:length(atrData{1})
    ann(atrData{1}(i)) = 1;
end

% Filter the ECG signal using a bandpass filter
[b, a] = butter(1, [5 15]/(fs/2), 'bandpass');
ecgFilt = filtfilt(b, a, ecg);

% Compute the first derivative of the filtered ECG signal
ecgDiff = diff(ecgFilt);

% Compute the squared signal
ecgSquared = ecgDiff.^2;

% Compute the moving average of the squared signal
winLength = round(0.15*fs);
b = ones(1, winLength)/winLength;
ecgAvg = conv(ecgSquared, b, 'same');

% Compute the moving average of the moving average
winLength = round(0.6*fs);
b = ones(1, winLength)/winLength;
ecgAvg2 = conv(ecgAvg, b, 'same');

% Find the R-peaks using the Pan-Tompkins algorithm
qrsThresh = 0.5*max(ecgAvg2);
rrAvg1 = 0;
rrAvg2 = 0;
qrsDetect = zeros(length(ecg), 1);
for i = 2:length(ecg)-1
    if ecgAvg2(i) > qrsThresh && ecgAvg2(i) > ecgAvg2(i-1) && ecgAvg2(i) > ecgAvg2(i+1)
        qrsDetect(i) = 1;
        if rrAvg1 == 0
            rrAvg1 = i-1;
        elseif rrAvg2 == 0
            rrAvg2 = i-1;
            rrAvg = round((rrAvg1+rrAvg2)/2);
            qrsThresh = 0.5*qrsThresh + 0.5*max(ecgAvg2(rrAvg-5:rrAvg+5));
            rrAvg1 = rrAvg2;
            rrAvg2 = 0;
        else
            rrAvg2 = 0;
        end
    end
end

% Compute the accuracy
tp = sum(qrsDetect == 1 & ann == 1);
tn = sum(qrsDetect == 0 & ann == 0);
fp = sum(qrsDetect == 1 & ann == 0);
fn = sum(qrsDetect == 0 & ann == 1);
sensitivity = tp/(tp+fn);
specificity = tn/(tn+fp);
accuracy = (tp+tn)/(tp+tn+fp+fn);
fprintf('Sensitivity: %.2f\n', sensitivity);
fprintf('Specificity: %.2f\n', specificity);
fprintf('Accuracy: %.2f\n', accuracy);
