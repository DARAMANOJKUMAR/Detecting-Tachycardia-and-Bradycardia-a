% Load the ECG signal
load('100m.mat');

% Define the sampling frequency
fs = 360;

% Define the time axis
t = (0:numel(val)-1)./fs;

%% Step 1: Filter the ECG signal using a bandpass filter
% Define the filter parameters
fc_low = 5;
fc_high = 15;
order = 2;

% Design the filter
[b, a] = butter(order, [fc_low, fc_high]./(fs/2));

% Filter the ECG signal
ecg_filt = filtfilt(b, a, val);

%% Step 2: Differentiate the filtered signal
% Define the filter coefficients for differentiation
diff_order = 1;
diff_coeffs = [1 -1];

% Apply the differentiation filter
ecg_diff = filtfilt(diff_coeffs, 1, ecg_filt);

%% Step 3: Square the differentiated signal
% Square the differentiated ECG signal
ecg_square = ecg_diff.^2;

%% Step 4: Perform moving window integration
% Define the size of the moving window for integration
w_size = round(0.150*fs);

% Compute the moving window average
mwa = movmean(ecg_square, w_size);

% Define the searchback window size
w_h = round(0.2*fs);

% Define the searchback threshold
searchback_threshold = 0.6;

% Initialize arrays to store the QRS amplitude and location
qrs_amp_raw = [];
qrs_i_raw = [];

% Initialize variables to store the delay between the filtered and detected QRS complexes
last_qrs_i = 0;
last_delay = 0;

% Loop through the ECG signal
for i = 1:numel(mwa)
    % Check that the index is not negative
    if i > w_h
        % Find the maximum of the moving window average in the searchback window
        [pk, locs] = findpeaks(mwa(i-w_h:i), 'MinPeakHeight', searchback_threshold*max(mwa(i-w_h:i)));
        if ~isempty(pk)
            % Find the location of the maximum peak in the searchback window
            [~, index] = max(pk);
            % Update the location to the index in the original signal
            locs = locs(index)+i-w_h-1;
            % Check that the location is after the last detected QRS complex
            if locs > last_qrs_i
                % Store the QRS amplitude and location
                qrs_amp_raw = [qrs_amp_raw pk(index)];
                qrs_i_raw = [qrs_i_raw locs];
                % Compute the delay between the filtered and detected QRS complexes
                delay = qrs_i_raw(end)-last_qrs_i;
                % Store the delay
                last_delay = delay;
                % Store the location of the last detected QRS complex
                last_qrs_i = qrs_i_raw(end);
            end
        end
    end
end

%% Step 5: Plot the detected QRS complexes on top of the ECG signal
% Scale the ECG signal for plotting purposes
ecg_plot = val./max(val);

figure;
plot(t, ecg_plot);
hold on;
stem(qrs_i_raw./fs, ecg_plot(qrs_i_raw), 'r', 'LineWidth', 2);
title('Detected QRS complexes using Pan-Tompkins algorithm');
xlabel('Time (s)');
ylabel('Normalized ECG amplitude');
legend('ECG signal', 'Detected QRS complexes');
%% Step 6: Classify heartbeats using detected QRS complexes
% Compute RR intervals
rr_int = diff(qrs_i_raw)./fs;
fprintf("Length of t vector: %d\n", length(t));
fprintf("Length of normal_rr vector: %d\n", length(normal_rr));

% Classify heartbeats using RR intervals
% Normal: RR intervals between 0.6 and 1.2 seconds
% Bradycardia: RR intervals greater than 1.2 seconds
% Tachycardia: RR intervals less than 0.6 seconds
normal_rr = rr_int >= 0.6 & rr_int <= 1.2;
brady_rr = rr_int > 1.2;
tachy_rr = rr_int < 0.6;

% Pad the classification vectors with a zero to match the length of the time vector
normal_rr = padarray(normal_rr, [0 1], 0, 'post');
brady_rr = padarray(brady_rr, [0 1], 0, 'post');
tachy_rr = padarray(tachy_rr, [0 1], 0, 'post');
figure;
t = t(1:length(normal_rr));
plot(t, normal_rr, 'g', 'LineWidth', 2);
plot(t, brady_rr, 'm', 'LineWidth', 2);
plot(t, tachy_rr, 'r', 'LineWidth', 2);
