%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% TD6 de DynaE : 
% Experimental Modal Analysis of a plate
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; format short g
  
Method = 'EMA'  % Select: 'ODS', 'Appropriation' or 'EMA'

Data_File  = 'fram_frf.uff';
Model_File = 'fram_geo.unv';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% lecture des FRF et pre-traitement

[H,df,loc,typ,units,freq]=uffread(Data_File,58,4); % lecture des donnees experimentales
%freq = freq(1,:);
[kref,ia] = unique(abs(loc(:,3))); kref = abs(loc(ia,3:4));
nref = size(kref,1)
[kresp,ia] = unique(abs(loc(:,1))); kresp = abs(loc(ia,1:2));
nresp = size(kresp,1)

[nfunc,nfreq] = size(H);           % Nombre total de fonctions mesurees 

W = 2*pi*freq;                     % table des pulsations et nombre de points en frequences

for ifunc=1:nfunc,
    H(ifunc,:) = sign(loc(ifunc,2))*sign(loc(ifunc,4))*H(ifunc,:);
end

% Evaluation des FRF en vitesses/efforts (mobilite)
Hv  = zeros(nresp*nref,nfreq);     % FRF en vitesses/efforts (mobilite)
for ifunc=1:nfunc,
    if strcmp(units,'m/s^2/N'),
        Hv(ifunc,2:end) = H(ifunc,2:end)./(1j*W(1,2:end));
    elseif strcmp(units,'m/N'),
        Hv(ifunc,:) = H(ifunc,:).*(1j*W(1,:));
    elseif strcmp(units,'m/s/N'),
        Hv(ifunc,:) = H(ifunc,:);
    end
end
units = 'm/s/N';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% lecture et affichage du modele experimental 

[vcor,kconec] = uffread(Model_File,15);
nnt = size(vcor,1);
kconec2 = kconec; kconec2(kconec==0)=1;
X = vcor(kconec2,:); X(kconec==0,:)=NaN;

figure(1); clf;  box off; 
set(gcf,'Name','Experimental model','Color','w')
hmesh = plot3(X(:,1),X(:,2),X(:,3)); axis equal; hold on; view(3)
hrep = plot3(vcor(kresp(:,1),1),vcor(kresp(:,1),2),vcor(kresp(:,1),3),'b.','MarkerSize',24);
href = plot3(vcor(kref(:,1),1),vcor(kref(:,1),2),vcor(kref(:,1),3),'r.','MarkerSize',36);
for i=1:nnt, nodelabel(i,:) = sprintf(' %5i',i); end
h=text(vcor(:,1),vcor(:,2),vcor(:,3),num2cell(nodelabel,2));
% pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Affichage de toutes les FRF 
% verification de la dispersion des pics (par amortissement ou variation de masses additionnelles)
% verification des rotations de phases

figure(2), clf
set(gcf,'Name','FRF')
for ifunc=1:nfunc,
    %clf
    subplot(2,1,1)
    semilogy(freq(ifunc,:),abs(Hv(ifunc,:))); hold all; grid on
    set(gca,'Xlim',[0,max(freq(:))],'Ylim',[min(abs(Hv(:))),max(abs(Hv(:)))*1.35])
    ylabel(['Module [',units,']'])
    title(sprintf('%d FRF',nfunc))
    subplot(2,1,2)
    plot(freq(ifunc,:),unwrap(angle(Hv(ifunc,:)))); hold all; grid on
    set(gca,'Xlim',[0,max(freq(:))])
    xlabel('Frequence [Hz]')
    ylabel('Phase [rd]')
    %   disp('Pause: press space bar to continue');pause
end


% Affichage des FRF colocalisees
% verification de la presence des antiresonances et des rotations de phases

disp('Pause: press space bar to continue');pause
figure(2), clf; legende=[];
kfunc = find(sum(abs(loc(:,1:2))-abs(loc(:,3:4)),2)==0);
for jfunc = 1:length(kfunc)
    ifunc = kfunc(jfunc);
    subplot(2,1,1)
    semilogy(freq(ifunc,:),abs(Hv(ifunc,:))); hold all; grid on
    set(gca,'Xlim',[0,max(freq(:))],'Ylim',[min(abs(Hv(:))),max(abs(Hv(:)))*1.35])
    xlabel('Frequence [Hz]')
    ylabel(['Module [',units,']'])
    subplot(2,1,2)
    plot(freq(ifunc,:),unwrap(angle(Hv(ifunc,:)))); hold all; grid on
    set(gca,'Xlim',[0,max(freq(:))])
    xlabel('Frequence [Hz]')
    ylabel('Phase [rd]') 
    legende = [legende;sprintf('FRF # %3d, Ref %2d, Dir %2d, Resp %2d, Dir %2d \n',ifunc,loc(ifunc,3),abs(loc(ifunc,4)),loc(ifunc,1),abs(loc(ifunc,2)))];
end
legend(legende,'Location','NorthOutside');


% Affichage des FRF de reciprocites
% verification de la linearite du systeme

disp('Pause: press space bar to continue');pause
figure(2), clf; ifig = 0;
for ifunc = 1:nfunc
    if sum(loc(ifunc,1) == kref(:,1)),
        ifig = ifig + 1;
        subplot(nref,nref,ifig)
        semilogy(freq(ifunc,:),abs(Hv(ifunc,:))); hold all; grid on
        set(gca,'Xlim',[0,max(freq(:))],'Ylim',[min(abs(Hv(:))),max(abs(Hv(:)))*1.35])
        ylabel(['Module [',units,']'])
        title(sprintf('FRF # %d, Ref %d, Resp %d',ifunc,loc(ifunc,3),loc(ifunc,1)))
   end
end

pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MIFs

MvMIF = zeros(nref,nfreq);
for kfreq = 1:nfreq,
    H = reshape(Hv(:,kfreq),nresp,nref);
    MvMIF(:,kfreq) = sort(real(eig(imag(H)'*imag(H),real(H)'*real(H)+imag(H)'*imag(H))));
end


figure(3); clf
set(gcf,'Name','MvMIF','DefaultAxesLineStyleOrder','-|-.|--|:')
for iref = 1:nref,
    plot(freq(iref,:),abs(MvMIF(iref,:)),'linewidth',1.5)
    hold all
end
grid on
set(gca,'Fontsize',14,'Xlim',[0,max(freq(:))],'Ylim',[0,1.05])
xlabel('Frequency [Hz]')
title('Multivariate MIF')

pause
fprintf('flag1');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Recherche automatisee des frequences de resonances / selection des poles

S = abs(MvMIF);
kmodmvmif = []; % frequences propres
for kfreq = 2:nfreq-1 % recherche des pics
    for iref=1:nref,
        if (S(iref,kfreq) < S(iref,kfreq-1) && S(iref,kfreq) < S(iref,kfreq+1))
            if S(iref,kfreq)<.75,
                kmodmvmif = [kmodmvmif,kfreq]; % indice de H qui donne les pics
            end
        end
    end
end
kfreq_modes = kmodmvmif;
freq_modes = freq(1,kfreq_modes)
Nmod = length(kfreq_modes)
fprintf('flag2');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Analyse modale

if strcmp(Method,'ODS'),  % ODS pour la 1ere excitation

    Psi = Hv(1:nresp,kfreq_modes);

elseif strcmp(Method,'Appropriation'),  % Appropriation numerique
    
    for rmod = 1:Nmod,
        
        H = reshape(Hv(:,kfreq_modes(rmod)),nresp,nref);
        
        [p,v] = eig(imag(H)'*imag(H),real(H)'*real(H)+imag(H)'*imag(H));
        [v,idx] = sort(abs(diag(v)));
        F(:,rmod) = p(:,idx(1));         % Pattern Search
        
        Psi(:,rmod) = H*F(:,rmod);
        
        % affichage des dephasage colocalise
        title2 = sprintf(', Mode #%d, %g Hz',rmod,freq_modes(rmod));
        Phases = angle((-1j*Psi(kref(:,1)))./F(:,rmod))
        figure; clf
        t = linspace(0,2*pi,200);
        for iref = 1:nref,
            subplot(2,2,iref); plot(real(F(iref,rmod)*exp(1j*t)),real(-1j*Psi(kref(iref))*exp(1j*t)))
            xlabel('Force'); ylabel('Deplacement')
            title(sprintf('Ref #%d',iref))
            set(gcf,'Name',title2)
        end
        if rmod<Nmod, pause; end
        
    end

elseif strcmp(Method,'EMA'),  % Experimental modal analysis
    fprintf('flag3:EMA');
    for ifunc = 1:nfunc,
        infoFRF(ifunc).response = loc(ifunc,1);
        infoFRF(ifunc).dir_response = abs(loc(ifunc,2));
        infoFRF(ifunc).excitation = loc(ifunc,3);
        infoFRF(ifunc).dir_excitation = abs(loc(ifunc,4));
    end
    
    [RES,infoFRF,infoMODE]=lsce(Hv(1:54,:).',freq(1,:)',infoFRF);
    freq_modes = infoMODE.frequencyk'
    xir = infoMODE.etak'*.5
        
    % Poles du modele
    Nmod = length(freq_modes);                   % nombre de modes
    wr  = 2*pi*freq_modes;                        % pulsations modales
    wdr = wr.*sqrt(1-xir.^2);              % pulsations amorties
    lbdr = -xir.*wr + 1j*wdr;               % poles
    
    %return
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    % Identification des residus 
    fa = [1:300]; 

    A = zeros(nfunc,Nmod);

Lfreq = length(fa);
kfreq = zeros(1,Lfreq);
for ka=1:Lfreq,
    [~,kfreq(ka)] = min(abs(freq(1,:)-fa(ka))); % donne l'indice de la frequence la plus proche de la frequence cherchee
end

M1 = zeros(Lfreq,Nmod);
M2 = zeros(Lfreq,Nmod);
for rmod = 1:Nmod,
    
    M1(:,rmod) = 1j*W(kfreq)./(1j*W(kfreq)-lbdr(rmod));
    M2(:,rmod) = 1j*W(kfreq)./(1j*W(kfreq)-conj(lbdr(rmod)));
    
end  % of rmod
        
M1 = [ M1, (1j*W(kfreq)).'];
M2 = [ M2, zeros(Lfreq,1)];

M = [real(M1) -imag(M1);  imag(M1)  real(M1)] +...
    [real(M2)  imag(M2);  imag(M2) -real(M2)];

for ifunc = 1:nfunc,
    B = Hv(ifunc,kfreq).';
    ARI = M\[real(B); imag(B)];
    A(ifunc,:) = complex(ARI(1:Nmod),ARI((Nmod+2):(end-1))).';
    R(ifunc,1) = complex(ARI(Nmod+1),ARI(end));
end


    % Identification des modes complexes
    ar  = 1j*ones(Nmod,1);        % constantes modales

Psi = zeros(nresp,Nmod,nref); 
for iref =1:nref,
    iresp = (1:nresp) + nresp*(iref-1) ;
    for rmod=1:Nmod,
        Psi(:,rmod,iref) = sqrt(ar(rmod))*A(iresp,rmod)./sqrt(A(iresp(kref(iref)),rmod)); %Psi1(:,r) = Psi;
    end
end


% redressement et lissage (car il y a 2 references) des modes complexes 
for iref =1:nref,
    for rmod=1:Nmod,
        psi  = Psi(:,rmod,iref);
        phir = .5*angle(psi.'*psi);
        psi  =  psi*exp(-1j*phir);
        [~,imax] = max(abs(real(psi)));
        Psi(:,rmod,iref) = psi*sign(real(psi(imax)));
    end
end
Psi = [zeros(1,Nmod); mean(Psi,3)];
  

    % Affichage des FRF synthetisees
    % Synthese totale intermediaire

Hv_hat = zeros(nfunc,nfreq);
for pfreq = 1:nfreq,
    for rmod=1:Nmod,
        for ifunc=1:nfunc,
           Hv_hat(ifunc,pfreq) = Hv_hat(ifunc,pfreq) + A(ifunc,rmod)./(1j*W(pfreq)-lbdr(rmod)).*1j*W(pfreq) +...
               conj(A(ifunc,rmod))./(1j*W(pfreq)-conj(lbdr(rmod))).*1j*W(pfreq);
        end  % of ifunc
    end  % of rmod
    Hv_hat(:,pfreq) = Hv_hat(:,pfreq) + R.*1j*W(pfreq) ;
end  % of pfreq


% Affichage des FRF
for iref = 1:nref,
    figure; set(gcf,'Name','Synthese modale intermediaire')
    for iresp=1:nresp,
        ifunc = iresp + nresp*(iref-1) ;
        subplot(5,6,iresp)
        semilogy(freq,abs(Hv(ifunc,:)),'y','LineWidth',3); hold on
        if Lfreq<10,semilogy(freq(kfreq),abs(Hv(ifunc,kfreq)),'o'); end
        semilogy(freq,abs(Hv_hat(ifunc,:)),'r'); grid on
        ylabel(['Module de la FRF [',units,']'])
        xlabel(['Frequence [Hz]'])
        title(sprintf('FRF # %d, Ref %d, Resp %d',ifunc,sign(loc(ifunc,4))*loc(ifunc,3),sign(loc(ifunc,2))*loc(ifunc,1)))
    end
end
   

end

 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Des modes complexes aux modes reels

% Affichage de la complexite modale
for rmod=1:Nmod,
    figure; clf
    set(gcf,'Name','Complexite modale')
    [theta ,rho] = cart2pol(real(Psi(:,rmod)),imag(Psi(:,rmod)));
    polar(theta ,rho)
    title(sprintf('Mode #%g, frequency: %g Hz', rmod, freq_modes(rmod)))
    if rmod<Nmod, pause; end
end

% rotation des modes complexes et extraction des modes normaux de vibration   
Phi = zeros(3*nresp,Nmod);
kloc = kresp(:,1)*3-3+kresp(:,2);
Psi=Psi(2:end,:);
Phi(kloc,:) = real(Psi*diag(exp(-1j*.5*angle(diag(Psi.'*Psi)))));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calcul du MAC pour les modes precedemment identifies (Auto-MAC)
MAC = zeros(Nmod);
for rmod =1:Nmod,    
    phii = Phi(:,rmod)./sqrt(abs(Phi(:,rmod)'*Phi(:,rmod)));
    for jmod = 1:Nmod,
        phij = Phi(:,jmod)./sqrt(abs((Phi(:,jmod)'*Phi(:,jmod))));
        MAC(rmod,jmod) =  abs(phii'*phij).^2;
    end
end

%  Affichage du MAC
figure; clf; title('MAC matrix')
set(gcf,'Name','Orthogonalite de la base modale finale','Color','w')
h = bar3(MAC); set(gca,'YDir','normal'); view(2); grid off
[numBars, numSets] = size(MAC);
for i = 1:numSets, 
	zdata = ones(6*numBars,4); k = 1; 
	for j = 0:6:(6*numBars-6), 
		zdata(j+1:j+6,:) = MAC(k,i); k = k+1; 
	end 
	set(h(i),'Cdata',zdata); 
end 
xlabel('Mode #'); ylabel('Mode #'); zlabel('MAC value')
colorbar

pause

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Animation des modes normaux de vibration
figure; box off; 
set(gcf,'Name','Modes normaux de vibration','Color','w')
hmesh = plot3(X(:,1),X(:,2),X(:,3)); axis equal; view(-170,70)
xlabel('X - Direction [m]')
ylabel('Y - Direction [m]')
zlabel('Z - Direction [m]')
ech = (max(vcor(:))-min(vcor(:)))*.05;
set(gca,'Xlim',[min(vcor(:,1))-ech*1.05, max(vcor(:,1))+ech*1.05],...
 'Ylim',[min(vcor(:,2))-ech*1.05, max(vcor(:,2))+ech*1.05],...
 'Zlim',[min(vcor(:,3))-ech*1.05, max(vcor(:,3))+ech*1.05])

for rmod = 1:Nmod,
    title(sprintf('Mode #%g,    frequency: %g Hz,  ', rmod, freq_modes(rmod)))
    phi = reshape(Phi(:,rmod),3,nnt)'; phi = phi/max(abs(phi(:)))*ech;
    for t=0:pi/60:6*pi,
        U = vcor + phi*cos(t); X = U(kconec2,:); X(kconec==0,:)=NaN;
        set(hmesh,'Xdata',X(:,1),'Ydata',X(:,2),'Zdata',X(:,3))
        drawnow
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Sauvegarde des modes experimentaux

PhiExp = Phi(2:3:end,:);
save(['PhiExp_',Method],'PhiExp');













