function twait = resource_availability(tresource,resource,t_instant)
    % tresource: time using the channel
    % resource: radio channel in use
    % t_instant: when this request is created 
    % Since the load can be divided when using certain resource,
    % as soon as possible the load could be transmitted, the load will be
    % delivered.
    
    % When tresource becomes 0 this task has been finished.
    
    twait=0;
    row = resource(1,:);
    ini = find(t_instant>row);
    [row,column] = size(ini);
    arrow = ini(column-1); 
    
    % t_instant location, 1st attempt
    
    if t_instant<resource(2,arrow)
        twait = resource(2,arrow)-t_instant;
        t_nextgap = resource(1,arrow+1)-resource(2,arrow);
    else 
        t_nextgap = resource(1,arrow+1)-t_instant;
    end 
   
    if t_nextgap<tresource
         tresource=tresource-tgap;
    else
         tresource=0;
    end
    
    % If the first gap found was not big enough, the system will keep
    % assigning resources until running out of bits (tresource=0)
    
    while tresource>0
        arrow=arrow+1;
        t_nextgap = resource(1,arrow+1)-resource(2,arrow);
        twait=twait+(resource(2,arrow)-resource(1,arrow));
        
        if t_nextgap<tresource && arrow ~= (column-1)
         tresource=tresource-tgap;
        else
         tresource=0;
        end
    end
end
