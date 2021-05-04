classdef Infinite_Reverb < audioPlugin
    %#codegen
    %% 変数の作成
    properties
       n = 0;                   %位置
       x_buff = zeros(8192,2);  %入力バッファ
       y_buff = zeros(8192,2);  %出力バッファ
       
       s_buff = zeros(8192,2); %オシレーターバッフア
       s = 0;
       
       spectrum_buff = zeros(8192/2,2);
       amp_db = 0;
       
       sustain = 1
       low = 1;
       high = 1;
       init_att = 0;
    
    end
    
   %% UIの設定
    properties (Constant)
        PluginInterface = ...
            audioPluginInterface( ...
                audioPluginParameter('sustain', ...
                'DisplayName', 'Sustain', ...
                'Label', '%/s', ...
                'Mapping', { 'lin', 0, 1}),  ...
                audioPluginParameter('low', ...
                'DisplayName', 'Sustain (Low Freq)', ...
                'Label', '%/s', ...
                'Mapping', { 'lin', 0, 1}), ...
                audioPluginParameter('high', ...
                'DisplayName', 'Sustain (High Freq)', ...
                'Label', '%/s', ...
                'Mapping', { 'lin', 0, 1}), ...
                audioPluginParameter('init_att', ...
                'DisplayName', 'Initial Attenuation', ...
                'Label', '', ...
                'Mapping', { 'lin', 0, 10}), ...
                audioPluginParameter('amp_db', ...
                'DisplayName', 'Amp', ...
                'Label', '', ...
                'Mapping', { 'lin', -40, 0}))
    end
    
    %%パラメタの設定
    properties(Constant)
        n_fft       = 8192;     %fft幅
        n_shift     =  128;      %シフト幅
    end
    
    %% メソッド
    methods
            
        function y_frame = process(p, x_frame)
          %% ループの準備
            %フレームサイズの取得
            frame_size = length(x_frame);
            
            %サンプリング周波数の取得
            Fs = getSampleRate(p);
            
            %出力フレームの用意
            y_frame = zeros(frame_size,2);
            
          %% メインループ
            for i = 1:frame_size
                %OSCを進める
                p.s_buff(p.n,:) = (2*rand(1,2)-1)*0.01;
                
              %% バッファの入出力とステップの進行
                p.x_buff(p.n,:) = x_frame(i,:);
                y_frame(i,:) = p.y_buff(max(1,p.n-p.n_fft/2),:).*10^(p.amp_db/20);
                p.n = p.n + 1;

             %% バッファが十分に満たされたら
               if p.n == p.n_fft
                    %FFTして負の周波数を無視
                    
                    x_fft_allfreq = fft(p.x_buff,p.n_fft);
                    x_fft = x_fft_allfreq(1:end/2,:).*2;
                    
                    s_fft_allfreq = fft(p.s_buff,p.n_fft);
                    s_fft = s_fft_allfreq(1:end/2,:).*2;
                    
                    %入力バッフアをずらす
                    p.x_buff(1:end-p.n_shift,:) =...
                        p.x_buff(p.n_shift+1:end,:);
                    p.s_buff(1:end-p.n_shift,:) =...
                        p.s_buff(p.n_shift+1:end,:);
                    
                    %信号処理部
                    
                    amp = abs(x_fft);

                    sustain_coeff_mono = (((1:p.n_fft/2)-1)./(p.n_fft/2-1).*(p.high-p.low)+p.low).';
                    
                    sustain_coeff = [sustain_coeff_mono sustain_coeff_mono];
                    
                    p.spectrum_buff = max(amp.*(sustain_coeff).^p.init_att,p.spectrum_buff.*((sustain_coeff*p.sustain).^(p.n_shift/Fs)));
                    
                    y_fft = p.spectrum_buff.*s_fft;
                    
                    %逆FFT
                    p.y_buff = real(ifft(y_fft,p.n_fft));
                    
                    %位置の初期化
                    p.n = p.n_fft - p.n_shift;

               end
               
            end
            
        %tiledlayout(1,3);
        %nexttile;
        %plot(amp)
        %title("Input")
        %nexttile;
        %plot(p.spectrum_buff)
        %title("Reverb")
        %nexttile;
        %plot(sustain_coeff_mono.*p.sustain);
        %ylim([0,1])
        %title("sustain")
        
        end
        
       %% 変数の初期化
        function reset(p)
            p.n = p.n_fft - p.n_shift;
            p.x_buff = zeros(p.n_fft,2);
            p.y_buff = zeros(p.n_fft,2);
            p.s_buff = zeros(p.n_fft,2);
            p.s = 0;
            p.spectrum_buff = zeros(p.n_fft/2,2);
        end

    end
end