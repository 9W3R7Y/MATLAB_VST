classdef Q_Reverb < audioPlugin
    %#codegen
    
    properties
        % 名前
        name = "9W3R7Y's Reverberator"
        
        % フィルタの個数
        combN = 100
        combNmax = 100;
        allN = 2
        
        % バッフアの大きさ
        combL = 2000;
        allL  = 300;
        
        %フィルタの状態保存用変数
        combZ;
        combidx;
        combm;
        combg;
        seed = 111;

        allZ;
        allidx;
        allm;
        allg;

        % サンプリング周波数
        Fs = 44100;

        % 残響時間のパラメタ
        T = 10;

        % ステレオ感のパラメタ
        W = 1;

        % Dryの音量のパラメタ
        drymix = 1;

        % Wetの音量のパラメタ
        wetmix = 1;
    end

    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('T','DisplayName','Time','Mapping',{'pow',2,0,20}),...
            audioPluginParameter('W','DisplayName','Width','Mapping',{'lin',0,1}),...
            audioPluginParameter('drymix','DisplayName','Dry','Mapping',{'lin',0,1}),...
            audioPluginParameter('wetmix','DisplayName','Wet','Mapping',{'lin',0,1}),...
            audioPluginParameter('combN','DisplayName','Number of Comb Filters','Mapping',{'int',1,100})...
            );
    end

    methods
        function p = Q_Reverb()
            % サンプリング周波数の取得
            p.Fs = getSampleRate(p);

            % バッフアの初期化
            p.resetBuffers();
        end

        function set.seed(p,seed)
            p.seed = seed;            
        end
                
        %% Process
        function out = process(p,in)
            
            % Monolize the input
            X = (in(:,1)+in(:,2))/2;
            
            [Y1,p.allZ, p.allidx] = seriesAllpass(NaN,X, p.allN, p.allZ, p.allidx, p.allm);
            
            p.combg = 10.^(-3*p.combm/p.Fs/p.T);
            [Y2,p.combZ,p.combidx] = parallelComb(NaN, Y1, p.combN, p.combZ, p.combidx, p.combm, p.combg);
            
            Y3 = applyMixMat(p, Y2);
            
            % Apply Width
            YL = Y3(:,1);
            YR = Y3(:,2);

            theta = (1-p.W)*pi/4;

            L = cos(theta)*YL + sin(theta)*YR;
            R = cos(theta)*YR + sin(theta)*YL;

            % Mix
            dry = in;
            wet = [L R];

            out = p.drymix*dry + p.wetmix*wet;
        end
        
        function resetBuffers(p)
            
            % combフィルタの初期化
            p.combZ = zeros(p.combL,p.combNmax);
            p.combidx = ones(p.combNmax,1);
            rng(p.seed);
            p.combm = floor((rand(p.combN,1)/2+1)*30*p.Fs/1000);

            % allpassフィルタの初期化
            p.allZ = zeros(p.allL,p.allN);
            p.allidx = ones(p.allN,1);
            p.allm = floor([5;1.7]*p.Fs/1000);
            p.allg = [0.7,0.7];
        end
    end
end