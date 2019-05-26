function [] = distDistribution(distances,distRatio,partition,option)

% distances: no. of clusters * no. of nodes
% partition: partition vector

% shortest distance distribution
if option==1
    min_dist=min(distances);
    hist(min_dist);
    title('Distance between a node and its closest center');
    xlabel('Distance');
    ylabel('No. of nodes');
end

% distance distribution per cluster
if option==2
    %for k=1:size(distances,1)
    k=4;
        cluster_k_dist=distances(k,partition==k);
        length(cluster_k_dist)
        cluster_k_dist
        cluster_inv_k_dist=distances(k,partition~=k);
        length(cluster_inv_k_dist)
        cluster_inv_k_dist
        
        subplot(1,2,1);
        hist(cluster_k_dist);
        axis([0 1.1 0 10]);
        title(['Nodes in cluster ',num2str(k)]);
        xlabel(['Distance to cluster ',num2str(k)]);
        ylabel('No. of nodes');
        
        subplot(1,2,2);
        hist(cluster_inv_k_dist);
        axis([0 1.1 0 10]);
        title(['Nodes NOT in cluster ',num2str(k)]);
        xlabel(['Distance to cluster ',num2str(k)]);
        ylabel('No. of nodes');
    %end
end

% compute gap and its distribution
if option==3
    sorted_distances = sort(distRatio); % relative distance
    first_gap = sorted_distances(2,:)-sorted_distances(1,:);
    second_gap = sorted_distances(3,:)-sorted_distances(2,:);
    third_gap = sorted_distances(4,:)-sorted_distances(3,:);  
    
    subplot(1,3,1);
    hist(first_gap);
    axis([0 0.1 0 18]);
    title('1st and 2nd clusters');
    xlabel('Relative distance gap');
    ylabel('No. of nodes');
        
    subplot(1,3,2);
    hist(second_gap);
    axis([0 0.1 0 18]);
    title('2nd and 3rd clusters');
    xlabel('Relative distance gap');
    ylabel('No. of nodes');
    
    subplot(1,3,3);
    hist(third_gap);
    axis([0 0.1 0 18]);
    title('3rd and 4th clusters');
    xlabel('Relative distance gap');
    ylabel('No. of nodes');
end

end

