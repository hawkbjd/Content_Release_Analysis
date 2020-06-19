function mat2xlsx(source_dir,file_name,data_structure)

% turn of warning about adding a sheet
warning('off','MATLAB:xlswrite:AddSheet')

script_folder = fileparts(mfilename('fullpath'));

new_folder = fullfile(source_dir,'processed');

if ~exist(new_folder, 'dir')
    mkdir(new_folder);
    cd(new_folder)
else
    cd(new_folder)
end

copyfile(fullfile(script_folder,'template.xlsx'),file_name)

%   Cum amount of content release
Event_Number = data_structure.cum_event_intensity_decrease(:,1);
Percent_Decrease = data_structure.cum_event_intensity_decrease(:,2) * 100;
T = table(Event_Number,Percent_Decrease);
writetable(T,file_name,'Sheet','Cum % release')

%   Number of release per event
%raw
Num_of_Releases = data_structure.releases_per_event(:,2);
T = table(Event_Number,Num_of_Releases);
writetable(T,file_name,'Sheet','Number of release')

%summary
Num_of_Releases = data_structure.release_type_calc(:,1);
Count = data_structure.release_type_calc(:,4);
Percent = data_structure.release_type_calc(:,2);
T = table(Num_of_Releases,Count,Percent);
writetable(T,file_name,'Sheet','Number of release','Range','D1')

%   Event max intensity
Max_intensity = data_structure.event_max_intensity;
T = table(Event_Number,Max_intensity);
writetable(T,file_name,'Sheet','Max intensity')

%   Cum release duration
Release_duration_frame = data_structure.cum_release_duration(:,2);
Release_duration_ms = Release_duration_frame*20;
Release_duration_sec = Release_duration_ms/1000;
T = table(Event_Number,Release_duration_frame,Release_duration_ms,Release_duration_sec);
writetable(T,file_name,'Sheet','Cum release duration')

%   Duration of each release event
Event_Number = data_structure.individual_fusion_pore_duration(:,1);
Which_release = data_structure.individual_fusion_pore_duration(:,2);
Release_duration_frame = data_structure.individual_fusion_pore_duration(:,3);
Release_duration_ms = Release_duration_frame*20;
Release_duration_sec = Release_duration_ms/1000;
T = table(Event_Number,Which_release,Release_duration_frame,Release_duration_ms,Release_duration_sec);
writetable(T,file_name,'Sheet','Individual Release')

%   Duration of first release event
Event_Number = data_structure.first_release_length(:,1);
Release_duration_frame = data_structure.first_release_length(:,2);
Release_duration_ms = Release_duration_frame*20;
Release_duration_sec = Release_duration_ms/1000;
T = table(Event_Number,Release_duration_frame,Release_duration_ms,Release_duration_sec);
writetable(T,file_name,'Sheet','First release duration')


%   Release from first release event
Percent_Decrease = data_structure.first_release_intensity_decrease(:,2) * 100;
T = table(Event_Number,Percent_Decrease);
writetable(T,file_name,'Sheet','Individual % release')

%   Whole event length
Event_Number = data_structure.event_length(:,1);
Event_length_frame = data_structure.event_length(:,2);
Event_length_ms = Event_length_frame * 20;
Event_length_sec = Event_length_ms / 1000;
T = table(Event_Number,Event_length_frame,Event_length_ms,Event_length_sec);
writetable(T,file_name,'Sheet','Whole event length')

%   Dilation time : start of release to max int of release (first release
%   only)
Event_Number = data_structure.first_release_length(:,1);
Dilation_time_frame = data_structure.dilation_time;
Dilation_time_ms = Dilation_time_frame * 20;
Dilation_time_sec = Dilation_time_ms / 1000;
T = table(Event_Number,Dilation_time_frame,Dilation_time_ms,Dilation_time_sec);
writetable(T,file_name,'Sheet','Dilation time')

%   Conctration time : max int of release to end of release (first release
%   only)
Contraction_time_frame = data_structure.shrink_time;
Contraction_time_ms = Contraction_time_frame * 20;
Contraction_time_sec = Contraction_time_ms / 1000;
T = table(Event_Number,Contraction_time_frame,Contraction_time_ms,Contraction_time_sec);
writetable(T,file_name,'Sheet','Contraction time')

%   files pooled
files = data_structure.files;
if ~isa(files,'cell')
    files = string(files);
end

T = table(files);
writetable(T,file_name,'Sheet','Files analyzed')


%   summary
Date = data_structure.TimeStamp;
Number_of_files = data_structure.num_of_files;
Number_of_events = data_structure.num_of_events;
T = table(Date,Number_of_files,Number_of_events);
writetable(T,file_name,'Sheet','Summary')

varible = whos('data_structure');

% if varible.bytes >= (1024^3)*2
%     save(file_name(1:end-5),'data_structure','-v7.3')
% else
%     save(file_name(1:end-5),'data_structure')
% end

try 
    save(file_name(1:end-5),'data_structure','-v7.3')
catch
    try
        disp('trying to save as older file type')
        save(file_name(1:end-5),'data_structure')
    catch
        disp('could not save mat file')
        return
    end
end

end