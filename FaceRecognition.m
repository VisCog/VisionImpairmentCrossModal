%function FaceRecognition
%
% Displays face images and subjects have to say if "same" or "different"
% Saves trial by trial data
%
% written by Gg Tran & Ione Fine 2019
%
% Function files used include: Psychtoolbox, makeBeep, PseudoRandom.m, cellwrite.m
% Sound files used: 220Hz_300ms, 440helpHz_50ms
clc; % clear command window
close all; 
clearvars;
sca; % screen close all

%% directories & subject's identifier

homedir = pwd;
cd(homedir);
theImageLocation = [homedir filesep 'face_images'];
addpath(genpath(theImageLocation));
% fileName = strcat(datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '.csv');
fileName = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
addpath(genpath('C:\ProgramFiles\PsychToolbox'))
Participant = 'CODE IDENTIFIER'; % PUT IN PARTICIPANT'S CODE IDENTIFIER
mkdir(Participant) %make a new directory in their name, existed foldername will throw a warning
cd(homedir);

%% trial variables

ntrials = 1; %number of trials
nStimulus = 35;
initpauseDur = 0.2; % initial pause after space bar
stimDur = 1.5; % each face up for 1s
pauseDur = 0.5; % interface gap of 0.5s

genderCat = {'Female', 'Male'};
pictCategories = {'NES', 'NEHR', 'NEHL', 'HAS', 'HAHR', 'HAHL'};
%Randomize the conditions: male/female, similar/different, the picture
%categegory of the 1st stimulus);
randomCondition = PseudoRandom(ntrials, 2, 2, 6);
[y440_long,Fs] = audioread([homedir filesep 'beep_sounds\440Hz_200ms.wav']);
[y440,Fs] = audioread([homedir filesep 'beep_sounds\440Hz_50ms.wav']);
[y220,Fs] = audioread([homedir filesep 'beep_sounds\220Hz_300ms.wav']);
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
        
        Screen('DrawText', window, 'New Trial', windowRect(3)/2, ...
            windowRect(4)/2, black);
        Screen('Flip', window);
        
        %Beep indicates new trial. Put beep sound on
        time_stamp_sound1 = GetSecs; sound(y440, Fs);
        
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
        if condition ==1
            stimulus2Location = stimulus1Location;
        else %tmp returns a randomly chosen folder, different from folder1
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
            end
        end
        WaitSecs(initpauseDur);
        
        % interval 1
        Screen('DrawTexture', window, imageTexture1, [], []);
        Screen('Flip', window);
        sound(y440, Fs);
        WaitSecs(stimDur);
        
        % pause
        Screen('DrawTexture', window, grayTexture);
        Screen('Flip', window);
        WaitSecs(pauseDur);
        
        % interval 2
        Screen('DrawTexture', window, imageTexture2, [], [], 0);
        Screen('Flip', window);
        sound(y440, Fs);
        WaitSecs(stimDur);
        
        % pause
        Screen('DrawTexture', window, grayTexture);
        Screen('Flip', window);
        
        %Wait for participant to press either f(different)/j(similar) key
        go = 0;
        while go == 0
            [keyIsDown, keysecs, keyCode] = KbCheck;
            if keyIsDown
                if keyCode(KbName('f')) == 1
                    KB_hit_key = KbName('f');go = 1;
                    time_stamp_KBhit = keysecs;
                elseif keyCode(KbName('j')) == 1
                    KB_hit_key = KbName('j');go = 1;
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
        respMat{t, 1} = time_stamp_KBhitSpace-time_stamp_KBhit;
        respMat{t, 2} = KB_hit_key;
        
        stimulusList{t, 1} = pict1Name;
        stimulusList{t, 2} = pict2Name;
        Screen('DrawTexture', window, grayTexture);
    end
catch ME
    Screen('CloseAll'); clear mex
end

WaitSecs(1);
sca;
cd(Participant) %save data in the subject's folder

response = horzcat(trial, stimulusList, respMat);
save(strcat(fileName, '.mat'), 'response')


