clear all

% put file you wish to test with in the same directory at this script and
% then change the name of the file below to match the one you want to test
load 'new_20190415_A03_SNAREonly_dye(30uM)_gspots.mat'

%get rid of all rows that are just 0
g_spots = data_cleaing(g_spots);

% uses a min value and fitting to correct for background
[traces_corrected,fit_stats] = background_correction(g_spots.donor);

%gets trace segments for whole event
[traces_start2end,event_duration] =...
    get_trace_start2end(g_spots.dock_time(:,2),g_spots.end_time(:,2),traces_corrected);

%gets max of intendity for event
[start2end_max] = max(traces_start2end,[],2);

%gets traces for 1st open to close in an event
[traces_open2close,first_open_duration] =...
    get_traces_open2close(g_spots.release_time(:,2),g_spots.close_time(:,2),traces_corrected);

%gets duration individual release
individual_open_duration = get_open_time(g_spots.release_time,g_spots.close_time);

%gets duration of closed events between open events
close_duration = get_close_time(g_spots.release_time,g_spots.close_time);

%gets time from start of open event to max and from max to end of open
%event
[open2max,max2close] = get_open2max(traces_open2close,first_open_duration(:,2));

%gets cumulative release duration for events
[num_of_release_events,time_open] =...
    get_cum_release_duration(event_duration,individual_open_duration);

%gets relative differnece between max intensity of event vs. intensity at end of last release
%event
percent_total_release = get_percent_release(start2end_max,traces_corrected,g_spots.release_time(:,2:end),g_spots.close_time(:,2:end));

%gets relative differnece between max intensity of 1st release event and
%end of 1st release event
percent_first_release_release = get_percent_first_release_decrease(g_spots.donor, traces_corrected,g_spots.release_time(:,2),g_spots.close_time(:,2));


%gather traces
traces.corrected = traces_corrected;
traces.event = traces_start2end;
traces.releases = traces_open2close;