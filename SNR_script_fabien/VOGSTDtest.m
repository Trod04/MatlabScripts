function [ validSTDTest, resultSTD, resultsPKS, maxStdDev, maxNmbPeaks ] = VOGSTDtest(fidLog, CT, posCSV, LoggedData);

%initialize return parameters
validSTDTest = 0;
resultSTD = 0;
resultsPKS = 0;
maxStdDev = 0;
maxNmbPeaks = 0;



try 
    %get info
    numPaths = LoggedData(1,1);
    [numRows, ~] = size(LoggedData);
    
    maxStdDev = CT.VGAS(5);
    peakDef = CT.VGAS(6);
    maxNmbPeaks = CT.VGAS(7);
    
    VoGpp = LoggedData(:,posCSV.VoGpp:(posCSV.VoGpp + (numPaths - 1)));
    
    %write info test to logfile
    testInfoToLog(fidLog, 'Standard Deviation VoG', 2);
    WriteToLogFile(fidLog, strcat('Standard Deviation VoG NoOfPaths: ', num2str(numPaths)));
    WriteToLogFile(fidLog, strcat('Standard Deviation VoG overall maximum: ', num2str(maxStdDev)));
    WriteToLogFile(fidLog, strcat('Standard Deviation VoG peak definition: ', num2str(peakDef), ' * Standard deviation'));
    WriteToLogFile(fidLog, strcat('Standard Deviation VoG maximum number of peaks: ', num2str(maxNmbPeaks)));
    
    
    %generate standardeviation per path
    for i = 1:numPaths
        stdDev(1,i) = std(VoGpp(:,i));
    end

    %generate results maximum STDdev
    resultSTD(1,numPaths)=0;

    for i = 1:numPaths
       if stdDev(1,i) > maxStdDev
          resultSTD(1,i) = 1; 
       end
    end

    resultSTD = [ resultSTD; stdDev ];

    %generate peak height per path

    for i = 1: numPaths
        peakHeight(1,i) = stdDev(1,i) * peakDef;
    end


    %generate average values paths
    avgPath(1,6) = 0;

    for i = 1:numPaths
        avgPath(1,i) = mean(VoGpp(:,i));
    end

    %generate deviation values
    devVals(numRows, numPaths) = 0;

    for j = 1: numPaths
        for k = 1: numRows
            devVals(k,j) = abs(VoGpp(k,j) - avgPath(1,j));
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
    resultsPKS(1,numPaths) = 0;

    for n = 1: numPaths
        if numPeaks(1,n) > maxNmbPeaks
            resultsPKS(1,n) = 1;
        end
    end

    resultsPKS = [ resultsPKS; numPeaks ];
    
    %write end test to logfile
    WriteToLogFile(fidLog,'STD deviation VoG test succeeded');
    %return valid test boolean
    validSTDTest = 1;
    
catch err
    WriteToLogFile(fidLog,'Error in performing STD deviation VoG test');
    WriteToLogFile(fidLog,err.message) ;
    return;
end

end

