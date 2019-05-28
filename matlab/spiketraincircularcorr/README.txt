%Procedure for running shuffled correlation and performing significance test



%Computing the shuffled correaltion for the 4 Hz case
Fsd=1000;           %Desired sampling rate for the shuffled correaltion
Fm=ras(11).Fm;      %modulation frequency
Delay=0;            %Always use zero

%Generates a 2-cycle dot raster; in our manuscript we used 4-cycles
FMAxis=ras(11).Fm;
Ncyc=2;     %Number of cycles; change to 4 if you want to use 4 cycles
dT=0;       %You can remove time at the begining of the file to prevent adaptation; In our manuscript I beleive we removed ~ 150 msec; dT=0.15
[RASTERc]=raster2cycleraster(ras(11:20),ras(11).Fm,2,Delay,dT);  %generates a 2-cycle dot raster

%Running shuffled correlogram
Fsd=1000
Delay='y'
NJ=10000
[RData]=rastercircularshufcorrfast(RASTERc,Fsd,Delay,NJ);   %This file computes the shuffled correlogram
RData.Renv=RData.Rshuf;
RData.Fm=Fm;
[REnvParam]=circularshufcorrenvparam(RData);

%Plotting shuffled correlogram, fitted model and dot-raster
subplot(223)
plot(RData.Tau,RData.Rshuf,'k')
hold on
plot(RData.Tau,REnvParam.Rmodel,'r')
hold off
axis([min(RData.Tau) max(RData.Tau) 0 max(RData.Rshuf)*1.25])

%you can display the cycle dot-raster as follows
subplot(221)
[RAS,Fs]=rasterexpand(RASTERc,Fsd,1/Fm*1000*Ncyc);    %This program converts the cycle dot-raster to a matrix
[i,j]=find(RAS);                        %Finds time and trials with spikes
plot(j/Fs*1000,i,'k.')                          %Plotting spikes
xlim([0 1/Fm*1000*Ncyc])
title('4 Hz example') 


%Running shuffled correlogram for Poisson spike train - null hypothesis 
sig=1/Fm*Ncyc*1000;
p=1;
lambdan=0;
[RASTERPoiss]=rasteraddjitterunifcirc(RASTERc,sig,p,lambdan);   %This randomizes the spike times
[RDataPoiss]=rastercircularshufcorrfast(RASTERPoiss,Fsd,Delay,NJ);   %This file computes the shuffled correlogram
RDataPoiss.Renv=RDataPoiss.Rshuf;
RDataPoiss.Fm=Fm;
[REnvParamPoiss]=circularshufcorrenvparam(RDataPoiss);

%Plotting shuffled correlogram and fitted model for Poisson
subplot(224)
plot(RDataPoiss.Tau,RDataPoiss.Rshuf,'k')
hold on
plot(RDataPoiss.Tau,REnvParamPoiss.Rmodel,'r')
hold off
axis([min(RData.Tau) max(RData.Tau) 0 max(RData.Rshuf)*1.25])

%plotting poisson cycle dot-raster
subplot(222)
[RAS,Fs]=rasterexpand(RASTERp,Fsd,1/Fm*1000*Ncyc);    %This program converts the cycle dot-raster to a matrix
[i,j]=find(RAS);                        %Finds time and trials with spikes
plot(j/Fs*1000,i,'k.')                          %Plotting spikes
xlim([0 1/Fm*1000*Ncyc])
title('Poisson - Null hypothesis') 

%Performing significance test - real data vs. poisson spike train
alpha=0.001
flag='REL'
[H,p]=rastercircularshufcorrsigtest(RData,RDataPoiss,alpha,flag)