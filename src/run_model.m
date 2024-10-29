function result = run_model(parameters, theta)
    % create result structure
    result = struct();
    % unpack parameters structure
    A_start = parameters.A;
    X = parameters.terrain;
    data = parameters.dataset_idx;

    % Initialize the accumulators
    A_av = zeros(size(A_start));
    simulation_times = zeros(1,length(data));
    U = parameters.U;
    exitflag_1 = 0;
    exitflag_2 = 0;
    nt = parameters.T;

    parfor rep = 1:parameters.n
        % Run the model for each instance
        [A, exfl1] = run_model_av(A_start, nt, theta, X, U(:,:,:,rep));
        
        % calculate arrival times
        [times, exfl2] = calculate_times(A, data);
        A_av = A_av + double(A);  % Convert to double to accumulate          
        simulation_times = simulation_times + double(times)';
        exitflag_1 = exitflag_1 + exfl1;
        exitflag_2 = exitflag_2 + exfl2;

    end

    % Finalize the average
    simulation_times = simulation_times / parameters.n;
    A_av = A_av / parameters.n;

    % assign values to result structure
    result.A = A_av;
    result.times = simulation_times;
    result.errors = calculate_error(data, simulation_times, "full");
    result.squared_error = calculate_error(data, simulation_times, "squared");
    result.exitflag_1 = exitflag_1/parameters.n;
    result.exitflag_2 = exitflag_2/parameters.n;

end


function [A, exitflag] = run_model_av(A_start, nt, theta, X, U)
    A = A_start;
    U = squeeze(U);
    flag = 0;
    for t = 2:nt
        [extflg1, A(:,:,t)] = step(A(:,:,t-1), theta, X, U(:,:,t));
        flag = flag + extflg1/nt;
    end
    if nargout > 1
        exitflag = flag;
    end
end


function [exfl1,a] = step(a, theta, X, U)
    a = sparse(a);

    [Fn,Fs,Fw,Fe] = frontier(a); % find adjacent cells to currently activated ones
    F = Fn | Fs | Fw | Fe;
    % theta(1) - average diffusion speed 
    % theta(2) - anisotropy term
    % theta(3) - contribution of terrain (b1)

    % OLD -> M = theta(1) * (Fe|Fw) + theta(2) * (Fn|Fs) + theta(3) * F .* X;
    M = F.*(theta(1) + theta(2)*(Fe|Fw-Fn|Fs) + theta(3)*X);
    f = find(M); % indices of frontier cells
    U = squeeze(U);
    k = 5;
    probabilities = 1./(1 + exp(-k * (M(f) - 0.5)));
    adopt = U(f)<= probabilities;
    a(f(adopt)) = true; % update activated cells to include adopted
    exfl1 = mean(M(f));
    if isnan(exfl1)
        exfl1 = 0.5;
    end

end


function [fN, fS, fW, fE] = frontier(A)
    % FRONTIER finds all adjacent cells in a two-dimensional array A to
    % true cells.

    [m,n] = size(A);

    % North
    fN = [diff(A) > 0; false(1,n)];

    % South
    fS = [false(1,n); flipud(diff(flipud(A)) > 0)];

    % West
    fW = [(diff(A') > 0)', false(m,1)];

    % East
    fE = [false(m,1), (flipud(diff(flipud(A')) > 0))'];

    end
