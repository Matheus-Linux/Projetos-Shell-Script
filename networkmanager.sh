#!/bin/bash


<<<<<<< HEAD
=======
#---------------------------------------------------------------------------------------------------------#
# - Nome: networkmanager.sh                                                                               #
# - Autor: Matheus Alexandre Almeida de Oliveira                                                          #
# - Mantenedor: Matheus Alexandre Almeida de Oliveira                                                     #
#                                                                                                         #
# - Descrição: networkmanager.sh - Exibe informações sobre tabela de roteamento, Interfaces ativas        #
#   e dasativadas na máquina. Pode criar rotas para outras máquinas em redes remotas, e adicionar IP      #
#   em interfaces desejadas.                                                                              #       
#                                                                                                         #                      
#                                                                                                         #
# - Exemplo:                                                                                              #      
#                                                                                                         #      
#   R  -   Adiciona Rota                                                                                  #
#   A  -   Adiciona IP                                                                                    #      
#   rr -   Remove IP                                                                                      #      
#   D  -   Adciona DNS                                                                                    #
#                                                                                                         #      
#   "Escolha uma opção:"                                                                                  #
#                                                                                                         #      
#   Opção = VALOR                                                                                         #
#                                                                                                         #      
# - Versão:                                                                                               #
#                                                                                                         #     
#       v1.0, 11/01/2022: Matheus Alexandre                                                               #
#       - Criação inicial do networkmanager.sh                                                            #      
#                                                                                                         #      
#---------------------------------------------------------------------------------------------------------#
>>>>>>> d0d2247aa2b697e9ff5aa4c7fb469204859597fd


#----------------------------------------------------------------VARIAVEIS GLOBAIS-------------------------------------------------------------------#
shopt -s &>-    #Ativa funções extglob
TABELA="$( tr a-z A-Z  <(ip route))" #Exibe tabela de toteamento
INT="$(ip link show | sed -n /'enp0s[0-9]'/p | sed s/'<.*state'//g | sed s/'mode.*'//g <(sed  s/^[0-9]://g))"  #Exibe todas as interfaces do sistema

#-----------------------------------------------------------------------------------------------------------------------------------------------------#


#---------------------------------------------------------------------------------------------------------#
# - Nome: networkmanager.sh                                                                               #
# - Autor: Matheus Alexandre Almeida de Oliveira                                                          #
# - Mantenedor: Matheus Alexandre Almeida de Oliveira                                                     #
#                                                                                                         #
# - Descrição: networkmanager.sh - Exibe informações sobre tabela de roteamento, Interfaces ativas        #
#   e dasativadas na máquina. Pode criar rotas para outras máquinas em redes remotas, e adicionar IP      #
#   em interfaces desejadas.                                                                              #       
#                                                                                                         #                      
#                                                                                                         #
# - Exemplo:                                                                                              #      
#                                                                                                         #      
#   R  -   Adiciona Rota                                                                                  #
#   A  -   Adiciona IP                                                                                    #      
#   rr -   Remove IP                                                                                      #      
#   D  -   Adciona DNS                                                                                    #
#                                                                                                         #      
#   "Escolha uma opção:"                                                                                  #
#                                                                                                         #      
#   Opção = VALOR                                                                                         #
#                                                                                                         #      
# - Versão:                                                                                               #
#                                                                                                         #     
#       v1.0, 11/01/2022: Matheus Alexandre                                                               #
#       - Criação inicial do networkmanager.sh                                                            #
#                                                                                                         #
#        v1.1, 01/03/2022: Matheus Alexandre                                                              #      
#       - Adicionada opção de DNS                                                                         #      
#---------------------------------------------------------------------------------------------------------#


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
REDE="$(ip addr s | sed -n /inet[^inet6].*/p | sed s/'s.*'//g <(sed s/"inet"/"ip interno"/g))"
REDE="$(echo ${REDE^^})"                  #Exibe todo conteúdo de rede em caixa alta             
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
                        [[ "$CONTINUAR" == @(N|NAO|NÃO|NO|) ]] &&               #Testa se usuário deseja  continuar
                                echo "Voltando..." && sleep 3                   
                        [[ "$CONTINUAR" == @(S|SIM|Y|YES) ]] &&
                                echo "Aplicando as configurações..." && sleep 3
                                ip route add "$DESTIP$CIDR" via "$VIZINHO"      #Essa linha adiciona rota ao sistema

                done

        ;;
        #Opçao A seleciona e adiciona IP em uma determina interface selecionada 
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
        #Opção r remove endereço IP de uma determinada interface
        r)
                clear
                CONTINUAR="N"
                while [ "$CONTINUAR" = "N" ];
                do
                        function_rede
                        read -p "Informe o IP que deseja remover: " IPREMOVE
                        read -p "Informe a Interface que está associoado o IP: " ETH
                        #Bloco IF testa se IP existe no sistema
                        if echo "$REDE" | grep -qo "$IPREMOVE"; then
                                MASK="$(function_rede | grep "$IPREMOVE")"
                                VETOR=($MASK)                #Expande a variável $MASK     
                                VETOR=$(echo ${VETOR[2]:12}) #Filtra a penas o CIDR
                                read -p "Deseja aplicar as configurações?"  CONFIGURE
                                CONFIGURE="$(echo ${CONFIGURE^^})"
                                [[ "$CONFIGURE" == @(S|SIM|YES|Y) ]] &&
                                        for cont in $(seq 1 4)
                                        do
                                                echo -en "Aplicando configurações..."
                                                sleep 0.5
                                                echo -en "$cont"\r\r
                                        done
                                        ip addr del "$IPREMOVE$VETOR" dev "$ETH"
                                        CONTINUAR="S"
                                [[ "$CONFIGURE" == @(N|NO|NAO) ]] &&
                                        CONTINUAR="N"
                        else
                                echo -e "\e[31;1mIP não consta no sistema!\e[m"
                                sleep 0.5
                                CONTINUAR="N"
                        fi
                done
        ;;
        #Opção v exibe os endereços IP da máquina 
        v)
                LOOP="S"
                #Repete o laço até variável $LOOP !=S
                while  [ "$LOOP" = "S" ]
                do
                        for cont in $(seq 1 5)
                        do
                                echo -en "Exibindo informações de IP..."
                                sleep 0.5
                                echo -en "$cont\r\r"
                        done
                        function_rede
                        #Testa se usuário deseja ver informações de IP
                        read -p "Deseja ver novamente os IPs ? [s] [n]: " CONTINUA
                        CONTINUA="$(echo ${CONTINUA^^})" #Expande a variável $CONTINUA 
                        [[ "$CONTINUA" == @(S|SIM|Y|YES) ]] &&  LOOP="S" || LOOP="N"
                done
        ;;
        #Opção D permite adicionar Servidores DNS no sistema
        D)      
                ERRO="S"
                while [ "$ERRO" = "S" ];
                do
                        clear
                        echo "Exibindo Lista de DNS..." && sleep 3
                        while read ARQUIVO;  #Lê conteúdo de /etc/resolv.conf
                        do
                                echo "$ARQUIVO"
                                sleep 1
                        done  <<< $(grep -o "nameserver".* /etc/resolv.conf)  #Passa o conteúdo do arquivo para a variável
                        read -p "Deseja adicinar um novo DNS? (s/n)" RESP     #$ARQUIVO
                        RESP="$(echo ${RESP^^})"
                        if [[ "$RESP" == @(S|SIM|Y|YES) ]]; then
                                clear
                                echo "Continuando..." && sleep 2
                                read -p "Informa o novo DNS:" DNS
                                if grep -q "$DNS" /etc/resolv.conf; then      #Testa de DNS existe 
                                        echo -e "\e[31;1mErro! Endereço já existe.\e[m"
                                        sleep 3
                                        ERRO="S"
                                else
                                        echo "nameserver $DNS" >> /etc/resolv.conf  #Adiciona DNS ao arquivo
                                        ERRO="S"
                                fi
                        else
                                ERRO="N"
                        fi
                done
        ;;
        #Opção S Encerra o programa 
        S)
                read -p "Deseja mesmo sair? [s] [n] " SAIR
                SAIR="$(echo ${SAIR^^} )"
                [[ "$SAIR" == @(S|SIM|YES|Y) ]] &&
                        echo "Encerrando..." ; sleep 3
                        exit 0
                [[ "$SAIR" == @(N|NAO|N|NO|NÃO) ]] &&
                        continue
        ;;
esac
done