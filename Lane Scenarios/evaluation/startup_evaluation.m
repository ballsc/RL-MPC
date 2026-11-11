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
FULL_MODEL = 'SAC_MPC_angle';
REDUCED_MODEL = 'SAC_MPC_angle_reduced';

models = {FULL_MODEL, REDUCED_MODEL};

scenarios = {@oval, @straight_left, @straight_left_multi ...
    @straight_right, @straight_right_multi};

[scenario, road_length] = scenarios{scenario_idx(1)}();
initialVehicleVelocity = 8.9; %m/s -> 25mph

% find initial position and pose of vehicle
initialPosition = scenario.Actors(scenario_idx(2)).Position;
initialYaw = scenario.Actors(scenario_idx(2)).Yaw;

% find time to reach end of road
max_time = road_length/initialVehicleVelocity;

% define output data structure
out_struct = struct('swAngleDeg', [], ...
                    'lateralJerk', [], ...
                    'lateralAcceleration', [], ...
                    'midOffset', []);

out_data = repmat(out_struct, num_eval, numel(models));

% Gather information from simulations
for i = 1:num_eval
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
        out_data(i, j).swAngleDeg = squeeze(find(out, 'swAngleDeg').Values.Data);
        out_data(i, j).lateralJerk = squeeze(find(out, 'lateralJerk').Values.Data);
        out_data(i, j).lateralAcceleration = squeeze(find(out, 'lateralAcceleration').Values.Data);
        out_data(i, j).midOffset = squeeze(find(out, 'midOffset').Values.Data);
    end
end

jpsp = psp(out_data);