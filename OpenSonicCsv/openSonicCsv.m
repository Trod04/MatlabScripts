function openSonicCsv()


strPath = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_09_25_process_low_flow_sample_data_TCC\data\';
strFile = 'trimmed_dataset.csv';

strFullPath = strcat(strPath,strFile);

SonicData = csvread(strFullPath,1,1);


end

