function y = filtboxnan(x,n)
% y = filtboxnan(x,n)
%
% THIS IS BASICALLY A MOVING AVERAGE OPERATOR
% x is the input vector; the no.of pts. of the vector
%    need not be specified
% n is the number of points of the boxcar smoother, 
% y is the smoothed x, convolved with the
%    boxcar of n pts.  Because the added edges at
%    the beginning and end are truncated, y will have
%    the same number of points as x.
%  T.N.Bishop, CCR, 4/94
%  
%  FILTBOXNAN DIFFERS FROM FILTBOX IN THAT IT HANDLES NaN's 
%  FILTBOX will cause any trace portions containing NaN's to grow larger 
%  by the length of the interpolation function. 
%  FILTBOXNAN avoids this by breaking the 
%  input trace into live segments and interpolating each separately.
%  The code is taken from Gary's SINCINAN function.
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
% first find the live and dead zones
	ilive=find(~isnan(x));
	ind=find(diff(ilive)>1);
	zone_beg=[ilive(1) ilive(ind+1)];
	zone_end=[ilive(ind) ilive(length(ilive))];
	nzones=length(zone_beg);
% 
%  compute the boxcar function of n points
f1 = ones(1,n)/n;
%  compute the center of the boxcar, assume n is odd
nc = fix(n/2) + 1;
%  compute other stuff
npad = n;
onepad = ones(1,npad);
%
% now initialize the output trace with nans, then loop over the zones
% and interpolate traces that fall in them
	y=nan*ones(1,length(x));
	
	for k=1:nzones
	
                xzone = x(zone_beg(k):zone_end(k));
		% get the input segment in this zone
		%pad input data with end values
xpad = [xzone(1)*onepad xzone xzone(length(xzone))*onepad];
%  use Gary's fct from seis.toolbox, to get same no.of
%  output points as input
ypad = convz(xpad,f1,nc,length(xpad),0);   %no cosine taper
		% unpad output data with end values
ypad = ypad((npad+1):(length(ypad)-npad));
                y(zone_beg(k):zone_end(k))=ypad(1:length(ypad));
	end
