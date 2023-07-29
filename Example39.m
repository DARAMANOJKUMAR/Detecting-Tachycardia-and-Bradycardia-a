% Load the MIT-BIH Arrhythmia Database
load('');
% Preprocessing
ecg = ecg - mean(ecg);
ecg = ecg / max(abs(ecg));

% Add noise to the ECG signal
noisy_ecg = awgn(ecg, 10, 'measured');

% Threshold-based method
t1 = tic;
[peaks1,locs1] = threshold_detector(noisy_ecg);
t2 = toc(t1);

% Pan-Tompkins algorithm
t3 = tic;
[peaks2,locs2] = pan_tompkins_detector(noisy_ecg);
t4 = toc(t3);

% HRV Analysis
t5 = tic;
[rri, t] = get_rri(ecg, Fs);
hrv_features = get_hrv_features(rri, t);
t6 = toc(t5);

% Evaluate the results
annotations = load('');
[accuracy1, sensitivity1, specificity1] = evaluate_results(peaks1,locs1,annotations);
[accuracy2, sensitivity2, specificity2] = evaluate_results(peaks2,locs2,annotations);
[accuracy3, sensitivity3, specificity3] = evaluate_hrv_results(hrv_features,annotations);

fprintf('Threshold-based method:\n');
fprintf('Accuracy: %.2f%%\n', accuracy1*100);
fprintf('Sensitivity: %.2f%%\n', sensitivity1*100);
fprintf('Specificity: %.2f%%\n', specificity1*100);
fprintf('Computation time: %.2f seconds\n\n', t2);

fprintf('Pan-Tompkins algorithm:\n');
fprintf('Accuracy: %.2f%%\n', accuracy2*100);
fprintf('Sensitivity: %.2f%%\n', sensitivity2*100);
fprintf('Specificity: %.2f%%\n', specificity2*100);
fprintf('Computation time: %.2f seconds\n\n', t4);

fprintf('HRV Analysis:\n');
fprintf('Accuracy: %.2f%%\n', accuracy3*100);
fprintf('Sensitivity: %.2f%%\n', sensitivity3*100);
fprintf('Specificity: %.2f%%\n', specificity3*100);
fprintf('Computation time: %.2f seconds\n\n', t6);
