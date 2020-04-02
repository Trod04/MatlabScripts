function writeToResults( fidLog, fidRF, numPaths, testLevel, testNameMain, testNameSub, testResults, testCriteria )

%test level definitions
%test level 1 = main test
%test level 2 = sub test


try
    switch testLevel
        case 1
            testLevel = 'GENERAL';
        case 2
            testLevel = 'DET';
    end
    
    switch testLevel
        case 'DET'
            for i = 1:numPaths
                if ~testResults(1,i)
                    fwrite(fidRF, strcat( testLevel, ';' , testNameMain , ';' , num2str(i) , ';OK;', testNameSub ,  ';' , num2str(testResults(2,i)) , ';0.0;', num2str(testCriteria)));
                    fprintf(fidRF,'\n');
                else
                    fwrite(fidRF, strcat( testLevel, ';' , testNameMain , ';' , num2str(i) , ';FAULT;', testNameSub ,  ';' , num2str(testResults(2,i)) , ';0.0;', num2str(testCriteria)));
                    fprintf(fidRF,'\n');
                end
            end
        case 'GENERAL'
            for i = 1:numPaths
                if ~testResults(1,i)
                    fwrite(fidRF, strcat( testLevel, ';' , testNameMain , ';' , num2str(i) , ';OK;' , num2str(testCriteria)));
                    fprintf(fidRF,'\n');
                else
                    fwrite(fidRF, strcat( testLevel, ';' , testNameMain , ';' , num2str(i) , ';OK;', num2str(testCriteria)));
                    fprintf(fidRF,'\n');
                end
            end
    end
    
    WriteToLogFile(fidLog, strcat(testNameSub, ' was succesfully written to resultsfile.'));
    
catch err
    WriteToLogFile(fidLog, strcat({'Error in writing '}, testNameSub, {' to resultsfile'}));
    WriteToLogFile(fidLog,err.message) ;
end






end

