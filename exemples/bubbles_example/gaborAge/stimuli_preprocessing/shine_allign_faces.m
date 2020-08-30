function shine_allign_faces
% Preprocess face stimuli : 1) cropping as a square image, 2) allign faces
% according to 20 landmarks (eyes, brows, nose, mouth), 3) add ellipse to
% throw out external cues (e.g. ears, hair) and 4) control for low-level luminance differences
% with SHINE toolbox

%% First load all stim from folders and put them in DeseImages structures. Compute mean images.
addpath(fullfile('~/gaborFeat/SHINEtoolbox'))


clear Images

stimuliPath=fullfile('~/gaborAge/stimuli_preprocessing/Image_Kids_raw');
Images=readImages(stimuliPath,'jpg');


Mean_all=zeros(size(Images{1}));
for ii=1:2
    for  DisIm=1:length(Images),Mean_all=Mean_all+double(Images{DisIm});end
end
Mean_all=(Mean_all-min(Mean_all(:)))/(max(Mean_all(:))-min(Mean_all(:)));
figure, imshow(stretch(Mean_all))

%% Crop DeseImages
%load 'Images_cropped.mat'
% [cropped, rect] = imcrop(stretch(double(DeseImages_male{ii}{DisIm})));

% [cropped, rect3] = imcrop(stretch(double(IM_cropped_female{ii}{DisIm})));
[cropped, rect] = imcrop(Mean_all);

% load('Images_cropped.mat','im_all', 'rect')
rect2=rect;

counter=0;
clear IM_cropped_neutral
for DisIm=1:length(Images)
IM_cropped_neutral{DisIm} = imcrop(Images{DisIm},rect2);
figure, imshow(IM_cropped_neutral{DisIm})
end

im_all=imcrop(Mean_all,rect2);

figure, imshow(im_all)
% save('Images_cropped_Kids.mat','im_all', 'rect','IM_cropped_neutral')
%% Align features from each images
% load('Faces_alligned.mat')
% load 'Images_cropped.mat'
% 1-2-3-4: left eye
% 5-6-7-8: right eye
% 9-10-11-12: mouth
% 13-14: left eyebrow
% 15-16: right eyebrow
% 17-18-19-20: nose
% 
% %template coordinates based on Average of all stimuli
% n=20;
% figure, imshow(im_all)
% 
% [x_coord y_coord] = ginput(n);
% template_coord=[x_coord y_coord];

% save('template_coord_v1_Kids.mat', 'template_coord','Pts')
%% warp images

% load('template_coord_v1.mat', 'template_coord')
for ii=6

im1=(im_all);
im2=(IM_cropped_neutral{ii});
%cpselect(MOVING,FIXED) returns control points in CPSTRUCT. MOVING is the image that needs to be warped to bring it into the coordinate system of the FIXED image
[pts2, pts1] = cpselect(im2, im1, template_coord, template_coord, 'Wait', true);


pts2better = cpcorr(pts2, pts1, mean(im2,3), mean(im1,3));


Pts{ii}=pts2better
end
%% mean of all points
ptsF = cell(size(Pts));
load('template_coord_v1.mat')
for Datface = 1:ii
    ptsF{Datface}(1,:) = mean(Pts{Datface}(1:4,:)); % l eye
    ptsF{Datface}(2,:) = mean(Pts{Datface}(5:8,:)); % r eye
    ptsF{Datface}(3,:) = mean(Pts{Datface}(9:12,:)); % mouth
    ptsF{Datface}(4,:) = mean(Pts{Datface}(13:14,:)); % l eyebrow
    ptsF{Datface}(5,:) = mean(Pts{Datface}(15:16,:)); % r eyebrow
    ptsF{Datface}(6,:) = mean(Pts{Datface}(17:20,:)); % nose
end

pts_mean = zeros(6,2);counter=0;
for Datface = 1:ii, counter=counter+1;  pts_mean = pts_mean + ptsF{Datface};end
pts_mean = pts_mean./(counter);

dd=load('template_coord_v1_Kids.mat');
for Datface = 1:ii
    ptsK{Datface}(1,:) = mean(dd.Pts{Datface}(1:4,:)); % l eye
    ptsK{Datface}(2,:) = mean(dd.Pts{Datface}(5:8,:)); % r eye
    ptsK{Datface}(3,:) = mean(dd.Pts{Datface}(9:12,:)); % mouth
    ptsK{Datface}(4,:) = mean(dd.Pts{Datface}(13:14,:)); % l eyebrow
    ptsK{Datface}(5,:) = mean(dd.Pts{Datface}(15:16,:)); % r eyebrow
    ptsK{Datface}(6,:) = mean(dd.Pts{Datface}(17:20,:)); % nose
end



% 
% 
% %also try with mytform
% mytform=cp2tform(Pts{face}, template_coord,'projective');
% 
% transformed=imtransform(im_all{1}{face},mytform);

for Datface = 1:counter
    im2 = IM_cropped_neutral{Datface};
    TFORM1 = fitgeotrans(ptsK{Datface},pts_mean,'NonreflectiveSimilarity');
    Rfixed = imref2d(size(im2));
    Faces{Datface} = im2;
    Faces_alligned{Datface} = imwarp(im2,TFORM1, 'FillValues', 255, 'OutputView', Rfixed);
end

figure,
for jj=1:counter, subplot(2,counter,jj),imshow(Faces{jj});subplot(2,counter,jj+counter), imshow(Faces_alligned{jj});end
% for jj=counter, subplot(2,1,1),imshow(Faces{jj});subplot(2,1,2), imshow(Faces_alligned_fear{jj});end
% save('Faces_alligned_Fear.mat','Faces_alligned_fear','Pts','ptsF','template_coord')
% save('Faces_alligned.mat','Faces','Faces_alligned','Pts','ptsF','template_coord')
%% make Ellipse mask

% xmin=(528-486)/2;ymin=xmin;width=486;height=486;
% clear ellipse
% figure,
% for DisIm=1:8
%  DatImage=(Faces_alligned{DisIm}(:,8:(end-9)));
%  DatImage=imresize(Faces_alligned{DisIm}(:,8:(end-9)),[528 528]);
%  DatImage=imcrop(DatImage,[xmin ymin width height]);
% % DatImage=Faces_alligned{DisIm};
% % Faces_alligned_2{DisIm} = imtranslate(DatImage,[0, -20])
% Faces_alligned_2{DisIm} = imtranslate(DatImage,[0, -30])
% DatImage=Faces_alligned_2{DisIm};
% imHalfSize=size(DatImage,1)/2;
% X0=0; %Coordinate X
% Y0=0; %Coordinate Y
% % l=imHalfSize/2.0; %Width
% % w=imHalfSize/1.35; %Length
% l=imHalfSize/1.80; %WitdthLength
% w=imHalfSize/1.35; %Length
% phi=45; %Degree you want to rotate
% [X Y] = meshgrid(-imHalfSize:imHalfSize-1,-imHalfSize:imHalfSize-1); %make a meshgrid: use the size of your image instead
% ellipse = ((X-X0)/l).^2+((Y-Y0)/w).^2<=1; %Your Binary Mask which you multiply to your image, but make sure you change the size of your mesh-grid
% 
% 
% 
% bck=zeros(size(ellipse));
% bck(ellipse==0)=128;
% 
% DatImage_ellipse{DisIm}=(SmoothCi(ellipse,8).*(double(DatImage)/255));
% subplot(2,4,DisIm), imshow(uint8(DatImage_ellipse{DisIm}*255)) % ok but black
% 
% end
% % % %------------ this was for adults ------------
% clear ellipse
% figure,
% for DisIm=1:6
%  DatImage=Faces_alligned{DisIm}(:,8:(end-9));
%  Faces_alligned_2{DisIm} = imtranslate(DatImage,[0, -30])
%  DatImage=Faces_alligned_2{DisIm};
% imHalfSize=size(DatImage,1)/2;
% X0=0; %Coordinate X
% Y0=0; %Coordinate Y
% % l=imHalfSize/2.0; %Width
% % w=imHalfSize/1.35; %Length
% l=imHalfSize/1.80; %WitdthLength
% w=imHalfSize/1.35; %Length
% phi=45; %Degree you want to rotate
% [X Y] = meshgrid(-imHalfSize:imHalfSize-1,-imHalfSize:imHalfSize-1); %make a meshgrid: use the size of your image instead
% ellipse = ((X-X0)/l).^2+((Y-Y0)/w).^2<=1; %Your Binary Mask which you multiply to your image, but make sure you change the size of your mesh-grid
% 
% 
% 
% bck=zeros(size(ellipse));
% bck(ellipse==0)=128;
% 
% DatImage_ellipse{DisIm}=(SmoothCi(ellipse,8).*(double(DatImage)/255));
% subplot(2,3,DisIm), imshow(uint8(DatImage_ellipse{DisIm}*255)) % ok but black
% 
% end
% ------------------------------------------------------------------------

% for DisIm=1:length(DeseImagesSad),IM_cropped{DisIm}(masque==0)=0;end

% [cropped, rect3] = imcrop(stretch(double(DatImage)));
% Recrop images
% rect4=rect3;
% rect4(4)=459;
% rect4(3)=459;
% rect4([1 3 4])=rect4([1 3 4])-10;
% for DisIm=1:length(Faces_alligned)
% Faces_alligned_Cropped{DisIm} = imcrop(Faces_alligned{DisIm},rect4);
% end
% % 
% DiffSize=size(Faces_alligned_Cropped{DisIm},1)-size(Faces_alligned_Cropped{DisIm},2);

%% Now Shine DeseImages

clear im_all
counter=0;
for ii=1:6
    counter=counter+1;
    IM_alligned_ell{counter}=uint8(Faces_alligned_2{ii});%uint8(DatImage_ellipse{ii}*255);%
end

Shined_lumMatchEllipse= SHINE(IM_alligned_ell,ellipse);
save('Stimuli_alligned_ellipse_shined_Kids.mat','Shined_lumMatchEllipse','ellipse','Faces_alligned_2')

%% Test stimuli

imHalfSize=size(Shined_lumMatchEllipse{1},1)/2;

for DisIm=1:8
    
    DatImage=Shined_lumMatchEllipse{DisIm};
    stimulus = (double(DatImage) - 127) .* SmoothCi(ellipse,8) + 127;

eval(sprintf('imwrite(uint8(stimulus),''Stimuli_alligned_ellipse_shined_%d.png'',''png'')',DisIm))

end

end