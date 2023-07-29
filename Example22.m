%Heart Rate Calculation Using Hilbert Transform Method
% Load ECG data
load('100m.mat');

% Filter the signal to remove noise and baseline wander
fs = 360; % Sampling frequency
fc = 45; % Cutoff frequency
[b,a] = butter(1,fc/(fs/2),'high');
ecg_data_filtered = filtfilt(b,a,val);

% Detect R-peaks using Hilbert transform method
analytic_signal = hilbert(ecg_data_filtered);
amplitude_envelope = abs(analytic_signal);
mean_amp_env = movmean(amplitude_envelope, fs*2); % moving average of amplitude envelope
std_amp_env = movstd(amplitude_envelope, fs*2); % moving standard deviation of amplitude envelope
threshold = mean_amp_env + 3*std_amp_env; % set threshold for R-peak detection
r_peak_idx = find(amplitude_envelope > threshold);

% Calculate heart rate
rr_interval = diff(r_peak_idx) / fs; % calculate RR intervals in seconds
heart_rate = 60 ./ rr_interval; % calculate heart rate in bpm

% Display heart rate
fprintf('Heart Rate (Hilbert Transform Method): %.2f bpm\n', mean(heart_rate));
