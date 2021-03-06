function [yk, ykbnd,spkfData] = ITER_SPKF(Vk, Tk, Ik, deltat,spkfData)

model = spkfData.model;

%Load the cell model parameters
Q  = getParamESC('QParam',Tk, model);
G  = getParamESC('GParam',Tk, model);
M  = getParamESC('MParam',Tk, model);
M0 = getParamESC('M0Param', Tk, model);
RC = exp(-deltat./abs(getParamESC('RCParam', Tk, model)));
R  = getParamESC('M0Param', Tk, model);
R0 = getParamESC('M0Param', Tk, model);
eta= getParamESC('M0Param', Tk, model);

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
