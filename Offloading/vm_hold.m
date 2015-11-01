function thold = vm_hold(vm, bits, t_vm_arrival)
    % vm: indicates which vm is requested
    % bits: amount to be processed
    % t_vm_arrival: when this request arrives to the vm (last bit)
    
    % calc/rate for each vm...(b/s) TODO 
    
    % Here is where VM power is taken into account.
    tcalc = bits/calc_rate;
    % When tcalc becomes 0 this task has been finished.
    twait=0;
    row = vm(1,:);
    ini = find(t_vm_arrival>row);
    [row,column] = size(ini);
    arrow = ini(column-1); 
    
    
    if t_vm_arrival<vm(2,arrow)
        twait = vm(2,arrow)-t_vm_arrival;
        t_nextgap = vm(1,arrow+1)-vm(2,arrow);
    else 
        t_nextgap = vm(1,arrow+1)-t_vm_arrival;
    end
    
    if t_nextgap>=tcalc
        tcalc=0;
    end
    
    % If we were not lucky...
    % There's no data partition to data processing
    
    while tcalc>0
        arrow=arrow+1;
        if arrow == column
            thold= inf;
            break;
        end
        t_nextgap = vm(1,arrow+1)-vm(2,arrow);
        twait=twait+(vm(2,arrow)-vm(1,arrow));
        if t_nextgap>tcalc
         tcalc=0;
        end
    end
    
    thold = tcalc + twait; % time in vm
end