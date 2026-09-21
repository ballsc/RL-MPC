% Function to get center line for lanes to randomize initial position of
% vehicle within lanes and boundaries.
%
% Input: S - drivingScenario, obtained from running .m file in Lane Scenarios
%        visualize - DEFAULT: 0. Either 1 or 0. If 1, plots the lanes gathered
%           from scenario.
%
% Output: lanes - struct with the following variables as Nx2 arrays
%                       outer_boundary
%                       inner_boundary
%                       center_line
%                       outer_center_line
%                       inner_center_line
%
function lanes = getLanes(S, visualize)
    if ~exist("visualize", "var")
        visualize = 0;
    end

    rb = S.roadBoundaries;

    % if the path is disconnected, there is only one road boundary.
    if numel(rb) == 2
        rb1 = rb{1}; rb1 = [rb1(:, 1:2)]; % outer road boundary
        rb2 = rb{2}; rb2 = [rb2(:, 1:2)]; % inner road boundary
        center_line = getCenterLine(rb2, rb1, size(rb1, 1));
    elseif isscalar(rb)
        rb = rb{1};
        rb1 = rb(1:round(size(rb, 1)/2), :);
        rb2 = rb(round(size(rb, 1)/2):end, :);

        center_line = getCenterLine(rb2, rb1, size(rb1, 1));
    else
        return
    end
    
    outer_lane_center_line = getCenterLine(center_line, rb1, 328);
    inner_lane_center_line = getCenterLine(center_line, rb2, 328);
    
    if visualize
        plot(rb1(:, 1), rb1(:, 2), rb2(:, 1), rb2(:, 2), center_line(:, 1), center_line(:, 2), ...
            outer_lane_center_line(:, 1), outer_lane_center_line(:, 2), ...
            inner_lane_center_line(:, 1), inner_lane_center_line(:, 2));
    end

    lanes = struct();
    lanes.outer_boundary = rb1;
    lanes.inner_boundary = rb2;
    lanes.center_line = center_line;
    lanes.outer_center_line = outer_lane_center_line;
    lanes.inner_center_line = inner_lane_center_line;
end

% Functions to get the center line.
function centerLine = getCenterLine(lb, rb, N)

    if nargin < 3
        N = 1000;
    end

    % Remove duplicated closing point if present
    if norm(lb(1,:) - lb(end,:)) < 1e-9
        lb(end,:) = [];
    end

    if norm(rb(1,:) - rb(end,:)) < 1e-9
        rb(end,:) = [];
    end

    % Resample both closed boundaries uniformly by arc length
    lb = resampleClosedCurve(lb, N);
    rb = resampleClosedCurve(rb, N);

    % Determine whether the boundaries travel in the same direction
    % Try rb normally
    costSame = alignmentCost(lb, rb);

    % Try rb reversed
    rbRev = flipud(rb);
    costReverse = alignmentCost(lb, rbRev);

    if costReverse < costSame
        rb = rbRev;
    end

    % Find best circular shift
    bestCost = inf;
    bestShift = 0;

    for k = 0:N-1

        rbShift = circshift(rb, k, 1);

        d = lb - rbShift;

        cost = mean(sum(d.^2, 2));

        if cost < bestCost
            bestCost = cost;
            bestShift = k;
        end
    end

    rb = circshift(rb, bestShift, 1);

    centerLine = (lb + rb)/2;

end

function Pnew = resampleClosedCurve(P, N)

    % Explicitly close curve
    Pc = [P; P(1,:)];

    % Segment lengths
    dP = diff(Pc, 1, 1);
    ds = sqrt(sum(dP.^2, 2));

    % Arc length
    s = [0; cumsum(ds)];

    % Remove any duplicate arc-length values
    [s, idx] = unique(s);
    Pc = Pc(idx,:);

    % Uniform samples around track
    sNew = linspace(0, s(end), N+1)';
    sNew(end) = [];

    % Interpolate X and Y
    x = interp1(s, Pc(:,1), sNew, 'linear');
    y = interp1(s, Pc(:,2), sNew, 'linear');

    Pnew = [x y];

end

function cost = alignmentCost(A, B)

    N = size(A,1);
    bestCost = inf;

    for k = 0:N-1
        Bshift = circshift(B, k, 1);

        d = A - Bshift;
        c = mean(sum(d.^2,2));

        if c < bestCost
            bestCost = c;
        end
    end

    cost = bestCost;

end
