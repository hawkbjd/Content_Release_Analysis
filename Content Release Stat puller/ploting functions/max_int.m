figure

%set hist parameters
low = 0;
high = 12.5;
num_of_bins = 50;

bins = (low:(high/num_of_bins):high)';

%find mean int of SNARE events with no release
SNARE_no_release = SNARE_alone.releases_per_event(:,2) == 0;
SNARE_no_release = SNARE_alone.event_max_intensity(SNARE_no_release,1);
non_release_int = mean(SNARE_no_release);

%make intensities relative to non release intensity
aS_124_int = aS_124.event_max_intensity(:,1);
aS_124_int = aS_124_int/non_release_int;
aS_WT_int = aS_WT.event_max_intensity(:,1);
aS_WT_int = aS_WT_int/non_release_int; 
SNARE_int = SNARE_alone.event_max_intensity(:,1);
SNARE_int = SNARE_int/non_release_int;

%make sure all data is ploted by stacking values greater than max into last
%bin
aS_124_outlier = aS_124_int > high;
aS_124_num_outlier = sum(aS_124_outlier);
aS_124_filler = ones(aS_124_num_outlier,1)*high;
aS_124_int = [aS_124_int(~aS_124_outlier);aS_124_filler];

aS_WT_outlier = aS_WT_int > high;
aS_WT_num_outlier = sum(aS_WT_outlier);
aS_WT_filler = ones(aS_WT_num_outlier,1)*high;
aS_WT_int = [aS_WT_int(~aS_WT_outlier);aS_WT_filler];

SNARE_outlier = SNARE_int > high;
SNARE_num_outlier = sum(SNARE_outlier);
SNARE_filler = ones(SNARE_num_outlier,1)*high;
SNARE_int = [SNARE_int(~SNARE_outlier);SNARE_filler];

%make hist plots
hold on
aS_124_max_int_hist = histogram(aS_124_int,bins,'Normalization','probability');
aS_WT_max_int_hist = histogram(aS_WT_int,bins,'Normalization','probability');
snare_alone_max_int_hist = histogram(SNARE_int,bins,'Normalization','probability');


% make vertical line for release threshold
Values = [aS_124_max_int_hist.Values,aS_WT_max_int_hist.Values,snare_alone_max_int_hist.Values];
line([1 1], [0 max(Values)],'LineWidth', 2,'Color', 'k','LineStyle','--')

%Labels
title('Max Fluorescence Intensity')
legend('aS 124','aS WT','SNARE alone')
xlabel('Fluorescence Intensity (a.u.)')
ylabel('Frequence')
hold off