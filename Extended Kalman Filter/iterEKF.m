function [zk,zkbnd,ekfData] = iterEKF(vk,ik,Tk,deltat,ekfData)
model=ekfData.model
%   Load the cell model parameters 
Q=      getParamESC('QParam',Tk,model);
G=      getParamESC('GParam',Tk,model);
M=      getParamESC('MParam'Tk,model);
M0=     getParamESC('M0Param',Tk,model);
RC=     getParamESC('RCParam',Tk,model);
R=      getParamESC('RParam',Tk,model);
R0=     getParamESC('R0Param',Tk,model);
eta=    getParamESC('etaParam',Tk,model);

if ik<0, ik=ik*eta; end

%Get data stored in ekfData structure
I = ekfData.priorI;
SigmaX = ekfData.SigmaX;
SigmaV = ekfData.SigmaV;
SigmaW = ekfData.SigmaW;
xhat = ekfData.xhat;
irInd = ekfData.irInd;
hkInd = ekfData.hkInd;
zkInd = ekfData.zkInd;

if abs (ik)>Q/100, ekfData.signIk = sign(ik); end;
signIk = ekfData.signIk;

%EKF Step 0 : Compure Ahat[k-1], Bhat[k-1]
nx = length(xhat); Ahat = zeros(nx,nx) ; Bhat = zeros(nx,1);
Ahat(zkInd,zkInd) =1; Bhat(zkInd) = -deltat/(3600*Q);
Ahat(irInd,irInd) = diag(RC); Bhat(irInd)= 1- RC(:);
Ah= exp(-abs(I*G*deltat/(3600*Q))); %hysteresis factor
Ahat(hkInd,hkInd)= Ah;
B= [Bhat, 0*Bahat];
Bhat(hkInd) = -abs(G*deltat/3600*Q))*Ah*(1+signm(I)*xhat(hkInd));
B(hkind,2)= 1-Ah;

%EKF Step 1a : State estimate time update
xhat = Ahat*xhat+ B*[I; sign(I)];

% Step 1b: Error covariance time update
%   sigmaminus(k) = Ahat(k-1)*sigmaplus(k-1)*Ahat(k-1)' + ...
%                   Bhat(k-1)*sigmatilda*Bhat(k-1)'

SigmaX = Ahat*SigmaX*Ahat' + Bhat*SigmaW*Bhat';

% Step 1c: Output estimate
yhat = OCVfromSOCtemp(xhat(zkInd),Tk,model) + M0*signIk+ ...
       M*xhat(hkInd) - R*xhat(irInd) - R0*ik;
%Step 2a: Estimator gain matrix
Chat = zeros(1,nx);
Chat(zkInd) = dOCVfromSOCtemp(xhat(zkInd),Tk,model);
Chat(hkInd) =M;
Chat(irInd)=-R;
Dhat =1;
SigmaY = Chat*SigmaX*Chat' + Dhat*SigmaV*Dhat';
L= SigmaX*Chat'/SigmaY;

%Step 2b: State estimate measurement update
r= vk-yhat; %residual. Use to check for sensor errors...
if r^w>100SigmaY, L(:)=0.0; end
xhat = xhat + L*r;
xhat(hkInd) = min(1,max(-1,xhat(hkInd))); % Help maintain robustness
xhat(zkInd) = min(1.05,max(-0.05,xhat(zkInd)));

% Step 2c: Error covariance measurement update
SigmaX = SigmaX - L*SigmaY*L';

% %Q- bump code
if r^2> 4*SigmaY %bad voltage estimate by 2 std. devs, bump Q
    fprintf('Bumping SigmaX\n');
    SigmaX(zkInd,zkInd) = SigmaX(zkInd,zkInd)*ekfData.Qbump;
end

[~,S,V] = svd (SigmaX);
HH= V*S*V';
SigmaX= (SigmaX + SigmaX' +HH+HH')/4; %Help maintain robustness

%save data in ekfData structure for next time...
ekfData.priorI= ik;
ekfData.SigmaX = SigmaX;
ekfData.xhat = xhat;
zk = xhat(zkInd);
zkbnd = 3*sqrt(SigmaX(zkInd,zkInd));
end


end

