LAN_CLAYNET=1
LAN_PROJECT=0
EXT=0

ASK=0         # 0 TO SKIP ASK - OR 1 TO ASK
CONFIRM=""   # "" TO SKIP CONFIRMING - OR ANYTHING TO GO CONFIRMING

EXT_DRIVE="CLAY_EXT"
PASSWORD=`/usr/bin/security find-generic-password -l "claynet" -w` 
PROJECTVOL="/Volumes/PROJECTVOL"
CLAY=".__CLAY__"
USERSDIR=".__USERS__"
HOME_LOCAL="/Users/$USER"
HOME_EXT="/Volumes/$EXT_DRIVE/$USERSDIR/$USER"

SHARED="Shared"
HOME_LOCAL_PUB="/Users/$SHARED"
HOME_EXT_PUB="/Volumes/$EXT_DRIVE/$USERSDIR/$SHARED"

TEMPDIR="/Users/$USER/$CLAY/__TEMPDIR__"
RESULTFILE="/Users/$USER/$CLAY/folderlist.txt"

# SERVER LIST
declare -a IPADDR_ARR=("192.168.1.10"  "192.168.1.20" )

# MAIN FOLDER STRUCTURE

clear


#####################################  ARGUMENTS PASSING  ###############################################
#
if ! [ "$1" == "" ]; then
    if [ "$1" == "-c" ]; then
        CONFIRM="x" 
    else
        CONFIRM="" 
    fi

    if [ "$1" == "-r" ]; then
        echo "RESULT :"
        echo "----------"
        cat $RESULTFILE
        echo
        exit 1
    fi

    if [ "$1" == "-d" ]; then
        echo "DATA :"
        echo "----------"
        echo "LAN CLAYNET : $LAN_CLAYNET"
        echo "LAN PROJECT : $LAN_PROJECT"
        echo "EXT : $EXT"
        echo
        exit 1
    fi

    if [ "$1" == "-" ]; then
        programname=$0

        function usage {
            echo "usage: $programname [-crd]"
            echo "  -c      turn ON confirm"
            echo "  -r      show last mounted folder structure"
            echo "  -d      show data"
            echo "  -      display help"
            echo
            exit 1
        }

        usage
    fi


fi


#####################################  PROCEDURE  ###############################################
#

askme() {
    # PUSH DATA
    LAN_CLAYNET0=$LAN_CLAYNET
    LAN_PROJECT0=$LAN_PROJECT
    EXT0=$EXT

    while ! [ "$CONFIRM" = "" ]
    do
        clear
        echo "================="
        echo "PROJECTVOL SETUP"
        echo "================="  
        echo
        if [ $ASK -eq 1 ]; then

            
            

            read -p "CLAYNET LAN ($LAN_CLAYNET) ? " LAN_CLAYNET
            if [ "$LAN_CLAYNET" = "" ]; then
                LAN_CLAYNET=$LAN_CLAYNET0
            fi
            #echo "LAN CLAYNET : $LAN_CLAYNET"
            #echo

            read -p "PROJECTS LAN ($LAN_PROJECT) ? " LAN_PROJECT
            if [ "$LAN_PROJECT" = "" ]; then
                LAN_PROJECT=$LAN_PROJECT0
            fi
            #echo "LAN PROJECT : $LAN_PROJECT"
            #echo

            read -p "EXTERNAL DRIVE ($EXT) ? " EXT
            if [ "$EXT" = "" ]; then
                EXT=$EXT0
            fi
            #echo "LAN CLAYNET : $EXT"
            #echo
        else


            echo "LAN CLAYNET : $LAN_CLAYNET"
            echo "LAN PROJECT : $LAN_PROJECT"
            echo "EXT : $EXT"
            
        fi
        echo
        read -p "CONFIRM ? " CONFIRM

        if ! [ "$CONFIRM" = "" ]; then
            ASK=1    
            # POP DATA
            LAN_CLAYNET=$LAN_CLAYNET0
            LAN_PROJECT=$LAN_PROJECT0
            EXT=$EXT0
        fi

    done
    clear
    echo
    echo
    }

unmount() {
    # CLEANUP
    # echo 
    # echo "      MOUNT CLEAN UP"  
    # echo "----------------------------------------------------"     
    echo ":::::::::::::::::::::::: INIT START ::::::::::::::::::::::::"
    echo
    echo "Temp folder for mounting test ... "
    echo
    if ! [ -d "$HOME_LOCAL/$CLAY" ]; then
        printf "> mkdir $HOME_LOCAL/$CLAY "
        mkdir $HOME_LOCAL/$CLAY && echo "... OK"  || exit 1
    else
        echo "$HOME_LOCAL/$CLAY ... OK"    
    fi

    if ! [ -d "$HOME_LOCAL_PUB/$CLAY" ]; then
        printf "> mkdir $HOME_LOCAL_PUB/$CLAY "
        mkdir $HOME_LOCAL_PUB/$CLAY && echo "... OK"  || exit 1
    else
        echo "$HOME_LOCAL_PUB/$CLAY ... OK"    
    fi



    echo
    if ! [ -d "$TEMPDIR" ]; then
        printf "> mkdir $TEMPDIR"
        mkdir $TEMPDIR && echo "... OK" || exit 1
    else
        echo "$TEMPDIR ... OK"
    fi

    mounted_folders=`df | awk '/CLAYNET/ { print $9 }'` # find mounted folder match this pattern

    SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
    IFS=$'\n'      # Change IFS to newline char
    mounted_folders=($mounted_folders) # split the `mounted_folders` string into an array by the same name
    IFS=$SAVEIFS   # Restore original IFS
    for (( i=0; i<${#mounted_folders[@]}; i++ ))
    do
        echo ""
        echo "> diskutil unmount ${mounted_folders[$i]}"
        diskutil unmount ${mounted_folders[$i]} && echo "... OK"  || exit 1

    done
    echo
    echo ":::::::::::::::::::::::: INIT DONE ::::::::::::::::::::::::"
    clear
    echo
    echo
    echo "================="
    }

header() {
    LAN=$(( $LAN_CLAYNET + $LAN_PROJECT ))
    LOOP_HEADER=1
    while [ $LOOP_HEADER -eq 1 ]
    do
        clear
        echo "================="
        echo "PROJECTVOL SETUP"
        echo "================="
        if [ $EXT -eq 1 ]; then
            printf "MODE : EXT"
        else
            printf "MODE : LOCAL"
        fi
        if [ $LAN_CLAYNET -eq 1 ]; then
            printf " +CLAYNET"
        fi

        if [ $LAN_PROJECT -eq 1 ]; then
            printf " +PROJECT"
        fi
        echo
        echo
        echo "LAN CLAYNET : $LAN_CLAYNET"
        echo "LAN PROJECT : $LAN_PROJECT"
        echo "EXT : $EXT"
        echo


        if [ $EXT -eq 1 ]; then
            if ! [ -d "/Volumes/$EXT_DRIVE" ]; then
                echo
                echo ">>>>>> ERROR - NO EXTERNAL DRIVE !"
                echo
                read -p 'SWITCH TO LOCAL ? ' USELOCAL
                if [ "$USELOCAL" = "" ]; then
                    EXT=0
                    echo
                    echo
                    echo
                    
                    continue
                else
                    echo
                    echo ">>>>>> ERROR - NO EXTERNAL DRIVE !"
                    echo
                    exit
                fi 
            fi
        fi


        if [ $LAN -gt 0 ];
        then
            echo
            echo "      CHECKING LAN"  
            echo "----------------------------------------------------" 
            ## declare an array variable
            
            IPADDR="" 

            ## now loop through the above array
            for i in "${IPADDR_ARR[@]}"
            do
                if ping -c1 -W1 -q $i > /dev/null 2>&1 ;
                then
                    IPADDR=$i
                    printf "$i --- OK --> "
                    MOUNT_POINT="//$IPADDR/CLAYNET"
                    # check mountpoint 
                    mount_smbfs $MOUNT_POINT $TEMPDIR
                    if [ $? -eq 0 ]; then
                        echo "MOUNT POINT $MOUNT_POINT --- OK"
                        if [ -d "$TEMPDIR" ]; then
                            diskutil unmount $TEMPDIR > /dev/null

                        fi
                        echo
                        break
                    else
                        echo
                        echo ">>>>>> MOUNT POINT $MOUNT_POINT --- FAIL or NOT AVAILABLE."
                        echo 
                        exit
                    fi
                fi
                echo "$i DOWN"
            done

            if [ -z "$IPADDR" ]  ;
            then
                
                echo
                echo ">>>>>> ERROR - NO SERVER !"
                echo 
                read -p 'SKIP LAN ? ' USELOCALEXT
                if [ "$USELOCALEXT" = "" ]; then
                    LAN_CLAYNET=0
                    LAN_PROJECT=0
                    LAN=$(( $LAN_CLAYNET + $LAN_PROJECT )) #new LAN VALUE
                    echo
                    echo
                    continue
                else
                    echo
                    echo ">>>>>> ERROR - NO SERVER !"
                    echo 
                    exit
                fi
            fi
            
        fi
        LOOP_HEADER=0
    done
    }

#
#
#####################################  START  ###############################################
#
#



askme
unmount
header

#
#
#####################################  FOLDER SETUP - CREATE IF DOES NOT EXIST  ###############################################
#
#

echo 
echo "      FOLDER SETUP"  
echo "----------------------------------------------------"    
#
# SETUP VARS
#
if [ $EXT -eq 1 ]; then
    CLAY_HOME="$HOME_EXT/$CLAY"
    CLAY_HOME_PUB="$HOME_EXT_PUB/$CLAY"
else
    CLAY_HOME="$HOME_LOCAL/$CLAY"
    CLAY_HOME_PUB="$HOME_LOCAL_PUB/$CLAY"
fi
PROJECTVOL_SRC="$CLAY_HOME/PROJECTVOL_SRC"

if [ $LAN_CLAYNET -eq 1 ]; then
    CLAYNET_SRC="//$IPADDR/CLAYNET"
else
    CLAYNET_SRC="$CLAY_HOME_PUB/CLAYNET_SRC"
fi

if [ $LAN_PROJECT -eq 1 ]; then
    PROJECTS_SRC="//$IPADDR/CLAYNET/homes/$USER/projects"
else
    PROJECTS_SRC="$CLAY_HOME/PROJECTS_SRC"
fi
LOCALIZED_CLAYNET_SRC="$CLAY_HOME_PUB/CLAYNET_SRC"

#
#
# /VOLUMES/EXT/.__USERS__/ & /VOLUMES/EXT/.__USERS__/<USER>/
if [ $EXT -eq 1 ]; then
    if ! [ -d "/Volumes/$EXT_DRIVE/$USERSDIR" ]; then
        printf "> create folder -> /Volumes/$EXT_DRIVE/$USERSDIR"
        mkdir /Volumes/$EXT_DRIVE/$USERSDIR && echo "... OK" || exit 1
    else 
        echo "/Volumes/$EXT_DRIVE/$USERSDIR ... OK"
    fi

    if ! [ -d "$HOME_EXT" ]; then
        printf "> create folder -> $HOME_EXT"
        mkdir $HOME_EXT && echo "... OK" || exit 1
    else 
        echo "$HOME_EXT ... OK"
    fi

    if ! [ -d "$HOME_EXT_PUB" ]; then
        printf "> create folder -> $HOME_EXT_PUB"
        mkdir $HOME_EXT_PUB && echo "... OK" || exit 1
    else 
        echo "$HOME_EXT_PUB ... OK"
    fi    

fi


# /VOLUMES/EXT/.__USERS__/<USER>/__CLAY__/ AND /Users/<USER>/__CLAY__/
if ! [ -d "$CLAY_HOME" ]; then
    printf "> create folder -> $CLAY_HOME"
    mkdir $CLAY_HOME  && echo "... OK" || exit 1
else 
    echo "$CLAY_HOME ... OK"
fi

if ! [ -d "$CLAY_HOME_PUB" ]; then
    printf "> create folder -> $CLAY_HOME_PUB"
    mkdir $CLAY_HOME_PUB  && echo "... OK" || exit 1
else 
    echo "$CLAY_HOME_PUB ... OK"
fi


# PROJECTVOL SRC
if ! [ -d "$PROJECTVOL_SRC" ]; then
    printf "> create folder -> $PROJECTVOL_SRC"
    mkdir $PROJECTVOL_SRC  && echo "... OK" || exit 1
else 
    echo "$PROJECTVOL_SRC ... OK"
fi

# ROOT FOLDER
declare -a FOLDERS_ARR=( "elements" "localized" "render")
for i in "${FOLDERS_ARR[@]}"
do
    if ! [ -d "$PROJECTVOL_SRC/$i" ]; then
        printf "> create folder -> $PROJECTVOL_SRC/$i"
        mkdir $PROJECTVOL_SRC/$i  && echo "... OK" || exit 1
    else
        echo "$PROJECTVOL_SRC/$i ... OK"
    fi
done

# CLAYNET_SRC AND PROJECT_SRC
if [ $LAN_CLAYNET -eq 0 ]; then
    if ! [ -d "$CLAYNET_SRC" ]; then
        printf "> create folder -> $CLAYNET_SRC"
        mkdir $CLAYNET_SRC  && echo "... OK" || exit 1
    else 
        echo "$CLAYNET_SRC ... OK"
    fi
else
    echo "$CLAYNET_SRC ... OK"
fi

if [ $LAN_PROJECT -eq 0 ]; then
    if ! [ -d "$PROJECTS_SRC" ]; then
        printf "> create folder -> $PROJECTS_SRC"
        mkdir $PROJECTS_SRC  && echo "... OK" || exit 1
    else 
        echo "$PROJECTS_SRC ... OK"
    fi
else
    echo "$PROJECTS_SRC ... OK"

fi

# LOCALIZED
if ! [ -d "$PROJECTVOL_SRC/localized/_Volumes" ]; then
    printf "> create folder -> $PROJECTVOL_SRC/localized/_Volumes"
    mkdir $PROJECTVOL_SRC/localized/_Volumes  && echo "... OK" || exit 1
else 
    echo "$PROJECTVOL_SRC/localized/_Volumes ... OK"
fi    

if ! [ -d "$PROJECTVOL_SRC/localized/_Volumes/PROJECTVOL" ]; then
    printf "> create folder -> $PROJECTVOL_SRC/localized/_Volumes/PROJECTVOL"
    mkdir $PROJECTVOL_SRC/localized/_Volumes/PROJECTVOL  && echo "... OK" || exit 1
else 
    echo "$PROJECTVOL_SRC/localized/_Volumes/PROJECTVOL ... OK"
fi    


echo " "
echo " "



#
#
########################################  CLEANUP FOLDERS  ##############################################
#
#
# REMOVE IF SYMLINK
# IF /USERS/__USER__/DESKTOP/PROJECTVOL & /VOLUMES/PROJECTVOL EXIST THEN DELETE      #
# IF CLAYNET AND projects EXIST INSIDE HOME/PROJECTVOL_SRC/ THEN DELETE
echo "      PROJECTVOL cleanup"  
echo "----------------------------------------------------" 


# remove FAIL LINKED FOLDER ( CLAYNET_SRC )
declare -a FAIL_FOLDER_ARR=( 
    "$HOME_EXT/$CLAY/CLAYNET_SRC/CLAYNET_SRC"
    "$HOME_LOCAL/$CLAY/CLAYNET_SRC/CLAYNET_SRC"
    )

for i in "${FAIL_FOLDER_ARR[@]}"
do
    if [ -L "$i" ]; # IF SYMLINK
    then
        printf "> remove symlink ( FAIL LINKED FOLDER ) -> $i"
        sudo rm $i  && echo "... OK" || exit 1
        
    else 
        if [ -d "$i" ]; # IF FOLDER EXISTS.
        then
            if [ -z "$(ls -A $i | grep -v -e '\.DS_Store' -e 'CLAYNET_SRC' -e 'PROJECTS_SRC')" ];  # IF FOLDER EMPTY
            then
                printf "> remove folder ( FAIL LINKED FOLDER ) -> $i"
                sudo rm -r $i  && echo "... OK" || exit 1
            else 
                echo "> Can't delete folder ( FAIL LINKED FOLDER ) -> $i. Folder is not empty."
            fi
        else
            echo "$i ... SKIP - ( FAIL LINKED FOLDER ) does not exist."
        fi
    fi
done



# remove __TEMPDIR__
printf "> rmdir $TEMPDIR"
rmdir $TEMPDIR && echo "... OK" || echo "... CAN'T REMOVE - SKIP"    





# remove MAIN TREE FOLDERS
declare -a PROJECTVOL_ARR=( 
    "$PROJECTVOL/localized/_Volumes/PROJECTVOL/CLAYNET" 
    "$PROJECTVOL"   
    "$HOME_LOCAL/Desktop/PROJECTVOL" 
    "$HOME_EXT/$CLAY/PROJECTVOL_SRC/CLAYNET" 
    "$HOME_EXT/$CLAY/PROJECTVOL_SRC/projects" 
    "$HOME_LOCAL/$CLAY/PROJECTVOL_SRC/CLAYNET" 
    "$HOME_LOCAL/$CLAY/PROJECTVOL_SRC/projects" 
    )

for i in "${PROJECTVOL_ARR[@]}"
do
    if [ -L "$i" ]; # IF SYMLINK
    then
        printf "> remove symlink -> $i"
        sudo rm $i  && echo "... OK" || exit 1
        
    else 
        if [ -d "$i" ]; # IF FOLDER EXISTS.
        then
            if [ -z "$(ls -A $i | grep -v -e '\.DS_Store' -e 'CLAYNET_SRC' -e 'PROJECTS_SRC')" ];  # IF FOLDER EMPTY
            then
                printf "> remove folder -> $i"
                sudo rm -r $i  && echo "... OK" || exit 1
            else 
                echo "Can't delete folder -> $i. Folder is not empty."
            fi
        else
            echo "$i ... SKIP - does not exist."
        fi
    fi
done
echo " " 
echo " " 

#
#
########################################  MOUNT / SYNLINK  ##############################################
# 
#

# CREATE SYMLINK TO /VOLUMES/PROJECTVOL
echo "      SYMLINK TO /VOLUMES/PROJECTVOL"  
echo "----------------------------------------------------"     
printf "> create symlink -> $PROJECTVOL_SRC -> $PROJECTVOL"
sudo ln -s $PROJECTVOL_SRC $PROJECTVOL  && echo "... OK" || exit 1 # 0 - USE EXTERNAL DRIVE
echo " "
echo " "


# CREATE SYMLINK TO /VOLUMES/PROJECTVOL/LOCALIZED
echo "      SYMLINK TO /VOLUMES/PROJECTVOL/LOCALIZED"  
echo "----------------------------------------------------"     
printf "> create symlink -> $LOCALIZED_CLAYNET_SRC -> $PROJECTVOL/localized/_Volumes/PROJECTVOL/CLAYNET"
sudo ln -s $LOCALIZED_CLAYNET_SRC $PROJECTVOL/localized/_Volumes/PROJECTVOL/CLAYNET  && echo "... OK" || exit 1 # 0 - USE EXTERNAL DRIVE

echo " "
echo " "
#
#

# CLAYNET & PROJECTS
echo "      SYMLINK (OR MOUNT) TO CLAYNET & PROJECTS "  
echo "----------------------------------------------------"     
if [ $LAN_CLAYNET -eq 1 ];
then
    # USE MOUNT /VOLUMES/PROJECTVOL/XX IF LAN=1
    if ! [ -d "$PROJECTVOL_SRC/CLAYNET" ]; then
        printf "> create folder -> $PROJECTVOL_SRC/CLAYNET"
        mkdir $PROJECTVOL_SRC/CLAYNET  && echo "... OK" || exit 1
        
    fi
    printf "> mount -> //$IPADDR/CLAYNET $PROJECTVOL_SRC/CLAYNET"
    mount_smbfs //$USER:$PASSWORD@$IPADDR/CLAYNET $PROJECTVOL_SRC/CLAYNET  && echo "... OK" || exit 1
    
else 
    # USE SYMLINK TO /VOLUMES/PROJECTVOL/XX IF LAN=0
    printf "> create symlink -> $CLAYNET_SRC -> $PROJECTVOL_SRC/CLAYNET"
    sudo ln -s $CLAYNET_SRC $PROJECTVOL_SRC/CLAYNET  && echo "... OK" || exit 1 # 0 - USE EXTERNAL DRIVE
    
fi


if [ $LAN_PROJECT -eq 1 ];
then
    # USE MOUNT /VOLUMES/PROJECTVOL/XX IF LAN=1
    if ! [ -d "$PROJECTVOL_SRC/projects" ]; then
        printf "> create folder -> $PROJECTVOL_SRC/projects"
        mkdir $PROJECTVOL_SRC/projects  && echo "... OK" || exit 1
        
    fi
    printf "> mount -> //$IPADDR/CLAYNET/homes/$USER/projects -> $PROJECTVOL_SRC/projects"
    mount_smbfs //$USER:$PASSWORD@$IPADDR/CLAYNET/homes/$USER/projects $PROJECTVOL_SRC/projects  && echo "... OK" || exit 1
    
else 
    # USE SYMLINK TO /VOLUMES/PROJECTVOL/XX IF LAN=0
    printf "> create symlink -> $PROJECTS_SRC -> $PROJECTVOL_SRC/projects "
    sudo ln -s $PROJECTS_SRC $PROJECTVOL_SRC/projects  && echo "... OK" || exit 1 # 0 - USE EXTERNAL DRIVE
    

fi

# SYMLINK TO /USER/__USER__/DESKTOP/PROJECTVOL
printf "> create symlink -> $PROJECTVOL -> $HOME_LOCAL/Desktop/PROJECTVOL"
ln -s $PROJECTVOL $HOME_LOCAL/Desktop/PROJECTVOL  && echo "... OK" || exit 1 # 0 - SYMLINK TO USER DESKTOP

echo
echo



#
#
########################################  RESULT  ##############################################
#
#

printf "      RESULT -- "  
if [ $EXT -eq 1 ]; then
    printf "EXT"
else
    printf "LOCAL"
fi
if [ $LAN -gt 0 ];
then
    
    if [ $LAN_CLAYNET -eq 1 ]; then
        printf " +CLAYNET"
    fi

    if [ $LAN_PROJECT -eq 1 ]; then
        printf " +PROJECT"
    fi
    printf " ( $IPADDR )"
    echo
else
    echo " - NO LAN"
fi
echo "--------------------------------------------------------------------------------------"  


echo "" > $RESULTFILE
ls -ls $PROJECTVOL | awk '{print $10 $11 $12}' | sed -e 's/->/ -> /g' | tee -a $RESULTFILE
if [ $LAN -gt 0 ];
then
    if ! [ $LAN_CLAYNET -eq 1 ]; then
        ls -ls -d $PROJECTVOL/* | grep -v "projects\|localized\|elements\|render\|temp" | awk '{print $10 $11 $12}' | sed -e 's/->/ -> /g' | tee -a $RESULTFILE
    fi
    df | awk '/CLAYNET/ { print $9 " -> " $1}' | sed  "s/CLAY_EXT\/$USERSDIR\/$USER\/$CLAY\/PROJECTVOL_SRC/PROJECTVOL/" | sed  "s/Users\/$USER\/$CLAY\/PROJECTVOL_SRC/Volumes\/PROJECTVOL/" | tee -a $RESULTFILE
    if ! [ $LAN_PROJECT -eq 1 ]; then
        ls -ls -d $PROJECTVOL/* | grep -v "CLAYNET\|localized\|elements\|render\|temp" | awk '{print $10 $11 $12}' | sed -e 's/->/ -> /g' | tee -a $RESULTFILE
    fi
    ls -ls -d $PROJECTVOL/localized/_Volumes/PROJECTVOL/CLAYNET | awk '{print $10 $11 $12}' | sed -e 's/->/ -> /g' | tee -a $RESULTFILE
    PARAM="CLAYNET\|projects\|localized"


    ls -ls -d $PROJECTVOL/* | grep -v $PARAM | awk '{print $10 $11 $12}' | tee -a $RESULTFILE

else
    ls -ls -d $PROJECTVOL/* | grep 'CLAYNET\|projects' | awk '{print $10 $11 $12}' | sed -e 's/->/ -> /g' | tee -a $RESULTFILE
    ls -ls -d $PROJECTVOL/localized/_Volumes/PROJECTVOL/CLAYNET | awk '{print $10 $11 $12}' | sed -e 's/->/ -> /g' | tee -a $RESULTFILE
    ls -ls -d $PROJECTVOL/* | grep -v 'CLAYNET\|projects' | grep -v 'localized' | awk '{print $10 $11 $12}' | tee -a $RESULTFILE
    
fi



echo " "
echo " "
echo "----------------------------------------------------"  
echo "      ALL GOOD :: Have a Nice Day." 
echo "----------------------------------------------------"  
echo " "    