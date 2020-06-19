function [traces_open2close,first_open_duration] = get_traces_open2close(open,close,traces_corrected)
%     open = g_spots.release_time(:,2); close = g_spots.close_time(:,2);
    
    event_index = open(:, 1) > 0;
    open = open(event_index,:);
    close = close(event_index,:);
    [r,~] = size(open);
    open_duration = zeros(r,2);
    open_duration(:,1) = (1:r)';
    open_duration(:,2) = close - open;
    non_zero_duration = open_duration(:,2) > 0;
    open_duration(~non_zero_duration,:) = [];
    event = open_duration(:,1);
    event_length = open_duration(:,2) + 1;
    [num_of_open_events,~] = size(open_duration);
    traces_open2close = zeros(num_of_open_events,3000); 
    for i = 1:num_of_open_events
        traces_open2close(i,1:event_length(i)) = traces_corrected(event(i),open(event(i)):close(event(i)));
    end    
    first_open_duration = open_duration;