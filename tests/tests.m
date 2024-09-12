% save("sweep_1_avg_dt_20.mat", "errors", "terrain_theta", "x_theta", "y_theta",'final_As');

disp(size(A))



[min_error, min_error_idx] = min(errors(:));
[terrain_idx, x_idx, y_idx] = ind2sub(size(errors), min_error_idx);


%% ERROR GIF
if false
    % Create a cell array to store the frames
    frames = cell(1, 10);

    for i = 1:length(terrain_theta)
        % Plot contour plots of errors standardizing the errors
        figure
        pcolor(y_theta, x_theta, dt*sqrt(squeeze(errors(i,:,:))));
        % clim([dt*min(errors(:)), dt*max(errors(:))]);
        clim([dt*sqrt(min(errors(:))) 10000.0]);
        xlabel('theta_x');    
        ylabel('theta_y');

        annotation('textbox', [0 0.9 1 0.1], 'String', sprintf('terrain = %s', string(terrain_theta(i))), 'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 14);
        % title(sprintf('terrain = %s', string(terrain_theta(i))));
        %add colorbar and label
        c = colorbar;
        c.Label.String = 'average error (years)';
        
        % Capture the current frame
        frames{i} = getframe(gcf);
        
        % Close the figure to avoid overlapping plots
        close(gcf);
    end

    % Create a GIF file from the frames
    filename = '/Users/mperuzzo/Documents/repos/bottlenecks/tests/contour_plots_5_av_dt_20_downsampled.gif';
    for i = 1:length(terrain_theta)
        % Convert the frame to an indexed image
        [frame_data, colormap] = rgb2ind(frames{i}.cdata, 256);
        
        % Write the frame to the GIF file
        if i == 1
            imwrite(frame_data, colormap, filename, 'gif', 'LoopCount', Inf, 'DelayTime', 0.5);
        else
            imwrite(frame_data, colormap, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 0.5);
        end
    end
end

%%cross sections
if true
    colormap = copper(length(terrain_theta));
    figure
    hold on;
    for i = 1:2:length(terrain_theta)
        plot(x_theta, dt*squeeze(sqrt(errors(i,:,y_idx))), 'Color', colormap(i,:), 'LineWidth', 1.);
        xlabel('θ_y');
        % ylim([1000 2000])
        ylabel('error');
        title('error vs y for different terrain');
    end

    figure
    hold on;
    for i = 1:2:length(terrain_theta)
        plot(y_theta, dt*squeeze(sqrt(errors(i,x_idx,:))), 'Color', colormap(i,:),'LineWidth', 1.);
        xlabel('θ_x');
        ylabel('error ');
        % ylim([1000 2000])
        title('error vs x for different terrain');
    end
end
x_idx = 1;
terrain_idx = 1;
if false
    idxs = find(errors < 55);
    frames = cell(1, length(x_theta));
    for idx = 1:length(x_theta)
        loc = 10;
        fwidth = 20;
        tic
        title = "terrain = " + string(terrain_theta(terrain_idx)) + " y = " + string(x_theta(idx)) + " x = " + string(y_theta(x_idx)) + " error = " + string(10*errors(terrain_idx, x_idx, y_idx));
        f = figure('Units','inches','Position',[loc loc fwidth fwidth/2.2], ...
        'PaperPosition',[.25 .25 8 6]);
        %add title
        annotation('textbox', [0 0.9 1 0.1], 'String', title, 'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontSize', 14);
        hold on;

        worldmap(["Ireland", "Iran"])
        axis xy

        % color map with A
        geoshow(squeeze(final_As(terrain_idx,idx,y_idx,:,:)), R, 'DisplayType', 'texturemap')
        %make sea white
        geoshow(fliplr([land.Lat]),fliplr([land.Lon]),'DisplayType', ...
            'Polygon', 'FaceColor', 'white', 'FaceAlpha', 0.5)

        framem('FLineWidth', 1, 'FontSize', 7)
        % Capture the current frame
        frames{idx} = getframe(gcf);
        
        % Close the figure to avoid overlapping plots
        close(gcf);
    end
    % Create a GIF file from the frames
    filename = '/Users/mperuzzo/Documents/repos/bottlenecks/tests/sweep_y.gif';
    for i = 1:length(x_theta)
        % Convert the frame to an indexed image
        [frame_data, colormap] = rgb2ind(frames{i}.cdata, 256);
        
        % Write the frame to the GIF file
        if i == 1
            imwrite(frame_data, colormap, filename, 'gif', 'LoopCount', Inf, 'DelayTime', 1.0);
        else
            imwrite(frame_data, colormap, filename, 'gif', 'WriteMode', 'append', 'DelayTime', 1.0);
        end
    end
end