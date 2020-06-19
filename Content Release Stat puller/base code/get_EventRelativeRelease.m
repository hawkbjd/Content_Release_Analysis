function [decrease] = get_EventRelativeRelease(event_max,event_end,traces)
%compares event length to releative decrease in intensity. Should show time
%of combined small pore and large pore release

%get intensity of end of event
event_num = event_end(:,1);
end_frame = event_end(:,2);
ind = sub2ind(size(traces),event_num,end_frame);
intensity_at_event_end = traces(ind);

%gets releative decrease for event
decrease = (event_max - intensity_at_event_end)./event_max;