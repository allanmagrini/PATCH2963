create or replace package body csf_own.pk_csf_api_pgto_imp_ret is

-------------------------------------------------------------------------
--| Corpo da Package de API do Pagamento de Impostos no padrão para DCTF
-------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Procedimento de registro de log Generico de Pagamento de Impostos Retidos
procedure pkb_log_generico_pir ( sn_loggenericopir_id     out nocopy log_generico_pir.id%type
                               , ev_mensagem           in            log_generico_pir.mensagem%type
                               , ev_resumo             in            log_generico_pir.resumo%type
                               , en_tipo_log           in            csf_tipo_log.cd_compat%type      default 1
                               , en_referencia_id      in            log_generico_pir.referencia_id%type  default null
                               , ev_obj_referencia     in            log_generico_pir.obj_referencia%type default null
                               , en_empresa_id         in            empresa.id%type                  default null
                               , en_dm_impressa        in            log_generico_pir.dm_impressa%type    default 0
                               )
is
   --
   vn_fase          number := 0;
   vn_empresa_id    Empresa.Id%type;
   vn_csftipolog_id csf_tipo_log.id%type := null;
   pragma           autonomous_transaction;
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
   if nvl(en_tipo_log,0) > 0 and ev_mensagem is not null then
      --
      vn_fase := 2;
      --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericopir_seq.nextval
        into sn_loggenericopir_id
        from dual;
      --
      vn_fase := 4;
      --
      insert into Log_Generico_pir ( id
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
                            values 
                                   ( sn_loggenericopir_id     -- Valor de cada log de validação
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
      gv_mensagem := 'Erro na pk_csf_api_pgto_imp_ret.pkb_log_generico_pir fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%type;
      begin
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => erro_de_sistema );
      exception
         when others then
            null;
      end;
      --
end pkb_log_generico_pir;

------------------------------------------------------------------------------------------

-- Procedimento armazena o valor do "loggenerico_id"
procedure pkb_gt_log_generico_pir ( en_loggenericopir_id in            log_generico_pir.id%type
                                  , est_log_generico_pir in out nocopy dbms_sql.number_table ) is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericopir_id,0) > 0 then
      --
      i := nvl(est_log_generico_pir.count,0) + 1;
      --
      est_log_generico_pir(i) := en_loggenericopir_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_pgto_imp_ret.pkb_gt_log_generico_pir: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%type;
      begin
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => erro_de_sistema );
      exception
         when others then
            null;
      end;
      --
end pkb_gt_log_generico_pir;

---------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Informações da Origem dos recurso dos processos administrativos/judiciário do EFD-REINF
procedure pkb_integr_pirprocreinforigrec ( est_log_generico_pir        in out nocopy  dbms_sql.number_table
                                         , est_pir_proc_reinf_orig_rec in out nocopy  pir_proc_reinf_orig_rec%rowtype
                                         , en_empresa_id               in             empresa.id%type
                                         , en_pirprocreinf_id          in             pir_proc_reinf_desp.id%type
                                         , ev_cod_part                 in             pessoa.cod_part%type
                                         , en_loteintws_id             in             lote_int_ws.id%type default 0
                                         )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   --
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Código de Part.: '|| ev_cod_part;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   vn_fase := 2;
   --
   est_pir_proc_reinf_orig_rec.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id  => pk_csf.fkg_multorg_id_empresa ( en_empresa_id )
                                                                          , ev_cod_part    => ev_cod_part
                                                                          );
   --
   if nvl(est_pir_proc_reinf_orig_rec.pessoa_id,0) = 0 then
      --
      vn_fase := 2.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Código do Participante ('|| ev_cod_part ||') do Advogado inválido ou não cadastrado no Compliance, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_proc_reinf_orig_rec.pirprocreinf_id,0) > 0
    and nvl(est_pir_proc_reinf_orig_rec.pessoa_id,0) > 0 then
    --
    vn_fase := 99.1;
    --
    est_pir_proc_reinf_orig_rec.id := pk_csf_pgto_imp_ret.fkg_pirprocreinforigrec_id ( en_pirprocreinf_id => est_pir_proc_reinf_orig_rec.pirprocreinf_id );
    --
    if nvl(est_pir_proc_reinf_orig_rec.id,0) = 0 then
       --
       select pirprocreinforigrec_seq.nextval
         into est_pir_proc_reinf_orig_rec.id
         from dual;
       --
       insert into csf_own.pir_proc_reinf_orig_rec ( id
                                                   , pirprocreinf_id
                                                   , pessoa_id )
                                             values( est_pir_proc_reinf_orig_rec.id
                                                   , est_pir_proc_reinf_orig_rec.pirprocreinf_id
                                                   , est_pir_proc_reinf_orig_rec.pessoa_id
                                                   );
       --
    else
       --
       update csf_own.pir_proc_reinf_orig_rec
          set pirprocreinf_id  = est_pir_proc_reinf_orig_rec.pirprocreinf_id
            , pessoa_id        = est_pir_proc_reinf_orig_rec.pessoa_id
        where id               = est_pir_proc_reinf_orig_rec.id;
       --
    end if;
    --
    commit;
    --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Origem de Recursos de processos/judicial VW_CSF_PIR_PROC_REINF_ORIG_REC inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pirprocreinforigrec fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pirprocreinforigrec;

---------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Despesas de com Advogados
procedure pkb_integr_pirprocreinfdespadv ( est_log_generico_pir        in out nocopy  dbms_sql.number_table
                                         , est_pir_proc_reinf_desp_adv in out nocopy  pir_proc_reinf_desp_adv%rowtype
                                         , en_empresa_id               in             empresa.id%type
                                         , en_pirprocreinfdesp_id      in             pir_proc_reinf_desp.id%type
                                         , ev_cod_part                 in             pessoa.cod_part%type
                                         , en_loteintws_id             in             lote_int_ws.id%type default 0
                                         )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   --
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Código de Part.: '|| ev_cod_part;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   vn_fase := 2;
   --
   est_pir_proc_reinf_desp_adv.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id  => pk_csf.fkg_multorg_id_empresa ( en_empresa_id )
                                                                      , ev_cod_part    => ev_cod_part
                                                                      );
   --
   if nvl(est_pir_proc_reinf_desp_adv.pessoa_id,0) = 0 then
      --
      vn_fase := 2.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Código do Participante ('|| ev_cod_part ||') do Advogado inválido ou não cadastrado no Compliance, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_pir_proc_reinf_desp_adv.vl_advogado,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor da despesa com o advogado não pode ser menor ou igual a Zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_proc_reinf_desp_adv.pirprocreinfdesp_id,0) > 0
    and nvl(est_pir_proc_reinf_desp_adv.pessoa_id,0) > 0
    and nvl(est_pir_proc_reinf_desp_adv.vl_advogado,0) > 0 then
    --
    vn_fase := 99.1;
    --
    est_pir_proc_reinf_desp_adv.id := pk_csf_pgto_imp_ret.fkg_pirprocreinfdespadv_id ( en_pessoa_id => est_pir_proc_reinf_desp_adv.pessoa_id );
    --
    if nvl(est_pir_proc_reinf_desp_adv.id,0) = 0 then
       --
       select pirprocreinfdespadv_seq.nextval
         into est_pir_proc_reinf_desp_adv.id
         from dual;
       --
       insert into csf_own.pir_proc_reinf_desp_adv ( id
                                                   , pirprocreinfdesp_id
                                                   , pessoa_id
                                                   , vl_advogado )
                                             values( est_pir_proc_reinf_desp_adv.id
                                                   , est_pir_proc_reinf_desp_adv.pirprocreinfdesp_id
                                                   , est_pir_proc_reinf_desp_adv.pessoa_id
                                                   , est_pir_proc_reinf_desp_adv.vl_advogado 
                                                   );
       --
    else
       --
       update csf_own.pir_proc_reinf_desp_adv
          set pirprocreinfdesp_id  = est_pir_proc_reinf_desp_adv.pirprocreinfdesp_id
            , pessoa_id            = est_pir_proc_reinf_desp_adv.pessoa_id
            , vl_advogado          = est_pir_proc_reinf_desp_adv.vl_advogado
        where id                   = est_pir_proc_reinf_desp_adv.id;
       --
    end if;
    --
    commit;
    --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Detalhamento das despesas com Advogado de processo judicial VW_CSF_PIR_PROC_REINF_DESP_ADV inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pirprocreinfdespadv fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pirprocreinfdespadv;

----------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Informações de pagamento de impostos retidos do exterior
procedure pkb_integr_pir_info_ext ( est_log_generico_pir      in out nocopy  dbms_sql.number_table
                                  , est_pir_info_ext          in out nocopy  pir_info_ext%rowtype
                                  , en_pgtoimpret_id          in             pgto_imp_ret.id%type
                                  , en_cd_tp_rend_benef_ext   in             tp_rend_benef_ext.cod%type
                                  , ev_cd_form_trib_benf_ext  in             forma_trib_rend_ext.cod%type
                                  , en_loteintws_id           in             lote_int_ws.id%type default 0
                                  )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   --
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Tipo de Rendimento: ' || en_cd_tp_rend_benef_ext;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   est_pir_info_ext.tprendbenefext_id := pk_csf_reinf.fkg_tprendbenefext_id ( en_tprendbenefext_cod => en_cd_tp_rend_benef_ext );
   --
   if nvl(est_pir_info_ext.tprendbenefext_id,0) <= 0 then
      --
      vn_fase := 4.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor do Código do Tipo de Rendimento de Beneficio do Exterior ('|| en_cd_tp_rend_benef_ext ||') inválido, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_pir_info_ext.formatribrendext_id := pk_csf_reinf.fkg_formatribrendext_id ( ev_formatribrendext_cod => ev_cd_form_trib_benf_ext );
   --
   if nvl(est_pir_info_ext.formatribrendext_id,0) <= 0 then
      --
      vn_fase := 5.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor do Código do Forma de Tributação para rendimentos de beneficiários no Exterior ('|| ev_cd_form_trib_benf_ext ||') inválido, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_info_ext.pgtoimpret_id,0) > 0
    and nvl(est_pir_info_ext.tprendbenefext_id,0) > 0
    and nvl(est_pir_info_ext.formatribrendext_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_pir_info_ext.id := pk_csf_pgto_imp_ret.fkg_pirinfoext_id (en_pgtoimpret_id     => est_pir_info_ext.pgtoimpret_id);
      --
      if nvl(est_pir_info_ext.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select pirinfoext_seq.nextval
           into est_pir_info_ext.id
           from dual;
         --
         insert into csf_own.pir_info_ext ( id
                                          , pgtoimpret_id
                                          , tprendbenefext_id
                                          , formatribrendext_id )
                                    values( est_pir_info_ext.id
                                          , est_pir_info_ext.pgtoimpret_id
                                          , est_pir_info_ext.tprendbenefext_id
                                          , est_pir_info_ext.formatribrendext_id );
         --
      else
         --
         vn_fase := 99.3;
         --
         update csf_own.pir_info_ext
            set pgtoimpret_id        = est_pir_info_ext.pgtoimpret_id
              , tprendbenefext_id    = est_pir_info_ext.tprendbenefext_id
              , formatribrendext_id  = est_pir_info_ext.formatribrendext_id
          where id                   = est_pir_info_ext.id;
         --
      end if;
      --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Pagamento de Impostos Retidos no Exterior VW_CSF_PIR_PROC_REINF_DESP inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pir_info_ext fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pir_info_ext;

---------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Despesas de Processos Administrativos/Judiciarios sobre Pagamentos de Impostos Retidos
procedure pkb_integr_pir_proc_reinf_desp ( est_log_generico_pir      in out nocopy  dbms_sql.number_table
                                         , est_pir_proc_reinf_desp   in out nocopy  pir_proc_reinf_desp%rowtype
                                         , en_empresa_id             in             empresa.id%type
                                         , en_pirprocreinf_id        in             pir_proc_reinf.id%type
                                         , en_loteintws_id           in             lote_int_ws.id%type default 0
                                         )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   --
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Valor da despesa com custas judiciais: '|| est_pir_proc_reinf_desp.vl_desp_custas ||
                                 'Valor da despesa com advogado(s): '|| est_pir_proc_reinf_desp.vl_desp_advog;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   if nvl(est_pir_proc_reinf_desp.vl_desp_custas,0) <= 0 then
      --
      vn_fase := 2.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor da despesa com custas judiciais não pode ser menor ou igual a Zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_pir_proc_reinf_desp.VL_DESP_ADVOG,0) <= 0 then
      --
      vn_fase := 3.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor da despesa com advogado(s) não pode ser menor ou igual a Zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_proc_reinf_desp.pirprocreinf_id,0) > 0
    and nvl(est_pir_proc_reinf_desp.vl_desp_custas,0) > 0
    and nvl(est_pir_proc_reinf_desp.VL_DESP_ADVOG,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_pir_proc_reinf_desp.id := pk_csf_pgto_imp_ret.fkg_pirprocreinfdesp_id ( en_pirprocreinf_id => est_pir_proc_reinf_desp.pirprocreinf_id );
      --
      if nvl(est_pir_proc_reinf_desp.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select csf_own.pirprocreinfdesp_seq.nextval
           into est_pir_proc_reinf_desp.id
           from dual;
         --
         insert into csf_own.pir_proc_reinf_desp ( id
                                                 , pirprocreinf_id
                                                 , vl_desp_custas
                                                 , vl_desp_advog )
                                           values( est_pir_proc_reinf_desp.id
                                                 , est_pir_proc_reinf_desp.pirprocreinf_id
                                                 , est_pir_proc_reinf_desp.vl_desp_custas
                                                 , est_pir_proc_reinf_desp.vl_desp_advog );
         --
      else
         --
         update csf_own.pir_proc_reinf_desp
            set pirprocreinf_id = est_pir_proc_reinf_desp.pirprocreinf_id
              , vl_desp_custas  = est_pir_proc_reinf_desp.vl_desp_custas
              , vl_desp_advog   = est_pir_proc_reinf_desp.vl_desp_advog
          where id              = est_pir_proc_reinf_desp.id;
         --
      end if;
      --
      commit;
      --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Detalhamento das despesas de processo judicial VW_CSF_PIR_PROC_REINF_DESP inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pir_proc_reinf_desp fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pir_proc_reinf_desp;
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
                                    )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   vn_emp_matriz_id   empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Dominio do Tipo de Processo: '|| pk_csf.fkg_dominio ( 'PIR_PROC_REINF.DM_IND_ORIG_REC', est_pir_proc_reinf.dm_ind_orig_rec ) ||
                                 ' Informar o número do processo administrativo/judicial: '|| ev_nro_proc ||
                                 ' Código Indicativo de Suspensão: '|| en_cod_susp;
   --
   -- Válidação do Registro
   vn_fase := 2;
   -- Recupera o ID da empresa matriz
   vn_emp_matriz_id := pk_csf.fkg_empresa_id_matriz(en_empresa_id => en_empresa_id);
   --
   vn_fase := 3;
   --
   est_pir_proc_reinf.procadmefdreinfinftrib_id := pk_csf_reinf.fkg_procadmefdreinfinftrib_id ( en_empresa_id => vn_emp_matriz_id
                                                                                              , ed_dt_ref     => ed_dt_pgto
                                                                                              , en_dm_tp_proc => en_dm_tp_proc
                                                                                              , ev_nro_proc   => ev_nro_proc
                                                                                              , en_cod_susp   => en_cod_susp
                                                                                              );
   --
   vn_fase := 4;
   --
   if nvl(est_pir_proc_reinf.procadmefdreinfinftrib_id,0) = 0
    and ( nvl(en_dm_tp_proc,0) > 0 or trim(ev_nro_proc) is not null) then
      --
      vn_fase := 4.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Código de Identificação do Processo Administrativo/Judiciario não encontrado na base com Data do Pagamento do Imposto Retido, segundo os seguintes parametros integrados (DM_TP_PROC: '|| en_dm_tp_proc ||
                   ', NRO_PROC: '|| ev_nro_proc || ', COD_SUSP: ' || en_cod_susp ||'), Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_pir_proc_reinf.dm_ind_orig_rec,0) not in (1, 2) then
      --
      vn_fase := 5.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor do Dominio de Indicador de Origem do Recurso ('|| est_pir_proc_reinf.dm_ind_orig_rec ||') inválido, Favor Verificar. '||
                   'Valores Válidos: 1-Recursos do próprio declarante; 2-Recursos de terceiros - Declarante é a Instituição Financeira responsável apenas pelo repasse dos valores.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_proc_reinf.procadmefdreinfinftrib_id,0) > 0
    and nvl(est_pir_proc_reinf.pgtoimpret_id,0) > 0
    and nvl(est_pir_proc_reinf.dm_ind_orig_rec,0) in (1,2) then
      --
      vn_fase := 99.1;
      --
      est_pir_proc_reinf.id := pk_csf_pgto_imp_ret.fkg_pirprocreinf_id ( en_pgtoimpret_id             => est_pir_proc_reinf.pgtoimpret_id
                                                                       , en_dm_ind_orig_rec           => est_pir_proc_reinf.dm_ind_orig_rec           
                                                                       , en_procadmefdreinfinftrib_id => est_pir_proc_reinf.procadmefdreinfinftrib_id
                                                                       );
      --
      if nvl(est_pir_proc_reinf.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select csf_own.pirprocreinf_seq.nextval
           into est_pir_proc_reinf.id
           from dual;
         --
         insert into csf_own.pir_proc_reinf ( id
                                            , procadmefdreinfinftrib_id
                                            , dm_ind_orig_rec
                                            , pgtoimpret_id )
                                      values( est_pir_proc_reinf.id
                                            , est_pir_proc_reinf.procadmefdreinfinftrib_id
                                            , est_pir_proc_reinf.dm_ind_orig_rec
                                            , est_pir_proc_reinf.pgtoimpret_id );
         --
      else
         --
         vn_fase := 99.3;
         --
         update csf_own.pir_proc_reinf
            set procadmefdreinfinftrib_id = est_pir_proc_reinf.procadmefdreinfinftrib_id
              , dm_ind_orig_rec           = est_pir_proc_reinf.dm_ind_orig_rec           
              , pgtoimpret_id             = est_pir_proc_reinf.pgtoimpret_id
          where id                        = est_pir_proc_reinf.id;
         --
      end if;
      --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Informações Informações Complementares - Demais rendimentos decorrentes de Decisão Judicial VW_CSF_PIR_PROC_REINF inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pir_proc_reinf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pir_proc_reinf;

-----------------------------------------------------------------------------------------
-- Procedimento de integração de Detalhamento das despesas de processo judicial Identificação do Advogado
procedure pkb_integr_pirinfrradespadv ( est_log_generico_pir      in out nocopy  dbms_sql.number_table
                                      , est_pir_inf_rra_desp_adv  in out nocopy  pir_inf_rra_desp_adv%rowtype
                                      , en_empresa_id             in             empresa.id%type
                                      , en_pirinfrradesp_id       in             pir_inf_rra_desp.id%type
                                      , ev_cod_part               in             pessoa.cod_part%type
                                      , en_loteintws_id           in             lote_int_ws.id%type default 0
                                      )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --            DM_IND_PER_REF, DT_REF_PER_PGTO
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Código Part.: '|| ev_cod_part;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   est_pir_inf_rra_desp_adv.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id  => pk_csf.fkg_multorg_id_empresa ( en_empresa_id )
                                                                       , ev_cod_part    => ev_cod_part
                                                                       );
   --
   if nvl(est_pir_inf_rra_desp_adv.pessoa_id,0) = 0 then
      --
      vn_fase := 2.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Código do Participante ('|| ev_cod_part ||') inválido ou não cadastrado no Compliance, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_pir_inf_rra_desp_adv.vl_advogado,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor da despesa com o advogado não pode ser menor ou igual a Zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_inf_rra_desp_adv.pirinfrradesp_id,0) > 0 
    and nvl(est_pir_inf_rra_desp_adv.pessoa_id,0) > 0  
    and nvl(est_pir_inf_rra_desp_adv.vl_advogado,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_pir_inf_rra_desp_adv.id := pk_csf_pgto_imp_ret.fkg_pirinfrradespadv_id ( en_pirinfrradesp_id => est_pir_inf_rra_desp_adv.pirinfrradesp_id
                                                                                 , en_pessoa_id        => est_pir_inf_rra_desp_adv.pessoa_id
                                                                                 );
      --
      if nvl(est_pir_inf_rra_desp_adv.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select csf_own.pirinfrradespadv_seq.nextval
           into est_pir_inf_rra_desp_adv.id
           from dual;
         --
         insert into csf_own.pir_inf_rra_desp_adv ( id
                                                  , pirinfrradesp_id
                                                  , pessoa_id
                                                  , vl_advogado )
                                            values( est_pir_inf_rra_desp_adv.id
                                                  , est_pir_inf_rra_desp_adv.pirinfrradesp_id
                                                  , est_pir_inf_rra_desp_adv.pessoa_id
                                                  , est_pir_inf_rra_desp_adv.vl_advogado 
                                                  );
         --
      else
         --
         vn_fase := 99.3;
         --
         update csf_own.pir_inf_rra_desp_adv
            set pirinfrradesp_id = est_pir_inf_rra_desp_adv.pirinfrradesp_id
              , pessoa_id        = est_pir_inf_rra_desp_adv.pessoa_id       
              , vl_advogado      = est_pir_inf_rra_desp_adv.vl_advogado
          where id               = est_pir_inf_rra_desp_adv.id;
         --
      end if;
      --
      commit;
      --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Informações Detalhamento das despesas de processo judicial Identificação do Advogado VW_CSF_PIR_INF_RRA_DESP_ADV inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pirinfrradespadv fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pirinfrradespadv;

-----------------------------------------------------------------------------------------
-- Procedimento de integração de Informações de Detalhamento das despesas de processo judicial
procedure pkb_integr_pir_inf_rra_desp ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                      , est_pir_inf_rra_desp  in out nocopy  pir_inf_rra_desp%rowtype
                                      , en_empresa_id         in             empresa.id%type
                                      , en_pirinfrra_id       in             pir_inf_rra.id%type
                                      , en_loteintws_id       in             lote_int_ws.id%type default 0
                                      )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --            DM_IND_PER_REF, DT_REF_PER_PGTO
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Valor da despesa com custas judiciais: '|| est_pir_inf_rra_desp.vl_desp_custas ||
                                 'Valor da despesa com advogado(s): '|| est_pir_inf_rra_desp.vl_desp_custas;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   if nvl(est_pir_inf_rra_desp.VL_DESP_CUSTAS,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor da despesa com custas judiciais ('|| est_pir_inf_rra_desp.VL_DESP_CUSTAS ||
                   ') não pode ser menor ou igual a Zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_pir_inf_rra_desp.VL_DESP_ADVOGADOS,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor da despesa com advogado(s) ('|| est_pir_inf_rra_desp.VL_DESP_ADVOGADOS ||
                   ') não pode ser menor ou igual a Zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_inf_rra_desp.pirinfrra_id,0) > 0
    and nvl(est_pir_inf_rra_desp.VL_DESP_CUSTAS,0) > 0
    and nvl(est_pir_inf_rra_desp.VL_DESP_ADVOGADOS,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_pir_inf_rra_desp.id := pk_csf_pgto_imp_ret.fkg_pirinfrradesp_id ( en_pirinfrra_id );
      --
      if nvl(est_pir_inf_rra_desp.id,0) = 0 then
         --
         vn_fase := 99.1;
         --
         select pirinfrradesp_seq.nextval
           into est_pir_inf_rra_desp.id
           from dual;
         --
         insert into csf_own.pir_inf_rra_desp ( id
                                              , pirinfrra_id
                                              , vl_desp_custas
                                              , vl_desp_advogados )
                                        values( est_pir_inf_rra_desp.id
                                              , est_pir_inf_rra_desp.pirinfrra_id
                                              , est_pir_inf_rra_desp.vl_desp_custas
                                              , est_pir_inf_rra_desp.vl_desp_advogados 
                                              );
         --
      else
         --
         update csf_own.pir_inf_rra_desp
            set pirinfrra_id      = est_pir_inf_rra_desp.pirinfrra_id
              , vl_desp_custas    = est_pir_inf_rra_desp.vl_desp_custas
              , vl_desp_advogados = est_pir_inf_rra_desp.vl_desp_advogados
          where id                = est_pir_inf_rra_desp.id;
         --
      end if;
      --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Informações Detalhamento de Compensação Judicial VW_CSF_PIR_INF_RRA_DESP inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pir_inf_rra_desp fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pir_inf_rra_desp;

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
                                 )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   vn_emp_matriz_id   empresa.id%type;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --            DM_IND_PER_REF, DT_REF_PER_PGTO
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || ' Natureza do Rendimento Recebido Acumuladamente: '|| est_pir_inf_rra.nat_rra;
   --
   gn_referencia_id  := est_pir_inf_rra.pgtoimpret_id;
   --
   -- Válidação do Registro
   vn_fase := 2;
   -- Recupera o ID da empresa matriz
   vn_emp_matriz_id := pk_csf.fkg_empresa_id_matriz(en_empresa_id => en_empresa_id);
   --
   vn_fase := 3;
   --
   est_pir_inf_rra.procadmefdreinfinftrib_id := pk_csf_reinf.fkg_procadmefdreinfinftrib_id ( en_empresa_id => vn_emp_matriz_id
                                                                                           , ed_dt_ref     => ed_dt_pgto
                                                                                           , en_dm_tp_proc => en_dm_tp_proc
                                                                                           , ev_nro_proc   => ev_nro_proc  
                                                                                           , en_cod_susp   => en_cod_susp
                                                                                           );
   --
   vn_fase := 4;
   --
   if nvl(est_pir_inf_rra.procadmefdreinfinftrib_id,0) = 0
    and ( nvl(en_dm_tp_proc,0) > 0 or trim(ev_nro_proc) is not null) then
      --
      vn_fase := 4.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Código de Identificação do Processo Administrativo/Judiciario não encontrado com base na Data do Pagamento do Imposto Retido, segundo os seguintes parametros integrados (DM_TP_PROC: '|| en_dm_tp_proc ||
                   ', NRO_PROC: '|| ev_nro_proc || ', COD_SUSP: ' || en_cod_susp ||'), Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_pir_inf_rra.QTDE_MESES_RRA,0) < 0 then
      --
      vn_fase := 5.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'A quantidade de Meses não pode ser menor que zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_inf_rra.pgtoimpret_id,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_pir_inf_rra.id := pk_csf_pgto_imp_ret.fkg_pirinfrra_id ( en_pgtoimpret_id             => est_pir_inf_rra.pgtoimpret_id
                                                                 , en_procadmefdreinfinftrib_id => est_pir_inf_rra.procadmefdreinfinftrib_id
                                                                 );
      --
      if nvl(est_pir_inf_rra.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select pirinfrra_seq.nextval
           into est_pir_inf_rra.id
           from dual;
         --
         insert into csf_own.pir_inf_rra ( id
                                         , pgtoimpret_id
                                         , procadmefdreinfinftrib_id
                                         , nat_rra
                                         , qtde_meses_rra )
                                   values( est_pir_inf_rra.id
                                         , est_pir_inf_rra.pgtoimpret_id
                                         , est_pir_inf_rra.procadmefdreinfinftrib_id
                                         , est_pir_inf_rra.nat_rra
                                         , est_pir_inf_rra.qtde_meses_rra );
         --
      else
         --
         vn_fase := 99.3;
         --
         update csf_own.pir_inf_rra
            set pgtoimpret_id              = est_pir_inf_rra.pgtoimpret_id
              , procadmefdreinfinftrib_id  = est_pir_inf_rra.procadmefdreinfinftrib_id
              , nat_rra                    = est_pir_inf_rra.nat_rra
              , qtde_meses_rra             = est_pir_inf_rra.qtde_meses_rra
          where id                         = est_pir_inf_rra.id;
         --
      end if;
      --
      commit;
      --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Informações Complementares - Rendimentos Recebidos Acumuladamente VW_CSF_PIR_INF_RRA inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pir_inf_rra fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pir_inf_rra;

-----------------------------------------------------------------------------------------
-- Procedimento de integração de informações Detalhamento de Compensação Judicial
procedure pkb_integr_pir_comp_jud ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                  , est_pir_comp_jud      in out nocopy  pir_comp_jud%rowtype
                                  , en_empresa_id         in             empresa.id%type
                                  , en_pgtoimpret_id      in             pgto_imp_ret.id%type
                                  , en_loteintws_id       in             lote_int_ws.id%type default 0
                                  )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --            DM_IND_PER_REF, DT_REF_PER_PGTO
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Valor da Compensação Judicial ano Calendário: '|| est_pir_comp_jud.VL_COMP_ANO_CALEND ||
                                 ' Compensação Judicial relativa a anos anteriores ao ano calendário: '|| est_pir_comp_jud.VL_COMP_ANO_ANT;
   --
   gn_referencia_id  := est_pir_comp_jud.pgtoimpret_id;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   if nvl(est_pir_comp_jud.VL_COMP_ANO_CALEND,0) < 0 then
      --
      vn_fase := 2.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor de Compensação Judicial relativa ao ano calendário não pode ser menor que zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_pir_comp_jud.VL_COMP_ANO_ANT,0) < 0 then
      --
      vn_fase := 3.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor de Compensação Judicial relativa a anos anteriores ao ano calendário não pode ser menor que zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_comp_jud.VL_COMP_ANO_CALEND,0) > 0
    and nvl(est_pir_comp_jud.VL_COMP_ANO_ANT,0) > 0
    and nvl(est_pir_comp_jud.PGTOIMPRET_ID,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_pir_comp_jud.id := pk_csf_pgto_imp_ret.fkg_pircompjud_id ( en_pgtoimpret_id => est_pir_comp_jud.PGTOIMPRET_ID );
      --
      if nvl(est_pir_comp_jud.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select pircompjud_seq.nextval
           into est_pir_comp_jud.id
           from dual;
         --
         insert into csf_own.pir_comp_jud ( id
                                          , pgtoimpret_id
                                          , vl_comp_ano_calend
                                          , vl_comp_ano_ant )
                                    values( est_pir_comp_jud.id
                                          , est_pir_comp_jud.pgtoimpret_id        
                                          , est_pir_comp_jud.vl_comp_ano_calend   
                                          , est_pir_comp_jud.vl_comp_ano_ant 
                                          );
         --
      else
         --
         update csf_own.pir_comp_jud
            set pgtoimpret_id      = est_pir_comp_jud.pgtoimpret_id
              , vl_comp_ano_calend = est_pir_comp_jud.vl_comp_ano_calend  
              , vl_comp_ano_ant    = est_pir_comp_jud.vl_comp_ano_ant
          where id                 = est_pir_comp_jud.id;
         --
      end if;
      --
      commit;
      --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Detalhamento de Compensação Judicial VW_CSF_PIR_COMP_JUD inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pir_comp_jud fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pir_comp_jud;

-----------------------------------------------------------------------------------------
-- Procedimento de integração de informações Detalhamento das Competencias
procedure pkb_integr_pir_det_comp ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                  , est_pir_det_comp      in out nocopy  pir_det_comp%rowtype
                                  , en_empresa_id         in             empresa.id%type
                                  , en_pgtoimpret_id      in             pgto_imp_ret.id%type
                                  , en_loteintws_id       in             lote_int_ws.id%type default 0
                                  )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --            DM_IND_PER_REF, DT_REF_PER_PGTO
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Dominio Indicativo de periódo de Ref.: '|| pk_csf.fkg_dominio ( 'PIR_DET_COMP.DM_IND_PER_REF', est_pir_det_comp.dm_ind_per_ref )
                  || 'Data de Referencia: ' || est_pir_det_comp.dt_ref_per_pgto;
   --
   gn_referencia_id  := est_pir_det_comp.pgtoimpret_id;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   if nvl(est_pir_det_comp.dm_ind_per_ref,-1) not in (1,2) then
      --
      vn_fase := 2.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Dominio Indicativo de Período de Referência ('||est_pir_det_comp.dm_ind_per_ref ||') inválido, Favor Verificar. Valores Válidos: 1- Folha de Pagamento Mensal; '||
                   '2- Folha do Décimo Terceiro Salário.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(est_pir_det_comp.DT_REF_PER_PGTO) is null then
      --
      vn_fase := 3.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Data de Referencia ao qual se refere o pagamento do rendimento Obrigatória, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_pir_det_comp.VL_REND_TRIB,0) < 0 then
      --
      vn_fase := 4.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor do rendimento tributável relativo ao período de referência('|| est_pir_det_comp.VL_REND_TRIB ||
                   ') não pode ser menor ou igual a Zero, Favor Vericar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   if nvl(est_pir_det_comp.dm_ind_per_ref,0) = 1
    and length(est_pir_det_comp.dt_ref_per_pgto) <> 7 then
      --
      vn_fase := 4.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Quando o Dominio Indicador de Periodo de Referencia for igual a 1-Folha de Pagamento Mensal o formatado da Data tem que ser '||
                   'igual a YYYY-MM, Favor Vericar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   elsif nvl(est_pir_det_comp.dm_ind_per_ref,0) = 2
    and length(est_pir_det_comp.dt_ref_per_pgto) <> 4 then
      --
      vn_fase := 4.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Quando o Dominio Indicador de Periodo de Referencia for igual a 1-Folha de Pagamento Mensal o formatado da Data tem que ser '||
                   'igual a YYYY, Favor Vericar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_det_comp.pgtoimpret_id,0) > 0
    and nvl(est_pir_det_comp.DM_IND_PER_REF,0) > 0
    and trim(est_pir_det_comp.dt_ref_per_pgto) is not null
    and nvl(est_pir_det_comp.vl_rend_trib,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_pir_det_comp.id := pk_csf_pgto_imp_ret.fkg_pirdetcomp_id ( en_pgtoimpret_id   => est_pir_det_comp.pgtoimpret_id
                                                                   , en_dm_ind_per_ref  => est_pir_det_comp.dm_ind_per_ref 
                                                                   , ev_dt_ref_per_pgto => est_pir_det_comp.dt_ref_per_pgto
                                                                   );
      --
      if nvl(est_pir_det_comp.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select csf_own.pirdetcomp_seq.nextval
           into est_pir_det_comp.id
           from dual;
         --
         insert into csf_own.pir_det_comp ( id
                                          , pgtoimpret_id
                                          , dm_ind_per_ref
                                          , dt_ref_per_pgto
                                          , vl_rend_trib )
                                    values( est_pir_det_comp.id
                                          , est_pir_det_comp.pgtoimpret_id
                                          , est_pir_det_comp.dm_ind_per_ref
                                          , est_pir_det_comp.dt_ref_per_pgto
                                          , est_pir_det_comp.vl_rend_trib );
         --
      else
         --
         vn_fase := 99.3;
         --
         update csf_own.pir_det_comp
            set pgtoimpret_id    = est_pir_det_comp.pgtoimpret_id
              , dm_ind_per_ref   = est_pir_det_comp.dm_ind_per_ref 
              , dt_ref_per_pgto  = est_pir_det_comp.dt_ref_per_pgto
              , vl_rend_trib     = est_pir_det_comp.vl_rend_trib
          where id               = est_pir_det_comp.id;
         --
      end if;
      --
      commit;
      --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Detalhamento das Competências VW_CSF_PIR_DET_COMP inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pir_det_comp fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pir_det_comp;

-----------------------------------------------------------------------------------------
-- Procedimento de integração de informações de Rendimentos Isentos/Não Tributáveis de Pgto de Impostos Retidos
procedure pkb_integr_pir_rend_isento ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                     , est_pir_rend_isento   in out nocopy  pir_rend_isento%rowtype
                                     , en_empresa_id         in             empresa.id%type
                                     , en_pgtoimpret_id      in             pgto_imp_ret.id%type
                                     , en_cd_tp_isencao      in             tipo_isencao.cd%type
                                     , en_loteintws_id       in             lote_int_ws.id%type default 0
                                     )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Código do Tipo de Isenção: '|| en_cd_tp_isencao || vv_nro_lote;
   --
   gn_referencia_id  := est_pir_rend_isento.pgtoimpret_id;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   est_pir_rend_isento.tipoisencao_id := pk_csf_pgto_imp_ret.fkg_cd_tipoisencao_id ( en_cd_tp_isencao => en_cd_tp_isencao);
   --
   if nvl(est_pir_rend_isento.tipoisencao_id,0) <= 0 then
      --
      vn_fase := 2.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Código de identificação do Tipo de Isenção ('|| en_cd_tp_isencao ||
                   ') Inválido, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_pir_rend_isento.vl_isento,0) <= 0 then
      --
      vn_fase := 2.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor da Parcela Isenta não pode ser menor ou igual a Zero. Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   if nvl(en_cd_tp_isencao,0) = 5 
    and trim(est_pir_rend_isento.descr_rend) is null then
      --
      vn_fase := 2.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Quando o código do Tipo de Isenção é igual 5-Outros (especificar), é obrigatório que seja informada a Descrição de Rendimento Isento.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_rend_isento.pgtoimpret_id,0) > 0
    and nvl(est_pir_rend_isento.tipoisencao_id,0) > 0
    and nvl(est_pir_rend_isento.vl_isento,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_pir_rend_isento.id := pk_csf_pgto_imp_ret.fkg_pirrendisento_id ( en_pgtoimpret_id => est_pir_rend_isento.pgtoimpret_id
                                                                         , en_tipoisencao_id => est_pir_rend_isento.tipoisencao_id
                                                                         );
      --
      if nvl(est_pir_rend_isento.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select pirrendisento_seq.nextval
           into est_pir_rend_isento.id
           from dual;
         --
         insert into csf_own.pir_rend_isento ( id
                                             , pgtoimpret_id
                                             , tipoisencao_id
                                             , vl_isento
                                             , descr_rend )
                                       values( est_pir_rend_isento.id
                                             , est_pir_rend_isento.pgtoimpret_id
                                             , est_pir_rend_isento.tipoisencao_id
                                             , est_pir_rend_isento.vl_isento
                                             , est_pir_rend_isento.descr_rend 
                                             );
         --
      else
         --
         vn_fase := 99.3;
         --
         update csf_own.pir_rend_isento
            set pgtoimpret_id   = est_pir_rend_isento.pgtoimpret_id
              , tipoisencao_id  = est_pir_rend_isento.tipoisencao_id  
              , vl_isento       = est_pir_rend_isento.vl_isento       
              , descr_rend      = est_pir_rend_isento.descr_rend
          where id              = est_pir_rend_isento.id;
         --
      end if;
      --
      commit;
      --
   else
      --
      vn_fase := 99.4;
      --
      gv_resumo := 'Layout da View de Rendimentos Isentos/Não Tributáveis VW_CSF_PIR_REND_ISENTO inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
EXCEPTION
 WHEN OTHERS THEN
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pir_rend_isento fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pir_rend_isento;

-----------------------------------------------------------------------------------------
-- Procedimento de integração de informações complementares de Pgto de Impostos Retidos
-----------------------------------------------------------------------------------------
procedure pkb_integr_pir_det_ded ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                 , est_pir_det_ded       in out nocopy  pir_det_ded%rowtype
                                 , en_empresa_id         in             empresa.id%type
                                 , en_pgtoimpret_id      in             pgto_imp_ret.id%type
                                 , en_loteintws_id       in             lote_int_ws.id%type default 0
                                 )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vv_nro_lote        varchar2(30) := null;
   vv_mensagem        log_generico_pir.mensagem%type;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vv_mensagem := gv_mensagem || 'Indicador de Processo relacionado a não Retenção de Contribuição Previdenciária: '|| pk_csf.fkg_dominio ( 'PIR_DET_DED.DM_IND_TP_DEDUCAO', est_pir_det_ded.dm_ind_tp_deducao ) ||
                  vv_nro_lote;
   --
   gn_referencia_id  := est_pir_det_ded.pgtoimpret_id;
   --
   -- Válidação do Registro
   vn_fase := 2;
   --
   if nvl(est_pir_det_ded.pgtoimpret_id,0) <= 0 then
      --
      vn_fase := 2.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Identificador da tabela de Impostos Retidos não informado/encontrado.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_pir_det_ded.dm_ind_tp_deducao,-1) not in (1,2,3,4,5,6) then
      --
      vn_fase := 3.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Dominio Indicador do Tipo de Dedução Inválido ou não Informado ('|| est_pir_det_ded.dm_ind_tp_deducao ||'), Favor verificar. Valores válidos: 1 - Previdência Oficial;'||
                   '2 - Previdência Privada; 3 - Fapi; 4 - Funpresp; 5 - Pensão Alimentícia; 6 - Dependentes.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_pir_det_ded.vl_deducao,0) <= 0 then
      --
      vn_fase := 4.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'O Valor da dedução da base de cálculo não pode ser Menor ou igual a Zero, Favor Verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_pir_det_ded.pgtoimpret_id,0) > 0 
    and nvl(est_pir_det_ded.dm_ind_tp_deducao,-1) in (1,2,3,4,5,6)
    and nvl(est_pir_det_ded.vl_deducao,0) > 0 then
      --
      vn_fase := 99.1;
      --
      est_pir_det_ded.id := pk_csf_pgto_imp_ret.fkg_pirdetded_id ( en_pgtoimpret_id     => est_pir_det_ded.pgtoimpret_id
                                                                 , en_dm_ind_tp_deducao => est_pir_det_ded.dm_ind_tp_deducao
                                                                 );
      --
      if nvl(est_pir_det_ded.id,0) = 0 then
         --
         vn_fase := 99.2;
         --
         select pirdetded_seq.nextval
           into est_pir_det_ded.id
           from dual;
         --
         insert into csf_own.pir_det_ded ( id
                                         , pgtoimpret_id
                                         , dm_ind_tp_deducao
                                         , vl_deducao )
                                   values( est_pir_det_ded.id
                                         , est_pir_det_ded.pgtoimpret_id
                                         , est_pir_det_ded.dm_ind_tp_deducao
                                         , est_pir_det_ded.vl_deducao 
                                         );
         --
      else
         --
         vn_fase := 99.3;
         --
         update csf_own.pir_det_ded
            set pgtoimpret_id      = est_pir_det_ded.pgtoimpret_id
              , dm_ind_tp_deducao  = est_pir_det_ded.dm_ind_tp_deducao 
              , vl_deducao         = est_pir_det_ded.vl_deducao
          where id                 = est_pir_det_ded.id;
         --
      end if;
      --
      commit;
      --
   else
      --
      gv_resumo := 'Layout da View de Detalhamento das Deduções VW_CSF_PIR_DET_DED inválido (Informação obrigatória vazia ou inválida), favor verificar.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => vv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pir_det_ded fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => vv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pir_det_ded;

-----------------------------------------------------------------------------------------
-- Procedimento de integração dos dados dos documentos fiscais relacionados às retenções
-----------------------------------------------------------------------------------------
procedure pkb_integr_imp_ret_rec_pc_nf ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                       , est_imp_ret_rec_pc_nf in out nocopy  imp_ret_rec_pc_nf%rowtype
                                       , ev_cpf_cnpj_emit      in             varchar2
                                       , ev_cpf_cnpj_emit_nf   in             varchar2
                                       , ev_cod_part_nf        in             varchar2
                                       , ev_cod_mod            in             varchar2
                                       , en_multorg_id         in             mult_org.id%type
                                       , en_loteintws_id       in             lote_int_ws.id%type default 0
                                       )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vn_notafiscal_id   number := 0;
   vv_nro_lote        varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referencia e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'IMP_RET_REC_PC';
   gv_mensagem       := 'Empresa: '||ev_cpf_cnpj_emit||' CNPJ NF: '||ev_cpf_cnpj_emit_nf||' Tipo de emissão: '||
                        pk_csf.fkg_dominio('NOTA_FISCAL.DM_IND_EMIT', est_imp_ret_rec_pc_nf.dm_ind_emit)||' Tipo de operação: '||
                        pk_csf.fkg_dominio('NOTA_FISCAL.DM_IND_OPER', est_imp_ret_rec_pc_nf.dm_ind_oper)||' Código do Cliente: '||ev_cod_part_nf||
                        ' Modelo fiscal: '||ev_cod_mod||' Série: '||est_imp_ret_rec_pc_nf.serie||' Número NF: '||est_imp_ret_rec_pc_nf.nro_nf||vv_nro_lote||'.';
   gn_referencia_id  := est_imp_ret_rec_pc_nf.impretrecpc_id;
   --
   vn_fase := 5;
   --
   if not pk_csf_pgto_imp_ret.fkg_existe_imp_ret_rec_pc ( en_impretrecpc_id => est_imp_ret_rec_pc_nf.impretrecpc_id ) then
      --
      vn_fase := 5.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Identificador dos Impostos Retidos sobre Receita Pis/Cofins não encontrado (id = '||est_imp_ret_rec_pc_nf.impretrecpc_id||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 6;
   -- Recupera o ID da empresa a partir do CNPJ
   if nvl(est_imp_ret_rec_pc_nf.empresa_id,0) <= 0 then
      est_imp_ret_rec_pc_nf.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                                              , ev_cpf_cnpj   => ev_cpf_cnpj_emit_nf );
   end if;
   --
   vn_fase := 6.1;
   --
   if nvl(est_imp_ret_rec_pc_nf.empresa_id,0) <= 0 then
      --
      vn_fase := 6.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Identificador da empresa da nota fiscal não encontrado ('||ev_cpf_cnpj_emit_nf||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 7;
   -- Indicador do emitente. De modo geral, sempre emissão própria: 0-Emissão própria; 1-Terceiros
   if nvl(est_imp_ret_rec_pc_nf.dm_ind_emit,0) not in (0,1) then
      --
      vn_fase := 7.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Indicador do emitente inválido, deve ser: 0-Emissão própria; 1-Terceiros.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 8;
   -- Indicador da operação. De modo geral, sempre saída: 0-Entrada; 1-Saída
   if nvl(est_imp_ret_rec_pc_nf.dm_ind_oper,0) not in (0,1) then
      --
      vn_fase := 8.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Indicador da operação inválido, deve ser: 0-Entrada; 1-Saída.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 9;
   -- Recupera o ID da pessoa a partir do codigo do participante
   if ev_cod_part_nf is null then
      --
      vn_fase := 9.1;
      est_imp_ret_rec_pc_nf.pessoa_id := null;
      --
   else
      --
      vn_fase := 9.2;
      est_imp_ret_rec_pc_nf.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                                       , ev_cod_part   => ev_cod_part_nf );
      --
      vn_fase := 9.3;
      --
      if nvl(est_imp_ret_rec_pc_nf.pessoa_id,0) <= 0 then
         --
         vn_fase := 9.4;
         --
         gv_resumo := null;
         --
         gv_resumo := 'Pessoa não encontrada - Código do participante '||ev_cod_part_nf||').';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      end if;
      --
   end if;
   --
   vn_fase := 10;
   -- Recupera o ID do modelo fiscal a partir da sigla do modelo
   est_imp_ret_rec_pc_nf.modfiscal_id := pk_csf.fkg_mod_fiscal_id( ev_cod_mod => trim(ev_cod_mod) );
   --
   vn_fase := 10.1;
   --
   if nvl(est_imp_ret_rec_pc_nf.modfiscal_id,0) <= 0 then
      --
      vn_fase := 10.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Identificador do modelo do documento fiscal inválido, código enviado = '||ev_cod_mod||'.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 11;
   --
   if est_imp_ret_rec_pc_nf.serie is null then
      --
      vn_fase := 11.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Série do documento fiscal inválido, não pode ser nula.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 12;
   --
   if nvl(est_imp_ret_rec_pc_nf.nro_nf,0) <= 0 then
      --
      vn_fase := 12.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Número do documento fiscal inválido, não pode ser zero/nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 13;                                       
   -- Verificar se a nota fiscal enviado está integrada no Cimpliance.
   vn_notafiscal_id := pk_csf.fkg_busca_notafiscal_id ( en_multorg_id      => en_multorg_id
                                                      , en_empresa_id      => est_imp_ret_rec_pc_nf.empresa_id
                                                      , ev_cod_mod         => ev_cod_mod
                                                      , ev_serie           => est_imp_ret_rec_pc_nf.serie
                                                      , en_nro_nf          => est_imp_ret_rec_pc_nf.nro_nf
                                                      , en_dm_ind_oper     => est_imp_ret_rec_pc_nf.dm_ind_oper
                                                      , en_dm_ind_emit     => est_imp_ret_rec_pc_nf.dm_ind_emit
                                                      , ev_cod_part        => ev_cod_part_nf
                                                      , en_dm_arm_nfe_terc => 0 );
   --
   vn_fase := 13.1;
   --
   if nvl(vn_notafiscal_id,0) > 0 then
      --
      vn_fase := 13.2;
      est_imp_ret_rec_pc_nf.notafiscal_id := nvl(vn_notafiscal_id,0);
      --
   end if;
   --
   -- Processo passou a aceitar Documentos fiscais que não existam no Compliance
   /*
   else
      --
      vn_fase := 13.3;
      --
      est_imp_ret_rec_pc_nf.notafiscal_id := null;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Identificador da nota fiscal - documento fiscal inválido - Não encontrado nos documentos fiscais.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   */
   vn_fase := 14;
   -- Valor do pagamento do documento fiscal (parcelamento)
   if nvl(est_imp_ret_rec_pc_nf.vl_pgto,0) <= 0 then
      --
      vn_fase := 14.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor do pagamento do documento fiscal (parcelamento) não pode ser negativo ou zero/nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_imp_ret_rec_pc_nf.impretrecpc_id,0) > 0 and
      nvl(est_imp_ret_rec_pc_nf.empresa_id,0) > 0 and
      nvl(est_imp_ret_rec_pc_nf.dm_ind_emit,0) in (0, 1) and
      nvl(est_imp_ret_rec_pc_nf.dm_ind_oper,0) in (0, 1) and
      nvl(est_imp_ret_rec_pc_nf.modfiscal_id,0) > 0 and
      est_imp_ret_rec_pc_nf.serie is not null and
      nvl(est_imp_ret_rec_pc_nf.nro_nf,0) > 0 and
      nvl(est_imp_ret_rec_pc_nf.vl_pgto,0) > 0 then
      --
      vn_fase := 99.1;
      --
      if nvl(vn_notafiscal_id,0) = -1 then
         --
         vn_notafiscal_id := null;
         --
      end if;
      --
      est_imp_ret_rec_pc_nf.id := pk_csf_pgto_imp_ret.fkg_imp_ret_rec_pc_nf_id ( en_impretrecpc_id => est_imp_ret_rec_pc_nf.impretrecpc_id
                                                                               , en_notafiscal_id  => vn_notafiscal_id
                                                                               , en_empresa_id_nf  => est_imp_ret_rec_pc_nf.empresa_id
                                                                               , en_dm_ind_emit    => est_imp_ret_rec_pc_nf.dm_ind_emit
                                                                               , en_dm_ind_oper    => est_imp_ret_rec_pc_nf.dm_ind_oper
                                                                               , en_pessoa_id      => pk_csf.fkg_pessoa_id_cod_part( en_multorg_id => en_multorg_id
                                                                                                                                   , ev_cod_part   => ev_cod_part_nf)
                                                                               , en_modfiscal_id   => pk_csf.fkg_mod_fiscal_id( ev_cod_mod => trim(ev_cod_mod) )
                                                                               , ev_serie          => est_imp_ret_rec_pc_nf.serie
                                                                               , en_nro_nf         => est_imp_ret_rec_pc_nf.nro_nf );
      --
      vn_fase := 4;
      --
      if nvl(est_imp_ret_rec_pc_nf.id,0) > 0 then
         --
         vn_fase := 99.2;
         --
         begin
            update imp_ret_rec_pc_nf ir
               set ir.vl_pgto = est_imp_ret_rec_pc_nf.vl_pgto
             where ir.id = est_imp_ret_rec_pc_nf.id;
         exception
            when others then
               --
               gv_resumo := 'Problemas ao atualizar valor de pagamento em pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec_pc_nf fase('||vn_fase||'): '||sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_pir.id%TYPE;
               begin
                  --
                  pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                       , ev_mensagem          => gv_mensagem
                                       , ev_resumo            => gv_resumo
                                       , en_tipo_log          => erro_de_sistema
                                       , en_referencia_id     => gn_referencia_id
                                       , ev_obj_referencia    => gv_obj_referencia );
                  --
               exception
                  when others then
                     null;
               end;
               --
               raise_application_error (-20101, gv_resumo);
               --
         end;
         --
      else
         --
         vn_fase := 99.3;
         --
         begin
            select impretrecpcnf_seq.nextval
              into est_imp_ret_rec_pc_nf.id
              from dual;
         exception
            when others then
               raise_application_error (-20101, 'Problemas ao recuperar sequence para imp_ret_rec_pc_nf. Erro = '||sqlerrm);
         end;
         --
         begin
            insert into imp_ret_rec_pc_nf ( id
                                          , impretrecpc_id
                                          , notafiscal_id
                                          , empresa_id
                                          , dm_ind_emit
                                          , dm_ind_oper
                                          , pessoa_id
                                          , modfiscal_id
                                          , serie
                                          , nro_nf
                                          , vl_pgto
                                          )
                                   values ( est_imp_ret_rec_pc_nf.id
                                          , est_imp_ret_rec_pc_nf.impretrecpc_id
                                          , est_imp_ret_rec_pc_nf.notafiscal_id
                                          , est_imp_ret_rec_pc_nf.empresa_id
                                          , est_imp_ret_rec_pc_nf.dm_ind_emit
                                          , est_imp_ret_rec_pc_nf.dm_ind_oper
                                          , est_imp_ret_rec_pc_nf.pessoa_id
                                          , est_imp_ret_rec_pc_nf.modfiscal_id
                                          , est_imp_ret_rec_pc_nf.serie
                                          , est_imp_ret_rec_pc_nf.nro_nf
                                          , est_imp_ret_rec_pc_nf.vl_pgto
                                          );
         exception
            when others then
               --
               gv_resumo := 'Problemas ao incluir valor de pagamento em pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec_pc_nf fase('||vn_fase||'): '||sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_pir.id%TYPE;
               begin
                  --
                  pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                       , ev_mensagem          => gv_mensagem
                                       , ev_resumo            => gv_resumo
                                       , en_tipo_log          => erro_de_sistema
                                       , en_referencia_id     => gn_referencia_id
                                       , ev_obj_referencia    => gv_obj_referencia );
                  --
               exception
                  when others then
                     null;
               end;
               --
               raise_application_error (-20101, gv_resumo);
               --
         end;
         --
      end if;
      --
      vn_fase := 99.4;
      -- Verifica se o registro está com erro de validação: 0-Não Validado, 1-Validado, 2-Erro de validação
      if nvl(est_log_generico_pir.count,0) > 0 then
         --
         vn_fase := 99.5;
         --
         begin
            update imp_ret_rec_pc ir
               set ir.dm_st_proc = 2 -- Erro de validação
             where ir.id = est_imp_ret_rec_pc_nf.impretrecpc_id;
         exception
            when others then
               --
               gv_resumo := 'Problemas ao atualizar status/erro de validação em pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec_pc_nf fase('||vn_fase||'): '||sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_pir.id%TYPE;
               begin
                  --
                  pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                       , ev_mensagem          => gv_mensagem
                                       , ev_resumo            => gv_resumo
                                       , en_tipo_log          => erro_de_sistema
                                       , en_referencia_id     => gn_referencia_id
                                       , ev_obj_referencia    => gv_obj_referencia );
                  --
               exception
                  when others then
                     null;
               end;
               --
               raise_application_error (-20101, gv_resumo);
               --
         end;
         --
      else
         --
         vn_fase := 99.5;
         --
         begin
            update imp_ret_rec_pc ir
               set ir.dm_st_proc = 1 -- Validado
             where ir.id = est_imp_ret_rec_pc_nf.impretrecpc_id;
         exception
            when others then
               --
               gv_resumo := 'Problemas ao atualizar status/erro de validação em pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec_pc_nf fase('||vn_fase||'): '||sqlerrm;
               --
               declare
                  vn_loggenerico_id  log_generico_pir.id%TYPE;
               begin
                  --
                  pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                       , ev_mensagem          => gv_mensagem
                                       , ev_resumo            => gv_resumo
                                       , en_tipo_log          => erro_de_sistema
                                       , en_referencia_id     => gn_referencia_id
                                       , ev_obj_referencia    => gv_obj_referencia );
                  --
               exception
                  when others then
                     null;
               end;
               --
               raise_application_error (-20101, gv_resumo);
               --
         end;
         --
      end if;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec_pc_nf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_imp_ret_rec_pc_nf;

---------------------------------------------------------------------------------------------
-- Procedimento de integração dos dados das retenções ocorridas nos recebimentos - Flex-Field
---------------------------------------------------------------------------------------------

procedure pkb_integr_imp_ret_rec_pc_ff ( est_log_generico_pir   in out nocopy  dbms_sql.number_table
                                       , en_impretrecpc_id      in             imp_ret_rec_pc.id%type
                                       , ev_atributo            in             varchar2
                                       , ev_valor               in             varchar2 )
is
   --
   vn_fase                 number := 0;
   vn_loggenericopir_id    log_generico_pir.id%type;
   vn_dmtipocampo          ff_obj_util_integr.dm_tipo_campo%type;
   vv_mensagem             varchar2(1000) := null;
   vn_vl_ret_ir            imp_ret_rec_pc.vl_ret_ir%type;
   vn_vl_ret_csll          imp_ret_rec_pc.vl_ret_csll%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem := null;
   --
   if ev_atributo is null then
      --
      vn_fase := 2;
      --
      gv_mensagem := 'Impostos Retidos sobre Receita Pis/Cofins: "Atributo" deve ser informado.';
      --
      vn_loggenericopir_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_mensagem
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if ev_valor is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem := 'Impostos Retidos sobre Receita Pis/Cofins: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericopir_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_mensagem
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos ( ev_obj_name => 'VW_CSF_IMP_RET_REC_PC_FF'
                                             , ev_atributo => ev_atributo
                                             , ev_valor    => ev_valor );
   --
   vn_fase := 4.1;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 4.2;
      --
      gv_mensagem := vv_mensagem;
      --
      vn_loggenericopir_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_mensagem
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   else
      --
      vn_fase := 5;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo ( ev_obj_name => 'VW_CSF_IMP_RET_REC_PC_FF'
                                                          , ev_atributo => ev_atributo );
      --
      vn_fase := 6;
      --
      if ev_atributo = 'VL_RET_IR' and ev_valor is not null then
         --
         vn_fase := 7;
         --
         if vn_dmtipocampo = 1 then -- tipo de campo = numerico
            --
            vn_fase := 8;
            --
            vn_vl_ret_ir := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_IMP_RET_REC_PC_FF'
                                                         , ev_atributo => ev_atributo
                                                         , ev_valor    => ev_valor );
            --
            if nvl(vn_vl_ret_ir,0) < 0 then
               --
               vn_fase := 9;
               --
               gv_mensagem := 'Valor do IR Retido na Fonte ('||ev_valor||') não pode ser negativo.';
               --
               vn_loggenericopir_id := null;
               --
               pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                                    , ev_mensagem          => gv_mensagem
                                    , ev_resumo            => gv_mensagem
                                    , en_tipo_log          => erro_de_validacao
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                       , est_log_generico_pir => est_log_generico_pir );
               --
            end if;
            --
         else
            --
            vn_fase := 10;
            --
            gv_mensagem := 'Para o atributo VL_RET_IR, o VALOR informado não confere com o tipo de campo, deveria ser Numérico.';
            --
            vn_loggenericopir_id := null;
            --
            pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                                 , ev_mensagem          => gv_mensagem
                                 , ev_resumo            => gv_mensagem
                                 , en_tipo_log          => erro_de_validacao
                                 , en_referencia_id     => gn_referencia_id
                                 , ev_obj_referencia    => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                    , est_log_generico_pir => est_log_generico_pir );
            --
         end if;
         --
      elsif ev_atributo = 'VL_RET_CSLL' and ev_valor is not null then
         --
         vn_fase := 11;
         --
         if vn_dmtipocampo = 1 then -- tipo de campo = numerico
            --
            vn_fase := 12;
            --
            vn_vl_ret_csll := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_IMP_RET_REC_PC_FF'
                                                           , ev_atributo => ev_atributo
                                                           , ev_valor    => ev_valor );
            --
            vn_fase := 13;
            --
            if nvl(vn_vl_ret_csll,0) < 0 then
               --
               vn_fase := 14;
               --
               gv_mensagem := 'Valor do CSLL Retido na Fonte ('||ev_valor||') não pode ser negativo.';
               --
               vn_loggenericopir_id := null;
               --
               pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                                    , ev_mensagem          => gv_mensagem
                                    , ev_resumo            => gv_mensagem
                                    , en_tipo_log          => erro_de_validacao
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                       , est_log_generico_pir => est_log_generico_pir );
               --
            end if;
            --
         else
            --
            vn_fase := 15;
            --
            gv_mensagem := 'Para o atributo VL_RET_CSLL, o VALOR informado não confere com o tipo de campo, deveria ser Numérico.';
            --
            vn_loggenericopir_id := null;
            --
            pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                                 , ev_mensagem          => gv_mensagem
                                 , ev_resumo            => gv_mensagem
                                 , en_tipo_log          => erro_de_validacao
                                 , en_referencia_id     => gn_referencia_id
                                 , ev_obj_referencia    => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                    , est_log_generico_pir => est_log_generico_pir );
            --
         end if;
         --
      else
         --
         vn_fase := 16;
         --
         gv_mensagem := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
         --
         vn_loggenericopir_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      end if;
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_log_generico_pir.count,0) > 0 then
      --
      vn_fase := 99.1;
      --
      update imp_ret_rec_pc set dm_st_proc = 2
       where id = en_impretrecpc_id;
      --
   end if;
   --
   vn_fase := 99.2;
   --
   if nvl(en_impretrecpc_id,0) > 0 and
      ev_atributo = 'VL_RET_IR' and
      nvl(vn_vl_ret_ir,0) > 0 and
      gv_mensagem is null then
      --
      vn_fase := 99.3;
      --
      update imp_ret_rec_pc i
         set i.vl_ret_ir = vn_vl_ret_ir
       where i.id = en_impretrecpc_id;
      --
   end if;
   --
   vn_fase := 99.4;
   --
   if nvl(en_impretrecpc_id,0) > 0 and
      ev_atributo = 'VL_RET_CSLL' and
      nvl(vn_vl_ret_csll,0) > 0 and
      gv_mensagem is null then
      --
      vn_fase := 99.5;
      --
      update imp_ret_rec_pc i
         set i.vl_ret_csll = vn_vl_ret_csll
       where i.id = en_impretrecpc_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec_pc_ff fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericopir_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_imp_ret_rec_pc_ff;

---------------------------------------------------------------------------------
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
                                 )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vn_pessoa_id_cnpj  pessoa.id%type;
   vd_data            date;
   vv_existe          varchar2(1) := 'N';
   vv_nro_lote        varchar2(30) := null; 
   --
   cursor c_cnpj (en_cpf_cnpj in number) is
      select pe.id pessoa_id
        from pessoa    pe
           , juridica  ju
       where ju.pessoa_id  = pe.id
         and ju.num_cnpj   = to_number(substr(lpad(en_cpf_cnpj,14,'0'), 1, 8))
         and ju.num_filial = to_number(substr(lpad(en_cpf_cnpj,14,'0'), 9, 4))
         and ju.dig_cnpj   = to_number(substr(lpad(en_cpf_cnpj,14,'0'), 13, 2))
         and pe.multorg_id = en_multorg_id;
   --
   cursor c_cpf (en_cpf_cnpj in number) is
      select pe.id pessoa_id
        from pessoa    pe
           , fisica    fi
       where fi.pessoa_id  = pe.id
         and fi.num_cpf    = to_number(substr(lpad(en_cpf_cnpj,11,'0'), 1, 9))
         and fi.dig_cpf    = to_number(substr(lpad(en_cpf_cnpj,11,'0'), 10, 2))
         and pe.multorg_id = en_multorg_id;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referência e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'IMP_RET_REC_PC';
   gv_mensagem       := 'Empresa: '||ev_cpf_cnpj_emit||' CNPJ Fonte Pagadora/Pesoa Jurídica: '||en_cnpj||' Código do Cliente: '||ev_cod_part||
                        ' Data da retenção: '||est_imp_ret_rec.dt_ret||' Número de controle: '||est_imp_ret_rec.ident_rec || vv_nro_lote;
   --
   vn_fase := 3;
   -- Recupera o ID da retenção ocorrida no recebimento
   est_imp_ret_rec.id := pk_csf_pgto_imp_ret.fkg_imp_ret_rec_pc_id ( en_empresa_id => pk_csf.fkg_empresa_id_pelo_cpf_cnpj( en_multorg_id => en_multorg_id
                                                                                                                         , ev_cpf_cnpj   => ev_cpf_cnpj_emit )
                                                                   , en_pessoa_id  => pk_csf.fkg_pessoa_id_cod_part( en_multorg_id => en_multorg_id
                                                                                                                   , ev_cod_part   => ev_cod_part)
                                                                   , ed_dt_ret     => est_imp_ret_rec.dt_ret
                                                                   , en_ident_rec  => est_imp_ret_rec.ident_rec
                                                                   );
   --
   vn_fase := 4;
   --
   if nvl(est_imp_ret_rec.id,0) <= 0 then
      --
      vn_fase := 4.1;
      --
      select impretrecpc_seq.nextval
        into est_imp_ret_rec.id
        from dual;
      --
   end if;
   --
   vn_fase := 5;
   --
   gn_referencia_id := est_imp_ret_rec.id;
   --
   vn_fase := 6;
   -- Recupera o ID da empresa a partir do CNPJ
   if nvl(est_imp_ret_rec.empresa_id,0) <= 0 then
      est_imp_ret_rec.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   end if;
   --
   vn_fase := 6.1;
   --
   if nvl(est_imp_ret_rec.empresa_id,0) <= 0 then
      --
      vn_fase := 6.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Empresa não encontrada ('||ev_cpf_cnpj_emit||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 7;
   -- Recupera o ID da pessoa a partir do codigo do participante
   est_imp_ret_rec.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                              , ev_cod_part   => ev_cod_part );
   --
   vn_fase := 8;
   --
   if nvl(est_imp_ret_rec.pessoa_id,0) <= 0 then
      --
      vn_fase := 8.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Pessoa não encontrada - Código do participante '||ev_cod_part||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   else
      --
      vn_fase := 8.2;
      --
      vv_existe := 'N';
      --
      for r_cnpj in c_cnpj( en_cpf_cnpj => en_cnpj )
      loop
         --
         exit when c_cnpj%notfound or (c_cnpj%notfound) is null;
         --
         vn_fase := 8.3;
         --
         if nvl(r_cnpj.pessoa_id,0) = nvl(est_imp_ret_rec.pessoa_id,0) then
            --
            vv_existe := 'S';
            exit;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 8.4;
      --
      if vv_existe = 'N' then
         --
         for r_cpf in c_cpf( en_cpf_cnpj => en_cnpj )
         loop
            --
            exit when c_cpf%notfound or (c_cpf%notfound) is null;
            --
            vn_fase := 8.5;
            --
            if nvl(r_cpf.pessoa_id,0) = nvl(est_imp_ret_rec.pessoa_id,0) then
               --
               vv_existe := 'S';
               exit;
               --
            end if;
            --
         end loop;
         --
      end if;
      --
      vn_fase := 8.6;
      --
      if vv_existe = 'N' then
         --
         vn_fase := 8.7;
         --
         gv_resumo := null;
         --
         gv_resumo := 'CNPJ ('||en_cnpj||') informado como Fonte Pagadora Responsável ou Pessoa Jurídica Beneficiária, não pertence ao mesmo identificador '||
                      'de PESSOA informado com Código do cliente ou Código da empresa ('||ev_cod_part||').';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      end if;
      --
   end if;
   --
   vn_fase := 9;
   -- Data de retenção
   begin
      vd_data := est_imp_ret_rec.dt_ret;
   exception
      when others then
         --
         vn_fase := 9.1;
         --
         gv_resumo := null;
         --
         gv_resumo := 'Data de retenção inválida como DATA.';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
   end;
   --
   vn_fase := 10;
   -- Número de controle da retenção
   if nvl(est_imp_ret_rec.ident_rec,0) <= 0 then
      --
      vn_fase := 10.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Número de controle da retenção não pode ser nulo, zero ou negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 11;
   -- Indicador da natureza de retenção na fonte
   if nvl(est_imp_ret_rec.dm_ind_nat_ret,0) not in (1, 2, 3, 4, 5, 99) then
      --
      vn_fase := 11.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Indicador da natureza de retenção na fonte deve ser: 1-Retenção por órgãos, autarquias e fundações federais; ou, 2-Retenção por outras '||
                   'entidades da administração pública federal; ou, 3-Retenção por pessoas jurídicas de direito privado; ou, 4-Recolhimento por sociedade '||
                   'cooperativa; ou, 5-Retenção por fabricante de máquinas e veiculos; ou, 99-Outras retenções.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 12;
   -- Valor da base de cálculo referente à retenção
   if nvl(est_imp_ret_rec.vl_base_calc,0) <= 0 then
      --
      vn_fase := 12.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor da base de cálculo referente à retenção não pode ser negativo ou zero/nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 13;
   -- Valor da retenção
   if nvl(est_imp_ret_rec.vl_ret,0) <= 0 then
      --
      vn_fase := 13.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor da retenção não pode ser negativo ou zero/nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 14;
   -- Indicador da natureza da receita
   if est_imp_ret_rec.dm_ind_nat_rec is not null then
      --   
      if nvl(est_imp_ret_rec.dm_ind_nat_rec,9) not in (0, 1) then
         --
         vn_fase := 14.1;
         --
         gv_resumo := null;
         --
         gv_resumo := 'Indicador da natureza da receita deve ser: 0-Receita não cumulativa; ou, 1-Receita cumulativa.';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      end if;
      --
   end if;	  
   --
   vn_fase := 15;
   -- Valor retido de PIS
   if nvl(est_imp_ret_rec.vl_ret_pis,0) < 0 then
      --
      vn_fase := 15.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor retido de PIS não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 16;
   -- Valor retido de COFINS
   if nvl(est_imp_ret_rec.vl_ret_cofins,0) < 0 then
      --
      vn_fase := 16.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor retido de COFINS não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 17;
   -- Indicador da condição da pessoa declarante
   if est_imp_ret_rec.dm_ind_dec is not null then  
      --   
      if nvl(est_imp_ret_rec.dm_ind_dec,9) not in (0, 1) then
         --
         vn_fase := 17.1;
         --
         gv_resumo := null;
         --
         gv_resumo := 'Indicador da natureza da receita deve ser: 0-Beneficiária da retenção; ou, 1-Responsável pela retenção.';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      end if;
      --
   end if;	  
   --
   vn_fase := 18;
   -- Valor retido de IR
   if nvl(est_imp_ret_rec.vl_ret_ir,0) < 0 then
      --
      vn_fase := 18.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor retido de IR não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 19;
   -- Valor retido de CSLL
   if nvl(est_imp_ret_rec.vl_ret_csll,0) < 0 then
      --
      vn_fase := 19.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor retido de CSLL não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;   
   -- 
   vn_fase := 20;
   --
   if ( nvl(est_imp_ret_rec.vl_ret_pis,0) > 0 or nvl(est_imp_ret_rec.vl_ret_cofins,0) > 0 ) and  
      ( est_imp_ret_rec.dm_ind_nat_rec is null or est_imp_ret_rec.dm_ind_dec is null ) then
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valores de Retenção de PIS e ou COFINS informados maiores que zero os campos, '||
                   '"Indicador da natureza da receita" e ou "Código de receita referente à retenção ou ao recolhimento" '||
                   'devem ser informados.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --							  
   end if;
   --
   vn_fase := 21;
   --
   if nvl(est_imp_ret_rec.vl_ret_pis,0) = 0 and nvl(est_imp_ret_rec.vl_ret_cofins,0) = 0 and 
      nvl(est_imp_ret_rec.vl_ret_ir,0) = 0 and nvl(est_imp_ret_rec.vl_ret_csll,0) = 0 then      
      --
      vn_fase := 21.1;
      --
      gv_mensagem := 'Valores de Retenção de PIS / COFINS / IR e CSLL não informados ao menos um de ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_mensagem
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --   
   end if; 
   --   
   vn_fase := 22;
   -- Tipo de manipulação: 1-Integrado; 2-Integrado/Alterado; 3-Digitado; 4-Digitado/Alterado
   est_imp_ret_rec.dm_tipo := 1;
   --
   vn_fase := 23;
   -- Verifica se o registro está com erro de validação: 0-Não Validado, 1-Validado, 2-Erro de validação
   if nvl(est_log_generico_pir.count,0) > 0 then
      --
      est_imp_ret_rec.dm_st_proc := 2; -- Erro de validação
      --
   else
      --
      est_imp_ret_rec.dm_st_proc := 1; -- Validado
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_imp_ret_rec.empresa_id,0) > 0 and
      nvl(est_imp_ret_rec.pessoa_id,0) > 0 and
      est_imp_ret_rec.dt_ret is not null and
      nvl(est_imp_ret_rec.ident_rec,0) > 0 and
      nvl(est_imp_ret_rec.dm_ind_nat_ret,0) in (1, 2, 3, 4, 5, 99) and
      nvl(est_imp_ret_rec.vl_base_calc,0) > 0 and
      nvl(est_imp_ret_rec.vl_ret,0) > 0 then
      --
      vn_fase := 99.1;
      --
      -- Cálcula a quantidade de registros Totais integrados, com sucesso e com erro para serem
      -- mostrados na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if pk_csf_pgto_imp_ret.fkg_existe_imp_ret_rec_pc(en_impretrecpc_id => est_imp_ret_rec.id ) = true then
         --
         vn_fase := 99.2;
         --
         begin
            --
            update imp_ret_rec_pc ir
               set ir.empresa_id      =  est_imp_ret_rec.empresa_id
                 , ir.pessoa_id       =  est_imp_ret_rec.pessoa_id
                 , ir.dm_st_proc      =  est_imp_ret_rec.dm_st_proc
                 , ir.dm_tipo         =  est_imp_ret_rec.dm_tipo
                 , ir.dt_ret          =  est_imp_ret_rec.dt_ret
                 , ir.ident_rec       =  est_imp_ret_rec.ident_rec
                 , ir.dm_ind_nat_ret  =  est_imp_ret_rec.dm_ind_nat_ret
                 , ir.vl_base_calc    =  est_imp_ret_rec.vl_base_calc
                 , ir.vl_ret          =  est_imp_ret_rec.vl_ret
                 , ir.cod_rec         =  est_imp_ret_rec.cod_rec
                 , ir.dm_ind_nat_rec  =  est_imp_ret_rec.dm_ind_nat_rec
                 , ir.vl_ret_pis      =  est_imp_ret_rec.vl_ret_pis
                 , ir.vl_ret_cofins   =  est_imp_ret_rec.vl_ret_cofins
                 , ir.dm_ind_dec      =  est_imp_ret_rec.dm_ind_dec
                 , ir.vl_ret_ir       =  est_imp_ret_rec.vl_ret_ir
                 , ir.vl_ret_csll     =  est_imp_ret_rec.vl_ret_csll				 
            where ir.id = est_imp_ret_rec.id;
            --
         exception
          when others then
            --
            gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec fase('||vn_fase||'): '||sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_pir.id%TYPE;
            begin
               --
               pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                    , ev_mensagem          => gv_mensagem
                                    , ev_resumo            => gv_resumo
                                    , en_tipo_log          => ERRO_DE_SISTEMA
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                       , est_log_generico_pir => est_log_generico_pir );
               --
            exception
             when others then
               null;
            end;
            --
            null;
            --
         end;
         --
      else
         --
         vn_fase := 99.3;
         --
         begin
            --
            insert into imp_ret_rec_pc ( id
                                       , empresa_id
                                       , pessoa_id
                                       , dm_st_proc
                                       , dm_tipo
                                       , dt_ret
                                       , ident_rec
                                       , dm_ind_nat_ret
                                       , vl_base_calc
                                       , vl_ret
                                       , cod_rec
                                       , dm_ind_nat_rec
                                       , vl_ret_pis
                                       , vl_ret_cofins
                                       , dm_ind_dec
                                       , vl_ret_ir
                                       , vl_ret_csll									   
                                       )
                                values ( est_imp_ret_rec.id
                                       , est_imp_ret_rec.empresa_id
                                       , est_imp_ret_rec.pessoa_id
                                       , est_imp_ret_rec.dm_st_proc
                                       , est_imp_ret_rec.dm_tipo
                                       , est_imp_ret_rec.dt_ret
                                       , est_imp_ret_rec.ident_rec
                                       , est_imp_ret_rec.dm_ind_nat_ret
                                       , est_imp_ret_rec.vl_base_calc
                                       , est_imp_ret_rec.vl_ret
                                       , est_imp_ret_rec.cod_rec
                                       , est_imp_ret_rec.dm_ind_nat_rec
                                       , est_imp_ret_rec.vl_ret_pis
                                       , est_imp_ret_rec.vl_ret_cofins
                                       , est_imp_ret_rec.dm_ind_dec
                                       , est_imp_ret_rec.vl_ret_ir
                                       , est_imp_ret_rec.vl_ret_csll									   
                                       );   
            --
         exception
          when others then
            --
            gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec fase('||vn_fase||'): '||sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_pir.id%TYPE;
            begin
               --
               pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                    , ev_mensagem          => gv_mensagem
                                    , ev_resumo            => gv_resumo
                                    , en_tipo_log          => ERRO_DE_SISTEMA
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                       , est_log_generico_pir => est_log_generico_pir );
               --
            exception
             when others then
               null;
            end;
            --
            null;
            --
         end;
         --
      end if;
      --
   else
      --
      vn_fase := 99.4;
      --
      if pk_csf_pgto_imp_ret.fkg_existe_imp_ret_rec_pc(en_impretrecpc_id => est_imp_ret_rec.id ) = true then
         --
         vn_fase := 99.5;
         --
         update imp_ret_rec_pc ir
            set ir.dm_st_proc = est_imp_ret_rec.dm_st_proc
          where ir.id = est_imp_ret_rec.id;
         --
      end if;
      --
   end if;
   --
   vn_fase := 99.6;
   --
   commit;
   --
exception
   when others then
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => ERRO_DE_SISTEMA
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_imp_ret_rec;

---------------------------------------------------------------------------------
-- Procedimento de integração dos dados das retenções ocorridas nos recebimentos
---------------------------------------------------------------------------------
procedure pkb_integr_imp_ret_rec_pc ( est_log_generico_pir   in out nocopy  dbms_sql.number_table
                                    , est_imp_ret_rec_pc in out nocopy  imp_ret_rec_pc%rowtype
                                    , ev_cpf_cnpj_emit   in             varchar2
                                    , en_cnpj            in             number
                                    , ev_cod_part        in             varchar2
                                    , en_multorg_id      in             mult_org.id%type
                                    , en_loteintws_id    in             lote_int_ws.id%type default 0
                                    )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_pir.id%type;
   vn_pessoa_id_cnpj  pessoa.id%type;
   vd_data            date;
   vv_existe          varchar2(1) := 'N';
   vv_nro_lote        varchar2(30) := null; 
   --
   cursor c_cnpj (en_cpf_cnpj in number) is
      select pe.id pessoa_id
        from pessoa    pe
           , juridica  ju
       where ju.pessoa_id  = pe.id
         and ju.num_cnpj   = to_number(substr(lpad(en_cpf_cnpj,14,'0'), 1, 8))
         and ju.num_filial = to_number(substr(lpad(en_cpf_cnpj,14,'0'), 9, 4))
         and ju.dig_cnpj   = to_number(substr(lpad(en_cpf_cnpj,14,'0'), 13, 2))
         and pe.multorg_id = en_multorg_id;
   --
   cursor c_cpf (en_cpf_cnpj in number) is
      select pe.id pessoa_id
        from pessoa    pe
           , fisica    fi
       where fi.pessoa_id  = pe.id
         and fi.num_cpf    = to_number(substr(lpad(en_cpf_cnpj,11,'0'), 1, 9))
         and fi.dig_cpf    = to_number(substr(lpad(en_cpf_cnpj,11,'0'), 10, 2))
         and pe.multorg_id = en_multorg_id;
   --
begin
   --
   vn_fase := 1;
   -- Montagem do objeto de referência e do cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_obj_referencia := 'IMP_RET_REC_PC';
   gv_mensagem       := 'Empresa: '||ev_cpf_cnpj_emit||' CNPJ Fonte Pagadora/Pesoa Jurídica: '||en_cnpj||' Código do Cliente: '||ev_cod_part||
                        ' Data da retenção: '||est_imp_ret_rec_pc.dt_ret||' Número de controle: '||est_imp_ret_rec_pc.ident_rec || vv_nro_lote;
   --
   vn_fase := 3;
   -- Recupera o ID da retenção ocorrida no recebimento
   est_imp_ret_rec_pc.id := pk_csf_pgto_imp_ret.fkg_imp_ret_rec_pc_id ( en_empresa_id => pk_csf.fkg_empresa_id_pelo_cpf_cnpj( en_multorg_id => en_multorg_id
                                                                                                                            , ev_cpf_cnpj   => ev_cpf_cnpj_emit )
                                                                      , en_pessoa_id  => pk_csf.fkg_pessoa_id_cod_part( en_multorg_id => en_multorg_id
                                                                                                                      , ev_cod_part   => ev_cod_part)
                                                                      , ed_dt_ret     => est_imp_ret_rec_pc.dt_ret
                                                                      , en_ident_rec  => est_imp_ret_rec_pc.ident_rec
                                                                      );
   --
   vn_fase := 4;
   --
   if nvl(est_imp_ret_rec_pc.id,0) <= 0 then
      --
      vn_fase := 4.1;
      --
      select impretrecpc_seq.nextval
        into est_imp_ret_rec_pc.id
        from dual;
      --
   end if;
   --
   vn_fase := 5;
   --
   gn_referencia_id := est_imp_ret_rec_pc.id;
   --
   vn_fase := 6;
   -- Recupera o ID da empresa a partir do CNPJ
   if nvl(est_imp_ret_rec_pc.empresa_id,0) <= 0 then
      est_imp_ret_rec_pc.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                                           , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   end if;
   --
   vn_fase := 6.1;
   --
   if nvl(est_imp_ret_rec_pc.empresa_id,0) <= 0 then
      --
      vn_fase := 6.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Empresa não encontrada ('||ev_cpf_cnpj_emit||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 7;
   -- Recupera o ID da pessoa a partir do codigo do participante
   est_imp_ret_rec_pc.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                                 , ev_cod_part   => ev_cod_part );
   --
   vn_fase := 8;
   --
   if nvl(est_imp_ret_rec_pc.pessoa_id,0) <= 0 then
      --
      vn_fase := 8.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Pessoa não encontrada - Código do participante '||ev_cod_part||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   else
      --
      vn_fase := 8.2;
      --
      vv_existe := 'N';
      --
      for r_cnpj in c_cnpj( en_cpf_cnpj => en_cnpj )
      loop
         --
         exit when c_cnpj%notfound or (c_cnpj%notfound) is null;
         --
         vn_fase := 8.3;
         --
         if nvl(r_cnpj.pessoa_id,0) = nvl(est_imp_ret_rec_pc.pessoa_id,0) then
            --
            vv_existe := 'S';
            exit;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 8.4;
      --
      if vv_existe = 'N' then
         --
         for r_cpf in c_cpf( en_cpf_cnpj => en_cnpj )
         loop
            --
            exit when c_cpf%notfound or (c_cpf%notfound) is null;
            --
            vn_fase := 8.5;
            --
            if nvl(r_cpf.pessoa_id,0) = nvl(est_imp_ret_rec_pc.pessoa_id,0) then
               --
               vv_existe := 'S';
               exit;
               --
            end if;
            --
         end loop;
         --
      end if;
      --
      vn_fase := 8.6;
      --
      if vv_existe = 'N' then
         --
         vn_fase := 8.7;
         --
         gv_resumo := null;
         --
         gv_resumo := 'CNPJ ('||en_cnpj||') informado como Fonte Pagadora Responsável ou Pessoa Jurídica Beneficiária, não pertence ao mesmo identificador '||
                      'de PESSOA informado com Código do cliente ou Código da empresa ('||ev_cod_part||').';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      end if;
      --
   end if;
   --
   vn_fase := 9;
   -- Data de retenção
   begin
      vd_data := est_imp_ret_rec_pc.dt_ret;
   exception
      when others then
         --
         vn_fase := 9.1;
         --
         gv_resumo := null;
         --
         gv_resumo := 'Data de retenção inválida como DATA.';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
   end;
   --
   vn_fase := 10;
   -- Número de controle da retenção
   if nvl(est_imp_ret_rec_pc.ident_rec,0) <= 0 then
      --
      vn_fase := 10.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Número de controle da retenção não pode ser nulo, zero ou negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 11;
   -- Indicador da natureza de retenção na fonte
   if nvl(est_imp_ret_rec_pc.dm_ind_nat_ret,0) not in (1, 2, 3, 4, 5, 99) then
      --
      vn_fase := 11.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Indicador da natureza de retenção na fonte deve ser: 1-Retenção por órgãos, autarquias e fundações federais; ou, 2-Retenção por outras '||
                   'entidades da administração pública federal; ou, 3-Retenção por pessoas jurídicas de direito privado; ou, 4-Recolhimento por sociedade '||
                   'cooperativa; ou, 5-Retenção por fabricante de máquinas e veiculos; ou, 99-Outras retenções.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 12;
   -- Valor da base de cálculo referente à retenção
   if nvl(est_imp_ret_rec_pc.vl_base_calc,0) <= 0 then
      --
      vn_fase := 12.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor da base de cálculo referente à retenção não pode ser negativo ou zero/nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 13;
   -- Valor da retenção
   if nvl(est_imp_ret_rec_pc.vl_ret,0) <= 0 then
      --
      vn_fase := 13.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor da retenção não pode ser negativo ou zero/nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 14;
   -- Indicador da natureza da receita
   if nvl(est_imp_ret_rec_pc.dm_ind_nat_rec,9) not in (0, 1) then
      --
      vn_fase := 14.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Indicador da natureza da receita deve ser: 0-Receita não cumulativa; ou, 1-Receita cumulativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 15;
   -- Valor retido de PIS
   if nvl(est_imp_ret_rec_pc.vl_ret_pis,0) <= 0 then
      --
      vn_fase := 15.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor retido de PIS não pode ser negativo ou zero/nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 16;
   -- Valor retido de COFINS
   if nvl(est_imp_ret_rec_pc.vl_ret_cofins,0) <= 0 then
      --
      vn_fase := 16.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor retido de COFINS não pode ser negativo ou zero/nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 17;
   -- Indicador da condição da pessoa declarante
   if nvl(est_imp_ret_rec_pc.dm_ind_dec,9) not in (0, 1) then
      --
      vn_fase := 17.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Indicador da natureza da receita deve ser: 0-Beneficiária da retenção; ou, 1-Responsável pela retenção.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 18;
   -- Código de receita referente à retenção ou ao recolhimento
   if est_imp_ret_rec_pc.cod_rec is null then -- Não informado
      --
      vn_fase := 18.1;
      --
      if nvl(est_imp_ret_rec_pc.dm_ind_dec,9) = 0 then
         -- No caso da pessoa jurídica beneficiária da retenção desconhecer o código de receita, o campo deve ser informado em branco
         vn_fase := 18.2;
         null;
         --
      else -- nvl(est_imp_ret_rec_pc.dm_ind_dec,9) = 1
         --
         vn_fase := 18.3;
         --
         gv_resumo := null;
         --
         gv_resumo := 'Código de receita referente à retenção ou ao recolhimento não pode ser nulo, devido ao Indicador da natureza da receita ser '||
                      '1-Responsável pela retenção.';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      end if;
      --
   else -- est_imp_ret_rec_pc.cod_rec is not null -- Informado
      --
      vn_fase := 18.4;
      --
      if nvl(est_imp_ret_rec_pc.dm_ind_dec,9) = 0 then
         --
         vn_fase := 18.5;
         --
         gv_resumo := null;
         --
         gv_resumo := 'Código de receita referente à retenção ou ao recolhimento deve ser nulo, devido ao Indicador da natureza da receita ser '||
                      '0-Beneficiária da retenção.';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      else -- nvl(est_imp_ret_rec_pc.dm_ind_dec,9) = 1
         -- Código informado e indicador de natureza responsável pela retenção
         vn_fase := 18.6;
         null;
         --
      end if;
      --
   end if;
   --
   vn_fase := 19;
   -- Tipo de manipulação: 1-Integrado; 2-Integrado/Alterado; 3-Digitado; 4-Digitado/Alterado
   est_imp_ret_rec_pc.dm_tipo := 1;
   --
   vn_fase := 20;
   -- Verifica se o registro está com erro de validação: 0-Não Validado, 1-Validado, 2-Erro de validação
   if nvl(est_log_generico_pir.count,0) > 0 then
      --
      est_imp_ret_rec_pc.dm_st_proc := 2; -- Erro de validação
      --
   else
      --
      est_imp_ret_rec_pc.dm_st_proc := 1; -- Validado
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_imp_ret_rec_pc.empresa_id,0) > 0 and
      nvl(est_imp_ret_rec_pc.pessoa_id,0) > 0 and
      est_imp_ret_rec_pc.dt_ret is not null and
      nvl(est_imp_ret_rec_pc.ident_rec,0) > 0 and
      nvl(est_imp_ret_rec_pc.dm_ind_nat_ret,0) in (1, 2, 3, 4, 5, 99) and
      nvl(est_imp_ret_rec_pc.vl_base_calc,0) > 0 and
      nvl(est_imp_ret_rec_pc.vl_ret,0) > 0 and
      nvl(est_imp_ret_rec_pc.dm_ind_nat_rec,9) in (0, 1) and
      nvl(est_imp_ret_rec_pc.vl_ret_pis,0) > 0 and
      nvl(est_imp_ret_rec_pc.vl_ret_cofins,0) > 0 and
      nvl(est_imp_ret_rec_pc.dm_ind_dec,9) in (0, 1) and
      ((est_imp_ret_rec_pc.cod_rec is null and nvl(est_imp_ret_rec_pc.dm_ind_dec,9) = 0) or
       (est_imp_ret_rec_pc.cod_rec is not null and nvl(est_imp_ret_rec_pc.dm_ind_dec,9) = 1)) then
      --
      vn_fase := 99.1;
      --
      -- Cálcula a quantidade de registros Totais integrados, com sucesso e com erro para serem
      -- mostrados na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if pk_csf_pgto_imp_ret.fkg_existe_imp_ret_rec_pc(en_impretrecpc_id => est_imp_ret_rec_pc.id ) = true then
         --
         vn_fase := 99.2;
         --
         begin
            --
            update imp_ret_rec_pc ir
               set ir.empresa_id      =  est_imp_ret_rec_pc.empresa_id
                 , ir.pessoa_id       =  est_imp_ret_rec_pc.pessoa_id
                 , ir.dm_st_proc      =  est_imp_ret_rec_pc.dm_st_proc
                 , ir.dm_tipo         =  est_imp_ret_rec_pc.dm_tipo
                 , ir.dt_ret          =  est_imp_ret_rec_pc.dt_ret
                 , ir.ident_rec       =  est_imp_ret_rec_pc.ident_rec
                 , ir.dm_ind_nat_ret  =  est_imp_ret_rec_pc.dm_ind_nat_ret
                 , ir.vl_base_calc    =  est_imp_ret_rec_pc.vl_base_calc
                 , ir.vl_ret          =  est_imp_ret_rec_pc.vl_ret
                 , ir.cod_rec         =  est_imp_ret_rec_pc.cod_rec
                 , ir.dm_ind_nat_rec  =  est_imp_ret_rec_pc.dm_ind_nat_rec
                 , ir.vl_ret_pis      =  est_imp_ret_rec_pc.vl_ret_pis
                 , ir.vl_ret_cofins   =  est_imp_ret_rec_pc.vl_ret_cofins
                 , ir.dm_ind_dec      =  est_imp_ret_rec_pc.dm_ind_dec
            where ir.id = est_imp_ret_rec_pc.id;
            --
         exception
          when others then
            --
            gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec_pc fase('||vn_fase||'): '||sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_pir.id%TYPE;
            begin
               --
               pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                    , ev_mensagem          => gv_mensagem
                                    , ev_resumo            => gv_resumo
                                    , en_tipo_log          => ERRO_DE_SISTEMA
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                       , est_log_generico_pir => est_log_generico_pir );
               --
            exception
             when others then
               null;
            end;
            --
            null;
            --
         end;
         --
      else
         --
         vn_fase := 99.3;
         --
         begin
            --
            insert into imp_ret_rec_pc ( id
                                       , empresa_id
                                       , pessoa_id
                                       , dm_st_proc
                                       , dm_tipo
                                       , dt_ret
                                       , ident_rec
                                       , dm_ind_nat_ret
                                       , vl_base_calc
                                       , vl_ret
                                       , cod_rec
                                       , dm_ind_nat_rec
                                       , vl_ret_pis
                                       , vl_ret_cofins
                                       , dm_ind_dec
                                       )
                                values ( est_imp_ret_rec_pc.id
                                       , est_imp_ret_rec_pc.empresa_id
                                       , est_imp_ret_rec_pc.pessoa_id
                                       , est_imp_ret_rec_pc.dm_st_proc
                                       , est_imp_ret_rec_pc.dm_tipo
                                       , est_imp_ret_rec_pc.dt_ret
                                       , est_imp_ret_rec_pc.ident_rec
                                       , est_imp_ret_rec_pc.dm_ind_nat_ret
                                       , est_imp_ret_rec_pc.vl_base_calc
                                       , est_imp_ret_rec_pc.vl_ret
                                       , est_imp_ret_rec_pc.cod_rec
                                       , est_imp_ret_rec_pc.dm_ind_nat_rec
                                       , est_imp_ret_rec_pc.vl_ret_pis
                                       , est_imp_ret_rec_pc.vl_ret_cofins
                                       , est_imp_ret_rec_pc.dm_ind_dec
                                       );   
            --
         exception
          when others then
            --
            gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec_pc fase('||vn_fase||'): '||sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_pir.id%TYPE;
            begin
               --
               pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                    , ev_mensagem          => gv_mensagem
                                    , ev_resumo            => gv_resumo
                                    , en_tipo_log          => ERRO_DE_SISTEMA
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                       , est_log_generico_pir => est_log_generico_pir );
               --
            exception
             when others then
               null;
            end;
            --
            null;
            --
         end;
         --
      end if;
      --
   else
      --
      vn_fase := 99.4;
      --
      if pk_csf_pgto_imp_ret.fkg_existe_imp_ret_rec_pc(en_impretrecpc_id => est_imp_ret_rec_pc.id ) = true then
         --
         vn_fase := 99.5;
         --
         update imp_ret_rec_pc ir
            set ir.dm_st_proc = est_imp_ret_rec_pc.dm_st_proc
          where ir.id = est_imp_ret_rec_pc.id;
         --
      end if;
      --
   end if;
   --
   vn_fase := 99.6;
   --
   commit;
   --
exception
   when others then
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_imp_ret_rec_pc fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => ERRO_DE_SISTEMA
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_imp_ret_rec_pc;
-------------------------------------------------------------------------------------
-- Procedimento de integração dos dados de Pagamento de Impostos no padrão para DCTF
-------------------------------------------------------------------------------------
procedure pkb_integr_pgto_imp_ret ( est_log_generico_pir  in out nocopy  dbms_sql.number_table
                                  , est_pgto_imp_ret  in out nocopy  pgto_imp_ret%rowtype
                                  , ev_cpf_cnpj_emit  in             varchar2
                                  , ev_cod_part       in             varchar2
                                  , en_cd_imp         in             tipo_imposto.cd%type
                                  , en_cd_ret_imp     in             tipo_ret_imp.cd%type
                                  , ev_cod_receita    in             tipo_ret_imp_receita.cod_receita%type
                                  , en_multorg_id     in             mult_org.id%type
                                  , en_loteintws_id   in             lote_int_ws.id%type default 0
                                  )
is
   --
   vn_fase                  number := 0;
   vn_loggenerico_id        log_generico_pir.id%type;
   vn_tipoimp_id            number;
   vn_tiporetimp_id         number;
   vn_tiporetimpreceita_id  number;
   vv_nro_lote              varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   -- Montagem o cabeçalho da mensagem de log
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_mensagem := 'Empresa: ' || ev_cpf_cnpj_emit || ' Numero do documento: ' || est_pgto_imp_ret.nro_doc || ' Data de vencimento: ' || est_pgto_imp_ret.dt_vcto || vv_nro_lote;
   --
   gv_obj_referencia := 'PGTO_IMP_RET';
   --
   vn_fase := 2;
   -- Recupera o ID da empresa a partir do CNPJ
   if nvl(est_pgto_imp_ret.empresa_id,0) <= 0 then
      est_pgto_imp_ret.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                                         , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   end if;
   --
   vn_fase := 2.1;
   --
   -- Recupera o ID da pessoa a partir do codigo do participante
   est_pgto_imp_ret.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                               , ev_cod_part   => ev_cod_part );
   --
   vn_fase := 2.2;
   --
   -- Recupera o ID do tipo do imposto a partir do codigo.
   vn_tipoimp_id := pk_csf.fkg_Tipo_Imposto_id ( en_cd => en_cd_imp );
   --
   vn_fase := 2.3;
   --
   -- Recupera o ID do tipo de retenção do imposto a partir do codigo.
   vn_tiporetimp_id := pk_csf.fkg_tipo_ret_imp ( en_multorg_id => en_multorg_id
                                               , en_cd_ret     => en_cd_ret_imp
                                               , en_tipoimp_id => vn_tipoimp_id
                                               );
   --
   vn_fase := 2.4;
   --
   if nvl(est_pgto_imp_ret.id,0) <= 0 then
      --
      -- Recupera o ID do Pagamento de Impostos no padrão para DCTF
      est_pgto_imp_ret.id := pk_csf_pgto_imp_ret.fkg_pgto_imp_ret_id ( en_empresa_id    => est_pgto_imp_ret.empresa_id
                                                                     , en_pessoa_id     => est_pgto_imp_ret.pessoa_id
                                                                     , ev_nro_doc       => est_pgto_imp_ret.nro_doc
                                                                     , ed_dt_vcto       => est_pgto_imp_ret.dt_vcto
                                                                     , ed_dt_pgto       => est_pgto_imp_ret.dt_pgto
                                                                     , en_tipoimp_id    => vn_tipoimp_id -- est_pgto_imp_ret.tipoimp_id
                                                                     , en_tiporetimp_id => vn_tiporetimp_id -- est_pgto_imp_ret.tiporetimp_id
                                                                     );
      --
      vn_fase := 2.5;
      --
      if nvl(est_pgto_imp_ret.id,0) <= 0 then
         --
         select pgtoimpret_seq.nextval
           into est_pgto_imp_ret.id
           from dual;
         --
      end if;
      --
   end if;
   --
   vn_fase := 2.6;
   --
   gn_referencia_id := est_pgto_imp_ret.id;
   --
   if nvl(est_pgto_imp_ret.empresa_id,0) <= 0 then
      --
      vn_fase := 2.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Empresa não encontrada (' || ev_cpf_cnpj_emit || ')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_pgto_imp_ret.pessoa_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Pessoa não encontrada (' || ev_cod_part || ')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(vn_tipoimp_id,0) <= 0 then
      --
      vn_fase := 4.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Código do tipo de imposto inválido (' || en_cd_imp || ')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   else
      est_pgto_imp_ret.tipoimp_id := vn_tipoimp_id;
   end if;
   --
   vn_fase := 5;
   --
   if nvl(vn_tiporetimp_id,0) <= 0 then
      --
      vn_fase := 5.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Código do tipo de retenção do imposto inválido (' || en_cd_ret_imp || ')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   else
      est_pgto_imp_ret.tiporetimp_id := vn_tiporetimp_id;
   end if;
   --
   --
   --| Valida os dados do Pagamento de Impostos no padrão para DCTF
   --
   vn_fase := 8;
   -- Número do documento:
   if est_pgto_imp_ret.nro_doc is null then
      --
      vn_fase := 8.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Número do documento não pode ser nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 9;
   -- Data de vencimento:
   if est_pgto_imp_ret.dt_vcto is null then
      --
      vn_fase := 9.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Data de vencimento não pode ser nula.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 10;
   -- Data de Pagamento:
   if est_pgto_imp_ret.dt_pgto is null then
      --
      vn_fase := 10.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Data de Pagamento não pode ser nula.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 11;
   -- Valor da base de cálculo:
   est_pgto_imp_ret.vl_base_calc := nvl(est_pgto_imp_ret.vl_base_calc,0);
   --
   vn_fase := 11.1;
   --
   if est_pgto_imp_ret.vl_base_calc < 0 then
      --
      vn_fase := 11.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor da base de cálculo não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 12;
   -- Alíquota aplicada ao imposto:
   est_pgto_imp_ret.aliq := nvl(est_pgto_imp_ret.aliq,0);
   --
   vn_fase := 12.1;
   --
   if est_pgto_imp_ret.aliq < 0 then
      --
      vn_fase := 12.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Alíquota aplicada ao imposto não pode ser negativa.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 13;
   -- Valor principal do imposto retido a ser pago:
   est_pgto_imp_ret.vl_principal := nvl(est_pgto_imp_ret.vl_principal,0);
   --
   vn_fase := 13.1;
   --
   if est_pgto_imp_ret.vl_principal < 0 then
      --
      vn_fase := 13.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor principal do imposto retido a ser pago não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 14;
   -- Valor da multa paga
   if nvl(est_pgto_imp_ret.vl_multa,0) < 0 then
      --
      vn_fase := 14.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor da multa paga não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 15;
   -- Valor dos juros pagos
   if nvl(est_pgto_imp_ret.vl_juros,0) < 0 then
      --
      vn_fase := 15.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor dos juros pagos não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 16;
   -- Valor do pagamento realizado:
   est_pgto_imp_ret.vl_pgto := nvl(est_pgto_imp_ret.vl_pgto,0);
   --
   vn_fase := 16.1;
   --
   if est_pgto_imp_ret.vl_pgto < 0 then
      --
      vn_fase := 16.2;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor do pagamento realizado não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 17;
   -- Valor da Dedução do Imposto
   if nvl(est_pgto_imp_ret.vl_deducao,0) < 0 then
      --
      vn_fase := 17.1;
      --
      gv_resumo := null;
      --
      gv_resumo := 'Valor da Dedução do Imposto não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 18;
   --
   if ev_cod_receita is null or
      nvl(est_pgto_imp_ret.tiporetimp_id,0) = 0 then
      --
      vn_fase := 18.1;
      est_pgto_imp_ret.tiporetimpreceita_id := null;
      --
   else
      --
      vn_fase := 18.2;
      vn_tiporetimpreceita_id := pk_csf_dctf.fkg_retorna_id_tiporetimprec ( en_tiporetimp_id        => est_pgto_imp_ret.tiporetimp_id
                                                                          , ev_tiporetimpreceita_cd => ev_cod_receita
                                                                          );
      --
      vn_fase := 18.3;
      --
      if nvl(vn_tiporetimpreceita_id,0) = 0 then
         --
         vn_fase := 18.4;
         est_pgto_imp_ret.tiporetimpreceita_id := null;
         --
      else
         est_pgto_imp_ret.tiporetimpreceita_id := vn_tiporetimpreceita_id;
      end if;
      --
   end if;
   --
   vn_fase := 19;
   -- Verifica se o registro está com erro de validação
   if nvl(est_log_generico_pir.count,0) > 0 then
      --
      est_pgto_imp_ret.dm_situacao := 2; -- Erro de validação
      est_pgto_imp_ret.dm_envio    := 0; -- Não enviado
      --
      gv_resumo := 'Registro com Erro de validação.';
      --
   else
      --
      est_pgto_imp_ret.dm_situacao := 1; -- Validado
      est_pgto_imp_ret.dm_envio    := 0; -- Não enviado
      --
      gv_resumo := 'Registro validado.';
      --
   end if;
   --
   vn_fase := 19.1;
   --
   pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                        , ev_mensagem          => gv_resumo
                        , ev_resumo            => gv_resumo
                        , en_tipo_log          => INFORMACAO
                        , en_referencia_id     => gn_referencia_id
                        , ev_obj_referencia    => gv_obj_referencia
                        );
   --
   vn_fase := 99;
   --
   if nvl(est_pgto_imp_ret.empresa_id,0) > 0
      and nvl(est_pgto_imp_ret.pessoa_id,0) > 0
      and est_pgto_imp_ret.nro_doc is not null
      and est_pgto_imp_ret.dt_vcto is not null
      and est_pgto_imp_ret.dt_pgto is not null
      and nvl(est_pgto_imp_ret.tipoimp_id,0) > 0
      and nvl(est_pgto_imp_ret.tiporetimp_id,0) > 0
      then
      --
      vn_fase := 99.1;
      --
      -- Cálcula a quantidade de registros Totais integrados, com sucesso e com erro para serem
      -- mostrados na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
         null;
      end;
      --
      if est_pgto_imp_ret.dm_situacao = 1 then -- Validado
         --
         begin
            pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
         exception
            when others then
            null;
         end;
         --
      elsif est_pgto_imp_ret.dm_situacao = 2 then -- Erro de validação
         --
         begin
            pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
         exception
            when others then
            null;
         end;
         --
      end if;
      --
      if pk_csf_pgto_imp_ret.fkg_existe_pgto_imp_ret ( en_pgtoimpret_id => est_pgto_imp_ret.id ) = true then
         --
         vn_fase := 99.2;
         --
         begin
            --
            update pgto_imp_ret set empresa_id            =  est_pgto_imp_ret.empresa_id
                                  , pessoa_id             =  est_pgto_imp_ret.pessoa_id
                                  , nro_doc               =  est_pgto_imp_ret.nro_doc
                                  , dt_vcto               =  est_pgto_imp_ret.dt_vcto
                                  , dt_pgto               =  est_pgto_imp_ret.dt_pgto
                                  , tipoimp_id            =  est_pgto_imp_ret.tipoimp_id
                                  , tiporetimp_id         =  est_pgto_imp_ret.tiporetimp_id
                                  , vl_base_calc          =  est_pgto_imp_ret.vl_base_calc
                                  , aliq                  =  est_pgto_imp_ret.aliq
                                  , vl_principal          =  est_pgto_imp_ret.vl_principal
                                  , vl_multa              =  est_pgto_imp_ret.vl_multa
                                  , vl_juros              =  est_pgto_imp_ret.vl_juros
                                  , vl_pgto               =  est_pgto_imp_ret.vl_pgto
                                  , perdcomp              =  est_pgto_imp_ret.perdcomp
                                  , vl_deducao            =  est_pgto_imp_ret.vl_deducao
                                  , dm_situacao           =  est_pgto_imp_ret.dm_situacao
                                  , dt_docto              =  est_pgto_imp_ret.dt_docto
                                  , tiporetimpreceita_id  =  est_pgto_imp_ret.tiporetimpreceita_id
            where id = est_pgto_imp_ret.id;
            --
         exception
          when others then
            --
            gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pgto_imp_ret fase('||vn_fase||'): '||sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_pir.id%TYPE;
            begin
              --
              pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                   , ev_mensagem          => gv_mensagem
                                   , ev_resumo            => gv_resumo
                                   , en_tipo_log          => ERRO_DE_SISTEMA
                                   , en_referencia_id     => gn_referencia_id
                                   , ev_obj_referencia    => gv_obj_referencia );
              --
              -- Armazena o "loggenerico_id" na memória
              pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                      , est_log_generico_pir => est_log_generico_pir );
              --
            exception
              when others then
               null;
            end;
            --
            null;
            --
         end;
         --
      else
         --
         vn_fase := 99.3;
         --
         begin
            --
            insert into pgto_imp_ret ( id
                                     , empresa_id
                                     , pessoa_id
                                     , nro_doc
                                     , dt_vcto
                                     , dt_pgto
                                     , tipoimp_id
                                     , tiporetimp_id
                                     , vl_base_calc
                                     , aliq
                                     , vl_principal
                                     , vl_multa
                                     , vl_juros
                                     , vl_pgto
                                     , perdcomp
                                     , vl_deducao
                                     , dm_situacao
                                     , dt_docto
                                     , tiporetimpreceita_id
                                     )
                              values ( est_pgto_imp_ret.id
                                     , est_pgto_imp_ret.empresa_id
                                     , est_pgto_imp_ret.pessoa_id
                                     , est_pgto_imp_ret.nro_doc
                                     , est_pgto_imp_ret.dt_vcto
                                     , est_pgto_imp_ret.dt_pgto
                                     , est_pgto_imp_ret.tipoimp_id
                                     , est_pgto_imp_ret.tiporetimp_id
                                     , est_pgto_imp_ret.vl_base_calc
                                     , est_pgto_imp_ret.aliq
                                     , est_pgto_imp_ret.vl_principal
                                     , est_pgto_imp_ret.vl_multa
                                     , est_pgto_imp_ret.vl_juros
                                     , est_pgto_imp_ret.vl_pgto
                                     , est_pgto_imp_ret.perdcomp
                                     , est_pgto_imp_ret.vl_deducao
                                     , est_pgto_imp_ret.dm_situacao
                                     , est_pgto_imp_ret.dt_docto
                                     , est_pgto_imp_ret.tiporetimpreceita_id
                                     );
            --
         exception
          when others then
            --
            gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pgto_imp_ret fase('||vn_fase||'): '||sqlerrm;
            --
            declare
               vn_loggenerico_id  log_generico_pir.id%TYPE;
            begin
              --
              pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                   , ev_mensagem          => gv_mensagem
                                   , ev_resumo            => gv_resumo
                                   , en_tipo_log          => ERRO_DE_SISTEMA
                                   , en_referencia_id     => gn_referencia_id
                                   , ev_obj_referencia    => gv_obj_referencia );
              --
              -- Armazena o "loggenerico_id" na memória
              pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                      , est_log_generico_pir => est_log_generico_pir );
              --
            exception
              when others then
               null;
            end;
            --
            null;
            --
         end;
         --
      end if;
      --
      vn_fase := 99.4;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pgto_imp_ret fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => ERRO_DE_SISTEMA
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo);
      --
end pkb_integr_pgto_imp_ret;

---------------------------------------------------------------------------------------------
-- Procedimento de integração dos dados de Pagamento de Impostos no padrão para DCTF - Flex-Field
---------------------------------------------------------------------------------------------

procedure pkb_integr_pgto_imp_ret_ff ( est_log_generico_pir   in out nocopy  dbms_sql.number_table
                                     , en_pgtoimpret_id       in             pgto_imp_ret.id%type
                                     , ev_atributo            in             varchar2
                                     , ev_valor               in             varchar2 )
is
   --
   vn_fase                 number := 0;
   vn_loggenericopir_id    log_generico_pir.id%type;
   vn_dmtipocampo          ff_obj_util_integr.dm_tipo_campo%type;
   vv_mensagem             varchar2(1000) := null;
   vv_dm_ind_susp_exig     pgto_imp_ret.dm_ind_susp_exig%type;
   vv_dm_ind_dec_terc      pgto_imp_ret.dm_ind_dec_terceiro%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem := null;
   --
   if ev_atributo is null then
      --
      vn_fase := 2;
      --
      gv_mensagem := 'Informações de pagamento de impostos retidos do exterior: "Atributo" deve ser informado.';
      --
      vn_loggenericopir_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_mensagem
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 3;
   --
   if ev_valor is null then
      --
      vn_fase := 3.1;
      --
      gv_mensagem := 'Informações de pagamento de impostos retidos do exterior: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenericopir_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_mensagem
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos ( ev_obj_name => 'VW_CSF_PGTO_IMP_RET_FF'
                                             , ev_atributo => ev_atributo
                                             , ev_valor    => ev_valor );
   --
   vn_fase := 4.1;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 4.2;
      --
      gv_mensagem := vv_mensagem;
      --
      vn_loggenericopir_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_mensagem
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                              , est_log_generico_pir => est_log_generico_pir );
      --
   else
      --
      vn_fase := 5;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo ( ev_obj_name => 'VW_CSF_PGTO_IMP_RET_FF'
                                                          , ev_atributo => ev_atributo );
      --
      vn_fase := 6;
      --
      if ev_atributo = 'DM_IND_SUSP_EXIG' and ev_valor is not null then
         --
         vn_fase := 7;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = caractere
            --
            vn_fase := 8;
            --
            vv_dm_ind_susp_exig := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_PGTO_IMP_RET_FF'
                                                                  , ev_atributo => ev_atributo
                                                                  , ev_valor    => ev_valor );
            --
            if vv_dm_ind_susp_exig is null then
               --
               vn_fase := 9;
               --
               gv_mensagem := 'Valor do indicativo de exigibilidade suspensa ('||ev_valor||') não pode ser nulo.';
               --
               vn_loggenericopir_id := null;
               --
               pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                                    , ev_mensagem          => gv_mensagem
                                    , ev_resumo            => gv_mensagem
                                    , en_tipo_log          => erro_de_validacao
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                       , est_log_generico_pir => est_log_generico_pir );
               --
            end if;
            --
         else
            --
            vn_fase := 10;
            --
            gv_mensagem := 'Para o atributo VV_DM_IND_SUSP_EXIG, o VALOR informado não confere com o tipo de campo, deveria ser Caractere.';
            --
            vn_loggenericopir_id := null;
            --
            pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                                 , ev_mensagem          => gv_mensagem
                                 , ev_resumo            => gv_mensagem
                                 , en_tipo_log          => erro_de_validacao
                                 , en_referencia_id     => gn_referencia_id
                                 , ev_obj_referencia    => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                    , est_log_generico_pir => est_log_generico_pir );
            --
         end if;
         --
      elsif ev_atributo = 'DM_IND_DEC_TERCEIRO' and ev_valor is not null then
         --
         vn_fase := 11;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = caractere
            --
            vn_fase := 12;
            --
            vv_dm_ind_dec_terc := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_PGTO_IMP_RET_FF'
                                                                 , ev_atributo => ev_atributo
                                                                 , ev_valor    => ev_valor );
            --
            vn_fase := 13;
            --
            if vv_dm_ind_dec_terc is null then
               --
               vn_fase := 14;
               --
               gv_mensagem := 'Valor do indicativo do décimo terceiro salário ('||ev_valor||') não pode ser nulo.';
               --
               vn_loggenericopir_id := null;
               --
               pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                                    , ev_mensagem          => gv_mensagem
                                    , ev_resumo            => gv_mensagem
                                    , en_tipo_log          => erro_de_validacao
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                       , est_log_generico_pir => est_log_generico_pir );
               --
            end if;
            --
         else
            --
            vn_fase := 15;
            --
            gv_mensagem := 'Para o atributo VV_DM_IND_DEC_TERC, o VALOR informado não confere com o tipo de campo, deveria ser Caractere.';
            --
            vn_loggenericopir_id := null;
            --
            pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                                 , ev_mensagem          => gv_mensagem
                                 , ev_resumo            => gv_mensagem
                                 , en_tipo_log          => erro_de_validacao
                                 , en_referencia_id     => gn_referencia_id
                                 , ev_obj_referencia    => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                    , est_log_generico_pir => est_log_generico_pir );
            --
         end if;
         --
      else
         --
         vn_fase := 16;
         --
         gv_mensagem := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
         --
         vn_loggenericopir_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      end if;
      --
   end if;
   --
   vn_fase := 99;
   -- Verifica se o registro está com erro de validação
   if nvl(est_log_generico_pir.count,0) > 0 then
      --
      vn_fase := 99.1;
      --
      update pgto_imp_ret 
         set dm_situacao = 2
       where id = en_pgtoimpret_id;
      --
   end if;
   --
   vn_fase := 99.2;
   --
   if nvl(en_pgtoimpret_id,0) > 0 and
      ev_atributo = 'DM_IND_SUSP_EXIG' and
      vv_dm_ind_susp_exig is not null and
      gv_mensagem is null then
      --
      vn_fase := 99.3;
      --
      update pgto_imp_ret pi
         set pi.dm_ind_susp_exig = vv_dm_ind_susp_exig
       where pi.id               = en_pgtoimpret_id;
      --
   end if;
   --
   vn_fase := 99.4;
   --
   if nvl(en_pgtoimpret_id,0) > 0 and
      ev_atributo = 'DM_IND_DEC_TERCEIRO' and
      vv_dm_ind_dec_terc is not null and
      gv_mensagem is null then
      --
      vn_fase := 99.5;
      --
      update pgto_imp_ret pi
         set pi.dm_ind_dec_terceiro = vv_dm_ind_dec_terc
       where pi.id                  = en_pgtoimpret_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_pgto_imp_ret.pkb_integr_pgto_imp_ret_ff fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenericopir_id  log_generico_pir.id%TYPE;
      begin
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenericopir_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenericopir_id
                                 , est_log_generico_pir => est_log_generico_pir );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_pgto_imp_ret_ff;
------------------------------------------------------------------------------------------

procedure pkb_ret_multorg_id( est_log_generico       in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org        in             mult_org.cd%type
                            , ev_hash_mult_org       in             mult_org.hash%type
                            , sn_multorg_id          in out nocopy  mult_org.id%type
                            , en_referencia_id       in             log_generico_pir.referencia_id%type  default null
                            , ev_obj_referencia      in             log_generico_pir.obj_referencia%type default null
                            )
is
   vn_fase               number := 0;
   vv_multorg_hash       mult_org.hash%type;
   vn_multorg_id         mult_org.id%type;
   vn_loggenerico_id     log_generico_pir.id%type;
   vn_dm_obrig_integr    mult_org.dm_obrig_integr%type;

begin
   --
   vn_fase := 1;
   --
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   begin
      --
      select mo.hash, mo.id, mo.dm_obrig_integr
        into vv_multorg_hash, vn_multorg_id, vn_dm_obrig_integr
        from mult_org mo
       where mo.cd = ev_cod_mult_org;
      --
      vn_fase := 2;
      --
   exception
      when no_data_found then
         --
         vn_fase := 3;
         --
         vv_multorg_hash := null;
         --
         vn_multorg_id := 0;
         --
      when others then
         --
         vn_fase := 4;
         --
         vv_multorg_hash := null;
         --
         vn_multorg_id := 0;
         --
         gv_mensagem := 'Problema ao tentar buscar o Mult Org. Fase: '||vn_fase;
         gv_resumo :=  'Codigo do MultOrg: |' || ev_cod_mult_org || '| Hash do MultOrg: |'||ev_hash_mult_org||'|';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => ERRO_DE_VALIDACAO
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico );
   --
   end;
   --
   vn_fase := 5;
   --
   if nvl(vn_multorg_id, 0) = 0 then

      gv_mensagem := 'O Mult Org de codigo: |' || ev_cod_mult_org || '| não existe.';
      --
      vn_loggenerico_id := null;
      --
      vn_fase := 5.1;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 5.2;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => INFORMACAO
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 5.3;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => ERRO_DE_VALIDACAO
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico );
         --
      end if;
      --
   elsif vv_multorg_hash != ev_hash_mult_org then
      --
      vn_fase := 6;
      --
      gv_mensagem := 'O valor do Hash ('|| ev_hash_mult_org ||') do Mult Org:'|| ev_cod_mult_org ||'esta incorreto.';
      --
      vn_loggenerico_id := null;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 6.1;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => INFORMACAO
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 6.2;
         --
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_mensagem
                              , en_tipo_log          => ERRO_DE_VALIDACAO
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico );
         --
      end if;
      --
   end if;
   --
   vn_fase := 7;
   --
   sn_multorg_id := vn_multorg_id;

exception
   when others then
      raise_application_error (-20101, 'Problemas ao validar Mult Org - pk_csf_api_pgto_imp_ret.pkb_ret_multorg_id. Fase: '||vn_fase||' Erro = '||sqlerrm);
end pkb_ret_multorg_id;

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
                                )


is
   --
   vn_fase             number := 0;
   vn_loggenerico_id   log_generico_pir.id%type;
   vv_mensagem         varchar2(1000) := null;
   vn_dmtipocampo      ff_obj_util_integr.dm_tipo_campo%type;
   vv_hash_mult_org    mult_org.hash%type;
   vv_cod_mult_org     mult_org.cd%type;
  --
begin
 --
   vn_fase := 1;
   --
   gv_mensagem := null;
   --
   gn_referencia_id   := en_referencia_id;
   gv_obj_referencia  := ev_obj_referencia;
   --
   vn_fase := 2;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 3;
      --
      gv_mensagem := 'Código ou HASH da Mult-Organização (objeto: '|| ev_obj_name ||'):"VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico );
      --
   end if;
   --
   vn_fase := 4;
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => ev_obj_name
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 5;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 6;
      --
      gv_mensagem := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem
                           , ev_resumo            => gv_resumo
                           , en_tipo_log          => ERRO_DE_VALIDACAO
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                              , est_log_generico_pir => est_log_generico );
      --
   else
       --
      vn_fase := 7;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => ev_obj_name
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 8;
      --
      if trim(ev_valor) is not null then
         --
         vn_fase := 9;
         --
         if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-numérico, 2-caractere
            --
            vn_fase := 10;
            --
            if trim(ev_atributo) = 'COD_MULT_ORG' then
                --
                vn_fase := 11;
                --
                begin
                   vv_cod_mult_org := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                    , ev_atributo => trim(ev_atributo)
                                                                    , ev_valor    => trim(ev_valor) );
                exception
                   when others then
                      vv_cod_mult_org := null;
                end;
                --
            elsif trim(ev_atributo) = 'HASH_MULT_ORG' then
               --
                vn_fase := 12;
                --
                begin
                   vv_hash_mult_org := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => ev_obj_name
                                                                     , ev_atributo => trim(ev_atributo)
                                                                     , ev_valor    => trim(ev_valor) );
                exception
                   when others then
                      vv_hash_mult_org := null;
                end;
                --
            end if;
            --
         else
            --
            vn_fase := 13;
            --
            gv_mensagem := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                                 , ev_mensagem          => gv_mensagem
                                 , ev_resumo            => gv_resumo
                                 , en_tipo_log          => ERRO_DE_VALIDACAO
                                 , en_referencia_id     => gn_referencia_id
                                 , ev_obj_referencia    => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                    , est_log_generico_pir => est_log_generico );
            --
         end if;
         --
      end if;
      --
   end if;
   --
   vn_fase := 14;
   --
   sv_cod_mult_org := vv_cod_mult_org;
   --
   sv_hash_mult_org := vv_hash_mult_org;
--
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_pgto_imp_ret.pkb_val_atrib_multorg fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico );
      exception
         when others then
            null;
      end;
end pkb_val_atrib_multorg;

-------------------------------------------------------------------------------------------------------

-- Procedure para Finalizar o processo de geração de Guia de Pagamento pela tela de Geração do PIS/COFINS

procedure pkb_finaliza_pgto_imp_ret ( est_log_generico    in out nocopy  dbms_sql.number_table
                                    , en_empresa_id       in empresa.id%type
                                    , en_dt_ini           in date
                                    , en_dt_fim           in date 
                                    , ev_cod_rec_cd_compl in guia_pgto_imp_compl_gen.cod_receita%type
                                    , sn_guiapgtoimp_id  out guia_pgto_imp.id%type)
is
   -- Regra de entrada de parâmetros
   -- Informar apenas en_aberturaefdpc_id ou infromar apenas en_empresa_id, en_dt_ini, en_dt_fim
   vn_fase              number := 0;
   vn_guiapgtoimp_id    guia_pgto_imp.id%type;
   vt_csf_log_generico  dbms_sql.number_table;
begin
   --
   vn_fase := 1;
   --
   -- seta o tipo de integração que será feito
   -- 0 - Válida e Atualiza os dados
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele   
   pk_csf_api_gpi.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
   --   
   vn_fase := 2;
   --
   -- Chama o Processo de Integração 
   pk_csf_api_gpi.pkb_integr_guia_pgto_imp( est_log_generico_gpi  => vt_csf_log_generico
                                           ,est_row_guia_pgto_imp => pk_csf_api_gpi.gt_row_guia_pgto_imp 
                                           ,en_empresa_id         => en_empresa_id
                                           ,en_multorg_id         => pk_csf.fkg_multorg_id_empresa(en_empresa_id)
                                           ,ev_cod_part           => pk_csf.fkg_pessoa_cod_part (pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id)
                                           ,en_tipimp_cd          => pk_csf.fkg_Tipo_Imposto_cd (pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id)
                                           ,ev_tiporetimp_cd      => pk_csf.fkg_tipo_ret_imp_cd (pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id)
                                           ,ev_cod_rec_cd         => pk_csf_gpi.fkg_tiporetimpreceita_cd (pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id)
                                           ,ev_cod_rec_cd_compl   => ev_cod_rec_cd_compl
                                           ,sn_guiapgtoimp_id     => vn_guiapgtoimp_id);
   --
   sn_guiapgtoimp_id := vn_guiapgtoimp_id;
   --
   if nvl(vt_csf_log_generico.count,0) > 0 then
      --
      update PGTO_IMP_RET
         set dm_situacao    = 2 -- Erro de validação
       where guiapgtoimp_id = vn_guiapgtoimp_id;
      --
   else
      --
      update PGTO_IMP_RET
         set dm_situacao    = 3 -- Processo Finalizado
       where guiapgtoimp_id = vn_guiapgtoimp_id;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_pgto_imp_ret.pkb_finaliza_pgto_imp_ret fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico );
      exception
         when others then
            null;
      end;
      --
end pkb_finaliza_pgto_imp_ret;
--
-------------------------------------------------------------------------------------------------------

-- Procedure para Estornar o processo de geração de Guia de Pagamento pela tela de Geração do PIS/COFINS
procedure pkb_estorna_pgto_imp_ret ( est_log_generico    in out nocopy  dbms_sql.number_table
                                   , en_empresa_id       in empresa.id%type
                                   , en_dt_ini           in date
                                   , en_dt_fim           in date  
                                   , en_pgtoimpret_id    in PGTO_IMP_RET.id%type default null)
is
   vn_fase              number := 0;
   vt_csf_log_generico  dbms_sql.number_table;
begin
  --
  vn_fase := 1;
  --
  -- Varre as Guias de Pagamento RETIDOS a serem estornadas 
   for x in (select p.guiapgtoimp_id, p.id pgtoimpiret_id 
                from PGTO_IMP_RET  p
             where p.empresa_id     = en_empresa_id
               and p.id             = nvl(en_pgtoimpret_id, p.id)
               and p.dt_docto between en_dt_ini 
                                  and en_dt_fim)
   loop
      --
      vn_fase := 2;
      --
      -- Realiza o Estonno da guia de pagamento
      pk_csf_api_gpi.pkb_estorno_guia_pgto_imp( est_log_generico_gpi => vt_csf_log_generico
                                              , en_guiapgtoimp_id    => x.guiapgtoimp_id); 
      --
      vn_fase := 3;
      --
      if nvl(vt_csf_log_generico.count,0) > 0 then
         --
         vn_fase := 3.1;
         --
         update PGTO_IMP_RET
            set dm_situacao = 2 -- Erro de validação
          where id = x.pgtoimpiret_id;
         --
      else
         --
         vn_fase := 3.2;
         --
         update PGTO_IMP_RET
            set dm_situacao = 3 -- Processo Finalizado
          where id = x.pgtoimpiret_id;
         --
      end if;
      --
   end loop;
   --
   
  -- Varre as Guias a serem estornadas 
   for x in (select p.id guiapgtoimp_id
                from GUIA_PGTO_IMP  p
             where p.empresa_id     = en_empresa_id
               and p.dt_ref   between en_dt_ini 
                                  and en_dt_fim)
   loop
      --
      vn_fase := 2;
      --
      -- Realiza o Estonno da guia de pagamento
      pk_csf_api_gpi.pkb_estorno_guia_pgto_imp( est_log_generico_gpi => vt_csf_log_generico
                                              , en_guiapgtoimp_id    => x.guiapgtoimp_id); 
      --
      vn_fase := 3;
      --
      if nvl(vt_csf_log_generico.count,0) > 0 then
         --
         vn_fase := 3.1;
         --
         update GUIA_PGTO_IMP t set
            t.dm_situacao = 2 -- Erro de Validação
         where t.id = x.guiapgtoimp_id;   
         --
      else
         --
         vn_fase := 3.2;
         --
         update GUIA_PGTO_IMP t set
            t.dm_situacao = 3 -- Cancelado
         where t.id = x.guiapgtoimp_id;   
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
      gv_mensagem := 'Erro na pk_csf_api_pgto_imp_ret.pkb_estorna_pgto_imp_ret fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pkb_log_generico_pir ( sn_loggenericopir_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_pir ( en_loggenericopir_id => vn_loggenerico_id
                                 , est_log_generico_pir => est_log_generico );
      exception
         when others then
            null;
      end;
      --
end pkb_estorna_pgto_imp_ret;
--

-------------------------------------------------------------------------------------------------------
end pk_csf_api_pgto_imp_ret;
/
