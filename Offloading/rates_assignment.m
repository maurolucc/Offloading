function rates_assignment=rates_assignment(RateIndexMatrix)

    % MCS (Modulation and Coding Schemes)
    % Each value represent the number of information bits that can be
    % transmitted in one RE (Resource element) for an specific combination 
    % of modulation and redundancy coding scheme
    % Although some terminals cannot transmit using certain modulations,
    % the MCS table is both used for uplink and downlink.
    
    MCS_Table=[0 0.1523 0.2344 0.3770 0.6016 0.8770 1.1758 1.4766 1.9141 2.4063 2.7305 3.3223 3.9023 4.5234 5.1152 5.5547];
   
    [r,c] = size(RateIndexMatrix);
    for i=1:r
        for j=1:c
            % assuming BW=20MHz-->100 PRB (Physical resource block)
            % PRB is the minimum resource radio unit
            % PRB = 12 carriers*0.5ms = 12carries*7 OFDM symbols =
            % = 84REs/ 0.5ms
            % Just an 88.95% (149436/168000 REs in 10ms) tranmit data. The
            % rest are used for control, synchronization,etc.
            MCS = MCS_Table(1,RateIndexMatrix(i,j));
            rate = MCS*84/0.5e-3*100*0.8895;
            % Rate=MCS(bits)* 84REs/0.5ms * 100PRBs * 0.8895 (%data) 
            rates_assignment(i,j)= rate;
        end    
    end    
end