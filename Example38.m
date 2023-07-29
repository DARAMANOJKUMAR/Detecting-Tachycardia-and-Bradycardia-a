%% HRV Analysis
% Load ECG signal
load('114m.mat');
fs = 360; % sampling rate

% Apply bandpass filter
[b, a] = butter(2, [5 15]/(fs/2), 'bandpass');
ecg_filt = filtfilt(b, a, val);

% Compute R-R intervals
[~, R_locs] = findpeaks(ecg_filt, 'MinPeakHeight', max(ecg_filt)/2, 'MinPeakDistance', round(0.5*fs));
RR_intervals = diff(R_locs)/fs*1000; % convert to milliseconds

% Compute HRV features
mean_RR = mean(RR_intervals);
SDNN = std(RR_intervals);
RMSSD = sqrt(mean(diff(RR_intervals).^2));
pNN50 = sum(abs(diff(RR_intervals)) > 50)/length(RR_intervals)*100;

% Classify heart rate
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
fprintf('Mean R-R interval: %.2f ms\n', mean_RR);
fprintf('SDNN: %.2f ms\n', SDNN);
fprintf('RMSSD: %.2f ms\n', RMSSD);
fprintf('pNN50: %.2f%%\n', pNN50);

