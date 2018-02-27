function CS_MIQP_GenerateSubmissionFile_GAMS(MyName, ~, varargin)

if nargin > 2
    numOfJobSubmissionFiles = varargin{1};
else
    numOfJobSubmissionFiles = 1;
end

currExe = 'gams';

initFileList    = dir([cd '\*.gms']);
Acell           = struct2cell(initFileList);
Acell           = reshape(Acell, size(Acell, 1), []);
finalFileList   = Acell(1,:)';

numOfFiles      = length(finalFileList);
subFileOrder    = randperm(numOfFiles);
numFilesEach    = ceil(numOfFiles/numOfJobSubmissionFiles);

index = 1;
while ~isempty(subFileOrder)
    
    try
        fileList    = finalFileList(subFileOrder(1:numFilesEach));
    catch
        fileList    = finalFileList(subFileOrder);
    end
    
    fileName        = [MyName num2str(index, '%02d')];
    fullFileName    = [fileName '.sh'];
    LP_file         = fopen(fullFileName,'W+t');
    
    if LP_file < 0
        error('error opening file %s\n\n',fileID);
    end
    
    fprintf(LP_file, '#!/bin/bash\n');
    fprintf(LP_file, '#$ -S /bin/bash\n');
    fprintf(LP_file, '#$ -N %s\n', fileName);
    fprintf(LP_file, '#$ -cwd\n');
    fprintf(LP_file, '#$ -V\n');
    fprintf(LP_file, '#$ -q serial\n');
    fprintf(LP_file, '#$ -pe fill 1\n');
    fprintf(LP_file, '#$ -o $JOB_NAME.o$JOB_ID\n');
    fprintf(LP_file, '#$ -j y\n');
    fprintf(LP_file, '#$ -P hrothgar\n');
    fprintf(LP_file, '\n');
    
    fprintf(LP_file, 'date\n');
    for i = 1 : length(fileList)
        [~, resultFileName] = fileparts(fileList{i});
        printString = [currExe ' Instances/' fileList{i} ' o=Results/' [resultFileName '.lst lo=2 lf=/dev/null'] '\n'];
        fprintf(LP_file, printString);
    end
    
    fprintf(LP_file, 'date');
    fclose(LP_file);
    
    unix2dos(fullFileName, 1)
    movefile(fullFileName, '..')
    
    try
        subFileOrder = subFileOrder(numFilesEach + 1:end);
    catch
        subFileOrder = [];
    end
    
    index = index + 1;
end

allSubFileName  = [MyName '_AllSub.sh'];
allSubFile      = fopen(allSubFileName,'W+t');

if allSubFile < 0
    error('error opening file %s\n\n',fileID);
end

fprintf(allSubFile, '#!/bin/bash\n');
for j = 1 : (index - 1)
    fprintf(allSubFile, ['qsub ' MyName '%02d.sh\n'], j);
end
fclose(LP_file);

unix2dos(allSubFileName, 1)
movefile(allSubFileName, '..')

fclose all;

end