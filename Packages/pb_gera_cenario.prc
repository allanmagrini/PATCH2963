CREATE OR REPLACE PROCEDURE CSF_OWN.PB_GERA_CENARIO ( en_multorg_id    in mult_org.id%type
                                                    , ed_dt_ini        in date
                                                    , ed_dt_fim        in date) is
/*
* Script para preparar tabelas auxiliares para fazer export do banco de dados produção do cliente
* para criação de cenário Local
* Criado por Marcos Ferreira
* Data: 03/09/2019
*/
   --
   vv_dt_ini        varchar2(10) := to_char(ed_dt_ini, 'DD/MM/YYYY');
   vv_dt_fim        varchar2(10) := to_char(ed_dt_fim, 'DD/MM/YYYY');
   vv_table_name    varchar2(255);
   vv_sql           varchar2(3000);
   --
   procedure pb_cria_tabela( ev_table_name varchar2
                            ,ev_sql        long) 
   is
   begin
      --
      -- DROPA A TABELA M$ CASO EXISTA
      begin
         execute immediate 'DROP TABLE M$'||ev_table_name;
      exception
         when others then
            null;
      end;
      -- EXECUTA O COMANDO DE CRIAÇÃO
      begin
         execute immediate ev_sql;
      exception 
         when others then
            dbms_output.put_line('Erro na criação da tabela temporária: '||ev_table_name||' - Erro Retornado: '||sqlerrm);
      end;
      -- GRANT
      begin
         execute immediate 'GRANT ALL ON CSF_OWN.M$'||ev_table_name||' TO DESENV_USER';
      exception
         when others then
            dbms_output.put_line('Erro na execução do GRANT da tabela temporária: M$'||ev_table_name||' para o DESEV_USER - Erro Retornado: '||sqlerrm);
      end;   
      --
      begin
         execute immediate 'GRANT ALL ON CSF_OWN.M$'||ev_table_name||' TO MLFERREIRA';
      exception
         when others then
            dbms_output.put_line('Erro na execução do GRANT da tabela temporária: M$'||ev_table_name||' para o MLFERREIRA - Erro Retornado: '||sqlerrm);
      end;
      --      
   end pb_cria_tabela;
   
BEGIN
   -- Grant de todas as tabelas para o desenv_user
   begin
      for x in (select * from all_tables t where t.OWNER = 'CSF_OWN')
      loop
         execute immediate('GRANT ALL ON CSF_OWN.'||x.table_name||' TO DESENV_USER');
      end loop;
   exception
      when others then null;
   end;
   --
   -- Grant de todas as tabelas para o mlferreira
   begin
      for x in (select * from all_tables t where t.OWNER = 'CSF_OWN')
      loop
         execute immediate('GRANT ALL ON CSF_OWN.'||x.table_name||' TO MLFERREIRA');
      end loop;
   exception
      when others then null;
   end;
   --
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --------------------------------------------------------- TABELAS VERMELAS -------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --
   -- TABELA VERSAO_SISTEMA --------------------------------------------------------------------------------------------------------------
   begin
      vv_table_name := 'VERSAO_SISTEMA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM '|| vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;
   --
   -- TABELA SEQ_TAB --------------------------------------------------------------------------------------------------------------
   begin
      vv_table_name := 'SEQ_TAB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM '|| vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;
   --
   -- TABELA MULT_ORG --------------------------------------------------------------------------------------------------------------
   begin
      vv_table_name := 'MULT_ORG';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM '|| vv_table_name ||' 
                 WHERE ID = '||en_multorg_id;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;
   --   
   -- TABELA PAIS ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'PAIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM '|| vv_table_name;  
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;   
   -- TABELA ESTADO ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'ESTADO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM '|| vv_table_name;  
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;   
   -- TABELA CIDADE ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'CIDADE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM '|| vv_table_name;  
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;   
   -- TABELA CSF_TIPO_LOG -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CSF_TIPO_LOG';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA DOMINIO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DOMINIO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;   
   --
   -- TABELA PROC_REGRA_NEGOCIO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PROC_REGRA_NEGOCIO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;   
   --
   -- TABELA PROC_REGRA_NEGOCIO_EXCECAO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PROC_REGRA_NEGOCIO_EXCECAO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;   
   --
   -- TABELA DEPARTAMENTO ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DEPARTAMENTO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA TIPO_SERVICO ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_SERVICO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA CNAE ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CNAE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA OBJ_UTIL_INTEGR ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OBJ_UTIL_INTEGR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;   
   --     
   -- TABELA FF_OBJ_UTIL_INTEGR ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'FF_OBJ_UTIL_INTEGR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;   
   --      
   -- TABELA FORMA_TRIB_REND_EXT ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'FORMA_TRIB_REND_EXT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA TP_REND_BENEF_EXT ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TP_REND_BENEF_EXT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA CLASS_TRIB ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CLASS_TRIB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA OBJ_INTEGR ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OBJ_INTEGR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA TIPO_OBJ_INTEGR ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_OBJ_INTEGR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA IMPRESSORA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IMPRESSORA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA AJUST_CONTR_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJUST_CONTR_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA COD_ST -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_ST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;  
   --      
   -- TABELA VERSAO_LAYOUT_EFD_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'VERSAO_LAYOUT_EFD_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;  
   --   
   -- TABELA TIPO_CRED_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_CRED_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;  
   --
   -- TABELA COD_AJ_BC_CONTR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_AJ_BC_CONTR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;  
   --
   -- TABELA CONTR_SOC_APUR_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_SOC_APUR_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;  
   --
   -- TABELA BASE_CALC_CRED_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'BASE_CALC_CRED_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;  
   --
   -- TABELA COD_COMPOS_DET_OIFD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_COMPOS_DET_OIFD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA PROD_DACON -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PROD_DACON';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA COD_NAT_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_NAT_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --   
   -- TABELA COD_DET_CPRB -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_DET_CPRB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --   
   -- TABELA ORIG_PROC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ORIG_PROC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --   
   -- TABELA CLASS_CONS_ITEM_CONT -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CLASS_CONS_ITEM_CONT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA COD_ANP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_ANP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA COD_ENT_REF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_ENT_REF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA RELAC_PART -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'RELAC_PART';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA COD_AJ_DECLAN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_AJ_DECLAN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA VERSAO_DECLAN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'VERSAO_DECLAN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA QUALIF_ASSIN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'QUALIF_ASSIN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA CEST -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CEST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA TIPO_EVENTO_SEFAZ -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_EVENTO_SEFAZ';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA TIPO_ESCR_CONTAB -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_ESCR_CONTAB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  
   -- TABELA VERSAO_LAYOUT_ECD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'VERSAO_LAYOUT_ECD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  
   -- TABELA REGISTRO_ECF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REGISTRO_ECF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- 
   --
   -- fim tabelas vermelhas ---------------------------------------------------------------------------------------------------------
   --
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --------------------------------------------------------- TABELAS BASICAS --------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --   
   -- TABELA EMPRESA ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'EMPRESA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM '|| vv_table_name||' 
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA EMPRESA_INTEGR_BANCO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EMPRESA_INTEGR_BANCO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA OPER_ATIV_IMOB_VEND -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OPER_ATIV_IMOB_VEND';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA OPER_ATIV_IMOB_CUS_INC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OPER_ATIV_IMOB_CUS_INC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE OPERATIVIMOBVEND_ID IN (SELECT ID FROM M$OPER_ATIV_IMOB_VEND)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA OPER_ATIV_IMOB_CUS_ORC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OPER_ATIV_IMOB_CUS_ORC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE OPERATIVIMOBVEND_ID IN (SELECT ID FROM M$OPER_ATIV_IMOB_VEND)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- 
   -- TABELA OPER_ATIV_IMOB_PROC_REF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OPER_ATIV_IMOB_PROC_REF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE OPERATIVIMOBVEND_ID IN (SELECT ID FROM M$OPER_ATIV_IMOB_VEND)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA ROT_PROG -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ROT_PROG';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA ROT_PROG_EMPRESA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ROT_PROG_EMPRESA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ROTPROG_ID IN (SELECT ID FROM M$ROT_PROG)
                   AND EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA COD_TRIB_MUNICIPIO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_TRIB_MUNICIPIO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CIDADE_ID IN (SELECT ID FROM M$CIDADE)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CIDADE_MOD_FISCAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CIDADE_MOD_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CIDADE_ID IN (SELECT ID FROM M$CIDADE)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA TIPO_RET_IMP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_RET_IMP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA TIPO_RET_IMP_RECEITA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_RET_IMP_RECEITA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE TIPORETIMP_ID IN (SELECT ID FROM M$TIPO_RET_IMP)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA SIT_DOCTO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'SIT_DOCTO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA MOD_FISCAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'MOD_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA MSG_WEBSERV -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'MSG_WEBSERV';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA LOTE -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LOTE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_ABERT,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                  AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA NEO_USUARIO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NEO_USUARIO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NEO_PAPEL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NEO_PAPEL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  
   -- TABELA NEO_USUARIO_PAPEL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NEO_USUARIO_PAPEL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE USUARIO_ID IN (SELECT ID FROM M$NEO_USUARIO)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA AGEND_INTEGR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AGEND_INTEGR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND USUARIO_ID IN (SELECT ID FROM M$NEO_USUARIO)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  
   -- TABELA IMPR_ERRO_AGEND_INTEGR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IMPR_ERRO_AGEND_INTEGR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE AGENDINTEGR_ID IN (SELECT ID FROM M$AGEND_INTEGR)
                   AND OBJINTEGR_ID   IN (SELECT ID FROM M$OBJ_INTEGR)
                   AND USUARIO_ID     IN (SELECT ID FROM M$NEO_USUARIO)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  
   -- TABELA ITEM_AGEND_INTEGR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_AGEND_INTEGR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE AGENDINTEGR_ID IN (SELECT ID FROM M$AGEND_INTEGR)
                   AND OBJINTEGR_ID   IN (SELECT ID FROM M$OBJ_INTEGR)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- 
   -- TABELA USUARIO_EMPRESA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'USUARIO_EMPRESA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  


   
   -- TABELA NAT_OPER -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NAT_OPER';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- TABELA TIPO_OPERACAO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_OPERACAO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA CFOP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CFOP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA PARAM_CFOP_EMPRESA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_CFOP_EMPRESA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID   IN (SELECT ID FROM M$EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  
      -- TABELA PARAM_CFOP_EMPR_CST -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_CFOP_EMPR_CST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODST_ID_PIS        IN (SELECT ID FROM M$COD_ST)
                   AND CODST_ID_COFINS     IN (SELECT ID FROM M$COD_ST)
                   AND PARAMCFOPEMPRESA_ID IN (SELECT ID FROM M$PARAM_CFOP_EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- 
   -- TABELA UNIDADE -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'UNIDADE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA TIPO_ITEM -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_ITEM';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA GENERO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'GENERO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA NCM -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NCM';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA EX_TIPI -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EX_TIPI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NCM_ID IN (SELECT ID FROM M$NCM)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA ITEM -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA ALTER_ITEM -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ALTER_ITEM';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEM_ID IN (SELECT ID FROM M$ITEM)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA ITEM_COMPL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_COMPL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEM_ID IN (SELECT ID FROM M$ITEM)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --    
   -- TABELA ITEM_INSUMO  -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_INSUMO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEM_ID IN (SELECT ID FROM M$ITEM)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --     
   -- TABELA CONVERSAO_UNIDADE -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONVERSAO_UNIDADE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEM_ID IN (SELECT ID FROM M$ITEM)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA FATOR_CONVERSAO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'FATOR_CONVERSAO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;    
   -- TABELA TIPO_IMPOSTO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_IMPOSTO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA PESSOA ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'PESSOA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA RESP_EMPRESA ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'RESP_EMPRESA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM '|| vv_table_name||' 
                 WHERE EMPRESA_ID     IN (SELECT ID FROM M$EMPRESA)
                   AND PESSOA_ID      IN (SELECT ID FROM M$PESSOA)
                   AND QUALIFASSIN_ID IN (SELECT ID FROM M$QUALIF_ASSIN)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --    
   -- TABELA JURIDICA ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'JURIDICA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PESSOA_ID IN (SELECT ID FROM M$PESSOA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- TABELA FISICA ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'FISICA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PESSOA_ID IN (SELECT ID FROM M$PESSOA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;
   --
   -- TABELA CONTADOR ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'CONTADOR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PESSOA_ID IN (SELECT ID FROM M$PESSOA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;
   --
   -- TABELA CONTADOR_EMPRESA ---------------------------------------------------------------------------------------------------------------   
   begin
      vv_table_name := 'CONTADOR_EMPRESA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONTADOR_ID IN (SELECT ID FROM M$CONTADOR)
                   AND EMPRESA_ID  IN (SELECT ID FROM M$EMPRESA) 
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;
   --
   -- TABELA DEPOSITO_ERP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DEPOSITO_ERP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- TABELA DE_PARA_ITEM_FORNEC -------------------------------------------------------------------------------------------------------------
   begin
      vv_table_name := 'DE_PARA_ITEM_FORNEC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;    
   -- TABELA INUTILIZA_NOTA_FISCAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INUTILIZA_NOTA_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA NOTA_FISCAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NOTA_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA) 
                      AND TRUNC(DT_EMISS,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                     AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NOTA_FISCAL_REFEREN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NOTA_FISCAL_REFEREN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NOTA_FISCAL_MDE -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NOTA_FISCAL_MDE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA LOTE_MDE -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LOTE_MDE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||' T
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND ID         IN (SELECT LOTEMDE_ID FROM M$NOTA_FISCAL_MDE';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NFINFOR_ADIC ----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NFINFOR_ADIC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA NF_COMPL_SERV ----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NF_COMPL_SERV';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA ITEM_NOTA_FISCAL ----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_NOTA_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA ITEMNF_COMPL_SERV ----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEMNF_COMPL_SERV';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEMNF_ID IN (SELECT ID FROM M$ITEM_NOTA_FISCAL)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA ITEMNF_EXPORT ----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEMNF_EXPORT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEMNF_ID IN (SELECT ID FROM M$ITEM_NOTA_FISCAL)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA IMP_ITEMNF ----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IMP_ITEMNF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEMNF_ID IN (SELECT ID FROM M$ITEM_NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA IMP_ITEMNF_ICMS_DEST ----------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IMP_ITEMNF_ICMS_DEST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE IMPITEMNF_ID IN (SELECT ID FROM M$IMP_ITEMNF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NOTA_FISCAL_EMIT ----------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NOTA_FISCAL_EMIT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NOTA_FISCAL_DEST ----------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NOTA_FISCAL_DEST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA NFDEST_EMAIL ----------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NFDEST_EMAIL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCALDEST_ID IN (SELECT ID FROM M$NOTA_FISCAL_DEST)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA NOTA_FISCAL_TOTAL ----------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NOTA_FISCAL_TOTAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;    
   -- TABELA NOTA_FISCAL_TRANSP ----------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NOTA_FISCAL_TRANSP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;  
   --   
   -- TABELA NFS_DET_CONSTR_CIVIL ----------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NFS_DET_CONSTR_CIVIL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;  
   --     
   -- TABELA NFTRANSP_VEIC ----------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NFTRANSP_VEIC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NFTRANSP_ID IN (SELECT ID FROM M$NOTA_FISCAL_TRANSP)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;    
   -- TABELA CONHEC_TRANSP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONHEC_TRANSP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA) 
                      AND TRUNC(DT_HR_EMISSAO,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                          AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONHEC_TRANSP_EMIT -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONHEC_TRANSP_EMIT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA CONHEC_TRANSP_DEST -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONHEC_TRANSP_DEST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --     
   -- TABELA CONHEC_TRANSP_IMP_RET -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONHEC_TRANSP_IMP_RET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA CT_COMP_DOC_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CT_COMP_DOC_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA CT_COMP_DOC_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CT_COMP_DOC_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA CT_INF_NFE -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CT_INF_NFE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA CONHEC_TRANSP_IMP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONHEC_TRANSP_IMP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA CONHEC_TRANSP_VLPREST -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONHEC_TRANSP_VLPREST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- TABELA CONHEC_TRANSP_INFCARGA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONHEC_TRANSP_INFCARGA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA CTINFCARGA_QTDE -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CTINFCARGA_QTDE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSPINFCARGA_ID IN (SELECT ID FROM M$CONHEC_TRANSP_INFCARGA)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA NOTA_FISCAL_PED -----------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NOTA_FISCAL_PED';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA ITEM_NF_PED ---------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_NF_PED';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCALPED_ID IN (SELECT ID FROM M$NOTA_FISCAL_PED)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA IMP_ITEMNF_PED ------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IMP_ITEMNF_PED';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEMNFPED_ID IN (SELECT ID FROM M$ITEM_NF_PED)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA MODULO_ERP ------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'MODULO_ERP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA NF_PED_ST_RET_ERP ---------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NF_PED_ST_RET_ERP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCALPED_ID IN (SELECT ID FROM M$NOTA_FISCAL_PED)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA CONHEC_TRANSP_PED -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONHEC_TRANSP_PED';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA ITEM_CT_PED -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_CT_PED';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSPPED_ID IN (SELECT ID FROM M$CONHEC_TRANSP_PED)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA CT_INF_NFE_PED -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CT_INF_NFE_PED';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSPPED_ID IN (SELECT ID FROM M$CONHEC_TRANSP_PED)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- TABELA CT_PED_ST_RET_ERP ---------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CT_PED_ST_RET_ERP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CONHECTRANSPPED_ID IN (SELECT ID FROM M$CONHEC_TRANSP_PED)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- TABELA R_LOTEINTWS_CTPEDSTRETERP -------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_LOTEINTWS_CTPEDSTRETERP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE CTPEDSTRETERP_ID IN (SELECT ID FROM M$CT_PED_ST_RET_ERP)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- TABELA LOTE_INT_WS ---------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LOTE_INT_WS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE ID IN (SELECT ID FROM M$R_LOTEINTWS_CTPEDSTRETERP)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- TABELA LOG_GENERICO_CT_PED -------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LOG_GENERICO_CT_PED';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                    WHERE REFERENCIA_ID IN (SELECT ID FROM M$CONHEC_TRANSP_PED)'; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- TABELA PEDIDO --------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PEDIDO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;    
   -- TABELA UTILIZACAO_FISCAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'UTILIZACAO_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;    
   -- TABELA ITEM_PEDIDO ---------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_PEDIDO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PEDIDO_ID IN (SELECT ID FROM M$PEDIDO)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;    
   -- TABELA IMP_ITEM_PED --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IMP_ITEMPED';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEMPEDIDO_ID IN (SELECT ID FROM M$ITEM_PEDIDO)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;      
   -- TABELA PARAM_RECEB  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_RECEB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- TABELA ITEM_PARAM_RECEB --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_PARAM_RECEB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PARAMRECEB_ID IN (SELECT ID FROM M$PARAM_RECEB)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- TABELA MODULO_SISTEMA  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'MODULO_SISTEMA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   -- TABELA GRUPO_SISTEMA  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'GRUPO_SISTEMA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   -- TABELA PARAM_GERAL_SISTEMA  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_GERAL_SISTEMA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   -- TABELA EMPR_PARAM_PEDIDO  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EMPR_PARAM_PEDIDO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA PGTO_IMP_RET  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PGTO_IMP_RET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND PESSOA_ID  IN (SELECT ID FROM M$PESSOA)
                   AND TIPOIMP_ID IN (SELECT ID FROM M$TIPO_IMPOSTO)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA PLANO_CONTA --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PLANO_CONTA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                 ';
      --
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA AGLUT_CONTABIL --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AGLUT_CONTABIL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID  IN (SELECT ID FROM M$EMPRESA)
                   AND CODNATPC_ID IN (SELECT ID FROM M$COD_NAT_PC)
                 ';
      --
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- FIM TABELAS BASICAS -----------------------------------------------------------------------------------------------------------------------------
   --
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------ REINF ---------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --
   -- TABELA GERACAO_EFD_REINF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'GERACAO_EFD_REINF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INI,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA PARAM_EFD_REINF_EMPRESA  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_EFD_REINF_EMPRESA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA LOG_PARAM_EFD_REINF_EMPRESA  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LOG_PARAM_EFD_REINF_EMPRESA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PARAMEFDREINFEMPRESA_ID IN (SELECT ID FROM M$PARAM_EFD_REINF_EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA EFD_REINF_R1000  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R1000';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA EFD_REINF_R1070  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R1070';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --      
   -- TABELA EFD_REINF_R2010  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2010';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFD_REINF_R2010_NF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2010_NF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2010_ID IN (SELECT ID FROM M$EFD_REINF_R2010)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFD_REINF_R2010_CTE  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2010_CTE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2010_ID IN (SELECT ID FROM M$EFD_REINF_R2010)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFD_REINF_R2020  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2020';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA EFD_REINF_R2020_NF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2020_NF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2020_ID IN (SELECT ID FROM M$EFD_REINF_R2020)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFD_REINF_R2020_CTE  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2020_CTE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2020_ID IN (SELECT ID FROM M$EFD_REINF_R2020)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA EFD_REINF_R2030  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2030';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA R_EFDREINFR2030_RECRECEB  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINFR2030_RECRECEB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2030_ID IN (SELECT ID FROM M$EFD_REINF_R2030)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA EFD_REINF_R2040  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2040';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA EFD_REINF_R2040  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2040';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA R_EFDREINFR2040_RECREP  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINFR2040_RECREP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2040_ID IN (SELECT ID FROM M$EFD_REINF_R2040)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --         
   -- TABELA EFD_REINF_R2050  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2050';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA EFD_REINF_R2060  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2060';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA EFD_REINF_R2070  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2070';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --         
   -- TABELA EFD_REINF_R2070_PIR  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2070_PIR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2070_ID IN (SELECT ID FROM M$EFD_REINF_R2070)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA EFD_REINF_R2098  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2098';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --       
   -- TABELA EFD_REINF_R2099  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R2099';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --         
   -- TABELA EFD_REINF_R3010  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R3010';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --         
   -- TABELA EFD_REINF_R3010_DET  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R3010_DET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR3010_ID IN (SELECT ID FROM M$EFD_REINF_R3010)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --       
   -- TABELA EFD_REINF_R9000  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R9000';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFD_REINF_R5001_R2010  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5001_R2010';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2010_ID IN (SELECT ID FROM M$EFD_REINF_R2010)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFDREINF_R5001_R2010_DET  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFDREINF_R5001_R2010_DET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR5001R2010_ID IN (SELECT ID FROM M$EFD_REINF_R5001_R2010)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFD_REINF_R5001_R2020  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5001_R2020';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2020_ID IN (SELECT ID FROM M$EFD_REINF_R2020)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFD_REINF_R5001_R2040  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5001_R2040';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2040_ID IN (SELECT ID FROM M$EFD_REINF_R2040)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFD_REINF_R5001_R2050  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5001_R2050';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2050_ID IN (SELECT ID FROM M$EFD_REINF_R2050)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA EFD_REINF_R5001_R2060  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5001_R2060';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2060_ID IN (SELECT ID FROM M$EFD_REINF_R2060)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA EFD_REINF_R5001_R3010  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5001_R3010';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR3010_ID IN (SELECT ID FROM M$EFD_REINF_R3010)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA EFD_REINF_R5011  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5011';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR2099_ID IN (SELECT ID FROM M$EFD_REINF_R2099)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA R_EFDREINF_R9000_R2010  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINF_R9000_R2010';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR9000_ID IN (SELECT ID FROM M$EFD_REINF_R9000)
                   AND EFDREINFR2010_ID IN (SELECT ID FROM M$EFD_REINF_R2010)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA R_EFDREINF_R9000_R2020  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINF_R9000_R2020';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR9000_ID IN (SELECT ID FROM M$EFD_REINF_R9000)
                   AND EFDREINFR2020_ID IN (SELECT ID FROM M$EFD_REINF_R2020)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA R_EFDREINF_R9000_R2030  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINF_R9000_R2030';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR9000_ID IN (SELECT ID FROM M$EFD_REINF_R9000)
                   AND EFDREINFR2030_ID IN (SELECT ID FROM M$EFD_REINF_R2030)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA R_EFDREINF_R9000_R2040  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINF_R9000_R2040';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR9000_ID IN (SELECT ID FROM M$EFD_REINF_R9000)
                   AND EFDREINFR2040_ID IN (SELECT ID FROM M$EFD_REINF_R2040)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA R_EFDREINF_R9000_R2050  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINF_R9000_R2050';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR9000_ID IN (SELECT ID FROM M$EFD_REINF_R9000)
                   AND EFDREINFR2050_ID IN (SELECT ID FROM M$EFD_REINF_R2050)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA R_EFDREINF_R9000_R2060  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINF_R9000_R2060';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR9000_ID IN (SELECT ID FROM M$EFD_REINF_R9000)
                   AND EFDREINFR2060_ID IN (SELECT ID FROM M$EFD_REINF_R2060)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA R_EFDREINF_R9000_R2070  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINF_R9000_R2070';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR9000_ID IN (SELECT ID FROM M$EFD_REINF_R9000)
                   AND EFDREINFR2070_ID IN (SELECT ID FROM M$EFD_REINF_R2070)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA R_EFDREINF_R9000_R3010  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EFDREINF_R9000_R3010';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR9000_ID IN (SELECT ID FROM M$EFD_REINF_R9000)
                   AND EFDREINFR3010_ID IN (SELECT ID FROM M$EFD_REINF_R3010)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA EFD_REINF_R5011_R2010  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5011_R2010';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR5011_ID IN (SELECT ID FROM M$EFD_REINF_R5011)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA EFDREINF_R5011_R2010_DET  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFDREINF_R5011_R2010_DET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR5011R2010_ID IN (SELECT ID FROM M$EFD_REINF_R5011_R2010)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA EFD_REINF_R5011_R2020  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5011_R2020';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR5011_ID IN (SELECT ID FROM M$EFD_REINF_R5011)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA EFD_REINF_R5011_R2040  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5011_R2040';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR5011_ID IN (SELECT ID FROM M$EFD_REINF_R5011)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA EFD_REINF_R5011_R2050  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5011_R2050';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR5011_ID IN (SELECT ID FROM M$EFD_REINF_R5011)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA EFD_REINF_R5011_R2060  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_R5011_R2060';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EFDREINFR5011_ID IN (SELECT ID FROM M$EFD_REINF_R5011)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA EFD_REINF_RESUMO  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_RESUMO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA LOTE_EFD_REINF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LOTE_EFD_REINF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA CTRL_EVT_REINF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CTRL_EVT_REINF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE GERACAOEFDREINF_ID IN (SELECT ID FROM M$GERACAO_EFD_REINF)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA REC_REP_ASS_DESP  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REC_REP_ASS_DESP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA REC_RECEB_ASS_DESP  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REC_RECEB_ASS_DESP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA PROC_ADM_EFD_REINF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PROC_ADM_EFD_REINF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA LOG_PROC_ADM_EFD_REINF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LOG_PROC_ADM_EFD_REINF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PROCADMEFDREINF_ID IN (SELECT ID FROM M$PROC_ADM_EFD_REINF)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --      
   -- TABELA INF_REC_RECEB_ASS_DESP  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_REC_RECEB_ASS_DESP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RECRECEBASSDESP_ID IN (SELECT ID FROM M$REC_RECEB_ASS_DESP)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA INF_REC_REP_ASS_DESP  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_REC_REP_ASS_DESP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RECREPASSDESP_ID IN (SELECT ID FROM M$REC_REP_ASS_DESP)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA COMER_PROD_RURAL_PJ_AGR  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COMER_PROD_RURAL_PJ_AGR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA TIPO_COMER_PROD_RURAL  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_COMER_PROD_RURAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE COMERPRODRURALPJAGR_ID IN (SELECT ID FROM M$COMER_PROD_RURAL_PJ_AGR)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA TIPO_COMER_PROD_RURAL_NF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_COMER_PROD_RURAL_NF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE TIPOCOMERPRODRURAL_ID IN (SELECT ID FROM M$TIPO_COMER_PROD_RURAL)
                   AND NOTAFISCAL_ID         IN (SELECT ID FROM M$NOTA_FISCAL)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA PROC_ADM_EFD_REINF_INF_TRIB  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PROC_ADM_EFD_REINF_INF_TRIB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PROCADMEFDREINF_ID     IN (SELECT ID FROM M$PROC_ADM_EFD_REINF)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA COMER_PROD_INF_PROC_ADM  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COMER_PROD_INF_PROC_ADM';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE TIPOCOMERPRODRURAL_ID     IN (SELECT ID FROM M$TIPO_COMER_PROD_RURAL)
                   AND PROCADMEFDREINFINFTRIB_ID IN (SELECT ID FROM M$PROC_ADM_EFD_REINF_INF_TRIB)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA REC_ESP_DESPORT  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REC_ESP_DESPORT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA REC_ESP_DESP_ORT_INGR  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REC_ESP_DESP_ORT_INGR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RECESPDESPORT_ID     IN (SELECT ID FROM M$REC_ESP_DESPORT)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA REC_ESP_DESP_ORT_OUTR  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REC_ESP_DESP_ORT_OUTR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RECESPDESPORT_ID     IN (SELECT ID FROM M$REC_ESP_DESPORT)
                 ';
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA REC_ESP_DESPORT_TOTAL  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REC_ESP_DESPORT_TOTAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RECESPDESPORT_ID     IN (SELECT ID FROM M$REC_ESP_DESPORT)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA INF_PROC_ADM_REC_REP  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_PROC_ADM_REC_REP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RECREPASSDESP_ID     IN (SELECT ID FROM M$REC_REP_ASS_DESP)
                 ';
                 
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA INF_PROC_ADM_REC_RECEB  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_PROC_ADM_REC_RECEB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RECRECEBASSDESP_ID     IN (SELECT ID FROM M$REC_RECEB_ASS_DESP)
                 ';
      --           
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA INF_PROC_ADM_REC_ESP  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_PROC_ADM_REC_ESP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RECESPDESPORTTOTAL_ID     IN (SELECT ID FROM M$REC_ESP_DESPORT_TOTAL)
                 ';
                 
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA EMPR_ITEM_TPSERVREINF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EMPR_ITEM_TPSERVREINF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                 ';
      --           
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA TIPO_SERV_REINF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TIPO_SERV_REINF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 ';
      --           
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --      
   -- TABELA EVT_EFD_REINF  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EVT_EFD_REINF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA PEFD_REINF_EMPR_CONTATO  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PEFD_REINF_EMPR_CONTATO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PARAMEFDREINFEMPRESA_ID IN (SELECT ID FROM M$PARAM_EFD_REINF_EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --      
   -- TABELA PEFD_REINF_EMPR_EFR  --------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PEFD_REINF_EMPR_EFR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PARAMEFDREINFEMPRESA_ID IN (SELECT ID FROM M$PARAM_EFD_REINF_EMPRESA)
                 ';
      --            
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --         
   -- TABELA COD_ATIV_CPRB ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_ATIV_CPRB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --      
   -- TABELA EMPRESA_ATIVCPRB ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EMPRESA_ATIVCPRB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA APUR_CPRB ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CPRB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INI,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';    
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA APURACAO_CPRB ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APURACAO_CPRB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                 '; 
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA APUR_CPRB_EMPR ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CPRB_EMPR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID  IN (SELECT ID FROM M$EMPRESA)
                   AND APURCPRB_ID IN (SELECT ID FROM M$APUR_CPRB) 
                 ';   
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA APUR_CPRB_EMPR_DET ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CPRB_EMPR_DET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODATIVCPRB_ID  IN (SELECT ID FROM M$COD_ATIV_CPRB)
                   AND APURCPRBEMPR_ID IN (SELECT ID FROM M$APUR_CPRB_EMPR)
                   AND PLANOCONTA_ID   IN (SELECT ID FROM M$PLANO_CONTA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA AJUST_APUR_CPRB_EMPR_DET ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJUST_APUR_CPRB_EMPR_DET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURCPRBEMPRDET_ID IN (SELECT ID FROM M$APUR_CPRB_EMPR_DET)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA NF_APUR_CPRB_EMPR_DET ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NF_APUR_CPRB_EMPR_DET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURCPRBEMPRDET_ID   IN (SELECT ID FROM M$APUR_CPRB_EMPR_DET)
                   AND NOTAFISCAL_ID        IN (SELECT ID FROM M$NOTA_FISCAL)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA INF_PROC_ADM_APUR_CPRB ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_PROC_ADM_APUR_CPRB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURCPRBEMPRDET_ID        IN (SELECT ID FROM M$APUR_CPRB_EMPR_DET)
                   AND PROCADMEFDREINFINFTRIB_ID IN (SELECT ID FROM M$PROC_ADM_EFD_REINF_INF_TRIB)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA PARAM_EFD_CONTR ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_EFD_CONTR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA EFD_REINF_EVT_PENDENTE ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EFD_REINF_EVT_PENDENTE';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- FIM REINF -----------------------------------------------------------------------------------------------------------------------------------
   --
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------ TABELAS FCI ---------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --
   -- TABELA PARAM_ABERT_FCI ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_ABERT_FCI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA REGISTRO_FCI ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REGISTRO_FCI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA ABERTURA_FCI ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_FCI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INI,''MM'') >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                   AND TRUNC(DT_FIN,''MM'') <= to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA ABERTURA_FCI_ARQ ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_FCI_ARQ';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAFCI_ID IN (SELECT ID FROM M$ABERTURA_FCI)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA R_LOTEINTWS_ABERTFCI ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_LOTEINTWS_ABERTFCI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAFCI_ID IN (SELECT ID FROM M$ABERTURA_FCI)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA INF_ITEM_FCI ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_ITEM_FCI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAFCIARQ_ID IN (SELECT ID FROM M$ABERTURA_FCI_ARQ)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- TABELA RETORNO_FCI ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'RETORNO_FCI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE INFITEMFCI_ID IN (SELECT ID FROM M$INF_ITEM_FCI)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA MEM_CALC_FCI ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'MEM_CALC_FCI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE INFITEMFCI_ID IN (SELECT ID FROM M$INF_ITEM_FCI)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA MCFCI_ITEMNF ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'MCFCI_ITEMNF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MEMCALCFCI_ID IN (SELECT ID FROM M$MEM_CALC_FCI)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --     
   -- TABELA MEM_CALC_IIFCI ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'MEM_CALC_IIFCI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE INFITEMFCI_ID IN (SELECT ID FROM M$INF_ITEM_FCI)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --    
   -- FIM FCI ----------------------------------------------------------------------------------------------------------------------------------------
   --   
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   ---------------------------------------------------- SPED CONTRIBUIÇÕES (PIS/COFINS) ---------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --
   -- TABELA REGISTR_EFD_PC ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REGISTR_EFD_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||
                 '';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA ABERTURA_EFD_PC_OIFD ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_EFD_PC_OIFD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND DT_INICIAL >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA ABERT_EFD_PC_OIFD_ESTAB ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERT_EFD_PC_OIFD_ESTAB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND ABERTURAEFDPCOIFD_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC_OIFD)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA ABERTURA_EFD_PC ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_EFD_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND VERSAOLAYOUTEFDPC_ID IN (SELECT ID FROM M$VERSAO_LAYOUT_EFD_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA ABERTURA_EFD_COMP_REC_PER ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_EFD_COMP_REC_PER';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAEFDPC_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end;   
   --     
   -- TABELA ABERTURA_EFD_PC_CPRB ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_EFD_PC_CPRB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAEFDPC_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA ABERTURA_EFD_PC_PER_DISP ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_EFD_PC_PER_DISP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAEFDPC_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA ABERTURA_EFD_PC_RECEITA ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_EFD_PC_RECEITA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAEFDPC_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA ABERTURA_EFD_PC_REGIME ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_EFD_PC_REGIME';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAEFDPC_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA ABERTURA_EFD_PC_SCP ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_EFD_PC_SCP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAEFDPC_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --  
   -- TABELA ESTR_ARQ_EFD_PC ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ESTR_ARQ_EFD_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAEFDPC_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   -- 
   -- TABELA PER_APUR_CRED_PIS ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_APUR_CRED_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND DT_INI >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA APUR_CRED_PIS ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CRED_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PERAPURCREDPIS_ID IN (SELECT ID FROM M$PER_APUR_CRED_PIS)
                   AND TIPOCREDPC_ID IN (SELECT ID FROM M$TIPO_CRED_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA AJUST_APUR_CRED_PIS ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJUST_APUR_CRED_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURCREDPIS_ID IN (SELECT ID FROM M$APUR_CRED_PIS)
                   AND AJUSTCONTRPC_ID IN (SELECT ID FROM M$AJUST_CONTR_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA PER_CONS_CONTR_PIS ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_CONS_CONTR_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND DT_INI >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA CONS_CONTR_PIS ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONS_CONTR_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PERCONSCONTRPIS_ID IN (SELECT ID FROM M$PER_CONS_CONTR_PIS)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA DET_CONS_CONTR_PIS ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_CONS_CONTR_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONSCONTRPIS_ID IN (SELECT ID FROM M$CONS_CONTR_PIS)
                   AND CONTRSOCAPURPC_ID IN (SELECT ID FROM M$CONTR_SOC_APUR_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA SOC_COOP_COMP_BC_CALC_PIS ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'SOC_COOP_COMP_BC_CALC_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE DETCONSCONTRPIS_ID IN (SELECT ID FROM M$DET_CONS_CONTR_PIS)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --   
   -- TABELA AJUST_BC_CONT_PIS ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJUST_BC_CONT_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE DETCONSCONTRPIS_ID IN (SELECT ID FROM M$DET_CONS_CONTR_PIS)
                   AND CODAJBCCONTR_ID IN (SELECT ID FROM M$COD_AJ_BC_CONTR)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA AJUST_CONTR_PIS_APUR ----------------------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJUST_CONTR_PIS_APUR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE DETCONSCONTRPIS_ID IN (SELECT ID FROM M$DET_CONS_CONTR_PIS)
                   AND AJUSTCONTRPC_ID IN (SELECT ID FROM M$AJUST_CONTR_PC)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA CTRL_VERSAO_CONTABIL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CTRL_VERSAO_CONTABIL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND DT_INI >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CENTRO_CUSTO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CENTRO_CUSTO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND CTRLVERSAOCONTABIL_ID IN (SELECT ID FROM M$CTRL_VERSAO_CONTABIL)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA BEM_ATIV_IMOB_OPER_CRED_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'BEM_ATIV_IMOB_OPER_CRED_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE BASECALCCREDPC_ID IN (SELECT ID FROM M$BASE_CALC_CRED_PC)
                   AND CODST_ID_PIS IN (SELECT ID FROM M$COD_ST)
                   AND CODST_ID_COFINS IN (SELECT ID FROM M$COD_ST)
                   AND EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONSOL_OPER_PER_OIFD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONSOL_OPER_PER_OIFD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTEFDPCOIFDESTAB_ID IN (SELECT ID FROM M$ABERT_EFD_PC_OIFD_ESTAB)
                   AND CODST_ID_PIS_COFINS IN (SELECT ID FROM M$COD_ST)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA COMPOS_RECDEDEXCL_OIFD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COMPOS_RECDEDEXCL_OIFD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODCOMPOSDETOIFD_ID IN (SELECT ID FROM M$COD_COMPOS_DET_OIFD)
                   AND CONSOLOPERPEROIFD_ID IN (SELECT ID FROM M$CONSOL_OPER_PER_OIFD)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONS_CONTR_PIS_OR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONS_CONTR_PIS_OR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE TIPORETIMPRECEITA_ID IN (SELECT ID FROM M$TIPO_RET_IMP_RECEITA)
                   AND CONSCONTRPIS_ID IN (SELECT ID FROM M$CONS_CONTR_PIS)
                   AND TIPORETIMP_ID IN (SELECT ID FROM M$TIPO_RET_IMP)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONS_OPER_INS_PC_RC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONS_OPER_INS_PC_RC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
                   AND CFOP_ID IN (SELECT ID FROM M$CFOP)
                   AND CODST_ID_PIS IN (SELECT ID FROM M$COD_ST)
                   AND EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND MODFISCAL_ID IN (SELECT ID FROM M$MOD_FISCAL)
                   AND CODST_ID_COFINS IN (SELECT ID FROM M$COD_ST)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONS_OPER_INS_PC_RCOMP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONS_OPER_INS_PC_RCOMP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CFOP_ID IN (SELECT ID FROM M$CFOP)
                   AND CODST_ID_PIS IN (SELECT ID FROM M$COD_ST)
                   AND EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND CODST_ID_COFINS IN (SELECT ID FROM M$COD_ST)
                   AND MODFISCAL_ID IN (SELECT ID FROM M$MOD_FISCAL)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONTR_CRED_FISCAL_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_CRED_FISCAL_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA APUR_CRED_EXT_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CRED_EXT_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE BASECALCCREDPC_ID IN (SELECT ID FROM M$BASE_CALC_CRED_PC)
                   AND CONTRCREDFISCALPIS_ID IN (SELECT ID FROM M$CONTR_CRED_FISCAL_PIS)
                   AND CENTROCUSTO_ID IN (SELECT ID FROM M$CENTRO_CUSTO)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND ITEMNF_ID IN (SELECT ID FROM M$ITEM_NOTA_FISCAL)
                   AND NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONTR_PIS_DIF_PER_ANT -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_PIS_DIF_PER_ANT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND CONTRSOCAPURPC_ID IN (SELECT ID FROM M$CONTR_SOC_APUR_PC)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA R_APURCREDPIS_CONTRCREDFPIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_APURCREDPIS_CONTRCREDFPIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURCREDPIS_ID IN (SELECT ID FROM M$APUR_CRED_PIS)
                   AND CONTRCREDFISCALPIS_ID IN (SELECT ID FROM M$CONTR_CRED_FISCAL_PIS)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA RELAC_APUR_CONTR_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'RELAC_APUR_CONTR_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONTRCREDFISCALPIS_ID IN (SELECT ID FROM M$CONTR_CRED_FISCAL_PIS)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --    
   -- TABELA IMP_RET_REC_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IMP_RET_REC_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND PESSOA_ID IN (SELECT ID FROM M$PESSOA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA GERA_CONTR_RET_FONTE_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'GERA_CONTR_RET_FONTE_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND DT_INI >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONTR_RET_FONTE_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_RET_FONTE_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONTRRETFONTE_IMPRETREC_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTRRETFONTE_IMPRETREC_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONTRRETFONTEPC_ID IN (SELECT ID FROM M$CONTR_RET_FONTE_PC)
                   AND GERACONTRRETFONTEPC_ID IN (SELECT ID FROM M$GERA_CONTR_RET_FONTE_PC)
                   AND IMPRETRECPC_ID IN (SELECT ID FROM M$IMP_RET_REC_PC)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONTR_VLR_RET_FONTE_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_VLR_RET_FONTE_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CRED_DECOR_EVENTO_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CRED_DECOR_EVENTO_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TIPOCREDPC_ID IN (SELECT ID FROM M$TIPO_CRED_PC)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CRED_PRES_EST_ABERT_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CRED_PRES_EST_ABERT_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE BASECALCCREDPC_ID IN (SELECT ID FROM M$BASE_CALC_CRED_PC)
                   AND CODST_ID_PIS IN (SELECT ID FROM M$COD_ST)
                   AND CODST_ID_COFINS IN (SELECT ID FROM M$COD_ST)
                   AND EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA OBS_LANCTO_FISCAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OBS_LANCTO_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CT_REG_ANAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CT_REG_ANAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CFOP_ID IN (SELECT ID FROM M$CFOP)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND OBSLANCTOFISCAL_ID IN (SELECT ID FROM M$OBS_LANCTO_FISCAL)
                   AND CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CUPOM_FISCAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CUPOM_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND MODFISCAL_ID IN (SELECT ID FROM M$MOD_FISCAL)
                   AND SITDOCTO_ID IN (SELECT ID FROM M$SIT_DOCTO)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA ITEM_CUPOM_FISCAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_CUPOM_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CFOP_ID IN (SELECT ID FROM M$CFOP)
                   AND CODTRIBMUNICIPIO_ID IN (SELECT ID FROM M$COD_TRIB_MUNICIPIO)
                   AND CUPOMFISCAL_ID IN (SELECT ID FROM M$CUPOM_FISCAL)
                   AND ITEM_ID IN (SELECT ID FROM M$ITEM)
                   AND NATOPER_ID IN (SELECT ID FROM M$NAT_OPER)
                   AND NCM_ID IN (SELECT ID FROM M$NCM)
                   AND UNIDADE_ID IN (SELECT ID FROM M$UNIDADE)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA IMP_ITEMCF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IMP_ITEMCF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND ITEMCUPOMFISCAL_ID IN (SELECT ID FROM M$ITEM_CUPOM_FISCAL)
                   AND TIPOIMP_ID IN (SELECT ID FROM M$TIPO_IMPOSTO)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA DEDUCAO_DIVERSA_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DEDUCAO_DIVERSA_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA DEM_DOC_OPER_GER_CC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DEM_DOC_OPER_GER_CC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE BASECALCCREDPC_ID IN (SELECT ID FROM M$BASE_CALC_CRED_PC)
                   AND CENTROCUSTO_ID IN (SELECT ID FROM M$CENTRO_CUSTO)
                   AND CODST_ID_PIS IN (SELECT ID FROM M$COD_ST)
                   AND CODST_ID_COFINS IN (SELECT ID FROM M$COD_ST)
                   AND EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND ITEM_ID IN (SELECT ID FROM M$ITEM)
                   AND PESSOA_ID IN (SELECT ID FROM M$PESSOA)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA DET_AJUST_APUR_CRED_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_AJUST_APUR_CRED_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND AJUSTAPURCREDPIS_ID IN (SELECT ID FROM M$AJUST_APUR_CRED_PIS)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA DET_AJUST_CONTR_PIS_APUR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_AJUST_CONTR_PIS_APUR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE AJUSTCONTRPISAPUR_ID IN (SELECT ID FROM M$AJUST_CONTR_PIS_APUR)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA DET_APUR_CRED_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_APUR_CRED_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURCREDPIS_ID IN (SELECT ID FROM M$APUR_CRED_PIS)
                   AND BASECALCCREDPC_ID IN (SELECT ID FROM M$BASE_CALC_CRED_PC)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA PER_REC_ISENTA_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_REC_ISENTA_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND DT_INI >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA REC_ISENTA_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REC_ISENTA_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PERRECISENTAPIS_ID IN (SELECT ID FROM M$PER_REC_ISENTA_PIS)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NAT_REC_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NAT_REC_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
                   AND PRODDACON_ID IN (SELECT ID FROM M$PROD_DACON)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NCM_NAT_REC_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NCM_NAT_REC_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EXTIPI_ID IN (SELECT ID FROM M$EX_TIPI)
                   AND NATRECPC_ID IN (SELECT ID FROM M$NAT_REC_PC)
                   AND NCM_ID IN (SELECT ID FROM M$NCM)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA PLANO_CONTA_NAT_REC_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NCM_NAT_REC_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NATRECPC_ID IN (SELECT ID FROM M$NAT_REC_PC)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --      
   -- TABELA DET_REC_ISENTA_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_REC_ISENTA_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NATRECPC_ID IN (SELECT ID FROM M$NAT_REC_PC)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
                   AND RECISENTAPIS_ID IN (SELECT ID FROM M$REC_ISENTA_PIS)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------ ECF -----------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --
   -- TABELA VERSAO_LAYOUT_ECF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'VERSAO_LAYOUT_ECF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name;
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA ABERTURA_ECF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_ECF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND VERSAOLAYOUTECF_ID IN (SELECT ID FROM M$VERSAO_LAYOUT_ECF)
                   AND TRUNC(DT_INI,''MM'') >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                   AND TRUNC(DT_FIN,''MM'') <= to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA APUR_IRPJ_CSLL_PARCIAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_IRPJ_CSLL_PARCIAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECF_ID IN (SELECT ID FROM M$ABERTURA_ECF)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA REL_APUR_IRPJ_CSLL_PARCIAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REL_APUR_IRPJ_CSLL_PARCIAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURIRPJCSLLPARCIAL_ID IN (SELECT ID FROM M$APUR_IRPJ_CSLL_PARCIAL)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA PER_APUR_LR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_APUR_LR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECF_ID IN (SELECT ID FROM M$ABERTURA_ECF)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA TAB_DIN_ECF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'TAB_DIN_ECF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE REGISTROECF_ID IN (SELECT ID FROM M$REGISTRO_ECF)
                   AND (
                    (TRUNC(DT_FIN,''MM'') >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy''))
                    OR DT_FIN IS NULL)  
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  
   -- TABELA LANC_PART_A_LALUR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LANC_PART_A_LALUR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PERAPURLR_ID IN (SELECT ID FROM M$PER_APUR_LR)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA LANC_PART_A_LACS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LANC_PART_A_LACS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PERAPURLR_ID IN (SELECT ID FROM M$PER_APUR_LR)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   -- 
   -- TABELA EQUIP_ECF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EQUIP_ECF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND MODFISCAL_ID IN (SELECT ID FROM M$MOD_FISCAL)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA REDUCAO_Z_ECF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REDUCAO_Z_ECF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EQUIPECF_ID IN (SELECT ID FROM M$EQUIP_ECF)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA RES_DIA_DOC_ECF_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'RES_DIA_DOC_ECF_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND ITEM_ID IN (SELECT ID FROM M$ITEM)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
                   AND REDUCAOZECF_ID IN (SELECT ID FROM M$REDUCAO_Z_ECF)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA DOC_FISCAL_EMIT_ECF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DOC_FISCAL_EMIT_ECF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MODFISCAL_ID IN (SELECT ID FROM M$MOD_FISCAL)
                   AND REDUCAOZECF_ID IN (SELECT ID FROM M$REDUCAO_Z_ECF)
                   AND SITDOCTO_ID IN (SELECT ID FROM M$SIT_DOCTO)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA INF_ADIC_DIF_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_ADIC_DIF_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE DETCONSCONTRPIS_ID IN (SELECT ID FROM M$DET_CONS_CONTR_PIS)
                   AND TIPOCREDPC_ID IN (SELECT ID FROM M$TIPO_CRED_PC)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA INF_PIS_FOLHA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_PIS_FOLHA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND DT_INI >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'') 
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA IT_DOC_FISCAL_EMIT_ECF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IT_DOC_FISCAL_EMIT_ECF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE DOCFISCALEMITECF_ID IN (SELECT ID FROM M$DOC_FISCAL_EMIT_ECF)
                   AND CFOP_ID IN (SELECT ID FROM M$CFOP)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND ITEM_ID IN (SELECT ID FROM M$ITEM)
                   AND UNIDADE_ID IN (SELECT ID FROM M$UNIDADE)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA RES_DIA_NF_VENDA_CONS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'RES_DIA_NF_VENDA_CONS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND MODFISCAL_ID IN (SELECT ID FROM M$MOD_FISCAL)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA REG_AN_RES_DIA_NF_VENDA_CONS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REG_AN_RES_DIA_NF_VENDA_CONS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CFOP_ID IN (SELECT ID FROM M$CFOP)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND OBSLANCTOFISCAL_ID IN (SELECT ID FROM M$OBS_LANCTO_FISCAL)
                   AND RESDIANFVENDACONS_ID IN (SELECT ID FROM M$RES_DIA_NF_VENDA_CONS)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA IT_RES_DIA_NF_VENDA_CONS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'IT_RES_DIA_NF_VENDA_CONS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEM_ID IN (SELECT ID FROM M$ITEM)
                   AND REGANRESDIANFVENDACONS_ID IN (SELECT ID FROM M$REG_AN_RES_DIA_NF_VENDA_CONS)
                   AND UNIDADE_ID IN (SELECT ID FROM M$UNIDADE)
                   AND CODST_ID_COFINS IN (SELECT ID FROM M$COD_ST)
                   AND CODST_ID_PIS IN (SELECT ID FROM M$COD_ST)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NF_COMPL_OPER_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NF_COMPL_OPER_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE BASECALCCREDPC_ID IN (SELECT ID FROM M$BASE_CALC_CRED_PC)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)
                   AND PLANOCONTA_ID IN (SELECT ID FROM M$PLANO_CONTA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA NFREGIST_ANALIT -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NFREGIST_ANALIT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CFOP_ID IN (SELECT ID FROM M$CFOP)
                   AND CODST_ID IN (SELECT ID FROM M$COD_ST)
                   AND NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)
                   AND OBSLANCTOFISCAL_ID IN (SELECT ID FROM M$OBS_LANCTO_FISCAL)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA OPER_GER_CRED_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OPER_GER_CRED_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE BASECALCCREDPC_ID IN (SELECT ID FROM M$BASE_CALC_CRED_PC)
                   AND CFOP_ID IN (SELECT ID FROM M$CFOP)
                   AND EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
               ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA ACAO_JUDIC_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ACAO_JUDIC_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA AJUST_APUR_CPRB -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJUST_APUR_CPRB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE AJUSTCONTRPC_ID IN (SELECT ID FROM M$AJUST_CONTR_PC)
                   AND APURACAOCPRB_ID IN (SELECT ID FROM M$APURACAO_CPRB)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
   end; 
   --
   -- TABELA PER_CONS_CONTR_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_CONS_CONTR_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA CONS_CONTR_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONS_CONTR_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE PERCONSCONTRCOFINS_ID IN (SELECT ID FROM M$PER_CONS_CONTR_COFINS)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA DET_CONS_CONTR_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_CONS_CONTR_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONSCONTRCOFINS_ID IN (SELECT ID FROM M$CONS_CONTR_COFINS)
                   AND CONTRSOCAPURPC_ID  IN (SELECT ID FROM M$CONTR_SOC_APUR_PC)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA AJUST_BC_CONT_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJUST_BC_CONT_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE DETCONSCONTRCOFINS_ID IN (SELECT ID FROM M$DET_CONS_CONTR_COFINS)
                   AND CODAJBCCONTR_ID  IN (SELECT ID FROM M$COD_AJ_BC_CONTR)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA AJUST_CONTR_COFINS_APUR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJUST_CONTR_COFINS_APUR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE AJUSTCONTRPC_ID       IN (SELECT ID FROM M$AJUST_CONTR_PC)
                   AND DETCONSCONTRCOFINS_ID IN (SELECT ID FROM M$DET_CONS_CONTR_COFINS)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA APUR_CPRB_ESTAB -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CPRB_ESTAB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURACAOCPRB_ID IN (SELECT ID FROM M$APURACAO_CPRB)
                   AND CODATIVCPRB_ID  IN (SELECT ID FROM M$COD_ATIV_CPRB)
                   AND EMPRESA_ID      IN (SELECT ID FROM M$EMPRESA)
                   ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA APUR_CPRB_ESTAB_DET -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CPRB_ESTAB_DET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURCPRBESTAB_ID IN (SELECT ID FROM M$APUR_CPRB_ESTAB)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA APUR_CPRB_ESTAB_PROC_REF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CPRB_ESTAB_PROC_REF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ORIGPROC_ID      IN (SELECT ID FROM M$ORIG_PROC)
                   AND APURCPRBESTAB_ID IN (SELECT ID FROM M$APUR_CPRB_ESTAB)
                 ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA PER_APUR_CRED_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_APUR_CRED_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA APUR_CRED_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CRED_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE TIPOCREDPC_ID IN (SELECT ID FROM M$TIPO_CRED_PC)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA CONTR_CRED_FISCAL_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_CRED_FISCAL_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID    IN (SELECT ID FROM M$EMPRESA)
                   AND TIPOCREDPC_ID IN (SELECT ID FROM M$TIPO_CRED_PC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA APUR_CRED_EXT_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_CRED_EXT_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONTRCREDFISCALCOFINS_ID IN (SELECT ID FROM M$CONTR_CRED_FISCAL_COFINS)
                   AND CFOP_ID                  IN (SELECT ID FROM M$CFOP)
                   AND BASECALCCREDPC_ID        IN (SELECT ID FROM M$BASE_CALC_CRED_PC)
                   AND CODST_ID                 IN (SELECT ID FROM M$COD_ST)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA COD_COMPL_OPER_OIFD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COD_COMPL_OPER_OIFD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODCOMPOSDETOIFD_ID IN (SELECT ID FROM M$COD_COMPOS_DET_OIFD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA COMPL_DETAL_OPER_OIFD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COMPL_DETAL_OPER_OIFD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE COMPOSRECDEDEXCLOIFD_ID IN (SELECT ID FROM M$COMPOS_RECDEDEXCL_OIFD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA COMPL_PROC_REF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COMPL_PROC_REF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE COMPLDETALOPEROIFD_ID IN (SELECT ID FROM M$COMPL_DETAL_OPER_OIFD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA COMPOS_PROC_REF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COMPOS_PROC_REF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE COMPOSRECDEDEXCLOIFD_ID IN (SELECT ID FROM M$COMPOS_RECDEDEXCL_OIFD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA COMP_REC_DET_RC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'COMP_REC_DET_RC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA CONS_CONTR_COFINS_OR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONS_CONTR_COFINS_OR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE TIPORETIMPRECEITA_ID IN (SELECT ID FROM M$TIPO_RET_IMP_RECEITA)
                   AND CONSCONTRCOFINS_ID   IN (SELECT ID FROM M$CONS_CONTR_COFINS)
                   AND TIPORETIMP_ID        IN (SELECT ID FROM M$TIPO_RET_IMP)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA CONS_DOCTO_EMIT_PER -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONS_DOCTO_EMIT_PER';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID   IN (SELECT ID FROM M$EMPRESA)
                   AND MODFISCAL_ID IN (SELECT ID FROM M$MOD_FISCAL)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA CONSOL_PROC_REF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONSOL_PROC_REF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONSOLOPERPEROIFD_ID IN (SELECT ID FROM M$CONSOL_OPER_PER_OIFD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA CONS_OPER_INS_PC_RC_AUM -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONS_OPER_INS_PC_RC_AUM';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID      IN (SELECT ID FROM M$EMPRESA)
                   AND CODST_ID_PIS    IN (SELECT ID FROM M$COD_ST)
                   AND CODST_ID_COFINS IN (SELECT ID FROM M$COD_ST)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA CONS_OP_INS_PCRCOMP_AUM -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONS_OP_INS_PCRCOMP_AUM';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID      IN (SELECT ID FROM M$EMPRESA)
                   AND CODST_ID_PIS    IN (SELECT ID FROM M$COD_ST)
                   AND CODST_ID_COFINS IN (SELECT ID FROM M$COD_ST)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA CONTR_COFINS_DIF_PER_ANT -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_COFINS_DIF_PER_ANT';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID        IN (SELECT ID FROM M$EMPRESA)
                   AND CONTRSOCAPURPC_ID IN (SELECT ID FROM M$CONTR_SOC_APUR_PC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA CONTR_SOC_EXT_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_SOC_EXT_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID        IN (SELECT ID FROM M$EMPRESA)
                   AND CONTRSOCAPURPC_ID IN (SELECT ID FROM M$CONTR_SOC_APUR_PC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA CONTR_SOC_EXT_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_SOC_EXT_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID        IN (SELECT ID FROM M$EMPRESA)
                   AND CONTRSOCAPURPC_ID IN (SELECT ID FROM M$CONTR_SOC_APUR_PC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA CONTR_VLR_RET_FONTE_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONTR_VLR_RET_FONTE_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID  IN (SELECT ID FROM M$EMPRESA)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA CT_PROC_REF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CT_PROC_REF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONHECTRANSP_ID IN (SELECT ID FROM M$CONHEC_TRANSP)
                   AND ORIGPROC_ID     IN (SELECT ID FROM M$ORIG_PROC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DEM_CRED_DESC_CONTR_EXT_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DEM_CRED_DESC_CONTR_EXT_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONTRSOCEXTCOFINS_ID IN (SELECT ID FROM M$CONTR_SOC_EXT_COFINS)
                   AND TIPOCREDPC_ID        IN (SELECT ID FROM M$TIPO_CRED_PC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DEM_CRED_DESC_CONTR_EXT_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DEM_CRED_DESC_CONTR_EXT_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONTRSOCEXTPIS_ID IN (SELECT ID FROM M$CONTR_SOC_EXT_PIS)
                   AND TIPOCREDPC_ID        IN (SELECT ID FROM M$TIPO_CRED_PC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DET_AJUS_BC_EXTRA_APUR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_AJUS_BC_EXTRA_APUR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID      IN (SELECT ID FROM M$EMPRESA)
                   AND CODAJBCCONTR_ID IN (SELECT ID FROM M$COD_AJ_BC_CONTR)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DET_AJUST_CONTR_COFINS_APUR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_AJUST_CONTR_COFINS_APUR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE AJUSTCONTRCOFINSAPUR_ID IN (SELECT ID FROM M$AJUST_CONTR_COFINS_APUR)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DET_APUR_CRED_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_APUR_CRED_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE APURCREDCOFINS_ID IN (SELECT ID FROM M$APUR_CRED_COFINS)
                   AND BASECALCCREDPC_ID IN (SELECT ID FROM M$BASE_CALC_CRED_PC)
                   AND CODST_ID          IN (SELECT ID FROM M$COD_ST)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DET_CONTR_SOC_EXT_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_CONTR_SOC_EXT_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONTRSOCEXTCOFINS_ID IN (SELECT ID FROM M$CONTR_SOC_EXT_COFINS)
                   AND EMPRESA_ID           IN (SELECT ID FROM M$EMPRESA)
                   AND CODST_ID             IN (SELECT ID FROM M$COD_ST)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PER_REC_ISENTA_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_REC_ISENTA_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INI,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA REC_ISENTA_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REC_ISENTA_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODST_ID IN (SELECT ID FROM M$COD_ST)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DET_REC_ISENTA_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_REC_ISENTA_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RECISENTACOFINS_ID IN (SELECT ID FROM M$REC_ISENTA_COFINS)
                   AND NATRECPC_ID        IN (SELECT ID FROM M$NAT_REC_PC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA EQUIP_ECF_PROC_REF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EQUIP_ECF_PROC_REF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EQUIPECF_ID IN (SELECT ID FROM M$EQUIP_ECF)
                   AND ORIGPROC_ID IN (SELECT ID FROM M$ORIG_PROC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA INCORP_IMOB_RET -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INCORP_IMOB_RET';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA INCORP_IMOB_PROC_REF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INCORP_IMOB_PROC_REF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE INCORPIMOBRET_ID IN (SELECT ID FROM M$INCORP_IMOB_RET)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA INF_ADIC_DIF_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INF_ADIC_DIF_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE DETCONSCONTRCOFINS_ID IN (SELECT ID FROM M$DET_CONS_CONTR_COFINS)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA INFOR_COMP_DCTO_FISCAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INFOR_COMP_DCTO_FISCAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE MULTORG_ID IN (SELECT ID FROM M$MULT_ORG)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA INUTILIZA_CONHEC_TRANSP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INUTILIZA_CONHEC_TRANSP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID   IN (SELECT ID FROM M$EMPRESA)
                   AND MODFISCAL_ID IN (SELECT ID FROM M$MOD_FISCAL)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA ITEM_ANP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_ANP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEM_ID   IN (SELECT ID FROM M$ITEM)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA ITEM_MARCA_COMERC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEM_MARCA_COMERC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEM_ID   IN (SELECT ID FROM M$ITEM)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA ITEMNF_DEC_IMPOR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEMNF_DEC_IMPOR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEMNF_ID   IN (SELECT ID FROM M$ITEM_NOTA_FISCAL)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA ITEMNFDI_ADIC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ITEMNFDI_ADIC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ITEMNFDI_ID   IN (SELECT ID FROM M$ITEMNF_DEC_IMPOR)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA NF_COMPL_OPER_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'NF_COMPL_OPER_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE NOTAFISCAL_ID IN (SELECT ID FROM M$NOTA_FISCAL)
                   AND CODST_ID      IN (SELECT ID FROM M$COD_ST)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PLANO_CONTA_REF_ECD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PLANO_CONTA_REF_ECD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODENTREF_ID IN (SELECT ID FROM M$COD_ENT_REF)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PC_REFEREN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PC_REFEREN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CODENTREF_ID         IN (SELECT ID FROM M$COD_ENT_REF)
                   AND PLANOCONTA_ID        IN (SELECT ID FROM M$PLANO_CONTA)
                   AND PLANOCONTAREFECD_ID  IN (SELECT ID FROM M$PLANO_CONTA_REF_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PER_REC_ISENTA_PIS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_REC_ISENTA_PIS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID         IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INI,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PESSOA_RELAC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PESSOA_RELAC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID   IN (SELECT ID FROM M$EMPRESA)
                   AND PESSOA_ID    IN (SELECT ID FROM M$PESSOA)
                   AND RELACPART_ID IN (SELECT ID FROM M$RELAC_PART)
                   AND TRUNC(DT_INI_REL,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                    AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PR_BAI_OPER_CRED_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PR_BAI_OPER_CRED_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE BEMATIVIMOBOPERCREDPC_ID IN (SELECT ID FROM M$BEM_ATIV_IMOB_OPER_CRED_PC)
                   AND ORIGPROC_ID              IN (SELECT ID FROM M$ORIG_PROC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PR_CONS_OPER_INS_PC_RC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PR_CONS_OPER_INS_PC_RC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONSOPERINSPCRC_ID IN (SELECT ID FROM M$CONS_OPER_INS_PC_RC)
                   AND ORIGPROC_ID        IN (SELECT ID FROM M$ORIG_PROC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PR_CONS_OP_INS_PCRC_AUM -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PR_CONS_OP_INS_PCRC_AUM';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONSOPERINSPCRCAUM_ID IN (SELECT ID FROM M$CONS_OPER_INS_PC_RC_AUM)
                   AND ORIGPROC_ID           IN (SELECT ID FROM M$ORIG_PROC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PR_CONS_OP_INS_PC_RCOMP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PR_CONS_OP_INS_PC_RCOMP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONSOPERINSPCRCOMP_ID IN (SELECT ID FROM M$CONS_OPER_INS_PC_RCOMP)
                   AND ORIGPROC_ID           IN (SELECT ID FROM M$ORIG_PROC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PR_DEM_DOC_OPER_GER_CC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PR_DEM_DOC_OPER_GER_CC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE DEMDOCOPERGERCC_ID IN (SELECT ID FROM M$DEM_DOC_OPER_GER_CC)
                   AND ORIGPROC_ID        IN (SELECT ID FROM M$ORIG_PROC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA PROC_ADM_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PROC_ADM_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INI,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA R_CONTADOR_ABERTURA_EFD_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_CONTADOR_ABERTURA_EFD_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONTADOR_ID      IN (SELECT ID FROM M$CONTADOR)
                   AND ABERTURAEFDPC_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA REG_ANAL_MOV_DIA_ECF -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'REG_ANAL_MOV_DIA_ECF';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE REDUCAOZECF_ID IN (SELECT ID FROM M$REDUCAO_Z_ECF)
                   AND CODST_ID       IN (SELECT ID FROM M$COD_ST)
                   AND CFOP_ID        IN (SELECT ID FROM M$CFOP)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA RELAC_APUR_CONTR_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'RELAC_APUR_CONTR_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE CONTRCREDFISCALCOFINS_ID IN (SELECT ID FROM M$CONTR_CRED_FISCAL_COFINS)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA R_EMPRESA_ABERTURA_EFD_PC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'R_EMPRESA_ABERTURA_EFD_PC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID       IN (SELECT ID FROM M$EMPRESA)
                   AND ABERTURAEFDPC_ID IN (SELECT ID FROM M$ABERTURA_EFD_PC)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA RES_DIA_DOC_ECF_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'RES_DIA_DOC_ECF_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE REDUCAOZECF_ID IN (SELECT ID FROM M$REDUCAO_Z_ECF)
                   AND CODST_ID       IN (SELECT ID FROM M$COD_ST)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA RES_DIA_NF_VENDA_CONS_CANC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'RES_DIA_NF_VENDA_CONS_CANC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE RESDIANFVENDACONS_ID IN (SELECT ID FROM M$RES_DIA_NF_VENDA_CONS)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA SOC_COOP_COMP_BC_CALC_COFINS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'SOC_COOP_COMP_BC_CALC_COFINS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE DETCONSCONTRCOFINS_ID IN (SELECT ID FROM M$DET_CONS_CONTR_COFINS)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DET_CONTR_EXIG_SUSP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_CONTR_EXIG_SUSP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ACAOJUDICPC_ID    IN (SELECT ID FROM M$ACAO_JUDIC_PC)
                   AND CODST_ID_PIS      IN (SELECT ID FROM M$COD_ST)
                   AND CODST_ID_COFINS   IN (SELECT ID FROM M$COD_ST)
                   AND CODST_ID_PIS_SUSP IN (SELECT ID FROM M$COD_ST)
                   AND CODST_COFINS_SUSP IN (SELECT ID FROM M$COD_ST)                   
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- FIM SPED CONTRIBUIÇÕES --------------------------------------------------------------------------------------------------------------------------
   --   
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --------------------------------------------------------------- DECLAN -----------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --
   -- TABELA ABERTURA_DECLAN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_DECLAN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID      IN (SELECT ID FROM M$EMPRESA)
                   AND VERSAODECLAN_ID IN (SELECT ID FROM M$VERSAO_DECLAN)
                   AND ANO_REF         = to_number(to_char(to_date('''||vv_dt_ini||''',''dd/mm/yyyy''),''YYYY''))
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   --
   -- TABELA EMPR_CFOP_PARAM_DECLAN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'EMPR_CFOP_PARAM_DECLAN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND CFOP_ID    IN (SELECT ID FROM M$CFOP)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA AJUST_ABERT_DECLAN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJUST_ABERT_DECLAN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURADECLAN_ID IN (SELECT ID FROM M$ABERTURA_DECLAN)
                   AND CODAJDECLAN_ID    IN (SELECT ID FROM M$COD_AJ_DECLAN)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DIPAM_GIA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DIPAM_GIA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ESTADO_ID IN (SELECT ID FROM M$ESTADO)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA DISTR_ABERT_DECLAN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DISTR_ABERT_DECLAN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURADECLAN_ID IN (SELECT ID FROM M$ABERTURA_DECLAN)
                   AND CIDADE_ID         IN (SELECT ID FROM M$CIDADE)
                   AND DIPAMGIA_ID       IN (SELECT ID FROM M$DIPAM_GIA)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --
   end; 
   -- 
   -- TABELA RBM_ABERT_DECLAN -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'RBM_ABERT_DECLAN';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURADECLAN_ID IN (SELECT ID FROM M$ABERTURA_DECLAN)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --    
   -- TABELA PARAM_DIPAMGIA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_DIPAMGIA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND CFOP_ID    IN (SELECT ID FROM M$CFOP)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --    
   -- TABELA INVENTARIO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'INVENTARIO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND ITEM_ID    IN (SELECT ID FROM M$ITEM)
                   AND UNIDADE_ID IN (SELECT ID FROM M$UNIDADE)
                   AND TRUNC(DT_INVENTARIO,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                       AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --    
   -- TABELA PARAM_EFD_ICMS_IPI -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_EFD_ICMS_IPI';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --       
   -- TABELA PARAM_OPER_FISCAL_ENTR -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_OPER_FISCAL_ENTR';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID   IN (SELECT ID FROM M$EMPRESA)
                   AND CFOP_ID_ORIG IN (SELECT ID FROM M$CFOP)
                   AND CFOP_ID_DEST IN (SELECT ID FROM M$CFOP)   
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --       
   -- TABELA PARAM_CALC_BASE_ICMS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_CALC_BASE_ICMS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID   IN (SELECT ID FROM M$EMPRESA)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --          
   -- TABELA PARAM_CALC_BASE_ICMS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_CALC_BASE_ICMS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID   IN (SELECT ID FROM M$EMPRESA)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- FIM DECLAN --------------------------------------------------------------------------------------------------------------------------------------
   --
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   ----------------------------------------------------------------- ECD ------------------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --
   -- TABELA PARAM_CONTABIL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_CONTABIL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID   IN (SELECT ID FROM M$EMPRESA)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA ABERTURA_ECD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ABERTURA_ECD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE EMPRESA_ID   IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INI,''MM'') >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                   AND TRUNC(DT_FIM,''MM'') <= to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA BALANCETE_DIARIO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'BALANCETE_DIARIO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CAMPO_ADIC_ECD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CAMPO_ADIC_ECD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CAMPO_RAZAO_AUX -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CAMPO_RAZAO_AUX';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA CONGL_ECON_PER_ESCR_CTB -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'CONGL_ECON_PER_ESCR_CTB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA DEMON_CONTAB -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DEMON_CONTAB';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA DET_RAZAO_AUX -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'DET_RAZAO_AUX';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --   
   -- TABELA ENCERRA_ECD -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'ENCERRA_ECD';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA LCTO_CONTABIL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LCTO_CONTABIL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA LIVRO_AUX_DIARIO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'LIVRO_AUX_DIARIO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA PARAM_RAZAO_AUX -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_RAZAO_AUX';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --
   -- TABELA SALDO_CONTA_RES -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'SALDO_CONTA_RES';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'||vv_table_name||' AS 
                 SELECT * FROM  '||vv_table_name||'
                 WHERE ABERTURAECD_ID IN (SELECT ID FROM M$ABERTURA_ECD)
                ';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --    
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --------------------------------------------------------SPED FISCAL ICMS / IPI----------------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   --
   -- TABELA AJ_OBRIG_REC -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJ_OBRIG_REC';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE TIPOIMP_ID IN (SELECT ID FROM M$TIPO_IMPOSTO)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  
   -- TABELA AJ_OBRIG_REC_ESTADO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'AJ_OBRIG_REC_ESTADO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE TIPOIMP_ID IN (SELECT ID FROM M$TIPO_IMPOSTO)
                   AND ESTADO_ID  IN (SELECT ID FROM M$ESTADO)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --  
   -- TABELA APURACAO_ICMS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APURACAO_ICMS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INICIO,''MM'') >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                   AND TRUNC(DT_FIM,''MM'')    <= to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end; 
   --    
   -- TABELA OBRIG_REC_APUR_ICMS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OBRIG_REC_APUR_ICMS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE APURACAOICMS_ID IN (SELECT ID FROM M$APURACAO_ICMS)
                   AND AJOBRIGREC_ID   IN (SELECT ID FROM M$AJ_OBRIG_REC)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --
   -- TABELA PER_APUR_ICMS_ST -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_APUR_ICMS_ST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INICIO,''MM'') >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                   AND TRUNC(DT_FIM,''MM'')    <= to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --
   -- TABELA APURACAO_ICMS_ST -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APURACAO_ICMS_ST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE PERAPURICMSST_ID IN (SELECT ID FROM M$PER_APUR_ICMS_ST)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --
   -- TABELA OBRIG_REC_APUR_ICMS_ST -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OBRIG_REC_APUR_ICMS_ST';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE APURACAOICMSST_ID IN (SELECT ID FROM M$APURACAO_ICMS_ST)
                   AND AJOBRIGREC_ID     IN (SELECT ID FROM M$AJ_OBRIG_REC)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --
   -- TABELA SUBAPUR_ICMS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'SUBAPUR_ICMS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INI,''MM'') >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                   AND TRUNC(DT_FIM,''MM'') <= to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --
   -- TABELA OBRIG_REC_SUBAPUR_ICMS -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OBRIG_REC_SUBAPUR_ICMS';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE SUBAPURICMS_ID IN (SELECT ID FROM M$SUBAPUR_ICMS)
                   AND AJOBRIGREC_ID  IN (SELECT ID FROM M$AJ_OBRIG_REC)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --
   -- TABELA PER_APUR_ICMS_DIFAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PER_APUR_ICMS_DIFAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INICIO,''MM'') >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                   AND TRUNC(DT_FIM,''MM'')    <= to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --
   -- TABELA APUR_ICMS_DIFAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_ICMS_DIFAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE PERAPURICMSDIFAL_ID IN (SELECT ID FROM M$PER_APUR_ICMS_DIFAL)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --   
   -- TABELA OBR_REC_APUR_ICMS_DIFAL -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'OBR_REC_APUR_ICMS_DIFAL';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE APURICMSDIFAL_ID IN (SELECT ID FROM M$APUR_ICMS_DIFAL)
                   AND AJOBRIGREC_ID    IN (SELECT ID FROM M$AJ_OBRIG_REC)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --      
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   -------------------------------------------------------- GUIA DE PAGAMENTO DE IMPOSTO --------------------------------------------------------------
   ----------------------------------------------------------------------------------------------------------------------------------------------------
   -- TABELA GUIA_PGTO_IMP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'GUIA_PGTO_IMP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_REF,''MM'') BETWEEN to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                                                AND to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;   
   --
   -- TABELA PARAM_GUIA_PGTO -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_GUIA_PGTO';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --
   -- TABELA PARAM_DET_GUIA_IMP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'PARAM_DET_GUIA_IMP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE PARAMGUIAPGTO_ID IN (SELECT ID FROM M$PARAM_GUIA_PGTO)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;      
   --   
   -- TABELA GER_GUIA_PGTO_IMP -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'GER_GUIA_PGTO_IMP';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;
   --   
   -- TABELA APUR_ISS_SIMPLIFICADA -----------------------------------------------------------------------------------------------------------
   begin
      --
      vv_table_name := 'APUR_ISS_SIMPLIFICADA';
      --
      vv_sql := 'CREATE TABLE CSF_OWN.M$'|| vv_table_name ||' AS
                 SELECT * FROM ' || vv_table_name ||'
                 WHERE EMPRESA_ID IN (SELECT ID FROM M$EMPRESA)
                   AND TRUNC(DT_INICIO,''MM'') >= to_date('''||vv_dt_ini||''',''dd/mm/yyyy'')
                   AND TRUNC(DT_FIM,''MM'')    <= to_date('''||vv_dt_fim||''',''dd/mm/yyyy'')';
      --
      pb_cria_tabela(vv_table_name, vv_sql);
      --      
   end;      
   --   
   
   
   
   
END PB_GERA_CENARIO;
/
