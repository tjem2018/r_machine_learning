%%
% clear down
clc;
clear all;
close all;
% choose and load file
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB';
[fname path] = uigetfile('\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\BATCH_1\*.*','Choose Image...');
fname=strcat(path,fname);
Io = imread(fname);
%Io = imread('\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\photos/DJI_0072.jpg')
%%
% reduce image size
I = imresize(Io, 0.25)
%%
% grayscale
%figure, imshow(IMG)
%figure, imshow(IMGs)
%figure, imagesc(IMGs)
I_gray = rgb2gray(I)

%figure, imshowpair(I,I_gray,'montage')

%%
% stretch and histogram
%figure, imhist(I(:,:,1))
I_stretch = imadjust(I, stretchlim(I))

%figure, imshowpair(I,I_stretch,'montage')
%figure, imhist(I_stretch(:,:,1))

%% 
% decorrelation stretch
I_dcstretch = decorrstretch(I,'Tol', 0.01)
I_dc_red = I_dcstretch(:,:,1)
I_dc_green = I_dcstretch(:,:,2)
I_dc_blue = I_dcstretch(:,:,3)
% complement
I_dc_red_c = imcomplement(I_dc_red); 
I_dc_green_c = imcomplement(I_dc_green); 
% plot
figure;
subplot(2,2,1), imshow(I_dcstretch);
title('Decorr Stretched');
subplot(2,2,2), imshow(I_dc_red_c);
title('Decorr Red');
subplot(2,2,3), imshow(I_dc_green_c);
title('Decorr Green');
subplot(2,2,4), imshow(I_dc_blue);
title('Decorr Blue');

%%
% binary thresholding
%rlev = 0.3; % 0.3
%glev = 0.5; % 0.5
%blev = 0.55; % 0.55

rlev = graythresh(I_dc_red_c);
glev = graythresh(I_dc_green_c);
blev = graythresh(I_dc_blue);

I_dc_r_bw = im2bw(I_dc_red_c,rlev)
I_dc_g_bw = im2bw(I_dc_green_c,glev)
I_dc_b_bw = im2bw(I_dc_blue,blev)
I_dc_bw_sum = (I_dc_r_bw&I_dc_g_bw&I_dc_b_bw)
% plot
figure;
subplot(2,2,1), imshow(I_dc_r_bw);
title('Red Plane Thresholded');
subplot(2,2,2), imshow(I_dc_g_bw);
title('Green Plane Thresholded');
subplot(2,2,3), imshow(I_dc_b_bw);
title('Blue Plane Thresholded');
subplot(2,2,4), imshow(I_dc_bw_sum);
title('Thresholds summed');
% hole fill
I_dc_bw_sum_hf = imfill(I_dc_bw_sum,'holes');
%figure, imshow(I_dc_bw_sum_hf);
% morphology
%size = 25;
%se = strel('square',size);
%Is_dc_bw_sum_hf_o = imopen(Is_dc_bw_sum_hf,se);

%%
% edge
s_step = 0.9;
I_bin_hf_ce = edge(I_dc_bw_sum_hf, 'Canny',s_step)
I_bin_hf_pe = edge(I_dc_bw_sum_hf, 'Prewitt', s_step)
I_bin_hf_re = edge(I_dc_bw_sum_hf, 'Roberts', s_step)
I_bin_hf_se = edge(I_dc_bw_sum_hf, 'Sobel', s_step)

% fill holes
ce_hf = imfill(I_bin_hf_ce,'holes');
pe_hf = imfill(I_bin_hf_pe,'holes');
re_hf = imfill(I_bin_hf_re,'holes');
se_hf = imfill(I_bin_hf_se,'holes');

%figure;
% subplot(2,2,1), imshow(ce_hf);
% title('Canny');
% subplot(2,2,2), imshow(pe_hf);
% title('Prewitt');
% subplot(2,2,3), imshow(re_hf);
% title('Roberts');
% subplot(2,2,4), imshow(se_hf);
% title('Sobel');

%figure, imshowpair(I_bin_hf_ce,ce_hf,'montage')

%%
% summary plot
figure;
subplot(2,2,1), imshow(I);
title('Original Image');
subplot(2,2,2), imshow(I_dcstretch);
title('Decorrlation Stretch');
subplot(2,2,3), imshow(I_dc_bw_sum);
title('Summed Binary Threshold Images Per Colour');
subplot(2,2,4), imshow(I_bin_hf_ce);
title('Canny Edge on Binary Threshold Image');

%%
% edge detect on grayscale
sense = 0.1;
I_gray_ce = edge(I_gray, 'Canny',sense)
I_gray_pe = edge(I_gray, 'Prewitt', sense)
I_gray_re = edge(I_gray, 'Roberts', sense)
I_gray_se = edge(I_gray, 'Sobel', sense)
figure;
subplot(2,2,1), imshow(I_gray_ce);
title('Canny');
subplot(2,2,2), imshow(I_gray_pe);
title('Prewitt');
subplot(2,2,3), imshow(I_gray_re);
title('Roberts');
subplot(2,2,4), imshow(I_gray_se);
title('Sobel');
%%
% fill holes
ce_hf = imfill(I_gray_ce,'holes');
pe_hf = imfill(I_gray_pe,'holes');
re_hf = imfill(I_gray_re,'holes');
se_hf = imfill(I_gray_se,'holes');

figure;
subplot(2,2,1), imshow(ce_hf);
title('Canny');
subplot(2,2,2), imshow(pe_hf);
title('Prewitt');
subplot(2,2,3), imshow(re_hf);
title('Roberts');
subplot(2,2,4), imshow(se_hf);
title('Sobel');

%figure, imshowpair(I_gray_ce,ce_hf,'montage')
%%
% 