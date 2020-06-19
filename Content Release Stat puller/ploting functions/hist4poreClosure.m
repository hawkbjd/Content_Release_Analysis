function [value,centers] = hist4poreClosure(max2release_end)
% Histogram of time from max to end of 1st release event
try
    d = figure;
    %sets hist perameters
    tmp = (max2release_end *20);
    low = min(tmp);
    high = max(tmp);
    num_of_bins = 50;
    bins = low:high/num_of_bins:high;
    % uses hist data to make bar graph
    % silly, but easiest way to make y-axis 0=> 100
    h = histogram(tmp,bins,'Normalization','probability');
    value = (h.Values)';
    centers = movmean(h.BinEdges,2);
    centers = centers(2:end)';      
    y_max = max(h.Values);
    y_max = y_max + 0.15*y_max;
    ylim([0 y_max])
    yticks(0:0.05:ceil(y_max))
    yticklabels(compose('%d%%',0:5:(ceil(y_max)*100)));
    title('Time for pore to close')
    xlabel('sec')
    ylabel('% of Events')
catch ME
    disp(ME.message)
    disp('no close events')
    delete(d)
end