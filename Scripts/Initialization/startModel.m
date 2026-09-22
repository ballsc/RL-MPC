% script to start-up the RL-MPC model with necessary initial values.
%
% model_name - model to be started
% simStepSize - step size of the simulation
% initialVehicleVelocity - starting speed of the vehicle in m/s
%
% scenario - random scenario chosen from all scenarios
% initialPosition - random position in chosen scenario
% initialAnggle - random angle corresponding to initialPosition
% max_time - time until scenario will end, defaults to 100
%
model_name = "SAC_MPC_angle";
simStepSize = 0.05;
initialVehicleVelocity = 8.9;

[initialPosition, initialAngle, scenario, max_time] = ResetFunction(initialVehicleVelocity);

open("RL_Environments\"+model_name)

load("Agents\SAC_MPC_trained_Sang.mat")
Simulink.ActorSimulation.load("BusActorPose");