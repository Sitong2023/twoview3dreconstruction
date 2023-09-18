clc
clear
I0=double(imread('G:\3D骨骼\bone.tif',34));
I0=I0-9500;
I0(I0<0)=0;
V=zeros(362,640,362);
line = I0(:,216);%中心点选取
[~,v]=max(line);
win0=line(v-30:v+30);
dd=256-233;

for i=1:67
    cmd=['I',num2str(i),'=double(imread(''G:\3D骨骼\bone.tif'',i))-9500;'];
    eval(cmd)
    cmd1=['I',num2str(i),'(I',num2str(i),'<0)=0;'];
    eval(cmd1)
    cmd2=['line=I',num2str(i),'(:,304);'];
    eval(cmd2)
    M=zeros(572,1);
    for y=31:512-30
        win1=line(y-30:y+30);
        match=sum(win1.*win0);
        M(y)=match;
    end
    [~,v2]=max(M);
    v2=v2(1);
    d=v2-v;
    I=zeros(512,640);
    if d>0
        cmd4=['I(1:512-d,:)=I',num2str(i),'(1+d:512,:);'];
        eval(cmd4)
    else
        cmd5=['I(1-d:512,:)=I',num2str(i),'(1:512+d,:);'];
        eval(cmd5)
    end
    I(1+dd:512,:)=I(1:512-dd,:);
    cmd3=['I',num2str(i),'=I;'];
    eval(cmd3)
%     pause(0.2)
%     imagesc(I)
end

V=zeros(512,512,640);
for i=1
    
    Iradon=zeros(512,67);
    line1=I1(:,i);
    for angle=1:67
        cmd=['line2=I',num2str(angle),'(:,i);'];
        eval(cmd)
        max1=max(line1);
        line2=line2/max(line2)*max1;
        Iradon(:,angle)=line2;
        line1=line2;
    end
    
    Iradon=imresize(Iradon,[512,33],'bicubic');
    Iradon=imresize(Iradon,[512,67],'bicubic');
    Iradon(Iradon<4000)=0;
    
%     y1=linspace(1,512,512);
%     y1=imresize(y1',[512,67]);
%     y1=y1.*imbinarize(Iradon);
%     y1(y1==0)=513;
    III=zeros(512,512);
    for x=1:10:67   % angle slice
        str=['angle = ' num2str(x) ''];
        disp(str)
        II=zeros(512,512);
        x3=zeros(512,1)*NaN;
        u3=0;
        for y=1:512  % y axis of Iradon
%             drop=rand(1);
            
            if Iradon(y,x)>0  %&&drop>0.5
                str=['y = ' num2str(y) ''];
                disp(str)
                match=zeros(1,512)*NaN;
                if u3==0||isnan(u3)  % first scan
                    
                for xx=76:437
                      
%                     str=['xx = ' num2str(xx) ''];
%                     disp(str)
                    phan=zeros(512,512);
                    phan(y,xx)=Iradon(y,x);
                    rphan=radon(phan);
                    rphan=rphan(109:620,:);
                    rphan=fliplr(rphan);
                    rphan=[rphan(:,91:180),flipud(rphan(:,1:90))];
                    rphan=[rphan(:,180-x+1:180),flipud(rphan(:,1:(67-x)))];
                    
%                     Iradon(rphan>0)=0;
%                     imagesc(Iradon)
                    rphan(rphan>0)=Iradon(rphan>0);
                    line=max(rphan);
                    if min(line)<=0
                        std_rphan=NaN;
                    else
                        std_rphan=mean(sqrt((line-Iradon(y,x)).^2));   
                    end
                    match(xx)=std_rphan;
                end
                
                else  % following scan
                    for xx=u3-20:u3+20

%                     str=['xx = ' num2str(xx) ''];
%                     disp(str)
                    phan=zeros(512,512);
                    phan(y,xx)=Iradon(y,x);
                    rphan=radon(phan);
                    rphan=rphan(109:620,:);
                    rphan=fliplr(rphan);
                    rphan=[rphan(:,91:180),flipud(rphan(:,1:90))];
                    rphan=[rphan(:,180-x+1:180),flipud(rphan(:,1:(67-x)))];
                    
%                     Iradon(rphan>0)=0;
%                     imagesc(Iradon)
                    rphan(rphan>0)=Iradon(rphan>0);
                    line=max(rphan);
                    if min(line)<=0
                        std_rphan=NaN;
                    else
                        std_rphan=mean(sqrt((line-Iradon(y,x)).^2));   
                    end
                    match(xx)=std_rphan;
                    end
                end
%                 plot(line)
%                 plot(match)
                [~,u3]=min(match);
                if u3==1
                    u3=x3(y-1);
                end

                x3(y)=u3(1);
                str=['u3 = ' num2str(u3(1)) ''];
                disp(str)
            end            
        end
        x3=round(medfilt1(medfilt1(x3,5),5));
        for y=1:512
            if x3(y)>0
               II(y,x3(y))=Iradon(y,x);
            end
        end
        
       II=imrotate(II,34-x);
        sizeII=size(II(:,1));
        ctr=round(sizeII/2);
        II=II(ctr-255:ctr+256,ctr-255:ctr+256);

        str=['i = ' num2str(i) ''];
        disp(str)
        III(II>0)=II(II>0);
    end
    
    imagesc(III)
    drawnow
    cmd1=['imwrite(uint16(III),''E:\bone\s',num2str(i),'.tif'')'];
    eval(cmd1)
    str=['i = ' num2str(i) ''];
    disp(str)
end


for i=1:512
    II=V(i,:,:);
    II=reshape(II,[512,640]);
    II=medfilt2(II,[3,3]);
    V(i,:,:)=II;
end
for i=1:512
    II=V(:,i,:);
    II=reshape(II,[512,640]);
    II=medfilt2(II,[3,3]);
%     II=medfilt2(II,[5,5]);
    imagesc(II)
    pause(0.5)
    cmd1=['imwrite(uint16(II),''E:\bone2\s',num2str(i),'.tif'')'];
    eval(cmd1)
    V(:,i,:)=II;
end


