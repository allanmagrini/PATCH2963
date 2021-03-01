create or replace package body csf_own.pk_csf_api_gpi is

----------------------------------------------------------------------------------------------------
-- Pacote de API de Guia de Pagamento de Impostos
----------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--| Procedimento seta o "ID de Referencia" utilizado na Valida��o da Informa��o
--------------------------------------------------------------------------------
procedure pkb_seta_referencia_id ( en_id in number
                                 ) is
begin
   --
   gn_referencia_id := en_id;
   --
end pkb_seta_referencia_id;

-------------------------------------------------------------------------------------------------------
--| Procedimento seta o tipo de integra��o que ser� feito
-- 0 - Somente v�lida os dados e registra o Log de ocorr�ncia
-- 1 - V�lida os dados e registra o Log de ocorr�ncia e insere a informa��o
-- Todos os procedimentos de integra��o fazem refer�ncia a ele
-------------------------------------------------------------------------------------------------------
procedure pkb_seta_tipo_integr ( en_tipo_integr in number )
is
Begin
   --
   gn_tipo_integr := en_tipo_integr;
   --
end pkb_seta_tipo_integr;
-------------------------------------------------------------------------------------------------------

--| Procedimento de registro de log de erros na valida��o de Guia de Pagamento de Impostos

procedure pkb_log_generico_gpi ( sn_loggenericogpi_id   in out nocopy log_generico_gpi.id%TYPE
                               , ev_mensagem            in            log_generico_gpi.mensagem%TYPE
                               , ev_resumo              in            log_generico_gpi.resumo%TYPE
                               , en_tipo_log            in            csf_tipo_log.cd_compat%type      default 1
                               , en_referencia_id       in            log_generico_gpi.referencia_id%TYPE  default null
                               , ev_obj_referencia      in            log_generico_gpi.obj_referencia%TYPE default null
                               , en_empresa_id          in            Empresa.Id%type                  default null
                               , en_dm_impressa         in            log_generico_gpi.dm_impressa%type    default 0 )
is
   --
   vn_fase          number := 0;
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
   if nvl(en_tipo_log,0) > 0 and ev_mensagem is not null then
      --
      vn_fase := 2;
      --
      vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id ( en_tipo_log => en_tipo_log );
      --
      vn_fase := 3;
      --
      select loggenericogpi_seq.nextval
        into sn_loggenericogpi_id
        from dual;
      --
      vn_fase := 4;
      --
      insert into Log_Generico_gpi ( id
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
                                    ( sn_loggenericogpi_id     -- Valor de cada log de valida��o
                                    , gn_processo_id        -- Valor ID do processo de integra��o
                                    , sysdate               -- Sempre atribui a data atual do sistema
                                    , ev_mensagem           -- Mensagem do log
                                    , en_referencia_id      -- Id de refer�ncia que gerou o log
                                    , ev_obj_referencia     -- Objeto do Banco que gerou o log
                                    , ev_resumo
                                    , en_dm_impressa
                                    , 0
                                    , vn_csftipolog_id
                                    , nvl(en_empresa_id, gn_empresa_id)
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
      gv_mensagem_log := 'Erro na pkb_log_generico_gpi fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                               , ev_mensagem        => gv_cabec_log
                               , ev_resumo          => gv_mensagem_log
                               , en_tipo_log        => ERRO_DE_SISTEMA 
                               , en_empresa_id      => en_empresa_id );
         --
      exception
         when others then
            null;
      end;
      --
   --
end pkb_log_generico_gpi;
--

-------------------------------------------------------------------------------------------------------

--| Procedimento finaliza o Log Gen�rico

procedure pkb_finaliza_log_generico_gpi is
begin
   --
   gn_processo_id := null;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_gpi.pkb_finaliza_log_generico_gpi: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
   --
end pkb_finaliza_log_generico_gpi;

----------------------------------------------------------------------------------
--| Procedimento seta o objeto de referencia utilizado na Valida��o da Informa��o    
----------------------------------------------------------------------------------
procedure pkb_seta_obj_ref ( ev_objeto in varchar2
                           ) is
begin
   --
   gv_obj_referencia := upper(ev_objeto);
   --
end pkb_seta_obj_ref;

------------------------------------------------------
--| Procedimento armazena o valor do "loggenerico_id"
------------------------------------------------------
procedure pkb_gt_log_generico_gpi ( en_loggenericogpi_id   in             Log_generico_gpi.id%TYPE
                                  , est_log_generico_gpi  in out nocopy  dbms_sql.number_table
                                  ) is
   --
   i pls_integer;
   --
begin
   --
   if nvl(en_loggenericogpi_id,0) > 0 then
      --
      i := nvl(est_log_generico_gpi.count,0) + 1;
      --
      est_log_generico_gpi(i) := en_loggenericogpi_id;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_csf_api_gpi.pkb_gt_log_generico_gpi: '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico_gpi.id%TYPE;
      begin
         --
         pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_SISTEMA );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_gt_log_generico_gpi;

----------------------------------------------------------------------------------------------------
-- Procedimento de integra��o de guia de pagamento de Imposto
procedure pkb_integr_guia_pgto_imp ( est_log_generico_gpi  in out nocopy dbms_sql.number_table
                                   , est_row_guia_pgto_imp in out nocopy guia_pgto_imp%rowtype
                                   , en_empresa_id         in            empresa.id%type
                                   , en_multorg_id         in            mult_org.id%type
                                   , ev_cod_part           in            pessoa.cod_part%type
                                   , en_tipimp_cd          in            tipo_imposto.cd%type
                                   , ev_tiporetimp_cd      in            tipo_ret_imp.cd%type
                                   , ev_cod_rec_cd         in            tipo_ret_imp_receita.cod_receita%type
                                   , ev_cod_rec_cd_compl   in            guia_pgto_imp_compl_gen.cod_receita%type
                                   , sn_guiapgtoimp_id    out            guia_pgto_imp.id%type   
                                   )
is
   --
   vn_fase                  number := null;
   vn_loggenerico_id        log_generico_gpi.id%type;
   --
begin
   --
   vn_fase := 1;
   -- Monta Cabe�alho do log
   if nvl(est_row_guia_pgto_imp.empresa_id,0) > 0 then
      --
      gv_cabec_log := 'Empresa: ' || pk_csf.fkg_nome_empresa ( en_empresa_id => est_row_guia_pgto_imp.empresa_id );
      --
      gv_cabec_log := gv_cabec_log || chr(10);
      --
   end if;
   --
   vn_fase := 2;
   --
   gv_cabec_log := gv_cabec_log || 'Retido pelo participante: '|| ev_cod_part;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   vn_fase := 2.1;
   --
   gv_cabec_log := gv_cabec_log || 'C�d. tipo de Imposto: '|| en_tipimp_cd;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   vn_fase := 2.2;
   --
   gv_cabec_log := gv_cabec_log ||'Data do Vencimento do Pagamento: '|| est_row_guia_pgto_imp.dt_vcto;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   vn_fase := 2.3;
   --
   gv_cabec_log := gv_cabec_log ||'C�d. da Receita: '|| ev_cod_rec_cd;
   gv_cabec_log := gv_cabec_log || chr(10);
   --
   vn_fase := 3;
   --
   -- Caso vier nullo alterar para zero.
   est_row_guia_pgto_imp.vl_multa := nvl(est_row_guia_pgto_imp.vl_multa,0);
   est_row_guia_pgto_imp.vl_juro := nvl(est_row_guia_pgto_imp.vl_juro,0);
   est_row_guia_pgto_imp.vl_outro := nvl(est_row_guia_pgto_imp.vl_outro,0);
   --
   -- Inicia a valida��o dos campos
   est_row_guia_pgto_imp.pessoa_id := pk_csf.fkg_pessoa_id_cod_part ( en_multorg_id  => en_multorg_id
                                                                    , ev_cod_part    => ev_cod_part
                                                                    );
   --
   vn_fase := 4;
   --
   if nvl(est_row_guia_pgto_imp.pessoa_id,0) = 0 then
      --
      vn_fase := 4.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"COD_PART" ('||ev_cod_part||') inv�lido ou n�o cadastrado na base do compliance.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 5;
   --
   est_row_guia_pgto_imp.tipoimposto_id := pk_csf.fkg_Tipo_Imposto_id ( en_cd => en_tipimp_cd );
   --
   if nvl(est_row_guia_pgto_imp.tipoimposto_id,0) = 0 then
      --
      vn_fase := 5.1;
      --
      gv_mensagem_log := null;
      --
      gv_mensagem_log := '"C�digo do Tipo de Imposto" ('||en_tipimp_cd||') inv�lido ou n�o cadastrado na base do compliance.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 6;
   --
   if trim(ev_tiporetimp_cd) is not null then
      --
      est_row_guia_pgto_imp.tiporetimp_id := pk_csf.fkg_tipo_ret_imp ( en_multorg_id  => en_multorg_id
                                                                  , en_cd_ret      => ev_tiporetimp_cd
                                                                  , en_tipoimp_id  => est_row_guia_pgto_imp.tipoimposto_id
                                                                  );
      --
      if nvl(est_row_guia_pgto_imp.tiporetimp_id,0) = 0 then
         --
         vn_fase := 6.1;
         --
         gv_mensagem_log := null;
         --
         gv_mensagem_log := '"C�digo da tabela de Documentos Fiscais com Impostos Retido" ('||ev_tiporetimp_cd||
                         ') inv�lido ou n�o cadastrado na base do compliance.';
         --
         vn_loggenerico_id := null;
         --
         pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
         --
      end if;
      --
   end if;
   --
   vn_fase := 7;
   --
   if trim(ev_cod_rec_cd) is not null then
      --
      vn_fase := 7.1;
      --
      if nvl(est_row_guia_pgto_imp.tiporetimp_id,0) > 0 then
         --
         vn_fase := 7.2;
         --
         begin
            --
            select id
              into est_row_guia_pgto_imp.tiporetimpreceita_id
              from tipo_ret_imp_receita
             where cod_receita   = ev_cod_rec_cd
               and tiporetimp_id = est_row_guia_pgto_imp.tiporetimp_id;
            --
         exception
           when no_data_found then
              est_row_guia_pgto_imp.tiporetimpreceita_id := null;
         end;
         --
         vn_fase := 7.3;
         --
         if nvl(est_row_guia_pgto_imp.tiporetimpreceita_id,0) <= 0 then
            --
            vn_fase := 7.4;
            --
            gv_mensagem_log := 'O c�digo de Receita ('|| ev_cod_rec_cd ||
                               ') inv�lido ou n�o cadastrado na base do compliance, favor verificar.';
            --
            pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                                 , ev_mensagem           => gv_cabec_log
                                 , ev_resumo             => gv_mensagem_log
                                 , en_tipo_log           => ERRO_DE_VALIDACAO
                                 , en_referencia_id      => gn_referencia_id
                                 , ev_obj_referencia     => gv_obj_referencia );
            --
            -- Armazena o "loggenerico_id" na mem�ria
            pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                                    , est_log_generico_gpi      => est_log_generico_gpi );
            --
         end if;
         --
      else
         --
         vn_fase := 7.5;
         --
         gv_mensagem_log := 'O c�digo de Receita foi informado porem n�o foi informado o c�digo'||
                            ' do tipo de reten��o de imposto, favor verificar.';
         --
         pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                              , ev_mensagem           => gv_cabec_log
                              , ev_resumo             => gv_mensagem_log
                              , en_tipo_log           => ERRO_DE_VALIDACAO
                              , en_referencia_id      => gn_referencia_id
                              , ev_obj_referencia     => gv_obj_referencia );
         --
         -- Armazena o "loggenerico_id" na mem�ria
         pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                                 , est_log_generico_gpi      => est_log_generico_gpi );
         --
      end if;
      --
   end if;
   --
   --
   gn_referencia_id := est_row_guia_pgto_imp.id;
   gv_obj_referencia := 'GUIA_PGTO_IMP';
   --
   delete from log_generico_gpi
    where referencia_id = gn_referencia_id
      and obj_referencia = gv_obj_referencia;
   --
   commit;
   --
   if nvl(est_row_guia_pgto_imp.dm_tipo,0) not in (1,2,3,4,5) then
      --
      gv_mensagem_log := 'Dominio do tipo de Guia inv�lido ('|| est_row_guia_pgto_imp.dm_tipo ||
                         '), Valores v�lidos: 1-GPS; 2-DARF; 3-GARE e 4-GNRE.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 9;
   --
   if nvl(est_row_guia_pgto_imp.dm_origem,-1) not in (0,1,2,3,4,5,6,7,8,9,10,11,12,13) then
      --
      gv_mensagem_log := 'Dominio de origem inv�lido ('|| est_row_guia_pgto_imp.dm_origem ||
                         '), Valores v�lidos: Origem dos dados: 0-Manual; 1-Imposto Retido;'||
                         ' 2-Apura��o IPI; 3-Apura��o ICMS; 4-Apura��o ICMS-ST; 5-Sub-Apura��o ICMS; 6-Apura��o ICMS-DIFAL; '||
                         '7-Apura��o PIS e 8-Apura��o COFINS;.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 10;
   --
   if nvl(est_row_guia_pgto_imp.nro_via_impressa,-1) <= 0 then
      --
      gv_mensagem_log := 'Numero de via Impressa inv�lido ('||est_row_guia_pgto_imp.nro_via_impressa||'), favor verificar.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 11;
   --
   if trim(est_row_guia_pgto_imp.dt_ref) is null then
      --
      gv_mensagem_log := 'Data de Refer�cia n�o pode ser nulla, favor verificar.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 12;
   --
   if trim(est_row_guia_pgto_imp.dt_vcto) is null then
      --
      gv_mensagem_log := 'Data de Vencimento n�o pode ser nulla, favor verificar.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 13;
   --
   if nvl(est_row_guia_pgto_imp.vl_princ,-1) < 0 then
      --
      gv_mensagem_log := 'Valor Principal do Imposto ('|| est_row_guia_pgto_imp.vl_princ ||
                         ') n�o pode ser menor que zero, favor verificar.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 14;
   --
   if nvl(est_row_guia_pgto_imp.vl_multa,-1) < 0 then
      --
      gv_mensagem_log := 'Valor da Multa ('|| est_row_guia_pgto_imp.vl_multa ||
                         ') n�o pode ser menor que zero, favor verificar.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 15;
   --
   if nvl(est_row_guia_pgto_imp.vl_juro,-1) < 0 then
      --
      gv_mensagem_log := 'Valor de Juros ('|| est_row_guia_pgto_imp.vl_juro ||
                         ') n�o pode ser menor que zero, favor verificar.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 16;
   --
   if nvl(est_row_guia_pgto_imp.vl_outro,-1) < 0 then
      --
      gv_mensagem_log := 'Valor de Juros ('|| est_row_guia_pgto_imp.vl_outro ||
                         ') n�o pode ser menor que zero, favor verificar.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 17;
   --
   if nvl(est_row_guia_pgto_imp.vl_total,-1) < 0 then
      --
      gv_mensagem_log := 'Valor total ('|| est_row_guia_pgto_imp.vl_total ||
                         ') n�o pode ser menor que zero, favor verificar.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 18;
   --
   if ( nvl(est_row_guia_pgto_imp.vl_princ,0) + nvl(est_row_guia_pgto_imp.vl_multa,0)
      + nvl(est_row_guia_pgto_imp.vl_juro,0)      + nvl(est_row_guia_pgto_imp.vl_outro,0) ) <>  nvl(est_row_guia_pgto_imp.vl_total,0) then
      --
      gv_mensagem_log := 'Valor total ('|| est_row_guia_pgto_imp.vl_total || ') tem que ser igual a soma '||
                         '( VL_PRINCIPAL + VL_MULTA + VL_JURO + VL_OUTRO ) -> ('||nvl(est_row_guia_pgto_imp.vl_princ,0) || 
                         ' + '|| nvl(est_row_guia_pgto_imp.vl_multa,0)|| ' + '|| nvl(est_row_guia_pgto_imp.vl_juro,0)|| 
                         ' + '|| nvl(est_row_guia_pgto_imp.vl_outro,0)|| ')';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   vn_fase := 19;
   --
   -- Valida��o da guia de pagamento
   if nvl(est_log_generico_gpi.count,0) > 0 then
      --
      est_row_guia_pgto_imp.dm_situacao := 2; -- Erro de Valida��o
      --
   else
      --
      est_row_guia_pgto_imp.dm_situacao := 1; -- Validado
      --
   end if;      
   --
   vn_fase := 20;
   --
   if nvl(est_row_guia_pgto_imp.empresa_id,0) > 0
    and nvl(est_row_guia_pgto_imp.usuario_id,0) > 0
    and nvl(est_row_guia_pgto_imp.tipoimposto_id,0) > 0
    and nvl(est_row_guia_pgto_imp.pessoa_id,0) > 0
    and nvl(est_row_guia_pgto_imp.dm_tipo,0) in (1,2,3,4,5)
    and nvl(est_row_guia_pgto_imp.dm_origem,-1) in (0,1,2,3,4,5,6,7,8,9,10,11,12,13)
    and nvl(est_row_guia_pgto_imp.nro_via_impressa,0) > 0
    and nvl(est_row_guia_pgto_imp.vl_princ,0) > 0
    and nvl(est_row_guia_pgto_imp.vl_multa,0) >= 0
    and nvl(est_row_guia_pgto_imp.vl_juro,0) >= 0
    and nvl(est_row_guia_pgto_imp.vl_outro,0) >= 0
    and nvl(est_row_guia_pgto_imp.vl_total,0) > 0
    and trim(est_row_guia_pgto_imp.dt_ref) is not null
    and trim(est_row_guia_pgto_imp.dt_vcto) is not null then
      --
      vn_fase := 21;
      --
      est_row_guia_pgto_imp.id := pk_csf_gpi.fkg_guiapgtoimp_id ( en_empresa_id           => est_row_guia_pgto_imp.empresa_id
                                                                , en_pessoa_id            => est_row_guia_pgto_imp.pessoa_id
                                                                , en_tipoimposto_id       => est_row_guia_pgto_imp.tipoimposto_id
                                                                , en_tiporetimp_id        => est_row_guia_pgto_imp.tiporetimp_id
                                                                , en_tiporetimpreceita_id => est_row_guia_pgto_imp.tiporetimpreceita_id
                                                                , ed_dt_vcto              => est_row_guia_pgto_imp.dt_vcto
                                                                , en_notafiscal_id        => est_row_guia_pgto_imp.notafiscal_id
                                                                , en_conhectransp_id      => est_row_guia_pgto_imp.conhectransp_id  
                                                                );
      --
      vn_fase := 22;
      --
      if nvl(est_row_guia_pgto_imp.id,0) <= 0 then
         --
         select guiapgtoimp_seq.nextval
           into est_row_guia_pgto_imp.id
           from dual;
         --
      end if;         
      --
      if pk_csf_gpi.fkg_exist_guiapgtoimp ( en_guiapgtoimp_id => nvl(est_row_guia_pgto_imp.id,0)) then
         
         --
         update guia_pgto_imp
            set empresa_id           = est_row_guia_pgto_imp.empresa_id
              , usuario_id           = est_row_guia_pgto_imp.usuario_id
              , dm_situacao          = est_row_guia_pgto_imp.dm_situacao
              , tipoimposto_id       = est_row_guia_pgto_imp.tipoimposto_id
              , tiporetimp_id        = est_row_guia_pgto_imp.tiporetimp_id
              , tiporetimpreceita_id = est_row_guia_pgto_imp.tiporetimpreceita_id
              , pessoa_id            = est_row_guia_pgto_imp.pessoa_id
              , dm_tipo              = est_row_guia_pgto_imp.dm_tipo
              , dm_origem            = est_row_guia_pgto_imp.dm_origem
              , nro_via_impressa     = est_row_guia_pgto_imp.nro_via_impressa
              , dt_ref               = est_row_guia_pgto_imp.dt_ref
              , dt_vcto              = est_row_guia_pgto_imp.dt_vcto
              , vl_princ             = est_row_guia_pgto_imp.vl_princ
              , vl_multa             = est_row_guia_pgto_imp.vl_multa
              , vl_juro              = est_row_guia_pgto_imp.vl_juro
              , vl_outro             = est_row_guia_pgto_imp.vl_outro
              , vl_total             = est_row_guia_pgto_imp.vl_total
              , obs                  = est_row_guia_pgto_imp.obs
              , pessoa_id_sefaz      = est_row_guia_pgto_imp.pessoa_id_sefaz
              , dm_ret_erp           = est_row_guia_pgto_imp.dm_ret_erp
              , aberturaefdpc_id     = est_row_guia_pgto_imp.aberturaefdpc_id
              , apuracaoicmsst_id    = est_row_guia_pgto_imp.apuracaoicmsst_id
              , apuricmsdifal_id     = est_row_guia_pgto_imp.apuricmsdifal_id
              , aberturaecf_id       = est_row_guia_pgto_imp.aberturaecf_id
              , gerguiapgtoimp_id    = est_row_guia_pgto_imp.gerguiapgtoimp_id
              , planoconta_id        = est_row_guia_pgto_imp.planoconta_id
              , notafiscal_id        = est_row_guia_pgto_imp.notafiscal_id
              , conhectransp_id      = est_row_guia_pgto_imp.conhectransp_id
          where id                   = est_row_guia_pgto_imp.id
            and dm_situacao not in (1,2); -- j� est� no ERP;
         --
      else
         --
         insert into guia_pgto_imp ( id
                                   , empresa_id
                                   , usuario_id
                                   , dm_situacao
                                   , tipoimposto_id
                                   , tiporetimp_id
                                   , tiporetimpreceita_id
                                   , pessoa_id
                                   , dm_tipo
                                   , dm_origem
                                   , nro_via_impressa
                                   , dt_ref
                                   , dt_vcto
                                   , vl_princ
                                   , vl_multa
                                   , vl_juro
                                   , vl_outro
                                   , vl_total
                                   , obs 
                                   , pessoa_id_sefaz
                                   , dm_ret_erp
                                   , aberturaefdpc_id
                                   , apuracaoicmsst_id
                                   , apuricmsdifal_id
                                   , aberturaecf_id
                                   , gerguiapgtoimp_id
                                   , planoconta_id
                                   , notafiscal_id
                                   , conhectransp_id)
                             values( est_row_guia_pgto_imp.id
                                   , est_row_guia_pgto_imp.empresa_id
                                   , est_row_guia_pgto_imp.usuario_id
                                   , est_row_guia_pgto_imp.dm_situacao
                                   , est_row_guia_pgto_imp.tipoimposto_id
                                   , est_row_guia_pgto_imp.tiporetimp_id
                                   , est_row_guia_pgto_imp.tiporetimpreceita_id
                                   , est_row_guia_pgto_imp.pessoa_id
                                   , est_row_guia_pgto_imp.dm_tipo
                                   , est_row_guia_pgto_imp.dm_origem
                                   , est_row_guia_pgto_imp.nro_via_impressa
                                   , est_row_guia_pgto_imp.dt_ref
                                   , est_row_guia_pgto_imp.dt_vcto
                                   , est_row_guia_pgto_imp.vl_princ
                                   , est_row_guia_pgto_imp.vl_multa
                                   , est_row_guia_pgto_imp.vl_juro
                                   , est_row_guia_pgto_imp.vl_outro
                                   , est_row_guia_pgto_imp.vl_total
                                   , est_row_guia_pgto_imp.obs
                                   , est_row_guia_pgto_imp.pessoa_id_sefaz
                                   , est_row_guia_pgto_imp.dm_ret_erp
                                   , est_row_guia_pgto_imp.aberturaefdpc_id 
                                   , est_row_guia_pgto_imp.apuracaoicmsst_id
                                   , est_row_guia_pgto_imp.apuricmsdifal_id
                                   , est_row_guia_pgto_imp.aberturaecf_id
                                   , est_row_guia_pgto_imp.gerguiapgtoimp_id
                                   , est_row_guia_pgto_imp.planoconta_id
                                   , est_row_guia_pgto_imp.notafiscal_id
                                   , est_row_guia_pgto_imp.conhectransp_id);
         --
      end if;
      --
      vn_fase := 23;
      --      
      -- Insere o complemento na tabela GUIA_PGTO_IMP_COMPL_GEN
      if ev_cod_rec_cd_compl is not null then
         --
         begin
         -- checar se cod_receita is not null -- 
           insert into GUIA_PGTO_IMP_COMPL_GEN (id,
                                                guiapgtoimp_id,
                                                cod_receita,
                                                ident_ref)
                                      values   (guiapgtoimpcomplgen_seq.nextval,
                                                est_row_guia_pgto_imp.id,
                                                ev_cod_rec_cd_compl,
                                                null);                          
         exception
            when dup_val_on_index then
               --
               update GUIA_PGTO_IMP_COMPL_GEN
                  set cod_receita = ev_cod_rec_cd_compl
               where guiapgtoimp_id = est_row_guia_pgto_imp.id;
               --
            when others then
               --
               gv_mensagem_log := 'N�o foi possivel incluir este registro na tabela GUIA_PGTO_IMP_COMPL_GEN por conta de inconsistencia de dados, '||
                                  'favor atualizar as informa��es e integrar novamente.';
               --
               pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                                    , ev_mensagem           => gv_cabec_log
                                    , ev_resumo             => gv_mensagem_log
                                    , en_tipo_log           => ERRO_DE_VALIDACAO
                                    , en_referencia_id      => gn_referencia_id
                                    , ev_obj_referencia     => gv_obj_referencia );
               --
               -- Armazena o "loggenerico_id" na mem�ria
               pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                                       , est_log_generico_gpi      => est_log_generico_gpi );
               --
         end;
         --
      end if;  
      --
   else
      --
      gv_mensagem_log := 'N�o foi possivel incluir este registro por conta de inconsistencia de dados, '||
                         'favor atualizar as informa��es e integrar novamente.';
      --
      pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                           , ev_mensagem           => gv_cabec_log
                           , ev_resumo             => gv_mensagem_log
                           , en_tipo_log           => ERRO_DE_VALIDACAO
                           , en_referencia_id      => gn_referencia_id
                           , ev_obj_referencia     => gv_obj_referencia );
      --
      -- Armazena o "loggenerico_id" na mem�ria
      pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                              , est_log_generico_gpi      => est_log_generico_gpi );
      --
   end if;
   --
   sn_guiapgtoimp_id := est_row_guia_pgto_imp.id;
   --
   commit;
   --
exception
  when others then
     --
     gv_mensagem_log := 'Erro na package pk_csf_api_gpi.pkb_integr_guia_pgto_imp fase ('|| vn_fase ||') Erro: '|| sqlerrm;
     --
     pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                          , ev_mensagem           => gv_cabec_log
                          , ev_resumo             => gv_mensagem_log
                          , en_tipo_log           => ERRO_DE_VALIDACAO
                          , en_referencia_id      => gn_referencia_id
                          , ev_obj_referencia     => gv_obj_referencia );
     --
     -- Armazena o "loggenerico_id" na mem�ria
     pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                             , est_log_generico_gpi      => est_log_generico_gpi );
     --
end pkb_integr_guia_pgto_imp;
--

----------------------------------------------------------------------------------------------------
-- Procedimento de estorno de guia de pagamento de Imposto

procedure pkb_estorno_guia_pgto_imp ( est_log_generico_gpi  in out nocopy dbms_sql.number_table
                                    , en_guiapgtoimp_id     in            guia_pgto_imp.id%type)
is
   vn_fase             number := 0;
   vn_loggenerico_id   log_generico_gpi.id%type;
begin
   --
   vn_fase := 1;
   --
   update guia_pgto_imp t
      set t.dm_situacao = 3 -- cancelado
   where id = en_guiapgtoimp_id;
   --
exception
  when others then
     --
     gv_mensagem_log := 'Erro na package pk_csf_api_gpi.pkb_esstorno_guia_pgto_imp fase ('|| vn_fase ||') Erro: '|| sqlerrm;
     --
     pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                          , ev_mensagem           => gv_cabec_log
                          , ev_resumo             => gv_mensagem_log
                          , en_tipo_log           => ERRO_DE_VALIDACAO
                          , en_referencia_id      => gn_referencia_id
                          , ev_obj_referencia     => gv_obj_referencia );
     --
     -- Armazena o "loggenerico_id" na mem�ria
     pkb_gt_log_generico_gpi ( en_loggenericogpi_id      => vn_loggenerico_id
                             , est_log_generico_gpi      => est_log_generico_gpi );
     --
end pkb_estorno_guia_pgto_imp;   
--

end pk_csf_api_gpi;
/
