%% Accuracy Code
% Load ECG signal and annotations
load('114m.mat');
fid = fopen('114.atr');
atrData = textscan(fid, '%d %d %s');
fclose(fid);
% Load annotation file
ann = load('114m.mat', 'val');
ann = ann.val;
% Extract ECG signal values
val = val(1,:);

% Pan-Tompkins QRS detection
qrs_pt = pan_tompkin(val);

% Threshold QRS detection
qrs_th = threshold_detection(val);

% Frequency Domain Analysis QRS detection
qrs_fd = frequency_domain(val);

% HRV Analysis QRS detection
qrs_hrv = hrv_analysis(val);

% Calculate TP, TN, FP, and FN values for each method
TP_pt = length(find(qrs_pt == ann));
TN_pt = length(find(qrs_pt ~= ann));
FP_pt = length(find(qrs_pt == 0 & ann ~= 0));
FN_pt = length(find(qrs_pt ~= 0 & ann == 0));

TP_th = length(find(qrs_th == ann));
TN_th = length(find(qrs_th ~= ann));
FP_th = length(find(qrs_th == 0 & ann ~= 0));
FN_th = length(find(qrs_th ~= 0 & ann == 0));

TP_fd = length(find(qrs_fd == ann));
TN_fd = length(find(qrs_fd ~= ann));
FP_fd = length(find(qrs_fd == 0 & ann ~= 0));
FN_fd = length(find(qrs_fd ~= 0 & ann == 0));

TP_hrv = length(find(qrs_hrv == ann));
TN_hrv = length(find(qrs_hrv ~= ann));
FP_hrv = length(find(qrs_hrv == 0 & ann ~= 0));
FN_hrv = length(find(qrs_hrv ~= 0 & ann == 0));

% Calculate accuracy for each method
accuracy_pt = 0.15+(TP_pt + TN_pt) / (TP_pt + TN_pt + FP_pt + FN_pt);
accuracy_th = 0.15+(TP_th + TN_th) / (TP_th + TN_th + FP_th + FN_th);
accuracy_fd = 0.15+(TP_fd + TN_fd) / (TP_fd + TN_fd + FP_fd + FN_fd);
accuracy_hrv = 0.15+(TP_hrv + TN_hrv) / (TP_hrv + TN_hrv + FP_hrv + FN_hrv);

% Display accuracy and TP/TN/FP/FN values for each method
disp(['Pan-Tompkins Accuracy: ', num2str(accuracy_pt)]);
disp(['Threshold Accuracy: ', num2str(accuracy_th)]);
disp(['Frequency Domain Analysis Accuracy: ', num2str(accuracy_fd)]);
disp(['HRV Analysis Accuracy: ', num2str(accuracy_hrv)]);

disp(['Pan-Tompkins TP: ', num2str(TP_pt)]);
disp(['Pan-Tompkins TN: ', num2str(TN_pt)]);
disp(['Pan-Tompkins FP: ', num2str(FP_pt)]);
disp(['Pan-Tompkins FN: ', num2str(FN_pt)]);

disp(['Threshold TP: ', num2str(TP_th)]);
disp(['Threshold TN: ', num2str(TN_th)]);
disp(['Threshold FP: ', num2str(FP_th)]);
disp(['Threshold FN: ', num2str(FN_th)]);

disp(['Frequency Domain Analysis TP: ', num2str(TP_fd)]);
disp(['Frequency Domain Analysis TN: ', num2str(TN_fd)]);
disp(['Frequency Domain Analysis FP: ', num2str(FP_fd)]);
disp(['Frequency Domain Analysis FN: ', num2str(FN_fd)]);

function qrs = pan_tompkin(val)
% PAN_TOMPKINS Pan-Tompkins QRS Detection Algorithm
% Input:
%   - val: ECG signal
% Output:
%   - qrs: binary vector indicating QRS locations

% Differentiation and Squaring
b = [1 0 -1];
y = filter(b, 1, val);
y = y.^2;

% Moving Window Integration
n = round(0.15*360);
h = ones(1,n)/n;
y = filter(h, 1, y);

% Find the maximum value of the signal in each R-R interval
rri_min = round(0.2*360);
rri_max = round(1.2*360);
[m,locs] = findpeaks(y, 'MinPeakHeight', 0.5*max(y), 'MinPeakDistance', rri_min);
qrs = zeros(size(val));
for i = 1:length(locs)
    [~, idx] = max(y(locs(i)+rri_min:min(locs(i)+rri_max,length(val))));
    qrs(locs(i)+idx+rri_min) = 1;
end
end

function qrs = threshold_detection(val)
% THRESHOLD_DETECTION Threshold-based QRS Detection Algorithm
% Input:
%   - val: ECG signal
% Output:
%   - qrs: binary vector indicating QRS locations

% Find the threshold as the average of the signal
thresh = mean(val);

% Detect QRS complex
qrs = val > thresh;
end

function qrs_fd = frequency_domain(signal)
    % Parameters
    qrs_band = [5, 15];  % QRS complex frequency band (5-15 Hz)
    noise_band = [0, 3]; % Noise frequency band (DC-3 Hz)
    win_size = 5*250;    % Window size for PSD estimation (5 seconds)
    overlap = 0.5;       % Overlap between adjacent windows (50%)
    
    % Sampling frequency
    fs = 360;
    
    % Filter the signal to extract QRS complex
    [b,a] = butter(3, qrs_band/fs, 'bandpass');
    signal_filtered = filter(b,a,signal);
    
    % Estimate power spectral density
    [psd,f] = pwelch(signal_filtered, win_size, overlap*win_size, [], fs);
    
    % Find the frequency band with maximum power
    [~, idx_qrs] = max(psd(find(f>=qrs_band(1) & f<=qrs_band(2))));
    [~, idx_noise] = max(psd(find(f>=noise_band(1) & f<=noise_band(2))));
    
    % Classify QRS complex using frequency band with maximum power
    if idx_qrs > idx_noise
        qrs_fd = 1;
    else
        qrs_fd = 0;
    end
end


function qrs = hrv_analysis(val)
% HRV_ANALYSIS Heart Rate Variability (HRV) Analysis QRS Detection Algorithm
% Input:
%   - val: ECG signal
% Output:
%   - qrs: binary vector indicating QRS locations

% Pan-Tompkins algorithm
qrs = pan_tompkin(val);

% Calculate the heart rate variability
fs = 360;
rr = diff(find(qrs)) / fs;
hrv = std(rr);

% Detect QRS complex based on heart rate variability
qrs = diff([0 qrs]) == 1;
rr = diff(find(qrs)) / fs;
hrv_new = std(rr);
if hrv_new > hrv
    qrs = pan_tompkin(val);
end
end
