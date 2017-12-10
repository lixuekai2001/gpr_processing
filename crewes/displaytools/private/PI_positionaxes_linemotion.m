function PI_positionaxes_linemotion(hObject, eventdata, handles)
h=get(gcf,'userdata');
hi=h(5);
hvertscrol=h(16);
hhorscrol=h(17);
mainax=findobj(gcf,'type','axes','tag','MAINAXES');
posax=findobj(gcf,'type','axes','tag','POSITIONAXES');
lns=get(get(posax,'title'),'userdata');
oldpt=get(gca,'userdata');
newpt=get(gca,'currentpoint');
dx=oldpt(1,1)-newpt(1,1);
dy=oldpt(1,2)-newpt(1,2);
ydat=[get(lns(1),'ydata') get(lns(2),'ydata')]; ydat=[ydat(1) ydat(4)];
xdat=[get(lns(3),'xdata') get(lns(4),'xdata')]; xdat=[xdat(1) xdat(4)];
newydat=ydat-dy;
newxdat=xdat-dx;
xlim=sort(get(lns(5),'xdata'));
ylim=sort(get(lns(5),'ydata'));
if(newxdat(1)<=xlim(1))
    sx=newxdat(2)-newxdat(1);
    newxdat(1)=xlim(1);
    newxdat=[newxdat(1) newxdat(1)+sx];
elseif(newxdat(2)>=xlim(end))
    sx=newxdat(2)-newxdat(1);
    newxdat(2)=xlim(end);
    newxdat=[newxdat(2)-sx newxdat(2)];
end
if(newydat(1)<=ylim(1))
    sy=newydat(2)-newydat(1);
    newydat(1)=ylim(1);
    newydat=[newydat(1) newydat(1)+sy];
elseif(newydat(2)>=ylim(end))
    sy=newydat(2)-newydat(1);
    newydat(2)=ylim(end);
    newydat=[newydat(2)-sy newydat(2)];
end
set(lns(1),'xdata',[newxdat(1) newxdat(2)],'ydata',[newydat(1) newydat(1)]);
set(lns(2),'xdata',[newxdat(1) newxdat(2)],'ydata',[newydat(2) newydat(2)]);
set(lns(3),'xdata',[newxdat(1) newxdat(1)],'ydata',[newydat(1) newydat(2)]);
set(lns(4),'xdata',[newxdat(2) newxdat(2)],'ydata',[newydat(1) newydat(2)]);
set(lns(6),'ydata',[newydat(1) newydat(2) newydat(2) newydat(1)],...
    'xdata',[newxdat(2) newxdat(2) newxdat(1) newxdat(1)],'visible','off');
set(hhorscrol,'value',(newxdat(2)-newxdat(1))/2+newxdat(1));
val=get(hvertscrol,'value');
yimlim=[get(hvertscrol,'min') get(hvertscrol,'max')];
y1=yimlim(end)-(newydat(1)-yimlim(1));
y2=yimlim(1)+(yimlim(end)-newydat(2));
set(hvertscrol,'value',y2+(y1-y2)/2);
set(gca,'userdata',newpt);
h=get(gcf,'userdata');
hmsg=h(2);
hi=h(5);
dat=get(hi,'cdata');
if(size(dat,1)*size(dat,2)>=600000)
    stringinfo='Due to Video limitations, main axes not instantly updated';
    set(hmsg,'string',stringinfo,'backgroundcolor',[1 1 1]);
    return
end
PI_zoomlock;
set(mainax,'xlim',newxdat,'ylim',newydat);
set(hi,'alphadatamapping','direct','alphadata',[0]);


