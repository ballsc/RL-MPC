% setup path
addpath("Agents\", "Lane Scenarios\", "LCC\", "RL_Environments\", ...
         "Scripts\", "Scripts\Visualization\", "Plants\", "DataDictionaries\", ...
         "Scripts\Initialization\", "Scripts\evaluation\", "Lane Scenarios\evaluation\")

addpath("RL_Environments\policies\", "RL_Environments\training\")

Simulink.ActorSimulation.load("BusActorPose");