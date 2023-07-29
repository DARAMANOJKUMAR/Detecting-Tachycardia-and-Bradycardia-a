
%% Pan-Tompkins algorithm
%The Pan-Tompkins algorithm is a commonly used algorithm for detecting R-peaks in an ECG signal.
%It involves several steps including bandpass filtering, differentiation, squaring, and integration.
%Once the R-peaks have been detected, the heart rate can be calculated and classified as normal, 
%bradycardia, or tachycardia based on certain thresholds.
% Load ECG signal
load('114m.mat');
fs = 360; % sampling rate

% Apply bandpass filter
[b, a] = butter(2, [5 15]/(fs/2), 'bandpass');
ecg_filt = filtfilt(b, a, val);

% Differentiate signal
diff_ecg = diff(ecg_filt);

% Square signal
squared_ecg = diff_ecg.^2;

% Moving window integration
window_size = round(0.15*fs);
mov_avg = conv(squared_ecg, ones(window_size, 1)/window_size, 'same');

% Find R-peaks using peak detection
[~, R_locs] = findpeaks(mov_avg, 'MinPeakHeight', max(mov_avg)/2, 'MinPeakDistance', round(0.5*fs));

% Calculate heart rate and classify as normal, bradycardia, or tachycardia
RR_intervals = diff(R_locs)/fs*1000; % convert to milliseconds
heart_rate = 60./(RR_intervals/1000); % calculate heart rate in beats per minute
mean_heart_rate = mean(heart_rate); % mean heart rate
if mean_heart_rate >= 60 && mean_heart_rate <= 100
    fprintf('Heart rate is normal.\n');
elseif mean_heart_rate < 60
    fprintf('Heart rate indicates bradycardia.\n');
else
    fprintf('Heart rate indicates tachycardia.\n');
end

% Display results
fprintf('Mean heart rate: %.2f bpm\n', mean_heart_rate);

% Plot signals
t = (0:length(val)-1)/fs;
figure
subplot(3,1,1);
plot(t, val);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');

subplot(3,1,2);
plot(t(1:end-1), diff_ecg);
title('Differentiated ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV/s)');

subplot(3,1,3);
plot(t(1:end-1), squared_ecg);
title('Squared ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV^2)');

% Plot ECG signal with R-peaks
figure;
t = (0:length(val)-1)/fs;
plot(t, val);
hold on;
plot(R_locs/fs, val(R_locs), 'ro', 'MarkerSize', 10);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('ECG Signal with R-Peak Detection');
legend('ECG Signal', 'R-Peaks');

