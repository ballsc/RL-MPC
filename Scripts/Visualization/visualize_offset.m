%% Plot Lateral Offset Comparison

offset_f = out_data(1).midOffset;
offset_r = out_data(2).midOffset;
offset_o = out_data(3).midOffset;

x = 1:numel(offset_f);

figure('Color', 'w', 'Position', [100 100 1100 550]);
hold on;

% Plot with refined colors and thicker lines
plot(1:numel(offset_f), offset_f, 'LineWidth', 2.8, 'Color', [0.00 0.45 0.74], ...
    'DisplayName', 'Full SAC-MPC');

plot(1:numel(offset_r), offset_r, 'LineWidth', 2.8, 'Color', [0.85 0.33 0.10], ...
    'DisplayName', 'Reduced SAC-MPC');

plot(1:numel(offset_o), offset_o, 'LineWidth', 2.8, 'Color', [0.47 0.67 0.19], ...
    'DisplayName', 'Default MPC');

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
title('Lateral Offset Comparison', ...
    'FontName', 'ITEC', 'FontSize', 22, 'FontWeight', 'bold');

xlabel('Simulation Step', ...
    'FontName', 'ITEC', 'FontSize', 19);

ylabel('Lateral Offset (m)', ...
    'FontName', 'ITEC', 'FontSize', 19);

% Axis limits
xlim([1 numel(x)]);

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
