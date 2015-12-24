function rates_Bassignment=rates_Bassignment(technologies)
    % CATEGORIZATION OF NON_IDEAL BACKHAUL
    % The following technologies will be used for each connection.
    % index -> technology
    % 1 -> Fiber Access 1
    % 2 -> Fiber Access 2
    % 3 -> Fiber Access 3
    % 4 -> DSL Access
    % 5 -> Wire 
    % 6 -> Wireless connection
    
    [r,c] = size(technologies);
    for i=1:r
        for j=1:c
            tech = technologies(i,j);
            if tech==1
                 rate = randi ([0 10000000000],1); 
                % TEST B
               % rate = 1000000000;
                if rate<1000000000 % if the connection rate is very low... 
                    rate=0; % disconnect
                end
            elseif tech==2
                rate = randi ([0 1000000000],1); 
                if rate<100000000 % if the connection rate is very low...
                    rate=0; % disconnect
                end
            elseif tech==3
                rate = randi ([0 10000000000],1);
                if rate<500000000 % if the connection rate is very low...
                    rate=0; % disconnect
                end
            else 
                rate = randi ([0 1000000000],1);
                if rate<100000000 % if the connection rate is very low... 
                    rate=0; % disconnect
                end
            end      
            rates_Bassignment(i,j) = rate;
        end    
    end 
end


