clear
clc

% figure

% Add the directory containing run_model.m to the MATLAB path
addpath('src');
rng(12) % set random seed

% choose whether to load pinhasi dataset or create a dataset
parameters = data_prep(20);
% theory_theta = [0.15 0.05 0.1];
% parameters = create_dataset(theory_theta, 20, [53.0627, 43.6865]);
% data_prep creates parameters struct with the following fields:
% parameters.A - initial matrix
% parameters.T - number of time steps
% parameters.terrain - terrain data
% parameters.dataset_idx - matrix storing index coordinates of dataset sites
% parameters.datset_lat - latitude of dataset sites
% parameters.dataset_lon - longitude of dataset sites
% parameters.dataset_bp - years before present of dataset sites
% parameters.dt - time step in years
% parameters.start_time - start time
% parameters.end_time - end time
% parameters.lat - first and last latitude
% parameters.lon - first and last longitude
% parameters.n - number of averages

%%

% theta(1) - average diffusion speed E-W
% theta(2) - average diffusion speed N-S
% theta(3) - contribution of terrain (b1)

theta_0 = linspace(0.0,1,51);
theta_1 = [0];%linspace(-0.05,0.05,11);
theta_2 = linspace(0.0,1.5,50);
all_errors = zeros(length(theta_0),length(theta_1),length(theta_2));
flag_1 = zeros(length(theta_0),length(theta_1),length(theta_2));
flag_2 = zeros(length(theta_0),length(theta_1),length(theta_2));
for t = 1:length(theta_2)
    for y = 1:length(theta_1)
        for x = 1:length(theta_0)
            theta = [theta_0(x), theta_1(y), theta_2(t)];
            tic
            result = run_model(parameters, theta);
            disp(toc)
            all_errors(x,y,t) = result.squared_error*parameters.dt;
            flag_1(x,y,t) = result.exitflag_1;
            flag_2(x,y,t) = result.exitflag_2;
            disp(theta);
            disp(all_errors(x,y,t));

        end
    end
end

save("pinhasi_dataset_theta_0_2.mat","all_errors","theta_0","theta_1","theta_2","flag_1","flag_2",'-mat')
disp("Done!")