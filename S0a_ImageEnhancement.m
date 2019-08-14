%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';
% choose and load file
[fname, path] = uigetfile('\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\TEST_1\*.JPG*','Choose Image...');
fq_fname=strcat(path,fname);
I = imread(fq_fname);
% load ground truth plane
fname_nx = fname(1:length(fname)-4);
fname_gt = strcat(fname_nx,'_GT','.bmp');
fq_fname_gt=strcat(path,fname_gt);
Igt = imread(fq_fname_gt);

%% reduce image sizes
new_size = 0.5;
Io = I;
I = imresize(I, new_size);
Igto = Igt;
Igt = imresize(Igt, new_size);

%%
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

% figure;
% subplot(2,1,1); imhist(rgb2gray(I)); title('Orig Grayscale');
% subplot(2,1,2); imhist(Igs); title('Adaptive Hist Grayscale');

% adaptive histogram equalisation for shadow reduction
%Iahist = adapthisteq(Igs,'clipLimit',0.01,'Distribution','rayleigh');

% create entropy plane
Ient_m = entropyfilt(Igs);
%Ient_m = entropyfilt(Iahist);
Ient = mat2gray(Ient_m);

% create range filter plane
Irang = rangefilt(Igs);
%Irang = rangefilt(Igs,ones(9,9));

% std filt
Istdfilt = stdfilt(Igs);

% graycomatrix
[Igcm, obj] = graycomatrix(Igs);
gcps = graycoprops(Igcm);

% Decorrelation stretch
Idc = decorrstretch(Iah,'Tol', 0.01);

% figure; 
% subplot(2,3,1); imhist(I(:,:,1)); title('Orig Red');
% subplot(2,3,2); imhist(I(:,:,2)); title('Orig Green');
% subplot(2,3,3); imhist(I(:,:,3)); title('Orig Blue');
% subplot(2,3,4); imhist(Idc(:,:,1)); title('DC Red');
% subplot(2,3,5); imhist(Idc(:,:,2)); title('DC Green');
% subplot(2,3,6); imhist(Idc(:,:,3)); title('DC Blue');

% create red green and blue planes
Ir = Idc(:,:,1);
Ig = Idc(:,:,2);
Ib = Idc(:,:,3);


% figure;
%subplot(1,2,1), imshow(I); title('Original Image');
% subplot(1,2,2), imshow(Igt); title('Ground Truth (Roof) Plane');
% figure;
subplot(1,2,1), imshow(Iah); title('Adaptive Histogram Equalisation (adapthisteq)');
subplot(1,2,2), imshow(Idc); title('Decorrelation Stretch on adapthisteq');
% % 
% figure;
% subplot(2,2,1), imshow(Igs); title('Grayscale on adapthisteq');
% subplot(2,2,2), imshow(Ir); title('Red Plane on decorrstretch');
% subplot(2,2,3), imshow(Ig); title('Green Plane on decorrstretch');
% subplot(2,2,4), imshow(Ib); title('Blue Plane on decorrstretch');
% 
% figure;
% subplot(1,2,1), imshow(Ient); title('Entropy Plane on grayscale');
% subplot(1,2,2), imshow(Irang); title('Range filter plane on grayscale');
%subplot(2,2,3), imshow(Istdfilt); title('STDev filter plane on grayscale');
%subplot(2,2,4), imshow(Igcm); title('graycomatrix plane on grayscale');

%imtool(Irang);
