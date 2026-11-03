classdef LaneRewardSystem < matlab.System
    % LaneRewardSystem  Stateful reward function for a Simulink MATLAB System block.
    % Inputs:  obs (6x1), leave, complete, action (2x1), weights (10x1)
    % Outputs: reward, isdone, penalties, rewards

    properties (Access = private)
        SteerPrev = 0
        Act1Prev = 0
        Act2Prev = 0
        InLanePrev = true
        Elapsed = 0
        Initialized = false
    end

    methods (Access = protected)
        function [reward, isdone, penalties, rewards] = stepImpl(obj, obs, leave, complete, action, weights)
            dt = 0.05;

            cy      = weights(1);
            cyaw    = weights(2);
            crate   = weights(3);
            ck      = weights(4);
            csteerD = weights(5);
            cactD   = weights(6);
            cdist   = weights(7);
            calive  = weights(8);
            R_fail  = weights(9);
            R_succ  = weights(10);

            scale_y   = 2.0;
            scale_yaw = 0.5;
            Vmin = 0.01;

            Ey_ref       = 1.0;
            Eyaw_ref     = 0.25;
            yawRate_ref  = 0.5;
            kDiff_ref    = 0.1;
            steerDot_ref = pi/6; % 30 deg/s
            actionD_ref  = 1.0;

            Vref = 8.9;
            ds_ref = Vref * dt;

            % Match the supplied leave signal convention: 1 = in lane.
            inLane = (leave == 1);
            done = (complete ~= 0);
            isdone = (~inLane) || done;

            steerAng = obs(5);
            if ~obj.Initialized
                obj.SteerPrev = steerAng;
                obj.Act1Prev = action(1);
                obj.Act2Prev = action(2);
                obj.InLanePrev = true;
                obj.Elapsed = 0;
                obj.Initialized = true;
            end

            justLeft = obj.InLanePrev && ~inLane;

            Ey = obs(1);
            Eyaw = obs(2);
            yawRate = obs(3);
            Vx = obs(4);
            k_lane = obs(6);

            Vx_eff = max(abs(Vx), Vmin);
            k_veh = yawRate / Vx_eff;
            k_diff = k_lane - k_veh;

            steer_dot = (steerAng - obj.SteerPrev) / dt;
            action_dot = abs(action(1) - obj.Act1Prev) + ...
                         abs(action(2) - obj.Act2Prev);

            gate = exp(-(Ey^2 / scale_y^2) - (Eyaw^2 / scale_yaw^2));
            ds_parallel = max(0, Vx * cos(Eyaw) * dt);

            p_y      = min((Ey / Ey_ref)^2, 4);
            p_yaw    = min((Eyaw / Eyaw_ref)^2, 4);
            p_rate   = min((yawRate / yawRate_ref)^2, 4);
            p_k      = min((k_diff / kDiff_ref)^2, 4);
            p_steer  = min((steer_dot / steerDot_ref)^2, 4);
            p_action = min((action_dot / actionD_ref)^2, 4);

            penaltyWeightSum = cy + cyaw + crate + ck + csteerD + cactD;

            if isdone || obj.Elapsed < 0.11
                penalties = 0;
            else
                penalties = -(cy*p_y + cyaw*p_yaw + crate*p_rate + ...
                    ck*p_k + csteerD*p_steer + cactD*p_action) / ...
                    max(penaltyWeightSum, eps);
            end

            progressNorm = min(max(ds_parallel / ds_ref, 0), 1);
            if isdone && obj.Elapsed < 0.11
                rewards = 0;
            else
                rewards = gate * (cdist * progressNorm + calive);
            end

            if justLeft
                penalties = penalties - R_fail;
            end
            if done
                rewards = rewards + R_succ;
            end

            reward = (penalties / min(ds_ref, 3) + rewards) * dt;

            obj.InLanePrev = inLane;
            obj.SteerPrev = steerAng;
            obj.Act1Prev = action(1);
            obj.Act2Prev = action(2);
            obj.Elapsed = obj.Elapsed + dt;
        end

        function resetImpl(obj)
            obj.SteerPrev = 0;
            obj.Act1Prev = 0;
            obj.Act2Prev = 0;
            obj.InLanePrev = true;
            obj.Elapsed = 0;
            obj.Initialized = false;
        end
    end
end
