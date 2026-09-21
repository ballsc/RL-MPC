function [initialPosition, initialAngle, scenario, max_time] = ResetFunction()
    scenarios = ["small_OvalTrack", "large_OvalTrack", "longStraight", ...
                "multiCurv", "leftCurv", "rightCurv"];
    num_scenarios = numel(scenarios);

    % find random scenario
    random_number = round((num_scenarios-1)*rand()) + 1;
    scenario = scenarios(random_number); run(scenario); S = ans;
    max_time = 10; % TODO

    %% using scenario, get initial position
    % get lanes
    lanes = getLanes(S);
    % for now, use outer lane center line for reference
    lane_ref = lanes.outer_center_line;
    num_points = size(lane_ref, 1);
    % choose random starting point from 1-N in ref lane
    random_number = round((num_points-1)*rand()) + 1;
    start_pt_xy = lane_ref(random_number, :);
    initialPosition = [start_pt_xy, 0];

    % using scenario, get initial angle
    initialAngle = 0;

    % add noise to initial position/angle

    % ensure noisy position/angle is within bounds

end