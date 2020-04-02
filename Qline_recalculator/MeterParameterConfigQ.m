function [ MeterConfig ] = MeterParameterConfigQ()

%Info
%----

MeterConfig.Size = 12;
MeterConfig.MeterType = 49;
MeterConfig.ParInfo = 'TCC 5D - CPA - 5D parameter config';


%PathLenghts, angles & ID
%----------------
MeterConfig.ID = 0.2889;

MeterConfig.PL(1) = 0.8480;
MeterConfig.PL(2) = 0.6020;
MeterConfig.PL(3) = 0.6022;
MeterConfig.PL(4) = 0.8473;
MeterConfig.PL(5) = 0;
MeterConfig.PL(6) = 0;
MeterConfig.PL(7) = 0;
MeterConfig.PL(8) = 0;

MeterConfig.Angle(1) = 62.01;
MeterConfig.Angle(2) = 70.05;
MeterConfig.Angle(3) = 70.16;
MeterConfig.Angle(4) = 61.97;
MeterConfig.Angle(5) = 0;
MeterConfig.Angle(6) = 0;
MeterConfig.Angle(7) = 0;
MeterConfig.Angle(8) = 0;

%Dens/Visc
%-------------
MeterConfig.Density = 1.8;
MeterConfig.Visc = 0.0000130;

%Reynolds Pars
%-------------

%Type A
MeterConfig.ReynoldsType(1).Par(1) = 3792;
MeterConfig.ReynoldsType(1).Par(2) = 26;
MeterConfig.ReynoldsType(1).Par(3) = 0.7502;
MeterConfig.ReynoldsType(1).Par(4) = 0.9711;
MeterConfig.ReynoldsType(1).Par(5) = 0.0231;
MeterConfig.ReynoldsType(1).Par(6) = -3.3190;


%Type B
MeterConfig.ReynoldsType(2).Par(1) = 3401;
MeterConfig.ReynoldsType(2).Par(2) = 66;
MeterConfig.ReynoldsType(2).Par(3) = 1.0037;
MeterConfig.ReynoldsType(2).Par(4) = 1.0093;
MeterConfig.ReynoldsType(2).Par(5) = 0.0175;
MeterConfig.ReynoldsType(2).Par(6) = -3.2090;

%Type C
MeterConfig.ReynoldsType(3).Par(1) = 1;
MeterConfig.ReynoldsType(3).Par(2) = 1;
MeterConfig.ReynoldsType(3).Par(3) = 1;
MeterConfig.ReynoldsType(3).Par(4) = 1;
MeterConfig.ReynoldsType(3).Par(5) = 0;
MeterConfig.ReynoldsType(3).Par(6) = 0;

%Type D
MeterConfig.ReynoldsType(4).Par(1) = 1;
MeterConfig.ReynoldsType(4).Par(2) = 1;
MeterConfig.ReynoldsType(4).Par(3) = 1;
MeterConfig.ReynoldsType(4).Par(4) = 1;
MeterConfig.ReynoldsType(4).Par(5) = 0;
MeterConfig.ReynoldsType(4).Par(6) = 0;

%Pathtype weight
%---------------

MeterConfig.WeightType(1) = 0.159;
MeterConfig.WeightType(2) = 0.8410;
MeterConfig.WeightType(3) = 0;
MeterConfig.WeightType(4) = 0;

end

