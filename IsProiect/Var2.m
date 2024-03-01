file_name = 'C:\Faculta An 3\IsProiect\Burzo.csv';
Burzo = import_date_proiect(file_name);

t = Burzo(:,1);
u = Burzo(:,2);
y = Burzo(:,3);
y2 = Burzo(:,4);

figure("Name",'Date initiale')
plot(t,u,t,y);%Afisarea datelor initiale

i1y = 173;% y max
i2y = 185;% y min
i1u = 168;% u max
i2u = 180;% u min

K = mean(y)/mean(u)% determinarea factorului de proportionalitate "K"
%K = (mean(u)-min(u))/(max(u)-min(u)) NU SE SUPRAPUN

Mr = (y(i2y)-y(i1y))/(u(i2u)-u(i1u)) %Determinarea modulului de rezonanta

zeta = sqrt((Mr-sqrt(Mr^2-1))/2/Mr)/K %Determinarea factorului de amortizare cu ajutorul Modulului de rezonanta

T = 2*(t(i2u)-t(i1u)) % Determinarea perioadei de osccilatie/unei oscilatii

wr = (2*pi)/T % Determinarea Pulsatiei la rezonanta


wn = wr/sqrt(1-2*zeta^2) %Determinarea pulsatiei naturale

num = K*wn^2; % Compunera numitorului functiei de transfer in spatiul starilot
den = [1 2*zeta*wn wn^2]; % Compunerea numaratorului functiei de transfer in spatiul starilor
H = tf(num,den) % functia de transfer
% Simularea iesirii cu functiei de transfer identificate cu ajutorul fenomenului de rezonanta
ysim_H = lsim(H,u,t);

% Afisarea unei comparatii intre iesirea obtinua prin calcul si iesirea originala a sistemului
figure("Name",'Date initiale/Date simulate(cu ajutorul H)')
plot(t,y,t,ysim_H)
% Calculaarea erorii medie patratica normalizata din contii initiale nule
empt_H = norm(y-ysim_H)/norm(y-mean(y))*100

%Compunerea matricilor pentru forma canonica de observare

A = [0,1; -wn^2,-2*zeta*wn];
B = [0;K*wn^2];
C = [1,0];
D = [0];

% Compunerea sistemului cu ajutorul matricilor din spatiul starilor

sys = ss(A,B,C,D);

% Simularea iesirii cu sistemului identificat cu ajutorul fenomenului de rezonanta

ysim = lsim(sys,u,t,[y(1);(y(2)-y(1))/(t(2)-t(1))]);

% Afisarea unei comparatii intre iesirea obtinua prin calcul si iesirea originala a sistemului
figure("Name",'Date initiale/Date simulate(cu ajutorul ss)')
plot(t,y,t,ysim)

% Calculaarea erorii medie patratica normalizata

empt = norm(y-ysim)/norm(y-mean(y))*100

%% Creerea obiectelor de tip iddata
% Stabilirea periodei de esantionare
Te = t(2)-t(1);
% Stabilirea datelor de identificare si validare si transformarea acestorain obiecte de tip iddata
Data_id = iddata(y,u,Te);
Data_vd = iddata(y,u,Te);
%% ARX
%Alegerea hiperparamentiilor pentru etoda arx pe baza functiei de transfer
nA = 2; % Reprezinta numarul de poli
nB = 1; % Reprezinta numarul de zerouri +1
nD = 1; % Reprezinta numarul de tacti de intarziere
m_arx = arx(Data_id,[nA,nB,nD]) % Determinarea unui model cu ajutorul metodei neparameterice ARX(Metoda celor mai mici patrate)
H_arx = tf(m_arx) % Determinarea functiei de transfer data de modelul arx
H_arx_c=d2c(H_arx) %Transformarea functiei de transfer din discret in continuu cu ajutorul comenzii d2c
figure
resid(Data_vd,m_arx) % Vizualizarea metodelor de validare cu ajutorul reziduriilor (acesta metoda trebuie sa treaca testul de autocorelatie)
figure
compare(Data_vd,m_arx) %Compararea graficului obtinut cu ajutorul modelului arx cu graficul initial

%% ARMAX (se folosesc aceleasi obiecte iddata)
%Alegerea hiperparamentiilor pentru etoda armax pe baza functiei de transfer
nA = 2;% Reprezinta numarul de poli
nB = 1;% Reprezinta numarul de zerouri +1
nC = 1;% Reprezinta dimensiunea ferestrei alunecatoare
nD = 1;% Reprezinta numarul de tacti de intarziere
m_armax =armax(Data_id,[nA,nB,nC,nD]) % Determinarea unui model cu ajutorul metodei neparameterice ARMAX
H_armax = tf(m_armax) % Determinarea functiei de transfer data de modelul armax
H_armax_c=d2c(H_armax) %Transformarea functiei de transfer din discret in continuu cu ajutorul comenzii d2c
figure
resid(Data_vd,m_armax)  % Vizualizarea metodelor de validare cu ajutorul reziduriilor (acesta metoda trebuie sa treaca testul de autocorelatie)
figure
compare(Data_vd,m_armax) %Compararea graficului obtinut cu ajutorul modelului arx cu graficul initial

%% OE (se folosesc aceleasi obiecte iddata)
%Alegerea hiperparamentiilor pentru etoda armax pe baza functiei de transfer
nB = 1;% Reprezinta numarul de zerouri +1
nF = 2;% Reprezinta numarul de poli
nD = 1;% Reprezinta numarul de tacti de intarziere
m_oe=oe(Data_id,[nB,nF,nD]) % Determinarea unui model cu ajutorul metodei neparameterice OE(Output Error/Eroare la iesire)
H_oe = tf(m_oe) % Determinarea functiei de transfer data de modelul oe
H_oe_c=d2c(H_oe) %Transformarea functiei de transfer din discret in continuu cu ajutorul comenzii d2c
figure
resid(Data_vd,m_oe) % Vizualizarea metodelor de validare cu ajutorul reziduriilor (acesta metoda trebuie sa treaca testul de intercorelatie)
figure
compare(Data_vd,m_oe) %Compararea graficului obtinut cu ajutorul modelului arx cu graficul initial

%% IV (se folosesc aceleasi obiecte iddata)
%Alegerea hiperparamentiilor pentru etoda armax pe baza functiei de transfer
nB = 1;% Reprezinta numarul de zerouri +1
nA = 2;% Reprezinta numarul de poli
nD = 1;% Reprezinta numarul de tacti de intarziere
m_iv=iv4(Data_id,[nA,nB,nD]) % Determinarea unui model cu ajutorul metodei neparameterice IV
H_iv = tf(m_iv) % Determinarea functiei de transfer data de modelul IV
H_iv_c=d2c(H_iv) %Transformarea functiei de transfer din discret in continuu cu ajutorul comenzii d2c
figure
resid(Data_vd,m_iv) % Vizualizarea metodelor de validare cu ajutorul reziduriilor (acesta metoda trebuie sa treaca testul de intercorelatie)
figure
compare(Data_vd,m_iv) %Compararea graficului obtinut cu ajutorul modelului arx cu graficul initial
