% tic;
% disp('Esperando...');
% pause(5);
% t=tic;
% disp(t);
% pause(2);
% k=toc;
% disp(k);

% z =clock;
% pause(4);
% disp(etime(clock, z));
% pause(6);
% disp(etime(clock,z));

% A= [21 22 23 24 25 26 0; 27 28 29 210 211 212 0];
% row = A(1,:);
% ini = find(23.56>row);
% [r,c] = size(ini);
% x= ini(c-1);

% A = [1 2 3 4 5; 11 22 33 44 55]
% A = circshift(A, [0, -1])
% A = A(:,1:end-1);
% disp(A);

% for i=1:15
%     if i == 8
%         disp('BREAK');
%         break;
%     end
%     disp(i);
% end


% A = [1,2,3,4,5,6;1,2,3,4,5,6];
% B = [0;0];
% 
% disp(A);
% 
% A = [A(:,1:2), B, A(:, 3:end)];
% 
% disp(A);
% 


% res = [1,2,3,4,5,6;1,2,3,4,5,6];
% intro = [19;20];
% arrow = 2;
% res = [res(:,1:arrow), intro, res(:,arrow+1:end)];
% disp(res);



% A = [21 22 23 24 25 26 27 0];
% disp(A);
% ini = find(23.4>A);
% disp(ini);
% [l, m] = size(ini);
% arrow = ini(1,m-1);
% disp(arrow);
% 
% aps = {};
% aps{1,1} = [1 1;1 1];
% aps{1,2} = [1 1;2 2];
% aps{2,1} = [2 2;1 1];
% aps{2,2} = [2 2;2 2];
% 
% disp(aps{2,2});

%  res = [22 55 58 0;30 56 89 0];
% row = res(1,:);
% disp(row);
% ini = find(57>row);
% disp(ini);
% [l,m] = size(ini);
% disp(m);
% 
%         arrow = ini(1,m-1);
%    
% fileID = fopen('exp.txt','w');
% fprintf(fileID,'%6s %12s\n','x','exp(x)');
% fprintf(fileID,'%6.2f %12.8f\n',res);
% fclose(fileID);

 res = [3;3;4;4;4;5;5;5;5;5;5;7;7;7;7;7;8;8;10];
 k= getblocks_ebit(res);
 disp(k);
% 
% disp(sum(res));
%         best_option = res(1,1);
%         var = sum(res==best_option);
%         disp(var);
    
% 
% temps= [1.5, 5.6, 8.4, 0.9];
% 
% [M,I] = min(temps); 
% disp(M),
% disp(I);