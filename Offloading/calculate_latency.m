function latencies =calculate_latency(technologies, vms_location)
    [r,c]=size(technologies);
    for i=1:r
        for j=1:c
            distance = vms_location(j);
            if vms_location(j)== 30 % located practically in the same city
                latencies(i,j)= 0;
            else
                if technologies(i,j)<=3
                    latencies(i,j)= (distance*1.57)/3e8;
                else
                    latencies(i,j)= distance/3e8;
                end
            end
        end
    end    
end
