%% Function to find and plot the VTS targets of LCC

%% TODO: add data from RL training with all outputs

% Gather Data from output
load("Results\Second_Training_Results.mat");

data_straight = trainStats1_straight;
data_right = trainStats2_right;
% data_all = something;

clearvars -except data_straight data_right data_left

% data from Straight
steps_s = data_straight.AverageSteps;
reward_s = data_straight.AverageReward;
q_s = data_straight.EpisodeQ0;
total_s = data_straight.EpisodeIndex;

% data from Right
steps_r = data_right.AverageSteps;
reward_r = data_right.AverageReward;
q_r = data_right.EpisodeQ0;
total_r = data_right.EpisodeIndex;

% data from RL all
% steps_a = data_all.AverageSteps;
% reward_a = data_all.AverageReward;
% q_a = data_all.EpisodeQ0;
% total_a = max(data_all.EpisodeIndex);


%% Setup tiled plot for Straight and Right
tiledlayout(3,2,'TileSpacing', 'tight')
ax1 = nexttile;

% Plot Agent Steps Straight
plot(total_s, steps_s, 'r', "DisplayName", "Straight", 'LineWidth',2)
hold on

xlim([0 max(total_s)])
ylabel("Agent Steps","FontName","Times New Roman", FontSize=16)

legend(FontSize=16)
grid on
hold off

% Plot Agent Steps Right
ax4 = nexttile;

plot(total_r, steps_r, 'Color', '#642F6C', "DisplayName", "Right", 'LineWidth',2)
hold on
xlim([0 300])
%ylabel("Agent Steps","FontName","Times New Roman", FontSize=16)

legend(FontSize=16)
grid on
hold off

% Plot Total Reward Straight
ax2 = nexttile;

plot(total_s, reward_s, 'r', "DisplayName","Straight", 'LineWidth',2)
hold on
xlim([0 max(total_s)])
ylabel("Total Reward","FontName","Times New Roman", FontSize=16)
grid on
hold off

% Plot Total Reward Right
ax5 = nexttile;

plot(total_r, reward_r, 'Color', '#642F6C', "DisplayName","Right", 'LineWidth',2)
hold on
xlim([0 300])
%ylabel("Total Reward","FontName","Times New Roman", FontSize=16)
grid on
hold off

% Plot Critic Q Value Straight
ax3 = nexttile;

set(gca, 'FontSize', 20)

plot(total_s, q_s, 'r', "DisplayName","Straight", 'LineWidth',2)
hold on
xlim([0 max(total_s)])
ylabel("Critic Q-Value","FontName","Times New Roman", FontSize=16)
box on
grid on
hold off

% Plot Critic Q Value Right
ax6 = nexttile;

set(gca, 'FontSize', 20)

plot(total_r, q_r, 'Color', '#642F6C', "DisplayName", "Right", 'LineWidth',2)
hold on
xlim([0 300])
%ylabel("Critic Q-Value","FontName","Times New Roman", FontSize=16)
box on
grid on
hold off


%% Setup tiled plot for All
% tiledlayout(3,1,'TileSpacing', 'tight')
% ax1 = nexttile;
% 
% % Plot Agent Steps
% plot(total_s, steps_s, 'r', "DisplayName", "all", 'LineWidth',2)
% hold on
% 
% ylabel("Agent Steps","FontName","Times New Roman", FontSize=16)
% 
% legend(FontSize=16)
% grid on
% hold off
% 
% % Plot Total Reward
% ax2 = nexttile;
% 
% plot(total_s, reward_s,'r', "DisplayName", "all", 'LineWidth',2)
% hold on
% 
% ylabel("Total Reward","FontName","Times New Roman", FontSize=16)
% grid on
% hold off
% 
% % Plot Critic Q Value
% ax3 = nexttile;
% 
% set(gca, 'FontSize', 20)
% 
% plot(total_s, q_s, 'r', "DisplayName", "all", 'LineWidth',2)
% hold on
% 
% ylabel("Critic Q-Value","FontName","Times New Roman", FontSize=16)
% box on
% grid on
% hold off
% 
% % Setup X axis
% linkaxes([ax1, ax2, ax3], 'x');
% xlabel(ax3,"Episode","FontName","Times New Roman", FontSize=16)
