% the perceptron

%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
    function [w, err] = perceptron(X,Y,w_init)

    max_iteration = 1000;    % maximum numbre of iterations
    err_tol = 0.01;         % misclassification rate tolerance
    w = w_init;
    for iteration = 1 : max_iteration,
        for ii = 1 : size(X,2)         % cycle through training set
            if sign(w'*X(:,ii)) ~= Y(ii) % wrong decision?
                w = w + X(:,ii) * Y(ii);   % then add (or subtract) this point to w
            end
        end
        if sum(sign(w'*X)~=Y)/size(X,2) < err_tol ,   % stopping crietria misclassification rate
            break;
        end
    end
    err = sum(sign(w'*X)~=Y)/size(X,2); % misclassification rate
%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%



% simple example
% data points
X=[0 0 1 1; 0 1 0 1; 1 1 1 1;];

% correct classification [-1,+1]
Y=[-1 1 1 1];             % or
Y=[-1 -1 -1 1];          % and

% init weigth vector
w_init=[.25 .25 .25];
[w, err] = perceptron(X, Y, w_init');

figure, hold on
% plots correct classification
plot(X(1,Y==-1),X(2,Y==-1),'bx')
plot(X(1,Y==1),X(2,Y==1),'rx')
% plots predicted classification
Yp = sign(w'*X);
plot(X(1,Yp==-1),X(2,Yp==-1),'bo')
plot(X(1,Yp==1),X(2,Yp==1),'ro')
legend('class -1','class +1','pred -1','pred +1')
hold off


% larger example
% random data points
% data points
X = rand(2, 1000);
X(3,:) = 1;

% correct classification [-1 1]
Y = X(2,:)>1*X(1,:).^4 + 0.25;
Y = 2*Y-1;

% init weigth vector
w_init = [.5 .5 .5]';

% call perceptron
[w, err] = perceptron(X,Y,w_init);


figure, hold on
% plots correct classification
plot(X(1,Y==-1),X(2,Y==-1),'bx')
plot(X(1,Y==1),X(2,Y==1),'rx')
% plots predicted classification
Yp = sign(w'*X);
plot(X(1,Yp==-1),X(2,Yp==-1),'bo')
plot(X(1,Yp==1),X(2,Yp==1),'ro')
legend('class -1','class +1','pred -1','pred +1')
hold off



% data reshaping...
YY = Y; YY(Y==-1) = 2;
XX = X(1:2,:)';

% logistic regression
B = mnrfit(XX, YY);

figure;hold on
% plots correct classification
plot(X(1,Y==-1),X(2,Y==-1),'bx')
plot(X(1,Y==1),X(2,Y==1),'rx')
% plots predicted classification
YYp = mnrval(B, XX);
plot(X(1,YYp(:,1)<YYp(:,2)),X(2,YYp(:,1)<YYp(:,2)),'bo')
plot(X(1,YYp(:,1)>=YYp(:,2)),X(2,YYp(:,1)>=YYp(:,2)),'ro')
legend('class -1','class +1','pred -1','pred +1')
hold off


% the xor problem
% data points
X=[0 0 1 1; 0 1 0 1; 1 1 1 1;];

% correct classification [-1,+1]
Y = [-1 1 1 -1];         % xor

% init weigth vector
w_init=[.25 .25 .25];
[w, err] = perceptron(X, Y, w_init');

figure, hold on
% plots correct classification
plot(X(1,Y==-1),X(2,Y==-1),'bx')
plot(X(1,Y==1),X(2,Y==1),'rx')
% plots predicted classification
Yp = sign(w'*X);
plot(X(1,Yp==-1),X(2,Yp==-1),'bo')
plot(X(1,Yp==1),X(2,Yp==1),'ro')
legend('class -1','class +1','pred -1','pred +1')
hold off

% solution to the xor problem: *handcrafted* features
% data points

X=[1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1; 1 1 1 1;]; % with 1000->11, 0100->10, 0010->01 and 0001->00

% correct classification [-1,+1]
Y = [-1 1 1 -1];         % xor

% init weigth vector
w_init=[.25 .25 .25 .25 .25];
[w, err] = perceptron(X, Y, w_init');
Yp = sign(w'*X);


% or, even better, multilayer perceptrons...

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [Wx,Wy,MSE]=trainMLP(p,H,m,mu,alpha,X,D,epochMax,MSETarget)
    % The matrix implementation of the Backpropagation algorithm for two-layer
    % Multilayer Perceptron (MLP) neural networks.
    %
    % Author: Marcelo Augusto Costa Fernandes
    % DCA - CT - UFRN
    % mfernandes@dca.ufrn.br
    %
    % Input parameters:
    %   p: Number of the inputs.
    %   H: Number of hidden neurons
    %   m: Number of output neurons
    %   mu: Learning-rate parameter
    %   alpha: Momentum constant
    %   X: Input matrix.  X is a (p x N) dimensional matrix, where p is a number of the inputs and N is a training size.
    %   D: Desired response matrix. D is a (m x N) dimensional matrix, where m is a number of the output neurons and N is a training size.
    %   epochMax: Maximum number of epochs to train.
    %   MSETarget: Mean square error target.
    %
    % Output parameters:
    %   Wx: Hidden layer weight matrix. Wx is a (H x p+1) dimensional matrix.
    %   Wy: Output layer weight matrix. Wy is a (m x H+1) dimensional matrix.
    %   MSE: Mean square error vector.

    [p1 N] = size(X);
    bias = -1;
    X = [bias*ones(1,N) ; X];
    Wx = rand(H,p+1);
    WxAnt = zeros(H,p+1);
    Tx = zeros(H,p+1);
    Wy = rand(m,H+1);
    Ty = zeros(m,H+1);
    WyAnt = zeros(m,H+1);
    DWy = zeros(m,H+1);
    DWx = zeros(H,p+1);
    MSETemp = zeros(1,epochMax);
    
    for i=1:epochMax

        % forward sweep
        k = randperm(N);
        X = X(:,k);
        D = D(:,k);
        V = Wx*X;
        Z = 1./(1+exp(-V));
        S = [bias*ones(1,N);Z];
        G = Wy*S;
        Y = 1./(1+exp(-G));
        E = D - Y;
        mse = mean(mean(E.^2));
        MSETemp(i) = mse;
        %disp(['epoch = ' num2str(i) ' mse = ' num2str(mse)]);
        if (mse < MSETarget)
            MSE = MSETemp(1:i);
            return
        end

        % backpropagation
        df = Y.*(1-Y);
        dGy = df .* E;
        DWy = mu/N * dGy*S';
        Ty = Wy;
        Wy = Wy + DWy + alpha*WyAnt;
        WyAnt = Ty;
        df= S.*(1-S);
        dGx = df .* (Wy' * dGy);
        dGx = dGx(2:end,:);
        DWx = mu/N* dGx*X';
        Tx = Wx;
        Wx = Wx + DWx + alpha*WxAnt;
        WxAnt = Tx;
    end
    MSE = MSETemp;
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Y=runMLP(X,Wx,Wy)
    % The matrix implementation of the two-layer Multilayer Perceptron (MLP) neural networks.
    %
    % Author: Marcelo Augusto Costa Fernandes
    % DCA - CT - UFRN
    % mfernandes@dca.ufrn.br
    %
    % Input parameters:
    %   X: Input neural network.  X is a (p x K) dimensional matrix, where p is a number of the inputs and K >= 1.
    %   Wx: Hidden layer weight matrix. Wx is a (H x p+1) dimensional matrix.
    %   Wy: Output layer weight matrix. Wy is a (m x H+1) dimensional matrix.
    %
    % Output parameters:
    %  Y: Outpuy neural network.  Y is a (m x K) dimensional matrix, where m is a number of the output neurons and K >= 1.
    
    [p1 N] = size (X);
    bias = -1;
    X = [bias*ones(1,N) ; X];
    V = Wx*X;
    Z = 1./(1+exp(-V));
    S = [bias*ones(1,N);Z];
    G = Wy*S;
    Y = 1./(1+exp(-G));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
% xor problem
% data points
X=[1 1; 0 1; 1 0; 0 0;]';

% correct classification
Y = [0 1 1 0];

% parameters
p = 2;          % p: Number of the inputs.
H = 4;          % H: Number of hidden neurons
m = 1;          % m: Number of output neurons
mu = .75;       % mu: Learning-rate parameter
alpha = 0.001;  % alpha: Momentum constant
epoch = 4000;   % Maximum number of epochs to train
MSEmin = 1e-20; % Mean square error target

% train
[Wx,Wy,MSE]=trainMLP(p,H,m,mu,alpha,X,Y,epoch,MSEmin);

% show learning
semilogy(MSE);

figure, hold on
% plots correct classification
plot(X(1,Y==0),X(2,Y==0),'bx')
plot(X(1,Y==1),X(2,Y==1),'rx')
% plots predicted classification
Yp = round(runMLP(X,Wx,Wy));
plot(X(1,Yp==0),X(2,Yp==0),'bo')
plot(X(1,Yp==1),X(2,Yp==1),'ro')
legend('class -1','class +1','pred -1','pred +1')
hold off



% larger example from the beginning
% data points
X = rand(2, 1000);
%X(3,:) = 1; % bias

% correct classification [0 1]
Y = X(2,:)>1*X(1,:).^4 + 0.25;
%Y = 2*Y-1;

% parameters
p = 2;          % p: Number of the inputs.
H = 20;          % H: Number of hidden neurons
m = 1;          % m: Number of output neurons
mu = .75;       % mu: Learning-rate parameter
alpha = 0.001;  % alpha: Momentum constant
epoch = 10000;   % Maximum number of epochs to train
MSEmin = 1e-20; % Mean square error target

% train
[Wx,Wy,MSE]=trainMLP(p,H,m,mu,alpha,X,Y,epoch,MSEmin);

% show learning
figure, semilogy(MSE);

figure, hold on
% plots correct classification
plot(X(1,Y==0),X(2,Y==0),'bx')
plot(X(1,Y==1),X(2,Y==1),'rx')
% plots predicted classification
Yp = round(runMLP(X,Wx,Wy));
plot(X(1,Yp==0),X(2,Yp==0),'bo')
plot(X(1,Yp==1),X(2,Yp==1),'ro')
legend('class -1','class +1','pred -1','pred +1')
hold off
        
        
        
        
        
