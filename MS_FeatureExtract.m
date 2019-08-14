%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';
% choose and load file
[fname path] = uigetfile('\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\TEST_1\*.JPG*','Choose Image...');
fq_fname=strcat(path,fname);
I = imread(fq_fname);
% load ground truth plane
fname_nx = fname(1:length(fname)-4);
fname_gt = strcat(fname_nx,'_GT','.bmp');
fq_fname_gt=strcat(path,fname_gt);
Igt = imread(fq_fname_gt);

%%
% reduce image sizes
new_size = 0.25;
Io = I;
I = imresize(I, new_size);
Igto = Igt;
Igt = imresize(Igt, new_size);

% adaptive histogram eq for shadow reduce on RGB image
% convert to L*a*b*
shadow_lab = rgb2lab(I);
% normalise luminosity to between 0-1
max_lum = 100;
L = shadow_lab(:,:,1)/max_lum;
% create output image
mymat = shadow_lab;
% adaptive histogram for luminosity
mymat(:,:,1) = adapthisteq(L,'clipLimit',0.01,'Distribution','rayleigh')*max_lum;
% convert to RGB
Iah = lab2rgb(mymat,'OutputType','uint8');

% create grayscale plane
Igs = rgb2gray(Iah);

% adaptive histogram equalisation for shadow reduction
%Iahist = adapthisteq(Igs,'clipLimit',0.01,'Distribution','rayleigh');

% create entropy plane
Ient_m = entropyfilt(Igs);
%Ient_m = entropyfilt(Iahist);
Ient = mat2gray(Ient_m);

% Decorrelation stretch
Idc = decorrstretch(Iah,'Tol', 0.01);

% create red green and blue planes
Ir = Idc(:,:,1);
Ig = Idc(:,:,2);
Ib = Idc(:,:,3);

figure;
subplot(3,3,1), imshow(Io); title('Original Image');
subplot(3,3,2), imshow(Iah); title('Adaptive Histogram Equalisation (adapthisteq)');
subplot(3,3,3), imshow(Idc); title('Decorrelation Stretch on adapthisteq');
subplot(3,3,4), imshow(Igs); title('Grayscale on adapthisteq');
subplot(3,3,5), imshow(Ient); title('Entropy Plane on grayscale');
subplot(3,3,6), imshow(Ir); title('Red Plane on decorrstretch');
subplot(3,3,7), imshow(Ig); title('Green Plane on decorrstretch');
subplot(3,3,8), imshow(Ib); title('Blue Plane on decorrstretch');
subplot(3,3,9), imshow(Igt); title('Ground Truth (Roof) Plane');


