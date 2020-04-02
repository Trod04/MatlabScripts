function multi_pulse_process()
%-------------------------------------------------------------------------
%Author: TROD
%Date modified: 21/03/2019
%
%Description:
%
%process multiple MPC or scope at once and save results to output 
%-------------------------------------------------------------------------

%populate data variables
%-------------------------------------------------------------------------

blnMPCscope = 0; %select if you are processing an MPC or scope capture
inputFolder = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_03_19_ITF_signal_capture_flow_envelope_test\data\ITF_scope_capture';
%inputFolder = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_03_19_ITF_signal_capture_flow_envelope_test\data\crash_test';
outputFolder = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_03_19_ITF_signal_capture_flow_envelope_test\data\proccessed_pulses';
%outputFolder = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_03_19_ITF_signal_capture_flow_envelope_test\data\crash_test';
blnSubFolder = 1; %indacte if there is a subfolder or not
strSubFolderName = 'swirl_path';

%get number and list of subfolders
listing = dir(inputFolder);
[numFolders, ~] =  size(listing);
numFolders = numFolders - 2;

cellFolderStrings =  cell(numFolders,1);

for i = 3:numFolders + 2
   currentFolderStrings = listing(i).name;
   cellFolderStrings{i - 2,1} = currentFolderStrings;
end

%process all pulses
%-------------------------------------------------------------------------
for i = 1:numFolders
    %compose current folder string
    currentFolder = cellFolderStrings{i};
    
    if blnSubFolder == true   
        currentDir = strcat(inputFolder, '\',currentFolder, '\', strSubFolderName, '\');       
    else
        currentDir = strcat(inputFolder, '\',currentFolder);       
    end
    
    %get number and list of files
    listing = dir(currentDir);
    [numFiles, ~] =  size(listing);
    numFiles = numFiles - 3;

    cellFileStrings =  cell(numFiles,1);

    for x = 3 :numFiles + 2
       currentFileStrings = listing(x).name;
       cellFileStrings{x - 2,1} = currentFileStrings;
    end
    
    %process each signal
    for y = 1:numFiles
        currentPathName = strcat(currentDir, cellFileStrings{y});
        numSignal = (i-1)*(numFolders-3) + y;
        flowpoint = currentFolder(end-6:end);
        
        currentVelocityDir = strcat(currentDir, 'velocity.txt');
        
        velocity = fileread(currentVelocityDir);
        pos = strfind(velocity,'=');
        velocity = velocity(pos+2:end);

        %data variable population
        data.currentPathName = currentPathName;
        data.currentFileName = cellFileStrings{y};
        data.numSignal = numSignal;
        data.flowpoint = flowpoint;       
        data.outputFolder = outputFolder;
        data.velocity = velocity;
        
        [~] = Envelope_detection(data);
    end  
    
end

end

