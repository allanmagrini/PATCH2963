create or replace package body csf_own.pk_valida_ambiente is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote da API para ler as notas fiscais com DM_ST_PROC = 0 (Não validada)
-- e chamar os procedimentos para validar os dados
-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Complemento do Cofins

procedure pkb_ler_nf_compl_oper_cofins ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                       , en_notafiscal_id         in             Nota_Fiscal.id%TYPE
                                       )
is

   vn_fase               number := 0;
   
   vv_cpf_cnpj_emit      varchar2(14);

   cursor c_compl_oper_cofins is
   select a.*
        , c.cod_st                                     cst_cofins
        , b.cd                                         cod_bc_cred_pc
        , d.cod_cta                                    cod_cta
        , e.empresa_id
     from nf_compl_oper_cofins a
        , cod_st c
        , base_calc_cred_pc b
        , plano_conta d
        , nota_fiscal e
    where a.notafiscal_id = en_notafiscal_id
      and c.id            = a.codst_id
      and e.id            = a.notafiscal_id
      and b.id(+)         = a.basecalccredpc_id
      and d.id(+)         = a.planoconta_id
    order by a.id;

begin
   --
   vn_fase := 1;
   --
   for rec in c_compl_oper_cofins loop
      exit when c_compl_oper_cofins%notfound or (c_compl_oper_cofins%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_compl_oper_cofins := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_compl_oper_cofins.id                 := rec.id;
      pk_csf_api.gt_row_nf_compl_oper_cofins.notafiscal_id      := rec.notafiscal_id;
      pk_csf_api.gt_row_nf_compl_oper_cofins.codst_id           := rec.codst_id;
      pk_csf_api.gt_row_nf_compl_oper_cofins.vl_item            := rec.vl_item;
      pk_csf_api.gt_row_nf_compl_oper_cofins.basecalccredpc_id  := rec.basecalccredpc_id;
      pk_csf_api.gt_row_nf_compl_oper_cofins.vl_bc_cofins       := rec.vl_bc_cofins;
      pk_csf_api.gt_row_nf_compl_oper_cofins.aliq_cofins        := rec.aliq_cofins;
      pk_csf_api.gt_row_nf_compl_oper_cofins.vl_cofins          := rec.vl_cofins;
      pk_csf_api.gt_row_nf_compl_oper_cofins.planoconta_id      := rec.planoconta_id;
      --
      vn_fase := 4;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      --
      vn_fase := 5;
      --
      pk_csf_api.pkb_integr_nfcompl_opercofins ( est_log_generico_nf            => est_log_generico_nf
                                               , est_row_nfcompl_opercofins  => pk_csf_api.gt_row_nf_compl_oper_cofins
                                               , ev_cpf_cnpj_emit            => trim(vv_cpf_cnpj_emit)
                                               , ev_cod_st                   => trim(rec.cst_cofins)
                                               , ev_cod_bc_cred_pc           => trim(rec.cod_bc_cred_pc)
                                               , ev_cod_cta                  => trim(rec.cod_cta)
                                               , en_multorg_id               => gn_multorg_id
                                               );

      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_compl_oper_cofins fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_compl_oper_cofins;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Complemento do Cofins

procedure pkb_ler_nf_compl_oper_pis ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id      in             Nota_Fiscal.id%TYPE
                                    )
is

   vn_fase               number := 0;
   
   vv_cpf_cnpj_emit      varchar2(14);

   cursor c_nfcompl_operpis is
   select a.*
        , c.cod_st                                     cst_pis
        , b.cd                                         cod_bc_cred_pc
        , d.cod_cta                                    cod_cta
        , e.empresa_id
     from nf_compl_oper_pis a
        , cod_st c
        , base_calc_cred_pc b
        , plano_conta d
        , nota_fiscal e
    where a.notafiscal_id   = en_notafiscal_id
      and c.id              = a.codst_id
      and e.id              = a.notafiscal_id
      and b.id(+)           = a.basecalccredpc_id
      and d.id(+)           = a.planoconta_id
    order by a.id;

begin
   --
   vn_fase := 1;
   --
   for rec in c_nfcompl_operpis loop
      exit when c_nfcompl_operpis%notfound or (c_nfcompl_operpis%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_compl_oper_pis := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_compl_oper_pis.id                 := rec.id;
      pk_csf_api.gt_row_nf_compl_oper_pis.notafiscal_id      := rec.notafiscal_id;
      pk_csf_api.gt_row_nf_compl_oper_pis.codst_id           := rec.codst_id;
      pk_csf_api.gt_row_nf_compl_oper_pis.vl_item            := rec.vl_item;
      pk_csf_api.gt_row_nf_compl_oper_pis.basecalccredpc_id  := rec.basecalccredpc_id;
      pk_csf_api.gt_row_nf_compl_oper_pis.vl_bc_pis          := rec.vl_bc_pis;
      pk_csf_api.gt_row_nf_compl_oper_pis.aliq_pis           := rec.aliq_pis;
      pk_csf_api.gt_row_nf_compl_oper_pis.vl_pis             := rec.vl_pis;
      pk_csf_api.gt_row_nf_compl_oper_pis.planoconta_id      := rec.planoconta_id;
      --
      vn_fase := 4;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa(rec.empresa_id);
      --
      vn_fase := 5;
      --
      pk_csf_api.pkb_integr_nfcompl_operpis ( est_log_generico_nf        => est_log_generico_nf
                                            , est_row_nfcompl_operpis => pk_csf_api.gt_row_nf_compl_oper_pis
                                            , ev_cpf_cnpj_emit        => trim(vv_cpf_cnpj_emit)
                                            , ev_cod_st               => trim(rec.cst_pis)
                                            , ev_cod_bc_cred_pc       => trim(rec.cod_bc_cred_pc)
                                            , ev_cod_cta              => trim(rec.cod_cta)
                                            , en_multorg_id           => gn_multorg_id
                                            );

      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_compl_oper_pis fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_compl_oper_pis;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura de Observações do Agendamento de Transporte

procedure pkb_ler_nf_obs_agend_transp ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                      , en_nfagendtransp_id   in             nf_agend_transp.id%type 
                                      , en_notafiscal_id      in             Nota_Fiscal.id%TYPE
                                      )
is

   vn_fase               number := 0;

   cursor c_obs is
   select *
     from nf_obs_agend_transp
    where nfagendtransp_id = en_nfagendtransp_id
    order by id;

begin
   --
   vn_fase := 1;
   --
   for rec in c_obs loop
      exit when c_obs%notfound or (c_obs%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_obs_agend_transp := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_obs_agend_transp.id                := rec.id;
      pk_csf_api.gt_row_nf_obs_agend_transp.nfagendtransp_id  := rec.nfagendtransp_id;
      pk_csf_api.gt_row_nf_obs_agend_transp.dm_tipo           := rec.dm_tipo;
      pk_csf_api.gt_row_nf_obs_agend_transp.codigo            := rec.codigo;
      pk_csf_api.gt_row_nf_obs_agend_transp.obs               := rec.obs;
      --
      vn_fase := 4;
      --
      pk_csf_api.pkb_integr_nf_obs_agend_transp ( est_log_generico_nf             => est_log_generico_nf
                                                , est_row_nf_obs_agend_transp  => pk_csf_api.gt_row_nf_obs_agend_transp
                                                , en_notafiscal_id             => en_notafiscal_id
                                                );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_obs_agend_transp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_obs_agend_transp;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Agendamento de Transporte

procedure pkb_ler_nf_agend_transp ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                  , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   vn_fase               number := 0;

   cursor c_agend is
   select *
     from nf_agend_transp
    where notafiscal_id = en_notafiscal_id
    order by id;

begin
   --
   vn_fase := 1;
   --
   for rec in c_agend loop
      exit when c_agend%notfound or (c_agend%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_agend_transp := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_agend_transp.id              := rec.id;
      pk_csf_api.gt_row_nf_agend_transp.notafiscal_id   := rec.notafiscal_id;
      pk_csf_api.gt_row_nf_agend_transp.pedido          := rec.pedido;
      --
      vn_fase := 4;
      --
      pk_csf_api.pkb_integr_nf_agend_transp ( est_log_generico_nf         => est_log_generico_nf
                                            , est_row_nf_agend_transp  => pk_csf_api.gt_row_nf_agend_transp );
      --
      vn_fase := 5;
      -- Lê Observações do Agendamento de Transporte
      pkb_ler_nf_obs_agend_transp ( est_log_generico_nf      => est_log_generico_nf
                                  , en_nfagendtransp_id   => pk_csf_api.gt_row_nf_agend_transp.id
                                  , en_notafiscal_id      => pk_csf_api.gt_row_nf_agend_transp.notafiscal_id
                                  );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_agend_transp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_agend_transp;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura de informações de NF fornecedores dos produtos constantes na DANFE

procedure pkb_ler_inf_nf_romaneio ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                  , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   vn_fase               number := 0;

   cursor c_infnfrom is
   select *
     from inf_nf_romaneio
    where notafiscal_id = en_notafiscal_id
    order by id;

begin
   --
   vn_fase := 1;
   --
   for rec in c_infnfrom loop
      exit when c_infnfrom%notfound or (c_infnfrom%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_inf_nf_romaneio := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_inf_nf_romaneio.id              := rec.id;
      pk_csf_api.gt_row_inf_nf_romaneio.notafiscal_id   := rec.notafiscal_id;
      pk_csf_api.gt_row_inf_nf_romaneio.cnpj_cpf        := rec.cnpj_cpf;
      pk_csf_api.gt_row_inf_nf_romaneio.nro_nf          := rec.nro_nf;
      pk_csf_api.gt_row_inf_nf_romaneio.serie           := rec.serie;
      pk_csf_api.gt_row_inf_nf_romaneio.dt_emiss        := rec.dt_emiss;
      --
      vn_fase := 4;
      --
      pk_csf_api.pkb_integr_inf_nf_romaneio ( est_log_generico_nf         => est_log_generico_nf
                                            , est_row_inf_nf_romaneio  => pk_csf_api.gt_row_inf_nf_romaneio );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_inf_nf_romaneio fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_inf_nf_romaneio;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura de informações de deduções da aquisição de cana-de-açúcar.

procedure pkb_ler_nf_aquis_cana_ded ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                    , en_nfaquiscana_id     in             nf_aquis_cana_ded.nfaquiscana_id%type
                                    , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_nf_aquis_cana is
   select d.*
     from nf_aquis_cana_ded  d
    where d.nfaquiscana_id  = en_nfaquiscana_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_nf_aquis_cana loop
      exit when c_nf_aquis_cana%notfound or (c_nf_aquis_cana%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_aquis_cana_ded := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_aquis_cana_ded.id              := rec.id;
      pk_csf_api.gt_row_nf_aquis_cana_ded.nfaquiscana_id  := en_nfaquiscana_id;
      pk_csf_api.gt_row_nf_aquis_cana_ded.deducao         := rec.deducao;
      pk_csf_api.gt_row_nf_aquis_cana_ded.vl_ded          := rec.vl_ded;
      --
      vn_fase := 4;
      -- Chama procedimento que válida a informação Aquisição de Cana
      pk_csf_api.pkb_integr_NFAq_Cana_Ded ( est_log_generico_nf       => est_log_generico_nf
                                          , est_row_NFAq_Cana_Ded  => pk_csf_api.gt_row_nf_aquis_cana_ded
                                          , en_notafiscal_id       => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_aquis_cana_ded fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_aquis_cana_ded;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura de informações de aquisição de cana-de-açúcar por dia.

procedure pkb_ler_nf_aquis_cana_dia ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                    , en_nfaquiscana_id     in             nf_aquis_cana_dia.nfaquiscana_id%type
                                    , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_nf_aquis_cana is
   select d.*
     from nf_aquis_cana_dia  d
    where d.nfaquiscana_id  = en_nfaquiscana_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_nf_aquis_cana loop
      exit when c_nf_aquis_cana%notfound or (c_nf_aquis_cana%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_aquis_cana_dia := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_aquis_cana_dia.id              := rec.id;
      pk_csf_api.gt_row_nf_aquis_cana_dia.nfaquiscana_id  := en_nfaquiscana_id;
      pk_csf_api.gt_row_nf_aquis_cana_dia.dia             := rec.dia;
      pk_csf_api.gt_row_nf_aquis_cana_dia.qtde            := rec.qtde;
      --
      vn_fase := 4;
      -- Chama procedimento que válida a informação Aquisição de Cana
      pk_csf_api.pkb_integr_NFAq_Cana_Dia ( est_log_generico_nf       => est_log_generico_nf
                                          , est_row_NFAq_Cana_Dia  => pk_csf_api.gt_row_nf_aquis_cana_dia
                                          , en_notafiscal_id       => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_aquis_cana_dia fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_aquis_cana_dia;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura de informações de aquisição de cana-de-açúcar.

procedure pkb_ler_nf_aquis_cana ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_nf_aquis_cana is
   select ac.*
     from nf_aquis_cana  ac
    where ac.notafiscal_id  = en_notafiscal_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_nf_aquis_cana loop
      exit when c_nf_aquis_cana%notfound or (c_nf_aquis_cana%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_aquis_cana := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_aquis_cana.id              := rec.id;
      pk_csf_api.gt_row_nf_aquis_cana.notafiscal_id   := rec.notafiscal_id;
      pk_csf_api.gt_row_nf_aquis_cana.safra           := rec.safra;
      pk_csf_api.gt_row_nf_aquis_cana.mes_ano_ref     := rec.mes_ano_ref;
      pk_csf_api.gt_row_nf_aquis_cana.qtde_total_mes  := rec.qtde_total_mes;
      pk_csf_api.gt_row_nf_aquis_cana.qtde_total_ant  := rec.qtde_total_ant;
      pk_csf_api.gt_row_nf_aquis_cana.qtde_total_ger  := rec.qtde_total_ger;
      pk_csf_api.gt_row_nf_aquis_cana.vl_forn         := rec.vl_forn;
      pk_csf_api.gt_row_nf_aquis_cana.vl_total_ded    := rec.vl_total_ded;
      pk_csf_api.gt_row_nf_aquis_cana.vl_liq_forn     := rec.vl_liq_forn;
      --
      vn_fase := 4;
      -- Chama procedimento que válida a informação Aquisição de Cana
      pk_csf_api.pkb_integr_NFAquis_Cana ( est_log_generico_nf      => est_log_generico_nf
                                         , est_row_NFAquis_Cana  => pk_csf_api.gt_row_nf_aquis_cana );
      --
      vn_fase := 5;
      -- Lê os dados de aquisição de cana dia
      pkb_ler_nf_aquis_cana_dia ( est_log_generico_nf      => est_log_generico_nf
                                , en_nfaquiscana_id     => pk_csf_api.gt_row_nf_aquis_cana.id
                                , en_notafiscal_id      => rec.notafiscal_id );
      --
      vn_fase := 6;
      -- Lê os dados de deduções da aquisição de cana de açucar
      pkb_ler_nf_aquis_cana_ded ( est_log_generico_nf      => est_log_generico_nf
                                , en_nfaquiscana_id     => pk_csf_api.gt_row_nf_aquis_cana.id
                                , en_notafiscal_id      => rec.notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_aquis_cana fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_aquis_cana;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Ajuste da Nota Fiscal para validação

procedure pkb_ler_inf_prov_docto_fiscal ( est_log_generico_nf    in out nocopy  dbms_sql.number_table
                                        , en_nfinforfiscal_id in             nfinfor_fiscal.id%type
                                        , en_notafiscal_id    in             Nota_Fiscal.id%TYPE
                                        )
is
   --
   vn_fase      number := 0;
   vv_cod_aj    cod_ocor_aj_icms.cod_aj%type;
   vv_cod_obs   obs_lancto_fiscal.cod_obs%type;
   vn_nro_item  item_nota_fiscal.nro_item%type;
   --
   cursor c_ajuste is
   select *
     from inf_prov_docto_fiscal
    where nfinforfisc_id  = en_nfinforfiscal_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_ajuste loop
       exit when c_ajuste%notfound or (c_ajuste%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_inf_prov_docto_fiscal := rec;
      --
      vv_cod_aj := pk_csf_efd.fkg_cod_ocor_aj_icms_cod_aj ( en_id => pk_csf_api.gt_row_inf_prov_docto_fiscal.codocorajicms_id );
      --
      vv_cod_obs := pk_csf.fkg_cod_obs_nfinfor_fiscal ( en_nfinforfiscal_id => pk_csf_api.gt_row_inf_prov_docto_fiscal.nfinforfisc_id );
      --
      vn_nro_item := pk_csf.fkg_nro_item ( en_itemnotafiscal_id => pk_csf_api.gt_row_inf_prov_docto_fiscal.ITEMNF_ID );
      --
      vn_fase := 4;
      -- Chama procedimento que válida as informações do Ajuste do Item da Nota Fiscal
      --
      pk_csf_api.pkb_integr_inf_prov_docto_fisc ( est_log_generico_nf              => est_log_generico_nf
                                                , est_row_inf_prov_docto_fiscal => pk_csf_api.gt_row_inf_prov_docto_fiscal
                                                , ev_cod_obs                    => vv_cod_obs
                                                , ev_cod_aj                     => vv_cod_aj
                                                , en_notafiscal_id              => en_notafiscal_id
                                                , en_nro_item                   => vn_nro_item
                                                , en_multorg_id                 => gn_multorg_id
                                                );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_ler_inf_prov_docto_fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_inf_prov_docto_fiscal;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Diferencial de aliquota do Item da Nota Fiscal para validação

procedure pkb_ler_itemnf_dif_aliq ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                  , en_itemnf_id              in             Item_Nota_Fiscal.id%TYPE
                                  , en_notafiscal_id          in Nota_Fiscal.id%TYPE )
is

   cursor c_itemnf_dif_aliq is
   select d.*
     from itemnf_dif_aliq d
    where d.itemnf_id  = en_itemnf_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_itemnf_dif_aliq loop
      exit when c_itemnf_dif_aliq%notfound or (c_itemnf_dif_aliq%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_itemnf_dif_aliq := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_itemnf_dif_aliq.itemnf_id     :=  rec.itemnf_id;
      pk_csf_api.gt_row_itemnf_dif_aliq.aliq_orig     :=  rec.aliq_orig;
      pk_csf_api.gt_row_itemnf_dif_aliq.aliq_ie       :=  rec.aliq_ie;
      pk_csf_api.gt_row_itemnf_dif_aliq.vl_bc_icms    :=  rec.vl_bc_icms;
      pk_csf_api.gt_row_itemnf_dif_aliq.vl_dif_aliq   :=  rec.vl_dif_aliq;
      pk_csf_api.gt_row_itemnf_dif_aliq.dm_tipo       :=  rec.dm_tipo;
      --
      vn_fase := 4;
      -- Chama procedimento que válida as informações do diferencial de aliquota
      pk_csf_api.pkb_int_itemnf_dif_aliq ( est_log_generico_nf          => est_log_generico_nf
                                         , est_row_itemnf_dif_aliq   => pk_csf_api.gt_row_itemnf_dif_aliq
                                         , en_notafiscal_id          => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_itemnf_dif_aliq fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_itemnf_dif_aliq;
-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura de Informações Complementares de Transporte do Item da Nota Fiscal

procedure pkb_ler_itemnf_compl_transp ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                      , en_itemnf_id          in             Item_Nota_Fiscal.id%TYPE
                                      , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_itemnf_compl_transp is
   select ct.*
     from itemnf_compl_transp  ct
    where ct.itemnf_id = en_itemnf_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_itemnf_compl_transp loop
      exit when c_itemnf_compl_transp%notfound or (c_itemnf_compl_transp%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_itemnf_compl_transp := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_itemnf_compl_transp.id                 := rec.id;
      pk_csf_api.gt_row_itemnf_compl_transp.itemnf_id          := rec.itemnf_id;
      pk_csf_api.gt_row_itemnf_compl_transp.qtde_emb           := rec.qtde_emb;
      pk_csf_api.gt_row_itemnf_compl_transp.peso_bruto         := rec.peso_bruto;
      pk_csf_api.gt_row_itemnf_compl_transp.peso_liq           := rec.peso_liq;
      pk_csf_api.gt_row_itemnf_compl_transp.volume             := rec.volume;
      pk_csf_api.gt_row_itemnf_compl_transp.qtde_prod          := rec.qtde_prod;
      pk_csf_api.gt_row_itemnf_compl_transp.s_num_cot          := rec.s_num_cot;
      pk_csf_api.gt_row_itemnf_compl_transp.cnl_cli            := rec.cnl_cli;
      pk_csf_api.gt_row_itemnf_compl_transp.cnl_cli_des        := rec.cnl_cli_des;
      pk_csf_api.gt_row_itemnf_compl_transp.alq_pis            := rec.alq_pis;
      pk_csf_api.gt_row_itemnf_compl_transp.dm_ind_rec_pis     := rec.dm_ind_rec_pis;
      pk_csf_api.gt_row_itemnf_compl_transp.alq_cofins         := rec.alq_cofins;
      pk_csf_api.gt_row_itemnf_compl_transp.dm_ind_rec_cofins  := rec.dm_ind_rec_cofins;
      --
      vn_fase := 4;
      -- Procedimento de Integração dos dados complementares de transporte do item da nota fiscal
      pk_csf_api.pkb_integr_ItemNf_Compl_transp ( est_log_generico_nf             => est_log_generico_nf
                                                , est_row_ItemNf_Compl_transp  => pk_csf_api.gt_row_itemnf_compl_transp
                                                , en_notafiscal_id             => en_notafiscal_id
                                                );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_itemnf_compl_transp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_itemnf_compl_transp;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura das Adições da Declaração de Importação para validação

procedure pkb_ler_ItemNFDI_Adic ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                , en_itemnfdi_id        in             ItemNFDI_Adic.itemnfdi_id%TYPE
                                , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_ItemNFDI_Adic is
   select ad.*
     from ItemNFDI_Adic  ad
    where ad.itemnfdi_id = en_itemnfdi_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_ItemNFDI_Adic loop
      exit when c_ItemNFDI_Adic%notfound or (c_ItemNFDI_Adic%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_ItemNFDI_Adic := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_ItemNFDI_Adic.id              := rec.id;
      pk_csf_api.gt_row_ItemNFDI_Adic.itemnfdi_id     := rec.itemnfdi_id;
      pk_csf_api.gt_row_ItemNFDI_Adic.nro_adicao      := rec.nro_adicao;
      pk_csf_api.gt_row_ItemNFDI_Adic.nro_seq_adic    := rec.nro_seq_adic;
      pk_csf_api.gt_row_ItemNFDI_Adic.cod_fabricante  := rec.cod_fabricante;
      pk_csf_api.gt_row_ItemNFDI_Adic.vl_desc_di      := rec.vl_desc_di;
      --
      vn_fase := 4;
      -- Chama procedimento que válida as informações da Adição da Declaração de Importação
      pk_csf_api.pkb_integr_ItemNFDI_Adic ( est_log_generico_nf        => est_log_generico_nf
                                          , est_row_ItemNFDI_Adic   => pk_csf_api.gt_row_ItemNFDI_Adic
                                          , en_notafiscal_id        => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_ItemNFDI_Adic fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_ItemNFDI_Adic;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura das Declarações de Importação do Item da Nota Fiscal para validação

procedure pkb_ler_ItemNF_Dec_Impor ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                   , en_itemnf_id          in             Item_Nota_Fiscal.id%TYPE
                                   , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_ItemNF_Dec_Impor is
   select di.*
     from ItemNF_Dec_Impor  di
    where di.itemnf_id = en_itemnf_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_ItemNF_Dec_Impor loop
      exit when c_ItemNF_Dec_Impor%notfound or (c_ItemNF_Dec_Impor%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_ItemNF_Dec_Impor := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_ItemNF_Dec_Impor.id               := rec.id;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.itemnf_id        := rec.itemnf_id;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.nro_di           := rec.nro_di;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.dt_di            := rec.dt_di;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.local_desemb     := rec.local_desemb;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.uf_desemb        := rec.uf_desemb;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.dt_desemb        := rec.dt_desemb;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.cod_part_export  := rec.cod_part_export;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.dm_cod_doc_imp   := rec.dm_cod_doc_imp;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.num_acdraw       := rec.num_acdraw;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.dm_tp_via_transp := rec.dm_tp_via_transp;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.vafrmm           := rec.vafrmm;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.dm_tp_intermedio := rec.dm_tp_intermedio;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.cnpj             := rec.cnpj;
      pk_csf_api.gt_row_ItemNF_Dec_Impor.uf_terceiro      := rec.uf_terceiro;
      --
      vn_fase := 4;
      -- Chama procedimento que válida as informações da Declaração de Importação
      pk_csf_api.pkb_integr_ItemNF_Dec_Impor ( est_log_generico_nf          => est_log_generico_nf
                                             , est_row_ItemNF_Dec_Impor  => pk_csf_api.gt_row_ItemNF_Dec_Impor
                                             , en_notafiscal_id          => en_notafiscal_id );
      -- 
      vn_fase := 5;
      -- Lê as informações das Adições da Declaração de Importação
      pkb_ler_ItemNFDI_Adic ( est_log_generico_nf      => est_log_generico_nf
                            , en_itemnfdi_id        => rec.id
                            , en_notafiscal_id      => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_ItemNF_Dec_Impor fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_ItemNF_Dec_Impor;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura dos Armamentos do Item da Nota Fiscal para validação

procedure pkb_ler_ItemNF_Arma ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                              , en_itemnf_id          in             Item_Nota_Fiscal.id%TYPE
                              , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_ItemNF_Arma is
   select a.*
     from ItemNF_Arma  a
    where a.itemnf_id  = en_itemnf_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_ItemNF_Arma loop
      exit when c_ItemNF_Arma%notfound or (c_ItemNF_Arma%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_ItemNF_Arma := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_ItemNF_Arma.id           := rec.id;
      pk_csf_api.gt_row_ItemNF_Arma.itemnf_id    := rec.itemnf_id;
      pk_csf_api.gt_row_ItemNF_Arma.dm_ind_arm   := rec.dm_ind_arm;
      pk_csf_api.gt_row_ItemNF_Arma.nro_serie    := rec.nro_serie;
      pk_csf_api.gt_row_ItemNF_Arma.nro_cano     := rec.nro_cano;
      pk_csf_api.gt_row_ItemNF_Arma.descr_compl  := rec.descr_compl;
      --
      vn_fase := 4;
      -- Chama procedimento que válida a informação de Armamento
      pk_csf_api.pkb_integr_ItemNF_Arma ( est_log_generico_nf      => est_log_generico_nf
                                        , est_row_ItemNF_Arma   => pk_csf_api.gt_row_ItemNF_Arma
                                        , en_notafiscal_id      => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_ItemNF_Arma fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_ItemNF_Arma;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura dos Medicamentos do Item da Nota Fiscal para validação

procedure pkb_ler_ItemNF_Med ( est_log_generico_nf     in out nocopy  dbms_sql.number_table
                             , en_itemnf_id         in             Item_Nota_Fiscal.id%TYPE
                             , en_notafiscal_id     in             Nota_Fiscal.id%TYPE )
is

   cursor c_ItemNF_Med is
   select med.*
     from ItemNF_Med    med
    where med.itemnf_id = en_itemnf_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_ItemNF_Med loop
      exit when c_ItemNF_Med%notfound or (c_ItemNF_Med%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_ItemNF_Med := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_ItemNF_Med.id               := rec.id;
      pk_csf_api.gt_row_ItemNF_Med.itemnf_id        := rec.itemnf_id;
      pk_csf_api.gt_row_ItemNF_Med.dm_tp_prod       := rec.dm_tp_prod;
      pk_csf_api.gt_row_ItemNF_Med.dm_ind_med       := rec.dm_ind_med;
      pk_csf_api.gt_row_ItemNF_Med.nro_lote         := rec.nro_lote;
      pk_csf_api.gt_row_ItemNF_Med.qtde_lote        := rec.qtde_lote;
      pk_csf_api.gt_row_ItemNF_Med.dt_fabr          := rec.dt_fabr;
      pk_csf_api.gt_row_ItemNF_Med.dt_valid         := rec.dt_valid;
      pk_csf_api.gt_row_ItemNF_Med.vl_tab_max       := rec.vl_tab_max;
      --
      vn_fase := 4;
      -- Chama procedimento que válida as informações dos medicamentos
      pk_csf_api.pkb_integr_ItemNF_Med ( est_log_generico_nf  => est_log_generico_nf
                                       , est_row_ItemNF_Med   => pk_csf_api.gt_row_ItemNF_Med
                                       , en_notafiscal_id     => en_notafiscal_id
                                       );
      --
      vn_fase := 5;
      -- Chama procediemnto que Integra as informações de medicamentos - Flex Field
      if trim(rec.cod_anvisa) is not null then
         --
         pk_csf_api.pkb_integr_itemnf_med_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_itemnfmed_id     => rec.id
                                             , ev_atributo         => 'COD_ANVISA'
                                             , ev_valor            => trim(rec.cod_anvisa)
                                             );
         --
      end if;
      --
      if trim(rec.mot_isen_anvisa) is not null then
         --
         pk_csf_api.pkb_integr_itemnf_med_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_itemnfmed_id     => rec.id
                                             , ev_atributo         => 'MOT_ISEN_ANVISA'
                                             , ev_valor            => trim(rec.mot_isen_anvisa)
                                             );
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_ItemNF_Med fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_ItemNF_Med;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Veículo do Item da Nota Fiscal para validação

procedure pkb_ler_ItemNF_Veic ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                              , en_itemnf_id              in             Item_Nota_Fiscal.id%TYPE
                              , en_notafiscal_id          in Nota_Fiscal.id%TYPE )
is

   cursor c_ItemNF_Veic is
   select v.*
     from ItemNF_Veic  v
    where v.itemnf_id  = en_itemnf_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_ItemNF_Veic loop
      exit when c_ItemNF_Veic%notfound or (c_ItemNF_Veic%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_ItemNF_Veic := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_ItemNF_Veic.id                := rec.id;
      pk_csf_api.gt_row_ItemNF_Veic.itemnf_id         := rec.itemnf_id;
      pk_csf_api.gt_row_ItemNF_Veic.dm_tp_oper        := rec.dm_tp_oper;
      pk_csf_api.gt_row_ItemNF_Veic.dm_ind_veic_oper  := rec.dm_ind_veic_oper;
      pk_csf_api.gt_row_ItemNF_Veic.chassi            := rec.chassi;
      pk_csf_api.gt_row_ItemNF_Veic.cod_cor           := rec.cod_cor;
      pk_csf_api.gt_row_ItemNF_Veic.descr_cor         := rec.descr_cor;
      pk_csf_api.gt_row_ItemNF_Veic.potencia_motor    := rec.potencia_motor;
      pk_csf_api.gt_row_ItemNF_Veic.cm3               := rec.cm3;
      pk_csf_api.gt_row_ItemNF_Veic.peso_liq          := rec.peso_liq;
      pk_csf_api.gt_row_ItemNF_Veic.peso_bruto        := rec.peso_bruto;
      pk_csf_api.gt_row_ItemNF_Veic.nro_serie         := rec.nro_serie;
      pk_csf_api.gt_row_ItemNF_Veic.tipo_combust      := rec.tipo_combust;
      pk_csf_api.gt_row_ItemNF_Veic.nro_motor         := rec.nro_motor;
      pk_csf_api.gt_row_ItemNF_Veic.cmkg              := rec.cmkg;
      pk_csf_api.gt_row_ItemNF_Veic.dist_entre_eixo   := rec.dist_entre_eixo;
      pk_csf_api.gt_row_ItemNF_Veic.renavam           := rec.renavam;
      pk_csf_api.gt_row_ItemNF_Veic.ano_mod           := rec.ano_mod;
      pk_csf_api.gt_row_ItemNF_Veic.ano_fabr          := rec.ano_fabr;
      pk_csf_api.gt_row_ItemNF_Veic.tp_pintura        := rec.tp_pintura;
      pk_csf_api.gt_row_ItemNF_Veic.tp_veiculo        := rec.tp_veiculo;
      pk_csf_api.gt_row_ItemNF_Veic.esp_veiculo       := rec.esp_veiculo;
      pk_csf_api.gt_row_ItemNF_Veic.vin               := rec.vin;
      pk_csf_api.gt_row_ItemNF_Veic.dm_cond_veic      := rec.dm_cond_veic;
      pk_csf_api.gt_row_ItemNF_Veic.cod_marca_modelo  := rec.cod_marca_modelo;
      pk_csf_api.gt_row_ItemNF_Veic.cilin             := rec.cilin;
      pk_csf_api.gt_row_ItemNF_Veic.tp_comb           := rec.tp_comb;
      pk_csf_api.gt_row_ItemNF_Veic.cmt               := rec.cmt;
      pk_csf_api.gt_row_ItemNF_Veic.cod_cor_detran    := rec.cod_cor_detran;
      pk_csf_api.gt_row_ItemNF_Veic.cap_max_lotacao   := rec.cap_max_lotacao;
      pk_csf_api.gt_row_ItemNF_Veic.dm_tp_restricao   := rec.dm_tp_restricao;
      --
      vn_fase := 4;
      -- Chama procedimento que válida as informações de veículo
      pk_csf_api.pkb_integr_ItemNF_Veic ( est_log_generico_nf          => est_log_generico_nf
                                        , est_row_ItemNF_Veic       => pk_csf_api.gt_row_ItemNF_Veic
                                        , en_notafiscal_id          => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_ItemNF_Veic fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_ItemNF_Veic;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Combustivel do Item da Nota Fiscal para validação

procedure pkb_ler_ItemNF_Comb ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                              , en_itemnf_id          in             Item_Nota_Fiscal.id%TYPE
                              , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_ItemNF_Comb is
   select c.*
        , nfe.uf
     from ItemNF_Comb       c
        , Item_Nota_Fiscal  itnf
        , Nota_Fiscal       nf
        , Nota_Fiscal_Emit  nfe
    where c.itemnf_id       = en_itemnf_id
      and itnf.id           = c.itemnf_id
      and nf.id             = itnf.notafiscal_id
      and nfe.notafiscal_id = nf.id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_ItemNF_Comb loop
      exit when c_ItemNF_Comb%notfound or (c_ItemNF_Comb%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_ItemNF_Comb := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_ItemNF_Comb.id                    := rec.id;
      pk_csf_api.gt_row_ItemNF_Comb.itemnf_id             := rec.itemnf_id;
      pk_csf_api.gt_row_ItemNF_Comb.codprodanp            := rec.codprodanp;
      pk_csf_api.gt_row_ItemNF_Comb.codif                 := rec.codif;
      pk_csf_api.gt_row_ItemNF_Comb.qtde_temp             := rec.qtde_temp;
      pk_csf_api.gt_row_ItemNF_Comb.qtde_bc_cide          := rec.qtde_bc_cide;
      pk_csf_api.gt_row_ItemNF_Comb.vl_aliq_prod_cide     := rec.vl_aliq_prod_cide;
      pk_csf_api.gt_row_ItemNF_Comb.vl_cide               := rec.vl_cide;
      pk_csf_api.gt_row_ItemNF_Comb.vl_base_calc_icms     := rec.vl_base_calc_icms;
      pk_csf_api.gt_row_ItemNF_Comb.vl_icms               := rec.vl_icms;
      pk_csf_api.gt_row_ItemNF_Comb.vl_base_calc_icms_st  := rec.vl_base_calc_icms_st;
      pk_csf_api.gt_row_ItemNF_Comb.vl_icms_st            := rec.vl_icms_st;
      pk_csf_api.gt_row_ItemNF_Comb.vl_bc_icms_st_dest    := rec.vl_bc_icms_st_dest;
      pk_csf_api.gt_row_ItemNF_Comb.vl_icms_st_dest       := rec.vl_icms_st_dest;
      pk_csf_api.gt_row_ItemNF_Comb.vl_bc_icms_st_cons    := rec.vl_bc_icms_st_cons;
      pk_csf_api.gt_row_ItemNF_Comb.vl_icms_st_cons       := rec.vl_icms_st_cons;
      pk_csf_api.gt_row_ItemNF_Comb.uf_cons               := rec.uf_cons;
      pk_csf_api.gt_row_ItemNF_Comb.nro_passe             := rec.nro_passe;
      pk_csf_api.gt_row_ItemNF_Comb.p_mix_gn              := rec.p_mix_gn;
      --
      pk_csf_api.gt_row_ItemNF_Comb.nro_bico              := rec.nro_bico;
      pk_csf_api.gt_row_ItemNF_Comb.nro_bomba             := rec.nro_bomba;
      pk_csf_api.gt_row_ItemNF_Comb.nro_tanque            := rec.nro_tanque;
      pk_csf_api.gt_row_ItemNF_Comb.vl_enc_ini            := rec.vl_enc_ini;
      pk_csf_api.gt_row_ItemNF_Comb.vl_enc_fin            := rec.vl_enc_fin;
      pk_csf_api.gt_row_ItemNF_Comb.descr_anp             := rec.descr_anp;
      pk_csf_api.gt_row_ItemNF_Comb.perc_glp              := rec.perc_glp;
      pk_csf_api.gt_row_ItemNF_Comb.perc_gnn              := rec.perc_gnn;
      pk_csf_api.gt_row_ItemNF_Comb.perc_gni              := rec.perc_gni;
      pk_csf_api.gt_row_ItemNF_Comb.vl_part               := rec.vl_part;
      --
      vn_fase := 4;
      -- Chama procedimento que válida as informações de Combustíveis
      pk_csf_api.pkb_integr_ItemNF_Comb ( est_log_generico_nf   => est_log_generico_nf
                                        , est_row_ItemNF_Comb   => pk_csf_api.gt_row_ItemNF_Comb
                                        , ev_uf_emit            => rec.uf
                                        , en_notafiscal_id      => en_notafiscal_id 
                                        );
      --
      vn_fase := 5;
      --
      -- Percentual de Gás Natural para o produto GLP (cProdANP=210203001)
      if nvl(rec.p_mix_gn,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'P_MIX_GN'
                                              , ev_valor              => to_char(rec.p_mix_gn, '99D9999')
                                              );
         --
      end if;
      --
      vn_fase := 5.1;
      -- Número de identificação do bico utilizado no abastecimento
      if nvl(rec.NRO_BICO,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'NRO_BICO'
                                              , ev_valor              => to_char(rec.NRO_BICO, '999')
                                              );
         --
      end if;
      --
      vn_fase := 5.2;
      -- Número de identificação da bomba ao qual o bico está interligado
      if nvl(rec.NRO_BOMBA,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'NRO_BOMBA'
                                              , ev_valor              => to_char(rec.NRO_BOMBA, '999')
                                              );
         --
      end if;
      --
      vn_fase := 5.3;
      -- Número de identificação do tanque ao qual o bico está interligado
      if nvl(rec.NRO_TANQUE,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'NRO_TANQUE'
                                              , ev_valor              => to_char(rec.NRO_TANQUE, '999')
                                              );
         --
      end if;
      --
      vn_fase := 5.4;
      -- Valor do Encerrante no início do abastecimento
      if nvl(rec.VL_ENC_INI,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'VL_ENC_INI'
                                              , ev_valor              => to_char(rec.VL_ENC_INI, '9999999999999D99')
                                              );
         --
      end if;
      --
      vn_fase := 5.5;
      -- Valor do Encerrante no final do abastecimento
      if nvl(rec.VL_ENC_FIN,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'VL_ENC_FIN'
                                              , ev_valor              => to_char(rec.VL_ENC_FIN, '9999999999999D99')
                                              );
         --
      end if;
      --
      vn_fase := 5.6;
      -- Descrição do produto conforme ANP
      if trim(rec.DESCR_ANP) is not null then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'DESCR_ANP'
                                              , ev_valor              => rec.DESCR_ANP
                                              );
         --
      end if;
      --
      vn_fase := 5.7;
      -- Percentual do GLP derivado do petróleo no produto GLP (cProdANP=210203001)
      if nvl(rec.PERC_GLP,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'PERC_GLP'
                                              , ev_valor              => to_char(rec.PERC_GLP, '999D9999')
                                              );
         --
      end if;
      --
      vn_fase := 5.8;
      -- Percentual de Gás Natural Nacional – GLGNn para o produto GLP (cProdANP=210203001)
      if nvl(rec.PERC_GNN,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'PERC_GNN'
                                              , ev_valor              => to_char(rec.PERC_GNN, '999D9999')
                                              );
         --
      end if;
      --
      vn_fase := 5.9;
      -- Percentual de Gás Natural Importado – GLGNi para o produto GLP (cProdANP=210203001)
      if nvl(rec.PERC_GNI,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'PERC_GNI'
                                              , ev_valor              => to_char(rec.PERC_GNI, '999D9999')
                                              );
         --
      end if;
      --
      vn_fase := 5.10;
      -- Valor de partida (cProdANP=210203001)
      if nvl(rec.VL_PART,0) > 0  then
         --
         pk_csf_api.pkb_integr_itemnf_comb_ff ( est_log_generico_nf   => est_log_generico_nf
                                              , en_notafiscal_id      => en_notafiscal_id
                                              , en_itemnfcomb_id      => rec.id
                                              , ev_atributo           => 'VL_PART'
                                              , ev_valor              => to_char(rec.VL_PART, '9999999999999D99')
                                              );
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_ItemNF_Comb fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_ItemNF_Comb;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Ressarcimento de ICMS em operações com substituição Tributária do Item da Nota Fiscal

procedure pkb_ler_itemnf_res_icms_st ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                     , en_itemnf_id          in             Item_Nota_Fiscal.id%TYPE
                                     , en_notafiscal_id      in             Nota_Fiscal.id%TYPE
                                     )
is
   --
   vn_fase number := 0;
   --
   cursor c_itemnf_res_icms_st is
   select ir.*
     from itemnf_res_icms_st ir
    where ir.itemnf_id = en_itemnf_id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_itemnf_res_icms_st loop
      exit when c_itemnf_res_icms_st%notfound or (c_itemnf_res_icms_st%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_itemnf_res_icms_st := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_itemnf_res_icms_st := rec;
      --
      vn_fase := 4;
      -- Chama procedimento que valida Ressarcimento de ICMS em operações com substituição Tributária do Item da Nota Fiscal
      pk_csf_api.pkb_integr_itemnf_res_icms_st ( est_log_generico_nf        => est_log_generico_nf
                                               , est_row_itemnf_res_icms_st => pk_csf_api.gt_row_itemnf_res_icms_st
                                               , en_notafiscal_id           => en_notafiscal_id
                                               , en_multorg_id              => gn_multorg_id
                                               , ev_cod_mod_e               => pk_csf.fkg_cod_mod_id ( en_modfiscal_id => rec.modfiscal_id )
                                               , ev_cod_part_e              => pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id )
                                               , ev_cod_part_nfe_ret        => pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id_nfe_ret )
                                               );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_itemnf_res_icms_st fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_itemnf_res_icms_st;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Rastreabilidade de produto

procedure pkb_ler_itemnf_rastreab ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                  , en_itemnf_id          in             Item_Nota_Fiscal.id%TYPE
                                  , en_notafiscal_id      in             Nota_Fiscal.id%TYPE
                                  )
is
   --
   cursor c_itemnf_rastreab is
   select *
     from itemnf_rastreab
    where itemnf_id = en_itemnf_id;
   --
   vn_fase               number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_itemnf_rastreab loop
      exit when c_itemnf_rastreab%notfound or (c_itemnf_rastreab%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_itemnf_rastreab := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_itemnf_rastreab := rec;
      --
      vn_fase := 4;
      -- Chama procedimento que valida as informações de Rastreabilidade de produto
      pk_csf_api.pkb_integr_itemnf_rastreab ( est_log_generico_nf      => est_log_generico_nf
                                            , est_row_itemnf_rastreab  => pk_csf_api.gt_row_itemnf_rastreab
                                            , en_notafiscal_id         => en_notafiscal_id
                                            );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_itemnf_rastreab fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_itemnf_rastreab;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do complemento de serviço do item

procedure pkb_ler_itemnf_compl_serv ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                                    , en_itemnf_id          in             Item_Nota_Fiscal.id%TYPE
                                    , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is
   --
   cursor c_itemnf_compl is
   select *
     from itemnf_compl_serv
    where itemnf_id = en_itemnf_id;
   --
   vn_fase               number := 0;
   vv_cod_trib_municipio cod_trib_municipio.cod_trib_municipio%type;
   vn_cod_siscomex       pais.cod_siscomex%type;
   vv_cod_mun            cidade.ibge_cidade%type;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_itemnf_compl loop
      exit when c_itemnf_compl%notfound or (c_itemnf_compl%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_itemnf_compl_serv := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_itemnf_compl_serv.itemnf_id              := rec.itemnf_id;
      pk_csf_api.gt_row_itemnf_compl_serv.dm_loc_exe_serv        := rec.dm_loc_exe_serv;
      pk_csf_api.gt_row_itemnf_compl_serv.dm_trib_mun_prest      := rec.dm_trib_mun_prest;
      pk_csf_api.gt_row_itemnf_compl_serv.codtribmunicipio_id    := rec.codtribmunicipio_id;
      pk_csf_api.gt_row_itemnf_compl_serv.vl_desc_incondicionado := rec.vl_desc_incondicionado;
      pk_csf_api.gt_row_itemnf_compl_serv.vl_desc_condicionado   := rec.vl_desc_condicionado;
      pk_csf_api.gt_row_itemnf_compl_serv.vl_deducao             := rec.vl_deducao;
      pk_csf_api.gt_row_itemnf_compl_serv.vl_outra_ret           := rec.vl_outra_ret;
      pk_csf_api.gt_row_itemnf_compl_serv.pais_id                := rec.pais_id;
      pk_csf_api.gt_row_itemnf_compl_serv.nro_proc               := rec.nro_proc;
      pk_csf_api.gt_row_itemnf_compl_serv.dm_ind_incentivo       := rec.dm_ind_incentivo;
      pk_csf_api.gt_row_itemnf_compl_serv.cidade_id              := rec.cidade_id;
      --
      vv_cod_trib_municipio := pk_csf.fkg_codtribmunicipio_cd ( rec.codtribmunicipio_id );
      --
      vn_cod_siscomex := pk_csf.fkg_cod_siscomex_pais_id ( rec.pais_id );
      --
      vv_cod_mun := pk_csf.fkg_ibge_cidade_id ( en_cidade_id => rec.cidade_id );
      --
      vn_fase := 4;
      -- Chama procedimento que valida as informações do complemento de serviço do item
      pk_csf_api.pkb_integr_itemnf_compl_serv ( est_log_generico_nf          => est_log_generico_nf
                                              , est_row_itemnf_compl_serv => pk_csf_api.gt_row_itemnf_compl_serv
                                              , en_notafiscal_id          => en_notafiscal_id 
                                              , ev_cod_trib_municipio     => vv_cod_trib_municipio
                                              , en_cod_siscomex           => vn_cod_siscomex
                                              , ev_cod_mun                => vv_cod_mun
                                              );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_itemnf_compl_serv fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_itemnf_compl_serv;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do detalhamento do NCM: NVE

procedure pkb_ler_itemnf_nve ( est_log_generico_nf      in out nocopy  dbms_sql.number_table
                             , en_itemnf_id          in             Item_Nota_Fiscal.id%TYPE
                             , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_itemnf_nve is
   select *
     from itemnf_nve
    where itemnf_id = en_itemnf_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_itemnf_nve loop
      exit when c_itemnf_nve%notfound or (c_itemnf_nve%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_itemnf_nve := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_itemnf_nve.id        := rec.id;
      pk_csf_api.gt_row_itemnf_nve.itemnf_id := rec.itemnf_id;
      pk_csf_api.gt_row_itemnf_nve.nve       := rec.nve;
      --
      vn_fase := 4;
      -- Chama procedimento que valida as informações do NVE
      pk_csf_api.pkb_integr_itemnf_nve ( est_log_generico_nf    => est_log_generico_nf
                                       , est_row_itemnf_nve  => pk_csf_api.gt_row_itemnf_nve
                                       , en_notafiscal_id    => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_itemnf_nve fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_itemnf_nve;

-------------------------------------------------------------------------------------------------------
-- Procedimento que faz leitura do complemento de informação de exportação
procedure pkb_ler_itemnf_export_compl ( est_log_generico_nf   in out nocopy dbms_sql.number_table
                                      , en_itemnfexport_id    in itemnf_export.id%type
                                      , en_notafiscal_id      in Nota_Fiscal.id%TYPE )
is
   --
   cursor c_dados is
      select *
        from itemnf_export_compl
       where itemnfexport_id = en_itemnfexport_id;
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      pk_csf_api.gt_row_itemnf_export_compl := null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_itemnf_export_compl.id              := rec.id;
      pk_csf_api.gt_row_itemnf_export_compl.itemnfexport_id := rec.itemnfexport_id;
      pk_csf_api.gt_row_itemnf_export_compl.dm_ind_doc      := rec.dm_ind_doc;
      pk_csf_api.gt_row_itemnf_export_compl.nro_de          := rec.nro_de;
      pk_csf_api.gt_row_itemnf_export_compl.dt_de           := rec.dt_de;
      pk_csf_api.gt_row_itemnf_export_compl.dm_nat_exp      := rec.dm_nat_exp;
      pk_csf_api.gt_row_itemnf_export_compl.nro_re          := rec.nro_re;
      pk_csf_api.gt_row_itemnf_export_compl.dt_re           := rec.dt_re;
      pk_csf_api.gt_row_itemnf_export_compl.chc_emb         := rec.chc_emb;
      pk_csf_api.gt_row_itemnf_export_compl.dt_chc          := rec.dt_chc;
      pk_csf_api.gt_row_itemnf_export_compl.dt_avb          := rec.dt_avb;
      pk_csf_api.gt_row_itemnf_export_compl.dm_tp_chc       := rec.dm_tp_chc;
      pk_csf_api.gt_row_itemnf_export_compl.nr_memo         := rec.nr_memo;
      --
      vn_fase := 3;
      --
      pk_csf_api.pkb_integr_info_export_compl ( est_log_generico_nf         => est_log_generico_nf
                                              , est_row_itemnf_export_compl => pk_csf_api.gt_row_itemnf_export_compl
                                              );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_itemnf_export_compl(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         --
         vn_loggenerico_id  log_generico_nf.id%TYPE;
         --
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem          => pk_csf_api.gv_cabec_log
                                        , ev_resumo            => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log          => pk_csf_api.erro_de_sistema
                                        , en_referencia_id     => en_notafiscal_id
                                        , ev_obj_referencia    => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            --
            null;
            --
      end;
      --
end pkb_ler_itemnf_export_compl;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a leitura do Controle de Exportação por Item

procedure pkb_ler_itemnf_export ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                , en_itemnf_id          in             Item_Nota_Fiscal.id%TYPE
                                , en_notafiscal_id      in             Nota_Fiscal.id%TYPE )
is

   cursor c_itemnf_export is
   select *
     from itemnf_export
    where itemnf_id = en_itemnf_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_itemnf_export loop
      exit when c_itemnf_export%notfound or (c_itemnf_export%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_itemnf_export := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_itemnf_export.id                  := rec.id;
      pk_csf_api.gt_row_itemnf_export.itemnf_id           := rec.itemnf_id;
      pk_csf_api.gt_row_itemnf_export.num_acdraw          := rec.num_acdraw;
      pk_csf_api.gt_row_itemnf_export.num_reg_export      := rec.num_reg_export;
      pk_csf_api.gt_row_itemnf_export.chv_nfe_export      := rec.chv_nfe_export;
      pk_csf_api.gt_row_itemnf_export.qtde_export         := rec.qtde_export;
      --
      vn_fase := 4;

      -- Chama procedimento que valida o Controle de Exportação por Item
      pk_csf_api.pkb_integr_itemnf_export ( est_log_generico_nf    => est_log_generico_nf
                                          , est_row_itemnf_export  => pk_csf_api.gt_row_itemnf_export
                                          , en_notafiscal_id       => en_notafiscal_id );
      --
      vn_fase := 5;
      --
      -- leitura do complemento de informação de exportação
      if nvl(pk_csf_api.gt_row_itemnf_export.id, 0) > 0 then
         --
         pkb_ler_itemnf_export_compl ( est_log_generico_nf => est_log_generico_nf
                                     , en_itemnfexport_id  => pk_csf_api.gt_row_itemnf_export.id
                                     , en_notafiscal_id    => en_notafiscal_id );
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_itemnf_itemnf_export(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_itemnf_export;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura dos Impostos da Partilha de ICMS
procedure pkb_ler_Imp_ItemNf_icms_dest ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                       , en_impitemnf_id           in             imp_itemnf.id%type
                                       , en_itemnf_id              in             Item_Nota_Fiscal.id%TYPE
                                       , en_notafiscal_id          in             Nota_Fiscal.id%TYPE
                                       )
is

   cursor c_dados is
   select imp.*
     from IMP_ITEMNF_ICMS_DEST     imp
    where imp.IMPITEMNF_ID  = en_impitemnf_id;

   vn_fase                  number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_imp_itemnficmsdest := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_imp_itemnficmsdest := rec;
      --
      vn_fase := 3.1;
      --
      pk_csf_api.pkb_integr_imp_itemnficmsdest ( est_log_generico_nf        => est_log_generico_nf
                                               , est_row_imp_itemnficmsdest => pk_csf_api.gt_row_imp_itemnficmsdest
                                               , en_notafiscal_id           => en_notafiscal_id
                                               , en_multorg_id              => gn_multorg_id
                                               );
      --
      vn_fase := 4;
      -- Valida os Flex-Fields
      --
      if nvl(rec.VL_BC_FCP_DEST,0) > 0 then
         --
         pk_csf_api.pkb_integr_impitnficmsdest_ff ( est_log_generico_nf      => est_log_generico_nf
                                                  , en_notafiscal_id         => en_notafiscal_id
                                                  , en_impitemnf_id          => en_impitemnf_id
                                                  , en_impitemnficmsdest_id  => rec.id
                                                  , ev_atributo              => 'VL_BC_FCP_DEST'
                                                  , ev_valor                 => to_char(rec.VL_BC_FCP_DEST, '9G999G999G999G999D00')
                                                  , en_multorg_id            => gn_multorg_id
                                                  );
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Imp_ItemNf_icms_dest fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem          => pk_csf_api.gv_cabec_log
                                        , ev_resumo            => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log          => pk_csf_api.ERRO_DE_SISTEMA
                                        , en_referencia_id     => en_notafiscal_id
                                        , ev_obj_referencia    => 'NOTA_FISCAL' 
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Imp_ItemNf_icms_dest;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura dos Impostos do Item da Nota Fiscal para validação
procedure pkb_ler_Imp_ItemNf ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                             , en_itemnf_id              in             Item_Nota_Fiscal.id%TYPE
                             , en_notafiscal_id          in             Nota_Fiscal.id%TYPE
                             )
is
   --
   cursor c_Imp_ItemNf is
   select imp.*
     from Imp_ItemNf     imp
    where imp.itemnf_id  = en_itemnf_id;
   --
   vn_fase                  number := 0;
   vn_cd_imp                tipo_imposto.cd%type;
   vv_cod_st                cod_st.cod_st%type;
   vv_sigla_estado          estado.sigla_estado%type;
   vn_cod_nat_rec_pc        nat_rec_pc.cod%type := 0;
   vn_cd_tipo_ret_imp       tipo_ret_imp.cd%type := null;
   vv_cod_receita           tipo_ret_imp_receita.cod_receita%type;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_Imp_ItemNf loop
      exit when c_Imp_ItemNf%notfound or (c_Imp_ItemNf%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_Imp_ItemNf := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_Imp_ItemNf.id                   := rec.id;
      pk_csf_api.gt_row_Imp_ItemNf.itemnf_id            := rec.itemnf_id;
      pk_csf_api.gt_row_Imp_ItemNf.tipoimp_id           := rec.tipoimp_id;
      pk_csf_api.gt_row_Imp_ItemNf.dm_tipo              := rec.dm_tipo;
      pk_csf_api.gt_row_Imp_ItemNf.codst_id             := rec.codst_id;
      pk_csf_api.gt_row_Imp_ItemNf.vl_base_calc         := rec.vl_base_calc;
      pk_csf_api.gt_row_Imp_ItemNf.aliq_apli            := rec.aliq_apli;
      pk_csf_api.gt_row_Imp_ItemNf.vl_imp_trib          := rec.vl_imp_trib;
      pk_csf_api.gt_row_Imp_ItemNf.perc_reduc           := rec.perc_reduc;
      pk_csf_api.gt_row_Imp_ItemNf.perc_adic            := rec.perc_adic;
      pk_csf_api.gt_row_Imp_ItemNf.qtde_base_calc_prod  := rec.qtde_base_calc_prod;
      pk_csf_api.gt_row_Imp_ItemNf.vl_aliq_prod         := rec.vl_aliq_prod;
      pk_csf_api.gt_row_Imp_ItemNf.perc_bc_oper_prop    := rec.perc_bc_oper_prop;
      pk_csf_api.gt_row_Imp_ItemNf.vl_bc_st_ret         := rec.vl_bc_st_ret;
      pk_csf_api.gt_row_Imp_ItemNf.vl_icmsst_ret        := rec.vl_icmsst_ret;
      pk_csf_api.gt_row_Imp_ItemNf.vl_bc_st_dest        := rec.vl_bc_st_dest;
      pk_csf_api.gt_row_Imp_ItemNf.vl_icmsst_dest       := rec.vl_icmsst_dest;
      pk_csf_api.gt_row_Imp_ItemNf.vl_icms_deson        := rec.vl_icms_deson;
      pk_csf_api.gt_row_Imp_ItemNf.vl_icms_oper         := rec.vl_icms_oper;
      pk_csf_api.gt_row_Imp_ItemNf.percent_difer        := rec.percent_difer;
      pk_csf_api.gt_row_Imp_ItemNf.vl_icms_difer        := rec.vl_icms_difer;
      --
      vn_fase := 3.1;
      --
      vn_cd_imp := pk_csf.fkg_Tipo_Imposto_cd ( en_tipoimp_id => rec.tipoimp_id );
      --
      vn_fase := 3.2;
      --
      vv_cod_st := pk_csf.fkg_Cod_ST_cod ( en_id_st => rec.codst_id );
      --
      vn_fase := 3.3;
      --
      vv_sigla_estado := pk_csf.fkg_Estado_id_sigla ( en_estado_id => rec.estado_id );
      --
      vn_fase := 4;
      -- Chama o procedimento que integra as informações do Imposto ICMS
      pk_csf_api.pkb_integr_Imp_ItemNf ( est_log_generico_nf  => est_log_generico_nf
                                       , est_row_Imp_ItemNf   => pk_csf_api.gt_row_Imp_ItemNf
                                       , en_cd_imp            => vn_cd_imp
                                       , ev_cod_st            => vv_cod_st
                                       , en_notafiscal_id     => en_notafiscal_id
                                       , ev_sigla_estado      => vv_sigla_estado
                                       );
      --
      vn_fase := 5;
      -- Valida os Flex-Fields
      --
      if nvl(rec.VL_BASE_OUTRO,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_BASE_OUTRO'
                                             , ev_valor            => to_char(rec.VL_BASE_OUTRO, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.1;
      --
      if nvl(rec.VL_IMP_OUTRO,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_IMP_OUTRO'
                                             , ev_valor            => to_char(rec.VL_IMP_OUTRO, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.2;
      --
      if nvl(rec.VL_BASE_ISENTA,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_BASE_ISENTA'
                                             , ev_valor            => to_char(rec.VL_BASE_ISENTA, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.3;
      --
      if nvl(rec.ALIQ_APLIC_OUTRO,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'ALIQ_APLIC_OUTRO'
                                             , ev_valor            => to_char(rec.ALIQ_APLIC_OUTRO, '999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.4;
      --
      if nvl(rec.VL_IMP_NAO_DEST,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_IMP_NAO_DEST'
                                             , ev_valor            => to_char(rec.VL_IMP_NAO_DEST, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.5;
      --
      if nvl(rec.natrecpc_id,0) > 0 then
         --
         vn_cod_nat_rec_pc := pk_csf_efd_pc.fkg_cod_id_nat_rec_pc ( en_natrecpc_id => rec.natrecpc_id );
         --
         vn_fase := 5.51;
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'COD_NAT_REC_PC'
                                             , ev_valor            => vn_cod_nat_rec_pc
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.6;
      --
      if nvl(rec.TIPORETIMP_ID,0) > 0 then
         --
         vn_cd_tipo_ret_imp := pk_csf.fkg_tipo_ret_imp_cd ( en_tiporetimp_id => rec.TIPORETIMP_ID );
         --
         vn_fase := 5.61;
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'CD_TIPO_RET_IMP'
                                             , ev_valor            => vn_cd_tipo_ret_imp
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.7;
      --
      if nvl(rec.VL_ICMS_DESON,0) >= 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_ICMS_DESON'
                                             , ev_valor            => to_char(nvl(rec.VL_ICMS_DESON,0), '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.8;
      --
      if nvl(rec.VL_ICMS_OPER,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_ICMS_OPER'
                                             , ev_valor            => to_char(rec.VL_ICMS_OPER, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.9;
      --
      if nvl(rec.PERCENT_DIFER,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'PERCENT_DIFER'
                                             , ev_valor            => to_char(rec.PERCENT_DIFER, '999D0000')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.10;
      --
      if nvl(rec.VL_ICMS_DIFER,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_ICMS_DIFER'
                                             , ev_valor            => to_char(rec.VL_ICMS_DIFER, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.11;
      --
      if nvl(rec.TIPORETIMPRECEITA_ID,0) > 0 then
         --
         begin
            --
            select cod_receita
              into vv_cod_receita
              from tipo_ret_imp_receita
             where id = rec.TIPORETIMPRECEITA_ID;
            --
         exception
            when others then
               vv_cod_receita := null;
         end;
         --
         vn_fase := 5.111;
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'COD_RECEITA'
                                             , ev_valor            => vv_cod_receita
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.12;
      --
      if nvl(rec.VL_BC_FCP,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_BC_FCP'
                                             , ev_valor            => to_char(rec.VL_BC_FCP, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.13;
      --
      if nvl(rec.ALIQ_FCP,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'ALIQ_FCP'
                                             , ev_valor            => to_char(rec.ALIQ_FCP, '999D0000')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.14;
      --
      if nvl(rec.VL_FCP,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_FCP'
                                             , ev_valor            => to_char(rec.VL_FCP, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.15;
      --
      if nvl(rec.BC_ICMS_EFET,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'BC_ICMS_EFET'
                                             , ev_valor            => to_char(rec.BC_ICMS_EFET, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --	 
	  vn_fase := 5.16;
      --
      if nvl(rec.VL_ICMS_EFET,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'VL_ICMS_EFET'
                                             , ev_valor            => to_char(rec.VL_ICMS_EFET, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.17;
      --
      if nvl(rec.ALIQ_ICMS_EFET,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'ALIQ_ICMS_EFET'
                                             , ev_valor            => to_char(rec.ALIQ_ICMS_EFET, '999D0000')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;
      --
      vn_fase := 5.18;
      --
      if nvl(rec.PERC_RED_BC_ICMS_EFET,0) > 0 then
         --
         pk_csf_api.pkb_integr_imp_itemnf_ff ( est_log_generico_nf => est_log_generico_nf
                                             , en_notafiscal_id    => en_notafiscal_id
                                             , en_impitemnf_id     => rec.id
                                             , ev_atributo         => 'PERC_RED_BC_ICMS_EFET'
                                             , ev_valor            => to_char(rec.PERC_RED_BC_ICMS_EFET, '9G999G999G999G999D00')
                                             , en_multorg_id       => gn_multorg_id
                                             );
         --
      end if;	  
      --	  
      vn_fase := 6;
      -- Lê informações de Partilha de ICMS
      pkb_ler_Imp_ItemNf_icms_dest ( est_log_generico_nf       => est_log_generico_nf
                                   , en_impitemnf_id           => rec.id
                                   , en_itemnf_id              => rec.itemnf_id
                                   , en_notafiscal_id          => en_notafiscal_id
                                   );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Imp_ItemNf fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Imp_ItemNf;
--
-- =============================================================================================================
-- Procedimento faz a leitura dos Items da Nota Fiscal para validação
procedure pkb_ler_Item_Nota_Fiscal ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                   , en_notafiscal_id          in             Nota_Fiscal.id%TYPE  )
is

   cursor c_Item_Nota_Fiscal is
   select itnf.*
     from Item_Nota_Fiscal    itnf
    where itnf.notafiscal_id  =  en_notafiscal_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Item_Nota_Fiscal loop
      exit when c_Item_Nota_Fiscal%notfound or (c_Item_Nota_Fiscal%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_Item_Nota_Fiscal := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_Item_Nota_Fiscal.id                   := rec.id;
      pk_csf_api.gt_row_Item_Nota_Fiscal.notafiscal_id        := rec.notafiscal_id;
      pk_csf_api.gt_row_Item_Nota_Fiscal.item_id              := rec.item_id;
      pk_csf_api.gt_row_Item_Nota_Fiscal.nro_item             := rec.nro_item;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cod_item             := rec.cod_item;
      pk_csf_api.gt_row_Item_Nota_Fiscal.dm_ind_mov           := rec.dm_ind_mov;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cean                 := rec.cean;
      pk_csf_api.gt_row_Item_Nota_Fiscal.descr_item           := rec.descr_item;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cod_ncm              := rec.cod_ncm;
      pk_csf_api.gt_row_Item_Nota_Fiscal.genero               := rec.genero;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cod_ext_ipi          := rec.cod_ext_ipi;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cfop_id              := rec.cfop_id;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cfop                 := rec.cfop;
      pk_csf_api.gt_row_Item_Nota_Fiscal.unid_com             := rec.unid_com;
      pk_csf_api.gt_row_Item_Nota_Fiscal.qtde_comerc          := rec.qtde_comerc;
      pk_csf_api.gt_row_Item_Nota_Fiscal.vl_unit_comerc       := rec.vl_unit_comerc;
      pk_csf_api.gt_row_Item_Nota_Fiscal.vl_item_bruto        := rec.vl_item_bruto;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cean_trib            := rec.cean_trib;
      pk_csf_api.gt_row_Item_Nota_Fiscal.unid_trib            := rec.unid_trib;
      pk_csf_api.gt_row_Item_Nota_Fiscal.qtde_trib            := rec.qtde_trib;
      pk_csf_api.gt_row_Item_Nota_Fiscal.vl_unit_trib         := rec.vl_unit_trib;
      pk_csf_api.gt_row_Item_Nota_Fiscal.vl_frete             := rec.vl_frete;
      pk_csf_api.gt_row_Item_Nota_Fiscal.vl_seguro            := rec.vl_seguro;
      pk_csf_api.gt_row_Item_Nota_Fiscal.vl_desc              := rec.vl_desc;
      pk_csf_api.gt_row_Item_Nota_Fiscal.vl_outro             := rec.vl_outro;
      pk_csf_api.gt_row_Item_Nota_Fiscal.dm_ind_tot           := rec.dm_ind_tot;
      pk_csf_api.gt_row_Item_Nota_Fiscal.infadprod            := rec.infadprod;
      pk_csf_api.gt_row_Item_Nota_Fiscal.orig                 := rec.orig;
      pk_csf_api.gt_row_Item_Nota_Fiscal.dm_mod_base_calc     := nvl(rec.dm_mod_base_calc,0);
      pk_csf_api.gt_row_Item_Nota_Fiscal.dm_mod_base_calc_st  := rec.dm_mod_base_calc_st;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cnpj_produtor        := rec.cnpj_produtor;
      pk_csf_api.gt_row_Item_Nota_Fiscal.qtde_selo_ipi        := rec.qtde_selo_ipi;
      pk_csf_api.gt_row_Item_Nota_Fiscal.vl_desp_adu          := rec.vl_desp_adu;
      pk_csf_api.gt_row_Item_Nota_Fiscal.vl_iof               := rec.vl_iof;
      pk_csf_api.gt_row_Item_Nota_Fiscal.classenqipi_id       := rec.classenqipi_id;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cl_enq_ipi           := rec.cl_enq_ipi;
      pk_csf_api.gt_row_Item_Nota_Fiscal.selocontripi_id      := rec.selocontripi_id;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cod_selo_ipi         := rec.cod_selo_ipi;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cod_enq_ipi          := rec.cod_enq_ipi;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cidade_ibge          := rec.cidade_ibge;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cd_lista_serv        := rec.cd_lista_serv;
      pk_csf_api.gt_row_Item_Nota_Fiscal.dm_ind_apur_ipi      := rec.dm_ind_apur_ipi;
      pk_csf_api.gt_row_Item_Nota_Fiscal.cod_cta              := rec.cod_cta;
      pk_csf_api.gt_row_Item_Nota_Fiscal.pedido_compra        := rec.pedido_compra;
      pk_csf_api.gt_row_Item_Nota_Fiscal.item_pedido_compra   := rec.item_pedido_compra;
      pk_csf_api.gt_row_Item_Nota_Fiscal.dm_mot_des_icms      := rec.dm_mot_des_icms;
      pk_csf_api.gt_row_Item_Nota_Fiscal.dm_cod_trib_issqn    := rec.dm_cod_trib_issqn;
      pk_csf_api.gt_row_item_nota_fiscal.vl_tot_trib_item     := rec.vl_tot_trib_item;
      --
      vn_fase := 4;
      -- Chama procedimento que faz a validação dos itens da Nota Fiscal
      pk_csf_api.pkb_integr_Item_Nota_Fiscal ( est_log_generico_nf         => est_log_generico_nf
                                             , est_row_Item_Nota_Fiscal    => pk_csf_api.gt_row_Item_Nota_Fiscal
                                             , en_multorg_id               => gn_multorg_id );
      --
      vn_fase := 4.1;
      -- Chama procedimento que faz a validação das flex-field dos itens da nota fiscal
      -- Valida Número do RECOPI
      if trim(rec.nro_recopi) is not null then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf  => est_log_generico_nf
                                                  , en_notafiscal_id     => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo          => 'NRO_RECOPI'
                                                  , ev_valor             => rec.nro_recopi );
         --
      end if;
      --
      -- Valida Percentual da mercadoria devolvida
      vn_fase := 4.2;
      --
      if nvl(rec.percent_devol,0) > 0 then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf => est_log_generico_nf
                                                  , en_notafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo => 'PERCENT_DEVOL'
                                                  , ev_valor => to_char(rec.percent_devol, '999D00')
                                                  );
         --
      end if;
      --
      -- Valor do IPI devolvido
      vn_fase := 4.3;
      --
      if nvl(rec.vl_ipi_devol,0) > 0 then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf => est_log_generico_nf
                                                  , en_notafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo => 'VL_IPI_DEVOL'
                                                  , ev_valor => to_char(rec.vl_ipi_devol, '9G999G999G999G999D00')
                                                  );
         --
      end if;
      --
      -- Valor Código Especificador da Substituição Tributária
      vn_fase := 4.4;
      --
      if rec.cod_cest is not null then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf => est_log_generico_nf
                                                  , en_notafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo => 'COD_CEST'
                                                  , ev_valor => rec.cod_cest );
         --
      end if;
      --
      -- Valor Número de controle da FCI - Ficha de Conteúdo de Importação
      vn_fase := 4.5;
      --
      if rec.nro_fci is not null then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf => est_log_generico_nf
                                                  , en_notafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo => 'NRO_FCI'
                                                  , ev_valor => rec.nro_fci );
         --
      end if;
      --
      -- Indicador de Produção em escala relevante, conforme Cláusula 23 do Convenio ICMS 52/2017
      vn_fase := 4.6;
      --
      if trim(rec.dm_ind_esc_rel) is not null then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf => est_log_generico_nf
                                                  , en_notafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo => 'DM_IND_ESC_REL'
                                                  , ev_valor => rec.dm_ind_esc_rel );
         --
      end if;
      --
      -- CNPJ do Fabricante da Mercadoria, obrigatório para produto em escala NÃO relevante
      vn_fase := 4.7;
      --
      if trim(rec.cnpj_fab_merc) is not null then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf => est_log_generico_nf
                                                  , en_notafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo => 'CNPJ_FAB_MERC'
                                                  , ev_valor => rec.CNPJ_FAB_MERC );
         --
      end if;
      --
      -- Código de Benefício Fiscal utilizado pela UF, aplicado ao item. Obs.: Deve ser utilizado o mesmo código adotado na EFD e outras declarações, nas UF que o exigem
      vn_fase := 4.8;
      --
      if nvl(rec.codocorajicms_id,0) > 0 then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf => est_log_generico_nf
                                                  , en_notafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo => 'COD_OCOR_AJ_ICMS'
                                                  , ev_valor => pk_csf_efd.fkg_cod_ocor_aj_icms_cod_aj ( en_id => rec.CODOCORAJICMS_ID )
                                                  );
         --
      end if;
      --
      -- Código identificador da classificação do serviço disponibilizado pelo SPED EFD-REINF
      vn_fase := 4.9;
      --
      if nvl(rec.tiposervreinf_id,0) > 0 then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf => est_log_generico_nf
                                                  , en_notafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo => 'CD_TP_SERV_REINF'
                                                  , ev_valor => pk_csf_reinf.fkg_tipo_serv_reinf_cd ( en_id => rec.tiposervreinf_id )
                                                  );
         --
      end if;
      --
      -- Indicativo do CPRB - SPED EFD-REINF
      vn_fase := 4.10;
      --
      if trim(rec.dm_ind_cprb) is not null then
         --
         pk_csf_api.pkb_integr_Item_Nota_Fiscal_ff( est_log_generico_nf => est_log_generico_nf
                                                  , en_notafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo => 'DM_IND_CPRB'
                                                  , ev_valor => rec.dm_ind_cprb
                                                  );
         --
      end if;
      --
      -- Indicador do Material utilizado
      vn_fase := 4.11;
      --
      if trim(rec.dm_mat_prop_terc) is not null then
         --
         pk_csf_api.pkb_integr_item_nota_fiscal_ff( est_log_generico_nf  => est_log_generico_nf
                                                  , en_notafiscal_id     => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo          => 'DM_MAT_PROP_TERC'
                                                  , ev_valor             => rec.dm_mat_prop_terc );
         --
      end if;
      --
      -- Informações Complementares de Impostos do Item
      vn_fase := 4.12;
      --
      if trim(rec.inf_cpl_imp_item) is not null then
         --
         pk_csf_api.pkb_integr_item_nota_fiscal_ff( est_log_generico_nf  => est_log_generico_nf
                                                  , en_notafiscal_id     => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo          => 'INF_CPL_IMP_ITEM'
                                                  , ev_valor             => rec.inf_cpl_imp_item );
         --
      end if;
      --
      -- Valor de Abatimento Não Tributado e Não Comercial
      vn_fase := 4.13;
      --
      if nvl(rec.vl_abat_nt,0) > 0 then
         --
         pk_csf_api.pkb_integr_item_nota_fiscal_ff( est_log_generico_nf  => est_log_generico_nf
                                                  , en_notafiscal_id     => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo          => 'VL_ABAT_NT'
                                                  , ev_valor             => rec.vl_abat_nt );
         --
      end if;
      --
      -- Id da tabela COD_INF_ADIC_VLR_DECL
      vn_fase := 4.14;
      --
      if nvl(rec.codinfadicvlrdecl_id,0) > 0 then
         --
         pk_csf_api.pkb_integr_item_nota_fiscal_ff( est_log_generico_nf  => est_log_generico_nf
                                                  , en_notafiscal_id     => pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id
                                                  , en_itemnotafiscal_id => pk_csf_api.gt_row_item_nota_fiscal.id
                                                  , ev_atributo          => 'COD_INF_ADIC_VLR_DECL'
                                                  , ev_valor             => rec.codinfadicvlrdecl_id );
         --
      end if;
      --
      vn_fase := 5;
      -- Lê as informações de Impostos do Item da Nota Fiscal
      pkb_ler_Imp_ItemNf ( est_log_generico_nf       => est_log_generico_nf
                         , en_itemnf_id              => rec.id
                         , en_notafiscal_id          => en_notafiscal_id );
      --
      vn_fase := 5.1;
      -- Lê as informações do detalhamento do NCM: NVE
      pkb_ler_itemnf_nve ( est_log_generico_nf          => est_log_generico_nf
                         , en_itemnf_id              => rec.id
                         , en_notafiscal_id          => en_notafiscal_id );
      --
      vn_fase := 5.2;
      -- Lê as informações do Controle de Exportação por Item
      pkb_ler_itemnf_export ( est_log_generico_nf            => est_log_generico_nf
                              , en_itemnf_id              => rec.id
                              , en_notafiscal_id          => en_notafiscal_id );
      --
      vn_fase := 6;
      -- Lê as informações de Combustivel do Item da Nota Fiscal
      pkb_ler_ItemNF_Comb ( est_log_generico_nf      => est_log_generico_nf
                          , en_itemnf_id          => rec.id
                          , en_notafiscal_id      => en_notafiscal_id );
      -- 
      vn_fase := 7;
      -- Lê as informações de Veículos do Item da Nota Fiscal
      pkb_ler_ItemNF_Veic ( est_log_generico_nf          => est_log_generico_nf
                          , en_itemnf_id              => rec.id
                          , en_notafiscal_id          => en_notafiscal_id );
      --
      vn_fase := 8;
      -- Lê as informações de Medicamentos do Item da Nota Fiscal
      pkb_ler_ItemNF_Med ( est_log_generico_nf     => est_log_generico_nf
                         , en_itemnf_id         => rec.id
                         , en_notafiscal_id     => en_notafiscal_id );
      --
      vn_fase := 9;
      -- Lê as informações de Armamentos do Item da Nota Fiscal
      pkb_ler_ItemNF_Arma ( est_log_generico_nf     => est_log_generico_nf
                          , en_itemnf_id         => rec.id
                          , en_notafiscal_id     => en_notafiscal_id );
      --
      vn_fase := 10;
      -- Lê as informações da Declaração de Importação
      pkb_ler_ItemNF_Dec_Impor ( est_log_generico_nf     => est_log_generico_nf
                               , en_itemnf_id         => rec.id
                               , en_notafiscal_id     => en_notafiscal_id );
      --
      vn_fase := 11;
      -- Lê as informações do Complemento de Transporte do Item da Nota Fiscal
      pkb_ler_itemnf_compl_transp ( est_log_generico_nf     => est_log_generico_nf
                                  , en_itemnf_id         => rec.id
                                  , en_notafiscal_id     => en_notafiscal_id );
      --
      vn_fase := 12;
      -- Lê as informações do diferencial de aliquota do Item da Nota Fiscal
      pkb_ler_itemnf_dif_aliq ( est_log_generico_nf   => est_log_generico_nf
                              , en_itemnf_id       => rec.id
                              , en_notafiscal_id   => en_notafiscal_id );
      --
      vn_fase := 13;
      -- Lê as informações complementares de serviço do Item da Nota Fiscal
      pkb_ler_itemnf_compl_serv ( est_log_generico_nf => est_log_generico_nf
                              , en_itemnf_id       => rec.id
                              , en_notafiscal_id   => en_notafiscal_id );
      --
      vn_fase := 14;
      -- Lês as informações de Rastreabilidade de produto
      pkb_ler_itemnf_rastreab ( est_log_generico_nf => est_log_generico_nf
                              , en_itemnf_id        => rec.id
                              , en_notafiscal_id    => en_notafiscal_id
                              );
      --
      vn_fase := 15;
      -- Lês as informações de Ressarcimento de ICMS em operações com substituição Tributária do Item da Nota Fiscal
      pkb_ler_itemnf_res_icms_st ( est_log_generico_nf => est_log_generico_nf
                                 , en_itemnf_id        => rec.id
                                 , en_notafiscal_id    => en_notafiscal_id
                                 );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Item_Nota_Fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Item_Nota_Fiscal;
--
-- =============================================================================================================
-- Procedimento faz a leirura de Cupom Fiscal Referênciado para Validação
procedure pkb_ler_cf_ref ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                         , en_notafiscal_id          in             Nota_Fiscal.id%TYPE  )
is

   cursor c_cf_ref is
   select cfr.*
     from cupom_fiscal_ref  cfr
    where cfr.notafiscal_id = en_notafiscal_id;

   vn_fase               number := 0;
   vv_cod_mod            mod_fiscal.cod_mod%type;

begin
   --
   vn_fase := 1;
   --
   for rec in c_cf_ref loop
      exit when c_cf_ref%notfound or (c_cf_ref%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_cf_ref := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_cf_ref.id                := rec.id;
      pk_csf_api.gt_row_cf_ref.notafiscal_id     := rec.notafiscal_id;
      pk_csf_api.gt_row_cf_ref.modfsical_id      := rec.modfsical_id;
      pk_csf_api.gt_row_cf_ref.ecf_fab           := rec.ecf_fab;
      pk_csf_api.gt_row_cf_ref.ecf_cx            := rec.ecf_cx;
      pk_csf_api.gt_row_cf_ref.num_doc           := rec.num_doc;
      pk_csf_api.gt_row_cf_ref.dt_doc            := rec.dt_doc;
      --
      vv_cod_mod := pk_csf.fkg_cod_mod_id ( en_modfiscal_id => rec.modfsical_id );
      --
      vn_fase := 4;
      --
      -- Chama procedimento que integra as informações de cupom fiscal referenciado
      pk_csf_api.pkb_integr_cf_ref ( est_log_generico_nf          => est_log_generico_nf
                                   , est_row_cf_ref            => pk_csf_api.gt_row_cf_ref
                                   , ev_cod_mod                => vv_cod_mod 
                                   );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_cf_ref fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_cf_ref;

-------------------------------------------------------------------------------------------------------

--carlos
-- Procedimento faz a leirura de Cupom Fiscal Referênciado para Validação

procedure pkb_ler_cfe_ref ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                          , en_notafiscal_id          in             Nota_Fiscal.id%TYPE  )
is

   cursor c_cfe_ref is
   select cfer.*
     from cfe_ref  cfer
    where cfer.notafiscal_id = en_notafiscal_id;

   vn_fase               number := 0;
   vv_cod_mod            mod_fiscal.cod_mod%type;

begin
   --
   --
   vn_fase := 1;
   --
   for rec in c_cfe_ref loop
      exit when c_cfe_ref%notfound or (c_cfe_ref%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_cfe_ref := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_cfe_ref.id                := rec.id;
      pk_csf_api.gt_row_cfe_ref.notafiscal_id     := rec.notafiscal_id;
      pk_csf_api.gt_row_cfe_ref.modfiscal_id      := rec.modfiscal_id;
      pk_csf_api.gt_row_cfe_ref.nr_sat            := rec.nr_sat;
      pk_csf_api.gt_row_cfe_ref.chv_cfe           := rec.chv_cfe;
      pk_csf_api.gt_row_cfe_ref.num_cfe           := rec.num_cfe;
      pk_csf_api.gt_row_cfe_ref.dt_doc            := rec.dt_doc;
      --
      vv_cod_mod := pk_csf.fkg_cod_mod_id ( en_modfiscal_id => rec.modfiscal_id );
      --
      vn_fase := 4;
      --
      -- Chama procedimento que integra as informações de cupom fiscal referenciado
      --
      pk_csf_api.pkb_integr_cfe_ref ( est_log_generico_nf           => est_log_generico_nf
                                    , est_row_cfe_ref            => pk_csf_api.gt_row_cfe_ref
                                    , ev_cod_mod                 => vv_cod_mod 
                                    );
      --
   end loop;
   --
   
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_cfe_ref fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_cfe_ref;

-------------------------------------------------------------------------------------------------------


-- Procedimento faz a leirura das Notas Fiscais Referênciadas para Validação

procedure pkb_ler_nf_referen ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id          in             Nota_Fiscal.id%TYPE  )
is

   cursor c_nf_referen is
   select r.*
     from nota_fiscal_referen   r
    where r.notafiscal_id = en_notafiscal_id;

   vn_fase               number := 0;
   vv_cod_mod            mod_fiscal.cod_mod%type;
   vv_cod_part           pessoa.cod_part%type;

begin
   --
   vn_fase := 1;
   --
   for rec in c_nf_referen loop
      exit when c_nf_referen%notfound or (c_nf_referen%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_referen := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_referen.id                := rec.id;
      pk_csf_api.gt_row_nf_referen.notafiscal_id     := rec.notafiscal_id;
      pk_csf_api.gt_row_nf_referen.nro_chave_nfe     := rec.nro_chave_nfe;
      pk_csf_api.gt_row_nf_referen.ibge_estado_emit  := rec.ibge_estado_emit;
      pk_csf_api.gt_row_nf_referen.cnpj_emit         := rec.cnpj_emit;
      pk_csf_api.gt_row_nf_referen.dt_emiss          := rec.dt_emiss;
      pk_csf_api.gt_row_nf_referen.modfiscal_id      := rec.modfiscal_id;
      pk_csf_api.gt_row_nf_referen.nro_nf            := rec.nro_nf;
      pk_csf_api.gt_row_nf_referen.serie             := rec.serie;
      pk_csf_api.gt_row_nf_referen.subserie          := rec.subserie;
      pk_csf_api.gt_row_nf_referen.pessoa_id         := rec.pessoa_id;
      pk_csf_api.gt_row_nf_referen.dm_ind_oper       := rec.dm_ind_oper;
      pk_csf_api.gt_row_nf_referen.dm_ind_emit       := rec.dm_ind_emit;
      pk_csf_api.gt_row_nf_referen.ie                := rec.ie;
      --
      vv_cod_mod := pk_csf.fkg_cod_mod_id ( en_modfiscal_id => rec.modfiscal_id );
      --
      vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
      --	  
	  -- Verificando se o multorg é nulo para quando essa procedure é chamada da trigger "T_A_I_U_Nota_Fiscal_NF_REF_01"
	  -- e carrega o valor da empresa da nota.
      vn_fase := 3.1;
      --	  
      if gn_multorg_id is null then
         --	
         begin
            --		 
            select em.multorg_id 
              into gn_multorg_id
              from nota_fiscal nf
                 , empresa em
             where nf.id = en_notafiscal_id
               and em.id = nf.empresa_id;
            --
         exception
            when others then
               null;
         end;
         --		 
      end if;	  
      --
      vn_fase := 4;
      --
      -- Chama procedimento que integra as informações de notas fiscais referenciadas
      pk_csf_api.pkb_integr_nf_referen ( est_log_generico_nf   => est_log_generico_nf
                                       , est_row_nf_referen => pk_csf_api.gt_row_nf_referen
                                       , ev_cod_mod         => vv_cod_mod
                                       , ev_cod_part        => vv_cod_part 
                                       , en_multorg_id      => gn_multorg_id
                                       );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_referen fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_referen;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura dos Lacres do Volume Transportado para validação

procedure pkb_ler_NFTranspVol_Lacre ( est_log_generico_nf           in out nocopy  dbms_sql.number_table
                                    , en_nftrvol_id              in             NFTranspVol_Lacre.nftrvol_id%TYPE
                                    , en_notafiscal_id           in             Nota_Fiscal.id%TYPE )
is

   cursor c_NFTranspVol_Lacre is
   select l.*
     from NFTranspVol_Lacre l
    where l.nftrvol_id = en_nftrvol_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_NFTranspVol_Lacre loop
      exit when c_NFTranspVol_Lacre%notfound or (c_NFTranspVol_Lacre%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_NFTranspVol_Lacre := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_NFTranspVol_Lacre.id          := rec.id;
      pk_csf_api.gt_row_NFTranspVol_Lacre.nftrvol_id  := rec.nftrvol_id;
      pk_csf_api.gt_row_NFTranspVol_Lacre.nro_lacre   := rec.nro_lacre;
      --
      vn_fase := 4;
      --
      -- Chama procedimento que faz validação dos lacres dos volumes
      pk_csf_api.pkb_integr_NFTranspVol_Lacre ( est_log_generico_nf            => est_log_generico_nf
                                              , est_row_NFTranspVol_Lacre   => pk_csf_api.gt_row_NFTranspVol_Lacre
                                              , en_notafiscal_id            => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_NFTranspVol_Lacre fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_NFTranspVol_Lacre;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura dos Volumes Transportados da Nota Fiscal para validação

procedure pkb_ler_NFTransp_Vol ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                               , en_nftransp_id            in             NFTransp_Veic.nftransp_id%TYPE
                               , en_notafiscal_id          in             Nota_Fiscal.id%TYPE )
is

   cursor c_NFTransp_Vol is
   select nftv.*
     from NFTransp_Vol   nftv
    where nftv.nftransp_id  = en_nftransp_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_NFTransp_Vol loop
      exit when c_NFTransp_Vol%notfound or (c_NFTransp_Vol%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_NFTransp_Vol := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_NFTransp_Vol.id           := rec.id;
      pk_csf_api.gt_row_NFTransp_Vol.nftransp_id  := rec.nftransp_id;
      pk_csf_api.gt_row_NFTransp_Vol.qtdevol      := rec.qtdevol;
      pk_csf_api.gt_row_NFTransp_Vol.especie      := rec.especie;
      pk_csf_api.gt_row_NFTransp_Vol.marca        := rec.marca;
      pk_csf_api.gt_row_NFTransp_Vol.nro_vol      := rec.nro_vol;
      pk_csf_api.gt_row_NFTransp_Vol.peso_bruto   := rec.peso_bruto;
      pk_csf_api.gt_row_NFTransp_Vol.peso_liq     := rec.peso_liq;
      --
      vn_fase := 4;
      --
      -- Chama procedimento que válida as informações de Volumes do Transporte
      pk_csf_api.pkb_integr_NFTransp_Vol ( est_log_generico_nf       => est_log_generico_nf
                                         , est_row_NFTransp_Vol   => pk_csf_api.gt_row_NFTransp_Vol
                                         , en_notafiscal_id       => en_notafiscal_id );
      --
      vn_fase := 5;
      -- Lê as informações dos lacres dos volumes transportados da Nota Fiscal
      pkb_ler_NFTranspVol_Lacre ( est_log_generico_nf           => est_log_generico_nf
                                , en_nftrvol_id              => rec.id
                                , en_notafiscal_id           => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_NFTransp_Vol fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_NFTransp_Vol;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do veículo e reboques do Transporte da Nota Fiscal para validação

procedure pkb_ler_NFTransp_Veic ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                , en_nftransp_id            in             NFTransp_Veic.nftransp_id%TYPE
                                , en_notafiscal_id          in             Nota_Fiscal.id%TYPE )

is

   cursor c_NFTransp_Veic is
   select nftv.*
     from NFTransp_Veic  nftv
    where nftv.nftransp_id  = en_nftransp_id
    order by nftv.dm_tipo;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_NFTransp_Veic loop
      exit when c_NFTransp_Veic%notfound or (c_NFTransp_Veic%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_NFTransp_Veic := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_NFTransp_Veic.id           := rec.id;
      pk_csf_api.gt_row_NFTransp_Veic.nftransp_id  := rec.nftransp_id;
      pk_csf_api.gt_row_NFTransp_Veic.dm_tipo      := rec.dm_tipo;
      pk_csf_api.gt_row_NFTransp_Veic.placa        := rec.placa;
      pk_csf_api.gt_row_NFTransp_Veic.uf           := rec.uf;
      pk_csf_api.gt_row_NFTransp_Veic.rntc         := rec.rntc;
      pk_csf_api.gt_row_NFTransp_Veic.balsa        := rec.balsa;
      pk_csf_api.gt_row_NFTransp_Veic.vagao        := rec.vagao;
      --
      vn_fase := 4;
      --
      -- Chama procedimento que integra as informações dos veículos do transporte
      pk_csf_api.pkb_integr_NFTransp_Veic ( est_log_generico_nf       => est_log_generico_nf
                                          , est_row_NFTransp_Veic  => pk_csf_api.gt_row_NFTransp_Veic
                                          , en_notafiscal_id       => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_NFTransp_Veic fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_NFTransp_Veic;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do Transporte da Nota Fiscal para validação

procedure pkb_ler_Nota_Fiscal_Transp ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                     , en_notafiscal_id          in             Nota_Fiscal_Transp.notafiscal_id%TYPE )
is

   cursor c_Nota_Fiscal_Transp is
   select nft.*
     from Nota_Fiscal_Transp  nft
    where nft.notafiscal_id   = en_notafiscal_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Nota_Fiscal_Transp loop
      exit when c_Nota_Fiscal_Transp%notfound or (c_Nota_Fiscal_Transp%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Transp := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Transp.id               := rec.id;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.notafiscal_id    := rec.notafiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.dm_mod_frete     := rec.dm_mod_frete;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.cnpj_cpf         := rec.cnpj_cpf;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.pessoa_id        := rec.pessoa_id;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.nome             := rec.nome;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.ie               := rec.ie;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.ender            := rec.ender;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.cidade           := rec.cidade;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.cidade_ibge      := rec.cidade_ibge;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.uf               := rec.uf;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.vl_serv          := rec.vl_serv;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.vl_basecalc_ret  := rec.vl_basecalc_ret;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.aliqicms_ret     := rec.aliqicms_ret;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.vl_icms_ret      := rec.vl_icms_ret;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.cfop_id          := rec.cfop_id;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.cfop             := rec.cfop;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.cpf_mot          := rec.cpf_mot;
      pk_csf_api.gt_row_Nota_Fiscal_Transp.nome_mot         := rec.nome_mot;
      --
      vn_fase := 4;
      --
      -- Chama procedimento que válida as informações de transporte
      pk_csf_api.pkb_integr_Nota_Fiscal_Transp ( est_log_generico_nf            => est_log_generico_nf
                                               , est_row_Nota_Fiscal_Transp  => pk_csf_api.gt_row_Nota_Fiscal_Transp
                                               , en_multorg_id               => gn_multorg_id );
      --
      vn_fase := 5;
      -- Lê as informações do véiculo e reboques do Transporte da Nota Fiscal
      pkb_ler_NFTransp_Veic ( est_log_generico_nf          => est_log_generico_nf
                            , en_nftransp_id            => rec.id
                            , en_notafiscal_id          => en_notafiscal_id );
      --
      vn_fase := 6;
      -- Lê as informações dos Volumes Transportados da Nota Fiscal
      pkb_ler_NFTransp_Vol ( est_log_generico_nf          => est_log_generico_nf
                           , en_nftransp_id            => rec.id
                           , en_notafiscal_id          => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_Transp fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal_Transp;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura da Local Coleta/Entrega da Nota Fiscal

procedure pkb_ler_Nota_Fiscal_Local ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id          in             Nota_Fiscal_Local.notafiscal_id%TYPE )
is

   cursor c_Nota_Fiscal_Local is
   select nfl.*
     from Nota_Fiscal_Local nfl
    where nfl.notafiscal_id = en_notafiscal_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Nota_Fiscal_Local loop
      exit when c_Nota_Fiscal_Local%notfound or (c_Nota_Fiscal_Local%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Local := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Local.id             := rec.id;
      pk_csf_api.gt_row_Nota_Fiscal_Local.notafiscal_id  := rec.notafiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal_Local.dm_tipo_local  := rec.dm_tipo_local;
      pk_csf_api.gt_row_Nota_Fiscal_Local.cnpj           := rec.cnpj;
      pk_csf_api.gt_row_Nota_Fiscal_Local.lograd         := rec.lograd;
      pk_csf_api.gt_row_Nota_Fiscal_Local.nro            := rec.nro;
      pk_csf_api.gt_row_Nota_Fiscal_Local.compl          := rec.compl;
      pk_csf_api.gt_row_Nota_Fiscal_Local.bairro         := rec.bairro;
      pk_csf_api.gt_row_Nota_Fiscal_Local.cidade         := rec.cidade;
      pk_csf_api.gt_row_Nota_Fiscal_Local.cidade_ibge    := rec.cidade_ibge;
      pk_csf_api.gt_row_Nota_Fiscal_Local.uf             := rec.uf;
      pk_csf_api.gt_row_Nota_Fiscal_Local.dm_ind_carga   := rec.dm_ind_carga;
      pk_csf_api.gt_row_Nota_Fiscal_Local.cpf            := rec.cpf;
      pk_csf_api.gt_row_Nota_Fiscal_Local.ie             := rec.ie;
      --
      vn_fase := 4;
      --
      -- Chama procedimento que válida as informações do Local Coleta/Entrega
      pk_csf_api.pkb_integr_Nota_Fiscal_Local ( est_log_generico_nf        => est_log_generico_nf
                                              , est_row_Nota_Fiscal_Local  => pk_csf_api.gt_row_Nota_Fiscal_Local );
      --
      vn_fase := 4.1;
      -- Chama procedimento que faz a validação das flex-field da nota_fiscal_local
      -- Valida nome
      if trim(rec.nome) is not null then
         --
         pk_csf_api.pkb_integr_Nota_Fiscal_Localff( est_log_generico_nf   => est_log_generico_nf
                                                   , en_notafiscal_id      => pk_csf_api.gt_row_Nota_Fiscal_Local.notafiscal_id
                                                   , en_notafiscallocal_id => pk_csf_api.gt_row_Nota_Fiscal_Local.id
                                                   , ev_atributo           => 'NOME'
                                                   , ev_valor              => rec.nome );
         --
      end if;
      --
      -- Valida cep
      if trim(rec.cep) is not null then
         --
         pk_csf_api.pkb_integr_Nota_Fiscal_Localff( est_log_generico_nf   => est_log_generico_nf
                                                   , en_notafiscal_id      => pk_csf_api.gt_row_Nota_Fiscal_Local.notafiscal_id
                                                   , en_notafiscallocal_id => pk_csf_api.gt_row_Nota_Fiscal_Local.id
                                                   , ev_atributo           => 'CEP'
                                                   , ev_valor              => rec.cep );
         --
      end if;
      --
      -- Valida cod_pais
      if trim(rec.cod_pais) is not null then
         --
         pk_csf_api.pkb_integr_Nota_Fiscal_Localff( est_log_generico_nf   => est_log_generico_nf
                                                   , en_notafiscal_id      => pk_csf_api.gt_row_Nota_Fiscal_Local.notafiscal_id
                                                   , en_notafiscallocal_id => pk_csf_api.gt_row_Nota_Fiscal_Local.id
                                                   , ev_atributo           => 'COD_PAIS'
                                                   , ev_valor              => rec.cod_pais );
         --
      end if;
      --
      -- Valida desc_pais
      if trim(rec.desc_pais) is not null then
         --
         pk_csf_api.pkb_integr_Nota_Fiscal_Localff( est_log_generico_nf   => est_log_generico_nf
                                                   , en_notafiscal_id      => pk_csf_api.gt_row_Nota_Fiscal_Local.notafiscal_id
                                                   , en_notafiscallocal_id => pk_csf_api.gt_row_Nota_Fiscal_Local.id
                                                   , ev_atributo           => 'DESC_PAIS'
                                                   , ev_valor              => rec.desc_pais );
         --
      end if;
      --
      -- Valida fone
      if trim(rec.fone) is not null then
         --
         pk_csf_api.pkb_integr_Nota_Fiscal_Localff( est_log_generico_nf   => est_log_generico_nf
                                                   , en_notafiscal_id      => pk_csf_api.gt_row_Nota_Fiscal_Local.notafiscal_id
                                                   , en_notafiscallocal_id => pk_csf_api.gt_row_Nota_Fiscal_Local.id
                                                   , ev_atributo           => 'FONE'
                                                   , ev_valor              => rec.fone );
         --
      end if;
      --
      -- Valida email
      if trim(rec.email) is not null then
         --
         pk_csf_api.pkb_integr_Nota_Fiscal_Localff( est_log_generico_nf   => est_log_generico_nf
                                                   , en_notafiscal_id      => pk_csf_api.gt_row_Nota_Fiscal_Local.notafiscal_id
                                                   , en_notafiscallocal_id => pk_csf_api.gt_row_Nota_Fiscal_Local.id
                                                   , ev_atributo           => 'EMAIL'
                                                   , ev_valor              => rec.email );
         --
      end if;

   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_Local fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal_Local;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura das Duplicatas a Notas Fiscal

procedure pkb_ler_NFCobr_Dup ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                             , en_nfcobr_id              in             nfcobr_dup.nfcobr_id%TYPE
                             , en_notafiscal_id          in             Nota_Fiscal.id%TYPE )
is

   cursor c_NFCobr_Dup is
   select d.*
     from NFCobr_Dup   d
    where d.nfcobr_id  = en_nfcobr_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_NFCobr_Dup loop
      exit when c_NFCobr_Dup%notfound or (c_NFCobr_Dup%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_NFCobr_Dup := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_NFCobr_Dup.id         := rec.id;
      pk_csf_api.gt_row_NFCobr_Dup.nfcobr_id  := rec.nfcobr_id;
      pk_csf_api.gt_row_NFCobr_Dup.nro_parc   := rec.nro_parc;
      pk_csf_api.gt_row_NFCobr_Dup.dt_vencto  := rec.dt_vencto;
      pk_csf_api.gt_row_NFCobr_Dup.vl_dup     := rec.vl_dup;
      --
      vn_fase := 4;
      --
      -- Chama o procedimento de integração das duplicatas
      pk_csf_api.pkb_integr_NFCobr_Dup ( est_log_generico_nf    => est_log_generico_nf
                                       , est_row_NFCobr_Dup  => pk_csf_api.gt_row_NFCobr_Dup
                                       , en_notafiscal_id    => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_NFCobr_Dup fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_NFCobr_Dup;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura da Cobrança da Nota Fiscal

procedure pkb_ler_Nota_Fiscal_Cobr ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                   , en_notafiscal_id          in             Nota_Fiscal_Cobr.notafiscal_id%TYPE )
is

   cursor c_Nota_Fiscal_Cobr is
   select nfc.*
     from Nota_Fiscal_Cobr  nfc
    where nfc.notafiscal_id = en_notafiscal_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Nota_Fiscal_Cobr loop
      exit when c_Nota_Fiscal_Cobr%notfound or (c_Nota_Fiscal_Cobr%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Cobr := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Cobr.id             := rec.id;
      pk_csf_api.gt_row_Nota_Fiscal_Cobr.notafiscal_id  := rec.notafiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal_Cobr.dm_ind_emit    := rec.dm_ind_emit;
      pk_csf_api.gt_row_Nota_Fiscal_Cobr.dm_ind_tit     := rec.dm_ind_tit;
      pk_csf_api.gt_row_Nota_Fiscal_Cobr.nro_fat        := rec.nro_fat;
      pk_csf_api.gt_row_Nota_Fiscal_Cobr.vl_orig        := rec.vl_orig;
      pk_csf_api.gt_row_Nota_Fiscal_Cobr.vl_desc        := rec.vl_desc;
      pk_csf_api.gt_row_Nota_Fiscal_Cobr.vl_liq         := rec.vl_liq;
      pk_csf_api.gt_row_Nota_Fiscal_Cobr.descr_tit      := rec.descr_tit;
      --
      vn_fase := 4;
      -- Chama o procedimento que válida os dados da Fatura de Cobrança da Nota Fiscal
      pk_csf_api.pkb_integr_Nota_Fiscal_Cobr ( est_log_generico_nf          => est_log_generico_nf
                                             , est_row_Nota_Fiscal_Cobr  => pk_csf_api.gt_row_Nota_Fiscal_Cobr );
      --
      vn_fase := 5;
      -- Lê dados da Duplicata da Nota Fiscal
      pkb_ler_NFCobr_Dup ( est_log_generico_nf          => est_log_generico_nf
                         , en_nfcobr_id              => rec.id
                         , en_notafiscal_id          => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_Cobr fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal_Cobr;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura da Informações Fiscais da Nota Fiscal

procedure pkb_ler_NFInfor_Fiscal ( est_log_generico_nf    in out nocopy  dbms_sql.number_table
                                 , en_notafiscal_id    in             NFInfor_Fiscal.notafiscal_id%TYPE )
is

   cursor c_NFInfor_Fiscal is
   select inf.*
     from NFInfor_Fiscal     inf
    where inf.notafiscal_id = en_notafiscal_id;

   vn_fase               number := 0;
   vv_cod_obs            Obs_Lancto_Fiscal.cod_obs%type;

begin
   --
   vn_fase := 1;
   --
   for rec in c_NFInfor_Fiscal loop
      exit when c_NFInfor_Fiscal%notfound or (c_NFInfor_Fiscal%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_NFInfor_Fiscal := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_NFInfor_Fiscal.id                  := rec.id;
      pk_csf_api.gt_row_NFInfor_Fiscal.notafiscal_id       := rec.notafiscal_id;
      pk_csf_api.gt_row_NFInfor_Fiscal.obslanctofiscal_id  := rec.obslanctofiscal_id;
      pk_csf_api.gt_row_NFInfor_Fiscal.txt_compl           := rec.txt_compl;
      --
      vv_cod_obs := pk_csf.fkg_cd_obs_lancto_fiscal ( en_obslanctofiscal_id => rec.obslanctofiscal_id );
      --
      vn_fase := 4;
      --
      -- Chama o procedimento de validação dos dados da Informações Fiscais da Nota Fiscal
      pk_csf_api.pkb_integr_NFInfor_Fiscal ( est_log_generico_nf       => est_log_generico_nf
                                           , est_row_NFInfor_Fiscal => pk_csf_api.gt_row_NFInfor_Fiscal
                                           , ev_cd_obs              => vv_cod_obs
                                           , en_multorg_id          => gn_multorg_id
                                           );
      vn_fase := 5;
      --  Lê as informações do Ajuste do Item da Nota Fiscal
      pkb_ler_inf_prov_docto_fiscal ( est_log_generico_nf    => est_log_generico_nf
                                    , en_nfinforfiscal_id => rec.id
                                    , en_notafiscal_id    => en_notafiscal_id
                                    );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_NFInfor_Fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_NFInfor_Fiscal;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura da Informação Adicional da Nota Fiscal

procedure pkb_ler_NFInfor_Adic ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                               , en_notafiscal_id          in             NFInfor_Adic.notafiscal_id%TYPE )
is

   cursor c_NFInfor_Adic is
   select inf.*
     from NFInfor_Adic  inf
    where inf.notafiscal_id = en_notafiscal_id;

   vn_fase               number := 0;
   vn_cd_orig_proc       orig_proc.cd%type;

begin
   --
   vn_fase := 1;
   --
   for rec in c_NFInfor_Adic loop
      exit when c_NFInfor_Adic%notfound or (c_NFInfor_Adic%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_NFInfor_Adic := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_NFInfor_Adic.id                 := rec.id;
      pk_csf_api.gt_row_NFInfor_Adic.notafiscal_id      := rec.notafiscal_id;
      pk_csf_api.gt_row_NFInfor_Adic.dm_tipo            := rec.dm_tipo;
      pk_csf_api.gt_row_NFInfor_Adic.infcompdctofis_id  := rec.infcompdctofis_id;
      pk_csf_api.gt_row_NFInfor_Adic.campo              := rec.campo;
      pk_csf_api.gt_row_NFInfor_Adic.conteudo           := rec.conteudo;
      pk_csf_api.gt_row_NFInfor_Adic.origproc_id        := rec.origproc_id;
      --
      vn_cd_orig_proc := pk_csf.fkg_Orig_Proc_cd ( en_origproc_id => rec.origproc_id );
      --
      vn_fase := 4;
      --
      -- Chama o procedimento de validação dos dados da Informação Adicional da Nota Fiscal
      pk_csf_api.pkb_integr_NFInfor_Adic ( est_log_generico_nf          => est_log_generico_nf
                                         , est_row_NFInfor_Adic      => pk_csf_api.gt_row_NFInfor_Adic 
                                         , en_cd_orig_proc           => vn_cd_orig_proc
                                         );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_NFInfor_Adic fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_NFInfor_Adic;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura dos Totais da Nota Fiscal

procedure pkb_ler_Nota_Fiscal_Total ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                    , en_notafiscal_id          in             Nota_Fiscal_Total.notafiscal_id%TYPE )
is

   cursor c_Nota_Fiscal_Total is
   select nft.*
     from Nota_Fiscal_Total  nft
    where nft.notafiscal_id  = en_notafiscal_id;

   vn_fase               number := 0;

Begin
   --
   vn_fase := 1;
   --
   for rec in c_Nota_Fiscal_Total loop
      exit when c_Nota_Fiscal_Total%notfound or (c_Nota_Fiscal_Total%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Total := null;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Total.id                     := rec.id;
      pk_csf_api.gt_row_Nota_Fiscal_Total.notafiscal_id          := rec.notafiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_base_calc_icms      := rec.vl_base_calc_icms;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_imp_trib_icms       := rec.vl_imp_trib_icms;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_base_calc_st        := rec.vl_base_calc_st;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_imp_trib_st         := rec.vl_imp_trib_st;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_total_item          := rec.vl_total_item;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_frete               := rec.vl_frete;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_seguro              := rec.vl_seguro;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_desconto            := rec.vl_desconto;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_imp_trib_ii         := rec.vl_imp_trib_ii;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_imp_trib_ipi        := rec.vl_imp_trib_ipi;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_imp_trib_pis        := rec.vl_imp_trib_pis;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_imp_trib_cofins     := rec.vl_imp_trib_cofins;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_outra_despesas      := rec.vl_outra_despesas;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_total_nf            := rec.vl_total_nf;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_serv_nao_trib       := rec.vl_serv_nao_trib;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_base_calc_iss       := rec.vl_base_calc_iss;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_imp_trib_iss        := rec.vl_imp_trib_iss;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_pis_iss             := rec.vl_pis_iss;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_cofins_iss          := rec.vl_cofins_iss;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_ret_pis             := rec.vl_ret_pis;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_ret_cofins          := rec.vl_ret_cofins;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_ret_csll            := rec.vl_ret_csll;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_base_calc_irrf      := rec.vl_base_calc_irrf;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_ret_irrf            := rec.vl_ret_irrf;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_base_calc_ret_prev  := rec.vl_base_calc_ret_prev;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_ret_prev            := rec.vl_ret_prev;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_total_serv          := rec.vl_total_serv;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_tot_trib            := rec.vl_tot_trib;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_icms_deson          := rec.vl_icms_deson;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_deducao             := rec.vl_deducao;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_outras_ret          := rec.vl_outras_ret;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_desc_incond         := rec.vl_desc_incond;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_desc_cond           := rec.vl_desc_cond;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_icms_uf_dest        := rec.vl_icms_uf_dest;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_icms_uf_remet       := rec.vl_icms_uf_remet;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_comb_pobr_uf_dest   := rec.vl_comb_pobr_uf_dest;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_fcp                 := rec.vl_fcp;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_fcp_st              := rec.vl_fcp_st;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_fcp_st_ret          := rec.vl_fcp_st_ret;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_ipi_devol           := rec.vl_ipi_devol;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_abat_nt             := rec.vl_abat_nt;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_pis_st              := rec.vl_pis_st;
      pk_csf_api.gt_row_Nota_Fiscal_Total.vl_cofins_st           := rec.vl_cofins_st;
      --
      -- Chama o procedimento de validação dos dados dos Totais da Nota Fiscal
      pk_csf_api.pkb_integr_Nota_Fiscal_Total ( est_log_generico_nf        => est_log_generico_nf
                                              , est_row_Nota_Fiscal_Total  => pk_csf_api.gt_row_Nota_Fiscal_Total );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_Total fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal_Total;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do e-mail por tipo de anexo do destinatário e valida a informação

procedure pkb_ler_nfdest_email ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                               , en_notafiscaldest_id      in             nfdest_email.notafiscaldest_id%TYPE 
                               , en_notafiscal_id          in             nota_fiscal.id%type )
is

   vn_fase               number := 0;

   cursor c_nfdest_email is
   select e.*
     from nfdest_email e
    where e.notafiscaldest_id = en_notafiscaldest_id;

begin
   --
   vn_fase := 1;
   --
   for rec in c_nfdest_email loop
      exit when c_nfdest_email%notfound or (c_nfdest_email%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nfdest_email := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nfdest_email.id                 := rec.id;
      pk_csf_api.gt_row_nfdest_email.notafiscaldest_id  := rec.notafiscaldest_id;
      pk_csf_api.gt_row_nfdest_email.email              := rec.email;
      pk_csf_api.gt_row_nfdest_email.dm_tipo_anexo      := rec.dm_tipo_anexo;
      pk_csf_api.gt_row_nfdest_email.dm_st_email        := rec.dm_st_email;
      --
      vn_fase := 4;
      --
      pk_csf_api.pkb_integr_nfdest_email ( est_log_generico_nf      => est_log_generico_nf
                                         , est_row_nfdest_email  => pk_csf_api.gt_row_nfdest_email
                                         , en_notafiscal_id      => en_notafiscal_id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nfdest_email fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nfdest_email;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do destinatário da Nota Fiscal e válida a informação

procedure pkb_ler_Nota_Fiscal_Dest ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                   , en_notafiscal_id          in             Nota_Fiscal_Dest.notafiscal_id%TYPE )
is

   cursor c_Nota_Fiscal_Dest is
   select nfd.*
     from Nota_Fiscal_Dest  nfd
    where nfd.notafiscal_id = en_notafiscal_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Nota_Fiscal_Dest loop
      exit when c_Nota_Fiscal_Dest%notfound or (c_Nota_Fiscal_Dest%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Dest := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Dest.id             := rec.id;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.notafiscal_id  := rec.notafiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.cnpj           := rec.cnpj;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.cpf            := rec.cpf;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.nome           := rec.nome;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.lograd         := rec.lograd;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.nro            := rec.nro;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.compl          := rec.compl;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.bairro         := rec.bairro;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.cidade         := rec.cidade;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.cidade_ibge    := rec.cidade_ibge;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.uf             := rec.uf;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.cep            := rec.cep;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.cod_pais       := rec.cod_pais;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.pais           := rec.pais;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.fone           := rec.fone;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.ie             := rec.ie;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.suframa        := rec.suframa;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.email          := rec.email;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.id_estrangeiro := rec.id_estrangeiro;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.dm_ind_ie_dest := rec.dm_ind_ie_dest;
      pk_csf_api.gt_row_Nota_Fiscal_Dest.im             := rec.im;
      --
      vn_fase := 4;
      --
      -- Chama o procedimento de validação dos dados do Destinatário da Nota Fiscal
      pk_csf_api.pkb_integr_Nota_Fiscal_Dest ( est_log_generico_nf          => est_log_generico_nf
                                             , est_row_Nota_Fiscal_Dest  => pk_csf_api.gt_row_Nota_Fiscal_Dest
                                             , ev_cod_part               => null
                                             , en_multorg_id             => gn_multorg_id );
      --
      vn_fase := 5;
      --
      pkb_ler_nfdest_email ( est_log_generico_nf          => est_log_generico_nf
                           , en_notafiscaldest_id      => pk_csf_api.gt_row_Nota_Fiscal_Dest.id
                           , en_notafiscal_id          => en_notafiscal_id
                           );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_Dest fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal_Dest;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura do emitente da Nota Fiscal e válida a informação

procedure pkb_ler_Nota_Fiscal_Emit ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                                   , en_notafiscal_id          in             Nota_Fiscal_Emit.notafiscal_id%TYPE
                                   , en_empresa_id             in             Empresa.id%TYPE
                                   , en_dm_ind_emit            in             Nota_Fiscal.dm_ind_emit%TYPE )
is

   cursor c_Nota_Fiscal_Emit is
   select nfe.*
     from Nota_Fiscal_Emit  nfe
    where nfe.notafiscal_id = en_notafiscal_id;

   vn_fase               number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Nota_Fiscal_Emit loop
      exit when c_Nota_Fiscal_Emit%notfound or (c_Nota_Fiscal_Emit%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Emit := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Emit.id             := rec.id;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.notafiscal_id  := rec.notafiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.nome           := rec.nome;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.fantasia       := rec.fantasia;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.lograd         := rec.lograd;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.nro            := rec.nro;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.compl          := rec.compl;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.bairro         := rec.bairro;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.cidade         := rec.cidade;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.cidade_ibge    := rec.cidade_ibge;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.uf             := rec.uf;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.cep            := rec.cep;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.cod_pais       := rec.cod_pais;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.pais           := rec.pais;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.fone           := rec.fone;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.ie             := rec.ie;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.iest           := rec.iest;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.im             := rec.im;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.cnae           := rec.cnae;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.cnpj           := rec.cnpj;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.cpf            := rec.cpf;
      pk_csf_api.gt_row_Nota_Fiscal_Emit.dm_reg_trib    := rec.dm_reg_trib;
      --
      vn_fase := 4;
      -- Chama o procedimento de validação dos dados do Emitente da Nota Fiscal
      pk_csf_api.pkb_integr_Nota_Fiscal_Emit ( est_log_generico_nf          => est_log_generico_nf
                                             , est_row_Nota_Fiscal_Emit  => pk_csf_api.gt_row_Nota_Fiscal_Emit
                                             , en_empresa_id             => en_empresa_id
                                             , en_dm_ind_emit            => en_dm_ind_emit
                                             , ev_cod_part               => null );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_Emit fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal_Emit;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura ds Autorização de acesso ao XML da Nota Fiscal

procedure pkb_ler_nf_aut_xml ( est_log_generico_nf          in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id          in             nf_aut_xml.notafiscal_id%TYPE )
is

   cursor c_nf_aut_xml is
   select nax.*
     from nf_aut_xml  nax
    where nax.notafiscal_id = en_notafiscal_id;

   vn_fase    number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_nf_aut_xml loop
      exit when c_nf_aut_xml%notfound or (c_nf_aut_xml%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_aut_xml := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_aut_xml.id             := rec.id;
      pk_csf_api.gt_row_nf_aut_xml.notafiscal_id  := rec.notafiscal_id;
      pk_csf_api.gt_row_nf_aut_xml.cnpj           := rec.cnpj;
      pk_csf_api.gt_row_nf_aut_xml.cpf            := rec.cpf;
      --
      vn_fase := 4;
      --
      -- Chama o procedimento de validação dos dados do Destinatário da Nota Fiscal
      pk_csf_api.pkb_integr_nf_aut_xml ( est_log_generico_nf           => est_log_generico_nf
                                       , est_row_nf_aut_xml         => pk_csf_api.gt_row_nf_aut_xml );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_aut_xml fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_aut_xml;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura ds Formas de Pagamento

procedure pkb_ler_nf_forma_pgto ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                                , en_notafiscal_id          in             nf_forma_pgto.notafiscal_id%TYPE
                                )
is

   cursor c_nf_forma_pgto is
   select nax.*
     from nf_forma_pgto  nax
    where nax.notafiscal_id = en_notafiscal_id;

   vn_fase    number := 0;

begin
   --
   vn_fase := 1;
   --
   for rec in c_nf_forma_pgto loop
      exit when c_nf_forma_pgto%notfound or (c_nf_forma_pgto%notfound) is null;
      --
      vn_fase := 2;
      --
      pk_csf_api.gt_row_nf_forma_pgto := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nf_forma_pgto := rec;
      --
      vn_fase := 4;
      --
      -- Chama o procedimento de validação dos dados do Destinatário da Nota Fiscal
      pk_csf_api.pkb_integr_nf_forma_pgto ( est_log_generico_nf           => est_log_generico_nf
                                          , est_row_nf_forma_pgto         => pk_csf_api.gt_row_nf_forma_pgto
                                          );
      --
      vn_fase := 5;
      --
      -- Tipo de Integração para pagamento
      if nvl(rec.DM_TP_INTEGRA,0) > 0 then
         --
         pk_csf_api.pkb_integr_nf_forma_pgto_ff ( est_log_generico_nf => est_log_generico_nf
                                                , en_notafiscal_id    => en_notafiscal_id
                                                , en_nfformapgto_id   => rec.id
                                                , ev_atributo         => 'DM_TP_INTEGRA'
                                                , ev_valor            => rec.DM_TP_INTEGRA
                                                );
         --
      end if;
      --
      vn_fase := 6;
      -- Valor do Troco
      if nvl(rec.VL_TROCO,0) > 0 then
         --
         pk_csf_api.pkb_integr_nf_forma_pgto_ff ( est_log_generico_nf => est_log_generico_nf
                                                , en_notafiscal_id    => en_notafiscal_id
                                                , en_nfformapgto_id   => rec.id
                                                , ev_atributo         => 'VL_TROCO'
                                                , ev_valor            => to_char(rec.VL_TROCO, '9G999G999G999D99')
                                                );
         --
      end if;
      --
      vn_fase := 7;
      -- Indicador da forma de pagamento
      if nvl(rec.DM_IND_PAG,0) > 0 then
         --
         pk_csf_api.pkb_integr_nf_forma_pgto_ff ( est_log_generico_nf => est_log_generico_nf
                                                , en_notafiscal_id    => en_notafiscal_id
                                                , en_nfformapgto_id   => rec.id
                                                , ev_atributo         => 'DM_IND_PAG'
                                                , ev_valor            => rec.DM_IND_PAG
                                                );
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nf_forma_pgto fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => en_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nf_forma_pgto;

-------------------------------------------------------------------------------------------------------
-- Procedimento de excluir os impostos se utilizar a calculadora fiscal
procedure pkb_excluir_imp_itemnf_cf ( en_notafiscal_id in nota_fiscal.id%type 
                                    , en_dm_ind_emit   in nota_fiscal.dm_ind_emit%type
                                    , en_empresa_id    in empresa.id%type
                                    )
is
   --
   vn_fase               number := 0;
   vn_dm_util_epropria          param_empr_calc_fiscal.dm_util_epropria%type;
   vn_dm_util_eterceiro         param_empr_calc_fiscal.dm_util_eterceiro%type;
   --
   cursor c_item is
   select id
     from item_nota_fiscal
	where notafiscal_id = en_notafiscal_id
    order by id;
   --
   cursor c_imp ( en_itemnf_id item_nota_fiscal.id%type ) is
   select id
     from imp_itemnf
    where itemnf_id = en_itemnf_id
    order by id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_notafiscal_id,0) > 0
      and nvl(en_dm_ind_emit,-1) in (0, 1)
      and nvl(en_empresa_id,0) > 0
      then
      --
      vn_fase := 2;
      --
      if en_dm_ind_emit = 0 then -- Emissão Propria
         --
         vn_fase := 2.1;
         vn_dm_util_epropria := pk_csf_calc_fiscal.fkg_empr_util_epropria ( en_empresa_id => en_empresa_id );
         vn_dm_util_eterceiro := 0;
         --
      else
         --
         vn_fase := 2.2;
         vn_dm_util_epropria := 0;
         vn_dm_util_eterceiro := pk_csf_calc_fiscal.fkg_empr_util_eterceiro ( en_empresa_id => en_empresa_id );
         --
      end if;
      --
      vn_fase := 3;
      --
      if nvl(vn_dm_util_epropria,0) = 1 -- Sim, utiliza Calculadora Fiscal
         or nvl(vn_dm_util_eterceiro,0) = 1
         then
         --
         vn_fase := 3.1;
         --
         -- exclui detalhes dos itens
         for rec in c_item loop
            exit when c_item%notfound or (c_item%notfound);
            --
            vn_fase := 3.2;
            for rec_imp in c_imp(rec.id) loop
               exit when c_imp%notfound or (c_imp%notfound) is null;
               --
               delete from imp_itemnf_icms_dest
                where impitemnf_id = rec_imp.id;
               --
            end loop;
            --
            vn_fase := 3.3;
            delete from imp_itemnf ii
             where ii.itemnf_id = rec.id
               and ii.tipoimp_id not in (select ti.id from tipo_imposto ti where ti.cd = 7);
            --
         end loop;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_excluir_imp_itemnf_cf fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem          => pk_csf_api.gv_cabec_log
                                        , ev_resumo            => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log          => pk_csf_api.ERRO_DE_SISTEMA
                                        , en_referencia_id     => en_notafiscal_id
                                        , ev_obj_referencia    => 'NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_excluir_imp_itemnf_cf;

-------------------------------------------------------------------------------------------------------
-- Procedimento de executar rotinas programadas de pré-validação para NF mercantil
procedure pkb_exec_rot_prog_pv_nf ( en_notafiscal_id  in nota_fiscal.id%type
                                  , ed_dt_emiss       in nota_fiscal.dt_emiss%type
                                  , en_usuario_id     in neo_usuario.id%type
                                  , en_empresa_id     in empresa.id%type
                                  )
is
   --
   vn_fase               number := 0;
   vv_unid_org_cd        unid_org.cd%type;
   vn_multorg_id         mult_org.id%type;
   vn_objintegr_id       obj_integr.id%type;
   vn_usuario_id         number;
   vv_maquina            varchar2(255);
   --
begin
   --
   vn_fase := 1;
   --
   vn_multorg_id := pk_csf.fkg_multorg_id_empresa( en_empresa_id => en_empresa_id );
   --
   -- Recupera o id do objeto de integração
      --
      begin
         select id
           into vn_objintegr_id
           from obj_integr
          where cd in ( select '16'  -- XML Sefaz - Nota Fiscal Mercantil
                          from r_loteintws_envdocfiscal r2
                         where r2.notafiscal_id = en_notafiscal_id ); 		  
      exception
         when no_data_found then
            begin
               select id
                 into vn_objintegr_id
                 from obj_integr
                where cd = '6'; -- Nota Fiscal Mercantil
            exception
               when others then
                  vn_objintegr_id := 0;
            end;
         when others then
            vn_objintegr_id := 0;
      end;	  
      --
      vn_fase := 5;
      -- Recupera o USUARIO_ID
      vn_usuario_id := null;
      --
      if nvl(en_usuario_id,0) > 0 then
         --
         vn_usuario_id := en_usuario_id;
         --
      end if;
      --
      vn_fase := 6;
      --
      if nvl(vn_usuario_id,0) <= 0 then
         --
         begin
            --
            select min(id)
              into vn_usuario_id
              from neo_usuario
             where multorg_id = vn_multorg_id;
            --
         exception
            when others then
            null;
         end;
         --
      end if;
      --
      vn_fase := 7;
      -- Recupera o nome da máquina
      --
      vv_maquina := sys_context('USERENV', 'HOST');
      --
      if vv_maquina is null then
         --
         vv_maquina := 'Servidor';
         --
      end if;
      --
      vn_fase := 8;
      -- Chama o procedimento de execução das rotinas programaveis do tipo "Emissão Online"
      pk_csf_rot_prog.pkb_exec_rot_prog_online_pv ( en_id_doc          => en_notafiscal_id
                                                  , ed_dt_ini          => ed_dt_emiss
                                                  , ed_dt_fin          => ed_dt_emiss
                                                  , ev_obj_referencia  => 'NOTA_FISCAL'
                                                  , en_referencia_id   => en_notafiscal_id
                                                  , en_usuario_id      => vn_usuario_id
                                                  , ev_maquina         => vv_maquina
                                                  , en_objintegr_id    => vn_objintegr_id
                                                  , en_multorg_id      => vn_multorg_id
                                                  , en_empresa_id      => en_empresa_id
                                                  );
      --
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pkb_exec_rot_prog_pv_nf fase(' || vn_fase || '): ' || sqlerrm;
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
                                            , ev_obj_referencia    => 'NOTA_FISCAL'
                                            );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_exec_rot_prog_pv_nf;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a leitura de uma NF para validação

procedure pkb_ler_Nota_Fiscal ( en_notafiscal_id in nota_fiscal.id%type
                              , en_loteintws_id  in lote_int_ws.id%type default 0
                              )
is
   --
   vn_fase                 number := 0;
   vt_log_generico_nf      dbms_sql.number_table;
   vn_notafiscal_id        Nota_Fiscal.id%TYPE;
   vn_dm_st_proc           nota_fiscal.dm_st_proc%type;
   vn_existe_canc          number;
   vv_sist_orig_sigla      sist_orig.sigla%type;
   vv_unid_org_cd          unid_org.cd%type;
   vn_dm_st_integra        nota_fiscal.dm_st_integra%type;
   vv_cod_part             pessoa.cod_part%type;
   vn_dm_aguard_liber_nfe  empresa.dm_aguard_liber_nfe%type;
   vv_cd_sitdocto          sit_docto.cd%type;
   vn_sitdocto_id          nota_fiscal.sitdocto_id%type;
   --
   cursor c_Nota_Fiscal is
   select nf.*
        , mf.cod_mod
     from Nota_Fiscal   nf
        , Mod_Fiscal    mf
    where nf.id              = en_notafiscal_id
      and nf.dm_arm_nfe_terc = 0
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55', '65')
      and not exists (select 1 from nota_fiscal_canc nfc where nfc.notafiscal_id = nf.id and nfc.DM_CANC_SERVICO = 1)
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
   --
   vb_entrou := false; -- 1979

   vn_empresa_id := pk_csf.fkg_empresa_notafiscal(en_notafiscal_id);
   vn_multorg_id := pk_csf.fkg_multorg_id_empresa(vn_empresa_id);
         --
   -- Busca o Parametro para checar se
   if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => vn_multorg_id,
                                                 en_empresa_id => vn_empresa_id,
                                                 en_modulo_id  => MODULO_SISTEMA,
                                                 en_grupo_id   => GRUPO_SISTEMA,
                                                 ev_param_name => 'UTILIZA_RABBIT_MQ',
                                                 sv_vlr_param  => vn_util_rabbitmq,
                                                 sv_erro       => vv_erro) then
      --
      vn_util_rabbitmq := 0;
      --
   end if;
    -- FIM 1979
   -- Lê as notas fiscais e faz o processo de validação encadeado
   for rec in c_Nota_Fiscal loop
      exit when c_Nota_Fiscal%notfound or (c_Nota_Fiscal%notfound) is null;
      --
	   vb_entrou := true; -- 1979
	   --
      if rec.dm_ind_emit = 0 then -- 1979
         --
         pkb_exec_rot_prog_pv_nf ( en_notafiscal_id  => rec.id
                                 , ed_dt_emiss       => rec.dt_emiss
                                 , en_usuario_id     => rec.usuario_id
                                 , en_empresa_id     => rec.empresa_id
                                 );
         --
      end if;
      --
      vn_fase := 2;
      -- limpa o array quando inicia uma nova Nota Fiscal
      vt_log_generico_nf.delete;
      --
      begin
         --
         select 1
           into vn_existe_canc
           from Nota_Fiscal_Canc nfc
          where nfc.notafiscal_id = rec.id;
         --
      exception
         when others then
            vn_existe_canc := 0;
      end;
      --
      if nvl(vn_existe_canc,0) > 0 then
         goto sair;
      end if;
      --
      vn_fase := 2.1;
      --
      gn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 2.2;
      --
      vv_sist_orig_sigla := pk_csf.fkg_sist_orig_sigla ( en_sistorig_id => rec.sistorig_id );
      --
      vn_fase := 2.3;
      --
      vv_unid_org_cd := pk_csf.fkg_unig_org_cd ( en_unidorg_id => rec.unidorg_id );
      --
      vn_fase := 2.4;
      --
      vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 2.5;
      --
      vv_cd_sitdocto := pk_csf.fkg_Sit_Docto_cd ( en_sitdoc_id => rec.sitdocto_id );
      --
      pk_csf_api.gt_row_Nota_Fiscal := null;
      --
      vn_fase := 3;
      --
      pk_csf_api.pkb_seta_referencia_id ( en_id => rec.id );
      --
      vn_fase := 3.1;
      --
      pk_csf_api.gt_row_Nota_Fiscal.id                := rec.id;
      --
      vn_notafiscal_id := rec.id;
      --
      pk_csf_api.gt_row_Nota_Fiscal.empresa_id        := rec.empresa_id;
      pk_csf_api.gt_row_Nota_Fiscal.pessoa_id         := rec.pessoa_id;
      pk_csf_api.gt_row_Nota_Fiscal.sitdocto_id       := rec.sitdocto_id;
      pk_csf_api.gt_row_Nota_Fiscal.natoper_id        := rec.natoper_id;
      pk_csf_api.gt_row_Nota_Fiscal.lote_id           := rec.lote_id;
      pk_csf_api.gt_row_Nota_Fiscal.inutilizanf_id    := rec.inutilizanf_id;
      pk_csf_api.gt_row_Nota_Fiscal.versao            := rec.versao;
      pk_csf_api.gt_row_Nota_Fiscal.id_tag_nfe        := rec.id_tag_nfe;
      pk_csf_api.gt_row_Nota_Fiscal.pk_nitem          := rec.pk_nitem;
      pk_csf_api.gt_row_Nota_Fiscal.nat_oper          := rec.nat_oper;
      pk_csf_api.gt_row_Nota_Fiscal.dm_ind_pag        := rec.dm_ind_pag;
      pk_csf_api.gt_row_Nota_Fiscal.modfiscal_id      := rec.modfiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal.dm_ind_emit       := rec.dm_ind_emit;
      pk_csf_api.gt_row_Nota_Fiscal.dm_ind_oper       := rec.dm_ind_oper;
      pk_csf_api.gt_row_Nota_Fiscal.dt_sai_ent        := rec.dt_sai_ent;
      pk_csf_api.gt_row_Nota_Fiscal.hora_sai_ent      := rec.hora_sai_ent;
      pk_csf_api.gt_row_Nota_Fiscal.dt_emiss          := rec.dt_emiss;
      pk_csf_api.gt_row_Nota_Fiscal.nro_nf            := rec.nro_nf;
      pk_csf_api.gt_row_Nota_Fiscal.serie             := rec.serie;
      pk_csf_api.gt_row_Nota_Fiscal.uf_embarq         := rec.uf_embarq;
      pk_csf_api.gt_row_Nota_Fiscal.local_embarq      := rec.local_embarq;
      pk_csf_api.gt_row_Nota_Fiscal.nf_empenho        := rec.nf_empenho;
      pk_csf_api.gt_row_Nota_Fiscal.pedido_compra     := rec.pedido_compra;
      pk_csf_api.gt_row_Nota_Fiscal.contrato_compra   := rec.contrato_compra;
      pk_csf_api.gt_row_Nota_Fiscal.dm_st_proc        := rec.dm_st_proc;
      pk_csf_api.gt_row_Nota_Fiscal.dt_st_proc        := rec.dt_st_proc;
      pk_csf_api.gt_row_Nota_Fiscal.dm_forma_emiss    := rec.dm_forma_emiss;
      pk_csf_api.gt_row_Nota_Fiscal.dm_impressa       := rec.dm_impressa;
      pk_csf_api.gt_row_Nota_Fiscal.dm_tp_impr        := rec.dm_tp_impr;
      pk_csf_api.gt_row_Nota_Fiscal.dm_tp_amb         := rec.dm_tp_amb;
      pk_csf_api.gt_row_Nota_Fiscal.dm_fin_nfe        := rec.dm_fin_nfe;
      pk_csf_api.gt_row_Nota_Fiscal.dm_proc_emiss     := rec.dm_proc_emiss;
      pk_csf_api.gt_row_Nota_Fiscal.vers_proc         := rec.vers_proc;
      pk_csf_api.gt_row_Nota_Fiscal.dt_aut_sefaz      := rec.dt_aut_sefaz;
      pk_csf_api.gt_row_Nota_Fiscal.dm_aut_sefaz      := rec.dm_aut_sefaz;
      pk_csf_api.gt_row_Nota_Fiscal.cidade_ibge_emit  := rec.cidade_ibge_emit;
      pk_csf_api.gt_row_Nota_Fiscal.uf_ibge_emit      := rec.uf_ibge_emit;
      pk_csf_api.gt_row_Nota_Fiscal.dt_hr_ent_sist    := rec.dt_hr_ent_sist;
      pk_csf_api.gt_row_Nota_Fiscal.nro_chave_nfe     := rec.nro_chave_nfe;
      pk_csf_api.gt_row_Nota_Fiscal.cnf_nfe           := rec.cnf_nfe;
      pk_csf_api.gt_row_Nota_Fiscal.dig_verif_chave   := rec.dig_verif_chave;
      pk_csf_api.gt_row_Nota_Fiscal.vers_apl          := rec.vers_apl;
      pk_csf_api.gt_row_Nota_Fiscal.dt_hr_recbto      := rec.dt_hr_recbto;
      pk_csf_api.gt_row_Nota_Fiscal.nro_protocolo     := rec.nro_protocolo;
      pk_csf_api.gt_row_Nota_Fiscal.digest_value      := rec.digest_value;
      pk_csf_api.gt_row_Nota_Fiscal.msgwebserv_id     := rec.msgwebserv_id;
      pk_csf_api.gt_row_Nota_Fiscal.cod_msg           := rec.cod_msg;
      pk_csf_api.gt_row_Nota_Fiscal.motivo_resp       := rec.motivo_resp;
      pk_csf_api.gt_row_Nota_Fiscal.nfe_proc_xml      := rec.nfe_proc_xml;
      pk_csf_api.gt_row_Nota_Fiscal.dm_st_email       := rec.dm_st_email;
      pk_csf_api.gt_row_Nota_Fiscal.id_usuario_erp    := rec.id_usuario_erp;
      pk_csf_api.gt_row_Nota_Fiscal.dm_st_integra     := rec.dm_st_integra;
      pk_csf_api.gt_row_Nota_Fiscal.vias_danfe_custom := rec.vias_danfe_custom;
      pk_csf_api.gt_row_Nota_Fiscal.nro_chave_cte_ref := rec.nro_chave_cte_ref;
      pk_csf_api.gt_row_nota_fiscal.dm_arm_nfe_terc   := rec.dm_arm_nfe_terc;
      pk_csf_api.gt_row_nota_fiscal.nro_ord_emb       := rec.nro_ord_emb;
      pk_csf_api.gt_row_nota_fiscal.seq_nro_ord_emb   := rec.seq_nro_ord_emb;
      pk_csf_api.gt_row_nota_fiscal.dm_id_dest        := rec.dm_id_dest;
      pk_csf_api.gt_row_nota_fiscal.dm_ind_final      := rec.dm_ind_final;
      pk_csf_api.gt_row_nota_fiscal.dm_ind_pres       := rec.dm_ind_pres;
      pk_csf_api.gt_row_nota_fiscal.local_despacho    := rec.local_despacho;
      pk_csf_api.gt_row_nota_fiscal.dt_cont           := rec.dt_cont;
      pk_csf_api.gt_row_nota_fiscal.dm_legado         := rec.dm_legado;
      pk_csf_api.gt_row_nota_fiscal.cod_cta           := rec.cod_cta;
      --
      pk_csf_api.gt_row_nota_fiscal.qr_code              := rec.qr_code;
      pk_csf_api.gt_row_nota_fiscal.dm_ind_ativ_part     := rec.dm_ind_ativ_part;
      pk_csf_api.gt_row_nota_fiscal.dm_mot_des_icms_part := rec.dm_mot_des_icms_part;
      pk_csf_api.gt_row_nota_fiscal.dm_calc_icmsst_part  := rec.dm_calc_icmsst_part;
      pk_csf_api.gt_row_nota_fiscal.url_chave            := rec.url_chave;
      pk_csf_api.gt_row_nota_fiscal.cod_mensagem         := rec.cod_mensagem;
      pk_csf_api.gt_row_nota_fiscal.msg_sefaz            := rec.msg_sefaz;
      --
      pk_csf_api.gt_row_nota_fiscal.dm_ind_intermed      := rec.dm_ind_intermed;
      pk_csf_api.gt_row_nota_fiscal.pessoa_id_intermed   := rec.pessoa_id_intermed;
      --
      vn_fase := 4;
      -- Chama o Processo de validação dos dados da Nota Fiscal
      pk_csf_api.pkb_integr_Nota_Fiscal ( est_log_generico_nf  => vt_log_generico_nf
                                        , est_row_Nota_Fiscal  => pk_csf_api.gt_row_Nota_Fiscal
                                        , ev_cod_mod           => rec.cod_mod
                                        , ev_cod_matriz        => null
                                        , ev_cod_filial        => null
                                        , ev_cod_part          => vv_cod_part
                                        , ev_cod_nat           => null
                                        , EV_CD_SITDOCTO       => vv_cd_sitdocto
                                        , ev_sist_orig         => vv_sist_orig_sigla
                                        , ev_cod_unid_org      => vv_unid_org_cd
                                        , en_multorg_id        => gn_multorg_id
                                        , en_loteintws_id      => en_loteintws_id
                                        );
      --
      if nvl(pk_csf_api.gt_row_Nota_Fiscal.id,0) = 0
         and nvl(en_loteintws_id,0) <= 0
         then
         --
         goto sair;
         --
      else
         --
         pk_csf_api.gt_row_Nota_Fiscal.id := rec.id;
         pk_csf_api.gt_row_Nota_Fiscal.empresa_id        := rec.empresa_id;
         pk_csf_api.gt_row_Nota_Fiscal.pessoa_id         := rec.pessoa_id;
         pk_csf_api.gt_row_Nota_Fiscal.sitdocto_id       := rec.sitdocto_id;
         pk_csf_api.gt_row_Nota_Fiscal.natoper_id        := rec.natoper_id;
         pk_csf_api.gt_row_Nota_Fiscal.lote_id           := rec.lote_id;
         pk_csf_api.gt_row_Nota_Fiscal.inutilizanf_id    := rec.inutilizanf_id;
         pk_csf_api.gt_row_Nota_Fiscal.versao            := rec.versao;
         pk_csf_api.gt_row_Nota_Fiscal.id_tag_nfe        := rec.id_tag_nfe;
         pk_csf_api.gt_row_Nota_Fiscal.pk_nitem          := rec.pk_nitem;
         pk_csf_api.gt_row_Nota_Fiscal.nat_oper          := rec.nat_oper;
         pk_csf_api.gt_row_Nota_Fiscal.dm_ind_pag        := rec.dm_ind_pag;
         pk_csf_api.gt_row_Nota_Fiscal.modfiscal_id      := rec.modfiscal_id;
         pk_csf_api.gt_row_Nota_Fiscal.dm_ind_emit       := rec.dm_ind_emit;
         pk_csf_api.gt_row_Nota_Fiscal.dm_ind_oper       := rec.dm_ind_oper;
         pk_csf_api.gt_row_Nota_Fiscal.dt_sai_ent        := rec.dt_sai_ent;
         pk_csf_api.gt_row_Nota_Fiscal.hora_sai_ent      := rec.hora_sai_ent;
         pk_csf_api.gt_row_Nota_Fiscal.dt_emiss          := rec.dt_emiss;
         pk_csf_api.gt_row_Nota_Fiscal.nro_nf            := rec.nro_nf;
         pk_csf_api.gt_row_Nota_Fiscal.serie             := rec.serie;
         pk_csf_api.gt_row_Nota_Fiscal.uf_embarq         := rec.uf_embarq;
         pk_csf_api.gt_row_Nota_Fiscal.local_embarq      := rec.local_embarq;
         pk_csf_api.gt_row_Nota_Fiscal.nf_empenho        := rec.nf_empenho;
         pk_csf_api.gt_row_Nota_Fiscal.pedido_compra     := rec.pedido_compra;
         pk_csf_api.gt_row_Nota_Fiscal.contrato_compra   := rec.contrato_compra;
         pk_csf_api.gt_row_Nota_Fiscal.dm_st_proc        := rec.dm_st_proc;
         pk_csf_api.gt_row_Nota_Fiscal.dt_st_proc        := rec.dt_st_proc;
         pk_csf_api.gt_row_Nota_Fiscal.dm_forma_emiss    := rec.dm_forma_emiss;
         pk_csf_api.gt_row_Nota_Fiscal.dm_impressa       := rec.dm_impressa;
         pk_csf_api.gt_row_Nota_Fiscal.dm_tp_impr        := rec.dm_tp_impr;
         pk_csf_api.gt_row_Nota_Fiscal.dm_tp_amb         := rec.dm_tp_amb;
         pk_csf_api.gt_row_Nota_Fiscal.dm_fin_nfe        := rec.dm_fin_nfe;
         pk_csf_api.gt_row_Nota_Fiscal.dm_proc_emiss     := rec.dm_proc_emiss;
         pk_csf_api.gt_row_Nota_Fiscal.vers_proc         := rec.vers_proc;
         pk_csf_api.gt_row_Nota_Fiscal.dt_aut_sefaz      := rec.dt_aut_sefaz;
         pk_csf_api.gt_row_Nota_Fiscal.dm_aut_sefaz      := rec.dm_aut_sefaz;
         pk_csf_api.gt_row_Nota_Fiscal.cidade_ibge_emit  := rec.cidade_ibge_emit;
         pk_csf_api.gt_row_Nota_Fiscal.uf_ibge_emit      := rec.uf_ibge_emit;
         pk_csf_api.gt_row_Nota_Fiscal.dt_hr_ent_sist    := rec.dt_hr_ent_sist;
         pk_csf_api.gt_row_Nota_Fiscal.nro_chave_nfe     := rec.nro_chave_nfe;
         pk_csf_api.gt_row_Nota_Fiscal.cnf_nfe           := rec.cnf_nfe;
         pk_csf_api.gt_row_Nota_Fiscal.dig_verif_chave   := rec.dig_verif_chave;
         pk_csf_api.gt_row_Nota_Fiscal.vers_apl          := rec.vers_apl;
         pk_csf_api.gt_row_Nota_Fiscal.dt_hr_recbto      := rec.dt_hr_recbto;
         pk_csf_api.gt_row_Nota_Fiscal.nro_protocolo     := rec.nro_protocolo;
         pk_csf_api.gt_row_Nota_Fiscal.digest_value      := rec.digest_value;
         pk_csf_api.gt_row_Nota_Fiscal.msgwebserv_id     := rec.msgwebserv_id;
         pk_csf_api.gt_row_Nota_Fiscal.cod_msg           := rec.cod_msg;
         pk_csf_api.gt_row_Nota_Fiscal.motivo_resp       := rec.motivo_resp;
         pk_csf_api.gt_row_Nota_Fiscal.nfe_proc_xml      := rec.nfe_proc_xml;
         pk_csf_api.gt_row_Nota_Fiscal.dm_st_email       := rec.dm_st_email;
         pk_csf_api.gt_row_Nota_Fiscal.id_usuario_erp    := rec.id_usuario_erp;
         pk_csf_api.gt_row_Nota_Fiscal.dm_st_integra     := rec.dm_st_integra;
         pk_csf_api.gt_row_Nota_Fiscal.vias_danfe_custom := rec.vias_danfe_custom;
         pk_csf_api.gt_row_Nota_Fiscal.nro_chave_cte_ref := rec.nro_chave_cte_ref;
         pk_csf_api.gt_row_nota_fiscal.dm_arm_nfe_terc   := rec.dm_arm_nfe_terc;
         pk_csf_api.gt_row_nota_fiscal.nro_ord_emb       := rec.nro_ord_emb;
         pk_csf_api.gt_row_nota_fiscal.seq_nro_ord_emb   := rec.seq_nro_ord_emb;
         pk_csf_api.gt_row_nota_fiscal.dm_id_dest        := rec.dm_id_dest;
         pk_csf_api.gt_row_nota_fiscal.dm_ind_final      := rec.dm_ind_final;
         pk_csf_api.gt_row_nota_fiscal.dm_ind_pres       := rec.dm_ind_pres;
         pk_csf_api.gt_row_nota_fiscal.local_despacho    := rec.local_despacho;
         pk_csf_api.gt_row_nota_fiscal.dt_cont           := rec.dt_cont;
         pk_csf_api.gt_row_nota_fiscal.dm_legado         := rec.dm_legado;
         pk_csf_api.gt_row_nota_fiscal.cod_cta           := rec.cod_cta;
         --
         pk_csf_api.gt_row_nota_fiscal.qr_code              := rec.qr_code;
         pk_csf_api.gt_row_nota_fiscal.dm_ind_ativ_part     := rec.dm_ind_ativ_part;
         pk_csf_api.gt_row_nota_fiscal.dm_mot_des_icms_part := rec.dm_mot_des_icms_part;
         pk_csf_api.gt_row_nota_fiscal.dm_calc_icmsst_part  := rec.dm_calc_icmsst_part;
         pk_csf_api.gt_row_nota_fiscal.url_chave            := rec.url_chave;
         pk_csf_api.gt_row_nota_fiscal.cod_mensagem         := rec.cod_mensagem;
         pk_csf_api.gt_row_nota_fiscal.msg_sefaz            := rec.msg_sefaz;
         --
         pk_csf_api.gt_row_nota_fiscal.dm_ind_intermed      := rec.dm_ind_intermed;
         pk_csf_api.gt_row_nota_fiscal.pessoa_id_intermed   := rec.pessoa_id_intermed;
         --         
      end if;
      --
      vn_fase := 5;
      --
      -- Procedimento de excluir os impostos se utilizar a calculadora fiscal
      pkb_excluir_imp_itemnf_cf ( en_notafiscal_id => rec.id
                                , en_dm_ind_emit   => rec.dm_ind_emit
                                , en_empresa_id    => rec.empresa_id
                                );
      --
      vn_fase := 5.01;
      -- Lê os dados do emitente da nota fiscal
      pkb_ler_Nota_Fiscal_Emit ( est_log_generico_nf          => vt_log_generico_nf
                               , en_notafiscal_id          => rec.id
                               , en_empresa_id             => rec.empresa_id
                               , en_dm_ind_emit            => rec.dm_ind_emit );
      --
      vn_fase := 6;
      -- Lê os dados do destinatário da nota fiscal
      pkb_ler_Nota_Fiscal_Dest ( est_log_generico_nf          => vt_log_generico_nf
                               , en_notafiscal_id          => rec.id );
      --
      vn_fase := 7;
      -- Lê os dados dos Totais da Nota Fiscal
      pkb_ler_Nota_Fiscal_Total ( est_log_generico_nf          => vt_log_generico_nf
                                , en_notafiscal_id          => rec.id );
      --
      vn_fase := 8;
      -- Lê os dados da Informação Adicional da Nota Fiscal
      pkb_ler_NFInfor_Adic ( est_log_generico_nf          => vt_log_generico_nf
                           , en_notafiscal_id          => rec.id );
      --
      vn_fase := 8.1;
      -- Lê os dados Informações Fiscais Compl. da Nota Fiscal
      pkb_ler_NFInfor_Fiscal ( est_log_generico_nf          => vt_log_generico_nf
                             , en_notafiscal_id          => rec.id );
      --
      vn_fase := 9;
      -- Lê os dados da Cobrança da Nota Fiscal
      pkb_ler_Nota_Fiscal_Cobr ( est_log_generico_nf          => vt_log_generico_nf
                               , en_notafiscal_id          => rec.id );
      --
      vn_fase := 10;
      -- Lê os dados do Local de Coleta/Entrega da Nota Fiscal
      pkb_ler_Nota_Fiscal_Local ( est_log_generico_nf          => vt_log_generico_nf
                                , en_notafiscal_id          => rec.id );

      --
      vn_fase := 11;
      -- Lê os dados do Transporte da Nota Fiscal
      pkb_ler_Nota_Fiscal_Transp ( est_log_generico_nf          => vt_log_generico_nf
                                 , en_notafiscal_id          => rec.id );

      --
      vn_fase := 12;
      -- Lê os dados da Nota Fiscal Referênciada
      pkb_ler_nf_referen ( est_log_generico_nf          => vt_log_generico_nf
                         , en_notafiscal_id          => rec.id );

      --
      vn_fase := 12.1;
      -- Lê os dados de Cupom Fiscal referenciado
      pkb_ler_cf_ref ( est_log_generico_nf          => vt_log_generico_nf
                     , en_notafiscal_id          => rec.id );
      --
      vn_fase := 12.2;
      -- Lê os dados de Cupom Fiscal Eletronico Referenciado
      pkb_ler_cfe_ref ( est_log_generico_nf          => vt_log_generico_nf
                      , en_notafiscal_id          => rec.id );
      --
      vn_fase := 13;
      -- Lê os dados do Item da Nota Fiscal
      pkb_ler_Item_Nota_Fiscal ( est_log_generico_nf          => vt_log_generico_nf
                               , en_notafiscal_id          => rec.id );
      --
      vn_fase := 14;
      -- Lê os dados de aquisição de cana
      pkb_ler_nf_aquis_cana ( est_log_generico_nf      => vt_log_generico_nf
                            , en_notafiscal_id      => rec.id );
      --
      vn_fase := 15;
      -- Lê os dados de Informações de NF de Fornecedores dos produtos da DANFE
      pkb_ler_inf_nf_romaneio ( est_log_generico_nf      => vt_log_generico_nf
                              , en_notafiscal_id      => rec.id );
      --
      vn_fase := 16;
      -- Lê os dados do Agendamento de Transporte
      pkb_ler_nf_agend_transp ( est_log_generico_nf      => vt_log_generico_nf
                              , en_notafiscal_id      => rec.id );
      --
      vn_fase := 17;
      -- Lê os dados do Complementos do PIS
      pkb_ler_nf_compl_oper_pis ( est_log_generico_nf      => vt_log_generico_nf
                                 , en_notafiscal_id      => rec.id );
      --
      vn_fase := 18;
      -- Lê os dados do Complemento do Cofins
      pkb_ler_nf_compl_oper_cofins ( est_log_generico_nf      => vt_log_generico_nf
                                   , en_notafiscal_id      => rec.id );
      --
      vn_fase := 19;
      -- Lê os dados da Autorização de acesso ao XML da Nota Fiscal
      pkb_ler_nf_aut_xml ( est_log_generico_nf       => vt_log_generico_nf
                         , en_notafiscal_id       => rec.id );
      --
      vn_fase := 20;
      -- Lê os dados da  Formas de Pagamento
      pkb_ler_nf_forma_pgto ( est_log_generico_nf    => vt_log_generico_nf
                            , en_notafiscal_id       => rec.id );
      --
      vn_fase := 21;
      -- Chama o processo que consiste a informação da Nota Fiscal
      pk_csf_api.pkb_consistem_nf ( est_log_generico_nf     => vt_log_generico_nf
                                  , en_notafiscal_id     => rec.id );
      --
      vn_fase := 98;
      --
      <<sair>>
      --
      vn_fase := 98.1;
      --
      if nvl(pk_csf_api.gt_row_Nota_Fiscal.id,0) = 0 and
         nvl(en_loteintws_id,0) <= 0 and
         nvl(vn_existe_canc,0) = 0 then
         -- Nota não existe no Compliance, não possui lote de integração web-service, e não possui cancelamento, portanto não passou pelo processo de validação
         null;
         --
      else
         -- A nota pode estar cancelada ou passou pelo processo de validação, portanto deve atualizar os valores de DM_ST_INTEGRA e DM_ST_PROC
         vn_fase := 99;
         --
         if rec.dm_st_integra in (7, 8, 9) then -- OPen Interface
            vn_dm_st_integra := 7;
         elsif rec.dm_st_integra in (13, 14) then -- SOFTWAY
               vn_dm_st_integra := 13;
         elsif rec.dm_st_integra in (10, 11) then -- SAP
               vn_dm_st_integra := 10;
         elsif rec.dm_st_integra in (2, 3, 4) then -- TXT/XML
               vn_dm_st_integra := 2;
         else
            vn_dm_st_integra := rec.dm_st_integra;
         end if;
         --
         vn_fase := 99.1;
         --
         if rec.dm_ind_emit = 0 then -- Emissão Própria, registra possíveis erros de validação
            --
            -- Se registrou algum log de erro, altera a Nota Fiscal para dm_st_proc = 10 - "Erro de Validação"
            if nvl(vt_log_generico_nf.count,0) > 0 and
               pk_csf_api.fkg_ver_erro_log_generico_nf(rec.id) = 1 then  -- Erro (Existe log de erro)
               --
               vn_fase := 99.2;
               --
               begin
                  --
                  vn_fase := 99.3;
                  --
                  update Nota_Fiscal set dm_st_proc     = 10
                                       , dt_st_proc     = sysdate
                                       , dm_st_integra  = vn_dm_st_integra
                                       , dm_envio_reinf = 0  --Não enviado
                   where id = rec.id;
                  --
                  commit;
                  --
               exception
                  when others then
                     --
                     pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal fase(' || vn_fase || '):' || sqlerrm;
                     --
                     declare
                        vn_loggenerico_id  log_generico_nf.id%TYPE;
                     begin
                        --
                        pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                                       , ev_mensagem         => pk_csf_api.gv_mensagem_log
                                                       , ev_resumo           => pk_csf_api.gv_mensagem_log
                                                       , en_tipo_log         => pk_csf_api.ERRO_DE_SISTEMA
                                                       , en_referencia_id    => rec.id
                                                       , ev_obj_referencia   => 'NOTA_FISCAL' );
                        --
                     exception
                        when others then
                           null;
                     end;
                     --
                     raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
                     --
               end;
               --
            else
               -- Se não houve nenhum nenhum registro de ocorrência
               -- então atualiza o dm_st_proc para 1-Aguardando Envio
               vn_fase := 99.4;
               -- Se a NFe de emissão propria não esta com situação de "4-Autorizado; 6-Denegado; 7-Cancelado; 8-Inutilizada"
               if rec.dm_st_proc not in (4, 6, 7, 8)
                  and rec.dm_legado = 0 -- 0-Não é Legado
                  then
                  --
                  vn_dm_aguard_liber_nfe := pk_csf.fkg_empr_aguard_liber_nfe ( en_empresa_id => rec.empresa_id );
                  --
                  if nvl(vn_dm_aguard_liber_nfe,0) = 1 then -- Sim, aguarda Liberação do usuário
                     --
                     vn_dm_st_proc := 21; -- Aguardando Liberacao
                     --
                  else
                     --
                     vn_dm_st_proc := 1; -- Aguardando Envio
                     --INICIO 1979
                     IF vn_util_rabbitmq = 1 THEN
                      pb_gera_lote(rec.empresa_id, rec.id); -- 1979
                     END IF;
                     -- FIM 1979
                     --
                  end if;
                  --
               else
                  -- Favor pensar muito antes de mexer aqui!
                  if rec.dm_legado = 1 then --Legado Autorizado
                     vn_dm_st_proc := 4;
                  elsif rec.dm_legado = 2 then --Legado Denegado
                        vn_dm_st_proc := 6;
                  elsif rec.dm_legado = 3 then --Legado Cancelado
                        vn_dm_st_proc := 7;
                  elsif rec.dm_legado = 4 then --Legado Inutilizado
                        vn_dm_st_proc := 8;
                  else
                     --
                     if rec.dm_st_proc in (4, 6, 7, 8) then
                        vn_dm_st_proc := rec.dm_st_proc;
                     else
                        vn_dm_st_proc := 1;
                     end if;
                     --
                  end if;
                  --
               end if;
               --
               vn_fase:= 99.5;
               --
               if vn_dm_st_proc = 8 then -- Inutilizada
                  --
                  vn_sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '05' ); -- NF-e ou CT-e : Numeracao inutilizada
                  --
               elsif vn_dm_st_proc = 7 then -- Cancelada
                  --
                  vn_sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '02' ); -- Documento cancelado
                  --
               elsif vn_dm_st_proc = 6 then -- Denegada
                  --
                  vn_sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '04' ); -- NF-e ou CT-e denegado
                  --
               else
                  --
                  vn_sitdocto_id := rec.sitdocto_id;
                  --
               end if;
               --
               vn_fase:= 99.6;
               --
               -- Variavel global usada em logs de triggers (carrega)
               gv_objeto := 'pk_valida_ambiente.pkb_ler_Nota_Fiscal';
               gn_fase   := vn_fase;
               --
               update Nota_Fiscal set dm_st_proc     = vn_dm_st_proc
                                    , dt_st_proc     = sysdate
                                    , dm_st_integra  = vn_dm_st_integra
                                    , dm_envio_reinf = 0  --Não enviado
                                    , sitdocto_id    = vn_sitdocto_id
                where id = rec.id;
               --
               -- Variavel global usada em logs de triggers (limpa)
               gv_objeto := 'pk_valida_ambiente';
               gn_fase   := null;
               --
               commit;
               --
            end if;
            --
         else
            --
            vn_fase := 99.6;
            --| Notas Fiscais Emitidas por terceiros
            if nvl(vt_log_generico_nf.count,0) > 0 and
               pk_csf_api.fkg_ver_erro_log_generico_nf(rec.id) = 1 then  -- Erro (Existe log de erro)
               --
               vn_fase := 99.7;
               -- Se registrou algum log, altera a Nota Fiscal para dm_st_proc = 10 - "Erro de Validação"
               update Nota_Fiscal set dm_st_proc     = 10
                                    , dt_st_proc     = sysdate
                                    , dm_envio_reinf = 0  --Não enviado
                where id = rec.id;
               --
            else
               --
               vn_fase := 99.8;
               --
               -- Variavel global usada em logs de triggers (carrega)
               gv_objeto := 'pk_valida_ambiente.pkb_ler_Nota_Fiscal';
               gn_fase   := vn_fase;
               --
               -- Se não houve nenhum registro de ocorrência atualiza o dm_st_proc para 4-Autorizada
               update Nota_Fiscal set dm_st_proc     = 4
                                    , dt_st_proc     = sysdate
                                    , dm_envio_reinf = 0  --Não enviado
                where id = rec.id;
               --
               -- Variavel global usada em logs de triggers (limpa)
               gv_objeto := 'pk_valida_ambiente';
               gn_fase   := null;
               --
            end if;
            --
            commit;
            --
         end if;
         --
      end if;
      --
      vn_fase := 100;
      --
      --inicio #70050
      -- este update substituirá a chamada da pk_csf_api.pkb_reg_danfe_rec_armaz_terc na pk_vld_amb_mde
      UPDATE NOTA_FISCAL SET DM_DANFE_REC = 1
       WHERE ID = (SELECT N.ID
                     FROM NOTA_FISCAL N
                    WHERE 1=1
                      AND N.DM_ARM_NFE_TERC = 0 --0-NÃO; 1-SIM
                      AND N.DM_IND_OPER     = 0 --0-ENTRADA 1-SAÍDA
                      AND N.DM_ST_PROC      = 4 -- DEPOIS DA VAILDAÇÃO E DA NF AUTORIZADA
                      AND N.ID              = vn_notafiscal_id--124961408
                      --A PRIMEIRA PARTE VALIDA A NOTA FISCAL DE ENTRADA
                      -- A SEGUNDA PARTE EXISTS VERIFICA SE A CHAVE ELETRONICA DA PRIMEIRA PARTE EXISTE NA SEGUNDA PARTE. SE EXISTIR EXECUTAR O UPDATE SENÃO, NÃO FAZER NADA.
                      AND EXISTS (SELECT NF.ID
                                      FROM EMPRESA     EM
                                         , NOTA_FISCAL NF
                                         , MOD_FISCAL  MF
                                     WHERE 1=1
                                       AND NF.NRO_CHAVE_NFE   = N.NRO_CHAVE_NFE--'35160654173042000153550010000040061215492350'
                                       AND NF.EMPRESA_ID      = N.EMPRESA_ID
                                       --AND EM.MULTORG_ID      = 26--EN_MULTORG_ID
                                       AND NF.EMPRESA_ID      = EM.ID
                                       AND NF.DM_ARM_NFE_TERC = 1-- 0-NÃO; 1-SIM
                                       AND NF.DM_REC_XML      = 1-- 0-NÃO RECEBIDO; 1-RECEBIDO
                                       AND NF.DM_DANFE_REC    = 0-- 0-NÃO RECEBIDO; 1-RECEBIDO
                                       AND MF.ID              = NF.MODFISCAL_ID
                                       AND MF.COD_MOD         = '55'));
      --fim #70050
      --
      commit;
      --
      vn_fase := 100.1;
      --
   end loop;
   --
   vn_fase := 100.2;
      --
   vn_dm_st_proc := pk_csf.fkg_st_proc_nf ( en_notafiscal_id => en_notafiscal_id ); -- 1979
      --
   vn_fase := 100.3;
         --
   vn_fase := 100.4;
   --
   if vb_entrou = false and vn_dm_st_proc <= 0  /*and vn_util_rabbitmq = 1*/ then
   --
      pk_csf_rabbitmq.pb_valida_nfe(en_notafiscal_id);
   --
      end if;
      --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a leitura das Notas Fiscais com DM_ST_PROC = 0 (Não validada)
-- e o encadiamento da validação - Todas menos NFCE - modelo 65

procedure pkb_ler_NF_Integradas ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase               number := 0;
   vn_notafiscal_id      Nota_Fiscal.id%TYPE;
   vn_dm_st_proc         nota_fiscal.dm_st_proc%type;
   vn_existe_canc        number;
   vn_existe_ws          number;
   --
   cursor c_Nota_Fiscal is
   select nf.id, nf.empresa_id, nf.dt_emiss, nf.usuario_id
     from empresa       e
        , Nota_Fiscal   nf
        , Mod_Fiscal    mf
    where 1 = 1
      and e.multorg_id       = en_multorg_id
      and nf.empresa_id      = e.id
      and nf.dm_ind_emit     = 0
      and nf.dm_st_proc      = 0 -- Não validada
      and nf.dm_arm_nfe_terc = 0
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('01', '1B', '04', '55')
      and rownum            <= 50 -- limite de NFe que podem ser enviadas e um lote!
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   -- Lê as notas fiscais e faz o processo de validação encadeado
   for rec in c_Nota_Fiscal loop
      exit when c_Nota_Fiscal%notfound or (c_Nota_Fiscal%notfound) is null;
      --
      vn_fase := 2;
      --
      begin
         --
         select 1
           into vn_existe_canc
           from Nota_Fiscal_Canc nfc
          where nfc.notafiscal_id = rec.id;
         --
      exception
         when others then
            vn_existe_canc := 0;
      end;
      --
      if nvl(vn_existe_canc,0) > 0 then
         goto sair;
      end if;
      --
      vn_fase := 2.2;
      -- verifica se existe Lote de Envio WebService com Situação 1-Recebido ou 2-Em Processamento
      begin
         --
         select count(1) 
           into vn_existe_ws
           from r_loteintws_nf   r
              , lote_int_ws      l
          where r.notafiscal_id  = rec.id
            and l.id             = r.loteintws_id
            and l.dm_st_proc     in (1, 2);
         --
      exception
         when others then
            vn_existe_ws := 0;
      end;
      --
      if nvl(vn_existe_ws,0) > 0 then
         goto sair;
      end if;
      --
      vn_fase := 3;
      --
      -- Procedimento de executar rotinas programadas de pré-validação para NFS
      pkb_exec_rot_prog_pv_nf ( en_notafiscal_id  => rec.id
                              , ed_dt_emiss       => rec.dt_emiss
                              , en_usuario_id     => rec.usuario_id
                              , en_empresa_id     => rec.empresa_id
                              );
      --
      vn_fase := 8;
      --
      vn_dm_st_proc := pk_csf.fkg_st_proc_nf ( en_notafiscal_id => rec.id );
      --
      vn_fase := 9;
      --
      if vn_dm_st_proc = 0 then
         pkb_ler_Nota_Fiscal ( en_notafiscal_id => rec.id );
      end if;
      --
      <<sair>>
      --
      vn_fase := 100;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_NF_Integradas fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_NF_Integradas;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a leitura das Notas Fiscais com DM_ST_PROC = 0 (Não validada)
-- e o encadiamento da validação - Só para notas NFCE - modelo 65

procedure pkb_ler_NFCE_Integradas ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase               number := 0;
   vn_notafiscal_id      Nota_Fiscal.id%TYPE;
   vn_dm_st_proc         nota_fiscal.dm_st_proc%type;
   vn_existe_canc        number;
   vn_existe_ws          number;
   --
   cursor c_Nota_Fiscal is
   select nf.id, nf.empresa_id, nf.dt_emiss, nf.usuario_id
     from empresa       e
        , Nota_Fiscal   nf
        , Mod_Fiscal    mf
    where 1 = 1
      and e.multorg_id       = en_multorg_id
      and nf.empresa_id      = e.id
      and nf.dm_ind_emit     = 0
      and nf.dm_st_proc      = 0 -- Não validada
      and nf.dm_arm_nfe_terc = 0
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        =  '65'
      and rownum            <= 50 -- limite de NFe que podem ser enviadas e um lote!
    order by nf.id;
   --
begin
   --
   vn_fase := 1;
   -- Lê as notas fiscais e faz o processo de validação encadeado
   for rec in c_Nota_Fiscal loop
      exit when c_Nota_Fiscal%notfound or (c_Nota_Fiscal%notfound) is null;
      --
      vn_fase := 2;
      --
      begin
         --
         select 1
           into vn_existe_canc
           from Nota_Fiscal_Canc nfc
          where nfc.notafiscal_id = rec.id;
         --
      exception
         when others then
            vn_existe_canc := 0;
      end;
      --
      if nvl(vn_existe_canc,0) > 0 then
         goto sair;
      end if;
      --
      vn_fase := 2.2;
      -- verifica se existe Lote de Envio WebService com Situação 1-Recebido ou 2-Em Processamento
      begin
         --
         select count(1) 
           into vn_existe_ws
           from r_loteintws_nf   r
              , lote_int_ws      l
          where r.notafiscal_id  = rec.id
            and l.id             = r.loteintws_id
            and l.dm_st_proc     in (1, 2);
         --
      exception
         when others then
            vn_existe_ws := 0;
      end;
      --
      if nvl(vn_existe_ws,0) > 0 then
         goto sair;
      end if;
      --
      vn_fase := 3;
      --
      -- Procedimento de executar rotinas programadas de pré-validação para NFS
      pkb_exec_rot_prog_pv_nf ( en_notafiscal_id  => rec.id
                              , ed_dt_emiss       => rec.dt_emiss
                              , en_usuario_id     => rec.usuario_id
                              , en_empresa_id     => rec.empresa_id
                              );
      --
      vn_fase := 8;
      --
      vn_dm_st_proc := pk_csf.fkg_st_proc_nf ( en_notafiscal_id => rec.id );
      --
      vn_fase := 9;
      --
      if vn_dm_st_proc = 0 then
         pkb_ler_Nota_Fiscal ( en_notafiscal_id => rec.id );
      end if;
      --
      <<sair>>
      --
      vn_fase := 100;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_NFCE_Integradas fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_NFCE_Integradas;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura das Notas Fiscais Canceladas que estão com o dm_st_proc = 0
-- e válida a informação do cancelamento notas modelo 55

procedure pkb_ler_Nota_Fiscal_Canc ( en_multorg_id in mult_org.id%type
                                   , en_notafiscal_id in nota_fiscal.id%type default null )
is

   cursor c_Nota_Fiscal_Canc is
   select nfc.*
        , nf.empresa_id
        , nf.nro_nf
        , nf.serie
        , mf.cod_mod
        , nf.dt_emiss
     from empresa           e
        , Nota_Fiscal       nf
        , Nota_Fiscal_Canc  nfc
        , Mod_Fiscal        mf
    where 1 = 1
      and e.multorg_id      = en_multorg_id
      and nf.id             = nvl(en_notafiscal_id, nf.id)
      and nf.empresa_id     = e.id
      and nf.dm_st_proc     in (0,5,10,11,12,13,15,16,99)
      and nf.dm_ind_emit    = 0 -- Emissão Própria
      and nfc.notafiscal_id = nf.id
      and (nfc.cod_msg is null or nfc.cod_msg <> '219')  -- Rejeição: Circulação da NF-e verificada
      and mf.id             = nf.modfiscal_id
      and mf.cod_mod        = '55';

   vn_fase               number := 0;
   vt_log_generico_nf       dbms_sql.number_table;
   vn_notafiscal_id      Nota_Fiscal.id%TYPE;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Nota_Fiscal_Canc loop
      exit when c_Nota_Fiscal_Canc%notfound or (c_Nota_Fiscal_Canc%notfound) is null;
      --
      vn_fase := 2;
      --
      vt_log_generico_nf.delete;
      --
      vn_fase := 3;
      --
      -- Cancelamento da Nota Fiscal
      pk_csf_api.gt_row_Nota_Fiscal_Canc := null;
      --
      vn_fase := 4;
      --
      pk_csf_api.pkb_seta_referencia_id ( en_id => rec.notafiscal_id );
      --
      vn_fase := 4.1;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Canc.id             := rec.id;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.notafiscal_id  := rec.notafiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.dt_canc        := rec.dt_canc;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.justif         := rec.justif;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.dm_st_integra  := rec.dm_st_integra;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.usuario_id     := rec.usuario_id;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.dm_canc_extemp := rec.dm_canc_extemp;
      --
      vn_fase := 5;
      -- Chama o procedimento de integração da Nota Fiscal Cancelada
      pk_csf_api.pkb_integr_Nota_Fiscal_Canc ( est_log_generico_nf          => vt_log_generico_nf
                                             , est_row_Nota_Fiscal_Canc  => pk_csf_api.gt_row_Nota_Fiscal_Canc
                                             );
      --
      vn_fase := 99;
      -- Se registrou algum log, altera a Nota Fiscal para dm_st_proc = 10 - "Erro de Validação"
      if nvl(vt_log_generico_nf.count,0) > 0 then
         --
         vn_fase := 99.1;
         --
         begin
            --
            vn_fase := 99.2;
            --
            -- Variavel global usada em logs de triggers (carrega)
            gv_objeto := 'pk_valida_ambiente.pkb_ler_Nota_Fiscal_Canc'; 
            gn_fase   := vn_fase;
            --
            update Nota_Fiscal set dm_st_proc = 4
                                 , dt_st_proc = sysdate
             where id = rec.notafiscal_id;
            --
            -- Variavel global usada em logs de triggers (limpa)
            gv_objeto := 'pk_valida_ambiente';
            gn_fase   := null;
            --
         exception
            when others then
               --
               pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_Canc fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                              , ev_mensagem        => pk_csf_api.gv_mensagem_log
                                              , ev_resumo          => pk_csf_api.gv_mensagem_log
                                              , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                              , en_referencia_id   => rec.id
                                              , ev_obj_referencia  => 'NOTA_FISCAL' );
                  --
               exception
                  when others then
                     null;
               end;
               --
               raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
               --
         end;
         --
      end if;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_Canc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal_Canc;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura das Notas Fiscais Canceladas que estão com o dm_st_proc = 0
-- e válida a informação do cancelamento para notas NFCE modelo 65

procedure pkb_ler_Nota_Fiscal_NFCE_Canc ( en_multorg_id in mult_org.id%type )
is

   cursor c_Nota_Fiscal_Canc is
   select nfc.*
        , nf.empresa_id
        , nf.nro_nf
        , nf.serie
        , mf.cod_mod
        , nf.dt_emiss
     from empresa           e
        , Nota_Fiscal       nf
        , Nota_Fiscal_Canc  nfc
        , Mod_Fiscal        mf
    where 1 = 1
      and e.multorg_id      = en_multorg_id
      and nf.empresa_id     = e.id
      and nf.dm_st_proc     in (10,11,12,13,15,16,5,99)
      and nf.dm_ind_emit    = 0 -- Emissão Própria
      and nfc.notafiscal_id = nf.id
      and (nfc.cod_msg is null or nfc.cod_msg <> '219')  -- Rejeição: Circulação da NF-e verificada
      and mf.id             = nf.modfiscal_id
      and mf.cod_mod        = '65';

   vn_fase               number := 0;
   vt_log_generico_nf       dbms_sql.number_table;
   vn_notafiscal_id      Nota_Fiscal.id%TYPE;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Nota_Fiscal_Canc loop
      exit when c_Nota_Fiscal_Canc%notfound or (c_Nota_Fiscal_Canc%notfound) is null;
      --
      vn_fase := 2;
      --
      vt_log_generico_nf.delete;
      --
      vn_fase := 3;
      --
      -- Cancelamento da Nota Fiscal
      pk_csf_api.gt_row_Nota_Fiscal_Canc := null;
      --
      vn_fase := 4;
      --
      pk_csf_api.pkb_seta_referencia_id ( en_id => rec.notafiscal_id );
      --
      vn_fase := 4.1;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Canc.id             := rec.id;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.notafiscal_id  := rec.notafiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.dt_canc        := rec.dt_canc;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.justif         := rec.justif;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.dm_st_integra  := rec.dm_st_integra;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.usuario_id     := rec.usuario_id;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.dm_canc_extemp := rec.dm_canc_extemp;
      --
      vn_fase := 5;
      -- Chama o procedimento de integração da Nota Fiscal Cancelada
      pk_csf_api.pkb_integr_Nota_Fiscal_Canc ( est_log_generico_nf          => vt_log_generico_nf
                                             , est_row_Nota_Fiscal_Canc  => pk_csf_api.gt_row_Nota_Fiscal_Canc
                                             );
      --
      vn_fase := 99;
      -- Se registrou algum log, altera a Nota Fiscal para dm_st_proc = 10 - "Erro de Validação"
      if nvl(vt_log_generico_nf.count,0) > 0 then
         --
         vn_fase := 99.1;
         --
         begin
            --
            vn_fase := 99.2;
            --
            -- Variavel global usada em logs de triggers (carrega)
            gv_objeto := 'pk_valida_ambiente.pkb_ler_Nota_Fiscal_NFCE_Canc'; 
            gn_fase   := vn_fase;
            --
            update Nota_Fiscal set dm_st_proc = 4
                                 , dt_st_proc = sysdate
             where id = rec.notafiscal_id;
            --
            -- Variavel global usada em logs de triggers (limpa)
            gv_objeto := 'pk_valida_ambiente';
            gn_fase   := null;
            --
         exception
            when others then
               --
               pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_NFCE_Canc fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                              , ev_mensagem        => pk_csf_api.gv_mensagem_log
                                              , ev_resumo          => pk_csf_api.gv_mensagem_log
                                              , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                              , en_referencia_id   => rec.id
                                              , ev_obj_referencia  => 'NOTA_FISCAL' );
                  --
               exception
                  when others then
                     null;
               end;
               --
               raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
               --
         end;
         --
      end if;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_Nota_Fiscal_NFCE_Canc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_Nota_Fiscal_NFCE_Canc;

-------------------------------------------------------------------------------------------------------

--| Procedimento de reenvio de emails com erro por dois dias

procedure pkb_reenvia_email
is
   --
   vn_fase number := 0;
   --
   cursor c_email is
   select nfd.*, nf.nro_nf, nf.dm_st_email, nf.dt_emiss
     from nota_fiscal_dest nfd, nota_fiscal nf
    where nfd.email is not null
      and nf.id = nfd.notafiscal_id
      and trunc(nf.dt_hr_ent_sist) >= trunc(sysdate - 2)
      and nf.dm_st_email = 3
    order by nfd.id desc;
   --
   pragma  autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_email loop
      exit when c_email%notfound or (c_email%notfound) is null;
      --
      vn_fase := 2;
      --
      update nota_fiscal set dm_st_email = 0
       where id = rec.notafiscal_id;
      --
   end loop;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_reenvia_email fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_mensagem_log
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_reenvia_email;

------------------------------------------------------------------------------------------------------- 

--| Procedimento de re-impressão de DANFE com erro

procedure pkb_reenvia_impressao_nfe ( en_multorg_id  in mult_org.id%type )
is
   --
   vn_fase number := 0;
   --
   cursor c_nfe1 is
   select nf.id
     from empresa e
        , nota_fiscal nf
        , mod_fiscal mf
    where 1 = 1
      and e.multorg_id   = en_multorg_id
      and nf.empresa_id  = e.id
      and nf.dm_ind_emit = 0
      and nf.dm_st_proc  in (4, 14)
      and nf.dm_impressa in (2,1)
      and (sysdate - trunc(nf.dt_emiss) ) <= 30
      and mf.id          = nf.modfiscal_id
      and mf.cod_mod     in ('55', '65')
      and nf.dt_aut_sefaz is not null
      and not exists (select 1 from nota_fiscal_pdf pdf where pdf.notafiscal_id = nf.id);

   cursor c_nfe2 is
   select nf.id
     from empresa e
        , nota_fiscal nf
        , mod_fiscal mf
    where 1 = 1
      and e.multorg_id       = en_multorg_id
      and nf.empresa_id      = e.id
      and nf.dm_arm_nfe_terc = 1
      and nf.dm_st_proc      = 4
      and nf.dm_impressa     in (2,1)
      and (sysdate - trunc(nf.dt_emiss) ) <= 30
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod         in ('55', '65')
      and nf.dt_aut_sefaz    is not null
      and not exists (select 1 from nota_fiscal_pdf pdf where pdf.notafiscal_id = nf.id);
   --
   pragma  autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nfe1 loop
      exit when c_nfe1%notfound or (c_nfe1%notfound) is null;
      --
      vn_fase := 2;
      --
      delete from nota_fiscal_pdf where notafiscal_id = rec.id;
      --
      vn_fase := 3;
      --
      -- Variavel global usada em logs de triggers (carrega)
      pk_valida_ambiente.gv_objeto := 'pk_valida_ambiente.pkb_reenvia_impressao_nfe';
      pk_valida_ambiente.gn_fase   := vn_fase;
      --
      pb_gera_danfe_nfe(rec.id);
      --
      -- Variavel global usada em logs de triggers (mantém o nome da package)
      pk_valida_ambiente.gv_objeto := 'pk_valida_ambiente';
      pk_valida_ambiente.gn_fase   := null;
      --
      vn_fase := 4;
      --
      update nota_fiscal set dm_impressa = 0
                           , nro_tentativas_impr = 0
                           , dt_ult_tenta_impr = null
                           , impressora_id = null
       where id = rec.id;
      --
   end loop;
   --
   vn_fase := 5;
   --
   for rec in c_nfe2 loop
      exit when c_nfe2%notfound or (c_nfe2%notfound) is null;
      --
      vn_fase := 7;
      --
      delete from nota_fiscal_pdf where notafiscal_id = rec.id;
      --
      vn_fase := 8;
      --
      -- Variavel global usada em logs de triggers (carrega)
      pk_valida_ambiente.gv_objeto := 'pk_valida_ambiente.pkb_reenvia_impressao_nfe';
      pk_valida_ambiente.gn_fase   := vn_fase;
      --
      pb_gera_danfe_nfe(rec.id);
      --
      -- Variavel global usada em logs de triggers (mantém o nome da package)
      pk_valida_ambiente.gv_objeto := 'pk_valida_ambiente';
      pk_valida_ambiente.gn_fase   := null;
      --
      vn_fase := 9;
      --
      update nota_fiscal set dm_impressa = 0
                           , nro_tentativas_impr = 0
                           , dt_ult_tenta_impr = null
                           , impressora_id = null
       where id = rec.id;
      --
   end loop;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_reenvia_impressao_nfe fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_mensagem_log
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_reenvia_impressao_nfe;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura/validação da carta de correção

procedure pkb_ler_nota_fiscal_cce ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase               number := 0;
   vt_log_generico_nf       dbms_sql.number_table;
   --
   cursor c_nfe is
   select cce.*
     from empresa e
        , nota_fiscal nf
        , nota_fiscal_cce cce
    where 1 = 1
      and e.multorg_id       = en_multorg_id
      and nf.empresa_id      = e.id
      and cce.notafiscal_id  = nf.id
      and cce.dm_st_proc     = 0 -- Não validada
    order by cce.id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nfe loop
      exit when c_nfe%notfound or (c_nfe%notfound) is null;
      --
      vn_fase := 2;
      --
      --
      -- seta o tipo de integração que será feito
      -- 0 - Válida e Atualiza os dados
      -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
      -- Todos os procedimentos de integração fazem referência a ele
      pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
      --
      vn_fase := 2.1;
      --
      pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL_CCE' );
      --
      vn_fase := 2.2;
      --
      pk_csf_api.pkb_seta_referencia_id ( en_id => rec.id );
      --
      vn_fase := 2.3;
      --
      vt_log_generico_nf.delete;
      --
      vn_fase := 3;
      --
      pk_csf_api.gt_row_nota_fiscal_cce := rec;
      --
      vn_fase := 3.1;
      --
      pk_csf_api.pkb_integr_nota_fiscal_cce ( est_log_generico_nf              => vt_log_generico_nf
                                            , est_row_nota_fiscal_cce       => pk_csf_api.gt_row_nota_fiscal_cce
                                            );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nota_fiscal_cce fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => pk_csf_api.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api.gv_obj_referencia
									 );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nota_fiscal_cce;

-------------------------------------------------------------------------------------------------------

--| Procedimento de leitura/validação do manifesto do destinatário

procedure pkb_ler_nota_fiscal_mde ( en_multorg_id  in mult_org.id%type )
is
   --
   vn_fase               number := 0;
   vt_log_generico_nf       dbms_sql.number_table;
   --
   cursor c_nfe is
   select mde.*
     from empresa e
        , nota_fiscal nf
        , nota_fiscal_mde mde
    where 1 = 1
      and e.multorg_id = en_multorg_id
      and nf.empresa_id = e.id
      and mde.notafiscal_id = nf.id
      and mde.dm_situacao = 0 -- Não validado
    order by mde.id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_nfe loop
      exit when c_nfe%notfound or (c_nfe%notfound) is null;
	  --
	  vn_fase := 2;	  
	  --
          --
          -- seta o tipo de integração que será feito
          -- 0 - Válida e Atualiza os dados
          -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
          -- Todos os procedimentos de integração fazem referência a ele
          pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
          --
          vn_fase := 2.1;
          --
          pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL_MDE' );
	  --
	  vn_fase := 2.2;
	  --
	  pk_csf_api.pkb_seta_referencia_id ( en_id => rec.id );
	  --
	  vn_fase := 2.3;
          --
	  vt_log_generico_nf.delete;
	  --
	  vn_fase := 3;
	  --	  
	  pk_csf_api.gt_row_nota_fiscal_mde := rec;
	  --
	  vn_fase := 3.1;
	  --
	  pk_csf_api.pkb_integr_nota_fiscal_mde ( est_log_generico_nf        => vt_log_generico_nf
                                                , est_row_nota_fiscal_mde => pk_csf_api.gt_row_nota_fiscal_mde
                                                );
	  --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_nota_fiscal_mde fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => pk_csf_api.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api.gv_obj_referencia
									 );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_nota_fiscal_mde;

-------------------------------------------------------------------------------------------------------
--| Procedimento de Consulta de Chaves de Nfe Cancelada de Terceiros

procedure pkb_cons_nfe_terc_canc ( en_multorg_id  in mult_org.id%type ) 
is
   --
   cursor c_dados is
	   select nf.*
		 from empresa e
			, nota_fiscal nf
			, mod_fiscal  mf
		where 1 = 1
		  and mf.id              = nf.modfiscal_id
		  and e.multorg_id = en_multorg_id
		  and nf.nro_chave_nfe is not null 
		  and nf.empresa_id = e.id
		  and mf.cod_mod         in ('55')
		  and nf.dm_arm_nfe_terc = 1
		  and nf.dm_st_proc = 7
		  and nf.dt_emiss >= add_months(sysdate, -1)
		  and not exists (select 1 from csf_cons_sit cs where cs.chnfe = nf.nro_chave_nfe and  cs.dm_situacao in (3))
		  and not exists (select 1 from nota_fiscal_mde b where b.notafiscal_id = nf.id and b.cod_msg = 650)
		  and not exists (select 1 from nota_fiscal_canc c where c.notafiscal_Id = nf.id)
		  and not exists (select 1 from cons_nfe_dest n
							   , cons_nfe_dest_cce r
							   , tipo_evento_sefaz tes
							where n.notafiscal_id = nf.id
							  and r.consnfedest_id = n.id
							  and tes.id           = r.TIPOEVENTOSEFAZ_ID
							  and tes.cd = '110111')
		order by 1 desc;
   --
begin
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
         -- Chama rotina que atualiza ou insere a tabela csf_cons_sit
         pk_csf_api_cons_sit.gt_row_csf_cons_sit                  := null;
         --
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.id               :=  null; -- id - id sera criado na pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id       :=  rec.empresa_id; -- empresa_id
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.chnfe            :=  rec.nro_chave_nfe; --chnfe
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.codufibge        :=  substr(rec.nro_chave_nfe,1,2); --codufibge
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_tp_cons       :=  4; -- DM_TP_CONS
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_situacao      :=  1; -- DM_SITUACAO
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dt_hr_cons_sit   :=  sysdate; -- dt_hr_cons_sit
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_rec_fisico    :=  0; -- DM_REC_FISICO
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_integr_erp    :=  0;
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_criar_mde     :=  0;
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.tpamb            :=  rec.dm_tp_amb; -- tpamb
         --
         pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                      , ev_campo_atu         => null
                                                      , en_tp_rotina         => 1 -- inserção
                                                      , ev_rotina_orig       => 'pk_valida_ambiente.pkb_cons_nfe_terc_canc'
                                                      );
      --
   end loop;
   --
   commit;
   --
end pkb_cons_nfe_terc_canc;

-------------------------------------------------------------------------------------------------------

--| procedimento de ajustar cupom fiscal cancelado
procedure pkb_ajusta_cf_canc ( en_multorg_id  in mult_org.id%type )
is
   --
   vn_fase number;
   vn_sitdocto_id  sit_docto.id%type;
   --
   cursor c_dados is
   select cf.*
     from empresa e
        , cupom_fiscal cf
        , cupom_fiscal_canc cfc
    where 1 = 1
      and e.multorg_id = en_multorg_id
      and cf.empresa_id = e.id
      and cf.dm_st_proc       <> 7
      and cfc.cupomfiscal_id  = cf.id
    order by cf.id;
   --
   cursor c_canc is
   select cf.*
     from empresa e
        , cupom_fiscal cf
        , cupom_fiscal_canc cfc
    where 1 = 1
      and e.multorg_id = en_multorg_id
      and cf.empresa_id = e.id
      and cf.dm_st_proc       <> 7
      and cfc.CHV_CANC        = cf.ID_TAG
    order by cf.id;
   --
begin
   --
   vn_fase := 1;
   --
   vn_sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '02' ); -- Cancelado
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      -- Variavel global usada em logs de triggers (carrega)
      gv_objeto := 'pk_valida_ambiente.pkb_ajusta_cf_canc'; 
      gn_fase   := vn_fase;
      --
      update cupom_fiscal set dm_st_proc  = 7 -- Cancelado
                            , sitdocto_id = vn_sitdocto_id
       where id = rec.id;
      --
      -- Variavel global usada em logs de triggers (limpa)
      gv_objeto := 'pk_valida_ambiente';
      gn_fase   := null;
      --
      commit;
      --
   end loop;
   --
   vn_fase := 2;
   --
   for rec in c_canc loop
      exit when c_canc%notfound or (c_canc%notfound) is null;
      --
      -- Variavel global usada em logs de triggers (carrega)
      gv_objeto := 'pk_valida_ambiente.pkb_ajusta_cf_canc'; 
      gn_fase   := vn_fase;
      --
      update cupom_fiscal set dm_st_proc  = 7 -- Cancelado
                            , sitdocto_id = vn_sitdocto_id
       where id = rec.id;
      --
      -- Variavel global usada em logs de triggers (limpa)
      gv_objeto := 'pk_valida_ambiente';
      gn_fase   := null;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      raise_application_error (-20101, 'Erro na pkb_ajusta_cf_canc fase(' || vn_fase || '): ' || sqlerrm);
      --
end pkb_ajusta_cf_canc;

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a leitura das Notas Fiscais com DM_ST_PROC = 4 (validada) Legado sem dados da nota fiscal
-- referenciada - Todas menos NFCE - modelo 65
-- Esse procedimento chama trigger "T_A_I_U_Nota_Fiscal_NF_REFEREN_01" para decomposição da chave

procedure pkb_ler_NF_Int_Legado_Ref ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase               number := 0;
   vn_notafiscal_id      Nota_Fiscal.id%TYPE;
   vn_dm_st_proc         nota_fiscal.dm_st_proc%type;
   --
   cursor c_Nota_Fiscal is
  select nf.id, nf.empresa_id, nf.dt_emiss, nf.usuario_id
     from empresa       e
        , Nota_Fiscal   nf                
        , Mod_Fiscal    mf
    where 1 = 1
      and e.multorg_id        = en_multorg_id
      and nf.empresa_id       = e.id
      and nf.dm_ind_emit      = 0
      and nf.dm_st_proc       = 4 -- Validada
      and nvl(nf.dm_legado,0) > 0
      and nf.dm_arm_nfe_terc  = 0
      and mf.id               = nf.modfiscal_id
      and mf.cod_mod         in ('01', '1B', '04', '55')
      and exists (select 1
                    from nota_fiscal_referen nr
                   where nr.notafiscal_id = nf.id
                     and nr.nro_chave_nfe    is not null
                     and nr.ibge_estado_emit is null
                     and nr.cnpj_emit        is null
                     and nr.dt_emiss         is null
                     and nr.modfiscal_id     is null
                     and nr.nro_nf           is null
                     and nr.serie            is null
                     and nr.subserie         is null
                     and nr.pessoa_id        is null
                     and nr.dm_ind_oper      is null
                     and nr.dm_ind_emit      is null)   
      and rownum            <= 50 -- limite de NFe que podem ser enviadas e um lote!
    order by nf.id;   
   --
begin
   --
   vn_fase := 1;
   -- Lê as notas fiscais e faz o processo de validação encadeado
   for rec in c_Nota_Fiscal loop
      exit when c_Nota_Fiscal%notfound or (c_Nota_Fiscal%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_dm_st_proc := pk_csf.fkg_st_proc_nf ( en_notafiscal_id => rec.id );
      vn_notafiscal_id := rec.id;	  
      --
      update nota_fiscal
         set dm_st_proc = vn_dm_st_proc
       where id = rec.id;		 
      --
      vn_fase := 3;
      --
      commit;
      --	  
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_ler_NF_Int_Legado_Ref fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_ler_NF_Int_Legado_Ref;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a validação de Notas Fiscais 
procedure pkb_integracao
is
   --
   vn_fase number := 0;
   --
   cursor c_mo is
   select mo.*
     from mult_org     mo
    where 1 = 1
      and mo.dm_situacao     = 1 -- Ativo
    order by 1;
   --
begin
   --
   for rec_mo in c_mo loop
      exit when c_mo%notfound or (c_mo%notfound) is null;
      --
      vn_fase := 1;
      --
      -- seta o tipo de integração que será feito
      -- 0 - Válida e Atualiza os dados
      -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
      -- Todos os procedimentos de integração fazem referência a ele
      pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
      --
      vn_fase := 1.1;
      --
      pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
      --
      vn_fase := 2;
      --
	  -- INICIO 1979
	   vn_multorg_id := rec_mo.id;
	         --
	   -- Busca o Parametro para checar se 
	   if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => vn_multorg_id,
	                                                 en_empresa_id => NULL,
	                                                 en_modulo_id  => MODULO_SISTEMA,
	                                                 en_grupo_id   => GRUPO_SISTEMA,
	                                                 ev_param_name => 'UTILIZA_RABBIT_MQ',
	                                                 sv_vlr_param  => vn_util_rabbitmq,
	                                                 sv_erro       => vv_erro) then
	      --
	      vn_util_rabbitmq := 0;
	      --
	   end if;
	   IF vn_util_rabbitmq = 0 THEN
	   pkb_ler_NF_Integradas ( en_multorg_id => rec_mo.id );
	   --
	   vn_fase := 3;
	   --
	   pk_csf_api.pkb_gera_lote ( en_multorg_id => rec_mo.id );
	   END IF;
      -- inicia a leitura para validação dos dados da nota fiscal
      /*pkb_ler_NF_Integradas ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 3;
      --
      pk_csf_api.pkb_gera_lote ( en_multorg_id => rec_mo.id ); 1979 */
      --
      vn_fase := 4;
      -- Inicia a leitura de Notas Fiscais Canceladas para validação
      --COMENTADO 1979 SERÁ TRATADO NO RABBITMQ E SERÁ CHAMADO PELA TRIGGER T_A_I_NOTAFISCAL_CANC_RABBITMQ
      pkb_ler_Nota_Fiscal_Canc ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 5;
      -- Inicia a leitura das Inutilizações "Não Validadas"
      pk_csf_api.pkb_consit_inutilizacao ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 6;
      -- Processo de atualização da inutilização
      pk_csf_api.pkb_atual_nfe_inut ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 7;
      -- processa log das NF-e
      --pk_csf_api.pkb_reg_log_proc_nfe;
      --
      vn_fase := 8;
      -- Reenvia lote com erro no envio ao Sefaz
      pk_csf_api.pkb_reenvia_lote ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 8.1;
      -- ajusta lote nfe
      pk_csf_api.pkb_ajusta_lote_nfe ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 10;
      -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
      pk_csf_api.pkb_finaliza_log_generico_nf;
      --
      vn_fase := 11;
      --
      pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => null );
      --
      vn_fase := 13;
      -- leitura/validação da carta de correção
      pkb_ler_nota_fiscal_cce ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 14;
      -- Inicia a leitura para notas legado com DM_ST_PROC 4(validadas) e nf referenciada sem dados e com chave gravada
      pkb_ler_NF_Int_Legado_Ref ( en_multorg_id => rec_mo.id );
      --	  
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_integracao fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem          => pk_csf_api.gv_mensagem_log
                                        , ev_resumo            => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log          => pk_csf_api.ERRO_DE_SISTEMA
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_integracao;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a validação de Notas Fiscais por MultOrg demais modelos menos modelo 65
procedure pkb_integracao_mo ( en_multorg_id  in mult_org.id%type )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   -- seta o tipo de integração que será feito
   -- 0 - Válida e Atualiza os dados
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
   --
   vn_fase := 1.1;
   --
   pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   vn_fase := 2;
   --
   -- inicia a leitura para validação dos dados da nota fiscal
   -- INICIO 1979
   vn_multorg_id := en_multorg_id;
         --
   -- Busca o Parametro para checar se 
   if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => vn_multorg_id,
                                                 en_empresa_id => NULL,
                                                 en_modulo_id  => MODULO_SISTEMA,
                                                 en_grupo_id   => GRUPO_SISTEMA,
                                                 ev_param_name => 'UTILIZA_RABBIT_MQ',
                                                 sv_vlr_param  => vn_util_rabbitmq,
                                                 sv_erro       => vv_erro) then
      --
      vn_util_rabbitmq := 0;
      --
   end if;
   IF vn_util_rabbitmq = 0 THEN
	   pkb_ler_NF_Integradas ( en_multorg_id => en_multorg_id );
	   --
	   vn_fase := 3;
	   --
	   pk_csf_api.pkb_gera_lote ( en_multorg_id => en_multorg_id );
   END IF;
   --
   -- FIM 1979
   vn_fase := 4;
   -- Inicia a leitura de Notas Fiscais Canceladas para validação
   --COMENTADO 1979 SERÁ TRATADO NO RABBITMQ E SERÁ CHAMADO PELA TRIGGER T_A_I_NOTAFISCAL_CANC_RABBITMQ
   pkb_ler_Nota_Fiscal_Canc ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 5;
   -- Inicia a leitura das Inutilizações "Não Validadas"
   pk_csf_api.pkb_consit_inutilizacao ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 6;
   -- Processo de atualização da inutilização
   pk_csf_api.pkb_atual_nfe_inut ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 7;
   -- processa log das NF-e
   --pk_csf_api.pkb_reg_log_proc_nfe;
   --
   vn_fase := 8;
   -- Reenvia lote com erro no envio ao Sefaz
   pk_csf_api.pkb_reenvia_lote ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 8.1;
   -- ajusta lote nfe
   pk_csf_api.pkb_ajusta_lote_nfe ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 10;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 11;
   --
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
   vn_fase := 13;
   -- leitura/validação da carta de correção
   pkb_ler_nota_fiscal_cce ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 14;
   -- Inicia a leitura para notas legado com DM_ST_PROC 4(validadas) e nf referenciada sem dados e com chave gravada
   pkb_ler_NF_Int_Legado_Ref ( en_multorg_id => en_multorg_id );
   --	  
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_integracao_mo fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem          => pk_csf_api.gv_mensagem_log
                                        , ev_resumo            => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log          => pk_csf_api.ERRO_DE_SISTEMA
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_integracao_mo;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a validação de Notas Fiscais por MultOrg somente para NFCE modelo 65
procedure pkb_integracao_nfce_mo ( en_multorg_id  in mult_org.id%type )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   -- seta o tipo de integração que será feito
   -- 0 - Válida e Atualiza os dados
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
   --
   vn_fase := 1.1;
   --
   pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   vn_fase := 2;
   --
   -- inicia a leitura para validação dos dados da nota fiscal NFCE modelo 65
   pkb_ler_NFCE_Integradas ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 3;
   --
   pk_csf_api.pkb_gera_lote ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 4;
   -- Inicia a leitura de Notas Fiscais Canceladas para validação
   pkb_ler_Nota_Fiscal_NFCE_Canc ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 5;
   -- Inicia a leitura das Inutilizações "Não Validadas"
   pk_csf_api.pkb_consit_inutilizacao ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 6;
   -- Processo de atualização da inutilização
   pk_csf_api.pkb_atual_nfe_inut ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 7;
   -- processa log das NF-e
   --pk_csf_api.pkb_reg_log_proc_nfe;
   --
   vn_fase := 8;
   -- Reenvia lote com erro no envio ao Sefaz
   pk_csf_api.pkb_reenvia_lote ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 8.1;
   -- ajusta lote nfe
   pk_csf_api.pkb_ajusta_lote_nfe ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 10;
   -- Finaliza o log genérico para a integração das Notas Fiscais no CSF
   pk_csf_api.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 11;
   --
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
   vn_fase := 13;
   -- leitura/validação da carta de correção
   pkb_ler_nota_fiscal_cce ( en_multorg_id => en_multorg_id );
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_integracao_nfce_mo fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem          => pk_csf_api.gv_mensagem_log
                                        , ev_resumo            => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log          => pk_csf_api.ERRO_DE_SISTEMA
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_integracao_nfce_mo;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a validação de Processo de Notas Fiscais não relacionados a Emissão
procedure pkb_processos_nfe
is
   --
   vn_fase number := 0;
   --
   cursor c_mo is
   select mo.*
     from mult_org     mo
    where 1 = 1
      and mo.dm_situacao     = 1 -- Ativo
    order by 1;
   --
begin
   --
   for rec_mo in c_mo loop
      exit when c_mo%notfound or (c_mo%notfound) is null;
      --
      vn_fase := 9;
      -- Relaciona a Consulta da Situação da Nfe com a NFe em si
      pk_csf_api_cons_sit.pkb_relac_nfe_cons_sit ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 9.1;
      -- Atualiza Situação do Documento Fiscal
      pk_csf_api.pkb_atual_sit_docto ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 12;
      -- solicita consulta de NFe de Terceiro
      pk_csf_api.pkb_cons_nfe_terc ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 14;
      -- solicita a geração de DANFES não gerados
      pkb_reenvia_impressao_nfe ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 15;
      -- Procedimento cria o "item" de NFe legado
      pk_csf_api.pkb_cria_item_nfe_legado(en_multorg_id => rec_mo.id);
      --
      vn_fase := 16;
      -- Procedimento cria a Pessoa de NFe legado
      pk_csf_api.pkb_cria_pessoa_nfe_legado ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 17;
      -- Validação do Manifesto do destinatário
      pkb_ler_nota_fiscal_mde ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 24;
      -- Procedimento de Consulta de Chaves de Nfe Cancelada de Terceiros
      pkb_cons_nfe_terc_canc ( en_multorg_id => rec_mo.id );
      --
      vn_fase := 25;
      -- procedimento de ajustar cupom fiscal cancelado
      pkb_ajusta_cf_canc ( en_multorg_id => rec_mo.id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_processos_nfe fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem          => pk_csf_api.gv_mensagem_log
                                        , ev_resumo            => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log          => pk_csf_api.ERRO_DE_SISTEMA
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_processos_nfe;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a validação de Processo de Notas Fiscais não relacionados a Emissão por MultOrg
procedure pkb_processos_nfe_mo ( en_multorg_id  in mult_org.id%type )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 9;
   -- Relaciona a Consulta da Situação da Nfe com a NFe em si
   pk_csf_api_cons_sit.pkb_relac_nfe_cons_sit ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 9.1;
   -- Atualiza Situação do Documento Fiscal
   pk_csf_api.pkb_atual_sit_docto ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 12;
   -- solicita consulta de NFe de Terceiro
   pk_csf_api.pkb_cons_nfe_terc ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 14;
   -- solicita a geração de DANFES não gerados
   pkb_reenvia_impressao_nfe ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 15;
   -- Procedimento cria o "item" de NFe legado
   pk_csf_api.pkb_cria_item_nfe_legado(en_multorg_id => en_multorg_id);
   --
   vn_fase := 16;
   -- Procedimento cria a Pessoa de NFe legado
   pk_csf_api.pkb_cria_pessoa_nfe_legado ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 17;
   -- Validação do Manifesto do destinatário
   pkb_ler_nota_fiscal_mde ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 24;
   -- Procedimento de Consulta de Chaves de Nfe Cancelada de Terceiros
   pkb_cons_nfe_terc_canc ( en_multorg_id => en_multorg_id );
   --
   vn_fase := 25;
   -- procedimento de ajustar cupom fiscal cancelado
   pkb_ajusta_cf_canc ( en_multorg_id => en_multorg_id );
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_processos_nfe_mo fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem          => pk_csf_api.gv_mensagem_log
                                        , ev_resumo            => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log          => pk_csf_api.ERRO_DE_SISTEMA
                                        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_processos_nfe_mo;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura das Cartas de Correções das Notas Fiscais

procedure pkb_vld_nota_fiscal_cce( en_notafiscalcce_id in     nota_fiscal_cce.id%type
                                 , sn_erro             in out number         -- 0-Não; 1-Sim
                                 , en_loteintws_id     in     lote_int_ws.id%type
                                 )
is
   --
   vn_fase            number := 0;
   vt_log_generico_nf dbms_sql.number_table;
   --
   cursor c_cce is
   select cce.*
     from nota_fiscal_cce cce
    where cce.id = en_notafiscalcce_id
    order by cce.id;
   --
begin
   --
   vn_fase := 1;
   --
   for r_cce in c_cce
   loop
      --
      exit when c_cce%notfound or (c_cce%notfound) is null;
      --
      vn_fase := 2;
      --
      vt_log_generico_nf.delete;
      --
      -- seta o tipo de integração que será feito
      -- 0 - Válida e Atualiza os dados
      -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
      -- Todos os procedimentos de integração fazem referência a ele
      --
      pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
      --
      vn_fase := 3;
      --
      pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL_CCE' );
      --
      vn_fase := 4;
      --
      pk_csf_api.pkb_seta_referencia_id ( en_id => r_cce.id );
      --
      vn_fase := 5;
      --
      pk_csf_api.gt_row_nota_fiscal_cce := r_cce;
      --
      vn_fase := 6;
      --
      pk_csf_api.pkb_integr_nota_fiscal_cce( est_log_generico_nf     => vt_log_generico_nf
                                           , est_row_nota_fiscal_cce => pk_csf_api.gt_row_nota_fiscal_cce
                                           );
      --
      vn_fase := 7;
      --
      if nvl(vt_log_generico_nf.count,0) > 0 then
         --
         vn_fase := 8;
         --
         sn_erro := 1; -- Sim contém erros
         --
      end if;
      --
      vn_fase := 9;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_vld_nota_fiscal_cce fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api.gv_cabec_log
                                        , ev_resumo           => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api.ERRO_DE_SISTEMA
                                        , en_referencia_id    => en_notafiscalcce_id
                                        , ev_obj_referencia   => 'NOTA_FISCAL_CCE'
				        );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_vld_nota_fiscal_cce;

-------------------------------------------------------------------------------------------------------

-- Procedimento faz a leitura das Notas Fiscais Canceladas

procedure pkb_vld_Nota_Fiscal_Canc ( en_notafiscal_id  in      nota_fiscal.id%type
                                   , sn_erro           in out  number         -- 0-Não; 1-Sim
                                   , en_loteintws_id   in      lote_int_ws.id%type
                                   )
is

   cursor c_Nota_Fiscal_Canc is
   select nfc.*
        , nf.empresa_id
        , nf.nro_nf
        , nf.serie
        , mf.cod_mod
        , nf.dt_emiss
     from Nota_Fiscal       nf
        , Nota_Fiscal_Canc  nfc
        , Mod_Fiscal        mf
    where 1 = 1
      and nf.id             = en_notafiscal_id
      and nf.dm_st_proc     in (0, 4) -- Integradas ou Integradas
      and nf.dm_ind_emit    = 0 -- Emissão Própria
      and nfc.notafiscal_id = nf.id
      and (nfc.cod_msg is null or nfc.cod_msg <> '219')  -- Rejeição: Circulação da NF-e verificada
      and mf.id             = nf.modfiscal_id
      and mf.cod_mod        in ('55', '65');

   vn_fase               number := 0;
   vt_log_generico_nf       dbms_sql.number_table;
   vn_notafiscal_id      Nota_Fiscal.id%TYPE;

begin
   --
   vn_fase := 1;
   --
   for rec in c_Nota_Fiscal_Canc loop
      exit when c_Nota_Fiscal_Canc%notfound or (c_Nota_Fiscal_Canc%notfound) is null;
      --
      vn_fase := 2;
      --
      vt_log_generico_nf.delete;
      --
      vn_fase := 3;
      --
      -- Cancelamento da Nota Fiscal
      pk_csf_api.gt_row_Nota_Fiscal_Canc := null;
      --
      vn_fase := 4;
      --
      pk_csf_api.pkb_seta_referencia_id ( en_id => rec.notafiscal_id );
      --
      vn_fase := 4.1;
      --
      pk_csf_api.gt_row_Nota_Fiscal_Canc.id             := rec.id;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.notafiscal_id  := rec.notafiscal_id;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.dt_canc        := rec.dt_canc;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.justif         := rec.justif;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.dm_st_integra  := rec.dm_st_integra;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.usuario_id     := rec.usuario_id;
      pk_csf_api.gt_row_Nota_Fiscal_Canc.dm_canc_extemp := rec.dm_canc_extemp;
      --
      vn_fase := 5;
      -- Chama o procedimento de integração da Nota Fiscal Cancelada
      pk_csf_api.pkb_integr_Nota_Fiscal_Canc ( est_log_generico_nf       => vt_log_generico_nf
                                             , est_row_Nota_Fiscal_Canc  => pk_csf_api.gt_row_Nota_Fiscal_Canc 
                                             , en_loteintws_id           => en_loteintws_id
                                             );
      --
      vn_fase := 99;
      -- Se registrou algum log, altera a Nota Fiscal para dm_st_proc = 10 - "Erro de Validação"
      if nvl(vt_log_generico_nf.count,0) > 0 then
         --
         vn_fase := 99.1;
         --
         sn_erro := 1; -- Sim contém erros
         --
         begin
            --
            vn_fase := 99.2;
            --
            -- Variavel global usada em logs de triggers (carrega)
            gv_objeto := 'pk_valida_ambiente.pkb_vld_Nota_Fiscal_Canc'; 
            gn_fase   := vn_fase;
            --
            update Nota_Fiscal set dm_st_proc = 4
                                 , dt_st_proc = sysdate
             where id = rec.notafiscal_id;
            --
            -- Variavel global usada em logs de triggers (limpa)
            gv_objeto := 'pk_valida_ambiente';
            gn_fase   := null;
            --
         exception
            when others then
               --
               pk_csf_api.gv_mensagem_log := 'Erro na pkb_vld_Nota_Fiscal_Canc fase(' || vn_fase || '):' || sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_nf.id%TYPE;
               begin
                  --
                  pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                              , ev_mensagem        => pk_csf_api.gv_mensagem_log
                                              , ev_resumo          => pk_csf_api.gv_mensagem_log
                                              , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                              , en_referencia_id   => rec.id
                                              , ev_obj_referencia  => 'NOTA_FISCAL' );
                  --
               exception
                  when others then
                     null;
               end;
               --
               raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
               --
         end;
         --
      end if;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_vld_Nota_Fiscal_Canc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_cabec_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , en_referencia_id   => vn_notafiscal_id
                                     , ev_obj_referencia  => 'NOTA_FISCAL' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_vld_Nota_Fiscal_Canc;

------------------------------------------------------------------------------------------------------

-- Procedimento faz a validação das Notas Fiscais Mercantis (Emissão Própria/Terceiro), solicitadas por Webservice

procedure pkb_vld_nf ( en_notafiscal_id  in      nota_fiscal.id%type
                     , sn_erro           in out  number         -- 0-Não; 1-Sim
                     , en_loteintws_id   in      lote_int_ws.id%type
                     )
is
   --
   vn_fase               number := 0;
   vn_qtde               number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   pkb_ler_Nota_Fiscal ( en_notafiscal_id => en_notafiscal_id
                       , en_loteintws_id  => en_loteintws_id
                       );
   --
   vn_fase := 2;
   --
   begin
      --
      select count(1)
        into vn_qtde
        from nota_fiscal
       where id = en_notafiscal_id
         and dm_st_proc in (5, 10, 11, 12, 13, 15, 16, 99);
      --
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   vn_fase := 3;
   --
   if nvl(vn_qtde,0) > 0 then
      sn_erro := 1;
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pkb_vld_nf fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
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
end pkb_vld_nf;

------------------------------------------------------------------------------------------------------

-- Procedimento faz a validação das Inutilizações de Notas Fiscais Mercantis, solicitadas por Webservice

procedure pkb_vld_inf ( en_inutilizanotafiscal_id  in      inutiliza_nota_fiscal.id%type
                      , sn_erro                    in out  number         -- 0-Não; 1-Sim
                      , en_loteintws_id            in      lote_int_ws.id%type
                      )
is
   --
   vn_fase               number := 0;
   vn_qtde               number := 0;
   --
   vv_cod_mod                mod_fiscal.cod_mod%type;
   vt_inutiliza_nota_fiscal  inutiliza_nota_fiscal%rowtype;
   vt_log_generico_nf        dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   vt_inutiliza_nota_fiscal := null;
   vt_log_generico_nf.delete;
   pk_csf_api.gv_obj_referencia := 'INUTILIZA_NOTA_FISCAL';
   pk_csf_api.gn_referencia_id := en_inutilizanotafiscal_id;
   --
   begin
      --
      select * into vt_inutiliza_nota_fiscal
        from inutiliza_nota_fiscal
       where id = en_inutilizanotafiscal_id;
      --
   exception
      when others then
         vt_inutiliza_nota_fiscal := null;
   end;
   --
   vn_fase := 1.1;
   --
   vv_cod_mod := pk_csf.fkg_cod_mod_id ( en_modfiscal_id => vt_inutiliza_nota_fiscal.modfiscal_id );
   --
   vn_fase := 1.2;
   --
   pk_csf_api.pkb_integr_inutilizanf ( est_log_generico_nf           => vt_log_generico_nf
                                     , est_row_Inutiliza_Nota_Fiscal => vt_inutiliza_nota_fiscal
                                     , ev_cod_mod                    => vv_cod_mod
                                     );
   --
   vn_fase := 2;
   --
   begin
      --
      select count(1)
        into vn_qtde
        from inutiliza_nota_fiscal
       where id = en_inutilizanotafiscal_id
         and dm_situacao in (3, 4, 6);
      --
   exception
      when others then
         vn_qtde := 0;
   end;
   --
   vn_fase := 3;
   --
   if nvl(vn_qtde,0) > 0 then
      sn_erro := 1;
   end if;
   --
exception
   when others then
      --
      pk_csf_api_nfs.gv_mensagem_log := 'Erro na pkb_vld_inf fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem          => pk_csf_api_nfs.gv_cabec_log
                                        , ev_resumo            => pk_csf_api_nfs.gv_mensagem_log
                                        , en_tipo_log          => pk_csf_api_nfs.ERRO_DE_SISTEMA
                                        , en_referencia_id     => en_inutilizanotafiscal_id
                                        , ev_obj_referencia    => 'INUTILIZA_NOTA_FISCAL'
                                        );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_vld_inf;
--
-- ==================================================================================================================== --
-- Procedimento para recuperar dados dos Nota Fiscal Mercantis a serem validados de origem da Integração por Web-Service
procedure pkb_ler_nfs_int_ws ( en_loteintws_id      in      lote_int_ws.id%type
                             , en_tipoobjintegr_id  in     tipo_obj_integr.id%type
                             , ev_tipoobjintegr_cd  in      tipo_obj_integr.cd%type
                             , sn_erro              in out  number         -- 0-Não; 1-Sim
                             , sn_aguardar          out     number         -- 0-Não; 1-Sim
                             )
is
   --
   vn_fase         number;
   vn_qtde_pend    number;
   vn_qtde         number;
   vv_maquina      varchar2(255);
   vn_objintegr_id number;
   vn_multorg_id   number;
   vn_usuario_id   number;
   ev_tipoobjintegr_cd_rabbit1 varchar2(20) := '1';
   ev_tipoobjintegr_cd_rabbit3 varchar2(20) := '3';
   --
   cursor c_nf is
   select r.notafiscal_id
        , nf.dm_st_proc
        , nf.dt_emiss
        , nf.usuario_id
        , nf.empresa_id
        , nf.dm_legado
     from r_loteintws_nf r
        , nota_fiscal    nf
        , mod_fiscal     mf
    where r.loteintws_id      = en_loteintws_id
      and nf.id               = r.notafiscal_id
      and nf.dm_arm_nfe_terc  = 0 -- Não é de armazenamento fiscal
      and mf.id               = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55')
   union all
   select r2.notafiscal_id
        , nf.dm_st_proc
        , nf.dt_emiss
        , nf.usuario_id
        , nf.empresa_id
        , nf.dm_legado
     from r_loteintws_envdocfiscal r2
        , nota_fiscal    nf
        , mod_fiscal     mf
    where r2.loteintws_id     = en_loteintws_id
      and nf.id               = r2.notafiscal_id
      and nf.dm_arm_nfe_terc  = 0 -- Não é de armazenamento fiscal
      and mf.id               = nf.modfiscal_id
      and mf.cod_mod          in ('01', '1B', '04', '55')
    order by notafiscal_id;
   --
   cursor c_cce is -- Carta de Correção
   select nc.id notafiscalcce_id
     from r_loteintws_nf  rl
        , nota_fiscal_cce nc
    where rl.loteintws_id  = en_loteintws_id
      and nc.notafiscal_id = rl.notafiscal_id
      and nc.dm_st_proc   in (0,4) -- 0-Não validado, 4-Erro de validação -- Não considerar: 1-Validado, 2-Aguardando Envio, 3-Processado ou 5-Rejeitada
    order by nc.id;
   --
   cursor c_inf is
   select r.inutilizanotafiscal_id
        , inf.dm_situacao
     from r_loteintws_inf        r
        , inutiliza_nota_fiscal  inf
    where r.loteintws_id      = en_loteintws_id
      and inf.id              = r.inutilizanotafiscal_id
    order by r.inutilizanotafiscal_id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      --
      vn_fase := 2;
      --
      if ev_tipoobjintegr_cd in ('1', '2', '3') then
         --
         -- 1-Emissão Própria de Notas Fiscais Mercantis, 2-Cancelamento de Emissão Própria de Notas Fiscais Mercantis, 3-Terceiros de Notas Fiscais Mercantis
         --
         vn_fase := 3;
         -- Processo para execução de rotina programável
         vv_maquina := sys_context('USERENV', 'HOST');
         --
         if vv_maquina is null then
            vv_maquina := 'Servidor';
         end if;
         --
         vn_fase := 3.1;
         --
         begin
            select ti.objintegr_id
              into vn_objintegr_id
              from tipo_obj_integr ti
             where ti.id = en_tipoobjintegr_id;
         exception
            when others then
               vn_objintegr_id := 0;
         end;
         --
         vn_fase := 3.2;
         --
         for rec in c_nf loop
            exit when c_nf%notfound or (c_nf%notfound) is null;
            --
            vn_fase := 3.3;
            --
             vn_empresa_id := pk_csf.fkg_empresa_notafiscal(rec.notafiscal_id);
             vn_multorg_id := pk_csf.fkg_multorg_id_empresa(vn_empresa_id);
             if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => vn_multorg_id,
                                                           en_empresa_id => vn_empresa_id,
                                                           en_modulo_id  => MODULO_SISTEMA,
                                                           en_grupo_id   => GRUPO_SISTEMA,
                                                           ev_param_name => 'UTILIZA_RABBIT_MQ',
                                                           sv_vlr_param  => vn_util_rabbitmq,
                                                           sv_erro       => vv_erro) then
                --
                vn_util_rabbitmq := 0;
                --
             end if;
             if vn_util_rabbitmq = 1 then
                ev_tipoobjintegr_cd_rabbit1 := null;
             end if;
            --
            vn_fase := 3.31;
            --
            if rec.dm_st_proc not in (1, 2, 3, 5, 8, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 99) then -- Não sendo Nenhuma das situações
               --
               vn_fase := 3.4;
               --
               if ev_tipoobjintegr_cd in ('1', '3') then -- 1-Emissão Própria de Notas Fiscais Mercantis / 3-Terceiros de Notas Fiscais Mercantis
                  --
                  vn_fase := 3.5;
                  --
                  /*if ev_tipoobjintegr_cd in ('1') then -- 1-EmissÃ£o PrÃ³pria de Notas Fiscais Mercantis (Esse processo deve ser chamado apenas na valida ambiente) 1979
                     -- Procedimento de executar rotinas programadas de pré-validação para NFS
                     pkb_exec_rot_prog_pv_nf ( en_notafiscal_id  => rec.notafiscal_id
                                             , ed_dt_emiss       => rec.dt_emiss
                                             , en_usuario_id     => rec.usuario_id
                                             , en_empresa_id     => rec.empresa_id
                                             );
                     --
                  end if;*/
                  --
                  if rec.dm_legado in (1, 2, 3, 4) then
                     --
                     pkb_vld_nf ( en_notafiscal_id  => rec.notafiscal_id
                                , sn_erro           => sn_erro
                                , en_loteintws_id   => en_loteintws_id
                                );
                     --
                  else
                     --
                     if rec.dm_st_proc not in (4, 6, 7, 8) and ev_tipoobjintegr_cd in (ev_tipoobjintegr_cd_rabbit1, ev_tipoobjintegr_cd_rabbit3) then -- NFe Emiss Própr está sendo tratado no trigger t_a_i_nota_fiscal_rabbitmq_nfe (Tratar via parametro do rabbit: Só vai entrar nota de emissão própria (ev_tipoobjintegr_cd = '1') caso o parametro do rabbit esteja inativo) 1979
                        --
                        pkb_vld_nf ( en_notafiscal_id  => rec.notafiscal_id
                                   , sn_erro           => sn_erro
                                   , en_loteintws_id   => en_loteintws_id
                                   );
                        --
                     end if;
                     --
                  end if;
                  --
                  vn_fase := 3.6;
                  -- Executar as Rotinas Programáveis para a nota fiscal mercantil
                  if nvl(vn_multorg_id,0) = 0 then
                     --
                     vn_fase := 3.7;
                     --
                     vn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => rec.empresa_id );
                     --
                     begin
                        select min(nu.id)
                          into vn_usuario_id
                          from neo_usuario nu
                         where nu.multorg_id = vn_multorg_id;
                     exception
                        when others then
                           null;
                     end;
                     --
                  end if;
                  --
                  vn_fase := 3.8;
                  --| Procedure de execução das rotinas programaveis do tipo "Integração/Ambas"
                  --| Utilizado no processo de Entrada de NFe de Terceiro: PK_ENTR_NFE_TERCEIRO
                  --| Acima temos outra rotina com o mesmo nome, porém com o parâmetro de entrada en_id_doc
                  pk_csf_rot_prog.pkb_exec_rot_prog_integr ( en_id_doc          => rec.notafiscal_id
                                                           , ed_dt_ini          => rec.dt_emiss
                                                           , ed_dt_fin          => rec.dt_emiss
                                                           , ev_obj_referencia  => 'NOTA_FISCAL'
                                                           , en_referencia_id   => rec.notafiscal_id
                                                           , en_usuario_id      => vn_usuario_id
                                                           , ev_maquina         => vv_maquina
                                                           , en_objintegr_id    => vn_objintegr_id
                                                           , en_multorg_id      => vn_multorg_id
                                                           );
                  --
               elsif ev_tipoobjintegr_cd = '2' then -- 2-Cancelamento de Emissão Própria de Notas Fiscais Mercantis
                  --
                  vn_fase := 3.9;
                  --
                  pkb_vld_Nota_Fiscal_Canc ( en_notafiscal_id  => rec.notafiscal_id
                                           , sn_erro           => sn_erro
                                           , en_loteintws_id   => en_loteintws_id
                                           );
                  --
               end if;
               --
            end if;
            --
            vn_fase := 3.10;
            --
            begin
               select count(1)
                 into vn_qtde
                 from nota_fiscal
                where id = rec.notafiscal_id
                  and dm_st_proc in (5, 10, 11, 12, 13, 15, 16, 99);
            exception
               when others then
                  vn_qtde := 0;
            end;
            --
            vn_fase := 3.11;
            --
            if nvl(vn_qtde,0) > 0 then
               sn_erro := 1;
            end if;
            --
         end loop;
         --
         vn_fase := 3.12;
         --
         commit;
         --
         vn_fase := 3.13;
         -- verifica se há NFS Pendentes
         begin
           select sum(qtd)
              into vn_qtde_pend
             from (   select count(1) qtd
              from r_loteintws_nf r
                 , nota_fiscal    nf
                 , mod_fiscal     mf
             where r.loteintws_id      = en_loteintws_id
               and nf.id               = r.notafiscal_id
               and nf.dm_arm_nfe_terc  = 0 -- Não é de armazenamento fiscal
               and nf.dm_st_proc       in (0, 1, 2, 3, 14)
               and mf.id               = nf.modfiscal_id
                         and mf.cod_mod          in ('01', '1B', '04', '55')
                   union all
                      select count(1) qtd
                        from r_loteintws_envdocfiscal r2
                           , nota_fiscal    nf
                           , mod_fiscal     mf
                       where r2.loteintws_id     = en_loteintws_id
                         and nf.id               = r2.notafiscal_id
                         and nf.dm_arm_nfe_terc  = 0 -- Não é de armazenamento fiscal
                         and nf.dm_st_proc       in (0, 1, 2, 3, 14)
                         and mf.id               = nf.modfiscal_id
                         and mf.cod_mod          in ('01', '1B', '04', '55')
                   union all
                      select count(1) qtd
                        from r_loteintws_envdocfiscal r2
                       where r2.loteintws_id     = en_loteintws_id
                         and r2.notafiscal_id is null
                  );
         exception
            when others then
               vn_qtde_pend := 0;
         end;
         --
         vn_fase := 3.14;
         --
         if nvl(vn_qtde_pend,0) > 0 and sn_erro = 0 then -- 1979
            sn_aguardar := 1; -- Sim aguardar fechamento do lote
         else
            sn_aguardar := 0; -- Não aguardar fechamento do lote
         end if;
         --
      elsif ev_tipoobjintegr_cd = '6' then -- 6-Carta de Correção NF (CC-e NF)
            --
            vn_fase := 4;
            --
            for r_cce in c_cce -- Carta de Correção
            loop
               --
               exit when c_cce%notfound or (c_cce%notfound) is null;
               --
               vn_fase := 4.1;
               --
               pkb_vld_nota_fiscal_cce ( en_notafiscalcce_id => r_cce.notafiscalcce_id
                                       , sn_erro             => sn_erro
                                       , en_loteintws_id     => en_loteintws_id
                                       );
               --
            end loop;
            --
            vn_fase := 4.2;
            --
            commit;
            --
            vn_fase := 4.3;
            -- Verificar se alguma carta de correção vinculada ao lote ficou com erro de validação
            begin
               select sum(qtd)
                 into vn_qtde
                 from (
                         select count(1) qtd
                 from r_loteintws_nf rl
                    , nota_fiscal_cce nc
                where rl.loteintws_id  = en_loteintws_id
                  and nc.notafiscal_id = rl.notafiscal_id
                            and nc.dm_st_proc    = 4 -- 4-Erro validação
                         union all
                         select count(1) qtd
                           from r_loteintws_envdocfiscal r2
                              , nota_fiscal_cce nc
                          where r2.loteintws_id  = en_loteintws_id
                            and nc.notafiscal_id = r2.notafiscal_id
                            and nc.dm_st_proc    = 4 -- 4-Erro validação
                      );
            exception
               when others then
                  vn_qtde := 0;
            end;
            --
            vn_fase := 4.4;
            --
            if nvl(vn_qtde,0) > 0 then
               sn_erro := 1; -- 1-Sim
            else
               sn_erro := 0; -- 0-Não
            end if;
            --
            vn_fase := 4.5;
            -- Verificar se alguma carta de correção vinculada ao lote ficou com sem validação
            begin
               select count(1)
                 into vn_qtde_pend
                 from r_loteintws_nf rl
                    , nota_fiscal_cce nc
                where rl.loteintws_id  = en_loteintws_id
                  and nc.notafiscal_id = rl.notafiscal_id
                  and nc.dm_st_proc   in (0,1,2); -- 0-Não validado, 1-Validado, 2-Aguardando envio
            exception
               when others then
                  vn_qtde_pend := 0;
            end;
            --
            vn_fase := 4.6;
            --
            if nvl(vn_qtde_pend,0) > 0 then
               sn_erro     := 1; -- 1-Sim
               sn_aguardar := 1; -- Sim aguardar fechamento do lote
            else
               sn_erro     := 0; -- 0-Não
               sn_aguardar := 0; -- Não aguardar fechamento do lote
            end if;
            --
      else -- ev_tipoobjintegr_cd in ('4', '5') -- 4-Inutilização de Emissão Própria de Notas Fiscais Mercantis, 5-Retorna XML de NFe
         --
         vn_fase := 5;
         --
         for rec_inf in c_inf loop
            exit when c_inf%notfound or (c_inf%notfound) is null;
            --
            vn_fase := 5.1;
            --
            if rec_inf.dm_situacao = 5 then
               --
               vn_fase := 5.2;
               -- chama procedimento de validação
               pkb_vld_inf ( en_inutilizanotafiscal_id  => rec_inf.inutilizanotafiscal_id
                           , sn_erro                    => sn_erro
                           , en_loteintws_id            => en_loteintws_id
                           );
               --
            end if;
            --
            vn_fase := 5.3;
            --
            begin
               select count(1)
                 into vn_qtde
                 from inutiliza_nota_fiscal
                where id = rec_inf.inutilizanotafiscal_id
                  and dm_situacao in (3, 4, 6);
            exception
               when others then
                  vn_qtde := 0;
            end;
            --
            vn_fase := 5.4;
            --
            if nvl(vn_qtde,0) > 0 then
               sn_erro := 1;
            end if;
            --
         end loop;
         --
         vn_fase := 5.5;
         --
         commit;
         --
         vn_fase := 5.6;
         -- verifica se há NFS Pendentes
         begin
            select count(1)
              into vn_qtde_pend
              from r_loteintws_inf r
                 , inutiliza_nota_fiscal  inf
             where r.loteintws_id      = en_loteintws_id
               and inf.id              = r.inutilizanotafiscal_id
               and inf.dm_situacao in (0, 1, 5);
         exception
            when others then
               vn_qtde_pend := 0;
         end;
         --
         vn_fase := 5.7;
         --
         if nvl(vn_qtde_pend,0) > 0 and sn_erro = 0 then -- 1979
            sn_aguardar := 1; -- Sim ainda está sendo processado - Em Processamento - aguardar
         else
            sn_aguardar := 0; -- Não tem mais nada para ser processado - Processado ou Processado com Erro - Status final do lote
         end if;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_ler_nfs_int_ws fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_csf_api.gv_mensagem_log
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.ERRO_DE_SISTEMA
                                     , EN_REFERENCIA_ID   => en_loteintws_id
                                     , EV_OBJ_REFERENCIA  => 'LOTE_INT_WS'
                                     );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nfs_int_ws;
--
-- ==================================================================================================================== --
-- Procedimento de validação de dados de Nota Fiscal de Mercantis e Nota Fiscal de Mercantis NFCE modelo 65
-- oriundos de Integração por Web-Service
procedure pkb_int_ws ( en_loteintws_id      in     lote_int_ws.id%type
                     , en_tipoobjintegr_id  in     tipo_obj_integr.id%type
                     , sn_erro              in out number
                     , sn_aguardar          out    number   --1 - Sim ainda está sendo processado - Em Processamento - aguardar
                                                            --0 - Não tem mais nada para ser processado - Processado ou Processado com Erro - Status final do lote
                     ) is
   --
   vn_fase              number;
   vv_tipoobjintegr_cd  tipo_obj_integr.cd%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0
      and nvl(en_tipoobjintegr_id,0) > 0
      then
      --
      vn_fase := 2;
      --
      vv_tipoobjintegr_cd := pk_csf.fkg_tipoobjintegr_cd ( en_tipoobjintegr_id => en_tipoobjintegr_id );
      --
      vn_fase := 2.1;
      --
      -- Nota Fiscal Mercantil
      pkb_ler_nfs_int_ws ( en_loteintws_id      => en_loteintws_id
                         , en_tipoobjintegr_id  => en_tipoobjintegr_id
                         , ev_tipoobjintegr_cd  => vv_tipoobjintegr_cd
                         , sn_erro              => sn_erro
                         , sn_aguardar          => sn_aguardar
                         );
      --
   end if;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_valida_ambiente.pkb_int_ws fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => pk_csf_api.gv_mensagem_log
                                        , ev_resumo           => pk_csf_api.gv_mensagem_log
                                        , en_tipo_log         => pk_csf_api.erro_de_sistema
                                        , en_referencia_id    => en_loteintws_id
                                        , ev_obj_referencia   => 'LOTE_INT_WS'
                                     );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api.gv_mensagem_log);
      --
end pkb_int_ws;
--
-- ==================================================================================================================== --
--
end pk_valida_ambiente;
/
