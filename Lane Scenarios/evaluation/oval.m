function [scnro, road_length, egoVehicle] = oval()
% Gives the scenario of a oval road that has the ego vehicle turning right.
% Using the second vehicle gives the oval scenario with the vehicle turning
% left
%
% Also outputs the road_length of the oval

% Construct a drivingScenario object.
scnro = drivingScenario;

% Add all road segments
roadCenters = [694.3 98.2 0;
    896.5 98.2 0;
    998.8 36.8 0;
    1035.5 -84.3 0;
    996.3 -190.1 0;
    898.2 -232.7 0;
    679.8 -239.5 0;
    577.4 -194.3 0;
    548.4 -84.3 0;
    577.4 41.1 0;
    694.3 98.2 0];
laneSpecification = lanespec(2);
road(scnro, roadCenters, Lanes = laneSpecification, Name = 'Road');

roadlength1 = sum(sqrt(sum(diff(roadCenters, 1, 1).^2, 2)));

% Add the ego vehicle
egoVehicle = vehicle(scnro, ...
    ClassID = 1, ...
    Length = 4.7, ...
    Position = [688.32 95.14 0.01], ...
    Yaw = 12, ...
    RearOverhang = 1, ...
    FrontOverhang = 0.9, ...
    Mesh = driving.scenario.carMesh, ...
    Name = 'Car');

% Add the non-ego actors
vehicle(scnro, ...
    ClassID = 1, ...
    Position = [806.23 111.72 0.01], ...
    Yaw = 180, ...
    Mesh = driving.scenario.carMesh, ...
    PlotColor = [0.066 0.443 0.745], ...
    Name = 'Car');

road_length = roadlength1; %m