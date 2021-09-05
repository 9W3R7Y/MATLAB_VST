classdef tuned_delay < audioPlugin
    %#codegen
    
    properties
        % ----------------
        % general settings
        % ----------------
        
        % sampling freq
        Fs;
        
        % dry
        drymix = 1;
        
        % wet
        
        wetmix = 1;
        
        % --------------
        % delay settings
        % --------------

        % frequency
        freq = 40;
        
        % half decay period
        HDP = 1;

        % --------------
        % variables
        % --------------
        
        % ring buffer
        rbf = zeros(2^15,2);

        % ring buffer index
        rbf_i = 1; 
    end
    
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('freq',    'Mapping', {'log',20,2000}),...
            audioPluginParameter('HDP',     'Mapping', {'lin',0,5}),...
            audioPluginParameter("drymix",  'Mapping', {'lin',0,1}),...
            audioPluginParameter('wetmix',  'Mapping', {'lin',0,1})...
            );
    end
    
    methods
        function out = process(p,in)
            p.Fs = getSampleRate(p);
            
            out = zeros(size(in));
            
            % calc delay sample & interpolation coeffs
            % y[i] = (1-coeff)*x[i-n] + coeff*x[i-n-1]
            
            delay_time = 1/p.freq;
            delay_sample = delay_time*p.Fs;
            
            coeff = mod(delay_sample,1);
            delay_n = floor(delay_sample);
            
            % calc feedback coeff
            feed = (1/2)^(1/(p.Fs*p.HDP)*delay_sample);
            
            % main loop
            
            for i = 1:length(in)
                % input
                dry = in(i,:);
                
                % clip
                dry(dry>1) = 1;
                dry(dry<-1) = -1;
                
                % delay
                n0 = mod(p.rbf_i-delay_n-1+length(p.rbf),length(p.rbf))+1;
                n1 = mod(p.rbf_i-delay_n-2+length(p.rbf),length(p.rbf))+1;
                
                wet = (1-coeff)*p.rbf(n0,:) + coeff*p.rbf(n1,:);
                
                % mute
                if max(wet) < eps
                    wet = [0 0];
                end
                
                % store current x in rbg
                p.rbf(p.rbf_i,:) = dry + feed*wet;
                
                % output
                out(i,:) = p.drymix*dry + p.wetmix*wet;
                
                % step
                p.rbf_i = mod(p.rbf_i,length(p.rbf))+1;
            end
        end
    end
end
