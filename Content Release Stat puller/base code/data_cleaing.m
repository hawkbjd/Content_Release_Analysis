function data = data_cleaing(data)

%get rid of rows that only have zeros
event_index = data.donor(:, 1) > 0;
data.donor = data.donor(event_index > 0,:);
data.dock_time = data.dock_time(event_index > 0,:);
data.end_time = data.end_time(event_index > 0,:);
data.release_time = data.release_time(event_index,:);
data.close_time = data.close_time(event_index > 0,:);

%reset event number to match new # of rows
[r,~] = size(data.donor);
data.dock_time(:,1) = (1:r)';
data.end_time(:,1) = (1:r)';
data.release_time(:,1) = (1:r)';
data.close_time(:,1) = (1:r)';
data.total(:,1) = r;

%make sure that there no zeros between event # and event times for
%release_time and close_time
data.release_time = zero_remover(data.release_time);
data.close_time = zero_remover(data.close_time);