function [ params ] = run_subjective_features_v2(params)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

sID             = params.sID;
resultsDir      = params.resultsDir;

soa             = params.soa;
runI            = params.runI;
nTrials         = params.nTrials;

nFts            = params.nFts;
nCatFts         = params.nCatFts;
Ratings         = params.Ratings;
TrialOrder      = params.TrialOrder;
Cond1Cond2      = params.Cond1Cond2;
gabvects        = params.gabvects;
displ           = params.displ;
imgw            = params.sizex;
imgh            = params.sizey;

% screen parameters
WINDOW          = params.WINDOW;
win_rect        = params.win_rect;
slack           = params.slack;
WHITE           = params.WHITE;
GRAY            = params.GRAY;
xcenter         = params.xcenter;
ycenter         = params.ycenter;


% KEYS
code1 = params.code1;  % 'adults'
code2 = params.code2;  % 'kids'
code7 = params.code7;  % 'escape';

objectRect              = [ xcenter-imgw/2 ycenter-imgh/2 ...
    xcenter+imgw/2 ycenter+imgh/2];

%% CREATE VECTORS FOR PSEUDO RANDOM TRIAL SELECTION
PsrandVects=cell(params.nCats,1);
for im=1:params.nCats 
    PsrandVects{im} = randperm(params.nFts);
end
    
% INIT TRIALS STRUCTURE

structFields = {'trialnumber',...
    'objectshown',...
    'trialtype',...
    'trialOnset',...
    'rt', ...
    'Ratings', ...
    'CorrectIncorrect',...
    'runNo',...
    'NbFeatures',...
    };

trials = struct('trialnumber',[],...
    'objectshown',  [], ...
    'trialtype', 	[], ...
    'trialOnset',   [], ...
    'rt',           [], ...
    'Ratings',       [], ...
    'CorrectIncorrect',[],...
    'runNo',        [], ...
    'NbFeatures', []);

trials = orderfields(trials, structFields);

format  = {'%d\t';...	% 'trialnumber'
    '%d\t';...          % 'objectshown'
    '%d\t';...			% 'trialtype'
    '%3.4f\t';...       % 'trialOnset'
    '%f\t';...          % 'rt'
    '%d\t';...          % 'Ratings'
    '%d\t';...          % 'CorrectIncorrect'
    '%d\t';...          % 'runNo'
    '%d\t';...          % 'NbFeatures'
    };

%% SET UP STUDY OUTPUT FILE
StudyOutputDir      = resultsDir;
StudyOutputFileName = fullfile(StudyOutputDir,sprintf('log_%s_run%d.txt',sID,runI));
fid                 = fopen(StudyOutputFileName,'w+t'); % open as writeable text

% write data column headers to file
objectdatalabels = fieldnames(trials); % headers for the log files
for i=1:length(objectdatalabels)
    fprintf(fid,'%s\t',objectdatalabels{i});
end
fprintf(fid,'\n');

% GRAY FIXATION WINDOW
blackFixWindow = Screen('OpenOffscreenWindow', WINDOW, 0, win_rect);
fixRect = [xcenter-5 ycenter-5 xcenter+5 ycenter+5];
Screen('FillRect', blackFixWindow , GRAY ,win_rect);
Screen('FillOval', blackFixWindow, WHITE, fixRect);

% GRAY FIXATION WINDOW - RED dot
redFixWindow = Screen('OpenOffscreenWindow', WINDOW, 0, win_rect);
Screen('FillRect', redFixWindow , GRAY ,win_rect);
Screen('FillOval', redFixWindow, [225 25 0], fixRect);

% GRAY FIXATION WINDOW
greenFixWindow = Screen('OpenOffscreenWindow', WINDOW, 0, win_rect);
Screen('FillRect', greenFixWindow , GRAY ,win_rect);
Screen('FillOval', greenFixWindow, [80 220 100], fixRect);


taskpause = Screen('OpenOffscreenWindow', WINDOW, 0, win_rect);
Screen('FillRect', taskpause, GRAY,win_rect);
Screen('TextFont', taskpause, 'Courier New');
Screen('TextSize', taskpause, 50);
Screen('TextStyle', taskpause, 1+2);
%DrawFormattedText(taskpause, sprintf('%s or %s?',num2str(params.cond1label),num2str(params.cond2label)), 'center', 'center', WHITE,80,[],[],3);
DrawFormattedText(taskpause, sprintf('key %s for %s or key %s for %s.',params.key1,params.cond1label,params.key2,params.cond2label), 'center',ycenter + (imgh/2) -100, WHITE,80,[],[],3);
DrawFormattedText(taskpause, 'resume when ready', 'center', ycenter + (imgh/2) -50, WHITE,80,[],[],3);
Screen('TextSize', taskpause, 30);
DrawFormattedText(taskpause, 'press spacebar to continue', 'center', ycenter + (imgh/2) + 100, WHITE,80,[],[],3);


%% GET TO ACTUAL BLOCK
%Initialize QEST parameters, now adjusting QUEST over the % of total gabors
    Questy.tGuessSd=.0175; % After testing multiple thresholds, this seems to be a middleground between how fast it adjust to appropriate individual threshold and volatility due to delta (blind) responses.
    Questy.pThreshold=.75; % desired probability of accuracy for threshold
    Questy.beta=3.5; % Steepness of the sigmoid curve is typically 3.5 but differs for random sampling methods
    Questy.delta=.01;% probability that the observers answers were "blind" over trials. Typically .01
    Questy.gamma=.5; % Chance.
    Questy.range=.2; % any guess for what this should be? for now, its from tGuess-(range/2) to tGuess+(range/2) 

    
if runI==1 % sets QUEST's "best guess" threshold value  as the default number of features for each task (e.g. 75 for identity)
    
    NbFeaturesStart=nCatFts/params.nFts; % in % of total gabors
    Questy.tGuess=NbFeaturesStart;
    
    % Starts Quest
    Questy.q_test=QuestCreate(Questy.tGuess,Questy.tGuessSd,Questy.pThreshold,Questy.beta,Questy.delta,Questy.gamma,[],Questy.range);
    
else % sets QUEST's "best guess" threshold value as the number of features from last run

    LastPath = fullfile(resultsDir,sprintf('parameters_%s_run%d.mat',sID,runI-1));
    lastRun=load(LastPath);
    Questy.tGuess=lastRun.outparams.trials(end).NbFeatures/params.nFts; 
   
    if params.flushQuest
        % Starts Quest
        Questy.q_test=QuestCreate(Questy.tGuess,Questy.tGuessSd,Questy.pThreshold,Questy.beta,Questy.delta,Questy.gamma,[],Questy.range);
    else
        % continues Quest from last run, including trial history.
        Questy.q_test= lastRun.outparams.QUEST;
    end
    clear lastRun
end


Start                   = GetSecs();
onset                   = Start;
requested_objectonset   = onset;
AbortExp                = 0;
HideCursor;

%STORE TIME OF PAGE FLIPPING FOR DIAGNOSTIC PURPOSES
timing = [];
diagnostics = cell(1,nTrials);

for iTrial=1:nTrials
    
    
    if not(mod(iTrial,params.trialsprebreak))
        
        Screen('CopyWindow',taskpause,WINDOW,win_rect, win_rect);
        Screen('Flip', WINDOW);
        
        % wait for them to press spacebar
        WaitForResponse(params.code9);
        requested_objectonset = GetSecs  + 1;
        
    end
    
    
    % FIXATION: this will handle the baseline. 1s + 200ms jitter
    Screen('CopyWindow',blackFixWindow,WINDOW,win_rect,win_rect);
    [onset,StimulusOnsetTime,FlipTimestamp,Missed,Beampos] = Screen('Flip', WINDOW,requested_objectonset-slack);
    
    %STORE TIME OF PAGE FLIPPING FOR DIAGNOSTIC PURPOSES
    timing = [timing; onset,StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
    
    % jitter the soa a bit
    requested_objectonset = onset + (soa + randperm(200,1)/1000);
    
    % we adjust the number of features here depending on previous trials
    % here

    DisNbFeatures=ceil(QuestMean(Questy.q_test)*params.nFts);
    if DisNbFeatures<10,DisNbFeatures=10;end % makes sure nbFeatures is capped at 10
    trials(iTrial).NbFeatures=DisNbFeatures;
    
    % select the features to display    
    try
        SelFts=PsrandVects{TrialOrder(iTrial)}(1:DisNbFeatures);
        PsrandVects{TrialOrder(iTrial)}(1:DisNbFeatures)=[];
    catch
        SelFts=PsrandVects{TrialOrder(iTrial)}(1:end);
        nMissingFts=DisNbFeatures-numel(SelFts);
        PsrandVects{TrialOrder(iTrial)}=randperm(params.nFts);
        NonOverlapInds=find(ismember(PsrandVects{TrialOrder(iTrial)},SelFts)==0);
        SelFts(end+1:DisNbFeatures)=PsrandVects{TrialOrder(iTrial)}(NonOverlapInds(1:nMissingFts));
        PsrandVects{TrialOrder(iTrial)}(NonOverlapInds(1:nMissingFts))=[];
        
    end

    
    params.SelFtsPerTrial(iTrial,SelFts) = 1;
    displ(:)=sum(gabvects(:,SelFts,TrialOrder(iTrial)),2);
    displ = displ+abs(min(displ(:)));
    displ = (displ./max(displ(:))).*255;
%     displ = fliplr(displ);

    
    % generate the texture
    tex    = Screen('MakeTexture', WINDOW, displ);
    
    [keyIsDown,TimeSecs,AnswerkeyCode] = KbCheck;
    if keyIsDown && AnswerkeyCode(code7)
        AbortExp = 1;
        break;
    end
    
    % draw the texture on screen
    Screen('DrawTexture', WINDOW, tex,[],objectRect);
    [onset,StimulusOnsetTime,FlipTimestamp,Missed,Beampos] = Screen('Flip', WINDOW, (requested_objectonset) - slack);
    
    %STORE TIME OF PAGE FLIPPING FOR DIAGNOSTIC PURPOSES
    timing = [timing; onset,StimulusOnsetTime, FlipTimestamp, Missed, Beampos];
        
    trialOnset  = onset - Start;
    
    % STIMULUS STAYS ON UNTIL RESPONSE %
    % now we need to wait for a response
    key_input = 0;
    Now=GetSecs;
    while key_input == 0        
        [~, secs, keyCode] = KbCheck; % check for input
        if keyCode(1,code1)
            key_input	= code1;
            rt        = secs-onset;
            Ratings    = 1;
            responset   = secs;
        elseif keyCode(1,code2)
            key_input	= code2;
            rt          = secs-onset;
            Ratings      = 2;
            responset   = secs;        
        elseif keyCode(1,code7)
            AbortExp   = 1;
            Ratings    = NaN;
            responset  = GetSecs;
            rt = Inf;
            %sca;
            break;
        end
    end
    
    % enable trial log with short time..
    requested_objectonset = responset + 0.100;
    
    if Cond1Cond2(iTrial)==Ratings
        Acc=1;
        Screen('CopyWindow',greenFixWindow,WINDOW,win_rect,win_rect);
    else
        Acc=0;
        Screen('CopyWindow',redFixWindow,WINDOW,win_rect,win_rect);
    end  
%     Screen('CopyWindow',blackFixWindow,WINDOW,win_rect,win_rect);
    [onset,StimulusOnsetTime,FlipTimestamp,Missed,Beampos] = Screen('Flip', WINDOW,requested_objectonset-slack);
    
    % enable trial log with short time..
    requested_objectonset = onset + 0.250;
    
    trials(iTrial).trialnumber      = iTrial;
    trials(iTrial).trialOnset       = trialOnset;
    trials(iTrial).trialtype        = Cond1Cond2(iTrial);
    trials(iTrial).objectshown      = TrialOrder(iTrial);
    trials(iTrial).rt               = rt;
    trials(iTrial).Ratings          = Ratings;
    trials(iTrial).CorrectIncorrect = Acc;
    trials(iTrial).runNo            = runI;
      
   
    Questy.q_test=QuestUpdate(Questy.q_test,QuestMean(Questy.q_test),Acc);
    
    % WRITE TRIAL INFO IN A TXT FILE
    nFields = length(objectdatalabels);
    trials = orderfields(trials, structFields);
    
    for iField = 1:nFields
        fprintf(fid,format{iField},trials(iTrial).(structFields{iField}));
    end % for iField = 1:nFields
    fprintf(fid,'\n'); % get ready for next trial
    
    diagnostics{iTrial} = timing;
    
    if AbortExp; fclose('all');break; end
    
end % for trial loop

WaitSecs(2); %  1= force wait for actual pulse; 0=return this many ms after pulse
params.diagnostics  = diagnostics;
params.trials       = trials;
params.Start        = Start;
params.QUEST        = Questy.q_test;
fclose('all');

