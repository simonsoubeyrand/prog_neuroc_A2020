function [x, y] = fabrique_grille_2d(patchSize)
% [x, y] = fabrique_grille_2d(patchSize)
%
% Frederic Gosselin, 20/01/2003

halfPatchSize = patchSize / 2;
[x, y] = meshgrid(-halfPatchSize:halfPatchSize-1, -halfPatchSize:halfPatchSize-1);
x = x / patchSize * 2 * pi;
y = y / patchSize * 2 * pi;
end