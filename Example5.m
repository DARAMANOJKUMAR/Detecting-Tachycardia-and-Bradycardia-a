%Time-domain analysis: In this method, the RR interval between successive QRS complexes is analyzed.
%Abnormalities in the RR interval can indicate arrhythmia.
%The following MATLAB code detects arrhythmia using time-domain analysis:
% Load ECG data
load('100m.mat');

% Detect RR intervals
[~,locs_Rwave] = findpeaks(val);

% Calculate RR intervals
RRintervals = diff(locs_Rwave);

% Detect arrhythmia using threshold
meanRR = mean(RRintervals);
deviation = std(RRintervals);
threshold = meanRR + 2*deviation;
arrhythmia = find(RRintervals > threshold);

% Plot ECG data with arrhythmia detected
figure;
plot(val);
hold on;
plot(locs_Rwave(arrhythmia+1),val(locs_Rwave(arrhythmia+1)),'ro');
title('ECG with Arrhythmia Detected');
xlabel('Sample Number');
ylabel('ECG Signal');
