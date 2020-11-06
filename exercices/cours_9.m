auteur{4}='- Ghandi';auteur{1}='- Trump'; auteur{2}='- Trump'; auteur{3}='- Biden';
% % % % % % % % Psychtoolbox % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% screen : http://psychtoolbox.org/
% en tapant 'Screen' on obtient (most useful only listed underneath) :

AssertOpenGL

% Usage:
% 
% % Get (and set) information about a window or screen:
% screenNumbers=Screen('Screens' [, physicalDisplays]);

screens=Screen('Screens');
screenNumber=max(screens); % va toujours chercher l'�cran secondaire
%%
% PTB (Screen...) va chercher des info utile de votre ecran/carte
% graphique/etc. (du "hardwarre"). tres utile pour des experience qui se
% replique
[width_in_mm, height_in_mm]=Screen('DisplaySize', screenNumber);
resolutions = Screen('Resolutions', screenNumber);
pixel_in_mm = width_in_mm/resolutions.width;

hz=Screen('FrameRate', screenNumber);

% % Open or close a window or texture:
% [windowPtr,rect]=Screen('OpenWindow',windowPtrOrScreenNumber [,color] [,rect] [,pixelSize] [,numberOfBuffers] [,stereomode] [,multisample][,imagingmode]);

% possible que vous soyez oblige d'ajouter la ligne suivante:
Screen('Preference', 'SkipSyncTests', 1);    % put 1 if the sync test fails

[windowPtr,rect]=Screen('OpenWindow', screenNumber);

% Screen('CloseAll');
sca

[windowPtr,rect]=Screen('OpenWindow',screenNumber, [0 255 0]); % ouvre l'écran. Mettre la couleur en Red Green Blue [RGB]
WaitSecs(3) % on attend 3 secondes
sca         % on ferme la "screen window"


%%
%  Draw lines and solids like QuickDraw and DirectX (OS 9 and Windows):
% Screen('DrawLine', windowPtr [,color], fromH, fromV, toH, toV [,penWidth]);
% Screen('DrawArc',windowPtr,[color],[rect],startAngle,arcAngle)
% Screen('FrameArc',windowPtr,[color],[rect],startAngle,arcAngle[,penWidth] [,penHeight] [,penMode])
% Screen('FillArc',windowPtr,[color],[rect],startAngle,arcAngle)
% Screen('FillRect', windowPtr [,color] [,rect] );
% Screen('FrameRect', windowPtr [,color] [,rect] [,penWidth]);
% Screen('FillOval', windowPtr [,color] [,rect]);
% Screen('FrameOval', windowPtr [,color] [,rect] [,penWidth] [,penHeight] [,penMode]);
% Screen('FramePoly', windowPtr [,color], pointList [,penWidth]);
% Screen('FillPoly', windowPtr [,color], pointList);

% EXPLIQUER LES COORDONEES DE LECRAN : commence a x=0 et y=0 en haut, a
% gauche completement
[windowPtr,rect]=Screen('OpenWindow',screenNumber, [0 255 0]); % ouvre l'écran 
Screen('DrawLine', windowPtr, [255 0 0], 300, 300, 400, 400, 5);

% Rien? Parce que dessine sur le tampon, pas sur l'ecran directement. Il
% faut ensuite "flip" le tampon sur l'ecran:

% % Synchronize with the window's screen (on-screen only):
% [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = Screen('Flip', windowPtr [, when] [, dontclear] [, dontsync] [, multiflip]);

Screen('Flip', windowPtr);


% Fabrique un Mondrian avec des couleurs et formes aleatoires
Screen('Preference', 'SkipSyncTests', 1);

color_choices=parula; % jet, parula, hot, cool, winter

% on va chercher l'ecran secondaire
screens=Screen('Screens');
screenNumber=max(screens);

% on ouvre l'ecran
[windowPtr,rect]=Screen('OpenWindow',screenNumber);
resolutions = Screen('Resolutions', screenNumber);
xx = resolutions.width;
yy = resolutions.height;
for ii = 1:100
    
    colors=uint8(255*color_choices(randperm(64,1),:));
    ax = round(xx * rand);
    bx = round(xx * rand);
    ay = round(yy * rand);
    by = round(yy * rand);
    Screen('FillRect', windowPtr, colors, [min(ax, bx), min(ay, by), max(ax, bx), max(ay, by)])
%     ax = round(xx * rand);
%     bx = round(xx * rand);
%     ay = round(yy * rand);
%     by = round(yy * rand);
%     Screen('FillOval', windowPtr, colors , [min(ax, bx), min(ay, by), max(ax, bx), max(ay, by)])
end
Screen('Flip', windowPtr);
WaitSecs(3);
sca;

%% Draw text one window

% oldTextSize=Screen('TextSize', windowPtr [,textSize]);
% [oldFontName,oldFontNumber]=Screen(windowPtr,'TextFont' [,fontNameOrNumber]);
% [newX,newY]=Screen('DrawText', windowPtr, text [,x] [,y] [,color] [,backgroundColor] [,yPositionIsBaseline]);
% oldTextColor=Screen('TextColor', windowPtr [,colorVector]);

which_quote=1; % choisissons la premiere "quote"

quote{1}='"I have a great relationship with the blacks"';
quote{2}='"The beauty of me is that I''m very rich"';
quote{3}='"Poor kids are just as bright and just as talented as white kids"';


[windowPtr,rect]=Screen('OpenWindow',screenNumber); 
Screen(windowPtr,'TextFont', 'Comic-Sans'); % on veut changer la police du texte? 
% Screen('TextSize', windowPtr, 100); % on veut changer la taille du texte? 
Screen('DrawText', windowPtr, auteur{which_quote}, 200, 300); % on veut rajouter du texte a une position specifique? 
Screen('TextSize', windowPtr, 30);
% Screen('TextColor', windowPtr, [100 0 150]) % on veut modifier la couleur? 
Screen('DrawText', windowPtr, quote{1}, 200, 200); % position is "x", "y" (in pixel position from left upper corner).
Screen('Flip', windowPtr);

% % Open or close a window or texture, suite
% textureIndex=Screen('MakeTexture', WindowIndex, imageMatrix [, optimizeForDrawAngle=0] [, specialFlags=0] [, floatprecision=0] [, textureOrientation=0] [, textureShader=0]);
 
%% Damier changeant de polarite a tous les "period" s 
period = 0.5; % s

% on met lecran en gris.
[windowPtr,rect]=Screen('OpenWindow',screenNumber, [128 128 128]);

% on prend le monitor flip interval (correspond au 1/60)
[monitorFlipInterval nrValidSamples stddev] = Screen('GetFlipInterval', windowPtr);

% on 
im1 = uint8(255*fabriquer_grand_damier(16, 8,10));
im2 = uint8(255*(1-fabriquer_grand_damier(16, 8,10)));

texturePtr(1) = Screen('MakeTexture', windowPtr, im1);
texturePtr(2) = Screen('MakeTexture', windowPtr, im2);

% on veut montrer l'image un temps specifique
endtime=5;
start = GetSecs;
while GetSecs<(start+endtime)
    Screen('DrawTexture', windowPtr, texturePtr(1));
    Screen('Flip', windowPtr);
    WaitSecs(period-monitorFlipInterval/2); % qu'est ce que "monitorFlipInterval"?
    Screen('DrawTexture', windowPtr, texturePtr(2));
    Screen('Flip', windowPtr);
    WaitSecs(period-monitorFlipInterval/2);
end
sca


%% meme idee, mais avec un "wiggle", et avec un changement de phase et de couleur ET, qui arrete avec un CLICK de souris

period = 0.5; % s
[windowPtr,rect]=Screen('OpenWindow',screenNumber, [128 128 128]);
[monitorFlipInterval nrValidSamples stddev] = Screen('GetFlipInterval', windowPtr);
clear im1 im2
% on cree un wiggle en black and white. taille_x, tailley, amp,
% freq1,phase1,
im1=uint8(255*fabriquer_wiggle_sin(256, 256, 1, 2, pi, 1, 10, 0));
% 
im2(:,:,1)=uint8(255*fabriquer_wiggle_sin(256, 256, 1, 2, 0, 1, 10, 0))*.5;
im2(:,:,2)=uint8(255*fabriquer_wiggle_sin(256, 256, 1, 2, 0, 1, 10, 0))*.3;
im2(:,:,3)=uint8(255*fabriquer_wiggle_sin(256, 256, 1, 2, 0, 1, 10, 0))*.8;

texturePtr(1) = Screen('MakeTexture', windowPtr, im1);
texturePtr(2) = Screen('MakeTexture', windowPtr, im2);
buttons = 0;
while (buttons)==0
    [xCoor, yCoor, buttons] = GetMouse(windowPtr);
    Screen('DrawTexture', windowPtr, texturePtr(1));
    Screen('Flip', windowPtr);
    WaitSecs(period-monitorFlipInterval/2);
    Screen('DrawTexture', windowPtr, texturePtr(2));
    Screen('Flip', windowPtr);
    WaitSecs(period-monitorFlipInterval/2);
end
sca

%%
% Pas optimale parce que ne tient pas compte des capacites de votre
% ordinateur (dans l'exemple 1/10 des retracage a 60 Hz sont utilises). 
% Pourrait meme ne pas fonctionner si la vitesse est trop grande (e.g. speed = 24).

% Meilleure facon de faire : on utilise ici un exemple avec des gabor
% patchs (des grilles sinusoidales filtre par une envelope gaussienne)
speed = 2;  % en cycles par seconde 
xySize = 512;
freq = 10;
orient = pi/4;
screens=Screen('Screens');
screenNumber=max(screens); % va toujours chercher l'�cran secondaire
[windowPtr,rect]=Screen('OpenWindow',screenNumber, [127 127 127]);
[monitorFlipInterval nrValidSamples stddev] = Screen('GetFlipInterval', windowPtr);
nb_frames_cycle = 1/(speed*monitorFlipInterval);

for frame = 1:nb_frames_cycle
    phase = (frame-1)/(nb_frames_cycle)*2*pi;
    texturePtr(frame) = Screen('MakeTexture', windowPtr, 255*fabriquer_gabor(xySize, 1, freq, phase, orient, 3));
end


keyCode=0;   
buttons=0;
while (buttons)==0
    [xCoor, yCoor, buttons] = GetMouse(windowPtr);
    for frame = 1:nb_frames_cycle
        Screen('DrawTexture', windowPtr, texturePtr(frame));
        Screen('Flip', windowPtr);
    end
end
sca


%%%%%%% LAISSER UN 10 MINUTES POUR COMMENCER LA FONCTION AVEC CE QUON VIENT
%%%%%%% DE VOIR : 
%                   Initialiser lecran, definir parametre, faire texture, presenter texture et flip.

%% mouse and keyboard demo.

% Mouse demo 1: set the mouse at specific coordinates, or get mouse
% coordinates

% set the mouse at specific x y coordinates

SetMouse(1000, 200)

% get mouse x y coordinates
[xCoor, yCoor, buttons] = GetMouse


%% Mouse, demo 2 : update les coordonee de la souris pendant qu'on la bouge , ne pas arreter tant qu'on ne click pas
old_xCoor = 0;
old_yCoor = 0;
buttons = 0;
start = GetSecs;
while sum(buttons)==0
    [xCoor, yCoor, buttons] = GetMouse;
    if (old_xCoor ~= xCoor) || (old_yCoor ~= yCoor)
        old_xCoor = xCoor
        old_yCoor = yCoor
    end
end

% we started at "start" seconds, now we're at "GetSecs" time. difference
% donne le temps de reponse.
RT = GetSecs-start


%% mouse demo 3 : show a gray screen, with updated mouse coordinates, get RT at mouse click, then close the screen.

AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens); % va toujours chercher l'ecran secondaire
[windowPtr,rect]=Screen('OpenWindow',screenNumber, [127 127 127]); % ecran gris

old_xCoor = 0;% commence a zero
old_yCoor = 0;
buttons = 0;


start = GetSecs;
while sum(buttons)==0
    [xCoor, yCoor, buttons] = GetMouse;
    if (old_xCoor ~= xCoor) || (old_yCoor ~= yCoor)
        old_xCoor = xCoor;
        old_yCoor = yCoor;
    end
    
    string_coord{1}=num2str(xCoor);
    string_coord{2}=num2str(yCoor);
    
    string=sprintf(' x coor at : %s, y coord at : %s',string_coord{1},string_coord{2})
    Screen('DrawText', windowPtr, string, (rect(3)/2)-200,rect(4)/2); % position is "x", "y" (in pixel position from left upper corner).
    Screen('Flip', windowPtr);
    
end
sca;
RT = GetSecs-start

%% mouse demo 4 : On present une image, et on la bouge de gauche a droite avec les coordonee de la souris

% initialise lecran
Screen('Preference', 'SkipSyncTests', 1);
AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);

[windowPtr,rect]=Screen('OpenWindow',screenNumber, 128);

HideCursor; % on cache lecran
SetMouse(round(rect(3)/2), round(rect(4)/2));% on place la souris au centre pour commencer

% on lit l'image avec imread, on trouve la taille et on la met pour ce
% qu'on veut (ici on la divise par 2)
im = imread('dune2020_large.jpg');
[ySize xSize col] = size(im);
xSize=xSize/2;
ySize=ySize/2;
im=imresize(im,[xSize ySize]);
imRect = [0 0 xSize ySize];
resolutions = Screen('Resolutions', screenNumber);
xx=resolutions.width;
yy=resolutions.height;

% on cree la texture avec limage
texturePtr = Screen('MakeTexture', windowPtr, im);

% on definit les coordonnee du centre
centerCoor = [round(xx/2 - xSize/2) round(yy/2 - ySize/2) round(xx/2 - xSize/2) round(yy/2 - ySize/2)];

% on fait un loop jsuqua ce qu'on click (buttons == 1).
buttons = 0;
while sum(buttons)==0
    [xCoor, yCoor, buttons] = GetMouse;
    
    destRect = imRect + [xCoor-round(xSize/2) round(yy/2 - ySize/2) xCoor-round(xSize/2) round(yy/2 - ySize/2)];
    
%   Screen('DrawTexture', windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
    Screen('DrawTexture', windowPtr, texturePtr, [], destRect, [],[],255);
    Screen('Flip', windowPtr);
end
sca;
ShowCursor;
%% % % % % % % % %  KEYBOARD % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % %% % % % % 

[secs, keyCode, deltaSecs] = KbWait([], 2); % waits for a key press (KbCheck doesn't wait? it typically has to be called repeatedly)

%%
keyCode         % nous donne l'index de la clef du clavier pesee, et enregistree avec KbWait
KbName(keyCode) % nous redonne le nom de la clef du clavier
KbName('a')     % a l'inverse, nous donne la clef du clavier selon son nom
find(keyCode==1)


% quelque chose qui ressemble a un temps de reponse dans une experience
start = GetSecs;
[secs, keyCode, deltaSecs] = KbWait([], 2); % waits for a key press (KbCheck doesn't wait?it typically has to be called repeatedly)
RT = secs-start


%% % % % % Keyboard demo 1 : KbWait % % % % % 
AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);

HideCursor;
ListenChar(2);

[windowPtr,rect]=Screen('OpenWindow',screenNumber);
Screen('TextSize', windowPtr, 100);

possibleKeys = 'qal';
exitKey = 'q';
temp = [];
FlushEvents('keyDown');
startSecs = GetSecs;
while ~strcmp(temp, exitKey)
    [secs, keyCode, deltaSecs] = KbWait([], 2);
    temp = KbName(keyCode);
    whichKey = strfind(possibleKeys, temp);
    if ~isempty(whichKey),
        Screen('DrawText', windowPtr, temp, 200, 200, [0 0 0]);
        Screen('DrawText', windowPtr, sprintf('%.2f', secs-startSecs), 300, 300, [0 0 0]);
        Screen('Flip', windowPtr);
        FlushEvents('keyDown');
    end
end
sca;
ShowCursor;
ListenChar(0);



%% Keyboard demo 2 : KbCheck

[keyIsDown, secs, keyCode, deltaSecs] = KbCheck;


%%  ce qui suit est equivalent a KbWait 
WaitSecs(0.1);

keyIsDown = 0;
while ~keyIsDown,
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
end

KbName(keyCode)

% % Une boucle qui se rapproche d'une experience avec KbCheck % % % % % 

% initialize screen parameters and stuff
AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);
HideCursor;
[windowPtr,rect]=Screen('OpenWindow',screenNumber);
Screen('TextSize', windowPtr, 100);
colors=cool;
counter=0;

% initialize keyboard keys enabled in the "experiment"
possibleKeys = 'qal';
exitKey = 'q';

temp = [];
old_temp = [];
FlushEvents('keyDown');
startSecs = GetSecs; % starts counter for RTs
while ~strcmp(temp, exitKey)
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck; % on utilise kbcheck pour interaction avec clavier
    
    % je module la couleur de mon ecran (de 1 a 64 du colorrange, definit plus haut) pendant l'experience
    counter=counter+1;
    color_temp=colors(mod(counter,64)+1,:);
    
    % je l'ecran colore au fur et a mesure de la modulation de couleur
    Screen('FillRect', windowPtr, uint8(255*color_temp))
    
    % si il y a une touche de pese, je vais montrer cette touche (ainsi que la latence du debut au keypress) 
    if ~isempty(temp)
        Screen('DrawText', windowPtr, old_temp, 300, 300, [0 0 0]);
        Screen('DrawText', windowPtr, sprintf('%.2f', latency), 400, 400, [0 0 0]);
    end
    Screen('Flip', windowPtr); % on met tout ca sur l'ecran pour le voir vraiment
    
    if keyIsDown % si une touche est pesee..
        
        temp = KbName(keyCode); % On retrouve son label
        
        
        if iscell(temp) % s'il y en a plusieur, on prend la premiere
            temp = temp{1};
        end
        
        % si la clef fait partie de celle "permise" dans lxp, on prend la
        % latence et la clef dans des var latency et old_temp
        whichKey = strfind(possibleKeys, temp);

        if ~isempty(whichKey)
            latency = secs - startSecs;
            old_temp = temp;
            FlushEvents('keyDown'); % Removes all events of the specified types from the event queue.
        else
            temp = old_temp;
        end
        
        
    end
end
sca;
ShowCursor;

%%


function grille_sin = fabriquer_grille_sin(patchSize, amplitude, frequence, phase, orientation)
% grille_sin = fabriquer_grille_sin(patchSize, amplitude, frequence, phase, orientation)
% 
% Frederic Gosselin, 22/01/2003
[x, y] = fabrique_grille_2d(patchSize);
u = cos(orientation);
v = sin(orientation);
grille_sin = amplitude * (sin(frequence * (u .* x + v .* y) + phase) / 2) + .5;
end


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
% figure, imshow(fabriquer_cercles_sin(512, 512, 1, 20, 0))
end


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
% figure, imshow(fabriquer_soleil_sin(512, 512, 1, 20, 0))
end

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
% figure, imshow(fabriquer_wiggle_sin(512, 512, 1, 5, 0, 7, 10, 0))


% avec de la couleur
% im = zeros(512, 512, 3);
% im(:,:,2) = fabriquer_grille_sin(512, 0.7, 5, 0, pi/4);
% im(:,:,1) = fabriquer_grille_sin(512, 0.7, 5, pi, pi/4);
% % figure, imshow(im)
end


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

% figure, imshow(fabriquer_gabor(256, 1, 20, 0, pi/5, 3))
end
function [x, y] = fabrique_grille_2d(patchSize)
% [x, y] = fabrique_grille_2d(patchSize)
%
% Frederic Gosselin, 20/01/2003

halfPatchSize = patchSize / 2;
[x, y] = meshgrid(-halfPatchSize:halfPatchSize-1, -halfPatchSize:halfPatchSize-1);
x = x / patchSize * 2 * pi;
y = y / patchSize * 2 * pi;

end

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
end
