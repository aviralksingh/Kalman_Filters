function ekfData = init(v0,T0,SigmaX0,SigmaV,SigmaW,model)
%   Initial State description
ir0 = 0;
ekfData.irInd =1;
hk0 = 0;
ekfData.hkInd =2;
SOC0 = SOCfromOCVtemp (v0,T0,model);
ekfData.zkInd=3;
ekfData.xhat = [ir0 hk0 SOC0]'; %initial state

%Covariance values
ekfData.SigmaX = SigmaX0;
ekfData.SigmaW = SigmaV;
ekfData.Qbump =5;

%Previous value of current
ekfData.priorI=0;
ekfData.signIk=0;

%store model data structure too
ekfData.model=model;
end

