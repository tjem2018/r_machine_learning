%% CLEAR DOWN AND STARTUP
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';

%% USER VARIABLES
tile = 50;
class_thresh = 0.75;
image_dir = 'UNSEEN';
% DATA INPUT VARS
database_root = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\';
dir_path = strcat(database_root,image_dir,'\');
mph_dir='morph_binary\'
% DATA OUTPUT VARS
writedir = 'mph_analysis\';

%% CONF MAT VARS
tp = 0;
fp = 0;
fn = 0;
tn = 0;

% get list of files with extension JPG
flist = dir(strcat(dir_path,'*bmp'));
[flh, flw] = size(flist);
% iterate over list of files
%for i = 1:2
for i = 1:flh;
    fname = flist(i).name;
    nlen = length(fname);
    if isequal(1,regexp(fname,'[^ . _]\w*[.]bmp'))
        % LOAD/RESIZE ORIGINAL AND GROUND TRUTH IMAGES
        full_fname=strcat(dir_path,fname);
        Igt = imread(full_fname);
        iname = fname(1:length(fname)-7);
        outstr = strcat('Processing Image:',num2str(i),' of:',num2str(flh),'. File:',fname);
        disp(outstr);

        % load morph bin
        fname_gt = strcat(mph_dir,iname,'_MorphologyBinary','.jpg');
        fq_fname_gt=strcat(dir_path,fname_gt);
        Imp = imread(fq_fname_gt);
        
        % tile sizes to segment image into
        stile = tile-1;
        [ht, wd] = size(Imp);
        % Image Tile Loop
        for si = 1:tile:ht
            for sj = 1:tile:wd
                if (si+stile <= ht && sj+stile <= wd)                                        
                    % GROUND TRUTH CLASS
                    ttile = Igt(si:si+stile,sj:sj+stile);
                    % convert gt sub matrix to vector
                    tt_v = ttile(:);
                    % calculate percent of tile which is gt roof
                    % if greater than class threshold, class as roof
                    gt_pc = sum(tt_v)/tile^2;
                    if gt_pc >= class_thresh
                        is_roof = 1;
                    else
                        is_roof = 0;
                    end;
                    
                    % MORPH CLASS
                    mpTile = Imp(si:si+stile,sj:sj+stile);
                    % convert gt sub matrix to vector
                    mp_v = mpTile(:);
                    % calculate percent of tile which is gt roof
                    % if greater than class threshold, class as roof
                    mp_pc = sum(mp_v)/tile^2;
                    if mp_pc >= class_thresh
                        p_roof = 1;
                    else
                        p_roof = 0;
                    end;
                    
                    if (is_roof && p_roof)
                        tp = tp+1;
                    elseif (is_roof && (~p_roof))
                        fn = fn+1;
                    elseif ((~is_roof) && (~p_roof))
                        tn = tn+1;
                    elseif ((~is_roof) && p_roof)
                        fp = fp+1;
                    end;
                end;
            end;
        end;
        % write fused image
        imwrite(imfuse(Igt,Imp,'falsecolor'),strcat(dir_path,writedir,iname,'_GTMPH_Fuse','.jpg'));
    end;
end;

disp(strcat('TN:',num2str(tn)))
disp(strcat('FN:',num2str(fn)))
disp(strcat('FP:',num2str(fp)))
disp(strcat('TP:',num2str(tp)))

disp(datetime('now'));
disp('Script complete.');
