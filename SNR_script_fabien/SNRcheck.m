function [ validSNRCheck ] = SNRcheck(MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData)
%initialize return parameters
validSNRCheck = 0;
try
    %log starting SNR tests
    testInfoToLog(fidLog, 'SNRCheck', 1);
    
    %execute all subtests
    %######################################################################
    
    %first subtest: SNR Standard deviation check
    [ validStdTest, resultStdPaths, resultsPksPaths,  maxSTDdev, maxPeaks ] = stdSNR (fidLog, CT, posCSV, LoggedData);

    
    %second subtest: SNR Limits check
    [ validLimitTest, resultsDiffPP, resultsDiffType, resultsDiffGeneral, resultsMinLim, maxDiffPP, maxDiffType, maxDiffGnrl, MinBnd, SNRaveragePP, MinBndPlt] =  limSNR(fidLog, CT, posCSV, pathConfig, LoggedData);
    
 
    %publish results
    %######################################################################
    %writeToResults( fidLog, fidRF, numPaths, testLevel, testNameMain, testNameSub, testResults, testCriteria )
    if validStdTest
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'SNR', 'STDdeviation', resultStdPaths, maxSTDdev );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'SNR', 'PEAKS', resultsPksPaths, maxPeaks );
    end
    
    if validLimitTest
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'SNR', 'LimitPP', resultsDiffPP, maxDiffPP );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'SNR', 'LimitType', resultsDiffType, maxDiffType );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'SNR', 'LimitGENERAL', resultsDiffGeneral, maxDiffGnrl );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'SNR', 'MinLimit', resultsMinLim, MinBnd );
    end

    
    
    %concatenate all results
    if (validStdTest & validLimitTest)
        mainResults(1, LoggedData(1,1))=0;
        for i = 1:LoggedData(1,1)
           if (resultStdPaths(1,i) | resultsPksPaths(1,i) | resultsDiffPP(1,i) | resultsDiffType(1,i) | resultsDiffGeneral(1,i) | resultsMinLim(1,i))
               mainResults(1,i)= 1;
           end
        end
    end
    [logSize, ~]= size(LoggedData);
    writeToResults( fidLog, fidRF, LoggedData(1,1), 1, 'SNR', 'SNR', mainResults, logSize );
    
    %execute all plots
    %######################################################################
    
    %check if foldername exists --> if not create figures folder
    createDir('figures',MeterDir,fidLog)
    currentMeterDir = strcat(MeterDir, '\figures'); 

    %plot different tests
    validPlot = plotSNR(currentMeterDir, fidLog, pathConfig, resultStdPaths, resultsPksPaths, resultsDiffPP, resultsDiffType, resultsDiffGeneral, resultsMinLim, maxSTDdev, maxPeaks, maxDiffPP, maxDiffType, maxDiffGnrl, MinBnd, SNRaveragePP, MinBndPlt);
   
    %if no errors accured, return valid parameter
    %######################################################################
    if validStdTest && validLimitTest && validPlot
        validSNRCheck = 1;
        WriteToLogFile(fidLog,'SNR tests succesfully terminated');      
    else
        WriteToLogFile(fidLog,'Couldnt execute one or more subtests');
    end
catch err
    WriteToLogFile(fidLog,'Error in performing SNRcheck');
    WriteToLogFile(fidLog,err.message);
    return;
end
    
end
