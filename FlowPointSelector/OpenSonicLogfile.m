function [ handles ] = OpenSonicLogfile( handles )

%Function description
%--------------------------------------------------------------------------
% Owner:     TROD
% Date modified:    27-07-2018
% General discription:  opens prompt to user and asks user to select a sonic
% logfile. If a file is selected the data is loaded into an array.
%--------------------------------------------------------------------------

%initialize return parameters
filename = 0;
pathname = 0;
csvData = 0;


try
    %check if the user has opened files before
%     if handles.pathname == 0
%         [filename, pathname] = uigetfile({'*.csv'},'File Selector');
%     else
%         path = [handles.pathname, '*.csv'];
%         [filename, pathname] = uigetfile({path},'File Selector');
%     end

    %test parameters

    pathname = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\FlowPointSelector\data'; %use for testing
    filename = 'BeforeCal_69512333_7-25-2018_2_22_44_PM.csv'; %use for testing

    %if the user has selected a file set the pathnames and update the
    %textFileLocation in the gui
    if filename ~= 0
        handles.pathname = pathname;
        handles.filename = filename;

        fullPathName = strcat(pathname, '\', filename);

        set(handles.textFileLocation, 'String', fullPathName);
    end

    %if the user selected a file, the csv data is loaded into an array,
    %stripping away the first row and columb which contains string data.
    if filename ~= 0
       csvData = csvread(fullPathName,1,1);       
    end
    
    

    %load obtained data into the handles variable
    if filename ~= 0
       handles.filename = filename;
       handles.pathname = pathname; 
       handles.csvData = csvData;
    end
    
    %write to logfile

    WriteToLogFile(handles.fidLog,'Sonic logfile succesfully opened');
    
catch err 
    
    WriteToLogFile(handles.fidLog,'Error in opening Sonic logfile');
    WriteToLogFile(handles.fidLog,err.message);    
    
end



end

