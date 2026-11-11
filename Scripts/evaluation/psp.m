% Function to derive the resulting perceived safety proxy (PSP) value from
% a simulink simulation run 
%
% Inputs: out     - simulation output from Simulink as a struct
%         weights - weights for use in the PSP.
%
% Output: Jpsp - the output safety proxy value

function Jpsp = psp(out, weights)
    % get weights
    if sum(weights) == 1
        w_a = 0.25;
        w_j = 0.25;
        w_d = 0.25;
        w_l = 0.25;
    else
        w_a = weights(1);
        w_j = weights(2);
        w_d = weights(3);
        w_l = weights(4);
    end

    % get simulation output values
    d_edge = out.midOffset;
    acc = out.lateralAcceleration;
    a_rms = rms(acc);
    jerk = out.lateralJerk;
    j_rms = rms(jerk);
    steering_rate = diff(out.swAngleDeg);
    s_rms = rms(steering_rate);

    % define lane proximity penalty
    d_safe = .3; % meters, ~ 1 foot from centerline
    p_lane = (1/numel(d_edge))*sum(max(0, d_safe - d_edge));

    Jpsp = w_a*a_rms + w_j*j_rms + w_d*s_rms + w_l*p_lane;
end