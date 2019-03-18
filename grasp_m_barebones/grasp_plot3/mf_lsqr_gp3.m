function [p, std,return_chi_square]=mf_lsqr_grasp(x,y,err,pin,dpin,func,extra)
%
% Version 3.beta
% Levenberg-Marquardt nonlinear regression of f(x,p) to y(x)
% Richard I. Shrager (301)-496-1122
% Modified by A.Jutan (519)-679-2111
% Modified by Ray Muzic 14-Jul-1992



p = [];
return_chi_square = [];
std = []; 

if nargin <7; extra = []; end

%wt=1./(err.^2); %Andrew Wildes says the error weighting should be like
%this.
wt = 1./err; %instead of this.

dp=dpin*1e-1;
niter=100;
stol=10e-10;

disp('Fitting: iteration 1');
disp('')
disp(sprintf('*Beginning fit (max %d iterations)',niter));
disp('--------------------------------------')
disp('Iteration  Time(s)  Reduced Chi^2');

y=y(:); wt=wt(:); pin=pin(:); dp=dp(:);
m=length(y); n=length(pin);

options=[zeros(n,1) Inf*ones(n,1)];
nor = n; noc = 2;
pprec=options(:,1);
maxstep=options(:,2);
p=pin;

f=feval(func,x,p,extra); fbest=f; pbest=p;

% figure
% errorbar(x,y,err);
% hold on
% hfit=line(x,f,'erasemode','xor','color','r','Tag','mf_fitline');

r=wt.*(y-f);

sbest=r'*r;
nrm=zeros(n,1);
chgprev=Inf*ones(n,1);
kvg=0;
epsLlast=1;
epstab=[.1 1 1e2 1e4 1e6];

% do iterations
for iter=1:niter,
  tic;
  pprev=pbest;
  prt=feval('mf_dfdp_gp3',x,fbest,pprev,dp,func,extra);
  r=wt.*(y-fbest);
  sprev=sbest;
  sgoal=(1-stol)*sprev;
  for j=1:n,
     if dp(j)==0,
      nrm(j)=0;
   else
      prt(:,j)=wt.*prt(:,j);
      nrm(j)=prt(:,j)'*prt(:,j);
      if nrm(j)>0,
        nrm(j)=1/sqrt(nrm(j));
      end;
   end
   prt(:,j)=nrm(j)*prt(:,j);
 end;
  [prt,s,v]=svd(prt,0);
  s=diag(s);
  g=prt'*r;
  for jjj=1:length(epstab),
    epsL = max(epsLlast*epstab(jjj),1e-7);
    se=sqrt((s.*s)+epsL);
    gse=g./se;

    chg=((v*gse).*nrm);
%   check the change constraints and apply as necessary
    ochg=chg;
    for iii=1:n,
      if (maxstep(iii)==Inf), break; end;
      chg(iii)=max(chg(iii),-abs(maxstep(iii)*pprev(iii)));
      chg(iii)=min(chg(iii),abs(maxstep(iii)*pprev(iii)));
    end;
    
    aprec=abs(pprec.*pbest);      
    if (any(abs(chg) > 0.1*aprec)),
      p=chg+pprev;
      f=feval(func,x,p,extra);
      %set(hfit,'Ydata',f);
      
      r=wt.*(y-f);
      ss=r'*r;
      
      if ss<sbest,
        pbest=p;
        fbest=f;
        sbest=ss;
      end;
      if ss<=sgoal,
        break;
      end;
    end;
  end;
  epsLlast = epsL;
  if ss<eps,
    break;
  end
  aprec=abs(pprec.*pbest);
%  [aprec chg chgprev]
  if (all(abs(chg) < aprec) & all(abs(chgprev) < aprec)),
    kvg=1;
    break;
  else
    chgprev=chg;
  end;
  if ss>sgoal,
    break;
 end;
  %mf_upars(p,[]);
  disp(['Iteration ' num2str(iter+1) ' (max ' num2str(niter) ')']);
  

  
  return_chi_square = ss/(length(x)-sum(1-dp));
  disp(sprintf('   %3d      %6.2f   %8.3f', iter, toc, return_chi_square));
end;

% set return values
%
p=pbest;
f=fbest;
ss=sbest;
kvg=((sbest>sgoal)|(sbest<=eps)|kvg);
if kvg ~= 1 , disp(' CONVERGENCE NOT ACHIEVED! '), end;

disp(' ');
disp('Covariance Checking')
disp(' ');

% CALC VARIANCE COV MATRIX AND CORRELATION MATRIX OF PARAMETERS
% re-evaluate the Jacobian at optimal values
jac=feval('mf_dfdp_gp3',x,f,p,dp,func,extra);
msk = dp ~= 0;
n = sum(msk);        % reduce n to equal number of estimated parameters
jac = jac(:, msk);	% use only fitted parameters

%% following section is Ray Muzic's estimate for covariance and correlation
%% assuming covariance of data is a diagonal matrix proportional to
%% diag(1/wt.^2).  
%% cov matrix of data est. from Bard Eq. 7-5-13, and Row 1 Table 5.1 


%*** CHUCK Replaced Sparces here also
%Qinv=diag(wt.*wt);
Qinv=sparse(diag(wt.*wt));
%Q=diag((0*wt+1)./(wt.^2));
Q=sparse(diag((0*wt+1)./(wt.^2)));


%[nrw ncw]=size(wt);
%Q=ones(nrw,ncw)./wt; Q=diag(Q.*Q);
resid=y-f;                                    %un-weighted residuals

%CHUCK was 'ere  7/11/2013
%Replace the original code:
    %covr=resid'*Qinv*resid*Q/(m-n);                 %covariance of residuals

%And use 'sparse' matricies instead - this massively reduces memory usage.
covr=sparse(resid'*Qinv*resid*Q/(m-n));                 %covariance of residuals


Vy=1/(1-n/m)*covr;  % Eq. 7-13-22, Bard         %covariance of the data 
covr=diag(covr);                                %for compact storage
Z=((m-n)*jac'*Qinv*jac)/(n*resid'*Qinv*resid);
stdresid=resid./sqrt(diag(Vy));

jtgjinv=inv(jac'*Qinv*jac);
covp=jtgjinv*jac'*Qinv*Vy*Qinv*jac*jtgjinv; % Eq. 7-5-13, Bard %cov of parm est
for k=1:n,
  for j=k:n,
    corp(k,j)=covp(k,j)/sqrt(abs(covp(k,k)*covp(j,j)));
    corp(j,k)=corp(k,j);
  end;
end;

std=sqrt(diag(covp));

j=1;
sig=zeros(size(p));
for i=1:length(std)
	while dp(j)==0
		j=j+1;
	end
	sig(j)=std(i);
	j=j+1;
end
std=sig;

%%% alt. est. of cov. mat. of parm.:(Delforge, Circulation, 82:1494-1504, 1990
%%disp('Alternate estimate of cov. of param. est.')
%%acovp=resid'*Qinv*resid/(m-n)*jtgjinv


