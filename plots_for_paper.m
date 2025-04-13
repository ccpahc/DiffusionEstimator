%% Colors

% Define the three colors (RGB format):
color1 = [4/255, 29/255, 45/255];   % Blue
color2 = [104/255, 93/255, 39/255];   % White
color3 = [241/255, 180/255, 188/255];   % Red

% Number of points in your colormap:
numColors = 256; 

% Create a colormap by interpolating between these colors:
dusk = interp1([1, 128, 256], [color1; color2; color3], linspace(1, 256, numColors));

% Define the three colors (RGB format):
color0 = [1/255, 1/255, 1/255];
color1 = [5/255, 66/255, 92/255];   % Blue
color2 = [165/255, 154/255, 109/255];   % White
color3 = [254/255, 240/255, 85/255];   % Red

% Number of points in your colormap:
numColors = 256; 
% Create a colormap by interpolating between these colors:
pepper = interp1(linspace(1,256,4), [color0; color1; color2; color3], linspace(1, 256, numColors));

% Define the three colors (RGB format):
color0 = [62/255, 4/255, 22/255];
color1 = [148/255, 95/255, 4/255];   % Blue
color2 = [147/255, 159/255, 38/255];   % White
color3 = [51/255, 204/255, 25/255];   % Red

% Number of points in your colormap:
numColors = 256; 
% Create a colormap by interpolating between these colors:
eclipse = interp1(linspace(1,256,4), [color0; color1; color2; color3], linspace(1, 256, numColors));

% Define the three colors (RGB format):
color1 = [30/255, 51/255, 110/255];   % Blue
color2 = [235/255, 232/255, 198/255];   % White
color3 = [110/255, 20/255, 30/255];   % Red

% Number of points in your colormap:
numColors = 256; 

% Create a colormap by interpolating between these colors:
redblue = interp1([1, 128, 256], [color1; color2; color3], linspace(1, 256, numColors));

%% Diffusion plot
addpath('src');
addpath("cmaps")
[x,y,t] = get_dataset("cobo");

parameters = data_prep(1, [1 0 1 0 0 0 0 0], x, y, t);
result = run_model(parameters, [-1.87, 0.90]);
pinhasi_active = parameters.dataset_idx;
land = shaperead('landareas.shp', 'UseGeoCoords', true);

R = georefcells(parameters.lat, parameters.lon, ...
    size(parameters.X{1}));

tic
f = figure (1);
set(gcf, 'Color', 'White')
f.Position = [100 100 900 400];
% subplot(1,2,2)
hold on;

latlim = parameters.lat;
lonlim = parameters.lon;

worldmap(latlim, lonlim)
colormap(pepper)

title("Rice dataset", "FontSize", 12)
c = colorbar;
ylabel(c,'Year','FontSize',12);
axis xy

%make sea white

geoshow(fliplr([land.Lat]),fliplr([land.Lon]),'DisplayType', ...
    'Polygon', 'FaceColor', 'white', 'FaceAlpha', 0.5)

framem('FLineWidth', 1, 'FontSize', 7)

scatterm(parameters.dataset_lat, parameters.dataset_lon, 5, parameters.times(parameters.dataset_idx(:,3)), 'filled');


[x,y,t] = get_dataset("all_wheat");
clear parameters
clear result
parameters = data_prep(1, [1 0 1 0 0 0 0 0], x, y, t);
result = run_model(parameters, [-1.87, 0.90]);
pinhasi_active = parameters.dataset_idx;
land = shaperead('landareas.shp', 'UseGeoCoords', true);

R = georefcells(parameters.lat, parameters.lon, ...
    size(parameters.X{1}));
loc = 10;
fwidth = 20;
tic
subplot(1,2,1)

hold on;

latlim = parameters.lat;
lonlim = parameters.lon;

worldmap(latlim, lonlim)
colormap(pepper)

title("Wheat dataset", "FontSize", 12)
c = colorbar;
ylabel(c,'Year','FontSize',12);
axis xy

%make sea white

geoshow(fliplr([land.Lat]),fliplr([land.Lon]),'DisplayType', ...
    'Polygon', 'FaceColor', 'white', 'FaceAlpha', 0.5)

framem('FLineWidth', 1, 'FontSize', 7)

scatterm(parameters.dataset_lat, parameters.dataset_lon, 5, parameters.times(parameters.dataset_idx(:,3)), 'filled');
print(f, 'saved_plots/Diffusive_data.pdf', '-depsc')

%% Model figure plots

addpath('src');
addpath("generated_data\")
%%
[x,y,t] = get_dataset("all_wheat");
active_layers = [0 0 0 0 0 1 0 0]; %prec
parameters = data_prep(1, active_layers, x, y, t);
%%
[nx,ny] = size(parameters.X{1});
X = linspace(parameters.lat(1), parameters.lat(2), nx);
Y = linspace(parameters.lon(1), parameters.lon(2), ny);
f = figure(1);
pepper_bright = brighten(pepper, 0.3);
f.Position = [100 100 700 400];
set(gcf, 'Color', 'White', 'Alphamap',0)
[X,Y] = meshgrid(X,Y);
s = mesh(X,Y,parameters.X{1}');
s.FaceColor = 'flat';
s.FaceAlpha = 1;
view([45 60])
xlim([min(X(:)), max(X(:))])
ylim([min(Y(:)), max(Y(:))])
colormap(pepper_bright)
ax = gca;
ax.FontSize = 16; 
xlabel("Latitude", 'Rotation', -25, "FontSize",16)
ylabel("Longitude", 'Rotation', 25, "FontSize",16)
zlabel("Mean temperature", "FontSize",16)
grid off
saveas(gcf,"saved_plots/tmean_layer.pdf")

%% %% Plot objective function
load("model_plot_sweep_small.mat")
[X,Y] = meshgrid(theta_prec,theta_tmean);
points = [[2.28 -0.16 1.61543+0.07]; [2.92 -0.56 1.02808+0.05];  [3.16 -0.72 0.721299+0.05]; [3.24 -0.96 0.475222+0.05]; [3.24 -1.04 0.4348+0.05]; [3.2 -1.12 0.413622+0.05]];

f = figure(1)
hold on
f.Position = [100 100 700 400];
set(gcf, 'Color', 'White', 'Alphamap',0)
plot_errors = log(errors/1e6);
s = mesh(X,Y,plot_errors');
% Plot lines between points
lineColor = [110/255, 20/255, 30/255];
plot3(points(:,1), points(:,2), points(:,3), ...
    '-', 'LineWidth', 2.5, 'Color', lineColor);

% Plot points as scatter3
scatter3(points(:,1), points(:,2), points(:,3), ...
    50, lineColor, 'filled');
s.FaceColor = 'flat';
s.FaceAlpha = 1;
view([55 0])
xlim([2,3.5])
ylim([-2.,-0.])
pepper_bright = brighten(pepper, 0.3);
colormap(flipud(pepper_bright))
view([180-70 30])
ax = gca;
ax.FontSize = 16; 
xlabel("\theta_{prec}", 'Rotation', 55, "FontSize",16)
ylabel("\theta_{tmean}", 'Rotation', -5, "FontSize",16)
zlabel("Objective function (a.u.)", "FontSize",16)

saveas(gcf,"saved_plots/Obj_func.pdf")

%% Bar chart results plot

tiledlayout(2,1, 'TileSpacing', 'compact')

load('C:\Users\matil\OneDrive\Documents\Work\AlanTuring_Oxford\bottlenecks\generated_data\filename_database.mat')

load('C:\Users\matil\OneDrive\Documents\Work\AlanTuring_Oxford\bottlenecks\generated_data\all_wheat_av_100av_2025-03-24_11-09.mat')
labels_w = {};
labels_w{1} = "av";
sq_errors_w = [result.squared_error];
yr_errors_w = [sqrt(result.squared_error)];

load('C:\Users\matil\OneDrive\Documents\Work\AlanTuring_Oxford\bottlenecks\generated_data\cobo_av100_2025-03-10_14-02.mat')
labels_r = {};
labels_r{1} = "av";
sq_errors_r = [result.squared_error];
yr_errors_r = [sqrt(result.squared_error)];

for i=1:length(database)
    if all(ismember('asym', database{i}.layers{1})) | all(ismember('sea', database{i}.layers{1}))
        continue
    end
    if (length(database{i}.layers) == 1) & ismember('wheat', database{i}.dataset)
        disp(database{i}.layers)
        labels_w{length(labels_w)+1} = database{i}.layers{1};
        load(database{i}.file)
        sq_errors_w = [sq_errors_w result.squared_error];
        yr_errors_w = [yr_errors_w sqrt(result.squared_error)];
    elseif (length(database{i}.layers) == 1) & ismember('rice', database{i}.dataset)
        disp(database{i}.layers)
        labels_r{length(labels_r)+1} = database{i}.layers{1};
        load(database{i}.file)
        sq_errors_r = [sq_errors_r result.squared_error];
        yr_errors_r = [yr_errors_r sqrt(result.squared_error)];
    end
end

[yr, w_idx] = sort(yr_errors_w);
w_idx = fliplr(w_idx);

yr_errors = [yr_errors_w(w_idx); yr_errors_r(w_idx)];
sq_errors =[sq_errors_w(w_idx); sq_errors_r(w_idx)];
ax = gca;

ax.XAxis.TickLabelInterpreter = 'latex';
ax.YAxis.TickLabelInterpreter = 'latex';
ax.Title.Interpreter = 'latex';  % For title
ax.XLabel.Interpreter = 'latex'; % For x-label
ax.YLabel.Interpreter = 'latex'; % For y-label

nexttile
b1 = bar(sq_errors/1e6);
ylim([0, 3.2])
cmap = pepper;
for k = 1:length(yr_errors_w)
    b1(k).FaceColor = cmap(int16((k)*length(cmap)/(length(yr_errors_r)+1)),:);
    % Add text label on top of each bar
    xpos = b1(k).XEndPoints;  % Get x-position of bars
    ypos = b1(k).YEndPoints;  % Get y-position of bars
    text(xpos, ypos, labels_w{w_idx(k)}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 8,'Interpreter','latex');
end

set(gca, 'XTick', 1:2, 'XTickLabel', {'wheat', 'rice'}); 
ylabel("Obj. function (a.u.)",'Interpreter','latex')
title("Without sea layer",'Interpreter','latex')
grid on

load('C:\Users\matil\OneDrive\Documents\Work\AlanTuring_Oxford\bottlenecks\generated_data\all_wheat_av_sea_100av_2025-03-27_16-12.mat')
labels_w = {};
labels_w{1} = "av";
sq_errors_w = [result.squared_error];
yr_errors_w = [sqrt(result.squared_error)];

load('C:\Users\matil\OneDrive\Documents\Work\AlanTuring_Oxford\bottlenecks\generated_data\cobo_av_sea_100av_2025-03-27_14-59.mat')
labels_r = {};
labels_r{1} = "av";
sq_errors_r = [result.squared_error];
yr_errors_r = [sqrt(result.squared_error)];

for i=1:length(database)
    if (length(database{i}.layers) == 2)
        if all(ismember('asym', database{i}.layers{1})) | ~all(ismember('sea', database{i}.layers{2}))
            continue
        end
    end
    if (length(database{i}.layers) == 2) & ismember('wheat', database{i}.dataset)
        disp(database{i}.layers)
        labels_w{length(labels_w)+1} = database{i}.layers{1};
        load(database{i}.file)
        sq_errors_w = [sq_errors_w result.squared_error];
        yr_errors_w = [yr_errors_w sqrt(result.squared_error)];
    elseif (length(database{i}.layers) == 2) & ismember('rice', database{i}.dataset)
        disp(database{i}.layers)
        labels_r{length(labels_r)+1} = database{i}.layers{1};
        load(database{i}.file)
        sq_errors_r = [sq_errors_r result.squared_error];
        yr_errors_r = [yr_errors_r sqrt(result.squared_error)];
    end
end

[yr, w_idx] = sort(yr_errors_w);
w_idx = fliplr(w_idx);

yr_errors = [yr_errors_w(w_idx); yr_errors_r(w_idx)];
sq_errors = [sq_errors_w(w_idx); sq_errors_r(w_idx)];

nexttile
b2 = bar(sq_errors/1e6);
cmap = pepper;
ylim([0, 3.2])
for k = 1:length(yr_errors_r)
    b2(k).FaceColor = cmap(int16((k)*length(cmap)/(length(yr_errors_r)+1)),:);
    xpos = b2(k).XEndPoints;  % Get x-position of bars
    ypos = b2(k).YEndPoints;  % Get y-position of bars
    text(xpos, ypos, labels_w{w_idx(k)}, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 8,'Interpreter','latex');
end 
set(gca,'XTickLabel', {"wheat", "rice"})
ylabel("Obj. Function",'Interpreter','latex')
title("With sea layer",'Interpreter','latex')
grid on
set(gcf, 'Color', 'White', 'Alphamap',0)

saveas(gcf,"saved_plots/results_bar_chart.pdf")
