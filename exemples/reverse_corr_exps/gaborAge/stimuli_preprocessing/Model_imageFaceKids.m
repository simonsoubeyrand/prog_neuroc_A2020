% Model image set : faces
ImSize=250;
NrOris=12;
nSFs=20;
LowestSFexp=2/5;%10^.4~=1.098*2;
LowestSF=10^LowestSFexp;
highestSFexp=1.758;% 
MinPhaseDistBetwGabs=.20;
SelTopGabProp=.15;
stepGrid=1;
desiredNumber=2200;
stimuli_type='faces';
OpDir='~/gaborAge/stimuli_preprocessing/Stimuli_Kids';
d=dir(fullfile(OpDir,'*.png'));

for DatIm=2:length(d)

InPutImg=fullfile(d(DatIm).folder,d(DatIm).name);

ModelImageWIthSmallGabSet_v2(ImSize,NrOris,nSFs,LowestSFexp,highestSFexp,MinPhaseDistBetwGabs,SelTopGabProp,InPutImg,OpDir,stepGrid,desiredNumber,stimuli_type)
end

%%