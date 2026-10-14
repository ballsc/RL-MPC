
%% Reinforcement Learning Training Script
numWorkers = 8;

if isempty(gcp('nocreate'))
    parpool('local', numWorkers);
end

% Check that agent and environment exist
assert(exist('a','var') == 1, 'Agent "a" is not defined.');
assert(exist('env','var') == 1, 'Environment "env" is not defined.');

%% Training Options
trainOpts = rlTrainingOptions( ...
    'MaxEpisodes', 1500, ...
    'MaxStepsPerEpisode', 1000, ...
    'ScoreAveragingWindowLength', 20, ...
    'StopTrainingCriteria', 'AverageReward', ...
    'StopTrainingValue', 50, ...
    'Verbose', true, ...
    'Plots', 'training-progress');

trainOpts.UseParallel = true;
trainOpts.ParallelizationOptions.Mode = 'async';

%% Start Training
trainingStats = train(a, env, trainOpts);

%% Save Trained Agent
delete(gcp('nocreate'));
% Use a unique filename for each training run
filename = ['trainedAgent_' ...
    datestr(now, 'yyyymmdd_HHMMSS') '.mat'];

% Save using MAT-file v7.3
save(filename, 'a', 'trainingStats', '-v7.3');

fprintf('Agent saved to: %s\n', filename);

disp('Training complete. Agent saved.');
