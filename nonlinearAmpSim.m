clear;
close all;
clc;

SignalType = 'AM'; % TI = Temporal Interference, AM = amplitude modulation, carrier = sinewave at fc

%% create AM signal
fs          = 10000;
amp         = 1;
carrierFreq = 220;
modulFreq   = 10;
t           = linspace(0,1,fs);%from 0 to 1

time = linspace(0,1,fs);

modulSignal     = 0.5*sin(fs*2*pi*modulFreq*t) + 0.5;
carrierSignal   = sin(fs*2*pi*carrierFreq*t);
%signalIn        = carrierSignal;

%% temporal interference
f1 = 200;
f2 = 210;

sig1 = sin(fs*2*pi*f1*t);
sig2 = sin(fs*2*pi*f2*t);

switch SignalType
    case 'AM'
        signalIn        = modulSignal.*carrierSignal;
    case 'carrier'
        signalIn = carrierSignal;
    case 'TI'
        signalIn = (sig1+sig2)/2;
end
        
runPlot = figure;
summaryPlot = figure;
%% plot Input signal
coeff = 1;
for iter = 1:6
    
    ampCoeff = [0 0 0 0 0 1 0];
    
    ampCoeff(7-iter) = 1;
    
    figure(runPlot);
    set(gcf, 'position', get(0,'screensize'))
    
    %i = 5e-4;
    %for i = [0 1e-10 1e-9 1e-8 1e-7 1e-6 1e-5 1e-4 1e-3 1e-2 1e-1 1e-0]
    
    subplot(4,3,[1 4]);
    plot(time, signalIn, 'k');
    xlabel('time [sec]');
    ylabel('Amplitude [a.u.]');
    temp = signalIn;
    
    %win = window(@hamming,length(signalIn));
    %signalIn = signalIn.*win';
    
    %% Frequency spectrum of Input signal
    InpComplex          = fft(signalIn);
    Amp2                = abs(InpComplex/length(signalIn));
    InpSpect            = Amp2(1:length(signalIn)/2+1);
    InpSpect(2:end-1)   = 2*InpSpect(2:end-1);
    Freq                = fs*(0:(length(signalIn)/2))/length(signalIn);
    
    InpSpect = power(InpSpect,2);
    
    signalIn = temp;
    
    %% plot Input spectrum
    subplot(4,3,[7 10]);
    plot(Freq,InpSpect, 'k', 'LineWidth', 2); xlim([5 300]);
    set(gca, 'YScale', 'log');
    xlabel('Frequency [Hz]');
    ylabel('Power [a.u.]');
    %% create transfer function
    testInput = [-20:0.1:20];
    
    transF = polyval(ampCoeff, testInput);
    
    formulaString = 'f(V_i_n) = ';
    for i = 1:length(ampCoeff)
        if ampCoeff(i) < 0
            
            if length(ampCoeff)-i == 1
                formulaString = [formulaString, ' - ', num2str(abs(ampCoeff(i))) 'x'];
            elseif length(ampCoeff)-i == 0
                formulaString = [formulaString, ' - ', num2str(abs(ampCoeff(i)))];
            else
                formulaString = [formulaString, ' - ', num2str(abs(ampCoeff(i))) 'x^', num2str(length(ampCoeff)-i)];
            end
            
        elseif i == 1
            formulaString = [formulaString, num2str(abs(ampCoeff(i))) 'x^', num2str(length(ampCoeff)-i)];
        else
            if length(ampCoeff)-i == 1
                formulaString = [formulaString, ' + ', num2str(abs(ampCoeff(i))) 'x'];
            elseif length(ampCoeff)-i == 0
                formulaString = [formulaString, ' + ', num2str(abs(ampCoeff(i)))];
            else
                formulaString = [formulaString, ' + ', num2str(abs(ampCoeff(i))) 'x^', num2str(length(ampCoeff)-i)];
            end
        end
        
    end
    
    
    
    subplot(4,3,[5 8]);
    plot(testInput,transF, 'k', 'LineWidth', 2); hold on; ylim([-10 10]); xlim([-10 10]);
    %plot([-amp amp; -amp amp], [-100 -100; 100 100], 'r--', 'LineWidth', 2);
    %plot([-100 -100; 100 100],[-amp amp; -amp amp], 'r--', 'LineWidth', 2);
    %set(gca, 'XTick', -50:10:50);
    xlabel('Input Voltage');
    ylabel('Output Voltage');
    title(sprintf(['Transfer Function [V_o_u_t = f(V_i_n)]',  '\n', formulaString ]));
    
    %% Evaluate Input signal with transfer function
    %signalOut   = 40*sigmf(signalIn,[0.1 0])-20;
    signalOut   = polyval(ampCoeff, signalIn);
    
    %% plot Output signal
    subplot(4,3,[3 6]);
    plot(time, signalOut, 'k'); ylim([-amp amp]);
    xlabel('time [sec]');
    ylabel('Amplitude [a.u.]');
    %% Frequency spectrum of Output signal
    OutpComplex          = fft(signalOut);
    Amp2                = abs(OutpComplex/length(signalOut));
    OutpSpect            = Amp2(1:length(signalOut)/2+1);
    OutpSpect(2:end-1)   = 2*OutpSpect(2:end-1);
    Freq                = fs*(0:(length(signalOut)/2))/length(signalOut);
    
    OutpSpect = power(OutpSpect,2);
    
    %% plot Output Spectrum
    subplot(4,3,[9 12]);
    plot(Freq,OutpSpect, 'k', 'LineWidth', 2); xlim([5 300]);
    set(gca, 'YScale', 'log');
    xlabel('Frequency [Hz]');
    ylabel('Power [a.u.]');
    
    pause(1)
    
%     figure;
%     plot(Freq,OutpSpect, 'k', 'LineWidth', 2); xlim([5 100]);
%     
    figure(summaryPlot);
    subplot(3,2,iter)
    plot(Freq,OutpSpect, 'k', 'LineWidth', 2); xlim([5 300]); ylim([1e-12 1]);
    set(gca, 'YScale', 'log');
    xlabel('Frequency [Hz]');
    ylabel('Power [a.u.]');
    set(gca, 'FontSize', 14, 'YTick', [1e-10 1e-5 1e-0]);
    box off;
    title(sprintf(['Transfer Function [V_o_u_t = f(V_i_n)]',  '\n', formulaString ]));
end
%delete(h);