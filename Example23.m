% Load ECG signal data
load('100m.mat');

% Apply a bandpass filter to the ECG signal
fs = 360; % sampling frequency
fc1 = 5; % lower cutoff frequency
fc2 = 15; % upper cutoff frequency
[b, a] = butter(1, [fc1, fc2]/(fs/2), 'bandpass');
filtered_signal = filtfilt(b, a, val);

% Differentiate the filtered signal
differentiated_signal = diff(filtered_signal);

% Square the differentiated signal
squared_signal = differentiated_signal .^ 2;

% Integrate the squared signal over a moving window
window_size = 0.150 * fs; % window size of 150 ms
smoothed_signal = movmean(squared_signal, window_size);

% Find the peaks in the smoothed signal that exceed a threshold
threshold = 0.6 * max(smoothed_signal);
[peaks, locations] = findpeaks(smoothed_signal, 'MinPeakHeight', threshold);

% Plot the ECG signal, the filtered signal, and the smoothed signal with peaks
figure;
subplot(3,1,1);
plot(val);
title('ECG Signal');
xlabel('Sample number');
ylabel('Signal value');
subplot(3,1,2);
plot(filtered_signal);
title('Filtered Signal');
xlabel('Sample number');
ylabel('Signal value');
subplot(3,1,3);
plot(smoothed_signal);
title('Smoothed Signal with Peaks');
xlabel('Sample number');
ylabel('Signal value');
hold on;
plot(locations, peaks, 'ro');
