
%% Plot Wall-Clock Time vs. Trial Number

figure('Color', 'w', 'Position', [100 100 1100 550]);
hold on;

% Model colors
colors = [
    0.00 0.45 0.74;  % Blue - Full SAC-MPC
    0.85 0.33 0.10   % Orange - Reduced SAC-MPC
    ];

% Plot first two models
for j = 1:2
    idx = runs.Model == string(labels{j});

    plot(runs.Run(idx), runs.WallTime_s(idx), '-o', ...
        'LineWidth', 2.8, ...
        'MarkerSize', 8, ...
        'Color', colors(j,:), ...
        'MarkerFaceColor', colors(j,:), ...
        'DisplayName', labels{j});
end

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
title('Simulation Wall Time Across Trials', ...
    'FontName', 'ITEC', 'FontSize', 22, 'FontWeight', 'bold');

xlabel('Trial Number', ...
    'FontName', 'ITEC', 'FontSize', 19);

ylabel('Wall-Clock Time (s)', ...
    'FontName', 'ITEC', 'FontSize', 19);

% Axis limits
xlim([1 max(runs.Run)]);
xticks(1:max(runs.Run));

% Subtle grid
grid on;
ax.GridAlpha = 0.15;
ax.GridLineStyle = '-';
ax.MinorGridAlpha = 0.08;

% Improved legend
lgd = legend('show');
lgd.Location = 'best';
lgd.FontName = 'ITEC';
lgd.FontSize = 13;
lgd.Box = 'off';
lgd.NumColumns = 1;
lgd.ItemTokenSize = [35 18];

hold off;
