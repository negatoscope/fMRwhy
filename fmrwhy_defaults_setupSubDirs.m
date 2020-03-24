function options = fmrwhy_defaults_setupSubDirs(bids_dir, sub, options)

if isempty(options)
    options = struct;
end

% Derivatives directories
options.deriv_dir = fullfile(bids_dir, 'derivatives');
options.preproc_dir = fullfile(options.deriv_dir, 'fmrwhy-preproc');
options.qc_dir = fullfile(options.deriv_dir, 'fmrwhy-qc');
options.stats_dir = fullfile(options.deriv_dir, 'fmrwhy-stats');

% Subject directories
options.sub_dir_preproc = fullfile(options.preproc_dir, ['sub-' sub]);
options.sub_dir_qc = fullfile(options.qc_dir, ['sub-' sub]);
options.sub_dir_stats = fullfile(options.stats_dir, ['sub-' sub]);
options.sub_dir_BIDS = fullfile(bids_dir, ['sub-' sub]);

% Create and copy content, if necessary
if ~exist(options.sub_dir_preproc, 'dir')
    mkdir(options.sub_dir_preproc)
    copyfile(sub_dir_BIDS, options.sub_dir_preproc)
end
if ~exist(options.sub_dir_qc, 'dir')
    mkdir(options.sub_dir_qc)
end
if ~exist(options.sub_dir_stats, 'dir')
    mkdir(options.sub_dir_stats)
end