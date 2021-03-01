create or replace package body csf_own.pk_ger_guia_pgto_imp is

  ----------------------------------------------------------------------------------------------------
  -- Procedimento Recuperação dos dados da Guia de Pagamento de Imposto 
  ----------------------------------------------------------------------------------------------------
  procedure pkb_rec_ger_guia_pgto_imp(en_gerguiapgtoimp_id in ger_guia_pgto_imp.id%type) is
  begin
    select *
      into gt_row_ger_guia_pgto_imp
      from ger_guia_pgto_imp
     where id = en_gerguiapgtoimp_id;
  exception
    when no_data_found then
      gt_row_ger_guia_pgto_imp := null;
    when others then
      raise_application_error(-20101, 'Erro na pk_ger_guia_pgto_imp.pkb_rec_ger_guia_pgto_imp: ' || sqlerrm);
  end pkb_rec_ger_guia_pgto_imp;

  -----------------------------------------------------------------------------------------------------
  -- Procedimento que valida as guias de Pgto de Importação
  -----------------------------------------------------------------------------------------------------
  procedure pkb_vld_guia_pgto_imp(est_log_generico_gpi in out nocopy dbms_sql.number_table) is
    --
    vn_fase number;
    vn_erro number;
    i       pls_integer;
    --
    cursor c_dados is
      select referencia_id, guiapgtoimp_id
        from r_guia_pgto_imp
       where gerguiapgtoimp_id = gt_row_ger_guia_pgto_imp.id
         and obj_referencia    = 'PGTO_IMP_RET';
    --
  begin
    --
    vn_fase := 1;
    --
    for rec in c_dados loop
      exit when c_dados%notfound or(c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_vld_amb_gpi.pkb_vld_guia_pgto_imp(en_guiapgtoimp_id => rec.guiapgtoimp_id,
                                           sn_erro           => vn_erro);
      --
      if nvl(vn_erro, 0) = 0 then
        --
        vn_fase := 3;
        --
        update guia_pgto_imp
           set dm_situacao = 1
         where id          = rec.guiapgtoimp_id;
        --
      else
        --
        update guia_pgto_imp
           set dm_situacao = 2
         where id          = rec.guiapgtoimp_id;
        --
        i := nvl(est_log_generico_gpi.count, 0) + 1;
        --
        est_log_generico_gpi(i) := rec.referencia_id;
        --
      end if;
      --
      -- Ajustar as referencias para geração de guia de pagamento
      pk_csf_api_gpi.gn_referencia_id  := gt_row_ger_guia_pgto_imp.id;
      pk_csf_api_gpi.gv_obj_referencia := 'GER_GUIA_PGTO_IMP';
      --
      commit;
      --
    end loop;
    --
  exception
    when others then
      --
      pk_csf_api_gpi.gv_resumo := 'Erro na package pk_ger_guia_pgto_imp.pkb_vld_guia_pgto_imp fase (' || vn_fase || ') Erro: ' || sqlerrm;
      --
      declare
        vn_loggenerico_id number;
      begin
        --
        pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                            ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                            ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                            en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                            en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                            ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                            en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
        --
      end;
  end pkb_vld_guia_pgto_imp;

  -----------------------------------------------------------------------------------------------------
  -- Procedimento que inicia os arrays
  -----------------------------------------------------------------------------------------------------
  procedure pkb_ini_arrays(est_log_generico_gpi    in out nocopy dbms_sql.number_table,
                           en_indx1                in number,
                           en_indx2                in number,
                           en_indx3                in number,
                           en_pessoa_id            in pessoa.id%type,
                           en_tipoimposto_id       in tipo_imposto.id%type,
                           en_tiporetimp_id        in tipo_ret_imp.id%type,
                           en_tiporetimpreceita_id in tipo_ret_imp_receita.id%type,
                           ed_dt_ref               in guia_pgto_imp.dt_ref%type,
                           ed_dt_vcto              in guia_pgto_imp.dt_vcto%type,
                           en_usuario_id           in neo_usuario.id%type,
                           en_retem                in number) is
    --
    vn_fase     number;
    vn_vl_princ guia_pgto_imp.VL_PRINC%type;
    vn_vl_multa guia_pgto_imp.VL_MULTA%type;
    vn_vl_juro  guia_pgto_imp.VL_JURO%type;
    vn_vl_outro guia_pgto_imp.VL_OUTRO%type;
    vn_vl_total guia_pgto_imp.VL_TOTAL%type;
    --
  begin
    --
    vn_fase := 1;
    --
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).empresa_id           := gt_row_ger_guia_pgto_imp.empresa_id;
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).pessoa_id            := en_pessoa_id;
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).usuario_id           := en_usuario_id;
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tipoimposto_id       := en_tipoimposto_id;
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tiporetimp_id        := en_tiporetimp_id;
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tiporetimpreceita_id := en_tiporetimpreceita_id;
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).dt_vcto              := ed_dt_vcto;
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).dt_ref               := ed_dt_ref;
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).dm_situacao          := 0;
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).nro_via_impressa     := 1;
  
    --
    if pk_csf.fkg_Tipo_Imposto_cd(en_tipoimp_id => vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tipoimposto_id) = 13 then -- INSS
      --
      vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).dm_tipo := 1; -- GPS
      --
    else
      --
      vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).dm_tipo := 2; -- 2 DARF
      --
    end if;
    --
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).dm_origem := 1; -- Imposto Retido
    --
    vn_fase := 2;
    --
    -- Verificar se o tipo de retenção de imposto for é retido para a empresa ou o participante.
    if en_retem = 1 then
      --
      begin
        select pessoa_id
          into vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).pessoa_id
          from empresa
         where id = gt_row_ger_guia_pgto_imp.empresa_id;
      exception
        when no_data_found then
          --
          vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).pessoa_id := null;
          --
          pk_csf_api_gpi.gv_resumo := 'Não foi possivel atribuir o código do participante da empresa na guia do pagamento (' ||
                                      'Cód Imposto: ' || pk_csf.fkg_Tipo_Imposto_cd(vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tipoimposto_id) ||
                                      ' e Tipo de Retenção de Imposto: ' || pk_csf.fkg_tipo_ret_imp_cd(vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tiporetimp_id) ||
                                      ' e com o cód. da Receita: ' || pk_csf_gpi.fkg_tiporetimpreceita_cd(vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tiporetimpreceita_id) ||
                                      ' para a data de vencimento do dia: ' || vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).dt_vcto || '), favor verificar.';
          --
          declare
            vn_loggenerico_id number;
          begin
            --
            pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                                ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                                ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                                en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                                en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                                ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia);
            --
          end;
      end;
      --
    end if;
    --
    vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).id := pk_csf_gpi.fkg_guiapgtoimp_id(en_empresa_id           => vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).empresa_id,
                                                                                                   en_pessoa_id            => vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).pessoa_id,
                                                                                                   en_tipoimposto_id       => vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tipoimposto_id,
                                                                                                   en_tiporetimp_id        => vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tiporetimp_id,
                                                                                                   en_tiporetimpreceita_id => vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).tiporetimpreceita_id,
                                                                                                   ed_dt_vcto              => vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).dt_vcto);
    --
    if nvl(vt_tri_tab_csf_guia_pgto_imp(en_indx1) (en_indx2)(en_indx3).id, 0) <= 0 then
      --
      select guiapgtoimp_seq.nextval
        into vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).id
        from dual;
      --
    else
      --
      vn_vl_princ := null;
      vn_vl_multa := null;
      vn_vl_juro  := null;
      vn_vl_outro := null;
      vn_vl_total := null;
      --
      begin
        --
        select pgi.vl_princ,
               pgi.vl_multa,
               pgi.vl_juro,
               pgi.vl_outro,
               pgi.vl_total
          into vn_vl_princ,
               vn_vl_multa,
               vn_vl_juro,
               vn_vl_outro,
               vn_vl_total
          from guia_pgto_imp pgi
         where id = vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).id;
        --
      exception
        when others then
          vn_vl_princ := null;
          vn_vl_multa := null;
          vn_vl_juro  := null;
          vn_vl_outro := null;
          vn_vl_total := null;
      end;
      --
      vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_princ := nvl(vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_princ, 0) + nvl(vn_vl_princ, 0);
      vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_multa := nvl(vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_multa, 0) + nvl(vn_vl_multa, 0);
      vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_juro  := nvl(vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_juro, 0) + nvl(vn_vl_juro, 0);
      vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_outro := nvl(vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_outro, 0) + nvl(vn_vl_outro, 0);
      vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_total := nvl(vt_tri_tab_csf_guia_pgto_imp(en_indx1)(en_indx2)(en_indx3).vl_total, 0) + nvl(vn_vl_princ, 0) + nvl(vn_vl_multa, 0) + nvl(vn_vl_juro, 0);
      --
    end if;
    --
  exception
    when others then
      --
      pk_csf_api_gpi.gv_resumo := 'Erro na package pk_ger_guia_pgto_imp.pkb_ini_arrays fase (' || vn_fase || ') Erro: ' || sqlerrm;
      --
      declare
        vn_loggenerico_id number;
      begin
        --
        pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                            ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                            ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                            en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                            en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                            ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                            en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
        --
      end;
      --
  end pkb_ini_arrays;

  -----------------------------------------------------------------------------------------------------
  -- Procedimento para montar a guia de Pagamento de Imposto
  -----------------------------------------------------------------------------------------------------
  procedure pkb_monta_guia_pgto_imp(est_log_generico_gpi in out nocopy dbms_sql.number_table,
                                    en_usuario_id        in neo_usuario.id%type) is
    --
    vn_indx1     number;
    vn_indx2     number;
    vn_indx3     number;
    vn_indx_det  number;
    vn_indx2_det number;
    --
    vn_fase             number;
    vn_teste            number;
    vb_achou            boolean;
    vn_loggenerico_id   log_generico.id%type;
    vt_log_generico_gpi dbms_sql.number_table;
    --
    cursor c_dados is
      select pi.id pgtoimpret_id
           , pi.vl_principal
           , pi.vl_multa
           , pi.vl_juros
           , pi.vl_pgto
           , pi.vl_deducao
           , pi.pessoa_id
           , to_date(pdgi.dia_vcto||'/'||to_char(add_months(pi.dt_docto,1), 'mm/yyyy'), 'dd/mm/yyyy') dt_vcto --to_date(pi.dt_vcto, 'dd/mm/yyyy') dt_vcto
           , last_day(pi.dt_docto)             dt_ref --, pi.dt_docto                       dt_ref
           , pi.tipoimp_id
           , pi.tiporetimp_id
           , pi.tiporetimpreceita_id
           , tri.dm_quem_retem
           , pi.empresa_id
           , pdgi.empresa_id_guia
           , pdgi.pessoa_id_sefaz
           , pdgi.planoconta_id
        from PGTO_IMP_RET          pi, 
             TIPO_IMPOSTO          ti, 
             TIPO_RET_IMP         tri,
             PARAM_GUIA_PGTO      pgp,
             PARAM_DET_GUIA_IMP  pdgi,
             EMPRESA                e
             --
       where pi.empresa_id             = gt_row_ger_guia_pgto_imp.empresa_id
         and pi.tiporetimp_id          = tri.id
         and ti.id                     = pi.tipoimp_id
         and pgp.empresa_id            = pi.empresa_id
         and pdgi.paramguiapgto_id     = pgp.id
         and pdgi.tipoimp_id           = ti.id
         and pdgi.tiporetimpreceita_id = pi.tiporetimpreceita_id
         and pdgi.tiporetimp_id        = pi.tiporetimp_id
         and pdgi.dm_origem            = 1 -- Imposto Retido
         and e.id                      = pi.empresa_id
         and ti.cd                     in (14, 12, 13, 4, 5, 11)
         and nvl(pi.dt_docto, pi.dt_vcto) between gt_row_ger_guia_pgto_imp.dt_ini 
                                              and gt_row_ger_guia_pgto_imp.dt_fin
UNION ALL -----------------------------------------------------------------------
      select pi.id pgtoimpret_id
           , pi.vl_principal
           , pi.vl_multa
           , pi.vl_juros
           , pi.vl_pgto
           , pi.vl_deducao
           , pi.pessoa_id
           , to_date(pdgi.dia_vcto||'/'||to_char(add_months(pi.dt_docto,1), 'mm/yyyy'), 'dd/mm/yyyy') dt_vcto --to_date(pi.dt_vcto, 'dd/mm/yyyy') dt_vcto
           , last_day(pi.dt_docto)             dt_ref --, pi.dt_docto                       dt_ref
           , pi.tipoimp_id
           , pi.tiporetimp_id
           , pi.tiporetimpreceita_id
           , tri.dm_quem_retem
           , pi.empresa_id
           , pdgi.empresa_id_guia
           , pdgi.pessoa_id_sefaz
           , pdgi.planoconta_id
        from PGTO_IMP_RET          pi, 
             TIPO_IMPOSTO          ti, 
             TIPO_RET_IMP         tri,
             PARAM_GUIA_PGTO      pgp,
             PARAM_DET_GUIA_IMP  pdgi,
             EMPRESA                e
             --
       where pi.empresa_id             = gt_row_ger_guia_pgto_imp.empresa_id
         and pi.tiporetimp_id          = tri.id
         and ti.id                     = pi.tipoimp_id
         and pgp.empresa_id            = pi.empresa_id
         and pdgi.paramguiapgto_id     = pgp.id
         and pdgi.tipoimp_id           = ti.id
         and pdgi.tiporetimp_id        = pi.tiporetimp_id
         and pdgi.dm_origem            = 1 -- Imposto Retido
         and e.id                      = pi.empresa_id
         and ti.cd                     in (14, 12, 13, 4, 5, 11)
         and nvl(pi.dt_docto, pi.dt_vcto) between gt_row_ger_guia_pgto_imp.dt_ini 
                                              and gt_row_ger_guia_pgto_imp.dt_fin
         and not exists (
            select 1
              from PGTO_IMP_RET          pi, 
                   TIPO_IMPOSTO          ti, 
                   TIPO_RET_IMP         tri,
                   PARAM_GUIA_PGTO      pgp,
                   PARAM_DET_GUIA_IMP  pdgi,
                   EMPRESA                e
                   --
             where pi.empresa_id             = gt_row_ger_guia_pgto_imp.empresa_id
               and pi.tiporetimp_id          = tri.id
               and ti.id                     = pi.tipoimp_id
               and pgp.empresa_id            = pi.empresa_id
               and pdgi.paramguiapgto_id     = pgp.id
               and pdgi.tipoimp_id           = ti.id
               and pdgi.tiporetimpreceita_id = pi.tiporetimpreceita_id
               and pdgi.tiporetimp_id        = pi.tiporetimp_id
               and pdgi.dm_origem            = 1 -- Imposto Retido
               and e.id                      = pi.empresa_id
               and ti.cd                     in (14, 12, 13, 4, 5, 11)
               and nvl(pi.dt_docto, pi.dt_vcto) between gt_row_ger_guia_pgto_imp.dt_ini 
                                                    and gt_row_ger_guia_pgto_imp.dt_fin)
UNION ALL -------------------------------------------------------------------------------------
      select pi.id pgtoimpret_id
           , pi.vl_principal
           , pi.vl_multa
           , pi.vl_juros
           , pi.vl_pgto
           , pi.vl_deducao
           , pi.pessoa_id
           , to_date(pdgi.dia_vcto||'/'||to_char(add_months(pi.dt_docto,1), 'mm/yyyy'), 'dd/mm/yyyy') dt_vcto --to_date(pi.dt_vcto, 'dd/mm/yyyy') dt_vcto
           , last_day(pi.dt_docto)             dt_ref --, pi.dt_docto                       dt_ref
           , pi.tipoimp_id
           , pi.tiporetimp_id
           , pi.tiporetimpreceita_id
           , tri.dm_quem_retem
           , pi.empresa_id
           , pdgi.empresa_id_guia
           , pdgi.pessoa_id_sefaz
           , pdgi.planoconta_id
        from PGTO_IMP_RET          pi, 
             TIPO_IMPOSTO          ti, 
             TIPO_RET_IMP         tri,
             PARAM_GUIA_PGTO      pgp,
             PARAM_DET_GUIA_IMP  pdgi,
             EMPRESA                e
             --
       where pi.empresa_id             = gt_row_ger_guia_pgto_imp.empresa_id
         and pi.tiporetimp_id          = tri.id
         and ti.id                     = pi.tipoimp_id
         and pgp.empresa_id            = pi.empresa_id
         and pdgi.paramguiapgto_id     = pgp.id
         and pdgi.tipoimp_id           = ti.id
         and pdgi.dm_origem            = 1 -- Imposto Retido
         and e.id                      = pi.empresa_id
         and ti.cd                     in (14, 12, 13, 4, 5, 11)
         and nvl(pi.dt_docto, pi.dt_vcto) between gt_row_ger_guia_pgto_imp.dt_ini 
                                              and gt_row_ger_guia_pgto_imp.dt_fin
         and not exists(
            select 1
              from PGTO_IMP_RET          pi, 
                   TIPO_IMPOSTO          ti, 
                   TIPO_RET_IMP         tri,
                   PARAM_GUIA_PGTO      pgp,
                   PARAM_DET_GUIA_IMP  pdgi,
                   EMPRESA                e
                   --
             where pi.empresa_id             = gt_row_ger_guia_pgto_imp.empresa_id
               and pi.tiporetimp_id          = tri.id
               and ti.id                     = pi.tipoimp_id
               and pgp.empresa_id            = pi.empresa_id
               and pdgi.paramguiapgto_id     = pgp.id
               and pdgi.tipoimp_id           = ti.id
               and pdgi.tiporetimpreceita_id = pi.tiporetimpreceita_id
               and pdgi.tiporetimp_id        = pi.tiporetimp_id
               and pdgi.dm_origem            = 1 -- Imposto Retido
               and e.id                      = pi.empresa_id
               and ti.cd                     in (14, 12, 13, 4, 5, 11)
               and nvl(pi.dt_docto, pi.dt_vcto) between gt_row_ger_guia_pgto_imp.dt_ini 
                                                    and gt_row_ger_guia_pgto_imp.dt_fin
      UNION ALL -----------------------------------------------------------------------
            select 1
              from PGTO_IMP_RET          pi, 
                   TIPO_IMPOSTO          ti, 
                   TIPO_RET_IMP         tri,
                   PARAM_GUIA_PGTO      pgp,
                   PARAM_DET_GUIA_IMP  pdgi,
                   EMPRESA                e
                   --
             where pi.empresa_id             = gt_row_ger_guia_pgto_imp.empresa_id
               and pi.tiporetimp_id          = tri.id
               and ti.id                     = pi.tipoimp_id
               and pgp.empresa_id            = pi.empresa_id
               and pdgi.paramguiapgto_id     = pgp.id
               and pdgi.tipoimp_id           = ti.id
               and pdgi.tiporetimp_id        = pi.tiporetimp_id
               and pdgi.dm_origem            = 1 -- Imposto Retido
               and e.id                      = pi.empresa_id
               and ti.cd                     in (14, 12, 13, 4, 5, 11)
               and nvl(pi.dt_docto, pi.dt_vcto) between gt_row_ger_guia_pgto_imp.dt_ini 
                                                    and gt_row_ger_guia_pgto_imp.dt_fin
               and not exists (
                  select 1
                    from PGTO_IMP_RET          pi, 
                         TIPO_IMPOSTO          ti, 
                         TIPO_RET_IMP         tri,
                         PARAM_GUIA_PGTO      pgp,
                         PARAM_DET_GUIA_IMP  pdgi,
                         EMPRESA                e
                         --
                   where pi.empresa_id             = gt_row_ger_guia_pgto_imp.empresa_id
                     and pi.tiporetimp_id          = tri.id
                     and ti.id                     = pi.tipoimp_id
                     and pgp.empresa_id            = pi.empresa_id
                     and pdgi.paramguiapgto_id     = pgp.id
                     and pdgi.tipoimp_id           = ti.id
                     and pdgi.tiporetimpreceita_id = pi.tiporetimpreceita_id
                     and pdgi.tiporetimp_id        = pi.tiporetimp_id
                     and pdgi.dm_origem            = 1 -- Imposto Retido
                     and e.id                      = pi.empresa_id
                     and ti.cd                     in (14, 12, 13, 4, 5, 11)
                     and nvl(pi.dt_docto, pi.dt_vcto) between gt_row_ger_guia_pgto_imp.dt_ini 
                                                          and gt_row_ger_guia_pgto_imp.dt_fin)) ;                                           
    
  begin
    --
    vn_fase := 1;
    --
    vt_tri_tab_csf_guia_pgto_imp.delete;
    --
    vn_fase := 2;
    --
    for rec in c_dados loop
      exit when c_dados%notfound or(c_dados%notfound) is null;
      --
      vn_fase := 3;
      --
      if nvl(rec.dm_quem_retem, 0) = 1 then
        --
        vn_fase := 3.1;
        -- Caso o tipo de Imposto Retido for para a Empresa
        -- Deve ser atribuido o valor para o array de empresa.
        begin
          --
          vn_fase := 3.2;
          --
          select pessoa_id
            into vn_indx1
            from empresa
           where id = rec.empresa_id;
          --
        exception
          when no_data_found then
            --
            pk_csf_api_gpi.gv_resumo := 'Não foi possivel atribuir o código do participante da empresa na guia do pagamento (' ||
                                        'Cód Imposto: ' || pk_csf.fkg_Tipo_Imposto_cd(rec.tipoimp_id) ||
                                        ' e Tipo de Retenção de Imposto: ' || pk_csf.fkg_tipo_ret_imp_cd(rec.tiporetimp_id) ||
                                        ' e com o cód. da Receita: ' || pk_csf_gpi.fkg_tiporetimpreceita_cd(rec.tiporetimpreceita_id) ||
                                        ' para a data de vencimento do dia: ' || to_date(rec.dt_vcto, 'dd/mm/yyyy') || '), favor verificar.';
            --
            declare
              vn_loggenerico_id number;
            begin
              --
              pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                                  ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                                  ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                                  en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                                  en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                                  ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia);
              --
            end;
            --
            raise_application_error(-20101, pk_csf_api_gpi.gv_resumo);
            --
        end;
        --
      else
        vn_indx1 := rec.pessoa_id;
      end if;
      --
      vn_indx2 := rec.tipoimp_id || rec.tiporetimp_id || rec.tiporetimpreceita_id;
      vn_indx3 := to_char(rec.dt_vcto, 'ddmmyyyy') || rec.dm_quem_retem;
      --
      vb_achou := null;
      --
      begin
        vb_achou := vt_tri_tab_csf_guia_pgto_imp.exists(vn_indx1);
      exception
        when others then
          vb_achou := false;
      end;
      --
      vn_fase := 3.2;
      --
      -- O Array será indexado por tomadores e por prestadores. Primeiro será identificado
      -- se ja existe index por tomador caso ja exista verificar por prestador
      if not vb_achou then
        --
        vn_fase := 4;
        --
        pkb_ini_arrays(est_log_generico_gpi    => est_log_generico_gpi,
                       en_indx1                => vn_indx1,
                       en_indx2                => vn_indx2,
                       en_indx3                => vn_indx3,
                       en_pessoa_id            => rec.pessoa_id,
                       en_tipoimposto_id       => rec.tipoimp_id,
                       en_tiporetimp_id        => rec.tiporetimp_id,
                       en_tiporetimpreceita_id => rec.tiporetimpreceita_id,
                       ed_dt_ref               => rec.dt_ref,
                       ed_dt_vcto              => rec.dt_vcto,
                       en_usuario_id           => en_usuario_id,
                       en_retem                => rec.dm_quem_retem);
      else
        --
        vb_achou := null;
        --
        begin
          vb_achou := vt_tri_tab_csf_guia_pgto_imp(vn_indx1).exists(vn_indx2);
        exception
          when others then
            vb_achou := false;
        end;
        --
        vn_fase := 5;
        --
        if not vb_achou then
          --
          vn_fase := 5.2;
          --
          pkb_ini_arrays(est_log_generico_gpi    => est_log_generico_gpi,
                         en_indx1                => vn_indx1,
                         en_indx2                => vn_indx2,
                         en_indx3                => vn_indx3,
                         en_pessoa_id            => rec.pessoa_id,
                         en_tipoimposto_id       => rec.tipoimp_id,
                         en_tiporetimp_id        => rec.tiporetimp_id,
                         en_tiporetimpreceita_id => rec.tiporetimpreceita_id,
                         ed_dt_ref               => rec.dt_ref,
                         ed_dt_vcto              => rec.dt_vcto,
                         en_usuario_id           => en_usuario_id,
                         en_retem                => rec.dm_quem_retem);
          --
        else
          --
          vn_fase := 6;
          --
          vb_achou := null;
          --
          begin
            vb_achou := vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2).exists(vn_indx3);
          exception
            when others then
              vb_achou := false;
          end;
          --
          vn_fase := 7;
          --
          if not vb_achou then
            --
            vn_fase := 8;
            --
            pkb_ini_arrays(est_log_generico_gpi    => est_log_generico_gpi,
                           en_indx1                => vn_indx1,
                           en_indx2                => vn_indx2,
                           en_indx3                => vn_indx3,
                           en_pessoa_id            => rec.pessoa_id,
                           en_tipoimposto_id       => rec.tipoimp_id,
                           en_tiporetimp_id        => rec.tiporetimp_id,
                           en_tiporetimpreceita_id => rec.tiporetimpreceita_id,
                           ed_dt_ref               => rec.dt_ref,
                           ed_dt_vcto              => rec.dt_vcto,
                           en_usuario_id           => en_usuario_id,
                           en_retem                => rec.dm_quem_retem);
            --
          end if;
          --
        end if;
        --
      end if;
      --
      vn_fase := 9;
      --
      -- Recuperar os valores de pgto de Impostos Retidos
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_princ := nvl(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_princ, 0) + nvl(rec.vl_principal, 0);
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_multa := nvl(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_multa, 0) + nvl(rec.vl_multa, 0);
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_juro  := nvl(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_juro, 0) + nvl(rec.vl_juros, 0);
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_outro := 0;
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_total := nvl(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_total, 0) + nvl(rec.vl_principal, 0) + nvl(rec.vl_multa, 0) + nvl(rec.vl_juros, 0);
      -- NOVOS CAMPOS --
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).pessoa_id_sefaz   := rec.pessoa_id_sefaz;
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).nro_tit_financ    := null;
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_alteracao	     := sysdate;
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dm_ret_erp        := case pk_csf.fkg_parametro_geral_sistema(pk_csf.fkg_multorg_id_empresa(rec.empresa_id_guia), rec.empresa_id_guia, 'GUIA_PGTO', 'RET_ERP', 'LIBERA_AUTOM_GUIA_ERP') when '1' then 0 when '0' then 6 end;
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).id_erp            := null;
      vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).planoconta_id     := rec.planoconta_id;      
      --
      vn_fase := 9.1;
      --
      vn_indx_det := null;
      vn_indx_det := vt_tri_tab_csf_guia_pgto_imp(vn_indx1) (vn_indx2)(vn_indx3).id;
      --
      vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(rec.pgtoimpret_id).guiapgtoimp_id    := vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).id;
      vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(rec.pgtoimpret_id).gerguiapgtoimp_id := gt_row_ger_guia_pgto_imp.id;
      vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(rec.pgtoimpret_id).obj_referencia    := 'PGTO_IMP_RET';
      vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(rec.pgtoimpret_id).referencia_id     := rec.pgtoimpret_id;
      --
    end loop;
    --
    vn_fase := 10;
    --
    --| Gravar as Guias de Pagamentos de Impostos
    vn_indx1 := nvl(vt_tri_tab_csf_guia_pgto_imp.first, 0);
    --
    vn_fase := 11;
    --
    loop
      --
      vn_fase := 11.1;
      --
      if nvl(vn_indx1, 0) = 0 then
        exit;
      end if;
      --
      vn_indx2 := nvl(vt_tri_tab_csf_guia_pgto_imp(vn_indx1).first, 0); 
      --
      vn_fase := 12;
      --
      loop
        --
        vn_fase := 12;
        --
        if nvl(vn_indx2, 0) = 0 then
          exit;
        end if;
        --
        vn_fase := 13;
        --
        vn_indx3 := nvl(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2).first, 0);
        --
        vn_fase := 13.1;
        --
        loop
          --
          vn_fase := 14;
          --
          if nvl(vn_indx3, -1) < 0 then
            exit;
          end if;
          --
          vn_fase := 15;
          --
          vn_teste := vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_princ;
          --
          null;
          --
          vn_teste := vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_total;
          --
          null;
          --
          vn_teste := vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tipoimposto_id;
          --
          null;
          --
          if nvl(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_princ, 0) > 0 and
             nvl(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_total, 0) > 0 and
             nvl(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tipoimposto_id, 0) > 0 and
             trim(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_vcto) is not null then
            --
            vn_fase := 16;
            --
            if pk_csf_gpi.fkg_exist_guiapgtoimp(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).id) = false then
              --
              vn_fase := 17;
              --
              begin
                --
                insert into guia_pgto_imp
                  (id,
                   empresa_id,
                   usuario_id,
                   dm_situacao,
                   tipoimposto_id,
                   tiporetimp_id,
                   tiporetimpreceita_id,
                   pessoa_id,
                   dm_tipo,
                   dm_origem,
                   nro_via_impressa,
                   dt_ref,
                   dt_vcto,
                   vl_princ,
                   vl_multa,
                   vl_juro,
                   vl_outro,
                   vl_total,
                   obs,
                   pessoa_id_sefaz,  
                   nro_tit_financ,   
                   dt_alteracao,     
                   dm_ret_erp,       
                   id_erp,           
                   planoconta_id                       
                   )
                values
                  (vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).id,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).empresa_id,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).usuario_id,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dm_situacao,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tipoimposto_id,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tiporetimp_id,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tiporetimpreceita_id,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).pessoa_id,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dm_tipo,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dm_origem,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).nro_via_impressa,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_ref,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_vcto,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_princ,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_multa,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_juro,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_outro,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_total,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).obs,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).pessoa_id_sefaz,
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).nro_tit_financ, 
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_alteracao,   
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dm_ret_erp,     
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).id_erp,         
                   vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).planoconta_id   
                   );
                --
              exception
                when others then
                  --
                  pk_csf_api_gpi.gv_resumo := 'Erro ao inserir o registro de Guia de Pagamento de Imposto, Cód Imposto: ' || pk_csf.fkg_Tipo_Imposto_cd(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tipoimposto_id) ||
                                              ' e Tipo de Retenção de Imposto: ' || pk_csf.fkg_tipo_ret_imp_cd(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tiporetimp_id) ||
                                              ' e com o cód. da Receita: ' || pk_csf_gpi.fkg_tiporetimpreceita_cd(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tiporetimpreceita_id) ||
                                              ' para a data de vencimento do dia: ' || vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_vcto || '. Erro: ' || sqlerrm;
                  --
                  pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                                      ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                                      ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                                      en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                                      en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                                      ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                                      en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
                  --
                  goto sair_pgto;
                  --
              end;
              --
              vn_fase := 19;
              --
              vn_indx_det := vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).id;
              --
              vn_indx2_det := nvl(vt_bi_tab_r_guia_pgto_imp(vn_indx_det).first, 0);
              --
              loop
                --
                vn_fase := 20;
                --
                select rguiapgtoimp_seq.nextval
                  into vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(vn_indx2_det).id
                  from dual;
                --
                insert into r_guia_pgto_imp
                  (id,
                   guiapgtoimp_id,
                   gerguiapgtoimp_id,
                   obj_referencia,
                   referencia_id)
                values
                  (vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(vn_indx2_det).id,
                   vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(vn_indx2_det).guiapgtoimp_id,
                   vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(vn_indx2_det).gerguiapgtoimp_id,
                   vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(vn_indx2_det).obj_referencia,
                   vt_bi_tab_r_guia_pgto_imp(vn_indx_det)(vn_indx2_det).referencia_id);
                --
                if vn_indx2_det = vt_bi_tab_r_guia_pgto_imp(vn_indx_det).last then
                  exit;
                else
                  vn_indx2_det := vt_bi_tab_r_guia_pgto_imp(vn_indx_det).next(vn_indx2_det);
                end if;
                --
              end loop;
              --
            else
              --
              update guia_pgto_imp
                 set empresa_id           = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).empresa_id,
                     usuario_id           = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).usuario_id,
                     dm_situacao          = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dm_situacao,
                     tipoimposto_id       = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tipoimposto_id,
                     tiporetimp_id        = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tiporetimp_id,
                     tiporetimpreceita_id = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tiporetimpreceita_id,
                     pessoa_id            = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).pessoa_id,
                     dm_tipo              = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dm_tipo,
                     dm_origem            = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dm_origem,
                     nro_via_impressa     = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).nro_via_impressa,
                     dt_ref               = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_ref,
                     dt_vcto              = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_vcto,
                     vl_princ             = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_princ,
                     vl_multa             = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_multa,
                     vl_juro              = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_juro,
                     vl_outro             = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_outro,
                     vl_total             = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).vl_total,
                     obs                  = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).obs,
                     pessoa_id_sefaz      = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).pessoa_id_sefaz,
                     nro_tit_financ       = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).nro_tit_financ, 
                     dt_alteracao         = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_alteracao,   
                     dm_ret_erp           = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dm_ret_erp,     
                     id_erp               = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).id_erp,         
                     planoconta_id        = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).planoconta_id  
               where id = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).id;
              --
            end if;
            --
            commit;
            --
          else
            --
            pk_csf_api_gpi.gv_resumo := 'Inconsistência nos dados da guia de pagamento para o Imposto: ' || pk_csf.fkg_Tipo_Imposto_cd(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tipoimposto_id) ||
                                        ' e Tipo de Retenção de Imposto: ' || pk_csf.fkg_tipo_ret_imp_cd(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tiporetimp_id) ||
                                        ' e com o cód. da Receita: ' || pk_csf_gpi.fkg_tiporetimpreceita_cd(vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).tiporetimpreceita_id) ||
                                        ' para a data de vencimento do dia: ' || vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2)(vn_indx3).dt_vcto || '.';
            --
            pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                                ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                                ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                                en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                                en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                                ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                                en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
            --
          end if;
          --
          vn_fase := 23;
          --
          <<sair_pgto>>
          --
          if vn_indx3 = vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2).last then
            exit;
          else
            vn_indx3 := vt_tri_tab_csf_guia_pgto_imp(vn_indx1)(vn_indx2).next(vn_indx3);
          end if;
          --
        end loop;
        --
        if vn_indx2 = vt_tri_tab_csf_guia_pgto_imp(vn_indx1).last then
          exit;
        else
          vn_indx2 := vt_tri_tab_csf_guia_pgto_imp(vn_indx1).next(vn_indx2);
        end if;
        --
      end loop;
      --
      vn_fase := 24;
      --
      if vn_indx1 = vt_tri_tab_csf_guia_pgto_imp.last then
        exit;
      else
        vn_indx1 := vt_tri_tab_csf_guia_pgto_imp.next(vn_indx1);
      end if;
      --
    end loop;
    --
  exception
    when others then
      --
      pk_csf_api_gpi.gv_resumo := 'Erro na package pk_ger_guia_pgto_imp.pkb_monta_guia_pgto_imp fase (' || vn_fase || ') Erro: ' || sqlerrm;
      --
      pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                          ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                          ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                          en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                          en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                          ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                          en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
      --
  end pkb_monta_guia_pgto_imp;
  
  ----------------------------------------------------------------------------------------------------
  -- Procedimento que verifica se gerou algum registro
  ----------------------------------------------------------------------------------------------------
  function fkb_verif_gerou(en_gerguiapgtoimp_id in ger_guia_pgto_imp.id%type)
    return number is
    --
    vn_fase   number := null;
    vn_existe number;
    --
  begin
    --
    vn_fase   := 1;
    vn_existe := 0;
    --
    if nvl(en_gerguiapgtoimp_id, 0) > 0 then
      --
      vn_fase := 2;
      --
      begin
        select distinct 1
          into vn_existe
          from r_guia_pgto_imp
         where gerguiapgtoimp_id = en_gerguiapgtoimp_id;
      exception
        when others then
          vn_existe := 0;
      end;
      --
      vn_fase := 3;
      --
    end if;
    --
    return vn_existe;
    --
  exception
    when others then
      --
      declare
        vn_loggenerico_id log_generico_gpi.id%type;
      begin
        --
        pk_csf_api_gpi.gv_resumo := 'Erro na package pk_ger_guia_pgto_imp.pkb_verif_gerou fase (' || vn_fase || ') Erro: ' || sqlerrm;
        --
        pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                            ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                            ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                            en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                            en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                            ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                            en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
        --
      end;
      --
  end fkb_verif_gerou;

  ----------------------------------------------------------------------------------------------------
  -- Procedimento de Geração de Guia de Pagamento de Imposto
  ----------------------------------------------------------------------------------------------------
  procedure pkb_gerar(en_gerguiapgtoimp_id in ger_guia_pgto_imp.id%type,
                      en_usuario_id        in neo_usuario.id%type) is
    --
    vn_fase             number;
    vn_loggenerico_id   log_generico.id%type;
    vt_log_generico_gpi dbms_sql.number_table;
    --
  begin
    --
    vn_fase := 1;
    --
    if nvl(en_gerguiapgtoimp_id, 0) > 0 then
      --
      vn_fase := 2;
      --
      -- Recuperar dados da geração da guia de pagamento de impostos
      pkb_rec_ger_guia_pgto_imp(en_gerguiapgtoimp_id);
      --
      vn_fase := 2.1;
      --
      pk_csf_api_gpi.gv_mensagem_log := 'Procedimento de geração de Guias de Pagamento de Imposto de ' || gt_row_ger_guia_pgto_imp.dt_ini || ' até ' || gt_row_ger_guia_pgto_imp.dt_fin || ' para a empresa: ' || pk_csf.fkg_nome_empresa(en_empresa_id => gt_row_ger_guia_pgto_imp.empresa_id) || '.';
      --
      pk_csf_api_gpi.gn_referencia_id  := en_gerguiapgtoimp_id;
      pk_csf_api_gpi.gv_obj_referencia := 'GER_GUIA_PGTO_IMP';
      --
      delete from log_generico_gpi
       where referencia_id  = pk_csf_api_gpi.gn_referencia_id
         and obj_referencia = pk_csf_api_gpi.gv_obj_referencia;
      --
      vn_fase := 2.2;
      --
      vt_log_generico_gpi.delete;
      --
      commit;
      --
      if nvl(gt_row_ger_guia_pgto_imp.dm_situacao, -1) = 0 then
        --
        vn_fase := 2.1;
        --
        -- Recuperar e agrupar guias de pgto de imposto
        pkb_monta_guia_pgto_imp(est_log_generico_gpi => vt_log_generico_gpi,
                                en_usuario_id        => en_usuario_id);
        --
        vn_fase := 2.2;
        --
        -- Verificar se gerou alguma guia de pagamento
        if nvl(fkb_verif_gerou(en_gerguiapgtoimp_id => gt_row_ger_guia_pgto_imp.id), 0) = 0 then
          --
          pk_csf_api_gpi.gv_resumo := 'Não existe lançamentos para ser gerado Guias de Pagamento neste periodo de ' || to_date(gt_row_ger_guia_pgto_imp.dt_ini, 'dd/mm/yyyy') || ' até ' || to_date(gt_row_ger_guia_pgto_imp.dt_fin, 'dd/mm/yyyy') || 'para a empresa: ' || pk_csf.fkg_nome_empresa(en_empresa_id => gt_row_ger_guia_pgto_imp.empresa_id) || '.';
          --
          pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                              ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                              ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                              en_tipo_log          => pk_csf_api_gpi.informacao,
                                              en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                              ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                              en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
          --
        else
          -- Validar as Guias de Pagamentos de Imposto
          pkb_vld_guia_pgto_imp(est_log_generico_gpi => vt_log_generico_gpi);
          --
        end if;
        --
        if nvl(vt_log_generico_gpi.count, 0) <= 0 then
          --
          update ger_guia_pgto_imp
             set dm_situacao = 1
           where id          = gt_row_ger_guia_pgto_imp.id;
          --
        else
          --
          update ger_guia_pgto_imp
             set dm_situacao = 2
           where id          = gt_row_ger_guia_pgto_imp.id;
          --
        end if;
        --
        commit;
        --
      end if;
      --
    end if;
    --
   -- Procedure para Geração da Guia de Pagamento de Imposto (nova)
   pkg_gera_guia_pgto (en_gerguiapgtoimp_id, en_usuario_id);
   --    
   --
  exception
    when others then
      --
      pk_csf_api_gpi.gv_resumo := 'Erro na package pk_ger_guia_pgto_imp.pkb_gerar fase (' || vn_fase || ') Erro: ' || sqlerrm;
      --
      pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                          ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                          ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                          en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                          en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                          ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                          en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
      --
  end pkb_gerar;

  ----------------------------------------------------------------------------------------------------
  -- Procedimento de desprocessamento da Guia de pagamento de Impostos
  procedure pkb_desfazer(en_gerguiapgtoimp_id in ger_guia_pgto_imp.id%type,
                         en_usuario_id        in neo_usuario.id%type) is
    --
    vn_fase           number;
    vn_loggenerico_id log_generico.id%type;
    --
    cursor c_dados is
      select id, 
             guiapgtoimp_id, 
             gerguiapgtoimp_id
        from r_guia_pgto_imp
       where gerguiapgtoimp_id = gt_row_ger_guia_pgto_imp.id;
    --
  begin
    --
    vn_fase := 1;
    --
    if nvl(en_gerguiapgtoimp_id, 0) > 0 then
      --
      vn_fase := 2;
      --
      -- Recuperar dados da geração da guia de pagamento de impostos
      pkb_rec_ger_guia_pgto_imp(en_gerguiapgtoimp_id);
      --
      vn_fase := 2.1;
      --
      pk_csf_api_gpi.gv_mensagem_log := 'Procedimento de desfazer a geração das Guias de Pagamento de Imposto de ' || gt_row_ger_guia_pgto_imp.dt_ini || ' até ' || gt_row_ger_guia_pgto_imp.dt_fin || ' para a empresa: ' || pk_csf.fkg_nome_empresa(en_empresa_id => gt_row_ger_guia_pgto_imp.empresa_id) || '.';
      --
      pk_csf_api_gpi.gn_referencia_id  := en_gerguiapgtoimp_id;
      pk_csf_api_gpi.gv_obj_referencia := 'GER_GUIA_PGTO_IMP';
      --
      delete from log_generico_gpi
       where referencia_id  = pk_csf_api_gpi.gn_referencia_id
         and obj_referencia = pk_csf_api_gpi.gv_obj_referencia;
      --
      vn_fase := 2.2;
      --
      commit;
      --
      if nvl(gt_row_ger_guia_pgto_imp.dm_situacao, -1) in (1, 2, 3) then
        --
        vn_fase := 2.1;
        --
        for rec in c_dados loop
          exit when c_dados%notfound or(c_dados%notfound) is null;
          --
          delete from r_guia_pgto_imp
           where gerguiapgtoimp_id = rec.gerguiapgtoimp_id;
          --
          vn_fase := 2.2;
          --
          delete 
            from guia_pgto_imp 
           where id = rec.guiapgtoimp_id;
          --
          vn_fase := 2.3;
          --
          delete 
            from log_generico_gpi
           where referencia_id  = rec.guiapgtoimp_id
             and obj_referencia = 'GUIA_PGTO_IMP';
          --
          vn_fase := 2.4;
          --
        end loop;
        --
        update ger_guia_pgto_imp
           set dm_situacao = 0
         where id = gt_row_ger_guia_pgto_imp.id;
        --
        commit;
        --
      else
        --
        pk_csf_api_gpi.gv_resumo := 'Situação da Geração da Guia de Pagamento que está (' || pk_csf.fkg_dominio('GER_GUIA_PGTO_IMP.DM_SITUACAO', gt_row_ger_guia_pgto_imp.dm_situacao) || '), não permite com que o processo seja executado';
        --
        pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                            ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                            ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                            en_tipo_log          => pk_csf_api_gpi.informacao,
                                            en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                            ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                            en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
        --
      end if;
      --
    end if;
    --
  exception
    when others then
      --
      pk_csf_api_gpi.gv_resumo := 'Erro na package pk_ger_guia_pgto_imp.pkb_gerar fase (' || vn_fase || ') Erro: ' || sqlerrm;
      --
      pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                          ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                          ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                          en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                          en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                          ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                          en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
      --
  end pkb_desfazer;
  --
----------------------------------------------------------------------------------------------------
-- Procedure para Geração da Guia de Pagamento de Imposto
procedure pkg_gera_guia_pgto (en_gerguiapgtoimp_id  in ger_guia_pgto_imp.id%type,
                              en_usuario_id         in neo_usuario.id%type)
is
   --       
   vn_fase              number := 0;       
   vn_loggenerico_id    log_generico.id%type;
   vn_guiapgtoimp_id    guia_pgto_imp.id%type;
   vt_csf_log_generico  dbms_sql.number_table;
   vv_dt_vencimento     varchar2(10);
   --
begin
   --
   vn_fase := 1;
   --
   -- Ppopula o período na variável global
   begin
      --
      select t.* 
        into gt_row_ger_guia_pgto_imp
      from GER_GUIA_PGTO_IMP t
      where t.id = en_gerguiapgtoimp_id;
      --
   exception
      when others then
         raise;
   end; 
   --  
   vn_fase := 2;
   --
   -- Varre as Notas Fiscais Mercantis e Serviço e também os Conhecimento de transportes --
   for r_docfis in c_docfis (en_gerguiapgtoimp_id)
   loop
      --  
      vn_fase := 2.1;
      --
      vv_dt_vencimento := lpad(r_docfis.dia_vcto, 2, '0') || '/' || lpad(extract(month from r_docfis.dt_vcto),2, '0') || '/' || extract(year from r_docfis.dt_vcto);
      if not pk_csf.fkg_data_valida(vv_dt_vencimento, 'dd/mm/yyyy') then
         raise_application_error (-20101, 'O Parâmetro "PARAM_DET_GUIA_IMP.DIA_VCTO" informa um dia inválido para o mês de apuração - Revise o Parâmetro');
      end if;        
      --  
      vn_fase := 2.2;
      --      
      -- Popula a Variável de Tabela -- 
      pk_csf_api_gpi.gt_row_guia_pgto_imp.id                       := null;                          
      pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id               := r_docfis.empresa_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.usuario_id               := en_usuario_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_situacao              := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id           := r_docfis.tipoimp_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id            := r_docfis.tiporetimp_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id     := r_docfis.tiporetimpreceita_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id                := r_docfis.pessoa_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_tipo                  := 1;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_origem                := r_docfis.dm_origem;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_via_impressa         := 1;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_ref                   := r_docfis.dt_ref;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_vcto                  := to_date(vv_dt_vencimento, 'dd/mm/yyyy');
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_princ                 := r_docfis.vl_princ;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_multa                 := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_juro                  := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_outro                 := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_total                 := r_docfis.vl_princ;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.obs                      := r_docfis.obs;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id_sefaz          := r_docfis.pessoa_id_sefaz;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_tit_financ           := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_alteracao             := sysdate;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_ret_erp               := case pk_csf.fkg_parametro_geral_sistema(pk_csf.fkg_multorg_id_empresa(r_docfis.empresa_id), r_docfis.empresa_id, 'GUIA_PGTO', 'RET_ERP', 'LIBERA_AUTOM_GUIA_ERP') when '1' then 0 when '0' then 6 end;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.id_erp                   := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.gerguiapgtoimp_id        := en_gerguiapgtoimp_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.planoconta_id            := r_docfis.planoconta_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.notafiscal_id            := case when r_docfis.tipo_docfis = 'NF' then r_docfis.documentofiscal_id else null end;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.conhectransp_id          := case when r_docfis.tipo_docfis = 'CT' then r_docfis.documentofiscal_id else null end;
      --
      vn_fase := 2.3;
      --
      -- Chama a procedure de integração e finalização da guia
      pk_csf_api_pgto_imp_ret.pkb_finaliza_pgto_imp_ret(est_log_generico    => vt_csf_log_generico,
                                                        en_empresa_id       => r_docfis.empresa_id,
                                                        en_dt_ini           => r_docfis.dt_ini,
                                                        en_dt_fim           => r_docfis.dt_fin,
                                                        ev_cod_rec_cd_compl => null,
                                                        sn_guiapgtoimp_id   => vn_guiapgtoimp_id);
      --
      vn_fase := 2.4;
      --
      -- Insere o relacionamento da guia de pagamnto
      if nvl(vn_guiapgtoimp_id,0) > 0 then 
         --
         insert into R_GUIA_PGTO_IMP(id
                                   , guiapgtoimp_id
                                   , gerguiapgtoimp_id
                                   , obj_referencia
                                   , referencia_id)
                             values( rguiapgtoimp_seq.nextval
                                   , vn_guiapgtoimp_id
                                   , r_docfis.gerguiapgtoimp_id
                                   , case when r_docfis.tipo_docfis = 'NF' then 'IMP_ITEMNF' else 'CONHEC_TRANSP_IMP_RET' end
                                   , r_docfis.documentofiscal_id);
         --
      end if;                             
      --
      vn_fase := 2.5;
      --
      -- Trata se houve Erro na geração da Guia --
      if nvl(vt_csf_log_generico.count,0) > 0 then
         --
         vn_fase := 2.6;
         --
         update GER_GUIA_PGTO_IMP
            set dm_situacao= 2 -- Erro Situacao: 
         where id = en_gerguiapgtoimp_id;
         --
      else
         --
         vn_fase := 2.7;
         --
         update GER_GUIA_PGTO_IMP
           set dm_situacao = 1 -- Guia Gerada
         where id = en_gerguiapgtoimp_id;
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
      pk_csf_api_gpi.gv_resumo := 'Erro na package pk_ger_guia_pgto_imp.pkg_gera_guia_pgto fase (' || vn_fase || ') Erro: ' || sqlerrm;
      --
      pk_csf_api_gpi.pkb_log_generico_gpi(sn_loggenericogpi_id => vn_loggenerico_id,
                                          ev_mensagem          => pk_csf_api_gpi.gv_mensagem_log,
                                          ev_resumo            => pk_csf_api_gpi.gv_resumo,
                                          en_tipo_log          => pk_csf_api_gpi.ERRO_DE_VALIDACAO,
                                          en_referencia_id     => pk_csf_api_gpi.gn_referencia_id,
                                          ev_obj_referencia    => pk_csf_api_gpi.gv_obj_referencia,
                                          en_empresa_id        => gt_row_ger_guia_pgto_imp.empresa_id);
end pkg_gera_guia_pgto;
--
----------------------------------------------------------------------------------------------------
end pk_ger_guia_pgto_imp;
/
