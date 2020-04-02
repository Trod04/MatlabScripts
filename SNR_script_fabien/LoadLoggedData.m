function [ LoggedData ] = LoadLoggedData(MeterDir, fidLog)

LoggedData = []; %initialise parameter

fullFilePath = strcat(MeterDir, '\*.csv');
FileList = dir(fullFilePath); %generate a list of all the .csv files in the dir

if isempty(FileList)
   WriteToLogFile(fidLog,'no csv files found!')
   return % no files present in dir
end

FileNaam = FileList(1).name;

if length(FileList) > 1
    WriteToLogFile(fidLog,'more then 1 csv file found!')
    WriteToLogFile(fidLog,['loading first file: ' FileNaam]); 
end

try    
    %LoggedData = load(['''' FileNaam '''']);
    fullPathFilename = strcat(MeterDir, '\', FileNaam);
    LoggedData = load(fullPathFilename);
    WriteToLogFile(fidLog,[FileNaam ' loaded'])
    [nR, nC] = size(LoggedData);
    WriteToLogFile(fidLog,['Logdata rows/columns: ' num2str(nR) ' / ' num2str(nC)])
catch err
    WriteToLogFile(fidLog,['Could not load ' FileNaam])
    WriteToLogFile(fidLog,err.message) 
end

end
