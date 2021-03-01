create or replace package body csf_own.pk_csf_api_dirf is

-------------------------------------------------------------------------------------------------------
--| Corpo do pacote de procedimentos de integração e validação da Dirf
-------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Procedimento seta o tipo de integração que será feito                    --
-- 0 - Somente valida os dados e registra o Log de ocorrência               --
-- 1 - Valida os dados e registra o Log de ocorrência e insere a informação --
-- Todos os procedimentos de integração fazem referência a ele              --
------------------------------------------------------------------------------
PROCEDURE PKB_SETA_TIPO_INTEGR ( EN_TIPO_INTEGR IN NUMBER
                               )
IS
BEGIN
   --
   gn_tipo_integr := en_tipo_integr;
   --
END PKB_SETA_TIPO_INTEGR;
-------------------------------------------------------------------------------------------------------
-- Procedimento seta o objeto de referencia utilizado na Validação da Informação
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_SETA_OBJ_REF ( EV_OBJETO IN VARCHAR2
                           )
IS
BEGIN
   --
   gv_obj_referencia := upper(ev_objeto);
   --
END PKB_SETA_OBJ_REF;
-------------------------------------------------------------------------------------------------------
-- Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_SETA_REFERENCIA_ID ( EN_ID IN NUMBER
                                 )
IS
BEGIN
   --
   gn_referencia_id := en_id;
   --
END PKB_SETA_REFERENCIA_ID;
-------------------------------------------------------------------------------------------------------
-- Procedimento armazena o valor do "loggenerico_id" da nota fiscal
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_GT_LOG_GENERICO_IRD ( EN_LOGGENERICOIRD_ID  IN            LOG_GENERICO_IRD.ID%TYPE
                                  , EST_LOG_GENERICO_IRD  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                  )
IS
   --
   i pls_integer;
   --
BEGIN
   --
   if nvl(en_loggenericoird_id,0) > 0 then
      --
      i := nvl(est_log_generico_ird.count,0) + 1;
      --
      est_log_generico_ird(i) := en_loggenericoird_id;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_dirf.pkb_gt_log_generico_ird: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%type;
      begin
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_cabec_log
                              , ev_resumo            => gv_mensagem_log
                              , en_tipo_log          => erro_de_sistema );
      exception
         when others then
            null;
      end;
      --
END PKB_GT_LOG_GENERICO_IRD;
-------------------------------------------------------------------------------------------------------
-- Procedimento finaliza o Log Genérico
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_FINALIZA_LOG_GENERICO_IRD
IS
BEGIN
   --
   gn_processo_id := null;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_dirf..pkb_finaliza_log_generico_ird: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%type;
      begin
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_cabec_log
                              , ev_resumo            => gv_mensagem_log
                              , en_tipo_log          => erro_de_sistema );
      exception
         when others then
            null;
      end;
      --
END PKB_FINALIZA_LOG_GENERICO_IRD;
-------------------------------------------------------------------------------------------------------
-- Procedimento de registro de log de erros na validação da nota fiscal
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_LOG_GENERICO_IRD ( SN_LOGGENERICOIRD_ID    OUT NOCOPY LOG_GENERICO_IRD.ID%TYPE
                               , EV_MENSAGEM          IN            LOG_GENERICO_IRD.MENSAGEM%TYPE
                               , EV_RESUMO            IN            LOG_GENERICO_IRD.RESUMO%TYPE
                               , EN_TIPO_LOG          IN            CSF_TIPO_LOG.CD_COMPAT%TYPE          DEFAULT 1
                               , EN_REFERENCIA_ID     IN            LOG_GENERICO_IRD.REFERENCIA_ID%TYPE  DEFAULT NULL
                               , EV_OBJ_REFERENCIA    IN            LOG_GENERICO_IRD.OBJ_REFERENCIA%TYPE DEFAULT NULL
                               , EN_EMPRESA_ID        IN            EMPRESA.ID%TYPE                      DEFAULT NULL
                               , EN_DM_IMPRESSA       IN            LOG_GENERICO_IRD.DM_IMPRESSA%TYPE    DEFAULT 0
                               )
IS
   --
   vn_fase          number := 0;
   vn_empresa_id    empresa.id%type;
   vn_csftipolog_id csf_tipo_log.id%type := null;
   pragma           autonomous_transaction;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(gn_processo_id,0) = 0 then
      select processo_seq.nextval
        into gn_processo_id
        from dual;
   end if;
   --
   vn_empresa_id := nvl(en_empresa_id, gn_empresa_id);
   --
   if nvl(en_tipo_log,0) > 0 and ev_mensagem is not null then
      --
      vn_fase := 2;
      --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericoird_seq.nextval
        into sn_loggenericoird_id
        from dual;
      --
      vn_fase := 4;
      --
      insert into log_generico_ird ( id
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
                            values ( sn_loggenericoird_id  -- Valor de cada log de validação
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
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_dirf.pkb_log_generico_ird fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%type;
      begin
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_cabec_log
                              , ev_resumo            => gv_mensagem_log
                              , en_tipo_log          => erro_de_sistema );
      exception
         when others then
            null;
      end;
      --
END PKB_LOG_GENERICO_IRD;
-------------------------------------------------------------------------------------------------------
--| Procedimento excluir dados de integracao DIRF
-------------------------------------------------------------------------------------------------------
procedure pkb_excluir_inf_rend ( est_log_generico_ird in out nocopy  dbms_sql.number_table
                               , en_infrenddirf_id    in             inf_rend_dirf.id%type
                               )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ird.id%type;
   pragma             autonomous_transaction;
   --
begin
   --
   vn_fase := 1;
   --
   delete from inf_rend_dirf_anual where infrenddirf_id = en_infrenddirf_id;
   --
   vn_fase := 2;
   --
   delete from inf_rend_dirf_mensal where infrenddirf_id = en_infrenddirf_id;
   --
   vn_fase := 3;
   --
   delete from inf_rend_dirf_pse where infrenddirf_id = en_infrenddirf_id;
   --
   vn_fase := 4;
   --
   delete from inf_rend_dirf_pdf where infrenddirf_id = en_infrenddirf_id;
   --
   vn_fase := 5;
   --
   delete from inf_rend_dirf_rpde where infrenddirf_id = en_infrenddirf_id;
   --
   vn_fase := 6;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_excluir_inf_rend fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%TYPE;
      begin
         --
          pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                               , ev_mensagem          => gv_cabec_log
                               , ev_resumo            => gv_mensagem_log
                               , en_tipo_log          => erro_de_sistema
                               , en_referencia_id     => gn_referencia_id
                               , ev_obj_referencia    => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na memória
          pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                  , est_log_generico_ird => est_log_generico_ird );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_excluir_inf_rend;
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração do Relaciomento da Geração do Informe de rendimentos
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_r_gera_infrenddirf ( est_log_generico_ird      in out nocopy  dbms_sql.number_table
                                        , est_r_gera_inf_rend_dirf  in out nocopy  r_gera_inf_rend_dirf%rowtype
                                        )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ird.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(est_r_gera_inf_rend_dirf.id,0) <= 0 then
      --
      select rgerainfrenddirf_seq.nextval
        into est_r_gera_inf_rend_dirf.id
        from dual;
      --
   end if;
   --
   vn_fase := 2;
   --
   if nvl(est_r_gera_inf_rend_dirf.gerainfrenddirf_id,0) <= 0 then
      --
      vn_fase := 2.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Sem informação de geração.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_r_gera_inf_rend_dirf.infrenddirf_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'Sem informação de Rendimento da DIRF.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_r_gera_inf_rend_dirf.gerainfrenddirf_id,0) > 0
      and nvl(est_r_gera_inf_rend_dirf.infrenddirf_id,0) > 0
      then
      --
      vn_fase := 99.1;
      --
      if pk_csf_dirf.fkg_existe_r_gera_infrenddirf ( en_rgerainfrenddirf_id => est_r_gera_inf_rend_dirf.id ) then
         --
         vn_fase := 99.2;
         --
         update r_gera_inf_rend_dirf set gerainfrenddirf_id = est_r_gera_inf_rend_dirf.gerainfrenddirf_id
                                       , infrenddirf_id     = est_r_gera_inf_rend_dirf.infrenddirf_id
          where id = est_r_gera_inf_rend_dirf.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into r_gera_inf_rend_dirf ( id
                                          , gerainfrenddirf_id
                                          , infrenddirf_id
                                          )
                                   values ( est_r_gera_inf_rend_dirf.id
                                          , est_r_gera_inf_rend_dirf.gerainfrenddirf_id
                                          , est_r_gera_inf_rend_dirf.infrenddirf_id
                                          );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := gv_cabec_log_item||'Erro na pk_csf_api_dirf.pkb_integr_r_gera_infrenddirf fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%TYPE;
      begin
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => null
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_r_gera_infrenddirf;
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração de informação de Plano de Saúde
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_inf_rend_dirf_pse ( est_log_generico_ird   in out nocopy  dbms_sql.number_table
                                       , est_inf_rend_dirf_pse  in out nocopy  inf_rend_dirf_pse%rowtype
                                       , ev_cod_part_pse        in             varchar2
                                       , en_multorg_id          in             mult_org.id%type
                                       )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ird.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_cabec_log_item := 'Dependente: '||est_inf_rend_dirf_pse.nome||' ';
   --
   vn_fase := 2;
   --
   if nvl(est_inf_rend_dirf_pse.id,0) <= 0 then
      --
      select infrenddirfpse_seq.nextval
        into est_inf_rend_dirf_pse.id
        from dual;
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_inf_rend_dirf_pse.infrenddirf_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Id Dirf" inválido.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_sistema
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_inf_rend_dirf_pse.vl_pago,0) < 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor Pago" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_inf_rend_dirf_pse.pessoa_id_pse := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                                        , ev_cod_part   => trim(ev_cod_part_pse) );
   --
   vn_fase := 6;
   --
   if nvl(est_inf_rend_dirf_pse.pessoa_id_pse,0) < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Código do Plano de Saúde" inválido ('||ev_cod_part_pse||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 7;
   --
   -- valida se CNPJ é numerico caso ele seja informado.
   --
   if trim(est_inf_rend_dirf_pse.cpf) is not null
      and pk_csf.fkg_is_numerico ( ev_valor => est_inf_rend_dirf_pse.cpf ) = false then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := gv_cabec_log_item||'O "CPF do dependente da Nota Fiscal" ('||est_inf_rend_dirf_pse.cpf||
                         ') deve conter somente números considerando os zeros à esquerda.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 8;
   --
   -- Valida o CPF
   --
   if trim(est_inf_rend_dirf_pse.cpf) is not null
      and pk_csf.fkg_is_numerico ( ev_valor =>  est_inf_rend_dirf_pse.cpf ) = true
      and nvl(pk_valida_docto.fkg_valida_cpf_cgc(ev_numero => est_inf_rend_dirf_pse.cpf), 0) = 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := gv_cabec_log_item||'O "CPF do destinatário da Nota Fiscal" ('||est_inf_rend_dirf_pse.cpf||') está inválido.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 9;
   --
   if est_inf_rend_dirf_pse.dt_nasc is null then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Data de nascimento do dependente" não pode ser nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 10;
   --
   est_inf_rend_dirf_pse.nome := trim(pk_csf.fkg_converte(est_inf_rend_dirf_pse.nome));
   --
   vn_fase := 11;
   --
   if est_inf_rend_dirf_pse.nome is null then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Nome do dependente" não pode ser nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 12;
   --
   if est_inf_rend_dirf_pse.dm_rel_dep not in ('00', '03', '04', '06', '08', '10') then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Código do dependente" inválido ('||est_inf_rend_dirf_pse.dm_rel_dep||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_inf_rend_dirf_pse.id,0) > 0
      and nvl(est_inf_rend_dirf_pse.infrenddirf_id,0) > 0
      and nvl(est_inf_rend_dirf_pse.pessoa_id_pse,0) > 0
      and est_inf_rend_dirf_pse.dt_nasc is not null
      and est_inf_rend_dirf_pse.nome is not null
      and est_inf_rend_dirf_pse.dm_rel_dep in ('00', '03', '04', '06', '08', '10')
      and nvl(est_inf_rend_dirf_pse.vl_pago,0) > 0
      then
      --
      vn_fase := 99.1;
      --
      if pk_csf_dirf.fkg_existe_inf_rend_dirf_pse ( en_infrenddirfpse_id => est_inf_rend_dirf_pse.id ) = true then
         --
         vn_fase := 99.2;
         --
          update inf_rend_dirf_pse set infrenddirf_id = est_inf_rend_dirf_pse.infrenddirf_id
                                     , pessoa_id_pse  = est_inf_rend_dirf_pse.pessoa_id_pse
                                     , cpf            = est_inf_rend_dirf_pse.cpf
                                     , dt_nasc        = est_inf_rend_dirf_pse.dt_nasc
                                     , nome           = est_inf_rend_dirf_pse.nome
                                     , dm_rel_dep     = est_inf_rend_dirf_pse.dm_rel_dep
                                     , vl_pago        = est_inf_rend_dirf_pse.vl_pago
          where id = est_inf_rend_dirf_pse.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into inf_rend_dirf_pse ( id
                                       , infrenddirf_id
                                       , pessoa_id_pse
                                       , cpf
                                       , dt_nasc
                                       , nome
                                       , dm_rel_dep
                                       , vl_pago
                                       )
                                values ( est_inf_rend_dirf_pse.id
                                       , est_inf_rend_dirf_pse.infrenddirf_id
                                       , est_inf_rend_dirf_pse.pessoa_id_pse
                                       , est_inf_rend_dirf_pse.cpf
                                       , est_inf_rend_dirf_pse.dt_nasc
                                       , est_inf_rend_dirf_pse.nome
                                       , est_inf_rend_dirf_pse.dm_rel_dep
                                       , est_inf_rend_dirf_pse.vl_pago
                                       );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := gv_cabec_log_item||'Erro na pk_csf_api_dirf.pkb_integr_inf_dirf_pse fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%TYPE;
      begin
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem        => gv_mensagem_log
                              , ev_resumo          => null
                              , en_tipo_log        => erro_de_sistema
                              , en_referencia_id   => gn_referencia_id
                              , ev_obj_referencia  => gv_obj_referencia
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_inf_rend_dirf_pse;
--
-------------------------------------------------------------------------------------------------------
--| Procedimento de integração de Rendimentos pagos a residentes ou domiciliados no exterior (RPDE)
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_inf_rend_dirf_rpde ( est_log_generico_ird   in out nocopy  dbms_sql.number_table
                                        , est_inf_rend_dirf_rpde in out nocopy  inf_rend_dirf_rpde%rowtype
                                        , ev_cod_part_rpde       in             varchar2
                                        , en_multorg_id          in             mult_org.id%type ) is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ird.id%type;
   vv_nome            pessoa.nome%type;
   vv_cod_nif         pessoa.cod_nif%type;
   vv_cod_part        pessoa.cod_part%type;
   vn_dm_obrig_nif    pais.dm_obrig_nif%type;
   --
begin
   --
   vn_fase := 1;
   --
   begin
      select p.nome
        into vv_nome
        from pessoa p
       where p.id = est_inf_rend_dirf_rpde.pessoa_id;
   exception
      when others then
         vv_nome := null;
   end;
   --
   gv_cabec_log_item := 'Residente no exterior: '||vv_nome||' ';
   --
   vn_fase := 2;
   --
   if nvl(est_inf_rend_dirf_rpde.id,0) <= 0 then
      --
      select infrenddirfrpde_seq.nextval
        into est_inf_rend_dirf_rpde.id
        from dual;
      --
   end if;
   --
   vn_fase := 3;
   --
   -- infrenddirf_id
   if nvl(est_inf_rend_dirf_rpde.infrenddirf_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Id Dirf" inválido.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_sistema
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 4;
   --
   -- vl_pago
   if nvl(est_inf_rend_dirf_rpde.vl_rend_pago,0) < 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor Pago" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_inf_rend_dirf_rpde.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                                     , ev_cod_part   => trim(ev_cod_part_rpde) );
   --
   if nvl(est_inf_rend_dirf_rpde.pessoa_id,0) < 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Código da pessoa no exterior" inválido ('||ev_cod_part_rpde||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_inf_rend_dirf_rpde.pessoa_id,0) > 0 then
      --
      vn_fase := 6.1;
      --
      begin
         select a.cod_nif
              , a.cod_part
              , b.dm_obrig_nif
           into vv_cod_nif
              , vv_cod_part
              , vn_dm_obrig_nif
           from pessoa   a
              , pais     b
          where b.id = a.pais_id
            and a.id = est_inf_rend_dirf_rpde.pessoa_id;
         --
         if nvl(vn_dm_obrig_nif,0) = 1 and nvl(vv_cod_nif,0) = 0 then
            --
            -- O país da pessoa exige o código NIF
            vn_fase := 6.2;
            --
            gv_mensagem_log := gv_cabec_log_item||'O "Código NIF" é obrigatório para o código do participante: ('||vv_cod_part||').';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                 , ev_mensagem          => gv_cabec_log
                                 , ev_resumo            => gv_mensagem_log
                                 , en_tipo_log          => erro_de_validacao
                                 , en_referencia_id     => gn_referencia_id
                                 , ev_obj_referencia    => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                    , est_log_generico_ird => est_log_generico_ird );
            --
         end if;
         --
      exception
         when no_data_found then
            --
            vn_fase := 6.3;
            --
            gv_mensagem_log := gv_cabec_log_item||'Não foi encontrado o participante e o país na verificação do "Código NIF".';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                 , ev_mensagem          => gv_cabec_log
                                 , ev_resumo            => gv_mensagem_log
                                 , en_tipo_log          => informacao
                                 , en_referencia_id     => gn_referencia_id
                                 , ev_obj_referencia    => gv_obj_referencia );
         --
      end;
      --
   end if;
   --
   vn_fase := 7;
   --
   -- data_pgto
   if est_inf_rend_dirf_rpde.data_pgto is null then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Data de pagamento" nula (Participante: '||ev_cod_part_rpde||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 8;
   --
   -- dm_tipo_rend
   if nvl(est_inf_rend_dirf_rpde.dm_tipo_rend,0) not in ('100', '110', '120', '130', '140', '150', '160', '170', '180', '190', '200', '210', '220', '230', '260', '270', '300') then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Tipo de rendimento" inválido (Participante: '||ev_cod_part_rpde||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 9;
   --
   -- dm_fonte_pag
   if nvl(est_inf_rend_dirf_rpde.dm_fonte_pag,0) not in ('500', '510', '520', '530', '540', '550', '560', '570', '900') then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Fonte pagadora" inválida (Participante: '||ev_cod_part_rpde||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 11;
   --
   -- dm_forma_trib
   if nvl(est_inf_rend_dirf_rpde.dm_forma_trib,0) not in ('10', '11', '12', '13', '30', '40', '41', '42', '43', '44', '50') then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Forma de tributação" inválido (Participante: '||ev_cod_part_rpde||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_inf_rend_dirf_rpde.id,0)                 > 0
      and nvl(est_inf_rend_dirf_rpde.infrenddirf_id,0) > 0
      and nvl(est_inf_rend_dirf_rpde.pessoa_id,0)      > 0
      and est_inf_rend_dirf_rpde.data_pgto             is not null
      and nvl(est_inf_rend_dirf_rpde.dm_tipo_rend,0)   in ('100', '110', '120', '130', '140', '150', '160', '170', '180', '190', '200', '210', '220', '230', '260', '270', '300')
      and nvl(est_inf_rend_dirf_rpde.dm_fonte_pag,0)   in ('500', '510', '520', '530', '540', '550', '560', '570', '900')
      and nvl(est_inf_rend_dirf_rpde.dm_forma_trib,0)  in ('10', '11', '12', '13', '30', '40', '41', '42', '43', '44', '50')
      and nvl(est_inf_rend_dirf_rpde.vl_rend_pago,0)   > 0
      then
      --
      vn_fase := 99.1;
      --
      if pk_csf_dirf.fkg_existe_inf_rend_dirf_rpde ( en_infrenddirfrpde_id => est_inf_rend_dirf_rpde.id ) = true then
         --
         vn_fase := 99.2;
         --
         update inf_rend_dirf_rpde set infrenddirf_id = est_inf_rend_dirf_rpde.infrenddirf_id
                                     , pessoa_id      = est_inf_rend_dirf_rpde.pessoa_id
                                     , dm_tipo_rend   = est_inf_rend_dirf_rpde.dm_tipo_rend
                                     , dm_fonte_pag   = est_inf_rend_dirf_rpde.dm_fonte_pag
                                     , dm_forma_trib  = est_inf_rend_dirf_rpde.dm_forma_trib
                                     , data_pgto      = est_inf_rend_dirf_rpde.data_pgto
                                     , vl_rend_pago   = est_inf_rend_dirf_rpde.vl_rend_pago
                                     , vl_imp_ret     = est_inf_rend_dirf_rpde.vl_imp_ret
         where id = est_inf_rend_dirf_rpde.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into inf_rend_dirf_rpde ( id
                                        , infrenddirf_id
                                        , pessoa_id
                                        , dm_tipo_rend
                                        , dm_fonte_pag
                                        , dm_forma_trib
                                        , data_pgto
                                        , vl_rend_pago
                                        , vl_imp_ret
                                        )
                                 values ( est_inf_rend_dirf_rpde.id
                                        , est_inf_rend_dirf_rpde.infrenddirf_id
                                        , est_inf_rend_dirf_rpde.pessoa_id
                                        , est_inf_rend_dirf_rpde.dm_tipo_rend
                                        , est_inf_rend_dirf_rpde.dm_fonte_pag
                                        , est_inf_rend_dirf_rpde.dm_forma_trib
                                        , est_inf_rend_dirf_rpde.data_pgto
                                        , est_inf_rend_dirf_rpde.vl_rend_pago
                                        , est_inf_rend_dirf_rpde.vl_imp_ret
                                        );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := gv_cabec_log_item||'Erro na pk_csf_api_dirf.pkb_integr_inf_dirf_rpde fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%TYPE;
      begin
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => null
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_inf_rend_dirf_rpde;

-------------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Informações de Rendimentos Anuais da DIRF
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_inf_rend_dirf_anual ( est_log_generico_ird     in out nocopy  dbms_sql.number_table
                                         , est_inf_rend_dirf_anual  in out nocopy  inf_rend_dirf_anual%rowtype
                                         , ev_cod_tipo_dirf         in             tipo_cod_dirf.cd%type
                                         )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ird.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   est_inf_rend_dirf_anual.tipocoddirf_id := pk_csf_dirf.fkg_retorna_id_cod_dirf(en_tipocoddirf_cd => ev_cod_tipo_dirf);
   --
   vn_fase := 1.1;
   --
   if nvl(est_inf_rend_dirf_anual.tipocoddirf_id,0) <= 0 then
      --
      vn_fase := 1.2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Tipo código da Dirf Anual" inválido ('||trim(ev_cod_tipo_dirf)||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   gv_cabec_log_item := 'Tipo código da Dirf: '||ev_cod_tipo_dirf||' ';
   --
   vn_fase := 2;
   --
   if nvl(est_inf_rend_dirf_anual.id,0) <= 0 then
      --
      select infrenddirfanual_seq.nextval
        into est_inf_rend_dirf_anual.id
        from dual;
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_inf_rend_dirf_anual.infrenddirf_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Id Dirf" inválido.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_sistema
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_inf_rend_dirf_anual.valor,0) < 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_inf_rend_dirf_anual.descr := trim(pk_csf.fkg_converte(est_inf_rend_dirf_anual.descr));
   --
   vn_fase := 99;
   --
   if nvl(est_inf_rend_dirf_anual.id,0) > 0
      and nvl(est_inf_rend_dirf_anual.infrenddirf_id,0) > 0
      and nvl(est_inf_rend_dirf_anual.tipocoddirf_id,0) > 0
      then
      --
      vn_fase := 99.1;
      --
      if pk_csf_dirf.fkg_existe_inf_rend_dirf_anual (en_infrenddirfanual_id => est_inf_rend_dirf_anual.id ) = true then
         --
         vn_fase := 99.2;
         --
          update inf_rend_dirf_anual set infrenddirf_id  = est_inf_rend_dirf_anual.infrenddirf_id
                                       , tipocoddirf_id  = est_inf_rend_dirf_anual.tipocoddirf_id
                                       , descr           = est_inf_rend_dirf_anual.descr
                                       , valor           = est_inf_rend_dirf_anual.valor
          where id = est_inf_rend_dirf_anual.id;

         --
      else
         --
         vn_fase := 99.3;
         --
         insert into inf_rend_dirf_anual ( id
                                         , infrenddirf_id
                                         , tipocoddirf_id
                                         , valor
                                         , descr
                                         )
                                  values ( est_inf_rend_dirf_anual.id
                                         , est_inf_rend_dirf_anual.infrenddirf_id
                                         , est_inf_rend_dirf_anual.tipocoddirf_id
                                         , est_inf_rend_dirf_anual.valor
                                         , est_inf_rend_dirf_anual.descr
                                             );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_dirf.pkb_integr_inf_dirf_anual fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%TYPE;
      begin
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => null
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_inf_rend_dirf_anual;
-------------------------------------------------------------------------------------------------------
-- Procedimento integra os dados de Informe de rendimentos da Dirf Mensal e Deduções dependente
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_inf_rend_dirf_mensa ( est_log_generico_ird      in out nocopy  dbms_sql.number_table
                                         , est_inf_rend_dirf_mensal  in out nocopy  inf_rend_dirf_mensal%rowtype
                                         , ev_cod_tipo_dirf          in tipo_cod_dirf.cd%type
                                         )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ird.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   --
   gv_cabec_log_item := 'Tipo código da Dirf: '||ev_cod_tipo_dirf||' ';
   --
   vn_fase := 1.1;
   --
   est_inf_rend_dirf_mensal.tipocoddirf_id := pk_csf_dirf.fkg_retorna_id_cod_dirf(en_tipocoddirf_cd => trim(ev_cod_tipo_dirf));
   --
   vn_fase := 2;
   --
   if nvl(est_inf_rend_dirf_mensal.id,0) <= 0 then
      --
      select infrenddirfmensal_seq.nextval
        into est_inf_rend_dirf_mensal.id
        from dual;
      --
   end if;
   --
   vn_fase := 3;
   --
   if nvl(est_inf_rend_dirf_mensal.infrenddirf_id,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Id Dirf" inválido.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_sistema
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_01,0) < 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor janeiro" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 5;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_02,0) < 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor fevereiro" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 6;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_03,0) < 0 then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor março" não pode ser negativo.';
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 7;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_04,0) < 0 then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor abril" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 8;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_05,0) < 0 then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor maio" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_06,0) < 0 then
      --
      vn_fase := 9.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor junho" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_07,0) < 0 then
      --
      vn_fase := 10.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor julho" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 11;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_08,0) < 0 then
      --
      vn_fase := 11.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor agosto" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 12;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_09,0) < 0 then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor setembro" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 13;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_10,0) < 0 then
      --
      vn_fase := 13.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor outubro" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 14;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_11,0) < 0 then
      --
      vn_fase := 14.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor novembro" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 15;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_12,0) < 0 then
      --
      vn_fase := 15.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor dezembro" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 16;
   --
   if nvl(est_inf_rend_dirf_mensal.vl_mes_13,0) < 0 then
      --
      vn_fase := 16.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := gv_cabec_log_item||'"Valor Décimo terceiro" não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 17;
   --
   if nvl(est_inf_rend_dirf_mensal.tipocoddirf_id,0) <= 0 then
      --
      vn_fase := 17.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Tipo código da Dirf Mensal" inválido ('||ev_cod_tipo_dirf||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_inf_rend_dirf_mensal.id,0) > 0
      and nvl(est_inf_rend_dirf_mensal.infrenddirf_id,0) > 0
      and nvl(est_inf_rend_dirf_mensal.tipocoddirf_id,0) > 0
      then
      --
      vn_fase := 99.1;
      --
      if pk_csf_dirf.fkg_existe_inf_rend_dirf_msl( en_infrenddirfmensal_id => est_inf_rend_dirf_mensal.id ) = true then
         --
         vn_fase := 99.2;
         --
          update inf_rend_dirf_mensal set   infrenddirf_id = est_inf_rend_dirf_mensal.infrenddirf_id
                                          , tipocoddirf_id = est_inf_rend_dirf_mensal.tipocoddirf_id
                                          , vl_mes_01 = est_inf_rend_dirf_mensal.vl_mes_01
                                          , vl_mes_02 = est_inf_rend_dirf_mensal.vl_mes_02
                                          , vl_mes_03 = est_inf_rend_dirf_mensal.vl_mes_03
                                          , vl_mes_04 = est_inf_rend_dirf_mensal.vl_mes_04
                                          , vl_mes_05 = est_inf_rend_dirf_mensal.vl_mes_05
                                          , vl_mes_06 = est_inf_rend_dirf_mensal.vl_mes_06
                                          , vl_mes_07 = est_inf_rend_dirf_mensal.vl_mes_07
                                          , vl_mes_08 = est_inf_rend_dirf_mensal.vl_mes_08
                                          , vl_mes_09 = est_inf_rend_dirf_mensal.vl_mes_09
                                          , vl_mes_10 = est_inf_rend_dirf_mensal.vl_mes_10
                                          , vl_mes_11 = est_inf_rend_dirf_mensal.vl_mes_11
                                          , vl_mes_12 = est_inf_rend_dirf_mensal.vl_mes_12
                                          , vl_mes_13 = est_inf_rend_dirf_mensal.vl_mes_13
          where id = est_inf_rend_dirf_mensal.id;
         --
      else
         --
         vn_fase := 99.3;
         --
          insert into inf_rend_dirf_mensal ( id
                                           , infrenddirf_id
                                           , tipocoddirf_id
                                           , vl_mes_01
                                           , vl_mes_02
                                           , vl_mes_03
                                           , vl_mes_04
                                           , vl_mes_05
                                           , vl_mes_06
                                           , vl_mes_07
                                           , vl_mes_08
                                           , vl_mes_09
                                           , vl_mes_10
                                           , vl_mes_11
                                           , vl_mes_12
                                           , vl_mes_13
                                           )
                                    values ( est_inf_rend_dirf_mensal.id
                                           , est_inf_rend_dirf_mensal.infrenddirf_id
                                           , est_inf_rend_dirf_mensal.tipocoddirf_id
                                           , est_inf_rend_dirf_mensal.vl_mes_01
                                           , est_inf_rend_dirf_mensal.vl_mes_02
                                           , est_inf_rend_dirf_mensal.vl_mes_03
                                           , est_inf_rend_dirf_mensal.vl_mes_04
                                           , est_inf_rend_dirf_mensal.vl_mes_05
                                           , est_inf_rend_dirf_mensal.vl_mes_06
                                           , est_inf_rend_dirf_mensal.vl_mes_07
                                           , est_inf_rend_dirf_mensal.vl_mes_08
                                           , est_inf_rend_dirf_mensal.vl_mes_09
                                           , est_inf_rend_dirf_mensal.vl_mes_10
                                           , est_inf_rend_dirf_mensal.vl_mes_11
                                           , est_inf_rend_dirf_mensal.vl_mes_12
                                           , est_inf_rend_dirf_mensal.vl_mes_13
                                           );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_dirf_mensa.pkb_integr_inf_dirf_mensa fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%TYPE;
      begin
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => null
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_inf_rend_dirf_mensa;
-------------------------------------------------------------------------------------------------------
-- Procedimento de Integração de Informação da DIRF
-------------------------------------------------------------------------------------------------------
procedure pkb_integr_inf_rend_dirf ( est_log_generico_ird in out nocopy  dbms_sql.number_table
                                   , est_inf_rend_dirf    in out nocopy  inf_rend_dirf%rowtype
                                   , ev_cpf_cnpj          in             varchar2
                                   , ev_cod_part          in             pessoa.cod_part%type
                                   , ev_cod_ret_imp       in             varchar2
                                   , en_multorg_id        in             mult_org.id%type
                                   , en_loteintws_id      in             lote_int_ws.id%type default 0
                                   )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico_ird.id%TYPE;
   vv_nro_lote        varchar2(30) := null;
   --
begin
   --
   vn_fase := 1;
   --
   est_inf_rend_dirf.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                                , ev_cod_part   => ev_cod_part );
   --
   vn_fase := 1.1;
   --
   est_inf_rend_dirf.empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj ( en_multorg_id => en_multorg_id
                                                                       , ev_cpf_cnpj   => ev_cpf_cnpj );
   --
   vn_fase := 1.2;
   --
   if nvl(en_loteintws_id,0) > 0 then
      vv_nro_lote := ' Lote WS: ' || en_loteintws_id;
   end if;
   --
   gv_cabec_log := 'Empresa: ' || ev_cpf_cnpj ||
                      ' Ano: ' || est_inf_rend_dirf.ano_ref ||
                      ' Código de Retenção: ' || ev_cod_ret_imp ||
                      ' Participante: ' || ev_cod_part || ' - ' || pk_csf.fkg_nome_pessoa_id ( en_pessoa_id => est_inf_rend_dirf.pessoa_id ) ||
                      ' Origem: ' || pk_csf.fkg_dominio('INF_REND_DIRF.DM_ORIGEM', est_inf_rend_dirf.dm_origem) ||
                      vv_nro_lote;
   --
   vn_fase := 2;
   --
   if nvl(est_inf_rend_dirf.id,0) <= 0 then
      --
      select infrenddirf_seq.nextval
        into est_inf_rend_dirf.id
        from dual;
      --
   end if;
   --
   gn_referencia_id := est_inf_rend_dirf.id;
   --gn_referencia_id := pk_gera_inf_rend_dirf.gt_row_gera_inf_rend_dirf.id;
   --
   vn_fase := 3;
   --
   if nvl(est_inf_rend_dirf.ano_ref,0) <= 0 then
      --
      vn_fase := 3.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Ano Referência" não pode ser nulo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );

      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 4;
   --
   if nvl(est_inf_rend_dirf.empresa_id,0) <= 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Empresa" inválida ('||ev_cpf_cnpj||').';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 5;
   --
   if est_inf_rend_dirf.dm_origem not in (1, 2) then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Origem" inválida ('||est_inf_rend_dirf.dm_origem||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 6;
   --
   if est_inf_rend_dirf.dm_tipo_lcto not in (1, 2, 3, 4, 5) then
      --
      vn_fase := 6.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Tipo de lançamento" inválido ('||est_inf_rend_dirf.dm_tipo_lcto||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 7;
   --
   if est_inf_rend_dirf.dm_situacao not in (0, 1, 2, 3) then
      --
      vn_fase := 7.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Situação" inválida ('||est_inf_rend_dirf.dm_situacao||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 8;
   --
   if est_inf_rend_dirf.dm_st_email not in (0, 1, 2, 3) then
      --
      vn_fase := 8.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"Situação do e-mail" inválida ('||est_inf_rend_dirf.dm_st_email||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_inf_rend_dirf.tiporetimp_id,0) <= 0 then -- Se a rotina for chamada do processo de Geração de Dados, o Identificador já existe (pk_gera_inf_rend_dirf)
      --
      vn_fase := 9.1;
      --
      est_inf_rend_dirf.tiporetimp_id := pk_csf_dirf.fkg_retorna_id_imposto( en_tiporetimp_cd => ev_cod_ret_imp
                                                                           , en_multorg_id    => en_multorg_id );
      --
      vn_fase := 9.2;
      --
      if nvl(est_inf_rend_dirf.tiporetimp_id,0) <= 0 then
         --
         vn_fase := 9.3;
         --
         gv_mensagem_log := null;
         --
         gv_mensagem_log := '"Código do Tipo de Retenção" está inválido ('||ev_cod_ret_imp||')';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_cabec_log
                              , ev_resumo            => gv_mensagem_log
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                 , est_log_generico_ird => est_log_generico_ird
                                 );
         --
      end if;
      --
   end if;
   --
   vn_fase := 10;
   --
   if est_inf_rend_dirf.dt_hr_ent_sist is null then
      est_inf_rend_dirf.dt_hr_ent_sist := sysdate;
   end if;
   --
   vn_fase := 11;
   --
   est_inf_rend_dirf.infor := trim(pk_csf.fkg_converte(est_inf_rend_dirf.infor));
   --
   vn_fase := 12;
   --
   if nvl(est_inf_rend_dirf.ano_calend, 0) < 0 then
      --
      vn_fase := 12.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O campo "Ano calendario" não pode ser menor que 0 ('||est_inf_rend_dirf.ano_calend||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   elsif est_inf_rend_dirf.ano_calend > est_inf_rend_dirf.ano_ref then
      --
      vn_fase := 12.2;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O campo "Ano calendario" não pode ser maior que o campo "Ano referencial"
                         (' ||'Ano calendario:'||est_inf_rend_dirf.ano_calend||' Ano referencial'||est_inf_rend_dirf.ano_ref||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   elsif est_inf_rend_dirf.ano_calend < (est_inf_rend_dirf.ano_ref - 1) then
      --
      vn_fase := 12.3;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := 'O campo "Ano calendario" não pode ser menor que o campo "Ano referencial" - 1
                         (' ||'Ano calendario:'||est_inf_rend_dirf.ano_calend||' Ano referencial'||est_inf_rend_dirf.ano_ref||')';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_cabec_log
                           , ev_resumo            => gv_mensagem_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia
                           );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird
                              );
      --
   end if;
   --
   vn_fase := 99;
   --
   if nvl(est_inf_rend_dirf.empresa_id,0) > 0
      and nvl(est_inf_rend_dirf.pessoa_id,0) > 0
      and est_inf_rend_dirf.ano_ref is not null
      and nvl(est_inf_rend_dirf.tiporetimp_id,0) > 0
      and est_inf_rend_dirf.dm_origem in (1, 2)
      and est_inf_rend_dirf.dm_tipo_lcto in (1,2,3,4,5)
      and est_inf_rend_dirf.dm_situacao in (0,1,2,3)
      and est_inf_rend_dirf.dm_st_email in (0,1,2,3)
      and est_inf_rend_dirf.ano_calend is not null
      then
      --
      vn_fase := 99.1;
      --
      -- Calcula a quantidade de registros totais integrados para ser
      -- mostrado na tela de agendamento.
      --
      begin
         pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
      exception
         when others then
            null;
      end;
      --
      if pk_csf_dirf.fkg_existe_inf_rend_dirf ( en_infrenddirf_id => est_inf_rend_dirf.id ) = true then
         --
         vn_fase := 99.2;
         --
          update inf_rend_dirf set ano_ref        = est_inf_rend_dirf.ano_ref
                                 , tiporetimp_id  = est_inf_rend_dirf.tiporetimp_id
                                 , dm_origem      = nvl(est_inf_rend_dirf.dm_origem,1)
                                 , dm_tipo_lcto   = nvl(est_inf_rend_dirf.dm_tipo_lcto,1)
                                 , dm_situacao    = nvl(est_inf_rend_dirf.dm_situacao,0)
                                 , dt_hr_ent_sist = est_inf_rend_dirf.dt_hr_ent_sist
                                 , dm_st_email    = nvl(est_inf_rend_dirf.dm_st_email,0)
                                 , infor          = est_inf_rend_dirf.infor
                                 , ano_calend     = est_inf_rend_dirf.ano_calend
          where id = est_inf_rend_dirf.id;
         --
      else
         --
         vn_fase := 99.3;
         --
         insert into inf_rend_dirf ( id
                                   , empresa_id
                                   , pessoa_id
                                   , ano_ref
                                   , tiporetimp_id
                                   , dm_origem
                                   , dm_tipo_lcto
                                   , dm_situacao
                                   , dt_hr_ent_sist
                                   , dm_st_email
                                   , infor
                                   , ano_calend
                                   )
                            values ( est_inf_rend_dirf.id
                                   , est_inf_rend_dirf.empresa_id
                                   , est_inf_rend_dirf.pessoa_id
                                   , est_inf_rend_dirf.ano_ref
                                   , est_inf_rend_dirf.tiporetimp_id
                                   , nvl(est_inf_rend_dirf.dm_origem,1)
                                   , nvl(est_inf_rend_dirf.dm_tipo_lcto,1)
                                   , nvl(est_inf_rend_dirf.dm_situacao,0)
                                   , est_inf_rend_dirf.dt_hr_ent_sist
                                   , nvl(est_inf_rend_dirf.dm_st_email,0)
                                   , est_inf_rend_dirf.infor
                                   , est_inf_rend_dirf.ano_calend
                                   );
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_dirf.pkb_integr_inf_dirf fase('||vn_fase||'):'||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%TYPE;
      begin
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => null
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integr_inf_rend_dirf;

----------------------------------------------------------------------------------------------------------------

procedure pkb_ret_multorg_id( est_log_generico  in out nocopy  dbms_sql.number_table
                            , ev_cod_mult_org   in             mult_org.cd%type
                            , ev_hash_mult_org  in             mult_org.hash%type
                            , sn_multorg_id     in out nocopy  mult_org.id%type
                            , en_referencia_id  in             log_generico_ird.referencia_id%type  default null
                            , ev_obj_referencia in             log_generico_ird.obj_referencia%type default null
                            )
is
   --
   vn_fase               number := 0;
   vv_multorg_hash       mult_org.hash%type;
   vn_multorg_id         mult_org.id%type;
   vn_loggenerico_id     log_generico_ird.id%type;
   vn_dm_obrig_integr    mult_org.dm_obrig_integr%type;
   --
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
         gv_mensagem_log := 'Problema ao tentar buscar o Mult Org. Fase: '||vn_fase;
         gv_cabec_log :=  'Codigo do MultOrg: |' || ev_cod_mult_org || '| Hash do MultOrg: |'||ev_hash_mult_org||'|';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_cabec_log
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                 , est_log_generico_ird => est_log_generico );
   --
   end;
   --
   vn_fase := 5;
   --
   if nvl(vn_multorg_id, 0) = 0 then

      gv_mensagem_log := 'O Mult Org de codigo: |' || ev_cod_mult_org || '| não existe.';
      --
      vn_loggenerico_id := null;
      --
      vn_fase := 5.1;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 5.2;
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_mensagem_log
                              , en_tipo_log          => informacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 5.3;
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_mensagem_log
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                                  );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                 , est_log_generico_ird => est_log_generico );
         --
      end if;
      --
   elsif vv_multorg_hash != ev_hash_mult_org then
      --
      vn_fase := 6;
      --
      gv_mensagem_log := 'O valor do Hash ('|| ev_hash_mult_org ||') do Mult Org:'|| ev_cod_mult_org ||'esta incorreto.';
      --
      vn_loggenerico_id := null;
      --
      if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
         --
         vn_fase := 6.1;
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_mensagem_log
                              , en_tipo_log          => informacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         --
      elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
         --
         vn_fase := 6.2;
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_mensagem_log
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                 , est_log_generico_ird => est_log_generico );
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
      raise_application_error (-20101, 'Problemas ao validar Mult Org - pk_csf_api_dirf.pkb_ret_multorg_id. Fase: '||vn_fase||' Erro = '||sqlerrm);
end pkb_ret_multorg_id;

-------------------------------------------------------------------------------------------------------

-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field

procedure pkb_val_atrib_multorg ( est_log_generico   in out nocopy  dbms_sql.number_table
                                , ev_obj_name        in             varchar2
                                , ev_atributo        in             varchar2
                                , ev_valor           in             varchar2
                                , sv_cod_mult_org    out            varchar2
                                , sv_hash_mult_org   out            varchar2
                                , en_referencia_id   in             log_generico_ird.referencia_id%type  default null
                                , ev_obj_referencia  in             log_generico_ird.obj_referencia%type default null
                                )
is
   --
   vn_fase                number := 0;
   vn_loggenerico_id      log_generico_ird.id%type;
   vv_mensagem            varchar2(1000) := null;
   vn_dmtipocampo         ff_obj_util_integr.dm_tipo_campo%type;
   vv_hash_mult_org       mult_org.hash%type;
   vv_cod_mult_org        mult_org.cd%type;
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log   := null;
   gn_referencia_id  := en_referencia_id;
   gv_obj_referencia := ev_obj_referencia;
   --
   vn_fase := 2;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 3;
      --
      gv_mensagem_log := '"Código ou HASH da Mult-Organização (objeto: '|| ev_obj_name ||'):"VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem_log
                           , ev_resumo            => gv_cabec_log
                           , en_tipo_log          => informacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico );
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
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem_log
                           , ev_resumo            => gv_cabec_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico );
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
            gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                 , ev_mensagem          => gv_mensagem_log
                                 , ev_resumo            => gv_cabec_log
                                 , en_tipo_log          => erro_de_validacao
                                 , en_referencia_id     => gn_referencia_id
                                 , ev_obj_referencia    => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                    , est_log_generico_ird => est_log_generico );
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
      gv_mensagem_log := 'Erro na pk_csf_api_dirf.pkb_val_atrib_multorg fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_cabec_log
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                 , est_log_generico_ird => est_log_generico );
      exception
         when others then
            null;
      end;
end pkb_val_atrib_multorg;

------------------------------------------------------------------------------------------

--| Procedimento de Integração de Informação da DIRF campos flex field do Informe de Rendimentos

procedure pkb_integr_inf_rend_dirf_ff ( est_log_generico_ird   in out nocopy  dbms_sql.number_table
                                      , ev_cod_part_rpde       in             varchar2
                                      , en_multorg_id          in             mult_org.id%type
                                      , ev_atributo            in             varchar2
                                      , ev_valor               in             varchar2 ) IS
   --
   vn_fase              number := 0;
   vn_loggenerico_id    log_generico_nf.id%type;
   vv_mensagem          varchar2(1000) := null;
   vn_dmtipocampo       ff_obj_util_integr.dm_tipo_campo%type;
   vn_percent_devol     number;
   vn_pessoa_id         inf_rend_dirf.pessoa_id%type;
   vn_qtde              number;
   vn_tipoparam_id      tipo_param.id%type;   
   vn_valortipopram_id  valor_tipo_param.id%type; 
   vv_cod_part_rpde     varchar2(60);   
   --
begin
   --
   vn_fase := 1;
   --
   gv_mensagem_log := null;
   --
   if trim(ev_atributo) is null then
      --
      vn_fase := 2;
      --
      vn_loggenerico_id := null;
      --
      gv_mensagem_log := 'Itens do Informe de Rendimentos: "Atributo" deve ser informado.';	  
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem_log
                           , ev_resumo            => gv_cabec_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird );	  
      --
   end if;
   --
   vn_fase := 3;
   --
   if trim(ev_valor) is null then
      --
      vn_fase := 4;
      --
      gv_mensagem_log := 'Itens do Informe de Rendimentos: "VALOR" referente ao atributo deve ser informado.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem_log
                           , ev_resumo            => gv_cabec_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird );	
      --
   end if;
   --
   vn_fase := 5;       
   --
   vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_INF_REND_DIRF_FF'
                                            , ev_atributo => trim(ev_atributo)
                                            , ev_valor    => trim(ev_valor) );
   --
   vn_fase := 6;
   --
   if vv_mensagem is not null then
      --
      vn_fase := 7;
      --
      gv_mensagem_log := vv_mensagem;
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                           , ev_mensagem          => gv_mensagem_log
                           , ev_resumo            => gv_cabec_log
                           , en_tipo_log          => erro_de_validacao
                           , en_referencia_id     => gn_referencia_id
                           , ev_obj_referencia    => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                              , est_log_generico_ird => est_log_generico_ird );	
      --
   else
      --
      vn_fase := 8;
      --
      vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_INF_REND_DIRF_FF'
                                                         , ev_atributo => trim(ev_atributo) );
      --
      vn_fase := 9;
      --
      if trim(ev_atributo) = 'COD_PART_RPDE' then
         --
         vn_fase := 10;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 10.1;
            --
            if vn_dmtipocampo = 2 then -- tipo de campo = 0-data, 1-numérico, 2-caractere
               --			
               vv_cod_part_rpde := pk_csf.fkg_ff_ret_vlr_caracter( ev_obj_name => 'VW_CSF_INF_REND_DIRF_FF'
                                                                 , ev_atributo => trim(ev_atributo)
                                                                 , ev_valor    => trim(ev_valor) );			
               --
               if vv_cod_part_rpde is null then
                  --
                  gv_mensagem_log := '"Codigo Participante do ERP Domiciado no Exterior" não pode ser omitido.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                       , ev_mensagem          => gv_mensagem_log
                                       , ev_resumo            => gv_cabec_log
                                       , en_tipo_log          => erro_de_validacao
                                       , en_referencia_id     => gn_referencia_id
                                       , ev_obj_referencia    => gv_obj_referencia );
                  -- Armazena o "loggenerico_id" na memória
                  pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                          , est_log_generico_ird => est_log_generico_ird );	
                  --
               end if;
               --
            else
               --
               vn_fase := 10.2;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                    , ev_mensagem          => gv_mensagem_log
                                    , ev_resumo            => gv_cabec_log
                                    , en_tipo_log          => erro_de_validacao
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                       , est_log_generico_ird => est_log_generico_ird );	
               --
            end if;
            --
         else
            --
            gv_mensagem_log := '"Codigo Participante do ERP Domiciado no Exterior" não pode ser nulo.';
            --
            vn_loggenerico_id := null;
            --
            pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                 , ev_mensagem          => gv_mensagem_log
                                 , ev_resumo            => gv_cabec_log
                                 , en_tipo_log          => erro_de_validacao
                                 , en_referencia_id     => gn_referencia_id
                                 , ev_obj_referencia    => gv_obj_referencia );
            -- Armazena o "loggenerico_id" na memória
            pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                    , est_log_generico_ird => est_log_generico_ird );	
             --			
         end if;
         --		 
      elsif trim(ev_atributo) = 'NAT_PESSOA_ESTRANG' then
         --
         vn_fase := 11;
         --
         if trim(ev_valor) is not null then
            --
            vn_fase := 11.1;
            --
            if vn_dmtipocampo = 1 then -- tipo de campo = 0-data, 1-numérico, 2-caractere
               --
               vn_fase := 11.2;
               --
               vn_percent_devol := pk_csf.fkg_ff_ret_vlr_number( ev_obj_name => 'VW_CSF_INF_REND_DIRF_FF'
                                                               , ev_atributo => trim(ev_atributo)
                                                               , ev_valor    => trim(ev_valor) );
               --
               if nvl(vn_percent_devol,0) > 1 then
                  --
                  gv_mensagem_log := '"Natureza da Pessoa Estrangeira" não pode ser maior que 1.';
                  --
                  vn_loggenerico_id := null;
                  --
                  pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                       , ev_mensagem          => gv_mensagem_log
                                       , ev_resumo            => gv_cabec_log
                                       , en_tipo_log          => erro_de_validacao
                                       , en_referencia_id     => gn_referencia_id
                                       , ev_obj_referencia    => gv_obj_referencia );
                  -- Armazena o "loggenerico_id" na memória
                  pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                          , est_log_generico_ird => est_log_generico_ird );	
                  --
               end if;
               --
               if to_number(ev_valor) not in (0,1) then			   
                  --
                  gv_mensagem_log := '"Natureza da Pessoa Estrangeira" invalida deve ser "0" ou "1".';
                  --
                  vn_loggenerico_id := null;
                  --
                  pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                       , ev_mensagem          => gv_mensagem_log
                                       , ev_resumo            => gv_cabec_log
                                       , en_tipo_log          => erro_de_validacao
                                       , en_referencia_id     => gn_referencia_id
                                       , ev_obj_referencia    => gv_obj_referencia );
                  -- Armazena o "loggenerico_id" na memória
                  pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                          , est_log_generico_ird => est_log_generico_ird );	
                  --			   
               end if;
               --			   
            else
               --
               vn_fase := 11.3;
               --
               gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
               --
               vn_loggenerico_id := null;
               --
               pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                                    , ev_mensagem          => gv_mensagem_log
                                    , ev_resumo            => gv_cabec_log
                                    , en_tipo_log          => erro_de_validacao
                                    , en_referencia_id     => gn_referencia_id
                                    , ev_obj_referencia    => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                       , est_log_generico_ird => est_log_generico_ird );	
               --
            end if;
            --
         end if;
	     --  
      else
         --
         vn_fase := 12;
         --
         gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_cabec_log
                              , en_tipo_log          => erro_de_validacao
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                 , est_log_generico_ird => est_log_generico_ird );	
         --
      end if;
      --
   end if;
   --
   vn_fase := 13;
   --
   if trim(ev_atributo) = 'NAT_PESSOA_ESTRANG' and
      trim(ev_cod_part_rpde) is not null and
      trim(ev_valor) is not null then 
      --	  
      vn_fase := 13.1;
      --
      vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id => en_multorg_id
                                                    , ev_cod_part   => ev_cod_part_rpde );
      --
      if nvl(vn_pessoa_id,0) > 0 then
         --
         vn_fase := 13.4;
         --		 
         begin 
            select count(1) 
              into vn_qtde			
              from pessoa_tipo_param p
                 , tipo_param t
             where t.cd           = '12' -- Natureza de pessoa estrangeira
               and p.pessoa_id    = vn_pessoa_id
               and p.tipoparam_id = t.id;          
         exception
            when others then
               vn_qtde := null;
         end;
         --
         vn_fase := 13.5;
         --				 
         begin 
            select t.id
              into vn_tipoparam_id		 
              from tipo_param t
             where t.cd  = '12'; -- Natureza de pessoa estrangeira			  
         exception
            when others then
               vn_tipoparam_id := null;
         end;			   
         --	
         vn_fase := 13.6;
         --		
         begin		 
            select v.id 
              into vn_valortipopram_id
              from valor_tipo_param v  
             where v.tipoparam_id = vn_tipoparam_id
               and v.cd           = ev_valor;		 
         exception
            when others then
               vn_valortipopram_id := null;
         end;
         --
		 vn_fase := 13.7;
         --	
         if nvl(vn_qtde,0) <= 0 then
            --		 
            insert into pessoa_tipo_param ( id
                                          , pessoa_id
                                          , tipoparam_id
                                          , valortipoparam_id
                                          )		 
                                    values( pessoatipoparam_seq.nextval
                                          , vn_pessoa_id
                                          , vn_tipoparam_id
                                          , vn_valortipopram_id
                                          );
            --										  
         else
            --		 
            update pessoa_tipo_param
               set valortipoparam_id = vn_valortipopram_id
             where pessoa_id    = vn_pessoa_id
               and tipoparam_id = vn_tipoparam_id;			 
            --			   
         end if;		 
         --	  
      end if;
      --	  
   end if;	  
   --
   vn_fase := 14;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_dirf.pkb_integr_inf_rend_dirf_ff fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_ird.id%TYPE;
      begin
         --
         pkb_log_generico_ird ( sn_loggenericoird_id => vn_loggenerico_id
                              , ev_mensagem          => gv_mensagem_log
                              , ev_resumo            => gv_cabec_log
                              , en_tipo_log          => erro_de_sistema
                              , en_referencia_id     => gn_referencia_id
                              , ev_obj_referencia    => gv_obj_referencia
                              );
         -- Armazena o "loggenerico_id" na memória
         pkb_gt_log_generico_ird ( en_loggenericoird_id => vn_loggenerico_id
                                 , est_log_generico_ird => est_log_generico_ird );
      exception
         when others then
            null;
      end;
      --
end pkb_integr_inf_rend_dirf_ff;

-------------------------------------------------------------------------------------------------------
--- Função que retorna o parametro de qual data será usada na leitura para a geração da DIRF
-------------------------------------------------------------------------------------------------------
function fkg_dt_ref_imp_ret ( en_empresa_id in empresa.id%type )
         return varchar2
is
   vn_multorg_id  mult_org.id%type;
   vn_modulo_id   modulo_sistema.id%type;
   vn_grupo_id    grupo_sistema.id%type;
   vv_vlr_param   param_geral_sistema.vlr_param%type; 
   vv_erro        varchar2(500);   
   vb_retorna     boolean;    
   -- 
   -- D - Default  - Data do Documento
   -- P -          - Data do Pagamento
   -- V -          - Data do Vencimento   
begin 
   -- 
   vn_multorg_id := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => en_empresa_id );
   --
   begin
      select m.id 
        into vn_modulo_id
        from modulo_sistema m
       where m.cod_modulo = 'OBRIG_FEDERAL';
   exception
      when others then
         vn_modulo_id := null;
   end;
   --
   begin
      select g.id 
        into vn_grupo_id   
        from grupo_sistema g
       where modulo_id in (select m.id 
	                         from modulo_sistema m
                            where m.cod_modulo = 'OBRIG_FEDERAL') 
         and g.cod_grupo = 'DIRF';
   exception
      when others then
         vn_grupo_id := null;
   end;	  
   --	
   vv_erro      := null;
   vv_vlr_param := null;
   --   
   vb_retorna:=  pk_csf.fkg_ret_vl_param_geral_sistema ( en_multorg_id => vn_multorg_id
                                                       , en_empresa_id => null
                                                       , en_modulo_id  => vn_modulo_id
                                                       , en_grupo_id   => vn_grupo_id
                                                       , ev_param_name => 'DT_REF_IMP_RET' 
                                                       , sv_vlr_param  => vv_vlr_param 
                                                       , sv_erro       => vv_erro  ); 
   if vb_retorna = true then
      --   
      if vv_erro is null then
         --	 
         vv_vlr_param := upper(vv_vlr_param);
         --
         return vv_vlr_param;		
         --		 
      else
         return 'D';	  
      end if;
      --	  
   else
      return 'D';
   end if;   
   --  
exception 
   when others then
      return 'D';   
      raise_application_error(-20101, 'Erro na fkg_dt_ref_imp_ret:' || sqlerrm);   
end fkg_dt_ref_imp_ret;		

------------------------------------------------------------------------------------------

end pk_csf_api_dirf;
/
