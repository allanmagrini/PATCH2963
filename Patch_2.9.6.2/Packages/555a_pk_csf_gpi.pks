create or replace package csf_own.pk_csf_gpi is

----------------------------------------------------------------------------------------------------
-- Pacote de Funções da Guia de Pagamento de Impostos         
----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------
-- Função que verifica se já existe o código identificador no banco
function fkg_exist_guiapgtoimp ( en_guiapgtoimp_id in guia_pgto_imp.id%type 
                               ) return boolean;

-----------------------------------------------------------------------
-- Função que retorna o código identificador da tabela guia_pgto_imp
function fkg_guiapgtoimp_id ( en_empresa_id           in empresa.id%type
                            , en_pessoa_id            in pessoa.id%type
                            , en_tipoimposto_id       in tipo_imposto.id%type
                            , en_tiporetimp_id        in tipo_ret_imp.id%type
                            , en_tiporetimpreceita_id in tipo_ret_imp_receita.id%type
                            , ed_dt_vcto              in guia_pgto_imp.dt_vcto%type
                            , en_notafiscal_id        in nota_fiscal.id%type   default null
                            , en_conhectransp_id      in conhec_transp.id%type default null
                            ) return guia_pgto_imp.id%type;

-----------------------------------------------------------------------
-- Função que retorna o código identificador da tabela tipo_ret_imp_receita
function fkg_tiporetimpreceita_cd ( en_tiporetimpreceita_id in tipo_ret_imp_receita.id%type
                                  ) return tipo_ret_imp_receita.cod_receita%type;

end pk_csf_gpi;
/
