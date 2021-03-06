function twait = resource_availability(tresource,resource,t_instant)
 % This function returns possible waiting time in a resource (channel).
 % The process can be fragmented.
 
    % tresource: time using the channel
    % resource: radio channel in use
    % t_instant: when this request is created 
    % Since the load can be divided when using certain resource,
    % as soon as possible the load could be transmitted, the load will be
    % delivered.
    
    % When tresource becomes 0 this task has been finished.
    
    twait=0;
    row = resource(1,:);
    ini1 = find(t_instant>row);
    ini2 = find(t_instant<row);
    [l,m] = size(row);
    [l1,m1] = size(ini1);
    [l2,m2] = size(ini2);
   
    if m==1 
        twait=0;
        return;
    elseif m1==1
        arrow = 1;
    else
        arrow = ini1(1,m1-1);
    end
    
    if m2==m-1 % just in case arrives before any time frame booked
     t_nextgap = resource(1,1) - t_instant;
     
     if t_nextgap>=tresource
         twait = 0;
         return;
     else
         tresource = tresource - t_nextgap;
         t_instant = resource(1,1);
         arrow = 1;
     end
     
    end
     
    
    % t_instant location, 1st attempt
    
    if t_instant<resource(2,arrow)
        twait = resource(2,arrow)-t_instant;
        if m~=1
            t_nextgap = resource(1,arrow+1)-resource(2,arrow);
            if t_nextgap<0 % if it's negative it means we are in the last column
                t_nextgap = inf; % correction
            end
        else
            t_nextgap = inf;
        end
        
    else
        if m~=1
            t_nextgap = resource(1,arrow+1)-t_instant;
            if t_nextgap<0
                t_nextgap = inf;
            end
        else
                t_nextgap = inf;
        end
    end 
 
   
    if t_nextgap<tresource
         tresource=tresource-t_nextgap;
    else
         tresource=0;
    end
    
    % If the first gap found was not big enough, the system will keep
    % assigning resources until running out of bits (tresource=0)
    
    while tresource>0
        arrow=arrow+1;
        if arrow >= m1-1    % avoid out of index
            twait=twait+(resource(2,arrow)-resource(1,arrow));
           break;
        else
            t_nextgap = resource(1,arrow+1)-resource(2,arrow);
            twait=twait+(resource(2,arrow)-resource(1,arrow));

            if t_nextgap<tresource && arrow ~= (column-1)
             tresource=tresource-t_nextgap;
            else
             tresource=0;
            end
        end
    end
end
