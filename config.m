%%****** Configurations of tracker parameters and sequences *******%%


%%*************************** Path settings ***********************%%

base_path = './data/';
datapath = [base_path title '/img/'];
gt_path = [base_path title '/groundtruth_rect.txt'];
imfiles = dir( [datapath '*.jpg'] );

frame_num = length(imfiles);
frame0 = imread( [datapath imfiles(1).name] );
[frame_height, frame_width] = size(frame0);

save_path = ['./results/' title '/'];
if ~exist(save_path,'dir'); mkdir(save_path);end

addpath(genpath('code'));


%%******************* Tracking parameters settings ****************%%

template_num = 10;
template_size = [32, 32];
params.template_sz = template_size;
particle_num = 600;
affsig = [ 8 8 .01 .00 .00 .00 ];
update_thr = 0.13;

% patch
% patch_size = [16,16];
% patch_step = 8;
patch_size = template_size ./ 2;
patch_step = patch_size(1) / 2;
patch_num(1) = length( patch_size(1)/2 : patch_step : (template_size(1)-patch_size(1)/2) );
patch_num(2) = length( patch_size(2)/2 : patch_step : (template_size(2)-patch_size(1)/2) );

% lambda
lambda1 = 0.01; % coefficient for blur kernel term
lambda2 = 0.01; % coefficient for sparse coding term

% sparse coding params
sc_param.lambda = lambda2;
sc_param.lambda2 = 0;
sc_param.mode = 0;
% sc_param.L = 20;

% number of selected particles
temp_best_num = 70;
sort_num = 200;

% indicators for showing and saving results
doshow = 1;
dosave = 1;

% displaying options
show_opt.doshow = doshow;
show_opt.title = 'Visual Tracking under Motion Blur';
show_opt.tnum = template_num;


%%************************ Initialization *************************%%

tsz = template_size;
gt = load(gt_path);

p = [ gt(1,1)+(gt(1,3)-1)/2, gt(1,2)+(gt(1,4)-1)/2,...
           gt(1,3), gt(1,4), 0.0];
affparam = [p(1), p(2), p(3)/tsz(1), p(5), p(4)/p(3), 0];
