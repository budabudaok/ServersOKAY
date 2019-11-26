#!/usr/bin/env bash
#sok.sh - .:SERVER OK:. For Linux with DirectAdmin & CPanel by .:DANIEL BUSTAMANTE:.

#VARIABLES
#identificamos el sistema operativo
    if cat /etc/redhat-release > /dev/null 2>&1
    then 
	    RedHat=$(cat /etc/redhat-release)
	    SO=$RedHat
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

#informamos la version de exim
	VersionEXIM=$(exim -bV | awk {'print $3 ; exit'})

#informamos los puertos smtp
  	PuertosSMTP=$(cat /etc/exim.conf | grep daemon_smtp_ports |cut -d= -f2 | head -1)

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
		topemisores=$(exim -bpc)
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
	echo -e "${GREEN}Hostname:${STD} $HOSTNAME 
${GREEN}Reverso de Hostname:${STD} $RDNS 
${GREEN}PTR de IP:${STD} $PTR
${GREEN}Sistema Operativo:${STD} $SO 
${GREEN}Panel de Control:${STD} $PANEL ${GREEN}Version de Panel:${STD} $PANELversion
${GREEN}Let's Encryt:${STD} $letsencrytstatus ${GREEN}ModUserDIR /~:${STD} $ModUserDirstatus
${GREEN}Carga actual:${STD} $Carga ${GREEN}Carga hace 15 minutos:${STD} $Carga15
${GREEN}Fecha:${STD} $Fecha ${GREEN}Hora:${STD} $Hora
${GREEN}Apache:${STD} $VersionAPACHE
${GREEN}MySQL:${STD} $VersionMYSQL
${GREEN}CSF:${STD} $(csf -V | cut -d: -f2)
${GREEN}Exim:${STD} $VersionEXIM ${GREEN}Puertos SMTP:${STD} $PuertosSMTP ${GREEN}Correos en cola:${STD} $(exim -bpc)
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
		     [sS][iI][si]|[SI])

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

		     [nN][no]|[NO])
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
		  read -r -p "¿Deseas suspender sus envios si los considera abusivos? [SI/NO] " input

		  case $input in
		      [sS][si][SI]|[iI])
		      
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
		      [nN][oO]|[nN])
		      echo "No"
		            ;;
		      *)
		    echo "Invalid input..."
		    ;;
		  esac
		#done


		else

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
		      [sS][si][SI]|[iI])
		      
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
		      [nN][oO]|[nN])
		      echo "No"
		            ;;
		      *)
		    echo "Invalid input..."
		    ;;
		  esac
		#done

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

	        pause
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

		}

seis(){

		printf "\n"
		echo -e "${GREEN}Vamos a setear la zona horaria a UTC-3 para este servidor:${STD}"
		printf "\n"
		printf "\n"
		#guardamos la hora actual
		horaanterior=$(date)
		sleep 2
		echo -e "Estoy aplicando la configuración para el Sistema Operativo..."
		#actualizamos el timezone manualente
		cp /etc/localtime /root/old.timezone
		rm /etc/localtime
		ln -s /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
		#instalamos el Network Time Protocol
		sleep 2
		printf "\n"
		printf "\n"
		echo -e "Listo, ahora instalaremos NTP (Network Time Protocol).."
		sleep 2
		printf "\n"
		printf "\n"
		yum install ntp ntpdate ntp-doc -y
		#reemplazar pool por servidores de argentina
		#sed -i 's/190.105.235.102/190.183.63.113/g' /etc/ntp.conf
		/etc/init.d/ntpd start > /dev/null
		service ntpd start > /dev/null
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Bien, luego actualiza el TimeZone en PHP de ser necesario.."
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
		sleep 2
	
	
        pause
}

siete(){

		printf "\n"
		echo -e "${GREEN}¡Genial! habilitemos NGINX + Apache como WebServer en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Aplicando la configuración necesaria..."
		sleep 2
		printf "\n"
		printf "\n"
		cd /usr/local/directadmin/custombuild
		./build update
		./build set webserver nginx_apache
		./build nginx_apache
		./build php n
		./build rewrite_confs
		sleep 2
		printf "\n"
		echo -e "${GREEN}¡Listo! ya verás más eficiente a tu WebServer${STD}"
		printf "\n"

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
		cd /
		#wget http://www.configserver.com/free/csf.tgz
		wget https://download.configserver.com/csf.tgz
		tar -xzf csf.tgz
		cd csf
		sh install.sh
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
		echo -e "${GREEN}¡Genial! analizaremos el /etc/my.cnf/ de este servidor${STD}"
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Ok, comencemos el análisis..."
		sleep 2
		printf "\n"
		printf "\n"
		cd /
		wget https://github.com/major/MySQLTuner-perl/archive/master.zip
		unzip master.zip
		cd MySQLTuner-perl-master
		./mysqltuner.pl
		sleep 4
		printf "\n"
		echo -e "${GREEN}¡Listo!${STD} revisa en el diagnóstico de lo que se pueda ${GREEN}Optimizar${STD}"
		printf "\n"

        pause
}

once(){

		#validamos todos los servicios del servidor
		chkconfig --list | awk '{ print $1 }' | cut -f1 | grep -v : | sort > serviciosdelservidor.txt

		cat serviciosdelservidor.txt |  while read output
		do
		   if ps ax | grep -v grep | grep "$output" > /dev/null

		   then
		  echo "¡Genial! el servicio $output está operando de forma normal"

		  else
		  echo "¡Ups! el servicio $output parece no responder, validarlo de ser necesario.."
		  
		fi

		done

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
		echo -e "${GREEN}¡Genial! estabilzaremos la carga de este servidor${STD}"
			#validamos todos los servicios del servidor
		chkconfig --list | awk '{ print $1 }' | cut -f1 | grep -v : | sort > serviciosdelservidor.txt

		cat serviciosdelservidor.txt |  while read output
		do
		   if ps ax | grep -v grep | grep "$output" > /dev/null

		   then
		   	service $output restart
		  echo "¡Genial! el servicio $output está operando de forma normal"

		  else
		  	service $output restart
		  echo "¡Ups! el servicio $output parece no responder, validarlo de ser necesario.."
		  
		fi

		done

		pause
}
catorce(){

		printf "\n"
		echo -e "${GREEN}¡Bien! Investiguemos para hacer IMAPSync del DOMINIO que me indiques a continuación..${STD}"
		printf "\n"
		read -p "DOMINIO: " dominioorigen1;
		printf "\n"
		#obtenemos el MX del dominio indicado
		mxdominioorigen1=$(nslookup -query=mx  $dominioorigen1 | awk '{print $6, $5 }' | head -9 | sort -n)
		#obtenemos el registro IMAP del dominio del dominio indicado
		ipdeimapdominioorigen1=$(nslookup -query=a imap.$dominioorigen1 | tail -2 | cut -d: -f2)
		ipdemaildominioorigen1=$(nslookup -query=a mail.$dominioorigen1 | tail -2 | cut -d: -f2)
		sleep 2
		echo -e "El dominio ${GREEN}$dominioorigen1${STD} posee"
		echo -e	"1) ${GREEN}IP de IMAP.$dominioorigen1:${STD}$ipdeimapdominioorigen1"
		echo -e	"2) ${GREEN}IP de MAIL.$dominioorigen1:${STD}$ipdemaildominioorigen1"
   read -p "3) IP MANUAL: " ipmanualdeldominioorigen1;
		printf "\n"
		sleep 2
		cuentachuser=$(/usr/local/bin/c4cd $dominioorigen1 | grep nfsweb | cut -d/ -f3)
		echo -e "La cuenta en CloudPanel es ${GREEN}$cuentachuser${STD} y posee las siguientes emails:"
		
		printf "\n"
        read -p "IMAP Host: " HOST1;
        read -p "E-mail: " EMAIL1;
        read -p "Password: " PASS1;

		#read -p "DOMINIO: " dominioorigen1;
		printf "\n"
		echo -e "Estoy aplicando la configuración para el Sistema Operativo..."
		#actualizamos el timezone manualente
		#if [[ $mxdominioorigen1 == "2" &&  $SO == *".elserver.com"* ]] ; then
		#guardamos la hora actual

		
		sleep 2
		echo -e "Estoy aplicando la configuración para el Sistema Operativo..."
		#actualizamos el timezone manualente
		
		
		
		#instalamos el Network Time Protocol
		sleep 2
		printf "\n"
		printf "\n"
		echo -e "Listo, ahora instalaremos NTP (Network Time Protocol).."
		sleep 2
		printf "\n"
		printf "\n"
	
		printf "\n"
		printf "\n"
		sleep 2
		echo -e "Bien, luego actualiza el TimeZone en PHP de ser necesario.."
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
		sleep 2
	

		pause

}
quince(){
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
		printf "\n"
		echo -e "${GREEN}¡Genial! habilitemos los links/~temporales en este servidor:${STD}"
		printf "\n"
		printf "\n"
		sleep 2
				echo -e "\e[1;40m" ; clear ; while :; do echo $LINES $COLUMNS $(( $RANDOM % $COLUMNS)) $(( $RANDOM % 72 )) ;sleep 0.05; done|awk '{ letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"; c=$4; letter=substr(letters,c,1);a[$3]=0;for (x in a) {o=a[x];a[x]=a[x]+1; printf "\033[%s;%sH\033[2;32m%s",o,x,letter; printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;if (a[x] >= $1) { a[x]=0; } }}'
		pause
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
show_menus() {
	clear

	echo -e "${GREEN}==============================================================================================${STD}"
    echo -e " ${GREEN}|| MENU PRINCIPAL || .:SERVER.OK:. by DANIEL BUSTAMANTE for Linux with DirectAdmin & CPanel ${STD} "
	echo -e "${GREEN}==============================================================================================${STD}"
	echo "0) Salir de la aplicacion"
	echo "1) Informacion del servidor"
	echo "2) Ping a las IP del servidor y Validar RBL"
	echo "3) Hacer espacio en disco del servidor"
	echo "4) Detener spammers y limpiar QUEUE de emails"
	echo "5) Habilitar let's encryt"
	echo "6) Setear FECHA/HORA a Argentina UTC -3"
	echo "7) NGINX como proxy reverso (DirectAdmin)"
	echo "8) Purgar QUEUE entera de Emails"
	echo "9) Instalar CSF / WAF / Firewall"
	echo "10) Analizar MY.CNF del SQL"
	echo "11) Ver Status de todos los servicios"
	echo "12) Permitir links temporales mediante /~ (DirectAdmin)"
	echo "13) Estabilizar Servidor Completo"
	echo "14) IMAPSync de Google a CloudPanel"
	echo "15) IMAPSync del dominio completo a Cpanel"
	echo "16) IMAPSync del dominio completo a DirectAdmin"
	echo "17) IMAPSync del dominio completo a Plesk"
	echo "18) IMAPSync de una cuenta individual"
	echo "19) NADA POR AHORA."
	echo "20) NADA POR AHORA."
	echo "21) NADA POR AHORA."
	echo "22) Matrix."
	printf "\n"
	echo -e "${GREEN}----------------------------------------------------------------------------------------------${STD}"
	printf "\n"
	printf "\n"
}
# read input from the keyboard and take a action
# invoke the one() when the user select 1 from the menu option.
# invoke the two() when the user select 2 from the menu option.
# Exit when user the user select 3 form the menu option.
read_options(){
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
		*) echo -e "${RED}¡UPS! Presionaste una tecla erronea, [ESPERA] y vuelve a elegir...${STD}" && sleep 2
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
 
	show_menus
	read_options
done
