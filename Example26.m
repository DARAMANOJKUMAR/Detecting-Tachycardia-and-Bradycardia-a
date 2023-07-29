% Load ECG signal data
load('100m.mat');

% Define wavelet transform parameters
wavelet_type = 'db6'; % type of wavelet
level = 5; % decomposition level

% Perform wavelet decomposition of the ECG signal
[c, l] = wavedec(val, level, wavelet_type);

% Reconstruct the ECG signal using the approximation coefficients
% from the highest wavelet decomposition level
a = wrcoef('a', c, l, wavelet_type, level);

% Calculate the difference between the original and reconstructed signal
difference_signal = val - a;

% Find the peaks in the difference signal that exceed a threshold
threshold = 0.1 * max(difference_signal);
[peaks, locations] = findpeaks(difference_signal, 'MinPeakHeight', threshold);

% Plot the ECG signal and the difference signal with peaks
figure;
subplot(2,1,1);
plot(val);
title('ECG Signal');
xlabel('Sample number');
ylabel('Signal value');
subplot(2,1,2);
plot(difference_signal);
title('Difference Signal with Peaks');
xlabel('Sample number');
ylabel('Signal value');
hold on;
plot(locations, peaks, 'ro');

% Classify the arrhythmia based on the location of the detected peaks
if any(locations < 100) || any(locations > length(ecg_signal) - 100)
    disp('Arrhythmia detected: premature ventricular contraction (PVC)');
elseif any(locations < 200) || any(locations > length(ecg_signal) - 200)
    disp('Arrhythmia detected: premature atrial contraction (PAC)');
else
    disp('No arrhythmia detected');
end
