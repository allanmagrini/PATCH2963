create or replace package csf_own.pk_csf_efd is

-------------------------------------------------------------------------------------------------------
--
-- Em 03/03/2021  - Allan Magrini - 2.9.5.6 / 2.9.6-3 / 2.9.7
-- Redmine #76715 - Valida��o incorreta - Inf. Valor Declarat�rio
-- Rotina Alterada: - fkg_cod_inf_adic_id, alterado o select e adicionada a condi��o (upper(co.id)   = upper(ev_cod_inf) or upper(co.cod_inf_adic) = upper(ev_cod_inf))  
--  
-- Em 31/08/2020  - Wendel Albino - 2.9.5
-- Redmine #69348 - Inclus�o de campo COD_INF_ADIC_VL_DECL (cBenef)
-- Rotinas Novas: - fkg_cod_inf_adic_id / fkg_cod_inf_adic_cod_inf criacao de novas funcoes que retornam id e cod da tabela COD_INF_ADIC_VL_DECL 
--  
-----------------------------------------------------------------------------------------
-- Em 18/02/2013 - Angela In�s.
-- Corrigida a fun��o que recupera o identificador da vers�o de layout.
-- Rotina: fkg_versao_layout_efd_id.
--
-- Em 14/03/2014 - Angela In�s.
-- Corre��o nos par�metros de entrada das fun��es, utilizando ID e n�o COD_AJ.
-- Rotinas: fkg_cod_ocor_aj_icms_cod_aj, fkg_cod_ocor_aj_icms_ref_apur, fkg_cod_ocor_aj_icms_tp_apur, fkg_cod_ocor_aj_icms_resp, fkg_cod_ocor_aj_icms_infl.
--
-- Em 09/04/2014 - Angela In�s.
-- Redmine #2505 - Altera��o da Gera��o do arquivo do Sped ICMS/IPI.
-- Inclus�o da fun��o que retorna o c�digo do ajuste da tabela COD_AJ_SALDO_APUR_ICMS atrav�s do identificador.
-- Rotina: fkg_cod_codajsaldoapuricms.
--
-- Em 08/04/2015 - Angela In�s.
-- Redmine #6716/#5706 - Atualiza��o Escritura��o Fiscal Digital - EFD.
-- Incluir fun��o para recuperar o c�digo IPM (�ndice de participa��o dos munic�pios) relacionado com empresa e item/produto.
-- Rotina: fkg_recup_cod_ipm_item.
--
-- Em 05/06/2015 - Angela In�s.
-- Redmine #8543 - Processos que utilizam as tabelas de c�digos de ajustes para Apura��o do ICMS.
-- Incluir as datas inicial e final na fun��o que recupera o ID do c�digo de ajuste de apura��o de icms atrav�s do c�digo.
-- Rotina: fkg_cod_aj_saldo_apur_icms_id e fkg_cod_ocor_aj_icms_id.
-- Incluir as datas inicial e final na fun��o que recupera o ID do c�digo de ocorr�ncia de ajuste de apura��o de icms atrav�s do c�digo.
-- Rotina: fkg_cod_ocor_aj_icms_id.
--
-- Em 05/02/2019 - Angela In�s.
-- Redmine #51225 - Considerar o C�digo (CD) da vers�o para recuperar o Identificador da Vers�o de leiaute, e Verificar as mensagens/logs.
-- Recuperar o C�digo (CD) da vers�o, para recuperar o Identificador da Vers�o de leiaute, no momento da valida��o do registro de abertura.
-- O registro de leiaute possui o C�digo (VERSAO_LAYOUT_EFD.CD) e a Vers�o (VERSAO_LAYOUT_EFD.VERSAO), como sendo chave �nica, e no processo estamos considerando
-- somente a Vers�o (VERSAO_LAYOUT_EFD.VERSAO).
-- Rotina: fkg_cdversao_layout_efd e fkg_versao_layout_efd_id.
--
-- Em 20/02/2019 - Eduardo Linden
-- Redmine #51748 - Inclus�o de novo paramentro estado_id ( Sped de ICMS e IPI - Erro na Exporta��o do Registro 1400)
-- Inclus�o de novo parametro : en_estado_id
-- Rotina : fkg_recup_cod_ipm_item
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo da vers�o o leiaute da EFD conforme ID

function fkg_cdversao_layout_efd ( en_id  in versao_layout_efd.id%type )
         return versao_layout_efd.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a vers�o o leiaute da EFD conforme ID

function fkg_versao_layout_efd ( en_id  in versao_layout_efd.id%type )
         return versao_layout_efd.versao%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do leiaute da EFD conforme VERSAO

function fkg_versao_layout_efd_id ( en_cdversao in versao_layout_efd.cd%type
                                  , ev_versao   in versao_layout_efd.versao%type )
         return versao_layout_efd.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o COD do registro_efd conforme ID

function fkg_registro_efd_cod ( en_id  in registro_efd.id%type )
         return registro_efd.cod%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID do registro_efd conforme COD

function fkg_registro_efd_id ( ev_cod  in registro_efd.cod%type )
         return registro_efd.id%type;

-------------------------------------------------------------------------------------------------------
--#69348 inclusao
-- Fun��o retorna o ID da tabela COD_INF_ADIC_VLR_DECL (Tabela de informa��es adicionais da apurac�o, valores declaratorios (registro E115 do Sped Fiscal))

function fkg_cod_inf_adic_id ( ev_cod_inf  in cod_inf_adic_vlr_decl.cod_inf_adic%type
                                      , ed_dt_ini   in cod_inf_adic_vlr_decl.dt_ini%type
                                      , ed_dt_fin   in cod_inf_adic_vlr_decl.dt_fin%type )
         return cod_inf_adic_vlr_decl.id%type;

---------------------------------------------------------------------------------------------------------
--#69348 inclusao
-- Fun��o retorna o COD_INF_ADIC da tabela COD_INF_ADIC_VLR_DECL (Tabela de informa��es adicionais da apurac�o, valores declaratorios (registro E115 do Sped Fiscal))

function fkg_cod_inf_adic_cod_inf ( en_id  in cod_inf_adic_vlr_decl.id%type )
         return cod_inf_adic_vlr_decl.cod_inf_adic%type;
-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID da tabela COD_OCOR_AJ_ICMS (Ajustes e Informa��es de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_id ( ev_cod_aj  in cod_ocor_aj_icms.cod_aj%type
                                 , ed_dt_ini  in cod_ocor_aj_icms.dt_ini%type
                                 , ed_dt_fin  in cod_ocor_aj_icms.dt_fin%type )
         return cod_ocor_aj_icms.id%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o COD_AJ da tabela COD_OCOR_AJ_ICMS (Ajustes e Informa��es de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_cod_aj ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.cod_aj%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o DM_REFLEXO_APUR da tabela COD_OCOR_AJ_ICMS (Ajustes e Informa��es de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_ref_apur ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.dm_reflexo_apur%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o DM_TIPO_APUR da tabela COD_OCOR_AJ_ICMS (Ajustes e Informa��es de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_tp_apur ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.dm_tipo_apur%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o DM_RESPONS da tabela COD_OCOR_AJ_ICMS (Ajustes e Informa��es de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_resp ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.dm_respons%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o DM_INFL_REC da tabela COD_OCOR_AJ_ICMS (Ajustes e Informa��es de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_infl ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.dm_infl_rec%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela COD_CONS_ITEM_CONT (Codifica��o do Consumo de Mercadorias/Servi�os de Fornecimento Continuo)

function fkg_cod_cons_item_cont_id ( ev_cod_mod   in mod_fiscal.cod_mod%type
                                   , ev_cod_cons  in cod_cons_item_cont.cod_cons%type )
         return cod_cons_item_cont.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo da tabela COD_CONS_ITEM_CONT (Codifica��o do Consumo de Mercadorias/Servi�os de Fornecimento Continuo)
-- atrav�s do seu ID

function fkg_id_cons_item_cont_cod ( en_codconsitemcont_id in cod_cons_item_cont.id%type )
         return cod_cons_item_cont.cod_cons%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela CLASS_CONS_ITEM_CONT (classifica��o do Consumo de Mercadorias/Servi�os de Fornecimento Continuo)

function fkg_class_cons_item_cont_id ( ev_cod_class  in class_cons_item_cont.cod_class%type )
         return class_cons_item_cont.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela COD_AJ_SALDO_APUR_ICMS (ajustes da apura��o de ICMS)

function fkg_cod_aj_saldo_apur_icms_id ( ev_cod_aj_apur  in cod_aj_saldo_apur_icms.cod_aj_apur%type
                                       , ed_dt_ini       in cod_aj_saldo_apur_icms.dt_ini%type
                                       , ed_dt_fin       in cod_aj_saldo_apur_icms.dt_fin%type )
         return cod_aj_saldo_apur_icms.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o DM_APUR da tabela COD_AJ_SALDO_APUR_ICMS (ajustes da apura��o de ICMS)

function fkg_cod_aj_saldo_apur_icms_apu ( en_id  in cod_aj_saldo_apur_icms.id%type )
         return cod_aj_saldo_apur_icms.dm_apur%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o DM_UTIL da tabela COD_AJ_SALDO_APUR_ICMS (ajustes da apura��o de ICMS)

function fkg_cod_aj_saldo_apur_icms_utl ( en_id  in cod_aj_saldo_apur_icms.id%type )
         return cod_aj_saldo_apur_icms.dm_util%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela COD_INF_ADIC_VLR_DECL (informa��es adicionais da apura��o, valores declarat�rios)

function fkg_cod_inf_adic_vlr_decl_id ( ev_cod_inf_adic  in cod_inf_adic_vlr_decl.cod_inf_adic%type )
         return cod_inf_adic_vlr_decl.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela COD_AJ_APUR_IPI (c�digo de ajuste de IPI)

function fkg_cod_aj_apur_ipi_id ( ev_cod_aj in cod_aj_apur_ipi.cod_aj%type )
         return cod_aj_apur_ipi.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o DM_NATUR da tabela COD_AJ_APUR_IPI (c�digo de ajuste de IPI)

function fkg_cod_aj_apur_ipi_natur ( en_id in cod_aj_apur_ipi.id%type )
         return cod_aj_apur_ipi.dm_natur%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela TIPO_UTIL (TIPOS DE UTILIZA��O DOS CR�DITOS FISCAIS ICMS)

function fkg_tipo_util_id ( ev_cd  in tipo_util.cd%type )
         return tipo_util.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o COD_IND_BEM da tabela BEM_ATIVO_IMOB

function fkg_bem_ativo_imob_cod_ind_bem ( en_bemativoimob_id in bem_ativo_imob.id%type )
         return bem_ativo_imob.cod_ind_bem%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o Conte�do anterior do campo da tabelaalter_pessoa atrav�s do ID

function fkg_cont_ant_id ( en_alterpessoa_id in alter_pessoa.id%type )
         return alter_pessoa.cont_ant%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo do ajuste da tabela COD_AJ_SALDO_APUR_ICMS atrav�s do identificador

function fkg_cod_codajsaldoapuricms ( en_codajsaldoapuricms_id in cod_aj_saldo_apur_icms.id%type )
         return cod_aj_saldo_apur_icms.cod_aj_apur%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo de informa��o atrav�s do identificador da tabela COD_INF_ADIC_VLR_DECL

function fkg_cod_codinfadicvlrdecl ( en_codinfadicvlrdecl_id in cod_inf_adic_vlr_decl.id%type )
         return cod_inf_adic_vlr_decl.cod_inf_adic%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o para recuperar o c�digo IPM (�ndice de participa��o dos munic�pios) relacionado com empresa e item/produto.

function fkg_recup_cod_ipm_item ( en_empresa_id in empresa.id%type
                                , en_item_id    in item.id%type
                                , en_estado     in estado.id%type )
         return param_ipm.cod_ipm%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna os Par�metros do Sped ICMS/IPI da Empresa
function fkg_param_efd_icms_ipi ( en_empresa_id in empresa.id%type
                                )
         return param_efd_icms_ipi%rowtype;

-------------------------------------------------------------------------------------------------------

end pk_csf_efd;
/
