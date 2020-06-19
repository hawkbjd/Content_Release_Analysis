figure

%set hist parameters
low = 0;
high = 4;
num_of_bins = 30;
bins = (low:(high/num_of_bins):high)';

%removes all events that do not have release
aS_124_no_release = aS_124.cum_release_duration(:,2) > 0;
aS_124_cum_release_duration = aS_124.cum_release_duration(aS_124_no_release,2);

aS_WT_no_release = aS_WT.cum_release_duration(:,2) > 0;
aS_WT_cum_release_duration = aS_WT.cum_release_duration(aS_WT_no_release,2);

SNARE_no_release = SNARE_alone.cum_release_duration(:,2) > 0;
SNARE_cum_release_duration = SNARE_alone.cum_release_duration(SNARE_no_release,2);

%converts frames to seconds
aS_124_cum_release_duration = (aS_124_cum_release_duration*20)/1000;
aS_WT_cum_release_duration = (aS_WT_cum_release_duration*20)/1000;
SNARE_cum_release_duration = (SNARE_cum_release_duration*20)/1000;

%make sure all data is ploted by stacking values greater than max into last
%bin
aS_124_outlier = aS_124_cum_release_duration > high;
aS_124_num_outlier = sum(aS_124_outlier);
aS_124_filler = ones(aS_124_num_outlier,1)*high;
aS_124_cum_release_duration = [aS_124_cum_release_duration(~aS_124_outlier);aS_124_filler];

aS_WT_outlier = aS_WT_cum_release_duration > high;
aS_WT_num_outlier = sum(aS_WT_outlier);
aS_WT_filler = ones(aS_WT_num_outlier,1)*high;
aS_WT_cum_release_duration = [aS_WT_cum_release_duration(~aS_WT_outlier);aS_WT_filler];

SNARE_outlier = SNARE_cum_release_duration > high;
SNARE_num_outlier = sum(SNARE_outlier);
SNARE_filler = ones(SNARE_num_outlier,1)*high;
SNARE_cum_release_duration = [SNARE_cum_release_duration(~SNARE_outlier);SNARE_filler];


%make hist plots
hold on
aS_124_release_duration_hist = histogram(aS_124_cum_release_duration,bins,'Normalization','probability');
aS_WT_release_duration_hist = histogram(aS_WT_cum_release_duration,bins,'Normalization','probability');
SNARE_release_duration_hist = histogram(SNARE_cum_release_duration,bins,'Normalization','probability');

title('Release Duration w/o zeros')
legend('aS 124','aS WT','SNARE alone')
xlabel('Release Duration (s)')
ylabel('Frequence')
hold off