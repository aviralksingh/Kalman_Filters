function [TestFileName,TestPathName] = Create_Model_Copy(FileName,PathName,TimeStep)
%% Creating MIL Folder and Path
% [FileName,PathName] = uigetfile('Select the model to for MIL Testing');
cd(PathName)
temp=strsplit(FileName,'.');
FileFolder=temp{1};
TestFolder=strcat(FileFolder,'_MIL');
if exist(TestFolder,'dir')
else
    mkdir(TestFolder)
    addpath(TestFolder)
end
TestPathName=strcat(PathName,TestFolder,'\');
cd(TestPathName)
Model_File_Name=temp{1};
TestFileName = strcat(FileFolder,'_MIL','_Model');
%% CREATE_MODEL_COPY Summary of this function goes here
%save_system(Model_File_Name,'newsysname.slx','BreakLinks') 
% create and open the model
if exist(TestFileName,'file')
    delete(TestFileName)
else
end
open_system(new_system(TestFileName));
load_system(Model_File_Name);

% add block from library
Source_Block=find_system(Model_File_Name,'SearchDepth',1,'Type','Block');
Test_Block='Sl_test';
Dest_Block=strcat(TestFileName,'/',Test_Block);
add_block(char(Source_Block),Dest_Block)

% save system after breaking links
save_system(TestFileName,[],'BreakAllLinks',true);

%% Set Signal Logging Properties
SetModelParams(TestFileName,TimeStep)
%% Add Path
addpath(TestFolder)
end

