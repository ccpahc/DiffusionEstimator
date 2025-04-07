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
subplot(1,2,2)
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