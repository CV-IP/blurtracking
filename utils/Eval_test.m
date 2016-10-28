base_path = 'E:\OneDrive\2016\Tracking\BlurTracking\iccv-code\result\05-Jul-2016 50 - ¸±±¾\';
dirs = dir(base_path);
		videos = {dirs.name};
		videos(strcmp('.', videos) | strcmp('..', videos) | ...
			strcmp('anno', videos)) = [];
%         videos = load_name();
		
		%the 'Jogging' sequence has 2 targets, create one entry for each.
		%we could make this more general if multiple targets per video
		%becomes a common occurence.
% 		videos(strcmpi('Jogging', videos)) = [];
% 		videos(end+1:end+2) = {'Jogging.1', 'Jogging.2'};
		
		all_precisions = zeros(numel(videos),1);  %to compute averages
        
%         resultpath = ['Ours\'];
		for k = 1:numel(videos),
            load([base_path videos{k}]);
			all_precisions(k) = max(precisions(20,:));
%             [precisions, index] = max(precisions, [], 2);
%             positions = positions(:,:,index(20));
%             eval(['save ' resultpath videos{k} ' positions precisions']);
        end
		
		%compute average precision at 20px, and FPS
		mean_precision = mean(all_precisions);
		fprintf('\nAverage precision (20px):% 1.3f, Average FPS:% 4.2f\n\n', mean_precision)