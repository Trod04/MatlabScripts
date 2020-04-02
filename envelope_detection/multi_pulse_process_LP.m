function multi_pulse_process_LP()
%-------------------------------------------------------------------------
%Author: TROD
%Date modified: 10/02/2020
%
%Description:
%
%process ADC data from LPUSM
%-------------------------------------------------------------------------

%populate data variables
%-------------------------------------------------------------------------

strCsvLoc = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2020_02_10_LPUSM_envelope_pulse_processing\data\SIPAI_20100120\CPA1-FW76-C1-FL160_A';
pathLength = 0.065; %theoretical value path lenght for VoS recalculation

%find relevant csv files in csvloc dir

dirFiles = dir(strCsvLoc);
fileNames = {dirFiles.name};

[~,numfiles] = size(fileNames);

for i = 3:numfiles
    currentFilename = fileNames{i};
    [~,numchars] = size(currentFilename);
    
    if numchars > 10
        if strcmp(currentFilename(1:10), 'ADCCapture')
            strCsvFilenameADC = currentFilename;
        end
    end
    
    if numchars > 18
        if strcmp(currentFilename(1:18), 'MeasurementCapture')
            strCsvFilenameMeasurement = currentFilename;
        end
    end
end

%compose full csv pathnames
strFullPathADC = strcat(strCsvLoc, '\', strCsvFilenameADC);
strFullpathMeasurement = strcat(strCsvLoc, '\', strCsvFilenameMeasurement);


%parse ADC signals and collect velocity data
[PCDSignals, velocityData, numSamplesADC] = ADCParcer(strFullPathADC, strFullpathMeasurement);

%generate output folder strings, generate on first process
%-------------------------------------------------------------------------

strOutputGeneralDir = strcat(strCsvLoc , '\', 'processed');

if ~exist(strOutputGeneralDir, 'dir')
   mkdir(strOutputGeneralDir);
end

strOutputPathDir = cell(4,1);
strPathName = cell(4,1);
numloop = 0;

for i = 1:2    
    for y = 1:2
        numloop = numloop + 1;
        
        if y == 1
            strSide = 'A';
        else
            strSide = 'B';
        end
        
        strPN = strcat('Path', num2str(i), strSide);
        strPathName{numloop,1} = strPN;
        
        strPathOP =strcat(strOutputGeneralDir , '\', strPN);
        
        strOutputPathDir{numloop,1} = strPathOP;
    
        if ~exist(strPathOP, 'dir')
           mkdir(strPathOP);
        end
    end
end

%process all pulses
%-------------------------------------------------------------------------
boolSingle = 0;
boolDetectionMethod = 0; %0 = envelope/slope, 1 = signal/tail

if boolSingle == 0
    %create zeros transit time array
    TransitTimesVoS = zeros(numSamplesADC, 6);
    
    for i = 1:numSamplesADC
        for y = 1:4        
            %data variable population
            data.boolSingle = boolSingle;
            data.pathName = strPathName{y};
            data.numADC = i;
            data.outputFolder = strOutputPathDir{y};
            data.velocity = velocityData(i);

            data.signal = PCDSignals(y,:,i);
            
            if boolDetectionMethod == 0
                TransitTimesVoS(i,y) = Envelope_detection_LP(data);
            else
                TransitTimesVoS(i,y) = tailReference_LPUSM(data);
            end
            
            
            %print progress to console

            CP = '1122';
            tdside = 'ABAB';

            strPrint = strcat('Current Sample: ', num2str(i), ', Path', CP(y), tdside(y));    
            disp(strPrint)        
        end        

        %process transit times into VoS value for both paths
    
        for z = 1:2
            TTup = TransitTimesVoS(i, z*2-1);
            TTdwn = TransitTimesVoS(i, z*2);

            currentVos = (pathLength/2) * ((1/TTup)+(1/TTdwn));

            if z == 1
                TransitTimesVoS(i, 5) = currentVos;
            else
                TransitTimesVoS(i, 6) = currentVos;
            end
        end
    end
    
    plot_TT_VoS(TransitTimesVoS,strCsvLoc);
else
    i = 5;
    y = 4;
    
    data.boolSingle = boolSingle;
    data.pathName = strPathName{y};
    data.numADC = i;
    data.outputFolder = strOutputPathDir{y};
    data.velocity = velocityData(i);

    data.signal = PCDSignals(y,:,i);
    
    if boolDetectionMethod == 0
        TransitTime = Envelope_detection_LP(data);
    else
        TransitTime = tailReference_LPUSM(data);
    end
    
end


 


