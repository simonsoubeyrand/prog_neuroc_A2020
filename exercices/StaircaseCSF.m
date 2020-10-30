function thresholds = StaircaseCSF(varargin)

% StaircaseCSF uses the QUEST adaptive method --
% Watson, A. B. and Pelli, D. G. (1983) QUEST: a Bayesian adaptive psychometric method. 
% Percept Psychophys, 33 (2), 113-20.
% -- to estimate the contrast thresholds for the orientation discrimination of Gabor patches 
% of different spatial frequencies (SFs).
%
% You must give the function two inputs at least: subNum, an integer that singles out the 
% subject, and nBlock, a integer from 1 to N that specifies the experimental block. The 
% threshold estimates are created in block 1 (default: educated guesses from the literature; 
% see the calculate_Start_SFs function below) and then refined and passed from block to 
% block. You can also give a third input: parameters (p) for a luminance calibration 
% function (i.e. luminance_value = p.a * rgb_value ^p.g + p.b; default is p.a=1, p.b=0 and 
% p.g=1.
%
% For example:
%
%       thresholds = StaircaseCSF(1, 1) % without luminance calibration parameters
%
%       p.a=0.0015; p.b=0.4; p.g=2;
%       thresholds = StaircaseCSF(1, 1, p) % with luminance calibration parameters
%
% The Gabors' SFs (default: 0.5, 0.99, 1.96, 3.87, 7.66, 15.16 and 30 cycles per deg), the 
% stimulus rectangle (default: 256 pixels), the Gabors' FWHM (default: 2 deg), the Gabors' 
% orientations (default: vertical vs. horizontal), the Gabors's phases (default: random), 
% the number of trials (7 SFs * 2 orientations * 6 repetitions = 82 trials), the response 
% keys (default: left arrow for vertical and up arrow from vertical), etc. are all specified 
% in the function and should be failry easy to change.
%
% The function outputs the thresholds (log10(contrast)) as well as a mat file that would be 
% called, in the above example, 'staircase_CSF_sub1_block1.mat'. This file contains three 
% variables: dataMat (a data matrix), q (a cell of QUEST structures), and scurr (the random 
% seed). dataMat contains one line per trial; each line has six columns that give: (1) the 
% Gabor's spatial frequency, (2) the Gabor's orientation, (3) the Gabor's phase, (4) the 
% accuracy of the reponse, (5) the response time, and (6) the contrast level (log10(contrast)).
%
% You will need functions from the Psychtoolbox (http://psychtoolbox.org) and the Curve Fitting 
% Toolbox (from MathWorks). Also you'll have to copy the truncated_log_parabola function, which
% appears at the end of this function, in the StaircaseCSF folder.
%
% Important: (1) adjust viewing distance so that the image rectangle is equal to PatchSize_deg 
% and (2) either make sure that there is a linear relationship between rgb values and luminance 
% values (e.g. on a Mac, put your LCD monitor gamma parameter to 1 in the Displays section of 
% the System Preferences), or provide luminance calibration parameters.
%
% Jessica Tardif, 17/07/2015
% jessica.tardif.1@umontreal.ca
%
% Modified by Frederic Gosselin, 20/07/2015
% frederic.gosselin@umontreal.ca

switch nargin
    case 2
        subNum = varargin{1};
        nBlock = varargin{2};
        p.a = 1; p.b = 0; p.g = 1;                                                      % default luminance caliibration
    case 3
        subNum = varargin{1};
        nBlock = varargin{2};
        p = varargin{3};                                                                % luminance calibration parameters (i.e. luminance_value = p.a * rgb_value ^p.g + p.c)
    otherwise
        error('Must give two input at least: subject_id and block_number. Can also give a third input: parameters (p) for a luminance calibration function.')
end

% Checks if file name already exists
file_name = sprintf('staircase_CSF_sub%d_block%d', subNum, nBlock);
if fopen([file_name,'.mat'])>0
	warning('This filename already exists.')
    reenter = input('Overwrite (y/n)? ', 's');
    if strcmp(reenter, 'n')
    	subNum = str2double(input('Enter new subject number: ', 's'));
        nBlock = str2double(input('Enter new block number: ', 's'));
    end
end

Screen('Preference', 'SkipSyncTests', 1); % Remove this on macs

% Constants
Gabor_deg = 2;                                                                      % Gabor's FWHM in deg
patchSize_pixel = 256;                                                              % image rectangle in pixels
std_prop = 0.3;                                                                     % Gaussian envelop's std in proportion of patchSize_pixel
Gabor_pixel = 2*sqrt(2*log(2))*std_prop*patchSize_pixel;                            % Gabors' FWHM in pixels
patchSize_deg = 2*atan((patchSize_pixel/2)/((Gabor_pixel/2)/tan(Gabor_deg/2)));     % image rectangle in deg
% To compute viewing_distance_cm from patchSize_cm (to measure with a ruler) and patchSize_deg:
% viewing_distance_cm = (patchSize_cm/2)/atan(patchSize_deg/2*pi/180) % is ~147 cm on my 15" monitor with the default parameters
gray = (128/255*255^p.g) .^(1/p.g);
%gray = 0; % to measure patch size with a ruler
nbFreq = 7;                                                                         % number of tested spatial frequencies   
minFreq = 0.5;                                                                      % min spatial frequency in cycles per deg
maxFreq = 30;                                                                       % max spatial frequency in cycles per deg
baseFreq = (maxFreq/minFreq)^(1/(nbFreq-1));
spaFreq = minFreq*baseFreq.^[0:nbFreq-1];                                           % all spatial frequencies in cycles per deg
orientations = [0 pi/2];                                                            % orientations in rad
key1 = 'a';%'UpArrow';                                                                   % Key for first entry in orientation vector
key2 = 's';%'LeftArrow';                                                                 % Key for second entry in orientation vector
nRep = 6;                                                                           % Shorter blocks for kids so they can take breaks
nTrials = nbFreq*nRep*2;                                                            % Times 2 because two orientations are discriminated
fid=fopen('StaircaseCSF.m');
this_function = fscanf(fid,'%s');                                                   % puts this function in a string that will be saved with the data for reference purposes
fclose(fid);

% Quest variables
startContrast = calculate_Start_SFs(spaFreq); % log10(contrast) threshold estimates from ModelFest database
q = cell(1,nbFreq);
if(nBlock == 1)
    pThreshold=0.82;
    beta=3.5;delta=0.01;gamma=0.5;
    tGuess = startContrast;
    tGuessSd = 2;
    for ii = 1:nbFreq
        q{ii}=QuestCreate(tGuess(ii),tGuessSd,pThreshold,beta,delta,gamma);
        q{ii}.normalizePdf=1;                                                       % This adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.
    end
else
    load(sprintf('staircase_CSF_sub%d_block%d.mat', subNum, nBlock-1))
end

% Data matrix; 4th line for accuracy, 5th line for response time, 6th for contrast level shown
rng('shuffle');                                                                     % seeds random generator with clock
scurr = rng;                                                                        % puts this seed in a variable
dataMat = zeros(6,nTrials);
dataMat(1,:) = repmat(1:nbFreq,1,2*nRep);                                           % Frequencies
idx = randperm(nTrials);
dataMat = dataMat(:, idx);                                                          % Shuffling trials
dataMat(2,:) = ceil(2*rand(1,nTrials));                                             % Orientations
dataMat(3,:) = pi*rand(1,nTrials);                                                  % Random phase

% Screen
AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);
[w, wRect]=Screen('OpenWindow',screenNumber, gray,[],32,2);
Screen('FillRect',w, gray);
Screen('Flip', w);
HideCursor; 
ListenChar(2);                                                                      % enables listening to keyboard but any output of keypresses is suppressed

thresholds = zeros(1, nbFreq);

% main loop
for trial = 1:nTrials
    
    % Creates stimulus
    thisSF = spaFreq(dataMat(1,trial));
    thisContrast = QuestMean(q{dataMat(1,trial)}); % expressed in log10(contrast)
    thisOrientation = orientations(dataMat(2,trial));
    thisPhase = dataMat(3,trial);

    thisContrast = min(max(thisContrast, -4), 0); % limits log10(contrast) on both sides
    dataMat(6,trial) = thisContrast;
    
    grating_temp = make_Gabor(patchSize_pixel, patchSize_deg, std_prop, thisPhase, thisContrast, thisSF, thisOrientation); 
    grating = noisy_bit(grating_temp, 256);                                               % noisy-bit dithering
    grating_dithered = (grating/255*255^p.g) .^(1/p.g);                                   % luminance calibration, sort of
    theGrating = Screen('MakeTexture', w, uint8(grating_dithered));

    % Blank screen
    Screen(w, 'FillRect', gray);
    Screen('Flip', w);
    WaitSecs(0.3);
    
    %sound(sin(1:500), 5000) % indicates the beginning of a new trial

    % Gives feedback
    if trial>1,
        if dataMat(4,trial-1)==1        % previous trial was correct
            sound(sin(1:500), 10000)    % positive feedback -- high pitch sound
        else                            % previous trial was incorrect
            sound(sin(1:500), 2500)     % negative feedback -- low pitch sound
        end
    else
        sound(sin(1:500), 5000)         % indicates the beginning of the first trial
    end   
    
    % Draw grating
    FlushEvents('keyDown');
    startSecs = GetSecs;
    Screen('DrawTexture', w, theGrating);
    Screen('Flip', w);
 
    while 1,
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
 
        if keyIsDown,
            if strcmp(KbName(keyCode), key1),
                if dataMat(2,trial) == 1;                                               % must corresponds to the first entry in the vector orientations
                    dataMat(4,trial) = 1;
                end
                dataMat(5,trial) = secs-startSecs;
                break;
            elseif strcmp(KbName(keyCode), key2),
                if dataMat(2,trial) == 2;                                               % must corresponds to the second entry in the vector orientations
                    dataMat(4,trial) = 1;
                end
                dataMat(5,trial) = secs-startSecs;
                break;
            elseif strcmp(KbName(keyCode),'q');
                error('Quit key was pressed');
                Screen('CloseAll');
            end
        end
    end
    FlushEvents('keyDown');
    
    q{dataMat(1,trial)} = QuestUpdate(q{dataMat(1,trial)}, thisContrast, dataMat(4,trial));
    
    for ii = 1:nbFreq, thresholds(ii) = QuestMean(q{ii}); end                           % current threshold estimates
    
    save(file_name, 'this_function', 'spaFreq', 'orientations', 'dataMat', 'q', 'scurr', 'p', 'thresholds')            % saves important stuff
end

sca;
ShowCursor;
ListenChar(1);                                                                          % enables listening to keyboard and keypress outputs

 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function  contrast_thresh = calculate_Start_SFs(spa_freq)
% Frederic Gosselin, 17/07/2015
% frederic.gosselin@umontreal.ca

% Thresholds for stimuli 1 to 10 from the ModelFest database (0.5 deg Gabors)
x = [1.12 2 2.83 4 5.66 8 11.3 16 22.6 30]; % spatial frequencies in cycles per deg
y = [1.8209 1.9602 2.0630 2.1040 1.9919 1.8436 1.6212 1.2953 0.9603 0.5687]; % mean thresholds (-log10(Weber contrast))

% Fits the truncated log parabola to the thresholds.
% But does not work unless the truncated_log_parabola function is copied in
% the StaircaseCSF folder.
ft = fittype('truncated_log_parabola(x, beta, delta, f_max, y_max)');
[f goodness] = fit(x', y', ft, 'Lower', [0 0 0 0], 'Upper', [5 50 30 500], 'StartPoint', [1 0.5 3 200], 'MaxIter', 2000);
contrast_thresh = -f(spa_freq); % log10(Weber contrast), not -log10(Weber contrast)



function y = truncated_log_parabola(x, beta, delta, f_max, y_max)
% Implements, with slight modifications, the truncated log parabola described in:
% Lesmes, L. A., Lu, Z. L., Baek, J., & Albright, T. D. (2010). Bayesian adaptive estimation of the contrast sensitivity function: the quick CSF method. Journal of Vision, 10(3), 17.
%
% Frederic Gosselin, 05/07/2015
% frederic.gosselin@umontreal.ca

%yp = log10(y_max) - ((log10(x)-log10(f_max))/(beta/2)).^2; % beta is the ~FWHM (full width at log10(y_max)-1)
%yp = log10(y_max) -
%log10(2)*((log10(x)-log10(f_max))/(log10(2*beta)/2)).^2; % beta is the ~FWHM in octaves (full width at log10(y_max)-1) according to Lesmes et al. (2010) but doesn't seem to work
yp = log10(y_max) - ((log10(x)-log10(f_max))/(beta*log10(2)/2)).^2; % beta is the ~FWHM in octaves (full width at log10(y_max)-1)
y = yp;
condition = (x<f_max) & (yp<(log10(y_max)-delta));
y(condition) = log10(y_max)-delta; % is (y_max-delta) in Lesmes et al. (2010) but it seems incorrect



function stimulus = make_Gabor(patch_pixel, patch_deg, std_prop, phase, contrast, freq_cpd, orientation_rad)
% Frederic Gosselin, 20/07/2015
% frederic.gosselin@umontreal.ca

the_contrast = 10^contrast;     % assumes that contrast is log10(contrast)
[x,y] = meshgrid(0:patch_pixel-1, 0:patch_pixel-1);
x = x/patch_pixel-.5;
y = y/patch_pixel-.5;
x_rad = x*2*pi*patch_deg;       % makes x-coordinates cover -patch_deg*pi to patch_deg*pi deg
y_rad = y*2*pi*patch_deg;       % makes y-coordinates cover -patch_deg*pi to patch_deg*pi deg
u = cos(orientation_rad);
v = sin(orientation_rad);
gaussian = exp(-(x .^2 / std_prop ^2) - (y .^2 / std_prop ^2));
sinus = sin(freq_cpd * (u .* x_rad + v .* y_rad) + phase);
stimulus = gaussian .* (the_contrast * sinus/2) + 0.5;



function tim = noisy_bit(im, depth)
% im must vary between 0 and 1 and depth is the number of gray shades
%
% im = double(imread('w1N.JPG'))/255;
% figure, imshow(stretch(noisy_bit(im, 2)))
%
% Allard, R., Faubert, J. (2008) The noisy-bit method for digital displays:
% converting a 256 luminance resolution into a continuous resolution.
% Behavior Research Method, 40(3), 735-743.
%
% Frederic Gosselin, 12/02/2013
% frederic.gosselin@umontreal.ca

tim = im*(depth-1);
tim = max(min(round(tim+rand(size(im))-.5), depth-1), 0) + 1;
