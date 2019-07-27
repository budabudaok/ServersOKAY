#!/usr/bin/env bash
#serverok.sh para DirectAdmin y CPanel por Daniel Bustamante

#identificamos el sistema operativo
if cat /etc/redhat-release > /dev/null 2>&1
then 
RedHat=$(cat /etc/redhat-release)
SO=$RedHat
else 
     Debian=$(lsb_release -a)
     SO=$Debian
fi

IPS=$(ip addr show scope global | awk '$1 ~ /^inet/ {print $2}')


#identificamos si tiene let's encryt
if cat /usr/local/directadmin/custombuild/versions.txt > /dev/null 2>&1
then
DALT=$(/usr/local/directadmin/directadmin c | grep letsencrypt=)
LTV=letsencrypt=1
if [ "$LTV" = "$DALT" ]
then 
LT=$"con Let's Encrypt" 
else
LT=$"sin Let's Encrypt"
fi
else 



echo "tiene WHM"

fi

#getent hosts unix.stackexchange.com | awk '{ print $1 }'
#
# dig +short $HOSTNAME
#
#host 190.105.237.44 | awk '{ print $5 ; exit}'
#
#


#COMENTARIO identificamos si tiene let's encryt y centos5 o menor Sistema Operativo
#if ["$SO"="CentOS release 5"*];
#then
#  if ["$LTV" = "$DALT"]; 
#   then
#   print "NO puede andar LETSRITN"
#  else
#  print "si puede andar LETSRITN"
#  fi
#else
#
#print "si puede andar LETSRITN"
#fi


#identificamos el panel de control y su versión
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



#comenzamos informando sobre el servidor, la carga actual y sus dns
printf "\n"
echo "Vamos a estabilizar completamente a este servidor de nombre $HOSTNAME"
printf "\n"
DNS=$(cat /etc/resolv.conf)
sleep 8
echo "1. Posee $SO con panel $PANEL y $LT "
printf "\n"
echo "1.A Consulta a los siguientes DNS para su resolución externa:"
echo "$DNS"
sleep 4
printf "\n"
echo "1.B Posee las siguientes IP en su interfaz:"
echo "$IPS"
sleep 5
printf "\n"

echo "2. La carga es $(cat /proc/loadavg) a las $(date +'%H:%M:%S') del dia $(date +'%d-%m-%Y')"
printf "\n"
echo "3. Validemos todos los servicios de este servidor.."
printf "\n"
sleep 8


#PANEL: Verificamos el estado y lo reiniciamos si está detenido
if [ "$PANELS" -eq "1" ];
then
SERVICE='directadmin'
else
SERVICE='cpanel'
fi
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
echo "¡Genial! el servicio $SERVICE está operando de forma normal"
else
echo "¡Ups! el servicio $SERVICE esta detenido, voy a reiniciarlo.."
service $SERVICE restart;
sleep 8
service $SERVICE status;
fi

#NAMED: Verificamos el estado y lo reiniciamos si está detenido
SERVICE='named'
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
echo "¡Genial! el servicio $SERVICE está operando de forma normal"
else
echo "¡Ups! el servicio $SERVICE esta detenido, voy a reiniciarlo.."
service $SERVICE restart;
sleep 8
service $SERVICE status;
fi

#FTP: Verificamos el estado y lo reiniciamos si está detenido
SERVICE='ftp'
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
echo "¡Genial! el servicio $SERVICE está operando de forma normal"
else
echo "¡Ups! el servicio $SERVICE esta detenido, voy a reiniciarlo.."
service $SERVICE restart;
sleep 6
service $SERVICE status;
fi

#MYSQL: Verificamos el estado y lo reiniciamos si está detenido
SERVICE='mysql'
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
echo "¡Genial! el servicio $SERVICE está operando de forma normal"
else
echo "¡Ups! el servicio $SERVICE esta detenido, voy a reiniciarlo.."
service $SERVICE restart;
sleep 6
service $SERVICE status;
fi

#APACHE: Verificamos el estado y lo reiniciamos si está detenido
SERVICE='httpd'
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
echo "¡Genial! el servicio $SERVICE está operando de forma normal"
else
echo "¡Ups! el servicio $SERVICE está detenido, voy a reiniciarlo.."
service $SERVICE restart;
sleep 6
service $SERVICE status;
fi

#DOVECOT: Verificamos el estado y lo reiniciamos si está detenido
SERVICE='dovecot'
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
echo "¡Genial! el servicio $SERVICE está operando de forma normal"
else
echo "¡Ups! el servicio $SERVICE está detenido, voy a reiniciarlo.."
service $SERVICE restart;
sleep 6
service $SERVICE status;
fi

#SPAMASSASINS: Verificamos el estado y lo reiniciamos si está detenido
SERVICE='spamd'
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
echo "¡Genial! el servicio $SERVICE está operando de forma normal"
else
echo "¡Ups! el servicio $SERVICE está detenido, voy a reiniciarlo.."
service $SERVICE restart;
sleep 6
service $SERVICE status;
fi

#EXIM: Verificamos el estado, los puertos y lo reiniciamos si está detenido y limpiamos emails frizados y con más de 1 dia en espera de distribución.
SERVICE='exim'
COLA=$(exim -bpc)

if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
echo "¡Genial! el servicio $SERVICE esta operando de forma normal y se posee $COLA correos en la bandeja de salida.."
else
echo "¡Ups! el servicio $SERVICE esta detenido, voy a reiniciarlo.."
service $SERVICE restart;
sleep 6
service $SERVICE status;
fi

sleep 8
printf "\n"
echo "como se posee $COLA emails en la bandeja de salida voy a limpiar los que están frizados.."
sleep 6
FRIZADOS=$(exiqgrep -zi | wc -l)
if [ "$FRIZADOS" -ge "1" ]; then
printf "\n"
echo "Se encontraron $FRIZADOS emails frizados, voy a limpiarlos.."
printf "\n"
sleep 2
 exiqgrep -zi|xargs exim -Mrm
 COLASINFRIZADOS=$(exim -bpc)
 printf "\n"
 printf "\n"
 echo "¡Listo! ahora solo quedan $COLASINFRIZADOS emails en la bandeja de salida sin estar frizados"
 sleep 4
else
 printf "\n"
 echo "¡Genial! no se encontraron emails frizados"
 sleep 4
fi
printf "\n"
echo "de los $COLASINFRIZADOS emails restantes en la bandeja de salida voy a limpiar los que están detenidos hace más de 1 dia.."
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
 echo "¡Listo! ahora solo quedan $COLASINDETENIDOS emails en la bandeja de salida en estado normales para su distribución"
 sleep 4
else
 echo "¡Genial! no se encontraron emails detenidos por 1 día, ningún correo normal será afectado para su distribución actual."
fi

sleep 4

#DISCO: Verificamos el espacio en disco del servidor
printf "\n"
echo "4. Validemos el espacio en disco de este servidor.."
printf "\n"
sleep 3
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
  echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  particion=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge 90 ]; then
  echo "Sin espacio en la partición \"$particion ($usep%)\", se requiere hacer limpieza..)"
  else 
  echo "Disco OK, no se requiere hacer limpieza"
  fi
done
sleep 8



#CARGA: Verificamos la carga del equipo
sleep 4
printf "\n"
echo "La carga actualmente está en $(cat /proc/loadavg)"

exit 0;


#ACTUALIZACIONES: Verificamos los repositorios de yum update
if [ "$PANELS" -eq "1" ];
then
printf "\n"
echo "como se utiliza $PANEL verificaré las actualizaciones de los servicios de este servidor.."
cd /usr/local/directadmin/custombuild
./build update
./build versions
./build update_versions
else
yum update -y
/usr/local/cpanel/scripts/upcp
fi
printf "\n"
echo "¡Listo! se han instalado las ultimas actualizaciones para $PANEL sus Servicios.."
sleep 8


#DISCO: Booramos  tar.gz, .tar, .tar.bz2, .bz2, .tar.gzip, .tgz, .gz, .rar, .zip
printf "\n"
echo "El disco está OK pero se itentará optimizar mejor el espacio.."
  find / -name "*.tar.gz" -type f -exec rm -rf {} \;
  find / -name "*.tar" -type f -exec rm -rf {} \;
  find / -name "*.tar.bz2" -type f -exec rm -rf {} \;
  find / -name "*.bz2" -type f -exec rm -rf {} \;
  find / -name "*.tar.gzip" -type f -exec rm -rf {} \;
  find / -name "*.tgz" -type f -exec rm -rf {} \;
  find / -name "*.gz" -type f -exec rm -rf {} \;
  find / -name "*.rar" -type f -exec rm -rf {} \;
  find / -name "*.zip" -type f -exec rm -rf {} \;
 
 sleep 4


#DISCO: Verificamos el espacio en disco del servidor
printf "\n"
echo "4. Validemos el espacio en disco de este servidor.."
printf "\n"
sleep 3
df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
do
  echo $output
  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
  particion=$(echo $output | awk '{ print $2 }' )
  if [ $usep -ge 90 ]; then
  echo "Sin espacio en la partición \"$particion ($usep%)\", se requiere hacer limpieza..)"
  else 
  echo "Disco OK, no se requiere hacer limpieza"
  fi
done
sleep 8


#ACTUALIZACIONES de RPM: Verificamos los últimos repositorios de yum update
printf "\n"
echo "5. Validemos los RPM para futuras actualizaciones de este servidor.."
printf "\n"
sleep 3
yum clean all #limpiar y actualizar lista de repositorios
yum upgrade -y #actualizar repositorios
sleep 2
printf "\n"
echo "¡Listo! se han instalado las ultimas dependencias para los RPM"


#CARGA: Verificamos la carga del equipo
sleep 4
printf "\n"
echo "La carga actualmente está en $(cat /proc/loadavg)"


exit 0;




#Operadores de Bash
# >	Comes before alphabetically	if [[ $a > $b ]]
# <	Comes first alphabetically	if [[ cat < dog ]]
# =	Equal (strings)	if [[ $path = "/usr/bin/" ]]
# -lt	less than (integers)	if [[ 1 -lt 10 ]]
# -gt	greater than (integers)	if [[ $number -gt 0 ]]
# -eq	Equal (integers)	if [[ $status -eq 0 ]]
# -ne	Not equal (integers)	if [[ $year -ne 2018 ]]
# -e 	File exists	if [[ -e "$bam_index" ]]
# -d	File exists, and its a directory	if [[ -d "/tmp" ]]
# -f 	File exists, and its a regular file	if [[ -f ~/.bashrc ]]
# -s	File exists and its not empty	if [[ -s "$output" ]]


Comparación de enteros (números)

    -eq
    es igual a

    if [ "$a" -eq "$b" ]

    -ne
    no es igual a / es distinto a

    if [ "$a" -ne "$b" ]

    -gt
    es mayor que

    if [ "$a" -gt "$b" ]

    -ge
    es mayor que o igual a

    if [ "$a" -ge "$b" ]

    -lt
    es menor que

    if [ "$a" -lt "$b" ]

    -le
    es menor que o igual a

    if [ "$a" -le "$b" ]

    <
    es menor que (dentro de doble paréntesis)

    (("$a" < "$b"))

    <=
    es menor que o igual a (dentro de doble paréntesis)

    (("$a" <= "$b"))

    >
    es mayor que (dentro de doble paréntesis)

    (("$a" > "$b"))

    >=
    es mayor que o igual a (dentro de doble paréntesis)

    (("$a" >= "$b"))

Comparación de cadenas

    =
    es igual a

    if [ "$a" = "$b" ]

    ==
    es igual a

    if [ "$a" == "$b" ]

    Nota: Aunque es un sinónimo de = el operador ==se comporta diferente cuando se usa dentro de corchetes dobles que simples, por ejemplo:

    [[ $a == z* ]]   # Verdadero si $a empieza con una "z" (expresión regular coincide).
    [[ $a == "z*" ]] # Verdadero si $a es igual a z* (coincide literalmente).

    [ $a == z* ]     # Ocurre división de palabras.
    [ "$a" == "z*" ] # Verdadero si $a es igual a z* (coincide literalmente).

    !=
    no es igual a / Distinto

    if [ "$a" != "$b" ]

    NOTA: este operador usa coincidencia de patrón dentro de doble corchete.
    <
    es menor que (en orden alfabético ASCII)

    if [[ "$a" < "$b" ]]
    if [ "$a" \< "$b" ]

    Nota: el operador "<" necesita ser escapado dentro de corchetes.
    >
    es mayor que (en orden alfabético ASCII)

    if [[ "$a" > "$b" ]]
    if [ "$a" \> "$b" ]

    Nota: el operador ">" necesita ser escapado dentro de corchetes.
    -z
    La cadena está vacía (nulll), tiene longitud cero.

    cadena=''   # Variable de longitud cero (null)
    if [ -z "$String" ]
    then
    echo "\$cadena está vacía."
    else
    echo "\$cadena no está vacía."
    fi

    -n
    cadena no está vacía (contiene algo) nota: El operador -n exige que la cadena esté entre comillas entre paréntesis. Aunque el uso son comillas puede funcionar es altamente recomendable usar comillas.

Comparaciones lógicas

    -a
    Y lógico (and)

    exp1 -a exp2

    devuelve verdadero si ambas exp1 y exp2 son verdaderas.
    -o
    O lógico (or)

    exp1 -o exp2

    devuelve verdadero si alguna de las expresiones exp1 y exp2 son verdaderas.

Éstos últimos operadores son similares a los operadores de Bash && (and) y || (or) cuando se usan con doble corchete:

[[ condition1 && condition2 ]]






#
	
cadena="murciélago"
echo $cadena | wc -l
#



En bash se puede escribir (tenga en cuenta los asteriscos son fuera de las comillas)

if [[ $t1 == *"$t2"* ]]; then 
      echo "$t1 and $t2 are equal" 
    fi 

Por/bin/sh, el operador = es sólo para la igualdad no por coincidencia de patrones. Puede utilizar case aunque

case "$t1" in 
    *"$t2"*) echo t1 contains t2 ;; 
    *) echo t1 does not contain t2 ;; 
esac 

Si se apuntan específicamente a Linux, asumiría la presencia de/bin/bash.





509

You can use getent, which comes with glibc (so you almost certainly have it on Linux). This resolves using gethostbyaddr/gethostbyname2, and so also will check /etc/hosts/NIS/etc:

getent hosts unix.stackexchange.com | awk '{ print $1 }'
Or, as Heinzi said below, you can use dig with the +short argument (queries DNS servers directly, does not look at /etc/hosts/NSS/etc) :

dig +short unix.stackexchange.com
If dig +short is unavailable, any one of the following should work. All of these query DNS directly and ignore other means of resolution:

host unix.stackexchange.com | awk '/has address/ { print $4 }'
nslookup unix.stackexchange.com | awk '/^Address: / { print $2 }'
dig unix.stackexchange.com | awk '/^;; ANSWER SECTION:$/ { getline ; print $5 }'
If you want to only print one IP, then add the exit command to awk's workflow.

dig +short unix.stackexchange.com | awk '{ print ; exit }'
getent hosts unix.stackexchange.com | awk '{ print $1 ; exit }'
host unix.stackexchange.com | awk '/has address/ { print $4 ; exit }'
nslookup unix.stackexchange.com | awk '/^Address: / { print $2 ; exit }'
dig unix.stackexchange.com | awk '/^;; ANSWER SECTION:$/ { getline ; print $5 ; exit }'






Linux
Using iproute2 and awk:

ip addr show scope global | awk '$1 ~ /^inet/ {print $2}'
ip -4 addr show scope global | awk '$1 == "inet" {print $2}'
ip -6 addr show scope global | awk '$1 == "inet6" {print $2}'
Using iproute2's recent JSON support:

ip -json addr show scope global | jq -r '.[] | .addr_info | .[] | .local'
ip -json -4 addr show scope global | jq -r '.[] | .addr_info | .[] | .local'
ip -json -6 addr show scope global | jq -r '.[] | .addr_info | .[] | .local'

ip -json addr | jq -r '.[] | .addr_info | .[] | select(.scope == "global") | .local'
ip -json addr | jq -r '.[] | .addr_info | .[] | select(.family == "inet" and .scope == "global") | .local'
ip -json addr | jq -r '.[] | .addr_info | .[] | select(.family == "inet6" and .scope == "global") | .local'
FreeBSD
Using FreeBSD ifconfig and awk (filtering by scope is a bit more difficult here):

ifconfig -a | awk '$1 ~ /^inet/ {print $2}'
ifconfig -a | awk '$1 == "inet" {print $2}'
Also note that ifconfig has many different output styles between different OSes – even Linux has at least three versions.




#buscar y reemplazar
#busca SYSADMIN y BORRA
find /test/ -name "*.txt" -print | xargs sed -i "s/SYSADMIT/--SYSADMIT--/g"

El comando sed es ampliamente utilizado en linux y lo puedes utilizar para escribir de forma sencilla y rápida una linea de comando para hacer un buscar y reemplazar en un fichero de texto.
sed -i 's/antigua/nueva/g' prueba.txt
Directamente con este simple comando buscará en el fichero prueba.txt todas las coincidencias con "antigua" y las reemplazará por "nueva". El resultado quedará guardado en el mismo fichero gracias al modificador " -i ".
