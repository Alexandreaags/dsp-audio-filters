%%pkg load signal

%% 1. Carregamento do Áudio
[sinal, Fs] = audioread('minha_gravacao.wav');
if size(sinal, 2) > 1
    sinal = mean(sinal, 2);
end

%% 2. Parâmetros do Filtro Passa-Baixa (IIR)
Rp = 1;  % Ripple máximo na banda de passagem (dB)
Rs = 60; % Atenuação mínima na banda de rejeição (dB)
fp = 2000; % Frequência de passagem (Hz)
fs_stop = 4000; % Frequência de rejeição (1 oitava acima)

% Pré-distorção para Bilinear
wd_p = fp / (Fs/2) * pi;
wa_p = 2 * Fs * tan(wd_p/2);

wd_s = fs_stop / (Fs/2) * pi;
wa_s = 2 * Fs * tan(wd_s/2);

%% 3. Projeto Analógico e Bilinear
[M, wc] = cheb1ord(wa_p, wa_s, Rp, Rs, 's');
[sb, sa] = cheby1(M, Rp, wc, 'low', 's');
[zb, za] = bilinear(sb, sa, 1/Fs);

%% 4. Resposta em Frequência
figure;
freqz(zb, za, 10000, Fs);
title('Resposta em Frequência - Passa-Baixa (IIR)');

%% 5. Teste no Tempo e Filtragem
sinal_filtrado = filter(zb, za, sinal);

figure;
subplot(2,1,1);
plot(sinal);
title('Sinal Original no Tempo');
subplot(2,1,2);
plot(sinal_filtrado);
title('Sinal Filtrado no Tempo (Passa-Baixa IIR)');

audiowrite('minha_gravacao_IIR_PB.wav', sinal_filtrado, Fs);
disp('Áudio salvo como "minha_gravacao_IIR_PB.wav"');

%% 6. Comparação dos Espectros
L = length(sinal); 
f_vector = (0:L-1) * (Fs / L);
f_vector_nyq = f_vector(1:floor(L/2));
SINAL = fft(sinal);
SINAL_FILTRADO = fft(sinal_filtrado);

figure;
plot(f_vector_nyq, abs(SINAL(1:floor(L/2))), 'b');
hold on;
plot(f_vector_nyq, abs(SINAL_FILTRADO(1:floor(L/2))), 'r');
title('Espectros: Original vs Filtrado (Passa-Baixa IIR)');
xlabel('Frequência (Hz)');
ylabel('Magnitude');
legend('Sinal Original', 'Sinal Filtrado');
xlim([0 6000]); % Foco na transição
hold off;