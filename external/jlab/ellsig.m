function[x,y,z]=ellsig(varargin)
%ELLSIG  Creates a modulated elliptical signal in two or three dimensions.
%
%   Z=ELLSIG(KAPPA,LAMBDA,THETA,PHI) creates a time-varying, complex-valued
%   elliptical signal Z=X+iY characterized by RMS amplitude KAPPA,
%   linearity LAMBDA, orientation THETA, and orbital phase PHI.
%
%   [X,Y]=ELLSIG(KAPPA,LAMBDA,THETA,PHI) returns the analytic part of the 
%   ellipse signal along the X and Y axes.
%
%   See Lilly and Gascard (2006) and Lilly and Olhede (2010a) for details.
%
%   ELLSIG is inverted by ELLPARAMS, which returns the ellipse parameters
%   given the analytic signals X and Y.
%   ______________________________________________________________________
%  
%   Three dimensions
%
%   ELLSIG can also generate an elliptical signal in three dimenions. 
%
%   [X,Y,Z]=ELLSIG(KAPPA,LAMBDA,THETA,PHI,ALPHA,BETA) returns the analytic 
%   part of the ellipse signal along the X, Y, and Z axes.
%   
%   Here BETA is the "zenith angle" giving the orientation of the plane 
%   containing the ellipse with respect to the vertical, while ALPHA is 
%   the "azimuth angle", the angle the normal to the plane of the ellipse
%   makes with the x-axis.  
%
%   In the trivariate case, LAMBDA is positive, and the direction of 
%   rotation of the particle projected onto the X-Y plane is changed by  
%   letting the zenith angle BETA exceed PI/2.
%
%   See Lilly (2010) for details on the trivariate case.        
%   ______________________________________________________________________
%
%   [X,Y]=ELLSIG(...,'real') or [X,Y,Z]=ELLSIG(...,'real') takes the real 
%   part of the output arguments.
%
%   'ellsig --t' runs some tests.
%
%   Usage:  z=ellsig(kappa,lambda,theta,phi);
%           [x,y]=ellsig(kappa,lambda,theta,phi);
%           [x,y,z]=ellsig(kappa,lambda,theta,phi,alpha,beta);
%   __________________________________________________________________
%   This is part of JLAB --- type 'help jlab' for more information
%   (C) 2007--2010 J.M. Lilly --- type 'help jlab_license' for details



if strcmp(varargin{1},'--t')
    ellsig_test;return
end

na=nargin;
if isstr(varargin{end})
    na=na-1;
    str=varargin{end};
    varargin=varargin(1:end-1); 
else
    str='complex';
end

k=varargin{1};
l=varargin{2};
theta=varargin{3};
phi=varargin{4};

[a,b]=kl2ab(k,l);

x=rot(phi).*(a.*cos(theta)+sqrt(-1).*b.*sin(theta));
y=rot(phi).*(a.*sin(theta)-sqrt(-1).*b.*cos(theta));
if na==4
    if nargout==1
        x=real(x)+sqrt(-1)*real(y);
    elseif strcmp(str(1:3),'rea')
        x=real(x);
        y=real(y);
    end
    
elseif na==6
    l=abs(l);
    alpha=varargin{5};
    beta=varargin{6};
    
    [x,y,z]=vectmult(jmat3(beta,1),x,y,0*y);
    [x,y,z]=vectmult(jmat3(alpha,3),x,y,z);    
    
    if strcmp(str(1:3),'rea')
        x=real(x);
        y=real(y);
        z=real(z);
    end
end


function[]=ellsig_test
t=(0:1:925)';
kappa=3*exp(2*0.393*(t/1000-1));
lambda=0.4;
phi=(t/1000*5)*2*pi;
theta=pi/4+0*phi;

[x,y]=ellsig(kappa,lambda,theta,phi);
z=ellsig(kappa,lambda,theta,phi);

reporttest('ELLSIG z vs. x and y output',aresame(real(z),real(x),1e-6)&&aresame(imag(z),real(y),1e-6));

z2=ellsig(kappa,lambda,theta+pi,phi-pi);

reporttest('ELLSIG invariance to THETA+PI, PHI-PI',aresame(z,z2,1e-6));


load solomon 
use solomon

z=anatrans([x y z]);
[kappa,lambda,theta,phi,alpha,beta]=ellparams(z(:,1),z(:,2),z(:,3));
z2=z*nan;

[z2(:,1),z2(:,2),z2(:,3)]=ellsig(kappa,lambda,theta,phi,alpha,beta);
   
reporttest('ELLSIG exactly inverts ELLPARAMS for trivariate case, Solomon Islands',aresame(z,z2,2e-7))