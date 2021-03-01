create or replace package csf_own.pk_relac_ped_nf is
--
-- ==================================================================================================== --
--
-- Especificação do pacote do Relacionamento entre os PEDIDOS e a NOTA FISCAL
-- e chamar os procedimentos para relacionar a Nota Fiscal ao seu pedido
--
-- Em 16/02/2021 - Luiz Armando / Danielle
-- Distribuições: 2.9.5.5 / 2.9.6.2 / 2.9.7
-- Redmine #75424	ajuste nos inserts passando a instrução completa
-- Rotinas Alterada: 
--
-- Em 23/10/2020  - Marcos Ferreira
-- Redmine #71428: Parametro de definição de onde recuperar o imposto a ser descontado no confronto
-- Alterações:    - Alterações de cursores e na Procedure de confronto dos impostos
--
-- Em 09/07/2020  - Wendel Albino
-- Redmine #66872 - Adicionar condição de modelo fiscal na inclusão de evento de MDe para notas do inbound
-- Rotina:        - pkb_valida_mde
-- Alterações:    - adicionar a condicao no cursor para trazer nfs de modelos 55 e 65
--
-- Em 03/07/2020 - Armando / Thiado Denadai
-- Redmine #66357: Adequação de validação para zeramento da quantidade para notas canceladas.
-- Rotina: pkb_valid_regra
-- Alterações: Adequação de validação para zeramento da quantidade para notas canceladas.
--
-- Em 10/02/2020  - Marcos Ferreira
-- Redmine #64643 - Nota sem pedido está validando sem Unidade de Medida
-- Rotina:        - pkb_dados_item_nf_ped
-- Alterações:    - Incluído validação de unidade de medida convertida.
--
-- Em 06/02/20120 - Marcos Ferreira
-- Redmine #64524 - Tratar dm_arm_nfe_terc para nota de serviço
-- Rotina:        - Cursor c_nf na pks
-- Alterações:    - Inclusão do dm_arm_nfe_terc para notas de serviço
--
-- Em 03/01/2020 - Marcos Ferreira
-- Redmine #62916: Alterar funcionalidade de botão duplicar em nota de serviço
-- Alterações: Criado procedure para duplicar item NFS
-- Procedures Criada: pkb_duplica_item_nfs
--
-- Em 13/12/2019 - Marcos Ferreira
-- Redmine #62572: Botão reiniciar documento fiscal - NFE e NFSe
-- Alterações: Criado procedure para reiniciar NFe e NFs
-- Procedures Criada: pkb_reinicia_nfp
--
-- Em 11/12/2019 - Marcos Ferreira
-- Redmine #62461: Criar linhas dos impostos zerados
-- Alterações: Criado insert para impostos zerados de novos tipos e retenções
-- Procedures Alteradas: pkb_dados_imp_itemnf_ped
--
-- Em 06/12/2019 - Marcos Ferreira
-- Redmine 61922: NFE cancelada não atualizando Status após validar
-- Alterações: Criação de procedure para atualizar as notas fiscais canceladas
-- Procedure Criada: pkb_cancela_nfped
-- Procedures Alteradas: pkb_dados_ped_nf: Inclusão da chamada da pkb_cancela_nfped
--
-- Em 04/12/2019 - Marcos Ferreira
-- Redmine #60710: Procedimento de validação - Retenções
-- Alterações: Inclusão de processo de confronto de Nota Fiscal de Serviço
-- Procedures Alteradas: Diversas
--
-- Em 26/11/2019 - Marcos Ferreira
-- Redmine #61737: Botão duplicar desconsiderar quantidade da nota
-- Alterações: Alteração da validação pré-duplicação de item
-- Procedures Alteradas: pkb_libera_recebimento_maior
--
-- Em 22/11/2019 - Marcos Ferreira
-- Redmine #61039 - Botão duplicar sendo acionado para pedido igual
-- Alterações: Incluído ponto de checagem para não permir duplicar se a quantidade recebida for = qtd pedido
-- Procedures Alteradas: pkb_libera_recebimento_maior
--
-- Em 27/08/2019 - Marcos Ferreira
-- Redmine #58061 - Utilizar ICMS_ST_RET para Impostos do confronto de notas
-- Alterações: Alteração do Cursor c_imp
-- Procedures Alteradas: pkb_dados_imp_itemnf_ped
--
-- Em 09/08/2019 - Luiz Armando Azoni
-- Redmine #55900 - ADICIONANDO PKB_VALIDA_MDE.
-- Rotina Alterada: PKB_VALIDA_MDE
--
-- Em 06/08/2019 - Luiz Armando Azoni
-- Redmine #57159 - Adequação no processo para duplicar o item e os impostos para edição do clietne.
-- Rotina Alterada: pkb_libera_recebimento_maior
--
-- Em 08/07/2019 - Luiz Armando Azoni
-- Redmine #56151 - Adequação da query para não recuperar nota_fiscal_ped.dm_st_proc not in (3,4,5,6,7).
-- Rotina Alterada: pkb_dados_ped_nf
--
-- Em 03/07/2019 - Luiz Armando Azoni
-- Redmine #55904 - Corrigindo join da query que recupera dados para liberação de recebimento a maior.
-- Rotina Alterada: pkb_libera_recebimento_maior
--
-- Em 11/06/2019 - Karina de Paula
-- Redmine #55294 - Adicionar colunas na NOTA_FISCAL_PED
-- Rotina Alterada: pkb_dados_notafiscal_ped => IncluÃ­do os campos vl_imp_trib_st e vl_imp_trib_ii
--
-- Em 05/04/2019 - Karina de Paula
-- Redmine #53169 - Confronto de pedido de compras com XML
--
-- ==================================================================================================== --
-------------------------------------------------------------------------------------------------------------
--Types
   --
   type tab_pedidos is table of pedido%rowtype;
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
-------------------------------------------------------------------------------------------------------------
-- Arrays Tables Globais --
   --
   ga_pedido                       tb_pedido              := tb_pedido();
   ga_item_pedido                  tb_item_pedido         := tb_item_pedido();
   ga_pedido_relac                 tb_pedido              := tb_pedido();
   ga_item_pedido_relac            tb_item_pedido         := tb_item_pedido();
   ga_nota_fiscal_ped              tb_nota_fiscal_ped     := tb_nota_fiscal_ped();
   ga_item_nf_ped                  tb_item_nf_ped         := tb_item_nf_ped();
   ga_item_nf_ped2                 tb_item_nf_ped         := tb_item_nf_ped();
   ga_imp_itemnf_ped               tb_imp_itemnf_ped      := tb_imp_itemnf_ped();
   ga_nota_fiscal_ped_relac        tb_nota_fiscal_ped     := tb_nota_fiscal_ped();
   ga_item_nf_ped_relac            tb_item_nf_ped         := tb_item_nf_ped();
   --
-------------------------------------------------------------------------------------------------------------
-- Constantes Globais --
   --
   ERRO_DE_VALIDACAO               constant number := 1;
   ERRO_DE_SISTEMA                 constant number := 2;
   INFORMACAO                      constant number := 35;
   MODULO_SISTEMA                  constant number := pk_csf.fkg_ret_id_modulo_sistema('PEDIDO_COMPRA');
   GRUPO_SISTEMA_TOLERANCIA        constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'MARGEM_TOLERANCIA');
   GRUPO_PARAM_RECEB_NF            constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'PARAM_RECEB_NF');
   --
-------------------------------------------------------------------------------------------------------------
-- Variaveis Globais
   --
   gn_empresa_id                   empresa.id%type;
   gn_multorg_id                   mult_org.id%type;
   gn_pessoa_id                    nota_fiscal_ped.pessoa_id%type;
   gn_modfiscal_id                 nota_fiscal_ped.modfiscal_id%type;
   gv_cnpj                         nota_fiscal_ped.cnpj%type;
   gn_finalidade_id                pedido.finalidade_id%type;
   gn_dm_mod_frete                 pedido.dm_mod_frete%type;
   gn_dm_dm_st_proc                pedido.dm_st_proc%type;
   gn_dm_obrig_pedido              NUMBER; --VOLTAR
   gn_erro                         NUMBER := 0;
   gn_aux                          NUMBER;
   gv_aux                          VARCHAR2(255);
   gv_erro                         log_generico_pedido.resumo%type;
   gn_loggenerico_id               log_generico_pedido.id%TYPE;
   gv_mensagem_log                 log_generico_pedido.mensagem%type;
   gv_resumo_log                   log_generico_pedido.resumo%type;
   gv_obj_referencia               log_generico_nf_ped.obj_referencia%type default 'NOTA_FISCAL_PED';
   gn_param_receb                  param_receb.id%type;
   vt_tab_pedido                   tab_pedidos;
   gv_aspas                        char(1) := null;
   gv_sql                          varchar2(10000) := null;
   gv_sql_tab                      varchar2(100)   := null;
   gv_sql_values                   varchar2(100)   := null;
   gv_sql_col                      varchar2(1500)  := null;
   gv_col_vetor                    varchar2(10000) := null;
   gt_row_notafiscal_ped           nota_fiscal_ped%rowtype;
   gt_row_item_nf_ped              item_nf_ped%rowtype;
   gt_row_nota_fiscal              nota_fiscal%rowtype;
   gt_row_conhec_transp_ped        conhec_transp_ped%rowtype;
   gt_row_item_ct_ped              item_ct_ped%rowtype;
   gt_row_c_param_receb_itm        pk_csf_pedido.c_param_receb_itm%rowtype;
   --
-------------------------------------------------------------------------------------------------------------
-- Cursores Globais --
--
--
   -- Empresas por Multi-Org
   cursor c_empresa ( en_multorg_id mult_org.id%type ) is
      select id
        from empresa e
       where e.multorg_id = en_multorg_id;
   --
   --
   -- Notas para Confronto
   cursor c_nf ( en_empresa_id nota_fiscal.empresa_id%type ) is
      select nfp.notafiscal_id
           , nfp.id  notafiscalped_id
      from nota_fiscal_ped nfp
      where nfp.dm_st_proc       in (0,1)
        and nfp.empresa_id       = en_empresa_id
      UNION ALL -------------------------------------- Novas Notas Fiscais Mercantis ---------------
      select nf.id   notafiscal_id
           , null    notafiscalped_id
        from nota_fiscal nf
            ,mod_fiscal  mf
      where mf.id                = nf.modfiscal_id
        and nf.dm_arm_nfe_terc   = 1
        and nf.dm_rec_xml        = 1
        and nf.dm_st_proc       in (4,7)
        and mf.cod_mod           = '55'
        and nf.empresa_id        = en_empresa_id
        and nf.dt_emiss          > to_date('01/01/2019','dd/mm/yyyy') -- Data inicial para não buscar registros antigos
        and not exists (
           select 1
              from nota_fiscal_ped nfp2
           where nfp2.notafiscal_id = nf.id)
      UNION ALL -------------------------------------- Novas Notas Fiscais de Serviço -------------
      select nf.id   notafiscal_id
           , null    notafiscalped_id
        from nota_fiscal nf
            ,mod_fiscal  mf
      where mf.id                = nf.modfiscal_id
        and nf.dm_arm_nfe_terc   = 1
        and nf.dm_st_proc       in (4,7)
        and mf.cod_mod           = '99'
        and nf.empresa_id        = en_empresa_id
        and nf.dt_emiss          > to_date('01/01/2019','dd/mm/yyyy') -- Data inicial para não buscar registros antigos
        and not exists (
           select 1
              from nota_fiscal_ped nfp2
           where nfp2.notafiscal_id = nf.id);
   --
   --
   -- Cursor dos dados da nota
   cursor c_nota ( en_notafiscal_id nota_fiscal.id%type ) is
   select  nf.id
         , nf.empresa_id
         , nf.dm_ind_emit
         , nf.dm_ind_oper
         , nf.nro_nf
         , nf.serie
         , nf.dt_emiss
         , nf.modfiscal_id
         , nf.nro_chave_nfe
         , nf.sitdocto_id
         , nf.pedido_compra
         , nvl(nvl(nfe.cnpj, nfe.cpf),pk_csf.fkg_cnpjcpf_pessoa_id(nf.pessoa_id)) cnpj
         , nft.vl_total_item
         , nft.vl_frete
         , nft.vl_seguro
         , nft.vl_desconto
         , nft.vl_outra_despesas
         , nft.vl_total_nf
         , nft.vl_imp_trib_icms
         , nft.vl_imp_trib_ipi
         , nft.vl_total_serv
         , nft.vl_imp_trib_pis
         , nft.vl_imp_trib_cofins
         , nft.vl_imp_trib_iss
         , nft.vl_imp_trib_ii
         , nft.vl_imp_trib_st
         , nf.dt_sai_ent
         --
         , nfp.id                    id_nfp
         , nfp.notafiscal_id         notafiscal_id_nfp
         , nfp.empresa_id            empresa_id_nfp
         , nfp.pessoa_id             pessoa_id_nfp
         , nfp.dm_st_proc            dm_st_proc_nfp
         , nfp.dt_emiss              dt_emiss_nfp
         , nfp.pedido_compra         pedido_compra_nfp
         , nfp.dm_ind_emit           dm_ind_emit_nfp
         , nfp.dm_ind_oper           dm_ind_oper_nfp
         , nfp.nro_nf                nro_nf_nfp
         , nfp.serie                 serie_nfp
         , nfp.dt_sai_ent            dt_sai_ent_nfp
         , nfp.cnpj                  cnpj_nfp
         , nfp.modfiscal_id          modfiscal_id_nfp
         , nfp.nro_chave_nfe         nro_chave_nfe_nfp
         , nfp.sitdocto_id           sitdocto_id_nfp
         , nfp.vl_total_item         vl_total_item_nfp
         , nfp.vl_frete              vl_frete_nfp
         , nfp.vl_seguro             vl_seguro_nfp
         , nfp.vl_desconto           vl_desconto_nfp
         , nfp.vl_outra_despesas     vl_outra_despesas_nfp
         , nfp.vl_total_nf           vl_total_nf_nfp
         , nfp.vl_imp_trib_pis       vl_imp_trib_pis_nfp
         , nfp.vl_imp_trib_cofins    vl_imp_trib_cofins_nfp
         , nfp.vl_imp_trib_iss       vl_imp_trib_iss_nfp
         , nfp.vl_total_serv         vl_total_serv_nfp
         , nfp.vl_imp_trib_ipi       vl_imp_trib_ipi_nfp
         , nfp.vl_imp_trib_icms      vl_imp_trib_icms_nfp
         , nfp.vl_imp_trib_st        vl_imp_trib_st_nfp
         , nfp.vl_imp_trib_ii        vl_imp_trib_ii_nfp
         , nfp.paramreceb_id         paramreceb_id_nfp
         , nvl(nfp.placa, nfv.placa) placa
         , nvl(nfp.uf, nfv.uf)       uf
         , e.multorg_id
         , nf.dm_fin_nfe
         --
      from nota_fiscal         nf
         , nota_fiscal_emit   nfe
         , nota_fiscal_total  nft
         , nota_fiscal_transp nfr
         , nftransp_veic      nfv
         , nota_fiscal_ped    nfp
         , empresa              e
     where nfe.notafiscal_id   (+) = nf.id
       and nft.notafiscal_id       = nf.id
       and nfr.notafiscal_id   (+) = nf.id
       and nfv.nftransp_id     (+) = nfr.id
       and nfp.notafiscal_id   (+) = nf.id
       and e.id                    = nf.empresa_id
       and nf.id                   = en_notafiscal_id;
   --
   --
   -- Cursor dos dados da item da nota
   cursor c_item ( en_notafiscal_id nota_fiscal.id%type ) is
   select inp.id                                        itemnfped_id
        , inp.itempedido_id                             itempedido_id
        , upper(inp.unid_com)                           unid_com_itemnfped
        , inf.id                                        itemnotafiscal_id
        , inf.item_pedido_compra                        item_pedido_compra
        , inf.pedido_compra                             i_pedido_compra
        , nf.pedido_compra                              n_pedido_compra
        , nvl(inp.nro_item, inf.nro_item)               nro_item
        , upper(nvl(inp.cod_item, inf.cod_item))        cod_item
        , nvl(inp.descr_item, inf.descr_item)           descr_item
        , inf.dm_ind_mov                                dm_ind_mov
        , nvl(inp.unid_com, inf.unid_com)               unid_com
        , nvl(inp.vl_unit_comerc, inf.vl_unit_comerc)   vl_unit_comerc
        , nvl(inp.qtde_comerc, inf.qtde_comerc)         qtde_comerc
        , nvl(inp.vl_outro,inf.vl_outro)                vl_outro
        , nvl(inp.vl_seguro,inf.vl_seguro)              vl_seguro
        , nvl(inp.vl_frete,inf.vl_frete)                vl_frete
        , nvl(inp.vl_desc,inf.vl_desc)                  vl_desc
        , nvl(inp.vl_item_bruto,inf.vl_item_bruto)      vl_item_bruto
        , nf.empresa_id                                 nfempresa_id
        , nf.pessoa_id                                  nfpessoa_id
        , nvl(nvl(nfe.cnpj, nfe.cpf),pk_csf.fkg_cnpjcpf_pessoa_id(nf.pessoa_id)) cnpj_cpf
        , nf.modfiscal_id                               modfiscal_id
        , e.multorg_id                                  multorg_id
        , inp.utilizacaofiscal_id                       utilizacaofiscal_id
        , inp.unid_convert                              unid_convert
        , nf.dm_fin_nfe                                 dm_fin_nfe
        , inp.departamento_id                           departamento_id
        , inp.depositoerp_id                            depositoerp_id
        , inp.dm_edicao                                 dm_edicao
        , inp.tiposervico_id                            tiposervico_id
        , inp.item_id                                   item_id
        , inp.dup_itemnfped_id
        , (select inf2.cfop_id
             from item_nota_fiscal inf2
           where inf2.notafiscal_id = nf.id
             and inf2.nro_item      = (select min(inf3.nro_item)
                                         from item_nota_fiscal inf3
                                       where inf3.notafiscal_id = nf.id)) cfop_id_itm_01
        --
        , ip.item_id                                    itempedido_item_id
        , i.cod_item                                    itempedido_cod_item
        , i.descr_item                                  itempedido_descr_item
     from item_nota_fiscal   inf
        , nota_fiscal         nf
        , nota_fiscal_emit   nfe
        , item_nf_ped        inp
        , empresa              e
        , item_pedido         ip
        , item                 i
    where nf.id                  = inf.notafiscal_id
      and nfe.notafiscal_id  (+) = nf.id
      and inp.itemnf_id      (+) = inf.id
      and e.id                   = nf.empresa_id
      and ip.id              (+) = inp.itempedido_id
      and i.id               (+) = ip.item_id
      and nf.id                  = en_notafiscal_id;
   --
   --
   -- Cursor de Impostos
   cursor c_imp ( en_itemnf_id item_nota_fiscal.id%type ) is
   select  iip.id  impitemnfped_id
         , iif.id
         , iif.itemnf_id
         , iif.tipoimp_id
         , iif.dm_tipo
         , iif.codst_id
         --
         , nvl(iip.vl_base_calc, case when nvl(iif.vl_base_calc,0) = 0 then iif.vl_bc_st_ret  else iif.vl_base_calc end) vl_base_calc_nf
         , nvl(iip.aliq_apli, iif.aliq_apli)                                                                             aliq_apli_nf
         , nvl(iip.vl_imp_trib,  case when nvl(iif.vl_imp_trib,0)  = 0 then iif.vl_icmsst_ret else iif.vl_imp_trib  end) vl_imp_trib_nf
         --
         , ipp.vlr_base_calc  vl_base_calc_ped
         , ipp.aliq_apli      aliq_apli_ped
         , ipp.vlr_imp_trib   vl_imp_trib_ped
         --
         , iif.perc_reduc
         , iif.perc_adic
         , iif.qtde_base_calc_prod
         , iif.vl_aliq_prod
         , iif.vl_bc_st_ret
         , iif.vl_icmsst_ret
         , iif.perc_bc_oper_prop
         , iif.estado_id
         , iif.vl_bc_st_dest
         , iif.vl_icmsst_dest
         , iif.dm_orig_calc
         , iif.tiporetimp_id
         , iif.vl_deducao
         , iif.vl_base_outro
         , iif.vl_imp_outro
         , iif.vl_base_isenta
         , iif.aliq_aplic_outro
         , iif.natrecpc_id
         , iif.vl_imp_nao_dest
         , iif.vl_icms_deson
         , iif.vl_icms_oper
         , iif.percent_difer
         , iif.vl_icms_difer
         , iif.tiporetimpreceita_id
         , iif.vl_bc_fcp
         , iif.aliq_fcp
         , iif.vl_fcp
         , (select inp.dm_edicao from item_nf_ped inp where inp.id = iip.itemnfped_id) dm_edicao
     from imp_itemnf     iif
        , imp_itemnf_ped iip
        , imp_itemped      ipp
    where iip.impitemnf_id (+) = iif.id
      and ipp.id           (+) = iip.impitemped_id
      and itemnf_id            = en_itemnf_id;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento de validaçãoo de dados de Pedido, oriundos de Integração por Web-Service
-------------------------------------------------------------------------------------------------------------
procedure pkb_valid_regra  ( en_empresa_id       in empresa.id%type
                           , en_notafiscal_id    in nota_fiscal.id%type
                           , en_notafiscalped_id in out nota_fiscal_ped.id%type );
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que identifica dados de pedido e de nota fiscal para relacionar
-------------------------------------------------------------------------------------------------------------
procedure pkb_dados_ped_nf ( en_multorg_id mult_org.id%type );
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que Libera o recebimento de uma nota fiscal com quantidade maior que o pedido, criando um novo item
----------------------------------------------------------------------------------------------------------
procedure pkb_libera_recebimento_maior ( en_itemnfped_id item_nf_ped.id%type );
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que duplica um ítem de nota fiscal de serviço para liberar um recebimento a maior
----------------------------------------------------------------------------------------------------------
procedure pkb_duplica_item_nfs ( en_itemnfped_id in item_nf_ped.id%type
                               , en_vlr_item     in item_nf_ped.vl_item_bruto%type);
--
-------------------------------------------------------------------------------------------------------------
-- Valida a criação da nota_fiscal_mde
-------------------------------------------------------------------------------------------------------------
procedure pkb_valida_mde ( en_notafiscalpe_id     nota_fiscal_ped.id%type default null
                          ,en_tipoeventosefaz_cd  tipo_evento_sefaz.cd%type default null
                          ,ea_justificativa       varchar2 default null
                         );
--
----------------------------------------------------------------------------------------------------------
-- Procedimento para resetar a Nota Fiscal e Reprocessá-la
----------------------------------------------------------------------------------------------------------
procedure pkb_reinicia_nfp ( en_notafiscalped_id  in nota_fiscal_ped.id%type);
--
end pk_relac_ped_nf;
/
