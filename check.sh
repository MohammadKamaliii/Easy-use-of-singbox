#!/bin/bash
hysteria=`ps -aux | grep /proxy/mainfiles/hysteria/config_hysteria.json | wc -l` 
vless=`ps -aux | grep /proxy/mainfiles/vless/config_vless.json | wc -l`
tuic=`ps -aux | grep /proxy/mainfiles/tuic/config_tuic.json | wc -l`
shadowtls=`ps -aux | grep /proxy/mainfiles/shadowtls/config_shadowtls.json | wc -l`


hysteria () {
	if [ $hysteria == 1 ]; then
	/proxy/mainfiles/hysteria/sing-box -c /proxy/mainfiles/hysteria/config_hysteria.json run &	
	fi
}


vless () {
	if [ $vless == 1 ]; then
	/proxy/mainfiles/vless/sing-box -c /proxy/mainfiles/vless/config_vless.json run &
	fi
}

tuic() {
	if [ $tuic == 1 ]; then
	/proxy/mainfiles/tuic/sing-box -c /proxy/mainfiles/tuic/config_tuic.json run &	
	fi
}

shadowtls () {
	if [ $shadowtls == 1 ]; then
	/proxy/mainfiles/shadowtls/sing-box -c /proxy/mainfiles/shadowtls/config_shadowtls.json run &
	fi
}
