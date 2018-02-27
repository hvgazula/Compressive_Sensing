function CS_MIQP_CreateLPFile(Dimension, rank, No_Problems)

Q = normrnd(0, 1, Dimension);
A = Q'*Q;
% [~, y] = chol(A);
% b = A*X;
b = 2*max(max(A));

for probNum = 1 : No_Problems
    fileID_L0   = sprintf('L0_Problem_%03d_Dim_%03d_Measures_%03d.lp', probNum, Dimension, rank);
    if ~exist('L0_Problems', 'dir')
        mkdir('L0_Problems');
    end
    CS_MIQP_WriteProblem(fullfile(pwd, 'L0_Problems', fileID_L0), A, b, 0)
    
    fileID_L1   = sprintf('L1_Problem_%03d_Dim_%03d_Measures_%03d.lp', probNum, Dimension, rank);
    fileID_L1C  = sprintf('L1_Problem_%03d_Dim_%03d_Measures_%03d_1.lp', probNum, Dimension, rank);
    
    if ~exist('L1_Problems', 'dir')
        mkdir('L1_Problems\Instances');
    end
    
    CS_MIQP_WriteProblem(fullfile(pwd, 'L1_Problems\Instances', fileID_L1), A, b, 1)
    CS_MIQP_WriteProblem(fullfile(pwd, 'L1_Problems\Instances', fileID_L1C), A, b, 2)
end

end