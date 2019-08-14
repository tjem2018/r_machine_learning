%% Morphology tests
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';
% vars
bin_dir = 'ml_binary\';
% choose and load orig image file
[fname, path] = uigetfile('\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\VALIDATE_2\*.*','Choose Image...');
fqfname=strcat(path,fname);
Imo = imread(fqfname);
iname = fname(1:length(fname)-4);
% load ground truth
fname_gt = strcat(iname,'_GT','.bmp');
fq_fname_gt=strcat(path,fname_gt);
Im_gt = imread(fq_fname_gt);
% load ml binary image
fq_bfname = strcat(path,bin_dir,iname,'_Binary.jpg');
Im = imread(fq_bfname);

% HOLE FILL
Im_hf = imfill(Im,'holes');
% COMBINED MORPH
se_size = 150;
se = strel('square',se_size);
Im_hf_mo = imopen(Im_hf,se);
%Im_hf_mc = imclose(Im_hf,se);
Im_hf_mo_mc = imclose(Im_hf_mo,se);

% figure;
subplot(3,3,1), imshow(Im), title('Orig');
subplot(3,3,2), imshow(Im_hf), title('Hole Fill');
subplot(3,3,3), imshow(Im_hf_mo), title('HF Morph Open');
%subplot(3,3,4), imshow(Im_hf_mc), title('HF Morph Close');
%subplot(3,3,5), imshow(Im_hf_mo), title('HoleFill and MorphOpen');
subplot(3,3,6), imshow(Im_hf_mo_mc), title('HoleFill and MOpen and MClose');
subplot(3,3,7), imshow(Im_gt), title('Ground Truth');

%% COMBINED MORPH AND ML
%se_size = 150;
%se = strel('square',se_size);
Im_m_l = logical(Im_hf_mo_mc);
Im_b_l = logical(Im);
Icomb = (Im_m_l | Im_b_l);
Icomb = im2uint8(Icomb);
Icomb_hf = imfill(Icomb,'holes');
%Icomb_hf_o = imopen(Icomb_hf,se);
%Icomb_hf_o_c = imclose(Icomb_hf_o,se);
se_size = 100;
se = strel('square',se_size);
Iexp1 = imclose(Icomb_hf,se);
Iexp2 = imopen(Iexp1,se);
se_size = 200;
se = strel('square',se_size);
Iexp3 = imclose(Iexp2,se);

% show results

% figure;
% subplot(2,2,1), imshow(Icomb), title('ML plus MorphAll');
% subplot(2,2,2), imshow(Icomb_hf), title('ML MA: HF');
% subplot(2,2,3), imshow(Icomb_hf_o), title('ML MA: HF MO');
% subplot(2,2,4), imshow(Icomb_hf_o_c), title('ML MA: HF MO MC');
figure;
subplot(3,3,1), imshow(Im_hf_mo_mc), title('ML Bin: HoleFill and MOpen and MClose');
subplot(3,3,2), imshow(Icomb), title('MLBin HF/Morph');
subplot(3,3,3), imshow(Icomb_hf), title('MLBin HF/Morph: HF');
%subplot(3,3,4), imshow(Icomb_hf_o), title('MLBin HF/Morph: HF MO');
%subplot(3,3,5), imshow(Icomb_hf_o_c), title('MLBin HF/Morph: HF MO MC');
subplot(3,3,6), imshow(Iexp1), title('EXP1');
subplot(3,3,7), imshow(Iexp2), title('EXP2');
subplot(3,3,8), imshow(Iexp3), title('EXP3');
subplot(3,3,9), imshow(Im_gt), title('ORIG: Ground Truth');


