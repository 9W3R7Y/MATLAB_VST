classdef Module_Buffer
    %#codegen
    
    properties
        buff
        N
    end
    
    methods
        
        function obj = Module_Buffer(bf_size,n_channel)
            
            obj.buff = zeros(bf_size,n_channel);
            obj.N = bf_size;
        end
        
        function obj = put_sample(obj,x)
            
            obj.buff(1:end-1,:) = obj.buff(2:end,:);
            obj.buff(end,:) = x;
        end
        
        function x = get_sample(obj,pos)
            
            i1 = mod(floor(pos),obj.N)+1;
            i2 = mod(i1,obj.N)+1;
            a = rem(pos,1);
                
            x = (1-a)*obj.buff(i1,:) + a*obj.buff(i2,:);
        end
        
    end
end

