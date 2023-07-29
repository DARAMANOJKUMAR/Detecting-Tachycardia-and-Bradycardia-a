% Load ECG data and ground truth labels
load('ecg_data.mat');
load('100m.mat');
fs =360; % Sampling frequency

% Filter the signal
[b,a] = butter(5, [0.5, 30]/(fs/2), 'bandpass');
ecg_filtered = filtfilt(b, a, ecg);

% Apply Hilbert transform
hilbert_signal = hilbert(ecg_filtered);
inst_amplitude = abs(hilbert_signal);

% Detect QRS complex
qrs_amp_raw = inst_amplitude;
qrs_i_raw = find(qrs_amp_raw > mean(qrs_amp_raw));

% Calculate heart rate
rr = diff(qrs_i_raw);
hr = 60*fs./rr;

% Identify arrhythmias
arrhythmia = false(1,length(hr));
arrhythmia(hr<50) = true; % Bradycardia
arrhythmia(hr>100) = true; % Tachycardia
arrhythmia(diff(rr)./fs > 0.16) = true; % Premature Ventricular Contractions

% Plot ECG signal and QRS detection
t = (0:length(ecg)-1)/fs;
figure;
subplot(2,1,1);
plot(t,ecg);
title('ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
subplot(2,1,2);
plot(t,inst_amplitude,'b');
hold on;
stem(t(qrs_i_raw),qrs_amp_raw(qrs_i_raw),'r','LineWidth',1);
title('QRS Detection using Hilbert Method');
xlabel('Time (s)');
ylabel('Amplitude (mV)');
legend('Instantaneous Amplitude','Detected QRS');

% Calculate accuracy
accuracy = sum(arrhythmia == ground_truth)/length(ground_truth)*100;
disp(['Accuracy: ' num2str(accuracy) '%']);
