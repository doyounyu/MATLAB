%% Frequency Sweeper

clc; clearvars; close all;

dc_offset = 600;    %모터 DC 오프셋


% 텍스트파일 태그 - win-wout-"X.XX"[Hz].txt
% 동시에 출력 주파수 태그이기도 함.
frequency = 0:0.2:3.8;

% 출력 버퍼 생성
output=zeros(1,length(frequency));
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
    phase = angle(fft(signal));
    ly = length(signal);
    mag =  2*mag/ly ;
    
    f = (-ly/2:ly/2-1)/ly*fs;
    [max_mag, max_freq_index] = max(mag);
    output(count)=max_mag;
    count=count+1;
end

 

semilogx(frequency(2:end), output(2:end), LineWidth=2);
    title('Frequency Response of the motor', FontSize=14,FontWeight="bold");

grid on;
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
