function judgeflag = judgeLocal(conductances,j)

judgeflag = 0;

if j < 10
    steps = 2;
elseif j >= 10
    steps = 3;
end

judgeConductances = conductances(1,j:(j+steps));
k = 1;
judgeContinues = diff(conductances(1,j:j+2));

if judgeContinues(1,2) > 0
    k = 2;
end

if conductances(1,j+k)/conductances(1,j) > 1.7 
    judgeflag = 1;
end

end
