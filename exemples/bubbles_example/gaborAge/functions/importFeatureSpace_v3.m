function [ gabvects,ImGabParams ] = importFeatureSpace_v3(fnames,options)
%importFeatureSpace imports the 300 best features for the diagnostic cat
%vs. dog feature experiment

featurePath = options.featurePath;
ImSize      = options.ImSize;
nFts        = options.nFts;
nCats       = options.nCats;
ImGabParams = options.ImGabParams;
gabvects    = zeros(ImSize^2,nFts,nCats,'int8');

for c=1:nCats
    a=load(fullfile(featurePath,fnames(c).name()));
    gabvects(:,:,c)=a.BestGabVects(:,1:nFts);
    ImGabParams(:,:,c)=a.BestGabParams(1:nFts,:);
end


% figure;
% displ = zeros(ImSize);
% displ(:)=squeeze(sum(AllTop2000Gabs,2));
% displ = displ+abs(min(displ(:)));
% displ = (displ./max(displ(:))).*255;
% imagesc(displ)
% colormap(gray);
% axis equal off