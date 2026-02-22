simStepSize = .05;
initialVehicleVelocity = 8.9;

load("RL_BusDefinitions.mat")

%% Uncomment if using the main SAC MPC model
% open(".\RL_Environments\SAC_MPC_angle.slx")
% load(".\Agents\SAC_MPC_agent.mat")

%% Uncomment if using just SAC model
open(".\RL_Environments\SAC_only_angle.slx")
load(".\Agents\SAC_solo_agent.mat")