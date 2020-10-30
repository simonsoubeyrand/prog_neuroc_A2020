
% Comme avec Floris... mais en Matlab :
Fe = 44100;     % frequence d'echantillonnage temporelle; 8000, 11025, 22050, 44100, 48000, 96000
duree = 2;      % duree en s
freq = 1000;    % frequence en Hz
etendue = (0:duree*Fe-1) / (Fe-1);
min(etendue)
max(etendue)
un_son = sin(2 * pi * freq * etendue); % son composee d'un sinus a une frequence de 'freq' Hz d'une duree de 'duree'; un_son doit varier entre -1 et 1
sound(un_son, Fe); % joue le son

duree_rampe = 0.2; % duree en s
rampe = (0:round(duree_rampe*Fe))/round(duree_rampe*Fe); % la rampe
masque = ones(size(un_son));        % initialise le masque avec des 1
masque(1:length(rampe)) = rampe;    % remplace le debut par la rampe 
masque(end-length(rampe)+1:end) = fliplr(rampe); % remplace la fin par l'image miroir de la rampe
figure, plot(masque)
stimulus = masque .* un_son;      % un_son masque
sound(stimulus, Fe); % joue le son masque

% exercise : essayez de faire un masque sinusoidal (exercise)
freq_masque = 3;    % en Hz
masque_sin = sin(2 * pi * freq_masque * etendue); % son composee d'un sinus a une frequence de 'freq' Hz d'une duree de 'duree'; un_son doit varier entre -1 et 1
figure, plot(masque_sin)
masque_sin = masque_sin/2+.5;
figure, plot(masque_sin)
stimulus = masque_sin .* un_son;      % un_son masque
sound(stimulus, Fe); % joue le son masque

% en ajoutant le masque de tout a l'heure
stimulus = masque .* masque_sin .* un_son;      % un_son masque
sound(stimulus, Fe); % joue le son masque

% ou encore mieux...
ecart_type = 0.35; % en s
masque_gauss = exp(-0.5 * ((etendue - (duree/2)) / ecart_type).^2);
figure, plot(masque_gauss)
stimulus = masque_gauss .* masque_sin .* un_son; % un_son masque
figure, plot(masque_gauss .* masque_sin)
sound(stimulus, Fe); % joue le son masque

% Semblable mais en vision...
% grille sinusoidale : quels sont les proprietes d'une grille sinusoidale?
% comment faire uen grille sinusoidale?
x_taille = 512;
y_taille = 512;
x = repmat(0:x_taille-1, y_taille, 1); % ou une boucle...
min(x(:))
max(x(:))
x = x/(x_taille-1);
min(x(:))
max(x(:))
figure, imshow(x)
freq_spa = 5; % cycles par largeur image
grille = sin(freq_spa .* x * 2 * pi); % une grille verticale
figure, imshow(grille)
% pas tr�s beau... Pourquoi?
grille = grille/2+.5;
figure, imshow(grille)

% exercise : changer le contraste


% et l'orientation?
y = repmat([0:y_taille-1]', 1, x_taille); % horizontale
%y = y / (y_taille - 1); % NON! implique cycle par hauteur d'image; on veut par largeur d'image
y = y / (x_taille - 1);
grille = amplitude*(sin(freq_spa .* y * 2 * pi + phase)/2)+.5;
figure, imshow(0.5 * (grille-.5)+.5)

% et entre ces deux orientations cardinale?
% c'est un peu plus complique...
% je vais vous donner la solution et vous y penserez chez vous si ca vous
% tente.
% Notez d'abord que :
[x, y] = meshgrid(0:(x_taille-1), 0:(y_taille-1)); % fait les 2 repmat
x = x / (x_taille-1);
y = y / (x_taille-1); % cycle par largeur d'image!

x_taille = 512;
y_taille = 512;
freq_spa = 5;           % en cycle par image
orientation = pi/4;     % en rad
phase = 0;              % en rad
amplitude = .5;
[x, y] = meshgrid(0:1/(x_taille-1):1, 0:1/(y_taille-1):1);
x = x-0.5;              % simplifie les calculs pour la suite...
y = y-0.5 * y_taille/x_taille;
u = cos(orientation);
v = sin(orientation);
xy = u .* x + v .* y;
figure, imshow(stretch(xy));

grille_sin = amplitude * (sin(freq_spa * xy * 2 * pi + phase) / 2) + .5;
figure, imshow(grille_sin)

% exercise : faire une fonction qui fait des grilles sinusoidale



% ajouter un masque circulaire
[x, y] = meshgrid(0:(x_taille-1), 0:(y_taille-1));
x = x / (x_taille-1);
y = y / (x_taille-1); % cycle par largeur d'image!
x = x-0.5;
y = y - 0.5 * y_taille/x_taille;
dist_centre = sqrt(x.^2 + y.^2);
%figure, imshow(dist_centre/max(dist_centre(:)))

rayon = .4;
masque = dist_centre < rayon;

figure, imshow(masque)

stimulus = masque .* grille_sin;
figure, imshow(stimulus)

stimulus = masque .* (grille_sin-.5) + .5;
figure, imshow(stimulus)

% encore mieux :

ecart_type = 0.25;
masque_gauss = exp(-(x .^2 / ecart_type ^2) - (y .^2 / ecart_type ^2));
gabor = masque_gauss .* (grille_sin-0.5) + 0.5; % le stimulus le plus utilise en vision
figure, imshow(gabor)



% exercise : ecrivez une fonction pour les deux masques; et pour la tache de Gabor



% D'autres exemples de stimuli periodiques :

function cercles_sin = fabriquer_cercles_sin(x_taille, y_taille, amplitude, frequence, phase)
% cercles_sin = fabriquer_cercles_sin(x_taille, y_taille, amplitude, frequence, phase)
% 
% Frederic Gosselin, 10/2020

[x, y] = meshgrid(0:(x_taille-1), 0:(y_taille-1));
x = x / (x_taille-1);
y = y / (x_taille-1); % cycle par largeur d'image!
x = x-0.5;
y = y - 0.5 * y_taille/x_taille;
dist_centre = sqrt(x .^2 + y .^2);
cercles_sin = amplitude * (sin(frequence * dist_centre * 2 * pi + phase) / 2) + .5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure, imshow(fabriquer_cercles_sin(512, 512, 1, 20, 0))


function soleil = fabriquer_soleil_sin(x_taille, y_taille, amplitude, frequenceRadiale, phase)
% soleil = fabriquer_soleil_sin(x_taille, y_taille, amplitude, frequenceRadiale, phase)
% 
% Frederic Gosselin, 10/2020
[x, y] = meshgrid(0:(x_taille-1), 0:(y_taille-1));
x = x / (x_taille-1);
y = y / (x_taille-1); % cycle par largeur d'image!
x = x-0.5;
y = y - 0.5 * y_taille/x_taille;
xyAngle = atan2(y, x);
soleil = amplitude * (sin(frequenceRadiale * xyAngle * 2 * pi + phase) / 2) + .5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure, imshow(fabriquer_soleil_sin(512, 512, 1, 20, 0))


function wiggle = fabriquer_wiggle_sin(x_taille, y_taille, amplitude, frequenceRadiale, phaseRadiale, frequenceMin, frequenceMax, phase)
% wiggle = fabriquer_wiggle_sin(x_taille, y_taille, amplitude, frequenceRadiale, phaseRadiale, frequenceMin, frequenceMax, phase)
% 
% Frederic Gosselin, 10/2020
[x, y] = meshgrid(0:(x_taille-1), 0:(y_taille-1));
x = x / (x_taille-1);
y = y / (x_taille-1); % cycle par largeur d'image!
x = x-0.5;
y = y - 0.5 * y_taille/x_taille;
xyAngle = atan2(y, x);
modulation_freq = (frequenceMax - frequenceMin) * (sin(frequenceRadiale * xyAngle + phaseRadiale) / 2 + .5) + frequenceMin;
rayon = sqrt(x .^2 + y .^2);
wiggle = amplitude * (sin(modulation_freq .* rayon * 2 * pi + phase) / 2) + .5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure, imshow(fabriquer_wiggle_sin(512, 512, 1, 5, 0, 7, 10, 0))


% avec de la couleur
im = zeros(512, 512, 3);
im(:,:,2) = fabriquer_grille_sin(512, 512, 0.7, 5, 0, pi/4);
im(:,:,1) = fabriquer_grille_sin(512, 512, 0.7, 5, pi, pi/4);
figure, imshow(im)
end
% Devoir : fabriquer une grille sinusoidale bleue et jaune (a partir de la fonction fabriquer_grille_sin) revelee 
% partiellement par une fenetre gaussienne (a partir de la fonction fabriquer_enveloppe_gauss).





