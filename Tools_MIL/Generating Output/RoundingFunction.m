function [ Output ] = RoundingFunction( Input,Ndecimals )
%ROUNDINGFUNCTION Summary of this function goes here
%  Detailed explanation goes here
    %% Round Function
    f = 10.^Ndecimals ;
    Output= round(f*Input)/f;
end

