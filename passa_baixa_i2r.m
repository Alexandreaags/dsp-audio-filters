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
%% 4. Resposta em Frequência (Escala Logarítmica)
% Extrai os dados de frequência (f) e resposta complexa (H)
[H, f] = freqz(zb, za, 10000, Fs);

% Calcula a magnitude em dB (normalizada para 0 dB no pico máximo)
H_db = 20*log10(abs(H) / max(abs(H)) + eps);

figure;
semilogx(f, H_db, 'LineWidth', 1.5, 'b');
% Altere o título abaixo conforme o filtro (Passa-Alta, Rejeita-Faixa ou Passa-Baixa)
title('Resposta em Frequência (IIR)'); 
xlabel('Frequência (Hz) - Escala Logarítmica');
ylabel('Magnitude (dB)');
grid on;

% Define os limites do gráfico para visualização ideal do Bode
xlim([10 Fs/2]); % Inicia em 10Hz para evitar erro de log(0) e vai até Nyquist
ylim([-100 5]);  % Limita o Y para focar no ripple e na atenuação de 60 dB

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