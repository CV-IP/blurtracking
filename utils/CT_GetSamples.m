function [A_pos, A_neg , pos_affpara] = CT_GetSamples( image, affpara, template_size, pos_num, neg_num )
%
%
%
all_affpara = repmat( affpara(:), 1, pos_num);

sigma = [1.0, 1.0, 0.0, 0.0, 0.0, 0.0];
all_affpara = all_affpara + randn(6,pos_num).*repmat( sigma(:), 1, pos_num);

pos_affpara = all_affpara;

all_affpara_mat = affparam2mat( all_affpara );
all_affimg = warpimg( image, all_affpara_mat, template_size );

A_pos = reshape(all_affimg,prod(template_size),pos_num);

candi_neg_num = neg_num*10;
all_affpara = repmat( affpara(:), 1, candi_neg_num);

affpara_mat = affparam2mat( affpara );
sigma = [ round( template_size(1)*affpara_mat(3) ) , round( template_size(1)*affpara_mat(3)*affpara(5) ) , 0.0, 0.0, 0.0, 0.0];
all_affpara = all_affpara + randn(6,candi_neg_num).*repmat( sigma(:), 1, candi_neg_num);

dist_x = round( sigma(1)/4 );
center_x = affpara(1);
left = center_x - dist_x;
right = center_x + dist_x;

dist_y = round( sigma(2)/4 );
center_y = affpara(2);
top = center_y - dist_y;
bottom = center_y + dist_y;

id = all_affpara(1,:)<= right & all_affpara(1,:)>=left & all_affpara( 2,: )>= top & all_affpara( 2,: ) <= bottom; % ????????????????????
all_affpara(:,id) = [];
%----------------
dist_x = round( sigma(1) );
center_x = affpara(1);
left = center_x - dist_x;
right = center_x + dist_x;

dist_y = round( sigma(2) );
center_y = affpara(2);
top = center_y - dist_y;
bottom = center_y + dist_y;

id = all_affpara(1,:)<=left | all_affpara(1,:) >= right | all_affpara(2,:) <= top | all_affpara(2,:) >= bottom;
all_affpara(:,id) = [];
%----------------
[img_h,img_w] = size(image);
id = ( all_affpara(1,:)<0 | all_affpara(1,:)>img_w | all_affpara(2,:)<0 | all_affpara(2,:)>img_h );
all_affpara(:,id) = [];
num = size(all_affpara,2);
neg_id = unidrnd(num,[1,neg_num]);
all_affpara = all_affpara(:,neg_id);

all_affpara_mat = affparam2mat( all_affpara );
all_affimg = warpimg( image, all_affpara_mat, template_size );
A_neg = reshape(all_affimg,prod(template_size),neg_num);

end

