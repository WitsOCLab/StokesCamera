function fig2 = StokesPlot(S0,S1,S2,S3,N,length,cmap,crop,cropS)
% Plots a stokes plot, as shown in the paper.
%
% Written by: Caremlo Rosales-Guzman and Mitchell A. Cox
%
% Example: load('stokes-08152023-143600.mat'); Stokes(frameS0,frameS1,frameS2,frameS3,200,6,'parula',[120 50], 300);
% Note that the variables above are stored in the .mat file produced when you push 'p' in the CameraPreviewStokes function.

fig2=figure('color','w','position',[10 100 700 700]);
%set(fig2, 'PaperPositionMode', 'auto');
%set(gca,'position',[-0 -0 1 1],'Visible','off')%%%%%One Fig only

S0 = S0(crop(1):crop(1)+cropS, crop(2):crop(2)+cropS);
S1 = S1(crop(1):crop(1)+cropS, crop(2):crop(2)+cropS);
S2 = S2(crop(1):crop(1)+cropS, crop(2):crop(2)+cropS);
S3 = S3(crop(1):crop(1)+cropS, crop(2):crop(2)+cropS);

samp=round(N/10);
%I=S0;
%S0=sqrt(S1.^2+S2.^2+S3.^2);
L=sqrt(S1.^2+S2.^2);
a=real(sqrt((S0+L)/2)); % Semi-major axis
b=real(sqrt((S0-L)/2)); % Semi-minor axis
phi=angle(S1+1i*S2)/2; % Rotation angle
h=sign(S3); % Handedness: (+) Righthanded = Red (-) Lefthanded = Blue
ip = round(linspace(1,min(size(S0)),samp));
a1 =a(ip,ip)*length;
b1 = b(ip,ip)*length;
hp1 = h(ip,ip);
phi1 = phi(ip,ip); 

smp=b1./a1;
imagesc(S0); 
colormap(cmap);
axis image %off
%set(gca,'XTick',[],'YTick',[]);
divs=size(a1);

S01=S0(ip,ip);

for i=1:divs(1)
    for j=1:divs(2)
        
     if S01(j,i)>0.001
        
        if smp(j,i)>= .05 && hp1(i,j) < 0
            %ecolor = x11colors('32');
            ecolor = 'red';
        
        elseif smp(j,i)>= .05 && hp1(i,j) > 0 
           %ecolor = x11colors('61');
           ecolor = 'green';
        elseif  smp(j,i)<= .05 
            %ecolor=x11colors('1');
            ecolor = 'white';
        end
        aux = mod(phi1(j,i),2*pi) * 180/pi;
        %aux = mod(phi1(i,j),pi) * 180/pi;
        aux=aux;
        drawellipse(gca,'Center',[ip(i),ip(j)],'SemiAxes',[a1(j,i),b1(j,i)],'RotationAngle',aux,'color',ecolor,...
            'InteractionsAllowed','none','LineWidth',1,'FaceAlpha',0);
     
     end    
         
    end
end

