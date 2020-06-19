function [release_percent,release_summary] = get_percent_type(num_of_release_events)

low = min(num_of_release_events);
high = max(num_of_release_events);
range = low:high;
release_summary = zeros(max(num_of_release_events),2);
if low == 0
    release_summary = [release_summary;[0 0]];
end    
for r = range
    if low == 0
        row = r + 1;
    else
        row = r;
    end
    release_summary(row,2) = sum(num_of_release_events == r);
end
release_summary(:,1) = range';
release_index = release_summary(:, 2) > 0;
release_summary = release_summary(release_index,:);
range = range(release_index');
perecent = (release_summary(:, 2) ./ sum(release_summary(:, 2)))*100;
release_percent = [range',perecent];