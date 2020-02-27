#!/usr/bin/env bash
#sok.sh - .:SERVER OK:. For Linux with DirectAdmin & CPanel by .:DANIEL BUSTAMANTE:.

#VARIABLES
#identificamos el sistema operativo
    if cat /etc/redhat-release > /dev/null 2>&1
    then 
	    RedHat=$(cat /etc/redhat-release)
	    SO=$RedHat
	    DLX=
    else 
	    Debian=$(lsb_release -a)
	    SO=$Debian
    fi
#identificamos el panel de control y su versión, importante para otras funciones
	if cat /usr/local/directadmin/custombuild/versions.txt > /dev/null 2>&1
	then
		DA=$(grep ^BUILDSCRIPT_VER /usr/local/directadmin/custombuild/build | cut -d= -f2)
		PANEL=$"DirectAdmin con CustomBuild $DA"
		PANELS=1
	else 
		WHM=$(/usr/local/cpanel/cpanel -V)
		PANEL=$"WHM $WHM"
		PANELS=2
	fi

#identificamos el MotherBoard
	MTHBD=$(dmidecode | grep -A3 '^System Information' | grep Manufacturer)

#Identificamos el CPU
	if dmidecode | grep CPU | grep Version | cut -d: -f2 > /dev/null 2>&1
	then
	CPU=$(cat /proc/cpuinfo | grep 'CPU' | head -1 | cut -d: -f2)
	else
	CPU=$(dmidecode | grep CPU | grep Version | cut -d: -f2)
	fi

#Identificamos la RAM
	RAM=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }' | while read KB dummy;do echo $((KB/1024))MB;done)

#Identificamos el disco DISCO
    HD=$(fdisk -l | grep Disk | grep /dev | cut -d, -f1)

#validamos el RDNS
	RDNS=$(getent hosts $HOSTNAME | awk '{ print $1 ; exit }')
#validamos el PTR
	PTR=$(dig +noall +answer -x $RDNS | awk '{print $5 ; exit}')
#informamos version de apache
	VersionAPACHE=$(httpd -v | awk {'print $3 ; exit'} | cut -d/ -f2)
#informamos version de mysql
	VersionMYSQL=$(mysql --version|awk '{ print $5 }'|awk -F\, '{ print $1 }')
#informamos cantidad de emails en la cola de emails
	COLAexim=$(exim -bpc)
#informamos sus DNS
	DNS=$(cat /etc/resolv.conf | awk {'print $2'})
#informamos la carga actual
	Carga=$(cat /proc/loadavg | awk {'print $1 ; exit'})
#informamos la carga hace 15 minutos
	Carga15=$(cat /proc/loadavg | awk {'print $3 ; exit'})
#informamos la fecha
	Fecha=$(date +'%d-%m-%Y')
#informamos la hora actual
	Hora=$(date | awk {'print $4 , $5'})
#informamos link temporales de usuarios
	if [[ $PANELS == "1" ]] ; then
	LinkUsuariosDA=$(cat /usr/local/directadmin/custombuild/options.conf | grep userdir_access)
	if [[ $LinkUsuariosDA == *"yes"* ]]; then
		ModUserDirstatus=Habilitado
	else
		ModUserDirstatus=Deshabilitado
	fi
	else
	ModUserDirstatus=Deshabilitado
	fi
#informamos version del panel de control
	if [[ $PANELS == "1" ]] ; then
		PANELversion=$(/usr/local/directadmin/directadmin v | awk  '{print $3 }')
	else
		PANELversion=$(/usr/local/cpanel/cpanel -V | awk {'print $1'})
	fi
#informamos el webserver
	if [[ $PANELS == "1" ]] ; then
		VersionWebSrv=$(cat /usr/local/directadmin/custombuild/options.conf | grep webserver | cut -d= -f2)
	fi

#informamos la version de exim
	VersionEXIM=$(exim -bV | awk {'print $3 ; exit'})

#informamos los puertos smtp
	if [[ $DA == *"2.0"* ]]; then

		if cat /etc/exim.conf | grep daemon_smtp_ports |cut -d= -f2 | head -1 > /dev/null 2>&1; then

		PuertosSMTP=$(cat /etc/exim.conf | grep daemon_smtp_ports |cut -d= -f2 | head -1)

		else
		
		PuertosSMTP=$(cat /etc/exim.variables.conf | grep daemon_smtp_ports |cut -d= -f2 | head -1)
	
		fi
  	fi

#informamos IP SMTP
	if cat /etc/virtual/domainips > /dev/null 2>&1; then
	IPdelSMTP=$(cat /etc/virtual/domainips | cut -d# -f1)
	else
	IPdelSMTP=$(cat /etc/virtual/domainips | cut -d# -f1)
    fi
	
#informamos si spamassasins esta habilitado
	if [[ $PANELS == "1" ]] ; then

		if /usr/bin/spamassassin -V > /dev/null 2>&1; then
		Spamassasinsstatus=Habilitado
		else
		Spamassasinsstatus=Deshabilitado
		fi
	else
		if /usr/local/cpanel/3rdparty/perl/528/bin/spamassassin -V | head -1 | awk {' print  $3 '} > /dev/null 2>&1; then
		Spamassasinsstatus=Habilitado
		else
		Spamassasinsstatus=Deshabilitado
		fi
	fi
	

#informamos versiones y modos de php
	if [[ $PANELS == "1" ]] ; then
		VersionesPHP=$(cat /usr/local/directadmin/custombuild/options.conf | grep php | grep release)
		VersionesModoPHP=$(cat /usr/local/directadmin/custombuild/options.conf | grep php | grep mode)
	else
		VersionesPHP=$(/usr/local/cpanel/bin/rebuild_phpconf -current)
	fi

#informamos si let's encryt esta habilitado
	if [[ $PANELS == "1" ]] ; then
		letsencryt=$(/usr/local/directadmin/directadmin c | grep letsencrypt= | cut -d= -f2)
		if [[ $letsencryt == *"1"* ]]; then
		letsencrytstatus=Habilitado
		else
		letsencrytstatus=Deshabilitado
		fi

	else
	
	if [[ $PANELS == "2" &&  $SO == *"Cloud"* ]] ; then
	letsencryt=$(/usr/local/cpanel/bin/whmapi1 get_autossl_providers | grep enable)
		if [[ $letsencryt == *"1"* ]]; then
		letsencrytstatus=Habilitado
		else
		letsencrytstatus=Deshabilitado
		fi
	else
		letsencryt=$(whmapi1 get_autossl_providers | grep enabled)
		if [[ $letsencryt == *"1"* ]]; then
		letsencrytstatus=Habilitado
		else
		letsencrytstatus=Deshabilitado
		fi
	fi
	fi

#informamos el top 5 de las cuentas con más envios realizados
	if [[ $PANELS == "1" ]] ; then
		topemisores=$(cat /var/log/directadmin/system.log* | grep sent | sort -n | cut -d: -f7 | head -5)
	else
		topemisores=$(exigrep @ /var/log/exim_mainlog | grep _login | sed -n 's/.*_login:\(.*\)S=.*/\1/p' | sort | uniq -c | sort -nr -k1 | head -5)
	fi

#hacemos telnet al puerto 25, 587,

	#obtenemos todas las ip del servidor




# ----------------------------------
# VARIABLES DEL MENU
# ----------------------------------
EDITOR=vim
PASSWD=/etc/passwd
RED='\033[0;41;30m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
STD='\033[0;0;39m'
 
#FIN VARIABLES

# ----------------------------------
# FUNCIONES
# ----------------------------------
pause(){
	printf "\n"
	printf "\n"
  	read -p "Presiona [ENTER] para volver volver al MENU PRINCIPAL..." fackEnterKey
  	printf "\n"
}

uno(){
	clear
	printf "\n"
	echo -e "
${GREEN}CPU:${STD} $CPU ${GREEN}RAM:${STD} $RAM 
${GREEN}DISCO:${STD} $HD 
${GREEN}MOTHERBOARD:${STD} $MTHBD
${GREEN}Hostname:${STD} $HOSTNAME ${GREEN}RDNS:${STD} $RDNS ${GREEN}PTR:${STD} $PTR
${GREEN}Sistema Operativo:${STD} $SO 
${GREEN}Panel de Control:${STD} $PANEL ${GREEN}Version de Panel:${STD} $PANELversion
${GREEN}Let's Encryt:${STD} $letsencrytstatus ${GREEN}ModUserDIR /~:${STD} $ModUserDirstatus ${GREEN}SpamaAsassins:${STD} $Spamassasinsstatus
${GREEN}Carga actual:${STD} $Carga ${GREEN}Carga hace 15 minutos:${STD} $Carga15
${GREEN}Fecha:${STD} $Fecha ${GREEN}Hora:${STD} $Hora
${GREEN}Apache:${STD} $VersionAPACHE ${GREEN}WebServer:${STD} $VersionWebSrv ${GREEN}MySQL:${STD} $VersionMYSQL
${GREEN}CSF:${STD} $(csf -V | cut -d: -f2)
${GREEN}Exim:${STD} $VersionEXIM ${GREEN}Puertos SMTP:${STD} $PuertosSMTP
${GREEN}Correos en cola:${STD} $(exim -bpc) ${GREEN}IP SMTP:${STD} $IPdelSMTP
${GREEN}Top 5 emisores:${STD}
$topemisores
${GREEN}Versiones de PHP:${STD}
$VersionesPHP
$VersionesModoPHP
${GREEN}DNS:${STD}
$DNS
 \n

"
    pause
}
 
# do something in two()
dos(){

	#obtenemos todas las ip del servidor
	IPS=$(ip addr show scope global | awk '$1 ~ /^inet/ {print $2}' | sort)
	echo "Este servidor posee las siguientes IP en su interfaz:"
	echo "$IPS"
	printf "\n"
	sleep 3	
	#validamos ping de todas las IP del servidor
	ip addr show scope global | awk '$1 ~ /^inet/ {print $2}' | cut -f1 -d "/" -s | sort > ipdelservidor.txt
    echo "Realizando ping localmente a las IP de su interfaz:"
	cat ipdelservidor.txt |  while read output
	
	do
	    ping -c 1 "$output" > /dev/null
	    if [ $? -eq 0 ]; then
	    	echo -e "IP $output ${GREEN}OK responde ping${STD}" 
	    else
	    	echo -e "IP $output ${RED}¡NO responde ping!${STD}"
	    fi
	done
	sleep 3
	printf "\n"
	printf "\n"
	#validamos ping de todas las IP del servidor
	ip addr show scope global | awk '$1 ~ /^inet/ {print $2}' | cut -f1 -d "/" -s | sort > ipdelservidor.txt
    echo "Realizando ping externamente a las IP de su interfaz:"
	cat ipdelservidor.txt |  while read output
	
	do
	    ping -c 1 "$output" > /dev/null
	    if [ $? -eq 0 ]; then
	    	echo -e "IP $output ${GREEN}OK responde ping${STD}" 
	    else
	    	echo -e "IP $output ${RED}¡NO responde ping!${STD}"
	    fi
	done
	sleep 3

    pause
}
 
tres(){

#Matamos procesos de backup (compresión y tareas del panel) en DirectAdmin y WHM
killall -9 gzip > /dev/null 2>&1 ; killall -9 tar > /dev/null 2>&1 ; killall -9 dataskq > /dev/null 2>&1 ; killall -9 cpbackup > /dev/null 2>&1 ; killall -9 pkgacct  > /dev/null 2>&1; killall -9 gunzip2  > /dev/null 2>&1 ; killall -9 pig z > /dev/null 2>&1

#Matamos procesos de ClamScan (antivirus)
/etc/init.d/clamd stop > /dev/null 2>&1 ; killall /usr/bin/clamscan > /dev/null 2>&1 ; killall clamd -9  > /dev/null 2>&1

#


#DISCO: Verificamos el espacio en disco del servidor
		printf "\n"
		echo "Validaremos el espacio del disco de este servidor:"
		printf "\n"
		echo "$(df -h)"
		printf "\n"
		sleep 3
		df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
		do
		  echo $output
		  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
		  particion=$(echo $output | awk '{ print $2 }' )
		  if [ $usep -ge 95 ]; then
		  echo -e "${RED}La partición \"$particion ($usep%)\" tiene más de 95% de su dico lleno, se deberia hacer limpieza${STD}"
		  fi
		done  
		  printf "\n"

	
		#do
		 read -r -p "Indica si deseas liberar o no espacio en este servidor [SI/NO] " input
		 
		 case $input in
		     s|si|S|SI)

		 echo "¡Genial! vamos a liberar espacio en este equipo"
		 #DISCO: Borramos  tar.gz, .tar, .tar.bz2, .bz2, .tar.gzip, .tgz, .gz, .rar, .zip
							printf "\n"
							echo "El espacio en disco actual es:"
							discoahora=$(df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $3 " " $5 " " $1 }')
							echo "$discoahora"
							printf "\n"
							sleep 4
							printf "\n"
							echo "Intentaré optimizar mejor este espacio, aguarda por favor, tómate un café..."

							  find / -name "*.tar.gz" -type f -exec rm -rf {} > /dev/null 2>&1 \;
							  find / -name "*.tar" -type f -exec rm -rf {} > /dev/null 2>&1 \;
							  find / -name "*.tar.bz2" -type f -exec rm -rf {} > /dev/null 2>&1 \;
							  find / -name "*.bz2" -type f -exec rm -rf {} > /dev/null 2>&1 \;
							  find / -name "*.tar.gzip" -type f -exec rm -rf {} > /dev/null 2>&1 \;
							  find / -name "*.tgz" -type f -exec rm -rf {} > /dev/null 2>&1 \;
							  find / -name "*.gz" -type f -exec rm -rf {} > /dev/null 2>&1 \;
							  find / -name "*.rar" -type f -exec rm -rf {} > /dev/null 2>&1 \;
							  find / -name "*.zip" -type f -exec rm -rf {} > /dev/null 2>&1 \;

							  if [[ $PANELS == "1" ]] ; then
							  	cd /home/tmp
							  	rm -rf admin.*
							  fi
							  if [[ $PANELS == "2" ]] ; then
							  	for user in `/bin/ls -A /var/cpanel/users` ; do rm -fv /home/$user/backup-*$user.tar.gz ; done > /dev/null 2>&1 
							  fi
							 sleep 4
							printf "\n"
							printf "\n"
							echo "Se finalizaron las tareas, el nuevo espacio en disco es:"
							discodespues=$(df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }')
							echo "$discodespues"
							sleep 5 ; pause
		 		;;

		     n|no|N|NO)
		printf "\n"
		 echo "OK, no se realizará limpieza ni optimización del disco" ; pause

		        ;;
		     *)
		printf "\n"
		 echo "Mmmm.. tómate un café, elegiste una opción incorrecta"
		 ;;
		 esac
		#done

		sleep 8
        pause
}

cuatro(){

		#EXIM: Verificamos el estado, los puertos y lo reiniciamos si está detenido y limpiamos emails frizados y con más de 1 dia en espera de distribución.
		SERVICE='exim'
		COLA=$(exim -bpc)

		if ps ax | grep -v grep | grep $SERVICE > /dev/null
		then
			echo -e "${GREEN}¡Genial! el servicio $SERVICE esta operando de forma normal${STD} y actualmente se posee $COLA correos en su bandeja de salida"
		else
			echo -e "${RED}¡Ups! el servicio $SERVICE esta detenido${STD}, voy a reiniciarlo y validar su operatividad:"
			printf "\n"
			service $SERVICE restart;
			sleep 6
			service $SERVICE status;
		fi

		sleep 8
		printf "\n"
		echo -e "de los $COLA emails en la bandeja de salida se procederá a limpiar los que están ${RED}frizados${STD}:"
		sleep 6
		FRIZADOS=$(exiqgrep -zi | wc -l)
		if [ "$FRIZADOS" -ge "1" ]; then
			printf "\n"
			echo -e "Se encontraron $FRIZADOS emails ${RED}frizados${STD}, se los eliminará de la bandeja de salida.."
			printf "\n"
			sleep 2
		 exiqgrep -zi|xargs exim -Mrm
		 COLASINFRIZADOS=$(exim -bpc)
		 	printf "\n"
		 	printf "\n"
		 	echo -e "${GREEN}¡Listo!${STD} ahora solo quedan $COLASINFRIZADOS emails en la bandeja de salida sin estar frizados"
		 sleep 4
		else
		 printf "\n"
		 echo -e "${GREEN}¡Genial!${STD} no se encontraron emails frizados"
		 sleep 4
		fi
		 printf "\n"
		 echo "de los $COLASINFRIZADOS emails restantes en la bandeja de salida limpiaré los que están detenidos hace más de 1 dia.."
		 printf "\n"
		 sleep 4
		DETENIDOSUNDIA=$(exiqgrep -o 86400 -i | wc -l)
		if [ "$DETENIDOSUNDIA" -ge "1" ]; then
		echo "Se encontraron $DETENIDOSUNDIA emails detenidos hace 1 dia, voy a limpiarlos.."
		 printf "\n"
		 sleep 2
		 exiqgrep -o 86400 -i | xargs exim -Mrm
		 COLASINDETENIDOS=$(exim -bpc)
		 printf "\n"
		 printf "\n"
		 echo -e "${GREEN}¡Listo!${STD} ahora solo quedan $COLASINDETENIDOS emails en la bandeja de salida en estado normales para su distribución"
		 sleep 4
		else
		 echo -e "${GREEN}¡Genial!${STD} no se encontraron emails detenidos por 1 día, ningún correo normal será afectado para su distribución actual."
		fi

		sleep 4

		#Si el panel es WHM con CloudLinux
		if [[ $PANELS == "2" &&  $SO == *"Cloud"* ]] ; then

		#identificamos la cuenta de email con mayores envios
		emailspammer=$(exigrep @ /var/log/exim_mainlog | grep _login | sed -n 's/.*_login:\(.*\)S=.*/\1/p' | sort | uniq -c | sort -nr -k1 | awk {'print $2'} | head -1)
		#identificamos la cantidad de envios que realizo dicha cuenta de email
		enviosdelspammer=$(exigrep @ /var/log/exim_mainlog | grep _login | sed -n 's/.*_login:\(.*\)S=.*/\1/p' | sort | uniq -c | sort -nr -k1 | awk {'print $1'} | head -1)
		#identificamos el dominio de esa cuenta de email
		dominiospammer=$(exigrep @ /var/log/exim_mainlog | grep _login | sed -n 's/.*_login:\(.*\)S=.*/\1/p' | sort | uniq -c | sort -nr -k1 | awk {'print $2'} | head -1 | cut -d@ -f2)
		#identificamos el usuario propietario de ese dominio
		usuariospammer=$(/scripts/whoowns $dominiospammer)

		echo -e "La cuenta ${RED}$emailspammer${STD} realizó ${RED}$enviosdelspammer${STD} envios.."
		#while true
		#do
		  read -r -p "¿Deseas suspender sus envios si los considera abusivos? [s/n] " input

		  case $input in
		      s|si|S|SI)
		      
				#deshabilitamos los envios de ese usuario para CloudLinux
				/usr/local/cpanel/bin/whmapi1 suspend_outgoing_email user=$usuariospammer

				#informamos lo realizado
				echo -e "Se deshabilitaron los envios la cuenta ${RED}$emailspammer${STD} porque se detectaron ${RED}$enviosdelspammer${STD} envios abusivos"
				printf "\n"
				printf "\n"
				echo -e "limpiaremos los envios generado únicamente por la cuenta ${RED}$emailspammer${STD} de la cola del servidor"
				printf "\n"
				#borramos de la cola de envios masivos realizados por la cuenta spammer
				exim -bp | grep '$emailspammer' | awk '{print $3}' | xargs exim -Mrm > /dev/null 2>&1
				sleep 4
				echo -e "${GREEN}¡Genial!${STD} ningún otro correo normal será afectado para su distribución actual."
				printf "\n"
				printf "\n"
		      ;;
		      n|no|N|NO)
		      echo "No"
		      ;;
		      *)
		    echo "Mmmm.. tómate un café, elegiste una opción incorrecta"
		      ;;
		  esac
		#done

		fi
		
		#Si el panel es WHM solo
		if [[ $PANELS == "2" ]] ; then

		#identificamos la cuenta de email con mayores envios
		emailspammer=$(exigrep @ /var/log/exim_mainlog | grep _login | sed -n 's/.*_login:\(.*\)S=.*/\1/p' | sort | uniq -c | sort -nr -k1 | awk {'print $2'} | head -1)
		#identificamos la cantidad de envios que realizo dicha cuenta de email
		enviosdelspammer=$(exigrep @ /var/log/exim_mainlog | grep _login | sed -n 's/.*_login:\(.*\)S=.*/\1/p' | sort | uniq -c | sort -nr -k1 | awk {'print $1'} | head -1)
		#identificamos el dominio de esa cuenta de email
		dominiospammer=$(exigrep @ /var/log/exim_mainlog | grep _login | sed -n 's/.*_login:\(.*\)S=.*/\1/p' | sort | uniq -c | sort -nr -k1 | awk {'print $2'} | head -1 | cut -d@ -f2)
		#identificamos el usuario propietario de ese dominio
		usuariospammer=$(/scripts/whoowns $dominiospammer)	

		echo -e "La cuenta ${RED}$emailspammer${STD} realizó ${RED}$enviosdelspammer${STD} envios.."
		#while true
		#do
		 read -r -p "¿Deseas suspender sus envios si los considera abusivos? [SI/NO] " input

		  case $input in
		      s|si|S|SI)
		      
				#deshabilitamos los envios de ese usuario para CloudLinux
				whmapi1 suspend_outgoing_email user=$usuariospammer

				#informamos lo realizado
				echo -e "Se deshabilitaron los envios la cuenta ${RED}$emailspammer${STD} porque se detectaron ${RED}$enviosdelspammer${STD} envios abusivos"
				printf "\n"
				printf "\n"
				echo -e "limpiaremos los envios generado únicamente por la cuenta ${RED}$emailspammer${STD} de la cola del servidor"
				printf "\n"
				#borramos de la cola de envios masivos realizados por la cuenta spammer
				exim -bp | grep '$emailspammer' | awk '{print $3}' | xargs exim -Mrm > /dev/null 2>&1
				sleep 4
				echo -e "${GREEN}¡Genial!${STD} ningún otro correo normal será afectado para su distribución actual."
				printf "\n"
				printf "\n"

		      ;;
		      n|no|N|NO)
		      echo "No"
		      ;;
		      *)
		    echo "Mmmm.. tómate un café, elegiste una opción incorrecta"
		      ;;
		  esac
		#done

		#Si el panel es DirectAdmin
		else
		echo "Tines un DirectAdmin y esta sección está en desarrollo..."
		fi

		if [[ $PANELS == "1" &&  $Spamassasinsstatus == *"Deshabilitado"* ]] ; then

			read -r -p "SpamAssasins está deshabilitado ¿Deseas instalarlo en este servidor? [s/n] " input

		  case $input in
		        s|si|S|SI)
				printf "\n"
				echo -e "Bien, instalaremos el ${GREEN}SpamaAsassin${STD} en este servidor.."
				printf "\n"

				#descargando paquetes de spamassasins
				yum -y install perl-ExtUtils-MakeMaker perl-Digest-SHA perl-Net-DNS perl-NetAddr-IP perl-Archive-Tar perl-IO-Zlib perl-Digest-SHA perl-Mail-SPF \
				perl-IO-Socket-INET6 perl-IO-Socket-SSL perl-Mail-DKIM perl-DBI perl-Encode-Detect perl-HTML-Parser \
				perl-HTML-Tagset perl-Time-HiRes perl-libwww-perl perl-Sys-Syslog perl-DB_File perl-Razor-Agent pyzor

				#instalación por custombuild
				cd /usr/local/directadmin/custombuild ; ./build set spamd spamassassin ; ./build spamassassin ; service exim start
				printf "\n"
				echo -e "la intalación esta ${GREEN}completada${STD} ahora validemos si el servicio spamd esta ejecutándose.."
				printf "\n"
				ps ax |grep spamd
				printf "\n"
				echo -e "${GREEN}¡Listo!${STD} SpamaAsassin está activo"
				printf "\n"
				printf "\n"

				#Actualizamos para saber si spamassasins esta habilitado
				if [[ $PANELS == "1" ]] ; then

					if /usr/bin/spamassassin -V > /dev/null 2>&1; then
					Spamassasinsstatus=Habilitado
					else
					Spamassasinsstatus=Deshabilitado
					fi
				else
					if /usr/local/cpanel/3rdparty/perl/528/bin/spamassassin -V | head -1 | awk {' print  $3 '} > /dev/null 2>&1; then
					Spamassasinsstatus=Habilitado
					else
					Spamassasinsstatus=Deshabilitado
					fi
				fi
				printf "\n"
		      ;;
		       n|no|N|NO)
		      echo -e "Okey, NO instalaremos el ${GREEN}SpamaAsassin${STD} en este servidor"
		      ;;
		      *)
		    echo "Mmmm.. tómate un café, elegiste una opción incorrecta"
		      ;;
		  esac
				
		fi
        pause
}

cinco(){

		#ACTUALIZACIONES de RPM: Verificamos los últimos repositorios de yum update
		printf "\n"
		echo "Actualizaremos los RPM para futuras actualizaciones de este servidor sin modificar el Kernel"
		printf "\n"
		sleep 2
		yum clean all #limpiar y actualizar lista de repositorios
		yum upgrade -y #actualizar repositorios
		yum -y --exclude=kernel\* update #acualizar sin modificar el kernel
		sleep 2
		printf "\n"
		echo -e "${GREEN}¡Listo! se han instalado las ultimas dependencias para los RPM${STD}"
        sleep 2
 		printf "\n"
		echo "Instalaremos Let's Encryt en breve.."
		printf "\n"

		#instalaremos Let's Encrytp en DirectAdmin
		if [[ $PANELS == "1" ]] ; then
			echo "letsencrypt=1" >> /usr/local/directadmin/conf/directadmin.conf
			service directadmin restart
			echo "enable_ssl_sni=1" >> /usr/local/directadmin/conf/directadmin.conf
			service directadmin restart
			cd /usr/local/directadmin/custombuild
			./build update
			./build rewrite_confs
			./build update
			./build letsencrypt
			printf "\n"
			echo -e "${GREEN}¡Genial! Let's Encryt quedo instalado y listo para usarse${STD}"
			printf "\n"
			printf "\n"

			
		else
		#instalaremos Let's Encrytp en WHM
			/scripts/install_lets_encrypt_autossl_provider
			printf "\n"
			echo -e "${GREEN}¡Genial! Let's Encryt quedo instalado y listo para usarse${STD}"
			printf "\n"
			printf "\n"

	        
    	fi

	    	#actualizaremos el status de si let's encryt esta habilitado
		if [[ $PANELS == "1" ]] ; then
			letsencryt=$(/usr/local/directadmin/directadmin c | grep letsencrypt= | cut -d= -f2)
			if [[ $letsencryt == *"1"* ]]; then
			letsencrytstatus=Habilitado
			else
			letsencrytstatus=Deshabilitado
			fi

		else
		
		if [[ $PANELS == "2" &&  $SO == *"Cloud"* ]] ; then
		letsencryt=$(/usr/local/cpanel/bin/whmapi1 get_autossl_providers | grep enable)
			if [[ $letsencryt == *"1"* ]]; then
			letsencrytstatus=Habilitado
			else
			letsencrytstatus=Deshabilitado
			fi
		else
			letsencryt=$(whmapi1 get_autossl_providers | grep enabled)
			if [[ $letsencryt == *"1"* ]]; then
			letsencrytstatus=Habilitado
			else
			letsencrytstatus=Deshabilitado
			fi
		fi
		fi

		pause

		}

seis(){

		printf "\n"
		echo -e "${GREEN}Vamos a setear la zona horaria para este servidor:${STD}"
		printf "\n"
		printf "\n"
		#guardamos la hora actual
		horaanterior=$(date)
		sleep 2
		echo -e "${GREEN}Selecciona por el NÚMERO tu continenete, luego tu pais y por último tu región para setear la hora correcta...${STD}"
		printf "\n"
		printf "\n"
		sleep 4
		#elegir hora
		tzselect
		#instalamos el Network Time Protocol
		sleep 2
		printf "\n"
		printf "\n"
		echo -e "Listo, ahora instalaremos ${GREEN}NTP (Network Time Protocol)..${STD}"
		sleep 2
		printf "\n"
		printf "\n"
		yum install ntp ntpdate ntp-doc -y
		#reemplazar pool por servidores de argentina
		#sed -i 's/190.105.235.102/190.183.63.113/g' /etc/ntp.conf
		/etc/init.d/ntpd start > /dev/null
		service ntpd start > /dev/null
		service ntpd restart > /dev/null
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Bien,  ${GREEN}actualiza el TimeZone en PHP de ser necesario..${STD}"
		printf "\n"
		printf "\n"

		#/usr/local/php*/lib/php.ini
		sleep 2
		printf "\n"
		echo -e "${GREEN}¡Bien! verifica en estos momentos la hora del servidor:${STD}"
		printf "\n"
		printf "\n"
		echo -e "Anterior FECHA Y HORA: $horaanterior"
		printf "\n"
		echo -e "Nueva FECHA Y HORA: $(date)"
		printf "\n"
		printf "\n"
		sleep 2
	
	
        pause
}

siete(){

		 read -r -p "¿Deseas habilitar NGINX+APACHE [1] ó APACHE [2] como WebServer? [1/2] " input

		  case $input in
		      1)
				printf "\n"
				echo -e "${GREEN}¡Genial! habilitemos NGINX + APACHE como WebServer en este servidor:${STD}"
				printf "\n"
				printf "\n"
				sleep 2
				echo -e "Aplicando la configuración necesaria..."
				sleep 2
				printf "\n"
				printf "\n"
				cd /usr/local/directadmin/custombuild ; ./build update ; ./build set webserver nginx_apache ; ./build nginx_apache ; ./build php y ; ./build rewrite_confs
				sleep 2
				printf "\n"
				echo -e "${GREEN}¡Listo! se instaló NGINX + APACHE como tu WebServer${STD}"
				printf "\n"

		      ;;
		      2)

		     	printf "\n"
				echo -e "${GREEN}¡Genial! habilitemos APACHE como WebServer en este servidor:${STD}"
				printf "\n"
				printf "\n"
				sleep 2
				echo -e "Aplicando la configuración necesaria..."
				sleep 2
				printf "\n"
				printf "\n"
				cd /usr/local/directadmin/custombuild ; ./build update  ; ./build set webserver apache  ; ./build apache  ; ./build php y ; ./build rewrite_confs
				sleep 2
				printf "\n"
				echo -e "${GREEN}¡Listo! se instaló APACHE como tu WebServer${STD}"
				printf "\n"

		      ;;
		      *)
			printf "\n"
		    echo "Mmmm.. tómate un ${GREEN}café${STD}, elegiste una opción incorrecta"
		    printf "\n"
		      ;;
		  esac
		#done

        pause
}

ocho(){
		printf "\n"
		echo "¡Vamos a purgar la QUEUE de emails de este servidor!"
		printf "\n"
		sleep 2
		echo -e "${GREEN}Actualmente posee la siguiente cantidad de emails:${STD} $(exim -bpc)"
		printf "\n"
		sleep 3
		#eliminamos todo la queue1|
		echo "Bien, a esos email los estoy limpiando de la QUEUE..."
		sleep 2
		cd /var/spool/exim/input
		yes|rm -r * > /dev/null 2>&1
		sleep 3
		printf "\n"
		#reiniciamos exim y dovecot
		echo "hecho, ahora reiniciaremos los servicios de exim y dovecot"
		printf "\n"
		service exim restart
		service dovecot
		printf "\n"
		#
		echo "¡Listo! se purgó la QUEUE de emails de este servidor."
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "${GREEN}La nueva cola de correos es:${STD} $(exim -bpc)"
		printf "\n"
        pause
}

nueve(){
		printf "\n"
		echo -e "${GREEN}¡Genial! Instalaremos el CSF - Firewall en este servidor${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Ok, realizando la instalación.."
		sleep 2
		printf "\n"
		printf "\n"
		cd / ; wget https://download.configserver.com/csf.tgz ; tar -xzf csf.tgz ; cd csf ; sh install.sh

		sed -i 's#^TESTING = "1"#TESTING = "0"#g' /etc/csf/csf.conf ; csf -r ; service lfd restart
		sleep 3
		printf "\n"
		echo -e "${GREEN}¡Listo!${STD} completada la instalación, veamos el ${GREEN}RESULTADO:${STD}"
		printf "\n"
		#Next, test whether you have the required iptables modules:
		perl /usr/local/csf/bin/csftest.pl | grep RESULT


        pause
}

diez(){
		printf "\n"
		read -r -p "¿Deseas analizar y reparar todas las bases de datos del servidor? [SI/NO] " input
		printf "\n"
		printf "\n"
		case $input in
		     s|si|S|SI)

				 echo "¡Genial! vamos a analizar / reparar todas las bases de datos de este equipo.."
				 sleep 2
				 printf "\n"
				 printf "\n"

		 		#Obtenemos la contraseña del mysql del directadmin y lo guardamos en $passdaadmin
				 if [[ $PANELS == "1" ]] ; then
					passdaadmin=$(cat /usr/local/directadmin/conf/mysql.conf | grep -v user | cut -d= -f2)

					mysqlcheck -u da_admin -p$passdaadmin --auto-repair --check --all-databases

					printf "\n"
					echo -e "${GREEN}¡Listo!${STD} se optimizaron / repararon las ${GREEN}bases de datos${STD} del servidor"
					printf "\n"
					printf "\n"
					pause 2

					read -r -p "¿Deseas optimizar el my.cnf de este servidor DirectAdmin? [s/n] " inputmycnf

					  case $inputmycnf in
					        s|si|S|SI)
							printf "\n"
							echo -e "Bien, aplicamos ${GREEN}my-huge.cnf${STD} en este servidor.."
							printf "\n"

							#descargando paquetes de spamassasins
							service mysqld stop ; mv /etc/my.cnf /etc/my.cnf.last_bkp ; cp -f /usr/share/mysql/my-huge.cnf /etc/my.cnf ; service mysqld start ; service mysqld status
							printf "\n"
							echo -e "${GREEN}¡Genial!${STD} MySQL está mejorado"
							printf "\n"
							printf "\n"
					      ;;
					       n|no|N|NO)
					      echo -e "Okey, NO aplicaremos ${GREEN}my-huge.cnf${STD} en este servidor"
					      ;;
					      *)
					    echo "Mmmm.. tómate un café, elegiste una opción incorrecta"
					      ;;
					  esac

			    else

					if [[ $PANELS == "2" ]] ; then
			
						mysqlcheck --auto-repair --check  --compress --extended --verbose --all-databases

						printf "\n"
						echo -e "${GREEN}¡Listo!${STD} se optimizaron / repararon las ${GREEN}bases de datos${STD} del servidor"
						printf "\n"

					fi
				fi	
		 		;;

		     n|no|N|NO)
		printf "\n"
		printf "\n"

		echo "OK, no se realizará ningún optimización de las bases de datos" ;

		        ;;
		     *)
		printf "\n"
		printf "\n"
		 echo "Mmmm.. tómate un café, elegiste una opción incorrecta"
		 ;;
		 esac
		#done

		sleep 2
		printf "\n"
		read -r -p "¿Deseas analizar el my.cnf con MySQLTuner? [SI/NO] " inputmycnfopt
		printf "\n"
		printf "\n"
		case $inputmycnfopt in
		     s|si|S|SI)
				
				printf "\n"
				echo -e "${GREEN}¡Genial! analizaremos el /etc/my.cnf/ de este servidor${STD}"
				printf "\n"
				printf "\n"
				sleep 2
				echo -e "Ok, comencemos el análisis..."
				sleep 2
				printf "\n"
				printf "\n"
				cd /

				#Verificamos si existe el archivo "mysqltuner.pl"
				#Ejemplo NEGATIVO: test ! -f /etc/resolv.conf && echo "El archivo /etc/resolv.conf NO existe." || echo "El archivo /etc/resolv.conf SI existe."
				#Ejemplor POSITIVO: test -f /usr/bin/imapsync  && echo "El archivo imapsync SI existe" || echo "l archivo imapsync NO existe"

				if test -f /MySQLTuner-perl-master/mysqltuner.pl ; then
					cd MySQLTuner-perl-master
					./mysqltuner.pl
					sleep 4
					else
					cd /
					wget https://github.com/major/MySQLTuner-perl/archive/master.zip
					unzip master.zip
					cd MySQLTuner-perl-master
					./mysqltuner.pl
					sleep 4
				fi
				printf "\n"
				echo -e "${GREEN}¡Listo!${STD} revisa en el diagnóstico de lo que se pueda ${GREEN}Optimizar${STD}"
				printf "\n"
				sleep 2
			;;
		     n|no|N|NO)

				printf "\n"
				echo "OK, no se realizará ningún analisis del my.cnf"
				printf "\n"

		     ;;
		     *)
			 printf "\n"
			 echo "Mmmm.. tómate un café, elegiste una opción incorrecta"
			 printf "\n"
		 ;;
		 esac

        pause
}

once(){
		    printf "\n"
		    echo -e "Primero validaremos si ${GREEN}IMAPSync${STD} está instalado en este servidor"
		    printf "\n"
		     #testear si imapsync está instalado en el equipo, sino instalarlo...
			if test -f /usr/bin/imapsync ; 
				then
				printf "\n"
				echo "IMAPSync no está instalado, procederé a instalarlo..."
				sleep 2
				printf "\n"
				yum install --enablerepo=extras epel-release ; yum install imapsync -y ; clear
				clear
				else
				statusimapsync=INSTALADO
				clear
			fi

		    printf "\n"
		    printf "\n"
		    echo -e "${GREEN}¡Bien! Indicame el DOMINIO que vamos a realizarle IMAPSync..${STD}"
		    printf "\n"
		    read -p "DOMINIO: " dominioorigen1;
		    printf "\n"

		    #obtenemos el MX del dominio indicado
		    mxdominioorigen1=$(nslookup -query=mx  $dominioorigen1 | awk '{print $6, $5 }' | head -9 | sort -n)
		    #obtenemos el registro IMAP del dominio del dominio indicado
		    ipdeimapdominioorigen1=$(nslookup -query=a imap.$dominioorigen1 | tail -2 | cut -d: -f2)
		    ipdemaildominioorigen1=$(nslookup -query=a mail.$dominioorigen1 | tail -2 | cut -d: -f2)
		    IPS=$(ip addr show scope global | awk '$1 ~ /^inet/ {print $2}' | cut -f1 -d "/" -s | sort)
		    sleep 2
		    
			printf "\n"
		    echo -e "El dominio ${GREEN}$dominioorigen1${STD} posee los siguientes registros IMAP y MAIL en sus DNS:"
		    echo -e "${GREEN}IP de IMAP.$dominioorigen1:${STD}$ipdeimapdominioorigen1"
		    echo -e "${GREEN}IP de MAIL.$dominioorigen1:${STD}$ipdemaildominioorigen1"
		    echo -e "${GREEN}IP de DE ESTE SERVIDOR:${STD}"
		    echo "$IPS"
		    echo -e "IMAPSync: ${GREEN}$statusimapsync${STD}"

		    printf "\n"
		    printf "\n"
		    echo -e "INGRESA ${GREEN}ALGUNA IP${STD} desde la cual OBTENDREMOS todos los emails.."
		    printf "\n"
		    read -p "A) IP ORIGEN (desde donde se absorberan los emails): " ipmanualdeldominioorigen1;
		    printf "\n"
		    printf "\n"
		    echo -e "INGRESA ${GREEN}ALGUNA IP${STD} a donde ENVIAREMOS todos los emails.."
		    printf "\n"
		    read -p "B) IP DESTINO (a donde se migraran los emails): " ipmanualdeldominiodestino1;

		  

		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}1 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 1 de 10: " EMAIL1;
		    read -p "Contraseña: " PASS1;
		    printf "\n"

		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}2 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 2 de 10: " EMAIL2;
		    read -p "Contraseña: " PASS2;
		    printf "\n"

		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}3 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 3 de 10: " EMAIL3;
		    read -p "Contraseña: " PASS3;
		    printf "\n"
		    
		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}4 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 4 de 10: " EMAIL4;
		    read -p "Contraseña: " PASS4;
		    printf "\n"
		    
		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}5 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 5 de 10: " EMAIL5;
		    read -p "Contraseña: " PASS5;
		    printf "\n"
		    
		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}6 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 6 de 10: " EMAIL6;
		    read -p "Contraseña: " PASS6;
		    printf "\n"
		    
		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}7 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 7 de 10: " EMAIL7;
		    read -p "Contraseña: " PASS7;
		    printf "\n"
		    
		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}8 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 8 de 10: " EMAIL8;
		    read -p "Contraseña: " PASS8;
		    printf "\n"
		    
		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}9 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 9 de 10: " EMAIL9;
		    read -p "Contraseña: " PASS9;
		    printf "\n"
		    
		    printf "\n"
			echo -e "Indicame la cuenta de email ${GREEN}10 de 10${STD} a migrar.."
			printf "\n"
		    read -p "E-mail 10 de 10: " EMAIL10;
		    read -p "Contraseña: " PASS10;
		    printf "\n"

		    printf "\n"
		    echo -e "${GREEN}¡OK! comencemos a realizarle IMAPSync de las 10 cuentas indicadas..${STD}"
		    printf "\n"

		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL1 --password1 $PASS1 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL1 --password2 $PASS1;
		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL2 --password1 $PASS2 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL2 --password2 $PASS2;
		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL3 --password1 $PASS3 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL3 --password2 $PASS3;
		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL4 --password1 $PASS4 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL4 --password2 $PASS4;
		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL5 --password1 $PASS5 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL5 --password2 $PASS5;
		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL6 --password1 $PASS6 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL6 --password2 $PASS6;
		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL7 --password1 $PASS7 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL7 --password2 $PASS7;
		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL8 --password1 $PASS8 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL8 --password2 $PASS8;
		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL9 --password1 $PASS9 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL9 --password2 $PASS9;
		imapsync --nosslcheck --host1  $ipmanualdeldominioorigen1 --user1 $EMAIL10 --password1 $PASS10 --host2 $ipmanualdeldominiodestino1 --user2 $EMAIL10 --password2 $PASS10;

		    printf "\n"
		    echo -e "${GREEN}¡LISTO!${STD} validemos el log de todo el proceso realizado."
		    printf "\n"


		pause
}
doce(){	

		printf "\n"
		echo -e "${GREEN}¡Genial! habilitemos los links/~temporales en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Aplicando la configuración de ModUserDIR..."
		sleep 2
		printf "\n"
		printf "\n"
		cd /usr/local/directadmin/custombuild
		./build set userdir_access yes
		./build rewrite_confs
		sleep 3
		printf "\n"
		echo -e "${GREEN}¡Listo! ya podrás utilizar IP.DE.TU.SERVER/~USUARIO${STD}"
		printf "\n"

		pause
}
trece(){

		printf "\n"
		echo -e "${GREEN}¡Genial! Renovaremos la Licencia de DirectAdmin en este servidor${STD}"
		printf "\n"
		printf "\n"

		if [[ $PANELS == "1" &&  $SO == *"5"* ]] ; then
			cd /usr/local/directadmin/scripts/ ; echo 1 > /root/.insecure_download
		fi
		sleep 2

		printf "\n"
	    echo -e "$INDICAME EL ${GREEN}ID de CLIENTE${STD} DE DIRECTADMIN"
	    printf "\n"
	    read -p "ID Cliente: " idclienteda;
	    printf "\n"

	    printf "\n"
	    printf "\n"
	    echo -e "INDICAME EL ${GREEN}ID de LICENCIA ${STD} DEL SERVIDOR"
	    printf "\n"
	    read -p "ID Licencia: " idlicenciada;
	    printf "\n"
	    printf "\n"

    	printf "\n"
	    echo -e "${GREEN}¡OK! comencemos la renovación..${STD}"
	    printf "\n"

	    ./getLicense.sh $idclienteda $idlicenciada ; service directadmin restart;

	   	printf "\n"
	    printf "\n"
	    echo -e "${GREEN}¡LISTO!${STD} valida si puedes accesar al Panel."
	    printf "\n"


		pause
}
catorce(){
			printf "\n"
		    printf "\n"
		    echo -e "${GREEN}¡Bien! Indicame la IP del SERVIDOR ORIGEN del cual vamos a realizarle WGET..${STD}"
		    printf "\n"
		    read -p "SERVIDOR (IP ORIGEN): " hostorigen1;
		    printf "\n"

		    printf "\n"
		    printf "\n"
		    echo -e "INGRESA ${GREEN}USUARIO FTP${STD} para conectarnos y OBTENER todos los archivos.."
		    printf "\n"
		    read -p "A) USUARIO FTP (para autenticarse en el servidor origen): " usermanualdeldominioorigen1;
		    printf "\n"
		    printf "\n"
		    echo -e "INGRESA ${GREEN}CONTRASEÑA FTP${STD} para autenticarse en el servidor.."
		    printf "\n"
		    read -p "B) CONTRASEÑA FTP (para autenticarse en el servidor origen): " passmanualdeldominiodestino1;
		    printf "\n"
		    printf "\n"
		    sleep 2
		    printf "\n"
		    echo -e "${GREEN}¡OK! comencemos a realizarle WGET con los datos indicados..${STD}"
		    printf "\n"

			wget -m --ftp-user="$usermanualdeldominioorigen1" --ftp-password="$passmanualdeldominiodestino1" ftp://$hostorigen1

		    printf "\n"
		    echo -e "${GREEN}¡LISTO!${STD} validá el log de todo el proceso realizado."
		    printf "\n"


		pause

}
quince(){
		printf "\n"
		echo -e "${GREEN}¡Bien! habilitemos MALDET y CLAMAV en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Se estará instalando ${GREEN}Linux Malware Detect${STD} a continuación.."
		sleep 3
		printf "\n"
		#descargar e instalar MALDET
		cd / ; wget http://www.rfxn.com/downloads/maldetect-current.tar.gz ; tar -xvf maldetect-current.tar.gz ; cd maldetect-* ; ./install.sh
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "¡Genial! se intaló ${GREEN}Linux Malware Detect${STD} satisfactoriamente, continuemos con ${GREEN}ClamAV Antivirus${STD}.."
		sleep 3
		#descargar e unstalar CLAMAV
		apt install yum
		yum update && yum install clamav ; maldet -u
		yum install epel-release ; yum update && yum install clamav ; maldet -u
		
		#descargar e unstalar CLAMAV en Debian
		sudo apt-get update && sudo apt-get upgrade -y ; sudo apt-get install clamav clamav-daemon -y; sudo freshclam

		printf "\n"
		printf "\n"
		sleep 4
		echo -e "¡Genial! se intaló ${GREEN}ClamAV Antivirus${STD} satisfactoriamente"
		sleep 3
		#Escanear todos los home y public_html de los usuarios
		maldet -a /home/?/public_html
		sleep 3
		printf "\n"
		echo -e "¡Listo! ya dispones de mayor${GREEN} Seguridad y Análisis ${STD}en tu Servidor"
		printf "\n"

		pause
}
dieciseis(){
		printf "\n"
		echo -e "${GREEN}¡Genial! habilitemos los links/~temporales en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Aplicando la configuración de ModUserDIR..."
		sleep 2
		printf "\n"
		printf "\n"
		cd /usr/local/directadmin/custombuild
		./build set userdir_access yes
		./build rewrite_confs
		sleep 3
		printf "\n"
		echo -e "${GREEN}¡Listo! ya podrás utilizar IP.DE.TU.SERVER/~USUARIO${STD}"
		printf "\n"

		pause
}
diecisiete(){
		printf "\n"
		echo -e "${GREEN}¡OK! arreglemos este error en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Aplicando comandos necesarios..."
		sleep 2
		printf "\n"
		printf "\n"
		service exim stop ; mv /var/spool/exim/db /var/spool/exim/db.bak ; service exim restart
		sleep 3
		printf "\n"
		echo -e "${GREEN}¡Listo! ya podrás utilizar EXIM de forma normal${STD}"
		printf "\n"

		pause
}
dieciocho(){
		printf "\n"
		echo -e "${GREEN}¡Genial! habilitemos los links/~temporales en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Aplicando la configuración de ModUserDIR..."
		sleep 2
		printf "\n"
		printf "\n"
		cd /usr/local/directadmin/custombuild
		./build set userdir_access yes
		./build rewrite_confs
		sleep 3
		printf "\n"
		echo -e "${GREEN}¡Listo! ya podrás utilizar IP.DE.TU.SERVER/~USUARIO${STD}"
		printf "\n"

		pause
}
diecinueve(){
		printf "\n"
		echo -e "${GREEN}¡Genial! habilitemos los links/~temporales en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Aplicando la configuración de ModUserDIR..."
		sleep 2
		printf "\n"
		printf "\n"
		cd /usr/local/directadmin/custombuild
		./build set userdir_access yes
		./build rewrite_confs
		sleep 3
		printf "\n"
		echo -e "${GREEN}¡Listo! ya podrás utilizar IP.DE.TU.SERVER/~USUARIO${STD}"
		printf "\n"

		pause
}
veinte(){
		printf "\n"
		echo -e "${GREEN}¡Genial! estabilzaremos completamente este servidor${STD}"
			#validamos todos los servicios del servidor

		#cpanel
		service mysql stop ; service httpd stop ; service exim stop ; cd /scripts/ ; ./restartsrv_apache_php_fpm

		#directadmin
		service mysqld stop ; service httpd stop ; service exim stop 

		pause
}
veintiuno(){
		printf "\n"
		echo -e "${GREEN}¡Genial! habilitemos los links/~temporales en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Aplicando la configuración de ModUserDIR..."
		sleep 2
		printf "\n"
		printf "\n"
		cd /usr/local/directadmin/custombuild
		./build set userdir_access yes
		./build rewrite_confs
		sleep 3
		printf "\n"
		echo -e "${GREEN}¡Listo! ya podrás utilizar IP.DE.TU.SERVER/~USUARIO${STD}"
		printf "\n"

		pause
}
veintidos(){

				echo -e "\e[1;40m" ; clear ; while :; do echo $LINES $COLUMNS $(( $RANDOM % $COLUMNS)) $(( $RANDOM % 72 )) ;sleep 0.05; done|awk '{ letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"; c=$4; letter=substr(letters,c,1);a[$3]=0;for (x in a) {o=a[x];a[x]=a[x]+1; printf "\033[%s;%sH\033[2;32m%s",o,x,letter; printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;if (a[x] >= $1) { a[x]=0; } }}'
}
PROXIMO(){
		printf "\n"
		echo -e "${GREEN}¡Genial! habilitemos los links/~temporales en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Aplicando la configuración de ModUserDIR..."
		sleep 2
		printf "\n"
		printf "\n"
		cd /usr/local/directadmin/custombuild
		./build set userdir_access yes
		./build rewrite_confs
		sleep 3
		printf "\n"
		echo -e "${GREEN}¡Listo! ya podrás utilizar IP.DE.TU.SERVER/~USUARIO${STD}"
		printf "\n"

		pause
}

# function to display menus
mostrar_menu() {
	clear
	printf "\n"
	echo -e "${GREEN}==============================================================================================${STD}"
    echo -e " ${GREEN}   MENU PRINCIPAL  .:SERVER.OK:. by DANIEL BUSTAMANTE for Linux with DirectAdmin & CPanel ${STD} "
	echo -e "${GREEN}==============================================================================================${STD}"
	echo "0) Salir de la aplicacion"
	echo "1) Informacion y Resumen del servidor"
	echo "2) Ping a las IP del servidor || Validar RBL"
	echo "3) Hacer espacio en disco del servidor"
	echo "4) Detener spammers || limpiar QUEUE de emails || Habilitar SpamAsassins"
	echo "5) Instalar let's encryt"
	echo "6) Setear FECHA/HORA  || Habilitar NTPD "
	echo "7) NGINX como proxy reverso (DirectAdmin)"
	echo "8) Purgar QUEUE entera de Emails"
	echo "9) Instalar CSF Firewall"
	echo "10) Reparar todas la Bases de Datos || Optimizar my.cnf || Analizar my.cnf del SQL"
	echo "11) IMAPSync de a 10 cuentas"
	echo "12) Permitir links temporales mediante /~ (DirectAdmin)"
	echo "13) Actulizar Licencia DirectAdmin"
	echo "14) WGET con autenticación FTP"
	echo "15) Instalar MALDET y CLAMAV || Ejecutar Antivirus"
	echo "16) NADA POR AHORA."
	echo "17) FIX - Berkeley DB error: /var/spool/exim/db/callout en EXIM"
	echo "18) NADA POR AHORA."
	echo "19) NADA POR AHORA."
	echo "20) ESTABILIZAR Servidor Completo."
	echo "21) OPTIMIZAR Servidor Completo."
	echo "22) ACTUALIZAR Servidor Completo."
	printf "\n"
	echo -e "${GREEN}----------------------------------------------------------------------------------------------${STD}"
	printf "\n"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
leer_opcion(){
	local choice
	read -p "SELECCIONA un NUMERO para tu OPCION [ 1 - 20 ]  y luego presiona ENTER: " choice
	printf "\n"
	case $choice in
		0) clear ; exit 0 ;;
		1) uno ;;
		2) dos ;;
		3) tres ;;
		4) cuatro;;
		5) cinco;;
		6) seis;;
		7) siete;;
		8) ocho;;
		9) nueve;;
		10) diez;;
		11) once;;
		12) doce;;
		13) trece;;
		14) catorce;;
		15) quince;;
		16) dieciseis;;
		17) diecisiete;;
		18) dieciocho;;
		19) diecinueve;;
		20) veinte;;
		21) veintiuno;;
		22) veintidos;;
		*) echo -e "${RED}¡UPS! Presionaste una tecla erronea, [ESPERA] y vuelve a elegir...${STD}" && sleep 1
	esac
}
 
# ----------------------------------------------
# Step #3: Trap CTRL+C, CTRL+Z and quit singles
# ----------------------------------------------
trap '' SIGINT SIGQUIT SIGTSTP
 

# -----------------------------------
# Step #4: Main logic - infinite loop
# ------------------------------------
while true
do
 
	mostrar_menu
	leer_opcion
done
