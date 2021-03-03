create or replace package body csf_own.pk_int_view_nfserv_efd is

------------------------------------------------------------------------------------------------------------
--
-- Em 05/05/2011 - Angela Inês.
-- Especificação do pacote de integração de Notas Fiscais de Serviço para EFD a partir de leitura de views.
--
------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
--| Procedimento de limpeza do array

procedure pkb_limpa_array
is
begin
   --
   vt_tab_csf_nfs_efd.delete;
   vt_tab_csf_nfs_inf_adic.delete;
   vt_tab_csf_nfs_item.delete;
   --
end pkb_limpa_array;

-------------------------------------------------------------------------------------------------------
--| Função para montagem do select dinâmico - comando FROM
function fkg_monta_from ( ev_obj in varchar2 )
         return varchar2
is

   vv_from  varchar2(4000) := null;
   vv_obj   varchar2(4000) := null;

begin
   --
   vv_obj := ev_obj;
   --
   if GV_NOME_DBLINK is not null then
      --
      vv_from := vv_from || trim(GV_ASPAS) || vv_obj || trim(GV_ASPAS) || '@' || GV_NOME_DBLINK;
      --
   else
      --
      vv_from := vv_from || trim(GV_ASPAS) || vv_obj || trim(GV_ASPAS);
      --
   end if;
   --
   if trim(GV_OWNER_OBJ) is not null then
      vv_from := trim(GV_OWNER_OBJ) || '.' || vv_from;
   end if;
   --
   vv_from := ' from ' || vv_from;
   --
   return vv_from;
   --
end fkg_monta_from;

-------------------------------------------------------------------------------------------------------
--| Processo de itens da nota fiscal de serviço
procedure pkb_ler_nfserv_item ( est_log_generico_nf     in out nocopy dbms_sql.number_table
                              , ev_cpf_cnpj_emit     in  varchar2
                              , en_dm_ind_emit       in  nota_fiscal.dm_ind_emit%type
                              , en_dm_ind_oper       in  nota_fiscal.dm_ind_oper%type
                              , ev_cod_part          in  pessoa.cod_part%type
                              , ev_serie             in  nota_fiscal.serie%type
                              , ev_sub_serie         in  nota_fiscal.sub_serie%type
                              , en_nro_nf            in  nota_fiscal.nro_nf%type
                              , en_notafiscal_id     in  nota_fiscal.id%type 
                              )
is
   --
   vn_fase         number := 0;
   vn_nro_item     number := 0;
   --
   i               pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   gv_sql := null;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(gv_aspas) || 'CPF_CNPJ_EMIT'    || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_IND_EMIT'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_IND_OPER'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'COD_PART'         || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'SERIE'            || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'SUBSERIE'         || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'NRO_NF'           || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'NRO_ITEM'         || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'COD_ITEM'         || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DESCR_ITEM'       || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_ITEM'          || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_DESC'          || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'NAT_BC_CRED'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_IND_ORIG_CRED' || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'CST_PIS'          || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_BC_PIS'        || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'ALIQ_PIS'         || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_PIS'           || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DT_PAG_PIS'       || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'CST_COFINS'       || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_BC_COFINS'     || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'ALIQ_COFINS'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_COFINS'        || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DT_PAG_COFINS'    || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'COD_CTA'          || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'COD_CCUS'         || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_LOC_EXE_SERV'  || trim(gv_aspas);
   --
   vn_fase := 3;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_ITEMNF_COMPL_SERV');
   --
   vn_fase := 4;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(gv_aspas) || 'CPF_CNPJ_EMIT' || trim(gv_aspas) || ' = ' || '''' || gv_cpf_cnpj || '''';
   gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'DM_IND_EMIT'   || trim(gv_aspas) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'DM_IND_OPER'   || trim(gv_aspas) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
	  gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || trim(ev_cod_part) || '''';
	  --
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'SERIE'         || trim(gv_aspas) || ' = ' || '''' || trim(ev_serie) || '''';   
   --
   if trim(ev_sub_serie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || trim(ev_sub_serie) || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'NRO_NF'        || trim(gv_aspas) || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_COMPL_SERV (empresa: ' || gv_cpf_cnpj || ')';
   -- recupera as Informações Adicionais através da view
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nfs_item;
      --
   exception
      when others then
         --
         pk_csf_api.gv_mensagem_log := 'Erro na pk_int_view_nfserv_efd.pkb_ler_nfserv_item fase(' || vn_fase || '):' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_nf.id%type;
         begin
            --
            pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem        => pk_csf_api.gv_mensagem_log
                                        , ev_resumo          => gv_resumo
                                        , en_tipo_log        => pk_csf_api.erro_de_sistema
                                        , en_referencia_id   => pk_csf_api.gn_referencia_id
                                        , ev_obj_referencia  => pk_csf_api.gv_obj_referencia );
            --
         exception
            when others then
               null;
         end;
         -- sair do processo de itens da nota fiscal com erro
         goto sair_geral;
         --
   end;
   --
   vn_fase := 6;
   --
   if nvl(vt_tab_csf_nfs_item.count,0) > 0 then
      --
      vn_fase := 7;
      --
      for i in vt_tab_csf_nfs_item.first..vt_tab_csf_nfs_item.last loop
         --
         vn_fase := 8;
         --
         pk_csf_api.gt_row_item_nota_fiscal := null;
		 --
		 vn_nro_item := nvl(vn_nro_item,0) + 1;
         --
         -- montar dados para integração dos itens da nota fiscal de serviço
         pk_csf_api.gt_row_item_nota_fiscal.notafiscal_id        := en_notafiscal_id;
         pk_csf_api.gt_row_item_nota_fiscal.item_id              := null;
         pk_csf_api.gt_row_item_nota_fiscal.nro_item             := vn_nro_item; -- vt_tab_csf_nfs_item(i).nro_item;
         pk_csf_api.gt_row_item_nota_fiscal.cod_item             := vt_tab_csf_nfs_item(i).cod_item;
         pk_csf_api.gt_row_item_nota_fiscal.dm_ind_mov           := 0; -- 0-Não, 1-Sim
         pk_csf_api.gt_row_item_nota_fiscal.cean                 := null;
         pk_csf_api.gt_row_item_nota_fiscal.descr_item           := vt_tab_csf_nfs_item(i).descr_item;
         pk_csf_api.gt_row_item_nota_fiscal.cod_ncm              := 99999999; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.genero               := 99; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.cod_ext_ipi          := null;
         pk_csf_api.gt_row_item_nota_fiscal.cfop_id              := 1; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.cfop                 := 1000; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.unid_com             := 'UN'; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.qtde_comerc          := 1; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.vl_unit_comerc       := vt_tab_csf_nfs_item(i).vl_item; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.vl_item_bruto        := vt_tab_csf_nfs_item(i).vl_item;
         pk_csf_api.gt_row_item_nota_fiscal.cean_trib            := null;
         pk_csf_api.gt_row_item_nota_fiscal.unid_trib            := 'UN'; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.qtde_trib            := 0; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.vl_unit_trib         := 0; -- valor default
         pk_csf_api.gt_row_item_nota_fiscal.vl_frete             := null;
         pk_csf_api.gt_row_item_nota_fiscal.vl_seguro            := null;
         pk_csf_api.gt_row_item_nota_fiscal.vl_desc              := vt_tab_csf_nfs_item(i).vl_desc;
         pk_csf_api.gt_row_item_nota_fiscal.infadprod            := null;
         pk_csf_api.gt_row_item_nota_fiscal.orig                 := 0;
         pk_csf_api.gt_row_item_nota_fiscal.dm_mod_base_calc     := 3; -- 0-Margem Valor Agregado (%), 1-Pauta (Valor), 2-Preço Tabelado Máx. (valor), 3-Valor da operação
         pk_csf_api.gt_row_item_nota_fiscal.dm_mod_base_calc_st  := 3; -- 0-Preço tab.ou máximo, 1-Lista Negativa (valor), 2-Lista Positiva (valor), 3-Lista Neutra (valor), 4-Margem Valor Agregado (%), 5-Pauta (valor)
         pk_csf_api.gt_row_item_nota_fiscal.cnpj_produtor        := null;
         pk_csf_api.gt_row_item_nota_fiscal.qtde_selo_ipi        := null;
         pk_csf_api.gt_row_item_nota_fiscal.vl_desp_adu          := null;
         pk_csf_api.gt_row_item_nota_fiscal.vl_iof               := null;
         pk_csf_api.gt_row_item_nota_fiscal.classenqipi_id       := null;
         pk_csf_api.gt_row_item_nota_fiscal.cl_enq_ipi           := null;
         pk_csf_api.gt_row_item_nota_fiscal.selocontripi_id      := null;
         pk_csf_api.gt_row_item_nota_fiscal.cod_selo_ipi         := null;
         pk_csf_api.gt_row_item_nota_fiscal.cod_enq_ipi          := null;
         pk_csf_api.gt_row_item_nota_fiscal.cidade_ibge          := null;
         pk_csf_api.gt_row_item_nota_fiscal.cd_lista_serv        := null;
         pk_csf_api.gt_row_item_nota_fiscal.dm_ind_apur_ipi      := null; -- 0-Mensal, 1-Decendial
         pk_csf_api.gt_row_item_nota_fiscal.cod_cta              := trim(vt_tab_csf_nfs_item(i).cod_cta);
         pk_csf_api.gt_row_item_nota_fiscal.classconsitemcont_id := null;
         pk_csf_api.gt_row_item_nota_fiscal.dm_ind_rec           := null; -- 0-Receita própria, 1-Receita de terceiros
         pk_csf_api.gt_row_item_nota_fiscal.pessoa_id            := null;
         pk_csf_api.gt_row_item_nota_fiscal.dm_ind_rec_com       := null; -- 0-Rec.própria-serv.prestados, 1-Rec.própria-cobr.débitos, 2-Rec.própria-venda merc., 3-Rec.própria - venda serv.pré-pago, 4-Outras rec.próprias, 5-Rec.terceiros (co-fat.), 9-Outras rec.terceiros
         pk_csf_api.gt_row_item_nota_fiscal.natoper_id           := null;
         pk_csf_api.gt_row_item_nota_fiscal.vl_outro             := null;
         pk_csf_api.gt_row_item_nota_fiscal.dm_ind_tot           := 1; -- 0-Valor item NÃO compõe valor total NF-e, 1-Valor item compõe valor total NF-e
         pk_csf_api.gt_row_item_nota_fiscal.pedido_compra        := null;
         pk_csf_api.gt_row_item_nota_fiscal.item_pedido_compra   := null;
         pk_csf_api.gt_row_item_nota_fiscal.dm_mot_des_icms      := null; -- 1-Táxi, 2-Deficiente Físico, 3-Produtor Agropecuário, 4-Frotista/Locadora, 5-Diplomático/Consular, 6-Util.Motoc.da Amazônia Ocid.e Áreas Livre Com., 7-SUFRAMA, 9-Outros
         pk_csf_api.gt_row_item_nota_fiscal.dm_cod_trib_issqn    := null; -- I-Isenta, N-Normal, R-Retida, S-Substituta
         --
         vn_fase := 10;
         -- chama procedimento de integração dos itens da nota fiscal de serviço
         pk_csf_api_nfserv.pkb_integr_item_nota_fiscal ( est_log_generico_nf         => est_log_generico_nf
                                                       , est_row_item_nota_fiscal => pk_csf_api.gt_row_item_nota_fiscal );
         --
         vn_fase := 11;
         -- montar dados para integração do complemento dos itens da nota fiscal de serviço
         pk_csf_api_nfserv.gt_row_nfserv_item_compl.itemnf_id         := pk_csf_api.gt_row_item_nota_fiscal.id;
         pk_csf_api_nfserv.gt_row_nfserv_item_compl.basecalccredpc_id := null;
         pk_csf_api_nfserv.gt_row_nfserv_item_compl.dm_ind_orig_cred  := vt_tab_csf_nfs_item(i).dm_ind_orig_cred; -- 0-Oper.Merc.Interno, 1-Oper.Importação
         pk_csf_api_nfserv.gt_row_nfserv_item_compl.dt_pag_pis        := vt_tab_csf_nfs_item(i).dt_pag_pis;
         pk_csf_api_nfserv.gt_row_nfserv_item_compl.dt_pag_cofins     := vt_tab_csf_nfs_item(i).dt_pag_cofins;
         pk_csf_api_nfserv.gt_row_nfserv_item_compl.dm_loc_exe_serv   := vt_tab_csf_nfs_item(i).dm_loc_exe_serv; -- 0-Executado País, 1-Executado Exterior
         pk_csf_api_nfserv.gt_row_nfserv_item_compl.centrocusto_id    := null;
         --
         vn_fase := 12;
         -- chama procedimento de integração do complemento dos itens da nota fiscal de serviço
         pk_csf_api_nfserv.pkb_integr_nfserv_item_compl ( est_log_generico_nf          => est_log_generico_nf
                                                        , est_row_nfserv_item_compl => pk_csf_api_nfserv.gt_row_nfserv_item_compl
                                                        , ev_cpf_cnpj_emit          => vt_tab_csf_nfs_item(i).cpf_cnpj_emit
                                                        , en_nro_nf                 => en_nro_nf
                                                        , ev_serie                  => ev_serie
                                                        , ev_cod_bc_cred_pc         => trim(vt_tab_csf_nfs_item(i).nat_bc_cred)
                                                        , ev_cod_ccus               => trim(vt_tab_csf_nfs_item(i).cod_ccus)
                                                        , en_multorg_id             => gn_multorg_id );
         --
         vn_fase := 13;
         -- montar dados para integração dos impostos dos itens da nota fiscal de serviço - PIS
         pk_csf_api.gt_row_imp_itemnf.itemnf_id           := pk_csf_api.gt_row_item_nota_fiscal.id;
         pk_csf_api.gt_row_imp_itemnf.tipoimp_id          := null; -- recuperado no processo pk_csf_api.pkb_integr_imp_itemnf
         pk_csf_api.gt_row_imp_itemnf.dm_tipo             := 0; -- 0-imposto, 1-retenção
         pk_csf_api.gt_row_imp_itemnf.codst_id            := null; -- recuperado no processo pk_csf_api.pkb_integr_imp_itemnf
         pk_csf_api.gt_row_imp_itemnf.vl_base_calc        := vt_tab_csf_nfs_item(i).vl_bc_pis;
         pk_csf_api.gt_row_imp_itemnf.aliq_apli           := vt_tab_csf_nfs_item(i).aliq_pis;
         pk_csf_api.gt_row_imp_itemnf.vl_imp_trib         := vt_tab_csf_nfs_item(i).vl_pis;
         pk_csf_api.gt_row_imp_itemnf.perc_reduc          := null;
         pk_csf_api.gt_row_imp_itemnf.perc_adic           := null;
         pk_csf_api.gt_row_imp_itemnf.qtde_base_calc_prod := null;
         pk_csf_api.gt_row_imp_itemnf.vl_aliq_prod        := null;
         pk_csf_api.gt_row_imp_itemnf.vl_bc_st_ret        := null;
         pk_csf_api.gt_row_imp_itemnf.vl_icmsst_ret       := null;
         pk_csf_api.gt_row_imp_itemnf.perc_bc_oper_prop   := null;
         pk_csf_api.gt_row_imp_itemnf.estado_id           := null;
         pk_csf_api.gt_row_imp_itemnf.vl_bc_st_dest       := null;
         pk_csf_api.gt_row_imp_itemnf.vl_icmsst_dest      := null;
         --
         vn_fase := 14;
         -- chama procedimento de integração dos impostos dos itens da nota fiscal de serviço - PIS
         pk_csf_api.pkb_integr_imp_itemnf ( est_log_generico_nf          => est_log_generico_nf
                                          , est_row_imp_itemnf        => pk_csf_api.gt_row_imp_itemnf
                                          , en_cd_imp                 => 4 -- pis
                                          , ev_cod_st                 => trim(vt_tab_csf_nfs_item(i).cst_pis)
                                          , en_notafiscal_id          => en_notafiscal_id
                                          , ev_sigla_estado           => null );
         --
         vn_fase := 15;
         -- montar dados para integração dos impostos dos itens da nota fiscal de serviço - COFINS
         pk_csf_api.gt_row_imp_itemnf.itemnf_id           := pk_csf_api.gt_row_item_nota_fiscal.id;
         pk_csf_api.gt_row_imp_itemnf.tipoimp_id          := null; -- recuperado no processo pk_csf_api.pkb_integr_imp_itemnf
         pk_csf_api.gt_row_imp_itemnf.dm_tipo             := 0; -- 0-imposto, 1-retenção
         pk_csf_api.gt_row_imp_itemnf.codst_id            := null; -- recuperado no processo pk_csf_api.pkb_integr_imp_itemnf
         pk_csf_api.gt_row_imp_itemnf.vl_base_calc        := vt_tab_csf_nfs_item(i).vl_bc_cofins;
         pk_csf_api.gt_row_imp_itemnf.aliq_apli           := vt_tab_csf_nfs_item(i).aliq_cofins;
         pk_csf_api.gt_row_imp_itemnf.vl_imp_trib         := vt_tab_csf_nfs_item(i).vl_cofins;
         pk_csf_api.gt_row_imp_itemnf.perc_reduc          := null;
         pk_csf_api.gt_row_imp_itemnf.perc_adic           := null;
         pk_csf_api.gt_row_imp_itemnf.qtde_base_calc_prod := null;
         pk_csf_api.gt_row_imp_itemnf.vl_aliq_prod        := null;
         pk_csf_api.gt_row_imp_itemnf.vl_bc_st_ret        := null;
         pk_csf_api.gt_row_imp_itemnf.vl_icmsst_ret       := null;
         pk_csf_api.gt_row_imp_itemnf.perc_bc_oper_prop   := null;
         pk_csf_api.gt_row_imp_itemnf.estado_id           := null;
         pk_csf_api.gt_row_imp_itemnf.vl_bc_st_dest       := null;
         pk_csf_api.gt_row_imp_itemnf.vl_icmsst_dest      := null;
         --
         vn_fase := 16;
         -- chama procedimento de integração dos impostos dos itens da nota fiscal de serviço - COFINS
         pk_csf_api.pkb_integr_imp_itemnf ( est_log_generico_nf          => est_log_generico_nf
                                          , est_row_imp_itemnf        => pk_csf_api.gt_row_imp_itemnf
                                          , en_cd_imp                 => 5 -- cofins
                                          , ev_cod_st                 => trim(vt_tab_csf_nfs_item(i).cst_cofins)
                                          , en_notafiscal_id          => en_notafiscal_id
                                          , ev_sigla_estado           => null );
         --
         vn_fase := 17;
         --
      end loop;
      --
   end if;
   --
   <<sair_geral>>
   --
   null;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_int_view_nfserv_efd.pkb_ler_nfserv_item fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => null
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.erro_de_sistema
                                     , en_referencia_id   => pk_csf_api.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nfserv_item;

-------------------------------------------------------------------------------------------------------
--| Procedimento de leitura das notas fiscais de serviço para EFD - informações adicionais
procedure pkb_ler_nfserv_nfinfor_adic ( est_log_generico_nf    in  out nocopy dbms_sql.number_table
                                      , ev_cpf_cnpj_emit    in  varchar2
                                      , en_dm_ind_emit      in  nota_fiscal.dm_ind_emit%type
                                      , en_dm_ind_oper      in  nota_fiscal.dm_ind_oper%type
                                      , ev_cod_part         in  pessoa.cod_part%type
                                      , ev_serie            in  nota_fiscal.serie%type
                                      , ev_sub_serie        in  nota_fiscal.sub_serie%type
                                      , en_nro_nf           in  nota_fiscal.nro_nf%type
                                      , en_notafiscal_id    in  nota_fiscal.id%type )
is
   --
   vn_fase         number := 0;
   i               pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   gv_sql := null;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NFSINFOR_ADIC_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(gv_aspas) || 'CPF_CNPJ_EMIT' || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_IND_EMIT'   || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_IND_OPER'   || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'COD_PART'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'SERIE'         || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'SUBSERIE'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'NRO_NF'        || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_TIPO'       || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'CAMPO'         || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'CONTEUDO'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'ORIG_PROC'     || trim(gv_aspas);
   --
   vn_fase := 3;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NFSINFOR_ADIC_EFD');
   --
   vn_fase := 4;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(gv_aspas) || 'CPF_CNPJ_EMIT' || trim(gv_aspas) || ' = ' || '''' || gv_cpf_cnpj || '''';
   gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'DM_IND_EMIT'   || trim(gv_aspas) || ' = ' || en_dm_ind_emit;
   gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'DM_IND_OPER'   || trim(gv_aspas) || ' = ' || en_dm_ind_oper;
   --
   if trim(ev_cod_part) is not null then
      --
	  gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS) || ' = ' || '''' || trim(ev_cod_part) || '''';
	  --
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'SERIE'         || trim(gv_aspas) || ' = ' || '''' || trim(ev_serie) || '''';   
   --
   if trim(ev_sub_serie) is not null then
      gv_sql := gv_sql || ' and ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS) || ' = ' || '''' || trim(ev_sub_serie) || '''';
   end if;
   --
   gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'NRO_NF'        || trim(gv_aspas) || ' = ' || en_nro_nf;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NFSINFOR_ADIC_EFD (empresa: ' || gv_cpf_cnpj || ')';
   -- recupera as Informações Adicionais através da view
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nfs_inf_adic;
      --
   exception
      when others then
         --
         pk_csf_api.gv_mensagem_log := 'Erro na pk_int_view_nfserv_efd.pkb_ler_nfserv_nfinfor_adic fase(' || vn_fase || '):' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_nf.id%type;
         begin
            --
            pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem        => pk_csf_api.gv_mensagem_log
                                        , ev_resumo          => gv_resumo
                                        , en_tipo_log        => pk_csf_api.erro_de_sistema
                                        , en_referencia_id   => pk_csf_api.gn_referencia_id
                                        , ev_obj_referencia  => pk_csf_api.gv_obj_referencia );
            --
         exception
            when others then
               null;
         end;
         -- sair do processo de informação adicional com erro
         goto sair_geral;
         --
   end;
   --
   vn_fase := 6;
   --
   if nvl(vt_tab_csf_nfs_inf_adic.count,0) > 0 then
      --
      vn_fase := 7;
      --
      for i in vt_tab_csf_nfs_inf_adic.first..vt_tab_csf_nfs_inf_adic.last loop
         --
         vn_fase := 8;
         --
         pk_csf_api.gt_row_nfinfor_adic := null;
         --
         -- montar dados para integração da informação adicional da nota fiscal de serviço
         pk_csf_api.gt_row_nfinfor_adic.notafiscal_id := en_notafiscal_id;
         pk_csf_api.gt_row_nfinfor_adic.dm_tipo       := vt_tab_csf_nfs_inf_adic(i).dm_tipo; -- 0-Contribuinte, 1-Fisco, 2-Processo
         pk_csf_api.gt_row_nfinfor_adic.campo         := vt_tab_csf_nfs_inf_adic(i).campo;
         pk_csf_api.gt_row_nfinfor_adic.conteudo      := vt_tab_csf_nfs_inf_adic(i).conteudo;
         --
         vn_fase := 10;
         -- chama procedimento de integração das informações adicionais da nota fiscal de serviço
         pk_csf_api.pkb_integr_nfinfor_adic ( est_log_generico_nf     => est_log_generico_nf
                                            , est_row_nfinfor_adic => pk_csf_api.gt_row_nfinfor_adic
                                            , en_cd_orig_proc      => vt_tab_csf_nfs_inf_adic(i).orig_proc );
         --
         vn_fase := 11;
         --
      end loop;
      --
   end if;
   --
   <<sair_geral>>
   --
   null;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_int_view_nfserv_efd.pkb_ler_nfserv_nfinfor_adic fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => null
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.erro_de_sistema
                                     , en_referencia_id   => pk_csf_api.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nfserv_nfinfor_adic;

-------------------------------------------------------------------------------------------------------
--| Procedimento de leitura das notas fiscais de serviço para EFD
procedure pkb_ler_nfserv_efd
is
   --
   vn_fase         number := 0;
   vt_log_generico_nf dbms_sql.number_table;
   i               pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   gv_sql := null;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_SERV_EFD') = 0 then
      --
      return;
      --
   end if;
   --
   vn_fase := 2;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql ||         trim(gv_aspas) || 'CPF_CNPJ_EMIT' || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_IND_EMIT'   || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_IND_OPER'   || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'COD_PART'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'SERIE'         || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'SUBSERIE'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'NRO_NF'        || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'SIT_DOCTO'     || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DT_EMISS'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DT_EXE_SERV'   || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'CHV_NFSE'      || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_DOC'        || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'DM_IND_PAG'    || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_DESC'       || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_BC_PIS'     || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_PIS'        || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_BC_COFINS'  || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_COFINS'     || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_PIS_RET'    || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_COFINS_RET' || trim(gv_aspas);
   gv_sql := gv_sql || ', ' || trim(gv_aspas) || 'VL_ISS'        || trim(gv_aspas);
   --
   vn_fase := 3;
   --
   gv_sql := gv_sql || fkg_monta_from ( ev_obj => 'VW_CSF_NF_SERV_EFD');
   --
   vn_fase := 4;
   --
   -- Monta a condição do where
   gv_sql := gv_sql || ' where ';
   gv_sql := gv_sql ||            trim(gv_aspas) || 'CPF_CNPJ_EMIT' || trim(gv_aspas) || ' = ' || '''' || gv_cpf_cnpj || '''';
   --
   vn_fase := 4.1;
   --
   if gd_dt_ini is not null and gd_dt_fin is not null then
      --
      gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'DT_EMISS'      || trim(gv_aspas) || ' >= ' || '''' || to_date(gd_dt_ini, gv_formato_dt_erp) || '''';
      gv_sql := gv_sql || ' and ' || trim(gv_aspas) || 'DT_EMISS'      || trim(gv_aspas) || ' <= ' || '''' || to_date(gd_dt_fin, gv_formato_dt_erp) || '''';
      --
   end if;
   --
   vn_fase := 5;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_SERV_EFD (empresa: ' || gv_cpf_cnpj || ')';
   -- recupera as Notas Fiscais de Serviço através da view
   begin
      --
      execute immediate gv_sql bulk collect into vt_tab_csf_nfs_efd;
      --
   exception
      when others then
         --
         pk_csf_api.gv_mensagem_log := 'Erro na pk_int_view_nfserv_efd.pkb_ler_nfserv_efd fase(' || vn_fase || '):' || sqlerrm;
         --
         declare
            vn_loggenerico_id  log_generico_nf.id%type;
         begin
            --
            pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                        , ev_mensagem        => pk_csf_api.gv_mensagem_log
                                        , ev_resumo          => gv_resumo
                                        , en_tipo_log        => pk_csf_api.erro_de_sistema
                                        , en_referencia_id   => pk_csf_api.gn_referencia_id
                                        , ev_obj_referencia  => pk_csf_api.gv_obj_referencia );
            --
         exception
            when others then
               null;
         end;
         -- sair do processo da nota fiscal de serviço com erro
         goto sair_geral;
         --
   end;
   --
   -- Calcula a quantidade de registros buscados no ERP
   -- para ser mostrado na tela de agendamento.
   --
   pk_agend_integr.gvtn_qtd_erp(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erp(gv_cd_obj),0) + nvl(vt_tab_csf_nfs_efd.count,0);
   --
   vn_fase := 6;
   --
   if nvl(vt_tab_csf_nfs_efd.count,0) > 0 then
      --
      vn_fase := 7;
      --
      for i in vt_tab_csf_nfs_efd.first..vt_tab_csf_nfs_efd.last loop
         --
         vn_fase := 8;
         --
         vt_log_generico_nf.delete;
         --
         vn_fase := 9;
         --
         pk_csf_api.gt_row_nota_fiscal := null;
         --
         -- monta dados para integração da nota fiscal de serviço
         pk_csf_api.gt_row_nota_fiscal.empresa_id             := null;
         pk_csf_api.gt_row_nota_fiscal.pessoa_id              := null;
         pk_csf_api.gt_row_nota_fiscal.sitdocto_id            := null;
         pk_csf_api.gt_row_nota_fiscal.natoper_id             := null;
         pk_csf_api.gt_row_nota_fiscal.lote_id                := null;
         pk_csf_api.gt_row_nota_fiscal.inutilizanf_id         := null;
         pk_csf_api.gt_row_nota_fiscal.versao                 := '1';
         pk_csf_api.gt_row_nota_fiscal.id_tag_nfe             := null;
         pk_csf_api.gt_row_nota_fiscal.pk_nitem               := null;
         pk_csf_api.gt_row_nota_fiscal.nat_oper               := 'NF Serviço';
         pk_csf_api.gt_row_nota_fiscal.dm_ind_pag             := vt_tab_csf_nfs_efd(i).dm_ind_pag; -- 0-à vista, 1-à prazo, 2-Outros, 9-Sem pagamento
         pk_csf_api.gt_row_nota_fiscal.modfiscal_id           := null;
         pk_csf_api.gt_row_nota_fiscal.dm_ind_emit            := vt_tab_csf_nfs_efd(i).dm_ind_emit; -- 0-Emissão própria, 1-Terceiros
         pk_csf_api.gt_row_nota_fiscal.dm_ind_oper            := vt_tab_csf_nfs_efd(i).dm_ind_oper; -- 0-Entrada, 1-Saída
         pk_csf_api.gt_row_nota_fiscal.dt_sai_ent             := null;
         pk_csf_api.gt_row_nota_fiscal.dt_emiss               := vt_tab_csf_nfs_efd(i).dt_emiss;
         pk_csf_api.gt_row_nota_fiscal.nro_nf                 := vt_tab_csf_nfs_efd(i).nro_nf;
         pk_csf_api.gt_row_nota_fiscal.serie                  := vt_tab_csf_nfs_efd(i).serie;
         pk_csf_api.gt_row_nota_fiscal.uf_embarq              := null;
         pk_csf_api.gt_row_nota_fiscal.local_embarq           := null;
         pk_csf_api.gt_row_nota_fiscal.nf_empenho             := null;
         pk_csf_api.gt_row_nota_fiscal.pedido_compra          := null;
         pk_csf_api.gt_row_nota_fiscal.contrato_compra        := null;
         pk_csf_api.gt_row_nota_fiscal.dm_st_proc             := 0; -- 0-Não validada, vai de 0 até 8, de 10 até 17, e 99
         pk_csf_api.gt_row_nota_fiscal.dt_st_proc             := sysdate;
         pk_csf_api.gt_row_nota_fiscal.dm_forma_emiss         := 1; -- 1-Normal, 2-Contigência FS, 3-Contingência SCAN, 4-Contigência DPEC, 5-Contigência FS-DA
         pk_csf_api.gt_row_nota_fiscal.dm_impressa            := 0; -- 0-Não, 1-Sim, 2-Erro na Impressão, 3-Não se aplica, 4-Impressão Manual
         pk_csf_api.gt_row_nota_fiscal.dm_tp_impr             := 1; -- 1-Retrato, 2-Paisagem
         pk_csf_api.gt_row_nota_fiscal.dm_tp_amb              := 1; -- 1-Produção, 2-Homologação
         pk_csf_api.gt_row_nota_fiscal.dm_fin_nfe             := 1; -- 1-NF-e normal, 2-NF-e complementar, 3-NF-e de ajuste, 4-
         pk_csf_api.gt_row_nota_fiscal.dm_proc_emiss          := 1; -- 0-NF-e c/aplic.contrib, 1-NF-e avulsa Fisco, 2-NF-e avulsa, contrib.c/ Fisco, 3-NF-e contrib.c/ aplic.Fisco
         pk_csf_api.gt_row_nota_fiscal.vers_proc              := '1';
         pk_csf_api.gt_row_nota_fiscal.dt_aut_sefaz           := sysdate;
         pk_csf_api.gt_row_nota_fiscal.dm_aut_sefaz           := 1; -- 0-Não, 1-Sim
         pk_csf_api.gt_row_nota_fiscal.cidade_ibge_emit       := '3543402'; -- código da cidade Ribeirão Preto
         pk_csf_api.gt_row_nota_fiscal.uf_ibge_emit           := '35'; -- código do estado de São Paulo
         pk_csf_api.gt_row_nota_fiscal.dt_hr_ent_sist         := sysdate;
         pk_csf_api.gt_row_nota_fiscal.nro_chave_nfe          := null;
         pk_csf_api.gt_row_nota_fiscal.cnf_nfe                := null;
         pk_csf_api.gt_row_nota_fiscal.dig_verif_chave        := null;
         pk_csf_api.gt_row_nota_fiscal.vers_apl               := '1';
         pk_csf_api.gt_row_nota_fiscal.dt_hr_recbto           := sysdate;
         pk_csf_api.gt_row_nota_fiscal.nro_protocolo          := null;
         pk_csf_api.gt_row_nota_fiscal.digest_value           := null;
         pk_csf_api.gt_row_nota_fiscal.msgwebserv_id          := null;
         pk_csf_api.gt_row_nota_fiscal.cod_msg                := null;
         pk_csf_api.gt_row_nota_fiscal.motivo_resp            := null;
         pk_csf_api.gt_row_nota_fiscal.nfe_proc_xml           := null;
         pk_csf_api.gt_row_nota_fiscal.dm_st_email            := 0; -- 0-Não Enviado, 1-Enviado pelo portal, 2-Enviado pelo e-mail automático, 3-Erro no Envio, 4-Não se aplica
         pk_csf_api.gt_row_nota_fiscal.id_usuario_erp         := null;
         pk_csf_api.gt_row_nota_fiscal.impressora_id          := null;
         pk_csf_api.gt_row_nota_fiscal.usuario_id             := null;
         pk_csf_api.gt_row_nota_fiscal.dm_st_integra          := 0; -- 0-Indefinido, vai de 0 até 9
         pk_csf_api.gt_row_nota_fiscal.vias_danfe_custom      := null;
         pk_csf_api.gt_row_nota_fiscal.nro_chave_nfe_adic     := null;
         pk_csf_api.gt_row_nota_fiscal.nro_tentativas_impr    := 0;
         pk_csf_api.gt_row_nota_fiscal.dt_ult_tenta_impr      := null;
         pk_csf_api.gt_row_nota_fiscal.sub_serie              := vt_tab_csf_nfs_efd(i).subserie;
         pk_csf_api.gt_row_nota_fiscal.codconsitemcont_id     := null;
         pk_csf_api.gt_row_nota_fiscal.inforcompdctofiscal_id := null;
         pk_csf_api.gt_row_nota_fiscal.cod_cta                := null;
         pk_csf_api.gt_row_nota_fiscal.dm_tp_ligacao          := null; -- 1-Monofásico, 2-Bifásico, 3-Trifásico
         pk_csf_api.gt_row_nota_fiscal.dm_cod_grupo_tensao    := null; -- de 01 até 14
         pk_csf_api.gt_row_nota_fiscal.dm_tp_assinante        := null; -- 1-Comercial/Industrial, 2-Poder Público, 3-Residencial/Pessoa física, 4-Público, 5-Semi-Público, 6-Outros
         pk_csf_api.gt_row_nota_fiscal.sistorig_id            := null;
         pk_csf_api.gt_row_nota_fiscal.unidorg_id             := null;
         pk_csf_api.gt_row_nota_fiscal.serie_scan             := null;
         pk_csf_api.gt_row_nota_fiscal.nro_nf_scan            := null;
         pk_csf_api.gt_row_nota_fiscal.hora_sai_ent           := null;
         pk_csf_api.gt_row_nota_fiscal.nro_chave_cte_ref      := null;
         pk_csf_api.gt_row_nota_fiscal.dt_cont                := null;
         pk_csf_api.gt_row_nota_fiscal.just_cont              := null;
         pk_csf_api.gt_row_nota_fiscal.dm_ret_nf_erp          := null; -- 0-Não, 1-Sim
         pk_csf_api.gt_row_nota_fiscal.xml_wssinal_suframa    := null;
         pk_csf_api.gt_row_nota_fiscal.dm_st_wssinal_suframa  := null; -- 0-Não Gerado, 1-Gerado
         pk_csf_api.gt_row_nota_fiscal.dm_arm_nfe_terc        := null; -- 0-Não, 1-Sim
         pk_csf_api.gt_row_nota_fiscal.dm_rec_xml             := null; -- 0-Não recebido, 1-Recebido
         pk_csf_api.gt_row_nota_fiscal.dm_danfe_rec           := null; -- 0-Não recebido, 1-Recebido
         pk_csf_api.gt_row_nota_fiscal.nro_email_env_forn     := null;
         pk_csf_api.gt_row_nota_fiscal.dm_fin_email_forn      := null; -- 0-Não, 1-Sim
         pk_csf_api.gt_row_nota_fiscal.seq_nro_ord_emb        := null;
         pk_csf_api.gt_row_nota_fiscal.dt_email_env_forn      := null;
         pk_csf_api.gt_row_nota_fiscal.nro_ord_emb            := null;
         --
         vn_fase := 10;
         -- chama procedimento de integração da nota fiscal de serviço
         pk_csf_api.pkb_integr_nota_fiscal ( est_log_generico_nf     => vt_log_generico_nf
                                           , est_row_nota_fiscal  => pk_csf_api.gt_row_nota_fiscal
                                           , ev_cod_mod           => '99' -- Serviço
                                           , ev_cod_matriz        => null
                                           , ev_cod_filial        => null
                                           , ev_empresa_cpf_cnpj  => vt_tab_csf_nfs_efd(i).cpf_cnpj_emit
                                           , ev_cod_part          => vt_tab_csf_nfs_efd(i).cod_part
                                           , ev_cod_nat           => null
                                           , ev_cd_sitdocto       => vt_tab_csf_nfs_efd(i).sit_docto
                                           , ev_cod_infor         => null
                                           , ev_sist_orig         => null
                                           , ev_cod_unid_org      => null
                                           , en_multorg_id        => gn_multorg_id );
         --
         if nvl(pk_csf_api.gt_row_nota_fiscal.id,0) = 0 then
            --
            goto ler_outro;
            --
         end if;
         --
         vn_fase := 11;
         --
         pk_csf_api.gt_row_nota_fiscal_total := null;
         -- monta dados para integração da nota fiscal de serviço - valores totais
         pk_csf_api.gt_row_nota_fiscal_total.notafiscal_id         := pk_csf_api.gt_row_nota_fiscal.id;
         pk_csf_api.gt_row_nota_fiscal_total.vl_base_calc_icms     := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_imp_trib_icms      := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_base_calc_st       := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_imp_trib_st        := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_total_item         := vt_tab_csf_nfs_efd(i).vl_doc;
         pk_csf_api.gt_row_nota_fiscal_total.vl_frete              := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_seguro             := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_desconto           := vt_tab_csf_nfs_efd(i).vl_desc;
         pk_csf_api.gt_row_nota_fiscal_total.vl_imp_trib_ii        := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_imp_trib_ipi       := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_imp_trib_pis       := vt_tab_csf_nfs_efd(i).vl_pis;
         pk_csf_api.gt_row_nota_fiscal_total.vl_imp_trib_cofins    := vt_tab_csf_nfs_efd(i).vl_cofins;
         pk_csf_api.gt_row_nota_fiscal_total.vl_outra_despesas     := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_total_nf           := vt_tab_csf_nfs_efd(i).vl_doc;
         pk_csf_api.gt_row_nota_fiscal_total.vl_serv_nao_trib      := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_base_calc_iss      := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_imp_trib_iss       := vt_tab_csf_nfs_efd(i).vl_iss;
         pk_csf_api.gt_row_nota_fiscal_total.vl_pis_iss            := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_cofins_iss         := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_ret_pis            := vt_tab_csf_nfs_efd(i).vl_pis_ret;
         pk_csf_api.gt_row_nota_fiscal_total.vl_ret_cofins         := vt_tab_csf_nfs_efd(i).vl_cofins_ret;
         pk_csf_api.gt_row_nota_fiscal_total.vl_ret_csll           := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_base_calc_irrf     := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_ret_irrf           := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_base_calc_ret_prev := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_ret_prev           := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_total_serv         := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_abat_nt            := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_forn               := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_terc               := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_servico            := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_pis_st             := null;
         pk_csf_api.gt_row_nota_fiscal_total.vl_cofins_st          := null;
         --
         vn_fase := 12;
         --
         -- chama procedimento de integração da nota fiscal de serviço - valores totais
         pk_csf_api.pkb_integr_nota_fiscal_total ( est_log_generico_nf          => vt_log_generico_nf
                                                 , est_row_nota_fiscal_total => pk_csf_api.gt_row_nota_fiscal_total );
         --
         vn_fase := 13;
         --
         pk_csf_api_nfserv.gt_row_nfserv_compl_efd := null;
         -- monta dados para integração da nota fiscal de serviço - complemento de serviço
         pk_csf_api_nfserv.gt_row_nfserv_compl_efd.notafiscal_id := pk_csf_api.gt_row_nota_fiscal.id;
         pk_csf_api_nfserv.gt_row_nfserv_compl_efd.chv_nfse      := vt_tab_csf_nfs_efd(i).chv_nfse;
         pk_csf_api_nfserv.gt_row_nfserv_compl_efd.dt_exe_serv   := vt_tab_csf_nfs_efd(i).dt_exe_serv;
         --
         vn_fase := 14;
         --
         -- chama procedimento de integração da nota fiscal de serviço - complemento de serviço
         pk_csf_api_nfserv.pkb_integr_nfserv_compl_efd ( est_log_generico_nf     => vt_log_generico_nf
                                                       , est_row_nfserv_compl => pk_csf_api_nfserv.gt_row_nfserv_compl_efd
                                                       , ev_cpf_cnpj_emit     => vt_tab_csf_nfs_efd(i).cpf_cnpj_emit
                                                       , en_nro_nf            => vt_tab_csf_nfs_efd(i).nro_nf
                                                       , ev_serie             => vt_tab_csf_nfs_efd(i).serie
                                                       , en_multorg_id        => gn_multorg_id );
         --
         vn_fase := 15;
         --
         -- chama processo de informação adicional da nota fiscal de serviço
         pkb_ler_nfserv_nfinfor_adic ( est_log_generico_nf => vt_log_generico_nf
                                     , ev_cpf_cnpj_emit => vt_tab_csf_nfs_efd(i).cpf_cnpj_emit
                                     , en_dm_ind_emit   => vt_tab_csf_nfs_efd(i).dm_ind_emit
                                     , en_dm_ind_oper   => vt_tab_csf_nfs_efd(i).dm_ind_oper
                                     , ev_cod_part      => vt_tab_csf_nfs_efd(i).cod_part
                                     , ev_serie         => vt_tab_csf_nfs_efd(i).serie
                                     , ev_sub_serie     => vt_tab_csf_nfs_efd(i).subserie
                                     , en_nro_nf        => vt_tab_csf_nfs_efd(i).nro_nf
                                     , en_notafiscal_id => pk_csf_api.gt_row_nota_fiscal.id );
         --
         vn_fase := 16;
         --
         -- chama processo de itens da nota fiscal de serviço
         pkb_ler_nfserv_item ( est_log_generico_nf => vt_log_generico_nf
                             , ev_cpf_cnpj_emit => vt_tab_csf_nfs_efd(i).cpf_cnpj_emit
                             , en_dm_ind_emit   => vt_tab_csf_nfs_efd(i).dm_ind_emit
                             , en_dm_ind_oper   => vt_tab_csf_nfs_efd(i).dm_ind_oper
                             , ev_cod_part      => vt_tab_csf_nfs_efd(i).cod_part
                             , ev_serie         => vt_tab_csf_nfs_efd(i).serie
                             , ev_sub_serie     => vt_tab_csf_nfs_efd(i).subserie
                             , en_nro_nf        => vt_tab_csf_nfs_efd(i).nro_nf
                             , en_notafiscal_id => pk_csf_api.gt_row_nota_fiscal.id );
         --
         vn_fase := 17;
         --
         -- chama procedimento de validação dos totais da Nota Fiscal de Serviço
         pk_csf_api_nfserv.pkb_valida_total_nf_serv_efd ( est_log_generico_nf     => vt_log_generico_nf
                                                        , en_notafiscal_id     => pk_csf_api.gt_row_nota_fiscal.id
                                                        );
         --
         -- atualiza situação da Nota
         if nvl(vt_log_generico_nf.count,0) > 0 then
            --
            vn_fase := 18;
            --
            update nota_fiscal set dm_st_proc = 10 -- erro de validação
             where id = pk_csf_api.gt_row_nota_fiscal.id;
            --
         elsif vt_tab_csf_nfs_efd(i).sit_docto in ('02','03','04') and -- 02-Documento cancelado, 03-Documento cancelado extemporâneo, 04-NF-e ou CT-e denegado
               vt_tab_csf_nfs_efd(i).dm_ind_emit = 0 then -- 0-emissão própria, 1-terceiros
               --
               vn_fase := 19;
               --
               update nota_fiscal set dm_st_proc = 7 -- Nota Fiscal Cancelada
                where id = pk_csf_api.gt_row_nota_fiscal.id;
               --
         else
            --
            vn_fase := 19;
            --
            update nota_fiscal set dm_st_proc = 4 -- Nota Fiscal Autorizada
             where id = pk_csf_api.gt_row_nota_fiscal.id;
            --
         end if;
         --
         -- Calcula a quantidade de registros integrados com sucesso
         -- e com erro para ser mostrado na tela de agendamento.
         --
         if nvl(vt_log_generico_nf.count,0) > 0 then -- Erro de validação
            --
            pk_agend_integr.gvtn_qtd_erro(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_erro(gv_cd_obj),0) + 1;
            --
         else
            --
            pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_sucesso(gv_cd_obj),0) + 1;
            --
         end if;
         --
         pk_csf_api.pkb_seta_referencia_id ( en_id => null );
         --
         <<ler_outro>>
         --
         null;
         --
      end loop;
      --
      vn_fase := 20;
      --
      commit;
      --
   end if;
   --
   <<sair_geral>>
   --
   null;
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pkb_int_view_nfserv_efd.pkb_ler_nfserv_efd fase(' || vn_fase || ' - cnpj:' || gv_cpf_cnpj || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                                     , ev_mensagem        => null
                                     , ev_resumo          => pk_csf_api.gv_mensagem_log
                                     , en_tipo_log        => pk_csf_api.erro_de_sistema
                                     , en_referencia_id   => pk_csf_api.gn_referencia_id
                                     , ev_obj_referencia  => pk_csf_api.gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_ler_nfserv_efd;

-------------------------------------------------------------------------------------------------------
--| Procedimento que inicia a integração de NFs de Serviços para EFD
procedure pkb_integracao ( en_empresa_id  in number
                         , ed_dt_ini      in date
                         , ed_dt_fin      in date )
is
   --
   vn_fase number := 0;
   vv_cpf_cnpj_emit varchar2(14);
   --
   cursor c_empr is
   select e.id empresa_id
        , e.dt_ini_integr
        , eib.owner_obj
        , eib.nome_dblink
        , eib.dm_util_aspa
        , eib.dm_ret_infor_integr
        , eib.formato_dt_erp
        , eib.dm_form_dt_erp
        , e.multorg_id
     from empresa e
        , empresa_integr_banco eib
    where e.id = en_empresa_id
      and e.dm_tipo_integr in (3, 4) -- Integração por view
      and e.dm_situacao    = 1 -- Ativa
      and eib.empresa_id   = e.id
    order by 1;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   -- Seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 2;
   --
   pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   vn_fase := 3;
   --
   gd_dt_ini  := ed_dt_ini;
   gd_dt_fin  := ed_dt_fin;
   --
   vn_fase := 5;
   --
   pkb_limpa_array;
   --
   vn_fase := 6;
   --
   for rec in c_empr loop
      exit when c_empr%notfound or (c_empr%notfound) is null;
      --
      vv_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 7;
      -- Setar o dblink
      gv_nome_dblink := rec.nome_dblink;
      gv_owner_obj   := rec.owner_obj;
      gv_cpf_cnpj    := vv_cpf_cnpj_emit;
      gn_multorg_id  := rec.multorg_id;
      --
      vn_fase := 8;
      --
      -- Verifica se utiliza aspas dupla
      if rec.dm_util_aspa = 1 then
         gv_aspas := '"';
      else
         gv_aspas := NULL;
      end if;
      --
      -- Setar formato da data para os procedimentos de integracao
      if trim(rec.formato_dt_erp) is not null then
         gv_formato_dt_erp := rec.formato_dt_erp;
      else
         gv_formato_dt_erp := gv_formato_data;
      end if;
      --
      vn_fase := 9;
      --
      -- Leitura das Notas fiscais de serviço para EFD
      pkb_ler_nfserv_efd;
      --
   end loop;
   --
   vn_fase := 10;
   --
   -- Finaliza o log genérico para a integração das Notas Fiscais de Serviço para EFD
   pk_csf_api.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 11;
   --
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
exception
   when others then
      --
      pk_csf_api.gv_mensagem_log := 'Erro na pk_int_view_nfserv_efd.pkb_integracao fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%TYPE;
      begin
         --
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                     , ev_mensagem       => pk_csf_api.gv_mensagem_log
                                     , ev_resumo         => null
                                     , en_tipo_log       => pk_csf_api.erro_de_sistema );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_integracao;

-------------------------------------------------------------------------------------------------------

-- Processo de integração por período informando todas as empresas ativas

procedure pkb_integr_periodo_geral ( ed_dt_ini in date
                                   , ed_dt_fin in date 
                                   )
is
   --
   vn_fase  number := 0;
   --
   cursor c_serv is
   select p.*
        , e.id empresa_id
        , e.ar_empresa_id
        , e.multorg_id multorg_id_empr
     from pessoa p
        , empresa e
    where e.pessoa_id = p.id
      and e.dm_situacao = 1 -- Ativa
    order by p.cod_part;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   -- Seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 2;
   --
   pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   vn_fase := 3;
   --
   gd_dt_ini  := ed_dt_ini;
   gd_dt_fin  := ed_dt_fin;
   --
   vn_fase := 4;
   --
   pkb_limpa_array;
   --
   vn_fase := 5;
   --
   for rec in c_serv loop
      --
      vn_fase := 6;
      --
      GV_NOME_DBLINK    := null;
      GV_OWNER_OBJ      := null;
      GV_ASPAS          := null;
      gv_cpf_cnpj       := rec.cod_part;
      gv_formato_dt_erp := gv_formato_data;
      gn_multorg_id     := rec.multorg_id_empr;
      --
      vn_fase := 7;
      --
      pkb_ler_nfserv_efd;
      --
   end loop;
   --
   vn_fase := 8;
   --
   -- Finaliza o log genérico para a integração das Notas Fiscais de Serviço para EFD
   pk_csf_api.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 9;
   --
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_int_view_nfserv_efd.pkb_integr_periodo_geral: ' || sqlerrm);
end pkb_integr_periodo_geral;

-------------------------------------------------------------------------------------------------------

-- Processo de integração informando todas as empresas matrizes

procedure pkb_integr_empresa_geral ( en_paramintegrdados_id  in param_integr_dados.id%type 
                                   , ed_dt_ini               in date
                                   , ed_dt_fin               in date 
                                   )
is
   --
   vn_fase number := 0;
   --
   vv_cpf_cpf_cnpj_emit varchar2(14);
   --
   cursor c_empr is
   select p.*
        , e.multorg_id
     from param_integr_dados_empresa p
        , empresa e
    where p.paramintegrdados_id = en_paramintegrdados_id
      and e.id = p.empresa_id
      and e.dm_situacao = 1 -- Ativo
    order by 1;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);
   --
   vn_fase := 1;
   --
   gv_formato_data := pk_csf.fkg_param_global_csf_form_data;
   --
   -- Seta o tipo de integração que será feito
   -- 0 - Somente válida os dados e registra o Log de ocorrência
   -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
   -- Todos os procedimentos de integração fazem referência a ele
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => 1 );
   --
   vn_fase := 2;
   --
   pk_csf_api.pkb_seta_obj_ref ( ev_objeto => 'NOTA_FISCAL' );
   --
   vn_fase := 3;
   --
   pkb_limpa_array;
   --
   vn_fase := 4;
   --
   for rec in c_empr loop
      --
      vn_fase := 5;
      --
      vv_cpf_cpf_cnpj_emit := pk_csf.fkg_cnpj_ou_cpf_empresa ( en_empresa_id => rec.empresa_id );
      --
      -- Se ta o DBLink
      GV_NOME_DBLINK := null;
      GV_OWNER_OBJ   := null;
      GV_ASPAS := null;
      gv_formato_dt_erp := gv_formato_data;
      --
      gd_dt_ini     := ed_dt_ini;
      gd_dt_fin     := ed_dt_fin;
      gv_cpf_cnpj   := vv_cpf_cpf_cnpj_emit;
      gn_multorg_id := rec.multorg_id;
      --
      vn_fase := 6;
      --
      -- Leitura das Notas fiscais de serviço para EFD
      pkb_ler_nfserv_efd;
      --
      commit;
      --
   end loop;
   --
   vn_fase := 10;
   --
   -- Finaliza o log genérico para a integração das Notas Fiscais de Serviço para EFD
   pk_csf_api.pkb_finaliza_log_generico_nf;
   --
   vn_fase := 11;
   --
   pk_csf_api.pkb_seta_tipo_integr ( en_tipo_integr => null );
   --
   commit;
   --
exception
   when others then
      raise_application_error (-20101, 'Erro na pk_int_view_nfserv_efd.pkb_integr_empresa_geral: ' || sqlerrm);
end pkb_integr_empresa_geral;

-------------------------------------------------------------------------------------------------------

end pk_int_view_nfserv_efd;
/
