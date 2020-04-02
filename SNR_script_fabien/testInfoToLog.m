function testInfoToLog(fidLog, TestName, headerType)
%write header with testname to logfile

%headertype switches between linestyle
%
%headertype 1 = maintest
%headertype 2 = subtest

switch headerType
    case 1
        WriteToLogFile(fidLog,'o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o');
        WriteToLogFile(fidLog,strcat('Starting test: ', TestName));
        WriteToLogFile(fidLog,'o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o-o');
    case 2
        WriteToLogFile(fidLog,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        WriteToLogFile(fidLog,strcat('Starting subtest: ', TestName));
        WriteToLogFile(fidLog,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');    
    otherwise
        WriteToLogFile(fidLog,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
        WriteToLogFile(fidLog,strcat('Starting test: ', TestName));
        WriteToLogFile(fidLog,'~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');   
end
    
end

