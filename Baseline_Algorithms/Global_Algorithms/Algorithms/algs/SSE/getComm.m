function Comm = getComm(C)

[m,n] = size(C);
Comm = cell(n,1);

for i = 1 : n
    Comm{i,1} = find(C(:,i)>0);
end

end


