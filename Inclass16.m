% Inclass16

%The folder in this repository contains code implementing a Tracking
%algorithm to match cells (or anything else) between successive frames. 
% It is an implemenation of the algorithm described in this paper: 
%
% Sbalzarini IF, Koumoutsakos P (2005) Feature point tracking and trajectory analysis 
% for video imaging in cell biology. J Struct Biol 151:182?195.
%
%The main function for the code is called MatchFrames.m and it takes three
%arguments: 

% 1. A cell array of data called peaks. Each entry of peaks is data for a
% different time point. Each row in this data should be a different object
% (i.e. a cell) and the columns should be x-coordinate, y-coordinate,
% object area, tracking index, fluorescence intensities (could be multiple
% columns). The tracking index can be initialized to -1 in every row. It will
% be filled in by MatchFrames so that its value gives the row where the
% data on the same cell can be found in the next frame. 

%2. a frame number (frame). The function will fill in the 4th column of the
% array in peaks{frame-1} with the row number of the corresponding cell in
% peaks{frame} as described above.

%3. A single parameter for the matching (L). In the current implementation of the algorithm, 
% the meaning of this parameter is that objects further than L pixels apart will never be matched. 

% Continue working with the nfkb movie you worked with in hw4. 
addpath('TrackingCode/');
reader1 = bfGetReader('../hw4-franklenoir/nfkb_movie1.tif');
iplane = reader1.getIndex(1-1,1-1,1-1)+1;
tempimg1 = bfGetPlane(reader1,iplane);
iplane2 = reader1.getIndex(1-1,1-1,2-1)+1;
tempimg2 = bfGetPlane(reader1,iplane2);

% Part 1. Use the first 2 frames of the movie. Segment them any way you
% like and fill the peaks cell array as described above so that each of the two cells 
% has 6 column matrix with x,y,area,-1,chan1 intensity, chan 2 intensity

iplane = reader1.getIndex(1-1,1-1,1-1)+1;
tempimg1 = bfGetPlane(reader1,iplane);
iplane2 = reader1.getIndex(1-1,1-1,2-1)+1;
tempimg2 = bfGetPlane(reader1,iplane2);

lims = [100 2000];
figure;
subplot(1,2,1); imshow(tempimg1,lims);
subplot(1,2,2); imshow(tempimg2,lims);

figure; imshowpair(imadjust(tempimg1),imadjust(tempimg2));

mask1 = tempimg1 > 700;
mask2 = tempimg2 > 700;

imshowpair(mask1, mask2);

mask1 = imopen(mask1, strel('disk', 5));
mask2 = imopen(mask2, strel('disk', 5));
mask1 = imfill(mask1, 'holes');
mask2 = imfill(mask2, 'holes');
mask1 = imdilate(mask1, strel('disk', 5));
mask2 = imdilate(mask2, strel('disk', 5));
imshowpair(mask1, mask2);

chan1dat1 = regionprops(mask1, tempimg1, 'Centroid', 'Area', 'MeanIntensity');
chan1dat2 = regionprops(mask2, tempimg2, 'Centroid', 'Area', 'MeanIntensity');

iplane = reader1.getIndex(1-1,2-1,1-1)+1;
tempimg1 = bfGetPlane(reader1,iplane);
iplane2 = reader1.getIndex(1-1,2-1,2-1)+1;
tempimg2 = bfGetPlane(reader1,iplane2);

chan2dat1 = regionprops(mask1, tempimg1,  'MeanIntensity');
chan2dat2 = regionprops(mask2, tempimg2,  'MeanIntensity');

xy = cat(1, chan1dat1.Centroid);
xy2 = cat(1, chan1dat2.Centroid);
area = cat(1, chan1dat1.Area);
area2 = cat(1, chan1dat2.Area);
meanint = cat(1, chan1dat1.MeanIntensity);
meanint1_2 = cat(1, chan1dat2.MeanIntensity);
meanint2 = cat(1, chan2dat1.MeanIntensity);
meanint2_2 = cat(1, chan2dat2.MeanIntensity);
negones = -1*ones(size(area));
negones2 = -1*ones(size(area2));
peak = [xy, area, negones,meanint,meanint2];
peaks{1} = num2cell(peak);
peak = [xy2, area2, negones2,meanint1_2,meanint2_2];
peaks{2} = num2cell(peak(1:27,:));

% Part 2. Run match frames on this peaks array. ensure that it has filled
% the entries in peaks as described above. 

peaks_matched = MatchFrames(peaks, 2,0.1);
%Index exceeds matrix dimensions. Unable to fix this issue. 

% Part 3. Display the image from the second frame. For each cell that was
% matched, plot its position in frame 2 with a blue square, its position in
% frame 1 with a red star, and connect these two with a green line. 

