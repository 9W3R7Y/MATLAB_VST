classdef DC_Offset_Remover < audioPlugin
    %#codegen
    
    properties
        Shift = 0;
        Time = 0.05;
        time_n = 0;
        flag = 0;
        n_Samples = 1000;
        Threshold = 0;
        buff = zeros(1000,2);
    end
    
    properties (Constant)
        PluginInterface = audioPluginInterface( ...
            audioPluginParameter('Time', ...
                'Label','s', ...
                'Mapping',{'lin',0,0.1}),...
            audioPluginParameter('n_Samples', ...
                'Label','sample', ...
                'Mapping',{'int',1,1000}),...
            audioPluginParameter('Threshold', ...
                'Label','%', ...
                'Mapping',{'lin',0,100}))
    end
    
    methods
        function out = process(p,in)
            out = zeros(size(in));
            Fs =  getSampleRate(p);
            
            for i = 1:length(in)
            %% Shift Buffer
                p.buff(2:end,:) = p.buff(1:end-1,:);
                p.buff(1,:) = in(i,:);
                
            %% Calc 
                L = p.buff(1:p.n_Samples,1);
                R = p.buff(1:p.n_Samples,2);
                
                f = @(x) sum(abs(x-mean(x)))/length(x);

                change = max(f(L),f(R));

                if change < p.Threshold/100+eps
                    if p.flag == 0
                        p.flag = 1;
                        p.time_n = 0;
                    end
                    
                    if p.time_n/Fs < p.Time
                        t = (p.Time - p.time_n/Fs)/p.Time;
                        
                        fade_func = @(t) (2-t)^2*t^2;
                        
                        out(i,:) = in(i,:)*fade_func(t);
                        p.time_n = p.time_n + 1;
                    else
                        out(i,:) = zeros(1,2);
                    end
                    
                else
                    p.flag = 0;
                    out(i,:) = in(i,:);
                end
            end
        end
    end
end