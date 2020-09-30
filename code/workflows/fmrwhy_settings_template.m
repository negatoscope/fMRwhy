% fmrwhy_settings_template: Settings for the fmrwhy_workflow_qc pipeline



% Main input: BIDS root folder
bids_dir = '/Volumes/TSM/NEUFEPME_data_BIDS';

% fMRwhy toolbox root directory
current_path = mfilename('fullpath');
ind = strfind(current_path,'fMRwhy');
options.fmrwhy_dir = current_path(1:ind+5);

% SPM directory
options.spm_dir = '/Users/jheunis/Documents/MATLAB/spm12';

% Setup fmrwhy BIDS-derivatuve directories on workflow level
options = fmrwhy_defaults_setupQcDerivDirs(bids_dir, options);

% BIDS structure values
options.bids_dataset = bids.layout(bids_dir);
options.subjects = bids.query(options.bids_dataset,'subjects');
options.sessions = bids.query(options.bids_dataset,'sessions');
options.runs = bids.query(options.bids_dataset,'runs');
options.tasks = bids.query(options.bids_dataset,'tasks');
options.types = bids.query(options.bids_dataset,'types');
options.modalities = bids.query(options.bids_dataset,'modalities');

% Set template for functional realignment purposes (if not needed, set to [])
sample_sub = options.subjects{1};
options.template_task = 'rest';
options.template_session = [];
options.template_run = '1';
options.template_echo = '2';

% Derive template flags from BIDS structure
options.has_sessions = ~isempty(options.sessions);
options.has_runs = ~isempty(options.runs);
if options.has_sessions
    if options.has_runs
        filenames = bids.query(options.bids_dataset, 'data', 'sub', sample_sub, 'task', options.template_task, 'sess', options.template_session, 'run', options.template_run, 'type', 'bold');
    else
        filenames = bids.query(options.bids_dataset, 'data', 'sub', sample_sub, 'task', options.template_task, 'sess', options.template_session, 'type', 'bold');
    end
else
    if options.has_runs
        filenames = bids.query(options.bids_dataset, 'data', 'sub', sample_sub, 'task', options.template_task, 'run', options.template_run, 'type', 'bold');
    else
        filenames = bids.query(options.bids_dataset, 'data', 'sub', sample_sub, 'task', options.template_task, 'type', 'bold');
    end
end
options.N_echoes = numel(filenames);
options.is_multiecho = false;
if options.N_echoes > 1
    options.is_multiecho = true;
end

% Sequence parameters
options.TR = 2;
options.N_slices = 34;
options.Ndummies = 5;
options.Nscans = 210;
options.TE = [14 28 42]; % assume for all functional runs
options.Ne = numel(options.TE);

if options.is_multiecho
    if options.N_echoes ~= options.Ne
        disp('ERROR: number of echoes derived from BIDS dataset (using bids-matlab) do not match the number of echo times specified in settings file. FIX!')
    end
end

% Dataset parameters
options.Nsessions = numel(options.sessions);
%options.tasks = {'rest', 'motor', 'emotion'};
options.Ntasks = numel(options.tasks);
%options.runs = {'1', '2'};
options.Nruns = numel(options.runs);

% Settings for structFunc processing

% Settings for anatLocaliser processing
options.map_rois = 1;
%options.roi_orig_dir = '/Volumes/Stephan_WD/NEUFEPME_data_templates';
options.roi_orig_dir = '/Users/jheunis/Desktop/sample-data/NEUFEPME_data_templates';
options.roi = struct;
% IMPORTANT: structure has to be named using the task name as in options.tasks: options.roi.(task).orig_fn
options.roi.motor.orig_fn = {fullfile(options.roi_orig_dir, 'Left_Motor_4a_4p.nii'),
                                fullfile(options.roi_orig_dir, 'Right_Motor_4a_4p.nii')}; % Raw ROI filenames

options.roi.motor.name = {'Left Motor', 'Right Motor'}; % For plots and strings
options.roi.motor.desc = {'leftMotor', 'rightMotor'}; % For BIDS file naming (after normalisation  to functional space)

options.roi.emotion.orig_fn = {fullfile(options.roi_orig_dir, 'Bilateral_Amygdala_allregions.nii'),
                                fullfile(options.roi_orig_dir, 'Left_Amygdala_allregions.nii'),
                                fullfile(options.roi_orig_dir, 'Right_Amygdala_allregions.nii')}; % Raw ROI filenames

options.roi.emotion.name = {'Bilateral Amygdala', 'Left Amygdala', 'Right Amygdala'}; % For plots and strings
options.roi.emotion.desc = {'bilateralAmygdala', 'leftAmygdala', 'rightAmygdala'}; % For BIDS file naming (after normalisation  to functional space)

%options.roi.(task).roi_fn = ROIs in subject space (not resliced)
%options.roi.(task).rroi_fn = resliced ROIs in subject space


% Settings for basicFunc processing
options.fwhm = 7;

% Settings for generateMultRegr routine
options.confounds.include_volterra = 1;
options.confounds.include_fd = 1;
options.confounds.include_tissue = 1;
options.confounds.include_physio = 1;

% generateMultRegr: framewise displacement
options.r = 50; % mm
options.FD_threshold = 0; % set as 0 to calculate with both standard thresholds 0.2 and 0.5 mm.

% generateMultRegr: PhysIO
options.physio.options.cardiac_fn = '';
options.physio.options.respiration_fn = '';
options.physio.options.vendor = 'BIDS';
options.physio.options.sampling_interval = 0.002; % 500 Hz ==> Philips wired acquisition
options.physio.options.align_scan = 'last';
options.physio.options.Nslices = options.N_slices;
options.physio.options.TR = options.TR; % in seconds
options.physio.options.Ndummies = options.Ndummies; % include, even if these are not included in the fMRI timeseries data exported from the scanner
options.physio.options.Nscans = options.Nscans;
options.physio.options.onset_slice = 1;
options.physio.options.cardiac_modality = 'PPU';
options.physio.options.output_multiple_regressors_fn = 'PhysIO_multiple_regressors.txt'; % text file name
options.physio.options.level = 0; % verbose.level = 0 ==> do not generate figure outputs
options.physio.options.fig_output_file = ''; % unnecessary if verbose.level = 0, but still initialized here


% Settings for QC
options.theplot.intensity_scale = [-6 6];
options.qc_overwrite_tissuecontours = true;
options.qc_overwrite_ROIcontours = true;
options.qc_overwrite_theplot = false;
options.qc_overwrite_statsoutput = true;


% Settings for first level analysis: steps to include/exclude
options.firstlevel.tmap_montages = true;
options.firstlevel.anat_func_roi = true;

% Settings for first level analysis: task-motor
options.firstlevel.motor.run1.sess_params.timing_units = 'secs';
options.firstlevel.motor.run1.sess_params.timing_RT = 2;
options.firstlevel.motor.run1.sess_params.cond_names = {'FingerTapping'};
options.firstlevel.motor.run2.sess_params.timing_units = 'secs';
options.firstlevel.motor.run2.sess_params.timing_RT = 2;
options.firstlevel.motor.run2.sess_params.cond_names = {'MentalFingerTapping'};

% Settings for first level analysis: task-emotion
options.firstlevel.emotion.run1.sess_params.timing_units = 'secs';
options.firstlevel.emotion.run1.sess_params.timing_RT = 2;
options.firstlevel.emotion.run1.sess_params.cond_names = {'Faces', 'Shapes'};
options.firstlevel.emotion.run2.sess_params.timing_units = 'secs';
options.firstlevel.emotion.run2.sess_params.timing_RT = 2;
options.firstlevel.emotion.run2.sess_params.cond_names = {'MentalEmotion'};

% Settings for plotting task conditions
onset = [11; 31; 51; 71; 91; 111; 131; 151; 171; 191];
duration = [10; 10; 10; 10; 10; 10; 10; 10; 10; 10];
options.firstlevel.motor.run1.plot_params.cond_onset = onset;
options.firstlevel.motor.run1.plot_params.cond_duration = duration;
options.firstlevel.motor.run2.plot_params.cond_onset = onset;
options.firstlevel.motor.run2.plot_params.cond_duration = duration;
options.firstlevel.emotion.run2.plot_params.cond_onset = onset;
options.firstlevel.emotion.run2.plot_params.cond_duration = duration;
onset = [12; 32; 52; 72; 92; 112; 132; 152; 172; 192];
duration = [9; 9; 9; 9; 9; 9; 9; 9; 9; 9];
options.firstlevel.emotion.run1.plot_params.cond_onset = onset;
options.firstlevel.emotion.run1.plot_params.cond_duration = duration;

% Settings for first level analysis: glm regressors to include
options.firstlevel.glm_regressors.trans_rot = true;
options.firstlevel.glm_regressors.trans_rot_derivative1 = true;
options.firstlevel.glm_regressors.trans_rot_power2 = false;
options.firstlevel.glm_regressors.trans_rot_derivative1_power2 = false;
options.firstlevel.glm_regressors.framewise_displacement_censor02 = false;
options.firstlevel.glm_regressors.framewise_displacement_censor05 = false;
options.firstlevel.glm_regressors.dvars_censor = false; % not yet implemented
options.firstlevel.glm_regressors.std_dvars_censor = false; % not yet implemented
options.firstlevel.glm_regressors.grey_matter = false;
options.firstlevel.glm_regressors.white_matter = false;
options.firstlevel.glm_regressors.csf = true;
options.firstlevel.glm_regressors.global_signal = false;
% Order of included retroicor regressors; if 0 ==> exclude
options.firstlevel.glm_regressors.retroicor_c = 2; % cardiac, max 6
options.firstlevel.glm_regressors.retroicor_r = 2; % respiratory, max 8
options.firstlevel.glm_regressors.retroicor_cxr = 0; % interaction, max 4
options.firstlevel.glm_regressors.hrv = false;
options.firstlevel.glm_regressors.rvt = false;


% Settings for first level analysis: task-motor
options.firstlevel.motor.run1.contrast_params.consess{1}.tcon.name = 'FingerTapping';
options.firstlevel.motor.run1.contrast_params.consess{1}.tcon.weights = [1];
options.firstlevel.motor.run1.contrast_params.consess{1}.tcon.sessrep = 'none';
options.firstlevel.motor.run2.contrast_params.consess{1}.tcon.name = 'MentalFingerTapping';
options.firstlevel.motor.run2.contrast_params.consess{1}.tcon.weights = [1];
options.firstlevel.motor.run2.contrast_params.consess{1}.tcon.sessrep = 'none';

% Settings for first level analysis: task-emotion
options.firstlevel.emotion.run1.contrast_params.consess{1}.tcon.name = 'Faces';
options.firstlevel.emotion.run1.contrast_params.consess{1}.tcon.weights = [1 0];
options.firstlevel.emotion.run1.contrast_params.consess{1}.tcon.sessrep = 'none';
options.firstlevel.emotion.run1.contrast_params.consess{2}.tcon.name = 'Shapes';
options.firstlevel.emotion.run1.contrast_params.consess{2}.tcon.weights = [0 1];
options.firstlevel.emotion.run1.contrast_params.consess{2}.tcon.sessrep = 'none';
options.firstlevel.emotion.run1.contrast_params.consess{3}.tcon.name = 'Faces>Shapes';
options.firstlevel.emotion.run1.contrast_params.consess{3}.tcon.weights = [1 -1];
options.firstlevel.emotion.run1.contrast_params.consess{3}.tcon.sessrep = 'none';
options.firstlevel.emotion.run2.contrast_params.consess{1}.tcon.name = 'MentalEmotion';
options.firstlevel.emotion.run2.contrast_params.consess{1}.tcon.weights = [1];
options.firstlevel.emotion.run2.contrast_params.consess{1}.tcon.sessrep = 'none';

%matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'Patients > Control';
%matlabbatch{1}.spm.stats.con.consess{2}.tcon.convec = [-1 1];
%matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';