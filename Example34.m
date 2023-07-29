% Load ECG signal
load('100m.mat');

% Set sampling rate and time vector
Fs = 360; % Sampling rate
t = (0:length(val)-1)/Fs; % Time vector

% Filter the ECG signal using a bandpass filter
Fn = Fs/2; % Nyquist frequency
Wp = [5 15]/Fn; % Passband frequencies
Ws = [2 20]/Fn; % Stopband frequencies
Rp = 1; % Passband ripple
Rs = 15; % Stopband attenuation
[n, Wn] = buttord(Wp, Ws, Rp, Rs); % Compute filter order and cutoff frequency
[b, a] = butter(n, Wn); % Compute filter coefficients
ecg_filtered = filtfilt(b, a, val); % Apply filter to the ECG signal

% Apply the Pan-Tompkins algorithm to detect R-peaks
R = pan_tompkins(ecg_filtered, Fs);

% Plot the original ECG signal and the detected R-peaks
figure;
plot(t, val);
hold on;
plot(t(R), val(R), 'r.', 'MarkerSize', 20);
xlabel('Time (s)');
ylabel('Amplitude (mV)');
title('ECG Signal with R-Peak Detection (Pan-Tompkins Algorithm)');
legend('ECG signal', 'R-peaks');
function R = pan_tompkins(x, Fs)
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