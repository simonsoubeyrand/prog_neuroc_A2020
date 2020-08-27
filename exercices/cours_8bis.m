clear all
rng('shuffle')

% bogus data with lots of factors
N = 1002;
n = 100;
x = randn(N,n);
x2 = [ones(N,1) x];                     % add a column with 1's at the beginning!!!
B = randn(n+1,1);
err =  2*randn(N,1);
y = x2*B + err;

% regression standard
[B_est,BINT,R,RINT,STATS] = regress(y,x2);  % must have the column with ones
% B_est = inv(x2'*x2)*x2'*y
yp = x2*B_est;

r_square = 1-sum((yp-y).^2)/sum((y - mean(y)).^2)
% r_square = STATS(1)

figure, plot(yp, y, 'ok')



% est-ce que ca generalise? predit de nouvelles donnees?
% cross-validation

% splitting the data
index = randperm(N);
training_set = index(1:N/2);                % 1/2 of the data
test_set = index(N/2+1:2*N/2);      % 1/2 of the data

% training model with training set
[B_est,BINT,R,RINT,STATS] = regress(y(training_set),x2(training_set,:));
yp = x2(training_set,:)*B_est;
r_square = 1-sum((yp-y(training_set)).^2)/sum((y(training_set) - mean(y(training_set))).^2)

% testing model with independant test set
yp = x2(test_set,:)*B_est;
r_square_pred = 1-sum((yp-y(test_set)).^2)/sum((y(test_set) - mean(y(test_set))).^2)

% repeat to have a better estimate of your predicted r_square
for ii = 1:100,
    % splitting the data
    index = randperm(N);
    training_set = index(1:N/2);                % 1/2 of the data
    test_set = index(N/2+1:2*N/2);      % 1/2 of the data
    
    % training model with training set
    [B_est,BINT,R,RINT,STATS] = regress(y(training_set),x2(training_set,:));
    yp = x2(training_set,:)*B_est;
    r_squares(ii) = 1-sum((yp-y(training_set)).^2)/sum((y(training_set) - mean(y(training_set))).^2);
    
    % testing model with independant test set
    yp = x2(test_set,:)*B_est;
    r_squares_pred(ii) = 1-sum((yp-y(test_set)).^2)/sum((y(test_set) - mean(y(test_set))).^2);
end
mean(r_squares)
mean(r_squares_pred)



% cross-validation with hyperparameters

% ridge regression
k = 0;
B_est = ridge(y, x2, k, 1);   % with the 1 at the end, must have a column with 1's in the x
% B_est = inv(x2'*x2 + k*eye(length(B)))*x2'*y
yp = x2*B_est;

r_square2 = 1-sum((yp-y).^2)/sum((y - mean(y)).^2)

% cross-validation : three-way holdout method
% splitting the data
index = randperm(N);
training_set = index(1:N/3);                % 1/3 of the data
validation_set = index(2*N/3+1:end);        % 1/3 of the data
test_set = index(N/3+1:2*N/3);      % 1/3 of the data

% training the models with for every hyperparameter values with training set
k = 0:.01:30;
B_est = ridge(y(training_set), x2(training_set,:), k, 1);

% validating the models with validation set
yp = x2(validation_set,:)*B_est;
r_squares = 1-sum((yp-repmat(y(validation_set),1, length(k))).^2, 1)./sum((y(validation_set) - mean(y(validation_set))).^2);

figure, plot(k, r_squares)
[greatest_r_square best_k_index] = max(r_squares);
best_k = k(best_k_index);
hold on
plot(k(best_k_index), greatest_r_square, '*r')
hold off

% combine training_set and validation_set to train the model on as much data as possible with the
% best hyperparameter
final_B = ridge(y([training_set validation_set]), x2([training_set validation_set],:), best_k, 1);

% test the best model on test set
final_yp = x2(test_set,:)*final_B;
final_r_square = 1-sum((final_yp-y(test_set)).^2)/sum((y(test_set) - mean(y(test_set))).^2)

% shipping model
shipping_B = ridge(y([training_set validation_set test_set]), x2([training_set validation_set test_set],:), best_k, 1)



% We can repeat and average final_r_squares to obtain a better estimate.
% This is called Repeated random sub-sampling validation.

for jj = 1:100,
    % cross-validation : three-way holdout method
    % splitting the data
    index = randperm(N);
    training_set = index(1:N/3);                % 1/3 of the data
    validation_set = index(2*N/3+1:end);        % 1/3 of the data
    test_set = index(N/3+1:2*N/3);      % 1/3 of the data
    
    
    % training the models with for every hyperparameter values with training set
    k = 0:.1:10;
    B_est = ridge(y(training_set), x2(training_set,:), k, 1);
    
    % validating the models with validation set
    yp = x2(validation_set,:)*B_est;
    r_squares = 1-sum((yp-repmat(y(validation_set),1, length(k))).^2, 1)./sum((y(validation_set) - mean(y(validation_set))).^2);
    
    [greatest_r_square best_k_index] = max(r_squares);
    best_ks(jj) = k(best_k_index);
    
    % combine training_set and validation_set to train the model on as much data as possible with the
    % best hyperparameter
    final_B = ridge(y([training_set validation_set]), x2([training_set validation_set],:), best_ks(jj), 1);
    
    % test the best model on test set
    final_yp = x2(test_set,:)*final_B;
    final_r_squares(jj) = 1-sum((final_yp-y(test_set)).^2)/sum((y(test_set) - mean(y(test_set))).^2);
    
    % shipping model
    shipping_Bs(:,jj) = ridge(y([training_set validation_set test_set]), x2([training_set validation_set test_set],:), best_ks(jj), 1);
    
end
% performance
mean(final_r_squares)

% shipping model
mean(shipping_Bs,2)

mean(best_ks)










