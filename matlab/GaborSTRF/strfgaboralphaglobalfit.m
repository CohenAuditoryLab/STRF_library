%
%function [GAModel]=strfgaboralphafit(STRFs,STRF,taxis,faxis,betaLB,betaUB)
%
%   FILE NAME       : STRF GABOR ALPHA FIT
%   DESCRIPTION     : STRF model opimization routine. The STRF is fitted
%                     using a least squares minimization procedure. The
%                     temporal receptive field is fit to a alpha-tone
%                     function while the spectral receptive field is
%                     modeled by a gabor function.
%
%   STRFs           : Significant STRF
%   STRFm           : Original STRF
%   taxis           : Frequency Axis (Hz)
%   faxis           : Time axis (sec)
%   betaLB          : Lower bound for model parameters (Optional)
%   betaUB          : Upper bound for model parameters (Optional)
%
%RETURNED VARIABLES
%
%   GAMOdel          : Data structure containing the following model
%                      results
%   .taxis           : Time axis (msec)
%   .faxis           : Frequency Axis
%   .STRFm1          : First order STRF model
%   .STRFm2          : Second order STRF model
%   .beta1           : STRF parameter vector
%       PARAMETERS FOR FIRST STRF COMPONENTS
%                     beta(1): Response latency (msec)
%                     beta(2): Rise time constant (msec)
%                     beta(3): Decay time constant (msec)
%                     beta(4): Best temporal modulation frequency (Hz)
%                     beta(5): Temporal phase (0-2*pi)
%                     beta(6): Best octave frequency, xo
%                     beta(7): Gaussian spectral bandwidth (octaves)
%                     beta(8): Best spectral modulation frequency (octaves)
%                     beta(9): Spectral phase (0-2*pi)
%                     beta(10): Peak Amplitude
%   .beta2           : The second order nonseparable model also includes 
%       PARAMETERS FOR SECOND STRF COMPONENT ALSO INCLUDE
%                     beta(11): Response latency (msec)
%                     beta(12): Rise time constant (msec)
%                     beta(13): Decay time constant (msec)
%                     beta(14): Best temporal modulation frequency (Hz)
%                     beta(15): Temporal phase (0-2*pi)
%                     beta(16): Best octave frequency, xo
%                     beta(17): Gaussian spectral bandwidth (octaves)
%                     beta(18): Best spectral modulation frequency (octaves)
%                     beta(19): Spectral phase (0-2*pi)
%                     beta(20): Peak Amplitude
%   .Cov1           : Parameter covariance matrix for first order model
%   .Cov2           : Parameter covariance matrix for second order model
%   .FI1            : Fisher information matrix for first order model
%   .FI2            : Fisher information matrix for second order model
%   .P1             : Ratio test for first order model: The model is 
%                     significant if P(10)>1.96
%   .P2             : Ratio test for second order model: The model is
%                     significant if P(10)>1.96 & P(20)>1.96
%   .Order          : Model order determined by significance test
%           
% (C) Monty A. Escabi, October 2006 (Last Edit by Chen, July 2007)
%
function [GAModel]=strfgaboralphafit(STRFs,STRF,taxis,faxis,betaLB,betaUB)

%Paramater Lower and Upper bounds
if nargin<5
    betaLB=[0  0  0   0   0    0 0 0 0    0                    ];
end
if nargin<6
    betaUB=[50 35 50 500 2*pi 8 8 4 2*pi 5*max(max(abs(STRF)))];
end

%Estimating initial STRF parameters
[RFParam]=strfparam(taxis-min(taxis),faxis,STRFs,500,4);
beta(1)=RFParam.delay;
beta(2)=RFParam.delay/4;
beta(3)=RFParam.delay/2;
beta(4)=mean(abs(RFParam.BestFm));
beta(5)=pi/2;
beta(6)=RFParam.BF;
beta(7)=1/mean(abs(RFParam.BestRD));
beta(8)=mean(abs(RFParam.BestRD));
beta(9)=0;
beta(10)=max(max(abs(STRF)));

OptOld=optimset('lsqcurvefit');
OptNew=optimset(OptOld,'MaxIter',10,'MaxFunEvals',10);
        %Fitting separable STRF model
        input.taxis=1000*(taxis-min(taxis));
        input.X=log2(faxis/faxis(1));
        [beta1,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,J1]=lsqcurvefit('strfgaboralpha1',beta,input,STRFs,betaLB,betaUB,OptNew);
        STRFm1=strfgaboralpha1(beta1,input);

%Fitting separable STRF model to RESIDUALS
%input.taxis=1000*(taxis-min(taxis));
%input.X=log2(faxis/faxis(1));
%[betaRes,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JRes]=lsqcurvefit('strfgaboralpha1',beta1,input,STRFs-STRFm1,betaLB,betaUB);
%STRFRes=strfgaboralpha1(betaRes,input);

%Fitting nonseparable STRF model
%beta=[beta1 betaRes];
beta=[beta1 beta1];
betaLB=[betaLB betaLB];
betaUB=[betaUB betaUB];
[beta2,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,J2]=lsqcurvefit('strfgaboralpha2',beta,input,STRF,betaLB,betaUB,OptNew);
STRFm2=strfgaboralpha2(beta2,input);

%Covariance Matrix
Cov1=full(inv(J1'*J1));         %Covariance Matrix
Cov2=full(inv(J2'*J2));         %Covariance Matrix
index=find(STRFs==0);
Var=var(STRF(index));           %Noise variance estimate
FI1=Cov1*Var;                   %Fisher Information Matrix
FI2=Cov2*Var;                   %Fisher Information Matrix
P1=beta1./sqrt(diag(FI1)');     %Ratio Test
P2=beta2./sqrt(diag(FI2)');     %Ratio Test

%Creating Data Structure
GAModel.taxis=taxis;
GAModel.faxis=faxis;
GAModel.STRFm1=STRFm1;
GAModel.STRFm2=STRFm2;
GAModel.beta1=beta1;
GAModel.beta2=beta2;
GAModel.Cov1=Cov1;
GAModel.Cov2=Cov2;
GAModel.FI1=FI1;
GAModel.FI2=FI2;
GAModel.P1=P1;
GAModel.P2=P2;
if P2(20)>1.96 & P2(10)>1.96
    GAModel.Order=2;
elseif P1(10)>1.96;
    GAModel.Order=1;
else
    GAModel.Order=0;
end