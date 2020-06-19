function [trace_start2end,event_duration] = get_trace_start2end(event_start,event_end,traces_corrected)
%     event_start = g_spots.dock_time(:,2); event_end = g_spots.end_time(:,2);
    
    num_of_events = length(event_start);
    num_of_frames = length(traces_corrected(1,:));
    trace_start2end = zeros(num_of_events,num_of_frames);
    event_duration = zeros(num_of_events,2);
    for r = 1:num_of_events
        event_duration(r,1) = r;
        event_duration(r,2) = event_end(r) - event_start(r) + 1;
        trace_start2end(r,1:event_duration(r,2)) = traces_corrected(r,event_start(r):event_end(r));
    end