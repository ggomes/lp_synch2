classdef Settings
    
    properties
        sim_dt = 3; 
        Kdem = 20;
        Kcool = 20;
        etha = 0.1;

    end
    
    methods
        function [obj]=Settings()
            obj.K = obj.Kdem + obj.Kcool;
        end
    end
    
end

