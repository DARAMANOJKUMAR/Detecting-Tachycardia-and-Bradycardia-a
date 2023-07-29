% Load ECG signal
load('100m.mat');

% Filter the ECG signal using a bandpass filter
Fs = 360; % Sampling rate
Fn = Fs/2; % Nyquist frequency
Wp = [5 15]/Fn; % Passband frequencies
Ws = [2 20]/Fn; % Stopband frequencies
Rp = 1; % Passband ripple
Rs = 15; % Stopband attenuation
[n, Wn] = buttord(Wp, Ws, Rp, Rs); % Compute filter order and cutoff frequency
[b, a] = butter(n, Wn); % Compute filter coefficients
ecg_filtered = filtfilt(b, a, val); % Apply filter to the ECG signal

% Differentiate the filtered signal to emphasize QRS complexes
ecg_diff = diff(ecg_filtered);

% Square the differentiated signal to highlight the QRS complex peaks
ecg_squared = ecg_diff.^2;

% Integrate the squared signal over a sliding window to smooth out the signal
window_width = 0.15 * Fs; % Window width in samples (150 ms)
ecg_integrated = zeros(size(ecg_squared));
for i = 1:length(ecg_squared)
    window_start = max(1, i - window_width);
    ecg_integrated(i) = sum(ecg_squared(window_start:i));
end

% Find the R-peaks (QRS complex peaks) in the integrated signal using the Pan-Tompkins algorithm
R = pan_tompkin(ecg_integrated, Fs);

% Compute the RR intervals and heart rate from the R-peak locations
RR_intervals = diff(R);
heart_rate = 60 * Fs ./ RR_intervals;

% Detect arrhythmia based on heart rate variability
mean_HR = mean(heart_rate);
std_HR = std(heart_rate);
if std_HR / mean_HR > 0.15
    fprintf('Arrhythmia detected.\n');
else
    fprintf('No arrhythmia detected.\n');
end
function R = pan_tompkin(x, Fs)
% Implements the Pan-Tompkins algorithm for QRS detection in ECG signals
% x: input ECG signal
% Fs: sampling frequency of the input signal
%
% Returns:
% R: locations of R-peaks (QRS complex peaks) in the ECG signal

% Set default values for algorithm parameters
if nargin < 2
    Fs = 360;
end
if nargin < 1
    error('Input ECG signal required.');
end

% Differentiate the signal to emphasize QRS complex peaks
dx = diff(x);

% Square the differentiated signal to highlight the QRS complex peaks
dx_squared = dx .^ 2;

% Low-pass filter the squared signal to remove high-frequency noise
N = round(0.150 * Fs); % Filter order (150 ms)
b = ones(1, N) / N;
a = 1;
dx_squared_filtered = filter(b, a, dx_squared);

% Find QRS complex peaks using a moving window integration approach
N = round(0.200 * Fs); % Integration window width (200 ms)
M = round(0.600 * Fs); % Searchback window width (600 ms)
K = 0.5; % Integration constant
L = length(dx_squared_filtered);
th = 0.5 * std(dx_squared_filtered(1:round(0.200 * Fs))); % Detection threshold
Q = zeros(1, L);
for i = (N+M+1):L
    % Compute integration value
    Q(i) = K * sum(dx_squared_filtered((i-N+1):i));
    
    % Find maximum in searchback window
    [max_val, max_index] = max(Q((i-M):i));
    
    % Check if maximum exceeds threshold and is the absolute maximum in the searchback window
    if max_val > th && (max_index == M+1)
        % Record R-peak location
        R(i-M) = i;
    else
        R(i-M) = 0;
    end
end

% Remove R-peaks too close to beginning or end of the signal
R(R < (0.5 * Fs)) = [];
R(R > (length(x) - (0.5 * Fs))) = [];
end