
% Devoir : presenter deux grilles sinusoidales derriere une ouverture
% gaussienne en mouvement a des vitesses x et y au centre de l'ecran avec le Psychtoolbox.

% Solution 1 : tous les frames possibles...
speed_1 = 2;     % en cycles par seconde 
speed_2 = 1;     % en cycles par seconde
xySize = 512;
orient_1 = 0;
freq_1 = 5;
orient_2 = pi/3;
freq_2 = 10;
screens=Screen('Screens');
screenNumber=max(screens); % va toujours chercher l'Ècran secondaire
[windowPtr,rect]=Screen('OpenWindow',screenNumber, [127 127 127]);
[monitorFlipInterval nrValidSamples stddev] = Screen('GetFlipInterval', windowPtr); %
nb_frames_cycle_1 = round(1/(speed_1*monitorFlipInterval));
nb_frames_cycle_2 = round(1/(speed_2*monitorFlipInterval));
nb_frames = lcm(nb_frames_cycle_1, nb_frames_cycle_2); % plus petit commun multiple (PPCM ou LCM en anglais) des nombres de frames
frame_1 = 0;
frame_2 = 0;
for frame = 1:nb_frames,
    frame_1 = mod(frame-1, nb_frames_cycle_1)+1;
    frame_2 = mod(frame-1, nb_frames_cycle_2)+1;
    phase_1 = (frame_1-1)/(nb_frames_cycle_1)*2*pi;
    phase_2 = (frame_2-1)/(nb_frames_cycle_2)*2*pi;
    stimulus = 255*(fabriquer_gabor(xySize, 1, freq_1, phase_1, orient_1, 3)+fabriquer_gabor(xySize, 1, freq_2, phase_2, orient_2, 3))/2;
    texturePtr(frame) = Screen('MakeTexture', windowPtr, stimulus);
end
while 1,
    for frame = 1:nb_frames,
        Screen('DrawTexture', windowPtr, texturePtr(frame));            
        Screen('Flip', windowPtr);
    end
end


% Solution 2 : en utilisant la transparence...
speed_1 = 2;     % en cycles par seconde 
speed_2 = 1;     % en cycles par seconde
xySize = 512;
orient_1 = 0;
freq_1 = 5;
orient_2 = pi/3;
freq_2 = 10;
screens=Screen('Screens');
screenNumber=max(screens); % va toujours chercher l'Ècran secondaire
[windowPtr,rect]=Screen('OpenWindow',screenNumber, [127 127 127]);
[monitorFlipInterval nrValidSamples stddev] = Screen('GetFlipInterval', windowPtr);
nb_frames_cycle_1 = round(1/(speed_1*monitorFlipInterval));

for frame = 1:nb_frames_cycle_1,

    phase_1 = (frame-1)/(nb_frames_cycle_1)*2*pi;
    stimulus = 128*ones(xySize, xySize, 4);
    for ii = 1:3, stimulus(:,:,ii) = 255*fabriquer_gabor(xySize, 1, freq_1, phase_1, orient_1, 3); end
    texturePtr1(frame) = Screen('MakeTexture', windowPtr, stimulus);
end
nb_frames_cycle_2 = round(1/(speed_2*monitorFlipInterval));
for frame = 1:nb_frames_cycle_2,
    phase_2 = (frame-1)/(nb_frames_cycle_2)*2*pi;
    stimulus = 128*ones(xySize, xySize, 4);
    for ii = 1:3, stimulus(:,:,ii) = 255*fabriquer_gabor(xySize, 1, freq_2, phase_2, orient_2, 3); end
    texturePtr2(frame) = Screen('MakeTexture', windowPtr, stimulus);
end
while 1,
    frame = frame + 1;
    frame_1 = mod(frame-1, nb_frames_cycle_1)+1;
    frame_2 = mod(frame-1, nb_frames_cycle_2)+1;
    
    Screen('DrawTexture', windowPtr, texturePtr1(frame_1));
    Screen('DrawTexture', windowPtr, texturePtr2(frame_2));
    Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('Flip', windowPtr);
end




% devoir 2 solution : Bouger une image en fonction des coordonnées de la souris. 

AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1);
screens=Screen('Screens');
screenNumber=max(screens);
[windowPtr,rect]=Screen('OpenWindow',screenNumber, 128);
HideCursor;
SetMouse(round(rect(3)/2), round(rect(4)/2))
im = imread('w1N.JPG');
texturePtr = Screen('MakeTexture', windowPtr, im);
[xSize ySize] = size(im);
imRect = [0 0 xSize ySize];
buttons = 0;
while sum(buttons)==0,
    [xCoor, yCoor, buttons] = GetMouse;
    texturePtr = Screen('MakeTexture', windowPtr, uint8((double(im)-128)*yCoor/rect(4)+128));
    destRect = imRect + [xCoor-round(xSize/2) yCoor-round(ySize/2) xCoor-round(xSize/2) yCoor-round(ySize/2)];
    Screen('DrawTexture', windowPtr, texturePtr, [], destRect, [],[],255);
    Screen('Flip', windowPtr);
end

sca;
ShowCursor;




%% Mouse, Démonstration d'application d'un effet de transparence sur 
%%l'image affiché en fonction des coordonnée y de la souris et donc de l'image

AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1);
screens=Screen('Screens');
screenNumber=max(screens);
[windowPtr,rect]=Screen('OpenWindow',screenNumber, 128);
HideCursor;
SetMouse(round(rect(3)/2), round(rect(4)/2))
im = imread('w1N.JPG');
texturePtr = Screen('MakeTexture', windowPtr, im);
[xSize ySize] = size(im);
imRect = [0 0 xSize ySize];
centerCoor = [round(rect(3)/2 - xSize/2) round(rect(4)/2 - ySize/2) round(rect(3)/2 - xSize/2) round(rect(4)/2 - ySize/2)];
buttons = 0;
while sum(buttons)==0,
    [xCoor, yCoor, buttons] = GetMouse;
    texturePtr = Screen('MakeTexture', windowPtr, uint8((double(im)-128)*yCoor/rect(4)+128));
    destRect = imRect + [xCoor-round(xSize/2) yCoor-round(ySize/2) xCoor-round(xSize/2) yCoor-round(ySize/2)];
    Screen('DrawTexture', windowPtr, texturePtr, [], destRect, [],[],255);
    Screen('Flip', windowPtr);
end
sca;
ShowCursor;


% Mouse, demo 4.5
AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1);
screens=Screen('Screens');
screenNumber=max(screens);
HideCursor;
im = imread('w1N.JPG');
[windowPtr,rect]=Screen('OpenWindow',screenNumber, im(1,1));
texturePtr = Screen('MakeTexture', windowPtr, im);
xSize = size(im,1);
ySize = size(im,2);
temp = 255*(1-fabriquer_enveloppe_gauss(rect(3), 10));
gauss = double(im(1,1))*ones(rect(3), rect(3), 4);
gauss(:,:,4) = temp;
texturePtr2 = Screen('MakeTexture', windowPtr, gauss);
imRect = [0 0 xSize ySize];
centerCoor = [round(rect(3)/2 - xSize/2) yCoor-round(ySize/2) round(rect(3)/2 - xSize/2) yCoor-round(ySize/2)];
SetMouse(round(rect(3)/2), round(rect(4)/2))
buttons = 0;
while sum(buttons)==0,
    [xCoor, yCoor, buttons] = GetMouse;
    destRect = imRect + [xCoor-round(xSize/2) round(rect(4)/2 - ySize/2) xCoor-round(xSize/2) round(rect(4)/2 - ySize/2)];
    Screen('DrawTexture', windowPtr, texturePtr, [], destRect, [],[],128);
    Screen('DrawTexture', windowPtr, texturePtr2);
    Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('Flip', windowPtr);
end
sca;
ShowCursor;


    
%% L'utilisation du Clavier

%Permet de mesurer les temps des réponses comportementales (RT)

% Keyboard
[secs, keyCode, deltaSecs] = KbWait([], 2); % waits for a key press (KbCheck doesn't wait?it typically has to be called repeatedly)

keyCode
KbName(keyCode)
KbName('a')
KbName(KbName(keyCode))
find(keyCode==1)
find(keyCode) %parce que binaire

start = GetSecs;
[secs, keyCode, deltaSecs] = KbWait([], 2); % waits for a key press (KbCheck doesn't wait?it typically has to be called repeatedly)
secs-start


% Keyboard demo, 1 -- KbWait
AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);
HideCursor;
[windowPtr,rect]=Screen('OpenWindow',screenNumber);
Screen('TextSize', windowPtr, 100);
possibleKeys = 'abcdefghijklmnopqrstuvwxyz';
exitKey = 'a';
temp = [];
FlushEvents('keyDown');
startSecs = GetSecs;

while ~strcmp(temp, exitKey),
    [secs, keyCode, deltaSecs] = KbWait([], 2);
    temp = KbName(keyCode);
    whichKey = strfind(possibleKeys, temp)
    if ~isempty(whichKey),
        Screen('DrawText', windowPtr, temp, 200, 200, [0 0 0]);
        Screen('DrawText', windowPtr, sprintf('%.2f', secs-startSecs), 300, 300, [0 0 0]);
        Screen('Flip', windowPtr);
        FlushEvents('keyDown');
    end
end
sca;
ShowCursor;




% KbCheck

[keyIsDown, secs, keyCode, deltaSecs] = KbCheck;

       
WaitSecs(0.1);

keyIsDown = 0;
while ~keyIsDown,
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
end

KbName(keyCode)


% Keyboard demo, 2 -- KbCheck
AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);
HideCursor;
[windowPtr,rect]=Screen('OpenWindow',screenNumber);
Screen('TextSize', windowPtr, 100);
possibleKeys = 'abc';
exitKey = 'a';
temp = [];
old_temp = [];
FlushEvents('keyDown');
startSecs = GetSecs; % starts counter for RTs
while ~strcmp(temp, exitKey),
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    Screen('FillRect', windowPtr, uint8(255*rand(1,3)))
    if ~isempty(temp),
        Screen('DrawText', windowPtr, old_temp, 200, 200, [0 0 0]);
        Screen('DrawText', windowPtr, sprintf('%.2f', latency), 300, 300, [0 0 0]);
    end
    Screen('Flip', windowPtr);
    if keyIsDown,
        temp = KbName(keyCode);
        if iscell(temp),
            temp = temp{1};
        end
        whichKey = strfind(possibleKeys, temp);
        if ~isempty(whichKey),
            latency = secs - startSecs;
            old_temp = temp;
            FlushEvents('keyDown'); %Remove events from the system event queue.
        else
            temp = old_temp;
        end
    end 
end
sca;
ShowCursor;


% Le son, faire des beeps avec des fréquences (façon interessante de donner des retours sonore dans une expérience)

BeepFreq = [800 1300 2000]; BeepDur = [.1 .3 .2];
Beep1 = MakeBeep(BeepFreq(1), BeepDur(1));
Beep2 = MakeBeep(BeepFreq(2), BeepDur(2));
Beep3 = MakeBeep(BeepFreq(3), BeepDur(3));
Beep4 = [Beep1 Beep2 Beep3];
Snd('Play', Beep2);
Snd('Play', Beep3);
Snd('Play', Beep4);


% Devoir :
% En utilisant le clavier et MakeBeep, vous devez créer une tâche où lorsque l'on pèse sur certaines touches du clavier, cela déclenche des sons à des fréquences différentes.
