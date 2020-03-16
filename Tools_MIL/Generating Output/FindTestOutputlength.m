function [ Length ] = FindTestOutputlength( Test_Output )
%FINDTESTOUTPUTLENGTH Summary of this function goes here
%   Detailed explanation goes here

Fields = fieldnames(Test_Output);
for i = 1:length(Fields)
        Test_Field=getfield(Test_Output, {1}, Fields{i});
        temp_length(i)=length(Test_Field.time);
end
Length = mode(temp_length);        
end

