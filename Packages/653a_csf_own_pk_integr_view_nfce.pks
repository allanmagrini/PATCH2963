create or replace package csf_own.pk_integr_view_nfce is
--
-- ============================================================================================================================================= --
-- Especificação do pacote de integração de Notas Fiscais a partir de leitura de views
--
-- Em 11 e 18/02/2021 - Karina de Paula
-- Redmine #75462  - Retorno de Mensagem de Cancelamento
-- Rotina Alterada - pkb_int_ret_infor_erp_ff/pkb_int_infor_erp_neo/pkb_ret_infor_erp_neo => Alterado o cod_msg para retornar da tabela nota_fiscal_canc quando a msg for de cancelamento
-- Liberado        - Release_2.9.7, Patch_2.9.6.2 e Patch_2.9.5.5
--
-- Em 25/08/2020  - Karina de Paula
-- Redmine #47204 - Separar integração OI de NFCE
-- Alterações     - pkb_ler_Nota_Fiscal_Emit/pkb_ler_Nota_Fiscal_Emit_ff => Essas rotinas foram criadas
-- Liberado       - Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 13/07/2020   - Wendel Albino
-- Redmine #69487  - Falha na integração NFCe - Todas empresas (VENANCIO)
-- Alterações      - pkb_ler_nota_fiscal-> tratamento na volta da chamada da pk_csf_api_nfce.pkb_integr_Nota_Fiscal se saiu com erro atualiza os totais e sai da integracao
--alterada posicao de validacao de cod_mod da nota para receber o cabecalho e gerar erro se houver.
--
-- Em 03 e 08/06/2020  - Karina de Paula
-- Redmine #62471      - Criar processo de validação da CSF_CONS_SIT
-- Alterações          - pkb_ler_cons_chave_nfe     => Alterada a chamada pk_csf_api_nfce.pkb_integr_cons_chave_nfe para pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe
--                     - pkb_seta_integr_erp_csf_cs => Retirado o update na csf_cons_sit e incluída a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
--                     - pkb_seta_integr_erp_csf_cs => Incluído o parâmetro de entrada empresa_id
--                     - pkb_int_csf_cons_sit       => Incluída a empresa_id na chamada da pkb_seta_integr_erp_csf_cs
-- Liberado            - Release_2.9.4, Patch_2.9.3.3 e Patch_2.9.2.6
--
-- Em 06/05/2020  - Karina de Paula
-- Redmine #65401 - NF-e de emissão própria autorizada indevidamente (CERRADÃO)
-- Alterações     - Incluído para o gv_objeto o nome da package como valor default para conseguir retornar nos logs o objeto;
-- Liberado       - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- ============================================================================================================================================= --
--
--| informações de notas fiscais não integradas
   -- Nível - 0
   type tab_csf_nota_fiscal is record ( cpf_cnpj_emit     varchar2(14)
                                      , dm_ind_emit       number(1)
                                      , dm_ind_oper       number(1)
                                      , cod_part          varchar2(60)
                                      , cod_mod           varchar2(2)
                                      , serie             varchar2(3)
                                      , nro_nf            number(9)
                                      , sit_docto         varchar2(2)
                                      , cod_nat_oper      varchar2(10)
                                      , descr_nat_oper    varchar2(60)
                                      , dm_ind_pag        number(1)
                                      , dt_sai_ent        date
                                      , hora_sai_ent      varchar2(8)
                                      , dt_emiss          date
                                      , uf_embarq         varchar2(2)
                                      , local_embarq      varchar2(60)
                                      , nf_empenho        varchar2(22)
                                      , pedido_compra     varchar2(60)
                                      , contrato_compra   varchar2(60)
                                      , dm_st_proc        number(2)
                                      , dm_fin_nfe        number(1)
                                      , dm_proc_emiss     number(1)
                                      , cidade_ibge_emit  number(7)
                                      , uf_ibge_emit      number(2)
                                      , usuario           varchar2(30)
                                      , vias_danfe_custom number(2)
                                      , nro_chave_cte_ref varchar2(44)
                                      , sist_orig         varchar2(10)
                                      , unid_org          varchar2(20)
                                      );
--
   type t_tab_csf_nota_fiscal is table of tab_csf_nota_fiscal index by binary_integer;
   vt_tab_csf_nota_fiscal t_tab_csf_nota_fiscal;
--
--| informações de notas fiscais não integradas - campos flex field
   -- Nível 1
   type tab_csf_nota_fiscal_ff is record ( cpf_cnpj_emit  varchar2(14)
                                         , dm_ind_emit    number(1)
                                         , dm_ind_oper    number(1)
                                         , cod_part       varchar2(60)
                                         , cod_mod        varchar2(2)
                                         , serie          varchar2(3)
                                         , nro_nf         number(9)
                                         , atributo       varchar2(30)
                                         , valor          varchar2(600) );
--
   type t_tab_csf_nota_fiscal_ff is table of tab_csf_nota_fiscal_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_ff t_tab_csf_nota_fiscal_ff;
--
--| informações do emitente da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_emit is record ( cpf_cnpj_emit  varchar2(14)
                                           , dm_ind_emit    number(1)
                                           , dm_ind_oper    number(1)
                                           , cod_part       varchar2(60)
                                           , cod_mod        varchar2(2)
                                           , serie          varchar2(3)
                                           , nro_nf         number(9)
                                           , nome           varchar2(60)
                                           , fantasia       varchar2(60)
                                           , lograd         varchar2(60)
                                           , nro            varchar2(10)
                                           , compl          varchar2(60)
                                           , bairro         varchar2(60)
                                           , cidade         varchar2(60)
                                           , cidade_ibge    number(7)
                                           , uf             varchar2(2)
                                           , cep            number(8)
                                           , cod_pais       number(4)
                                           , pais           varchar2(60)
                                           , fone           varchar2(14)
                                           , ie             varchar2(14)
                                           , iest           varchar2(14)
                                           , im             varchar2(15)
                                           , cnae           varchar2(7)
                                           , dm_reg_trib    number(1) );
--
   type t_tab_csf_nota_fiscal_emit is table of tab_csf_nota_fiscal_emit index by binary_integer;
   vt_tab_csf_nota_fiscal_emit t_tab_csf_nota_fiscal_emit;
--
--| informações do emitente da nota fiscal - campos Flex Field
   -- Nível 2
   type tab_csf_nota_fiscal_emit_ff is record ( cpf_cnpj_emit  varchar2(14)
                                              , dm_ind_emit    number(1)
                                              , dm_ind_oper    number(1)
                                              , cod_part       varchar2(60)
                                              , cod_mod        varchar2(2)
                                              , serie          varchar2(3)
                                              , nro_nf         number(9)
                                              , atributo       varchar2(30)
                                              , valor          varchar2(255));
--
   type t_tab_csf_nota_fiscal_emit_ff is table of tab_csf_nota_fiscal_emit_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_emit_ff t_tab_csf_nota_fiscal_emit_ff;
--
--| informações do destinatário da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_dest is record ( cpf_cnpj_emit  varchar2(14)
                                           , dm_ind_emit    number(1)
                                           , dm_ind_oper    number(1)
                                           , cod_part       varchar2(60)
                                           , cod_mod        varchar2(2)
                                           , serie          varchar2(3)
                                           , nro_nf         number(9)
                                           , cnpj           varchar2(14)
                                           , cpf            varchar2(11)
                                           , nome           varchar2(60)
                                           , lograd         varchar2(60)
                                           , nro            varchar2(10)
                                           , compl          varchar2(60)
                                           , bairro         varchar2(60)
                                           , cidade         varchar2(60)
                                           , cidade_ibge    number(7)
                                           , uf             varchar2(2)
                                           , cep            number(8)
                                           , cod_pais       number(4)
                                           , pais           varchar2(60)
                                           , fone           varchar2(14)
                                           , ie             varchar2(14)
                                           , suframa        varchar2(9)
                                           , email          varchar2(4000) );
--
   type t_tab_csf_nota_fiscal_dest is table of tab_csf_nota_fiscal_dest index by binary_integer;
   vt_tab_csf_nota_fiscal_dest t_tab_csf_nota_fiscal_dest;
--
--| informações do destinatário da nota fiscal - campos Flex Field
   -- Nível 2
   type tab_csf_nota_fiscal_dest_ff is record ( cpf_cnpj_emit  varchar2(14)
                                              , dm_ind_emit    number(1)
                                              , dm_ind_oper    number(1)
                                              , cod_part       varchar2(60)
                                              , cod_mod        varchar2(2)
                                              , serie          varchar2(3)
                                              , nro_nf         number(9)
                                              , atributo       varchar2(30)
                                              , valor          varchar2(255));
--
   type t_tab_csf_nota_fiscal_dest_ff is table of tab_csf_nota_fiscal_dest_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_dest_ff t_tab_csf_nota_fiscal_dest_ff;
--
--| informações do destinatário da nota fiscal
   -- Nível 2
   type tab_csf_nfdest_email is record ( cpf_cnpj_emit  varchar2(14)
                                       , dm_ind_emit    number(1)
                                       , dm_ind_oper    number(1)
                                       , cod_part       varchar2(60)
                                       , cod_mod        varchar2(2)
                                       , serie          varchar2(3)
                                       , nro_nf         number(9)
                                       , email          varchar2(4000)
                                       , dm_tipo_anexo  number(1) );
--
   type t_tab_csf_nfdest_email is table of tab_csf_nfdest_email index by binary_integer;
   vt_tab_csf_nfdest_email t_tab_csf_nfdest_email;
--
--| informações dos totais da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_total is record ( cpf_cnpj_emit          varchar2(14)
                                            , dm_ind_emit            number(1)
                                            , dm_ind_oper            number(1)
                                            , cod_part               varchar2(60)
                                            , cod_mod                varchar2(2)
                                            , serie                  varchar2(3)
                                            , nro_nf                 number(9)
                                            , vl_base_calc_icms      number(15,2)
                                            , vl_imp_trib_icms       number(15,2)
                                            , vl_base_calc_st        number(15,2)
                                            , vl_imp_trib_st         number(15,2)
                                            , vl_total_item          number(15,2)
                                            , vl_frete               number(15,2)
                                            , vl_seguro              number(15,2)
                                            , vl_desconto            number(15,2)
                                            , vl_imp_trib_ii         number(15,2)
                                            , vl_imp_trib_ipi        number(15,2)
                                            , vl_imp_trib_pis        number(15,2)
                                            , vl_imp_trib_cofins     number(15,2)
                                            , vl_outra_despesas      number(15,2)
                                            , vl_total_nf            number(15,2)
                                            , vl_serv_nao_trib       number(15,2)
                                            , vl_base_calc_iss       number(15,2)
                                            , vl_imp_trib_iss        number(15,2)
                                            , vl_pis_iss             number(15,2)
                                            , vl_cofins_iss          number(15,2)
                                            , vl_ret_pis             number(15,2)
                                            , vl_ret_cofins          number(15,2)
                                            , vl_ret_csll            number(15,2)
                                            , vl_base_calc_irrf      number(15,2)
                                            , vl_ret_irrf            number(15,2)
                                            , vl_base_calc_ret_prev  number(15,2)
                                            , vl_ret_prev            number(15,2)
                                            , vl_total_serv          number(15,2) );
--
   type t_tab_csf_nota_fiscal_total is table of tab_csf_nota_fiscal_total index by binary_integer;
   vt_tab_csf_nota_fiscal_total t_tab_csf_nota_fiscal_total;
--
--| informações dos totais da nota fiscal - campos Flex Field
   -- Nível 2
   type tab_csf_nota_fiscal_total_ff is record ( cpf_cnpj_emit          varchar2(14)
                                                , dm_ind_emit            number(1)
                                                , dm_ind_oper            number(1)
                                                , cod_part               varchar2(60)
                                                , cod_mod                varchar2(2)
                                                , serie                  varchar2(3)
                                                , nro_nf                 number(9)
                                                , atributo               varchar2(30)
                                                , valor                  varchar2(255) );
--
   type t_tab_csf_nota_fiscal_total_ff is table of tab_csf_nota_fiscal_total_ff index by binary_integer;
   vt_tab_csf_notafiscal_total_ff t_tab_csf_nota_fiscal_total_ff;
--
--| informações de documentos fiscais referenciados
   -- Nível 1
   type tab_csf_nota_fiscal_referen is record ( cpf_cnpj_emit         varchar2(14)
                                              , dm_ind_emit           number(1)
                                              , dm_ind_oper           number(1)
                                              , cod_part              varchar2(60)
                                              , cod_mod               varchar2(2)
                                              , serie                 varchar2(3)
                                              , nro_nf                number(9)
                                              , nro_chave_nfe_ref     varchar2(44)
                                              , ibge_estado_emit_ref  varchar2(2)
                                              , cnpj_emit_ref         varchar2(14)
                                              , dt_emiss_ref          date
                                              , cod_mod_ref           varchar2(2)
                                              , nro_nf_ref            number(9)
                                              , serie_ref             varchar2(3)
                                              , subserie_ref          number(3)
                                              , cod_part_ref          varchar2(60)
                                              , dm_ind_oper_ref       number(1)
                                              , dm_ind_emit_ref       number(1) );
--
   type t_tab_csf_nota_fiscal_referen is table of tab_csf_nota_fiscal_referen index by binary_integer;
   vt_tab_csf_nota_fiscal_referen t_tab_csf_nota_fiscal_referen;
--
--| informações de documentos fiscais referenciados - campos flex field
   -- Nível 1
   type tab_csf_notafiscalrefer_ff is record ( cpf_cnpj_emit         varchar2(14)
                                             , dm_ind_emit           number(1)
                                             , dm_ind_oper           number(1)
                                             , cod_part              varchar2(60)
                                             , cod_mod               varchar2(2)
                                             , serie                 varchar2(3)
                                             , nro_nf                number(9)
                                             , nro_chave_nfe_ref     varchar2(44)
                                             , ibge_estado_emit_ref  varchar2(2)
                                             , cnpj_emit_ref         varchar2(14)
                                             , dt_emiss_ref          date
                                             , cod_mod_ref           varchar2(2)
                                             , nro_nf_ref            number(9)
                                             , serie_ref             varchar2(3)
                                             , subserie_ref          number(3)
                                             , cod_part_ref          varchar2(60)
                                             , dm_ind_oper_ref       number(1)
                                             , dm_ind_emit_ref       number(1)
                                             , atributo              varchar2(30)
                                             , valor                 varchar2(255) );
--
   type t_tab_csf_notafiscalrefer_ff is table of tab_csf_notafiscalrefer_ff index by binary_integer;
   vt_tab_csf_notafiscalrefer_ff t_tab_csf_notafiscalrefer_ff;
--
--| informações de cupom fiscal referenciado
   -- Nível 1
   type tab_csf_cupom_fiscal_ref is record ( cpf_cnpj_emit         varchar2(14)
                                           , dm_ind_emit           number(1)
                                           , dm_ind_oper           number(1)
                                           , cod_part              varchar2(60)
                                           , cod_mod               varchar2(2)
                                           , serie                 varchar2(3)
                                           , nro_nf                number(9)
                                           , cod_mod_cf            varchar2(2)
                                           , ecf_fab               varchar2(20)
                                           , ecf_cx                number(3)
                                           , num_doc               number(6)
                                           , dt_doc                date );
--
   type t_tab_csf_cupom_fiscal_ref is table of tab_csf_cupom_fiscal_ref index by binary_integer;
   vt_tab_csf_cupom_fiscal_ref t_tab_csf_cupom_fiscal_ref;
--
--| informações de Autorização de acesso ao XML da Nota Fiscal
   -- Nível 1
   type tab_csf_nf_aut_xml is record ( cpf_cnpj_emit         varchar2(14)
                                    , dm_ind_emit           number(1)
                                    , dm_ind_oper           number(1)
                                    , cod_part              varchar2(60)
                                    , cod_mod               varchar2(2)
                                    , serie                 varchar2(3)
                                    , nro_nf                number(9)
                                    , cnpj                  varchar2(14)
                                    , cpf                   varchar2(11));
--
   type t_tab_csf_nf_aut_xml is table of tab_csf_nf_aut_xml index by binary_integer;
   vt_tab_csf_nf_aut_xml t_tab_csf_nf_aut_xml;

--| informações de Formas de Pagamento
   -- Nível 1
   type tab_csf_nf_forma_pgto is record ( cpf_cnpj_emit         varchar2(14)
                                        , dm_ind_emit           number(1)
                                        , dm_ind_oper           number(1)
                                        , cod_part              varchar2(60)
                                        , cod_mod               varchar2(2)
                                        , serie                 varchar2(3)
                                        , nro_nf                number(9)
                                        , dm_tp_pag             varchar2(2)
                                        , vl_pgto               number(15,2)
                                        , cnpj                  varchar2(14)
                                        , dm_tp_band            varchar2(2)
                                        , nro_aut               varchar2(20));
--
   type t_tab_csf_nf_forma_pgto is table of tab_csf_nf_forma_pgto index by binary_integer;
   vt_tab_csf_nf_forma_pgto t_tab_csf_nf_forma_pgto;

--| informações de Formas de Pagamento - Flex-Field
   -- Nível 1
   type tab_csf_nf_forma_pgto_ff is record ( cpf_cnpj_emit   varchar2(14)
                                           , dm_ind_emit     number(1)
                                           , dm_ind_oper     number(1)
                                           , cod_part        varchar2(60)
                                           , cod_mod         varchar2(2)
                                           , serie           varchar2(3)
                                           , nro_nf          number(9)
                                           , dm_tp_pag       varchar2(2)
                                           , vl_pgto         number(15,2)
                                           , cnpj            varchar2(14)
                                           , dm_tp_band      varchar2(2)
                                           , nro_aut         varchar2(20)
                                           , atributo        varchar2(30)
                                           , valor           varchar2(255));
--
   type t_tab_csf_nf_forma_pgto_ff is table of tab_csf_nf_forma_pgto_ff index by binary_integer;
   vt_tab_csf_nf_forma_pgto_ff t_tab_csf_nf_forma_pgto_ff;

--| informações fiscais da nota fiscal
   -- Nível 1
   type tab_csf_nfinfor_fiscal is record ( cpf_cnpj_emit  varchar2(14)
                                         , dm_ind_emit    number(1)
                                         , dm_ind_oper    number(1)
                                         , cod_part       varchar2(60)
                                         , cod_mod        varchar2(2)
                                         , serie          varchar2(3)
                                         , nro_nf         number(9)
                                         , cod_obs        varchar2(6)
                                         , txt_compl      varchar2(255) );
--
   type t_tab_csf_nfinfor_fiscal is table of tab_csf_nfinfor_fiscal index by binary_integer;
   vt_tab_csf_nfinfor_fiscal t_tab_csf_nfinfor_fiscal;
--
--| informações adicionais da nota fiscal
   -- Nível 1
   type tab_csf_nfinfor_adic is record ( cpf_cnpj_emit  varchar2(14)
                                       , dm_ind_emit    number(1)
                                       , dm_ind_oper    number(1)
                                       , cod_part       varchar2(60)
                                       , cod_mod        varchar2(2)
                                       , serie          varchar2(3)
                                       , nro_nf         number(9)
                                       , dm_tipo        number(1)
                                       , campo          varchar2(256)
                                       , conteudo       varchar2(4000)
                                       , orig_proc      number(1) );
--
   type t_tab_csf_nfinfor_adic is table of tab_csf_nfinfor_adic index by binary_integer;
   vt_tab_csf_nfinfor_adic t_tab_csf_nfinfor_adic;
--
--| informações de cobrança da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_cobr is record ( cpf_cnpj_emit    varchar2(14)
                                           , dm_ind_emit      number(1)
                                           , dm_ind_oper      number(1)
                                           , cod_part         varchar2(60)
                                           , cod_mod          varchar2(2)
                                           , serie            varchar2(3)
                                           , nro_nf           number(9)
                                           , nro_fat          varchar2(60)
                                           , dm_ind_emit_tit  number(1)
                                           , dm_ind_tit       varchar2(2)
                                           , vl_orig          number(15,2)
                                           , vl_desc          number(15,2)
                                           , vl_liq           number(15,2)
                                           , descr_tit        varchar2(255) );
--
   type t_tab_csf_nota_fiscal_cobr is table of tab_csf_nota_fiscal_cobr index by binary_integer;
   vt_tab_csf_nota_fiscal_cobr t_tab_csf_nota_fiscal_cobr;
--
--| informações das duplicatas da cobrança da nota fiscal
   -- Nível 2
   type tab_csf_nf_cobr_dup is record ( cpf_cnpj_emit  varchar2(14)
                                      , dm_ind_emit    number(1)
                                      , dm_ind_oper    number(1)
                                      , cod_part       varchar2(60)
                                      , cod_mod        varchar2(2)
                                      , serie          varchar2(3)
                                      , nro_nf         number(9)
                                      , nro_fat        varchar2(60)
                                      , nro_parc       varchar2(60)
                                      , dt_vencto      date
                                      , vl_dup         number(15,2) );
--
   type t_tab_csf_nf_cobr_dup is table of tab_csf_nf_cobr_dup index by binary_integer;
   vt_tab_csf_nf_cobr_dup t_tab_csf_nf_cobr_dup;
--
--| informações do local de coleta e entrega da nota fiscal local - campos flex field
   -- Nível 1
   type tab_csf_nota_fiscal_local_ff is record ( cpf_cnpj_emit  varchar2(14)
                                               , dm_ind_emit    number(1)
                                               , dm_ind_oper    number(1)
                                               , cod_part       varchar2(60)
                                               , cod_mod        varchar2(2)
                                               , serie          varchar2(3)
                                               , nro_nf         number(9)
                                               , dm_tipo_local  number(1)
                                               , atributo       varchar2(30)
                                               , valor          varchar2(255)
                                               );
--
   type t_tab_csf_nota_fiscal_local_ff is table of tab_csf_nota_fiscal_local_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_localff t_tab_csf_nota_fiscal_local_ff;
--
--| informações do local de coleta e entrega da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_local is record ( cpf_cnpj_emit  varchar2(14)
                                            , dm_ind_emit    number(1)
                                            , dm_ind_oper    number(1)
                                            , cod_part       varchar2(60)
                                            , cod_mod        varchar2(2)
                                            , serie          varchar2(3)
                                            , nro_nf         number(9)
                                            , dm_tipo_local  number(1)
                                            , cnpj           varchar2(14)
                                            , lograd         varchar2(60)
                                            , nro            varchar2(10)
                                            , compl          varchar2(60)
                                            , bairro         varchar2(60)
                                            , cidade         varchar2(60)
                                            , cidade_ibge    number(7)
                                            , uf             varchar2(2)
                                            , dm_ind_carga   number(1)
                                            , cpf            varchar2(11)
                                            , ie             varchar2(15)
                                            );
--
   type t_tab_csf_nota_fiscal_local is table of tab_csf_nota_fiscal_local index by binary_integer;
   vt_tab_csf_nota_fiscal_local t_tab_csf_nota_fiscal_local;
--
--| informações do transporte da nota fiscal
   -- Nível 1
   type tab_csf_nota_fiscal_transp is record ( cpf_cnpj_emit    varchar2(14)
                                             , dm_ind_emit      number(1)
                                             , dm_ind_oper      number(1)
                                             , cod_part         varchar2(60)
                                             , cod_mod          varchar2(2)
                                             , serie            varchar2(3)
                                             , nro_nf           number(9)
                                             , dm_mod_frete     number(1)
                                             , cnpj_cpf         varchar2(14)
                                             , cod_part_transp  varchar2(60)
                                             , nome             varchar2(60)
                                             , ie               varchar2(14)
                                             , ender            varchar2(60)
                                             , cidade           varchar2(60)
                                             , cidade_ibge      number(7)
                                             , uf               varchar2(2)
                                             , vl_serv          number(15,2)
                                             , vl_basecalc_ret  number(15,2)
                                             , aliqicms_ret     number(5,2)
                                             , vl_icms_ret      number(15,2)
                                             , cfop             number(4)
                                             , cpf_mot          number(11)
                                             , nome_mot         varchar2(60) );
--
   type t_tab_csf_nota_fiscal_transp is table of tab_csf_nota_fiscal_transp index by binary_integer;
   vt_tab_csf_nota_fiscal_transp t_tab_csf_nota_fiscal_transp;
--
--| informações de veículos utilizados no transporte da nota fiscal
   -- Nível 2
   type tab_csf_nftransp_veic is record ( cpf_cnpj_emit  varchar2(14)
                                        , dm_ind_emit    number(1)
                                        , dm_ind_oper    number(1)
                                        , cod_part       varchar2(60)
                                        , cod_mod        varchar2(2)
                                        , serie          varchar2(3)
                                        , nro_nf         number(9)
                                        , dm_tipo        number(1)
                                        , placa          varchar2(8)
                                        , uf             varchar2(2)
                                        , rntc           varchar2(20)
                                        , vagao          varchar2(20)
                                        , balsa          varchar2(20) );
--
   type t_tab_csf_nftransp_veic is table of tab_csf_nftransp_veic index by binary_integer;
   vt_tab_csf_nftransp_veic t_tab_csf_nftransp_veic;
--
--| informações de volumes de transporte da nota fiscal
   -- Nível 2
   type tab_csf_nftransp_vol is record ( cpf_cnpj_emit  varchar2(14)
                                       , dm_ind_emit    number(1)
                                       , dm_ind_oper    number(1)
                                       , cod_part       varchar2(60)
                                       , cod_mod        varchar2(2)
                                       , serie          varchar2(3)
                                       , nro_nf         number(9)
                                       , nro_vol        varchar2(60)
                                       , qtdevol        number(15)
                                       , especie        varchar2(60)
                                       , marca          varchar2(60)
                                       , peso_bruto     number(15,3)
                                       , peso_liq       number(15,3) );
--
   type t_tab_csf_nftransp_vol is table of tab_csf_nftransp_vol index by binary_integer;
   vt_tab_csf_nftransp_vol t_tab_csf_nftransp_vol;
--
--| informações de lacres do volume de transporte da nota fiscal
   -- Nível 3
   type tab_csf_nftranspvol_lacre is record ( cpf_cnpj_emit  varchar2(14)
                                            , dm_ind_emit    number(1)
                                            , dm_ind_oper    number(1)
                                            , cod_part       varchar2(60)
                                            , cod_mod        varchar2(2)
                                            , serie          varchar2(3)
                                            , nro_nf         number(9)
                                            , nro_vol        varchar2(60)
                                            , nro_lacre      varchar2(60) );
--
   type t_tab_csf_nftranspvol_lacre is table of tab_csf_nftranspvol_lacre index by binary_integer;
   vt_tab_csf_nftranspvol_lacre t_tab_csf_nftranspvol_lacre;
--
--| informações Complementares do Item da NFe
   -- Nível 1
   type tab_csf_itemnfe_compl_serv is record ( cpf_cnpj_emit           varchar2(14)
                                             , dm_ind_emit             number(1)
                                             , dm_ind_oper             number(1)
                                             , cod_part                varchar2(60)
                                             , cod_mod                 varchar2(2)
                                             , serie                   varchar2(3)
                                             , nro_nf                  number(9)
                                             , nro_item                number
                                             , vl_deducao              number(15,2)
                                             , vl_outra_ret            number(15,2)
                                             , vl_desc_incondicionado  number(15,2)
                                             , vl_desc_condicionado    number(15,2)
                                             , cod_trib_municipio      varchar2(20)
                                             , cod_siscomex            number(4)
                                             , nro_proc                varchar2(30)
                                             , dm_ind_incentivo        number(1)
                                             , cod_mun                 varchar2(7));
--
   type t_tab_csf_itemnfe_compl_serv is table of tab_csf_itemnfe_compl_serv index by binary_integer;
   vt_tab_csf_itemnfe_compl_serv t_tab_csf_itemnfe_compl_serv;
--
--| informações dos itens da nota fiscal
   -- Nível 1
   type tab_csf_item_nota_fiscal is record ( cpf_cnpj_emit        varchar2(14)
                                           , dm_ind_emit          number(1)
                                           , dm_ind_oper          number(1)
                                           , cod_part             varchar2(60)
                                           , cod_mod              varchar2(2)
                                           , serie                varchar2(3)
                                           , nro_nf               number(9)
                                           , nro_item             number
                                           , cod_item             varchar2(60)
                                           , dm_ind_mov           number(1)
                                           , cean                 varchar2(14)
                                           , descr_item           varchar2(120)
                                           , cod_ncm              varchar2(8)
                                           , genero               number(2)
                                           , cod_ext_ipi          varchar2(3)
                                           , cfop                 number(4)
                                           , unid_com             varchar2(6)
                                           , qtde_comerc          number(15,4)
                                           , vl_unit_comerc       number(22,10)
                                           , vl_item_bruto        number(15,2)
                                           , cean_trib            varchar2(14)
                                           , unid_trib            varchar2(6)
                                           , qtde_trib            number(15,4)
                                           , vl_unit_trib         number(22,10)
                                           , vl_frete             number(15,2)
                                           , vl_seguro            number(15,2)
                                           , vl_desc              number(15,2)
                                           , vl_outro             number(15,2)
                                           , dm_ind_tot           number(1)
                                           , infadprod            varchar2(500)
                                           , orig                 number(1)
                                           , dm_mod_base_calc     number(1)
                                           , dm_mod_base_calc_st  number(1)
                                           , cnpj_produtor        varchar2(14)
                                           , qtde_selo_ipi        number(12)
                                           , vl_desp_adu          number(15,2)
                                           , vl_iof               number(15,2)
                                           , cl_enq_ipi           varchar2(5)
                                           , cod_selo_ipi         varchar2(10)
                                           , cod_enq_ipi          varchar2(3)
                                           , cidade_ibge          number(7)
                                           , cd_lista_serv        number(4)
                                           , dm_ind_apur_ipi      number(1)
                                           , cod_cta              varchar2(255)
                                           , pedido_compra        varchar2(15)
                                           , item_pedido_compra   number(6)
                                           , dm_mot_des_icms      number(2)
                                           , dm_cod_trib_issqn    varchar2(1) );
--
   type t_tab_csf_item_nota_fiscal is table of tab_csf_item_nota_fiscal index by binary_integer;
   vt_tab_csf_item_nota_fiscal t_tab_csf_item_nota_fiscal;
--
--| informações dos itens da nota fiscal - campos flex field
   -- Nível 1
   type tab_csf_item_nota_fiscal_ff is record ( cpf_cnpj_emit        varchar2(14)
                                              , dm_ind_emit          number(1)
                                              , dm_ind_oper          number(1)
                                              , cod_part             varchar2(60)
                                              , cod_mod              varchar2(2)
                                              , serie                varchar2(3)
                                              , nro_nf               number(9)
                                              , nro_item             number
                                              , cod_item             varchar2(60)
                                              , atributo             varchar2(30)
                                              , valor                varchar2(255));
--
   type t_tab_csf_item_nota_fiscal_ff is table of tab_csf_item_nota_fiscal_ff index by binary_integer;
   vt_tab_csf_item_nota_fiscal_ff t_tab_csf_item_nota_fiscal_ff;
--
--| informações de impostos do item da nota fiscal
   -- Nível 2
   type tab_csf_imp_itemnf is record ( cpf_cnpj_emit        varchar2(14)
                                     , dm_ind_emit          number(1)
                                     , dm_ind_oper          number(1)
                                     , cod_part             varchar2(60)
                                     , cod_mod              varchar2(2)
                                     , serie                varchar2(3)
                                     , nro_nf               number(9)
                                     , nro_item             number
                                     , cod_imposto          number(3)
                                     , dm_tipo              number(1)
                                     , cod_st               varchar2(3)
                                     , vl_base_calc         number(15,2)
                                     , aliq_apli            number(7,4)
                                     , vl_imp_trib          number(15,2)
                                     , perc_reduc           number(5,2)
                                     , perc_adic            number(5,2)
                                     , qtde_base_calc_prod  number(16,4)
                                     , vl_aliq_prod         number(15,4)
                                     , perc_bc_oper_prop    number(5,2)
                                     , ufst                 varchar2(2)
                                     , vl_bc_st_ret         number(15,2)
                                     , vl_icmsst_ret        number(15,2)
                                     , vl_bc_st_dest        number(15,2)
                                     , vl_icmsst_dest       number(15,2) );
--
   type t_tab_csf_imp_itemnf is table of tab_csf_imp_itemnf index by binary_integer;
   vt_tab_csf_imp_itemnf t_tab_csf_imp_itemnf;
--
--| informações de impostos do item da nota fiscal - campos flex field
   -- Nível 2
   type tab_csf_imp_itemnf_ff is record ( cpf_cnpj_emit  varchar2(14)
                                        , dm_ind_emit    number(1)
                                        , dm_ind_oper    number(1)
                                        , cod_part       varchar2(60)
                                        , cod_mod        varchar2(2)
                                        , serie          varchar2(3)
                                        , nro_nf         number(9)
                                        , nro_item       number
                                        , cod_imposto    number(3)
                                        , dm_tipo        number(1)
                                        , atributo       varchar2(30)
                                        , valor          varchar2(255) );
--
   type t_tab_csf_imp_itemnf_ff is table of tab_csf_imp_itemnf_ff index by binary_integer;
   vt_tab_csf_imp_itemnf_ff t_tab_csf_imp_itemnf_ff;
--
--| informações de grupo de tributação do imposto ICMS para UF do destinatário do item da nota fiscal
   -- Nível 2
   type tab_csf_imp_itemnficmsdest is record ( cpf_cnpj_emit           varchar2(14)
                                             , dm_ind_emit             number(1)
                                             , dm_ind_oper             number(1)
                                             , cod_part                varchar2(60)
                                             , cod_mod                 varchar2(2)
                                             , serie                   varchar2(3)
                                             , nro_nf                  number(9)
                                             , nro_item                number
                                             , cod_imposto             number(3)
                                             , dm_tipo                 number(1)
                                             , vl_bc_uf_dest           number(15,2)
                                             , perc_icms_uf_dest       number(7,4)
                                             , perc_icms_inter         number(7,4)
                                             , perc_icms_inter_part    number(7,4)
                                             , vl_icms_uf_dest         number(15,2)
                                             , vl_icms_uf_remet        number(15,2)
                                             , perc_comb_pobr_uf_dest  number(7,4)
                                             , vl_comb_pobr_uf_dest    number(15,2) );
--
   type t_tab_csf_imp_itemnficmsdest is table of tab_csf_imp_itemnficmsdest index by binary_integer;
   vt_tab_csf_imp_itemnficmsdest t_tab_csf_imp_itemnficmsdest;
--
--| informações de impostos da partilha do do item da nota fiscal - campos flex field
   -- Nível 2
   type tab_csf_impitnficmsdest_ff is record ( cpf_cnpj_emit  varchar2(14)
                                             , dm_ind_emit    number(1)
                                             , dm_ind_oper    number(1)
                                             , cod_part       varchar2(60)
                                             , cod_mod        varchar2(2)
                                             , serie          varchar2(3)
                                             , nro_nf         number(9)
                                             , nro_item       number
                                             , cod_imposto    number(3)
                                             , dm_tipo        number(1)
                                             , atributo       varchar2(30)
                                             , valor          varchar2(255)
                                             );
--
   type t_tab_csf_impitnficmsdest_ff is table of tab_csf_impitnficmsdest_ff index by binary_integer;
   vt_tab_csf_impitnficmsdest_ff t_tab_csf_impitnficmsdest_ff;
--
--| informações do detalhamento do NCM: NVE
   -- Nível 2
   type tab_csf_itemnf_nve is record ( cpf_cnpj_emit        varchar2(14)
                                     , dm_ind_emit          number(1)
                                     , dm_ind_oper          number(1)
                                     , cod_part             varchar2(60)
                                     , cod_mod              varchar2(2)
                                     , serie                varchar2(3)
                                     , nro_nf               number(9)
                                     , nro_item             number
                                     , nve                  varchar2(6) );
--
   type t_tab_csf_itemnf_nve is table of tab_csf_itemnf_nve index by binary_integer;
   vt_tab_csf_itemnf_nve t_tab_csf_itemnf_nve;
--
--| informações do Controle de Exportação por Item
   -- Nível 2
   type tab_csf_itemnf_export is record ( cpf_cnpj_emit        varchar2(14)
                                        , dm_ind_emit          number(1)
                                        , dm_ind_oper          number(1)
                                        , cod_part             varchar2(60)
                                        , cod_mod              varchar2(2)
                                        , serie                varchar2(3)
                                        , nro_nf               number(9)
                                        , nro_item             number
                                        , num_acdraw           number(11)
                                        , num_reg_export       number(12)
                                        , chv_nfe_export       varchar2(44)
                                        , qtde_export          number(15,4));
--
   type t_tab_csf_itemnf_export is table of tab_csf_itemnf_export index by binary_integer;
   vt_tab_csf_itemnf_export t_tab_csf_itemnf_export;
--
--| Informações complementares do item da nota fiscal.
   -- Nível 3
   type tab_csf_itemnf_export_compl is record ( cpf_cnpj_emit varchar2(14)
                                              , dm_ind_emit   number(1)
                                              , dm_ind_oper   number(1)
                                              , cod_part      varchar2(60)
                                              , cod_mod       varchar2(2)
                                              , serie         varchar2(3)
                                              , nro_nf        number(9)
                                              , nro_item      number
                                              , num_acdraw    number(11)
                                              , dm_ind_doc    number(1)
                                              , nro_de        varchar2(14)
                                              , dt_de         date
                                              , dm_nat_exp    number(1)
                                              , nro_re        number(12)
                                              , dt_re         date
                                              , chc_emb       varchar2(18)
                                              , dt_chc        date
                                              , dt_avb        date
                                              , dm_tp_chc     varchar2(2)
                                              , nr_memo       number
                                              );
   --
   type t_tab_csf_itemnf_export_compl is table of tab_csf_itemnf_export_compl index by binary_integer;
   vt_tab_csf_itemnf_export_compl t_tab_csf_itemnf_export_compl;
--
--| registros de combustíveis do item da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_comb is record ( cpf_cnpj_emit         varchar2(14)
                                      , dm_ind_emit           number(1)
                                      , dm_ind_oper           number(1)
                                      , cod_part              varchar2(60)
                                      , cod_mod               varchar2(2)
                                      , serie                 varchar2(3)
                                      , nro_nf                number(9)
                                      , nro_item              number
                                      , codprodanp            number(9)
                                      , codif                 number(21)
                                      , qtde_temp             number(16,4)
                                      , qtde_bc_cide          number(16,4)
                                      , vl_aliq_prod_cide     number(15,4)
                                      , vl_cide               number(15,2)
                                      , vl_base_calc_icms     number(15,2)
                                      , vl_icms               number(15,2)
                                      , vl_base_calc_icms_st  number(15,2)
                                      , vl_icms_st            number(15,2)
                                      , vl_bc_icms_st_dest    number(15,2)
                                      , vl_icms_st_dest       number(15,2)
                                      , vl_bc_icms_st_cons    number(15,2)
                                      , vl_icms_st_cons       number(15,2)
                                      , uf_cons               varchar2(2)
                                      , nro_passe             varchar2(255) );
--
   type t_tab_csf_itemnf_comb is table of tab_csf_itemnf_comb index by binary_integer;
   vt_tab_csf_itemnf_comb t_tab_csf_itemnf_comb;
--
--| registros de combustíveis do item da nota fiscal - campos Flex Field
   -- Nível 3
   type tab_csf_itemnf_comb_ff is record ( cpf_cnpj_emit         varchar2(14)
                                          , dm_ind_emit           number(1)
                                          , dm_ind_oper           number(1)
                                          , cod_part              varchar2(60)
                                          , cod_mod               varchar2(2)
                                          , serie                 varchar2(3)
                                          , nro_nf                number(9)
                                          , nro_item              number
                                          , atributo              varchar2(30)
                                          , valor                 varchar2(255) );
--
   type t_tab_csf_itemnf_comb_ff is table of tab_csf_itemnf_comb_ff index by binary_integer;
   vt_tab_csf_itemnf_comb_ff t_tab_csf_itemnf_comb_ff;
--
--| informações de veículos do item da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_veic is record ( cpf_cnpj_emit     varchar2(14)
                                      , dm_ind_emit       number(1)
                                      , dm_ind_oper       number(1)
                                      , cod_part          varchar2(60)
                                      , cod_mod           varchar2(2)
                                      , serie             varchar2(3)
                                      , nro_nf            number(9)
                                      , nro_item          number
                                      , dm_tp_oper        number(1)
                                      , dm_ind_veic_oper  number(1)
                                      , chassi            varchar2(17)
                                      , cod_cor           varchar2(4)
                                      , descr_cor         varchar2(40)
                                      , potencia_motor    varchar2(4)
                                      , cm3               varchar2(4)
                                      , peso_liq          varchar2(9)
                                      , peso_bruto        varchar2(9)
                                      , nro_serie         varchar2(9)
                                      , tipo_combust      varchar2(8)
                                      , nro_motor         varchar2(21)
                                      , cmkg              varchar2(9)
                                      , dist_entre_eixo   varchar2(4)
                                      , renavam           varchar2(11)
                                      , ano_mod           number(4)
                                      , ano_fabr          number(4)
                                      , tp_pintura        varchar2(1)
                                      , tp_veiculo        number(2)
                                      , esp_veiculo       number(1)
                                      , vin               varchar2(1)
                                      , dm_cond_veic      number(1)
                                      , cod_marca_modelo  number(6)
                                      , cilin             number(4)
                                      , tp_comb           varchar2(2)
                                      , cmt               varchar2(9)
                                      , cod_cor_detran    varchar2(2)
                                      , cap_max_lotacao   number(3)
                                      , dm_tp_restricao   number(1) );
--
   type t_tab_csf_itemnf_veic is table of tab_csf_itemnf_veic index by binary_integer;
   vt_tab_csf_itemnf_veic t_tab_csf_itemnf_veic;
--
--| informações de medicamentos da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_med is record ( cpf_cnpj_emit  varchar2(14)
                                     , dm_ind_emit    number(1)
                                     , dm_ind_oper    number(1)
                                     , cod_part       varchar2(60)
                                     , cod_mod        varchar2(2)
                                     , serie          varchar2(3)
                                     , nro_nf         number(9)
                                     , nro_item       number
                                     , nro_lote       varchar2(20)
                                     , dm_tp_prod     number(1)
                                     , dm_ind_med     number(1)
                                     , qtde_lote      number(11,3)
                                     , dt_fabr        date
                                     , dt_valid       date
                                     , vl_tab_max     number(15,2) );
--
   type t_tab_csf_itemnf_med is table of tab_csf_itemnf_med index by binary_integer;
   vt_tab_csf_itemnf_med t_tab_csf_itemnf_med;
--
--| registros de Medicadmentos do item da nota fiscal - campos Flex Field
   -- Nível 3
   type tab_csf_itemnf_med_ff is record ( cpf_cnpj_emit         varchar2(14)
                                        , dm_ind_emit           number(1)
                                        , dm_ind_oper           number(1)
                                        , cod_part              varchar2(60)
                                        , cod_mod               varchar2(2)
                                        , serie                 varchar2(3)
                                        , nro_nf                number(9)
                                        , nro_item              number
                                        , nro_lote              varchar2(20)
                                        , atributo              varchar2(30)
                                        , valor                 varchar2(255)
                                        );
--
   type t_tab_csf_itemnf_med_ff is table of tab_csf_itemnf_med_ff index by binary_integer;
   vt_tab_csf_itemnf_med_ff t_tab_csf_itemnf_med_ff;
--
--| informações de armamentos do item da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_arma is record ( cpf_cnpj_emit  varchar2(14)
                                      , dm_ind_emit    number(1)
                                      , dm_ind_oper    number(1)
                                      , cod_part       varchar2(60)
                                      , cod_mod        varchar2(2)
                                      , serie          varchar2(3)
                                      , nro_nf         number(9)
                                      , nro_item       number
                                      , dm_ind_arm     number(1)
                                      , nro_serie      number(15)
                                      , nro_cano       number(15)
                                      , descr_compl    varchar2(255) );
--
   type t_tab_csf_itemnf_arma is table of tab_csf_itemnf_arma index by binary_integer;
   vt_tab_csf_itemnf_arma t_tab_csf_itemnf_arma;
--
--| informações de declarações de importação do item da nota fiscal
   -- Nível 2
   type tab_csf_itemnf_dec_impor is record ( cpf_cnpj_emit    varchar2(14)
                                           , dm_ind_emit      number(1)
                                           , dm_ind_oper      number(1)
                                           , cod_part         varchar2(60)
                                           , cod_mod          varchar2(2)
                                           , serie            varchar2(3)
                                           , nro_nf           number(9)
                                           , nro_item         number
                                           , nro_di           varchar2(15)
                                           , dt_di            date
                                           , local_desemb     varchar2(60)
                                           , uf_desemb        varchar2(2)
                                           , dt_desemb        date
                                           , cod_part_export  varchar2(60)
                                           , dm_cod_doc_imp   number(1) );
--
   type t_tab_csf_itemnf_dec_impor is table of tab_csf_itemnf_dec_impor index by binary_integer;
   vt_tab_csf_itemnf_dec_impor t_tab_csf_itemnf_dec_impor;
--
--| informações de declarações de importação do item da nota fiscal - campos Flex Field
   -- Nível 3
   type tab_csf_itemnf_dec_impor_ff is record ( cpf_cnpj_emit    varchar2(14)
                                               , dm_ind_emit      number(1)
                                               , dm_ind_oper      number(1)
                                               , cod_part         varchar2(60)
                                               , cod_mod          varchar2(2)
                                               , serie            varchar2(3)
                                               , nro_nf           number(9)
                                               , nro_item         number
                                               , nro_di           varchar2(15)
                                               , atributo         varchar2(30)
                                               , valor            varchar2(255) );
--
   type t_tab_csf_itemnf_dec_impor_ff is table of tab_csf_itemnf_dec_impor_ff index by binary_integer;
   vt_tab_csf_itemnf_dec_impor_ff t_tab_csf_itemnf_dec_impor_ff;
--
--| informações das adições da declaração de importação do item da nota fiscal
   -- Nível 3
   type tab_csf_itemnfdi_adic is record ( cpf_cnpj_emit   varchar2(14)
                                        , dm_ind_emit     number(1)
                                        , dm_ind_oper     number(1)
                                        , cod_part        varchar2(60)
                                        , cod_mod         varchar2(2)
                                        , serie           varchar2(3)
                                        , nro_nf          number(9)
                                        , nro_item        number
                                        , nro_di          varchar2(15)
                                        , nro_adicao      number(3)
                                        , nro_seq_adic    number(3)
                                        , cod_fabricante  varchar2(60)
                                        , vl_desc_di      number(15,2)
                                        );
--
   type t_tab_csf_itemnfdi_adic is table of tab_csf_itemnfdi_adic index by binary_integer;
   vt_tab_csf_itemnfdi_adic t_tab_csf_itemnfdi_adic;
--
--| informações das adições da declaração de importação do item da nota fiscal
   -- Nível 3
   type tab_csf_itemnfdi_adic_ff is record ( cpf_cnpj_emit   varchar2(14)
                                           , dm_ind_emit     number(1)
                                           , dm_ind_oper     number(1)
                                           , cod_part        varchar2(60)
                                           , cod_mod         varchar2(2)
                                           , serie           varchar2(3)
                                           , nro_nf          number(9)
                                           , nro_item        number
                                           , nro_di          varchar2(15)
                                           , nro_adicao      number(3)
                                           , atributo        varchar2(30)
                                           , valor           varchar2(255)
                                           );
--
   type t_tab_csf_itemnfdi_adic_ff is table of tab_csf_itemnfdi_adic_ff index by binary_integer;
   vt_tab_csf_itemnfdi_adic_ff t_tab_csf_itemnfdi_adic_ff;
--
--| Informações do diferencial de aliquota  do item da nota fiscal
  type tab_csf_itemnf_dif_aliq is record ( cpf_cnpj_emit    varchar2(14)
                                         , dm_ind_emit      number(1)
                                         , dm_ind_oper      number(1)
                                         , cod_part         varchar2(60)
                                         , cod_mod          varchar2(2)
                                         , serie            varchar2(3)
                                         , nro_nf           number(9)
                                         , nro_item         number
                                         , aliq_orig        number(5,2)
                                         , aliq_ie          number(5,2)
                                         , vl_bc_icms       number(15,2)
                                         , vl_dif_aliq      number(15,2)
                                         );
--
  type t_tab_csf_itemnf_dif_aliq is table of tab_csf_itemnf_dif_aliq index by binary_integer;
  vt_tab_csf_itemnf_dif_aliq t_tab_csf_itemnf_dif_aliq;
--
--| Informações do Rastreabilidade de produto
  type tab_csf_itemnf_rastreab is record ( cpf_cnpj_emit    varchar2(14)
                                         , dm_ind_emit      number(1)
                                         , dm_ind_oper      number(1)
                                         , cod_part         varchar2(60)
                                         , cod_mod          varchar2(2)
                                         , serie            varchar2(3)
                                         , nro_nf           number(9)
                                         , nro_item         number
                                         , nro_lote         varchar2(20)
                                         , qtde_lote        number(11,3)
                                         , dt_fabr          date
                                         , dt_valid         date
                                         , cod_agreg        varchar2(20)
                                         );
--
  type t_tab_csf_itemnf_rastreab is table of tab_csf_itemnf_rastreab index by binary_integer;
  vt_tab_csf_itemnf_rastreab t_tab_csf_itemnf_rastreab;
--
--| Tabela/view de Ressarcimento de ICMS em operações com substituição Tributária do Item da Nota Fiscal
  type tab_csf_itemnf_res_icms_st is record ( cpf_cnpj_emit                varchar2(14)
                                            , dm_ind_emit                  number(1)
                                            , dm_ind_oper                  number(1)
                                            , cod_part                     varchar2(60)
                                            , cod_mod                      varchar2(2)
                                            , serie                        varchar2(3)
                                            , nro_nf                       number(9)
                                            , nro_item                     number(3)
                                            , cod_mod_e                    varchar2(2)
                                            , num_doc_ult_e                number(9)
                                            , ser_ult_e                    varchar2(3)
                                            , dt_ult_e                     date
                                            , cod_part_e                   varchar2(60)
                                            , quant_ult_e                  number(12,3)
                                            , vl_unit_ult_e                number(15,3)
                                            , vl_unit_bc_st                number(15,3)
                                            , vl_unit_limite_bc_icms_ult_e number(15,2)
                                            , vl_unit_icms_ult_e           number(15,3)
                                            , aliq_st_ult_e                number(3,2)
                                            , vl_unit_res                  number(15,3)
                                            , dm_cod_resp_ret              number(1)
                                            , dm_cod_mot_res               number(1)
                                            , chave_nfe_ret                varchar2(44)
                                            , cod_part_nfe_ret             varchar2(60)
                                            , ser_nfe_ret                  varchar2(3)
                                            , num_nfe_ret                  number(9)
                                            , item_nfe_ret                 number(3)
                                            , dm_cod_da                    varchar2(1)
                                            , num_da                       varchar2(255)
                                            , chave_nfe_ult_e              varchar2(44)
                                            , num_item_ult_e               number(3)
                                            , vl_unit_bc_icms_ult_e        number(15,3)
                                            , aliq_icms_ult_e              number(5,2)
                                            , vl_unit_res_fcp_st           number(15,2)
                                            );
--
  type t_tab_csf_itemnf_res_icms_st is table of tab_csf_itemnf_res_icms_st index by binary_integer;
  vt_tab_csf_itemnf_res_icms_st t_tab_csf_itemnf_res_icms_st;
--
--| Informações do ajuste  do item da nota fiscal
  type tab_csf_inf_prov_docto_fisc is record ( cpf_cnpj_emit    varchar2(14)
                                             , dm_ind_emit      number(1)
                                             , dm_ind_oper      number(1)
                                             , cod_part         varchar2(60)
                                             , cod_mod          varchar2(2)
                                             , serie            varchar2(3)
                                             , nro_nf           number(9)
                                             , cod_obs          varchar2(6)
                                             , cod_aj           varchar2(10)
                                             , nro_item         number
                                             , descr_compl_aj   varchar2(255)
                                             , vl_bc_icms       number(15,2)
                                             , aliq_icms        number(5,2)
                                             , vl_icms          number(15,2)
                                             , vl_outros        number(15,2)
                                             );
--
  type t_tab_csf_inf_prov_docto_fisc is table of tab_csf_inf_prov_docto_fisc index by binary_integer;
  vt_tab_csf_inf_prov_docto_fisc t_tab_csf_inf_prov_docto_fisc;
--

--| informações de aquisição de cana-de-açúcar
    type tab_csf_nf_aquis_cana is record ( cpf_cnpj_emit   varchar2(14)
                                         , dm_ind_emit     number(1)
                                         , dm_ind_oper     number(1)
                                         , cod_part        varchar2(60)
                                         , cod_mod         varchar2(2)
                                         , serie           varchar2(3)
                                         , nro_nf          number(9)
                                         , safra           varchar2(9)
                                         , mes_ano_ref     varchar2(9)
                                         , qtde_total_mes  number(21,10)
                                         , qtde_total_ant  number(21,10)
                                         , qtde_total_ger  number(21,10)
                                         , vl_forn         number(15,2)
                                         , vl_total_ded    number(15,2)
                                         , vl_liq_forn     number(15,2) );
--
   type t_tab_csf_nf_aquis_cana is table of tab_csf_nf_aquis_cana index by binary_integer;
   vt_tab_csf_nf_aquis_cana t_tab_csf_nf_aquis_cana;
--
--| informações de aquisição de cana-de-açúcar por dia.
   type tab_csf_nf_aquis_cana_dia is record ( cpf_cnpj_emit   varchar2(14)
                                            , dm_ind_emit     number(1)
                                            , dm_ind_oper     number(1)
                                            , cod_part        varchar2(60)
                                            , cod_mod         varchar2(2)
                                            , serie           varchar2(3)
                                            , nro_nf          number(9)
                                            , safra           varchar2(9)
                                            , mes_ano_ref     varchar2(9)
                                            , dia             number(2)
                                            , qtde            number(21,10) );
--
   type t_tab_csf_nf_aquis_cana_dia is table of tab_csf_nf_aquis_cana_dia index by binary_integer;
   vt_tab_csf_nf_aquis_cana_dia t_tab_csf_nf_aquis_cana_dia;
--
--| informações de dedução da aquisição de cana-de-açúcar
   type tab_csf_nf_aquis_cana_ded is record ( cpf_cnpj_emit   varchar2(14)
                                            , dm_ind_emit     number(1)
                                            , dm_ind_oper     number(1)
                                            , cod_part        varchar2(60)
                                            , cod_mod         varchar2(2)
                                            , serie           varchar2(3)
                                            , nro_nf          number(9)
                                            , safra           varchar2(9)
                                            , mes_ano_ref     varchar2(9)
                                            , deducao         varchar2(60)
                                            , vl_ded          number(15,2) );
--
   type t_tab_csf_nf_aquis_cana_ded is table of tab_csf_nf_aquis_cana_ded index by binary_integer;
   vt_tab_csf_nf_aquis_cana_ded t_tab_csf_nf_aquis_cana_ded;
--
--|  informações de NF de fornecedores a serem impressas na DANFE (Romaneio)
   type tab_csf_inf_nf_romaneio is record ( cpf_cnpj_emit   varchar2(14)
                                          , dm_ind_emit     number(1)
                                          , dm_ind_oper     number(1)
                                          , cod_part        varchar2(60)
                                          , cod_mod         varchar2(2)
                                          , serie           varchar2(3)
                                          , nro_nf          number(9)
                                          , cnpj_cpf_forn   varchar2(20)
                                          , nro_nf_forn     number(9)
                                          , serie_forn      varchar2(3)
                                          , dt_emiss_forn   date
                                          );
--
   type t_tab_csf_inf_nf_romaneio is table of tab_csf_inf_nf_romaneio index by binary_integer;
   vt_tab_csf_inf_nf_romaneio t_tab_csf_inf_nf_romaneio;
--
--|  informações de Agendamento de Transporte
   type tab_csf_nf_agend_transp is record ( cpf_cnpj_emit   varchar2(14)
                                          , dm_ind_emit     number(1)
                                          , dm_ind_oper     number(1)
                                          , cod_part        varchar2(60)
                                          , cod_mod         varchar2(2)
                                          , serie           varchar2(3)
                                          , nro_nf          number(9)
                                          , pedido          varchar2(60)
                                          );
--
   type t_tab_csf_nf_agend_transp is table of tab_csf_nf_agend_transp index by binary_integer;
   vt_tab_csf_nf_agend_transp t_tab_csf_nf_agend_transp;
--
--|  informações de Observações do Agendamento de Transporte
   type tab_csf_nf_obs_agend_transp is record ( cpf_cnpj_emit   varchar2(14)
                                              , dm_ind_emit     number(1)
                                              , dm_ind_oper     number(1)
                                              , cod_part        varchar2(60)
                                              , cod_mod         varchar2(2)
                                              , serie           varchar2(3)
                                              , nro_nf          number(9)
                                              , dm_tipo         varchar2(1)
                                              , codigo          varchar2(30)
                                              , obs             varchar2(500)
                                              );
--
   type t_tab_csf_nf_obs_agend_transp is table of tab_csf_nf_obs_agend_transp index by binary_integer;
   vt_tab_csf_nf_obs_agend_transp t_tab_csf_nf_obs_agend_transp;
--
--| informações para o cancelamento da nota fiscal
   type tab_csf_nota_fiscal_canc is record ( cpf_cnpj_emit  varchar2(14)
                                           , dm_ind_emit    number(1)
                                           , dm_ind_oper    number(1)
                                           , cod_part       varchar2(60)
                                           , cod_mod        varchar2(2)
                                           , serie          varchar2(3)
                                           , nro_nf         number(9)
                                           , dt_canc        date
                                           , justif         varchar2(255) );
--
   type t_tab_csf_nota_fiscal_canc is table of tab_csf_nota_fiscal_canc index by binary_integer;
   vt_tab_csf_nota_fiscal_canc t_tab_csf_nota_fiscal_canc;
--
--| informações para inutilização de nota fiscla
   type tab_csf_inutiliza_nf is record ( cpf_cnpj_emit   varchar2(14)
                                       , ano             number(4)
                                       , serie           varchar2(3)
                                       , nro_ini         number(9)
                                       , nro_fim         number(9)
                                       , justif          varchar2(255)
                                       , dm_st_proc      number(1)
                                       );
--
   type t_tab_csf_inutiliza_nf is table of tab_csf_inutiliza_nf index by binary_integer;
   vt_tab_csf_inutiliza_nf t_tab_csf_inutiliza_nf;
--

--| Informações Complementares de Transporte do Item da Nota Fiscal
   type tab_csf_itemnf_compl_transp is record ( cpf_cnpj_emit   varchar2(14)
                                              , dm_ind_emit     number(1)
                                              , dm_ind_oper     number(1)
                                              , cod_part        varchar2(60)
                                              , cod_mod         varchar2(2)
                                              , serie           varchar2(3)
                                              , nro_nf          number(9)
                                              , nro_item        number
                                              , qtde_prod       number(16,6)
                                              , qtde_emb        number(16,6)
                                              , peso_bruto      number(16,6)
                                              , peso_liq        number(16,6)
                                              , volume          number(16,6)
                                              , s_num_cot       number(20)
                                              , cnl_cli         varchar2(10)
                                              , cnl_cli_des     varchar2(100)
                                              , alq_pis         number(7,3)
                                              , ind_rec_pis     varchar2(1)
                                              , alq_cofins      number(7,3)
                                              , ind_rec_cofins  varchar2(1)
                                              );
--
   type t_tab_csf_itemnf_compl_transp is table of tab_csf_itemnf_compl_transp index by binary_integer;
   vt_tab_csf_itemnf_compl_transp t_tab_csf_itemnf_compl_transp;
--
--| Informações Complementares da Nota Fiscal
   type tab_csf_nota_fiscal_compl is record ( cpf_cnpj_emit        varchar2(14)
                                            , dm_ind_emit          number(1)
                                            , dm_ind_oper          number(1)
                                            , cod_part             varchar2(60)
                                            , cod_mod              varchar2(2)
                                            , serie                varchar2(3)
                                            , nro_nf               number(9)
                                            , nro_chave_nfe        varchar2(44)
                                            , id_erp               number
                                            , sub_serie            number(3)
                                            , cod_infor            varchar2(6)
                                            , cod_cta              varchar2(30)
                                            , cod_cons             varchar2(2)
                                            , dm_tp_ligacao        number(1)
                                            , dm_cod_grupo_tensao  varchar2(2)
                                            , dm_tp_assinante      number(1)
                                            , nro_ord_emb          number
                                            , seq_nro_ord_emb      number
                                            );
--
   type t_tab_csf_nota_fiscal_compl is table of tab_csf_nota_fiscal_compl index by binary_integer;
   vt_tab_csf_nota_fiscal_compl t_tab_csf_nota_fiscal_compl;
--
--| Informações Complementares do Item da Nota Fiscal
   type tab_csf_itemnf_compl is record ( cpf_cnpj_emit   varchar2(14)
                                       , dm_ind_emit     number(1)
                                       , dm_ind_oper     number(1)
                                       , cod_part        varchar2(60)
                                       , cod_mod         varchar2(2)
                                       , serie           varchar2(3)
                                       , nro_nf          number(9)
                                       , nro_item        number
                                       , id_item_erp     number
                                       , cod_class       varchar2(4)
                                       , dm_ind_rec      number(1)
                                       , cod_part_item   varchar2(60)
                                       , dm_ind_rec_com  number(1)
                                       , cod_nat         varchar2(10)
                                       );
--
   type t_tab_csf_itemnf_compl is table of tab_csf_itemnf_compl index by binary_integer;
   vt_tab_csf_itemnf_compl t_tab_csf_itemnf_compl;
--
--
--| informações de cupom fiscal eletronico referenciado
   -- Nível 1
   type tab_csf_cfe_ref is record ( cpf_cnpj_emit         varchar2(14)
                                  , dm_ind_emit           number(1)
                                  , dm_ind_oper           number(1)
                                  , cod_part              varchar2(60)
                                  , cod_mod               varchar2(2)
                                  , serie                 varchar2(3)
                                  , nro_nf                number(9)
                                  , cod_mod_ref           varchar2(2)
                                  , nr_sat                varchar2(9)
                                  , chv_cfe               varchar2(44)
                                  , num_cfe               number(6)
                                  , dt_doc                date
                                  );
--
   type t_tab_csf_cfe_ref is table of tab_csf_cfe_ref index by binary_integer;
   vt_tab_csf_cfe_ref t_tab_csf_cfe_ref;
--

--| informações de CCe
   -- Nível 1
   type tab_csf_nota_fiscal_cce is record ( cpf_cnpj_emit         varchar2(14)
                                          , dm_ind_emit           number(1)
                                          , dm_ind_oper           number(1)
                                          , cod_part              varchar2(60)
                                          , cod_mod               varchar2(2)
                                          , serie                 varchar2(3)
                                          , nro_nf                number(9)
                                          , dm_st_proc            number(2)
                                          , correcao              varchar2(1000)
                                          , cod_msg               varchar2(4)
                                          , motivo_resp           varchar2(4000)
                                          , dt_hr_reg_evento      date
                                          , nro_protocolo         number(15)
                                          , dm_leitura            number(1)
                                          );
--
   type t_tab_csf_nota_fiscal_cce is table of tab_csf_nota_fiscal_cce index by binary_integer;
   vt_tab_csf_nota_fiscal_cce t_tab_csf_nota_fiscal_cce;
--

--| Informações de Consulta de chave de acesso
   -- Nível 1
   type tab_csf_cons_chave_nfe is record ( cpf_cnpj_emit  varchar2(14)
                                         , unid_org       varchar2(20)
                                         , nro_chave_nfe  varchar2(44)
                                         , dm_situacao    number(1)
                                         , cstat          varchar2(3)
                                         , xmotivo        varchar2(255)
                                         , dhrecbto       date
                                         , nprot          varchar2(15)
                                         , dm_leitura     number(1)
                                         );
--
   type t_tab_csf_cons_chave_nfe is table of tab_csf_cons_chave_nfe index by binary_integer;
   vt_tab_csf_cons_chave_nfe t_tab_csf_cons_chave_nfe;
--
--| informações para o cancelamento da nota fiscal
   type tab_csf_nota_fiscal_canc_ff is record ( cpf_cnpj_emit  varchar2(14)
                                           , dm_ind_emit    number(1)
                                           , dm_ind_oper    number(1)
                                           , cod_part       varchar2(60)
                                           , cod_mod        varchar2(2)
                                           , serie          varchar2(3)
                                           , nro_nf         number(9)
                                           , atributo       varchar2(30)
                                           , valor          varchar2(255));
--
   type t_tab_csf_nota_fiscal_canc_ff is table of tab_csf_nota_fiscal_canc_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_canc_ff t_tab_csf_nota_fiscal_canc_ff;
--
--|
   type tab_csf_nota_fiscal_inu_ff is record ( cpf_cnpj_emit  VARCHAR2(14)
                                             , ano            NUMBER(4)
                                             , serie          VARCHAR2(3)
                                             , nro_ini        NUMBER(9)
                                             , nro_fim        NUMBER(9)
                                             , atributo       VARCHAR2(30)
                                             , valor          VARCHAR2(255));
--
   type t_tab_csf_nota_fiscal_inu_ff is table of tab_csf_nota_fiscal_inu_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_inu_ff t_tab_csf_nota_fiscal_inu_ff;
--
-- ============================================================================================================================================= --
--
   gv_sql            varchar2(4000) := null;
   gv_where          varchar2(4000) := null;
   gn_rel_part       number := 0;
   gd_dt_ini_integr  date := null;
   gv_resumo         log_generico_nf.resumo%type := null;
   gv_cabec_nf       varchar2(4000) := null;
   gd_formato_dt_erp empresa.formato_dt_erp%type := 'dd/mm/rrrr';
   gn_dm_form_dt_erp empresa_integr_banco.dm_form_dt_erp%type;
--
-- ============================================================================================================================================= --
--
   gv_aspas                   char(1) := null;
   gv_nome_dblink             empresa.nome_dblink%type := null;
   gv_owner_obj               empresa.owner_obj%type := null;
   gn_dm_ret_infor_integr     empresa.dm_ret_infor_integr%type := null;
   gv_sist_orig               sist_orig.sigla%type := null;
   gn_dm_ind_emit             nota_fiscal.dm_ind_emit%type := null;
   -- #69487 alterado objeto de integracao de 6 para 13
   gv_cd_obj                  obj_integr.cd%type := '13';
   gn_multorg_id              mult_org.id%type;
   gn_empresaintegrbanco_id   empresa_integr_banco.id%type;
   gn_empresa_id              empresa.id%type;
   gv_formato_data            param_global_csf.valor%type := null;
   --
   gv_objeto                  varchar2(300);
   gn_fase                    number;
   --
   info_fechamento number;
--
-- ============================================================================================================================================= --
--
-- Procedimento integra as consultas de NFe com o ERP
procedure pkb_int_csf_cons_sit ( en_empresa_id   in empresa.id%type
                               , ev_nome_dblink  in empresa_integr_banco.nome_dblink%type -- ev_nome_dblink
                               , ev_aspas        in varchar2 -- ev_aspas
                               , ev_owner_obj    in empresa_integr_banco.owner_obj%type -- ev_owner_obj
                               );
--
-- ============================================================================================================================================= --
--| Procedimento Gera o Retorno para o ERP
procedure pkb_gera_retorno ( ev_sist_orig in varchar2 default null );
--
-- ============================================================================================================================================= --
-- Procedimento Gera o Retorno para o ERP com a Integração em Bloco
procedure pkb_gera_retorno_bloco ( en_paramintegrdados_id in param_integr_dados.id%type );
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração de Notas Fiscais Eletrônicas de Emissão Própria
-- por meio da integração por Bloco
procedure pkb_int_bloco ( en_paramintegrdados_id  in param_integr_dados.id%type
                        , en_dm_ind_emit          in nota_fiscal.dm_ind_emit%type
                        , ed_dt_ini               in date default null
                        , ed_dt_fin               in date default null
                        , en_empresa_id           in empresa.id%type default null
                        );
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração de Notas Fiscais através do Mult-Org.
-- Esse processo estará sendo executado por JOB SCHEDULER, especifícamente para Ambiente Amazon.
-- A rotina deverá executar o mesmo procedimento da rotina pkb_integracao, porém com a identificação da mult-org.
procedure pkb_integr_multorg ( en_multorg_id in mult_org.id%type );
--
-- ============================================================================================================================================= --
-- Procedimento de integração por período informando todas empresas ativas
procedure pkb_integr_perido_geral ( en_multorg_id in mult_org.id%type
                                  , ed_dt_ini     in date
                                  , ed_dt_fin     in date
                                  );
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração Normal de Notas Fiscais, recuperando todas as empresas
procedure pkb_integr_periodo_normal ( ed_dt_ini       in  date
                                    , ed_dt_fin       in  date
                                    , en_dm_ind_emit  in  nota_fiscal.dm_ind_emit%type default null
                                    );
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração de Notas Fiscais por empresa e período
procedure pkb_integr_periodo ( en_empresa_id   in  empresa.id%type
                             , ed_dt_ini       in  date
                             , ed_dt_fin       in  date
                             , en_dm_ind_emit  in  nota_fiscal.dm_ind_emit%type default null
                             );
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração de Notas Fiscais
procedure pkb_integracao ( ev_sist_orig in varchar2 default null );
--
-- ============================================================================================================================================= --
--
end pk_integr_view_nfce;
/
