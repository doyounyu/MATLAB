%% Frequency Sweeper - using lsqcurvefit() for better high frequency performance

clc; clearvars; close all;

dc_offset = 600;    %모터 DC 오프셋
input_amp = 200;

% 텍스트파일 태그 - win-wout-"X.XX"[Hz].txt
% 동시에 출력 주파수 태그이기도 함.
frequency = 0:0.2:3.8;

% 출력 버퍼 생성
output_mag=zeros(1,length(frequency));
output_phase=zeros(1,length(frequency));
count = 1;

for i1 = frequency
    
    filename   =   "win-wout-";
    filename= append(filename,num2str(i1,'%.2f'));
    ext        =   "[Hz].txt";
    
    %파일명 생성
    fullname = append(filename,ext);
    data = readmatrix(fullname);

    input = data(:,2);
    signal = data(:,3)-dc_offset;

    t = data(:,1)/1000; %[ms] to [s]

    fun = @(x, t) x(1)*sin(x(2)*t-x(3));

    x0 = [input_amp, 2*pi*frequency(count), 1];

    x = lsqcurvefit(fun,x0,t,signal)

    output_mag(count)=x(1)/input_amp;
    output_phase(count)=-x(3);
   
    %출력 체크
    % figure;
   % plot(t,signal,'ko',t,fun(x,t),'b-', t, input-600);
     
    title(num2str(i1,'%.2f'))
    count=count+1;
end

%DC의 전달함수 크기와 위상차는 각각 1, 0이라고 가정한다.
 output_mag(1) = 1; 
 output_phase(1) = 0; 



subplot(2,1,1);
semilogx(frequency, mag2db(output_mag), LineWidth=2); 
title('Frequency Response of the motor', FontSize=14,FontWeight="bold");
grid on;
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')



subplot(2,1,2);
semilogx(frequency,rad2deg(output_phase), LineWidth=2);
grid on;
xlabel('Frequency [Hz]')

ylabel(['Phase' '[' char(176) ']'])

%실제 전달함수 계산
b = figure;
tblFreqResp = output_mag .* exp(1i*output_phase) ; %주파수응답 오일러 꼴로 만들어줌
[num, den] = invfreqs(tblFreqResp, 2*pi*frequency, 0, 1); %전달함수 계산
EstTransFunc = tf(num,den) ; 

bode(EstTransFunc)
grid on
