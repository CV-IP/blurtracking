function patch = GetPatch( all_affimg, patch_size, patch_step )
%% 
sample_num = size( all_affimg, 3 );
template_size = size( all_affimg(:,:,1) );
patch_num(1) = length( patch_size(1)/2 : patch_step : (template_size(1)-patch_size(1)/2) );
patch_num(2) = length( patch_size(2)/2 : patch_step : (template_size(2)-patch_size(1)/2) );
patch = zeros( prod(patch_size), prod(patch_num), sample_num );

x = patch_size(1)/2;
y = patch_size(2)/2;
patch_centerx = x : patch_step : ( template_size(1)-x ) ;
patch_centery = y : patch_step : ( template_size(2)-y ) ;

l = 1;
for j = 1:patch_num(1)
    for k = 1:patch_num(2)
        data = all_affimg( patch_centerx(j)-x+1:patch_centerx(j)+x , patch_centery(k)-y+1:patch_centery(k)+y , : );
        data = reshape( data, prod(patch_size), 1, sample_num );
        patch(:,l,:) = data;
        l = l + 1;
    end
end

end

