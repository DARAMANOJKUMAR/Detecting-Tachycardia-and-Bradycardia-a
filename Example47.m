% Load ECG signal and annotations
load('101m.mat');
fid = fopen('101.atr');
atrData = textscan(fid, '%d %d %s');
fclose(fid);


% Compute R-peaks using Pan-Tompkins algorithm
qrs_pt = pan_tompkin(val,Fs);

% Compute R-peaks using threshold detection
qrs_th = threshold_detection(val);

% Compute R-peaks using frequency domain analysis
qrs_fd = fd_analysis(val, Fs);

% Compute R-peaks using HRV analysis
qrs_hrv = hrv_analysis(val, Fs);

% Convert annotation locations to samples
ann_samples = round(ann / (1/Fs));

% Compute true positive, true negative, false positive, and false negative rates
TP_pt = length(intersect(qrs_pt, ann_samples));
TN_pt = length(val) - length(union(qrs_pt, ann_samples));
FP_pt = length(qrs_pt) - TP_pt;
FN_pt = length(ann_samples) - TP_pt;

TP_th = length(intersect(qrs_th, ann_samples));
TN_th = length(val) - length(union(qrs_th, ann_samples));
FP_th = length(qrs_th) - TP_th;
FN_th = length(ann_samples) - TP_th;

TP_fd = length(intersect(qrs_fd, ann_samples));
TN_fd = length(val) - length(union(qrs_fd, ann_samples));
FP_fd = length(qrs_fd) - TP_fd;
FN_fd = length(ann_samples) - TP_fd;

TP_hrv = length(intersect(qrs_hrv, ann_samples));
TN_hrv = length(val) - length(union(qrs_hrv, ann_samples));
FP_hrv = length(qrs_hrv) - TP_hrv;
FN_hrv = length(ann_samples) - TP_hrv;

% Compute accuracy rates
Acc_pt = (TP_pt + TN_pt) / (TP_pt + TN_pt + FP_pt + FN_pt);
Acc_th = (TP_th + TN_th) / (TP_th + TN_th + FP_th + FN_th);
Acc_fd = (TP_fd + TN_fd) / (TP_fd + TN_fd + FP_fd + FN_fd);
Acc_hrv = (TP_hrv + TN_hrv) / (TP_hrv + TN_hrv + FP_hrv + FN_hrv);

% Display results
disp("Pan-Tompkins Accuracy: " + Acc_pt);
disp("Threshold Accuracy: " + Acc_th);
disp("Frequency Domain Analysis Accuracy: " + Acc_fd);
disp("HRV Analysis Accuracy: " + Acc_hrv);

disp("Pan-Tompkins TP: " + TP_pt);
disp("Pan-Tompkins TN: " + TN_pt);
disp("Pan-Tompkins FP: " + FP_pt);
disp("Pan-Tompkins FN: " + FN_pt);

disp("Threshold TP: " + TP_th);
disp("Threshold TN: " + TN_th);
disp("Threshold FP: " + FP_th);
disp("Threshold FN: " + FN_th);

disp("Frequency Domain Analysis TP: " + TP_fd);
disp("Frequency Domain Analysis TN: " + TN_fd);
disp("Frequency Domain Analysis FP: " + FP_fd);
disp("Frequency Domain Analysis FN: " + FN_fd);

disp("HRV Analysis TP: " + TP_hrv);
disp("HRV Analysis TN: " + TN_hrv);
disp("HRV Analysis FP: " + FP_hrv);
disp("HRV Analysis FN: " + FN_hrv);

function [qrs_peaks, qrs_locs] = pan_tompkin(ecg_signal, fs)

% high-pass filter (1 Hz cutoff)
[b, a] = butter(1, 1 / (fs / 2), 'high');
ecg_signal_filtered = filter(b, a, ecg_signal);

% differentiation filter
diff_filter = [1 0 -1];
ecg_signal_diff = conv(ecg_signal_filtered, diff_filter);

% squared signal
ecg_signal_squared = ecg_signal_diff .^ 2;

% moving window integration (150ms window)
window_size = round(fs * 0.150);
window = ones(1, window_size);
ecg_signal_integrated = conv(ecg_signal_squared, window);

% find QRS complexes
[qrs_peaks, qrs_locs] = findpeaks(ecg_signal_integrated, 'MinPeakHeight', max(ecg_signal_integrated) * 0.6, 'MinPeakDistance', round(0.3 * fs));
end

function qrs_th = threshold_detection(val)
    th = mean(val);
    qrs_th = val > th;
end

function qrs_fd = fd_analysis(val, fs)
    n = length(val);
    f = (0:n-1)*(fs/n); % frequency range
    fft_val = fft(val);
    P = abs(fft_val).^2/n; % power of the signal
    P = P(1:floor(n/2)+1);
    P(2:end-1) = 2*P(2:end-1);
    [~, ind] = max(P);
    qrs_fd = abs(f - f(ind)) < 5; % +/- 5Hz around peak frequency
end

function [tp, tn, fp, fn] = hrv_analysis(r_peaks, annot)
    % r_peaks: R-peak locations (in samples)
    % annot: annotation of QRS complexes ('N' for normal, 'V' for ventricular ectopic, etc.)
    
    % Extract RR intervals
    rr = diff(r_peaks);
    
    % Calculate mean and standard deviation of RR intervals
    mean_rr = mean(rr);
    std_rr = std(rr);
    
    % Calculate threshold values for identifying abnormal RR intervals
    upper_thresh = mean_rr + 2*std_rr;
    lower_thresh = mean_rr - 2*std_rr;
    
    % Classify RR intervals based on threshold values and annotation
    n = length(rr);
    tp = sum(rr > upper_thresh & strcmp(annot(2:end), 'V'));
    tn = sum(rr < lower_thresh & strcmp(annot(2:end), 'N'));
    fp = sum(rr > upper_thresh & strcmp(annot(2:end), 'N'));
    fn = sum(rr < lower_thresh & strcmp(annot(2:end), 'V'));
end

