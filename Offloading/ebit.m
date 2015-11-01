function e_bit=ebit(rul,rdl)
    % E = Ecommunication + Ecomputation;
    % Ecom = Pul* t_tx + Pdl * t_rx;
    % Pul= ktx1 + ktx2*Ptx;
    % Pdl= krx1 + krx2*rdl;
    
    Ptx= 0.1;   % Ptmax (W) Tx power
    ktx1= 0.4;  % W
    ktx2= 18;   % W
    krx1= 0.4 ; % W
    krx2= 2.86; % W/Mbps
    
    pul= ktx1 + ktx2*Ptx;
    pdl= krx1 + krx2*rdl;
    
    e_bit= (pul/rul)+(pdl/rdl);
end