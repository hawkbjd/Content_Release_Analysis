function close_duration = get_close_time(open,close)
%     open = g_spots.release_time; close = g_spots.close_time;
    [r,c] = size(open);
    close_duration = zeros(r,c);
    % i =  rows & j = column
    % c-1 because does not count last close event
    for i = 1:r
        for j = 2:(c-1)
            tmp = open(i,j+1) - close(i,j);
            if tmp > 0
                close_duration(i,j) = tmp;
            end
        end
    end
    
    %get rid of all elements that are not useful (greater than 0)
    [r,~,v] = find(close_duration);
    close_duration = [r,v];