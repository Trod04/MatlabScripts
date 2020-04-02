function FlowSimDataGenerator()

%data values
datalines = 100;
numPaths = 8;

boolUdata = 0;

Samplerate = 19;

Samplerate_path = [19, 19, 19, 19, 19, 19, 19, 19];

VoS_Path = [350, 350, 350, 350, 350, 350, 350, 350];

Gain_AGC_A = [4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000];

Gain_AGC_B = [4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000];

Gain_SNR_A = [4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000];

Gain_SNR_B = [4000, 4000, 4000, 4000, 4000, 4000, 4000, 4000];

Pathlength = [0.55806, 0.17541, 0.17541, 0.24803,0.24803, 0.17541, 0.17541, 0.55806];

Pathangle = [62.2, 50, 50, 50, 50, 50, 50, 62.2];

if boolUdata == 1
    strPath = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_08_27_DNVGL_15bar_PD_24ms_generated_flowsim\';
    strFile = 'cas6_24mps_15bar_PD_dataset.csv';
    
    strFullPath = strcat(strPath,strFile);

    SonicData = csvread(strFullPath,1,1);   
    
    rawVogVals = SonicData(:,57:62);
    [datalines, ~] = size(rawVogVals);
    
end

%generate first line
for y = 1:datalines
    
    %reset line data for each itteration
    line_data = [];
    
    %use fixed value for each line or use from udata log
    if boolUdata == 1
        currentVogVals = rawVogVals(y,:);
        Avg_VoG = mean(currentVogVals(:)); 
        
        %VoG_Path = [Avg_VoG, currentVogVals, Avg_VoG]; %for qmax or 6d+2
        
        VoG_Path = currentVogVals; %for 6D
        
    else
        VoG_Path = [10, 10,  10, 10,  10,  10,  10,	10 ];
        Avg_VoG = mean(VoG_Path(1:numPaths)); 
    end
    
    
    for i = 1:numPaths

        VoG = VoG_Path(i); %value velocity of gas path, unit m/s          
        PL = Pathlength(i); %value pathlenght in unit m, unit m
        angle = Pathangle(i); %value path angle, unit degrees

        %compensate vos with Mach correction    
        VoS_Raw = VoS_Path(i); % value velocity of sound path, unit m
        Mach_corr = 1 + 0.5*((Avg_VoG*sind(angle))/VoS_Raw)^2;
        VoS = VoS_Raw/Mach_corr;

        %calculate transit times: x = 1/TT_ab, y = 1/TT_ba --> insert into vog
        %and vos formula from measapll calculations document
        %---------------------------------------------------------------------

        F1 = (2*VoS)/PL; %known variables VoS formula reworked into single factor
        F2 = (2*cosd(angle)*VoG)/PL; %known variables VoG formula reworked into single factor

        x = (F1+F2)/2;
        y = x - F2;

        %revert back to normal transit times
        TT_AB = 1/x; 
        TT_BA = 1/y;

        %randominze gain values to avoid DSP flowboard error

        Gain_RDM_SNR_A = Gain_SNR_A(i) + randi([-50 50],1,1);
        Gain_RDM_AGC_A = Gain_AGC_A(i) + randi([-50 50],1,1);
        Gain_RDM_SNR_B = Gain_SNR_B(i) + randi([-50 50],1,1);
        Gain_RDM_AGC_B = Gain_AGC_B(i) + randi([-50 50],1,1);


        path(i).data = [Samplerate, Samplerate_path(i), Gain_RDM_SNR_A, Gain_RDM_AGC_A, TT_AB, 0, 0, Gain_RDM_SNR_B, Gain_RDM_AGC_B, TT_BA, 0, 0 ];

        if exist('line_data','var')        
            line_data = [line_data, path(i).data];
        else
            line_data = path(i).data;
        end

    end

    if exist('flowsimdata','var')        
        flowsimdata = [flowsimdata; line_data];
    else
        flowsimdata = line_data;
    end
end


%create flowsimdatafile
pathname = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\flowsimgenerator\generated_flowsim\flowsimdata.txt';

flowsimdata = num2cell(flowsimdata);

cell2csvFS(pathname,flowsimdata,'\t');


end

