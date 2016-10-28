function [ K, fK, C ] = GetBlurKernalAndCoding( T, Y, lamda1, template_size, param)
%% Multi-Task Reverse Sparse Representation
%% 
% param.lambda = lamda2;
% param.lambda2 = 0;
% param.mode = 2;

max_time = 40;
T_num = size( T,2 );
T_image = reshape( T, template_size(1), template_size(2)*T_num );

C = mexLasso( T, Y, param);
C = full(C);

temp_K = zeros( template_size(1), template_size(2)*T_num );
for i = 1 : max_time
    consT = Y*C;
    consT_image = reshape( consT, template_size(1), template_size(2)*T_num );
    fx = fft2( T_image );
    numer = conj( fx ) .* fft2( consT_image );
    denom = abs(fx).^2 + lamda1 * eye(size(T_image));
    
    fK = (numer ./ denom);
    K = real(ifft2(fK));
    K = K./sum(K(:));
    
    blurT_image = ifft2( fft2(T_image) .* fft2(K) );
    blurT = reshape( blurT_image, prod(template_size), T_num );
    blurT = normalizeMat(blurT);
    C = mexLasso( blurT, Y, param);
    C = full(C);
    
    error = sum( sum ( ( K - temp_K ).^2 ) );
    if error < 5e-4
        break;
    else
        temp_K = K;
    end
end
% i

end

