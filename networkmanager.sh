#!/bin/bash


#----------------------------------------------------------------VARIAVEIS GLOBAIS-------------------------------------------------------------------#
shopt -s &>-    #Ativa funções extglob
TABELA="$( tr a-z A-Z  <<< "$(ip route)")" #Exibe tabela de toteamento
INT="$(ip link show | sed -n /'enp0s[0-9]'/p | sed s/'<.*state'//g | sed s/'mode.*'//g | sed  s/^[0-9]://g)"  #Exibe todas as interfaces do sistema

#------------------------------------------------------------------------------------------------------------------------------------------------------#


#Função exibe estado das interfaces, Ex: on/off
function_interfaces () {
clear
#Testa se existe alguma interce em estado DOWN
if grep -qi "down" <<< "$(ip link show)"; then
        echo -e "\e[31;1mATENÇÃO!!! Existe interfaces desativadas.\e[m"
        echo -e "\e[33;1m$INT\e[m"
        read -p "Deseja ativar alguma interface? " ATIVAR
        ATIVAR=$(echo ${ATIVAR^^})
        [[ "$ATIVAR" == @(S|Y|SIM|YES) ]] &&  #Estrutura test que seleciona opções informadas
                CONFIRMA="N"
                while [ "$CONFIRMA" = "N" ];
                do
                        clear && echo "$INT"
                        read -p "Selecione uma interface para ativação:" IFACE
                        read -p "Deseja confirmar? [S/N] " CONFIRMA
                        CONFIRMA="$(echo ${CONFIRMA^^})"
                done
                echo "Aplicando configurações..."
                sleep 3
                ip link set "$IFACE" up   #Ativa a interface
                function_interfaces
else
        echo "$INT"
fi
}


#Função exibe todos IPs da máquina
function_rede () {
REDE="$(ip addr s | sed -n /inet[^inet6].*/p | sed s/'s.*'//g | sed s/"inet"/"ip interno"/g)"
REDE="$(tr a-z A-Z <<< $REDE )"
echo -e "\e[31;1m------Lista de IPs da máquina------\e[m
\e[34;1m$REDE\e[m"
}


#Função exibe tabela de roteamento
function_tabela () {
for cont in  "$(seq 0 4)" #Contador de 4 segundos
do
        echo -en "Carregando tabela de roteamento..."
        sleep 0.5
        echo -en "\e[31;1m$cont\e[m\r"
done
echo -e "\e[31;1m---Tabela de roteamento do Kernel----\e[m
\e[34;1m$TABELA\e[m"
}


while true;
do

clear
echo -e "\e[33;1m
- R     Adiciona Rota
- A     Adiciona IP
- rr    Remove IP
- D     Adciona DNS
\e[m"

read -p "Escolha uma opção:"  ESCOLHA
case "$ESCOLHA"  in
        #Opção abaixo adiciona uma nova rota ao sistema        
        R)
                CONTINUAR="N"
                while [ "$CONTINUAR" = "N" ];                                   #Continua até usuário selecionar SIM 
                do
                        clear
                        function_tabela
                        read -p "Informe a rede de destino: "  DESTIP
                        read -p "Informe o CIDR da rede. Ex: /24, /25: "  CIDR
                        echo "$"
                        read -p "Informe a rede conectado ao neighbor: "  VIZINHO
                        read -p "Deseja adicionar a rota? [s] [n] " CONTINUAR
                        CONTINUAR=$(echo ${CONTINUAR^^} )                       #Deixa tudo em caixa alta
                        [[ "$CONTINUAR" == @(N|NAO|NÃO|NO|) ]] &&               #Testa se usuário desaja  continuar
                                echo "Voltando..." && sleep 3                   
                        [[ "$CONTINUAR" == @(S|SIM|Y|YES) ]] &&
                                echo "Aplicando as configurações..." && sleep 3
                                ip route add "$DESTIP$CIDR" via "$VIZINHO"      #Essa linha adiciona rota ao sistema

                done

        ;;
        #Opçao A seleciona adiciona IP em uma determina interface selecionada 
        A)
                CONFIRMAR="N"
                while [ "$CONFIRMAR" = "N" ];
                do
                        function_interfaces
                        function_rede
                        read -p "Selecione um novo IP: " IP
                        read -p "Selecione o CIDR. Ex: /24, /25: " CIDR
                        echo "$INT"
                        read -p "Escolha uma interface: " IFACE
                        read -p "Deseja confirmar ou cancelar? [S] [N] [C] " CONFIRMAR
                        CONFIRMAR="$(echo ${CONFIRMAR^^})"                      #Deixa tudo em caixa alta 
                        #Condição test que confirma a adição do IP
                        [[ "$CONFIRMAR" == @(S|SIM|YES|Y) ]] &&
                                echo "Aplicando configurações..." && sleep 3
                                ip addr add "$IP$CIDR $IFACE"                   #Adiciona IP dentro da interface 
                        [[ "$CONFIRMAR" == @(C|CANCEL|CANCELAR) ]] &&           #Test se usuário quer cancelar operação
                                echo "Operação cancelada!"

                done

        ;;
esac
done

