%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';

%% VARIABLES for AUTO LOAD FILES
% set path to image directory and example file name
dir_path = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\TEST_2\';
tiles_dir = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\texture_tiles\';
example_image = 'DJI_0072.JPG'; % TEST_2
%example_image = 'DJI_0077.JPG'; % VALIDATE_2
% image resize, tile size, percent of roof in tile for class IsRoof
new_size = 1;
tile = 50;
class_thresh = 1;
% set path to output dir and output file name
writepath = '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\ppData\';
writefile = strcat('PPD_TEST2','_',num2str(round(new_size*100)),'ip_',num2str(tile),'ts_',num2str(round(class_thresh*100)),'cp.csv');

%% VARIABLES FOR FEATURE SELECTION
% features to select
iname = '';
ipos = 0;
jpos = 0;
isegID = '';
% grayscale tile stats
ivar = 0;
istdev = 0;
imin = 0;
imax = 0;
imean = 0;
imed = 0;
imod = 0;
% entropy tile stats
ievar = 0;
iestdev = 0;
iemin = 0;
iemax = 0;
iemean = 0;
iemed = 0;
iemod = 0;
% red tile stats
irvar = 0;
irstdev = 0;
irmin = 0;
irmax = 0;
irmean = 0;
irmed = 0;
irmod = 0;
% green tile stats
igvar = 0;
igstdev = 0;
igmin = 0;
igmax = 0;
igmean = 0;
igmed = 0;
igmod = 0;
% blue tile stats
ibvar = 0;
ibstdev = 0;
ibmin = 0;
ibmax = 0;
ibmean = 0;
ibmed = 0;
ibmod = 0;
% structural similarity stats
ssim1 = 0;
ssim2 = 0;
ssim3 = 0;
ssim4 = 0;
ssim5 = 0;
ssim6 = 0;
ssim7 = 0;
ssim8 = 0;
ssim9 = 0;
ssim10 = 0;
ssim11 = 0;
ssim12 = 0;
ssim13 = 0;
ssim14 = 0;
ssim15 = 0;
ssim16 = 0;
ssim17 = 0;
ssim18 = 0;
ssim19 = 0;
ssim20 = 0;
ssim21 = 0;
ssim22 = 0;
ssim23 = 0;
ssim24 = 0;
ssim25 = 0;
ssim26 = 0;
ssim27 = 0;
ssim28 = 0;
% class
is_roof = 0;
% output matrix
vars_out = 0;

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
        % load ground truth
        fname_gt = strcat(iname,'_GT','.bmp');
        fq_fname_gt=strcat(dir_path,fname_gt);
        Igt = imread(fq_fname_gt);
        % reduce image sizes
        if not(isequal(new_size,1))
            I = imresize(I, new_size);
            Igt = imresize(Igt, new_size);
        else
            disp('No image resizing.');
        end;
        
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
        % create entropy plane
        Ient_m = entropyfilt(Igs);
        %Ient_m = entropyfilt(Iahist);
        Ient = mat2gray(Ient_m);
        % Decorrelation stretch
        Idc = decorrstretch(Iah,'Tol', 0.01);
        % create red green and blue planes
        Ir = Idc(:,:,1);
        Ig = Idc(:,:,2);
        Ib = Idc(:,:,3);
        
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
                    
                    % tile structure similarity index per tile
                    % 1
                    ssim1I = imread(strcat(tiles_dir,'brown_grass.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim1 = ssim1val;
                    % 2
                    ssim1I = imread(strcat(tiles_dir,'car_bonnet.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim2 = ssim1val;
                    % 3
                    ssim1I = imread(strcat(tiles_dir,'car_window.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim3 = ssim1val;
                    % 4
                    ssim1I = imread(strcat(tiles_dir,'concrete_roofing.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim4 = ssim1val;
                    % 5
                    ssim1I = imread(strcat(tiles_dir,'flower_garden.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim5 = ssim1val;
                    % 6
                    ssim1I = imread(strcat(tiles_dir,'gray_roof_edge.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim6 = ssim1val;
                    % 7
                    ssim1I = imread(strcat(tiles_dir,'gray_roof_horiz_line.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim7 = ssim1val;
                    % 8
                    ssim1I = imread(strcat(tiles_dir,'green_grass.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim8 = ssim1val;
                    % 9
                    ssim1I = imread(strcat(tiles_dir,'marked_gray_roof.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim9 = ssim1val;
                    % 10
                    ssim1I = imread(strcat(tiles_dir,'moss_mould_brown.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim10 = ssim1val;
                    % 11
                    ssim1I = imread(strcat(tiles_dir,'moss_mould_orange.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim11 = ssim1val;
                    % 12
                    ssim1I = imread(strcat(tiles_dir,'new_gray_roof.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim12 = ssim1val;
                    % 13
                    ssim1I = imread(strcat(tiles_dir,'new_gray_roof_vertic_line1.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim13 = ssim1val;
                    % 14
                    ssim1I = imread(strcat(tiles_dir,'new_gray_roof_vertic_line2.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim14 = ssim1val;
                    % 15
                    ssim1I = imread(strcat(tiles_dir,'new_red_roof1.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim15 = ssim1val;
                    % 16
                    ssim1I = imread(strcat(tiles_dir,'new_red_roof2.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim16 = ssim1val;
                    % 17
                    ssim1I = imread(strcat(tiles_dir,'speckled_gray_roof.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim17 = ssim1val;
                    % 18
                    ssim1I = imread(strcat(tiles_dir,'stained_gray_roof1.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim18 = ssim1val;
                    % 19
                    ssim1I = imread(strcat(tiles_dir,'stained_gray_roof2.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim19 = ssim1val;
                    % 20
                    ssim1I = imread(strcat(tiles_dir,'stained_worn_gray_roof1.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim20 = ssim1val;
                    % 21
                    ssim1I = imread(strcat(tiles_dir,'stained_worn_gray_roof2.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim21 = ssim1val;
                    % 22
                    ssim1I = imread(strcat(tiles_dir,'tarmac.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim22 = ssim1val;
                    % 23
                    ssim1I = imread(strcat(tiles_dir,'tree_foliage1.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim23 = ssim1val;
                    % 24
                    ssim1I = imread(strcat(tiles_dir,'tree_foliage2.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim24 = ssim1val;
                    % 25
                    ssim1I = imread(strcat(tiles_dir,'washed_out_gray_roof.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim25 = ssim1val;
                    % 26
                    ssim1I = imread(strcat(tiles_dir,'white_wall.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim26 = ssim1val;
                    % 27
                    ssim1I = imread(strcat(tiles_dir,'worn_gray_roof1.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim27 = ssim1val;
                    % 28
                    ssim1I = imread(strcat(tiles_dir,'worn_gray_roof2.bmp'));
                    [ssim1val, ~] = ssim(Itile,ssim1I);
                    ssim28 = ssim1val;
                    
                    % convert gt sub matrix to vector
                    tile_v = Itile(:);
                    % extract features
                    ipos = si;
                    jpos = sj;
                    isegID = strcat(iname,'_i',num2str(si),'j',num2str(sj));
                    ivar = var(double(tile_v));
                    istdev = std(double(tile_v));
                    imin = min(double(tile_v));
                    imax = max(double(tile_v));
                    imean = mean(double(tile_v));
                    imed = median(double(tile_v));
                    imod = mode(double(tile_v));
                    
                    % ENTROPY
                    % create image tile matrix
                    Ietile = Ient_m(si:si+stile,sj:sj+stile);
                    % convert gt sub matrix to vector
                    etile_v = Ietile(:);
                    % extract features
                    ievar = var(double(etile_v));
                    iestdev = std(double(etile_v));
                    iemin = min(double(etile_v));
                    iemax = max(double(etile_v));
                    iemean = mean(double(etile_v));
                    iemed = median(double(etile_v));
                    iemod = mode(double(etile_v));
                    
                    % RED
                    % create image tile matrix
                    Irtile = Ir(si:si+stile,sj:sj+stile);
                    % convert gt sub matrix to vector
                    rtile_v = Irtile(:);
                    % extract features
                    irvar = var(double(rtile_v));
                    irstdev = std(double(rtile_v));
                    irmin = min(double(rtile_v));
                    irmax = max(double(rtile_v));
                    irmean = mean(double(rtile_v));
                    irmed = median(double(rtile_v));
                    irmod = mode(double(rtile_v));
                    
                    % GREEEN
                    % create image tile matrix
                    Igtile = Ig(si:si+stile,sj:sj+stile);
                    % convert gt sub matrix to vector
                    gtile_v = Igtile(:);
                    % extract features
                    igvar = var(double(gtile_v));
                    igstdev = std(double(gtile_v));
                    igmin = min(double(gtile_v));
                    igmax = max(double(gtile_v));
                    igmean = mean(double(gtile_v));
                    igmed = median(double(gtile_v));
                    igmod = mode(double(gtile_v));
                    
                    % BLUE
                    % create image tile matrix
                    Ibtile = Ib(si:si+stile,sj:sj+stile);
                    % convert gt sub matrix to vector
                    btile_v = Ibtile(:);
                    % extract features
                    ibvar = var(double(btile_v));
                    ibstdev = std(double(btile_v));
                    ibmin = min(double(btile_v));
                    ibmax = max(double(btile_v));
                    ibmean = mean(double(btile_v));
                    ibmed = median(double(btile_v));
                    ibmod = mode(double(btile_v));
                    
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
                    
                    % SAVE FEATURES TO TABLE
                    if (isequal(vars_out,0))
                        vars_out = {isegID,iname,ipos,jpos,ivar,istdev,imin,imax,imean,imed,imod,ievar,iestdev,iemin,iemax,iemean,iemed,iemod,irvar,irstdev,irmin,irmax,irmean,irmed,irmod,igvar,igstdev,igmin,igmax,igmean,igmed,igmod,ibvar,ibstdev,ibmin,ibmax,ibmean,ibmed,ibmod,ssim1,ssim2,ssim3,ssim4,ssim5,ssim6,ssim7,ssim8,ssim9,ssim10,ssim11,ssim12,ssim13,ssim14,ssim15,ssim16,ssim17,ssim18,ssim19,ssim20,ssim21,ssim22,ssim23,ssim24,ssim25,ssim26,ssim27,ssim28,is_roof};
                    else
                        vars_out = cat(1,vars_out,{isegID,iname,ipos,jpos,ivar,istdev,imin,imax,imean,imed,imod,ievar,iestdev,iemin,iemax,iemean,iemed,iemod,irvar,irstdev,irmin,irmax,irmean,irmed,irmod,igvar,igstdev,igmin,igmax,igmean,igmed,igmod,ibvar,ibstdev,ibmin,ibmax,ibmean,ibmed,ibmod,ssim1,ssim2,ssim3,ssim4,ssim5,ssim6,ssim7,ssim8,ssim9,ssim10,ssim11,ssim12,ssim13,ssim14,ssim15,ssim16,ssim17,ssim18,ssim19,ssim20,ssim21,ssim22,ssim23,ssim24,ssim25,ssim26,ssim27,ssim28,is_roof});
                    end;
                end;
            end;
        end;
    end;
end;

%% DEFINE DATA TABLE FIELDS AND WRITE FEATURE DATA TO FILE
% add variable names to table
mytab = array2table(vars_out, 'VariableNames', {'ImageSegmentID','ImageName','IPos','JPos','Variance','Stdev','Min','Max','Mean','Median','Mode','EVariance','EStdev','EMin','EMax','EMean','EMedian','EMode','RVariance','RStdev','RMin','RMax','RMean','RMedian','RMode','GVariance','GStdev','GMin','GMax','GMean','GMedian','GMode','BVariance','BStdev','BMin','BMax','BMean','BMedian','BMode','ssim1','ssim2','ssim3','ssim4','ssim5','ssim6','ssim7','ssim8','ssim9','ssim10','ssim11','ssim12','ssim13','ssim14','ssim15','ssim16','ssim17','ssim18','ssim19','ssim20','ssim21','ssim22','ssim23','ssim24','ssim25','ssim26','ssim27','ssim28','IsRoof'});
% write table to csv
fqfname = strcat(writepath,writefile);
writetable(mytab,fqfname);

%% DISPLAY EXAMPLE IMAGE AND TILES SIZE
%% Example Image to show tiles
Iexample = imread(strcat(dir_path,example_image));
Iexample = imresize(Iexample, new_size);
[ht, wd, dp] = size(Iexample);
%Itiles = uint8(zeros(ht,wd,dp));
% Image Tile Loop
for si = 1:tile:ht
    for sj = 1:tile:wd
        if (si+tile < ht && sj+tile < wd)
            Iexample(si:si+tile,sj:sj+1,1) = 255;
            Iexample(si:si+1,sj:sj+tile,1) = 255;
            Iexample(si:si+1,sj:sj+1,2:3) = 0;
        end;
    end;
end;
figure, imshow(Iexample);
