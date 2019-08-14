%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';

%% VARIABLES for AUTO LOAD FILES
% input dir
input_dir = '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\ML_output\ANN_0p9\';
input_filename = 'OUTPUT_ANN_ClassificationResults.csv';
% output dir
images_dir = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\VALIDATE_2\';
output_dir = strcat(images_dir,'ml_binary\');
% tile size used on machine learning images
tile = 50;
tbdr = ceil(sqrt(tile)/2);

% LOAD INPUT FILE
mydata=readtable(strcat(input_dir,input_filename));
%all_image_data=all_image_data(:,{'ImageSegmentID','ImageName','IPos','JPos','predictIsRoof','IsRoof'});
mydata = table(mydata.IPos,mydata.JPos,mydata.predictIsRoof,mydata.IsRoof, 'VariableNames', {'IPos' 'JPos' 'predictIsRoof' 'IsRoof'}, 'RowNames', mydata.ImageSegmentID);

%% VARIABLES FOR FEATURE SELECTION
% features to select
iname = '';
ipos = 0;
jpos = 0;
isegID = '';

%% AUTO LOAD FILES
% get list of files with extension JPG
flist = dir(strcat(images_dir,'*JPG'));
[flh, flw] = size(flist);
% iterate over list of files
%for i = 1:1
for i = 1:flh
    fname = flist(i).name;
    nlen = length(fname);
    if isequal(1,regexp(fname,'[^ . _]\w*[.]JPG'))
        % LOAD/RESIZE ORIGINAL AND GROUND TRUTH IMAGES
        full_fname=strcat(images_dir,fname);
        Image = imread(full_fname);
        Image = rgb2gray(Image);
        Image(:,:) = 0;
        iname = fname(1:length(fname)-4);
        outstr = strcat('Processing Image:',num2str(i),' of:',num2str(flh),'. File:',fname);
        disp(outstr);
        
        %% DISPLAY EXAMPLE IMAGE AND TILES SIZE
        stile = tile;
        %% Example Image to show tiles
        [ht, wd, dp] = size(Image);
        %Itiles = uint8(zeros(ht,wd,dp));
        % Image Tile Loop
        for si = 1:tile:ht
            for sj = 1:tile:wd
                if (si+stile <= ht && sj+stile <= wd)
                    % create image tile/segment ID
                    isegID = strcat(iname,'_i',num2str(si),'j',num2str(sj));
                    % select segment row from input data
                    mydata_row = mydata({isegID},:);
                    % variables for roof classfication
                    predict = mydata_row{isegID,'predictIsRoof'};
                    actual = mydata_row{isegID,'IsRoof'};
                    if (predict)
                        % make tile all white
                        Image(si:si+stile,sj:sj+stile,:) = 255;
                    else
                        % make tile all black
                        Image(si:si+stile,sj:sj+stile,:) = 0;
                    end;
                end;
            end;
        end;
        % write image to output dir with colour tiles indicating TP and FP
        imwrite(Image,strcat(output_dir,iname,'_Binary','.jpg'));
    end;
end;
%figure, imshow(small);
disp('Script Complete.');
