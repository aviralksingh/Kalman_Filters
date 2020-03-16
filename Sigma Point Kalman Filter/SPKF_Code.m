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

function [yk, ykbnd,spkfData] = ITER_SPKF(Vk, Tk, Ik, deltat,spkfData)

model = spkfData.model;

%Load the cell model parameters
Q  = getParamESC('QParam',Tk, model);
G  = getParamESC('GParam',Tk, model);
M  = getParamESC('MParam',Tk, model);
M0 = getParamESC('M0Param', Tk, model);
RC = exp(-deltat./abs(getParamESC('RCParam', Tk, model)));
R  = getParamESC('RParam', Tk, model);
R0 = getParamESC('R0Param', Tk, model);
eta= getParamESC('etaParam', Tk, model);

if Ik<0
    Ik =Ik*eta;
end

%Get data stored in spkfData Structure
irInd = spkfData.irInd;
hkInd = spkfData.hkInd;
zkInd = spkfData.zkInd;
xhat  = spkfData.xhat;
SigmaX= spkfData.SigmaX;

%Get SPKF specific parameters
Snoise = spkfData.Snoise;
Nx     = spkfData.Nx;
Nw     = spkfData.Nw;
Nv     = spkfData.Nv;
Na     = spkfData.Na;
alpham = spkfData.alpham;
alphac = spkfData.alphac;

%Dynamic variables relating to input current
I = spkfData.priorI;
if abs(ik)>Q/100
    spkfData.signIk = sign(ik);
end
signIk = spkfData.signIk;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start SPKF Steps%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 % Step 1a: State-Estimate Time Update
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Step 1a: State-Estimate Time Update
%              - Create x_hat_minus augmented SigmaX points
%              - Create x_hat_minus state SigmaX points            
%              - Compute weighted average x_hat_minus(k)

%Step 1a -1: Create Augmented x_hat and Sigma X
x_hat_augmented = [xhat; zeros([Nw+nV] 1)];
[Sigma_X_Augmented, p] = chol(SigmaX,'lower');
if p>0,
    fprintf('Cholesky Error. Recovering...\n');
    theAbsDiag = abs(diag(SigmaX));
    Sigma_X_Augmented = (max (SQRT(theAbsDiag),SQRT(spkfData.SigmaW)));
end
Sigma_X_Augmented = blkdiag(real(Sigma_X_Augmented),Snoise);
%Sigma_X_Augmented is lower triangular 

%Step 1a -2: Calculate SigmaX Points
X_Augmented = x_hat_augmented(:, ones([1 2*Na+1]))+ spkfData.h*[zeros([Na 1]), Sigma_X_Augmented, -Sigma_X_Augmented];

%Step 1a-3: Time Update from last iteration until now
% StateEquation (Xold, Current, Noise)
Xx    = StateEqn( Xa(1:Nx,:), I < Xa(Nx+1:Nx+Nw,:));
x_hat = Xx*alpham;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                 % Step 1b: Error-Covariance time Update
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%          Compute weighted covariance Sigma_minus(k)

Xs =Xx -xhat(:, ones([1 2*Na+1]));
SigmaX=Xs*diag(alphac)*Xs';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %Step 1c: Output Estimate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%          Compute weighted output estimate yhat(k)
I = ik;
yk =vk;
Y= outputEqn(Xx, I Xa(Nx+Nw+1:end,:), Tk, model);
yhat = Y*alpham;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                     %Step 2a: Estimator Gain Matrix 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Ys = Y- yhat(:, ones([1 2*Na+1]));
SigmaXY = Xs*diag(alphaC)*Ys';
SigmaY  = Ys*diag(alphac)*Ys';
L= SigmaXY/SigmaY;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Step 2b: State Measurement Update
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

r = yk- yhat; %residual
if r^2 > 100*SigmaY
    L(:,1)=0.0;
end
x_hat=x_hat+L*r;
xhat(hkInd) = min(1, max(-1,xhat(hkInd)));
xhat(zkInd) = min(1, max(-0.05,xhat(zkInd)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               %Step 2c: Error Covariance Measurement Update
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Start%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SigmaX = Sigma X - L*SigmaY*L';
[~,S,V] =svd(SigmaX);
HH=V*S*V';
SigmaX=(SigmaX+SigmaX'+HH+HH')/4; %Help maintain Robustness

% Q- Bump Code
if r^2 > 4*SigmaY %bad voltage estimate by 2-Sigma X, bump Q
    fprintf('Bumping sigmax\n');
    SigmaX(zkInd, zkInd)= SigmaX(zkInd, zkInd)*spkfData.SXbump;
end


% Save data in spkfData structure for next time...
spkfData.priorI= ik;
spkfData.SigmaX = SigmaX;
spkfData.xhat=shat;
zk=xhat(zkInd);
zkbnd=3*sqrt(SigmaX(zkInd,zkInd));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
