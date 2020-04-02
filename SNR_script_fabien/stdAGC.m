function [ validStdTest, resultsStdPaths, resultsPksPaths,  maxSTDdev, maxPeaks ] = stdAGC (fidLog, CT, posCSV, LoggedData)
%function determins results STD/PEAKS from AGC paths

%initialize return parameters
validStdTest = 0;
resultsStdPaths = 0;
resultsPksPaths = 0;
maxSTDdev = 0;
maxPeaks = 0;

try
    %get info
    numPaths = LoggedData(1,1);
    AGCPaths = LoggedData(:,posCSV.AGC:(posCSV.AGC + (numPaths*2) - 1));
    [numRows, ~] = size(AGCPaths);
    maxSTDdev = CT.AGC(5);
    peakDef = CT.AGC(6);
    maxPeaks = CT.AGC(7);

    %write info test to logfile
    testInfoToLog(fidLog, 'Standard Deviation', 2);
    WriteToLogFile(fidLog, strcat('Standard Deviation NoOfPaths: ', num2str(numPaths)));
    WriteToLogFile(fidLog, strcat('Standard Deviation overall maximum: ', num2str(maxSTDdev)));
    WriteToLogFile(fidLog, strcat('Standard Deviation peak definition: ', num2str(peakDef), ' * Standard deviation'));
    WriteToLogFile(fidLog, strcat('Standard Deviation maximum number of peaks: ', num2str(maxPeaks)));

    %generate standardeviation per path
    for i = 1:(numPaths*2)
        stdDev(1,i) = std(AGCPaths(:,i));
    end

    %generate results maximum STDdev

    resultsSTDmaxA(1,numPaths)=0;
    resultsSTDmaxB(1,numPaths)=0;

    %A sides
    j = 1;
    for i = [1:2:((numPaths*2) -1)]
       if stdDev(1,i) > maxSTDdev
          resultsSTDmaxA(1,j) = 1; 
       end
       j = j +1;
    end
    %B sides
    j = 1;
    for i = [2:2:(numPaths*2)]
       if stdDev(1,i) > maxSTDdev
          resultsSTDmaxB(1,j) = 1; 
       end
       j = j +1;
    end

    %concatate results
    resultsStdPaths(2, numPaths) = 0;
    for i = 1: numPaths
        if resultsSTDmaxA(1,i) || resultsSTDmaxB(1,i)
            resultsStdPaths(1,i) = 1;
        end
    end
    
    j = 1;
    for i = 1:2:((numPaths*2)-1)
        if  stdDev(1,i) > stdDev(1,i+1)
            resultsStdPaths(2,j) = stdDev(1,i);
        else
            resultsStdPaths(2,j) = stdDev(1,i+1);
        end
        j = j+1;
    end

    %generate max deviation PP
    j = 1;
    for i = [1:2:((numPaths*2)-1)]
        if max(stdDev(:,i)) > max(stdDev(:,i+1))
            resultsStdPaths(2,j) = max(stdDev(:,i));
        else
            resultsStdPaths(2,j) = max(stdDev(:,i+1));
        end
        j = j +1;
    end

    %generate peakdefinition per path
    for i = 1:(numPaths*2)
        peakDefPP(1,i) = stdDev(1,i)*peakDef;
    end

    %generate average per path
    for i = 1 : (numPaths*2)
        averagePath(1,i) = mean(AGCPaths(:,i));
    end

    %generate deviation values
    devVals(numRows, numPaths*2) = 0;

    for i = 1: (numPaths*2)
        for j = 1: numRows
            devVals(j,i) = abs(AGCPaths(j,i) -averagePath(1,i));
        end
    end

    %count number of peaks
    numPeaks(1, numPaths*2) = 0;

    for i = 1 : (numPaths*2)
        for j = 1 : numRows
            if devVals(j,i) > peakDefPP(1,i)
               numPeaks(1,i) =  numPeaks(1,i) + 1;
            end
        end
    end

    %generate results maximum Peaks

    resultsPKSmaxA(1,numPaths)=0;
    resultsPKSmaxB(1,numPaths)=0;

    %A sides
    j = 1;
    for i = [1:2:((numPaths*2) -1)]
       if numPeaks(1,i) > maxPeaks
          resultsPKSmaxA(1,j) = 1; 
       end
       j = j +1;
    end
    %B sides
    j = 1;
    for i = [2:2:(numPaths*2)]
       if numPeaks(1,i) > maxPeaks
          resultsPKSmaxB(1,j) = 1; 
       end
       j = j +1;
    end

    %concatate results
    resultsPksPaths(2, numPaths) = 0;
    for i = 1: numPaths
        if resultsPKSmaxA(1,i) || resultsPKSmaxB(1,i)
            resultsPksPaths(1,i) = 1;
        end
    end

    %generate max peaks PP
    j = 1;
    for i = [1:2:((numPaths*2)-1)]
        if numPeaks(1,i) > numPeaks(1,1+1)
            resultsPksPaths(2,j) = numPeaks(1,i);
        else
            resultsPksPaths(2,j) = numPeaks(1,i+1);
        end
        j = j +1;
    end

    %write end test to logfile
    WriteToLogFile(fidLog,'STD deviation test succeeded');
    %return valid test boolean
    validStdTest = 1;
    
catch err
    
    WriteToLogFile(fidLog,'Error in performing STD deviation test');
    WriteToLogFile(fidLog,err.message) ;
    return;
    
end

end

