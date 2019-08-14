function optimal_val = divisor_highest_ctr_int(I,min,max)

highest_int = 0;
for div_it = min:max
    % complement if needed
    Ic = best_complement_opt(I,div_it);
    
    % thresholding otsu
    rlev = graythresh(Ic);
    I_bw = im2bw(Ic,rlev);
    
    % calculate mean intensity of centre square
    [height width depth] = size(Ic);
    side_border = floor(width/div_it/2);
    top_border = floor(height/div_it/2);
    c_width = floor(width - side_border*2);
    c_height = floor(height - top_border*2);
    
    total_b_pix = floor((side_border*height*2)+(top_border*c_width*2));
    total_c_pix = floor(c_width*c_height);
    total_pix = total_b_pix + total_c_pix;
    
    % centre square
    sum_centre = 0;
    for i = side_border:c_width
        for j = top_border:c_height
            sum_centre = sum_centre + I_bw(j,i);
        end;
    end;
    
    mc_int = sum_centre/total_c_pix;
    
%     echo on;
%     div_it
%     mc_int
%     echo off;
    
    if (mc_int > highest_int)
        highest_int = mc_int;
        optimal_val = div_it;
    end;
end;

end