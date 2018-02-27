function CS_MIQP_GMS_CreateFile(Dimension, rank, No_Problems)

Q = normrnd(0, 1, Dimension);
A = Q'*Q;

b = max(max(A))*rand();

myConstraintString = CS_MIQP_GMS_GenerateConstraint(Q, b);

for probNum = 1 : No_Problems
    fileID_L0   = sprintf('L0_Problem_%03d_Dim_%03d_Measures_%03d.gms', probNum, Dimension, rank);
    if ~exist('L0_Problems', 'dir')
        mkdir('L0_Problems');
    end
    CS_MIQP_GMS_WriteProblem(fullfile(pwd, 'L0_Problems', fileID_L0), A, b, 0, myConstraintString)
    
    fileID_L1   = sprintf('L1_Problem_%03d_Dim_%03d_Measures_%03d.gms', probNum, Dimension, rank);
    %     fileID_L1C  = sprintf('L1_Problem_%03d_Dim_%03d_Measures_%03d_1.gms', probNum, Dimension, rank);
    
    if ~exist('L1_Problems', 'dir')
        mkdir('L1_Problems\Instances');
    end
    
    CS_MIQP_GMS_WriteProblem(fullfile(pwd, 'L1_Problems\Instances', fileID_L1), A, b, 1, myConstraintString)
    %     generateProblemGAMS(fullfile(pwd, 'L1_Problems\Instances', fileID_L1C), A, b, 2, myConstraintString)
end

end