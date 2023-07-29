% Load ECG signal
load 100m.mat

% Define wavelet name and level
wname = 'sym8';
level = 5;

% Apply wavelet decomposition
[C, L] = wavedec(val, level, wname);

% Extract approximation and detail coefficients
app_coeffs = wrcoef('a', C, L, wname, level);
det_coeffs = zeros(level, length(val));
for i = 1:level
    det_coeffs(i,:) = wrcoef('d', C, L, wname, i);
end

% Compute threshold for each level
thr = zeros(level, 1);
for i = 1:level
    sigma = median(abs(det_coeffs(i,:))) / 0.6745;
    thr(i) = sigma * sqrt(2*log10(length(val)));
end

% Detect arrhythmia based on threshold
arrhythmia = zeros(size());
for i = 1:length(thr)
    index = find(abs(det_coeffs(i,:)) > thr(i));
    arrhythmia(index) = 1;
end

% Plot original signal and detected arrhythmia
figure;
subplot(2,1,1);
plot(val);
title('Original ECG Signal');
xlabel('Sample number');
ylabel('Amplitude');

subplot(2,1,2);
plot(val);
hold on;
plot(find(arrhythmia), val(arrhythmia==1), 'ro');
title('Detected Arrhythmia using Wavelet Method');
xlabel('Sample number');
ylabel('Amplitude');
legend('ECG signal', 'Arrhythmia');
