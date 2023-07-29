% Load ECG signal from MIT-BIH Arrhythmia Database
load('100m.mat'); % replace with path to the database file

% Extract ECG signal and sampling frequency
ecg_signal = val;
fs = 360;

% Define Pan-Tompkins parameters
f1 = 5; % low-pass filter cutoff frequency (Hz)
f2 = 15; % high-pass filter cutoff frequency (Hz)
N = round(0.1 * fs); % integration window size
M = round(0.35 * fs); % searchback window size
K1 = 0.25; % threshold multiplication factor
K2 = 0.5; % noise peak exclusion factor

% Apply bandpass filter
[b,a] = butter(2, [f1 f2] / (fs/2), 'bandpass');
ecg_filt = filter(b, a, ecg_signal);

% Square the filtered signal
ecg_squared = ecg_filt .^ 2;

% Apply moving average filter
ecg_moving_avg = movmean(ecg_squared, N);

% Find local maxima in moving average
[~, locs] = findpeaks(ecg_moving_avg);

% Initialize QRS detection variables
qrs_detected = false(size(ecg_signal));
qrs_peak_locs = [];

% Loop through each detected peak
for i = 1:length(locs)
    % Determine the searchback window
    searchback_start = max(1, locs(i) - M);
    searchback_end = locs(i);
    
    % Find the local maximum within the searchback window
    [~, peak_loc] = max(ecg_signal(searchback_start:searchback_end));
    peak_loc = peak_loc + searchback_start - 1;
    
    % Compute the threshold
    if i == 1
        threshold = K1 * ecg_moving_avg(peak_loc);
    else
        previous_peak = qrs_peak_locs(end);
        noise_peak_locs = locs(locs > previous_peak & locs < locs(i));
        noise_peak_vals = ecg_moving_avg(noise_peak_locs);
        threshold = K1 * (ecg_moving_avg(peak_loc) - K2 * mean(noise_peak_vals));
    end
    
    % Determine if the peak exceeds the threshold
    if ecg_moving_avg(peak_loc) > threshold
        qrs_detected(peak_loc) = true;
        qrs_peak_locs(end+1) = peak_loc;
    end
end

% Plot ECG signal with detected QRS complexes
t = (0:length(ecg_signal)-1) / fs;
figure;
plot(t, ecg_signal);
hold on;
plot(t(qrs_detected), ecg_signal(qrs_detected), 'ro');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
legend('ECG signal', 'Detected QRS complexes');
