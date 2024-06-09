#!/bin/bash

mkdir -p /proxy
mkdir -p /proxy/mainfiles
cp check.sh /proxy/mainfiles
uuid="bfc4bf3c-b739-4ac1-97b0-801ccdc20e60"

delete_go () {
	rm -rf /usr/local/go
}

dow_install_go () {

	wget https://go.dev/dl/go1.20.12.linux-amd64.tar.gz;mv go1* /proxy
	tar -C /usr/local -xzf /proxy/go1*
        echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
	source /etc/profile	
}

sing_box() {
	apt install git 
	git clone https://github.com/SagerNet/sing-box.git
	cp -r sing-box/* .
	go build -tags "with_quic with_dhcp with_wireguard with_ech with_utls with_reality_server with_acme" .cmd/sing-box
go install -v -tags with_quic,with_dhcp,with_wireguard,with_ech,with_utls,with_reality_server,with_acme github.com/sagernet/sing-box/cmd/sing-box@dev-next

}

seteverything() {

	listofthings=("hysteria" "vless" "tuic" "shadowtls")
	mainlist=()
	portlist=()
	for ((i=0;i<4;i++));
		do
		echo 1:YES  2:NO
		read -p "install ${listofthings[$i]}? " j
		if [ $j == 1 ]; then
			mainlist+=($i)
			read -p "on which port?" port
			portlist+=($port)
			echo "${listofthings[$i]} Added"
		elif [ $j == 2 ]; then
			echo "${listofthings[$i]} didn't Add"
			portlist+=(443)
		else
			echo "invalid
	please enter a new mount again : "
			i=$(( $i - 1 ))
		fi

	done
check
}

check() {
	abc=""
	for j in ${mainlist[@]};
	do
		abc="$abc  ${listofthings[$j]}"
		mkdir -p /proxy/mainfiles/${listofthings[$j]}
	done

	echo "you've chosen : $abc"

	echo 1:YES  2:NO
	read -p "is it right? " c

	while [ $c != 1 ] && [ $c != 2 ] ; do

		read -p "Invalid number
	please enter a new : " c
		echo $c
	done
	if [ $c == 1 ]; then

		echo "files are made"

	elif [ $c == 2 ]; then
		rm -rf /proxy/mainfiles/*
		seteverything
		
	fi


}

makerunfile() {
echo "#!bin/bash" > /proxy/mainfiles/sn.sh
	for ((i=1;i<=${#mainlist[@]};i++));
		do
			bbb=`echo $abc | tr -s " " | cut -d " " -f $i`

			touch /proxy/mainfiles/$bbb/config_$bbb".json"
			echo /proxy/mainfiles/$bbb/sing-box -c /proxy/mainfiles/$bbb/config_$bbb".json run &" >> /proxy/mainfiles/sn.sh
		done


sed -i '$s/&//' /proxy/mainfiles/sn.sh



}

makecheckfile () {
	for ((i=1;i<=${#mainlist[@]};i++));
	do
			bbb=`echo $abc | tr -s " " | cut -d " " -f $i`
			
			echo $bbb >> /proxy/mainfiles/check.sh
	done
	
	echo "* * * * * /proxy/mainfiles/check.sh" >> /var/spool/cron/crontabs/root
}


certification() {
    echo "1:YES 2:NO"
    read -p "Do you have a domain or not? " certanswer

    if [ "$certanswer" == 1 ]; then
        echo "Coming soon in the next release"
    elif [ "$certanswer" == 2 ]; then
        openssl ecparam -genkey -name prime256v1 -out /proxy/ca.key
        openssl req -new -x509 -days 36500 -key /proxy/ca.key -out /proxy/ca.crt -subj "/CN=bing.com"
        cert="/proxy/ca.crt"
        key="/proxy/ca.key"
    fi
}


hysteria () {
	linkhys=https://raw.githubusercontent.com/chika0801/sing-box-examples/main/Hysteria2/config_server.json
	curl $linkhys > /proxy/mainfiles/hysteria/config_hysteria.json
	
	sed -i 's|""|'\"$uuid\"'|' /proxy/mainfiles/hysteria/config_hysteria.json
	sed -i 's|"/root/fullchain.cer"|'\"$cert\"'|' /proxy/mainfiles/hysteria/config_hysteria.json
	sed -i 's|"/root/private.key"|'\"$key\"'|' /proxy/mainfiles/hysteria/config_hysteria.json
	sed -i 's|"listen_port": 443|"listen_port": '${portlist[0]}'|' /proxy/mainfiles/hysteria/config_hysteria.json

cp /root/go/bin/sing-box /proxy/mainfiles/hysteria

}

vless () {
	linkvless=https://raw.githubusercontent.com/chika0801/sing-box-examples/main/TCP_Brutal/config_server.json
	curl $linkvless > /proxy/mainfiles/vless/config_vless.json
	
	sed -i 's|""|'\"$uuid\"'|' /proxy/mainfiles/vless/config_vless.json
	sed -i 's|"/root/fullchain.cer"|'\"$cert\"'|' /proxy/mainfiles/vless/config_vless.json
	sed -i 's|"/root/private.key"|'\"$key\"'|' /proxy/mainfiles/vless/config_vless.json
	sed -i 's|"listen_port": 443|"listen_port": '${portlist[1]}'|' /proxy/mainfiles/vless/config_vless.json

cp /root/go/bin/sing-box /proxy/mainfiles/vless
}

tuic () {
	linktuic=https://raw.githubusercontent.com/chika0801/sing-box-examples/main/TUIC/config_server.json
	curl $linktuic > /proxy/mainfiles/tuic/config_tuic.json
	sed -i 's|""|'\"$uuid\"'|' /proxy/mainfiles/tuic/config_tuic.json
	sed -i 's|""|'\"$uuid\"'|' /proxy/mainfiles/tuic/config_tuic.json
	sed -i 's|"/root/fullchain.cer"|'\"$cert\"'|' /proxy/mainfiles/tuic/config_tuic.json
	sed -i 's|"/root/private.key"|'\"$key\"'|' /proxy/mainfiles/tuic/config_tuic.json
	sed -i 's|"listen_port": 443|"listen_port": '${portlist[2]}'|' /proxy/mainfiles/tuic/config_tuic.json

cp /root/go/bin/sing-box /proxy/mainfiles/tuic


}

shadowtls () {
	linkshadowtls=https://raw.githubusercontent.com/chika0801/sing-box-examples/main/ShadowTLS/config_server.json
	curl $linkshadowtls > /proxy/mainfiles/shadowtls/config_shadowtls.json
	sed -i 's|"password": ""|"password": "r/l11RHl183Al8FhbB7xVA=="|' /proxy/mainfiles/shadowtls/config_shadowtls.json
	sed -i 's|"server": ""|"server": "speedtest.net"|' /proxy/mainfiles/shadowtls/config_shadowtls.json
	sed -i 's|"listen_port": 443|"listen_port": '${portlist[3]}'|' /proxy/mainfiles/shadowtls/config_shadowtls.json

cp /root/go/bin/sing-box /proxy/mainfiles/shadowtls

}



setconfigs () {

	for i in ${mainlist[@]}; 
	do
		if [ $i == 0 ]; then
			hysteria
		elif [ $i == 1 ]; then
			vless
		elif [ $i == 2 ]; then
			tuic
		elif [ $i == 3 ]; then
			shadowtls
		fi
	done
}	



setservice() {
cp sing-box.service /etc/systemd/system
chmod u+x /proxy/mainfiles/sn.sh
systemctl daemon-reload
systemctl enable --now sing-box.service


}

delete_go
dow_install_go
sing_box
seteverything
makerunfile
certification
setconfigs
setservice
makecheckfile
