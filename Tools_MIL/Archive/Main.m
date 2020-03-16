close all
clear all
clc
LoadSysCals
%% Creating MIL Folder and MIL Model
[FileName,PathName] = uigetfile('Select the model to for MIL Testing');
[TestFileName,TestPathName]=Create_Model_Copy(FileName,PathName);

%% Set Signal Logging Properties
Signal_Logging(TestFileName);

%% Get Model Objects
[Inputs,Outputs,Locals]=GetModelObjects(TestFileName,TestPathName,2);

%% Add Top Level Objects
AddTopLevelImports(TestFileName,TestPathName,Inputs,Outputs,Locals)
AddAHS2FunctionCall(TestFileName,TestPathName);
%% Create Test Sheet
Create_Test_Sheet(TestFileName,TestPathName,Inputs,Outputs,Locals);
close all

