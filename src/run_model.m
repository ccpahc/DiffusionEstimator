
function A_av = run_model(n, A_start, nt, diff_speed, c_x, c_y, dt)
    A_av = zeros(size(A_start));
    for rep = 1:n
        A = run_model_av(A_start, nt, diff_speed, c_x, c_y, dt);
        A_av = A_av + A/n;
    end
end

function A = run_model_av(A_start, nt, diff_speed, c_x, c_y, dt)
    A = A_start;
    for t = 2:nt
        A(:,:,t) = step(A(:,:,t-1), diff_speed, c_x, c_y, dt);
    end

end

function a = step(a, diff_speed, c_x, c_y, dt)
    %normalize c_x and c_y
    norm_factor = norm([c_x, c_y]);
    c_x = c_x/norm_factor;
    c_y = c_y/norm_factor;
    [F, N] = map_frontier(a); % find adjacent cells to currently activated ones
    f = find(F); % indices of frontier cells
    [f_x, f_y] = ind2sub(size(F), f);
    factors = ones(1,length(f))+1;
    for k = 1:length(factors)
        x_dir = N(f_x(k),f_y(k),1);
        y_dir = N(f_x(k),f_y(k),2);
        factors(k) = diff_speed * dt * (abs(c_x*x_dir) + abs(c_y*y_dir));
    end
    adopt = rand(length(f),1) <= factors';

    a(f(adopt)) = true; % update activated cells to include adopters
    
end

function [F, normals] = map_frontier(a)
    % Get the size of the matrix
    [rows, cols] = size(a);
    % Initialize the frontier matrix
    F = false(rows, cols);
    % Initialize the normals matrix to store direction vectors
    normals = zeros(rows, cols, 2); % 2D vectors for each cell

    % Iterate through each cell in the matrix
    for r = 1:rows
        for c = 1:cols
            if a(r, c) % If the cell is activated
                % Check all 8 possible neighboring cells
                for i = -1:1
                    for j = -1:1
                        if i == 0 && j == 0
                            continue; % Skip the cell itself
                        end
                        nr = r + i; % Neighbor row index
                        nc = c + j; % Neighbor column index
                        % Check if neighbor is within bounds
                        if nr >= 1 && nr <= rows && nc >= 1 && nc <= cols
                            if ~a(nr, nc) % If neighbor is not activated
                                F(nr, nc) = true; % Mark as frontier
                                % Compute the normal vector
                                normals(nr, nc, 1) = normals(nr, nc, 1) + -i; % x component (opposite to the neighbor cell)
                                normals(nr, nc, 2) = normals(nr, nc, 2) + -j; % y component (opposite to the neighbor cell)
                            end
                        end
                    end
                end
            end
        end
    end

    % Normalize the normal vectors
    for r = 1:rows
        for c = 1:cols
            if F(r, c) % If the cell is a frontier
                normal_vector = squeeze(normals(r, c, :));
                norm_value = norm(normal_vector);
                if norm_value ~= 0
                    normals(r, c, :) = normals(r, c, :)/ norm_value;
                end
            end
        end
    end
end