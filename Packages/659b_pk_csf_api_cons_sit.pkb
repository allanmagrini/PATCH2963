create or replace package body csf_own.pk_csf_api_cons_sit is
--
-------------------------------------------------------------------------------------------------------
-- Procedure que insere o log
-------------------------------------------------------------------------------------------------------
procedure pkb_log_generico_conssit( sn_loggenericonf_id    out nocopy    log_generico_nf.id%type
                                  , ev_mensagem            in            log_generico_nf.mensagem%type
                                  , ev_resumo              in            log_generico_nf.resumo%type
                                  , en_tipo_log            in            csf_tipo_log.cd_compat%type         default 1
                                  , en_empresa_id          in            Empresa.Id%type                     default null )is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_nf.id%type;
   vn_csftipolog_id  csf_tipo_log.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem := ev_mensagem;
   gv_resumo   := ev_resumo;
   --
   if nvl(gn_processo_id,0) = 0 then
      select processo_seq.nextval
        into gn_processo_id
        from dual;
   end if;
   --
   if nvl(en_tipo_log,0) > 0 and ev_mensagem is not null then
   --
      vn_fase := 2;
   --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericonf_seq.nextval
        into vn_loggenerico_id
        from dual;
      --
      sn_loggenericonf_id := vn_loggenerico_id;
      --
      vn_fase := 4;
      --
      insert into log_generico_nf ( id
                                   , processo_id
                                   , dt_hr_log
                                   , referencia_id
                                   , obj_referencia
                                   , resumo
                                   , dm_impressa
                                   , dm_env_email
                                   , csftipolog_id
                                   , empresa_id
                                   , mensagem )
                            values ( vn_loggenerico_id
                                   , gn_processo_id
                                   , sysdate
                                   , gn_referencia_id
                                   , gv_obj_referencia
                                   , ev_resumo
                                   , 0
                                   , 0
                                   , vn_csftipolog_id
                                   , nvl(en_empresa_id, gn_empresa_id)
                                   , ev_mensagem
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
      gv_mensagem := gv_mensagem || '. Erro na pk_csf_api_cons_sit.pkb_log_generico_conssit fase('||vn_fase||'):'||sqlerrm;
      gv_resumo   := gv_resumo;
      --
       declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem
                                          , ev_resumo          => gv_resumo
                                          , en_tipo_log        => erro_de_sistema
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => null
                                          , en_empresa_id      => nvl(en_empresa_id, gn_empresa_id)
                                          , en_dm_impressa     => 0 );
      exception
         when others then
            null;
      end;
      --
end pkb_log_generico_conssit;
--
-------------------------------------------------------------------------------------------------------
-- Procedure que insere o log
-------------------------------------------------------------------------------------------------------
procedure pkb_log_generico_conssit_ct( sn_loggenericoct_id    out nocopy    log_generico_ct.id%type
                                     , ev_mensagem            in            log_generico_ct.mensagem%type
                                     , ev_resumo              in            log_generico_ct.resumo%type
                                     , en_tipo_log            in            csf_tipo_log.cd_compat%type         default 1
                                     , en_empresa_id          in            Empresa.Id%type                     default null )is
   --
   vn_fase           number := 0;
   vn_loggenerico_id log_generico_ct.id%type;
   vn_csftipolog_id  csf_tipo_log.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem := ev_mensagem;
   gv_resumo   := ev_resumo;
   --
   if nvl(gn_processo_id,0) = 0 then
      select processo_seq.nextval
        into gn_processo_id
        from dual;
   end if;
   --
   if nvl(en_tipo_log,0) > 0 and ev_mensagem is not null then
      --
      vn_fase := 2;
      --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericoct_seq.nextval
        into vn_loggenerico_id
        from dual;
      --
      sn_loggenericoct_id := vn_loggenerico_id;
      --
      vn_fase := 4;
      --
      insert into log_generico_ct ( id
                                  , processo_id
                                  , dt_hr_log
                                  , referencia_id
                                  , obj_referencia
                                  , resumo
                                  , dm_impressa
                                  , dm_env_email
                                  , csftipolog_id
                                  , empresa_id
                                  , mensagem )
                           values ( vn_loggenerico_id
                                  , gn_processo_id
                                  , sysdate
                                  , gn_referencia_id
                                  , gv_obj_referencia_ct
                                  , ev_resumo
                                  , 0
                                  , 0
                                  , vn_csftipolog_id
                                  , nvl(en_empresa_id, gn_empresa_id)
                                  , ev_mensagem
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
      gv_mensagem := gv_mensagem || '. Erro na pk_csf_api_cons_sit.pkb_log_generico_conssit_ct fase('||vn_fase||'):'||sqlerrm;
      gv_resumo   := gv_resumo;
      --
       declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem
                                          , ev_resumo          => gv_resumo
                                          , en_tipo_log        => erro_de_sistema
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => null
                                          , en_empresa_id      => nvl(en_empresa_id, gn_empresa_id)
                                          , en_dm_impressa     => 0 );
      exception
         when others then
            null;
      end;
      --
end pkb_log_generico_conssit_ct;
--
-----------------------------------------
--| Procedimento finaliza o Log Genérico
-----------------------------------------
procedure pkb_finaliza_log_generico_csit is
begin
   --
   gn_processo_id := null;
      --
exception
   when others then
      --
      gv_resumo := 'Erro na pk_csf_api_cons_sit.pkb_finaliza_log_generico_csit: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem          => 'Finalizar processo de Log Genérico - CSF_CONS_SIT'
                              , ev_resumo            => gv_resumo
                              , en_tipo_log          => erro_de_sistema
                              , en_empresa_id        => gn_empresa_id );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_finaliza_log_generico_csit;
--
------------------------------------------------------
--| Procedimento armazena o valor do "loggenerico_id"
------------------------------------------------------
procedure pkb_gt_log_generico_conssit ( en_loggenericonf_id in             log_generico_nf.id%type
                                      , est_log_generico_nf in out nocopy  dbms_sql.number_table
                                      ) is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericonf_id,0) > 0 then
   --
      i := nvl(est_log_generico_nf.count,0) + 1;
   --
      est_log_generico_nf(i) := en_loggenericonf_id;
      --
   end if;
   --
exception
   when others then
   --
      gv_resumo := 'Erro na pk_csf_api_cons_sit.pkb_gt_log_generico_conssit: '||sqlerrm;
   --
   declare
         vn_loggenerico_id  Log_Generico_nf.id%TYPE;
   begin
      --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem          => 'Registrar logs genéricos com erro de validação - CSF_CONS_SIT'
                          , ev_resumo            => gv_resumo
                          , en_tipo_log          => erro_de_sistema
                          , en_empresa_id        => gn_empresa_id );
         --
   exception
      when others then
        null;
   end;
   --
end pkb_gt_log_generico_conssit;
--
------------------------------------------------------
--| Procedimento armazena o valor do "loggenerico_id"
------------------------------------------------------
procedure pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id in             log_generico_ct.id%type
                                         , est_log_generico_ct in out nocopy  dbms_sql.number_table
                                         ) is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericoct_id,0) > 0 then
   --
      i := nvl(est_log_generico_ct.count,0) + 1;
   --
      est_log_generico_ct(i) := en_loggenericoct_id;
      --
   end if;
   --
exception
   when others then
   --
      gv_resumo := 'Erro na pk_csf_api_cons_sit.pkb_gt_log_generico_conssit_ct: '||sqlerrm;
   --
   declare
         vn_loggenerico_id  Log_Generico_ct.id%TYPE;
   begin
      --
      pkb_log_generico_conssit_ct( sn_loggenericoct_id  => vn_loggenerico_id
                                 , ev_mensagem          => 'Registrar logs genéricos com erro de validação - CT_CONS_SIT'
                                 , ev_resumo            => gv_resumo
                                 , en_tipo_log          => erro_de_sistema
                                 , en_empresa_id        => gn_empresa_id );
         --
   exception
      when others then
        null;
   end;
   --
end pkb_gt_log_generico_conssit_ct;
--
----------------------------------------------------------------------------------
-- Procedimento que limpa a tabela log_generico_nf
----------------------------------------------------------------------------------
procedure pkb_limpar_loggenericoconssit( en_empresa_id     in      Empresa.Id%type ) is
   --
begin
   --
   delete from log_generico_nf l
    where nvl(l.empresa_id,0) = nvl(en_empresa_id,0)
      and l.empresa_id     is not null
      and l.obj_referencia = 'CSF_CONS_SIT';
   --
   commit;
   --
exception
   when others then
      --
      gv_resumo := 'Erro na pkb_limpar_loggenericoconssit:'||sqlerrm;
      --
      declare
         vn_loggenerico_id   log_generico_nf.id%type;
      begin
      --
      pkb_log_generico_conssit( sn_loggenericonf_id  => vn_loggenerico_id
                              , ev_mensagem          => 'Limpar tabela de logs genéricos - CSF_CONS_SIT'
                          , ev_resumo            => gv_resumo
                          , en_tipo_log          => erro_de_sistema
                          , en_empresa_id        => gn_empresa_id );
      exception
         when others then
           null;
      end;
end pkb_limpar_loggenericoconssit;
--
-----------------------------------------------------------------------------
--| Procedimento seta o tipo de integração que será feito
--| 0 - Somente válida os dados e registra o Log de ocorrência
--| 1 - Válida os dados e registra o Log de ocorrência e insere a informação
--| Todos os procedimentos de integração fazem referência a ele
-----------------------------------------------------------------------------
procedure pkb_seta_tipo_integr ( en_tipo_integr in number
                               ) is
begin
   --
   gn_tipo_integr := en_tipo_integr;
   --
end pkb_seta_tipo_integr;
--
-- ====================================================================================================================== --
-- Checa se existe consulta pendente ou consulta no dia de chave de acesso nfe
-- ====================================================================================================================== --
function fkg_checa_chave_envio_pendente (ev_nro_chave_nfe nota_fiscal.nro_chave_nfe%type) return number is
   --
   vn_retorno number := 0;
   --
begin
   -- Primeiro passo, checa se existe consulta no mesmo dia
   begin
      select distinct 1
        into vn_retorno
        from csf_cons_sit t
       where t.chnfe                 = ev_nro_chave_nfe
         and trunc(t.dt_hr_cons_sit) = trunc(sysdate);
   exception
      when others then
         vn_retorno := 0;
   end;
   --
   -- Se não achou pendencia de consulta no dia, checa se existe consulta pendente de envio
   if vn_retorno = 0 then
      --
      begin
         select distinct 1
           into vn_retorno
          from csf_cons_sit t
          where t.chnfe       = ev_nro_chave_nfe
            and t.dm_situacao = 1;
      exception
         when others then
            vn_retorno := 0;
      end;
      --
   end if;
   --
   return vn_retorno;
   --
exception
  when others then
     null;
end fkg_checa_chave_envio_pendente;
--
-- ====================================================================================================================== --
-- Checa se existe a mesma chave em outro registro com DM_SITUACAO IN (0,1)
-- ====================================================================================================================== --
function fkg_checa_existe_chave (ev_nro_chave_nfe nota_fiscal.nro_chave_nfe%type) return number is
   --
   vn_retorno number := 0;
   --
begin
   -- Validar 
   begin
      select max(id)
        into vn_retorno
        from csf_cons_sit
       where chnfe        = ev_nro_chave_nfe
         and dm_situacao in (0,1);
   exception
      when no_data_found then
         vn_retorno := null;
   end;
   --
   return vn_retorno;
   --
exception
  when others then
     null;
end fkg_checa_existe_chave;
--
-- ====================================================================================================================== --
-- Checa se a NOTA_FISCAL_MDE já existe registrado e vinculado a NFe
-- ====================================================================================================================== --
function fkg_ck_nota_fiscal_mde_registr( en_notafiscal_id       in nota_fiscal_mde.notafiscal_id%type
                                       , en_tipoeventosefaz_id  in nota_fiscal_mde.tipoeventosefaz_id%type)
return boolean is
   --
   vn_aux             number;
   vn_loggenerico_id  log_generico_nf.id%type;
   --
begin
   --
   select distinct 1 -- idx: NOTA_FISCAL_MDE_IDX5
     into vn_aux
   from nota_fiscal_mde nf
   where nf.notafiscal_id      = en_notafiscal_id
     and nf.tipoeventosefaz_id = en_tipoeventosefaz_id;
   --
   -- Grava o Log na nota informando que houve tentativa de novas inclusões do MDE
   vn_loggenerico_id := null;
   gv_mensagem       := 'Esta Nota Fiscal já encontra-se registrada no MDE';
   --
   gn_referencia_id  := en_notafiscal_id;
   gv_obj_referencia := 'NOTA_FISCAL';
   --
   pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                            , ev_mensagem         => gv_mensagem
                            , ev_resumo           => gv_mensagem
                            , en_tipo_log         => erro_de_validacao );
   --
   return true;
   --
exception
  when others then
    return false;
end fkg_ck_nota_fiscal_mde_registr;
--
-- ====================================================================================================================== --
-- Procedimento de atualização da tabela CSF_CONS_SIT
-- ====================================================================================================================== --
procedure pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit in out nocopy csf_cons_sit%rowtype
                                   , ev_campo_atu         in varchar2 
                                   , en_tp_rotina         in number
                                   , ev_rotina_orig       in varchar2
                                   ) is
   --
begin
   --
   if en_tp_rotina = 0 then -- Atualização
      --
      gn_referencia_id := est_row_csf_cons_sit.id;
      --
      -- Identifica qual campo será atualizado
      if upper(ev_campo_atu) = 'NOTAFISCAL_ID' then
         --
         update csf_cons_sit
            set notafiscal_id = est_row_csf_cons_sit.notafiscal_id
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_CRIAR_MDE' then
          --
         update csf_cons_sit
            set dm_criar_mde = est_row_csf_cons_sit.dm_criar_mde
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_INTEGR_ERP' then
          --
         update csf_cons_sit
            set dm_integr_erp = est_row_csf_cons_sit.dm_integr_erp
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_ST_INTEGRA' then
          --
         update csf_cons_sit
            set dm_st_integra = est_row_csf_cons_sit.dm_st_integra
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_SITUACAO' then
          --
         update csf_cons_sit
            set dm_situacao = est_row_csf_cons_sit.dm_situacao
          where id = est_row_csf_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'CSTAT' then
          --
         update csf_cons_sit
            set cstat = est_row_csf_cons_sit.cstat
          where id = est_row_csf_cons_sit.id;
         --
      end if;
      --
   elsif en_tp_rotina = 1 then-- Inserção
      --
      -- Validar se existe a mesma chave em outro registro com DM_SITUACAO IN (0,1)
      -- Se existir não insere novamente
      -- =============================================================================
      if nvl(pk_csf_api_cons_sit.fkg_checa_existe_chave(est_row_csf_cons_sit.chnfe),0) = 0 then   
         --
         begin
            select csfconssit_seq.nextval
              into est_row_csf_cons_sit.id
              from dual;
         exception
            when others then
               est_row_csf_cons_sit.id := null;
         end;
         --
         gn_referencia_id := est_row_csf_cons_sit.id;
         --      
      insert into csf_cons_sit ( id
                               , empresa_id
                               , notafiscal_id
                               , usuario_id
                               , referencia
                               , chnfe
                               , codufibge
                               , dm_tp_cons
                               , dm_situacao
                               , dt_hr_cons_sit
                               , versao
                               , tpamb
                               , veraplic
                               , cstat
                               , xmotivo
                               , cuf
                               , dhrecbto
                               , nprot
                               , digval
                               , signature
                                  , dm_rec_fisico
                                  , dm_integr_erp 
                                  , dm_st_integra )
	                         values ( est_row_csf_cons_sit.id -- id
                               , est_row_csf_cons_sit.empresa_id
                               , est_row_csf_cons_sit.notafiscal_id
                               , est_row_csf_cons_sit.usuario_id
                               , est_row_csf_cons_sit.referencia
                               , est_row_csf_cons_sit.chnfe
                               , est_row_csf_cons_sit.codufibge
                               , est_row_csf_cons_sit.dm_tp_cons
                               , est_row_csf_cons_sit.dm_situacao
                               , est_row_csf_cons_sit.dt_hr_cons_sit
                               , est_row_csf_cons_sit.versao
                               , est_row_csf_cons_sit.tpamb
                               , est_row_csf_cons_sit.veraplic
                               , est_row_csf_cons_sit.cstat
                               , est_row_csf_cons_sit.xmotivo
                               , est_row_csf_cons_sit.cuf
                               , est_row_csf_cons_sit.dhrecbto
                               , est_row_csf_cons_sit.nprot
                               , est_row_csf_cons_sit.digval
                               , est_row_csf_cons_sit.signature
                               , est_row_csf_cons_sit.dm_rec_fisico
                                  , est_row_csf_cons_sit.dm_integr_erp
                                  , est_row_csf_cons_sit.dm_st_integra
                               );
      end if; 
      --
   end if;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit : '||sqlerrm;
      gv_resumo   := 'Rotina que chamou a pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit : '||ev_rotina_orig;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                                  , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id);
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem);
      --
end pkb_ins_atu_csf_cons_sit;
--
-- ====================================================================================================================== --
-- Procedimento de validação dos dados da chave da nf
-- ====================================================================================================================== --
procedure pkb_valid_cons_chave_nfe ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                   , est_row_csf_cons_sit in out nocopy  csf_cons_sit%rowtype
                                   , en_multorg_id        in             mult_org.id%type
                                   , ev_rotina            in             varchar2 default null -- rotina que chamou esse processo
                                   ) is
   vn_fase        number;
   vn_loggenerico_id log_generico_nf.id%type;
   vn_dig_verif_chave         nota_fiscal.dig_verif_chave%type;
   --
begin
   --
   vn_fase := 1;
   --
   gn_referencia_id := est_row_csf_cons_sit.id;
   --   
   vn_fase := 2;
   --
   -- Verifica se valor da chave não é nulo
   -- =====================================
   if trim(est_row_csf_cons_sit.chnfe) is not null then
      --
      vn_fase := 2.1;
      --
      -- Valida se a Chave de Acesso contêm 44 digitos
      -- =============================================
      if length(trim(est_row_csf_cons_sit.chnfe)) <> 44 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso deve conter 44 dígitos';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe. '||
                      'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                             , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
      vn_fase := 2.3;
      --
      -- Valida digito verificador da chave
      -- ==================================
      -- Valida o digito verificador da Chave de Acesso
      vn_dig_verif_chave := pk_csf.fkg_mod_11 ( ev_codigo => substr(trim(est_row_csf_cons_sit.chnfe), 1,43) );
      --
      vn_fase := 2.4;
      --
      if nvl(vn_dig_verif_chave,0) <> to_number( substr(trim(est_row_csf_cons_sit.chnfe), 44,1) ) then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso inválida';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe. '||
                      'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                             , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
      --Validar 2 primeiros dígitos da chave - devem ter um valor valido em ESTADO.IBGE_ESTADO
      -- ======================================================================================
      if nvl(pk_csf.fkg_Estado_ibge_id (substr(est_row_csf_cons_sit.chnfe,1,2)),0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Código da UF contido na Chave está inválido';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe. '||
                      'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                             , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
      -- Validar se os dígitos que representam o ano e mês de emissão não são mais antigos que 6 meses
      -- =============================================================================================
      if to_date(sysdate,'dd/mm/yyyy') - to_date(est_row_csf_cons_sit.dt_hr_cons_sit,'dd/mm/yyyy') > 210 then -- 7 meses para garantir
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso é muito antiga. SEFAZ permite consulta apenas para notas emitidas nos ultimos 180 dias';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe. '||
                      'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                             , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                , est_log_generico_nf => est_log_generico_nf );
         --
      end if;
      --
      end if;
      --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_valid_cons_chave_nfe fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                                  , en_tipo_log         => erro_de_sistema
                                  , en_empresa_id       => est_row_csf_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                     , est_log_generico_nf => est_log_generico_nf );
      exception
         when others then
            null;
      end;
   --
end pkb_valid_cons_chave_nfe;
--
-- ====================================================================================================================== --
-- Procedimento de integração de consulta chave nfe
-- ====================================================================================================================== --
procedure pkb_integr_cons_chave_nfe ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                    , est_row_csf_cons_sit in out nocopy  csf_cons_sit%rowtype
                                    , ev_cpf_cnpj_emit     in             varchar2
                                    , en_multorg_id        in             mult_org.id%type 
                                    , ev_rotina            in             varchar2 default null -- rotina que chamou esse processo
                                    ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_nf.id%type;
   vn_empresa_id      empresa.id%type;
   gv_resumo          log_generico_nf.resumo%type;
   gv_mensagem         csf_cons_sit.xmotivo%type := null;
   vn_dm_tp_amb       empresa.dm_tp_amb%type;
   --
begin
   --
   vn_fase := 1;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 1.1;
   --
   if nvl(vn_empresa_id,0) <= 0 then
      --
      vn_fase := 1.2;
      --
      gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe. '||
                   'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                   'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
      --
      gv_mensagem := 'Empresa não encontrada. CNPJ(' || ev_cpf_cnpj_emit || ').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                               , ev_mensagem         => gv_mensagem
                               , ev_resumo           => gv_resumo
                               , en_tipo_log         => erro_de_validacao
                               , en_empresa_id       => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                  , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Valida se tem valor para a chave
   if trim(est_row_csf_cons_sit.chnfe) is null then
      --
      gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe. '||
                   'Chave('||est_row_csf_cons_sit.chnfe||'). '||
                   'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
      --
      gv_mensagem := 'Não foi informada a chave de acesso da NFe.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                               , ev_mensagem         => gv_mensagem
                               , ev_resumo           => gv_resumo
                               , en_tipo_log         => erro_de_validacao
                               , en_empresa_id       => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   elsif trim(est_row_csf_cons_sit.chnfe) is not null then
      --
      vn_fase := 3;
      --
      -- Recupera o tipo de ambiente da empresa
      vn_dm_tp_amb := pk_csf.fkg_tp_amb_empresa ( en_empresa_id => vn_empresa_id );
      --
      vn_fase := 5;
      --
      begin
         -- Chama rotina que atualiza ou insere a tabela csf_cons_sit
         --
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.id               :=  null;  -- id
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id       :=  vn_empresa_id;                          -- empresa_id
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.chnfe            :=  est_row_csf_cons_sit.chnfe;             --chnfe
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.codufibge        :=  substr(est_row_csf_cons_sit.chnfe,1,2); -- codufibge
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_tp_cons       :=  6;                                      -- dm_tp_cons -- Automática através de integração table/view
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_situacao      :=  0;                                      -- dm_situacao
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dt_hr_cons_sit   :=  sysdate;                                -- dt_hr_cons_sit
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.tpamb            :=  vn_dm_tp_amb;                           -- tpamb
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.xmotivo          :=  gv_mensagem;
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_rec_fisico    :=  1;                                      -- dm_rec_fisico
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_integr_erp    :=  0;                                      -- dm_integr_erp
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_st_integra    :=  7;                                      -- dm_st_integra
         --
         pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                      , ev_campo_atu         => null
                                                      , en_tp_rotina         => 1 -- inserção
                                                      , ev_rotina_orig       => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                                      );
          --
          -- Chama a rotina de validacao da Chave de Acesso
          -- ==============================================
          pkb_valid_cons_chave_nfe ( est_log_generico_nf      => est_log_generico_nf
                                   , est_row_csf_cons_sit     => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                   , en_multorg_id            => null
                                   , ev_rotina                => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                   );
          --
          vn_fase := 6;
          --
          if nvl(est_log_generico_nf.count,0) > 0 then
             --
             -- Chama rotina que atualiza a tabela csf_cons_sit
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id    := vn_empresa_id;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_situacao   := 7;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.cstat         := '000';
             --
             pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                          , ev_campo_atu         => 'dm_situacao'
                                                          , en_tp_rotina         => 0 -- atualização
                                                          , ev_rotina_orig       => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                                          );
             --
             pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                          , ev_campo_atu         => 'cstat'
                                                          , en_tp_rotina         => 0 -- atualização
                                                          , ev_rotina_orig       => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                                          );
             --
          else
             --
             -- Chama rotina que atualiza a tabela csf_cons_sit
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id    := vn_empresa_id;
             pk_csf_api_cons_sit.gt_row_csf_cons_sit.dm_situacao   := 1;
             --
             pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                          , ev_campo_atu         => 'dm_situacao'
                                                          , en_tp_rotina         => 0 -- atualização
                                                          , ev_rotina_orig       => 'pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe'
                                                          );
             --
          end if;
          --
          commit;
          --
      exception
         when others then
            pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                     , ev_mensagem         => 'Erro ao tentar inserir/atualizar os dados na tabela csf_cons_sit'
                                     , ev_resumo           => 'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')Erro('||sqlerrm||')'
                                     , en_tipo_log         => erro_de_sistema
                                     , en_empresa_id       => null );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                        , est_log_generico_nf => est_log_generico_nf );
      end;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_integr_cons_chave_nfe fase('||vn_fase||'). Erro: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_mensagem
                                  , en_tipo_log         => erro_de_sistema
                                  , en_empresa_id       => vn_empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit ( en_loggenericonf_id => vn_loggenerico_id
                                     , est_log_generico_nf => est_log_generico_nf );
      exception
         when others then
            null;
      end;
   --
END pkb_integr_cons_chave_nfe;
--
-- ====================================================================================================================== --
-- Procedimento de atualização do campo NOTAFISCAL_ID da tabela CSF_CONS_SIT
-- Pega todos os registros que o campo NOTAFISCAL_ID estão nulos, verifica se sua chave de acesso existe
-- na tabela NOTA_FISCAL, se exitir relaciona o campo NOTA_FISCAL.ID com campo CSF_CONS_SIT.NOTAFISCCAL_ID
-- ====================================================================================================================== --
procedure pkb_relac_nfe_cons_sit ( en_multorg_id  in mult_org.id%type ) is
   --
   vn_csfconssit_id    csf_cons_sit.id%type;
   vn_fase             number := 0;
   vn_notafiscal_id    Nota_Fiscal.id%TYPE := null;
   vn_multorg_id       mult_org.id%type;
   vn_dm_st_proc       Nota_Fiscal.dm_st_proc%type := null;
   vn_loggenerico_id   number := null;
   vv_msg              varchar2(4000) := null;
   vv_ibge_estado      estado.ibge_estado%type;
   vd_dt_emiss         nota_fiscal.dt_emiss%type;
   vv_cnpj_emit        varchar2(14);
   vv_cod_mod          mod_fiscal.cod_mod%type;
   vv_serie            nota_fiscal.serie%type;
   vn_nro_nf           nota_fiscal.nro_nf%type;
   vn_dm_forma_emiss   nota_fiscal.dm_forma_emiss%type;
   vn_cnf_nfe          nota_fiscal.cnf_nfe%type;
   vn_dig_verif_chave  nota_fiscal.dig_verif_chave%type;
   vv_cod_part         pessoa.cod_part%type;
   vn_pessoa_id        pessoa.id%type;
   vn_dm_situacao      csf_cons_sit.dm_situacao%type;
   vv_tpevento         csf_cons_sit_evento.tpevento%type;
   vn_dm_ind_emit      nota_fiscal.dm_ind_emit%type;
   --
   vn_tipoeventosefaz_id  tipo_evento_sefaz.id%type;
   vn_qtde_ciencia_mde    number;
   vd_hr_evento           date;
   vn_dm_reg_co_mde_aut   empr_param_cons_mde.dm_reg_co_mde_aut%type;
   --
   cursor c_cons_sit is
   select cs.*
     from empresa e
        , csf_cons_sit cs
    where 1 = 1
      and e.multorg_id = en_multorg_id
      and cs.empresa_id = e.id
      and nvl(cs.notafiscal_id,0) <= 0
      and cs.dm_situacao          in (2, 3, 4)
      and length(cs.chnfe)         = 44
    order by cs.id;
   --
   -- Notas Fiscais com consulta e sem definição de situação
   cursor c_nf is
   select nf.id
     from empresa e
        , nota_fiscal nf
        , mod_fiscal  mf
    where 1 = 1
      and e.multorg_id       = en_multorg_id
      and nf.empresa_id      = e.id
      and nf.dm_arm_nfe_terc = 1
      and nf.dm_st_proc      = 0
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        <> '65'
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_cons_sit loop
      exit when c_cons_sit%notfound or (c_cons_sit%notfound) is null;
      --
      vn_fase := 2;
      --
      vn_csfconssit_id := rec.id;
      --
      -- Verificar se exite NFe para a Chave de Acesso consultada
      -- vn_notafiscal_id := pk_csf.fkg_notafiscal_id_pela_chave ( en_nro_chave_nfe => rec.chnfe );
      --
      vv_ibge_estado := substr(rec.chnfe, 1, 2);
      --
      if rec.dhrecbto is not null then
         --
         vd_dt_emiss := rec.dhrecbto;
         --
      elsif pk_csf.fkg_data_valida('01/' || substr(rec.chnfe, 5, 2) || '/' || substr(rec.chnfe, 3, 2), 'dd/mm/yy') then
         --
         vd_dt_emiss := to_date('01/' || substr(rec.chnfe, 5, 2) || '/' || substr(rec.chnfe, 3, 2), 'dd/mm/yy');
         --
      else
         --
         vd_dt_emiss := sysdate;
         --
      end if;
      --
      vn_fase := 3;
      --
      vv_cnpj_emit := substr(rec.chnfe, 7, 14);
      vv_cod_mod   := substr(rec.chnfe, 21, 2);
      vv_serie     := to_number(substr(rec.chnfe, 23, 3));
      vn_nro_nf    := substr(rec.chnfe, 26, 9);
      --
      vn_fase := 4;
      --
      vn_dm_forma_emiss  := substr(rec.chnfe, 35, 1);
      vn_cnf_nfe         := substr(rec.chnfe, 36, 8);
      vn_dig_verif_chave := substr(rec.chnfe, 44, 1);
      --
      vn_fase := 5;
      --
      vn_multorg_id    := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => rec.empresa_id );
      --
      -- busca a pessoa
      vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj ( en_multorg_id => vn_multorg_id
                                                    , en_cpf_cnpj   => vv_cnpj_emit );
      --
      vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => vn_pessoa_id );
      --
      vn_fase := 6;
      --
      -- Recupera o ID da nota fiscal
      vn_notafiscal_id := pk_csf.fkg_nf_id_terceiro_pela_chave ( en_nro_chave_nfe => rec.chnfe );
      --
      if nvl(vn_notafiscal_id,0) <= 0 then
         --
         vn_notafiscal_id := pk_csf.fkg_busca_notafiscal_id ( en_multorg_id      => vn_multorg_id
                                                            , en_empresa_id      => rec.empresa_id
                                                            , ev_cod_mod         => vv_cod_mod
                                                            , ev_serie           => vv_serie
                                                            , en_nro_nf          => vn_nro_nf
                                                            , en_dm_ind_oper     => 0
                                                            , en_dm_ind_emit     => 1
                                                            , ev_cod_part        => null
                                                            , en_dm_arm_nfe_terc => 1 );
         --
      end if;
      --
      vn_fase := 7;
      --
      begin
         --
         select e.tpevento
           into vv_tpevento
           from csf_cons_sit_evento e
          where e.csfconssit_id = rec.id;
         --
      exception
         when others then
            vv_tpevento := null;
      end;
      --
      vn_fase := 8;
      --
      -- Se encontrou a NFe para a Chave de Acesso, relacionar o ID
      if nvl(vn_notafiscal_id,0) > 0 then
         --
         vn_fase := 9;
         --
         -- Chama rotina que atualiza a tabela csf_cons_sit
         pk_csf_api_cons_sit.gt_row_csf_cons_sit               := null;
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.empresa_id    := rec.empresa_id;
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.id            := rec.id;
         pk_csf_api_cons_sit.gt_row_csf_cons_sit.notafiscal_id := vn_notafiscal_id;
         --
         pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit => pk_csf_api_cons_sit.gt_row_csf_cons_sit
                                                      , ev_campo_atu         => 'notafiscal_id'
                                                      , en_tp_rotina         => 0 -- atualização
                                                      , ev_rotina_orig       => 'pk_csf_api.pkb_relac_nfe_cons_sit'
                                                      );
         --
         if trim(vv_tpevento) = '110111' then -- Cancelamento registrado
            --
            vn_dm_st_proc := 7; -- Cancelado
            --
            vv_msg := 'Consulta da NFe na Sefaz, com a situação Cancelamento registrado';
            --
         else
            --
            vn_fase := 10;
            --
            vn_dm_st_proc := case
                                when rec.dm_situacao = 2 then 4 -- Autorizado o uso da NF-e (100)
                                when rec.dm_situacao = 3 then 7 -- Cancelamento da NF-e Homologado (101)
                                when rec.dm_situacao = 4 then 6 -- Uso denegado (110)
                                when rec.dm_situacao = 5 then 5 -- Rejeitada
                                when rec.dm_situacao = 6 then 5 -- Rejeitada
                             else 0
                             end;
            --
            vn_fase := 11;
            --
            vv_msg := 'Consulta da NFe na Sefaz, com a situação '||pk_csf.fkg_dominio( ev_dominio => 'CSF_CONS_SIT.DM_SITUACAO'
                                                                                     , ev_vl      => rec.dm_situacao );
            --
         end if;
         --
         vn_fase := 12;
         --
         if rec.dm_rec_fisico = 1 then -- Sim, recebimento fisico da DANFE
            --
            vv_msg := vv_msg||', havendo o recebimento físico da DANFE';
            --
         end if;
         --
         gn_referencia_id  := vn_notafiscal_id;
         gv_obj_referencia := 'NOTA_FISCAL';
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => 'Chave de acesso: ' || rec.chnfe
                                  , ev_resumo           => vv_msg
                                  , en_tipo_log         => CONS_SIT_NFE_SEFAZ);
         vn_fase := 13;
         --
         if nvl(trim(rec.CSTAT), '0') <> '526' then -- não é "Rejeição: Consulta a uma Chave de Acesso muito antiga"
            --
            -- Atualiza o status da NFe
            if rec.dm_rec_fisico = 1 then -- Sim, recebimento fisico da DANFE
               --
               -- Variavel global usada em logs de triggers (carrega)
               gv_objeto := 'pk_csf_api.pkb_relac_nfe_cons_sit';
               gn_fase   := vn_fase;
               --
               update nota_fiscal
                  set dm_st_proc    = vn_dm_st_proc
                    , dm_danfe_rec  = 1
                    , dm_ret_nf_erp = 0
                where id          = vn_notafiscal_id
                  and dm_st_proc <> vn_dm_st_proc;
               --
               -- Variavel global usada em logs de triggers (limpa)
               gv_objeto := 'pk_csf_api';
               gn_fase   := null;
               --
            else
               --
               -- Variavel global usada em logs de triggers (carrega)
               gv_objeto := 'pk_csf_api.pkb_relac_nfe_cons_sit';
               gn_fase   := vn_fase;
               --
               update nota_fiscal
                  set dm_st_proc    = vn_dm_st_proc
                    , dm_ret_nf_erp = 0
                where id          = vn_notafiscal_id
                  and dm_st_proc <> vn_dm_st_proc;
               --
               -- Variavel global usada em logs de triggers (limpa)
               gv_objeto := 'pk_csf_api';
               gn_fase   := null;
               --
            end if;
            --
         end if;
         --
      elsif rec.dm_rec_fisico = 1 then
         --
         vn_fase := 11;
         -- Cria o registro da Nota Fiscal, conforme chave de acesso
         -- quebra os dados da chave de acesso
         if vn_dm_forma_emiss not in (1, 2, 3, 4, 5, 6, 7, 8, 9) then
            vn_dm_forma_emiss := 1;
         end if;
         --
         vn_fase := 12;
         -- insere dados da nota
         vn_dm_st_proc := case
                             when rec.dm_situacao = 2 then 4 -- Autorizado o uso da NF-e (100)
                             when rec.dm_situacao = 3 then 7 -- Cancelamento da NF-e Homologado (101)
                             when rec.dm_situacao = 4 then 6 -- Uso denegado (110)
                             when rec.dm_situacao = 5 then 5 -- Rejeitada
                             when rec.dm_situacao = 6 then 5 -- Rejeitada
                          else 0
                          end;
         --
         vn_fase := 13;
         --
         select notafiscal_seq.nextval
           into vn_notafiscal_id
           from dual;
         --
         vn_fase := 14;
         --
         begin
            --
            -- Variavel global usada em logs de triggers (carrega)
            gv_objeto := 'pk_csf_api.pkb_relac_nfe_cons_sit';
            gn_fase   := vn_fase;
            --
            insert into nota_fiscal ( id
                                 , empresa_id
                                 , pessoa_id
                                 , sitdocto_id
                                 , natoper_id
                                 , lote_id
                                 , inutilizanf_id
                                 , versao
                                 , id_tag_nfe
                                 , pk_nitem
                                 , nat_oper
                                 , dm_ind_pag
                                 , modfiscal_id
                                 , dm_ind_emit
                                 , dm_ind_oper
                                 , dt_sai_ent
                                 , dt_emiss
                                 , nro_nf
                                 , serie
                                 , uf_embarq
                                 , local_embarq
                                 , nf_empenho
                                 , pedido_compra
                                 , contrato_compra
                                 , dm_st_proc
                                 , dt_st_proc
                                 , dm_forma_emiss
                                 , dm_impressa
                                 , dm_tp_impr
                                 , dm_tp_amb
                                 , dm_fin_nfe
                                 , dm_proc_emiss
                                 , vers_proc
                                 , dt_aut_sefaz
                                 , dm_aut_sefaz
                                 , cidade_ibge_emit
                                 , uf_ibge_emit
                                 , dt_hr_ent_sist
                                 , nro_chave_nfe
                                 , cnf_nfe
                                 , dig_verif_chave
                                 , vers_apl
                                 , dt_hr_recbto
                                 , nro_protocolo
                                 , digest_value
                                 , msgwebserv_id
                                 , cod_msg
                                 , motivo_resp
                                 , nfe_proc_xml
                                 , dm_st_email
                                 , id_usuario_erp
                                 , impressora_id
                                 , usuario_id
                                 , dm_st_integra
                                 , vias_danfe_custom
                                 , nro_chave_nfe_adic
                                 , nro_tentativas_impr
                                 , dt_ult_tenta_impr
                                 , sub_serie
                                 , codconsitemcont_id
                                 , inforcompdctofiscal_id
                                 , cod_cta
                                 , dm_tp_ligacao
                                 , dm_cod_grupo_tensao
                                 , dm_tp_assinante
                                 , sistorig_id
                                 , unidorg_id
                                 , serie_scan
                                 , nro_nf_scan
                                 , hora_sai_ent
                                 , nro_chave_cte_ref
                                 , dt_cont
                                 , just_cont
                                 , dm_ret_nf_erp
                                 , xml_wssinal_suframa
                                 , dm_st_wssinal_suframa
                                 , dm_arm_nfe_terc
                                 , dm_rec_xml
                                 , dm_danfe_rec
                                 , nro_email_env_forn
                                 , dm_fin_email_forn )
                          values ( vn_notafiscal_id
                                 , rec.empresa_id
                                 , vn_pessoa_id
                                 , pk_csf.fkg_Sit_Docto_id ( '00' )
                                 , null
                                 , null
                                 , null
                                 , null
                                 , 'NFe' || rec.chnfe
                                 , null
                                 , null
                                 , 0 -- DM_IND_PAG
                                 , pk_csf.fkg_mod_fiscal_id ( vv_cod_mod )
                                 , 1 -- dm_ind_emit
                                 , 0 -- dm_ind_oper
                                 , null -- dt_sai_ent
                                 , vd_dt_emiss -- dt_emiss
                                 , vn_nro_nf -- nro_nf
                                 , vv_serie -- serie
                                 , null -- uf_embarq
                                 , null -- local_embarq
                                 , null -- nf_empenho
                                 , null -- pedido_compra
                                 , null -- contrato_compra
                                 , vn_dm_st_proc -- dm_st_proc
                                 , sysdate -- dt_st_proc
                                 , vn_dm_forma_emiss -- dm_forma_emiss
                                 , 3 -- dm_impressa -- 3-Não se aplica
                                 , 1 -- dm_tp_impr
                                 , 1 -- dm_tp_amb
                                 , 1 -- dm_fin_nfe
                                 , 0 -- dm_proc_emiss
                                 , '1' -- vers_proc
                                 , rec.dhrecbto -- dt_aut_sefaz
                                 , 1 -- dm_aut_sefaz
                                 , 9999999 -- cidade_ibge_emit
                                 , vv_ibge_estado -- uf_ibge_emit
                                 , sysdate -- dt_hr_ent_sist
                                 , rec.chnfe -- nro_chave_nfe
                                 , vn_cnf_nfe
                                 , vn_dig_verif_chave
                                 , rec.versao -- vers_apl
                                 , rec.dhrecbto -- dt_hr_recbto
                                 , rec.nprot -- nro_protocolo
                                 , rec.digval --digest_value
                                 , null -- msgwebserv_id
                                 , rec.cstat -- cod_msg
                                 , rec.xmotivo -- motivo_resp
                                 , null -- nfe_proc_xml
                                 , 1 -- dm_st_email
                                 , null -- id_usuario_erp
                                 , null -- impressora_id
                                 , null -- usuario_id
                                 , 0 -- dm_st_integra
                                 , 0 -- vias_danfe_custom
                                 , null -- nro_chave_nfe_adic
                                 , 0 -- nro_tentativas_impr
                                 , null -- dt_ult_tenta_impr
                                 , null -- sub_serie
                                 , null -- codconsitemcont_id
                                 , null -- inforcompdctofiscal_id
                                 , null -- cod_cta
                                 , null -- dm_tp_ligacao
                                 , null -- dm_cod_grupo_tensao
                                 , null -- dm_tp_assinante
                                 , null -- sistorig_id
                                 , null -- unidorg_id
                                 , null -- serie_scan
                                 , null -- nro_nf_scan
                                 , null -- hora_sai_ent
                                 , null -- nro_chave_cte_ref
                                 , null -- dt_cont
                                 , null -- just_cont
                                 , 0 -- dm_ret_nf_erp -- Não
                                 , null -- xml_wssinal_suframa
                                 , 0 -- dm_st_wssinal_suframa
                                 , 1 -- dm_arm_nfe_terc
                                 , 0 -- dm_rec_xml
                                 , rec.dm_rec_fisico -- dm_danfe_rec
                                 , 0 -- nro_email_env_forn
                                 , 0 -- dm_fin_email_forn
                                 );
            --
            -- Variavel global usada em logs de triggers (limpa)
            gv_objeto := 'pk_csf_api';
            gn_fase   := null;
            --
            vn_fase := 15;
            -- insere informações do emitente
            insert into nota_fiscal_emit ( id
                                      , notafiscal_id
                                      , nome
                                      , lograd
                                      , nro
                                      , cidade_ibge
                                      , uf
                                      , cnpj
                                      , dm_reg_trib
                                      )
                               values ( notafiscalemit_seq.nextval
                                      , vn_notafiscal_id
                                      , 'Informar pelo XML'
                                      , 'SL'
                                      , 'SN'
                                      , 9999999
                                      , pk_csf.fkg_estado_id_sigla ( pk_csf.fkg_estado_ibge_id ( vv_ibge_estado ) )
                                      , vv_cnpj_emit -- cnpj
                                      , 3 -- dm_reg_trib
                                      );
            --
            vn_fase := 16;
            --
            insert into nota_fiscal_dest( id
                                     , notafiscal_id
                                     , cnpj
                                     , cpf
                                     , nome
                                     , lograd
                                     , nro
                                     , compl
                                     , bairro
                                     , cidade
                                     , cidade_ibge
                                     , uf
                                     , cep
                                     , cod_pais
                                     , pais
                                     , fone
                                     , ie
                                     , suframa
                                     , email
                                     , usuario_id
                                     , dm_integr_edi )
                               values( notafiscaldest_seq.nextval
                                     , vn_notafiscal_id -- notafiscal_id
                                     , null -- cnpj
                                     , null -- cpf
                                     , 'Integrar pelo XML' -- nome
                                     , 'SL' -- lograd
                                     , 'SN' -- nro
                                     , null -- compl
                                     , 'SB' -- bairro
                                     , 'SC' -- cidade
                                     , 9999999 -- cidade_ibge
                                     , pk_csf.fkg_estado_id_sigla ( pk_csf.fkg_estado_ibge_id ( vv_ibge_estado ) ) -- uf
                                     , null -- cep
                                     , null -- cod_pais
                                     , null -- pais
                                     , null -- fone
                                     , null -- ie
                                     , null -- suframa
                                     , null -- email
                                     , null -- usuario_id
                                     , 2 ); -- dm_integr_edi
            --
            vn_fase := 17;
            --
            -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (carrega)
            pk_csf_api.gv_objeto := 'pk_csf_api.PKB_RELAC_NFE_CONS_SIT';
            pk_csf_api.gn_fase   := vn_fase;
            --
            insert into nota_fiscal_total ( id
                              , notafiscal_id
                              , vl_base_calc_icms
                              , vl_imp_trib_icms
                              , vl_base_calc_st
                              , vl_imp_trib_st
                              , vl_total_item
                              , vl_frete
                              , vl_seguro
                              , vl_desconto
                              , vl_imp_trib_ii
                              , vl_imp_trib_ipi
                              , vl_imp_trib_pis
                              , vl_imp_trib_cofins
                              , vl_outra_despesas
                              , vl_total_nf
                              , vl_serv_nao_trib
                              , vl_base_calc_iss
                              , vl_imp_trib_iss
                              , vl_pis_iss
                              , vl_cofins_iss
                              , vl_ret_pis
                              , vl_ret_cofins
                              , vl_ret_csll
                              , vl_base_calc_irrf
                              , vl_ret_irrf
                              , vl_base_calc_ret_prev
                              , vl_ret_prev
                              , vl_total_serv
                              , vl_abat_nt
                              , vl_forn
                              , vl_terc
                              , vl_servico
                              , vl_pis_st
                              , vl_cofins_st
                              )
                       values ( notafiscaltotal_seq.nextval
                              , vn_notafiscal_id -- notafiscal_id
                              , 0 -- vl_base_calc_icms
                              , 0 -- vl_imp_trib_icms
                              , 0 -- vl_base_calc_st
                              , 0 -- vl_imp_trib_st
                              , 0 -- vl_total_item
                              , 0 -- vl_frete
                              , 0 -- vl_seguro
                              , 0 -- vl_desconto
                              , 0 -- vl_imp_trib_ii
                              , 0 -- vl_imp_trib_ipi
                              , 0 -- vl_imp_trib_pis
                              , 0 -- vl_imp_trib_cofins
                              , 0 -- vl_outra_despesas
                              , 0 -- vl_total_nf
                              , 0 -- vl_serv_nao_trib
                              , 0 -- vl_base_calc_iss
                              , 0 -- vl_imp_trib_iss
                              , 0 -- vl_pis_iss
                              , 0 -- vl_cofins_iss
                              , 0 -- vl_ret_pis
                              , 0 -- vl_ret_cofins
                              , 0 -- vl_ret_csll
                              , 0 -- vl_base_calc_irrf
                              , 0 -- vl_ret_irrf
                              , 0 -- vl_base_calc_ret_prev
                              , 0 -- vl_ret_prev
                              , 0 -- vl_total_serv
                              , 0 -- vl_abat_nt
                              , 0 -- vl_forn
                              , 0 -- vl_terc
                              , 0 -- vl_servico
                              , 0 -- vl_pis_st
                              , 0 -- vl_cofins_st
                              );
            -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (limpa)
            pk_csf_api.gv_objeto := 'pk_csf_api';
            pk_csf_api.gn_fase   := null;
            --
            vn_fase := 18;
            -- registra o log
            vv_msg := 'NFe criada a partir da consulta da Situação na Sefaz';
            --
            gn_referencia_id  := vn_notafiscal_id;
            gv_obj_referencia := 'NOTA_FISCAL';
            --
            pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                     , ev_mensagem         => 'Chave de acesso: ' || rec.chnfe
                                     , ev_resumo           => vv_msg
                                     , en_tipo_log         => CONS_SIT_NFE_SEFAZ );
            --
            vn_fase := 19;
            --
            vv_msg := 'Consulta da NFe na Sefaz, com a situação '||pk_csf.fkg_dominio( ev_dominio => 'CSF_CONS_SIT.DM_SITUACAO'
                                                                                  , ev_vl      => rec.dm_situacao );
            --
            vn_fase := 20;
            --
            if rec.dm_rec_fisico = 1 then -- Sim, recebimento fisico da DANFE
               --
               vv_msg := vv_msg||', havendo o recebimento físico da DANFE';
               --
            end if;
            --
            gn_referencia_id  := vn_notafiscal_id;
            gv_obj_referencia := 'NOTA_FISCAL';
            --
            pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                     , ev_mensagem         => 'Chave de acesso: ' || rec.chnfe
                                     , ev_resumo           => vv_msg
                                     , en_tipo_log         => cons_sit_nfe_sefaz );
            --
         exception
            when others then
               null;
         end;
         --
      end if;
      --
      vn_fase := 21;
      --
      vn_dm_reg_co_mde_aut := pk_csf.fkg_empresa_reg_co_mde_aut ( en_empresa_id => rec.empresa_id );
      --
      vd_hr_evento := NEW_TIME(systimestamp,'GMT', 'ADT');
      --
      if vd_hr_evento < rec.dhrecbto then
         --
         vd_hr_evento := rec.dhrecbto;
         --
      end if;
      --
      vn_fase := 21.1;
      --
      begin
         --
         select dm_ind_emit into vn_dm_ind_emit
           from nota_fiscal
          where id = vn_notafiscal_id;
         --
      exception
         when others then
            vn_dm_ind_emit := 0;
      end;
      --
      if nvl(vn_dm_reg_co_mde_aut,0) = 1 -- Sim regista a Ciencia da operação
         and vn_dm_ind_emit = 1 -- Terceiros
         then
         --
         vn_qtde_ciencia_mde   := 0;
         vn_tipoeventosefaz_id := pk_csf.fkg_tipoeventosefaz_id( '210210' );
         --
         begin
            --
            select count(1)
              into vn_qtde_ciencia_mde
              from nota_fiscal_mde
             where notafiscal_id       = vn_notafiscal_id
               and dm_situacao         in (0, 1, 2, 3)
               and tipoeventosefaz_id  = vn_tipoeventosefaz_id;
            --
         exception
            when others then
               vn_qtde_ciencia_mde := 0;
         end;
         --
         if nvl(vn_qtde_ciencia_mde,0) <= 0 then
            --
            begin
               --
               if not fkg_ck_nota_fiscal_mde_registr(vn_notafiscal_id, vn_tipoeventosefaz_id) then
                  --
                  insert into nota_fiscal_mde ( id
                                              , notafiscal_id
                                              , dm_situacao
                                              , dt_hr_evento
                                              , tipoeventosefaz_id
                                              , dm_tipo_integra
                                              )
                                       values ( notafiscalmde_seq.nextval -- id
                                              , vn_notafiscal_id          -- notafiscal_id
                                              , 0                         -- dm_situacao
                                              , vd_hr_evento              -- dt_hr_evento
                                              , vn_tipoeventosefaz_id     -- tipoeventosefaz_id
                                              , 0 -- Tipo de integração do evento. (0-Gerado automático pela aplicação/1-Manualmente no portal/2-Integração Webservice)
                                              );
               --
               end if;
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
      commit;
      --
   end loop;
   --
   vn_fase := 22;
   --
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 22.1;
      --
      begin
         --
         select a.dm_situacao
           into vn_dm_situacao
           from csf_cons_sit a
          where a.id in ( select max(b.id)
                            from csf_cons_sit b
                           where b.notafiscal_id = rec.id
                             and b.dm_situacao <> 1 );
         --
      exception
         when others then
            vn_dm_situacao := 0;
      end;
      --
      vn_fase := 22.2;
      --
      if nvl(vn_dm_situacao,0) <> 0 then
         --
         vn_fase := 23;
         --
         vn_dm_st_proc := case
                             when vn_dm_situacao = 2 then 4 -- Autorizado o uso da NF-e (100)
                             when vn_dm_situacao = 3 then 7 -- Cancelamento da NF-e Homologado (101)
                             when vn_dm_situacao = 4 then 6 -- Uso denegado (110)
                             when vn_dm_situacao = 5 then 5 -- Rejeitada
                             when vn_dm_situacao = 6 then 5 -- Rejeitada
                          else 0
                          end;
         --
         vn_fase := 23.1;
         --
         -- Variavel global usada em logs de triggers (carrega)
         gv_objeto := 'pk_csf_api.pkb_relac_nfe_cons_sit';
         gn_fase   := vn_fase;
         --
         update nota_fiscal
            set dm_st_proc     = vn_dm_st_proc
              , dm_ret_nf_erp  = 0
          where id = rec.id
            and dm_st_proc <> vn_dm_st_proc;
         --
         -- Variavel global usada em logs de triggers (limpa)
         gv_objeto := 'pk_csf_api';
         gn_fase   := null;
         --
      end if;
      --
      vn_fase := 24;
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem := 'Erro na pkb_relac_nfe_cons_sit fase('||vn_fase||') id ('||vn_csfconssit_id||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         --
         gv_obj_referencia := 'NOTA_FISCAL';
         --
         pkb_log_generico_conssit ( sn_loggenericonf_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_mensagem
                                  , en_tipo_log         => erro_de_validacao );
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem);
      --
END pkb_relac_nfe_cons_sit;
--
-- ====================================================================================================================== --
-- Procedimento de atualização da tabela CT_CONS_SIT
-- ====================================================================================================================== --
procedure pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit in out nocopy ct_cons_sit%rowtype
                                  , ev_campo_atu        in varchar2
                                  , en_tp_rotina        in number
                                  , ev_rotina_orig      in varchar2
                                  ) is
   --
   vn_id_existe number;
   --
begin
   if en_tp_rotina = 0 then -- Atualização
      --
      gn_referencia_id := est_row_ct_cons_sit.id;
      --
      -- Identifica qual campo será atualizado
      if upper(ev_campo_atu) = 'CONHECTRANSP_ID' and ev_rotina_orig = 'pk_csf_api_ct.pkb_excluir_dados_ct' then
         --
         update ct_cons_sit
            set conhectransp_id = null
          where conhectransp_id = est_row_ct_cons_sit.conhectransp_id;
         --
      elsif upper(ev_campo_atu) = 'CONHECTRANSP_ID' and ev_rotina_orig = 'pk_csf_api_ct.pkb_relac_cte_cons_sit' then
         --
         update ct_cons_sit
            set conhectransp_id = est_row_ct_cons_sit.conhectransp_id
          where id = est_row_ct_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_SITUACAO' then
         --
         update ct_cons_sit
            set dm_situacao = est_row_ct_cons_sit.dm_situacao
          where id = est_row_ct_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_INTEGR_ERP' then
         --
         update ct_cons_sit
            set dm_integr_erp = est_row_ct_cons_sit.dm_integr_erp
          where id = est_row_ct_cons_sit.id;
         --
      elsif upper(ev_campo_atu) = 'DM_ST_INTEGRA' then
         --
         update ct_cons_sit
            set dm_st_integra = est_row_ct_cons_sit.dm_st_integra
          where conhectransp_id = est_row_ct_cons_sit.conhectransp_id;
         --
      end if;
      --
   elsif en_tp_rotina = 1 then-- Inserção
      --
      -- Validar se existe a mesma chave em outro registro com DM_SITUACAO IN (0,1)
      -- Se existir não insere novamente
      -- =============================================================================
      begin
         select max(id)
           into vn_id_existe
           from ct_cons_sit
          where nro_chave_cte = est_row_ct_cons_sit.nro_chave_cte
            and dm_situacao   in (0,1);
      exception
         when no_data_found then
            vn_id_existe         := null;
      end;
      --
      gn_referencia_id := est_row_ct_cons_sit.id;      
      --
      if nvl(vn_id_existe,0) = 0 then
         --        
         begin
            select ctconssit_seq.nextval
              into est_row_ct_cons_sit.id
              from dual;
         exception
            when others then
               est_row_ct_cons_sit.id := null;
         end;
         --
         gn_referencia_id := est_row_ct_cons_sit.id;
         --            
      insert into ct_cons_sit (	id
                              ,	empresa_id
                              ,	conhectransp_id
                              ,	dm_tp_cons
                              ,	dm_tp_amb
                              ,	nro_chave_cte
                              ,	dt_hr_cons_sit
                              ,	dm_situacao
                              ,	cte_proc_xml
                              ,	usuario_id
                              ,	versao
                              ,	veraplic
                              ,	msgwebserv_id
                              ,	cstat
                              ,	xmotivo
                              ,	cuf
                              ,	dhrecbto
                              ,	nprot
                              ,	digval
                              ,	ret_cons_sit_cte_xml
                              ,	c_ref_cte
                              ,	c_serie
                              ,	c_nct
                              ,	c_dhemi
                              ,	c_cnpj_emit
                              ,	c_vt_prest
                              ,	c_cst
                              ,	c_p_icms
                              ,	c_v_icms
                              ,	c_v_bc
                              ,	dm_rec_fisico
                              ,	dm_integr_erp
                              ,	dm_st_integra
                              )
	                        values ( est_row_ct_cons_sit.id
                              ,	est_row_ct_cons_sit.empresa_id
                              ,	est_row_ct_cons_sit.conhectransp_id
                              ,	est_row_ct_cons_sit.dm_tp_cons
                              ,	est_row_ct_cons_sit.dm_tp_amb
                              ,	est_row_ct_cons_sit.nro_chave_cte
                              ,	est_row_ct_cons_sit.dt_hr_cons_sit
                              ,	est_row_ct_cons_sit.dm_situacao
                              ,	est_row_ct_cons_sit.cte_proc_xml
                              ,	est_row_ct_cons_sit.usuario_id
                              ,	est_row_ct_cons_sit.versao
                              ,	est_row_ct_cons_sit.veraplic
                              ,	est_row_ct_cons_sit.msgwebserv_id
                              ,	est_row_ct_cons_sit.cstat
                              ,	est_row_ct_cons_sit.xmotivo
                              ,	est_row_ct_cons_sit.cuf
                              ,	est_row_ct_cons_sit.dhrecbto
                              ,	est_row_ct_cons_sit.nprot
                              ,	est_row_ct_cons_sit.digval
                              ,	est_row_ct_cons_sit.ret_cons_sit_cte_xml
                              ,	est_row_ct_cons_sit.c_ref_cte
                              ,	est_row_ct_cons_sit.c_serie
                              ,	est_row_ct_cons_sit.c_nct
                              ,	est_row_ct_cons_sit.c_dhemi
                              ,	est_row_ct_cons_sit.c_cnpj_emit
                              ,	est_row_ct_cons_sit.c_vt_prest
                              ,	est_row_ct_cons_sit.c_cst
                              ,	est_row_ct_cons_sit.c_p_icms
                              ,	est_row_ct_cons_sit.c_v_icms
                              ,	est_row_ct_cons_sit.c_v_bc
                              , nvl(est_row_ct_cons_sit.dm_rec_fisico,0)
                              , nvl(est_row_ct_cons_sit.dm_integr_erp,0)
                              , nvl(est_row_ct_cons_sit.dm_st_integra,0)							  
                              );
      --
   end if;
   --
   end if;
   --
exception
   when others then
      --
      rollback;
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit : '||sqlerrm;
      gv_resumo   := 'Rotina que chamou a pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit : '||ev_rotina_orig;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id);
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem);
      --
end pkb_ins_atu_ct_cons_sit;
--
-- ====================================================================================================================== --
-- Procedimento de validação dos dados da chave da ct
-- ====================================================================================================================== --
procedure pkb_valid_ct_cons_sit ( est_log_generico_ct in out nocopy  dbms_sql.number_table
                                , est_row_ct_cons_sit in out nocopy  ct_cons_sit%rowtype
                                , en_multorg_id       in             mult_org.id%type
                                , ev_rotina           in             varchar2 default null -- rotina que chamou esse processo
                                ) is
   --
   vn_fase              number;
   vn_loggenerico_id    log_generico_ct.id%type;
   vn_dig_verif_chave   conhec_transp.dig_verif_chave%type;
   --
begin
   --
   vn_fase := 1;
   --   
   gn_referencia_id := est_row_ct_cons_sit.id;
   --      
   vn_fase := 2;
   --
   -- Verifica se valor da chave não é nulo
   -- =====================================
   if trim(est_row_ct_cons_sit.nro_chave_cte) is not null then
      --
      vn_fase := 2.1;
      --
      -- Valida se a Chave de Acesso contêm 44 digitos
      -- =============================================
      if length(trim(est_row_ct_cons_sit.nro_chave_cte)) <> 44 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso deve conter 44 dígitos';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_ct_cons_sit. '||
                      'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
         --
      end if;
      --
      vn_fase := 2.3;
      --
      -- Valida digito verificador da chave
      -- ==================================
      -- Valida o digito verificador da Chave de Acesso
      vn_dig_verif_chave := pk_csf.fkg_mod_11 ( ev_codigo => substr(trim(est_row_ct_cons_sit.nro_chave_cte), 1,43) );
      --
      vn_fase := 2.4;
      --
      if nvl(vn_dig_verif_chave,0) <> to_number( substr(trim(est_row_ct_cons_sit.nro_chave_cte), 44,1) ) then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso inválida';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_ct_cons_sit. '||
                      'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
         --
      end if;
      --
      --Validar 2 primeiros dígitos da chave - devem ter um valor valido em ESTADO.IBGE_ESTADO
      -- ======================================================================================
      if nvl(pk_csf.fkg_Estado_ibge_id (substr(est_row_ct_cons_sit.nro_chave_cte,1,2)),0) = 0 then
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Código da UF contido na Chave está inválido';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_ct_cons_sit. '||
                      'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
         --
      end if;
      --
      -- Validar se os dígitos que representam o ano e mês de emissão não são mais antigos que 6 meses
      -- =============================================================================================
      if to_date(sysdate,'dd/mm/yyyy') - to_date(est_row_ct_cons_sit.dt_hr_cons_sit,'dd/mm/yyyy') > 210 then -- 7 meses para garantir
         --
         vn_fase := 2.2;
         --
         gv_mensagem := 'Chave de acesso é muito antiga. SEFAZ permite consulta apenas para notas emitidas nos ultimos 180 dias';
         --
         gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_valid_ct_cons_sit. '||
                      'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                      'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_validacao
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
         --
      end if;
      --
      end if;
      --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_valid_ct_cons_sit fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ct.id%type;
      begin
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_resumo
                                     , en_tipo_log         => erro_de_sistema
                                     , en_empresa_id       => est_row_ct_cons_sit.empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
      exception
         when others then
            null;
      end;
   --
end pkb_valid_ct_cons_sit;
--
-- ====================================================================================================================== --
-- Procedimento de integração de consulta chave ct
-- ====================================================================================================================== --
procedure pkb_integr_ct_cons_sit ( est_log_generico_ct in out nocopy  dbms_sql.number_table
                                 , est_row_ct_cons_sit in out nocopy  ct_cons_sit%rowtype
                                 , ev_cpf_cnpj_emit    in             varchar2
                                 , en_multorg_id       in             mult_org.id%type
                                 , ev_rotina           in             varchar2 default null -- rotina que chamou esse processo
                                 ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ct.id%type;
   vn_empresa_id      empresa.id%type;
   gv_resumo          log_generico_ct.resumo%type;
   gv_mensagem        ct_cons_sit.xmotivo%type := null;
   vn_dm_tp_amb       empresa.dm_tp_amb%type;
   --
begin
   --
   vn_fase := 1;
   --
   --est_log_generico_nf := null;
   --
   vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                        , ev_cpf_cnpj   => ev_cpf_cnpj_emit );
   --
   vn_fase := 1.1;
   --
   if nvl(vn_empresa_id,0) <= 0 then
      --
      vn_fase := 1.2;
      --
      gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_integr_ct_cons_sit. '||
                   'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                   'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
      --
      gv_mensagem := 'Empresa não encontrada. CNPJ(' || ev_cpf_cnpj_emit || ').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                                  , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                     , est_log_generico_ct => est_log_generico_ct );
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Valida se tem valor para a chave
   if trim(est_row_ct_cons_sit.nro_chave_cte) is null then
      --
      gv_resumo := 'Erro de validação gerado pela rotina pk_csf_api_cons_sit.pkb_integr_ct_cons_sit. '||
                   'Chave('||est_row_ct_cons_sit.nro_chave_cte||'). '||
                   'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')';
      --
      gv_mensagem := 'Não foi informada a chave de acesso da NFe.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                  , ev_mensagem         => gv_mensagem
                                  , ev_resumo           => gv_resumo
                                  , en_tipo_log         => erro_de_validacao
                                  , en_empresa_id       => vn_empresa_id );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                     , est_log_generico_ct => est_log_generico_ct );
      --
   elsif trim(est_row_ct_cons_sit.nro_chave_cte) is not null then
      --
      vn_fase := 3;
      --
      -- Recupera o tipo de ambiente da empresa
      vn_dm_tp_amb := pk_csf.fkg_tp_amb_empresa ( en_empresa_id => vn_empresa_id );
      --
      vn_fase := 5;
      --
      begin
         -- Chama rotina que atualiza ou insere a tabela ct_cons_sit
         --
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.id               :=  null;-- id
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.empresa_id       :=  vn_empresa_id;                           -- empresa_id
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_tp_cons       :=  6;                                       -- dm_tp_cons -- Automática através de integração table/view
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_tp_amb        :=  vn_dm_tp_amb;                            -- tpamb
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.nro_chave_cte    :=  trim(est_row_ct_cons_sit.nro_chave_cte); --nro_chave_cte
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.dt_hr_cons_sit   :=  sysdate;                                 -- dt_hr_cons_sit
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_situacao      :=  0;                                       -- dm_situacao
         pk_csf_api_cons_sit.gt_row_ct_cons_sit.xmotivo          :=  gv_mensagem;
         --
         pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit => pk_csf_api_cons_sit.gt_row_ct_cons_sit
                                                     , ev_campo_atu        => null
                                                     , en_tp_rotina        => 1 -- inserção
                                                     , ev_rotina_orig      => 'pk_csf_api_cons_sit.pkb_integr_ct_cons_sit'
                                                     );
          --
          -- Chama a rotina de validacao da Chave de Acesso
          -- ==============================================
          pkb_valid_ct_cons_sit ( est_log_generico_ct => est_log_generico_ct
                                , est_row_ct_cons_sit => pk_csf_api_cons_sit.gt_row_ct_cons_sit
                                , en_multorg_id       => null
                                , ev_rotina           => 'pk_csf_api_cons_sit.pkb_integr_ct_cons_sit'
                                );
          --
          vn_fase := 6;
          --
          if nvl(est_log_generico_ct.count,0) > 0 then
             --
             -- Chama rotina que atualiza a tabela ct_cons_sit
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.empresa_id    := vn_empresa_id;
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_situacao   := 7;
             --
             pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit => pk_csf_api_cons_sit.gt_row_ct_cons_sit
                                                         , ev_campo_atu        => 'dm_situacao'
                                                         , en_tp_rotina        => 0 -- atualização
                                                         , ev_rotina_orig      => 'pk_csf_api_cons_sit.pkb_integr_ct_cons_sit'
                                                         );
             --
          else
             --
             -- Chama rotina que atualiza a tabela ct_cons_sit
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.empresa_id    := vn_empresa_id;
             pk_csf_api_cons_sit.gt_row_ct_cons_sit.dm_situacao   := 1;
             --
             pk_csf_api_cons_sit.pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit => pk_csf_api_cons_sit.gt_row_ct_cons_sit
                                                         , ev_campo_atu        => 'dm_situacao'
                                                         , en_tp_rotina        => 0 -- atualização
                                                         , ev_rotina_orig      => 'pk_csf_api_cons_sit.pkb_integr_ct_cons_sit'
                                                         );
             --
          end if;
          --
          commit;
          --
      exception
         when others then
            pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                        , ev_mensagem         => 'Erro ao tentar inserir/atualizar os dados na tabela ct_cons_sit'
                                        , ev_resumo           => 'Fase('||vn_fase||'). Rotina origem:('||nvl(ev_rotina,'NÃO INFORMADA')||')Erro('||sqlerrm||')'
                                        , en_tipo_log         => erro_de_sistema
                                        , en_empresa_id       => null );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                           , est_log_generico_ct => est_log_generico_ct );
      end;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem := 'Erro na pk_csf_api_cons_sit.pkb_integr_ct_cons_sit fase('||vn_fase||'). Erro: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_conssit_ct ( sn_loggenericoct_id => vn_loggenerico_id
                                     , ev_mensagem         => gv_mensagem
                                     , ev_resumo           => gv_mensagem
                                     , en_tipo_log         => erro_de_sistema
                                     , en_empresa_id       => vn_empresa_id );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_conssit_ct ( en_loggenericoct_id => vn_loggenerico_id
                                        , est_log_generico_ct => est_log_generico_ct );
      exception
         when others then
            null;
      end;
   --
END pkb_integr_ct_cons_sit;
--
-- ====================================================================================================================== --
--
end pk_csf_api_cons_sit;
/
