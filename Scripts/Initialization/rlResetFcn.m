function in = rlResetFcn(in)

    [initialPosition, initialAngle, scenario, max_time] = ...
        ResetFunction();

    mdl = "SAC_MPC_angle";

    in = setVariable(in, "max_time", max_time, Workspace=mdl);
    in = setVariable(in, "initialPosition", initialPosition, Workspace=mdl);
    in = setVariable(in, "initialAngle", initialAngle, Workspace="Plant_angle");
    in = setVariable(in, "scenario", scenario, Workspace=mdl);
    in = setVariable(in, "initialVehicleVelocity", 8.9, Workspace=mdl);
    in = setVariable(in, "initialVehicleVelocity", 8.9, Workspace="Plant_angle");
    in = setVariable(in, "simStepSize", 0.05, Workspace=mdl);
    in = setVariable(in, "simStepSize", 0.05, Workspace="Plant_angle");

end