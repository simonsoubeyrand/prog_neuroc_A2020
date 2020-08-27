
% Devoir : le grand_damier varie présentement entre 0 (case noires) et 1 (cases blanches); le faire varier entre p et q (avec p < q).

grand_damier = fabriquer_grand_damier(256/8, 4, 3);

min(grand_damier(:))
max(grand_damier(:))

p = 10;
q = 100;
grand_damier2 = grand_damier * (q - p) + p;

min(grand_damier2(:))
max(grand_damier2(:))

% l'inverse : varie entre p et q et souhaite que varie entre 0 et 1
p = min(grand_damier2(:));
q = max(grand_damier2(:));
% on isole grand_damier and ce qui suit : grand_damier2 = grand_damier * (q - p) + p;
grand_damier = (grand_damier2 - p) / (q - p);

min(grand_damier(:))
max(grand_damier(:))

% ou au long :
grand_damier = (grand_damier2 - min(grand_damier2(:))) / (max(grand_damier2(:)) - min(grand_damier2(:)));

min(grand_damier(:))
max(grand_damier(:))

% exercise : ecrivez une fonction qui "stretch" une image entre 0 et 1 



% mettre une image quelconque dans une matrice
im = imread('w1N.JPG');

size(im)

min(im(:))
max(im(:))

figure, imshow(im)

% de uint8 a double
im_double = double(im)/255;

min(im_double(:))
max(im_double(:))

figure, imshow(im)

% de double a uint8
im_uint8 = uint8(255*im_double);

min(im_uint8(:))
max(im_uint8(:))

figure, imshow(im_uint8)

% transformer les images 
im_double2 = im_double.^2;
im_double3 = im_double.^0.5;
im_double4 = 1-im_double;
im_double5 = sin(im_double*pi);

figure, imshow(im_double2)
figure, imshow(im_double3)
figure, imshow(im_double4)
figure, imshow(im_double5)

x = 0:.01:1;
y2 = x.^2;
y3 = x.^0.5;
y4 = 1-x;
y5 = sin(x*pi);

figure, plot(x, y2, x, y3, x, y4, x, y5)


% uint8 vs. double entre 0 et 1...
% rampe de luminance
rampe = repmat(0:1/(2000-1):1, 2000, 1);
figure, imshow(rampe)
imwrite(rampe, 'rampe.tif', 'tif')
rampe2 = imread('rampe.tif');
figure, imshow(rampe2)
numel(unique(rampe(:)))
numel(unique(rampe2(:)))
figure, plot(1:100, 255*rampe(1,1:100), 'k', 1:100, rampe2(1,1:100), 'r')
xlabel('L''axe des x sur l''image (pixel)')
ylabel('Niveau de gris (entre 0 et 255)')
legend('double','uint8')



% changer le contraste d'une image en double
etendue = .1; % ~ contraste
tim_double = etendue * (im_double - .5) + .5;
figure, imshow(tim_double)

% mesurer le contraste d'une image
rms_contrast = std(tim_double(:)) % root mean square contrast

rms_contrast = .1;
tim_double = rms_contrast * (im_double - mean(im_double(:))) / std(im_double(:)) + mean(im_double(:));
figure, imshow(tim_double)

% mesurer le contraste d'une image
rms_contrast = std(tim_double(:)) % root mean square contrast






% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
function etiree = stretch(im)
% Fred Gosselin, 05/02/03

im = double(im);
etiree = (im - min(im(:))) / (max(im(:)) - min(im(:)));
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 


% Devoir : Ecrire une fonction avec comme input : une image "im" et un
% ecart-type "ecart_type"; et comme output : une image "tim" dont
% l'ecart-type est "ecart_type" (la commande "std(tim(:))" donne 
% l'ecart-type de "tim") et la moyenne est 0.5 (la commande "mean(tim(:)) 
% donne l'ecart-type de "tim").


min(tim_double(:))
max(tim_double(:))
tim_double2 = stretch(tim_double);
min(tim_double2(:))
max(tim_double2(:))

im = stretch(im_uint8);
min(im(:))
max(im(:))

figure, imshow(stretch(im_double .^0.3))
figure, imshow(stretch(im_double .^2))

% une importante difference entre les images en double et en uint8
unique([1 2 2 3 3 3 4 4 4 4])   % la fonction unique

numel(unique(im_double))
numel(unique(tim_double))
numel(unique(im_uint8))
numel(unique(tim_uint8))

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
figure, imshow(conv2(im, h))


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
% Proceedings of the Society of Information Display 17, 75Ğ77 (1976).

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





% Devoir : ajouter une quantité variable de bruit rectangulaire (rand) ou Gaussien (randn) à une image

