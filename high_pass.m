%%pkg load signal

%% 1. Carregamento do Áudio
% Lemos o arquivo diretamente para garantir o Fs correto (44100 Hz)
[sinal, Fs] = audioread('minha_gravacao.wav');

% Garante que o áudio seja mono para facilitar a filtragem
if size(sinal, 2) > 1
    sinal = mean(sinal, 2);
end

%%%%%%%% parametros do Filtro %%%%%%%%%
N = 630;              % Agora sim, esta é a ordem (tamanho) do filtro
M = floor(N / 2);      % M é calculado automaticamente com base no N
fc = 2000
wc = 2 * pi * (fc / Fs) 

%%%%%%%%%%%%%%% Filtro PA (Passa-Alta) %%%%%%%%%%%%%%
h_0 = 1 - wc/pi;
h_positivo = zeros(1, M);
for n=1:M
    h_positivo(n) = -sin(wc*n)/(pi*n);
end
h = [fliplr(h_positivo) h_0 h_positivo];

%%%%%%%%%%% Com janela de Kaiser %%%%%%%%%%%%%
beta_kaiser = 5.55; 
w = kaiser(length(h), beta_kaiser)'; 
h = h.*w;

figure;
stem(h);
title('Resposta ao Impulso (Janela de Kaiser)');

% Espectro do Filtro
h_z = [h zeros(1, 50000)]; % Aumentar os zeros melhora a resolução visual (zero-padding)
H = fft(h_z);

% Pegar apenas a primeira metade (Nyquist)
H_mag = abs(H(1:floor(length(H)/2)));

% Normalizar o ganho máximo para 0 dB (opcional, mas recomendado para filtros)
% e converter para dB. O 'eps' evita erro de log(0) caso algum valor seja exatamente zero.
H_db = 20*log10(H_mag / max(H_mag) + eps); 

% Ajustando o eixo X do filtro para mostrar em Hz reais
f_filter = linspace(0, Fs/2, length(H_mag)); 

figure;
semilogx(f_filter, H_db, 'LineWidth', 1.5);
title('Resposta em Frequência do Filtro');
xlabel('Frequência (Hz)');
ylabel('Magnitude (dB)');
grid on; % O grid ajuda MUITO a visualizar as quedas de dB

%%%%%%%%%%% Teste no Tempo %%%%%%%%%%%%
%% Comparacao de sinais no tempo
figure;
plot(sinal);
title('Sinal Original no Tempo');
xlabel('Amostras');

sinal_filtrado = filter(h, 1, sinal);

figure;
plot(sinal_filtrado);
title('Sinal Filtrado no Tempo');
xlabel('Amostras');

%% Audio filtrado
audiowrite('minha_gravacao_PA.wav', sinal_filtrado, Fs);
disp('Áudio filtrado salvo como "minha_gravacao_PA.wav"');

%% Comparacao dos espectros
% CORREÇÃO: O eixo de frequências precisa ter o mesmo tamanho da FFT do áudio
L = length(sinal); % Tamanho real do arquivo de áudio
f_vector = (0:L-1) * (Fs / L);
f_vector_nyq = f_vector(1:floor(L/2));

SINAL = fft(sinal);
SINAL_FILTRADO = fft(sinal_filtrado);

figure;
plot(f_vector_nyq, abs(SINAL(1:floor(L/2))), 'b');
hold on;
plot(f_vector_nyq, abs(SINAL_FILTRADO(1:floor(L/2))), 'r');
title('Comparação dos Espectros: Original vs Filtrado');
xlabel('Frequência (Hz)');
ylabel('Magnitude');
legend('Sinal Original', 'Sinal Filtrado');
hold off;