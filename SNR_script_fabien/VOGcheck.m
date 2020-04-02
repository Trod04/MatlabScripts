function [ validVoGcheck ] = VOGcheck( MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData)
%initialize return parameters
validVoGcheck = 0;
try
    %log starting VoS tests
    testInfoToLog(fidLog, 'VoGcheck', 1);
    
    %execute all subtests
    %######################################################################
    
    %first subtest: check if general vog is within limits
    [ validVOGTest, resultVOG, maxdevVOG, VOG, VOGband ] = VOGtest(fidLog, CT, posCSV, LoggedData);
    
    %second subtest: check if VoGpp is within limits
    [ validVOGppTest, resultVOGpp, maxdevVOGpp, VOGpp, VOGppband ] = VOGpptest(fidLog, CT, posCSV, LoggedData);
    
    %third subtest: check STD deviation & peaks
    [ validSTDTest, resultSTD, resultsPKS, maxStdDev, maxNmbPeaks ] = VOGSTDtest(fidLog, CT, posCSV, LoggedData);
    
    %publish results
    %######################################################################
    %writeToResults( fidLog, fidRF, numPaths, testLevel, testNameMain, testNameSub, testResults, testCriteria )
    if validVOGTest
        writeToResults( fidLog, fidRF, 1, 2, 'VOG', 'VOGGENERAL', resultVOG, maxdevVOG );
    end
    
    if validVOGppTest
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'VOG', 'VOGpp', resultVOGpp, maxdevVOGpp );
    end
    
    if validSTDTest
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'VOG', 'STD', resultSTD, maxStdDev );
        writeToResults( fidLog, fidRF, LoggedData(1,1), 2, 'VOG', 'PKS', resultsPKS, maxNmbPeaks );
    end  
      
    %concatenate all results
    if (validVOGTest & validVOGppTest & validSTDTest)
        mainResults(1, LoggedData(1,1))=0;
        for i = 1:LoggedData(1,1)
           if (resultVOG(1,1) | resultVOGpp(1,i) | resultSTD(1,i) | resultsPKS(1,i)) 
               mainResults(1,i)= 1;
           end
        end
        [logSize, ~]= size(LoggedData);
        writeToResults( fidLog, fidRF, LoggedData(1,1), 1, 'VOG', 'VOG', mainResults, logSize );
    end
    
    
    
    %execute all plots
    %######################################################################
    %check if foldername exists --> if not create figures folder
    createDir('figures',MeterDir,fidLog)
    currentMeterDir = strcat(MeterDir, '\figures');


    %plot different tests
    validPltVoG = plotVoG(currentMeterDir, fidLog, pathConfig, resultVOG, resultVOGpp, resultSTD, resultsPKS, maxdevVOG, maxdevVOGpp, maxStdDev, maxNmbPeaks, VOG, VOGpp, VOGband, VOGppband);
 
   
    %if no errors accured, return valid parameter
    %######################################################################
    
   
    if validVOGTest && validVOGppTest && validSTDTest && validPltVoG
        validVoGcheck = 1;
        WriteToLogFile(fidLog,'VoG tests succesfully terminated');      
    else
        WriteToLogFile(fidLog,'Couldnt execute one or more subtests');
    end
catch err
    WriteToLogFile(fidLog,'Error in performing VOGcheck');
    WriteToLogFile(fidLog,err.message) ;
    return;
end
    
end
