
%Heart Arrythmia Detection Using Hilbert Transform Method
% Load ECG data
load('100m.mat');

% Filter the signal to remove noise and baseline wander
fs = 360; % Sampling frequency
fc = 45; % Cutoff frequency
[b,a] = butter(1,fc/(fs/2),'high');
ecg_data_filtered = filtfilt(b,a,val);

% Detect arrhythmia using Hilbert transform method
analytic_signal = hilbert(ecg_data_filtered);
amplitude_envelope = abs(analytic_signal);
mean_amp_env = movmean(amplitude_envelope, fs*2); % moving average of amplitude envelope
std_amp_env = movstd(amplitude_envelope, fs*2); % moving standard deviation of amplitude envelope
threshold = mean_amp_env + 3*std_amp_env; % set threshold for arrhythmia detection
arrhythmia_detected = amplitude_envelope > threshold;

% Plot results
figure;
t = (1:length(val))/fs;
plot(t, val, 'b');
hold on;
plot(t, amplitude_envelope, 'r');
plot(t, threshold, 'k--');
xlabel('Time (s)');
ylabel('Amplitude');
legend('ECG Signal', 'Amplitude Envelope', 'Threshold');
title('Arrhythmia Detection Using Hilbert Transform Method');

% Display arrhythmia detection for every sample
for i = 1:size(arrhythmia_detected,2)
    fprintf('Sample %d: Arrhythmia Detected = %d\n', i, any(arrhythmia_detected(:,i)));
end
