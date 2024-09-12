clear
clc

function error = optimize_model(theta, parameters)
    % Call run_model with the given theta
    
    A = parameters.A;
    terrain = parameters.terrain;
    pinhasi_active = parameters.pinhasi_dataset;
    T = parameters.T;
    [~, error] = run_model(20, A, T, theta, terrain, pinhasi_active);

end

% figure

if true
    % Add the directory containing run_model.m to the MATLAB path
    addpath('src');
    rng(12) % set random seed

    parameters = data_prep();
    % data prep creates parameters struct with the following fields:
    % parameters.A - initial matrix
    % parameters.T - number of time steps
    % parameters.terrain - terrain data
    % parameters.pinhasi_dataset - matrix storing x,y,t coordinates of pinhasi sites
    % parameters.dt - time step in years
    % parameters.start_time - start time
    % parameters.end_time - end time
    % parameters.lat - first and last latitude
    % parameters.lon - first and last longitude

    

    % theta(1) - average diffusion speed E-W
    % theta(2) - average diffusion speed N-S
    % theta(3) - contribution of terrain (b1)

    objective_function = @(theta) optimize_model(theta,parameters);

    % initial guess
    theta0 = [0.01 0.01 0.01];

    options = optimoptions('fminunc', ...
        'Display', 'iter', ...
        "PlotFcn","optimplotx", ...
        'Algorithm', 'quasi-newton', ...
        'FiniteDifferenceType', 'central', ...
        'StepTolerance', 1e-18, ...,
        "FiniteDifferenceStepSize", 2e-5, ...,
        "UseParallel", true);

    tic
    % Run fminunc
    [theta, fval, exitflag, output, grad, hessian] = fminunc(objective_function, theta0, options);
    disp("Elapsed time: " + toc + " seconds");


    [A,error] = run_model(20, parameters.A, parameters.T, theta, parameters.terrain, parameters.pinhasi_dataset);

    % Output the results
    disp('Optimized Parameters:');
    disp(theta);

    disp('Error:');
    disp(error);
    
    errors = calculate_error(A, parameters.pinhasi_dataset, "full")*parameters.dt;

    plot_map(parameters, errors);
    figure(3)
    hold on;
    histogram(errors)
    title('Error histogram')
    xlabel('Error')
    ylabel('Frequency')
    fprintf('Elapsed time: %.2f seconds\n', toc);
end

% 0.0514    0.0086    0.0239