%%
% 
% folder = 'generated_data\bootstraps_data\';
% file = struct2table(dir([folder, '*.mat'])).name;
% i = 2;
% figure()
% hold on;
% for i = 1:3
%     load([folder, file{i}])
%     [folder, file{i}]
%     if strfind(file{i},'wheat') == 5
%         [mean(theta_bootstrap(:,1))],[i],[std(theta_bootstrap(:,1))]
%         errorbar([mean(theta_bootstrap(:,1))],[i],[std(theta_bootstrap(:,1))],'horizontal')
%         xlim([-2,2])
%     end
% end
% ylim([0,4])
% %%
% load('generated_data\filename_database.mat')
% figure()
% ax = [subplot(1,3,1) subplot(1,3,2) subplot(1,3,3)];
% hold on
% for i=1:length(database)
%     if (length(database{i}.layers) == 2)
%         if ~(ismember('sea', database{i}.layers))
%             continue
%         end
%     elseif (length(database{i}.layers) == 1)
%         if ~(ismember('sea', database{i}.layers))
%             continue
%         end
%     end
% 
%     if strmatch(database{i}.dataset,'maize')
% 
%         disp(database{i}.file)
%         load(database{i}.file)
%         for j = 1:length(theta_optim)
% 
%             plot(ax(j),[theta_optim(j)],[i],'.','MarkerSize',20)
%         end
%     end
% 
% end
% xlim([-2,2])
% ylim([0,20])
% %% 
% load('generated_data\filename_database.mat')
% figure();
% set(gcf, 'Color', 'White', 'Alphamap',0)
% colors = copper(3);
% % Initialize subplots
% ax = [subplot(1,3,1), subplot(1,3,2), subplot(1,3,3)];
% 
% % Set consistent axes limits first
% for k = 1:3
%     hold(ax(k), 'on');
%     xlim(ax(k), [-4, 4]);
%     ylim(ax(k), [0, 7]);
% end
% 
% 
% markers = {'o','diamond','square'};
% crops = {'wheat','rice','maize'};
% legend_handles = gobjects(1,3);  % To hold plot handles for legend
% 
% for crop = 1:3
%     counter = 1; % To track y-position across subplots
%     for i = 1:length(database)
%         % Check for 'sea' layer (simplified condition)
%         if ~any(contains(database{i}.layers, 'sea'))
%             continue;
%         end
% 
%         % Process only rice datasets
%         if strcmp(database{i}.dataset, crops{crop})
%             disp(database{i}.file);
%             load(database{i}.file);
%             disp(theta_optim)
%             if length(theta_optim) > 2
%                 theta_optim([2 3]) = theta_optim([3 2]);
%             end
%             % Plot each theta value in corresponding subplot
%             for j = 1:min(3, length(theta_optim)) % Ensure we don't exceed 3 subplots
%                 % plot(ax(j), theta_optim(j), counter, markers{crop}, 'MarkerSize', 5, 'Color',colors(crop,:), 'MarkerFaceColor', colors(crop,:));
%                 h = plot(ax(j), theta_optim(j), counter, markers{crop}, ...
%                      'MarkerSize', 5, ...
%                      'Color', colors(crop,:), ...
%                      'MarkerFaceColor', colors(crop,:));
%                 if j == 1 && counter == 1
%                     legend_handles(crop) = h;
%                 end
%             end
% 
%             counter = counter + 1; % Increment y-position
%         end
%     end
% end
% % Add labels
% thetas = {'av','sea','layer'};
% for k = 1:3
%     xlabel(ax(k), sprintf('$\\theta_{%s}$', thetas{k}),'FontSize', 8, 'Interpreter','latex');
%     ylabel(ax(k), []);
%     yticklabels(ax(k),[])
%     grid(ax(k), 'on');
%     xline(ax(k),0,'--k')
%     set(ax(k), 'TickLabelInterpreter', 'latex');
% 
% end
% yticks(ax(1),linspace(1,6,6));
% yticklabels(ax(1),{'anisotropy','rivers','precipitation','mean temperature','crop suitability','sea only'})
% t1.FontSize = 8;
% t1.Interpreter = 'latex';
% set(gca,"TickLabelInterpreter",'latex')
% legend(ax(3), legend_handles, crops, ...
%     'Location', 'northeast', ...
%     'FontSize', 8, ...
%     'Interpreter', 'latex');

%%
load('generated_data\filename_database.mat')
markers = {'o','diamond','square'};
crops = {'wheat','rice','maize'};
offset = [-0.0 0 0.0];
colors = [pepper(50,:);      
                pepper(150,:);  
                pepper(200,:)];

f = figure();
f.Position = [100 100 400 260];
vmax = 110.567/4;
subplot(5,5,2:10)
hold on
for i = 1:length(database)

    if any(contains(database{i}.layers, 'av'))
        disp(database{i}.layers)
        for c = 1:length(crops)
            if strmatch(database{i}.dataset,crops{c})
                load(database{i}.file)
                prob = 1/(1+exp(-theta_optim(1)));
                v = prob*vmax;
                h = plot(v, 3 + offset(c), markers{c}, ...
                     'MarkerSize', 4, ...
                     'Color', colors(c,:), ...
                     'MarkerFaceColor', colors(c,:));
                legend_handles(c) = h;
            end
        end
    end


    if any(contains(database{i}.layers, 'sea')) & (length(database{i}.layers) == 1)
        disp(database{i}.layers)
        disp(database{i}.dataset)
        
        for c = 1:length(crops)
            if strmatch(database{i}.dataset,crops{c})
                load(database{i}.file)
                prob = 1/(1+exp(-theta_optim(1)));
                v = prob*vmax;
                
                h = plot(v, 2 + offset(c), markers{c}, ...
                     'MarkerSize', 4, ...
                     'Color', colors(c,:), ...
                     'MarkerFaceColor', colors(c,:));
            end
        end
    end

    if any(contains(database{i}.layers, 'sea')) & any(contains(database{i}.layers, 'prec'))
        disp(database{i}.layers)
        disp(database{i}.dataset)

        for c = 1:length(crops)
            if strmatch(database{i}.dataset,crops{c})
                load(database{i}.file)
                prob = 1/(1+exp(-theta_optim(1)));
                v = prob*vmax;
                h = plot(v, 1 + offset(c), markers{c}, ...
                     'MarkerSize', 4, ...
                     'Color', colors(c,:), ...
                     'MarkerFaceColor', colors(c,:));
            end
        end
    end
end
ylim([0,4])
xlim([-5,20])
xticks([-0,5,10,15])
yticks([1,2,3])
xline(0,'--k')
legend(legend_handles, crops, ...
    'Location', 'northeast', ...
    'FontSize', 6, ...
    'Interpreter', 'latex');
grid('on')
yticklabels({'sea and precipitation','sea only','baseline model'})
% ylabel('Model','FontSize', 12, ...
%     'Interpreter', 'latex')
set(gca,"TickLabelInterpreter",'latex', 'FontSize', 6)
set(gca, 'Units', 'normalized', 'Position', [0.25 0.7 0.7 0.25])  % [left bottom width height]
xlabel('average velocity (km/yr)', 'Interpreter','latex')


subplot(5,5,12:25)
hold on
for crop = 1:3
    counter = 1; % To track y-position across subplots
    for i = 1:length(database)
        % Check for 'sea' layer (simplified condition)
        if ~any(contains(database{i}.layers, 'sea')) | (length(database{i}.layers) < 2)
            continue;
        end
        
        if strcmp(database{i}.dataset, crops{crop})
            disp(database{i}.file);
            load(database{i}.file);
            prob_diff = 1/(1+exp(-(theta_optim(1)+theta_optim(2)))) - 1/(1+exp(-theta_optim(1)));
            v_diff = prob_diff*vmax;
          
            % plot(ax(j), theta_optim(j), counter, markers{crop}, 'MarkerSize', 5, 'Color',colors(crop,:), 'MarkerFaceColor', colors(crop,:));
            h = plot(v_diff, counter + offset(crop), markers{crop}, ...
                 'MarkerSize', 4, ...
                 'Color', colors(crop,:), ...
                 'MarkerFaceColor', colors(crop,:));
            % if j == 1 && counter == 1
            %     legend_handles(crop) = h;
            % end
           
            
            counter = counter + 1; % Increment y-position
        end
    end
end

ylim([0,6])
yticks([1,2,3,4,5])
xlim([-20,20])
xticks([-10,0,10])
grid('on')
yticklabels({'anisotropy','rivers','precipitation','mean temperature','crop suitability','sea only'})
set(gca,"TickLabelInterpreter",'latex')
xline(0,'--k')
% ylabel('Model','FontSize', 12, ...
%     'Interpreter', 'latex')
set(gca, 'Units', 'normalized', 'Position', [0.25 0.1 0.7 0.5], 'FontSize', 6)  % [left bottom width height]
xlabel('velocity difference (km/yr)', 'Interpreter','latex')
set(gcf, 'Color', 'White', 'Alphamap',0)
exportgraphics(gcf,'saved_plots/estimates.pdf','ContentType','vector')