#!/bin/bash
cd /home/ubuntu
sudo curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
sudo python3 get-pip.py --break-system-packages
sudo python3 -m pip install ansible --break-system-packages
tee -a playbook.yml > /dev/null << EOT
- hosts: localhost
  tasks:
  - name: Instalando o Python3 e o Virtualenv
    apt:
      pkg:
      - python3
      - virtualenv
      update_cache: yes
    become: yes

  - name: Git clone do repositório
    ansible.builtin.git:
     repo: https://github.com/guilhermeonrails/clientes-leo-api.git
     dest: /home/ubuntu/tcc
     version: master  #Esta é a branch do github que você quer clonar
     force: yes # Força a atualização do repositório se já existir

  - name: Instalando dependencias com pip (Django e Django rest)
    pip:
      virtualenv: /home/ubuntu/tcc/venv # Criando um ambiente virtual na pasta venv
      requirements: /home/ubuntu/tcc/requirements.txt # Instalando as dependências do requirements.txt
  
  - name: Configurando hosts de settings.py com Ansible # permitindo acesso externo
    lineinfile: # Modifica o arquivo settings.py para permitir acesso externo
      path: /home/ubuntu/tcc/setup/settings.py # Caminho do arquivo settings.py
      regexp: 'ALLOWED_HOSTS' # Procura a linha que começa com ALLOWED_HOSTS
      line: 'ALLOWED_HOSTS = ["*"]' # Substitui a linha por ALLOWED_HOSTS = ["*"]
      backrefs: yes #

  - name: Instalar setuptools #remenda a ausência do pacote distutils
    pip: # Usa o módulo pip para instalar pacotes Python
      name: setuptools # Nome do pacote a ser instalado
      virtualenv: /home/ubuntu/tcc/venv # Caminho do ambiente virtual

  - name: Configurando o banco de dados com Ansible
    shell: '. /home/ubuntu/tcc/venv/bin/activate; python /home/ubuntu/tcc/manage.py migrate' # Executa o comando migrate do Django dentro do ambiente virtual

  - name: Carregando os dados iniciais com Ansible
    shell: '. /home/ubuntu/tcc/venv/bin/activate; python /home/ubuntu/tcc/manage.py loaddata clientes.json' # Carrega os dados iniciais do arquivo clientes.json
  - name: Iniciando o servidor Django
    shell: '. /home/ubuntu/tcc/venv/bin/activate; nohup python /home/ubuntu/tcc/manage.py runserver 0.0.0.0:8000 &' # Inicia o servidor Django na porta 8000, permitindo acesso externo
EOT
ansible-playbook playbook.yml
