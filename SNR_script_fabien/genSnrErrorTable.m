function [ snrErrorTable ] = genSnrErrorTable(numPaths, numCSV, snrDataPath)
%generate error code table for detailed SNR results Fabien.

%   - code: noise type code =  0 => no noise
%                           =  1 => low ringing
%                           =  2 => medium white noise
%                           =  3 => medium ringing
%                           =  4 => medium white noise and ringing
%                           =  5 => high white noise
%                           =  6 => high ringing
%                           =  7 => high white noise and ringing
%                           =  8 => white noise detected (shall not happen)
%                           =  9 => one low SNR detected (shall not happen)
%                           = 10 => two low SNR detected (shall not happen)
%                           = -1 => not discriminated (shall not happen)

%initialize return par
snrErrorTable(numPaths,2) = 0;

for x = 1:numPaths
   for y = 1:2
       %   make/clear binairy results for all possible states for current
       %   path
       binResults= [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
       currentTD = struct2cell(snrDataPath.path(x).side(y).SnrDetails)';
       for z = 1 : numCSV           
           switch currentTD{z,1}
              case 1
                   binResults(1) = 1;
              case 2
                   binResults(2) = 1;
              case 3
                   binResults(3) = 1;
              case 4
                   binResults(4) = 1;
              case 5
                   binResults(5) = 1;
              case 6
                   binResults(6) = 1;
              case 7
                   binResults(7) = 1;
              case 8
                   binResults(8) = 1;
              case 9
                   binResults(9) = 1;
              case 10
                   binResults(10) = 1;
              case -1
                   binResults(11) = 1;
           end       
       end
       
       snrErrorTable(x,y) = bin2dec(binResults);
   end
end


end

