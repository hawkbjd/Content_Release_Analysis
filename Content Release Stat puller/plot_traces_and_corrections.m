function plot_traces_and_corrections(data_structure)



num_of_files = length(data_structure.traces);


for f = 1:num_of_files
    [num_of_traces,num_of_frames] = size(data_structure.traces(f).corrected);
    x = 1:num_of_frames;
    
    figure
    plot(x, data_structure.new_g_spots(f).donor); hold on
    plot(x, data_structure.fits(f).fit,'LineWidth',4); hold off
    text = ['Raw Traces: ',num2str(f)];
    title(text)
    dim = [0.2 0.5 0.3 0.3];
    str = ['# of Traces: ', num2str(num_of_traces)];
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    
    figure
    plot(x,data_structure.traces(f).corrected)
    text = ['Corrected Traces: ',num2str(f)];
    title(text)
end