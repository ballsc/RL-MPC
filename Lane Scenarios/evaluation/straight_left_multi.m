function [scnro, road_length, egoVehicle] = straight_left_multi()
% Gives the scenario of a straight road into a road that curves left and 
% then right for the ego vehicle. Using the second vehicle gives the 
% scenario of a road that curves left and then right into a straight road.
%
% Also outputs the road_length 

% Construct a drivingScenario object.
scnro = drivingScenario;

% Add all road segments
roadCenters = [700 0 0;
    1000 0 0];
laneSpecification = lanespec(2);
road(scnro, roadCenters, Lanes = laneSpecification, Name = 'Road');

roadlength1 = sum(sqrt(sum(diff(roadCenters, 1, 1).^2, 2)));

roadCenters = [1000 0 0;
    1147.9 59.2 0;
    1191 149.3 0;
    1200 300 0;
    1300 400 0;
    1450 300 0;
    1500 200 0];
headings = [0;NaN;NaN;80;NaN;NaN;NaN];
laneSpecification = lanespec(2);
road(scnro, roadCenters, Heading = headings, Lanes = laneSpecification, Name = 'Road1');

roadlength2 = sum(sqrt(sum(diff(roadCenters, 1, 1).^2, 2)));

% Add the ego vehicle
egoVehicle = vehicle(scnro, ...
    ClassID = 1, ...
    Length = 4.7, ...
    Position = [702.16 -2.05 0.01], ...
    RearOverhang = 1, ...
    FrontOverhang = 0.9, ...
    Mesh = driving.scenario.carMesh, ...
    Name = 'Car');

% Add the non-ego actors
vehicle(scnro, ...
    ClassID = 1, ...
    Position = [1500.71 203.42 0.01], ...
    Yaw = 115, ...
    Mesh = driving.scenario.carMesh, ...
    PlotColor = [0.066 0.443 0.745], ...
    Name = 'Car');

road_length = roadlength1 + roadlength2; %m

