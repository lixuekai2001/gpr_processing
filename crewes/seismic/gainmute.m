function sg=gainmute(s,t,x,xshot,xmute,tmute,gainpow)
% GAINMUTE ... gain and mute a seismic gather
%
% sg=gainmute(s,t,x,xshot,xmute,tmute,gainpow)
%
% s ... seismic gather, one trace per column. This can also be a cell array
%       of gathers, in which case the output willbe asimilar cell array.
% t ... time coordinate for s, length(t) must equal size(s,1) 
% x ... receiver coordinate for s, length(x) must equal size(s,2). If s is a
%       cell array, then this should be too.
% xshot ... shot coordinate for s. FOr a single shot, this is a scalar, for
%       s a cell array, this is a vector of the same length as s.
% xmute ... vector of at least two offsets at which mute times are specified.
%       Mutes are applied using absolute value of actual source-receiver
%       offset so this should be non-negative numbers. The simplest
%       meaningfull values would be [0 max(x)].
% tmute ... vector of times corresponding to xmute. At each offset, samples at times
%       earlier than the mute time will be zero'd. Traces with offsets not
%       specified in xmute will have mute times by linear interpolation or,
%       if the trace offset is larger than max(xmute), the times are
%       computed by constant-slope extrapolation. NOTE: size(tmute) must
%       equal size(xmute).
% NOTE... to turn off all muting, enter xmute=0 and tmute=0.
% gainpow ... gain applied to each sesimic trace is t.^gainpow . For no
%       gain, use gainpow=0.
% ************** default: gainpow=1 ******************
%
% sg = gather with gain and mute applied.
%
%
% G.F. Margrave, CREWES Project, August 2013
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

if(nargin<7)
    gainpow=1;
end
if(~iscell(s))
    if(length(t)~=size(s,1))
        error('invalid t coordinate vector')
    end
    if(length(x)~=size(s,2))
        error('invalid x coordinate vector')
    end

    if(abs(gainpow)>10 || length(gainpow)>1)
        error('Bad value for gainpow')
    end

    if(size(xmute)~=size(tmute))
        error('xmute and tmute must be the same size')
    end
    %compute offsets
    xoff=abs(x-xshot);
    
    %interpolate the mute
    if(length(xmute)>1)
        tmutex=interpextrap(xmute,tmute,abs(xoff));
    end

    sg=zeros(size(s));
    g=t.^gainpow;
    dt=t(2)-t(1);
    
    for k=1:length(xoff)
        %apply gain
        if(gainpow~=0)
            tmp=s(:,k).*g;%simple gain
        else
            tmp=s(:,k);
        end
        %apply mute
        if(length(xmute)>1)
            imute=min([round(tmutex(k)/dt)+1,length(t)]);
            tmp(1:imute)=0;
        end

        sg(:,k)=tmp;
    end
else
    nshots=length(s);

    if(~iscell(x))
        xx=x;
        x=cell(1,nshots);
        for k=1:nshots
            x{k}=xx;
        end
    end
    if(length(t)~=size(s{1},1))
        error('invalid t coordinate vector')
    end
    if(length(x{1})~=size(s{1},2))
        error('invalid x coordinate vector')
    end

    if(abs(gainpow)>10 || length(gainpow)>1)
        error('Bad value for gainpow')
    end

    if(size(xmute)~=size(tmute))
        error('xmute and tmute must be the same size')
    end
    
    if(length(xshot)~=nshots)
        error('invalid shot coordinate array')
    end

    sg=cell(size(s));
    g=t.^gainpow;
    dt=t(2)-t(1);
    
    for kshot=1:nshots
        ss=s{kshot};
        xx=x{kshot};
        ssg=zeros(size(ss));
        if(length(xx)~=size(ss,2))
            error(['x coordinate for shot ' int2str(kshot) ' is incorrect']);
        end
        
        %offsets for this shot
        xoff=abs(xx-xshot(kshot));
        
        %interpolate the mute
        if(length(xmute)>1)
            tmutex=interpextrap(xmute,tmute,xoff);
        end
        
        for k=1:length(xoff)
            %apply gain
            if(gainpow~=0)
                tmp=ss(:,k).*g;%simple gain
            else
                tmp=ss(:,k);
            end
            %apply mute
            if(length(xmute)>1)
                imute=min([round(tmutex(k)/dt)+1,length(t)]);
                tmp(1:imute)=0;
            end

            ssg(:,k)=tmp;
        end
        sg{kshot}=ssg;
    end
end