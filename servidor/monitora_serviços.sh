#!/bin/bash

#---------------------------------------------------------------------------------------------------------#
# - Nome: monitora_serviços.sh                                                                            #
# - Autor: Matheus Alexandre Almeida de Oliveira                                                          #
# - Mantenedor: Matheus Alexandre Almeida de Oliveira                                                     #
#                                                                                                         #
# - Descrição:                                                                                            #
#       monitora_serviços.sh - Exibe informações do estado atual dos serviços instalados no               #                                                                     
#       servidor, como: APACHE,DNS, DHCP entre outras coisas. Este programa tem como objetivo             #                                                                                                              
#       funcionar por agendamento na Crontab do Linux                                                     #
#                                                                                                         #      
# - Exemplo:                                                                                              #      
#       Criação do agendamento na Crontab do sistema                                                      #                                                   
#       Comando: crontab -e                                                                               #
#                                                                                                         #      
#       Adicionar o seguinte trecho abaixo:                                                               #      
#                                                                                                         #      
#      */5  *   *   1-12   1-5    /<seu-diretório>/monitora_serviço.sh                                    #                              
#                                                                                                         #                                                                                                                                             #                      
#      Essa linha acima cria um agendamento com o usuário atual, executando o programa à cada             #                                                                                                                   
#      5 minutos em qualquer hora, em qualquer dia do mês, de  Janeiro até Dezembro, de Segunda           #
#      até Sexta.                                                                                         #
#                                                                                                         #
#                                                                                                         #       
# - Versão:                                                                                               #
#                                                                                                         #     
#       v1.0, 23/02/2022: Matheus Alexandre                                                               #
#       - Criação inicial do monitora_serviços.sh                                                         #      
#                                                                                                         #      
#---------------------------------------------------------------------------------------------------------#


#+----------------------------------------VARIÁVEIS GLOBAIS DO SISTEMA----------------------------------+#
                                                                                                         #
BIND="$( systemctl status bind9 )"             #Filtra o serviço do DNS                                  #    
DHCP="$( systemctl status isc-dhcp-server )"   #Filtra o serviço do DHCP                                 #
APACHE="$( systemctl status apache2 )"         #Filtra o serviço do APACHE                               #
INTERFACES="$( cut -d" " -f1,8 <(ip addr s | grep -Eo "enp0s[0-9].*"))"  #Filtra as interfaces de rede   #
DISCO="$(grep "/dev/sda1" <<< $(df -Th ))"     #Filtra a partição raiz                                   #
MEM="$(free -m)"                               #Filtra uso de memória                                    #
LOG=/var/log/monitoramento.log                 #Arquivo que armazena todas as mensagens do programa      #
DIA="$(date +"%d/%m/%Y")"                      #Filtra o dia, exemplo: 20/02/2022                        #
HORA="$(date +"%H:%M")"                        #Filtra a hora, exemplo: 14:30                            #
                                                                                                         #
#+------------------------------------------------------------------------------------------------------+#


#+-----------------------------------VARIÁVEIS EXPANDIDAS---------------------------------+#
                                                                                           #     
EXTBIND=($BIND)                                 #Cria um vetor em  $BIND                   #    
EXTBIND="$(echo ${EXTBIND[15]})"                #Filtra o 15º campo da variável $BIND      #
EXTDHCP=($DHCP)                                 #Cria um vetor em   $DHCP                  #
EXTDHCP="$(echo ${EXTDHCP[15]})"                #Filtra o 15º campo da variável $DHCP      #
EXTAPACHE=($APACHE)                             #Cria um vetor em   $APACHE                #     
EXTAPACHE="$(echo ${EXTAPACHE[18]})"            #Filtra o 18º campo da variável $APACHE    #
EXTDISCO=($DISCO)                               #Cria um vetor em  $DISCO                  #
EXTDISCO="$(echo ${EXTDISCO[5]/\%/})"           #Filtra o 5º campo da variável $EXTDISCO   #
EXTMEM=($MEM)                                   #Cria um vetor em  $MEM                    #
TOTMEM="$(echo ${EXTMEM[7]})"                   #Filtra o 7º campo da variável $EXTMEM     #
USEMEM="$(echo ${EXTMEM[8]})"                   #Filtra o 8º campo da variável $EXTMEM     #
DESLIGADA="$(cat /tmp/desligada.tmp)"           #Viasualiza o arquivo 'desligada.tmp'      #
LIGADA="$(cat /tmp/ligada.tmp)"                 #Visualiza o arquivo 'ligada.tmp'          #
                                                                                           #     
#+----------------------------------------------------------------------------------------+#


#Filtra interfaces em estado "DOWN" e redireciona
grep -io ".*down" /tmp/text.tmp > /tmp/desligada.tmp
#Filtra interfaces em estado "UP" e redireciona
grep -io ".*up" /tmp/text.tmp > /tmp/ligada.tmp


#Testa se existe interfaces desligada
if grep -iq "down" /tmp/desligada.tmp; then
   echo -e "INTERFACES DESLIGADA:
   \e[31;1m$DESLIGADA\e[m" >> "$LOG" #Envia mensagem para $LOG
fi


#Testa se existe interfaces ligada
if grep -iq "up" /tmp/ligada.tmp; then
   echo -e "INTERFACES UP:
   \e[34;1m$LIGADA\e[m" >> "$LOG"    #Envia mensagem para $LOG
fi


#Testa se BIND está ativo
[[ "$EXTBIND" == "active" ]] && \
        echo -e "[$DIA] \e[34;1mSERVIÇO DE DNS ATIVADO\e[m [$HORA]" \
        >> "$LOG" \ #Envia mensagem para $LOG
        || echo -e "[$DIA] \e[31;1mSERVIÇO DE DNS DESATIVADO\e[m [$HORA]" \
        >> "$LOG"   #Envia mensagem para $LOG

#Testa se DHCP está ativo
[[ "$EXTDHCP" == "active" ]] && \
        echo -e "[$DIA] \e[34;1mSERVIÇO DHCP ATIVADO\e[m [$HORA]" \
        >> "$LOG" \ #Envia mensagem para $LOG
        || echo -e "[$DIA] \e[31;1mSERVIÇO DHCP DESATIVADO\e[m [$HORA]" \
        >> "$LOG"   #Envia mensagem para $LOG


#Testa se APACHE está ativo 
[[ "$EXTAPACHE" == "active" ]] && \
        echo -e "[$DIA] \e[34;1mServiço HTTP ativado\e[m [$HORA]" \
        >> "$LOG" \ #Envia mensagem para $LOG
        || echo -e "[$DIA] \e[31;1mServiço HTTP desativado\e[m [$HORA]" \
        >> "$LOG"   #Envia mensagem para $LOG


#Testa se Partição raiz chegou a 80% de uso
[[ "$EXTDISCO" -ge 80 ]] && \
        echo -e "[$DIA] \e[31;1mATENÇÃO! Disco ultrapassou o limite de 80%\e[m" \
        [$HORA] >> "$LOG" \
        || echo -e "[$DIA] \e[34;1mDisco do sistema está com $EXTDISCO% de uso\e[m" \
         [$HORA] >> "$LOG"


#Testa se Memória está com 100% de uso  
[[ "$TOTMEM" -eq "$USEMEM" ]] && \
        echo -e "[$DIA] \e[31;1ATENÇÃO! MEMÓRIA ATINGIU O LIMITE DE 100%\e[m" \ #Envia mensagem de aviso para $LOG
        >> "$LOG" \
        || tr -s \r " " <<< $(echo -e    \  #Apaga os TABs e envia para o comando 'tr'
          "\e[34;1mMEMÓRIA TOTAL:        \
           \e[m\e[33;1m[$TOTMEM]\e[m     \
           \e[34;1mUSO ATUAL DE MEMÓRIA: \
           \e[m \e[33;1m[$USEMEM]\e[m [$HORA] ") >> "$LOG"  #Envia mensagem para $LOG
