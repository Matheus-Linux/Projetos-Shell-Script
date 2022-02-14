#!/bin/bash

####################### VARIÁVEIS GLOBAIS DO SISTEMA ######################
SUBNET="$(cut -d" " -f2 <(grep "^subnet" "$ARQUIVO"))"                    #
NETMASK="$(cut -d" " -f4 <(grep "^subnet" "$ARQUIVO" ))"                  #      
RANGE="$(cut -d" " -f4- <(grep "range" "$ARQUIVO" ))"                     #      
GATEWAY="$(cut -d" " -f5 <(grep "routers" "$ARQUIVO"))"                   #
BROADCAST="$(cut -d" " -f5 <(grep "broadcast" "$ARQUIVO"))"               #
DNSSERVERS="$(cut -d" " -f5 <(grep "servers" "$ARQUIVO"))"                #
DOMAIN="$(cut -d" " -f5 <(sed -n '8p' "$ARQUIVO"))"                       #
LEASE="$(cut -d" " -f4 <(grep "max" "$ARQUIVO"))"                         #
MAXLEASE="$(cut -d4 <(grep "default" "$ARQUIVO"))"                        #
ARQUIVO=/etc/dhcp/dhcpd.conf                                              #
###########################################################################



#Função pergunta de usuário deseja continuar as configurações
#ou deseja voltar o menu 
function_continuar () {
dialog --stdout --title "DHCP" \
        --yesno "Deseja aplicar as configurações? " 0 0

TESTE="$(echo $?)" #Caso --yesno = sim o programa salva as configurações
[ "$TESTE" -eq 0 ] && function_salva || continue

}

#Função que salva todas as alterações realizadas no DHCP
function_salva () {
function_continuar


#Bloco while a seguir faz uma barra de progresso com o Dialog
PORCENTAGEM=0
while [[ $PORCENTAGEM -le 100 ]];
do
        #O 'echo' Joga '$PORCENTAGEM' para entrada do dialog
        echo "$PORCENTAGEM" | dialog --stdout --title "DHCP" \
        --gauge "Aplicando configurações ..." 0 0
        PORCENTAGEM=$((PORCENTAGEM +20 ))
        sleep 0.5
done

#################################################################
#Echo abaixo salva todas alterações para dentro do arquivo de   #
#configuração do DHCP. O 'echo' apaga todas as configuração     #
#enteriores no arquivo.                                         #
#################################################################                
echo "
subnet $SUBNET netmask $NETMASK {
  range $RANGE
  option routers $GATEWAY
  option broadcast-address $BROADCAST
  option subnet-mask $NETMASK
  option domain-name-servers $DNSSERVERS
  option domain-name "$DOMAIN"
  max-lease-time $MAXLEASE
  default-lease-time $LEASE
}
" > "$ARQUIVO"  #Salva alterações dentro do arquivo de DHCP
}


while true;
do      
        #Abaixo segue um menu com o dialog 
        MENU="$(dialog --stdout --title "DHCP SERVER" \
                --menu "ESCOLHA UMA OPÇÃO: " 0 0 9    \
                1 'ESCOLHA SUB-REDE'                  \
                2 'DEFINE POOL DE ENDEREÇOS'          \
                3 'DEFINE GETEWAY PADRÃO'             \
                4 'DEFINE BROADCAST DA REDE'          \
                5 'SELECIONA SERVIDORES DNS'          \
                6 'SELECIONA TEMPO DE EMPRÉSTIMO'     \
                7 'SALVAR CONFIGURAÇÕES'              \
                8 'VER CONFIGURAÇÕES'                 \
                9 'SAIR')"


        case "$MENU" in
                1)      #Essa opção altera a rede e mascara
                        
                        REDE="$(dialog --stdout --title "DHCP" \
                        --inputbox "Informe uma nova sub-rede:" 0 0)"

                        MASCARA="$(dialog --stdout --title "DHCP" \
                        --inputbox "Informe a máscara da rede: " 0 0)"
                        #Linha abaixo guarda as informações 
                        #dentro da variável $SUBNET e $NETMASK 
                        SUBNET="$REDE" ; NETMASK="$MASCARA"  
                ;;
                2)      #Essa opção seleciona os intervalos de 
                        #pool do DHCP

                        POOLINI="$(dialog --stdout --title "DHCP" \
                        --inputbox \
                        "Escolha o  inicio do pool de endereços: " 0 0)"

                        POOLFIM="$(dialog --stdout --title "DHCP" \
                        --inputbox \
                        "Escolha o fim do pool de endereços:" 0 0)"
                        #Linha abaixo guarda as informações 
                        #dentro de $RANGE 
                        RANGE="$POOLINI $POOLFIM"
                ;;
                3)      #Essa opção seleciona o gateway 
                        #padrão da rede 

                        ROUTER="$(dialog --stdout --title "DHCP" \
                        --inputbox "Defina o gateway: " 0 0)"
                        #Linha abaixo guarda as informações 
                        #dentro de $GATEWAY
                        GATEWAY="$ROUTER"
                ;;
                4)      #Essa opção faz usuário informar o 
                        #endereço broadcast da rede

                        MSG="$(dialog --stdout --title "DHCP" \
                        --inputbox "Defina o broadcast: " 0 0)"
                        #Linha abaixo guarda as informações dentro
                        #de $BROADCAST
                        BROADCAST="$MSG"
                ;;
                5)      #Essa opção faz usuário informar IP
                        #do servidor DNS e também o nome de 
                        #de domínio da rede

                        NAMESERVER="$(dialog --stdout --title "DHCP" \
                        --inputbox "Defina os IPs de DNS: " 0 0)"

                        NAME="$(dialog --stdout --title "DHCP" \
                        --inputbox "Informe o nome de dominio: " 0 0)"
                        #Linha abaixo guarda as informações de DNS 
                        #dentro de $DNSSERVER e nomes de domínio 
                        #dentro e $DOMAIN 
                        DNSSERVERS="$NAMESERVER" ; DOMAIN="$NAME"
                ;;
                6)      #Essa opção faz selecionar o tempo de 
                        #de empréstimo de endereços IPs      

                        EMPRESTIMO="$(dialog --stdout --title "DHCP" \
                        --inputbox "Defina o tempo mínimo de emprestimo: " 0 0)"

                        EMPRESTIMOMAX="$(dialog --stdout --title "DHCP" \
                        --inputbox "Defina o tempo máximo de emprestimo: " 0 0 )"
                        #Linha abaixo guarda as informações dentro de 
                        #$LEASE e $MAXLEASE
                        LEASE="$EMPRESTIMO" ; MAXLEASE="$EMPRESTIMOMAX"
                ;;
                7)      #Essa opção chama função que salva 
                        #todas as configurações 

                        function_salva
                ;;
                8)      #Essa opção exibe as informações dentro 
                        #do arquivo de configuração do DHCP 

                        dialog --stdout --title "CONFIGURAÇÕES" \
                                --textbox "$ARQUIVO" 0 0
                ;;
                9)     #Essa opção faz programa encerrar  
                
                        CONTADOR=0
                        while [ "$CONTADOR" -le 100 ];
                        do
                              echo "$CONTADOR" | dialog --stdout --title "DHCP" \
                              --gauge "Saindo..." 0 0 
                              CONTADOR=$((CONTADOR + 20 )) 
                              sleep 0.5 
                              exit 0 
                        done                      
        esac
done
