function CS_MIQP_GenerateConstraint(LP_File, Q, b)

[~, dimension] = size(Q);

% for i = 1 : dimension
%     eval(['syms X_' num2str(i)])
% end

part1 = [];

for i = 1 : dimension
    part1   = [part1 sprintf('X_%d ', i-1)];
end

part1   = ['[' strtrim(part1) ']'];
part2   = strrep(strtrim(part1), ' ', ';');
part1   = sym(part1);
part2   = sym(part2);
x       = vpa(simplify(part1*double(Q)*part2), 3);
x       = char(x);
expression = '(\d).(\d)+';
[~, EndIndex] = regexp(x,expression);
x(EndIndex+1) = ' ';


fprintf(LP_File, 'c1: [%s]= %0.2f\n', strtrim(x), b);

end