function [ validType, numPaths, meterType, pathConfig, PathCT ] = MPCmeterTypeID(fidLog, CT)

%initialise return parameters
validType = 0;
numPaths = 0;
meterType = 0;
pathConfig = 0;
PathCT = 0;

try
    %get typenumber from CT.INFO
    typeNum = cell2mat(CT.INFO(1,4));

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
            meterType = 'Checksonic';
            pathConfig = CheckSonic;
            [ validCT, PathCT ] = MeterPathCT( fidLog, CT, pathConfig );
            numPaths = 1;
            if validCT
                validType = 1;
            end
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype was identified');
        case 62
            meterType = 'CheckSonic2';
            pathConfig = CheckSonic2;
            [ validCT, PathCT ] = MeterPathCT( fidLog, CT, pathConfig );
            numPaths = 2;
            if validCT
                validType = 1;
            end
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype was identified');
        case 63
            meterType = 'Qsonic3SVI';
            pathConfig = Qsonic3SVI;  
            [ validCT, PathCT ] = MeterPathCT( fidLog, CT, pathConfig );
            numPaths = 3;
            if validCT
                validType = 1;
            end
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype was identified');
        case 64
            meterType = 'QsonicAtom';
            pathConfig = QsonicAtom;
            [ validCT, PathCT ] = MeterPathCT( fidLog, CT, pathConfig );
            numPaths = 4;
            if validCT
                validType = 1;
            end
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype was identified');
        case 65
            meterType = 'Qsonic5SVI';
            pathConfig = Qsonic5SVI;
            [ validCT, PathCT ] = MeterPathCT( fidLog, CT, pathConfig );
            numPaths = 5;
            if validCT
                validType = 1;
            end
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype was identified');
        case 66
            meterType = 'QsonicPlus';
            pathConfig = QsonicPlus;
            [ validCT, PathCT ] = MeterPathCT( fidLog, CT, pathConfig );
            numPaths = 6;
            if validCT
                validType = 1;
            end
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype was identified');
        case 68
            meterType = 'QsonicMax';
            pathConfig = QsonicMax;
            [ validCT, PathCT ] = MeterPathCT( fidLog, CT, pathConfig );
            numPaths = 8;
            if validCT
                validType = 1;
            end
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype was identified');
        case 70
            meterType = 'ChecksonicVX6';
            pathConfig = ChecksonicVX6;
            [ validCT, PathCT ] = MeterPathCT( fidLog, CT, pathConfig );
            numPaths = 6;
            if validCT
                validType = 1;
            end
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype was identified');
        case 71
            meterType = 'ChecksonicVX3';
            pathConfig = ChecksonicVX3;
            [ validCT, PathCT ] = MeterPathCT( fidLog, CT, pathConfig );
            numPaths = 3;
            if validCT
                validType = 1;
            end
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype was identified');
        case 0
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype is not indentified in CRITERIA file');
        otherwise
            %write event to logfile
            WriteToLogFile(fidLog,'Metertype is not known to matlab');
    end
catch err
    %write event to logfile
    WriteToLogFile(fidLog,'Error in identifing metertype');
    WriteToLogFile(fidLog,err.message) ;
end      

end