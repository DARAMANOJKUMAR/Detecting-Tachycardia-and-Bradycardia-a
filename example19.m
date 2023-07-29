% Parameters
fs = 360;               % Sampling frequency
f_low = 5;              % Lower cutoff frequency for bandpass filter
f_high = 15;            % Higher cutoff frequency for bandpass filter
wavelet_name = 'db4';   % Wavelet type
level = 5;              % Decomposition level
threshold = 0.6;        % Threshold for detecting R-peaks

% Load ECG signal
load('100m.mat');
ecg_signal = val;

% Preprocessing
ecg_signal = ecg_signal - mean(ecg_signal);
ecg_signal = ecg_signal / max(ecg_signal);

% Bandpass filter
[b, a] = butter(2, [f_low, f_high]/(fs/2), 'bandpass');
ecg_filtered = filter(b, a, ecg_signal);

% Wavelet decomposition
[coeffs, L] = wavedec(ecg_filtered, level, wavelet_name);

% Find threshold for detecting R-peaks
sigma = median(abs(coeffs)) / 0.6745;
threshold = 10+sigma * sqrt(2*log(length(ecg_filtered)));

% Find R-peaks
a5 = wrcoef('a', coeffs, L, wavelet_name, level);  % Get approximation coefficients at level 5
[~,locs] = findpeaks(a5, 'MinPeakHeight', threshold);

% Plot results
t = (0:length(ecg_signal)-1)/fs;
figure;
subplot(2,1,1);
plot(t, ecg_signal);
title('Original ECG signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
subplot(2,1,2);
plot(t, a5);
hold on;
plot(t(locs), a5(locs), 'ro');
title('R-peaks detected using wavelet method');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
% Calculate heart rate from R-peaks
t_rr = diff(t(locs)); % Calculate RR intervals
hrv = 60./t_rr; % Calculate heart rate variability (HRV)
heart_rate = mean(hrv); % Calculate average heart rate
fprintf('Heart rate (wavelet method): %.2f bpm\n', heart_rate);

