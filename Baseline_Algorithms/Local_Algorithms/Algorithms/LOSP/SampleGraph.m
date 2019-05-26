function [I2 ,I] = sampleGraph(seeds,graph )
% Sample the subgraph according to BFS

for k = 1 : length(seeds)
    newI = [];
    tempI = find(graph(seeds(k),:)>0);
    newI = union(newI,tempI,'stable');
    I = union(seeds(k), newI,'stable');
    I = sort(I);
    degreesOut = zeros(1,length(I));
    degrees = sum(graph);
    degrees = degrees(I);
    subgraphI = graph(I,I);
    subdegreesIn = sum(subgraphI);

    for i = 1 : length(I)
        degreesOut(1,i) = degrees(1,i) - subdegreesIn(1,i);
    end

    degreesRatio = subdegreesIn./degreesOut;
    [~,Ind] = sort(degreesRatio,'descend');

    for j = 1 : length(Ind)
        if sum(degreesOut(1:Ind(j))) > 3000
            break;
        end
    end

    I2 = I(Ind(1:j));
    [~,I3] = BFS(graph,I2,1);
    I4 = union(I3,I);
    I4 = union(I2,I4);
    I_seeds{1,k} = I4;
end

cellfun(@length,I_seeds);
I = [];

for k = 1 : length(seeds) 
    I = union(I,I_seeds{1,k});
end

if length(I) > 5000
    p = zeros(1,length(I));
    [~, subSeeds ] = intersect(I,seeds);
    subgraph = graph(I,I);
    subSize = length(subgraph);
    p(subSeeds) = 1/3;
    Prob = RandomWalk(subgraph,p,3);
    [~,ind] = sort(Prob,'descend');
    Idx2 = ind(1,1:min(5000,subSize));
    I2 = I(Idx2);
else
    I2 = I;
end

end
