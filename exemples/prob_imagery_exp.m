function y = prob_imagery_exp(subjectNumber)
%%Presented to Frédéric Gosselin as a final project for class
%%PSY2038-Programmation en neuroscience cognitive.

%Individuals do not make rational decisions when put in an economic context.
%This irrational decision-making is know to be  mainly due to cognitive biases 
%and heuristics, cognitive shortcuts that accelerate the decision-making process 
%(Kahneman and Tversky, 1979).One of theses cognitive biases is to overestimate 
%small probabilities and underestimate larger probabilities. 

%This experiment studies this biased small probability estimation in a 
%lottery context : the subject has to decide which of the two lotteries 
%presented (reward and probability of the reward) is more advantageous. 
%The 120 trials of this short experiment will be divided in 4 conditions :
% 1) reward+probability in a numeral representation (1000 - 1/30 000) 
% 2)reward+probability in a numeral and graphic representation 
%(1000 - 1000 white pixel image on black screen - 1/30 000 - 30 000 white 
%pixel image on black screen) 3)reward in a numeral representation and 
%probability in a numeral and graphic representation (1000 - 1/30 000- 
%30 000 white pixels) and 4) reward+probability in a graphic
%representation(1000 white pixels - 30 000 white pixels). The hypothesis is
%that subjects will make more rational decision with information presented
%graphically (i.e. will choose the lottery with the highest expected value)
%than with information presented numerically. The underlying hypothesis is
%that individuals underestimate large probabilities because of
%human's limited visual imagery, phenomenon that can be countered if
%presented with an accurate visual representation. Condition 2 and 4 test
%weither a combination of numeral-graphic representation is more beneficial
%than a single graphical representation while condition 1 and 2 test
%weither an additional graphical representation of the reward 
%also has an impact on rational decisions.

%In each condition, half of the trials have a small difference between
%the two expected values and half have a large difference. All probabilities 
%are based on real lottery probabilities in Quebec (see the
%Loto-Quebec website). The small-large difference trials are in a random order
%comparatively to the condition presentation order that is as follows to avoid the
%use of magnitude estimation from graphical trials on numerical trials 
%(especially condition 2 - 3 that lead to associations): 1 - 4 - 3 - 2.

%The experiment must be conducted in a quiet environment with a monitor having
%a screen resolution of 1920 x 1080 pixels or higher.No additional control 
%measures are required(e.g.complete darkness,head stand,monitor - retina distance).

%This function requires one input (subject number) to create
%and save a data matrix file per subject containing all collected information 
%useful for further analysis (trial number,condition number,high-low 
%expected value difference,presented lottery data, associated expected values,
%response,correct response, reponse times). Psychtoolbox needs to be
%downloaded to the Matlab environment as this code uses its functions.

%Valérie Daigneault, 06/12/2019, valerie.daigneault.2@umontreal.ca

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin ~= 1 %no blocks --> only 120 trials
    error ('Function requires 1 input (subject number)');
end

%Check for an already existing file

file = sprintf('prob_imagery_exp_%d', subjectNumber);
if fopen([file,'.mat'])>0
	warning('This filename already exists.')
    answer = input('Overwrite (y/n)? ', 's');
    if ~(strcmp(answer, 'y'))
        subjectNumber = str2double(input('New subject number: ', 's'));
        file = sprintf('prob_imagery_exp_%d', subjectNumber);
    end
end

Screen('Preference', 'SkipSyncTests', 1);

%Constants
nbconditions = 4; %number of conditions
condOrder = [1 4 3 2];% condition order presentation
nbHighEV = 1; %number of trials with large expected value difference per condition
nbLowEV = 1; % number of trials with small EV difference per condition
nbtrials = nbconditions*(nbHighEV + nbLowEV); %total number of trials
nbTrialCond = nbtrials/nbconditions; %number trials per condition
keyLot1 = 'a'; %lottery 1
keyLot2 = 'l'; %lottery 2
exitKey = 'v'; %closes program when on choice slide
condname =0;%name of condition;
riskAversionQ = 0; %answer to risk aversion likert scale (asked last)
instructionsE1 = [ %English instructions part1
    'The following experiment will present you with two different lotteries.\n'...
    'The loteries will be presented reward first and probability second.\n'...
    'Therefore,the first reward and probability representation is lotery 1 and the second is lottery 2.\n'...
    'Note that the reward and probability representations for both lotteries will not always be in numbers.\n'...
    'While Condition 1 does indeed present lotteries in this way,\n'...
    'Condition 2 presents rewards and probabilities graphically (dots on the screen),\n'...
    'Condition 3 presents rewards in numbers and probabilities both numerically and graphically,\n'...
    ' and Condition 4 presents rewards and probabilities both numerically and graphically.\n'...
    'The condition number and description will be presented at the beginning of each condition.\n\n'...
    'Be careful, the graphic probability representation shows the denominator(probability = 1/number of dots).\n\n'...
    'Press any key for the next instruction page'];
instructionsE2 =[%English instructions part2
     'Your task is to choose which of the two lotteries is the most advantageous.\n'...
     'Press a for lotery 1 and l for lotery 2.\n'...
     'You will be able to answer after seeing both lottery presentations.\n'...
     'However, once an answer is entered, it is not possible to change it.\n'...
     'Take note that you will have less than 5 seconds to make your choice.\n'...
     'There will a beep every second. Therefore, you ABSOLUTELY have to answer after the 4th one.\n\n\n'...
     'Press any  key to start the experiment']; 
 instructionsF1 = [ %French instructions part1
     'La présente expérience vous présentera deux loteries différentes.\n'...
     'Ces loteries seront présentées de la manière suivante: lot en premier et probabilité en deuxième.\n'...
     'Ainsi, la loterie 1 est la combinaison du premier lot et de la première probabilité\n'...
     ' et la loterie 2 est la combinaison du deuxième lot et de la deuxième probabilité.\n'...
     'Cependant, les lots et les probabilités ne seront pas toujours présentés en chiffres.\n'...
     'Bien que la Condition 1 les représente de cette façon,\n'...
     'la condition 2 présente les lots et les probabilités graphiquement à l''aide de points sur l''écran,\n'...
     'la condition 3 présente les lots en chiffres et les probabilités à la fois numériquement et graphiquement et \n'...
     'la condition 4 présente les lots et les probabilités à la fois numériquement et graphiquement.\n'...
     'Le numéro et la description des conditions seront présentés avant le début de chaque condition.\n\n'...
     'Faites attention, la représentation graphique des probabilités correspond au dénominateur (probabilité = 1/nombre de points).\n\n'...
     'Appuyer sur une touche pour la prochaine page d''instructions'];
 instructionsF2 = [ %French instructions part2
     'Votre tâche est de choisir laquelle des deux loteries est la plus avantageuse.\n'...
     'Appuyer sur a pour la loterie 1 et l pour la loterie 2.\n'...
     'Vous pourrez répondre à l''aide des touches une fois les deux loteries présentées.\n'...
     'Cependant, vous ne pourrez pas changer votre réponse une fois entrée.\n'...
     'Notez que vous aurez moins de 5 secondes pour faire un choix.\n'...
     'Il y aura un son à chaque seconde. Vous devez donc ABSOLUMENT répondre après le 4e.\n\n\n'...
     'Appuyer sur une touche pour commencer l''expérience'];
 condE1 = 'Rewards and probabilities in numbers';
 condF1 = 'Lots et probabilités en chiffres';
 condE2 = 'Rewards and probabilities presented graphically';
 condF2 = 'Lots et probabilités présentés graphiquement';
 condE3 = 'Rewards: numerically    probabilities: numerically and graphically';
 condF3 = 'Lots : numériquement    probabilités : numériquement et graphiquement';
 condE4 = 'Rewards and probabilities: numerically and graphically';
 condF4 = 'Lots et probabilités : numériquement et graphiquement';
lowEVmat = [[50	1105	3000	55492 %small EV difference stimuli matrix
5000	15464	25000	74941  %columns: reward1,probability1,reward2,probability2
55	1105	100	1641
40	1005	6000	112413
100	1411	20	235
5	44	50000	387197
5	44	50000	387197
430	11112	100	1841
50	619	1000	10325
5	63	25	261
3000	55492	100	1411
2	8	22	82
1000	37749	50	1105
5	86	200	2571
9	98	110841	967867
50	1006	75	1033
500	10112	75	1033
4	20	19	85
75	1033	20	205
3000	55492	80876	1017653
1000	37749	3000	55492
200	2571	5000	47238
950	59674	5000	113000
1500	60674	100	1841
535	10112	100	1211
1000	45674	3000	57654
45	1105	100	1411
465	10112	3500	45089
75	1133	10	100
1000	43098	6000	105000
1050	37749	600	9500
100	1841	18	196
50	1105	20	235
1000	37749	75	1033
75	1411	10	100
500	10112	10	100
18	235	110841	867342
250	781	5000	13464
1000	60674	100	1411
2	39	5000	47238
50	1105	10	100
10	199	5000	47238
1000	37749	20	235
500	78097	65098	910654
5	95	100	841
110841	1000000	10	56
3000	55492	225	1841
1000	60674	20	235
5	86	50000	387197
1000	60674	81634	912135
1000	37749	10	100
5000	113000	92340	776090
225000	914718	5000	15464
2	39	50000	387197
10	199	50000	387197
10	56	20	76
1000	3383	5000	13098
98765	878670	4	20
2	39	100	685
10	199	100	685
]];

highEVmat = [[5	44	200000	914718 %large EV difference stimuli matrix
5000	47238	200000	914718 % R1, 1/P1, R2 1/P2
25	169	2500	9556
200000	914718	275	803
3000	55492	10	56
500000	1000000	5	8
75	1033	4	20
100	1411	4	20
110841	1000000	20	82
50	1105	10	56
4500	120000	10	56
25	169	1000	3383
100	685	1000	3383
200	2031	3	12
200	8112	10	56
5	86	200000	914718
20	82	407654	1006456
75	1033	235675	1000000
25	169	250	800
5	44	1000	3383
1000	60674	4	20
25	169	25000	74941
100	685	25000	74941
100	1841	20	82
5000	47238	1000	3383
3000	55492	20	82
50000	387197	250	781
5000	95000	20	82
500	10112	20	82
25000	74941	100	189
100	1841	2	8
5000	15464	25	48
50000	387197	25000	74941
25000	74941	7	13
100	685	250	711
5000	15464	100	189
5	44	250	781
3000	68985	3	12
5	44	5000	15464
2500	67000	2	8
40	1305	20	82
5000	47238	250	781
250	781	7	13
5	44	25000	74941
5	50	250	781
1000	10325	250	781
5	50	5000	15464
25	261	250	781
1000	3383	25	48
5	63	250	816
25	261	5000	15464
5000	47238	25000	74941
100	685	4500	11987
1000	3383	100	189
1000	3383	7	13
200000	914718	25	48
1000	10325	5000	12354
110841	876453	500000	1010654
5	44	100	189
50	1105	5	8
]];



%Create data matrix
%Columns: 1)condition number (1-4-3-2) 2)EV condition 3)money lottery1 
%4)probability lottery1 5)money lottery2 6)probability lottery2 7)subject 
%response(key)8)rationally correct response(true/false) 9)response time 

%Random seed used to create graphic representations is saved in mat
%file later on(stimuli creation for condition 4-3-2)

datamat = zeros(nbtrials,9);

%Column 1
for ii = 0:nbconditions-1
    datamat(nbTrialCond*ii+1 :nbTrialCond*(ii+1),1) = condOrder(ii+1);
end

%Column 2
% 1 = low EV difference 2 = high EV difference
order(1:nbLowEV) = 1;
order(nbLowEV +1 : nbHighEV + nbLowEV) = 2;
for ii = 0:nbconditions-1
    order = order(randperm(length(order)));
    datamat(nbTrialCond*ii+1 : nbTrialCond*(ii+1),2) = order;
end

%Column 3,4,5,6
lowEVIndex = randperm(nbLowEV*nbconditions);
highEVIndex = randperm(nbHighEV*nbconditions);
Lot1Lot2Order = round(rand(nbtrials));%determines which lottery is lottery1 and lottery2
lowCount = 1;
highCount = 1;
for ii = 1:nbtrials
    if datamat(ii,2) == 1
        if Lot1Lot2Order(ii) == 0
            datamat(ii,3) = lowEVmat(lowEVIndex(lowCount),1);
            datamat(ii,4) = lowEVmat(lowEVIndex(lowCount),2);
            datamat(ii,5) = lowEVmat(lowEVIndex(lowCount),3);
            datamat(ii,6) = lowEVmat(lowEVIndex(lowCount),4);
        else
            datamat(ii,5) = lowEVmat(lowEVIndex(lowCount),1);
            datamat(ii,6) = lowEVmat(lowEVIndex(lowCount),2);
            datamat(ii,3) = lowEVmat(lowEVIndex(lowCount),3);
            datamat(ii,4) = lowEVmat(lowEVIndex(lowCount),4);
            
        end
        lowCount = lowCount+1;
    end
    if datamat(ii,2) == 2
        if Lot1Lot2Order(ii) == 0
            datamat(ii,3) = highEVmat(highEVIndex(highCount),1);
            datamat(ii,4) = highEVmat(highEVIndex(highCount),2);
            datamat(ii,5) = highEVmat(highEVIndex(highCount),3);
            datamat(ii,6) = highEVmat(highEVIndex(highCount),4);
        else
            datamat(ii,5) = highEVmat(highEVIndex(highCount),1);
            datamat(ii,6) = highEVmat(highEVIndex(highCount),2);
            datamat(ii,3) = highEVmat(highEVIndex(highCount),3);
            datamat(ii,4) = highEVmat(highEVIndex(highCount),4);
        end
        highCount = highCount+1;
    end
        
end

%Column 7,8,9 : subject response related measures
%saved and updated during subject testing


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Experimental sequence

%Psychtoolbox window

AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);
[windowPtr,rect]=Screen('OpenWindow',screenNumber);
HideCursor; 
ListenChar(2); %supression of keyboard responses in command window

%Instructions (English or French)
DrawFormattedText(windowPtr,'Press e for English\n Appuyer sur f pour l''affichage en français' ,'center','center');
Screen('Flip', windowPtr);
FlushEvents('keyDown');
[secs, keyCode] = KbWait([], 2); %language selection

if strcmp(KbName(keyCode), 'e')
    DrawFormattedText(windowPtr,instructionsE1,'center','center',[],80);
    Screen('Flip', windowPtr);
else 
    DrawFormattedText(windowPtr,instructionsF1,'center','center',[],80);
    Screen('Flip', windowPtr);
end
     
FlushEvents('keyDown');
[secs, keyCode1] = KbWait([], 2); % subject ready for second instruction page


if strcmp(KbName(keyCode), 'e')
    DrawFormattedText(windowPtr,instructionsE2,'center','center',[],80);
    Screen('Flip', windowPtr);
   
else
    DrawFormattedText(windowPtr,instructionsF2,'center','center',[],80);
    Screen('Flip', windowPtr);
end

FlushEvents('keyDown');
[secs, keyCode1] = KbWait([], 2); %subject ready for start of experiment


%Experimental loop

rng('shuffle');
scurr = rng;

for ii = 1:nbtrials 
    
    %Stimuli creation
    %Depends on condition
    
    
    %Condition 1
    if datamat(ii,1) == 1 
        stimuli{1} = sprintf('%d $',datamat(ii,3));%reward1
        stimuli{2} = sprintf('1/%d',datamat(ii,4));% probability1
        stimuli{3} = sprintf('%d $',datamat(ii,5));%reward2
        stimuli{4} = sprintf('1/%d',datamat(ii,6));%probability2
    end
    
    %Condition 4
    if datamat(ii,1) == 4 
        for jj = 1:4 %4 different graphic stimuli
            graphic = graphical_stim();
            stimuli{jj} = Screen('MakeTexture', windowPtr, im2uint8(graphic)); %R1,P1,R2,P2
        end
    end
    
    %Condition 3
    if datamat(ii,1) == 3
        stimuli{1} = sprintf('%d $',datamat(ii,3));%reward1;
        stimuli{2} = sprintf('1/%d',datamat(ii,4));%probability1
        stimuli{4} = sprintf('%d $',datamat(ii,5));%reward2
        stimuli{5} = sprintf('1/%d',datamat(ii,6)); %probability2
        for jj = 2:2:4 % two different stimuli
            graphic = graphical_stim();
            if jj == 2
                stimuli{3} = Screen('MakeTexture',windowPtr, im2uint8(graphic));
            end
            if jj == 4
                stimuli{6} = Screen('MakeTexture',windowPtr, im2uint8(graphic));
            end
        end  
    end
    
    %Condition 2
    if datamat(ii,1) == 2
        stimuli{1} = sprintf('%d $',datamat(ii,3));%reward1;
        stimuli{3} = sprintf('1/%d',datamat(ii,4));%probability1
        stimuli{5} = sprintf('%d $',datamat(ii,5)); %reward2
        stimuli{7} = sprintf('1/%d',datamat(ii,6)); %probability2
        for jj = 1:4
            graphic = graphical_stim();
            stimuli{jj+jj} = Screen('MakeTexture',windowPtr, im2uint8(graphic));
        end   
    end
    
    
    
    %Stimuli presentation
    
    %Presents new condition if beginning of new condition
    if ((ii == 1)||(datamat(ii-1,1)~= datamat(ii,1)))
        condname = condname +1;
        cond = sprintf('Condition %d',condname);
        DrawFormattedText(windowPtr,cond,'center','center');
        if strcmp(KbName(keyCode), 'e')
            if datamat(ii,1)== 1
                DrawFormattedText(windowPtr,condE1,'center',800);
            elseif datamat(ii,1) == 4
                DrawFormattedText(windowPtr,condE2,'center',800);
            elseif datamat(ii,1) == 3 
                DrawFormattedText(windowPtr,condE3,'center',800);
            else
                DrawFormattedText(windowPtr,condE4,'center',800);
            end
        else
            if datamat(ii,1)== 1
                DrawFormattedText(windowPtr,condF1,'center',800);
            elseif datamat(ii,1) == 4
                DrawFormattedText(windowPtr,condF2,'center',800);
            elseif datamat(ii,1) == 3 
                DrawFormattedText(windowPtr,condF3,'center',800);
            else
                DrawFormattedText(windowPtr,condF4,'center',800);
            end      
        end
            Screen('Flip', windowPtr);
            WaitSecs(5);
    end
    
    %Lottery1 slide
    if strcmp(KbName(keyCode), 'e')
         DrawFormattedText(windowPtr,'Lottery 1','center','center');
    else
         DrawFormattedText(windowPtr,'Loterie 1','center','center');
    end
    Screen('Flip', windowPtr);
    WaitSecs(0.75);
    
    %Lottery1 stimuli
    for zz = 1:((numel(stimuli))/2)
        if ischar(stimuli{zz})
            DrawFormattedText(windowPtr,stimuli{zz},'center','center');
        else
            Screen('DrawTexture',windowPtr, stimuli{zz});
        end
        Screen('Flip', windowPtr);
        WaitSecs(1.5);
    end
    
    %Lottery2 slide
    if strcmp(KbName(keyCode), 'e')
         DrawFormattedText(windowPtr,'Lottery 2','center','center');
    else
         DrawFormattedText(windowPtr,'Loterie 2','center','center');
    end
    Screen('Flip', windowPtr);
    WaitSecs(0.75);
    
    %Lottery2 stimuli
    for zz = (((numel(stimuli))/2)+1): numel(stimuli)
        if ischar(stimuli{zz})
            DrawFormattedText(windowPtr,stimuli{zz},'center','center');
        else
            Screen('DrawTexture',windowPtr, stimuli{zz});
        end
        Screen('Flip', windowPtr);
        WaitSecs(1.5);
    end
    
    %Choice slide
    if strcmp(KbName(keyCode), 'e')
         DrawFormattedText(windowPtr,'Lottery 1 (a) or Lottery 2 (l)','center','center');
    else
         DrawFormattedText(windowPtr,'Loterie 1 (a) ou Loterie 2 (l)','center','center');
    end
    
    if datamat(ii,1) ~= 4
        tt1 = sprintf('%d $', datamat(ii,3));
        tt2 = sprintf('1/%d', datamat(ii,4));
        tt3 = sprintf('%d $', datamat(ii,5));
        tt4 = sprintf('1/%d', datamat(ii,6));
        ttSpace = '   ';
        DrawFormattedText(windowPtr, [tt1 ttSpace tt2 ttSpace ttSpace tt3 ttSpace tt4],'center',800);
    end
    Screen('Flip', windowPtr);
    
    %Recording of behavioral responses
    FlushEvents('keyDown');
    startSecs = GetSecs;
    newSecs = startSecs;
    beepCount = 0;
    
    while 1
    [keyIsDown, secs, keyCode1] = KbCheck();
    
        if keyIsDown % if a key is pressed
            
            if strcmp(KbName(keyCode1), keyLot1)
                datamat(ii,7) = keyLot1;
                datamat(ii,9) = secs-startSecs;
                if (datamat(ii,3)*(1/datamat(ii,4)))>(datamat(ii,5)*(1/datamat(ii,6)))
                    datamat(ii,8) = 1;
                end
                break;
            elseif strcmp(KbName(keyCode1), keyLot2)
                datamat(ii,7) = keyLot2;
                datamat(ii,9) = secs-startSecs;
                if (datamat(ii,5)*(1/datamat(ii,6)))>(datamat(ii,3)*(1/datamat(ii,4)))
                    datamat(ii,8) = 1;
                end
                break;
            elseif strcmp(KbName(keyCode1), exitKey)
                sca;
                ListenChar;
                ShowCursor;
                error('Exit key was pressed');
            end
            
        else %if no key is pressed
            
        %Maximum 5 second response delay-> subjects don't have time to calculate the 2 EV
        %If no time limit, subject could calculate 2 EV on every trials and
        %have 100% correct -> don't want to measure math skills but mental
        %representations of small probabiliies
        %Bip every second to diminush number of late responses
        
            
            if secs-newSecs > 1 
                newSecs = GetSecs;
                Beep = MakeBeep(220, 0.15);%low-pitched sound to lessen impact on attention
                Snd('Play', Beep);
                beepCount = beepCount+1;
                if beepCount == 5
                    break;
                end
            end    
        end     
    end %end behavioral response recording loop
    
    FlushEvents('keyDown');
    
    %save datamat
    save(file,'datamat','scurr','riskAversionQ');% saves datamatrix 
                     %and random seed to recreate graphic stimuli if needed
        
end % end of experimental loop

%Risk Aversion Question
Screen('FillRect', windowPtr,[255 255 255]);
WaitSecs(1);
if strcmp(KbName(keyCode), 'e')
     DrawFormattedText(windowPtr,'Risk Aversion Question','center',250);
     DrawFormattedText(windowPtr,'On a scale of 1 to 5 (1: lowest 5: highest),\ndo you like taking risks?','center','center');
     DrawFormattedText(windowPtr,'Answer with keyboard keys','center',850);
else
     DrawFormattedText(windowPtr,'Question sur l''aversion au risque','center',250);
     DrawFormattedText(windowPtr,'Sur une échelle d''1(désaccord total) à 5(accord total),\naimez-vous prendre des risques?','center','center');
     DrawFormattedText(windowPtr,'Répondez avec les touches du clavier','center',850);
end
Screen('Flip', windowPtr);
[secs, keyCode1] = KbWait([], 2);
riskAversionQ = KbName(keyCode1);
save(file,'datamat','scurr','riskAversionQ');
DrawFormattedText(windowPtr,'End of experiment\nFin de l''expérience','center','center');
Screen('Flip', windowPtr);
WaitSecs(2);

%Control parameter reset
sca;
ShowCursor;
ListenChar;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Graphical_stim function
%Outputs the graphical stimuli
%as written, the functions requires two loops (ii and jj)
%datamat(ii,2+jj) = reward1 -> probability1 -> reward2 -> probability2
%rect = screen width in pixels

    function graph = graphical_stim() 
        stim = zeros(rect(4),rect(3)); %pixel matrix creation
        XY = [floor(sqrt(datamat(ii,(2+jj)))),floor(sqrt(datamat(ii,(2+jj)))),datamat(ii,(2+jj))-(floor(sqrt(datamat(ii,(2+jj)))).^ 2)];
        %(1):nb of rows of white pixels %(2):nb of columns of white pixels
        %(3):total white pixels - (1)*(2):remainding pixels (will be uncomplete rows)
        while XY(3)>= XY(1) %makes complete rows with remainding pixels
          XY(3) = XY(3) - XY(1);
          XY(2) = XY(2) +1;
        end
        stim(1:XY(1),1:XY(2)) = 1;%adds white pixels to black matrix
        stim(XY(1)+1,1:XY(3)) = 1;
        for kk = 1:rect(4)%random permutation(rows)
            v = stim(kk,:);
            vv = v(randperm(length(v)));
            stim(kk,:) = vv;
        end
        for ll = 1:rect(3)%random permutation(columns)
            v = stim(:,ll);
            vv = v(randperm(length(v)));
            stim(:,ll) = vv;
        end
        graph = stim;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Prob_imagery_exp function output

y = datamat;
end