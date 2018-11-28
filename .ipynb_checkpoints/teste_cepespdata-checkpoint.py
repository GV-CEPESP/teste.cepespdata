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
import requests
import os

class teste_cepespdata:
    ############################################################################
    ############################################################################
    ## 1. Construtor
    def __init__(self, ano, cargo, agregacao_politica = 2, agregacao_regional = 0, test = False):
        
        if test:
            self.u0 = "http://test.cepesp.io/api/consulta/"
        else:
            self.u0 = 'http://cepesp.io/api/consulta/'
            
        self.ano = str(ano)
        self.cargo = str(cargo)
        self.agregacao_politica = str(agregacao_politica)
        self.agregacao_regional = str(agregacao_regional)
        self.download_candidatos()
        self.download_eleicoes()
    
    ############################################################################
    ############################################################################
    # 2. Funções para Download dos Bancos
    
    def download_eleicoes(self):
        colunas = 'c[]=ANO_ELEICAO&c[]=NUM_TURNO&c[]=COD_MUN_TSE&c[]=COD_MUN_IBGE&c[]=NOME_MUNICIPIO&c[]=UF&c[]=CODIGO_CARGO&c[]=DESCRICAO_CARGO&c[]=NOME_CANDIDATO&c[]=NUMERO_CANDIDATO&c[]=CPF_CANDIDATO&c[]=DES_SITUACAO_CANDIDATURA&c[]=NUMERO_PARTIDO&c[]=SIGLA_PARTIDO&c[]=NUM_TITULO_ELEITORAL_CANDIDATO&c[]=QTDE_VOTOS'
        u0 = self.u0 + "/tse?format=csv&cargo=" + \
                self.cargo + "&anos[]=" + \
                self.ano+"&agregacao_regional=" + \
                self.agregacao_regional+"&agregacao_politica=" + \
                self.agregacao_politica+"&brancos=1&nulos=1&" +\
                colunas
        
        eleicoes_df = pd.read_csv(u0, sep = ",", dtype = {'num_titulo_eleitoral_candidato': str,
                                                          'cpf_candidato': str})
        self.banco_eleicoes = eleicoes_df
        
    def download_candidatos(self):
        u0 = self.u0 + "candidatos?format=csv&cargo="+self.cargo+"&anos[]="+self.ano
        candidatos_df = pd.read_csv(u0, sep = ',',  dtype = {'num_titulo_eleitoral_candidato': str,
                                                             'cpf_candidato': str})
        self.banco_candidatos = candidatos_df
    
    ############################################################################
    ############################################################################
    # 3. Funções para Testes Específicos
    
    ## 3.1. Votos Brancos e Nulos
    def teste_total_votos(self):
        banco = self.banco_eleicoes
        qtde_votos_total_1turno = banco[banco.num_turno == 1][['qtde_votos']].sum()
        qtde_votos_total_2turno = banco[banco.num_turno == 2][['qtde_votos']].sum()
        self.qtde_votos_total_1turno = int(qtde_votos_total_1turno)
        self.qtde_votos_total_2turno = int(qtde_votos_total_2turno)
        
    def teste_votos_brancos_nulos(self):
        banco = self.banco_eleicoes
        banco = banco[banco.num_turno == 1]
        
        qtde_votos_brancos = banco[banco.numero_candidato == 95].qtde_votos.sum()
        qtde_votos_nulos = banco[banco.numero_candidato == 96].qtde_votos.sum()
        
        brancos = qtde_votos_brancos / self.qtde_votos_total_1turno
        nulos = qtde_votos_nulos / self.qtde_votos_total_1turno
        
        self.prop_votos_brancos = brancos
        self.prop_votos_nulos = nulos

    ## 3.2. Votos Legenda - Proporção de votos legenda
    def teste_voto_legenda(self):
        banco = self.banco_eleicoes
        banco = banco[banco.num_turno == 1]
        
        numero_legendas = range(10,91) # partidos entre 10 e 90 inclusivo

        qtde_votos_legenda = banco[np.in1d(banco.numero_candidato, numero_legendas)].qtde_votos.sum()
        prop_votos_legenda = qtde_votos_legenda / self.qtde_votos_total_1turno
        
        self.qtde_votos_legenda =  qtde_votos_legenda
        self.prop_votos_legenda = prop_votos_legenda

    ## 3.3. Número de Cidades Únicas
    def teste_cidades(self):
        banco = self.banco_eleicoes
        
        n_unique_ibge = len(set(banco.cod_mun_ibge))
        n_unique_tse = len(set(banco.cod_mun_tse))
        
        self.qtde_cidades_ibge = n_unique_ibge
        self.qtde_cidades_tse = n_unique_tse

    ## 3.4. Proporção de CPFs e Títulos Válidos
    def teste_cpf_titulos(self):
        banco = self.banco_eleicoes
        
        len_titulo = [(lambda x: len(str(x)))(x) for x in banco.num_titulo_eleitoral_candidato]
        len_cpf = [(lambda x: len(str(x)))(x) for x in banco.cpf_candidato]
        prop_titulo = sum(np.array(len_titulo) == 12) / len(len_titulo)
        prop_cpf    = sum(np.array(len_cpf) == 11) / len(len_cpf)
        
        self.prop_titulo_validos = prop_titulo
        self.prop_cpf_validos = prop_cpf
    
    ## 3.5. (ALFA) TESTE DO NÙMERO TOTAL DE VOTOS
    def teste_votos(self):
        pass
    
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
        if self.agregacao_regional == 6: # Teste n de cidades apenas se agreg. reg. for municipal
            self.teste_cidades()
    
    ## 4.2. Teste para o Banco de Candidatos
    def call_teste_candidatos(self):
        self.teste_eleitos()
    
    ## 4.3. Teste para todos os bancos definidos
    def call_teste_geral(self):
        print("Starting test...\nyear: " + self.ano + "\nposition: " + self.cargo)
        
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