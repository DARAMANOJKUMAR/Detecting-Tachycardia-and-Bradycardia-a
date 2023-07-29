% Load the ECG dataset from a file
load('100m.mat'); % Replace with your file name
% Plot the ECG signal
figure;
plot(1:length(val), val, 'r', 'LineWidth', 1);
xlabel('Sample Number');
ylabel('Amplitude');
title('ECG Signal');
