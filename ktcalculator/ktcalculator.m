%KT recalculation  script

%input pars
%----------

%sonic log path
strPath = 'D:\lintorfkt\';
strFile = 'kt.csv';

%numpaths meter
numPaths = 6;

%Pathlengts meter
pathLenght(1)= 0.8480;
pathLenght(2)= 0.17541;
pathLenght(3)= 0.6128;
pathLenght(4)= 0.6022;
pathLenght(5)= 0.8473;
pathLenght(6)= 0.17541;
pathLenght(7)= 0;
pathLenght(8)= 0;

%old kt's
oldkt(1) = 13000;
oldkt(2) = 18995;
oldkt(3) = 13000;
oldkt(4) = 13000;
oldkt(5) = 13000;
oldkt(6) = 19116;
oldkt(7) = 10000;
oldkt(8) = 10000;

%theoretical vos
theoreticalVos = 404.2;


%output pars
%-----------
newkt = 0;

%data processing
%---------------

%process udata log
strFullPath = strcat(strPath,strFile);
SonicData = csvread(strFullPath,1,1);

startVosVals = 9 + 5*numPaths;

vosData = SonicData(:,startVosVals:startVosVals + numPaths -1);

for i = 1:numPaths
    vosPath(i) = mean(vosData(:,i));
end

%calculate new kt's
%------------------

%calculate actual transit times in nano seconds
for i = 1:numPaths
    oldTT(i) = pathLenght(i)/vosPath(i) *1000000000;
    actTT(i) = oldTT(i) + oldkt(i); 
end

%calculate theoretical transit time in nano seconds
for i = 1:numPaths
    thTT(i) = pathLenght(i)/theoreticalVos *1000000000;
end

%calculate new kts in nanoseconds
for i = 1:numPaths
    newkt(i) = (actTT(i) - thTT(i));
end

newkt = newkt';
newkt = round(newkt)
