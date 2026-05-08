clear
clc

% Dados da gravação
Fs = 44100;
t = 5;

% 1. CORREÇÃO AQUI: Removido o ID '2'. 
% O MATLAB vai usar o microfone padrão automaticamente.
rec = audiorecorder(Fs, 16, 1); 

% Gravação
disp('Pressione Enter para iniciar a gravação...');
pause;
disp('Gravando...');
recordblocking(rec, t);
disp('Fim da gravação.');

% 2. CORREÇÃO AQUI: Extrair os dados da gravação da memória (do objeto 'rec')
% Não use audioread aqui, use getaudiodata!
data = getaudiodata(rec);

% 3. Salvar o áudio em um arquivo .wav (agora sim ele salva o que você gravou)
audiowrite('minha_gravacao.wav', data, Fs);
disp('Arquivo "minha_gravacao.wav" salvo com sucesso.');

% 4. Tocar o áudio gravado (Opcional)
% play(rec); 

% Visualização
figure;
plot(data); % DICA: plot é melhor que stem para visualizar áudios longos
title('Sinal de Áudio Gravado');
xlabel('Amostras');
ylabel('Amplitude');