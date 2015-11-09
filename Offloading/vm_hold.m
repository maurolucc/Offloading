function twait = vm_hold(tcalc,vm, t_vm_arrival)
    % vm: indicates which vm is requested
    % bits: amount to be processed
    % t_vm_arrival: when this request arrives to the vm (last bit)

    % When tcalc becomes 0 this task has been finished.
    twait=0;
    row = vm(1,:);
    ini = find(t_vm_arrival>row);
    [l,m] = size(ini);
    if m==1 
        arrow = ini(1,1); %first access
    else
        arrow = ini(1,m-1);
    end

    if t_vm_arrival<vm(2,arrow)
        twait = vm(2,arrow)-t_vm_arrival;
        t_nextgap = vm(1,arrow+1)-vm(2,arrow);
        if t_nextgap<0
            t_nextgap=inf;
        end
    else
        if m~=1
            t_nextgap = vm(1,arrow+1)-t_vm_arrival;
        else 
            t_nextgap= inf;
        end
    end
    
    if t_nextgap>=tcalc
        tcalc=0;
    end
    
    % If we were not lucky...
    % There's no data partition to data processing
    
    while tcalc>0
        arrow=arrow+1;
        if arrow >= m-1
            twait=twait+(vm(2,arrow)-vm(1,arrow));
            break;
        end
        t_nextgap = vm(1,arrow+1)-vm(2,arrow);
        twait=twait+(vm(2,arrow)-vm(1,arrow));
        if t_nextgap>tcalc
         tcalc=0;
        end
    end
    
end