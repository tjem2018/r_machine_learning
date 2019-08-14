%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';

%% VARIABLES for AUTO LOAD FILES
% GT images dir
images_dir = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\TEST_2p1\';
% bin GT output dir
output_dir = strcat(images_dir,'binary_gt\');
% tile size used on machine learning images
tile = 50;
tbdr = ceil(sqrt(tile)/2);
% clas threshold to use for GT tiles
class_thresh = 0.95;

%% AUTO LOAD FILES
% get list of files with extension JPG
flist = dir(strcat(images_dir,'*bmp'));
[flh, flw] = size(flist);
% iterate over list of files
%for i = 1:1
for i = 1:flh
    fname = flist(i).name;
    nlen = length(fname);
    if isequal(1,regexp(fname,'[^ . _]\w*[.]bmp'))
        % LOAD/RESIZE ORIGINAL AND GROUND TRUTH IMAGES
        full_fname=strcat(images_dir,fname);
        gtImage = imread(full_fname);
        bin_gtImage = gtImage;
        iname = fname(1:length(fname)-4);
        outstr = strcat('Processing Image:',num2str(i),' of:',num2str(flh),'. File:',fname);
        disp(outstr);
        
        %% DISPLAY EXAMPLE IMAGE AND TILES SIZE
        stile = tile-1;
        %% Example Image to show tiles
        [ht, wd, dp] = size(gtImage);
        %Itiles = uint8(zeros(ht,wd,dp));
        % Image Tile Loop
        for si = 1:tile:ht
            for sj = 1:tile:wd
                if (si+stile <= ht && sj+stile <= wd)
                    % GROUND TRUTH CLASS
                    ttile = gtImage(si:si+stile,sj:sj+stile);
                    % convert gt sub matrix to vector
                    tt_v = ttile(:);
                    % calculate percent of tile which is gt roof
                    % if greater than class threshold, class as roof
                    gt_pc = sum(tt_v)/tile^2;
                    if gt_pc >= class_thresh
                        %is_roof = 1;
                        % make tile all white
                        bin_gtImage(si:si+stile,sj:sj+stile,:) = 255;
                    else
                        %is_roof = 0;
                        % make tile all black
                        bin_gtImage(si:si+stile,sj:sj+stile,:) = 0;
                    end;
                end;
            end;
        end;
        % write image to output dir with colour tiles indicating TP and FP
        bingt_gt_img = imfuse(bin_gtImage, gtImage, 'falsecolor');
        imwrite(bingt_gt_img,strcat(output_dir,iname,'_BinaryGT','.jpg'));
    end;
end;
%%
%figure, imshowpair(gtImage,bin_gtImage);
disp('Script Complete.');
