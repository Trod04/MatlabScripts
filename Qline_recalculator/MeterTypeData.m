function [ Data ] = MeterTypeData( MeterType )

%provide data regarding to the Metertype

%initialize return par


switch MeterType
    case 66
        %path type numbers
        Data.Type(1).vals = [3,4];
        Data.Type(2).vals = [1,2,5,6];
        Data.Type(3).vals = [];
        Data.Type(4).vals = [];
        
        Data.UsedTypes = [1,1,0,0];
        
    case 68
        %path type numbers
        Data.Type(1).vals = [4,5];
        Data.Type(2).vals = [1,8];
        Data.Type(3).vals = [];
        Data.Type(4).vals = [2,3,6,7];
        
        Data.UsedTypes = [1,1,0,1];
        
    case 74
        %path type numbers
        Data.Type(1).vals = [3,4];
        Data.Type(2).vals = [];
        Data.Type(3).vals = [];
        Data.Type(4).vals = [1,2,5,6];
        
        Data.UsedTypes = [1,0,0,1];
        
     case 49
        %path type numbers
        Data.Type(1).vals = [2,3];
        Data.Type(2).vals = [1,4];
        Data.Type(3).vals = [];
        Data.Type(4).vals = [];
        
        Data.UsedTypes = [1,1,0,0];
end


end

