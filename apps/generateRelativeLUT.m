% generateAccurateLUT.m
% 11 May 2015, Derin Sevenler

% This script generates a lookup table for an IRIS image.
% This script is only configured to work with TIFF stacks collected using micromanager, 
% saved in the order (blue, green, orange red). Use only a single image (not a time series)
% with this function.

% This script is designed to work with IRIS films that are not thick enough to be fit using nonlinear least squares regression: in water under 200nm, dry under 80nm.
% If your oxide thickness is more, you may get better results with 'generateRelativeLUT'.

%% Get fit parameters

prompt={'Media ("air" or "water")',
	'approximate oxide thickness',
	'lookup table - nm below',
	'lookup table - nm above',
	'lookup table - nm increment'};

name='Lookup table parameters';
numlines = 1;
defaultanswer={'air', '100','10','10','.1'}; 
options.Resize='on';
options.WindowStyle='normal';
answer=inputdlg(prompt,name,numlines,defaultanswer, options);

media = answer{1};
dApprox = answer{2};
minus = answer{3};
plus = answer{4};
dt = answer{5};

%% Load the images

% Get the measurement image file info
[file, folder] = uigetfile('*.*', 'Select the TIFF image stack (multicolor)');
tifFile= [folder filesep file];

% Get the mirror image file info
[mirFile, mirFolder] = uigetfile('*.*', 'Select the mirror file (TIFF image stack also)');
mirFile= [mirFolder filesep mirFile];

% load the first image to get the self-reference region
f = figure('Name', 'Please select a region of bare Si');
im = double(imread(tifFile, 1));
[~, selfRefRegion] = imcrop(im, double(median(im(:)))*[.8 1.2]);
pause(0.01); % so the window can close
close(f);

% Load the images. Normalize by the mirrors and self-reference regions
data = zeros(size(im,1), size(im,2), 4);
for channel = 1:4
	I = imread(tifFile, channel);
	mir = imread(mirFile, channel);
	In = double(I)./double(mir);
	sRef = imcrop(In, selfRefRegion);
	data(:,:,channel) = In./median(sRef(:));
end

%% Perform fitting and generate the look up table.

[d, bestColor, LUT, X] = noFitLUT(data, media, dApprox, minus, plus, dt);

% Save the LUT and the Parameters
results.LUT = LUT;
results.params.dGiven = dApprox;
results.params.plus = plus;
results.params.minus = minus;
results.params.dt = dt;
results.params.media = media;
results.params.origFile = [folder filesep file];

results.data_fitted = interp1(LUT(:,2), LUT(:,1), squeeze(data(:,:,bestColor)), 'nearest', 0);
figure; imshow(results.data_fitted,[dApprox-minus dApprox+plus]);


saveName = [file filesep datestr(now, 'HHMMSS') 'results.mat'];

    [filename, pathname] = uiputfile([datestr(now, 'HHMMSS') 'results.mat'], 'Save results as');

save(saveName, 'results');
