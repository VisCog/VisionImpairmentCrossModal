%Function file(s) use: PseudoRandom.m
%Sound files used: 220Hz_300ms, 440Hz_50ms
close all; clear all; clc; sca;

%% directories & subject's identifier

fileName = strcat(datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '.mat');
homedir = pwd;
addpath(genpath('C:\ProgramFiles\PsychToolbox'))
Participant = 'CODE IDENTIFIER'; % PUT IN PARTICIPANT'S CODE IDENTIFIER
mkdir(Participant) %make a new directory in their name, existed foldername will throw a warning
cd(homedir);

%% trial variables

ntrials = 5; %number of trials
nStimulus = 6;  %CHANGE THE TOTAL NUMBER OF STIMULUS FILES YOU HAVE
initpauseDur = 0.2; % initial pause after space bar
stimDur = 1.5; % each face up for 1s
pauseDur = 0.5; % interface gap of 0.5s

%Randomize the conditions: male/female, similar/different);
randomCondition = PseudoRandom(ntrials, 2, 2);
[y440_long,Fs] = audioread([homedir filesep 'beep_sounds\440Hz_200ms.wav']);
[y440,Fs] = audioread([homedir filesep 'beep_sounds\440Hz_50ms.wav']);
[y220,Fs] = audioread([homedir filesep 'beep_sounds\220Hz_300ms.wav']);
theSoundLocation = [homedir filesep 'voice_stimulus'];
cd(theSoundLocation);
addpath(genpath(theSoundLocation));

%Initialize all data structures to be saved to log file
trial = cell(ntrials, 1);
respMat = cell(ntrials, 7);
stimulusList = cell(ntrials, 2);

%Randomize both the Male & Female stimulus folders
genderCat = {'Female', 'Male'};
fnameShuffled = {'FemaleFiles', 'MaleFiles'};
for index = 1:2
    genderFolder = genderCat{index};
    cd([theSoundLocation filesep genderFolder])
    files = dir(); cd(homedir);
    %Getting the subfolder name
    %Shuffle their orders
    fname = {files.name}; fname = fname(3:end)';
    fnameShuffled{index} = fname((randperm(length(fname))));
end
cd(homedir);

%Setting up PsychToolBox
screens = Screen('Screens');
scrn = max(screens);
Screen('Preference', 'Verbosity',0);
Screen('Preference','SkipSyncTests', 1);
Screen('Preference','VisualDebugLevel', 0);
Screen('Preference','SuppressAllWarnings', 1);
white = WhiteIndex(scrn);
black = BlackIndex(scrn);
grey = white / 2;

[window, windowRect] = Screen('OpenWindow', scrn, grey);
grayTexture = Screen('MakeTexture', window, ...
    grey.*ones(windowRect(4)/2, windowRect(3)/2));
oldTextSize=Screen('TextSize', window, 40);
Screen('DrawTexture', window, grayTexture);
Screen('Flip', window);

try
    %Starting the experiment trials
    for t = 1:ntrials
        gender = randomCondition(t, 1);  
        condition = randomCondition(t, 2); %pick Different or Similar condition

        Screen('DrawText', window, 'New Trial', windowRect(3)/2, ...
                windowRect(4)/2, black);
        Screen('Flip', window);

        %First beep indicate start of trial. 
        time_stamp_beep_start_trial = GetSecs; 
        sound(y440, Fs);
 
         %% find the stimuli folders
            % load first stimulus
        stimulus1Location = [theSoundLocation filesep genderCat{gender} filesep ...
            fnameShuffled{gender}{t}];
        cd(stimulus1Location)
        tmp = dir('*.wav'); tmp = {tmp.name};

        %Pick the file name of the first sound
        sound1_index = randi(numel(tmp));
        firstSound = tmp{sound1_index};
        [sound1, Fsound1] = audioread(firstSound);
        % load second stimulus
        %If condition is similar, pick another sound in same subfolder
        if condition == 1
             tmp = setdiff(tmp, firstSound);
             tmp2 = randperm(length(tmp));
             secondSound = tmp{tmp2(1)};

        else %If condition is different, pick sound in another folder (folder2)
            %pick folder2 randomly, folder2 cannot be the previously used folder
            %Then, get a sound file from folder2.
            tmp = setdiff(fnameShuffled{gender},fnameShuffled{gender}{t}); 
            tmp2 = randperm(length(tmp));
            stimulus2Location = [theSoundLocation filesep genderCat{gender}...
                    filesep tmp{tmp2(1)}];
            cd(stimulus2Location);
            sound2Name = dir('*.wav');
            sound2Name = {sound2Name.name};
            secondSound = sound2Name{randi(length(sound2Name))}; 
        end
        [sound2,Fsound2] = audioread(secondSound);
        cd(homedir);

        % initiate trial with space bar
         go = 0;
         while go == 0
            [~, keysecs, keyCode] = KbCheck;
            if keyCode(KbName('space')) == 1
                go = 1;
                time_stamp_KBhitSpace = keysecs;
            end
         end
         WaitSecs(initpauseDur);

         % interval 1
         Screen('DrawText', window, 'First sound', windowRect(3)/2,...
             windowRect(4)/2, black);        
         Screen('Flip', window);
         sound(y440, Fs);
         WaitSecs(stimDur);
         time_stamp_start_stim1 = GetSecs;
         p1 = audioplayer(sound1,Fsound1); playblocking(p1);

        % pause
        Screen('DrawTexture', window, grayTexture);
        Screen('Flip', window)
        time_stamp_start_isi = GetSecs;
        WaitSecs(pauseDur);

        % interval 2 
        Screen('DrawText', window, 'Second sound', windowRect(3)/2,...
            windowRect(4)/2, [232, 4, 156]);        
        Screen('Flip', window);
        sound(y440, Fs);
        WaitSecs(stimDur);
        time_stamp_start_stim2 = GetSecs;
        p9 = audioplayer(sound2,Fsound2); playblocking(p9);

        % pause
        Screen('DrawTexture', window, grayTexture);
        Screen('Flip', window);

        %Wait for participant to press either f(different)/j(similar) key
        go = 0;
        while go == 0
            [keyIsDown, keysecs, keyCode] = KbCheck;
            if keyIsDown
               if keyCode(KbName('f')) == 1
                  KB_hit_key = KbName('f'); go = 1;
                  time_stamp_KBhit = keysecs;
               elseif keyCode(KbName('j')) == 1
                  KB_hit_key = KbName('j'); go = 1;
                  time_stamp_KBhit = keysecs;
               else
                  sound(y220, Fs);
                  Screen('DrawText', window, 'Wrong key pressed!  Press Again',...
                         windowRect(3)/2, windowRect(4)/2, black);
                  Screen('Flip', window);
               end
               KbReleaseWait;
               keyIsDown = 0;
           end
        end

        trial{t} = t;
        respMat{t, 1} = time_stamp_beep_start_trial;
        respMat{t, 2} = time_stamp_KBhitSpace;
        respMat{t, 3} = time_stamp_start_stim1;
        respMat{t, 4} = time_stamp_start_isi;
        respMat{t, 5} = time_stamp_start_stim2;
        respMat{t, 6} = time_stamp_KBhit;
        respMat{t, 7} = KB_hit_key;   
        stimulusList{t, 1} = firstSound;
        stimulusList{t, 2} = secondSound;
        Screen('DrawTexture', window, grayTexture);
    end
catch ME
     Screen('CloseAll'); clear mex
end
Screen('DrawText', window, 'Experiment Finished.   Press Any Key To Exit',...
    windowRect(3)/2, windowRect(4)/2, black);
Screen('Flip', window);
WaitSecs(1);
sca;
cd(homedir);
  
response = horzcat(trial, stimulusList, respMat);
cd(Participant)
save(fileName, 'response')



