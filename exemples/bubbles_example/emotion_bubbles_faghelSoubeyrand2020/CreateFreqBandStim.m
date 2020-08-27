function [out]=CreateFreqBandStim(varargin)

anImage = double(varargin{1});
whichFreqBands=varargin{2};
nBands=length(whichFreqBands);
	[ySize, xSize] = size(anImage);
	nPeriod=3; nZero=2.18;
	stdev = nPeriod * 2^(4);
	maxHalfSize5 = round(stdev * nZero);
	gauss5 = zeros(2*maxHalfSize5,2*maxHalfSize5);
	[y,x] = meshgrid(-maxHalfSize5:maxHalfSize5,-maxHalfSize5:maxHalfSize5);
	gauss5 = exp(-(x.^2/stdev^2)-(y.^2/stdev^2));
	gauss5 = gauss5/max(gauss5(:));
	clear x, y;
	method = 'nearest';
	stdev = nPeriod * 2^(4);
	maxHalfSize4 = round(stdev * nZero);
	gauss4 = double(imresize(gauss5,[(2*maxHalfSize4+1) (2*maxHalfSize4+1)], method));
	stdev = nPeriod * 2^(3);
	maxHalfSize3 = round(stdev * nZero);
	gauss3 = double(imresize(gauss5,[(2*maxHalfSize3+1) (2*maxHalfSize3+1)], method));
	stdev = nPeriod * 2^(2);
	maxHalfSize2 = round(stdev * nZero);
	gauss2 = double(imresize(gauss5,[(2*maxHalfSize2+1) (2*maxHalfSize2+1)], method));
	stdev = nPeriod * 2^(1);
	maxHalfSize1 = round(stdev * nZero);
	gauss1 = double(imresize(gauss5,[(2*maxHalfSize1+1) (2*maxHalfSize1+1)], method));
	fGauss=mkGaussian(11);
	fGauss1=fGauss(:,1);
	fGauss1=sqrt(2)*fGauss1/sum(fGauss1);
	clear fGauss BandStim;
	winPlane = double(zeros(ySize,xSize));
	[pyr,pind] = buildLpyr(double(anImage),nBands,fGauss1);
	stimulus = zeros(ySize,xSize);
	for ii = whichFreqBands	
		nameGauss = sprintf('gauss%d',ii);
		nameMax = sprintf('maxHalfSize%d',ii);
		temp = eval(nameMax);
		tempPlane = zeros(ySize+temp-1,xSize+temp-1);
		tempPlane = real(ifft2(fft2(eval(nameGauss),ySize+temp-1,xSize+temp-1)));
		winPlane = min(tempPlane(temp:ySize+temp-1,temp:xSize+temp-1), 1);
		stimulus = stimulus + double(reconLpyr(pyr,pind,[ii],fGauss1));
        BandStim(:,:,ii)=double(reconLpyr(pyr,pind,[ii],fGauss1)) + double(reconLpyr(pyr,pind,[nBands],fGauss1));
%          figure, imshow(uint8(squeeze(BandStim(:,:,ii))))
	end
% 	theStimulus = (stimulus + double(reconLpyr(pyr,pind,[nBands],fGauss1)));
out=(BandStim);
end

