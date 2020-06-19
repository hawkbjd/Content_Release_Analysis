function percent_release_type(release_type_calc)

release_categories  = release_type_calc(:,1);
event_percent  = release_type_calc(:,2);

figure
bar(release_categories,event_percent)
title('Number of Releases per event')
xlabel('# of releases')
ylabel('% of Events')
















