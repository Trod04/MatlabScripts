function varargout = FlowPointSelector(varargin)
% FLOWPOINTSELECTOR MATLAB code for FlowPointSelector.fig
%      FLOWPOINTSELECTOR, by itself, creates a new FLOWPOINTSELECTOR or raises the existing
%      singleton*.
%
%      H = FLOWPOINTSELECTOR returns the handle to a new FLOWPOINTSELECTOR or the handle to
%      the existing singleton*.
%
%      FLOWPOINTSELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLOWPOINTSELECTOR.M with the given input arguments.
%
%      FLOWPOINTSELECTOR('Property','Value',...) creates a new FLOWPOINTSELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FlowPointSelector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FlowPointSelector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FlowPointSelector

% Last Modified by GUIDE v2.5 30-Jul-2018 15:04:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FlowPointSelector_OpeningFcn, ...
                   'gui_OutputFcn',  @FlowPointSelector_OutputFcn, ...
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


% --- Executes just before FlowPointSelector is made visible.
function FlowPointSelector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FlowPointSelector (see VARARGIN)

% Choose default command line output for FlowPointSelector
handles.output = hObject;

%open error logfile
[ ~, fidLog ] = OpenLog('C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\FlowPointSelector\data');
handles.fidLog = hObject;
handles.fidLog = fidLog;

%open csv log data file
handles.csvData = hObject;
handles.csvData = 0;

%initialize validCsv
handles.pathname = hObject;
handles.pathname = 0;

%initialize sample start/stop values
handles.sampleStart = hObject;
handles.sampleStop = hObject;

handles.sampleStart = 1;
handles.sampleStop = 999999;

%determine numPaths based on Metertype

handles.numPaths = hObject;
Selection = get(handles.popMeterType, 'Value');
SelectedMeterType = get(handles.popMeterType, 'String');
strMeterType = SelectedMeterType(Selection, :);
handles.numPaths = numMeterType(strMeterType);

%determine Qline, VoS and Vog position

handles.Qline = hObject;
handles.VosStart = hObject;
handles.VogStart = hObject;

handles.Qline = 5*handles.numPaths + 6;
handles.VosStart = 5*handles.numPaths + 9;
handles.VogStart = 6*handles.numPaths + 9;

%determine which paths to plot
handles.plotSelection = hObject;
Selection = get(handles.pnlPlotSelected, 'SelectedObject');
strPlotSelected = get(Selection, 'String');
handles.plotSelection = numPlotSelection(strPlotSelected);

%plot variables
handles.A1 = hObject;
handles.A2 = hObject;
handles.A3 = hObject;

handles.A1 = 0;
handles.A2 = 0;
handles.A3 = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FlowPointSelector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FlowPointSelector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushAddFlowpoint.
function pushAddFlowpoint_Callback(hObject, eventdata, handles)
% hObject    handle to pushAddFlowpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushOpenLogFile.
function pushOpenLogFile_Callback(hObject, eventdata, handles)

%open prompt to obtain logfiledata
handles = OpenSonicLogfile(handles);

%set sampleStop to the correct maximum

[sizeRows, ~] = size(handles.csvData);

if sizeRows > 1
   maxSize = num2str(sizeRows);
   set(handles.editSampleStop,'String', maxSize);

   handles.sampleStop = sizeRows;
   
   % Update handles structure
    guidata(hObject, handles);
end

%update graphs
handles = UpdateGraphs(handles);

% Update handles structure
guidata(hObject, handles);

%update graphs


% hObject    handle to pushOpenLogFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkActivateVosFilter.
function checkActivateVosFilter_Callback(hObject, eventdata, handles)
% hObject    handle to checkActivateVosFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkActivateVosFilter



function editNumVosSTDev_Callback(hObject, eventdata, handles)
% hObject    handle to editNumVosSTDev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumVosSTDev as text
%        str2double(get(hObject,'String')) returns contents of editNumVosSTDev as a double


% --- Executes during object creation, after setting all properties.
function editNumVosSTDev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumVosSTDev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkActivateVogFilter.
function checkActivateVogFilter_Callback(hObject, eventdata, handles)
% hObject    handle to checkActivateVogFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkActivateVogFilter


% --- Executes on button press in pushExportCsv.
function pushExportCsv_Callback(hObject, eventdata, handles)
% hObject    handle to pushExportCsv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function editNumVogSTDev_Callback(hObject, eventdata, handles)
% hObject    handle to editNumVogSTDev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNumVogSTDev as text
%        str2double(get(hObject,'String')) returns contents of editNumVogSTDev as a double


% --- Executes during object creation, after setting all properties.
function editNumVogSTDev_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNumVogSTDev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editQmax_Callback(hObject, eventdata, handles)
% hObject    handle to editQmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editQmax as text
%        str2double(get(hObject,'String')) returns contents of editQmax as a double


% --- Executes during object creation, after setting all properties.
function editQmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editQmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkPlotP1.
function checkPlotP1_Callback(hObject, eventdata, handles)
% hObject    handle to checkPlotP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkPlotP1

% --- Executes on selection change in popMeterType.
function popMeterType_Callback(hObject, eventdata, handles)
% hObject    handle to popMeterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popMeterType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popMeterType


% --- Executes during object creation, after setting all properties.
function popMeterType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popMeterType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSampleStart_Callback(hObject, eventdata, handles)
% hObject    handle to editSampleStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setVal = str2num(get(handles.editSampleStart, 'String'));

if setVal < 1 || setVal >= str2num(get(handles.editSampleStop, 'String')) || handles.csvData == 0
    set(handles.editSampleStart, 'String', num2str(1));
    handles.sampleStart = 1;
else
    handles.sampleStart = setVal;
end

% Update handles structure
guidata(hObject, handles);


% Hints: get(hObject,'String') returns contents of editSampleStart as text
%        str2double(get(hObject,'String')) returns contents of editSampleStart as a double


% --- Executes during object creation, after setting all properties.
function editSampleStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSampleStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSampleStop_Callback(hObject, eventdata, handles)
% hObject    handle to editSampleStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setVal = str2num(get(handles.editSampleStop, 'String'));

if handles.csvData ~= 0    
    if  setVal <= str2num(get(handles.editSampleStart, 'String'))
       [~, sizeRows] = size(handles.csvData);
       maxSize = num2str(sizeRows);

       set(handles.editSampleStop, 'String', maxSize);
       handles.sampleStop = sizeRows;       
    else
       handles.sampleStop = setVal;
    end
else
    set(handles.editSampleStop, 'String', num2str(999999));
    handles.sampleStop = 999999;
end

% Update handles structure
guidata(hObject, handles);

% Hints: get(hObject,'String') returns contents of editSampleStop as text
%        str2double(get(hObject,'String')) returns contents of editSampleStop as a double


% --- Executes during object creation, after setting all properties.
function editSampleStop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSampleStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function text5_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axesQlineTotal_CreateFcn(hObject, eventdata, handles)

set(gca,'yticklabel',{[]});
set(gca,'xticklabel',{[]}); 

% hObject    handle to axesQlineTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesQlineTotal


% --- Executes during object creation, after setting all properties.
function axesVosSelection_CreateFcn(hObject, eventdata, handles)

set(gca,'yticklabel',{[]});
set(gca,'xticklabel',{[]});

% hObject    handle to axesVosSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesVosSelection


% --- Executes during object creation, after setting all properties.
function axesVogSelection_CreateFcn(hObject, eventdata, handles)

set(gca,'yticklabel',{[]});
set(gca,'xticklabel',{[]}); 

% hObject    handle to axesVogSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesVogSelection


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over radiobutton1.
function radiobutton1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over radiobutton2.
function radiobutton2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in pnlPlotSelected.
function pnlPlotSelected_SelectionChangedFcn(hObject, eventdata, handles)

Selection = get(handles.pnlPlotSelected, 'SelectedObject');
strPlotSelected = get(Selection, 'String');
handles.plotSelection = numPlotSelection(strPlotSelected);

%update graphs
handles = UpdateGraphs(handles);

% Update handles structure
guidata(hObject, handles);

% hObject    handle to the selected object in pnlPlotSelected 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1
