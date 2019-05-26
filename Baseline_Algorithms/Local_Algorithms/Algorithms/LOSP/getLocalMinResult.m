function [LocalMin,findCommSize] = getLocalMinResult(conductances,minCommSize,maxCommSize,w)

minConducts = sort(conductances(minCommSize:maxCommSize));

for i = 1 : length(minConducts)
    if minConducts(1,i) > 0
        minConduct = minConducts(1,i);
        break;
    end
end

if minCommSize == maxCommSize
    minConduct = conductances(maxCommSize-1);
end

cut = min(5,maxCommSize-1);

findCommSizefirst = find(abs(diff(w(cut:maxCommSize,1))) == max(abs(diff(w(cut:maxCommSize,1)))),1) + cut;
LocalMinfirst = conductances(1,findCommSizefirst);
LocalMin = LocalMinfirst;
findCommSize = findCommSizefirst;
flag = 1;     

for i = 1 : (length(w)-1)   
    maxcut = 0.15;
    mincut = 0.1;
    if (w(i)-w(i+1)) > maxcut && w(i+1) < mincut
        findCommSize = i + 1;
        if findCommSize < 15
            flag = 0;
            LocalMin = conductances(1,findCommSize);
            break;
        end
    end
end

if flag == 1
    for j = minCommSize : (maxCommSize-5) 
        if conductances(1,j) == 0
            continue;
        end
        if judgeLocal(conductances,j) == 1
            LocalMin = conductances(1,j);
            findCommSize = j;
            break;
        end
    end
end

end
