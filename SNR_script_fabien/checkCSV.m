function [ CSVPOS ] = checkCSV( numPaths )
%Determen the start column for each variable in the CSV, based on the number of paths.
nPaths = numPaths;

CSVPOS.SampleRate= 2;
CSVPOS.ValidSamples=3;
CSVPOS.AGC= 3 + nPaths;
CSVPOS.SNR= 3 + 3*nPaths;
CSVPOS.VoS= 3 + 5*nPaths;
CSVPOS.VoG= 4 + 5*nPaths;
CSVPOS.VoSpp= 10 + 5*nPaths;
CSVPOS.VoGpp= 10 + 6*nPaths;
CSVPOS.MeterType = 10 + 7*nPaths;
CSVPOS.TempFAT= 17 + 8*nPaths;
CSVPOS.PresFAT= 18 + 8*nPaths;
CSVPOS.VoSFAT= 19 + 8*nPaths;


end

