function [ validPERcheck ] = PERcheck( MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData)
%initialize return parameters
validPERcheck = 0;
try
    %log starting VoS tests
    testInfoToLog(fidLog, 'PERFORMANCE check', 1);
    
    %execute all subtests
    %######################################################################
    
    %first subtest: check if general vog is within limits
    [ ValidPerf, resultPERmin, resultsPERavg, PerfMinLim, PerfAvgLim, PerfPP, LimitAvgBand, LimitMinBand ] = PerfTest(fidLog, CT, posCSV, LoggedData);
    
    
    %publish results
    %######################################################################
    %writeToResults( fidLog, fidRF, numPaths, testLevel, testNameMain, testNameSub, testResults, testCriteria )
    if ValidPerf
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'PERF', 'AVG', resultsPERavg, PerfAvgLim );
    end
    
    if ValidPerf
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'PERF', 'MIN', resultPERmin, PerfMinLim );
    end
      
    %concatenate all results
    if ValidPerf
        mainResults(1, LoggedData(1,1))=0;
        for i = 1:LoggedData(1,1)
           if (resultsPERavg(1,i) | resultPERmin(1,i)) 
               mainResults(1,i)= 1;
           end
        end
        [logSize, ~]= size(LoggedData);
        writeToResults( fidLog, fidRF, LoggedData(1,1), 1, 'PERF', 'PERF', mainResults, logSize );
    end
    
 
    
    %execute all plots
    %######################################################################
    
    %check if foldername exists --> if not create figures folder
    createDir('figures',MeterDir,fidLog)
    currentMeterDir = strcat(MeterDir, '\figures');    

    %plot different tests
    validPltPERF = plotPERF(currentMeterDir, fidLog, pathConfig, resultPERmin, resultsPERavg, PerfMinLim, PerfAvgLim, PerfPP, LimitAvgBand, LimitMinBand);
   

    %if no errors accured, return valid parameter
    %######################################################################
    
   
    if ValidPerf && validPltPERF
        validPERcheck = 1;
        WriteToLogFile(fidLog,'PERFORMANCE tests succesfully terminated');      
    else
        WriteToLogFile(fidLog,'Couldnt execute one or more subtests');
    end
catch err
    WriteToLogFile(fidLog,'Error in performing PERFcheck');
    WriteToLogFile(fidLog,err.message) ;
    return;
end
    
end