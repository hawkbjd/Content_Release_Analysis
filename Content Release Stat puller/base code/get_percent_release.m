function [percent_release] = get_percent_release(event_max,corrected_traces,start_release_frame,end_release_frame)
%gets ratio of max intensity of event vs. intensity at end of last release
%event

% event_max = start2end_max; corrected_traces = traces_corrected; start_release_frame = g_spots.release_time(:,2:end); end_release_frame = g_spots.close_time(:,2:end);

%finds column index of end of last release event
[num_of_events,~] = size(end_release_frame);
end_of_last_release_event_index = (1:num_of_events)';
end_of_last_release_column_index = sum(start_release_frame > 0,2);

%revomes events that do not have release events
release_index = end_of_last_release_column_index > 0; 
end_of_last_release_column_index = end_of_last_release_column_index(release_index);
end_of_last_release_event_index = end_of_last_release_event_index(release_index);
event_max = event_max(release_index,:);


%gets frame of end of last release event
%[num_of_releases,~] = size(end_of_last_release_column_index);
ind = sub2ind(size(end_release_frame), end_of_last_release_event_index, end_of_last_release_column_index);
end_of_last_release_frame = end_release_frame(ind);

%Double check that all are real events
event_check = end_of_last_release_frame > 0;
end_of_last_release_frame = end_of_last_release_frame(event_check);
event_max = event_max(event_check,:);
end_of_last_release_event_index = end_of_last_release_event_index(event_check);

%gets intensity of end of last release from corrected traces
ind = sub2ind(size(corrected_traces),end_of_last_release_event_index,end_of_last_release_frame);
int_of_last_release_corrected = corrected_traces(ind);


%gets the percent decrease of intensity as: P = (Max(corrected)-last_int(corrected))/Max(corrected)
percent_release_corrected = (event_max - int_of_last_release_corrected) ./ event_max;


%collect events that have release events
percent_release = [end_of_last_release_event_index,percent_release_corrected];

%add in events that have no release events
event_list = (1:num_of_events)';
no_release_events = setdiff(event_list,end_of_last_release_event_index);
num_no_release_events = length(no_release_events);
filler_zeros = zeros(num_no_release_events,1);
percent_release = [percent_release;[no_release_events,filler_zeros]];

%sort by event number
[~,I] = sort(percent_release(:,1));
percent_release = percent_release(I,:);