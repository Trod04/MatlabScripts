function  AnalyseMPCFile(MeterDir)

%########################################################################
%# NAME: AnalyseMPCFile.m
%# DESCRIPTION: Automated analysis of NGQ MPC files for NTB
%# OWNER: TROD
%# RELEASE DATE: 16 - 10 - 2017
%# VERSION NUMBER: 3.0
%# NEW FEATURES: implement SNR script Fabien
%########################################################################
%Save currentdir & move to dir where the meterdata is saved
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o


%MeterDir = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\SNR_script_fabien\test_data'; %temporary for testing

PulseSB = 0;

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
[validCT, CT] = MPCOpenCriteriaFile(MeterDir, fidLog);

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
[validType, numPaths, meterType, pathConfig, PathCT] = MPCmeterTypeID( fidLog, CT );

%checks if metertype could be identified--> if not abort
if validType == 0 
    fclose('all');
    return;         %if log can't be opened, stop & close all files
end

%insert PathNumbers in CTINFO
CT.INFO{1,8} = numPaths;

%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%Write meter info to logfile
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
info2log(CT.INFO,meterType, fidLog);

%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%Load csv files
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o

[validCSV, numCSV, CSVdata] = LoadMPCFiles(MeterDir, fidLog);

%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%execute tests
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o

[validMPCtest, MPCPulseTops, MPCPeakRatios, MPCSecondWaves, MPCSnr] = MPCtest(MeterDir, pathConfig, PathCT, CT, numCSV, CSVdata, fidRF, fidLog, PulseSB);

%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
%close all open files & variables
%-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o
ClearMemory();


%########################################################################




end

