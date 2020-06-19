function cum_release_duration(release_duration)
try
    a = figure;
    
    %sets hist perameters
    release_duration = (release_duration*20)/1000;
    
    %starting values
    low = min(release_duration);
    high = max(release_duration);
    
    %set later
%     low = 0;
%     high = 5;
    num_of_bins = 30;
    bins = low:high/num_of_bins:high;
    
    % sets "more" values
    A = (release_duration > bins(end-1));
    release_duration = release_duration(~A); 
    release_duration = [release_duration; ones(sum(A),1)*bins(end)];
    sum(release_duration == 0);
    
    h = histogram(release_duration,bins,'Normalization','probability');
    value = (h.Values)';
    title('Cum Release Duration')
    xlabel('Time (s)')
    ylabel('Frequency of Events')
catch ME
    disp(ME.message)
    disp('no release events')
    delete(a)
end