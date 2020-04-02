function [ validCT, PathCT ] = MeterPathCT( fidLog, CT, PathConfig )
%this function determines the specific path criteria based on metertype and
%the original criteriafile

%initialize return parameters
PathCT = 0;
validCT = 0;

try
    %get raw criteria, specific pathtypes & inversion (1= positive, 0 =
    %negative)

    Criteria = CT.PATH;
    Inversion = CT.DETECTION;
    meterPathtypes = PathConfig(3,:);

    %determine number of paths
    [~,numPaths] = size(PathConfig);

    %determine number of criteria
    [~,numCT] = size(CT.PATH);

    %Pathtypes available
    Type = {'AX', 'SW', 'D1', 'D2'};
    
    %make temporary array for generating CTs
    genCrit(numPaths, numCT)=0;

    %generate CTs for each individual path based on the meterType
    for i = 1:numPaths
        switch meterPathtypes{1,i}
                case Type{1,1}
                    if Inversion(1,i)
                        genCrit(i,:) = Criteria(1,:);
                    else
                        genCrit(i,:) = Criteria(2,:);
                    end
                case Type{1,2}
                    if Inversion(1,i)
                        genCrit(i,:) = Criteria(3,:);
                    else
                        genCrit(i,:) = Criteria(4,:);
                    end
                case Type{1,3}
                    if Inversion(1,i)
                        genCrit(i,:) = Criteria(5,:);
                    else
                        genCrit(i,:) = Criteria(6,:);
                    end
                case Type{1,4}
                    if Inversion(1,i)
                        genCrit(i,:) = Criteria(7,:);
                    else
                        genCrit(i,:) = Criteria(8,:);
                    end
        end

    end

    PathCT = genCrit;
    
    %set valid control bit
    validCT = 1;
    
    %write event to logfile
    WriteToLogFile(fidLog,'Path CTs were succesfully generated');

catch err
    %write event to logfile
    WriteToLogFile(fidLog,'Error in generating Path CTs');
    WriteToLogFile(fidLog,err.message) ;
end      



end

