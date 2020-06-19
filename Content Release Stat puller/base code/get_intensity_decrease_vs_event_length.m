function [length_and_decrease] = get_intensity_decrease_vs_event_length(release_times,close_time, event_end_times, corrected_traces)
% gets max intensity for event from start of release to end of event and
% length of event from release to end of event

%get total number of events
[num_of_events,~] = size(release_times);
event_list = (1:num_of_events)';

%get events that have release
release_index = release_times(:,2) > 0;
close_index = close_time(:,2) > 0;
event_index = and(release_index,close_index);

%kust keep events that have release
event_list = event_list(event_index);

%get length of events
lenght_release2end = event_end_times(event_index,2) - release_times(event_index,2) + 1;

%gets number of evnts that have release and sets up data holders for max intensity
num_of_releases = length(event_list);
max_intensity = zeros(num_of_releases,1);

%get max intensity
for e = 1:num_of_releases
    event = event_list(e);
    start = release_times(event,2);
    last = event_end_times(event,2);
    if start >= last
        continue
    end
    hight = max(corrected_traces(event,start:last));
    max_intensity(e) = hight;
end

%gets intensity at end of event
ind = sub2ind(size(corrected_traces),event_list,event_end_times(event_index,2));
intensity_at_event_end = corrected_traces(ind);

%gets releative decrease for event
decrease = (max_intensity - intensity_at_event_end)./max_intensity;
length_and_decrease = [event_list,max_intensity,intensity_at_event_end,lenght_release2end,decrease];
