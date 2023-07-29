% Load ECG data
load('100m.mat');
fs = 1000; % Sampling frequency

% Filter the signal
[b,a] = butter(5, [0.5, 30]/(fs/2), 'bandpass');
ecg_filtered = filtfilt(b, a, ecg);

% Detect QRS complex
[qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg_filtered,fs,0);

% Calculate heart rate
rr = diff(qrs_i_raw);
hr = 60*fs./rr;

% Identify arrhythmias
arrhythmia = false(1,length(hr));
arrhythmia(hr<50) = true; % Bradycardia
arrhythmia(hr>100) = true; % Tachycardia
arrhythmia(diff(rr)./fs > 0.16) = true; % Premature Ventricular Contractions



function [qrs_amp_raw,qrs_i_raw,delay]=pan_tompkin(ecg,fs,flag)

% Default parameters
if nargin < 3
    flag = 0;
end

if nargin < 2
    fs = 200;
end

if nargin < 1
    error('Please input ECG signal');
end

if size(ecg,1) > size(ecg,2)
    ecg = ecg';
end

% Filter ECG signal
f1=5;f2=15;          % bandpass filter 5Hz to 15Hz
Wn=[f1 f2]/(fs/2);
N=3;
[a,b]=butter(N,Wn);
ecg_f=filtfilt(a,b,ecg);

% Differentiate and square the signal
ecg_diff = diff(ecg_f);
ecg_sq = ecg_diff .^ 2;

% Moving window integration
window_length = round(0.15 * fs); % window length is 150ms
a = 1;
b = ones(1, window_length) / window_length;
ecg_int = filter(b, a, ecg_sq);

% Find R-peaks
th = 0.5 * std(ecg_int);
[pks, locs] = findpeaks(ecg_int, 'MINPEAKHEIGHT', th, 'MINPEAKDISTANCE', 0.3 * fs);

% Calculate RR intervals
rr = diff(locs) / fs;

% Remove R-peaks too close to each other
rm_idx = find(rr < 0.6 * mean(rr));
locs(rm_idx + 1) = [];
pks(rm_idx + 1) = [];

% Remove first peak if it is within 0.5s of the start of the signal
if locs(1) < 0.5 * fs
    locs(1) = [];
    pks(1) = [];
end

% Remove last peak if it is within 0.5s of the end of the signal
if locs(end) > length(ecg_int) - 0.5 * fs
    locs(end) = [];
    pks(end) = [];
end

% Output raw QRS peaks and their corresponding indexes
qrs_amp_raw = pks;
qrs_i_raw = locs;

% Correction delay
delay = mean(rr) / 2;
if flag == 1
    figure
    subplot(2,1,1)
    plot(ecg)
    title('Original ECG signal')
    subplot(2,1,2)
    plot(ecg_int)
    hold on
    plot(locs, pks, 'ro')
    title('Integrated ECG signal with R-peaks marked')
end

end
