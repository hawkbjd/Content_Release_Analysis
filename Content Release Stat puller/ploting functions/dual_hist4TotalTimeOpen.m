%set data and convert to seconds
aS_data = aS.time_pore_opened(:,2);
SANRE_only_data = SNARE_alone.time_pore_opened(:,2);
aS_data = (aS_data*20)/1000;
SANRE_only_data = (SANRE_only_data*20)/1000;

%get min and max of data
aS_min = min(aS_data);
SNARE_min = min(SANRE_only_data);
aS_max = max(aS_data);
SNARE_max = max(SANRE_only_data);

%set hist parameters
low = min(aS_min,SNARE_min);
high = 4;
num_of_bins = 16;
figure
bins = low:high/num_of_bins:high;
a = histogram(aS_data,bins,'Normalization','probability');hold on
b = histogram(SANRE_only_data,bins,'Normalization','probability'); hold off

title('Total Time Open per event')
xlabel('sec')
ylabel('Frequency')
legend('aS','SNARE only')

bins = bins'