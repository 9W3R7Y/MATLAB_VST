classdef Schroeders < audioPlugin
    %#codegen
    
    properties
        combN = 4
        allN = 2
        
        combZ;
        combidx;
        combm;
        
        allZ;
        allidx;
        allm;
        
        Fs = 44100;
        T = 10;
        W = 1;
        
        drymix = 1;
        wetmix = 1;
    end
    
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('T','DisplayName','Time','Mapping',{'pow',2,0,20}),...
            audioPluginParameter('W','DisplayName','Width','Mapping',{'lin',0,1}),...
            audioPluginParameter('drymix','DisplayName','Dry','Mapping',{'lin',0,1}),...
            audioPluginParameter('wetmix','DisplayName','Wet','Mapping',{'lin',0,1})...
            );
    end
    
    methods
        %% Init
        function p = Schroeders()
            p.Fs = getSampleRate(p);
            
            p.combZ = zeros(p.combN,1000,2);
            p.combidx = ones(p.combN,2);
            p.combm = floor((rand(p.combN,2)/2+1)*30*44100/1000);
            
            p.allZ = zeros(p.allN,1000,2);
            p.allidx = ones(p.allN,2);
            p.allm = floor([[5;1.7],[5;1.7]]*44100/1000);
            
        end
        
        %% Process
        function out = process(p,in)
            reb = paraComb(p,in);
            reb = seriAllpass(p,reb);
            
            % Apply Width
            Lreb = reb(:,1);
            Rreb = reb(:,2);
            
            w = p.W/2+1/2;
            
            L = Lreb*w + Rreb*(1-w);
            R = Rreb*w + Lreb*(1-w);
            
            % Mix
            dry = in;
            wet = [L R];
            
            out = p.drymix*dry + p.wetmix*wet;
        end
        
        %% comb filter
        function [Y,Z,i] = comb(X, Z, i, m, g)

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
                Y(j,:) = y; 

                % 入力のバッファへの格納とフィードバック
                Z(ringInd(i),:) = x + g*z;

                % バッファのインデックスを進める
                i = ringInd(i+1);
            end
        end
        
        %% allpass filter
        function [Y,Z,i] = allpass(X, Z, i, m, g)

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
                Y(j,:) = y; 

                % 入力のバッファへの格納とフィードバック
                Z(ringInd(i),:) = x + g*z;

                % バッファのインデックスを進める
                i = ringInd(i+1);
            end
        end
        
        %% Parallel Comb Filter
        function out = paraComb(p,in)
            X = in;
            out = zeros(size(in));
            
            for i = 1:p.combN
                % set parameters
                Z = reshape(p.combZ(i,:,:),[1000,2]);
                idx = p.combidx(i,:);
                m   = p.combm(i,:);
                g   = 10.^(-3*m/p.Fs/p.T);
                
                % filter
                [YL,p.combZ(i,:,1),p.combidx(i,1)] = ...
                    comb(X(:,1),Z(:,1),idx(1),m(1),g(1));
                [YR,p.combZ(i,:,2),p.combidx(i,2)] = ...
                    comb(X(:,2),Z(:,2),idx(2),m(2),g(2));
                
                % sum
                out = out+[YL,YR];
            end
            
        end
        
        %% Series Allpass Filter
        function out = seriAllpass(p,in)
            X = in;
            
            % series
            
            for i = 1:p.allN
                % set parameters
                Z = reshape(p.allZ(i,:,:),[1000,2]);
                idx = p.allidx(i,:);
                m   = p.allm(i);
                g   = 0.7;
                
                % filter
                [YL,p.allZ(i,:,1),p.allidx(i,1)] = allpass(X(:,1),Z(:,1),idx(1),m,g);
                [YR,p.allZ(i,:,2),p.allidx(i,2)] = allpass(X(:,2),Z(:,2),idx(2),m,g);
                
                X = [YL YR];
            end
            
            out = X;
        end
    end
end