function grille_sin = fabriquer_grille_sin(patchSize, amplitude, frequence, phase, orientation)
% grille_sin = fabriquer_grille_sin(patchSize, amplitude, frequence, phase, orientation)
% 
% Frederic Gosselin, 22/01/2003
[x, y] = fabrique_grille_2d(patchSize);
u = cos(orientation);
v = sin(orientation);
grille_sin = amplitude * (sin(frequence * (v .* x + u .* y) + phase) / 2) + .5;
