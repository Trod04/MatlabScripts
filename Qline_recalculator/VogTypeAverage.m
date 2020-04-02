function [ VogRawType, UsedTypes ] = VogTypeAverage( VogRaw )

%Recalculate the Raw Vog averages based on the Metertype

%get path type configuration 
MeterConfig = MeterParameterConfigQ();
Data = MeterTypeData( MeterConfig.MeterType );
UsedTypes = Data.UsedTypes;

%calculate averages
%------------------

VogRawType(1:4)= 0;

for i = 1: 4
    
    %exclude unused path types for metertype
    
    if UsedTypes(i)
        
        [~,numPathsType]  =size(Data.Type(i).vals);
        CurrentTypeVals = Data.Type(i).vals;

        total = 0;

        for y = 1 : numPathsType
            total = total + VogRaw(CurrentTypeVals(y));
        end

        AV = total/numPathsType;

        VogRawType(i)= AV;
        
    end
end


end

