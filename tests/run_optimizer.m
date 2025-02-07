clear all
clc

function [error, grad, hessian] = optimize_model(theta, parameters, factor)
    result = run_model(parameters, theta);
    error = result.squared_error;
    if nargout > 1
        f = @(theta) run_model(parameters, theta).squared_error;
        grad = calculateGradient(f, theta, 0.01, factor);
    end
    if nargout > 2
        hessian = calculateHessian(f, theta, 0.01);
    end
end

function stop = saveIterations(x, optimValues, state)
    % Persistent variable to store the fitted parameters
    persistent paramsHistory

    % Initialize if the state is 'init'
    if strcmp(state, 'init')
        paramsHistory = []; % clear history at the beginning
    end

    % Append current parameters to the history during iterations
    if strcmp(state, 'iter')
        paramsHistory = [paramsHistory; x]; 
        assignin('base', 'paramsHistory', paramsHistory); % Save to workspace
    end

    % No stopping criterion
    stop = false;
end

ns = [10, 50, 100, 200, 1000];
thetas = [];
fmins = [];

for n = 1:length(ns)
    active_layers = [1 0 1 0 0];
    cobo = readtable( ...
         'data/raw/cobo_etal/cobo_etal_data.xlsx');
    parameters = data_prep(ns(n), active_layers, cobo.Latitude, cobo.Longitude, cobo.Est_DateMean_BC_AD_);
    
    theta_start = [-1.1234 0.4332];
    
    objective_function = @(theta) optimize_model(theta, parameters, 1);
    
    
    options = optimset(...
                'Display', 'iter', ...
                'TolX', 1e-4, ...
                'TolFun', 1e-4 ...
                );
    
    [theta_min, fval, exitflag, output] = fminsearch(objective_function, theta_start, options);
    disp(theta_min)
    thetas = [thetas; theta_min];
    fmins = [fmins fval];
end