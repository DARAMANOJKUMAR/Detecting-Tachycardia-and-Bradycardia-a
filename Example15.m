% Load ECG signal from .mat file
load('100m.mat');
ecg = val(:, 1); % Extract first column of ECG signal data from .mat file

% Set filter parameters
fs = 360; % Sampling frequency
fc_low = 5; % Low cutoff frequency for bandpass filter
fc_high = 15; % High cutoff frequency for bandpass filter
order = 2; % Filter order

% Design bandpass filter
[b, a] = butter(order, [fc_low/(fs/2) fc_high/(fs/2)], 'bandpass');

% Filter ECG signal
filtered_ecg = filtfilt(b, a, ecg);

% Zero-pad ECG signal to avoid edge effects during peak detection
pad_length = length(ecg) - length(filtered_ecg);
padded_ecg = [filtered_ecg; zeros(pad_length, 1)];

% Detect R-peaks using the Pan-Tompkins algorithm
threshold = 0.5; % Set threshold for peak detection
[peaks, locations] = pan_tompkins(padded_ecg, fs, threshold);

% Calculate heart rate from R-R intervals
RR_intervals = diff(locations) / fs; % Calculate time between R-peaks in seconds
heart_rate = 60./RR_intervals; % Calculate heart rate in bpm

% Plot results
figure;
subplot(3,1,1);
plot(ecg);
title('Original ECG Signal');
xlabel('Samples');
ylabel('Amplitude');

subplot(3,1,2);
plot(filtered_ecg);
title('Filtered ECG Signal');
xlabel('Samples');
ylabel('Amplitude');

subplot(3,1,3);
plot(padded_ecg);
hold on;
plot(locations, peaks, 'r*', 'MarkerSize', 10);
title('R-Peak Detection');
xlabel('Samples');
ylabel('Amplitude');
legend('ECG Signal', 'R-Peaks');
