function [Test_Output] = PostprocessingData( TestCase,logsout)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
for (i = 1:logsout.getLength)
    logsout.getElement(i).Values.Name
    temp_varname=char(logsout.getElement(i).Values.Name);
    temp_vartime=logsout.getElement(i).Values.Time;
    temp_size=size(logsout.getElement(i).Values.Data);
    temp_vardata=logsout.getElement(i).Values.Data;
    tempstr=strcat(temp_varname,char('= temp_vardata;'));
    tempstr=strcat(char('Test_Output.'),temp_varname,'.values=temp_vardata;');
    eval(tempstr); 
    tempstr=strcat(char('Test_Output.'),temp_varname,'.time=temp_vartime;');
    eval(tempstr);
    tempstr=strcat(char('Test_Output.'),temp_varname,'.name=temp_varname;');
    eval(tempstr);
end
end