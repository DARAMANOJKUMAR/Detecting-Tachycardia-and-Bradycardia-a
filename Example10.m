% Load ECG signal
load('100m.mat'); % replace with your own ECG signal data

% Define sampling frequency
Fs = 360;

% Remove baseline wander using high-pass filter
[b,a] = butter(2, 0.5/(Fs/2), 'high');
ecg_filtered = filtfilt(b, a, val);

% Apply Pan-Tompkins QRS detection algorithm to detect R-peaks
[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg_filtered,Fs,0);

% Calculate R-R intervals (in seconds)
rr_interval = diff(qrs_i_raw)/Fs;

% Calculate heart rate (in bpm)
hr = 60./rr_interval;

% Calculate standard deviation of heart rate
std_hr = std(hr);

% Plot ECG signal and detected R-peaks
t = (0:length(ecg_signal)-1)/Fs;
figure;
plot(t, ecg_signal);
hold on;
plot(t(qrs_i_raw), ecg_signal(qrs_i_raw), 'rv', 'MarkerFaceColor', 'r');
xlabel('Time (s)');
ylabel('Amplitude');
legend('ECG signal', 'Detected R-peaks');

% Compute power spectral density (PSD) of ECG signal
nfft = length(ecg_signal);
ecg_fft = fft(ecg_signal, nfft);
ecg_psd = abs(ecg_fft).^2/nfft/Fs;

% Define frequency vector
f = (0:nfft/2-1)*Fs/nfft;

% Plot PSD of ECG signal
figure;
plot(f, ecg_psd(1:nfft/2));
xlabel('Frequency (Hz)');
ylabel('Power/Frequency (dB/Hz)');
title('PSD of ECG signal');

