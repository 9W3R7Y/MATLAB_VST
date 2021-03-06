classdef Schroeders < audioPlugin
    %#codegen
    
    properties
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
        seed = 111;

        allZ;
        allidx;
        allm;

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
        function p = Schroeders()
            % サンプリング周波数の取得
            p.Fs = getSampleRate(p);

            % combフィルタの初期化
            p.combZ = zeros(p.combL,p.combNmax);
            p.combidx = ones(p.combNmax);
            rng(p.seed);
            p.combm = floor((rand(p.combN)/2+1)*30*p.Fs/1000);

            % allpassフィルタの初期化
            p.allZ = zeros(p.allL,p.allN);
            p.allidx = ones(p.allN);
            p.allm = floor([5;1.7]*p.Fs/1000);
        end

        function set.seed(p,seed)
            p.seed = seed;            
        end
                
        %% Filters
        function out = paraComb(p,in)            
            function [Y,Z,i] = comb(~, X, Z, i, m, g)
                % 変数の初期化
                nsample = length(X); % サンプル数
                Y = zeros(size(X));  % 出力用の行列
                N = length(Z); % バッファの大きさ

                % インデックスの変換
                ringInd = @(i) mod(i-1+N,N)+1;

                % サンプル毎の処理
                for j = 1:nsample

                    % 入力
                    x = X(j,:);

                    % mサンプル前の値を取得
                    z  = Z(ringInd(i-m),:);

                    % 出力
                    y = z;
                    Y(j,:) = y(1); 

                    % 入力のバッファへの格納とフィードバック
                    Z(ringInd(i),:) = x + g*z;

                    % バッファのインデックスを進める
                    i = ringInd(i+1);
                end
            end
        
            X = in;
            [L,~] = size(in);
            out = zeros(L,2);

            for i = 1:p.combN
                % set parameters
                Z = p.combZ(:,i);
                idx = p.combidx(i);
                m   = p.combm(i);
                g   = 10^(-3*m/p.Fs/p.T);

                % filter
                [Y,p.combZ(:,i),p.combidx(i)] = ...
                    comb(p,X,Z,idx,m,g);
                                
                % Apply Mixing Matrix
                out = out+[Y Y*(rem(i,2)*2-1)];
            end
           
            out = out/sqrt(p.combN);
            
        end
        
        function out = seriAllpass(p,in)
            X = in;

            % series

            for i = 1:p.allN
                % set parameters
                Z = p.allZ(:,i);
                idx = p.allidx(i);
                m   = p.allm(i);
                g   = 0.7;

                % filter
                [Y,p.allZ(:,i),p.allidx(i)] = allpass(p,X,Z,idx,m,g);

                X = Y;
            end

            out = X;
            
            function [Y,Z,i] = allpass(~, X, Z, i, m, g)

                % 変数の初期化
                nsample = length(X); % サンプル数
                Y = zeros(size(X));  % 出力用の行列
                N = length(Z); % バッファの大きさ

                % インデックスの変換
                ringInd = @(i) mod(i-1+N,N)+1;

                % サンプル毎の処理
                for j = 1:nsample

                    % 入力
                    x = X(j,:);

                    % mサンプル前の値を取得
                    z  = Z(ringInd(i-m),:);

                    % 出力
                    y = (1-g^2)*z - g*x;
                    Y(j) = y; 

                    % 入力のバッファへの格納とフィードバック
                    Z(ringInd(i),:) = x + g*z;

                    % バッファのインデックスを進める
                    i = ringInd(i+1);
                end
            end
        end
        
        %% Process
        function out = process(p,in)
            
            % Monolize the input
            X = (in(:,1)+in(:,2))/2;
            
            %Y1 = seriAllpass(p,X);
            Y2 = paraComb(p,X);
            
            % Apply Width
            YL = Y2(:,1);
            YR = Y2(:,2);

            theta = (p.W)*pi/4;

            L = cos(theta)*YL + sin(theta)*YR;
            R = cos(theta)*YR + sin(theta)*YL;

            % Mix
            dry = in;
            wet = [L R];

            out = p.drymix*dry + p.wetmix*wet;
        end
    end
end