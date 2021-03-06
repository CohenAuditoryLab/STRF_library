%
%function [fighandle]=plotrtfhists(filename,SoundCh,FMMax,RDMax)
%
%       FILE NAME       : PLOT RTF HISTS
%       DESCRIPTION     : Plots all the RTFHs from a given spike file 
%			  sequence 
%
%	filename	: Input RTFHist file name
%	SoundCh		: Sound Channel Number ( 1 or 2 or [1 2] )
%			  Default: SoundCh = 1
%
%OPTIONAL
%	FMMax		: Maximum Temporal Modulation Rate ( Hz )
%			  Default = Taken from RTFHist File
%	RDMax		: Maximum Ripple Density ( Cycles / Octave )
%			  Default = Taken from RTFHist File
%
function [fighandle]=plotrtfhists(filename,SoundCh,FMMax,RDMax)

%Input Arguments
if nargin<2
	SoundCh=1;
end

%Preliminaries
more off

%Loading Data files
index=findstr(filename,'_u');
SpikeFile=filename(1:index-1);
f=['load ' SpikeFile];
eval(f);

%Finding All Non-Outlier Spet Variables
count=-1;
while exist(['spet' int2str(count+1)])
	count=count+1;
end
Nspet=(count+1)/2;

%Number of Subplots
if Nspet<=4
	L1=2;
	L2=2;
	Height=.35;
elseif Nspet<=6
	L1=3;
	L2=2;
	Height=.18;
else
	L1=3;
	L2=3;
	Height=.18;
end

if length(SoundCh)==1

	%Setting Figure and PaperPosition
	fighandle=figure('Name',...
		['RTFHs for ' SpikeFile ', Sound Channel ' int2str(SoundCh)],...
		'NumberTitle','off');
	set(fighandle,'position',[400,200,600,500],'paperposition',...
		[.25 1.5  8 8.5]);

	%Plotting RTFHs
	for k=0:Nspet-1

			%Loading RTFH Files
			f=['load ' filename];
			f(5+index+2)=int2str(k);
			eval(f);	

			%Input Arguments
			if nargin<3
				FMMax=max(abs(FM));
			end
			if nargin<4
				RDMax=max(RD);
			end

			if SoundCh==2
				%Plotting RTFH - Sound Channel 2
				s=subplot(L1,L2,k+1);
				Pos=get(s,'Position');,Pos(4)=Height;
				set(s,'Position',Pos);
				pcolor(-FM,RD,N2),...
				colormap jet, colorbar
				set(gca,'Ydir','normal')
				axis([-FMMax FMMax 0 RDMax])
				title(['U=' int2str(k) , ...
				', No=' int2str(sum(sum(N2)))])
			else
				%Plotting RTFH - Sound Channel 1
				s=subplot(L1,L2,k+1);
				Pos=get(s,'Position');,Pos(4)=Height;
				set(s,'Position',Pos);
				pcolor(-FM,RD,N1),...
				colormap jet, colorbar
				set(gca,'Ydir','normal')
				axis([-FMMax FMMax 0 RDMax])
				title(['U=' int2str(k) , ...
				', No=' int2str(sum(sum(N1)))])
			end

	end
	hold off

elseif length(SoundCh)==2

	if nargin<3
		[fighandel1]=plotrtfhists(filename,SoundCh(1));
		[fighandel2]=plotrtfhists(filename,SoundCh(2));
	elseif nargin<4
		[fighandel1]=plotrtfhists(filename,SoundCh(1),FMMax);
		[fighandel2]=plotrtfhists(filename,SoundCh(2),FMMax);
	else
		[fighandel1]=plotrtfhists(filename,SoundCh(1),FMMax,RDMax);
		[fighandel2]=plotrtfhists(filename,SoundCh(2),FMMax,RDMax);
	end
	fighandel=[fighandel1 fighandel2];

end
