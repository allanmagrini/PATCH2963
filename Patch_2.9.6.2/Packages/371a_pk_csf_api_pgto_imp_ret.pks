create or replace package csf_own.pk_csf_api_pgto_imp_ret is

-------------------------------------------------------------------------------------------------------------------------
--
--| Especifícação da Package de API de Pagamento de Impostos no padrão para DCTF
--
-- Em 14/12/2019 - Luis Marques
-- Redmine #58009 - Adequação de tabela de retenção
-- Nova rotina: pkb_integr_imp_ret_rec - Integração de nova view (VW_CSF_IMP_RET_REC) com inclusão dos campos
--              VL_RET_IR e VL_RET_CSLL.
--
-- ======================================================================================================================
--
-- Em 08/02/2021 - Marcos Ferreira
-- Distribuições: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #73588 - Criar Origem de Dados para ISS Retido para Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 27/07/2020 - Marcos Ferreira
-- Distribuições: 2.9.5 / 2.9.4.2
-- Redmine #65265: Gerar guias de impostos a partir da apuração
-- Rotinas Criadas: pkb_finaliza_pgto_imp_ret, pkb_estorna_pgto_imp_ret
-- Alterações: Criação da Estrutura das Procedures
--
-- Em 10/07/2020 - Marcos Ferreira
-- Distribuições: 2.9.4
-- Redmine #65265: Gerar guias de impostos a partir da apuração
-- Rotinas Criadas: pkb_finaliza_guia_pagamento, pkb_estorna_guia_pagamento
-- Alterações: Criação da Estrutura das Procedures
--
-- Em 16/12/2013 - Angela Inês.
-- Redmine #1377 - Processos relacionados a Integração e Validação de Impostos Retidos sobre Receita (Pis/Cofins) - API.
-- 1) Foi corrigido a rotina pk_csf_api_pgto_imp_ret.pkb_integr_pgto_imp_ret para deixar NULO na coluna TIPORETIMPRECEITA_ID quando não existir.
--
-- Em 13/01/2014 - Angela Inês.
-- Redmine #1706/1765 - Problemas no processo de "Validar" e "Desfazer".
-- 1) Considerar um documento fiscal por código de retenção.
-- 2) Caso haja erro nos documentos fiscais será gerado LOG vinculado ao Imposto retido (referencia_id = imp_ret_rec_pc.id e obj_referncia = IMP_RET_REC_PC).
-- 3) O status do imposto retido ficará com 2-erro de validação.
-- 4) Alteração nas mensagens de inconsistências.
-- Rotina: pkb_integr_imp_ret_rec_pc_nf.
--
-- Em 19/08/2014 - Angela Inês.
-- Redmine #3789 - Erro de Validação no processo de impostos retidos sobre receita - Tadeu/Aceco.
-- Rotina: pkb_integr_imp_ret_rec_pc.
--
-- Em 26/09/2014 - Rogério Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
-- Rotinas: pkb_integr_pgto_imp_ret, pkb_integr_imp_ret_rec_pc.
--
-- Em 16/10/2014 - Rogério Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
--
-- Em 22/10/2014 - Rogério Silva
-- Redmine #4067 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
--
-- Em 07/01/2015 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 10/06/2015 - Rogério Silva
-- Redmine #8251 - Processo de Registro de Log em Packages - Pagamento de Impostos no padrÆo para DCTF
--
-- Em 01/09/2015 - Rogério Silva
-- Redmine #11327 - Implementação de Flex-Field para a tabela IMP_RET_REC_PC
--
-- Em 03/02/2016 - Angela Inês.
-- Redmine #15080 - Integração de DCTF.
-- Considerar as variáveis de tipo de imposto e tipo de código de retenção para identificar se o registro já existe, e não utilizar as variáveis do array.
-- Rotina: pkb_integr_pgto_imp_ret.
--
-- Em 04/02/2016 - Rogério Silva
-- Redmine #13079 - Registro do Número do Lote de Integração Web-Service nos logs de validação
--
-- Em 13/04/2016 - Fábio Tavares
-- Redmine #16793 - Melhoria nas mensagens dos processos flex-field.
--
-- Em 02/09/2016 - Angela Inês.
-- Redmine #23107 - Correção no processo de atualização de Pagamentos de Impostos Retidos.
-- Corrigir as mensagens de logs no processo de validação de integração de Pagamentos de Impostos Retidos.
-- Rotina: pkb_integr_pgto_imp_ret.
--
-- Em 29/12/2016 - Fábio Tavares
-- Redmine #26730 - Ajuste no Processo de Validação da tabela imp_ret_rec_pc_nf
-- Rotina: pkb_integr_imp_ret_rec_pc_nf
--
-- Em 13/12/2016 - Fábio Tavares
-- Redmine #28058 - Falha na integração Impostos Retidos (ACECO)
-- Rotina: pkb_integr_imp_ret_rec_pc
--
-- Em 09/10/2017 - Fábio Tavares
-- Redmine #33840 - Integração de Pgto Imp. Retidos para o Sped Reinf
-- Rotinas: Implementação das novas views do REINF;
--
-- Em 09/02/2018 - Marcelo Ono
-- Redmine #39287 - Correções e implementações nos processos do REINF.
-- 1- Implementado o processo de integração dos dados de Pagamento de Impostos no padrão para DCTF - Flex-Field;
-- 2- Implementado o processo de validação das Informações de pagamento de impostos retidos do exterior.
-- Rotina: pkb_integr_pgto_imp_ret_ff, pkb_integr_pir_info_ext.
--
-- Em 22/02/2018 - Marcelo Ono
-- Redmine #38773 - Correções e implementações nos processos do projeto REINF.
-- 1- Implementado processo para recuperar a informação de suspensão de exibilidade de tributos do Processo Administrativo/Judiciário da Empresa Matriz.
-- 2- Implementado processo na validação do Pagamento de Imposto Retido para alterar o campo "DM_ENVIO" para "0-Não Enviado";
-- Rotina: pkb_integr_pir_proc_reinf, pkb_integr_pir_inf_rra, pkb_integr_pgto_imp_ret.
--
-------------------------------------------------------------------------------------------------------------------------

   gt_row_pgto_imp_ret            pgto_imp_ret%rowtype;
   gt_row_imp_ret_rec_pc          imp_ret_rec_pc%rowtype;
   gt_row_imp_ret_rec             imp_ret_rec_pc%rowtype;
   gt_row_imp_ret_rec_pc_nf       imp_ret_rec_pc_nf%rowtype;
   gt_row_pir_det_ded             pir_det_ded%rowtype;
   gt_row_pir_rend_isento         pir_rend_isento%rowtype;
   gt_row_pir_det_comp            pir_det_comp%rowtype;
   gt_row_pir_comp_jud            pir_comp_jud%rowtype;
   gt_row_pir_inf_rra             pir_inf_rra%rowtype;
   gt_row_pir_inf_rra_desp        pir_inf_rra_desp%rowtype;
   gt_row_pir_inf_rra_desp_adv    pir_inf_rra_desp_adv%rowtype;
   gt_row_pir_proc_reinf          pir_proc_reinf%rowtype;
   gt_row_pir_proc_reinf_desp     pir_proc_reinf_desp%rowtype;
--   gt_row_pir_inf_rra_desp_adv    pir_inf_rra_desp_adv%rowtype;
   gt_row_pir_proc_reinf_desp_adv pir_proc_reinf_desp_adv%rowtype;
   gt_row_pir_proc_reinf_orig_rec pir_proc_reinf_orig_rec%rowtype;
   gt_row_pir_info_ext            pir_info_ext%rowtype;

-------------------------------------------------------------------------------------------------------

-- Declaração de constantes

   ERRO_DE_VALIDACAO       CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA         CONSTANT NUMBER := 2;
   INFORMACAO              constant number := 35;

-------------------------------------------------------------------------------------------------------

   gn_processo_id        log_generico.processo_id%type := null;
   --
   gv_resumo             log_generico_pir.resumo%TYPE;
   --
   gv_mensagem           log_generico_pir.mensagem%TYPE;
   --
   gv_obj_referencia     log_generico_pir.obj_referencia%type default 'PGTO_IMP_RET';
   --
   gn_referencia_id      log_generico_pir.referencia_id%type := null;
   --
   gv_cd_obj             obj_integr.cd%type := '46';
   
------------------------------------------------------------------------------------------

-- Procedimento de registro de log
procedure pkb_log_generico_pir ( sn_loggenericopir_id     out nocopy log_generico_pir.id%type
                               , ev_mensagem           in            log_generico_pir.mensagem%type
                               , ev_resumo             in            log_generico_pir.resumo%type
                               , en_tipo_log           in            csf_tipo_log.cd_compat%type      default 1
                               , en_referencia_id      in            log_generico_pir.referencia_id%type  default null
                               , ev_obj_referencia     in            log_generico_pir.obj_referencia%type default null
                               , en_empresa_id         in            empresa.id%type                  default null
                               , en_dm_impressa        in            log_generico_pir.dm_impressa%type    default 0
                               );

------------------------------------------------------------------------------------------

-- Procedimento armazena o valor do "loggenerico_id"
procedure pkb_gt_log_generico_pir ( en_loggenericopir_id in            log_generico_pir.id%type
                                  , est_log_generico_pir in out nocopy dbms_sql.number_table
                                  );
                                  
---------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Informações da Origem dos recurso dos processos administrativos/judiciário do EFD-REINF
procedure pkb_integr_pirprocreinforigrec ( est_log_generico_pir        in out nocopy  dbms_sql.number_table
                                         , est_pir_proc_reinf_orig_rec in out nocopy  pir_proc_reinf_orig_rec%rowtype
                                         , en_empresa_id               in             empresa.id%type
                                         , en_pirprocreinf_id          in             pir_proc_reinf_desp.id%type
                                         , ev_cod_part                 in             pessoa.cod_part%type
                                         , en_loteintws_id             in             lote_int_ws.id%type default 0
                                         );
                                  
---------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Despesas de com Advogados
procedure pkb_integr_pirprocreinfdespadv ( est_log_generico_pir        in out nocopy  dbms_sql.number_table
                                         , est_pir_proc_reinf_desp_adv in out nocopy  pir_proc_reinf_desp_adv%rowtype
                                         , en_empresa_id               in             empresa.id%type
                                         , en_pirprocreinfdesp_id      in             pir_proc_reinf_desp.id%type
                                         , ev_cod_part                 in             pessoa.cod_part%type
                                         , en_loteintws_id             in             lote_int_ws.id%type default 0
                                         );

----------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Informações de pagamento de impostos retidos do exterior
procedure pkb_integr_pir_info_ext ( est_log_generico_pir      in out nocopy  dbms_sql.number_table
                                  , est_pir_info_ext          in out nocopy  pir_info_ext%rowtype
                                  , en_pgtoimpret_id          in             pgto_imp_ret.id%type
                                  , en_cd_tp_rend_benef_ext   in             tp_rend_benef_ext.cod%type
                                  , ev_cd_form_trib_benf_ext  in             forma_trib_rend_ext.cod%type
                                  , en_loteintws_id           in             lote_int_ws.id%type default 0
                                  );

-----------------------------------------------------------------------------------------
-- Procedimento de integração de Detalhamento das despesas de processo judicial Identificação do Advogado
procedure pkb_integr_pirinfrradespadv ( est_log_generico_pir      in out nocopy  dbms_sql.number_table
                                      , est_pir_inf_rra_desp_adv  in out nocopy  pir_inf_rra_desp_adv%rowtype
                                      , en_empresa_id             in             empresa.id%type
                                      , en_pirinfrradesp_id       in             pir_inf_rra_desp.id%type
                                      , ev_cod_part               in             pessoa.cod_part%type
                                      , en_loteintws_id           in             lote_int_ws.id%type default 0
                                      );

---------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Despesas de Processos Administrativos/Judiciarios sobre Pagamentos de Impostos Retidos
procedure pkb_integr_pir_proc_reinf_desp ( est_log_generico_pir      in out nocopy  dbms_sql.number_table
                                         , est_pir_proc_reinf_desp   in out nocopy  pir_proc_reinf_desp%rowtype
                                         , en_empresa_id             in             empresa.id%type
                                         , en_pirprocreinf_id        in             pir_proc_reinf.id%type
                                         , en_loteintws_id           in             lote_int_ws.id%type default 0
                                         );

----------------------------------------------------------------------------------------------------
-- Procedimento de integração de Informações Complementares - Demais rendimentos decorrentes de Decisão Judicial
procedure pkb_integr_pir_proc_reinf ( est_log_generico_pir      in out nocopy  dbms_sql.number_table
                                    , est_pir_proc_reinf        in out nocopy  pir_proc_reinf%rowtype
                                    , en_empresa_id             in             empresa.id%type
                                    , en_pgtoimpret_id          in             pgto_imp_ret.id%type
                                    , ed_dt_pgto                in             pgto_imp_ret.dt_pgto%type
                                    , en_dm_tp_proc             in             proc_adm_efd_reinf.dm_tp_proc%type
                                    , ev_nro_proc               in             proc_adm_efd_reinf.nro_proc%type
                                    , en_cod_susp               in             proc_adm_efd_reinf_inf_trib.cod_susp%type
                                    , en_loteintws_id           in             lote_int_ws.id%type default 0
                                    );

-----------------------------------------------------------------------------------------
-- Procedimento de integração de Informações de Detalhamento das despesas de processo judicial
procedure pkb_integr_pir_inf_rra_desp ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                      , est_pir_inf_rra_desp  in out nocopy  pir_inf_rra_desp%rowtype
                                      , en_empresa_id         in             empresa.id%type
                                      , en_pirinfrra_id       in             pir_inf_rra.id%type
                                      , en_loteintws_id       in             lote_int_ws.id%type default 0
                                      );

-----------------------------------------------------------------------------------------
-- Procedimento de integração de Informações Complementares - Rendimentos Recebidos Acumuladamente
procedure pkb_integr_pir_inf_rra ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                 , est_pir_inf_rra       in out nocopy  pir_inf_rra%rowtype
                                 , en_empresa_id         in             empresa.id%type
                                 , en_pgtoimpret_id      in             pgto_imp_ret.id%type
                                 , ed_dt_pgto            in             pgto_imp_ret.dt_pgto%type
                                 , en_dm_tp_proc         in             proc_adm_efd_reinf.dm_tp_proc%type
                                 , ev_nro_proc           in             proc_adm_efd_reinf.nro_proc%type
                                 , en_cod_susp           in             proc_adm_efd_reinf_inf_trib.cod_susp%type
                                 , en_loteintws_id       in             lote_int_ws.id%type default 0
                                 );

-----------------------------------------------------------------------------------------
-- Procedimento de integração de informações Detalhamento de Compensação Judicial
procedure pkb_integr_pir_comp_jud ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                  , est_pir_comp_jud      in out nocopy  pir_comp_jud%rowtype
                                  , en_empresa_id         in             empresa.id%type
                                  , en_pgtoimpret_id      in             pgto_imp_ret.id%type
                                  , en_loteintws_id       in             lote_int_ws.id%type default 0
                                  );

-------------------------------------------------------------------------------------
-- Procedimento de integração dos dados de Pagamento de Impostos no padrão para DCTF
procedure pkb_integr_pgto_imp_ret ( est_log_generico_pir        in out nocopy  dbms_sql.number_table
                                  , est_pgto_imp_ret            in out nocopy  pgto_imp_ret%rowtype
                                  , ev_cpf_cnpj_emit            in             varchar2
                                  , ev_cod_part                 in             varchar2
                                  , en_cd_imp                   in             tipo_imposto.cd%type
                                  , en_cd_ret_imp               in             tipo_ret_imp.cd%type
                                  , ev_cod_receita              in             tipo_ret_imp_receita.cod_receita%type
                                  , en_multorg_id               in             mult_org.id%type
                                  , en_loteintws_id             in             lote_int_ws.id%type default 0
                                  );

-------------------------------------------------------------------------------------
-- Procedimento de integração dos dados de Pagamento de Impostos no padrão para DCTF - Flex-Field
procedure pkb_integr_pgto_imp_ret_ff ( est_log_generico_pir   in out nocopy  dbms_sql.number_table
                                     , en_pgtoimpret_id       in             pgto_imp_ret.id%type
                                     , ev_atributo            in             varchar2
                                     , ev_valor               in             varchar2 
                                     );

-----------------------------------------------------------------------------------------
-- Procedimento de integração de informações Detalhamento das Competencias
procedure pkb_integr_pir_det_comp ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                  , est_pir_det_comp      in out nocopy  pir_det_comp%rowtype
                                  , en_empresa_id         in             empresa.id%type
                                  , en_pgtoimpret_id      in             pgto_imp_ret.id%type
                                  , en_loteintws_id       in             lote_int_ws.id%type default 0
                                  );
                                  
-----------------------------------------------------------------------------------------
-- Procedimento de integração de informações de Rendimentos Isentos/Não Tributáveis de Pgto de Impostos Retidos
procedure pkb_integr_pir_rend_isento ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                     , est_pir_rend_isento   in out nocopy  pir_rend_isento%rowtype
                                     , en_empresa_id         in             empresa.id%type
                                     , en_pgtoimpret_id      in             pgto_imp_ret.id%type
                                     , en_cd_tp_isencao      in             tipo_isencao.cd%type
                                     , en_loteintws_id       in             lote_int_ws.id%type default 0
                                     );

-----------------------------------------------------------------------------------------
-- Procedimento de integração de informações complementares de Pgto de Impostos Retidos
-----------------------------------------------------------------------------------------
procedure pkb_integr_pir_det_ded ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                 , est_pir_det_ded       in out nocopy  pir_det_ded%rowtype
                                 , en_empresa_id         in             empresa.id%type
                                 , en_pgtoimpret_id      in             pgto_imp_ret.id%type
                                 , en_loteintws_id       in             lote_int_ws.id%type default 0
                                 );

-----------------------------------------------------------------------------------------
-- Procedimento de integração dos dados dos documentos fiscais relacionados às retenções
procedure pkb_integr_imp_ret_rec_pc_nf ( est_log_generico_pir   in out nocopy  dbms_sql.number_table
                                       , est_imp_ret_rec_pc_nf  in out nocopy  imp_ret_rec_pc_nf%rowtype
                                       , ev_cpf_cnpj_emit       in             varchar2
                                       , ev_cpf_cnpj_emit_nf    in             varchar2
                                       , ev_cod_part_nf         in             varchar2
                                       , ev_cod_mod             in             varchar2
                                       , en_multorg_id          in             mult_org.id%type
                                       , en_loteintws_id        in             lote_int_ws.id%type default 0
                                       );
                                       
-------------------------------------------------------------------------------------------------------

-- Procedimento de integração dos dados das retenções ocorridas nos recebimentos - Flex-Field
procedure pkb_integr_imp_ret_rec_pc_ff ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                       , en_impretrecpc_id     in             imp_ret_rec_pc.id%type
                                       , ev_atributo           in             varchar2
                                       , ev_valor              in             varchar2
                                       );   

-- Procedimento de integração dos dados das retenções ocorridas nos recebimentos
-- Nova View de Integração (VW_CSF_IMP_RET_REC) incluindo campo VL_RET_IR e 
-- VL_RET_CSLL copia da view VW_CSF_IMP_RET_REC_PC	  
---------------------------------------------------------------------------------
procedure pkb_integr_imp_ret_rec ( est_log_generico_pir in out nocopy  dbms_sql.number_table
                                 , est_imp_ret_rec      in out nocopy  imp_ret_rec_pc%rowtype
                                 , ev_cpf_cnpj_emit     in             varchar2
                                 , en_cnpj              in             number
                                 , ev_cod_part          in             varchar2
                                 , en_multorg_id        in             mult_org.id%type
                                 , en_loteintws_id      in             lote_int_ws.id%type default 0
                                 );

---------------------------------------------------------------------------------
-- Procedimento de integração dos dados das retenções ocorridas nos recebimentos
procedure pkb_integr_imp_ret_rec_pc ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                    , est_imp_ret_rec_pc    in out nocopy  imp_ret_rec_pc%rowtype
                                    , ev_cpf_cnpj_emit      in             varchar2
                                    , en_cnpj               in             number
                                    , ev_cod_part           in             varchar2
                                    , en_multorg_id         in             mult_org.id%type
                                    , en_loteintws_id       in             lote_int_ws.id%type default 0
                                    );

-------------------------------------------------------------------------------------------------------

procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , en_referencia_id       in             log_generico_pir.referencia_id%type  default null
                            , ev_obj_referencia      in             log_generico_pir.obj_referencia%type default null
                            );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field

procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , en_referencia_id   in            log_generico_pir.referencia_id%type  default null
                                , ev_obj_referencia  in            log_generico_pir.obj_referencia%type default null
                                );

-------------------------------------------------------------------------------------------------------------------------

-- Procedure para Finalizar o processo de geração de Guia de Pagamento pela tela de Geração do PIS/COFINS

procedure pkb_finaliza_pgto_imp_ret ( est_log_generico    in out nocopy  dbms_sql.number_table
                                    , en_empresa_id       in empresa.id%type
                                    , en_dt_ini           in date
                                    , en_dt_fim           in date
                                    , ev_cod_rec_cd_compl in guia_pgto_imp_compl_gen.cod_receita%type
                                    , sn_guiapgtoimp_id  out guia_pgto_imp.id%type); 
--
-------------------------------------------------------------------------------------------------------

-- Procedure para Estornar o processo de geração de Guia de Pagamento pela tela de Geração do PIS/COFINS

procedure pkb_estorna_pgto_imp_ret ( est_log_generico    in out nocopy  dbms_sql.number_table
                                   , en_empresa_id       in empresa.id%type
                                   , en_dt_ini           in date
                                   , en_dt_fim           in date 
                                   , en_pgtoimpret_id    in PGTO_IMP_RET.id%type default null); 
--
-------------------------------------------------------------------------------------------------------
end pk_csf_api_pgto_imp_ret;
/
