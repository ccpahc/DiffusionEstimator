clear
clc

% figure

% Add the directory containing run_model.m to the MATLAB path
addpath('src');
rng(12) % set random seed
dataset = 'cobo';
[x,y,t] = get_dataset(dataset);
active_layers = [  1   0   0   0   1   1   0   0   0  ];
parameters = data_prep(50, active_layers, x, y, t);

theta_prec = linspace(2,4,51);
theta_tmean = linspace(-2,2,51);
errors = zeros(51);

for t1 = 1:51
    for t2=1:51
        theta = [0.65 theta_prec(t1) theta_tmean(t2)];
        result = run_model(parameters, theta);
        errors(t1,t2) = result.squared_error;

    end
end

save("model_plot_sweep.mat","all_errors","theta_prec","theta_tmean",'-mat')

%% Plot
load("model_plot_sweep_small.mat")
%%
[X,Y] = meshgrid(theta_prec,theta_tmean);
points = [[2.28 -0.16 1.61543+0.07]; [2.92 -0.56 1.02808+0.05];  [3.16 -0.72 0.721299+0.05]; [3.24 -0.96 0.475222+0.05]; [3.24 -1.04 0.4348+0.05]; [3.2 -1.12 0.413622+0.05]];

f = figure(1)
hold on
f.Position = [100 100 700 400];
set(gcf, 'Color', 'White', 'Alphamap',0)
plot_errors = log(errors/1e6);
s = mesh(X,Y,plot_errors');
% Plot lines between points
lineColor = [110/255, 20/255, 30/255];
plot3(points(:,1), points(:,2), points(:,3), ...
    '-', 'LineWidth', 2.5, 'Color', lineColor);

% Plot points as scatter3
scatter3(points(:,1), points(:,2), points(:,3), ...
    50, lineColor, 'filled');
s.FaceColor = 'flat';
s.FaceAlpha = 1;
view([55 0])
xlim([2,3.5])
ylim([-2.,-0.])
pepper_bright = brighten(pepper, 0.3);
colormap(flipud(pepper_bright))
view([180-70 30])
ax = gca;
ax.FontSize = 16; 
xlabel("\theta_{prec}", 'Rotation', 55, "FontSize",16)
ylabel("\theta_{tmean}", 'Rotation', -5, "FontSize",16)
zlabel("Objective function (a.u.)", "FontSize",16)

saveas(gcf,"saved_plots/Obj_func.pdf")
