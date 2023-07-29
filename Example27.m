% Load ECG signal data
load('100m.mat');

% Apply a bandpass filter to the ECG signal
fs = 360; % sampling frequency
fc1 = 5; % lower cutoff frequency
fc2 = 15; % upper cutoff frequency
[b, a] = butter(1, [fc1, fc2]/(fs/2), 'bandpass');
filtered_signal = filtfilt(b, a, val);

% Apply the Pan-Tompkins algorithm to detect QRS complexes
[~,locs_Rwave] = findpeaks(filtered_signal,'MinPeakHeight',0.6*max(filtered_signal),'MinPeakDistance',0.35*fs);
RR=diff(locs_Rwave)/fs*1000; % RR intervals in ms
BPM=60./(RR/1000); % Heart rate in BPM

% Plot the ECG signal with detected QRS complexes
figure;
plot(val);
hold on;
plot(locs_Rwave,val(locs_Rwave),'ro');
title('ECG Signal with QRS Complexes Detected');
xlabel('Sample number');
ylabel('Signal value');

% Display the heart rate
disp(['Heart rate: ' num2str(mean(BPM)) ' BPM']);
