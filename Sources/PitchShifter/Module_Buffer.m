classdef Module_Buffer
    %#codegen
    
    properties
        buff
        N
    end
    
    methods
        
        function obj = Module_Buffer(bf_size,n_channel)
            %RINGBUFFER Constructor of ringbuffer.
            % 
            % obj = Ringbuffer(bf_size, n_channel, init_i)
            %
            %
            % Params
            % ------
            %   bf_size     ... The size of ring buffer.
            %   n_channel   ... The number of channels (Default = 1). 
            %   init_i      ... Initilal index (Default = 1).
            %
            %
            % Reterns
            % -------
            %   obj         ... Ringbuffer Object
                       
            % Initialization
            obj.buff = zeros(bf_size,n_channel);
            obj.N = bf_size;
        end
        
        function obj = put_sample(obj,x)
            %PUT_SAMPLE Put in new sample to ringbuffer.
            %
            % put_sample(x)
            %
            %
            % Params
            % ------
            %   obj     ... Ringbuffer object.
            %   x       ... New Sample; 
            
            obj.buff(1:end-1,:) = obj.buff(2:end,:);
            obj.buff(end,:) = x;
        end
        
        function x = get_sample(obj,pos)
            %GET_SAMPLE
            
            i1 = mod(floor(pos),obj.N)+1;
            i2 = mod(i1,obj.N)+1;
            a = rem(pos,1);
                
            x = (1-a)*obj.buff(i1,:) + a*obj.buff(i2,:);
        end
        
    end
end

