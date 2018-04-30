
[ori,fs]=audioread('4OnMyOwn_Lofi_.wav');
maxbeat=200; %bpm
mineval=fs/(maxbeat/60);

mono=sum(ori,2);%unscaled mono track
t=linspace(0,numel(mono)/fs,numel(mono));
[a,d]=dwt(mono,'sym1');
zcs=boolean(zeros(size(d)));
for i=2:numel(zcs) 
    %find each peak so we don't wind up with stupid data
    %sound crosses 0 a lot
    zcs(i)=(d(i)>0&&d(i-1)<0)||(d(i)<0&&d(i-1)>0);
end

%begin and end also edges of the waveform
allzcs=[1,find(zcs)',numel(zcs)]; 

absd=abs(d);

peaks = zeros(size(allzcs,1)-1,1);
peaklocs=peaks;
beats=peaks; %only debugging
beatlocs=peaks;
for i=1:numel(allzcs)-1
    wavesect=absd(allzcs(i):allzcs(i+1));
    [peaks(i),idx]=max(wavesect);
    peaklocs(i)=idx+allzcs(i)-1;
end

stdev=std(peaks);
locs=peaklocs(peaks>6*stdev);
i=1;
j=1;
k=1;
while i<numel(locs)
    currentbeat=0;
    while (i<numel(locs)-1)&&(locs(i)+(mineval/2)>locs(i+1))
        if absd(locs(i))>currentbeat
            currentbeatloc=locs(i);
            allmaxes(k)=locs(i);
            k=k+1;
            currentbeat=absd(currentbeatloc);
        end
        i=i+1;
    end
    beats(j)=currentbeat;
    beatlocs(j)=currentbeatloc;
    j=j+1;
    i=i+1;
end
figure
hold on
plot(absd)
plot (beatlocs,beats,'ro');
hold off
beattimes=beatlocs/fs;
beatinterval=beattimes;
beatinterval(2:end)=beatinterval(2:end)-beatinterval(1:end-1);

%peak not being detected