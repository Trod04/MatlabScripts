function [validSTDTest, resultsSTDmax, resultsSTDpeak, maxStdDev, maxNmbPeaks, vosPaths] =  vosSTDtest(fidLog, CT, posCSV, LoggedData)

%initialize return parameters
validSTDTest = 0;
resultsSTDmax = 0;
resultsSTDpeak = 0;
maxStdDev = 0;
maxNmbPeaks = 0;
vosPaths = 0;


try 
    %get info
    numPaths = LoggedData(1,1);
    [numRows, ~] = size(LoggedData);
    
    maxStdDev = CT.VOS(5);
    peakDef = CT.VOS(6);
    maxNmbPeaks = CT.VOS(7);
    
    vosPaths = LoggedData(:,posCSV.VoSpp:(posCSV.VoSpp + (numPaths - 1)));
    
    %write info test to logfile
    testInfoToLog(fidLog, 'Standard Deviation', 2);
    WriteToLogFile(fidLog, strcat('Standard Deviation NoOfPaths: ', num2str(numPaths)));
    WriteToLogFile(fidLog, strcat('Standard Deviation overall maximum: ', num2str(maxStdDev)));
    WriteToLogFile(fidLog, strcat('Standard Deviation peak definition: ', num2str(peakDef), ' * Standard deviation'));
    WriteToLogFile(fidLog, strcat('Standard Deviation maximum number of peaks: ', num2str(maxNmbPeaks)));
    
    
    %generate standardeviation per path
    for h = 1:numPaths
        stdDev(1,h) = std(vosPaths(:,h));
    end

    %generate results maximum STDdev
    resultsSTDmax(1,numPaths)=0;

    for f = 1:numPaths
       if stdDev(1,f) > maxStdDev
          resultsSTDmax(1,f) = 1; 
       end
    end

    resultsSTDmax = [ resultsSTDmax; stdDev ];

    %generate peak height per path

    for g = 1: numPaths
        peakHeight(1,g) = stdDev(1,g) * peakDef;
    end


    %generate average values paths
    avgPath(1,6) = 0;

    for i = 1:numPaths
        avgPath(1,i) = mean(vosPaths(:,i));
    end

    %generate deviation values
    devVals(numRows, numPaths) = 0;

    for j = 1: numPaths
        for k = 1: numRows
            devVals(k,j) = abs(vosPaths(k,j) - avgPath(1,j));
        end
    end

    %count number of peaks
    numPeaks(1, numPaths) = 0;

    for l = 1 : numPaths
        for m = 1 : numRows
            if devVals(m,l) > peakHeight(1,l)
               numPeaks(1,l) =  numPeaks(1,l) + 1;
            end
        end
    end

    %generate results
    resultsSTDpeak(1,numPaths) = 0;

    for n = 1: numPaths
        if numPeaks(1,n) > maxNmbPeaks
            resultsSTDpeak(1,n) = 1;
        end
    end

    resultsSTDpeak = [ resultsSTDpeak; numPeaks ];
    
    %write end test to logfile
    WriteToLogFile(fidLog,'STD deviation test succeeded');
    %return valid test boolean
    validSTDTest = 1;
    
catch err
    WriteToLogFile(fidLog,'Error in performing STD deviation test');
    WriteToLogFile(fidLog,err.message) ;
    return;
end

end

