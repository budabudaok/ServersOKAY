#!/usr/bin/env bash
#sokg.sh - .:SERVER.OK.GRAPHIC:. For Linux with DirectAdmin & CPanel by .:DANIEL BUSTAMANTE:.
printf "\n"
echo "Initializing the DASHBOARD for your simplicity.."
printf "\n"
sleep 1
if ps ax | grep -v grep | grep dialog > /dev/null 2>&1
then 
printf "\n"
printf "\n"
echo "¡OK! Executing .:SERVER.OK.GRAPHIC:. by .:DANIEL BUSTAMANTE:."
printf "\n"
printf "\n"
sleep 4
else 
yum install dialog -y
clear
printf "\n"
printf "\n"
echo "¡OK! Executing .:SERVER.OK.GRAPHIC:. by .:DANIEL BUSTAMANTE:."
printf "\n"
printf "\n"
sleep 4
fi

# Store menu options selected by the user
INPUT=/tmp/menu.sh.$$

# Storage file for displaying cal and date command output
OUTPUT=/tmp/output.sh.$$

# get text editor or fall back to vi_editor
vi_editor=${EDITOR-vi}

#identificamos el sistema operativo
    if cat /etc/redhat-release > /dev/null 2>&1
    then 
    RedHat=$(cat /etc/redhat-release)
    SO=$RedHat
    else 
     Debian=$(lsb_release -a)
     SO=$Debian
    fi
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

#validamos el RDNS
RDNS=$(getent hosts $HOSTNAME | awk '{ print $1 ; exit }')

#validamos el PTR
PTR=$(dig +noall +answer -x $RDNS | awk '{print $5 ; exit}')


#informamos version de apache
VersionAPACHE=$(httpd -v | awk {'print $3 ; exit'} | cut -d/ -f2)

#informamos version de mysql
VersionMYSQL=$(mysql --version|awk '{ print $5 }'|awk -F\, '{ print $1 }')

#informamos versiones y modos de php
#VersionesPHP=$(cat /usr/local/directadmin/custombuild/options.conf | grep php | grep release)
#VersionesModoPHP=$(cat /usr/local/directadmin/custombuild/options.conf | grep php | grep mode)
#echo "7. Sus versiones php son:"
#echo "$VersionesPHP"
#sleep 3
#echo "y operan en los siguientes modos:"
#echo "$VersionesModoPHP"
#printf "\n"
#sleep 4

# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; exit" SIGHUP SIGINT SIGTERM

#
# Purpose - display output using msgbox 
#  $1 -> set msgbox height
#  $2 -> set msgbox width
#  $3 -> set msgbox title
#
function display_output(){
    local h=${1-30}         # box height default 10
    local w=${2-71}         # box width default 41
    local t=${3-Output}     # box title 
    dialog --backtitle ".:SERVER.OK.GRAPHIC:. For Linux with DirectAdmin & CPanel by .:DANIEL BUSTAMANTE:." --title "${t}" --clear --msgbox "$(<$OUTPUT)" ${h} ${w}
}
#
# Purpose - display current system date & time
#
function show_date(){
    echo "Today is $(date) @ $(hostname -f)." >$OUTPUT
    display_output 6 60 "Date and Time"
}
#
# Purpose - display a calendar
#
function show_calendar(){
    cal >$OUTPUT
    display_output 13 25 "Calendar"
}
#
# proposito - mostrar info del sistema
#
function mostrar_info(){
   
echo "1. Hostname: $HOSTNAME \n\\n\
2. Reverso de Hostname: $RDNS \n\\n\
3. PTR de IP: $PTR \n\\n\
4. Sistema Operativo: $SO \n\\n\
5. Panel de Control: $PANEL \n\\n\
6. Apache: $VersionAPACHE \n\\n\
7. MySQL: $VersionMYSQL \n\n\ " >$OUTPUT

    display_output 30 85 "Informacion del Sistema"
}
#
# set infinite loop
#
while true
do

### display main menu ###
dialog --clear  --help-button --backtitle ".:SERVER.OK.GRAPHIC:. For Linux with DirectAdmin & CPanel by .:DANIEL BUSTAMANTE:." \
--title "[ MENU PRINCIPAL ]" \
--menu "Navega con las flechas ARRIBA/ABAJO o bien con la primera LETRA de tu opción.\n\\n\
Marca tu opción y presiona ENTER por favor:" 25 70 9 \
Informacion "Resumen del servidor" \
Date/time "Displays date and time" \
Calendar "Displays a calendar" \
Editor "Start a text editor" \
Exit "Exit to the shell" 2>"${INPUT}"

menuitem=$(<"${INPUT}")


# make decsion 
case $menuitem in
    Informacion) mostrar_info;;
    Date/time) show_date;;
    Calendar) show_calendar;;
    Editor) $vi_editor;;
    Exit) clear; echo "¡Thanks for use .:SERVER.OK.GRAPHIC:. by .:DANIEL BUSTAMANTE:.! Have a nice day"; break;;
    
esac

done

# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
