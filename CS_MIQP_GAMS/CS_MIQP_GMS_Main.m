function CS_MIQP_GMS_Main()
% CS_MIQP_Main_GAMS()
% This function defines the structure for generating gms files for MIQP problems
% Number of Problem Sets
% Number of Instances of each Problem Type
% Problem type is defined by variable size and constraint size

close all; clear; clc

probSetNum  = 0;
numOfProbs  = 1;

varSizeRange    = 2:5;
constraintSize  = 1;

numOfSubmissionFiles  = 1;

currFolder = pwd;
addpath(currFolder)

dirString = fullfile(currFolder, '..', ['CS_MIQP_Problem_Set_' num2str(probSetNum, '%02d')]);
if ~exist(dirString, 'dir')
    mkdir(dirString)
end
cd(dirString)

for varNum = varSizeRange
    for eqnNum = constraintSize
        if eqnNum < varNum
            CS_MIQP_GMS_CreateFile(varNum, eqnNum, numOfProbs)
        end
    end
end

fclose all;

numOfSubFolders = 3;
folderNames     = cell(numOfSubFolders, 1);

for k = 1 : numOfSubFolders
    folderNames{k} = ['SubSet' sprintf('%02d', k)];
end

cellfun(@(x) mkdir(['L0_Problems_' x '\Instances']), folderNames, 'uniformoutput', 0)

Acell           = struct2cell(dir(fullfile(pwd, 'L0_Problems', '\*.gms')));
Acell           = reshape(Acell, size(Acell, 1), []);
fileList        = Acell(1,:)';

numOfFiles      = length(fileList);
fileOrder       = randperm(numOfFiles);
numFilesEach    = ceil(numOfFiles/length(folderNames));

index = 1;

while ~isempty(fileOrder)
    if length(fileOrder) < numFilesEach
        for j = 1 : length(fileOrder)
            copyfile(fullfile(pwd, 'L0_Problems', fileList{fileOrder(j)}), fullfile(pwd, ['L0_Problems_' folderNames{end}], 'Instances'))
        end
        fileOrder = [];
    else
        for j = 1 : numFilesEach
            copyfile(fullfile(pwd, 'L0_Problems', fileList{fileOrder(j)}), fullfile(pwd, ['L0_Problems_' folderNames{index}], 'Instances'));
        end
        fileOrder = fileOrder(numFilesEach + 1 : end);
        index = index + 1;
    end
end

for folderNum = 1 : length(folderNames)
    mkdir(['L0_Problems_' folderNames{folderNum} '\Results'])
    cd(fullfile(pwd, ['L0_Problems_' folderNames{folderNum}], 'Instances'));
    if any(size(dir('*.gms' ),1))
        CS_MIQP_GMS_GenerateSubmissionFile(folderNames{folderNum}, 0, numOfSubmissionFiles);
    end
    cd ../..
end

cd(fullfile(pwd, 'L1_Problems\Instances'))
CS_MIQP_GMS_GenerateSubmissionFile('L1_Submission', 1);
mkdir('..\Results')
cd ../..
mkdir('L0_Problems_Results')

cd(currFolder)

end