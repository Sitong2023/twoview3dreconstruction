clc
clear
for i=1:61
    I=double(imread('G:\ex_vivo\exbone.tif',i));
%     imagesc(I)
    I=I-30;
    I(I<0)=0;
    cmd=['I',num2str(i),'=I;'];
    eval(cmd)
    
end
V=zeros(512,512,640);
for i=1:640
    
    Iradon=zeros(512,58);
    line1=I1(:,i);
    for angle=1:58
        cmd=['line2=I',num2str(angle),'(:,i);'];
        eval(cmd)
        max1=max(line1);
        line2=line2/max(line2)*max1;
        Iradon(:,angle)=line2;
        line1=line2;
    end
    
    Iradon=imresize(Iradon,[512,31],'bicubic');
    Iradon=imresize(Iradon,[512,58],'bicubic');
    Iradon(Iradon<0)=0;
    
%     y1=linspace(1,512,512);
%     y1=imresize(y1',[512,67]);
%     y1=y1.*imbinarize(Iradon);
%     y1(y1==0)=513;
    III=zeros(512,512);
    for x=10:10:50   % angle slice
        str=['angle = ' num2str(x) ''];
        disp(str)
        II=zeros(512,512);
        x3=zeros(512,1)*NaN;
        u3=0;
        for y=76:437  % y axis of Iradon
%             drop=rand(1);
            
            if Iradon(y,x)>5  %&&drop>0.5
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
                    rphan=[rphan(:,180-x+1:180),flipud(rphan(:,1:(58-x)))];
                    
%                     Iradon(rphan>0)=0;
%                     imagesc(Iradon)
                    rphan(rphan>0)=Iradon(rphan>0);
                    line=max(rphan);

                    line=line(x-8:x+8);

                    if min(line)<=0
                        std_rphan=NaN;
                    else
                        std_rphan=mean(sqrt((line-Iradon(y,x)).^2));   
                    end
                    match(xx)=std_rphan;
%                     disp(std_rphan)
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
                    rphan=[rphan(:,180-x+1:180),flipud(rphan(:,1:(58-x)))];
                    
%                     Iradon(rphan>0)=0;
%                     imagesc(Iradon)
                    rphan(rphan>0)=Iradon(rphan>0);
                    line=max(rphan);
                    line=line(x-8:x+8);
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
                if u3<76||u3>432
                    u3=nan;
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
        
       II=imrotate(II,29-x);
        sizeII=size(II(:,1));
        ctr=round(sizeII/2);
        II=II(ctr-255:ctr+256,ctr-255:ctr+256);

        str=['i = ' num2str(i) ''];
        disp(str)
        III(II>0)=II(II>0);
    end
    
    imagesc(III)
    drawnow
    cmd1=['imwrite(uint16(III),''E:\bone2\s',num2str(i),'.tif'')'];
    eval(cmd1)
    str=['i = ' num2str(i) ''];
    disp(str)
end

