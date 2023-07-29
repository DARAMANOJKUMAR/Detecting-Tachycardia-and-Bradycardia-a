%% Wavelet Method
% Load ECG data
ecg = load('100m.mat');
x = ecg.val(1,1:3600);

% Set wavelet parameters
wname = 'db6'; % Wavelet name
scales = 1:128; % Scales for wavelet decomposition
level = 4; % Decomposition level

% Perform wavelet decomposition
[c,l] = wavedec(x, level, wname);
cD4 = detcoef(c,l,4); % Detail coefficients at level 4

% Calculate threshold for detail coefficients
sigma = median(abs(cD4))/0.6745;
thresh = sigma*sqrt(2*log(length(x)));

% Perform soft thresholding of detail coefficients
cD4_t = wthresh(cD4, 's', thresh);

% Reconstruct the denoised signal
cD = zeros(size(c));
cD(end-length(cD4)+1:end) = cD4_t;
x_denoised = waverec(cD,l,wname);

% Plot ECG and denoised signal
t = 0:1/360:(length(x)-1)/360;
figure
subplot(2,1,1)
plot(t,x)
title('ECG')
subplot(2,1,2)
plot(t,x_denoised)
title('Denoised Signal')

% Detect R peaks using thresholding
thresh = 0.6 * max(x_denoised);
r_peaks = t(x_denoised > thresh);

% Plot R peak detection results
figure
plot(t,x_denoised)
hold on
plot(r_peaks, thresh*ones(size(r_peaks)), 'ro')
title('R Peak Detection')