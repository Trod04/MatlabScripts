function [ validType, numPaths, meterType, pathConfig, posCSV ] = meterTypeID(fidLog, CTINFO, writeToLogfile)

%initialise return parameters
validType = 0;
numPaths = 0;
meterType = 0;
pathConfig = 0;
posCSV = 0;
CTINFO = CTINFO;

try
    %get typenumber from CT.INFO
    typeNum = cell2mat(CTINFO(1,4));

    CheckSonic = { 1 ; 'A1' ; 'AX' };
    CheckSonic2 = { 1, 2 ; 'A1', 'A2' ; 'AX', 'AX' };
    Qsonic3SVI = { 1, 2, 3 ; 'A1', 'B1-CW', 'B2-CCW' ; 'AX', 'SW', 'SW'};
    QsonicAtom = { 1, 2, 3, 4 ; 'B1-CW', 'A1', 'A2', 'B2-CCW' ;  'SW', 'AX', 'AX', 'SW'};
    Qsonic5SVI = { 1, 2, 3, 4, 5; 'B1-CW', 'A1', 'B1-CCW', 'A2', 'A3'; 'SW', 'AX', 'SW', 'AX', 'AX'};
    QsonicPlus = { 1, 2, 3, 4, 5, 6; 'B1-CW', 'B1-CCW', 'A1', 'A2', 'B2-CW', 'B2-CCW'; 'SW', 'SW','AX','AX','SW', 'SW'};
    QsonicMax = { 1, 2, 3, 4, 5, 6, 7, 8; 'B1CW', 'D-RT', 'D-LT', 'D-C1', 'D-C2', 'D-RB', 'D-LB', 'B1-CCW'; 'SW', 'D1', 'D1', 'D2', 'D2', 'D1', 'D1', 'SW'};
    ChecksonicVX6 = { 1, 2, 3, 4, 5, 6; 'D-RT', 'D-LT', 'A1', 'A2', 'D-RB', 'D-LB'; 'D1', 'D1','AX','AX','D1', 'D1'};
    ChecksonicVX3 = { 1, 2, 3; 'D-T', 'A1', 'D-B'; 'D1', 'AX', 'D1' };
    

    switch typeNum
        case 61
            validType = 1;
            meterType = 'Checksonic';
            pathConfig = CheckSonic;
            posCSV = checkCSV(1);
            numPaths = 1;
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype was identified');
            end
        case 62
            validType = 1;
            meterType = 'CheckSonic2';
            pathConfig = CheckSonic2;
            posCSV = checkCSV(2);
            numPaths = 2;
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype was identified');
            end
        case 63
            validType = 1;
            meterType = 'Qsonic3SVI';
            pathConfig = Qsonic3SVI;
            posCSV = checkCSV(3);
            numPaths = 3;
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype was identified');
            end
        case 64
            validType = 1;
            meterType = 'QsonicAtom';
            pathConfig = QsonicAtom;
            posCSV = checkCSV(4);
            numPaths = 4;
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype was identified');
            end
        case 65
            validType = 1;
            meterType = 'Qsonic5SVI';
            pathConfig = Qsonic5SVI;
            posCSV = checkCSV(5);
            numPaths = 5;
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype was identified');
            end
        case 66
            validType = 1;
            meterType = 'QsonicPlus';
            pathConfig = QsonicPlus;
            posCSV = checkCSV(6);
            numPaths = 6;
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype was identified');
            end
        case 68
            validType = 1;
            meterType = 'QsonicMax';
            pathConfig = QsonicMax;
            posCSV = checkCSV(8);
            numPaths = 8;
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype was identified');
            end
        case 70
            validType = 1;
            meterType = 'ChecksonicVX6';
            pathConfig = ChecksonicVX6;
            posCSV = checkCSV(6);
            numPaths = 6;
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype was identified');
            end
        case 71
            validType = 1;
            meterType = 'ChecksonicVX3';
            pathConfig = ChecksonicVX3;
            posCSV = checkCSV(3);
            numPaths = 3;
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype was identified');
            end
        case 0
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype is not indentified in CRITERIA file');
            end
        otherwise
            %write event to logfile
            if writeToLogfile == 1
                WriteToLogFile(fidLog,'Metertype is not known to matlab');
            end
    end
catch err
    %write event to logfile
    if writeToLogfile == 1
        WriteToLogFile(fidLog,'Error in identifing metertype');
        WriteToLogFile(fidLog,err.message) ;
    end
end      

end