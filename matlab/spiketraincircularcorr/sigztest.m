function [H,p]=sigztest(mu1,sigma1,mu2,sigma2,alpha)

% DESCRIPTION       : z test whether two sets or data could have the same
% mean at the significance lever alpha

% mu1, sigma1      : mean and standard deviation of data1
% mu2, sigma2, n2   : mean and standard deviation of data2
% alpha             : significance level 

% H                 : H=0: null hypothesis (mu1-mu2=0) cannaot be rejected at the
% alpha significance level;  H=1:null hypothesis can be reject at the alpha
% significace level.

% (c) Yi Zheng, Aug 2007

if nargin<5
    alpha=0.05;
end
z = abs(mu1-mu2)/sqrt(sigma1^2+sigma2^2);
% if alpha==0.05
%   z_alpha = 1.96;  % at the 0.05 level of significance (p<0.05)
% elseif alpha==0.001;
%     z_alpha = 3.28;  % p<0.001
% end
z_alpha = tinv((1-alpha),inf);

p=1-tcdf(z,inf);

% if abs(z)>=z_alpha   % two-tail z test
if z>=z_alpha
    H=1;
else
    H=0;
end
