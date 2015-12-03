function mts_assignment = mts_assignment(M,app_index)
    % This function assigns a rate to a mobile terminal in terms of
    % computational power depending on the kind of app running.
    
    % In this simulator there are five kind of terminals considered that
    % correspond to the five columns.
    % Depending on the app the function will assign rates from one row or
    % another. To add a new app in the case study, add a new row with the
    % correspondant reasonable rates.
    
    rates_app = [2.6 1.05 0.79 0.62 0.3;4 1.62 1.22 0.96 0.47]; % MB/s
    for i=1:M
        mts_assignment(1,i) = randsample(rates_app(app,:),1)*10e6*8; % b/s
    end
    
end