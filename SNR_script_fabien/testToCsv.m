function [validtable] = testToCsv(currentMeterDir, fidLog, NameTest, testType, testResults, testLimits)
%this function generates the csv needed for generating a info table

%plotgroup: name of the plot were the table belongs to
%nametest: name of the csv that will be generated
%testType: name column 3 in generated csv, defines the type of test
%testResults: array with the results
%testLimits: upper limit of the test

validtable = 0;

try
    testName = strcat(currentMeterDir, '\', NameTest, '.csv');

    [~, numPaths] = size(testResults);

    %generate Cell structure for table
    cellResults = cell(numPaths + 1, 4);

    %insert Tablenames into cell
    cellResults{1,1} = 'NumPaths';
    cellResults{1,2} = 'TestResults';
    cellResults{1,3} = testType;
    cellResults{1,4} = 'Limit';

    %insert pathnumbers
    for i =  1:numPaths
        cellResults{i+1,1} = i;
    end

    %insert testresults
    for i = 1:numPaths   
      if testResults(1,i)
         cellResults{i+1,2} = 'FAULT'; 
      else
         cellResults{i+1,2} = 'OK'; 
      end
    end

    %insert test values
    for i = 1:numPaths
        cellResults{i+1,3} = testResults(2,i);
    end

    %insert limits
    for i = 1:numPaths
        cellResults{i+1,4} = testLimits;
    end

    %make CSV file from cell
    cell2csv(testName, cellResults, ';');
   
    %write succesfull test to logfile
    WriteToLogFile(fidLog,strcat('Generated testresults table for: ', testName));
    validtable = 1;

catch err
    WriteToLogFile(fidLog,strcat('Error in generating table csv for: ', testName));
    WriteToLogFile(fidLog,err.message) ;
end
end

