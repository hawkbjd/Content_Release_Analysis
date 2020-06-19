 f = polyval(p,x,[],mu);
 [p,~,mu] = polyfit(x,mean(movmean(traces,25)), 15);
 [min_fit_par,~,mu] = polyfit(x,traces_min, 15);
 x = 1:3000;
 C = bsxfun(@minus, traces, min(traces));
 traces = g_spots.donor(1:g_spots.total,:);
 index_filter = find(traces(:,1) == 0 ); 
 traces(index_filter,:) = [];
 min_fit = polyval(min_fit_par,x,[],mu);
 