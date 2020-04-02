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
            
            pathType(1) = 2;
            pathType(2) = 4;
            pathType(3) = 4;
            pathType(4) = 1;
            pathType(5) = 1;
            pathType(6) = 4;
            pathType(7) = 4;
            pathType(8) = 2;
        end
end

%ouput parameters
Pinfo.PL = pathLength;
Pinfo.Angle = pathAngle;
Pinfo.PathType = pathType;

end

