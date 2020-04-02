function [ validNoiseTable ] = GenerateNoiseTable(MeterDir, fidLog, pathConfig, numPaths, tableData, snrErrorTable)
%Generate noise table according to metertype

validNoiseTable = 0;

try
    %generate tablecell and get info from tableData.
    tableCell = cell(numPaths + 1,5);
    tableCell(1,:)= [cellstr('PATH'), cellstr('RESULT'), cellstr('MIN SNR'), cellstr('A'), cellstr('B')];
    tableCell(2:end,1) = pathConfig(2,:)';
    
    %fill in results from tabledata into tablecell
    for i = 1:numPaths
        TrLetter='ab';
        eval(['tableCell(', num2str(i + 1) , ',3)' , ' = cellstr(num2str(tableData.t', num2str(i), 'a.tableresult(3,6)));']);

        for j = 1:2
            eval(['Result', TrLetter(j), ' = tableData.t', num2str(i), TrLetter(j), '.tableresult(1,6);']);

            if j == 1
                eval(['tableCell(', num2str(i + 1) , ',4)' , ' = cellstr(num2str(tableData.t', num2str(i), TrLetter(j), '.tableresult(2,6)));']);
            else
                eval(['tableCell(', num2str(i + 1) , ',5)' , ' = cellstr(num2str(tableData.t', num2str(i), TrLetter(j), '.tableresult(2,6)));']);
            end

        end

        if Resulta && Resultb
            tableCell(i + 1,2)= cellstr('OK');
        else
            tableCell(i + 1,2)= cellstr('FAULT');
        end
    end
    
    %insert snr codes fabien into tableCell
    for i = 2: numPaths+1
        %a-side
        current_a = tableCell{i,4};        
        composedSTR_A = strcat(num2str(current_a), 'dB [' , num2str(snrErrorTable(i-1,1)), ']');        
        tableCell(i,4) = cellstr(composedSTR_A);
        
        %b-side
        current_b = tableCell{i,5};        
        composedSTR_B = strcat(num2str(current_b), 'dB [' , num2str(snrErrorTable(i-1,2)), ']');        
        tableCell(i,5) = cellstr(composedSTR_B);
        
    end
    
    
    csvFullPath = strcat(MeterDir, '\figures\SNRTable.csv');
    cell2csv( csvFullPath, tableCell, ';');
    
    validNoiseTable = 1;
    WriteToLogFile(fidLog,'SNR table succesfully generated.');

catch err
    WriteToLogFile(fidLog,'Error in generating SNR Table.');
    WriteToLogFile(fidLog,err.message) ;
    return;
end

end

