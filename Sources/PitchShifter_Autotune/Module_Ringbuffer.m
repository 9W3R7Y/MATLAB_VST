classdef Module_Ringbuffer
    %#codegen
    
    properties
        buff
        i
        N
    end
    
    methods
        
        function obj = Module_Ringbuffer(bf_size,n_channel,init_i)
            %MODULE_RINGBUFFER Constructor of ringbuffer.
            % 
            % obj = Module_Ringbuffer(bf_size, n_channel, init_i)
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
            obj.i = init_i;
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
            
            obj.buff(obj.i,:) = x;
            obj.i = mod(obj.i,obj.N) + 1;
        end
        
        function x = get_sample(obj,pos,varargin)
            %GET_SAMPLE
            
            if ~isempty(varargin) && varargin{1} == "local"
                pos = pos+obj.i-1;
            else % global
                
            end

            i1 = mod(floor(pos),obj.N)+1;
            i2 = mod(i1,obj.N)+1;
            a = rem(pos,1);
                
            x = (1-a)*obj.buff(i1,:) + a*obj.buff(i2,:);
        end
        
        function obj = rearrange(obj)
            left = obj.buff(1:obj.i-1,:);
            right = obj.buff(obj.i:end,:);
            obj.buff = [right; left];
            obj.i = 1;
        end
    end
end

