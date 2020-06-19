function num_of_traces = get_filename_and_num_traces(source_dir,source_filenames)

[~,num_of_files] = size(source_filenames);
num_of_traces = {num_of_files,2};

for f = 1:num_of_files
    disp(source_filenames{f})
    file  = fullfile(source_dir,source_filenames{f});
    load(file);
    disp(g_spots.total)
    num_of_traces{f,1} = source_filenames{f};
    num_of_traces{f,2} = g_spots.total;
end
