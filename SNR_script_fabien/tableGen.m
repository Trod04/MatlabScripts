function [ validTable, tableData ] = tableGen(fidLog, numCSV, numPaths, processedData)
%generate the value tables for the plot, displays the least favorable
%results per signal

%initialize return parameters
validTable = 0;

try
    TrLetter='ab';
    for i = 1: numPaths
        for j = 1: 2
            %generate empty table
            eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(3,7) =0;']);
            
            for k = 1 : 6
                %look in fourth row of pulseresults to determine if max or min
                %result should be searched
                eval(['MaxMin = processedData.t', num2str(i), TrLetter(j), '.pulseResults(1,4,k);']);
                
                %compose table results according to type: min or max value
                %of all CSVs
                if MaxMin
                    eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(1,k) = isempty(find(processedData.t', num2str(i), TrLetter(j), '.pulseResults(:,1,k) == 0));']);
                    eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(2,k)  = max(processedData.t' , num2str(i), TrLetter(j), '.pulseResults(:,2,k));']);
                    eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(3,k)  = processedData.t', num2str(i), TrLetter(j),'.pulseResults(1,3,k);']);
                else               
                    eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(1,k) = isempty(find(processedData.t', num2str(i), TrLetter(j), '.pulseResults(:,1,k) == 0));']);
                    eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(2,k)  = min(processedData.t' , num2str(i), TrLetter(j), '.pulseResults(:,2,k));']);
                    eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(3,k)  = processedData.t', num2str(i), TrLetter(j),'.pulseResults(1,3,k);']);
                end
            end
            
            %sum up valid detection point and check if all CVS have valid
            %detection points
            
            eval(['validDetectionPoints = sum(processedData.t', num2str(i), TrLetter(j), '.pulseResults(:,2,7));']);
            
            if validDetectionPoints == numCSV
                eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(1,7)  = 1;']);
            else
                eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(1,7)  = 0;']);
            end
                
            eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(2,7)  = validDetectionPoints;']);
            eval(['tableData.t' , num2str(i), TrLetter(j),'.tableresult(3,7)  = numCSV;']);

        end
    end
    validTable = 1;
    WriteToLogFile(fidLog,'plot tables were generated succesfully');

catch err
    tableData = 0;
    WriteToLogFile(fidLog,'Error in generating plot tables');
    WriteToLogFile(fidLog,err.message) ;
    return;
end
end

