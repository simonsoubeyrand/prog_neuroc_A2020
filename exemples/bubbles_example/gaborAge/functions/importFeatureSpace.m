function [ gabvects,ImGabParams ] = importFeatureSpace(fnames,options)
%importFeatureSpace imports the 300 best features for the diagnostic cat
%vs. dog feature experiment

featurePath = options.featurePath;
ImSize      = options.ImSize;
nFts        = options.nFts;
nCats       = options.nCats;
ImGabParams = options.ImGabParams;
gabvects    = zeros(ImSize^2,nFts,nCats,'int8');

for c=1:nCats
    load(fullfile(featurePath,fnames(c).name()));
    gabvects(:,:,c)=AllTop2000Gabs(:,1:2000);
    ImGabParams(:,:,c)=AllTop2000GabsParams(1:2000,:);
end


% figure;
% displ = zeros(ImSize);
% displ(:)=squeeze(sum(AllTop2000Gabs,2));
% displ = displ+abs(min(displ(:)));
% displ = (displ./max(displ(:))).*255;
% imagesc(displ)
% colormap(gray);
% axis equal off