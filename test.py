import pytest
from teste_cepespdata import teste_cepespdata
#[(a,b,c) for a in range(1998,2022,4) for b in [1,3,6] for c in [1]]
@pytest.mark.parametrize('ano, cargo, agregacao_regional', [
    (2014, 1, 6),
    (2010, 1, 6),
    (2006, 1, 6),
])

def test_cepespdata(ano, cargo, agregacao_regional):
    inst = teste_cepespdata(ano, cargo, agregacao_regional = agregacao_regional)
    inst.call_teste_geral()
    
    n_eleitos(inst.qtde_eleitos, inst.qtde_vagas_disponiveis)
    
#    if agregacao_regional == 6:
#       cidades_ibge(inst.qtde_cidades_ibge, cargo)
#        
    
    
#def cidades_tse(qtde_cidades_tse, cargo):
#    if cargo == 1:
#        assert qtde_cidades_tse >= 5570
#    else:
#        assert qtde_cidades_tse == 5570

#def cidades_ibge(qtde_cidades_ibge, cargo):
#    if cargo == 1:
#        assert qtde_cidades_ibge >= 5570
#    else:
#        assert qtde_cidades_ibge == 5570

def n_eleitos(qtde_eleitos, qtde_vagas_disponiveis):
    assert qtde_eleitos == qtde_vagas_disponiveis
    
    