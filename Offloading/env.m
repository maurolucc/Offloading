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
prompt3 = 'App kind (1 o 2):';
app = input(prompt3);
prompt4 = 'lambda:';
lambda = input(prompt4);

% Rates assignation 
R_UL = randi([1 16],K,N);  
R_UL = rates_assignment(R_UL);
R_DL= randi([1 16],K,N); 
R_DL = rates_assignment(R_DL);

technologies = randi([1 6], N,M); 

RB_UL = rates_Bassignment(technologies); 
RB_DL = RB_UL; % Considering a symmetric backhaul link

vms_location = vms_assignment(M,app);
latencies = calculate_latency(technologies,vms_location(1,:));

mts_local_rates = mts_assignment(K,app);

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
    possibilities(count,1)= N+1; % this index indicates running in local
    possibilities(count,2)= M+1; % this index indicates running in local
    possibilities(count,3)= 0.004356; % average value for mobile terminals (J/s)
    possibilities = sortrows(possibilities,3); % order asc by energy
    container{i}=possibilities;
    % the possibilities matrix for the user i is allocated in container {i} 
end

% B. TIME FRAME CREATION

ti = 0;   
tf = 0;  

% Mobile terminals

mts_timedivison = {}; % {i} refers to mobile terminal i
for w=1:K
    mts_timedivision{w} = [ti;tf]; % local
end  

% Access radio channels
aps_timedivison = {}; % {i} refers to AP i
for t=1:(N+1) 
    aps_timedivision{t,1} = [ti;tf]; % UL
    aps_timedivision{t,2} = [ti;tf]; % DL
end    

% Backhaul radio channels and virtual machines
vms_timedivision = {}; % {i} refers to VM i 
vms_calc = {};         % {i} refers to VM i 
for s=1:M
    vms_timedivision{s,1} = [ti;tf]; % UL
    vms_timedivision{s,2} = [ti;tf]; % DL
    vms_calc{s} = [ti;tf];
end    

simtime = 10; % simulation time
requests = lambda; % mean number of requests per user
request = event_generator(K,requests,simtime,app);

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

% In case the possibility in study is local running, it will be directly
% assigned since it will always meet the t_threshold condition and the
% possible following options will be worse in terms of energy consumption.

rec = 0;
[s,f]=size(request);

RES_A = []; % MATRIX CONTAINS RESULTS FOR TEST A
for ra=1:K
  RES_A(ra,1)=0; % number of fails
  RES_A(ra,2)=0; % number of success
end

RES_B = []; % MATRIX CONTAINS RESULTS FOR TEST B
for rb=1:M
  RES_B(rb,1)=vms_location(1,rb);
  RES_B(rb,2)=latencies(1,rb);
  RES_B(rb,3)=0;
end


RES_D = [];
for rd=1:K
  RES_D(rd,1)= 0;
end

    while rec ~= f % until the buffer of requests is not empty
        rec = rec+1;
        disp('***********************************************************************************************');
        disp('                         REQUEST:'); fprintf('\b'); disp(rec);
        disp('***********************************************************************************************');

        who_user= request(2,rec);
        
        bits= request(3,rec);
        t_resourceMT = bits/ mts_local_rates(1,who_user); % local time execution
        twp=resource_availability(t_resourceMT, mts_timedivision{who_user}, request(1,rec));
        local_total = twp+t_resourceMT;
        t_threshold = 0 * local_total; 
        
        
        % t_threshold is set for every request since the local resource
        % could be busy and the criteria must consider this option.
        poss = container{who_user};
        
        ebit_blocks= getblocks_ebit(poss(:,3)); % group by energy/bit
        [h1, h2] = size(ebit_blocks);
        
        for x=1:h2 
        % Loop for each energy block
        % The comparisions are done as many times as the same  e/bit is repeated in different possibilites
        % and the previous combinations failed.
            t_totals = Inf(1,ebit_blocks(1,x));
            
            % This vector will be fullfilled with the t_total's calculated
            % in order to be able to compare among the possibilities with
            % the same energy/bit.
            
            register=1;
            
            for j=1:size(poss) 
                j=register;
                
                for y=1:ebit_blocks(1,x)
                % Loop for each possibility with the same energy/bit
                
                    t_instant = request(1,rec); % reset t_instant
              
                    if poss(j,1)== N+1 && poss(j,2)== M+1 
                        break;
                    end
                    
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
                    
                    t_VM_resource = bits/vms_location(2,poss(j,2)); 
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
                
                [minim,I] = min(t_totals); 
                t_total = minim;
                % choose the best option in terms of time (for those options that have the same e/bit)
                
                if x==1 % set the respective possibility
                    j=I;
                else
                    j=0; 
                    for aux=1:x-1
                        j=j+ebit_blocks(1,aux);
                    end
                    j=j+I;
                    register=j;
                end
                
                if poss(j,1)== N+1 && poss(j,2)== M+1 
                    % Local running has been reached as the best option
                    mts_timedivision{who_user} = resource_validation(t_resourceMT,mts_timedivision{who_user},request(1,rec));
                    % It will always meet the condition t_threshold.
                    % Consequently is directly assigned.
                     disp('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
                     disp('local');
                     disp('&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&');
                     disp('The user '); fprintf('\b');
                     disp(who_user);fprintf('\b'); 
                     disp(' has computed in local.');
                     disp('The user needed ');fprintf('\b'); disp(local_total);
                     disp('s tho have the process end.');
                     disp('It was consumed '); fprintf('\b'); disp(0.004356*bits);
                     disp('J');

                    RES_A(who_user,1)= RES_A(who_user,1)+1;
                    RES_D(who_user,1)= RES_D(who_user,1) + (0.004356*bits);
                    
                    br_flag=true;
                    break;
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
                   disp(t_total);fprintf('\b'); disp('<'); disp(t_threshold);
                   disp('Energy needed:');fprintf('\b');
                   e = poss(j,3) * bits;
                   disp(e);

                   RES_A(who_user,2)= RES_A(who_user,2)+1;
                   RES_B(poss(j,2),3)= RES_B(poss(j,2),3)+1;
                   
                   RES_D(who_user,1)=RES_D(who_user,1)+e;
    
                   disp('<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>');
                   
                   percentage = t_total/t_threshold;
                   
                   porfin= 0.0206*bits;
                   porfin2= t_threshold/1.3;
                   d_aux = porfin-e;
                   t_weird= t_total-porfin2;
                   d_aux_p = (d_aux/porfin)*100;
                   t_weird_p = (t_weird/porfin2)*100;

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
                   
                   disp('Time needed:');fprintf('\b');
                   disp(t_total); disp('>'); disp(t_threshold);
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
    
   






