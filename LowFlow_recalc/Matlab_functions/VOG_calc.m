function RawVogs = VOG_calc( numPaths, Vos, pathInfo, TTdiffs )
%calculate VOG TT

for i = 1:numPaths
    currentPl = pathInfo.PL(i);
    currentAngle = pathInfo.Angle(i);
    currentTTdiff = TTdiffs(i); 
    
    TTgen= currentPl/Vos;

    Tab = TTgen - (currentTTdiff/1000000000/2);
    Tba = TTgen + (currentTTdiff/1000000000/2);

    P1= currentPl/(2*cos(currentAngle));
    P2 = (1/Tab) - (1/Tba);

    RawVogs(i) = P1*P2;
end

end

