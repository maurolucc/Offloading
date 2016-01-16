function res = resource_validation(tresource,resource,t_instant)
% This function validates decisions. Status of the resource is updated and
% returned.

% tresource: time that the resource will be busy due to this request
% resource: which resource will serve this request
% t_instant: when this request arrives to this certain resource

    res = resource; % old and new one must be preserved 
    row = resource(1,:); % all
    ini1 = find(t_instant>row); % major
    ini2 = find(t_instant<row); % menor
    [l,m] = size(row);
    [l1,m1] = size(ini1);
    [l2,m2] = size(ini2);
    
    % A. ARROW ALLOCATION 
    
    if m==1 % First attempt
        new =[t_instant;t_instant+tresource];
        res = [new res];
        return; % function job done
    elseif m1==1 % protecting out of index
        arrow = ini1(1,1);
    else
        arrow = ini1(1,m1-1);
    end
    
    
    % B. FIRST ATTEMPT 
    
    if m2==m-1 % just for two columns
         % Consider: the request can arrive before any booked time frame
         % specially in backhaul
         t_nextgap = resource(1,1) - t_instant;
         if t_nextgap>tresource  
             new = [t_instant;t_instant+tresource];
             res = [new res];
             return;% function job done
         elseif t_nextgap==tresource 
             res(1,1)=t_instant;
             return;% function job done
         else
             res(1,1)=t_instant;
             tresource = tresource - t_nextgap;
             arrow = 1;
         end
    end 
    
    if t_instant<resource(2,arrow) % the resource is busy 
        t_nextgap = resource(1,arrow+1)-resource(2,arrow);
        if t_nextgap>0 
             if t_nextgap<tresource
                 res(2,arrow)= res(2,arrow+1);
                 tresource=tresource-t_nextgap;
             elseif t_nextgap==tresource
                    res(2,arrow)= resource(2,arrow+1);
                    tresource=0;
             else
                     res(2,arrow)= resource(2,arrow)+tresource;
                     tresource=0;
             end
        else % just for arrow+1 is the last column (zeros)
            res(2,arrow)= res(2,arrow)+tresource;
            tresource=0;
        end
    else  % the resource is free 
        if m~=1 && resource(2,arrow)~=0
            t_nextgap = resource(1,arrow+1)-t_instant;
            
            if t_nextgap<tresource 
                 res(1,arrow+1) = t_instant;
                 if t_nextgap>0  
                    tresource=tresource-t_nextgap;
                 else
                    res(2,arrow+1)=t_instant+tresource;
                    tresource=0; 
                 end
            elseif t_nextgap==tresource
                res(1,arrow+1) = t_instant;
                tresource=0;
            else
                 ti=t_instant;
                 tf=t_instant+tresource;
                 intro = [ti;tf];
                 % introduce a new column in the middle of the matrix
                 res = [res(:,1:arrow), intro, res(:, arrow+1:end)]; 
                 tresource=0;
            end
        else 
                 ti=t_instant;
                 tf=t_instant+tresource;
                 res = [ti;tf]; 
                 tresource=0;
        end
    end
    
    % C. RECURSIVE SEARCH
    
    while tresource>0
        
        arrow=arrow+1;
        if arrow >= m-1   % avoid out of index
            t_nextgap = inf;
           break;
        else
            t_nextgap = resource(1,arrow+1)-resource(2,arrow);

            if t_nextgap<tresource && arrow ~= (m1-1)
                 tresource=tresource-t_nextgap;
                 res(2,arrow)=res(2,arrow+1);
            elseif t_nextgap==tresource && arrow ~= (m1-1)
                  res(2,arrow)=res(2,arrow+1);
                  tresource=0;
            else
                  res(2,arrow)=res(2,arrow)+tresource;
                  tresource=0;
            end
        end
    end
       
    % D. MAKE UP RESOURCE MATRIX
    
    [q,w]= size(res);
    last_column = res(:,w);
    
    for i=1:(w-1)
    [q2,w2]= size(res);
        if w2<=i
            if res(:,i)~=0
                if res(1,i+1)<res(2,i) && res(2,i+1)<=res(2,i)
                    res(:,i+1)=[];
                elseif (res(1,i+1)<res(2,i) && res(2,i+1)>res(2,i)) || res(1,i+1)==res(2,i) 
                    res(2,i)=res(2,i+1);
                    res(:,i+1)=[];
                end
            end
        else
            break;
        end
    end
    
  if last_column~=0 % add necessary column of zeros if needed
        z=[0;0];
        res=[res z];
  end
end
