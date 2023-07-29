load('100m.mat');

% Extract ECG signal data from .mat file
ecg = val(1).dat; 

% Sampling frequency of ECG signal
fs = 360;

% Filter parameters
f_low = 0.5;
f_high = 40;
order = 2;

% Design bandpass filter
[b, a] = butter(order, [f_low, f_high]/(fs/2), 'bandpass');

% Filter ECG signal
filtered_ecg = filtfilt(b, a, ecg);

% Take the absolute value of the Hilbert transform of the filtered ECG signal
abs_hilbert = abs(hilbert(filtered_ecg));

% Threshold for detecting R-peaks
threshold = mean(abs_hilbert) + 0.25*std(abs_hilbert);

% Find R-peaks using thresholding
[~, r_locs] = findpeaks(abs_hilbert, 'MinPeakHeight', threshold);

% Plot ECG signal, filtered ECG signal, and detected R-peaks
t = (0:length(ecg)-1)/fs;
figure;
subplot(2,1,1);
plot(t, ecg);
title('ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(2,1,2);
hold on;
plot(t, filtered_ecg);
plot(t(r_locs), filtered_ecg(r_locs), 'rv');
title('Filtered ECG Signal with Detected R-peaks');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Filtered ECG Signal', 'R-peaks');
