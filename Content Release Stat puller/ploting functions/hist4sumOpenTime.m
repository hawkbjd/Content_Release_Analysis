function [value,centers] = hist4sumOpenTime(time_pore_open)
% Sum of pore open times for each event
% try
    e = figure;
    %sets hist perameters
    tmp = time_pore_open*20;
    low = min(tmp);
    high = max(tmp);
    num_of_bins = 40;
    bins = low:high/num_of_bins:high;
    h = histogram(tmp,bins,'Normalization','probability');
    value = (h.Values)';
    centers = movmean(h.BinEdges,2);
    centers = centers(2:end)';    
    y_max = max(h.Values);
    y_max = y_max + 0.15*y_max;
    ylim([0 y_max]);
    step = round(y_max/10,2);
    range = 0:step:y_max;
    yticks(range)
    range = range .* 100;
    labels = compose('%3.0f%%',range);
    yticklabels(labels)
    title('Amount of pore open per event')
    xlabel('sec')
    ylabel('% of Events')
% catch ME
%     disp(ME.message)
%     disp('no close events')
%     delete(e)
% end
