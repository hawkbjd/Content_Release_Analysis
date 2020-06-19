

%%%%%
aS_data = aS_raw.releases_per_event(:,2);
SNARE_only_data = SANRE_only.releases_per_event(:,2);

%%%%%%%
range_min = min([aS_data;SNARE_only_data]);
range_max = max([aS_data;SNARE_only_data]);
range = range_min:range_max;
release_master = zeros(length(range),2);

for r = range
   if range_min == 0
       row = r+1;
   else
       row = r;
   end
   release_master(row,1) = sum(aS_data == r);
   release_master(row,2) = sum(SNARE_only_data == r); 
end    

event_index = sum(release_master > 0,2) > 0;
release_master = release_master(event_index,:);
range = range(event_index);
[num_of_types,~] = size(release_master);
percent_master = zeros(num_of_types,2);
percent_master(:,1) = release_master(:,1)./sum(release_master(:,1));
percent_master(:,2) = release_master(:,2)./sum(release_master(:,2));


%%%%%%
figure
bar(range,percent_master)
title('Number of Releases per event')
xlabel('# of releases')
ylabel('% of Events')
legend('aS','SNARE only')








