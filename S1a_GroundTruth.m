%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';

% set path to image directory
dir_path = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\TEST_2\';

% get list of files with extension JPG
flist = dir(strcat(dir_path,'*JPG'));
[flh, flw] = size(flist);
current_mask = zeros(5,5);
% iterate over list of files and request ground truth for each
for i = 1:flh
    fname = flist(i).name;
    nlen = length(fname);
    if isequal(1,regexp(fname,'[^ . _]\w*[.]JPG'))
        full_fname=strcat(dir_path,fname);
        I = imread(full_fname);
        less_ext = fname(1:length(fname)-4);
        mask = roipoly(I);
        imwrite(mask,strcat(dir_path,less_ext,'_GT','.bmp'));
        current_mask = mask;
    end;
end;
% display last created mask
figure, imshow(current_mask);
