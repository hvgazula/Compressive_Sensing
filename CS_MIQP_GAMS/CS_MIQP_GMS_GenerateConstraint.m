function myConstraintString = CS_MIQP_GenerateConstraint_GAMS(Q, b)

[~, dimension] = size(Q);

myString = [];
for i = 1 : dimension
    myString = [myString num2str(Q(i,i), '%+.2f') '*sqr(X' num2str(i-1) ') '];
end

for j = 1 : dimension - 1
    for k = j + 1 : dimension
        myString = [myString  num2str(2*Q(j, k), '%+.2f') '*X' num2str(j-1) '*X' num2str(k-1) ' '];
    end
end

myConstraintString = sprintf('CON1.. %s =E= %0.2f ;\n', strtrim(myString), b);


% for i = 1 : dimension
%     eval(['syms X' num2str(i)])
% end
% 
% part1 = [];
% 
% for i = 1 : dimension
%     part1   = [part1 sprintf('X%d ', i-1)];
% end
% 
% part1   = ['[' strtrim(part1) ']'];
% part2   = strrep(strtrim(part1), ' ', ';');
% part1   = sym(part1);
% part2   = sym(part2);
% x       = vpa(simplify(part1*double(Q)*part2), 3);
% x       = char(x);
% % expression = '(\d).(\d)+';
% % [~, EndIndex] = regexp(x,expression);
% % x(EndIndex+1) = ' ';
% 
% for j = 1 : dimension
%     oldSubStr = ['X' num2str(j-1) '^2'];
%     newSubStr = ['sqr(X' num2str(j-1) ')'];
%     x = strrep(x, oldSubStr, newSubStr);
% end
% 
% myConstraintString = sprintf('CON1.. %s =E= %0.2f ;\n', strtrim(x), b);

end