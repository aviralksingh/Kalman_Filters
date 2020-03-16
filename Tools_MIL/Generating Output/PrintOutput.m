function [ output_args ] = PringOutput(TC_FileName,Inputs,Outputs,Locals,Test_Input,Test_Output)
%GENERATEOUTPUT Summary of this function goes here
%   Detailed explanation goes here
Test_Output_File= strcat('Output_',TC_FileName);


xlswrite(Test_Output_File,Object_Names)
end

