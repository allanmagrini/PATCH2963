create or replace package body csf_own.pk_csf_int_bloco_nfs is

-------------------------------------------------------------------------------------------------------
-- Corpo do pacote de integração de Notas Fiscais de Serviço em bloco, baseado em views do ERP
-------------------------------------------------------------------------------------------------------

--| Procedimento de limpeza do array
procedure pkb_limpa_array
is
begin
   --
   vt_tab_csf_nfs.delete;
   vt_tab_csf_itemnf_compl_serv.delete;
   vt_tab_csf_imp_itemnf_serv.delete;
   vt_tab_csf_imp_itemnf_serv_ff.delete;
   vt_tab_csf_nfinfor_adic_serv.delete;
   vt_tab_csf_nf_dest_serv.delete;
   vt_tab_csf_nf_inter_serv.delete;
   vt_tab_csf_nfs_det_const_civil.delete;
   vt_tab_csf_nf_cobr_dup_serv.delete;
   vt_tab_csf_nf_canc_serv.delete;
   vt_tab_csf_nf_compl_serv.delete;
   vt_tab_csf_itnf_compl_serv_ff.delete;
   vt_tab_csf_nota_fiscal_serv_ff.delete;
   vt_tab_csf_nf_proc_reinf.delete;
   --
end pkb_limpa_array;

---------------------------------------------------------------------------------------------------------
--| Procedimento de leitura de Informações de Nota fiscal de Serviço
procedure pkb_ler_nfs
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NOTA_FISCAL_SERV'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUBSERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_EMISS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_EXE_SERV' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_SAI_ENT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SIT_DOCTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CHV_NFSE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_PAG' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_NAT_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO_RPS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_STATUS_RPS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_RPS_SUBST' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE_RPS_SUBST' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_ST_PROC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SIST_ORIG' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'UNID_ORG' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_SERV' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nfs;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nfs.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nfs.first..vt_tab_csf_nfs.last loop
         --
         if trim(vt_tab_csf_nfs(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nfs(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nfs(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nfs(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nfs(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nfs(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nfs(i).SERIE) is null then
            vt_tab_csf_nfs(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nfs(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nfs(i).NRO_NF := 0;
         end if;
         --
         if trim(vt_tab_csf_nfs(i).DT_EMISS) is null then
            vt_tab_csf_nfs(i).DT_EMISS := trunc(sysdate);
         end if;
         --
         if trim(vt_tab_csf_nfs(i).SIT_DOCTO) is null then
            vt_tab_csf_nfs(i).SIT_DOCTO := '-1';
         end if;
         --
         if nvl(vt_tab_csf_nfs(i).DM_IND_PAG, -1) < 0 then
            vt_tab_csf_nfs(i).DM_IND_PAG := -1;
         end if;
         --
         if nvl(vt_tab_csf_nfs(i).DM_NAT_OPER, -1) < 0 then
            vt_tab_csf_nfs(i).DM_NAT_OPER := -1;
         end if;
         --
         if nvl(vt_tab_csf_nfs(i).DM_ST_PROC, -1) < 0 then
            vt_tab_csf_nfs(i).DM_ST_PROC := -1;
         end if;
         --
         vt_tab_csf_nfs(i).COD_PART  := trim(vt_tab_csf_nfs(i).COD_PART);
         vt_tab_csf_nfs(i).SERIE     := trim(vt_tab_csf_nfs(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nfs.count
         insert into VW_CSF_NOTA_FISCAL_SERV values vt_tab_csf_nfs(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nfs;

---------------------------------------------------------------------------------------------------------
--| Procedimento de leitura de Informações de Nota fiscal de Serviço - Campos flex-field

procedure pkb_ler_nfs_ff
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_SERV_FF') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NOTA_FISCAL_SERV_FF'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'SERIE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR' || GV_ASPAS;
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_SERV_FF' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nota_fiscal_serv_ff;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nota_fiscal_serv_ff.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nota_fiscal_serv_ff.first..vt_tab_csf_nota_fiscal_serv_ff.last loop
         --
         if trim(vt_tab_csf_nota_fiscal_serv_ff(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nota_fiscal_serv_ff(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nota_fiscal_serv_ff(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nota_fiscal_serv_ff(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nota_fiscal_serv_ff(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nota_fiscal_serv_ff(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nota_fiscal_serv_ff(i).SERIE) is null then
            vt_tab_csf_nota_fiscal_serv_ff(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nota_fiscal_serv_ff(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nota_fiscal_serv_ff(i).NRO_NF := 0;
         end if;
         --
         if trim(vt_tab_csf_nota_fiscal_serv_ff(i).ATRIBUTO) is null then
            vt_tab_csf_nota_fiscal_serv_ff(i).ATRIBUTO := 'X';
         end if;
         --
         if trim(vt_tab_csf_nota_fiscal_serv_ff(i).VALOR) is null then
            vt_tab_csf_nota_fiscal_serv_ff(i).VALOR := 'X';
         end if;
         --
         vt_tab_csf_nota_fiscal_serv_ff(i).COD_PART  := trim(vt_tab_csf_nota_fiscal_serv_ff(i).COD_PART);
         vt_tab_csf_nota_fiscal_serv_ff(i).SERIE     := trim(vt_tab_csf_nota_fiscal_serv_ff(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nota_fiscal_serv_ff.count
         insert into VW_CSF_NOTA_FISCAL_SERV_FF values vt_tab_csf_nota_fiscal_serv_ff(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nfs_ff;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações de Item Nota Fiscal Complementos de Serviços

procedure pkb_ler_itemnf_compl_serv
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_ITEMNF_COMPL_SERV'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DESCR_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CFOP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_SERVICO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DESC_INCONDICIONADO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DESC_CONDICIONADO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DEDUCAO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_OUTRA_RET' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CNAE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CD_LISTA_SERV' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_TRIB_MUNICIPIO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NAT_BC_CRED' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_ORIG_CRED' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_PAG_PIS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_PAG_COFINS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_LOC_EXE_SERV' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TRIB_MUN_PREST' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CIDADE_IBGE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_CTA' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_CCUS' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_COMPL_SERV' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_itemnf_compl_serv;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_itemnf_compl_serv.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_itemnf_compl_serv.first..vt_tab_csf_itemnf_compl_serv.last loop
         --
         if trim(vt_tab_csf_itemnf_compl_serv(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_itemnf_compl_serv(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_itemnf_compl_serv(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_itemnf_compl_serv(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_itemnf_compl_serv(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_itemnf_compl_serv(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_itemnf_compl_serv(i).SERIE) is null then
            vt_tab_csf_itemnf_compl_serv(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_itemnf_compl_serv(i).NRO_NF, -1) < 0 then
            vt_tab_csf_itemnf_compl_serv(i).NRO_NF := 0;
         end if;
         --
         if nvl(vt_tab_csf_itemnf_compl_serv(i).NRO_ITEM, -1) < 0 then
            vt_tab_csf_itemnf_compl_serv(i).NRO_ITEM := -1;
         end if;
         --
         if trim(vt_tab_csf_itemnf_compl_serv(i).COD_ITEM) is null then
            vt_tab_csf_itemnf_compl_serv(i).COD_ITEM := '-1';
         end if;
         --
         if trim(vt_tab_csf_itemnf_compl_serv(i).DESCR_ITEM) is null then
            vt_tab_csf_itemnf_compl_serv(i).DESCR_ITEM := ' ';
         end if;
         --
         if nvl(vt_tab_csf_itemnf_compl_serv(i).CFOP, -1) < 0 then
            vt_tab_csf_itemnf_compl_serv(i).CFOP := -1;
         end if;
         --
         if nvl(vt_tab_csf_itemnf_compl_serv(i).VL_SERVICO, -1) < 0 then
            vt_tab_csf_itemnf_compl_serv(i).VL_SERVICO := -1;
         end if;
         --
         if nvl(vt_tab_csf_itemnf_compl_serv(i).DM_IND_ORIG_CRED, -1) < 0 then
            vt_tab_csf_itemnf_compl_serv(i).DM_IND_ORIG_CRED := -1;
         end if;
         --
         if nvl(vt_tab_csf_itemnf_compl_serv(i).DM_TRIB_MUN_PREST, -1) < 0 then
            vt_tab_csf_itemnf_compl_serv(i).DM_TRIB_MUN_PREST := -1;
         end if;
         --
         if nvl(vt_tab_csf_itemnf_compl_serv(i).CIDADE_IBGE, -1) < 0 then
            vt_tab_csf_itemnf_compl_serv(i).CIDADE_IBGE := -1;
         end if;
         --
         vt_tab_csf_itemnf_compl_serv(i).COD_PART  := trim(vt_tab_csf_itemnf_compl_serv(i).COD_PART);
         vt_tab_csf_itemnf_compl_serv(i).SERIE     := trim(vt_tab_csf_itemnf_compl_serv(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_itemnf_compl_serv.count
         insert into VW_CSF_ITEMNF_COMPL_SERV values vt_tab_csf_itemnf_compl_serv(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_itemnf_compl_serv;
---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações de Item Nota Fiscal Complementos de Serviços

procedure pkb_ler_itemnf_compl_serv_ff
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_ITEMNF_COMPL_SERV_FF') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_ITEMNF_COMPL_SERV_FF'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || GV_ASPAS || 'CPF_CNPJ_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_EMIT' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'DM_IND_OPER' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'COD_PART' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'SERIE' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_NF' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'NRO_ITEM' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'ATRIBUTO' || GV_ASPAS;
   gv_sql := gv_sql || ', ' || GV_ASPAS || 'VALOR' || GV_ASPAS;
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_ITEMNF_COMPL_SERV_FF' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_itnf_compl_serv_ff;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_itnf_compl_serv_ff.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_itnf_compl_serv_ff.first..vt_tab_csf_itnf_compl_serv_ff.last loop
         --
         if trim(vt_tab_csf_itnf_compl_serv_ff(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_itnf_compl_serv_ff(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_itnf_compl_serv_ff(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_itnf_compl_serv_ff(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_itnf_compl_serv_ff(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_itnf_compl_serv_ff(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_itnf_compl_serv_ff(i).SERIE) is null then
            vt_tab_csf_itnf_compl_serv_ff(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_itnf_compl_serv_ff(i).NRO_NF, -1) < 0 then
            vt_tab_csf_itnf_compl_serv_ff(i).NRO_NF := 0;
         end if;
         --
         if nvl(vt_tab_csf_itnf_compl_serv_ff(i).NRO_ITEM, -1) < 0 then
            vt_tab_csf_itnf_compl_serv_ff(i).NRO_ITEM := -1;
         end if;
         --
         if trim(vt_tab_csf_itnf_compl_serv_ff(i).ATRIBUTO) is null then
            vt_tab_csf_itnf_compl_serv_ff(i).ATRIBUTO := 'X';
         end if;
         --
         if trim(vt_tab_csf_itnf_compl_serv_ff(i).VALOR) is null then
            vt_tab_csf_itnf_compl_serv_ff(i).VALOR := 'X';
         end if;
         --
         vt_tab_csf_itnf_compl_serv_ff(i).COD_PART  := trim(vt_tab_csf_itnf_compl_serv_ff(i).COD_PART);
         vt_tab_csf_itnf_compl_serv_ff(i).SERIE     := trim(vt_tab_csf_itnf_compl_serv_ff(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_itnf_compl_serv_ff.count
         insert into VW_CSF_ITEMNF_COMPL_SERV_FF values vt_tab_csf_itnf_compl_serv_ff(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_itemnf_compl_serv_ff;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações de serviços do Serviço

procedure pkb_ler_imp_itemnf_serv
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_IMP_ITEMNF_SERV'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_IMPOSTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_ST' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_BASE_CALC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ALIQ_APLI' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_IMP_TRIB' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_IMP_ITEMNF_SERV' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_imp_itemnf_serv;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_imp_itemnf_serv.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_imp_itemnf_serv.first..vt_tab_csf_imp_itemnf_serv.last loop
         --
         if trim(vt_tab_csf_imp_itemnf_serv(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_imp_itemnf_serv(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_imp_itemnf_serv(i).SERIE) is null then
            vt_tab_csf_imp_itemnf_serv(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv(i).NRO_NF, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv(i).NRO_NF := 0;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv(i).NRO_ITEM, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv(i).NRO_ITEM := -1;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv(i).COD_IMPOSTO, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv(i).COD_IMPOSTO := -1;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv(i).DM_TIPO, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv(i).DM_TIPO := -1;
         end if;
         --
         vt_tab_csf_imp_itemnf_serv(i).COD_PART  := trim(vt_tab_csf_imp_itemnf_serv(i).COD_PART);
         vt_tab_csf_imp_itemnf_serv(i).SERIE     := trim(vt_tab_csf_imp_itemnf_serv(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_imp_itemnf_serv.count
         insert into VW_CSF_IMP_ITEMNF_SERV values vt_tab_csf_imp_itemnf_serv(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_imp_itemnf_serv;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações de Impostos dos itens serviços do Serviço - Processo FF

procedure pkb_ler_imp_itemnf_serv_ff
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SERV_FF') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_IMP_ITEMNF_SERV_FF'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ITEM' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_IMPOSTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ATRIBUTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_IMP_ITEMNF_SERV_FF' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_imp_itemnf_serv_ff;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_imp_itemnf_serv_ff.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_imp_itemnf_serv_ff.first..vt_tab_csf_imp_itemnf_serv_ff.last loop
         --
         if trim(vt_tab_csf_imp_itemnf_serv_ff(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_imp_itemnf_serv_ff(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv_ff(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv_ff(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv_ff(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv_ff(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_imp_itemnf_serv_ff(i).SERIE) is null then
            vt_tab_csf_imp_itemnf_serv_ff(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv_ff(i).NRO_NF, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv_ff(i).NRO_NF := 0;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv_ff(i).NRO_ITEM, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv_ff(i).NRO_ITEM := -1;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv_ff(i).COD_IMPOSTO, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv_ff(i).COD_IMPOSTO := -1;
         end if;
         --
         if nvl(vt_tab_csf_imp_itemnf_serv_ff(i).DM_TIPO, -1) < 0 then
            vt_tab_csf_imp_itemnf_serv_ff(i).DM_TIPO := -1;
         end if;
         --
         if trim(vt_tab_csf_imp_itemnf_serv_ff(i).ATRIBUTO) is null then
            vt_tab_csf_imp_itemnf_serv_ff(i).ATRIBUTO := '-1';
         end if;
         --
         if trim(vt_tab_csf_imp_itemnf_serv_ff(i).VALOR) is null then
            vt_tab_csf_imp_itemnf_serv_ff(i).VALOR := ' ';
         end if;
         --
         vt_tab_csf_imp_itemnf_serv(i).COD_PART  := trim(vt_tab_csf_imp_itemnf_serv(i).COD_PART);
         vt_tab_csf_imp_itemnf_serv(i).SERIE     := trim(vt_tab_csf_imp_itemnf_serv(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_imp_itemnf_serv_ff.count
         insert into VW_CSF_IMP_ITEMNF_SERV_FF values vt_tab_csf_imp_itemnf_serv_ff(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_imp_itemnf_serv_ff;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações adicionais da nota fiscal de serviço

procedure pkb_ler_nfinfor_adic_serv
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NFINFOR_ADIC_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NFINFOR_ADIC_SERV'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TIPO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CAMPO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CONTEUDO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ORIG_PROC' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NFINFOR_ADIC_SERV' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nfinfor_adic_serv;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nfinfor_adic_serv.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nfinfor_adic_serv.first..vt_tab_csf_nfinfor_adic_serv.last loop
         --
         if trim(vt_tab_csf_nfinfor_adic_serv(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nfinfor_adic_serv(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nfinfor_adic_serv(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nfinfor_adic_serv(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nfinfor_adic_serv(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nfinfor_adic_serv(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nfinfor_adic_serv(i).SERIE) is null then
            vt_tab_csf_nfinfor_adic_serv(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nfinfor_adic_serv(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nfinfor_adic_serv(i).NRO_NF := 0;
         end if;
         --
         if nvl(vt_tab_csf_nfinfor_adic_serv(i).DM_TIPO, -1) < 0 then
            vt_tab_csf_nfinfor_adic_serv(i).DM_TIPO := 0;
         end if;
         --
         if trim(vt_tab_csf_nfinfor_adic_serv(i).CONTEUDO) is null then
            vt_tab_csf_nfinfor_adic_serv(i).CONTEUDO := ' ';
         end if;
         --
         vt_tab_csf_nfinfor_adic_serv(i).COD_PART  := trim(vt_tab_csf_nfinfor_adic_serv(i).COD_PART);
         vt_tab_csf_nfinfor_adic_serv(i).SERIE     := trim(vt_tab_csf_nfinfor_adic_serv(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nfinfor_adic_serv.count
         insert into VW_CSF_NFINFOR_ADIC_SERV values vt_tab_csf_nfinfor_adic_serv(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nfinfor_adic_serv;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações do Destinatario da Nota Fiscal de Serviço

procedure pkb_ler_nf_dest_serv
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_DEST_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NF_DEST_SERV'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CNPJ' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CPF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NOME' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'LOGRAD' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COMPL' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'BAIRRO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CIDADE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CIDADE_IBGE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'UF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CEP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PAIS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'PAIS' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'FONE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'IE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SUFRAMA' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'EMAIL' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'IM' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_DEST_SERV' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nf_dest_serv;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nf_dest_serv.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nf_dest_serv.first..vt_tab_csf_nf_dest_serv.last loop
         --
         if trim(vt_tab_csf_nf_dest_serv(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nf_dest_serv(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nf_dest_serv(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nf_dest_serv(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nf_dest_serv(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nf_dest_serv(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nf_dest_serv(i).SERIE) is null then
            vt_tab_csf_nf_dest_serv(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nf_dest_serv(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nf_dest_serv(i).NRO_NF := 0;
         end if;
         --
         if trim(vt_tab_csf_nf_dest_serv(i).NOME) is null then
            vt_tab_csf_nf_dest_serv(i).NOME := ' ';
         end if;
         --
         if trim(vt_tab_csf_nf_dest_serv(i).LOGRAD) is null then
            vt_tab_csf_nf_dest_serv(i).LOGRAD := ' ';
         end if;
         --
         if trim(vt_tab_csf_nf_dest_serv(i).NRO) is null then
            vt_tab_csf_nf_dest_serv(i).NRO := ' ';
         end if;
         --
         if trim(vt_tab_csf_nf_dest_serv(i).BAIRRO) is null then
            vt_tab_csf_nf_dest_serv(i).BAIRRO := ' ';
         end if;
         --
         if trim(vt_tab_csf_nf_dest_serv(i).CIDADE) is null then
            vt_tab_csf_nf_dest_serv(i).CIDADE := ' ';
         end if;
         --
         if nvl(vt_tab_csf_nf_dest_serv(i).CIDADE_IBGE, -1) < 0 then
            vt_tab_csf_nf_dest_serv(i).CIDADE_IBGE := -1;
         end if;
         --
         if trim(vt_tab_csf_nf_dest_serv(i).UF) is null then
            vt_tab_csf_nf_dest_serv(i).UF := '-1';
         end if;
         --
         vt_tab_csf_nf_dest_serv(i).COD_PART  := trim(vt_tab_csf_nf_dest_serv(i).COD_PART);
         vt_tab_csf_nf_dest_serv(i).SERIE     := trim(vt_tab_csf_nf_dest_serv(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nf_dest_serv.count
         insert into VW_CSF_NF_DEST_SERV values vt_tab_csf_nf_dest_serv(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nf_dest_serv;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações do Intermediario da Nota Fiscal de Serviço

procedure pkb_ler_nf_inter_serv
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_INTER_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NF_INTER_SERV'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NOME' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'INSCR_MUNIC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'CPF_CNPJ' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_INTER_SERV' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nf_inter_serv;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nf_inter_serv.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nf_inter_serv.first..vt_tab_csf_nf_inter_serv.last loop
         --
         if trim(vt_tab_csf_nf_inter_serv(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nf_inter_serv(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nf_inter_serv(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nf_inter_serv(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nf_inter_serv(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nf_inter_serv(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nf_inter_serv(i).SERIE) is null then
            vt_tab_csf_nf_inter_serv(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nf_inter_serv(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nf_inter_serv(i).NRO_NF := 0;
         end if;
         --
         vt_tab_csf_nf_inter_serv(i).COD_PART  := trim(vt_tab_csf_nf_inter_serv(i).COD_PART);
         vt_tab_csf_nf_inter_serv(i).SERIE     := trim(vt_tab_csf_nf_inter_serv(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nf_inter_serv.count
         insert into VW_CSF_NF_INTER_SERV values vt_tab_csf_nf_inter_serv(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nf_inter_serv;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações sobre o detalhamento de serviços prestados na construção civil

procedure pkb_ler_nfs_det_const_civil
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NFS_DET_CONSTR_CIVIL') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NFS_DET_CONSTR_CIVIL'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_OBRA'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_ART'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_CNO'         || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OBRA'         || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NFS_DET_CONSTR_CIVIL' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nfs_det_const_civil;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nfs_det_const_civil.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nfs_det_const_civil.first..vt_tab_csf_nfs_det_const_civil.last loop
         --
         if trim(vt_tab_csf_nfs_det_const_civil(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nfs_det_const_civil(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nfs_det_const_civil(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nfs_det_const_civil(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nfs_det_const_civil(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nfs_det_const_civil(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nfs_det_const_civil(i).SERIE) is null then
            vt_tab_csf_nfs_det_const_civil(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nfs_det_const_civil(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nfs_det_const_civil(i).NRO_NF := 0;
         end if;
         --
         vt_tab_csf_nfs_det_const_civil(i).COD_PART  := trim(vt_tab_csf_nfs_det_const_civil(i).COD_PART);
         vt_tab_csf_nfs_det_const_civil(i).SERIE     := trim(vt_tab_csf_nfs_det_const_civil(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nfs_det_const_civil.count
         insert into VW_CSF_NFS_DET_CONSTR_CIVIL values vt_tab_csf_nfs_det_const_civil(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nfs_det_const_civil;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações das duplicatas da cobrança da nota fiscal de serviço.

procedure pkb_ler_nf_cobr_dup_serv
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_COBR_DUP_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NF_COBR_DUP_SERV'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_FAT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_PARC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_VENCTO' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VL_DUP' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_COBR_DUP_SERV' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nf_cobr_dup_serv;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nf_cobr_dup_serv.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nf_cobr_dup_serv.first..vt_tab_csf_nf_cobr_dup_serv.last loop
         --
         if trim(vt_tab_csf_nf_cobr_dup_serv(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nf_cobr_dup_serv(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nf_cobr_dup_serv(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nf_cobr_dup_serv(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nf_cobr_dup_serv(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nf_cobr_dup_serv(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nf_cobr_dup_serv(i).SERIE) is null then
            vt_tab_csf_nf_cobr_dup_serv(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nf_cobr_dup_serv(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nf_cobr_dup_serv(i).NRO_NF := 0;
         end if;
         --
         if trim(vt_tab_csf_nf_cobr_dup_serv(i).NRO_FAT) is null then
            vt_tab_csf_nf_cobr_dup_serv(i).NRO_FAT := '-1';
         end if;
         --
         if trim(vt_tab_csf_nf_cobr_dup_serv(i).NRO_PARC) is null then
            vt_tab_csf_nf_cobr_dup_serv(i).NRO_PARC := '-1';
         end if;
         --
         if trim(vt_tab_csf_nf_cobr_dup_serv(i).DT_VENCTO) is null then
            vt_tab_csf_nf_cobr_dup_serv(i).DT_VENCTO := trunc(sysdate);
         end if;
         --
         vt_tab_csf_nf_cobr_dup_serv(i).COD_PART  := trim(vt_tab_csf_nf_cobr_dup_serv(i).COD_PART);
         vt_tab_csf_nf_cobr_dup_serv(i).SERIE     := trim(vt_tab_csf_nf_cobr_dup_serv(i).SERIE);
         vt_tab_csf_nf_cobr_dup_serv(i).NRO_FAT   := trim(vt_tab_csf_nf_cobr_dup_serv(i).NRO_FAT);
         vt_tab_csf_nf_cobr_dup_serv(i).NRO_PARC  := trim(vt_tab_csf_nf_cobr_dup_serv(i).NRO_PARC);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nf_cobr_dup_serv.count
         insert into VW_CSF_NF_COBR_DUP_SERV values vt_tab_csf_nf_cobr_dup_serv(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nf_cobr_dup_serv;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações do complemento do serviço.

procedure pkb_ler_nf_compl_serv
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NOTA_FISCAL_COMPL_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NOTA_FISCAL_COMPL_SERV'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'ID_ERP' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NOTA_FISCAL_COMPL_SERV' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nf_compl_serv;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nf_compl_serv.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nf_compl_serv.first..vt_tab_csf_nf_compl_serv.last loop
         --
         if trim(vt_tab_csf_nf_compl_serv(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nf_compl_serv(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nf_compl_serv(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nf_compl_serv(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nf_compl_serv(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nf_compl_serv(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nf_compl_serv(i).SERIE) is null then
            vt_tab_csf_nf_compl_serv(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nf_compl_serv(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nf_compl_serv(i).NRO_NF := 0;
         end if;
         --
         vt_tab_csf_nf_compl_serv(i).COD_PART  := trim(vt_tab_csf_nf_compl_serv(i).COD_PART);
         vt_tab_csf_nf_compl_serv(i).SERIE     := trim(vt_tab_csf_nf_compl_serv(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nf_compl_serv.count
         insert into VW_CSF_NOTA_FISCAL_COMPL_SERV values vt_tab_csf_nf_compl_serv(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nf_compl_serv;

---------------------------------------------------------------------------------------------------------

--| Procedimento de leitura de Informações para o cancelamento da nota fiscal de serviço

procedure pkb_ler_nf_canc_serv
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_CANC_SERV') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NF_CANC_SERV'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DT_CANC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'JUSTIF' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_CANC_SERV' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nf_canc_serv;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nf_canc_serv.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nf_canc_serv.first..vt_tab_csf_nf_canc_serv.last loop
         --
         if trim(vt_tab_csf_nf_canc_serv(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nf_canc_serv(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nf_canc_serv(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nf_canc_serv(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nf_canc_serv(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nf_canc_serv(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nf_canc_serv(i).SERIE) is null then
            vt_tab_csf_nf_canc_serv(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nf_canc_serv(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nf_canc_serv(i).NRO_NF := 0;
         end if;
         --
         if trim(vt_tab_csf_nf_canc_serv(i).DT_CANC) is null then
            vt_tab_csf_nf_canc_serv(i).DT_CANC := trunc(sysdate);
         end if;
         --
         if trim(vt_tab_csf_nf_canc_serv(i).JUSTIF) is null then
            vt_tab_csf_nf_canc_serv(i).JUSTIF := ' ';
         end if;
         --
         vt_tab_csf_nf_canc_serv(i).COD_PART  := trim(vt_tab_csf_nf_canc_serv(i).COD_PART);
         vt_tab_csf_nf_canc_serv(i).SERIE     := trim(vt_tab_csf_nf_canc_serv(i).SERIE);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nf_canc_serv.count
         insert into VW_CSF_NF_CANC_SERV values vt_tab_csf_nf_canc_serv(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nf_canc_serv;

---------------------------------------------------------------------------------------------------------

procedure pkb_excluir_dados
is
   --
   vn_fase number := 0;
   --
begin
   --
   pb_truncate_table('VW_CSF_NOTA_FISCAL_SERV');
   pb_truncate_table('VW_CSF_NOTA_FISCAL_SERV_FF');
   pb_truncate_table('VW_CSF_ITEMNF_COMPL_SERV');
   pb_truncate_table('VW_CSF_ITEMNF_COMPL_SERV_FF');
   pb_truncate_table('VW_CSF_IMP_ITEMNF_SERV');
   pb_truncate_table('VW_CSF_IMP_ITEMNF_SERV_FF');
   pb_truncate_table('VW_CSF_NFINFOR_ADIC_SERV');
   pb_truncate_table('VW_CSF_NF_DEST_SERV');
   pb_truncate_table('VW_CSF_NF_INTER_SERV');
   pb_truncate_table('VW_CSF_NFS_DET_CONSTR_CIVIL');
   pb_truncate_table('VW_CSF_NF_COBR_DUP_SERV');
   pb_truncate_table('VW_CSF_NF_CANC_SERV');
   pb_truncate_table('VW_CSF_NOTA_FISCAL_COMPL_SERV');
   pb_truncate_table('VW_CSF_NF_PROC_REINF');
   --
   commit;
   --
exception
   when others then
      null;
end pkb_excluir_dados;

procedure pkb_ler_nf_proc_reinf
is
   --
   vn_fase   number := 0;
   i         pls_integer;
   vn_qtde   number := 0;
   vv_obj    varchar2(100);
   --
begin
   --
   vn_fase := 1;
   --
   if pk_csf.fkg_existe_obj_util_integr ( ev_obj_name => 'VW_CSF_NF_PROC_REINF') = 0 then
      --
      return;
      --
   end if;
   --
   vv_obj := pk_csf.fkg_monta_obj ( ev_obj         => 'VW_CSF_NF_PROC_REINF'
                                  , ev_aspas       => GV_ASPAS
                                  , ev_owner_obj   => GV_OWNER_OBJ
                                  , ev_nome_dblink => GV_NOME_DBLINK
                                  );
   --
   vn_qtde := pk_csf.fkg_quantidade(vv_obj);
   --
   gv_sql := null;
   --
   --  inicia montagem da query
   gv_sql := 'select ';
   --
   gv_sql := gv_sql || trim(GV_ASPAS) || 'CPF_CNPJ_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_EMIT' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_OPER' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_PART' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'SERIE' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_NF' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_TP_PROC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'NRO_PROC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'COD_SUSP' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'DM_IND_PROC_RET_ADIC' || trim(GV_ASPAS);
   gv_sql := gv_sql || ', ' || trim(GV_ASPAS) || 'VALOR' || trim(GV_ASPAS);
   --
   gv_sql := gv_sql || ' from ' || vv_obj || ' where rownum <= ' || vn_qtde;
   --
   vn_fase := 2;
   --
   gv_resumo := 'Inconsistência de dados no leiaute VW_CSF_NF_PROC_REINF' || chr(10);
   -- recupera as Notas Fiscais de Serviço não integradas
   begin
     --
     execute immediate gv_sql bulk collect into vt_tab_csf_nf_proc_reinf;
     --
   exception
      when others then
        null;
   end;
   --
   vn_fase := 3;
   --
   if (vt_tab_csf_nf_proc_reinf.count) > 0 then
      --
      vn_fase := 4;
      --
      for i in vt_tab_csf_nf_proc_reinf.first..vt_tab_csf_nf_proc_reinf.last loop
         --
         if trim(vt_tab_csf_nf_proc_reinf(i).CPF_CNPJ_EMIT) is null then
            vt_tab_csf_nf_proc_reinf(i).CPF_CNPJ_EMIT := 0;
         end if;
         --
         if nvl(vt_tab_csf_nf_proc_reinf(i).DM_IND_EMIT, -1) < 0 then
            vt_tab_csf_nf_proc_reinf(i).DM_IND_EMIT := -1;
         end if;
         --
         if nvl(vt_tab_csf_nf_proc_reinf(i).DM_IND_OPER, -1) < 0 then
            vt_tab_csf_nf_proc_reinf(i).DM_IND_OPER := -1;
         end if;
         --
         if trim(vt_tab_csf_nf_proc_reinf(i).SERIE) is null then
            vt_tab_csf_nf_proc_reinf(i).SERIE := '0';
         end if;
         --
         if nvl(vt_tab_csf_nf_proc_reinf(i).NRO_NF, -1) < 0 then
            vt_tab_csf_nf_proc_reinf(i).NRO_NF := 0;
         end if;
         --
         if trim(vt_tab_csf_nf_proc_reinf(i).NRO_PROC) is null then
            vt_tab_csf_nf_proc_reinf(i).NRO_PROC := '0';
         end if;
         --
         if trim(vt_tab_csf_nf_proc_reinf(i).DM_IND_PROC_RET_ADIC) is null then
            vt_tab_csf_nf_proc_reinf(i).DM_IND_PROC_RET_ADIC := '0';
         end if;
         --
         if nvl(vt_tab_csf_nf_proc_reinf(i).VALOR, -1) < 0 then
            vt_tab_csf_nf_proc_reinf(i).VALOR := 0;
         end if;
         --
         vt_tab_csf_nf_proc_reinf(i).COD_PART              := trim(vt_tab_csf_nf_proc_reinf(i).COD_PART);
         vt_tab_csf_nf_proc_reinf(i).SERIE                 := trim(vt_tab_csf_nf_proc_reinf(i).SERIE);
         vt_tab_csf_nf_proc_reinf(i).NRO_PROC              := trim(vt_tab_csf_nf_proc_reinf(i).NRO_PROC);
         vt_tab_csf_nf_proc_reinf(i).DM_IND_PROC_RET_ADIC  := trim(vt_tab_csf_nf_proc_reinf(i).DM_IND_PROC_RET_ADIC);
         --
      end loop;
      --
      vn_fase := 5;
      --
      forAll i in 1..vt_tab_csf_nf_proc_reinf.count
         insert into VW_CSF_NF_PROC_REINF values vt_tab_csf_nf_proc_reinf(i);
      --
   end if;
   --
exception
   when others then
      null;
end pkb_ler_nf_proc_reinf;



-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais de Serviço

procedure pkb_integracao ( ed_dt_ini      in date default null
			 , ed_dt_fin      in date default null
			 , en_empresa_id  in empresa.id%type default null
                         )
is
   --
   vn_fase number := 0;
   --
   cursor c_emp is
   select pid.*
     from param_integr_dados pid
    order by 1;
   --
begin
   -- Inicia os contadores de registros a serem integrados
   pk_agend_integr.pkb_inicia_cont(ev_cd_obj => gv_cd_obj);  
   --
   vn_fase := 1;
   --
   for rec in c_emp loop
      exit when c_emp%notfound or (c_emp%notfound) is null;
      --
      pkb_excluir_dados;
      --
      vn_fase := 1.1;
      --
      GV_NOME_DBLINK          := rec.NOME_DBLINK;
      GV_OWNER_OBJ            := rec.OWNER_OBJ;
      gn_dm_ret_infor_integr  := rec.DM_RET_INFOR_INTEGR;
      --
      --  Seta formata da data para os procedimentos de retorno
      if trim(rec.formato_dt_erp) is not null then
         gd_formato_dt_erp := rec.formato_dt_erp;
      else
         gd_formato_dt_erp := 'DD/MM/YYYY';
      end if;
      --
      -- Verifica se utiliza GV_ASPAS dupla
      if rec.dm_util_aspa = 1 then
         --
         GV_ASPAS := '"';
         --
      else
         --
         GV_ASPAS := null;
         --
      end if;
      --
      vn_fase := 2;
      --
      pkb_limpa_array;
      --
      vn_fase := 3;
      --
      pkb_ler_nfs;
      --
      vn_fase := 3.1;
      --
      pkb_ler_nfs_ff;
      --
      vn_fase := 4;
      --
      pkb_ler_itemnf_compl_serv;
      --
      vn_fase := 4.1;
      --
      pkb_ler_itemnf_compl_serv_ff;
      --
      vn_fase := 5;
      --
      pkb_ler_imp_itemnf_serv;
      --
      vn_fase := 6;
      --
      pkb_ler_imp_itemnf_serv_ff;
      --
      vn_fase := 7;
      --
      pkb_ler_nfinfor_adic_serv;
      --
      vn_fase := 8;
      --
      pkb_ler_nf_dest_serv;
      --
      vn_fase := 9;
      --
      pkb_ler_nf_inter_serv;
      --
      vn_fase := 10;
      --
      pkb_ler_nfs_det_const_civil;
      --
      vn_fase := 11;
      --
      pkb_ler_nf_cobr_dup_serv;
      --
      vn_fase := 12;
      --
      pkb_ler_nf_compl_serv;
      --
      vn_fase := 13;
      --
      pkb_ler_nf_canc_serv;
      --
      vn_fase := 14;
      --
      pkb_ler_nf_proc_reinf;
      --
      vn_fase := 15;
      --
      commit;
      --
      vn_fase := 16;
      --
      --| Executa procedimento de integração 
      pk_integr_view_nfs.pkb_int_bloco ( en_paramintegrdados_id  => rec.id
                                       , ed_dt_ini               => ed_dt_ini
                                       , ed_dt_fin               => ed_dt_fin
                                       , en_empresa_id           => en_empresa_id
                                       );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101,'Erro pk_csf_int_bloco_nfs.pkb_integracao fase(' || vn_fase || '):' || sqlerrm);
end pkb_integracao;

-------------------------------------------------------------------------------------------------------

end pk_csf_int_bloco_nfs;
/

