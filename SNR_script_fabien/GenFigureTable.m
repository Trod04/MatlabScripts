function GenFigureTable(fullFileName, pulseResults, detectionResults, fidLog)
%Generates the table results for current graph

%initialize return parameters
validMPCTable = 0;

try
    FilterTable(7,4) = 0;
    
    %generate table for pulseresults
    for i = 1:6
        if pulseResults(1,4,i)== 0
            FilterTable(i,:) = pulseResults(1,:,i);
            FilterTable(i,2) = min(pulseResults(:,2,i));
        else
            FilterTable(i,:) = pulseResults(1,:,i);
            FilterTable(i,2) = max(pulseResults(:,2,i));
        end
    end
    
    %enter valid detection points into table
    FilterTable(7,1)= detectionResults(1);
    FilterTable(7,2)= detectionResults(2);
    FilterTable(7,3)= detectionResults(3);    
    FilterTable(7,4)= 0;
    
    %generate Cell structure for table
    cellResults = cell(8,5);
    
    %insert headers
    cellResults{1,1} = 'Test Type';
    cellResults{1,2} = 'Test Results';
    cellResults{1,3} = 'Test Values';
    cellResults{1,4} = 'Limits Type';
    cellResults{1,5} = 'Limits Value';

    %insert testnames into cell
    cellResults{2,1} = 'P4/P2 Ratio';
    cellResults{3,1} = 'P3/P1 Ratio';
    cellResults{4,1} = 'N4/N2 Ratio';
    cellResults{5,1} = 'N3/N1 Ratio';
    cellResults{6,1} = 'Second Wave';
    cellResults{7,1} = 'Signal Noise';
    cellResults{8,1} = 'Valid Detection Points';
    

    %insert testresults
    for i = 1:7   
      if FilterTable(i,1)
         cellResults{i+1,2} = 'OK'; 
      else
         cellResults{i+1,2} = 'FAULT'; 
      end
    end
    
    %insert result values
    for i = 1:7   
         cellResults{i+1,3} = FilterTable(i,2); 
    end
    
    %insert limit type
    for i = 1:7   
      if FilterTable(i,4)
         cellResults{i+1,4} = 'MAX'; 
      else
         cellResults{i+1,4} = 'MIN'; 
      end
    end
    
    %insert limits
    for i = 1:7   
         cellResults{i+1,5} = FilterTable(i,3); 
    end
    
    csvName = strcat(fullFileName , '_results.csv');
    %make CSV file from cell
    cell2csv(csvName, cellResults, ';');

    validMPCTable = 1;
    WriteToLogFile(fidLog,'RESULTS table succesfully generated');
    
catch err
    WriteToLogFile(fidLog,'Error in generating resultstable');
    WriteToLogFile(fidLog,err.message) ;
    return;
end
end

