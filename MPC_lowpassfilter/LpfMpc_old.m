function LpfMpc()

Fs = 200e3;
Ts = 1/Fs;
dt=0:Ts:5e-3-Ts;

%3 different frequencies
f1 = 1e3;
f2 = 20e3;
f3 = 30e3;

%combined example signal
y = 5*sin(2*pi*f1*dt) + 5*sin(2*pi*f2*dt) + 10*sin(2*pi*f3*dt);

%plot(dt,y);

%fft signal
nfft = length(y);
nfft2 = 2.^nextpow2(nfft);

fy = fft(y,nfft2);
fy = fy(1:nfft2/2);

xfft = Fs.*(0:nfft2/2-1)/nfft2;

%impluse response LPF

cut_off = 1.5e3/Fs/2;
order = 32;

h = fir1(order,cut_off);

fh = fft(h, nfft2);
fh = fh(1:nfft2/2);

mul = fh.*fy;

con = conv(y,h);

%fft filter plot
subplot(3,2,1)
plot(dt,y);
subplot(3,2,3)
plot(h);
subplot(3,2,5)
plot(con);


subplot(3,2,2)
plot(xfft,abs(fy/max(fy)));
subplot(3,2,4)
plot(xfft,abs(fh/max(fh)));
subplot(3,2,6)
plot(xfft,mul/max(mul));

end

