create or replace package csf_own.pk_vld_amb_gpi is

-- Em 08/02/2021 - Marcos Ferreira
-- Distribuições: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #73588 - Criar Origem de Dados para ISS Retido para Guia de Pagamento
-- Rotinas Alteradas: pkb_vld_guia_pgto_imp, pkb_ler_guia_pgto_imp
--
-- Em 27/07/2020 - Marcos Ferreira
-- Distribuições: 2.9.5 / 2.9.4.2
-- Redmine #65265: Gerar guias de impostos a partir da apuração
-- Rotinas Alterada: pkb_ler_guia_pgto_imp
-- Alterações: Criação da Estrutura das Procedures
--
-------------------------------------------------------------------------------------------------------
--
-- Especificação do pacote da Validação do Ambiente de Guia de Pagamento de Imposto com DM_ST_PROC = 0
-- (Não validada) e chamar os procedimentos para validar os dados
--
----------------------------------------------------------------------------------------------------
-- Variaveis Globais

   gn_multorg_id   mult_org.id%type;

----------------------------------------------------------------------------------------------------
--Procedimento de validação de guia de pgto de Importação

procedure pkb_vld_guia_pgto_imp ( en_guiapgtoimp_id   in            guia_pgto_imp.id%type
                                , sn_erro             in out nocopy number
                                , en_loteintws_id     in            lote_int_ws.id%type default 0
                                , ev_cod_rec_cd_compl in            guia_pgto_imp_compl_gen.cod_receita%type default null
                                );
                                
----------------------------------------------------------------------------------------------------
-- Procedimento que valida a guia de pgto de Impostos
procedure pkb_vld_guia_pgto_imp ( en_guiapgtoimp_id in guia_pgto_imp.id%type );

end pk_vld_amb_gpi;
/