addpath('src');

% Test harness for the new robust optimizer: grad_descent.m
% This script checks that optimization improves (or at least does not worsen)
% the run_model objective from a chosen starting theta.

clearvars;
clc;

data_file = fullfile(pwd, 'generated_data', 'cobo_av_sea_100av_2026-01-06_09-18.mat');
if ~isfile(data_file)
    error('Missing data file: %s', data_file);
end
load(data_file); % expects variables: parameters, theta_start (or similar)

if ~exist('parameters', 'var')
    error('The loaded file must contain a variable named "parameters".');
end

if exist('theta_start', 'var')
    theta0 = theta_start(:)';
elseif exist('theta_optim', 'var')
    theta0 = theta_optim(:)';
else
    error('No theta initializer found. Expected "theta_start" or "theta_optim" in MAT file.');
end

opts = struct();
opts.n_starts = 10;
opts.max_iters = 120;
opts.step_size = 0.08;
opts.step_decay = 0.995;
opts.min_step_size = 1e-4;
opts.momentum = 0.85;
opts.gradient_method = 'spsa';
opts.fd_eps = 0.01;
opts.grad_samples = 4;
opts.obj_samples = 3;
opts.perturb_scale = 0.12;
opts.perturb_decay = 0.99;
opts.stagnation_patience = 15;
opts.randomize_objective = true;
opts.random_seed = 123;
opts.verbose = true;

% Optional bounds: uncomment and adjust if you have known parameter ranges.
% opts.lb = [-5 -5];
% opts.ub = [ 5  5];

base_result = run_model(parameters, theta0);
base_error = base_result.squared_error;

[theta_best, result_best, info] = grad_descent(theta0, parameters, opts);
best_error = result_best.squared_error;

fprintf('\n=== grad_descent test summary ===\n');
fprintf('Initial theta: %s\n', mat2str(theta0, 6));
fprintf('Best theta:    %s\n', mat2str(theta_best, 6));
fprintf('Initial error: %.12g\n', base_error);
fprintf('Final error:   %.12g\n', best_error);
fprintf('Improvement:   %.12g (%.3f%%)\n', ...
    base_error - best_error, 100 * (base_error - best_error) / max(base_error, eps));
fprintf('Reported best in info: %.12g\n', info.best_error);

% Regression check: this should usually pass for a healthy optimizer setup.
assert(best_error <= base_error + 1e-10, ...
    'grad_descent did not improve objective (start=%.12g, final=%.12g).', ...
    base_error, best_error);

disp('PASS: grad_descent reduced or matched squared_error.');
