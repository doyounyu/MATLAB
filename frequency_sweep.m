%% Frequency Sweeper

clc; clearvars; close all;

dc_offset = 600;    %모터 DC 오프셋


% 텍스트파일 태그 - win-wout-"X.XX"[Hz].txt
% 동시에 출력 주파수 태그이기도 함.
frequency = 0:0.2:3.8;

% 출력 버퍼 생성
output_mag=zeros(1,length(frequency));
output_phase=zeros(1,length(frequency));
count = 1;

for i1 = 0:0.2:3.8
    
    filename   =   "win-wout-";
    filename= append(filename,num2str(i1,'%.2f'));
    ext        =   "[Hz].txt";
    
    %파일명 생성
    fullname = append(filename,ext);
    data = readmatrix(fullname);

    input = data(:,2);
    
    t = data(:,1);
    fs = 1/((t(2)-t(1)))*1000; % sampling freq
    signal = smoothdata(data(:,3), 'rloess'); %이 method가 가장 유지를 잘하고 필터링함.
    signal = signal - 600; %DC 빼주기

    mag = abs(fftshift(fft(signal)));

    phase = angle(fftshift(fft(signal)));

    tol = 1e-6;
    
    phase(abs(phase) < tol) = 0;

    ly = length(signal);

    %스케일링
    mag =  2*mag/ly ;
 
    
    %반토막 날리기
    mag =  mag(end/2:end) ;
    phase = phase(end/2:end) ;

    f = (-ly/2:ly/2-1)/ly*fs;

    [max_mag, max_freq_index] = max(mag);
    max_phase = phase;

    output_mag(count)=max_mag;
    output_phase(count)=max_phase;

    count=count+1;
end
output_phase(1) = -pi/2; %DC에는 위상차 없다..
 
a = figure;
subplot(2,1,1);
semilogx(frequency, mag2db(output_mag/600), LineWidth=2); %입력의 크기가 600이므로, 전달함수를 구하기 위해 출력/입력 해줌
title('Frequency Response of the motor', FontSize=14,FontWeight="bold");
grid on;
xlabel('Frequency [Hz]')
ylabel(['Phase' '[' char(176) ']'])


subplot(2,1,2);
semilogx(frequency, rad2deg(output_phase)+90, LineWidth=2);
grid on;
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
