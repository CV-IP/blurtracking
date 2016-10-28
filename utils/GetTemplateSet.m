%%****** Tracking the First Few Frames with Simple Method ******%%

template_set = zeros(template_size(1),template_size(2),template_num);

CT_lambda = 0.85;

CT_pos_num = 100; % number of positive samples
CT_neg_num = 150; % number of negative sampless

CT_M = prod(template_size);
mean0 = zeros(CT_M,1);
mean1 = zeros(CT_M,1);
sig0 = ones(CT_M,1);
sig1 = ones(CT_M,1);

img_color = imread( [datapath imfiles(1).name] );
if size(img_color,3) == 3
    img = double(rgb2gray(img_color))/256;
else
    img = double(img_color)/256;
end

template_set(:,:,1) = warpimg( img, affparam2mat(affparam), template_size );

[CT_pos_samples, CT_neg_samples] = CT_GetSamples(img, affparam, template_size, CT_pos_num, CT_neg_num);%??????????????????
[mean1, mean0, sig1, sig0] = UpdateClassifer(CT_pos_samples, CT_neg_samples, mean1, mean0, sig1, sig0, 0);%??????????????????????????

all_affparam = repmat( affparam(:),1,particle_num );
all_affparam = all_affparam + randn(6,particle_num).*repmat( affsig(:),1,particle_num );
all_affparam(:,end) = affparam(:);
CheckParticle;

disp(['frame: ' '1']);

show_opt.f = 1;
show_opt = ShowResult0(img_color, affparam, template_size, show_opt);
x = round( affparam(1) );
y = round( affparam(2) );
w = round( affparam(3)*template_size(1) );
h = round( affparam(3)*affparam(5)*template_size(1) );
positions(1,:) = [y, x, h, w];

for f = 2 : template_num
    disp(['frame: ' num2str(f)]);
    
    show_opt.f = f;
    img_color = imread( [datapath imfiles(f).name] );
    if size(img_color,3) == 3
        img = double(rgb2gray(img_color))/256;
    else
        img = double(img_color)/256;
    end
    
    Y_mat = warpimg( img, affparam2mat(all_affparam), template_size );
    YY = reshape(Y_mat,prod(template_size),particle_num);
    likelihood = GetLikelihood(YY,mean1,mean0,sig1,sig0);
    [~,max_id] = max( likelihood );
    affparam = all_affparam(:,max_id);
    template_set(:,:,f) = Y_mat(:,:,max_id);
    
    [CT_pos_samples, CT_neg_samples] = CT_GetSamples(img, affparam, template_size, CT_pos_num, CT_neg_num);%??????????????????
    [mean1, mean0, sig1, sig0] = UpdateClassifer(CT_pos_samples, CT_neg_samples, mean1, mean0, sig1, sig0, CT_lambda);
    
    all_affparam = repmat( affparam(:),1,particle_num );
    all_affparam = all_affparam + randn(6,particle_num).*repmat( affsig(:),1,particle_num );
    all_affparam(:,end) = affparam(:);
    CheckParticle;
    
    show_opt = ShowResult0(img_color, affparam, template_size, show_opt);
    x = round( affparam(1) );
    y = round( affparam(2) );
    w = round( affparam(3)*template_size(1) );
    h = round( affparam(3)*affparam(5)*template_size(1) );
    positions(f,:) = [y, x, h, w];
end



