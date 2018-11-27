# teste.cepespdata

O teste.cepespdata é um conjunto de funções e classes desenvolvidas em Python a fim de averiguar a consistência dos dados produzidos pelo CEPESPData. O objetivo principal do algoritmo é servir como teste automatizado para o CEPESP, mas também pode ser utilizado por outros indivíduos que desejem averiguar pessoalmente a qualidade dos nossos bancos.

## Como utilizar o teste.cepespdata?

### Instale o Anaconda

O Anaconda traz o Python e os pacotes mais utilizados para análise de dados (_pandas_, _numpy_, etc.)

- [Anaconda](https://www.anaconda.com/download/#linux)

### Abra o jupyter notebook

No Windows, abra o programa `Anaconda` e inicie um `jupyter notebook`.

No Linux, abra um jupyter notebook mediante o comando `jupyter notebook`.

### Ordem dos Scripts

1. script_download: realiza o _download_ dos bancos necessários para o teste.

2. script_molde: cria dois moldes a partir dos bancos baixados para serem comparados com as requisições do CEPESPData.

3. script_teste: define a classe `teste_cepespdata`, que pode ser utilizada para testar automaticamente todos os anos, cargos, agregações políticas e regionais.

## Autores

- Gabriela Campos

- Rafael Coelho

- Rebeca Carvalho

## Contribuições

Contribuições externas são bem-vindas. Basta realizar um `pull request`, informando a necessidade da alteração pretendida.