function e_bit=ebit(rul,rdl)

    Ptx= 0.1;   % Ptmax (W) Tx power
    ktx1= 0.4;  % W
    ktx2= 18;   
    krx1= 0.4 ; % W
    krx2= 2.86 * 10e-6; % W/bps
    
    pul= ktx1 + ktx2*Ptx;
    pdl= krx1 + krx2*rdl;
    
    e_bit= (pul/rul)+(pdl/rdl);
    
end