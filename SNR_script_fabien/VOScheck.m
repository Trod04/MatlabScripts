function [ validVOScheck ] = VOScheck( MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData)
%initialize return parameters
validVOScheck = 0;
try
    %log starting VoS tests
    testInfoToLog(fidLog, 'VoScheck', 1);
    
    %execute all subtests
    %######################################################################
    
    %first subtest: determine if kt's deviation is within margins from
    %eachother/vosFAT
    [ validKTTest, resultKTpath, resultKTfat, resultRelFAT,  maxdevPath, maxdevFAT, maxDevRel,DevPathFAT, relDev, absDev   ] = ktDiff(fidLog, CT, posCSV, LoggedData);

    
    %second subtest: check if the STD deviation isn't too high + check for
    %max number of peaks
    [ validSTDTest, resultsSTDmax, resultsSTDpeak , maxStdDev, maxNmbPeaks, vosPaths] =  vosSTDtest(fidLog, CT, posCSV, LoggedData);
    
    
    %third subtest: check if the maximum bandwidth isn't exeeded
    [ validBandTest, resultsBand, Bandwidth, MinMaxBand ] =  vosBandTest(fidLog, CT, posCSV, LoggedData);
    
    
    %publish results
    %######################################################################
    %writeToResults( fidLog, fidRF, numPaths, testLevel, testNameMain, testNameSub, testResults, testCriteria )
    if validKTTest
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'VOS', 'KTPATH', resultKTpath, maxdevPath );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'VOS', 'KTABSFAT', resultKTfat, maxdevFAT );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'VOS', 'KTRELFAT', resultRelFAT, maxDevRel );
    end
    
    if validSTDTest
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'VOS', 'STD', resultsSTDmax, maxStdDev );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'VOS', 'PKS', resultsSTDpeak, maxNmbPeaks );
    end
    
    if validBandTest
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'VOS', 'DEVBAND', resultsBand, Bandwidth );
    end
    
    
    %concatenate all results
    if (validKTTest & validSTDTest & validBandTest)
        mainResults(1, LoggedData(1,1))=0;
        for i = 1:LoggedData(1,1)
           if (resultKTpath(1,i) | resultKTfat(1,i) | resultRelFAT(1,i) | resultsSTDmax(1,i) | resultsSTDpeak(1,i) | resultsBand(1,i)) 
               mainResults(1,i)= 1;
           end
        end
    end
    
    [logSize, ~]= size(LoggedData);
    
    writeToResults( fidLog, fidRF, LoggedData(1,1), 1, 'VOS', 'VOS', mainResults, logSize );
    
    %execute all plots
    %######################################################################
    
    %check if foldername exists --> if not create figures folder
    createDir('figures',MeterDir,fidLog)
    currentMeterDir = strcat(MeterDir, '\figures');
    
    %plot different tests
    validDeltaVos = plotDeltaVos(currentMeterDir, fidLog, pathConfig, resultKTpath, resultKTfat, resultRelFAT, maxdevPath, maxdevFAT, maxDevRel,DevPathFAT, relDev, absDev );
    validVos = plotVos(currentMeterDir, fidLog, pathConfig, resultsSTDmax, resultsSTDpeak, resultsBand, maxStdDev, maxNmbPeaks, Bandwidth, vosPaths, MinMaxBand);
    
    validPlot = 0;
    if validDeltaVos && validVos
        validPlot =1;
    end
    
    %if no errors accured, return valid parameter
    %######################################################################
    if validKTTest && validSTDTest && validBandTest && validPlot
        validVOScheck = 1;
        WriteToLogFile(fidLog,'VoS tests succesfully terminated');      
    else
        WriteToLogFile(fidLog,'Couldnt execute one or more subtests');
    end
catch err
    WriteToLogFile(fidLog,'Error in performing VOScheck');
    WriteToLogFile(fidLog,err.message) ;
    return;
end
    
end

