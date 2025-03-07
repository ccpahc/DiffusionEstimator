clear
clc

% figure

% Add the directory containing run_model.m to the MATLAB path
addpath('src');
rng(12) % set random seed
dataset = 'pinhasi';

if strcmp(dataset,'pinhasi')
    % load pinhasi
    pinhasi = readtable( ...
        'data/raw/pinhasi/Neolithic_timing_Europe_PLOS.xls');

    pinhasi = pinhasi(pinhasi.Var1 == "SITE",:); %% keep only site rows

    pinhasi = renamevars(pinhasi, {'Latitude', 'Longitude', 'CALC14BP'}, ...
        {'lat', 'lon', 'bp'});

    pinhasi = pinhasi(:,{'lat', 'lon', 'bp'});
    pinhasi.bp = 2000 - pinhasi.bp; % from BP to year

    x = pinhasi.lat;
    y = pinhasi.lon;
    t = pinhasi.bp;

elseif strcmp(dataset,'cobo')
    % LOAD COBO et al

    cobo = readtable( ...
         'data/raw/cobo_etal/cobo_etal_data.xlsx');

    x = cobo.Latitude;
    y = cobo.Longitude;
    t = cobo.Est_DateMean_BC_AD_;
end
active_layers = [1 0 1 0 0 0 0];
parameters = data_prep(50, active_layers, x, y, t);

%%

ranges = [[-2, 2.0]; [-2.0,2.0]];
n_points = 51;
[theta_min, on_edge, min_error, errors] = sweep(ranges, n_points, 0, parameters);
theta_0 = linspace(ranges(1,1), ranges(1,2), n_points);
theta_1 = linspace(ranges(2,1), ranges(2,2), n_points);
all_errors = reshape(errors, [n_points,n_points]);
% 
save("norm2.mat","all_errors","theta_0","theta_1",'-mat')
disp("Done!")

