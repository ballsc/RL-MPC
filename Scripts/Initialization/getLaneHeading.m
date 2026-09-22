% function to estimate vehicle yaw from a lane centerline.
%
% Inputs:
%   lane_ref - Nx2 array of [x y] lane centerline points
%   idx      - index of the vehicle's position on lane_ref
%
% Output:
%   yaw      - heading angle in degrees, measured counterclockwise
%              from the +X axis
%
function yaw = getLaneHeading(lane_ref, idx)

    N = size(lane_ref, 1);

    if N < 2
        error('lane_ref must contain at least two points.');
    end

    if idx < 1 || idx > N
        error('idx must be between 1 and size(lane_ref,1).');
    end

    % Use points immediately before and after the selected point.
    % Wrap around because the lane is a closed curve.
    prevIdx = mod(idx - 2, N) + 1;
    nextIdx = mod(idx,     N) + 1;

    % Central-difference estimate of the local tangent
    tangent = lane_ref(nextIdx, :) - lane_ref(prevIdx, :);

    % Convert tangent vector to heading angle
    yaw = atan2d(tangent(2), tangent(1));

    % convert from [-180,180] to [0,360)
    yaw = mod(yaw, 360);
end