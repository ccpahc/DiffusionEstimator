function [best_theta, best_result, info] = grad_descent(theta0, parameters, options)
%GRAD_DESCENT Robust stochastic descent for noisy/non-convex run_model objectives.
%   [best_theta, best_result, info] = grad_descent(theta0, parameters, options)
%   minimizes run_model(parameters, theta).squared_error.
%
%   This optimizer is designed for noisy objectives and local minima:
%   - Multi-start restarts
%   - SPSA gradient estimates (noise-tolerant, 2 evaluations per sample)
%   - Momentum with step-size decay
%   - Backtracking
%   - Stagnation-triggered random basin hopping
%
%   Optional fields in options:
%     max_iters (default 150)
%     n_starts (default 8)
%     step_size (default 0.08)
%     step_decay (default 0.995)
%     min_step_size (default 1e-4)
%     momentum (default 0.85)
%     tol_grad (default 1e-4)
%     tol_improve (default 1e-7)
%     stagnation_patience (default 20)
%     fd_eps (default 5e-3)              % used when gradient_method='finite'
%     gradient_method (default 'spsa')   % 'spsa' or 'finite'
%     grad_samples (default 3)
%     obj_samples (default 3)
%     perturb_scale (default 0.1)
%     perturb_decay (default 0.99)
%     lb / ub (default -Inf/+Inf)
%     randomize_objective (default true)
%     random_seed (default 42)
%     verbose (default false)
%     use_parallel (default true)

    if nargin < 3
        options = struct();
    end

    theta0 = theta0(:)';
    n_theta = numel(theta0);

    max_iters = get_opt(options, 'max_iters', 150);
    n_starts = get_opt(options, 'n_starts', 8);
    step_size0 = get_opt(options, 'step_size', 0.08);
    step_decay = get_opt(options, 'step_decay', 0.995);
    min_step_size = get_opt(options, 'min_step_size', 1e-4);
    momentum = get_opt(options, 'momentum', 0.85);
    tol_grad = get_opt(options, 'tol_grad', 1e-4);
    tol_improve = get_opt(options, 'tol_improve', 1e-7);
    stagnation_patience = get_opt(options, 'stagnation_patience', 20);
    fd_eps = get_opt(options, 'fd_eps', 5e-3);
    gradient_method = lower(get_opt(options, 'gradient_method', 'spsa'));
    grad_samples = get_opt(options, 'grad_samples', 3);
    obj_samples = get_opt(options, 'obj_samples', 3);
    perturb_scale0 = get_opt(options, 'perturb_scale', 0.1);
    perturb_decay = get_opt(options, 'perturb_decay', 0.99);
    randomize_objective = get_opt(options, 'randomize_objective', true);
    random_seed = get_opt(options, 'random_seed', 42);
    verbose = get_opt(options, 'verbose', false);
    use_parallel = get_opt(options, 'use_parallel', true);

    lb = get_opt(options, 'lb', -inf(1, n_theta));
    ub = get_opt(options, 'ub', inf(1, n_theta));
    lb = reshape(lb, 1, []);
    ub = reshape(ub, 1, []);
    if numel(lb) ~= n_theta || numel(ub) ~= n_theta
        error('options.lb and options.ub must match length(theta0).');
    end

    best_theta = project(theta0, lb, ub);
    [best_f0, best_result0] = eval_objective(best_theta, parameters, lb, ub, 0, 0, obj_samples, randomize_objective, random_seed);

    rng(random_seed);
    start_thetas = zeros(n_starts, n_theta);
    start_thetas(1,:) = best_theta;
    for s = 2:n_starts
        start_thetas(s,:) = project(theta0 + perturb_scale0 * randn(size(theta0)), lb, ub);
    end

    info = struct();
    info.best_error = best_f0;
    info.history_best_error = nan(n_starts, max_iters);
    info.history_start_best_error = nan(n_starts, 1);
    info.iterations_per_start = zeros(n_starts, 1);
    info.settings = options;
    info.used_parallel = false;

    local_best_theta = zeros(n_starts, n_theta);
    local_best_error = inf(n_starts, 1);
    local_best_result = cell(n_starts, 1);
    history_best_error = nan(n_starts, max_iters);
    iterations_per_start = zeros(n_starts, 1);
    history_start_best_error = nan(n_starts, 1);

    cfg = struct();
    cfg.max_iters = max_iters;
    cfg.step_size0 = step_size0;
    cfg.step_decay = step_decay;
    cfg.min_step_size = min_step_size;
    cfg.momentum = momentum;
    cfg.tol_grad = tol_grad;
    cfg.tol_improve = tol_improve;
    cfg.stagnation_patience = stagnation_patience;
    cfg.fd_eps = fd_eps;
    cfg.gradient_method = gradient_method;
    cfg.grad_samples = grad_samples;
    cfg.obj_samples = obj_samples;
    cfg.perturb_scale0 = perturb_scale0;
    cfg.perturb_decay = perturb_decay;
    cfg.randomize_objective = randomize_objective;
    cfg.random_seed = random_seed;
    cfg.verbose = verbose;

    can_parallel = use_parallel && has_parallel_toolbox();
    if can_parallel
        info.used_parallel = true;
        parfor s = 1:n_starts
            [theta_s, f_s, res_s, hist_s, iters_s] = run_single_start( ...
                start_thetas(s,:), s, parameters, lb, ub, cfg, false);
            local_best_theta(s,:) = theta_s;
            local_best_error(s) = f_s;
            local_best_result{s} = res_s;
            history_best_error(s,:) = hist_s;
            iterations_per_start(s) = iters_s;
            history_start_best_error(s) = f_s;
        end
    else
        for s = 1:n_starts
            [theta_s, f_s, res_s, hist_s, iters_s] = run_single_start( ...
                start_thetas(s,:), s, parameters, lb, ub, cfg, verbose);
            local_best_theta(s,:) = theta_s;
            local_best_error(s) = f_s;
            local_best_result{s} = res_s;
            history_best_error(s,:) = hist_s;
            iterations_per_start(s) = iters_s;
            history_start_best_error(s) = f_s;
        end
    end

    info.history_best_error = history_best_error;
    info.iterations_per_start = iterations_per_start;
    info.history_start_best_error = history_start_best_error;

    [best_f_starts, best_start_idx] = min(local_best_error);
    if best_f_starts < best_f0
        best_theta = local_best_theta(best_start_idx,:);
        best_result = local_best_result{best_start_idx};
        best_f = best_f_starts;
    else
        best_theta = project(theta0, lb, ub);
        best_result = best_result0;
        best_f = best_f0;
    end

    info.best_error = best_f;
    info.best_theta = best_theta;
end

function y = project(x, lb, ub)
    y = min(max(x, lb), ub);
end

function val = get_opt(options, field_name, default_val)
    if isfield(options, field_name)
        val = options.(field_name);
    else
        val = default_val;
    end
end

function [theta_best, f_best, result_best, history_row, iter_done] = run_single_start(theta_init, start_idx, parameters, lb, ub, cfg, print_progress)
    rng(cfg.random_seed + 10000 * start_idx);
    theta = project(theta_init, lb, ub);
    [f_curr, res_curr] = eval_objective(theta, parameters, lb, ub, start_idx, 0, cfg.obj_samples, cfg.randomize_objective, cfg.random_seed);
    theta_best = theta;
    f_best = f_curr;
    result_best = res_curr;
    v = zeros(size(theta));
    no_improve = 0;
    history_row = nan(1, cfg.max_iters);

    if print_progress
        fprintf('Start %d: f0 = %.6g\n', start_idx, f_curr);
    end

    iter_done = cfg.max_iters;
    for it = 1:cfg.max_iters
        eta = max(cfg.min_step_size, cfg.step_size0 * cfg.step_decay^(it - 1));
        jump_scale = cfg.perturb_scale0 * cfg.perturb_decay^(it - 1);

        g = estimate_gradient(theta, start_idx, it, parameters, lb, ub, cfg);
        g_norm = norm(g);
        if g_norm < cfg.tol_grad
            iter_done = it;
            break;
        end

        v = cfg.momentum * v + (1 - cfg.momentum) * g;
        theta_try = project(theta - eta * v, lb, ub);
        [f_try, res_try] = eval_objective(theta_try, parameters, lb, ub, start_idx, it, cfg.obj_samples, cfg.randomize_objective, cfg.random_seed);

        accepted = false;
        if f_try <= f_curr - cfg.tol_improve
            accepted = true;
        else
            eta_bt = eta;
            for bt = 1:3
                eta_bt = 0.5 * eta_bt;
                theta_bt = project(theta - eta_bt * v, lb, ub);
                [f_bt, res_bt] = eval_objective(theta_bt, parameters, lb, ub, start_idx, it + bt, cfg.obj_samples, cfg.randomize_objective, cfg.random_seed);
                if f_bt <= f_curr - cfg.tol_improve
                    theta_try = theta_bt;
                    f_try = f_bt;
                    res_try = res_bt;
                    accepted = true;
                    break;
                end
            end
        end

        if accepted
            theta = theta_try;
            f_curr = f_try;
            res_curr = res_try;
            no_improve = 0;
        else
            no_improve = no_improve + 1;
            theta_jump = project(theta + jump_scale * randn(size(theta)), lb, ub);
            [f_jump, res_jump] = eval_objective(theta_jump, parameters, lb, ub, start_idx, it, cfg.obj_samples, cfg.randomize_objective, cfg.random_seed);
            if f_jump < f_curr
                theta = theta_jump;
                f_curr = f_jump;
                res_curr = res_jump;
                no_improve = 0;
            end
        end

        if f_curr < f_best
            f_best = f_curr;
            theta_best = theta;
            result_best = res_curr;
        end

        history_row(it) = f_best;

        if no_improve >= cfg.stagnation_patience
            theta = project(theta_best + jump_scale * randn(size(theta)), lb, ub);
            [f_curr, res_curr] = eval_objective(theta, parameters, lb, ub, start_idx, it, cfg.obj_samples, cfg.randomize_objective, cfg.random_seed);
            no_improve = 0;
        end

        if print_progress && (mod(it, 10) == 0 || it == 1)
            fprintf('  it=%d f=%.6g local_best=%.6g |g|=%.3g\n', it, f_curr, f_best, g_norm);
        end
    end
end

function g = estimate_gradient(theta, start_idx, iter_idx, parameters, lb, ub, cfg)
    g = zeros(size(theta));
    switch cfg.gradient_method
        case 'spsa'
            c = cfg.fd_eps;
            for k = 1:cfg.grad_samples
                delta = sign(rand(size(theta)) - 0.5);
                delta(delta == 0) = 1;
                [f_plus, ~] = eval_objective(theta + c * delta, parameters, lb, ub, start_idx, iter_idx + 2 * k, 1, cfg.randomize_objective, cfg.random_seed);
                [f_minus, ~] = eval_objective(theta - c * delta, parameters, lb, ub, start_idx, iter_idx + 2 * k + 1, 1, cfg.randomize_objective, cfg.random_seed);
                g = g + (f_plus - f_minus) ./ (2 * c * delta);
            end
            g = g / cfg.grad_samples;
        case 'finite'
            for i = 1:numel(theta)
                e = zeros(size(theta));
                e(i) = cfg.fd_eps;
                [f_plus, ~] = eval_objective(theta + e, parameters, lb, ub, start_idx, iter_idx + 2 * i, 1, cfg.randomize_objective, cfg.random_seed);
                [f_minus, ~] = eval_objective(theta - e, parameters, lb, ub, start_idx, iter_idx + 2 * i + 1, 1, cfg.randomize_objective, cfg.random_seed);
                g(i) = (f_plus - f_minus) / (2 * cfg.fd_eps);
            end
        otherwise
            error('Unsupported gradient_method: %s', cfg.gradient_method);
    end
end

function [f_mean, result_out] = eval_objective(theta_eval, parameters, lb, ub, start_idx, iter_idx, n_samples, randomize_flag, random_seed)
    theta_eval = project(theta_eval, lb, ub);
    errs = zeros(n_samples, 1);
    result_out = struct();
    for j = 1:n_samples
        params_eval = parameters;
        if randomize_flag
            params_eval.random = random_seed + 100000 * start_idx + 1000 * iter_idx + j;
        end
        res = run_model(params_eval, theta_eval);
        errs(j) = res.squared_error;
        if j == 1
            result_out = res;
        end
    end
    f_mean = mean(errs);
end

function tf = has_parallel_toolbox()
    tf = ~isempty(ver('parallel')) && license('test', 'Distrib_Computing_Toolbox');
end
