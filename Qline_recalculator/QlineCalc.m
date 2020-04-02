function [ Qline, QlineLogCalcDiff ] = QlineCalc(VogRaw)

%Recalculate RAW VoG values to Qline

%testdata: TCC class 0.5 Type Test - baseline 5D - CPA - 5D
%VogRaw = [-0.00206525  0.00192282 -0.0006172  -0.02596988  0.00144805  0.00439162 ];
logQline =  -0.587043039;

VogRaw = [-0.001 0.002 -0.002 -0.012 ];
% logQline = 891.780579

%data
MeterConfig = MeterParameterConfigQ();

%calculate average Vog values per type
[ VogRawType, UsedTypes ] = VogTypeAverage(VogRaw);

%apply Reynolds corrections on path types

for i = 1:4  
    if UsedTypes(i)
        Rfactor = ReynoldsCalc(VogRawType(i), i);        
        CorrectedVogType(i) = VogRawType(i) * Rfactor;
    end
end

%apply weighing factors on corrected vog values to find Vline

pathTypeWeight(1:4) = MeterConfig.WeightType(:);
Vline = 0;

for i = 1:4    
    if UsedTypes(i)
        Vline = Vline + (CorrectedVogType(i)* pathTypeWeight(i));
    end
end

%calculate Qline

surface = (MeterConfig.ID/2)^2 * pi;
Qline = surface * Vline * 3600;

QlineLogCalcDiff = (Qline-logQline)/logQline *100;

end

