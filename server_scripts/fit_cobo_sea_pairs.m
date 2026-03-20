clearvars;
clc;

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(script_dir);
cd(repo_root);
addpath(fullfile(repo_root, 'src'));

layer_pairs = {
    {'asym', 'sea'}
    {'csi', 'sea'}
    {'hydro', 'sea'}
    {'prec', 'sea'}
    {'tmean', 'sea'}
};

for i = 1:size(layer_pairs, 1)
    layers = layer_pairs{i};
    fprintf('Running fit_model for cobo with layers %s\n', strjoin(layers, ', '));
    fit_model('cobo', layers);
end
