load("Results\MPC_RL_Best_Eval_2.mat")

ai_qy = squeeze(find(data, "ai_qy").Values.Data);
ai_qyaw = squeeze(find(data, "ai_qyaw").Values.Data);
ai_rang = squeeze(find(data, "ai_rang").Values.Data);
ai_sang = squeeze(find(data, "ai_sang").Values.Data);

window = 100;

norm_qy = smoothdata(normalize(ai_qy, "range", [0 1]), "sgolay", window);
norm_qyaw = smoothdata(normalize(ai_qyaw, "range", [0 1]), "sgolay", window);
norm_rang = smoothdata(normalize(ai_rang, "range", [0 1]), "sgolay", window);
norm_sang = smoothdata(normalize(ai_sang, "range", [0 1]), "sgolay", window);

mean_qy = repmat(mean(ai_qy), size(ai_qy));
mean_qyaw = repmat(mean(ai_qyaw), size(ai_qyaw));
mean_rang = repmat(mean(ai_rang), size(ai_rang));
mean_sang = repmat(mean(ai_sang), size(ai_sang));

close all

x = .05:.05:numel(norm_qy)*.05;

figure('Color', 'w', 'Position', [100 100 1100 550]);
hold on;

% Plot with thicker lines and refined colors
plot(x, norm_qy,   'LineWidth', 2.8, 'Color', [0.00 0.45 0.74], ...
    'DisplayName', 'Lateral Error Weight');

plot(x, norm_qyaw, 'LineWidth', 2.8, 'Color', [0.85 0.33 0.10], ...
    'DisplayName', 'Yaw Error Weight');

plot(x, norm_rang, 'LineWidth', 2.8, 'Color', [0.47 0.67 0.19], ...
    'DisplayName', 'Steering Magnitude Penalty Weight');

plot(x, norm_sang, 'LineWidth', 2.8, 'Color', [0.49 0.18 0.56], ...
    'DisplayName', 'Steering Rate Penalty Weight');

% Axes formatting
ax = gca;
ax.FontName = 'ITEC';
ax.FontSize = 16;
ax.LineWidth = 1.4;
ax.TickDir = 'out';
ax.Box = 'off';
ax.XColor = [0.2 0.2 0.2];
ax.YColor = [0.2 0.2 0.2];

% Labels and title
title('Weight Progression over Oval Track Test', ...
    'FontName', 'ITEC', 'FontSize', 22, 'FontWeight', 'bold');

xlabel('Time (s)', ...
    'FontName', 'ITEC', 'FontSize', 19);

ylabel('Normalized Weight Value', ...
    'FontName', 'ITEC', 'FontSize', 19);

% Axis limits
xlim([5 400]);
ylim([0 1.1]);

% Subtle grid
grid on;
ax.GridAlpha = 0.15;
ax.GridLineStyle = '-';
ax.MinorGridAlpha = 0.08;

% Improved legend
lgd = legend('show');
lgd.Location = 'southeast';
lgd.FontName = 'ITEC';
lgd.FontSize = 13;
lgd.Box = 'off';
lgd.NumColumns = 1;
lgd.ItemTokenSize = [35 18];

hold off;