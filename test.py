import pytest
import math
from teste_cepespdata import teste_cepespdata

#teste parametrizado - significa que a gente já detalha aqui todos os testes - se quiser adicionar agregação regional é só colocar o numero
@pytest.mark.parametrize('ano, cargo, agregacao_regional',
                         [(a,b,c) for a in range(2006,2022,4) for b in [1,3,6] for c in [6]])

def test_cepespdata(ano, cargo, agregacao_regional):
    inst = teste_cepespdata(ano, cargo, agregacao_regional = agregacao_regional, test = False)
    inst.call_teste_geral()
    
    #o assert é usado para fazer o teste de fato. Se der false, ele já coloca no log
    #o log para sempre no primeiro erro
    
    #primeiro teste é que eleitos tem que ser igual a vagas
    assert inst.qtde_eleitos == inst.qtde_vagas_disponiveis
    
    #segundo e terceiro testes testa se votos comparacimento está dentro de 1% - a base de referência é detalhe seção do TSE 
    assert math.isclose(inst.qtde_votos_total_1turno, inst.qtde_comparecimento_1turno, rel_tol=0.01)
    assert math.isclose(inst.qtde_votos_total_2turno, inst.qtde_comparecimento_2turno, rel_tol=0.01)
    
    #ultimo ele testa se tem todos os municipios que tem no TSE
    if agregacao_regional == 6:
        assert inst.qtde_cidades_tse  == inst.qtde_cidades_esperadas
        assert inst.qtde_cidades_ibge == inst.qtde_cidades_esperadas   
    