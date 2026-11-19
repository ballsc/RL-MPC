
%% Reinforcement Learning Training Script

numWorkers = 8;

%% Check Agent and Load Environment
assert(exist('a','var') == 1, ...
    'Agent "a" is not defined.');

if size(a.ActionInfo.Dimension, 2) == 2
    load("RL_Environments\reduced_env.mat");
elseif size(a.ActionInfo.Dimension, 2) == 4
    load("RL_Environments\full_env.mat");
else
    assert(exist('env','var') == 1, ...
        'Environment "env" is not defined.');
end

%% GPU Configuration
% if gpuDeviceCount("available") > 0
% 
%     gpu = gpuDevice;
% 
%     fprintf('GPU detected: %s\n', gpu.Name);
%     fprintf('GPU memory: %.2f GB\n', ...
%         gpu.TotalMemory / 1e9);
% 
%     % Enable GPU for neural network learning
%     a.UseGPUForLearning = "on";
% 
%     disp('GPU acceleration enabled.');
% 
% else
% 
%     warning('No compatible GPU detected. Using CPU.');
%     a.UseGPUForLearning = "off";
% 
% end

%% Initialize Parallel Workers
pool = gcp('nocreate');

if isempty(pool)
    parpool('local', numWorkers);
elseif pool.NumWorkers ~= numWorkers
    delete(pool);
    parpool('local', numWorkers);
end

%% Training Options
trainOpts = rlTrainingOptions( ...
    'MaxEpisodes', 500, ...
    'MaxStepsPerEpisode', 8000, ...
    'ScoreAveragingWindowLength', 10, ...
    'StopTrainingCriteria', 'AverageSteps', ...
    'StopTrainingValue', 3000, ...
    'Verbose', true, ...
    'Plots', 'training-progress');

% Parallel environment simulations
trainOpts.UseParallel = "on";

% Asynchronous experience collection
trainOpts.ParallelizationOptions.Mode = "async";

%% Start Training
start = tic();
[~] = train(a, env, trainOpts);
toc(start)

%% Save Trained Agent
% Close parallel workers
delete(gcp('nocreate'));

% Unique filename
filename = ['trainedAgent_' ...
    datestr(now, 'yyyymmdd_HHMMSS') '.mat'];

a.UseGPUForLearning = "off";

% Save using MAT-file v7.3
save(filename, 'a', '-v7.3');

fprintf('Agent saved to: %s\n', filename);

disp('Training complete. Agent saved.');
