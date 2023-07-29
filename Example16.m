% Load the signal from a file or create it
signal = load('100m.mat') % your signal

% Determine the sampling frequency
Fs = 1 / mean(diff(t)); % where t is the time vector of the signal

% Determine the duration of the signal
duration = length(signal) / Fs;

% Print the results
fprintf('Sampling frequency: %g Hz\n', Fs);
fprintf('Signal duration: %g seconds\n', duration);
