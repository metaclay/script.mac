LAN=1
OK=1
EXT=1 # USE EXTERNAL DRIVE

clear

echo "PROJECTVOL SETUP"
if [ $EXT -eq 1 ]; then
    printf "EXT MODE"
else
    printf "LOCAL MODE"
fi


if [ $LAN -eq 1 ];
then
    echo " --- +LAN"
    # echo
    # echo 
    # echo "      CHECKING LAN"  
    # echo "----------------------------------------------------" 
    ## declare an array variable
    declare -a IPADDR_ARR=("192.168.1.10" "192.168.1.20")
    IPADDR="" 

    ## now loop through the above array
    for i in "${IPADDR_ARR[@]}"
    do
        if ping -c1 -W1 -q $i > /dev/null 2>&1 ;
        then
            IPADDR=$i
            # echo "SERVER : $IPADDR"
            break
        fi
    done

    if [ -z "$IPADDR" ] && [ $LAN -eq 1 ] ;
    then
        OK=0
        echo
        echo "ERR - NO SERVER ! CANNOT USE LAN"
        echo 
    fi
    
fi



if [ $OK -eq 1 ];
then
    PASSWORD=`/usr/bin/security find-generic-password -l "claynet" -w` 
    PROJECTVOL="/Volumes/PROJECTVOL"
    EXT_DRIVE="CLAY_EXT"  #EXT DRIVE NAME
    CLAY="__CLAY__"
    CLAYNETDIR="CLAYNET"
    USERSDIR="__USERS__"
    HOME_LOCAL="/Users/$USER"
    HOME_EXT="/Volumes/$EXT_DRIVE/$USERSDIR/$USER"
    declare -a FOLDERS_ARR=( "elements" "localized" "render")
    


    #
    # FOLDER SETUP - CREATE IF DOES NOT EXIST.
    echo
    echo 
    echo "      FOLDER SETUP"  
    echo "----------------------------------------------------"    
    #
    # SETUP VARS
    #
    if [ $EXT -eq 1 ]; then
        CLAY_HOME="$HOME_EXT/$CLAY"
    else
        CLAY_HOME="$HOME_LOCAL/$CLAY"
    fi
    PROJECTVOL_SRC="$CLAY_HOME/PROJECTVOL_SRC"

    if [ $LAN -eq 1 ]; then
        CLAYNET_SRC="//$IPADDR/CLAYNET"
        PROJECTS_SRC="$CLAYNET_SRC/homes/$USER/projects"
    else
        CLAYNET_SRC="$CLAY_HOME/CLAYNET_SRC"
        PROJECTS_SRC="$CLAY_HOME/PROJECTS_SRC"
    fi
    #
    #
    # CREATE DIR IF NOT EXIST
    #
    if [ $EXT -eq 1 ]; then
        if ! [ -d "/Volumes/$EXT_DRIVE/$USERSDIR" ]; then
            echo "create folder -> /Volumes/$EXT_DRIVE/$USERSDIR"
            mkdir /Volumes/$EXT_DRIVE/$USERSDIR || exit 1
        else 
            echo "/Volumes/$EXT_DRIVE/$USERSDIR ... OK"
        fi

        if ! [ -d "$HOME_EXT" ]; then
            echo "create folder -> $HOME_EXT"
            mkdir $HOME_EXT || exit 1
        else 
            echo "$HOME_EXT ... OK"
        fi

    fi



    if ! [ -d "$CLAY_HOME" ]; then
        echo "create folder -> $CLAY_HOME"
        mkdir $CLAY_HOME || exit 1
    else 
        echo "$CLAY_HOME ... OK"
    fi

    if ! [ -d "$PROJECTVOL_SRC" ]; then
        echo "create folder -> $PROJECTVOL_SRC"
        mkdir $PROJECTVOL_SRC || exit 1
    else 
        echo "$PROJECTVOL_SRC ... OK"
    fi


    for i in "${FOLDERS_ARR[@]}"
    do
        if ! [ -d "$PROJECTVOL_SRC/$i" ]; then
            echo "create folder -> $PROJECTVOL_SRC/$i"
            mkdir $PROJECTVOL_SRC/$i || exit 1
        else
            echo "$PROJECTVOL_SRC/$i ... OK"
        fi
    done

    if [ $LAN -eq 0 ]; then
        if ! [ -d "$CLAYNET_SRC" ]; then
            echo "create folder -> $CLAYNET_SRC"
            mkdir $CLAYNET_SRC || exit 1
        else 
            echo "$CLAYNET_SRC ... OK"
        fi

        if ! [ -d "$PROJECTS_SRC" ]; then
            echo "create folder -> $PROJECTS_SRC"
            mkdir $PROJECTS_SRC || exit 1
        else 
            echo "$PROJECTS_SRC ... OK"
        fi
    else
        echo "$CLAYNET_SRC ... OK"
        echo "$PROJECTS_SRC ... OK"

    fi
    echo " "
    echo " "



    # CLEANUP
    # UNMOUNT IF MOUNTED FOLDER

    echo "      CLAYNET / PROJECTS CLEAN UP"  
    echo "----------------------------------------------------"     
    mounted_folders=`df | awk '/CLAYNET/ { print $9 }'` # find mounted folder match this pattern

    SAVEIFS=$IFS   # Save current IFS (Internal Field Separator)
    IFS=$'\n'      # Change IFS to newline char
    mounted_folders=($mounted_folders) # split the `mounted_folders` string into an array by the same name
    IFS=$SAVEIFS   # Restore original IFS
    for (( i=0; i<${#mounted_folders[@]}; i++ ))
    do
        diskutil unmount ${mounted_folders[$i]} || exit 1
    #
    #
    done
    echo " " 
    echo " " 

    # REMOVE IF SYMLINK
    # IF /USERS/__USER__/DESKTOP/PROJECTVOL & /VOLUMES/PROJECTVOL EXIST THEN DELETE      #
    # IF CLAYNET AND projects EXIST INSIDE HOME/PROJECTVOL_SRC/ THEN DELETE
    echo "      PROJECTVOL cleanup"  
    echo "----------------------------------------------------" 
    declare -a PROJECTVOL_ARR=( 
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
            
            sudo rm $i || exit 1
            echo "remove symlink -> $i"
        else 
            if [ -d "$i" ]; # IF FOLDER EXISTS.
            then
                if [ -z "$(ls -A $i | grep -v -e '\.DS_Store' -e 'CLAYNET_SRC' -e 'PROJECTS_SRC')" ];  # IF FOLDER EMPTY
                then
                    echo "remove folder -> $i"
                    sudo rm -r $i || exit 1
                else 
                    echo "Can't delete folder -> $i. Folder is not empty."
                fi
            else
                echo "$i does not exist."
            fi
        fi
    done
    echo " " 
    echo " " 


    # MOUNT / SYNLINK
    # CREATE SYMLINK TO /VOLUMES/PROJECTVOL
    echo "      SYMLINK TO /VOLUMES/PROJECTVOL"  
    echo "----------------------------------------------------"     

    sudo ln -s $PROJECTVOL_SRC $PROJECTVOL || exit 1 # 0 - USE EXTERNAL DRIVE
    echo "create symlink -> $PROJECTVOL_SRC -> $PROJECTVOL"
    echo " "
    echo " "
    #
    #
    # CLAYNET & PROJECTS
    echo "      SYMLINK (OR MOUNT) TO CLAYNET & PROJECTS "  
    echo "----------------------------------------------------"     
    if [ $LAN -eq 1 ];
    then
        # USE MOUNT /VOLUMES/PROJECTVOL/XX IF LAN=1
        if ! [ -d "$PROJECTVOL_SRC/CLAYNET" ]; then
            mkdir $PROJECTVOL_SRC/CLAYNET || exit 1
            echo "create folder -> $PROJECTVOL_SRC/CLAYNET"
        fi
        mount_smbfs //$USER:$PASSWORD@$IPADDR/CLAYNET $PROJECTVOL_SRC/CLAYNET || exit 1
        echo "mount -> //$IPADDR/CLAYNET $PROJECTVOL_SRC/CLAYNET"

        if ! [ -d "$PROJECTVOL_SRC/projects" ]; then
            mkdir $PROJECTVOL_SRC/projects || exit 1
            echo "create folder -> $PROJECTVOL_SRC/projects"
        fi
        mount_smbfs //$USER:$PASSWORD@$IPADDR/CLAYNET/homes/andi/projects $PROJECTVOL_SRC/projects || exit 1
        echo "mount -> //$IPADDR/CLAYNET/homes/andi/projects -> $PROJECTVOL_SRC/projects"
    else 
        # USE SYMLINK TO /VOLUMES/PROJECTVOL/XX IF LAN=0
        sudo ln -s $CLAYNET_SRC $PROJECTVOL_SRC/CLAYNET || exit 1 # 0 - USE EXTERNAL DRIVE
        echo "create symlink -> $CLAYNET_SRC -> $PROJECTVOL_SRC/CLAYNET"
        sudo ln -s $PROJECTS_SRC $PROJECTVOL_SRC/projects || exit 1 # 0 - USE EXTERNAL DRIVE
        echo "create symlink -> $PROJECTS_SRC -> $PROJECTVOL_SRC/projects "

    fi
    # SYMLINK TO /USER/__USER__/DESKTOP/PROJECTVOL
    ln -s $PROJECTVOL $HOME_LOCAL/Desktop/PROJECTVOL || exit 1 # 0 - SYMLINK TO USER DESKTOP
    echo "create symlink -> $PROJECTVOL -> $HOME_LOCAL/Desktop/PROJECTVOL"
    echo
    echo

    printf "      RESULT -- "  
    if [ $EXT -eq 1 ]; then
        printf "EXT MODE"
    else
        printf "LOCAL MODE"
    fi
    if [ $LAN -eq 1 ];
    then
        echo " + SERVER : $IPADDR"
    else
        echo " - NO LAN"
    fi
    echo "----------------------------------------------------"  
    
    ls -ls $PROJECTVOL | awk '{print $10 $11 $12}'
    if [ $LAN -eq 1 ];
    then
        df | awk '/CLAYNET/ { print $9 " -> " $1}' | sed  "s/CLAY_EXT\/__USERS__\/andi\/__CLAY__\/PROJECTVOL_SRC/PROJECTVOL/"
        ls -ls -d $PROJECTVOL/* | grep -v 'CLAYNET\|projects' | awk '{print $10 $11 $12}'
    else
        ls -ls -d $PROJECTVOL/* | grep 'CLAYNET\|projects' | awk '{print $10 $11 $12}'
        ls -ls -d $PROJECTVOL/* | grep -v 'CLAYNET\|projects' | awk '{print $10 $11 $12}'
    fi
    


    echo " "
    echo " "
    echo "----------------------------------------------------"  
    echo "      ALL GOOD :: Have a Nice Day." 
    echo "----------------------------------------------------"  
    echo " "    
fi