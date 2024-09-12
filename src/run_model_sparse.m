function [A_av, error_av] = run_model_sparse(n, A_start, nt, theta, X, data)
    % Initialize the accumulators
    A_av = zeros(size(A_start));
    error_sum = 0;
    tic
    for rep = 1:n
        % Run the model for each instance
        tic
        A = run_model_av(A_start, nt, theta, X);

        error = calculate_error(A, data, "squared");

        % Accumulate the results
        error_sum = error_sum + error;
        A_av = A_av + double(A);  % Convert to double to accumulate
        %disp("Run " + rep + " completed in " + toc + " seconds");
    end
    % disp("All runs completed in " + toc + " seconds");
    % Finalize the average
    error_av = error_sum / n;
    A_av = A_av / n;
end


function A = run_model_av(A_start, nt, theta, X)
    A = A_start;

    [f_n, f_s, f_w, f_e] = frontier(A(:,:,1));
    f_x = (f_w + f_e)/2;
    f_y = (f_n + f_s)/2;
    for t = 2:nt
        [A(:,:,t), f_x, f_y] = step(A(:,:,t-1), theta, X, f_x, f_y);
    end

end

function [a, f_x, f_y] = step(a, theta, X, f_x, f_y)
    a = sparse(a);
    M = theta(1) * f_x + theta(2) * f_y + theta(3) * (f_x | f_y) .* X;
    f = find(M);
    adopt = rand(length(f),1) <= M(f); % which frontier cells adopt
    a(f(adopt)) = true; % update activated cells to include adopters

    f_x(f(adopt)) = 0;
    f_y(f(adopt)) = 0;
    [rows, columns] = ind2sub(size(a),f(adopt));

    for i=1:length(f(adopt))
        [size_x,size_y] = size(a);
        r = rows(i);
        c = columns(i);
        if r > 1
            if a(r-1,c) == 0
                f_x(r-1,c) = f_x(r-1,c)+0.5;
            end
        end

        if r < size_x 
            if a(r+1,c)==0
                f_x(r+1,c) = f_x(r+1,c)+0.5;
            end
        end

        if c > 1
            if a(r,c-1) == 0
                f_y(r,c-1) = f_y(r,c-1)+0.5;
            end
        end

        if c < size_y 
            if a(r,c+1)==0
                f_y(r,c+1) = f_y(r,c+1)+0.5;
            end
        end

    end
end


% 
% function a = step(a, theta, X)
%     % a = sparse(a);
%     %normalize c_x and c_y
%     [Fn,Fs,Fw,Fe] = frontier(a); % find adjacent cells to currently activated ones
%     F = Fn | Fs | Fw | Fe;
%     % theta(1) - average diffusion speed N-S
%     % theta(2) - average diffusion speed E-W
%     % theta(3) - contribution of terrain (b1)
% 
%     M = theta(1) * (Fn+Fs)/2 + theta(2) * (Fe+Fw)/2 + theta(3) * F .* X;
%     % M = abs(theta(1)) .* (cx * (Fe+Fw)/2 + cy * (Fn+Fs)/2) + theta(3) * F .* X;
%     f = find(M); % indices of frontier cells
% 
%     adopt = rand(length(f),1) <= M(f); % which frontier cells adopt
% 
%     a(f(adopt)) = true; % update activated cells to include adopters
% 
% end
% 
% 
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
