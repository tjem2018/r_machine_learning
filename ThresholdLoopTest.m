%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';
% choose and load file
[fname path] = uigetfile('\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\VALIDATE_2\*.*','Choose Image...');
fname=strcat(path,fname);
Io = imread(fname);
%Io = imread('\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\photos/DJI_0072.jpg')
% reduce image size
I = imresize(Io, 0.1);

%% 
% decorrelation stretch
I_dcstretch = decorrstretch(I,'Tol', 0.01);
I_dc_red = I_dcstretch(:,:,1);
I_dc_green = I_dcstretch(:,:,2);
I_dc_blue = I_dcstretch(:,:,3);

%%
min = 2;
max = 20;
% red
divisor = divisor_highest_ctr_int(I_dc_red,min,max);
mean_border_int_r = mean_border_int(I_dc_red,divisor);
%mean_border_int_r
mean_centre_int_r = mean_centre_int(I_dc_red,divisor);
%mean_centre_int_r
% complement if needed
% red
I_dc_red = best_complement_opt(I_dc_red,divisor); 

% green
divisor = divisor_highest_ctr_int(I_dc_green,min,max);
mean_border_int_g = mean_border_int(I_dc_green,divisor);
%mean_border_int_g
mean_centre_int_g = mean_centre_int(I_dc_green,divisor);
%mean_centre_int_g
% green
I_dc_green = best_complement_opt(I_dc_green,divisor); 

% blue
divisor = divisor_highest_ctr_int(I_dc_blue,min,max);
% '*** Blue Divisor:'
% divisor
mean_border_int_b = mean_border_int(I_dc_blue,divisor);
% '*** Mean border int:'
% mean_border_int_b
%mean_border_int_b
mean_centre_int_b = mean_centre_int(I_dc_blue,divisor);
% '*** Mean centre int:'
% mean_centre_int_b
%mean_centre_int_b
% blue
I_dc_blue = best_complement_opt(I_dc_blue,divisor); 

% plot
%figure;
% subplot(4,4,1), imshow(I_dcstretch);
% title('Decorr Stretched');
% subplot(4,4,2), imshow(I_dc_red);
% title('Decorr Red');
% subplot(4,4,3), imshow(I_dc_green);
% title('Decorr Green');
% subplot(4,4,4), imshow(I_dc_blue);
% title('Decorr Blue');
%figure, imshow(I_dc_blue);

% thresholding
rlev = graythresh(I_dc_red);
glev = graythresh(I_dc_green);
blev = graythresh(I_dc_blue);

I_dc_r_bw = im2bw(I_dc_red,rlev);
I_dc_g_bw = im2bw(I_dc_green,glev);
I_dc_b_bw = im2bw(I_dc_blue,blev);
I_dc_bw_sum = (I_dc_r_bw&I_dc_g_bw&I_dc_b_bw);

% hole_fill
I_dc_bw_sum_hf = imfill(I_dc_bw_sum,'holes');

% percent of image is roof
[height_sum width_sum] = size(I_dc_bw_sum_hf);
num_pix_sum = height_sum*width_sum;
count_ones_sum = 0;
for i = 1:height_sum
    for j = 1:width_sum
        if isequal(I_dc_bw_sum_hf(i,j),1)
            count_ones_sum = count_ones_sum + 1;
        end;
    end;
end;

roof_percent = count_ones_sum/num_pix_sum;
roof_percent = num2str(round(roof_percent*100,2));

% morphology close
size_hf_mo = 10;
se = strel('square',size_hf_mo);
I_dc_bw_sum_mo_o = imopen(I_dc_bw_sum_hf,se);
% morphology open
I_dc_bw_sum_mo_c = imclose(I_dc_bw_sum_hf,se);

% percent of image is roof morph open
[height_mo width_mo] = size(I_dc_bw_sum_mo_o);
num_pix_mo = height_mo*width_mo;
count_ones_mo = 0;
for i = 1:height_mo
    for j = 1:width_mo
        if isequal(I_dc_bw_sum_mo_o(i,j),1)
            count_ones_mo = count_ones_mo + 1;
        end;
    end;
end;

roof_percent_mo_o = count_ones_mo/num_pix_mo;
roof_percent_mo_o = num2str(round(roof_percent_mo_o*100,2));

% percent of image is roof
[height_mo width_mo] = size(I_dc_bw_sum_mo_c);
num_pix_mo = height_mo*width_mo;
count_ones_mo = 0;
for i = 1:height_mo
    for j = 1:width_mo
        if isequal(I_dc_bw_sum_mo_c(i,j),1)
            count_ones_mo = count_ones_mo + 1;
        end;
    end;
end;

roof_percent_mo_c = count_ones_mo/num_pix_mo;
roof_percent_mo_c = num2str(round(roof_percent_mo_c*100,2));

% merge
I_merge = uint8(zeros(height_mo,width_mo,3));
for i = 1:height_mo
    for j = 1:width_mo
        if isequal(I_dc_bw_sum_mo_c(i,j),0)
            I_merge(i, j, 1:3) = 0;
        else
            I_merge(i, j, 1) = I(i,j,1);
            I_merge(i, j, 2) = I(i,j,2);
            I_merge(i, j, 3) = I(i,j,3);
        end;
    end;
end;

stats = regionprops(I_dc_bw_sum_mo_c);
r=stats(1).BoundingBox;
figure;
imshow(I);
hold on;
r = rectangle('Position',r);
set(r,'EdgeColor',[1 0.1 0]);

% plot
%figure;
% subplot(3,3,1), imshow(I);
% title('Original');
% subplot(3,3,2), imshow(I_dcstretch);
% title('Decorrelation Stretch');
% subplot(3,3,3), imshow(I_dc_r_bw);
% title('Red Plane Thresholded');
% subplot(3,3,4), imshow(I_dc_g_bw);
% title('Green Plane Thresholded');
% subplot(3,3,5), imshow(I_dc_b_bw);
% title('Blue Plane Thresholded');
% subplot(3,3,6), imshow(I_dc_bw_sum);
% title('Summed Thresholds');
% subplot(3,3,7), imshow(I_dc_bw_sum_hf);
% title(strcat('Hole Fill:',roof_percent,'% of image detected as roof'));
% subplot(3,3,8), imshow(I_dc_bw_sum_mo_c);
% title(strcat('Morph Close:',roof_percent_mo_c,'% of image detected as roof'));
% subplot(3,3,9), imshow(I_merge);
% title('Morph Close and Image Merged');

figure;
subplot(2,3,1), imshow(I);
title('Original');
subplot(2,3,2), imshow(I_dcstretch);
title('Decorrelation Stretch');
subplot(2,3,3), imshow(I_dc_bw_sum);
title('Summed Thresholds');
subplot(2,3,4), imshow(I_dc_bw_sum_hf);
title(strcat('Hole Fill:',roof_percent,'% of image detected as roof'));
subplot(2,3,5), imshow(I_dc_bw_sum_mo_c);
title(strcat('Morph Close:',roof_percent_mo_c,'% of image detected as roof'));
subplot(2,3,6), imshow(I_merge);
title('Morph Close and Image Merged');

