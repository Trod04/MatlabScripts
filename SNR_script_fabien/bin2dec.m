function [ errorcode ] = bin2dec(binResults)
%convert binresults to binairy number

%initialize return parameter
errorcode = 0;

%generate decimal code array
codeArray = [1,2,4,8,16,32,64,128,256,256,512];

for i = 1: 11
    if binResults(i)
        errorcode = errorcode + codeArray(i);
    end
end


