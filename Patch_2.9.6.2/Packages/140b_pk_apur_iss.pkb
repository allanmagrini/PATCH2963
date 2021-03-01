create or replace package body csf_own.pk_apur_iss is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de procedimentos de Apuração do ISS 
-------------------------------------------------------------------------------------------------------
--
-- Procedimento de registro de log de erros na validação
--
procedure pkb_log_generico_apur_iss ( sn_loggenerico_id     out nocopy log_generico_apur_iss.id%type
                                    , ev_mensagem        in            log_generico_apur_iss.mensagem%type
                                    , ev_resumo          in            log_generico_apur_iss.resumo%type
                                    , en_tipo_log        in            csf_tipo_log.cd_compat%type      default 1
                                    , en_referencia_id   in            log_generico_apur_iss.referencia_id%type  default null
                                    , ev_obj_referencia  in            log_generico_apur_iss.obj_referencia%type default null
                                    , en_empresa_id      in            empresa.id%type                  default null
                                    , en_dm_impressa     in            log_generico_apur_iss.dm_impressa%type    default 0)
is
   --
   vn_fase            number := 0;
   vn_empresa_id      empresa.id%type;
   vn_csftipolog_id   csf_tipo_log.id%type := null;
   gv_mensagem        log_generico_apur_iss.mensagem%type;
   pragma             autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gn_processo_id,0) = 0 then
      select processo_seq.nextval
        into gn_processo_id
        from dual;
   end if;
   --
   vn_empresa_id := en_empresa_id;
   --
   if nvl(en_tipo_log,0) > 0 
      and ev_mensagem is not null 
      then
      --
      vn_fase := 2;
      --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericoapuriss_seq.nextval
        into sn_loggenerico_id
        from dual;
      --
      vn_fase := 4;
      --
      insert into log_generico_apur_iss ( id
                               , processo_id
                               , dt_hr_log
                               , mensagem
                               , referencia_id
                               , obj_referencia
                               , resumo
                               , dm_impressa
                               , dm_env_email
                               , csftipolog_id
                               , empresa_id
                               )
                        values ( sn_loggenerico_id     -- Valor de cada log de validação
                               , gn_processo_id        -- Valor ID do processo de integração
                               , sysdate               -- Sempre atribui a data atual do sistema
                               , ev_mensagem           -- Mensagem do log
                               , en_referencia_id      -- Id de referência que gerou o log
                               , ev_obj_referencia     -- Objeto do Banco que gerou o log
                               , ev_resumo
                               , en_dm_impressa
                               , 0
                               , vn_csftipolog_id
                               , vn_empresa_id
                               );
      --
      vn_fase := 5;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_log_generico_apur_iss.pkb_log_generico_apur_iss fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_apur_iss.id%type;
      begin
         pkb_log_generico_apur_iss ( sn_loggenerico_id  => vn_loggenerico_id
                                   , ev_mensagem        => gv_mensagem
                                   , ev_resumo          => gv_mensagem
                                   , en_tipo_log        => erro_de_sistema
                                   );
      exception
         when others then
            null;
      end;
      --
END pkb_log_generico_apur_iss;
--
-------------------------------------------------------------------------------------------------------
--
-- Procedimento para simplificar a chamda do log_generico
--
procedure pkb_grava_log_generico (en_referencia_id in log_generico_apur_iss.referencia_id%type
                                , en_tipo_log      in log_generico_apur_iss.csftipolog_id%type)
is
begin
   --       
   pkb_log_generico_apur_iss (sn_loggenerico_id => gn_loggenerico_id,
                              ev_mensagem       => gv_resumo_log || gv_mensagem_log,
                              ev_resumo         => gv_mensagem_log,
                              en_tipo_log       => en_tipo_log,
                              en_referencia_id  => en_referencia_id,
                              ev_obj_referencia => gv_obj_referencia,
                              en_empresa_id     => gn_empresa_id,
                              en_dm_impressa    => 0);
   
   --
   if en_tipo_log in(ERRO_DE_VALIDACAO, ERRO_DE_SISTEMA) then
      gn_erro := gn_erro + 1;
   end if;   
   --
end pkb_grava_log_generico;
--
-------------------------------------------------------------------------------------------------------
--
-- Procedure para Geração da Apuração do ISS devido a outros municípios.
--
procedure pkg_apur_iss_out_mun (en_apurisssimplificada_id apur_iss_simplificada.id%type)
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   for x in c_apur_iss_ret_out_mun(en_apurisssimplificada_id)
   loop
      --
      vn_fase := 2;
      --
      update APUR_ISS_OUT_MUN t set
         t.vl_iss_retido = x.vl_imposto
      where t.apurisssimplificada_id = en_apurisssimplificada_id
        and t.cidade_id              = x.cidade_id;
      --
      vn_fase := 3;
      --
      if SQL%NOTFOUND then     
         --
         insert into APUR_ISS_OUT_MUN(id,
                                      apurisssimplificada_id,
                                      cidade_id,
                                      vl_iss_retido,
                                      guiapgtoimp_id)
                              values (apurissoutmun_seq.Nextval,
                                      en_apurisssimplificada_id,
                                      x.cidade_id,
                                      x.vl_imposto,
                                      null);
         --                            
      end if;                               
      --                               
   end loop
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_iss.pkg_apur_iss_out_mun fase('||vn_fase||'): '||sqlerrm;
      pkb_grava_log_generico(en_apurisssimplificada_id, ERRO_DE_SISTEMA);   
      --
end pkg_apur_iss_out_mun;
-- 
-------------------------------------------------------------------------------------------------------
--
-- Procedure para gerar apuração do Iss Simplificado
--
procedure pkb_apur_iss_simplificada (en_apurisssimplificada_id apur_iss_simplificada.id%type) 
is
   --
   vn_fase  number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_apur_iss(en_apurisssimplificada_id)
   loop
      --
      update APUR_ISS_SIMPLIFICADA ais set
         dm_situacao       = 1,
         vl_iss_proprio    = rec.vl_iss_proprio,
         vl_iss_retido     = rec.vl_iss_retido,
         vl_iss_total      = (rec.vl_iss_proprio + rec.vl_iss_retido)
      where ais.id = en_apurisssimplificada_id;   
      --
   end loop;
   --
   -- Prepara a apuração do ISS Retino de outros municípios
   --
   vn_fase := 2;
   --
   pkg_apur_iss_out_mun(en_apurisssimplificada_id);
   --
   commit;
   --
exception
   when others then
      gv_mensagem_log := 'Erro desconhecido na rotina pk_apur_iss.pkb_apur_iss_simplificada: fase: '||vn_fase||' - Erro: '||sqlerrm;
      pkb_grava_log_generico(en_apurisssimplificada_id, ERRO_DE_SISTEMA);   
end pkb_apur_iss_simplificada;
--
-------------------------------------------------------------------------------------------------------
--
-- Procedure para Validar apuração do Iss Simplificado
--
procedure pkb_valida_apur_iss_simp (en_apurisssimplificada_id apur_iss_simplificada.id%type) 
is
   --
   vn_fase number := 0;
   vn_erro number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   -- Varre a apuração da empresa e período
   for rec in c_valida_apur (en_apurisssimplificada_id) 
   loop
      --
      vn_erro := 0;
      --
      if rec.dt_inicio is null then
         --
         pb_inc(vn_erro);
         gv_mensagem_log := 'A data de início não foi informada';
         pkb_grava_log_generico(rec.id, ERRO_DE_VALIDACAO);
         --
      end if;
      --
      if rec.dt_fim is null then
         --
         pb_inc(vn_erro);
         gv_mensagem_log := 'A data Fim não foi informada';
         pkb_grava_log_generico(rec.id, ERRO_DE_VALIDACAO);
         --
      end if;
      --
      if nvl(rec.vl_iss_proprio,0) = 0 and
         nvl(rec.vl_iss_retido,0)  = 0 and
         nvl(rec.vl_iss_total,0)   = 0 
       then
         --
         pb_inc(vn_erro);
         gv_mensagem_log := 'A apuração deve conter pelo menos um valor próprio ou retidoo';
         pkb_grava_log_generico(rec.id, ERRO_DE_VALIDACAO);
         --
      end if;
      --
      vn_fase := 2;
      --
      -- Seta o dm_situacao conforma a validação
      if nvl(vn_erro,0) > 0 then
         --
         update APUR_ISS_SIMPLIFICADA ais set
            ais.dm_situacao = 4   --Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação
         where ais.id = rec.id;   
         --
      else
         --
         update APUR_ISS_SIMPLIFICADA ais set
            ais.dm_situacao = 3   --Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação
         where ais.id = rec.id;   
         --
      end if;
      
   end loop;
   --
   commit;
   --
exception
   when others then
      gv_mensagem_log := 'Erro desconhecido na rotina pk_apur_iss.pkb_valida_apur_iss_simp, fase('||vn_fase||')'||sqlerrm;
      pkb_grava_log_generico(en_apurisssimplificada_id, ERRO_DE_SISTEMA);   
end pkb_valida_apur_iss_simp;                                    
-------------------------------------------------------------------------------------------------------
--
-- Procedure para desfazer apuração do Iss Simplificado
--
procedure pkb_desfazer_apur_iss_simp (en_apurisssimplificada_id apur_iss_simplificada.id%type) 
is
begin
   update APUR_ISS_SIMPLIFICADA ais set
      ais.vl_iss_proprio = 0,
      ais.vl_iss_retido  = 0,
      ais.vl_iss_total   = 0,
      ais.dm_situacao    = 0  
     where ais.id = en_apurisssimplificada_id;
   --
   delete apur_iss_out_mun 
     where apurisssimplificada_id = en_apurisssimplificada_id;
   --   
   commit;
   --       
exception
   when others then
      gv_mensagem_log := 'Erro desconhecido na rotina pk_apur_iss.pkb_desfazer_apur_iss_simp: '||sqlerrm;
      pkb_grava_log_generico(en_apurisssimplificada_id, ERRO_DE_SISTEMA);   
end pkb_desfazer_apur_iss_simp;
--
-------------------------------------------------------------------------------------------------------
--
-- Procedure para Geração da Guia de Pagamento de Imposto
--
procedure pkg_gera_guia_pgto (en_apurisssimplificada_id apur_iss_simplificada.id%type,
                              en_usuario_id neo_usuario.id%type) 
is
   --       
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   vn_guiapgtoimp_id    guia_pgto_imp.id%type;
   vv_dt_vencimento     varchar2(10);
   --
begin
   --
   vn_fase := 1;
   --
   --
   -- Geração das Guias do Imposto ISS ---
   for x in (
      select ais.id apurisssimplificada_id
           , e.id empresa_id
           , e.pessoa_id
           , ais.dt_inicio
           , ais.dt_fim
           , last_day(ais.dt_fim) dt_ref
           , ais.vl_iss_proprio
           , ais.vl_iss_retido
           , ais.vl_iss_total
           , pdgi.dm_tipo
           , pdgi.dm_origem
           , pdgi.pessoa_id_sefaz
           , pdgi.obs
           , pdgi.tipoimp_id
           , pdgi.planoconta_id
           , add_months(ais.dt_fim,1) dt_vcto
           , pdgi.dia_vcto
           , pdgi.tiporetimp_id
           , pdgi.tiporetimpreceita_id
           , pdgi.cod_receita
           --
         from APUR_ISS_SIMPLIFICADA ais,
              PARAM_GUIA_PGTO       pgp,
              PARAM_DET_GUIA_IMP   pdgi,
              EMPRESA                 e
      where pgp.empresa_id        = ais.empresa_id
        and pdgi.paramguiapgto_id = pgp.id
        and pdgi.tipoimp_id       = pk_csf.fkg_Tipo_Imposto_id(6) -- ISS
        and pdgi.dm_origem        = 9                             -- Apuração de ISS
        and e.id                  = pdgi.empresa_id_guia
        and ais.id                = en_apurisssimplificada_id 
         )
   loop
      --
      vn_fase := 2;
      --
      vv_dt_vencimento := lpad(x.dia_vcto, 2, '0') || '/' || lpad(extract(month from x.dt_vcto),2, '0') || '/' || extract(year from x.dt_vcto);
      if not pk_csf.fkg_data_valida(vv_dt_vencimento, 'dd/mm/yyyy') then
         raise_application_error (-20101, 'O Parâmetro "PARAM_DET_GUIA_IMP.DIA_VCTO" informa um dia inválido para o mês de apuração - Revise o Parâmetro');
      end if;      
      --
      vn_fase := 2.1;
      --      
      if nvl(x.vl_iss_total,0) > 0 then
         -- Popula a Variável de Tabela -- 
         pk_csf_api_gpi.gt_row_guia_pgto_imp.id                       := null;                          
         pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id               := x.empresa_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.usuario_id               := en_usuario_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_situacao              := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id           := x.tipoimp_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id            := x.tiporetimp_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id     := x.tiporetimpreceita_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id                := x.pessoa_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_tipo                  := x.dm_tipo;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_origem                := x.dm_origem;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_via_impressa         := 1;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_ref                   := x.dt_ref;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_vcto                  := to_date(vv_dt_vencimento, 'dd/mm/yyyy');
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_princ                 := x.vl_iss_total;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_multa                 := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_juro                  := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_outro                 := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_total                 := x.vl_iss_total;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.obs                      := x.obs;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id_sefaz          := x.pessoa_id_sefaz;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_tit_financ           := null;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_alteracao             := sysdate;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_ret_erp               := case pk_csf.fkg_parametro_geral_sistema(pk_csf.fkg_multorg_id_empresa(x.empresa_id), x.empresa_id, 'GUIA_PGTO', 'RET_ERP', 'LIBERA_AUTOM_GUIA_ERP') when '1' then 0 when '0' then 6 end;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.id_erp                   := null;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.planoconta_id            := x.planoconta_id;
         --
         vn_fase := 2.2;
         --
         vn_guiapgtoimp_id := 0;
         --
         -- Chama a procedure de integração e finalização da guia
         pk_csf_api_pgto_imp_ret.pkb_finaliza_pgto_imp_ret(est_log_generico    => vt_csf_log_generico,
                                                           en_empresa_id       => x.empresa_id,
                                                           en_dt_ini           => x.dt_inicio,
                                                           en_dt_fim           => x.dt_fim,
                                                           ev_cod_rec_cd_compl => x.cod_receita,
                                                           sn_guiapgtoimp_id   => vn_guiapgtoimp_id);
         --
         vn_fase := 2.3;
         --
         -- Atualiza o id da guia de pagamento
         update APUR_ISS_SIMPLIFICADA ais set
            ais.guiapgtoimp_id_prop = vn_guiapgtoimp_id,
            ais.dm_situacao_guia    = 1
         where ais.id = x.apurisssimplificada_id;   
         --
      end if;
      --
      vn_fase := 3;
      --
      /*if nvl(x.vl_iss_retido,0) > 0 then
         -- Popula a Variável de Tabela -- 
         pk_csf_api_gpi.gt_row_guia_pgto_imp.id                       := null;                          
         pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id               := x.empresa_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.usuario_id               := en_usuario_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_situacao              := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id           := x.tipoimp_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id            := x.tiporetimp_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id     := x.tiporetimpreceita_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id                := x.pessoa_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_tipo                  := x.dm_tipo;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_origem                := x.dm_origem;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_via_impressa         := 1;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_ref                   := x.dt_ref;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_vcto                  := to_date(vv_dt_vencimento, 'dd/mm/yyyy');
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_princ                 := x.vl_iss_retido;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_multa                 := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_juro                  := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_outro                 := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_total                 := x.vl_iss_retido;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.obs                      := x.obs;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id_sefaz          := x.pessoa_id_sefaz;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_tit_financ           := null;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_alteracao             := sysdate;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_ret_erp               := case pk_csf.fkg_parametro_geral_sistema(pk_csf.fkg_multorg_id_empresa(x.empresa_id), x.empresa_id, 'GUIA_PGTO', 'RET_ERP', 'LIBERA_AUTOM_GUIA_ERP') when '1' then 0 when '0' then 6 end;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.id_erp                   := null;
         --
         vn_fase := 3.1;
         --
         vn_guiapgtoimp_id := 0;
         --
         -- Chama a procedure de integração e finalização da guia
         pk_csf_api_pgto_imp_ret.pkb_finaliza_pgto_imp_ret(est_log_generico    => vt_csf_log_generico,
                                                           en_empresa_id       => x.empresa_id,
                                                           en_dt_ini           => x.dt_inicio,
                                                           en_dt_fim           => x.dt_fim,
                                                           ev_cod_rec_cd_compl => x.cod_receita,
                                                           sn_guiapgtoimp_id   => vn_guiapgtoimp_id);
         --
         vn_fase := 3.2;
         --
         -- Atualiza o id da guia de pagamento
         update APUR_ISS_SIMPLIFICADA ais set
            ais.guiapgtoimp_id_ret = vn_guiapgtoimp_id,
            ais.dm_situacao_guia   = 1
         where ais.id = x.apurisssimplificada_id;   
         --         
      end if;*/
      --      
   end loop;   
   --
   vn_fase := 5;
   --
   -- Gera Guia de ISS Retido para outros Municípios -- 
   for x in (
     select ais.empresa_id
          , pdgi.tipoimp_id
          , e.pessoa_id
          , pdgi.dm_tipo
          , pdgi.dm_origem
          , last_day(ais.dt_fim) dt_ref
          , ais.dt_inicio
          , ais.dt_fim
          , pdgi.obs
          , pdgi.pessoa_id_sefaz
          , pdgi.planoconta_id
          , pdgi.dia_vcto
          , add_months(ais.dt_fim,1) dt_vcto
          , pdgi.tiporetimp_id
          , pdgi.tiporetimpreceita_id
          , pdgi.cod_receita
          , sum(aiom.vl_iss_retido)  vl_iss_retido
       from APUR_ISS_OUT_MUN       aiom
          , APUR_ISS_SIMPLIFICADA   ais
          , EMPRESA                   e 
          , PARAM_GUIA_PGTO         pgp
          , PARAM_DET_GUIA_IMP     pdgi
     where ais.id                = aiom.apurisssimplificada_id
       and e.id                  = ais.empresa_id
       and pgp.empresa_id        = ais.empresa_id
       and pdgi.paramguiapgto_id = pgp.id
       and pdgi.tipoimp_id       = pk_csf.fkg_Tipo_Imposto_id(6) -- ISS
       and pdgi.dm_origem        = 13                            -- Imposto Retido
       and ais.id                = en_apurisssimplificada_id
     group by ais.empresa_id
            , pdgi.tipoimp_id
            , e.pessoa_id
            , pdgi.dm_tipo
            , pdgi.dm_origem
            , last_day(ais.dt_fim)
            , ais.dt_inicio
            , ais.dt_fim
            , pdgi.obs
            , pdgi.pessoa_id_sefaz
            , pdgi.planoconta_id
            , pdgi.dia_vcto
            , add_months(ais.dt_fim,1)
            , pdgi.tiporetimp_id
            , pdgi.tiporetimpreceita_id
            , pdgi.cod_receita
            )
   loop
      --
      vn_fase := 5.1;
      --
      vv_dt_vencimento := lpad(x.dia_vcto, 2, '0') || '/' || lpad(extract(month from x.dt_vcto),2, '0') || '/' || extract(year from x.dt_vcto);
      if not pk_csf.fkg_data_valida(vv_dt_vencimento, 'dd/mm/yyyy') then
         raise_application_error (-20101, 'O Parâmetro "PARAM_DET_GUIA_IMP.DIA_VCTO" informa um dia inválido para o mês de apuração - Revise o Parâmetro');
      end if;
      --      
      vn_fase := 5.2;
      --
      if nvl(x.vl_iss_retido,0) > 0 then
         -- Popula a Variável de Tabela -- 
         pk_csf_api_gpi.gt_row_guia_pgto_imp.id                       := null;                          
         pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id               := x.empresa_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.usuario_id               := en_usuario_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_situacao              := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id           := x.tipoimp_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id            := x.tiporetimp_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id     := x.tiporetimpreceita_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id                := x.pessoa_id;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_tipo                  := x.dm_tipo;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_origem                := x.dm_origem;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_via_impressa         := 1;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_ref                   := x.dt_ref;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_vcto                  := to_date(vv_dt_vencimento, 'dd/mm/yyyy');
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_princ                 := x.vl_iss_retido;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_multa                 := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_juro                  := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_outro                 := 0;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_total                 := x.vl_iss_retido;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.obs                      := x.obs;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id_sefaz          := x.pessoa_id_sefaz;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_tit_financ           := null;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_alteracao             := sysdate;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_ret_erp               := case pk_csf.fkg_parametro_geral_sistema(pk_csf.fkg_multorg_id_empresa(x.empresa_id), x.empresa_id, 'GUIA_PGTO', 'RET_ERP', 'LIBERA_AUTOM_GUIA_ERP') when '1' then 0 when '0' then 6 end;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.id_erp                   := null;
         pk_csf_api_gpi.gt_row_guia_pgto_imp.planoconta_id            := x.planoconta_id;
         --
         vn_guiapgtoimp_id := 0;
         --
         vn_fase := 5.3;
         --         
         -- Chama a procedure de integração e finalização da guia
         pk_csf_api_pgto_imp_ret.pkb_finaliza_pgto_imp_ret(est_log_generico    => vt_csf_log_generico,
                                                           en_empresa_id       => x.empresa_id,
                                                           en_dt_ini           => x.dt_inicio,
                                                           en_dt_fim           => x.dt_fim,
                                                           ev_cod_rec_cd_compl => x.cod_receita,
                                                           sn_guiapgtoimp_id   => vn_guiapgtoimp_id);
         --
         vn_fase := 5.4;
         --
         -- Atualiza o id da guia de pagamento
         update APUR_ISS_OUT_MUN ais set
            ais.guiapgtoimp_id = vn_guiapgtoimp_id
         where ais.apurisssimplificada_id = en_apurisssimplificada_id;
         --
      end if;      
      --   
   end loop;   
   --
   commit;
   --
exception
   when others then
      gv_mensagem_log := 'Erro na pk_apur_iss.pkg_gera_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      pkb_grava_log_generico(en_apurisssimplificada_id, ERRO_DE_SISTEMA);   
      --     
end pkg_gera_guia_pgto; 
--
-------------------------------------------------------------------------------------------------------
-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_apurisssimplificada_id apur_iss_simplificada.id%type,
                                 en_usuario_id neo_usuario.id%type)  
is
   --
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   --
begin
   --
   for x in (
      select * 
         from APUR_ISS_SIMPLIFICADA ais
      where ais.id = en_apurisssimplificada_id)
   loop   
      pk_csf_api_pgto_imp_ret.pkb_estorna_pgto_imp_ret(est_log_generico => vt_csf_log_generico,
                                                       en_empresa_id    => x.empresa_id,
                                                       en_dt_ini        => x.dt_inicio,
                                                       en_dt_fim        => x.dt_fim,
                                                       en_pgtoimpret_id => null);
      --  
      if nvl(vt_csf_log_generico.count,0) > 0 then
         --
         vn_fase := 3.1;
         --
         update guia_pgto_imp t set
           t.dm_situacao = 2 -- Erro de Validação
         , t.usuario_id  = en_usuario_id  
         where t.empresa_id = x.empresa_id
           and t.dt_ref between x.dt_inicio 
                            and x.dt_fim;
         --
      else
         --
         vn_fase := 3.2;
         --
         update guia_pgto_imp t set
           t.dm_situacao = 3 -- Cancelado
         , t.usuario_id  = en_usuario_id  
         where t.empresa_id = x.empresa_id
           and t.dt_ref between x.dt_inicio 
                            and x.dt_fim;
         --      
      end if;                                                           
      -- 
      update APUR_ISS_SIMPLIFICADA ais set
         ais.dm_situacao_guia    = 0,
         ais.guiapgtoimp_id_prop = null,
         ais.guiapgtoimp_id_ret  = null
      where ais.id = x.id;
      -- 
   end loop;
   --   
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_iss.pkg_estorna_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      pkb_grava_log_generico(en_apurisssimplificada_id, ERRO_DE_SISTEMA);   
      --                                                          
end pkg_estorna_guia_pgto; 
--
-------------------------------------------------------------------------------------------------------
--
end pk_apur_iss;
/
