%Function files use: PseudoRandom.m, cellwrite.m
%Sound files used: 220Hz_300ms, 440Hz_50ms

close all;
clearvars;
sca;

fileName = strcat(datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '.csv');
homedir = pwd;
cd(homedir);

%Setting up PsychToolBox
screens = Screen('Screens');
screen = max(screens);
Screen('Preference', 'Verbosity',0);
Screen('Preference','SkipSyncTests', 1);
white = WhiteIndex(screen);
black = BlackIndex(screen);
grey = white / 2;
[window, windowRect] = PsychImaging('OpenWindow', screen, grey);

ntrials = 10; %number of trials
nStimulus = 35;
pictCategories = {'NES', 'NEHR', 'NEHL', 'HAS', 'HAHR', 'HAHL'};
%Randomize the conditions: male/female, similar/different, the picture
%categegory of the 1st stimulus);
randomCondition = PseudoRandom(ntrials, 2, 2, 6);
theImageLocation = [homedir filesep 'face images'];
cd(theImageLocation);
addpath(genpath(theImageLocation));

%Randomize both the Male & Female stimulus folders
genderCat = {'Female', 'Male'};
fnameShuffled = {'FemaleFiles', 'MaleFiles'};
for index = 1:2
    genderFolder = genderCat{index};
    cd([theImageLocation filesep genderFolder])
    files = dir();
    cd(homedir);
    %Getting the subfolder name
    %Shuffle their orders
    fname = {files.name};
    fname = fname(3:end)';
    fnameShuffled{index} = fname((randperm(length(fname))));
end

cd(homedir);

%Initialize all data structures to be saved to log file
%trial = zeros(ntrials, 1);
%respMat = nan(ntrials, 7);
trial = cell(ntrials, 1);
respMat = cell(ntrials, 7);
stimulusList = cell(ntrials, 2);
%stimulus2 = cell(ntrials, 1);
folder2IndexMat = zeros(ntrials, 1); %PUT THIS HERE TO TEST FOLDER2 RANDOMIZATION

%TESTING TESTING RANDOMIZATION

%Starting the experiment trials
for t = 1:ntrials
    %Show screen
    DrawFormattedText(window, 'New Trial', 'center', 'center', black);
    Screen('Flip', window); 
    WaitSecs(2);
    %Get time stamp of first sound. Put sound on 
    time_stamp_sound1 = GetSecs;
    %Make first sound:
    [y,Fs] = audioread('sounds\440Hz_50ms.wav');
    sound(y, Fs);
    %Pick the gender for the first stimulus
    genderNum = randomCondition(t, 1);       
    gender = ('');
    if genderNum == 1
        gender = ('Female');
    else
        gender = ('Male');
    end 
    %Pick the first stimulus folder                                  
    stimulusLocation = [theImageLocation filesep gender filesep ...
        fnameShuffled{genderNum}{t}];
    cd(stimulusLocation)
    pictsName = dir('*.jpg');
    
    %Delete all files you don't want  [will figure out this step soon...]
    
    condition = randomCondition(t, 2); %pick Different or Similar condition
    types = randomCondition(t, 3);
    pictTypes = (''); %picture type of 1st stimlus
    secondPictTypes = ('');%picture type of 2nd stimlus
    if types == 1
        pictTypes = pictCategories{1};
    elseif types == 2
        pictTypes = pictCategories{2};
    elseif types == 3
        pictTypes = pictCategories{3};
    elseif types == 4
        pictTypes = pictCategories{4};
    elseif types == 5
        pictTypes = pictCategories{5};
    else 
        pictTypes = pictCategories{6};
    end

    pictsName  = {pictsName.name};
    firstPict = '';
    secondPict = '';
    image1 = '';
    image2 = '';
    
    %Find the file name of the first picture
    for k = 1:length(pictsName)
        if contains(pictsName{k}, pictTypes) == 1
            firstPict = pictsName{k};
            break;
        end
    end
    %If condition is similar, pick another pict in same subfolder
    if condition == 1
        %if pict1 is neutral (NE) face, pict2 will be happy (HA) face 
        if contains(pictTypes, 'NES') %if pict1 is NES, pict2 is HAHR/HAHL
            secondPictTypes = pictCategories{randi([5 6], 1)};
        elseif contains(pictTypes, 'HAS') %if pict1 is HAS, pict2 is NEHR/NEHL
            secondPictTypes = pictCategories{randi([2 3], 1)};
        else 
            if contains(pictTypes, 'HA') %if first pict is HA & not straight
               %pick NE pictures but with different orientation
               if contains(pictTypes, 'HL')
                   secondPictTypes = pictCategories{2}; %NEHR
               else
                   secondPictTypes = pictCategories{3}; %NEHL
               end
            else
                %if 1st pict is NE, pick picts in HA but different orientation
                if contains(pictTypes, 'HL')
                   secondPictTypes = pictCategories{5} %HAHR
               else
                   secondPictTypes = pictCategories{6} %HAHL
               end
            end
        end
        %FIND THE FILE NAME OF THE SECOND PICT 
        for k = 1:length(pictsName)
                if contains(pictsName{k}, secondPictTypes) == 1
                    secondPict = pictsName{k};
                    break;
                end
        end
    else %If condition is different, pick pictures in another folder (folder2)
        %pick folder2 randomly, folder2 cannot be the previously used folder
        %Then, get a picture from folder2. Picture has different
        %orientation than the first picture.
        indexes = 1:nStimulus; 
        folder2_indexes = indexes(~ismember(1:numel(indexes), t));
        folder2_indexesShuffled = randperm(numel(folder2_indexes));
        select_index = folder2_indexesShuffled(randi(numel(folder2_indexesShuffled)));
        folder2IndexMat(t, 1) = select_index; %PUT DIS HERE TO TEST
        nextStimulusLocation = [theImageLocation filesep gender filesep ...
            fnameShuffled{genderNum}{select_index}];
        cd(nextStimulusLocation);
        nextPictsName = dir('*.jpg'); 
        nextPictsName = {nextPictsName.name};
        cd(homedir);
        
        %Choose picture with different orientation from the first picture
        if contains(pictTypes, 'NES') %if pict1 is NES, pict2 is HAHR/HAHL
            secondPictTypes = pictCategories{randi([5 6], 1)};
        elseif contains(pictTypes, 'HAS') %if pict1 is HAS, pict2 is NEHR/NEHL
            secondPictTypes = pictCategories{randi([2 3], 1)};
        else 
            if contains(pictTypes, 'HA') %if first pict is HA & not straight
               %pick NE pictures with different orientation
               if contains(pictTypes, 'HL')
                   secondPictTypes = pictCategories{2}; %NEHR
               else
                   secondPictTypes = pictCategories{3}; %NEHL
               end
            else
                %if 1st pict is NE, pick picts in HA but different orientation
                if contains(pictTypes, 'HL')
                   secondPictTypes = pictCategories{5} %HAHR
               else
                   secondPictTypes = pictCategories{6} %HAHL
               end
            end
        end
       for k = 1:length(nextPictsName)
            if contains(nextPictsName{k}, secondPictTypes) == 1
                 secondPict = nextPictsName{k};
                 break;
            end
       end    
    end

    
    %SHOW THE TWO PICTURES ON THE SCREEN    
    image1 = imread(firstPict);
    image2 = imread(secondPict);
    imageTexture = Screen('MakeTexture', window, image1);
    imageTexture2 = Screen('MakeTexture', window, image2);
     
    KbWait; %Wait for keyboard to start showing first stimulus

     [~, keysecs1, keyCode1] = KbCheck;
      if keyCode1(KbName('space')) == 1
        Screen('DrawTexture', window, imageTexture, [], [], 0);
        Screen('Flip', window);
        time_stamp_start_stim1 = GetSecs;
        WaitSecs(1);
        time_stamp_KBhit1 = keysecs1;
      end
    
    %time stamp start isi
    %Grey screen 1000ms
    Screen('Flip', window)
    time_stamp_start_isi = GetSecs;
    WaitSecs(1);

    %SOUND2. 
    cd(homedir);
    [y,Fs] = audioread('sounds\440Hz_50ms.wav');
    sound(y, Fs);
    WaitSecs(1);
    Screen('DrawTexture', window, imageTexture2, [], [], 0);
    Screen('Flip', window);
    time_stamp_start_stim2 = GetSecs;
    WaitSecs(1);
    Screen('Flip', window);
    %Wait for participant to press either f(different)/j(similar) key
    KbWait;
    [~, time_stamp_KBhit2, keyCode2] = KbCheck; 
    if keyCode2(KbName('f')) == 1
        KB_hit2_key = KbName('f');
    elseif keyCode2(KbName('j')) == 1
        KB_hit2_key = KbName('j');
    else
        %%%%%If PAR press wrong keyboard
        %%%%Put them in infinite loop until the right keyboard is pressed
        while keyCode2(KbName('j')) == 0 || keyCode2(KbName('j')) == 0
            [y2,Fs2] = audioread('sounds\220Hz_300ms.wav');
            sound(y2, Fs2);
            DrawFormattedText(window, 'Wrong key pressed! \n\n Press Again',...
                        'center', 'center', black);
            Screen('Flip', window);
            KbWait;
            [~, time_stamp_KBhit2, keyCode2] = KbCheck; 
            if keyCode2(KbName('j')) == 1 
                KB_hit2_key = KbName('f');
                break;
            elseif keyCode2(KbName('j')) == 1
                KB_hit2_key = KbName('j');
                break;
            end
        end
    end 
    
    trial{t} = t;
    respMat{t, 1} = time_stamp_sound1;
    respMat{t, 2} = time_stamp_KBhit1;
    respMat{t, 3} = time_stamp_start_stim1;
    respMat{t, 4} = time_stamp_start_isi;
    respMat{t, 5} = time_stamp_start_stim2;
    respMat{t, 6} = time_stamp_KBhit2;
    respMat{t, 7} = KB_hit2_key;
    
    stimulusList{t, 1} = firstPict;
    stimulusList{t, 2} = secondPict;
end
WaitSecs(1);
DrawFormattedText(window, 'Experiment Finished \n\n Press Any Key To Exit',...
    'center', 'center', black);
Screen('Flip', window);
KbStrokeWait;
sca;
cd(homedir);

response = horzcat(trial, stimulusList, respMat);
cellwrite(fileName, response)
responseTable = cell2table(response, 'VariableNames',...
    {'trial' 'stimulus1' 'stimulus2' ...
    'time_stamp_sound1' 'time_stamp_KBhit1'...
    'time_stamp_start_stim1' 'time_stamp_start_isi'... 
    'time_stamp_start_stim2' 'time_stamp_KBhit2' 'KB_hit2_key'});
writetable(responseTable, fileName)



