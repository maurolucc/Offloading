% Mauro Lucchini
% AP = access point
% VM = virtual machine
% MT = mobile terminal
% Params: the number of AP's (N) , VM's (M) and MT's (K).

% A. DRAW THE SCENARIO
prompt0 = 'Number of mobile terminals: ';
K = input(prompt0);
prompt1 = 'Number of access points: ';
N = input(prompt1);
prompt2 = 'Number of virtual machines: ';
M = input(prompt2);

R_UL = randi([1 16],K,N); 
R_UL = rates_assignment(R_UL);
% disp('Access rates uplink:');
% disp(R_UL);
R_DL= randi([1 16],K,N); 
R_DL = rates_assignment(R_DL);
% disp('Access rates downlink:');
% disp(R_DL);

technologies = randi([1 6],N,M);

RB_UL = rates_Bassignment(technologies); 
% disp('Backhaul rates uplink:');
% disp(RB_UL);
RB_DL = RB_UL; % Considering a symmetric backhaul link
% disp('Backhaul rates downlink:');
% disp(RB_DL);

vms_location = vms_assignment(M);
latencies = calculate_latency(technologies,vms_location);
% disp('Latency matrix:');
% disp(latencies);

% Generate the connection possibilities for each user
containter = {};
for i=1:K
    possibilities = [];
    count=1;
    for j=1:N
        if R_UL(i,j)~=0 && R_DL(i,j)~=0
            for l=1:M
                if RB_UL(j,l)~=0 && RB_DL(j,l)~=0
                   possibilities(count,1)= j;
                   possibilities(count,2)= l;
                   % Join the E/bit column
                   possibilities(count,3)= ebit(R_UL(i,j),R_DL(i,j)); 
                   count=count+1;
                end    
            end
        end    
    end  
    possibilities = sortrows(possibilities,3); % order asc by energy
    container{i}=possibilities;
    % the possibilities matrix for the user i is allocated in container {i} 
end

% B. TIME FRAME CREATION

ti = 0;   
tf = 0;  

% Access radio channels
aps_timedivison = {}; % {i} refers to AP i
for t=1:N 
    aps_timedivision{t,1} = [ti;tf]; % UL
    aps_timedivision{t,2} = [ti;tf]; % DL
end    

% Backhaul radio channels and VM availability
vms_timedivision = {}; % {i} refers to VM i 
vms_calc = {};         % {i} refers to VM i 
for s=1:M
    vms_timedivision{s,1} = [ti;tf]; % UL
    vms_timedivision{s,2} = [ti;tf]; % DL
    vms_calc{s} = [ti;tf];
end    


simtime = 5; % simulation time
requests = 10; % mean number of requests per user
request = event_generator(K,requests,simtime);

% C. OFFLOADING MANAGEMENT

% The Offloading Manager (OM) will work with the following time parameters
% in order to take decisions, since the energy criteria will be given by
% default, the possibilities are given depending on their energy consumption.
% Channel resources: t_resourceUL, t_resourceDL, t_resourceBUL, t_resourceBDL
% Waiting: tw_UL, tw_DL, tw_BUL, tw_BDL
% Processing: tp_ap, tp_vm   

count = 0;

    while count ~= size(request)
        
        count = count+1;
        t_threshold = 10000000000; % we could modifify this value depending on a parameter... (e.g. app)
        who_user= request(2,count);
        bits= request(3,count);
        poss = container{who_user};
       
            for j=1:size(poss)
                
                t_instant = request(1,count); % reset t_instant

                t_resourceUL = bits/R_UL(who_user,poss(j,1));
                tw_UL = resource_availability(t_resourceUL,aps_timedivision{poss(j,1),1},t_instant);
                t1 = t_instant;
                
%                 disp('tw_UL:');
%                 disp(tw_UL);
                
                
                t_instant = t_instant + tw_UL + t_resourceUL;
                t_resourceBUL = bits/RB_UL(poss(j,1),poss(j,2));
                t2 = t_instant;
                tw_BUL = resource_availability(t_resourceBUL,vms_timedivision{poss(j,2),1},t_instant);
                
%                 disp('tw_BUL:');
%                 disp(tw_BUL);
                
                t_instant = t_instant + tw_BUL+ t_resourceBUL; 
                t_vm_arrival= t_instant + latencies(poss(j,1),poss(j,2));
                t3 = t_vm_arrival;
               % rate = 10;
               % t_VM_resource = bits/rate; % pending to specify rate
                t_VM_resource = 4;
                tw_vm = resource_availability(t_VM_resource,vms_calc{poss(j,2)},t_vm_arrival);
                tp_vm =  t_VM_resource + tw_vm;
                %t_vm_arrival: time that arrive last bit to be able to process data
   
%                 disp('tw_vm:');
%                 disp(tw_vm);
%                 
                
                t_resourceBDL = bits/RB_DL(poss(j,1),poss(j,2)); 
                t_instant = t_vm_arrival + tp_vm + latencies(poss(j,1),poss(j,2));
                t4 = t_instant;
                tw_BDL = resource_availability(t_resourceBDL,vms_timedivision{poss(j,2),2},t_instant); 
                
%                 disp('tw_BDL:');
%                 disp(tw_BDL);
                
                t_instant= t_instant + tw_BDL + t_resourceBDL;
                t_resourceDL = bits/R_DL(who_user,poss(j,1));
                t5 = t_instant;
                tw_DL = resource_availability(t_resourceDL,aps_timedivision{poss(j,1),2},t_instant);
                t_total= t_resourceUL+tw_UL+t_resourceBUL+tw_BUL+tp_vm+t_resourceBDL+tw_BDL+t_resourceDL+tw_DL + 2*latencies(poss(j,1),poss(j,2));
                
%                 disp('tw_DL:');
%                 disp(tw_DL);
                
        
% an other consideration, ap routing t_wait = 0 ;
                 
                if t_total<=t_threshold
		   
                   disp('SUCCESS!!!');
                   disp('The user ');
                   disp(who_user);
                   disp(' has offloaded using AP ');
                   disp(poss(j,1));
                   disp(' and VM ');
                   disp(poss(j,2));
                 
                   disp('The resources were in these state before the user offloaded...');

                   disp('UL resource'); 
                   disp(poss(j,1));
                   disp(aps_timedivision{poss(j,1),1});
                   disp('BUL resource');
                   disp(poss(j,2));
                   disp(vms_timedivision{poss(j,2),1});
                   disp('VM resource');
                   disp(poss(j,2));
                   disp(vms_calc{poss(j,2)});
                   disp('BDL resource');
                   disp(poss(j,2));
                   disp(vms_timedivision{poss(j,2),2});
                   disp('DL resource');
                   disp(poss(j,1));
                   disp(aps_timedivision{poss(j,1),2});	 
		   
                    % Success!=> Validation
                   aps_timedivision{poss(j,1),1} = resource_validation(t_resourceUL,aps_timedivision{poss(j,1),1},t1);
                   vms_timedivision{poss(j,2),1} = resource_validation(t_resourceBUL,vms_timedivision{poss(j,2),1},t2);
                   vms_calc{poss(j,2)}= resource_validation(t_VM_resource,vms_calc{poss(j,2)},t3); 
                   vms_timedivision{poss(j,2),2} = resource_validation(t_resourceBDL,vms_timedivision{poss(j,2),2},t4);
                   aps_timedivision{poss(j,1),2} = resource_validation(t_resourceDL,aps_timedivision{poss(j,1),2},t5);
                  
                    
                   disp('The user arrived at :');
                   disp(request(1,count));
                   disp('The resources are now in these state after offloading validation...');
               
                   disp('UL resource'); 
                   disp(poss(j,1));
                   disp(aps_timedivision{poss(j,1),1});
                   disp('BUL resource');
                   disp(poss(j,2));
                   disp(vms_timedivision{poss(j,2),1});
                   disp('VM resource');
                   disp(poss(j,2));
                   disp(vms_calc{poss(j,2)});
                   disp('BDL resource');
                   disp(poss(j,2));
                   disp(vms_timedivision{poss(j,2),2});
                   disp('DL resource');
                   disp(poss(j,1));
                   disp(aps_timedivision{poss(j,1),2});		  
		   	
                   disp('Check the variables used by the Offload manager:');

                   disp('t_resourceUL: ');
                   disp(t_resourceUL);
                   disp('tw_UL: ');
                   disp(tw_UL);
                   disp('t_resourceBUL: ');
                   disp(t_resourceBUL);
                   disp('tw_BUL: ')
                   disp(tw_BUL);
                   disp('tp_vm: ');
                   disp(tp_vm);
                   disp('t_resourceBDL: ');
                   disp(t_resourceBDL);
                   disp('tw_BDL: ');
                   disp(tw_BDL);
                   disp('t_resourceDL: ');
                   disp(t_resourceDL);
                   disp('tw_DL: ');
                   disp(tw_DL);

                   disp('FINAL RESULT');
                   disp('Time needed:');
                   disp(t_total);
                   disp('Energy needed:');
                   e = poss(j,3) * bits;
                   disp(e);
                   break;

                else
                    disp('Fail');
                end 
            end
    end






