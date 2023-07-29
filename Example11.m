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
figure;
subplot(2,1,1);
plot(ecg_signal);
title('Original ECG Signal');
xlabel('Sample');
ylabel('Amplitude');
subplot(2,1,2);
plot(filtered_ecg);
hold on;
plot(qrs_detect,filtered_ecg(qrs_detect),'ro');
title('R-Peak Detection using Pan-Tompkins Algorithm');
xlabel('Sample');
ylabel('Amplitude');
legend('Filtered ECG','R-Peak');
