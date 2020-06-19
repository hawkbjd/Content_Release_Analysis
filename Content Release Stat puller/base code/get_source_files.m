function [source_filenames,source_dir] = get_source_files
%%looks for .mat files in a given folder. Multiple can be selected. 

[source_filenames, source_dir] = uigetfile( ...
{  '*.mat','Fusion Data Files (*.mat)'}, ...
   'Pick a file', ...
   'MultiSelect', 'on');
if isempty(source_filenames) == 1 
    return
end