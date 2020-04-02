function [ Qline, QlineLogCalcDiff ] = QlineCalc()

%Recalculate RAW VoG values to Qline

%testdata: TCC class 0.5 Type Test - baseline 5D - CPA - 5D, log line 3250
% VogRaw = [0.476196,	0.461571,	0.478757,	0.528869,	0.532454,	0.341217,	0.361015,	0.474855 ];
% logQline = 47.887596;

VogRaw = [8.706397,	7.989939,	8.116369,	8.917305,	8.977791,	8.09961,	8.262599,	8.671127 ];
logQline = 891.780579;

%data
MeterConfig = MeterParameterConfig();

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

