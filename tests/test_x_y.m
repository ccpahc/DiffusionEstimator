clear
clc
% Add the directory containing run_model.m to the MATLAB path
addpath('src');

d = 22.5; % distance between two cells
gamma = 10; % km per decade
diff_speed = gamma / d / 10; % diffusion speed in cells per year

% load build
load('data/prep/geography.mat');

% load pinhasi
pinhasi = readtable( ...
    'data/raw/pinhasi/Neolithic_timing_Europe_PLOS.xls');

pinhasi = pinhasi(pinhasi.Var1 == "SITE",:); %% keep only site rows

pinhasi = renamevars(pinhasi, {'Latitude', 'Longitude', 'CALC14BP'}, ...
    {'lat', 'lon', 'bp'});

pinhasi = pinhasi(:,{'lat', 'lon', 'bp'});
pinhasi.bp = 2000 - pinhasi.bp; % from BP to year
idx = find(pinhasi.bp == min(pinhasi.bp));

% restrict to Europe/Iran range
topleft = [60, -17.19];
bottomright = [15, 65.07];

latidx = lat <= topleft(1) & lat >= bottomright(1);
lonidx = lon >= topleft(2) & lon <= bottomright(2);

latp = lat(latidx);
lonp = lon(lonidx);

[~, index_x] = min(abs(latp - pinhasi.lat(idx)));
[~, index_y] = min(abs(lonp - pinhasi.lon(idx)));

%% define simulation array

dt = 50; % time step in years
start_time = floor(min(pinhasi.bp)/dt)*dt;
end_time = ceil(max(pinhasi.bp)/dt)*dt;
T = round((end_time - start_time)/dt + 1);

times = start_time:dt:end_time;

% create matrix storing x,y,t coordinates of pinhasi sites
pinhasi_active = zeros(length(pinhasi.lat),3);
for event_index = 1:length(pinhasi.lat)
    lat_event = pinhasi.lat(event_index);
    lon_event = pinhasi.lon(event_index);
    [~, index_x] = min(abs(latp - lat_event));
    [~, index_y] = min(abs(lonp - lon_event));
    [~, index_t] = min(abs(times - pinhasi.bp(event_index)));
    pinhasi_active(event_index,:) = [index_x, index_y, index_t];
end

% initialize A
A = false(length(latp), length(lonp), T);
% find event in pinhasi_active with the earliest time
[~, earliest_event] = min(pinhasi_active(:,3));
A(pinhasi_active(earliest_event,1), pinhasi_active(earliest_event,2), 1) = true;

% define c_x and c_y
c_x = 100;
c_y = 1;
ratios = [100,10,1,0.1,0.01,0.001];

for ratio = 1:length(ratios)
    c_x  = 1;
    c_y = ratios(ratio)*c_x;
    A = run_model(100, A, T, diff_speed, c_x, c_y, dt);
    
    error = calculate_error(A, pinhasi_active);
    disp(error)
    % make figure

    pinhasimtx = zeros(length(latp),length(lonp));
    [~, index_x] = min(abs(latp - pinhasi.lat(idx)));
    [~, index_y] = min(abs(lonp - pinhasi.lon(idx)));
    pinhasimtx(index_x,index_y) = 1; 

    land = shaperead('landareas.shp', 'UseGeoCoords', true);

    R = georefcells([latp(1) latp(end)], [lonp(1) lonp(end)], ...
        size(pinhasimtx));

    loc = 10;
    fwidth = 20;
    % set up figure with extent of Europe/Iran
    f = figure('Units','inches','Position',[loc loc fwidth fwidth/2.2], ...
    'PaperPosition',[.25 .25 8 6]);
    hold on;

    worldmap(["Ireland", "Iran"])
    axis xy

    % color map with A
    geoshow(sum(A,3), R, 'DisplayType', 'texturemap')
    %make sea white
    geoshow(fliplr([land.Lat]),fliplr([land.Lon]),'DisplayType', ...
        'Polygon', 'FaceColor', 'white')

    framem('FLineWidth', 1, 'FontSize', 7)

    % add pinhasi sites and set the color to reflect bp
    scatterm(pinhasi.lat, pinhasi.lon, 10, 'r', 'filled')
end