function modified_result = saveTrain(rl_results)

    % Values to keep from rlTrainingResult object
    keeps = {'EpisodeIndex', 'AverageReward', 'AverageSteps', 'TotalAgentSteps', ...
              'EpisodeQ0', 'EpisodeSteps', 'EpisodeReward'};
    
    for i = 1:numel(keeps)
        modified_result.(keeps{i}) = rl_results.(keeps{i});
    end

end