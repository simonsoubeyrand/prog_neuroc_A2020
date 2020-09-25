
% Devoir : le grand_damier varie presentement entre 0 (case noires) et 1 (cases blanches); le faire varier entre p et q (avec p < q).
% % % % % % % % REPONSE DEVOIR % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %% % % % % % % % % % % % % % % %
debut = 0;
fin   = 1;

la_moitie=50;
pas=fin/(la_moitie-1);
 
rampe = repmat(debut:pas:fin, la_moitie, 1); % version facile.

petit_damier = fabriquer_petit_damier_rampe(la_moitie,debut,fin);
figure, imshow(petit_damier)

grand_damier = fabriquer_grand_damier_rampe(la_moitie,4,4);
figure, imshow(grand_damier)

% % % version with for loop (repeter sur les rows % % % 
rampe=zeros(la_moitie,la_moitie);
rampe_inv=zeros(la_moitie,la_moitie);
for row=1:la_moitie
    rampe(row,:)=debut:pas:fin;
    rampe_inv(row,:)=fin:-pas:debut;% fonctionne aussi "de reculons", faites help :
end


% % % autre(s) solution(s) % % % % %
nb_pas=la_moitie;
lin_r=linspace(debut, fin, nb_pas); % help linspace

lin_rampe = repmat(lin_r, la_moitie, 1); % version facile.


figure, subplot(1,2,1),plot(lin_r),axis('square')
subplot(1,2,2),imshow(lin_rampe)

% function petit_damier = fabriquer_petit_damier_rampe(la_moitie)
% % petit_damier = fabriquer_petit_damier(la_moitie)
% % Fabrique un petit damier de 2 par 2 cases.
% % Frederic Gosselin, 16/01/2003
% % Simon Faghel-Soubeyrand, 2020
% 
% rampe = repmat(0:1/(la_moitie-1):1, la_moitie, 1);
% 
% petit_damier = ones(2 * la_moitie, 2 * la_moitie);
% petit_damier(1 : la_moitie, 1 : la_moitie) = rampe;
% petit_damier(la_moitie + 1 : 2 * la_moitie, la_moitie + 1 : 2 * la_moitie) = rampe;
% end
% 
% 
% function grand_damier = fabriquer_grand_damier_rampe(la_moitie, m_rangees, n_colonnes)
% % grand_damier = fabriquer_grand_damier(la_moitie, nb_repetition)
% % Fabrique un damier de 2*m_rangees par 2*n_colonnes cases.
% % Utilise la fonction fabriquer_petit_damier.
% % Frederic Gosselin, 16/01/2003
% % Simon Faghel-Soubeyrand, 2020
% 
% % fabrique petit damier, i.e.le "cycle"
% petit_damier = fabriquer_petit_damier_rampe(la_moitie);
% 
% % repete le petit damier
% grand_damier = zeros(m_rangees * 2 * la_moitie, n_colonnes * 2 * la_moitie);
% for ii = 1:m_rangees
% 	for jj = 1:n_colonnes
% 		grand_damier(((ii - 1) * 2 * la_moitie + 1) : (ii * 2 * la_moitie), ((jj - 1) * 2 * la_moitie + 1) : (jj * 2 * la_moitie)) = petit_damier;
% 	end
% end
% 
% end
%% On veut modifier le "range" (l'etendue) d'une image. Ici le damier.

grand_damier = fabriquer_grand_damier(32, 4, 4);

min(grand_damier(:)) % on se rappelle que (:) "vectorise" une matrice. Donc on passe de 4 x 4 a 1 x 16
max(grand_damier(:))

p = 10; % minimum
q = 100; % maximum
% (q - p) = l'etendue, ou le "range" dans matlab
grand_damier2 = grand_damier * (q - p) + p;

min(grand_damier2(:))
max(grand_damier2(:))

% l'inverse : varie entre p et q et souhaite que varie entre 0 et 1
p = min(grand_damier2(:));
q = max(grand_damier2(:));

% on isole grand_damier and ce qui suit : grand_damier2 = grand_damier * (q - p) + p;
%  grand_damier2 - p = grand_damier * (q - p);
% (grand_damier2 - p) = grand_damier * (q - p);
% (grand_damier2 - p) / (q - p) = grand_damier
% 
grand_damier = (grand_damier2 - p) / (q - p);

min(grand_damier(:))
max(grand_damier(:))

% ou au long :
grand_damier = (grand_damier2 - min(grand_damier2(:))) / (max(grand_damier2(:)) - min(grand_damier2(:)));

min(grand_damier(:))
max(grand_damier(:))

%% % % % EXERCICE pendant le cours : ecrivez une fonction qui "stretch" une image entre 0 et 1 % % % %
%  % % % % 15 minutes % % % % % % 
%%
% mettre une image quelconque dans une matrice "im"
im = imread('dune2020_large.jpg');

size(im)

min(im(:))
max(im(:))

figure, imshow(im) % est en uint8

% U   : unsigned (non-negatifs, aka positifs)
% int : integers (nombres entiers, pas de décimales)
% 8   : 8-bits d'information (de 0 à 255)
% Unsigned Integers of 8 bits. 
% A uint8 data type contains all whole numbers from 0 to 255. 
% As with all unsigned numbers, the values must be non-negative. 
% Uint8's are mostly used in graphics (colors are always non-negative)

% double : float number en 64 bits of information
% single : float aussi, en 32 bits of information

% im est une matrice de 450 x 1050 x 3: pourquoi "x 3" ? RGB (la couleur).
% ecran : 256 niveau gris.

% de uint8 a double
im_double = double(im)/255;

min(im_double(:))
max(im_double(:))

figure, imshow(im_double)

% meme chose pour single
im_single = single(im)/255;

min(im_single(:))
max(im_single(:))

figure, imshow(im_single)


% de double a uint8
im_uint8 = uint8(255*im_double);

min(im_uint8(:))
max(im_uint8(:))

figure, imshow(im_uint8)

% en resume, on utilise uint8 puisque c'est la resolution necessaire pour
% presenter les images en general. Plus de precision serait inutile.

% de double a uint8, sans la transformation du range (*255)
im_uint8 = uint8(im_double);

min(im_uint8(:))
max(im_uint8(:))

figure, imshow(im_uint8)

% transformer les images 
im_double2 = im_double.^2;
im_double3 = im_double.^0.5;
im_double4 = 1-im_double;
im_double5 = sin(im_double*pi);
im_double6 = cos(im_double*pi); % ressemble etrangement a im_double4

figure, imshow(im_double2)
figure, imshow(im_double3)
figure, imshow(im_double4)

subplot(3,1,1),imshow(im_double),title('im orig')
subplot(3,1,2),imshow(im_double5),title('sin(im orig)')
subplot(3,1,3),imshow(im_double6)

x = 0:.01:1;
y2 = x.^2;
y3 = x.^0.5;
y4 = 1-x;
y5 = sin(x*pi);

figure, plot(x, y2, x, y3, x, y4, x, y5) % on peut "plot" plusieurs fonctions sur une meme ligne.


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

% "DEVOIR" 3 pour le prochain cours : votre oral, + installation python. Je
% vous donne les instructions cette fds.
%% PAUSE OU PROCHAIN COURS 

% % % % % % % % % changer le contraste d'une image en double % % % % % %  %
% % % % % % %
michelson_contrast=(max(im_double(:))-min(im_double(:)))/(max(im_double(:))+min(im_double(:)));
etendue = .1; % ~ contraste
tim_double = etendue * (im_double - .5) + .5;
michelson_contrast=(max(tim_double(:))-min(tim_double(:)))/(max(tim_double(:))+min(tim_double(:)));
figure, imshow(tim_double)

% mesurer le contraste d'une image
rms_contrast = std(tim_double(:)); % root mean square contrast

rms_contrast = .1;
tim_double = rms_contrast * (im_double - mean(im_double(:))) / std(im_double(:)) + mean(im_double(:));
figure, imshow(tim_double)
michelson_contrast=(max(tim_double(:))-min(tim_double(:)))/(max(tim_double(:))+min(tim_double(:)));

% mesurer le contraste d'une image
rms_contrast = std(tim_double(:)) % root mean square contrast

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




%% % % % % % % % %

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



% Devoir : ajouter une quantit� variable de bruit rectangulaire (rand) ou Gaussien (randn) � une image

% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
function etiree = stretch(im)
% Fred Gosselin, 05/02/03

im = double(im);
etiree = (im - min(im(:))) / (max(im(:)) - min(im(:)));
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % 
end


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
end


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
% Proceedings of the Society of Information Display 17, 75�77 (1976).

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

end
