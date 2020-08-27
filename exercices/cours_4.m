im = double(imread('w1N.JPG'))/255; % im en double qui varie entre 0 et 1
bruit = randn(size(im)); % bruit normal standard (moyenne de 0 et ecart-type de 1) de la taille de im
stimulus = im+bruit;

% est-ce viable? non
figure, imshow(stimulus) % trop saturee

% plus evident sur une histogramme des valeurs
figure, hist(stimulus(:))

% en fait, ce qui depasse devient soit 0, soit 1
figure, hist(min(max(stimulus(:),0),1))

% on doit donc reduire le contraste de l'image ou l'ecart-type du bruit
im = double(imread('w1N.JPG'))/255; % im en double qui varie entre 0 et 1
facteur = 0.05;
im = facteur * (im-.5)+.5;
ecart_type = 0.05;
bruit = ecart_type * randn(size(im)); 
stimulus = im + bruit;

figure, hist(stimulus(:))

% encore plus evident en calculant la proportion qui depasse
(sum(stimulus(:)>1)+sum(stimulus(:)<0))/prod(size(stimulus))
% moins de 0.05 (ou 5%) est considere comme acceptable en vision

% voila!
figure, imshow(stimulus)


% mesurer le signal, le bruit et le ratio signal sur bruit
rms_im = sqrt(mean((im(:)-mean(im(:))).^2))
% ou plus simplement
rms_im = std(im(:))

rms_bruit = std(bruit(:)) % en fait il s'agit de l'ecart-type du bruit, ni plus ni moins

% ratio signal sur bruit (SNR)
SNR = rms_im^2 / rms_bruit^2 % 1 veut dire autant de signal que de bruit; <1 plus de bruit; >1 plus de signal

% le SNR est souvent exprime en decibel :
SNR_dB = 10*log10(SNR) % 0 veut dire autant de signal que de bruit; <0 plus de bruit; >0 plus de signal


% ATTENTION :
% typiquement on initialise (seed) le generateur de nombres aleatoires *une* fois au
% debut de la fonction experimentale
seed = round(sum(100*clock));   % on utilise l'horloge; a moins d'avoir 2 sujets qui commencent l'experience 
% en meme temps a la micro seconde pres, ca fonctionne
rng(seed)
randn(1,5)
randn(1,5)
% mais :
rng(seed)
randn(1,5)
% quand vous ouvrez Matlab le seed par defaut est le meme (0, si vous
% voulez vraiment savoir)...

% ou plus simplement :
rng('shuffle')




% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function [x, y] = fabrique_grille_2d(patchSize)
% [x, y] = fabrique_grille_2d(patchSize)
%
% Frederic Gosselin, 20/01/2003

halfPatchSize = patchSize / 2;
[x, y] = meshgrid(-halfPatchSize:halfPatchSize-1, -halfPatchSize:halfPatchSize-1);
x = x / patchSize * 2 * pi;
y = y / patchSize * 2 * pi;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

[x, y] = fabrique_grille_2d(256);
figure, imshow(x/(2*pi)+.5)
figure, imshow(y/(2*pi)+.5)


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function grille_sin = fabriquer_grille_sin(patchSize, amplitude, frequence, phase, orientation)
% grille_sin = fabriquer_grille_sin(patchSize, amplitude, frequence, phase, orientation)
% 
% Frederic Gosselin, 22/01/2003
[x, y] = fabrique_grille_2d(patchSize);
u = cos(orientation);
v = sin(orientation);
grille_sin = amplitude * (sin(frequence * (u .* x + v .* y) + phase) / 2) + .5;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

imshow(fabriquer_grille_sin(256, 1, 10, 0, pi/3))


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function cercles = fabriquer_cercles_sin(patchSize, amplitude, frequence, phase)
% cercles = fabriquer_cercles_sin(patchSize, amplitude, frequence, phase)
% 
% Frederic Gosselin, 22/01/2003
[x, y] = fabrique_grille_2d(patchSize);
rayon = sqrt(x .^2 + y .^2);
cercles = amplitude * (sin(frequence * rayon + phase) / 2) + .5;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

imshow(fabriquer_cercles_sin(256, 1, 20, 0))


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function soleil = fabriquer_soleil_sin(patchSize, amplitude, frequenceRadiale, phase)
% soleil = fabriquer_soleil_sin(patchSize, amplitude, frequenceRadiale, phase)
% 
% Frederic Gosselin, 29/01/2003
[x, y] = fabrique_grille_2d(patchSize);
xyAngle = atan2(y, x);
soleil = amplitude * (sin(frequenceRadiale * xyAngle + phase) / 2) + .5;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

imshow(fabriquer_soleil_sin(256, 1, 20, 0))


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
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
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

imshow(fabriquer_enveloppe_gauss(256, 3))


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function gabor = fabriquer_gabor(patchSize, amplitude, frequence, phase, orientation, nb_ecart_type)
% gabor = fabriquer_gabor(patchSize, amplitude, frequence, phase, orientation, nb_ecart_type)
% 
% Frederic Gosselin, 4/3/2008

grille_sin = fabriquer_grille_sin(patchSize, amplitude, frequence, phase, orientation);
gaussienne = fabriquer_enveloppe_gauss(patchSize, nb_ecart_type);
gabor = (grille_sin-.5).*gaussienne+.5;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

imshow(fabriquer_gabor(256, 1, 20, 0, pi/5, 3))


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function lucarne = fabriquer_ellipse(patchSize, cutoffA, cutoffB)
% lucarne = fabriquer_ellipse(patchSize, cutoffA, cutoffB)
% 
% Frederic Gosselin, 4/3/2008

[x, y] = fabrique_grille_2d(patchSize);
ellipse = (x.^2 / cutoffA^2 + y.^2 / cutoffB^2);
lucarne = lt(ellipse, 1);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

imshow(fabriquer_ellipse(256, pi, pi/2))


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function wiggle = fabriquer_wiggle_sin(patchSize, amplitude, frequenceRadiale, phaseRadiale, frequenceMin, frequenceMax, phase)
% wiggle = fabriquer_wiggle_sin(patchSize, amplitude, frequenceRadiale, phaseRadiale, frequenceMin, frequenceMax, phase)
% 
% Definitions des arguments :
% patchSize = taille, en pixels, de l'image carrée; amplitude = amplitude (entre 0 et 1) de la variation sinusoïdale
% (est liée au contraste); frequenceRadiale = le nombre de bosses vers l'extérieur sur les cercles; phaseRadiale = fait
% varier la position des bosses sur les cercles; frequenceMin = le nombre minimal de bords de cercles concentriques (nb. 
% de cercles / 2); frequenceMax = le nombre maximal de bords de cercles concentriques; phase = determine la position des 
% cercles concentriques sur le rayon.
%
% P. ex. :
% gauss = fabriquer_enveloppe_gauss(512, 2); 
% wiggle = fabriquer_wiggle_sin(512, 1, 5, 0, 8, 10, 0);
% gauss_wiggle = gauss.*(wiggle-.5) + .5;
% figure, imshow(gauss_wiggle)
% imwrite(uint8(255 * gauss_wiggle), 'wiggle.tif', 'tif')
% 
% Frederic Gosselin, 29/01/2003

[x, y] = fabrique_grille_2d(patchSize);

xyAngle = atan2(y, x);
modulation_freq = (frequenceMax - frequenceMin) * (sin(frequenceRadiale * xyAngle + phaseRadiale) / 2 + .5) + frequenceMin;
rayon = sqrt(x .^2 + y .^2);
wiggle = amplitude * (sin(modulation_freq .* rayon + phase) / 2) + .5;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

imshow(fabriquer_wiggle_sin(256, 1, 5, 0, 7, 10, 0))


% avec de la couleur
im = zeros(256, 256, 3);
im(:,:,2) = fabriquer_grille_sin(256, 1, 10, 0, pi/5);
im(:,:,1) = fabriquer_grille_sin(256, 1, 10, pi, pi/5);
figure, imshow(im)

% Devoir : fabriquer une grille sinusoidale bleue et jaune (a partir de la fonction fabriquer_grille_sin) revelee 
% partiellement par une fenetre gaussienne (a partir de la fonction
% fabriquer_enveloppe_gauss).
