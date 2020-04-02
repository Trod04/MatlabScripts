function [validCT, CT] = OpenCriteriaFile(MeterDir,fidLog)
% open the logfile related to the analysis of the Logfile 
fidLog = fidLog;
validCT = 0;
try
    %open Criteria file
    fullPathCrit = strcat(MeterDir, '\CRITERIA.TXT');
    fidCF = fopen(fullPathCrit);
    if fidCF > -1
        %get number of lines
        data = fread(fidCF); 
        frewind(fidCF);
        numLines = sum(data == 10);

        %get number of columns 
        line = fgetl(fidCF);
        frewind(fidCF);
        [~,numSemiCol] = size(strfind(line, ';'));
        numColumns = numSemiCol +1;

        %make array with all lines
        line = cell(numLines, 1);
        for i = 1:numLines
            line(i,1)= cellstr(fgetl(fidCF));
        end

        %get positions of semicolons in lines
        semiPos = cell(numLines,numColumns);
        linePos = 0;
        lastPos = 0;
        for k = 1:numLines
           linePos = strfind(char(cell2mat(line(k,1))), ';');
           for l = 1:numColumns
               if l == numColumns
                   [~,lastPos] = size(cell2mat(line(k,1)));
                   semiPos{k,l}= lastPos + 1;
               else
                   semiPos{k,l}=linePos(l);
               end
           end
        end
        semiPos = cell2mat(semiPos);

        %get criteria out of csv
        rawCriteria = cell(numLines,numColumns);
        currentline = '';
        CTstart = 0;
        CTend = 0;
        for m = 1:numLines
            currentline = char(cellstr(line(m,1)));
            firstcolumn=0;
            for n = 1:numColumns
                if firstcolumn >0
                CTstart = semiPos(m,n-1) + 1;
                end
                CTend = semiPos(m,n) -1;
                if firstcolumn == 0
                    rawCriteria{m,1}= char(currentline(1:CTend));
                    firstcolumn = 1;
                else
                   if isempty(sscanf(currentline(CTstart:CTend),'%f', 1))
                        rawCriteria{m,n}= char(currentline(CTstart:CTend));
                   else
                        rawCriteria{m,n}= sscanf(currentline(CTstart:CTend),'%f', 1);
                   end
                end
            end
        
        end

        %make structure with different CT
        CTnames = rawCriteria(:,1);
        CTvals = rawCriteria(:,2:end);

        for o = 1:numLines
            CT.(CTnames{o})= cell(1,numColumns - 1);
        end

        for p = 1: numLines
            for q = 1: numColumns -1
                CT.(CTnames{p}){1,q}= CTvals{p,q};
            end
        end

        for q = 2: numLines
            CT.(CTnames{q})= cell2mat(CT.(CTnames{q}));
        end

        %close Criteria file
        fclose(fidCF);
        
        %write event to logfile
        WriteToLogFile(fidLog,'CRITERIA.TXT for logfile loaded');
        
        %Read Criteria file is valid
        validCT = 1;
    else
        %initialize return parameter
        CT= 0;
        %write event to logfile
        WriteToLogFile(fidLog,'Error opening CRITERIA.TXT');
    end
catch err
    %initialize return parameter
    CT= 0;
    WriteToLogFile(fidLog,'Could not load CRITERIA.TXT for logfile');
    WriteToLogFile(fidLog,err.message) ;
end
    
    

end
