import pytest
import math
from teste_cepespdata import teste_cepespdata

@pytest.mark.parametrize('ano, cargo, agregacao_regional',
                         [(a,b,c) for a in range(2006,2022,4) for b in [1,3,6] for c in [6]])

def test_cepespdata(ano, cargo, agregacao_regional):
    inst = teste_cepespdata(ano, cargo, agregacao_regional = agregacao_regional, test = False)
    inst.call_teste_geral()
    
    assert inst.qtde_eleitos == inst.qtde_vagas_disponiveis
    
    assert math.isclose(inst.qtde_votos_total_1turno, inst.qtde_comparecimento_1turno, rel_tol=0.01)
    assert math.isclose(inst.qtde_votos_total_2turno, inst.qtde_comparecimento_2turno, rel_tol=0.01)
    
    if agregacao_regional == 6:
        assert inst.qtde_cidades_tse  == inst.qtde_cidades_esperadas
        assert inst.qtde_cidades_ibge == inst.qtde_cidades_esperadas   
    