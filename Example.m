% Load ECG signal data
load('ecg_data.mat');

% Apply preprocessing to the ECG signal
ecg = preprocess_ecg(ecg_data);

% Perform arrhythmia detection using Hilbert detection
hilbert_result = hilbert_detection(ecg);
hilbert_accuracy = calculate_accuracy(hilbert_result, ecg_data);

% Perform arrhythmia detection using Pan-Tompkins detection
pt_result = pan_tompkins_detection(ecg);
pt_accuracy = calculate_accuracy(pt_result, ecg_data);

% Perform arrhythmia detection using Wavelet detection
wavelet_result = wavelet_detection(ecg);
wavelet_accuracy = calculate_accuracy(wavelet_result, ecg_data);

% Print the accuracy results
fprintf('Accuracy results:\n');
fprintf('Hilbert detection: %0.2f%%\n', hilbert_accuracy*100);
fprintf('Pan-Tompkins detection: %0.2f%%\n', pt_accuracy*100);
fprintf('Wavelet detection: %0.2f%%\n', wavelet_accuracy*100);

% Plot the results
figure;
subplot(4,1,1);
plot(ecg);
title('ECG signal');
xlabel('Samples');
ylabel('Amplitude');

subplot(4,1,2);
plot(hilbert_result);
title(sprintf('Arrhythmia detection using Hilbert detection\nAccuracy: %0.2f%%', hilbert_accuracy*100));
xlabel('Samples');
ylabel('Amplitude');

subplot(4,1,3);
plot(pt_result);
title(sprintf('Arrhythmia detection using Pan-Tompkins detection\nAccuracy: %0.2f%%', pt_accuracy*100));
xlabel('Samples');
ylabel('Amplitude');

subplot(4,1,4);
plot(wavelet_result);
title(sprintf('Arrhythmia detection using Wavelet detection\nAccuracy: %0.2f%%', wavelet_accuracy*100));
xlabel('Samples');
ylabel('Amplitude');

% Preprocessing function
function ecg_filtered = preprocess_ecg(ecg_data)
    % Remove baseline wander
    ecg_filt1 = highpass(ecg_data, 0.5, 1000);

    % Remove powerline interference
    f0 = 60;
    bw = 2;
    notchFilter = designfilt('bandstopiir','FilterOrder',2, ...
        'HalfPowerFrequency1',f0-bw,'HalfPowerFrequency2',f0+bw, ...
        'DesignMethod','butter','SampleRate',1000);
    ecg_filt2 = filtfilt(notchFilter, ecg_filt1);

    % Filter the signal using a bandpass filter
    ecg_filtered = bandpass(ecg_filt2, [0.5 30], 1000);
end


% Hilbert detection function
function hilbert_result = hilbert_detection(ecg_data)
    % Apply the Hilbert transform to the ECG signal
    ecg_hilbert = abs(hilbert(ecg_data));

    % Normalize the signal
    hilbert_result = (ecg_hilbert - mean(ecg_hilbert)) / std(ecg_hilbert);
end

%pan_tompkins_detection
function pt_result = pan_tompkins_detection(ecg_data)
% Initialize filter coefficients
fs = 1000;
f1 = 5;
f2 = 15;
N = 33;
h1 = fir1(N, 2*f1/fs, 'low');
h2 = fir1(N, 2*f2/fs, 'high');
% Filter the signal using a lowpass filter
ecg_filt1 = filter(h1, 1, ecg_data);

% Filter the signal using a highpass filter
ecg_filt2 = filter(h2, 1, ecg_filt1);

% Perform QRS detection
[qrs_amp_raw, qrs_i_raw] = pan_tompkins(ecg_filt2, fs);

% Create a binary vector indicating the presence of a QRS complex
pt_result = zeros(length(ecg_data), 1);
pt_result(qrs_i_raw) = 1;
end

% Wavelet detection function
function wavelet_result = wavelet_detection(ecg_data)
% Choose a wavelet function
wname = 'sym8';

scss
Copy code
% Perform wavelet decomposition
[c, l] = wavedec(ecg_data, 5, wname);

% Extract the coefficients associated with the QRS complex
qrs_c = wrcoef('a', c, l, wname, 5);

% Compute the threshold for detecting the QRS complex
t = std(qrs_c) * 3;

% Detect the QRS complex
wavelet_result = qrs_c > t;
end
