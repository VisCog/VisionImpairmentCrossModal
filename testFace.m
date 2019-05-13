
%%
ntrials = 50;
%% directories & subject's identifier

homedir = pwd;
cd(homedir);
theImageLocation = [homedir filesep 'face_images'];
addpath(genpath(theImageLocation));
fileName = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
addpath(genpath('C:\ProgramFiles\PsychToolbox'))
participantname = 'test';
mkdir(participantname)
cd(homedir);

%% Initialize variables to help process stimulus
genderCat = {'Female', 'Male'};
pictCategories = {'NES', 'NEHR', 'NEHL', 'HAS', 'HAHR', 'HAHL'};
usedMaleFolders = []; 
usedFemaleFolders = [];
tmpList = [];
Stimulus1Folder = '';
%Randomize the conditions: male/female, similar/different, the picture
%categegory of the 1st stimulus);
randomCondition = PseudoRandom(ntrials, 2, 2, 6);

%% Initialize all data structures to be saved to log file

trial = cell(ntrials, 1);
% respMat = cell(ntrials, 2);
stimulusList = cell(ntrials, 2);
folder1 = [];

%% randomize stimulus order

fnameShuffled = {'FemaleFiles', 'MaleFiles'};
for index = 1:length(genderCat)
    genderFolder = genderCat{index};
    cd([theImageLocation filesep genderFolder])
    files = dir(); fname = {files.name}; fname = fname(3:end)';
    fnameShuffled{index} = fname((randperm(length(fname))));
end
cd(homedir);

%% start trial
for t = 1:ntrials
        
          gender = randomCondition(t, 1);
%          condition = randomCondition(t, 2); %pick Different or Similar condition
 condition = 1; 
         pict1type = pictCategories{randomCondition(t, 3)};
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
                Stimulus1Folder = Sample(setdiff(fnameShuffled{gender}, tmpList)); 
            else
                Stimulus1Folder = Sample(fnameShuffled{gender});
            end
        else
            Stimulus1Folder = Sample(fnameShuffled{gender});
        end
       
         if gender == 1 && length(tmpList) < length(fnameShuffled{gender})
                usedFemaleFolders = vertcat(usedFemaleFolders, Stimulus1Folder);
         elseif gender == 2 && length(tmpList) < length(fnameShuffled{gender})
                usedMaleFolders = vertcat(usedMaleFolders, Stimulus1Folder);
         end
         
         folder1 = vertcat(folder1, Stimulus1Folder);
        

        stimulus1Location = fullfile(theImageLocation, genderCat{gender},...
            cell2mat(Stimulus1Folder));
        tmp = dir(fullfile(stimulus1Location,['*', pict1type, '*.jpg']));
        pict1Name  = tmp.name;
        
        % load second stimulus
        if condition == 1 % same condition
            stimulus2Location = stimulus1Location;
        else 
            stimulus2Folder = Sample(setdiff(fnameShuffled{gender}, Stimulus1Folder));
            stimulus2Location = fullfile(theImageLocation, genderCat{gender},...
                cell2mat(stimulus2Folder));
            %If stimulus2 not in used folders, add it to the used folder
            if isempty(find(strcmp(tmpList, stimulus2Folder))) == 1
                 if gender == 1 && length(usedFemaleFolders) < length(fnameShuffled{gender})
                    usedFemaleFolders = vertcat(usedFemaleFolders, stimulus2Folder);
                elseif gender == 2 && length(usedMaleFolders) < length(fnameShuffled{gender})
                    usedMaleFolders = vertcat(usedMaleFolders, stimulus2Folder);
                end        
            end
        end
        
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
        tmp = dir(fullfile(stimulus2Location,...
            ['*', pict2type, '*.jpg']));
        pict2Name  = tmp.name;
        
         trial{t} = t;
             
                stimulusList{t, 1} = pict1Name;
                stimulusList{t, 2} = pict2Name;
            
        
 end
 response = horzcat(trial, stimulusList);
        cd(participantname)
        save(fileName, 'response')
        cd(homedir);