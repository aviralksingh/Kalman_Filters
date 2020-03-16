function [ output_args ] = SetSimulationTime(FileName,StopTime)
%GENERATEOUTPUT Summary of this function goes here
%Get model handle
h=get_param(FileName,'handle');
%% Set_system_parameters
set_param(h,'Solver','FixedStepDiscrete','StopTime',num2str(StopTime));
%,'FixedStep',num2str(Time_Step)
end

