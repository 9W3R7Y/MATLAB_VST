classdef Plug_PitchShifter < audioPlugin
    %#codegen
    properties
        %% Audio Setting
        
        % Sampling Freq
        Fs = 44100;
        
        %% PitchShifting variables
        % Buffer Size
        N = 1024;
        
        % Loop Length
        L = 512;
        
        % Main Buffer
        BF
        
        % Reader Positions
        reader_pos
        
        % Crossfade Coefficieant
        cross_coeff = 0.1;
        
        %% F0 Estimation variables
        
        % Lowpass
        LPBF
        LPZ
        LPCoeff
        
        %%　
        % f0 duration
        f0_duration = 128;
        f0_count = 0;
        
        %% Parameter
        pitch = 0
        
        adaptive_loop_length = true
        
        fmin = 100;
        fmax = 1000;
        
        %% Visualization variables
        
        F0Buff;
        OutBuff;
        
        lastACF;
        lastLocsACF;
    end
    
    %% User Interface
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('pitch','DisplayName','Shift',...
                                 'Label','cent',...
                                 'Mapping',{'lin',-24,24}),...
            audioPluginParameter('adaptive_loop_length','DisplayName','Adaptive Loop Length',...
                                 'Mapping',{'enum','on','off'},...
                                 'Style','checkbox' ...
                                 ));
    end
    
    %%
    methods
       function obj = Plug_PitchShifter()
            %% Initialize buffers with zeros
            obj.BF = Module_Buffer(obj.N,1);
            obj.reader_pos = obj.N/2;
            
            obj.LPBF = Module_Buffer(obj.N,1);
            obj.LPZ  = zeros(5,1);
            obj.LPCoeff = [1 1 1 1 1 -0.96]/6;
            
            obj.F0Buff = Module_Buffer(obj.N,1);
            obj.OutBuff =Module_Buffer(obj.N,1);
       end
       
        %% Main Process
        function out = process(obj, in)
            %% Modify input signal
            
            % monolize
            in = mean(in,2);
            
            % get the size of input
            [framesize,nchannel] = size(in);
            
            % create output matrix
            out = zeros(framesize, nchannel);
            
            %% Filtering (for f0 estimation)
            [in_filted,obj.LPZ] = filter(obj.LPCoeff,1,in,obj.LPZ);
            
            %% main loop
            for i = 1:framesize
                %% Put input signal in buffer
                % get x from input 
                x = in(i,:);
                x_filted = in_filted(i,:);
                
                % put x in Buffer
                obj.BF = obj.BF.put_sample(x);
                obj.LPBF = obj.LPBF.put_sample(x_filted);
                
                %% Calc L
                if rem(obj.f0_count,obj.f0_duration) == 0

                    % calc Autocorrection Function
                    ACF = xcorr(obj.LPBF.buff.*blackman(obj.N));
                    ACF = ACF(floor(end/2):end);
                    ACF = ACF/ACF(1);

                    % find peaks
                    [~,locsACF] = findpeaks(ACF,'MinPeakProminence',0.3);

                    % 
                    if ~isempty(locsACF)
                        T0 = locsACF(1);
                        obj.L = T0*2;
                        obj.F0Buff = obj.F0Buff.put_sample(obj.Fs/T0);
                    else
                        obj.F0Buff = obj.F0Buff.put_sample(0);
                    end
                    
                    % reset counter
                    obj.f0_count = 0;
                    
                    % save current ACF
                    obj.lastACF = ACF;
                    obj.lastLocsACF = locsACF;
                    
                else
                    obj.F0Buff = obj.F0Buff.put_sample(obj.Fs/obj.L*2);
                end
                
                if ~obj.adaptive_loop_length
                    obj.L = 512;
                end
                
                % update counter
                obj.f0_count = obj.f0_count + 1;
                
               %% Update Readers
               
                % set loop range
                bf_left = (obj.N - obj.L)/2;
                bf_right = bf_left + obj.L - 1;
                
                % calc step length
                step = 2^(obj.pitch/12) - 1;
                
                % step position
                obj.reader_pos = obj.reader_pos + step;
                
                % loop
                if obj.reader_pos < bf_left
                    obj.reader_pos = obj.reader_pos + obj.L;
                elseif bf_right < obj.reader_pos
                    obj.reader_pos = obj.reader_pos - obj.L;
                end
                
                %% CrossFade

                % get sample from Buffer
                y_R = obj.BF.get_sample(obj.reader_pos+obj.L);
                y_C = obj.BF.get_sample(obj.reader_pos);
                y_L = obj.BF.get_sample(obj.reader_pos-obj.L);

                % calc mix rate
                clip = @(x) min(1,max(0,x));
                faderange = obj.L*obj.cross_coeff;
                mix_R = @(pos) 1-clip((pos-(obj.N-obj.L)/2)/faderange+1/2);
                mix_L = @(pos) clip((pos-(obj.N+obj.L)/2)/faderange+1/2);
                mix_C = @(pos) 1-max(mix_R(pos),mix_L(pos));
                
                y = y_L*mix_L(obj.reader_pos) + ...
                    y_R*mix_R(obj.reader_pos) + ...
                    y_C*mix_C(obj.reader_pos);
                
                %% Signal Output
                out(i,:) = y;
                obj.OutBuff = obj.OutBuff.put_sample(y);
            end
            
            out = [out, out];
            
            %% Plot
            
            %%{
            f = figure(1);
            f.Visible = true;
            clf;

            % Buffer
            subplot(2,2,1);
            hold on;
            plot(obj.BF.buff,'color','#888888');
            plot(obj.reader_pos, y, 'o','color', 'r');
            fadecol = [1,0,0];
            xline(obj.reader_pos,'color',fadecol);
            yline(y,':','color','r');
            
            xline(bf_left);
            xline(bf_right);
            
            xlim([1 obj.N]);
            ylim([-1 1]);
            xticks([]);
            
            ylabel('Amplitude')
            
            title('Input Signal')
            
            % Output
            subplot(2,2,2);
            hold on;
            plot(obj.OutBuff.buff,'color','#888888');
            ylabel('Amplitude')
            title('Output Signal')
            plot(obj.N, y, 'o','color', 'r');
            
            xlim([-inf inf]);
            ylim([-1 1]);
            xticks([]);
            
            yline(y,':','color','r');
            
            % Autocorrection Function
            subplot(2,2,3);
            plot(obj.lastACF);
            hold on;
            
            if ~isempty(obj.lastLocsACF)
                plot(obj.lastLocsACF(1),...
                     obj.lastACF(obj.lastLocsACF(1)),'o');
            end
            
            xlim([-inf inf]);ylim([-1 1]);
            xticks([]);
            
            ylabel('Autocorrection')
            
            title('Autocorrection Function')
            
            % Pitch
            subplot(2,2,4);
            plot(obj.F0Buff.buff);
            xlim([-inf inf]);
            xticks([]);
            ylim([0 1000]);

            ylabel('Frequency [Hz]');
            title('Pitch')
            
            drawnow;
            
            %}
        end
    end
end
