function [ dataPosLog ] = dataPosSE(MeterConfig)
%Sonic log data positions

numPaths = MeterConfig.numPaths;
meterType = MeterConfig.meterType;

if meterType == 74
    numPaths = 8;
end

dataPosLog.sampleRate = 1;
dataPosLog.validSamples = 2;
dataPosLog.AGC = 2 + (1 * numPaths);
dataPosLog.SNR = 2 + (3 * numPaths);
dataPosLog.measVos = 2 + (5 * numPaths);
dataPosLog.measVline = 3 + (5 * numPaths);
dataPosLog.Qline = 6 + (5 * numPaths);
dataPosLog.vosPath = 9 + (5 * numPaths);
dataPosLog.vogPath = 9 + (6 * numPaths);
dataPosLog.measVline = 3 + (5 * numPaths);

end

