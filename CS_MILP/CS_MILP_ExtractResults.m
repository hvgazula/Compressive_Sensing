function CS_MILP_ExtractResults()
% compSensExtractResults(flag): Extract results for L0 & L1 Problems;

% Browse to the folder where you have the results and call this function
% ResultsTable is the variable we are looking for

% IMPORTANT: varSizRange and constraintSizeRange should be
% copied from compSensProbSetGenerator()

close all; clear; clc

myFolder = uigetdir;
cd(myFolder)

varSizeRange         = 25:25:175;
constraintSizeRange  = 5:5:95;

fileList = dir;

if strcmp(fileList(3).name(2), '0')
    fileStart   = 'L0';
else
    fileStart   = 'L1';
end

checkString = 'Number of non-zero variables is : ';

ResultsTable    = zeros(length(fileList) - 2, 3);
count           = 1;

for dimNum = 1 : length(varSizeRange)
    for measNum = 1 : length(constraintSizeRange)
        if ~(constraintSizeRange(measNum) < varSizeRange(dimNum))
            continue
        else
            dimString               = sprintf('%03d', varSizeRange(dimNum));
            measureString           = sprintf('%03d', constraintSizeRange(measNum));
            FileString              = [fileStart '_Problem_001_Dim_' dimString '_Measures_' measureString '.txt'];
            
            try
                fileContents        = fileread(FileString);
                Index               = strfind(fileContents, checkString);
                Value               = sscanf(fileContents(Index(1) + length(checkString):end), '%g', 1);
            catch
                Value               = NaN;
            end
            
            myVec                   = [varSizeRange(dimNum) constraintSizeRange(measNum) Value];
            ResultsTable(count, :)  = myVec;
            count                   = count + 1;
        end
    end
end

disp(ResultsTable)