function res = resource_validation(tresource,resource,t_instant)

% This function validates the new inputs in all the 
    res = resource;
    row = resource(1,:);
    ini = find(t_instant>row);
    [row,column] = size(ini);
    arrow = ini(column-1); 
    
    if t_instant<resource(2,arrow) 
        t_nextgap = resource(1,arrow+1)-resource(2,arrow);
        if t_nextgap<tresource
         res(2,arrow)= res(2,arrow+1);
         tresource=tresource-tgap;
        elseif tnextgap==tresource
            res(2,arrow)= resource(2,arrow+1);
            tresource=0;
        else
             res(2,arrow)= resource(2,arrow)+tresource;
             tresource=0;
        end
        
    else 
        t_nextgap = resource(1,arrow+1)-t_instant;
        if t_nextgap<tresource
         res(1,arrow+1) = t_instant;
         tresource=tresource-tgap;
         
        elseif tnextgap==tresource
            res(1,arrow+1) = t_instant;
            tresource=0;
        else
             ti=t_instant;
             tf=t_instant+t_resource;
             intro = [ti;tf];
             % introduce a new column in the middle of the matrix
             res = [res(:,1:arrow+1), intro, res(:, arrow+2:end)]; 
             tresource=0;
        end
    end 
   
   % If the tresource is still not zero.
    while tresource>0
        arrow=arrow+1;
        t_nextgap = resource(1,arrow+1)-resource(2,arrow);
        
        if t_nextgap<tresource && arrow ~= (column-1)
             tresource=tresource-tgap;
             res(2,arrow)=res(2,arrow+1);
        elseif t_nextgap==tresource && arrow ~= (column-1)
              res(2,arrow)=res(2,arrow+1);
              tresource=0;
        else
              res(2,arrow)=res(2,arrow)+tresource;
              tresource=0;
        end
    end
    
    % clean outdated columns
    for i=1:(size(res)-1)
        if res(1,i+1)<res(2,i) && res(2,i+1)<=res(2,i)
            res(:,i+1)=[];
        elseif (res(1,i+1)<res(2,i) && res(2,i+1)>res(2,i)) || res(1,i+1)==res(2,i) 
            res(2,i)=res(2,i+1);
            res(:,i+1)=[];
        end
    end

end