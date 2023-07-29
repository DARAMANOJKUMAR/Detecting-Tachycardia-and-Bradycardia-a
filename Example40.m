%% Freqeuncy Domain Analysis
% Load MIT Arrhythmia Database
load('114m.mat');
Fs = 360; % Sampling frequency

% Select a single ECG signal
ecg = val(1,:) - mean(val(1,:));

% Design a 4th-order lowpass Butterworth filter with a cutoff frequency of 30 Hz
[b,a] = butter(4, 30/(Fs/2), 'low');

% Filter the ECG signal
ecg_filtered = filtfilt(b,a,ecg);

% Compute the power spectral density (PSD) of the ECG signal
[psd,f] = pwelch(ecg_filtered,[],[],[],Fs);

% Compute the total power (TP) and high-frequency power (HF) of the PSD
TP = trapz(f,psd);
HF = trapz(f(f>=0.15),psd(f>=0.15));

% Compute the normalized HF power (HFnu) and LF/HF ratio
HFnu = HF/TP;
LFHF = trapz(f(f>=0.04 & f<=0.15),psd(f>=0.04 & f<=0.15)) / HF;

% Define thresholds for bradycardia and tachycardia detection based on HFnu and LF/HF ratio
if (HFnu < 0.15 && LFHF < 0.5)
    fprintf('Bradycardia detected\n');
elseif (HFnu > 0.4 && LFHF > 1.5)
    fprintf('Tachycardia detected\n');
else
    fprintf('Normal heart rate detected\n');
end

% Plot the PSD
plot(f,psd);
xlabel('Frequency (Hz)');
ylabel('Power spectral density');
