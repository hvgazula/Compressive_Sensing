function CS_MIQP_WriteProblem(fileID, A, b, fileTypeFlag)

[~, dimension] = size(A);

LP_File = fopen(fileID,'W+t');

if LP_File < 0
    error('error opening file %s\n\n', fileID);
end

fprintf(LP_File,'Minimize\n\nObj: ');

if fileTypeFlag == 2
    arrayfun(@(x) fprintf(LP_File,'X_%d + ', x-1), 1:dimension-1);
    fprintf(LP_File,'X_%d\n\n', dimension-1);
else
    arrayfun(@(x) fprintf(LP_File,'Y_%d + ', x-1), 1:dimension-1);
    fprintf(LP_File,'Y_%d\n\n', dimension-1);
end

fprintf(LP_File,'Subject to\n\n');

% for constraintNum = 1 : rank
%     currConstraintIndex = constraintNum - 1;
%     fprintf(LP_File,'c_%d: ', currConstraintIndex);
%     arrayfun(@(x, y) fprintf(LP_File, '%+.2fX_%d ', x, y-1), A(constraintNum, :), 1:dimension);
%     fprintf(LP_File,'= %.2f\n\n', b(constraintNum));
% end

% for i = 1 : rank
%     fprintf(LP_File,'c_%d: ',i-1);
%     for j = 1 : dimension
%         fprintf(LP_File,'%+.2fX_%d ',A(i,j),j-1);
%     end
%     fprintf(LP_File,'= %f\n\n',b(i));
% end

CS_MIQP_GenerateConstraint(LP_File, A, b)

% for i = 1 : rank
%     fprintf(LP_File,'c_%d: ',i-1);
%     for j = 1 : dimension
%         fprintf(LP_File,'%+.2fX_%d ',A(i,j),j-1);
%     end
%     fprintf(LP_File,'= %f\n\n',b(i));
% end

fprintf(LP_File,'\n');

if fileTypeFlag == 0 % L0_file generation
    
    arrayfun(@(x) fprintf(LP_File,'X_%d - Y_%d <= 0\n', x-1, x-1), 1:dimension);
    
    fprintf(LP_File,'\nBounds\n\n');
    arrayfun(@(x) fprintf(LP_File,'0 <= X_%d\n', x-1), 1:dimension);
    
    fprintf(LP_File,'\nBinary\n\n');
    arrayfun(@(x) fprintf(LP_File,'Y_%d\n',x-1), 1:dimension);
    
elseif fileTypeFlag == 1
    
    arrayfun(@(x) fprintf(LP_File,'X_%d - Y_%d <= 0\n', x-1, x-1), 1:dimension);
    
    fprintf(LP_File,'\nBounds\n\n');
    
    arrayfun(@(x) fprintf(LP_File,'0 <= X_%d\n', x-1), 1:dimension);
    arrayfun(@(x) fprintf(LP_File,'1 >= Y_%d\n',x-1), 1:dimension);
    
else
    
    fprintf(LP_File,'Bounds\n\n');
    arrayfun(@(x) fprintf(LP_File,'0 <= X_%d <= 1\n', x-1), 1:dimension);
    
end

fprintf(LP_File,'\nEnd');
fclose(LP_File);

end