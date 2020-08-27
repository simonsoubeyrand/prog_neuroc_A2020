function Memory_Step1 = memory_exp(SubName, BlockNum)
%% Rose-Marie Gervais
%The Gabor patches were created with the following loop and than saved as .jpg images
% 
% for jj = 1:nGabors
%     gabor = fabriquer_gabor(500, 0.2, 10, 1, jj*pi/nGabors, 2);
%     output = char(strcat('\Users\Utilisateur\Documents\Rose-Marie\UdeM\Automne 2018\Programmation en neuroscience cognitive\exp_prog\', 'patch', string(jj), '.jpg')); 
%     imwrite(gabor, output); 
% end
%
% As for the neural flash, it is the average of all the gabor patches and
% it was created with the following code and saved as a .jpg image
% im1 = double(imread('patch1.jpg'))/255;
% im2 = double(imread('patch2.jpg'))/255;
% im3 = double(imread('patch3.jpg'))/255;
% im4 = double(imread('patch4.jpg'))/255;
% 
% imNoise = (im1 + im2 + im3 + im4) / 4;
% imNoise = imNoise*255;
% imNoise = uint8(imNoise);


SubSeed = rng('Shuffle');                         % The seed will be saved at the end of each trial in order to be able to reproduce the exact same noise if necessary
%% Create file name that all the data will saved under

file_name = sprintf('memory_exp_Sub%s_Block%d.mat', SubName, BlockNum);               
% Check if the file name already exists
if fopen(file_name)>0                
	warning('This filename already exists.')
    reenter = input('Overwrite (y/n)? ', 's');
    if strcmp(reenter, 'n')
        SubName = str2double(input('Enter new subject number: ', 's'));
        BlockNum = str2double(input('Enter new block number: ', 's'));
    end
end


%% Constants
nTrials = 160;                                  % Number of trials: DO NOT CHANGE BECAUSE THIS VALUE WAS CHOSENT TO FIT WITH THE AMOUNT OF DIFFERENT FACES (24). Go to line 139 for more details
nStimuli = 24;                                  % Number of different stimuli
nTargets = 8;                                   % Number of targets
nGabors = 4;                                    % Number of Gabor Patches
nNonTargets = nStimuli - nTargets;              % Number of non-targets
patchSize = 500;
FemaleMat(1, :) = 1:12;                         % This matrix is used to randomly pick 4 female faces that will be targets. The numbers 1 to 12 represent the index of the stimuli
MaleMat(1, :) = 13:24;                          % This matrix is used to randomly pick 4 male faces that will be targets. The numbers 13 to 24 represent the index of the stimuli
StimMat = [];                                   % This is the matrix that contains all the stimuli ? row 1 = stimulus index, row 2 = target or not (1 = taret, 2 = non-target)
TargMat = [];                                   % This matrix contains the indez of the stimuli the that were randomly picked as targets
NonTargMat = [];                                % This matrix contains the index of the stimuli that aren't targets
GaborMat = 1:nGabors;
GaborMat = Shuffle(GaborMat);

KbName('UnifyKeyNames');
Key1=KbName('d'); 
Key2=KbName('k');
escKey = KbName('ESCAPE');
spaceKey = KbName('SPACE');
corrkey = [68, 75];

data = struct;                                  % Structure in which all the data of a participant will be saved
data.TrialMat = [];                             % This matrix contains which stimulus is to be presented for each trial (row 1) and whether or not it is a target (row 2, 1 = target) and whether or not the target is 
                                                % associated with a Gabor patch (row 3, 1 = associated) and which patch associated target are associated with (can be either 1 = patch1, 2 = patch2, 3 = patch3 and 4 = patch4. 0 means no patch
data.accuracy = [];                             % 1 = good answer, 2 = bad answer
data.reactT = [];                               % Reaction time for each trial
data.answer = [];                               % Will contain the answer of the participant. 'd' means non-target and 'k' means target

%% Here we define which stimuli will be targets and which targets are associated with a patch
% This is where the target stimuli are randomly selected and put in the StimMat matrix. This is only executed if it is the first block and the
% resulting matrix is saved at the end and will be reused for the following blocks

if BlockNum == 1
    MaleTargs = randperm(12, 4);                                 % This gives the position of the stimuli in the FemaleMat and MaleMat that will be targets since the numbers in those matrices represente the indexes of the stimuli
    FemaleTargs = randperm(12, 4);
    AssocMaleTargs = randperm(4, 2);                             % This gives us the position of the targets in the MaleTargs and FemaleTargs matrices that will associated with a patch
    AssocFemaleTargs = randperm(4, 2);
    
    
    for ii = 1:2                                                 % This loops put the value 1 in the FemaleTargs and MaleTargs matrices for the targets that are associated with a patch
        FemaleTargs(2, AssocFemaleTargs(1, ii)) = 1;              
        MaleTargs(2, AssocMaleTargs(1, ii)) = 1;
    end
       
    
    
    for ii = 1:4                                                  % This loop gives the value 1 to the targets for female and male faces
        FemaleMat(2, FemaleTargs(1,ii)) = 1;                         
        MaleMat(2, MaleTargs(1,ii)) = 1;
        if FemaleTargs(2, ii) == 1                                % This condition verifies if the target is associated and if it is, it puts the value 1 on the FemaleMat and MaleMat
            FemaleMat(3, FemaleTargs(1, ii)) = 1;
        end
        if MaleTargs(2, ii) == 1
            MaleMat(3, MaleTargs(1, ii)) = 1;
        end
    end
        
    
    StimMat = [FemaleMat, MaleMat];                               % Here the FemaleMat and MaleMat are combined into one matrix.This is the matrix that will be saved
    
    
    condition1 = 0;
    condition2 = 0;
    condition3 = 0;
    condition4 = 0;
    
    for ii = 1:nStimuli                                           % This loop defines which patch is going to be paired with the associated targets. 
        if StimMat(3, ii) == 1 && (condition1 == 0)
            StimMat(4, ii) = GaborMat(1, 1);
            condition1 = 1;
        elseif ((StimMat(3, ii) == 1) && (condition2 == 0) && (condition1 == 1))
            StimMat(4, ii) = GaborMat(1, 2);
            condition2 = 1;
        elseif ((StimMat(3, ii) == 1) && (condition3 == 0) && (condition1 == 1) && (condition2 == 1))
            StimMat(4, ii) = GaborMat(1, 3);
            condition3 = 1;
        elseif ((StimMat(3, ii) == 1) && (condition4 == 0) && (condition1 == 1) && (condition3 == 1) && (condition2 == 1))
            StimMat(4, ii) = GaborMat(1, 4);
            condition4 = 1;
        end
    end
    
    
    for ii = 1:nStimuli                                             % This loop simply puts the value 2 for each stimuli that are not targets and for the targets that aren't associated
        if StimMat(2,ii) ~= 1                           
            StimMat(2, ii) = 2;
        end
        if StimMat(3, ii) ~= 1
            StimMat(3, ii) = 2;
        end 
    end
    
    save(sprintf('StimMat%s.mat', SubName), 'StimMat');             % The final matrix is saved and will be reused for ulterior blocks

elseif BlockNum ~= 1                                                % If this isn't the first block, get the StimMat that was used previously for the subject because we don't want to change the association or which stimuli are targets
    Mat = matfile(sprintf('StimMat%s.mat', SubName));           
    StimMat = Mat.StimMat;        
end


%% Here we put the target index and the non-target index in a different matrix to create de Trial matrix that will determine the order of presentation (random) of each stimulus. 
% 50% of trials will display targets and the other 50% will be non-targets. All targets are presented
% the exact same amount of time. Same for all the non-targets.

for ii = 1:nStimuli
    if StimMat(2, ii) == 1
        TargMat= [TargMat, StimMat(1, ii)];
    elseif StimMat(2, ii) == 2
        NonTargMat = [NonTargMat, StimMat(1, ii)];
    end
end

% Here the TrialMat will determine the random order of presentation of each stimulus. 
% Since we have 160 trials, 80 trials will present targets and 80 will present non-target. Sinci we have 8 targets, all of them will be presented
% 10 times in one block. Because we have 16 non-tagets, they will all be presented 5 times in one block
data.TrialMat = [repmat(TargMat, [1, nTrials*0.5/nTargets]), repmat(NonTargMat, [1, nTrials*0.5/nNonTargets])];          % Matrix for trials that will decide if the displayed stimulus is a target or not and which stimulus will be presented
data.TrialMat = data.TrialMat(randperm(length(data.TrialMat)));                                                              % This is the final trial matrix that will be used to present the different stimuli in a random order


%% Generate the noise to mask the patches
halfPatchSize = (patchSize-1) / 2;
[x, y] = meshgrid(-halfPatchSize:halfPatchSize, -halfPatchSize:halfPatchSize);
x = x / (patchSize-1) * 2 * pi;
y = y / (patchSize-1) * 2 * pi;
rayon = sqrt(x .^2 + y .^2);
filt = rayon>.025*pi & rayon<.175*pi;

%% Create the feedback noise
Fe = 8000;
nBits = 16;
duree = 0.30;
freq = 850; 
etendue = 2 * pi * (0:duree*Fe-1) / Fe;
amplitude = 0.3;
un_son = amplitude * sin(freq * etendue);
un_son_struct = audioplayer(un_son, Fe, nBits);

%% Starting the experiement

Screen('Preference', 'SkipSyncTests', 0);
AssertOpenGL;
screens = Screen('Screens');
screenNumber = max(screens);
[windowPtr,~] = Screen('OpenWindow',screenNumber, [127 127 127]);
Screen('Flip', windowPtr);
HideCursor;
FlipInterval = Screen('GetFlipInterval', windowPtr);
NumSecsNoise = 1;                                              % This determines the amount of time the noise will be presented
NumSecsStim = 0.03;                                            % This determines the amount of time the patches will be presented
NumFrames = round(NumSecsNoise / FlipInterval);                % This value will determine how many times the screen will be flipped until the desired time is reached. The value changes according to the refresh rate of a cumputer
NumFramesStim = round(NumSecsStim / FlipInterval);

%% Instructions

Screen('TextSize',windowPtr, 18);
Screen('TextFont',windowPtr,'Helvetica');
Screen('TextStyle', windowPtr, 0);
Screen('TextColor', windowPtr, [255 255 255], [0 0 900 900]);
Screen('FillRect',windowPtr, [127 127 127]);

% Display instructions
if BlockNum == 1                                              % This condition is to make sure that the target stimuli are only presented before the first block. If the person has already done the block one, the task will begin right away
    InstruMat = Shuffle(TargMat);                             % Will present the targets in a random order because if they are presented in order the females will all be showed before the males    
    
    FlushEvents('keyDown');
    keyIsDown = 0;
    DrawFormattedText(windowPtr, sprintf('In this task, you will be presented with 8 different faces (Targets)\n\n\none after the other that you will have to memorize. After this step,\n\n\nsome faces will be presented to you and your task will be to indicate,\n\n\n as quickly as possible and as accuratly as possible,\n\n\nif the face that is displayed is a target (%s) or a non-target (%s).\n\n\nIf you wish to quit the task during the experiement press the escape key\n\n\n\nPress any key to continue.', Key1, Key2, escKey), 'center', 'center');
    Screen('Flip', windowPtr);
    
    while ~keyIsDown
        keyIsDown = KbCheck; 
    end
    Screen('Flip', windowPtr);

    FlushEvents('keyDown');
    keyIsDown = 0;
    WaitSecs(0.75);
    DrawFormattedText(windowPtr, 'You will receive a feedback \n\n\ntelling you if you got the correct answer or not. \n\n\nThe feedback will be a sound that you will hear\n\n\nif you get the INCORRECT answer. \n\n\n\nPress any key to hear the feedback sound.', 'center', 'center');
    Screen('Flip', windowPtr);
    
    while ~keyIsDown
        keyIsDown = KbCheck; 
        if keyIsDown
            WaitSecs(0.3);
            play(un_son_struct);
            WaitSecs(2);
        end
    end
    
    FlushEvents('keyDown');
    keyIsDown = 0;
    DrawFormattedText(windowPtr, 'The experiment will now begin.\n\n\n\nPress any key when you are ready.', 'center', 'center');
    Screen('Flip', windowPtr);
    while ~keyIsDown
        keyIsDown = KbCheck; 
    end
    WaitSecs(0.75);
    DrawFormattedText(windowPtr, 'Memorize the following faces.', 'center', 'center');
    Screen('Flip', windowPtr);
    WaitSecs(2);
    
    % Show all the target faces that should be memorized one after the other. All of which are presented for 4 seconds
    for ii = 1:nTargets
        noise = (randn(patchSize));                                               % create random noise that is different for each trial 
        noise = noise/(2*icdf('norm', 0.025, 0, 1))+0.5;
        fnoise = fftshift(fft2(noise));
        filt_fnoise = fnoise .* filt;
        filt_noise = uint8(stretch_image(real(ifft2(ifftshift(filt_fnoise))))*255);

        if StimMat(1, InstruMat(1, ii)) < 13                                      % If the stimulus is a female face (this only exists because the female and male faces are saved under different names)
            imDisp = imread(sprintf('SHINEd_CDF_WF_%d.tif', InstruMat(1, ii))); 
        elseif StimMat(1, InstruMat(1, ii)) >= 13                                 % If the stimulus is a male face
            imDisp = imread(sprintf('SHINEd_CDF_WM_%d.tif', InstruMat(1, ii)));
        end

                                                           
        if StimMat(3, InstruMat(1, ii)) == 1                                      % If the face is associated with a patch, show the said patch. If not show the neutral flash
            Gabor = imread(sprintf('patch%d.jpg', StimMat(4, InstruMat(1, ii))));
        elseif StimMat(3, InstruMat(1, ii)) == 2
            Gabor = imread('imNoise.jpg');                                        % ImNoise is the mean of all the patches and will be used as the neutral flash
        end
                
        texturePtr = Screen('MakeTexture', windowPtr, filt_noise);                % Noise (mask)
        showGabor = Screen('MakeTexture', windowPtr, Gabor);                      % Gabor or neutral flash
        image = Screen('MakeTexture', windowPtr, imDisp);                         % Face that will be displayed

        for ii = 1:NumFrames                                                      % This loop allows us to present the stimuli for the desired amount of time
            Screen('DrawTexture', windowPtr, texturePtr);                         % The noise is showed for 1 second before and after the patch or neutral flash
            Screen('Flip', windowPtr);
        end

        for ii = 1:NumFramesStim                                                  % The patch or neutral flash is showed for 30 ms
            Screen('DrawTexture', windowPtr, showGabor);
            Screen('Flip', windowPtr);
        end

        for ii = 1:NumFrames
            Screen('DrawTexture', windowPtr, texturePtr);
            Screen('Flip', windowPtr);
        end
        
        
        Screen('DrawTexture', windowPtr, image);                                   % Show the face
        Screen('Flip', windowPtr);
        WaitSecs(4);
    end
end
    
% This will be executed regardless of the block number. 
FlushEvents('keyDown');
keyIsDown = 0;
DrawFormattedText(windowPtr, sprintf('Target key (%s) and non-target key (%s).\n\n\n\nPress any key to start.', Key1, Key2), 'center', 'center'); 
Screen('Flip', windowPtr);

while ~keyIsDown
    keyIsDown = KbCheck;
end
Screen('Flip', windowPtr);
WaitSecs(0.5);

%% experimental loop

for trial = 1:nTrials  
    noise = (randn(patchSize));                                                      % Creates the noise. It is different for each trial
    noise = noise/(2*icdf('norm', 0.025, 0, 1))+0.5;
    fnoise = fftshift(fft2(noise));
    filt_fnoise = fnoise .* filt;
    filt_noise = uint8(stretch_image(real(ifft2(ifftshift(filt_fnoise))))*255);      % Noise
    
    
    if data.TrialMat(1, trial) < 13                                                  % If the face is a female face
        imDisp = imread(sprintf('SHINEd_CDF_WF_%d.tif', data.TrialMat(1, trial)));   % imDisp is the face that will be present at the current trial      
    elseif data.TrialMat(1, trial) >= 13
        imDisp = imread(sprintf('SHINEd_CDF_WM_%d.tif', data.TrialMat(1, trial)));   % If the face is a male face
    end
    
    
    if StimMat(3, data.TrialMat(1, trial)) == 1                                      % If the face is paired with a patch, Gabor = the patch matched with the face
        Gabor = imread(sprintf('patch%d.jpg', StimMat(4, data.TrialMat(1, trial))));
    elseif StimMat(3, data.TrialMat(1, trial)) == 2                                  % If the face isn't paired with a patch, Gabor will be the neutral flash
        Gabor = imread('imNoise.jpg');
    end
    
    
    % Create the different textures
    texturePtr = Screen('MakeTexture', windowPtr, filt_noise);         
    showGabor = Screen('MakeTexture', windowPtr, Gabor);
    image = Screen('MakeTexture', windowPtr, imDisp);
    
    % Present the different textures for the desired amount of time
    for ii = 1:NumFrames
        Screen('DrawTexture', windowPtr, texturePtr);          % Present the noise for 1 second
        Screen('Flip', windowPtr);
    end
    
    for ii = 1:NumFramesStim
        Screen('DrawTexture', windowPtr, showGabor);           % Present gabor or neutral flash for 30 ms
        Screen('Flip', windowPtr);
    end
    
    for ii = 1:NumFrames
        Screen('DrawTexture', windowPtr, texturePtr);          % Present the noise for another 1 second
        Screen('Flip', windowPtr);
    end
    
    
    % Show the face
    Screen('DrawTexture', windowPtr, image);
    Screen('Flip', windowPtr);
    timeStart = GetSecs;                               % Start GetSecs right after the stimulus is presented
    
    keyIsDown= 0; 
    accuracy = 0; 
    rt=0; 
    answer = 0;
    
    % Get response
    while 1
        [keyIsDown, secs, keyCode] = KbCheck;
        FlushEvents('keyDown');
        if keyIsDown
            nKeys = sum(keyCode);
            %Screen('Flip', windowPtr);
            if nKeys==1                                             % Check if a key was pressed
                if keyCode(Key1)||keyCode(Key2)                     % Checks if the keyCode of the pressed key corresponds to D or K
                    rt = (secs - timeStart);                        % Reaction time
                    keypressed = find(keyCode);                     % contains the code of the pressed key. can be either 68 (D) or 75 (K)
                    data.answer = [data.answer, keypressed];        % Add keypress to data.answer
                    break;
                elseif keyCode(escKey)                              % End the trial if the escape key is pressed
                    ShowCursor; 
                    Screen('CloseAll'); 
                    return
                end
            end
        end  
    end
    
    % Check accuracy
    if (((data.answer(1, trial) == 68) && (StimMat(2, data.TrialMat(1, trial)) == 1)) || ((data.answer(1, trial) == 75) && (StimMat(2, data.TrialMat(1, trial)) == 2)))
        accuracy = 1;                                % If the response is correct
        Screen('FillRect',windowPtr, [127 127 127]);
        Screen('Flip', windowPtr);
        WaitSecs(1);
    end
    if (((data.answer(1, trial) == 68) && (StimMat(2, data.TrialMat(1, trial)) == 2)) || ((data.answer(1, trial) == 75) && (StimMat(2, data.TrialMat(1, trial)) == 1)))
        accuracy = 2;                                % If the response is incorrect 
        Screen('FillRect',windowPtr, [127 127 127]);
        Screen('Flip', windowPtr);
        play(un_son_struct);                         % Play the feedback sound
        WaitSecs(1);
    end
    
    data.accuracy = [data.accuracy, accuracy];      % Add the accuracy to data.accuracy. 1 = correct and 2 = incorrect
    data.reactT = [data.reactT, rt];                % Add the reaction time of current trial to data.reactT

    save(file_name, 'data', 'SubSeed');             % Save the data structure and the rng(Shuffle) values under the file name
      
end
ShowCursor;
sca;
end
