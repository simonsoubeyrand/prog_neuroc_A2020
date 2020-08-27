function gaussienne = fabriquer_enveloppe_gauss(patchSize, nb_ecart_type)
% gaussienne = fabriquer_enveloppe_gauss(patchSize, nb_ecart_type)
%
% nb_ecart_type est le nombre d'ecart type de la gaussienne qui rentre dans la largeur de l'image.
% 
% Frederic Gosselin, 22/01/2003
[x, y] = fabrique_grille_2d(patchSize);
nb_ecart_type = pi / nb_ecart_type;
gaussienne = exp(-(x .^2 / nb_ecart_type ^2) - (y .^2 / nb_ecart_type ^2));
gaussienne = (gaussienne - min(gaussienne(:))) / (max(gaussienne(:)) - min(gaussienne(:)));