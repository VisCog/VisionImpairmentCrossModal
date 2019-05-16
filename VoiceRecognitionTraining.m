function VoiceRecognitionTraining(participantname, ntrials)

% Displays people voices and subjects have to say if "same" or "different"
% voices.
% If participant answers incorrectly, the trial is repeated.
% Saves trial by trial data
%
% written by Gg Tran & Ione Fine & Kelly Chang 2019
% Function file(s) use: PseudoRandom.m
% Sound files used: 220Hz_300ms, 440Hz_50ms, wrongAnswer
%

close all; clc; sca;
% FlushEvents();
KbName('UnifyKeyNames');

if ~exist('participantname', 'var') ||  isempty(participantname)
    participantname = 'TRAINING';
end

if ~exist('ntrials', 'var') ||  isempty(ntrials)
    ntrials = 50;
end

%% directories & subject's identifier

fileName = strcat(datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '.mat');
homedir = pwd;
% addpath(genpath('C:\ProgramFiles\PsychToolbox'))
% addpath(genpath('C:\Users\Administrator\Desktop\Psychtoolbox-3-PTB_Beta-2014-04-06_V3.0.11\Psychtoolbox\MatlabWindowsFilesR2007a'));
% addpath(genpath('C:\Users\Administrator\Desktop\Psychtoolbox-3-PTB_Beta-2014-04-06_V3.0.11\Psychtoolbox\PsychContributed'))

mkdir(participantname);
cd(homedir);

%% trial variables

initpauseDur = 0.2; % initial pause after space bar
stimDur = 1.5; % each face up for 1s
pauseDur = 0.5; % interface gap of 0.5s
endoftrialpauseDur = 0.5;

%% Randomize the conditions: male/female, similar/different);
randomCondition = PseudoRandom(ntrials, 2, 2);

%% Beep sounds used
[y440_long,Fs440_long] = audioread([homedir filesep 'beep_sounds\440Hz_200ms.wav']);
[y440,Fs] = audioread([homedir filesep 'beep_sounds\440Hz_50ms.wav']);
[y220,Fs220] = audioread([homedir filesep 'beep_sounds\220Hz_300ms.wav']);
[wrong, FsWrong] = audioread([homedir filesep 'beep_sounds\wrongAnswer.wav']);
[yEnd,FsEnd] = audioread([homedir filesep 'beep_sounds\EndOfExperiment.wav']);
theSoundLocation = [homedir filesep 'voice_stim_training'];
cd(theSoundLocation);
addpath(genpath(theSoundLocation));

%% Initialize variables to help process stimulus
genderCat = {'Female', 'Male'};
usedMaleFolders = []; 
usedFemaleFolders = [];
tmpList = [];
firstSoundVoice = '';
fnameShuffled = {'FemaleFiles', 'MaleFiles'};

%% Randomize both the Male & Female stimulus folders
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
        grey.*ones(windowRect(4), windowRect(3)));
    oldTextSize = Screen('TextSize', window, 40);
    Screen('DrawTexture', window, grayTexture, [],[],[],[],[],[255, 0, 0]);
    Screen('Flip', window);


try
    
    % Prompt user input on number of trials        
     number = GetScreenNumber(window, 'Trial number(enter to skip): ', ...
                windowRect(3)*0.05 - 50, windowRect(4)*0.05, [255, 255, 255], grey);
     if ~isnan(number)
        ntrials = number;               
     end
                
     %% Initialize all data structures to be saved to log file
     trial = cell(ntrials, 1);
     respMat = cell(ntrials, 8);
     stimulusList = cell(ntrials, 2);

    %Starting the experiment trial
    for t = 1:ntrials
        respMat{t, 8} = 1;  %Set default answer to first try as correct
        gender = randomCondition(t, 1);
        condition = randomCondition(t, 2); %pick Different or Similar condition
        usedFemaleFolders = unique(usedFemaleFolders);
        usedMaleFolders = unique(usedMaleFolders);
        
        Screen('FillRect', window, [66, 229, 244], windowRect);
        Screen('Flip', window);
        Screen('DrawText', window,...
            'New Trial.', ...
            windowRect(3)/2 -100, windowRect(4)/2, black);
        Screen('DrawText', window,...
            'Spacebar to Start. Esc to quit.', ...
            windowRect(3)/2-500, windowRect(4)/2+50, black);
        Screen('DrawText', window,...
            strcat('t=', num2str(t)), ...
            windowRect(3)/2-500, windowRect(4)/2+100, black);  
        Screen('Flip', window);
              
        %First beep indicate start of trial.
        time_stamp_beep_start_trial = GetSecs; sound(y440, Fs);
        
        %% find the stimuli folders
        % load first stimulus
         if condition == 1 && isempty(usedFemaleFolders) == 0 ...
                 && isempty(usedMaleFolders) == 0
            if gender == 1  
                 tmpList = usedFemaleFolders;
            elseif gender == 2   
                 tmpList = usedMaleFolders;
            end
            if length(tmpList) < length(fnameShuffled{gender})
                firstSoundVoice = Sample(setdiff(fnameShuffled{gender}, tmpList)); 
            else
                firstSoundVoice = Sample(fnameShuffled{gender});
            end
        else
            firstSoundVoice = Sample(fnameShuffled{gender});
        end
       
         if gender == 1 && length(tmpList) < length(fnameShuffled{gender})
                usedFemaleFolders = vertcat(usedFemaleFolders, firstSoundVoice);
         elseif gender == 2 && length(tmpList) < length(fnameShuffled{gender})
                usedMaleFolders = vertcat(usedMaleFolders, firstSoundVoice);
         end
        
        stimulus1Location = fullfile(theSoundLocation, genderCat{gender}, ...
             cell2mat(firstSoundVoice));
        tmp = dir(fullfile(stimulus1Location, '*.wav'));
        tmp = {tmp.name};
        
        %Pick the file name of the first sound
         sound1_index = randi(numel(tmp));
         firstSound = tmp{sound1_index};
        firstSoundPath = fullfile(stimulus1Location, firstSound);
        [sound1, Fsound1] = audioread(firstSoundPath);
        
        % load second stimulus
        if condition == 1
            sound2_index = Sample(setdiff(1:numel(tmp), sound1_index));
            secondSound = tmp{sound2_index};
            secondSoundPath = fullfile(stimulus1Location, secondSound);
            
        else 
            tmp = setdiff(fnameShuffled{gender}, firstSoundVoice);
            secondSoundVoice = tmp{randi(length(tmp))};
            stimulus2Location = fullfile(theSoundLocation, ...
                genderCat{gender}, secondSoundVoice);
            sound2Files = dir(fullfile(stimulus2Location, '*.wav'));
            sound2Files = {sound2Files.name};
            secondSound = char(Sample(sound2Files));
            secondSoundPath = fullfile(stimulus2Location, secondSound);
            %If stimulus2 not in used folders, add it to the used folder
            if isempty(find(strcmp(tmpList, secondSoundVoice))) == 1
                 if gender == 1 && length(usedFemaleFolders) < length(fnameShuffled{gender})
                    usedFemaleFolders = vertcat(usedFemaleFolders, secondSoundVoice);
                elseif gender == 2 && length(usedMaleFolders) < length(fnameShuffled{gender})
                    usedMaleFolders = vertcat(usedMaleFolders, secondSoundVoice);
                end        
            end    
        end
        [sound2,Fsound2] = audioread(secondSoundPath);
        
        % initiate trial with space bar
        go = 0;
        while go == 0
            [~, keysecs, keyCode] = KbCheck;
            if keyCode(KbName('space')) == 1
                go = 1;
                time_stamp_KBhitSpace = keysecs;
                [time_stamp_start_stim1, time_stamp_start_isi,...
                    time_stamp_start_stim2, time_stamp_KBhit, ...
                    KB_hit_key] = PresentVoices();
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
            elseif keyCode(KbName('escape'))
                saveFiles();
                ShowCursor; sca;
                return;
            end
        end
        
    end
    sound(yEnd, FsEnd);
    Screen('CloseAll'); clear mex
catch ME
    cd(homedir)
    Screen('CloseAll'); clear mex
    rethrow(ME);
end
saveFiles();

    function saveFiles()
        response = horzcat(trial, stimulusList, respMat);
        cd(participantname)
        save(fileName, 'response')
        cd(homedir);
    end

    function  [time_stamp_start_stim1, time_stamp_start_isi,...
            time_stamp_start_stim2, time_stamp_KBhit,...
            KB_hit_key] = PresentVoices()
        WaitSecs(initpauseDur);
        % interval 1
        Screen('FillRect', window, [192, 255, 168], windowRect);
        Screen('Flip', window);
        Screen('DrawText', window, 'First sound', windowRect(3)/2 - 100,...
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
        Screen('FillRect', window, [1, 153, 79], windowRect);
        Screen('Flip', window);
        Screen('DrawText', window, 'Second sound', windowRect(3)/2 - 100,...
            windowRect(4)/2, [232, 4, 156]);
        Screen('Flip', window);
        sound(y440, Fs);
        WaitSecs(stimDur);
        time_stamp_start_stim2 = GetSecs;
        p2 = audioplayer(sound2,Fsound2); playblocking(p2);
        
        % pause
        Screen('DrawTexture', window, grayTexture);
        Screen('Flip', window);
        
        %Wait for participantname to press either left arrow(different)/right arrow(similar) key
        Screen('FillRect', window, [7, 60, 249], windowRect);
        Screen('Flip', window);
        go = 0;
        while go == 0
            [keyIsDown, keysecs1, keyCode1] = KbCheck;
            if keyIsDown
                if keyCode1(KbName('leftarrow')) == 1
                    KB_hit_key = KbName('leftarrow'); go = 1;
                    time_stamp_KBhit = keysecs1;
                    if condition == 1 % if incorrect answer given
                        respMat{t, 8} = 0; %if they press wrong or right on 1st try
                        sound(wrong, FsWrong);
                        Screen('DrawText', window, 'Wrong answer! Redo trial!',...
                            windowRect(3)/2, windowRect(4)/2, black);
                        Screen('Flip', window);
                        [time_stamp_start_stim1, time_stamp_start_isi,...
                            time_stamp_start_stim2, time_stamp_KBhit,...
                            KB_hit_key] = PresentVoices();
                    end
                elseif keyCode1(KbName('rightarrow')) == 1
                    KB_hit_key = KbName('rightarrow'); go = 1;
                    time_stamp_KBhit = keysecs1;
                    if condition == 2 % if incorrect answer given
                        respMat{t, 8} = 0;
                        sound(wrong, FsWrong);
                        Screen('DrawText', window, 'Wrong answer! Redo trial!',...
                            windowRect(3)/2 - 300, windowRect(4)/2, black);
                        Screen('Flip', window);
                        [time_stamp_start_stim1, time_stamp_start_isi,...
                            time_stamp_start_stim2, time_stamp_KBhit,...
                            KB_hit_key] = PresentVoices();
                    end
                else
                    sound(y220, Fs220);
                    Screen('DrawText', window, 'Wrong key pressed! Press Again',...
                        windowRect(3)/2 - 300, windowRect(4)/2, black);
                    Screen('Flip', window);
                end
                KbReleaseWait;
                keyIsDown = 0;
            end
            
        end
        WaitSecs(endoftrialpauseDur);
    end

function [number] = GetScreenNumber(windowPtr,msg,x,y,textColor,bgColor)
% [number] = GetScreenNumber(windowPtr,msg,x,y,textColor,bgColor)
% addpath(genpath('C:\Users\Administrator\Desktop\Psychtoolbox-3-PTB_Beta-2014-04-06_V3.0.11\Psychtoolbox\PsychContributed'))
%% Input Control

if ~exist('x', 'var'); x = []; end
if isempty(x); x = 0; end
if ~exist('y', 'var'); y = []; end
if isempty(y); y = 0; end
if ~exist('textColor', 'var'); textColor = []; end
if isempty(textColor); textColor = BlackIndex(windowPtr); end
if ~exist('bgColor', 'var'); bgColor = []; end
if isempty(bgColor); bgColor = GrayIndex(windowPtr); end

%% Draw Text onto Psychtoolbox Screen

% Enable user defined alpha blending if a text background color is
% specified. This makes text background colors actually work, e.g., on OSX:
if ~isempty(bgColor)
    if Screen('Preference', 'TextRenderer') >= 1
        oldalpha = Screen('Preference', 'TextAlphaBlending', 0);
    else
        oldalpha = Screen('Preference', 'TextAlphaBlending', 1-IsLinux);
    end
end

% Clear keyboard event queues
% FlushEvents();

string = ''; % initialize string
output = [msg, ' ', string];

% Write the initial message:
Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
Screen('Flip', windowPtr, 0, 1);

while true
    char = GetKbChar(-3); % get key press on all devices (i.e., -3)

    switch abs(char)
        case {13, 3, 10, 27}
            % ctrl-C, enter, return, or escape
            break;
        case 8 % backspace
            if ~isempty(string)
                % Redraw text string, but with textColor == bgColor, so
                % that the old string gets completely erased:
                oldTextColor = Screen('TextColor', windowPtr);
                Screen('DrawText', windowPtr, output, x, y, bgColor, bgColor);
                Screen('TextColor', windowPtr, oldTextColor);
                
                % Remove last character from string:
                string = string(1:length(string)-1);
            end
        otherwise % add character to string
            string = [string, char]; 
    end
    
    output = [msg, ' ', string];
    Screen('DrawText', windowPtr, output, x, y, textColor, bgColor);
    Screen('Flip', windowPtr, 0, 1);
end

% Restore text alpha blending state if it was altered:
if ~isempty(bgColor)
    Screen('Preference', 'TextAlphaBlending', oldalpha);
end

number = str2double(string);
end
end
