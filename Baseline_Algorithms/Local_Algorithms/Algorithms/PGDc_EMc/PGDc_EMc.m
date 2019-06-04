function [] = PGDc_d(algoMode) 
% PGDc-d: The projected gradient descent algorithm for optimizing sigma-conductance
% EMc: The Expectation Maximization algorithm for optimizing sigma-conductance

if nargin < 1
    algoMode = 1;
end

graphPath = '../../../../test_data/zachary';
communityPath = '../../../../test_data/zachary.txt';

% load graph
graph = loadGraph(graphPath);

% load truth communities
comm = loadCommunities(communityPath);

% choose a community from truth communities randomly
commId = randi(length(comm));

% choose 3 nodes from selected community randomly
seedId = randperm(length(comm{commId}),3);
seed = comm{commId}(seedId);

seed_vec = zeros(length(graph),1);
seed_vec(seed) = 1;

if algoMode == 1
    [set,l] = optimize_cluster(graph,seed_vec);
    savePathandName = '../../Results/zachary/result_PGDc-0.txt';
elseif algoMode == 2
    [set,l] = optimize_cluster(graph,seed_vec,'score','sigma');
    savePathandName = '../../Results/zachary/result_PGDc-d.txt';
elseif algoMode == 3
    [set,l] = optimize_cluster(graph,seed_vec,'method','em','sigma',0);
    savePathandName = '../../Results/zachary/result_EMc-0.txt';
elseif algoMode == 4
    [set,l] = optimize_cluster(graph,seed_vec,'method','em');
    savePathandName = '../../Results/zachary/result_EMc-d.txt';
else
    error('Not a valid algorithm mode');
end
set = find(set);

% compute F1 score and Jaccard index
jointSet = intersect(set,comm{commId});
unionSet = union(set,comm{commId});
jointLen = length(jointSet);
unionLen = length(unionSet);

F1 = 2*jointLen/(length(set)+length(comm{commId})); 
Jaccard = jointLen/unionLen;

% printing out result
fprintf('The detected community is')
disp(set')
fprintf('The F1 score and Jaccard index between detected community and ground truth community are %.3f and %.3f\n',F1,Jaccard)

% save out result
dlmwrite(savePathandName,'The detected community is','delimiter','');
dlmwrite(savePathandName,set','-append','delimiter','\t','precision','%.0f');
dlmwrite(savePathandName,['The F1 score and Jaccard index between detected community and ground truth community are ' num2str(F1,'%.3f') ' and ' num2str(Jaccard,'%.3f')],'-append','delimiter','');

end
