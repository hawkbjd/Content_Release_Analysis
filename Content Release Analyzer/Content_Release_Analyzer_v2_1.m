function varargout = Content_Release_Analyzer_v2_1(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Content_Release_Analyzer_v2_1_OpeningFcn, ...
                   'gui_OutputFcn',  @Content_Release_Analyzer_v2_1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
function Content_Release_Analyzer_v2_1_OpeningFcn(hObject, eventdata, handles, varargin)
global plot_data


handles.output = hObject;
handles.start_frame = get(handles.EB_start_frame,'Value');
handles.end_frame = get(handles.EB_end_frame,'Value');
handles.zoom_start = handles.start_frame;
handles.zoom_end = handles.end_frame;
handles.frame_type = 0;
guidata(hObject, handles);
initialize(handles,1);
addlistener(handles.slider_windowPMA,'Value','PostSet',@listener_slider_windowPMA_Callback);

% addlistener(handles.EB_frame_index,'Value','PostSet',@listener_EB_frame_index_Callback);
set (gcf, 'WindowButtonMotionFcn', @mouseMove);
set ( 0, 'DefaultFigureColor', [1 1 1] )

function varargout = Content_Release_Analyzer_v2_1_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%  PMA WINDOW  %%%%%%%%%%%%%%%%%%%%%%%%%%
function windowPMA_CreateFcn(hObject, eventdata, handles)

function windowPMA_ButtonDownFcn(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%  BACKGROUND  %%%%%%%%%%%%%%%%%%%%%%%%%%
function background_WindowButtonMotionFcn(hObject, eventdata, handles)




function background_WindowButtonDownFcn(hObject, eventdata, handles)
global pma;
global ghandles;
global g_spots;
global g_tmpspot;

clickPoint{1} = get(ghandles.windowPMA,'CurrentPoint');
clickPoint{2} = get(ghandles.windowTRACE,'CurrentPoint');

if pma.len == 0
    return;
end    

%If click on PMA window
currentPoint = clickPoint{1};
if ((currentPoint(1,1) >= 3) && (currentPoint(1,1) < pma.width-3) && ...
           (currentPoint(1,2) >= 3) && (currentPoint(1,2) < pma.height-3))
       
       
%reset release_count
    g_spots.release_count = 2;
    try g_tmpspot.release_time = [];catch;end
    try g_tmpspot.close_time = [];catch;end


%clear all trace window data


       
    mbutton = get(hObject, 'SelectionType');
    
    if strcmpi(mbutton, 'normal')
        index = istherespot(currentPoint(1,1),currentPoint(1,2));
        frame = get(ghandles.EB_frame_index,'Value');
        Clear_trace_window()
        
    %set start for zoom
        if frame - 250 < ghandles.start_frame
            start = ghandles.start_frame;
        else
            start = frame - 250;
        end

        %set end for zoom
        if frame + 250 > ghandles.end_frame
            last = ghandles.end_frame;
        else
            last = frame + 100;
        end    
    
        
        if get(ghandles.windowTRACE,'xlim') ~= [1 pma.len]
            xlim(ghandles.windowTRACE,[ghandles.zoom_start ghandles.zoom_end]); 
        end
        

        if index > 0 %jwk mouse is over a peak get selected peak
            set_tmpspot(index);
            make_tmpspotframe()
            draw_frame()
            display_current_frame_line(frame)
        else         %jwk mouse is not over a peak make current peak
            set_newtmpspot(currentPoint(1,1),currentPoint(1,2))
            make_tmpspotframe()
            draw_frame()
            display_current_frame_line(frame)
        end
    else
        return
    end
        
end

%If click on TRACE window    
currentPoint = clickPoint{2};
XLim = get(ghandles.windowTRACE,'XLim');
YLim = get(ghandles.windowTRACE,'YLim');
if ((currentPoint(1,1) >= XLim(1)) && (currentPoint(1,1) < XLim(2)) && ...
         (currentPoint(1,2) >= YLim(1)) && (currentPoint(1,2) < YLim(2)))
    
    %if left click
    if strcmpi(get(hObject, 'SelectionType'),'normal')
        zoom_bars(1, currentPoint(1,1))
    end
    
    %if right click
    if strcmpi(get(hObject, 'SelectionType'),'alt')
        zoom_bars(2, currentPoint(1,1))
    end
    
    %if middle mouse button pressed
    if strcmpi(get(hObject, 'SelectionType'),'extend')
        if get(ghandles.windowTRACE,'xlim') == [1 pma.len]
            xlim(ghandles.windowTRACE,[ghandles.zoom_start ghandles.zoom_end]);
        else
            xlim(ghandles.windowTRACE,[1 pma.len]);
        end
    end
end








% --- Executes on scroll wheel click while the figure is in focus.
function background_WindowScrollWheelFcn(hObject, eventdata, handles)
global pma;
if eventdata.VerticalScrollCount < 0
        move_slider(-1)
elseif eventdata.VerticalScrollCount > 0
        move_slider(1)
end

%JWK_FIX 'a' docking 's' hemifusion 'd'fusion 'p' delete 'x' content
%release start 'c' content release stop 'z' content seen 'w' all lipid
%events 'e' content docking and start of release
function background_WindowKeyPressFcn(hObject, eventdata, handles)
global g_tmpspot;
global g_spots;
global MAX_NUM_SPOTS;
global ghandles

set(ghandles.uipanel8,'ForegroundColor','b')

spot_exist = 1; 
if g_tmpspot.index < 1 || g_tmpspot.index > MAX_NUM_SPOTS
   spot_exist = 0; 
end
%JWK_INCOMPLETE
%display(eventdata.Key)
switch eventdata.Key
    % add docking spot
    case 'a'
        if spot_exist ==  1
        else
            if g_tmpspot.x(1) == 0
                return
            else
            disp('ADD')
            add_tmpspots(0)
            display_docking_line (g_tmpspot.donor,g_tmpspot.dock_time)
            draw_hist()
            update_stats()
            end
        end

    %add start release event
    case 's'
        if spot_exist ==  0
        else
            if get(ghandles.EB_frame_index,'Value') >= g_tmpspot.dock_time
                if length(g_spots.release_time(g_spots.total,:)) < g_spots.release_count
                    set_fusiontime(g_tmpspot.index,1)
                    display_docking_line (g_tmpspot.donor,g_tmpspot.dock_time)
                    display_release_start_line (g_tmpspot.donor,g_tmpspot.release_time)
                    display_release_stop_line (g_tmpspot.donor,g_tmpspot.close_time)
                elseif get(ghandles.EB_frame_index,'Value') > g_spots.release_time(g_spots.total,g_spots.release_count)
                    set_fusiontime(g_tmpspot.index,1)
                    display_docking_line (g_tmpspot.donor,g_tmpspot.dock_time)
                    display_release_start_line (g_tmpspot.donor,g_tmpspot.release_time)
                    display_release_stop_line (g_tmpspot.donor,g_tmpspot.close_time)
                end
            end
            update_stats()
            draw_hist()
        end
    % add end release event
    case 'd'
        if spot_exist ==  0
        else
            if length(g_spots.release_time(g_spots.total,:)) < g_spots.release_count
                return
            end
            if length(find(g_spots.release_time(g_spots.total,:))>0) == 1
                return
            end            
            if g_spots.release_time(g_spots.total,g_spots.release_count) <= get(ghandles.EB_frame_index,'Value')
                if g_spots.close_time(g_spots.total,g_spots.release_count - 1) ~= get(ghandles.EB_frame_index,'Value')
                set_fusiontime(g_tmpspot.index,2)        
                display_docking_line (g_tmpspot.donor,g_tmpspot.dock_time)
                display_release_start_line (g_tmpspot.donor,g_tmpspot.release_time)
                display_release_stop_line (g_tmpspot.donor,g_tmpspot.close_time)
                end
                update_stats()
                draw_hist()
            end
        end
    case 'f'
        if spot_exist ==  0
        else
           set_fusiontime(g_tmpspot.index,3) 
           set(ghandles.ST_total_events,'String',['/ ',num2str(g_spots.total)])
           set(ghandles.EB_current_event,'String',num2str(g_tmpspot.index))
           set(ghandles.EB_current_event,'Value',g_tmpspot.index)
           g_spots.total = g_spots.total+1; 
           display_docking_line (g_tmpspot.donor,g_tmpspot.dock_time)
           display_release_start_line (g_tmpspot.donor,g_tmpspot.release_time)
           display_release_stop_line (g_tmpspot.donor,g_tmpspot.close_time)
           display_event_end_line (g_tmpspot.donor,g_tmpspot.end_time)
           update_stats()
           get_plot_stats()
           draw_hist()
        end
        
        
    case 'p'
        if spot_exist == 1
            disp('DEL')
            display('this is current index')
            del_tmpspots()
            update_stats()
        else
        end
          
        
end
% jwk_later cannot overlap
if g_tmpspot.x(1) > 0
    if strcmp(eventdata.Key, 'leftarrow') || strcmp(eventdata.Key, '7')
        move_tmpspot('l')
    elseif strcmp(eventdata.Key, 'rightarrow') || strcmp(eventdata.Key, '9')
        move_tmpspot('r')
    elseif strcmp(eventdata.Key, 'uparrow') || strcmp(eventdata.Key, '8')
        move_tmpspot('u')
    elseif strcmp(eventdata.Key, 'downarrow') || strcmp(eventdata.Key, 'hyphen')
        move_tmpspot('d')
    end
    
end
if strcmp(eventdata.Key, 'v') || strcmp(eventdata.Key, '5')
    if get(ghandles.TB_fast_frame_forward,'value') == 0
        set(ghandles.TB_fast_frame_forward,'value',1)
        TB_fast_frame_forward_Callback;        
    elseif get(ghandles.TB_fast_frame_forward,'value') == 1
        set(ghandles.TB_fast_frame_forward,'value',0)
    end
end

if strcmp(eventdata.Key, 'c') || strcmp(eventdata.Key, '2')
    if get(ghandles.TB_fast_frame_back,'value') == 0
        set(ghandles.TB_fast_frame_back,'value',1)
        TB_fast_frame_back_Callback;        
    elseif get(ghandles.TB_fast_frame_back,'value') == 1
        set(ghandles.TB_fast_frame_back,'value',0)
    end        
end    


% key = eventdata.Key;5

assignin('base','tmp',g_tmpspot)
assignin('base','g_spots',g_spots)

function background_KeyPressFcn(hObject, eventdata, handles)

%%%%%%%%%%%%%%%%%%%%%%  INITIALIZE  %%%%%%%%%%%%%%%%%%%%%%%%%%
function initialize(handles,is_initial)
global ghandles;    ghandles = handles;
%initialize_etc();
if is_initial ~= 1
    initialize_tmpspot(); initialize_spots(); 
    initialize_figure(handles); initialize_coeff(handles);
end

function initialize_figure(handles)
% clear figures
cla(handles.windowPMA);
cla(handles.windowTRACE)
% set figure axis
set(handles.windowPMA,  'xTick', [], 'yTick', []);
colormap(handles.windowPMA,gray(128))

% initialize edit string

function initialize_tmpspot()
global g_tmpspot;
global pma;
global MAX_NUM_SPOTS

g_tmpspot   = struct('index',-1,'x',zeros(1,2),'y',zeros(1,2),...
            'donor',zeros(1,pma.len),'acceptor',zeros(1,pma.len),'dock_time',[],'release_time',[],'close_time',[],'end_time',[]);
        
g_tmpspot.index     = -1;
g_tmpspot.x         = zeros(1,2);
g_tmpspot.y         = zeros(1,2);

g_tmpspot.donor     = zeros(1,pma.len);
g_tmpspot.acceptor  = zeros(1,pma.len);
% jwk_change
% make_tmpspotframe(); %this clears tmpspotframe
% draw_frame()
function initialize_spots()
global g_spots
global pma
global MAX_NUM_SPOTS

g_spots     = struct('total',1,'x',zeros(MAX_NUM_SPOTS,2),'y',zeros(MAX_NUM_SPOTS,2),...
            'donor',zeros(MAX_NUM_SPOTS,pma.len),'acceptor',zeros(MAX_NUM_SPOTS,pma.len),'dock_time',[],'release_time',[],'close_time',[],'end_time',[],'release_count',2);
        
g_spots.total     = 1;
g_spots.release_count = 2;
g_spots.x         = zeros(MAX_NUM_SPOTS,2);
g_spots.y         = zeros(MAX_NUM_SPOTS,2);

g_spots.donor     = zeros(MAX_NUM_SPOTS,pma.len);
g_spots.acceptor  = zeros(MAX_NUM_SPOTS,pma.len);
% jwk_change
% make_maskframe()
% draw_frame()
function initialize_etc()
global MAX_NUM_SPOTS
global NUM_BIN
global g_maskframe
global g_tmpspotframe
global IS_MEAN
global dir_script
global pma

dir_script = mfilename('fullpath'); dir_script = dir_script(1:end-numel(mfilename));
g_maskframe         = zeros(pma.height,pma.width);
g_tmpspotframe      = zeros(pma.height,pma.width);
% MAX_NUM_SPOTS       = 10;
MAX_NUM_SPOTS       = 5000;

IS_MEAN         = 0;
NUM_BIN         = 5; %actually number of frames in bin

function initialize_coeff(handles)




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% BUTTON CONTROL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function EB_LeftContrast_Callback(hObject, eventdata, handles)
global pma

old_value = get(handles.EB_LeftContrast, 'Value');
multiplier = str2double(get(handles.EB_LeftContrast, 'String'));


if ~isreal(multiplier) || isnan(multiplier)
    set(handles.EB_LeftContrast, 'String',num2str(old_value))
    return
end

set(handles.EB_LeftContrast, 'Value',multiplier)


draw_frame()

function EB_RightContrast_Callback(hObject, eventdata, handles)
global pma

old_value = get(handles.EB_RightContrast, 'Value');
multiplier = str2double(get(handles.EB_RightContrast, 'String'));


if ~isreal(multiplier) || isnan(multiplier)
    set(handles.EB_RightContrast, 'String',num2str(old_value))
    return
end

set(handles.EB_RightContrast, 'Value',multiplier)


draw_frame()


% colormap(handles.windowPMA,gray(contrast))

function edit_NUMBIN_Callback(hObject, eventdata, handles)
global NUM_BIN
str   = get(handles.edit_NUMBIN, 'string');
NUM_BIN   = str2num(str);
draw('normal')
function edit_FRAMEMAX_Callback(hObject, eventdata, handles)
global FRAME_MAX
str   = get(handles.edit_FRAMEMAX, 'string');
FRAME_MAX   = str2num(str);
draw('normal')
% function btn_save_Callback(hObject, eventdata, handles)
% disp('SAVE PKS, TRACE')
% write_variables()
% % write_pks()
% % write_trace()
% write_hist()
% write_config()
function EB_frame_index_Callback(hObject, eventdata, handles)
old_value = get(handles.EB_frame_index, 'Value');
frame_index = str2double(get(handles.EB_frame_index, 'String'));


if ~isreal(frame_index) || isnan(frame_index)
    set(handles.EB_frame_index, 'String',num2str(old_value))
    return
end
set(handles.slider_windowPMA, 'Value', frame_index);
draw_frame();

%added by bhawk 20180508
function listener_EB_frame_index_Callback(hObject, eventdata)
global ghandles
frame_index = str2double(get(ghandles.EB_frame_index, 'String'));
if frame_index > ghandles.end_frame
    set(ghandles.background, 'Color','red')
else
    set(ghandles.background, 'Color','white')
end

display_current_frame_line(frame_index)



function listener_slider_windowPMA_Callback(hObject, eventdata)
global ghandles
frame_index = round(get(ghandles.slider_windowPMA,'value'));
set(ghandles.EB_frame_index, 'value', frame_index);
set(ghandles.EB_frame_index, 'string', frame_index);
draw('slider');
function EB_LeftContrast_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_FRAMEMAX_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_NUMBIN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit_endFRAME_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function slider_windowPMA_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function EB_frame_index_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function static_pmalen_CreateFcn(hObject, eventdata, handles)
function clear_global()
clear pma
clear g_spot
clear MAX_NUM_SPOTS
clear ghandles
clear g_tmpspot
clear MAX_NUM_SPOTS
clear NUM_BIN
clear g_maskframe
clear g_tmpspotframe
clear IS_MEAN
clear dir_script
function slider_windowPMA_Callback(hObject, eventdata, handles)

%%% PRIVATE %%%
function load_pmafile(pathname,filename,handles)
global pma
global ghandles

pma = [];

downstairs = 1;
if downstairs == 1
    fullpath = [pathname,filename,'.pma'];
    field_len     = 'len'; field_width   = 'width';  field_height  = 'height';
    field_area    = 'area';field_frames  = 'frames'; field_name    = 'name';
    field_dir     = 'dir'; field_savename= 'savename';
    
    fileinfo    = dir(fullpath);    filesize    = fileinfo.bytes;
    fid         = fopen(fullpath);  
    pma_width   = fread(fid, 1, 'int16')
    pma_height  = fread(fid, 1, 'int16') 
    pma_len     = floor((filesize-4)/(pma_width*pma_height))
    pma_frames  = zeros(pma_height,pma_width,pma_len);
else
    fullpath = [pathname,filename,'.pma'];
    field_len     = 'len'; field_width   = 'width';  field_height  = 'height';
    field_area    = 'area';field_frames  = 'frames'; field_name    = 'name';
    field_dir     = 'dir'; field_savename= 'savename';
    
    fileinfo    = dir(fullpath);    filesize    = fileinfo.bytes;
    fid         = fopen(fullpath);  pma_width   = fread(fid, 1, 'int16');
    pma_height  = fread(fid, 1, 'int16'); pma_len     = (filesize-4)/(pma_width*pma_height);
    pma_frames  = zeros(pma_height,pma_width,pma_len);
    
end

pma = struct(field_len,pma_len,field_width,pma_width,field_height,pma_height,field_area,pma_width*pma_height,...
    field_frames,pma_frames,field_name,filename,field_dir,pathname,field_savename,'');

initialize_etc();
set(handles.static_filename,'string',pma.name);

h = waitbar(0, 'Loading frames from pma file...');
tic
for i=1:pma.len
    pma.frames(:,:,i) = fread(fid, [pma.height,pma.width], 'uint8');
%     pma.frames(:,:,i) = rot90(pma.frames(:,:,i));
    waitbar(i/pma_len);
end
toc
close(h)
fclose(fid);

%%% corects for changes in background
CB_BackgroundCorrection_Callback;


set(handles.static_pmalen, 'value', pma.len);
set(handles.static_pmalen, 'string', pma.len);

% %%%%%%%%%%%%%%% slider setup %%%%%%%%%%%%%%%%%%%%%%%%
set(handles.slider_windowPMA, 'Min', 1);
set(handles.slider_windowPMA, 'Max', pma.len);
set(handles.slider_windowPMA, 'SliderStep', [1,20]/(pma.len-1));
set(handles.slider_windowPMA, 'value', handles.start_frame);
set(handles.EB_end_frame,'value',pma.len)
set(handles.EB_end_frame,'string',num2str(pma.len))
ghandles.end_frame = pma.len;
handles.end_frame = pma.len;
listener_EB_frame_index_Callback()
addlistener(handles.EB_frame_index,'Value','PostSet',@listener_EB_frame_index_Callback);
% guidata(hObject,handles);
% assignin('base','plot_data',plot_data)

function write_config()
global ghandles
global pma

start_frame     = str2num(get(ghandles.edit_startFRAME, 'string'));
disp('in write config function')
end_frame       = str2num(get(ghandles.edit_endFRAME, 'string'));

donor_level     = str2num(get(ghandles.edit_DonorLevel, 'string'));
acceptor_level  = str2num(get(ghandles.edit_AcceptorLevel, 'string'));
leakage         = str2num(get(ghandles.edit_leakage, 'string'));
correction_factor   = str2num(get(ghandles.edit_Correction, 'string'));
num_bin             = str2num(get(ghandles.edit_NUMBIN, 'string'));
fid = fopen([pma.dir,'new_',pma.name,'_config.txt'],'wt');
fprintf(fid,'start frame   :: %f \n',start_frame);
fprintf(fid,'end frame     :: %f \n',end_frame);
fprintf(fid,'donor    level:: %f \n',donor_level);
fprintf(fid,'acceptor level:: %f \n',acceptor_level);
fprintf(fid,'leakage       :: %f \n',leakage);
fprintf(fid,'correction    :: %f \n',correction_factor);
fprintf(fid,'num bin       :: %f \n',num_bin);

fclose(fid);

function write_trace()
%jwk trace write
global g_spots;
global pma;
global MAX_NUM_SPOTS

%jwk get information
fid = fopen([pma.dir,'new_',pma.name,'.traces'], 'w');
fwrite(fid,pma.len,'int32');
fwrite(fid,g_spots.total*2,'int16');
disp('WRITE TRACE ::')
disp('pma.len g_spots.total')
disp([pma.len g_spots.total])

tmp = zeros(g_spots.total, pma.len);
spot_index = find(g_spots.x(:,1) > 0);
trace_index  = 0;
if ~isempty(spot_index)
    for i = 1: g_spots.total
        trace_index = trace_index + 1;
        tmp(trace_index,:) = g_spots.donor(i,:);
        trace_index = trace_index + 1;
        tmp(trace_index,:) = g_spots.acceptor(i,:);
    end
end

index       = (1:g_spots.total*pma.len*2);
fdata       = zeros(g_spots.total*pma.len*2,1,'int16');
fdata(index)= tmp(index);
fwrite(fid,fdata,'int16');
fclose(fid);  
function write_variables()
global pma;
global g_spots
name_gspot = [pma.dir,'new_',pma.name,'_gspots.mat'];
save(name_gspot,'g_spots');

function write_summary()
%write summary file of # of events and # events sorted by #
%of release events
global g_spots
global pma

num_of_events = length(g_spots.end_time(:,1));

save_name = [pma.dir,pma.name,'_summary.csv'];
fid_2 = fopen(save_name, 'w');

release_events = zeros(num_of_events,2);
for e = 1:length(g_spots.end_time)
    %check to make sure event data for all steps
    try size(g_spots.end_time(e,:));
    catch
        break
    end
    %find number of release events
    try release_count = length(find(g_spots.release_time(e,2:end)>0));catch; continue; end
    release_events(e,1) = e; release_events(e,2) = release_count;
end
max_releases = max(release_events(:,2));
release_count = zeros(max_releases,2);
for r = 0:max_releases
    release_count(r+1,1) = r;
    release_count(r+1,2) = length(find(release_events(:,2) == r));
end 
num_of_events = num2str(num_of_events);
fprintf(fid_2,'%15s, %6s\n','# of events',num2str(num_of_events));
fprintf(fid_2,'%15s, %15s\n','# of releases','# of events');
fprintf(fid_2,'%6.0f, %6.0f\n',release_count');
fclose(fid_2);
disp('summary writen')


function matrix = events2matrix(index,data_holder,header)
% takes index of events, original data set, header for columns 

index = [(1:length(index))',data_holder(index,1)...
    ,data_holder(index,2),data_holder(index,3)...
    ,data_holder(index,6),data_holder(index,4),data_holder(index,5)];
index = num2cell(index);
matrix = [header;index];


function write_data2csv(filename,headers,data)

[row,col] = size(data);

fid = fopen(filename, 'w') ;

fprintf(fid,'%6s %12s\n',headers);
% for i = 1:row
%     for j = 1:col
%         if isa(data{i,j},'char')
%             if col == j
%                 fprintf(fid, '%s\n', data{i,j}) ;
%             else
%                 fprintf(fid, '%s,\t', data{i,j}) ;
%             end
%             
%         elseif isa(data{i,j},'double') %&& isempty(master_array{i,j}) ~= 1
%             if col == j
%                 fprintf(fid, '%8.2f\n', data{i,j}) ;
%             else
%                 fprintf(fid, '%8.2f\t', data{i,j}) ;
%             end
%         end
%     end
% end
fclose(fid);

function move_slider(direction)
global ghandles
global pma
frame_index = str2double(get(ghandles.EB_frame_index, 'String'));

frame_index = frame_index + direction;
if frame_index < 1
    return
elseif frame_index > pma.len
    return
end
set(ghandles.EB_frame_index, 'value', frame_index);
set(ghandles.EB_frame_index, 'string', frame_index);
set(ghandles.slider_windowPMA, 'value',frame_index);
draw('slider');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     SPOTS      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% PUBLIC %%%%%%%
function spots_pma()
% function add_spots_pks(x,y,donor,acceptor)
function add_spots_pks(x,y)
global g_spots
global MAX_NUM_SPOTS
global pma
x_d = x(1:2:end); x_a = x(2:2:end);
y_d = y(1:2:end); y_a = y(2:2:end);

num_spots = numel(x_d);

dbg_str = sprintf('size x_d: %d ',num_spots);
disp(dbg_str);

if num_spots > MAX_NUM_SPOTS
    disp('PKS is has more spots than MAX_NUM_SPOTS')
    num_spots = MAX_NUM_SPOTS;
end

donor       = zeros(num_spots,pma.len);
acceptor    = zeros(num_spots,pma.len);

dbg_str = sprintf('size donor:'); disp(dbg_str);
disp(size(donor))

circle = [ ...       
        0.0037    0.0743    0.2019    0.0743    0.0037    ; ...
        0.0123    0.2466    0.6703    0.2466    0.0123    ; ...
        0.0183    0.3679    1.0000    0.3679    0.0183    ; ...
        0.0123    0.2466    0.6703    0.2466    0.0123    ; ...
        0.0037    0.0743    0.2019    0.0743    0.0037    ; ...     
];

radius = 2;
x_d = round(x_d);     x_a = round(x_a);
y_a = 512*ones(num_spots,1)-round(y_a);
y_d = 512*ones(num_spots,1)-round(y_d);

dbg_str = sprintf('size x_d: %d ',numel(x_d)); disp(dbg_str);
dbg_str = sprintf('size y_d: %d ',numel(y_d)); disp(dbg_str);
dbg_str = sprintf('size x_a: %d ',numel(x_a)); disp(dbg_str);
dbg_str = sprintf('size y_a: %d ',numel(y_a)); disp(dbg_str);


%get donor accpetor trace from PMA
for j = 1: num_spots
    for i = 1:pma.len
        donor(j,i) = ...
            sum(sum(pma.frames(y_d(j)-radius:y_d(j)+radius,x_d(j)-radius:x_d(j)+radius,i).*circle));
    end
    
    %JWK_INCOMPLETE
    for i = 1:pma.len
        acceptor(j,i) = ...
            sum(sum(pma.frames(y_a(j)-radius:y_a(j)+radius,x_a(j)-radius:x_a(j)+radius,i).*circle));
    end
end
g_spots.x(1:num_spots,1)        = x_d;
g_spots.y(1:num_spots,1)        = y_d;
g_spots.x(1:num_spots,2)        = x_a;
g_spots.y(1:num_spots,2)        = y_a;
g_spots.total                   = num_spots;
g_spots.donor(1:num_spots,:)     = donor;
g_spots.acceptor(1:num_spots,:)  = acceptor;
dbg_str = sprintf('size x_d: %d ',numel(g_spots.x(1:num_spots,1))); disp(dbg_str);
dbg_str = sprintf('size y_d: %d ',numel(g_spots.y(1:num_spots,1))); disp(dbg_str);
dbg_str = sprintf('size x_a: %d ',numel(g_spots.x(1:num_spots,2))); disp(dbg_str);
dbg_str = sprintf('size y_a: %d ',numel(g_spots.y(1:num_spots,2))); disp(dbg_str);

[tmp, index ] = sort(g_spots.y(1:num_spots,1));

g_spots.x(1:num_spots,1)             =g_spots.x(index,1);
g_spots.x(1:num_spots,2)             =g_spots.x(index,2);
g_spots.y(1:num_spots,1)             =g_spots.y(index,1);
g_spots.y(1:num_spots,2)             =g_spots.y(index,2);
g_spots.donor(1:num_spots,:)       =g_spots.donor(index,:);
g_spots.acceptor(1:num_spots,:)    =g_spots.acceptor(index,:);

initialize_tmpspot()

%type 0 is add current frame index type 1 is add closest spike previous to
%current frame index
function add_tmpspots(type)
global g_spots;
global g_tmpspot;
global MAX_NUM_SPOTS;
global pma
global ghandles
current_index = get_currentframeindex();
current_frame = pma.frames(:,:,current_index);

donor_frame = current_frame(g_tmpspot.x(1)-1:g_tmpspot.x(1)+1,g_tmpspot.y(1)-1:g_tmpspot.y(1)+1);

if type == 1 
    if current_index < 100;
        start_look = 1;
    else
        start_look = current_index - 100;
    end
    search_frame = smooth(g_tmpspot.acceptor(start_look:current_index));
    A = search_frame(1:end-3);
    B = search_frame(4:end);
    C = B-A;
    [max_diff max_diff_index]   = max(C);
    current_index = max_diff_index + 2 + start_look;
end

Dx = 0; Dy = 0; Ax = 0; Ay = 0;

%JWK_incomplete
%check if any available spots
index = get_insertspotindex(g_tmpspot.y(1));
display(index)
if (index > 0) && index <= MAX_NUM_SPOTS &&g_spots.total < MAX_NUM_SPOTS
   g_spots.x(index,1)           = round(g_tmpspot.x(1))-Dx;
   g_spots.y(index,1)           = round(g_tmpspot.y(1))-Dy;
   g_spots.x(index,2)           = round(g_tmpspot.x(2))-Ax;
   g_spots.y(index,2)           = round(g_tmpspot.y(2))-Ay;
   g_spots.donor(index,:)       = g_tmpspot.donor;
   g_spots.acceptor(index,:)    = g_tmpspot.acceptor;
%    g_spots.etime(index,:)       = g_tmpspot.etime;
%    g_spots.etime(index,1)       = current_index;
   g_spots.dock_time(index,2)       = current_index;
   g_spots.dock_time(index,1)       = g_spots.total;
   g_spots.release_time(index,1)       = g_spots.total;
   g_spots.close_time(index,1)       = g_spots.total;
   g_spots.end_time(index,1)       = g_spots.total;

   
    set_tmpspot(index)

else

end
assignin('base','tmp',g_tmpspot)
assignin('base','g_spots',g_spots)


function del_tmpspots()
global g_tmpspot;
global MAX_NUM_SPOTS;
global g_spots
display('index')
g_tmpspot.index
%check if selected
if (g_tmpspot.index > 0)||(g_tmpspot.index <= MAX_NUM_SPOTS) 
    initialize_spots_index(g_tmpspot.index);
%     initialize_tmpspot();
    make_maskframe();
    make_tmpspotframe();
    draw_frame();
else
    disp('NOT EXISTING SPOT')
end




function index = get_insertspotindex(y)
global g_spots
global MAX_NUM_SPOTS
global pma
% if g_spots.total < MAX_NUM_SPOTS
%    tmp = find(g_spots.etime(:,1)== pma.len);
%    index = tmp(1);
% end
index = g_spots.total;

%JWK_INCOMPLETE
function move_tmpspot(arrow)
global g_tmpspot
global g_spots
global pma
global ghandles
radius = 3;
curr_x = g_tmpspot.x(1); curr_y = g_tmpspot.y(1);
switch arrow
    case 'l'
        if (curr_x - 1) < radius
            return
        end
        set_newtmpspot(curr_x -1,curr_y)
    case 'r'
        if (curr_x + 1) > (pma.width - radius)
            return
        end
        set_newtmpspot(curr_x+1,curr_y)
    case 'd'
        if (curr_y + 1) > (pma.height - radius)
            return
        end
        set_newtmpspot(curr_x,curr_y+1)
    case 'u'
        if (curr_y - 1) < radius
            return
        end
        set_newtmpspot(curr_x,curr_y-1)
end
frame_index = get(ghandles.EB_frame_index,'value');
display_current_frame_line(frame_index)
%JWK_INCOMPLETE

function set_newtmpspot(x,y)
global g_tmpspot;
global pma;
%jwk make gaussian
%JWK_INCOMPLETE


circle = [ ...       
        0.0037    0.0743    0.2019    0.0743    0.0037    ; ...
        0.0123    0.2466    0.6703    0.2466    0.0123    ; ...
        0.0183    0.3679    1.0000    0.3679    0.0183    ; ...
        0.0123    0.2466    0.6703    0.2466    0.0123    ; ...
        0.0037    0.0743    0.2019    0.0743    0.0037    ; ...     
];

radius = 2;

g_tmpspot.index     = -1;
g_tmpspot.x(1)      = round(x);
g_tmpspot.y(1)      = round(y);
g_tmpspot.dock_time(1)  = get_currentframeindex();
disp('x y')

disp([g_tmpspot.x(1) g_tmpspot.y(1)])

%JWK_INCOMPLETE
for i = 1:pma.len
    g_tmpspot.donor(i) = ...
        sum(sum(pma.frames(g_tmpspot.y(1)-radius:g_tmpspot.y(1)+radius,g_tmpspot.x(1)-radius:g_tmpspot.x(1)+radius,i).*circle));
end
    

make_tmpspotframe()
draw_frame()
draw_trace(g_tmpspot.donor)

function set_tmpspot(i)
global g_tmpspot;
global g_spots;
global ghandles

g_tmpspot.index        = i;
g_tmpspot.x(1)         = g_spots.x(i,1);
g_tmpspot.x(2)         = g_spots.x(i,2);
g_tmpspot.y(1)         = g_spots.y(i,1);
g_tmpspot.y(2)         = g_spots.y(i,2);
g_tmpspot.donor        = g_spots.donor(i,:);
g_tmpspot.acceptor     = g_spots.acceptor(i,:);
g_tmpspot.dock_time        = g_spots.dock_time(i,2);
events = find(g_spots.release_time(i,2:end) ~= 0);
try g_tmpspot.release_time        = g_spots.release_time(i,events+1);catch;end;
try g_tmpspot.close_time        = g_spots.close_time(i,events+1);catch;end;
try g_tmpspot.end_time        = g_spots.end_time(i,2);catch;end



make_tmpspotframe()
draw_frame()
draw_trace(g_tmpspot.donor)
display_docking_line(g_tmpspot.donor,g_tmpspot.dock_time)
display_release_start_line(g_tmpspot.donor,g_tmpspot.release_time)
display_release_stop_line(g_tmpspot.donor,g_tmpspot.close_time)
display_event_end_line(g_tmpspot.donor,g_tmpspot.end_time)
set(ghandles.EB_current_event,'String',num2str(g_tmpspot.index))
set(ghandles.EB_current_event,'Value',g_tmpspot.index)





%%%%%%% PRIVATE %%%%%%%
function mapped = make_mapped_coordinate(x,y)

P = zeros(4,4);
Q = zeros(4,4);

if x > 256
   %selected acceptor 
    x = x - 256-1;
    y = y-1;

    P(:) = [ ...
        -266871000000 ...
        -4023970000000 ...
        19141500000 ...
        -23513000 ...
        94802400000000 ...
        129600000000 ...
        -568250000 ...
        686717 ...
        57233800000 ...
        -1188760000 ...
        5179620 ...
        -6333.17...
        -163853000 ...
        3212910 ...
        -14029.4 ...
        17.3716 ...
        ];
    Q(:) = [ ...
        -11732800000 ...
        98463700000000 ...
        8387000000 ...
        -11872800 ...
        -74637800000 ...
        43426000000 ...
        -237806000 ...
        329130 ...
        9311360000 ...
        -354871000 ...
        1897220 ...
        -2613.1 ...
        -27862000 ...
        891458 ...
        -4743.65 ...
        6.52014000000000...
        ];

    
    
    input = [ 1 x x^2 x^3; y x*y y*x^2 y*x^3; y^2 y^2*x y^2*x^2 y^2*x^3;y^3 y^3*x y^3*x^2 y^3*x^3 ];
    mapped_x = sum(sum(input .*P / 100000000000000))+1.5;
    %mapped_y = sum(sum(input .*Q / 100000000000000))+1;
    mapped_y = sum(sum(input .*Q / 100000000000000))+3.5;
    
else
   %selected donor
    x = x-1;
    y = y-1;
    
    P(:) = [ ...
        300526000000    4004180000000   -19059000000    23503900 ...
        105141000000000 -129242000000   567943000       -689949 ...
        -56638500000     1188130000      -5191790        6382.570000 ...
        162327000       -3215840        14081           -17.52190000];
    
    Q(:) = [ ...
        15600800000 ...
        101479000000000 ...
        -8083900000 ...
        11484600 ...
        760930000000 ...
        -42481900000 ...
        233099000 ...
        -323524 ...
        -9410120000 ...
        348777000 ...
        -1868090 ...
        2578.84 ...
        28065300 ...
        -879026 ...
        4686.480000 ...
        -6.453270000 ...
        ];

    input = [ 1 x x^2 x^3; y x*y y*x^2 y*x^3; y^2 y^2*x y^2*x^2 y^2*x^3;y^3 y^3*x y^3*x^2 y^3*x^3 ];
    mapped_x = sum(sum(input .*P / 100000000000000))+256;
    %mapped_y = sum(sum(input .*Q / 100000000000000))+1;
    mapped_y = sum(sum(input .*Q / 100000000000000))+2;

end

mapped   = [mapped_x mapped_y];
function index = istherespot(x,y,handles)
global MAX_NUM_SPOTS
global g_spots
global g_tmpspot
index = 0;
current_frame = get_currentframeindex();
for i=1:MAX_NUM_SPOTS     
    if (abs(g_spots.y(i,1)-y)<2 && abs(g_spots.x(i,1)-x)<2) || (abs(g_spots.y(i,2)-y)<2 && abs(g_spots.x(i,2)-x)<2)
%         if current_frame > g_spots.etime(i,1) && current_frame < g_spots.etime(i,3) 
        if current_frame > g_spots.dock_time(i,2) && current_frame < g_spots.end_time(i,2) 
            index = i;
            g_tmpspot.index = index;
            display('this is occupied')
            return
        end
    end
end
index = 0;

function initialize_spots_index(index)
%%removes stored data for event

global g_spots
global g_tmpspot
global ghandles
global pma
global MAX_NUM_SPOTS

% if g_spots.total == g_tmpspot.index
% elseif g_spots.total == 1
% else  g_spots.total = g_spots.total-1;  
% end    

cursor_x = g_spots.x(index,1); cursor_y = g_spots.y(index,1);

g_spots.x(index,:)        = [];
g_spots.x = [g_spots.x;[0 0]]; 
g_spots.y(index,:)        = [];
g_spots.y = [g_spots.y;[0 0]]; 
g_spots.donor(index,:)    = [];
g_spots.donor = [g_spots.donor;zeros(1,pma.len)];  
g_spots.acceptor(index,:) = [];
g_spots.acceptor = [g_spots.acceptor;zeros(1,pma.len)];  

try g_spots.dock_time(index,:)    = [];catch;end
try g_spots.release_time(index,:)    = [];catch;end
try g_spots.close_time(index,:)    = [];catch;end
try g_spots.end_time(index,:)    = [];catch;end

try g_tmpspot.dock_time(index,:)    = [];catch;end
try g_tmpspot.release_time(index,:)    = [];catch;end
try g_tmpspot.close_time(index,:)    = [];catch;end
try g_tmpspot.end_time(index,:)    = [];catch;end
% try g_tmpspot.end_time(:,1)    = (1:length(g_spots.end_time(:,1)));catch;end
g_spots.dock_time(:,1)    = (1:length(g_spots.end_time(:,1)))';
g_spots.release_time(:,1)    = (1:length(g_spots.end_time(:,1)))';
g_spots.close_time(:,1)    = (1:length(g_spots.end_time(:,1)))';
g_spots.end_time(:,1)    = (1:length(g_spots.end_time(:,1)))';

g_spots.total = length(g_spots.end_time)+1;
set(ghandles.EB_current_event,'String',num2str(g_tmpspot.index))
set(ghandles.EB_current_event,'Value',g_tmpspot.index)
set(ghandles.ST_total_events,'String',['/ ',num2str(length(g_spots.end_time(:,1)))])


% set_tmpspot(index)
% set_newtmpspot(cursor_x,cursor_y)
make_maskframe()
draw_frame()
assignin('base','g_spots',g_spots)
assignin('base','tmp',g_tmpspot)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%      DRAW      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%% PUBLIC %%%%%%%
function draw(type)
if strcmp(type,'slider')
    draw_frame(); make_maskframe(); make_tmpspotframe();
elseif strcmp(type, 'initial')
    draw_frame();
else
    make_maskframe(); make_tmpspotframe();
    draw_frame(); draw_hist();
end
function draw_hist()
global plot_data
assignin('base','plot_data',plot_data)
draw_plot_1()
draw_plot_2()
%add plots here

function draw_hist_fusion()
% global ghandles
% global g_spots
% global pma
% global NUM_BIN
% axes(ghandles.axes_fusionDelayHist);
% % docked_index   = find(g_spots.etime(:,1) ~= pma.len);
% fused_index    = find(g_spots.etime(:,3) ~= pma.len);
% ghandles.fused_index = fused_index;
% 
% if ~isempty(fused_index)
%     
%     fuse_time  = g_spots.etime(fused_index,3)-g_spots.etime(fused_index,1);
%     ghandles.fuse_time = fuse_time;
%     max_fuse_time = ceil(max(fuse_time)/NUM_BIN)*NUM_BIN;
%     if max_fuse_time == 0
%         max_fuse_time = 5;
%     end
%     xbins = 0:NUM_BIN:max_fuse_time;
%     xbins = xbins + NUM_BIN/2;
%     [hist_data,b] = hist(fuse_time,xbins);
%     bar(b,hist_data);
%     axis([0 max_fuse_time 0 max(hist_data)*1.2])
%     hold on;
%     time_const = median(fuse_time);
%     line([time_const time_const], [0 max(hist_data)*1.2],'LineWidth', 1, 'Color', 'r');
% 
%     hold off;
%     grid on;
% end



function draw_plot_1()
global plot_data
global ghandles

plot_type = plot_data.plot_1_type;
plot_axes = ghandles.axes_plot_1;
num_of_bins = plot_data.plot_1_bin;


if strcmp('Cumulative Events',plot_type)
    set(ghandles.ST_title_plot_1,'String','Docking (Blue) Release (Red)')
else
    set(ghandles.ST_title_plot_1,'String',plot_type)
end


if strcmp('Relative content release',plot_type)
    cum_content_release(plot_axes,num_of_bins)
elseif strcmp('Cumulative release duration',plot_type)
    cum_release_duration(plot_axes,num_of_bins)
elseif strcmp('Percent of each type of release',plot_type)
    percent_type(plot_axes)
elseif strcmp('Max intinsty of event',plot_type)
    event_max_intensity(plot_axes,num_of_bins)
elseif strcmp('Cumulative Events',plot_type)
    cumulative_events(plot_axes)
end

function draw_plot_2()
global plot_data
global ghandles

plot_type = plot_data.plot_2_type;
plot_axes = ghandles.axes_plot_2;
num_of_bins = plot_data.plot_2_bin;

if strcmp('Cumulative Events',plot_type)
    set(ghandles.ST_title_plot_2,'String','Docking (Blue) Release (Red)')
else
    set(ghandles.ST_title_plot_2,'String',plot_type)
end

if strcmp('Relative content release',plot_type)
    cum_content_release(plot_axes,num_of_bins)
elseif strcmp('Cumulative release duration',plot_type)
    cum_release_duration(plot_axes,num_of_bins)
elseif strcmp('Percent of each type of release',plot_type)
    percent_type(plot_axes)
elseif strcmp('Max intinsty of event',plot_type)
    event_max_intensity(plot_axes,num_of_bins)
elseif strcmp('Cumulative Events',plot_type)
    cumulative_events(plot_axes)
end


   


function draw_trace(trace)
global ghandles
global g_tmpspot
global pma

cla(ghandles.windowTRACE);
axes(ghandles.windowTRACE);

plot_donor   = trace;
hold on 

max_trace = max(plot_donor);
min_trace = min(plot_donor);
if g_tmpspot.dock_time(1)> 0
    ghandles.trace_plot = plot(plot_donor, 'Parent', ghandles.windowTRACE,'LineWidth', 1, 'Color', 'w'); hold on
end

if get(ghandles.windowTRACE,'xlim') ~= [0 pma.len]
    xlim(ghandles.windowTRACE,[ghandles.zoom_start ghandles.zoom_end]);
end
ylim(ghandles.windowTRACE,[min_trace*.95  max_trace*1.1]);
set(ghandles.windowTRACE, 'yTick', 0: round((ceil(max(g_tmpspot.donor)*1.2)/10)/5)*5 :ceil(max(g_tmpspot.donor)*1.2));
hold off

function draw_frame()
global ghandles
global g_maskframe
global g_tmpspotframe
global pma

% assignin('base','ghandles',ghandles)
% assignin('base','pma',pma)

width = pma.width;
hight = pma.height;

type = ghandles.frame_type;


current_frame = get(ghandles.EB_frame_index,'Value');



%rolling average to "remove" moving particles'
if get(ghandles.CB_rolling_avg,'value')
    averaging_length = get(ghandles.EB_rolling_avg_length,'value');
    index = 1:averaging_length;
    frame_modifier = index - round(averaging_length/2);

    frame_index = zeros(1,averaging_length);

    for  i=1:averaging_length
        frame_index(i) = current_frame + frame_modifier(i);
    end


    nul_index = [find(frame_index < 1),find(frame_index > pma.len)];

    frame_index(nul_index) = [];

    num_of_frames = length(frame_index);

    frame_holder = zeros(hight,width,num_of_frames);

    for i = 1:num_of_frames
        frame_holder(:,:,i) = pma.frames(:,:,frame_index(i));
    end    

    frame = round(sum(frame_holder,3)/num_of_frames);
else
    frame = pma.frames(:,:,current_frame);
end    

if get(ghandles.CB_BackgroundCorrection, 'Value') == 1
        if get(ghandles.RB_bkgCorr_mean, 'Value') == 1
            frame = frame - mean(mean(frame))*1;
            if min(min(frame)) < 0
                frame = frame + min(min(frame));
            end
        elseif get(ghandles.RB_bkgCor_min, 'Value') == 1
            frame = frame - min(min(frame));
        end
end  

str   = get(ghandles.EB_LeftContrast, 'string');
contrast_L   = str2num(str);
try frame(:,1:256) = frame(:,1:256) * contrast_L;catch;end

str   = get(ghandles.EB_RightContrast, 'string');
contrast_R   = str2num(str);
try frame(:,257:end) = frame(:,257:end) * contrast_R;catch;end



  

frame(g_maskframe == 1) =  50;
frame(g_maskframe == 5) = 150;

frame(g_tmpspotframe == 1) = 150;
frame(g_tmpspotframe == 5) = 200;
assignin('base','frame',frame)

image(frame, 'Parent', ghandles.windowPMA);
grid(ghandles.windowPMA, 'off');
set(ghandles.windowPMA, 'TickLength', [0 0], 'yTick', 0)
set(ghandles.windowPMA, 'colormap',gray);

%%%%%%% PRIVATE %%%%%%%
function current_index = get_currentframeindex()
global ghandles
current_index = str2double(get(ghandles.EB_frame_index, 'String'));
function set_fusiontime(index,fusion_type)            
global g_spots
global g_tmpspot
global ghandles
current_index = str2double(get(ghandles.EB_frame_index, 'String'));
%start release
if fusion_type == 1
    g_spots.release_time(index,g_spots.release_count) = current_index;
    g_spots.release_time(index,1) = g_spots.total;
    g_spots.close_time(index,g_spots.release_count) = 0;
    g_tmpspot.release_time = g_spots.release_time(g_spots.total,2:g_spots.release_count);
%stop release and increase release count   
elseif fusion_type == 2
    g_spots.close_time(index,g_spots.release_count) = current_index;
	g_spots.close_time(index,1) = g_spots.total;
    g_tmpspot.close_time = g_spots.close_time(g_spots.total,2:g_spots.release_count);
    g_spots.release_count = g_spots.release_count +1;
%end event    
elseif fusion_type == 3
    g_spots.end_time(index,2) = current_index;
	g_spots.end_time(index,1) = g_spots.total;     
    g_tmpspot.end_time(1) = current_index;  
    if g_spots.total ~= 1
        if length(g_spots.end_time(:,1)) > length(g_spots.release_time(:,1))
            try g_spots.release_time(index,1) = g_spots.total; catch; end
        end
        if length(g_spots.end_time(:,1)) > length(g_spots.close_time(:,1))
            try g_spots.close_time(index,1) = g_spots.total; catch; end
        end  
    end
end
assignin('base', 'g_spots', g_spots)
assignin('base', 'tmp', g_tmpspot)

function frame = get_frame(index)
%%%%%%%%%%%%%%% loading frames from pma file %%%%%%%%
global pma;
frame = pma.frames(:,:,index);

function make_maskframe()
global g_spots;
global g_maskframe;
global pma;
global ghandles
radius = 4;

event_mask_status = get(ghandles.CB_EventIndicator,'Value');


% circle_D = ... 
%   [ 1 1 1 0 0 0 1 1 1;...
%     1 1 0 0 0 0 0 1 1;...
%     1 0 0 0 0 0 0 0 1;...
%     0 0 0 0 0 0 0 0 0;...
%     0 0 0 0 0 0 0 0 0;...
%     0 0 0 0 0 0 0 0 0;...
%     1 0 0 0 0 0 0 0 1;...
%     1 1 0 0 0 0 0 1 1;...
%     1 1 1 0 0 0 1 1 1];

if event_mask_status == 1

    circle_D = ... 
      [ 0 0 1 1 1 1 1 0 0;...
        1 0 0 0 0 0 0 0 0;...
        1 0 0 0 0 0 0 0 1;...
        1 0 0 0 0 0 0 0 1;...
        1 0 0 0 0 0 0 0 1;...
        1 0 0 0 0 0 0 0 1;...
        1 0 0 0 0 0 0 0 1;...
        0 0 0 0 0 0 0 0 0;...
        0 0 1 1 1 1 1 0 0];
    
elseif event_mask_status == 0
    circle_D = ... 
      [ 0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0];
end
    

current_frame = get_currentframeindex();
g_maskframe = zeros(pma.height,pma.width);

%jwk_fix
% spot_index = find(g_spots.x(:,1) > 0);

if size(g_spots.dock_time)==[0,0]
    docked_index = 1;
else docked_index = find(g_spots.dock_time(:,2) <= current_frame);
end    

if numel(g_spots.end_time) < 2
    end_index = 1;
else end_index = find(g_spots.end_time(:,2) < current_frame);
end    


[x y] = size(g_spots.dock_time);
A = zeros(x,1);
A(docked_index) = 1;
A(end_index) = 0;
spot_index = find(A>0);

%jwk 20170614
if ~isempty(spot_index)
    g_maskframe = g_maskframe * 5;
    for i = spot_index'
        if ((round(g_spots.y(i,1))-radius) * (round(g_spots.y(i,1))+radius) * (round(g_spots.x(i,1))-radius) * (round(g_spots.x(i,1))+radius)) < 0
            i
            (round(g_spots.y(i,1))-radius)  
            (round(g_spots.y(i,1))+radius)  
            (round(g_spots.x(i,1))-radius)  
            (round(g_spots.x(i,1))+radius)
        else
            g_maskframe(round(g_spots.y(i,1))-radius : round(g_spots.y(i,1))+radius, round(g_spots.x(i,1))-radius : round(g_spots.x(i,1))+radius) ...
                = g_maskframe(round(g_spots.y(i,1))-radius : round(g_spots.y(i,1))+radius, round(g_spots.x(i,1))-radius : round(g_spots.x(i,1))+radius) |circle_D;
        end
    end
end



function make_tmpspotframe()
global g_tmpspotframe;
global g_tmpspot
global pma;
global ghandles

event_mask_status = get(ghandles.CB_EventIndicator,'Value');

x = g_tmpspot.x(1);
y = g_tmpspot.y(1);


%JWK_INCOMPLETE must check if mapped x y are in boundary
if x < 1
    g_tmpspotframe = zeros(pma.height,pma.width);
    return
end

% radius = 3;
radius = 4;
% circle = ... 
%   [ 0 0 1 1 1 0 0;...
%     0 1 0 0 0 1 0;...
%     1 0 0 0 0 0 1;...
%     1 0 0 0 0 0 1;...
%     1 0 0 0 0 0 1;...
%     0 1 0 0 0 1 0
%     0 0 1 1 1 0 0];
%  if event_mask_status == 1
%     circle = ... 
%       [ 0 0 1 0 1 0 0;...
%         0 1 0 0 0 1 0;...
%         1 0 0 0 0 0 1;...
%         0 0 0 0 0 0 0;...
%         1 0 0 0 0 0 1;...
%         0 1 0 0 0 1 0;...
%         0 0 1 0 1 0 0];
    
 if event_mask_status == 1
    circle = ... 
      [ 0 0 1 0 0 0 1 0 0;...
        0 1 0 0 0 0 0 1 0;...
        1 0 0 0 0 0 0 0 1;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        1 0 0 0 0 0 0 0 1;...
        0 1 0 0 0 0 0 1 0;...
        0 0 1 0 0 0 1 0 0];

%  elseif event_mask_status == 0
%          circle = ... 
%       [ 0 0 0 0 0 0 0;...
%         0 0 0 0 0 0 0;...
%         0 0 0 0 0 0 0;...
%         0 0 0 0 0 0 0;...
%         0 0 0 0 0 0 0;...
%         0 0 0 0 0 0 0;...
%         0 0 0 0 0 0 0];
 elseif event_mask_status == 0
         circle = ... 
      [ 0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0];
 end
g_tmpspotframe = zeros(pma.height,pma.width);
g_tmpspotframe(round(y)-radius : round(y)+radius, round(x)-radius : round(x)+radius) = circle;




function slider_windowCONTRAST_Callback(hObject, eventdata, handles)
function slider_windowCONTRAST_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in CB_Grid.
function CB_Grid_Callback(hObject, eventdata, handles)
% hObject    handle to CB_Grid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Grid = [handles.gridline_horizontal_bottom, handles.gridline_horizontal_top, handles.uipanel8];
status = get(handles.CB_Grid, 'Value');

if status == 1
    set(Grid, 'Visible', 'On')
elseif status == 0
    set(Grid, 'Visible', 'Off')
end

function update_stats()
global g_tmpspot
global ghandles
set(ghandles.ST_dock_time,'String',num2str(g_tmpspot.dock_time))
set(ghandles.ST_release_time,'String',num2str(g_tmpspot.release_time))
set(ghandles.ST_close_time,'String',num2str(g_tmpspot.close_time))
set(ghandles.ST_end_time,'String',num2str(g_tmpspot.end_time))



function EB_start_frame_Callback(hObject, eventdata, handles)
global ghandles
old_value = get(handles.EB_start_frame, 'Value');
frame = str2double(get(handles.EB_start_frame, 'String'));


if ~isreal(frame) || isnan(frame)
    set(handles.EB_start_frame, 'String',num2str(old_value))
    return
end

set(handles.EB_start_frame, 'Value',frame)


handles.start_frame = frame;
ghandles.start_frame = frame;
handles.zoom_start = frame;
ghandles.zoom_start = frame;
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function EB_start_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EB_start_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EB_end_frame_Callback(hObject, eventdata, handles)
global ghandles
global pma

old_value = get(hObject,'Value');
frame = get(hObject,'String');

if strcmp('end',frame)
    frame = pma.len;
    set(handles.EB_end_frame, 'String',frame)
else
    frame = str2double(get(hObject,'String'));
    if ~isreal(frame) || isnan(frame)
        disp('here')
        set(handles.EB_end_frame, 'String',num2str(old_value))    
        return
    end
end

set(handles.EB_end_frame, 'Value',frame)

handles.end_frame = frame;
ghandles.end_frame = frame;
handles.zoom_end = frame;
ghandles.zoom_end = frame;
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function EB_end_frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EB_end_frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function corrected_frames = background_correction(data)
global pma;
pma_len = pma.len;
y.avarage = zeros(1,pma_len);
y.min = zeros(1,pma_len);
pma_frames = data;
for t = 1:length(pma_frames(1,1,:))
    avarage.y(t) = mean(mean(pma_frames(:,:,t)));
end

disp('starting correction')
h = waitbar(0, 'Subtracting Correction Values...');
for t = 1:length(pma_frames(1,1,:))
    y.avarage(t) = mean(mean(pma_frames(:,:,t)));
    pma_frames(:,:,t) = pma_frames(:,:,t) - y.avarage(t);
    if (mod(t,10) == 0)
        waitbar(t/pma_len);
    end;
end
close(h)


disp('getting new average')
fitted.average = zeros(1,pma_len);
fitted.min = zeros(1,pma_len);
for t = 1:pma_len
    fitted.average(t) = mean(mean(pma_frames(:,:,t)));
end
disp('done')

%makes sure that all values are above zero
disp('Making sure all values are positive')
fitted_average_min = min(fitted.average);
if fitted_average_min < 0
    h = waitbar(0, 'Making least value Zero...');
    for t = 1:pma_len
        pma_frames(:,:,t) =   pma_frames(:,:,t) + abs(fitted_average_min);
        fitted.average(t) = mean(mean(pma_frames(:,:,t)));
        if (mod(t,10) == 0)
            waitbar(t/pma_len);
        end;
    end
    close(h)
end
disp('done')
corrected_frames = pma_frames;
disp('Correction Complete')

figure
hold on
plot(y.avarage)
plot(fitted.average); hold off

draw_frame()


% --- Executes on button press in CB_BackgroundCorrection_Right.
function CB_BackgroundCorrection_Right_Callback(hObject, eventdata, handles)

draw_frame()

% --- Executes on button press in CB_BackgroundCorrection.
function CB_BackgroundCorrection_Callback(hObject, eventdata, handles)

draw_frame()


% --- Executes on button press in PB_reset_frame_num.
function PB_reset_frame_num_Callback(hObject, eventdata, handles)

global ghandles
set(ghandles.EB_frame_index, 'Value',ghandles.start_frame);
set(ghandles.EB_frame_index, 'String',ghandles.start_frame);
set(ghandles.slider_windowPMA, 'Value', ghandles.start_frame);
draw_frame();


% --- Executes on button press in PB_trace_save.
function PB_trace_save_Callback(hObject, eventdata, handles)

global ghandles;
global g_tmpspot;
global pma;
global g_spots;



if get(ghandles.RB_trace_individual,'Value') == 1
	index = g_tmpspot.index;
    save_name = [pma.dir,'new_',pma.name,'_trace_',num2str(index)];
    fig_title = ['new_',pma.name,'_trace_',num2str(index)];
    
    f = figure('visible','off');
    hold on
    plot_donor = g_tmpspot.donor;
    plot(plot_donor,'r');
    max_trace = max(plot_donor);
    min_trace = min(plot_donor);
    for e = 1:length(g_tmpspot.release_time)
        g_tmpspot.release_time(e)
        line([g_tmpspot.release_time(e) g_tmpspot.release_time(e)], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'c')
    end 
    for e = 1:length(g_tmpspot.close_time)
        g_tmpspot.close_time(e)
        line([g_tmpspot.close_time(e) g_tmpspot.close_time(e)], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'm')
    end 
    dim = [0.7 0.5 0.3 0.3];
    get(ghandles.EB_frame_index,'Value')
    str = {['frame = ',get(ghandles.EB_frame_index,'String')],['x = ',num2str(g_tmpspot.x(1))],['y = ',num2str(g_tmpspot.y(1))]};
    annotation('textbox',dim,'String',str,'FitBoxToText','on');
    title(fig_title,'Interpreter','none')
    xlim(get(ghandles.windowTRACE,'xlim'))
    hold off
    csvwrite([save_name,'.csv'],plot_donor');
    saveas(f,[save_name,'.png'],'png')  
end    

p = gcp('nocreate');

if get(ghandles.RB_trace_all,'Value') == 1
    tic
    if isempty(p)
    %without parrallel processing
        release_events = zeros(length(g_spots.end_time(:,1)),2);
        % find number of releases for each event
        for e = 1:g_spots.total
            %check to make sure event data for all steps
            try size(g_spots.end_time(e,:));
            catch
                break
            end
            %find number of release events
            release_count = length(find(g_spots.release_time(e,2:end)>0));
            release_events(e,1) = e; release_events(e,2) = release_count;
        end

        %Get max number of releases
        max_releases = max(release_events(:,2));
        disp(['max # of release in a single event = ',num2str(max_releases)])

        h = waitbar(0, 'Saving trace images...');
        %sort events based on number of releases
        counter = 1;
        for r = 0:max_releases
            event_index = find(release_events(:,2) == r);
            if ~isempty(event_index)
                str = ['sorting release = #',num2str(r)];
                disp(str)
                sort_count = [];
                sort_count(r+1,:) = release_events(event_index,1);
                count_folder = [pma.dir,pma.name,'_release_events_',num2str(r)];
                if exist(count_folder,'dir') ~= 7
                    mkdir(count_folder)
                end
            cd(count_folder)
            end
            %make plot for each event
            for e = 1:length(event_index)
                event = event_index(e);
                fig = figure('visible','off');
                hold on
                plot_donor = g_spots.donor(event,:);
                plot(plot_donor,'r');
                max_trace = max(plot_donor);
                min_trace = min(plot_donor);
                line([g_spots.dock_time(event,2) g_spots.dock_time(event,2)], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'g')
                for t = 1:length(g_spots.release_time(event,2:end))
                    if g_spots.release_time(event,t+1) ~= 0
                        frame = g_spots.release_time(event,t+1);
                        line([frame frame], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'c')
                    end
                end 
                for t = 1:length(g_spots.close_time(event,2:end))
                    if g_spots.close_time(event,t+1) ~= 0
                        frame = g_spots.close_time(event,t+1);
                        line([frame frame], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'm')
                    end
                end
                line([g_spots.end_time(event,2) g_spots.end_time(event,2)], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'r')
                fig_title = ['new_',pma.name,'_trace_',num2str(event)];
                title(fig_title,'Interpreter','none')
                dim = [0.2 0.5 0.3 0.3];
                str = {['Start frame = ',num2str(g_spots.dock_time(event,2))],['x = ',num2str(g_spots.x(event,1))],['y = ',num2str(g_spots.y(event,1))]};
                annotation('textbox',dim,'String',str,'FitBoxToText','on');
                plot_width = g_spots.end_time(event,2)-g_spots.dock_time(event,2);
                plot_start = g_spots.dock_time(event,2) - plot_width *0.2;
                if plot_start < 1; plot_start = 1; end
                plot_end = g_spots.end_time(event,2) + plot_width *0.2;
                if plot_end > pma.len; plot_end = pma.len; end
                try xlim([plot_start plot_end]);
                catch
                    error_msg = ['error with event #',num2str(e)];
                    disp(error_msg)
                    continue
                end
                hold off
                saveas(fig,[fig_title,'.png'],'png')
                delete(fig)
                waitbar(counter/length(release_events(:,1)))
                counter = counter +1;
            end
            cd(pma.dir)
        end
        close(h)
    else
    %with or w/ parrallel processing
        max_donor_int = max(max(g_spots.donor));
        min_donor_int = min(min(g_spots.donor));
        release_events = zeros(length(g_spots.end_time(:,1)),2);
        % find number of releases for each event
        for e = 1:g_spots.total
            %check to make sure event data for all steps
            try size(g_spots.end_time(e,:));
            catch
                break
            end
            %find number of release events
            release_count = length(find(g_spots.release_time(e,2:end)>0));
            release_events(e,1) = e; release_events(e,2) = release_count;
        end

        %Get max number of releases
        max_releases = max(release_events(:,2));
        disp(['max # of release in a single event = ',num2str(max_releases)])

        %sort events based on number of releases
        donor_traces = g_spots.donor(1:length(g_spots.end_time(:,1)),:);
        dock_time = g_spots.dock_time(:,2);
        release_time = g_spots.release_time(:,2:end);
        close_time = g_spots.close_time(:,2:end);
        end_time = g_spots.end_time(:,2);
        pma_name = pma.name;
        x = g_spots.x(1:length(g_spots.end_time(:,1)),1);
        y = g_spots.y(1:length(g_spots.end_time(:,1)),1);
        pma_length = pma.len;
        parfor e = 1:length(end_time)
            fig = figure('visible','off');
            hold on
            plot_donor = donor_traces(e,:);
            plot(plot_donor,'r');
            max_trace = max(plot_donor);
            min_trace = min(plot_donor);
            line([dock_time(e) dock_time(e)], [min_trace*0.95 max_trace*1.2],'LineWidth', 2,'Color', 'g')
            releases = release_time(e,:);
            for t = releases
                if t ~= 0
                    line([t t], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'c')
                end
            end
            closes = close_time(e,:);
            for t = closes
                if t ~= 0
                    line([t t], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'm')
                end
            end
            line([end_time(e) end_time(e)], [min_trace*0.95 max_trace*1.2],'LineWidth', 2,'Color', 'r')
            fig_title = [pma_name,'_trace_',num2str(e)];
            title(fig_title,'Interpreter','none')
            dim = [0.2 0.5 0.3 0.3];
            str = {['Start frame = ',num2str(dock_time(e))],['x = ',num2str(x(e))],['y = ',num2str(y(e))]};
            annotation('textbox',dim,'String',str,'FitBoxToText','on');
            plot_width = end_time(e)-dock_time(e);
            plot_start = dock_time(e) - plot_width *0.2;
            if plot_start < 1; plot_start = 1; end
            plot_end = end_time(e) + plot_width *0.2;
            if plot_end > pma_length; plot_end = pma_length; end
            try xlim([plot_start plot_end]);
            catch
                error_msg = ['error with event #',num2str(e)];
                disp(error_msg)
                continue
            end
            hold off
            saveas(fig,[fig_title,'.png'],'png')
            delete(fig)
        end
         for r = 0:max_releases
            event_index = find(release_events(:,2) == r);
            if ~isempty(event_index)
                str = ['sorting release = #',num2str(r)];
                disp(str)
                count_folder = [pma.dir,pma.name,'_release_events_',num2str(r)];
                if exist(count_folder,'dir') ~= 7
                    mkdir(count_folder)
                end
            end
            for f = event_index'
                file = [pma_name,'_trace_',num2str(f),'.png'];
                try movefile (file, count_folder)
                catch
                    msg = ['error with #: ',num2str(f)];
                    disp(msg)
                    continue
                end
            end
         end
    end
    toc
end


%controls zoom and mask disappear
function zoom_bars(bar, frame)
%%displays and moves bars on trace window for zoom and removal of event
%%mask
global ghandles;
global g_tmpspot;
global pma

persistent zoom_start_line zoom_end_line
plot_acceptor   = g_tmpspot.acceptor;
plot_donor      = g_tmpspot.donor;
max_trace = max([max(plot_acceptor) max(plot_donor)]);
min_trace = min([min(plot_acceptor) min(plot_donor)]);

%move or make start zoom bar
if bar == 1
    if frame < ghandles.zoom_end
        axes(ghandles.windowTRACE)
        delete(zoom_start_line)
        zoom_start_line=line([frame frame], [min_trace max_trace*1.2],...
            'LineWidth', 1,'Color', 'g','Parent', ghandles.windowTRACE);
        ghandles.zoom_start_line = zoom_start_line;
        ghandles.zoom_start = frame;
    end
end

%move or make end zoom bar
if bar == 2
    if frame > ghandles.zoom_start
        axes(ghandles.windowTRACE)
        delete(zoom_end_line)
        zoom_end_line = line([frame frame], [min_trace max_trace*1.2],...
            'LineWidth', 1,'Color', 'r','Parent', ghandles.windowTRACE);
        ghandles.zoom_end_line = zoom_end_line;
        ghandles.zoom_end = frame;
    end
end  

if get(ghandles.windowTRACE,'xlim') ~= [1 pma.len]
    xlim(ghandles.windowTRACE,[ghandles.zoom_start ghandles.zoom_end])
    %ylim(ghandles.windowTRACE,[min(g_tmpspot.acceptor(ghandles.zoom_start,ghandles.zoom_end))  max(g_tmpspot.acceptor(ghandles.zoom_start,ghandles.zoom_end))*1.2]);
end    
    
function mouseMove (object, eventdata)
global ghandles;
global pma

mouse_cords = get(ghandles.windowPMA,'CurrentPoint');
try
    if ((mouse_cords(1,1) >= 0) && (mouse_cords(1,1) < pma.width) && ...
        (mouse_cords(1,2) >= 0) && (mouse_cords(1,2)< pma.height))
        set(ghandles.ST_mouse_x,'String',num2str(round(mouse_cords(1,1),0)));
        set(ghandles.ST_mouse_y,'String',num2str(round(mouse_cords(1,2),0)));
    end 
catch
    return
end    

    
function display_current_frame_line(frame)

global ghandles;
global g_tmpspot;
global pma;

persistent current_frame_line
    try
    axes(ghandles.windowTRACE)
    delete(current_frame_line)
    plot_acceptor   = g_tmpspot.acceptor;
    plot_donor      = g_tmpspot.donor;
    hold on
    max_trace = max([max(plot_acceptor) max(plot_donor)]);
    min_trace = min([min(plot_acceptor) min(plot_donor)]);
    current_frame_line = line([frame frame], [min_trace*0.95 max_trace*1.2],...
                'LineWidth', 1,'Color', 'y','Parent', ghandles.windowTRACE);
    if get(ghandles.windowTRACE,'xlim') ~= [0 pma.len]
        xlim(ghandles.windowTRACE,[ghandles.zoom_start ghandles.zoom_end]);
    else
        xlim(ghandles.windowTRACE,[0 pma.len]);
    end
    catch
        return
    end
        
function display_docking_line (trace,frame)
global ghandles;
global pma;

axes(ghandles.windowTRACE)

try 
    delete(ghandles.docking_line)
catch
end  

plot_donor      = trace;
max_trace = max(plot_donor);
min_trace = min(plot_donor);
ghandles.docking_line = line([frame frame], [min_trace*0.95 max_trace*1.2],'LineWidth', 2,'Color', 'g','Parent', ghandles.windowTRACE);
if get(ghandles.windowTRACE,'xlim') ~= [0 pma.len]
    xlim(ghandles.windowTRACE,[ghandles.zoom_start ghandles.zoom_end]);
else
    xlim(ghandles.windowTRACE,[0 pma.len]);
end


function display_release_start_line (trace,events)
global ghandles;
global pma;

axes(ghandles.windowTRACE) 

try 
    delete(ghandles.rlease_line)
catch
end  

plot_donor      = trace;
max_trace = max(plot_donor);
min_trace = min(plot_donor);

release_events = events;
for e = 1:length(release_events)
    ghandles.rlease_line(e)=line([release_events(e) release_events(e)], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'c','Parent', ghandles.windowTRACE);
end  
if get(ghandles.windowTRACE,'xlim') ~= [0 pma.len]
    xlim(ghandles.windowTRACE,[ghandles.zoom_start ghandles.zoom_end]);
else
    xlim(ghandles.windowTRACE,[0 pma.len]);
end

        
function display_release_stop_line (trace,events)
global ghandles;
global pma;

axes(ghandles.windowTRACE) 

try 
    delete(ghandles.close_line)
catch
end  

plot_donor      = trace;
max_trace = max(plot_donor);
min_trace = min(plot_donor);

stop_events = events;

for e = 1:length(stop_events)
    ghandles.close_line(e) = line([stop_events(e) stop_events(e)], [min_trace*0.95 max_trace*1.2],'LineWidth', 1,'Color', 'm','Parent', ghandles.windowTRACE);
end 
if get(ghandles.windowTRACE,'xlim') ~= [0 pma.len]
    xlim(ghandles.windowTRACE,[ghandles.zoom_start ghandles.zoom_end]);
else
    xlim(ghandles.windowTRACE,[0 pma.len]);
end
        
function display_event_end_line (trace,frame)
global ghandles;
global pma;
if frame == 0
    return
end

try 
    delete(ghandles.event_end_line)
catch
end  

axes(ghandles.windowTRACE)
plot_donor      = trace;
max_trace = max(plot_donor);
min_trace = min(plot_donor);
try
    ghandles.event_end_line = line([frame frame], [min_trace*0.95 max_trace*1.2],'LineWidth', 2,'Color', 'r','Parent', ghandles.windowTRACE);
    if get(ghandles.windowTRACE,'xlim') ~= [0 pma.len]
        xlim(ghandles.windowTRACE,[ghandles.zoom_start ghandles.zoom_end]);
    else
        xlim(ghandles.windowTRACE,[0 pma.len]);
    end
catch
end


% --- Executes when background is resized.
function background_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Tab_option_Callback(hObject, eventdata, handles)
% hObject    handle to Tab_option (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Tab_loadPMA_Callback(hObject, eventdata, handles)
global ghandles
global plot_data

[filename, pathname] = uigetfile( ...
{  '*.pma','pma-files (*.pma)'; ...
   '*.*',  'All Files (*.*)'}, ...
   'Pick a file', ...
   'MultiSelect', 'on');
if filename == 0 
    return
end
cd(pathname)
load_pmafile(pathname,filename(1:end-4),handles);
handles.end_frame = ghandles.end_frame;
initialize(handles,0);
draw('initial');
plot_data = [];
plot_data = struct('max_int',[],'cum_release_duration',[],'release_type',[],...
                   'cum_content_release',[],'plot_1_bin',10,'plot_2_bin',10,...
				   'plot_1_type','Cumulative Events','plot_2_type','Relative content release');


% --------------------------------------------------------------------
function Tab_loadSavedEvents_Callback(hObject, eventdata, handles)
global pma
global g_spots
global ghandles
global g_tmpspot

name_gspot = [pma.dir,'new_',pma.name,'_gspots.mat'];
A = load(name_gspot);
g_spots = A.g_spots;
if g_spots.total == length(g_spots.end_time(:,1))
    g_spots.total = g_spots.total + 1;
end    
set(ghandles.ST_total_events,'String',['/ ',num2str(length(g_spots.end_time(:,1)))])
set(ghandles.EB_current_event,'String',num2str(1))
set(ghandles.EB_current_event,'Value',1)
g_tmpspot.index = g_spots.end_time(1,1);
make_plot_data()
update_stats()
draw('normal')
disp('Events Loaded')
assignin('base','g_spots',g_spots)
assignin('base','tmp',g_tmpspot)



% --------------------------------------------------------------------
function Tab_save_Callback(hObject, eventdata, handles)
disp('SAVE PKS, TRACE')
write_variables()
write_summary


% --- Executes during object creation, after setting all properties.
function EB_RightContrast_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CB_EventIndicator.
function CB_EventIndicator_Callback(hObject, eventdata, handles)
make_maskframe()
make_tmpspotframe()
draw_frame()

function Clear_trace_window()
%%clears ghandles.windowTRACE of all data
global ghandles;

try 
    delete(ghandles.trace_plot)
catch
end  
try 
    delete(ghandles.docking_line)
catch
end    
try 
    delete(ghandles.rlease_line)
catch
end    
try 
    delete(ghandles.close_line)
catch
end  
try 
    delete(ghandles.event_end_line)
catch
end


% --- Executes on button press in RB_bkgCorr_mean.
function RB_bkgCorr_mean_Callback(hObject, eventdata, handles)
set(handles.RB_bkgCor_min,'Value',0);
draw_frame()


% --- Executes on button press in RB_bkgCor_min.
function RB_bkgCor_min_Callback(hObject, eventdata, handles)
set(handles.RB_bkgCorr_mean,'Value',0);
draw_frame()


% --------------------------------------------------------------------
function Tab_options_Callback(hObject, eventdata, handles)
% hObject    handle to Tab_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Tab_parrallel_processing_Callback(hObject, eventdata, handles)

disp('parrallel processing started')
p = gcp('nocreate');
if isempty(p)
    p = gcp;
else
    delete(gcp('nocreate'))
end
   



function EB_current_event_Callback(hObject, eventdata, handles)
global g_spots;
global g_tmpspot;
global ghandles;

old_value = get(handles.EB_current_event, 'Value');
EB_value = str2double(get(handles.EB_current_event, 'String'));


if ~isreal(EB_value) || isnan(EB_value)
    set(handles.EB_current_event, 'String',num2str(old_value))
    return
end

set(handles.EB_current_event, 'Value',EB_value)

if EB_value >= 1 &&EB_value <= length(g_spots.end_time(:,1))
    g_tmpspot.index = EB_value;
end
set_tmpspot(EB_value)

% --- Executes during object creation, after setting all properties.
function EB_current_event_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PB_next_event.
function PB_next_event_Callback(hObject, eventdata, handles)
global ghandles;
global g_spots;
global g_tmpspot;


if g_tmpspot.index == length(g_spots.end_time)
    return
end

g_tmpspot.index = g_tmpspot.index + 1;
index = g_tmpspot.index;
set_tmpspot(index)
set(ghandles.slider_windowPMA, 'Value', g_spots.dock_time(index,2));
draw_frame();
set(ghandles.EB_current_event,'String',num2str(index))
set(ghandles.EB_current_event,'Value',index)
update_stats()
assignin('base','g_spots',g_spots)
assignin('base','tmp',g_tmpspot)



% --- Executes on button press in PB_previous_event.
function PB_previous_event_Callback(hObject, eventdata, handles)
global ghandles;
global g_spots;
global g_tmpspot;

if g_spots.total <= 1
    return
end
if g_tmpspot.index == 1
    return
end

g_tmpspot.index = g_tmpspot.index - 1;
index = g_tmpspot.index;

set_tmpspot(index)

set(ghandles.slider_windowPMA, 'Value', g_spots.dock_time(index,2));
draw_frame();
set(ghandles.EB_current_event,'String',num2str(index))
set(ghandles.EB_current_event,'Value',index)
update_stats()
assignin('base','g_spots',g_spots)
assignin('base','tmp',g_tmpspot)






% --- Executes on button press in TB_fast_frame_forward.
function TB_fast_frame_forward_Callback(hObject, eventdata, handles)
global ghandles;

step = get(ghandles.EB_scrooling_speed,'value');
set(ghandles.TB_fast_frame_back,'value',0)
while get(ghandles.TB_fast_frame_forward,'Value')
    move_slider(step)
    pause(0.02)
end    


% --- Executes on button press in TB_fast_frame_back.
function TB_fast_frame_back_Callback(hObject, eventdata, handles)
global ghandles;

step = get(ghandles.EB_scrooling_speed,'value');
set(ghandles.TB_fast_frame_forward,'value',0)
while get(ghandles.TB_fast_frame_back,'Value')
    move_slider(-step)
    pause(0.02)
end   



function TB_fast_frame_forward_KeyPressFcn(hObject, eventdata, handles)

function TB_fast_frame_back_KeyPressFcn(hObject, eventdata, handles)


% --- Executes on button press in CB_rolling_avg.
function CB_rolling_avg_Callback(hObject, eventdata, handles)

draw_frame()



function EB_rolling_avg_length_Callback(hObject, eventdata, handles)

old_value = get(handles.EB_rolling_avg_length, 'Value');
frames = str2double(get(handles.EB_rolling_avg_length, 'String'));


if ~isreal(frames) || isnan(frames)
    set(handles.EB_rolling_avg_length, 'String',num2str(old_value))
    return
end

set(handles.EB_rolling_avg_length, 'Value',frames)
   

draw_frame()




% --- Executes during object creation, after setting all properties.
function EB_rolling_avg_length_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over PB_previous_event.
function PB_previous_event_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PB_previous_event (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function frame_index_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EB_scrooling_speed_Callback(hObject, eventdata, handles)

old_speed = get(handles.EB_scrooling_speed, 'Value');
step = str2double(get(handles.EB_scrooling_speed, 'String'));


if ~isreal(step) || isnan(step)
    set(handles.EB_scrooling_speed, 'String',num2str(old_speed))
    return
end

set(handles.EB_scrooling_speed, 'Value',step)


%make sure speed isn't too fast
if step > 0 && step < 15 
    set(handles.EB_scrooling_speed,'value',step)
else
    set(handles.EB_scrooling_speed,'String',num2str(old_speed))
end    

% --- Executes during object creation, after setting all properties.
function EB_scrooling_speed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in LB_plot_type.
function LB_plot_type_Callback(hObject, eventdata, handles)
global ghandles
global plot_data
contents = cellstr(get(hObject,'String'));
selection = contents{get(hObject,'Value')};
% 
% if strcmp('Relative content release',selection)
%     disp('Relative content release')
% elseif strcmp('Cumulative release duration',selection)
%     disp('Cumulative release duration')
% elseif strcmp('Percent of each type of release',selection)
%     disp('Percent of each type of release')
% elseif strcmp('Max intinsty of event',selection)
%     disp('Max intinsty of event')
% elseif strcmp('Cumulative Events',selection)
%     disp('Cumulative Events')
% end

status = get(ghandles.RB_plot_1,'Value');

if status == 1   
    plot_data.plot_1_type = selection;
else
    plot_data.plot_2_type = selection;
end

draw_hist()


% --- Executes during object creation, after setting all properties.
function LB_plot_type_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Relative content release','Cumulative release duration',...
    'Percent of each type of release','Max intinsty of event','Cumulative Events'})



function EB_hist_bins_Callback(hObject, eventdata, handles)
global ghandles
global plot_data

old_value = get(hObject, 'Value');
EB_value = str2double(get(hObject, 'String'));


if ~isreal(EB_value) || isnan(EB_value)
    set(hObject, 'String',num2str(old_value))
    return
end

set(hObject, 'Value',EB_value)

status = get(ghandles.RB_plot_1,'Value');

if status == 1    
    plot_data.plot_1_bin = EB_value;
else
    plot_data.plot_2_bin = EB_value;
end
draw_hist()






% --- Executes during object creation, after setting all properties.
function EB_hist_bins_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EB_hist_bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% Make plot data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function get_plot_stats()
global g_tmpspot
global plot_data;

get_max_intensity(g_tmpspot.donor)
get_cum_release_duration(g_tmpspot.release_time, g_tmpspot.close_time)
get_num_of_releases(g_tmpspot.close_time)
get_cum_content_release(plot_data.max_int(end), g_tmpspot.donor, g_tmpspot.close_time)

function get_max_intensity(trace)
global plot_data;

plot_data.max_int = [plot_data.max_int;max(trace)];
assignin('base','donor_trace',trace)

function get_cum_release_duration(release_time, close_time)
global plot_data;

if isempty(release_time) || isempty(close_time)
    plot_data.cum_release_duration = [plot_data.cum_release_duration;0];

    return
end

cum_time = 0;

for r = 1:length(release_time)      % r is for rleases
    if close_time(r) ~= 0 && release_time(r) ~= 0
        cum_time = cum_time + (close_time(r) - release_time(r) + 1);
        close_time(r)
        release_time(r)
    end
end

plot_data.cum_release_duration = [plot_data.cum_release_duration;cum_time];

function get_num_of_releases(close_time)
global plot_data;

if isempty(close_time)
    plot_data.release_type = [plot_data.release_type;0];
    return
end

length(close_time)
plot_data.release_type = [plot_data.release_type;length(close_time)];

function get_cum_content_release(max_int, trace, close_time)
global plot_data;

if isempty(close_time)
    plot_data.cum_content_release = [plot_data.cum_content_release;0];
    return
end

low_int = trace(close_time(end));
cum_content_release = ((max_int-low_int)/max_int);
plot_data.cum_content_release = [plot_data.cum_content_release;cum_content_release];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% plot types

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function event_max_intensity (plot_axes,num_of_bins)
% Histogram for max intinsty of event
global ghandles;
global plot_data;

axes(plot_axes);
max_intensity = plot_data.max_int;

%sets hist perameters

% values to start with
low = min(max_intensity);
high = max(max_intensity);

% values to set later
% low = 0;
% high = 140;
bins = low:high/num_of_bins:high;

% sets "more" values
A = (max_intensity > bins(end-1));
max_intensity = max_intensity(~A); 
max_intensity = [max_intensity; ones(sum(A),1)*bins(end)];
sum(max_intensity == 0);

% makes plots
histogram(max_intensity,bins,'Normalization','probability');

%change y-axis from frequency to percent

yl = ylim;
yl(2) = yl(2) * 1.2;
ylim(yl);

ytix = get(gca, 'YTick');
set(gca, 'YTick',ytix, 'YTickLabel',ytix*100)

ylimit = get(gca, 'YTick');

xlabel('Intensity (au)')
ylabel('Percent of Events')


function cum_release_duration(plot_axes,num_of_bins)
global ghandles;
global plot_data;

axes(plot_axes);

    
%sets hist perameters
release_duration = (plot_data.cum_release_duration*20)/1000;

%starting values
low = min(release_duration);
high = max(release_duration);

%set later
%     low = 0;
%     high = 5;
bins = low:high/num_of_bins:high;

% sets "more" values
A = (release_duration > bins(end-1));
release_duration = release_duration(~A); 
release_duration = [release_duration; ones(sum(A),1)*bins(end)];
sum(release_duration == 0);

histogram(release_duration,bins,'Normalization','probability');


%change y-axis from frequency to percent

yl = ylim;
yl(2) = yl(2) * 1.2;
ylim(yl);

ytix = get(gca, 'YTick');
set(gca, 'YTick',ytix, 'YTickLabel',ytix*100)
xlabel('Time (s)')
ylabel('Percent of Events')


function cumulative_events(plot_axes)
global ghandles
global g_spots


axes(plot_axes);
dock_frame      = sort(g_spots.dock_time(:,2));
event_num = (1:length(dock_frame));
plot(dock_frame,event_num,'b'); hold on;
try
    release_frame = g_spots.release_time(:,2:end);
    num_of_elements = numel(release_frame);
    release_frame = reshape(release_frame,[num_of_elements,1]);
    releases = release_frame > 0;
    release_frame = sort(release_frame(releases));
    release_num = (1:length(release_frame));
    release_data.x = release_frame; release_data.y = release_num;
    assignin('base','release_data',release_data)
    plot(release_frame,release_num,'r'); hold off;    
catch
    disp('something went wrong in ploting release frame and number')
end
grid on;


function percent_type(plot_axes)
global ghandles
global plot_data;

axes(plot_axes);

release_type = plot_data.release_type;
num_of_events = length(release_type);

low = min(release_type);
high = max(release_type);

range = low:high;

types = length(range);

type_data = zeros(types,2);

for t = 1:types          %t is for type
    type_data(t,1) = range(t);
    type_data(t,2) = sum(release_type == range(t))/num_of_events;
end

bar(type_data(:,1),type_data(:,2))

%change y-axis from frequency to percent

yl = ylim;
yl(2) = yl(2) * 1.2;
ylim(yl);

ytix = get(gca, 'YTick');
set(gca, 'YTick',ytix, 'YTickLabel',ytix*100)
xlabel('Number of Releases')
ylabel('Percent of Events')


function cum_content_release(plot_axes,num_of_bins)
global ghandles
global plot_data;

axes(plot_axes);

intensity_decrease = plot_data.cum_content_release*100;

low = 0;
high = 100;
bins = low:high/num_of_bins:high;

histogram(intensity_decrease,bins,'Normalization','probability');

%change y-axis from frequency to percent


yl = ylim;
yl(2) = yl(2) * 1.2;
ylim(yl);

ytix = get(gca, 'YTick');
set(gca, 'YTick',ytix, 'YTickLabel',ytix*100)
xlabel('Amount of release')
ylabel('Percent of Events')


% --- Executes on button press in RB_plot_1.
function RB_plot_1_Callback(hObject, eventdata, handles)
% hObject    handle to RB_plot_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RB_plot_1



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%% makeing plot data after loading saved events

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function make_plot_data()
global g_spots;
global plot_data;

plot_data = [];
plot_data = struct('max_int',[],'cum_release_duration',[],'release_type',[],...
                   'cum_content_release',[],'plot_1_bin',10,'plot_2_bin',10,...
				   'plot_1_type','Cumulative Events','plot_2_type','Relative content release');

num_of_events = length(g_spots.dock_time(:,1));

for e = 1:num_of_events
    e
    get_max_intensity(g_spots.donor(e,:));
    load_get_cum_release_duration(g_spots.release_time(e,2:end), g_spots.close_time(e,2:end));
    load_get_num_of_releases(g_spots.close_time(e,2:end));
    load_get_cum_content_release(plot_data.max_int(e), g_spots.donor(e,:), g_spots.close_time(e,2:end));
end

function load_get_cum_release_duration(release_time, close_time)
global plot_data;

if release_time(1) == 0 || close_time(1) == 0
    plot_data.cum_release_duration = [plot_data.cum_release_duration;0];

    return
end

cum_time = 0;

num_of_release = length(release_time);

while 1
    if release_time(num_of_release) == 0
        num_of_release = num_of_release - 1;
    else
        break
    end
end

for r = 1:length(num_of_release)      % r is for rleases
    if close_time(r) ~= 0 && release_time(r) ~= 0
        cum_time = cum_time + (close_time(r) - release_time(r) + 1);
    end
end

plot_data.cum_release_duration = [plot_data.cum_release_duration;cum_time];

function load_get_num_of_releases(close_time)
global plot_data;

if close_time(1) == 0
    plot_data.release_type = [plot_data.release_type;0];
    return
end

num_of_release = length(close_time);

while 1
    if close_time(num_of_release) == 0
        num_of_release = num_of_release - 1;
    else
        break
    end
end

plot_data.release_type = [plot_data.release_type;num_of_release];

function load_get_cum_content_release(max_int, donor_trace, close_time)
global plot_data;

if close_time(1) == 0
    plot_data.cum_content_release = [plot_data.cum_content_release;0];
    return
end

index = 0;
while 1
    if close_time(end - index) ~= 0
        break
    else
        index = index + 1;
    end
end
    
        

low_int = donor_trace(close_time(end - index));
cum_content_release = ((max_int-low_int)/max_int);
plot_data.cum_content_release = [plot_data.cum_content_release;cum_content_release];
