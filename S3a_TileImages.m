%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';

%% VARIABLES for AUTO LOAD FILES
% set path to image directory and example file name
dir_path = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\VALIDATE_2\';
outdir = 'tiled\';
write_size = 1;

%example_image = 'DJI_0072.JPG'; % TEST_2
%example_image = 'DJI_0077.JPG'; % VALIDATE_2
% image resize, tile size, percent of roof in tile for class IsRoof
tile = 50;
%class_thresh = 1;
% set path to output dir and output file name

%% AUTO LOAD FILES
% get list of files with extension JPG
flist = dir(strcat(dir_path,'*JPG'));
[flh, flw] = size(flist);
% iterate over list of files
%for i = 1:1
for i = 1:flh
    fname = flist(i).name;
    nlen = length(fname);
    if isequal(1,regexp(fname,'[^ . _]\w*[.]JPG'))
        % LOAD/RESIZE ORIGINAL AND GROUND TRUTH IMAGES
        full_fname=strcat(dir_path,fname);
        I = imread(full_fname);
        iname = fname(1:length(fname)-4);
        outstr = strcat('Processing Image:',num2str(i),' of:',num2str(flh),'. File:',fname);
        disp(outstr);
        
        %% DISPLAY EXAMPLE IMAGE AND TILES SIZE
        %% Example Image to show tiles
        [ht, wd, dp] = size(I);
        %Itiles = uint8(zeros(ht,wd,dp));
        % Image Tile Loop
        for si = 1:tile:ht
            for sj = 1:tile:wd
                if (si+tile < ht && sj+tile < wd)
                    I(si:si+tile,sj:sj+2,1) = 255;
                    I(si:si+2,sj:sj+tile,1) = 255;
                    I(si:si+2,sj:sj+2,2:3) = 0;
                end;
            end;
        end;
        % reduce image size
        small = I;
        if (~isequal(write_size,1)) 
            small = imresize(small, write_size);
        end;
        imwrite(small,strcat(dir_path,outdir,iname,'_T.jpg'))
    end;
end;

disp('Script complete.');
