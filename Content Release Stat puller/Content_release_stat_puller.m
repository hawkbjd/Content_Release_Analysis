function  processed = Content_release_stat_puller()

%gets .mat files to pull data from
[source_filenames,source_dir] = get_source_files;

tic

[~,num_of_files] = size(source_filenames);
event_max_intensity = [];
individual_fusion_pore_duration = [];
dilation_time = [];
shrink_time = [];
cum_release_duration = [];
releases_per_event = [];
cum_event_intensity_decrease = [];
event_length = [];
first_release_length = [];
first_release_intensity_decrease = [];


if isa(source_filenames,'cell')
    for f = 1:num_of_files
        file = fullfile(source_dir,source_filenames{f})
        
        [start2end_max,individual_open_duration,...
            open2max,max2close,cum_time_open,...
            num_of_release_events,percent_total_release,...
            new_g_spots,event_duration,...
            first_open_duration,fit_stats,traces,...
            percent_first_release_release] = base_code(file);
        
        cum_event_intensity_decrease = [cum_event_intensity_decrease;percent_total_release];
        event_max_intensity = [event_max_intensity;start2end_max];
        individual_fusion_pore_duration = [individual_fusion_pore_duration;individual_open_duration];
        dilation_time = [dilation_time;open2max];
        shrink_time = [shrink_time;max2close];
        cum_release_duration = [cum_release_duration;cum_time_open];
        releases_per_event = [releases_per_event;num_of_release_events];
        processed.new_g_spots(f) = new_g_spots;
        event_length = [event_length;event_duration];
        first_release_length = [first_release_length;first_open_duration];  
        processed.fits(f) = fit_stats;
        processed.traces(f) = traces;
        first_release_intensity_decrease = [first_release_intensity_decrease;percent_first_release_release];
        
    end 
    
    [release_type_percent,release_type_summary] = get_percent_type(releases_per_event(:,2));    
    
    processed.TimeStamp = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    [processed.num_of_events] = length(event_max_intensity);
    processed.num_of_files =  num_of_files;
    processed.cum_event_intensity_decrease = cum_event_intensity_decrease;    
    processed.release_type_calc = [release_type_percent,release_type_summary];
    processed.event_max_intensity = event_max_intensity;
    processed.releases_per_event = releases_per_event;
    processed.cum_release_duration = cum_release_duration;
    processed.individual_fusion_pore_duration = individual_fusion_pore_duration(individual_fusion_pore_duration(:,1)>0,:);
    processed.dilation_time = dilation_time;
    processed.shrink_time = shrink_time;
    processed.event_length = event_length;
    processed.first_release_length = first_release_length;
    processed.first_release_intensity_decrease = first_release_intensity_decrease;
    processed.files = source_filenames';
    
    toc        

else
    if file == 0
        return
    end
    file = fullfile(source_dir,source_filenames)
    [start2end_max,individual_open_duration,...
            open2max,max2close,cum_time_open,...
            num_of_release_events,percent_total_release,...
            new_g_spots,event_duration,...
            first_open_duration,fit_stats,traces,...
            percent_first_release_release] = base_code(file);
        
    processed.TimeStamp = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    processed.num_of_events = length(start2end_max);
    processed.num_of_files = 1;
    processed.cum_event_intensity_decrease = percent_total_release;
    [release_type_percent,release_type_summary] = get_percent_type(num_of_release_events(:,2));
    processed.release_type_calc = [release_type_percent,release_type_summary];
    processed.event_max_intensity = start2end_max;
    processed.releases_per_event = num_of_release_events;
    processed.cum_release_duration = cum_time_open;
    processed.individual_fusion_pore_duration = individual_open_duration;
    processed.dilation_time = open2max;
    processed.shrink_time = max2close;
    processed.event_length = event_duration;
    processed.first_release_length = first_open_duration;
    processed.first_release_intensity_decrease = percent_first_release_release;
    processed.files = source_filenames;
    processed.new_g_spots = new_g_spots;
    processed.fits = fit_stats;
    processed.traces = traces;    
       
    toc
end    

% %   Gets user input for file name
disp('look for promt')

file_name = inputdlg('What do you want the file name to be?');
if isempty(file_name)
    file_name = 'processes';
end
file_name = [file_name{1},'.xlsx'];

mat2xlsx(source_dir,file_name,processed);

disp('Done! :-)')