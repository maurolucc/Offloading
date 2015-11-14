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
R_DL= randi([1 16],K,N); 
R_DL = rates_assignment(R_DL);

technologies = randi([1 6],N,M);

RB_UL = rates_Bassignment(technologies); 
RB_DL = RB_UL; % Considering a symmetric backhaul link

vms_location = vms_assignment(M);
latencies = calculate_latency(technologies,vms_location);

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


simtime = 2; % simulation time
requests = 2; % mean number of requests per user
request = event_generator(K,requests,simtime);

% C. OFFLOADING MANAGEMENT

% The Offloading Manager (OM) will work with the following time parameters
% in order to take decisions, since the energy criteria will be given by
% default, the possibilities are given depending on their energy consumption.
% Channel resources: t_resourceUL, t_resourceDL, t_resourceBUL, t_resourceBDL
% Waiting: tw_UL, tw_DL, tw_BUL, tw_BDL
% Processing: tp_ap, tp_vm   

% There will be many options with the same E/bit. Therefore, it seems 
% logical not choosing the first preconfigured option among the ones that
% have the same E/bit. The best option in terms of time consuming will be
% chosen among the ones that have the same E/bit characterization.


rec = 0;
[s,f]=size(request);

    while rec ~= f
         rec = rec+1;
         disp('***********************************************************************************************');
         disp('                         REQUEST:'); fprintf('\b'); disp(rec);
         disp('***********************************************************************************************');

        t_threshold = 30; % TODO: modifify this value depending on a parameter... (e.g. app)
        who_user= request(2,rec);
        bits= request(3,rec);
        poss = container{who_user};
        
        ebit_blocks= getblocks_ebit(poss(:,3));
        [h1, h2] = size(ebit_blocks);
        
        for x=1:h2
        % The comparisions are done as many times as the same  e/bit is repeated in different possibilites
        % and the previous combinations failed.
            t_totals = Inf(1,ebit_blocks(1,x));
            % this vector will be fullfilled with the t_total's calculated
            % in order to be able to compare.
            register=1;
            for j=1:size(poss)
                j=register;
                
                for y=1:ebit_blocks(1,x)
                
                    t_instant = request(1,rec); % reset t_instant

                    t_resourceUL = bits/R_UL(who_user,poss(j,1));
                    tw_UL = resource_availability(t_resourceUL,aps_timedivision{poss(j,1),1},t_instant);
                    t1 = t_instant;

                    t_instant = t_instant + tw_UL + t_resourceUL;
                    t_resourceBUL = bits/RB_UL(poss(j,1),poss(j,2));
                    t2 = t_instant;
                    tw_BUL = resource_availability(t_resourceBUL,vms_timedivision{poss(j,2),1},t_instant);

                    t_instant = t_instant + tw_BUL+ t_resourceBUL; 
                    t_vm_arrival= t_instant + latencies(poss(j,1),poss(j,2));
                    t3 = t_vm_arrival;
                    % rate = 10; % pending to specify rate
                    % t_VM_resource = bits/rate; % pending to specify rate
                    % depending on VM in use
                    t_VM_resource = 4;
                    tw_vm = resource_availability(t_VM_resource,vms_calc{poss(j,2)},t_vm_arrival);
                    tp_vm =  t_VM_resource + tw_vm;
                    %t_vm_arrival: time that arrive last bit to be able to process data

                    t_resourceBDL = bits/RB_DL(poss(j,1),poss(j,2)); 
                    t_instant = t_vm_arrival + tp_vm + latencies(poss(j,1),poss(j,2));
                    t4 = t_instant;
                    tw_BDL = resource_availability(t_resourceBDL,vms_timedivision{poss(j,2),2},t_instant); 

                    t_instant= t_instant + tw_BDL + t_resourceBDL;
                    t_resourceDL = bits/R_DL(who_user,poss(j,1));
                    t5 = t_instant;
                    tw_DL = resource_availability(t_resourceDL,aps_timedivision{poss(j,1),2},t_instant);
                    t_total= t_resourceUL+tw_UL+t_resourceBUL+tw_BUL+tp_vm+t_resourceBDL+tw_BDL+t_resourceDL+tw_DL + 2*latencies(poss(j,1),poss(j,2));

                    t_totals(1,y)= t_total;
                    j= j+1;
                end 
                
                j=register;
                
                [M,I] = min(t_totals); 
                t_total = M;
                % choose the best option in terms of time (for those options that have the same e/bit)
                
                if x==1 % set the respective possibility
                    j=I;
                    register;
                else
                    j=0; 
                    for aux=1:x-1
                        j=j+ebit_blocks(1,aux);
                    end
                    j=j+I;
                    register=j;
                end
                
                if t_total<=t_threshold 
                    % Success!=> Validation
                   disp('<><><><><><><><><><><><><><><><><><>SUCCESS<><><><><><><><><><><><><><><><><><><><><><><><><>');
                   disp('The user '); fprintf('\b');
                   disp(who_user);fprintf('\b'); 
                   disp(' has offloaded using AP '); fprintf('\b');
                   disp(poss(j,1));fprintf('\b');
                   disp(' and VM '); fprintf('\b');
                   disp(poss(j,2));
                
                   disp('PREVIOUS UL resource'); 
                   disp(poss(j,1));
                   disp(aps_timedivision{poss(j,1),1});
                   disp('PREVIOUS BUL resource');
                   disp(poss(j,2));
                   disp(vms_timedivision{poss(j,2),1});
                   disp('PREVIOUS VM resource');
                   disp(poss(j,2));
                   disp(vms_calc{poss(j,2)});
                   disp('PREVIOUS BDL resource');
                   disp(poss(j,2));
                   disp(vms_timedivision{poss(j,2),2});
                   disp('PREVIOUS DL resource');
                   disp(poss(j,1));
                   disp(aps_timedivision{poss(j,1),2});	 
		   
                   aps_timedivision{poss(j,1),1} = resource_validation(t_resourceUL,aps_timedivision{poss(j,1),1},t1);
                   vms_timedivision{poss(j,2),1} = resource_validation(t_resourceBUL,vms_timedivision{poss(j,2),1},t2);
                   vms_calc{poss(j,2)}= resource_validation(t_VM_resource,vms_calc{poss(j,2)},t3); 
                   vms_timedivision{poss(j,2),2} = resource_validation(t_resourceBDL,vms_timedivision{poss(j,2),2},t4);
                   aps_timedivision{poss(j,1),2} = resource_validation(t_resourceDL,aps_timedivision{poss(j,1),2},t5);
                  
                    
                   disp('The user created a request (seconds):');fprintf('\b');
                   disp(t1);
                   disp('ACTUAL UL resource'); 
                   disp(poss(j,1));
                   disp(aps_timedivision{poss(j,1),1});
                   disp('ACTUAL BUL resource');
                   disp(poss(j,2));
                   disp(vms_timedivision{poss(j,2),1});
                   disp('ACTUAL VM resource');
                   disp(poss(j,2));
                   disp(vms_calc{poss(j,2)});
                   disp('ACTUAL BDL resource');
                   disp(poss(j,2));
                   disp(vms_timedivision{poss(j,2),2});
                   disp('ACTUAL DL resource');
                   disp(poss(j,1));
                   disp(aps_timedivision{poss(j,1),2});		  
		   	
                   disp('VARS:');

                   disp('t_resourceUL:');fprintf('\b');
                   disp(t_resourceUL);
                   disp('tw_UL:');fprintf('\b');
                   disp(tw_UL);
                   disp('t_resourceBUL:');fprintf('\b');
                   disp(t_resourceBUL);
                   disp('tw_BUL:');fprintf('\b');
                   disp(tw_BUL);
                   disp('tw_vm:');fprintf('\b');
                   disp(tw_vm);
                   disp('t_VM_resource:');fprintf('\b');
                   disp(t_VM_resource);
                   disp('latency:');fprintf('\b');
                   disp(latencies(poss(j,1),poss(j,2)));
                   disp('tp_vm:');fprintf('\b');
                   disp(tp_vm);
                   disp('t_resourceBDL:');fprintf('\b');
                   disp(t_resourceBDL);
                   disp('tw_BDL:');fprintf('\b');
                   disp(tw_BDL);
                   disp('t_resourceDL:');fprintf('\b');
                   disp(t_resourceDL);
                   disp('tw_DL:');fprintf('\b');
                   disp(tw_DL);

                   disp('FINAL RESULT');
                   disp('Time needed:');fprintf('\b');
                   disp(t_total);
                   disp('Energy needed:');fprintf('\b');
                   e = poss(j,3) * bits;
                   disp(e);
             
                   disp('<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>');
                   br_flag = true;
                   break;

                else
                   
                   disp('--------------------------------------------FAIL----------------------------------------------');
                   disp('The user '); fprintf('\b');
                   disp(who_user);fprintf('\b'); 
                   disp(' could NOT offload using AP '); fprintf('\b');
                   disp(poss(j,1));fprintf('\b');
                   disp(' and VM '); fprintf('\b');
                   disp(poss(j,2));
                   
                   disp('VARS:');

                   disp('t_resourceUL:');fprintf('\b');
                   disp(t_resourceUL);
                   disp('tw_UL:');fprintf('\b');
                   disp(tw_UL);
                   disp('t_resourceBUL:');fprintf('\b');
                   disp(t_resourceBUL);
                   disp('tw_BUL:');fprintf('\b');
                   disp(tw_BUL);
                   disp('tw_vm:');fprintf('\b');
                   disp(tw_vm);
                   disp('t_VM_resource:');fprintf('\b');
                   disp(t_VM_resource);
                   disp('latency:');fprintf('\b');
                   disp(latencies(poss(j,1),poss(j,2)));
                   disp('tp_vm:');fprintf('\b');
                   disp(tp_vm);
                   disp('t_resourceBDL:');fprintf('\b');
                   disp(t_resourceBDL);
                   disp('tw_BDL:');fprintf('\b');
                   disp(tw_BDL);
                   disp('t_resourceDL:');fprintf('\b');
                   disp(t_resourceDL);
                   disp('tw_DL:');fprintf('\b');
                   disp(tw_DL);
                   disp('----------------------------------------------------------------------------------------------');
                   
                   b_flag=true;
                   if x==h2 
                    br_flag=true;
                   else 
                    br_flag=false;
                   end
                end
                
                if b_flag==true
                    break;
                end
                if br_flag==true
                    break;
                end
            end
            if br_flag==true
                    break;
            end
        end   
    end






