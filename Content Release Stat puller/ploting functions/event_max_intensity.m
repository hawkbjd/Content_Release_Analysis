function event_max_intensity (max_intensity)
% Histogram for max intinsty of event

figure
%sets hist perameters

% values to start with
low = min(max_intensity);
high = max(max_intensity);

% values to set later
% low = 0;
% high = 140;
num_of_bins = 20;
bins = low:high/num_of_bins:high;

% sets "more" values
A = (max_intensity > bins(end-1));
max_intensity = max_intensity(~A); 
max_intensity = [max_intensity; ones(sum(A),1)*bins(end)];
sum(max_intensity == 0);

% makes plots
h = histogram(max_intensity,bins,'Normalization','probability');hold on;
title('Event Max Intensities')
xlabel('Intensity (au)')
ylabel('Frequency of Events')