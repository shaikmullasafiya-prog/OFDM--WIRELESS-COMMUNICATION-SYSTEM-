clc;
clear;
close all;

% Step 1: Generate random data
N = 1000;
data = randi([0 1], 1, N);

% Step 2: QPSK Modulation
data_reshaped = reshape(data, 2, []);
symbols = data_reshaped(1,:) + 1i*data_reshaped(2,:);

% Step 3: OFDM (IFFT)
ofdm_signal = ifft(symbols);

% Step 4: Add Noise (AWGN)
snr = 10;
noisy_signal = awgn(ofdm_signal, snr, 'measured');

% Step 5: Receiver (FFT)
received_symbols = fft(noisy_signal);

% Step 6: Demodulation
received_bits = zeros(1, N);
received_bits(1:2:end) = real(received_symbols) > 0;
received_bits(2:2:end) = imag(received_symbols) > 0;

% Step 7: BER Calculation
errors = sum(data ~= received_bits);
ber = errors / N;

% Display result
disp(['Bit Error Rate (BER): ', num2str(ber)]);
