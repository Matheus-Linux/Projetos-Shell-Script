Este programa tem como função básica adicionar IPs em determinadas interfaces de rede no Servidor, ou mesmo em um Desktop. Ele tembém
pode criar rotas para outras redes e exibir a tabela de roteamento do Kernel do Linux  

Recomendo a instalação do do seguinte pacote: net-tools
Instalar esse pacote pode evitar erros, caso a máquina não tenha ele instalado.

Para fazer o Script funcionar é necessário verificar se as funções de 'extglob' estão ativadas na máquina.Para realizar a consulta
pode ser feito com o seguinte comando: shopt | grep extglob .
Caso esteja com off será necessário realizar a ativação do mesmo, com o seguinte comando: shopt -s extglob 

Atenção!!! Sempre quando utilizar o "shopt" ele só irá funcionar na sessão atual do shell, ou seja, processos "filhos" do shell atual não erdam o shopt
por padrão. Para evitar este problema adicionamos o "shopt" dentro do programa.   