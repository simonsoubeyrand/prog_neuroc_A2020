function gabor = fabriquer_gabor(patchSize, amplitude, frequence, phase, orientation, nb_ecart_type)
% gabor = fabriquer_gabor(patchSize, amplitude, frequence, phase, orientation, nb_ecart_type)
% 
% Frederic Gosselin, 4/3/2008

grille_sin = fabriquer_grille_sin(patchSize, amplitude, frequence, phase, orientation);
gaussienne = fabriquer_enveloppe_gauss(patchSize, nb_ecart_type);
gabor = (grille_sin-.5).*gaussienne+.5;