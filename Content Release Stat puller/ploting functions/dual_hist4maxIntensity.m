figure
%sets hist perameters
aS_data = aS_raw.time_pore_opened(:,2);
SANRE_only_data = SANRE_only.time_pore_opened(:,2);
aS_data = (aS_data*20)/1000;
SANRE_only_data = (SANRE_only_data*20)/1000;
low = 0;
high = 7;
num_of_bins = 30;
bins = low:high/num_of_bins:high;
a = histogram(aS_data,bins,'Normalization','probability');hold on
b = histogram(SANRE_only_data,bins,'Normalization','probability'); hold off

a_max = a.Values;
b_max = b.Values;
y_max = max([a_max,b_max]);
y_max = y_max + 0.15*y_max;
ylim([0 y_max])
y_max = ceil(y_max);
yticks(0:0.1:y_max)
yticklabels(compose('%d%%',0:10:(ceil(y_max)*100)));

title('Amount of pore open per event')
xlabel('sec')
ylabel('% of Events')
legend('aS','SNARE only')