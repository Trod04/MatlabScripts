function TTinfo = splinePointcalc( numPaths, ZC, sampleData, numSplinePoints);
%define spline point, and calculate exact position zeroCross

%collect spline points from sample data

for i = 1:numPaths*2
    sampleStart = ZC(i) - numSplinePoints/2;
    
    %generate samples array
    for y = 1:numSplinePoints
        splineSamples(1,y) = sampleStart + y - 1;        
    end
    
    %collect vals from MPC data
    for z = 1:numSplinePoints
        splineSamples(2,z) = sampleData(i,splineSamples(1,z)); 
    end
    
    splinePointsPath(:,:,i) = splineSamples;
end

%determine exact ZC's
for i = 1:numPaths*2
    %separate x & y values in to separate vectors
    xValPoly = splinePointsPath(1,:,i);
    yValPoly = splinePointsPath(2,:,i);
    
    %define polynome coeficients and find all roots
    p = polyfit(xValPoly,yValPoly,3);
    polyZC = roots(p);

    %zerocross is between middle spline points, filter out other ones
    polyFmin = xValPoly(numSplinePoints/2)-1;
    polyFmax = xValPoly(numSplinePoints/2+1)+1;

    exactZC(i) = polyZC(polyZC < polyFmax & polyZC > polyFmin);
end

exactZCMPC = exactZC';


%calculate TTdiff between A and B paths
currentPath = 1;

for i = 2:2:numPaths*2
   diffAB = abs(exactZC(i) - exactZC(i-1));   
   
   %time between samples = 320ns, recalculate absolute TTdiff for that
   TTdiff(currentPath) = diffAB *320;
   currentPath = currentPath + 1;    
end

%populate return parameter
TTinfo.exactZC = exactZCMPC;
TTinfo.TTab = TTdiff;

end

