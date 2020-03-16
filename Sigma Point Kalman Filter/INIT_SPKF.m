function spkfData = INIT_SPKF(Ve_V_AvgVoltage, Ve_T_AvgTemperature, Ve_k_StateCovariance, Ve_k_MeasurementCovariance, Ve_k_ProcessNoiseCovariance, Model)

% Initial State Description
IR0 = 0;                spkfData.irInd=1;
hk0 = 0;                spkfData.hkInd=2;
SOC0 = 0;               spkfData.zkInd=3;

spkfData.xhat = [IR0 hk0 SOC0]';

%Covariance Values
spkfData.SigmaX= Ve_k_StateCovariance;
spkfData.SigmaV= Ve_k_MeasurementCovariance;
spkfData.SigmaW= Ve_k_ProcessNoiseCovariance;
spkfData.Snoise=chol (blkdiag(Ve_k_ProcessNoiseCovariance, Ve_k_MeasurementCovariance), 'lower');
spkfData.SXbump=5;

%SPKF specific parameters
Nx= length(spkfData.xhat);                  spkfData.Nx=Nx; % State-Vector Length
Ny=1;                                       spkfData.Ny=Ny; %Measurement-Vector Length
Nu=1;                                       spkfData.Nu=Nu; %Measurement-Vector Length
Nw = size(Ve_k_ProcessNoiseCovariance,1);   spkfData.Nw=Nw; %Process Noise- Vector Length
Nv=  size(Ve_k_MeasurementCovariance,1);    spkfData.Nv=Nv; % Sensor-Noise- Vector Length
Na= Nx+Nw+Nv;                               spkfData.Na=Na; %Augmented-State-Vector Length

% Tuning Factors
h= sqrt(3);                                 spkfData.h=h;   %SPKF/CDKF tuning factor
alpha1 = (h*h-Na)/(h*h);                                    %weighting factors when computing mean
alpha2 = 1/(2*h*h);                                         %weighting factors when computing covariance
                                            spkfData.alpham=[alpha1; alpha2*ones(2*Na,1)]; % mean
                                            spkfData.alphac=alpham;                        % covariance
                                            
% previous value of current
spkfData.priorI=0;
spkfData.signIk=0;

%store model data structure
spkfData.model=model;


end

function xnew = StateEquation(xold, current, xnoise)
current = current+xnoise; %noise adds to current
xnew = 0*xold; % create space for x new
xnew (irInd,:) = RC*xold(irInd,:)+(1-RC)*current);
Ah = exp(-abs(current*G*deltat/3600/Q));
xnew(hkInd,:)= Ah.*xold(zkInd,:)+ (Ah-1).*sign(current);
xnew(zkInd,:) = xold(zkInd,:) -current/3600/Q;
xnew(hkInd,:)= min(1,max(-1,xnew(hkInd,:)));
xnew(zkInd,:) = min(1.05,max(-0.05,xnew(zkInd,:)));
end


function yhat = outputEquation(xhat,current,ynoise,T,model)
yhat=OCVfromSOCtemp(xhat(zkInd,:),T,model);
yhat=yhat + M*xhat(hkInd,:) + M0*signIk;
yhat=yhat -R*xhat(irInd,:) - R0*current+ynoise(1,:);
end

function X=SQRT(x)
    X=sqrt(max(0,x));
end
