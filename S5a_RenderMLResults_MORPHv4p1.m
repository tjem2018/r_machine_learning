%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';

%% VARIABLES for AUTO LOAD FILES
% input dirs
images_dir = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\VALIDATE_2\';
binary_dir = 'ml_binary\';
% output dir
output_dir = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\VALIDATE_2\classed_output\';
% tile size used on machine learning images
tile = 50;

%% VARIABLES FOR FEATURE SELECTION
% features to select
% iname = '';
% ipos = 0;
% jpos = 0;
% isegID = '';

%% USE MORPHOLOGY TO SEPARATE ROOF AREA
%% RENDER IMAGES WITH BINARY CLASSED ROOF
% get list of files with extension JPG
flist = dir(strcat(images_dir,'*JPG'));
[flh, flw] = size(flist);
% iterate over list of files
%for i = 1:1
for i = 1:flh
    fname = flist(i).name;
    nlen = length(fname);
    if isequal(1,regexp(fname,'[^ . _]\w*[.]JPG'))
        % LOAD ORIGINAL and BINARY IMAGES
        outstr = strcat('Processing Image:',num2str(i),' of:',num2str(flh),'. File:',fname);
        disp(outstr);
        % orig
        full_fname=strcat(images_dir,fname);
        Image = imread(full_fname);
        iname = fname(1:length(fname)-4);
        % binary
        bin_fname=strcat(images_dir,binary_dir,iname,'_Binary.jpg');
        BinImage = imread(bin_fname);
        
        % MORPHOLOGY        
        % HOLE FILL
        Im_hf = imfill(BinImage,'holes');
        
        % COMBINED MORPH
        se_size = 150;
        se = strel('square',se_size);
        Im_hf_mo = imopen(Im_hf,se);
        Im_hf_mo_mc = imclose(Im_hf_mo,se);
        
        % COMBINED MORPH AND ML
        Im_m_l = logical(Im_hf_mo_mc);
        Im_b_l = logical(BinImage);
        Icomb = (Im_m_l | Im_b_l);
        Icomb = im2uint8(Icomb);
        Icomb_hf = imfill(Icomb,'holes');
        se_size = 100;
        se = strel('square',se_size);
        Iexp1 = imclose(Icomb_hf,se);
        Iexp2 = imopen(Iexp1,se);
        se_size = 200;
        se = strel('square',se_size);
        Iexp3 = imclose(Iexp2,se);
        
        %% DISPLAY EXAMPLE IMAGE AND TILES SIZE
        stile = tile;
        %% Example Image to show tiles
        [ht, wd, dp] = size(Image);
        %Itiles = uint8(zeros(ht,wd,dp));
        % Image Tile Loop
        for si = 1:tile:ht
            for sj = 1:tile:wd
                if (si+stile <= ht && sj+stile <= wd)
                    Btile = Iexp3(si:si+stile,sj:sj+stile);
                    ml_class_weight = mean(Btile(:));
                    if (ml_class_weight < 0.8)
                        Image(si:si+stile,sj:sj+stile,:) = 0;
                    end;
                end;
            end;
        end;
        % write image to output dir with colour tiles indicating TP and FP
        imwrite(Image,strcat(output_dir,iname,'_MorphologyClassed','.jpg'));
    end;
end;
disp('Script Complete.');
