figure

% set hist parameters
low = 0;
high = 1;
num_of_bins = 20;

bins = (low:(high/num_of_bins):high)';

%remove events w/o release
aS_124_cum_release = aS_124.cum_event_intensity_decrease(:,2) > 0;
aS_124_cum_release = aS_124.cum_event_intensity_decrease(aS_124_cum_release,2);

aS_WT_cum_release = aS_WT.cum_event_intensity_decrease(:,2) > 0;
aS_WT_cum_release = aS_WT.cum_event_intensity_decrease(aS_WT_cum_release,2);

snare_alone_cum_release = SNARE_alone.cum_event_intensity_decrease(:,2) > 0;
snare_alone_cum_release = SNARE_alone.cum_event_intensity_decrease(snare_alone_cum_release,2);

% make plots
hold on
aS_124_release_hist = histogram(aS_124_cum_release,bins,'Normalization','probability');
aS_WT_release_hist = histogram(aS_WT_cum_release,bins,'Normalization','probability');
SNARE_release_hist = histogram(snare_alone_cum_release,bins,'Normalization','probability');

%plot labels
title('Amount of Release without events with no release')
legend('aS 124','aS WT','SNARE alone')
xlabel('Amount of Release')
ylabel('Frequence')
hold off