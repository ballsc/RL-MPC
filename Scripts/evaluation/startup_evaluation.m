% Script to evaluate SAC-MPC systems. Must select scenario to use and how
% many times the evaluation should run.

%% Select Scenario to use
%   1. Oval scenario turning right / oval scenario turning left
%   2. Straight into left / right into straight
%   3. Straight into multi-left / multi-left into straight
%   4. Straight into right / left into straight
%   5. Straight into multi-right / multi-right into straight

scenario_idx = [1 1]; % 1-5 then 1-2
num_eval = 10;
FULL_MODEL = 'SAC_MPC_angle_policy';
REDUCED_MODEL = 'SAC_MPC_angle_reduced_policy';
DEFAULT_MODEL = 'MPC_only';

max_position_noise = 1; %m
max_angle_noise = 10; %deg

initialVehicleVelocity = 8.9; %m/s -> 25mph

models = {FULL_MODEL, REDUCED_MODEL, DEFAULT_MODEL};

scenarios = {@oval, @straight_left, @straight_left_multi ...
    @straight_right, @straight_right_multi};
for ii = 1:5
    for jj = 1:2
        scenario_idx = [ii jj]; % 1-5 then 1-2
        [scenario, road_length] = scenarios{scenario_idx(1)}();
        
        out_data = run_eval_sim(scenario, road_length, models, initialVehicleVelocity, ...
                                max_position_noise, max_angle_noise, num_eval, ...
                                scenario_idx);
        
        jpsp = zeros(size(out_data));
        
        for i = 1:size(out_data, 1)
            for j = 1:size(out_data, 2)
                jpsp(i, j) = psp(out_data(i, j));
            end
        end
        
        for i = 1:numel(models)
            jpsp_avg(i) = mean(jpsp(:, i));
        end
        
        filename = ['evaluationScenario' sprintf('[%d,%d]', scenario_idx(1), scenario_idx(2)) ...
            datestr(now, 'yyyymmdd_HHMMSS') '.mat'];
        
        % Save using MAT-file v7.3
        save(filename, 'jpsp_avg', 'out_data', '-v7.3');
        
        % clearvars -except BusActorPose jpsp out_data jpsp_avg
        clear filename out_data jpsp jpsp_avg
    end
end

clearvars -except BusActorPose

function out_data = run_eval_sim(scenario, road_length, models, initialVehicleVelocity, ...
                                  max_position_noise, max_angle_noise, num_eval, ...
                                  scenario_idx)
    % find initial position and pose of vehicle
    initialPosition = scenario.Actors(scenario_idx(2)).Position;
    initialAngle = scenario.Actors(scenario_idx(2)).Yaw;
    
    % find time to reach end of road
    max_time = road_length/initialVehicleVelocity;
    
    % define output data structure
    out_struct = struct('swAngleDeg', [], ...
                        'lateralJerk', [], ...
                        'lateralAcceleration', [], ...
                        'midOffset', []);
    
    out_data = repmat(out_struct, num_eval, numel(models));
    % num_eval X numel(models) size struct array with out from each eval
    
    % Gather information from simulations
    for i = 1:num_eval
        % add noise to initial position/angle
        % position noise between -max_pos and max_pos units
        position_noise = [2*max_position_noise*rand - max_position_noise, ...
            2*max_position_noise*rand - max_position_noise, 0];
        initialPosition = initialPosition + position_noise;
        % angle noise between -max_angle_noise and max_angle_noise degrees
        angle_noise = 2*max_angle_noise*rand - max_angle_noise;
        initialAngle = initialAngle + angle_noise;

        for j = 1:numel(models)
            % Set initial model values
            mdl = models{j};
            in = Simulink.SimulationInput(mdl);
            in = setVariable(in, "max_time", max_time, Workspace=mdl);
            in = setVariable(in, "initialPosition", initialPosition, Workspace=mdl);
            in = setVariable(in, "initialAngle", initialAngle, Workspace="Plant_angle");
            in = setVariable(in, "scenario", scenario, Workspace=mdl);
            in = setVariable(in, "initialVehicleVelocity", initialVehicleVelocity, Workspace=mdl);
            in = setVariable(in, "initialVehicleVelocity", initialVehicleVelocity, Workspace="Plant_angle");
            in = setVariable(in, "simStepSize", 0.05, Workspace=mdl);
            in = setVariable(in, "simStepSize", 0.05, Workspace="Plant_angle");
    
            % simulate system
            out = sim(in);
    
            % gather required output data
            out_data(i, j).swAngleDeg = squeeze(find(out.logsout, 'swAngleDeg').Values.Data);
            out_data(i, j).lateralJerk = squeeze(find(out.logsout, 'lateralJerk').Values.Data);
            out_data(i, j).lateralAcceleration = squeeze(find(out.logsout, 'lateralAcceleration').Values.Data);
            out_data(i, j).midOffset = squeeze(find(out.logsout, 'midOffset').Values.Data);
        end
    end
end

