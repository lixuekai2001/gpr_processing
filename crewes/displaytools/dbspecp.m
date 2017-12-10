function hs=dbspec(t,s,flag,n)
% DBSPECP: plots a Fourier amplitude spectrum using a decibel scale for a profile.
%
% hs=dbspec(t,s,flag,n)
% hs=dbspec(t,s,flag)
% hs=dbspec(t,s)
%
% DBSPECP opens up a new figure window and plots the average Fourier
% amplitude spectrum (in decibels) spectrum (unwrapped).
% If s is a vector, then a single curve is
% plotted showing the amplitude spectrum of s. If s is a matrix,
% then the average decibel spectrum of the columns (traces) of s is
% plotted.
%
% Note: DBSPECP uses PLOT for display and calls SIMPLEZOOM 
% to provide an interactive Zoom
%
% s= input trace, if a matrix with more than one trace then individual
%   trace spectra are plotted.
% t= input time vector
% flag= 0... apply an n length mwindow to s before transforming
%       1... apply an n length half-mwindow to s before transforming
%       2... transform directly without windowing
% ************* default=2 **************
% n= transform length, if not supplied, then fft length
%    will be length(s)
% hs= the handles of the plotted spectra
% 
% 
% by G.F. Margrave, May 2011
%
% NOTE: It is illegal for you to use this software for a purpose other
% than non-profit education or research UNLESS you are employed by a CREWES
% Project sponsor. By using this software, you are agreeing to the terms
% detailed in this software's Matlab source file.
 
% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by 
% its author (identified above) and the CREWES Project.  The CREWES 
% project may be contacted via email at:  crewesinfo@crewes.org
% 
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) Use of this SOFTWARE by any for-profit commercial organization is
%    expressly forbidden unless said organization is a CREWES Project
%    Sponsor.
%
% 2) A CREWES Project sponsor may use this SOFTWARE under the terms of the 
%    CREWES Project Sponsorship agreement.
%
% 3) A student or employee of a non-profit educational institution may 
%    use this SOFTWARE subject to the following terms and conditions:
%    - this SOFTWARE is for teaching or research purposes only.
%    - this SOFTWARE may be distributed to other students or researchers 
%      provided that these license terms are included.
%    - reselling the SOFTWARE, or including it or any portion of it, in any
%      software that will be resold is expressly forbidden.
%    - transfering the SOFTWARE in any form to a commercial firm or any 
%      other for-profit organization is expressly forbidden.
%
% END TERMS OF USE LICENSE

%figure 
[m,nn]=size(s);
if(nargin<4)
   n=length(s);
 end
if nargin<3
   flag=2;
end

%test for a row vector
if(m==1)
   s=s(:);
end

%if m>nn, s=s.'; end

% test to see if s is complex
test=imag(s);
mag=sum(abs(test));
% branch accordingly
if(mag>0.0)
   if flag <2
      mw=ones(size(s(1,:)));
      if flag==0, mw=mwindow(s(1,:),20);end
      if flag==1, mw=mwhalf(s(1,:),20);end
      for it=1:m, s(it,:)=s(it,:).*mw;end
    end
    %spec=abs(fftshiftm(fft(s.',n)));
    spec=abs(fftshiftm(fft(s,n)));
    db=20*log10(spec/max(max(spec)));
    dt=t(2)-t(1);
    fn=1./(2*dt);
    df=1/((n-1)*dt);
    f=linspace(-fn,fn-df,n);
 else
    if flag <2
      mw=ones(size(s(1,:)));
      if flag==0, mw=mwindow(s(1,:),20);end
      if flag==1, mw=mwhalf(s(1,:),20);end
      for it=1:m, s(it,:)=s(it,:).*mw;end
    end
    %s=abs(fft(s',n));
    s=abs(fft(s,n));
    spec=s(1:round(n/2),:);
    db=20*log10(spec/max(max(spec)));
    dt=t(2)-t(1);
    fn=1./(2*dt);
    f=linspace(0.,fn,round(n/2));
 end
% now plot it
figure
   h=plot(f,mean(db,2));
   xlabel('Frequency (Hz)');
   ylabel(' decibels ');
	  grid;
	  %set(gca,'xlabel',text(0,0,' Frequency (Hz)'));
	  %set(gca,'ylabel',text(0,0,' db down'));
   simplezoom 
   if(nargout>0)
       hs=h;
   end
