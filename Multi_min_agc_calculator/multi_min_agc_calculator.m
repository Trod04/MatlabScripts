function multi_min_agc_calculator()
%path dir containing all the csv's for max AGC val search (make sure there are
%only MPC csv's in the dir, and that the csv's have a proper name format)
PathDir = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_01_08_low_gain_board_high_pressure_feasability\qplus';

%low gain correction value
lowGainCorr = 2000;

%find all files in DIR
cd(PathDir);
listing = dir('**.csv');

%find num of CSVs
[numCsvs, ~] = size(listing);

%create cell CSV output array
CellData = {};

for x = 1 :numCsvs
    %get metertype from name   
    currentCsvName = listing(x).name;
    meterType = str2num(currentCsvName(24:25));
    meterSize = str2num(currentCsvName(11:12));
    
    %import udata current file    
    FullDir = strcat(PathDir,'\', currentCsvName);
    LoggedData = load(FullDir);    
        
    if meterType == 66
        %trim logfile to AGC values, sub category pathtype and calculate
        %max agc values. add second field for correct low gain value.        
        
        agcdata = LoggedData(:,9:20);
        
        pathtType_data_axial = agcdata(:,5:8);
        pathtType_data_swirl  = [agcdata(:,1:4),agcdata(:,9:12)];
        
        maxAGCvalAx = max(pathtType_data_axial(:));
        maxAGCvalSw = max(pathtType_data_swirl(:));
        maxOverall =  max(agcdata(:));       
        
        maxAGCvalAxCorr = maxAGCvalAx + lowGainCorr;
        maxAGCvalSwCorr = maxAGCvalSw + lowGainCorr;
        maxAGCvalOverallCorr = maxOverall + lowGainCorr;
                
        %make cell matrix for results file
        strCellHeading = [cellstr('Pathtype'),cellstr('maxAGC'), cellstr('maxAGCcorr')];        
        strCellVals = [num2cell(maxAGCvalAx), num2cell(maxAGCvalAxCorr); num2cell(maxAGCvalSw), num2cell(maxAGCvalSwCorr); cellstr('NaN'), cellstr('NaN'); cellstr('NaN'), cellstr('NaN'); num2cell(maxOverall), num2cell(maxAGCvalOverallCorr) ];
        strCollName = [cellstr('Type1_ax');cellstr('Type2_sw');cellstr('Type3_na');cellstr('type4_na');cellstr('type_average')];
        
        strCellCsv = [strCollName,strCellVals];
        strCellCsv = [strCellHeading; strCellCsv];        
    else     
        %trim logfile to AGC values, sub category pathtype and calculate
        %max agc values. add second field for correct low gain value.   
        
        agcdata = LoggedData(:,11:26); 
        
        pathtType_data_long_direct = agcdata(:,7:10);
        pathtType_data_swirl  = [agcdata(:,1:2),agcdata(:,15:16)];
        pathtType_data_short_direct = [agcdata(:,3:6),agcdata(:,11:14)];
        
        maxAGCvalLD = max(pathtType_data_long_direct(:));
        maxAGCvalSw = max(pathtType_data_swirl(:));
        maxAGCvalSD = max(pathtType_data_short_direct(:));
        maxOverall =  max(agcdata(:));
        
        maxAGCvalLDCorr = maxAGCvalLD + lowGainCorr;
        maxAGCvalSwCorr = maxAGCvalSw + lowGainCorr;
        maxAGCvalSDCorr = maxAGCvalSD + lowGainCorr;
        maxAGCvalOverallCorr = maxOverall + lowGainCorr;
                
        %make cell matrix for results file
        strCellHeading = [cellstr('Pathtype'),cellstr('maxAGC'), cellstr('maxAGCcorr')];        
        strCellVals = [num2cell(maxAGCvalLD), num2cell(maxAGCvalLDCorr); num2cell(maxAGCvalSw), num2cell(maxAGCvalSwCorr); cellstr('NaN'), cellstr('NaN'); num2cell(maxAGCvalSD), num2cell(maxAGCvalSDCorr); num2cell(maxOverall), num2cell(maxAGCvalOverallCorr) ];
        strCollName = [cellstr('Type1_LD');cellstr('Type2_sw');cellstr('Type3_na');cellstr('type4_SD');cellstr('type_average')];
        
        strCellCsv = [strCollName,strCellVals];
        strCellCsv = [strCellHeading; strCellCsv];      
    end 
    
    %add results to cell array    

    strCsvTotal = [cellstr(listing(x).name),cellstr('NaN'), num2cell(meterSize); strCellCsv];
 
    CellData = [CellData, strCsvTotal];
end

%write results to output file
cell2csv('SNR_results.txt', CellData);


end

