function CS_MIQP_WriteProblem_GAMS(fileID, A, ~, fileTypeFlag, myConstraintString)

[~, dimension] = size(A);
[~, fileName, fileExt] = fileparts(fileID);

LP_File = fopen(fileID,'W+t');

if LP_File < 0
    error('error opening file %s\n\n', fileID);
end

fprintf(LP_File, '$TITLE %s\n', [fileName fileExt]);
fprintf(LP_File, '$OFFSYMXREF OFFSYMLIST OFFLISTING\n\n');

fprintf(LP_File, 'VARIABLES Z ;\n');
fprintf(LP_File, 'POSITIVE VARIABLES ');
if fileTypeFlag == 0
    %     arrayfun(@(x) fprintf(LP_File, 'X%d, ', x), 0:dimension-2);
    CS_MIQP_GMS_LoopString(LP_File, 'X%d, ', 0:dimension-2)
    fprintf(LP_File, 'X%d ;\n', dimension-1);
    fprintf(LP_File, 'BINARY VARIABLES ');
    %     arrayfun(@(x) fprintf(LP_File, 'Y%d, ', x), 0:dimension-2);
    CS_MIQP_GMS_LoopString(LP_File, 'Y%d, ', 0:dimension-2);
    fprintf(LP_File, 'Y%d ;\n\n', dimension-1);
else
    %     arrayfun(@(x) fprintf(LP_File, 'X%d, Y%d, ', x, x), 0:dimension-2);
    CS_MIQP_GMS_LoopString(LP_File, 'X%d, Y%d, ', 0:dimension-2, 1)
    fprintf(LP_File, 'X%d, Y%d ;\n\n', dimension-1, dimension-1);
end

fprintf(LP_File, 'EQUATIONS ');

if fileTypeFlag == 2
    fprintf(LP_File, 'CON1, ');
else
    %     arrayfun(@(x) fprintf(LP_File, 'CON%d, ', x), 1:dimension+1);
    CS_MIQP_GMS_LoopString(LP_File, 'CON%d, ', 1:dimension+1);
end

fprintf(LP_File, 'OBJ;\n\n');

% compSensMIQPGenerateConstraintGAMS(LP_File, A, b)
fprintf(LP_File, myConstraintString);

if fileTypeFlag ~= 2
    arrayfun(@(x) fprintf(LP_File,'CON%d.. X%d - Y%d =L= 0 ;\n', x+1, x-1, x-1), 1:dimension);
end


fprintf(LP_File, 'OBJ.. Z =E= ');
if fileTypeFlag == 2
    %     arrayfun(@(x) fprintf(LP_File, 'X%d + ', x), 0:dimension-2);
    CS_MIQP_GMS_LoopString(LP_File, 'X%d + ', 0:dimension-2);
    fprintf(LP_File, 'X%d ;\n\n', dimension-1);
else
    %     arrayfun(@(x) fprintf(LP_File, 'Y%d + ', x), 0:dimension-2);
    CS_MIQP_GMS_LoopString(LP_File, 'Y%d + ', 0:dimension-2);
    fprintf(LP_File, 'Y%d ;\n\n', dimension-1);
end

fprintf(LP_File, 'MODEL TEST / ALL /;\n\n');
fprintf(LP_File, 'OPTION LIMROW = 0;\n');
fprintf(LP_File, 'OPTION LIMCOL = 0;\n');
fprintf(LP_File, 'OPTION SOLPRINT = OFF;\n');
fprintf(LP_File, 'OPTION SYSOUT = OFF;\n');
fprintf(LP_File, 'OPTION SOLVER = GLOMIQO;\n\n');
fprintf(LP_File, 'SOLVE TEST USING MIQCP MINIMIZING Z;\n\n');
fprintf(LP_File, 'DISPLAY Z.l;') ;

fclose(LP_File);

end