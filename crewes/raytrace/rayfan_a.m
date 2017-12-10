function [x,t,phi]=rayfan_a(v,z,z1,z2,theta)
% RAYFAN_A: similar to RAYFAN but the rays are specified by angle
%
% [x,t,phi]=rayfan_a(v,z,z1,z2,theta)
%
% rayfan_a shoots a fan of rays through the stratified earth. It is
% identical to rayfan except that the fan is described by a vector of
% angles rather than a ray parameter vector.
% v = vector of layer velocities
% z = vector of depths to the tops of each layer. Thus V(k) is
%	the velocity between z(k) and z(k+1). Z should be sorted into
%	ascending order.
% z1 = depth the ray starts at
% z2 = depth the ray ends at
% theta = vector of angles (from the vertical) of the ray at z1 (degrees)
% x = horizontal distance the ray travels (one for each theta)
% t = traveltime along the ray ( in seconds ) (one for each theta)
% NOTE: Critically refracted rays will return inf for both x an t
% phi = angle (from the vertical) of the ray at z2 (degrees) (one for
% each theta)
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

%preliminaries
 z=z(:);
 v=v(:);
 theta=theta(:)';
 nz=length(z);
 %adjust z1 and z2 so that they won't be exactly on layer boundaries
 zt=min([z1 z2]);
 if(zt==z1)
 	z1=z1+100000*eps;
 	z2=z2-100000*eps;
 else
 	z1=z1-100000*eps;
 	z2=z2+100000*eps;
 end
 if( z1< z(1) | z2< z(1) )
 	error(' start or end depth outside model range');
 end
 %compute ray parameter
 ind=find(z>=z1);
 if(isempty(ind))
 	ibeg=nz;
 else
 	ibeg=ind(1)-1;
 end
 p=sin(pi*theta/180.)/v(ibeg);
 
 %compute sin and check for critical angle
 ind=find(z>=z2);
 if(isempty(ind))
 	iend=nz;
 else
 	iend=ind(1)-1;
 end
 if(ibeg~=iend)
 	 % these are the layers propagated thru
 	iprop=ibeg:sign(iend-ibeg):iend;
 else
 	iprop=ibeg;
 end
 sn = v(iprop)*p;
 %
 % sn is an n by m matrix where n is the length of iprop (the number of
 %    layers propagated through) and m is the length of p (the number of
 %    unique ray parameters to use). Each column of sn corresponds to a
 %    single ray parameter and contains the sin of the vertical angle;
 %
 
 [ichk,pchk]=find(sn>1);
% if(~isempty(ichk))
% 	%assign infs
% 	sn(ichk,pchk)=inf*ones(size(sn(ichk,pchk)));
% end
 
 %compute x and t
 np=length(iprop);
 cs=sqrt(1-sn.*sn);
 zprop=[z1;z(iprop(2:np));z2];
 vprop=v(iprop)*ones(1,length(p));
 thk=abs(diff(zprop))*ones(1,length(p));
 if(size(sn,1)>1)
 	x=sum( (thk.*sn)./cs);
 	t=sum(thk./(vprop.*cs));
 else
 	x=(thk.*sn)./cs;
 	t=thk./(vprop.*cs);
 end
 if(~isempty(ichk))
 	x(pchk)=inf*ones(size(pchk));
 	t(pchk)=inf*ones(size(pchk));
 end
 
 % final angle
 phi=180*asin(sn(np,:))/pi;

