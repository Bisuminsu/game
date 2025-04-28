% Define your 3D space dimensions
x_min = 0;
x_max = 50;
y_min = 0;
y_max = 50;
z_min = 0;
z_max = 50;

% Define the start and target points (randomly or as needed)
start = [randi([x_min, x_max]), randi([y_min, y_max]), randi([z_min, z_max])];     % Random starting point
target = [randi([x_min, x_max]), randi([y_min, y_max]), randi([z_min, z_max])];  % Random target point

% Create random obstacles (you can customize this part)
num_obstacles = 20;  % Number of obstacles
obstacles = [randi([x_min, x_max], num_obstacles, 1), ...
             randi([y_min, y_max], num_obstacles, 1), ...
             randi([z_min, z_max], num_obstacles, 1)];

% Set up a 3D plot
figure;
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
grid on;
axis([x_min, x_max, y_min, y_max, z_min, z_max]);
view(3);

% Plot the start, target, and obstacles
scatter3(start(1), start(2), start(3), 'bo', 'filled'); % Start point
scatter3(target(1), target(2), target(3), 'go', 'filled'); % Target point
hold on;
scatter3(obstacles(:,1), obstacles(:,2), obstacles(:,3), 'r', 'filled'); % Obstacles

% Main loop for navigating from start to target
current_position = start;
while norm(current_position - target) > 1  % Termination condition (you can customize this)
    % Update the current position (simulated navigation step)
    % Replace this with your navigation algorithm logic.
    % For demonstration purposes, we will move toward the target directly.
    step_size = 1;  % Adjust the step size as needed.
    direction = (target - current_position) / norm(target - current_position);
    current_position = current_position + step_size * direction;

    % Plot the current position (drone's position)
    plot3(current_position(1), current_position(2), current_position(3), 'bs', 'MarkerSize', 10);

    % Pause for visualization (adjust the duration as needed)
    pause(0.1);
end

hold off;
disp('Reached the target!');



% Define your linear equations
horizontal_motor_power = @(horizontal_speed) 2953.802 * horizontal_speed + 22913.3015;
vertical_motor_power = @(vertical_speed) 6.020407083 * vertical_speed + 671.235371;
combined_motor_power = @(horizontal_speed, vertical_speed) -2010.788075 * horizontal_speed + 1207.608431 * vertical_speed + 39797.47324;

% Initialize variables
current_position = start;
total_power = 0;

% Main loop for navigating from start to target
while norm(current_position - target) > 1  % Termination condition (you can customize this)
    % Update the current position (simulated navigation step)
    % Replace this with your navigation algorithm logic.
    % For demonstration purposes, we will move toward the target directly.
    step_size = 1;  % Adjust the step size as needed.
    direction = (target - current_position) / norm(target - current_position);
    current_position = current_position + step_size * direction;

    % Calculate the horizontal and vertical speeds
    horizontal_speed = direction(1);
    vertical_speed = direction(2);

    % Calculate motor power based on speed and movement type
    if horizontal_speed ~= 0 && vertical_speed ~= 0
        motor_power = combined_motor_power(horizontal_speed, vertical_speed);
    elseif horizontal_speed ~= 0
        motor_power = horizontal_motor_power(horizontal_speed);
    elseif vertical_speed ~= 0
        motor_power = vertical_motor_power(vertical_speed);
    else
        motor_power = 0;  % No movement
    end

    % Accumulate the power
    total_power = total_power + motor_power;
end

disp(['Total Power Used: ', num2str(total_power), ' watts']);
