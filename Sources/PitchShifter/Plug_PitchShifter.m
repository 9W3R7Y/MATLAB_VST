classdef Plug_PitchShifter < audioPlugin
    %#codegen
    properties
        %% Audio Setting
        
        % Sampling Freq
        Fs = 44100;
        
        %% PitchShifting variables
        % Buffer Size
        N = 2048;
        
        % Loop Length
        L = 512;
        
        % Main Buffer
        BF
        
        % Reader Positions
        reader_pos
        
        % Crossfade Ratio
        cross_rate = 0.1;
        
        %% F0 Estimation variables
        
        % Lowpass
        LPBF
        LPZ
        LPCoeff
        
        % T0
        T0 = 512
        
        % f0 duration
        f0_duration = 512;
        f0_count = 0;
        
        % f0 filter
        LPZ_F0;
        LPCoeff_F0;
       
        %% Parameter
        pitch = 0
        
        adaptive_loop_length = true
        
        fmin = 100;
        fmax = 500;
        
        %% Visualization variables
        
        F0Buff;
        OutBuff;
        
        lastACF;
        lastLocACF;
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
    
    %% Methods
    methods
        %% Constructor
        function obj = Plug_PitchShifter()
            %% Initialize buffers with zeros
            obj.BF = Module_Buffer(obj.N,1);
            obj.reader_pos = obj.N/2;

            obj.LPBF = Module_Buffer(obj.N,1);

            obj.F0Buff = Module_Buffer(obj.N,1);
            obj.OutBuff =Module_Buffer(obj.N,1);
            
            %% Initialize Filters
            obj.LPCoeff = [1 1 1 1 1 1 1 -0.96]/6;
            obj.LPZ  = zeros(length(obj.LPCoeff)-1,1);
            
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
                
                %% f0 estimation
                if rem(obj.f0_count,obj.f0_duration) == 0

                    % calc Autocorrelation Function
                    ACF = xcorr(obj.LPBF.buff.*blackman(obj.N));
                    ACF = ACF(floor(end/2):end);
                    ACF = ACF/ACF(1);

                    % find peaks
                    [peaks,peakIdxs] = findpeaks(ACF,'MinPeakProminence',0.1);
                    
                    % 
                    if ~isempty(peaks)
                        %% find peak
                        
                        % find maximum peak
                        [~, Idx] = max(peaks);
                        loc = peakIdxs(Idx);
                        
                        % temporary T0
                        
                        T0_tmp = loc;
                        
                       %% F0 Validation & Correction
                        
                        % if F0 is too high (ex.noise)
                        % ...ignore & use old value
                        if T0_tmp < obj.Fs/obj.fmax
                            T0_tmp = obj.T0;
                        end
                        
                        % Correct T0
                        obj.T0 = T0_tmp;
                    else
                        loc = 1;
                    end
                    
                    % save current ACF
                    obj.lastACF = ACF;
                    obj.lastLocACF = loc;
                    
                    % reset counter
                    obj.f0_count = 0;
                end
                
                % save to buffer
                obj.F0Buff = obj.F0Buff.put_sample(obj.Fs/obj.T0);
                
                % update counter
                obj.f0_count = obj.f0_count + 1;

                %% Set loop length
                
                if obj.adaptive_loop_length
                    obj.L = obj.T0;
                else
                    obj.L = 512;
                end
                
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
                faderange = obj.L*obj.cross_rate;
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
            
            %% Modify output sig
            out = [out, out];
            
            %% Plot
            
            %%{
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
            
            % Autocorrelation Function
            subplot(2,2,3);
            plot(obj.lastACF);
            hold on;
            
            if ~isempty(obj.lastLocACF)
                plot(obj.lastLocACF,...
                     obj.lastACF(obj.lastLocACF(1)),'o');
            end
            
            xlim([-inf inf]);ylim([-1 1]);
            xticks([]);
            
            ylabel('Autocorrelation')
            
            title('Autocorrelation Function')
            
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
