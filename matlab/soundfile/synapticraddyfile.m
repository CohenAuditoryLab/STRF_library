%
%function []=synapticraddyfile(header,outfile)
%
%       FILE NAME       : SYNAPTIC RADDY FILE
%       DESCRIPTION     : Synaptic Noise Current Signal Generator used by 
%			  Raddy Ramos to test the input-output properties of 
%			  a collection of neurons from a large enseble. Takes
%			  files generated from BATCHSYNAPTICRADDY and generates
%			  a single WAV sound file.
%
%			  Randomizes the order of all stimuli.
%
%	header		: Header for input and output files
%	outfile		: Output File Name (no extension)
%
%RETURNED VARIABLES
%
%(C) Monty A. Escabi, Nov 2005
%
function []=synapticraddyfile(header,outfile)

%Finding Files
File.List=dir(['*' header '*Trial*.mat']);

%Random Sorting 
File.order=[];
count=1;
TempFile.List=dir(['*' 'Raddy' '*Trial' int2strconvert(count,4)  '.mat']);
File.List=dir(['*' 'Raddy' '*Trial*.mat']);
N=size(File.List,1);
while size(TempFile.List,1)~=0
    
    Ntemp=randperm(size(TempFile.List,1));
    for k=1:size(TempFile.List,1)
        for l=1:size(File.List,1)
            if strcmp(TempFile.List(Ntemp(k)).name,File.List(l).name)
               File.order=[File.order l];
               continue
            end
        end
    end
    
    %Updating File Counter
    count=count+1;
    TempFile.List=dir(['*' 'Raddy' '*Trial' int2strconvert(count,4)  '.mat']);

end

%Finding Maximum Amplitude from All Files
Max=-9999;
for k=1:N
	%Loading files
	f=['load ' File.List(k).name];
	eval(f)

	%Finding Max
	Max=max([Max abs(SynapticNoiseX)]);
end

%Opening Output Files
fid=fopen([outfile '.sw'],'wb');

%Appending Signals
Trigger=31000*[ones(1,1000) zeros(1,1000)];
for k=1:N
	
	%Display
	disp(['Appending File: ' File.List(File.order(k)).name])

	%Loading files in random order
	f=['load ' File.List(File.order(k)).name];
	eval(f)

	%250 msec Quiet Period 
	L=round(0.25 * Inputs.Fs);
	S=zeros(1,L);

	%Generating Signal and Interleaving Triggers
	%Double Trigger Interleaved Every 10 Triggers
	%Tripple Trigger At the 10-th Trigger of File
	%Add B-Spline Window Function with 100 msec rise time
	W=window(Inputs.Fs,3,round(length(SynapticNoiseX)/Inputs.Fs*1000-100),100);
	W=[W zeros(1,length(SynapticNoiseX)-length(W))];
	X=round(0.98*1024*32/Max*[SynapticNoiseX.*W S]);
	Trig=zeros(1,length(X));
	if k==10
		Trig(1:6000)=[Trigger Trigger Trigger];
	elseif k/10~=round(k/10) & k~=1
		Trig(1:2000)=Trigger;
	else
		Trig(1:4000)=[Trigger Trigger];
	end
	Y(1:2:length(X)*2)=X;
	Y(2:2:length(X)*2)=Trig;

	%Appending Signal to Output File
	fwrite(fid,Y,'int16');

end

%Appending the Maximum amplitude to File List Information
File.Max=Max;

%Closing All Opened Files
fclose('all');

%Saving File Data Information
f=['save ' header 'FileListInformation File'];
eval(f);

%Converting SW file to WAV file
f=['!sox -r ' num2str(Inputs.Fs) ' -c 2 ' outfile '.sw ' outfile '.wav'];
eval(f)