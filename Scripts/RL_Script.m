%% Script to make a RL Agent
% Observation and action specifications
obsInfo = rlNumericSpec([6 1]);

actInfo = rlNumericSpec([2 1], LowerLimit = 0, UpperLimit = 5);

% SAC agent options
agentOpts = rlSACAgentOptions(SampleTime = 0.05);

% Create SAC agent with default actor/critic networks
low_agent = rlSACAgent(obsInfo, actInfo, agentOpts);

% Create Environment for Agent
low_env = rlSimulinkEnv("SAC_MPC_angle_reduced","SAC_MPC_angle_reduced/RLModel/RL Agent");
low_env.ResetFcn = @(in) rlResetFcn(in);
