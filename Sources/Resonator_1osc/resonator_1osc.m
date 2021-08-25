classdef resonator_1osc < audioPlugin
    %#codegen
    %% 変数の作成
    properties
       n = 0;                   %位置
       x_buff = zeros(4096,2);  %入力バッファ
       y_buff = zeros(4096,2);  %出力バッファ
       
       s_buff = zeros(4096,2); %オシレーターバッフア
       s = 0;
       s_amp = 0.01;
       f = 110;
       
       spectrum_buff = zeros(4096/2,2);
       coeff = 0;
       bins = 256;
       color = 1;
       amp_db = 0;
    
    end
    
   %% UIの設定
    properties (Constant)
        PluginInterface = ...
            audioPluginInterface( ...
                audioPluginParameter('coeff', ...
                'DisplayName', 'Delay', ...
                'Label', '%', ...
                'Mapping', { 'pow', 10, 0, 100}),...
                ...
                audioPluginParameter('f', ...
                'DisplayName', 'Freq', ...
                'Label', 'Hz', ...
                'Mapping', { 'log', 20, 2000}),...
                ...
                audioPluginParameter('bins', ...
                'DisplayName', 'Harmonics', ...
                'Label', '', ...
                'Mapping', { 'lin', 1, 256}),...
                ...
                audioPluginParameter('color', ...
                'DisplayName', 'Color', ...
                'Label', '', ...
                'Mapping', { 'lin', 0, 1}),...
                ...
                audioPluginParameter('amp_db', ...
                'DisplayName', 'Amp', ...
                'Label', '', ...
                'Mapping', { 'lin', -40, 0}))
    end
    
    %%パラメタの設定
    properties(Constant)
        n_fft       = 4096;     %fft幅
        n_shift     =   64;      %シフト幅
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
            
            %% オシレーターの関数
            function y = series2wave(x,N,Phi,color,freq)
                n_bin = length(N);
                y = 0;
                for i_bin = 1:n_bin
                    if freq * N(i_bin) < Fs/2
                        y = y + sin(N(i_bin)*x+Phi(i_bin)).*(1/N(i_bin))^color;
                    else
                        break
                    end
                end
            end
            
          %% メインループ
            for i = 1:frame_size
                %OSCを進める
                p.s = mod(p.s + p.f/Fs, 1);
                N = 1:p.bins;
                Phi = zeros(size(N));
                p.s_buff(p.n,:) = series2wave(2*pi*(2*p.s-1),N,Phi,1-p.color,p.f)*p.s_amp;
                
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

                    p.spectrum_buff = max(amp,p.spectrum_buff.*((p.coeff/100).^(p.n_shift/Fs)));
                    
                    y_fft = p.spectrum_buff.*s_fft;
                    
                    %逆FFT
                    p.y_buff = real(ifft(y_fft,p.n_fft));
                    
                    %位置の初期化
                    p.n = p.n_fft - p.n_shift;
               end
            end
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