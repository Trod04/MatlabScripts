function [ validUDATA ] = checkUDATA( fidLog, CTINFO  )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
CTINFO = CTINFO;
validUDATA = 0;

try
    if CTINFO{1,5} == 39
        WriteToLogFile(fidLog,'U_DATA extended Format is used');
        validUDATA = 1;
    else
        WriteToLogFile(fidLog,'Wrong U_DATA format was used');
    end
catch err
    WriteToLogFile(fidLog,'Error in identifying U_DATA type');
    WriteToLogFile(fidLog, err.message);
end
    

end

