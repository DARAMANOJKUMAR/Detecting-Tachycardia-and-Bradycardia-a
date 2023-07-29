% Load ECG signal
load('100m.mat'); % Load the mat file
ecg_signal = val; % Extract the ECG signal from the loaded data
ecg_signal = double(ecg_signal); % Convert to double precision

% Apply bandpass filter
[b, a] = butter(2, [0.5/500, 40/500], 'bandpass');
filtered_signal = filtfilt(b, a, ecg_signal);

% Calculate SPWVD
spwvd_signal = spwvd(filtered_signal);

% Calculate Shannon entropy
entropy_signal = zeros(size(filtered_signal));
for i = 1:length(filtered_signal)
    if i < 64 || i > length(filtered_signal)-64
        entropy_signal(i) = 0;
    else
        entropy_signal(i) = shannon_entropy(spwvd_signal(i-64:i+64));
    end
end

% Thresholding to detect arrhythmias
threshold = 1.2*median(entropy_signal);
arrhythmias = find(entropy_signal > threshold);
disp(['Detected arrhythmias at samples: ', num2str(arrhythmias)]);

function h = shannon_entropy(x)
    p = histcounts(x, 256) / length(x);
    p = p(p ~= 0);
    h = -sum(p .* log2(p));
end

function tfr = spwvd(x)
    n = length(x);
    tfr = zeros(n, n);
    for m = 1:n
        for n = 1:n
            tfr(m, n) = sum(x(m:m+1-1) .* conj(x(n:n+1-1)) .* exp(-2j * pi * (m - n) .* (0:n-m-1) / n));
        end
    end
    tfr = real(fftshift(fft(tfr)));
end
