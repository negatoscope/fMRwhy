% A custom workflow that runs 1st level analysis for all runs of all tasks of specified subjects

% Code steps:
% 1.


%--------------------------------------------------------------------------


% -------
% STEP 0.1 -- Load defaults, filenames and parameters
% -------

% Load fMRwhy defaults
options = fmrwhy_defaults;

% Main input: BIDS root folder
bids_dir = '/Users/jheunis/Desktop/sample-data/NEUFEPME_data_BIDS';

% Setup fmrwhy BIDS-derivatuve directories on workflow level
options = fmrwhy_defaults_setupDerivDirs(bids_dir, options);

% Grab parameters from workflow settings file
options = fmrwhy_settings_preprocQC(bids_dir, options);

% Loop through subjects, sessions, tasks, runs, etc
subs = {'001'};
%sub = '002';
ses = '';


for s = 1:numel(subs)
    sub = subs{s};
    % Setup fmrwhy bids directories on subject level (this copies data from bids_dir)
    options = fmrwhy_defaults_setupSubDirs(bids_dir, sub, options);

    % Update workflow params with subject anatomical derivative filenames
    options = fmrwhy_defaults_subAnat(bids_dir, sub, options);

    % -------
    % PER TASK and RUN
    % -------
    % Loop through sessions, tasks, runs, echoes.
    ses = '';
    tasks = {'motor', 'emotion'};
    runs = {'1', '2'};

    for t = 1:numel(tasks)
        task = tasks{t};
        for r = 1:numel(runs)
            run = runs{r};

            % -------
            % STEP 1 -- 1st level analysis for a single run
            % -------
            fmrwhy_workflow_1stlevelRun(bids_dir, sub, ses, task, run, options.template_echo, options)

%            % -------
%            % STEP 2 --
%            % -------
%            output = fmrwhy_util_createOverlayMontageColormap(template_img, overlay_img, columns, rotate, str, clrmp, visibility, shape, cxs, overlay_clrmp, saveAs_fn)

        end
    end

%    % -------
%    % STEP 3 -- 1st level report
%    % -------
%    fmrwhy_neufep_generateSubReport(bids_dir, sub);

end