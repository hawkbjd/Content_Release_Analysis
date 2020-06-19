function cum_content_release(intensity_decrease)
try
    b = figure;
    
    %sets hist perameters
    intensity_decrease = intensity_decrease*100;
    
    low = 0;
    high = 100;    
    num_of_bins = 20;
    bins = low:high/num_of_bins:high;
    
    histogram(intensity_decrease,bins,'Normalization','probability');
    title('Cumulative Content Release')
    xlabel('Relative Release (%)')
    ylabel('% of Events')
catch ME
    disp(ME.message)
    disp('no release events')
    delete(b)
end