 function [ VersionNumber ] = GetVersionNumber()
% version number control

VersionNumber = 'v 0.0.3.0';

%V 0.0.3.0 201/09/01
%Final merge of matlab Analyse Data & MPC with pictures & different
%metertype support.

% V 0.0.2.0 FHUI 2014/01/28
% First new revision matlabcode TROD


% V 0.0.1.8 FHUI 2013/06/27
% Starting point for TROD
% still nice to have:
% a) FAT revision number presented in Criteria.txt
% should be displayed in the title of the figures generated
% FAT rev number is currently imported as a number not as a string
% beware when converting the items in CRITERIA.txt, most of the 
% data should be imported as numbers not as strings!

% V 0.0.1.7 FHUI 2013/06/27, in use since 2013/06/27 16h00
% Last compilation on laptop CVHO using matlab 2013a and trial version of 
% VS 2010 professional compiler.
% Also compiled on laptop TROD using matlab 2013a and SDK compiler, seems
% to generate proper code that runs, checked on NTB test system.
% issues solved:
% a) calculate and write the  min and max of all the pulse ratio's for each
% transducer to the logfile (not the results file!), this makes the 
% determination of the criteria much easier
% b) bug solved in testing of VGAS of logfile: too much ; were printed
% in the output results of VMETER
% still nice to have:
% a) FAT revision number presented in Criteria.txt
% should be displayed in the title of the figures generated

% V 0.0.1.5 FHUI 2013/06/26, in use since 2013/06/26 17h00 
% a) Small bug solved when determining the color of the 
% errorbars in the plots of the ratio's in the pulseshapes
% b) more comments added to facilitate support
% c) bug solved in return data from AGCR test: the complete ratio
% vector was returned instead of a single number
% d) more checkes added in analysis of acoustic signals, tool now plots
% the acoustic signals even for non working meters or empty or
% corrupted pulses

% V 0.0.1.4 FHUI 2013/06/04
% Meter serial number and FAT revision now extracted
% from filename of LOG- or MPC-file, comparison made
% with serial number in CRITERIA file, serial number
% from filename has higher priority

% V 0.0.1.3 FHUI 2013/04/10
% multiple input arguments removed
% extra function added VarTest(varargin) to
% support variable list of input arguments
% check on offset of meter added, extra par in criteria file

% V 0.0.1.2 FHUI 2013/04/10
% multiple input arguments in AnalyseLogFile
% do not use this version in production
% just for testing
% check on offset of meter added, extra par in criteria file

% V 0.0.1.1 FHUI 2013/04/09
% low pass filtering and flag added to prevent plotting
% plotting not allowed on server!

% V 0.0.1.0 FHUI 2013/04/08
% minor bug in CheckDVOSI solved

% V 0.0.0.9 FHUI 2013/04/03
% errorbars in green or red to indicatie ok or failiure

% V 0.0.0.8 FHUI 2013/04/03
% Meter serial number and size added to MPC analysis
% in path 0 parameter

% V 0.0.0.7 FHUI 2013/04/03
% errorbars added to analysis of pulse plot
% output format analysis MPC files rearranged

% V 0.0.0.6 FHUI 2013/04/03
% calculation of SNRatio now based on max of first wavelet
% instead of max of complete signal
% trying to solve issues with differences in filesystem

% V 0.0.0.5 FHUI 2013/04/02
% with full check on logfile and
% first version with check on pulsshape
% logfile now created in requested dir
% all calls to msgBox removed

% V 0.0.0.4 FHUI 2013/03/29
% with full check on logfile and
% first version with check on pulsshape
% logfile now created in requested dir

% V 0.0.0.3 FHUI 2013/03/28
% first trials with check on logfile 
% first version with check on pulsshape

% V 0.0.0.2 FHUI 2013/03/28
% versopm with check on logfile 
% all checks on logfile implemented

% V 0.0.0.1 FHUI 2013/03/28
% first trials with check on logfile 
% only check on VGAS

end