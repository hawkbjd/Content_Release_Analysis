function [traces_corrected,fit_stats] = background_correction(traces)

[num_of_traces,num_of_frames] = size(traces);
x = 1:num_of_frames;

if num_of_traces < 10
    least = min(traces,[],'all');
    traces_fit = zeros(1,num_of_frames) + least;
    fit_stats.constants = least;
    fit_stats.mu = [];
else
    traces_min = min(traces,[],1);
    traces_rolling = movmean(traces_min,25);
    [p,~,mu] = polyfit(x,traces_rolling, 15);
    traces_fit = polyval(p,x,[],mu);
    fit_stats.constants = p;
    fit_stats.mu = mu;
end

traces_corrected = traces - traces_fit;

fit_stats.fit = traces_fit;