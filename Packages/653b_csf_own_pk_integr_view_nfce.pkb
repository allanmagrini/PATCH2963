create or replace package body csf_own.pk_integr_view_nfce is
--
-- ============================================================================================================================================= --
-- Especificação do pacote de integração de Notas Fiscais a partir de leitura de views
-- ============================================================================================================================================= --
--
-- ============================================================================================================================================= --
-- Procedimento de limpeza do array
procedure pkb_limpa_array is
--
begin
   --
   vt_tab_csf_nota_fiscal_ff.delete;
   vt_tab_csf_nota_fiscal_emit.delete;
   vt_tab_csf_nota_fiscal_emit_ff.delete;
   vt_tab_csf_nota_fiscal_dest.delete;
   vt_tab_csf_nota_fiscal_dest_ff.delete;
   vt_tab_csf_nfdest_email.delete;
   vt_tab_csf_nota_fiscal_total.delete;
   vt_tab_csf_notafiscal_total_ff.delete;
   vt_tab_csf_nota_fiscal_referen.delete;
   vt_tab_csf_notafiscalrefer_ff.delete;
   vt_tab_csf_cupom_fiscal_ref.delete;
   vt_tab_csf_nfinfor_adic.delete;
   vt_tab_csf_nota_fiscal_cobr.delete;
   vt_tab_csf_nf_cobr_dup.delete;
   vt_tab_csf_nota_fiscal_local.delete;
   vt_tab_csf_nota_fiscal_transp.delete;
   vt_tab_csf_nftransp_veic.delete;
   vt_tab_csf_nftransp_vol.delete;
   vt_tab_csf_nftranspvol_lacre.delete;
   vt_tab_csf_item_nota_fiscal.delete;
   vt_tab_csf_imp_itemnf.delete;
   vt_tab_csf_imp_itemnf_ff.delete;
   vt_tab_csf_imp_itemnficmsdest.delete;
   vt_tab_csf_impitnficmsdest_ff.delete;
   vt_tab_csf_itemnf_comb.delete;
   vt_tab_csf_itemnf_comb_ff.delete;
   vt_tab_csf_itemnf_veic.delete;
   vt_tab_csf_itemnf_med.delete;
   vt_tab_csf_itemnf_arma.delete;
   vt_tab_csf_itemnf_dec_impor.delete;
   vt_tab_csf_itemnf_dec_impor_ff.delete;
   vt_tab_csf_itemnfdi_adic.delete;
   vt_tab_csf_itemnf_dif_aliq.delete;
   vt_tab_csf_itemnf_rastreab.delete;
   vt_tab_csf_itemnf_res_icms_st.delete;
   vt_tab_csf_itemnf_med_ff.delete;
   vt_tab_csf_nf_aquis_cana.delete;
   vt_tab_csf_nf_aquis_cana_dia.delete;
   vt_tab_csf_nf_aquis_cana_ded.delete;
   vt_tab_csf_inf_nf_romaneio.delete;
   vt_tab_csf_nf_agend_transp.delete;
   vt_tab_csf_nf_obs_agend_transp.delete;
   vt_tab_csf_inutiliza_nf.delete;
   vt_tab_csf_itemnf_compl_transp.delete;
   vt_tab_csf_nota_fiscal_compl.delete;
   vt_tab_csf_itemnf_compl.delete;
   vt_tab_csf_cfe_ref.delete;
   vt_tab_csf_item_nota_fiscal_ff.delete;
   vt_tab_csf_inf_prov_docto_fisc.delete;
   vt_tab_csf_nf_aut_xml.delete;
   vt_tab_csf_nf_forma_pgto.delete;
   vt_tab_csf_nf_forma_pgto_ff.delete;
   vt_tab_csf_itemnf_nve.delete;
   vt_tab_csf_itemnf_export.delete;
   vt_tab_csf_itemnf_export_compl.delete;
   vt_tab_csf_nfinfor_fiscal.delete;
   --
end pkb_limpa_array;
--
-- ================================================================================================================= --
-- Procedimento responsável por excluir os dados de resposta da NFe no ERP
procedure pkb_excluir_nf ( ev_cpf_cnpj_emit  in  varchar2
                         , en_dm_ind_emit    in  number
                         , en_dm_ind_oper    in  number
                         , ev_cod_part       in  varchar2
                         , ev_cod_mod        in  varchar2
                         , ev_serie          in  varchar2
                         , en_nro_nf         in  number
                         , en_notafiscal_id  in  number
                         , ev_obj            in  varchar2
                         , ev_aspas          in  varchar2
                         )
is
   --
   PRAGMA AUTONOMOUS_TRANSACTION;
   --
   vn_fase number := 0;
   --
begin
   --
   gv_sql := 'delete from ' || ev_obj;
   --
   vn_fase := 1;
   --
   gv_sql := gv_sql || ' where ' || ev_aspas || 'CPF_CNPJ_EMIT' || ev_aspas || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql ||   ' and ' || ev_aspas || 'DM_IND_OPER'   || ev_aspas || ' = ' || en_dm_ind_oper;
   gv_sql := gv_sql ||   ' and ' || ev_aspas || 'DM_IND_EMIT'   || ev_aspas || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql ||   ' and ' || ev_aspas || 'COD_MOD'       || ev_aspas || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql ||   ' and ' || eV_ASPAS || 'SERIE'         || eV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql ||   ' and ' || ev_aspas || 'NRO_NF'        || ev_aspas || ' = ' || en_nro_nf;
   --
   vn_fase := 2;
   --
   begin
      --
      execute immediate gv_sql;
      --
   exception
      when others then
         null;
   end;
   --
   commit;
   --
end pkb_excluir_nf;
--
-- ============================================================================================================================================= --
function fkg_monta_from ( ev_obj in varchar2 ) return varchar2 is
   --
   vv_from  varchar2(4000) := null;
   vv_obj   varchar2(4000) := null;
   --
begin
   --
   vv_obj := ev_obj || gn_dm_ind_emit; -- para difenciar view de tabelas
   --
   if GV_NOME_DBLINK is not null then
      --
      vv_from := vv_from || GV_ASPAS || vv_obj || GV_ASPAS || '@' || GV_NOME_DBLINK;
      --
   else
      --
      vv_from := vv_from || GV_ASPAS || vv_obj || GV_ASPAS;
      --
   end if;
   --
   if trim(GV_OWNER_OBJ) is not null then
      vv_from := trim(GV_OWNER_OBJ) || '.' || vv_from;
   end if;
   --
   vv_from := ' from ' || vv_from;
   --
   return vv_from;
   --
end fkg_monta_from;
--
-- ============================================================================================================================================= --
-- Procedimento seta "where" para pesquisa por período
procedure pkb_seta_where_periodo ( ed_dt_ini  in  date
                                 , ed_dt_fin  in  date ) is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gv_where    := null;
   gn_rel_part := 1;
   --
   gv_where := ' and ((a.' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = 0'||
                     ' and (trunc(a.' || GV_ASPAS || 'DT_EMISS' || GV_ASPAS || ') >= ' || '''' || to_char(ed_dt_ini, gd_formato_dt_erp) || '''' ||
                      ' and trunc(a.' || GV_ASPAS || 'DT_EMISS' || GV_ASPAS || ') <= ' || '''' || to_char(ed_dt_fin, gd_formato_dt_erp) || '''' ||
                     '))'||
                 ' or (a.' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = 1'||
                     ' and (trunc(a.' || GV_ASPAS || 'DT_SAI_ENT' || GV_ASPAS || ') >= ' || '''' || to_char(ed_dt_ini, gd_formato_dt_erp) || '''' ||
                      ' and trunc(a.' || GV_ASPAS || 'DT_SAI_ENT' || GV_ASPAS || ') <= ' || '''' || to_char(ed_dt_fin, gd_formato_dt_erp) || '''' || ')))';
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_seta_where_periodo fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_seta_where_periodo;
--
-- ============================================================================================================================================= --
-- Procedimento seta "where" para pesquisa de Nfe de emissão própria
procedure pkb_seta_where_emissao_propria is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gv_where := null;
   gv_where := ' and a.' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = 0';
   gv_where := gv_where || ' and a.' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' in (''65'')';
   gv_where := gv_where || ' and a.' || GV_ASPAS || 'DM_ST_PROC' || GV_ASPAS || ' IN (0)';
   --
   gn_rel_part := 0;
   --
   vn_fase := 2;
   --
   if GV_SIST_ORIG is not null then
      --
      gv_where := gv_where || ' and a.' || GV_ASPAS || 'SIST_ORIG' || GV_ASPAS || ' = ' || '''' || GV_SIST_ORIG || '''';
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_seta_where_emissao_propria fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_seta_where_emissao_propria;
--
-- ============================================================================================================================================= --
function fkg_ret_dm_st_proc_erp ( ev_cpf_cnpj_emit          in             varchar2
                                , en_dm_ind_emit            in             number
                                , en_dm_ind_oper            in             number
                                , ev_cod_part               in             varchar2
                                , ev_cod_mod                in             varchar2
                                , ev_serie                  in             varchar2
                                , en_nro_nf                 in             number
                                , en_notafiscal_id          in             number
                                , ev_obj                    in             varchar2
                                , ev_aspas                  in             varchar2
                                , ev_obj_name               in             varchar2
                                )
         return number
is
   --
   vn_dm_st_proc_erp number(2) := -1;
   --
   PRAGMA AUTONOMOUS_TRANSACTION;
   --
begin
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => ev_obj_name) = 0 then
      --
      vn_dm_st_proc_erp := null;
      --
      return vn_dm_st_proc_erp;
      --
   end if;
   --
   -- Inicia montagem da query
   gv_sql :=                       'SELECT distinct ';
   gv_sql := gv_sql || ev_aspas || 'DM_ST_PROC' || ev_aspas;
   gv_sql := gv_sql ||             ' from '     || ev_obj;
   --
   gv_sql := gv_sql || ' where ' || ev_aspas || 'CPF_CNPJ_EMIT' || ev_aspas || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and '   || ev_aspas || 'DM_IND_OPER'   || ev_aspas || ' = ' || en_dm_ind_oper;
   gv_sql := gv_sql || ' and '   || ev_aspas || 'DM_IND_EMIT'   || ev_aspas || ' = ' || en_dm_ind_emit;
   --
   if en_dm_ind_emit = 1 and trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || ev_aspas || 'COD_PART' || ev_aspas || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and ' || ev_aspas || 'COD_MOD' || ev_aspas || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || eV_ASPAS || 'SERIE'   || eV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || ev_aspas || 'NRO_NF'  || ev_aspas || ' = ' || en_nro_nf;
   --
   begin
      --
      execute immediate gv_sql into vn_dm_st_proc_erp;
      --
   exception
      when no_data_found then
         vn_dm_st_proc_erp := -1;
      when others then
         vn_dm_st_proc_erp := -1;
         -- não registra erro caso a view não exista
         if sqlcode in (-942) then
            null;
	 elsif sqlcode in (-1010) then
   	       vn_dm_st_proc_erp := 1; /*redmine 10594*/
         else
            --
            -- A função replace está sendo utilizada para substituir uma aspas por duas, no comando executado,
            -- pois esse log será registrado em outra tabela através de uma query dinâmica feita pelo procedimento
            -- pkb_ret_infor_erro_nf_erp, e quando tem apenas uma aspas, ocorre o erro: ORA-00917: vírgula não encontrada
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na Erro na fkg_ret_dm_st_proc_erp:' || sqlerrm || ' - ' || replace (gv_sql, '''', '''''');
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   commit;
   --
   return vn_dm_st_proc_erp;
   --
exception
   when others then
      return -1;
end fkg_ret_dm_st_proc_erp;
--
-- ================================================================================================================= --
-- Grava informação da alteração da situação da integração da Nfe
procedure pkb_alter_sit_integra_nfe ( en_notafiscal_id  in  nota_fiscal.id%type
                                    , en_dm_st_integra  in  nota_fiscal.dm_st_integra%type ) is
   --
   PRAGMA  AUTONOMOUS_TRANSACTION;
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 and nvl(en_dm_st_integra,0) >= 0 then
      --
      vn_fase := 2;
      --
      update nota_fiscal
         set dm_st_integra = nvl(en_dm_st_integra,0)
       where id            = en_notafiscal_id;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_alter_sit_integra_nfe fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_alter_sit_integra_nfe;
--
-- ================================================================================================================= --
-- Grava informação da alteração da situação da integração da Nfe
procedure pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  in  nota_fiscal.id%type
                                         , en_dm_st_integra  in  nota_fiscal.dm_st_integra%type ) is
   --
   vn_fase number := 0;
   PRAGMA AUTONOMOUS_TRANSACTION;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0 and nvl(en_dm_st_integra,0) >= 0 then
      --
      vn_fase := 2;
      --
      update nota_fiscal_canc
         set dm_st_integra = nvl(en_dm_st_integra,0)
       where notafiscal_id = en_notafiscal_id;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_alter_sit_integra_nfe_canc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_alter_sit_integra_nfe_canc;
--
-- ================================================================================================================= --
-- Função que retorna a quantidade de registros da tabela VW_CSF_RESP_NF_ERP_FF conforme a chave e atributo
function fkg_existe_registro ( ev_cpf_cnpj_emit   varchar2
                             , en_dm_ind_emit     number
                             , en_dm_ind_oper     number
                             , ev_cod_part        varchar2
                             , ev_cod_mod         varchar2
                             , ev_serie           varchar2
                             , en_nro_nf          number
                             , ev_atributo        varchar2
                             , ev_obj             varchar2
                             , ev_aspas           char
                             )
         return number
is
   --
   vn_existe  number := 0;
   vn_fase    number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || ev_aspas || 'COUNT(1)' || ev_aspas;
   --
   gv_sql := gv_sql || ' FROM ' || ev_obj;
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || ev_aspas || 'CPF_CNPJ_EMIT' || ev_aspas || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || ev_aspas || 'DM_IND_EMIT' || ev_aspas || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || ev_aspas || 'DM_IND_OPER' || ev_aspas || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || ev_aspas || 'COD_PART' || ev_aspas || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || ev_aspas || 'COD_MOD' || ev_aspas || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || eV_ASPAS || 'SERIE' || eV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || ev_aspas || 'NRO_NF' || ev_aspas || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || ev_aspas || 'ATRIBUTO' || ev_aspas || ' = ' || '''' || ev_atributo || '''';
   --
   vn_fase := 5;
   --
   begin
      --
      execute immediate gv_sql into vn_existe;
      --
   exception
      when others then
      -- não registra erro casa a view não exista
      if sqlcode = -942 then
        null;
      else
        --
        gv_resumo := 'Erro na pk_integr_view_nfce.fkg_existe_registro fase(' || vn_fase || '):' || sqlerrm;
        --
        declare
           vn_loggenerico_id  log_generico_nf.id%TYPE;
        begin
           --
           pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                          , ev_mensagem         => gv_resumo
                                          , ev_resumo           => gv_resumo
                                          , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                          , en_referencia_id    => null
                                          , ev_obj_referencia   => 'NOTA_FISCAL'
                                          );
           --
        exception
           when others then
              null;
        end;
        --
      end if;
      --
   end;
   --
   return vn_existe;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_integr_view_nfce.fkg_existe_registro:' || sqlerrm);
end fkg_existe_registro;
--
-- ================================================================================================================= --
-- Procedimento seta a integração com o ERP para SIM
procedure pkb_seta_integr_erp_csf_cs ( en_csfconssit_id in csf_cons_sit.id%type
                                     , en_empresa_id    in csf_cons_sit.empresa_id%type ) is
   --
   PRAGMA AUTONOMOUS_TRANSACTION;
   --
begin
   --
   -- Chama rotina que atualiza a tabela csf_cons_sit
   pk_csf_api_cons_sit.gt_row_csf_cons_sit               := null;
   pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id    := en_empresa_id;
   pk_csf_api_cons_sit.gt_row_csf_cons_sit.id            := en_csfconssit_id;
   pk_csf_api_cons_sit.gt_row_csf_cons_sit.DM_INTEGR_ERP := 1;
   --
   pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                , ev_campo_atu         => 'DM_INTEGR_ERP'
                                                , en_tp_rotina         => 0 -- atualização
                                                , ev_rotina_orig       => 'pk_integr_view_nfce.pkb_seta_integr_erp_csf_cs'
                                                );
   --
   commit;
   --
exception
   when others then
      null;
end pkb_seta_integr_erp_csf_cs;
--
-- ================================================================================================================= --
-- Procedimento integra as consultas de NFe com o ERP
procedure pkb_int_csf_cons_sit ( en_empresa_id   in empresa.id%type
                               , ev_nome_dblink  in empresa_integr_banco.nome_dblink%type -- ev_nome_dblink
                               , ev_aspas        in varchar2 -- ev_aspas
                               , ev_owner_obj    in empresa_integr_banco.owner_obj%type -- ev_owner_obj
                               ) is
   --
   vn_fase              number := 0;
   vn_erro              number := 0;
   vv_obj               varchar2(4000) := null;
   vb_retorna_xml       boolean := false;
   vv_cpf_cnpj          varchar2(14);
   vn_empresa_id        empresa.id%type;
   vn_dm_ind_emit       nota_fiscal.dm_ind_emit%type;
   vn_dm_ind_oper       nota_fiscal.dm_ind_oper%type;
   vd_dt_emiss          nota_fiscal.dt_emiss%type;
   vn_nro_nf            nota_fiscal.nro_nf%type;
   vv_serie             nota_fiscal.serie%type;
   vd_dt_aut_sefaz      nota_fiscal.dt_aut_sefaz%type;
   vv_nro_chave_nfe     nota_fiscal.nro_chave_nfe%type;
   vn_dm_st_proc        nota_fiscal.dm_st_proc%type;
   vv_cod_mod           mod_fiscal.cod_mod%type;
   vv_cod_part          pessoa.cod_part%type;
   vn_dm_ret_nf_erp     nota_fiscal.dm_ret_nf_erp%type;
   vn_dm_rec_xml        nota_fiscal.dm_rec_xml%type;
   vb_nfe_proc_xml      nota_fiscal.nfe_proc_xml%type;
   vn_modfiscal_id      nota_fiscal.modfiscal_id%type;
   vn_pessoa_id         nota_fiscal.pessoa_id%type;
   vn_nro_protocolo     nota_fiscal.nro_protocolo%type;
   vn_dm_st_andam_cons  number(1);
   vn_lim_hora_canc_nfe number;
   vn_dif_horas         number;
   --
   cursor c_csf_cons_sit is
   select *
     from csf_cons_sit
    where empresa_id = en_empresa_id
      and dm_situacao in (2, 3, 4)
      and dm_integr_erp = 0
      and nvl(notafiscal_id,0) > 0
    order by id;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_XML_NFE_TERC') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   for rec in c_csf_cons_sit loop
      exit when c_csf_cons_sit%notfound or (c_csf_cons_sit%notfound) is null;
      --
      vb_retorna_xml := false;
      --
      vn_fase := 2.1;
      --
      begin
         --
         select nf.empresa_id
              , nf.dm_ind_emit
              , nf.dm_ind_oper
              , nf.dt_emiss
              , nf.nro_nf
              , nf.serie
              , nf.nro_chave_nfe
              , nf.dm_st_proc
              , nf.dm_ret_nf_erp
              , nf.dm_rec_xml
              , nf.modfiscal_id
              , nf.pessoa_id
              , nf.nro_protocolo
           into vn_empresa_id
              , vn_dm_ind_emit
              , vn_dm_ind_oper
              , vd_dt_emiss
              , vn_nro_nf
              , vv_serie
              , vv_nro_chave_nfe
              , vn_dm_st_proc
              , vn_dm_ret_nf_erp
              , vn_dm_rec_xml
              , vn_modfiscal_id
              , vn_pessoa_id
              , vn_nro_protocolo
           from nota_fiscal nf
          where nf.id = rec.NOTAFISCAL_ID
            and nf.dm_st_proc in (4, 6, 7, 8);
         --
      exception
         when others then
            --
            vn_empresa_id     := null;
            vn_dm_ind_emit    := null;
            vn_dm_ind_oper    := null;
            vd_dt_emiss       := null;
            vn_nro_nf         := null;
            vv_serie          := null;
            vv_nro_chave_nfe  := null;
            vn_dm_st_proc     := null;
            vn_dm_ret_nf_erp  := null;
            vn_dm_rec_xml     := null;
            vb_nfe_proc_xml   := null;
            vn_modfiscal_id   := null;
            vn_pessoa_id      := null;
            vn_nro_protocolo  := null;
            --
      end;
      --
      vn_fase := 3;
      --
      vv_cpf_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => vn_empresa_id ); -- rec.EMPRESA_ID
      vv_cod_mod  := pk_csf.fkg_cod_mod_id ( en_modfiscal_id => vn_modfiscal_id );
      vv_cod_part := pk_csf.fkg_cnpjcpf_pessoa_id(vn_pessoa_id); --pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => vn_pessoa_id );
      vd_dt_aut_sefaz := nvl(rec.dhrecbto,sysdate);
      --
      vn_fase := 3.1;
      --| Retona o Status de andamento da Consulta
      -- Recupera o Limite de horas para cancelar uma NFe no estado dela
      begin
         --
         select est.lim_hora_canc_nfe
           into vn_lim_hora_canc_nfe
           from estado est
          where ibge_estado = substr(vv_nro_chave_nfe, 1, 2);
         --
      exception
         when others then
            vn_lim_hora_canc_nfe := 0;
      end;
      --
      vn_fase := 3.2;
      -- cálcula a direfença de horas
      vn_dif_horas := (sysdate - vd_dt_aut_sefaz) * 24;
      --
      if vn_dm_st_proc = 7 then
         --
         vn_dm_st_andam_cons := 0; -- Cancelado
         --
      else
         --
         if nvl(vn_dif_horas,0) >= vn_lim_hora_canc_nfe then
            --
            vn_dm_st_andam_cons := 2; -- Autorizada
            --
         else
            --
            vn_dm_st_andam_cons := 1; -- Passível de cancelamento;
            --
         end if;
         --
      end if;
      --
      vn_fase := 3.3;
      --
      if vn_dm_rec_xml = 1
         and nvl(vn_nro_protocolo,0) > 0
         then
         --
         vn_fase := 4;
         -- Inicio de montagem do bloco para inserir ou alterar os dados da VW_CSF_XML_NFE_TERC
         if ev_nome_dblink is not null then
            --
            vb_retorna_xml := false;
            --
            vv_obj := ev_aspas || 'VW_CSF_XML_NFE_TERC' || ev_aspas || '@' || ev_nome_dblink;
            --
         else
            --
            vb_retorna_xml := true;
            --
            vv_obj := ev_aspas || 'VW_CSF_XML_NFE_TERC' || ev_aspas;
            --
         end if;
         --
         if trim(ev_owner_obj) is not null then
            vv_obj := trim(ev_owner_obj) || '.' || vv_obj;
         else
            vv_obj := vv_obj;
         end if;
         --
         vn_fase := 5;
         --
         gv_sql := null;
         --
         gv_sql := 'declare';
         gv_sql := gv_sql || ' vn_qntd_id number;';
         gv_sql := gv_sql || ' vn_qntd_ch number;';
         gv_sql := gv_sql || ' vb_nfe_proc_xml nota_fiscal.nfe_proc_xml%type;';
         gv_sql := gv_sql || ' vv_nome_dblink  empresa_integr_banco.nome_dblink%type;';
         --
         gv_sql := gv_sql || ' begin';
         --
         gv_sql := gv_sql || ' begin';
         gv_sql := gv_sql || ' select nfe_proc_xml';
         gv_sql := gv_sql || ' into vb_nfe_proc_xml';
         gv_sql := gv_sql || ' from nota_fiscal';
         gv_sql := gv_sql || ' where id = ' || rec.NOTAFISCAL_ID || ';';
         gv_sql := gv_sql || ' exception when others then';
         gv_sql := gv_sql || ' vb_nfe_proc_xml := null;';
         gv_sql := gv_sql || ' end;';
         -- Verificar se já existe registro pelo identificador da nota (notafiscal_id)
         gv_sql := gv_sql || ' begin';
         gv_sql := gv_sql || ' select count(1)';
         gv_sql := gv_sql || ' into vn_qntd_id';
         gv_sql := gv_sql || ' from ' || vv_obj;
         gv_sql := gv_sql || ' where notafiscal_id = ' || rec.NOTAFISCAL_ID || ';';
         gv_sql := gv_sql || ' exception when others then';
         gv_sql := gv_sql || ' vn_qntd_id := 1;';
         gv_sql := gv_sql || ' end;';
         -- Se não houver registro pelo identificador da nota (notafiscal_id), verificar pelo nro da chave nfe
         gv_sql := gv_sql || ' if nvl(vn_qntd_id,-1) <= 0 and trim(' || '''' || trim(vv_nro_chave_nfe) || '''' || ') is not null then';
         gv_sql := gv_sql || ' begin';
         gv_sql := gv_sql || ' select count(1)';
         gv_sql := gv_sql || ' into vn_qntd_ch';
         gv_sql := gv_sql || ' from ' || vv_obj;
         gv_sql := gv_sql || ' where nro_chave_nfe = ' || '''' || trim(vv_nro_chave_nfe) || '''' || ';';
         gv_sql := gv_sql || ' exception when others then';
         gv_sql := gv_sql || ' vn_qntd_ch := 1;';
         gv_sql := gv_sql || ' end;';
         gv_sql := gv_sql || ' end if;';
         --
         gv_sql := gv_sql || ' if nvl(vn_qntd_id,-1) <= 0 and nvl(vn_qntd_ch,-1) <= 0 then';
         --
         gv_sql := gv_sql || ' insert into ';
         --
         vn_fase := 6;
         --
         gv_sql := gv_sql || vv_obj || ' (';
         --
         gv_sql := gv_sql || ev_aspas || 'CPF_CNPJ_EMIT' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'DM_IND_EMIT' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'DM_IND_OPER' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'COD_PART' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'COD_MOD' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'SERIE' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'NRO_NF' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'NRO_CHAVE_NFE' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'NOTAFISCAL_ID' || ev_aspas;
         --
         if vb_retorna_xml = true then
            gv_sql := gv_sql || ', ' || ev_aspas || 'ARQUIVO' || ev_aspas;
         end if;
         --
         gv_sql := gv_sql || ', ' || ev_aspas || 'DT_EMISS' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'DM_ST_PROC' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'DT_HR_AUT_SEFAZ' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'DM_LEITURA' || ev_aspas;
         gv_sql := gv_sql || ', ' || ev_aspas || 'DM_ST_ANDAM_CONS' || ev_aspas;
         --
         gv_sql := gv_sql || ') values (';
         --
         gv_sql := gv_sql || '''' || vv_cpf_cnpj || '''';
         gv_sql := gv_sql || ', ' || vn_dm_ind_emit;
         gv_sql := gv_sql || ', ' || vn_dm_ind_oper;
         --
         gv_sql := gv_sql || ', ' || case when trim(vv_cod_part) is not null then '''' || trim(vv_cod_part) || '''' else 'null' end;
         --
         gv_sql := gv_sql || ', ' || vv_cod_mod;
         gv_sql := gv_sql || ', ' || vv_serie;
         --
         gv_sql := gv_sql || ', ' || case when trim(vn_nro_nf) is not null then '''' || trim(vn_nro_nf) || '''' else 'null' end;
         gv_sql := gv_sql || ', ' || case when trim(vv_nro_chave_nfe) is not null then '''' || trim(vv_nro_chave_nfe) || '''' else 'null' end;
         --
         gv_sql := gv_sql || ', ' || rec.NOTAFISCAL_ID;
         --
         if vb_retorna_xml = true then
            --
            gv_sql := gv_sql || ', vb_nfe_proc_xml';
            --
--         else
            --
  --          gv_sql := gv_sql || ', null';
            --
         end if;
         --
         gv_sql := gv_sql || ', ''' || vd_dt_emiss || '''';
         gv_sql := gv_sql || ', ' || vn_dm_st_proc;
         --
         gv_sql := gv_sql || ', ''' || vd_dt_aut_sefaz || '''';
         --
         gv_sql := gv_sql || ', 0';
         gv_sql := gv_sql || ', ' || vn_dm_st_andam_cons;
         --
         gv_sql := gv_sql || ');';
         --
         gv_sql := gv_sql || ' else';
         -- Encontrou o registro pelo identificador da nota (notafiscal_id)
         gv_sql := gv_sql || ' if nvl(vn_qntd_id,-1) > 0 then';
         --
         gv_sql := gv_sql || ' update ' || vv_obj || ' set ';
         gv_sql := gv_sql ||         ev_aspas || 'DM_ST_PROC' || ev_aspas || ' = ' || vn_dm_st_proc;
         gv_sql := gv_sql || ', ' || ev_aspas || 'DM_LEITURA' || ev_aspas || ' = 0';
         gv_sql := gv_sql || ', ' || ev_aspas || 'DM_ST_ANDAM_CONS' || ev_aspas || ' = ' || vn_dm_st_andam_cons;
         gv_sql := gv_sql || ' where ';
         gv_sql := gv_sql || ev_aspas || 'NOTAFISCAL_ID' || ev_aspas || ' = ' || trim(rec.NOTAFISCAL_ID) || ';';
         -- Encontrou o registro pelo nro da chave nfe
         gv_sql := gv_sql || ' elsif nvl(vn_qntd_ch,-1) > 0 then';
         --
         gv_sql := gv_sql || ' update ' || vv_obj || ' set ';
         gv_sql := gv_sql || ev_aspas || 'DM_ST_PROC' || ev_aspas || ' = ' || vn_dm_st_proc;
         gv_sql := gv_sql || ', ' || ev_aspas || 'DM_LEITURA' || ev_aspas || ' = 0';
         gv_sql := gv_sql || ', ' || ev_aspas || 'DM_ST_ANDAM_CONS' || ev_aspas || ' = ' || vn_dm_st_andam_cons;
         gv_sql := gv_sql || ' where nro_chave_nfe = ' || '''' || trim(vv_nro_chave_nfe) || '''' || ';';
         --
         gv_sql := gv_sql || ' end if;';
         --
         gv_sql := gv_sql || ' end if;';
         --
         gv_sql := gv_sql || ' commit; end;';
         --
         vn_erro := 0;
         --
         vn_fase := 7;
         --
         begin
            --
            execute immediate gv_sql;
            --
         exception
            when others then
               --
               vn_erro := 1;
               --
               pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_csf_cons_sit - primeira etapa (notafiscal_id = '||rec.notafiscal_id||' nro_nf = '||
                                             vn_nro_nf||', nro_chave_nfe = '||vv_nro_chave_nfe||'), fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                 , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                 , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                 , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                                 , en_referencia_id    => rec.id
                                                 , ev_obj_referencia   => 'CSF_CONS_SIT'
                                                 );
                  --
               exception
                  when others then
                     null;
               end;
               --
         end;
         --
         vn_fase := 8;
         -- Processo de verificar NFe com DM_ST_ANDAM_CONS = 1-Passível de Cancelamento; Caso a Data de Autorização seja maior que 24 horas (1 dia), muda o campo DM_ST_ANDAM_CONS para 2-Autorizada
         gv_sql := 'declare';
         gv_sql := gv_sql || ' vn_dif number;';
         gv_sql := gv_sql || ' vv_dt_converte varchar2(50);';
         gv_sql := gv_sql || ' cursor c_dados is';
         gv_sql := gv_sql || ' select dt_hr_aut_sefaz, notafiscal_id from ' || vv_obj;
         gv_sql := gv_sql || ' where DM_ST_ANDAM_CONS = 1;';
         gv_sql := gv_sql || ' begin';
         gv_sql := gv_sql || ' for rec in c_dados loop';
         gv_sql := gv_sql || ' exit when c_dados%notfound or (c_dados%notfound) is null;';
         --gv_sql := gv_sql || ' vn_dif := sysdate - rec.dt_hr_aut_sefaz;';
         -- alguns clientes estão com o campo dt_hr_aut_sefaz declarados como Caracter, por isso a conversão para data
         gv_sql := gv_sql || ' vv_dt_converte := rec.dt_hr_aut_sefaz;';
         gv_sql := gv_sql || ' vn_dif := (sysdate - to_date(vv_dt_converte));';
         gv_sql := gv_sql || ' if nvl(vn_dif,0) > 1 then';
         gv_sql := gv_sql || ' update ' || vv_obj || ' set DM_ST_ANDAM_CONS = 2, DM_LEITURA = 0 where NOTAFISCAL_ID = rec.NOTAFISCAL_ID;';
         gv_sql := gv_sql || ' commit;';
         gv_sql := gv_sql || ' end if;';
         gv_sql := gv_sql || ' end loop;';
         gv_sql := gv_sql || ' end;';
         --
         vn_fase := 8.1;
         --
         begin
            --
            execute immediate gv_sql;
            --
         exception
            when others then
               --
               vn_erro := 1;
               --
               pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_csf_cons_sit - segunda etapa (notafiscal_id = '||rec.notafiscal_id||' nro_nf = '||
                                             vn_nro_nf||', nro_chave_nfe = '||vv_nro_chave_nfe||'), fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                 , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                 , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                 , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                                 , en_referencia_id    => rec.id
                                                 , ev_obj_referencia   => 'CSF_CONS_SIT'
                                                 );
                  --
               exception
                  when others then
                     null;
               end;
               --
         end;
         --
         vn_fase := 9;
         -- retira a consulta da fila
         if nvl(vn_erro,0) = 0 then
            --
            -- Variavel global usada em logs de triggers (carrega)
            gv_objeto := 'pk_integr_view_nfce.pkb_int_csf_cons_sit';
            gn_fase   := vn_fase;
            --
            update nota_fiscal
               set dm_ret_nf_erp = 0
             where id = rec.notafiscal_id;
            --
            -- Variavel global usada em logs de triggers (limpa)
            gv_objeto := 'pk_integr_view_nfce';
            gn_fase   := null;
            --
            pkb_seta_integr_erp_csf_cs ( en_csfconssit_id => rec.ID 
                                       , en_empresa_id    => rec.empresa_id );
            --
         end if;
         --
      end if;
      --
   end loop;
   --
   commit;
   --
exception
   when others then
    --
    pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_csf_cons_sit fase(' || vn_fase || ') empresa (' || vv_cpf_cnpj || '):' || sqlerrm;
    --
    declare
       vn_loggenerico_id  log_generico_nf.id%TYPE;
    begin
       --
       pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                      , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                      , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                      , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                      , en_referencia_id    => null
                                      , ev_obj_referencia   => 'NOTA_FISCAL'
                                      );
       --
    exception
       when others then
          null;
    end;
    --
end pkb_int_csf_cons_sit;
--
-- ================================================================================================================= --
-- Procedimento integra informações no ERP para campos FF
procedure pkb_int_ret_infor_erp_ff ( ev_cpf_cnpj_emit  in  varchar2
                                   , en_dm_ind_emit    in  number
                                   , en_dm_ind_oper    in  number
                                   , ev_cod_part       in  varchar2
                                   , ev_cod_mod        in  varchar2
                                   , ev_serie          in  varchar2
                                   , en_nro_nf         in  number
                                   , en_notafiscal_id  in  nota_fiscal.id%type default 0
                                   , ev_owner_obj      in  empresa_integr_banco.owner_obj%type
                                   , ev_nome_dblink    in  empresa_integr_banco.nome_dblink%type
                                   , ev_aspas          in  char
                                   ) is
   --
   vn_fase    number         := 0;
   vv_insert  varchar2(4000) := null;
   vv_update  varchar2(4000) := null;
   vv_obj     varchar2(255)  := null;
   vn_existe  number         := 0;
   --
   cursor c_ff is
      select nf.cod_msg
           , nfc.id_erp
        from nota_fiscal nf
           , nota_fiscal_compl nfc
       where nf.id                = en_notafiscal_id
         and nfc.notafiscal_id(+) = nf.id
         and not exists (select 1
                           from nota_fiscal_canc nfca
                          where nfca.notafiscal_id = nf.id)
       union
       select nfca.cod_msg
            , nfca.id_erp
         from nota_fiscal nf
            , nota_fiscal_canc nfca
        where nf.id              = en_notafiscal_id
          and nfca.notafiscal_id = nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NF_ERP_FF') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NF_ERP_FF'
                                  , ev_aspas       => ev_aspas
                                  , ev_owner_obj   => ev_owner_obj
                                  , ev_nome_dblink => ev_nome_dblink
                                  );
   --
   vn_fase := 3;
   --
   vv_insert := 'insert into ' || vv_obj || '(';
   --
   vv_insert := vv_insert ||         ev_aspas || 'CPF_CNPJ_EMIT' || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas || 'DM_IND_EMIT'   || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas || 'DM_IND_OPER'   || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas || 'COD_PART'      || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas || 'COD_MOD'       || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas || 'SERIE'         || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas || 'NRO_NF'        || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas || 'ATRIBUTO'      || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas || 'VALOR'         || ev_aspas;
   --
   vv_insert := vv_insert || ') values (';
   --
   vv_insert := vv_insert || '''' || ev_cpf_cnpj_emit || '''';
   vv_insert := vv_insert || ', ' || en_dm_ind_emit;
   vv_insert := vv_insert || ', ' || en_dm_ind_oper;
   --
   vv_insert := vv_insert || ', ' || case when trim(ev_cod_part) is not null then '''' || trim(ev_cod_part) || '''' else 'null' end;
   --
   vv_insert := vv_insert || ', ' || '''' || ev_cod_mod || '''';
   vv_insert := vv_insert || ', ' || '''' || ev_serie || '''';
   vv_insert := vv_insert || ', ' || en_nro_nf;
   --
   vn_fase := 4;
   --
   vv_update := 'update ' || vv_obj || ' set ';
   --
   vn_fase := 5;
   --
   for rec in c_ff loop
      exit when c_ff%notfound or (c_ff%notfound) is null;
      --
      vn_fase := 6;
      --
      vn_existe := 0;
      --
      if nvl(rec.id_erp,0) > 0 then
         --
         vn_fase := 7;
         --
         vn_existe := fkg_existe_registro ( ev_cpf_cnpj_emit => ev_cpf_cnpj_emit
                                          , en_dm_ind_emit   => en_dm_ind_emit
                                          , en_dm_ind_oper   => en_dm_ind_oper
                                          , ev_cod_part      => ev_cod_part
                                          , ev_cod_mod       => ev_cod_mod
                                          , ev_serie         => ev_serie
                                          , en_nro_nf        => en_nro_nf
                                          , ev_atributo      => 'ID_ERP'
                                          , ev_obj           => vv_obj
                                          , ev_aspas         => ev_aspas
                                          );
         --
         vn_fase := 8;
         --
         if vn_existe > 0 then
            --
            vn_fase := 9;
            --
            gv_sql := vv_update || ev_aspas || 'VALOR' || ev_aspas || ' = ' || rec.id_erp;
            --
            gv_sql := gv_sql || ' where ';
            gv_sql := gv_sql ||            ev_aspas || 'CPF_CNPJ_EMIT' || ev_aspas || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
            gv_sql := gv_sql || ' and ' || ev_aspas || 'DM_IND_EMIT'   || ev_aspas || ' = ' || en_dm_ind_emit;
            gv_sql := gv_sql || ' and ' || ev_aspas || 'DM_IND_OPER'   || ev_aspas || ' = ' || en_dm_ind_oper;
            --
            vn_fase := 10;
            --
            if ev_cod_part is not null then
               --
               gv_sql := gv_sql || ' and ' || ev_aspas || 'COD_PART' || ev_aspas || ' = ' || '''' || ev_cod_part || '''';
               --
            end if;
            --
            vn_fase := 11;
            --
            gv_sql := gv_sql || ' and ' || ev_aspas || 'COD_MOD'  || ev_aspas || ' = ' || '''' || ev_cod_mod || '''';
            gv_sql := gv_sql || ' and ' || eV_ASPAS || 'SERIE'    || eV_ASPAS || ' = ' || '''' || ev_serie || '''';
            gv_sql := gv_sql || ' and ' || ev_aspas || 'NRO_NF'   || ev_aspas || ' = ' || en_nro_nf;
            gv_sql := gv_sql || ' and ' || ev_aspas || 'ATRIBUTO' || ev_aspas || ' = ''ID_ERP''';
            --
         else
            --
            vn_fase := 12;
            --
            gv_sql := vv_insert || ', ' || '''ID_ERP''';
            gv_sql := gv_sql || ', ' || '''' || rec.id_erp || ''')';
            --
         end if;
         --
         vn_fase := 13;
         --
         begin
            --
            execute immediate gv_sql;
            --
         exception
            when others then
               --
               -- A função replace está sendo utilizada para substituir uma aspas por duas, no comando executado,
               -- pois esse log será registrado em outra tabela através de uma query dinâmica feita pelo procedimento
               -- pkb_ret_infor_erro_nf_erp, e quando tem apenas uma aspas, ocorre o erro: ORA-00917: vírgula não encontrada
               --
               pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_ret_infor_erp_ff fase(' || vn_fase || '):' || sqlerrm || ' - ' || replace (gv_sql, '''', '''''');
               --
               declare
                  vn_loggenerico_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                 , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                 , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                 , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                                 , en_referencia_id    => en_notafiscal_id
                                                 , ev_obj_referencia   => 'NOTA_FISCAL' );
                  --
               exception
                  when others then
                     null;
               end;
               --
         end;
         --
      end if;
      --
      vn_fase := 14;
      --
      if nvl(rec.cod_msg,0) > 0 then
         --
         vn_fase := 15;
         --
         vn_existe := fkg_existe_registro ( ev_cpf_cnpj_emit => ev_cpf_cnpj_emit
                                          , en_dm_ind_emit   => en_dm_ind_emit
                                          , en_dm_ind_oper   => en_dm_ind_oper
                                          , ev_cod_part      => ev_cod_part
                                          , ev_cod_mod       => ev_cod_mod
                                          , ev_serie         => ev_serie
                                          , en_nro_nf        => en_nro_nf
                                          , ev_atributo      => 'COD_MSG'
                                          , ev_obj           => vv_obj
                                          , ev_aspas         => ev_aspas
                                          );
         --
         vn_fase := 16;
         --
         if vn_existe > 0 then
            --
            vn_fase := 17;
            --
            gv_sql := vv_update || ev_aspas || 'VALOR' || ev_aspas || ' = ' || rec.cod_msg;
            --
            gv_sql := gv_sql || ' where ';
            gv_sql := gv_sql ||            ev_aspas || 'CPF_CNPJ_EMIT' || ev_aspas || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
            gv_sql := gv_sql || ' and ' || ev_aspas || 'DM_IND_EMIT'   || ev_aspas || ' = ' || en_dm_ind_emit;
            gv_sql := gv_sql || ' and ' || ev_aspas || 'DM_IND_OPER'   || ev_aspas || ' = ' || en_dm_ind_oper;
            --
            vn_fase := 18;
            --
            if ev_cod_part is not null then
               --
               gv_sql := gv_sql || ' and ' || ev_aspas || 'COD_PART' || ev_aspas || ' = ' || '''' || ev_cod_part || '''';
               --
            end if;
            --
            vn_fase := 19;
            --
            gv_sql := gv_sql || ' and ' || ev_aspas || 'COD_MOD'  || ev_aspas || ' = ' || '''' || ev_cod_mod || '''';
            gv_sql := gv_sql || ' and ' || eV_ASPAS || 'SERIE'    || eV_ASPAS || ' = ' || '''' || ev_serie || '''';
            gv_sql := gv_sql || ' and ' || ev_aspas || 'NRO_NF'   || ev_aspas || ' = ' || en_nro_nf;
            gv_sql := gv_sql || ' and ' || ev_aspas || 'ATRIBUTO' || ev_aspas || ' = ''COD_MSG''';
            --
         else
            --
            gv_sql := vv_insert || ', ' || '''COD_MSG''';
            gv_sql := gv_sql || ', ' || '''' || rec.cod_msg || ''')';
            --
         end if;
         --
         vn_fase := 20;
         --
         begin
            --
            execute immediate gv_sql;
            --
         exception
            when others then
               --
               -- A função replace está sendo utilizada para substituir uma aspas por duas, no comando executado,
               -- pois esse log será registrado em outra tabela através de uma query dinâmica feita pelo procedimento
               -- pkb_ret_infor_erro_nf_erp, e quando tem apenas uma aspas, ocorre o erro: ORA-00917: vírgula não encontrada
               --
               pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_ret_infor_erp_ff fase(' || vn_fase || '):' || sqlerrm || ' - ' || replace (gv_sql, '''', '''''');
               --
               declare
                  vn_loggenerico_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                 , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                 , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                 , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                                 , en_referencia_id    => en_notafiscal_id
                                                 , ev_obj_referencia   => 'NOTA_FISCAL' );
                  --
               exception
                  when others then
                     null;
               end;
               --
         end;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_ret_infor_erp_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_ret_infor_erp_ff;
--
-- ================================================================================================================= --
-- Retorna informações de Erro ocorrido no processo da nota fiscal
procedure pkb_ret_infor_erro_nf_erp ( en_notafiscal_id in nota_fiscal.id%type
                                    , ev_obj           in obj_util_integr.obj_name%type ) is
   --
   PRAGMA AUTONOMOUS_TRANSACTION;
   --
   vn_fase           number         := 0;
   vv_obj            varchar2(4000) := null;
   vv_cpf_cnpj       varchar2(14)   := null;
   vv_cod_part       pessoa.cod_part%type;
   vv_cod_mod        mod_fiscal.cod_mod%type;
   vv_sistorig_sigla sist_orig.sigla%type;
   vv_unidorg_cd     unid_org.cd%type;
   --
   cursor c_nf is
   select nf.empresa_id
        , nf.dm_ind_oper
        , nf.dm_ind_emit
        , nf.pessoa_id
        , nf.modfiscal_id
        , nf.serie
        , nf.nro_nf
        , nf.id                 notafiscal_id
        , nf.dm_st_integra
        , nf.sistorig_id
        , nf.unidorg_id
     from nota_fiscal nf
    where nf.id = en_notafiscal_id;
   --
   cursor c_log ( en_referencia_id in log_generico_nf.referencia_id%type ) is
   select max(lg.id) loggenerico_id -- mantemos o último gerado devido a repetição de mensagens
        , lg.mensagem
        , lg.resumo
     from log_generico_nf  lg
        , csf_tipo_log  tl
    where lg.referencia_id   = en_referencia_id
      and lg.obj_referencia  = 'NOTA_FISCAL'
      and tl.id              = lg.csftipolog_id
      and tl.cd in ( 'ERRO_VALIDA'
                   , 'ERRO_GERAL_SISTEMA'
                   , 'ERRO_XML_NFE'
                   , 'ERRO_ENV_LOTE_SEFAZ_NFE'
                   , 'ERRO_RET_ENV_LOTE_SEFAZ_NFE'
                   , 'ERRO_RET_PROC_LOTE_SEFAZ_NFE'
                   , 'ERRO_RET_PROC_LOTE_NFE'
                   , 'ERRO_ENVRET_CANCELA_NFE'
                   , 'ERRO_ENVRET_INUTILIZA_NFE'
                   , 'ERRO_ENV_EMAIL_DEST_NFE'
                   , 'ERRO_IMPRESSAO_DANFE'
                   , 'INFO_RET_PROC_LOTE_NFE' )
    group by lg.mensagem
        , lg.resumo
   union
   select max(lg.id) loggenerico_id -- mantemos o último gerado devido a repetição de mensagens
        , lg.mensagem
        , lg.resumo
     from log_generico  lg
        , csf_tipo_log  tl
    where lg.referencia_id   = en_referencia_id
      and lg.obj_referencia  = 'NOTA_FISCAL'
      and tl.id              = lg.csftipolog_id
      and tl.cd in ( 'ERRO_VALIDA'
                   , 'ERRO_GERAL_SISTEMA'
                   , 'ERRO_XML_NFE'
                   , 'ERRO_ENV_LOTE_SEFAZ_NFE'
                   , 'ERRO_RET_ENV_LOTE_SEFAZ_NFE'
                   , 'ERRO_RET_PROC_LOTE_SEFAZ_NFE'
                   , 'ERRO_RET_PROC_LOTE_NFE'
                   , 'ERRO_ENVRET_CANCELA_NFE'
                   , 'ERRO_ENVRET_INUTILIZA_NFE'
                   , 'ERRO_ENV_EMAIL_DEST_NFE'
                   , 'ERRO_IMPRESSAO_DANFE'
                   , 'INFO_RET_PROC_LOTE_NFE' )
    group by lg.mensagem
        , lg.resumo
    order by 1;
   --
   -- =============================================================================================================== --
   -- Fuction interna
   function fkg_existe_log ( en_loggenericonf_id_id in log_generico_nf.id%type ) return number
   is
      --
      vv_sql_canc varchar2(4000);
      --
      vn_ret number := 0;
      --
   begin
      --
      -- Não pega notas com registro de cancelamento
      vv_sql_canc := vv_sql_canc || 'select 1 ' || fkg_monta_from ( ev_obj => ev_obj);
      --
      vv_sql_canc := vv_sql_canc || ' where ' || GV_ASPAS || 'LOGGENERICO_ID' || GV_ASPAS || ' = ' || en_loggenericonf_id_id;
      --
      begin
         --
         execute immediate vv_sql_canc into vn_ret;
         --
      exception
         when no_data_found then
            return 0;
         when others then
               --
               pk_csf_api_nfce.gv_mensagem_log := 'Erro na fkg_existe_log:' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                 , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                 , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                 , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                                 , en_referencia_id    => null
                                                 , ev_obj_referencia   => 'NOTA_FISCAL' );
                  --
               exception
                  when others then
                     null;
               end;
               --
      end;
      --
      return vn_ret;
      --
   end fkg_existe_log;
   --
   -- =============================================================================================================== --
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => ev_obj) = 0 then
      --
      return;
      --
   end if;
   --
   if nvl(en_notafiscal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec1 in c_nf loop
         exit when c_nf%notfound or (c_nf%notfound) is null;
         --
         vn_fase := 3;
         --
         vv_cpf_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec1.empresa_id );
         --
         vn_fase := 3.1;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec1.pessoa_id );
         --
         vn_fase := 3.2;
         --
         vv_cod_mod := pk_csf.fkg_cod_mod_id ( en_modfiscal_id => rec1.modfiscal_id );
         --
         vn_fase := 3.3;
         --
         vv_sistorig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec1.sistorig_id );
         --
         vn_fase := 3.4;
         --
         vv_unidorg_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec1.unidorg_id );
         --
         vn_fase := 4;
         -- Insere os registros de log da nota Fiscal
         for rec2 in c_log(rec1.notafiscal_id) loop
            exit when c_log%notfound or (c_log%notfound) is null;
            --
            vn_fase := 5;
            --
            if trim(rec2.resumo) is not null
               and fkg_existe_log ( en_loggenericonf_id_id => rec2.loggenerico_id ) = 0
               then
               --
               gv_sql := 'insert into ';
               --
               if GV_NOME_DBLINK is not null then
                  --
                  vn_fase := 6;
                  --
                  vv_obj := GV_ASPAS || ev_obj || GV_ASPAS || '@' || GV_NOME_DBLINK;
                  --
               else
                  --
                  vn_fase := 7;
                  --
                  vv_obj := GV_ASPAS || ev_obj || GV_ASPAS;
                  --
               end if;
               --
               if trim(GV_OWNER_OBJ) is not null then
                  vv_obj := trim(GV_OWNER_OBJ) || '.' || vv_obj;
               else
                  vv_obj := vv_obj;
               end if;
               --
               vn_fase := 8;
               --
               gv_sql := gv_sql || vv_obj || ' (';
               --
               gv_sql := gv_sql ||         GV_ASPAS || 'CPF_CNPJ_EMIT'  || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER'    || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT'    || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART'       || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD'        || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'SERIE'          || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF'         || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'NOTAFISCAL_ID'  || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'LOGGENERICO_ID' || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'RESUMO'         || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_LEITURA'     || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'SIST_ORIG'      || GV_ASPAS;
               gv_sql := gv_sql || ', ' || GV_ASPAS || 'UNID_ORG'       || GV_ASPAS;
               --
               gv_sql := gv_sql || ') values (';
               --
               gv_sql := gv_sql || '''' || vv_cpf_cnpj || '''';
               gv_sql := gv_sql || ', ' || rec1.DM_IND_OPER;
               gv_sql := gv_sql || ', ' || rec1.DM_IND_EMIT;
               --
               gv_sql := gv_sql || ', ' || case when trim(vv_cod_part) is not null then '''' || trim(vv_cod_part) || '''' else '''' || vv_cpf_cnpj || '''' end;
               --
               gv_sql := gv_sql || ', ' || '''' || vv_cod_mod || '''';
               gv_sql := gv_sql || ', ' || '''' || rec1.SERIE || '''';
               gv_sql := gv_sql || ', ' || rec1.NRO_NF;
               gv_sql := gv_sql || ', ' || rec1.notafiscal_id;
               gv_sql := gv_sql || ', ' || nvl(rec2.loggenerico_id,0);
               gv_sql := gv_sql || ', ' || case when trim(pk_csf.fkg_converte(rec2.resumo)) is not null then '''' || trim(pk_csf.fkg_converte(rec2.resumo)) || '''' else '''' || ' ' || '''' end;
               gv_sql := gv_sql || ', 0'; -- DM_LEITURA
               gv_sql := gv_sql || ', ' || case when trim(vv_sistorig_sigla) is not null then '''' || trim(vv_sistorig_sigla) || '''' else '''' || ' ' || '''' end;
               gv_sql := gv_sql || ', ' || case when trim(vv_unidorg_cd) is not null then '''' || trim(vv_unidorg_cd) || '''' else '''' || ' ' || '''' end;
               --
               gv_sql := gv_sql || ')';
               --
               vn_fase := 9;
               --
               begin
                  --
                  execute immediate gv_sql;
                  --
               exception
                  when others then
                     -- não registra erro caso a view não exista
                     if sqlcode IN (-942, -28500, -01010, -02063) then
                        null;
                     else
                        --
                        pk_csf_api_nfce.gv_mensagem_log := 'Erro na Erro na pk_integr_view_nfce.pkb_ret_infor_erro_nf_erp fase(' || vn_fase || ') ('||gv_sql||'):' || sqlerrm;
                        --
                        declare
                           vn_loggenerico_id  log_generico_nf.id%TYPE;
                        begin
                           --
                           pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                          , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                          , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                          , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                                          , en_referencia_id    => en_notafiscal_id
                                                          , ev_obj_referencia   => 'NOTA_FISCAL' );
                           --
                        exception
                           when others then
                              null;
                        end;
                        --
                     end if;
               end;
               --
            end if;
            --
         end loop;
         --
         commit;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ret_infor_erro_nf_erp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ret_infor_erro_nf_erp;
--
-- ================================================================================================================= --
-- Procedimento retorna a informação para o ERP
procedure pkb_ret_infor_erp ( ev_cpf_cnpj_emit in varchar2 ) is
   --
   vn_fase                  number := 0;
   vn_notafiscal_id         Nota_Fiscal.id%TYPE;
   vn_dm_st_integra         nota_fiscal.dm_st_integra%type;
   vn_dm_st_proc_erp        number(2) := null;
   vv_obj                   varchar2(4000) := null;
   vv_sql_where             varchar2(4000) := null;
   vn_qtde                  number := 0;
   vn_erro                  number := 0;
   vn_dm_ret_hr_aut         empresa.dm_ret_hr_aut%type := 0;
   vn_empresa_id            empresa.id%type;
   vv_cod_part              pessoa.cod_part%type;
   vv_sitdocto_cd           sit_docto.cd%type;
   vv_sistorig_sigla        sist_orig.sigla%type;
   vv_unidorg_cd            unid_org.cd%type;
   vd_dt_canc               nota_fiscal_canc.dt_hr_recbto%type;
   vn_nro_protocolo_canc    nota_fiscal_canc.nro_protocolo%type;
   vv_owner_obj             empresa_integr_banco.owner_obj%type;
   vv_nome_dblink           empresa_integr_banco.nome_dblink%type;
   vn_dm_util_aspa          empresa_integr_banco.dm_util_aspa%type;
   vn_dm_ret_infor_integr   empresa_integr_banco.dm_ret_infor_integr%type;
   vv_formato_dt_erp        empresa_integr_banco.formato_dt_erp%type;
   vn_dm_form_dt_erp        empresa_integr_banco.dm_form_dt_erp%type;
   vv_aspas                 char(1) := null;
   --
   -- Recupera as notas que foram inseridas na tabela de resposta do ERP
   cursor c_nf (en_empresa_id number) is
   select nf.empresa_id
        , nf.dm_ind_oper
        , nf.dm_ind_emit
        , nf.pessoa_id
        , mf.cod_mod
        , nf.serie
        , nf.nro_nf
        , nf.sitdocto_id
        , nf.dm_st_proc
        , nf.dt_st_proc
        , nf.dm_forma_emiss
        , nf.dm_impressa
        , nf.dm_st_email
        , nf.dm_tp_amb
        , nf.nro_chave_nfe
        , nf.cNF_nfe
        , nf.dig_verif_chave
        , nf.dm_aut_sefaz
        , nf.dt_aut_sefaz
        , nf.nro_protocolo
        , nf.id                 notafiscal_id
        , nf.dt_emiss
        , nf.dm_st_integra
        , nf.sistorig_id
        , nf.unidorg_id
        , nf.cod_msg
        , nf.empresaintegrbanco_id
     from Nota_Fiscal           nf
        , mod_fiscal            mf
    where nf.empresa_id         = en_empresa_id
      and nf.dm_st_proc         > 3 -- Sempre maior que 3-Aguardando Retorno
      and nf.dm_ind_emit        = 0 -- emissão própria
      and nf.dm_st_integra      = 8 -- Aguardando retorno para o ERP
      and trunc(nf.DT_HR_ENT_SIST) > trunc(sysdate-30)
      and ( nf.cod_msg is null or nf.cod_msg not in ('204', '539', '290') )
      and mf.id                 = nf.modfiscal_id
      and mf.cod_mod            = '65' -- somente modelo 65
    order by nf.id;

begin
   -- Atualiza informações
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NF_ERP') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_cpf_cnpj ( en_multorg_id => gn_multorg_id
                                                   , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 3;
   --
   for rec in c_nf(vn_empresa_id) loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 4;
      --
      if nvl(rec.empresaintegrbanco_id,0) > 0
         and nvl(rec.empresaintegrbanco_id,0) <> nvl(gn_empresaintegrbanco_id,0)
         then
         --
         vn_fase := 5;
         --
         begin
            --
            select ei.owner_obj
                 , ei.nome_dblink
                 , ei.dm_util_aspa
                 , ei.dm_ret_infor_integr
                 , ei.formato_dt_erp
                 , ei.dm_form_dt_erp
              into vv_owner_obj
                 , vv_nome_dblink
                 , vn_dm_util_aspa
                 , vn_dm_ret_infor_integr
                 , vv_formato_dt_erp
                 , vn_dm_form_dt_erp
              from empresa_integr_banco ei
             where ei.id = rec.empresaintegrbanco_id;
            --
         exception
            when others then
               null;
         end;
         --
         if nvl(vn_dm_form_dt_erp,0) = 0
            or trim(vv_formato_dt_erp) is null then
            --
            vv_formato_dt_erp := gv_formato_data;
            --
         end if;
         --
         if nvl(vn_dm_util_aspa,0) = 1 then
            --
            vv_aspas := '"';
            --
         end if;
         --
         vn_fase := 6;
         --
      else
         --
         vn_fase := 7;
         --
         vv_owner_obj           := GV_OWNER_OBJ;
         vv_nome_dblink         := GV_NOME_DBLINK;
         vv_aspas               := GV_ASPAS;
         vn_dm_ret_infor_integr := GN_DM_RET_INFOR_INTEGR;
         vv_formato_dt_erp      := GD_FORMATO_DT_ERP;
         --
      end if;
      --
      vn_fase := 8;
      --
      vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NF_ERP'
                                     , ev_aspas       => vv_aspas
                                     , ev_owner_obj   => vv_owner_obj
                                     , ev_nome_dblink => vv_nome_dblink
                                     );
      --
      vn_fase := 9;
      --
      if nvl(vn_dm_ret_infor_integr,0) = 1 then
         --
         vn_fase := 9.1;
         --
         vn_dm_ret_hr_aut := pk_csf.fkg_ret_hr_aut_empresa_id ( en_empresa_id => vn_empresa_id );
         --
         vn_fase := 9.2;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
         --
         if trim(vv_cod_part) is null then
            vv_cod_part := trim(ev_cpf_cnpj_emit);
         end if;
         --
         vn_fase := 9.3;
         --
         vv_sitdocto_cd := pk_csf.fkg_Sit_Docto_cd ( en_sitdoc_id => rec.sitdocto_id );
         --
         vn_fase := 9.4;
         --
         vv_sistorig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec.sistorig_id );
         --
         vn_fase := 9.5;
         --
         vv_unidorg_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec.unidorg_id );
         --
         vn_fase := 9.6;
         --
         begin
            --
            select nfc.dt_hr_recbto
                 , nfc.nro_protocolo
              into vd_dt_canc
                 , vn_nro_protocolo_canc
              from nota_fiscal_canc nfc
             where nfc.notafiscal_id = rec.notafiscal_id;
            --
         exception
            when others then
               vd_dt_canc            := null;
               vn_nro_protocolo_canc := null;
         end;
         --
         vn_fase := 10;
         --
         vn_dm_st_proc_erp := fkg_ret_dm_st_proc_erp ( ev_cpf_cnpj_emit   => ev_cpf_cnpj_emit
                                                     , en_dm_ind_emit     => rec.dm_ind_emit
                                                     , en_dm_ind_oper     => rec.dm_ind_oper
                                                     , ev_cod_part        => vv_cod_part
                                                     , ev_cod_mod         => rec.cod_mod
                                                     , ev_serie           => rec.serie
                                                     , en_nro_nf          => rec.nro_nf
                                                     , en_notafiscal_id   => rec.notafiscal_id
                                                     , ev_obj             => vv_obj
                                                     , ev_aspas           => vv_aspas
                                                     , ev_obj_name        => 'VW_CSF_RESP_NF_ERP'
                                                     );
         --
         vn_fase := 11;
         -- Verifica se a situação da NFe no ERP é diferente de zero e diferetente da Situação da NFe no Compliance
         if nvl(vn_dm_st_proc_erp,0) not in (0, -1)
            and nvl(vn_dm_st_proc_erp,0) <> nvl(rec.dm_st_proc,0) then
            --
            vn_fase := 12;
            --
            vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8) then 9 else 8 end;
            --
            vn_fase := 13;
            -- Inicia montagem do update de atualização da resposta do ERP
            gv_sql := 'update ';
            --
            vn_fase := 14;
            --
            gv_sql := gv_sql || vv_obj || ' set ' || vv_aspas || 'SIT_DOCTO' || vv_aspas || ' = ' || '''' || case when rec.DM_ST_PROC = 7 then '02' when rec.DM_ST_PROC = 6 then '04' when rec.DM_ST_PROC = 8 then '05' else trim(vv_sitdocto_cd) end || '''';
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_ST_PROC' || vv_aspas || ' = ' || rec.dm_st_proc;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_ST_PROC' || vv_aspas || ' = ' || '''' || to_char(rec.dt_st_proc, vv_formato_dt_erp ) || '''';
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_EMISS' || vv_aspas || ' = ' || '''' || to_char(rec.dt_emiss, vv_formato_dt_erp ) || '''';
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_FORMA_EMISS' || vv_aspas || ' = ' || rec.dm_forma_emiss;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_IMPRESSA' || vv_aspas || ' = ' || rec.dm_impressa;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_ST_EMAIL' || vv_aspas || ' = ' || rec.dm_st_email;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_TP_AMB' || vv_aspas || ' = ' || rec.dm_tp_amb;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_CHAVE_NFE' || vv_aspas || ' = ' || '''' || rec.nro_chave_nfe || '''';
            --
            if nvl(rec.cNF_nfe,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'CNF_NFE' || vv_aspas || ' = ' || nvl(rec.cNF_nfe,0);
            end if;
            --
            if nvl(rec.dig_verif_chave,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'DIG_VERIF_CHAVE' || vv_aspas || ' = ' || nvl(rec.dig_verif_chave,0);
            end if;
            --
            if nvl(rec.dm_aut_sefaz,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'DM_AUT_SEFAZ' || vv_aspas || ' = ' || nvl(rec.dm_aut_sefaz,0);
            end if;
            --
            if rec.dt_aut_sefaz is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'DT_AUT_SEFAZ' || vv_aspas || ' = ' || '''' || to_char(rec.dt_aut_sefaz, vv_formato_dt_erp) || '''';
            end if;
            --
            if nvl(rec.nro_protocolo,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_PROTOCOLO' || vv_aspas || ' = ' || nvl(rec.nro_protocolo,0);
            end if;
            --
            if vd_dt_canc is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'DT_CANC' || vv_aspas || ' = ' || '''' || to_char(vd_dt_canc, vv_formato_dt_erp) || '''';
            end if;
            --
            if nvl(vn_nro_protocolo_canc,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_PROTOCOLO_CANC' || vv_aspas || ' = ' || nvl(vn_nro_protocolo_canc,0);
            end if;
            --
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_LEITURA' || vv_aspas || ' = 0';
            --
            if trim(vv_sistorig_sigla) is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'SIST_ORIG' || vv_aspas || ' = ' || '''' || trim(vv_sistorig_sigla) || '''';
            end if;
            --
            if trim(vv_unidorg_cd) is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'UNID_ORG' || vv_aspas || ' = ' || '''' || trim(vv_unidorg_cd) || '''';
            end if;
            --
            if nvl(vn_dm_ret_hr_aut,0) = 1 then
               --
               if rec.dt_aut_sefaz is not null then
                  gv_sql := gv_sql || ', ' || vv_aspas || 'HR_AUT_NFE' || vv_aspas || ' = ' || '''' || to_char(rec.dt_aut_sefaz, 'HH24:MI:SS') || '''';
               end if;
               --
               if vd_dt_canc is not null then
                  gv_sql := gv_sql || ', ' || vv_aspas || 'HR_AUT_CANC_NFE' || vv_aspas || ' = ' || '''' || to_char(vd_dt_canc, 'HH24:MI:SS') || '''';
               end if;
               --
            end if;
            --
            vv_sql_where := ' where ' || vv_aspas || 'NOTAFISCAL_ID' || vv_aspas || ' = ' || rec.notafiscal_id;
            --
            gv_sql := gv_sql || vv_sql_where;
            --
            vn_fase := 15;
            --
            begin
               --
               execute immediate ('select count(1) from ' || vv_obj || ' ' || vv_sql_where) into vn_qtde;
               --
            exception
               when others then
                  vn_qtde := 0;
            end;
            --
            --insert into erro values ( ('select count(1) from ' || vv_obj || ' ' || vv_sql_where) || ' vn_qtde: ' || vn_qtde); commit;
            --
            if nvl(vn_qtde,0) > 0 then
               --
               vn_erro := 0;
               --
               begin
                  --
                  execute immediate gv_sql;
                  --
               exception
                  when others then
                     --
                     vn_erro := 1;
                     --
                     -- A função replace está sendo utilizada para substituir uma aspas por duas, no comando executado,
                     -- pois esse log será registrado em outra tabela através de uma query dinâmica feita pelo procedimento
                     -- pkb_ret_infor_erro_nf_erp, e quando tem apenas uma aspas, ocorre o erro: ORA-00917: vírgula não encontrada
                     --
                     pk_csf_api_nfce.gv_mensagem_log := 'Erro na pkb_ret_infor_erp fase(' || vn_fase || ' ' || gv_sql || '):' || sqlerrm || ' - ' || replace (gv_sql, '''', '''''');
                     --
                     declare
                        vn_loggenerico_id  log_generico_nf.id%TYPE;
                     begin
                        --
                        pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                       , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                       , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                       , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                                       , en_referencia_id    => rec.notafiscal_id
                                                       , ev_obj_referencia   => 'NOTA_FISCAL' );
                        --
                     exception
                        when others then
                           null;
                     end;
                     --
               end;
               --
               vn_fase := 16;
               -- Executa procedimento de resposta FF
               pkb_int_ret_infor_erp_ff ( ev_cpf_cnpj_emit  => ev_cpf_cnpj_emit
                                        , en_dm_ind_emit    => rec.dm_ind_emit
                                        , en_dm_ind_oper    => rec.dm_ind_oper
                                        , ev_cod_part       => vv_cod_part
                                        , ev_cod_mod        => rec.cod_mod
                                        , ev_serie          => rec.serie
                                        , en_nro_nf         => rec.nro_nf
                                        , en_notafiscal_id  => rec.notafiscal_id
                                        , ev_owner_obj      => vv_owner_obj
                                        , ev_nome_dblink    => vv_nome_dblink
                                        , ev_aspas          => vv_aspas
                                        );
               --
               commit;
               --
               vn_fase := 17;
               --
               if nvl(vn_erro,0) = 0 then
                  --
                  pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  => rec.notafiscal_id
                                                 , en_dm_st_integra  => vn_dm_st_integra );
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => vn_dm_st_integra );
                  --
                  -- grava informações de log para o erp
                  pkb_ret_infor_erro_nf_erp ( en_notafiscal_id => rec.notafiscal_id
                                            , ev_obj           => 'VW_CSF_RESP_ERRO_NF_ERP' );
                  --
               end if;
               --
            else
               -- Informar retorno para o ERP, forçar nova inclusão
               pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                         , en_dm_st_integra  => 7 -- Inserir retorno do ERP
                                         );
               --
            end if;
            --
         else
            --
            vn_fase := 18;
            -- se a situação da NFe for 4-Autorizada, já alteração a integração para 9-Finalizado processo de View
            if nvl(vn_dm_st_proc_erp,0) = nvl(rec.dm_st_proc,0) then
               vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8) then 9 else 8 end;
            else
               vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8) then 9 else 7 end;
            end if;
            --
            --insert into erro values ('passo 2 notafiscal_id: ' || rec.notafiscal_id || ' vn_dm_st_proc_erp: ' || vn_dm_st_proc_erp || ' dm_st_proc: ' || rec.dm_st_proc || ' vn_dm_st_integra: ' || vn_dm_st_integra); commit;
            --
            pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  => rec.notafiscal_id
                                           , en_dm_st_integra  => vn_dm_st_integra );
            --
            pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                      , en_dm_st_integra  => vn_dm_st_integra );
            --
         end if;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ret_infor_erp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => vn_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ret_infor_erp;
--
-- ============================================================================================================================================= --
-- Procedimento retorna a informação para o ERP - NEO
procedure pkb_ret_infor_erp_neo ( ev_cpf_cnpj_emit in varchar2 ) is
   --
   vn_fase                  number := 0;
   vn_notafiscal_id         Nota_Fiscal.id%TYPE;
   vn_dm_st_integra         nota_fiscal.dm_st_integra%type;
   vn_dm_st_proc_erp        number(2) := null;
   vv_obj                   varchar2(4000) := null;
   vv_sql_where             varchar2(4000) := null;
   vn_qtde                  number := 0;
   vn_erro                  number := 0;
   vn_dm_ret_hr_aut         empresa.dm_ret_hr_aut%type := 0;
   vn_empresa_id            empresa.id%type;
   vv_cod_part              pessoa.cod_part%type;
   vv_sitdocto_cd           sit_docto.cd%type;
   vv_sistorig_sigla        sist_orig.sigla%type;
   vv_unidorg_cd            unid_org.cd%type;
   vd_dt_canc               nota_fiscal_canc.dt_hr_recbto%type;
   vn_nro_protocolo_canc    nota_fiscal_canc.nro_protocolo%type;
   vv_owner_obj             empresa_integr_banco.owner_obj%type;
   vv_nome_dblink           empresa_integr_banco.nome_dblink%type;
   vn_dm_util_aspa          empresa_integr_banco.dm_util_aspa%type;
   vn_dm_ret_infor_integr   empresa_integr_banco.dm_ret_infor_integr%type;
   vv_formato_dt_erp        empresa_integr_banco.formato_dt_erp%type;
   vn_dm_form_dt_erp        empresa_integr_banco.dm_form_dt_erp%type;
   vv_aspas                 char(1) := null;
   --
   -- Recupera as notas que foram inseridas na tabela de resposta do ERP
   cursor c_nf (en_empresa_id number) is
   select nf.empresa_id
        , nf.dm_ind_oper
        , nf.dm_ind_emit
        , nf.pessoa_id
        , mf.cod_mod
        , nf.serie
        , nf.nro_nf
        , nf.sitdocto_id
        , nf.dm_st_proc
        , nf.dt_st_proc
        , nf.dm_forma_emiss
        , nf.dm_impressa
        , nf.dm_st_email
        , nf.dm_tp_amb
        , nf.nro_chave_nfe
        , nf.cNF_nfe
        , nf.dig_verif_chave
        , nf.dm_aut_sefaz
        , nf.dt_aut_sefaz
        , nf.nro_protocolo
        , nf.id                 notafiscal_id
        , nf.dt_emiss
        , nf.dm_st_integra
        , nf.sistorig_id
        , nf.unidorg_id
        , nf.cod_msg
        , nfca.cod_msg cod_msg_canc
        , nf.empresaintegrbanco_id
        , nfc.id_erp  id_erp
        , nfca.id_erp id_erp_can
     from Nota_Fiscal           nf
        , mod_fiscal            mf
        , nota_fiscal_compl     nfc
        , nota_fiscal_canc      nfca
    where nf.empresa_id         = en_empresa_id
      and nf.dm_st_proc         > 3 -- Sempre maior que 3-Aguardando Retorno
      and nf.dm_ind_emit        = 0 -- emissão própria
      and nf.dm_st_integra      = 8 -- Aguardando retorno para o ERP
      and trunc(nf.DT_HR_ENT_SIST) > trunc(sysdate-30)
      and ( nf.cod_msg is null or nf.cod_msg not in ('204', '539', '290') )
      and mf.id                 = nf.modfiscal_id
      and mf.cod_mod            = '65'
      and nfc.notafiscal_id(+)  = nf.id
      and nfca.notafiscal_id(+) = nf.id
    order by nf.id;

begin
   -- Atualiza informações
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NF_ERP_NEO') = 0 then
      --
      return;
      --
   else
      -- Estando ATIVO veririca se o objeto antigo de integração tb está ativo e atualiza para DESATIVADO
      -- Manter somente uma view de resposta ativa
      if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NF_ERP') = 1 then
         --
         vn_fase := 1.1;
         --
         update obj_util_integr
            set dm_ativo = 0
          where obj_name in ('VW_CSF_RESP_NF_ERP', 'VW_CSF_RESP_NF_ERP_FF');
         --
      end if;
      --
   end if;
   --
   vn_fase := 2;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_cpf_cnpj ( en_multorg_id => gn_multorg_id
                                                   , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 3;
   --
   for rec in c_nf(vn_empresa_id) loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 4;
      --
      if nvl(rec.empresaintegrbanco_id,0) > 0
         and nvl(rec.empresaintegrbanco_id,0) <> nvl(gn_empresaintegrbanco_id,0)
         then
         --
         vn_fase := 5;
         --
         begin
            --
            select ei.owner_obj
                 , ei.nome_dblink
                 , ei.dm_util_aspa
                 , ei.dm_ret_infor_integr
                 , ei.formato_dt_erp
                 , ei.dm_form_dt_erp
              into vv_owner_obj
                 , vv_nome_dblink
                 , vn_dm_util_aspa
                 , vn_dm_ret_infor_integr
                 , vv_formato_dt_erp
                 , vn_dm_form_dt_erp
              from empresa_integr_banco ei
             where ei.id = rec.empresaintegrbanco_id;
            --
         exception
            when others then
               null;
         end;
         --
         if nvl(vn_dm_form_dt_erp,0) = 0
            or trim(vv_formato_dt_erp) is null then
            --
            vv_formato_dt_erp := gv_formato_data;
            --
         end if;
         --
         if nvl(vn_dm_util_aspa,0) = 1 then
            --
            vv_aspas := '"';
            --
         end if;
         --
         vn_fase := 6;
         --
      else
         --
         vn_fase := 7;
         --
         vv_owner_obj           := GV_OWNER_OBJ;
         vv_nome_dblink         := GV_NOME_DBLINK;
         vv_aspas               := GV_ASPAS;
         vn_dm_ret_infor_integr := GN_DM_RET_INFOR_INTEGR;
         vv_formato_dt_erp      := GD_FORMATO_DT_ERP;
         --
      end if;
      --
      vn_fase := 8;
      --
      vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NF_ERP_NEO'
                                     , ev_aspas       => vv_aspas
                                     , ev_owner_obj   => vv_owner_obj
                                     , ev_nome_dblink => vv_nome_dblink
                                     );
      --
      vn_fase := 9;
      --
      if nvl(vn_dm_ret_infor_integr,0) = 1 then
         --
         vn_fase := 9.1;
         --
         vn_dm_ret_hr_aut := pk_csf.fkg_ret_hr_aut_empresa_id ( en_empresa_id => vn_empresa_id );
         --
         vn_fase := 9.2;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
         --
         if trim(vv_cod_part) is null then
            vv_cod_part := trim(ev_cpf_cnpj_emit);
         end if;
         --
         vn_fase := 9.3;
         --
         vv_sitdocto_cd := pk_csf.fkg_Sit_Docto_cd ( en_sitdoc_id => rec.sitdocto_id );
         --
         vn_fase := 9.4;
         --
         vv_sistorig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec.sistorig_id );
         --
         vn_fase := 9.5;
         --
         vv_unidorg_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec.unidorg_id );
         --
         vn_fase := 9.6;
         --
         begin
            --
            select nfc.dt_hr_recbto
                 , nfc.nro_protocolo
              into vd_dt_canc
                 , vn_nro_protocolo_canc
              from nota_fiscal_canc nfc
             where nfc.notafiscal_id = rec.notafiscal_id;
            --
         exception
            when others then
               vd_dt_canc            := null;
               vn_nro_protocolo_canc := null;
         end;
         --
         vn_fase := 10;
         --
         vn_dm_st_proc_erp := fkg_ret_dm_st_proc_erp ( ev_cpf_cnpj_emit   => ev_cpf_cnpj_emit
                                                     , en_dm_ind_emit     => rec.dm_ind_emit
                                                     , en_dm_ind_oper     => rec.dm_ind_oper
                                                     , ev_cod_part        => vv_cod_part
                                                     , ev_cod_mod         => rec.cod_mod
                                                     , ev_serie           => rec.serie
                                                     , en_nro_nf          => rec.nro_nf
                                                     , en_notafiscal_id   => rec.notafiscal_id
                                                     , ev_obj             => vv_obj
                                                     , ev_aspas           => vv_aspas
                                                     , ev_obj_name        => 'VW_CSF_RESP_NF_ERP_NEO'
                                                     );
         --
         vn_fase := 11;
         -- Verifica se a situação da NFe no ERP é diferente de zero e diferetente da Situação da NFe no Compliance
         if nvl(vn_dm_st_proc_erp,0) not in (0, -1)
            and nvl(vn_dm_st_proc_erp,0) <> nvl(rec.dm_st_proc,0) then
            --
            vn_fase := 12;
            --
            vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8) then 9 else 8 end;
            --
            vn_fase := 13;
            -- Inicia montagem do update de atualização da resposta do ERP
            gv_sql := 'update ';
            --
            vn_fase := 14;
            --
            gv_sql := gv_sql || vv_obj || ' set ' || vv_aspas || 'SIT_DOCTO' || vv_aspas || ' = ' || '''' || case when rec.DM_ST_PROC = 7 then '02' when rec.DM_ST_PROC = 6 then '04' when rec.DM_ST_PROC = 8 then '05' else trim(vv_sitdocto_cd) end || '''';
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_ST_PROC'             || vv_aspas || ' = ' || rec.dm_st_proc;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_ST_PROC'             || vv_aspas || ' = ' || '''' || to_char(rec.dt_st_proc, vv_formato_dt_erp ) || '''';
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_EMISS'               || vv_aspas || ' = ' || '''' || to_char(rec.dt_emiss, vv_formato_dt_erp ) || '''';
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_FORMA_EMISS'         || vv_aspas || ' = ' || rec.dm_forma_emiss;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_IMPRESSA'            || vv_aspas || ' = ' || rec.dm_impressa;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_ST_EMAIL'            || vv_aspas || ' = ' || rec.dm_st_email;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_TP_AMB'              || vv_aspas || ' = ' || rec.dm_tp_amb;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_CHAVE_NFE'          || vv_aspas || ' = ' || '''' || rec.nro_chave_nfe || '''';
            --
            if nvl(rec.cNF_nfe,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'CNF_NFE'         || vv_aspas || ' = ' || nvl(rec.cNF_nfe,0);
            end if;
            --
            if nvl(rec.dig_verif_chave,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'DIG_VERIF_CHAVE' || vv_aspas || ' = ' || nvl(rec.dig_verif_chave,0);
            end if;
            --
            if nvl(rec.dm_aut_sefaz,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'DM_AUT_SEFAZ'    || vv_aspas || ' = ' || nvl(rec.dm_aut_sefaz,0);
            end if;
            --
            if rec.dt_aut_sefaz is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'DT_AUT_SEFAZ'    || vv_aspas || ' = ' || '''' || to_char(rec.dt_aut_sefaz, vv_formato_dt_erp) || '''';
            end if;
            --
            if nvl(rec.nro_protocolo,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_PROTOCOLO'   || vv_aspas || ' = ' || nvl(rec.nro_protocolo,0);
            end if;
            --
            if vd_dt_canc is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'DT_CANC'         || vv_aspas || ' = ' || '''' || to_char(vd_dt_canc, vv_formato_dt_erp) || '''';
            end if;
            --
            if nvl(vn_nro_protocolo_canc,0) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_PROTOCOLO_CANC' || vv_aspas || ' = ' || nvl(vn_nro_protocolo_canc,0);
            end if;
            --
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_LEITURA' || vv_aspas || ' = 0';
            --
            if trim(vv_sistorig_sigla) is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'SIST_ORIG' || vv_aspas || ' = ' || '''' || trim(vv_sistorig_sigla) || '''';
            end if;
            --
            if trim(vv_unidorg_cd) is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'UNID_ORG' || vv_aspas || ' = ' || '''' || trim(vv_unidorg_cd) || '''';
            end if;
            --
            if nvl(vn_dm_ret_hr_aut,0) = 1 then
               --
               if rec.dt_aut_sefaz is not null then
                  gv_sql := gv_sql || ', ' || vv_aspas || 'HR_AUT_NFE' || vv_aspas || ' = ' || '''' || to_char(rec.dt_aut_sefaz, 'HH24:MI:SS') || '''';
               end if;
               --
               if vd_dt_canc is not null then
                  gv_sql := gv_sql || ', ' || vv_aspas || 'HR_AUT_CANC_NFE' || vv_aspas || ' = ' || '''' || to_char(vd_dt_canc, 'HH24:MI:SS') || '''';
               end if;
               --
            end if;
            --
            if rec.cod_msg_canc is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'COD_MSG' || vv_aspas || ' = ' || rec.cod_msg_canc;
            elsif rec.cod_msg is not null then
               gv_sql := gv_sql || ', ' || vv_aspas || 'COD_MSG' || vv_aspas || ' = ' || rec.cod_msg;
            end if;
            --
            if nvl(rec.id_erp, rec.id_erp_can) > 0 then
               gv_sql := gv_sql || ', ' || vv_aspas || 'ID_ERP'  || vv_aspas || ' = ' || nvl(rec.id_erp, rec.id_erp_can);
            end if;
            --
            vn_fase := 15;
            --
            vv_sql_where := ' where ' || vv_aspas || 'NOTAFISCAL_ID' || vv_aspas || ' = ' || rec.notafiscal_id;
            --
            gv_sql := gv_sql || vv_sql_where;
            --
            begin
               --
               vn_fase := 16;
               --
               execute immediate ('select count(1) from ' || vv_obj || ' ' || vv_sql_where) into vn_qtde;
               --
            exception
               when others then
                  vn_qtde := 0;
            end;
            --
            vn_fase := 17;
            --
            if nvl(vn_qtde,0) > 0 then
               --
               vn_erro := 0;
               --
               begin
                  --
                  vn_fase := 18;
                  --
                  execute immediate gv_sql;
                  --
               exception
                  when others then
                     --
                     vn_erro := 1;
                     --
                     -- A função replace está sendo utilizada para substituir uma aspas por duas, no comando executado,
                     -- pois esse log será registrado em outra tabela através de uma query dinâmica feita pelo procedimento
                     -- pkb_ret_infor_erro_nf_erp, e quando tem apenas uma aspas, ocorre o erro: ORA-00917: vírgula não encontrada
                     --
                     pk_csf_api_nfce.gv_mensagem_log := 'Erro na pkb_ret_infor_erp_neo fase(' || vn_fase || ' ' || gv_sql || '):' || sqlerrm || ' - ' || replace (gv_sql, '''', '''''');
                     --
                     declare
                        vn_loggenerico_id  log_generico_nf.id%TYPE;
                     begin
                        --
                        pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                       , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                       , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                       , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                                       , en_referencia_id    => rec.notafiscal_id
                                                       , ev_obj_referencia   => 'NOTA_FISCAL' );
                        --
                     exception
                        when others then
                           null;
                     end;
                     --
               end;
               --
               -- Não tem procedimento de resposta FF
               --
               commit;
               --
               vn_fase := 19;
               --
               if nvl(vn_erro,0) = 0 then
                  --
                  pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  => rec.notafiscal_id
                                                 , en_dm_st_integra  => vn_dm_st_integra );
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => vn_dm_st_integra );
                  --
                  -- grava informações de log para o erp
                  pkb_ret_infor_erro_nf_erp ( en_notafiscal_id => rec.notafiscal_id
                                            , ev_obj           => 'VW_CSF_RESP_ERRO_NF_ERP' );
                  --
               end if;
               --
            else
               -- Informar retorno para o ERP, forçar nova inclusão
               pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                         , en_dm_st_integra  => 7 -- Inserir retorno do ERP
                                         );
               --
            end if;
            --
         else
            --
            vn_fase := 18;
            -- se a situação da NFe for 4-Autorizada, já alteração a integração para 9-Finalizado processo de View
            if nvl(vn_dm_st_proc_erp,0) = nvl(rec.dm_st_proc,0) then
               vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8) then 9 else 8 end;
            else
               vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8) then 9 else 7 end;
            end if;
            --
            vn_fase := 19;
            --
            pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  => rec.notafiscal_id
                                           , en_dm_st_integra  => vn_dm_st_integra );
            --
            pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                      , en_dm_st_integra  => vn_dm_st_integra );
            --
         end if;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ret_infor_erp_neo fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => vn_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ret_infor_erp_neo;
--
-- ============================================================================================================================================= --
-- Procedimento que retorna a consulta para o ERP
procedure pkb_ret_cons_erp ( en_empresa_id in empresa.id%type ) is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14);
   vv_obj           varchar2(100);
   vn_erro          number;
   --
   cursor c_ret_cons_chnfe is
      select ccs.id
           , ccs.chnfe
           , ccs.dm_situacao
           , ccs.cstat
           , ccs.xmotivo
           , ccs.dhrecbto
           , ccs.nprot
           , ccs.empresa_id
        from csf_cons_sit ccs
       where ccs.empresa_id     = en_empresa_id
         --and ccs.dm_situacao   <> 1 -- 1-Consulta Pendente, 2-Autorizado o uso da NF-e (100), 3-Cancelamento da NF-e Homologado (101), 4-Uso denegado (110), 5-Erro ao consultar, 6-NFe inexistente
         and ccs.dm_st_integra in (7,8)
         and ccs.dm_integr_erp  = 0
       order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CONS_CHAVE_NFE') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => en_empresa_id );
   --
   for rec in c_ret_cons_chnfe loop
      exit when c_ret_cons_chnfe%notfound or (c_ret_cons_chnfe%notfound) is null;
      --
      -- Monta Update
      --
      if GV_NOME_DBLINK is not null then
         --
         vv_obj := GV_ASPAS || 'VW_CSF_CONS_CHAVE_NFE' || GV_ASPAS || '@' || GV_NOME_DBLINK;
         --
      else
         --
         vv_obj := GV_ASPAS || 'VW_CSF_CONS_CHAVE_NFE' || GV_ASPAS;
         --
      end if;
      --
      vn_fase := 3;
      --
      if trim(GV_OWNER_OBJ) is not null then
         vv_obj := trim(GV_OWNER_OBJ) || '.' || vv_obj;
      else
         vv_obj := vv_obj;
      end if;
      --
      vn_fase := 3.1;
      --
      gv_sql := 'update ' || vv_obj || ' set ';
      --
      gv_sql := gv_sql || GV_ASPAS || 'DM_SITUACAO' || GV_ASPAS || ' = ' || rec.dm_situacao;
      --
      vn_fase := 3.2;
      --
      if trim(rec.cstat) is not null then
         gv_sql := gv_sql || ', ' || GV_ASPAS || 'CSTAT' || GV_ASPAS || ' = ' || '''' || trim(rec.cstat) || '''';
      end if;
      --
      vn_fase := 3.3;
      --
      if trim(rec.xmotivo) is not null then
         gv_sql := gv_sql || ', ' || GV_ASPAS || 'XMOTIVO' || GV_ASPAS || ' = ' || '''' || trim(rec.xmotivo) || '''';
      end if;
      --
      vn_fase := 3.4;
      --
      if rec.dhrecbto is not null then
         gv_sql := gv_sql || ', ' || GV_ASPAS || 'DHRECBTO' || GV_ASPAS || ' = ' || '''' || to_char(trunc(nvl(rec.dhrecbto, sysdate)), gd_formato_dt_erp) || '''';
      end if;
      --
      vn_fase := 3.5;
      --
      if rec.nprot is not null then
         gv_sql := gv_sql || ', ' || GV_ASPAS || 'NPROT' || GV_ASPAS || ' = ' || '''' || trim(rec.nprot) || '''';
      end if;
      --
      gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_LEITURA' || GV_ASPAS || ' = 0';
      --
      vn_fase := 3.6;
      --
      gv_sql := gv_sql || ' where ';
      gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || vv_cpf_cnpj_emit || '''';
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_CHAVE_NFE' || GV_ASPAS || ' = ' || '''' || rec.chnfe || '''';
      --
      vn_fase := 4;
      --
      vn_erro := 0;
      --
      begin
         --
         execute immediate gv_sql;
         --
      exception
         when others then
            --
            vn_erro := 1;
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ret_cons_erp fase(' || vn_fase || ' ' || gv_sql || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'CSF_CONS_SIT' );
               --
            exception
               when others then
                  null;
            end;
            --
      end;
      --
      commit;
      --
      if vn_erro = 0 then
         --
         vn_fase := 5;
         --
         if rec.dm_situacao = 1 then
            --
            -- Chama rotina que atualiza a tabela csf_cons_sit
            pk_csf_api_cons_sit.gt_row_csf_cons_sit               := null;
            pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id    := rec.empresa_id;
            pk_csf_api_cons_sit.gt_row_csf_cons_sit.id            := rec.id;
            pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_st_integra := 8;
            --
            pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                         , ev_campo_atu         => 'dm_st_integra'
                                                         , en_tp_rotina         => 0 -- atualização
                                                         , ev_rotina_orig       => 'pk_integr_view_nfce.pkb_ret_cons_erp'
                                                         );
            --
         else
            --
            -- Chama rotina que atualiza a tabela csf_cons_sit
            pk_csf_api_cons_sit.gt_row_csf_cons_sit               := null;
            pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id    := rec.empresa_id;
            pk_csf_api_cons_sit.gt_row_csf_cons_sit.id            := rec.id;
            pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_st_integra := 9;
            pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_integr_erp := 1;
            --
            pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                         , ev_campo_atu         => 'dm_st_integra'
                                                         , en_tp_rotina         => 0 -- atualização
                                                         , ev_rotina_orig       => 'pk_integr_view_nfce.pkb_ret_cons_erp'
                                                         );
            --
            pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                         , ev_campo_atu         => 'dm_integr_erp'
                                                         , en_tp_rotina         => 0 -- atualização
                                                         , ev_rotina_orig       => 'pk_integr_view_nfce.pkb_ret_cons_erp'
                                                         );
            --
         end if;
         --
         commit;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
   --
    pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ret_cons_erp fase(' || vn_fase || '):' || sqlerrm;
    --
    declare
       vn_loggenerico_id  log_generico_nf.id%TYPE;
    begin
       --
       pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                      , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                      , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                      , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                      , en_referencia_id    => null
                                      , ev_obj_referencia   => 'CSF_CONS_SIT'
                                      );
       --
    exception
       when others then
          null;
    end;
   --
end pkb_ret_cons_erp;
--
-- ============================================================================================================================================= --
-- Procedimento integra informações no ERP
procedure pkb_int_infor_erp ( ev_cpf_cnpj_emit  in  varchar2
                            , en_notafiscal_id  in  nota_fiscal.id%type default 0 ) is
   --
   PRAGMA AUTONOMOUS_TRANSACTION;
   --
   vn_fase                  number := 0;
   vn_notafiscal_id         Nota_Fiscal.id%TYPE;
   vn_dm_st_proc_erp        nota_fiscal.DM_ST_PROC%type;
   vv_obj                   varchar2(4000) := null;
   vn_erro                  number := 0;
   vn_dm_ret_hr_aut         empresa.dm_ret_hr_aut%type := 0;
   vn_empresa_id            empresa.id%type := null;
   vv_cpf_cnpj              varchar2(14);
   --
   vv_cod_part              pessoa.cod_part%type;
   vv_sitdocto_cd           sit_docto.cd%type;
   vv_sistorig_sigla        sist_orig.sigla%type;
   vv_unidorg_cd            unid_org.cd%type;
   vd_dt_canc               nota_fiscal_canc.dt_hr_recbto%type;
   vn_nro_protocolo_canc    nota_fiscal_canc.nro_protocolo%type;
   --
   vv_owner_obj             empresa_integr_banco.owner_obj%type;
   vv_nome_dblink           empresa_integr_banco.nome_dblink%type;
   vn_dm_util_aspa          empresa_integr_banco.dm_util_aspa%type;
   vn_dm_ret_infor_integr   empresa_integr_banco.dm_ret_infor_integr%type;
   vv_formato_dt_erp        empresa_integr_banco.formato_dt_erp%type;
   vn_dm_form_dt_erp        empresa_integr_banco.dm_form_dt_erp%type;
   vv_aspas                 char(1) := null;
   --
   cursor c_nf (en_empresa_id number) is
   select nf.empresa_id
        , nf.dm_ind_oper
        , nf.dm_ind_emit
        , nf.pessoa_id
        , mf.cod_mod
        , nf.serie
        , nf.nro_nf
        , nf.sitdocto_id
        , nf.dm_st_proc
        , nf.dt_st_proc
        , nf.dm_forma_emiss
        , nf.dm_impressa
        , nf.dm_st_email
        , nf.dm_tp_amb
        , nf.nro_chave_nfe
        , nf.cNF_nfe
        , nf.dig_verif_chave
        , nf.dm_aut_sefaz
        , nf.dt_aut_sefaz
        , nf.nro_protocolo
        , nf.id                 notafiscal_id
        , nf.dt_emiss
        , nf.dm_st_integra
        , nf.sistorig_id
        , nf.unidorg_id
        , nf.cod_msg
        , nf.empresaintegrbanco_id
     from Nota_Fiscal           nf
        , mod_fiscal            mf
    where nf.empresa_id         = en_empresa_id
      and nf.dm_st_proc         <> 0
      and nf.dm_ind_emit        = 0
      and nf.dm_st_integra      = 7
      and ( nf.cod_msg is null or nf.cod_msg not in ('204', '539', '290') )
      and mf.id                 = nf.modfiscal_id
      and mf.cod_mod            ='65' -- somente modelo 65
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NF_ERP') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_cpf_cnpj ( en_multorg_id => gn_multorg_id
                                                   , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 3;
   --
   for rec in c_nf(vn_empresa_id) loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 4;
      --
      if nvl(rec.empresaintegrbanco_id,0) > 0
         and nvl(rec.empresaintegrbanco_id,0) <> nvl(gn_empresaintegrbanco_id,0)
         then
         --
         vn_fase := 5;
         --
         begin
            --
            select ei.owner_obj
                 , ei.nome_dblink
                 , ei.dm_util_aspa
                 , ei.dm_ret_infor_integr
                 , ei.formato_dt_erp
                 , ei.dm_form_dt_erp
              into vv_owner_obj
                 , vv_nome_dblink
                 , vn_dm_util_aspa
                 , vn_dm_ret_infor_integr
                 , vv_formato_dt_erp
                 , vn_dm_form_dt_erp
              from empresa_integr_banco ei
             where ei.id = rec.empresaintegrbanco_id;
            --
         exception
            when others then
               null;
         end;
         --
         vn_fase := 6;
         --
         if nvl(vn_dm_form_dt_erp,0) = 0
            or trim(vv_formato_dt_erp) is null then
            --
            vv_formato_dt_erp := gv_formato_data;
            --
         end if;
         --
         vn_fase := 7;
         --
         if nvl(vn_dm_util_aspa,0) = 1 then
            --
            vv_aspas := '"';
            --
         end if;
         --
      else
         --
         vn_fase := 8;
         --
         vv_owner_obj           := GV_OWNER_OBJ;
         vv_nome_dblink         := GV_NOME_DBLINK;
         vv_aspas               := GV_ASPAS;
         vn_dm_ret_infor_integr := GN_DM_RET_INFOR_INTEGR;
         vv_formato_dt_erp      := GD_FORMATO_DT_ERP;
         --
      end if;
      --
      vn_fase := 9;
      --
      vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NF_ERP'
                                     , ev_aspas       => vv_aspas
                                     , ev_owner_obj   => vv_owner_obj
                                     , ev_nome_dblink => vv_nome_dblink
                                     );
      --
      vn_fase := 10;
      --
      if nvl(vn_dm_ret_infor_integr,0) = 1 then
         --
         vn_fase := 10.1;
         --
         vn_empresa_id := rec.empresa_id;
         --
         vv_cpf_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
         --
         vn_fase := 10.2;
         --
         vn_dm_ret_hr_aut := pk_csf.fkg_ret_hr_aut_empresa_id ( en_empresa_id => vn_empresa_id );
         --
         vn_fase := 10.3;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
         --
         if trim(vv_cod_part) is null then
            vv_cod_part := ev_cpf_cnpj_emit;
         end if;
         --
         vn_fase := 10.4;
         --
         vv_sitdocto_cd := pk_csf.fkg_Sit_Docto_cd ( en_sitdoc_id => rec.sitdocto_id );
         --
         vn_fase := 10.5;
         --
         vv_sistorig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec.sistorig_id );
         --
         vn_fase := 10.6;
         --
         vv_unidorg_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec.unidorg_id );
         --
         vn_fase := 10.7;
         --
         begin
            --
            select nfc.dt_hr_recbto
                 , nfc.nro_protocolo
              into vd_dt_canc
                 , vn_nro_protocolo_canc
              from nota_fiscal_canc nfc
             where nfc.notafiscal_id = rec.notafiscal_id;
            --
         exception
            when others then
               vd_dt_canc            := null;
               vn_nro_protocolo_canc := null;
         end;
         --
         vn_fase := 11;
         --
         pkb_excluir_nf ( ev_cpf_cnpj_emit          => vv_cpf_cnpj
                        , en_dm_ind_emit            => rec.DM_IND_EMIT
                        , en_dm_ind_oper            => rec.DM_IND_OPER
                        , ev_cod_part               => vv_cod_part
                        , ev_cod_mod                => rec.COD_MOD
                        , ev_serie                  => rec.SERIE
                        , en_nro_nf                 => rec.NRO_NF
                        , en_notafiscal_id          => rec.notafiscal_id
                        , ev_obj                    => vv_obj
                        , ev_aspas                  => vv_aspas
                        );
         --
         vn_fase := 12;
         --| Verifica se existe
         vn_dm_st_proc_erp := fkg_ret_dm_st_proc_erp ( ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                                                     , en_dm_ind_emit            => rec.dm_ind_emit
                                                     , en_dm_ind_oper            => rec.dm_ind_oper
                                                     , ev_cod_part               => vv_cod_part
                                                     , ev_cod_mod                => rec.cod_mod
                                                     , ev_serie                  => rec.serie
                                                     , en_nro_nf                 => rec.nro_nf
                                                     , en_notafiscal_id          => rec.notafiscal_id
                                                     , ev_obj                    => vv_obj
                                                     , ev_aspas                  => vv_aspas
                                                     , ev_obj_name               => 'VW_CSF_RESP_NF_ERP'
                                                     );
         --
         vn_fase := 13;
         --insert into erro values ( 'notafiscal_id: ' || rec.notafiscal_id || ' vn_dm_st_proc_erp: ' || vn_dm_st_proc_erp); commit;
         -- Se não encontrou informa o registro
         if nvl(vn_dm_st_proc_erp,-1) = -1 then
            --
            vn_fase := 14;
            --
            vn_notafiscal_id := rec.notafiscal_id;
            --
            gv_sql := 'insert into ';
            --
            vn_fase := 15;
            --
            gv_sql := gv_sql || vv_obj || '(';
            --
            gv_sql := gv_sql || vv_aspas || 'CPF_CNPJ_EMIT' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_IND_OPER' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_IND_EMIT' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'COD_PART' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'COD_MOD' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'SERIE' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_NF' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'SIT_DOCTO' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_ST_PROC' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_ST_PROC' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_FORMA_EMISS' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_IMPRESSA' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_ST_EMAIL' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_TP_AMB' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_CHAVE_NFE' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'CNF_NFE' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DIG_VERIF_CHAVE' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_AUT_SEFAZ' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_AUT_SEFAZ' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_PROTOCOLO' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_CANC' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_PROTOCOLO_CANC' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NOTAFISCAL_ID' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_EMISS' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_LEITURA' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'SIST_ORIG' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'UNID_ORG' || vv_aspas;
            --
            vn_fase := 16;
            --
            if nvl(vn_dm_ret_hr_aut,0) = 1 then -- Retorna informação da hora de Autorização/Cancelamento para o ERP
               --
               gv_sql := gv_sql || ', ' || vv_aspas || 'HR_AUT_NFE' || vv_aspas;
               gv_sql := gv_sql || ', ' || vv_aspas || 'HR_AUT_CANC_NFE' || vv_aspas;
               --
            end if;
            --
            gv_sql := gv_sql || ') values (';
            --
            gv_sql := gv_sql || '''' || ev_cpf_cnpj_emit || '''';
            gv_sql := gv_sql || ', ' || rec.DM_IND_OPER;
            gv_sql := gv_sql || ', ' || rec.DM_IND_EMIT;
            --
            gv_sql := gv_sql || ', ' || case when trim(vv_cod_part) is not null then '''' || trim(vv_cod_part) || '''' else '''' || ev_cpf_cnpj_emit || '''' end;
            --
            gv_sql := gv_sql || ', ' || '''' || rec.COD_MOD || '''';
            gv_sql := gv_sql || ', ' || '''' || rec.SERIE || '''';
            gv_sql := gv_sql || ', ' || rec.NRO_NF;
            gv_sql := gv_sql || ', ' || '''' || case when rec.DM_ST_PROC = 7 then '02' when rec.DM_ST_PROC = 6 then '04' when rec.DM_ST_PROC = 8 then '05' else trim(vv_sitdocto_cd) end || '''';
            gv_sql := gv_sql || ', ' || case when rec.DM_ST_PROC = 0 then 1 else rec.DM_ST_PROC end;
            gv_sql := gv_sql || ', ' || '''' || to_char(rec.DT_ST_PROC, vv_formato_dt_erp )  || '''';
            gv_sql := gv_sql || ', ' || rec.DM_FORMA_EMISS;
            gv_sql := gv_sql || ', ' || rec.DM_IMPRESSA;
            gv_sql := gv_sql || ', ' || rec.DM_ST_EMAIL;
            gv_sql := gv_sql || ', ' || rec.DM_TP_AMB;
            gv_sql := gv_sql || ', ' || '''' || rec.NRO_CHAVE_NFE || '''';
            --
            vn_fase := 17;
            --
            gv_sql := gv_sql || ', ' || nvl(rec.CNF_NFE,0);
            --
            vn_fase := 18;
            --
            gv_sql := gv_sql || ', ' || nvl(rec.DIG_VERIF_CHAVE,0);
            --
            vn_fase := 19;
            --
            gv_sql := gv_sql || ', ' || nvl(rec.DM_AUT_SEFAZ,0);
            --
            vn_fase := 20;
            --
            if rec.DT_AUT_SEFAZ is not null then
               gv_sql := gv_sql || ', ' || '''' || to_char(rec.DT_AUT_SEFAZ, vv_formato_dt_erp ) || '''';
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 21;
            --
            gv_sql := gv_sql || ', ' || nvl(rec.NRO_PROTOCOLO,0);
            --
            vn_fase := 22;
            --
            if vd_dt_canc is not null then
               gv_sql := gv_sql || ', ' || '''' || to_char(vd_dt_canc, vv_formato_dt_erp ) || '''';
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 23;
            --
            gv_sql := gv_sql || ', ' || nvl(vn_nro_protocolo_canc,0);
            --
            vn_fase := 24;
            --
            gv_sql := gv_sql || ', ' || rec.NOTAFISCAL_ID;
            --
            vn_fase := 25;
            --
            if rec.dt_emiss is not null then
               gv_sql := gv_sql || ', ' || '''' || to_char(rec.dt_emiss, vv_formato_dt_erp) || '''';
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 26;
            --
            gv_sql := gv_sql || ', 0'; -- DM_LEITURA
            --
            gv_sql := gv_sql || ', ' ||  case when trim(vv_sistorig_sigla) is null then '''' || ' ' || '''' else '''' || trim(vv_sistorig_sigla) || '''' end;
            --
            gv_sql := gv_sql || ', ' ||  case when trim(vv_unidorg_cd) is null then '''' || ' ' || '''' else '''' || trim(vv_unidorg_cd) || '''' end;
            --
            vn_fase := 27;
            --
            if nvl(vn_dm_ret_hr_aut,0) = 1 then -- Retorna informação da hora de Autorização/Cancelamento para o ERP
               --
               if rec.DT_AUT_SEFAZ is not null then
                  gv_sql := gv_sql || ', ' || '''' || to_char(rec.DT_AUT_SEFAZ, 'HH24:MI:SS' ) || '''';
               else
                  gv_sql := gv_sql || ', null';
               end if;
               --
               if vd_dt_canc is not null then
                  gv_sql := gv_sql || ', ' || '''' || to_char(vd_dt_canc, 'HH24:MI:SS' ) || '''';
               else
                  gv_sql := gv_sql || ', null';
               end if;
               --
            end if;
            --
            gv_sql := gv_sql || ')';
            --
            vn_fase := 28;
            --
            vn_erro := 0;
            --
            begin
               --
               execute immediate gv_sql;
               --
            exception
               when others then
                  --
                  vn_erro := 1;
                  --
                  -- A função replace está sendo utilizada para substituir uma aspas por duas, no comando executado,
                  -- pois esse log será registrado em outra tabela através de uma query dinâmica feita pelo procedimento
                  -- pkb_ret_infor_erro_nf_erp, e quando tem apenas uma aspas, ocorre o erro: ORA-00917: vírgula não encontrada
                  --
                  pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_infor_erp fase(' || vn_fase || '):' || sqlerrm || ' - ' || replace (gv_sql, '''', '''''');
                  --
                  declare
                     vn_loggenerico_id  log_generico_nf.id%TYPE;
                  begin
                     --
                     pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                    , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                    , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                    , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                                    , en_referencia_id    => rec.NOTAFISCAL_ID
                                                    , ev_obj_referencia   => 'NOTA_FISCAL' );
                     --
                  exception
                     when others then
                        null;
                  end;
                  --
            end;
            --
            commit;
            --
            vn_fase := 29;
            --
            begin
               -- grava informações de erro para o erp
               pkb_ret_infor_erro_nf_erp ( en_notafiscal_id => rec.notafiscal_id
                                         , ev_obj           => 'VW_CSF_RESP_ERRO_NF_ERP' );
               --
            exception
               when others then
                  vn_erro := 1;
            end;
            --
            if nvl(vn_erro,0) = 0 then
               --
               vn_fase := 30;
               --
               if rec.DM_ST_PROC not in (4, 6, 7, 8) then
                  --
                  vn_fase := 31;
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => 8 );
                  --
               else
                  --
                  vn_fase := 32;
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => 9 );
                  --
               end if;
               --
            end if;
            --
         else
            --
            vn_fase := 33;
            --
            pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                      , en_dm_st_integra  => 8 );
            --
         end if;
         --
         vn_fase := 34;
         -- Executa procedimento de resposta FF
         pkb_int_ret_infor_erp_ff ( ev_cpf_cnpj_emit  => ev_cpf_cnpj_emit
                                  , en_dm_ind_emit    => rec.dm_ind_emit
                                  , en_dm_ind_oper    => rec.dm_ind_oper
                                  , ev_cod_part       => vv_cod_part
                                  , ev_cod_mod        => rec.cod_mod
                                  , ev_serie          => rec.serie
                                  , en_nro_nf         => rec.nro_nf
                                  , en_notafiscal_id  => rec.notafiscal_id
                                  , ev_owner_obj      => vv_owner_obj
                                  , ev_nome_dblink    => vv_nome_dblink
                                  , ev_aspas          => vv_aspas
                                  );
         --
         vn_fase := 35;
         --
         commit;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_infor_erp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => vn_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_infor_erp;
--
-- ============================================================================================================================================= --
-- Procedimento integra informações no ERP - NEO
procedure pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit  in  varchar2
                                , en_notafiscal_id  in  nota_fiscal.id%type default 0 ) is
   --
   PRAGMA AUTONOMOUS_TRANSACTION;
   --
   vn_fase                  number                     := 0;
   vn_notafiscal_id         Nota_Fiscal.id%TYPE;
   vn_dm_st_proc_erp        nota_fiscal.DM_ST_PROC%type;
   vv_obj                   varchar2(4000)             := null;
   vn_erro                  number                     := 0;
   vn_dm_ret_hr_aut         empresa.dm_ret_hr_aut%type := 0;
   vn_empresa_id            empresa.id%type            := null;
   vv_cpf_cnpj              varchar2(14);
   --
   vv_cod_part              pessoa.cod_part%type;
   vv_sitdocto_cd           sit_docto.cd%type;
   vv_sistorig_sigla        sist_orig.sigla%type;
   vv_unidorg_cd            unid_org.cd%type;
   vd_dt_canc               nota_fiscal_canc.dt_hr_recbto%type;
   vn_nro_protocolo_canc    nota_fiscal_canc.nro_protocolo%type;
   --
   vv_owner_obj             empresa_integr_banco.owner_obj%type;
   vv_nome_dblink           empresa_integr_banco.nome_dblink%type;
   vn_dm_util_aspa          empresa_integr_banco.dm_util_aspa%type;
   vn_dm_ret_infor_integr   empresa_integr_banco.dm_ret_infor_integr%type;
   vv_formato_dt_erp        empresa_integr_banco.formato_dt_erp%type;
   vn_dm_form_dt_erp        empresa_integr_banco.dm_form_dt_erp%type;
   vv_aspas                 char(1)                    := null;
   --
   cursor c_nf (en_empresa_id number) is
   select nf.empresa_id
        , nf.dm_ind_oper
        , nf.dm_ind_emit
        , nf.pessoa_id
        , mf.cod_mod
        , nf.serie
        , nf.nro_nf
        , nf.sitdocto_id
        , nf.dm_st_proc
        , nf.dt_st_proc
        , nf.dm_forma_emiss
        , nf.dm_impressa
        , nf.dm_st_email
        , nf.dm_tp_amb
        , nf.nro_chave_nfe
        , nf.cNF_nfe
        , nf.dig_verif_chave
        , nf.dm_aut_sefaz
        , nf.dt_aut_sefaz
        , nf.nro_protocolo
        , nf.id                 notafiscal_id
        , nf.dt_emiss
        , nf.dm_st_integra
        , nf.sistorig_id
        , nf.unidorg_id
        , nf.cod_msg
        , nf.cod_msg cod_msg_canc        
        , nf.empresaintegrbanco_id
        , nfc.id_erp  id_erp
        , nfca.id_erp id_erp_can
     from Nota_Fiscal           nf
        , mod_fiscal            mf
        , nota_fiscal_compl     nfc
        , nota_fiscal_canc      nfca
    where nf.empresa_id         = en_empresa_id
      and nf.dm_st_proc         <> 0
      and nf.dm_ind_emit        = 0
      and nf.dm_st_integra      = 7
      and ( nf.cod_msg is null or nf.cod_msg not in ('204', '539', '290') )
      and mf.id                 = nf.modfiscal_id
      and mf.cod_mod            = '65'
      and nfc.notafiscal_id(+)  = nf.id
      and nfca.notafiscal_id(+) = nf.id
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   -- Verifica se o objeto de integração está ATIVO
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NF_ERP_NEO') = 0 then
      --
      return;
      --
   else
      -- Estando ATIVO veririca se o objeto antigo de integração tb está ativo e atualiza para DESATIVADO
      -- Manter somente uma view de resposta ativa
      if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NF_ERP') = 1 then
         --
         vn_fase := 1.1;
         --
         update obj_util_integr
            set dm_ativo = 0
          where obj_name in ('VW_CSF_RESP_NF_ERP', 'VW_CSF_RESP_NF_ERP_FF');
         --
      end if;
      --
   end if;
   --
   vn_fase := 2;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_cpf_cnpj ( en_multorg_id => gn_multorg_id
                                                   , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 3;
   --
   for rec in c_nf(vn_empresa_id) loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 4;
      --
      if nvl(rec.empresaintegrbanco_id,0) > 0
         and nvl(rec.empresaintegrbanco_id,0) <> nvl(gn_empresaintegrbanco_id,0)
         then
         --
         vn_fase := 5;
         --
         begin
            --
            select ei.owner_obj
                 , ei.nome_dblink
                 , ei.dm_util_aspa
                 , ei.dm_ret_infor_integr
                 , ei.formato_dt_erp
                 , ei.dm_form_dt_erp
              into vv_owner_obj
                 , vv_nome_dblink
                 , vn_dm_util_aspa
                 , vn_dm_ret_infor_integr
                 , vv_formato_dt_erp
                 , vn_dm_form_dt_erp
              from empresa_integr_banco ei
             where ei.id = rec.empresaintegrbanco_id;
            --
         exception
            when others then
               null;
         end;
         --
         vn_fase := 6;
         --
         if nvl(vn_dm_form_dt_erp,0) = 0
            or trim(vv_formato_dt_erp) is null then
            --
            vv_formato_dt_erp := gv_formato_data;
            --
         end if;
         --
         vn_fase := 7;
         --
         if nvl(vn_dm_util_aspa,0) = 1 then
            --
            vv_aspas := '"';
            --
         end if;
         --
      else
         --
         vn_fase := 8;
         --
         vv_owner_obj           := GV_OWNER_OBJ;
         vv_nome_dblink         := GV_NOME_DBLINK;
         vv_aspas               := GV_ASPAS;
         vn_dm_ret_infor_integr := GN_DM_RET_INFOR_INTEGR;
         vv_formato_dt_erp      := GD_FORMATO_DT_ERP;
         --
      end if;
      --
      vn_fase := 9;
      --
      vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NF_ERP_NEO'
                                     , ev_aspas       => vv_aspas
                                     , ev_owner_obj   => vv_owner_obj
                                     , ev_nome_dblink => vv_nome_dblink
                                     );
      --
      vn_fase := 10;
      --
      if nvl(vn_dm_ret_infor_integr,0) = 1 then
         --
         vn_fase := 10.1;
         --
         vn_empresa_id := rec.empresa_id;
         --
         vv_cpf_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
         --
         vn_fase := 10.2;
         --
         vn_dm_ret_hr_aut := pk_csf.fkg_ret_hr_aut_empresa_id ( en_empresa_id => vn_empresa_id );
         --
         vn_fase := 10.3;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
         --
         if trim(vv_cod_part) is null then
            vv_cod_part := ev_cpf_cnpj_emit;
         end if;
         --
         vn_fase := 10.4;
         --
         vv_sitdocto_cd := pk_csf.fkg_Sit_Docto_cd ( en_sitdoc_id => rec.sitdocto_id );
         --
         vn_fase := 10.5;
         --
         vv_sistorig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec.sistorig_id );
         --
         vn_fase := 10.6;
         --
         vv_unidorg_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec.unidorg_id );
         --
         vn_fase := 10.7;
         --
         begin
            --
            select nfc.dt_hr_recbto
                 , nfc.nro_protocolo
              into vd_dt_canc
                 , vn_nro_protocolo_canc
              from nota_fiscal_canc nfc
             where nfc.notafiscal_id = rec.notafiscal_id;
            --
         exception
            when others then
               vd_dt_canc            := null;
               vn_nro_protocolo_canc := null;
         end;
         --
         vn_fase := 11;
         --
         pkb_excluir_nf ( ev_cpf_cnpj_emit          => vv_cpf_cnpj
                        , en_dm_ind_emit            => rec.DM_IND_EMIT
                        , en_dm_ind_oper            => rec.DM_IND_OPER
                        , ev_cod_part               => vv_cod_part
                        , ev_cod_mod                => rec.COD_MOD
                        , ev_serie                  => rec.SERIE
                        , en_nro_nf                 => rec.NRO_NF
                        , en_notafiscal_id          => rec.notafiscal_id
                        , ev_obj                    => vv_obj
                        , ev_aspas                  => vv_aspas
                        );
         --
         vn_fase := 12;
         --| Verifica se existe
         vn_dm_st_proc_erp := fkg_ret_dm_st_proc_erp ( ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                                                     , en_dm_ind_emit            => rec.dm_ind_emit
                                                     , en_dm_ind_oper            => rec.dm_ind_oper
                                                     , ev_cod_part               => vv_cod_part
                                                     , ev_cod_mod                => rec.cod_mod
                                                     , ev_serie                  => rec.serie
                                                     , en_nro_nf                 => rec.nro_nf
                                                     , en_notafiscal_id          => rec.notafiscal_id
                                                     , ev_obj                    => vv_obj
                                                     , ev_aspas                  => vv_aspas
                                                     , ev_obj_name               => 'VW_CSF_RESP_NF_ERP_NEO'
                                                     );
         --
         vn_fase := 13;
         --
         -- Se não encontrou informa o registro
         if nvl(vn_dm_st_proc_erp,-1) = -1 then
            --
            vn_fase := 14;
            --
            vn_notafiscal_id := rec.notafiscal_id;
            --
            gv_sql := 'insert into ';
            --
            vn_fase := 15;
            --
            gv_sql := gv_sql || vv_obj || '(';
            --
            gv_sql := gv_sql ||         vv_aspas || 'CPF_CNPJ_EMIT'      || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_IND_OPER'        || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_IND_EMIT'        || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'COD_PART'           || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'COD_MOD'            || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'SERIE'              || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_NF'             || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'SIT_DOCTO'          || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_ST_PROC'         || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_ST_PROC'         || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_FORMA_EMISS'     || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_IMPRESSA'        || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_ST_EMAIL'        || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_TP_AMB'          || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_CHAVE_NFE'      || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'CNF_NFE'            || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DIG_VERIF_CHAVE'    || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_AUT_SEFAZ'       || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_AUT_SEFAZ'       || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_PROTOCOLO'      || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_CANC'            || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_PROTOCOLO_CANC' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NOTAFISCAL_ID'      || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DT_EMISS'           || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'DM_LEITURA'         || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'SIST_ORIG'          || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'UNID_ORG'           || vv_aspas;
            --
            vn_fase := 16;
            --
            if nvl(vn_dm_ret_hr_aut,0) = 1 then -- Retorna informação da hora de Autorização/Cancelamento para o ERP
               --
               gv_sql := gv_sql || ', ' || vv_aspas || 'HR_AUT_NFE' || vv_aspas;
               gv_sql := gv_sql || ', ' || vv_aspas || 'HR_AUT_CANC_NFE' || vv_aspas;
               --
            end if;
            --
            gv_sql := gv_sql || ', ' || vv_aspas || 'COD_MSG'            || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas || 'ID_ERP'             || vv_aspas;
            --
            gv_sql := gv_sql || ') values (';
            --
            gv_sql := gv_sql || '''' || ev_cpf_cnpj_emit || '''';
            gv_sql := gv_sql || ', ' || rec.DM_IND_OPER;
            gv_sql := gv_sql || ', ' || rec.DM_IND_EMIT;
            --
            gv_sql := gv_sql || ', ' || case when trim(vv_cod_part) is not null then '''' || trim(vv_cod_part) || '''' else '''' || ev_cpf_cnpj_emit || '''' end;
            --
            gv_sql := gv_sql || ', ' || '''' || rec.COD_MOD || '''';
            gv_sql := gv_sql || ', ' || '''' || rec.SERIE || '''';
            gv_sql := gv_sql || ', ' || rec.NRO_NF;
            gv_sql := gv_sql || ', ' || '''' || case when rec.DM_ST_PROC = 7 then '02' when rec.DM_ST_PROC = 6 then '04' when rec.DM_ST_PROC = 8 then '05' else trim(vv_sitdocto_cd) end || '''';
            gv_sql := gv_sql || ', ' || case when rec.DM_ST_PROC = 0 then 1 else rec.DM_ST_PROC end;
            gv_sql := gv_sql || ', ' || '''' || to_char(rec.DT_ST_PROC, vv_formato_dt_erp )  || '''';
            gv_sql := gv_sql || ', ' || rec.DM_FORMA_EMISS;
            gv_sql := gv_sql || ', ' || rec.DM_IMPRESSA;
            gv_sql := gv_sql || ', ' || rec.DM_ST_EMAIL;
            gv_sql := gv_sql || ', ' || rec.DM_TP_AMB;
            gv_sql := gv_sql || ', ' || '''' || rec.NRO_CHAVE_NFE || '''';
            --
            vn_fase := 17;
            --
            gv_sql := gv_sql || ', ' || nvl(rec.CNF_NFE,0);
            --
            vn_fase := 18;
            --
            gv_sql := gv_sql || ', ' || nvl(rec.DIG_VERIF_CHAVE,0);
            --
            vn_fase := 19;
            --
            gv_sql := gv_sql || ', ' || nvl(rec.DM_AUT_SEFAZ,0);
            --
            vn_fase := 20;
            --
            if rec.DT_AUT_SEFAZ is not null then
               gv_sql := gv_sql || ', ' || '''' || to_char(rec.DT_AUT_SEFAZ, vv_formato_dt_erp ) || '''';
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 21;
            --
            gv_sql := gv_sql || ', ' || nvl(rec.NRO_PROTOCOLO,0);
            --
            vn_fase := 22;
            --
            if vd_dt_canc is not null then
               gv_sql := gv_sql || ', ' || '''' || to_char(vd_dt_canc, vv_formato_dt_erp ) || '''';
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 23;
            --
            gv_sql := gv_sql || ', ' || nvl(vn_nro_protocolo_canc,0);
            --
            vn_fase := 24;
            --
            gv_sql := gv_sql || ', ' || rec.NOTAFISCAL_ID;
            --
            vn_fase := 25;
            --
            if rec.dt_emiss is not null then
               gv_sql := gv_sql || ', ' || '''' || to_char(rec.dt_emiss, vv_formato_dt_erp) || '''';
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 26;
            --
            gv_sql := gv_sql || ', 0'; -- DM_LEITURA
            --
            gv_sql := gv_sql || ', ' ||  case when trim(vv_sistorig_sigla) is null then '''' || ' ' || '''' else '''' || trim(vv_sistorig_sigla) || '''' end;
            --
            gv_sql := gv_sql || ', ' ||  case when trim(vv_unidorg_cd) is null then '''' || ' ' || '''' else '''' || trim(vv_unidorg_cd) || '''' end;
            --
            vn_fase := 27;
            --
            if nvl(vn_dm_ret_hr_aut,0) = 1 then -- Retorna informação da hora de Autorização/Cancelamento para o ERP
               --
               vn_fase := 27.1;
               --
               if rec.DT_AUT_SEFAZ is not null then
                  gv_sql := gv_sql || ', ' || '''' || to_char(rec.DT_AUT_SEFAZ, 'HH24:MI:SS' ) || '''';
               else
                  gv_sql := gv_sql || ', null';
               end if;
               --
               vn_fase := 27.2;
               --
               if vd_dt_canc is not null then
                  gv_sql := gv_sql || ', ' || '''' || to_char(vd_dt_canc, 'HH24:MI:SS' ) || '''';
               else
                  gv_sql := gv_sql || ', null';
               end if;
               --
            end if;
            --
            vn_fase := 28;
            --
            if rec.COD_MSG_CANC is not null then
               gv_sql := gv_sql || ', ' || rec.COD_MSG_CANC;
            elsif rec.COD_MSG is not null then
               gv_sql := gv_sql || ', ' || rec.COD_MSG;
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 29;
            --
            if nvl(rec.id_erp,rec.id_erp_can) > 0 then
               gv_sql := gv_sql || ', ' || nvl(rec.id_erp,rec.id_erp_can);
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 30;
            --
            gv_sql := gv_sql || ')';
            --
            vn_fase := 31;
            --
            vn_erro := 0;
            --
            begin
               --
               execute immediate gv_sql;
               --
            exception
               when others then
                  --
                  vn_erro := 1;
                  --
                  -- A função replace está sendo utilizada para substituir uma aspas por duas, no comando executado,
                  -- pois esse log será registrado em outra tabela através de uma query dinâmica feita pelo procedimento
                  -- pkb_ret_infor_erro_nf_erp, e quando tem apenas uma aspas, ocorre o erro: ORA-00917: vírgula não encontrada
                  --
                  pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_infor_erp_neo fase(' || vn_fase || '):' || sqlerrm || ' - ' || replace (gv_sql, '''', '''''');
                  --
                  declare
                     vn_loggenerico_id  log_generico_nf.id%TYPE;
                  begin
                     --
                     pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                    , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                    , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                    , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                                    , en_referencia_id    => rec.NOTAFISCAL_ID
                                                    , ev_obj_referencia   => 'NOTA_FISCAL' );
                     --
                  exception
                     when others then
                        null;
                  end;
                  --
            end;
            --
            commit;
            --
            vn_fase := 32;
            --
            begin
               -- grava informações de erro para o erp
               pkb_ret_infor_erro_nf_erp ( en_notafiscal_id => rec.notafiscal_id
                                         , ev_obj           => 'VW_CSF_RESP_ERRO_NF_ERP' );
               --
            exception
               when others then
                  vn_erro := 1;
            end;
            --
            if nvl(vn_erro,0) = 0 then
               --
               vn_fase := 33;
               --
               if rec.DM_ST_PROC not in (4, 6, 7, 8) then
                  --
                  vn_fase := 34;
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => 8 );
                  --
               else
                  --
                  vn_fase := 35;
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => 9 );
                  --
               end if;
               --
            end if;
            --
         else
            --
            vn_fase := 36;
            --
            pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                      , en_dm_st_integra  => 8 );
            --
         end if;
         --
         -- Executa procedimento de resposta FF
         -- Não tem FF
         --
         commit;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_infor_erp_neo fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => vn_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_infor_erp_neo;
--
-- ============================================================================================================================================= --
-- Procedimento Gera o Retorno para o ERP
procedure pkb_gera_retorno ( ev_sist_orig in varchar2 default null ) is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.owner_obj
        , eib.id empresaintegrbanco_id
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
        , e.multorg_id
     from empresa e
        , empresa_integr_banco eib
    where e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
      and eib.empresa_id   = e.id
      and eib.dm_ret_infor_integr = 1 -- retorna a informação para o ERP
    order by 1;

begin
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   GV_SIST_ORIG := trim(ev_sist_orig);
   --
   vn_fase := 2;
   --
   pk_csf_api_nfce.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      --
      vn_fase := 3;
      --
      gn_multorg_id := rec.multorg_id;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      --
      vn_fase := 3.1;
      -- Seta o DBLink
      GN_EMPRESAINTEGRBANCO_ID := rec.empresaintegrbanco_id;
      GV_NOME_DBLINK           := rec.nome_dblink;
      GV_OWNER_OBJ             := rec.owner_obj;
      --
      vn_fase := 4;
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         GV_ASPAS := '"';
         --
      else
         --
         GV_ASPAS := null;
         --
      end if;
      --
      vn_fase := 5;
      --  Seta formata da data para os procedimentos de retorno
      gn_dm_form_dt_erp := rec.dm_form_dt_erp;
      --
      if nvl(rec.dm_form_dt_erp,0) = 1
         and trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := rec.formato_dt_erp;
      else
         gd_formato_dt_erp := gv_formato_data;
      end if;
      --
      gn_dm_ret_infor_integr := nvl(rec.dm_ret_infor_integr,0);
      --
      vn_fase := 6;
      -- Integra a informação para o ERP - VW_CSF_RESP_NF_ERP
      pkb_int_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 7;
      -- retorna a informação para o ERP - VW_CSF_RESP_NF_ERP
      pkb_ret_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      -- Integra a informação para o ERP - NEO - VW_CSF_RESP_NF_ERP_NEO
      vn_fase := 8;
      pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 9;
      -- retorna a informação para o ERP - NEO - VW_CSF_RESP_NF_ERP_NEO
      pkb_ret_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
   end loop;
   --
   vn_fase := 9;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api_nfce.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 10;
   --
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_gera_retorno fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_gera_retorno;
--
-- ============================================================================================================================================= --
-- Procedimento de Formas de Pagamento - Flex-Field
procedure pkb_ler_nf_forma_pgto_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                   , en_notafiscal_id      in             nota_fiscal_emit.notafiscal_id%type
                                   , en_nfformapgto_id     in             nf_forma_pgto.id%type
                                   --| parâmetros de chave
                                   , ev_cpf_cnpj_emit      in             varchar2
                                   , en_dm_ind_emit        in             number
                                   , en_dm_ind_oper        in             number
                                   , ev_cod_part           in             varchar2
                                   , ev_cod_mod            in             varchar2
                                   , ev_serie              in             varchar2
                                   , en_nro_nf             in             number
                                   , ev_dm_tp_pag          in             varchar2
                                   , en_vl_pgto            in             number
                                   , ev_cnpj               in             varchar2
                                   , ev_dm_tp_band         in             varchar2
                                   , ev_nro_aut            in             varchar2
                                   ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_FORMA_PGTO_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD'       || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TP_PAG'     || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_PGTO'       || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CNPJ'          || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TP_BAND'    || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_AUT'       || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR'         || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_FORMA_PGTO_FF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD'    || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'     || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_TP_PAG'  || GV_ASPAS || ' = ' || '''' || ev_dm_tp_pag || '''';
   --gv_sql := gv_sql || ' and ' || GV_ASPAS || 'VL_PGTO'    || GV_ASPAS || ' = ' || en_vl_pgto; -- devido as casas decimais do campo numérico, o valor aparece com vírgula
   gv_sql := gv_sql || ' and (' || GV_ASPAS || 'VL_PGTO'    || GV_ASPAS || ' * 100) = ' || (en_vl_pgto * 100); -- devido as casas decimais
   --
   if ev_cnpj is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'CNPJ' || GV_ASPAS || ' = ' || '''' || ev_cnpj || '''';
      --
   end if;
   --
   if ev_dm_tp_band is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_TP_BAND' || GV_ASPAS || ' = ' || '''' || ev_dm_tp_band || '''';
      --
   end if;
   --
   if ev_nro_aut is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_AUT' || GV_ASPAS || ' = ' || '''' || ev_nro_aut || '''';
      --
   end if;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_FORMA_PGTO_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nf_forma_pgto_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nf_forma_pgto_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nf_forma_pgto_ff.count > 0 then
      --
      for i in vt_tab_csf_nf_forma_pgto_ff.first..vt_tab_csf_nf_forma_pgto_ff.last loop
         --
         vn_fase := 7;
         -- Chama procedimento que valida as informações da Forma do Pagamento - Campos Flex Field
         pk_csf_api_nfce.pkb_integr_nf_forma_pgto_ff ( est_log_generico_nf => est_log_generico_nf
                                                , en_notafiscal_id    => en_notafiscal_id
                                                , en_nfformapgto_id   => en_nfformapgto_id
                                                , ev_atributo         => vt_tab_csf_nf_forma_pgto_ff(i).atributo
                                                , ev_valor            => vt_tab_csf_nf_forma_pgto_ff(i).valor );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nf_forma_pgto_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => gv_cabec_nf
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nf_forma_pgto_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de Formas de Pagamento
procedure pkb_ler_nf_forma_pgto ( est_log_generico_nf        in out nocopy  dbms_sql.number_table
                                 , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                                 --| parâmetros de chave
                                 , ev_cpf_cnpj_emit          in             varchar2
                                 , en_dm_ind_emit            in             number
                                 , en_dm_ind_oper            in             number
                                 , ev_cod_part               in             varchar2
                                 , ev_cod_mod                in             varchar2
                                 , ev_serie                  in             varchar2
                                 , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_FORMA_PGTO') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TP_PAG' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_PGTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CNPJ' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TP_BAND' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_AUT' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_FORMA_PGTO');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_FORMA_PGTO' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nf_forma_pgto;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nf_forma_pgto fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nf_forma_pgto.count > 0 then
      --
      for i in vt_tab_csf_nf_forma_pgto.first..vt_tab_csf_nf_forma_pgto.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_nf_forma_pgto := null;
         --
         pk_csf_api_nfce.gt_row_nf_forma_pgto.notafiscal_id  := en_notafiscal_id;
         pk_csf_api_nfce.gt_row_nf_forma_pgto.dm_tp_pag      := trim(vt_tab_csf_nf_forma_pgto(i).dm_tp_pag);
         pk_csf_api_nfce.gt_row_nf_forma_pgto.vl_pgto        := vt_tab_csf_nf_forma_pgto(i).vl_pgto;
         pk_csf_api_nfce.gt_row_nf_forma_pgto.cnpj           := trim(vt_tab_csf_nf_forma_pgto(i).cnpj);
         pk_csf_api_nfce.gt_row_nf_forma_pgto.dm_tp_band     := trim(vt_tab_csf_nf_forma_pgto(i).dm_tp_band);
         pk_csf_api_nfce.gt_row_nf_forma_pgto.nro_aut        := trim(vt_tab_csf_nf_forma_pgto(i).nro_aut);
         --
         vn_fase := 8;
         --
         pk_csf_api_nfce.pkb_integr_nf_forma_pgto ( est_log_generico_nf   => est_log_generico_nf
                                             , est_row_nf_forma_pgto => pk_csf_api_nfce.gt_row_nf_forma_pgto );
         --
         vn_fase := 9;
         --
         pkb_ler_nf_forma_pgto_ff ( est_log_generico_nf   => est_log_generico_nf
                                  , en_notafiscal_id      => en_notafiscal_id
                                  , en_nfformapgto_id     => pk_csf_api_nfce.gt_row_nf_forma_pgto.id
                                  --| parâmetros de chave
                                  , ev_cpf_cnpj_emit      => ev_cpf_cnpj_emit
                                  , en_dm_ind_emit        => en_dm_ind_emit
                                  , en_dm_ind_oper        => en_dm_ind_oper
                                  , ev_cod_part           => ev_cod_part
                                  , ev_cod_mod            => ev_cod_mod
                                  , ev_serie              => ev_serie
                                  , en_nro_nf             => en_nro_nf
                                  , ev_dm_tp_pag          => vt_tab_csf_nf_forma_pgto(i).dm_tp_pag 
                                  , en_vl_pgto            => pk_csf_api_nfce.gt_row_nf_forma_pgto.vl_pgto
                                  , ev_cnpj               => vt_tab_csf_nf_forma_pgto(i).cnpj 
                                  , ev_dm_tp_band         => vt_tab_csf_nf_forma_pgto(i).dm_tp_band 
                                  , ev_nro_aut            => vt_tab_csf_nf_forma_pgto(i).nro_aut 
                                  );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nf_forma_pgto fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => gv_cabec_nf
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nf_forma_pgto;
--
-- ============================================================================================================================================= --
-- Procedimento de Autorização de acesso ao XML da Nota Fiscal
procedure pkb_ler_nf_aut_xml ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                             --| parâmetros de chave
                             , ev_cpf_cnpj_emit          in             varchar2
                             , en_dm_ind_emit            in             number
                             , en_dm_ind_oper            in             number
                             , ev_cod_part               in             varchar2
                             , ev_cod_mod                in             varchar2
                             , ev_serie                  in             varchar2
                             , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_AUT_XML') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CNPJ' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CPF' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_AUT_XML');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_AUT_XML' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nf_aut_xml;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nf_aut_xml fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nf_aut_xml.count > 0 then
      --
      for i in vt_tab_csf_nf_aut_xml.first..vt_tab_csf_nf_aut_xml.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_nf_aut_xml := null;
         --
         pk_csf_api_nfce.gt_row_nf_aut_xml.notafiscal_id  := en_notafiscal_id;
         pk_csf_api_nfce.gt_row_nf_aut_xml.cnpj        := trim(vt_tab_csf_nf_aut_xml(i).cnpj);
         pk_csf_api_nfce.gt_row_nf_aut_xml.cpf         := trim(vt_tab_csf_nf_aut_xml(i).cpf);
         --
         vn_fase := 8;
         --
         pk_csf_api_nfce.pkb_integr_nf_aut_xml ( est_log_generico_nf          => est_log_generico_nf
                                           , est_row_nf_aut_xml       => pk_csf_api_nfce.gt_row_nf_aut_xml );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nf_aut_xml fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => gv_resumo || gv_cabec_nf
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nf_aut_xml;
--
-- ============================================================================================================================================= --
-- Procedimento de informações de Ajustes da nota fiscal
procedure pkb_ler_inf_prov_docto_fiscal ( est_log_generico_nf    in out nocopy  dbms_sql.number_table
                                        , en_notafiscal_id       in             Nota_Fiscal.id%TYPE
                                      --| parâmetros de chave
                                        , ev_cpf_cnpj_emit       in             varchar2
                                        , en_dm_ind_emit         in             number
                                        , en_dm_ind_oper         in             number
                                        , ev_cod_part            in             varchar2
                                        , ev_cod_mod             in             varchar2
                                        , ev_serie               in             varchar2
                                        , en_nro_nf              in             number
                                        , ev_cd_obs              in             varchar2
                                        ) is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_INF_PROV_DOCTO_FISCAL') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD'       || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_OBS'       || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_AJ'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DESCR_COMPL_AJ'|| GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BC_ICMS'    || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ALIQ_ICMS'     || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ICMS'       || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_OUTROS'     || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_INF_PROV_DOCTO_FISCAL');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE'   || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'  || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_OBS' || GV_ASPAS || ' = ' || '''' || ev_cd_obs || '''';
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_INF_PROV_DOCTO_FISCAL' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_inf_prov_docto_fisc;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_inf_prov_docto_fiscal fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_inf_prov_docto_fisc.count > 0 then
      --
      for i in vt_tab_csf_inf_prov_docto_fisc.first..vt_tab_csf_inf_prov_docto_fisc.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_inf_prov_docto_fiscal := null;
         --
         pk_csf_api_nfce.gt_row_inf_prov_docto_fiscal.descr_compl_aj := vt_tab_csf_inf_prov_docto_fisc(i).descr_compl_aj;
         pk_csf_api_nfce.gt_row_inf_prov_docto_fiscal.vl_bc_icms     := vt_tab_csf_inf_prov_docto_fisc(i).vl_bc_icms;
         pk_csf_api_nfce.gt_row_inf_prov_docto_fiscal.aliq_icms      := vt_tab_csf_inf_prov_docto_fisc(i).aliq_icms;
         pk_csf_api_nfce.gt_row_inf_prov_docto_fiscal.vl_icms        := vt_tab_csf_inf_prov_docto_fisc(i).vl_icms;
         pk_csf_api_nfce.gt_row_inf_prov_docto_fiscal.vl_outros      := vt_tab_csf_inf_prov_docto_fisc(i).vl_outros;
         --
         vn_fase := 8;
         -- Chama o procedimento que integra as informações do Ajuste
         pk_csf_api_nfce.pkb_integr_inf_prov_docto_fisc ( est_log_generico_nf           => est_log_generico_nf
                                                   , est_row_inf_prov_docto_fiscal => pk_csf_api_nfce.gt_row_inf_prov_docto_fiscal
                                                   , ev_cod_obs                    => trim(ev_cd_obs)
                                                   , ev_cod_aj                     => vt_tab_csf_inf_prov_docto_fisc(i).cod_aj
                                                   , en_notafiscal_id              => en_notafiscal_id
                                                   , en_nro_item                   => vt_tab_csf_inf_prov_docto_fisc(i).nro_item
                                                   , en_multorg_id                 => gn_multorg_id
                                                   );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_inf_prov_docto_fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_inf_prov_docto_fiscal;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de informações fiscais da nota fiscal
procedure pkb_ler_NFInfor_Fiscal ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                 , en_notafiscal_id          in             NFInfor_Fiscal.notafiscal_id%TYPE
                               --| parâmetros de chave
                                 , ev_cpf_cnpj_emit          in             varchar2
                                 , en_dm_ind_emit            in             number
                                 , en_dm_ind_oper            in             number
                                 , ev_cod_part               in             varchar2
                                 , ev_cod_mod                in             varchar2
                                 , ev_serie                  in             varchar2
                                 , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NFINFOR_FISCAL') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD'       || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_OBS'       || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'TXT_COMPL'     || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NFINFOR_FISCAL');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE'   || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'  || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NFINFOR_FISCAL' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nfinfor_fiscal;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_NFInfor_Fiscal fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nfinfor_fiscal.count > 0 then
      --
      for i in vt_tab_csf_nfinfor_fiscal.first..vt_tab_csf_nfinfor_fiscal.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_NFInfor_Fiscal := null;
         --
         if trim(vt_tab_csf_nfinfor_fiscal(i).cod_obs) is not null then
            --
            pk_csf_api_nfce.gt_row_NFInfor_Fiscal.notafiscal_id := en_notafiscal_id;
            pk_csf_api_nfce.gt_row_NFInfor_Fiscal.txt_compl     := trim(vt_tab_csf_nfinfor_fiscal(i).txt_compl);
            --
            vn_fase := 8;
            -- Chama o procedimento de validação dos dados da Informação Fiscal da Nota Fiscal
            pk_csf_api_nfce.pkb_integr_NFInfor_Fiscal ( est_log_generico_nf    => est_log_generico_nf
                                                 , est_row_NFInfor_Fiscal => pk_csf_api_nfce.gt_row_NFInfor_Fiscal
                                                 , ev_cd_obs              => trim(vt_tab_csf_nfinfor_fiscal(i).cod_obs)
                                                 , en_multorg_id          => gn_multorg_id );
            --
            vn_fase := 9;
            --
            pkb_ler_inf_prov_docto_fiscal ( est_log_generico_nf => est_log_generico_nf
                                          , en_notafiscal_id    => en_notafiscal_id
                                        --| parâmetros de chave
                                          , ev_cpf_cnpj_emit    => ev_cpf_cnpj_emit
                                          , en_dm_ind_emit      => en_dm_ind_emit
                                          , en_dm_ind_oper      => en_dm_ind_oper
                                          , ev_cod_part         => ev_cod_part
                                          , ev_cod_mod          => ev_cod_mod
                                          , ev_serie            => ev_serie
                                          , en_nro_nf           => en_nro_nf
                                          , ev_cd_obs           => vt_tab_csf_nfinfor_fiscal(i).cod_obs
                                          );
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_NFInfor_Fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_NFInfor_Fiscal;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de Rastreabilidade de produto
procedure pkb_ler_itemnf_rastreab ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                  , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                                  , en_itemnf_id              in             Item_Nota_Fiscal.id%TYPE
                                  --| parâmetros de chave
                                  , ev_cpf_cnpj_emit          in             varchar2
                                  , en_dm_ind_emit            in             number
                                  , en_dm_ind_oper            in             number
                                  , ev_cod_part               in             varchar2
                                  , ev_cod_mod                in             varchar2
                                  , ev_serie                  in             varchar2
                                  , en_nro_nf                 in             number
                                  , en_nro_item               in             number
                                  ) is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_RASTREAB') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_LOTE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'QTDE_LOTE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DT_FABR' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DT_VALID' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_AGREG' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEMNF_RASTREAB');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS || ' = ' || en_nro_item;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_RASTREAB' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_itemnf_rastreab;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_itemnf_rastreab fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_itemnf_rastreab.count > 0 then
      --
      for i in vt_tab_csf_itemnf_rastreab.first..vt_tab_csf_itemnf_rastreab.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_itemnf_rastreab := null;
         --
         pk_csf_api_nfce.gt_row_itemnf_rastreab.itemnf_id        := en_itemnf_id;
         pk_csf_api_nfce.gt_row_itemnf_rastreab.NRO_LOTE         := vt_tab_csf_itemnf_rastreab(i).NRO_LOTE;
         pk_csf_api_nfce.gt_row_itemnf_rastreab.QTDE_LOTE        := vt_tab_csf_itemnf_rastreab(i).QTDE_LOTE;
         pk_csf_api_nfce.gt_row_itemnf_rastreab.DT_FABR          := vt_tab_csf_itemnf_rastreab(i).DT_FABR;
         pk_csf_api_nfce.gt_row_itemnf_rastreab.DT_VALID         := vt_tab_csf_itemnf_rastreab(i).DT_VALID;
         pk_csf_api_nfce.gt_row_itemnf_rastreab.COD_AGREG        := vt_tab_csf_itemnf_rastreab(i).COD_AGREG;
         --
         vn_fase := 8;
         -- Chama procedimento que válida as informações de rastreabilidade do produto
         pk_csf_api_nfce.pkb_integr_itemnf_rastreab ( est_log_generico_nf      => est_log_generico_nf
                                               , est_row_itemnf_rastreab   => pk_csf_api_nfce.gt_row_itemnf_rastreab
                                               , en_notafiscal_id         => en_notafiscal_id
                                               );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_itemnf_rastreab fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_itemnf_rastreab;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de informações de medicamentos do item da nota fiscal - campos Flex Field
procedure pkb_ler_ItemNF_Med_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                , en_notafiscal_id          in             Nota_Fiscal.id%TYPE
                                , en_itemnfmed_id           in             Item_Nota_Fiscal.id%TYPE
                                --| parâmetros de chave
                                , ev_cpf_cnpj_emit          in             varchar2
                                , en_dm_ind_emit            in             number
                                , en_dm_ind_oper            in             number
                                , ev_cod_part               in             varchar2
                                , ev_cod_mod                in             varchar2
                                , ev_serie                  in             varchar2
                                , en_nro_nf                 in             number
                                , en_nro_item               in             number
                                , ev_nro_lote               in             varchar2
                                ) is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_MED_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_LOTE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEMNF_MED_FF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS || ' = ' || en_nro_item;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_LOTE' || GV_ASPAS || ' = ' ||  '''' || ev_nro_lote || '''';
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_MED_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_itemnf_med_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_ItemNF_Med_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => gv_resumo || gv_cabec_nf
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_itemnf_med_ff.count > 0 then
      --
      for i in vt_tab_csf_itemnf_med_ff.first..vt_tab_csf_itemnf_med_ff.last loop
         --
         vn_fase := 7;
         -- Chama procedimento que válida as informações de Combustíveis
         pk_csf_api_nfce.pkb_integr_ItemNF_Med_ff ( est_log_generico_nf  => est_log_generico_nf
                                             , en_notafiscal_id     => en_notafiscal_id
                                             , en_itemnfmed_id      => en_itemnfmed_id
                                             , ev_atributo          => vt_tab_csf_itemnf_med_ff(i).atributo
                                             , ev_valor             => vt_tab_csf_itemnf_med_ff(i).valor
                                             );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_ItemNF_Med_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_ItemNF_Med_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de informações de medicamentos da nota fiscal
procedure pkb_ler_ItemNF_Med ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                             , en_itemnf_id              in             Item_Nota_Fiscal.id%TYPE
                             --| parâmetros de chave
                             , ev_cpf_cnpj_emit          in             varchar2
                             , en_dm_ind_emit            in             number
                             , en_dm_ind_oper            in             number
                             , ev_cod_part               in             varchar2
                             , ev_cod_mod                in             varchar2
                             , ev_serie                  in             varchar2
                             , en_nro_nf                 in             number
                             , en_nro_item               in             number ) is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_MED') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_LOTE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TP_PROD' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_MED' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'QTDE_LOTE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DT_FABR' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DT_VALID' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_TAB_MAX' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEMNF_MED');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS || ' = ' || en_nro_item;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_MED' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_itemnf_med;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_ItemNF_Med fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_itemnf_med.count > 0 then
      --
      for i in vt_tab_csf_itemnf_med.first..vt_tab_csf_itemnf_med.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_ItemNF_Med := null;
         --
         pk_csf_api_nfce.gt_row_ItemNF_Med.itemnf_id   := en_itemnf_id;
         pk_csf_api_nfce.gt_row_ItemNF_Med.dm_tp_prod  := vt_tab_csf_itemnf_med(i).dm_tp_prod;
         pk_csf_api_nfce.gt_row_ItemNF_Med.dm_ind_med  := vt_tab_csf_itemnf_med(i).dm_ind_med;
         pk_csf_api_nfce.gt_row_ItemNF_Med.nro_lote    := trim(vt_tab_csf_itemnf_med(i).nro_lote);
         pk_csf_api_nfce.gt_row_ItemNF_Med.qtde_lote   := vt_tab_csf_itemnf_med(i).qtde_lote;
         pk_csf_api_nfce.gt_row_ItemNF_Med.dt_fabr     := vt_tab_csf_itemnf_med(i).dt_fabr;
         pk_csf_api_nfce.gt_row_ItemNF_Med.dt_valid    := vt_tab_csf_itemnf_med(i).dt_valid;
         pk_csf_api_nfce.gt_row_ItemNF_Med.vl_tab_max  := vt_tab_csf_itemnf_med(i).vl_tab_max;
         --
         vn_fase := 8;
         -- Chama procedimento que válida as informações dos medicamentos
         pk_csf_api_nfce.pkb_integr_ItemNF_Med ( est_log_generico_nf  => est_log_generico_nf
                                          , est_row_ItemNF_Med   => pk_csf_api_nfce.gt_row_ItemNF_Med
                                          , en_notafiscal_id     => en_notafiscal_id
                                          );
         --
         vn_fase := 9;
         --
         pkb_ler_ItemNF_Med_ff ( est_log_generico_nf       => est_log_generico_nf
                               , en_notafiscal_id          => en_notafiscal_id
                               , en_itemnfmed_id           => pk_csf_api_nfce.gt_row_ItemNF_Med.id
                               --| parâmetros de chave
                               , ev_cpf_cnpj_emit          => trim(vt_tab_csf_itemnf_med(i).cpf_cnpj_emit)
                               , en_dm_ind_emit            => trim(vt_tab_csf_itemnf_med(i).dm_ind_emit)
                               , en_dm_ind_oper            => trim(vt_tab_csf_itemnf_med(i).dm_ind_oper)
                               , ev_cod_part               => trim(vt_tab_csf_itemnf_med(i).cod_part)
                               , ev_cod_mod                => trim(vt_tab_csf_itemnf_med(i).cod_mod )
                               , ev_serie                  => trim(vt_tab_csf_itemnf_med(i).serie)
                               , en_nro_nf                 => trim(vt_tab_csf_itemnf_med(i).nro_nf)
                               , en_nro_item               => trim(vt_tab_csf_itemnf_med(i).nro_item)
                               , ev_nro_lote               => trim(vt_tab_csf_itemnf_med(i).nro_lote)
                               );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_ItemNF_Med fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_ItemNF_Med;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de informações de combustíveis do item da nota fiscal - campos Flex Field
procedure pkb_ler_ItemNF_Comb_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                 , en_notafiscal_id          in             Nota_Fiscal.id%TYPE
                                 , en_itemnfcomb_id          in             Item_Nota_Fiscal.id%TYPE
                                 --| parâmetros de chave
                                 , ev_cpf_cnpj_emit          in             varchar2
                                 , en_dm_ind_emit            in             number
                                 , en_dm_ind_oper            in             number
                                 , ev_cod_part               in             varchar2
                                 , ev_cod_mod                in             varchar2
                                 , ev_serie                  in             varchar2
                                 , en_nro_nf                 in             number
                                 , en_nro_item               in             number ) is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_COMB_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEMNF_COMB_FF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS || ' = ' || en_nro_item;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_COMB_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_itemnf_comb_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_ItemNF_Comb_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => gv_resumo || gv_cabec_nf
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_itemnf_comb_ff.count > 0 then
      --
      for i in vt_tab_csf_itemnf_comb_ff.first..vt_tab_csf_itemnf_comb_ff.last loop
         --
         vn_fase := 7;
         -- Chama procedimento que válida as informações de Combustíveis
         pk_csf_api_nfce.pkb_integr_ItemNF_Comb_ff ( est_log_generico_nf  => est_log_generico_nf
                                              , en_notafiscal_id  => en_notafiscal_id
                                              , en_itemnfcomb_id  => en_itemnfcomb_id
                                              , ev_atributo       => vt_tab_csf_itemnf_comb_ff(i).atributo
                                              , ev_valor          => vt_tab_csf_itemnf_comb_ff(i).valor  );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_ItemNF_Comb_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_ItemNF_Comb_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de informações de combustíveis do item da nota fiscal
procedure pkb_ler_ItemNF_Comb ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                              , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                              , en_itemnf_id              in             Item_Nota_Fiscal.id%TYPE
                              --| parâmetros de chave
                              , ev_cpf_cnpj_emit          in             varchar2
                              , en_dm_ind_emit            in             number
                              , en_dm_ind_oper            in             number
                              , ev_cod_part               in             varchar2
                              , ev_cod_mod                in             varchar2
                              , ev_serie                  in             varchar2
                              , en_nro_nf                 in             number
                              , en_nro_item               in             number ) is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_COMB') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CODPRODANP' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CODIF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'QTDE_TEMP' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'QTDE_BC_CIDE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ALIQ_PROD_CIDE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_CIDE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BASE_CALC_ICMS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ICMS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BASE_CALC_ICMS_ST' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ICMS_ST' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BC_ICMS_ST_DEST' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ICMS_ST_DEST' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BC_ICMS_ST_CONS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ICMS_ST_CONS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'UF_CONS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_PASSE' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEMNF_COMB');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS || ' = ' || en_nro_item;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_COMB' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_itemnf_comb;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_ItemNF_Comb fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => gv_resumo || gv_cabec_nf
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_itemnf_comb.count > 0 then
      --
      for i in vt_tab_csf_itemnf_comb.first..vt_tab_csf_itemnf_comb.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_ItemNF_Comb := null;
         --
         pk_csf_api_nfce.gt_row_ItemNF_Comb.itemnf_id             := en_itemnf_id;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.codprodanp            := vt_tab_csf_itemnf_comb(i).codprodanp;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.codif                 := vt_tab_csf_itemnf_comb(i).codif;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.qtde_temp             := vt_tab_csf_itemnf_comb(i).qtde_temp;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.qtde_bc_cide          := vt_tab_csf_itemnf_comb(i).qtde_bc_cide;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_aliq_prod_cide     := vt_tab_csf_itemnf_comb(i).vl_aliq_prod_cide;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_cide               := vt_tab_csf_itemnf_comb(i).vl_cide;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_base_calc_icms     := vt_tab_csf_itemnf_comb(i).vl_base_calc_icms;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_icms               := vt_tab_csf_itemnf_comb(i).vl_icms;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_base_calc_icms_st  := vt_tab_csf_itemnf_comb(i).vl_base_calc_icms_st;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_icms_st            := vt_tab_csf_itemnf_comb(i).vl_icms_st;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_bc_icms_st_dest    := vt_tab_csf_itemnf_comb(i).vl_bc_icms_st_dest;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_icms_st_dest       := vt_tab_csf_itemnf_comb(i).vl_icms_st_dest;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_bc_icms_st_cons    := vt_tab_csf_itemnf_comb(i).vl_bc_icms_st_cons;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.vl_icms_st_cons       := vt_tab_csf_itemnf_comb(i).vl_icms_st_cons;
         pk_csf_api_nfce.gt_row_ItemNF_Comb.uf_cons               := trim(vt_tab_csf_itemnf_comb(i).uf_cons);
         pk_csf_api_nfce.gt_row_ItemNF_Comb.nro_passe             := trim(vt_tab_csf_itemnf_comb(i).nro_passe);
         --
         vn_fase := 8;
         -- Chama procedimento que válida as informações de Combustíveis
         pk_csf_api_nfce.pkb_integr_ItemNF_Comb ( est_log_generico_nf      => est_log_generico_nf
                                           , est_row_ItemNF_Comb   => pk_csf_api_nfce.gt_row_ItemNF_Comb
                                           , ev_uf_emit            => pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.uf
                                           , en_notafiscal_id      => en_notafiscal_id );
         --
         vn_fase := 9;
         --
         pkb_ler_ItemNF_Comb_ff ( est_log_generico_nf         => est_log_generico_nf
                                , en_notafiscal_id         => en_notafiscal_id
                                , en_itemnfcomb_id         => pk_csf_api_nfce.gt_row_ItemNF_Comb.id
                                --| parâmetros de chave
                                , ev_cpf_cnpj_emit         => vt_tab_csf_itemnf_comb(i).cpf_cnpj_emit
                                , en_dm_ind_emit           => vt_tab_csf_itemnf_comb(i).dm_ind_emit
                                , en_dm_ind_oper           => vt_tab_csf_itemnf_comb(i).dm_ind_oper
                                , ev_cod_part              => vt_tab_csf_itemnf_comb(i).cod_part
                                , ev_cod_mod               => vt_tab_csf_itemnf_comb(i).cod_mod
                                , ev_serie                 => vt_tab_csf_itemnf_comb(i).serie
                                , en_nro_nf                => vt_tab_csf_itemnf_comb(i).nro_nf
                                , en_nro_item              => vt_tab_csf_itemnf_comb(i).nro_item );
      end loop;
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_ItemNF_Comb fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_ItemNF_Comb;
--
-- ============================================================================================================================================= --
-- Procedimento de informações de impostos do item da nota fiscal - campos flex field
procedure pkb_ler_Imp_ItemNf_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                , en_notafiscal_id          in             nota_fiscal.id%type
                                , en_impitemnf_id           in             imp_itemnf.id%type
                                --| parâmetros de chave
                                , ev_cpf_cnpj_emit          in             varchar2
                                , en_dm_ind_emit            in             number
                                , en_dm_ind_oper            in             number
                                , ev_cod_part               in             varchar2
                                , ev_cod_mod                in             varchar2
                                , ev_serie                  in             varchar2
                                , en_nro_nf                 in             number
                                , en_nro_item               in             number
                                , en_cod_imposto            in             number
                                , en_dm_tipo                in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_IMP_ITEMNF_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_IMPOSTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TIPO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_IMP_ITEMNF_FF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS || ' = ' || en_nro_item;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_IMPOSTO' || GV_ASPAS || ' = ' || en_cod_imposto;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_TIPO' || GV_ASPAS || ' = ' || en_dm_tipo;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_IMP_ITEMNF_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_imp_itemnf_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Imp_ItemNF_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_imp_itemnf_ff.count > 0 then
      --
      for i in vt_tab_csf_imp_itemnf_ff.first..vt_tab_csf_imp_itemnf_ff.last loop
         --
         vn_fase := 7;
         -- Chama o procedimento que integra as informações do Imposto ICMS - Campos Flex Field
         pk_csf_api_nfce.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => en_impitemnf_id
                                             , ev_atributo         => vt_tab_csf_imp_itemnf_ff(i).atributo
                                             , ev_valor            => vt_tab_csf_imp_itemnf_ff(i).valor
                                             , en_multorg_id       => gn_multorg_id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_imp_itemnf_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Imp_ItemNf_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de informações de impostos do item da nota fiscal
procedure pkb_ler_Imp_ItemNf ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                             , en_itemnf_id              in             Item_Nota_Fiscal.id%TYPE
                             , en_empresa_id             in             empresa.id%type
                             --| parâmetros de chave
                             , ev_cpf_cnpj_emit          in             varchar2
                             , en_dm_ind_emit            in             number
                             , en_dm_ind_oper            in             number
                             , ev_cod_part               in             varchar2
                             , ev_cod_mod                in             varchar2
                             , ev_serie                  in             varchar2
                             , en_nro_nf                 in             number
                             , en_nro_item               in             number ) is
   --
   vn_fase number := 0;
   i       pls_integer;
   vn_dm_util_epropria          param_empr_calc_fiscal.dm_util_epropria%type;
   vn_dm_util_eterceiro         param_empr_calc_fiscal.dm_util_eterceiro%type;
   vn_dm_mod_base_calc_st       item_nota_fiscal.dm_mod_base_calc_st%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_IMP_ITEMNF') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 1.1;
   --
   if en_dm_ind_emit = 0 then -- Emissão Propria
      --
      vn_dm_util_epropria := pk_csf_calc_fiscal.fkg_empr_util_epropria ( en_empresa_id => en_empresa_id );
      vn_dm_util_eterceiro := 0;
      --
   else
      --
      vn_dm_util_epropria := 0;
      vn_dm_util_eterceiro := pk_csf_calc_fiscal.fkg_empr_util_eterceiro ( en_empresa_id => en_empresa_id );
      --
   end if;
   --
   vn_fase := 1.2;
   --
   if nvl(vn_dm_util_epropria,0) = 1 -- Sim, utiliza Calculadora Fiscal, não integra os impostos
      or nvl(vn_dm_util_eterceiro,0) = 1
      then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         GV_ASPAS || 'CPF_CNPJ_EMIT'    || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART'         || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD'          || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF'           || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM'         || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_IMPOSTO'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TIPO'          || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_ST'           || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BASE_CALC'     || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ALIQ_APLI'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_IMP_TRIB'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'PERC_REDUC'       || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'PERC_ADIC'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'QTDE_BASE_CALC_PROD' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ALIQ_PROD'     || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'PERC_BC_OPER_PROP'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'UFST'             || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BC_ST_RET'     || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ICMSST_RET'    || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BC_ST_DEST'    || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ICMSST_DEST'   || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_IMP_ITEMNF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD'  || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE'    || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'   || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS || ' = ' || en_nro_item;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_IMP_ITEMNF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_imp_itemnf;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Imp_ItemNF fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_imp_itemnf.count > 0 then
      --
      for i in vt_tab_csf_imp_itemnf.first..vt_tab_csf_imp_itemnf.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_Imp_ItemNf := null;
         --
         pk_csf_api_nfce.gt_row_Imp_ItemNf.itemnf_id            := en_itemnf_id;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.dm_tipo              := vt_tab_csf_imp_itemnf(i).dm_tipo;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_base_calc         := vt_tab_csf_imp_itemnf(i).vl_base_calc;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.aliq_apli            := vt_tab_csf_imp_itemnf(i).aliq_apli;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_imp_trib          := vt_tab_csf_imp_itemnf(i).vl_imp_trib;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.perc_reduc           := vt_tab_csf_imp_itemnf(i).perc_reduc;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.perc_adic            := vt_tab_csf_imp_itemnf(i).perc_adic;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.qtde_base_calc_prod  := vt_tab_csf_imp_itemnf(i).qtde_base_calc_prod;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_aliq_prod         := vt_tab_csf_imp_itemnf(i).vl_aliq_prod;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.perc_bc_oper_prop    := vt_tab_csf_imp_itemnf(i).PERC_BC_OPER_PROP;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_bc_st_ret         := vt_tab_csf_imp_itemnf(i).VL_BC_ST_RET;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_icmsst_ret        := vt_tab_csf_imp_itemnf(i).VL_ICMSST_RET;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_bc_st_dest        := vt_tab_csf_imp_itemnf(i).VL_BC_ST_DEST;
         pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_icmsst_dest       := vt_tab_csf_imp_itemnf(i).VL_ICMSST_DEST;
         --
         if vt_tab_csf_imp_itemnf(i).COD_IMPOSTO = 7 then -- Imposto de Importação
            --
            pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_base_calc := nvl(pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_base_calc,0);
            pk_csf_api_nfce.gt_row_Imp_ItemNf.aliq_apli := nvl(pk_csf_api_nfce.gt_row_Imp_ItemNf.aliq_apli,0);
            pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_imp_trib := nvl(pk_csf_api_nfce.gt_row_Imp_ItemNf.vl_imp_trib,0);
	     --
         end if;
         --
         vn_fase := 7.1;
         --
         begin
            select inf.dm_mod_base_calc_st
              into vn_dm_mod_base_calc_st
              from item_nota_fiscal inf
             where inf.id = en_itemnf_id;
         exception
            when others then
               vn_dm_mod_base_calc_st := null;
         end;
         --
         if nvl(vn_dm_mod_base_calc_st,4) in (0, 1, 2, 3, 4, 5) and
            trim(vt_tab_csf_imp_itemnf(i).cod_st) in ('10', '30', '60', '70', '90') and
            vt_tab_csf_imp_itemnf(i).COD_IMPOSTO IN (1,2) and  -- ICMS  / ICMS-ST
            nvl(pk_csf_api_nfce.gt_row_Imp_ItemNf.perc_adic,0) = 0 then
            --
            pk_csf_api_nfce.gt_row_Imp_ItemNf.perc_adic := null;  -- colocado para não ocorrer erro no XML
            --
         end if;
         --
         vn_fase := 8;
         -- Chama o procedimento que integra as informações do Imposto ICMS
         pk_csf_api_nfce.pkb_integr_Imp_ItemNf ( est_log_generico_nf  => est_log_generico_nf
                                          , est_row_imp_itemnf   => pk_csf_api_nfce.gt_row_imp_itemnf
                                          , en_cd_imp            => vt_tab_csf_imp_itemnf(i).cod_imposto
                                          , ev_cod_st            => trim(vt_tab_csf_imp_itemnf(i).cod_st)
                                          , en_notafiscal_id     => en_notafiscal_id
                                          , ev_sigla_estado      => upper(trim(vt_tab_csf_imp_itemnf(i).ufst)) );
         --
         vn_fase := 9;
         -- Leitura de informações de impostos do item da nota fiscal - campos flex field
         pkb_ler_Imp_ItemNf_ff ( est_log_generico_nf  => est_log_generico_nf
                               , en_notafiscal_id     => en_notafiscal_id
                               , en_impitemnf_id      => pk_csf_api_nfce.gt_row_imp_itemnf.id
                               --| parâmetros de chave
                               , ev_cpf_cnpj_emit     => vt_tab_csf_imp_itemnf(i).cpf_cnpj_emit
                               , en_dm_ind_emit       => vt_tab_csf_imp_itemnf(i).dm_ind_emit
                               , en_dm_ind_oper       => vt_tab_csf_imp_itemnf(i).dm_ind_oper
                               , ev_cod_part          => vt_tab_csf_imp_itemnf(i).cod_part
                               , ev_cod_mod           => vt_tab_csf_imp_itemnf(i).cod_mod
                               , ev_serie             => vt_tab_csf_imp_itemnf(i).serie
                               , en_nro_nf            => vt_tab_csf_imp_itemnf(i).nro_nf
                               , en_nro_item          => vt_tab_csf_imp_itemnf(i).nro_item
                               , en_cod_imposto       => vt_tab_csf_imp_itemnf(i).cod_imposto
                               , en_dm_tipo           => vt_tab_csf_imp_itemnf(i).dm_tipo );
         --
         vn_fase := 10;
         -- Chama o procedimento que integra as informações do Grupo de Tributação do Imposto ICMS para UF do destinatário.
         -- A VIEW VW_CSF_IMP_ITEMNF_ICMS_DEST NÃO ESTÁ SENDO USADA
         /*pkb_ler_imp_itemnficmsdest ( est_log_generico_nf  => est_log_generico_nf
                                    , en_notafiscal_id     => en_notafiscal_id
                                    , en_impitemnf_id      => pk_csf_api_nfce.gt_row_imp_itemnf.id
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit     => vt_tab_csf_imp_itemnf(i).cpf_cnpj_emit
                                    , en_dm_ind_emit       => vt_tab_csf_imp_itemnf(i).dm_ind_emit
                                    , en_dm_ind_oper       => vt_tab_csf_imp_itemnf(i).dm_ind_oper
                                    , ev_cod_part          => vt_tab_csf_imp_itemnf(i).cod_part
                                    , ev_cod_mod           => vt_tab_csf_imp_itemnf(i).cod_mod
                                    , ev_serie             => vt_tab_csf_imp_itemnf(i).serie
                                    , en_nro_nf            => vt_tab_csf_imp_itemnf(i).nro_nf
                                    , en_nro_item          => vt_tab_csf_imp_itemnf(i).nro_item
                                    , en_cod_imposto       => vt_tab_csf_imp_itemnf(i).cod_imposto
                                    , en_dm_tipo           => vt_tab_csf_imp_itemnf(i).dm_tipo );*/
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Imp_ItemNf fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Imp_ItemNf;
--
-- ============================================================================================================================================= --
-- Procedimento de Leitura informações dos itens da nota fiscal - campos flex field
procedure pkb_ler_Item_Nota_Fiscal_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id          in             nota_fiscal.id%TYPE
                                      , en_itemnotafiscal_id      in             item_nota_fiscal.id%TYPE
                                    --| parâmetros de chave
                                      , ev_cpf_cnpj_emit          in             varchar2
                                      , en_dm_ind_emit            in             number
                                      , en_dm_ind_oper            in             number
                                      , ev_cod_part               in             varchar2
                                      , ev_cod_mod                in             varchar2
                                      , ev_serie                  in             varchar2
                                      , en_nro_nf                 in             number
                                      , en_nro_item               in             number
                                      , ev_cod_item               in             varchar2 ) is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEM_NOTA_FISCAL_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEM_NOTA_FISCAL_FF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS || ' = ' || en_nro_item;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_ITEM' || GV_ASPAS || ' = ' || '''' || ev_cod_item || '''';
   gv_sql := gv_sql || ' order by  ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEM_NOTA_FISCAL_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_item_nota_fiscal_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Item_Nota_Fiscal_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_item_nota_fiscal_ff.count > 0 then
      --
      for i in vt_tab_csf_item_nota_fiscal_ff.first..vt_tab_csf_item_nota_fiscal_ff.last loop
         --
         vn_fase := 7;
         -- Chama procedimento que faz a validação dos itens da Nota Fiscal - campos flex field.
         pk_csf_api_nfce.pkb_integr_Item_Nota_Fiscal_ff ( est_log_generico_nf     => est_log_generico_nf
                                                   , en_notafiscal_id     => en_notafiscal_id
                                                   , en_itemnotafiscal_id => en_itemnotafiscal_id
                                                   , ev_atributo          => vt_tab_csf_item_nota_fiscal_ff(i).atributo
                                                   , ev_valor             => vt_tab_csf_item_nota_fiscal_ff(i).valor );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Item_Nota_Fiscal_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Item_Nota_Fiscal_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de Leitura informações dos itens da nota fiscal
procedure pkb_ler_Item_Nota_Fiscal ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                   , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                                   , en_empresa_id             in             empresa.id%type
                                   --| parâmetros de chave
                                   , ev_cpf_cnpj_emit          in             varchar2
                                   , en_dm_ind_emit            in             number
                                   , en_dm_ind_oper            in             number
                                   , ev_cod_part               in             varchar2
                                   , ev_cod_mod                in             varchar2
                                   , ev_serie                  in             varchar2
                                   , en_nro_nf                 in             number ) is
   --
   vn_fase      number := 0;
   i            pls_integer;
   vn_nro_item  item_nota_fiscal.nro_item%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEM_NOTA_FISCAL') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', PK_CSF.FKG_CONVERTE(' || GV_ASPAS || 'COD_ITEM' || GV_ASPAS || ')';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_MOV' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CEAN' || GV_ASPAS;
   gv_sql := gv_sql || ', PK_CSF.FKG_CONVERTE(' || GV_ASPAS || 'DESCR_ITEM' || GV_ASPAS || ')';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_NCM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'GENERO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_EXT_IPI' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CFOP' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'UNID_COM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'QTDE_COMERC' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_UNIT_COMERC' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ITEM_BRUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CEAN_TRIB' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'UNID_TRIB' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'QTDE_TRIB' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_UNIT_TRIB' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_FRETE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_SEGURO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_DESC' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_OUTRO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_TOT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'INFADPROD' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ORIG' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_MOD_BASE_CALC' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_MOD_BASE_CALC_ST' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CNPJ_PRODUTOR' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'QTDE_SELO_IPI' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_DESP_ADU' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_IOF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CL_ENQ_IPI' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_SELO_IPI' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_ENQ_IPI' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CIDADE_IBGE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CD_LISTA_SERV' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_APUR_IPI' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_CTA' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'PEDIDO_COMPRA' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ITEM_PEDIDO_COMPRA' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_MOT_DES_ICMS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_COD_TRIB_ISSQN' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEM_NOTA_FISCAL');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' order by  ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEM_NOTA_FISCAL' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_item_nota_fiscal;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Item_Nota_Fiscal fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_item_nota_fiscal.count > 0 then
      --
      vn_nro_item := 0;
      --
      for i in vt_tab_csf_item_nota_fiscal.first..vt_tab_csf_item_nota_fiscal.last loop
         --
         vn_fase := 7;
         --
         vn_nro_item := nvl(vn_nro_item,0) + 1;
         --
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal := null;
         --
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.notafiscal_id        := en_notafiscal_id;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.nro_item             := vn_nro_item;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cod_item             := trim(vt_tab_csf_item_nota_fiscal(i).cod_item);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.dm_ind_mov           := vt_tab_csf_item_nota_fiscal(i).dm_ind_mov;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cean                 := trim(vt_tab_csf_item_nota_fiscal(i).cean);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.descr_item           := trim(vt_tab_csf_item_nota_fiscal(i).descr_item);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cod_ncm              := trim(vt_tab_csf_item_nota_fiscal(i).cod_ncm);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.genero               := vt_tab_csf_item_nota_fiscal(i).genero;
         --
         if trim(pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.genero) is null then
            pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.genero := substr(pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cod_ncm, 1, 2);
         end if;
         --
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cod_ext_ipi          := trim(vt_tab_csf_item_nota_fiscal(i).cod_ext_ipi);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cfop                 := vt_tab_csf_item_nota_fiscal(i).cfop;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.unid_com             := trim(vt_tab_csf_item_nota_fiscal(i).unid_com);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.qtde_comerc          := vt_tab_csf_item_nota_fiscal(i).qtde_comerc;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.vl_unit_comerc       := vt_tab_csf_item_nota_fiscal(i).vl_unit_comerc;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.vl_item_bruto        := vt_tab_csf_item_nota_fiscal(i).vl_item_bruto;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cean_trib            := trim(vt_tab_csf_item_nota_fiscal(i).cean_trib);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.unid_trib            := trim(vt_tab_csf_item_nota_fiscal(i).unid_trib);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.qtde_trib            := vt_tab_csf_item_nota_fiscal(i).qtde_trib;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.vl_unit_trib         := vt_tab_csf_item_nota_fiscal(i).vl_unit_trib;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.vl_frete             := vt_tab_csf_item_nota_fiscal(i).vl_frete;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.vl_seguro            := vt_tab_csf_item_nota_fiscal(i).vl_seguro;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.vl_desc              := vt_tab_csf_item_nota_fiscal(i).vl_desc;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.VL_OUTRO             := vt_tab_csf_item_nota_fiscal(i).VL_OUTRO;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.DM_IND_TOT           := vt_tab_csf_item_nota_fiscal(i).DM_IND_TOT;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.infadprod            := trim(vt_tab_csf_item_nota_fiscal(i).infadprod);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.orig                 := vt_tab_csf_item_nota_fiscal(i).orig;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.dm_mod_base_calc     := vt_tab_csf_item_nota_fiscal(i).dm_mod_base_calc;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.dm_mod_base_calc_st  := vt_tab_csf_item_nota_fiscal(i).dm_mod_base_calc_st;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cnpj_produtor        := trim(vt_tab_csf_item_nota_fiscal(i).cnpj_produtor);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.qtde_selo_ipi        := vt_tab_csf_item_nota_fiscal(i).qtde_selo_ipi;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.vl_desp_adu          := vt_tab_csf_item_nota_fiscal(i).vl_desp_adu;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.vl_iof               := vt_tab_csf_item_nota_fiscal(i).vl_iof;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cl_enq_ipi           := trim(vt_tab_csf_item_nota_fiscal(i).cl_enq_ipi);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cod_selo_ipi         := trim(vt_tab_csf_item_nota_fiscal(i).cod_selo_ipi);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cod_enq_ipi          := trim(vt_tab_csf_item_nota_fiscal(i).cod_enq_ipi);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cidade_ibge          := vt_tab_csf_item_nota_fiscal(i).cidade_ibge;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cd_lista_serv        := vt_tab_csf_item_nota_fiscal(i).cd_lista_serv;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.dm_ind_apur_ipi      := vt_tab_csf_item_nota_fiscal(i).dm_ind_apur_ipi;
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.cod_cta              := trim(vt_tab_csf_item_nota_fiscal(i).cod_cta);
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.PEDIDO_COMPRA        := trim(vt_tab_csf_item_nota_fiscal(i).PEDIDO_COMPRA);
         --
         if nvl(vt_tab_csf_item_nota_fiscal(i).ITEM_PEDIDO_COMPRA,0) = 0 then
            pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.ITEM_PEDIDO_COMPRA   := null;
         else
            pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.ITEM_PEDIDO_COMPRA   := vt_tab_csf_item_nota_fiscal(i).ITEM_PEDIDO_COMPRA;
         end if;
         --
         if nvl(vt_tab_csf_item_nota_fiscal(i).DM_MOT_DES_ICMS,0) = 0 then
            pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.DM_MOT_DES_ICMS      := null;
         else
            pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.DM_MOT_DES_ICMS      := vt_tab_csf_item_nota_fiscal(i).DM_MOT_DES_ICMS;
         end if;
         --
         pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.DM_COD_TRIB_ISSQN    := trim(vt_tab_csf_item_nota_fiscal(i).DM_COD_TRIB_ISSQN);
         --
         vn_fase := 8;
         -- Chama procedimento que faz a validação dos itens da Nota Fiscal
         pk_csf_api_nfce.pkb_integr_Item_Nota_Fiscal ( est_log_generico_nf          => est_log_generico_nf
                                                , est_row_Item_Nota_Fiscal  => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal
                                                , en_multorg_id             => gn_multorg_id );
         --
         vn_fase := 9;
         --
         pkb_ler_Item_Nota_Fiscal_ff ( est_log_generico_nf      => est_log_generico_nf
                                     , en_notafiscal_id      => en_notafiscal_id
                                     , en_itemnotafiscal_id  => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                                     --| parâmetros de chave
                                     , ev_cpf_cnpj_emit      => ev_cpf_cnpj_emit
                                     , en_dm_ind_emit        => en_dm_ind_emit
                                     , en_dm_ind_oper        => en_dm_ind_oper
                                     , ev_cod_part           => ev_cod_part
                                     , ev_cod_mod            => ev_cod_mod
                                     , ev_serie              => ev_serie
                                     , en_nro_nf             => en_nro_nf
                                     , en_nro_item           => vt_tab_csf_item_nota_fiscal(i).nro_item
                                     , ev_cod_item           => vt_tab_csf_item_nota_fiscal(i).cod_item
                                     );
         --
         vn_fase := 9.1;
         -- Leitura de informações de impostos do item da nota fiscal
         pkb_ler_Imp_ItemNf ( est_log_generico_nf          => est_log_generico_nf
                            , en_notafiscal_id          => en_notafiscal_id
                            , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                            , en_empresa_id             => en_empresa_id
                          --| parâmetros de chave
                            , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                            , en_dm_ind_emit            => en_dm_ind_emit
                            , en_dm_ind_oper            => en_dm_ind_oper
                            , ev_cod_part               => ev_cod_part
                            , ev_cod_mod                => ev_cod_mod
                            , ev_serie                  => ev_serie
                            , en_nro_nf                 => en_nro_nf
                            , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
                            );
         --
         vn_fase := 10;
         -- Leitura de registros do detalhamento do NCM: NVE
         --  A VIEW VW_CSF_ITEMNF_NVE NAO ESTA SENDO USADA
         /*pkb_ler_itemnf_nve ( est_log_generico_nf          => est_log_generico_nf
                            , en_notafiscal_id          => en_notafiscal_id
                            , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                          --| parâmetros de chave
                            , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                            , en_dm_ind_emit            => en_dm_ind_emit
                            , en_dm_ind_oper            => en_dm_ind_oper
                            , ev_cod_part               => ev_cod_part
                            , ev_cod_mod                => ev_cod_mod
                            , ev_serie                  => ev_serie
                            , en_nro_nf                 => en_nro_nf
                            , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
                            );*/
         --
         vn_fase := 11;
         -- Leitura de registros do detalhamento do Controle de Exportação por Item
         --  A VIEW VW_CSF_ITEMNF_EXPORT NAO ESTA SENDO USADA 
         /*pkb_ler_itemnf_export ( est_log_generico_nf          => est_log_generico_nf
                                , en_notafiscal_id          => en_notafiscal_id
                                , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                              --| parâmetros de chave
                                , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                                , en_dm_ind_emit            => en_dm_ind_emit
                                , en_dm_ind_oper            => en_dm_ind_oper
                                , ev_cod_part               => ev_cod_part
                                , ev_cod_mod                => ev_cod_mod
                                , ev_serie                  => ev_serie
                                , en_nro_nf                 => en_nro_nf
                                , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
                                );*/
         --
         vn_fase := 12;
         -- Leitura de registros de combustíveis do item da nota fiscal
         pkb_ler_ItemNF_Comb ( est_log_generico_nf          => est_log_generico_nf
                             , en_notafiscal_id          => en_notafiscal_id
                             , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                           --| parâmetros de chave
                             , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                             , en_dm_ind_emit            => en_dm_ind_emit
                             , en_dm_ind_oper            => en_dm_ind_oper
                             , ev_cod_part               => ev_cod_part
                             , ev_cod_mod                => ev_cod_mod
                             , ev_serie                  => ev_serie
                             , en_nro_nf                 => en_nro_nf
                             , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
                             );
         --
         vn_fase := 13;
         -- Leitura de informações de veículos do item da nota fiscal
         --  A VIEW VW_CSF_ITEMNF_VEIC NÃO ESTÁ SENDO USADA 
         /*pkb_ler_ItemNF_Veic ( est_log_generico_nf          => est_log_generico_nf
                             , en_notafiscal_id          => en_notafiscal_id
                             , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                           --| parâmetros de chave
                             , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                             , en_dm_ind_emit            => en_dm_ind_emit
                             , en_dm_ind_oper            => en_dm_ind_oper
                             , ev_cod_part               => ev_cod_part
                             , ev_cod_mod                => ev_cod_mod
                             , ev_serie                  => ev_serie
                             , en_nro_nf                 => en_nro_nf
                             , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
                             );*/
         --
         vn_fase := 14;
         -- Leitura de informações de medicamentos da nota fiscal
         pkb_ler_ItemNF_Med ( est_log_generico_nf          => est_log_generico_nf
                            , en_notafiscal_id          => en_notafiscal_id
                            , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                          --| parâmetros de chave
                            , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                            , en_dm_ind_emit            => en_dm_ind_emit
                            , en_dm_ind_oper            => en_dm_ind_oper
                            , ev_cod_part               => ev_cod_part
                            , ev_cod_mod                => ev_cod_mod
                            , ev_serie                  => ev_serie
                            , en_nro_nf                 => en_nro_nf
                            , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
                            );
         --
         vn_fase := 15;
         -- Leitura de informações de armamentos do item da nota fiscal
         --  A VIEW VW_CSF_ITEMNF_ARMA  NAO ESTA SENDO USADA
         /*pkb_ler_ItemNF_Arma ( est_log_generico_nf          => est_log_generico_nf
                             , en_notafiscal_id          => en_notafiscal_id
                             , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                           --| parâmetros de chave
                             , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                             , en_dm_ind_emit            => en_dm_ind_emit
                             , en_dm_ind_oper            => en_dm_ind_oper
                             , ev_cod_part               => ev_cod_part
                             , ev_cod_mod                => ev_cod_mod
                             , ev_serie                  => ev_serie
                             , en_nro_nf                 => en_nro_nf
                             , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
                             );*/
         --
         vn_fase := 16;
         -- Leitura de informações de declarações de importação do item da nota fiscal
         --  A VIEW VW_CSF_ITEMNF_DEC_IMPOR  NAO ESTA SENDO USADA 
         /*pkb_ler_ItemNF_Dec_Impor ( est_log_generico_nf          => est_log_generico_nf
                                  , en_notafiscal_id          => en_notafiscal_id
                                  , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                                 --| parâmetros de chave
                                  , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                                  , en_dm_ind_emit            => en_dm_ind_emit
                                  , en_dm_ind_oper            => en_dm_ind_oper
                                  , ev_cod_part               => ev_cod_part
                                  , ev_cod_mod                => ev_cod_mod
                                  , ev_serie                  => ev_serie
                                  , en_nro_nf                 => en_nro_nf
                                  , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
                                  );*/
         --
         vn_fase := 17;
         -- Leitura de informações de declarações de importação do item da nota fiscal
         --  A VIEW VW_CSF_ITEMNF_COMPL_TRANSP NAO ESTA SENDO USADA 
         /*pkb_ler_ItemNF_Compl_transp ( est_log_generico_nf          => est_log_generico_nf
                                     , en_notafiscal_id          => en_notafiscal_id
                                     , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                                    --| parâmetros de chave
                                     , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                                     , en_dm_ind_emit            => en_dm_ind_emit
                                     , en_dm_ind_oper            => en_dm_ind_oper
                                     , ev_cod_part               => ev_cod_part
                                     , ev_cod_mod                => ev_cod_mod
                                     , ev_serie                  => ev_serie
                                     , en_nro_nf                 => en_nro_nf
                                     , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
                                     );*/
	       --
	       vn_fase := 18;
         -- leitura de Informações Complementares do Item da Nota Fiscal
         --  VIEW VW_CSF_ITEMNF_COMPL NÃO ESTA SENDO USADA 
/*         pkb_ler_itemnf_compl ( est_log_generico_nf          => est_log_generico_nf
                              , en_notafiscal_id          => en_notafiscal_id
			                        , en_itemnf_id              => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                              --| parâmetros de chave
                              , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                              , en_dm_ind_emit            => en_dm_ind_emit
                              , en_dm_ind_oper            => en_dm_ind_oper
                              , ev_cod_part               => ev_cod_part
                              , ev_cod_mod                => ev_cod_mod
                              , ev_serie                  => ev_serie
                              , en_nro_nf                 => en_nro_nf
                              , en_nro_item               => vt_tab_csf_item_nota_fiscal(i).nro_item
							  );
*/         --
         vn_fase := 19;
         -- leitura de informações do diferencial de aliquota do item da nota fiscal
         --  VIEW VW_CSF_ITEMNF_DIF_ALIQ NÃO ESTA SENDO USADA         
         /*pkb_ler_itemnf_dif_aliq ( est_log_generico_nf         => est_log_generico_nf
                                 , en_notafiscal_id         => en_notafiscal_id
                                 , en_itemnf_id             => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                                 --| parâmetros de chave
                                 , ev_cpf_cnpj_emit         => ev_cpf_cnpj_emit
                                 , en_dm_ind_emit           => en_dm_ind_emit
                                 , en_dm_ind_oper           => en_dm_ind_oper
                                 , ev_cod_part              => ev_cod_part
                                 , ev_cod_mod               => ev_cod_mod
                                 , ev_serie                 => ev_serie
                                 , en_nro_nf                => en_nro_nf
                                 , en_nro_item              => vt_tab_csf_item_nota_fiscal(i).nro_item
                                 );*/

         --
         vn_fase := 20;
         -- Leitura das informações complementares de serviço do item
         --  A VIEW VW_CSF_ITEMNFE_COMPL_SERV  NAO ESTA SENDO USADA
         /*pkb_ler_itemnfe_compl_serv ( est_log_generico_nf         => est_log_generico_nf
                                 , en_notafiscal_id         => en_notafiscal_id
                                 , en_itemnf_id             => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                                 --| parâmetros de chave
                                 , ev_cpf_cnpj_emit         => ev_cpf_cnpj_emit
                                 , en_dm_ind_emit           => en_dm_ind_emit
                                 , en_dm_ind_oper           => en_dm_ind_oper
                                 , ev_cod_part              => ev_cod_part
                                 , ev_cod_mod               => ev_cod_mod
                                 , ev_serie                 => ev_serie
                                 , en_nro_nf                => en_nro_nf
                                 , en_nro_item              => vt_tab_csf_item_nota_fiscal(i).nro_item
                                 );*/
         --
         vn_fase := 21;
         -- Leitura das informações de Rastreabilidade de produto
         pkb_ler_itemnf_rastreab ( est_log_generico_nf      => est_log_generico_nf
                                 , en_notafiscal_id         => en_notafiscal_id
                                 , en_itemnf_id             => pk_csf_api_nfce.gt_row_Item_Nota_Fiscal.id
                                 --| parâmetros de chave
                                 , ev_cpf_cnpj_emit         => ev_cpf_cnpj_emit
                                 , en_dm_ind_emit           => en_dm_ind_emit
                                 , en_dm_ind_oper           => en_dm_ind_oper
                                 , ev_cod_part              => ev_cod_part
                                 , ev_cod_mod               => ev_cod_mod
                                 , ev_serie                 => ev_serie
                                 , en_nro_nf                => en_nro_nf
                                 , en_nro_item              => vt_tab_csf_item_nota_fiscal(i).nro_item
                                 );
         --
         vn_fase := 22;
         -- Leitura das informações de Ressarcimento de ICMS em operações com substituição Tributária do Item da Nota Fiscal
         --  A VIEW VW_CSF_ITEMNF_RES_ICMS_ST NAO ESTA SENDO USADA 
         /*pkb_ler_itemnf_res_icms_st ( est_log_generico_nf      => est_log_generico_nf
                                    , en_notafiscal_id         => en_notafiscal_id
                                    , en_itemnf_id             => pk_csf_api_nfce.gt_row_item_nota_fiscal.id
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit         => ev_cpf_cnpj_emit
                                    , en_dm_ind_emit           => en_dm_ind_emit
                                    , en_dm_ind_oper           => en_dm_ind_oper
                                    , ev_cod_part              => ev_cod_part
                                    , ev_cod_mod               => ev_cod_mod
                                    , ev_serie                 => ev_serie
                                    , en_nro_nf                => en_nro_nf
                                    , en_nro_item              => vt_tab_csf_item_nota_fiscal(i).nro_item
                                    );*/
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Item_Nota_Fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Item_Nota_Fiscal;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de informações do transporte da nota fiscal
procedure pkb_ler_Nota_Fiscal_Transp ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                     , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                                     --| parâmetros de chave
                                     , ev_cpf_cnpj_emit          in             varchar2
                                     , en_dm_ind_emit            in             number
                                     , en_dm_ind_oper            in             number
                                     , ev_cod_part               in             varchar2
                                     , ev_cod_mod                in             varchar2
                                     , ev_serie                  in             varchar2
                                     , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_TRANSP') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_MOD_FRETE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CNPJ_CPF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART_TRANSP' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NOME' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'IE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ENDER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CIDADE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CIDADE_IBGE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'UF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_SERV' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BASECALC_RET' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ALIQICMS_RET' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_ICMS_RET' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CFOP' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CPF_MOT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NOME_MOT' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_TRANSP');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_TRANSP' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_transp;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Transp fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => gv_resumo || gv_cabec_nf
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_transp.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_transp.first..vt_tab_csf_nota_fiscal_transp.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp := null;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.notafiscal_id    := en_notafiscal_id;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.dm_mod_frete     := vt_tab_csf_nota_fiscal_transp(i).dm_mod_frete;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.cnpj_cpf         := trim(vt_tab_csf_nota_fiscal_transp(i).cnpj_cpf);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.nome             := trim(vt_tab_csf_nota_fiscal_transp(i).nome);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.ie               := trim(vt_tab_csf_nota_fiscal_transp(i).ie);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.ender            := trim(vt_tab_csf_nota_fiscal_transp(i).ender);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.cidade           := trim(vt_tab_csf_nota_fiscal_transp(i).cidade);
         --
         if nvl(vt_tab_csf_nota_fiscal_transp(i).cidade_ibge,0) = 0 then
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.cidade_ibge      := null;
         else
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.cidade_ibge      := vt_tab_csf_nota_fiscal_transp(i).cidade_ibge;
         end if;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.uf               := trim(vt_tab_csf_nota_fiscal_transp(i).uf);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.vl_serv          := vt_tab_csf_nota_fiscal_transp(i).vl_serv;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.vl_basecalc_ret  := vt_tab_csf_nota_fiscal_transp(i).vl_basecalc_ret;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.aliqicms_ret     := vt_tab_csf_nota_fiscal_transp(i).aliqicms_ret;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.vl_icms_ret      := vt_tab_csf_nota_fiscal_transp(i).vl_icms_ret;
         --
         if nvl(vt_tab_csf_nota_fiscal_transp(i).cfop,0) = 0 then
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.cfop             := null;
         else
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.cfop             := vt_tab_csf_nota_fiscal_transp(i).cfop;
         end if;
         --
         if nvl(vt_tab_csf_nota_fiscal_transp(i).cpf_mot,0) = 0 then
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.cpf_mot          := null;
         else
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.cpf_mot          := vt_tab_csf_nota_fiscal_transp(i).cpf_mot;
         end if;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.nome_mot         := trim(vt_tab_csf_nota_fiscal_transp(i).nome_mot);
         --
         vn_fase := 8;
         -- Chama procedimento que válida as informações de transporte
         pk_csf_api_nfce.pkb_integr_Nota_Fiscal_Transp ( est_log_generico_nf            => est_log_generico_nf
                                                  , est_row_Nota_Fiscal_Transp  => pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp
                                                  , en_multorg_id               => gn_multorg_id );
         --
         vn_fase := 9;
         -- Leitura de informações de veículos utilizados no transporte da nota fiscal
         --  A VIEW VW_CSF_NFTRANSP_VEIC NAO ESTA SENDO UTILIZADA
         /*pkb_ler_NFTransp_Veic ( est_log_generico_nf          => est_log_generico_nf
                               , en_notafiscal_id          => en_notafiscal_id
                               , en_nftransp_id            => pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.id
                             --| parâmetros de chave
                               , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                               , en_dm_ind_emit            => en_dm_ind_emit
                               , en_dm_ind_oper            => en_dm_ind_oper
                               , ev_cod_part               => ev_cod_part
                               , ev_cod_mod                => ev_cod_mod
                               , ev_serie                  => ev_serie
                               , en_nro_nf                 => en_nro_nf );*/
         --
         vn_fase := 10;
         -- Leitura de informações de volumes de transporte da nota fiscal
         --  A VIEW VW_CSF_NFTRANSP_VOL NAO ESTA SENDO UTILIZADA
         /*pkb_ler_NFTransp_Vol ( est_log_generico_nf          => est_log_generico_nf
                              , en_notafiscal_id          => en_notafiscal_id
                              , en_nftransp_id            => pk_csf_api_nfce.gt_row_Nota_Fiscal_Transp.id
                            --| parâmetros de chave
                              , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                              , en_dm_ind_emit            => en_dm_ind_emit
                              , en_dm_ind_oper            => en_dm_ind_oper
                              , ev_cod_part               => ev_cod_part
                              , ev_cod_mod                => ev_cod_mod
                              , ev_serie                  => ev_serie
                              , en_nro_nf                 => en_nro_nf );*/
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Transp fase(' || vn_fase || ' nro_nf: ' || en_nro_nf || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Transp;
--
-- ============================================================================================================================================= --
-- Procedimento de Nota Fiscal Local - Flex-Field
procedure pkb_ler_Nota_Fiscal_Local_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id          in             Nota_Fiscal_local.notafiscal_id%TYPE
                                       , en_notafiscallocal_id     in             Nota_Fiscal_local.id%TYPE
                                       --| parâmetros de chave
                                       , ev_cpf_cnpj_emit          in             varchar2
                                       , en_dm_ind_emit            in             number
                                       , en_dm_ind_oper            in             number
                                       , ev_cod_part               in             varchar2
                                       , ev_cod_mod                in             varchar2
                                       , ev_serie                  in             varchar2
                                       , en_nro_nf                 in             number
                                       , en_dm_tipo_local          in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_LOCAL_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD'       || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TIPO_LOCAL' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR'         || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_LOCAL_FF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD'       || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE'         || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'        || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_TIPO_LOCAL' || GV_ASPAS || ' = ' || en_dm_tipo_local;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_LOCAL_FF' || chr(10);
   --
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_localff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Local_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_localff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_localff.first..vt_tab_csf_nota_fiscal_localff.last loop
         --
         vn_fase := 7;
         -- Chama procedimento que valida as informações da Forma do Pagamento - Campos Flex Field
         pk_csf_api_nfce.pkb_integr_nota_fiscal_localff ( est_log_generico_nf    => est_log_generico_nf
                                                   , en_notafiscal_id       => en_notafiscal_id
                                                   , en_notafiscallocal_id  => en_notafiscallocal_id
                                                   , ev_atributo            => vt_tab_csf_nota_fiscal_localff(i).atributo
                                                   , ev_valor               => vt_tab_csf_nota_fiscal_localff(i).valor );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Local_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => gv_cabec_nf
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Local_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de informações do local de coleta e entrega da nota fiscal
procedure pkb_ler_Nota_Fiscal_Local ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit          in             varchar2
                                    , en_dm_ind_emit            in             number
                                    , en_dm_ind_oper            in             number
                                    , ev_cod_part               in             varchar2
                                    , ev_cod_mod                in             varchar2
                                    , ev_serie                  in             varchar2
                                    , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_LOCAL') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART'      || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD'       || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TIPO_LOCAL' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CNPJ'          || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'LOGRAD'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO'           || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COMPL'         || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'BAIRRO'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CIDADE'        || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CIDADE_IBGE'   || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'UF'            || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_CARGA'  || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CPF'           || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'IE'            || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_LOCAL');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_LOCAL' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_local;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Local fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_local.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_local.first..vt_tab_csf_nota_fiscal_local.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local := null;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.notafiscal_id  := en_notafiscal_id;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.dm_tipo_local  := vt_tab_csf_nota_fiscal_local(i).dm_tipo_local;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.cnpj           := trim(vt_tab_csf_nota_fiscal_local(i).cnpj);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.lograd         := trim(vt_tab_csf_nota_fiscal_local(i).lograd);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.nro            := trim(vt_tab_csf_nota_fiscal_local(i).nro);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.compl          := trim(vt_tab_csf_nota_fiscal_local(i).compl);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.bairro         := trim(vt_tab_csf_nota_fiscal_local(i).bairro);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.cidade         := trim(vt_tab_csf_nota_fiscal_local(i).cidade);
         --
         if nvl(vt_tab_csf_nota_fiscal_local(i).cidade_ibge,0) = 0 then
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.cidade_ibge    := null;
         else
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.cidade_ibge    := vt_tab_csf_nota_fiscal_local(i).cidade_ibge;
         end if;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.uf             := upper(trim(vt_tab_csf_nota_fiscal_local(i).uf));
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.dm_ind_carga   := vt_tab_csf_nota_fiscal_local(i).dm_ind_carga;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.cpf            := trim(vt_tab_csf_nota_fiscal_local(i).cpf);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.ie             := trim(vt_tab_csf_nota_fiscal_local(i).ie);
         --
         vn_fase := 8;
         -- Chama procedimento que válida as informações do Local Coleta/Entrega
         pk_csf_api_nfce.pkb_integr_Nota_Fiscal_Local ( est_log_generico_nf        => est_log_generico_nf
                                                 , est_row_Nota_Fiscal_Local  => pk_csf_api_nfce.gt_row_Nota_Fiscal_Local );
         --
         vn_fase := 9;
         --
         --| Procedimento de Nota Fiscal Local - Flex-Field
         --
         pkb_ler_Nota_Fiscal_Local_ff ( est_log_generico_nf       => est_log_generico_nf
                                      , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.notafiscal_id
                                      , en_notafiscallocal_id     => pk_csf_api_nfce.gt_row_Nota_Fiscal_Local.id
                                      --| parâmetros de chave
                                      , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal_local(i).cpf_cnpj_emit)
                                      , en_dm_ind_emit            => trim(vt_tab_csf_nota_fiscal_local(i).dm_ind_emit)
                                      , en_dm_ind_oper            => trim(vt_tab_csf_nota_fiscal_local(i).dm_ind_oper)
                                      , ev_cod_part               => trim(vt_tab_csf_nota_fiscal_local(i).cod_part)
                                      , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal_local(i).cod_mod)
                                      , ev_serie                  => trim(vt_tab_csf_nota_fiscal_local(i).serie)
                                      , en_nro_nf                 => trim(vt_tab_csf_nota_fiscal_local(i).nro_nf)
                                      , en_dm_tipo_local          => trim(vt_tab_csf_nota_fiscal_local(i).dm_tipo_local) );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Local fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => gv_resumo || gv_cabec_nf
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Local;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de informações adicionais da nota fiscal
procedure pkb_ler_NFInfor_Adic ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                               --| parâmetros de chave
                               , ev_cpf_cnpj_emit          in             varchar2
                               , en_dm_ind_emit            in             number
                               , en_dm_ind_oper            in             number
                               , ev_cod_part               in             varchar2
                               , ev_cod_mod                in             varchar2
                               , ev_serie                  in             varchar2
                               , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NFINFOR_ADIC') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TIPO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CAMPO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CONTEUDO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ORIG_PROC' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NFINFOR_ADIC');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NFINFOR_ADIC' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nfinfor_adic;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_NFInfor_Adic fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nfinfor_adic.count > 0 then
      --
      for i in vt_tab_csf_nfinfor_adic.first..vt_tab_csf_nfinfor_adic.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_NFInfor_Adic := null;
         --
         if trim(vt_tab_csf_nfinfor_adic(i).CONTEUDO) is not null then
            --
            pk_csf_api_nfce.gt_row_NFInfor_Adic.notafiscal_id      := en_notafiscal_id;
            pk_csf_api_nfce.gt_row_NFInfor_Adic.dm_tipo            := vt_tab_csf_nfinfor_adic(i).DM_TIPO;
            pk_csf_api_nfce.gt_row_NFInfor_Adic.campo              := trim(vt_tab_csf_nfinfor_adic(i).CAMPO);
            pk_csf_api_nfce.gt_row_NFInfor_Adic.conteudo           := trim(vt_tab_csf_nfinfor_adic(i).CONTEUDO);
            --
            vn_fase := 8;
            -- Chama o procedimento de validação dos dados da Informação Adicional da Nota Fiscal
            pk_csf_api_nfce.pkb_integr_NFInfor_Adic ( est_log_generico_nf          => est_log_generico_nf
                                               , est_row_NFInfor_Adic      => pk_csf_api_nfce.gt_row_NFInfor_Adic
                                               , en_cd_orig_proc           => vt_tab_csf_nfinfor_adic(i).ORIG_PROC );
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_NFInfor_Adic fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_NFInfor_Adic;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura dos totais da nota fiscal - campos Flex Field
procedure pkb_ler_Nota_Fiscal_Total_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id          in             Nota_Fiscal.id%TYPE
                                       , en_notafiscaltotal_id     in             nota_fiscal_total.id%type
                                       --| parâmetros de chave
                                       , ev_cpf_cnpj_emit          in             varchar2
                                       , en_dm_ind_emit            in             number
                                       , en_dm_ind_oper            in             number
                                       , ev_cod_part               in             varchar2
                                       , ev_cod_mod                in             varchar2
                                       , ev_serie                  in             varchar2
                                       , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_TOTAL_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_TOTAL_FF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_TOTAL_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_notafiscal_total_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Total_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_notafiscal_total_ff.count > 0 then
      --
      for i in vt_tab_csf_notafiscal_total_ff.first..vt_tab_csf_notafiscal_total_ff.last loop
         --
         vn_fase := 7;
         -- Chama o procedimento de validação dos dados dos Totais da Nota Fiscal
         pk_csf_api_nfce.pkb_integr_NotaFiscal_Total_ff ( est_log_generico_nf      => est_log_generico_nf
                                                   , en_notafiscal_id      => en_notafiscal_id
                                                   , en_notafiscaltotal_id => en_notafiscaltotal_id
                                                   , ev_atributo           => vt_tab_csf_notafiscal_total_ff(i).atributo
                                                   , ev_valor              => vt_tab_csf_notafiscal_total_ff(i).valor   );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_NotaFiscal_Total_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Total_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura dos totais da nota fiscal
procedure pkb_ler_Nota_Fiscal_Total ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit          in             varchar2
                                    , en_dm_ind_emit            in             number
                                    , en_dm_ind_oper            in             number
                                    , ev_cod_part               in             varchar2
                                    , ev_cod_mod                in             varchar2
                                    , ev_serie                  in             varchar2
                                    , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_TOTAL') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BASE_CALC_ICMS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_IMP_TRIB_ICMS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BASE_CALC_ST' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_IMP_TRIB_ST' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_TOTAL_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_FRETE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_SEGURO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_DESCONTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_IMP_TRIB_II' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_IMP_TRIB_IPI' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_IMP_TRIB_PIS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_IMP_TRIB_COFINS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_OUTRA_DESPESAS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_TOTAL_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_SERV_NAO_TRIB' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BASE_CALC_ISS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_IMP_TRIB_ISS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_PIS_ISS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_COFINS_ISS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_RET_PIS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_RET_COFINS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_RET_CSLL' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BASE_CALC_IRRF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_RET_IRRF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_BASE_CALC_RET_PREV' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_RET_PREV' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VL_TOTAL_SERV' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_TOTAL');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_TOTAL' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_total;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Total fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_total.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_total.first..vt_tab_csf_nota_fiscal_total.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total := null;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.notafiscal_id          := en_notafiscal_id;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_base_calc_icms      := vt_tab_csf_nota_fiscal_total(i).vl_base_calc_icms;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_imp_trib_icms       := vt_tab_csf_nota_fiscal_total(i).vl_imp_trib_icms;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_base_calc_st        := vt_tab_csf_nota_fiscal_total(i).vl_base_calc_st;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_imp_trib_st         := vt_tab_csf_nota_fiscal_total(i).vl_imp_trib_st;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_total_item          := vt_tab_csf_nota_fiscal_total(i).vl_total_item;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_frete               := vt_tab_csf_nota_fiscal_total(i).vl_frete;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_seguro              := vt_tab_csf_nota_fiscal_total(i).vl_seguro;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_desconto            := vt_tab_csf_nota_fiscal_total(i).vl_desconto;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_imp_trib_ii         := vt_tab_csf_nota_fiscal_total(i).vl_imp_trib_ii;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_imp_trib_ipi        := vt_tab_csf_nota_fiscal_total(i).vl_imp_trib_ipi;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_imp_trib_pis        := vt_tab_csf_nota_fiscal_total(i).vl_imp_trib_pis;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_imp_trib_cofins     := vt_tab_csf_nota_fiscal_total(i).vl_imp_trib_cofins;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_outra_despesas      := vt_tab_csf_nota_fiscal_total(i).vl_outra_despesas;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_total_nf            := vt_tab_csf_nota_fiscal_total(i).vl_total_nf;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_serv_nao_trib       := vt_tab_csf_nota_fiscal_total(i).vl_serv_nao_trib;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_base_calc_iss       := vt_tab_csf_nota_fiscal_total(i).vl_base_calc_iss;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_imp_trib_iss        := vt_tab_csf_nota_fiscal_total(i).vl_imp_trib_iss;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_pis_iss             := vt_tab_csf_nota_fiscal_total(i).vl_pis_iss;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_cofins_iss          := vt_tab_csf_nota_fiscal_total(i).vl_cofins_iss;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_ret_pis             := vt_tab_csf_nota_fiscal_total(i).vl_ret_pis;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_ret_cofins          := vt_tab_csf_nota_fiscal_total(i).vl_ret_cofins;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_ret_csll            := vt_tab_csf_nota_fiscal_total(i).vl_ret_csll;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_base_calc_irrf      := vt_tab_csf_nota_fiscal_total(i).vl_base_calc_irrf;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_ret_irrf            := vt_tab_csf_nota_fiscal_total(i).vl_ret_irrf;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_base_calc_ret_prev  := vt_tab_csf_nota_fiscal_total(i).vl_base_calc_ret_prev;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_ret_prev            := vt_tab_csf_nota_fiscal_total(i).vl_ret_prev;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.vl_total_serv          := vt_tab_csf_nota_fiscal_total(i).vl_total_serv;
         --
         vn_fase := 8;
         -- Chama o procedimento de validação dos dados dos Totais da Nota Fiscal
         pk_csf_api_nfce.pkb_integr_Nota_Fiscal_Total ( est_log_generico_nf           => est_log_generico_nf
                                                 , est_row_Nota_Fiscal_Total  => pk_csf_api_nfce.gt_row_Nota_Fiscal_Total );
         --
         vn_fase := 9;
         --
         pkb_ler_Nota_Fiscal_Total_ff ( est_log_generico_nf          => est_log_generico_nf
                                      , en_notafiscal_id          => en_notafiscal_id
                                      , en_notafiscaltotal_id     => pk_csf_api_nfce.gt_row_Nota_Fiscal_Total.id
                                      --| parâmetros de chave
                                      , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                                      , en_dm_ind_emit            => en_dm_ind_emit
                                      , en_dm_ind_oper            => en_dm_ind_oper
                                      , ev_cod_part               => ev_cod_part
                                      , ev_cod_mod                => ev_cod_mod
                                      , ev_serie                  => ev_serie
                                      , en_nro_nf                 => en_nro_nf);
       end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Total fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Total;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura do destinatário da nota fiscal
procedure pkb_ler_nfdest_email ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                               , en_notafiscaldest_id      in             nfdest_email.notafiscaldest_id%TYPE
                               --| parâmetros de chave
                               , ev_cpf_cnpj_emit          in             varchar2
                               , en_dm_ind_emit            in             number
                               , en_dm_ind_oper            in             number
                               , ev_cod_part               in             varchar2
                               , ev_cod_mod                in             varchar2
                               , ev_serie                  in             varchar2
                               , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NFDEST_EMAIL') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'EMAIL' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TIPO_ANEXO' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NFDEST_EMAIL');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NFDEST_EMAIL' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nfdest_email;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nfdest_email fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if nvl(vt_tab_csf_nfdest_email.count,0) > 0 then
      --
      for i in vt_tab_csf_nfdest_email.first..vt_tab_csf_nfdest_email.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_nfdest_email := null;
         --
         pk_csf_api_nfce.gt_row_nfdest_email.notafiscaldest_id  := en_notafiscaldest_id;
         pk_csf_api_nfce.gt_row_nfdest_email.email              := trim(vt_tab_csf_nfdest_email(i).email);
         pk_csf_api_nfce.gt_row_nfdest_email.dm_tipo_anexo      := trim(vt_tab_csf_nfdest_email(i).dm_tipo_anexo);
         --
         vn_fase := 8;
         -- Chama procedimento para integrar informações de email por tipo de anexo
         pk_csf_api_nfce.pkb_integr_nfdest_email ( est_log_generico_nf      => est_log_generico_nf
                                            , est_row_nfdest_email  => pk_csf_api_nfce.gt_row_nfdest_email
                                            , en_notafiscal_id      => en_notafiscal_id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nfdest_email fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => gv_resumo || gv_cabec_nf
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nfdest_email;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura do destinatário da nota fiscal
procedure pkb_ler_Nota_Fiscal_Dest_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id          in             Nota_Fiscal.id%TYPE
                                      , en_notafiscaldest_id      in             nota_fiscal_dest.id%type
                                      --| parâmetros de chave
                                      , ev_cpf_cnpj_emit          in             varchar2
                                      , en_dm_ind_emit            in             number
                                      , en_dm_ind_oper            in             number
                                      , ev_cod_part               in             varchar2
                                      , ev_cod_mod                in             varchar2
                                      , ev_serie                  in             varchar2
                                      , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_DEST_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_DEST_FF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_DEST_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_dest_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Dest_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_dest_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_dest_ff.first..vt_tab_csf_nota_fiscal_dest_ff.last loop
         --
         vn_fase := 7;
         -- Chama o procedimento de validação dos dados do Destinatário da Nota Fiscal
         pk_csf_api_nfce.pkb_integr_Nota_Fiscal_Dest_ff ( est_log_generico_nf           => est_log_generico_nf
                                                   , en_notafiscal_id           => en_notafiscal_id
                                                   , en_notafiscaldest_id       => en_notafiscaldest_id
                                                   , ev_atributo                => vt_tab_csf_nota_fiscal_dest_ff(i).atributo
                                                   , ev_valor                   => vt_tab_csf_nota_fiscal_dest_ff(i).valor );
      --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Dest_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => gv_resumo || gv_cabec_nf
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Dest_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura do destinatário da nota fiscal
procedure pkb_ler_Nota_Fiscal_Dest ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                   , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                                   --| parâmetros de chave
                                   , ev_cpf_cnpj_emit          in             varchar2
                                   , en_dm_ind_emit            in             number
                                   , en_dm_ind_oper            in             number
                                   , ev_cod_part               in             varchar2
                                   , ev_cod_mod                in             varchar2
                                   , ev_serie                  in             varchar2
                                   , en_nro_nf                 in             number ) is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_DEST') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CNPJ' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CPF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NOME' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'LOGRAD' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COMPL' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'BAIRRO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CIDADE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CIDADE_IBGE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'UF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CEP' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PAIS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'PAIS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'FONE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'IE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'SUFRAMA' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'EMAIL' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_DEST');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_DEST' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_dest;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Dest fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => gv_resumo || gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                              , en_referencia_id    => en_notafiscal_id
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_dest.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_dest.first..vt_tab_csf_nota_fiscal_dest.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest := null;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.notafiscal_id  := en_notafiscal_id;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.cnpj           := pk_csf.fkg_converte(vt_tab_csf_nota_fiscal_dest(i).CNPJ);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.cpf            := pk_csf.fkg_converte(vt_tab_csf_nota_fiscal_dest(i).CPF);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.nome           := trim(vt_tab_csf_nota_fiscal_dest(i).NOME);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.lograd         := trim(vt_tab_csf_nota_fiscal_dest(i).LOGRAD);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.nro            := trim(vt_tab_csf_nota_fiscal_dest(i).NRO);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.compl          := trim(vt_tab_csf_nota_fiscal_dest(i).COMPL);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.bairro         := trim(vt_tab_csf_nota_fiscal_dest(i).BAIRRO);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.cidade         := trim(vt_tab_csf_nota_fiscal_dest(i).CIDADE);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.cidade_ibge    := vt_tab_csf_nota_fiscal_dest(i).CIDADE_IBGE;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.uf             := upper(trim(vt_tab_csf_nota_fiscal_dest(i).UF));
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.cep            := vt_tab_csf_nota_fiscal_dest(i).CEP;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.pais           := trim(vt_tab_csf_nota_fiscal_dest(i).PAIS);

         if nvl(vt_tab_csf_nota_fiscal_dest(i).COD_PAIS,0) = 0 then
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.cod_pais := null;
         else
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.cod_pais    := vt_tab_csf_nota_fiscal_dest(i).COD_PAIS;
         end if;

         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.fone           := trim(vt_tab_csf_nota_fiscal_dest(i).FONE);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.ie             := pk_csf.fkg_converte(vt_tab_csf_nota_fiscal_dest(i).IE);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.suframa        := trim(vt_tab_csf_nota_fiscal_dest(i).SUFRAMA);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.email          := trim(vt_tab_csf_nota_fiscal_dest(i).EMAIL);
         --
         vn_fase := 8;
         -- Chama o procedimento de validação dos dados do Destinatário da Nota Fiscal
         pk_csf_api_nfce.pkb_integr_Nota_Fiscal_Dest ( est_log_generico_nf          => est_log_generico_nf
                                                , est_row_Nota_Fiscal_Dest  => pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest
                                                , ev_cod_part               => ev_cod_part
                                                , en_multorg_id             => gn_multorg_id );
         --
         vn_fase := 9;
         --| Procedimento de leitura do destinatário da nota fiscal
         pkb_ler_nfdest_email ( est_log_generico_nf          => est_log_generico_nf
                              , en_notafiscal_id          => en_notafiscal_id
                              , en_notafiscaldest_id      => pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.id
                              --| parâmetros de chave
                              , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                              , en_dm_ind_emit            => en_dm_ind_emit
                              , en_dm_ind_oper            => en_dm_ind_oper
                              , ev_cod_part               => ev_cod_part
                              , ev_cod_mod                => ev_cod_mod
                              , ev_serie                  => ev_serie
                              , en_nro_nf                 => en_nro_nf
                              );
         --
         vn_fase := 10;
         --
         pkb_ler_Nota_Fiscal_Dest_ff (est_log_generico_nf       => est_log_generico_nf
                                    , en_notafiscal_id       => pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.notafiscal_id
                                    , en_notafiscaldest_id   => pk_csf_api_nfce.gt_row_Nota_Fiscal_Dest.id
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit       => trim(vt_tab_csf_nota_fiscal_dest(i).CPF_CNPJ_EMIT)
                                    , en_dm_ind_emit         => vt_tab_csf_nota_fiscal_dest(i).DM_IND_EMIT
                                    , en_dm_ind_oper         => vt_tab_csf_nota_fiscal_dest(i).DM_IND_OPER
                                    , ev_cod_part            => trim(vt_tab_csf_nota_fiscal_dest(i).COD_PART)
                                    , ev_cod_mod             => trim(vt_tab_csf_nota_fiscal_dest(i).COD_MOD)
                                    , ev_serie               => trim(vt_tab_csf_nota_fiscal_dest(i).SERIE)
                                    , en_nro_nf              => vt_tab_csf_nota_fiscal_Dest(i).NRO_NF );
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Dest fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => gv_resumo || gv_cabec_nf
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Dest;
--
-- ============================================================================================================================================= --
--| Procedimento de leitura do Emitente da nota fiscal Flex-Field
procedure pkb_ler_Nota_Fiscal_Emit_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id          in             Nota_Fiscal.id%TYPE
                                      , en_notafiscalemit_id      in             nota_fiscal_emit.id%type
                                      --| parâmetros de chave
                                      , ev_cpf_cnpj_emit          in             varchar2
                                      , en_dm_ind_emit            in             number
                                      , en_dm_ind_oper            in             number
                                      , ev_cod_part               in             varchar2
                                      , ev_cod_mod                in             varchar2
                                      , ev_serie                  in             varchar2
                                      , en_nro_nf                 in             number
                                      )
is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_EMIT_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_EMIT_FF');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE'   || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'  || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_EMIT_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_emit_ff;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Emit_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                   , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                   , ev_resumo           => gv_resumo || gv_cabec_nf
                                                   , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                                   , en_referencia_id    => en_notafiscal_id
                                                   , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                      , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_emit_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_emit_ff.first..vt_tab_csf_nota_fiscal_emit_ff.last loop
         --
         vn_fase := 7;
         -- Chama o procedimento de validação dos dados do Emitente da Nota Fiscal
         pk_csf_api_nfce.pkb_integr_Nota_Fiscal_Emit_ff ( est_log_generico_nf        => est_log_generico_nf
                                                        , en_notafiscal_id           => en_notafiscal_id
                                                        , en_notafiscalemit_id       => en_notafiscalemit_id
                                                        , ev_atributo                => vt_tab_csf_nota_fiscal_emit_ff(i).atributo
                                                        , ev_valor                   => vt_tab_csf_nota_fiscal_emit_ff(i).valor );
      --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Emit_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                             , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                             , ev_resumo           => gv_resumo || gv_cabec_nf
                                             , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                             , en_referencia_id    => en_notafiscal_id
                                             , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Emit_ff;
--
-- ============================================================================================================================================= --
--| Procedimento de leitura do emitente da nota fiscal
procedure pkb_ler_Nota_Fiscal_Emit ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                   , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                                   , en_empresa_id             in             Empresa.id%TYPE
                                   --| parâmetros de chave
                                   , ev_cpf_cnpj_emit          in             varchar2
                                   , en_dm_ind_emit            in             number
                                   , en_dm_ind_oper            in             number
                                   , ev_cod_part               in             varchar2
                                   , ev_cod_mod                in             varchar2
                                   , ev_serie                  in             varchar2
                                   , en_nro_nf                 in             number )
is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
   cursor c_dados ( en_empresa_id empresa.id%type ) is
    select p.id pessoa_id    , p.nome            , p.fantasia          , p.lograd
         , p.nro             , p.compl             , p.bairro
         , c.descr cidade    , c.ibge_cidade       , s.sigla_estado
         , p.cep             , ia.descr descr_pais , ia.sigla_pais
         , ia.cod_siscomex   , p.fone              , j.ie                
         , j.iest            , j.im                , j.cnae
      from empresa  e
         , pessoa   p
         , cidade   c
         , estado   s
         , pais     ia
         , juridica j
     where p.id           = e.pessoa_id
       and c.id           = p.cidade_id
       and s.id           = c.estado_id
       and ia.id          = s.pais_id
       and j.pessoa_id(+) = p.id
       and e.id           = en_empresa_id;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_EMIT') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NOME' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'FANTASIA' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'LOGRAD' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COMPL' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'BAIRRO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CIDADE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CIDADE_IBGE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'UF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CEP' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PAIS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'PAIS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'FONE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'IE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'IEST' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'IM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CNAE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_REG_TRIB' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_EMIT');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE'   || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'  || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_EMIT' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_emit;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Emit fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                   , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                   , ev_resumo           => gv_resumo || gv_cabec_nf
                                                   , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                                   , en_referencia_id    => en_notafiscal_id
                                                   , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                      , est_log_generico_nf => est_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_emit.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_emit.first..vt_tab_csf_nota_fiscal_emit.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit := null;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.notafiscal_id  := en_notafiscal_id;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.nome           := trim(vt_tab_csf_nota_fiscal_emit(i).NOME);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.fantasia       := trim(vt_tab_csf_nota_fiscal_emit(i).FANTASIA);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.lograd         := trim(vt_tab_csf_nota_fiscal_emit(i).LOGRAD);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.nro            := trim(vt_tab_csf_nota_fiscal_emit(i).NRO);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.compl          := trim(substr(vt_tab_csf_nota_fiscal_emit(i).COMPL, 1, 20));
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.bairro         := trim(vt_tab_csf_nota_fiscal_emit(i).BAIRRO);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cidade         := trim(vt_tab_csf_nota_fiscal_emit(i).CIDADE);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cidade_ibge    := vt_tab_csf_nota_fiscal_emit(i).CIDADE_IBGE;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.uf             := upper(vt_tab_csf_nota_fiscal_emit(i).UF);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cep            := vt_tab_csf_nota_fiscal_emit(i).CEP;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.pais           := trim(vt_tab_csf_nota_fiscal_emit(i).PAIS);
         --
         if nvl(vt_tab_csf_nota_fiscal_emit(i).cod_pais,0) = 0 then
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cod_pais := 1058;
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.pais     := 'Brasil';
         else
            pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cod_pais    := vt_tab_csf_nota_fiscal_emit(i).COD_PAIS;
         end if;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.fone           := trim(vt_tab_csf_nota_fiscal_emit(i).FONE);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.ie             := pk_csf.fkg_converte(vt_tab_csf_nota_fiscal_emit(i).IE);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.iest           := trim(vt_tab_csf_nota_fiscal_emit(i).IEST);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.im             := trim(vt_tab_csf_nota_fiscal_emit(i).IM);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cnae           := trim(vt_tab_csf_nota_fiscal_emit(i).CNAE);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.DM_REG_TRIB    := vt_tab_csf_nota_fiscal_emit(i).DM_REG_TRIB;
         --
         vn_fase := 8;
         -- Chama o procedimento de validação dos dados do Emitente da Nota Fiscal
         pk_csf_api_nfce.pkb_integr_Nota_Fiscal_Emit ( est_log_generico_nf       => est_log_generico_nf
                                                     , est_row_Nota_Fiscal_Emit  => pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit
                                                     , en_empresa_id             => en_empresa_id
                                                     , en_dm_ind_emit            => en_dm_ind_emit
                                                     , ev_cod_part               => ev_cod_part );
         --
         vn_fase := 9;
         --
         pkb_ler_Nota_Fiscal_Emit_ff ( est_log_generico_nf    => est_log_generico_nf
                                     , en_notafiscal_id       => pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.notafiscal_id
                                     , en_notafiscalemit_id   => pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.id
                                     --| parâmetros de chave
                                     , ev_cpf_cnpj_emit       => trim(vt_tab_csf_nota_fiscal_emit(i).CPF_CNPJ_EMIT)
                                     , en_dm_ind_emit         => vt_tab_csf_nota_fiscal_emit(i).DM_IND_EMIT
                                     , en_dm_ind_oper         => vt_tab_csf_nota_fiscal_emit(i).DM_IND_OPER
                                     , ev_cod_part            => trim(vt_tab_csf_nota_fiscal_emit(i).COD_PART)
                                     , ev_cod_mod             => trim(vt_tab_csf_nota_fiscal_emit(i).COD_MOD)
                                     , ev_serie               => trim(vt_tab_csf_nota_fiscal_emit(i).SERIE)
                                     , en_nro_nf              => vt_tab_csf_nota_fiscal_emit(i).NRO_NF
                                     );
         --
      end loop;
      --
   else
      --
      -- Se a informação do emitente não foi enviada para o modelo "65" a rotina irá buscar os dados da empresa
      -- Gera os dados do emitente da nota fiscal conforme dados da empresa para poder integrar a view
      for rec_dados in c_dados ( en_empresa_id ) loop
        --
        exit when c_dados%notfound or (c_dados%notfound);
        --
        vn_fase := 10;
        --
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit := null;
        --
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.notafiscal_id  := en_notafiscal_id;
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.nome           := trim(rec_dados.nome);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.fantasia       := trim(rec_dados.fantasia);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.lograd         := trim(rec_dados.lograd);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.nro            := trim(rec_dados.nro);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.compl          := trim(substr(rec_dados.compl, 1, 20));
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.bairro         := trim(rec_dados.bairro);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cidade         := trim(rec_dados.cidade);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cidade_ibge    := rec_dados.ibge_cidade;
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.uf             := upper(rec_dados.sigla_estado);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cep            := rec_dados.cep;
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.pais           := trim(rec_dados.descr_pais);
        --
        vn_fase := 10.1;
        --
        if nvl(rec_dados.cod_siscomex,0) = 0 then
           pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cod_pais := 1058;
           pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.pais     := 'Brasil';
        else
           pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cod_pais    := rec_dados.cod_siscomex;
        end if;
        --
        vn_fase := 10.2;
        --
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.fone           := trim(rec_dados.fone);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.ie             := pk_csf.fkg_converte(rec_dados.ie);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.iest           := trim(rec_dados.iest);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.im             := trim(rec_dados.im);
        pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.cnae           := trim(rec_dados.cnae);
        --
        vn_fase := 10.3;
        --
        begin
           select vp.cd
             into pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.DM_REG_TRIB
             from pessoa_tipo_param pt
                , valor_tipo_param  vp
                , tipo_param        tp
            where vp.id        = pt.valortipoparam_id
              and tp.id        = pt.tipoparam_id
              and tp.cd        = '9'
              and pt.pessoa_id = rec_dados.pessoa_id;
        exception
           when others then
              pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit.DM_REG_TRIB    := 1; -- conforme valor default da tabela
        end;
        --
        vn_fase := 11;
        -- Chama o procedimento de validação dos dados do Emitente da Nota Fiscal
        pk_csf_api_nfce.pkb_integr_Nota_Fiscal_Emit ( est_log_generico_nf       => est_log_generico_nf
                                                    , est_row_Nota_Fiscal_Emit  => pk_csf_api_nfce.gt_row_Nota_Fiscal_Emit
                                                    , en_empresa_id             => en_empresa_id
                                                    , en_dm_ind_emit            => en_dm_ind_emit
                                                    , ev_cod_part               => ev_cod_part );
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Emit fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                             , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                             , ev_resumo           => gv_resumo || gv_cabec_nf
                                             , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                             , en_referencia_id    => en_notafiscal_id
                                             , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Emit;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de Informações Complementares da Nota Fiscal
procedure pkb_ler_nota_fiscal_compl ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id          in             nf_agend_transp.notafiscal_id%TYPE
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit          in             varchar2
                                    , en_dm_ind_emit            in             number
                                    , en_dm_ind_oper            in             number
                                    , ev_cod_part               in             varchar2
                                    , ev_cod_mod                in             varchar2
                                    , ev_serie                  in             varchar2
                                    , en_nro_nf                 in             number
                                    ) is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_COMPL') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_CHAVE_NFE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ID_ERP' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'SUB_SERIE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_INFOR' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_CTA' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_CONS' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TP_LIGACAO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_COD_GRUPO_TENSAO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_TP_ASSINANTE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ORD_EMB' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'SEQ_NRO_ORD_EMB' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_COMPL');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_COMPL' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_compl;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nota_fiscal_compl fase(' || vn_fase || '):' || sqlerrm;
           --
           declare
              vn_loggenerico_id  log_generico_nf.id%TYPE;
           begin
              --
              pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                             , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                             , ev_resumo           => gv_resumo || gv_cabec_nf
                                             , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                             , en_referencia_id    => en_notafiscal_id
                                             , ev_obj_referencia   => 'NOTA_FISCAL' );
              --
              -- Armazena o "loggenerico_id" na memória
              pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                , est_log_generico_nf => est_log_generico_nf );
              --
           exception
              when others then
                 null;
           end;
           --
        end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_compl.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_compl.first..vt_tab_csf_nota_fiscal_compl.last loop
         --
         vn_fase := 7;
         --
         pk_csf_api_nfce.gt_row_nota_fiscal_compl := null;
         --
         pk_csf_api_nfce.gt_row_nota_fiscal_compl.notafiscal_id  := en_notafiscal_id;
         pk_csf_api_nfce.gt_row_nota_fiscal_compl.id_erp         := vt_tab_csf_nota_fiscal_compl(i).id_erp;
         --
         vn_fase := 8;
         --
         pk_csf_api_nfce.pkb_integr_nota_fiscal_compl ( est_log_generico_nf           => est_log_generico_nf
                                                 , est_row_nota_fiscal_compl  => pk_csf_api_nfce.gt_row_nota_fiscal_compl
                                                 , en_notafiscal_id           => en_notafiscal_id
                                                 , en_nro_nf                  => en_nro_nf
                                                 , ev_nro_chave_nfe           => vt_tab_csf_nota_fiscal_compl(i).nro_chave_nfe
                                                 , en_sub_serie               => vt_tab_csf_nota_fiscal_compl(i).sub_serie
                                                 , ev_cod_mod                 => vt_tab_csf_nota_fiscal_compl(i).cod_mod
                                                 , ev_cod_infor               => vt_tab_csf_nota_fiscal_compl(i).cod_infor
                                                 , ev_cod_cta                 => vt_tab_csf_nota_fiscal_compl(i).cod_cta
                                                 , ev_cod_cons                => vt_tab_csf_nota_fiscal_compl(i).cod_cons
                                                 , en_dm_tp_ligacao           => vt_tab_csf_nota_fiscal_compl(i).dm_tp_ligacao
                                                 , ev_dm_cod_grupo_tensao     => trim(vt_tab_csf_nota_fiscal_compl(i).dm_cod_grupo_tensao)
                                                 , en_dm_tp_assinante         => vt_tab_csf_nota_fiscal_compl(i).dm_tp_assinante
                                                 , en_nro_ord_emb             => vt_tab_csf_nota_fiscal_compl(i).nro_ord_emb
                                                 , en_seq_nro_ord_emb         => vt_tab_csf_nota_fiscal_compl(i).seq_nro_ord_emb
                                                 , en_multorg_id              => gn_multorg_id
                                                 );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nota_fiscal_compl fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => en_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                           , est_log_generico_nf => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nota_fiscal_compl;
--
-- ============================================================================================================================================= --
-- Procedimento para recuperar os dados de Mult-Org
procedure pkb_nota_fiscal_multorg_ff( est_log_generico   in  out nocopy  dbms_sql.number_table
                                    , ev_cpf_cnpj_emit   in  varchar2
                                    , en_dm_ind_emit     in  number
                                    , en_dm_ind_oper     in  number
                                    , ev_cod_part        in  varchar2
                                    , ev_cod_mod         in  varchar2
                                    , ev_serie           in  varchar2
                                    , en_nro_nf          in  number
                                    , sn_multorg_id      in  out mult_org.id%type ) is
   --
   vn_fase               number := 0;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   vv_cod                mult_org.cd%type;
   vv_hash               mult_org.hash%type;
   vv_cod_ret            mult_org.cd%type;
   vv_hash_ret           mult_org.hash%type;
   vn_multorg_id         mult_org.id%type := 0;
   vb_multorg            boolean := false;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gn_multorg_id, 0) <= 0 then
      --
      gn_multorg_id := pk_csf.fkg_multorg_id ( ev_multorg_cd => '1' );
      --
   end if;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_FF') = 0 then
      --
      sn_multorg_id := vn_multorg_id;
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nota_fiscal_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_FF' );
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_sql := gv_sql || ' ORDER BY ' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_nota_fiscal_multorg_ff fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                          , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                          , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                          , en_referencia_id    => null
                                          , ev_obj_referencia   => 'NOTA_FISCAL' );
           --
           raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_ff.first..vt_tab_csf_nota_fiscal_ff.last loop
         --
         vn_fase := 7;
         --
         if vt_tab_csf_nota_fiscal_ff(i).atributo in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            vb_multorg:= true;
            --
            vn_fase := 8;
            -- Chama procedimento que faz a validação dos itens da Inventario - campos flex field.
            vv_cod_ret := null;
            vv_hash_ret := null;

            pk_csf_api_nfce.pkb_val_atrib_multorg ( est_log_generico     => est_log_generico
                                             , ev_obj_name          => 'VW_CSF_NOTA_FISCAL_FF'
                                             , ev_atributo          => vt_tab_csf_nota_fiscal_ff(i).atributo
                                             , ev_valor             => vt_tab_csf_nota_fiscal_ff(i).valor
                                             , sv_cod_mult_org      => vv_cod_ret
                                             , sv_hash_mult_org     => vv_hash_ret
                                             , en_referencia_id     => null
                                             , ev_obj_referencia    => 'NOTA_FISCAL');
           --
           vn_fase := 9;
           --
           if vv_cod_ret is not null then
              vv_cod := vv_cod_ret;
           end if;
           --
           if vv_hash_ret is not null then
              vv_hash := vv_hash_ret;
           end if;
           --
        end if;
        --
      end loop;
      --
      vn_fase := 10;
      --
      if nvl(est_log_generico.count, 0) <= 0 and
         vb_multorg then
         --
         vn_fase := 11;
         --
         vn_multorg_id := sn_multorg_id;
         --
         pk_csf_api_nfce.pkb_ret_multorg_id( est_log_generico   => est_log_generico
                                      , ev_cod_mult_org    => vv_cod
                                      , ev_hash_mult_org   => vv_hash
                                      , sn_multorg_id      => vn_multorg_id
                                      , en_referencia_id   => null
                                      , ev_obj_referencia  => 'NOTA_FISCAL'
                                      );
      end if;
      --
      vn_fase := 12;
      --
      sn_multorg_id := vn_multorg_id;
      --
   else
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Nota fiscal cadastrada com Mult Org default (codigo = 1), pois não foram passados o codigo e a hash do multorg.';
      --
      vn_loggenericonf_id := null;
      --
      vn_fase := 13;
      --
      pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                     , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                     , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                     , en_tipo_log         => pk_csf_api_nfce.INFORMACAO
                                     , en_referencia_id    => null
                                     , ev_obj_referencia   => 'NOTA_FISCAL'
                                     );
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_nota_fiscal_multorg_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
      --
end pkb_nota_fiscal_multorg_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura das Notas Fiscais
procedure pkb_ler_Nota_Fiscal ( ev_cpf_cnpj_emit in varchar2 ) is
   --
   vn_fase                number := 0;
   vt_log_generico_nf     dbms_sql.number_table;
   vn_notafiscal_id       Nota_Fiscal.id%TYPE;
   vn_empresa_id          Empresa.id%TYPE;
   vn_dm_st_proc          Nota_Fiscal.dm_st_proc%type;
   vn_cancelado           number := 0;
   vd_dt_ult_fecha        fecha_fiscal_empresa.dt_ult_fecha%type;
   i                      pls_integer;
   vv_obj                 varchar2(255);
   vn_multorg_id          mult_org.id%type;
   vn_dm_dt_escr_dfepoe   empresa.dm_dt_escr_dfepoe%type;
   vn_loggenericonf_id    log_generico_nf.id%type;
   vn_dm_aguard_liber_nfe empresa.dm_aguard_liber_nfe%type;
   vv_serie               nota_fiscal.serie%type;
   vv_cod_mod             mod_fiscal.cod_mod%type; 
   --
   function fkg_existe_cancelamento ( ev_cpf_cnpj_emit  in  varchar2
                                    , en_dm_ind_emit    in  number
                                    , en_dm_ind_oper    in  number
                                    , ev_cod_part       in  varchar2
                                    , ev_cod_mod        in  varchar2
                                    , ev_serie          in  varchar2
                                    , en_nro_nf         in  number
                                    ) return number is
      --
      vv_sql_canc varchar2(4000);
      --
      vn_ret number := 0;
      --
   begin
      --
      if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_CANC') = 0 then
         --
         vn_ret := 0;
         --
         return vn_ret;
         --
      end if;
      --
      -- Não pega notas com registro de cancelamento
      vv_sql_canc := vv_sql_canc || 'select 1 ' || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_CANC');
      --
      vv_sql_canc := vv_sql_canc || ' where ' || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
      vv_sql_canc := vv_sql_canc || ' and '   || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
      vv_sql_canc := vv_sql_canc || ' and '   || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
      --
      if en_dm_ind_emit = 1 and trim(ev_cod_part) is not null then
         --
         vv_sql_canc := vv_sql_canc || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
         --
      end if;
      --
      vv_sql_canc := vv_sql_canc || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
      vv_sql_canc := vv_sql_canc || ' and ' || GV_ASPAS || 'SERIE'   || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
      vv_sql_canc := vv_sql_canc || ' and ' || GV_ASPAS || 'NRO_NF'  || GV_ASPAS || ' = ' || en_nro_nf;
      --
      begin
         --
         execute immediate vv_sql_canc into vn_ret;
         --
      exception
         when no_data_found then
            return 0;
         when others then
            null;
      end;
      --
      return vn_ret;
      --
   end fkg_existe_cancelamento;
   --
begin
   --
   vn_fase := 1;
   --
   vt_log_generico_nf.delete;
   --
   pkb_limpa_array;
   --
   vn_fase := 12;
   --
   gv_sql := null;
   --
   vt_tab_csf_nota_fiscal.delete;
   --
   vn_fase := 1.3;
   --
   info_fechamento := pk_csf.fkg_retorna_csftipolog_id(ev_cd => 'INFO_FECHAMENTO');
   --
   if nvl(gn_empresa_id, 0) <= 0 then
      --
      gn_multorg_id := pk_csf.fkg_multorg_id ( ev_multorg_cd => '1' );
      --
   else
      --
      gn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => gn_empresa_id );
      --
   end if;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NOTA_FISCAL'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  , en_dm_ind_emit => gn_dm_ind_emit
                                  );
   --
   if nvl(gn_dm_ind_emit,0) = 1 then
      --
      if nvl(pk_csf.fkg_quantidade (ev_obj => vv_obj),0) = 0 then
         --
         vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NOTA_FISCAL'
                                        , ev_aspas       => GV_ASPAS
                                        , ev_owner_obj   => GV_OWNER_OBJ
                                        , ev_nome_dblink => GV_NOME_DBLINK
                                        , en_dm_ind_emit => null
                                        );
         --
         gn_dm_ind_emit := null;
         --
      end if;
      --
   end if;
   --
   -- Carrega o CODIGO DO MODELO FISCAL que será integrado
   vv_cod_mod := '65';
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || 'a.'   || GV_ASPAS || 'CPF_CNPJ_EMIT'  || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_IND_EMIT'    || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_IND_OPER'    || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'COD_PART'       || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'COD_MOD'        || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(a.' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'NRO_NF'         || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'SIT_DOCTO'      || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'COD_NAT_OPER'   || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DESCR_NAT_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_IND_PAG'     || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DT_SAI_ENT'     || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'HORA_SAI_ENT'   || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DT_EMISS'       || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'UF_EMBARQ'      || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'LOCAL_EMBARQ'   || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'NF_EMPENHO'     || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'PEDIDO_COMPRA'  || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'CONTRATO_COMPRA'|| GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_ST_PROC'     || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_FIN_NFE'     || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_PROC_EMISS'  || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'CIDADE_IBGE_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'UF_IBGE_EMIT'     || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'USUARIO'          || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'VIAS_DANFE_CUSTOM' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'NRO_CHAVE_CTE_REF' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'SIST_ORIG'         || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'UNID_ORG'          || GV_ASPAS;
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' a';
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || 'a.'    || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD'       || GV_ASPAS || ' = ' || '''' || vv_cod_mod || '''';   
   --
   vn_fase := 3;
   -- testa data de inicio da integração
   if gd_dt_ini_integr is not null then
      --
      gv_sql := gv_sql || ' and trunc(a.' || GV_ASPAS || 'DT_EMISS' || GV_ASPAS || ') >= ' || '''' || to_char(gd_dt_ini_integr, gd_formato_dt_erp) || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || gv_where;
   --
   vn_fase := 5;
   --
   gv_sql := gv_sql || ' order by a.' || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'COD_PART'    || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'COD_MOD'     || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'SERIE'       || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'NRO_NF'      || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DT_EMISS'    || GV_ASPAS;
   --
   vn_fase := 6;
   --
   gv_resumo := 'Inconsistência de dados no leiaute ' || vv_obj || ' (empresa: ' || ev_cpf_cnpj_emit || ')';
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         null;
         --
         pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal fase(' || vn_fase || ') ('||gv_sql||'):' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_nf.id%TYPE;
         begin
            --
            pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                           , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                           , ev_resumo           => gv_resumo
                                           , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                           , en_referencia_id    => null
                                           , ev_obj_referencia   => 'NOTA_FISCAL' );
            --
         exception
            when others then
               null;
         end;
         -- em vez o "raise", sai do processo da nota fiscal com erro
         goto sair_geral;
         --
   end;
   --
   -- Calcula a quantidade de registros buscados no ERP
   -- para ser mostrado na tela de agendamento.
   --
   begin
      pk_agend_integr.gvtn_qtd_erp(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erp(gv_cd_obj),0) + nvl(vt_tab_csf_nota_fiscal.count,0);
   exception
      when others then
      null;
   end;
   --
   vn_fase := 7;
   --
   if vt_tab_csf_nota_fiscal.count > 0 then
      -- Leitura do array de notas fiscais
      for i in vt_tab_csf_nota_fiscal.first..vt_tab_csf_nota_fiscal.last loop
         --
         vn_fase := 8;
         --
         if nvl(vn_multorg_id, 0) <= 0 then
            --
            vn_multorg_id := gn_multorg_id;
            --
         end if;
         --
         pkb_nota_fiscal_multorg_ff( est_log_generico  =>  vt_log_generico_nf
                                   , ev_cpf_cnpj_emit  =>  vt_tab_csf_nota_fiscal(i).cpf_cnpj_emit
                                   , en_dm_ind_emit    =>  vt_tab_csf_nota_fiscal(i).dm_ind_emit
                                   , en_dm_ind_oper    =>  vt_tab_csf_nota_fiscal(i).dm_ind_oper
                                   , ev_cod_part       =>  vt_tab_csf_nota_fiscal(i).cod_part
                                   , ev_cod_mod        =>  vt_tab_csf_nota_fiscal(i).cod_mod
                                   , ev_serie          =>  vt_tab_csf_nota_fiscal(i).serie
                                   , en_nro_nf         =>  vt_tab_csf_nota_fiscal(i).nro_nf
                                   , sn_multorg_id     =>  vn_multorg_id );
         vn_fase := 8.1;
         --
         if nvl(vn_multorg_id, 0) <= 0 then
            --
            vn_multorg_id := gn_multorg_id;
            --
         elsif vn_multorg_id != gn_multorg_id then
            --
            vn_multorg_id := gn_multorg_id;
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Mult-org informado pelo usuario('||vn_multorg_id||') não corresponde ao Mult-org da empresa('||gn_multorg_id||').';
            --
            vn_fase := 8.2;
            --
            declare
               vn_loggenericonf_id  log_generico_nf.id%TYPE;
            begin
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => 'Mult-Org incorreto ou não informado.'
                                              , en_tipo_log         => pk_csf_api_nfce.INFORMACAO
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'NOTA_FISCAL'
                                              );
            exception
               when others then
                  null;
            end;
            --
         end if;
         --
         vn_empresa_id := pk_csf.fkg_empresa_id_cpf_cnpj ( en_multorg_id => vn_multorg_id
                                                         , ev_cpf_cnpj   => vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT );
         --
         vd_dt_ult_fecha := pk_csf.fkg_recup_dtult_fecha_empresa( en_empresa_id   => vn_empresa_id
                                                                , en_objintegr_id => pk_csf.fkg_recup_objintegr_id( ev_cd => '6' ));
         --
         vn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => vn_empresa_id );
         --
         vn_fase := 9;
         --
         if (vd_dt_ult_fecha is null) or
            (vt_tab_csf_nota_fiscal(i).dm_ind_emit = 0 and vt_tab_csf_nota_fiscal(i).dm_ind_oper = 1 and trunc(vt_tab_csf_nota_fiscal(i).dt_emiss) > vd_dt_ult_fecha) or
            (vt_tab_csf_nota_fiscal(i).dm_ind_emit = 0 and vt_tab_csf_nota_fiscal(i).dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 0 and trunc(vt_tab_csf_nota_fiscal(i).dt_emiss) > vd_dt_ult_fecha) or
            (vt_tab_csf_nota_fiscal(i).dm_ind_emit = 0 and vt_tab_csf_nota_fiscal(i).dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 1 and trunc(nvl(vt_tab_csf_nota_fiscal(i).dt_sai_ent,vt_tab_csf_nota_fiscal(i).dt_emiss)) > vd_dt_ult_fecha) or
            (vt_tab_csf_nota_fiscal(i).dm_ind_emit = 1 and trunc(nvl(vt_tab_csf_nota_fiscal(i).dt_sai_ent,vt_tab_csf_nota_fiscal(i).dt_emiss)) > vd_dt_ult_fecha) then
            --
            vn_fase := 10;
            --
            vn_cancelado := fkg_existe_cancelamento ( ev_cpf_cnpj_emit => vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT
                                                    , en_dm_ind_emit   => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                                    , en_dm_ind_oper   => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                                    , ev_cod_part      => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                                    , ev_cod_mod       => vt_tab_csf_nota_fiscal(i).COD_MOD
                                                    , ev_serie         => vt_tab_csf_nota_fiscal(i).SERIE
                                                    , en_nro_nf        => vt_tab_csf_nota_fiscal(i).NRO_NF
                                                    );
            if vn_cancelado = 1 then -- sim tem cancelamento
               --
               goto sair_integr;
               --
            end if;
            --
            vn_fase := 11;
            --
            vt_log_generico_nf.delete;
            --
            pkb_limpa_array;
            --
            vn_fase := 12;
            --
            gv_cabec_nf := 'Empresa: ' || vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT
                                       || pk_csf.fkg_nome_empresa ( en_empresa_id => vn_empresa_id );
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            gv_cabec_nf := gv_cabec_nf || 'Número: ' || vt_tab_csf_nota_fiscal(i).NRO_NF;
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            gv_cabec_nf := gv_cabec_nf || 'Série: ' || vt_tab_csf_nota_fiscal(i).SERIE;
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            gv_cabec_nf := gv_cabec_nf || 'Modelo: ' || vt_tab_csf_nota_fiscal(i).COD_MOD;
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            gv_cabec_nf := gv_cabec_nf || 'Operação: ' || pk_csf.fkg_dominio ( ev_dominio => 'NOTA_FISCAL.DM_IND_OPER'
                                                                             , ev_vl      => vt_tab_csf_nota_fiscal(i).DM_IND_OPER );
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            gv_cabec_nf := gv_cabec_nf || 'Indicador do Emitente: ' || pk_csf.fkg_dominio ( ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT'
                                                                                          , ev_vl      => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT );
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            vn_fase := 13;
            --
            if pk_csf.fkg_is_numerico ( ev_valor => trim(vt_tab_csf_nota_fiscal(i).SERIE) ) then
               --
               vv_serie := to_number(trim(vt_tab_csf_nota_fiscal(i).SERIE));
               --
            else
               --
               vv_serie := trim(vt_tab_csf_nota_fiscal(i).SERIE);
               --
            end if;
            --
            vn_notafiscal_id := null;
            -- Recupera o ID da nota fiscal
            begin
               --
               vn_notafiscal_id := pk_csf.fkg_busca_notafiscal_id ( en_multorg_id   => vn_multorg_id
                                                                  , en_empresa_id   => vn_empresa_id
                                                                  , ev_cod_mod      => vt_tab_csf_nota_fiscal(i).COD_MOD
                                                                  , ev_serie        => vv_serie -- vt_tab_csf_nota_fiscal(i).SERIE
                                                                  , en_nro_nf       => vt_tab_csf_nota_fiscal(i).NRO_NF
                                                                  , en_dm_ind_oper  => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                                                  , en_dm_ind_emit  => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                                                  , ev_cod_part     => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                                                  );
               --
            exception
               when others then
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                              , ev_mensagem         => 'Erro ao buscar nota fiscal: ' || sqlerrm
                                              , ev_resumo           => gv_cabec_nf
                                              , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
               goto sair_integr;
               --
            end;
            --
            vn_fase := 14;
            --
            if nvl(vn_notafiscal_id,0) > 0 then
               -- Se a nota já existe no sistema, então
               vn_dm_st_proc := pk_csf.fkg_st_proc_nf ( en_notafiscal_id => vn_notafiscal_id );
               --
               if vn_dm_st_proc in ( 0, 1, 2, 3, 4, 6, 7, 8, 14, 17, 18, 19, 21 ) then
                  -- Sai do processo
                  goto sair_integr;
               end if;
               --
            end if;
            --
            vn_fase := 15;
            --
            pk_csf_api_nfce.gt_row_Nota_Fiscal := null;
            --
            pk_csf_api_nfce.gt_row_Nota_Fiscal.id                := vn_notafiscal_id;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.nat_oper          := trim(vt_tab_csf_nota_fiscal(i).DESCR_NAT_OPER);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dm_ind_pag        := vt_tab_csf_nota_fiscal(i).DM_IND_PAG;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dm_ind_emit       := vt_tab_csf_nota_fiscal(i).DM_IND_EMIT;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dm_ind_oper       := vt_tab_csf_nota_fiscal(i).DM_IND_OPER;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dt_sai_ent        := vt_tab_csf_nota_fiscal(i).DT_SAI_ENT;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.HORA_SAI_ENT      := vt_tab_csf_nota_fiscal(i).HORA_SAI_ENT;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dt_emiss          := vt_tab_csf_nota_fiscal(i).DT_EMISS;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.nro_nf            := vt_tab_csf_nota_fiscal(i).NRO_NF;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.serie             := trim(vt_tab_csf_nota_fiscal(i).SERIE);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.uf_embarq         := trim(vt_tab_csf_nota_fiscal(i).UF_EMBARQ);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.local_embarq      := trim(vt_tab_csf_nota_fiscal(i).LOCAL_EMBARQ);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.nf_empenho        := trim(vt_tab_csf_nota_fiscal(i).NF_EMPENHO);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.pedido_compra     := trim(vt_tab_csf_nota_fiscal(i).PEDIDO_COMPRA);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.contrato_compra   := trim(vt_tab_csf_nota_fiscal(i).CONTRATO_COMPRA);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dm_st_proc        := trim(vt_tab_csf_nota_fiscal(i).DM_ST_PROC);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dt_st_proc        := sysdate;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dm_impressa       := 0;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dm_fin_nfe        := vt_tab_csf_nota_fiscal(i).DM_FIN_NFE;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dm_proc_emiss     := vt_tab_csf_nota_fiscal(i).DM_PROC_EMISS;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.vers_proc         := '1';
            pk_csf_api_nfce.gt_row_Nota_Fiscal.cidade_ibge_emit  := vt_tab_csf_nota_fiscal(i).CIDADE_IBGE_EMIT;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.uf_ibge_emit      := trim(vt_tab_csf_nota_fiscal(i).UF_IBGE_EMIT);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dt_hr_ent_sist    := sysdate;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dm_st_email       := 0;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.id_usuario_erp    := trim(vt_tab_csf_nota_fiscal(i).USUARIO);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.VIAS_DANFE_CUSTOM := vt_tab_csf_nota_fiscal(i).VIAS_DANFE_CUSTOM;
            pk_csf_api_nfce.gt_row_Nota_Fiscal.NRO_CHAVE_CTE_REF := trim(vt_tab_csf_nota_fiscal(i).NRO_CHAVE_CTE_REF);
            pk_csf_api_nfce.gt_row_Nota_Fiscal.dm_st_integra     := 7; -- Integração por view de banco
            pk_csf_api_nfce.gt_row_nota_fiscal.dm_arm_nfe_terc   := 0; -- Não faz armazenamento fiscal
            --# 69487 adicionada empresa
            pk_csf_api_nfce.gt_row_nota_fiscal.empresa_id        := vn_empresa_id ; 
            --
            vn_fase := 16;
            -- Chama o Processo de validação dos dados da Nota Fiscal
            pk_csf_api_nfce.pkb_integr_Nota_Fiscal ( est_log_generico_nf        => vt_log_generico_nf
                                                   , est_row_Nota_Fiscal        => pk_csf_api_nfce.gt_row_Nota_Fiscal
                                                   , ev_cod_mod                 => vt_tab_csf_nota_fiscal(i).COD_MOD
                                                   , ev_cod_matriz              => null
                                                   , ev_cod_filial              => null
                                                   , ev_empresa_cpf_cnpj        => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                                   , ev_cod_part                => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                                   , ev_cod_nat                 => trim(vt_tab_csf_nota_fiscal(i).COD_NAT_OPER)
                                                   , ev_cd_sitdocto             => vt_tab_csf_nota_fiscal(i).SIT_DOCTO
                                                   , ev_sist_orig               => vt_tab_csf_nota_fiscal(i).sist_orig
                                                   , ev_cod_unid_org            => vt_tab_csf_nota_fiscal(i).unid_org
                                                   , en_multorg_id              => vn_multorg_id
                                                   , en_empresaintegrbanco_id   => gn_empresaintegrbanco_id
                                                   );
            --
            vn_fase := 17;
            --
            if nvl(pk_csf_api_nfce.gt_row_Nota_Fiscal.id,0) > 0 then
               -- Leitura dos campos flex field de nota fiscal 
               /*pkb_ler_nota_fiscal_ff ( est_log_generico_nf           => vt_log_generico_nf
                                      , en_notafiscal_id           => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                      --| parâmetros de chave
                                      , ev_cpf_cnpj_emit           => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                      , en_dm_ind_emit             => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                      , en_dm_ind_oper             => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                      , ev_cod_part                => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                      , ev_cod_mod                 => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                      , ev_serie                   => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                      , en_nro_nf                  => vt_tab_csf_nota_fiscal(i).NRO_NF );*/
               --
               -- leitura do emitente da nota fiscal 
               pkb_ler_Nota_Fiscal_Emit ( est_log_generico_nf       => vt_log_generico_nf
                                        , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                        , en_empresa_id             => pk_csf_api_nfce.gt_row_Nota_Fiscal.empresa_id
                                        --| parâmetros de chave
                                        , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                        , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                        , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                        , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                        , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                        , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                        , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 18;
               -- Leitura do destinatário da nota fiscal 
               pkb_ler_Nota_Fiscal_Dest ( est_log_generico_nf          => vt_log_generico_nf
                                        , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                        --| parâmetros de chave
                                        , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                        , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                        , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                        , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                        , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                        , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                        , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 19;
               -- Leitura de nota fiscais referenciadas 
               /*pkb_ler_nf_referen ( est_log_generico_nf          => vt_log_generico_nf
                                  , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                  --| parâmetros de chave
                                  , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                  , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                  , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                  , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                  , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                  , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                  , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );*/
               --
               vn_fase := 20;
               -- Leitura de cupom fiscal referênciado 
               /*pkb_ler_cf_referen ( est_log_generico_nf          => vt_log_generico_nf
                                  , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                  --| parâmetros de chave
                                  , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                  , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                  , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                  , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                  , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                  , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                  , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );*/
               --
               vn_fase := 21;
               -- Leitura de cupom fiscal eletronico referênciado 
               /*pkb_ler_cfe_referen ( est_log_generico_nf          => vt_log_generico_nf
                                   , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                   --| parâmetros de chave
                                   , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                   , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                   , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                   , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                   , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                   , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                   , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );*/
               --
               vn_fase := 22;
               -- Leitura de informações do local de coleta e entrega da nota fiscal 
               pkb_ler_Nota_Fiscal_Local ( est_log_generico_nf          => vt_log_generico_nf
                                         , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                         --| parâmetros de chave
                                         , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                         , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                         , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                         , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                         , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                         , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                         , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 23;
               -- Leitura de informações de cobrança da nota fiscal 
               /*pkb_ler_Nota_Fiscal_Cobr ( est_log_generico_nf          => vt_log_generico_nf
                                        , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                        --| parâmetros de chave
                                        , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                        , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                        , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                        , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                        , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                        , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                        , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );*/
               --
               vn_fase := 24;
               -- Leitura de informações adicionais da nota fiscal 
               pkb_ler_NFInfor_Adic ( est_log_generico_nf          => vt_log_generico_nf
                                    , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                    , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                    , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                    , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                    , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                    , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                    , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 25;
               -- Leitura de informações do transporte da nota fiscal 
               pkb_ler_Nota_Fiscal_Transp ( est_log_generico_nf          => vt_log_generico_nf
                                          , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                          --| parâmetros de chave
                                          , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                          , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                          , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                          , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                          , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                          , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                          , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 26;
               -- Leitura de informações dos itens da nota fiscal 
               pkb_ler_Item_Nota_Fiscal ( est_log_generico_nf          => vt_log_generico_nf
                                        , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                        , en_empresa_id             => pk_csf_api_nfce.gt_row_Nota_Fiscal.empresa_id
                                        --| parâmetros de chave
                                        , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                        , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                        , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                        , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                        , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                        , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                        , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 27;
               -- Leitura de informações fiscais da nota fiscal 
               pkb_ler_NFInfor_Fiscal ( est_log_generico_nf          => vt_log_generico_nf
                                      , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                      --| parâmetros de chave
                                      , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                      , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                      , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                      , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                      , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                      , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                      , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 28;
               -- Leitura dos totais da nota fiscal
               pkb_ler_Nota_Fiscal_Total ( est_log_generico_nf          => vt_log_generico_nf
                                         , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                         --| parâmetros de chave
                                         , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                         , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                         , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                         , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                         , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                         , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                         , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 29;
               -- Leitura das Aquisições de Cana de Açucar
               --  A VIEW VW_CSF_NF_AQUIS_CANA NAO ESTA SENDO USADA 
               /*pkb_ler_nf_aquis_cana ( est_log_generico_nf          => vt_log_generico_nf
                                     , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                     --| parâmetros de chave
                                     , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                     , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                     , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                     , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                     , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                     , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                     , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );*/
               --
               vn_fase := 30;
               -- Leitura de informações de NF de fornecedores a serem impressas na DANFE (Romaneio)
               --  A VIEW 19)	VW_CSF_INF_NF_ROMANEIO NAO ESTA SENDO USADA
               /*pkb_ler_inf_nf_romaneio ( est_log_generico_nf          => vt_log_generico_nf
                                       , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                       --| parâmetros de chave
                                       , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                       , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                       , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                       , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                       , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                       , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                       , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );*/
               --
               vn_fase := 31;
               -- Leitura de Agendamento de Transporte
               --  A VIEW VW_CSF_NF_AGEND_TRANSP NAO ESTA SENDO USADA
               /*pkb_ler_nf_agend_transp ( est_log_generico_nf          => vt_log_generico_nf
                                       , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                       --| parâmetros de chave
                                       , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                       , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                       , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                       , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                       , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                       , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                       , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );*/
               --
               vn_fase := 32;
               -- leitura de Informações Complementares da Nota Fiscal
               pkb_ler_nota_fiscal_compl ( est_log_generico_nf          => vt_log_generico_nf
                                         , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                         --| parâmetros de chave
                                         , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                         , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                         , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                         , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                         , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                         , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                         , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 32.1;
               -- informações de Autorização de acesso ao XML da Nota Fiscal
               pkb_ler_nf_aut_xml ( est_log_generico_nf     => vt_log_generico_nf
                                  , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                  --| parâmetros de chave
                                  , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                  , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                  , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                  , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                  , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                  , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                  , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 32.2;
               -- informações de Formas de Pagamento
               pkb_ler_nf_forma_pgto ( est_log_generico_nf     => vt_log_generico_nf
                                  , en_notafiscal_id          => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                  --| parâmetros de chave
                                  , ev_cpf_cnpj_emit          => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                  , en_dm_ind_emit            => vt_tab_csf_nota_fiscal(i).DM_IND_EMIT
                                  , en_dm_ind_oper            => vt_tab_csf_nota_fiscal(i).DM_IND_OPER
                                  , ev_cod_part               => trim(vt_tab_csf_nota_fiscal(i).COD_PART)
                                  , ev_cod_mod                => trim(vt_tab_csf_nota_fiscal(i).COD_MOD)
                                  , ev_serie                  => trim(vt_tab_csf_nota_fiscal(i).SERIE)
                                  , en_nro_nf                 => vt_tab_csf_nota_fiscal(i).NRO_NF );
               --
               vn_fase := 33;
               -----------------------------
               -- Processos que consistem a informação da Nota Fiscal
               -----------------------------
               pk_csf_api_nfce.pkb_consistem_nf ( est_log_generico_nf     => vt_log_generico_nf
                                           , en_notafiscal_id     => pk_csf_api_nfce.gt_row_Nota_Fiscal.id );
               --
               vn_fase := 34;
               -- Se registrou algum log, altera a Nota Fiscal para dm_st_proc = 10 - "Erro de Validação"
               if nvl(vt_log_generico_nf.count,0) > 0
                  and vt_tab_csf_nota_fiscal(i).DM_ST_PROC not in (6, 7, 8)
                  then
                  --
                  vn_fase := 35;
                  --
                  begin
                     --
                     vn_fase := 36;
                     --
                     -- Variavel global usada em logs de triggers (carrega)
                     gv_objeto := 'pk_integr_view_nfce.pkb_ler_Nota_Fiscal';
                     gn_fase   := vn_fase;
                     --
                     update Nota_Fiscal set dm_st_proc = 10
                                          , dt_st_proc = sysdate
                      where id = pk_csf_api_nfce.gt_row_Nota_Fiscal.id;
                     --
                     -- Variavel global usada em logs de triggers (limpa)
                     gv_objeto := 'pk_integr_view_nfce';
                     gn_fase   := null;
                     --
                  exception
                     when others then
                        --
                        pk_csf_api_nfce.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal fase(' || vn_fase || '):' || sqlerrm;
                        --
                        declare
                           vn_loggenerico_id  log_generico_nf.id%TYPE;
                        begin
                           --
                           pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                          , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                          , ev_resumo           => gv_cabec_nf
                                                          , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                                          , en_referencia_id    => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                                          , ev_obj_referencia   => 'NOTA_FISCAL' );
                           --
                        exception
                           when others then
                              null;
                        end;
                        --
                  end;
                  --
               else
                  -- Se não houve nenhum nenhum registro de ocorrência
                  -- então atualiza o dm_st_proc para 1-Aguardando Envio
                  vn_fase := 37;
                  --
                  begin
                     --
                     if vt_tab_csf_nota_fiscal(i).DM_IND_EMIT = 0 then
                        --
                        if vt_tab_csf_nota_fiscal(i).DM_ST_PROC not in (4, 6, 7, 8) then
                           --
                           if nvl(pk_csf_api_nfce.gt_row_nota_fiscal.dm_legado,0) = 0 then
                              --
                              vn_dm_aguard_liber_nfe := pk_csf.fkg_empr_aguard_liber_nfe ( en_empresa_id => vn_empresa_id );
                              --
                              if nvl(vn_dm_aguard_liber_nfe,0) = 1 then -- Sim, aguarda liberação do usuário
                                 --
                                 -- Variavel global usada em logs de triggers (carrega)
                                 gv_objeto := 'pk_integr_view_nfce.pkb_ler_Nota_Fiscal';
                                 gn_fase   := vn_fase;
                                 --
                                 update Nota_Fiscal set dm_st_proc = 21 -- Aguardando Liberação
                                                      , dt_st_proc = sysdate
                                  where id = pk_csf_api_nfce.gt_row_Nota_Fiscal.id;
                                 --
                                 -- Variavel global usada em logs de triggers (limpa)
                                 gv_objeto := 'pk_integr_view_nfce';
                                 gn_fase   := null;
                                 --
                              else
                                 -- Variavel global usada em logs de triggers (carrega)
                                 gv_objeto := 'pk_integr_view_nfce.pkb_ler_Nota_Fiscal';
                                 gn_fase   := vn_fase;
                                 --
                                 update Nota_Fiscal set dm_st_proc = 1
                                                      , dt_st_proc = sysdate
                                  where id = pk_csf_api_nfce.gt_row_Nota_Fiscal.id;
                                 --
                                 -- Variavel global usada em logs de triggers (limpa)
                                 gv_objeto := 'pk_integr_view_nfce';
                                 gn_fase   := null;
                                 --
                              end if;
                              --
                           else
                              -- Atualiza SITUACAO conforme informação de legado
                              --
                              if nvl(pk_csf_api_nfce.gt_row_nota_fiscal.dm_legado,0) = 1 then --Legado Autorizado
                                 vt_tab_csf_nota_fiscal(i).DM_ST_PROC := 4;
                              elsif nvl(pk_csf_api_nfce.gt_row_nota_fiscal.dm_legado,0) = 2 then --Legado Denegado
                                 vt_tab_csf_nota_fiscal(i).DM_ST_PROC := 6;
                              elsif nvl(pk_csf_api_nfce.gt_row_nota_fiscal.dm_legado,0) = 3 then --Legado Cancelado
                                 vt_tab_csf_nota_fiscal(i).DM_ST_PROC := 7;
                              elsif nvl(pk_csf_api_nfce.gt_row_nota_fiscal.dm_legado,0) = 4 then --Legado Inutilizado
                                 vt_tab_csf_nota_fiscal(i).DM_ST_PROC := 8;
                              else
                                 vt_tab_csf_nota_fiscal(i).DM_ST_PROC := 1;
                              end if;
                              --
                              -- Variavel global usada em logs de triggers (carrega)
                              gv_objeto := 'pk_integr_view_nfce.pkb_ler_Nota_Fiscal';
                              gn_fase   := vn_fase;
                              --
                              update Nota_Fiscal set dm_st_proc = vt_tab_csf_nota_fiscal(i).DM_ST_PROC
                                                   , dt_st_proc = sysdate
                               where id = pk_csf_api_nfce.gt_row_Nota_Fiscal.id;
                              --
                              -- Variavel global usada em logs de triggers (limpa)
                              gv_objeto := 'pk_integr_view_nfce';
                              gn_fase   := null;
                              --
                           end if;
                           --
                        else
                           --
                           -- Variavel global usada em logs de triggers (carrega)
                           gv_objeto := 'pk_integr_view_nfce.pkb_ler_Nota_Fiscal';
                           gn_fase   := vn_fase;
                           --
                           update Nota_Fiscal set dm_st_proc = vt_tab_csf_nota_fiscal(i).DM_ST_PROC
                                                , dt_st_proc = sysdate
                            where id = pk_csf_api_nfce.gt_row_Nota_Fiscal.id;
                            --
                            -- Variavel global usada em logs de triggers (limpa)
                            gv_objeto := 'pk_integr_view_nfce';
                            gn_fase   := null;
                            --
                        end if;
                        --
                     else -- Em caso de Notas emitidas por terceiros, situação fica como AUtorizada
                        --
                        -- Variavel global usada em logs de triggers (carrega)
                        gv_objeto := 'pk_integr_view_nfce.pkb_ler_Nota_Fiscal';
                        gn_fase   := vn_fase;
                        --
                        update Nota_Fiscal set dm_st_proc = 4
                                             , dt_st_proc = sysdate
                         where id = pk_csf_api_nfce.gt_row_Nota_Fiscal.id;
                        --
                        -- Variavel global usada em logs de triggers (limpa)
                        gv_objeto := 'pk_integr_view_nfce';
                        gn_fase   := null;
                        --
                     end if;
                     --
                  exception
                     when others then
                        --
                        pk_csf_api_nfce.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal fase(' || vn_fase || '):' || sqlerrm;
                        --
                        declare
                           vn_loggenerico_id  log_generico_nf.id%TYPE;
                        begin
                           --
                           pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                          , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                          , ev_resumo           => gv_cabec_nf
                                                          , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                                          , en_referencia_id    => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                                          , ev_obj_referencia   => 'NOTA_FISCAL' );
                           --
                        exception
                           when others then
                              null;
                        end;
                        --
                  end;
                  --
               end if;
               --
               vn_fase := 38;
               --
               commit;
               --
               -- Verifica se retorna a informação para o ERP
               if gn_dm_ret_infor_integr = 1 then
                  --
                  -- Chama a rotina que trabalha com a view VW_CSF_RESP_NF_ERP
                  pkb_int_infor_erp ( ev_cpf_cnpj_emit  => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                    , en_notafiscal_id  => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                    );
                  --
                  -- Chama a rotina que trabalha com a view VW_CSF_RESP_NF_ERP_NEO
                  pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit  => trim(vt_tab_csf_nota_fiscal(i).CPF_CNPJ_EMIT)
                                        , en_notafiscal_id  => pk_csf_api_nfce.gt_row_Nota_Fiscal.id
                                        );
                  --
               end if;
               --
            end if;
            --
            -- #69487 alteracao do local de validacao de qtds se der erro ou sucesso
            --
            pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
            --  
               -- Calcula a quantidade de registros integrados com sucesso
               -- e com erro para ser mostrado na tela de agendamento.
               --
               begin
                  --
                  if pk_agend_integr.gvtn_qtd_total(gv_cd_obj) >
                     (pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) + pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj)) then
                     --
                     if nvl(vt_log_generico_nf.count,0) > 0 then -- Erro de validação
                        --
                        pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
                        --
                     else
                        --
                        pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
                        --
                     end if;
                     --
                  end if;
                  --
               exception
                  when others then
                  null;
               end;
               --
         else
            --
            vn_fase := 39;
            -- Gerar log no agendamento devido a data de fechamento
            declare
               vn_loggenerico_id  log_generico_nf.id%type;
            begin
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => 'Integração de notas fiscais mercantis'
                                              , ev_resumo           => 'Período informado para integração da nota fiscal não permitido devido a data de '||
                                                                       'fechamento fiscal '||to_char(vd_dt_ult_fecha,'dd/mm/yyyy')||' - CNPJ/CPF: '||
                                                                       trim(vt_tab_csf_nota_fiscal(i).cpf_cnpj_emit)||', Número da NF: '||
                                                                       vt_tab_csf_nota_fiscal(i).nro_nf||', Série: '||trim(vt_tab_csf_nota_fiscal(i).serie)||'.'
                                              , en_tipo_log         => info_fechamento
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'NOTA_FISCAL'
                                              , en_empresa_id       => gn_empresa_id
                                              );
            exception
               when others then
                  null;
            end;
            --
         end if;
         --
         <<sair_integr>>
         --
         pk_csf_api_nfce.pkb_seta_referencia_id ( en_id => null );
         --
      end loop;
      --
   end if;
   --
   <<sair_geral>>
   --
   null;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal fase(' || vn_fase || ' cnpj:' || ev_cpf_cnpj_emit || '): ' || sqlerrm;
      --
      gv_resumo := null;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal;
--
-- ============================================================================================================================================= --
-- Procedimento para recuperar os dados de Mult-Org do Cancelamento
procedure pkb_nf_canc_multorg_ff( est_log_generico   in  out nocopy  dbms_sql.number_table
                                , ev_cpf_cnpj_emit   in              varchar2
                                , en_dm_ind_emit     in              number
                                , en_dm_ind_oper     in              number
                                , ev_cod_part        in              varchar2
                                , ev_cod_mod         in              varchar2
                                , ev_serie           in              varchar2
                                , en_nro_nf          in              number
                                , sn_multorg_id      in  out         mult_org.id%type ) is
   --
   vn_fase               number := 0;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   vv_cod                mult_org.cd%type;
   vv_hash               mult_org.hash%type;
   vv_cod_ret            mult_org.cd%type;
   vv_hash_ret           mult_org.hash%type;
   vn_multorg_id         mult_org.id%type := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gn_multorg_id, 0) <= 0 then
      --
      gn_multorg_id := pk_csf.fkg_multorg_id ( ev_multorg_cd => '1' );
      --
   end if;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_CANC_FF') = 0 then
      --
      sn_multorg_id := vn_multorg_id;
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nota_fiscal_canc_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_CANC_FF' );
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_sql := gv_sql || ' ORDER BY ' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_CANC_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_canc_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_nf_canc_multorg_ff fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                          , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                          , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                          , en_referencia_id    => null
                                          , ev_obj_referencia   => 'NOTA_FISCAL' );
           --
           raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_canc_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_canc_ff.first..vt_tab_csf_nota_fiscal_canc_ff.last loop
         --
         vn_fase := 7;
         --
         if vt_tab_csf_nota_fiscal_canc_ff(i).atributo in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            vn_fase := 8;
            -- Chama procedimento que faz a validação dos itens da Inventario - campos flex field.
            vv_cod_ret  := null;
            vv_hash_ret := null;
            --
            pk_csf_api_nfce.pkb_val_atrib_multorg ( est_log_generico     => est_log_generico
                                                  , ev_obj_name          => 'VW_CSF_NOTA_FISCAL_CANC_FF'
                                                  , ev_atributo          => vt_tab_csf_nota_fiscal_canc_ff(i).atributo
                                                  , ev_valor             => vt_tab_csf_nota_fiscal_canc_ff(i).valor
                                                  , sv_cod_mult_org      => vv_cod_ret
                                                  , sv_hash_mult_org     => vv_hash_ret
                                                  , en_referencia_id     => null
                                                  , ev_obj_referencia    => 'NOTA_FISCAL');
           --
           vn_fase := 9;
           --
           if vv_cod_ret is not null then
              vv_cod := vv_cod_ret;
           end if;
           --
           if vv_hash_ret is not null then
              vv_hash := vv_hash_ret;
           end if;
           --
        end if;
        --
      end loop;
      --
      vn_fase := 10;
      --
      if nvl(est_log_generico.count, 0) <= 0 then
         --
         vn_fase := 11;
         --
         vn_multorg_id := sn_multorg_id;
         --
         pk_csf_api_nfce.pkb_ret_multorg_id( est_log_generico   => est_log_generico
                                      , ev_cod_mult_org    => vv_cod
                                      , ev_hash_mult_org   => vv_hash
                                      , sn_multorg_id      => vn_multorg_id
                                      , en_referencia_id   => null
                                      , ev_obj_referencia  => 'NOTA_FISCAL'
                                      );
      end if;
      --
      vn_fase := 12;
      --
      sn_multorg_id := vn_multorg_id;
      --
   else
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Nota fiscal cadastrada com Mult Org default (codigo = 1), pois não foram passados o codigo e a hash do multorg.';
      --
      vn_loggenericonf_id := null;
      --
      vn_fase := 13;
      --
      pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                     , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                     , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                     , en_tipo_log         => pk_csf_api_nfce.INFORMACAO
                                     , en_referencia_id    => null
                                     , ev_obj_referencia   => 'NOTA_FISCAL'
                                     );
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_nf_canc_multorg_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
      --
end pkb_nf_canc_multorg_ff;
--
-- ============================================================================================================================================= --
-- Procedimento para recuperar os dados de Flex-Field do Cancelamento
procedure pkb_nf_canc_ff ( est_log_generico   in  out nocopy  dbms_sql.number_table
                         , ev_cpf_cnpj_emit   in              varchar2
                         , en_dm_ind_emit     in              number
                         , en_dm_ind_oper     in              number
                         , ev_cod_part        in              varchar2
                         , ev_cod_mod         in              varchar2
                         , ev_serie           in              varchar2
                         , en_nro_nf          in              number
                         ) is
   --
   vn_fase               number := 0;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_CANC_FF') = 0 then
      --
      pk_csf_api_nfce.gt_row_nota_fiscal_canc.dm_canc_extemp := 0;
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nota_fiscal_canc_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_CANC_FF' );
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_sql := gv_sql || ' ORDER BY ' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_CANC_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_canc_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_nf_canc_ff fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                          , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                          , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                          , en_referencia_id    => null
                                          , ev_obj_referencia   => 'NOTA_FISCAL' );
           --
           raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_canc_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_canc_ff.first..vt_tab_csf_nota_fiscal_canc_ff.last loop
         --
         vn_fase := 7;
         --
         if trim(vt_tab_csf_nota_fiscal_canc_ff(i).atributo) in ('DM_CANC_EXTEMP') then
            --
            vn_fase := 7.1;
            --
            pk_csf_api_nfce.gt_row_nota_fiscal_canc.dm_canc_extemp := vt_tab_csf_nota_fiscal_canc_ff(i).valor;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 10;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_nf_canc_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
      --
end pkb_nf_canc_ff;
--
-- ============================================================================================================================================= --
-- Ler a view VW_CSF_NOTA_FISCAL_CANC_FF por conta do atributo ID_ERP --
procedure pkb_ler_nf_canc_ff ( est_log_generico_nf  in out nocopy dbms_sql.number_table
                             , en_notafiscalcanc_id in number
                             --| Chava da view
                             , ev_cpf_cnpj_emit     in varchar2
                             , en_dm_ind_emit       in number
                             , en_dm_ind_oper       in number
                             , ev_cod_part          in varchar2
                             , ev_cod_mod           in varchar2
                             , ev_serie             in varchar2
                             , en_nro_nf            in number
                             ) is
   --
   vn_fase number;
   i pls_integer;
   --
   vn_loggenericonf_id number;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_CANC_FF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nota_fiscal_canc_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_CANC_FF' );
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 3;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_sql := gv_sql || ' ORDER BY ' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'COD_MOD' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_CANC_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_canc_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_nf_canc_multorg_ff fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                          , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                          , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                          , en_referencia_id    => null
                                          , ev_obj_referencia   => 'NOTA_FISCAL_CANC' );
           --
           raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_canc_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_canc_ff.first..vt_tab_csf_nota_fiscal_canc_ff.last loop
         --
         if vt_tab_csf_nota_fiscal_canc_ff(i).atributo not in ('COD_MULT_ORG','HASH_MULT_ORG','DM_CANC_EXTEMP') then
            --
            -- API para avaliar o atributo ID_ERP
            /*pk_csf_api_nfce.pkb_val_ler_nf_canc_ff ( est_log_generico_nf  => est_log_generico_nf
                                              , en_notafiscalcanc_id => en_notafiscalcanc_id
                                              , ev_atributo          => vt_tab_csf_nota_fiscal_canc_ff(i).atributo
                                              , ev_valor             => vt_tab_csf_nota_fiscal_canc_ff(i).valor
                                              );*/--
                                              NULL;
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_nf_canc_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'NOTA_FISCAL_CANC'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
      --
end pkb_ler_nf_canc_ff;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de notas fiscais canceladas
procedure pkb_ler_Nota_Fiscal_Canc ( ev_cpf_cnpj_emit in varchar2 ) is
   --
   vn_fase             number := 0;
   vt_log_generico_nf  dbms_sql.number_table;
   vn_notafiscal_id    Nota_Fiscal.id%TYPE;
   vn_empresa_id       Empresa.id%TYPE;
   vn_multorg_id       mult_org.id%type;
   i                   pls_integer;
   --
   procedure pkb_excluir_canc ( ev_cpf_cnpj_emit  in  varchar2
                              , en_dm_ind_emit    in  number
                              , en_dm_ind_oper    in  number
                              , ev_cod_part       in  varchar2
                              , ev_cod_mod        in  varchar2
                              , ev_serie          in  varchar2
                              , en_nro_nf         in  number
                              , en_notafiscal_id  in  number
                              )
   is
      --
      PRAGMA AUTONOMOUS_TRANSACTION;
      --
   begin
      --
      -- Delete da view pai de cancelamento de nota fiscal cancelada
      --
      vn_fase := 1;
      --
      gv_sql := 'delete ' || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_CANC');
      --
      vn_fase := 2;
      --
      gv_sql := gv_sql || ' where ' || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
      gv_sql := gv_sql || ' and '   || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
      gv_sql := gv_sql || ' and '   || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
      --
      if en_dm_ind_emit = 1 and trim(ev_cod_part) is null then
         --
         gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
         --
      end if;
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE'   || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'  || GV_ASPAS || ' = ' || en_nro_nf;
      --
      vn_fase := 3;
      --
      begin
         --
         execute immediate gv_sql;
         --
      exception
         when others then
            null;
      end;
      --
      commit;
      --
      -- Delete da view pai de cancelamento de nota fiscal cancelada - campos flex field
      --
      vn_fase := 4;
      --
      gv_sql := 'delete ' || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_CANC_FF');
      --
      vn_fase := 5;
      --
      gv_sql := gv_sql || ' where ' || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
      gv_sql := gv_sql || ' and '   || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
      gv_sql := gv_sql || ' and '   || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
      --
      if en_dm_ind_emit = 1 and trim(ev_cod_part) is null then
         --
         gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
         --
      end if;
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' = ' || '''' || ev_cod_mod || '''';
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE'   || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'  || GV_ASPAS || ' = ' || en_nro_nf;
      --
      vn_fase := 6;
      --
      begin
         --
         execute immediate gv_sql;
         --
      exception
         when others then
            null;
      end;
      --
      commit;
      --
   exception
      when others then
         --
         pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Canc.pkb_excluir_canc fase(' || vn_fase || '): ' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_nf.id%TYPE;
         begin
            --
            pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                           , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                           , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                           , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                           , en_referencia_id    => en_notafiscal_id
                                           , ev_obj_referencia   => 'NOTA_FISCAL' );
            --
         exception
            when others then
               null;
         end;
         --
   end pkb_excluir_canc;

begin
   --
   vn_fase := 1;
   --
   if nvl(gn_empresa_id, 0) <= 0 then
      --
      gn_multorg_id := pk_csf.fkg_multorg_id ( ev_multorg_cd => '1' );
      --
   else
      --
      gn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => gn_empresa_id );
      --
   end if;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_CANC') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nota_fiscal_canc.delete;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || 'a.'   || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'COD_MOD' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(a.' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DT_CANC' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'JUSTIF' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_CANC') || ' a';
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || 'a.' || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and a.' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS || ' = 0';
   gv_sql := gv_sql || ' and a.' || GV_ASPAS || 'COD_MOD' || GV_ASPAS || ' in ' || '(''' || '65' || ''')';
   --
   vn_fase := 3;
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_canc;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Canc fase(' || vn_fase || '):' || sqlerrm;
            --
         declare
            vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 4;
   --
   if vt_tab_csf_nota_fiscal_canc.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_canc.first..vt_tab_csf_nota_fiscal_canc.last loop
         --
         vn_fase := 5;
         --
         vt_log_generico_nf.delete;
         --
         vn_fase := 6;
         --
         if nvl(vn_multorg_id, 0) <= 0 then
            --
            vn_multorg_id := gn_multorg_id;
            --
         end if;
         --
         pkb_nf_canc_multorg_ff( est_log_generico  =>  vt_log_generico_nf
                               , ev_cpf_cnpj_emit  =>  vt_tab_csf_nota_fiscal_canc(i).cpf_cnpj_emit
                               , en_dm_ind_emit    =>  vt_tab_csf_nota_fiscal_canc(i).dm_ind_emit
                               , en_dm_ind_oper    =>  vt_tab_csf_nota_fiscal_canc(i).dm_ind_oper
                               , ev_cod_part       =>  vt_tab_csf_nota_fiscal_canc(i).cod_part
                               , ev_cod_mod        =>  vt_tab_csf_nota_fiscal_canc(i).cod_mod
                               , ev_serie          =>  vt_tab_csf_nota_fiscal_canc(i).serie
                               , en_nro_nf         =>  vt_tab_csf_nota_fiscal_canc(i).nro_nf
                               , sn_multorg_id     =>  vn_multorg_id );
         vn_fase := 6.1;
         --
         if nvl(vn_multorg_id, 0) <= 0 then
            --
            vn_multorg_id := gn_multorg_id;
            --
         elsif vn_multorg_id != gn_multorg_id then
            --
            vn_multorg_id := gn_multorg_id;
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Mult-org informado pelo usuario('||vn_multorg_id||') não corresponde ao Mult-org da empresa('||gn_multorg_id||').';
            --
            vn_fase := 6.2;
            --
            declare
               vn_loggenericonf_id  log_generico_nf.id%TYPE;
            begin
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => 'Mult-Org incorreto ou não informado.'
                                              , en_tipo_log         => pk_csf_api_nfce.INFORMACAO
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'NOTA_FISCAL'
                                              );
            exception
               when others then
                  null;
            end;
            --
         end if;
         --
         vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => gn_multorg_id
                                                              , ev_cpf_cnpj   => vt_tab_csf_nota_fiscal_canc(i).CPF_CNPJ_EMIT );
         --
         vn_fase := 7;
         -- Recupera o ID da nota fiscal
         vn_notafiscal_id := pk_csf.fkg_busca_notafiscal_id ( en_multorg_id   => vn_multorg_id
                                                            , en_empresa_id   => vn_empresa_id
                                                            , ev_cod_mod      => vt_tab_csf_nota_fiscal_canc(i).COD_MOD
                                                            , ev_serie        => vt_tab_csf_nota_fiscal_canc(i).SERIE
                                                            , en_nro_nf       => vt_tab_csf_nota_fiscal_canc(i).NRO_NF
                                                            , en_dm_ind_oper  => vt_tab_csf_nota_fiscal_canc(i).DM_IND_OPER
                                                            , en_dm_ind_emit  => vt_tab_csf_nota_fiscal_canc(i).DM_IND_EMIT
                                                            , ev_cod_part     => vt_tab_csf_nota_fiscal_canc(i).COD_PART );
         --
         vn_fase := 8;
         --
         pk_csf_api_nfce.pkb_seta_referencia_id ( en_id => vn_notafiscal_id );
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Canc := null;
         --
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Canc.notafiscal_id  := vn_notafiscal_id;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Canc.dt_canc        := vt_tab_csf_nota_fiscal_canc(i).dt_canc;
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Canc.justif         := trim(vt_tab_csf_nota_fiscal_canc(i).justif);
         pk_csf_api_nfce.gt_row_Nota_Fiscal_Canc.dm_st_integra  := 7; -- Integração por view de banco
         --
         vn_fase := 8.1;
         --
         pkb_nf_canc_ff ( est_log_generico  =>  vt_log_generico_nf
                        , ev_cpf_cnpj_emit  =>  vt_tab_csf_nota_fiscal_canc(i).cpf_cnpj_emit
                        , en_dm_ind_emit    =>  vt_tab_csf_nota_fiscal_canc(i).dm_ind_emit
                        , en_dm_ind_oper    =>  vt_tab_csf_nota_fiscal_canc(i).dm_ind_oper
                        , ev_cod_part       =>  vt_tab_csf_nota_fiscal_canc(i).cod_part
                        , ev_cod_mod        =>  vt_tab_csf_nota_fiscal_canc(i).cod_mod
                        , ev_serie          =>  vt_tab_csf_nota_fiscal_canc(i).serie
                        , en_nro_nf         =>  vt_tab_csf_nota_fiscal_canc(i).nro_nf
                        );
         --
         vn_fase := 9;
         -- Chama o procedimento de integração da Nota Fiscal Cancelada
         pk_csf_api_nfce.pkb_integr_Nota_Fiscal_Canc ( est_log_generico_nf          => vt_log_generico_nf
                                                , est_row_Nota_Fiscal_Canc  => pk_csf_api_nfce.gt_row_Nota_Fiscal_Canc );
         --
         commit;
         --
         vn_fase := 9.1;
         --
         -- Ler a view VW_CSF_NOTA_FISCAL_CANC_FF por conta do atributo ID_ERP
         if nvl(pk_csf_api_nfce.gt_row_Nota_Fiscal_Canc.id, 0) > 0 then
            --
            pkb_ler_nf_canc_ff ( est_log_generico_nf  => vt_log_generico_nf
                               , en_notafiscalcanc_id => pk_csf_api_nfce.gt_row_Nota_Fiscal_Canc.id
                               --| Chava da view
                               , ev_cpf_cnpj_emit     => vt_tab_csf_nota_fiscal_canc(i).cpf_cnpj_emit
                               , en_dm_ind_emit       => vt_tab_csf_nota_fiscal_canc(i).dm_ind_emit
                               , en_dm_ind_oper       => vt_tab_csf_nota_fiscal_canc(i).dm_ind_oper
                               , ev_cod_part          => vt_tab_csf_nota_fiscal_canc(i).cod_part
                               , ev_cod_mod           => vt_tab_csf_nota_fiscal_canc(i).cod_mod
                               , ev_serie             => vt_tab_csf_nota_fiscal_canc(i).serie
                               , en_nro_nf            => vt_tab_csf_nota_fiscal_canc(i).nro_nf
                               );
            --
         end if;
         --
         -- Se registrou algum log, altera a Nota Fiscal para dm_st_proc = 10 - "Erro de Validação", exclui o cancelamento
         -- Comentado pois esta dando muito problema! - 31/05/2010 - Leandro A. Savenhago
         --
         pkb_excluir_canc ( ev_cpf_cnpj_emit => vt_tab_csf_nota_fiscal_canc(i).cpf_cnpj_emit
                          , en_dm_ind_emit   => vt_tab_csf_nota_fiscal_canc(i).dm_ind_emit
                          , en_dm_ind_oper   => vt_tab_csf_nota_fiscal_canc(i).dm_ind_oper
                          , ev_cod_part      => vt_tab_csf_nota_fiscal_canc(i).cod_part
                          , ev_cod_mod       => vt_tab_csf_nota_fiscal_canc(i).cod_mod
                          , ev_serie         => vt_tab_csf_nota_fiscal_canc(i).serie
                          , en_nro_nf        => vt_tab_csf_nota_fiscal_canc(i).nro_nf
                          , en_notafiscal_id => vn_notafiscal_id
                          );
         --
         pk_csf_api_nfce.pkb_seta_referencia_id ( en_id => null );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_Nota_Fiscal_Canc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => vn_notafiscal_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Canc;
--
-- ============================================================================================================================================= --
-- Procedimento para recuperar o Mult-Org da Inutilização
procedure pkb_nota_fiscal_inu_multorg_ff( est_log_generico in out nocopy  dbms_sql.number_table
                                        , ev_cpf_cnpj_emit in             varchar2
                                        , en_ano           in             number
                                        , ev_serie         in             varchar2
                                        , en_nro_ini       in             number
                                        , en_nro_fim       in             number
                                        , sn_multorg_id       out         mult_org.id%type) is
   --
   vn_fase               number := 0;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   vv_cod                mult_org.cd%type;
   vv_hash               mult_org.hash%type;
   vv_cod_ret            mult_org.cd%type;
   vv_hash_ret           mult_org.hash%type;
   vn_multorg_id         mult_org.id%type := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_INUTILIZA_NOTAFISCAL_FF') = 0 then
      --
      sn_multorg_id := vn_multorg_id;
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nota_fiscal_inu_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ANO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', pk_csf.fkg_converte(' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_INI' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_FIM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   vn_fase := 2;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_INUTILIZA_NOTAFISCAL_FF' );
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'ANO' || GV_ASPAS || ' = ' || en_ano;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || ''''|| ev_serie||'''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_INI' || GV_ASPAS || ' = ' || en_nro_ini;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_FIM' || GV_ASPAS || ' = ' || en_nro_fim;
   --
   gv_sql := gv_sql || ' ORDER BY ' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'ANO' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'NRO_INI' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'NRO_FIM' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   vn_fase := 3;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_INUTILIZA_NOTAFISCAL_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_inu_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_nota_fiscal_inu_multorg_ff fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                          , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                          , ev_resumo           => 'Nota fiscal: serie - ' || ev_serie ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                          , en_referencia_id    => null
                                          , ev_obj_referencia   => 'NOTA_FISCAL' );
           --
           raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 4;
   --
   if vt_tab_csf_nota_fiscal_inu_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_inu_ff.first..vt_tab_csf_nota_fiscal_inu_ff.last loop
         --
         vn_fase := 5;
         --
         if vt_tab_csf_nota_fiscal_inu_ff(i).atributo in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            vn_fase := 6;
            -- Chama procedimento que faz a validação dos itens da Inventario - campos flex field.
            vv_cod_ret := null;
            vv_hash_ret := null;

            pk_csf_api_nfce.pkb_val_atrib_multorg ( est_log_generico     => est_log_generico
                                             , ev_obj_name          => 'VW_CSF_INUTILIZA_NOTAFISCAL_FF'
                                             , ev_atributo          => vt_tab_csf_nota_fiscal_inu_ff(i).atributo
                                             , ev_valor             => vt_tab_csf_nota_fiscal_inu_ff(i).valor
                                             , sv_cod_mult_org      => vv_cod_ret
                                             , sv_hash_mult_org     => vv_hash_ret
                                             , en_referencia_id     => null
                                             , ev_obj_referencia    => 'NOTA_FISCAL');
           --
           vn_fase := 7;
           --
           if vv_cod_ret is not null then
              vv_cod := vv_cod_ret;
           end if;
           --
           if vv_hash_ret is not null then
              vv_hash := vv_hash_ret;
           end if;
           --
        end if;
        --
      end loop;
      --
      vn_fase := 8;
      --
      if nvl(est_log_generico.count, 0) <= 0 then
         --
         vn_fase := 9;
         --
         pk_csf_api_nfce.pkb_ret_multorg_id( est_log_generico   => est_log_generico
                                      , ev_cod_mult_org    => vv_cod
                                      , ev_hash_mult_org   => vv_hash
                                      , sn_multorg_id      => vn_multorg_id
                                      , en_referencia_id   => null
                                      , ev_obj_referencia  => 'NOTA_FISCAL'
                                      );
      end if;
      --
      vn_fase := 10;
      --
      sn_multorg_id := vn_multorg_id;
      --
   else
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Nota fiscal cadastrada com Mult Org default (codigo = 1), pois não foram passados o codigo e a hash do multorg.';
      --
      vn_loggenericonf_id := null;
      --
      vn_fase := 11;
      --
      pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                     , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                     , ev_resumo           => 'Nota fiscal: serie - ' || ev_serie ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                     , en_tipo_log         => pk_csf_api_nfce.INFORMACAO
                                     , en_referencia_id    => null
                                     , ev_obj_referencia   => 'NOTA_FISCAL'
                                     );
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_nota_fiscal_inu_multorg_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => 'Nota fiscal: serie - ' || ev_serie ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_nfce.gv_mensagem_log);
      --
end pkb_nota_fiscal_inu_multorg_ff;
--
-- ============================================================================================================================================= --
-- Procedimento para atualizar a situação da inutilização da nota fiscal
procedure pkb_atual_st_proc_inut ( ev_cpf_cnpj_emit  in varchar2
                                 , en_ano            in number
                                 , ev_serie          in varchar2
                                 , en_nro_ini        in number
                                 , en_nro_fim        in number
                                 , en_dm_st_proc     in number default 0
                                 ) is
   --
   vn_fase number;
   vv_obj  varchar2(4000) := null;
   --
   PRAGMA AUTONOMOUS_TRANSACTION;
   --
begin
   --
   vn_fase := 1;
   --
   gv_sql := 'UPDATE ';

      if GV_NOME_DBLINK is not null then
         --
         vn_fase := 2;
         --
         vv_obj := GV_ASPAS || 'VW_CSF_INUTILIZA_NOTA_FISCAL' || GV_ASPAS || '@' || GV_NOME_DBLINK;
         --
      else
         --
         vn_fase := 3;
         --
         vv_obj := GV_ASPAS || 'VW_CSF_INUTILIZA_NOTA_FISCAL' || GV_ASPAS;
         --
      end if;
   --
   gv_sql := gv_sql || vv_obj;
   --
   gv_sql := gv_sql || ' set ' || GV_ASPAS || 'DM_ST_PROC' || GV_ASPAS || ' = ' || en_dm_st_proc;
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || ' where ' || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'ANO' || GV_ASPAS || ' = ' || en_ano;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'SERIE' || GV_ASPAS || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_INI' || GV_ASPAS || ' = ' || en_nro_ini;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_FIM' || GV_ASPAS || ' = ' || en_nro_fim;
   --
   vn_fase := 5;
   --
   begin
      --
      execute immediate gv_sql;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode in (-942, -1031, -28500) then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na Erro na pk_integr_view_nfce.pkb_atual_st_proc_inut fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'INUTILIZA_NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
      --
   end;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_atual_st_proc_inut fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => null
                                        , ev_obj_referencia   => 'INUTILIZA_NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_atual_st_proc_inut;
--
-- ============================================================================================================================================= --
-- Procedimento de leitura de Inutilização de Nota Fiscal
procedure pkb_ler_inutiliza_nf ( ev_cpf_cnpj_emit in varchar2 ) is
   --
   vn_fase             number := 0;
   vt_log_generico_nf  dbms_sql.number_table;
   vn_notafiscal_id    Nota_Fiscal.id%TYPE;
   vn_empresa_id       Empresa.id%TYPE;
   vn_multorg_id       mult_org.id%type;
   gv_sql              varchar2(4000) := null;
   vn_qtde             number;
   i                   pls_integer;
   vn_dm_tp_amb        empresa.dm_tp_amb%type;
   vv_ibge_estado      estado.ibge_estado%type := null;
   vv_cnpj             varchar2(14) := null;
   vn_dm_tipo_integr   empresa.dm_tipo_integr%type := null;
   vv_cod_mod          mod_fiscal.cod_mod%type := null;
   vv_id_inut          inutiliza_nota_fiscal.id_inut%type := null;
   vn_inutilizanf_id   inutiliza_nota_fiscal.id%type := null;
   vn_erro             number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_INUTILIZA_NOTA_FISCAL') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_inutiliza_nf.delete;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||   'a.' || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'ANO' || GV_ASPAS;
   gv_sql := gv_sql || ', pk_csf.fkg_converte(a.' || GV_ASPAS || 'SERIE' || GV_ASPAS || ') ';
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'NRO_INI' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'NRO_FIM' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'JUSTIF' || GV_ASPAS;
   gv_sql := gv_sql || ', a.' || GV_ASPAS || 'DM_ST_PROC' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_INUTILIZA_NOTA_FISCAL') || ' a';
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || 'a.' || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and a.' || GV_ASPAS || 'DM_ST_PROC' || GV_ASPAS || ' = 0';
   --
   vn_fase := 3;
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_inutiliza_nf;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_inutiliza_nf fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
            vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'INUTILIZA_NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   COMMIT;
   --
   vn_fase := 4;
   --
   if vt_tab_csf_inutiliza_nf.count > 0 then
      --
      for i in vt_tab_csf_inutiliza_nf.first..vt_tab_csf_inutiliza_nf.last loop
         --
         vn_fase := 5;
         --
         vt_log_generico_nf.delete;
         --
         vn_fase := 6;
         --
         pkb_nota_fiscal_inu_multorg_ff( est_log_generico  =>  vt_log_generico_nf
                                       , ev_cpf_cnpj_emit  =>  vt_tab_csf_inutiliza_nf(i).cpf_cnpj_emit
                                       , en_ano            =>  vt_tab_csf_inutiliza_nf(i).ano
                                       , ev_serie          =>  vt_tab_csf_inutiliza_nf(i).serie
                                       , en_nro_ini        =>  vt_tab_csf_inutiliza_nf(i).nro_ini
                                       , en_nro_fim        =>  vt_tab_csf_inutiliza_nf(i).nro_fim
                                       , sn_multorg_id     =>  vn_multorg_id );
         vn_fase := 6.1;
         --
         if nvl(vn_multorg_id, 0) <= 0 then
            --
            vn_multorg_id := gn_multorg_id;
            --
         elsif vn_multorg_id != gn_multorg_id then
            --
            vn_multorg_id := gn_multorg_id;
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Mult-org informado pelo usuario('||vn_multorg_id||') não corresponde ao Mult-org da empresa('||gn_multorg_id||').';
            --
            vn_fase := 6.2;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%type;
            begin
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => 'Mult-Org incorreto ou não informado.'
                                              , en_tipo_log         => pk_csf_api_nfce.INFORMACAO
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'NOTA_FISCAL'
                                              );
            --
            exception
               when others then
                  null;
            end;
            --
         end if;
         --
         vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => vn_multorg_id
                                                              , ev_cpf_cnpj   => vt_tab_csf_inutiliza_nf(i).CPF_CNPJ_EMIT );
         --
         vn_fase := 7;
         -- verifica se existe inutilizacao
         begin
            --
            select count(1)
              into vn_qtde
              from inutiliza_nota_fiscal inf
             where inf.empresa_id  = vn_empresa_id
               and inf.serie       = trim(vt_tab_csf_inutiliza_nf(i).serie)
               and inf.nro_ini     = vt_tab_csf_inutiliza_nf(i).nro_ini
               and inf.nro_fim     = vt_tab_csf_inutiliza_nf(i).nro_fim;
            --
         exception
            when others then
               vn_qtde := 0;
         end;
         --
         vn_fase := 8;
         --
         if nvl(vn_qtde,0) <= 0 then
           --
           vn_fase := 9;
           --
           begin
              --
              select e.dm_tp_amb
                   , es.ibge_estado
                   , (lpad(j.num_cnpj, 8, '0') || lpad(j.num_filial, 4, '0') || lpad(j.dig_cnpj, 2, '0')) cnpj
                   , e.dm_tipo_integr
                into vn_dm_tp_amb
                   , vv_ibge_estado
                   , vv_cnpj
                   , vn_dm_tipo_integr
                from empresa     e
                   , pessoa      p
                   , juridica    j
                   , cidade      c
                   , estado      es
               where e.id        = vn_empresa_id
                 and p.id        = e.pessoa_id
                 and j.pessoa_id = p.id
                 and c.id        = p.cidade_id
                 and es.id       = c.estado_id;
                 --
           exception
              when others then
                 vn_dm_tp_amb        := null;
                 vv_ibge_estado      := null;
                 vv_cnpj             := null;
                 vn_dm_tipo_integr   := null;
           end;
           --
           vv_cod_mod := '65';
           --
           vv_id_inut := (   'ID'
                          || vv_ibge_estado
                          || substr(to_number(to_char(sysdate, 'RRRR')), 3, 2)
                          || vv_cnpj
                          || vv_cod_mod
                          || lpad(trim(vt_tab_csf_inutiliza_nf(i).serie), 3, '0')
                          || lpad(vt_tab_csf_inutiliza_nf(i).nro_ini, 9, '0')
                          || lpad(vt_tab_csf_inutiliza_nf(i).nro_fim, 9, '0')
                          );
           --
           select inutilizanf_seq.nextval
             into vn_inutilizanf_id
             from dual;
           --
           vn_fase := 10;
           --
           begin
              --
              insert into inutiliza_nota_fiscal ( id
                                                , empresa_id
                                                , dm_situacao
                                                , dm_tp_amb
                                                , dm_forma_emiss
                                                , dt_inut
                                                , uf_ibge
                                                , ano
                                                , cnpj
                                                , modfiscal_id
                                                , serie
                                                , nro_ini
                                                , nro_fim
                                                , justif
                                                , id_inut
                                                , dm_st_integra
                                                , dm_integr_nf
                                                )
                                         values ( vn_inutilizanf_id
                                                , vn_empresa_id
                                                , 5 -- dm_situacao
                                                , vn_dm_tp_amb
                                                , 1
                                                , sysdate
                                                , vv_ibge_estado
                                                , to_number(to_char(sysdate, 'RRRR'))
                                                , vv_cnpj
                                                , 31
                                                , TRIM(vt_tab_csf_inutiliza_nf(i).serie)
                                                , vt_tab_csf_inutiliza_nf(i).nro_ini
                                                , vt_tab_csf_inutiliza_nf(i).nro_fim
                                                , trim ( pk_csf.fkg_converte ( vt_tab_csf_inutiliza_nf(i).justif ) )
                                                , vv_id_inut
                                                , 7 -- Table/View
                                                , 0 -- sem nota fiscal
                                                );
              --
           exception
              when others then
                 --
                 pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_inutiliza_nf fase(' || vn_fase || '):' || sqlerrm;
                 --
                 declare
                 vn_loggenerico_id  log_generico_nf.id%TYPE;
                 begin
                    --
                    pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                   , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                                   , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                                   , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                                   , en_referencia_id    => null
                                                   , ev_obj_referencia   => 'INUTILIZA_NOTA_FISCAL' );
                    --
                 exception
                    when others then
                       null;
                 end;
                 --
                 vn_erro := 1;
                 -- registra o erro para o ERP
                 pkb_atual_st_proc_inut ( ev_cpf_cnpj_emit  => vt_tab_csf_inutiliza_nf(i).CPF_CNPJ_EMIT
                                   , en_ano            => vt_tab_csf_inutiliza_nf(i).ano
                                   , ev_serie          => vt_tab_csf_inutiliza_nf(i).serie
                                   , en_nro_ini        => vt_tab_csf_inutiliza_nf(i).nro_ini
                                   , en_nro_fim        => vt_tab_csf_inutiliza_nf(i).nro_fim
                                   , en_dm_st_proc     => 2 -- Erro
                                   );
           end;
           --
         end if;
         --
         COMMIT;
         --
         vn_fase := 11;
         --
         if vn_erro = 0 then
            --
            -- registra o erro para o ERP
            pkb_atual_st_proc_inut ( ev_cpf_cnpj_emit  => vt_tab_csf_inutiliza_nf(i).CPF_CNPJ_EMIT
                                   , en_ano            => vt_tab_csf_inutiliza_nf(i).ano
                                   , ev_serie          => vt_tab_csf_inutiliza_nf(i).serie
                                   , en_nro_ini        => vt_tab_csf_inutiliza_nf(i).nro_ini
                                   , en_nro_fim        => vt_tab_csf_inutiliza_nf(i).nro_fim
                                   , en_dm_st_proc     => 1 -- integrado
                                   );
            --
         end if;
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_inutiliza_nf fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => vn_notafiscal_id
                                        , ev_obj_referencia   => 'INUTILIZA_NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_inutiliza_nf;
--
-- ============================================================================================================================================= --
-- Procedimento de integração de chave de acesso de NFe, para o registro do recebimento físico da mercadoria e consulta na Sefaz
procedure pkb_ler_cons_chave_nfe ( ev_cpf_cnpj_emit in varchar2 ) is
   --
   vn_fase         number := 0;
   i               pls_integer;
   vt_log_generico_nf dbms_sql.number_table;
   --
begin
   --
   vt_log_generico_nf.delete;
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_CONS_CHAVE_NFE') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'UNID_ORG' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_CHAVE_NFE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_SITUACAO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'CSTAT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'XMOTIVO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DHRECBTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NPROT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_LEITURA' || GV_ASPAS;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_CONS_CHAVE_NFE');
   --
   vn_fase := 2;
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_SITUACAO' || GV_ASPAS || ' = 0';
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_CONS_CHAVE_NFE' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_cons_chave_nfe;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_cons_chave_nfe fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                              , en_referencia_id    => null
                                              , ev_obj_referencia   => 'CSF_CONS_SIT' );
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_nfce.pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                                                 , est_log_generico_nf => vt_log_generico_nf );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 3;
   --
   if vt_tab_csf_cons_chave_nfe.count > 0 then
      --
      for i in vt_tab_csf_cons_chave_nfe.first..vt_tab_csf_cons_chave_nfe.last loop
         --
         vn_fase := 4;
         --
         pk_csf_api_nfce.gt_row_csf_cons_sit                 := null;
         pk_csf_api_nfce.gt_row_csf_cons_sit.chnfe           := vt_tab_csf_cons_chave_nfe(i).nro_chave_nfe;
         --
         vn_fase := 5;
         --
         pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe ( est_log_generico_nf  => vt_log_generico_nf
                                                       , est_row_csf_cons_sit => pk_csf_api_nfce.gt_row_csf_cons_sit
                                                       , ev_cpf_cnpj_emit     => vt_tab_csf_cons_chave_nfe(i).cpf_cnpj_emit
                                                       , en_multorg_id        => gn_multorg_id
                                                       , ev_rotina            => 'pk_integr_view_nfce.pkb_ler_cons_chave_nfe' );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
   --
    pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_ler_cons_chave_nfe fase(' || vn_fase || '):' || sqlerrm;
    --
    declare
       vn_loggenerico_id  log_generico_nf.id%TYPE;
    begin
       --
       pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                      , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                      , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                      , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                      , en_referencia_id    => null
                                      , ev_obj_referencia   => 'CSF_CONS_SIT'
                                      );
       --
    exception
       when others then
          null;
    end;
   --
end pkb_ler_cons_chave_nfe;
--
-- ============================================================================================================================================= --
-- Executa procedure do SUPERUS
procedure pkb_superus ( ED_DT_INI        IN DATE
                      , ED_DT_FIN        IN DATE
                      , ev_cpf_cnpj_emit in varchar2 default null
                      ) is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'PK_INT_NF_SUPERUS') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   gv_sql := 'begin PK_INT_NF_SUPERUS.PKB_INTEGRACAO (' ||
                        '''' || to_date(ed_dt_ini, gd_formato_dt_erp) || '''' || ', ' ||
                        '''' || to_date(ed_dt_fin, gd_formato_dt_erp) || '''' || ', ' ||
                        '''' || trim(ev_cpf_cnpj_emit) || '''' ||
                        ' ); end;';
   --
   begin
      --
      execute immediate gv_sql;
      --
   exception
      when others then
         -- não registra erro scasa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfce.gv_cabec_log := 'Erro na pk_integr_view_nfce.pkb_superus fase('||vn_fase||'): '||sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%type;
            begin
               --
               pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                              , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                              , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                              , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                              , en_referencia_id    => pk_agend_integr.gn_referencia_id
                                              , ev_obj_referencia   => pk_agend_integr.gv_obj_referencia
                                              );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
EXCEPTION
   when others then
      --
      pk_csf_api_nfce.gv_cabec_log := 'Erro na pk_integr_view_nfce.pkb_superus fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_cabec_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id    => pk_agend_integr.gn_referencia_id
                                        , ev_obj_referencia   => pk_agend_integr.gv_obj_referencia
                                        );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_superus;
--
-- ============================================================================================================================================= --
-- Executa procedure Stafe
procedure pkb_stafe ( ev_cpf_cnpj in varchar2
                    , ed_dt_ini   in date
                    , ed_dt_fin   in date
                    ) is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'PK_INT_NF_STAFE_CSF') = 0 then
      --
      return;
      --
   end if;
   --
   if length(ev_cpf_cnpj) in (11, 14) then
      --
      vn_fase := 2;
      --
      gv_sql := 'begin PK_INT_NF_STAFE_CSF.PB_GERA(' ||
                           ev_cpf_cnpj || ', ' ||
                           '''' || to_date(ed_dt_ini, gd_formato_dt_erp) || '''' || ', ' ||
                           '''' || to_date(ed_dt_fin, gd_formato_dt_erp) || '''' || ' ); end;';
      --
      begin
         --
         execute immediate gv_sql;
         --
      exception
         when others then
            -- não registra erro casa a view não exista
            if sqlcode = -942 then
               null;
            else
               --
               pk_csf_api_nfce.gv_mensagem_log := 'Erro na pkb_stafe fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  Log_Generico.id%TYPE;
               begin
                  --
                  pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                 , ev_mensagem           => pk_csf_api_nfce.gv_mensagem_log
                                                 , ev_resumo             => pk_csf_api_nfce.gv_mensagem_log
                                                 , en_tipo_log           => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                                 , en_referencia_id      => null
                                                 , ev_obj_referencia     => pk_csf_api_nfce.gv_obj_referencia
                                                 , en_empresa_id         => gn_empresa_id
                                                 );
                  --
               exception
                  when others then
                     null;
               end;
               --
               --raise_application_error (-20101, gv_mensagem_log);
               --
            end if;
      end;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pkb_stafe fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem           => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo             => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log           => pk_csf_api_nfce.ERRO_DE_SISTEMA
                                        , en_referencia_id      => null
                                        , ev_obj_referencia     => pk_csf_api_nfce.gv_obj_referencia
                                        , en_empresa_id         => gn_empresa_id
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      --raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_stafe;
--
-- ============================================================================================================================================= --
-- Procedimento Gera o Retorno para o ERP com a Integração em Bloco
procedure pkb_gera_retorno_bloco ( en_paramintegrdados_id in param_integr_dados.id%type ) is
   --
   vn_fase number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , pid.owner_obj
        , pid.nome_dblink
        , pid.dm_util_aspa
        , pid.dm_ret_infor_integr
        , pid.formato_dt_erp
        , e.multorg_id
     from param_integr_dados pid
        , param_integr_dados_empresa p
        , empresa e
    where pid.id                 = en_paramintegrdados_id
      and p.paramintegrdados_id  = pid.id
      and e.id                   = p.empresa_id
    order by 1;

begin
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   gv_sist_orig := null;
   --
   vn_fase := 2;
   --
   pk_csf_api_nfce.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      gn_multorg_id := rec.multorg_id;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      --
      vn_fase := 3.1;
      -- Se ta o DBLink
      GV_NOME_DBLINK := rec.nome_dblink;
      GV_OWNER_OBJ := rec.owner_obj;
      --
      vn_fase := 4;
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         GV_ASPAS := '"';
         --
      else
         --
         GV_ASPAS := null;
         --
      end if;
      --
      gn_dm_ret_infor_integr := nvl(rec.dm_ret_infor_integr,0);
      --
      vn_fase := 5;
      -- Verifica se retorna a informação para o ERP
      if rec.dm_ret_infor_integr = 1 then
         --
         vn_fase := 6;
         --  Seta formata da data para os procedimentos de retorno
         if trim(rec.formato_dt_erp) is not null then
            gd_formato_dt_erp := rec.formato_dt_erp;
         else
            gd_formato_dt_erp := gv_formato_data;
         end if;
         --
         vn_fase := 7;
         -- Integra a informação para o ERP - VW_CSF_RESP_NF_ERP
         pkb_int_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 8;
         -- retorna a informação para o ERP - VW_CSF_RESP_NF_ERP
         pkb_ret_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 9;
         -- Integra a informação para o ERP - NEO - VW_CSF_RESP_NF_ERP_NEO
         pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10;
         -- retorna a informação para o ERP - NEO - VW_CSF_RESP_NF_ERP_NEO
         pkb_ret_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
      end if;
      --
      commit;
      --
   end loop;
   --
   vn_fase := 10;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api_nfce.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 11;
   --
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_gera_retorno_bloco fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_gera_retorno_bloco;
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração de Notas Fiscais Eletrônicas de Emissão Própria por meio da integração por Bloco
procedure pkb_int_bloco ( en_paramintegrdados_id  in param_integr_dados.id%type
                        , en_dm_ind_emit          in nota_fiscal.dm_ind_emit%type
                        , ed_dt_ini               in date default null
                        , ed_dt_fin               in date default null
                        , en_empresa_id           in empresa.id%type default null
                        ) is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.multorg_id
     from param_integr_dados_empresa p
        , empresa e
    where p.paramintegrdados_id = en_paramintegrdados_id
      and p.empresa_id          = nvl(en_empresa_id, p.empresa_id)
      and e.id                  = p.empresa_id
      and e.dm_situacao         = 1
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 2;
   --
   pk_csf_api_nfce.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      gn_multorg_id := rec.multorg_id;
      gn_empresa_id := rec.empresa_id;
      --
      vn_fase := 3.1;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      --
      vn_fase := 3.2;
      -- seta "where" para pesquisa de Nfe de emissão própria
      if nvl(en_dm_ind_emit, -1) in (0, 1) then
         gv_where := ' and a.DM_IND_EMIT  = ' || en_dm_ind_emit;
      end if;
      --
      vn_fase := 3.3;
      --
      gd_formato_dt_erp := gv_formato_data;
      --
      if ed_dt_ini is not null and ed_dt_fin is not null then
         --
         --gv_where := ' AND (a.' || GV_ASPAS || 'DT_SAI_ENT' || GV_ASPAS || ' >= ' || '''' || to_char(ed_dt_ini, gd_formato_dt_erp) || '''' ||
         --             ' AND a.' || GV_ASPAS || 'DT_SAI_ENT' || GV_ASPAS || ' <= ' || '''' || to_char(ed_dt_fin, gd_formato_dt_erp) || '''' || ')';
         --
         gv_where := ' and (trunc(a.' || GV_ASPAS || 'DT_SAI_ENT' || GV_ASPAS || ') >= ' || '''' || to_char(ed_dt_ini, gd_formato_dt_erp) || '''' ||
                      ' and trunc(a.' || GV_ASPAS || 'DT_SAI_ENT' || GV_ASPAS || ') <= ' || '''' || to_char(ed_dt_fin, gd_formato_dt_erp) || '''' || ')';
         --
      end if;
      --
      vn_fase := 4;
      --
      gv_nome_dblink   := null;
      gv_owner_obj     := null;
      gv_sist_orig     := null;
      gn_dm_ind_emit   := null;
      gd_dt_ini_integr := null;
      --
      gn_dm_ret_infor_integr := 0;
      --
      vn_fase := 5;
      -- leitura das Notas Fiscais
      pkb_ler_Nota_Fiscal( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 6;
      -- leitura de notas fiscais canceladas
      pkb_ler_Nota_Fiscal_Canc( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 7;
      -- Leitura de inutilizações
      pkb_ler_inutiliza_nf ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
   end loop;
   --
   vn_fase := 8;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api_nfce.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 9;
   --
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_int_bloco fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_bloco;
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração de Notas Fiscais através do Mult-Org.
-- Esse processo estará sendo executado por JOB SCHEDULER, especifícamente para Ambiente Amazon.
-- A rotina deverá executar o mesmo procedimento da rotina pkb_integracao, porém com a identificação da mult-org.
procedure pkb_integr_multorg ( en_multorg_id in mult_org.id%type ) is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , eib.id
        , e.dt_ini_integr
        , e.dm_ret_nfe_terc_erp
        , eib.id empresaintegrbanco_id
        , eib.owner_obj
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
        , e.multorg_id
     from empresa e
        , empresa_integr_banco eib
    where e.multorg_id      = en_multorg_id
      and e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao     = 1 -- Ativa
      and eib.empresa_id    = e.id
    order by 1, 2;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   vn_fase := 1;
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 2;
   --
   pk_csf_api_nfce.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      gn_multorg_id := rec.multorg_id;
      --
      vn_fase := 3.1;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      --
      vn_fase := 3.2;
      -- Seta as configurações de banco
      gn_empresaintegrbanco_id := rec.empresaintegrbanco_id;
      gv_nome_dblink           := rec.nome_dblink;
      gv_owner_obj             := rec.owner_obj;
      gd_dt_ini_integr         := trunc(rec.dt_ini_integr);
      gn_empresa_id            := rec.empresa_id;
      --
      vn_fase := 4;
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         gv_aspas := '"';
         --
      else
         --
         gv_aspas := null;
         --
      end if;
      --
      vn_fase := 5;
      -- seta "where" para pesquisa de Nfe de emissão própria
      pkb_seta_where_emissao_propria;
      --
      vn_fase := 6;
      --  Seta o formato de data para os procedimentos de retorno
      gn_dm_form_dt_erp := rec.dm_form_dt_erp;
      --
      if nvl(rec.dm_form_dt_erp,0) = 1
         and trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := rec.formato_dt_erp;
      else
         gd_formato_dt_erp := gv_formato_data;
      end if;
      --
      gn_dm_ret_infor_integr := nvl(rec.dm_ret_infor_integr,0);
      --
      vn_fase := 7;
      -- leitura das Notas Fiscais
      pkb_ler_Nota_Fiscal( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 8;
      -- leitura de notas fiscais canceladas
      pkb_ler_Nota_Fiscal_Canc( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 9;
      -- Leitura de intulizações
      pkb_ler_inutiliza_nf ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 10;
      -- Verifica se retorna a informação para o ERP
      if gn_dm_ret_infor_integr = 1 then
         --
         vn_fase := 10.1;
         -- Integra a informação para o ERP - VW_CSF_RESP_NF_ERP
         pkb_int_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10.2;
         -- retorna a informação para o ERP - VW_CSF_RESP_NF_ERP
         pkb_ret_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10.3;
         -- Integra a informação para o ERP - VW_CSF_RESP_NF_ERP_NEO
         pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10.4;
         -- retorna a informação para o ERP - VW_CSF_RESP_NF_ERP_NEO
         pkb_ret_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
      end if;
      --
      vn_fase := 11;
      -- Procedimento integra as consultas de NFe com o ERP
      if rec.dm_ret_nfe_terc_erp = 0 then -- Parametro que retorna Notas Fiscais de terceiros para o ERP está habilitado
         -- Apenas se não retorna os dados para o ERP de XML de Armazenamento de Terceiro
         pkb_int_csf_cons_sit ( en_empresa_id   => rec.empresa_id
                              , ev_nome_dblink  => gv_nome_dblink
                              , ev_aspas        => gv_aspas
                              , ev_owner_obj    => gv_owner_obj
                              );
         --
      end if;
      --
      vn_fase := 12;
      --
      pkb_ler_cons_chave_nfe ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 13;
      --
      pkb_ret_cons_erp ( en_empresa_id => rec.empresa_id );
      --
   end loop;
   --
   vn_fase := 14;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api_nfce.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 15;
   --
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_integr_multorg fase(' || vn_fase || ') empresa (' || vv_cpf_cnpj_emit || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_multorg;
--
-- ============================================================================================================================================= --
-- Procedimento de integração por período informando todas empresas ativas
procedure pkb_integr_perido_geral ( en_multorg_id in mult_org.id%type
                                  , ed_dt_ini     in date
                                  , ed_dt_fin     in date
                                  ) is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.multorg_id
     from empresa e
    where e.multorg_id  = en_multorg_id
      and e.dm_situacao = 1 -- Ativa
    order by 1;
   --
   cursor c_dados ( en_empresa_id number )is
   select eib.owner_obj
        , eib.nome_dblink
     from empresa e
        , empresa_integr_banco eib
    where e.id             = en_empresa_id
      AND e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
      and eib.empresa_id   = e.id
      and eib.dm_ret_infor_integr = 1 -- retorna a informação para o ERP
    order by 1;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 1.1;
   --
   --pkb_superus ( ed_dt_ini => ed_dt_ini
   --            , ed_dt_fin => ed_dt_fin
   --            ); 
   --
   vn_fase := 2;
   --
   pk_csf_api_nfce.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      gn_multorg_id := rec.multorg_id;
      gn_empresa_id := rec.empresa_id;
      --
      vn_fase := 3.1;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      --
      vn_fase := 3.2;
      --
      gv_nome_dblink    := null;
      gv_owner_obj      := null;
      gv_sist_orig      := null;
      gn_dm_ind_emit    := null;
      gd_dt_ini_integr  := null;
      --
      open c_dados (rec.empresa_id);
      fetch c_dados into gv_owner_obj
                       , gv_nome_dblink;
      close c_dados;
      --
      gd_formato_dt_erp := gv_formato_data;
      --
      vn_fase := 4;
      --
      --pkb_stafe ( ev_cpf_cnpj => vv_cpf_cnpj_emit
      --          , ed_dt_ini   => ed_dt_ini
      --          , ed_dt_fin   => ed_dt_fin
      --          ); 
      --
      vn_fase := 5;
      -- seta "where" para pesquisa por período
      pkb_seta_where_periodo ( ed_dt_ini  => ed_dt_ini
                             , ed_dt_fin  => ed_dt_fin );
      --
      vn_fase := 6;
      --
      gn_dm_ret_infor_integr := 0;
      --
      vn_fase := 7;
      -- leitura das Notas Fiscais
      pkb_ler_Nota_Fiscal( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
   end loop;
   --
   vn_fase := 8;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api_nfce.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 9;
   --
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_integr_perido_geral fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_perido_geral;
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração Normal de Notas Fiscais, recuperando todas as empresas
procedure pkb_integr_periodo_normal ( ed_dt_ini       in  date
                                    , ed_dt_fin       in  date
                                    , en_dm_ind_emit  in  nota_fiscal.dm_ind_emit%type default null
                                    ) is
   --
   vn_fase          number := 0;
   --
   cursor c_empr is
   select e.id empresa_id
     from empresa e
    where e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 2;
      --
      pkb_integr_periodo ( en_empresa_id   => rec.empresa_id
                         , ed_dt_ini       => ed_dt_ini
                         , ed_dt_fin       => ed_dt_fin
                         , en_dm_ind_emit  => en_dm_ind_emit
                         );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_integr_periodo_normal fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_periodo_normal;
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração de Notas Fiscais por empresa e período
procedure pkb_integr_periodo ( en_empresa_id   in  empresa.id%type
                             , ed_dt_ini       in  date
                             , ed_dt_fin       in  date
                             , en_dm_ind_emit  in  nota_fiscal.dm_ind_emit%type default null
                             ) is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.owner_obj
        , eib.id empresaintegrbanco_id
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
        , e.multorg_id
     from empresa e
        , empresa_integr_banco eib
    where e.id          = en_empresa_id
      and e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
      and eib.empresa_id   = e.id
    order by 1;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   vn_fase := 1;
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 2;
   --
   pk_csf_api_nfce.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   if nvl(en_dm_ind_emit,0) = 1 then
      gn_dm_ind_emit := en_dm_ind_emit;
   else
      gn_dm_ind_emit := null;
   end if;
   --
   vn_fase := 3;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 4;
      --
      gn_multorg_id := rec.multorg_id;
      --
      vn_fase := 4.1;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      --
      vn_fase := 4.2;
      --
      pkb_superus ( ed_dt_ini        => ed_dt_ini
                  , ed_dt_fin        => ed_dt_fin
                  , ev_cpf_cnpj_emit => vv_cpf_cnpj_emit
                  );
      --
      vn_fase := 5;
      -- Seta o DBLink
      gn_empresaintegrbanco_id := rec.empresaintegrbanco_id;
      gv_nome_dblink           := rec.nome_dblink;
      gv_owner_obj             := rec.owner_obj;
      gd_dt_ini_integr         := null;
      gn_dm_ret_infor_integr   := nvl(rec.dm_ret_infor_integr,0);
      gn_empresa_id            := rec.empresa_id;
      --
      vn_fase := 6;
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         gv_aspas := '"';
         --
      else
         --
         gv_aspas := null;
         --
      end if;
      --
      vn_fase := 7;
      --  Seta formata da data para os procedimentos de retorno
      gn_dm_form_dt_erp := rec.dm_form_dt_erp;
      --
      if nvl(rec.dm_form_dt_erp,0) = 1
         and trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := rec.formato_dt_erp;
      else
         gd_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 7.1;
      --
      pkb_stafe ( ev_cpf_cnpj => vv_cpf_cnpj_emit
                , ed_dt_ini   => ed_dt_ini
                , ed_dt_fin   => ed_dt_fin
                );
      --
      vn_fase := 8;
      -- seta "where" para pesquisa por período
      pkb_seta_where_periodo ( ed_dt_ini => ed_dt_ini
                             , ed_dt_fin => ed_dt_fin );
      --
      vn_fase := 9;
      -- leitura das Notas Fiscais
      pkb_ler_Nota_Fiscal( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
   end loop;
   --
   vn_fase := 10;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api_nfce.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 11;
   --
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_integr_periodo fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.erro_de_sistema );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_periodo;
--
-- ============================================================================================================================================= --
-- Procedimento que inicia a integração de Notas Fiscais Eletrônicas de Emissão Própria por meio de leitura de views
procedure pkb_integracao ( ev_sist_orig in varchar2 default null ) is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , eib.id
        , e.dt_ini_integr
        , e.dm_ret_nfe_terc_erp
        , eib.id empresaintegrbanco_id
        , eib.owner_obj
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
        , e.multorg_id
     from empresa e
        , empresa_integr_banco eib
    where e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
      and eib.empresa_id   = e.id
    order by 1, 2;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   vn_fase := 1;
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   gv_sist_orig := trim(ev_sist_orig);
   --
   vn_fase := 2;
   --
   pk_csf_api_nfce.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      gn_multorg_id := rec.multorg_id;
      --
      vn_fase := 3.1;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      --
      vn_fase := 3.2;
      -- Seta as configurações de banco
      gn_empresaintegrbanco_id := rec.empresaintegrbanco_id;
      gv_nome_dblink           := rec.nome_dblink;
      gv_owner_obj             := rec.owner_obj;
      gd_dt_ini_integr         := trunc(rec.dt_ini_integr);
      gn_empresa_id            := rec.empresa_id;
      --
      vn_fase := 4;
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         gv_aspas := '"';
         --
      else
         --
         gv_aspas := null;
         --
      end if;
      --
      vn_fase := 5;
      -- seta "where" para pesquisa de Nfe de emissão própria
      pkb_seta_where_emissao_propria;
      --
      vn_fase := 6;
      --  Seta o formato de data para os procedimentos de retorno
      gn_dm_form_dt_erp := rec.dm_form_dt_erp;
      --
      if nvl(rec.dm_form_dt_erp,0) = 1
         and trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := rec.formato_dt_erp;
      else
         gd_formato_dt_erp := gv_formato_data;
      end if;
      --
      gn_dm_ret_infor_integr := nvl(rec.dm_ret_infor_integr,0);
      --
      vn_fase := 7;
      -- leitura das Notas Fiscais
      pkb_ler_Nota_Fiscal( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 8;
      -- leitura de notas fiscais canceladas
      pkb_ler_Nota_Fiscal_Canc( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 9;
      -- Leitura de intulizações
      pkb_ler_inutiliza_nf ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 10;
      -- Verifica se retorna a informação para o ERP
      if gn_dm_ret_infor_integr = 1 then
         --
         vn_fase := 10.1;
         -- Integra a informação para o ERP - VW_CSF_RESP_NF_ERP
         pkb_int_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10.2;
         -- retorna a informação para o ERP - VW_CSF_RESP_NF_ERP
         pkb_ret_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10.3;
         -- Integra a informação para o ERP - VW_CSF_RESP_NF_ERP_NEO
         pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10.4;
         -- retorna a informação para o ERP - VW_CSF_RESP_NF_ERP_NEO
         pkb_ret_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
      end if;
      --
      vn_fase := 11;
      -- Procedimento integra as consultas de NFe com o ERP
      if rec.dm_ret_nfe_terc_erp = 0 then -- Parametro que retorna Notas Fiscais de terceiros para o ERP está habilitado
         -- Apenas se não retorna os dados para o ERP de XML de Armazenamento de Terceiro
         pkb_int_csf_cons_sit ( en_empresa_id   => rec.empresa_id
                              , ev_nome_dblink  => gv_nome_dblink
                              , ev_aspas        => gv_aspas
                              , ev_owner_obj    => gv_owner_obj
                              );
         --
      end if;
      --
      vn_fase := 12;
      --
      pkb_ler_cons_chave_nfe ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 13;
      --
      pkb_ret_cons_erp ( en_empresa_id => rec.empresa_id );
      --
   end loop;
   --
   vn_fase := 14;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api_nfce.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 15;
   --
   pk_csf_api_nfce.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfce.gv_mensagem_log := 'Erro na pk_integr_view_nfce.pkb_integracao fase(' || vn_fase || ') empresa (' || vv_cpf_cnpj_emit || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfce.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api_nfce.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api_nfce.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api_nfce.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
      --      raise_application_error(-20101, pk_csf_api_nfce.gv_mensagem_log);
      --
end pkb_integracao;
--
-- ============================================================================================================================================= --
--
end pk_integr_view_nfce;
/
