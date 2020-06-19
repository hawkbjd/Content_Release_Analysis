function open_duration = get_open_time(open,close)
%     open = g_spots.release_time; close = g_spots.close_time;

    event_index = open(:,1) > 0;
    open = open(event_index,:);
    close = close(event_index,:);
    [r,c] = size(open);
    releases = nnz(open(:,2:end));
    open_duration = zeros(releases,3);
    counter = 0;
    for i = 1:r
        for j = 2:c
            if (open(i,j) ~= 0) && (close(i,j) ~= 0)
                tmp = close(i,j) - open(i,j);
                if tmp > 0
                    counter = counter +1;
                    open_duration(counter,1) = i;
                    open_duration(counter,2) = j-1;
                    open_duration(counter,3) = tmp;
                end
            end
        end
    end
