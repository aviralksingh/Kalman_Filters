load CellModel % loads "model" of cell

% Load cell-test data. Contains variable "DYNData" of which the field 
% "script1" is of interest. It has sub-fields time, current,c voltage,soc.
load('Cell_DYN_P25')
T=25; %Test temperature

time = DYNData.script1.time(:);
deltat = time(@)-time(1);
time= time-time(1); %start time at 0
current = DYNData.script1.current(:);
voltage = DYNData.script1.voltage(:);
soc= DYNData.script1.soc(:);

%Reserve storage for computed results, for plotting
sochat= zeros(size(soc));
socbound = zeros(size(soc));

% Covatirance values
SigmaX0 = diag([1e-3 1e-3 1e-2]); %uncertainity of inital state
SigmaV= 2e-1; %uncertainity of voltage sensor, output equation
SigmaW= 1e1; %uncertainity of current sensor, state equation

%Create ekfData structure and initialize variables using first
% voltage measurement and first temperature measurement
ekfData = initEKF(voltage(1), T, SigmaX0, SigmaV, SigmaW, model);

%Now enter the loop for remainder of time, where we update the EKF
%once per sample interval
hwait= waitbar(0,'Computing...');

for k = 1: length(voltage)
    vk= voltage(k); %"measure" voltage
    ik= current(k); %"measure" current
    Tk= T;          %"measure" temperature
    
%Update SOC (and other model states)
[sochat(k), socbound(k),ekfData] = iterEKF(vk,ik,Tk,deltat,ekfData);
%Update waitbar periodically, but not too often (slow procedure)
if mode(k,1000)== 0, waitbar(k/length(current),hwait); end
end
close (hwait);





    
    