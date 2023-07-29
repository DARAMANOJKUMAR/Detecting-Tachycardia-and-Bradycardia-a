% Load data
load('100m.mat');

% Get annotation information
ann = wfdb.rdann('ecg', 'atr');

% Check if 'ann' is a non-empty cell array
if ~isempty(ann)
    % Convert annotation labels to cell array of strings
    ann_labels = cellstr(ann.anntype);
    
    % Print the first 10 annotation labels
    disp(ann_labels(1:10));
else
    error('Annotation data is empty!');
end
