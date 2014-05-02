function stdDev = commonFitStdDev(jacobian,variance)
% COMMONFITSTDDEV  Calculate the standard deviations of fit parameters.
% 
% Usage
%   stdDev = commonFitStdDev(jacobian,variance)
%
% jacobian - array
%            jacobian matrix of size n x p
%            n is the number of experimental data points
%            p is the number of fitted parameters
%            seventh output argument of 'lsqcurvefit'
%
% variance - double
%            variance of residuals => var(residuals)
%            'residuals' is third output argrument of 'lsqcurvefit'
%
% stdDev   - vector
%            contains the standard deviations for all p fit parameters
%
%
% See also
%   lsqcurvefit, var
%
% based on
%   John D'Errico, "Confidence limits on a regression model" and
%   "Confidence limits on the parameters in a nonlinear regression" in:
%   John D'Errico, "Optimization Tips and Tricks" (2011)
%   http://www.mathworks.de/matlabcentral/fileexchange/8553
%   retrieved, 2014-04-29
%

% (c) 2014, Bernd Paulus
% 2014-05-02

% perform QR factorization on J
[~,R] = qr(jacobian,0);

%% use triangular matrix R to calculate standard deviations
% Inv(J'*J) == Inv(R'*R) == Inv(R)*Inv(R') == Inv(R)*Inv(R)'
% as we only need diagonal elements, there's no need to calculate inverses
stdDev = sqrt( variance * sum(inv(R).^2,2) );

end
