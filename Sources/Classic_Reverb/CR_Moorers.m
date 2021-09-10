classdef CR_Moorers < audioPlugin
    %#codegen
    
    properties
        % 名前
        name = "Moorer's Reverberator"
        
        % フィルタの個数
        combN = 6
        allN = 1
        
        % バッフアの大きさ
        combL = 2000;
        allL  = 300;
        
        %フィルタの状態保存用変数
        combZ;
        combidx;
        combm;
        seed = 10;

        allZ;
        allidx;
        allm;
        allg;
        
        LPZ;
        g1;
        g2;
        damp = 0;

        % サンプリング周波数
        Fs = 44100;

        % 残響時間のパラメタ
        g = 0.5;

        % Dryの音量のパラメタ
        drymix = 1;

        % Wetの音量のパラメタ
        wetmix = 1;
    end

    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('g','DisplayName','Feedback','Mapping',{'pow',1/10,0,1}),...
            audioPluginParameter('damp','DisplayName','Damp','Mapping',{'lin',0,2}),...
            audioPluginParameter('drymix','DisplayName','Dry','Mapping',{'lin',0,1}),...
            audioPluginParameter('wetmix','DisplayName','Wet','Mapping',{'lin',0,1})...
            );
    end

    methods
        function p = CR_Moorers()
            % サンプリング周波数の取得
            p.Fs = getSampleRate(p);
            p.resetBuffers();
        end
        
        %% Process
        function out = process(p,in)
            % Tis is the main process
            
            % Monolize the input
            X = (in(:,1)+in(:,2))/2;
            [L,~] = size(in);
            
            g1tuned = (p.g1).^(1/(p.damp+eps));
            p.g2  = p.g*(1-g1tuned);
            [Y,p.combZ,p.combidx,p.LPZ] = parallelComb(NaN, X, p.combN, p.combZ, p.combidx, p.combm, g1tuned, p.g2, p.LPZ);
            X = reshape(sum(Y,1),[L,1]);
           
            [Y,p.allZ, p.allidx] = seriesAllpass(NaN, X, p.allN, p.allZ, p.allidx, p.allm);
            
            % Mix
            dry = in;
            wet = [Y Y];
            
            out = p.drymix*dry + p.wetmix*wet;
        end
        
        function resetBuffers(p)
            % combフィルタの初期化
            p.combZ = zeros(p.combL,p.combN);
            p.combidx = ones(1,p.combN);
            rng(p.seed);
            p.combm = floor([50 56 61 68 72 78]*p.Fs/1000);

            % allpassフィルタの初期化
            p.allZ = zeros(p.allL,p.allN);
            p.allidx = ones(p.allN,1);
            p.allm = floor(6*p.Fs/1000);
            
            % LPFの初期化
            p.LPZ = zeros(1,p.combN);
            p.g1  = [0.46, 0.48, 0.50, 0.52, 0.53, 0.55];
            p.g2  = p.g*(1-p.g1);
        end
    end
end