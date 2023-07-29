% Load ECG signal
load('100m.mat');
fs = 360; % Sampling rate (Hz)
t = (0:length(val)-1)/fs; % Time vector

% Apply low-pass filter
fc = 40; % Cut-off frequency (Hz)
[b, a] = butter(2, fc/(fs/2), 'low'); % Design 2nd-order Butterworth filter
ecg_filtered = filtfilt(b, a, val); % Apply filter using zero-phase filtering

% Plot results
figure;
plot(t, val);
title('Original ECG signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

