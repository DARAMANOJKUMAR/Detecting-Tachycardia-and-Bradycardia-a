
%% Hilbert Method
% Load ECG data
ecg = load('100m.mat');
x = ecg.val(1,1:3600);

% Design FIR bandpass filter
fs = 360; % Sampling frequency
N = 100; % Filter order
f1 = 0.5; % Lower cutoff frequency
f2 = 100; % Upper cutoff frequency
b = fir1(N, [f1 f2]/(fs/2));

% Apply filter to ECG data
xf = filter(b, 1, x);

% Calculate the analytic signal using Hilbert transform
xh = hilbert(xf);
xr = real(xh);
xi = imag(xh);
xa = sqrt(xr.^2 + xi.^2);

% Plot ECG and analytic signal
t = 0:1/fs:(length(x)-1)/fs;
figure
subplot(2,1,1)
plot(t,x)
title('ECG')
subplot(2,1,2)
plot(t,xa)
title('Analytic Signal')

% Detect R peaks using thresholding
thresh = 0.6 * max(xa);
r_peaks = t(xa > thresh);

% Plot R peak detection results
figure
plot(t,xa)
hold on
plot(r_peaks, thresh*ones(size(r_peaks)), 'ro')
title('R Peak Detection')