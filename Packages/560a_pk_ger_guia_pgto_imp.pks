create or replace package csf_own.pk_ger_guia_pgto_imp is

----------------------------------------------------------------------------------------------------
-- Especificação do pacote geração das guias de pagamento de Impostos
--
-- Em 23/02/2021 - Marcos Ferreira
-- Distribuições: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #76180 - Adequação do modelo antigo ao padrão novo utilizando pgto_imp_ret
-- Rotinas Alteradas: pkb_monta_guia_pgto_imp e type vt_tri_tab_csf_guia_pgto_imp
--
-- Em 08/02/2021 - Marcos Ferreira
-- Distribuições: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #73588 - Criar Origem de Dados para ISS Retido para Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 02/12/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-3 / 2.9.4-6
-- Redmine #72795: Geração de guia a partir de retenção de INSS em documento fiscal
-- Rotinas Alteradas: 
--
-- Em 18/10/2019 - Renan Alves
-- Redmine #60082 - Debug - Geração de guia de pagamento de impostos
-- Foi alterado o tipo dos types t_tab_csf_guia_pgto_imp, t_bi_tab_csf_guia_pgto_imp,
-- t_tri_tab_csf_guia_pgto_imp de BINARY_INTEGER para PLS_INTEGER
--
-- Em 03/04/2017 - Fábio Tavares 
-- Redmine #29824 e #29832 - Geração Guias de Impostos Retido- Logs e Desprocessamento-Geração Guia Imposto Retido.
-- Rotinas: pkb_monta_guia_pgto_imp e pkb_desfazer.
--
  ----------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------
  --
  gt_row_ger_guia_pgto_imp ger_guia_pgto_imp%rowtype;
  --
  ----------------------------------------------------------------------------------------------------
  -- 
  type tab_r_guia_pgto_imp is record(
    ID                NUMBER,
    GUIAPGTOIMP_ID    NUMBER,
    GERGUIAPGTOIMP_ID NUMBER,
    OBJ_REFERENCIA    VARCHAR2(30),
    REFERENCIA_ID     NUMBER);
  --
  type t_tab_r_guia_pgto_imp is table of tab_r_guia_pgto_imp index by varchar2(200); --binary_integer;
  type t_bi_tab_r_guia_pgto_imp is table of t_tab_r_guia_pgto_imp index by varchar2(200); --binary_integer;
  vt_bi_tab_r_guia_pgto_imp t_bi_tab_r_guia_pgto_imp;
  --
  TYPE tab_csf_guia_pgto_imp IS record(
    ID                   NUMBER,
    EMPRESA_ID           NUMBER,
    USUARIO_ID           NUMBER,
    DM_SITUACAO          NUMBER(1),
    TIPOIMPOSTO_ID       NUMBER,
    TIPORETIMP_ID        NUMBER,
    TIPORETIMPRECEITA_ID NUMBER,
    PESSOA_ID            NUMBER,
    DM_TIPO              NUMBER(1),
    DM_ORIGEM            NUMBER(2),
    NRO_VIA_IMPRESSA     NUMBER(3),
    DT_REF               DATE,
    DT_VCTO              DATE,
    VL_PRINC             NUMBER(15, 2),
    VL_MULTA             NUMBER(15, 2),
    VL_JURO              NUMBER(15, 2),
    VL_OUTRO             NUMBER(15, 2),
    VL_TOTAL             NUMBER(15, 2),
    OBS                  VARCHAR2(500),
    PESSOA_ID_SEFAZ      NUMBER,
    NRO_TIT_FINANC       NUMBER,
    DT_ALTERACAO         DATE,
    DM_RET_ERP           NUMBER,
    ID_ERP               NUMBER,
    PLANOCONTA_ID        NUMBER,
    GERGUIAPGTOIMP_ID    NUMBER,
    NOTAFISCAL_ID        NUMBER,
    CONHECTRANSP_ID      NUMBER);
  --
  type t_tab_csf_guia_pgto_imp is table of tab_csf_guia_pgto_imp index by varchar2(200); --binary_integer;
  type t_bi_tab_csf_guia_pgto_imp is table of t_tab_csf_guia_pgto_imp index by varchar2(200); --binary_integer;
  type t_tri_tab_csf_guia_pgto_imp is table of t_bi_tab_csf_guia_pgto_imp index by varchar2(200); --binary_integer;
  --
  --
  vt_tri_tab_csf_guia_pgto_imp t_tri_tab_csf_guia_pgto_imp;
  --
  -- 
  ----------------------------------------------------------------------------------------------------
   -- CURSORES
   ----------------------------------------------------------------------------------------------------
   cursor c_docfis (en_gerguiapgtoimp_id ger_guia_pgto_imp.id%type) is
      select 'NF'                                      tipo_docfis             
           , ggpi.id                                   gerguiapgtoimp_id
           , ggpi.empresa_id
           , nf.id                                     documentofiscal_id
           , nf.pessoa_id
           , ti.id                                     tipoimp_id
           , nvl(ii.tiporetimp_id, pdgi.tiporetimp_id) tiporetimp_id
           , pdgi.dm_origem
           , last_day(ggpi.dt_ini)                      dt_ref
           , pdgi.obs
           , pdgi.pessoa_id_sefaz
           , pdgi.planoconta_id
           , ggpi.dt_ini
           , ggpi.dt_fin
           , ii.tiporetimpreceita_id
           , pdgi.dia_vcto
           , add_months(ggpi.dt_fin,1)                 dt_vcto
           , sum(ii.vl_imp_trib)                       vl_princ
        from GER_GUIA_PGTO_IMP   ggpi
            ,NOTA_FISCAL           nf
            ,ITEM_NOTA_FISCAL     inf
            ,IMP_ITEMNF            ii
            ,PARAM_GUIA_PGTO       pgp
            ,PARAM_DET_GUIA_IMP   pdgi
            ,MOD_FISCAL             mf
            ,TIPO_IMPOSTO           ti
      where nf.empresa_id                   = ggpi.empresa_id
        and trunc(nf.dt_emiss) between ggpi.dt_ini 
                                   and ggpi.dt_fin
        and inf.notafiscal_id               = nf.id
        and ii.itemnf_id                    = inf.id
        and pgp.empresa_id                  = ggpi.empresa_id
        and pdgi.paramguiapgto_id           = pgp.id
        and mf.id                           = nf.modfiscal_id
        and ti.id                           = ii.tipoimp_id
        and mf.cod_mod                      in ('01','55','99') -- Notas fiscais Mercantil, Conjugada, Serviço
        and ti.cd                           = '13'              -- INSS Retido.
        and pdgi.dm_origem                  = 10                -- INSS Retido em Nota Serviço
        and nf.dm_st_proc                   = 4                 -- Somemente notas Autorizadas
        and nf.dm_arm_nfe_terc              = 0                 -- Não pegar notas de armazenamento
        and ggpi.id                         = en_gerguiapgtoimp_id
     having nvl(sum(ii.vl_imp_trib),0) > 0
     group by 'NF'  
              , ggpi.id  
              , ggpi.empresa_id
              , nf.id
              , nf.pessoa_id
              , ti.id
              , nvl(ii.tiporetimp_id, pdgi.tiporetimp_id)
              , pdgi.dm_origem
              , last_day(ggpi.dt_ini)
              , pdgi.obs
              , pdgi.pessoa_id_sefaz
              , pdgi.planoconta_id
              , ggpi.dt_ini
              , ggpi.dt_fin  
              , ii.tiporetimp_id
              , ii.tiporetimpreceita_id
              , pdgi.dia_vcto
              , add_months(ggpi.dt_fin,1) 
   UNION ALL -----------------------------------------------------------------------------------------------------        
      select 'CT'                                        tipo_docfis
           , ggpi.id                                     gerguiapgtoimp_id
           , ggpi.empresa_id
           , ct.id                                       documentofiscal_id
           , ct.pessoa_id
           , ti.id                                       tipoimp_id
           , nvl(ctir.tiporetimp_id, pdgi.tiporetimp_id) tiporetimp_id
           , pdgi.dm_origem
           , last_day(ggpi.dt_ini)                       dt_ref
           , pdgi.obs
           , pdgi.pessoa_id_sefaz
           , pdgi.planoconta_id
           , ggpi.dt_ini
           , ggpi.dt_fin
           , ctir.tiporetimpreceita_id
           , pdgi.dia_vcto
           , add_months(ggpi.dt_fin,1)                   dt_vcto
           , sum(ctir.vl_imp)                            vl_princ
        from GER_GUIA_PGTO_IMP     ggpi
           , CONHEC_TRANSP           ct
           , CONHEC_TRANSP_IMP_RET ctir   
           , PARAM_GUIA_PGTO        pgp
           , PARAM_DET_GUIA_IMP    pdgi
           , MOD_FISCAL              mf
           , TIPO_IMPOSTO            ti
      where ct.empresa_id                   = ggpi.empresa_id
        and trunc(ct.dt_hr_emissao)         between ggpi.dt_ini 
                                                and ggpi.dt_fin
        and ctir.conhectransp_id            = ct.id    
        and pgp.empresa_id                  = ggpi.empresa_id
        and pdgi.paramguiapgto_id           = pgp.id
        and mf.id                           = ct.modfiscal_id
        and ti.id                           = ctir.tipoimp_id
        and mf.cod_mod                      = '67'              -- Conhecimento de Transporte
        and ti.cd                           = '13'              -- INSS Retido.
        and pdgi.dm_origem                  = 10                -- INSS Retido em Nota Serviço
        and ct.dm_st_proc                   = 4                 -- Somente autorizados
        and ct.dm_arm_cte_terc              = 0                 -- Não pegar ctes de armazenamento
        and ggpi.id                         = en_gerguiapgtoimp_id       
     having nvl(sum(ctir.vl_imp),0) > 0       
     group by  'CT' 
              , ggpi.id  
              , ggpi.empresa_id
              , ct.id
              , ct.pessoa_id
              , ti.id
              , nvl(ctir.tiporetimp_id, pdgi.tiporetimp_id)
              , pdgi.dm_origem
              , last_day(ggpi.dt_ini)
              , pdgi.obs
              , pdgi.pessoa_id_sefaz
              , pdgi.planoconta_id
              , ggpi.dt_ini
              , ggpi.dt_fin
              , ctir.tiporetimp_id
              , ctir.tiporetimpreceita_id
              , pdgi.dia_vcto
              , add_months(ggpi.dt_fin,1)
              ;  
  ----------------------------------------------------------------------------------------------------  
  ----------------------------------------------------------------------------------------------------
  -- Procedimento de geração da Guia de pagamento de Impostos
  procedure pkb_gerar(en_gerguiapgtoimp_id in ger_guia_pgto_imp.id%type,
                      en_usuario_id        in neo_usuario.id%type);
  --
  ----------------------------------------------------------------------------------------------------
  -- Procedimento de desprocessamento da Guia de pagamento de Impostos
  procedure pkb_desfazer(en_gerguiapgtoimp_id in ger_guia_pgto_imp.id%type,
                         en_usuario_id        in neo_usuario.id%type);
  --
  -- Procedure para Geração da Guia de Pagamento de Imposto
  procedure pkg_gera_guia_pgto (en_gerguiapgtoimp_id  in ger_guia_pgto_imp.id%type,
                                en_usuario_id         in neo_usuario.id%type);
  -- 
  
end pk_ger_guia_pgto_imp;
/
