function error = calculate_error(A, data, type)

    [r,~] = size(data);
    [~, ~, t] = size(A);
    errors = zeros(r,1);
    t_simulations = zeros(r,1);

    for event_index = 1:r
        simulation_timeseries = A(data(event_index,1), data(event_index,2), :);
        if all(simulation_timeseries == 0)
            t_simulations(event_index) = 50 + t;
        else
            t_simulations(event_index) = find(simulation_timeseries, 1);
        end
    end
    t_pinhasi = data(:,3);
    if type == "absolute"
        errors = abs(t_pinhasi - t_simulations);
    elseif type == "squared"
        errors = (t_pinhasi - t_simulations).^2;
    elseif type == "root"
        errors = sqrt((t_pinhasi - t_simulations));
    elseif type == "full"
        errors = t_pinhasi - t_simulations;
    elseif type == "average"
        errors = t_pinhasi - t_simulations;
    end

    if type == "full"
        error = errors;
    elseif type == "average"
        error = abs(mean(errors)) + std(errors)^2;
    else
        error = mean(errors);
    end
end
