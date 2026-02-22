% Simulink RL model
mdl = "RL_Model";
agentblk = mdl + "/RLModel/RL Agent";
load("C:\Users\balls\Desktop\EcoCAR\git\CAV - 2025b\base_agent.mat")
load("C:\Users\balls\Desktop\EcoCAR\git\CAV - 2025b\RL_best_agent.mat")

env = rlSimulinkEnv(mdl,agentblk,obsInfo,actInfo);