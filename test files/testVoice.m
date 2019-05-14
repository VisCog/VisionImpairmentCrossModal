close all; clc; clear mex;

fileName = strcat(datestr(now, 'yyyy-mm-dd-HH-MM-SS'), '.mat');

homedir = pwd;
addpath(genpath('C:\ProgramFiles\PsychToolbox'))
participantname = 'test';
mkdir(participantname) %make a new directory in their name, existed foldername will throw a warning
cd(homedir);

%% Randomize the conditions: female/male, similar/different);

ntrials = 40;
randomCondition = PseudoRandom(ntrials, 2, 2);
theSoundLocation = [homedir filesep 'voice_stim_test'];
cd(theSoundLocation);
addpath(genpath(theSoundLocation));

%% Initialize all data structures to be saved to log file
trial = cell(ntrials, 1);
stimulusList = cell(ntrials, 2);
tmpList = [];

%% Initialize variables to help process stimulus
genderCat = {'Female', 'Male'};
usedMaleFolders = []; 
usedFemaleFolders = []; 
folder1 = [];
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

%% run trials
for t = 1:ntrials        
         gender = randomCondition(t, 1);
%         condition = randomCondition(t, 2); %pick Different or Similar condition
        condition = 1;
        
        usedFemaleFolders = unique(usedFemaleFolders);
         usedMaleFolders = unique(usedMaleFolders);
         
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
        
         folder1 = vertcat(folder1, firstSoundVoice);
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
        
        trial{t} = t;
             
                stimulusList{t, 1} = firstSound;
                stimulusList{t, 2} = secondSound;
            
        
end

        response = horzcat(trial, stimulusList);
        cd(participantname)
        save(fileName, 'response')
        cd(homedir);
