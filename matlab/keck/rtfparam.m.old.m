%
%function [TFParam]=rtfparam(Fm,RD,RTF,Thresh,alpha,Display)
%
%   FILE NAME       : RTF PARAM
%   DESCRIPTION     : Finds RTF Parameters
%
%       Fm          : Modulation Rate Axis
%       RD          : Ripple Density Axis
%       RTF         : Ripple Transfer Function (assumes amplitude not power)
%       Thresh      : Fraction of Maximum Power for second response peak
%                     Two Best RD and FM are choosen if the second
%                     maximum power achieves the value Thresh*max(max(RTF))
%                     where Thresh is between [0 1] (Default=.5).
%       alpha       : Threshold value for computing cSMF and cTMF. Values below 
%                     alpha are not considered (Default==0.25)
%       Display     : Display : 'y' or 'n' (Default='n')
%
%RETURNED VALUES
%   TFParam (Data structure containing RTF parameters)
%       .BestFm     : Best Modulation Rate - Returns 2 values if second 
%                     quadrant exceeds desired threshold value
%       .BestRD     : Best Ripple Density - Returns 2 values if second 
%                     quadrant exceeds desired threshold value
%       .bTMF       : Best Temporal Modulation Frequency (Optained by averaging
%                     RTF quandrants ala Milller 2001)
%       .bSMF       : Best Spectral Modulation Frequency (Optained by averaging
%                     RTF quandrants ala Milller 2001)
%       .cTMF       : Temporal Modulation Frequency Centroid (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%       .cSMF       : Spectral Modulation Frequency Centroid (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%       .cTMF2      : Same as cTMF except that signals below alpha % of max are
%                     not used in the estimate
%       .cSMF2      : Same as cSMF except that signals below alpha % of max are
%                     not used in the estimate
%       .bwSMF      : Spectral MTF bandwidth, Measured using standard deviation
%                     of sMTF
%       .bwTMF      : Tpectral MTF bandwidth, Measured using standard deviation
%                     of tMTF
%       .bwSMF2     : Same as bwSMF except that signals below alpha% of max are
%                     not used in the estimate
%       .bwTMF2     : Same as bwTMF except that signals below alpha% of max are
%                     not used in the estimate
%.FmUpperCutoff     : Temporal Modulation Frequency Upper Cutoff (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%.FmLowerCutoff     : Temporal Modulation Frequency Lower Cutoff (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%.RDUpperCutoff     : Spectral Modulation Frequency Upper Cutoff (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%.RDLowerCutoff     : Spectral Modulation Frequency Lower Cutoff (Optained by
%                     averaging RTF quandrants ala Milller 2001)
%       .DSI        : Direction selectivity index, DSI=(P1-P2)/(P1+P2) where P1 and
%                     P2 are the powers in the 1st and 2nd ripple transfer function
%                     quadrants, respectively.
%       .Max        : Peak Response values from Ripple density plot
%
%   (C) Monty A. Escabi, Edit October 2007 (Edit January 2008)
%
function [TFParam]=rtfparam(Fm,RD,RTF,Thresh,alpha,Display)

%Input Arguments
if nargin<4
    Thresh=0.5;
end
if nargin<5
    alpha=0.25;
end
if nargin<6
    Display='n';
end

%Convert RTF to Power RTF
RTF=RTF.^2;

%Computing Parameters
N1=size(RTF,1);
N2=size(RTF,2);
[i,j]=find( RTF(floor(N1/2)+1:N1,:)==max(max(RTF(floor(N1/2)+1:N1,:))) );
BestRD1=RD(i(1)+floor(N1/2));
BestFm1=Fm(j(1));
Max=max(max(RTF));

%Finding a second Maximum Conjugate Frequencies
N=ceil(length(Fm)/2);
if BestFm1<0
	[i,j]=find( RTF(floor(N1/2)+1:N1,N:N2)==max(max(RTF(floor(N1/2)+1:N1,N:N2))) );
	Max2=max(max(RTF(floor(N1/2)+1:N1,N:N2)));
	BestRD2=RD(i+floor(N1/2));
	BestFm2=Fm(j+N-1);
else
	[i,j]=find( RTF(floor(N1/2)+1:N1,1:N)==max(max(RTF(floor(N1/2)+1:N1,1:N))) );
	Max2=max(max(RTF(floor(N1/2)+1:N1,1:N)));
	BestRD2=RD(i+floor(N1/2));
	BestFm2=Fm(j);
end

%Combining Negative and Possitive Frequencies if Exceeds Power Threshold
if Max2>Thresh*Max
	BestFm=[BestFm1 BestFm2];
	BestRD=[BestRD1 BestRD2];
    Max=[Max Max2];
else
	BestFm=BestFm1;
	BestRD=BestRD1;
    Max=Max;
end

%Computing Direction Selectivity Index (DSI)
RTF1=RTF(ceil(N1/2+.1):N1,ceil(N2/2+.1):N2);
RTF=fliplr(RTF);
RTF2=RTF(ceil(N1/2+.1):N1,ceil(N2/2+.1):N2);
P1=sum(sum(RTF1));               %Power in 1st quadrant
P2=sum(sum(RTF2));               %Power in 2nd quadrant
DSI=(P1-P2)/(P2+P1);
RTF=fliplr(RTF);                 %Flip Back!!!

%Finding bTMF based on Miller Averaging Procedure
MTF=mean(RTF);          %Note that RTF is ^2 so we are dealing with Power
%MTF=MTF-min(MTF);      %Remove DC
Nt=(length(MTF)-1)/2;
Fmb=Fm(Nt+1:2*Nt+1);
tMTF(1)=MTF(Nt+1);
tMTF(2:Nt+1)=(MTF(Nt:-1:1)+MTF(Nt+2:2*Nt+1))/2;
tMTF=tMTF;
i=find(tMTF==max(tMTF));
bTMF=Fmb(i);
cTMF=sum(tMTF.*Fmb)/sum(tMTF);
bwTMF=2*sqrt(sum(tMTF.*(Fmb-cTMF).^2)/sum(tMTF));
tMTFn=tMTF-min(tMTF);                   %Normalized tMTF - DC Removed
ii=find(tMTFn/max(tMTFn)>alpha);        %Estimating Based on values that exceed alpha% of Max
cTMF2=sum(tMTFn(ii).*Fmb(ii))/sum(tMTFn(ii));
bwTMF2=2*sqrt(sum(tMTFn(ii).*(Fmb(ii)-cTMF).^2)/sum(tMTFn(ii)));

%Finding bSMF based on Miller Averaging Procedure
MTF=mean((RTF'));   %Note that RTF is ^2 so we are dealing with Power
%MTF=MTF-min(MTF);   %Remove DC
Ns=(length(MTF)-1)/2;
RDb=RD(Ns+1:2*Ns+1);
sMTF(1)=MTF(Ns+1);
sMTF(2:Ns+1)=(MTF(Ns:-1:1)+MTF(Ns+2:2*Ns+1))/2;
i=find(sMTF==max(sMTF));
bSMF=RDb(i);
cSMF=sum(sMTF.*RDb)/sum(sMTF);
bwSMF=2*sqrt(sum(sMTF.*(RDb-cSMF).^2)/sum(sMTF));
sMTFn=sMTF-min(sMTF);                   %Normalized sMTF - DC Removed
ii=find(sMTFn/max(sMTFn)>alpha);        %Estimating Based on values that exceed alpha% of Max
cSMF2=sum(sMTFn(ii).*RDb(ii))/sum(sMTFn(ii));
bwSMF2=2*sqrt(sum(sMTFn(ii).*(RDb(ii)-cSMF).^2)/sum(sMTFn(ii)));

%Finding Temporal MTF Upper Cutoff (Carefull if DC is removed above)
index=max(find(tMTF==max(tMTF)));
if index<length(tMTF)-1
    k=1;
    while tMTF(index+k)>max(tMTF)/2 & index+k<length(Fmb)
        k=k+1;
    end
    
    if index+k<=length(Fmb)
        FmUpperCutoff=interp1([tMTF(index+k) tMTF(index+k-1)]/max(tMTF),[Fmb(index+k) Fmb(index+k-1)],.5,'linear');
    else
        FmUpperCutoff=max(Fmb);
    end
else
    FmUpperCutoff=max(Fmb);
end

%Finding Temporal MTF Lower Cutoff (Carefull if DC is removed above)
index=min(find(tMTF==max(tMTF)));
if index>1
    k=1;
    while tMTF(index-k)>max(tMTF)/2 & index-k>1
        k=k+1;
    end
    if index-k==1
        FmLowerCutoff=0;
    else
        FmLowerCutoff=interp1([tMTF(index-k) tMTF(index-k+1)]/max(tMTF),[Fmb(index-k) Fmb(index-k+1)],.5,'linear');
    end
else
    FmLowerCutoff=0;
end

%Finding Spectral MTF Upper Cutoff (Carefull if DC is removed above)
index=max(find(sMTF==max(sMTF)));
if index<length(sMTF)-1
    k=1;
    while sMTF(index+k)>max(sMTF)/2 & index+k<length(RDb)
        k=k+1;
    end
    if index+k<=length(Fmb)
        RDUpperCutoff=interp1([sMTF(index+k) sMTF(index+k-1)]/max(sMTF),[RDb(index+k) RDb(index+k-1)],.5,'linear');
    else
        RDUpperCutoff=max(RDb);
    end
else
    RDUpperCutoff=max(RDb);
end

%Finding Spectral MTF Lower Cutoff (Carefull if DC is removed above)
index=min(find(sMTF==max(sMTF)));
if index>1
    k=1;
    while sMTF(index-k)>max(sMTF)/2 & index-k>1
        k=k+1;
    end
    if index-k==1
        RDLowerCutoff=0;
    else
        RDLowerCutoff=interp1([sMTF(index-k) sMTF(index-k+1)]/max(sMTF),[RDb(index-k) RDb(index-k+1)],.5,'linear');
    end
else
    RDLowerCutoff=0;
end

%Assinging Parameters to data structure
TFParam.BestFm=BestFm;
TFParam.BestRD=BestRD;
TFParam.bTMF=bTMF;
TFParam.bSMF=bSMF;
TFParam.cTMF=cTMF;
TFParam.cSMF=cSMF;
TFParam.cTMF2=cTMF2;
TFParam.cSMF2=cSMF2;
TFParam.FmLowerCutoff=FmLowerCutoff;
TFParam.FmUpperCutoff=FmUpperCutoff;
TFParam.RDLowerCutoff=RDLowerCutoff;
TFParam.RDUpperCutoff=RDUpperCutoff;
TFParam.DSI=DSI;
TFParam.Max=Max;
TFParam.bwTMF=bwTMF;
TFParam.bwTMF2=bwTMF2;
TFParam.bwSMF=bwSMF;
TFParam.bwSMF2=bwSMF2;

%Plotting Output If desired
Max=max(max(RTF));
if strcmp(Display,'y')
	figure
	imagesc(Fm,RD,RTF,[0 Max]),shading flat,colormap jet
	hold on
	C=contour(Fm,RD,RTF,[.5 .1]*Max,'k');
	plot(BestFm1,BestRD1,'ko','linewidth',5)
	if Max2>Thresh*Max
		plot(BestFm2,BestRD2,'ko','linewidth',5)
    end
    plot(cTMF*[-1 1],cSMF*[1 1],'k+','linewidth',5)
	set(gca,'Ydir','normal')	
	axis([min(Fm) max(Fm) 0 max(RD)])
	title('Ripple Transfer Function')
	ylabel('RD ( Cycles / Octave )')
	xlabel('Fm ( Hz )')
end
