function [ validLimitTest, resultsDiffPP, resultsDiffType, resultsDiffGeneral, resultsMinLim, maxDiffPP, maxDiffType, maxDiffGnrl, minBnd, SNRaveragePP, MinBndPlt] =  limSNR(fidLog, CT, posCSV, pathConfig, LoggedData)
    
%determines if all agc values are within limits

%initialize return parameters
validLimitTest = 0;
resultsDiffPP = 0;
resultsDiffType = 0;
resultsDiffGeneral = 0;
resultsMinLim = 0;
maxDiffPP = 0;
maxDiffType = 0;
maxDiffGnrl = 0;
minBnd = 0;
SNRaveragePP = 0;
MinBndPlt = 0;

try
    %get info
    maxDiffPP = CT.SNR(1);
    maxDiffType = CT.SNR(2);
    maxDiffGnrl = CT.SNR(3);
    minBnd = CT.SNR(4);

    numPaths = LoggedData(1,1);
    SnrVals = LoggedData(:,posCSV.SNR:(posCSV.SNR + (numPaths*2) - 1));
    [numRows, ~] = size(SnrVals);

    pathTypes = pathConfig(3,:);

    %write info test to logfile
    testInfoToLog(fidLog, 'SNR Limit test', 2);
    WriteToLogFile(fidLog, strcat('SNR Limit NoOfPaths: ', num2str(numPaths)));
    WriteToLogFile(fidLog, strcat('SNR Limit Path maximum: ', num2str(maxDiffPP)));
    WriteToLogFile(fidLog, strcat('SNR Limit Type maximum: ', num2str(maxDiffType)));
    WriteToLogFile(fidLog, strcat('SNR Limit General maximum: ', num2str(maxDiffGnrl)));
    WriteToLogFile(fidLog, strcat('SNR Lower Limit: ', num2str(minBnd)));

    %generate lower limit band
   
    MinBndPlt(:, 1) = minBnd;


    %determine if min max bandwidth is exeeded
    resultsMinLim(2,numPaths) = 0;

    pathNum = 1;
    for i = 1:2:((numPaths * 2) - 1)
        if min(SnrVals(:,i)) < minBnd || min(SnrVals(:,i+1)) < minBnd
            resultsMinLim(1, pathNum) = 1;
        end
        
        if min(SnrVals(:,i)) > min(SnrVals(:,i+1))
            resultsMinLim(2, pathNum) = min(SnrVals(:,i+1));
        else
            resultsMinLim(2, pathNum) = min(SnrVals(:,i));
        end
        
        pathNum = pathNum + 1;
    end

    %determine if A & B side from individual paths are within limits
    resultsDiffPP(2, numPaths) = 0;
    valsDiffPP(numRows, numPaths) = 0;
    SNRaveragePP(numRows, numPaths) = 0;

    pathNum = 1;
    for i = 1:2:((numPaths * 2)-1)
        for j = 1:numRows
            if abs(SnrVals(j,i) - SnrVals(j,i+1)) > maxDiffPP
                resultsDiffPP(1,pathNum) = 1;
            end
            valsDiffPP(j,pathNum) = abs(SnrVals(j,i) - SnrVals(j,i+1));
            SNRaveragePP(j, pathNum) = (SnrVals(j,i) + SnrVals(j,i+1))/2;
        end
        pathNum = pathNum +1;
    end

    for i = 1: numPaths
        resultsDiffPP(2,i) = max(valsDiffPP(:,i));
    end

    %determine path types stay within limits
    %#########################################################################

    %separerate path types

    pathDeff = { 'AX', 'SW', 'D1', 'D2' };

    pathsMeter(numPaths,3) = 0;
    resultsDiffType(2,numPaths) = 0;

    curPos = 1;
    for i = 1:4
        for j= 1:numPaths
            if pathDeff{i} == pathTypes{j}
                pathsMeter(curPos,1) = i;
                pathsMeter(curPos,2) = j;
                pathsMeter(curPos,3) = mean(SNRaveragePP(:,j));
                curPos = curPos +1;
            end
        end
    end

    %determine if axial type is ok
    numAx = 0;
    for i = 1:numPaths
        if pathsMeter(i,1) == 1
            numAx = numAx +1;
        end
    end

    if numAx > 0
        validAx = 1;
        axPaths(numAx,5) = 0;
        axPaths(1:numAx,1) = [1:numAx];

        curPos = 1;
        for i = 1: numPaths
            if pathsMeter(i,1) == 1
                axPaths(curPos,2) = pathsMeter(i,2);
                axPaths(curPos,3) = pathsMeter(i,3);
                curPos = curPos +1;
            end    
        end    
        for i = 1:numAx
           if abs(axPaths(i,3) - max(axPaths(:,3))) > maxDiffType
               axPaths(i,4)= 1;
           end
           axPaths(i,5)= abs(axPaths(i,3) - max(axPaths(:,3)));
        end    
        for i = 1:numAx
            resultsDiffType(1,axPaths(i,2))= axPaths(i,4);
            resultsDiffType(2,axPaths(i,2))= axPaths(i,5);        
        end    
    end

    %determine if swirl type is ok

    numSw = 0;
    for i = 1:numPaths
        if pathsMeter(i,1) == 2
            numSw = numSw +1;
        end
    end

    if numSw > 0
        validSw = 1;
        swPaths(numSw,5) = 0;
        swPaths(1:numSw,1) = [1:numSw];

        curPos = 1;
        for i = 1: numPaths
            if pathsMeter(i,1) == 2
                swPaths(curPos,2) = pathsMeter(i,2);
                swPaths(curPos,3) = pathsMeter(i,3);
                curPos = curPos +1;
            end    
        end    
        for i = 1:numSw
           if abs(swPaths(i,3) - max(swPaths(:,3))) > maxDiffType
               swPaths(i,4)= 1;
           end
           swPaths(i,5)= abs(swPaths(i,3) - max(swPaths(:,3)));
        end
        for i = 1:numSw
            resultsDiffType(1,swPaths(i,2))= swPaths(i,4);
            resultsDiffType(2,swPaths(i,2))= swPaths(i,5);        
        end  
    end

    %determine if d1 type is ok

    numD1 = 0;
    for i = 1:numPaths
        if pathsMeter(i,1) == 3
            numD1 = numD1 +1;
        end
    end

    if numD1 > 0
        validD1 = 1;
        d1Paths(numD1,5) = 0;
        d1Paths(1:numD1,1) = [1:numD1];

        curPos = 1;
        for i = 1: numPaths
            if pathsMeter(i,1) == 3
                d1Paths(curPos,2) = pathsMeter(i,2);
                d1Paths(curPos,3) = pathsMeter(i,3);
                curPos = curPos +1;
            end    
        end
        for i = 1:numD1
           if abs(d1Paths(i,3) - max(d1Paths(:,3))) > maxDiffType
               d1Paths(i,4)= 1;
           end
           d1Paths(i,5)= abs(d1Paths(i,3) - max(d1Paths(:,3)));
        end
        for i = 1:numD1
            resultsDiffType(1,d1Paths(i,2))= d1Paths(i,4);
            resultsDiffType(2,d1Paths(i,2))= d1Paths(i,5);        
        end  

    end

    %determine if d2 type is ok

    numD2 = 0;
    for i = 1:numPaths
        if pathsMeter(i,1) == 3
            numD2 = numD2 +1;
        end
    end

    if numD2 > 0
        validD2 = 1;
        d2Paths(numD2,5) = 0;
        d2Paths(1:numD2,1) = [1:numD2];

        curPos = 1;
        for i = 1: numPaths
            if pathsMeter(i,1) == 3
                d2Paths(curPos,2) = pathsMeter(i,2);
                d2Paths(curPos,3) = pathsMeter(i,3);
                curPos = curPos +1;
            end    
        end
        for i = 1:numD2
           if abs(d2Paths(i,3) - max(d2Paths(:,3))) > maxDiffType
               d2Paths(i,4)= 1;
           end
           d2Paths(i,5)= abs(d2Paths(i,3) - max(d2Paths(:,3)));
        end
        for i = 1:numD2
            resultsDiffType(1,d2Paths(i,2))= d2Paths(i,4);
            resultsDiffType(2,d2Paths(i,2))= d2Paths(i,5);        
        end  
    end

    %determine if paths are within general limits
    %###########################################################
    generalPaths(1,numPaths) = 0;
    resultsDiffGeneral(2,numPaths) = 0;

    for i = 1 : numPaths
        generalPaths(1,i) = mean(SNRaveragePP(:,i));
    end

    for i = 1:numPaths
        if abs(generalPaths(1,i) - max(generalPaths(1,:))) > maxDiffGnrl
            resultsDiffGeneral(1,i) = 1;
        end
        resultsDiffGeneral(2,i) = abs(generalPaths(1,i) - max(generalPaths(1,:)));
    end 
        
    %write end test to logfile
    WriteToLogFile(fidLog,'SNR Limit test succeeded');
    %return valid test boolean
    validLimitTest = 1;
    
catch err
    
    WriteToLogFile(fidLog,'Error in performing SNR Limit test');
    WriteToLogFile(fidLog,err.message) ;
    return;
    
end

end

