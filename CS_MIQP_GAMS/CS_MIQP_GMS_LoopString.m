function CS_MIQP_GMS_LoopString(LP_File, myString, loopRange, varargin)

if nargin > 3
    arrayfun(@(x) fprintf(LP_File, myString, x, x), loopRange);
else
    %     arrayfun(@(x) fprintf(LP_File, myString, x), loopRange);
    for i = loopRange
        fprintf(LP_File, myString, i);
    end
end

end