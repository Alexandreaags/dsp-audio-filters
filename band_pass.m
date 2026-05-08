clear
clc
close all
%%pkg load signal
%%%%%%%% parametros %%%%%%%%%
Fs = 1e3;
N = 500;
M = 200;
wc1 = pi/5;
wc2 = pi/3;
t=0:N-1;
t=t/Fs;
%%%%%%%%%%%%%%% Filtro PF %%%%%%%%%%%%%%
h_0 = (wc2-wc1)/(pi);
for n=1:M
h_positivo(n) = sin(wc2*n)/(pi*n) - sin(wc1*n)/(pi*n);
end
h = [fliplr(h_positivo) h_0 h_positivo];
figure
stem(h)
%preenchimento com zeros - somente para visualizar
%melhor o espectro
h_z = [h zeros(1,50)];
H = fft(h_z);
f_filter = linspace(0,1,length(h_z)/2)
figure
plot(f_filter, abs(H(1:length(H)/2)));
%%%%%%%%%%% Com janela %%%%%%%%%%%%%
w = window(@hann, length(h))';
h = h.*w;
figure
stem(h);
h_z = [h zeros(1,50)];
H = fft(h_z);
figure
plot(abs(H(1:length(H)/2)));
%%%%%%%%%%% teste %%%%%%%%%%%%
%% Comparao de sinais exemplo no tempo
sinal = sin(2*pi*20*t) + 0.2*sin(2*pi*400*t) + sin(2*pi*120*t)
figure;
plot(sinal)
figure
sinal_filtrado = filter(h,1,sinal)
plot(sinal_filtrado)
%% Comparao dos espectros
f_vector=0:N-1;
f_vector = f_vector*Fs/N;
f_vector_nyq = f_vector(1:length(f_vector)/2);
figure
SINAL = fft(sinal);
plot(f_vector_nyq, abs(SINAL(1:length(SINAL)/2)));
hold
SINAL_FILTRADO = fft(sinal_filtrado);
plot(f_vector_nyq, abs(SINAL_FILTRADO(1:length(SINAL_FILTRADO)/2)));
