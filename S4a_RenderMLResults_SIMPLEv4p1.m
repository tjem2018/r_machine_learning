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
output_dir = strcat(images_dir,'output\');
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
                        % draw RED tile boarder
                        Image(si:si+stile,sj:sj+tbdr,1) = 255;
                        Image(si:si+tbdr,sj:sj+stile,1) = 255;
                        Image(si:si+stile,sj+stile-tbdr:sj+stile,1) = 255;
                        Image(si+stile-tbdr:si+stile,sj:sj+stile,1) = 255;
                        % black out colours other than tile boarder
                        Image(si:si+stile,sj:sj+tbdr,2:3) = 0;
                        Image(si:si+tbdr,sj:sj+stile,2:3) = 0;
                        Image(si:si+stile,sj+stile-tbdr:sj+stile,2:3) = 0;
                        Image(si+stile-tbdr:si+stile,sj:sj+stile,2:3) = 0;
                    end;
                end;
            end;
        end;
        % reduce image size
        small = Image;
        small = imresize(small, 0.75);
        % write image to output dir with colour tiles indicating TP and FP
        imwrite(small,strcat(output_dir,iname,'_Classification','.jpg'));
    end;
end;
%figure, imshow(small);
disp('Script Complete.');
