create or replace package csf_own.pk_csf_api_gpi is                  

----------------------------------------------------------------------------------------------------
-- Pacote de API de Guia de Pagamento de Impostos
----------------------------------------------------------------------------------------------------
-- Em 27/11/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine 73369: Adicionar a parametrização da Conta Contábil que será vinculada a Guia de Pagamento
-- Rotinas Alteradas: pkb_integr_guia_pgto_imp
--
-- Em 25/11/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5.2
-- Redmine #65265: Gerar guias de impostos a partir da apuração
-- Rotinas Alterada: pkb_integr_guia_pgto_imp
-- Alterações: Inclusão de novos valores para a validação do dm_origem e dm_tipo
--
-- Em 27/07/2020 - Marcos Ferreira
-- Distribuições: 2.9.5 / 2.9.4.2
-- Redmine #65265: Gerar guias de impostos a partir da apuração
-- Rotinas Alterada: pkb_integr_guia_pgto_imp
-- Rotina Criada: pkb_estorno_guia_pgto_imp, 
-- Alterações: Criação da Estrutura das Procedures
--
----------------------------------------------------------------------------------------------------

   gv_cabec_log          log_generico_gpi.mensagem%TYPE;
   --
   gv_cabec_log_item     log_generico_gpi.mensagem%TYPE;
   --
   gv_mensagem_log       log_generico_gpi.mensagem%TYPE;
   --
   gv_dominio            Dominio.descr%TYPE;
   --
   gn_dm_tp_amb          Empresa.dm_tp_amb%TYPE := null;
   --
   gn_empresa_id         Empresa.id%type := null;
   --
   gn_processo_id        log_generico_gpi.processo_id%TYPE := null;
   --
   gv_obj_referencia     log_generico_gpi.obj_referencia%type default 'GUIA_PGTO_IMP';
   --
   gn_referencia_id      log_generico_gpi.referencia_id%type := null;
   --
   gn_tipo_integr        number := null;
   --
   gv_resumo             log_generico_gpi.resumo%type := null;

-------------------------------------------------------------------------------------------------------

-- Declaração de constantes

   erro_de_validacao       constant number := 1;
   erro_de_sistema         constant number := 2;
   nota_fiscal_integrada   constant number := 16;
   informacao              constant number := 35;

------------------------------------------------------------------------------------------------------
   gt_row_guia_pgto_imp    guia_pgto_imp%rowtype;

------------------------------------------------------------------------------------------------------

--| Procedimento seta o "ID de Referencia" utilizado na Validação da Informação
procedure pkb_seta_referencia_id ( en_id in number );

-------------------------------------------------------------------------------------------------------
--| Procedimento seta o tipo de integração que será feito
-- 0 - Somente válida os dados e registra o Log de ocorrência
-- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
-- Todos os procedimentos de integração fazem referência a ele
-------------------------------------------------------------------------------------------------------
procedure pkb_seta_tipo_integr ( en_tipo_integr in number );

-------------------------------------------------------------------------------------------------------

--| Procedimento finaliza o Log Genérico

procedure pkb_finaliza_log_generico_gpi;

-------------------------------------------------------------------------------------------------------

--| Procedimento seta o objeto de referencia utilizado na Validação da Informação  
procedure pkb_seta_obj_ref ( ev_objeto in varchar2 );

-------------------------------------------------------------------------------------------------------

-- Procedimento armazena o valor do "loggenerico_id"

procedure pkb_gt_log_generico_gpi ( en_loggenericogpi_id   in             log_generico_gpi.id%TYPE
                                  , est_log_generico_gpi   in out nocopy  dbms_sql.number_table );

-------------------------------------------------------------------------------------------------------

--| Procedimento de registro de log de erros na validação do ECF

procedure pkb_log_generico_gpi ( sn_loggenericogpi_id   in out nocopy log_generico_gpi.id%TYPE
                               , ev_mensagem            in            log_generico_gpi.mensagem%TYPE
                               , ev_resumo              in            log_generico_gpi.resumo%TYPE
                               , en_tipo_log            in            csf_tipo_log.cd_compat%type      default 1
                               , en_referencia_id       in            log_generico_gpi.referencia_id%TYPE  default null
                               , ev_obj_referencia      in            log_generico_gpi.obj_referencia%TYPE default null
                               , en_empresa_id          in            Empresa.Id%type                  default null
                               , en_dm_impressa         in            log_generico_gpi.dm_impressa%type    default 0 );
                               
----------------------------------------------------------------------------------------------------
-- Procedimento de integração de guia de pagamento de Imposto
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
                                   );

----------------------------------------------------------------------------------------------------
-- Procedimento de estorno de guia de pagamento de Imposto
procedure pkb_estorno_guia_pgto_imp ( est_log_generico_gpi  in out nocopy dbms_sql.number_table
                                    , en_guiapgtoimp_id     in            guia_pgto_imp.id%type);

--
end pk_csf_api_gpi;
/
