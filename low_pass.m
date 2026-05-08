%%pkg load signal

%% 1. Carregamento do Áudio
% Lemos o arquivo diretamente para garantir o Fs correto
[sinal, Fs] = audioread('minha_gravacao.wav');

% Garante que o áudio seja mono para facilitar a filtragem
if size(sinal, 2) > 1
    sinal = mean(sinal, 2);
end

%%%%%%%% parametros do Filtro %%%%%%%%%
N = 630;               % Ordem (tamanho) do filtro
M = floor(N / 2);      % M é calculado automaticamente com base no N
fc = 2000;             % Frequência de corte (Hz)

% Frequência de corte normalizada
wc = 2 * pi * (fc / Fs);

%%%%%%%%%%%%%%% Filtro PB (Passa-Baixa) %%%%%%%%%%%%%%
% Equação do filtro passa-baixa ideal
h_0 = wc / pi;
h_positivo = zeros(1, M);
for n=1:M
    h_positivo(n) = sin(wc*n)/(pi*n);
end
h = [fliplr(h_positivo) h_0 h_positivo];

%%%%%%%%%%% Com janela de Kaiser %%%%%%%%%%%%%
beta_kaiser = 5.55; 
w = kaiser(length(h), beta_kaiser)'; 
h = h.*w;

figure;
stem(h);
title('Resposta ao Impulso Passa-Baixa (Janela de Kaiser)');

% Espectro do Filtro (Diagrama de Bode)
h_z = [h zeros(1, 50000)]; % Zero-padding para alta resolução
H = fft(h_z);

% Pegar apenas a primeira metade (Nyquist)
H_mag = abs(H(1:floor(length(H)/2)));

% Normalizar e converter para dB
H_db = 20*log10(H_mag / max(H_mag) + eps); 

% Ajustando o eixo X
f_filter = linspace(0, Fs/2, length(H_mag)); 

figure;
semilogx(f_filter, H_db, 'LineWidth', 1.5);
title('Resposta em Frequência do Filtro Passa-Baixa');
xlabel('Frequência (Hz)');
ylabel('Magnitude (dB)');
grid on; 
xlim([10 Fs/2]);  % Foca a visualização a partir de 10 Hz
ylim([-100 5]);   % Limita o eixo Y para não mostrar ruído de arredondamento numérico

%%%%%%%%%%% Teste no Tempo %%%%%%%%%%%%
figure;
plot(sinal);
title('Sinal Original no Tempo');
xlabel('Amostras');

% Aplica o filtro no áudio
sinal_filtrado = filter(h, 1, sinal);

figure;
plot(sinal_filtrado);
title('Sinal Filtrado no Tempo (Passa-Baixa)');
xlabel('Amostras');

%% Audio filtrado
audiowrite('minha_gravacao_PB.wav', sinal_filtrado, Fs);
disp('Áudio filtrado salvo como "minha_gravacao_PB.wav"');

%% Comparacao dos espectros do Áudio
L = length(sinal); % Tamanho real do arquivo de áudio
f_vector = (0:L-1) * (Fs / L);
f_vector_nyq = f_vector(1:floor(L/2));

SINAL = fft(sinal);
SINAL_FILTRADO = fft(sinal_filtrado);

figure;
plot(f_vector_nyq, abs(SINAL(1:floor(L/2))), 'b');
hold on;
plot(f_vector_nyq, abs(SINAL_FILTRADO(1:floor(L/2))), 'r');
title('Comparação dos Espectros: Original vs Filtrado (PB)');
xlabel('Frequência (Hz)');
ylabel('Magnitude');
legend('Sinal Original', 'Sinal Filtrado');
hold off;