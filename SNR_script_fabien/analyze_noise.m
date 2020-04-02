function [code, SNR_min, SNR_max, RMS,WN] = analyze_noise(noise,signal,fr_length, SNR_lim,RMS_lim,WN_lim,fig)
%Analyze noise from FAT
%Discriminate noise source from single burst measurement on FAT
%between correlated noise (ringing) and white noise.
%
%FAES
%19/09/2017
%
% Function inputs:
%   - noise:     vector containing noise to be analyzed (normalized relative to the signal) 
%   - signal:    vector containing entire signal from which the noise has been extracted
%                signal must be normalized
%   - fr_length: frame length (in sample) dividing noise in N frames
%                if length(noise) / fr_length is not an integer, the last
%                frame will be zero padded (not changing SNR calculation)
%   - SNR_lim:   limit value of the SNR between OK and FAILURE
%   - RMS_lim:   limit value between correlated and uncorrelated noise
%   - WN_lim:    limit value between low and high white noise
%   - fig:       optional figure display (= 1) or not (= 0) 
%
% Function outputs:
%   - code: noise type code =  0 => no noise
%                           =  1 => low ringing
%                           =  2 => medium white noise
%                           =  3 => medium ringing
%                           =  4 => medium white noise and ringing
%                           =  5 => high white noise
%                           =  6 => high ringing
%                           =  7 => high white noise and ringing
%                           =  8 => white noise detected (shall not happen)
%                           =  9 => one low SNR detected (shall not happen)
%                           = 10 => two low SNR detected (shall not happen)
%                           = -1 => not discriminated (shall not happen)
%                  
%   - SNR_min: minimum SNR value (based on noise local max value)
%   - SNR_max: maximum SBR value (based on noise local min value)
%   - RMS:     RMS value of the noise autocorrelation
%   - WN:      white noise ground floor of the noise FFT (at Fs/2)

if nargin < 6
    error('Function requires 6 mandatory inputs. Please refer to help to parametrize correctly')
end

if iscolumn(noise)  %make sure noise is a row vector
    noise = noise';
end

signal_pp = max(signal) - min(signal); %signal max peak to peak value

%Noise framing:
nl = length(noise); %noise length
if rem(nl,fr_length) ~= 0
    z  = fr_length - rem(nl,fr_length); %nr of zero to pad noise to have fixed length frames
    noise =  [noise zeros(1,z)];        %pad z zeros at the end of noise (z = 0 if not required)
    nl = nl + z;
end
nr_frame = nl / fr_length;

%Separate noise in frames:
for n = 1:nr_frame
    [noise_max(n),ind_max(n)] = max(noise((1:fr_length) + (n-1)*fr_length)); %Frame noise max
    [noise_min(n),ind_min(n)] = min(noise((1:fr_length) + (n-1)*fr_length)); %Frame noise min
    noise_max_ind(n) = (n-1)*fr_length + ind_max(n);                         %index of the frame local max
    noise_min_ind(n) = (n-1)*fr_length + ind_min(n);                         %index of the frame local min
    noise_pp(n)  = noise_max(n) - noise_min(n);                              %Frame noise peak to peak value
    SNR(n) = 20*log10(signal_pp/noise_pp(n));                                %Frame SNR
end

SNR_min = min(SNR); %noise min/max SNR
SNR_max = max(SNR);

%Autocorrelation:
xc = conv(noise,fliplr(noise)); %correlation
xc = xc / max(xc); %normalization

RMS = sqrt(sum(xc.^2)); %RMS value of correlation

%FFT analysis:
Xn = 20*log10(abs(fft(noise)/length(noise))); %FFT magnitude
WN = Xn(round(nl/2)+1);                       %Value at Fs/2

%Noise discrimination:
if    (SNR_min > SNR_lim) && (RMS < RMS_lim) && (WN < WN_lim)                        % high SNR + low corr + low WN
    t = ['No noise'];
    code = 0;
elseif (SNR_min > SNR_lim) && (RMS < RMS_lim)&& (WN > WN_lim)                        % high SNR + low corr + high WN
    t = ['High WN detected(?)'];
    code = 8;
elseif (SNR_min > SNR_lim) && (RMS > RMS_lim)&& (WN < WN_lim)                        % high SNR + high corr + low WN
    t = ['Low ringing'];
    code = 1;
elseif (SNR_min > SNR_lim) && (RMS > RMS_lim)&& (WN > WN_lim)                        % high SNR + high corr + high WN
    t = ['Low ringing'];
    code = 1;
elseif (SNR_min < SNR_lim) && (SNR_max > SNR_lim) && (RMS < RMS_lim)&& (WN < WN_lim) % 1x low SNR + low corr + low WN
    t = ['One low SNR detected(?)'];
    code = 9;
elseif (SNR_min < SNR_lim) && (SNR_max > SNR_lim) && (RMS < RMS_lim)&& (WN > WN_lim) % 1x low SNR + low corr + high WN
    t = ['Medium WN'];
    code = 2;
elseif (SNR_min < SNR_lim) && (SNR_max > SNR_lim) && (RMS > RMS_lim)&& (WN < WN_lim) % 1x low SNR + high corr + low WN
    t = ['Medium ringing'];
    code = 3;
elseif (SNR_min < SNR_lim) && (SNR_max > SNR_lim) && (RMS > RMS_lim)&& (WN > WN_lim) % 1x low SNR + high corr + high WN
    t = ['Medium WN and ringing'];
    code = 4;
elseif (SNR_min < SNR_lim) && (SNR_max < SNR_lim) && (RMS < RMS_lim)&& (WN < WN_lim) % 2x low SNR + low corr + low WN
    t = ['Two low SNR detected(?)'];
    code = 10;
elseif (SNR_min < SNR_lim) && (SNR_max < SNR_lim) && (RMS < RMS_lim)&& (WN > WN_lim) % 2x low SNR + low corr + high WN
    t = ['High WN'];
    code = 5;
elseif (SNR_min < SNR_lim) && (SNR_max < SNR_lim) && (RMS > RMS_lim)&& (WN < WN_lim) % 2x low SNR + high corr + low WN
    t = ['High ringing'];
    code = 6;
elseif (SNR_min < SNR_lim) && (SNR_max < SNR_lim) && (RMS > RMS_lim)&& (WN > WN_lim) % 2x low SNR + high corr + high WN
    t = ['High WN and ringing'];
    code = 7;
else
    t = ['Unknown']; %
    code = -1
end
    
%Optional plotting:
if fig == 1
    figure
    subplot(2,2,1)
    hold on
    plot(signal)
    hold off
    title('Signal')
    
    subplot(2,2,2)
    hold on
    plot(noise)
    plot(noise_max_ind,noise_max,'-r.')
    plot(noise_min_ind,noise_min,'-r.')
    for n = 1:nr_frame
        plot([n*fr_length n*fr_length],[1 -1],':r')
    end
    t = strvcat(t,['Code = ' num2str(code)]);
    t = strvcat(t,[' ']);
    t = strvcat(t,['SNR min = ' num2str(SNR_min,3) 'dB']);
    t = strvcat(t,['SNR max = ' num2str(SNR_max,3) 'dB']);
    text(0,max(abs(noise))*1.2,t,'VerticalAlign','Top')
    hold off
    axis([0 nl max(abs(noise))*[-1.2 1.2]])
    title('Noise')
    
    subplot(2,2,3)
    hold on
    plot(xc)
    text(0,1,['Correlation RMS = ' num2str(RMS,2)],'VerticalAlign','Top');
    title('Noise autocorrelation')
    
    subplot(2,2,4)
    hold on
    plot(Xn)
    hold off
    text(nl/2,WN+5,['WN = ' num2str(WN,3) 'dB'],'HorizontalAlign','Center');
    title('Noise FFT')
end
