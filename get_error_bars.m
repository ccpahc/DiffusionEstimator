clear
load('C:\Users\matil\OneDrive\Documents\Work\AlanTuring_Oxford\bottlenecks\generated_data\filename_database.mat')
addpath("src")
n_av = 50;
for nd = 1:length(database)
    disp(database{nd}.file)
    load(database{nd}.file)
    spread_errors_shuffle = zeros(n_av);
    
    for nav=1:n_av
        seed = randi(999);
        parameters.random = int16(seed);
        result = run_model(parameters, theta_optim);
        spread_errors_shuffle(nav) = result.squared_error;
    end
    parameters.random = 12;
    save(database{nd}.file, "spread_errors_shuffle", '-append');

    clear parameters; clear result;
end