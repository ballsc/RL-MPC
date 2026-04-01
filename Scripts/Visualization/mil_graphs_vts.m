%% Function to find and plot the VTS targets of LCC

% Gather Data from output
data_mpc = load("Results\MPC_Best_Eval.mat");
data_rl1 = load("Results\MPC_RL_Best_Eval_2.mat");
data_rl2 = load("Results\MPC_RL_Best_Eval_3.mat");

data_mpc = data_mpc.data;
data_rl1 = data_rl1.data;
data_rl2 = data_rl2.data;

% data from MPC
lateral_jerk_mpc = squeeze(find(data_mpc, "lateralJerk").Values.Data);
swAngleDeg_mpc = find(data_mpc,"swAngleDeg").Values.Data;
midOffset_mpc = find(data_mpc, "offset_diff").Values.Data;
time = find(data_mpc, "lateralJerk").Values.Time;

% data from RL test 1
lateral_jerk_rl1 = squeeze(find(data_rl1, "lateralJerk").Values.Data);
swAngleDeg_rl1 = find(data_rl1,"swAngleDeg").Values.Data;
midOffset_rl1 = find(data_rl1, "midOffset").Values.Data;

% data from RL test 2
lateral_jerk_rl2 = squeeze(find(data_rl2, "lateralJerk").Values.Data);
swAngleDeg_rl2 = find(data_rl2,"swAngleDeg").Values.Data;
midOffset_rl2 = find(data_rl2, "midOffset").Values.Data;

% Process data to get general VTS information
max_lat_jerk_mpc = max(lateral_jerk_mpc);
rms_lat_deviation_mpc = rms(midOffset_mpc);
steering_busyness_mpc = sum(abs(diff(swAngleDeg_mpc)))/((time*20)/60);
steering_busyness_mpc = steering_busyness_mpc(end);

max_lat_jerk_rl1 = max(lateral_jerk_rl1);
rms_lat_deviation_rl1 = rms(midOffset_rl1);
steering_busyness_rl1 = sum(abs(diff(swAngleDeg_rl1)))/((time*20)/60);
steering_busyness_rl1 = steering_busyness_rl1(end);

max_lat_jerk_rl2 = max(lateral_jerk_rl2);
rms_lat_deviation_rl2 = rms(midOffset_rl2);
steering_busyness_rl2 = sum(abs(diff(swAngleDeg_rl2)))/((time*20)/60);
steering_busyness_rl2 = steering_busyness_rl2(end);

%% Setup tiled plots
tiledlayout(3,1,'TileSpacing', 'tight')
ax1 = nexttile;

% Plot steering wheel degrees
% plot(time,swAngleDeg_rl1, 'Color', '#642F6C', "DisplayName", "SAC+MPC 1", 'LineWidth',2)
hold on
plot(time,swAngleDeg_rl2, 'Color', '#642F6C', "DisplayName", "SAC+MPC 2", 'LineWidth',2)
plot(time,swAngleDeg_mpc, "r", "DisplayName","MPC", 'LineWidth',2)

ylabel("Steering Wheel Angle (degrees)","FontName","Times New Roman", FontSize=16)

legend(FontSize=16)
grid on
hold off

% Plot Lateral Jerk
ax2 = nexttile;

% plot(time,lateral_jerk_rl1,'Color', '#642F6C', "DisplayName","SAC+MPC 1", 'LineWidth',2)
hold on
plot(time,lateral_jerk_rl2,'Color', '#642F6C', "DisplayName","SAC+MPC 2", 'LineWidth',2)
plot(time,lateral_jerk_mpc,"r", "DisplayName","MPC", 'LineWidth',2)

ylabel("Lateral Jerk (m/s^3)","FontName","Times New Roman", FontSize=16)
grid on
hold off

% Plot Distance to Center Line
ax3 = nexttile;

plot(time, midOffset_mpc, 'r', "DisplayName","S_a_n_g = 50", 'LineWidth',2)
hold on
% plot(time, midOffset_rl1, "Color", '#642F6C', "DisplayName","S_a_n_g = 25", 'LineWidth',2)
plot(time, midOffset_rl2, "Color", '#642F6C', "DisplayName","S_a_n_g = 25", 'LineWidth',2)

ylabel("Offset From Center Line (m)","FontName","Times New Roman", FontSize=16)
box on
grid on
hold off

% Setup X axis
linkaxes([ax1, ax2, ax3], 'x');
xlim(ax1,[0 400])
xlabel(ax3,"Time (s)","FontName","Times New Roman", FontSize=16)
