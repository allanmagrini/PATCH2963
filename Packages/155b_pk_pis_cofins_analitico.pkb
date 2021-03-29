create or replace package body pk_pis_cofins_analitico is

-------------------------------------------------------------------------------------------------------
--| Corpo do pacote de Geração de dados PIS / COFINS Analítico
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
-- Procedimento de Inclusão de NF
-------------------------------------------------------------------------------------------------------

PROCEDURE PKB_INCLUI_NOTA_FISCAL( EN_NOTAFISCAL_ID    IN NOTA_FISCAL.ID%TYPE
                                , EN_EMPRESA_ID       IN EMPRESA.ID%TYPE
                                , EN_MULTORG_ID       IN MULT_ORG.ID%TYPE
                                , EN_DM_ST_PROC       IN NOTA_FISCAL.DM_ST_PROC%TYPE
                                , EN_DM_ARM_NFE_TERC  IN NOTA_FISCAL.DM_ARM_NFE_TERC%TYPE
                                , EN_MODFISCAL_ID     IN NOTA_FISCAL.modfiscal_id%TYPE
                                , EN_DM_IND_EMIT      IN NOTA_FISCAL.DM_IND_EMIT%TYPE
                                , EN_DT_REF           IN NOTA_FISCAL.DT_SAI_ENT%TYPE
                                , EN_DM_FIN_NFE       IN NOTA_FISCAL.DM_FIN_NFE%TYPE) IS
--
 --declare
   vn_existe number; 
   vn_fase   number := 0;  
--
cursor n_pis_cofins  is
    select   it.Notafiscal_Id
           , it.id     itemnf_id
           , ii.codst_id
           , it.cfop_id
           , ii.tipoimp_id
           , nvl((ii.qtde_base_calc_prod * ii.vl_aliq_prod),0) vl_contabil
           , nvl(ii.vl_base_calc,0) vl_contabil_bc
           , nvl(ii.aliq_apli,0) aliq
           , nvl(ii.qtde_base_calc_prod,0) vl_bc_qtde
           , nvl(ii.vl_aliq_prod,0) aliq_reais
           , nvl(ii.vl_imp_trib,0) valor 
           , '' BC_CALC_CRED    --(bc.cd||' - '||bc.descr BC_CALC_CRED)arrumar      
           , ii.natrecpc_id    
        from mod_fiscal       mf
           , item_nota_fiscal it
           , imp_itemnf       ii
           , tipo_imposto     ti
           , cod_st           cst
           --, base_calc_cred_pc bc
       where it.notafiscal_id   = en_notafiscal_id
         and 4                  = en_dm_st_proc      -- autorizada
         and 0                  = en_dm_arm_nfe_terc -- 0-não, 1-sim
         and mf.id              = en_modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65') -- NF, NF de Produtor, NF Avulsa, NF Eletrônica
         and ii.itemnf_id       = it.id
         --and bc.id              =    --cc.basecalccredpc_id
         and ii.dm_tipo         = 0 -- IMPOSTO
         and ti.id              = ii.tipoimp_id
         and ti.cd              in ('4','5') --4 Pis / 5 COFINS
         and cst.id             = ii.codst_id
         and cst.cod_st        in ('01', '02', '03', '05')
       order by it.notafiscal_id
           , it.id
           , ii.id
           , ii.codst_id;
--         
BEGIN
   --
   vn_fase := 1;
   --   
   for r_pis_cofins in n_pis_cofins
   loop   
   --
   vn_existe:= 0;
   --
   begin
    select count(*)
          into vn_existe
          from APURA_PC_DOC_ITEM   
       where  REFERENCIA_ID = EN_NOTAFISCAL_ID
         and  ITEMNF_ID     = r_pis_cofins.itemnf_id
         and  TIPOIMP_ID    = r_pis_cofins.tipoimp_id
         and  EMPRESA_ID    = EN_EMPRESA_ID
         and  MULTORG_ID    = EN_MULTORG_ID;
     exception
        when others then
          null;
     end;
   --
   vn_fase := 2;
   -- 
   if nvl(vn_existe,0) = 0 then
   --
     insert into APURA_PC_DOC_ITEM( ID
                                 , REFERENCIA_ID
                                 , ITEMNF_ID
                                 , OBJ_REFERENCIA 
                                 , EMPRESA_ID
                                 , CODST_ID
                                 , CFOP_ID
                                 , TIPOIMP_ID
                                 , VL_CONTABIL  
                                 , VL_BC --10
                                 , ALIQ
                                 , BC_QTDE
                                 , ALIQ_REAIS 
                                 , VALOR                                        
                                 , BC_CALC_CRED    
                                 , NAT_REC_PC  
                                 , DM_IND_EMIT
                                 , DT_REF
                                 , DM_FIN_NFE  
                                 , MULTORG_ID 
                                  )
                        values( apurapcdocitem_seq.NextVal
                              , EN_NOTAFISCAL_ID
                              , r_pis_cofins.itemnf_id
                              , 'NOTA_FISCAL'
                              , EN_EMPRESA_ID
                              , r_pis_cofins.codst_id
                              , r_pis_cofins.cfop_id
                              , r_pis_cofins.tipoimp_id
                              , r_pis_cofins.vl_contabil
                              , r_pis_cofins.vl_contabil_bc --10
                              , r_pis_cofins.aliq
                              , r_pis_cofins.vl_bc_qtde
                              , r_pis_cofins.aliq_reais
                              , r_pis_cofins.valor
                              , r_pis_cofins.bc_calc_cred
                              , r_pis_cofins.natrecpc_id
                              , en_dm_ind_emit
                              , en_dt_ref
                              , en_dm_fin_nfe
                              , EN_MULTORG_ID);
   --
   else 
   --
   vn_fase := 3;
   --
     update APURA_PC_DOC_ITEM
       SET  CODST_ID      = r_pis_cofins.codst_id                             
           , CFOP_ID      = r_pis_cofins.cfop_id
           , VL_CONTABIL  = r_pis_cofins.vl_contabil
           , VL_BC        = r_pis_cofins.vl_contabil_bc
           , ALIQ         = r_pis_cofins.aliq
           , BC_QTDE      = r_pis_cofins.vl_bc_qtde
           , ALIQ_REAIS   = r_pis_cofins.aliq_reais
           , VALOR        = r_pis_cofins.valor
           , BC_CALC_CRED = r_pis_cofins.bc_calc_cred
           , NAT_REC_PC   = r_pis_cofins.natrecpc_id
           , DM_IND_EMIT  = en_dm_ind_emit
           , DT_REF       = en_DT_REF
           , DM_FIN_NFE   = en_DM_FIN_NFE
       WHERE 1=1
         and REFERENCIA_ID  = EN_NOTAFISCAL_ID
         and ITEMNF_ID      = r_pis_cofins.itemnf_id
         and TIPOIMP_ID     = r_pis_cofins.tipoimp_id
         and OBJ_REFERENCIA = 'NOTA_FISCAL'
         and EMPRESA_ID     = EN_EMPRESA_ID
         and MULTORG_ID     = EN_MULTORG_ID;
    --    
    end if; 
   -- 
   end loop;
   --    
EXCEPTION
   when others then
      raise_application_error (-20101, 'Problemas ao incluir - PKB_INCLUI_NOTA_FISCAL (notafiscal_id = '||en_notafiscal_id||'), fase('||vn_fase||'). Erro = '||sqlerrm);  
END PKB_INCLUI_NOTA_FISCAL;

-------------------------------------------------------------------------------------------------------
-- Procedimento de Inclusão de CTE
-------------------------------------------------------------------------------------------------------

PROCEDURE PKB_INCLUI_CONHEC_TRANSP( EN_CONHECTRANSP_ID   IN CONHEC_TRANSP.ID%TYPE
                                  , EN_EMPRESA_ID        IN EMPRESA.ID%TYPE
                                  , EN_MULTORG_ID        IN MULT_ORG.ID%TYPE
                                  , EN_DM_ST_PROC        IN CONHEC_TRANSP.DM_ST_PROC%TYPE
                                  , EN_DM_ARM_CTE_TERC   IN CONHEC_TRANSP.DM_ARM_CTE_TERC%TYPE
                                  , EN_DM_IND_OPER       IN CONHEC_TRANSP.DM_IND_OPER%TYPE
                                  , EN_DT_REF            IN CONHEC_TRANSP.DT_SAI_ENT%TYPE
                                  , EN_DM_IND_EMIT       IN CONHEC_TRANSP.DM_IND_EMIT%TYPE
                                  , EN_MODFISCAL_ID      IN CONHEC_TRANSP.MODFISCAL_ID%TYPE) IS
--
 --declare
   vn_existe number;
   vn_fase   number := 0;   
--
cursor c_pis_cofins  is
    select distinct cr.conhectransp_id  
           , cc.id ctcompdocpis_id
           , (select id from tipo_imposto where cd = '4') tipoimp_id
           , cr.cfop_id
           , cc.codst_id
           --         
           , nvl(cc.vl_bc_pis,0)  vl_contabil  
           , nvl(cc.vl_bc_pis,0)  vl_bc
           , nvl(cc.aliq_pis,0) aliq  
           , nvl(cc.vl_bc_pis,0) vl_bc_qtde           
           , nvl(cc.aliq_pis,0) aliq_reais
           , nvl(cc.vl_pis,0) valor
           --
           , cc.natrecpc_id
           , bc.cd||' - '||bc.descr BC_CALC_CRED            
        from mod_fiscal        mf
           , ct_comp_doc_pis   cc
           , ct_reg_anal       cr
           , base_calc_cred_pc bc
       where cr.conhectransp_id = EN_CONHECTRANSP_ID
         and en_dm_st_proc      = 4 -- autorizado
         and en_dm_arm_cte_terc = 0 -- 0-Não, 1-Sim
         and en_dm_ind_oper     = 0 -- 0-Entrada, 1-Saída 
         and bc.id              = cc.basecalccredpc_id
         and mf.id              = EN_MODFISCAL_ID
         and mf.cod_mod        in ('07', '08', '8B', '09', '10', '11', '26', '27', '57', '63', '67')
         and cc.conhectransp_id = cr.conhectransp_id
           --         
           union     
           --     
    select distinct cr.conhectransp_id
           , cc.id ctcompdoccofins_id
           , (select id from tipo_imposto where cd = '5') tipoimp_id
           , cr.cfop_id
           , cc.codst_id 
           --  
           , nvl(cc.vl_bc_cofins,0)  vl_contabil  
           , nvl(cc.vl_bc_cofins,0)  vl_bc
           , nvl(cc.aliq_cofins,0) aliq  
           , nvl(cc.vl_bc_cofins,0) vl_bc_qtde           
           , nvl(cc.aliq_cofins,0) aliq_reais
           , nvl(cc.vl_cofins,0) valor
           --
           , cc.natrecpc_id
           , bc.cd||' - '||bc.descr BC_CALC_CRED 
        from mod_fiscal      mf
           , ct_comp_doc_cofins cc
           , ct_reg_anal     cr
           , base_calc_cred_pc bc
       where cr.conhectransp_id = EN_CONHECTRANSP_ID
         and bc.id              = cc.basecalccredpc_id
         and en_dm_st_proc      = 4 -- autorizado
         and en_dm_arm_cte_terc = 0 -- 0-Não, 1-Sim
         and en_dm_ind_oper     = 0 -- 0-Entrada, 1-Saída
         and mf.id              = EN_MODFISCAL_ID
         and mf.cod_mod        in ('07', '08', '8B', '09', '10', '11', '26', '27', '57', '63', '67')
         and cc.conhectransp_id = cr.conhectransp_id
       order by 1,2,3;  
  --         
BEGIN
   --
   vn_fase := 1;
   --      
   for t_pis_cofins in c_pis_cofins
   loop   
   
   begin
    select count(*)
          into vn_existe
          from APURA_PC_DOC_ITEM   
       where  REFERENCIA_ID = EN_CONHECTRANSP_ID
         and  TIPOIMP_ID    = t_pis_cofins.tipoimp_id
         and  EMPRESA_ID    = EN_EMPRESA_ID
         and  MULTORG_ID    = EN_MULTORG_ID;
     exception
        when others then
          null;
     end;
   --
   vn_fase := 2;
   --   
   if nvl(vn_existe,0) = 0 then
   --
     insert into APURA_PC_DOC_ITEM( ID
                                 , REFERENCIA_ID
                                 , ITEMNF_ID
                                 , OBJ_REFERENCIA 
                                 , EMPRESA_ID
                                 , CODST_ID
                                 , CFOP_ID
                                 , TIPOIMP_ID
                                 , VL_CONTABIL  
                                 , VL_BC--10
                                 , ALIQ
                                 , BC_QTDE
                                 , ALIQ_REAIS 
                                 , VALOR                                       
                                 , BC_CALC_CRED  
                                 , NAT_REC_PC   
                                 , DM_IND_EMIT
                                 , DT_REF
                                 , DM_FIN_NFE  
                                 , MULTORG_ID 
                                  )
                        values( apurapcdocitem_seq.NextVal
                              , EN_CONHECTRANSP_ID
                              , null
                              , 'CONHEC_TRANSP'
                              , EN_EMPRESA_ID
                              , t_pis_cofins.codst_id
                              , t_pis_cofins.cfop_id
                              , t_pis_cofins.tipoimp_id
                              , t_pis_cofins.vl_contabil
                              , t_pis_cofins.vl_bc
                              , t_pis_cofins.aliq 
                              , t_pis_cofins.vl_bc_qtde
                              , t_pis_cofins.aliq_reais
                              , t_pis_cofins.valor
                              , t_pis_cofins.BC_CALC_CRED
                              , t_pis_cofins.natrecpc_id
                              , EN_DM_IND_EMIT
                              , EN_DT_REF
                              , null 
                              , EN_MULTORG_ID);
   --
   else 
   --
   vn_fase := 3;
   --  
     update APURA_PC_DOC_ITEM
       SET  CODST_ID      = t_pis_cofins.codst_id                             
           , CFOP_ID      = t_pis_cofins.cfop_id
           , VL_CONTABIL  = t_pis_cofins.vl_contabil
           , VL_BC        = t_pis_cofins.vl_bc
           , ALIQ         = t_pis_cofins.aliq
           , BC_QTDE      = t_pis_cofins.vl_bc_qtde
           , ALIQ_REAIS   = t_pis_cofins.aliq_reais
           , VALOR        = t_pis_cofins.valor
           , BC_CALC_CRED = t_pis_cofins.BC_CALC_CRED
           , NAT_REC_PC   = t_pis_cofins.natrecpc_id
           , DM_IND_EMIT  = en_dm_ind_emit
           , DT_REF       = EN_DT_REF
       WHERE 1=1
         and REFERENCIA_ID  = EN_CONHECTRANSP_ID
         and TIPOIMP_ID     = t_pis_cofins.tipoimp_id
         and OBJ_REFERENCIA = 'CONHEC_TRANSP'
         and EMPRESA_ID     = EN_EMPRESA_ID
         and MULTORG_ID     = EN_MULTORG_ID;
    --    
    end if; 
   --  
   end loop;
   -- 
EXCEPTION
   when others then
      raise_application_error (-20101, 'Problemas ao incluir - PKB_INCLUI_CONHEC_TRANSP (conhectransp_id = '||EN_CONHECTRANSP_ID||'), fase('||vn_fase||'). Erro = '||sqlerrm);  
END PKB_INCLUI_CONHEC_TRANSP;
                             
-----------------------------------------------------------------------------                                  
--| Procedimento para excluir a Nota e itens do processo analitico PIS COFINS
-----------------------------------------------------------------------------
procedure PKB_EXCLUI_NOTA_FISCAL ( EN_NOTAFISCAL_ID   IN NOTA_FISCAL.ID%TYPE
                                 , EN_EMPRESA_ID      IN EMPRESA.ID%TYPE
                                 , EN_MULTORG_ID      IN MULT_ORG.ID%TYPE) 
is
begin
   --
   -- Exclui os dados da tabela
   delete APURA_PC_DOC_ITEM a
     where a.referencia_id = EN_NOTAFISCAL_ID 
       and a.empresa_id    = EN_EMPRESA_ID
       and a.multorg_id    = EN_MULTORG_ID;
   --   
   --commit;
   --
exception
   when others then
      gv_resumo_log := 'Erro na procedure APURA_PC_DOC_ITEM : '||sqlerrm;
      raise_application_error (-20101, gv_resumo_log);
end PKB_EXCLUI_NOTA_FISCAL;
 
--------------------------------------------------------------------------------------------------------------
--| Procedimento para excluir a CTe do processo analitico PIS COFINS
-----------------------------------------------------------------------------
PROCEDURE PKB_EXCLUI_CONHEC_TRANSP( EN_CONHECTRANSP_ID   IN CONHEC_TRANSP.ID%TYPE
                                  , EN_EMPRESA_ID        IN EMPRESA.ID%TYPE
                                  , EN_MULTORG_ID        IN MULT_ORG.ID%TYPE) 
is
begin
   --
   -- Exclui os dados da tabela
   delete APURA_PC_DOC_ITEM a
     where a.referencia_id = EN_CONHECTRANSP_ID 
       and a.empresa_id    = EN_EMPRESA_ID
       and a.multorg_id    = EN_MULTORG_ID;
   --   
   --commit;
   --
exception
   when others then
      gv_resumo_log := 'Erro na procedure APURA_PC_DOC_ITEM : '||sqlerrm;
      raise_application_error (-20101, gv_resumo_log);
end PKB_EXCLUI_CONHEC_TRANSP;

--------------------------------------------------------------------------------------------------------------


end pk_pis_cofins_analitico;
/
