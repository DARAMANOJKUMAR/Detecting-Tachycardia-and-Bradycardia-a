% Load MIT-BIH Arrhythmia Database
% Load MIT-BIH Arrhythmia Database
load('100m.mat');

% Check if the variable 'val' exists in the loaded data
if ~exist('val', 'var')
    error('Could not find variable ''val'' in loaded data.');
end

% Check if the variable 'ann' exists in the loaded data
if ~exist('ann', 'var')
    error('Could not find variable ''ann'' in loaded data.');
end

% Check if the variable 'ann' is a cell array with at least one element
if ~iscell(ann) || numel(ann) < 1
    error('Variable ''ann'' must be a cell array with at least one element.');
end

% Get the first element of 'ann' and check if it has the required fields
if ~isfield(ann{1}, 'anntype') || ~isfield(ann{1}, 'sample')
    error('First element of variable ''ann'' must have fields ''anntype'' and ''sample''.');
end

% Define parameters
fs = 360;
w = 5;
threshold = 0.5;

% Extract annotation information
ann_labels = cellstr(ann{1}.anntype);
ann_samples = ann{1}.sample;

% Initialize variables
threshold_bp = zeros(1, 11);
pan_tompkins_bp = zeros(1, 11);
hrv_bp = zeros(1, 11);
freq_domain_bp = zeros(1, 11);

% Loop through all ECG signals
for i = 1:11
    
    % Extract ECG signal and annotation
    ecg = val(:, i);
    ann_label = ann_labels{find(ann_samples <= length(ecg), 1, 'last')};
    
    % Apply threshold-based method
    threshold_bp(i) = detect_brady_tachy_threshold(ecg, fs, w, threshold);
    
    % Apply Pan-Tompkins algorithm
    [~, pan_tompkins_bp(i)] = detect_beats(ecg, fs);
    
    % Apply HRV analysis
    hrv_features = extract_hrv_features(ecg, ann_label, fs);
    if hrv_features.RMSSD > 50
        hrv_bp(i) = 0;
    elseif hrv_features.Mean_RR < 600
        hrv_bp(i) = -1;
    elseif hrv_features.Mean_RR > 1000
        hrv_bp(i) = 1;
    else
        hrv_bp(i) = 0;
    end
    
    % Apply frequency domain analysis
    [~, ~, HF, TP] = spectral_analysis(ecg, fs);
    HFnu = HF/TP;
    LFHF = trapz(f(f>=0.04 & f<=0.15),psd(f>=0.04 & f<=0.15)) / HF;
    if (HFnu < 0.15 && LFHF < 0.5)
        freq_domain_bp(i) = -1;
    elseif (HFnu > 0.4 && LFHF > 1.5)
        freq_domain_bp(i) = 1;
    else
        freq_domain_bp(i) = 0;
    end
    
end

% Load annotation file
bp = load('100m.mat', 'val');
bp = logical(bp.val);

% Compute performance metrics
threshold_bp = logical(threshold_bp);
pan_tompkins_bp = logical(pan_tompkins_bp);
hrv_bp = logical(hrv_bp);
freq_domain_bp = logical(freq_domain_bp);


% True positives
tp_threshold = sum(threshold_bp & bp);
tp_pan_tompkins = sum(pan_tompkins_bp & bp);
tp_hrv = sum(hrv_bp & bp);
tp_freq_domain = sum(freq_domain_bp & bp);

% False positives
fp_threshold = sum(threshold_bp & ~bp);
fp_pan_tompkins = sum(pan_tompkins_bp & ~bp);
fp_hrv = sum(hrv_bp & ~bp);
fp_freq_domain = sum(freq_domain_bp & ~bp);

% False negatives
fn_threshold = sum(~threshold_bp & bp);
fn_pan_tompkins = sum(~pan_tompkins_bp & bp);
fn_hrv = sum(~hrv_bp & bp);
fn_freq_domain = sum(~freq_domain_bp & bp);
% True negatives
tn_threshold = sum(~threshold_bp & ~bp);
tn_pan_tompkins = sum(~pan_tompkins_bp & ~bp);
tn_hrv = sum(~hrv_bp & ~bp);
tn_freq_domain = sum(~freq_domain_bp & ~bp);

% Compute accuracy, precision, recall, and F1 score
accuracy_threshold = (tp_threshold + tn_threshold) / length(bp);
precision_threshold = tp_threshold / (tp_threshold + fp_threshold);
recall_threshold = tp_threshold / (tp_threshold + fn_threshold);
f1_score_threshold = 2 * precision_threshold * recall_threshold / (precision_threshold + recall_threshold);

accuracy_pan = (tp_pan + tn_pan) / total_cases;
precision_pan = tp_pan / (tp_pan + fp_pan);
recall_pan = tp_pan / (tp_pan + fn_pan);
f1_score_pan = 2 * precision_pan * recall_pan / (precision_pan + recall_pan);

accuracy_hrv = (tp_hrv + tn_hrv) / total_cases;
precision_hrv = tp_hrv / (tp_hrv + fp_hrv);
recall_hrv = tp_hrv / (tp_hrv + fn_hrv);
f1_score_hrv = 2 * precision_hrv * recall_hrv / (precision_hrv + recall_hrv);

% Display performance metrics
fprintf('Performance Metrics\n');
fprintf('-------------------\n');
fprintf('Method Accuracy Precision Recall F1 Score\n');
fprintf('------------------------------------------------------------\n');
fprintf('Threshold-based %.2f %.2f %.2f %.2f\n', accuracy_threshold, precision_threshold, recall_threshold, f1_score_threshold);
fprintf('Pan-Tompkins %.2f %.2f %.2f %.2f\n', accuracy_pan, precision_pan, recall_pan, f1_score_pan);
fprintf('HRV Analysis %.2f %.2f %.2f %.2f\n', accuracy_hrv, precision_hrv, recall_hrv, f1_score_hrv);  
