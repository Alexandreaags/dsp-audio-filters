%%pkg load signal

%% 1. Carregamento do Áudio
[sinal, Fs] = audioread('minha_gravacao.wav');
if size(sinal, 2) > 1
    sinal = mean(sinal, 2);
end

%% 2. Parâmetros do Filtro Rejeita-Faixa (IIR)
Rp = 1;  % Ripple na passagem (dB)
Rs = 60; % Atenuação na rejeição (dB)
fp1 = 250;  fp2 = 2000; % Frequências onde a passagem termina e recomeça
fs1 = 500;  fs2 = 1000; % Frequências da banda de rejeição (1 oitava para dentro)

% Pré-distorção para Bilinear
Wd_p = [fp1, fp2] / (Fs/2) * pi;
Wa_p = 2 * Fs * tan(Wd_p/2);

Wd_s = [fs1, fs2] / (Fs/2) * pi;
Wa_s = 2 * Fs * tan(Wd_s/2);

%% 3. Projeto Analógico e Bilinear
[M, wc] = cheb1ord(Wa_p, Wa_s, Rp, Rs, 's');
[sb, sa] = cheby1(M, Rp, wc, 'stop', 's');
[zb, za] = bilinear(sb, sa, 1/Fs);

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
title('Sinal Filtrado no Tempo (Rejeita-Faixa IIR)');

audiowrite('minha_gravacao_IIR_RF.wav', sinal_filtrado, Fs);
disp('Áudio salvo como "minha_gravacao_IIR_RF.wav"');

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
title('Espectros: Original vs Filtrado (Rejeita-Faixa IIR)');
xlabel('Frequência (Hz)');
ylabel('Magnitude');
legend('Sinal Original', 'Sinal Filtrado');
xlim([0 3000]); % Foco nas bandas de corte
hold off;