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
    mkdir plugins
    curl -s -o plugins/hibernate.jar https://www.spigotmc.org/resources/hibernate.4441/download?version=506703
    echo "eula=true" > eula.txt
}

startproxy{
    if [ -z "${BUNGEE_VERSION}" ] || [ "${BUNGEE_VERSION}" == "latest" ]; then
    BUNGEE_VERSION="lastStableBuild"
    fi
    curl -o BungeeCord.jar https://ci.md-5.net/job/BungeeCord/${BUNGEE_VERSION}/artifact/bootstrap/target/BungeeCord.jar
    java -Xms128M -XX:MaxRAMPercentage=95.0 -Dterminal.jline=false -Dterminal.ansi=true -jar BungeeCord.jar
}
startjava(){
if [ -n "${DL_PATH}" ]; then
	echo -e "Using supplied download url: ${DL_PATH}"
	DOWNLOAD_URL=`eval echo $(echo ${DL_PATH} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
else
	VER_EXISTS=`curl -s https://api.papermc.io/v2/projects/${PROJECT} | jq -r --arg VERSION $MINECRAFT_VERSION '.versions[] | contains($VERSION)' | grep -m1 true`
	LATEST_VERSION=`curl -s https://api.papermc.io/v2/projects/${PROJECT} | jq -r '.versions' | jq -r '.[-1]'`

	if [ "${VER_EXISTS}" == "true" ]; then
		echo -e "Version is valid. Using version ${MINECRAFT_VERSION}"
	else
		echo -e "Specified version not found. Defaulting to the latest ${PROJECT} version"
		MINECRAFT_VERSION=${LATEST_VERSION}
	fi

	BUILD_EXISTS=`curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION} | jq -r --arg BUILD ${BUILD_NUMBER} '.builds[] | tostring | contains($BUILD)' | grep -m1 true`
	LATEST_BUILD=`curl -s https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION} | jq -r '.builds' | jq -r '.[-1]'`

	if [ "${BUILD_EXISTS}" == "true" ]; then
		echo -e "Build is valid for version ${MINECRAFT_VERSION}. Using build ${BUILD_NUMBER}"
	else
		echo -e "Using the latest ${PROJECT} build for version ${MINECRAFT_VERSION}"
		BUILD_NUMBER=${LATEST_BUILD}
	fi

	JAR_NAME=${PROJECT}-${MINECRAFT_VERSION}-${BUILD_NUMBER}.jar

	echo "Version being downloaded"
	echo -e "MC Version: ${MINECRAFT_VERSION}"
	echo -e "Build: ${BUILD_NUMBER}"
	echo -e "JAR Name of Build: ${JAR_NAME}"
	DOWNLOAD_URL=https://api.papermc.io/v2/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds/${BUILD_NUMBER}/downloads/${JAR_NAME}
fi

cd /mnt/server

echo -e "Running curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}"

if [ -f ${SERVER_JARFILE} ]; then
	mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

curl -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

if [ ! -f server.properties ]; then
    echo -e "Downloading MC server.properties"
    curl -o server.properties https://raw.githubusercontent.com/parkervcp/eggs/master/minecraft/java/server.properties
fi
java -Xms128M -Xmx{{SERVER_MEMORY}}M -XX:MaxRAMPercentage=90.0 -Dterminal.jline=false -Dterminal.ansi=true -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -jar server.jar
}

startpurper{

}
echo "
  Which platform are you gonna use?
  1) Paper            
  2) BungeeCord
  "
    case $n in
      1)
        echo "Starting Minecraft Java Server, Please wait.."
        startjava
        requirement
        ;;
      2)
      echo "Starting Minecraft Proxy Server, Please wait.."
      startproxy
      ;;
