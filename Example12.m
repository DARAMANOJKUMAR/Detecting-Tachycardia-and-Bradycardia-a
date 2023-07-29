%% Load ECG signal
load('100m.mat'); % replace with your own ECG signal

%% Pre-processing
fs = 360; % sampling frequency
[b,a] = butter(2,[5/(fs/2) 15/(fs/2)],'bandpass'); % bandpass filter design

% extract ECG signal and apply filter
ecg_signal = ecg.val; % extract ECG signal
filtered_ecg = filtfilt(b,a,double(ecg_signal)); % zero-phase filtering
diff_ecg = diff(filtered_ecg); % differentiate
squared_ecg = diff_ecg.^2; % square
win_length = round(0.15*fs); % window length for moving average
ma_ecg = movmean(squared_ecg,win_length); % moving average

%% Pan-Tompkins algorithm
threshold1 = 0.5*max(ma_ecg); % first threshold
threshold2 = 0.05*max(ma_ecg); % second threshold
delay = round(0.15*fs); % delay for peak detection
qrs_detect = []; % array to store R-peak locations

for i=delay+2:length(ma_ecg)-delay-1
    % find local maximum
    if ma_ecg(i)>ma_ecg(i-1) && ma_ecg(i)>ma_ecg(i+1) && ma_ecg(i)>threshold1
        % find QRS onset
        for j=1:delay
            if ma_ecg(i-j)<threshold2
                onset = i-j;
                break;
            end
        end
        % find QRS offset
        for j=1:delay
            if ma_ecg(i+j)<threshold2
                offset = i+j;
                break;
            end
        end
        % add R-peak location to array
        [~,r_loc] = max(filtered_ecg(onset:offset));
        r_loc = r_loc+onset-1;
        qrs_detect = [qrs_detect r_loc];
    end
end

%% Plot results
t = (1:length(ecg_signal))/fs; % time vector
figure;
subplot(511);
plot(t,ecg_signal);
title('Original ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(512);
plot(t,filtered_ecg);
title('Filtered ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(513);
plot(t(1:end-1),diff_ecg);
title('Differentiated ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(514);
plot(t(1:end-1),squared_ecg);
title('Squared ECG Signal');
xlabel('Time (s)');
ylabel('Amplitude');
subplot(515);
plot(t(ma_ecg>0),ma_ecg(ma_ecg>0));
hold on;
plot(qrs_detect/fs,ma_ecg(qrs_detect),'ro');
title('Moving Average ECG Signal with R-Peak Detection');
xlabel('Time (s)');
ylabel('Amplitude');
legend('Moving Average ECG','R-Peak');
