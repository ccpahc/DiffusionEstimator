clear all
clc

plot_landscape = true;

factor = .01;


function error = optimize_model(theta, parameters)
    factor = .01;
    theta = theta/factor;
    % Call run_model with the given theta
    theta = [theta(1) 10^(theta(2))*theta(1) 0.0];
    result = run_model(parameters, theta);
    error = result.squared_error;
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



% figure

if true
    % Add the directory containing run_model.m to the MATLAB path
    addpath('src');
    
    % choose whether to load pinhasi dataset or create a dataset
    parameters = data_prep(20);
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

    

    % theta(1) - average diffusion speed E-W
    % theta(2) - average diffusion speed N-S
    % theta(3) - contribution of terrain (b1)

    objective_function = @(theta) optimize_model(theta,parameters);

    % initial guess
    theta0 = [0.2 -0.0]*factor;

    options = optimoptions('fminunc', ...
        'Display', 'iter', ...
        'Algorithm', 'quasi-newton', ...
        'FiniteDifferenceType', 'central', ...
        'StepTolerance', 1e-9*factor, ...,
        "FiniteDifferenceStepSize", 0.01*factor, ...,
        "FunctionTolerance",0.5, ...
        "OptimalityTolerance",2e-6/factor, ...
        'MaxFunctionEvaluations', 10000, ...
        'MaxIterations', 10000, ...
        'OutputFcn', @saveIterations, ... % Call the custom function
        "UseParallel", true);

    tic
    % Run fminunc
    
    [theta, fval, grad, hessian, exitflag, output] = fminunc(objective_function, theta0, options);
    disp("Elapsed time: " + toc + " seconds");

    theta = theta/factor;
    theta = [theta(1) theta(1)*10^(theta(2)) 0.0]/factor;

    
    result = run_model(parameters,theta);

    A = result.A;
    error = result.squared_error;
    times = result.times;
    % Output the results
    % disp('Optimized Parameters:');
    % disp(theta);
    % 
    % disp('Error:');
    % disp(error);
    
    % errors = calculate_error(parameters.dataset_idx, result.times, "full")*parameters.dt;
    % 
    % plot_map(parameters, errors);
    % figure(3)
    % hold on;
    % histogram(errors)
    % title('Error histogram')
    % xlabel('Error')
    % ylabel('Frequency')
    % fprintf('Elapsed time: %.2f seconds\n', toc);

    if plot_landscape
        load("all_errors_pinhasi_sweep.mat")
        dt = 20;
        error_slice = all_errors(:,:,1);
        [min_error, min_error_idx] = min(error_slice(:));
        [av_idx, r_idx] = ind2sub(size(error_slice), min_error_idx);
        
        [X,Y] = meshgrid(av_theta,log10(r_theta));
        
        % Define the three colors (RGB format):
        color1 = [23/255, 42/255, 80/255];   % Blue
        color2 = [235/255, 232/255, 198/255];   % White
        color3 = [80/255, 13/255, 23/255];   % Red
        
        % Number of points in your colormap:
        numColors = 256; 
        
        % Create a colormap by interpolating between these colors:
        cmap = interp1([1, 256], [color2; color3], linspace(1, 256, numColors));
        colormap(parula)
        
        figure(1)
        p = contourf(X,Y,squeeze(all_errors(:,:,1))');
        % set(p, 'CData',squeeze(all_errors(:,:,1))');
        colorbar;
        ylabel("log(ratio)")
        xlabel("average diffusion speed")
        % plot point with lowest error in red
        hold on
        plot(av_theta(av_idx), log10(r_theta(r_idx)), 'r*', 'MarkerSize',10)
        plot(paramsHistory(:,1)/factor,paramsHistory(:,2)/factor,'ro')
        plot(paramsHistory(:,1)/factor,paramsHistory(:,2)/factor,'r')
        % add text box with error value next to point with white background
        % annotation('textbox', [0.42 0.46 0.1 0.1], 'String', sprintf('error^{1/2} = %f', sqrt(min_error)), 'EdgeColor', 'none', 'BackgroundColor', 'white', 'HorizontalAlignment', 'center', 'FontSize', 14);
        max_abs_value = 50;

    end

end

% 0.0514    0.0086    0.0239