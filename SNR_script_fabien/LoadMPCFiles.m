function [validCSV, numCSV, CSVdata] = LoadMPCFiles(MeterDir, fidLog)
%Load the CSV files located in the folder

%initialise return parameters
validCSV = 0;
numCSV = 0;

try
    %generate a list of all the .csv files in the dir
    fullPathPulses = strcat(MeterDir, '\PULSE*.csv');
    FileList = dir(fullPathPulses); 

    %check if filelist is empty & get number of csvs
    if isempty(FileList)
       WriteToLogFile(fidLog,'no csv files found!')
       return
    else
       WriteToLogFile(fidLog,[num2str(length(FileList)) ' csv files found'])
       numCSV = length(FileList);
    end
    
    %generate namelist
    nameCSV = cell(numCSV,1);
        
    for i = 1:numCSV
        nameCSV{i,1} = FileList(i).name;
    end
    
    %merge txt files
    system('copy /b *.CSV  mergedPulses.CSV');
    
    for k = 1: numCSV
        currentCSV = strcat(MeterDir, '\', nameCSV{k});
        data=importdata(currentCSV, ',',0);
        strData=data.textdata;
        numData=data.data;

        [row,col]=size(numData);
        
        for i=row:-1:1
            if isnan(numData(i,100))
                numData(i,:)=[];
            end
        end
        
        TrLetter='ab';
        [row,~]=size(numData);
        
        for i=1:8
            for j=1:2
                I=find(numData(:,1)==i & numData(:,2)==j); %#ok<EFIND>
                
                %large window MPCs dont have an equal number of samples,
                %look for first sample at the end of the row that is not
                %NAN and trim the row based on this position
                
                if ~isempty(I)                    
                    RowData = 0;
                    RowDetectionPoint = 0;
                    
                    for f = col:-1:1
                        if ~isnan(numData(I,f))
                            RowData = numData(I,27:f-6);
                            RowDetectionPoint = numData(I, f)-22;
                            break
                        end              
                    end

                    eval(['CSVdata.CSV', num2str(k), '.t', num2str(i), TrLetter(j), '.Puls = RowData;']);
                    eval(['CSVdata.CSV', num2str(k), '.t', num2str(i), TrLetter(j), '.DetectionPoint = RowDetectionPoint;']);
                end

            end
        end

       eval(['CSVdata.CSV', num2str(k),'.Signal = numData(:,25:col-2);']);
        
    end  
    
       
    %test succeeded, set validCSV
    validCSV = 1;
    
    %write event to logfile
    WriteToLogFile(fidLog,'MPC files were loaded succesfully');
           
catch err
    %write event to logfile
    CSVdata = 0;
    WriteToLogFile(fidLog,'Error in loading MPC files');
    WriteToLogFile(fidLog,err.message) ;
end      


end

