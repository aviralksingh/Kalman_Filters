function [Test_Input_File] = Create_Test_Sheet(TestFileName,TestPathName,Inputs,Outputs,Locals)
%% Path Setting
cd(TestPathName);
%% Load the System
open_system(TestFileName);
root = bdroot;
%% Identify Inputs, Outputs and Locals
Object_Names= ['Test Case',Inputs.Names, '___t___',Outputs.Names Locals.Names];
%% Creating Test Sheet
Object_Names{2,1}='TC_ID_101';
for i = 1: length(Inputs.Names)
Object_Names{2,1+i}=num2str(zeros(Inputs.Dimensions(i,1,1),Inputs.Dimensions(i,1,2)));
end
Object_Names{2,2+i}=num2str(0.001);

Test_Input_File=['Test_Cases_' root '.xlsx'];

xlswrite(Test_Input_File,Object_Names)
end

