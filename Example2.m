% Load ECG data
load('ecgdemodata2.mat');
fs = 1000; % Sampling frequency

% Perform continuous wavelet transform
[s, f, t] = cwt(ecg, 'amor', fs);

% Extract features
cfs = abs(s).^2;
cfs = normalize(cfs, 'range');
psd = sum(cfs, 1);
pwr = sum(cfs(:,f>=0.5 & f<=30), 2);

% Identify arrhythmias
arrhythmia = false(1,length(pwr));
arrhythmia(pwr < 0.2) = true; % Bradycardia
arrhythmia(pwr > 0.8) = true; % Tachycardia
arrhythmia(diff(t(1:length(t)-1))./fs > 0.16) = true; % Premature Ventricular Contractions
