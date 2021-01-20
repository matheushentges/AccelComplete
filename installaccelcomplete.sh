#!/bin/bash
#Autor: Matheus Hentges
#Licence Creative Commons

#Sources List
whiptail --title "Aviso!" --msgbox "  Alterando Sources List!!!"  --fb 10 35  3>&1 1>&2 2>&3;

{ echo "deb http://ftp.debian.org/debian buster main non-free contrib";
  echo "deb http://ftp.debian.org/debian buster-updates main contrib non-free";
  echo "deb http://security.debian.org buster/updates main contrib non-free";
} > /etc/apt/sources.list;

apt update && apt upgrade -y

#Declarando funcoes
#SSH
function installssh() {

      apt install openssh-server -y

    { echo "Port $PortaSSH" ;
      echo 'Protocol 2';
      echo 'DebianBanner no';
      echo 'PermitRootLogin no';
      echo 'PermitEmptyPasswords no';
      echo 'ChallengeResponseAuthentication no';
      echo 'X11Forwarding no';
      echo 'PrintMotd no';
      echo 'AcceptEnv LANG LC_*';
      echo 'Subsystem  sftp  /usr/lib/openssh/sftp-server';
      echo 'Match User *,!root';
      echo '    ForceCommand /bin/false';
      echo "Match Address $IPS";
      echo '    PermitRootLogin yes';
    } > /etc/ssh/sshd_config;

    { echo '';

echo ' $$$$$$\                                $$\         $$$$$$$\  $$$$$$$\  $$$$$$$\  ';
echo '$$  __$$\                               $$ |        $$  __$$\ $$  __$$\ $$  __$$\ ';
echo '$$ /  $$ | $$$$$$$\  $$$$$$$\  $$$$$$\  $$ |        $$ |  $$ |$$ |  $$ |$$ |  $$ |';
echo '$$$$$$$$ |$$  _____|$$  _____|$$  __$$\ $$ |$$$$$$\ $$$$$$$  |$$$$$$$  |$$$$$$$  |';
echo '$$  __$$ |$$ /      $$ /      $$$$$$$$ |$$ |\______|$$  ____/ $$  ____/ $$  ____/ ';
echo '$$ |  $$ |$$ |      $$ |      $$   ____|$$ |        $$ |      $$ |      $$ |      ';
echo '$$ |  $$ |\$$$$$$$\ \$$$$$$$\ \$$$$$$$\ $$ |        $$ |      $$ |      $$ |      ';
echo '\__|  \__| \_______| \_______| \_______|\__|        \__|      \__|      \__|      ';
echo '                                                                                  ';
    } > /etc/motd;

      systemctl restart ssh
      systemctl restart sshd

  }


#Pacote Accel
function installaccel() {
  apt install git net-tools libsnmp-dev build-essential cmake gcc linux-headers-`uname -r` git libpcre3-dev libssl-dev liblua5.1-0-dev -y
  mkdir -p /usr/local/src/accel/build
  cd /usr/local/src/accel
  git clone https://github.com/xebd/accel-ppp.git
  cd /usr/local/src/accel/build

cmake \
-DCPACK_TYPE=Debian10 \
-DBUILD_IPOE_DRIVER=TRUE \
-DBUILD_VLAN_MON_DRIVER=TRUE \
-DRADIUS=TRUE \
-DNETSNMP=TRUE \
-DCMAKE_BUILD_TYPE=Debug \
-DCMAKE_INSTALL_PREFIX=/usr \
-DKDIR=/usr/src/linux-headers-$(uname -r) \
../accel-ppp

make

cp drivers/ipoe/driver/ipoe.ko /lib/modules/$(uname -r)
cp drivers/vlan_mon/driver/vlan_mon.ko /lib/modules/$(uname -r)
depmod -a
modprobe  vlan_mon
modprobe  ipoe

echo "vlan_mon" >> /etc/modules
echo "ipoe" >> /etc/modules

cpack -G DEB
apt install ./accel-ppp.deb

systemctl enable accel-ppp
systemctl restart accel-ppp

cd /tmp;
git clone https://github.com/matheushentges/testessh.git
cat /tmp/ConfAccel/accel-ppp.conf >> /etc/accel-ppp.conf
cat /tmp/ConfAccel/dictionary.accel >> /usr/share/accel-ppp/radius/dictionary;

}


#conf accel
function confaccel {

    if (whiptail --title "CONFIGURAR ARQUIVO 'accel-ppp.conf' " --yesno "Deseja iniciar a configuração do arquivo 'accel-ppp.conf' ?" 10 60);then
	    echo "Você escolheu Sim. Saída com status $?.";

#Variaveis e whiptail

		SERVICENAME=$(whiptail --title "Módulo - PPPoE" --inputbox "Por favor, digite o nome a ser criado para o serviço..." --fb 10 60 3>&1 1>&2 2>&3);

		POOLCLIENTE=$(whiptail --title "Módulo - PPPoE" --inputbox "Por favor, digite o nome da pool à ser entregue para seus clientes..." --fb 10 60 3>&1 1>&2 2>&3);

		INTERFACEACCEL=$(whiptail --title "Módulo - PPPoE" --inputbox "Por favor, digite o nome da interface onde seus clientes irão autenticar..." --fb 10 60 3>&1 1>&2 2>&3);

		DNS1=$(whiptail --title "Módulo - DNS" --inputbox "Por favor, digite seu DNS primário..." --fb 10 60 3>&1 1>&2 2>&3);

		DNS2=$(whiptail --title "Módulo - DNS" --inputbox "Por favor, digite seu DNS secundário..." --fb 10 60 3>&1 1>&2 2>&3);

		NOMEDOCONCENTRADOR=$(whiptail --title "Módulo - Radius" --inputbox "digite o nome do seu concentrador, assim como consta no cadastro do mesmo no sistema..." --fb 10 60 3>&1 1>&2 2>&3);

		IPCONCENTRADOR=$(whiptail --title "Módulo - Radius" --inputbox "Digite o IP do seu concentrador, assim como consta no cadastro do mesmo no sistema..." --fb 10 60 3>&1 1>&2 2>&3);

		IPSERVERRADIUS=$(whiptail --title "Módulo - Radius" --inputbox "Digite o IP do seu servidor radius..." --fb 10 60 3>&1 1>&2 2>&3);

		SENHASERVERRADIUS=$(whiptail --title "Módulo - Radius" --inputbox "Digite a senha do seu servidor radius..." --fb 10 60 3>&1 1>&2 2>&3);

		GATEWAYPOOL=$(whiptail --title "Módulo - ip-pool" --inputbox "Por favor, Digite o gateway da pool..." --fb 10 60 3>&1 1>&2 2>&3);

    POOLCLIENTES=$(whiptail --title "Módulo - ip-pool" --inputbox "Por favor, Digite o bloco para entrega aos clientes (ex: 100.64.0.0/24)" --fb 10 60 3>&1 1>&2 2>&3);

		POOLAVISODEATRASO=$(whiptail --title "Módulo - ip-pool" --inputbox "Por favor, Digite o bloco para aviso de atraso... (ex: 172.20.1.0/24)" --fb 10 60 3>&1 1>&2 2>&3);

		POOLBLOQUEIO=$(whiptail --title "Módulo - ip-pool" --inputbox "Por favor, Digite o bloco para bloqueio... (ex: 172.20.2.0/24)" --fb 10 60 3>&1 1>&2 2>&3);

		POOLAGUARDANDOASSINATURA=$(whiptail --title "Módulo - ip-pool" --inputbox "Por favor, Digite o bloco para aguardando assinatura... (ex: 172.20.3.0/24)" --fb 10 60 3>&1 1>&2 2>&3);

#Seds

		sed -i 's/service-name=SERVICENAME/service-name='$SERVICENAME'/' /etc/accel-ppp.conf;

		sed -i 's/ip-pool=POOLCLIENTE/ip-pool='$POOLCLIENTE'/' /etc/accel-ppp.conf;

		sed -i 's/interface=INTERFACEACCEL/interface='$INTERFACEACCEL'/' /etc/accel-ppp.conf;

		sed -i 's/dns1=DNS1/dns1='$DNS1'/' /etc/accel-ppp.conf;

		sed -i 's/dns2=DNS2/dns1='$DNS2'/' /etc/accel-ppp.conf;

		sed -i 's/nas-identifier=NOMEDOCONCENTRADOR/nas-identifier='$NOMEDOCONCENTRADOR'/' /etc/accel-ppp.conf;

		sed -i 's/nas-ip-address=IPDOCONCENTRADOR/nas-ip-address='$IPCONCENTRADOR'/' /etc/accel-ppp.conf;

		sed -i 's/gw-ip-address=IPDOCONCENTRADOR/gw-ip-address='$IPCONCENTRADOR'/' /etc/accel-ppp.conf;

		sed -i 's/server=IPSERVERRADIUS,SENHARADIUS/server='$IPSERVERRADIUS','$SENHASERVERRADIUS'/' /etc/accel-ppp.conf;

		sed -i 's/dae-server=IPSERVERRADIUSCOA:3799,SENHARADIUSCOA/dae-server='$IPSERVERRADIUS':3799,'$SENHASERVERRADIUS'/' /etc/accel-ppp.conf;

		sed -i 's/dm_coa_secret=SENHARADIUSCOA/dm_coa_secret='$SENHASERVERRADIUS'/' /etc/accel-ppp.conf;

		sed -i 's/gw-ip-address=GATEWAYPOOL/gw-ip-address='$GATEWAYPOOL'/' /etc/accel-ppp.conf;

    sed -i 's:POOLCLIENTES,name='$POOLCLIENTE':'$POOLCLIENTE',name='$POOLCLIENTE':' /etc/accel-ppp.conf;

		sed -i 's:POOLAVISODEATRASO,name=pool_aviso_atraso:'$POOLAVISODEATRASO',name=pool_aviso_atraso:' /etc/accel-ppp.conf;

		sed -i 's:POOLBLOQUEIO,name=pool_bloqueio:'$POOLBLOQUEIO',name=pool_bloqueio:' /etc/accel-ppp.conf;

		sed -i 's:POOLAGUARDANDOASSINATURA,name=pool_aguardando_assinatura:'$POOLAGUARDANDOASSINATURA',name=pool_aguardando_assinatura:' /etc/accel-ppp.conf;

		/etc/init.d/accel-ppp restart;

    else
		echo "Você escolheu Não. Saída com status $?.";
	fi
}

#Declarando Variaveis
OS=`cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' | awk '{print $1}'`
VERSAO=`cat /etc/os-release | grep "VERSION_ID" | sed 's/VERSION_ID=//g' | sed 's/["]//g' | awk '{print $1}'`

#Inicio da validacao do sistema
if [ "$OS" != "Debian" ]; then
    echo "   Sua distribuicao linux ($OS) nao e o Debian!!!"; echo;
else
	if [ "$VERSAO" != "10" ]; then
	    echo "   Sua distribuicao linux Debian ($VERSAO) nao esta na versao 10!!!"; echo
	else

#Instalacao e configuracao do SSH
whiptail --title "Acesso ao Accel" --msgbox "Na Proxima etapa preencha os IPs que terao acesso ao accel via SSH. Ex.:(192.168.0.0/24,45.175.128.1) e tambem a porta ssh para o equipamento, caso nao deseje alterar digite 22.                                Escolha OK para continuar." --fb 15 50
whiptail --title "Aviso!" --msgbox "Caso nao preencher nenhum dado, o SSH sera liberado na porta padrao(22) e deixando aberto para o mundo todo(0.0.0.0/0)!!!"  --fb 15 50  3>&1 1>&2 2>&3;

IPS=$(whiptail --title "IPs no sshd_config" --inputbox "Digite os IPs:              Ex.:192.168.0.0/24,45.175.128.1" --fb 10 50 3>&1 1>&2 2>&3)
PortaSSH=$(whiptail --title "Porta SSH" --inputbox "Digite a porta ssh que deseja definir:            Ex.:50022" --fb 10 50 3>&1 1>&2 2>&3)
if [ "$PortaSSH" != "" ]||[ "$IPS" != "" ];then
   installssh;
    else
      { echo "Port 22" ;
        echo 'Protocol 2';
        echo 'DebianBanner no';
        echo 'PermitRootLogin no';
        echo 'PermitEmptyPasswords no';
        echo 'ChallengeResponseAuthentication no';
        echo 'X11Forwarding no';
        echo 'PrintMotd no';
        echo 'AcceptEnv LANG LC_*';
        echo 'Subsystem  sftp  /usr/lib/openssh/sftp-server';
        echo 'Match User *,!root';
        echo '    ForceCommand /bin/false';
        echo "Match Address 0.0.0.0/0";
        echo '    PermitRootLogin yes';
      } > /etc/ssh/sshd_config;

      service ssh restart
    fi
#instalacao pacote accel
    whiptail --title "Instalacao Accel" --msgbox " Nesse passo instalaremos o Accel"  --fb 15 40  3>&1 1>&2 2>&3;
    (whiptail --title "Instalacao Accel" --yesno " Deseja prosseguir?" --yes-button "Não" --no-button "Sim" 15 40  3>&1 1>&2 2>&3);
    if [ $? -eq 1 ]; then
        installaccel;

        SUCESSO=`systemctl status accel-ppp | grep "active" | sed 's/active=//g' | sed 's/["]//g' | awk '{print $1}'`
        if [ "$SUCESSO" = "Active:" ];

        then

        echo "                       _        ____   ____   ____   ";
        echo "     /\               | |      |  __ \|  __ \|  __ \ ";
        echo "    /  \   ___ ___ ___| |______| |__) | |__) | |__) |";
        echo "   / /\ \ / __/ __/ _ \ |______|  ___/|  ___/|  ___/ ";
        echo "  / ____ \ (_| (_|  __/ |      | |    | |    | |     ";
        echo " /_/___ \_\___\___\___|_|  _   |_|    |_|    |_|     ";
        echo " |_   _|         | |      | |         | |     | |    ";
        echo "   | |  _ __  ___| |_ __ _| | __ _  __| | ___ | |    ";
        echo "   | | | |_ \/ __| __/ _| | |/ _  |/  |_|/ _ \| |    ";
        echo "  _| |_| | | \__ \ || (_| | | (_| | (_| | (_) |_|    ";
        echo " |_____|_| |_|___/\__\__,_|_|\__,_|\__,_|\___/(_)    ";
        echo;
        echo "    Status do servico Accel";
        echo " ";
        systemctl status accel-ppp

        confaccel;

        else
          echo "     Ocorreu um erro na instalacao do pacote, reinicie o processo";
          echo "     Status do servico Accel";
          echo " ";
          systemctl status accel-ppp

        fi

    else
        echo " ";
        echo " ";
        echo "Operacao cancelada pelo usuario!";
        echo "Lembrando que as configuracoes do SSH foram alteradas no passo anterior!";
        echo "Caso deseje alterar edite o arquivo /etc/ssh/sshd_config.";
        echo " ";
        echo " ";
    fi
  fi
fi
