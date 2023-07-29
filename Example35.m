
%% Threshold-based method
%The threshold-based method involves setting a threshold on the ECG signal to detect R-peaks. 
%Once the R-peaks have been detected, the heart rate can be calculated and classified as normal,
%bradycardia, or tachycardia based on certain thresholds.
% Load ECG signal
load('114m.mat');
fs = 360; % sampling rate

% Set threshold for peak detection
threshold = 0.6;

% Detect R-peaks using threshold-based method
peaks = val > threshold*max(val);
R_locs = find(diff(peaks) == 1);

% Calculate heart rate and classify as normal, bradycardia, or tachycardia
RR_intervals = diff(R_locs)/fs*1000; % convert to milliseconds
heart_rate = 60./(RR_intervals/1000); % calculate heart rate in beats per minute
mean_heart_rate = mean(heart_rate); % mean heart rate
if mean_heart_rate >= 60 && mean_heart_rate <= 100
    fprintf('Heart rate is normal.\n');
elseif mean_heart_rate < 60
    fprintf('Heart rate indicates bradycardia.\n');
else
    fprintf('Heart rate indicates tachycardia.\n');
end

% Plot ECG signal with detected R-peaks
t = (0:length(val)-1)/fs; % time vector
figure;
plot(t, val, 'b');
hold on;
plot(t(R_locs), val(R_locs), 'r*', 'MarkerSize', 10);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('ECG Signal with Detected R-Peaks');

% Display results
fprintf('Mean heart rate: %.2f bpm\n', mean_heart_rate);
