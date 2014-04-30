
function H=HOG(Im)
nwin_x=6;% the number of HOG windows per bound box
nwin_y=6;
B=36;%the number of histogram bins
[L,C]=size(Im); % L num of lines ; C num of columns
H=zeros(1,nwin_x*nwin_y*B); % column vector with zeros
m=sqrt(L/2);
if C==1 % if num of columns==1
    Im=im_recover(Im,m,2*m);%verify the size of image, e.g. 25x50
    L=2*m;
    C=m;
end
Im=double(Im);
step_x=floor(C/(nwin_x+1));
step_y=floor(L/(nwin_y+1));
cont=0;
hx = [-1,0,1];
hy = -hx';
grad_xr = imfilter(double(Im),hx);
grad_yu = imfilter(double(Im),hy);
angles=atan2(grad_yu,grad_xr);
magnit=((grad_yu.^2)+(grad_xr.^2)).^.5;
for n=0:nwin_y-1
    for m=0:nwin_x-1
        cont=cont+1;
        angles2=angles(n*step_y+1:(n+2)*step_y,m*step_x+1:(m+2)*step_x); 
        magnit2=magnit(n*step_y+1:(n+2)*step_y,m*step_x+1:(m+2)*step_x);
        v_angles=angles2(:);    
        v_magnit=magnit2(:);
        %assembling the histogram with 36 bins (range of 5 degrees per bin)
        bin=0;
        H2=zeros(B,1);
        for ang_lim=-pi+2*pi/B:2*pi/B:pi
            bin=bin+1;
            idx = find(v_angles<ang_lim); 
            v_angles(idx) = 100; 
            H2(bin) = H2(bin) + sum(v_magnit(idx));
        end
                
        H2=H2/(norm(H2)+0.01);        
        H(1,(cont-1)*B+1:cont*B)=H2;
    end
end
