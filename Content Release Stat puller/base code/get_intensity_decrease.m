function percent_release = get_intensity_decrease(event_max_intensity,end_release,traces,max_int_with_background)
%gets ratio of max intensity of event vs. intensity at end of last release
%event

end_release = end_release(:,2:end);
[num_of_events,~] = size(end_release);
end_of_last_release_index = zeros(num_of_events,2);
end_of_last_release_index(:,1) = (1:num_of_events)';
end_of_last_release_index(:,2) = sum(end_release > 0,2);
release_index = end_of_last_release_index(:,2) > 0;
end_of_last_release_index = end_of_last_release_index(release_index,:);
[num_of_events,~] = size(end_of_last_release_index);
end_of_last_release_frame = zeros(num_of_events,2);

for i = 1:num_of_events
    end_of_last_release_frame(i,1) = end_of_last_release_index(i,1);
    end_of_last_release_frame(i,2) = end_release(end_of_last_release_index(i,1),end_of_last_release_index(i,2));
end

end_of_last_release_intensity = zeros(num_of_events,2);
for c = 1:num_of_events
    end_of_last_release_intensity(c,1) = end_of_last_release_frame(c,1);
    end_of_last_release_intensity(c,2) = traces(end_of_last_release_frame(c,1),end_of_last_release_frame(c,2));
end    

event_max_intensity = event_max_intensity(release_index);
max_int_with_background = max_int_with_background(release_index);

percent_release =  (event_max_intensity - end_of_last_release_intensity(:,2))./max_int_with_background;
percent_release = [percent_release,event_max_intensity,max_int_with_background,end_of_last_release_intensity];