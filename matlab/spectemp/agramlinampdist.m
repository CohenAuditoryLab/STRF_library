%
%function [Time,LinAmp,PDistLin]=agramlinampdist(header,f1,f2,dT,faxis,Fs,Disp,Save,ND)
%
%	FILE NAME 	: AGRAM LIN AMP DIST
%	DESCRIPTION 	: Computes the Time Dependent Spectro-Temporal 
%			  Linear Amplitude Distribution of a Sound from 
%			  the STE Spectrotemporal Envelope File
%
%	header		: Input STE File Name Header
%	f1		: Minimum frequency for contrast measurement
%	f2		: Maximum frequency for contrast measurement
%	dT		: Temporal Window Used to Compute Distribution
%	faxis		: Array of Center Frequencies for Filter Bank
%	Fs		: Modulation Sampling Freqeuncy
%	Disp		: Display output window: 'y' or 'n' ( Default = 'n')
%	Save		: Save to File         : 'y' or 'n' ( Default = 'n')
%	ND		: Polynomial Order: Detrends the local spectrum
%			  by fiting a polynomial of order ND. The fitted 
%			  trend is then removed. If ND==0 then no detrending
%			  is performed. Default==0 (No detrending)
%
%RETUERNED VARIABLES
%	Time		: Time Axis
%	LinAmp		: Linear Amplitude Axis
%	PDistLin	: Time Dependent Probability Distribution of Amp
%
function [Time,LinAmp,PDistLin]=agramlinampdist(header,f1,f2,dT,faxis,Fs,Disp,Save,ND)

%Input Arguments
if nargin<7
	Disp='n';
end
if nargin<8
	Save='n';
end
if nargin<9
	ND=0;
end

%Opening Temporary File
if exist('temp.out')
	!rm temp.out
end
fidt=fopen('temp.out','w');

%Reading First Input Data Block
dN=round(dT*Fs);
Max=5*max(max(xtractagram(header,0,250000)));
[ste]=xtractagram(header,0,dN-1);

%Reading Data and Computing Amplitude Distribution
PP=[];
count=0;
while size(ste,2)==dN & ste~=-1

	%Concatenating N blocks at a time 
	N=50;
	count2=0;
	PP=[];

	while count2<N & size(ste,2)==dN
		%Display Output
		clc
		disp(['Finding Lin Amp Dist for Block: ' num2str(count)])

		%Finding index for f1 and f2
		indexf1=min(find(faxis>f1));
		indexf2=max(find(faxis<f2));

		%Selecting Envelope between f1-f2
		ste=ste(indexf1:indexf2,:);
		f=faxis(indexf1:indexf2);

		%Detrending Local Spectrum If Desired
		if ND>0
			[p,s]=polyfit(f,mean(ste'),ND); 
			[Sfit]=polyval(p,f,s)';
			MeanS=mean(mean(ste'));
			for l=1:size(S,2)
				ste(:,l)=ste(:,l)-Sfit+MeanS;	
			end
		end

		%Computing Time Varying Distribution
		ste=reshape(ste,1,size(ste,1)*size(ste,2));
		[P,LinAmp]=hist(ste,[0:Max/1000:Max]);

		PP=[PP P'/length(ste)];
		LinAmp=LinAmp';

		%Incrementing count variable
		count=count+1;
		count2=count2+1;
	
		%Reading Input Data Array
		[ste]=xtractagram(header,count*dN,(count+1)*dN-1);

		%Displaying output if desired
		if strcmp(Disp,'y')
			if count2>1
				pcolor((1:size(PP,2)),LinAmp,PP)
				caxis([0 max(max(PP))])
				shading flat,colormap jet
				pause(0)
			end		
		end

	end

	%Saving N Block Segments
	fwrite(fidt,reshape(PP,1,size(PP,1)*size(PP,2)),'float');

end

%Reloading PP and Concatenating to PDist
fclose(fidt);
fidt=fopen('temp.out');
PDistLin=[];
PP=fread(fidt,N*length(LinAmp),'float');
PP=reshape(PP,length(LinAmp),length(PP)/length(LinAmp));
while ~feof(fidt)
	PDistLin=[PDistLin PP];
	PP=fread(fidt,N*length(LinAmp),'float');
	PP=reshape(PP,length(LinAmp),length(PP)/length(LinAmp));
end
if size(PP,2)>1
	PDist=[PDist PP];
end

%Normalizing Linear Amplitude Between zero and one
LinAmp=(LinAmp-min(LinAmp))/(max(LinAmp)-min(LinAmp));

%Generating Time Axis
Time=(0:size(PDist,2)-1)*dN/Fs;

%Finding Mean, Std, and Kurtosis Trajectories
[Time,StddB,MeandB,KurtdB]=ampstdmean(Time,LinAmp,PDist);

%Saving Data if Desired
if strcmp(Save,'y') & ND==0

	f=['save ' header '_AgramLinCont Time LinAmp PDistLin StddB MeandB KurtdB f1 f2 dT faxis Fs'];
	if findstr(version,'5.')
		f=[f ' -v4'];
	end
	eval(f);
elseif strcmp(Save,'y') & ND>0

	f=['save ' header '_AgramLinContND' int2str(ND) ' Time LinAmp PDistLin StddB MeandB KurtdB f1 f2 dT faxis Fs'];
	if findstr(version,'5.')
		f=[f ' -v4'];
	end
	eval(f);
end

%Closing all Files
fclose('all');

%Deleting Temporary File
!rm temp.out
