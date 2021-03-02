create or replace package body csf_own.pk_integr_view_nfs is
-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de integração de Notas Fiscais de Serviços a partir de leitura de views
-------------------------------------------------------------------------------------------------------

--| Procedimento de limpeza do array
procedure pkb_limpa_array
is

begin
   --
   vt_tab_csf_itemnf_compl_serv.delete;
   vt_tab_csf_imp_itemnf_serv.delete;
   vt_tab_csf_imp_itemnf_serv_ff.delete;
   vt_tab_csf_imp_adicaposespserv.delete;
   vt_tab_csf_nfinfor_adic_serv.delete;
   vt_tab_csf_nf_dest_serv.delete;
   vt_tab_csf_nf_inter_serv.delete;
   vt_tab_csf_nfs_det_cc.delete;
   vt_tab_csf_nf_cobr_dup.delete;
   vt_tab_csf_nf_compl_serv.delete;
   vt_tab_csf_nf_proc_reinf.delete;
   --
end pkb_limpa_array;

-------------------------------------------------------------------------------------------------------

function fkg_monta_from ( ev_obj in varchar2 )
         return varchar2
is

   vv_from  varchar2(4000) := null;
   vv_obj   varchar2(4000) := null;

begin
   --
   vv_obj := ev_obj;
   --
   if GV_NOME_DBLINK is not null then
      --
      vv_from := vv_from || trim(GV_ASPAS) || vv_obj || trim(GV_ASPAS) || '@' || GV_NOME_DBLINK;
      --
   else
      --
      vv_from := vv_from || trim(GV_ASPAS) || vv_obj || trim(GV_ASPAS);
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

---------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Processos Administrativo/Judiciario relacionado com a Nota Fiscal de Serviço
---------------------------------------------------------------------------------------------------
procedure pkb_ler_nf_proc_reinf ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                , en_notafiscal_id          in             nota_fiscal.id%TYPE
                                , en_empresa_id             in             empresa.id%type
                              --| parâmetros de chave
                                , ev_cpf_cnpj_emit          in             varchar2
                                , en_dm_ind_emit            in             number
                                , en_dm_ind_oper            in             number
                                , ev_cod_part               in             varchar2
                                , ev_serie                  in             varchar2
                                , en_nro_nf                 in             number
                                , ed_dt_emiss               in             date
                                )
is
   --
   vn_fase number := 0;
   i       pls_integer;
   vn_loggenerico_id            log_generico_nf.id%type;
   vv_sql                       varchar2(2000);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_PROC_REINF') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TP_PROC'    || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_PROC'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_SUSP'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_PROC_RET_ADIC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR'         || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_PROC_REINF');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS)  || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and '      || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   --
   vn_fase := 2;
   --
   vv_sql := gv_sql;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_COMPL_SERV';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nf_proc_reinf;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_proc_reinf fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                  , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                                  , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                                  , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                  , en_referencia_id   => en_notafiscal_id
                                                  , ev_obj_referencia  => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 2.1;
   --
   if nvl(vt_tab_csf_nf_proc_reinf.count,0) > 0 then
      --
      vn_fase := 3;
      --
      for i in vt_tab_csf_nf_proc_reinf.first..vt_tab_csf_nf_proc_reinf.last loop 
         --
         vn_fase := 4;
         --
         pk_csf_api_nfs.gt_row_nf_proc_reinf := null;
         --
         pk_csf_api_nfs.gt_row_nf_proc_reinf.notafiscal_id         := en_notafiscal_id;
         pk_csf_api_nfs.gt_row_nf_proc_reinf.dm_ind_proc_ret_adic  := vt_tab_csf_nf_proc_reinf(i).dm_ind_proc_ret_adic;
         pk_csf_api_nfs.gt_row_nf_proc_reinf.valor                 := vt_tab_csf_nf_proc_reinf(i).valor;
         --
         vn_fase := 5;
         --
         pk_csf_api_nfs.pkb_integr_nf_proc_reinf ( est_log_generico_nf          => est_log_generico_nf
                                                 , est_row_nf_proc_reinf        => pk_csf_api_nfs.gt_row_nf_proc_reinf
                                                 , en_empresa_id                => en_empresa_id
                                                 , ed_dt_emiss                  => ed_dt_emiss
                                                 , en_dm_tp_proc                => vt_tab_csf_nf_proc_reinf(i).dm_tp_proc
                                                 , ev_nro_proc                  => vt_tab_csf_nf_proc_reinf(i).nro_proc
                                                 , en_cod_susp                  => vt_tab_csf_nf_proc_reinf(i).cod_susp
                                                 );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_proc_reinf fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                            , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                            , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                            , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id     => en_notafiscal_id
                                            , ev_obj_referencia    => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                                               , est_log_generico_nf    => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nf_proc_reinf;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações do complemento do serviço

procedure pkb_ler_nf_compl_serv ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                , en_notafiscal_id          in             nota_fiscal.id%TYPE
                              --| parâmetros de chave
                                , ev_cpf_cnpj_emit          in             varchar2
                                , en_dm_ind_emit            in             number
                                , en_dm_ind_oper            in             number
                                , ev_cod_part               in             varchar2
                                , ev_serie                  in             varchar2
                                , en_nro_nf                 in             number
                                )
is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_COMPL_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ID_ERP' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_COMPL_SERV');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_COMPL_SERV';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nf_compl_serv;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_compl_serv fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id   => en_notafiscal_id
                                               , ev_obj_referencia  => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 2.1;
   --
   if nvl(vt_tab_csf_nf_compl_serv.count,0) > 0 then
      --
      vn_fase := 3;
      --
      for i in vt_tab_csf_nf_compl_serv.first..vt_tab_csf_nf_compl_serv.last loop
         --
         vn_fase := 4;
         --
         pk_csf_api_nfs.gt_row_nota_fiscal_compl := null;
         --
         pk_csf_api_nfs.gt_row_nota_fiscal_compl.notafiscal_id := en_notafiscal_id;
         pk_csf_api_nfs.gt_row_nota_fiscal_compl.id_erp        := vt_tab_csf_nf_compl_serv(i).id_erp;
         --
         vn_fase := 4.1;
         --
         pk_csf_api_nfs.pkb_integr_nota_fiscal_compl ( est_log_generico_nf          => est_log_generico_nf
                                                     , est_row_nota_fiscal_compl => pk_csf_api_nfs.gt_row_nota_fiscal_compl
                                                     );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_compl_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                                            , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nf_compl_serv;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações das duplicatas da cobrança

procedure pkb_ler_nf_cobr_dup ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                              , en_notafiscal_id          in             nota_fiscal.id%TYPE
                              --| parâmetros de chave
                              , ev_cpf_cnpj_emit          in             varchar2
                              , en_dm_ind_emit            in             number
                              , en_dm_ind_oper            in             number
                              , ev_cod_part               in             varchar2
                              , ev_serie                  in             varchar2
                              , en_nro_nf                 in             number
                              , ed_dt_emiss               in             date
                              )
is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_COBR_DUP_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_FAT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_PARC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_VENCTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DUP' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_COBR_DUP_SERV');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_VENCTO' || trim(GV_ASPAS) || ' >= ' || '''' || to_char(ed_dt_emiss, gd_formato_dt_erp) || '''';
   --
   vn_fase := 2;
   --
--   insert into erro values (gv_sql);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_COBR_DUP_SERV';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nf_cobr_dup;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_cobr_dup fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id   => en_notafiscal_id
                                               , ev_obj_referencia  => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 2.1;
   --
   if nvl(vt_tab_csf_nf_cobr_dup.count,0) > 0 then
      --
      vn_fase := 3;
      --
      pk_csf_api_nfs.gt_row_nota_fiscal_cobr := null;
      --
      pk_csf_api_nfs.gt_row_nota_fiscal_cobr.NOTAFISCAL_ID  := en_notafiscal_id;
      pk_csf_api_nfs.gt_row_nota_fiscal_cobr.DM_IND_EMIT    := en_dm_ind_emit;
      pk_csf_api_nfs.gt_row_nota_fiscal_cobr.DM_IND_TIT     := '00'; -- Duplicata
      pk_csf_api_nfs.gt_row_nota_fiscal_cobr.NRO_FAT        := en_nro_nf;
      pk_csf_api_nfs.gt_row_nota_fiscal_cobr.VL_ORIG        := 0;
      pk_csf_api_nfs.gt_row_nota_fiscal_cobr.VL_DESC        := 0;
      pk_csf_api_nfs.gt_row_nota_fiscal_cobr.VL_LIQ         := 0;
      pk_csf_api_nfs.gt_row_nota_fiscal_cobr.DESCR_TIT      := NULL;
      --
      vn_fase := 3.1;
      --
      pk_csf_api_nfs.pkb_integr_Nota_Fiscal_Cobr ( est_log_generico_nf          => est_log_generico_nf
                                                 , est_row_Nota_Fiscal_Cobr  => pk_csf_api_nfs.gt_row_nota_fiscal_cobr
                                                 );
      --
      for i in vt_tab_csf_nf_cobr_dup.first..vt_tab_csf_nf_cobr_dup.last loop
         --
         vn_fase := 4;
         --
         pk_csf_api_nfs.gt_row_nfcobr_dup := null;
         --
         pk_csf_api_nfs.gt_row_nfcobr_dup.NFCOBR_ID  := pk_csf_api_nfs.gt_row_nota_fiscal_cobr.id;
         pk_csf_api_nfs.gt_row_nfcobr_dup.NRO_PARC   := vt_tab_csf_nf_cobr_dup(i).NRO_PARC;
         pk_csf_api_nfs.gt_row_nfcobr_dup.DT_VENCTO  := vt_tab_csf_nf_cobr_dup(i).DT_VENCTO;
         pk_csf_api_nfs.gt_row_nfcobr_dup.VL_DUP     := vt_tab_csf_nf_cobr_dup(i).VL_DUP;
         --
         vn_fase := 4.1;
         --
         pk_csf_api_nfs.pkb_integr_NFCobr_Dup ( est_log_generico_nf          => est_log_generico_nf
                                              , est_row_NFCobr_Dup        => pk_csf_api_nfs.gt_row_nfcobr_dup
                                              , en_notafiscal_id          => en_notafiscal_id
                                              );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_cobr_dup fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                                            , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nf_cobr_dup;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações sobre o detalhamento de serviços prestados na construção civil 

procedure pkb_ler_nfs_det_constr_civil ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id          in             nota_fiscal.id%TYPE
                                       --| parâmetros de chave
                                       , ev_cpf_cnpj_emit          in             varchar2
                                       , en_dm_ind_emit            in             number
                                       , en_dm_ind_oper            in             number
                                       , ev_cod_part               in             varchar2
                                       , ev_serie                  in             varchar2
                                       , en_nro_nf                 in             number
                                       )
is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NFS_DET_CONSTR_CIVIL') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_OBRA' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_CNO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OBRA' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NFS_DET_CONSTR_CIVIL');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   --
   vn_fase := 2;
--   insert into erro values (gv_sql);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NFS_DET_CONSTR_CIVIL';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nfs_det_cc;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nfs_det_constr_civil fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id   => en_notafiscal_id
                                               , ev_obj_referencia  => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 2.1;
   --
   if nvl(vt_tab_csf_nfs_det_cc.count,0) > 0 then
      --
      for i in vt_tab_csf_nfs_det_cc.first..vt_tab_csf_nfs_det_cc.last loop
         --
         vn_fase := 3;
         --
         pk_csf_api_nfs.gt_row_nfs_det_constr_civil := null;
         --
         pk_csf_api_nfs.gt_row_nfs_det_constr_civil.NOTAFISCAL_ID  := en_notafiscal_id;
         pk_csf_api_nfs.gt_row_nfs_det_constr_civil.COD_OBRA       := vt_tab_csf_nfs_det_cc(i).COD_OBRA;
         pk_csf_api_nfs.gt_row_nfs_det_constr_civil.NRO_ART        := vt_tab_csf_nfs_det_cc(i).NRO_ART;
         pk_csf_api_nfs.gt_row_nfs_det_constr_civil.NRO_CNO        := vt_tab_csf_nfs_det_cc(i).NRO_CNO;
         pk_csf_api_nfs.gt_row_nfs_det_constr_civil.DM_IND_OBRA    := vt_tab_csf_nfs_det_cc(i).DM_IND_OBRA;
         --
         vn_fase := 3.1;
         --
         pk_csf_api_nfs.pkb_integr_nfs_detconstrcivil ( est_log_generico_nf              => est_log_generico_nf
                                                      , est_row_nfs_det_constr_civil     => pk_csf_api_nfs.gt_row_nfs_det_constr_civil
                                                      );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nfs_det_constr_civil fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                                            , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nfs_det_constr_civil;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações do Intermediário de Serviço

procedure pkb_ler_nf_inter_serv ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                , en_notafiscal_id          in             nota_fiscal.id%TYPE
                                --| parâmetros de chave
                                , ev_cpf_cnpj_emit          in             varchar2
                                , en_dm_ind_emit            in             number
                                , en_dm_ind_oper            in             number
                                , ev_cod_part               in             varchar2
                                , ev_serie                  in             varchar2
                                , en_nro_nf                 in             number
                                )
is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_INTER_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NOME' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'INSCR_MUNIC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_INTER_SERV');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   --
   vn_fase := 2;
--   insert into erro values (gv_sql);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_INTER_SERV';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nf_inter_serv;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_inter_serv fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id   => en_notafiscal_id
                                               , ev_obj_referencia  => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 2.1;
   --
   if nvl(vt_tab_csf_nf_inter_serv.count,0) > 0 then
      --
      for i in vt_tab_csf_nf_inter_serv.first..vt_tab_csf_nf_inter_serv.last loop
         --
         vn_fase := 3;
         --
         pk_csf_api_nfs.gt_row_nf_inter_serv := null;
         --
         pk_csf_api_nfs.gt_row_nf_inter_serv.NOTAFISCAL_ID  := en_notafiscal_id;
         pk_csf_api_nfs.gt_row_nf_inter_serv.NOME           := vt_tab_csf_nf_inter_serv(i).NOME;
         pk_csf_api_nfs.gt_row_nf_inter_serv.INSCR_MUNIC    := vt_tab_csf_nf_inter_serv(i).INSCR_MUNIC;
         pk_csf_api_nfs.gt_row_nf_inter_serv.CPF_CNPJ       := vt_tab_csf_nf_inter_serv(i).CPF_CNPJ;
         --
         vn_fase := 3.1;
         --
         pk_csf_api_nfs.pkb_integr_nf_inter_serv ( est_log_generico_nf          => est_log_generico_nf
                                                 , est_row_nf_inter_serv     => pk_csf_api_nfs.gt_row_nf_inter_serv
                                                 );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_inter_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                                            , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nf_inter_serv;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações Tomador do Serviço

procedure pkb_ler_nf_dest_serv ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id          in             nota_fiscal.id%TYPE
                               --| parâmetros de chave
                               , ev_cpf_cnpj_emit          in             varchar2
                               , en_dm_ind_emit            in             number
                               , en_dm_ind_oper            in             number
                               , ev_cod_part               in             varchar2
                               , ev_serie                  in             varchar2
                               , en_nro_nf                 in             number
                               )
is
   --
   vn_fase number := 0;
   vv_ibge_cidade                 cidade.ibge_cidade%type;
   vn_empresa_id                  Empresa.id%TYPE;
   vn_cid number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_DEST_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CNPJ' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CPF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NOME' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'LOGRAD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COMPL' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'BAIRRO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CIDADE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CIDADE_IBGE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'UF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CEP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PAIS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'PAIS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'FONE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'IE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUFRAMA' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'EMAIL' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'IM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ID_ESTRANGEIRO' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_DEST_SERV');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   --
   vn_fase := 2;
   --insert into erro values (gv_sql);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_DEST_SERV';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nf_dest_serv;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_dest_serv fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id   => en_notafiscal_id
                                               , ev_obj_referencia  => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 2.1;
   --
   if nvl(vt_tab_csf_nf_dest_serv.count,0) > 0 then
      --
      for i in vt_tab_csf_nf_dest_serv.first..vt_tab_csf_nf_dest_serv.last loop
         --
         vn_fase := 3;
         --
         pk_csf_api_nfs.gt_row_nota_fiscal_dest := null;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.NOTAFISCAL_ID   := en_notafiscal_id;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.CNPJ            := vt_tab_csf_nf_dest_serv(i).CNPJ;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.CPF             := vt_tab_csf_nf_dest_serv(i).CPF;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.NOME            := vt_tab_csf_nf_dest_serv(i).NOME;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.LOGRAD          := vt_tab_csf_nf_dest_serv(i).LOGRAD;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.NRO             := vt_tab_csf_nf_dest_serv(i).NRO;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.COMPL           := vt_tab_csf_nf_dest_serv(i).COMPL;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.BAIRRO          := vt_tab_csf_nf_dest_serv(i).BAIRRO;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.CIDADE          := vt_tab_csf_nf_dest_serv(i).CIDADE;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.CIDADE_IBGE     := vt_tab_csf_nf_dest_serv(i).CIDADE_IBGE;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.UF              := vt_tab_csf_nf_dest_serv(i).UF;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.CEP             := vt_tab_csf_nf_dest_serv(i).CEP;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.COD_PAIS        := vt_tab_csf_nf_dest_serv(i).COD_PAIS;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.PAIS            := vt_tab_csf_nf_dest_serv(i).PAIS;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.FONE            := vt_tab_csf_nf_dest_serv(i).FONE;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.IE              := vt_tab_csf_nf_dest_serv(i).IE;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.SUFRAMA         := vt_tab_csf_nf_dest_serv(i).SUFRAMA;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.EMAIL           := vt_tab_csf_nf_dest_serv(i).EMAIL;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.IM              := vt_tab_csf_nf_dest_serv(i).IM;
         pk_csf_api_nfs.gt_row_nota_fiscal_dest.ID_ESTRANGEIRO  := vt_tab_csf_nf_dest_serv(i).ID_ESTRANGEIRO;
         --
         vn_fase := 3.1;
         --
         vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => gn_multorg_id
                                                              , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
         --
         vv_ibge_cidade := pk_csf.fkg_ibge_cidade_empresa ( vn_empresa_id );
         --
         if trim(vv_ibge_cidade) = '3550308' then -- São Paulo - SP
            --
            vn_fase := 3.11;
            --
            vn_cid := 3550308;            
            --
         elsif trim(vv_ibge_cidade) = '3304557' then -- Rio de Janeiro - RJ
            --
            vn_fase := 3.12;
            --
            vn_cid := 3304557;            
            --
         end if;               
         --        
         vn_fase := 4.1;
         --
         pk_csf_api_nfs.pkb_integr_Nota_Fiscal_Dest ( est_log_generico_nf       => est_log_generico_nf
                                                    , est_row_Nota_Fiscal_Dest  => pk_csf_api_nfs.gt_row_nota_fiscal_dest
                                                    , ev_cod_part               => vt_tab_csf_nf_dest_serv(i).COD_PART
                                                    , en_multorg_id             => gn_multorg_id
                                                    , en_cid                    => vn_cid );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_dest_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                                            , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nf_dest_serv;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações de observação da nota fiscal de serviço

procedure pkb_ler_nfinfor_adic_serv ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id          in             nota_fiscal.id%TYPE
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit          in             varchar2
                                    , en_dm_ind_emit            in             number
                                    , en_dm_ind_oper            in             number
                                    , ev_cod_part               in             varchar2
                                    , ev_serie                  in             varchar2
                                    , en_nro_nf                 in             number
                                    )
is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NFINFOR_ADIC_SERV') = 0 then
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
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CAMPO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CONTEUDO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ORIG_PROC' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NFINFOR_ADIC_SERV');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   --
   vn_fase := 2;
--   insert into erro values (gv_sql);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NFINFOR_ADIC_SERV';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nfinfor_adic_serv;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nfinfor_adic_serv fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo          => gv_resumo || gv_cabec_nf
                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id   => en_notafiscal_id
                                               , ev_obj_referencia  => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
   end;
   --
   vn_fase := 2.1;
   --
   if nvl(vt_tab_csf_nfinfor_adic_serv.count,0) > 0 then
      --
      for i in vt_tab_csf_nfinfor_adic_serv.first..vt_tab_csf_nfinfor_adic_serv.last loop
         --
         vn_fase := 3;
         pk_csf_api_nfs.gt_row_nfinfor_adic := null;
         pk_csf_api_nfs.gt_row_nfinfor_adic.NOTAFISCAL_ID  := en_notafiscal_id;
         pk_csf_api_nfs.gt_row_nfinfor_adic.DM_TIPO        := vt_tab_csf_nfinfor_adic_serv(i).DM_TIPO;
         pk_csf_api_nfs.gt_row_nfinfor_adic.CAMPO          := vt_tab_csf_nfinfor_adic_serv(i).CAMPO;
         pk_csf_api_nfs.gt_row_nfinfor_adic.CONTEUDO       := vt_tab_csf_nfinfor_adic_serv(i).CONTEUDO;
         --
         vn_fase := 3.1;
         --
         pk_csf_api_nfs.pkb_integr_NFInfor_Adic ( est_log_generico_nf          => est_log_generico_nf
                                                , est_row_NFInfor_Adic      => pk_csf_api_nfs.gt_row_nfinfor_adic
                                                , en_cd_orig_proc           => vt_tab_csf_nfinfor_adic_serv(i).ORIG_PROC
                                                );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nfinfor_adic_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_cabec_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                                            , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nfinfor_adic_serv;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações de impostos dos itens das notas fiscais de Servico - Campos Flex Field (FF)

procedure pkb_ler_imp_itemnf_serv_ff ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                     , en_notafiscal_id in             nota_fiscal.id%type
                                     , en_impitemnf_id  in             imp_itemnf.id%type
                                     , en_tipoimp_id    in             tipo_imposto.id%type
                                     --| parâmetros de chave
                                     , ev_cpf_cnpj_emit in             varchar2
                                     , en_dm_ind_emit   in             number
                                     , en_dm_ind_oper   in             number
                                     , ev_cod_part      in             varchar2
                                     , ev_serie         in             varchar2
                                     , en_nro_nf        in             number
                                     , en_nro_item      in             number
                                     , en_cd_imp        in             number
                                     , en_dm_tipo       in             number
                                     )
is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV_FF') = 0 then
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
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_IMPOSTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_IMP_ITEMNF_SERV_FF');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF'      || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_ITEM'    || trim(GV_ASPAS) || ' = ' || en_nro_item;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_IMPOSTO' || trim(GV_ASPAS) || ' = ' || en_cd_imp;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_TIPO'     || trim(GV_ASPAS) || ' = ' || en_dm_tipo;
   --
   vn_fase := 2;
--   insert into erro values (gv_sql);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_IMP_ITEMNF_SERV_FF';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_imp_itemnf_serv_ff;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_imp_itemnf_serv_ff fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo          => gv_resumo || gv_cabec_nf
                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id   => en_notafiscal_id
                                               , ev_obj_referencia  => 'NOTA_FISCAL' );
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
   if nvl(vt_tab_csf_imp_itemnf_serv_ff.count,0) > 0 then
      --
      for i in vt_tab_csf_imp_itemnf_serv_ff.first..vt_tab_csf_imp_itemnf_serv_ff.last loop
         --
         vn_fase := 4;
         --
         pk_csf_api_nfs.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                                 , en_impitemnf_id  => en_impitemnf_id
                                                 , en_tipoimp_id    => en_tipoimp_id
                                                 , en_cd_imp        => en_cd_imp
                                                 , ev_atributo      => vt_tab_csf_imp_itemnf_serv_ff(i).atributo
                                                 , ev_valor         => vt_tab_csf_imp_itemnf_serv_ff(i).valor
                                                 , en_multorg_id    => gn_multorg_id
                                                 );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_imp_itemnf_serv_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_cabec_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                                            , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_imp_itemnf_serv_ff;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações de impostos adicionais de aposentadoria especial.

procedure pkb_ler_imp_adic_apos_esp_serv ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                                         , en_notafiscal_id in                nota_fiscal.id%type
                                         , en_impitemnf_id  in                imp_itemnf.id%type
                                         , en_tipoimp_id    in                tipo_imposto.id%type
                                         --| parâmetros de chave
                                         , ev_cpf_cnpj_emit  in               varchar2
                                         , en_dm_ind_emit    in               number
                                         , en_dm_ind_oper    in               number
                                         , ev_cod_part       in               varchar2
                                         , ev_serie          in               varchar2
                                         , en_nro_nf         in               number
                                         , en_nro_item       in               number
                                         , en_cd_imp         in               number
                                         , en_dm_tipo        in               number
                                         )
is
   --
   vn_fase number := 0;
   i       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_IMP_ADIC_APOS_ESP_SERV') = 0 then
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
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_IMPOSTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'PERCENTUAL' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_ADICIONAL' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_IMP_ADIC_APOS_ESP_SERV');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF'      || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_ITEM'    || trim(GV_ASPAS) || ' = ' || en_nro_item;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_IMPOSTO' || trim(GV_ASPAS) || ' = ' || en_cd_imp;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_TIPO'     || trim(GV_ASPAS) || ' = ' || en_dm_tipo;
   --
   vn_fase := 2;
--   insert into erro values (gv_sql);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_IMP_ADIC_APOS_ESP_SERV';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_imp_adicaposespserv;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_imp_adic_apos_esp_serv fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                  , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                  , ev_resumo            => gv_resumo || gv_cabec_nf
                                                  , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                  , en_referencia_id     => en_notafiscal_id
                                                  , ev_obj_referencia    => 'NOTA_FISCAL' );
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
   if nvl(vt_tab_csf_imp_adicaposespserv.count,0) > 0 then
      --
      for i in vt_tab_csf_imp_adicaposespserv.first..vt_tab_csf_imp_adicaposespserv.last loop
         --
         vn_fase := 4;
         --
         pk_csf_api_nfs.gt_row_imp_adic_apos_esp_serv := null;
         --
         pk_csf_api_nfs.gt_row_imp_adic_apos_esp_serv.impitemnf_id  := en_impitemnf_id;
         pk_csf_api_nfs.gt_row_imp_adic_apos_esp_serv.percentual    := vt_tab_csf_imp_adicaposespserv(i).percentual;
         pk_csf_api_nfs.gt_row_imp_adic_apos_esp_serv.vl_adicional  := vt_tab_csf_imp_adicaposespserv(i).vl_adicional;
         --
         vn_fase := 4.1;
         --
         pk_csf_api_nfs.pkb_int_imp_adic_apos_esp_serv ( est_log_generico_nf             => est_log_generico_nf
                                                       , est_row_imp_adic_apos_esp_serv  => pk_csf_api_nfs.gt_row_imp_adic_apos_esp_serv
                                                       , en_cd_imp                       => vt_tab_csf_imp_adicaposespserv(i).cod_imposto
                                                       );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_imp_adic_apos_esp_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                            , ev_mensagem          => pk_csf_api_nfs.gv_cabec_log
                                            , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                            , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id     => en_notafiscal_id
                                            , ev_obj_referencia    => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenerico_id
                                               , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_imp_adic_apos_esp_serv;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações de impostos de Servico

procedure pkb_ler_imp_itemnf_serv ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                  , en_notafiscal_id          in             nota_fiscal.id%TYPE
                                  , en_itemnf_id              in             item_nota_fiscal.id%type
                                  --| parâmetros de chave
                                  , ev_cpf_cnpj_emit          in             varchar2
                                  , en_dm_ind_emit            in             number
                                  , en_dm_ind_oper            in             number
                                  , ev_cod_part               in             varchar2
                                  , ev_serie                  in             varchar2
                                  , en_nro_nf                 in             number
                                  , en_nro_item               in             number
                                  )
is
   --
   vn_fase                 number := 0;
   i                       pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV') = 0 then
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
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_IMPOSTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_ST' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BASE_CALC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_APLI' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_IMP_TRIB' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_IMP_ITEMNF_SERV');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_ITEM' || trim(GV_ASPAS) || ' = ' || en_nro_item;
   --
   vn_fase := 2;
--   insert into erro values (gv_sql);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_IMP_ITEMNF_SERV';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_imp_itemnf_serv;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_imp_itemnf_serv fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo          => gv_resumo || gv_cabec_nf
                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id   => en_notafiscal_id
                                               , ev_obj_referencia  => 'NOTA_FISCAL' );
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
   if nvl(vt_tab_csf_imp_itemnf_serv.count,0) > 0 then
      --
      for i in vt_tab_csf_imp_itemnf_serv.first..vt_tab_csf_imp_itemnf_serv.last loop
         --
         vn_fase := 4;
         --
         pk_csf_api_nfs.gt_row_imp_Itemnf := null;
         --
         pk_csf_api_nfs.gt_row_imp_Itemnf.ITEMNF_ID     := en_itemnf_id;
         pk_csf_api_nfs.gt_row_imp_Itemnf.DM_TIPO       := vt_tab_csf_imp_itemnf_serv(i).DM_TIPO;
         pk_csf_api_nfs.gt_row_imp_Itemnf.VL_BASE_CALC  := vt_tab_csf_imp_itemnf_serv(i).VL_BASE_CALC;
         pk_csf_api_nfs.gt_row_imp_Itemnf.ALIQ_APLI     := vt_tab_csf_imp_itemnf_serv(i).ALIQ_APLI;
         pk_csf_api_nfs.gt_row_imp_Itemnf.VL_IMP_TRIB   := vt_tab_csf_imp_itemnf_serv(i).VL_IMP_TRIB;
         --
         vn_fase := 4.1;
         --
         pk_csf_api_nfs.pkb_integr_Imp_ItemNf ( est_log_generico_nf => est_log_generico_nf
                                              , est_row_Imp_ItemNf  => pk_csf_api_nfs.gt_row_imp_Itemnf
                                              , en_cd_imp           => vt_tab_csf_imp_itemnf_serv(i).COD_IMPOSTO
                                              , ev_cod_st           => vt_tab_csf_imp_itemnf_serv(i).COD_ST
                                              , en_notafiscal_id    => en_notafiscal_id
                                              );
         --
         vn_fase := 4.2;
         -- Leitura de informações de impostos - Código da retenção do imposto e valor da dedução
         pkb_ler_imp_itemnf_serv_ff ( est_log_generico_nf => est_log_generico_nf
                                    , en_notafiscal_id    => en_notafiscal_id
                                    , en_impitemnf_id     => pk_csf_api_nfs.gt_row_imp_Itemnf.id
                                    , en_tipoimp_id       => pk_csf_api_nfs.gt_row_imp_Itemnf.tipoimp_id
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit    => ev_cpf_cnpj_emit
                                    , en_dm_ind_emit      => en_dm_ind_emit
                                    , en_dm_ind_oper      => en_dm_ind_oper
                                    , ev_cod_part         => ev_cod_part
                                    , ev_serie            => ev_serie
                                    , en_nro_nf           => en_nro_nf
                                    , en_nro_item         => en_nro_item
                                    , en_cd_imp           => vt_tab_csf_imp_itemnf_serv(i).cod_imposto
                                    , en_dm_tipo          => vt_tab_csf_imp_itemnf_serv(i).dm_tipo
                                    );
         --
         vn_fase := 4.3;
         --
         if nvl(pk_csf_api_nfs.gt_row_imp_Itemnf.id, 0) > 0 then
            -- Leitura de informações de impostos adicionais de aposentadoria especial
            pkb_ler_imp_adic_apos_esp_serv ( est_log_generico_nf => est_log_generico_nf
                                           , en_notafiscal_id    => en_notafiscal_id
                                           , en_impitemnf_id     => pk_csf_api_nfs.gt_row_imp_Itemnf.id
                                           , en_tipoimp_id       => pk_csf_api_nfs.gt_row_imp_Itemnf.tipoimp_id
                                           --| parâmetros de chave
                                           , ev_cpf_cnpj_emit    => ev_cpf_cnpj_emit
                                           , en_dm_ind_emit      => en_dm_ind_emit
                                           , en_dm_ind_oper      => en_dm_ind_oper
                                           , ev_cod_part         => ev_cod_part
                                           , ev_serie            => ev_serie
                                           , en_nro_nf           => en_nro_nf
                                           , en_nro_item         => en_nro_item
                                           , en_cd_imp           => vt_tab_csf_imp_itemnf_serv(i).cod_imposto
                                           , en_dm_tipo          => vt_tab_csf_imp_itemnf_serv(i).dm_tipo
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
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_imp_itemnf_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_cabec_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                                            , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_imp_itemnf_serv;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura do complemento dos itens das Notas Fiscais de Serviço - campos Flex Field

procedure pkb_ler_itemnf_compl_serv_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id          in             nota_fiscal.id%TYPE
                                       , en_itemnf_id              in             item_nota_fiscal.id%TYPE
                                       --| parâmetros de chave
                                       , ev_cpf_cnpj_emit          in             varchar2
                                       , en_dm_ind_emit            in             number
                                       , en_dm_ind_oper            in             number
                                       , ev_cod_part               in             varchar2
                                       , ev_serie                  in             varchar2
                                       , en_nro_nf                 in             number
                                       )
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV_FF') = 0 then
      --
      return;
      --
   end if;
   --
   vt_tab_csf_itnf_compl_serv_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEMNF_COMPL_SERV_FF');
   --
   vn_fase := 2;
   --
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
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_COMPL_SERV_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_itnf_compl_serv_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_itemnf_compl_serv_ff fase(' || vn_fase || '):' || sqlerrm;
           --
           declare
              vn_loggenerico_id  log_generico_nf.id%TYPE;
           begin
              --
              pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                 , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                 , ev_resumo            => gv_resumo || gv_cabec_nf
                                                 , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                 , en_referencia_id     => en_notafiscal_id
                                                 , ev_obj_referencia    => 'NOTA_FISCAL' );
              --
              -- Armazena o "loggenerico_id" na memória
              pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenerico_id
                                                    , est_log_generico_nf  => est_log_generico_nf );
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
   if vt_tab_csf_itnf_compl_serv_ff.count > 0 then
      --
      for i in vt_tab_csf_itnf_compl_serv_ff.first..vt_tab_csf_itnf_compl_serv_ff.last loop
         --
         vn_fase := 7;
         --
         if vt_tab_csf_itnf_compl_serv_ff(i).atributo not in ('COD_MULT_ORG', 'HASH_MULT_ORG', 'COD_MOD') then
            --
            pk_csf_api_nfs.pkb_int_itemnf_compl_serv_ff ( est_log_generico_nf   => est_log_generico_nf
                                                        , en_notafiscal_id      => en_notafiscal_id
                                                        , en_itemnf_id          => en_itemnf_id
                                                        , ev_atributo           => vt_tab_csf_itnf_compl_serv_ff(i).atributo
                                                        , ev_valor              => vt_tab_csf_itnf_compl_serv_ff(i).valor
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
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_itemnf_compl_serv_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                            , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                            , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                            , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id     => en_notafiscal_id
                                            , ev_obj_referencia    => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenerico_id
                                               , est_log_generico_nf   => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_itemnf_compl_serv_ff;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de informações do item de Servico

procedure pkb_ler_itemnf_compl_serv ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id          in             nota_fiscal.id%TYPE
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit          in             varchar2
                                    , en_dm_ind_emit            in             number
                                    , en_dm_ind_oper            in             number
                                    , ev_cod_part               in             varchar2
                                    , ev_serie                  in             varchar2
                                    , en_nro_nf                 in             number
                                    )
is
   --
   vn_fase      number := 0;
   i            pls_integer;
   vn_nro_item  number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DESCR_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CFOP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_SERVICO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DESC_INCONDICIONADO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DESC_CONDICIONADO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DEDUCAO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_OUTRA_RET' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CNAE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CD_LISTA_SERV' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_TRIB_MUNICIPIO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NAT_BC_CRED' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_ORIG_CRED' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_PAG_PIS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_PAG_COFINS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_LOC_EXE_SERV' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TRIB_MUN_PREST' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CIDADE_IBGE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_CTA' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_CCUS' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEMNF_COMPL_SERV');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
   --
   vn_fase := 2;
--   insert into erro values (gv_sql);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_COMPL_SERV';
   -- recupera as Notas Fiscais de servico não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_itemnf_compl_serv;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_itemnf_compl_serv fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                  , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                  , ev_resumo            => gv_resumo || gv_cabec_nf
                                                  , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                  , en_referencia_id     => en_notafiscal_id
                                                  , ev_obj_referencia    => 'NOTA_FISCAL' );
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
   if nvl(vt_tab_csf_itemnf_compl_serv.count,0) > 0 then
      --
      for i in vt_tab_csf_itemnf_compl_serv.first..vt_tab_csf_itemnf_compl_serv.last loop
         --
         vn_fase := 4;
         --
         vn_nro_item := nvl(vn_nro_item,0) + 1;
         --
         pk_csf_api_nfs.gt_row_item_nota_fiscal := null;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.NOTAFISCAL_ID           := en_notafiscal_id;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.NRO_ITEM                := vn_nro_item; --vt_tab_csf_itemnf_compl_serv(i).NRO_ITEM;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.COD_ITEM                := vt_tab_csf_itemnf_compl_serv(i).COD_ITEM;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.DM_IND_MOV              := 1;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.DESCR_ITEM              := vt_tab_csf_itemnf_compl_serv(i).DESCR_ITEM;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.CFOP                    := vt_tab_csf_itemnf_compl_serv(i).CFOP;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.UNID_COM                := 'UN';
         pk_csf_api_nfs.gt_row_item_nota_fiscal.QTDE_COMERC             := 1;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.VL_UNIT_COMERC          := vt_tab_csf_itemnf_compl_serv(i).VL_SERVICO;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.VL_ITEM_BRUTO           := vt_tab_csf_itemnf_compl_serv(i).VL_SERVICO;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.UNID_TRIB               := 'UN';
         pk_csf_api_nfs.gt_row_item_nota_fiscal.QTDE_TRIB               := 1;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.VL_UNIT_TRIB            := vt_tab_csf_itemnf_compl_serv(i).VL_SERVICO;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.CIDADE_IBGE             := vt_tab_csf_itemnf_compl_serv(i).CIDADE_IBGE;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.CD_LISTA_SERV           := vt_tab_csf_itemnf_compl_serv(i).CD_LISTA_SERV;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.COD_CTA                 := vt_tab_csf_itemnf_compl_serv(i).COD_CTA;
         pk_csf_api_nfs.gt_row_item_nota_fiscal.DM_IND_TOT              := 0;
         --
         vn_fase := 4.1;
         --
         pk_csf_api_nfs.pkb_integr_Item_Nota_Fiscal ( est_log_generico_nf          => est_log_generico_nf
                                                    , est_row_Item_Nota_Fiscal  => pk_csf_api_nfs.gt_row_item_nota_fiscal
                                                    );
         --
         vn_fase := 4.2;
         -- dados complementares do item do serviço
         pk_csf_api_nfs.gt_row_itemnf_compl_serv := null;
         
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.ITEMNF_ID               := pk_csf_api_nfs.gt_row_item_nota_fiscal.id;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.DM_IND_ORIG_CRED        := vt_tab_csf_itemnf_compl_serv(i).DM_IND_ORIG_CRED;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.DT_PAG_PIS              := vt_tab_csf_itemnf_compl_serv(i).DT_PAG_PIS;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.DT_PAG_COFINS           := vt_tab_csf_itemnf_compl_serv(i).DT_PAG_COFINS;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.DM_LOC_EXE_SERV         := vt_tab_csf_itemnf_compl_serv(i).DM_LOC_EXE_SERV;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.DM_TRIB_MUN_PREST       := vt_tab_csf_itemnf_compl_serv(i).DM_TRIB_MUN_PREST;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.VL_DESC_INCONDICIONADO  := vt_tab_csf_itemnf_compl_serv(i).VL_DESC_INCONDICIONADO;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.VL_DESC_CONDICIONADO    := vt_tab_csf_itemnf_compl_serv(i).VL_DESC_CONDICIONADO;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.VL_DEDUCAO              := vt_tab_csf_itemnf_compl_serv(i).VL_DEDUCAO;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.VL_OUTRA_RET            := vt_tab_csf_itemnf_compl_serv(i).VL_OUTRA_RET;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.CNAE                    := vt_tab_csf_itemnf_compl_serv(i).CNAE;
         pk_csf_api_nfs.gt_row_itemnf_compl_serv.CIDADE_ID               := pk_csf.fkg_Cidade_ibge_id(vt_tab_csf_itemnf_compl_serv(i).CIDADE_IBGE);
         --
         vn_fase := 4.3;
         --
         pk_csf_api_nfs.pkb_integr_itemnf_compl_serv ( est_log_generico_nf          => est_log_generico_nf
                                                     , est_row_nfserv_item_compl => pk_csf_api_nfs.gt_row_itemnf_compl_serv
                                                     , en_notafiscal_id          => en_notafiscal_id
                                                     , ev_cod_bc_cred_pc         => vt_tab_csf_itemnf_compl_serv(i).NAT_BC_CRED
                                                     , ev_cod_ccus               => vt_tab_csf_itemnf_compl_serv(i).COD_CCUS
                                                     , ev_cod_trib_municipio     => vt_tab_csf_itemnf_compl_serv(i).COD_TRIB_MUNICIPIO
                                                     );
         --
         vn_fase := 4.4;
         --
         -- Leitura de informações de impostos
         pkb_ler_imp_itemnf_serv ( est_log_generico_nf       => est_log_generico_nf
                                 , en_notafiscal_id          => en_notafiscal_id
                                 , en_itemnf_id              => pk_csf_api_nfs.gt_row_item_nota_fiscal.id
                                 --| parâmetros de chave
                                 , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                                 , en_dm_ind_emit            => en_dm_ind_emit
                                 , en_dm_ind_oper            => en_dm_ind_oper
                                 , ev_cod_part               => ev_cod_part
                                 , ev_serie                  => ev_serie
                                 , en_nro_nf                 => en_nro_nf
                                 , en_nro_item               => vt_tab_csf_itemnf_compl_serv(i).nro_item
                                 );
         --
         pkb_ler_itemnf_compl_serv_ff ( est_log_generico_nf       => est_log_generico_nf
                                      , en_notafiscal_id          => en_notafiscal_id
                                      , en_itemnf_id              => pk_csf_api_nfs.gt_row_item_nota_fiscal.id
                                      --| parâmetros de chave
                                      , ev_cpf_cnpj_emit          => ev_cpf_cnpj_emit
                                      , en_dm_ind_emit            => en_dm_ind_emit
                                      , en_dm_ind_oper            => en_dm_ind_oper
                                      , ev_cod_part               => ev_cod_part
                                      , ev_serie                  => ev_serie
                                      , en_nro_nf                 => en_nro_nf
                                      );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_itemnf_compl_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                            , ev_mensagem          => pk_csf_api_nfs.gv_cabec_log
                                            , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                            , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id     => en_notafiscal_id
                                            , ev_obj_referencia    => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenerico_id
                                               , est_log_generico_nf  => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_itemnf_compl_serv;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura das Notas Fiscais de Serviço - campos Flex Field

procedure pkb_ler_nota_fiscal_serv_ff ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                      , en_notafiscal_id          in             nota_fiscal.id%TYPE
                                      --| parâmetros de chave
                                      , ev_cpf_cnpj_emit          in             varchar2
                                      , en_dm_ind_emit            in             number
                                      , en_dm_ind_oper            in             number
                                      , ev_cod_part               in             varchar2
                                      , ev_serie                  in             varchar2
                                      , en_nro_nf                 in             number
                                      )
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV_FF') = 0 then
      --
      return;
      --
   end if;
   --
   vt_tab_csf_nota_fiscal_serv_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||              trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE'         || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'NRO_NF'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'ATRIBUTO'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'VALOR'         || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_SERV_FF');
   --
   vn_fase := 2;
   --
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
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_SERV_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_serv_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nota_fiscal_serv_ff fase(' || vn_fase || '):' || sqlerrm;
           --
           declare
              vn_loggenerico_id  log_generico_nf.id%TYPE;
           begin
              --
              pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                 , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                 , ev_resumo            => gv_resumo || gv_cabec_nf
                                                 , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                 , en_referencia_id     => en_notafiscal_id
                                                 , ev_obj_referencia    => 'NOTA_FISCAL' );
              --
              -- Armazena o "loggenerico_id" na memória
              pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenerico_id
                                                    , est_log_generico_nf  => est_log_generico_nf );
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
   if vt_tab_csf_nota_fiscal_serv_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_serv_ff.first..vt_tab_csf_nota_fiscal_serv_ff.last loop
         --
         vn_fase := 7;
         --
         if vt_tab_csf_nota_fiscal_serv_ff(i).atributo not in ('COD_MULT_ORG', 'HASH_MULT_ORG', 'COD_MOD', 'COD_NAT_OPER') then
            --
            pk_csf_api_nfs.pkb_integr_nota_fiscal_serv_ff ( est_log_generico_nf   => est_log_generico_nf
                                                          , en_notafiscal_id      => en_notafiscal_id
                                                          , ev_atributo           => vt_tab_csf_nota_fiscal_serv_ff(i).atributo
                                                          , ev_valor              => vt_tab_csf_nota_fiscal_serv_ff(i).valor
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
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nota_fiscal_serv_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                            , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                            , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                            , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id     => en_notafiscal_id
                                            , ev_obj_referencia    => 'NOTA_FISCAL' );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_csf_api_nfs.pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenerico_id
                                               , est_log_generico_nf   => est_log_generico_nf );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nota_fiscal_serv_ff;


-------------------------------------------------------------------------------------------------------
--| Procedimento de leitura de informações Flex Field da nota fiscal de serviço - Mult_Org

procedure pkb_ler_nf_serv_multorg_ff ( est_log_generico   in  out nocopy  dbms_sql.number_table
                                     , ev_cpf_cnpj_emit   in  varchar2
                                     , en_dm_ind_emit     in  number
                                     , en_dm_ind_oper     in  number
                                     , ev_cod_part        in  varchar2
                                     , ev_serie           in  varchar2
                                     , en_nro_nf          in  number
                                     , sn_multorg_id      out mult_org.id%type )
is
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
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV_FF') = 0 then
      --
      sn_multorg_id := vn_multorg_id;
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nota_fiscal_serv_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR'         || trim(GV_ASPAS);
   --
   vn_fase := 1.1;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_SERV_FF' );
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
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
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
   gv_sql := gv_sql || ', trim('|| trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ')';
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_SERV_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_serv_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_serv_multorg_ff fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                          , ev_resumo            => 'Nota fiscal de serviço: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                          , en_referencia_id     => null
                                          , ev_obj_referencia    => 'NOTA_FISCAL' );
           --
           raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nota_fiscal_serv_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_serv_ff.first..vt_tab_csf_nota_fiscal_serv_ff.last loop
         --
         vn_fase := 7;
         --
         if vt_tab_csf_nota_fiscal_serv_ff(i).atributo in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            vb_multorg := true;
            --
            vn_fase := 8;
            -- Chama procedimento que faz a validação dos itens da Inventario - campos flex field.
            vv_cod_ret := null;
            vv_hash_ret := null;

            pk_csf_api_nfs.pkb_val_atrib_multorg ( est_log_generico     => est_log_generico
                                             , ev_obj_name          => 'VW_CSF_NOTA_FISCAL_SERV_FF'
                                             , ev_atributo          => vt_tab_csf_nota_fiscal_serv_ff(i).atributo
                                             , ev_valor             => vt_tab_csf_nota_fiscal_serv_ff(i).valor
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
      if nvl(est_log_generico.count, 0) <= 0
         and vb_multorg then
         --
         vn_fase := 11;
         --
         vn_multorg_id := sn_multorg_id;
         pk_csf_api_nfs.pkb_ret_multorg_id( est_log_generico   => est_log_generico
                                      , ev_cod_mult_org    => vv_cod
                                      , ev_hash_mult_org   => vv_hash
                                      , sn_multorg_id      => vn_multorg_id
                                      , en_referencia_id     => null
                                      , ev_obj_referencia    => 'NOTA_FISCAL'
                                      );
      end if;
      --
      vn_fase := 12;
      --
      sn_multorg_id := vn_multorg_id;
      --
   else
      --
      pk_csf_api.gv_mensagem_log := 'Nota fiscal cadastrada com Mult Org default (codigo = 1), pois não foram passados o codigo e a hash do multorg.';
      --
      vn_loggenericonf_id := null;
      --
      vn_fase := 10;
      --
      pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem           => pk_csf_api_nfs.gv_mensagem_log
                                          , ev_resumo             => 'Nota fiscal de serviço: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log           => pk_csf_api_nfs.INFORMACAO
                                          , en_referencia_id      => null
                                          , ev_obj_referencia     => 'NOTA_FISCAL'
                                          );
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_serv_multorg_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                        , ev_mensagem           => pk_csf_api_nfs.gv_mensagem_log
                                        , ev_resumo             => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                        , en_tipo_log           => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                        , en_referencia_id      => null
                                        , ev_obj_referencia     => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_serv_multorg_ff;
--
-- ============================================================================================================================= --
--
--| Procedimento de leitura de informações Flex Field da nota fiscal de serviço
--
procedure pkb_ler_nf_serv_ff ( est_log_generico   in  out nocopy  dbms_sql.number_table
                             , ev_cpf_cnpj_emit   in  varchar2
                             , en_dm_ind_emit     in  number
                             , en_dm_ind_oper     in  number
                             , ev_cod_part        in  varchar2
                             , ev_serie           in  varchar2
                             , en_nro_nf          in  number
                             , sv_cod_mod         out mod_fiscal.cod_mod%type
                             , sv_nro_aut_nfs     out nf_compl_serv.nro_aut_nfs%type
                             , sv_cod_nat         out nat_oper.cod_nat%type
                             )
is
   --
   vn_fase               number := 0;
   vv_cod_mod            mod_fiscal.cod_mod%type        := '99';
   vv_nro_aut_nfs        nf_compl_serv.nro_aut_nfs%type := null;
   vv_cod_nat            Nat_Oper.cod_nat%TYPE          := null;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV_FF') = 0 then
      --
      sv_cod_mod     := vv_cod_mod;
      sv_nro_aut_nfs := vv_nro_aut_nfs;
      sv_cod_nat     := vv_cod_nat;
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nota_fiscal_serv_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||              trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE'         || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'NRO_NF'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'ATRIBUTO'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' ||      trim(GV_ASPAS) || 'VALOR'         || trim(GV_ASPAS);
   --
   vn_fase := 1.1;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_SERV_FF' );
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_EMIT'   || GV_ASPAS || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'DM_IND_OPER'   || GV_ASPAS || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 2;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || GV_ASPAS || 'COD_PART' || GV_ASPAS || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 3;
   --
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'   || GV_ASPAS || ' = ' || en_nro_nf;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_SERV_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     vn_fase := 4;
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_serv_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_serv_ff fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                              , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                              , ev_resumo            => 'Nota fiscal de serviço: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                              , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                              , en_referencia_id     => null
                                              , ev_obj_referencia    => 'NOTA_FISCAL' );
           --
           raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 5;
   --
   if vt_tab_csf_nota_fiscal_serv_ff.count > 0 then
      --
      for i in vt_tab_csf_nota_fiscal_serv_ff.first..vt_tab_csf_nota_fiscal_serv_ff.last loop
         --
         vn_fase := 6;
         --
         if vt_tab_csf_nota_fiscal_serv_ff(i).atributo in ('COD_MOD') then
            --
            vv_cod_mod := vt_tab_csf_nota_fiscal_serv_ff(i).valor;
            --
         elsif vt_tab_csf_nota_fiscal_serv_ff(i).atributo in ('NRO_AUT_NFS') then
            --
            vv_nro_aut_nfs := vt_tab_csf_nota_fiscal_serv_ff(i).valor;
            --
         elsif vt_tab_csf_nota_fiscal_serv_ff(i).atributo in ('COD_NAT_OPER') then
            --
            vv_cod_nat := vt_tab_csf_nota_fiscal_serv_ff(i).valor;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 10;
      --
      sv_cod_mod     := vv_cod_mod;
      sv_nro_aut_nfs := vv_nro_aut_nfs;
      sv_cod_nat     := vv_cod_nat;
      --
   else
      --
      vn_fase := 11;
      --
      sv_cod_mod     := vv_cod_mod;
      sv_nro_aut_nfs := vv_nro_aut_nfs;
      sv_cod_nat     := vv_cod_nat;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_serv_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id   => vn_loggenericonf_id
                                            , ev_mensagem           => pk_csf_api_nfs.gv_mensagem_log
                                            , ev_resumo             => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                            , en_tipo_log           => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id      => null
                                            , ev_obj_referencia     => 'NOTA_FISCAL'
                                            );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_serv_ff;
--
-- ============================================================================================================================= --
--
--| Procedimento de leitura de informações da nota fiscal de serviço

procedure pkb_ler_nota_fiscal_serv ( ev_cpf_cnpj_emit in varchar2 )

is
   --
   vn_fase                 number := 0;
   vt_log_generico         dbms_sql.number_table;
   vn_notafiscal_id        Nota_Fiscal.id%TYPE;
   vn_empresa_id           Empresa.id%TYPE;
   vn_dm_st_proc           Nota_Fiscal.dm_st_proc%type;
   i                       pls_integer;
   vd_dt_ult_fecha         fecha_fiscal_empresa.dt_ult_fecha%type;
   vn_multorg_id           mult_org.id%type;
   vn_dm_dt_escr_dfepoe    empresa.dm_dt_escr_dfepoe%type;
   vv_cod_mod              mod_fiscal.cod_mod%type;
   vv_nro_aut_nfs          nf_compl_serv.nro_aut_nfs%type;
   vn_dm_tp_transmis_terc  cidade_nfse.dm_tp_transmis_terc%type := null;
   vv_cod_nat              Nat_Oper.cod_nat%TYPE:= null;
   vn_cod_nat_id           nota_fiscal.natoper_id%type:=null;
--
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   vt_tab_csf_nota_fiscal_serv.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'          || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_EMISS'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_EXE_SERV'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_SAI_ENT'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SIT_DOCTO'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CHV_NFSE'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_PAG'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_NAT_OPER'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO_RPS'     || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_STATUS_RPS'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_RPS_SUBST'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE_RPS_SUBST' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_ST_PROC'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SIST_ORIG'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'UNID_ORG'        || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NOTA_FISCAL_SERV');
   --
   vn_fase := 1.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   --
   vn_fase := 1.4;
   -- testa data de inicio da integração
   if gd_dt_ini_integr is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'DT_EMISS' || trim(GV_ASPAS) || ' >= ' || '''' || to_char(gd_dt_ini_integr, gd_formato_dt_erp) || '''';
      --
   end if;
   --
   vn_fase := 1.5;
   --
   gv_sql := gv_sql || gv_where;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_SERV (empresa: ' || ev_cpf_cnpj_emit || ')';
   -- recupera as Notas Fiscais de servico não integradas
   --
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_serv;
      --
   exception
      when others then
         -- não registra erro casa a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nota_fiscal_serv fase(' || vn_fase || '):' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                  , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                  , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                                  , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                  , en_referencia_id     => null
                                                  , ev_obj_referencia    => 'NOTA_FISCAL' );
               --
            exception
               when others then
                  null;
            end;
            --
            goto sair_geral;
            --
         end if;
   end;
   --
   -- Calcula a quantidade de registros buscados no ERP
   -- para ser mostrado na tela de agendamento.
   --
   begin
      pk_agend_integr.gvtn_qtd_erp(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erp(gv_cd_obj),0) + nvl(vt_tab_csf_nota_fiscal_serv.count,0);
   exception
      when others then
      null;
   end;
   --
   vn_fase := 2.1;
   --
   if vt_tab_csf_nota_fiscal_serv.count > 0 then
      -- Leitura do array de notas fiscais de serviço
      for i in vt_tab_csf_nota_fiscal_serv.first..vt_tab_csf_nota_fiscal_serv.last loop
         --
         vn_fase := 3;
         --
         vt_log_generico.delete;
         --
         pkb_limpa_array;
         --
         vn_fase := 3.1;
         vn_multorg_id := gn_multorg_id;
         --
         pkb_ler_nf_serv_multorg_ff ( est_log_generico  =>  vt_log_generico
                                    , ev_cpf_cnpj_emit  =>  vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                    , en_dm_ind_emit    =>  vt_tab_csf_nota_fiscal_serv(i).dm_ind_emit
                                    , en_dm_ind_oper    =>  vt_tab_csf_nota_fiscal_serv(i).dm_ind_oper
                                    , ev_cod_part       =>  vt_tab_csf_nota_fiscal_serv(i).cod_part
                                    , ev_serie          =>  vt_tab_csf_nota_fiscal_serv(i).serie
                                    , en_nro_nf         =>  vt_tab_csf_nota_fiscal_serv(i).nro_nf
                                    , sn_multorg_id     =>  vn_multorg_id
                                    );
         --
         vn_fase := 3.11;
         --
         pkb_ler_nf_serv_ff ( est_log_generico  =>  vt_log_generico
                            , ev_cpf_cnpj_emit  =>  vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                            , en_dm_ind_emit    =>  vt_tab_csf_nota_fiscal_serv(i).dm_ind_emit
                            , en_dm_ind_oper    =>  vt_tab_csf_nota_fiscal_serv(i).dm_ind_oper
                            , ev_cod_part       =>  vt_tab_csf_nota_fiscal_serv(i).cod_part
                            , ev_serie          =>  vt_tab_csf_nota_fiscal_serv(i).serie
                            , en_nro_nf         =>  vt_tab_csf_nota_fiscal_serv(i).nro_nf
                            , sv_cod_mod        =>  vv_cod_mod
                            , sv_nro_aut_nfs    =>  vv_nro_aut_nfs
                            , sv_cod_nat        =>  vv_cod_nat
                            );
         --
         vn_fase := 3.2;
         --
         if nvl(vn_multorg_id, 0) <= 0 then
            --
            vn_multorg_id := gn_multorg_id;
            --
         elsif vn_multorg_id != gn_multorg_id then
            --
            pk_csf_api.gv_mensagem_log := 'Mult-org informado pelo usuario('||vn_multorg_id||') não corresponde ao Mult-org da empresa('||gn_multorg_id||').';
            --
            vn_fase := 3.3;
            --
            vn_multorg_id := gn_multorg_id;
            --
            declare
               vn_loggenericonf_id  log_generico_nf.id%TYPE;
            begin
               pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id   => vn_loggenericonf_id
                                              , ev_mensagem           => pk_csf_api.gv_mensagem_log
                                              , ev_resumo             => 'Mult-Org incorreto ou não informado.'
                                              , en_tipo_log           => pk_csf_api.INFORMACAO
                                              , en_referencia_id      => null
                                              , ev_obj_referencia     => 'NOTA_FISCAL'
                                              );
            exception
               when others then
                  null;
            end;
            --
         end if;
         --
         vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => vn_multorg_id
                                                              , ev_cpf_cnpj   => vt_tab_csf_nota_fiscal_serv(i).CPF_CNPJ_EMIT );
         --
         gn_empresa_id := vn_empresa_id;
         --
         vn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => vn_empresa_id );
         --
         vd_dt_ult_fecha := pk_csf.fkg_recup_dtult_fecha_empresa( en_empresa_id   => vn_empresa_id
                                                                , en_objintegr_id => pk_csf.fkg_recup_objintegr_id( ev_cd => '7' ));
         --
         if (vd_dt_ult_fecha is null) or
            (vt_tab_csf_nota_fiscal_serv(i).dm_ind_emit = 0 and vt_tab_csf_nota_fiscal_serv(i).dm_ind_oper = 1 and trunc(vt_tab_csf_nota_fiscal_serv(i).dt_emiss) > vd_dt_ult_fecha) or
            (vt_tab_csf_nota_fiscal_serv(i).dm_ind_emit = 0 and vt_tab_csf_nota_fiscal_serv(i).dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 0 and trunc(vt_tab_csf_nota_fiscal_serv(i).dt_emiss) > vd_dt_ult_fecha) or
            (vt_tab_csf_nota_fiscal_serv(i).dm_ind_emit = 0 and vt_tab_csf_nota_fiscal_serv(i).dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 1 and trunc(nvl(vt_tab_csf_nota_fiscal_serv(i).dt_sai_ent,vt_tab_csf_nota_fiscal_serv(i).dt_emiss)) > vd_dt_ult_fecha) or
            (vt_tab_csf_nota_fiscal_serv(i).dm_ind_emit = 1 and trunc(nvl(vt_tab_csf_nota_fiscal_serv(i).dt_sai_ent,vt_tab_csf_nota_fiscal_serv(i).dt_emiss)) > vd_dt_ult_fecha) then
            --
            gv_cabec_nf := 'Empresa: ' || vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit || '-'
                                       || pk_csf.fkg_nome_empresa ( en_empresa_id  => vn_empresa_id );
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            gv_cabec_nf := gv_cabec_nf || 'Número: ' || vt_tab_csf_nota_fiscal_serv(i).NRO_NF;
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            gv_cabec_nf := gv_cabec_nf || 'Operação: ' || pk_csf.fkg_dominio ( ev_dominio => 'NOTA_FISCAL.DM_IND_OPER'
                                                                             , ev_vl      => vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER );
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            gv_cabec_nf := gv_cabec_nf || 'Indicador do Emitente: ' || pk_csf.fkg_dominio ( ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT'
                                                                                          , ev_vl      => vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT );
            --
            gv_cabec_nf := gv_cabec_nf || chr(10);
            --
            vn_fase := 3.4;
            -- Recupera o ID da nota fiscal
            vn_notafiscal_id := pk_csf.fkg_busca_notafiscal_id ( en_multorg_id   => vn_multorg_id
                                                               , en_empresa_id   => vn_empresa_id
                                                               , ev_cod_mod      => vv_cod_mod
                                                               , ev_serie        => trim(vt_tab_csf_nota_fiscal_serv(i).SERIE)
                                                               , en_nro_nf       => vt_tab_csf_nota_fiscal_serv(i).NRO_NF
                                                               , en_dm_ind_oper  => vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER
                                                               , en_dm_ind_emit  => vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT
                                                               , ev_cod_part     => trim(vt_tab_csf_nota_fiscal_serv(i).COD_PART)
                                                               );
            --
            vn_fase := 3.5;
            --
            if nvl(vn_notafiscal_id,0) > 0 then
               -- Se a nota já existe no sistema, então
               vn_dm_st_proc := pk_csf.fkg_st_proc_nf ( en_notafiscal_id => vn_notafiscal_id );
               --
               vn_fase := 3.51;
               --
               if vn_dm_st_proc in ( 0, 1, 2, 3, 4, 6, 7, 8, 14, 17, 18, 19, 20, 21 ) then
                  --
                  -- Sai do processo
                  goto sair_integr;
                  --
               end if;
               --
            end if;
            --
            vn_fase := 3.52;
            --
            vn_cod_nat_id :=  pk_csf.fkg_Nat_Oper_id ( en_multorg_id => vn_multorg_id
                                                     , ev_cod_nat    => vv_cod_nat );
            --
            vn_fase := 3.53;
            --
            pk_csf_api_nfs.gt_row_nota_fiscal := null;
            --
            pk_csf_api_nfs.gt_row_nota_fiscal.EMPRESA_ID           := vn_empresa_id;
            pk_csf_api_nfs.gt_row_nota_fiscal.DM_IND_PAG           := vt_tab_csf_nota_fiscal_serv(i).DM_IND_PAG;
            pk_csf_api_nfs.gt_row_nota_fiscal.DM_IND_EMIT          := vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT;
            pk_csf_api_nfs.gt_row_nota_fiscal.DM_IND_OPER          := vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER;
            pk_csf_api_nfs.gt_row_nota_fiscal.DT_EMISS             := vt_tab_csf_nota_fiscal_serv(i).DT_EMISS;
            pk_csf_api_nfs.gt_row_nota_fiscal.DT_sai_ent           := vt_tab_csf_nota_fiscal_serv(i).DT_sai_ent;
            pk_csf_api_nfs.gt_row_nota_fiscal.NRO_NF               := vt_tab_csf_nota_fiscal_serv(i).NRO_NF;
            pk_csf_api_nfs.gt_row_nota_fiscal.SERIE                := trim(vt_tab_csf_nota_fiscal_serv(i).SERIE);
            pk_csf_api_nfs.gt_row_nota_fiscal.DM_ST_PROC           := vt_tab_csf_nota_fiscal_serv(i).DM_ST_PROC;
            pk_csf_api_nfs.gt_row_nota_fiscal.DM_IMPRESSA          := 0;
            pk_csf_api_nfs.gt_row_nota_fiscal.DM_FIN_NFE           := 1;
            pk_csf_api_nfs.gt_row_nota_fiscal.DM_PROC_EMISS        := 1;
            pk_csf_api_nfs.gt_row_nota_fiscal.VERS_PROC            := '1';
            pk_csf_api_nfs.gt_row_nota_fiscal.DM_ST_EMAIL          := 0;
            pk_csf_api_nfs.gt_row_nota_fiscal.DM_ST_INTEGRA        := 7;
            pk_csf_api_nfs.gt_row_nota_fiscal.NRO_TENTATIVAS_IMPR  := 0;
            pk_csf_api_nfs.gt_row_nota_fiscal.dm_arm_nfe_terc      := 0;
            pk_csf_api_nfs.gt_row_nota_fiscal.natoper_id           := vn_cod_nat_id;
            -- A informação deverá ser alimentada por vt_tab_csf_nota_fiscal_serv(i).cod_part, na rotina pk_csf_api_nfs.pkb_integr_Nota_Fiscal_serv
            -- Se não houver informação, o campo PESSOA_ID deverá ser alimentado através do Destinatário da Nota, na rotina pkb_ler_nf_dest_serv
            --pk_csf_api_nfs.gt_row_nota_fiscal.PESSOA_ID            := vn_pessoa_id_empr;
            --
            --pk_csf_api_nfs.gv_ibge_cidade_empr                     := vv_ibge_cidade_empr;
            --pk_csf_api_nfs.gv_cod_mod                              := vv_cod_mod;
            --
            vn_fase := 3.6;
            --
            -- Chama o Processo de validação dos dados da Nota Fiscal de Serviço
            pk_csf_api_nfs.pkb_integr_Nota_Fiscal_serv ( est_log_generico_nf        => vt_log_generico
                                                       , est_row_Nota_Fiscal        => pk_csf_api_nfs.gt_row_nota_fiscal
                                                       , ev_cod_mod                 => vv_cod_mod
                                                       , ev_empresa_cpf_cnpj        => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                                       , ev_cod_part                => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                                       , ev_cd_sitdocto             => vt_tab_csf_nota_fiscal_serv(i).sit_docto
                                                       , ev_sist_orig               => vt_tab_csf_nota_fiscal_serv(i).sist_orig
                                                       , ev_cod_unid_org            => vt_tab_csf_nota_fiscal_serv(i).unid_org
                                                       , en_multorg_id              => vn_multorg_id
                                                       , en_empresaintegrbanco_id   => gn_empresaintegrbanco_id
                                                       );
            vn_fase := 3.7;
            --
            if nvl(pk_csf_api_nfs.gt_row_nota_fiscal.id,0) > 0 then
               --
               vn_fase := 4;
               -- integra informações do complemento do serviço
               pk_csf_api_nfs.gt_row_nf_compl_serv := null;
               pk_csf_api_nfs.gt_row_nf_compl_serv.notafiscal_id     := pk_csf_api_nfs.gt_row_nota_fiscal.id;
               pk_csf_api_nfs.gt_row_nf_compl_serv.chv_nfse          := vt_tab_csf_nota_fiscal_serv(i).CHV_NFSE;
               pk_csf_api_nfs.gt_row_nf_compl_serv.dt_exe_serv       := vt_tab_csf_nota_fiscal_serv(i).DT_EXE_SERV;
               pk_csf_api_nfs.gt_row_nf_compl_serv.dm_nat_oper       := vt_tab_csf_nota_fiscal_serv(i).DM_NAT_OPER;
               pk_csf_api_nfs.gt_row_nf_compl_serv.dm_tipo_rps       := vt_tab_csf_nota_fiscal_serv(i).DM_TIPO_RPS;
               pk_csf_api_nfs.gt_row_nf_compl_serv.dm_status_rps     := vt_tab_csf_nota_fiscal_serv(i).DM_STATUS_RPS;
               pk_csf_api_nfs.gt_row_nf_compl_serv.nro_rps_subst     := vt_tab_csf_nota_fiscal_serv(i).NRO_RPS_SUBST;
               pk_csf_api_nfs.gt_row_nf_compl_serv.serie_rps_subst   := vt_tab_csf_nota_fiscal_serv(i).SERIE_RPS_SUBST;
               --
               vn_fase := 4.1;
               --
               pk_csf_api_nfs.pkb_integr_nf_compl_serv ( est_log_generico_nf  => vt_log_generico
                                                       , est_row_nfserv_compl => pk_csf_api_nfs.gt_row_nf_compl_serv
                                                       );
               --
               vn_fase := 4.2;
               --
               pkb_ler_nota_fiscal_serv_ff ( est_log_generico_nf   => vt_log_generico
                                           , en_notafiscal_id      => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                           --| parâmetros de chave
                                           , ev_cpf_cnpj_emit      => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                           , en_dm_ind_emit        => vt_tab_csf_nota_fiscal_serv(i).dm_ind_emit
                                           , en_dm_ind_oper        => vt_tab_csf_nota_fiscal_serv(i).dm_ind_oper
                                           , ev_cod_part           => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                           , ev_serie              => vt_tab_csf_nota_fiscal_serv(i).serie
                                           , en_nro_nf             => vt_tab_csf_nota_fiscal_serv(i).nro_nf
                                           );
               --
               vn_fase := 5;
               --
               -- informações de notas fiscais de serviço
               pkb_ler_itemnf_compl_serv ( est_log_generico_nf       => vt_log_generico
                                         , en_notafiscal_id          => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                         --| parâmetros de chave
                                         , ev_cpf_cnpj_emit          => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                         , en_dm_ind_emit            => vt_tab_csf_nota_fiscal_serv(i).dm_ind_emit
                                         , en_dm_ind_oper            => vt_tab_csf_nota_fiscal_serv(i).dm_ind_oper
                                         , ev_cod_part               => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                         , ev_serie                  => vt_tab_csf_nota_fiscal_serv(i).serie
                                         , en_nro_nf                 => vt_tab_csf_nota_fiscal_serv(i).nro_nf
                                         );
               --
               vn_fase := 6;
               --
               -- Informações de observação da nota fiscal de serviço
               pkb_ler_nfinfor_adic_serv ( est_log_generico_nf       => vt_log_generico
                                         , en_notafiscal_id          => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                         --| parâmetros de chave
                                         , ev_cpf_cnpj_emit          => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                         , en_dm_ind_emit            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT
                                         , en_dm_ind_oper            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER
                                         , ev_cod_part               => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                         , ev_serie                  => vt_tab_csf_nota_fiscal_serv(i).SERIE
                                         , en_nro_nf                 => vt_tab_csf_nota_fiscal_serv(i).NRO_NF
                                         );
               --
               vn_fase := 7;
               -- Leitura de informações Tomador do Serviço
               pkb_ler_nf_dest_serv ( est_log_generico_nf       => vt_log_generico
                                    , en_notafiscal_id          => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                    --| parâmetros de chave
                                    , ev_cpf_cnpj_emit          => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                    , en_dm_ind_emit            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT
                                    , en_dm_ind_oper            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER
                                    , ev_cod_part               => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                    , ev_serie                  => vt_tab_csf_nota_fiscal_serv(i).SERIE
                                    , en_nro_nf                 => vt_tab_csf_nota_fiscal_serv(i).NRO_NF
                                    );
               --
               vn_fase := 8;
               -- Leitura de informações do Intermediário de Serviço
               pkb_ler_nf_inter_serv ( est_log_generico_nf       => vt_log_generico
                                     , en_notafiscal_id          => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                     --| parâmetros de chave
                                     , ev_cpf_cnpj_emit          => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                     , en_dm_ind_emit            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT
                                     , en_dm_ind_oper            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER
                                     , ev_cod_part               => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                     , ev_serie                  => vt_tab_csf_nota_fiscal_serv(i).SERIE
                                     , en_nro_nf                 => vt_tab_csf_nota_fiscal_serv(i).NRO_NF
                                     );
               --
               vn_fase := 9;
               -- Leitura de informações sobre o detalhamento de serviços prestados na construção civil
               pkb_ler_nfs_det_constr_civil ( est_log_generico_nf       => vt_log_generico
                                            , en_notafiscal_id          => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                            --| parâmetros de chave
                                            , ev_cpf_cnpj_emit          => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                            , en_dm_ind_emit            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT
                                            , en_dm_ind_oper            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER
                                            , ev_cod_part               => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                            , ev_serie                  => vt_tab_csf_nota_fiscal_serv(i).SERIE
                                            , en_nro_nf                 => vt_tab_csf_nota_fiscal_serv(i).NRO_NF
                                            );
               --
               vn_fase := 10;
               -- Leitura de informações das duplicatas da cobrança
               pkb_ler_nf_cobr_dup ( est_log_generico_nf       => vt_log_generico
                                   , en_notafiscal_id          => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                   --| parâmetros de chave
                                   , ev_cpf_cnpj_emit          => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                   , en_dm_ind_emit            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT
                                   , en_dm_ind_oper            => vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER
                                   , ev_cod_part               => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                   , ev_serie                  => vt_tab_csf_nota_fiscal_serv(i).SERIE
                                   , en_nro_nf                 => vt_tab_csf_nota_fiscal_serv(i).NRO_NF
                                   , ed_dt_emiss               => vt_tab_csf_nota_fiscal_serv(i).DT_EMISS
                                   );
               --
               vn_fase := 11;
               -- Leitura de informações do complemento do serviço
               pkb_ler_nf_compl_serv ( est_log_generico_nf    => vt_log_generico
                                     , en_notafiscal_id       => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                   --| parâmetros de chave
                                     , ev_cpf_cnpj_emit       => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                     , en_dm_ind_emit         => vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT
                                     , en_dm_ind_oper         => vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER
                                     , ev_cod_part            => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                     , ev_serie               => vt_tab_csf_nota_fiscal_serv(i).serie
                                     , en_nro_nf              => vt_tab_csf_nota_fiscal_serv(i).nro_nf
                                     );
               --
               vn_fase := 12;
               --
               pkb_ler_nf_proc_reinf ( est_log_generico_nf      => vt_log_generico
                                     , en_notafiscal_id         => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                     , en_empresa_id            => pk_csf_api_nfs.gt_row_nota_fiscal.empresa_id
                                   --| parâmetros de chave
                                     , ev_cpf_cnpj_emit         => vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit
                                     , en_dm_ind_emit           => vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT
                                     , en_dm_ind_oper           => vt_tab_csf_nota_fiscal_serv(i).DM_IND_OPER
                                     , ev_cod_part              => vt_tab_csf_nota_fiscal_serv(i).cod_part
                                     , ev_serie                 => vt_tab_csf_nota_fiscal_serv(i).serie
                                     , en_nro_nf                => vt_tab_csf_nota_fiscal_serv(i).nro_nf
                                     , ed_dt_emiss              => vt_tab_csf_nota_fiscal_serv(i).dt_emiss
                                     );
               --
               -----------------------------
               -- Processos que consistem a informação da Nota Fiscal de Serviço
               -----------------------------
               pk_csf_api_nfs.pkb_consistem_nf ( est_log_generico_nf  => vt_log_generico
                                               , en_notafiscal_id     => pk_csf_api_nfs.gt_row_nota_fiscal.id
                                               );
               --
               vn_fase := 99;
               --
               -- Se registrou algum log, altera a Nota Fiscal de Serviço para dm_st_proc = 10 - "Erro de Validação"
               if nvl(vt_log_generico.count,0) > 0 and
                  pk_csf_api_nfs.fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => pk_csf_api_nfs.gt_row_nota_fiscal.ID ) = 1 then
                  --
                  vn_fase := 99.1;
                  --
                  begin
                     --
                     vn_fase := 99.2;
                     --
                     -- Variavel global usada em logs de triggers (carrega)
                     gv_objeto := 'pk_integr_view_nfs.pkb_ler_nota_fiscal_serv';
                     gn_fase   := vn_fase;
                     --
                     update NOTA_FISCAL set dm_st_proc = 10
                                          , dt_st_proc = sysdate
                      where id = pk_csf_api_nfs.gt_row_nota_fiscal.ID;
                     --
                     -- Variavel global usada em logs de triggers (limpa)
                     gv_objeto := 'pk_integr_view_nfs';
                     gn_fase   := null;
                     --
                  exception
                     when others then
                        --
                        pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_NOTA_FISCAL fase(' || vn_fase || '):' || sqlerrm;
                        --
                        declare
                           vn_loggenerico_id  log_generico_nf.id%TYPE;
                        begin
                           --
                            pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                                               , ev_resumo          => gv_cabec_nf
                                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                               , en_referencia_id   => pk_csf_api_nfs.gt_row_nota_fiscal.ID
                                                               , ev_obj_referencia  => 'NOTA_FISCAL'
                                                               );
                           --
                         exception
                           when others then
                              null;
                        end;
                        --
                  end;
                  --
               else
                  -- Se não houve nenhum registro de ocorrência
                  -- então atualiza o dm_st_proc para 1-Aguardando Envio se não for emissão propia
                  vn_fase := 99.3;
                  --
                  begin
                     --
                     -- Em caso de Notas emitidas por terceiros, situação fica como AUtorizada
                     if vt_tab_csf_nota_fiscal_serv(i).DM_IND_EMIT = 1 -- Emissão terceiros
                        and vv_cod_mod = '99'
                        then
                        --
                        vn_dm_tp_transmis_terc := pk_csf_nfs.fkg_empr_cidade_tp_trans_terc ( en_empresa_id => vn_empresa_id );
                        --
                        if nvl(vn_dm_tp_transmis_terc,0) = 1 then
                           --
                           -- Variavel global usada em logs de triggers (carrega)
                           gv_objeto := 'pk_integr_view_nfs.pkb_ler_nota_fiscal_serv';
                           gn_fase   := vn_fase;
                           --
                           -- Prefeitura de Salvador, altera situação para 21-Aguardando Liberacao
                           update NOTA_FISCAL set dm_st_proc = 21
                                                , dt_st_proc = sysdate
                            where id = pk_csf_api_nfs.gt_row_nota_fiscal.ID;
                           --
                           -- Variavel global usada em logs de triggers (limpa)
                           gv_objeto := 'pk_integr_view_nfs';
                           gn_fase   := null;
                           --
                        else
                           --
                           -- Variavel global usada em logs de triggers (carrega)
                           gv_objeto := 'pk_integr_view_nfs.pkb_ler_nota_fiscal_serv';
                           gn_fase   := vn_fase;
                           --
                           update NOTA_FISCAL set dm_st_proc = 4
                                                , dt_st_proc = sysdate
                            where id = pk_csf_api_nfs.gt_row_nota_fiscal.ID;
                           --
                           -- Variavel global usada em logs de triggers (limpa)
                           gv_objeto := 'pk_integr_view_nfs';
                           gn_fase   := null;
                           --
                        end if;
                        --
                     end if;
                     --
                  exception
                     when others then
                        --
                        pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nota_fiscal_serv fase(' || vn_fase || '):' || sqlerrm;
                        --
                        declare
                           vn_loggenerico_id  log_generico_nf.id%TYPE;
                        begin
                           --
                           pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                              , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                              , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                                              , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                              , en_referencia_id     => pk_csf_api_nfs.gt_row_nota_fiscal.ID
                                                              , ev_obj_referencia    => 'NOTA_FISCAL'
                                                              );
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
               commit;
               --
            end if;
            -- 
            -- #71510 -alteracao do local onde valida as qts 
            vn_fase := 99.4;
            --
            -- Calcula a quantidade de registros integrados com sucesso
            -- e com erro para ser mostrado na tela de agendamento.
            --
            begin
               --
               if pk_agend_integr.gvtn_qtd_total(gv_cd_obj) >
                  (pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) + pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj)) then
                  --
                  if nvl(vt_log_generico.count,0) > 0 then -- Erro de validação
                     -- verifica se no log generico tem erro ou só aviso/informação
                     if pk_csf_api_nfs.fkg_ver_erro_log_generico_nfs( en_nota_fiscal_id => pk_csf_api_nfs.gt_row_nota_fiscal.ID ) = 1 then
                        --
                        pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
                        --
                     else
                        --
                        pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
                        --
                     end if;
                  else
                     --
                     pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
                     --
                  end if;
                  --
               end if;
               --
               commit;
               --
            exception
               when others then
               /*null;*/
               ---
               pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nota_fiscal_serv fase(' || vn_fase || ') - id da nota fiscal :'|| pk_csf_api_nfs.gt_row_nota_fiscal.ID ||' - erro:'|| sqlerrm;
               ---
               declare
                  vn_loggenericonf_id  log_generico_nf.id%TYPE;
               begin
                  pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id   => vn_loggenericonf_id
                                                 , ev_mensagem           => pk_csf_api.gv_mensagem_log
                                                 , ev_resumo             => 'Erro na contagem na quantidade de registros no processo de agendamento de integração.'
                                                 , en_tipo_log           => pk_csf_api.INFORMACAO
                                                 , en_referencia_id      => pk_csf_api_nfs.gt_row_nota_fiscal.ID
                                                 , ev_obj_referencia     => 'NOTA_FISCAL'
                                                 );
               exception
                  when others then
                     null;
               end;
            end;
            --
            --
         else
            --
            vn_fase := 100;
            -- Gerar log no agendamento devido a data de fechamento
            --
            info_fechamento := pk_csf.fkg_retorna_csftipolog_id(ev_cd => 'INFO_FECHAMENTO');
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%type;
            begin
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                  , ev_mensagem          => 'Integração de notas fiscais de serviço'
                                                  , ev_resumo            => 'Período informado para integração da nota fiscal de serviço não permitido devido a '
                                                                            ||'data de fechamento fiscal '                            || to_char(vd_dt_ult_fecha,'dd/mm/yyyy')
                                                                            ||' - CNPJ/CPF: '                                         || trim(vt_tab_csf_nota_fiscal_serv(i).cpf_cnpj_emit)
                                                                            ||', Número da NF: '                                      || vt_tab_csf_nota_fiscal_serv(i).nro_nf
                                                                            ||', Série: '                                             || trim(vt_tab_csf_nota_fiscal_serv(i).serie)
                                                                            ||', Indicador do emitente: '                             || vt_tab_csf_nota_fiscal_serv(i).dm_ind_emit
                                                                            ||', Indicador da operacão: '                             || vt_tab_csf_nota_fiscal_serv(i).dm_ind_oper
                                                                            ||', Data de Saida ou da Entrada da Mercadoria/Produto: ' || to_char(vt_tab_csf_nota_fiscal_serv(i).dt_sai_ent,'dd/mm/yyyy')
                                                                            ||', Data de emiss?o do Documento Fiscal: '               || to_char(vt_tab_csf_nota_fiscal_serv(i).dt_emiss,'dd/mm/yyyy')
                                                                            ||'.'
                                                  , en_tipo_log          => info_fechamento
                                                  , en_referencia_id     => null
                                                  , ev_obj_referencia    => 'NOTA_FISCAL'
                                                  , en_empresa_id        => gn_empresa_id
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
         pk_csf_api_nfs.pkb_seta_referencia_id ( en_id => null );
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
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nota_fiscal_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => pk_csf_api_nfs.gt_row_nota_fiscal.ID
                                         , ev_obj_referencia  => 'NOTA_FISCAL'
                                         );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nota_fiscal_serv;

-------------------------------------------------------------------------------------------------------


-- grava informação da alteração da situação da integração da Nfe

procedure pkb_alter_sit_integra_nfe ( en_notafiscal_id  in  nota_fiscal.id%type
                                    , en_dm_st_integra  in  nota_fiscal.dm_st_integra%type )
is
   --
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
      update nota_fiscal set dm_st_integra = nvl(en_dm_st_integra,0)
       where id = en_notafiscal_id;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_alter_sit_integra_nfe fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_cabec_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' 
                                         );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_alter_sit_integra_nfe;

-------------------------------------------------------------------------------------------------------

-- grava informação da alteração da situação da integração da Nfe

procedure pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  in  nota_fiscal.id%type
                                         , en_dm_st_integra  in  nota_fiscal.dm_st_integra%type )
is
   --
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
      update nota_fiscal_canc set dm_st_integra = nvl(en_dm_st_integra,0)
       where notafiscal_id = en_notafiscal_id;
      --
   end if;
   --
   vn_fase := 3;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_alter_sit_integra_nfe_canc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_cabec_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => en_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_alter_sit_integra_nfe_canc;
-- 
-- =================================================================================================================== --
--
-- retorna informações de Erro ocorrido no processo da nota fiscal
procedure pkb_ret_infor_erro_nf_erp ( en_notafiscal_id in nota_fiscal.id%type
                                    , ev_obj           in obj_util_integr.obj_name%type )
is
   --
   vn_fase             number := 0;
   vv_obj              varchar2(4000) := null;
   vv_cpf_cnpj         varchar2(14)   := null;
   --
   vv_cod_part         pessoa.cod_part%type;
   vv_cod_mod          mod_fiscal.cod_mod%type;
   vv_sistorig_sigla   sist_orig.sigla%type;
   vv_unidorg_cd       unid_org.cd%type;
   --
   cursor c_nf is
   select nf.empresa_id
        , nf.dm_ind_oper
        , nf.dm_ind_emit
        , nf.pessoa_id
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
   select lg.id                 loggenerico_id
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
                   , 'INFO_RET_PROC_LOTE_NFE'
                   , 'INFO_LOG_GENERICO'
                   )
   union all
   select lg.id                 loggenerico_id
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
                   , 'INFO_RET_PROC_LOTE_NFE'
                   , 'INFO_LOG_GENERICO'
                   )
    order by 1;
   --
   -- =============================================================================================================== --
   -- Fuction interna
   function fkg_existe_log ( en_loggenericonf_id_id in log_generico_nf.id%type
                           ) return number
   is
      --
      vv_sql_canc varchar2(4000);
      vn_ret      number := 0;
      --
   begin
      --
      -- Não pega notas com registro de cancelamento
      vv_sql_canc := vv_sql_canc || 'select 1 ' || fkg_monta_from ( ev_obj => ev_obj );
      --
      vv_sql_canc := vv_sql_canc || ' where ' || trim(GV_ASPAS) || 'LOGGENERICO_ID' || trim(GV_ASPAS) || ' = ' || en_loggenericonf_id_id;
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
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na fkg_existe_log:' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                  , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                  , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                                  , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                  , en_referencia_id     => null
                                                  , ev_obj_referencia    => 'NOTA_FISCAL' );
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
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => ev_obj ) = 0 then
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
         vv_cod_part         := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec1.pessoa_id );
         --
         vn_fase := 3.2;
         --
         vv_sistorig_sigla   := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec1.sistorig_id );
         --
         vn_fase := 3.4;
         --
         vv_unidorg_cd       := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec1.unidorg_id );
         --
         vn_fase := 3.5;
         --
         -- Insere os registros de log da nota Fiscal
         for rec2 in c_log(rec1.notafiscal_id) loop
            exit when c_log%notfound or (c_log%notfound) is null;
            --
            vn_fase := 4;
            --
            if trim(rec2.resumo) is not null
               and fkg_existe_log ( en_loggenericonf_id_id => rec2.loggenerico_id ) = 0
               then
               --
               gv_sql := 'insert into ';
               --
               if GV_NOME_DBLINK is not null then
                  --
                  vn_fase := 5;
                  --
                  vv_obj := trim(GV_ASPAS) || ev_obj || trim(GV_ASPAS) || '@' || GV_NOME_DBLINK;
                  --
               else
                  --
                  vn_fase := 6;
                  --
                  vv_obj := trim(GV_ASPAS) || ev_obj || trim(GV_ASPAS);
                  --
               end if;
               --
               if trim(GV_OWNER_OBJ) is not null then
                  vv_obj := trim(GV_OWNER_OBJ) || '.' || vv_obj;
               else
                  vv_obj := vv_obj;
               end if;
               --
               vn_fase := 7;
               --
               gv_sql := gv_sql || vv_obj || ' (';
               --
               gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT'  || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'    || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'    || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'       || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE'          || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NOTAFISCAL_ID'  || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'LOGGENERICO_ID' || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'RESUMO'         || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_LEITURA'     || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SIST_ORIG'      || trim(GV_ASPAS);
               gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'UNID_ORG'       || trim(GV_ASPAS);
               --
               gv_sql := gv_sql || ') values (';
               --
               gv_sql := gv_sql || '''' || vv_cpf_cnpj || '''';
               gv_sql := gv_sql || ', ' || rec1.DM_IND_OPER;
               gv_sql := gv_sql || ', ' || rec1.DM_IND_EMIT;
               --
               gv_sql := gv_sql || ', ' || case when trim(vv_cod_part) is not null then '''' || trim(vv_cod_part) || '''' else '''' || ' ' || '''' end;
               --
               gv_sql := gv_sql || ', ' || '''' || trim(rec1.SERIE) || '''';
               gv_sql := gv_sql || ', ' || rec1.NRO_NF;
               gv_sql := gv_sql || ', ' || rec1.notafiscal_id;
               gv_sql := gv_sql || ', ' || nvl(rec2.loggenerico_id,0);
               gv_sql := gv_sql || ', ' || case when trim(rec2.resumo) is not null then '''' || trim(pk_csf.fkg_converte(rec2.resumo)) || '''' else '''' || ' ' || '''' end;
               gv_sql := gv_sql || ', 0'; -- DM_LEITURA
               gv_sql := gv_sql || ', ' || case when trim(vv_sistorig_sigla) is not null then '''' || trim(vv_sistorig_sigla) || '''' else '''' || ' ' || '''' end;
               gv_sql := gv_sql || ', ' || case when trim(vv_unidorg_cd) is not null then '''' || trim(vv_unidorg_cd) || '''' else '''' || ' ' || '''' end;
               --
               gv_sql := gv_sql || ')';
               --
               vn_fase := 8;
               --
               begin
                  --
                  execute immediate gv_sql;
                  --
               exception
                  when others then
                     -- não registra erro caso a view não exista
                     --if sqlcode IN (-942, -28500, -01010, -02063) then
                     --   null;
                     --else
                        --
                        pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ret_infor_erro_nf_erp fase(' || vn_fase || '):' || sqlerrm;
                        --
                        declare
                           vn_loggenerico_id  log_generico_nf.id%TYPE;
                        begin
                           --
                           pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                              , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                              , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                                              , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                              , en_referencia_id     => en_notafiscal_id
                                                              , ev_obj_referencia    => 'NOTA_FISCAL' );
                           --
                        exception
                           when others then
                              null;
                        end;
                        --
                     --end if;
               end;
               --
            end if;
            --
         end loop;
         --
      end loop;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ret_infor_erro_nf_erp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                            , ev_mensagem          => pk_csf_api_nfs.gv_cabec_log
                                            , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                            , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id     => null
                                            , ev_obj_referencia    => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ret_infor_erro_nf_erp;
-- 
-- =================================================================================================================== --
--
--| Procedimento responsável por excluir os dados de resposta da NFSe no ERP

procedure pkb_excluir_nfs ( ev_cpf_cnpj_emit          in             varchar2
                          , en_dm_ind_emit            in             number
                          , ev_cod_part               in             varchar2
                          , ev_serie                  in             varchar2
                          , en_nro_nf                 in             number
                          , en_notafiscal_id          in             number
                          , ev_obj                    in             varchar2
                          , ev_aspas                  in             varchar2
                          )
is
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
   gv_sql := gv_sql || ' and ' || ev_aspas || 'DM_IND_EMIT' || ev_aspas || ' = ' || en_dm_ind_emit;
   --
   gv_sql := gv_sql || ' and trim(' || trim(ev_aspas) || 'SERIE' || trim(ev_aspas) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || ev_aspas || 'NRO_NF' || ev_aspas || ' = ' || en_nro_nf;
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
end pkb_excluir_nfs;
--
-- ========================================================================================================================== --
--
function fkg_ret_dm_st_proc_erp ( en_notafiscal_id   in number
                                , ev_obj             in varchar2
                                , ev_aspas           in varchar2
                                , ev_obj_name        in varchar2
                                ) return number
is
   --
   vn_dm_st_proc_erp number(2) := null;
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
   gv_sql := 'SELECT distinct ';
   gv_sql := gv_sql || ev_aspas  || 'DM_ST_PROC' || ev_aspas;
   gv_sql := gv_sql || ' from '  || ev_obj;
   --
   gv_sql := gv_sql || ' where ' || ev_aspas || 'NOTAFISCAL_ID' || ev_aspas || ' = ' || en_notafiscal_id;
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
         -- não registra erro casa a view não exista
         if sqlcode in (-942, -1010) then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pkb_integr_view_nfs.fkg_ret_dm_st_proc_erp:' || sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                  , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                  , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                                  , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                  , en_referencia_id     => en_notafiscal_id
                                                  , ev_obj_referencia    => 'NOTA_FISCAL' );
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
      return null;
end fkg_ret_dm_st_proc_erp;
--
-- ========================================================================================================================== --
--
function fkg_monta_obj ( ev_obj           varchar2
                       , ev_owner_obj     empresa_integr_banco.owner_obj%type
                       , ev_nome_dblink   empresa_integr_banco.nome_dblink%type
                       , ev_aspas         char
                       )
         return varchar2
is
   --
   vv_obj_montado varchar2(255) := null;
   --
begin
   --
   vv_obj_montado := ev_aspas || ev_obj || ev_aspas;
   --
   if ev_nome_dblink is not null then
      vv_obj_montado := vv_obj_montado || '@' || ev_nome_dblink;
   end if;
   --
   if trim(ev_owner_obj) is not null then
      vv_obj_montado := trim(ev_owner_obj) || '.' || vv_obj_montado;
   end if;
   --
   return vv_obj_montado;
   --
exception
   when others then
   --
   return null;
   --
end fkg_monta_obj;

-------------------------------------------------------------------------------------------------------

-- Função que retorna a quantidade de registros da tabela VW_CSF_RESP_NFS_ERP_FF conforme a chave e atributo

function fkg_existe_registro ( ev_cpf_cnpj_emit   varchar2
                             , en_dm_ind_emit     number
                             , en_dm_ind_oper     number
                             , ev_cod_part        varchar2
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
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || ev_aspas || 'COUNT(1)' || ev_aspas;
   --
   gv_sql := gv_sql || ' FROM ' || ev_obj;
   --
   vn_fase := 2.1;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            ev_aspas || 'CPF_CNPJ_EMIT' || ev_aspas || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
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
   gv_sql := gv_sql || ' and trim(' || trim(ev_aspas) || 'SERIE' || trim(ev_aspas) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || ev_aspas || 'NRO_NF'   || ev_aspas || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || ev_aspas || 'ATRIBUTO' || ev_aspas || ' = ' || '''' || ev_atributo || '''';
   --
   vn_fase := 3;
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
        gv_resumo := 'Erro na pk_integr_view_nfs.fkg_existe_registro fase(' || vn_fase || '):' || sqlerrm;
        --
        declare
           vn_loggenerico_id  log_generico_nf.id%TYPE;
        begin
           --
           pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                              , ev_mensagem        => gv_resumo
                                              , ev_resumo          => gv_resumo
                                              , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                              , en_referencia_id   => null
                                              , ev_obj_referencia  => 'NOTA_FISCAL'
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
   commit;
   --
   return vn_existe;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_integr_view_nfs.fkg_existe_registro:' || sqlerrm);
end fkg_existe_registro;

-------------------------------------------------------------------------------------------------------

--| Procedimento integra informações no ERP para campos FF

procedure pkb_int_ret_infor_erp_ff ( ev_cpf_cnpj_emit  in  varchar2
                                   , en_dm_ind_emit    in  number
                                   , en_dm_ind_oper    in  number
                                   , ev_cod_part       in  varchar2
                                   , ev_serie          in  varchar2
                                   , en_nro_nf         in  number
                                   , en_notafiscal_id  in  nota_fiscal.id%type default 0
                                   , ev_owner_obj      in  empresa_integr_banco.owner_obj%type
                                   , ev_nome_dblink    in  empresa_integr_banco.nome_dblink%type
                                   , ev_aspas          in  char
                                   )
is
   --
   vn_fase    number         := 0;
   vv_insert  varchar2(4000) := null;
   vv_update  varchar2(4000) := null;
   vv_obj     varchar2(255)  := null;
   vn_existe   number        := 0;
   --
   cursor c_ff is
      select 'COD_VERIF_NFS' atributo
           , cod_verif_nfs valor
        from nf_compl_serv
       where notafiscal_id = en_notafiscal_id
      union
      select 'ID_ERP' atributo
           , to_char(nfcomp.id_erp) valor
        from nota_fiscal_compl nfcomp
       where nfcomp.notafiscal_id = en_notafiscal_id
        and not exists ( select 1
                            from nota_fiscal_canc nfc
                           where nfc.notafiscal_id = nfcomp.notafiscal_id )
      union
      select 'ID_ERP' atributo
          , to_char(nfc.id_erp) valor
       from nota_fiscal_canc nfc
      where nfc.notafiscal_id = en_notafiscal_id;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NFS_ERP_FF') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NFS_ERP_FF'
                                  , ev_aspas       => ev_aspas
                                  , ev_owner_obj   => ev_owner_obj
                                  , ev_nome_dblink => ev_nome_dblink
                                  );
   --
   vv_insert := 'insert into ' || vv_obj || '(';
   --
   vv_insert := vv_insert ||         ev_aspas       || 'CPF_CNPJ_EMIT' || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas       || 'DM_IND_EMIT'   || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas       || 'DM_IND_OPER'   || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas       || 'COD_PART'      || ev_aspas;
   vv_insert := vv_insert || ', ' || trim(ev_aspas) || 'SERIE'         || trim(ev_aspas);
   vv_insert := vv_insert || ', ' || ev_aspas       || 'NRO_NF'        || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas       || 'ATRIBUTO'      || ev_aspas;
   vv_insert := vv_insert || ', ' || ev_aspas       || 'VALOR'         || ev_aspas;
   --
   vv_insert := vv_insert || ') values (';
   --
   vv_insert := vv_insert || '''' || ev_cpf_cnpj_emit || '''';
   vv_insert := vv_insert || ', ' || en_dm_ind_emit;
   vv_insert := vv_insert || ', ' || en_dm_ind_oper;
   --
   vv_insert := vv_insert || ', ' || case when trim(ev_cod_part) is not null then '''' || trim(ev_cod_part) || '''' else '''' || ' ' || '''' end;
   --
   vv_insert := vv_insert || ', ' || '''' || trim(ev_serie) || '''';
   vv_insert := vv_insert || ', ' || en_nro_nf;
   --
   vn_fase := 3;
   --
   vv_update := 'update ' || vv_obj || ' set ';
   --
   vn_fase := 4;
   --
   for rec in c_ff loop
      exit when c_ff%notfound or (c_ff%notfound) is null;
      --
      vn_fase := 5;
      --
      vn_existe := 0;
      --
      if trim(rec.valor) is not null then
         --
         vn_existe := fkg_existe_registro ( ev_cpf_cnpj_emit => ev_cpf_cnpj_emit
                                          , en_dm_ind_emit   => en_dm_ind_emit
                                          , en_dm_ind_oper   => en_dm_ind_oper
                                          , ev_cod_part      => ev_cod_part
                                          , ev_serie         => ev_serie
                                          , en_nro_nf        => en_nro_nf
                                          , ev_atributo      => rec.atributo
                                          , ev_obj           => vv_obj
                                          , ev_aspas         => ev_aspas
                                          );
         --
         if vn_existe > 0 then
            --
            gv_sql := vv_update || ev_aspas || 'VALOR' || ev_aspas || ' = ' || '''' || rec.valor || '''';
            --
            gv_sql := gv_sql || ' where ';
            gv_sql := gv_sql || ev_aspas || 'CPF_CNPJ_EMIT' || ev_aspas || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
            gv_sql := gv_sql || ' and ' || ev_aspas || 'DM_IND_EMIT' || ev_aspas || ' = ' || en_dm_ind_emit;
            gv_sql := gv_sql || ' and ' || ev_aspas || 'DM_IND_OPER' || ev_aspas || ' = ' || en_dm_ind_oper;
            --
            vn_fase := 6;
            --
            if ev_cod_part is not null then
               --
               gv_sql := gv_sql || ' and ' || ev_aspas || 'COD_PART' || ev_aspas || ' = ' || '''' || ev_cod_part || '''';
               --
            end if;
            --
            vn_fase := 7;
            --
            gv_sql := gv_sql || ' and trim(' || trim(ev_aspas) || 'SERIE' || trim(ev_aspas) || ') ' || ' = ' || '''' || ev_serie || '''';
            gv_sql := gv_sql || ' and ' || ev_aspas || 'NRO_NF'   || ev_aspas || ' = ' || en_nro_nf;
            gv_sql := gv_sql || ' and ' || ev_aspas || 'ATRIBUTO' || ev_aspas || ' = ' || '''' || rec.atributo || '''';
            --
         else
            --
            vn_fase := 8;
            --
            gv_sql := vv_insert || ', ' || '''' || rec.atributo || '''';
            gv_sql := gv_sql || ', ' || '''' || rec.valor || ''')';
            --
         end if;
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
            --if sqlcode IN (-942, -1, -28500, -01010, -02063) then
            --   null;
            --else
               --
               pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_int_ret_infor_erp_ff fase(' || vn_fase || '):' || sqlerrm || ' - ' || gv_sql;
               --
               declare
                  vn_loggenerico_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                     , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                                     , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                                     , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                     , en_referencia_id   => en_notafiscal_id
                                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
                  --
               exception
                  when others then
                     null;
               end;
               --
            --end if;
            --
         end;
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
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_int_ret_infor_erp_ff fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                            , ev_mensagem        => pk_csf_api_nfs.gv_cabec_log
                                            , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                            , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id   => en_notafiscal_id
                                            , ev_obj_referencia  => 'NOTA_FISCAL'
                                            );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_ret_infor_erp_ff;
--
-- =============================================================================================================================== --
--
--| Procedimento integra informações no ERP
procedure pkb_int_infor_erp ( ev_cpf_cnpj_emit  in  varchar2
                            , en_notafiscal_id  in  nota_fiscal.id%type default 0
                            )
is
   --
   vn_fase                  number := 0;
   vn_notafiscal_id         Nota_Fiscal.id%TYPE;
   vn_dm_st_proc_erp        nota_fiscal.DM_ST_PROC%type;
   vv_obj                   varchar2(4000) := null;
   vn_erro                  number := 0;
   vn_dm_ret_hr_aut         empresa.dm_ret_hr_aut%type := 0;
   vn_empresa_id            empresa.id%type := null;
   vv_cpf_cnpj              varchar2(14) := null;
   vv_cod_part              pessoa.cod_part%type;
   vv_sistorig_sigla        sist_orig.sigla%type;
   vv_unidorg_cd            unid_org.cd%type;
   vv_link                  nf_compl_serv.link%type;
   vn_nro_aut_nfs           nf_compl_serv.nro_aut_nfs%type;
   vv_owner_obj             empresa_integr_banco.owner_obj%type;
   vv_nome_dblink           empresa_integr_banco.nome_dblink%type;
   vn_dm_util_aspa          empresa_integr_banco.dm_util_aspa%type;
   vn_dm_ret_infor_integr   empresa_integr_banco.dm_ret_infor_integr%type;
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
        , nf.dm_st_proc
        , nf.id                 notafiscal_id
        , nf.dt_emiss
        , nf.dm_st_integra
        , nf.sistorig_id
        , nf.unidorg_id
        , nf.empresaintegrbanco_id
     from Nota_Fiscal           nf
        , mod_fiscal            mf
    where nf.empresa_id         = en_empresa_id
      and nf.dm_st_proc         <> 0
      and nf.dm_ind_emit        = 0
      and nf.dm_st_integra      = 7
      and mf.id                 = nf.modfiscal_id
      and mf.cod_mod            IN ('99', 'ND')
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NFS_ERP') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => gn_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   for rec in c_nf(vn_empresa_id) loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      if nvl(rec.empresaintegrbanco_id,0) > 0
         and nvl(rec.empresaintegrbanco_id,0) <> nvl(gn_empresaintegrbanco_id,0)
         then
         --
         begin
            --
            select ei.owner_obj
                 , ei.nome_dblink
                 , ei.dm_util_aspa
                 , ei.dm_ret_infor_integr
              into vv_owner_obj
                 , vv_nome_dblink
                 , vn_dm_util_aspa
                 , vn_dm_ret_infor_integr
              from empresa_integr_banco ei
             where ei.id = rec.empresaintegrbanco_id;
            --
         exception
            when others then
               null;
         end;
         --
         if nvl(vn_dm_util_aspa,0) = 1 then
            --
            vv_aspas := '"';
            --
         end if;
         --
      else
         --
         vv_owner_obj           := GV_OWNER_OBJ;
         vv_nome_dblink         := GV_NOME_DBLINK;
         vv_aspas               := GV_ASPAS;
         vn_dm_ret_infor_integr := 1;
         --
      end if;
      --
      vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NFS_ERP'
                                     , ev_aspas       => vv_aspas
                                     , ev_owner_obj   => vv_owner_obj
                                     , ev_nome_dblink => vv_nome_dblink
                                     );
      --
      if nvl(vn_dm_ret_infor_integr,0) = 1 then
         --
         vn_fase := 3;
         --
         vn_empresa_id := rec.empresa_id;
         --
         vv_cpf_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
         --
         vn_fase := 4;
         --
         vn_dm_ret_hr_aut := pk_csf.fkg_ret_hr_aut_empresa_id ( en_empresa_id => vn_empresa_id );
         --
         vn_fase := 4.1;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
         --
         vn_fase := 4.2;
         --
         vv_sistorig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec.sistorig_id );
         --
         vn_fase := 4.3;
         --
         vv_unidorg_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec.unidorg_id );
         --
         vn_fase := 4.4;
         --
         begin
            --
            select cs.link
                 , cs.nro_aut_nfs
              into vv_link
                 , vn_nro_aut_nfs
              from nf_compl_serv cs
             where cs.notafiscal_id = rec.notafiscal_id;
            --
         exception
            when others then
               vv_link := null;
               vn_nro_aut_nfs := null;
         end;
         --
         vn_fase := 4.5;
         --
         vn_fase := 5;
         --
         pkb_excluir_nfs ( ev_cpf_cnpj_emit   => vv_cpf_cnpj
                         , en_dm_ind_emit     => rec.dm_ind_emit
                         , ev_cod_part        => vv_cod_part
                         , ev_serie           => rec.serie
                         , en_nro_nf          => rec.nro_nf
                         , en_notafiscal_id   => rec.notafiscal_id
                         , ev_obj             => vv_obj
                         , ev_aspas           => vv_aspas
                         );
         --
         vn_fase := 5.1;
         --| verificar se existe
         vn_dm_st_proc_erp := fkg_ret_dm_st_proc_erp ( en_notafiscal_id   => rec.notafiscal_id
                                                     , ev_obj             => vv_obj
                                                     , ev_aspas           => vv_aspas
                                                     , ev_obj_name        => 'VW_CSF_RESP_NFS_ERP'
                                                     );
         -- se não encontrou informa o registro
         if nvl(vn_dm_st_proc_erp,-1) = -1
            and nvl(rec.nro_nf,0) > 0
            then
            --
            vn_fase := 6;
            --
            vn_notafiscal_id := rec.notafiscal_id;
            --
            gv_sql := 'insert into ';
            --
            vn_fase := 9;
            --
            gv_sql := gv_sql || vv_obj || '(';
            --
            gv_sql := gv_sql ||         vv_aspas       || 'CPF_CNPJ_EMIT' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'DM_IND_OPER'   || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'DM_IND_EMIT'   || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'COD_PART'      || vv_aspas;
            gv_sql := gv_sql || ', ' || trim(vv_aspas) || 'SERIE'         || trim(vv_aspas);
            gv_sql := gv_sql || ', ' || vv_aspas       || 'NRO_NF'        || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'DM_ST_PROC'    || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'LINK'          || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'NRO_AUT_NFS'   || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'NOTAFISCAL_ID' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'DM_LEITURA'    || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'SIST_ORIG'     || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'UNID_ORG'      || vv_aspas;
            --
            vn_fase := 10;
            --
            gv_sql := gv_sql || ') values (';
            --
            gv_sql := gv_sql || '''' || ev_cpf_cnpj_emit || '''';
            gv_sql := gv_sql || ', ' || rec.DM_IND_OPER;
            gv_sql := gv_sql || ', ' || rec.DM_IND_EMIT;
            --
            vn_fase := 10.1;
            --
            --if rec.dm_ind_emit = 1 then
               gv_sql := gv_sql || ', ' || case when trim(vv_cod_part) is not null then '''' || trim(vv_cod_part) || '''' else '''' || ' ' || '''' end;
            --else
            --   gv_sql := gv_sql || ', ' || '''' || ' ' || '''';
            --end if;
            --
            gv_sql := gv_sql || ', ' || '''' || trim(rec.SERIE) || '''';
            gv_sql := gv_sql || ', ' || rec.NRO_NF;
            vn_fase := 10.2;
            gv_sql := gv_sql || ', ' || case when rec.DM_ST_PROC = 0 then 1 else rec.DM_ST_PROC end;
            vn_fase := 10.3;
            gv_sql := gv_sql || ', ' || case when trim(vv_link) is not null then '''' || trim(vv_link) || '''' else '''' || ' ' || '''' end;
            vn_fase := 10.4;
            gv_sql := gv_sql || ', ' || nvl(vn_nro_aut_nfs, 0);
            gv_sql := gv_sql || ', ' || rec.NOTAFISCAL_ID;
            --
            gv_sql := gv_sql || ', 0'; -- DM_LEITURA
            --
            vn_fase := 10.5;
            --
            gv_sql := gv_sql || ', ' ||  case when trim(vv_sistorig_sigla) is null then '''' || ' ' || '''' else '''' || trim(vv_sistorig_sigla) || '''' end;
            --
            gv_sql := gv_sql || ', ' ||  case when trim(vv_unidorg_cd) is null then '''' || ' ' || '''' else '''' || trim(vv_unidorg_cd) || '''' end;
            --
            vn_fase := 11;
            --
            gv_sql := gv_sql || ')';
            --
            vn_fase := 12;
            --
            vn_erro := 0;
            --insert into erro values (gv_sql); commit;
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
                  rollback;
                  --
                  -- não registra erro caso a view não exista
                  --if sqlcode IN (-942, -1, -28500, -01010, -02063) then
                  --   null;
                  --else
                     --
                     pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_int_infor_erp fase(' || vn_fase || '):' || sqlerrm || ' - ' || gv_sql;
                     --
                     declare
                        vn_loggenerico_id  log_generico_nf.id%TYPE;
                     begin
                        --
                        pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                        , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                                        , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                                        , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                        , en_referencia_id   => rec.NOTAFISCAL_ID
                                                        , ev_obj_referencia  => 'NOTA_FISCAL' );
                        --
                     exception
                        when others then
                           null;
                     end;
                     --
                  --end if;
            end;
            --
            commit;
            --
            vn_fase := 13;
            --
            if rec.DM_ST_PROC not in (0, 1, 2, 3, 4, 6, 7, 8, 20) then
               --
               begin
                  -- grava informações de erro para o erp
                  pkb_ret_infor_erro_nf_erp ( en_notafiscal_id => rec.notafiscal_id 
                                            , ev_obj           => 'VW_CSF_RESP_ERRO_NFS_ERP' ); 
                  --
               exception
                  when others then
                     vn_erro := 1;
               end;
               --
            end if;
            --
            if nvl(vn_erro,0) = 0 then
               --
               vn_fase := 14;
               --
               if rec.DM_ST_PROC not in (4, 6, 7, 8, 20)
                  then
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => 8 );
                  --
               else
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
            vn_fase := 15;
            --
            pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                      , en_dm_st_integra  => 8 );
            --
         end if;
         --
         vn_fase := 16;
         --
         -- Procedimento integra informações no ERP para campos FF
         pkb_int_ret_infor_erp_ff ( ev_cpf_cnpj_emit  => ev_cpf_cnpj_emit
                                  , en_dm_ind_emit    => rec.dm_ind_emit
                                  , en_dm_ind_oper    => rec.dm_ind_oper
                                  , ev_cod_part       => vv_cod_part
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
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_int_infor_erp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => vn_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_infor_erp;
--
-- =============================================================================================================================== --
--
--| Procedimento integra informações no ERP
procedure pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit  in  varchar2
                                , en_notafiscal_id  in  nota_fiscal.id%type default 0 )
is
   --
   vn_fase                  number := 0;
   vn_notafiscal_id         Nota_Fiscal.id%TYPE;
   vn_dm_st_proc_erp        nota_fiscal.DM_ST_PROC%type;
   vv_obj                   varchar2(4000) := null;
   vn_erro                  number := 0;
   vn_dm_ret_hr_aut         empresa.dm_ret_hr_aut%type := 0;
   vn_empresa_id            empresa.id%type := null;
   vv_cpf_cnpj              varchar2(14) := null;
   vv_cod_part              pessoa.cod_part%type;
   vv_sistorig_sigla        sist_orig.sigla%type;
   vv_unidorg_cd            unid_org.cd%type;
   vv_link                  nf_compl_serv.link%type;
   vn_nro_aut_nfs           nf_compl_serv.nro_aut_nfs%type;
   vv_owner_obj             empresa_integr_banco.owner_obj%type;
   vv_nome_dblink           empresa_integr_banco.nome_dblink%type;
   vn_dm_util_aspa          empresa_integr_banco.dm_util_aspa%type;
   vn_dm_ret_infor_integr   empresa_integr_banco.dm_ret_infor_integr%type;
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
        , nf.dm_st_proc
        , nf.id                 notafiscal_id
        , nf.dt_emiss
        , nf.dm_st_integra
        , nf.sistorig_id
        , nf.unidorg_id
        , nf.empresaintegrbanco_id
        , ncs.cod_verif_nfs
        , nfc.id_erp  id_erp
        , nfca.id_erp id_erp_can
     from Nota_Fiscal           nf
        , mod_fiscal            mf
        , nf_compl_serv         ncs
        , nota_fiscal_compl     nfc
        , nota_fiscal_canc      nfca
    where nf.empresa_id         = en_empresa_id
      and nf.dm_st_proc         <> 0
      and nf.dm_ind_emit        = 0
      and nf.dm_st_integra      = 7
      and mf.id                 = nf.modfiscal_id
      and mf.cod_mod            IN ('99', 'ND')
      and ncs.notafiscal_id(+)  = nf.id
      and nfc.notafiscal_id(+)  = nf.id
      and nfca.notafiscal_id(+) = nf.id
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   -- Verifica se o objeto de integração está ATIVO
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NFS_ERP_NEO') = 0 then
      --
      return;
      --
   else
      -- Estando ATIVO veririca se o objeto antigo de integração tb está ativo e atualiza para DESATIVADO
      -- Manter somente uma view de resposta ativa
      if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NFS_ERP') = 1 then
         --
         vn_fase := 1.1;
         --
         update obj_util_integr
            set dm_ativo = 0
          where obj_name in ('VW_CSF_RESP_NFS_ERP', 'VW_CSF_RESP_NFS_ERP_FF');
         --
      end if;
      --
   end if;
   --
   vn_fase := 2;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => gn_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   for rec in c_nf(vn_empresa_id) loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      if nvl(rec.empresaintegrbanco_id,0) > 0
         and nvl(rec.empresaintegrbanco_id,0) <> nvl(gn_empresaintegrbanco_id,0)
         then
         --
         begin
            --
            select ei.owner_obj
                 , ei.nome_dblink
                 , ei.dm_util_aspa
                 , ei.dm_ret_infor_integr
              into vv_owner_obj
                 , vv_nome_dblink
                 , vn_dm_util_aspa
                 , vn_dm_ret_infor_integr
              from empresa_integr_banco ei
             where ei.id = rec.empresaintegrbanco_id;
            --
         exception
            when others then
               null;
         end;
         --
         if nvl(vn_dm_util_aspa,0) = 1 then
            --
            vv_aspas := '"';
            --
         end if;
         --
      else
         --
         vv_owner_obj           := GV_OWNER_OBJ;
         vv_nome_dblink         := GV_NOME_DBLINK;
         vv_aspas               := GV_ASPAS;
         vn_dm_ret_infor_integr := 1;
         --
      end if;
      --
      vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NFS_ERP_NEO'
                                     , ev_aspas       => vv_aspas
                                     , ev_owner_obj   => vv_owner_obj
                                     , ev_nome_dblink => vv_nome_dblink
                                     );
      --
      if nvl(vn_dm_ret_infor_integr,0) = 1 then
         --
         vn_fase := 3;
         --
         vn_empresa_id := rec.empresa_id;
         --
         vv_cpf_cnpj := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
         --
         vn_fase := 4;
         --
         vn_dm_ret_hr_aut := pk_csf.fkg_ret_hr_aut_empresa_id ( en_empresa_id => vn_empresa_id );
         --
         vn_fase := 4.1;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
         --
         vn_fase := 4.2;
         --
         vv_sistorig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec.sistorig_id );
         --
         vn_fase := 4.3;
         --
         vv_unidorg_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec.unidorg_id );
         --
         vn_fase := 4.4;
         --
         begin
            --
            select cs.link
                 , cs.nro_aut_nfs
              into vv_link
                 , vn_nro_aut_nfs
              from nf_compl_serv cs
             where cs.notafiscal_id = rec.notafiscal_id;
            --
         exception
            when others then
               vv_link := null;
               vn_nro_aut_nfs := null;
         end;
         --
         vn_fase := 4.5;
         --
         vn_fase := 5;
         --
         pkb_excluir_nfs ( ev_cpf_cnpj_emit   => vv_cpf_cnpj
                         , en_dm_ind_emit     => rec.dm_ind_emit
                         , ev_cod_part        => vv_cod_part
                         , ev_serie           => rec.serie
                         , en_nro_nf          => rec.nro_nf
                         , en_notafiscal_id   => rec.notafiscal_id
                         , ev_obj             => vv_obj
                         , ev_aspas           => vv_aspas
                         );
         --
         vn_fase := 5.1;
         --| verificar se existe
         vn_dm_st_proc_erp := fkg_ret_dm_st_proc_erp ( en_notafiscal_id   => rec.notafiscal_id
                                                     , ev_obj             => vv_obj
                                                     , ev_aspas           => vv_aspas
                                                     , ev_obj_name        => 'VW_CSF_RESP_NFS_ERP_NEO'
                                                     );
         -- se não encontrou informa o registro
         if nvl(vn_dm_st_proc_erp,-1) = -1
            and nvl(rec.nro_nf,0) > 0
            then
            --
            vn_fase := 6;
            --
            vn_notafiscal_id := rec.notafiscal_id;
            --
            gv_sql := 'insert into ';
            --
            vn_fase := 9;
            --
            gv_sql := gv_sql || vv_obj || '(';
            --
            gv_sql := gv_sql ||         vv_aspas       || 'CPF_CNPJ_EMIT' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'DM_IND_OPER'   || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'DM_IND_EMIT'   || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'COD_PART'      || vv_aspas;
            gv_sql := gv_sql || ', ' || trim(vv_aspas) || 'SERIE'         || trim(vv_aspas);
            gv_sql := gv_sql || ', ' || vv_aspas       || 'NRO_NF'        || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'DM_ST_PROC'    || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'LINK'          || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'NRO_AUT_NFS'   || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'NOTAFISCAL_ID' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'DM_LEITURA'    || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'SIST_ORIG'     || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'UNID_ORG'      || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'COD_VERIF_NFS' || vv_aspas;
            gv_sql := gv_sql || ', ' || vv_aspas       || 'ID_ERP'        || vv_aspas;
            --
            vn_fase := 10;
            --
            gv_sql := gv_sql || ') values (';
            --
            gv_sql := gv_sql || '''' || ev_cpf_cnpj_emit || '''';
            gv_sql := gv_sql || ', ' || rec.DM_IND_OPER;
            gv_sql := gv_sql || ', ' || rec.DM_IND_EMIT;
            --
            vn_fase := 10.1;
            --
            --if rec.dm_ind_emit = 1 then
               gv_sql := gv_sql || ', ' || case when trim(vv_cod_part) is not null then '''' || trim(vv_cod_part) || '''' else '''' || ' ' || '''' end;
            --else
            --   gv_sql := gv_sql || ', ' || '''' || ' ' || '''';
            --end if;
            --
            gv_sql := gv_sql || ', ' || '''' || trim(rec.SERIE) || '''';
            gv_sql := gv_sql || ', ' || rec.NRO_NF;
            --
            vn_fase := 10.2;
            gv_sql := gv_sql || ', ' || case when rec.DM_ST_PROC = 0 then 1 else rec.DM_ST_PROC end;
            --
            vn_fase := 10.3;
            gv_sql := gv_sql || ', ' || case when trim(vv_link) is not null then '''' || trim(vv_link) || '''' else '''' || ' ' || '''' end;
            --
            vn_fase := 10.4;
            gv_sql := gv_sql || ', ' || nvl(vn_nro_aut_nfs, 0);
            gv_sql := gv_sql || ', ' || rec.NOTAFISCAL_ID;
            gv_sql := gv_sql || ', 0'; -- DM_LEITURA
            --
            vn_fase := 10.5;
            gv_sql := gv_sql || ', ' ||  case when trim(vv_sistorig_sigla) is null then '''' || ' ' || '''' else '''' || trim(vv_sistorig_sigla) || '''' end;
            gv_sql := gv_sql || ', ' ||  case when trim(vv_unidorg_cd) is null then '''' || ' ' || '''' else '''' || trim(vv_unidorg_cd) || '''' end;
            --
            vn_fase := 10.6;
            --
            if rec.cod_verif_nfs is not null then
               gv_sql := gv_sql || ', ' || '''' || rec.cod_verif_nfs || '''';
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 10.7;
            --
            if nvl(rec.id_erp,rec.id_erp_can) > 0 then
               gv_sql := gv_sql || ', ' || nvl(rec.id_erp,rec.id_erp_can);
            else
               gv_sql := gv_sql || ', null';
            end if;
            --
            vn_fase := 10.8;
            --
            vn_fase := 11;
            --
            gv_sql := gv_sql || ')';
            --
            vn_fase := 12;
            --
            vn_erro := 0;
            --insert into erro values (gv_sql); commit;
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
                  rollback;
                  --
                  -- não registra erro caso a view não exista
                  --if sqlcode IN (-942, -1, -28500, -01010, -02063) then
                  --   null;
                  --else
                     --
                     pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_int_infor_erp_neo fase(' || vn_fase || '):' || sqlerrm || ' - ' || gv_sql;
                     --
                     declare
                        vn_loggenerico_id  log_generico_nf.id%TYPE;
                     begin
                        --
                        pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                           , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                                           , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                                           , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                           , en_referencia_id     => rec.NOTAFISCAL_ID
                                                           , ev_obj_referencia    => 'NOTA_FISCAL' );
                        --
                     exception
                        when others then
                           null;
                     end;
                     --
                  --end if;
            end;
            --
            commit;
            --
            vn_fase := 13;
            --
            if rec.DM_ST_PROC not in (0, 1, 2, 3, 4, 6, 7, 8, 20) then
               --
               begin
                  -- grava informações de erro para o erp
                  pkb_ret_infor_erro_nf_erp ( en_notafiscal_id => rec.notafiscal_id 
                                            , ev_obj           => 'VW_CSF_RESP_ERRO_NFS_ERP' );
                  --
               exception
                  when others then
                     vn_erro := 1;
               end;
               --
            end if;
            --
            if nvl(vn_erro,0) = 0 then
               --
               vn_fase := 14;
               --
               if rec.DM_ST_PROC not in (4, 6, 7, 8, 20)
                  then
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => 8 );
                  --
               else
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
            vn_fase := 15;
            --
            pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                      , en_dm_st_integra  => 8 );
            --
         end if;
         --
         vn_fase := 16;
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
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_int_infor_erp_neo fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                            , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                            , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                            , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id     => vn_notafiscal_id
                                            , ev_obj_referencia    => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_infor_erp_neo;
--
-- =============================================================================================================================== --
--
--| Procedimento retorna a informação para o ERP
procedure pkb_ret_infor_erp ( ev_cpf_cnpj_emit in varchar2 )
is
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
   vn_empresa_id            empresa.id%type := null;
   vv_cpf_cnpj              varchar2(14) := null;
   vv_cod_part              pessoa.cod_part%type;
   vv_sistorig_sigla        sist_orig.sigla%type;
   vv_unidorg_cd            unid_org.cd%type;
   vv_link                  nf_compl_serv.link%type;
   vn_nro_aut_nfs           nf_compl_serv.nro_aut_nfs%type;
   vv_owner_obj             empresa_integr_banco.owner_obj%type;
   vv_nome_dblink           empresa_integr_banco.nome_dblink%type;
   vn_dm_util_aspa          empresa_integr_banco.dm_util_aspa%type;
   vn_dm_ret_infor_integr   empresa_integr_banco.dm_ret_infor_integr%type;
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
        , nf.dm_st_proc
        , nf.id                 notafiscal_id
        , nf.dt_emiss
        , nf.dm_st_integra
        , nf.sistorig_id
        , nf.unidorg_id
        , nf.empresaintegrbanco_id
     from Nota_Fiscal           nf
        , mod_fiscal            mf
    where nf.empresa_id         = en_empresa_id
      and nf.dm_st_proc         > 3 -- Sempre maior que 3-Aguardando Retorno
      and nf.dm_ind_emit        = 0 -- emissão própria
      and nf.dm_st_integra      = 8 -- Aguardando retorno para o ERP
      and mf.id                 = nf.modfiscal_id
      and mf.cod_mod            IN ('99', 'ND')
    order by nf.id;
   --
begin
   -- Atualiza informações
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NFS_ERP') = 0 then
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
   for rec in c_nf(vn_empresa_id) loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      if nvl(rec.empresaintegrbanco_id,0) > 0
         and nvl(rec.empresaintegrbanco_id,0) <> nvl(gn_empresaintegrbanco_id,0)
         then
         --
         begin
            --
            select ei.owner_obj
                 , ei.nome_dblink
                 , ei.dm_util_aspa
                 , ei.dm_ret_infor_integr
              into vv_owner_obj
                 , vv_nome_dblink
                 , vn_dm_util_aspa
                 , vn_dm_ret_infor_integr
              from empresa_integr_banco ei
             where ei.id = rec.empresaintegrbanco_id;
            --
         exception
            when others then
               null;
         end;
         --
         if nvl(vn_dm_util_aspa,0) = 1 then
            --
            vv_aspas := '"';
            --
         end if;
         --
      else
         --
         vv_owner_obj           := GV_OWNER_OBJ;
         vv_nome_dblink         := GV_NOME_DBLINK;
         vv_aspas               := GV_ASPAS;
         vn_dm_ret_infor_integr := 1;
         --
      end if;
      --
      vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NFS_ERP'
                                     , ev_aspas       => vv_aspas
                                     , ev_owner_obj   => vv_owner_obj
                                     , ev_nome_dblink => vv_nome_dblink
                                     );
      --
      if nvl(vn_dm_ret_infor_integr,0) = 1 then
         --
         vn_fase := 3;
         --
         vn_dm_ret_hr_aut := pk_csf.fkg_ret_hr_aut_empresa_id ( en_empresa_id => vn_empresa_id );
         --
         vn_fase := 3.1;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
         --
         vn_fase := 3.2;
         --
         vv_sistorig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec.sistorig_id );
         --
         vn_fase := 3.3;
         --
         vv_unidorg_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec.unidorg_id );
         --
         vn_fase := 3.4;
         --
         begin
            --
            select cs.link
                 , cs.nro_aut_nfs
              into vv_link
                 , vn_nro_aut_nfs
              from nf_compl_serv cs
             where cs.notafiscal_id = rec.notafiscal_id;
            --
         exception
            when others then
               vv_link := null;
               vn_nro_aut_nfs := null;
         end;
         --
         vn_fase := 3.5;
         --
         vn_fase := 4;
         --
         vn_dm_st_proc_erp := fkg_ret_dm_st_proc_erp ( en_notafiscal_id   => rec.notafiscal_id
                                                     , ev_obj             => vv_obj
                                                     , ev_aspas           => vv_aspas
                                                     , ev_obj_name        => 'VW_CSF_RESP_NFS_ERP'
                                                     );
         --
         vn_fase := 5;
         -- Verifica se a situação da NFe no ERP é diferente de zero e diferetente da Situação da NFe no Compliance
         if nvl(vn_dm_st_proc_erp,0) not in (0, -1)
            and nvl(vn_dm_st_proc_erp,0) <> nvl(rec.dm_st_proc,0) then
            --
            vn_fase := 6;
            --
            --vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8) then 9 else 8 end;
            vn_dm_st_integra := 9;
            --
            vn_fase := 7;
            -- Inicia montagem do update de atualização da resposta do ERP
            gv_sql := 'update ';
            --
            vn_fase := 8;
            --
            gv_sql := gv_sql || vv_obj;
            gv_sql := gv_sql || ' set ' || vv_aspas || 'DM_ST_PROC' || vv_aspas || ' = ' || rec.dm_st_proc;
            gv_sql := gv_sql || ', ' || vv_aspas || 'LINK' || vv_aspas || ' = ' || case when trim(vv_link) is not null then '''' || trim(vv_link) || '''' else '''' || ' ' || '''' end;
            gv_sql := gv_sql || ', ' || vv_aspas || 'NRO_AUT_NFS' || vv_aspas || ' = ' || nvl(vn_nro_aut_nfs, 0);
            gv_sql := gv_sql || ', ' || vv_aspas || 'NOTAFISCAL_ID' || vv_aspas || ' = ' || rec.NOTAFISCAL_ID;
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
            vv_sql_where := ' where ' || vv_aspas || 'NOTAFISCAL_ID' || vv_aspas || ' = ' || rec.notafiscal_id;
            --
            gv_sql := gv_sql || vv_sql_where;
            --insert into erro values (gv_sql); commit;
            --
            vn_fase := 9;
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
            commit;
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
                     pk_csf_api_nfs.gv_mensagem_log := 'Erro na pkb_ret_infor_erp fase(' || vn_fase || ' ' || gv_sql || '):' || sqlerrm || ' - ' || gv_sql;
                     --
                     declare
                        vn_loggenerico_id  log_generico_nf.id%TYPE;
                     begin
                        --
                        pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                        , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                                        , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                                        , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                        , en_referencia_id   => rec.notafiscal_id
                                                        , ev_obj_referencia  => 'NOTA_FISCAL' );
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
               vn_fase := 10;
               --
               if nvl(vn_erro,0) = 0 then
                  --
                  pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  => rec.notafiscal_id
                                                 , en_dm_st_integra  => vn_dm_st_integra );
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => vn_dm_st_integra );
                  --
                  if rec.DM_ST_PROC not in (0, 1, 2, 3, 4, 6, 7, 8, 20) then
                     -- grava informações de log para o erp
                     pkb_ret_infor_erro_nf_erp ( en_notafiscal_id => rec.notafiscal_id 
                                               , ev_obj           => 'VW_CSF_RESP_ERRO_NFS_ERP' );
                     --
                  end if;
                  --
               end if;
               --
            else
               --
               pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                         , en_dm_st_integra  => 7
                                         );
               --
            end if;
            --
         else
            --
            vn_fase := 11;
            -- se a situação da NFe for 4-Autorizada, já alteração a integração para 9-Finalizado processo de View
            --
            if nvl(vn_dm_st_proc_erp,0) = nvl(rec.dm_st_proc,0) then
               vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8, 20) then 9 else 8 end;
            else
               vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8, 20) then 9 else 7 end;
            end if;
            --
            pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  => rec.notafiscal_id
                                           , en_dm_st_integra  => vn_dm_st_integra );
            --
            pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                      , en_dm_st_integra  => vn_dm_st_integra );
            --
         end if;
         --
         vn_fase := 12;
         --
         -- Procedimento integra retorno de informações no ERP para campos FF
         pkb_int_ret_infor_erp_ff ( ev_cpf_cnpj_emit  => ev_cpf_cnpj_emit
                                  , en_dm_ind_emit    => rec.dm_ind_emit
                                  , en_dm_ind_oper    => rec.dm_ind_oper
                                  , ev_cod_part       => vv_cod_part
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
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ret_infor_erp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => vn_notafiscal_id
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ret_infor_erp;
--
-- =============================================================================================================================== --
--
--| Procedimento retorna a informação para o ERP
procedure pkb_ret_infor_erp_neo ( ev_cpf_cnpj_emit in varchar2 )
is
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
   vn_empresa_id            empresa.id%type := null;
   vv_cpf_cnpj              varchar2(14) := null;
   vv_cod_part              pessoa.cod_part%type;
   vv_sistorig_sigla        sist_orig.sigla%type;
   vv_unidorg_cd            unid_org.cd%type;
   vv_link                  nf_compl_serv.link%type;
   vn_nro_aut_nfs           nf_compl_serv.nro_aut_nfs%type;
   vv_owner_obj             empresa_integr_banco.owner_obj%type;
   vv_nome_dblink           empresa_integr_banco.nome_dblink%type;
   vn_dm_util_aspa          empresa_integr_banco.dm_util_aspa%type;
   vn_dm_ret_infor_integr   empresa_integr_banco.dm_ret_infor_integr%type;
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
        , nf.dm_st_proc
        , nf.id                 notafiscal_id
        , nf.dt_emiss
        , nf.dm_st_integra
        , nf.sistorig_id
        , nf.unidorg_id
        , nf.empresaintegrbanco_id
        , ncs.cod_verif_nfs
        , nfc.id_erp  id_erp
        , nfca.id_erp id_erp_can
     from Nota_Fiscal           nf
        , mod_fiscal            mf
        , nf_compl_serv         ncs
        , nota_fiscal_compl     nfc
        , nota_fiscal_canc      nfca
    where nf.empresa_id         = en_empresa_id
      and nf.dm_st_proc         > 3 -- Sempre maior que 3-Aguardando Retorno
      and nf.dm_ind_emit        = 0 -- emissão própria
      and nf.dm_st_integra      = 8 -- Aguardando retorno para o ERP
      and mf.id                 = nf.modfiscal_id
      and mf.cod_mod            IN ('99', 'ND')
      and ncs.notafiscal_id(+)  = nf.id
      and nfc.notafiscal_id(+)  = nf.id
      and nfca.notafiscal_id(+) = nf.id
    order by nf.id;
   --
begin
   -- Atualiza informações
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NFS_ERP_NEO') = 0 then
      --
      return;
      --
   else
      -- Estando ATIVO veririca se o objeto antigo de integração tb está ativo e atualiza para DESATIVADO
      -- Manter somente uma view de resposta ativa
      if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_RESP_NFS_ERP') = 1 then
         --
         vn_fase := 1.1;
         --
         update obj_util_integr
            set dm_ativo = 0
          where obj_name in ('VW_CSF_RESP_NFS_ERP', 'VW_CSF_RESP_NFS_ERP_FF');
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
   for rec in c_nf(vn_empresa_id) loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      if nvl(rec.empresaintegrbanco_id,0) > 0
         and nvl(rec.empresaintegrbanco_id,0) <> nvl(gn_empresaintegrbanco_id,0)
         then
         --
         begin
            --
            select ei.owner_obj
                 , ei.nome_dblink
                 , ei.dm_util_aspa
                 , ei.dm_ret_infor_integr
              into vv_owner_obj
                 , vv_nome_dblink
                 , vn_dm_util_aspa
                 , vn_dm_ret_infor_integr
              from empresa_integr_banco ei
             where ei.id = rec.empresaintegrbanco_id;
            --
         exception
            when others then
               null;
         end;
         --
         if nvl(vn_dm_util_aspa,0) = 1 then
            --
            vv_aspas := '"';
            --
         end if;
         --
      else
         --
         vv_owner_obj           := GV_OWNER_OBJ;
         vv_nome_dblink         := GV_NOME_DBLINK;
         vv_aspas               := GV_ASPAS;
         vn_dm_ret_infor_integr := 1;
         --
      end if;
      --
      vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_RESP_NFS_ERP_NEO'
                                     , ev_aspas       => vv_aspas
                                     , ev_owner_obj   => vv_owner_obj
                                     , ev_nome_dblink => vv_nome_dblink
                                     );
      --
      if nvl(vn_dm_ret_infor_integr,0) = 1 then
         --
         vn_fase := 3;
         --
         vn_dm_ret_hr_aut := pk_csf.fkg_ret_hr_aut_empresa_id ( en_empresa_id => vn_empresa_id );
         --
         vn_fase := 3.1;
         --
         vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
         --
         vn_fase := 3.2;
         --
         vv_sistorig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec.sistorig_id );
         --
         vn_fase := 3.3;
         --
         vv_unidorg_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec.unidorg_id );
         --
         vn_fase := 3.4;
         --
         begin
            --
            select cs.link
                 , cs.nro_aut_nfs
              into vv_link
                 , vn_nro_aut_nfs
              from nf_compl_serv cs
             where cs.notafiscal_id = rec.notafiscal_id;
            --
         exception
            when others then
               vv_link := null;
               vn_nro_aut_nfs := null;
         end;
         --
         vn_fase := 3.5;
         --
         vn_fase := 4;
         --
         vn_dm_st_proc_erp := fkg_ret_dm_st_proc_erp ( en_notafiscal_id   => rec.notafiscal_id
                                                     , ev_obj             => vv_obj
                                                     , ev_aspas           => vv_aspas
                                                     , ev_obj_name        => 'VW_CSF_RESP_NFS_ERP_NEO'
                                                     );
         --
         vn_fase := 5;
         -- Verifica se a situação da NFe no ERP é diferente de zero e diferetente da Situação da NFe no Compliance
         if nvl(vn_dm_st_proc_erp,0) not in (0, -1)
            and nvl(vn_dm_st_proc_erp,0) <> nvl(rec.dm_st_proc,0) then
            --
            vn_fase := 6;
            --
            --vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8) then 9 else 8 end;
            vn_dm_st_integra := 9;
            --
            vn_fase := 7;
            -- Inicia montagem do update de atualização da resposta do ERP
            gv_sql := 'update ';
            --
            vn_fase := 8;
            --
            gv_sql := gv_sql || vv_obj;
            gv_sql := gv_sql || ' set ' || vv_aspas || 'DM_ST_PROC'    || vv_aspas || ' = ' || rec.dm_st_proc;
            gv_sql := gv_sql || ', '    || vv_aspas || 'LINK'          || vv_aspas || ' = ' || case when trim(vv_link) is not null then '''' || trim(vv_link) || '''' else '''' || ' ' || '''' end;
            gv_sql := gv_sql || ', '    || vv_aspas || 'NRO_AUT_NFS'   || vv_aspas || ' = ' || nvl(vn_nro_aut_nfs, 0);
            gv_sql := gv_sql || ', '    || vv_aspas || 'NOTAFISCAL_ID' || vv_aspas || ' = ' || rec.NOTAFISCAL_ID;
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
            if rec.cod_verif_nfs is not null then
               --
               gv_sql := gv_sql || ', ' || vv_aspas || 'COD_VERIF_NFS' || vv_aspas || ' = ' || '''' || trim(rec.cod_verif_nfs) || '''';
               --
            end if;
            --
            if trim(nvl(rec.id_erp,rec.id_erp_can)) > 0 then
               --
               gv_sql := gv_sql || ', ' || vv_aspas || 'ID_ERP' || vv_aspas || ' = ' || '''' || trim(nvl(rec.id_erp,rec.id_erp_can)) || '''';
               --
            end if;
            --
            vv_sql_where := ' where ' || vv_aspas || 'NOTAFISCAL_ID' || vv_aspas || ' = ' || rec.notafiscal_id;
            --
            gv_sql := gv_sql || vv_sql_where;
            --insert into erro values (gv_sql); commit;
            --
            vn_fase := 9;
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
            commit;
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
                     pk_csf_api_nfs.gv_mensagem_log := 'Erro na pkb_ret_infor_erp_neo ( Fase' || vn_fase || ': ' || gv_sql || '):' || sqlerrm || ' - ' || gv_sql;
                     --
                     declare
                        vn_loggenerico_id  log_generico_nf.id%TYPE;
                     begin
                        --
                        pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                        , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                                        , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                                        , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                        , en_referencia_id   => rec.notafiscal_id
                                                        , ev_obj_referencia  => 'NOTA_FISCAL' );
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
               vn_fase := 10;
               --
               if nvl(vn_erro,0) = 0 then
                  --
                  pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  => rec.notafiscal_id
                                                 , en_dm_st_integra  => vn_dm_st_integra );
                  --
                  pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                            , en_dm_st_integra  => vn_dm_st_integra );
                  --
                  if rec.DM_ST_PROC not in (0, 1, 2, 3, 4, 6, 7, 8, 20) then
                     -- grava informações de log para o erp
                     pkb_ret_infor_erro_nf_erp ( en_notafiscal_id => rec.notafiscal_id
                                               , ev_obj           => 'VW_CSF_RESP_ERRO_NFS_ERP' );
                     --
                  end if;
                  --
               end if;
               --
            else
               --
               pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                         , en_dm_st_integra  => 7
                                         );
               --
            end if;
            --
         else
            --
            vn_fase := 11;
            -- se a situação da NFe for 4-Autorizada, já alteração a integração para 9-Finalizado processo de View
            --
            if nvl(vn_dm_st_proc_erp,0) = nvl(rec.dm_st_proc,0) then
               vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8, 20) then 9 else 8 end;
            else
               vn_dm_st_integra := case when rec.dm_st_proc in (4, 6, 7, 8, 20) then 9 else 7 end;
            end if;
            --
            pkb_alter_sit_integra_nfe_canc ( en_notafiscal_id  => rec.notafiscal_id
                                           , en_dm_st_integra  => vn_dm_st_integra );
            --
            pkb_alter_sit_integra_nfe ( en_notafiscal_id  => rec.notafiscal_id
                                      , en_dm_st_integra  => vn_dm_st_integra );
            --
         end if;
         --
         vn_fase := 12;
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
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ret_infor_erp_neo (Fase: ' || vn_fase || ') ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                            , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                            , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                            , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                            , en_referencia_id     => vn_notafiscal_id
                                            , ev_obj_referencia    => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ret_infor_erp_neo;
-- 
-- =============================================================================================================================== --
--
--| Procedimento Gera o Retorno para o ERP
procedure pkb_gera_retorno ( ev_sist_orig in varchar2 default null )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
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
      and eib.dm_ret_infor_integr = 1 -- retorna a informação para o ERP
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
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   GV_SIST_ORIG := trim(ev_sist_orig);
   --
   vn_fase := 1.1;
   --
   pk_csf_api_nfs.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 2;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      gn_multorg_id    := rec.multorg_id;
      gn_empresa_id    := rec.empresa_id;
      -- Seta o DBLink
      gn_empresaintegrbanco_id  := rec.empresaintegrbanco_id;
      gv_nome_dblink            := rec.nome_dblink;
      gv_owner_obj              := rec.owner_obj;
      --
      vn_fase := 3;
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
      vn_fase := 3.1;
      --
      if trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := trim(rec.formato_dt_erp);
      else
         gd_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 4;
      --   
      -- Integra a informação para o ERP - VW_CSF_RESP_NFS_ERP
      pkb_int_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 4.1;
      -- retorna a informação para o ERP - VW_CSF_RESP_NFS_ERP
      pkb_ret_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 4.2;
      -- Integra a informação para o ERP - VW_CSF_RESP_NFS_ERP_NEO
      pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 4.3;
      -- retorna a informação para o ERP - VW_CSF_RESP_NFS_ERP_NEO
      pkb_ret_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
   end loop;
   --
   vn_fase := 5;
   -- Finaliza o log genérico para a integração das Notas Fiscais de Serviços no CSF
   pk_csf_api_nfs.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 6;
   --
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_gera_retorno fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_gera_retorno;

-------------------------------------------------------------------------------------------------------
-- procedimento seta "where" para pesquisa de Nfs de emissão própria
procedure pkb_seta_where_emissao_propria
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gv_where := null;
   gv_where := ' and ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = 0';
   gv_where := gv_where || ' and ' || trim(GV_ASPAS) || 'DM_ST_PROC' || trim(GV_ASPAS) || ' IN (0)';
   --
   vn_fase := 2;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_seta_where_emissao_propria fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_cabec_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => null
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_seta_where_emissao_propria;

-------------------------------------------------------------------------------------------------------

procedure pkb_ler_Nota_Fiscal_Canc_ff( est_log_generico   in  out nocopy  dbms_sql.number_table
                                     , ev_cpf_cnpj_emit   in  varchar2
                                     , en_dm_ind_emit     in  number
                                     , en_dm_ind_oper     in  number
                                     , ev_cod_part        in  varchar2
                                     , ev_serie           in  varchar2
                                     , en_nro_nf          in  number
                                     , sn_multorg_id      out mult_org.id%type )
is
   vn_fase               number := 0;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   vv_cod                mult_org.cd%type;
   vv_hash               mult_org.hash%type;
   vv_cod_ret            mult_org.cd%type;
   vv_hash_ret           mult_org.hash%type;
   vn_multorg_id         mult_org.id%type := 0;
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_CANC_SERV_FF') = 0 then
      --
      sn_multorg_id := vn_multorg_id;
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nf_canc_serv_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR'         || trim(GV_ASPAS);
   --
   vn_fase := 1.1;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_CANC_SERV_FF' );
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
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   --
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
   gv_sql := gv_sql || ', trim('|| trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ', '|| trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_CANC_SERV_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nf_canc_serv_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_Nota_Fiscal_Canc_ff fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                          , ev_resumo            => 'Nota fiscal de serviço: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                          , en_referencia_id     => null
                                          , ev_obj_referencia    => 'NOTA_FISCAL' );
           --
           raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nf_canc_serv_ff.count > 0 then
      --
      for i in vt_tab_csf_nf_canc_serv_ff.first..vt_tab_csf_nf_canc_serv_ff.last loop
         --
         vn_fase := 7;
         --
         if vt_tab_csf_nf_canc_serv_ff(i).atributo in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            vn_fase := 8;
            -- Chama procedimento que faz a validação dos itens da Inventario - campos flex field.
            vv_cod_ret := null;
            vv_hash_ret := null;

            pk_csf_api_nfs.pkb_val_atrib_multorg ( est_log_generico     => est_log_generico
                                                 , ev_obj_name          => 'VW_CSF_NF_CANC_SERV_FF'
                                                 , ev_atributo          => vt_tab_csf_nf_canc_serv_ff(i).atributo
                                                 , ev_valor             => vt_tab_csf_nf_canc_serv_ff(i).valor
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
         pk_csf_api_nfs.pkb_ret_multorg_id( est_log_generico   => est_log_generico
                                          , ev_cod_mult_org    => vv_cod
                                          , ev_hash_mult_org   => vv_hash
                                          , sn_multorg_id      => vn_multorg_id
                                          , en_referencia_id     => null
                                          , ev_obj_referencia    => 'NOTA_FISCAL'
                                          );
      end if;
      --
      vn_fase := 12;
      --
      sn_multorg_id := vn_multorg_id;
      --
   else
      --
      pk_csf_api.gv_mensagem_log := 'Nota fiscal cadastrada com Mult Org default (codigo = 1), pois não foram passados o codigo e a hash do multorg.';
      --
      vn_loggenericonf_id := null;
      --
      vn_fase := 10;
      --
      pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem           => pk_csf_api.gv_mensagem_log
                                          , ev_resumo             => 'Nota fiscal de serviço: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log           => pk_csf_api_nfs.INFORMACAO
                                          , en_referencia_id      => null
                                          , ev_obj_referencia     => 'NOTA_FISCAL'
                                          );
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_Nota_Fiscal_Canc_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                        , ev_mensagem           => pk_csf_api_nfs.gv_mensagem_log
                                        , ev_resumo             => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                        , en_tipo_log           => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                        , en_referencia_id      => null
                                        , ev_obj_referencia     => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal_Canc_ff;

-------------------------------------------------------------------------------------------------------

procedure pkb_ler_nf_Canc_ff_cod_mod ( est_log_generico   in  out nocopy  dbms_sql.number_table
                                     , ev_cpf_cnpj_emit   in  varchar2
                                     , en_dm_ind_emit     in  number
                                     , en_dm_ind_oper     in  number
                                     , ev_cod_part        in  varchar2
                                     , ev_serie           in  varchar2
                                     , en_nro_nf          in  number
                                     , sv_cod_mod         out mod_fiscal.cod_mod%type 
                                     )
is
   vn_fase               number := 0;
   vn_loggenericonf_id   log_generico_nf.id%TYPE;
   vv_cod_mod            mod_fiscal.cod_mod%type := '99';
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_CANC_SERV_FF') = 0 then
      --
      sv_cod_mod := vv_cod_mod;
      --
      return;
      --
   end if;
   --
   gv_sql := null;
   --
   vt_tab_csf_nf_canc_serv_ff.delete;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR'         || trim(GV_ASPAS);
   --
   vn_fase := 1.1;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_CANC_SERV_FF' );
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
   gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'NRO_NF'   || GV_ASPAS || ' = ' || en_nro_nf;
   gv_sql := gv_sql || ' and ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS || ' = ' || '''' || 'COD_MOD' || '''';
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_CANC_SERV_FF' || chr(10);
   -- recupera as Notas Fiscais não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nf_canc_serv_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_Canc_ff_cod_mod fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                          , ev_resumo            => 'Nota fiscal de serviço: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                          , en_referencia_id     => null
                                          , ev_obj_referencia    => 'NOTA_FISCAL' );
           --
           raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 6;
   --
   if vt_tab_csf_nf_canc_serv_ff.count > 0 then
      --
      for i in vt_tab_csf_nf_canc_serv_ff.first..vt_tab_csf_nf_canc_serv_ff.last loop
         --
         vn_fase := 7;
         --
         if vt_tab_csf_nf_canc_serv_ff(i).atributo in ('COD_MOD') then
            --
            vn_fase := 8;
            --
            vv_cod_mod := vt_tab_csf_nf_canc_serv_ff(i).valor;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 10;
      --
      sv_cod_mod := vv_cod_mod;
      --
   else
      --
      sv_cod_mod := vv_cod_mod;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_nf_Canc_ff_cod_mod fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                        , ev_mensagem           => pk_csf_api_nfs.gv_mensagem_log
                                        , ev_resumo             => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                        , en_tipo_log           => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                        , en_referencia_id      => null
                                        , ev_obj_referencia     => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_Canc_ff_cod_mod;
----------------------------------------------------------------------------------------------

--Ler view para trabalhar com o atributo ID_ERP
procedure pkb_ler_nf_canc_serv_ff ( est_log_generico_nf  in  out nocopy dbms_sql.number_table
                                  , en_notafiscalcanc_id in  number
                                  , ev_cpf_cnpj_emit     in  varchar2
                                  , en_dm_ind_emit       in  number
                                  , en_dm_ind_oper       in  number
                                  , ev_cod_part          in  varchar2
                                  , ev_serie             in  varchar2
                                  , en_nro_nf            in  number
                                  )
is
   --
   vn_fase             number;
   vn_loggenericonf_id log_generico_nf.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_CANC_SERV_FF') = 0 then
      --
      --sn_multorg_id := vn_multorg_id;
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   gv_sql := null;
   vt_tab_csf_nf_canc_serv_ff.delete;
   --
   vn_fase := 3;
   --
   gv_sql := 'select';
   gv_sql := gv_sql ||' ' ||trim(gv_aspas)||'cpf_cnpj_emit' ||trim(gv_aspas);
   gv_sql := gv_sql ||', '||trim(gv_aspas)||'dm_ind_emit'   ||trim(gv_aspas);
   gv_sql := gv_sql ||', '||trim(gv_aspas)||'dm_ind_oper'   ||trim(gv_aspas);
   gv_sql := gv_sql ||', '||trim(gv_aspas)||'cod_part'      ||trim(gv_aspas);
   gv_sql := gv_sql || ', trim(' || trim(gv_aspas) || 'serie' || trim(gv_aspas) || ') ';
   gv_sql := gv_sql ||', '||trim(gv_aspas)||'nro_nf'        ||trim(gv_aspas);
   gv_sql := gv_sql ||', '||trim(gv_aspas)||'atributo'      ||trim(gv_aspas);
   gv_sql := gv_sql ||', '||trim(gv_aspas)||'valor'         ||trim(gv_aspas);
   --
   vn_fase := 4;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_CANC_SERV_FF' );
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            gv_aspas || 'cpf_cnpj_emit' || gv_aspas || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   gv_sql := gv_sql || ' and ' || gv_aspas || 'dm_ind_emit'   || gv_aspas || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || gv_aspas || 'dm_ind_oper'   || gv_aspas || ' = ' || en_dm_ind_oper;
   --
   vn_fase := 5;
   --
   if en_dm_ind_emit = 1 and ev_cod_part is not null then
      --
      gv_sql := gv_sql || ' and ' || gv_aspas || 'cod_part' || gv_aspas || ' = ' || '''' || ev_cod_part || '''';
      --
   end if;
   --
   vn_fase := 6;
   --
   gv_sql := gv_sql || ' and trim(' || trim(gv_aspas) || 'serie' || trim(gv_aspas) || ') ' || ' = ' || '''' || ev_serie || '''';
   gv_sql := gv_sql || ' and ' || gv_aspas || 'nro_nf' || gv_aspas || ' = ' || en_nro_nf;
   --
   vn_fase := 7;
   --
   gv_sql := gv_sql || ' order by ' || trim(gv_aspas) || 'cpf_cnpj_emit' || trim(gv_aspas);
   --
   gv_sql := gv_sql || ', '|| trim(gv_aspas) || 'dm_ind_emit' || trim(gv_aspas);
   --
   gv_sql := gv_sql || ', '|| trim(gv_aspas) || 'dm_ind_oper' || trim(gv_aspas);
   --
   gv_sql := gv_sql || ', '|| trim(gv_aspas) || 'cod_part' || trim(gv_aspas);
   --
   gv_sql := gv_sql || ', trim('|| trim(gv_aspas) || 'serie' || trim(gv_aspas) || ')';
   --
   gv_sql := gv_sql || ', '|| trim(gv_aspas) || 'nro_nf' || trim(gv_aspas);
   --
   gv_sql := gv_sql || ', '|| trim(gv_aspas) || 'atributo' || trim(gv_aspas);
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_CANC_SERV_FF' || chr(10);
   --
   vn_fase := 8;
   --
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nf_canc_serv_ff;
     --
   exception
      when others then
        -- não registra erro caso a view não exista
        if sqlcode = -942 then
           null;
        else
           --
           pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_Nota_Fiscal_Canc_ff fase('||vn_fase||'):'||sqlerrm;
           --
           pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                          , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                          , ev_resumo            => 'Nota fiscal de serviço: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                          , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                          , en_referencia_id     => null
                                          , ev_obj_referencia    => 'NOTA_FISCAL' );
           --
           raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
           --
        end if;
   end;
   --
   vn_fase := 9;
   --
   if vt_tab_csf_nf_canc_serv_ff.count > 0 then
      --
      for i in vt_tab_csf_nf_canc_serv_ff.first..vt_tab_csf_nf_canc_serv_ff.last loop
         --
         if vt_tab_csf_nf_canc_serv_ff(i).atributo not in ('COD_MULT_ORG', 'HASH_MULT_ORG') then
            --
            --Validação do campo ID_ERP na API
            pk_csf_api_nfs.pkb_val_integr_nf_canc_ff ( est_log_generico_nf  => est_log_generico_nf
                                                     , en_notafiscalcanc_id => en_notafiscalcanc_id
                                                     , ev_atributo          => vt_tab_csf_nf_canc_serv_ff(i).atributo
                                                     , ev_valor             => vt_tab_csf_nf_canc_serv_ff(i).valor
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
      pk_csf_api.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_Nota_Fiscal_Canc_ff fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenericonf_id  log_generico_nf.id%TYPE;
      begin
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                                        , ev_mensagem           => pk_csf_api_nfs.gv_mensagem_log
                                        , ev_resumo             => 'Nota fiscal: numero - ' || en_nro_nf ||'cnpj/cpf - '||ev_cpf_cnpj_emit
                                        , en_tipo_log           => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                        , en_referencia_id      => null
                                        , ev_obj_referencia     => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_canc_serv_ff;
--
-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de notas fiscais canceladas

procedure pkb_ler_Nota_Fiscal_Canc ( ev_cpf_cnpj_emit in varchar2
                                   , en_dm_ind_emit   in number
                                   )
is
   --
   vn_fase          number := 0;
   vt_log_generico  dbms_sql.number_table;
   vn_notafiscal_id Nota_Fiscal.id%TYPE;
   vn_empresa_id    Empresa.id%TYPE;
   i                pls_integer;
   vn_multorg_id    mult_org.id%type;
   vv_cod_mod       mod_fiscal.cod_mod%type;
   --
   procedure pkb_excluir_canc ( ev_cpf_cnpj_emit          in             varchar2
                              , en_dm_ind_emit            in             number
                              , en_dm_ind_oper            in             number
                              , ev_cod_part               in             varchar2
                              , ev_serie                  in             varchar2
                              , en_nro_nf                 in             number
                              , en_notafiscal_id          in             number
                              )
   is
      --
   begin
      --
      -- Delete da view pai de cancelamento de nota fiscal cancelada
      --
      vn_fase := 1;
      --
      gv_sql := 'delete ' || fkg_monta_from ( ev_obj => 'VW_CSF_NF_CANC_SERV');
      --
      vn_fase := 2;
      --
      gv_sql := gv_sql || ' where ' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
      gv_sql := gv_sql || ' and '   || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
      gv_sql := gv_sql || ' and '   || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
      --
      if en_dm_ind_emit = 1 and trim(ev_cod_part) is not null then
         --
         gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
         --
      end if;
      --
      gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
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
         --
      end;
      --
      commit;
      --
      -- Delete da view pai de cancelamento de nota fiscal cancelada - campos flex field
      --
      vn_fase := 4;
      --
      gv_sql := 'delete ' || fkg_monta_from ( ev_obj => 'VW_CSF_NF_CANC_SERV_FF');
      --
      vn_fase := 5;
      --
      gv_sql := gv_sql || ' where ' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
      gv_sql := gv_sql || ' and '   || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_oper;
      gv_sql := gv_sql || ' and '   || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS) || ' = ' || en_dm_ind_emit;
      --
      if en_dm_ind_emit = 1 and trim(ev_cod_part) is not null then
         --
         gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || ev_cod_part || '''';
         --
      end if;
      --
      gv_sql := gv_sql || ' and trim(' || trim(GV_ASPAS) || 'SERIE'  || trim(GV_ASPAS) || ') ' || ' = ' || '''' || ev_serie || '''';
      gv_sql := gv_sql || ' and '      || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS) || ' = ' || en_nro_nf;
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
         --
      end;
      --
      commit;
      --
   exception
      when others then
         --
         pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_Nota_Fiscal_Canc.pkb_excluir_canc fase(' || vn_fase || '): ' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_nf.id%TYPE;
         begin
            --
            pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem          => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                               , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id     => en_notafiscal_id
                                               , ev_obj_referencia    => 'NOTA_FISCAL' );
            --
         exception
            when others then
               null;
         end;
         --
   end pkb_excluir_canc;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_CANC_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vt_tab_csf_nf_canc_serv.delete;
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || 'a.'   || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', a.' || trim(GV_ASPAS) || 'DM_IND_EMIT'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', a.' || trim(GV_ASPAS) || 'DM_IND_OPER'   || trim(GV_ASPAS);
   gv_sql := gv_sql || ', a.' || trim(GV_ASPAS) || 'COD_PART'      || trim(GV_ASPAS);
   gv_sql := gv_sql || ', trim(a.' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS) || ') ';
   gv_sql := gv_sql || ', a.' || trim(GV_ASPAS) || 'NRO_NF'        || trim(GV_ASPAS);
   gv_sql := gv_sql || ', a.' || trim(GV_ASPAS) || 'DT_CANC'       || trim(GV_ASPAS);
   gv_sql := gv_sql || ', a.' || trim(GV_ASPAS) || 'JUSTIF'        || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_CANC_SERV') || ' a';
   --
   vn_fase := 2;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql || 'a.' || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS) || ' = ' || '''' || ev_cpf_cnpj_emit || '''';
   -- Comentado pois passou a ter NFSe de Terceiro que recebe cancelamento por WebService
   --gv_sql := gv_sql || ' and a.' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS) || ' = 0';
   --
   vn_fase := 3;
   -- recupera as Notas Fiscais não integradas
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nf_canc_serv;
      --
   exception
      when others then
         -- não registra erro caso a view não exista
         if sqlcode = -942 then
            null;
         else
            --
            pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_Nota_Fiscal_Canc fase(' || vn_fase || '):' || sqlerrm;
            --
         declare
            vn_loggenerico_id  log_generico_nf.id%TYPE;
            begin
               --
               pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                               , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                               , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                               , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                               , en_referencia_id   => null
                                               , ev_obj_referencia  => 'NOTA_FISCAL' );
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
   if vt_tab_csf_nf_canc_serv.count > 0 then
      --
      for i in vt_tab_csf_nf_canc_serv.first..vt_tab_csf_nf_canc_serv.last loop
         --
         vn_fase := 5;
         --
         vt_log_generico.delete;
         --
         vn_fase := 6;
         --
         vn_multorg_id := gn_multorg_id;
         --
         pkb_ler_Nota_Fiscal_Canc_ff( est_log_generico  =>  vt_log_generico
                                    , ev_cpf_cnpj_emit  =>  vt_tab_csf_nf_canc_serv(i).cpf_cnpj_emit
                                    , en_dm_ind_emit    =>  vt_tab_csf_nf_canc_serv(i).dm_ind_emit
                                    , en_dm_ind_oper    =>  vt_tab_csf_nf_canc_serv(i).dm_ind_oper
                                    , ev_cod_part       =>  vt_tab_csf_nf_canc_serv(i).cod_part
                                    , ev_serie          =>  vt_tab_csf_nf_canc_serv(i).serie
                                    , en_nro_nf         =>  vt_tab_csf_nf_canc_serv(i).nro_nf
                                    , sn_multorg_id     =>  vn_multorg_id );
         --
         vn_fase := 6.01;
         --
         pkb_ler_nf_Canc_ff_cod_mod ( est_log_generico  =>  vt_log_generico
                                    , ev_cpf_cnpj_emit  =>  vt_tab_csf_nf_canc_serv(i).cpf_cnpj_emit
                                    , en_dm_ind_emit    =>  vt_tab_csf_nf_canc_serv(i).dm_ind_emit
                                    , en_dm_ind_oper    =>  vt_tab_csf_nf_canc_serv(i).dm_ind_oper
                                    , ev_cod_part       =>  vt_tab_csf_nf_canc_serv(i).cod_part
                                    , ev_serie          =>  vt_tab_csf_nf_canc_serv(i).serie
                                    , en_nro_nf         =>  vt_tab_csf_nf_canc_serv(i).nro_nf
                                    , sv_cod_mod        =>  vv_cod_mod
                                    );
         --
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
            pk_csf_api.gv_mensagem_log := 'Mult-org informado pelo usuario('||vn_multorg_id||') não corresponde ao Mult-org da empresa('||gn_multorg_id||').';
            --
            vn_fase := 6.2;
            --
            declare
               vn_loggenericonf_id  log_generico_nf.id%TYPE;
            begin
               pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id   => vn_loggenericonf_id
                                              , ev_mensagem           => pk_csf_api.gv_mensagem_log
                                              , ev_resumo             => 'Mult-Org incorreto ou não informado.'
                                              , en_tipo_log           => pk_csf_api.INFORMACAO
                                              , en_referencia_id      => null
                                              , ev_obj_referencia     => 'NOTA_FISCAL'
                                              );
            exception
               when others then
                  null;
            end;
            --
         end if;

         vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => vn_multorg_id
                                                              , ev_cpf_cnpj   => vt_tab_csf_nf_canc_serv(i).CPF_CNPJ_EMIT );
         --
         vn_fase := 7;
         -- Recupera o ID da nota fiscal
         vn_notafiscal_id := pk_csf.fkg_busca_notafiscal_id ( en_multorg_id   => vn_multorg_id
                                                            , en_empresa_id   => vn_empresa_id
                                                            , ev_cod_mod      => vv_cod_mod
                                                            , ev_serie        => vt_tab_csf_nf_canc_serv(i).SERIE
                                                            , en_nro_nf       => vt_tab_csf_nf_canc_serv(i).NRO_NF
                                                            , en_dm_ind_oper  => vt_tab_csf_nf_canc_serv(i).DM_IND_OPER
                                                            , en_dm_ind_emit  => vt_tab_csf_nf_canc_serv(i).DM_IND_EMIT
                                                            , ev_cod_part     => vt_tab_csf_nf_canc_serv(i).COD_PART
                                                            );
         --
         vn_fase := 8;
         --
         pk_csf_api_nfs.pkb_seta_referencia_id ( en_id => vn_notafiscal_id );
         --
         pk_csf_api_nfs.gt_row_Nota_Fiscal_Canc := null;
         --
         pk_csf_api_nfs.gt_row_Nota_Fiscal_Canc.notafiscal_id  := vn_notafiscal_id;
         pk_csf_api_nfs.gt_row_Nota_Fiscal_Canc.dt_canc        := vt_tab_csf_nf_canc_serv(i).dt_canc;
         pk_csf_api_nfs.gt_row_Nota_Fiscal_Canc.justif         := trim(vt_tab_csf_nf_canc_serv(i).justif);
         pk_csf_api_nfs.gt_row_Nota_Fiscal_Canc.dm_st_integra  := 7; -- Integração por view de banco
         --
         vn_fase := 9;
         -- Chama o procedimento de integração da Nota Fiscal Cancelada
         pk_csf_api_nfs.pkb_integr_Nota_Fiscal_Canc ( est_log_generico_nf          => vt_log_generico
                                                    , est_row_Nota_Fiscal_Canc  => pk_csf_api_nfs.gt_row_Nota_Fiscal_Canc
                                                    , en_multorg_id             => vn_multorg_id );
         --
         commit;
         --
         vn_fase := 10;
         --
         if nvl(pk_csf_api_nfs.gt_row_Nota_Fiscal_Canc.id, 0) > 0 then
            --
            -- Leitura da view vw_csf_nf_canc_serv_ff
            pkb_ler_nf_canc_serv_ff ( est_log_generico_nf  => vt_log_generico
                                    , en_notafiscalcanc_id => pk_csf_api_nfs.gt_row_Nota_Fiscal_Canc.id
                                    -- chave da view
                                    , ev_cpf_cnpj_emit     => vt_tab_csf_nf_canc_serv(i).cpf_cnpj_emit
                                    , en_dm_ind_emit       => vt_tab_csf_nf_canc_serv(i).dm_ind_emit
                                    , en_dm_ind_oper       => vt_tab_csf_nf_canc_serv(i).dm_ind_oper
                                    , ev_cod_part          => vt_tab_csf_nf_canc_serv(i).cod_part
                                    , ev_serie             => vt_tab_csf_nf_canc_serv(i).serie
                                    , en_nro_nf            => vt_tab_csf_nf_canc_serv(i).nro_nf
                                    );
            --
         end if;
         --
         -- Se registrou algum log, altera a Nota Fiscal para dm_st_proc = 10 - "Erro de Validação", exclui o cancelamento
         -- Comentado pois esta dando muito problema! - 31/05/2010 - Leandro A. Savenhago
         --if nvl(vt_log_generico.count,0) > 0 then
            --
            pkb_excluir_canc ( ev_cpf_cnpj_emit          => vt_tab_csf_nf_canc_serv(i).CPF_CNPJ_EMIT
                             , en_dm_ind_emit            => vt_tab_csf_nf_canc_serv(i).DM_IND_EMIT
                             , en_dm_ind_oper            => vt_tab_csf_nf_canc_serv(i).DM_IND_OPER
                             , ev_cod_part               => vt_tab_csf_nf_canc_serv(i).COD_PART
                             , ev_serie                  => vt_tab_csf_nf_canc_serv(i).SERIE
                             , en_nro_nf                 => vt_tab_csf_nf_canc_serv(i).NRO_NF
                             , en_notafiscal_id          => vn_notafiscal_id
                             );
            --
         --end if;
         --
         pk_csf_api_nfs.pkb_seta_referencia_id ( en_id => null );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_ler_Nota_Fiscal_Canc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api_nfs.gv_cabec_log
                                     , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_Nota_Fiscal_Canc;

-------------------------------------------------------------------------------------------------------

-- executa procedure Stafe
procedure pkb_stafe ( ev_cpf_cnpj in varchar2
                    , ed_dt_ini   in date
                    , ed_dt_fin   in date
                    )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'PK_INT_NFS_STAFE_CSF') = 0 then
      --
      return;
      --
   end if;
   --
   if length(ev_cpf_cnpj) in (11, 14) then
      --
      vn_fase := 2;
      --
      gv_sql := 'begin PK_INT_NFS_STAFE_CSF.PB_GERA(' ||
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
               pk_csf_api_nfs.gv_mensagem_log := 'Erro na pkb_stafe fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  Log_Generico.id%TYPE;
               begin
                  --
                  pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                                    , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                                    , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                                    , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                                    , en_referencia_id   => null
                                                    , ev_obj_referencia  => pk_csf_api_nfs.gv_obj_referencia
                                                    , en_empresa_id      => gn_empresa_id
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
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pkb_stafe fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                           , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                           , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                           , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                           , en_referencia_id   => null
                                           , ev_obj_referencia  => pk_csf_api_nfs.gv_obj_referencia
                                           , en_empresa_id      => gn_empresa_id
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

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais de Serviços Eletrônicas de Emissão Própria
-- por meio de leitura de views
procedure pkb_integracao ( ev_sist_orig in varchar2 default null )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.id empresaintegrdados_id
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
    order by 1;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   vn_fase := 1;
   --
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   gv_sist_orig := trim(ev_sist_orig);
   --
   vn_fase := 2;
   --
   pk_csf_api_nfs.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      gn_multorg_id    := rec.multorg_id;
      gn_empresa_id    := rec.empresa_id;
      --
      vn_fase := 3;
      --
      if vv_cpf_cnpj_emit is null then
         goto proximo;
      end if;
      --
      vn_fase := 4;
      -- Seta o DBLink
      gn_empresaintegrbanco_id := rec.empresaintegrdados_id;
      gv_nome_dblink           := rec.nome_dblink;
      gv_owner_obj             := rec.owner_obj;
      gd_dt_ini_integr         := trunc(rec.dt_ini_integr);
      --
      vn_fase := 5;
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
      vn_fase := 6;
      --
      if trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := trim(rec.formato_dt_erp);
      else
         gd_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 7;
      -- seta "where" para pesquisa de Nfs de emissão própria
      pkb_seta_where_emissao_propria;
      --
      vn_fase := 8;
      -- leitura das Notas Fiscais de Serviço
      pkb_ler_nota_fiscal_serv ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 9;
      -- leitura de notas fiscais canceladas
      pkb_ler_Nota_Fiscal_Canc( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit
                              , en_dm_ind_emit   => 0 );
      --
      -- Verifica se redorna a informação para o ERP
      if rec.dm_ret_infor_integr = 1 then
         --
         vn_fase := 10;
         -- Integra a informação para o ERP - VW_CSF_RESP_NFS_ERP
         pkb_int_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10.1;
         -- retorna a informação para o ERP - VW_CSF_RESP_NFS_ERP
         pkb_ret_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10.2;
         -- Integra a informação para o ERP - VW_CSF_RESP_NFS_ERP_NEO
         pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 10.3;
         -- retorna a informação para o ERP - VW_CSF_RESP_NFS_ERP_NEO
         pkb_ret_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
      end if;
      --
      <<proximo>>
      null;
      --
   end loop;
   --
   vn_fase := 11;
   -- Finaliza o log genérico para a integração das Notas Fiscais de Serviço no CSF
   pk_csf_api_nfs.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 12;
   --
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_integracao fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.erro_de_sistema );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integracao;
--
-- ================================================================================================================================ --
--
--| Procedimento que inicia a integração de Notas Fiscais de Serviços através do Mult-Org.
--| Esse processo estará sendo executado por JOB SCHEDULER, especifícamente para Ambiente Amazon.
--| A rotina deverá executar o mesmo procedimento da rotina pkb_integracao, porém com a identificação da mult-org.
procedure pkb_integr_multorg ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr ( en_multorg_id in mult_org.id%type ) is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.id empresaintegrdados_id
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
   --
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 2;
   --
   pk_csf_api_nfs.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr ( en_multorg_id => en_multorg_id )
   loop
      --
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      gn_multorg_id    := rec.multorg_id;
      gn_empresa_id    := rec.empresa_id;
      --
      vn_fase := 3;
      --
      if vv_cpf_cnpj_emit is null then
         goto proximo;
      end if;
      --
      vn_fase := 4;
      -- Seta o DBLink
      gn_empresaintegrbanco_id := rec.empresaintegrdados_id;
      gv_nome_dblink           := rec.nome_dblink;
      gv_owner_obj             := rec.owner_obj;
      gd_dt_ini_integr         := trunc(rec.dt_ini_integr);
      --
      vn_fase := 5;
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
      vn_fase := 6;
      --
      if trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := trim(rec.formato_dt_erp);
      else
         gd_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 7;
      -- seta "where" para pesquisa de Nfs de emissão própria
      pkb_seta_where_emissao_propria;
      --
      vn_fase := 8;
      -- leitura das Notas Fiscais de Serviço
      pkb_ler_nota_fiscal_serv ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 11;
      -- leitura de notas fiscais canceladas
      pkb_ler_Nota_Fiscal_Canc( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit 
                              , en_dm_ind_emit   => 0 );
      --
      -- Verifica se redorna a informação para o ERP
      if rec.dm_ret_infor_integr = 1 then
         --
         vn_fase := 12;
         -- Integra a informação para o ERP - VW_CSF_RESP_NFS_ERP
         pkb_int_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 12.1;
         -- retorna a informação para o ERP - VW_CSF_RESP_NFS_ERP
         pkb_ret_infor_erp ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 12.2;
         -- Integra a informação para o ERP - VW_CSF_RESP_NFS_ERP_NEO
         pkb_int_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
         vn_fase := 12.3;
         -- retorna a informação para o ERP - VW_CSF_RESP_NFS_ERP_NEO
         pkb_ret_infor_erp_neo ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
         --
      end if;
      --
      <<proximo>>
      null;
      --
   end loop;
   --
   vn_fase := 14;
   -- Finaliza o log genérico para a integração das Notas Fiscais de Serviço no CSF
   pk_csf_api_nfs.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 15;
   --
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_integr_multorg fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.erro_de_sistema );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_multorg;

-------------------------------------------------------------------------------------------------------

-- procedimento seta "where" para pesquisa por período

procedure pkb_seta_where_periodo ( ed_dt_ini  in  date
                                 , ed_dt_fin  in  date )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gv_where := null;
   gv_where := ' and ((DM_IND_EMIT = 0 AND (DT_EMISS >= ' || '''' || to_char(ed_dt_ini, gd_formato_dt_erp) || '''' ||
                                         ' AND DT_EMISS <= ' || '''' || to_char(ed_dt_fin, gd_formato_dt_erp) || '''' ||
               ')) OR (DM_IND_EMIT = 1 AND (DT_SAI_ENT >= ' || '''' || to_char(ed_dt_ini, gd_formato_dt_erp) || '''' ||
                                              ' AND DT_SAI_ENT <= ' || '''' || to_char(ed_dt_fin, gd_formato_dt_erp) || '''' || ')))';
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_seta_where_periodo fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_cabec_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                         , en_referencia_id   => null
                                         , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_seta_where_periodo;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais de Serviço por empresa e período

procedure pkb_integr_periodo ( en_empresa_id  in  empresa.id%type
                             , ed_dt_ini      in  date
                             , ed_dt_fin      in  date )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.id empresaintegrdados_id
        , eib.owner_obj
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
        , e.multorg_id
     from empresa e
        , empresa_integr_banco eib
    where e.id             = en_empresa_id
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
   gn_empresa_id := en_empresa_id;
   --
   vn_fase := 1;
   -- seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 1.1;
   --
   pk_csf_api_nfs.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      gn_multorg_id    := rec.multorg_id;
      --
      vn_fase := 2;
      -- Seta o DBLink
      gn_empresaintegrbanco_id := rec.empresaintegrdados_id;
      gv_nome_dblink           := rec.nome_dblink;
      gv_owner_obj             := rec.owner_obj;
      gd_dt_ini_integr         := null;
      --
      vn_fase := 3;
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
      vn_fase := 3.1;
      --
      if trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := trim(rec.formato_dt_erp);
      else
         gd_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 3.2;
      --
      pkb_stafe ( ev_cpf_cnpj => vv_cpf_cnpj_emit
                , ed_dt_ini   => ed_dt_ini
                , ed_dt_fin   => ed_dt_fin
                );
      --
      vn_fase := 4;
      -- seta "where" para pesquisa por período
      pkb_seta_where_periodo ( ed_dt_ini  => ed_dt_ini
                             , ed_dt_fin  => ed_dt_fin );
      --
      vn_fase := 5;
      -- leitura das Notas Fiscais de Serviços
      pkb_ler_nota_fiscal_serv ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 6;
      --
      pkb_ler_Nota_Fiscal_Canc ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit
                               , en_dm_ind_emit   => 1
                               );
      --
      <<proximo>>
      --
      null;
      --
   end loop;
   --
   vn_fase := 6;
   -- Finaliza o log genérico para a integração das Notas Fiscais de Serviço no CSF
   pk_csf_api_nfs.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 7;
   --
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_integr_periodo fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_periodo;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração Normal de Notas Fiscais de Serviço recuperando todas as empresas

procedure pkb_integr_periodo_normal ( ed_dt_ini      in  date
                                    , ed_dt_fin      in  date
                                    )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
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
      pkb_integr_periodo ( en_empresa_id  => rec.empresa_id
                         , ed_dt_ini      => ed_dt_ini
                         , ed_dt_fin      => ed_dt_fin
                         );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_integr_periodo_normal fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_periodo_normal;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais de Serviço por período

procedure pkb_integr_periodo_geral ( en_multorg_id in mult_org.id%type
                                   , ed_dt_ini     in  date
                                   , ed_dt_fin     in  date
                                   )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.nome_dblink
        , e.dm_util_aspa
        , e.dm_ret_infor_integr
        , e.dt_ini_integr
        , e.owner_obj
        , e.formato_dt_erp
        , e.multorg_id
     from empresa e
    where e.multorg_id  = en_multorg_id
      and e.dm_situacao = 1  -- Ativa
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
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 1.1;
   --
   pk_csf_api_nfs.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      gn_multorg_id    := rec.multorg_id;
      gn_empresa_id    := rec.empresa_id;
      --
      vn_fase := 2;
      -- Seta o DBLink
      gv_nome_dblink   := rec.nome_dblink;
      gv_owner_obj     := rec.owner_obj;
      gd_dt_ini_integr := null;
      --
      vn_fase := 3;
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
      vn_fase := 3.1;
      --
      if trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := trim(rec.formato_dt_erp);
      else
         gd_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 3.2;
      --
      pkb_stafe ( ev_cpf_cnpj => vv_cpf_cnpj_emit
                , ed_dt_ini   => ed_dt_ini
                , ed_dt_fin   => ed_dt_fin
                );
      --
      vn_fase := 4;
      -- seta "where" para pesquisa por período
      pkb_seta_where_periodo ( ed_dt_ini  => ed_dt_ini
                             , ed_dt_fin  => ed_dt_fin );
      --
      vn_fase := 5;
      -- leitura das Notas Fiscais de Serviços
      pkb_ler_nota_fiscal_serv ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      pkb_ler_Nota_Fiscal_Canc ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit
                               , en_dm_ind_emit   => 1
                               );      
      --
      <<proximo>>
      null;
      --
   end loop;
   --
   vn_fase := 6;
   -- Finaliza o log genérico para a integração das Notas Fiscais de Serviço no CSF
   pk_csf_api_nfs.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 7;
   --
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_integr_periodo_geral fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_periodo_geral;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais Eletrônicas de Emissão Própria
-- por meio da integração por Bloco
procedure pkb_int_bloco ( en_paramintegrdados_id  in param_integr_dados.id%type
                        , ed_dt_ini               in date default null
			, ed_dt_fin               in date default null
			, en_empresa_id           in empresa.id%type default null
                        )
is
   --
   vn_fase          number := 0;
   vv_cpf_cnpj_emit varchar2(14) := null;
   --
   cursor c_empr is
   select e.id empresa_id
        , e.multorg_id
     from param_integr_dados_empresa p
        , empresa e
    where p.paramintegrdados_id  = en_paramintegrdados_id
      and p.empresa_id           = nvl(en_empresa_id, p.empresa_id)
      and e.id                   = p.empresa_id
      and e.dm_situacao          = 1
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
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 2;
   --
   pk_csf_api_nfs.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vn_fase := 3;
      --
      gv_nome_dblink := null;
      gv_owner_obj   := null;
      gv_sist_orig   := null;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      gn_multorg_id    := rec.multorg_id;
      gn_empresa_id    := rec.empresa_id;
      --
      vn_fase := 4;
      --
      gd_formato_dt_erp := gv_formato_data;
      --
      if ed_dt_ini is not null and ed_dt_fin is not null then
         --
         -- seta "where" para pesquisa por período
         pkb_seta_where_periodo ( ed_dt_ini  => ed_dt_ini
                                , ed_dt_fin  => ed_dt_fin );
         --
      end if;
      --
      vn_fase := 5;
      -- leitura das Notas Fiscais
      pkb_ler_nota_fiscal_serv ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit );
      --
      vn_fase := 6;
      -- leitura de notas fiscais canceladas
      pkb_ler_Nota_Fiscal_Canc ( ev_cpf_cnpj_emit => vv_cpf_cnpj_emit
                               , en_dm_ind_emit   => 0 );
      --
      <<proximo>>
      null;
      --
   end loop;
   --
   vn_fase := 7;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api_nfs.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 8;
   --
   pk_csf_api_nfs.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pk_integr_view_nfs.pkb_int_bloco fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api_nfs.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                         , ev_mensagem        => pk_csf_api_nfs.gv_mensagem_log
                                         , ev_resumo          => pk_csf_api_nfs.gv_mensagem_log
                                         , en_tipo_log        => pk_csf_api_nfs.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_int_bloco;

-------------------------------------------------------------------------------------------------------

end pk_integr_view_nfs;
/
