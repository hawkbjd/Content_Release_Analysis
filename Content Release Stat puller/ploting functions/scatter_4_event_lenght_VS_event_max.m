function scatter_4_event_lenght_VS_event_max(eventLengthVSmax)
figure
event_length = eventLengthVSmax(:,1);
event_length = event_length .* 20;
event_max = eventLengthVSmax(:,2);
plot(event_length,event_max,'.')
title('Event Length Vs. Event Max Intensity')
xlabel('Event Length')
ylabel('Max Intensity (au)')
