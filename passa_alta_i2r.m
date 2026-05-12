%%pkg load signal

%% 1. Carregamento do Áudio
% Lemos o arquivo diretamente para garantir o Fs correto (44100 Hz)
[sinal, Fs] = audioread('minha_gravacao.wav');

% Garante que o áudio seja mono para facilitar a filtragem
if size(sinal, 2) > 1
    sinal = mean(sinal, 2);
end

%%%%%%%% Parâmetros do Filtro IIR (Passa-Alta) %%%%%%%%%
% Em IIR, definimos exatamente as duas bordas para cravar a 1 oitava
Fpass = 2000; % Início da banda de passagem (Hz)
Fstop = 1000; % Fim da banda de rejeição (Hz) -> Exatamente 1 oitava abaixo!

Apass = 0.5;    % Ripple máximo permitido na banda de passagem (dB)
Astop = 60;   % Atenuação mínima na banda de rejeição (dB)

% Normalizando as frequências por Nyquist (Fs/2)
Wp = Fpass / (Fs/2);
Ws = Fstop / (Fs/2);

%%%%%%%%%%%%%%% Projeto do Filtro IIR (Elíptico) %%%%%%%%%%%%%%
% 1. Calcula a ordem mínima (N) necessária para atender aos seus critérios
[N_ordem, Wn] = ellipord(Wp, Ws, Apass, Astop);

% 2. Gera os coeficientes 'b' (numerador) e 'a' (denominador) do filtro
[b, a] = ellip(N_ordem, Apass, Astop, Wp, 'high');

% Exibe a ordem no terminal para você ver a diferença de eficiência
fprintf('Ordem do filtro IIR projetado: %d\n', N_ordem);

%%%%%%%%%%% Resposta ao Impulso %%%%%%%%%%%%%
% Diferente do FIR, o IIR é infinito. Simulamos injetando um impulso [1 0 0 0...]
impulso = [1; zeros(99, 1)]; 
h_impz = filter(b, a, impulso);

figure;
stem(0:99, h_impz);
title('Resposta ao Impulso IIR (Primeiras 100 amostras)');
xlabel('Amostras');
ylabel('Amplitude');

%%%%%%%%%%% Espectro do Filtro (Diagrama de Bode) %%%%%%%%%%%%%
% A função freqz calcula a resposta em frequência diretamente dos coeficientes
[H, f_filter] = freqz(b, a, 50000, Fs);

H_mag = abs(H);
H_db = 20*log10(H_mag + eps); 

figure;
semilogx(f_filter, H_db, 'LineWidth', 1.5);
title('Resposta em Frequência do Filtro IIR (Passa-Alta)');
xlabel('Frequência (Hz)');
ylabel('Magnitude (dB)');
grid on;
xlim([10 Fs/2]);
ylim([-100 5]);

%%%%%%%%%%% Teste no Tempo %%%%%%%%%%%%
%% Comparacao de sinais no tempo
figure;
plot(sinal);
title('Sinal Original no Tempo');
xlabel('Amostras');

% A filtragem IIR usa tanto 'b' quanto 'a'
sinal_filtrado = filter(b, a, sinal);

figure;
plot(sinal_filtrado);
title('Sinal Filtrado no Tempo (IIR)');
xlabel('Amostras');

%% Audio filtrado
audiowrite('minha_gravacao_PA_IIR.wav', sinal_filtrado, Fs);
disp('Áudio filtrado salvo como "minha_gravacao_PA_IIR.wav"');

%% Comparacao dos espectros
L = length(sinal); 
f_vector = (0:L-1) * (Fs / L);
f_vector_nyq = f_vector(1:floor(L/2));

SINAL = fft(sinal);
SINAL_FILTRADO = fft(sinal_filtrado);

figure;
plot(f_vector_nyq, abs(SINAL(1:floor(L/2))), 'b');
hold on;
plot(f_vector_nyq, abs(SINAL_FILTRADO(1:floor(L/2))), 'r');
title('Comparação dos Espectros: Original vs Filtrado (IIR)');
xlabel('Frequência (Hz)');
ylabel('Magnitude');
legend('Sinal Original', 'Sinal Filtrado');
hold off;