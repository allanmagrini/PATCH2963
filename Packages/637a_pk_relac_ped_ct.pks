create or replace package csf_own.pk_relac_ped_ct is
--
-- ==================================================================================================== --
--
-- Especificação do pacote do Relacionamento entre os PEDIDOS e a NOTA FISCAL
-- e chamar os procedimentos para relacionar a Nota Fiscal ao seu pedido
--

-- Em 16/02/2021 - Luiz Armando / Danielle
-- Distribuições: 2.9.5.5 / 2.9.6.2 / 2.9.7
-- Redmine #75424	ajuste nos inserts passando a instrução completa
-- Rotinas Alterada: pkb_duplica_item_cte
--
-- Em 17/08/2020 - Marcos Ferreira
-- Distribuições: 2.9.5 / 2.9.4.2
-- Redmine 70448	Registro de 'Confronto pedidos x CT-e' em que o tomador não possui empresa cadastrada.
-- Rotinas Alterada: Alteração do Cursor c_ct, tratativa de Tomadores.
--
-- Em 06/01/2020 - Marcos Ferreira
-- Redmine #62919: Alterar funcionalidade de duplicar do CTE
-- Alterações: Criação de procedure para duplicar o item do cte.
-- Procedure Criada: pkb_duplica_item_cte
--
-- Em 06/12/2019 - Marcos Ferreira
-- Redmine #60894: Criar CTES que estejam cancelados no confronto
-- Alterações: Criação de procedure para atualizar as notas fiscais canceladas
-- Procedure Criada: pkb_cancela_ctped
-- Procedures Alteradas: pkb_dados_ped_ct: Inclusão da chamada da pkb_cancela_ctped
--
-- Em 06/11/2019 - Marcos Ferreira
-- Redmine #60832 - CTE com nota de emissao propria criando 1 item só
-- Alterações: Incluído a coluna nro_chave_nfe_ref na UK da tabela ITEM_CT_PED e alterado o cursor c_item
--             para considerar mais de uma NFe referenciada pelo CT
--             Alterado o Cursor c_item
--             Alterado checagem de item já existente, incluído o Nro_chave_nfe_ref na condição do where
-- Procedures Alteradas: pkb_dados_item_ct_ped
--
-- Em 11/06/2019 - Karina de Paula
-- Redmine #55294 - Adicionar colunas na NOTA_FISCAL_PED
-- Rotina Alterada: pkb_dados_notafiscal_ped => Incluído os campos vl_imp_trib_st e vl_imp_trib_ii
--
-- Em 05/04/2019 - Karina de Paula
-- Redmine #53169 - Confronto de pedido de compras com XML
--
-- ==================================================================================================== --
--
--Types
   --
   type tab_pedidos is table of pedido%rowtype;
   --
----------------------------------------------------------------------------------------------------
-- Constantes Globais --
   --
   ERRO_DE_VALIDACAO               constant number := 1;
   ERRO_DE_SISTEMA                 constant number := 2;
   INFORMACAO                      constant number := 35;
   MODULO_SISTEMA                  constant number := pk_csf.fkg_ret_id_modulo_sistema('PEDIDO_COMPRA');
   GRUPO_SISTEMA_TOLERANCIA        constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'MARGEM_TOLERANCIA');
   --

-- Variaveis Globais
   --
   gn_empresa_id                   empresa.id%type;
   gn_multorg_id                   mult_org.id%type;
   gn_pessoa_id                    nota_fiscal_ped.pessoa_id%type; 
   gn_modfiscal_id                 nota_fiscal_ped.modfiscal_id%type;
   gn_conhectransp_id              conhec_transp.id%type;
   gn_notafiscal_id                nota_fiscal.id%type;
   gv_cnpj                         nota_fiscal_ped.cnpj%type;
   gn_finalidade_id                pedido.finalidade_id%type;
   gn_dm_mod_frete                 pedido.dm_mod_frete%type;
   gn_dm_obrig_pedido              NUMBER; --VOLTAR
   gn_erro                         NUMBER;
   gn_aux                          NUMBER;
   gv_aux                          VARCHAR2(255);
   gv_erro                         log_generico_ct.resumo%type;   
   gn_loggenerico_id               log_generico_ct.id%TYPE;
   gv_mensagem_log                 log_generico_ct.mensagem%type;
   gv_resumo_log                   log_generico_ct.resumo%type;
   gv_obj_referencia               log_generico_ct.obj_referencia%type default 'CONHEC_TRANSP_PED';
   gn_referencia_id                log_generico_ct.referencia_id%type;
   gn_param_receb                  param_receb.id%type;
   vt_tab_pedido                   tab_pedidos;
   gv_aspas                        char(1) := null;
   gv_sql                          varchar2(10000) := null;
   gv_sql_tab                      varchar2(100)   := null;
   gv_sql_values                   varchar2(100)   := null;
   gv_sql_col                      varchar2(1500)  := null;
   gv_col_vetor                    varchar2(10000) := null;
   gt_row_conhectransp_ped         conhec_transp_ped%rowtype;
   gt_row_item_ct_ped              item_ct_ped%rowtype;
   gt_row_nota_fiscal              nota_fiscal%rowtype;
   gt_row_param_receb              param_receb%rowtype;
   gt_row_c_param_receb_itm        pk_csf_pedido.c_param_receb_itm%rowtype;
   gt_row_item_pedido              item_pedido%rowtype;
   --
   type t_tab_csf_nf_forma_pgto_ped is table of nf_forma_pgto%rowtype index by binary_integer;
   vt_tab_csf_nf_forma_pgto_ped t_tab_csf_nf_forma_pgto_ped;
   --
   --
   type tab_csf_pedido_relac is record ( id	            pedido.id%type
                                       , empresa_id	   pedido.empresa_id%type
                                       , pessoa_id	      pedido.pessoa_id%type
                                       , nro_pedido	   pedido.nro_pedido%type
                                       , dt_emiss	      pedido.dt_emiss%type
                                       , qtd_total	      pedido.qtd_total%type
                                       , vlr_total	      pedido.vlr_total%type
                                       , dm_st_proc	   pedido.dm_st_proc%type
                                       , dm_mod_frete	   pedido.dm_mod_frete%type
                                       , finalidade_id	pedido.finalidade_id%type );
   --
   type t_tab_csf_pedido_relac is table of tab_csf_pedido_relac index by binary_integer;
   vt_tab_csf_pedido_relac t_tab_csf_pedido_relac;
   --
------------------------------------------------------------------------------------------------------------
-- Cursores Globais
------------------------------------------------------------------------------------------------------------
   -- Cursor para buscar as empresas que utilizam o sistema Gestão de Pedidos de Compras
   cursor c_empresa ( en_multorg_id mult_org.id%type ) is
   select id
     from empresa e
    where pk_csf_pedido.fkg_ret_param_habil_pedidos   (e.id ) = 1
      and pk_csf_pedido.fkg_ret_param_habil_confronto (e.id ) = 1
      and e.multorg_id                                        = en_multorg_id;
   --
   --
   -- Cursor para buscar os Ctes para fazer o Confronto 
   cursor c_inicia_ct ( en_empresa_id conhec_transp.empresa_id%type ) is
      select ctp.conhectransp_id
           , ctp.id  conhectranspped_id
        from conhec_transp_ped     ctp   
      where ctp.empresa_id = en_empresa_id
        and ctp.dm_st_proc in (0,1)  
      UNION ALL ------------------------------------------------     
      select ct.id   conhectransp_id
           , null    conhectranspped_id
        from conhec_transp         ct
       where ct.dm_arm_cte_terc      = 1
         and ct.dm_rec_xml           = 1
         and ct.dm_st_proc          in (4,7)
         and ct.empresa_id           = en_empresa_id
         and ct.dt_hr_emissao        > to_date('01/01/2019','dd/mm/yyyy')
         and not exists (
           select 1
              from conhec_transp_ped ctp2
           where ctp2.conhectransp_id = ct.id);
   --        
   -- Cursor para recuperar o conhecimento de transporte (Header)
   cursor c_ct ( en_conhectransp_id conhec_transp.id%type ) is
   select ct.id conhectransp_id
        , ct.empresa_id
        , ct.dt_hr_emissao
        , ct.modfiscal_id
        , ctp.paramreceb_id
        , ctp.dt_receb
        , ctp.dm_edicao
        , e.multorg_id
        , ct.cfop_id
        , ctp.id conhectranspped_id
        , nvl(ctp.placa, ctv.placa) placa
        , nvl(ctp.uf, ctv.uf)       uf
     from conhec_transp         ct
        , conhec_transp_rodo   ctr
        , ctrodo_veic          ctv
        , conhec_transp_ped    ctp
        , empresa                e
        , conhec_transp_rem     ct0  -- usar o cnpj quando dm_tomador = 0
        , conhec_transp_exped   ct1  -- usar o cnpj quando dm_tomador = 1
        , conhec_transp_receb   ct2  -- usar o cnpj quando dm_tomador = 2
        , conhec_transp_dest    ct3  -- usar o cnpj quando dm_tomador = 3
        , conhec_transp_tomador ct4  -- usar o cnpj quando dm_tomador = 4       
    where ctp.conhectransp_id     (+) = ct.id
      and ctr.conhectransp_id     (+) = ct.id
      and ctv.conhectransprodo_id (+) = ctr.id
      and e.id                        = ct.empresa_id
      and ct0.conhectransp_id     (+) = ct.id
      and ct1.conhectransp_id     (+) = ct.id
      and ct2.conhectransp_id     (+) = ct.id
      and ct3.conhectransp_id     (+) = ct.id
      and ct4.conhectransp_id     (+) = ct.id
      and ct.dm_st_proc              in (4,7)
      and ct.id                       = en_conhectransp_id
   --
      and (
              (ct.dm_tomador = 0 and nvl(pk_csf.fkg_empresa_id_pelo_cpf_cnpj(e.multorg_id, ct0.cnpj),0) > 0) or
              (ct.dm_tomador = 1 and nvl(pk_csf.fkg_empresa_id_pelo_cpf_cnpj(e.multorg_id, ct1.cnpj),0) > 0) or
              (ct.dm_tomador = 2 and nvl(pk_csf.fkg_empresa_id_pelo_cpf_cnpj(e.multorg_id, ct2.cnpj),0) > 0) or
              (ct.dm_tomador = 3 and nvl(pk_csf.fkg_empresa_id_pelo_cpf_cnpj(e.multorg_id, ct3.cnpj),0) > 0) or
              (ct.dm_tomador = 4 and nvl(pk_csf.fkg_empresa_id_pelo_cpf_cnpj(e.multorg_id, ct4.cnpj),0) > 0) 
          );   
   --
   --
   -- Cursor para recuperar o conhecimento de transporte e seus detalhes
   cursor c_item ( en_conhectransp_id      conhec_transp.id%type
                 , en_conhectranspped_id   conhec_transp_ped.id%type ) 
   is
      -- Conhecimento de Transporte sem vinculo com nota fiscal
      select  ct.id                                                                      conhectransp_id
            , nf.id                                                                      notafiscal_id
            , nf.dm_ind_emit                                                             dm_ind_emit
            , nvl(icp.vl_prest_serv,nvl(ctv.vl_prest_serv,0))                            vl_prest_serv
            , nvl(icp.vl_receb, nvl(ctv.vl_receb,0))                                     vl_receb
            , cti.tipoimp_id                                                             tipoimp_id
            , cti.codst_id                                                               codst_id
            , nvl(icp.vl_base_calc, nvl(cti.vl_base_calc,0))                             vl_base_calc
            , nvl(icp.aliq_apli, nvl(cti.aliq_apli,0))                                   aliq_apli
            , nvl(icp.vl_imp_trib, nvl(cti.vl_imp_trib,0))                               vl_imp_trib
            , icp.vl_total_merc                                                          vl_total_merc
            , icp.vl_carga_averb                                                         vl_carga_averb
            , ctq.dm_cod_unid                                                            dm_cod_unid
            , ctq.tipo_medida                                                            tipo_medida
            , nvl(icp.qtde_carga, nvl(ctq.qtde_carga,0))                                 qtde_carga
            , ctp.id                                                                     conhectranspped_id
            , icp.id                                                                     itemctped_id
            , icp.itempedido_id                                                          itempedido_id
            , e.multorg_id                                                               multorg_id
            , ct.modfiscal_id                                                            modfiscal_id
            , ct.cfop_id                                                                 cfop_id
            , null                                                                       utilizacaofiscal_id
            , null                                                                       itemnotafiscal_id
            , icp.itemnfped_id                                                           itemnfped_id
            , null                                                                       item_id
            , null                                                                       notafiscalped_id
            , icp.depositoerp_id                                                         depositoerp_id
            , nf.nro_chave_nfe                                                           nro_chave_nfe
            , icp.nro_item                                                               nro_item
            , 1                                                                          fator
            , 1                                                                          query
        from CONHEC_TRANSP                                  ct
           , CONHEC_TRANSP_PED                             ctp
           , ITEM_CT_PED                                   icp
           , CT_INF_NFE                                     ci
           , CONHEC_TRANSP_IMP                             cti
           , CONHEC_TRANSP_VLPREST                         ctv
           , CONHEC_TRANSP_INFCARGA                        ctc
           , EMPRESA                                         e
           , NOTA_FISCAL                                    nf
           , (select ctq.conhectranspinfcarga_id 
                   , ctq.dm_cod_unid
                   , ctq.tipo_medida 
                   , ctq.qtde_carga
                 from CTINFCARGA_QTDE ctq
              where ctq.dm_cod_unid        = (select min(ctq2.dm_cod_unid)
                                                from CTINFCARGA_QTDE ctq2
                                              where ctq2.conhectranspinfcarga_id = ctq.conhectranspinfcarga_id)) ctq
       where ctp.conhectransp_id            (+) = ct.id
         and icp.conhectranspped_id         (+) = ctp.id
         and ci.conhectransp_id             (+) = ctp.conhectransp_id
         and cti.conhectransp_id            (+) = ct.id
         and ctv.conhectransp_id            (+) = ct.id
         and ctc.conhectransp_id            (+) = ct.id
         and e.id                           (+) = ct.empresa_id
         and nf.nro_chave_nfe               (+) = ci.nro_chave_nfe
         and ctq.conhectranspinfcarga_id    (+) = ctc.id
         and ct.dm_arm_cte_terc                 = 1
         and ct.dm_rec_xml                      = 1
         and ct.dm_st_proc                     in (4,7)
         and nf.id                              is null
         and ct.id                              = en_conhectransp_id
UNION ALL--------------------------------------------------------------------------------------------
      -- Conhecimento de transporte vinculados a nota fiscal de terceiros
      select  ct.id                                                                      conhectransp_id
            , nf.id                                                                      notafiscal_id
            , nf.dm_ind_emit                                                             dm_ind_emit
            , nvl(icp.vl_prest_serv, nvl(ctv.vl_prest_serv,0)    * nvl(vft.fator,1))     vl_prest_serv
            , nvl(icp.vl_receb, nvl(ctv.vl_receb,0)              * nvl(vft.fator,1))     vl_receb
            , cti.tipoimp_id                                                             tipoimp_id
            , cti.codst_id                                                               codst_id
            , nvl(icp.vl_base_calc, nvl(cti.vl_base_calc,0)      * nvl(vft.fator,1))     vl_base_calc
            , nvl(icp.aliq_apli, nvl(cti.aliq_apli,0))                                   aliq_apli
            , nvl(icp.vl_imp_trib, nvl(cti.vl_imp_trib,0)        * nvl(vft.fator,1))     vl_imp_trib
            , null                                                                       vl_total_merc
            , null                                                                       vl_carga_averb
            , '03'                                                                       dm_cod_unid
            , 'UNIDADE'                                                                  tipo_medida
            , nvl(icp.qtde_carga, nvl(inp.qtde_convert, inp.qtde_comerc))                qtde_carga
            , ctp.id                                                                     conhectranspped_id
            , null                                                                       itemctped_id
            , icp.itempedido_id                                                          itempedido_id
            , e.multorg_id                                                               multorg_id
            , ct.modfiscal_id                                                            modfiscal_id
            , ct.cfop_id                                                                 cfop_id
            , null                                                                       utilizacaofiscal_id
            , inp.itemnf_id                                                              itemnotafiscal_id
            , nvl(icp.itemnfped_id, inp.id)                                              itemnfped_id
            , inp.item_id                                                                item_id
            , nfp.id                                                                     notafiscalped_id
            , inp.depositoerp_id                                                         depositoerp_id
            , nf.nro_chave_nfe                                                           nro_chave_nfe
            , icp.nro_item                                                               nro_item
            , vft.fator                                                                  fator
            , 2                                                                          query
        from CONHEC_TRANSP                                  ct
           , CONHEC_TRANSP_PED                             ctp
           , ITEM_CT_PED                                   icp
           , CT_INF_NFE_PED                                 ci
           , NOTA_FISCAL_PED                               nfp
           , NOTA_FISCAL                                    nf
           , ITEM_NF_PED                                   inp
           , CONHEC_TRANSP_IMP                             cti
           , CONHEC_TRANSP_VLPREST                         ctv
           , CONHEC_TRANSP_INFCARGA                        ctc
           , EMPRESA                                         e  
           , (select inp2.notafiscalped_id, inp2.id itemnfped_id 
                 , ((inp2.vl_item_bruto / (select sum(inp3.vl_item_bruto) 
                                          from ITEM_NF_PED inp3
                                        where inp3.notafiscalped_id = inp2.notafiscalped_id))/
                   (select count(1) 
                      from CT_INF_NFE cin
                    where cin.conhectransp_id   = cin2.conhectransp_id))  fator
               from CT_INF_NFE      cin2            
                  , NOTA_FISCAL      nf2
                  , NOTA_FISCAL_PED nfp2
                  , ITEM_NF_PED     inp2
               where nf2.nro_chave_nfe     = cin2.nro_chave_nfe
                 and (
                       (nf2.dm_arm_nfe_terc = 1 and nf2.dm_ind_emit = 1)
                  or
                       (nf2.dm_arm_nfe_terc = 0 and nf2.dm_ind_emit = 0)
                     )
                 and nfp2.notafiscal_id    = nf2.id
                 and inp2.notafiscalped_id = nfp2.id
                 and cin2.conhectransp_id  = en_conhectransp_id) vft      
       where 1=1
         and ctp.conhectransp_id                = ct.id
         and icp.conhectranspped_id         (+) = ctp.id
         and ci.conhectranspped_id              = ctp.id
         and nfp.notafiscal_id              (+) = ci.notafiscal_id
         and nf.id                          (+) = nfp.notafiscal_id
         and inp.notafiscalped_id           (+) = nfp.id
         and nvl(icp.itemnfped_id, inp.id)      = nvl(inp.id, icp.itemnfped_id) -- alter join manual
         and cti.conhectransp_id            (+) = ct.id
         and ctv.conhectransp_id            (+) = ct.id
         and ctc.conhectransp_id            (+) = ct.id
         and e.id                           (+) = ct.empresa_id
         and vft.notafiscalped_id           (+) = inp.notafiscalped_id
         and vft.itemnfped_id               (+) = inp.id
         and ct.dm_arm_cte_terc                 = 1
         and ct.dm_rec_xml                      = 1
         and ct.dm_st_proc                     in (4,7)
         and ci.notafiscal_id                   is not null
         and nf.dm_ind_emit                     = 1
         and ct.id                              = en_conhectransp_id
UNION ALL--------------------------------------------------------------------------------------------
      -- Conhecimento de transporte vinculados a nota fiscal de emissão própria
      select  ct.id                                                                      conhectransp_id
            , nf.id                                                                      notafiscal_id
            , nf.dm_ind_emit                                                             dm_ind_emit
            , nvl(icp.vl_prest_serv, nvl(nvl(ctv.vl_prest_serv,0)    * vft.fator,0))     vl_prest_serv
            , nvl(icp.vl_receb, nvl(nvl(ctv.vl_receb,0)              * vft.fator,0))     vl_receb
            , cti.tipoimp_id                                                             tipoimp_id
            , cti.codst_id                                                               codst_id
            , nvl(icp.vl_base_calc, nvl(nvl(cti.vl_base_calc,0)      * vft.fator,0))     vl_base_calc
            , nvl(icp.aliq_apli, nvl(cti.aliq_apli,0))                                   aliq_apli
            , nvl(icp.vl_imp_trib, nvl(nvl(cti.vl_imp_trib,0)        * vft.fator,0))     vl_imp_trib
            , icp.vl_total_merc                                                          vl_total_merc
            , icp.vl_carga_averb                                                         vl_carga_averb
            , '03'                                                                       dm_cod_unid
            , 'UNIDADE'                                                                  tipo_medida
            , inf.qtde_comerc                                                            qtde_carga
            , ctp.id                                                                     conhectranspped_id
            , null                                                                       itemctped_id
            , icp.itempedido_id                                                          itempedido_id
            , e.multorg_id                                                               multorg_id
            , ct.modfiscal_id                                                            modfiscal_id
            , ct.cfop_id                                                                 cfop_id
            , icp.utilizacaofiscal_id                                                    utilizacaofiscal_id
            , inf.id                                                                     itemnotafiscal_id
            , icp.itemnfped_id                                                           itemnfped_id
            , inf.item_id                                                                item_id
            , null                                                                       notafiscalped_id
            , icp.depositoerp_id                                                         depositoerp_id
            , nf.nro_chave_nfe                                                           nro_chave_nfe
            , icp.nro_item                                                               nro_item
            , vft.fator                                                                  fator
            , 3                                                                          query
        from CONHEC_TRANSP                                  ct
           , CONHEC_TRANSP_PED                             ctp
           , ITEM_CT_PED                                   icp
           , CT_INF_NFE                                     ci
           , NOTA_FISCAL                                    nf
           , ITEM_NOTA_FISCAL                              inf
           , CONHEC_TRANSP_IMP                             cti
           , CONHEC_TRANSP_VLPREST                         ctv
           , CONHEC_TRANSP_INFCARGA                        ctc
           , EMPRESA                                         e  
           , (select inf2.notafiscal_id, inf2.id itemnotafiscal_id                                     
                  , (inf2.vl_item_bruto / (select sum(inf3.vl_item_bruto)
                                             from ITEM_NOTA_FISCAL inf3
                                                , NOTA_FISCAL       nf3  
                                                , CT_INF_NFE        cin3
                                           where nf3.id = inf3.notafiscal_id
                                             and cin3.nro_chave_nfe = nf3.nro_chave_nfe
                                             and cin3.conhectransp_id = cin2.conhectransp_id)) fator
                from CT_INF_NFE           cin2
                   , NOTA_FISCAL           nf2
                   , ITEM_NOTA_FISCAL     inf2
                where nf2.nro_chave_nfe    = cin2.nro_chave_nfe
                  and inf2.notafiscal_id   = nf2.id
                  and cin2.conhectransp_id = en_conhectransp_id) vft  
       where 1=1
         and ctp.conhectransp_id            (+) = ct.id
         and icp.conhectranspped_id         (+) = ctp.id
         and ci.conhectransp_id                 = ct.id
         and nf.nro_chave_nfe                   = ci.nro_chave_nfe
         and inf.notafiscal_id              (+) = nf.id
         and cti.conhectransp_id            (+) = ct.id
         and ctv.conhectransp_id            (+) = ct.id
         and ctc.conhectransp_id            (+) = ct.id
         and e.id                           (+) = ct.empresa_id
         and vft.notafiscal_id              (+) = inf.notafiscal_id
         and vft.itemnotafiscal_id          (+) = inf.id
         and ct.dm_arm_cte_terc                 = 1
         and ct.dm_rec_xml                      = 1
         and ct.dm_st_proc                      in (4,7)
         and ci.nro_chave_nfe                   is not null
         and nf.dm_ind_emit                     = 0
         and ct.id                              = en_conhectransp_id;
      --
      --
----------------------------------------------------------------------------------------------------------
-- Função que retorna o proximo nro_item do item_ct_ped
----------------------------------------------------------------------------------------------------------
function fkg_ret_proximo_nro_item (en_conhectranspped_id in conhec_transp_ped.id%type ) return number;
--
-- Procedimento de validação das Regras para Relacionar o Conhecimento de Transporte ao Pedido
----------------------------------------------------------------------------------------------------------
procedure pkb_valid_regra ( en_empresa_id         in     empresa.id%type
                          , en_conhectransp_id    in     conhec_transp.id%type
                          , en_conhectranspped_id in out conhec_transp_ped.id%type
                          );
--
-- Procedimento que identifica dados de pedido e do conhecimento de transporte para relacionar
----------------------------------------------------------------------------------------------------------
procedure pkb_dados_ped_ct ( en_multorg_id mult_org.id%type );
--
----------------------------------------------------------------------------------------------------------
-- Procedimento para resetar o Conhecimento de Transporte e Reprocessá-lo
procedure pkb_reinicia_cte ( en_conhectranspped_id  in conhec_transp_ped.id%type
                           , eb_recria_cte          in boolean default true);

--
-- Procedimento que duplica um ítem do CTe para liberar um recebimento a maior
----------------------------------------------------------------------------------------------------------
procedure pkb_duplica_item_cte ( en_itemctped_id in item_ct_ped.id%type
                               , en_vlr_item     in item_ct_ped.vl_prest_serv%type);
--
end pk_relac_ped_ct;
/
