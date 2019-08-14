function mc_int = mean_centre_int(I,divisor)
[height width depth] = size(I);
side_border = floor(width/divisor/2);
top_border = floor(height/divisor/2);
c_width = floor(width - side_border*2);
c_height = floor(height - top_border*2);

%total_b_pix = floor((side_border*height*2)+(top_border*c_width*2));
total_c_pix = floor(c_width*c_height);
%total_pix = total_b_pix + total_c_pix;

% convert to doubles
I_db = double(I);

% centre square
sum_centre = 0;
for i = side_border:c_width
    for j = top_border:c_height
        sum_centre = sum_centre + I_db(j,i);
    end;
end;
mc_int = sum_centre/total_c_pix;

end
