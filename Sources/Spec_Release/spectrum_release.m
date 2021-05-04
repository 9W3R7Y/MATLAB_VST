classdef spectrum_release < audioPlugin
    %#codegen
    %% 変数の作成
    properties
       n = 0;                   %位置
       x_buff = zeros(4096,2);  %入力バッファ
       y_buff = zeros(4096,2);  %出力バッファ
       spectrum_buff = zeros(2048,2);
       coeff = 0;
    
    end
    
   %% UIの設定
    properties (Constant)
        PluginInterface = ...
            audioPluginInterface( ...
                audioPluginParameter('coeff', ...
                'DisplayName', 'Attenuation rate', ...
                'Label', '%', ...
                'Mapping', { 'pow', 1/100, 0, 100}))
    end
    
    %%パラメタの設定
    properties(Constant)
        n_fft       = 4096;     %fft幅
        n_shift     =  32;      %シフト幅
    end
    
    %% メソッド
    methods
        function y_frame = process(p, x_frame)
          %% ループの準備
            %フレームサイズの取得
            frame_size = length(x_frame);
            
            %出力フレームの用意
            y_frame = zeros(frame_size,2);
            
          %% メインループ
            for i = 1:frame_size
              %% バッファの入出力とステップの進行
                p.x_buff(p.n,:) = x_frame(i,:);
                y_frame(i,:) = p.y_buff(max(1,p.n-p.n_fft/2),:);
                p.n = p.n + 1;

             %% バッファが十分に満たされたら
               if p.n == p.n_fft
                    %FFTして負の周波数を無視
                    
                    x_fft_allfreq = fft(p.x_buff,p.n_fft);
                    x_fft = x_fft_allfreq(1:end/2,:).*2;
                    
                    %入力バッフアをずらす
                    p.x_buff(1:end-p.n_shift,:) =...
                        p.x_buff(p.n_shift+1:end,:);
                    
                    %信号処理部
                    
                    amp = abs(x_fft);
                    phase = x_fft./amp;

                    p.spectrum_buff = max(amp,p.spectrum_buff.*p.coeff/100);
                    
                    y_fft = p.spectrum_buff.*phase;
                    
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
            p.spectrum_buff = zeros(p.n_fft/2,2);
        end
    end
end