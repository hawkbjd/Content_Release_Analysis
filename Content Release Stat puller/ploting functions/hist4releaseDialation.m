function [value,centers] = hist4releaseDialation(release_start2max)
% Histogram of time from release start to max intensity for 1st release event
% for each trace if there is a release event

try
    c = figure;
    %sets hist perameters
    tmp = (release_start2max*20)/1000;
    low = 0;
    high = 2;
    num_of_bins = 20;
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
    title('Release Dialation')
    xlabel('ms')
    ylabel('% of Events')
    
%     ytickformat('%d%%')
catch ME
    disp(ME.message)
    disp('no close events')
    delete(c)
end 