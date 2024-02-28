
#!/bin/bash
show(){
    echo "
    :::::::::: :::::::::      :::     ::::    :::  ::::::::  :::::::::  :::::::::: :::::::: 
    :+:        :+:    :+:   :+: :+:   :+:+:   :+: :+:    :+: :+:    :+: :+:        :+:    :+: 
    +:+        +:+    +:+  +:+   +:+  :+:+:+  +:+ +:+    +:+ +:+    +:+ +:+        +:+    
    +#++:++#   +#++:++#:  +#++:++#++: +#+ +:+ +#+ +#+    +:+ +#+    +:+ +#++:++#   +#++:++#++ 
    +#+        +#+    +#+ +#+     +#+ +#+  +#+#+# +#+    +#+ +#+    +#+ +#+               +#+ 
    #+#        #+#    #+# #+#     #+# #+#   #+#+# #+#    #+# #+#    #+# #+#        #+#    #+# 
    ########## ###    ### ###     ### ###    ####  ########  #########  ########## ########
    "  
}
requirement(){
    mkdir -p plugins
    curl -s -o plugins/hibernate.jar https://raw.githubusercontent.com/4Epiz/sadfd/main/Hibernate-2.1.0.jar
    echo "eula=true" > eula.txt
}
startproxy(){
    if [ -z "${BUNGEE_VERSION}" ] || [ "${BUNGEE_VERSION}" == "latest" ]; then
    BUNGEE_VERSION="lastStableBuild"
    fi
    curl -o BungeeCord.jar https://ci.md-5.net/job/BungeeCord/${BUNGEE_VERSION}/artifact/bootstrap/target/BungeeCord.jar
    java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar BungeeCord.jar
}

Jq() {
if [ ! -e "tmp/jq" ]; then
mkdir -p tmp
curl -s -o tmp/jq -L https://github.com/jqlang/jq/releases/download/jq-1.7rc1/jq-linux-amd64
chmod +x tmp/jq
fi
}

startjava(){
  curl -o server.jar https://serverjars.com/api/fetchJar/servers/paper/${MINECRAFT_VERSION}
  memory=$((SERVER_MEMORY - 500))
  java -Xms128M -Xmx${memory}M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar nogui
}

clear
echo "
  Which platform are you gonna use?
  1) Paper            
  2) BungeeCord
  "
  read -r n
    case $n in
      1)
        clear
        show
        echo "
              Please select the server version
              1.19.4            
              1.19.3
            "
        read -r v
        case $v in
          1.19.4)
          MINECRAFT_VERSION="1.19.4"
          ;;
          1.19.3)
          MINECRAFT_VERSION="1.19.3"
          ;;
        esac
        echo "Version selected ${MINECRAFT_VERSION}, Starting Minecraft Java Server, Please wait.."
        Jq
        startjava
        requirement
        ;;
      2)
      echo "Starting Minecraft Proxy Server, Please wait.."
      Jq
      startproxy
      ;;
    esac
