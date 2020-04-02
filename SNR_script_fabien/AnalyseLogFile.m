function  AnalyseLogFile(MeterDir)

%########################################################################
%# NAME: AnalyseLogFile.m
%# DESCRIPTION: Automated analysis of NGQ logfile for NTB
%# OWNER: TROD
%# RELEASE DATE: 01 - 09 - 2014
%# VERSION NUMBER: 3.0
%# NEW FEATURES: FinalMerge Base
%########################################################################
%Save currentdir & move to dir where the meterdata is saved
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o


%MeterDir = 'C:\Users\TROD\Documents\NTB\Matlab\matlab_new_analysis_tool\testdata\192_168_160_120\MeterDataAnalysis'; %temporary for test

%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%Open/create Logfile, Criteria, Results
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o

%open logfile
[validLog, fidLog] = OpenLogfile(MeterDir);

%checks validity of logfile --> if not abort
if validLog == 0
    fclose('all');
    return;         %if log can't be opened, stop & close all files
end

%open criteria
[validCT, CT] = OpenCriteriaFile(MeterDir, fidLog);

%checks validity of criteriafile --> if not abort
if validCT == 0 
    fclose('all');
    return;         %if log can't be opened, stop & close all files
end

%open resultsfile
fidRF = OpenResultsFile(MeterDir, fidLog);

%checks if resultsfile could be created --> if not abort

if fidRF < 0
    fclose('all');
    return;         %if log can't be opened, stop & close all files
end
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%Check/loads metertype, pathconfiguration, CSV positions, UDATA format.
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o

%gets the metertype & pathconfiguration from the loaded criteriafile 
%determine the column positions in the CSV file.
writeToLogfile = 1;
[validType, numPaths, meterType, pathConfig, posCSV] = meterTypeID( fidLog, CT.INFO, writeToLogfile );

%checks if metertype could be identified--> if not abort
if validType == 0 
    fclose('all');
    return;         %if log can't be opened, stop & close all files
end

%insert PathNumbers in CTINFO
CT.INFO{1,8} = numPaths;

%check if the wright u-dataformat is used
validUDATA = checkUDATA(fidLog, CT.INFO);

%checks if UDATATYPE could be identified--> if not abort
if validUDATA == 0 
    fclose('all');
    return;         %if UDATA isn't correct/couldn't be identified --> abort
end

%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%Write meter info to logfile
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
info2log(CT.INFO,meterType, fidLog);

%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%Load logged udata from meter
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
LoggedData = LoadLoggedData(MeterDir, fidLog);

if isempty(LoggedData)
    WriteToLogFile(fidLog,'LoggedData is empty');
    fclose('all');
    return;         %if logfile is empty --> abort
end

%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%execute tests
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
try
    validVoScheck = 0;
    if CT.VOS(8)
        validVoScheck = VOScheck(MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData);
    end

    validVoGcheck = 0;
    if CT.VGAS(8)
        validVoGcheck = VOGcheck(MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData);
    end

    validPERcheck = 0;
    if CT.PERF(8)
        validPERcheck = PERcheck(MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData);
    end

    validAgcCheck = 0;
    if CT.AGC(8)
        validAgcCheck = AGCcheck(MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData);
    end

    validSNRCheck = 0;
    if CT.SNR(8)
        validSNRCheck = SNRcheck(MeterDir, fidLog, fidRF, CT, pathConfig, posCSV, meterType, LoggedData);
    end

    if (validVoScheck | ~CT.VOS(8)) & (validVoGcheck | ~CT.VGAS(8)) & (validPERcheck | CT.PERF(8)) & (validAgcCheck | ~CT.AGC(8)) & (validSNRCheck | ~CT.SNR(8))
        WriteToLogFile(fidLog,'All tests succeeded, finishing matlab LogDataAnalysis and closing all open files.');
    else
        WriteToLogFile(fidLog,'One or more failed tests, finishing matlab LogDataAnalysis and closing all open files.');
    end
    
catch err
    WriteToLogFile(fidLog,err.message);
end

%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%close all open files & variables
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
ClearMemory();


%########################################################################




end

