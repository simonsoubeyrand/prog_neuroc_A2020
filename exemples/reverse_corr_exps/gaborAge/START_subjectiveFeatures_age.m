% START_diagnosticFeatures

close all; clear;

%% folder organisation parameters

startPath=pwd;
functionPath = fullfile(startPath,'/functions'); addpath(genpath(functionPath));
featurePath  = fullfile(startPath,'/features');
resultsPath  = fullfile(startPath,'results');

%% query participant details
prompt       = {'Enter the subject identifier:'};
name         = 'Participant setup';
numlines     = 1;
answer       = inputdlg(prompt,name,numlines);
params.sID   = answer{1};

%% query the experiment details

params.expe  = 'age';

%% define parameters
prompt       = {'Enter the Display''s CFG name (e.g. Cubicle)'};
name         = 'Display setup';
numlines     = 1;
answer       = inputdlg(prompt,name,numlines);
params.DispCFG  = answer{1};

showplots = 1;

% Display configuration can be :
%CFG	= 'CharestLaptop';
%CFG	= 'Cubicle';
%CFG     = 'MacMini';
%CFG     = 'LaptotSimon';

CFG    =   params.DispCFG;

stimsize_deg    = 8; % degrees of visual angle
nRepetitions    =  1; % Number of blocks

% update params struct
params.cfg            = CFG;
params.nruns          = nRepetitions;
params.featurePath    = featurePath;
params.resultsPath    = resultsPath;
params.trialsprebreak = 200;
params.ImSize         = 250;
params.displ          = zeros(params.ImSize);
params.nFts           = 2200;%

params.CatReps        = 200;
params.fixrange       = (params.ImSize/2)-3:(params.ImSize/2)+3;
params.FixIm          = zeros(params.ImSize);params.FixIm(params.fixrange,params.fixrange)=.5;

%% identify features to select

% only load relevant features
params.flushQuest     = 1; % 1 = flush quest history on start of a new run. 0 = resume Quest including previous runs trial history.
switch params.expe

    case 'age'
        
        KbName('UnifyKeyNames');
        params.nCatFts        = 300; % 10 % of the top 3000 gabors
        params.cond1label = 'adults';
        params.cond2label = 'kids';
        
        % read in the instructions
        instructionPath = fullfile(startPath,'instructions');
        f = fopen(fullfile(instructionPath,'instructions_age.txt'));
        instructions   = fread(f,'*char')';
        fclose(f);
        
        resultsDir = fullfile(resultsPath,params.sID,'childVSadult');
        if ~exist(resultsDir,'dir')
            mkdir(resultsDir);
        end
        
        params.key1 = 'p';
        params.key2 = 'q';    
        
        switch params.expe
            case'age'
                params.code1 = KbName(params.key1); % p for adults
                params.code2 = KbName(params.key2); % q for kids
        end
        
        
        params.code7 = KbName('escape');
        params.code8 = KbName('return');
        params.code9 = KbName('space');
        
end

params.resultsDir = resultsDir;


% load the params
fnames      = dir(fullfile(featurePath,'*.mat'));

params.nCats  = numel(fnames);

params.ImGabParams    = zeros(params.nFts,6,params.nCats);

params.featurePath = featurePath;
[params.gabvects,params.ImGabParams] = importFeatureSpace_v3(fnames,params);

% colors for the lettering of the teams.
params.cond1col = [20 10 255];
params.cond2col = [255 140 0];

params.nTrials      =(params.nCats)*params.CatReps;
params.duration     = 2;    % duration is mapped in frames
params.resptime     = 2;    % 3 seconds to respond
params.soa          = .250;

switch CFG
    case 'Cubicle'
        ptb_path='C:\toolbox\Psychtoolbox';
        addpath((ptb_path))
        
        startPath = 'c:\experiments\perceptualFingerprint';
        resolutionScreen	= [1920 1080];
        monitor.resolution  = resolutionScreen;
        monitor.width       = 677; % mm
        monitor.height      = 381; % cm
        monitor.viewdist	= 700; % cm
        monitor.hz          = 60; % cm
        params.monitor	= monitor;
        
    case 'MacMini'
        resolutionScreen    = [1920 1080];
        monitor.resolution  = resolutionScreen;
        monitor.width       = 597; % mm
        monitor.height      = 336; % mm
        monitor.viewdist    = 700; % mm
        monitor.hz          = 60; % Hz
        params.monitor      = monitor;
        params.startPath    = startPath;
        
    case 'LaptopSimon'
        resolutionScreen    = [1440 1080];
        monitor.resolution  = resolutionScreen;
        monitor.width       = 331; % mm
        monitor.height      = 206; % mm
        monitor.viewdist    = 700; % mm
        monitor.hz          = 60; % Hz
        params.monitor      = monitor;
        params.startPath    = startPath;
       
end

% load the scene for background
sceneImg = rgb2gray(imread(fullfile('grass_scene.jpg')));
%[sceneH,sceneW] = size(sceneImg);

% update params struct
params.resultsPath      = resultsPath;
params.instructionPath  = instructionPath;
params.instructions     = instructions;
params.sceneImg         = sceneImg;

% Calculate image size
img.sizedeg    = stimsize_deg;  %deg
[sizex,sizey]  = visangle2stimsize(img.sizedeg,img.sizedeg,monitor.viewdist,monitor.width,monitor.resolution(1)); %visAng2xyNew(fix.sizedeg,monitor,fix.sizedeg./2);

% update params struct
params.sizex    = sizex;
params.sizey    = sizey;
params.sizexsmall = sizex/2;
params.sizeysmall = sizey/2;

%% GET TO ACTUAL EXPERIMENT

% CHECK PTB IS PROPERLY INSTALLED
% ---------------------------------
PsychDefaultSetup(1); % do some basic test, check if mex files there and properly installed, etc.

AssertOpenGL;
Screen('Preference','SkipSyncTests', 1);
Screen('Preference', 'Verbosity', 3);
Screen('Preference', 'Enable3DGraphics', 1);

params.clock = clock; 					% to recreate the stimulation sequence later
% Get generator settings.
rng('shuffle');
params.rng = rng;


% Restore previous generator
% settings.
% rng(params.rng);

% check screen pc settings against user settings
nominalPar = Screen('Resolution', max(Screen('Screens')));
[nominalWidth_mm, nominalHeight_mm] = Screen('DisplaySize', max(Screen('Screens')));

params.monitor.nominal = nominalPar;
params.monitor.nominal.resolution = [params.ImSize params.ImSize];
params.monitor.nominal.width = nominalWidth_mm;
params.monitor.nominal.height = nominalHeight_mm;

try
    %% SET UP SCREEN AND GET READY FOR BLOCKS
    [WINDOW, win_rect] = Screen('OpenWindow',max(Screen('Screens')), [1 1 1],[0 0 resolutionScreen]);
    [xcenter, ycenter] = RectCenter(win_rect);
    % win_rect(3) = WIDTH
    % win_rect(4) = HEIGHT
    PriorityMax=MaxPriority(WINDOW);
    Priority(PriorityMax);
    slack = Screen('getFlipInterval', WINDOW) /2; % important for timing! Slack is half your refresh rate!
    
    Screen('BlendFunction', WINDOW, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);   % enables alpha blending
    
    params.slack	= slack;
    params.WINDOW	= WINDOW;
    params.win_rect = win_rect;
    params.xcenter	= xcenter;
    params.ycenter	= ycenter;
    
    % this will bring keyboard in command window
    commandwindow;
    
    % define some font specs
    font    = 'Arial';
    f_size  = 18;
    f_style = 1; %bold
    
    % define what size the text will be presented at (text settings)11
    Screen('TextFont', WINDOW, font);
    Screen('TextSize', WINDOW, f_size);
    Screen('TextStyle', WINDOW, f_style);
    BLACK       = BlackIndex(WINDOW);
    WHITE       = WhiteIndex(WINDOW);
    GRAY        = GrayIndex(WINDOW);
    background  = repmat(GRAY,1,3);
    
    params.background   = background;
    params.font         = font;
    params.f_size       = f_size;
    params.f_style      = f_style;
    params.BLACK        = BLACK;
    params.WHITE        = WHITE;
    params.GRAY         = GRAY;
    
    
    % use functions that are laggy on first use... !!!warm up cold code
    %(functions need to be compiled once!)
    HideCursor;
    WaitSecs(0.01);
    
    % draw text for first time because it's laggy otherwise (it won't show
    % on the screen
    DrawFormattedText(WINDOW, 'word', 'center', 'center', GRAY);
    Screen('FillRect', WINDOW , GRAY ,win_rect);
    
    priorityLevel = MaxPriority(WINDOW);
    Priority(priorityLevel);
    HideCursor;
    
    Screen('FillRect', WINDOW, background);
    Screen('TextSize', WINDOW, f_size);
    Screen('TextFont', WINDOW, font);
    
    % load background image
    sceneTex  = Screen('MakeTexture', WINDOW, sceneImg);
    
    Screen('DrawTexture', WINDOW, sceneTex);
    DrawFormattedText(WINDOW, 'Please pay attention to the task instructions', 'center', ycenter-200, WHITE);
    onset = Screen('Flip', WINDOW);
    requested_onset = onset +1;
    
    % prepare a general background offscreen window
    backgroundWindow = Screen('OpenOffscreenWindow', WINDOW, 0, win_rect);
    Screen('TextSize', backgroundWindow, 18);
    Screen('FillRect', backgroundWindow , background ,win_rect);
    Screen('DrawTexture', backgroundWindow, sceneTex);
    
    % prepare an instructions offscreen window
    instructionWindow = Screen('OpenOffscreenWindow', WINDOW, 0, win_rect);
    Screen('TextSize', instructionWindow, 18);
    Screen('FillRect', instructionWindow , background ,win_rect);
    DrawFormattedText(instructionWindow, instructions, 'center', 'center', WHITE,80,[],[],3);
    
    inst3 = Screen('OpenOffscreenWindow', WINDOW, 0, win_rect);
    Screen('FillRect', inst3, background ,win_rect);
    Screen('TextFont', inst3, 'Courier New');
    Screen('TextSize', inst3, 50);
    Screen('TextStyle', inst3, 1+2);
    DrawFormattedText(inst3, 'let''s start!', 'center', 'center', WHITE,80,[],[],3);
    Screen('TextSize', inst3, 30);
    DrawFormattedText(inst3, 'press spacebar to continue', 'center', ycenter + (params.sizey/2) + 100, WHITE,80,[],[],3);
    
    % copy the offscreen window to the main window and flip them up now.
    Screen('CopyWindow',instructionWindow,WINDOW,win_rect, win_rect);
    onset = Screen('Flip', WINDOW, requested_onset - slack);
    
    % wait for them to press spacebar
    WaitForResponse(params.code9);
    requested_onset = GetSecs  + 1;
    
    %% START EXPERIMENT: USE nBLOCKS + 1 because first block is always practice
    AbortExp    = 0;
    
    params = startOrResume(params);
    runI   = params.runI;
    
    params.ncompletedruns=0;
    while runI<=nRepetitions  && AbortExp == 0
        
        
        % child vs adult feature task
        
        
        % ENABLE BREAKING THE EXPERIMENT ALTOGETHER
        [keyIsDown,TimeSecs,AnswerkeyCode] = KbCheck;
        if keyIsDown && AnswerkeyCode(params.code7)
            
            % OPTION TO QUIT THE EPERIMENT OR CANCEL
            Screen('CopyWindow',backgroundWindow,WINDOW,win_rect, win_rect);
            DrawFormattedText(WINDOW, 'Are you sure you want to Quit?', 'center', 'center', WHITE,80,[],[],3);
            DrawFormattedText(WINDOW, 'Press Q to confirm or C to cancel', 'center', ycenter+100, WHITE,80,[],[],3);
            onset = Screen('Flip', WINDOW);
            
            waiting = 1;
            while(waiting)
                [keyIsDown,TimeStamp,keyCode] = KbCheck;
                if keyIsDown && keyCode(KbName('q'))
                    waiting = 0;
                    AbortExp = 1;
                    break;
                elseif keyIsDown && keyCode(KbName('c'))
                    waiting = 0;
                end
            end
        end
        if AbortExp == 1
            break;
        end
        
        % initiate run specific parameters
        params.TrialOrder     = floor(1:1/params.CatReps:params.nCats+1-(1/params.CatReps));
        params.SelFtsPerTrial = zeros(params.nTrials,params.nFts);
        params.Ratings        = zeros(size(params.TrialOrder));
        params.RTs            = zeros(size(params.TrialOrder));
        params.TrialOrder     = params.TrialOrder(randperm(params.nTrials));
        switch params.expe
            case 'age'
              % 1:8 --> kid 9:16 --> adults
                params.Cond1Cond2     = (params.TrialOrder>params.nCats/2)+1;params.Cond1Cond2(params.TrialOrder==0)=0;
        end
        params.runI           = runI;
        
        % start the experiment
        params                = run_subjective_features_v2(params);
        params.ncompletedruns = params.ncompletedruns+1;
        
        outparams = params;
        % clean up some fields in params.
        outparams            = rmfield(outparams,'displ');
        % to save on storage space, let's use importFeatureSpace_v3 in analysis to get the gabor vectors and params back.
        outparams            = rmfield(outparams,'gabvects');
        outparams            = rmfield(outparams,'ImGabParams');
        
        % SAVE PARAMS STRUCT
        paramsPath = fullfile(resultsDir,sprintf('parameters_%s_run%d.mat',params.sID,runI));
        save(paramsPath,'outparams');
        clear outparams;
        
        % PROCEED TO NEXT  RUN
        runI = runI + 1;
        
        if runI <= nRepetitions
            % >>> draw a scene here.
            % the block is over, give them the option to see instructions again, or take a short break.
            % DrawFormattedText(WINDOW, 'Press spacebar for next run or press return to see the task instructions again', 'center', 'center', WHITE);
            Screen('CopyWindow',backgroundWindow,WINDOW,win_rect, win_rect);
            DrawFormattedText(WINDOW, 'Press spacebar for next run or', 'center', ycenter, WHITE,80,[],[],3);
            DrawFormattedText(WINDOW, 'press return to see the task instructions again', 'center', ycenter+50, WHITE,80,[],[],3);
            DrawFormattedText(WINDOW, 'Press Esc to quit', 'center', ycenter+100, WHITE,80,[],[],3);
            
            onset = Screen('Flip', WINDOW);
            
            % GIVE THE PARTICIPANT THE CHOICE OF REVIEWING INSTRUCTIONS OR MOVING TO THE NEXT RUN
            waiting = 1;
            while(waiting)
                
                [~, secs, keyCode]= KbCheck;
                
                if keyCode(1,params.code9)
                    % MOVING TO THE NEXT RUN WITHOUT REVIEWING THE INSTRUCTIONS
                    Screen('CopyWindow',backgroundWindow,WINDOW,win_rect, win_rect);
                    DrawFormattedText(WINDOW, sprintf('Great! Starting run no: %d/%d',runI,nRepetitions), 'center', 'center', WHITE);
                    onset = Screen('Flip', WINDOW);
                    WaitSecs(2);
                    waiting = 0;
                    
                elseif keyCode(1,params.code7)
                    % OPTION TO QUIT OR CANCEL
                    Screen('CopyWindow',backgroundWindow,WINDOW,win_rect, win_rect);
                    DrawFormattedText(WINDOW, 'Are you sure you want to Quit?', 'center', 'center', WHITE,80,[],[],3);
                    DrawFormattedText(WINDOW, 'Press Q to confirm or C to cancel', 'center', ycenter+100, WHITE,80,[],[],3);
                    onset = Screen('Flip', WINDOW);
                    waiting = 1;
                    while(waiting)
                        [keyIsDown,TimeStamp,keyCode] = KbCheck;
                        if keyIsDown && keyCode(KbName('q'))
                            waiting 	= 0;
                            AbortExp 	= 1;
                            break;
                        elseif keyIsDown && keyCode(KbName('c'))
                            Screen('CopyWindow',backgroundWindow,WINDOW,win_rect, win_rect);
                            Screen('TextSize', WINDOW, 18);
                            DrawFormattedText(WINDOW, 'Press spacebar for next run or', 'center', ycenter, WHITE,80,[],[],3);
                            DrawFormattedText(WINDOW, 'press return to see the task instructions again', 'center', ycenter+50, WHITE,80,[],[],3);
                            DrawFormattedText(WINDOW, 'Press Esc to quit', 'center', ycenter+100, WHITE,80,[],[],3);
                            onset = Screen('Flip', WINDOW);
                            waiting = 0;
                        end
                    end
                    
                elseif keyCode(1,params.code8)
                    
                    % REVIEWING INSTRUCTIONS BEFORE MOVING TO THE NEXT RUN
                    Screen('CopyWindow',instructionWindow,WINDOW,win_rect, win_rect);
                    onset = Screen('Flip', WINDOW);
                    
                    WaitForResponse(params.code9);  % wait for them to press spacebar
                    WaitSecs(1);
                    
                    Screen('CopyWindow',backgroundWindow,WINDOW,win_rect, win_rect);
                    DrawFormattedText(WINDOW, sprintf('Great! Starting block %d run no: %d/%d',blockNo,runI,nRepetitions), 'center', 'center', WHITE);
                    onset = Screen('Flip', WINDOW);
                    WaitSecs(2);
                    waiting = 0;
                end
            end
        end
        
    end
    
    % SHOW GOODBYES
    Screen('CopyWindow',backgroundWindow,WINDOW,win_rect, win_rect);
    DrawFormattedText(WINDOW, 'Thank you...you can relax now!', 'center', 'center', WHITE);
    vbl = Screen('Flip',WINDOW);
    WaitSecs(5);
    
    % CLOSE PSYCHTOOLBOX
    Screen('Close');
    ShowCursor;
    Screen('CloseAll');
    Priority(0);
    
    
catch
    % catch error: This is executed in case something goes wrong in the
    % 'try' part due to programming error etc.:
    % Do same cleanup as at the end of a regular session...
    
    % CLOSE EXT CONNECTIONS
    
    % CLOSE PSYCHTOOLBOX
    Screen('CloseAll');
    sca;
    ShowCursor;
    fclose('all');
    Priority(0);
    % Output the error message that describes the error:
    psychrethrow(psychlasterror);
    
end % try ... catch %


%% test it out
%{
if showplots==1
    
    allMemRTs=[];
    allMemTrialOrder=[];
    allMemSelFtsPerTrial=[];
    
    for runI=1:params.ncompletedruns;
        load(fullfile(resultsDir,sprintf('parameters_%s_run%d.mat',params.sID,runI)));
        MemSelFtsPerTrial=params.SelFtsPerTrial;
        MemTrialOrder=params.TrialOrder;
        for trialI=1:length(params.trials)
            MemRTs(trialI)= params.trials(trialI).rt;
        end
        
        allMemSelFtsPerTrial=[allMemSelFtsPerTrial;MemSelFtsPerTrial];
        allMemTrialOrder=[allMemTrialOrder MemTrialOrder];
        allMemRTs=[allMemRTs MemRTs];
        % RTs=[MemRTs RTs];%(RTs-median(RTs))];
    end
    SelFtsPerTrial=allMemSelFtsPerTrial;
    TrialOrder=allMemTrialOrder;
    RTs=allMemRTs;
    % clean up for excessively slow trials
    RTs(abs(RTs-mean(RTs))>(2*std(RTs)))=NaN;
    
    FtScores=zeros(params.nFts,params.nCats);
    FtScoresOdd=zeros(params.nFts,params.nCats);
    FtScoresEven=zeros(params.nFts,params.nCats);
    sel=randperm(numel(TrialOrder));
    OddRef=zeros(size(TrialOrder));OddRef(sel(1:2:end))=1;
    
    for im=1:params.nCats
        perf=mean(CorrResp(TrialOrder==im))
        for ft=1:params.nFts
            FtScores(ft,im) = sum(SelFtsPerTrial(:,ft)'==1&CorrResp==1&TrialOrder==im)/sum(SelFtsPerTrial(:,ft)'==1&CorrResp==0&TrialOrder==im);
            %FtScores(ft,im)= nanmean(RTs(SelFtsPerTrial(:,ft)'==1&CorrResp==1&TrialOrder==im));
            
            FtScoresOdd(ft,im)=sum(SelFtsPerTrial(:,ft)'==1&CorrResp==1&TrialOrder==im&OddRef==1)/sum(SelFtsPerTrial(:,ft)'==1&CorrResp==0&TrialOrder==im&OddRef==1);
            %FtScoresOdd(ft,im)=nanmean(RTs(SelFtsPerTrial(:,ft)'==1&CorrResp==1&TrialOrder==im&OddRef==1));
            FtScoresEven(ft,im)=sum(SelFtsPerTrial(:,ft)'==1&CorrResp==1&TrialOrder==im&OddRef==0)/sum(SelFtsPerTrial(:,ft)'==1&CorrResp==0&TrialOrder==im&OddRef==0);
            %FtScoresEven(ft,im)=nanmean(RTs(SelFtsPerTrial(:,ft)'==1&CorrResp==1&TrialOrder==im&OddRef==0));
        end
    end
    FtScores(isinf(FtScores))=max(FtScores(~isinf(FtScores)))+1;
    FtScoresOdd(isinf(FtScoresOdd))=max(FtScoresOdd(~isinf(FtScoresOdd)))+1;
    FtScoresEven(isinf(FtScoresEven))=max(FtScoresEven(~isinf(FtScoresEven)))+1;
    
    EvenVect=FtScoresEven(:); OddVect=FtScoresOdd(:);
    rem=isnan(EvenVect)|isnan(OddVect);
    [rho,p]=corr(EvenVect(rem==0),  OddVect(rem==0) );
    
    % test-retest reliability?
    corrmat = corr(FtScoresOdd,FtScoresEven,'type','Pearson','rows','pairwise');
    figure; imagesc(corrmat)
    % not great!
    
    displ=zeros(params.ImSize);
    %displ_w=zeros(params.ImSize);
    for c=1:params.nCats
        figure;
        % this is not working yet, but the idea is to weigh the
        % gaborvectors by the feature scores.
        temp = params.gabvects(:,:,c);
        for ft=1:1000
            weightedVects(:,ft) = temp(:,ft).*FtScores(ft,c);
        end
        displ(:)=sum(weightedVects,2);
        %displ = displ+abs(min(displ(:)));
        %displ = (displ./max(displ(:)));
        imagesc(displ);
        %displ_r(:)=sum(squeeze(params.gabvects(:,:,c)),2).*repmat(squeeze(FtScores(:,c)),1,size(params.gabvects,1))';
    end
    
    displ_r=zeros(params.ImSize);
    displ_w=zeros(params.ImSize);
    TopFts=300;
    for c=1:params.nCats
        [vals, inds]=sort(FtScores(:,c));
        figure;
        subplot(2,1,1);
        displ_r(:)=sum(params.gabvects(:,inds(1:TopFts),c),2);
        imagesc(displ_r); title(['best ' num2str(TopFts) ' Features']);
        colormap('gray'); axis square; drawnow;
        
        subplot(2,1,2);
        [vals, inds]=sort(FtScores(:,c),'descend');
        displ_w(:)=sum(params.gabvects(:,inds(1:TopFts),c),2);
        imagesc(displ_w); title(['worst ' num2str(TopFts) ' Features']);
        colormap('gray'); axis square; drawnow;
    end
end
%}