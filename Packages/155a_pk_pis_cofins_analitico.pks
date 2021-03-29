create or replace package csf_own.pk_pis_cofins_analitico is

-------------------------------------------------------------------------------------------------------
--| Especificação da Package de Geração de PIS COFINS ANALITICO
--
-- Em 16/03/2021     - Allan Magrini
-- Redmine #52590    :  Relatório para conferência de Apuração de PIS/COFINS.
-- Rotina criada.
--                      
-------------------------------------------------------------------------------------------------------

-- Declaração de constantes
gv_resumo_log         log_generico.resumo%type := null;

-------------------------------------------------------------------------------------------------------
-- Procedure para inclusão dos itens da Nota_fiscal no Analitico PIS COFINS
 
PROCEDURE PKB_INCLUI_NOTA_FISCAL( EN_NOTAFISCAL_ID    IN NOTA_FISCAL.ID%TYPE
                                , EN_EMPRESA_ID       IN EMPRESA.ID%TYPE
                                , EN_MULTORG_ID       IN MULT_ORG.ID%TYPE
                                , EN_DM_ST_PROC       IN NOTA_FISCAL.DM_ST_PROC%TYPE
                                , EN_DM_ARM_NFE_TERC  IN NOTA_FISCAL.DM_ARM_NFE_TERC%TYPE
                                , EN_MODFISCAL_ID     IN NOTA_FISCAL.MODFISCAL_ID%TYPE
                                , EN_DM_IND_EMIT      IN NOTA_FISCAL.DM_IND_EMIT%TYPE
                                , EN_DT_REF           IN NOTA_FISCAL.DT_SAI_ENT%TYPE
                                , EN_DM_FIN_NFE       IN NOTA_FISCAL.DM_FIN_NFE%TYPE);
-------------------------------------------------------------------------------------------------------
-- Procedure para inclusão dos itens da Nota_fiscal no Analitico PIS COFINS
 
PROCEDURE PKB_EXCLUI_NOTA_FISCAL( EN_NOTAFISCAL_ID   IN NOTA_FISCAL.ID%TYPE
                                , EN_EMPRESA_ID      IN EMPRESA.ID%TYPE
                                , EN_MULTORG_ID      IN MULT_ORG.ID%TYPE);
                                
-------------------------------------------------------------------------------------------------------
-- Procedure para inclusão dos itens da CONHEC_TRANSP no Analitico PIS COFINS
 
PROCEDURE PKB_INCLUI_CONHEC_TRANSP( EN_CONHECTRANSP_ID   IN CONHEC_TRANSP.ID%TYPE
                                  , EN_EMPRESA_ID        IN EMPRESA.ID%TYPE
                                  , EN_MULTORG_ID        IN MULT_ORG.ID%TYPE
                                  , EN_DM_ST_PROC        IN CONHEC_TRANSP.DM_ST_PROC%TYPE
                                  , EN_DM_ARM_CTE_TERC   IN CONHEC_TRANSP.DM_ARM_CTE_TERC%TYPE
                                  , EN_DM_IND_OPER       IN CONHEC_TRANSP.DM_IND_OPER%TYPE
                                  , EN_DT_REF            IN CONHEC_TRANSP.DT_SAI_ENT%TYPE
                                  , EN_DM_IND_EMIT       IN CONHEC_TRANSP.DM_IND_EMIT%TYPE
                                  , EN_MODFISCAL_ID      IN CONHEC_TRANSP.MODFISCAL_ID%TYPE);
-------------------------------------------------------------------------------------------------------
-- Procedure para inclusão dos itens da CONHEC_TRANSP no Analitico PIS COFINS
 
PROCEDURE PKB_EXCLUI_CONHEC_TRANSP( EN_CONHECTRANSP_ID   IN CONHEC_TRANSP.ID%TYPE
                                  , EN_EMPRESA_ID        IN EMPRESA.ID%TYPE
                                  , EN_MULTORG_ID        IN MULT_ORG.ID%TYPE);
                                  
--
end pk_pis_cofins_analitico;
/
