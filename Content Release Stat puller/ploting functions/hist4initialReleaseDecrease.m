function [value,centers] = hist4initialReleaseDecrease(first_release_intensity_decrease)
% Histogram of relative differnece between max intensity of 1st release event and
%end of 1st release event

try
    d = figure;
    %sets hist perameters
    tmp = first_release_intensity_decrease*100;
    low = 0;
    high = 100;
    num_of_bins = 35;
    bins = low:high/num_of_bins:high;
    h = histogram(tmp,bins,'Normalization','probability');
    value = (h.Values)';
    centers = movmean(h.BinEdges,2);
    centers = centers(2:end)';      
    y_max = max(h.Values);
    y_max = y_max + 0.15*y_max;
    ylim([0 y_max])
    yticks(0:5:ceil(y_max))
    yticklabels(compose('%d%%',0:5:(ceil(y_max)*100)));
    title('Decrease in Intensity for 1st release event')
    xlabel('% devrease')
    ylabel('Population %')
catch ME
    disp(ME.message)
    disp('no release events')
    delete(d)
end