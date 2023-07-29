load('100m.mat');  % load the signal from the .mat file
signal = val;  % assume the signal is stored in a variable called 'val'

% Determine signal duration and number of samples
duration = size(signal, 1) / fs;  % signal duration in seconds
num_samples = size(signal, 1);   % number of samples in the signal

% Calculate sampling frequency
fs = num_samples / duration;     % sampling frequency in Hz
disp(fs)
