% Reset function to randomize starting scenario, position, and angle from
% driving scenario. Also, assigns max time based on scenario
%
% scenario        - scenario randomly chosen from all scenarios
% initialPosition - random position within chosen scenario
% initialAngle    - random angle based on random position in the lane
% max_time        - time taken to get to the end of the lane
%
function [initialPosition, initialAngle, scenario, max_time] = ResetFunction(initialVehicleVelocity)
    if ~exist("initialVehicleVelocity", "var")
        initialVehicleVelocity = 8.9;
    end
    
    % scenarios = {@small_OvalTrack, @large_OvalTrack, @longStraight, ...
    %             @multiCurv, @leftCurv, @rightCurv};
    scenarios = {@longStraight};

    % find random scenario
    random_number = randi(numel(scenarios));
    [scenario, roadCenters] = scenarios{random_number}();

    % get max_time
    roadCenters = roadCenters(:, 1:2);
    d = diff(roadCenters, 1, 1);
    roadLength = sum(vecnorm(d, 2, 2));
    max_time = 1.1*roadLength/initialVehicleVelocity;

    % get lanes
    lanes = getLanes(scenario);
    % use initial position from scenario if disconnected road
    if isempty(lanes)
        initialPosition = scenario.Actors(1).Position;
        initialAngle = scenario.Actors(1).Yaw;
    % use randomized initial position if connected road
    else
        % use outer lane center line for reference
        lane_ref = lanes.outer_center_line;
        num_points = size(lane_ref, 1);
        % choose random starting point from 1-N in ref lane
        random_number = round((num_points-1)*rand()) + 1;
        start_pt_xy = lane_ref(random_number, :);
        initialPosition = [start_pt_xy, 0];
    
        % using scenario, get initial angle
        initialAngle = getLaneHeading(lane_ref, random_number);
    end

    % add noise to initial position/angle
    % position noise between -max_pos and max_pos units
    max_pos = 1;
    position_noise = [2*max_pos*rand - 1, 2*max_pos - 1, 0];
    initialPosition = initialPosition + position_noise;
    % angle noise between -max_ang and max_ang degrees
    max_ang = 3;
    angle_noise = 2*max_ang*rand - max_ang;
    initialAngle = initialAngle + angle_noise;
end