function options = fmrwhy_defaults_setupDerivDirs(bids_dir, options)

if nargin < 2
    options = struct;
end

% Derivatives directory structure
options.deriv_dir = fullfile(bids_dir, 'derivatives');
options.preproc_dir = fullfile(options.deriv_dir, 'fmrwhy-preproc');
options.qc_dir = fullfile(options.deriv_dir, 'fmrwhy-qc');
options.stats_dir = fullfile(options.deriv_dir, 'fmrwhy-stats');
% If the fMRwhy directories do not exist, create them
dirs = {options.preproc_dir, options.qc_dir, options.stats_dir};
for i = 1:numel(dirs)
    if ~exist(dirs{i}, 'dir')
        mkdir(dirs{i});
    end
end

