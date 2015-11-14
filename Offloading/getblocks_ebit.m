function gr = getblocks_ebit(ebit_column)
    % This function returns the indexes to group the possiblities in terms
    % of E/bit. 
    
    var = 1;
    s = 0;
    c=1;
    [v1,v2] = size(ebit_column);

    while s < v1
        best_option = ebit_column(s+1,1);
        var = sum(ebit_column==best_option);
        gr(c) = var;
        c = c+1;
        var = var+1;
        s = sum(gr);
    end       
end