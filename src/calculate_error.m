
function error = calculate_error(A, data)
    error = 0;
    for event_index = 1:length(data)
        new_error = abs(1-A(data(event_index,1),data(event_index,2),data(event_index,3)));
        error = error + new_error;
    end
end