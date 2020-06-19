function [open2max,max2close] = get_open2max(traces_open2close,span)
    % Get trace max
    [~,max_index] = max(traces_open2close,[],2);
    
    %Get open to trace max
    open2max = max_index;
    
    %Get trace max to close
    max2close = span - max_index;        