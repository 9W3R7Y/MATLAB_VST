classdef CR_Schroeders < audioPlugin
    %#codegen
    
    properties
        % 名前
        name = "Schroeder's Reverberator"
        
        % フィルタの個数
        combN = 4
        allN = 2
        
        % バッフアの大きさ
        combL = 2000;
        allL  = 300;
        
        %フィルタの状態保存用変数
        combZ;
        combidx;
        combm;
        combg;
        seed = 10;

        allZ;
        allidx;
        allm;
        allg;

        % サンプリング周波数
        Fs = 44100;

        % 残響時間のパラメタ
        T = 10;

        % Dryの音量のパラメタ
        drymix = 1;

        % Wetの音量のパラメタ
        wetmix = 1;
    end

    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('T','DisplayName','Time','Mapping',{'pow',2,0,20}),...
            audioPluginParameter('drymix','DisplayName','Dry','Mapping',{'lin',0,1}),...
            audioPluginParameter('wetmix','DisplayName','Wet','Mapping',{'lin',0,1})...
            );
    end

    methods
        function p = CR_Schroeders()
            % サンプリング周波数の取得
            p.Fs = getSampleRate(p);
            p.resetBuffers();
        end

        function set.seed(p,seed)
            p.seed = seed;            
        end
                
        %% Process
        function out = process(p,in)
            % Tis is the main process
            
            % Monolize the input
            X = (in(:,1)+in(:,2))/2;
            [L,~] = size(in);
            
            p.combg = 10.^(-3*p.combm/p.Fs/p.T);
            [Y,p.combZ,p.combidx] = parallelComb(NaN, X, p.combN, p.combZ, p.combidx, p.combm, p.combg);
            
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
            p.combm = floor((rand(p.combN,1)/2+1)*30*p.Fs/1000);
            
            % allpassフィルタの初期化
            p.allZ = zeros(p.allL,p.allN);
            p.allidx = ones(p.allN,1);
            p.allm = floor([5;1.7]*p.Fs/1000);
            p.allg = [0.7 0.7];
        end
    end
end