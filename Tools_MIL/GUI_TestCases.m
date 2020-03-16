function varargout = GUI_TestCases(varargin)
% GUI_TESTCASES MATLAB code for GUI_TestCases.fig
%      GUI_TESTCASES, by itself, creates a new GUI_TESTCASES or raises the existing
%      singleton*.
%
%      H = GUI_TESTCASES returns the handle to a new GUI_TESTCASES or the handle to
%      the existing singleton*.
%
%      GUI_TESTCASES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_TESTCASES.M with the given input arguments.
%
%      GUI_TESTCASES('Property','Value',...) creates a new GUI_TESTCASES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_TestCases_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_TestCases_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_TestCases

% Last Modified by GUIDE v2.5 28-Feb-2018 09:49:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_TestCases_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_TestCases_OutputFcn, ...
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

% --- Executes just before GUI_TestCases is made visible.
function GUI_TestCases_OpeningFcn(hObject, eventdata, handles, varargin)
%
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_TestCases (see VARARGIN)

% load all cals
LoadSysCals;

% default function initializes all the edit and list boxes
default(hObject, handles);

% Choose default command line output for GUI_TestCases
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_TestCases_OutputFcn(hObject, eventdata, handles)
%
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
%
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
%
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
%
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
%
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit20_Callback(hObject, eventdata, handles)
%
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
%
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton3.
function pushbutton1_Callback(hObject, eventdata, handles)
%
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

TimeStep = handles.TimeStep;

% set pushbutton to run
[pushbutton_info]=Run_Indication(handles,1);

% Clear path in the edit boxes
set(handles.edit1, 'String','');
set(handles.edit2, 'String','');

% Get original model file (library)
[FileName,PathName]=uigetfile('Select the model for MIL Testing');

% Create a simulation model (copy)
[TestFileName,TestPathName]=Create_Model_Copy(FileName,PathName,TimeStep);

% Enable signal logging in simulation model
Signal_Logging(TestFileName);

% Get Model Objects
[Inputs,Outputs,Locals]=GetModelObjects(TestFileName,TestPathName,2);

% Add Top Level Objects
AddTopLevelImports(TestFileName,TestPathName,Inputs,Outputs,Locals)
AddAHS2FunctionCall(TestFileName,TestPathName);

% Create Test Cases Template File
Test_Input_File=Create_Test_Sheet(TestFileName,TestPathName,Inputs,Outputs,Locals);

% reset pushbutton
set(handles.pushbutton1,'str',pushbutton_info.text,'backg',pushbutton_info.bgColor);

% Update edit boxes
set(handles.edit1, 'String', [TestPathName,TestFileName,'.mdl']);
set(handles.edit2, 'String', [TestPathName,Test_Input_File]);

% Update handles structure
handles.TestFileName=TestFileName;
handles.TestPathName=TestPathName;
handles.TC_Input_File=Test_Input_File;
handles.Inputs=Inputs;
handles.Outputs=Outputs;
handles.Locals=Locals;
guidata(hObject,handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
%
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
%
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% clear edit box
set(handles.edit1, 'String','');

[Mdl_FileName,Mdl_PathName]=uigetfile('Select the model for MIL Testing');

% if user does not provide an input do not edit the edit box
if ~isequal(Mdl_FileName,0)
    set(handles.edit1, 'String',[Mdl_PathName,Mdl_FileName]);
else
end;
% get filename
Name =  strsplit(Mdl_FileName, '.');
FileName = Name{1};

% Update handles structure
handles.TestFileName = Mdl_FileName;
handles.TestPathName = Mdl_PathName;
guidata(hObject, handles);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% clear edit box
set(handles.edit2, 'String','');

[TC_FileName,TC_PathName]=uigetfile({'*.xls;*.xlsx'},'File Name','Select Test Cases Excel File');

% if user does not provide an input do not edit the edit box
if ~isequal(TC_FileName,0)
    set(handles.edit2, 'String',[TC_PathName,TC_FileName]);
else
end;

% Update handles structure
handles.TC_Input_File = TC_FileName;
guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles) % run
%
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set pushbutton to run
[pushbutton_info]=Run_Indication(handles,5);

% getting file names
Mdl_FileName=handles.TestFileName;
Mdl_PathName=handles.TestPathName;
TC_FileName=handles.TC_Input_File;

% Get Model Objects
[Inputs,Outputs,Locals]=GetModelObjects(Mdl_FileName,Mdl_PathName,1);

% Create Signal Strings
InputNamesStr = CreateInputString(Inputs);

% Get Test Cases
[Test_Input,Time,TestCase,Input_Matrix,Inputs_Matrix_Struct] = GetTestCases(Inputs,TC_FileName);

% reset push button
set(handles.pushbutton5,'str',pushbutton_info.text,'backg',pushbutton_info.bgColor)

% Update handles structure
handles.Inputs=Inputs;
handles.Outputs=Outputs;
handles.Locals=Locals;
handles.InputNamesStr=InputNamesStr;
handles.Test_Input=Test_Input;
handles.TestCase=TestCase;
handles.Input_Matrix=Input_Matrix;
handles.Inputs_Matrix_Struct=Inputs_Matrix_Struct;
handles.Time=Time;
guidata(hObject, handles);


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
%
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set pushbutton to run
[pushbutton_info]=Run_Indication(handles,6);

Inputs=handles.Inputs;
Outputs=handles.Outputs;
Locals=handles.Locals;
InputNamesStr=handles.InputNamesStr;
Test_Input=handles.Test_Input;
TestCase=handles.TestCase;
Inputs_Matrix_Struct=handles.Inputs_Matrix_Struct;
Mdl_FileName = handles.TestFileName;
Time=handles.Time;
TC_FileName=handles.TC_Input_File;
TimeStep = handles.TimeStep;

% get filename
Name =  strsplit(Mdl_FileName, '.');
FileName = Name{1};

% Select test cases to simulate
[Selected,OK_Pressed]=listdlg('PromptString','Select test cases to run:',...
    'ListString',TestCase);
Inputs_Selected=[];

% Simulate
% if user presses ok continue execution else terminate
if (OK_Pressed==1)
    % extracting selected inputs and time matrix
    for i=1:length(Selected)
        Inputs_Selected=[Inputs_Selected;Inputs_Matrix_Struct{Selected(i)}];
        Time_Selected{i}=Time{Selected(i)};
        TestCaseStr{i}= TestCase{Selected(i)};
    end;
    
    % run only selected test cases
    Test_Output=SimTestCases(Selected,Time,Inputs,Test_Input,InputNamesStr,TestCase,FileName);
    
    % save simulation logs as .mat file
    save(strcat('Test_Result_',TC_FileName,'.mat'),'Test_Output')
    disp('Completed!!!');
    
    % data post processing before saving to excel file
    Sort_Matrix=GenerateOutputMatrix(Inputs,Outputs,Locals,Test_Input,Time_Selected,Test_Output);
    Output_Matrix=[Inputs_Selected Sort_Matrix];
    
    % save as excel
    Test_Output_LogFile=['Test_Ouput_' Mdl_FileName '.xlsx'];
    xlswrite(Test_Output_LogFile,Output_Matrix);
    
    % update list box with test cases that were run
    set(handles.listbox6,'String',TestCaseStr);
else
    msgbox('No test cases were selected','Title','modal');
    set(handles.listbox6,'String','');
end;

% reset pushbutton
set(handles.pushbutton6,'str',pushbutton_info.text,'backg',pushbutton_info.bgColor);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton5.
function pushbutton9_Callback(hObject, eventdata, handles)
%
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in listbox6.
function listbox6_Callback(hObject, eventdata, handles)
%
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox6


% --- Executes during object creation, after setting all properties.
function listbox6_CreateFcn(hObject, eventdata, handles)
%
% hObject    handle to listbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
% --- Reset pushbutton
function pushbutton7_Callback(hObject, eventdata, handles)
%
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set all attributes to default
default(hObject, handles);

% Update handles structure
guidata(hObject, handles);


function default(hObject, handles)
% set all edit boxes to default values at startup
set(handles.edit1,'String','Enter MIL Model file path');
set(handles.edit2,'String','Enter Test Cases file path');
set(handles.edit2,'String','Enter Time Step');
set(handles.edit14,'String','0.001');
set(handles.listbox6,'String','');
set(handles.pushbutton1,'String','Create MIL Model','backg',[0.941,0.941,0.941]);
set(handles.pushbutton5,'String','Get Test Cases','backg',[0.941,0.941,0.941]);
set(handles.pushbutton6,'String','Run Test Cases','backg',[0.941 0.941 0.941]);

% Update handles structure
guidata(hObject, handles);

function [pushbutton_info]=Run_Indication(handles,number)
pb_handle=eval(['handles.pushbutton',num2str(number)]);
BackGrnd_Color = get(pb_handle,'backg');  % Get the background color of the figure.
PushButton_Text = get(pb_handle,'String');
set(pb_handle,'str','Running.....','backg',[1 .6 .6]) % Change color of button.
pushbutton_info.bgColor = BackGrnd_Color;
pushbutton_info.text = PushButton_Text;



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
TimeStep = get(handles.edit14, 'String');
handles.TimeStep = (TimeStep);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

