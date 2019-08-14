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
% set path to image directory
indir = 'tiled\masks\';
outdir = 'tiled\tiles\';
iter = 4;
tile = 50;
class_thresh = 0.60;

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
        disp(datetime('now'));
        % load tile mask
        fname_gt = strcat(iname,'_MaskIteration',num2str(iter),'.bmp');
        fq_fname_gt=strcat(dir_path,indir,fname_gt);
        Igt = imread(fq_fname_gt);
        
        % PREPROCESSING
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
        
        % FEATURE EXTRACTION
        % tile sizes to segment image into
        stile = tile-1;
        [ht, wd] = size(Igs);
        % Image Tile Loop
        for si = 1:tile:ht
            for sj = 1:tile:wd
                if (si+tile < ht && sj+tile < wd)
                    % GRAYSCALE
                    % create image tile matrix
                    Itile = Igs(si:si+stile,sj:sj+stile);
                    
                    % GROUND TRUTH CLASS
                    ttile = Igt(si:si+stile,sj:sj+stile);
                    % convert gt sub matrix to vector
                    tt_v = ttile(:);
                    % calculate percent of tile which is gt roof
                    % if greater than class threshold, class as roof
                    gt_pc = sum(tt_v)/tile^2;
                    if gt_pc >= class_thresh
                        disp(num2str(gt_pc));
                        % save target tile as ref image
                        %imwrite(ttile,strcat(dir_path,outdir,iname,'_tTile_i',num2str(si),'_j',num2str(sj),'.bmp'))
                        imwrite(Itile,strcat(dir_path,outdir,iname,'_Tile_i',num2str(si),'_j',num2str(sj),'.bmp'))
                    end;
                end;
            end;
        end;
    end;
end;
disp('Done.');