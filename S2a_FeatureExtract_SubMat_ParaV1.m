%% CLEAR DOWN AND STARTUP
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';
% Parallel Processing parameters
delete(gcp('nocreate'));
parpool(14);

%% USER VARIABLES
new_size = 1;
tile = 50;
class_thresh = 1;
image_dir = 'VALIDATE_2';
% DATA INPUT VARS
database_root = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\';
dir_path = strcat(database_root,image_dir,'\');
tiles_dir = '\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\texture_tiles\';
% DATA OUTPUT VARS
writepath = '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\ppData\';
% FEATURES
% feature normal
features = {'ImageSegmentID','ImageName','IPos','JPos','Variance','Stdev','Min','Max','Mean','Median','Mode','EVariance','EStdev','EMin','EMax','EMean','EMedian','EMode','RVariance','RStdev','RMin','RMax','RMean','RMedian','RMode','GVariance','GStdev','GMin','GMax','GMean','GMedian','GMode','BVariance','BStdev','BMin','BMax','BMean','BMedian','BMode','IsRoof'};
dummy_row = {'DUMMY','DUMMY',1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,0};
% features ssim
%features = {'ImageSegmentID','ImageName','IPos','JPos','Variance','Stdev','Min','Max','Mean','Median','Mode','EVariance','EStdev','EMin','EMax','EMean','EMedian','EMode','RVariance','RStdev','RMin','RMax','RMean','RMedian','RMode','GVariance','GStdev','GMin','GMax','GMean','GMedian','GMode','BVariance','BStdev','BMin','BMax','BMean','BMedian','BMode','ssim1','ssim2','ssim3','ssim4','ssim5','ssim6','ssim7','ssim8','ssim9','ssim10','ssim11','ssim12','IsRoof'};
%dummy_row = {'DUMMY','DUMMY',1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0};

%% LOOP AUTO FEATURE EXTRACTION
disp('Feature Extraction started...');
disp(datetime('now'));
% get list of files with extension JPG
flist = dir(strcat(dir_path,'*JPG'));
[flh, flw] = size(flist);
% iterate over list of files
%for i = 1:2
%for i = 1:flh;
%parfor i = 1:2
parfor i = 1:flh;
    fname = flist(i).name;
    nlen = length(fname);
    if isequal(1,regexp(fname,'[^ . _]\w*[.]JPG'))
        % LOAD/RESIZE ORIGINAL AND GROUND TRUTH IMAGES
        full_fname=strcat(dir_path,fname);
        I = imread(full_fname);
        iname = fname(1:length(fname)-4);
        outstr = strcat('Processing Image:',num2str(i),' of:',num2str(flh),'. File:',fname);
        disp(outstr);
        % load ground truth
        fname_gt = strcat(iname,'_GT','.bmp');
        fq_fname_gt=strcat(dir_path,fname_gt);
        Igt = imread(fq_fname_gt);
        % reduce image sizes
        if (~isequal(new_size,1))
            I = imresize(I, new_size);
            Igt = imresize(Igt, new_size);
            disp(strcat('Resizing to:',num2str(new_size)));
        end;
        
        % OUTPUT FILE
        writefile = strcat('PPDv1_',image_dir,'_',num2str(round(new_size*100)),'ip',num2str(tile),'ts',num2str(round(class_thresh*100)),'cp_',iname,'.csv');
        fqwritefile = strcat(writepath,writefile);
        % empty data table
        data_table = cell2table(dummy_row,'VariableNames',features);
        % write empty table to csv if file does not exist
        if (isequal(exist(fqwritefile,'file'),0))
            writetable(data_table,fqwritefile);
        end;
        
        % IMAGE ENHANCEMENT
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
        % output variables
        vars_out = 0;
        % tile sizes to segment image into
        stile = tile-1;
        [ht, wd] = size(Igs);
        % Image Tile Loop
        for si = 1:tile:ht
            for sj = 1:tile:wd
                if (si+tile <= ht && sj+tile <= wd)
                    % GRAYSCALE
                    % create image tile matrix
                    Itile = Igs(si:si+stile,sj:sj+stile);
                    
                    % STRUCTURAL SIMILARITY
                    % 1
%                     ssim1I = imread(strcat(tiles_dir,'ssim1_new_gray_roof1.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim1 = ssim1val;
%                     % 2
%                     ssim1I = imread(strcat(tiles_dir,'ssim2_new_gray_roof2.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim2 = ssim1val;
%                     % 3
%                     ssim1I = imread(strcat(tiles_dir,'ssim3_new_gray_roof3.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim3 = ssim1val;
%                     % 4
%                     ssim1I = imread(strcat(tiles_dir,'ssim4_dark_gray_roof1.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim4 = ssim1val;
%                     % 5
%                     ssim1I = imread(strcat(tiles_dir,'ssim5_dark_gray_roof2.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim5 = ssim1val;
%                     % 6
%                     ssim1I = imread(strcat(tiles_dir,'ssim6_light_washed_out_roof1.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim6 = ssim1val;
%                     % 7
%                     ssim1I = imread(strcat(tiles_dir,'ssim7_light_washed_out_roof2.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim7 = ssim1val;
%                     % 8
%                     ssim1I = imread(strcat(tiles_dir,'ssim8_light_washed_out_roof3.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim8 = ssim1val;
%                     % 9
%                     ssim1I = imread(strcat(tiles_dir,'ssim9_new_red_roof1.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim9 = ssim1val;
%                     % 10
%                     ssim1I = imread(strcat(tiles_dir,'ssim10_distant_gray_roof1.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim10 = ssim1val;
%                     % 11
%                     ssim1I = imread(strcat(tiles_dir,'ssim11_brown_stained_gray_roof1.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim11 = ssim1val;
%                     % 12
%                     ssim1I = imread(strcat(tiles_dir,'ssim12_dark_stained_roof2.bmp'));
%                     [ssim1val, ~] = psnr(Itile,ssim1I);
%                     ssim12 = ssim1val;
                    
                    % GRAYSCALE FEATURES
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
                    
                    % ADD TILE FEATURE VARS TO CELL MATRIX
                    if (isequal(vars_out,0))
                        % normal features
                        vars_out = {isegID,iname,ipos,jpos,ivar,istdev,imin,imax,imean,imed,imod,ievar,iestdev,iemin,iemax,iemean,iemed,iemod,irvar,irstdev,irmin,irmax,irmean,irmed,irmod,igvar,igstdev,igmin,igmax,igmean,igmed,igmod,ibvar,ibstdev,ibmin,ibmax,ibmean,ibmed,ibmod,is_roof};
                        % ssim
                        % vars_out = {isegID,iname,ipos,jpos,ivar,istdev,imin,imax,imean,imed,imod,ievar,iestdev,iemin,iemax,iemean,iemed,iemod,irvar,irstdev,irmin,irmax,irmean,irmed,irmod,igvar,igstdev,igmin,igmax,igmean,igmed,igmod,ibvar,ibstdev,ibmin,ibmax,ibmean,ibmed,ibmod,ssim1,ssim2,ssim3,ssim4,ssim5,ssim6,ssim7,ssim8,ssim9,ssim10,ssim11,ssim12,is_roof};
                    else
                        % normal features
                        vars_out = cat(1,vars_out,{isegID,iname,ipos,jpos,ivar,istdev,imin,imax,imean,imed,imod,ievar,iestdev,iemin,iemax,iemean,iemed,iemod,irvar,irstdev,irmin,irmax,irmean,irmed,irmod,igvar,igstdev,igmin,igmax,igmean,igmed,igmod,ibvar,ibstdev,ibmin,ibmax,ibmean,ibmed,ibmod,is_roof});
                        % ssim
                        % vars_out = cat(1,vars_out,{isegID,iname,ipos,jpos,ivar,istdev,imin,imax,imean,imed,imod,ievar,iestdev,iemin,iemax,iemean,iemed,iemod,irvar,irstdev,irmin,irmax,irmean,irmed,irmod,igvar,igstdev,igmin,igmax,igmean,igmed,igmod,ibvar,ibstdev,ibmin,ibmax,ibmean,ibmed,ibmod,ssim1,ssim2,ssim3,ssim4,ssim5,ssim6,ssim7,ssim8,ssim9,ssim10,ssim11,ssim12,is_roof});
                    end;
                end;
            end;
        end;
        % WRITE IMAGE FEATURES TO FILE
        % prepare new table data for new tile
        new_tb = cell2table(vars_out,'VariableNames',features);
        % read current data and concatenate with new data
        read_tb = readtable(fqwritefile);
        write_tb = [read_tb;new_tb];
        % write concatenated table data to file
        writetable(write_tb,fqwritefile);
        disp(strcat('Processing Complete for Image:',num2str(i),'. File:',fname));
    end;
end;

master_table = cell2table(dummy_row,'VariableNames',features);
writefile = strcat('PPDv1_',image_dir,'_',num2str(round(new_size*100)),'ip',num2str(tile),'ts',num2str(round(class_thresh*100)),'cp_ALL.csv');
master_fqfile = strcat(writepath,'master\',writefile);
% write empty table to csv if file does not exist
if (isequal(exist(writefile,'file'),0))
    disp('Merging tables...');
    disp(datetime('now'));
    writetable(master_table,master_fqfile);
    % get list of files with extension JPG
    flist = dir(strcat(writepath,'*csv'));
    [flh, flw] = size(flist);
    % iterate over list of files
    for i = 1:flh;
        fname = flist(i).name;
        if isequal(1,regexp(fname,'[^ . _]\w*[.]csv'))
            full_fname=strcat(writepath,fname);
            new_tb = readtable(full_fname);
            read_mtb = readtable(master_fqfile);
            write_mtb = [read_mtb;new_tb(2:height(new_tb),:)];
            % write concatenated table data to file
            writetable(write_mtb,master_fqfile);
            if (i==flh)
                read_fmtb = readtable(master_fqfile);
                final_mtb = read_fmtb(2:height(read_fmtb),:);
                writetable(final_mtb,master_fqfile);
            end;
        end;
    end;
else
    disp('WARNING: Master file exists. Will not merge output into master file.');
end;
disp('Feature Extraction complete.');
disp(datetime('now'));
disp('Script complete.');
