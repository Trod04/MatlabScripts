function varargout = AnalyseMPC(varargin)
% ANALYSEMPC MATLAB code for AnalyseMPC.fig
%      ANALYSEMPC, by itself, creates a new ANALYSEMPC or raises the existing
%      singleton*.
%
%      H = ANALYSEMPC returns the handle to a new ANALYSEMPC or the handle to
%      the existing singleton*.
%
%      ANALYSEMPC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSEMPC.M with the given input arguments.
%
%      ANALYSEMPC('Property','Value',...) creates a new ANALYSEMPC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalyseMPC_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalyseMPC_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalyseMPC

% Last Modified by GUIDE v2.5 12-Oct-2016 13:58:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnalyseMPC_OpeningFcn, ...
                   'gui_OutputFcn',  @AnalyseMPC_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before AnalyseMPC is made visible.
function AnalyseMPC_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AnalyseMPC (see VARARGIN)

% Choose default command line output for AnalyseMPC
handles.output = hObject;

%open error logfile
mkdir('C:\TEMP\SignalAnalyser\');
[ ~, fidLog ] = OpenLogScope('C:\TEMP\SignalAnalyser\');
handles.fidLog = hObject;
handles.fidLog = fidLog;

%get and initialize threshold
handles.threshold = hObject;
handles.threshold = str2num(get(handles.edtThresholdLimit,'String'));

%initialize validPlot
handles.validPlot = hObject;
handles.validPlot = 0;

%initialize CsvData
handles.CSVdata = hObject;

%initialize pulseData
handles.pulseData = hObject;

%initial state of currentpath, a = non existant
handles.currentPathname = hObject;
handles.currentPathname = 'a';

%initialize validCsv
handles.validCSV = hObject;
handles.validCSV = 0;

%initialize validCsv
handles.pathname = hObject;
handles.pathname = 0;

% Update handles structure
guidata(hObject, handles);



% UIWAIT makes AnalyseMPC wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AnalyseMPC_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function tblResults_CreateFcn(hObject, eventdata, handles)
% set the tables 'Data' property to a cell array of empty matrices. 

% The size of the cell array determines the number of rows and columns in the table.

set(hObject, 'Data', cell(7,1));
set(hObject, 'RowName', {'Voltage', 'Positive max ratio: P3/P1', 'Positive min ratio: P4/P2', 'Negative max ratio: N3/N1', 'Negative min ratio: N4/N2', 'SNR', 'Second Package Ratio'}, 'ColumnName', {'Value'});


% hObject    handle to tblResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function txtaxSignal_CreateFcn(hObject, eventdata, handles)

% hObject    handle to txtaxSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pshOpen.
function pshOpen_Callback(hObject, eventdata, handles)

filename = 0;
pathname = 0;

% %check if the user has opened files before
if handles.pathname == 0
    [filename, pathname] = uigetfile({'*.csv'},'File Selector');
else
    path = [handles.pathname, '*.csv']
    [filename, pathname] = uigetfile({path},'File Selector');
end

% pathname = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\Elster\SonicExplorer\Devices\06270\Data\MPC Files\'; %use for testing
% filename = 'MPC_7-9-2019_10_22_30_AM_23.3_mps.csv'; %use for single scope signal testing
% filename = 'NGQ_Sample.csv'; %use for NGQ signal testing

if pathname ~= 0
    handles.pathname = pathname;
    handles.filename = filename;
end

if filename ~= 0
    
    %set popmenu back to original state
    set(handles.popPaths, 'Value', 1);
    set(handles.popSide, 'Value',1);
    set(handles.popMPC, 'Value', 1);
    
    strFullPath = strcat(pathname, filename);
    set(handles.edtFilePath,'String',strFullPath);
    [typeCsv, validCSV, CSVdataRaw] = LoadMPC(strFullPath, handles.fidLog);
    
    if validCSV
        if typeCsv (1,1) == 1
            % disable path pop menu
            set(handles.popPaths,'Enable', 'off');
            set(handles.popSide,'Enable', 'off');
            set(handles.popMPC,'Enable', 'off');

            %set scope data as CSV data
            CSVdata = CSVdataRaw;
        else
            % enable path pop menu
            set(handles.popPaths,'Enable', 'on');
            popPathList(1:typeCsv (1,1),1:6) = 'a';

            for i = 1:typeCsv (1,1)
                currentPath = ['Path ', num2str(i)];
                popPathList(i,:) = currentPath;
            end
            set(handles.popPaths,'String', popPathList);

            % enable side pop menu
            set(handles.popSide,'Enable', 'on');

            % enable MPC pop menu
            set(handles.popMPC,'Enable', 'on');
            popMPC(1:typeCsv (1,2),1) = '1';

            for i = 1:typeCsv (1,2)
                popMPC(i,:) = num2str(i);
            end

            set(handles.popMPC,'String', popMPC); 
            
            % set CSV data to path 1, side A MPC1 to start
            CSVdata = CSVdataRaw(1,:);
        end

        handles.validCSV = validCSV;
        handles.typeCsv = typeCsv;
        handles.CSVdataRaw = CSVdataRaw;
        handles.CSVdata = CSVdata;    

        firstProcess = 1;
        [validPlot, pulseData] = dataProcess(handles,firstProcess, hObject);
        handles.validPlot = validPlot;
        handles.pulseData = pulseData;
    end    
end

% Update handles structure
guidata(hObject, handles);

% hObject    handle to pshOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pshSetThreshold.
function pshSetThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to pshSetThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
validCsv = handles.validCSV;
handles.threshold = str2num(get(handles.edtThresholdLimit,'String'));

if validCsv == 1
    firstProcess = 1;

    [validPlot, pulseData] = dataProcess(handles,firstProcess, hObject);
    handles.validPlot = validPlot;
    handles.pulseData = pulseData;   

end

% Update handles structure
guidata(hObject, handles);


function edtThresholdLimit_Callback(hObject, eventdata, handles)
% hObject    handle to edtThresholdLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtThresholdLimit as text
%        str2double(get(hObject,'String')) returns contents of edtThresholdLimit as a double


% --- Executes during object creation, after setting all properties.
function edtThresholdLimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtThresholdLimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edtFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to edtFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtFilePath as text
%        str2double(get(hObject,'String')) returns contents of edtFilePath as a double


% --- Executes during object creation, after setting all properties.
function edtFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axSignal_CreateFcn(hObject, eventdata, handles)
set(gca,'yticklabel',{[]})
set(gca,'xticklabel',{[]}) 
% hObject    handle to axSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axSignal


% --- Executes during object creation, after setting all properties.
function axSignalZoom_CreateFcn(hObject, eventdata, handles)
set(gca,'yticklabel',{[]})
set(gca,'xticklabel',{[]}) 
% hObject    handle to axSignalZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: place code in OpeningFcn to populate axSignalZoom


% --- Executes during object creation, after setting all properties.
function axFFT_CreateFcn(hObject, eventdata, handles)
%set(gca,'yticklabel',{[]})
%set(gca,'xticklabel',{[]}) 
% hObject    handle to axFFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axFFT


% --- Executes on mouse press over axes background.
function axSignalZoom_ButtonDownFcn(hObject, eventdata, handles)
if handles.validPlot == 1
    firstProcess = 0;
    
    [validPlot, pulseData] = dataProcess(handles,firstProcess, hObject);
    handles.validPlot = validPlot;
    handles.pulseData = pulseData;
    
    % Update handles structure
    guidata(hObject, handles);   
       
end


% hObject    handle to axSignalZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popPaths.
function popPaths_Callback(hObject, eventdata, handles)
% hObject    handle to popPaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
validCsv = handles.validCSV;

if validCsv == 1
    handles.CSVdata = getSelectedSignal(hObject, handles);

    firstProcess = 1;

    [validPlot, pulseData] = dataProcess(handles,firstProcess, hObject);
    handles.validPlot = validPlot;
    handles.pulseData = pulseData;
    
    % Update handles structure
    guidata(hObject, handles);
end

% Hints: contents = cellstr(get(hObject,'String')) returns popPaths contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popPaths


% --- Executes during object creation, after setting all properties.
function popPaths_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popPaths (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popSide.
function popSide_Callback(hObject, eventdata, handles)
% hObject    handle to popSide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

validCsv = handles.validCSV;

if validCsv == 1
    handles.CSVdata = getSelectedSignal(hObject, handles);

    firstProcess = 1;

    [validPlot, pulseData] = dataProcess(handles,firstProcess, hObject);
    handles.validPlot = validPlot;
    handles.pulseData = pulseData;
    
    % Update handles structure
    guidata(hObject, handles);
end

% Hints: contents = cellstr(get(hObject,'String')) returns popSide contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popSide


% --- Executes during object creation, after setting all properties.
function popSide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popSide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PshSave.
function PshSave_Callback(hObject, eventdata, handles)
% hObject    handle to PshSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.validPlot == 1
    %get filenamedata
    pathname = handles.pathname;
    filename = handles.filename;
    filename = filename(1:end-4);

    %data gui retrieval
    STDloc = get(handles.checkboxSave,'value');
    pathSel = get(handles.popPaths, 'Value');
    pathSide = get(handles.popSide, 'Value');

    if pathSide == 1
        pathSideLetter = 'A';
    else
        pathSideLetter = 'B';
    end

    MPCNum = get(handles.popMPC, 'Value');

    %compose standard path screenshot name
    
    if handles.typeCsv(1,1) > 1
        screenshotpath = [pathname, filename, '_path', num2str(pathSel), pathSideLetter, '_MPC', num2str(MPCNum), '.jpg'];
    else
        screenshotpath = [pathname, filename,'.jpg'];
    end

    if STDloc == 1
        %save screencapture to standard locaction
        screencapture('handle',gcf, 'target',screenshotpath);
    else

        if handles.currentPathname == 'a'
            path = [pathname, '*.jpg']
            [filename, currentPathname] = uiputfile(path);
        else
            path = [handles.currentPathname, '*.jpg']
            [filename, currentPathname] = uiputfile(path);
        end
        
        %check if user pressed cancel
        if ~currentPathname == 0
            screenshotpath = [currentPathname, filename];
            
            %save current dir location for possible next save
            handles.currentPathname = currentPathname;

            % Update handles structure
            guidata(hObject, handles);
            
            %save screencapture to selected locaction
            screencapture('handle',gcf, 'target',screenshotpath);
        end
    end
end


% --- Executes on selection change in popMPC.
function popMPC_Callback(hObject, eventdata, handles)
% hObject    handle to popMPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
validCsv = handles.validCSV;

if validCsv == 1
    handles.CSVdata = getSelectedSignal(hObject, handles);

    firstProcess = 1;

    [validPlot, pulseData] = dataProcess(handles,firstProcess, hObject);
    handles.validPlot = validPlot;
    handles.pulseData = pulseData;
    
    % Update handles structure
    guidata(hObject, handles);
end
% Hints: contents = cellstr(get(hObject,'String')) returns popMPC contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popMPC


% --- Executes during object creation, after setting all properties.
function popMPC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popMPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkboxSave.
function checkboxSave_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: get(hObject,'Value') returns toggle state of checkboxSave


% --- Executes on key press with focus on checkboxSave and none of its controls.
function checkboxSave_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to checkboxSave (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
