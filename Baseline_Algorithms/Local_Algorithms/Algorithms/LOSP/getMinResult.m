function [bestJaccardindex,bestF05s,bestF1s,bestF2s,bestprecisions,bestrecalls,findCommSize,bestcond] = getMinResult(conductances,bestJaccard,bestF05,bestF1,bestF2,bestprecision,bestrecall,findCommSizes)
% return the best F1 with the min conductance

bestF1s = [];
truthF1s = [];
bestprecisions = [];
bestrecalls = [];
[SIZE1, SIZE2] = size(conductances);

re = [];
k = 1; % best column Idx for each row

for i = 1 : SIZE1 % for each column
    Min = 1;
    for j = 1 : SIZE2 % for each row
        if conductances(i,j) == 0
            break;
        end
        if conductances(i,j) < Min
            Min = conductances(i,j);
            k = j;
        end
    end
    re=[re;i k];
end

for i = 1 : SIZE1
    m = re(i,2);
    if m > length(bestF1)
        m = length(bestF1);
    end
    bestJaccardindex(i) = bestJaccard(i,m);
    bestF05s(i) = bestF05(i,m);
    bestF1s(i) = bestF1(i,m);
    bestF2s(i) = bestF2(i,m);
    bestprecisions(i) = bestprecision(i,m);
    bestrecalls(i) = bestrecall(i,m);
	findCommSize(i) = findCommSizes(i,m);
    bestcond(i) = conductances(i,m);
end

end
