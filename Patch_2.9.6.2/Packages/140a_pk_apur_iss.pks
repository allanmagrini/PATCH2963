create or replace package csf_own.pk_apur_iss is

-------------------------------------------------------------------------------------------------------
-- Especifica��o do pacote de procedimentos de Apura��o do ISS
--
-- Em 18/02/2021 - Marcos Ferreira
-- Distribui��es: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #76210 - Altera��o na apura��o de ISS Simplificada para adequar � Apura��o de ISS de outro municipio
-- Rotinas Alteradas: pkg_apur_iss_out_mun, pkg_gera_guia_pgto
--
-- Em 12/02/2021 - Marcos Ferreira
-- Distribui��es: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #74916 - Mudar origem de ISS proprio
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 10/02/2021 - Marcos Ferreira
-- Distribui��es: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #74220 - Altera��o no processo de gera��o de Guia de Impostos Retidos
-- Rotinas Alteradas: pkg_gera_guia_pgto
-- Altera��o: Inclus�o do campo dm_origem nos cursores
--
-- Em 08/02/2021 - Marcos Ferreira
-- Distribui��es: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #73588 - Criar Origem de Dados para ISS Retido para Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 15/12/2020 - Marcos Ferreira
-- Distribui��es: 2.9.6 / 2.9.5-3 / 2.9.4-6
-- Redmine #73506: Detalhamento de ISS por municipio
-- Rotinas Alteradas: Cria��o da procedure pkg_apur_iss_out_mun. Altera��o da procedure pkg_gera_guia_pgto
--
-- Em 27/11/2020 - Marcos Ferreira
-- Distribui��es: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine 73369: Adicionar a parametriza��o da Conta Cont�bil que ser� vinculada a Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 22/11/2020     - Jo�o Carlos
-- Distribui��es     - 2.9.6 / 2.9.5-3 / 2.9.4-6
-- Redmine #73566    - Adicionada condi��o and sit.cd in ('00', '01', '06', '07', '08') -- 00-Documento regular, 01-Documento regular extemporaneo, 06-NF-e ou CT-e Numera��o inutilizada, 07-Documento Fiscal Complementar extemporaneo e 08-Documento Fiscal emitido com base em Regime Especial ou Norma Especifica
--                   - Retornar somente os documento regulares.
-- Rotinas Alteradas - cursor c_apur_iss
-- Em 26/08/2020 - Marcos Ferreira
-- Distribui��es: 2.9.5 / 2.9.4.2
-- Redmine #70423	Criar procedimento de apura��o de ISS
-- Rotinas Cria��o da package e das procedures
--
--
-------------------------------------------------------------------------------------------------------
   -- GLOBAL VARIAVEIS
   --
   gn_loggenerico_id   log_generico_apur_iss.id%TYPE;
   gv_obj_referencia   log_generico_apur_iss.obj_referencia%type := 'APUR_ISS_SIMPLIFICADA';
   gn_referencia_id    log_generico_apur_iss.referencia_id%type;
   gn_processo_id      log_generico_apur_iss.processo_id%type;
   gv_mensagem_log     log_generico_apur_iss.mensagem%type;
   gv_resumo_log       log_generico_apur_iss.resumo%type;
   gn_erro             number := 0;
   gn_empresa_id       empresa.id%type;
   --
   ERRO_DE_VALIDACAO   CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA     CONSTANT NUMBER := 2;
   INFORMACAO          CONSTANT NUMBER := 35;
   --

-------------------------------------------------------------------------------------------------------
   -- CURSORES
   --
   -- Cursor para apura��o do ISS --
   cursor c_apur_iss (en_apurisssimplificada_id apur_iss_simplificada.id%type) is
   select sum(case when imp.dm_tipo = 0 then nvl(sum(imp.vl_imp_trib),0) else 0 end)  vl_iss_proprio
        , sum(case when imp.dm_tipo    = 1
                and nf.dm_ind_emit     = 1
          then nvl(sum(imp.vl_imp_trib),0) else 0 end)                                vl_iss_retido
     from APUR_ISS_SIMPLIFICADA ais,
          NOTA_FISCAL            nf,
          ITEM_NOTA_FISCAL      inf,
          IMP_ITEMNF            imp,
          MOD_FISCAL             mf,
          TIPO_IMPOSTO           tp,
          SIT_DOCTO             sit,
          EMPRESA                 e,
          PESSOA                  p,
          CIDADE                  c
   where inf.notafiscal_id  = nf.id
     and imp.itemnf_id      = inf.id
     and mf.id              = nf.modfiscal_id
     and tp.id              = imp.tipoimp_id
     and sit.id             = nf.sitdocto_id
     and e.id               = nf.empresa_id
     and p.id               = e.pessoa_id
     and c.id               = p.cidade_id
     and c.ibge_cidade      = nvl(inf.cidade_ibge, c.ibge_cidade)
     and sit.cd             in ('00', '01', '06', '07', '08') -- 00-Documento regular, 01-Documento regular extemporaneo, 06-NF-e ou CT-e Numera��o inutilizada, 07-Documento Fiscal Complementar extemporaneo e 08-Documento Fiscal emitido com base em Regime Especial ou Norma Especifica #73566
     and mf.cod_mod         = '99' -- nota fiscal de servico
     and tp.cd              = '6'  -- ISS
     and nf.dm_st_proc      = 4    -- Somente nota autorizadas
     and nf.dm_arm_nfe_terc = 0
     and ais.id             = en_apurisssimplificada_id 
     and nf.empresa_id      = ais.empresa_id
     and nf.dt_emiss        between ais.dt_inicio
                                and ais.dt_fim
   group by imp.dm_tipo, nf.dm_arm_nfe_terc, nf.dm_ind_emit
   having case when imp.dm_tipo = 0 then nvl(sum(imp.vl_imp_trib),0) else 0 end > 0
       or case when imp.dm_tipo        = 1
                and nf.dm_ind_emit     = 1
          then nvl(sum(imp.vl_imp_trib),0) else 0 end > 0;  
   --        
   -- Cursor para valida��o da apura��o do ISS
   cursor c_valida_apur (en_apurisssimplificada_id apur_iss_simplificada.id%type)  is
   select * 
      from APUR_ISS_SIMPLIFICADA ais
   where ais.id = en_apurisssimplificada_id;   
   --   
   -- Cursor para apura��o do ISS 
   cursor c_apur_iss_ret_out_mun (en_apurisssimplificada_id apur_iss_simplificada.id%type) is
   select c.id cidade_id
        , sum(ii.vl_imp_trib) vl_imposto
     from APUR_ISS_SIMPLIFICADA ais
        , NOTA_FISCAL            nf
        , ITEM_NOTA_FISCAL      inf
        , IMP_ITEMNF             ii
        , TIPO_IMPOSTO           ti
        , EMPRESA                 e
        , PESSOA                  p
        , CIDADE                  c
   where nf.empresa_id     = ais.empresa_id
     and inf.notafiscal_id = nf.id
     and ii.itemnf_id      = inf.id
     and ti.id             = ii.tipoimp_id
     and e.id              = nf.empresa_id
     and p.id              = e.pessoa_id
     and c.id              = p.cidade_id
     and nf.dt_emiss       between ais.dt_inicio
                               and ais.dt_fim
     and ti.cd              = '6' -- ISS
     and ii.dm_tipo         = 1   -- Reten��o
     and nf.dm_st_proc      = 4   -- Somente notas fiscais autorizadas
     and nf.dm_arm_nfe_terc = 0
     and inf.cidade_ibge   != c.ibge_cidade
     and ais.id             = en_apurisssimplificada_id
   group by c.id;
   
              
-------------------------------------------------------------------------------------------------------
-- PROCEDURES
--
-- Procedure para gera��o do Log Gen�rico --
procedure pkb_log_generico_apur_iss ( sn_loggenerico_id     out nocopy log_generico_apur_iss.id%type
                                    , ev_mensagem        in            log_generico_apur_iss.mensagem%type
                                    , ev_resumo          in            log_generico_apur_iss.resumo%type
                                    , en_tipo_log        in            csf_tipo_log.cd_compat%type      default 1
                                    , en_referencia_id   in            log_generico_apur_iss.referencia_id%type  default null
                                    , ev_obj_referencia  in            log_generico_apur_iss.obj_referencia%type default null
                                    , en_empresa_id      in            empresa.id%type                  default null
                                    , en_dm_impressa     in            log_generico_apur_iss.dm_impressa%type    default 0);


-------------------------------------------------------------------------------------------------------
-- Procedure para gerar apura��o do Iss Simplificado
--
procedure pkb_apur_iss_simplificada ( en_apurisssimplificada_id apur_iss_simplificada.id%type); 
-------------------------------------------------------------------------------------------------------
-- Procedure para Validar apura��o do Iss Simplificado
--
procedure pkb_valida_apur_iss_simp (en_apurisssimplificada_id apur_iss_simplificada.id%type); 
-------------------------------------------------------------------------------------------------------
-- Procedure para desfazer apura��o do Iss Simplificado
--
procedure pkb_desfazer_apur_iss_simp (en_apurisssimplificada_id apur_iss_simplificada.id%type);   
-------------------------------------------------------------------------------------------------------
-- Procedure para Gera��o da Guia de Pagamento de Imposto
--
procedure pkg_gera_guia_pgto (en_apurisssimplificada_id apur_iss_simplificada.id%type,
                              en_usuario_id neo_usuario.id%type);
-------------------------------------------------------------------------------------------------------
-- Procedure para Estorno da Guia de Pagamento de Imposto
--
procedure pkg_estorna_guia_pgto (en_apurisssimplificada_id apur_iss_simplificada.id%type,
                                 en_usuario_id neo_usuario.id%type); 
-------------------------------------------------------------------------------------------------------
--
end pk_apur_iss;
/
