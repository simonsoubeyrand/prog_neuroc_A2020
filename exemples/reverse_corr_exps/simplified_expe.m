function simplified_expe(outName,session,task,keys)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEMPORAL SAMPLING WITH BUBBLES
% Lots of stuff erased or modified for simplification: 
% use as a teaching example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simplifications made in November 2018
% Laurent Caplette, October 2016
% Based on previous work by F. Gosselin, D. Fiset, C. Blais
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

time = clock;

AssertOpenGL;

screens = Screen('Screens');
screenNumber = max(screens); % 0 is main screen; 1 secondary screen

if keys==1
    possibleKeys = 'alb'; % a,l for 2 stimuli; b to quit
elseif keys==2
    possibleKeys = 'lab';
end


    %%%% lots of code here... %%%%


%% Open screen and start experiment

if expe.screen.hz ~= 120 || expe.screen.height ~= 1080
    error('Screen parameters are not valid')
end

k = GetKeyboardIndices; % if there are more than one keyboard...

ListenChar(2);

halfFix = 15;
white = WhiteIndex(screenNumber); % what is the RGB value for white (usually 255)
black = BlackIndex(screenNumber); % what is the RGB value for black (usually 0)
gray = (white+black)/2;

pixelSizes = Screen(screenNumber,'PixelSizes'); % color depths available
if max(pixelSizes)<16
    fprintf('Sorry, Hal needs a screen that supports 16-or 32-bit pixelSize.\n');
    return;
end

Screen('Preference','SkipSyncTests',1); 
pixelDepth = max(pixelSizes);
%pixelDepth = 24;
grandRect = Screen(screenNumber,'Rect'); % get useable window area (rectangle)

w = Screen('OpenWindow',screenNumber,0, [], pixelDepth, 2);

HideCursor;

priorityLevel = MaxPriority(w);

PsychGPUControl('SetGPUPerformance', 10); % only works on Windows, with specific GPUs...

ifi = Screen('GetFlipInterval', w); % real refresh rate

Screen('TextSize',w,25);
Screen('TextFont',w,'Helvetica');
Screen('TextStyle', w, 0);
Screen('TextColor', w, black);

Screen('FillRect',w, gray);
Screen('Flip', w);

xCenter = round(grandRect(3)/2);
yCenter = round(grandRect(4)/2);

% Various texts
welcometext = 'Appuyez sur une touche pour commencer la tâche.';
instructext{1} = sprintf(' Homme (%s) ou Femme (%s)?', possibleKeys(1), possibleKeys(2));
instructext{2} = sprintf(' Neutre (%s) ou Souriant (%s)?', possibleKeys(1), possibleKeys(2));
breaktext = 'Pause. Appuyez sur une touche pour continuer.';

% Display instructions
[normBoundsRect, offsetBoundsRect]= Screen('TextBounds', w, [welcometext, instructext{task}], xCenter, yCenter);
offsetX = (offsetBoundsRect(3)-offsetBoundsRect(1))/2;
offsetY = (offsetBoundsRect(4)-offsetBoundsRect(2))/2;
FlushEvents('keyDown');
keyIsDown = 0;
Screen('DrawText', w, [welcometext, instructext{task}], xCenter-offsetX, yCenter-offsetY);
Screen('Flip', w);
while ~keyIsDown
    keyIsDown = KbCheck(k(end));
end
Screen('Flip', w); % clear text

%% Boucle expérimentale

for Block = 1:nBlocks
    
    for trial = ((Block-1)*nTrialsBlock)+1:Block*nTrialsBlock
                
        startSecs = GetSecs; % to get processing duration...
        
        
            %%%% some processing here %%%%
        
        
        % création des textures (très courte vidéo)
        imTexture = zeros(1,nframes);
        for frame=1:nframes
            winImage = out{frame}+backgr_face+backgr_im;
            imTexture(frame) = Screen('MakeTexture', w, uint8(winImage*255));
        end
        
        calcTime(trial) = GetSecs - startSecs; % processing time at the beginning of each trial
        
        if trial==1
            realBlankT = blankT;
        else
            realBlankT = max(blankT-calcTime(trial)-WT(trial-1)-ifi,0.02);
        end
        
        % 1. blank/fixation (continuing from last trial)
        Screen('DrawLine',w,black, round(grandRect(3)/2)-halfFix,round(grandRect(4)/2),round(grandRect(3)/2)+halfFix,round(grandRect(4)/2));
        Screen('DrawLine',w,black, round(grandRect(3)/2),round(grandRect(4)/2)-halfFix,round(grandRect(3)/2),round(grandRect(4)/2)+halfFix);
        Screen('Flip', w);
        WaitSecs(realBlankT-ifi);
        
        Priority(priorityLevel); % not essential; and more complicated to use on Windows
        
        % 2. video stimulus
        vbl = Screen('Flip', w, [], 1); % flip to get timestamp but don't clear (cross still showing)
        startSecs = GetSecs; % starts counter for RTs (at the beginning of stimulus)
        for frame=1:expe.nframes
            Screen('DrawTexture', w, imTexture(frame));
            Screen('DrawLine',w,black, round(grandRect(3)/2)-halfFix,round(grandRect(4)/2),round(grandRect(3)/2)+halfFix,round(grandRect(4)/2));
            Screen('DrawLine',w,black, round(grandRect(3)/2),round(grandRect(4)/2)-halfFix,round(grandRect(3)/2),round(grandRect(4)/2)+halfFix);            
            vbl = Screen('Flip', w, vbl + 0.5 * ifi);
        end
        
        % 3. blank/fixation        
        Screen('DrawLine',w,black, round(grandRect(3)/2)-halfFix,round(grandRect(4)/2),round(grandRect(3)/2)+halfFix,round(grandRect(4)/2));
        Screen('DrawLine',w,black, round(grandRect(3)/2),round(grandRect(4)/2)-halfFix,round(grandRect(3)/2),round(grandRect(4)/2)+halfFix);       
        Screen('Flip', w);
        
        % Wait for response
        FlushEvents('keyDown');
        temp = 0;
        whichKey = [];
        while isempty(whichKey)     
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(k(end));
            if keyIsDown
                temp = KbName(keyCode);
                if sum(keyCode)==1
                    whichKey = findstr(temp, possibleKeys);
                end
                if eq(whichKey, 3)
                    sca
                    ListenChar(0);
                    error('Program stopped. User pressed exit key.')
                end
            end
        end
        
        % Compute response variables
        RT(trial) = secs - startSecs;
        responsekey(trial) = temp;
        responsestim(trial) = find(possibleKeys==temp); % nb of stimulus chosen
        
        
            %%%% some code here %%%%
        
            
        save(sprintf('facefeattime_%i_%s_%i.mat', task, outName, session), 'Xpadded', 'xpstim', 'weight', 'runningThreshold', 'responsekey', 'responsestim', 'correct', 'RT', 'WT', 'calcTime', 'theseed', 'prop', 'nGaussians', 'expe')
        
        Screen('Close', imTexture);
        
        WT(trial) = GetSecs - secs; % time between response and end of trial (here)
        
    end
    
    % Pause entre chaque bloc
    if Block~=nBlocks
        WaitSecs(0.5); % wait so that key is not down
        FlushEvents('keyDown');
        keyIsDown = 0;
        [normBoundsRect, offsetBoundsRect]= Screen('TextBounds', w, [welcometext, instructext{task}], xCenter, yCenter);
        offsetX = (offsetBoundsRect(3)-offsetBoundsRect(1))/2;
        offsetY = (offsetBoundsRect(4)-offsetBoundsRect(2))/2;
        Screen('DrawText', w, breaktext, xCenter-offsetX, yCenter-offsetY);
        Screen('Flip', w);
        while ~keyIsDown
            [keyIsDown, secs, keyCode, deltaSecs] = KbCheck(k(end));
        end
        Screen('DrawLine',w,black, round(grandRect(3)/2)-halfFix,round(grandRect(4)/2),round(grandRect(3)/2)+halfFix,round(grandRect(4)/2));
        Screen('DrawLine',w,black, round(grandRect(3)/2),round(grandRect(4)/2)-halfFix,round(grandRect(3)/2),round(grandRect(4)/2)+halfFix);               
        Screen('Flip', w);
        WaitSecs(WT(trial)); % wait so that next blank is really blankT
    end
    
end

ListenChar(0);
priorityLevel(0);
cd('/Users/dFiset/Documents/Laurent/MEG_dynamic/EEG_results');
sca;

fprintf('\nExactitude moyenne: %.1f%%', mean(correct)*100)
fprintf('\nTemps de réponse moyen: %.0f ms', mean(RT)*1000)
fprintf('\n')

ShowCursor;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%% Supporting functions here %%%%


