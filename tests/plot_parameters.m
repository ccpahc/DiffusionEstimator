addpath('src');

parameters = data_prep(20);

theta_0 = 0.127;
theta_1 = 0.04;
theta_2 = 0.129;
theta = [theta_0 theta_1 theta_2]

result = run_model(parameters, theta);

errors = calculate_error(parameters.dataset_idx, result.times, "full")*parameters.dt;
calculate_error(parameters.dataset_idx, result.times, "absolute")*parameters.dt
plot_map(parameters, errors);
figure(3)
hold on;
histogram(errors)
title('Error histogram')
xlabel('Error')
ylabel('Frequency')
fprintf('Elapsed time: %.2f seconds\n', toc);
