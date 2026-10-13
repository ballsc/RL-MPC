function in = rlResetFcn_reduced(in)

    [initialPosition, initialAngle, scenario, max_time, initialVehicleVelocity] = ...
        ResetFunction();

    mdl = "SAC_MPC_angle_reduced";

    in = setVariable(in, "max_time", max_time, Workspace=mdl);
    in = setVariable(in, "initialPosition", initialPosition, Workspace=mdl);
    in = setVariable(in, "initialAngle", initialAngle, Workspace="Plant_angle");
    in = setVariable(in, "scenario", scenario, Workspace=mdl);
    in = setVariable(in, "initialVehicleVelocity", initialVehicleVelocity, Workspace=mdl);
    in = setVariable(in, "initialVehicleVelocity", initialVehicleVelocity, Workspace="Plant_angle");
    in = setVariable(in, "simStepSize", 0.05, Workspace=mdl);
    in = setVariable(in, "simStepSize", 0.05, Workspace="Plant_angle");

end