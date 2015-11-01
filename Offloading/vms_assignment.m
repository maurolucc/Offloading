function vms_assignment=vms_assignment(M)
    % Returns a matrix with three rows and M columns.
    % The first row contains the VM index, the second one the distance to
    % the access point and the last one the latency associated.
    % There will be considered the 15 following remote machines
    % 
    % The distances are approximated (Km).  
    %   cities = [cellstr('BCN'),30;
    %             cellstr('MAD'),620;
    %             cellstr('PAR'),1035;
    %             cellstr('LON'),1486;
    %             cellstr('AMS'),1533;
    %             cellstr('VIE'),1828;
    %             cellstr('WAW'),2397;
    %             cellstr('WAS'),6489;
    %             cellstr('MIA'),7542;
    %             cellstr('DFW'),8330;
    %             cellstr('LAX'),9653;
    %             cellstr('HKG'),10053;
    %             cellstr('TYO'),10413;
    %             cellstr('SIN'),10875;
    %             cellstr('SYD'),17179];
    
    % Distances APs-VMs
    location = [30,620,1035,1486,1533,1828,2397,6489,7542,8330,9653,10053,10413,10875,17179]; 
    % At first the VMs in the scenario are located (KM). 
     for i=1:M
         vms_assignment(i)= randsample(location,1)*1000;
     end
end