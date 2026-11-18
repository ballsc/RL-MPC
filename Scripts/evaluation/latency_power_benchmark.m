%% Benchmark full vs reduced SAC-MPC in Simulink
% Set the model names and (optionally) logged controller timing signal below.
% Run this script from the RL-MPC repository root after required setup.
%
% Measures:
%   1) Total wall-clock simulation time
%   2) Approx. wall-clock time / simulated control step (NOT controller latency)
%   3) True per-step controller latency IF logged by the model
%
% IMPORTANT: Power values supplied here are NOT hardware measurements.
% MATLAB/Simulink alone does not determine computer electrical power.

%% -------------------- USER CONFIGURATION ------------------------------
cfg.fullModel    = 'SAC_MPC_angle_policy';
cfg.reducedModel = 'SAC_MPC_angle_reduced_policy';
cfg.defaultModel = 'MPC_only';
cfg.stopTime     = 100;                  % simulated seconds
cfg.Ts           = 0.05;                 % controller sample time [s]
cfg.repetitions  = 10;                   % timed runs per controller
cfg.warmups      = 1;                    % untimed runs per controller
cfg.outputDir    = 'benchmark_results';

% Optional: log true controller execution time at every sample from a
% timing instrument around the complete controller (SAC inference + MPC).
% Set to '' to skip. Signal MUST be logged to logsout as a timeseries.
cfg.latencySignal = '';                  % e.g. 'controller_exec_time'
cfg.latencyUnit   = 's';                 % 's' or 'ms'

% Scenario for evaluation
[scenario, road_length] = oval();

% ----------------------------------------------------------------------

assert(cfg.Ts > 0 && cfg.stopTime > 0 && cfg.repetitions >= 1);
assert(ismember(cfg.latencyUnit, {'s','ms'}));
assert(~strcmp(cfg.fullModel,'FULL_MODEL_NAME') && ...
       ~strcmp(cfg.reducedModel,'REDUCED_MODEL_NAME'), ...
       'Set cfg.fullModel and cfg.reducedModel to actual Simulink model names.');

if ~isfolder(cfg.outputDir), mkdir(cfg.outputDir); end
models = {cfg.defaultModel, cfg.reducedModel};
labels = {'Full SAC-MPC','Reduced SAC-MPC'};

numModels = numel(models);

for j = 1:numModels
    assert(bdIsLoaded(models{j}) || ~isempty(which([models{j},'.slx'])) || ...
           ~isempty(which([models{j},'.mdl'])), ...
           'Cannot locate model: %s',models{j});
    load_system(models{j});
end

% Run each model once before timing to reduce first-run initialization bias.
for k = 1:cfg.warmups
    [max_time, initialPosition, initialAngle, initialVehicleVelocity] = loadStart(scenario, road_length);
    for j = 1:numModels
        fprintf('Warmup %d/%d: %s\n', ...
            k, cfg.warmups, labels{j});

        in = Simulink.SimulationInput(models{j});
        mdl = models{j};
        
        in = in.setModelParameter( ...
            'StopTime', num2str(cfg.stopTime), ...
            'SimulationMode', 'normal');
        in = setVariable(in, "max_time", max_time, Workspace=mdl);
        in = setVariable(in, "initialPosition", initialPosition, Workspace=mdl);
        in = setVariable(in, "initialAngle", initialAngle, Workspace="Plant_angle");
        in = setVariable(in, "scenario", scenario, Workspace=mdl);
        in = setVariable(in, "initialVehicleVelocity", initialVehicleVelocity, Workspace=mdl);
        in = setVariable(in, "initialVehicleVelocity", initialVehicleVelocity, Workspace="Plant_angle");
        in = setVariable(in, "simStepSize", 0.05, Workspace=mdl);
        in = setVariable(in, "simStepSize", 0.05, Workspace="Plant_angle");

        sim(in);
    end
end

% Alternate run order to reduce systematic temperature / clock bias.
N = numModels * cfg.repetitions;

Model = strings(N,1);
Run = zeros(N,1);
WallTime_s = nan(N,1);
ControlSteps = nan(N,1);
WallTimePerStep_ms = nan(N,1);

ControllerMean_ms = nan(N,1);
ControllerPeak_ms = nan(N,1);
ControllerP95_ms = nan(N,1);

% Base model execution order
baseOrder = 1:numModels;

r = 0;

for k = 1:cfg.repetitions

    % Rotate the starting model each repetition
    shift = mod(k-1, numModels);

    order = circshift(baseOrder, [0, -shift]);

    fprintf('\nRepetition %d/%d\n', k, cfg.repetitions);
    fprintf('Execution order: %s\n', ...
        strjoin(labels(order), ' -> '));

    % Generate starting variables
    [max_time, initialPosition, initialAngle, initialVehicleVelocity] = loadStart(scenario, road_length);

    for j = order

        r = r + 1;

        fprintf('Timed run %d/%d: %s\n', ...
            k, cfg.repetitions, labels{j});

        % Configure simulation
        in = Simulink.SimulationInput(models{j});
        mdl = models{j};

        in = in.setModelParameter( ...
            'StopTime', num2str(cfg.stopTime), ...
            'SimulationMode', 'normal');
        in = setVariable(in, "max_time", max_time, Workspace=mdl);
        in = setVariable(in, "initialPosition", initialPosition, Workspace=mdl);
        in = setVariable(in, "initialAngle", initialAngle, Workspace="Plant_angle");
        in = setVariable(in, "scenario", scenario, Workspace=mdl);
        in = setVariable(in, "initialVehicleVelocity", initialVehicleVelocity, Workspace=mdl);
        in = setVariable(in, "initialVehicleVelocity", initialVehicleVelocity, Workspace="Plant_angle");
        in = setVariable(in, "simStepSize", 0.05, Workspace=mdl);
        in = setVariable(in, "simStepSize", 0.05, Workspace="Plant_angle");

        % Measure wall-clock execution time
        t0 = tic;
        out = sim(in);
        elapsed = toc(t0);

        % Store results
        Model(r) = string(labels{j});
        Run(r) = k;
        WallTime_s(r) = elapsed;

        ControlSteps(r) = ceil(cfg.stopTime / cfg.Ts);

        WallTimePerStep_ms(r) = ...
            1e3 * elapsed / ControlSteps(r);

        % Optional controller latency measurements
        if ~isempty(cfg.latencySignal)

            lat = readLatency( ...
                out, cfg.latencySignal, cfg.latencyUnit);

            if ~isempty(lat)

                ControllerMean_ms(r) = mean(lat);
                ControllerPeak_ms(r) = max(lat);
                ControllerP95_ms(r) = prctile(lat, 95);

                ControlSteps(r) = numel(lat);

                WallTimePerStep_ms(r) = ...
                    1e3 * elapsed / ControlSteps(r);

            else
                warning( ...
                    'Latency signal "%s" not found for %s run %d.', ...
                    cfg.latencySignal, models{j}, k);
            end
        end
    end
end

runs = table(Model,Run,WallTime_s,ControlSteps,WallTimePerStep_ms, ...
    ControllerMean_ms,ControllerP95_ms,ControllerPeak_ms);

% Aggregate mean and standard deviation across repeated runs.
summary = table(strings(numModels,1),nan(numModels,1),nan(numModels,1),...
    nan(numModels,1),nan(numModels,1),nan(numModels,1),nan(numModels,1), ...
    'VariableNames',{'Model','WallMean_s','WallStd_s', ...
    'WallPerStepMean_ms','CtrlMean_ms','CtrlP95Mean_ms','CtrlPeakMax_ms'});

for j=1:numModels
    idx = Model == string(labels{j});
    summary.Model(j) = string(labels{j});
    summary.WallMean_s(j) = mean(WallTime_s(idx));
    summary.WallStd_s(j) = std(WallTime_s(idx));
    summary.WallPerStepMean_ms(j) = mean(WallTimePerStep_ms(idx));
    summary.CtrlMean_ms(j) = mean(ControllerMean_ms(idx),'omitnan');
    summary.CtrlP95Mean_ms(j) = mean(ControllerP95_ms(idx),'omitnan');
    summary.CtrlPeakMax_ms(j) = max(ControllerPeak_ms(idx),[],'omitnan');
end

disp('Individual benchmark runs:'); disp(runs);
disp('Summary (NaN = not measured):'); disp(summary);

wallReduction = 100 * (1 - summary.WallMean_s(2)/summary.WallMean_s(1));
fprintf('\nReduced vs full: simulation wall-time reduction = %.2f%%\n', wallReduction);
if all(isfinite(summary.CtrlMean_ms))
    ctrlReduction = 100 * (1-summary.CtrlMean_ms(2)/summary.CtrlMean_ms(1));
    fprintf('Controller latency reduction = %.2f%%\n', ctrlReduction);
else
    fprintf('Controller latency NOT measured; instrument the controller and log timings.\n');
end

writetable(runs,fullfile(cfg.outputDir,'individual_runs.csv'));
writetable(summary,fullfile(cfg.outputDir,'summary.csv'));
save(fullfile(cfg.outputDir,'benchmark_data.mat'),'cfg','runs','summary');

figure('Name','SAC-MPC timing comparison');
bar(categorical(cellstr(summary.Model)),summary.WallMean_s);
ylabel('Mean wall-clock simulation time (s)');
title('Full vs Reduced SAC-MPC (simulation runtime, not control latency)');
grid on;
saveas(gcf,fullfile(cfg.outputDir,'simulation_runtime.png'));

%% Local functions
function latency_ms = readLatency(simOut,signalName,unit)
    latency_ms = [];
    try
        logs = simOut.get('logsout');
        if isempty(logs), return; end
        item = logs.getElement(signalName);
        if isempty(item), return; end
        values = item.Values;
        latency_ms = double(values.Data(:));
        latency_ms = latency_ms(isfinite(latency_ms) & latency_ms >= 0);
        if strcmp(unit,'s'), latency_ms = latency_ms * 1000; end
    catch ME
        warning('Unable to read controller timing from logsout: %s',ME.message);
    end
end

function [max_time, initialPosition, initialAngle, initialVehicleVelocity] = loadStart(scenario, road_length)
    max_position_noise = 1; %m
    max_angle_noise = 10; %deg

    initialVehicleVelocity = 8.9; %m/s -> 25mph

    % find initial position and pose of vehicle
    initialPosition = scenario.Actors(1).Position;
    initialAngle = scenario.Actors(1).Yaw;

    position_noise = [2*max_position_noise*rand - max_position_noise, ...
        2*max_position_noise*rand - max_position_noise, 0];
    initialPosition = initialPosition + position_noise;
    % angle noise between -max_angle_noise and max_angle_noise degrees
    angle_noise = 2*max_angle_noise*rand - max_angle_noise;
    initialAngle = initialAngle + angle_noise;

    % find time to reach end of road
    max_time = road_length/initialVehicleVelocity;
end