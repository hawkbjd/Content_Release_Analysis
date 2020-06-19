function refined_data = zero_remover(data_with_0)

data = data_with_0;
[r,c] = size(data);
refined_data = zeros(r,c);

 for i = 1:r
     tmp_index  = data(i,:) > 0;
     tmp = data(i,tmp_index);
     refined_data(i,1:length(tmp(1,:))) = tmp;
 end 
 
%removes columns with only zeros
 refined_data = refined_data(:,sum(refined_data) > 0);