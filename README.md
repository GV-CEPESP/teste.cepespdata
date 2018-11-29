# teste.cepespdata

O teste.cepespdata é um conjunto de funções e classes desenvolvidas em Python a fim de averiguar a consistência dos dados produzidos pelo CEPESPData. O objetivo principal do algoritmo é servir como teste automatizado para o CEPESP, mas também pode ser utilizado por outros indivíduos que desejem averiguar pessoalmente a qualidade dos nossos bancos.

## Como utilizar o teste.cepespdata?

### 1. Instale o Anaconda

O Anaconda traz o Python e os pacotes mais utilizados para análise de dados (_pandas_, _numpy_, etc.)

- [Anaconda](https://www.anaconda.com/download/#linux)

### 2. Execute o arquivo run_test.sh

Caso tenha acesso a um terminal shell execute o comando `bash run_test.sh`. 

O teste pode ser executado no próprio terminal com o comando `pytest --disable-warnings test.py > test.log`. 

Os resultados, nesse caso, serão salvos no arquivo "test.log". Você pode abri-lo com qualquer editor de texto. Fique atento para a necessidade de alterar o padrão de quebra de linha. 

## Scripts

1. script_download: realiza o _download_ dos bancos necessários para o teste.

2. script_molde: cria dois moldes a partir dos bancos baixados para serem comparados com as requisições do CEPESPData.

3. script_teste: utilizado como plataforma de teste e visualização de requisições.

3. cepespdata.py: define a classe `teste_cepespdata`, que pode ser utilizada para testar automaticamente todos os anos, cargos, agregações políticas e regionais. Deve ser requisitado como módulo como módulo: `from teste_cepespdata import teste_cepespdata`.

## Autores

- Gabriela Campos

- Rafael Coelho

- Rebeca Carvalho

## Contribuições

Contribuições externas são bem-vindas. Basta realizar um `pull request`, informando a necessidade da alteração pretendida.