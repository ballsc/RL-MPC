%% Script to make a RL Agent
% Observation and action specifications
obsInfo = rlNumericSpec([6 1]);

actInfo = rlNumericSpec([4 1], LowerLimit = 0, UpperLimit = 5);

% SAC agent options
agentOpts = rlSACAgentOptions(SampleTime = 0.05);

% Create SAC agent with default actor/critic networks
agent = rlSACAgent(obsInfo, actInfo, agentOpts);

% Create Environment for Agent
base_env = rlSimulinkEnv("SAC_MPC_angle","SAC_MPC_angle/RLModel/RL Agent");
