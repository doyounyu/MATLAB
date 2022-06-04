%모터의 2차 전달함수 계수들을 통해 속도 컨트롤러의 PID Gain 산출에 도움을 주는 코드. 
%알파 값(컨트롤러 복소 극점의 wc에 앞에 곱해져서 rc 값을 만드는 계수)을 달리 하면서 원하는 스펙을 표를 통해 산출할 수 있다.  

clc; clearvars; close all;

%모터 상수들
km = 1;
wm = 68;
zm = 0.6;


s = tf('s');

i = 1:0.1:10;
cnt = 1;
zc = 1/sqrt(2);


%버퍼 생성
risebuff = zeros(length(i), 1);
wcbuff = zeros(length(i), 1);
osbuff = zeros(length(i), 1);
pmbuff = zeros(length(i), 1);
gmbuff = zeros(length(i), 1);
disturbbuff = zeros(length(i), 1);

figure('units','normalized','outerposition',[0 0 1 1]) %꽉찬화면

for j = 1:5
    for i= 1:0.1:10
    figure(1)
    a = j;  %알파 값을 달리 하면서 어떤 형태로 주어지는지 확인
    wc = 0.1*wm*i;
    rc = a*wc;
    
    Kp = (wc^2 -wm^2 + 2*zc*wc*rc)/(km*wm^2);
    Ki = (rc*wc^2)/(km*wm^2);
    Kd = (2*zc*wc-2*zm*wm+rc)/(km*wm^2);
    %Open Loop 전달함수
    Go = km*wm^2*(s^2*Kd+s*Kp+Ki)/(s*(s^2+2^zm*wm*s+wm^2));
    %Closed Loop 
    Gcl = (km*wm^2*(Kd*s^2+Kp*s+Ki))/((s+rc)*(s^2+2*zc*wc*s+wc^2));
    
    risebuff(cnt) = stepinfo(Gcl).RiseTime;
    wcbuff(cnt) = wc;
    osbuff(cnt) = stepinfo(Gcl).Overshoot;
    [gmbuff(cnt), pmbuff(cnt)] = margin(Go);

    disturbance = bode( 1/(1+Go), (5));
    disturbbuff(cnt) = mag2db(disturbance);
    cnt = cnt + 1;
    

    end
    subplot(2,3,1)
    plot(wcbuff/wm, risebuff);
    grid on; box on;
    title('Rise time with Different $\alpha$','Interpreter','latex','FontSize',14)
    xlabel('$\omega_n/\omega_m$ [-]','Interpreter','latex','FontSize',14)
    ylabel('$t_{90}$ [s]','Interpreter','latex','FontSize',14)
    legend('\alpha = 1','\alpha = 2','\alpha = 3','\alpha = 4','\alpha = 5')
    xlim([0.1 1])

    hold on;
    subplot(2,3,2)
    plot(wcbuff/wm, osbuff);
    grid on; box on;
    title('\%OS with Different $\alpha$','Interpreter','latex','FontSize',14)
    xlabel('$\omega_n/\omega_m$ [-]','Interpreter','latex','FontSize',14)
    ylabel('\%OS [\%]','Interpreter','latex','FontSize',14)
    legend('\alpha = 1','\alpha = 2','\alpha = 3','\alpha = 4','\alpha = 5')
    xlim([0.1 1])

    subplot(2,3,3)
    plot(wcbuff/wm, mag2db(gmbuff));
    grid on; box on;
    title('Gain Margin with Different $\alpha$','Interpreter','latex','FontSize',14)
    xlabel('$\omega_n/\omega_m$ [-]','Interpreter','latex','FontSize',14)
    ylabel('GM [dB]','Interpreter','latex','FontSize',14)
    legend('\alpha = 1','\alpha = 2','\alpha = 3','\alpha = 4','\alpha = 5')
    ylim([0 20])
    xlim([0.1 1])

    subplot(2,3,4)
    plot(wcbuff/wm, pmbuff);
    grid on; box on;
    title('Phase Margin with Different $\alpha$','Interpreter','latex','FontSize',14)
    xlabel('$\omega_n/\omega_m$ [-]','Interpreter','latex','FontSize',14)
    ylabel('PM [deg]','Interpreter','latex','FontSize',14)
    legend('\alpha = 1','\alpha = 2','\alpha = 3','\alpha = 4','\alpha = 5')
    xlim([0.1 1])
  
    subplot(2,3,5)
    plot(wcbuff/wm, disturbbuff);
        grid on; box on;
    title('Disturbance Rejection Performance $\alpha$','Interpreter','latex','FontSize',14)
    xlabel('$\omega_n/\omega_m$ [-]','Interpreter','latex','FontSize',14)
    ylabel('Magnitude [dB]','Interpreter','latex','FontSize',14)
    legend('\alpha = 1','\alpha = 2','\alpha = 3','\alpha = 4','\alpha = 5')
    xlim([0.1 1])

end
