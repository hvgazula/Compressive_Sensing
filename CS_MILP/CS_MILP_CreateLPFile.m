function CS_MILP_CreateLPFile(varSize, constraintSize, numOfProbs)
% CS_MILP_CreateLPFile(varSize, constraintSize, numOfProbs)
% Creates LP files of each type (given by variable size and constraint size)
% by generating the A and b matrices
% Input Arguments:
% varSize       : Number of Variables
% constraintSize: Number of Constraints
% numOfProbs    : Number of problems of each type

X = 0.8 + rand(varSize, 1)*0.2;
X(randperm(varSize, ceil(0.2*varSize))) = 0;

A = normrnd(0, 1, constraintSize, varSize);
b = A*X;

for probNum = 1 : numOfProbs
    
    fileID_L0   = sprintf('L0_Problem_%03d_Dim_%03d_Measures_%03d.lp', probNum, varSize, constraintSize);
    if ~exist('L0_Problems', 'dir')
        mkdir('L0_Problems');
    end    
    CS_MILP_WriteProblem(fullfile(pwd, 'L0_Problems', fileID_L0), A, b, 0)
    
    fileID_L1      = sprintf('L1_Problem_%03d_Dim_%03d_Measures_%03d.lp', probNum, varSize, constraintSize);    
    if ~exist('L1_Problems', 'dir')
        mkdir('L1_Problems\Instances');
    end    
    CS_MILP_WriteProblem(fullfile(pwd, 'L1_Problems\Instances', fileID_L1), A, b, 1)    
    
end

end