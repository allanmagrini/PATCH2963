create or replace package csf_own.pk_csf_api_nfce is
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------
--   
-- Especificação do pacote integração de notas fiscais NFCE modelo 65 para o CSF
--
-- Em 10/02/2021      - Karina de Paula
-- Redmine #75685     - Falha na consulta de status da NF-e (Terceiros)
-- Rotina Alterada    - PKB_CONS_NFE_TERC => Retirado o nf.* e incluído os campos que estão sendo utilizados, alterada a forma de busca do
--                      intervalo para cancelamento, agora a rotina pega o tempo em horas cadastrado no estado e criado um index para melhorar performance
-- Liberado na versão - Release_2.9.7, Patch_2.9.6.2 e Patch_2.9.5.5
--
-- Em 02/02/2021      - Karina de Paula
-- Redmine #75655     - Looping na tabela CSF_OWN.CSF_CONS_SIT após atualização da 2.9.5.0 (NOVA AMERICA)
-- Rotina Alterada    - PKB_CONS_NFE_TERC => Antes da chamada da pkb_ins_atu_csf_cons_sit foi excluída a busca a sequence da csf_cons_sit porque dentro da rotina
--                      pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit é criado um novo id, sendo esse não utilizado
--                      Tambem estava chamando a sequence duas vezes
--                    - PKB_CONS_NFE_TERC => Incluída a chamada da função FKG_CHECA_CHAVE_ENVIO_PENDENTE e retirado select
-- Liberado na versão - Release_2.9.7, Patch_2.9.6.2 e Patch_2.9.5.5
--
-- Em 16/11/2020   - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #73138  - Registro analitico não considerando outros valores do item
-- Rotina Alterada - PKB_GERA_REGIST_ANALIT_IMP - Incluido no calculo de base reduzida de icms os campos "vl_frete", 
--                   "vl_seguro" e "vl_desc" do item da nota fiscal.
--
-- Em 28/10/2020   - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #72338  - Validação do FCp DIFAL - Total X Itens não está ocorrendo
-- Rotina Alterada - PKB_VALIDA_TOTAL_NF - Incluida verificação de FCP DIFAL se o valor na NOTA_FISCAL_TOTAL bate 
--                   com os valores do item na linha do imposto.
--
-- Em 16/10/2020   - Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #72338  - Validação do FCp - Total X Itens não está ocorrendo
-- Rotina Alterada - PKB_VALIDA_TOTAL_NF - Incluida verificação de FCP, FCP retido p/ subst. tributária e FCP retido 
--                   p/ subst. tributária retido anteriormente se o valor na NOTA_FISCAL_TOTAL bate com os valores 
--                   do item na linha do imposto.
--
-- Em 17/08/2020   - Luis Marques - 2.9.5
-- Redmine #58588  - Alterar tamanho de campo NRO_NF
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL - Colocado verificação que a quantidade de dígitos do numero da nota fiscal
--                   para NFC-e não pode ser maior que 9 dígitos.
--
-- Em 03/09/2020   - Luis Marques - 2.9.4-3 / 2.9.5
-- Redmine #71004  - Cancelamento da NFCE pelo portal não esta sendo executado - Aviva
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL_CANC - Foi inserido verificação se o cancelamento for via portal para 
--                   tratar as datas como forma de emissão normal para a efetivação do cancelamento, também a 
--                   verificação de tempo passa para 30 minutos.
-- 
-- Em 25/08/2020  - Karina de Paula
-- Redmine #47204 - Separar integração OI de NFCE
-- Alterações     - PKB_SETA_COD_MOD_NFCE/gv_cod_mod_65 => Excluída essa procedure e todas as chamadas dela
--                  A rotina pk_csf_api_nfce é específica do modelo "65" não tendo necessidade de setar esse valor nos processos
--                  O fato de buscar o valor na tab nota_fiscal estava impedindo a integração por OPENINTERFACE pq a nota ainda não 
--                  existe nas tabelas oficiais
-- Liberado       - Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 31/07/2020   - Luis Marques - 2.9.4-2 / 2.9.5
-- Redmine #70011  - Status "cancelamento" não esta sendo alterado para NFCE - Aviva
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL_CANC - colocado verificação da forma de emissão para atualizar a data
--                   de cancelamento com sysdate, só será alterado se a nota não for forma de emissão 
--                   "9-Contingência off-line da NFC-e".
--
-- Em 21/07/2020   - Luis Marques - 2.9.4-1 / 2.9.5
-- Redmine #68300  - Falha na integração & "E" comercial - WEBSERVICE NFE EMISSAO PROPRIA (OCQ) 
-- Rotina Alterada - PKB_INTEGR_NOTA_FISCAL_EMIT - Colocado nos campos nome,fantasia e lograd pra utiliza no parametro
--                   "en_ret_carac_espec" valor 4 que retira todos os caracteres especiais menos o caracter & (E comercial).
--
-- Em 13/07/2020   - Wendel Albino
-- Redmine #69487  - Falha na integração NFCe - Todas empresas (VENANCIO)
-- Alterações      - pkb_ler_nota_fiscal-> alterada posicao de validacao de cod_mod da nota para receber o cabecalho e gerar erro se houver.
--                 - PKB_SETA_COD_MOD_NFCE -> retirado a atribuicao ao gv_cod_mod_65 := '99' e alterado pra 'XX'
--
-- Em 02/07/2020  - Karina de Paula
-- Redmine #57986 - [PLSQL] PIS e COFINS (ST e Retido) na NFe de Serviços (Brasília)
-- Alterações     - pkb_integr_notafiscal_total_ff/pkb_solic_calc_imp/pkb_atual_nfe_inut/pkb_relac_nfe_cons_sit/pkb_integr_nota_fiscal_total => Inclusão 
--                  dos campos vl_pis_st e vl_cofins_st
-- Liberado       - Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4
--
-- Em 08/06/2020 - Luis Marques - 2.9.3-3 / 2.9.4
-- Redmine #68409 - Ajustar para não verificar forma de pagamento da empresa x nota quando nota for NFCE - mod 65
-- Rotinas alteradas - PKB_GERA_LOTE - Incluir geração de lote para DM_FORMA_EMISS = 9 - ontingência off-line da NFC-e.
--                     PKB_VALIDA_CHAVE_CESSO - Retirar validação de forma de emissão para documentos NFCE modelo 65.
--                     PKB_VALIDA_NF_EMIT - Retirada validação de emitente pois não é obrigatorio para NFCE modelo 65.
--
-- Em 04/06/2020 - Luis Marques - 2.9.3-3 / 2.9.4
-- Redmine #68126 - CST do XML não está subindo para CSF - RELATO DE BUG [200527-1500]
-- Rotina Incluida: PKB_INTEGR_NOTA_FISCAL_CCE - Está sendo chamada na "pk_valida_ambiente_nfce" e não existia
--                  trazida da "pk_csf_api".
--
-- Em 03/06/2020  - Karina de Paula
-- Redmine #62471 - Criar processo de validação da CSF_CONS_SIT
-- Alterações     - PKB_INTEGR_CONS_CHAVE_NFE => Exclusão dessa rotina pq foi substituída pela pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe
--                - PKB_RELAC_NFE_CONS_SIT    => Retirado o update na csf_cons_sit e incluída a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
--                - PKB_CONS_NFE_TERC         => Retirado o insert na csf_cons_sit e incluída a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
-- Liberado       - Release_2.9.4, Patch_2.9.3.3 e Patch_2.9.2.6
--
-- Em 13/03/2020 - Luis Marques - 2.9.3
-- Redmine #63776 - Integração de NFSe - Aumentar Campo Razao Social do Destinatário e Logradouro
-- Rotinas Alteradas - PKB_REG_PESSOA_DEST_NF, PKB_INTEGR_NOTA_FISCAL_DEST, PKB_CRIA_PESSOA_NFE_LEGADO - Alterado para 
--                     recuperar 60 caracteres dos campos nome e lograd da nota_fiscal_dest para todas as validações, 
--                     colocado verificação que se nome ou logradouro campos "nome" e "lograd" vierem com mais de 60 
--                     caracteres será gravado log de erro.
--
-- Em 29/01/2020   - Luis Marques
-- Redmine #63056  - ICMS Desonerado RJ
-- Rotina Alterada - PKB_AJUSTA_TOTAL_NF - Ajustado para considerar o parametro na tabela "PARAM_EFD_ICMS_IPI" campo
--                   "DM_SUBTR_VL_ICMS_DESON" e se estiver marcado como 1 ler o valor do ICMS desonerado para 
--                   subtrair do valor total da nota fiscal.
--
-- Em 18/12/2019 - Allan Magrini
-- Redmine #61174 - Inclusão de modelo de documento 66
-- Adicionado '66' na validação do cod_mod, notas de seviços continuos, fase 1.8 e 99.1
-- Rotina: PKB_INTEGR_NOTA_FISCAL
--
-- Em 10/12/2019   - Karina de Paula
-- Redmine #60469  - Criar novo objeto e tipo de objeto Emissão Própria NFCE (modelo 65)
-- Rotina Alterada - Várias rotinas alteradas pq estava chamando pk_csf_api e não pk_csf_api_nfce
--
-- Em 08/11/2019   - Karina de Paula
-- Redmine #57901  - Criar validação para Verificar o código de benefício fiscal com o estado da empresa emitente
-- Rotina Alterada - PKB_INTEGR_ITEM_NOTA_FISCAL_FF e pkb_integr_inf_prov_docto_fisc => Incluída a verificação da UF do COD_OCOR_AJ_ICMS
--                   pkb_integr_inf_prov_docto_fisc => não estava atualizando os campos itemnf_id e codocorajicms_id na tabela inf_prov_docto_fiscal
--
-- Em 09/10/2019        - Karina de Paula
-- Redmine #52654/59814 - Alterar todas as buscar na tabela PESSOA para retornar o MAX ID
-- Rotinas Alteradas    - Trocada a função pk_csf.fkg_Pessoa_id_cpf_cnpj_interno pela pk_csf.fkg_Pessoa_id_cpf_cnpj
-- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 16/09/2019 - Luis Marques
-- Redmine #58220 - Package de validação 
-- Criação do processo de integração de Notas Fiscais de Consumidor Eletronica - NFCE modelo 65
--
------------------------------------------------------------------------------------------------------------------------------------------------------------------
   --
   gt_row_cf_ref                cupom_fiscal_ref%rowtype;
   gt_row_cfe_ref               cfe_ref%rowtype;
   gt_row_nota_fiscal           nota_fiscal%rowtype;
   gt_row_nf_referen            nota_fiscal_referen%rowtype;
   gt_row_nota_fiscal_emit      nota_fiscal_emit%rowtype;
   gt_row_nota_fiscal_dest      nota_fiscal_dest%rowtype;
   gt_row_nota_fiscal_local     nota_fiscal_local%rowtype;
   gt_row_nota_fiscal_transp    nota_fiscal_transp%rowtype;
   gt_row_nota_fiscal_cobr      nota_fiscal_cobr%rowtype;
   gt_row_nota_fiscal_fisco     nota_fiscal_fisco%rowtype;
   gt_row_nota_fiscal_total     nota_fiscal_total%rowtype;
   gt_row_nota_fiscal_canc      nota_fiscal_canc%rowtype;
   gt_row_nota_fiscal_compl     nota_fiscal_compl%rowtype;
   gt_row_nota_fiscal_cce       nota_fiscal_cce%rowtype;
   gt_row_nfdest_email          nfdest_email%rowtype;
   gt_row_nftransp_vol          nftransp_vol%rowtype;
   gt_row_nftransp_veic         nftransp_veic%rowtype;
   gt_row_nftranspvol_lacre     nftranspvol_lacre%rowtype;
   gt_row_nfcobr_dup            nfcobr_dup%rowtype;
   gt_row_nfinfor_fiscal        nfinfor_fiscal%rowtype;
   gt_row_nfinfor_adic          nfinfor_adic%rowtype;
   gt_row_nfregist_analit       nfregist_analit%rowtype;
   gt_row_nf_compl_oper_pis     nf_compl_oper_pis%rowtype;
   gt_row_nf_compl_oper_cofins  nf_compl_oper_cofins%rowtype;
   gt_row_nf_aquis_cana         nf_aquis_cana%rowtype;
   gt_row_nf_aquis_cana_dia     nf_aquis_cana_dia%rowtype;
   gt_row_nf_aquis_cana_ded     nf_aquis_cana_ded%rowtype;
   gt_row_nf_agend_transp       nf_agend_transp%rowtype;
   gt_row_nf_obs_agend_transp   nf_obs_agend_transp%rowtype;
   gt_row_item_nota_fiscal      item_nota_fiscal%rowtype;
   gt_row_itemnf_dec_impor      itemnf_dec_impor%rowtype;
   gt_row_itemnfdi_adic         itemnfdi_adic%rowtype;
   gt_row_itemnf_veic           itemnf_veic%rowtype;
   gt_row_itemnf_med            itemnf_med%rowtype;
   gt_row_itemnf_arma           itemnf_arma%rowtype;
   gt_row_itemnf_comb           itemnf_comb%rowtype;
   gt_row_itemnf_compl          itemnf_compl%rowtype;
   gt_row_itemnf_compl_transp   itemnf_compl_transp%rowtype;
   gt_row_imp_itemnf            imp_itemnf%rowtype;
   gt_row_imp_itemnficmsdest    imp_itemnf_icms_dest%rowtype;
   gt_row_inf_nf_romaneio       inf_nf_romaneio%rowtype;
   gt_row_inutiliza_nota_fiscal inutiliza_nota_fiscal%rowtype;
   gt_row_lote                  lote%rowtype;
   gt_row_usuempr_unidorg       usuempr_unidorg%rowtype;
   gt_row_itemnf_dif_aliq       itemnf_dif_aliq%rowtype;
   gt_row_r_nf_nf               r_nf_nf%rowtype;
   gt_row_nota_fiscal_mde       nota_fiscal_mde%rowtype;
   gt_row_csf_cons_sit          csf_cons_sit%rowtype;
   gt_row_inf_prov_docto_fiscal inf_prov_docto_fiscal%rowtype;
   gt_row_nf_aut_xml            nf_aut_xml%rowtype;
   gt_row_nf_forma_pgto         nf_forma_pgto%rowtype;
   gt_row_itemnf_nve            itemnf_nve%rowtype; 
   gt_row_itemnf_rastreab       itemnf_rastreab%rowtype;
   gt_row_itemnf_export         itemnf_export%rowtype;
   gt_row_itemnf_export_compl   itemnf_export_compl%rowtype;
   gt_row_itemnf_compl_serv     itemnf_compl_serv%rowtype;
   gt_row_itemnf_res_icms_st    itemnf_res_icms_st%rowtype;
   --
-------------------------------------------------------------------------------------------------------
   --
   gv_cabec_log          log_generico_nf.mensagem%type;
   gv_cabec_log_item     log_generico_nf.mensagem%type;
   gv_mensagem_log       log_generico_nf.mensagem%type;
   gn_processo_id        log_generico_nf.processo_id%type := null;
   gv_obj_referencia     log_generico_nf.obj_referencia%type default 'NOTA_FISCAL';
   gn_referencia_id      log_generico_nf.referencia_id%type := null;
   --
   gv_dominio            dominio.descr%type;
   gn_notafiscal_id      nota_fiscal.id%type;
   gn_dm_tp_amb          empresa.dm_tp_amb%type := null;
   gn_empresa_id         empresa.id%type := null;
   gn_tipo_integr        number := null;
   --
   gv_objeto             varchar2(300);
   gn_fase               number;
   --
-------------------------------------------------------------------------------------------------------

-- Declaração de constantes

   erro_de_validacao       constant number := 1;
   erro_de_sistema         constant number := 2;
   nota_fiscal_integrada   constant number := 16;
   cons_sit_nfe_sefaz      constant number := 30;
   info_canc_nfe           constant number := 31;
   informacao              constant number := 35;
   INFO_CALC_FISCAL        constant number := 38;
   gv_cd_obj               obj_integr.cd%type;

-------------------------------------------------------------------------------------------------------
procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , en_referencia_id       in             log_generico_nf.referencia_id%type
                            , ev_obj_referencia      in             log_generico_nf.obj_referencia%type
                            );

-------------------------------------------------------------------------------------------------------
-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field
procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             VARCHAR2
                                , ev_atributo        in             VARCHAR2
                                , ev_valor           in             VARCHAR2
                                , sv_cod_mult_org    out            VARCHAR2
                                , sv_hash_mult_org   out            VARCHAR2
                                , en_referencia_id   in             log_generico_nf.referencia_id%type
                                , ev_obj_referencia  in             log_generico_nf.obj_referencia%type
                                );

-------------------------------------------------------------------------------------------------------
-- Procedimento seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
procedure pkb_seta_tipo_integr ( en_tipo_integr in number );

-------------------------------------------------------------------------------------------------------

-- Procedimento seta o objeto de referencia utilizado na Validação da Informação
procedure pkb_seta_obj_ref ( ev_objeto in varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
procedure pkb_seta_referencia_id ( en_id in number );

-------------------------------------------------------------------------------------------------------

-- Procedimento exclui dados de uma nota fiscal
procedure pkb_excluir_dados_nf ( en_notafiscal_id  in nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento armazena o valor do "loggenerico_id" da nota fiscal
procedure pkb_gt_log_generico_nf ( en_loggenericonf_id  in             log_generico_nf.id%type
                                 , est_log_generico_nf  in out nocopy  dbms_sql.number_table );

-------------------------------------------------------------------------------------------------------

-- Procedimento finaliza o Log Genérico
procedure pkb_finaliza_log_generico_nf;

-------------------------------------------------------------------------------------------------------

-- Procedimento de registro de log de erros na validação da nota fiscal
procedure pkb_log_generico_nf ( sn_loggenericonf_id   out nocopy log_generico_nf.id%type
                              , ev_mensagem        in            log_generico_nf.mensagem%type
                              , ev_resumo          in            log_generico_nf.resumo%type
                              , en_tipo_log        in            csf_tipo_log.cd_compat%type      default 1
                              , en_referencia_id   in            log_generico_nf.referencia_id%type  default null
                              , ev_obj_referencia  in            log_generico_nf.obj_referencia%type default null
                              , en_empresa_id      in            empresa.id%type                  default null
                              , en_dm_impressa     in            log_generico_nf.dm_impressa%type    default 0 );

                                    
-------------------------------------------------------------------------------------------------------

-- Procedimento de Integração de dados Complementares da Nota Fiscal
procedure pkb_integr_nota_fiscal_compl ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                       , est_row_nota_fiscal_compl  in out nocopy  nota_fiscal_compl%rowtype
                                       , en_notafiscal_id           in             nota_fiscal.id%type
                                       , en_nro_nf                  in             nota_fiscal.nro_nf%type
                                       , ev_nro_chave_nfe           in             nota_fiscal.nro_chave_nfe%type
                                       , en_sub_serie               in             nota_fiscal.sub_serie%type
                                       , ev_cod_mod                 in             mod_fiscal.cod_mod%type
                                       , ev_cod_infor               in             infor_comp_dcto_fiscal.cod_infor%type
                                       , ev_cod_cta                 in             nota_fiscal.cod_cta%type
                                       , ev_cod_cons                in             cod_cons_item_cont.cod_cons%type
                                       , en_dm_tp_ligacao           in             nota_fiscal.dm_tp_ligacao%type
                                       , ev_dm_cod_grupo_tensao     in             nota_fiscal.dm_cod_grupo_tensao%type
                                       , en_dm_tp_assinante         in             nota_fiscal.dm_tp_assinante%type
                                       , en_nro_ord_emb             in             nota_fiscal.nro_ord_emb%type
                                       , en_seq_nro_ord_emb         in             nota_fiscal.seq_nro_ord_emb%type
                                       , en_multorg_id              in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de impostos do Item da Nota Fiscal
procedure pkb_integr_imp_itemnf ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                , est_row_imp_itemnf   in out nocopy  imp_itemnf%rowtype
                                , en_cd_imp            in             tipo_imposto.cd%type
                                , ev_cod_st            in             cod_st.cod_st%type
                                , en_notafiscal_id     in             nota_fiscal.id%type
                                , ev_sigla_estado      in             estado.sigla_estado%type default null );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de impostos do Item da Nota Fiscal - Campos Flex Field
procedure pkb_integr_imp_itemnf_ff ( est_log_generico_nf in out nocopy dbms_sql.number_table
                                   , en_notafiscal_id    in            nota_fiscal.id%type
                                   , en_impitemnf_id     in            imp_itemnf.id%type
                                   , ev_atributo         in            varchar2
                                   , ev_valor            in            varchar2
                                   , en_multorg_id       in            mult_org.id%type );

-------------------------------------------------------------------------------------------------------
-- Integra as informações de Rastreabilidade de produto
PROCEDURE pkb_integr_itemnf_rastreab ( est_log_generico_nf     in out nocopy dbms_sql.number_table
                                     , est_row_itemnf_rastreab  in out        itemnf_rastreab%rowtype
                                     , en_notafiscal_id        in            nota_fiscal.id%type
                                     );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de combustíveis
procedure pkb_integr_itemnf_comb ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                 , est_row_itemnf_comb   in out nocopy  itemnf_comb%rowtype
                                 , ev_uf_emit            in             estado.sigla_estado%type
                                 , en_notafiscal_id      in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de combustíveis - Flex Field
procedure pkb_integr_itemnf_comb_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id      in             nota_fiscal.id%type
                                    , en_itemnfcomb_id      in             itemnf_comb.id%type
                                    , ev_atributo           in             varchar2
                                    , ev_valor              in             varchar2 );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de medicamentos - Flex Field
PROCEDURE PKB_INTEGR_ITEMNF_MED_FF ( EST_LOG_GENERICO_NF IN OUT NOCOPY  DBMS_SQL.NUMBER_TABLE
                                   , EN_NOTAFISCAL_ID    IN             NOTA_FISCAL.ID%TYPE
                                   , EN_ITEMNFMED_ID     IN             ITEMNF_MED.ID%TYPE
                                   , EV_ATRIBUTO         IN             VARCHAR2
                                   , EV_VALOR            IN             VARCHAR2 
                                   );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de medicamentos
procedure pkb_integr_itemnf_med ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                , est_row_itemnf_med   in out nocopy  itemnf_med%rowtype
                                , en_notafiscal_id     in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações adicionais da Nota Fiscal
procedure pkb_integr_nfinfor_fiscal ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                    , est_row_nfinfor_fiscal   in out nocopy  nfinfor_fiscal%rowtype
                                    , ev_cd_obs                in obs_lancto_fiscal.cod_obs%type default null
                                    , en_multorg_id            in mult_org.id%type );

                                  
-------------------------------------------------------------------------------------------------------

-- Integra as informações dos itens da nota fiscal
procedure pkb_integr_item_nota_fiscal ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_item_nota_fiscal  in out nocopy  item_nota_fiscal%rowtype
                                      , en_multorg_id             in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações dos itens da nota fiscal - campos flex field
procedure pkb_integr_Item_Nota_Fiscal_ff ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id     in             nota_fiscal.id%type
                                         , en_itemnotafiscal_id in             item_nota_fiscal.id%type
                                         , ev_atributo          in             varchar2
                                         , ev_valor             in             varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento para complemento da operação de COFINS
procedure pkb_integr_nfcompl_opercofins ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                        , est_row_nfcompl_opercofins in out nocopy  nf_compl_oper_cofins%rowtype
                                        , ev_cpf_cnpj_emit           in             varchar2
                                        , ev_cod_st                  in             cod_st.cod_st%type
                                        , ev_cod_bc_cred_pc          in             base_calc_cred_pc.cd%type
                                        , ev_cod_cta                 in             plano_conta.cod_cta%type
                                        , en_multorg_id              in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento para complemento da operação de COFINS - Campos Flex Field
procedure pkb_integr_nfcomplopercof_ff ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                                       , en_nfcomplopercofins_id in             nf_compl_oper_cofins.id%type
                                       , ev_atributo             in             varchar2
                                       , ev_valor                in             varchar2
                                       , en_multorg_id           in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento para complemento da operação de PIS/PASEP
procedure pkb_integr_nfcompl_operpis ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                     , est_row_nfcompl_operpis  in out nocopy  nf_compl_oper_pis%rowtype
                                     , ev_cpf_cnpj_emit         in             varchar2
                                     , ev_cod_st                in             cod_st.cod_st%type
                                     , ev_cod_bc_cred_pc        in             base_calc_cred_pc.cd%type
                                     , ev_cod_cta               in             plano_conta.cod_cta%type
                                     , en_multorg_id            in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento para complemento da operação de PIS/PASEP - Campos Flex Field
procedure pkb_integr_nfcomploperpis_ff ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                       , en_nfcomploperpis_id in             nf_compl_oper_pis.id%type
                                       , ev_atributo          in             varchar2
                                       , ev_valor             in             varchar2
                                       , en_multorg_id        in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de Totais de Nota Fiscal
procedure pkb_integr_nota_fiscal_total ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                       , est_row_nota_fiscal_total  in out nocopy  nota_fiscal_total%rowtype );

-------------------------------------------------------------------------------------------------------

-- Integra as informações de Totais de Nota Fiscal - Flex Field
procedure pkb_integr_notafiscal_total_ff ( est_log_generico_nf     in out nocopy dbms_sql.number_table
                                         , en_notafiscal_id        in            nota_fiscal.id%type 
                                         , en_notafiscaltotal_id   in            nota_fiscal_total.id%type
                                         , ev_atributo             in            varchar2
                                         , ev_valor                in            varchar2);

-------------------------------------------------------------------------------------------------------

-- Integra as informações adicionais da Nota Fiscal
procedure pkb_integr_nfinfor_adic ( est_log_generico_nf    in out nocopy  dbms_sql.number_table
                                  , est_row_nfinfor_adic   in out nocopy  nfinfor_adic%rowtype
                                  , en_cd_orig_proc        in             orig_proc.cd%type default null );


-------------------------------------------------------------------------------------------------------

-- Integra informações referênte ao transporte da Nota Fiscal
procedure pkb_integr_nota_fiscal_transp ( est_log_generico_nf         in out nocopy  dbms_sql.number_table
                                        , est_row_nota_fiscal_transp  in out nocopy  nota_fiscal_transp%rowtype
                                        , en_multorg_id               in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra informações do Local de Retirada/Entrega de mercadorias - campos flex field --
--
procedure pkb_integr_nota_fiscal_localff ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id         in             nota_fiscal.id%type
                                         , en_notafiscallocal_id    in             nota_fiscal_local.id%type
                                         , ev_atributo              in             varchar2
                                         , ev_valor                 in             varchar2
                                         ) ;

-------------------------------------------------------------------------------------------------------

-- Integra informações do Local de Retirada/Entrega de mercadorias
procedure pkb_integr_nota_fiscal_local ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                       , est_row_nota_fiscal_local  in out nocopy  nota_fiscal_local%rowtype );


-------------------------------------------------------------------------------------------------------

-- Integra informações de email por tipo de anexo
procedure pkb_integr_nfdest_email ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                  , est_row_nfdest_email  in out nocopy  nfdest_email%rowtype
                                  , en_notafiscal_id      in             nota_fiscal.id%type );
-------------------------------------------------------------------------------------------------------

-- Procedimento de registro da pessoa destinatário da Nota Fiscal
procedure pkb_verif_pessoas_restricao ( est_log_generico_nf in  out nocopy  dbms_sql.number_table
                                      , ev_cpf_cnpj         in  ctrl_restr_pessoa.cpf_cnpj%type
                                      , en_multorg_id       in  ctrl_restr_pessoa.multorg_id%type default 0
                                      );

-------------------------------------------------------------------------------------------------------

-- Integra as informações do Destinatário da Nota Fiscal
procedure pkb_integr_nota_fiscal_dest ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_nota_fiscal_dest  in out nocopy  nota_fiscal_dest%rowtype
                                      , ev_cod_part               in             pessoa.cod_part%type
                                      , en_multorg_id             in             mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Integra as informações do Destinatário da Nota Fiscal - Flex Field
procedure pkb_integr_nota_fiscal_dest_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id      in             nota_fiscal.id%type
                                         , en_notafiscaldest_id  in             nota_fiscal_dest.id%type
                                         , ev_atributo           in             varchar2
                                         , ev_valor              in             varchar2 );

---------------------------------------------------------------------------------------------------------------------------------------
-- Integra as informações do Emitente da Nota Fiscal - Flex Field                                                    --
---------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE PKB_INTEGR_NOTA_FISCAL_EMIT_FF ( EST_LOG_GENERICO_NF       IN OUT NOCOPY  DBMS_SQL.NUMBER_TABLE
                                         , EN_NOTAFISCAL_ID          IN             NOTA_FISCAL.ID%TYPE
                                         , EN_NOTAFISCALEMIT_ID      IN             NOTA_FISCAL_EMIT.ID%TYPE
                                         , EV_ATRIBUTO               IN             VARCHAR2
                                         , EV_VALOR                  IN             VARCHAR2
                                         );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informação do emitente da Nota Fiscal
procedure pkb_integr_nota_fiscal_emit ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_nota_fiscal_emit  in out nocopy  nota_fiscal_emit%rowtype
                                      , en_empresa_id             in             empresa.id%type
                                      , en_dm_ind_emit            in             nota_fiscal.dm_ind_emit%type
                                      , ev_cod_part               in             pessoa.cod_part%type default null );
                                      
-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações da Autorização de acesso ao XML da Nota Fiscal
procedure pkb_integr_nf_aut_xml ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                , est_row_nf_aut_xml   in out nocopy  nf_aut_xml%rowtype
                                );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações da Formas de Pagamento
procedure pkb_integr_nf_forma_pgto ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                   , est_row_nf_forma_pgto in out nocopy  nf_forma_pgto%rowtype
                                   );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra as informações da Formas de Pagamento - Campos Flex Field
procedure pkb_integr_nf_forma_pgto_ff ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id    in             nota_fiscal.id%type
                                      , en_nfformapgto_id   in             nf_forma_pgto.id%type
                                      , ev_atributo         in             varchar2
                                      , ev_valor            in             varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento que faz a integração as Notas Fiscais Cancelas
procedure pkb_integr_nota_fiscal_canc ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , est_row_nota_fiscal_canc  in out nocopy  nota_fiscal_canc%rowtype 
                                      , en_loteintws_id           in     lote_int_ws.id%type default 0
                                      );

-------------------------------------------------------------------------------------------------------

-- Procedimento integra a Chave da Nota Fiscal
procedure pkb_integr_nfchave_refer ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                   , en_empresa_id        in             empresa.id%type
                                   , en_notafiscal_id     in             nota_fiscal.id%type
                                   , ed_dt_emiss          in             nota_fiscal.dt_emiss%type
                                   , ev_cod_mod           in             mod_fiscal.cod_mod%type
                                   , en_serie             in             nota_fiscal.serie%type
                                   , en_nro_nf            in             nota_fiscal.nro_nf%type
                                   , en_dm_forma_emiss    in             nota_fiscal.dm_forma_emiss%type
                                   , esn_cnf_nfe          in out nocopy  nota_fiscal.cnf_nfe%type
                                   , sn_dig_verif_chave   out            nota_fiscal.dig_verif_chave%type
                                   , sv_nro_chave_nfe     out            nota_fiscal.nro_chave_nfe%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida a chave de acesso da Nota Fiscal
procedure pkb_valida_chave_acesso ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                  , ev_nro_chave_nfe     in             nota_fiscal.nro_chave_nfe%type
                                  , EN_UF_IBGE           IN             NOTA_FISCAL.UF_IBGE_EMIT%TYPE
                                  , EV_CNPJ              IN             varchar2
                                  , ed_dt_emiss          in             nota_fiscal.dt_emiss%type
                                  , ev_cod_mod           in             mod_fiscal.cod_mod%type
                                  , en_serie             in             nota_fiscal.serie%type
                                  , en_nro_nf            in             nota_fiscal.nro_nf%type
                                  , en_dm_forma_emiss    in             nota_fiscal.dm_forma_emiss%type
                                  , sn_cnf_nfe           out            nota_fiscal.cnf_nfe%type
                                  , sn_dig_verif_chave   out            nota_fiscal.dig_verif_chave%type
                                  , sn_qtde_erro         out            number );

-------------------------------------------------------------------------------------------------------

--| Procedimento que faz validações na Nota Fiscal e grava na CSF
procedure pkb_integr_nota_fiscal ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                 , est_row_nota_fiscal        in out nocopy  nota_fiscal%rowtype
                                 , ev_cod_mod                 in             mod_fiscal.cod_mod%type
                                 , ev_cod_matriz              in             empresa.cod_matriz%type  default null
                                 , ev_cod_filial              in             empresa.cod_filial%type  default null
                                 , ev_empresa_cpf_cnpj        in             varchar2                 default null -- cpf/cnpj da empresa
                                 , ev_cod_part                in             pessoa.cod_part%type     default null
                                 , ev_cod_nat                 in             nat_oper.cod_nat%type    default null
                                 , ev_cd_sitdocto             in             sit_docto.cd%type        default null
                                 , ev_cod_infor               in             infor_comp_dcto_fiscal.cod_infor%type  default null
                                 , ev_sist_orig               in             sist_orig.sigla%type     default null
                                 , ev_cod_unid_org            in             unid_org.cd%type         default null
                                 , en_multorg_id              in             mult_org.id%type
                                 , en_empresaintegrbanco_id   in             empresa_integr_banco.id%type default null
                                 , en_loteintws_id            in             lote_int_ws.id%type default 0
                                 );

-------------------------------------------------------------------------------------------------------

--| Procedimento que faz validações na Nota Fiscal e grava na CSF - Campos Flex Field
procedure pkb_integr_nota_fiscal_ff ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id    in             nota_fiscal.id%type
                                    , ev_atributo         in             varchar2
                                    , ev_valor            in             varchar2
                                    );

-------------------------------------------------------------------------------------------------------

-- procedimento complementa a informação da nota fiscal
procedure pkb_monta_compl_infor_adic ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                     , en_notafiscal_id    in             nota_fiscal.id%type
				     , ev_texto_compl      in             nfinfor_adic.conteudo%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento valida informações adicionais da Nota Fiscal
procedure pkb_valida_infor_adic ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informação da transportadora
procedure pkb_valida_transportadora ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações do Local de Retirada/Entrega
-- verifica se existe apenas uma informação para cada registro de Retirada ou Entrega
procedure pkb_valida_nf_local ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                              , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida os itens de combustível - Só pode existir um Item de Combustível por item da nota
procedure pkb_valida_item_comb ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações dos totais - Só pode existir um único registro de totais
procedure pkb_valida_total_nf ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                              , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações do Emitente da Nota Fiscal
-- verifica se existe mais de um emitente, ou se não foi informado o emitente
procedure pkb_valida_nf_emit ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida informações do Destinatário da Nota Fiscal
-- verifica se existe mais de um Destinatário, ou se não foi informado o emitente
procedure pkb_valida_nf_dest ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida a quantidade de Itema de uma Nota Fiscal - Só pode ter até 990 itens em uma nota Fiscal
procedure pkb_valida_qtde_item_nf ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                  , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento válida a quantidade de impostos por item da Nota Fiscal
-- Só pode existir um registro de cada tipo de imposto por Nota Fiscal
procedure pkb_valida_qtde_imposto_item ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de válidações de impostos
procedure pkb_valida_imposto_item ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                  , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedimento de validações de base de impostos de ICMS

procedure pkb_valida_base_icms ( est_log_generico_nf  IN OUT NOCOPY  dbms_sql.number_table
                               , en_notafiscal_id     IN             nota_fiscal.id%type );
                               
-------------------------------------------------------------------------------------------------------

-- Função retorna as notas fiscais que não pode ser inutilizadas
function fkg_nf_nao_inutiliza ( en_empresa_id   in  inutiliza_nota_fiscal.empresa_id%type
                              , en_dm_tp_amb    in  inutiliza_nota_fiscal.dm_tp_amb%type
                              , ev_cod_mod      in  mod_fiscal.cod_mod%type
                              , en_serie        in  inutiliza_nota_fiscal.serie%type
                              , en_nro_ini      in  inutiliza_nota_fiscal.nro_ini%type
                              , en_nro_fim      in  inutiliza_nota_fiscal.nro_fim%type )
          return varchar2;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a integração da Inutilização de Notas Fiscais
procedure pkb_integr_inutilizanf ( est_log_generico_nf            in out nocopy  dbms_sql.number_table
                                 , est_row_inutiliza_nota_fiscal  in out nocopy  inutiliza_nota_fiscal%rowtype
                                 , ev_cod_mod                     in             mod_fiscal.cod_mod%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento que busca todas as Inutilizações com a situação "5-Não Validada"
procedure pkb_consit_inutilizacao ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Função cria o Lote de Envio da Nota Fiscal e retorna o ID
function fkg_integr_lote ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                         , en_empresa_id       in             empresa.id%type
			 , en_dm_forma_emiss   in             empresa.dm_forma_emiss%type default null )
         return lote.id%type;

-------------------------------------------------------------------------------------------------------

-- Processo de criação do Lote de Notas Fiscais
procedure pkb_gera_lote ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------
-- Procedimento realiza a criação de registro analitico de impostos da Nota Fiscal --
-------------------------------------------------------------------------------------
PROCEDURE PKB_GERA_REGIST_ANALIT_IMP ( EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                     , EN_NOTAFISCAL_ID IN            NOTA_FISCAL.ID%TYPE );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Cálculo de ICMS-Normal
procedure pkb_calc_icms_normal ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de Ajuste do total da NFe
procedure pkb_ajusta_total_nf ( en_notafiscal_id in nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedure que consiste os dados da Nota Fiscal
procedure pkb_consistem_nf ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                           , en_notafiscal_id    in             nota_fiscal.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento registra Log de processamento da Nota Fiscal
procedure pkb_reg_log_proc_nfe;

-------------------------------------------------------------------------------------------------------

-- Re-envia lote que teve erro ao ser enviado a SEFAZ
procedure pkb_reenvia_lote ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento ajusta lotes que estão com a situação 2-concluído e suas notas não
procedure pkb_ajusta_lote_nfe ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualiar NF-e inutilizadas
-- Depois de Homologado a Inutilização, verifica se tem alguma NFe vinculada e
-- Altera o DM_ST_PROC para 8-Inutilizada e a Situação do Documento para "05-NF-e ou CT-e - Numeração inutilizada"
procedure pkb_atual_nfe_inut ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de atualização do campo NOTAFISCAL_ID da tabela CSF_CONS_SIT
-- Pega todos os registros que o campo NOTAFISCAL_ID estão nulos, verifica se sua chave de acesso existe
-- na tabela NOTA_FISCAL, se exitir relacionar o campo NOTA_FISCCAL.ID com campo CSF_CONS_SIT.NOTAFISCCAL_ID
procedure pkb_relac_nfe_cons_sit ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Atualiza Situação do Documento Fiscal
procedure pkb_atual_sit_docto ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Metodo para consultar NFe de Terceiro, com "Data de Autorização" menor que sete dias da data atual
-- serve para verificar se o emitente da NFe cancelou a mesma
procedure pkb_cons_nfe_terc ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Função retorna a Valor Base de Cálculo do PIS/Cofins conforme o ITEMNF_ID
function fkg_vl_base_calc_pc_itemnf ( en_itemnf_id in item_nota_fiscal.id%type )
         return imp_itemnf.vl_base_calc%type;

-------------------------------------------------------------------------------------------------------

-- Procedimento de acerta pessoa emissão propria
PROCEDURE PKB_ACERTA_PESSOA_EMISS_PROP ( EN_EMPRESA_ID IN EMPRESA.ID%TYPE
                                       , ED_DATA       IN DATE
                                       );

-------------------------------------------------------------------------------------------------------

-- Procedimento de acerta pessoa Terceiros
PROCEDURE PKB_ACERTA_PESSOA_TERCEIRO ( EN_EMPRESA_ID IN EMPRESA.ID%TYPE
                                     , ED_DATA       IN DATE
                                     );

-------------------------------------------------------------------------------------------------------

-- Procedimento de acerto de item
PROCEDURE PKB_ACERTA_ITEM_NF ( EN_EMPRESA_ID IN EMPRESA.ID%TYPE
                             , ED_DATA       IN DATE
                             );

-------------------------------------------------------------------------------------------------------

-- Procedimento para gravar o log/alteração das notas fiscais
procedure pkb_inclui_log_nota_fiscal( en_notafiscal_id in nota_fiscal.id%type
                                    , ev_resumo        in log_nota_fiscal.resumo%type
                                    , ev_mensagem      in log_nota_fiscal.mensagem%type
                                    , en_usuario_id    in neo_usuario.id%type
                                    , ev_maquina       in varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento que retorna os valores fiscais (ICMS/ICMS-ST/IPI) de um item de nota fiscal
procedure pkb_vlr_fiscal_item_nf ( en_itemnf_id           in   item_nota_fiscal.id%type
                                 , sn_cfop                out  cfop.cd%type
                                 , sn_vl_operacao         out  number
                                 , sv_cod_st_icms         out  cod_st.cod_st%type
                                 , sn_vl_base_calc_icms   out  imp_itemnf.vl_base_calc%type
                                 , sn_aliq_icms           out  imp_itemnf.aliq_apli%type
                                 , sn_vl_imp_trib_icms    out  imp_itemnf.vl_imp_trib%type
                                 , sn_vl_base_calc_icmsst out  imp_itemnf.vl_base_calc%type
                                 , sn_vl_imp_trib_icmsst  out  imp_itemnf.vl_imp_trib%type
                                 , sn_vl_bc_isenta_icms   out  number
                                 , sn_vl_bc_outra_icms    out  number
                                 , sv_cod_st_ipi          out  cod_st.cod_st%type
                                 , sn_vl_base_calc_ipi    out  imp_itemnf.vl_base_calc%type
                                 , sn_aliq_ipi            out  imp_itemnf.aliq_apli%type
                                 , sn_vl_imp_trib_ipi     out  imp_itemnf.vl_imp_trib%type
                                 , sn_vl_bc_isenta_ipi    out  number
                                 , sn_vl_bc_outra_ipi     out  number
                                 , sn_ipi_nao_recup       out  number
                                 , sn_outro_ipi           out  number
                                 , sn_vl_imp_nao_dest_ipi out  number
                                 , sn_vl_fcp_icmsst       out  number
                                 , sn_aliq_fcp_icms       out  number
                                 , sn_vl_fcp_icms         out  number
                                 );

-------------------------------------------------------------------------------------------------------

-- Procedimento de integração dos dados do ajuste do item.
procedure pkb_integr_inf_prov_docto_fisc ( est_log_generico_nf           in out nocopy  dbms_sql.number_table
                                         , est_row_inf_prov_docto_fiscal in out nocopy  inf_prov_docto_fiscal%rowtype
                                         , ev_cod_obs                    in             obs_lancto_fiscal.cod_obs%type
                                         , ev_cod_aj                     in             cod_ocor_aj_icms.cod_aj%type
                                         , en_notafiscal_id              in             nota_fiscal.id%type
                                         , en_nro_item                   in             item_nota_fiscal.nro_item%type
                                         , en_multorg_id                 in             mult_org.id%type
                                         );

-------------------------------------------------------------------------------------------------------

-- Procedimento cria o "item" de NFe legado
procedure pkb_cria_item_nfe_legado( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento cria a Pessoa de NFe legado
procedure pkb_cria_pessoa_nfe_legado ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Função para validar as notas fiscais - utilizada na rotina de validação da GIA-SP - PK_GERA_ARQ_GIA.PKB_VALIDAR
function fkg_valida_nf ( en_empresa_id      in  empresa.id%type
                       , ed_dt_ini          in  date
                       , ed_dt_fin          in  date
                       , ev_obj_referencia  in  log_generico_nf.obj_referencia%type
                       , en_referencia_id   in  log_generico_nf.referencia_id%type )
         return boolean;
         
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------

PROCEDURE PKB_INTEGR_NOTA_FISCAL_CCE ( EST_LOG_GENERICO_NF       IN OUT NOCOPY  DBMS_SQL.NUMBER_TABLE
                                     , EST_ROW_NOTA_FISCAL_CCE   IN OUT NOCOPY  NOTA_FISCAL_CCE%ROWTYPE
                                     );

-------------------------------------------------------------------------------------------------------

end pk_csf_api_nfce;
/
