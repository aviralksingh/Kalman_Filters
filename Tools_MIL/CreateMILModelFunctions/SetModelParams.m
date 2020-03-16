function [ ] = SetModelParams(FileName,TimeStep)
%Function enables signal logging at the point of creation of a signal
%Get model handle
h=get_param(FileName,'handle');
%Get model object
ob=get_param(h,'object');
%Find Stateflow charts in model
sfchart=ob.find('-isa','Stateflow.Chart');
%Find the states in this stateflow chart
sfStates=sfchart.find('-isa','Stateflow.State');
%Enable logging for all states
for x=1:length(sfStates)
 sfStates(x).LoggingInfo.DataLogging = 1;
end 

%% Set_system_parameters
set_param(h,'Solver','FixedStepDiscrete','StopTime','10','FixedStep',TimeStep)

%% Set the Global logging options (Which are in the Configuration %parameter dialog box
set_param(h,'SignalLogging','on');
set_param(h,'SignalLoggingName','logsout');
set_param(h,'SaveFormat','StructureWithTime');
set_param(h,'SignalLoggingSaveFormat','Dataset');
end

