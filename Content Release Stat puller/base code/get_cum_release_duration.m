function [num_of_release_events,time_open] = get_cum_release_duration(event_duration,open_duration)

    [number_of_events,~] = size(event_duration);
    num_of_release_events = zeros(number_of_events,2);
    time_open = zeros(number_of_events,1);
    for e = 1:number_of_events
        open_index = open_duration(:,1) == e;
        num_of_release_events(e,2) = sum(open_index,'all');
        time_open(e) = sum(open_duration(open_index,3));
    end
    
    num_of_release_events(:,1) = (1:number_of_events)';
    time_open = [(1:number_of_events)',time_open];