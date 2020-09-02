%% Function by Arjen Alink, UKE Hamburg, 30-11-2017, Version 1.0
% ModelImageWIthSmallGabSet(ImSize,NrOris,nSFs,LowestSF,MinPhaseDistBetwGabs,SelTopGabProp,InPutImg)
% This function reads a (square) image and models it with a set of Gabor
% wavelets trying to achieve the maximum fit with the fewest nr of gabors.
% The Wavelet set and their parameters are saved in a .mat file in the
% local directory
% Parameters:
%   ImSize: Square size that the inout image is reduced to before wavelet
%   modeling. Bigger size -> more details, longer computation time
%
%   NrOris: Number of evenly spaced orientations considered.
%   More orientations  ->better fit, longer computation time
%
%   nSFs:  Number of spatial frequency considered . idem
%   LowestSF=1.098; Lowest spatial frequency considered. This version selects
%   the SF set as LowestSF.^(1:nSFs). Mind that there is an upper limit to
%   the highers SF (pixels per cycle needs to be bigger than 2)
%
%   MinPhaseDistBetwGabs: This parameter specifies the minimum distance in
%   gabor wavelets phase units between selected Gabors with the same SF and
%   Ori. The lower this values, the greater the size of initially selected
%   wavelets Gabors -> too low values will result in high Memory usage and
%   increased computation time
%
%   SelTopGabProp: restricts wavelet position to the top proportion of
%   positions within each Ori and SF
%
%   inputImg: image file name

% Version 2.0 by Simon Faghel-Soubeyrand, U.Montreal/Birmingham, 01-10-2018
function ModelImageWIthSmallGabSet_v2(ImSize,NrOris,nSFs,LowestSFexp,highestSFexp,MinPhaseDistBetwGabs,SelTopGabProp,InPutImg,OpDir,stepGrid,desiredNumber,stimuli_type)
addpath(fullfile('~/gaborFeat/SHINEtoolbox/'))
% LowestSF=10^LowestSFexp;
% SFs=logspace(LowestSFexp,highestSFexp,nSFs); %  SF is defined as cycles per Image size in pixels. The SF set is selected exponentially between 2 SF limits.

LowestSF=1.098*1.10;
SFs=LowestSF.^(1:nSFs); % SF is defined as cycles per Image size in pixels. The SF set is selected exponentially.
oris=180/NrOris:180/NrOris:180; % orientations are sampled with equal distances between them

switch stimuli_type
    case 'objects'
name_img=extractBetween(InPutImg,'cropped_sized_stimuli/','.png');
% e=load('Stimuli_alligned_ellipse_shined.mat','ellipse');
    case 'scenes'
name_img=extractBetween(InPutImg,'_','.png');
% e=load('Stimuli_alligned_ellipse_shined.mat','ellipse');
    case 'faces'
name_img=extractBetween(InPutImg,'shined_','.png');
%         name_img=extractBetween(InPutImg,'shined_','.png');
e=load('Stimuli_alligned_ellipse_shined_Kids.mat','ellipse');
end

% % quick test params
SelectedParams=[num2str(ImSize), '_' ,num2str(NrOris),'_' ,num2str(nSFs),'_' ,num2str(LowestSF),'_' ,num2str(MinPhaseDistBetwGabs),'_' ,num2str(SelTopGabProp)];

% ensure that images are always the same sizes
img = imresize(single(imread(InPutImg)),[ImSize ImSize]);

ellipse=ones(size(img)); % not an ellipse for the perceptualFingerprint project
crop_x=50;
img=uint8(imcrop(img,[0+crop_x/2 0+crop_x/2 ImSize-crop_x ImSize-crop_x]));


% how sparse do you want the grid to be?
step=stepGrid; % no grid for the moment (perceptualFingerprint project, jan.2018, S.Faghel-Soubeyrand)
maskGrid=zeros(ImSize);maskGrid(1:step:end,1:step:end)=1;
maskGrid=(ellipse.*maskGrid);

if numel(size(img))>2 % if image is RGB, make it gray-scale
    img = (rgb2gray(img));
end
img = imresize(img,[ImSize ImSize]); %set to desired output size, input needs to be square

% obtain for each image pixel the optimal phase and amplitude for the
% Gabors with all selected Oris and SFs
mags=zeros(ImSize,ImSize,nSFs,NrOris);
phases=zeros(ImSize,ImSize,nSFs,NrOris);
tic
for c=1:nSFs
    for ori=1:NrOris
        Sigma=.5*(ImSize/SFs(c));
        [mags(:,:,c,ori), phases(:,:,c,ori)]=imgaborfilt(img,Sigma,oris(ori));
    end
end
toc

gabVects=zeros(250^2,0,'single'); % will contain ImSize^2 sized gabor wavelet vectors
gabparamscgv=zeros(0,6); % storing the parameters for all gabors saved in gabVects
gabCount=1;
for c=1:nSFs
    tic
    for ori =1:NrOris
        
        % for each SF and Ori first select only the pixels for which the
        % orientation provides the best fit across all orientations for the
        % given SF. Furthermore, for each orientation only the pixels among
        % the top proportion are selected
        PeakLocs=zeros(0,2);
        magMap=mags(:,:,c,ori);
        magMapRank=magMap;
        [~, inds]=sort(magMap(:));
        magMapRank(inds)=1:ImSize^2;
        magMapRankThr=magMapRank>round((1-SelTopGabProp)*(ImSize^2));
        [~, inds]=max(mags(:,:,c,:),[],4);
        GridIndices=(maskGrid);
%         possibleGabInds=find([inds==ones(ImSize)*ori==1&magMapRankThr==1&GridIndices]==1);
        possibleGabInds=find([inds==ones(ImSize)*ori==1&magMapRankThr==1]==1);
        [possibleGabXs, possibleGabYs]=ind2sub([ImSize,ImSize],possibleGabInds);

        % here we select the best fitting pixel, save its coordinates and
        % then removed the pixel and its neighbours (within
        % MinPhaseDistBetwGabsq). Then proces is repeated for the remnant
        % pixels until no pixels are left. This process selects top pixels
        % while at the same time ensuring that high contrast areas in the
        % image do not absorb all features. Furthermore, because MinPhaseDistBetwGabsq
        % depends on the SF, this leads to more features being selected for
        % higher SFs - which is highly desirable.
        while numel(possibleGabInds)>0
            [val, peakInd]=max(magMap(possibleGabInds));
            PeakLocs=[PeakLocs;possibleGabXs(peakInd),possibleGabYs(peakInd)];
            remLocs=pdist2(PeakLocs(end,:),[possibleGabXs, possibleGabYs],'euclidean')<=((ImSize/SFs(c))*MinPhaseDistBetwGabs);
            possibleGabInds(remLocs)=[];
            possibleGabXs(remLocs)=[];
            possibleGabYs(remLocs)=[];
        end
        
        % creating Gabor wavelets with optimal parameters for all selected
        % locations and saving their parameters.
        for i=1:size(PeakLocs,1)
            Sigma=.5*(ImSize/SFs(c));
            
            % gabor_phase is the Matlab function gabor with the additional
            % phase parameter. Importantly, this is the same function used
            % by imgaborfilt.
            GabWavelet=gabor_phase( Sigma,oris(ori),[],[],phases(PeakLocs(i,1),PeakLocs(i,2),c,ori));
            GabWavelet=real(GabWavelet.SpatialKernel);
            gabInIm=zeros(ImSize,'single');
            gabRange=(size(GabWavelet,1)-1)/2;
            Xrange=PeakLocs(i,1)-gabRange:PeakLocs(i,1)+gabRange;
            Yrange=PeakLocs(i,2)-gabRange:PeakLocs(i,2)+gabRange;
            ValidXrange=find([Xrange<ImSize&Xrange>1]==1);
            ValidYrange=find([Yrange<ImSize&Yrange>1]==1);
            gabInIm(Xrange( ValidXrange), Yrange( ValidYrange))=GabWavelet( ValidXrange,ValidYrange);
            gabVects(:,gabCount)= gabInIm(:);
            gabparamscgv(gabCount,:)=[ImSize,SFs(c)*2, oris(ori),phases(PeakLocs(i,1),PeakLocs(i,2),c,ori),PeakLocs(i,1),PeakLocs(i,2)];
            gabCount=gabCount+1;
        end
    end
    fprintf('preparing gabors for %d spatial frequencies\n',c);
    toc
end

% Gabors are sorted according the amount of variation they can account for
% divided the area that each wavelet covers. This is done is chunks of 1000
% to keep memory usage to a minimum
betas=[];
for i=1:1000:size(gabVects,2)
    if i+999<size(gabVects,2)
        betas=[betas; [gabVects(:,i:i+999)'*(double(img(:)))]]; %no betas but cov estimates
    else
        betas=[betas; [gabVects(:,i:end)'*(double(img(:)))]]; %no betas but cov estimates
    end
end
GabArea=sum(abs(gabVects));
[vals ExplVarRanking]=sort(betas./(GabArea.^(1*.95))','descend');%./GabArea';


% The best ranked Gabor is selected first and the next is added if adding
% it increases the correlation between the summed wavelet image and the
% original image. This process is repeated until an addition attempt has
% been made for each wavelet.
SelGabs=ExplVarRanking(1);
SelGabsSum=gabVects(:,SelGabs);
test1=zeros(ImSize);
for i=2:numel(ExplVarRanking)
    test1= sum(SelGabsSum,2);
    test2=  SelGabsSum+ gabVects(:,ExplVarRanking(i));
    if corr(double(img(:)),test1(:)) < corr(double(img(:)),test2(:)) % maybe try a correlation cut-off, maybe also to the reverse
        SelGabs= [SelGabs ExplVarRanking(i)];
        SelGabsSum= test2;
    end
    percentComplete = (i/numel(ExplVarRanking))*100;
    if mod(i,100)==0
    fprintf('finding the best ranked Gabors | %.2f%% done\n',percentComplete);
    end
end
size(SelGabs)

BestGabVects=int8(gabVects(:,SelGabs(1:desiredNumber))*(127/max(gabVects(:))));
BestGabParams=gabparamscgv(SelGabs(1:desiredNumber),:);
displ=zeros(ImSize);
displ(:)=sum(gabVects(:,SelGabs(1:desiredNumber)),2);
displ(:)=displ(:)+abs(min( displ(:)));
displ(:)= displ(:)/max(displ(:));
figure; imagesc(displ), title(sprintf('%4.0f gabors needed',size(SelGabs,2)))
colormap('gray'); axis square;

imwrite(displ,fullfile(OpDir,sprintf('%s_%s_BestFts.png',name_img{1},num2str(desiredNumber))),'png');
save(fullfile(OpDir, sprintf('%s_OptSetOfGabs_Params_%s.mat',name_img{1}, SelectedParams)),'gabparamscgv','ExplVarRanking','BestGabVects','BestGabParams');
end