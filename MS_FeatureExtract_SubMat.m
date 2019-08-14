%%
% clear down
clc;
clear all;
close all;
echo off;
cd '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\Scripts';
% choose and load file
[fname path] = uigetfile('\\surrey.ac.uk\personal\HS216\tm00529\TimsFiles\Dissertation\DATABASE\TEST_1\*.JPG*','Choose Image...');
fq_fname=strcat(path,fname);
I = imread(fq_fname);
% load ground truth plane
fname_nx = fname(1:length(fname)-4);
fname_gt = strcat(fname_nx,'_GT','.bmp');
fq_fname_gt=strcat(path,fname_gt);
Igt = imread(fq_fname_gt);

%% reduce image sizes
new_size = 0.25;
Io = I;
I = imresize(I, new_size);
Igto = Igt;
Igt = imresize(Igt, new_size);

%%
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

% adaptive histogram equalisation for shadow reduction
%Iahist = adapthisteq(Igs,'clipLimit',0.01,'Distribution','rayleigh');

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

figure;
subplot(3,3,1), imshow(I); title('Original Image');
subplot(3,3,2), imshow(Iah); title('Adaptive Histogram Equalisation (adapthisteq)');
subplot(3,3,3), imshow(Idc); title('Decorrelation Stretch on adapthisteq');
subplot(3,3,4), imshow(Igs); title('Grayscale on adapthisteq');
subplot(3,3,5), imshow(Ient); title('Entropy Plane on grayscale');
subplot(3,3,6), imshow(Ir); title('Red Plane on decorrstretch');
subplot(3,3,7), imshow(Ig); title('Green Plane on decorrstretch');
subplot(3,3,8), imshow(Ib); title('Blue Plane on decorrstretch');
subplot(3,3,9), imshow(Igt); title('Ground Truth (Roof) Plane');

% Image to process
I_s = Igs;
% features to select
iname = fname(1:length(fname)-4);
ipos = 0;
jpos = 0;
ivar = 0;
istdev = 0;
imin = 0;
imax = 0;
imean = 0;
imed = 0;
imod = 0;
is_roof = 0;
% output matrix
vars_out = 0;
% tile sizes to segment image into
tile = 25;
stile = tile-1;
% loop variables
[ht, wd] = size(I_s);
I_gt_sub = uint8(zeros(ht,wd));
% process image loop
for si = 1:tile:ht
    for sj = 1:tile:wd
        if (si+tile < ht && sj+tile < wd)
            % create image tile matrix
            Itile = I_s(si:si+stile,sj:sj+stile);
            % convert gt sub matrix to vector
            tile_v = Itile(:);
            
            % extract features
            ipos = si;
            jpos = sj;
            ivar = var(double(tile_v));
            istdev = std(double(tile_v));
            imin = min(double(tile_v));
            imax = max(double(tile_v));
            imean = mean(double(tile_v));
            imed = median(double(tile_v));
            imod = mode(double(tile_v));
            % ground truth tile matrix
            gttile = Igt(si:si+stile,sj:sj+stile);
            % convert gt sub matrix to vector
            gtt_v = gttile(:);
            % calculate percent of tile which is gt roof and if greater than
            % threshold, add tile to new output image of gt tiles
            gt_pc = sum(gtt_v)/tile^2;
            if gt_pc > 0.8
               I_gt_sub(si:si+stile,sj:sj+stile) = I_s(si:si+stile,sj:sj+stile);
               is_roof = 1;
            else
                is_roof = 0;
            end;
            
            % save features to table
            if (isequal(vars_out,0))
                vars_out = {iname,ipos,jpos,ivar,istdev,imin,imax,imean,imed,imod,is_roof};
            else
                vars_out = cat(1,vars_out,{iname,ipos,jpos,ivar,istdev,imin,imax,imean,imed,imod,is_roof});
            end;
            
            % add bright pixel at tile start points
            I_gt_sub(si:si+1,sj:sj+1) = 255;
        end;
    end;
end;
% add variable names to table
mytab = array2table(vars_out, 'VariableNames', {'ImageName','IPos','JPos','Variance','Stdev','Min','Max','Mean','Median','Mode','IsRoof'});

% write table to csv
writepath = '\\surrey.ac.uk\personal\HS216\tm00529\MATLAB\ppData\';
fname = 'pp_data_1.csv';
fqfname = strcat(writepath,fname);
writetable(mytab,fqfname);
%figure, imshow(I_s);
%figure, imshow(I_gt_sub);
