function Obj = sofaALFE(Obj, fmin, fmax)
% Adaptative Low frequency extention
% DAVI ROCHA CARVALHO @ UFSM NOVEMBER/2020
% Inputs:
%      ~ Obj:   SOFA HRTF
%      ~ fmin:  minimal frequency to be extended (default: 15Hz)
%      ~ fmax:  reference frequency value to be extended until fmin 
%                considering HRTFs are linear on low frequencies (default: 500Hz) 

%% Preprocess
fs = Obj.Data.SamplingRate;
IR = shiftdim(Obj.Data.IR, 2);
N = size(IR, 1);
freq_vec = (0:N/2-1)*fs/N;

%%% prepare extension
if nargin < 3
    fmax = 500;
end
if nargin < 2
    fmin = 15; % minimum freq
end
N_ext = ceil(fs/fmin); % minimum length necessary to contain fmin
if N_ext <= N
    N_ext = N;
    freq_vec_ext = freq_vec;
else
    freq_vec_ext = (0:N_ext/2-1)*fs/N_ext;
end
f500Hz = dsearchn(freq_vec_ext.', fmax); % idx at 500Hz (linear part of HRTFs)


%% interp 
% figure()
ir_interp = zeros(size(IR, 2), size(IR, 3), N_ext);
for k = 1:size(IR, 2)
    for l = 1:size(IR, 3)
        time = [IR(:,k,l); zeros(ceil(N_ext - N), 1)];
        mag = fft(time);
        mag_interp = mag;
        
        % interp baixas freqs
        x = [freq_vec_ext(2),    freq_vec_ext(f500Hz:f500Hz+1)];
        xq = freq_vec_ext(2:f500Hz);
        y_mag = [mag(f500Hz); mag(f500Hz:f500Hz+1)];
        mag_interp(2:f500Hz) = interp1(x, y_mag, xq, 'makima');

        % back to time domain
        ir_interp(k,l,:) = real(ifft(mag_interp, N_ext, 'symmetric'));
        
        %plot
%         semilogx(freq_vec_ext, db(abs(mag(1:N_ext/2)))); hold on
%         semilogx(freq_vec_ext, db(abs(mag_interp(1:N_ext/2)))); hold on 
%         hghg = fft(squeeze(ir_interp(k,l,:)));
%         semilogx(freq_vec_ext, db(abs(hghg(1:N_ext/2)))); hold off
%         legend('original', 'interp', 'ir_fft')
%         pause(1)
    end
end


%% Normalize
ir_interp = ir_interp./max(abs(ir_interp(:))) .* max(abs(IR(:)));

% OUTPUT
Obj_out = Obj;
Obj_out.Data.IR = ir_interp;

end


%% Plot time                       
% figure()
% tx = 0:1/fs:(N-1)/fs;
% tx_ext = 0:1/fs:(N_ext-1)/fs;
% 
% ch = 1;
% k=1;
% % 
% % plot(tx, IR(:,k,ch)); hold on
% % plot(tx_ext(1:N), squeeze(ir_interp(k,ch,1:N))); hold off
% plot(tx_ext, squeeze(ir_interp(k,ch,:))); hold off
% 
% legend('original', 'interp')
% xlabel('Time (ms)')
% ylabel('Amplitude')
%             
% 
% %%% PLOT FREQ
% ch = 1;
% k = 1;
% intr = db(abs(fft(squeeze(ir_interp(k,ch,:)))));
% ori = db(abs(fft(squeeze(Obj.Data.IR(k,ch,:)))));
% semilogx(freq_vec, ori(1:N/2)); hold on
% semilogx(freq_vec_ext, intr(1:N_ext/2));
% legend('original', 'interp')
% xlabel('Time (ms)')
% ylabel('Amplitude')
% 
% 
% %%% Plot ITD
% itd = sofaGetITD(Obj);
% itd2= sofaGetITD(Obj_out);
% figure()
% plot(itd); hold on; plot(itd2);
% legend('original', 'interp')




 