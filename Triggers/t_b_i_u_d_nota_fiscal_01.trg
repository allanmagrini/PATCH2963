create or replace trigger csf_own.t_b_i_u_d_nota_fiscal_01
before insert or update or delete
    on "CSF_OWN"."NOTA_FISCAL"
referencing old as old new as new
for each row
--
declare
   vn_multorg_id         mult_org.id%type;
   vn_empresa_id         empresa.id%type;
   vn_notafiscal_id      nota_fiscal.id%type; 
   vn_dm_st_proc_new     nota_fiscal.dm_st_proc%type; 
   vn_dm_st_proc_old     nota_fiscal.dm_st_proc%type;
   vn_dm_arm_nfe_terc    nota_fiscal.dm_arm_nfe_terc%type; 
   vn_modfiscal_id       nota_fiscal.modfiscal_id%type; 
   vn_dm_ind_emit        nota_fiscal.dm_ind_emit%type; 
   vn_dt_ref             nota_fiscal.dt_emiss%type; 
   vn_dm_fin_nfe         nota_fiscal.dm_fin_nfe%type; 
   vn_dm_dt_escr_dfepoe  empresa.dm_dt_escr_dfepoe%type; 
   pragma autonomous_transaction;
   --
begin
   -------------------------------------------------------------------------------
   -- 
   -- Em 16/03/2021 - Allan Magrini
   -- #52590 Relatório para conferência de Apuração de PIS/COFINS.
   --
   --
   -------------------------------------------------------------------------------
   vn_multorg_id      := pk_csf.fkg_multorg_id_empresa (:old.empresa_id); 
   vn_notafiscal_id   := :old.id;
   vn_empresa_id      := :old.empresa_id;
   vn_dm_st_proc_new  := :new.dm_st_proc;
   vn_dm_st_proc_old  := :old.dm_st_proc;
   vn_dm_arm_nfe_terc := :old.dm_arm_nfe_terc;
   vn_modfiscal_id    := :old.modfiscal_id;
   vn_dm_ind_emit     := :old.dm_ind_emit;
   vn_dt_ref          := :old.DT_EMISS;
   vn_dm_fin_nfe      := :old.dm_fin_nfe;
--
  if nvl( pk_csf.fkg_parametro_geral_sistema ( en_multorg_id =>  vn_multorg_id,
                                       en_empresa_id  =>  vn_empresa_id,
                                       ev_cod_modulo  => 'OBRIG_FEDERAL',
                                       ev_cod_grupo   => 'EFD_CONTRIB',
                                       ev_param_name  => 'GERA_PIS_COFINS_ANALITICO'),0) > 0 then
   --
   begin
    select em.dm_dt_escr_dfepoe
      into vn_dm_dt_escr_dfepoe
        from empresa em
       where em.id = vn_empresa_id; 
   exception
         when others then
            vn_dm_dt_escr_dfepoe := null;
   end;
   --
if (:old.dm_ind_emit = 1) then
 vn_dt_ref:= nvl(:old.dt_sai_ent,:old.dt_emiss);  
 --
else 
  --
  if :old.dm_ind_emit = 0 and :old.dm_ind_oper = 1  then
     vn_dt_ref:=  :old.dt_emiss;
  end if;
  --
  if  (:old.dm_ind_emit = 0 and :old.dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 0) then
      vn_dt_ref:=  :old.dt_emiss;
  end if;
  --
  if (:old.dm_ind_emit = 0 and :old.dm_ind_oper = 0 and vn_dm_dt_escr_dfepoe = 1)  then
      vn_dt_ref:=  nvl(:old.dt_sai_ent,:old.dt_emiss);
  end if;
  --
end if;
   --
   if inserting or updating then
     --
     if vn_dm_st_proc_new in (4) then 
     pk_pis_cofins_analitico.pkb_inclui_nota_fiscal(  en_notafiscal_id    =>  vn_notafiscal_id  
                                                    , en_empresa_id       =>  vn_empresa_id
                                                    , en_multorg_id       =>  vn_multorg_id
                                                    , en_dm_st_proc       =>  vn_dm_st_proc_new
                                                    , en_dm_arm_nfe_terc  =>  vn_dm_arm_nfe_terc
                                                    , en_modfiscal_id     =>  vn_modfiscal_id
                                                    , en_dm_ind_emit      =>  vn_dm_ind_emit
                                                    , en_dt_ref           =>  vn_dt_ref
                                                    , en_dm_fin_nfe       =>  vn_dm_fin_nfe);  
     end if;
     --
     if vn_dm_st_proc_new in (7) then
     pk_pis_cofins_analitico.pkb_exclui_nota_fiscal(  en_notafiscal_id =>  vn_notafiscal_id   
                                                    , en_empresa_id    =>  vn_empresa_id
                                                    , en_multorg_id    =>  vn_multorg_id); 
   -- 
   end if;
     --
   elsif deleting or vn_dm_st_proc_old in (4) then
     pk_pis_cofins_analitico.pkb_exclui_nota_fiscal(  en_notafiscal_id =>  vn_notafiscal_id   
                                                    , en_empresa_id    =>  vn_empresa_id
                                                    , en_multorg_id    =>  vn_multorg_id); 
   -- 
   end if;
   --
   commit;
   --
   end if;
end t_b_i_u_d_nota_fiscal_01;
/
