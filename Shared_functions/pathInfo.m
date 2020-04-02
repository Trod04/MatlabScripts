function [ Pinfo ] = pathInfo(meterSize, meterType)
%return pathlengths base on metersize and metertype
%populated base on need. 
%
%If return parameter = 99999999 --> PL's not defined yet

%initialize return parameters
pathLength = 99999999;
pathAngle  = 99999999;

%populate pathlengths

switch meterSize
    case 8
        if meterType == 68
            pathLength(1) = 0.55806;
            pathLength(2) = 0.17541;
            pathLength(3) = 0.17541;
            pathLength(4) = 0.24803;
            pathLength(5) = 0.24803;
            pathLength(6) = 0.17541;
            pathLength(7) = 0.17541;
            pathLength(8) = 0.55806;
            
            pathAngle(1) = 62.2;
            pathAngle(2) = 50;
            pathAngle(3) = 50;
            pathAngle(4) = 50;
            pathAngle(5) = 50;
            pathAngle(6) = 50;
            pathAngle(7) = 50;
            pathAngle(8) = 62.2;
        end
        if meterType == 74            
            pathLength(1) = 0.17541;
            pathLength(2) = 0.17541;
            pathLength(3) = 0.24803;
            pathLength(4) = 0.24803;
            pathLength(5) = 0.17541;
            pathLength(6) = 0.17541;
            pathLength(7) = 0.55806;
            pathLength(8) = 0.55806;
            
            pathAngle(1) = 50;
            pathAngle(2) = 50;
            pathAngle(3) = 50;
            pathAngle(4) = 50;
            pathAngle(5) = 50;
            pathAngle(6) = 50;
            pathAngle(7) = 62.2;
            pathAngle(8) = 62.2;
        end
end

%path type pairing logic and numPaths

switch meterType
    case 68
        Ptype(1).vals = [4,5];
        Ptype(2).vals = [1,8];
        Ptype(3).vals = [];
        Ptype(4).vals = [2,3,6,7];

        PtypeUsed = [1,1,0,1];
        
        numPaths = 8;
    case 74
        Ptype(1).vals = [3,4];
        Ptype(2).vals = [7,8];
        Ptype(3).vals = [];
        Ptype(4).vals = [1,2,5,6];

        PtypeUsed = [1,0,0,1];
        
        numPaths = 6;
end

%ouput parameters
Pinfo.PL = pathLength;
Pinfo.angle = pathAngle;
Pinfo.numPaths = numPaths;
Pinfo.Ptype = Ptype;
Pinfo.PtypeUsed = PtypeUsed;


end

