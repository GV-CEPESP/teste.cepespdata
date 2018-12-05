###################################################################################
#      Classe teste_cepespdata
#
#
#
#
#
#
#
###################################################################################

import pandas as pd
import numpy as np
import os

class teste_cepespdata:
    ############################################################################
    ############################################################################
    ## 1. Construtor
    def __init__(self, ano, cargo, agregacao_politica = 2, agregacao_regional = 0, test = False):
        print("Ano: {}\nCargo: {} \nBanco Teste: {}\n".format(ano, cargo, test))
        
        if test:
            self.u0 = "http://test.cepesp.io/api/consulta/"
        else:
            self.u0 = 'http://cepesp.io/api/consulta/'
            
        self.ano = str(ano)
        self.cargo = str(cargo)
        self.agregacao_politica = str(agregacao_politica)
        self.agregacao_regional = str(agregacao_regional)
        
        self.create_requests()
    
    ############################################################################
    ############################################################################
    # 2. Funções para Download dos Bancos
    
    def create_requests(self):
        url_eleicoes = self.u0 + "tse?format=csv&cargo=" + \
                       self.cargo + "&anos[]=" + \
                       self.ano+"&agregacao_regional=" + \
                       self.agregacao_regional+"&agregacao_politica=" + \
                       self.agregacao_politica+"&brancos=1&nulos=1&"
        
        self.url_eleicoes = url_eleicoes
        
        url_candidatos = self.u0 + "candidatos?format=csv&cargo="+self.cargo+"&anos[]="+self.ano
        
        self.url_candidatos = url_candidatos
        
        url_votos = self.u0 + "votos?format=csv&brancos=1&nulos=1" +\
                              "&anos="+self.ano + \
                              "&cargo="+self.cargo + \
                              "&agregacao_regional"+self.agregacao_regional
        
        self.url_votos = url_votos
        
        url_coligacao = self.u0 + "legendas?format=csv&cargo="+self.cargo+"&anos[]="+self.ano
        
        self.url_coligacao = url_coligacao
    
    def download_eleicoes(self):
        print("Downloading Eleições - BETA...")
                
        eleicoes_df = pd.read_csv(self.url_eleicoes, sep = ",", 
                                  dtype = {'num_titulo_eleitoral_candidato': str,
                                           'cpf_candidato': str})
        
        self.banco_eleicoes = eleicoes_df
        
    def download_candidatos(self):
        print("Downloading Candidatos...")
        
        candidatos_df = pd.read_csv(self.url_candidatos, sep = ',',  
                                    dtype = {'num_titulo_eleitoral_candidato': str,
                                             'cpf_candidato': str})
        
        self.banco_candidatos = candidatos_df
    
    ############################################################################
    ############################################################################
    # 3. Funções para Testes Específicos
    
    ## 3.1. Votos Brancos e Nulos
    def teste_total_votos(self):
        banco = self.banco_eleicoes
        qtde_votos_total_1turno = banco[banco.NUM_TURNO == 1][['QTDE_VOTOS']].sum()
        qtde_votos_total_2turno = banco[banco.NUM_TURNO == 2][['QTDE_VOTOS']].sum()
        self.qtde_votos_total_1turno = int(qtde_votos_total_1turno)
        self.qtde_votos_total_2turno = int(qtde_votos_total_2turno)
        
    def teste_votos_brancos_nulos(self):
        banco = self.banco_eleicoes
        banco = banco[banco.NUM_TURNO == 1]
        
        qtde_votos_brancos = banco[banco.NUMERO_CANDIDATO == 95].QTDE_VOTOS.sum()
        qtde_votos_nulos = banco[banco.NUMERO_CANDIDATO == 96].QTDE_VOTOS.sum()
        
        brancos = qtde_votos_brancos / self.qtde_votos_total_1turno
        nulos = qtde_votos_nulos / self.qtde_votos_total_1turno
        
        self.prop_votos_brancos = brancos
        self.prop_votos_nulos = nulos

    ## 3.2. Votos Legenda - Proporção de votos legenda
    def teste_voto_legenda(self):
        banco = self.banco_eleicoes
        banco = banco[banco.num_turno == 1]
        
        numero_legendas = range(10,91) # partidos entre 10 e 90 inclusivo

        qtde_votos_legenda = banco[np.in1d(banco.NUMERO_CANDIDATO, numero_legendas)].QTDE_VOTOS.sum()
        prop_votos_legenda = qtde_votos_legenda / self.qtde_votos_total_1turno
        
        self.qtde_votos_legenda =  qtde_votos_legenda
        self.prop_votos_legenda = prop_votos_legenda

    ## 3.3. Número de Cidades Únicas
    def teste_cidades(self):
        banco = self.banco_eleicoes
        
        molde = pd.read_csv('data/moldes/molde_cidades.csv')
    
        
        qtde_cidades_esperadas = molde[(molde.ano_eleicao == int(self.ano)) & (molde.codigo_cargo == int(self.cargo))][['codigo_municipio']]
        
        qtde_cidades_esperadas = int(qtde_cidades_esperadas.iloc[0])
        
        n_unique_ibge = len(set(banco.COD_MUN_TSE))
        n_unique_tse = len(set(banco.COD_MUN_TSE))
        
        self.qtde_cidades_ibge = n_unique_ibge
        self.qtde_cidades_tse = n_unique_tse
        self.qtde_cidades_esperadas = qtde_cidades_esperadas
        
    def teste_ufs(self):
        molde = pd.read_csv("data/moldes/molde_secao.csv")
        molde = molde[(molde.ano_eleicao == int(self.ano)) & (molde.codigo_cargo == int(self.cargo))]
        
        self.qtde_ufs_esperada = sum(np.unique(molde.UF) != "VT") # Exclui voto em trânsito
        self.qtde_ufs = len(set(self.banco_eleicoes.UF))

    ## 3.4. Proporção de CPFs e Títulos Válidos
    def teste_cpf_titulos(self):
        banco = self.banco_eleicoes
        
        len_titulo = [(lambda x: len(str(x)))(x) for x in banco.NUM_TITULO_ELEITORAL_CANDIDATO]
        len_cpf = [(lambda x: len(str(x)))(x) for x in banco.CPF_CANDIDATO]
        prop_titulo = sum(np.array(len_titulo) == 12) / len(len_titulo)
        prop_cpf    = sum(np.array(len_cpf) == 11) / len(len_cpf)
        
        self.prop_titulo_validos = prop_titulo
        self.prop_cpf_validos = prop_cpf
    
    ## 3.5. (ALFA) TESTE DO NÙMERO TOTAL DE VOTOS
    def teste_votos(self):
        molde = pd.read_csv("data/moldes/molde_secao.csv")
        
        qtde_aptos_1turno = molde[(molde.ano_eleicao == int(self.ano)) & (molde.codigo_cargo == int(self.cargo)) & (molde.num_turno == 1)][['qtd_aptos']].sum()
        
        qtde_comparecimento_1turno = molde[(molde.ano_eleicao == int(self.ano)) & (molde.codigo_cargo == int(self.cargo)) & (molde.num_turno == 1)][['qtd_comparecimento']].sum()
        
        qtde_aptos_2turno = molde[(molde.ano_eleicao == int(self.ano)) & (molde.codigo_cargo == int(self.cargo)) & (molde.num_turno == 2)][['qtd_aptos']].sum()
        
        qtde_comparecimento_2turno = molde[(molde.ano_eleicao == int(self.ano)) & (molde.codigo_cargo == int(self.cargo)) & (molde.num_turno == 2)][['qtd_comparecimento']].sum()

        self.qtde_aptos_1turno = int(qtde_aptos_1turno)
        self.qtde_comparecimento_1turno = int(qtde_comparecimento_1turno)
        self.qtde_aptos_2turno = int(qtde_aptos_2turno)
        self.qtde_comparecimento_2turno = int(qtde_comparecimento_2turno)
        
    def teste_votos_uf(self):
        molde = pd.read_csv("data/moldes/molde_secao.csv")
        molde = molde[(molde.ano_eleicao == int(self.ano)) & (molde.codigo_cargo == int(self.cargo))]

        qtde_votos_uf_comparecimento = molde[['ano_eleicao', 'num_turno', 'uf', 'qtd_comparecimento']].groupby(['ano_eleicao', 'num_turno', 'uf']).sum()
        qtde_votos_uf_aptos = molde[['ano_eleicao', 'num_turno', 'uf', 'qtd_aptos']].groupby(['ano_eleicao', 'num_turno', 'uf']).sum()
                
        qtde_votos_uf = self.banco_eleicoes[['ano_eleicao', 'num_turno', 'uf', 'qtde_votos']].groupby(['ano_eleicao', 'num_turno', 'uf']).sum()
                
        self.qtde_votos_uf =  qtde_votos_uf.join(qtde_votos_uf_aptos).join(qtde_votos_uf_comparecimento)
            
    ## 3.6. Quantidade de Eleitos e de Vagas
    def teste_eleitos(self):
       
        valores_eleitos = "ELEITO", 'ELEITO POR QP', 'ELEITO POR MÉDIA'
        qtde_eleitos = sum(np.in1d(self.banco_candidatos.DESC_SIT_TOT_TURNO, valores_eleitos))
        
        molde = pd.read_csv("data/moldes/molde_vagas.csv")
        vagas = molde[(molde.ANO_ELEICAO == int(self.ano)) & (molde.CODIGO_CARGO == int(self.cargo))][['QTDE_VAGAS']].sum()[0]
        
        self.qtde_vagas_disponiveis = vagas
        self.qtde_eleitos = qtde_eleitos 
    
    ############################################################################
    ############################################################################
    # 4. Funções para Chamar mais de teste
    
    ## 4.1. Teste para o Banco de Eleições
    def call_teste_eleicoes(self):
        self.teste_total_votos()
        self.teste_votos_brancos_nulos()
        self.teste_cpf_titulos()
        self.teste_voto_legenda()
        self.teste_votos()
        
        # Testes de acordo com agregacao regional
        if int(self.agregacao_regional) >= 2:
            self.teste_votos_uf()
            self.teste_ufs()
            
        if int(self.agregacao_regional) >= 6: 
            self.teste_cidades()
    
    ## 4.2. Teste para o Banco de Candidatos
    def call_teste_candidatos(self):
        self.teste_eleitos()
    
    ## 4.3. Teste para todos os bancos definidos
    def call_teste_geral(self): 
        print("Starting test...")
        if not hasattr(self, 'banco_eleicoes'):
            self.download_eleicoes()
        if not hasattr(self, 'banco_candidatos'):
            self.download_candidatos()
            
        self.call_teste_eleicoes()
        self.call_teste_candidatos()
    
    ############################################################################
    ############################################################################
    # 5. Estrutura do print
    def __str__(self):
        texto = '''
ANO: {}, CARGO: {}

** BANCO ELEICOES - BETA

Proporção Branco: {:.2f}
Proporção Nulos: {:.2f}

Proporção de CPF com 11 dígitos: {:.2f}
Proporção de títulos com 12 dígitos: {:.2f}

Proporção de votos em legenda: {:.2f}

Total de Votos - 1º Turno: {}
Total de Votos - 2º Turno: {}

** BANCO CANDIDATOS

Vagas: {}
Eleitos: {}
'''
        print_out = texto.format(self.ano, 
                                 self.cargo,
                                 self.prop_votos_brancos,
                                 self.prop_votos_nulos,
                                 self.prop_cpf_validos,
                                 self.prop_titulo_validos,
                                 self.prop_votos_legenda,
                                 self.qtde_votos_total_1turno,
                                 self.qtde_votos_total_2turno,
                                 self.qtde_vagas_disponiveis,
                                 self.qtde_eleitos)
        return print_out