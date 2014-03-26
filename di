#!/bin/bash
##########################################################
## Autor: Percio Andrades
## Desenvolvido por : Eros Carvalho 
## Colaboradores : Rafael Terra, Percio Andrades
## Versão 1.2
##########################################################

# variaveis baschcss
corPadrao="\033[0m"
preto="\033[0;30m"
vermelho="\033[0;31m"
verde="\033[0;32m"
marrom="\033[0;33m"
azul="\033[0;34m"
purple="\033[0;35m"
cyan="\033[0;36m"
cinzaClaro="\033[0;37m"
pretoCinza="\033[1;30m"
vermelhoClaro="\033[1;31m"
verdeClaro="\033[1;32m"
amarelo="\033[1;33m"
azulClaro="\033[1;34m"
purpleClaro="\033[1;35m"
cyanClaro="\033[1;36m"
branco="\033[1;37m"
FAIL="\033[0;31m[!]\033[0m";



INFO_BR=$2
HOST=$(dig ip +short ${INFO_BR})

function SHOW_HELP(){
  echo "
  usage: di [-a] [domain] | [ -h --help ]

  Options:

        -b    |   --br          : Informação junto ao registro.br sobre documento e dominio 
        -i    |   --int         : Consulta dominio internacional (ainda não implementado)
        -a    |   --all         : Informações adicionais do dominio
	-m    |   --map		: Informação sobre portas        
	
        -h    |   --help        : Opções
 ex:

  di -b xxxxxxxxx-xx | di -b domain.com.br
  di -a domain.com
       "
  exit

}

## CHECK DEPENDECIES
if [ ! -f '/usr/bin/dig' ];then
	echo -e "
	${FAIL} - The application ${amar}dig${rese} is not installed on your computer, please install in order to run this script:
  
  	   - Red Hat: yum install dig
  	   - Debian: apt-get install dig
        "
exit

elif [ ! -f '/usr/bin/curl' ];then

	echo -e "
  	${FAIL} - The application ${amar}curl${rese} is not not installed on your computer, please install in order to run this script:

  	- RedHat: yum install curl
  	- Debian: apt-get install curl
        "
 exit
fi

### query national domain
function INFO_REGISTRO_BR(){
CURL_BR=$(curl -s https://registro.br/cgi-bin/whois/?qr=${INFO_BR}| egrep -o "excedida|inexistente|negada"| head -1)
if [ "${CURL_BR}" = "excedida" ];then
	echo -e "Proxy search\n"
	curl -s http://tools.badaiocas.com/search.php/registro.br/cgi-bin/whois/?qr=${INFO_BR} | sed -n '194,224p'| sed -e 's/<.*>//g'| iconv -f iso8859-1 -t utf-8
elif [ "${CURL_BR}" = "inexistente" ];then
	echo -e "\033[0;31m${INFO_BR}\n\033[0mnão consta na base de dados do registro.br\033[0m"

elif [ "${CURL_BR}" = "negada"  ];then
	echo -e "Consulta negada"
else
	(curl -s https://registro.br/cgi-bin/whois/?qr=${INFO_BR} | sed -n '189,225p'| sed -e 's/<.*>//g'| iconv -f iso8859-1 -t utf-8 | sed -e 's/criado/registrado/g')

fi
} 


## function get aditional information
function GET_ALL(){
G_SOA=$ echo -e "\033[0;31m Entrada SOA :\033[0m" && dig SOA  ${INFO_BR} +short | awk '{ print $1," ",$2}'
G_NS=$ echo -e "\n\033[0;31m Servidores DNS :\033[0m" &&  dig ns ${INFO_BR} +short 
G_IP=$ echo -e "\n\033[0;31m IP para ${DOMAIN} :\033[0m" && dig ip ${INFO_BR} +short
G_MX=$ echo -e "\n\033[0;31m Entradas MX :\033[0m" && dig mx ${INFO_BR} +short
G_TXT=$ echo -e "\n\033[0;31m Entradas SPF/TXT :\033[0m" && dig txt ${INFO_BR} +short 
G_HOST=$ echo -e "\n\033[0;31m Hostname destino :\033[0m" && host ${HOST} && echo -e "\n"
}

## nmap check
function MAP(){
if [ ! -f /usr/bin/nmap  ];then 
	echo -e "
	${FAIL} o pacote \033[1;33mnmap\033[0m não esta instalado. 
	Este podera ser instalado a partir de ums do comandos abaixo 

	  \033[0;31m -Red Hat : yum install -y namp
	   -Debian : apt-get install -y nmap\033[0m
	   "
else
	nmap ${INFO_BR}
fi
}



case $1 in
  -a) GET_ALL
  ;;
  -b) INFO_REGISTRO_BR
  ;;
 -m) MAP
  ;; 
 -h) SHOW_HELP
  ;;
  *) SHOW_HELP
  esac
