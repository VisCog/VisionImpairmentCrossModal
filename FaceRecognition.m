function FaceRecognition(participantname)
%
% Displays face images and subjects have to say if "same" or "different"
% Saves trial by trial data
%
% written by Gg Tran & Ione Fine 2019
%
% Function files used include: Psychtoolbox, PseudoRandom.m
% Sound files used: 220Hz_300ms, 440Hz_50ms
%
% 3/11/2019 Ione made the stimulus presentation a function
%
% Running the program: 
% Put in the function FaceRecognition('name') into the command window


clc; % clear command window
close all;
sca; % screen close all

if ~exist('participantname', 'var') ||  isempty(participantname)
    participantname = 'TRAINING';
end

%% directories & subject's identifier

homedir = pwd;
cd(homedir);
theImageLocation = [homedir filesep 'face_images'];
addpath(genpath(theImageLocation));
fileName = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
addpath(genpath('C:\ProgramFiles\PsychToolbox'))
mkdir(participantname) %make a new directory in their name, existed foldername will throw a warning
cd(homedir);

%% trial variables

ntrials = 5; %number of trials
initpauseDur = 0.2; % initial pause after space bar
stimDur = 1.5; % each face up for 1s
pauseDur = 0.5; % interface gap of 0.5s
endoftrialpauseDur = 0.5;

genderCat = {'Female', 'Male'};
pictCategories = {'NES', 'NEHR', 'NEHL', 'HAS', 'HAHR', 'HAHL'};
%Randomize the conditions: male/female, similar/different, the picture
%categegory of the 1st stimulus);
randomCondition = PseudoRandom(ntrials, 2, 2, 6);
[y440_long,Fs440_long] = audioread([homedir filesep 'beep_sounds\440Hz_200ms.wav']);
[y440,Fs440] = audioread([homedir filesep 'beep_sounds\440Hz_50ms.wav']); % new trial sound
[y220,Fs220] = audioread([homedir filesep 'beep_sounds\220Hz_300ms.wav']); % wrong keypress

%% Initialize all data structures to be saved to log file

trial = cell(ntrials, 1);
respMat = cell(ntrials, 2);
stimulusList = cell(ntrials, 2);

%% randomize stimulus order

fnameShuffled = {'FemaleFiles', 'MaleFiles'};
for index = 1:length(genderCat)
    genderFolder = genderCat{index};
    cd([theImageLocation filesep genderFolder])
    files = dir(); fname = {files.name}; fname = fname(3:end)';
    fnameShuffled{index} = fname((randperm(length(fname))));
end
cd(homedir);

%% Setting up PsychToolBox
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
    %% Starting the experiment trials
    for t = 1:ntrials
        
        gender = randomCondition(t, 1);
        condition = randomCondition(t, 2); %pick Different or Similar condition
         pict1type = pictCategories{randomCondition(t, 3)};
        
        Screen('DrawText', window, 'New Trial. Press esc to quit', windowRect(3)/2, ...
            windowRect(4)/2, black);
        Screen('Flip', window);
        
        %First beep indicate start of trial.
        time_stamp_beep_start_trial = GetSecs; sound(y440, Fs440);

        %% find the stimuli folders
        % load first stimulus
        stimulus1Location = [theImageLocation filesep genderCat{gender}...
            filesep fnameShuffled{gender}{t}];
        cd(stimulus1Location);
        tmp = dir(['*', pict1type, '*.jpg']);
        pict1Name  = tmp.name;
        image1 = imread(pict1Name);
        imageTexture1 = Screen('MakeTexture', window, image1);
        
        % load second stimulus
        if condition ==1 % same condition
            stimulus2Location = stimulus1Location;
        else 
            tmp=setdiff(fnameShuffled{gender},fnameShuffled{gender}{t});
            tmp2=randperm(length(tmp));
            stimulus2Location = [theImageLocation filesep genderCat{gender}...
                filesep tmp{tmp2(1)}];
        end
        cd(stimulus2Location)
        switch pict1type
            %if pict1 is neutral (NE) face, pict2 will be happy (HA) face
            case 'NES' % if pict1 is NES, pict2 is HAHR/HAHL
                pict2type = pictCategories{randi([5 6], 1)};
            case 'HAS' % if pict1 is HAS, pict2 is NEHR/NEHL
                pict2type = pictCategories{randi([2 3], 1)};
            case 'HAHL' %if first pict is HA & not straight
                pict2type = pictCategories{2};
            case 'HAHR'
                pict2type = pictCategories{3};
            case 'NEHL'
                pict2type = pictCategories{5};
            case 'NEHR'
                pict2type = pictCategories{6};
        end
        %FIND THE FILE NAME OF THE SECOND PICT
        tmp = dir(['*', pict2type, '*.jpg']);
        pict2Name  = tmp.name;
        image2 = imread(pict2Name);
        imageTexture2 = Screen('MakeTexture', window, image2);
        
        cd(homedir);
        % initiate trial with space bar
        go = 0;
        while go == 0
            [~, keysecs, keyCode] = KbCheck;
            if keyCode(KbName('space')) == 1
                go = 1;
                time_stamp_KBhitSpace = keysecs;
                [time_stamp_start_stim1, time_stamp_start_isi,...
                     time_stamp_start_stim2, time_stamp_KBhit,...
                         KB_hit_key] = PresentFaces();
                
                trial{t} = t;
                respMat{t, 1} = time_stamp_beep_start_trial;
                respMat{t, 2} = time_stamp_KBhitSpace;
                respMat{t, 3} = time_stamp_start_stim1;
                respMat{t, 4} = time_stamp_start_isi;
                respMat{t, 5} = time_stamp_start_stim2;
                respMat{t, 6} = time_stamp_KBhit;
                respMat{t, 7} = KB_hit_key;
                stimulusList{t, 1} = pict1Name;
                stimulusList{t, 2} = pict2Name;
            elseif keyCode(KbName('esc'))
                saveFiles();
                ShowCursor; sca; 
                return;
            end
        end
        
    end
     Screen('CloseAll'); clear mex
catch ME
    cd(homedir);
    Screen('CloseAll'); clear mex
end
saveFiles()

    function saveFiles()
    cd(participantname) %save data in the subject's folder
    response = horzcat(trial, stimulusList, respMat);
    save(strcat(fileName, '.mat'), 'response')
    cd(homedir);
    end

    function [time_stamp_start_stim1, time_stamp_start_isi,...
            time_stamp_start_stim2, time_stamp_KBhit,...
            KB_hit_key] = PresentFaces()
        WaitSecs(initpauseDur);
        
        % interval 1
        Screen('DrawTexture', window, imageTexture1, [], []);
        Screen('Flip', window);
        time_stamp_start_stim1 = GetSecs;
        sound(y440, Fs440);
        WaitSecs(stimDur);
        
        % pause
        Screen('DrawTexture', window, grayTexture);
        Screen('Flip', window);
        time_stamp_start_isi = GetSecs;
        WaitSecs(pauseDur);
        
        % interval 2
        Screen('DrawTexture', window, imageTexture2, [], [], 0);
        Screen('Flip', window);
        time_stamp_start_stim2 = GetSecs;
        sound(y440, Fs440);
        WaitSecs(stimDur);
        
        % pause
        Screen('DrawTexture', window, grayTexture);
        Screen('Flip', window);
        %Wait for participantname to press either f(different)/j(similar) key
        go = 0;
        while go == 0
            [keyIsDown, keysecs1, keyCode1] = KbCheck;
            if keyIsDown
                if keyCode1(KbName('f')) == 1
                    KB_hit_key = KbName('f'); go = 1;
                    time_stamp_KBhit = keysecs1;
                elseif keyCode1(KbName('j')) == 1
                    KB_hit_key = KbName('j');go = 1;
                    time_stamp_KBhit = keysecs1;
                else
                    sound(y220, Fs220);
                    Screen('DrawText', window, 'Wrong key pressed! Press Again',...
                        windowRect(3)/2, windowRect(4)/2, black);
                    Screen('Flip', window);
                end
                KbReleaseWait;
                keyIsDown = 0;
            end
        end
        WaitSecs(endoftrialpauseDur);
    end
end