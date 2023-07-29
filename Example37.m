% Load ECG signal
load('100m.mat');
fs = 360; % sampling rate

% Apply bandpass filter
[b, a] = butter(2, [5 15]/(fs/2), 'bandpass');
ecg_filt = filtfilt(b, a, val);

% Differentiate signal
diff_ecg = diff(ecg_filt);

% Square signal
squared_ecg = diff_ecg.^2;

% Find R-peaks using peak detection
[~, R_locs] = findpeaks(squared_ecg, 'MinPeakHeight', max(squared_ecg)/2, 'MinPeakDistance', round(0.5*fs));

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

% Plot original, squared, and differentiated signals
t = (0:length(val)-1)/fs;
figure;
subplot(3,1,1);
plot(t, val);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(3,1,2);
plot(t(1:end-1), squared_ecg);
title('Squared ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(3,1,3);
plot(t(1:end-1), diff_ecg);
title('Differentiated ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');


% Plot R-peaks
figure;
plot(t, squared_ecg);
hold on;
scatter(R_locs/fs, squared_ecg(R_locs), 'r', 'filled');
title('R-Peak Detection');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Squared ECG Signal', 'R-Peak Locations');
