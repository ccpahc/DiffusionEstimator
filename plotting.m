


active_layers = [1 0 1 0 1];
cobo = readtable( ...
     'data/raw/cobo_etal/cobo_etal_data.xlsx');
parameters = data_prep(50, active_layers, cobo.Latitude, cobo.Longitude, cobo.Est_DateMean_BC_AD_);

theta_0 = -1.16;
theta_1 = 0.27;
theta_2 = -0.98;


theta = [theta_0 theta_1 theta_2];


result = run_model(parameters, theta);

[min_time, min_idx] = min(parameters.dataset_idx(:,3));

%%


function [x,y,c] = get_plot_coords(parameters, result)
    % Define the three colors (RGB format):
    color1 = [30/255, 51/255, 110/255];   % Blue
    color2 = [235/255, 232/255, 198/255];   % White
    color3 = [110/255, 20/255, 30/255];   % Red
    
    % Number of points in your colormap:
    numColors = 256; 
    
    % Create a colormap by interpolating between these colors:
    cmap = interp1([1, 128, 256], [color1; color2; color3], linspace(1, 256, numColors));
    x = parameters.dataset_idx(:,3);
    y = result.errors;
    [x, x_ind] = sort(x);
    y = y(x_ind);
    yMin = min(y);
    yMax = max(y);
    yRange = max(abs(yMin), abs(yMax)); % Use the larger absolute bound for symmetry
    y_norm = round((y + yRange) / (2 * yRange) * (numColors - 1)) + 1; % Map y to [1, 256]
    c = cmap(y_norm,:);
end


[x,y,colors] = get_plot_coords(parameters, result);
figure;
hold on;
for i = 1:length(x)
    line([x(i), x(i)], [0, y(i)], 'Color', colors(i, :), 'LineWidth', 1);
end

% Plot the points with color corresponding to y-values
s = scatter(x, y, 10, colors, 'filled'); % 100 is the marker size, adjust as needed

% Customize the plot
xlabel('Activation year', 'FontSize',14);
ylabel('Error (years)','FontSize',14);
grid on;

%% Color palette
