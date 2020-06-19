function percent_first_release_release = get_percent_first_release_decrease(~, corrected_traces,start_of_release,end_of_release)
% gets relative decrease in intensity from max of 1st release event to end
% of 1st release event

% original_traces = g_spots.donor; corrected_traces = traces_corrected; start_of_release = g_spots.release_time(:,2); end_of_release = g_spots.close_time(:,2);


%setup event number
[number_of_evnts,~] = size(start_of_release);
event_number = (1:number_of_evnts)';

%check that event has release and remove events that have no release
release_index = start_of_release(:,1) > 0;
start_of_release = start_of_release(release_index,:);
end_of_release = end_of_release(release_index,:);
event_number = event_number(release_index);

%check that event has an end of release
pass_index = end_of_release(:,1) > 0;
start_of_release = start_of_release(pass_index,:);
end_of_release = end_of_release(pass_index,:);
event_number = event_number(pass_index);

%gets max intensity for release
[number_of_traces,~] = size(start_of_release);
max_release_intensty_corrected = zeros(number_of_traces,1);
start_of_release = start_of_release(:,1);
end_of_release = end_of_release(:,1);

for t = 1:number_of_traces
    max_release_intensty_corrected(t) = max(corrected_traces(event_number(t),start_of_release(t):end_of_release(t)));
end

%gets intensity at end of 1st release
ind = sub2ind(size(corrected_traces),event_number,end_of_release);
end_intensity_corrected = corrected_traces(ind);
% 
%gets the percent decrease of intensity as:
%P = (Max(corrected)-end_int(corrected)/Max(Raw)
percent_first_release_release = (max_release_intensty_corrected - end_intensity_corrected) ./ max_release_intensty_corrected;

% percent_first_release_release = [event_number,end_of_release,max_release_intensty_raw,max_release_intensty_corrected,end_intensity_corrected,percent_first_release_release];
percent_first_release_release = [event_number,percent_first_release_release];
