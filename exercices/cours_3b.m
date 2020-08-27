
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

% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
function etiree = stretch(im)
% Fred Gosselin, 05/02/03

im = double(im);
etiree = (im - min(im(:))) / (max(im(:)) - min(im(:)));
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 




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



% changer l'etendue d'une image en double
etendue = .1; % ~ contraste
tim_double = etendue * (im_double - .5) + .5;
figure, imshow(tim_double)


% Devoir : Ecrire une fonction avec comme input : une image "im" et un
% ecart-type "ecart_type"; et comme output : une image "tim" dont
% l'ecart-type est "ecart_type" (la commande "std(tim(:))" donne 
% l'ecart-type de "tim") et la moyenne est 0.5 (la commande "mean(tim(:)) 
% donne l'ecart-type de "tim").

