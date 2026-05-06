clc; clear; close all;

%% Parameters
N = 64;                 
cp_len = 16;            
numSymbols = 500;       
snr_db = 0:2:20;        

M = 4;                  
k = log2(M);            

%% Generate bits
numBits = numSymbols * N * k;
data_bits = randi([0 1], numBits, 1);

%% QPSK Modulation
data_symbols = bi2de(reshape(data_bits, [], k));
modulated = pskmod(data_symbols, M, pi/4);

%% OFDM framing
ofdm_symbols = reshape(modulated, N, []);

%% IFFT (TX OFDM)
ifft_data = ifft(ofdm_symbols, N);

%% Add Cyclic Prefix
cp = ifft_data(end-cp_len+1:end, :);
tx_signal = [cp; ifft_data];
tx_signal = tx_signal(:);   % Serial signal

%% Plot Transmitted Signal (first 200 samples)
figure;
plot(real(tx_signal(1:200)));
grid on;
title('Transmitted OFDM Signal (Time Domain)');
xlabel('Sample Index');
ylabel('Amplitude');

ber = zeros(length(snr_db),1);

%% Loop over SNR
for i = 1:length(snr_db)
    
    % AWGN Channel
    rx_signal = awgn(tx_signal, snr_db(i), 'measured');
    
    % Store one RX signal for plotting (only first SNR)
    if i == 1
        rx_plot = rx_signal;
    end
    
    % Reshape
    rx_matrix = reshape(rx_signal, N+cp_len, []);
    
    % Remove CP
    rx_no_cp = rx_matrix(cp_len+1:end, :);
    
    % FFT
    fft_data = fft(rx_no_cp, N);
    
    % Demodulation
    rx_symbols = fft_data(:);
    demod_data = pskdemod(rx_symbols, M, pi/4);
    
    % Bits
    rx_bits = de2bi(demod_data, k);
    rx_bits = rx_bits(:);
    
    % BER
    [~, ber(i)] = biterr(data_bits, rx_bits);
end

%% Plot Received Signal (first 200 samples)
figure;
plot(real(rx_plot(1:200)));
grid on;
title('Received OFDM Signal (Time Domain, with Noise)');
xlabel('Sample Index');
ylabel('Amplitude');

%% BER Plot
figure;
semilogy(snr_db, ber, 'o-','LineWidth',2);
grid on;
xlabel('SNR (dB)');
ylabel('BER');
title('OFDM BER vs SNR (QPSK)');
