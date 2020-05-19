% Set the a-priori probabilities for the two classes by initializing 
% variable P.
P = 0.9;
% Define the location parameters mu1 and mu2.
MU1 = -2.0;
MU2 = 2.0;
% Define the scale parameter C1 and C2.
C1 = 1.0;
C2 = 1.0;

%-----------------------------------------------------------------------------------------------
% Determine the intersection points of the two curves Pw1_x(x) and Pw2_x(x).                   |
% To this end, we need to obtain the roots of the following equation with                      |      
% respect to x:                                                                                |                 
% G(x) = Pw1_x(x) - Pw2_x(x) = 0 <=>                                                           |     
% G(x) = P * Px_w1(x) - (1-P) * Px_w2(x) = 0 <=>                                               |     
% G(x) = (P-1) * C2 * (x - MU1)^2 + P * C1 * (x - MU2)^2 + (P-1)*C1^2*C2 + P*C2^2*C1 = 0 [4]   | 
% Define the necessary symbolic variables for computing the intesection                        |
% points                                                                                       |
%-----------------------------------------------------------------------------------------------

syms mu1 mu2 p c1 c2 x
G = (p-1) * c2 * (x - mu1)^2 + p * c1 * (x - mu2)^2 + (p-1)*c1^2*c2 + p*c2^2*c1;
% Subsitite the symbolic variables appearing in the expression for G(x)
% with the contents of the corresponding numeric variables. The resulting
% symbolic variable will be denoting a function of the form Go(x).
Go = subs(G,[mu1 mu2 p c1 c2],[MU1 MU2 P C1 C2]);
% Perform numeric operations involving the coefficients of the symbolic 
% objects to simplify the expression for Go. The resulting Go variable will
% remain a symbolic object.
Go = vpa(Go);
% Get the solutions to the equations Go(x) = 0.
So = solve(Go==0,x);
% Covert symbolic object to double to acquire access to the solutions of
% the equation Go(x) = 0.
So = double(So);
% Get the number of the obtained solutions.
No = length(So);
% Assing the obtained solutions to new variables xo for the case of a
% single solution and xo_min, xo_max for the case of two solutions.

% If Statement.

if(No==1)
    xo = So;
else
    xo_min = min(So);
    xo_max = max(So);
end

% In fact,we may define the one-dimensional feature space X in terms of an
% auxiliary parameter K in the following way:
% MUmin = min{MU1,MU2} [5]
% MUmax = max{MU1,MU2} [6]
% Cmin = min{C1,C2} [7]
% Cmax = max{C1,C2} [8]
% X = [MUmin - K*Cmax,MUmax + K*Cmax] [9]

%-----------------------------------------------------------------------------------------
% It is easy to deduce that in the case where P(W1) = P(W2) and C1 = C2,                 |                  
% then there exists a unique intersection point for the curves Pw1_x(x) and              |
% Pw2_x(x) which is given by the following equation:                                     |
%                  xo = (1/2) * (MU1 + MU2) [10],                                        |           
% which will necessarily lie within the interval [Xmin,Xmax].                            |                       
% However, in the case where P(W1) <> P(W2) and / or C1 <> C2, then there                |       
% exist two intersection points for the curves Pw1_x(x) and Pw2_x(x) which               |               
% are given by equation (4) and are stored in variables xo_min and xo_max.               |                                   
% In this case, we need to ensure that the ragne of the feature space that               |                           
% we consider includes points xo_min and xo_max, that is we need to enforce              |                               
% that: Xmin <= xo_min [11] and Xmax >= xo_max [12].                                     |                                       
%                                                                                        |                                   
% In this setting equation (11) yields:                                                  |                   
%         MUmin - K * Cmax <= xo_min ==> K >= (MUmin - xo_min) / Cmax [13]               |                   
% Likewise, equation (12) yields:                                                        |                       
%         MUmax + K * Cmax >= xo_max ==> K >= (xo_max - MUmax) / Cmax [14]               |                       
% Combining inequalities (13) and (14) gives:                                            |                                   
% K >= max{(MUmin - xo_min) / Cmax,(xo_max - MUmax) / Cmax} [15]                         |                           
%-----------------------------------------------------------------------------------------

Cmax = max(C);
if(No==1)
    K = 10;
else
    K = ceil(max(((MUmin - xo_min) / Cmax),((xo_max - MUmax) / Cmax)));
end

% Define the lower and upper bounds for the one-dimensional feauture space.
% Xmin = min([MU1 - K*C1,MU2 - K*C2]);
% Xmax = max([MU1 + K*C1,MU2 + K*C2]);
Xmin = MUmin - K*Cmax;
Xmax = MUmax + K*Cmax;

% Define the discretization parameter of the feature space.
dx = 0.001;

% Compute vector X storing all the possible values of the one-dimensional
% feature space for the given lower and upper bounds.
X = Xmin:dx:Xmax;

% Compute the values of the class conditional probabilty density functions 
% for each point in the feature space X.
p1 = @(x) (1 / (pi * C1)) * (1 ./ (1 + ((x - MU1)/C1).^2));
p2 = @(x) (1 / (pi * C2)) * (1 ./ (1 + ((x - MU2)/C2).^2));

% Define the vectors storing the class conditional probability denstity
% values for each point in the feature space X.
Px_w1 = p1(X);
Px_w2 = p2(X);

%------------------------------------------------------------------------------
% This script file provides fundamental computational functionality for the   |  
% simulation of binary classification problem within an one-dimensional       |  
% feature space. The class-conditional probability density functions for      |  
% the problem will be given by the parameterized Cauchy distribution as:      |  
%   
%                     1              1
%     P(x;MU,C) = ------- *  ------------------        [1]
%                 pi * C                  2
%                                 (x - MU)   
%                           1 + ----------
%                                     2 
%                                    C  

% Assumming that scale parameters for the class-conditional probability 
% denstity functions are given by (C1) and (C2), and the corresponding  
% location parameters parameters (mean values) are given by (MU1) and (MU2)
% , we may write that:
%                      p(x|W1) = p(x;MU1,C1) and p(x|W2) = p(x;MU2,C2)    [2]

% The a-priori proababilities for the two classes W1 and W2 such that: 
% P(W1) = P and P(W2) = 1 - P. Thus, the condition for equiprobable classes
% translates to:
%               P(W1) = P(W2) ==> P = 0.5 [3]% This script file provides 
%                        fundamental computational functionality for the
%
% simulation of binary classification problem within an one-dimensional 
% feature space. The class-conditional probability density functions for 
% the problem will be given by the parameterized Cauchy distribution as:
%   
%                     1              1
%     P(x;MU,C) = ------- *  ------------------        [1]
%                 pi * C                  2
%                                 (x - MU)   
%                           1 + ----------
%                                     2 
%                                    C  

% Assumming that scale parameters for the class-conditional probability 
% denstity functions are given by (C1) and (C2), and the corresponding  
% location parameters parameters (mean values) are given by (MU1) and (MU2)
% , we may write that:
%                      p(x|W1) = p(x;MU1,C1) and p(x|W2) = p(x;MU2,C2)    [2]

% The a-priori proababilities for the two classes W1 and W2 such that: 
% P(W1) = P and P(W2) = 1 - P. Thus, the condition for equiprobable classes
% translates to:
%               P(W1) = P(W2) ==> P = 0.5 [3]
%---------------------------------------------------------------------------------
