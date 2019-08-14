function mb_int = mean_border_int(I,divisor)
[height width depth] = size(I);
side_border = floor(width/divisor/2);
top_border = floor(height/divisor/2);
c_width = floor(width - side_border*2);
c_height = floor(height - top_border*2);

total_b_pix = floor((side_border*height*2)+(top_border*c_width*2));
total_c_pix = floor(c_width*c_height);
total_pix = total_b_pix + total_c_pix;

I_db = double(I);
sum_borders = 0;
% full top border
for i = 1:top_border
    for j = 1:width
        sum_borders = sum_borders + I_db(i,j);
    end;
end;
% full bottom border
for i = (top_border+c_height):height
    for j = 1:width
        sum_borders = sum_borders + I_db(i,j);
    end;
end;
% left side centre border
for i = 1:side_border
    for j = top_border:(height-top_border)
        sum_borders = sum_borders + I_db(j,i);
    end;
end;
% right side centre border
for i = (c_width+side_border):width
    for j = top_border:(height-top_border)
        sum_borders = sum_borders + I_db(j,i);
    end;
end;

mb_int = sum_borders/total_b_pix;

end
