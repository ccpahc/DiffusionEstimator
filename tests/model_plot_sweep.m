clear
clc

% figure

% Add the directory containing run_model.m to the MATLAB path
addpath('src');
rng(12) % set random seed
dataset = 'cobo';
[x,y,t] = get_dataset(dataset);
active_layers = [  1   0   0   0   1   1   0   0   0  ];
parameters = data_prep(50, active_layers, x, y, t);

theta_prec = linspace(2,4,51);
theta_tmean = linspace(-2,2,51);
errors = zeros(51);

for t1 = 1:51
    for t2=1:51
        theta = [0.65 theta_prec(t1) theta_tmean(t2)];
        result = run_model(parameters, theta);
        errors(t1,t2) = result.squared_error;

    end
end

save("model_plot_sweep.mat","all_errors","theta_prec","theta_tmean",'-mat')