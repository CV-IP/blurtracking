function single_tracker(title)

%%*********************** Parameters settings *********************%%

% configurations for path and parameters
config;

knn = zeros( frame_num, 1 );

%%************************* Start Tracking ************************%%

duration = 0;

% tracking the fist 10 frames with simple method
GetTemplateSet;
template_set_vec = reshape( template_set, prod(template_size), template_num );
template_set_norm = normalizeMat( template_set_vec );

% tracking the rest frames
for f = template_num + 1 : frame_num
    disp(['frame: ' num2str(f)]);
    
    show_opt.f = f;
    img_color = imread( [datapath imfiles(f).name] );
    
    tic;
    
    if size(img_color,3) == 3
        img = double(rgb2gray(img_color))/256;
    else
        img = double(img_color)/256;
    end
    
    Y_mat = warpimg( img, affparam2mat(all_affparam), template_size );
    Y_vec = reshape( Y_mat, prod(template_size), particle_num );
    Y_vec_norm = normalizeMat( Y_vec );
    
    Y_coef = mexLasso(Y_vec_norm, template_set_norm, sc_param);
    Y_coef = full(Y_coef);
    Y_error = sum( (Y_vec_norm - template_set_norm*Y_coef).^2 );
    [~, Y_sort_id] = sort(Y_error, 'ascend');
    
    Y_sort_id = Y_sort_id(:, 1:sort_num);
    Y_mat = Y_mat( :,:,Y_sort_id );
    Y_vec = Y_vec( :,Y_sort_id );
    Y_vec_norm = Y_vec_norm( :,Y_sort_id );
    all_affparam = all_affparam( :,Y_sort_id );
    
    
    % Multi-Task Reverse Sparse Representation
    [ K, ~, C ] = GetBlurKernalAndCoding( template_set_norm, Y_vec_norm, lambda1, template_size, sc_param ); %??????????????????????????????????????
    knn(f) = norm(K);
    
    
    max_coef = max( C, [], 2 ); % max pooling
    [max_coef,sort_id] = sort( max_coef,'descend' );
    Y_mat = Y_mat( :,:,sort_id );
    Y_vec = Y_vec( :,sort_id );
    Y_vec_norm = Y_vec_norm( :,sort_id );
    all_affparam = all_affparam( :,sort_id );
    
    best_num = sum( max_coef>0 );
    if best_num > temp_best_num
        best_num = temp_best_num;
    end
    
    T_image = reshape( template_set_norm, template_size(1), template_size(2)*template_num );
    blurT_image = ifft2( fft2(T_image) .* fft2(K) );
    blurT = reshape( blurT_image, template_size(1), template_size(2), template_num );
    blurT_patch = GetPatch(blurT,patch_size,patch_step);
    blurT_patch = reshape( blurT_patch, prod(patch_size), prod(patch_num)*template_num );
    blurT_patch = normalizeMat( blurT_patch );
    
    T_patch = GetPatch(template_set,patch_size,patch_step);
    T_patch = reshape( T_patch, prod(patch_size), prod(patch_num)*template_num );
    T_patch = normalizeMat( T_patch );
    
    candi_mat = Y_mat(:,:,1:best_num);
    candi_patch = GetPatch(candi_mat,patch_size,patch_step);
    candi_patch = reshape( candi_patch, prod(patch_size), prod(patch_num)*best_num );
    candi_patch = normalizeMat( candi_patch );
    
    coef = mexLasso( candi_patch, blurT_patch, sc_param);
    coef = full(coef);
    
    coef2 = mexLasso( candi_patch, T_patch, sc_param);
    coef2 = full(coef2);
    
    w = eye( prod(patch_num) );
    w = repmat( w, template_num, best_num );
    error =sum( ( candi_patch - blurT_patch*( w.*coef ) ).^2 );
    pro = exp(-5*error);
    pro = reshape(pro,prod(patch_num),best_num);
    likelihood = sum(pro);
    likelihood = likelihood/sum(likelihood);
    
    error2 =sum( ( candi_patch - T_patch*( w.*coef2 ) ).^2 );
    pro2 = exp(-5*error2);
    pro2 = reshape(pro2,prod(patch_num),best_num);
    
    likelihood2 = sum(pro2);
    likelihood2 = likelihood2/sum(likelihood2);
    
    likelihood_total = likelihood + likelihood2;
    
    [max_like,max_id] = max( likelihood_total );
    affparam = all_affparam(:,max_id);
    
    t1 = reshape( template_set, prod(template_size), template_num );
    t2 = reshape( blurT, prod(template_size), template_num );
    t1 = normalizeMat(t1);
    t2 = normalizeMat(t2);
    diff = sum( (t1-t2).^2 );
    diff_ave = sum(diff)/template_num;
    
    if diff_ave < update_thr && max_like > 0.25
        newT = Y_mat(:,:,max_id);
        [~, minIndex] = min( diff );
        [~, maxIndex] = max( diff );
        template_set(:,:,minIndex) = newT;
        template_set_vec = reshape( template_set, prod(template_size), template_num );
        template_set_norm = normalizeMat( template_set_vec );
    end
    
    all_affparam = repmat( affparam(:),1,particle_num );
    all_affparam = all_affparam + randn(6,particle_num).*repmat( affsig(:),1,particle_num );
    all_affparam(:,end) = affparam(:);
    CheckParticle;
    
    duration = duration + toc;
    
    show_opt = ShowResult0(img_color, affparam, template_size, show_opt);
    
    x = round( affparam(1) );
    y = round( affparam(2) );
    w = round( affparam(3)*template_size(1) );
    h = round( affparam(3)*affparam(5)*template_size(1) );
    positions(f,:) = [y, x, h, w];
end

fprintf('%d frames took %.3f seconds : %.3fps\n',frame_num-template_num, duration, ( frame_num - template_num ) / duration);

%%************************* Saving Results ************************%%

rect = positions;
rect = [rect(:,[2,1]) - rect(:,[4,3]) / 2, rect(:,[4,3])];
dlmwrite([save_path 'rect.txt'], rect);

end
