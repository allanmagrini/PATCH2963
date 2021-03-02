create or replace package csf_own.pk_csf_int_bloco_nfs is

------------------------------------------------------------------------------------------------------------
-- Especificação do pacote de integração por bloco de Notas Fiscais de Serviço a partir de leitura de views
--
-- Em 10/08/2020   - Luis Marques - 2.9.5
-- Redmine #58588  - Alterar tamanho de campo NRO_NF
--                 - Ajuste em todos os types campo "NRO_NF" de 9 para 30 para notas de serviços.
--
-- Em 16/03/2020 - Luis Marques
-- Redmine #63776 -Integração de NFSe - Aumentar Campo Razao Social do Destinatário e Logradouro
-- Rotina Alterada: pkb_ler_nf_dest_serv - alterado tamanho dos campos nome e lograd do type "vt_tab_csf_nf_dest_serv".
--
-- =========================================================================================================
--
-- Em 17/09/2012 - Angela Inês - Ficha HD 63072.
-- 1) Inclusão do processo de integração de Impostos Retidos - Processo Flex Field (FF).
--
-- Em 05/11/2014 - Rogério Silva
-- Redmine #5020 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
--
-- Em 22/01/2015 - Rogério Silva
-- Redmine #5889 - Alterar integrações em bloco para usar o where e rownum
--
-- Em 02/06/2015 - Rogério Silva.
-- Redmine #8233 - Processo de Registro de Log em Packages - Notas Fiscais de Serviços EFD
--
-- Em 30/07/2015 - Rogério Silva.
-- Redmine #9832 - Alteração do processo de Integração Open Interface Table/View
--
-- Em 09/10/2017 - Fábio Tavares
-- Redmine #33828 - Integração Complementar de NFS para o Sped Reinf
-- Rotina: Adicionar as novas views do REINF
--
-- Em 06/08/2018 - Marcos Ferreira
-- Redmine #33155 - Adaptar Layout de Inttegração de Nota Fiscais de Serviço para novo campo.
-- Adicionado campo id_estrangeiro no Type tab_csf_nf_dest_serv da pks
--


------------------------------------------------------------------------------------------------------------

--| Informações de Nota fiscal de Serviço

   type tab_csf_nfs is record ( cpf_cnpj_emit        varchar2(14)
                              , dm_ind_emit          number(1)
                              , dm_ind_oper          number(1)
                              , cod_part             varchar2(60)
                              , serie                varchar2(3)
                              , nro_nf               number(30)
                              , subserie             number(3)
                              , dt_emiss             date
                              , dt_exe_serv          date
                              , dt_sai_ent           date
                              , sit_docto            varchar2(2)
                              , chv_nfse             varchar2(60)
                              , dm_ind_pag           number(1)
                              , dm_nat_oper          number(1)
                              , dm_tipo_rps          number(1)
                              , dm_status_rps        number(1)
                              , nro_rps_subst        number(9)
                              , serie_rps_subst      varchar2(3)
                              , dm_st_proc           number(2)
                              , sist_orig            varchar2(10)
                              , unid_org             varchar2(20)
                              );
--
   type t_tab_csf_nfs is table of tab_csf_nfs index by binary_integer;
   vt_tab_csf_nfs t_tab_csf_nfs;
--
--| informações Flex Field de notas fiscais de serviços não integradas
   type tab_csf_nota_fiscal_serv_ff is record ( cpf_cnpj_emit       varchar2(14)
                                              , dm_ind_emit         number(1)
                                              , dm_ind_oper         number(1)
                                              , cod_part            varchar2(60)
                                              , serie               varchar2(3)
                                              , nro_nf              number(30)
                                              , atributo            varchar2(30)
                                              , valor               varchar2(255)
                                              );
   --
   type t_tab_csf_nota_fiscal_serv_ff is table of tab_csf_nota_fiscal_serv_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_serv_ff t_tab_csf_nota_fiscal_serv_ff;
-- 
--| Informações Item Nota Fiscal Complementos de Serviços

   type tab_csf_itemnf_compl_serv is record ( cpf_cnpj_emit            varchar2(14)
                                            , dm_ind_emit              number(1)
                                            , dm_ind_oper              number(1)
                                            , cod_part                 varchar2(60)
                                            , serie                    varchar2(3)
                                            , nro_nf                   number(30)
                                            , nro_item                 number
                                            , cod_item                 varchar2(60)
                                            , descr_item               varchar2(2000)
                                            , cfop                     number(4)
                                            , vl_servico               number(15,2)
                                            , vl_desc_incondicionado   number(15,2)
                                            , vl_desc_condicionado     number(15,2)
                                            , vl_deducao               number(15,2)
                                            , vl_outra_ret             number(15,2)
                                            , cnae                     varchar2(7)
                                            , cd_lista_serv            number(4)
                                            , cod_trib_municipio       varchar2(20)
                                            , nat_bc_cred              varchar2(2)
                                            , dm_ind_orig_cred         number(1)
                                            , dt_pag_pis               date
                                            , dt_pag_cofins            date
                                            , dm_loc_exe_serv          number(1)
                                            , dm_trib_mun_prest        number(1)
                                            , cidade_ibge              number(7)
                                            , cod_cta                  varchar2(60)
                                            , cod_ccus                 varchar2(30)
                                            );
--
   type t_tab_csf_itemnf_compl_serv is table of tab_csf_itemnf_compl_serv index by binary_integer;
   vt_tab_csf_itemnf_compl_serv t_tab_csf_itemnf_compl_serv;
--

--| Informações Item Nota Fiscal Complementos de Serviços - Campos Flex-Field
   -- Nível - 1
   type tab_csf_itnf_compl_serv_ff is record ( cpf_cnpj_emit           varchar2(14)
                                             , dm_ind_emit             number(1)
                                             , dm_ind_oper             number(1)
                                             , cod_part                varchar2(60)
                                             , serie                   varchar2(3)
                                             , nro_nf                  number(30)
                                             , nro_item                number
                                             , atributo                varchar2(30)
                                             , valor                   varchar2(255)
                                             );
   --
   type t_tab_csf_itnf_compl_serv_ff is table of tab_csf_itnf_compl_serv_ff index by binary_integer;
   vt_tab_csf_itnf_compl_serv_ff t_tab_csf_itnf_compl_serv_ff;
--
--| Informações de impostos dos itens de notas fiscais de serviços

   type tab_csf_imp_itemnf_serv is record ( cpf_cnpj_emit    varchar2(14)
                                          , dm_ind_emit      number(1)
                                          , dm_ind_oper      number(1)
                                          , cod_part         varchar2(60)
                                          , serie            varchar2(3)
                                          , nro_nf           number(30)
                                          , nro_item         number
                                          , cod_imposto      number(3)
                                          , dm_tipo          number(1)
                                          , cod_st           varchar2(2)
                                          , vl_base_calc     number(15,2)
                                          , aliq_apli        number(5,2)
                                          , vl_imp_trib      number(15,2)
                                          );
--
   type t_tab_csf_imp_itemnf_serv is table of tab_csf_imp_itemnf_serv index by binary_integer;
   vt_tab_csf_imp_itemnf_serv t_tab_csf_imp_itemnf_serv;
--
--| Informações de impostos dos itens de notas fiscais de serviços - campos flex field

   type tab_csf_imp_itemnf_serv_ff is record ( cpf_cnpj_emit    varchar2(14)
                                             , dm_ind_emit      number(1)
                                             , dm_ind_oper      number(1)
                                             , cod_part         varchar2(60)
                                             , serie            varchar2(3)
                                             , nro_nf           number(30)
                                             , nro_item         number
                                             , cod_imposto      number(3)
                                             , dm_tipo          number(1)
                                             , atributo         varchar2(30)
                                             , valor            varchar2(255)
                                             );
--
   type t_tab_csf_imp_itemnf_serv_ff is table of tab_csf_imp_itemnf_serv_ff index by binary_integer;
   vt_tab_csf_imp_itemnf_serv_ff t_tab_csf_imp_itemnf_serv_ff;
--
--| Informação adicional da nota fiscal de serviço

   type tab_csf_nfinfor_adic_serv is record ( cpf_cnpj_emit  varchar2(14)
                                            , dm_ind_emit    number(1)
                                            , dm_ind_oper    number(1)
                                            , cod_part       varchar2(60)
                                            , serie          varchar2(3)
                                            , nro_nf         number(30)
                                            , dm_tipo        number(1)
                                            , campo          varchar2(256)
                                            , conteudo       varchar2(4000)
                                            , orig_proc      number(1)
                                            );
--
   type t_tab_csf_nfinfor_adic_serv is table of tab_csf_nfinfor_adic_serv index by binary_integer;
   vt_tab_csf_nfinfor_adic_serv t_tab_csf_nfinfor_adic_serv;
--
--| Informações do Destinatario da Nota Fiscal de Serviço

   type tab_csf_nf_dest_serv is record ( cpf_cnpj_emit  varchar2(14)
                                       , dm_ind_emit    number(1)
                                       , dm_ind_oper    number(1)
                                       , cod_part       varchar2(60)
                                       , serie          varchar2(3)
                                       , nro_nf         number(30)
                                       , cnpj           varchar2(14)
                                       , cpf            varchar2(11)
                                       , nome           varchar2(150)
                                       , lograd         varchar2(150)
                                       , nro            varchar2(10)
                                       , compl          varchar2(60)
                                       , bairro         varchar2(60)
                                       , cidade         varchar2(60)
                                       , cidade_ibge    number(7)
                                       , uf             varchar2(2)
                                       , cep            number(8)
                                       , cod_pais       number(4)
                                       , pais           varchar2(60)
                                       , fone           varchar2(13)
                                       , ie             varchar2(14)
                                       , suframa        varchar2(9)
                                       , email          varchar2(60)
                                       , im             varchar2(15)
                                       , id_estrangeiro varchar2(20)
                                       );
--
   type t_tab_csf_nf_dest_serv is table of tab_csf_nf_dest_serv index by binary_integer;
   vt_tab_csf_nf_dest_serv t_tab_csf_nf_dest_serv;
--
--| Informações do Intermediario da Nota Fiscal de Serviço

   type tab_csf_nf_inter_serv is record ( cpf_cnpj_emit   varchar2(14)
                                        , dm_ind_emit     number(1)
                                        , dm_ind_oper     number(1)
                                        , cod_part        varchar2(60)
                                        , serie           varchar2(3)
                                        , nro_nf          number(30)
                                        , nome            varchar2(115)
                                        , inscr_munic     varchar2(15)
                                        , cpf_cnpj        varchar2(14)
                                        );
--
   type t_tab_csf_nf_inter_serv is table of tab_csf_nf_inter_serv index by binary_integer;
   vt_tab_csf_nf_inter_serv t_tab_csf_nf_inter_serv;
--
--| Informações sobre o detalhamento de serviços prestados na construção civil.

   type tab_csf_nfs_det_const_civil is record ( cpf_cnpj_emit  varchar2(14)
                                               , dm_ind_emit    number(1)
                                               , dm_ind_oper    number(1)
                                               , cod_part       varchar2(60)
                                               , serie          varchar2(3)
                                               , nro_nf         number(30)
                                               , cod_obra       varchar2(15)
                                               , nro_art        varchar2(15)
                                               , nro_cno        number(14)
                                               , dm_ind_obra    number
                                               );
--
   type t_tab_csf_nfs_det_const_civil is table of tab_csf_nfs_det_const_civil index by binary_integer;
   vt_tab_csf_nfs_det_const_civil t_tab_csf_nfs_det_const_civil;
--
--| Informações das duplicatas da cobrança da nota fiscal de serviço.

   type tab_csf_nf_cobr_dup_serv is record ( cpf_cnpj_emit    varchar2(14)
                                           , dm_ind_emit      number(1)
                                           , dm_ind_oper      number(1)
                                           , cod_part         varchar2(60)
                                           , serie            varchar2(3)
                                           , nro_nf           number(30)
                                           , nro_fat          varchar2(60)
                                           , nro_parc         varchar2(60)
                                           , dt_vencto        date
                                           , vl_dup           number(15,2)
                                           );
--
   type t_tab_csf_nf_cobr_dup_serv is table of tab_csf_nf_cobr_dup_serv index by binary_integer;
   vt_tab_csf_nf_cobr_dup_serv t_tab_csf_nf_cobr_dup_serv;
--
--| informações do complemento do serviço
   -- Nível - 1
   type tab_csf_nf_compl_serv is record ( cpf_cnpj_emit           varchar2(14)
                                        , dm_ind_emit             number(1)
                                        , dm_ind_oper             number(1)
                                        , cod_part                varchar2(60)
                                        , serie                   varchar2(3)
                                        , nro_nf                  number(30)
                                        , id_erp                  number
                                        );
   --
   type t_tab_csf_nf_compl_serv is table of tab_csf_nf_compl_serv index by binary_integer;
   vt_tab_csf_nf_compl_serv t_tab_csf_nf_compl_serv;
--
--| Informações para o cancelamento da nota fiscal de serviço.

   type tab_csf_nf_canc_serv is record ( cpf_cnpj_emit   varchar2(14)
                                       , dm_ind_emit     number(1)
                                       , dm_ind_oper     number(1)
                                       , cod_part        varchar2(60)
                                       , serie           varchar2(3)
                                       , nro_nf          number(30)
                                       , dt_canc         date
                                       , justif          varchar2(255)
                                       );
--
   type t_tab_csf_nf_canc_serv is table of tab_csf_nf_canc_serv index by binary_integer;
   vt_tab_csf_nf_canc_serv t_tab_csf_nf_canc_serv;
--
--| Informações de Processos administrativos/Judiciario do REINF relacionado a nota fiscal de Serviço
   type tab_csf_nf_proc_reinf is record ( cpf_cnpj_emit               varchar2(14)
                                        , dm_ind_emit                 number(1)
                                        , dm_ind_oper                 number(1)
                                        , cod_part                    varchar2(60)
                                        , serie                       varchar2(3)
                                        , nro_nf                      number(30)
                                        , dm_tp_proc                  number(1)
                                        , nro_proc                    varchar2(21)
                                        , cod_susp                    number(2)
                                        , dm_ind_proc_ret_adic        varchar2(1)
                                        , valor                       number(14,2)
                                        );
  --
   type t_tab_csf_nf_proc_reinf is table of tab_csf_nf_proc_reinf index by binary_integer;
   vt_tab_csf_nf_proc_reinf t_tab_csf_nf_proc_reinf;
--
-------------------------------------------------------------------------------------------------------

   gv_sql              varchar2(4000) := null;
   gv_where            varchar2(4000) := null;
   gn_rel_part         number := 0;
   gd_dt_ini_integr    date := null;
   gv_resumo           log_generico_nf.resumo%type := null;
   gv_cabec_nf         varchar2(4000) := null;
   gd_formato_dt_erp   empresa.formato_dt_erp%type := null;
   gv_cd_obj           obj_integr.cd%type := '7';

-------------------------------------------------------------------------------------------------------

   GV_ASPAS                CHAR(1) := null;
   GV_NOME_DBLINK          empresa.nome_dblink%type := null;
   GV_OWNER_OBJ            empresa.owner_obj%type := null;
   gn_dm_ret_infor_integr  empresa.dm_ret_infor_integr%type := null;
   GV_SIST_ORIG            sist_orig.sigla%type := null;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais de Serviço
--| Importa todos os tipos de Notas
procedure pkb_integracao ( ed_dt_ini      in date default null
			 , ed_dt_fin      in date default null
			 , en_empresa_id  in empresa.id%type default null
                         );

-------------------------------------------------------------------------------------------------------

end pk_csf_int_bloco_nfs;
/