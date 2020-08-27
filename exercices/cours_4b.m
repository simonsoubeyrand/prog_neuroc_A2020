
% Devoir : Ecrire une fonction avec comme input : une image "im" et un
% ecart-type "ecart_type"; et comme output : une image "tim" dont
% l'ecart-type est "ecart_type" (la commande "std(tim(:))" donne 
% l'ecart-type de "tim") et la moyenne est 0.5 (la commande "mean(tim(:)) 
% donne la moyenne de "tim").

im_uint8 = imread('w1N.JPG');
im_double = double(im_uint8)/255;

% mesurer le contraste d'une image
rms_contrast = std(im_double(:)) % root mean square contrast

% changer le contraste d'une image en double
rms_contrast = .01;
tim_double = rms_contrast * (im_double - mean(im_double(:))) / std(im_double(:)) + 0.5;
figure, imshow(tim_double)

% mesurer le contraste d'une image
rms_contrast = std(tim_double(:)) % root mean square contrast


% une importante difference entre les images en double et en uint8
unique([1 2 2 3 3 3 4 4 4 4])   % la fonction unique
numel(unique([1 2 2 3 3 3 4 4 4 4]))

numel(unique(im_double(:)))
numel(unique(im_uint8(:)))

numel(unique(tim_double))
tim_uint8 = uint8(255*tim_double);
numel(unique(tim_uint8))

figure, imshow(stretch(tim_uint8))

% en definitive, nous ne disposons que de 256 niveaux de gris pour montrer 
% les images; une facheuse consequence...
n = 2;
im_n = stretch(round(im_double*(n-1)));
numel(unique(im_n(:)))   % test
figure, imshow(im_n)    % image denaturee


% the Allard & Faubert method
allard = allard_faubert(im_double, n);
figure, imshow(stretch(allard))
numel(unique(allard))


% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
function tim = allard_faubert(im, depth)
% im must vary between 0 and 1 and depth is the number of gray shades
%
% im = double(imread('w1N.JPG'))/255;
% figure, imshow(stretch(allard_faubert(im, 2)))
%
% Allard, R., Faubert, J. (2008) The noisy-bit method for digital displays:
% converting a 256 luminance resolution into a continuous resolution. Behavior 
% Research Method, 40(3), 735-743.

tim = im*(depth-1);
tim = max(min(round(tim+rand(size(im))-.5), depth-1), 0) + 1;
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 

% pourquoi ca fonctionne jusqu'a un certain point?
sigma = 3;
TNoyau = 2*sigma+1;
h = fspecial('gaussian',ceil(TNoyau),sigma);
figure, imshow(stretch(h))
figure, imshow(stretch(conv2(allard, h)))
figure, imshow(conv2(im_double, h))


% error diffusion -- The Floyd & Steinberg method
floyd = floyd_steinberg(im_double, n);
figure, imshow(stretch(floyd))
numel(unique(floyd))
%figure, imshow(stretch(conv2(floyd, h)))



% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
function tim = floyd_steinberg(im, depth)
% im must vary between 0 and 1 and depth is the number of gray shades
%
% im = fabriquer_grille_sin(256, 1, 1, 0, 0);
% im = double(imread('w1N.JPG'))/255;
% figure, imshow(stretch(floyd_steinberg(im, 2)))
% 
% R.W. Floyd, L. Steinberg, An adaptive algorithm for spatial grey scale. 
% Proceedings of the Society of Information Display 17, 75–77 (1976).

%tim = max(min(im*(depth-1), depth-1), 0);
tim = im*(depth-1);
for yy = 2:size(im,1)-1,
    for xx = 2:size(im,2)-1,
        oldpixel = tim(yy,xx);
        newpixel = round(tim(yy,xx));
        im(xx,yy) = double(newpixel);
        quant_error = oldpixel - newpixel;
        tim(yy,xx+1) = tim(yy,xx+1) + 7/16 * quant_error;
        tim(yy+1,xx-1) = tim(yy+1,xx-1) + 3/16 * quant_error;
        tim(yy+1,xx) = tim(yy+1,xx) + 5/16 * quant_error;
        tim(yy+1,xx+1) = tim(yy+1,xx+1) + 1/16 * quant_error;
    end
end
tim = round(tim);
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 



% Une ensemble de fonctions pour creer des stimuli en Matlab

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

figure, imshow(fabriquer_grille_sin(256, 1, 10, 0, pi/3))


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

figure, imshow(fabriquer_cercles_sin(256, 1, 20, 0))


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

figure, imshow(fabriquer_soleil_sin(256, 1, 20, 0))


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

figure, imshow(fabriquer_enveloppe_gauss(256, 3))


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

figure, imshow(fabriquer_gabor(256, 1, 20, 0, pi/5, 3))


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

figure, imshow(fabriquer_ellipse(256, pi, pi/2))


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


figure, imshow(fabriquer_wiggle_sin(256, 1, 5, 0, 7, 10, 0))


% avec de la couleur
im = zeros(256, 256, 3);
im(:,:,2) = fabriquer_grille_sin(256, 1, 10, 0, pi/5);
im(:,:,1) = fabriquer_grille_sin(256, 1, 10, pi, pi/5);
figure, imshow(im)

% Devoir : fabriquer une grille sinusoidale bleue et jaune (a partir de la fonction fabriquer_grille_sin) revelee 
% partiellement par une fenetre gaussienne (a partir de la fonction fabriquer_enveloppe_gauss).









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Egaliser certains parametres des images : la librairie SHINE
% http://mapageweb.umontreal.ca/gosselif/SHINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ims{1} = imread('w1N.JPG');    % fonctionne avec images en uint8
ims{2} = imread('m1H.JPG');

figure, imshow(ims{1})
figure, imshow(ims{2})

im = double(ims{1});
im2 = double(ims{2});
mean(im(:))
std(im(:)) % rms contrast
mean(im2(:))
std(im2(:)) % rms contrast

figure, imhist(ims{1})
figure, imhist(ims{2})


% mean and luminance match; from the SHINE toolbox
tims = lumMatch(ims,[], [128 60]);   
tim = double(tims{1});
tim2 = double(tims{2});

figure, imshow(tims{1})
figure, imshow(tims{2})

mean(tim(:))
std(tim(:)) % rms contrast
mean(tim2(:))
std(tim2(:)) % rms contrast
figure, imhist(tims{1})
figure, imhist(tims{2})

% histogram match; from the SHINE toolbox
tims2 = histMatch(ims);  
tim = double(tims2{1});
tim2 = double(tims2{2});

figure, imshow(tims2{1})
figure, imshow(tims2{2})

mean(tim(:))
std(tim(:)) % rms contrast
mean(tim2(:))
std(tim2(:)) % rms contrast

figure, imhist(tims{1})
figure, imhist(tims{2})
figure, imhist(tims2{1})
figure, imhist(tims2{2})


% spatial frequency match; from the SHINE toolbox
figure, imshow(ims{1})
figure, imshow(ims{2})
spectrumPlot(ims{1}, 1);
spectrumPlot(ims{2}, 1);

tims3 = specMatch(ims, 1);
figure, imshow(tims3{1})
figure, imshow(tims3{2})
spectrumPlot(tims3{1}, 1);
spectrumPlot(tims3{2}, 1);

figure, imhist(tims3{1})
figure, imhist(tims3{2})


