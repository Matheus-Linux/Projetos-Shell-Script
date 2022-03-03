Este programa tem como função básica monitar os serviços ativos na máquina local. Ele também pode exibir mais algumas informações como: Memória RAM, Espaço utilizado em disco
e os serviços que estão ativados. 

É recomendado criar um rotacionamento do Log , para o arquivo de log do sistema não ficar muito grane e não consumir muito espaço no sistema . Abaixo segue um 
exemplo de como criar um rotacionamento de log com o logrotate do Linux. 

ROTACIONAMENTO DE LOG: 

Adicionar as seguintes linhas em /etc/logrotate.d/rsyslog 

/var/log/monitoramento.log
{
            rotate 3
            weekly
            missingok
            notifempty
            compress
            postrotate
                  /usr/lib/rsyslog/rdsyslog-rotate
            endscript
}

Essa configuração permite comprimir os logs por três semanas, depois o processo será feito novamente.
