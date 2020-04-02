function [ validAgcCheck ] = AGCcheck(MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData)
%initialize return parameters
validAgcCheck = 0;
try
    %log starting AGC tests
    testInfoToLog(fidLog, 'AgcCheck', 1);
    
    %execute all subtests
    %######################################################################
    
    %first subtest: AGC STD dev check
    [ validStdTest, resultStdPaths, resultsPksPaths,  maxSTDdev, maxPeaks ] = stdAGC (fidLog, CT, posCSV, LoggedData);

    
    %second subtest: AGC Limits check
    [ validLimitTest, resultsDiffPP, resultsDiffType, resultsDiffGeneral, resultsMinLim, resultsMaxLim, maxDiffPP, maxDiffType, maxDiffGnrl, MinBnd, MaxBnd, AGCaveragePP, MinMaxBndPlt] =  limAGC(fidLog, CT, posCSV, pathConfig, LoggedData);
    
 
    %publish results
    %######################################################################
    %writeToResults( fidLog, fidRF, numPaths, testLevel, testNameMain, testNameSub, testResults, testCriteria )
    if validStdTest
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'AGC', 'STDdeviation', resultStdPaths, maxSTDdev );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'AGC', 'PEAKS', resultsPksPaths, maxPeaks );
    end
    
    if validLimitTest
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'AGC', 'LimitPP', resultsDiffPP, maxDiffPP );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'AGC', 'LimitType', resultsDiffType, maxDiffType );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'AGC', 'LimitGENERAL', resultsDiffGeneral, maxDiffGnrl );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'AGC', 'MinLimit', resultsMinLim, MinBnd );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'AGC', 'MaxLimit', resultsMaxLim, MaxBnd );
    end

    
    
    %concatenate all results
    if (validStdTest & validLimitTest)
        mainResults(1, LoggedData(1,1))=0;
        for i = 1:LoggedData(1,1)
           if (resultStdPaths(1,i) | resultsPksPaths(1,i) | resultsDiffPP(1,i) | resultsDiffType(1,i) | resultsDiffGeneral(1,i) | resultsMinLim(1,i) | resultsMaxLim(1,i))
               mainResults(1,i)= 1;
           end
        end
    end
    [logSize, ~]= size(LoggedData);
    writeToResults( fidLog, fidRF, LoggedData(1,1), 1, 'AGC', 'AGC', mainResults, logSize );
    
    %execute all plots
    %######################################################################
    
    %check if foldername exists --> if not create figures folder
    createDir('figures',MeterDir,fidLog)
    currentMeterDir = strcat(MeterDir, '\figures');    

    %plot different tests
    validPlot = plotAGC(currentMeterDir, fidLog, pathConfig, resultStdPaths, resultsPksPaths, resultsDiffPP, resultsDiffType, resultsDiffGeneral, resultsMinLim, resultsMaxLim, maxSTDdev, maxPeaks, maxDiffPP, maxDiffType, maxDiffGnrl, MinBnd, MaxBnd, AGCaveragePP, MinMaxBndPlt);
   
    %if no errors accured, return valid parameter
    %######################################################################
    if validStdTest && validLimitTest && validPlot
        validAgcCheck = 1;
        WriteToLogFile(fidLog,'AGC tests succesfully terminated');      
    else
        WriteToLogFile(fidLog,'Couldnt execute one or more subtests');
    end
catch err
    WriteToLogFile(fidLog,'Error in performing AGCcheck');
    WriteToLogFile(fidLog,err.message);
    return;
end
    
end




