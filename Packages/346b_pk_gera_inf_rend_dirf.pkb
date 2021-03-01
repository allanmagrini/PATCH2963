create or replace package body csf_own.pk_gera_inf_rend_dirf is
-------------------------------------------------------------------------------------------------------
--
--| Corpo do pacote de procedimentos de Geração de Informe de Rendimentos da DIRF
--
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- procedimento recupera os dados da Geração de Informe de Rendimentos da DIRF
-------------------------------------------------------------------------------------------------------
procedure pkb_dados_gera_inf_rend_dirf ( en_gerainfrenddirf_id in gera_inf_rend_dirf.id%type )
is
begin
   --
   select *
     into gt_row_gera_inf_rend_dirf
     from gera_inf_rend_dirf
    where id = en_gerainfrenddirf_id;
   --
exception
   when no_data_found then
      gt_row_gera_inf_rend_dirf := null;
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_inf_rend_dirf.pkb_dados_gera_inf_rend_dirf: '||sqlerrm);
end pkb_dados_gera_inf_rend_dirf;
-------------------------------------------------------------------------------------------------------
-- cria os Informes de Rendimento da DIRF
-------------------------------------------------------------------------------------------------------
procedure pkb_criar_inf_rend_dirf(est_log_generico_ird in out nocopy dbms_sql.number_table) is
  --
  vn_fase              number;
  vt_log_generico_ird  dbms_sql.number_table;
  i                    varchar2(14) := null; -- pls_integer;
  j                    varchar2(14) := null; -- pls_integer;
  vn_tiporetimp_id_old number := 0;
  vn_pessoa_id_old     number := 0;
  vn_infrenddirf_id    inf_rend_dirf.id%type;
  vn_dm_situacao       inf_rend_dirf.dm_situacao%type;
  vv_cpf_cnpj_emit     varchar2(14);
  vv_cod_part          pessoa.cod_part%type;
  vv_cod_ret_imp       tipo_ret_imp.cd%type;
  vv_cod_part_rpde     pessoa.cod_part%type;
  vb_achou             boolean;
  vb_achou_rtdp        boolean;
  --
begin
  --
  vn_fase := 1;
  --
  if nvl(vt_bi_tab_csf_imp_ret.count, 0) > 0 then
    --
    vn_fase := 2;
    --
    i := nvl(vt_bi_tab_csf_imp_ret.first, 0); -- tiporetimp_id
    --
    vn_fase := 2.1;
    --
    loop
      --
      vn_fase := 2.2;
      --
      if nvl(i, 0) = 0 then
        exit;
      end if;
      --
      vn_fase := 2.3;
      --
      j := vt_bi_tab_csf_imp_ret(i).first; -- cnpjcpf
      --
      vn_fase := 3;
      --
      loop
        --
        vn_fase := 3.1;
        --
        if nvl(j, 0) = 0 then
          exit;
        end if;
        --
        -- seta o tipo de integração que será feito
        -- 0 - Somente valida os dados e registra o Log de ocorrência
        -- 1 - valida os dados e registra o Log de ocorrência e insere a informação
        -- Todos os procedimentos de integração fazem referência a ele
        pk_csf_api_dirf.pkb_seta_tipo_integr(en_tipo_integr => 1);
        --
        pk_csf_api_dirf.pkb_seta_obj_ref(ev_objeto => 'INF_REND_DIRF');
        --
        vn_fase := 4;
        -- Cria o Informe de rendimentos, conforme mudança de dados
        if vn_tiporetimp_id_old <> vt_bi_tab_csf_imp_ret(i)(j)
        .tiporetimp_id or vn_pessoa_id_old <> vt_bi_tab_csf_imp_ret(i)(j).pessoa_id then
          --
          vt_log_generico_ird.delete;
          --
          vn_fase := 4.1;
          --
          vn_tiporetimp_id_old := vt_bi_tab_csf_imp_ret(i)(j).tiporetimp_id;
          vn_pessoa_id_old     := vt_bi_tab_csf_imp_ret(i)(j).pessoa_id;
          --
          vn_fase := 4.2;
          --
          pk_csf_api_dirf.gt_row_inf_rend_dirf               := null;
          pk_csf_api_dirf.gt_row_inf_rend_dirf.empresa_id    := gt_row_gera_inf_rend_dirf.empresa_id;
          pk_csf_api_dirf.gt_row_inf_rend_dirf.pessoa_id     := vt_bi_tab_csf_imp_ret(i)(j).pessoa_id;
          pk_csf_api_dirf.gt_row_inf_rend_dirf.ano_calend    := vt_bi_tab_csf_imp_ret(i)(j).ano;
          pk_csf_api_dirf.gt_row_inf_rend_dirf.tiporetimp_id := vt_bi_tab_csf_imp_ret(i)(j).tiporetimp_id;
          pk_csf_api_dirf.gt_row_inf_rend_dirf.dm_origem     := 1; -- Documento Fiscal
          pk_csf_api_dirf.gt_row_inf_rend_dirf.dm_tipo_lcto  := 1; -- Integração
          pk_csf_api_dirf.gt_row_inf_rend_dirf.dm_situacao   := 0; -- Não validada
          pk_csf_api_dirf.gt_row_inf_rend_dirf.dm_st_email   := 0; -- Não Enviado
          pk_csf_api_dirf.gt_row_inf_rend_dirf.infor         := null;
          pk_csf_api_dirf.gt_row_inf_rend_dirf.ano_ref       := gt_row_gera_inf_rend_dirf.ano_ref;
          --
          vn_fase := 4.3;
          --
          -- Verifica se já existe um registro de DIRF
          vn_infrenddirf_id := pk_csf_dirf.fkg_ver_existe_inf_rend_dirf(en_empresa_id    => pk_csf_api_dirf.gt_row_inf_rend_dirf.empresa_id,
                                                                        en_pessoa_id     => pk_csf_api_dirf.gt_row_inf_rend_dirf.pessoa_id,
                                                                        en_ano_ref       => pk_csf_api_dirf.gt_row_inf_rend_dirf.ano_ref,
                                                                        en_tiporetimp_id => pk_csf_api_dirf.gt_row_inf_rend_dirf.tiporetimp_id,
                                                                        en_dm_origem     => pk_csf_api_dirf.gt_row_inf_rend_dirf.dm_origem);
          --
          vn_fase := 4.4;
          --
          if nvl(vn_infrenddirf_id, 0) > 0 then
            --
            vn_fase := 4.41;
            --
            -- Recupera a situação do Informe de Rendimento
            vn_dm_situacao := pk_csf_dirf.fkg_existe_situ_inf_rend_dirf(en_infrenddirf_id => vn_infrenddirf_id);
            --
            if vn_dm_situacao = 2 -- Erro de validação
             then
              --
              pk_csf_api_dirf.pkb_excluir_inf_rend(est_log_generico_ird => vt_log_generico_ird,
                                                   en_infrenddirf_id    => vn_infrenddirf_id);
              --
            else
              --
              goto pula;
              --
            end if;
            --
            pk_csf_api_dirf.gt_row_inf_rend_dirf.id := vn_infrenddirf_id;
            --
          end if;
          --
          vn_fase := 4.5;
          --
          vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => pk_csf_api_dirf.gt_row_inf_rend_dirf.empresa_id);
          --
          vn_Fase := 4.51;
          --
          vv_cod_part := pk_csf.fkg_pessoa_cod_part(en_pessoa_id => pk_csf_api_dirf.gt_row_inf_rend_dirf.pessoa_id);
          --
          vn_fase := 4.52;
          --
          vv_cod_ret_imp := pk_csf_dirf.fkg_retorna_cd_imposto(en_tiporetimp_id => pk_csf_api_dirf.gt_row_inf_rend_dirf.tiporetimp_id);
          --
          vn_fase := 4.53;
          --
          pk_csf_api_dirf.pkb_integr_inf_rend_dirf(est_log_generico_ird => vt_log_generico_ird,
                                                   est_inf_rend_dirf    => pk_csf_api_dirf.gt_row_inf_rend_dirf,
                                                   ev_cpf_cnpj          => vv_cpf_cnpj_emit,
                                                   ev_cod_part          => vv_cod_part,
                                                   ev_cod_ret_imp       => vv_cod_ret_imp,
                                                   en_multorg_id        => pk_csf.fkg_multorg_id_empresa(en_empresa_id => pk_csf_api_dirf.gt_row_inf_rend_dirf.empresa_id));
          --
        end if;
        --
        vn_fase := 5;
        -- No processo de integração podem ocorrer erros e o registro não fica gravado
        if pk_csf_dirf.fkg_existe_inf_rend_dirf(en_infrenddirf_id => nvl(pk_csf_api_dirf.gt_row_inf_rend_dirf.id,
                                                                         0)) = true then
          --
          vn_fase := 6;
          -- cria o informe de rendimento RTRT 
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa := null;
          --
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.infrenddirf_id := nvl(pk_csf_api_dirf.gt_row_inf_rend_dirf.id, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_01      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_01, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_02      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_02, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_03      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_03, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_04      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_04, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_05      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_05, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_06      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_06, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_07      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_07, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_08      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_08, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_09      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_09, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_10      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_10, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_11      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_11, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_12      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_rend_12, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_13      := 0;
          --
          vn_fase := 6.1;
          --
          pk_csf_api_dirf.pkb_integr_inf_rend_dirf_mensa(est_log_generico_ird     => vt_log_generico_ird,
                                                         est_inf_rend_dirf_mensal => pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa,
                                                         ev_cod_tipo_dirf         => 'RTRT');
          --
          vn_fase := 6.2;
          --
          -- Cria registros RTDP
          -- Verifica se o array não é nulo/vazio       
          begin
            vb_achou_rtdp := vt_bi_tab_csf_imp_ded_dep(i).exists(j);
          exception
            when others then
              vb_achou_rtdp := false;
          end;
          --
          if vb_achou_rtdp then  
            if (nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_01, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_02, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_03, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_04, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_05, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_05, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_07, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_08, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_09, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_10, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_11, 0) +
                nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_12, 0)) > 0 then
              -- cria o informe de rendimento RTDP 
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu := null;
              --
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.infrenddirf_id := nvl(pk_csf_api_dirf.gt_row_inf_rend_dirf.id, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_01      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_01, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_02      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_02, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_03      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_03, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_04      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_04, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_05      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_05, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_06      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_06, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_07      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_07, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_08      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_08, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_09      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_09, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_10      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_10, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_11      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_11, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_12      := nvl(vt_bi_tab_csf_imp_ded_dep(i)(j).vl_dedu_12, 0);
              pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu.vl_mes_13      := 0;
              --
              vn_fase := 6.3;
              --
              -- Usando package do mensal para gravar as deduções
              pk_csf_api_dirf.pkb_integr_inf_rend_dirf_mensa(est_log_generico_ird     => vt_log_generico_ird,
                                                             est_inf_rend_dirf_mensal => pk_csf_api_dirf.gt_row_inf_rend_dirf_dedu,
                                                             ev_cod_tipo_dirf         => 'RTDP');
            end if;                                                           
          end if;          
          --
          vn_fase := 7;
          -- cria a Imposto Retido RTIRF
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa := null;
          --
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.infrenddirf_id := nvl(pk_csf_api_dirf.gt_row_inf_rend_dirf.id, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_01      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_01, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_02      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_02, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_03      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_03, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_04      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_04, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_05      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_05, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_06      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_06, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_07      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_07, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_08      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_08, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_09      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_09, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_10      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_10, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_11      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_11, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_12      := nvl(vt_bi_tab_csf_imp_ret(i)(j).vl_ir_12, 0);
          pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa.vl_mes_13      := 0;
          --
          vn_fase := 7.1;
          --
          pk_csf_api_dirf.pkb_integr_inf_rend_dirf_mensa(est_log_generico_ird     => vt_log_generico_ird,
                                                         est_inf_rend_dirf_mensal => pk_csf_api_dirf.gt_row_inf_rend_dirf_mensa,
                                                         ev_cod_tipo_dirf         => 'RTIRF');
          --
          --
          vn_fase := 8;
          --
          -- Cria registros RPDE
          -- Verifica se o array não é nulo/vazio
          begin
            vb_achou := vt_bi_tab_csf_imp_ret_rpde(i).exists(j);
          exception
            when others then
              vb_achou := false;
          end;
          --
          if vb_achou then
          --if vt_bi_tab_csf_imp_ret_rpde.count > 0 then
            --
            pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde := null;
            --
            pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde.infrenddirf_id := nvl(pk_csf_api_dirf.gt_row_inf_rend_dirf.id, 0);
            pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde.pessoa_id      := nvl(vt_bi_tab_csf_imp_ret_rpde(i)(j).pessoa_id, 0);
            pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde.dm_tipo_rend   := nvl(vt_bi_tab_csf_imp_ret_rpde(i)(j).dm_tipo_rend, 0);
            pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde.dm_fonte_pag   := nvl(vt_bi_tab_csf_imp_ret_rpde(i)(j).dm_fonte_pag, 0);
            pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde.dm_forma_trib  := nvl(vt_bi_tab_csf_imp_ret_rpde(i)(j).dm_forma_trib, 0);
            pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde.data_pgto      := vt_bi_tab_csf_imp_ret_rpde(i)(j).data_pgto;
            pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde.vl_rend_pago   := nvl(vt_bi_tab_csf_imp_ret_rpde(i)(j).vl_rend_pago, 0);
            pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde.vl_imp_ret     := nvl(vt_bi_tab_csf_imp_ret_rpde(i)(j).vl_imp_ret, 0);
            --
            vn_fase := 8.1;
            --
            vv_cod_part_rpde := pk_csf.fkg_pessoa_cod_part(en_pessoa_id => pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde.pessoa_id);
            --
            pk_csf_api_dirf.pkb_integr_inf_rend_dirf_rpde(est_log_generico_ird   => vt_log_generico_ird,
                                                          est_inf_rend_dirf_rpde => pk_csf_api_dirf.gt_row_inf_rend_dirf_rpde,
                                                          ev_cod_part_rpde       => vv_cod_part_rpde,
                                                          en_multorg_id          => pk_csf.fkg_multorg_id_empresa(en_empresa_id => pk_csf_api_dirf.gt_row_inf_rend_dirf.empresa_id));
          end if;
          --
          vn_fase := 9;
          -- cria o relaciomento da geração
          pk_csf_api_dirf.gt_row_r_gera_inf_rend_dirf                    := null;
          pk_csf_api_dirf.gt_row_r_gera_inf_rend_dirf.gerainfrenddirf_id := gt_row_gera_inf_rend_dirf.id;
          pk_csf_api_dirf.gt_row_r_gera_inf_rend_dirf.infrenddirf_id     := pk_csf_api_dirf.gt_row_inf_rend_dirf.id;
          --
          vn_fase := 9.1;
          --
          pk_csf_api_dirf.pkb_integr_r_gera_infrenddirf(est_log_generico_ird     => vt_log_generico_ird,
                                                        est_r_gera_inf_rend_dirf => pk_csf_api_dirf.gt_row_r_gera_inf_rend_dirf);
          --
          commit;
          --
          vn_fase := 10;
          --
          if nvl(vt_log_generico_ird.count, 0) > 0 then
            -- ocorreram erros de integração
            --
            vn_fase := 11;
            --
          else
            --
            vn_fase := 12;
            -- valida a informação
            pk_vld_amb_dirf.pkb_valida(en_infrenddirf_id => pk_csf_api_dirf.gt_row_inf_rend_dirf.id);
            --
          end if;
          --
        end if;
        --
        vn_fase              := 13;
        est_log_generico_ird := vt_log_generico_ird;
        -- pula para o próximo registro
        <<pula>>
      --
        if j = vt_bi_tab_csf_imp_ret(i).last then
          exit;
        else
          j := vt_bi_tab_csf_imp_ret(i).next(j);
        end if;
        --
      end loop;
      --
      if i = vt_bi_tab_csf_imp_ret.last then
        exit;
      else
        i := vt_bi_tab_csf_imp_ret.next(i);
      end if;
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    raise_application_error(-20101, 'Erro na pk_gera_inf_rend_dirf.pkb_criar_inf_rend_dirf (fase = ' || vn_fase || '): ' || sqlerrm);
end pkb_criar_inf_rend_dirf;
-------------------------------------------------------------------------------------------------------
-- Registra os valores
-------------------------------------------------------------------------------------------------------
procedure pkb_reg_valores ( en_tiporetimp_id      in number
                          , en_pessoa_id          in number
                          , ed_dt_docto_pgto_vcto in date
                          , en_ano                in number
                          , en_mes                in number
                          , en_vl_rendimento      in number
                          , en_vl_imp_retido      in number
                          , en_vl_deducao         in number
                          )
is
   --
   vb_achou      boolean := false;
   vb_achou_dedu boolean := false;
   vb_achou_rpde boolean := false;
   vv_sigla_pais pais.sigla_pais%type;
   --
begin
   --
   if en_pessoa_id is not null then
      --
      begin
         vb_achou := vt_bi_tab_csf_imp_ret(en_tiporetimp_id).exists(en_pessoa_id);--vt_bi_tab_csf_imp_ret(en_tiporetimp_id).exists(vv_cnpjcpf);
      exception
         when others then
            vb_achou := false;
      end;
      --
      if not vb_achou then
         --
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).tiporetimp_id  := nvl(en_tiporetimp_id,0);
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).pessoa_id      := nvl(en_pessoa_id,0);
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).ano            := nvl(en_ano,0);
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).mes            := nvl(en_mes,0);
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_01     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_01       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_02     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_02       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_03     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_03       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_04     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_04       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_05     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_05       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_06     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_06       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_07     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_07       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_08     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_08       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_09     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_09       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_10     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_10       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_11     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_11       := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_12     := 0;
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_12       := 0;
         --
      end if;
      --
      if en_mes = 1 then
         --
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_01     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_01 + nvl(en_vl_rendimento,0);
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_01       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_01 + nvl(en_vl_imp_retido,0);
         --
      elsif en_mes = 2 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_02     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_02 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_02       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_02 + nvl(en_vl_imp_retido,0);
            --
      elsif en_mes = 3 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_03     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_03 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_03       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_03 + nvl(en_vl_imp_retido,0);
            --
      elsif en_mes = 4 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_04     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_04 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_04       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_04 + nvl(en_vl_imp_retido,0);
            --
      elsif en_mes = 5 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_05     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_05 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_05       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_05 + nvl(en_vl_imp_retido,0);
            --
      elsif en_mes = 6 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_06     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_06 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_06       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_06 + nvl(en_vl_imp_retido,0);
            --
      elsif en_mes = 7 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_07     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_07 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_07       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_07 + nvl(en_vl_imp_retido,0);
            --
      elsif en_mes = 8 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_08     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_08 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_08       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_08 + nvl(en_vl_imp_retido,0);
            --
      elsif en_mes = 9 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_09     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_09 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_09       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_09 + nvl(en_vl_imp_retido,0);
            --
      elsif en_mes = 10 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_10     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_10 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_10       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_10 + nvl(en_vl_imp_retido,0);
            --
      elsif en_mes = 11 then
            --
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_11     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_11 + nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_11       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_11 + nvl(en_vl_imp_retido,0);
            --
      else
         --
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_12     := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_rend_12 + nvl(en_vl_rendimento,0);
         vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_12       := vt_bi_tab_csf_imp_ret(en_tiporetimp_id)(en_pessoa_id).vl_ir_12 + nvl(en_vl_imp_retido,0);
         --
      end if;
      --
      -- Rotina para as deducoes dependenteste (RTDP)
      begin
         vb_achou_dedu := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id).exists(en_pessoa_id);
      exception
         when others then
            vb_achou_dedu := false;
      end;
      --
      if not vb_achou_dedu then
         --
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).tiporetimp_id  := nvl(en_tiporetimp_id,0);
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).pessoa_id      := nvl(en_pessoa_id,0);
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).ano            := nvl(en_ano,0);
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).mes            := nvl(en_mes,0);
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_01     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_02     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_03     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_04     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_05     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_06     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_07     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_08     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_09     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_10     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_11     := 0;
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_12     := 0;
         --
      end if;
      --
      if en_mes = 1 then
         --
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_01     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_01 + nvl(en_vl_deducao,0);
         --
      elsif en_mes = 2 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_02     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_02 + nvl(en_vl_deducao,0);
            --
      elsif en_mes = 3 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_03     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_03 + nvl(en_vl_deducao,0);
            --
      elsif en_mes = 4 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_04     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_04 + nvl(en_vl_deducao,0);
            --
      elsif en_mes = 5 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_05     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_05 + nvl(en_vl_deducao,0);
            --
      elsif en_mes = 6 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_06     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_06 + nvl(en_vl_deducao,0);
            --
      elsif en_mes = 7 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_07     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_07 + nvl(en_vl_deducao,0);
            --
      elsif en_mes = 8 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_08     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_08 + nvl(en_vl_deducao,0);
            --
      elsif en_mes = 9 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_09     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_09 + nvl(en_vl_deducao,0);
            --
      elsif en_mes = 10 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_10     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_10 + nvl(en_vl_deducao,0);
            --
      elsif en_mes = 11 then
            --
            vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_11     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_11 + nvl(en_vl_deducao,0);
            --
      else
         --
         vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_12     := vt_bi_tab_csf_imp_ded_dep(en_tiporetimp_id)(en_pessoa_id).vl_dedu_12 + nvl(en_vl_deducao,0);
         --
      end if;      
      --
      --
      -- Rotina para o tipo de arquivo RPDE - inf_rend_dirf_rpde
      vv_sigla_pais := pk_csf.fkg_sigla_pais(en_pessoa_id);
      --
      if vv_sigla_pais is not null and vv_sigla_pais <> 'BR' then
         --
         begin
            vb_achou_rpde := vt_bi_tab_csf_imp_ret_rpde(en_tiporetimp_id).exists(en_pessoa_id);
         exception
            when others then
               vb_achou_rpde := false;
         end;
         --
         if not vb_achou_rpde then
            --
            --vt_bi_tab_csf_imp_ret_rpde(en_tiporetimp_id)(en_pessoa_id).tiporetimp_id  := nvl(en_tiporetimp_id,0);
            --
            vt_bi_tab_csf_imp_ret_rpde(en_tiporetimp_id)(en_pessoa_id).pessoa_id     :=  nvl(en_pessoa_id,0);
            vt_bi_tab_csf_imp_ret_rpde(en_tiporetimp_id)(en_pessoa_id).dm_tipo_rend  :=  300;
            vt_bi_tab_csf_imp_ret_rpde(en_tiporetimp_id)(en_pessoa_id).dm_fonte_pag  :=  900;
            vt_bi_tab_csf_imp_ret_rpde(en_tiporetimp_id)(en_pessoa_id).dm_forma_trib :=  30;
            vt_bi_tab_csf_imp_ret_rpde(en_tiporetimp_id)(en_pessoa_id).data_pgto     :=  ed_dt_docto_pgto_vcto;
            vt_bi_tab_csf_imp_ret_rpde(en_tiporetimp_id)(en_pessoa_id).vl_rend_pago  :=  nvl(en_vl_rendimento,0);
            vt_bi_tab_csf_imp_ret_rpde(en_tiporetimp_id)(en_pessoa_id).vl_imp_ret    :=  nvl(en_vl_imp_retido,0);
            --
         end if;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_inf_rend_dirf.pkb_reg_valores. Erro = '||sqlerrm);
end pkb_reg_valores;
-------------------------------------------------------------------------------------------------------
-- Procedimento para gerar informe de rendimento mensal
-------------------------------------------------------------------------------------------------------
 procedure pkb_gera_ird_docto_fiscal is
  --
  vn_fase          number;
  vn_tiporetimp_id tipo_ret_imp.id%type;
  vv_cd            tipo_ret_imp.cd%type;
  vv_zerar         varchar2(1) := 'N';
  vn_vl_rend       number := 0;
  vn_multorg_id    empresa.multorg_id%type;
  --
  -- Cursor para recuperar as empresas
  cursor c_emp is
    select e2.id empresa_id
      from empresa e1, 
           empresa e2
     where e1.id                        = gt_row_gera_inf_rend_dirf.empresa_id
       and nvl(e2.ar_empresa_id, e2.id) = e1.id
     order by 1;
  --
  -- Cursor recupera apenas os impostos de PIS/COFINS/CSLL
  cursor c_pcc(en_empresa_id empresa.id%type) is
    select dd.tiporetimp_cd,
           dd.pessoa_id,
           to_number(to_char(dd.dt_docto_pgto_vcto, 'rrrr')) ano,
           to_number(to_char(dd.dt_docto_pgto_vcto, 'mm')) mes,
           dd.dt_docto_pgto_vcto,
           nvl(sum(nvl(dd.vl_rendimento, 0)), 0) vl_rendimento,
           nvl(sum(nvl(dd.vl_imp_retido, 0)), 0) vl_imp_retido,
           dd.tipoimp_id
      from (select pir.nro_doc,
                   tri.cd tiporetimp_cd,
                   pir.pessoa_id,
                   case when gn_dt_ref_imp_ret = 'D' then nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto))
                        when gn_dt_ref_imp_ret = 'P' then nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto))
                        when gn_dt_ref_imp_ret = 'V' then nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto))
                   end dt_docto_pgto_vcto,
                   --nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)) dt_docto_pgto_vcto,
                   --nvl(pir.dt_pgto, pir.dt_vcto) dt_docto_pgto_vcto,
                   sum(distinct(pir.vl_base_calc)) vl_rendimento,
                   sum(pir.vl_principal) vl_imp_retido,
                   pir.tipoimp_id tipoimp_id
              from pgto_imp_ret pir, 
                   tipo_ret_imp tri, 
                   tipo_imposto ti
             where pir.empresa_id  = en_empresa_id
               and pir.dm_situacao = 1 -- Validado
               and ((gn_dt_ref_imp_ret = 'D' and to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
                    or
                    (gn_dt_ref_imp_ret = 'P' and to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
                    or	 
                    (gn_dt_ref_imp_ret = 'V' and to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend))
               --and to_number(to_char(nvl(pir.dt_pgto, pir.dt_vcto), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend			   
               and ti.id           = pir.tipoimp_id
               and ti.cd           = 11 -- 11-csll
			   and tri.cd not in ('2372', '2484') -- #70522
               and tri.id          = pir.tiporetimp_id
             group by pir.nro_doc,
                      tri.cd,
                      pir.pessoa_id,
                      nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)),
                      nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)),
                      nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)),					  
                      --nvl(pir.dt_pgto, pir.dt_vcto),
                      pir.tipoimp_id
             union 
            select pir.nro_doc,
                   tri.cd tiporetimp_cd,
                   pir.pessoa_id,
                   case when gn_dt_ref_imp_ret = 'D' then nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto))
                        when gn_dt_ref_imp_ret = 'P' then nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto))
                        when gn_dt_ref_imp_ret = 'V' then nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto))
                   end dt_docto_pgto_vcto,				   
                   --nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)) dt_docto_pgto_vcto,
                   --nvl(pir.dt_pgto, pir.dt_vcto) dt_docto_pgto_vcto, 
                   sum(distinct(pir.vl_base_calc)) vl_rendimento,
                   sum(pir.vl_principal) vl_imp_retido,
                   pir.tipoimp_id tipoimp_id
              from pgto_imp_ret pir, 
                   tipo_ret_imp tri, 
                   tipo_imposto ti
             where pir.empresa_id  = en_empresa_id
               and pir.dm_situacao = 1 -- Validado
               and ((gn_dt_ref_imp_ret = 'D' and to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
                    or
                    (gn_dt_ref_imp_ret = 'P' and to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
                    or	 
                    (gn_dt_ref_imp_ret = 'V' and to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend))
               and ti.id           = pir.tipoimp_id
               and ti.cd           in (4, 5) -- 4-pis, 5-cofins
               and tri.id          = pir.tiporetimp_id
               and tri.cd          in (5952,5979) -- tipo de retenção para 4-pis e 5-cofins para dirf
             group by pir.nro_doc,
                      tri.cd,
                      pir.pessoa_id,
                      nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)),
                      nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)),
                      nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)),					  
                      --nvl(pir.dt_pgto, pir.dt_vcto),
                      pir.tipoimp_id) dd
     group by dd.tiporetimp_cd,
              dd.pessoa_id,
              dd.dt_docto_pgto_vcto,
              to_number(to_char(dd.dt_docto_pgto_vcto, 'rrrr')),
              to_number(to_char(dd.dt_docto_pgto_vcto, 'mm')),
              dd.tipoimp_id
     order by dd.tiporetimp_cd, 
              dd.pessoa_id;
  --
  cursor c_imp_ret(en_empresa_id empresa.id%type) is
    select pir.tiporetimp_id,
           pir.pessoa_id,
           case when gn_dt_ref_imp_ret = 'D' then nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto))
                when gn_dt_ref_imp_ret = 'P' then nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto))
                when gn_dt_ref_imp_ret = 'V' then nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto))
           end dt_docto_pgto_vcto,
           case when gn_dt_ref_imp_ret = 'D' then to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr'))
                when gn_dt_ref_imp_ret = 'P' then to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr'))
                when gn_dt_ref_imp_ret = 'V' then to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr'))
           end ano,
           case when gn_dt_ref_imp_ret = 'D' then to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'mm'))
                when gn_dt_ref_imp_ret = 'P' then to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'mm'))
                when gn_dt_ref_imp_ret = 'V' then to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'mm'))
           end mes,
           sum(pir.vl_base_calc) vl_rendimento,
           sum(pir.vl_principal) vl_imp_retido
      from pgto_imp_ret pir, 
           tipo_ret_imp tri, 
           tipo_imposto ti
     where pir.empresa_id  = en_empresa_id
       and pir.dm_situacao = 1 -- Validado
       and ((gn_dt_ref_imp_ret = 'D' and to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
            or
            (gn_dt_ref_imp_ret = 'P' and to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
            or	 
            (gn_dt_ref_imp_ret = 'V' and to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend))
       and tri.id = pir.tiporetimp_id
       and ti.id  = pir.tipoimp_id
       --and ti.cd not in (4, 5, 6, 11, 13, 14) -- 4-PIS, 5-COFINS, 6-ISS, 11-CSLL, 13-INSS, 14-PCC
       and ti.cd in (12, 14) -- 12-irrf, 14-PCC
     group by pir.tiporetimp_id,
              pir.pessoa_id,
              nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)),
              nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)),
              nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)),
              to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr')),
              to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr')),
              to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr')),              
              to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'mm')),
              to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'mm')),
              to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'mm'));
  --
  -- Cursor recupera apenas dedução dependentes
  cursor c_imp_ded_dep(en_empresa_id empresa.id%type) is
    select pir.tiporetimp_id,
           pir.pessoa_id,
           case when gn_dt_ref_imp_ret = 'D' then nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto))
                when gn_dt_ref_imp_ret = 'P' then nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto))
                when gn_dt_ref_imp_ret = 'V' then nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto))
           end dt_docto_pgto_vcto,
           case when gn_dt_ref_imp_ret = 'D' then to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr'))
                when gn_dt_ref_imp_ret = 'P' then to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr'))
                when gn_dt_ref_imp_ret = 'V' then to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr'))
           end ano,
           case when gn_dt_ref_imp_ret = 'D' then to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'mm'))
                when gn_dt_ref_imp_ret = 'P' then to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'mm'))
                when gn_dt_ref_imp_ret = 'V' then to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'mm'))
           end mes,
           sum(ded.vl_deducao) vl_deducao
      from pgto_imp_ret pir,
           tipo_ret_imp tri,
           tipo_imposto ti,
           pir_det_ded ded
     where pir.empresa_id         = en_empresa_id
       and pir.dm_situacao        = 1 -- Validado
       and ((gn_dt_ref_imp_ret = 'D' and to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
            or
            (gn_dt_ref_imp_ret = 'P' and to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
            or	 
            (gn_dt_ref_imp_ret = 'V' and to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend))
       and tri.id                 = pir.tiporetimp_id
       and ti.id                  = pir.tipoimp_id
       --and ti.cd             not in (4, 5, 6, 11, 13, 14) -- 4-PIS, 5-COFINS, 6-ISS, 11-CSLL, 13-INSS, 14-PCC
       and ti.cd                 in (11, 12, 14) -- 11-csll, 12-irrf, 14-PCC
           and tri.cd not in ('2372','2484')  -- #70522
       and ded.pgtoimpret_id     = pir.id
       and ded.dm_ind_tp_deducao = 6  -- Dedução Dependentes
     group by pir.tiporetimp_id,
              pir.pessoa_id,
              nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)),
              nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)),
              nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)),
              to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr')),
              to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr')),
              to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr')),              
              to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'mm')),
              to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'mm')),
              to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'mm'))              
     union
    select pir.tiporetimp_id,
           pir.pessoa_id,
           case when gn_dt_ref_imp_ret = 'D' then nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto))
                when gn_dt_ref_imp_ret = 'P' then nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto))
                when gn_dt_ref_imp_ret = 'V' then nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto))
           end dt_docto_pgto_vcto,
           case when gn_dt_ref_imp_ret = 'D' then to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr'))
                when gn_dt_ref_imp_ret = 'P' then to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr'))
                when gn_dt_ref_imp_ret = 'V' then to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr'))
           end ano,
           case when gn_dt_ref_imp_ret = 'D' then to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'mm'))
                when gn_dt_ref_imp_ret = 'P' then to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'mm'))
                when gn_dt_ref_imp_ret = 'V' then to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'mm'))
           end mes,
           sum(ded.vl_deducao) vl_deducao
      from pgto_imp_ret pir,
           tipo_ret_imp tri,
           tipo_imposto ti,
           pir_det_ded ded
     where pir.empresa_id         = en_empresa_id
       and pir.dm_situacao        = 1 -- Validado
       and ((gn_dt_ref_imp_ret = 'D' and to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
            or
            (gn_dt_ref_imp_ret = 'P' and to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend)
            or	 
            (gn_dt_ref_imp_ret = 'V' and to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend))
       and tri.id                 = pir.tiporetimp_id
       and tri.cd                 = 5952 -- tipo de retenção para 4-pis e 5-cofins para dirf	   
       and ti.id                  = pir.tipoimp_id
       and ti.cd                  in (4, 5) -- 4-pis, 5-cofins
       and ded.pgtoimpret_id     = pir.id
       and ded.dm_ind_tp_deducao = 6  -- Dedução Dependentes
     group by pir.tiporetimp_id,
              pir.pessoa_id,
              nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)),
              nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)),
              nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)),
              to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'rrrr')),
              to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'rrrr')),
              to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'rrrr')),              
              to_number(to_char(nvl(pir.dt_docto, nvl(pir.dt_pgto, pir.dt_vcto)), 'mm')),
              to_number(to_char(nvl(pir.dt_pgto, nvl(pir.dt_docto, pir.dt_vcto)), 'mm')),
              to_number(to_char(nvl(pir.dt_vcto, nvl(pir.dt_docto, pir.dt_pgto)), 'mm'))              
     order by 1,2;  
  --
  /*  
  cursor c_itemnf(en_empresa_id empresa.id%type) is
    select nf.id notafiscal_id,
           pe.id pessoa_id,
           trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) dt_docto_pgto_vcto,
           to_number(to_char(trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)), 'rrrr')) ano,
           to_number(to_char(trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)), 'mm')) mes,
           ie.id itemnf_id
      from nota_fiscal nf, 
           mod_fiscal mf, 
           pessoa pe, 
           item_nota_fiscal ie
     where nf.empresa_id      = en_empresa_id
       and nf.dm_arm_nfe_terc = 0
       and nf.dm_st_proc      = 4 -- 4-autorizadas
       and nf.dm_ind_emit     = 1
       and to_number(to_char(trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)), 'rrrr')) = gt_row_gera_inf_rend_dirf.ano_calend
       and mf.id              = nf.modfiscal_id
       and mf.cod_mod         in ('99', '55', '65')
       and pe.id(+)           = nf.pessoa_id
       and ie.notafiscal_id   = nf.id
     order by nf.id, 
              pe.id;
  --
  cursor c_impitemnf(en_itemnf_id item_nota_fiscal.id%type) is
    select ii.tiporetimp_id,
           ti.cd cd_tipoimp,
           nvl(sum(nvl(ii.vl_base_calc, 0)), 0) vl_base_calc,
           nvl(sum(nvl(ii.vl_imp_trib, 0)), 0) vl_imp_retido
      from imp_itemnf ii, 
           tipo_imposto ti
     where ii.itemnf_id = en_itemnf_id
       and ii.dm_tipo   = 1 -- 0-imposto, 1-retenção
       and ti.id        = ii.tipoimp_id
       and ti.cd        in (4, 5, 11, 12) -- 4-PIS, 5-COFINS, 11-CSLL, 12-IRRF
     group by ii.tiporetimp_id, 
              ti.cd
     order by ii.tiporetimp_id, 
              ti.cd;
  */			  
  --
begin
  --
  vn_fase := 1;
  --
  vn_multorg_id := pk_csf.fkg_multorg_id_empresa(en_empresa_id => gt_row_gera_inf_rend_dirf.empresa_id);
  --
  for rec in c_emp loop
    exit when c_emp%notfound or(c_emp%notfound) is null;
    --
    vn_fase := 2;
    --
    -- Leitura do parametro de data para leitura da dos documentos para geração da DIRF	
	gn_dt_ref_imp_ret := pk_csf_api_dirf.fkg_dt_ref_imp_ret ( en_empresa_id => rec.empresa_id );
    --	
    for rec_pcc in c_pcc(rec.empresa_id) loop
      exit when c_pcc%notfound or(c_pcc%notfound) is null;
      --
      vn_fase := 2.1;
      --
      begin
        select max(tr.id)
          into vn_tiporetimp_id
          from tipo_ret_imp tr, 
               tipo_imposto ti
         where tr.cd         = rec_pcc.tiporetimp_cd
           and ti.id         = tr.tipoimp_id
           and ti.cd         in (4, 5, 11, 12, 14) -- 4-pis, 5-cofins, 11-csll, 12-irrf, 14-pcc
		   and tr.cd     not in ('2372','2484') -- #70522
           and tr.multorg_id = vn_multorg_id
           and tr.tipoimp_id = rec_pcc.tipoimp_id;
      exception
        when others then
          vn_tiporetimp_id := 0;
      end;
      --
      vn_fase := 2.2;
      --
      pkb_reg_valores(en_tiporetimp_id      => vn_tiporetimp_id,
                      en_pessoa_id          => rec_pcc.pessoa_id,
                      ed_dt_docto_pgto_vcto => rec_pcc.dt_docto_pgto_vcto,
                      en_ano                => rec_pcc.ano,
                      en_mes                => rec_pcc.mes,
                      en_vl_rendimento      => rec_pcc.vl_rendimento,
                      en_vl_imp_retido      => rec_pcc.vl_imp_retido,
                      en_vl_deducao         => 0);
      --
    end loop;
    --
    vn_fase := 3;
    --
    for rec_imp_ret in c_imp_ret(rec.empresa_id) loop
      exit when c_imp_ret%notfound or(c_imp_ret%notfound) is null;
      --
      vn_fase := 3.1;
      --
      pkb_reg_valores(en_tiporetimp_id      => rec_imp_ret.tiporetimp_id,
                      en_pessoa_id          => rec_imp_ret.pessoa_id,
                      ed_dt_docto_pgto_vcto => rec_imp_ret.dt_docto_pgto_vcto,
                      en_ano                => rec_imp_ret.ano,
                      en_mes                => rec_imp_ret.mes,
                      en_vl_rendimento      => rec_imp_ret.vl_rendimento,
                      en_vl_imp_retido      => rec_imp_ret.vl_imp_retido,
                      en_vl_deducao         => 0);
      --
    end loop;
    --
    vn_fase := 4;
    --
    for rec_imp_ded_dep in c_imp_ded_dep(rec.empresa_id) loop
      exit when c_imp_ded_dep%notfound or(c_imp_ded_dep%notfound) is null;
      --
      vn_fase := 4.1;
      --  
      pkb_reg_valores(en_tiporetimp_id      => rec_imp_ded_dep.tiporetimp_id,
                      en_pessoa_id          => rec_imp_ded_dep.pessoa_id,
                      ed_dt_docto_pgto_vcto => rec_imp_ded_dep.dt_docto_pgto_vcto,
                      en_ano                => rec_imp_ded_dep.ano,
                      en_mes                => rec_imp_ded_dep.mes,
                      en_vl_rendimento      => 0,
                      en_vl_imp_retido      => 0,
                      en_vl_deducao         => rec_imp_ded_dep.vl_deducao);
      --
    end loop;
    
    --
    vn_fase := 5;
    --
    /*for rec_itemnf in c_itemnf(rec.empresa_id) loop
      exit when c_itemnf%notfound or(c_itemnf%notfound) is null;
      --
      vn_fase    := 4.01;
      vv_zerar   := 'N';
      vn_fase    := 4.02;
      vn_vl_rend := 0;
      vn_fase    := 4.1;
      --
      for rec_impitemnf in c_impitemnf(rec_itemnf.itemnf_id) loop
        exit when c_impitemnf%notfound or(c_impitemnf%notfound) is null;
        --
        vn_fase := 4.2;
        --
        vv_cd := pk_csf_dirf.fkg_retorna_cd_imposto(rec_impitemnf.tiporetimp_id);
        --
        begin
          select max(tr.id)
            into vn_tiporetimp_id
            from tipo_ret_imp tr, 
                 tipo_imposto ti
           where tr.cd = vv_cd
             and ti.id = tr.tipoimp_id
             and ti.cd in (4, 5, 11); -- 4-pis, 5-cofins, 11-csll
        exception
          when others then
            vn_tiporetimp_id := rec_impitemnf.tiporetimp_id;
        end;
        --
        vn_fase := 4.3;
        --
        if nvl(vn_tiporetimp_id, 0) = 0 then
          -- não pertence aos impostos pis/cofins/csll
          vn_tiporetimp_id := rec_impitemnf.tiporetimp_id;
        end if;
        --
        vn_fase := 4.4;
        --
        if vv_zerar = 'S' and
           nvl(rec_impitemnf.cd_tipoimp, 0) in (4, 5, 11) then
          -- impostos pis/cofins/csll
          vn_vl_rend := 0;
        else
          vn_vl_rend := nvl(rec_impitemnf.vl_base_calc, 0);
        end if;
        --
        if nvl(vn_tiporetimp_id, 0) > 0 and
           nvl(rec_itemnf.pessoa_id, 0) > 0 then
          --
          vn_fase := 4.5;
          --
          pkb_reg_valores(en_tiporetimp_id      => vn_tiporetimp_id,
                          en_pessoa_id          => rec_itemnf.pessoa_id,
                          ed_dt_docto_pgto_vcto => rec_itemnf.dt_docto_pgto_vcto,
                          en_ano                => rec_itemnf.ano,
                          en_mes                => rec_itemnf.mes,
                          en_vl_rendimento      => nvl(vn_vl_rend, 0), -- rec_impitemnf.vl_base_calc
                          en_vl_imp_retido      => rec_impitemnf.vl_imp_retido,
                          en_vl_deducao         => 0);
          --
          if nvl(rec_impitemnf.cd_tipoimp, 0) in (4, 5, 11) then
            -- impostos pis/cofins/csll
            vv_zerar := 'S';
          end if;
          --
        else
          --
          vn_fase := 4.6;
          --
        end if;
        --
      end loop;
      --
    end loop;*/
    --
  end loop;
  --
exception
  when no_data_found then
    gt_row_gera_inf_rend_dirf := null;
  when others then
    raise_application_error(-20101, 'Erro na pk_gera_inf_rend_dirf.pkb_gera_ird_docto_fiscal - fase (' || vn_fase || '): ' || sqlerrm);
end pkb_gera_ird_docto_fiscal;
-------------------------------------------------------------------------------------------------------
--| Procedimento de geração dos dados
-------------------------------------------------------------------------------------------------------
procedure pkb_geracao ( en_gerainfrenddirf_id in gera_inf_rend_dirf.id%type )
is
   --
   vn_fase          number;
   vt_log_generico_ird  dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   pkb_dados_gera_inf_rend_dirf ( en_gerainfrenddirf_id => en_gerainfrenddirf_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_gera_inf_rend_dirf.id,0) > 0 then
      --
      vn_fase := 3;
      --
      if gt_row_gera_inf_rend_dirf.dm_situacao in (0) then -- Não Gerado
         --
         vt_bi_tab_csf_imp_ret.delete;
         --
         vn_fase := 4;
         --
         if gt_row_gera_inf_rend_dirf.dm_gera_docto_fiscal = 1 then -- Gera Documento Fiscal
            --
            vn_fase := 5;
            --
            pkb_gera_ird_docto_fiscal;
            --
         end if;
         --
         vn_fase := 6;
         --
         if gt_row_gera_inf_rend_dirf.dm_gera_folha_pgto = 1 then -- Gera Folha de Pagamento
            --
            vn_fase := 6.1;
            -- Não implementado
         end if;
         --
         vn_fase := 7;
         -- Cria os Informes de Rendimento da DIRF
         vt_log_generico_ird.delete;
         --
         vn_fase := 8;
         --
         begin
            delete from log_generico_ird lg
             where lg.obj_referencia = 'INF_REND_DIRF'
               and not exists (select ir.id
                                 from inf_rend_dirf ir
                                where ir.id = lg.referencia_id);
         exception
            when others then
               raise_application_error(-20101, 'Erro ao excluir log/inconsistência - pk_gera_inf_rend_dirf.pkb_geracao: '||sqlerrm);
         end;
         --
         vn_fase := 9;
         --
         pkb_criar_inf_rend_dirf( est_log_generico_ird => vt_log_generico_ird );
         --
         vn_fase := 10;
         --
         if nvl(vt_log_generico_ird.count,0) > 0 then -- ocorreram erros de integração
            --
            vn_fase := 11;
            update gera_inf_rend_dirf gi
               set gi.dm_situacao = 2 -- Erro na Geração
             where gi.id = en_gerainfrenddirf_id;
            --
         else
            --
            vn_fase := 12;
            update gera_inf_rend_dirf gi
               set gi.dm_situacao = 1 -- Gerado
             where gi.id = en_gerainfrenddirf_id;
            --
         end if;
         --
         vn_fase := 13;
         --
         commit;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      update gera_inf_rend_dirf gi
         set gi.dm_situacao = 2 -- Erro na Geração
       where gi.id = en_gerainfrenddirf_id;
      --
      commit;
      --
      raise_application_error(-20101, 'Erro na pk_gera_inf_rend_dirf.pkb_geracao (fase = '||vn_fase||'): '||sqlerrm);
end pkb_geracao;
-------------------------------------------------------------------------------------------------------
--| Procedimento de desfazer a geração
-------------------------------------------------------------------------------------------------------
procedure pkb_desfazer ( en_gerainfrenddirf_id in gera_inf_rend_dirf.id%type )
is
   --
   vn_fase              number;
   vt_log_generico_ird  dbms_sql.number_table;
   vn_inf_manual        number := 0;
   vn_pessoa_id         number;
   vv_cod_part          pessoa.cod_part%type;
   --
   cursor c_ird is
   select r.infrenddirf_id
     from r_gera_inf_rend_dirf r
    where r.gerainfrenddirf_id = en_gerainfrenddirf_id
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   pkb_dados_gera_inf_rend_dirf ( en_gerainfrenddirf_id => en_gerainfrenddirf_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_gera_inf_rend_dirf.id,0) > 0 then
      --
      vn_fase := 3;
      --
      if gt_row_gera_inf_rend_dirf.dm_situacao in (1,2) then -- 1-Gerado; 2-Erro na Geração
         --
         vn_fase := 4;
         --
         for rec in c_ird loop
            exit when c_ird%notfound or (c_ird%notfound) is null;
            -- excluir os "Informe de Rendimentos da DIRF" criados pela integração
            vn_fase := 5;
            --
            vt_log_generico_ird.delete;
            --
            pk_csf_api_dirf.pkb_excluir_inf_rend ( est_log_generico_ird  => vt_log_generico_ird
                                                 , en_infrenddirf_id     => rec.infrenddirf_id
                                                 );
            --
            vn_fase := 5.1;
            --
            delete from rel_jur_it_inf_rend_dirf rj
             where rj.reljurinfrenddirf_id in (select ri.id
                                                 from rel_jur_inf_rend_dirf ri
                                                where infrenddirf_id = rec.infrenddirf_id);
            --
            vn_fase := 5.2;
            --
            delete from rel_jur_inf_rend_dirf rj
             where rj.infrenddirf_id = rec.infrenddirf_id;
            --
            vn_fase := 5.3;
            --
            delete from rel_fis_inf_rend_dirf rf
             where rf.infrenddirf_id = rec.infrenddirf_id;
            --
            vn_fase := 5.4;
            --
            delete from r_gera_inf_rend_dirf
             where infrenddirf_id = rec.infrenddirf_id;
            --
            vn_fase := 5.5;
            --
            delete from r_loteintws_ird
             where infrenddirf_id = rec.infrenddirf_id;
            --
            vn_fase := 5.6;
            --
            delete from inf_rend_dirf
             where id = rec.infrenddirf_id;
            --
         end loop;
         --
         vn_fase := 6;
         -- altera situação da geração
         update gera_inf_rend_dirf gi
            set gi.dm_situacao = 0 -- Não gerado
          where gi.id = en_gerainfrenddirf_id;
         --
         vn_fase := 7;
         --
         commit;
         --
         vn_fase := 8;
         --
         begin
            select count(*)
              into vn_inf_manual
              from inf_rend_dirf ir
             where ir.empresa_id   = gt_row_gera_inf_rend_dirf.empresa_id
               and ir.ano_ref      = gt_row_gera_inf_rend_dirf.ano_ref
               and ir.ano_calend   = gt_row_gera_inf_rend_dirf.ano_calend
               and ir.dm_tipo_lcto = 5; -- Tipo de Lançamento Valores: 1-Integração; 2-Integração/Manual; 3-Automático; 4-Automático/Manual; 5-Manual
         exception
            when no_data_found then
               vn_inf_manual := 0;
         end;
         --
         vn_fase := 9;
         --
         if nvl(vn_inf_manual, 0) > 0 then
            --
            erro_de_sistema   := 35;
            --
            begin
               select pessoa_id
                 into vn_pessoa_id
                 from empresa
                where id = gt_row_gera_inf_rend_dirf.empresa_id;
            exception
               when others then
                  vn_pessoa_id := null;
            end;
            --
            vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => vn_pessoa_id );
            --
            gv_cabec_log      := 'Existe Informes de Rendimento incluídos manualmente para a mesma empresa '||
                                 vv_cod_part||', ano de referência '|| gt_row_gera_inf_rend_dirf.ano_ref||
                                 ' e ano calendário '||gt_row_gera_inf_rend_dirf.ano_calend||'. Esses informes não foram excluídos.';
            gv_obj_referencia := 'GERACAO_DIRF';
            gv_mensagem_log   := 'Desfazer DIRF do ano '||gt_row_gera_inf_rend_dirf.ano_ref;
            --
            declare
               vn_loggenerico_id  log_generico_ird.id%TYPE;
            begin
               --
               pk_csf_api_dirf.pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                                    , ev_mensagem          => gv_cabec_log
                                                    , ev_resumo            => gv_mensagem_log
                                                    , en_tipo_log          => erro_de_sistema
                                                    , en_referencia_id     => en_gerainfrenddirf_id
                                                    , ev_obj_referencia    => gv_obj_referencia
                                                    , en_empresa_id        => gt_row_gera_inf_rend_dirf.empresa_id);
               --
               -- Armazena o "loggenerico_id" na memória
               pk_csf_api_dirf.pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                                       , est_log_generico_ird => vt_log_generico_ird );
               --
            exception
               when others then
                  null;
            end;
            --
         end if;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_inf_rend_dirf.pkb_desfazer (fase = '||vn_fase||'): '||sqlerrm);
end pkb_desfazer;

-------------------------------------------------------------------------------------------------------

end pk_gera_inf_rend_dirf;
/
