% Simulink RL model
mdl = "RL_Model";
agentblk = mdl + "/RLModel/RL Agent";
load(".\Agents\base_agent.mat")
load(".\Agents\RL_best_agent.mat")

env = rlSimulinkEnv(mdl,agentblk,obsInfo,actInfo);