addpath('src');

load("C:\Users\mperuzzo\OneDrive - Nexus365\Documents\bottlenecks\generated_data\cobo_av_sea_100av_2026-01-06_09-18.mat")
load("C:\Users\mperuzzo\OneDrive - Nexus365\Documents\bottlenecks\generated_data\cobo_sweep_2d.mat")
[min_error,min_idx] = min(all_errors(:));

[min_x, min_y, min_z] = ind2sub(size(all_errors),min_idx);

errors = squeeze(all_errors(:,:,min_z));
figure(1)
hold on;
imagesc(theta_0, theta_1, errors')
clim([min_error, 1.5e6])
%%
reduced_theta_0 = theta_0(theta_0>-0.95);
reduced_theta_1 = theta_1(theta_1>-1.75 & theta_1<-1.55);
% objective_function = @(theta) optimize_model(theta, parameters, 1);
grads = zeros(length(reduced_theta_0(1:8:end)), length(reduced_theta_1(1:8:end)), 2);
for th_0=reduced_theta_0(1:8:end)
    disp(th_0)
    for th_1=reduced_theta_1(1:8:end)
        theta_start_xy = [th_0 th_1];
        dtheta = 0.1;
        grad = calculateGradient(objective_function, theta_start_xy, dtheta, 1);
        quiver(theta_start_xy(1), theta_start_xy(2), -grad(1)/1e7, -grad(2)/1e7, 'k')
        grads(find(theta_0 == th_0),find(theta_1 == th_1), :) = grad;
    end
end
%%
for th_0=reduced_theta_0(1:4:end)
    for th_1=reduced_theta_1(1:4:end) 
        theta_start_xy = [th_0 th_1];
        grad = [grads(find(theta_0 == th_0), find(theta_1 == th_1), 1),grads(find(theta_0 == th_0),find(theta_1 == th_1), 2)];
        quiver(th_0, th_1, grad(1)/1e7, grad(2)/1e7)
    end
end

%%
% objective_function = @(theta) optimize_model(theta, parameters, 1);
theta_start_xy = [theta_start(1) theta_start(2)];

iter = 3;
grads = zeros(iter,2);

for i = 1:iter
    disp(i)
    dtheta = 0.02;
    grad = calculateGradient(objective_function, theta_start_xy, dtheta, 1);
    grads(i,:) = grad;
    step = -0.02*grad/norm(grad);
    quiver(theta_start_xy(1), theta_start_xy(2), step(1), step(2), 'y')
    new_theta = theta_start_xy + step';
    scatter(new_theta(1), new_theta(2),'y.')
    theta_start_xy = new_theta;

end

%%

scatter(theta_start(1), theta_start(2),'k.')
scatter(theta_optim(1), theta_optim(2),'r.')

eps = 0.01;
npoints = 11;
f = zeros(npoints,npoints);
theta_x = theta_optim(1) + linspace(-0.05, 0.05, npoints);
theta_y = theta_optim(2) + linspace(-0.05, 0.05, npoints);
for ex = 1:npoints
    ex
    for ey = 1:npoints
        th = [theta_x(ex) theta_y(ey)];
        f(ex,ey) = objective_function(th);
    end
end

%%
imagesc(theta_x, theta_y, f')
hold on;
scatter(theta_start(1), theta_start(2),'k.')
scatter(theta_optim(1), theta_optim(2),'r.')
dtheta = 0.1;
% objective_function = @(theta) optimize_model(theta, parameters, 1);

function result = optimize_function_mean(theta,parameters)
% Evaluate the new theta and update the objective function value
    obj_functions = [];
    sweeps = [-0.005 +0.005];
    obj_functions(1) = run_model(parameters, theta).squared_error;
    for i=1:length(theta)
        for s = 1:length(sweeps)
            new_theta = theta;
            new_theta(i) = theta(i) + sweeps(s);

            obj_functions(end+1) = run_model(parameters,theta).squared_error;
        end
    end
    result = mean(obj_functions);
    
end

objective_function = @(theta) optimize_function_mean(theta, parameters);

%%
function new_theta = step_func(theta_start, objective_function,dtheta)
    
    direction = 0;
    same_dir = true;
    grad = calculateGradient(objective_function, theta_start, dtheta,1);
    obj = objective_function(theta_start);
    fprintf('Start objective function: %d\n',obj)
    step = -obj./(grad+3000)/5e2;
    
   while same_dir & (norm(step) > 0.01)
        % take step
        new_theta = theta_start + step';
        new_obj = objective_function(new_theta);
        fprintf('New objective function: %d\n',new_obj)
        if new_obj > obj
            step = step*0.7;
            fprintf('Overshoot, taking a smaller step: %d\n',norm(step))
            
            if direction ~= -1
                same_dir = true;
                direction = 1;

            else
                same_dir = false;
                step = step/0.7;
            end
        elseif new_obj < obj
            step = step*1.3;
            fprintf('Undershoot, taking a larger step: %d\n',norm(step))

            if direction ~= 1
                same_dir = true;
                direction = -1;
                obj = new_obj;
 
            else
                same_dir = false;
                step = step/1.3;
            end
        end 

    

   end
   new_theta = theta_start+step';
end

new_theta = step_func(theta_start, objective_function,0.2);
scatter(new_theta(1), new_theta(2),'.b')
new_theta = step_func(new_theta, objective_function,0.1);
scatter(new_theta(1), new_theta(2),'.m')
new_theta = step_func(new_theta, objective_function,0.05);
scatter(new_theta(1), new_theta(2),'.r')
new_theta = step_func(new_theta, objective_function,0.02);
scatter(new_theta(1), new_theta(2),'.c')