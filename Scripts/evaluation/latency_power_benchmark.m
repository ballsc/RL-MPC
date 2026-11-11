%% Benchmark full vs reduced SAC-MPC in Simulink
% Set the model names and (optionally) logged controller timing signal below.
% Run this script from the RL-MPC repository root after required setup.
%
% Measures:
%   1) Total wall-clock simulation time
%   2) Approx. wall-clock time / simulated control step (NOT controller latency)
%   3) True per-step controller latency IF logged by the model
%   4) Energy = measured/assumed electrical power * wall-clock time
%
% IMPORTANT: Power values supplied here are NOT hardware measurements.
% MATLAB/Simulink alone does not determine computer electrical power.

clearvars; clc;

%% -------------------- USER CONFIGURATION ------------------------------
cfg.fullModel    = 'FULL_MODEL_NAME';      % Change to actual .slx model name
cfg.reducedModel = 'REDUCED_MODEL_NAME';   % Change to actual .slx model name
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

% OPTIONAL external measured power (W), collected under equivalent conditions.
% Set to NaN if no real measurements are available. A single average power
% for each run condition is an approximation, not a power trace measurement.
cfg.fullPowerW    = NaN;                 % average wall/board power [W]
cfg.reducedPowerW = NaN;                 % average wall/board power [W]
cfg.idlePowerW    = NaN;                 % same measurement boundary [W]

% If real measurements are unavailable, you may intentionally set the power
% fields to ASSUMED values for a scenario analysis. Label results estimates.
% All Simulink initialization scripts/data dictionaries must be prepared.
% ----------------------------------------------------------------------

assert(cfg.Ts > 0 && cfg.stopTime > 0 && cfg.repetitions >= 1);
assert(ismember(cfg.latencyUnit, {'s','ms'}));
assert(~strcmp(cfg.fullModel,'FULL_MODEL_NAME') && ...
       ~strcmp(cfg.reducedModel,'REDUCED_MODEL_NAME'), ...
       'Set cfg.fullModel and cfg.reducedModel to actual Simulink model names.');

if ~isfolder(cfg.outputDir), mkdir(cfg.outputDir); end
models = {cfg.fullModel, cfg.reducedModel};
labels = {'Full SAC-MPC','Reduced SAC-MPC'};
powers = [cfg.fullPowerW, cfg.reducedPowerW];
for j = 1:2
    assert(bdIsLoaded(models{j}) || ~isempty(which([models{j},'.slx'])) || ...
           ~isempty(which([models{j},'.mdl'])), ...
           'Cannot locate model: %s',models{j});
    load_system(models{j});
end

% Run each model once before timing to reduce first-run initialization bias.
for k = 1:cfg.warmups
    for j = 1:2
        fprintf('Warmup %d: %s\n',k,labels{j});
        in = Simulink.SimulationInput(models{j});
        in = in.setModelParameter('StopTime',num2str(cfg.stopTime), ...
                                  'SimulationMode','normal');
        sim(in);
    end
end

% Alternate run order to reduce systematic temperature / clock bias.
N = 2 * cfg.repetitions;
Model = strings(N,1); Run = zeros(N,1);
WallTime_s = nan(N,1); ControlSteps = nan(N,1);
WallTimePerStep_ms = nan(N,1);
ControllerMean_ms = nan(N,1); ControllerPeak_ms = nan(N,1);
ControllerP95_ms = nan(N,1);
AveragePower_W = nan(N,1); TotalEnergy_J = nan(N,1);
IncrementalEnergy_J = nan(N,1);

r = 0;
for k = 1:cfg.repetitions
    if mod(k,2)==1, order = [1,2]; else, order = [2,1]; end
    for j = order
        r = r + 1;
        fprintf('Timed run %d/%d: %s\n',k,cfg.repetitions,labels{j});
        in = Simulink.SimulationInput(models{j});
        in = in.setModelParameter('StopTime',num2str(cfg.stopTime), ...
                                  'SimulationMode','normal');
        t0 = tic;
        out = sim(in);
        elapsed = toc(t0);

        Model(r) = string(labels{j});
        Run(r) = k;
        WallTime_s(r) = elapsed;
        % Valid for fixed-rate controller from t=0 through t<stopTime.
        % For variable-rate/adaptive/early-stop runs, replace this with
        % the ACTUAL logged number of controller invocations.
        ControlSteps(r) = ceil(cfg.stopTime / cfg.Ts);
        WallTimePerStep_ms(r) = 1e3 * elapsed / ControlSteps(r);

        if ~isempty(cfg.latencySignal)
            lat = readLatency(out,cfg.latencySignal,cfg.latencyUnit);
            if ~isempty(lat)
                ControllerMean_ms(r) = mean(lat);
                ControllerPeak_ms(r) = max(lat);
                ControllerP95_ms(r)  = prctile(lat,95);
                ControlSteps(r) = numel(lat);
                % Total sim time / controller invocation (still a proxy).
                WallTimePerStep_ms(r) = 1e3 * elapsed / numel(lat);
            else
                warning('Latency signal "%s" not found for %s run %d.', ...
                    cfg.latencySignal,models{j},k);
            end
        end

        if isfinite(powers(j))
            AveragePower_W(r) = powers(j);
            TotalEnergy_J(r) = powers(j) * elapsed;
            if isfinite(cfg.idlePowerW)
                IncrementalEnergy_J(r) = ...
                    (powers(j)-cfg.idlePowerW)*elapsed;
            end
        end
    end
end

runs = table(Model,Run,WallTime_s,ControlSteps,WallTimePerStep_ms, ...
    ControllerMean_ms,ControllerP95_ms,ControllerPeak_ms, ...
    AveragePower_W,TotalEnergy_J,IncrementalEnergy_J);

% Aggregate mean and standard deviation across repeated runs.
summary = table(strings(2,1),nan(2,1),nan(2,1),nan(2,1), ...
    nan(2,1),nan(2,1),nan(2,1),nan(2,1),nan(2,1), ...
    'VariableNames',{'Model','WallMean_s','WallStd_s', ...
    'WallPerStepMean_ms','CtrlMean_ms','CtrlP95Mean_ms','CtrlPeakMax_ms', ...
    'MeanPower_W','MeanEnergy_J'});
for j=1:2
    idx = Model == string(labels{j});
    summary.Model(j) = string(labels{j});
    summary.WallMean_s(j) = mean(WallTime_s(idx));
    summary.WallStd_s(j) = std(WallTime_s(idx));
    summary.WallPerStepMean_ms(j) = mean(WallTimePerStep_ms(idx));
    summary.CtrlMean_ms(j) = mean(ControllerMean_ms(idx),'omitnan');
    summary.CtrlP95Mean_ms(j) = mean(ControllerP95_ms(idx),'omitnan');
    summary.CtrlPeakMax_ms(j) = max(ControllerPeak_ms(idx),[],'omitnan');
    summary.MeanPower_W(j) = mean(AveragePower_W(idx),'omitnan');
    summary.MeanEnergy_J(j) = mean(TotalEnergy_J(idx),'omitnan');
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
if all(isfinite(summary.MeanEnergy_J))
    energyReduction = 100*(1-summary.MeanEnergy_J(2)/summary.MeanEnergy_J(1));
    fprintf('Wall-clock execution energy reduction = %.2f%%\n',energyReduction);
else
    fprintf('Power/energy NOT measured; supply externally measured average power.\n');
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
