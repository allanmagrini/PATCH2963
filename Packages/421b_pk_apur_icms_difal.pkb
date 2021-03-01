create or replace package body csf_own.pk_apur_icms_difal is

-------------------------------------------------------------------------------------------------------
--| Corpo do pacote de procedimentos de Geração da Apuração de ICMS DIFAL
-------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valores recolhidos ou a recolher, extra-apuração - FCP.
function fkg_soma_vl_deb_esp_fcp
         return ajust_apur_icms_difal.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apur_icms_difal.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aai.vl_aj_apur)
     into vn_vl_aj_apur
     from ajust_apur_icms_difal  aai
        , cod_aj_saldo_apur_icms cod
    where aai.apuricmsdifal_id   = gt_row_apur_icms_difal.id
      and cod.id                 = aai.codajsaldoapuricms_id
      and cod.dm_apur            in (3) -- FCP
      and cod.dm_util            in (5); -- 5-Debitos Especiais
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_deb_esp_fcp:' || sqlerrm);
end fkg_soma_vl_deb_esp_fcp;

------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total das deduções "FCP"
function fkg_soma_vl_deducoes_fcp
         return ajust_apur_icms_difal.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apur_icms_difal.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aai.vl_aj_apur)
     into vn_vl_aj_apur
     from ajust_apur_icms_difal  aai
        , cod_aj_saldo_apur_icms cod
    where aai.apuricmsdifal_id   = gt_row_apur_icms_difal.id
      and cod.id                 = aai.codajsaldoapuricms_id
      and cod.dm_apur            in (3) -- FCP
      and cod.dm_util            in (4); -- 4-Deducoes
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_deducoes_fcp:' || sqlerrm);
end fkg_soma_vl_deducoes_fcp;

------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total de Ajustes "Outros créditos FCP" e “Estorno de débitos FCP”
function fkg_soma_vl_out_cred_fcp
         return ajust_apur_icms_difal.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apur_icms_difal.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aai.vl_aj_apur)
     into vn_vl_aj_apur
     from ajust_apur_icms_difal  aai
        , cod_aj_saldo_apur_icms cod
    where aai.apuricmsdifal_id   = gt_row_apur_icms_difal.id
      and cod.id                 = aai.codajsaldoapuricms_id
      and cod.dm_apur            in (3) -- FCP
      and cod.dm_util            in (2,3); -- "2-outros creditos" ou "3-estorno debitos"
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_out_cred_fcp:' || sqlerrm);
end fkg_soma_vl_out_cred_fcp;

------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos ajustes "Outros débitos FCP" e “Estorno de créditos FCP”
function fkg_soma_vl_out_deb_fcp
         return ajust_apur_icms_difal.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apur_icms_difal.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aai.vl_aj_apur) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apur_icms_difal  aai
        , cod_aj_saldo_apur_icms cod
    where aai.apuricmsdifal_id   = gt_row_apur_icms_difal.id
      and cod.id                 = aai.codajsaldoapuricms_id
      and cod.dm_apur            in (3) -- FCP
      and cod.dm_util            in (0,1); -- "0-outros débitos" ou "1-estorno créditos"
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_out_deb_fcp:' || sqlerrm);
end fkg_soma_vl_out_deb_fcp;

-------------------------------------------------------------------------------------------------------
-- Função retorna o saldo anterior FCP
function fkg_saldo_credor_ant_fcp
         return apur_icms_difal.vl_sld_cred_ant_fcp%type
is
   --
   vn_vl_sld_cred_ant_fcp apur_icms_difal.vl_sld_cred_ant_fcp%type := 0;
   --
begin
   --
   select ai.vl_sld_cred_transportar_fcp
     into vn_vl_sld_cred_ant_fcp
     from per_apur_icms_difal pa
        , apur_icms_difal     ai
    where pa.empresa_id                   = gt_row_per_apur_icms_difal.empresa_id
      and to_char(pa.dt_inicio, 'rrrrmm') = to_char(add_months(gt_row_per_apur_icms_difal.dt_inicio, -1), 'rrrrmm')
      and pa.dm_tipo                      = gt_row_per_apur_icms_difal.dm_tipo
      and ai.perapuricmsdifal_id          = pa.id
      and ai.estado_id                    = gt_row_apur_icms_difal.estado_id
      and ai.dm_situacao                  = 3; -- Processada
   --
   return nvl(vn_vl_sld_cred_ant_fcp,0);
   --
exception
   when others then
      return 0;
end fkg_saldo_credor_ant_fcp;

-------------------------------------------------------------------------------------------------------
-- Função retorna o saldo anterior DIFAL
function fkg_saldo_credor_ant_difal
         return apur_icms_difal.vl_sld_cred_ant_difal%type
is
   --
   vn_vl_sld_cred_ant_difal apur_icms_difal.vl_sld_cred_ant_difal%type := 0;
   --
begin
   --
   select a.vl_sld_cred_transportar
     into vn_vl_sld_cred_ant_difal
     from per_apur_icms_difal  p
        , apur_icms_difal a
    where p.empresa_id                   = gt_row_per_apur_icms_difal.empresa_id
      and to_char(p.dt_inicio, 'rrrrmm') = to_char(add_months(gt_row_per_apur_icms_difal.dt_inicio, -1), 'rrrrmm')
      and p.dm_tipo                      = gt_row_per_apur_icms_difal.dm_tipo
      and a.perapuricmsdifal_id          = p.id
      and a.estado_id                    = gt_row_apur_icms_difal.estado_id
      and a.dm_situacao                  = 3; -- Processada
   --
   return nvl(vn_vl_sld_cred_ant_difal,0);
   --
exception
   when others then
      return 0;
end fkg_saldo_credor_ant_difal;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos débitos por "Saídas e prestações com débito do ICMS referente ao diferencial de alíquota devido à UF do Remetente/Destinatário"
function fkg_vl_tot_debitos_difal
         return apur_icms_difal.vl_tot_debitos_difal%type
is
   --
   vn_vl_tot_debitos_difal apur_icms_difal.vl_tot_debitos_difal%type := 0;
   --
begin
   -- Se o campo 2 – UF do registro E300 for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_REM
   if gv_sigla_estado_empresa = gv_apur_sigla_estado then
      --
      begin
         --
         /* 67653 select sum( nvl(nft.vl_icms_uf_remet,0) )
           into vn_vl_tot_debitos_difal
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_oper     = 1 -- Saida
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nft.notafiscal_id  = nf.id; */
         select sum( nvl(nft.vl_icms_uf_remet,0) )
           into vn_vl_tot_debitos_difal
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_oper     = 1 -- Saida
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nft.notafiscal_id  = nf.id;			
         --
      exception
         when others then
            vn_vl_tot_debitos_difal := 0;
      end;
      --
   else
      -- Se o campo 2 – UF do registro E300 for a do destinatário, então corresponde à somatória dos campos VL_ICMS_UF_DEST
      begin
         --
         /* 67653 select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl_tot_debitos_difal
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_dest   nfd
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_oper     = 1 -- Saida
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id; */
         select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl_tot_debitos_difal
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , nota_fiscal_dest       nfd
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_oper     = 1 -- Saida
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.dm_ind_ie_dest <> 1
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id;			
         --
      exception
         when others then
            vn_vl_tot_debitos_difal := 0;
      end;
      --
   end if;
   --
   return nvl(vn_vl_tot_debitos_difal,0);
   --
exception
   when others then
      return 0;
end fkg_vl_tot_debitos_difal;

------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor Total dos ajustes "Outros débitos ICMS Diferencial de Alíquota da UF de Origem/Destino" " e “Estorno de créditos ICMS Diferencial de Alíquota da UF de Origem/Destino
function fkg_soma_vl_out_deb_difal
         return ajust_apur_icms_difal.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apur_icms_difal.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aai.vl_aj_apur) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apur_icms_difal  aai
        , cod_aj_saldo_apur_icms cod
    where aai.apuricmsdifal_id   = gt_row_apur_icms_difal.id
      and cod.id                 = aai.codajsaldoapuricms_id
      and cod.dm_apur            in (2) -- DIFAL
      and cod.dm_util            in (0,1); -- "0-outros débitos" ou "1-estorno créditos"
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_out_deb_difal:' || sqlerrm);
end fkg_soma_vl_out_deb_difal;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos débitos FCP por "Saídas e prestações”
function fkg_vl_tot_deb_fcp
         return apur_icms_difal.vl_tot_deb_fcp%type
is
   --
   vn_vl_tot_deb_fcp apur_icms_difal.vl_tot_deb_fcp%type := 0;
   --
begin
   -- Se o campo 2 – UF do registro E300 for a do registro 0000, este valor será zero
   if gv_sigla_estado_empresa = gv_apur_sigla_estado then
      --
      vn_vl_tot_deb_fcp := 0;
      --
   else
      -- Se o campo 2 – UF do registro E300 for a do destinatário, então corresponde à somatória dos campos VL_FCP_UF_DEST
      begin
         --
         /* 67653 select sum( nvl(nft.vl_comb_pobr_uf_dest,0) )
           into vn_vl_tot_deb_fcp
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_dest   nfd
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_oper     = 1 -- Saida
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id; */
         select sum( nvl(nft.vl_comb_pobr_uf_dest,0) )
           into vn_vl_tot_deb_fcp
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , nota_fiscal_dest       nfd
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_oper     = 1 -- Saida
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.dm_ind_ie_dest <> 1
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id;			
         --
      exception
         when others then
            vn_vl_tot_deb_fcp := 0;
      end;
      --
   end if;
   --
   return nvl(vn_vl_tot_deb_fcp,0);
   --
exception
   when others then
      return 0;
end fkg_vl_tot_deb_fcp;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos créditos do ICMS referente ao diferencial de alíquota devido à UF dos Remetente/ Destinatário
function fkg_vl_tot_creditos_difal
         return apur_icms_difal.vl_tot_creditos_difal%type
is
   --
   vn_vl_tot_creditos_difal     apur_icms_difal.vl_tot_creditos_difal%type := 0;
   --
   vn_vl1_r                     nota_fiscal_total.vl_icms_uf_remet%type := 0;
   vn_vl1_d                     nota_fiscal_total.vl_icms_uf_dest%type := 0;
   --
   vn_vl2_r                     nota_fiscal_total.vl_icms_uf_remet%type := 0;
   vn_vl2_d                     nota_fiscal_total.vl_icms_uf_dest%type := 0;
   --
   vn_vl3_r                     nota_fiscal_total.vl_icms_uf_remet%type := 0;
   vn_vl3_d                     nota_fiscal_total.vl_icms_uf_dest%type := 0;
   --
begin
   --
   /*
   Até 31/12/2016 - Manual:
   VL_TOT_CREDITOS_DIFAL - Valor total dos créditos do ICMS referente ao diferencial de alíquota devido à UF dos Remetente/ Destinatário
   Campo 07 – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada).
                         Se o campo 2 – UF do registro E300 for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
                         Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_ICMS_UF_REM.
   A partir de 01/01/2017 - Manual:
   VL_TOT_CREDITOS_DIFAL - Valor total dos créditos do ICMS referente ao diferencial de alíquota devido à UF de Origem/Destino
   Campo 06 – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada).
                         Se o campo 2 – UF do registro E300 for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
                         Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_ICMS_UF_REM.
   Obs.: Não existe diferença na descrição da validação do campo, portanto o processo mantém a mesma regra.
   */
   --
   -- Se o campo 2 – UF do registro E300 for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
   -- UF do Registro E300: per_apur_icms_difal/apur_icms_difal.estado_id/estado => gv_apur_sigla_estado: apur_icms_difal.estado_id/estado
   -- UF do Registro 0000: abertura_efd.uf => gv_sigla_estado_empresa: per_apur_icms_difal.empresa_id/empresa/pessoa/cidade/estado
   --
   if gv_sigla_estado_empresa = gv_apur_sigla_estado then -- UF do registro 0000 for a do registro E300
      --
      begin
         -- siglas iguais -- devolução
         /* 67653 select sum( nvl(nft.vl_icms_uf_remet,0) )
           into vn_vl1_r
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nft.notafiscal_id  = nf.id
            and exists (select 1
                          from item_nota_fiscal it
                             , cfop             cf
                             , tipo_operacao    tp
                         where it.notafiscal_id = nf.id
                           and cf.id            = it.cfop_id
                           and tp.id            = cf.tipooperacao_id
                           and tp.cd            = 3);  */-- devolução
         select sum( nvl(nft.vl_icms_uf_remet,0) )
           into vn_vl1_r
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nft.notafiscal_id  = nf.id
            and exists (select 1
                          from tmp_item_nota_fiscal it
                             , cfop                 cf
                             , tipo_operacao        tp
                         where it.notafiscal_id = nf.id
                           and cf.id            = it.cfop_id
                           and tp.id            = cf.tipooperacao_id
                           and tp.cd            = 3); -- devolução						   
         --
      exception
         when others then
            vn_vl1_r := 0;
      end;
      --
      begin
         -- siglas iguais -- não é devolução
         /* 67653 select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl2_d
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nft.notafiscal_id  = nf.id
            and exists (select 1
                          from item_nota_fiscal it
                             , cfop             cf
                             , tipo_operacao    tp
                         where it.notafiscal_id = nf.id
                           and cf.id            = it.cfop_id
                           and tp.id            = cf.tipooperacao_id
                           and tp.cd           <> 3); */ -- devolução
         select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl2_d
           from tmp_nota_fiscal        nf
              , mod_fiscal         mf
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nft.notafiscal_id  = nf.id
            and exists (select 1
                          from tmp_item_nota_fiscal it
                             , cfop                 cf
                             , tipo_operacao        tp
                         where it.notafiscal_id = nf.id
                           and cf.id            = it.cfop_id
                           and tp.id            = cf.tipooperacao_id
                           and tp.cd           <> 3); -- devolução						   
         --
      exception
         when others then
            vn_vl2_d := 0;
      end;
      --
      begin
         --
         /* 67653 select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl3_d
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_emit     = 1 -- Terceiro
            and nf.dm_ind_oper     = 0 -- Entrada
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nft.notafiscal_id  = nf.id; */
         select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl3_d
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_emit     = 1 -- Terceiro
            and nf.dm_ind_oper     = 0 -- Entrada
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nft.notafiscal_id  = nf.id
            and not exists (select 1			
                              from tmp_nota_fiscal  nfx,
                                   nota_fiscal_dest nfd,
                                   empresa          emp,
                                   pessoa           p,
                                   cidade           c,
                                   estado           e,
                                   abertura_efd     a
                             where nfx.id            = nf.id
                               and nfd.notafiscal_id = nfx.id
                               and nfx.empresa_id    = emp.id
                               and emp.pessoa_id     = p.id
                               and p.cidade_id       = c.id
                               and c.estado_id       = e.id
                               and a.empresa_id      = emp.id
                               and a.dt_ini          = gt_row_per_apur_icms_difal.dt_inicio
                               and a.dt_fim          = gt_row_per_apur_icms_difal.dt_fim
                               and (e.sigla_estado = a.uf and nfd.dm_ind_ie_dest = 1));
      --
      exception
         when others then
            vn_vl3_d := 0;
      end;
      --
      vn_vl_tot_creditos_difal := nvl(vn_vl1_d,0) + nvl(vn_vl2_d,0) + nvl(vn_vl3_d,0)+ nvl(vn_vl1_r,0) + nvl(vn_vl2_r,0) + nvl(vn_vl3_r,0);
      --
   else
      -- Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_ICMS_UF_REM
      begin
         -- siglas diferentes - devolução
         /* 67653 select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl1_d
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_dest   nfd
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id
            and exists (select 1
                          from item_nota_fiscal it
                             , cfop             cf
                             , tipo_operacao    tp
                         where it.notafiscal_id = nf.id
                           and cf.id            = it.cfop_id
                           and tp.id            = cf.tipooperacao_id
                           and tp.cd            = 3); */ -- devolução
         select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl1_d
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , nota_fiscal_dest       nfd
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id
            and exists (select 1
                          from tmp_item_nota_fiscal it
                             , cfop                 cf
                             , tipo_operacao        tp
                         where it.notafiscal_id = nf.id
                           and cf.id            = it.cfop_id
                           and tp.id            = cf.tipooperacao_id
                           and tp.cd            = 3); -- devolução						   
         --
      exception
         when others then
            vn_vl1_d := 0;
      end;
      --
      begin
         -- siglas diferentes - não é devolução
         /* 67653 select sum( nvl(nft.vl_icms_uf_remet,0) )
           into vn_vl2_r
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_dest   nfd
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id
            and exists (select 1
                          from item_nota_fiscal it
                             , cfop             cf
                             , tipo_operacao    tp
                         where it.notafiscal_id = nf.id
                           and cf.id            = it.cfop_id
                           and tp.id            = cf.tipooperacao_id
                           and tp.cd           <> 3); */ -- devolução
         select sum( nvl(nft.vl_icms_uf_remet,0) )
           into vn_vl2_r
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , nota_fiscal_dest       nfd
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id
            and exists (select 1
                          from tmp_item_nota_fiscal it
                             , cfop                 cf
                             , tipo_operacao        tp
                         where it.notafiscal_id = nf.id
                           and cf.id            = it.cfop_id
                           and tp.id            = cf.tipooperacao_id
                           and tp.cd           <> 3); -- devolução
						   
         --
      exception
         when others then
            vn_vl2_r := 0;
      end;
      --
      begin
         --
         /* 67653 select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl3_d
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_emit   nfe
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_emit     = 1 -- Terceiros
            and nf.dm_ind_oper     = 0 -- Entrada
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfe.notafiscal_id  = nf.id
            and nfe.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id;  */
         select sum( nvl(nft.vl_icms_uf_dest,0) )
           into vn_vl3_d
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , nota_fiscal_emit       nfe
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_emit     = 1 -- Terceiros
            and nf.dm_ind_oper     = 0 -- Entrada
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfe.notafiscal_id  = nf.id
            and nfe.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id
            and not exists (select 1			
                              from tmp_nota_fiscal  nfx,
                                   nota_fiscal_dest nfd,
                                   empresa          emp,
                                   pessoa           p,
                                   cidade           c,
                                   estado           e,
                                   abertura_efd     a
                             where nfx.id            = nf.id
                               and nfd.notafiscal_id = nfx.id
                               and nfx.empresa_id    = emp.id
                               and emp.pessoa_id     = p.id
                               and p.cidade_id       = c.id
                               and c.estado_id       = e.id
                               and a.empresa_id      = emp.id
                               and a.dt_ini          = gt_row_per_apur_icms_difal.dt_inicio
                               and a.dt_fim          = gt_row_per_apur_icms_difal.dt_fim
                               and (e.sigla_estado = a.uf and nfd.dm_ind_ie_dest = 1));			
         --
      exception
         when others then
            vn_vl3_d := 0;
      end;
      --
      vn_vl_tot_creditos_difal := nvl(vn_vl1_d,0) + nvl(vn_vl2_d,0) + nvl(vn_vl3_d,0)+ nvl(vn_vl1_r,0) + nvl(vn_vl2_r,0) + nvl(vn_vl3_r,0);
      --
   end if;
   --
   return nvl(vn_vl_tot_creditos_difal,0);
   --
exception
   when others then
      return 0;
end fkg_vl_tot_creditos_difal;

------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total de Ajustes "Outros créditos ICMS Diferencial de Alíquota da UF de Origem/Destino" e “Estorno de débitos ICMS Diferencial de Alíquota da UF de Origem/Destino”
function fkg_soma_vl_out_cred_difal
         return ajust_apur_icms_difal.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apur_icms_difal.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aai.vl_aj_apur) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apur_icms_difal  aai
        , cod_aj_saldo_apur_icms cod
    where aai.apuricmsdifal_id   = gt_row_apur_icms_difal.id
      and cod.id                 = aai.codajsaldoapuricms_id
      and cod.dm_apur            in (2) -- DIFAL
      and cod.dm_util            in (2,3); -- "2-outros creditos" ou "3-estorno debitos"
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_out_cred_difal:' || sqlerrm);
end fkg_soma_vl_out_cred_difal;

-------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos créditos FCP por Entradas
function fkg_vl_tot_cred_fcp
         return apur_icms_difal.vl_tot_cred_fcp%type
is
   --
   vn_vl_tot_cred_fcp apur_icms_difal.vl_tot_cred_fcp%type := 0;
   vn_vl1             nota_fiscal_total.vl_comb_pobr_uf_dest%type := 0;
   vn_vl2             nota_fiscal_total.vl_comb_pobr_uf_dest%type := 0;
   --
begin
   -- Se o campo 2 – UF do registro E300 for a do registro 0000, este valor sempre será igual a zero
   if gv_sigla_estado_empresa = gv_apur_sigla_estado then
      --
      vn_vl_tot_cred_fcp := 0;
      --
   else
      --  Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_FCP_UF_DEST
      begin
         --
         /* 67653 select sum( nvl(nft.vl_comb_pobr_uf_dest,0) )
           into vn_vl1
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_dest   nfd
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id; */
         select sum( nvl(nft.vl_comb_pobr_uf_dest,0) )
           into vn_vl1
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , nota_fiscal_dest       nfd
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_emit     = 0 -- Emissão Propria
            and nf.dm_ind_oper     = 0 -- Entrada
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfd.notafiscal_id  = nf.id
            and nfd.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id;			
         --
      exception
         when others then
            vn_vl1 := 0;
      end;
      --
      begin
         --
         /* 67653 select sum( nvl(nft.vl_comb_pobr_uf_dest,0) )
           into vn_vl2
           from nota_fiscal        nf
              , mod_fiscal         mf
              , nota_fiscal_emit   nfe
              , nota_fiscal_total  nft
          where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
            and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
            and nf.dm_st_proc      = 4
            and nf.dm_ind_emit     = 1 -- Terceiro
            and nf.dm_ind_oper     = 0 -- Entrada
            --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
            --      or
            --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
            and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
                  or
                 (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfe.notafiscal_id  = nf.id
            and nfe.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id; */
         select sum( nvl(nft.vl_comb_pobr_uf_dest,0) )
           into vn_vl2
           from tmp_nota_fiscal        nf
              , mod_fiscal             mf
              , nota_fiscal_emit       nfe
              , tmp_nota_fiscal_total  nft
          where nf.dm_ind_emit     = 1 -- Terceiro
            and nf.dm_ind_oper     = 0 -- Entrada
            and mf.id              = nf.modfiscal_id
            and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
            and nfe.notafiscal_id  = nf.id
            and nfe.uf             = gv_apur_sigla_estado
            and nft.notafiscal_id  = nf.id;			
         --
      exception
         when others then
            vn_vl2 := 0;
      end;
      --
      vn_vl_tot_cred_fcp := nvl(vn_vl1,0) + nvl(vn_vl2,0);
      --
   end if;
   --
   return nvl(vn_vl_tot_cred_fcp,0);
   --
exception
   when others then
      return 0;
end fkg_vl_tot_cred_fcp;

------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valor total dos ajustes "Deduções ICMS Diferencial de Alíquota da UF de Origem/Destino"
function fkg_soma_vl_deducoes_difal
         return ajust_apur_icms_difal.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apur_icms_difal.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aai.vl_aj_apur) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apur_icms_difal  aai
        , cod_aj_saldo_apur_icms cod
    where aai.apuricmsdifal_id   = gt_row_apur_icms_difal.id
      and cod.id                 = aai.codajsaldoapuricms_id
      and cod.dm_apur            in (2) -- DIFAL
      and cod.dm_util            in (4); -- 4-Deducoes
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_deducoes_difal:' || sqlerrm);
end fkg_soma_vl_deducoes_difal;

------------------------------------------------------------------------------------------------------------------------------------------
-- Função retorna o Valores recolhidos ou a recolher, extraapuração
function fkg_soma_vl_deb_esp_difal
         return ajust_apur_icms_difal.vl_aj_apur%type
is
   --
   vn_vl_aj_apur ajust_apur_icms_difal.vl_aj_apur%type := 0;
   --
begin
   --
   select sum(aai.vl_aj_apur) vl_aj_apur
     into vn_vl_aj_apur
     from ajust_apur_icms_difal  aai
        , cod_aj_saldo_apur_icms cod
    where aai.apuricmsdifal_id   = gt_row_apur_icms_difal.id
      and cod.id                 = aai.codajsaldoapuricms_id
      and cod.dm_apur            in (2) -- DIFAL
      and cod.dm_util            in (5); -- 5-Debitos Especiais
   --
   return vn_vl_aj_apur;
   --
exception
   when no_data_found then
      return 0;
   when others then
      raise_application_error(-20101, 'Erro na fkg_soma_vl_deducoes_difal:' || sqlerrm);
end fkg_soma_vl_deb_esp_difal;

-------------------------------------------------------------------------------------------------------
-- Procedimento limpa os caracteres especiais dos campos de descrição do Bloco E
procedure pkb_limpa_caracteres_bloco_e ( en_apuricmsdifal_id in apur_icms_difal.id%type )
is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   -- Se informou o id da Apuração de ICMS-DIFAL
   if nvl(en_apuricmsdifal_id,0) > 0 then
      --
      vn_fase := 2;
      -- No registro E311
      update ajust_apur_icms_difal s
         set s.descr_compl_aj = trim(pk_csf.fkg_converte(s.descr_compl_aj))
       where s.apuricmsdifal_id = en_apuricmsdifal_id;
      --
      vn_fase := 3;
      -- No registro E230
      update inf_aj_apur_icms_difal c
         set c.descr_proc = trim(pk_csf.fkg_converte(c.descr_proc))
           , c.txt_compl = trim(pk_csf.fkg_converte(c.txt_compl))
       where c.ajustapuricmsdifal_id in ( select distinct a.id
                                            from ajust_apur_icms_difal a
                                           where a.apuricmsdifal_id = en_apuricmsdifal_id );
      --
      vn_fase := 4;
      -- No registro E250
      update obr_rec_apur_icms_difal m
         set m.descr_proc = trim(pk_csf.fkg_converte(m.descr_proc))
           , m.txt_compl  = trim(pk_csf.fkg_converte(m.txt_compl))
       where m.apuricmsdifal_id = en_apuricmsdifal_id;
      --
      vn_fase := 5;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pkb_limpa_caracteres_bloco_e fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => gv_mensagem_log
                                     , ev_resumo          => gv_resumo_log
                                     , en_tipo_log        => ERRO_DE_SISTEMA
                                     , en_referencia_id   => gn_referencia_id
                                     , ev_obj_referencia  => gv_obj_referencia );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_limpa_caracteres_bloco_e;

-------------------------------------------------------------------------------------------------------
-- Procedimento recupera os dados da Apuração de ICMS-DIFAL
procedure pkb_dados_per_apur_icms_difal ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type )
is
begin
   --
   if nvl(en_perapuricmsdifal_id,0) > 0 then
      --
      select *
        into gt_row_per_apur_icms_difal
 	from per_apur_icms_difal
       where id = en_perapuricmsdifal_id;
      --
      gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => gt_row_per_apur_icms_difal.empresa_id );
      --
      gv_formato_data      := pk_csf.fkg_param_global_csf_form_data;
      --
      -- Alterar os valores de datas inicial e final considerando a hora, para evitar o comando TRUNC na recuperação dos valores dos documentos fiscais.
      gt_row_per_apur_icms_difal.dt_inicio := to_date(gt_row_per_apur_icms_difal.dt_inicio,gv_formato_data/*'dd/mm/rrrr'*/);
      gt_row_per_apur_icms_difal.dt_fim    := to_date(gt_row_per_apur_icms_difal.dt_fim,gv_formato_data/*'dd/mm/rrrr'*/);
      --
      begin
         --
         select est.sigla_estado
           into gv_sigla_estado_empresa
           from empresa e
              , pessoa p
              , cidade cid
              , estado est
          where e.id = gt_row_per_apur_icms_difal.empresa_id
            and p.id = e.pessoa_id
            and cid.id = p.cidade_id
            and est.id = cid.estado_id;
         --
      exception
         when others then
            gv_sigla_estado_empresa := null;
      end;
      --
   end if;
   --
end pkb_dados_per_apur_icms_difal;

-------------------------------------------------------------------------------------------------------
-- Procedure recupera os dados da apuração de imposto de ICMS-DIFAL
procedure pkb_dados_apur_icms_difal ( en_apuricmsdifal_id in apur_icms_difal.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   --
   cursor c_apur is
   select * from apur_icms_difal
    where id = en_apuricmsdifal_id;
   --
begin
   --
   vn_fase := 1;
   --
   gt_row_apur_icms_difal := null;
   --
   if nvl(en_apuricmsdifal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      open c_apur;
      fetch c_apur into gt_row_apur_icms_difal;
      close c_apur;
      --
      vn_fase := 3;
      --
      if nvl(gt_row_apur_icms_difal.id,0) > 0 then
         --
         vn_fase := 4;
         -- Sigla do estado da apuração
         gv_apur_sigla_estado := pk_csf.fkg_Estado_id_sigla(gt_row_apur_icms_difal.estado_id);
         --
         vn_fase := 5;
         -- recupera os dados do período para utilizar no processo
         pkb_dados_per_apur_icms_difal ( en_perapuricmsdifal_id => gt_row_apur_icms_difal.perapuricmsdifal_id );
         --
         vn_fase := 6;
         --

         --
         vn_fase := 7;
         --
         gn_referencia_id  := gt_row_apur_icms_difal.id;
         gv_obj_referencia := 'APUR_ICMS_DIFAL';
         -- Monta mensagem para o log da Apuração de ICMS-ST
         if nvl(gn_dm_dt_escr_dfepoe,0) = 0 then -- 0-data de emissão
            --
            gv_mensagem_log := 'Apuração de ICMS-DIFAL com Data Inicial '||to_char(gt_row_per_apur_icms_difal.dt_inicio, gv_formato_data /*'dd/mm/rrrr'*/)||' até Data Final '||
                               to_char(gt_row_per_apur_icms_difal.dt_fim,gv_formato_data /*'dd/mm/rrrr'*/)||'. Data que será considerada para recuperar os documentos fiscais de '||
                               'emissão própria com operação de entrada: Data de emissão.';
            --
         else -- nvl(gn_dm_dt_escr_dfepoe,0) = 1 -- 1-data de entrada/saída
            --
            gv_mensagem_log := 'Apuração de ICMS-DIFAL com Data Inicial '||to_char(gt_row_per_apur_icms_difal.dt_inicio,gv_formato_data /*'dd/mm/rrrr'*/)||' até Data Final '||
                               to_char(gt_row_per_apur_icms_difal.dt_fim,gv_formato_data /*'dd/mm/rrrr'*/)||'. Data que será considerada para recuperar os documentos fiscais de '||
                               'emissão própria com operação de entrada: Data da entrada/saída.';
            --
         end if;
         --
      else
         --
         vn_fase := 8;
         --
         gn_referencia_id := null;
         gv_obj_referencia := null;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_dados_apur_icms_difal fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => en_apuricmsdifal_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_dados_apur_icms_difal;

-----------------------------------------------------------------------------------------------------------
-- Valida os dados a Apuração de ICMS-DIFAL - Considerar o leiaute do Registro E300 a partir de 01/01/2017
procedure pkb_valida_apartir_01012017 ( est_log_generico in out nocopy  dbms_sql.number_table )
is
   --
   vn_fase                        number := 0;
   vn_loggenerico_id              log_generico.id%type;
   --
   vn_vl_sld_cred_ant_difal    apur_icms_difal.vl_sld_cred_ant_difal%type;
   vn_vl_tot_debitos_difal     apur_icms_difal.vl_tot_debitos_difal%type;
   vn_vl_out_deb_difal         apur_icms_difal.vl_out_deb_difal%type;
   vn_vl_tot_deb_fcp           apur_icms_difal.vl_tot_deb_fcp%type;
   vn_vl_tot_creditos_difal    apur_icms_difal.vl_tot_creditos_difal%type;
   vn_vl_tot_cred_fcp          apur_icms_difal.vl_tot_cred_fcp%type;
   vn_vl_out_cred_difal        apur_icms_difal.vl_out_cred_difal%type;
   vn_vl_sld_dev_ant_difal     apur_icms_difal.vl_sld_dev_ant_difal%type;
   vn_vl_deducoes_difal        apur_icms_difal.vl_deducoes_difal%type;
   vn_vl_recol                 apur_icms_difal.vl_recol%type;
   vn_vl_sld_cred_transportar  apur_icms_difal.vl_sld_cred_transportar%type;
   vn_vl_deb_esp_difal         apur_icms_difal.vl_deb_esp_difal%type;
   vn_vl_sld_cred_ant_fcp      apur_icms_difal.vl_sld_cred_ant_fcp%type;
   vn_vl_out_deb_fcp           ajust_apur_icms_difal.vl_aj_apur%type;
   vn_vl_out_cred_fcp          ajust_apur_icms_difal.vl_aj_apur%type;
   -- 
   vn_vl_sld_dev_ant_fcp       number := 0;
   --
   vn_vl_deducoes_fcp          ajust_apur_icms_difal.vl_aj_apur%type;
   --
   vn_vl_recol_fcp             number := 0;
   vn_vl_sld_cred_transportar_fcp number := 0;
   --
   vn_vl_deb_esp_fcp          ajust_apur_icms_difal.vl_aj_apur%type;
   vn_vl_or                   obr_rec_apur_icms_difal.vl_or%type;
   --
   cursor c_or is
   select ord.id
        , ord.apuricmsdifal_id
        , ord.ajobrigrec_id
        , aor.cd     aj_obrig_rec_cd
        , aor.descr  aj_obrig_rec_descr
        , ord.vl_or
        , ord.dt_vcto
        , cur.cod_rec
        , ord.num_proc
        , ord.origproc_id
        , op.cd      orig_proc_cd
        , op.descr   orig_proc_descr
        , ord.descr_proc
        , ord.txt_compl
        , ord.mes_ref
        , ord.ajobrigrecestado_id
     from obr_rec_apur_icms_difal ord
        , aj_obrig_rec aor
        , orig_proc op
        , cod_rec_uf   cur
    where ord.apuricmsdifal_id  = gt_row_apur_icms_difal.id
      and aor.id                = ord.ajobrigrec_id
      and op.id(+)              = ord.origproc_id
      and cur.id             (+)= ord.codrecuf_id
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gt_row_per_apur_icms_difal.empresa_id, 0) > 0
      and trunc(gt_row_per_apur_icms_difal.dt_inicio) is not null
      and trunc(gt_row_per_apur_icms_difal.dt_fim) is not null then
      --
      vn_fase := 2;
      -- Campo 03 (VL_SLD_CRED_ANT_DIFAL) – Preenchimento: Valor do campo VL_SLD_CRED_TRANSPORTAR  do período de apuração anterior.
      vn_vl_sld_cred_ant_difal := fkg_saldo_credor_ant_difal;
      --
      vn_fase := 2.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_difal,0) <> nvl(vn_vl_sld_cred_ant_difal,0) then
         --
         vn_fase := 2.2;
         --
         gv_resumo_log := 'O "Valor do Saldo credor de período anterior – ICMS Diferencial de Alíquota da UF de Origem/Destino" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_difal,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Valor '||
                          'do Saldo credor de período anterior" ('||trim(to_char(nvl(vn_vl_sld_cred_ant_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 3;
      /*
      Campo 04 (VL_TOT_DEBITOS_DIFAL) - Validação: somatório de todos os valores do C101 e D101, cujos registros pai C100 e D100
      tenham IND_OPER = 1 (Saída), exceto aqueles cujos C100 e D100 utilizarem os COD_SIT 01 ou 07. Se o campo 2 – UF do registro E300
      for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_REM. Se o campo 2 – UF do registro E300 for a do
      destinatário, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
      */
      vn_vl_tot_debitos_difal := fkg_vl_tot_debitos_difal;
      --
      vn_fase := 3.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0) <> nvl(vn_vl_tot_debitos_difal,0) then
         --
         vn_fase := 3.2;
         --
         gv_resumo_log := 'O "Valor total dos débitos por Saídas e prestações com débito do ICMS referente ao diferencial de alíquota devido à UF de Origem/'||
                          'Destino" na Apuração do ICMS-DIFAL ('||trim(to_char(nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0),'9999G999G999G990D00'))||
                          ') está divergente do "Cálculo do Valor total dos débitos por Saídas e prestações com débito do ICMS" ('||
                          trim(to_char(nvl(vn_vl_tot_debitos_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 4;
      /*
      Campo 05 (VL_OUT_DEB_DIFAL) – Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311,
      quando o terceiro caractere for igual a ‘2’ e o quarto for igual a ‘0’ ou ‘1’, ambos do campo COD_AJ_APUR do registro E311.
      */
      vn_vl_out_deb_difal := fkg_soma_vl_out_deb_difal;
      --
      vn_fase := 4.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0) <> nvl(vn_vl_out_deb_difal,0) then
         --
         vn_fase := 4.2;
         --
         gv_resumo_log := 'O "Valor total dos ajustes Outros débitos ICMS Diferencial de Alíquota da UF de Origem/Destino e Estorno de créditos ICMS '||
                          'Diferencial de Alíquota da UF de Origem/Destino" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Valor total '||
                          'dos ajustes Outros débitos ICMS Diferencial de Alíquota da UF de Origem/Destino e Estorno de créditos ICMS Diferencial de '||
                          'Alíquota" ('||trim(to_char(nvl(vn_vl_out_deb_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 5;
      /*
      Campo 06 (VL_TOT_CREDITOS_DIFAL) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada).
      Se o campo 2 – UF do registro E300 for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
      Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_ICMS_UF_REM.
      */
      vn_vl_tot_creditos_difal := fkg_vl_tot_creditos_difal;
      --
      vn_fase := 5.1;

      if nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0) <> nvl(vn_vl_tot_creditos_difal,0) then
         --
         vn_fase := 5.2;
         --
         gv_resumo_log := 'O "Valor total dos créditos do ICMS referente ao diferencial de alíquota devido à UF de Origem/Destino" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Valor '||
                          'total dos créditos do ICMS referente ao diferencial de alíquota devido" ('||
                          trim(to_char(nvl(vn_vl_tot_creditos_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 6;
      /*
      Campo 07 (VL_OUT_CRED_DIFAL) - Validação:  o valor informado deve corresponder ao somatório do campo VL_AJ_APUR dos registros E311,
      quando o terceiro caractere for igual a ‘2’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘2’ ou ‘3’.
      */
      vn_vl_out_cred_difal := fkg_soma_vl_out_cred_difal;
      --
      vn_fase := 6.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0) <> nvl(vn_vl_out_cred_difal,0) then
         --
         vn_fase := 6.2;
         --
         gv_resumo_log := 'O "Valor total de Ajustes Outros créditos ICMS Diferencial de Alíquota da UF de Origem/Destino e Estorno de débitos ICMS Diferencial '||
                          'de Alíquota da UF de Origem/Destino" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Valor '||
                          'de Ajustes Outros créditos ICMS Diferencial de Alíquota da UF de Origem/Destino e Estorno de débitos ICMS Diferencial de Alíquota" ('||
                          trim(to_char(nvl(vn_vl_out_cred_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 7;
      /*
      Campo 08 (VL_SLD_DEV_ANT_DIFAL) - Validação: Se (VL_TOT_DEBITOS_DIFAL + VL_OUT_DEB_DIFAL) menos (VL_SLD_CRED_ANT_DIFAL + VL_TOT_CREDITOS_DIFAL +
      VL_OUT_CRED_DIFAL), for maior ou igual a ZERO, então o resultado deverá ser igual ao VL_SLD_DEV_ANT_DIFAL; senão VL_SLD_DEV_ANT_DIFAL deve ser igual a ZERO.
      */
      vn_vl_sld_dev_ant_difal := ( nvl(vn_vl_tot_debitos_difal,0) + nvl(vn_vl_out_deb_difal,0) ) -
                                 ( nvl(vn_vl_sld_cred_ant_difal,0) + nvl(vn_vl_tot_creditos_difal,0) + nvl(vn_vl_out_cred_difal,0) );
      --
      vn_fase := 7.1;
      --
      if nvl(vn_vl_sld_dev_ant_difal,0) <= 0 then
         vn_vl_sld_dev_ant_difal := 0;
      end if;
      --
      vn_fase := 7.2;
      --
      if nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0) <> nvl(vn_vl_sld_dev_ant_difal,0) then
         --
         vn_fase := 7.3;
         --
         gv_resumo_log := 'O "Valor total de Saldo devedor ICMS Diferencial de Alíquota da UF de Origem/Destino antes das deduções" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Valor '||
                          'de Saldo devedor ICMS Diferencial de Alíquota da UF de Origem/Destino antes das deduções" ('||
                          trim(to_char(nvl(vn_vl_sld_dev_ant_difal,0),'9999G999G999G990D00'))||'). Valor composto pela soma dos campos: "Valor total dos débitos '||
                          'por Saídas e prestações com débito do ICMS referente ao diferencial de alíquota" (mais) "Valor total dos ajustes Outros débitos ICMS '||
                          'Diferencial e Estorno de créditos ICMS Diferencial de Alíquota"; e subtraindo da soma dos campos: "Valor do Saldo credor de período '||
                          'anterior – ICMS Diferencial de Alíquota" (mais) "Valor total dos créditos do ICMS referente ao diferencial de alíquota devido", (mais), '||
                          '"Valor total de Ajustes Outros créditos ICMS Diferencial de Alíquota e Estorno de débitos ICMS Diferencial de Alíquota".';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 8;
      /*
      Campo 09 (VL_DEDUÇÕES_DIFAL) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311, por UF,
      quando o terceiro caractere for igual a ‘2’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘4’.
      */
      vn_vl_deducoes_difal := fkg_soma_vl_deducoes_difal;
      --
      vn_fase := 8.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_deducoes_difal,0) <> nvl(vn_vl_deducoes_difal,0) then
         --
         vn_fase := 8.2;
         --
         gv_resumo_log := 'O "Valor total dos ajustes Deduções ICMS Diferencial de Alíquota da UF de Origem/Destino" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_deducoes_difal,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Valor '||
                          'dos ajustes Deduções ICMS Diferencial de Alíquota" ('||trim(to_char(nvl(vn_vl_deducoes_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 9;
      /*
      Campo 10 (VL_RECOL_DIFAL) - Validação: Se (VL_SLD_DEV_ANT_DIFAL menos VL_DEDUCOES_DIFAL) for maior ou igual a ZERO,
      então VL_RECOL é igual ao resultado da equação; senão o VL_RECOL deverá ser igual a ZERO.
      VL_RECOL_DIFAL + DEB_ESP_DIFAL + VL_RECOL_FCP + DEB_ESP_FCP = soma do campo VL_OR (E316).
      */
      vn_vl_recol := nvl(vn_vl_sld_dev_ant_difal,0) - nvl(vn_vl_deducoes_difal,0);
      --
      vn_fase := 9.1;
      --
      if nvl(vn_vl_recol,0) <= 0 then
         vn_vl_recol := 0;
      end if;
      --
      vn_fase := 9.2;
      --
      if nvl(gt_row_apur_icms_difal.vl_recol,0) <> nvl(vn_vl_recol,0) then
         --
         vn_fase := 9.3;
         --
         gv_resumo_log := 'O "Valor recolhido ou a recolher referente ao ICMS Diferencial de Alíquota da UF de Origem/Destino" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_recol,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do Valor '||
                          'recolhido ou a recolher referente ao ICMS Diferencial de Alíquota" ('||trim(to_char(nvl(vn_vl_recol,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 10;
      /*
      Campo 11 (VL_SLD_CRED_TRANSPORTAR_DIFAL) – Validação: Se (VL_SLD_CRED_ANT_DIFAL + VL_TOT_CREDITOS_DIFAL + VL_OUT_CRED_DIFAL) menos (VL_TOT_DEBITOS_DIFAL +
      VL_OUT_DEB_DIFAL) for maior que ZERO, então VL_SLD_CRED_TRANSPORTAR_DIFAL deve ser igual ao resultado da equação; senão VL_SLD_CRED_TRANSPORTAR_DIFAL será
      ZERO.
      */
      vn_vl_sld_cred_transportar := ( nvl(vn_vl_sld_dev_ant_difal,0) + nvl(vn_vl_tot_creditos_difal,0) + nvl(vn_vl_out_cred_difal,0) ) -
                                    ( nvl(vn_vl_tot_debitos_difal,0) + nvl(vn_vl_out_deb_difal,0) );
      --
      vn_fase := 10.1;
      --
      if nvl(vn_vl_sld_cred_transportar,0) <= 0 then
         vn_vl_sld_cred_transportar := 0;
      end if;
      --
      vn_fase := 10.2;
      --
      if nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar,0) <> nvl(vn_vl_sld_cred_transportar,0) then
         --
         vn_fase := 10.3;
         --
         gv_resumo_log := 'O "Saldo credor a transportar para o período seguinte referente ao ICMS Diferencial de Alíquota da UF de Origem/Destino" na Apuração '||
                          'do ICMS-DIFAL ('||trim(to_char(nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar,0),'9999G999G999G990D00'))||') está divergente do '||
                          '"Cálculo do Valor credor a transportar para o período seguinte referente ao ICMS Diferencial de Alíquota" ('||
                          trim(to_char(nvl(vn_vl_sld_cred_transportar,0),'9999G999G999G990D00'))||'). Valor composto pela soma dos campos: "Valor do Saldo '||
                          'credor de período anterior – ICMS Diferencial de Alíquota" (mais) "Valor total dos débitos por Saídas e prestações com débito do '||
                          'ICMS referente ao diferencial de alíquota" (mais) "Valor total de Ajustes Outros créditos ICMS Diferencial de Alíquota e Estorno '||
                          'de débitos ICMS Diferencial de Alíquota"; e subtraindo da soma dos campos: "Valor total dos débitos por Saídas e prestações com '||
                          'débito do ICMS referente ao diferencial de alíquota" (mais) "Valor total dos ajustes Outros débitos ICMS Diferencial de Alíquota e '||
                          'Estorno de créditos ICMS Diferencial de Alíquota".';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 11;
      /*
      Campo 12 (DEB_ESP_DIFAL) – Validação: Informar por UF:
      Somatório dos campos VL_AJ_APUR dos registros E311, se o campo COD_AJ_APUR  possuir o terceiro caractere do código informado no registro E311 igual a “2” e o
      quarto caractere for igual a “5".
      */
      vn_vl_deb_esp_difal := fkg_soma_vl_deb_esp_difal;
      --
      vn_fase := 11.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0) <> nvl(vn_vl_deb_esp_difal,0) then
         --
         vn_fase := 11.2;
         --
         gv_resumo_log := 'O "Valores recolhidos ou a recolher, extra-apuração - ICMS Diferencial de Alíquota da UF de Origem/Destino" na Apuração '||
                          'do ICMS-DIFAL ('||trim(to_char(nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0),'9999G999G999G990D00'))||') está divergente do '||
                          '"Cálculo do Valor recolhido ou a recolher, extra-apuração - ICMS Diferencial de Alíquota" ('||
                          trim(to_char(nvl(vn_vl_deb_esp_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 12;
      /*
      Campo 13 (VL_SLD_CRED_ANT_FCP) – Validação: Valor do campo VL_SLD_CRED_TRANSPORTAR_FCP do período de apuração anterior.
      */
      vn_vl_sld_cred_ant_fcp := fkg_saldo_credor_ant_fcp;
      --
      vn_fase := 12.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_fcp,0) <> nvl(vn_vl_sld_cred_ant_fcp,0) then
         --
         vn_fase := 12.2;
         --
         gv_resumo_log := 'O "Valor do Saldo credor de período anterior – FCP" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_fcp,0),'9999G999G999G990D00'))||') está divergente do '||
                          '"Cálculo do Saldo credor de período anterior – FCP" ('||trim(to_char(nvl(vn_vl_sld_cred_ant_fcp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 13;
      /*
      Campo 14 (VL_TOT_DEB_FCP) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 1 (Saída),
      exceto aqueles cujos C100 e D100 utilizarem os COD_SIT 01 ou 07. Se o campo 2 – UF do registro E300 for a do registro 0000, este valor será zero.
      Se o campo 2 – UF do registro E300 for a do destinatário, então corresponde à somatória dos campos VL_FCP_UF_DEST.
      */
      vn_vl_tot_deb_fcp := fkg_vl_tot_deb_fcp;
      --
      vn_fase := 13.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0) <> nvl(vn_vl_tot_deb_fcp,0) then
         --
         vn_fase := 13.2;
         --
         gv_resumo_log := 'O "Valor total dos débitos FCP por Saídas e Prestações" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0),'9999G999G999G990D00'))||') está divergente do '||
                          '"Cálculo do total dos débitos FCP por Saídas e Prestações" ('||trim(to_char(nvl(vn_vl_tot_deb_fcp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 14;
      /*
      Campo 15 (VL_OUT_DEB_FCP) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311, quando o terceiro caractere
      for igual a ‘3’ e o quarto for igual a ‘0’ ou ‘1’, ambos do campo COD_AJ_APUR do registro E311.
      */
      vn_vl_out_deb_fcp := fkg_soma_vl_out_deb_fcp;
      --
      vn_fase := 14.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_out_deb_fcp,0) <> nvl(vn_vl_out_deb_fcp,0) then
         --
         vn_fase := 14.2;
         --
         gv_resumo_log := 'O "Valor total dos ajustes Outros débitos FCP e Estorno de créditos FCP" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_out_deb_fcp,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do total dos '||
                          'ajustes Outros débitos FCP e Estorno de créditos FCP" ('||trim(to_char(nvl(vn_vl_out_deb_fcp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 15;
      /*
      Campo 16 (VL_TOT_CRED_FCP) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada).
      Se o campo 2 – UF do registro E300 for a do registro 0000, este valor sempre será igual a zero.
      Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_FCP_UF_DEST.
      */
      vn_vl_tot_cred_fcp := fkg_vl_tot_cred_fcp;
      --
      vn_fase := 15.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0) <> nvl(vn_vl_tot_cred_fcp,0) then
         --
         vn_fase := 15.2;
         --
         gv_resumo_log := 'O "Valor total dos créditos FCP por Entradas" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do total dos '||
                          'créditos FCP por Entradas" ('||trim(to_char(nvl(vn_vl_tot_cred_fcp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 16;
      /*
      Campo 17 (VL_OUT_CRED_FCP) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR dos registros E311, quando o terceiro
      caractere for igual a ‘3’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘2’ ou ‘3’.
      */
      vn_vl_out_cred_fcp := fkg_soma_vl_out_cred_fcp;
      --
      vn_fase := 16.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_out_cred_fcp,0) <> nvl(vn_vl_out_cred_fcp,0) then
         --
         vn_fase := 16.2;
         --
         gv_resumo_log := 'O "Valor total de Ajustes Outros créditos FCP e Estorno de débitos FCP" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_out_cred_fcp,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do total dos '||
                          'Ajustes Outros créditos FCP e Estorno de débitos FCP" ('||trim(to_char(nvl(vn_vl_out_cred_fcp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 17;
      /*
      Campo 18 (VL_SLD_DEV_ANT_FCP) - Validação: Se (VL_TOT_DEB_FCP + VL_OUT_DEB_FCP) menos (VL_SLD_CRED_ANT_FCP + VL_TOT_CRED_FCP + VL_OUT_CRED_FCP) for maior ou
      igual a ZERO, então o resultado deverá ser igual ao VL_SLD_DEV_ANT_FCP; senão VL_SLD_DEV_ANT_FCP deve ser igual a ZERO.
      */
      vn_vl_sld_dev_ant_fcp := ( (nvl(vn_vl_tot_deb_fcp,0) + nvl(vn_vl_out_deb_fcp,0) ) -
                                 (nvl(vn_vl_sld_cred_ant_fcp,0) + nvl(vn_vl_tot_cred_fcp,0) + nvl(vn_vl_out_cred_fcp,0)) );
      --
      vn_fase := 17.1;
      --
      if nvl(vn_vl_sld_dev_ant_fcp,0) <= 0 then
         vn_vl_sld_dev_ant_fcp := 0;
      end if;
      --
      vn_fase := 17.2;
      --
      if nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_fcp,0) <> nvl(vn_vl_sld_dev_ant_fcp,0) then
         --
         vn_fase := 17.3;
         --
         gv_resumo_log := 'O "Valor total de Saldo devedor FCP antes das deduções" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_fcp,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do total de '||
                          'Saldo devedor FCP antes das deduções" ('||trim(to_char(nvl(vn_vl_sld_dev_ant_fcp,0),'9999G999G999G990D00'))||'). Valor composto pela '||
                          'soma dos campos: "Valor total dos débitos FCP por Saídas e prestações" (mais) "Valor total dos ajustes Outros débitos FCP e Estorno '||
                          'de créditos FCP"; e subtraindo pela soma dos campos: "Valor do Saldo credor de período anterior – FCP" (mais) "Valor total dos '||
                          'créditos FCP por Entradas" (mais) "Valor total de Ajustes Outros créditos FCP" e Estorno de débitos FCP".';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 18;
      /*
      Campo 19 (VL_DEDUÇÕES_FCP) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311, por UF, quando o terceiro
      caractere for igual a ‘3’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘4’.
      */
      vn_vl_deducoes_fcp := fkg_soma_vl_deducoes_fcp;
      --
      vn_fase := 18.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_deducoes_fcp,0) <> nvl(vn_vl_deducoes_fcp,0) then
         --
         vn_fase := 18.2;
         --
         gv_resumo_log := 'O "Valor total das deduções FCP" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_deducoes_fcp,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do total das '||
                          'deduções FCP" ('||trim(to_char(nvl(vn_vl_deducoes_fcp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 19;
      /*
      Campo 20 (VL_RECOL_FCP) - Validação: Se (VL_SLD_DEV_ANT_FCP menos VL_DEDUCOES_FCP) for maior ou igual a ZERO, então VL_RECOL_FCP é igual ao resultado da
      equação; senão o VL_RECOL_FCP deverá ser igual a ZERO.
      */
      vn_vl_recol_fcp := ( nvl(vn_vl_sld_dev_ant_fcp,0) - nvl(vn_vl_deducoes_fcp,0) );
      --
      vn_fase := 19.1;
      --
      if nvl(vn_vl_recol_fcp,0) <= 0 then
         vn_vl_recol_fcp := 0;
      end if;
      --
      vn_fase := 19.2;
      --
      if nvl(gt_row_apur_icms_difal.vl_recol_fcp,0) <> nvl(vn_vl_recol_fcp,0) then
         --
         vn_fase := 19.3;
         --
         gv_resumo_log := 'O "Valor recolhido ou a recolher referente ao FCP" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_deducoes_fcp,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do total do '||
                          'valor recolhido ou a recolher referente ao FCP" ('||trim(to_char(nvl(vn_vl_recol_fcp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 20;
      /*
      Campo 21 (VL_SLD_CRED_TRANSPORTAR_FCP) – Validação: Se (VL_SLD_CRED_ANT_FCP + VL_TOT_CRED_FCP + VL_OUT_CRED_FCP) menos (VL_TOT_DEB_FCP + VL_OUT_DEB_FCP)
      for maior que ZERO, então VL_SLD_CRED_TRANSPORTAR_FCP deve ser igual ao resultado da equação; senão VL_SLD_CRED_TRANSPORTAR_FCP será ZERO.
      */
      vn_vl_sld_cred_transportar_fcp := ( (nvl(vn_vl_sld_cred_ant_fcp,0) + nvl(vn_vl_tot_cred_fcp,0) + nvl(vn_vl_out_cred_fcp,0)) -
                                          (nvl(vn_vl_tot_deb_fcp,0) + nvl(vn_vl_out_deb_fcp,0)) );
      --
      vn_fase := 20.1;
      --
      if nvl(vn_vl_sld_cred_transportar_fcp,0) <= 0 then
         vn_vl_sld_cred_transportar_fcp := 0;
      end if;
      --
      vn_fase := 20.2;
      --
      if nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar_fcp,0) <> nvl(vn_vl_sld_cred_transportar_fcp,0) then
         --
         vn_fase := 20.3;
         --
         gv_resumo_log := 'O "Saldo credor a transportar para o período seguinte referente ao FCP" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_deducoes_fcp,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do total credor a '||
                          'transportar para o período seguinte referente ao FCP" ('||trim(to_char(nvl(vn_vl_sld_cred_transportar_fcp,0),'9999G999G999G990D00'))||
                          '). Valor composto pela soma dos campos: Valor do "Saldo credor de período anterior – FCP" (mais) "Valor total dos créditos FCP por '||
                          'Entradas" (mais) "Valor total de Ajustes Outros créditos FCP e Estorno de débitos FCP"; e subtraindo pela soma dos campos: "Valor '||
                          'total dos débitos FCP por Saídas e prestações" (mais) "Valor total dos ajustes Outros débitos FCP e Estorno de créditos FCP".';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 21;
      /*
      Campo 22 (DEB_ESP_FCP) – Validação: Somatório dos campos VL_AJ_APUR dos registros E311, se o campo COD_AJ_APUR possuir o terceiro caractere do código
      informado no registro E311 igual a “3” e o quarto caractere for igual a “5".
      */
      vn_vl_deb_esp_fcp := fkg_soma_vl_deb_esp_fcp;
      --
      vn_fase := 21.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_deb_esp_fcp,0) <> nvl(vn_vl_deb_esp_fcp,0) then
         --
         vn_fase := 21.2;
         --
         gv_resumo_log := 'O "Valores recolhidos ou a recolher, extra-apuração - FCP" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_deb_esp_fcp,0),'9999G999G999G990D00'))||') está divergente do "Cálculo do valor '||
                          'recolhido ou a recolher, extra-apuração - FCP" ('||trim(to_char(nvl(vn_vl_deb_esp_fcp,0),'9999G999G999G990D00'))||'.';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_validacao
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 22;
      -- Busca o valor da obrigação a recolher
      begin
         --
         select sum(oa.vl_or)
           into vn_vl_or
           from obr_rec_apur_icms_difal oa
          where oa.apuricmsdifal_id = gt_row_apur_icms_difal.id;
         --
      exception
         when others then
            vn_vl_or := 0;
      end;
      --
      vn_fase := 22.1;
      -- Validação: Verifica se as obrigações de imposto a recolher foram lançadas corretamente com o valor de icms a recolher na apuração de icms.
      -- VL_RECOL_DIFAL + DEB_ESP_DIFAL + VL_RECOL_FCP + DEB_ESP_FCP
      if ( nvl(gt_row_apur_icms_difal.vl_recol,0) + nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0) + 
           nvl(gt_row_apur_icms_difal.vl_recol_fcp,0) + nvl(gt_row_apur_icms_difal.vl_deb_esp_fcp,0) ) <> nvl(vn_vl_or,0)
         then
         --
         vn_fase := 22.2;
         --
         gv_resumo_log := 'O "Valor da Obrigação a recolher" em Obrigações de ICMS-DIFAL a Recolher ('||trim(to_char(nvl(vn_vl_or,0),'9999G999G999G990D00'))||
                          ') está divergente do cálculo: "Valor recolhido ou a recolher referente ao Imposto do DIFAL" mais(+) "Valor recolhidos ou a '||
                          'recolher, extra-apuração - DIFAL" mais(+) "Valor recolhido ou a recolher referente a FCP" mais(+) "Valores recolhidos ou a '||
                          'recolher, extra-apuração - FCP", na Apuração de ICMS-DIFAL ('||trim(to_char((nvl(gt_row_apur_icms_difal.vl_recol,0) + 
                          nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0) + nvl(gt_row_apur_icms_difal.vl_recol_fcp,0) + 
                          nvl(gt_row_apur_icms_difal.vl_deb_esp_fcp,0)),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 23;
      -- Valida informações de Obrigação a recolher
      for rec_or in c_or loop
         exit when c_or%notfound or (c_or%notfound) is null;
         --
         vn_fase := 23.1;
         -- Valida Número do processo
         if rec_or.num_proc is not null
            and ( rec_or.origproc_id is null or rec_or.descr_proc is null )
            then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', Informações de Processo preenchidas de forma errada e/ou incompletas.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
         vn_fase := 23.2;
         -- Valida Origem do Processo
         if rec_or.origproc_id is not null
            and ( rec_or.num_proc is null or rec_or.descr_proc is null )
            then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', Informações de Processo preenchidas de forma errada e/ou incompletas.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
         vn_fase := 23.3;
         -- Valida Origem do Processo
         if rec_or.descr_proc is not null
            and ( rec_or.num_proc is null or rec_or.origproc_id is null )
            then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', Informações de Processo preenchidas de forma errada e/ou incompletas.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
         vn_fase := 23.4;
         -- Valida Informação de Mês e Ano de Referencia
         if length(rec_or.mes_ref) <> 6 then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', formato inválido do "Mês/Ano de Referencia" (' || rec_or.mes_ref || '). Correto MMRRRRR (Mês + Ano), exemplo: 012015.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
         vn_fase := 23.5;
         --
         if length(rec_or.mes_ref) = 6
            and to_number(substr(rec_or.mes_ref, 1, 2)) not between 1 and 12
            then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', o "Mês de Referencia" (' || substr(rec_or.mes_ref, 1, 2) || ') esta inválido.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
      end loop;
      --
      vn_fase := 24;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms_difal.pkb_valida_apartir_01012017 fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => erro_de_sistema
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_valida_apartir_01012017;

-------------------------------------------------------------------------------------------------------
-- Valida os dados a Apuração de ICMS-DIFAL - Considerar o leiaute do Registro E300 até 31/12/2016
procedure pkb_valida_ate_31122016 ( est_log_generico in out nocopy  dbms_sql.number_table )
is
   --
   vn_fase                    number := 0;
   vn_loggenerico_id          log_generico.id%type;
   --
   vn_vl_sld_cred_ant_difal    apur_icms_difal.vl_sld_cred_ant_difal%type;
   vn_vl_tot_debitos_difal     apur_icms_difal.vl_tot_debitos_difal%type;
   vn_vl_out_deb_difal         apur_icms_difal.vl_out_deb_difal%type;
   vn_vl_tot_deb_fcp           apur_icms_difal.vl_tot_deb_fcp%type;
   vn_vl_tot_creditos_difal    apur_icms_difal.vl_tot_creditos_difal%type;
   vn_vl_tot_cred_fcp          apur_icms_difal.vl_tot_cred_fcp%type;
   vn_vl_out_cred_difal        apur_icms_difal.vl_out_cred_difal%type;
   vn_vl_sld_dev_ant_difal     apur_icms_difal.vl_sld_dev_ant_difal%type;
   vn_vl_deducoes_difal        apur_icms_difal.vl_deducoes_difal%type;
   vn_vl_recol                 apur_icms_difal.vl_recol%type;
   vn_vl_sld_cred_transportar  apur_icms_difal.vl_sld_cred_transportar%type;
   vn_vl_deb_esp_difal         apur_icms_difal.vl_deb_esp_difal%type;
   --
   vn_vl_or                    obr_rec_apur_icms_difal.vl_or%type       := 0;
   --
   cursor c_or is
   select ord.id
        , ord.apuricmsdifal_id
        , ord.ajobrigrec_id
        , aor.cd     aj_obrig_rec_cd
        , aor.descr  aj_obrig_rec_descr
        , ord.vl_or
        , ord.dt_vcto
        , cur.cod_rec
        , ord.num_proc
        , ord.origproc_id
        , op.cd      orig_proc_cd
        , op.descr   orig_proc_descr
        , ord.descr_proc
        , ord.txt_compl
        , ord.mes_ref
        , ord.ajobrigrecestado_id
     from obr_rec_apur_icms_difal ord
        , aj_obrig_rec aor
        , orig_proc op
        , cod_rec_uf   cur 
    where ord.apuricmsdifal_id  = gt_row_apur_icms_difal.id
      and aor.id                = ord.ajobrigrec_id
      and op.id(+)              = ord.origproc_id
      and cur.id             (+)= ord.codrecuf_id
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(gt_row_per_apur_icms_difal.empresa_id, 0) > 0
      and trunc(gt_row_per_apur_icms_difal.dt_inicio) is not null
      and trunc(gt_row_per_apur_icms_difal.dt_fim) is not null then
      --
      vn_fase := 2;
      -- Campo 03 (VL_SLD_CRED_ANT_DIFAL) – Preenchimento: Valor do campo VL_SLD_CRED_TRANSPORTAR  do período de apuração anterior.
      vn_vl_sld_cred_ant_difal := fkg_saldo_credor_ant_difal;
      --
      vn_fase := 2.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_difal,0) <> nvl(vn_vl_sld_cred_ant_difal,0) then
         --
         vn_fase := 2.2;
         --
         gv_resumo_log := 'O "Valor do Saldo credor de período anterior – ICMS Diferencial de Alíquota da UF de Origem/Destino" na Apuração do ICMS-DIFAL ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_difal,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor do Saldo credor de período anterior" ('||trim(to_char(nvl(vn_vl_sld_cred_ant_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 3;
      --
      /*
      Campo 04 (VL_TOT_DEBITOS_DIFAL) - Validação: somatório de todos os valores do C101 e D101, cujos registros pai C100 e D100
      tenham IND_OPER = 1 (Saída), exceto aqueles cujos C100 e D100 utilizarem os COD_SIT 01 ou 07. Se o campo 2 – UF do registro E300
      for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_REM. Se o campo 2 – UF do registro E300 for a do
      destinatário, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
      */
      vn_vl_tot_debitos_difal := fkg_vl_tot_debitos_difal;
      --
      vn_fase := 3.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0) <> nvl(vn_vl_tot_debitos_difal,0) then
         --
         vn_fase := 3.2;
         --
         gv_resumo_log := 'O "Valor total dos débitos por Saídas e prestações com débito do ICMS referente ao diferencial de alíquota devido à UF do Remetente/Destinatário" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor total dos débitos por Saídas e prestações com débito do ICMS" ('
                          ||trim(to_char(nvl(vn_vl_tot_debitos_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 4;
      /*
      Campo 05 (VL_OUT_DEB_DIFAL) – Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311,
      quando o terceiro caractere for igual a ‘2’ e o quarto for igual a ‘0’ ou ‘1’, ambos do campo COD_AJ_APUR do registro E311.
      */
      vn_vl_out_deb_difal := fkg_soma_vl_out_deb_difal;
      --
      vn_fase := 4.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0) <> nvl(vn_vl_out_deb_difal,0) then
         --
         vn_fase := 4.2;
         --
         gv_resumo_log := 'O "Valor Total dos ajustes Outros débitos ICMS Diferencial de Alíquota da UF de Origem/Destino e Estorno de créditos ICMS Diferencial de Alíquota da UF de Origem/Destino" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor Total dos ajustes Outros débitos e Estorno de créditos ICMS" ('
                          ||trim(to_char(nvl(vn_vl_out_deb_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico 
                                             );
         --
      end if;
      --
      vn_fase := 5;
      --
      /*
      Campo 06 (VL_TOT_DEB_FCP) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 1 (Saída), 
      exceto aqueles cujos C100 e D100 utilizarem os COD_SIT 01 ou 07. Se o campo 2 – UF do registro E300 for a do registro 0000, este valor será zero. 
      Se o campo 2 – UF do registro E300 for a do destinatário, então corresponde à somatória dos campos VL_FCP_UF_DEST.
      */
      vn_vl_tot_deb_fcp := fkg_vl_tot_deb_fcp;
      --
      vn_fase := 5.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0) <> nvl(vn_vl_tot_deb_fcp,0) then
         --
         vn_fase := 5.2;
         --
         gv_resumo_log := 'O "Valor total dos débitos FCP por Saídas e prestações" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor total dos débitos FCP por Saídas e prestações" ('
                          ||trim(to_char(nvl(vn_vl_tot_deb_fcp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico 
                                             );
         --
      end if;
      --
      vn_fase := 6;
      /*
      Campo 07 (VL_TOT_CREDITOS_DIFAL) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada). 
      Se o campo 2 – UF do registro E300 for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_DEST. 
      Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_ICMS_UF_REM.
      */
      vn_vl_tot_creditos_difal := fkg_vl_tot_creditos_difal;
      --
      vn_fase := 6.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0) <> nvl(vn_vl_tot_creditos_difal,0) then
         --
         vn_fase := 6.2;
         --
         gv_resumo_log := 'O "Valor total dos créditos do ICMS referente ao diferencial de alíquota devido à UF dos Remetente/ Destinatário" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor total dos créditos do ICMS" ('
                          ||trim(to_char(nvl(vn_vl_tot_creditos_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico 
                                             );
         --
      end if;
      --
      vn_fase := 7;
      --
      /*
      Campo 08 (VL_TOT_CRED_FCP) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada).  
      Se o campo 2 – UF do registro E300 for a do registro 0000, este valor sempre será igual a zero. 
      Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_FCP_UF_DEST.
      */
      vn_vl_tot_cred_fcp := fkg_vl_tot_cred_fcp;
      --
      vn_fase := 7.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0) <> nvl(vn_vl_tot_cred_fcp,0) then
         --
         vn_fase := 7.2;
         --
         gv_resumo_log := 'O "Valor total dos créditos FCP por Entradas" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor total dos créditos FCP" ('
                          ||trim(to_char(nvl(vn_vl_tot_cred_fcp,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico 
                                             );
         --
      end if;
      --
      vn_fase := 8;
      /*
      Campo 09 (VL_OUT_CRED_DIFAL) - Validação:  o valor informado deve corresponder ao somatório do campo VL_AJ_APUR dos registros E311,
      quando o terceiro caractere for igual a ‘2’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘2’ ou ‘3’.
      */
      vn_vl_out_cred_difal := fkg_soma_vl_out_cred_difal;
      --
      vn_fase := 8.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0) <> nvl(vn_vl_out_cred_difal,0) then
         --
         vn_fase := 8.2;
         --
         gv_resumo_log := 'O "Valor total de Ajustes "Outros créditos ICMS Diferencial de Alíquota da UF de Origem/Destino" e “Estorno de débitos ICMS Diferencial de Alíquota da UF de Origem/Destino”" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor total de Ajustes Outros créditos e Estorno de débitos" ('
                          ||trim(to_char(nvl(vn_vl_out_cred_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico 
                                             );
         --
      end if;
      --
      vn_fase := 9;
      /*
      Campo 10 (VL_SLD_DEV_ANT_DIFAL) - Validação: Se (VL_TOT_DEBITOS_DIFAL + VL_OUT_DEB_DIFAL+ VL_TOT_DEB_FCP) 
      menos (VL_SLD_CRED_ANT_DIFAL + VL_TOT_CREDITOS_DIFAL + VL_OUT_CRED_DIFAL + VL_TOT_CRED_FCP) 
      for maior ou igual a ZERO, então o resultado deverá ser igual ao VL_SLD_DEV_ANT_DIFAL; 
      senão VL_SLD_DEV_ANT_DIFAL deve ser igual a ZERO.
      */
      vn_vl_sld_dev_ant_difal := ( nvl(vn_vl_tot_debitos_difal,0) + nvl(vn_vl_out_deb_difal,0) + nvl(vn_vl_tot_deb_fcp,0) )
                               - ( nvl(vn_vl_sld_cred_ant_difal,0) + nvl(vn_vl_tot_creditos_difal,0) + nvl(vn_vl_tot_cred_fcp,0) + nvl(vn_vl_out_cred_difal,0) );
      --
      vn_fase := 9.1;
      --
      if nvl(vn_vl_sld_dev_ant_difal,0) <= 0 then
         vn_vl_sld_dev_ant_difal := 0;
      end if;
      --
      vn_fase := 9.2;
      --
      if nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0) <> nvl(vn_vl_sld_dev_ant_difal,0) then
         --
         vn_fase := 9.3;
         --
         gv_resumo_log := 'O "Valor total de Saldo devedor ICMS Diferencial de Alíquota da UF de Origem/Destino antes das deduções" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor total de Saldo devedor ICMS antes das deduções" ('
                          ||trim(to_char(nvl(vn_vl_sld_dev_ant_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico 
                                             );
         --
      end if;
      --
      vn_fase := 10;
      /*
      Campo 11 (VL_DEDUÇÕES_DIFAL) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311, por UF,
      quando o terceiro caractere for igual a ‘2’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘4’.
      */
      vn_vl_deducoes_difal := fkg_soma_vl_deducoes_difal;
      --
      vn_fase := 10.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_deducoes_difal,0) <> nvl(vn_vl_deducoes_difal,0) then
         --
         vn_fase := 10.2;
         --
         gv_resumo_log := 'O "Valor total dos ajustes Deduções ICMS Diferencial de Alíquota da UF de Origem/Destino" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_deducoes_difal,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor total dos ajustes Deduções ICMS" ('
                          ||trim(to_char(nvl(vn_vl_deducoes_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico 
                                             );
         --
      end if;
      --
      vn_fase := 11;
      /*
      Campo 12 (VL_RECOL) - Validação: Se (VL_SLD_DEV_ANT_DIFAL menos VL_DEDUCOES_DIFAL) for maior ou igual a ZERO,
      então VL_RECOL é igual ao resultado da equação; senão o VL_RECOL deverá ser igual a ZERO. VL_RECOL + DEB_ESP_DIFAL = soma do campo VL_OR (E316).
      */
      vn_vl_recol := nvl(vn_vl_sld_dev_ant_difal,0) - nvl(vn_vl_deducoes_difal,0);
      --
      vn_fase := 11.1;
      --
      if nvl(vn_vl_recol,0) <= 0 then
         vn_vl_recol := 0;
      end if;
      --
      vn_fase := 11.2;
      --
      if nvl(gt_row_apur_icms_difal.vl_recol,0) <> nvl(vn_vl_recol,0) then
         --
         vn_fase := 11.3;
         --
         gv_resumo_log := 'O "Valor recolhido ou a recolher referente a FCP e Imposto do Diferencial de Alíquota da UF de Origem/Destino" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_recol,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valor recolhido ou a recolher referente a FCP e DIFAL" ('
                          ||trim(to_char(nvl(vn_vl_recol,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 12;
      /*
      Campo 13 (VL_SLD_CRED_TRANSPORTAR) – 
      Validação:
          Se (VL_SLD_CRED_ANT_DIFAL + VL_TOT_CREDITOS_DIFAL + VL_OUT_CRED_DIFAL+ VL_TOT_CRED_FCP)
             menos (VL_TOT_DEBITOS_DIFAL+ VL_OUT_DEB_DIFAL+ VL_TOT_DEB_FCP) for maior que ZERO, então 
             VL_SLD_CRED_TRANSPORTAR deve ser igual ao resultado da equação;
          senão VL_SLD_CRED_TRANSPORTAR será ZERO.
      */
      vn_vl_sld_cred_transportar := ( nvl(vn_vl_sld_dev_ant_difal,0) + nvl(vn_vl_tot_creditos_difal,0) + nvl(vn_vl_tot_cred_fcp,0) + nvl(vn_vl_out_cred_difal,0) )
                                  - ( nvl(vn_vl_tot_debitos_difal,0) + nvl(vn_vl_out_deb_difal,0) + nvl(vn_vl_tot_deb_fcp,0) );
      --
      vn_fase := 12.1;
      --
      if nvl(vn_vl_sld_cred_transportar,0) <= 0 then
         vn_vl_sld_cred_transportar := 0;
      end if;
      --
      vn_fase := 12.2;
      --
      if nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar,0) <> nvl(vn_vl_sld_cred_transportar,0) then
         --
         vn_fase := 12.3;
         --
         gv_resumo_log := 'O "Saldo credor a transportar para o período seguinte referente a FCP e Imposto do Diferencial de Alíquota da UF de Origem/Destino" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Saldo credor a transportar para o período seguinte referente a FCP e DIFAL" ('
                          ||trim(to_char(nvl(vn_vl_sld_cred_transportar,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 13;
      /*
      Campo 14 (DEB_ESP_DIFAL) – Validação: Informar por UF:
         Somatório dos campos VL_AJ_APUR dos registros E311, se o campo COD_AJ_APUR  possuir o terceiro caractere do código informado no registro E311 igual a “2” e o
      quarto caractere for igual a “5".
         MAIS Somente para o primeiro período do apuração: Se a UF do Registro E300 for igual a UF do Registro 0000, a soma de todos os campos VL_ICMS_UF_REM
      dos Registros C101 e D101 cujos registros pais C100 e D100 possuam o campo IND_OPER igual a 1 (Saída) e o campo COD_SIT igual a “01” ou “07”.
         Se a UF do Registro E300 for diferente da UF do Registro 0000, a soma dos campos VL_FCP_UF_DEST e VL_ICMS_UF_DEST dos registros C101 e D101,
      cujos registros pais C100 e D100 possuem o campo IND_OPER igual a 1 (Saída) e o campo COD_SIT igual a “01” ou “07”.
      */
      vn_vl_deb_esp_difal := fkg_soma_vl_deb_esp_difal;
      --
      vn_fase := 13.1;
      --
      if nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0) <> nvl(vn_vl_deb_esp_difal,0) then
         --
         vn_fase := 13.2;
         --
         gv_resumo_log := 'O "Valores recolhidos ou a recolher, extraapuração" ('||
                          trim(to_char(nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0),'9999G999G999G990D00'))
                          ||') está divergente do "Cálculo do Valores recolhidos ou a recolher, extraapuração" ('
                          ||trim(to_char(nvl(vn_vl_deb_esp_difal,0),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 14;
      -- Busca o valor da obrigação a recolher
      begin
         --
         select sum(vl_or)
           into vn_vl_or
           from obr_rec_apur_icms_difal
          where apuricmsdifal_id = gt_row_apur_icms_difal.id;
         --
      exception
         when others then
            vn_vl_or := 0;
      end;
      --
      vn_fase := 14.1;
      -- Validação: Verifica se as obrigações de imposto a recolher foram lançadas
      -- corretamente com o valor de icms a recolher na apuração de icms.
      if ( nvl(gt_row_apur_icms_difal.vl_recol,0) + nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0) ) <> nvl(vn_vl_or,0)
         then
         --
         vn_fase := 14.2;
         --
         gv_resumo_log := 'O "Valor da Obrigação a recolher" em Obrigações de ICMS-DIFAL a Recolher ('||trim(to_char(nvl(vn_vl_or,0),'9999G999G999G990D00'))||
                          ') está divergente do cálculo: "Valor total do ICMS a recolher" mais "Valor recolhidos ou a recolher, extra-apuração", na Apuração de '||
                          'ICMS-DIFAL ('||trim(to_char((nvl(gt_row_apur_icms_difal.vl_recol,0) + nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0)),'9999G999G999G990D00'))||').';
         --
         vn_loggenerico_id := null;
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_VALIDACAO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico
                                             );
         --
      end if;
      --
      vn_fase := 15;
      -- Valida informações de Obrigação a recolher
      for rec_or in c_or loop
         exit when c_or%notfound or (c_or%notfound) is null;
         --
         vn_fase := 15.1;
         -- Valida Número do processo
         if rec_or.num_proc is not null
            and ( rec_or.origproc_id is null or rec_or.descr_proc is null )
            then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', Informações de Processo preenchidas de forma errada e/ou incompletas.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
         vn_fase := 15.2;
         -- Valida Origem do Processo
         if rec_or.origproc_id is not null
            and ( rec_or.num_proc is null or rec_or.descr_proc is null )
            then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', Informações de Processo preenchidas de forma errada e/ou incompletas.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
         vn_fase := 15.3;
         -- Valida Origem do Processo
         if rec_or.descr_proc is not null
            and ( rec_or.num_proc is null or rec_or.origproc_id is null )
            then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', Informações de Processo preenchidas de forma errada e/ou incompletas.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
         vn_fase := 15.4;
         -- Valida Informação de Mês e Ano de Referencia
         if length(rec_or.mes_ref) <> 6 then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', formato inválido do "Mês/Ano de Referencia" (' || rec_or.mes_ref || '). Correto MMRRRRR (Mês + Ano), exemplo: 012015.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
         vn_fase := 15.5;
         --
         if length(rec_or.mes_ref) = 6
            and to_number(substr(rec_or.mes_ref, 1, 2)) not between 1 and 12
            then
            --
            gv_resumo_log := 'Obrig. Recolher - Cód. Ajuste ' || rec_or.aj_obrig_rec_cd || ', Valor ' || trim(to_char(nvl(rec_or.vl_or,0),'9999G999G999G990D00'))
                             || ', Data Vencto ' || to_char(rec_or.dt_vcto, 'dd/mm/rrrr') || ' e Cód. Receita ' || rec_or.cod_rec
                             || ', o "Mês de Referencia" (' || substr(rec_or.mes_ref, 1, 2) || ') esta inválido.';
            --
            vn_loggenerico_id := null;
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => gv_mensagem_log
                                             , ev_resumo          => gv_resumo_log
                                             , en_tipo_log        => ERRO_DE_VALIDACAO
                                             , en_referencia_id   => gn_referencia_id
                                             , ev_obj_referencia  => gv_obj_referencia
                                             );
            --
            -- Armazena o "loggenerico_id" na memória
            pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                                , est_log_generico  => est_log_generico
                                                );
            --
         end if;
         --
      end loop;
      --
      vn_fase := 16;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms_difal.pkb_valida_ate_31122016 fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
         -- Armazena o "loggenerico_id" na memória
         pk_log_generico.pkb_gt_log_generico ( en_loggenerico    => vn_loggenerico_id
                                             , est_log_generico  => est_log_generico );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_valida_ate_31122016;

-------------------------------------------------------------------------------------------------------
--| Procedimento que carrega os dados nas tabelas temporárias
procedure pkb_insert_tabela_tmp is
  --
begin
  --
  -- Limpa Tabelas ----------------------
  delete from tmp_nota_fiscal;
  commit;
  --  
  delete from tmp_nota_fiscal_total;
  commit;
  --
  delete from tmp_item_nota_fiscal;
  commit;
  --  
  -- Carrega Tabelas --------------------  
  -- Nota Fiscal
  insert /*+ APPEND */
  into tmp_nota_fiscal
    select * -- menção da tabela nota fiscal somente no insert da temporária.
      from nota_fiscal nf
     where nf.dm_st_proc      = 4 -- 4-Autorizada
       and nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
       and nf.dm_arm_nfe_terc = 0
       and nf.dm_ind_emit     = 1 -- Emissão Terceiro
       and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/rrrr') between to_date(gt_row_per_apur_icms_difal.dt_inicio,'dd/mm/rrrr') and to_date(gt_row_per_apur_icms_difal.dt_fim, 'dd/mm/rrrr'))
             or
            (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/rrrr') between to_date(gt_row_per_apur_icms_difal.dt_inicio,'dd/mm/rrrr') and to_date(gt_row_per_apur_icms_difal.dt_fim, 'dd/mm/rrrr'))
             or
            (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/rrrr'),to_date(nf.dt_emiss,'dd/mm/rrrr')) between to_date(gt_row_per_apur_icms_difal.dt_inicio,'dd/mm/rrrr') and to_date(gt_row_per_apur_icms_difal.dt_fim, 'dd/mm/rrrr')))
    union all
    select * -- menção da tabela nota fiscal somente no insert da temporária.
      from nota_fiscal nf
     where nf.dm_st_proc      = 4 -- 4-Autorizada
       and nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
       and nf.dm_arm_nfe_terc = 0
       and nf.dm_ind_emit     = 0 -- Emisão Prórpia
       and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/rrrr') between to_date(gt_row_per_apur_icms_difal.dt_inicio,'dd/mm/rrrr') and to_date(gt_row_per_apur_icms_difal.dt_fim, 'dd/mm/rrrr'))
             or
            (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/rrrr') between to_date(gt_row_per_apur_icms_difal.dt_inicio,'dd/mm/rrrr') and to_date(gt_row_per_apur_icms_difal.dt_fim, 'dd/mm/rrrr'))
             or
            (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/rrrr'),to_date(nf.dt_emiss,'dd/mm/rrrr')) between to_date(gt_row_per_apur_icms_difal.dt_inicio,'dd/mm/rrrr') and to_date(gt_row_per_apur_icms_difal.dt_fim, 'dd/mm/rrrr')));
  -- 
  commit;
  --
  -- Total Nota Fiscal
  insert /*+ APPEND */
  into tmp_nota_fiscal_total
    select nft.*
      from nota_fiscal_total nft
     where nft.notafiscal_id in (select id from tmp_nota_fiscal);
  commit;
  --
  -- Item Nota Fiscal
  insert /*+ APPEND */
  into tmp_item_nota_fiscal
    select inf.*
      from item_nota_fiscal inf
     where inf.notafiscal_id in (select id from tmp_nota_fiscal);
  commit;
  --
end pkb_insert_tabela_tmp;

-------------------------------------------------------------------------------------------------------
--| Procedimento valida as informações da Apuração de IMCS DIFAL
procedure pkb_validar ( en_apuricmsdifal_id in apur_icms_difal.id%type )
is
   --
   vn_fase            number := 0;
   vt_log_generico    dbms_sql.number_table;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   -- recupera os dados da apuração de imposto		 
   pkb_dados_apur_icms_difal ( en_apuricmsdifal_id => en_apuricmsdifal_id ); 
   --	  
   if nvl(gv_geral,'N') = 'N' then	  
      --
      vn_fase := 1.1;
      --	  
      pkb_insert_tabela_tmp;	  
      --	  
   end if;     
   --
   vn_fase := 2;
   --
   if nvl(gt_row_apur_icms_difal.id,0) > 0 then
      --
      vn_fase := 3;
      -- Limpar os logs
      delete log_generico o
       where o.obj_referencia = gv_obj_referencia
         and o.referencia_id  = gt_row_apur_icms_difal.id;
      --
      vn_fase := 4;
      --
      commit;
      --
      vn_fase := 5;
      -- Inicia processo de validação do ICMS
      if gt_row_per_apur_icms_difal.dt_fim < '01/01/2017' then
         --
         vn_fase := 6;
         --
         pkb_valida_ate_31122016 ( est_log_generico => vt_log_generico ); -- considerar o layout do Registro E310 até 31/12/2016
         --
      else
         --
         vn_fase := 7;
         --
         pkb_valida_apartir_01012017 ( est_log_generico => vt_log_generico ); -- considerar o layout do Registro E310 a partir de 01/01/2017
         --
      end if;
      --
      vn_fase := 8;
      --
      if nvl(vt_log_generico.count,0) <= 0 then
         --
         vn_fase := 9;
         -- Como não há erros de validação ai limpa os caracteres numa única vez.
         pkb_limpa_caracteres_bloco_e ( en_apuricmsdifal_id => gt_row_apur_icms_difal.id);
         --
         vn_fase := 10;
         --  Atualiza status como processado
         update apur_icms_difal set dm_situacao = 3
         where id = gt_row_apur_icms_difal.id;
         --
         gv_resumo_log := 'Apuração de ICMS-DIFAL Processada com sucesso!';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => INFO_APUR_IMPOSTO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
      else
         --
         vn_fase := 11;
         --  Atualiza status de erros de validação
         update apur_icms_difal set dm_situacao = 4
          where id = gt_row_apur_icms_difal.id;
         --
         gv_resumo_log := 'Cálculo da Apuração de ICMS-DIFAL possui erros de validação!';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => INFO_APUR_IMPOSTO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
      end if;
      --
      vn_fase := 12;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_validar fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => en_apuricmsdifal_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_validar;

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a situação da Apuração de IMCS DIFAL e volta para seu anterior
procedure pkb_desfazer ( en_apuricmsdifal_id in apur_icms_difal.id%type )
is
   --
   vn_fase               number := 0;
   vv_descr_dm_situacao  Dominio.dominio%TYPE;
   vn_loggenerico_id     Log_Generico.id%TYPE;
   --
begin
   --
   vn_fase := 1;
   -- recupera os dados da apuração de imposto
   pkb_dados_apur_icms_difal ( en_apuricmsdifal_id => en_apuricmsdifal_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_apur_icms_difal.id,0) > 0 then
      --
      vn_fase := 3;
      -- Limpar os logs
      delete log_generico o
       where o.obj_referencia = 'APURACAO_ICMS_DIFAL'
         and o.referencia_id  = en_apuricmsdifal_id;
      --
      commit;
      --
      vn_fase := 4;
      -- Se o DM_SITUACAO = 4 "Erro de Validação" ou 3 "Processada", defaz para 2 "Cálculado"
      if gt_row_apur_icms_difal.dm_situacao in (4, 3) then
         --
         vn_fase := 5;
         --
         update apur_icms_difal set dm_situacao = 1
          where id = gt_row_apur_icms_difal.id;
         --
         vn_fase := 6;
         --
         vv_descr_dm_situacao := pk_csf.fkg_dominio ( ev_dominio   => 'APUR_ICMS_DIFAL.DM_SITUACAO'
                                                    , ev_vl        => '1' );
         --
      elsif gt_row_apur_icms_difal.dm_situacao in (1, 2) then
         -- Se o DM_SITUACAO = 1 "Calculado" ou 2 "Erro no Cálculo", defaz para 0 "Aberto"
         vn_fase := 7;
         --
         update apur_icms_difal set dm_situacao                 = 0
                                  , dm_ind_mov_difal            = 0
                                  , vl_sld_cred_ant_difal       = 0
                                  , vl_tot_debitos_difal        = 0
                                  , vl_out_deb_difal            = 0
                                  , vl_tot_deb_fcp              = 0
                                  , vl_tot_creditos_difal       = 0
                                  , vl_tot_cred_fcp             = 0
                                  , vl_out_cred_difal           = 0
                                  , vl_sld_dev_ant_difal        = 0
                                  , vl_deducoes_difal           = 0
                                  , vl_recol                    = 0
                                  , vl_sld_cred_transportar     = 0
                                  , vl_deb_esp_difal            = 0
                                  , vl_sld_cred_ant_fcp         = 0
                                  , vl_out_deb_fcp              = 0
                                  , vl_out_cred_fcp             = 0
                                  , vl_sld_dev_ant_fcp          = 0
                                  , vl_deducoes_fcp             = 0
                                  , vl_recol_fcp                = 0
                                  , vl_sld_cred_transportar_fcp = 0
                                  , vl_deb_esp_fcp              = 0
          where id = gt_row_apur_icms_difal.id;
         --
         vn_fase := 8;
         --
         vv_descr_dm_situacao := pk_csf.fkg_dominio ( ev_dominio => 'APUR_ICMS_DIFAL.DM_SITUACAO'
                                                    , ev_vl      => '0' );
         --
      end if;
      --
      vn_fase := 9;
      --
      commit;
      --
      vn_fase := 10;
      --
      gv_resumo_log := 'Desfeito a situação de "' || pk_csf.fkg_dominio ( ev_dominio => 'APURACAO_ICMS_DIFAL.DM_SITUACAO'
                                                                        , ev_vl      => gt_row_apur_icms_difal.dm_situacao
                                                                        )
                       || '" para a situação "' || vv_descr_dm_situacao || '"';
      --
      pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                       , ev_mensagem        => gv_mensagem_log
                                       , ev_resumo          => gv_resumo_log
                                       , en_tipo_log        => INFO_APUR_IMPOSTO
                                       , en_referencia_id   => gn_referencia_id
                                       , ev_obj_referencia  => gv_obj_referencia );
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_desfazer fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => en_apuricmsdifal_id
                                          , ev_obj_referencia  => gv_obj_referencia 
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_desfazer;

------------------------------------------------------------------------------------------------------------
--| Procedimento faz a apuração do ICMS DIFAL - Considerar o layout do Registro E310 a partir de 01/01/2017
procedure pkb_apura_apartir_01012017 is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   -- Campo 03 (VL_SLD_CRED_ANT_DIFAL) – Preenchimento: Valor do campo VL_SLD_CRED_TRANSPORTAR  do período de apuração anterior.
   gt_row_apur_icms_difal.vl_sld_cred_ant_difal := fkg_saldo_credor_ant_difal;
   --
   vn_fase := 2;
   /*
   Campo 04 (VL_TOT_DEBITOS_DIFAL) - Validação: somatório de todos os valores do C101 e D101, cujos registros pai C100 e D100
   tenham IND_OPER = 1 (Saída), exceto aqueles cujos C100 e D100 utilizarem os COD_SIT 01 ou 07. Se o campo 2 – UF do registro E300
   for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_REM. Se o campo 2 – UF do registro E300 for a do
   destinatário, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
   */
   gt_row_apur_icms_difal.vl_tot_debitos_difal := fkg_vl_tot_debitos_difal;
   --
   vn_fase := 3;
   /*
   Campo 05 (VL_OUT_DEB_DIFAL) – Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311,
   quando o terceiro caractere for igual a ‘2’ e o quarto for igual a ‘0’ ou ‘1’, ambos do campo COD_AJ_APUR do registro E311.
   */
   gt_row_apur_icms_difal.vl_out_deb_difal := fkg_soma_vl_out_deb_difal;
   --
   vn_fase := 4;
   --
   /*
   Campo 06 (VL_TOT_CREDITOS_DIFAL) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada).
   Se o campo 2 – UF do registro E300 for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
   Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_ICMS_UF_REM.
   */
   gt_row_apur_icms_difal.vl_tot_creditos_difal := fkg_vl_tot_creditos_difal;
   --
   vn_fase := 5;
   /*
   Campo 07 (VL_OUT_CRED_DIFAL) - Validação:  o valor informado deve corresponder ao somatório do campo VL_AJ_APUR dos registros E311,
   quando o terceiro caractere for igual a ‘2’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘2’ ou ‘3’.
   */
   gt_row_apur_icms_difal.vl_out_cred_difal := fkg_soma_vl_out_cred_difal;
   --
   vn_fase := 6;
   /*
   Campo 08 (VL_SLD_DEV_ANT_DIFAL) - Validação: Se (VL_TOT_DEBITOS_DIFAL + VL_OUT_DEB_DIFAL) menos (VL_SLD_CRED_ANT_DIFAL + VL_TOT_CREDITOS_DIFAL + 
   VL_OUT_CRED_DIFAL), for maior ou igual a ZERO, então o resultado deverá ser igual ao VL_SLD_DEV_ANT_DIFAL; senão VL_SLD_DEV_ANT_DIFAL deve ser igual a ZERO.
   */
   gt_row_apur_icms_difal.vl_sld_dev_ant_difal := ( nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0) + nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0) ) -
                                                  ( nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_difal,0) + nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0) +
                                                    nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0) );
   --
   vn_fase := 7;
   --
   if nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0) <= 0 then
      gt_row_apur_icms_difal.vl_sld_dev_ant_difal := 0;
   end if;
   --
   vn_fase := 8;
   /*
   Campo 09 (VL_DEDUÇÕES_DIFAL) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311, por UF,
   quando o terceiro caractere for igual a ‘2’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘4’.
   */
   gt_row_apur_icms_difal.vl_deducoes_difal := fkg_soma_vl_deducoes_difal;
   --
   vn_fase := 9;
   /*
   Campo 10 (VL_RECOL_DIFAL) - Validação: Se (VL_SLD_DEV_ANT_DIFAL menos VL_DEDUCOES_DIFAL) for maior ou igual a ZERO,
   então VL_RECOL é igual ao resultado da equação; senão o VL_RECOL deverá ser igual a ZERO.
   VL_RECOL_DIFAL + DEB_ESP_DIFAL + VL_RECOL_FCP + DEB_ESP_FCP = soma do campo VL_OR (E316).
   */
   gt_row_apur_icms_difal.vl_recol := nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0) - nvl(gt_row_apur_icms_difal.vl_deducoes_difal,0);
   --
   vn_fase := 10;
   --
   if nvl(gt_row_apur_icms_difal.vl_recol,0) <= 0 then
      gt_row_apur_icms_difal.vl_recol := 0;
   end if;
   --
   vn_fase := 11;
   /*
   Campo 11 (VL_SLD_CRED_TRANSPORTAR_DIFAL) – Validação: Se (VL_SLD_CRED_ANT_DIFAL + VL_TOT_CREDITOS_DIFAL + VL_OUT_CRED_DIFAL) menos (VL_TOT_DEBITOS_DIFAL +
   VL_OUT_DEB_DIFAL) for maior que ZERO, então VL_SLD_CRED_TRANSPORTAR_DIFAL deve ser igual ao resultado da equação; senão VL_SLD_CRED_TRANSPORTAR_DIFAL será
   ZERO.
   */
   gt_row_apur_icms_difal.vl_sld_cred_transportar := ( nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0) +
                                                       nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0) +
                                                       nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0) ) -
                                                     ( nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0) + nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0) );
   --
   vn_fase := 12;
   --
   if nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar,0) <= 0 then
      gt_row_apur_icms_difal.vl_sld_cred_transportar := 0;
   end if;
   --
   vn_fase := 13;
   /*
   Campo 12 (DEB_ESP_DIFAL) – Validação: Informar por UF:
   Somatório dos campos VL_AJ_APUR dos registros E311, se o campo COD_AJ_APUR  possuir o terceiro caractere do código informado no registro E311 igual a “2” e o
   quarto caractere for igual a “5".
   MAIS Somente para o primeiro período do apuração: Se a UF do Registro E300 for igual a UF do Registro 0000, a soma de todos os campos VL_ICMS_UF_REM
   dos Registros C101 e D101 cujos registros pais C100 e D100 possuam o campo IND_OPER igual a 1 (Saída) e o campo COD_SIT igual a “01” ou “07”.
   Se a UF do Registro E300 for diferente da UF do Registro 0000, a soma dos campos VL_ICMS_UF_DEST dos registros C101 e D101, cujos registros pais C100 e
   D100 possuam o campo IND_OPER igual a 1 (Saída) e o campo COD_SIT igual a “01” ou “07”.
   */
   gt_row_apur_icms_difal.vl_deb_esp_difal := fkg_soma_vl_deb_esp_difal;
   --
   vn_fase := 14;
   /*
   Campo 13 (VL_SLD_CRED_ANT_FCP) – Validação: Valor do campo VL_SLD_CRED_TRANSPORTAR_FCP do período de apuração anterior.
   */
   gt_row_apur_icms_difal.vl_sld_cred_ant_fcp := fkg_saldo_credor_ant_fcp;
   --
   vn_fase := 15;
   /*
   Campo 14 (VL_TOT_DEB_FCP) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 1 (Saída),
   exceto aqueles cujos C100 e D100 utilizarem os COD_SIT 01 ou 07. Se o campo 2 – UF do registro E300 for a do registro 0000, este valor será zero.
   Se o campo 2 – UF do registro E300 for a do destinatário, então corresponde à somatória dos campos VL_FCP_UF_DEST.
   */
   gt_row_apur_icms_difal.vl_tot_deb_fcp := fkg_vl_tot_deb_fcp;
   --
   vn_fase := 16;
   /*
   Campo 15 (VL_OUT_DEB_FCP) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311, quando o terceiro caractere
   for igual a ‘3’ e o quarto for igual a ‘0’ ou ‘1’, ambos do campo COD_AJ_APUR do registro E311.
   */
   gt_row_apur_icms_difal.vl_out_deb_fcp := fkg_soma_vl_out_deb_fcp;
   --
   vn_fase := 17;
   /*
   Campo 16 (VL_TOT_CRED_FCP) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada).
   Se o campo 2 – UF do registro E300 for a do registro 0000, este valor sempre será igual a zero.
   Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_FCP_UF_DEST.
   */
   gt_row_apur_icms_difal.vl_tot_cred_fcp := fkg_vl_tot_cred_fcp;
   --
   vn_fase := 18;
   /*
   Campo 17 (VL_OUT_CRED_FCP) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR dos registros E311, quando o terceiro
   caractere for igual a ‘3’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘2’ ou ‘3’.
   */
   gt_row_apur_icms_difal.vl_out_cred_fcp := fkg_soma_vl_out_cred_fcp;
   --
   vn_fase := 19;
   /*
   Campo 18 (VL_SLD_DEV_ANT_FCP) - Validação: Se (VL_TOT_DEB_FCP + VL_OUT_DEB_FCP) menos (VL_SLD_CRED_ANT_FCP + VL_TOT_CRED_FCP + VL_OUT_CRED_FCP) for maior ou
   igual a ZERO, então o resultado deverá ser igual ao VL_SLD_DEV_ANT_FCP; senão VL_SLD_DEV_ANT_FCP deve ser igual a ZERO.
   */
   gt_row_apur_icms_difal.vl_sld_dev_ant_fcp := ( (nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0) + nvl(gt_row_apur_icms_difal.vl_out_deb_fcp,0) ) -
                                                  (nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_fcp,0) + nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0) +
                                                   nvl(gt_row_apur_icms_difal.vl_out_cred_fcp,0)) );
   --
   vn_fase := 20;
   --
   if nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_fcp,0) <= 0 then
      gt_row_apur_icms_difal.vl_sld_dev_ant_fcp := 0;
   end if;
   --
   vn_fase := 21;
   /*
   Campo 19 (VL_DEDUÇÕES_FCP) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311, por UF, quando o terceiro
   caractere for igual a ‘3’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘4’.
   */
   gt_row_apur_icms_difal.vl_deducoes_fcp := fkg_soma_vl_deducoes_fcp;
   --
   vn_fase := 22;
   /*
   Campo 20 (VL_RECOL_FCP) - Validação: Se (VL_SLD_DEV_ANT_FCP menos VL_DEDUCOES_FCP) for maior ou igual a ZERO, então VL_RECOL_FCP é igual ao resultado da
   equação; senão o VL_RECOL_FCP deverá ser igual a ZERO.
   */
   gt_row_apur_icms_difal.vl_recol_fcp := ( nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_fcp,0) - nvl(gt_row_apur_icms_difal.vl_deducoes_fcp,0) );
   --
   vn_fase := 23;
   --
   if nvl(gt_row_apur_icms_difal.vl_recol_fcp,0) <= 0 then
      gt_row_apur_icms_difal.vl_recol_fcp := 0;
   end if;
   --
   vn_fase := 24;
   /*
   Campo 21 (VL_SLD_CRED_TRANSPORTAR_FCP) – Validação: Se (VL_SLD_CRED_ANT_FCP + VL_TOT_CRED_FCP + VL_OUT_CRED_FCP) menos (VL_TOT_DEB_FCP + VL_OUT_DEB_FCP)
   for maior que ZERO, então VL_SLD_CRED_TRANSPORTAR_FCP deve ser igual ao resultado da equação; senão VL_SLD_CRED_TRANSPORTAR_FCP será ZERO.
   */
   gt_row_apur_icms_difal.vl_sld_cred_transportar_fcp := ( (nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_fcp,0) +
                                                            nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0) +
                                                            nvl(gt_row_apur_icms_difal.vl_out_cred_fcp,0)) -
                                                           (nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0) +
                                                            nvl(gt_row_apur_icms_difal.vl_out_deb_fcp,0)) );
   --
   vn_fase := 25;
   --
   if nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar_fcp,0) <= 0 then
      gt_row_apur_icms_difal.vl_sld_cred_transportar_fcp := 0;
   end if;
   --
   vn_fase := 26;
   /*
   Campo 22 (DEB_ESP_FCP) – Validação: Somatório dos campos VL_AJ_APUR dos registros E311, se o campo COD_AJ_APUR possuir o terceiro caractere do código
   informado no registro E311 igual a “3” e o quarto caractere for igual a “5".
   */
   gt_row_apur_icms_difal.vl_deb_esp_fcp := fkg_soma_vl_deb_esp_fcp;
   --
   vn_fase := 27;
   -- 02 - ind_mov_st: 0 – sem operações com st ou 1 – com operações de st
   if nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_difal,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_deducoes_difal,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_recol,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_fcp,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_out_deb_fcp,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_out_cred_fcp,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_fcp,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_deducoes_fcp,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_recol_fcp,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar_fcp,0) > 0 or
      nvl(gt_row_apur_icms_difal.vl_deb_esp_fcp,0) > 0 then
      --
      gt_row_apur_icms_difal.dm_ind_mov_difal := 1;
      --
   else
      --
      gt_row_apur_icms_difal.dm_ind_mov_difal := 0;
      --
   end if;
   --
exception
   when others then
      --
      update apur_icms_difal set dm_situacao = 2 -- Erro no Calculo
       where id = gt_row_apur_icms_difal.id;
      --
      commit;
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_apuracao.pkb_apura_apartir_01012017 fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => erro_de_sistema
                                          , en_referencia_id   => gt_row_apur_icms_difal.id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_apura_apartir_01012017;

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apuração do ICMS DIFAL - Considerar o layout do Registro E310 até 31/12/2016
procedure pkb_apura_ate_31122016 is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   -- Campo 03 (VL_SLD_CRED_ANT_DIFAL) – Preenchimento: Valor do campo VL_SLD_CRED_TRANSPORTAR  do período de apuração anterior.
   gt_row_apur_icms_difal.vl_sld_cred_ant_difal := fkg_saldo_credor_ant_difal;
   --
   vn_fase := 2;
   /*
   Campo 04 (VL_TOT_DEBITOS_DIFAL) - Validação: somatório de todos os valores do C101 e D101, cujos registros pai C100 e D100
   tenham IND_OPER = 1 (Saída), exceto aqueles cujos C100 e D100 utilizarem os COD_SIT 01 ou 07. Se o campo 2 – UF do registro E300
   for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_REM. Se o campo 2 – UF do registro E300 for a do
   destinatário, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
   */
   gt_row_apur_icms_difal.vl_tot_debitos_difal := fkg_vl_tot_debitos_difal;
   --
   vn_fase := 3;
   /*
   Campo 05 (VL_OUT_DEB_DIFAL) – Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311,
   quando o terceiro caractere for igual a ‘2’ e o quarto for igual a ‘0’ ou ‘1’, ambos do campo COD_AJ_APUR do registro E311.
   */
   gt_row_apur_icms_difal.vl_out_deb_difal := fkg_soma_vl_out_deb_difal;
   --
   vn_fase := 4;
   --
   /*
   Campo 06 (VL_TOT_DEB_FCP) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 1 (Saída),
   exceto aqueles cujos C100 e D100 utilizarem os COD_SIT 01 ou 07. Se o campo 2 – UF do registro E300 for a do registro 0000, este valor será zero.
   Se o campo 2 – UF do registro E300 for a do destinatário, então corresponde à somatória dos campos VL_FCP_UF_DEST.
   */
   gt_row_apur_icms_difal.vl_tot_deb_fcp := fkg_vl_tot_deb_fcp;
   --
   vn_fase := 5;
   /*
   Campo 07 (VL_TOT_CREDITOS_DIFAL) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada).
   Se o campo 2 – UF do registro E300 for a do registro 0000, então corresponde à somatória dos campos VL_ICMS_UF_DEST.
   Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_ICMS_UF_REM.
   */
   gt_row_apur_icms_difal.vl_tot_creditos_difal := fkg_vl_tot_creditos_difal;
   --
   vn_fase := 6;
   /*
   Campo 08 (VL_TOT_CRED_FCP) – Validação: soma de todos os valores do C101 e D101, cujos registros pai C100 e D100 tenham IND_OPER = 0 (Entrada).
   Se o campo 2 – UF do registro E300 for a do registro 0000, este valor sempre será igual a zero.
   Se o campo 2 – UF do registro E300 for a do remetente (em devolução), então corresponde à somatória dos campos VL_FCP_UF_DEST.
   */
   gt_row_apur_icms_difal.vl_tot_cred_fcp := fkg_vl_tot_cred_fcp;
   --
   vn_fase := 7;
   /*
   Campo 09 (VL_OUT_CRED_DIFAL) - Validação:  o valor informado deve corresponder ao somatório do campo VL_AJ_APUR dos registros E311,
   quando o terceiro caractere for igual a ‘2’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘2’ ou ‘3’.
   */
   gt_row_apur_icms_difal.vl_out_cred_difal := fkg_soma_vl_out_cred_difal;
   --
   vn_fase := 8;
   /*
   Campo 10 (VL_SLD_DEV_ANT_DIFAL) - Validação: Se (VL_TOT_DEBITOS_DIFAL + VL_OUT_DEB_DIFAL+ VL_TOT_DEB_FCP)
   menos (VL_SLD_CRED_ANT_DIFAL + VL_TOT_CREDITOS_DIFAL + VL_OUT_CRED_DIFAL + VL_TOT_CRED_FCP)
   for maior ou igual a ZERO, então o resultado deverá ser igual ao VL_SLD_DEV_ANT_DIFAL;
   senão VL_SLD_DEV_ANT_DIFAL deve ser igual a ZERO.
   */
   gt_row_apur_icms_difal.vl_sld_dev_ant_difal := ( nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0)
                                                    + nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0)
                                                    + nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0) )
                                                   - ( nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_difal,0)
                                                       + nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0)
                                                       + nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0)
                                                       + nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0)
                                                      );
   --
   vn_fase := 9;
   --
   if nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0) <= 0 then
      gt_row_apur_icms_difal.vl_sld_dev_ant_difal := 0;
   end if;
   --
   vn_fase := 10;
   /*
   Campo 11 (VL_DEDUÇÕES_DIFAL) - Validação: o valor informado deve corresponder ao somatório do campo VL_AJ_APUR do registro E311, por UF,
   quando o terceiro caractere for igual a ‘2’ e o quarto caractere do campo COD_AJ_APUR for igual a ‘4’.
   */
   gt_row_apur_icms_difal.vl_deducoes_difal := fkg_soma_vl_deducoes_difal;
   --
   vn_fase := 11;
   /*
   Campo 12 (VL_RECOL) - Validação: Se (VL_SLD_DEV_ANT_DIFAL menos VL_DEDUCOES_DIFAL) for maior ou igual a ZERO,
   então VL_RECOL é igual ao resultado da equação; senão o VL_RECOL deverá ser igual a ZERO. VL_RECOL + DEB_ESP_DIFAL = soma do campo VL_OR (E316).
   */
   gt_row_apur_icms_difal.vl_recol := nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0) - nvl(gt_row_apur_icms_difal.vl_deducoes_difal,0);
   --
   vn_fase := 12;
   --
   if nvl(gt_row_apur_icms_difal.vl_recol,0) <= 0 then
      gt_row_apur_icms_difal.vl_recol := 0;
   end if;
   --
   vn_fase := 13;
   /*
   Campo 13 (VL_SLD_CRED_TRANSPORTAR) –
   Validação:
       Se (VL_SLD_CRED_ANT_DIFAL + VL_TOT_CREDITOS_DIFAL + VL_OUT_CRED_DIFAL+ VL_TOT_CRED_FCP)
          menos (VL_TOT_DEBITOS_DIFAL+ VL_OUT_DEB_DIFAL+ VL_TOT_DEB_FCP) for maior que ZERO, então
          VL_SLD_CRED_TRANSPORTAR deve ser igual ao resultado da equação;
       senão VL_SLD_CRED_TRANSPORTAR será ZERO.
   */
   gt_row_apur_icms_difal.vl_sld_cred_transportar := ( nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0)
                                                       + nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0)
                                                       + nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0)
                                                       + nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0)
                                                       )
                                                     - ( nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0)
                                                         + nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0)
                                                         + nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0)
                                                        );
   --
   vn_fase := 14;
   --
   if nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar,0) <= 0 then
      gt_row_apur_icms_difal.vl_sld_cred_transportar := 0;
   end if;
   --
   vn_fase := 15;
   /*
   Campo 14 (DEB_ESP_DIFAL) – Validação: Informar por UF:
      Somatório dos campos VL_AJ_APUR dos registros E311, se o campo COD_AJ_APUR  possuir o terceiro caractere do código informado no registro E311 igual a “2” e o
   quarto caractere for igual a “5".
      MAIS Somente para o primeiro período do apuração: Se a UF do Registro E300 for igual a UF do Registro 0000, a soma de todos os campos VL_ICMS_UF_REM
   dos Registros C101 e D101 cujos registros pais C100 e D100 possuam o campo IND_OPER igual a 1 (Saída) e o campo COD_SIT igual a “01” ou “07”.
      Se a UF do Registro E300 for diferente da UF do Registro 0000, a soma dos campos VL_FCP_UF_DEST e VL_ICMS_UF_DEST dos registros C101 e D101,
   cujos registros pais C100 e D100 possuem o campo IND_OPER igual a 1 (Saída) e o campo COD_SIT igual a “01” ou “07”.
   */
   gt_row_apur_icms_difal.vl_deb_esp_difal := fkg_soma_vl_deb_esp_difal;
   --
   vn_fase := 16;
   -- 02 - ind_mov_st: 0 – sem operações com st ou 1 – com operações de st
   if ( nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_difal,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_deducoes_difal,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_recol,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar,0) > 0
       or nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0) > 0
       )
       then
      gt_row_apur_icms_difal.dm_ind_mov_difal := 1;
   else
      gt_row_apur_icms_difal.dm_ind_mov_difal := 0;
   end if;
   --
exception
   when others then
      --
      update apur_icms_difal set dm_situacao = 2 -- Erro no Calculo
       where id = gt_row_apur_icms_difal.id;
      --
      commit;
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_apuracao.pkb_apura_ate_31122016 fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => erro_de_sistema
                                          , en_referencia_id   => gt_row_apur_icms_difal.id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_apura_ate_31122016;

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apuração do ICMS DIFAL
procedure pkb_apuracao ( en_apuricmsdifal_id in apur_icms_difal.id%type )
is
   --
   vn_fase            number := 0;
   vn_loggenerico_id  log_generico.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_apuricmsdifal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pkb_dados_apur_icms_difal ( en_apuricmsdifal_id => en_apuricmsdifal_id );
      --
      if nvl(gv_geral,'N') = 'N' then	  
         --
         vn_fase := 2.1;
         --	  
         pkb_insert_tabela_tmp;	  
         --	  
      end if;
      --	  
      vn_fase := 3;
      --
      if nvl(gt_row_apur_icms_difal.id,0) > 0 then
         --
         vn_fase := 4;
         --
         if gt_row_per_apur_icms_difal.dt_fim < '01/01/2017' then
            --
            vn_fase := 5;
            --
            pkb_apura_ate_31122016; -- considerar o layout do Registro E310 até 31/12/2016
            --
         else
            --
            vn_fase := 6;
            --
            pkb_apura_apartir_01012017; -- considerar o layout do Registro E310 a partir de 01/01/2017
            --
         end if;
         --
         vn_fase := 7;
         --
         update apur_icms_difal
            set dm_situacao                 = 1   -- Calculada
              , dm_ind_mov_difal            = nvl(gt_row_apur_icms_difal.dm_ind_mov_difal,0)
              , vl_sld_cred_ant_difal       = nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_difal,0)
              , vl_tot_debitos_difal        = nvl(gt_row_apur_icms_difal.vl_tot_debitos_difal,0)
              , vl_out_deb_difal            = nvl(gt_row_apur_icms_difal.vl_out_deb_difal,0)
              , vl_tot_deb_fcp              = nvl(gt_row_apur_icms_difal.vl_tot_deb_fcp,0)
              , vl_tot_creditos_difal       = nvl(gt_row_apur_icms_difal.vl_tot_creditos_difal,0)
              , vl_tot_cred_fcp             = nvl(gt_row_apur_icms_difal.vl_tot_cred_fcp,0)
              , vl_out_cred_difal           = nvl(gt_row_apur_icms_difal.vl_out_cred_difal,0)
              , vl_sld_dev_ant_difal        = nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_difal,0)
              , vl_deducoes_difal           = nvl(gt_row_apur_icms_difal.vl_deducoes_difal,0)
              , vl_recol                    = nvl(gt_row_apur_icms_difal.vl_recol,0)
              , vl_sld_cred_transportar     = nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar,0)
              , vl_deb_esp_difal            = nvl(gt_row_apur_icms_difal.vl_deb_esp_difal,0)
              , vl_sld_cred_ant_fcp         = nvl(gt_row_apur_icms_difal.vl_sld_cred_ant_fcp,0)
              , vl_out_deb_fcp              = nvl(gt_row_apur_icms_difal.vl_out_deb_fcp,0)
              , vl_out_cred_fcp             = nvl(gt_row_apur_icms_difal.vl_out_cred_fcp,0)
              , vl_sld_dev_ant_fcp          = nvl(gt_row_apur_icms_difal.vl_sld_dev_ant_fcp,0)
              , vl_deducoes_fcp             = nvl(gt_row_apur_icms_difal.vl_deducoes_fcp,0)
              , vl_recol_fcp                = nvl(gt_row_apur_icms_difal.vl_recol_fcp,0)
              , vl_sld_cred_transportar_fcp = nvl(gt_row_apur_icms_difal.vl_sld_cred_transportar_fcp,0)
              , vl_deb_esp_fcp              = nvl(gt_row_apur_icms_difal.vl_deb_esp_fcp,0)
         where id = gt_row_apur_icms_difal.id;
         --                                                                                                    
         vn_fase := 8;
         --                                                                                                    
         commit;                                                                                               
         --                                                                                                    
         vn_fase := 9;
         --
         gv_resumo_log := 'Cálculo da Apuração de ICMS-DIFAL realizado com sucesso!';
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_resumo_log
                                          , en_tipo_log        => INFO_APUR_IMPOSTO
                                          , en_referencia_id   => gn_referencia_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --

      end if;
      --
   end if;
   --
exception
   when others then
      --
      update apur_icms_difal set dm_situacao = 2 -- Erro no Calculo
       where id = en_apuricmsdifal_id;
      --
      commit;
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_apuracao fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => en_apuricmsdifal_id
                                          , ev_obj_referencia  => gv_obj_referencia
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_apuracao;

-------------------------------------------------------------------------------------------------------
--| Procedimento Valida a apuração do ICMS DIFAL para todos os estados do período
procedure pkb_validar_geral ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type )
is
   --
   vn_fase  number := 0;
   --
   cursor c_apur is
   select id
     from apur_icms_difal
    where perapuricmsdifal_id = en_perapuricmsdifal_id
    order by id;
   --
begin
   --
   begin
    execute immediate 'alter session set NLS_DATE_FORMAT = ''dd/mm/rrrr'' ';
   end;
   --
   vn_fase := 1;
   --
   gv_geral := 'S';
   --   
   -- recupera os dados do período para utilizar no processo
   pkb_dados_per_apur_icms_difal ( en_perapuricmsdifal_id => en_perapuricmsdifal_id);   
   --
   vn_fase := 1.1;
   --	  
   pkb_insert_tabela_tmp;	  
   --      
   if nvl(en_perapuricmsdifal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_apur
      loop
         --
         exit when c_apur%notfound or (c_apur%notfound) is null;
         --
         vn_fase := 3;
         --
         pkb_validar ( en_apuricmsdifal_id => rec.id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_validar_geral fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => null 
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_validar_geral;

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a apuração do ICMS DIFAL para todos os estados do período
procedure pkb_desfazer_geral ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type )
is
   --
   vn_fase  number := 0;
   --
   cursor c_apur is
   select id
     from apur_icms_difal
    where perapuricmsdifal_id = en_perapuricmsdifal_id
    order by id;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_perapuricmsdifal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_apur
      loop
         --
         exit when c_apur%notfound or (c_apur%notfound) is null;
         --
         vn_fase := 3;
         --
         pkb_desfazer ( en_apuricmsdifal_id => rec.id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_desfazer_geral fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => null 
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_desfazer_geral;

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apuração do ICMS DIFAL para todos os estados do período
procedure pkb_apuracao_geral ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type )
is
   --
   vn_fase  number := 0;
   --
   cursor c_apur is
   select id
     from apur_icms_difal
    where perapuricmsdifal_id = en_perapuricmsdifal_id
    order by id;
   --
begin
   --
   vn_fase := 1;
   --
   gv_geral := 'S';
   --   
   -- recupera os dados do período para utilizar no processo
   pkb_dados_per_apur_icms_difal ( en_perapuricmsdifal_id => en_perapuricmsdifal_id);   
   --
   vn_fase := 1.1;
   --	  
   pkb_insert_tabela_tmp;	  
   --   
   if nvl(en_perapuricmsdifal_id,0) > 0 then
      --
      vn_fase := 2;
      --
      for rec in c_apur
      loop
         --
         exit when c_apur%notfound or (c_apur%notfound) is null;
         --
         vn_fase := 3;
         --
         pkb_apuracao ( en_apuricmsdifal_id => rec.id );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_apuracao_geral fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => null
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_apuracao_geral;

-------------------------------------------------------------------------------------------------------
-- Processo de geração dos estados
procedure pkb_gerar_estados ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type )
is
   --
   vn_fase      number := 0;
   vn_estado_id number := 0;
   --
   cursor c_ies is
   select ies.*
     from ie_subst ies
    where ies.empresa_id = gt_row_per_apur_icms_difal.empresa_id
    order by ies.estado_id;
   --
   cursor c_nfprop is
      select distinct nfd.uf
        from nota_fiscal        nf
           , mod_fiscal         mf
           , nota_fiscal_dest   nfd
           , nota_fiscal_total  nft
       where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
         and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_st_proc      = 4
         and nf.dm_ind_emit     = 0
         --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
         --      or
         --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
         --      or
         --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
         and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nfd.notafiscal_id  = nf.id
         and nft.notafiscal_id  = nf.id
         and ( nvl(nft.vl_icms_uf_dest,0) > 0 or nvl(nft.vl_icms_uf_remet,0) > 0 or nvl(nft.vl_comb_pobr_uf_dest,0) > 0 )
       order by 1;
   --
   cursor c_nfterc is
      select distinct nfe.uf
        from nota_fiscal        nf
           , mod_fiscal         mf
           , nota_fiscal_emit   nfe
           , nota_fiscal_total  nft
       where nf.empresa_id      = gt_row_per_apur_icms_difal.empresa_id
         and nf.dm_arm_nfe_terc = 0 -- Não é nota de armazenamento fiscal
         and nf.dm_st_proc      = 4
         and nf.dm_ind_emit     = 1 -- Terceiro
         --and ((nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
         --      or
         --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim))
         --      or
         --     (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_per_apur_icms_difal.dt_inicio) and trunc(gt_row_per_apur_icms_difal.dt_fim)))
         and ((nf.dm_ind_oper = 1 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and to_date(nf.dt_emiss,'dd/mm/yyyy') between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim)
               or
              (nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and nvl(to_date(nf.dt_sai_ent,'dd/mm/yyyy'),to_date(nf.dt_emiss,'dd/mm/yyyy')) between gt_row_per_apur_icms_difal.dt_inicio and gt_row_per_apur_icms_difal.dt_fim))
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '1B', '04', '55', '65', '06', '29', '28', '21', '22')
         and nfe.notafiscal_id  = nf.id
         and nft.notafiscal_id  = nf.id
         and ( nvl(nft.vl_icms_uf_dest,0) > 0 or nvl(nft.vl_icms_uf_remet,0) > 0 or nvl(nft.vl_comb_pobr_uf_dest,0) > 0 )
       order by 1;
   --
   procedure pkb_ins_apuracao_icms_difal ( en_estado_id  in estado.id%type
                                         )
   is
      --
      vn_qtde      number := 0;
      --
   begin
      --
      if nvl(en_estado_id,0) > 0 then
         --
         begin
            select count(1)
              into vn_qtde
              from apur_icms_difal         ai
             where ai.estado_id            = en_estado_id
               and ai.perapuricmsdifal_id  = gt_row_per_apur_icms_difal.id;
         exception
            when others then
               vn_qtde := 0;
         end;
         --
         if nvl(vn_qtde,0) <= 0 then
            --
            insert into apur_icms_difal ( id
                                        , perapuricmsdifal_id
                                        , estado_id
                                        , dm_situacao
                                        , dm_ind_mov_difal
                                        , vl_sld_cred_ant_difal
                                        , vl_tot_debitos_difal
                                        , vl_out_deb_difal
                                        , vl_tot_deb_fcp
                                        , vl_tot_creditos_difal
                                        , vl_tot_cred_fcp
                                        , vl_out_cred_difal
                                        , vl_sld_dev_ant_difal
                                        , vl_deducoes_difal
                                        , vl_recol
                                        , vl_sld_cred_transportar
                                        , vl_deb_esp_difal
                                        )
                                 values ( apuricmsdifal_seq.nextval
                                        , gt_row_per_apur_icms_difal.id -- perapuricmsdifal_id
                                        , en_estado_id
                                        , 0 -- dm_situacao
                                        , 0 -- dm_ind_mov_difal
                                        , 0 -- vl_sld_cred_ant_difal
                                        , 0 -- vl_tot_debitos_difal
                                        , 0 -- vl_out_deb_difal
                                        , 0 -- vl_tot_deb_fcp
                                        , 0 -- vl_tot_creditos_difal
                                        , 0 -- vl_tot_cred_fcp
                                        , 0 -- vl_out_cred_difal
                                        , 0 -- vl_sld_dev_ant_difal
                                        , 0 -- vl_deducoes_difal
                                        , 0 -- vl_recol
                                        , 0 -- vl_sld_cred_transportar
                                        , 0 -- vl_deb_esp_difal
                                        );
            --
         end if;
         --
         commit;
         --
      end if;
      --
   exception
      when others then
         raise_application_error ( -20101, 'Erro na pk_apur_icms_difal.pkb_ins_apuracao_icms_difal: '||sqlerrm );
   end pkb_ins_apuracao_icms_difal;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_perapuricmsdifal_id,0) > 0 then
      --
      vn_fase := 2;
      -- recupera dados do período
      pkb_dados_per_apur_icms_difal ( en_perapuricmsdifal_id => en_perapuricmsdifal_id );
      --
      vn_fase := 2.1;
      --
      vn_estado_id := pk_csf.fkg_Estado_id(gv_sigla_estado_empresa);
      --
      if nvl(vn_estado_id,0) > 0 then
         --
         pkb_ins_apuracao_icms_difal ( en_estado_id  => vn_estado_id );
         --
      end if;
      --
      vn_fase := 3;
      --
      if nvl(gt_row_per_apur_icms_difal.id,0) > 0 then
         --
         vn_fase := 4;
         --
         -- Recupera as IE-Substituto Tributário
         for rec_ies in c_ies
         loop
            --
            exit when c_ies%notfound or (c_ies%notfound) is null;
            --
            vn_fase := 5;
            --
            pkb_ins_apuracao_icms_difal ( en_estado_id  => rec_ies.estado_id
                                        );
            --
         end loop;
         --
         vn_fase := 6;
         --
         for rec in c_nfprop
         loop
            --
            exit when c_nfprop%notfound or (c_nfprop%notfound) is null;
            --
            vn_fase := 6.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 6.2;
            --
            pkb_ins_apuracao_icms_difal ( en_estado_id  => vn_estado_id
                                        );
            --
         end loop;
         --
         vn_fase := 7;
         --
         for rec in c_nfterc
         loop
            --
            exit when c_nfterc%notfound or (c_nfterc%notfound) is null;
            --
            vn_fase := 7.1;
            --
            vn_estado_id := pk_csf.fkg_Estado_id(rec.uf);
            --
            vn_fase := 7.2;
            --
            pkb_ins_apuracao_icms_difal ( en_estado_id  => vn_estado_id
                                        );
            --
         end loop;
         --
         vn_fase := 99;
         --
         commit;
         --
      end if;
      --
   end if;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_apur_icms_difal.pkb_gerar_estados fase ('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => gv_mensagem_log
                                          , ev_resumo          => gv_mensagem_log
                                          , en_tipo_log        => ERRO_DE_SISTEMA
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => null 
                                          );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_mensagem_log);
      --
end pkb_gerar_estados;

-------------------------------------------------------------------------------------------------------
-- Procedure para Geração da Guia de Pagamento de Imposto
procedure pkg_gera_guia_pgto (en_apuricmsdifal_id   in apur_icms_difal.id%type,
                              en_usuario_id         in neo_usuario.id%type)
is
   --       
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   vn_guiapgtoimp_id    guia_pgto_imp.id%type;
   vv_dt_vencimento     varchar2(10);
   --
begin
   --
   vn_fase := 1;
   --
   begin
      --
      select t.* 
        into gt_row_apur_icms_difal
      from APUR_ICMS_DIFAL t
      where t.id = en_apuricmsdifal_id;
      --
   exception
      when others then
         raise;
   end;
   --
   vn_fase := 1;
   --
   begin
      --
      select t.* 
        into gt_row_per_apur_icms_difal
      from PER_APUR_ICMS_DIFAL t
      where t.id = gt_row_apur_icms_difal.perapuricmsdifal_id;
      --
   exception
      when others then
         raise;
   end;
   --
   -- Geração das Guias do Imposto ICMS-ST ---
   for x in (
      select ord.id obrrecapuricmsdifal_id
           , pai.empresa_id
           , e.pessoa_id
           , pai.dt_inicio
           , pai.dt_fim
           , last_day(pai.dt_fim) dt_ref
           , ord.dt_vcto          dt_vencto
           , ord.vl_or            vl_rec
           , pdgi.dm_tipo
           , pdgi.dm_origem
           , pdgi.pessoa_id_sefaz
           , pdgi.tipoimp_id
           , pdgi.obs
           , pdgi.planoconta_id
           , pdgi.dia_vcto
           , add_months(pai.dt_fim,1) dt_vcto
           --
         from OBR_REC_APUR_ICMS_DIFAL  ord,
              APUR_ICMS_DIFAL          aid,
              PER_APUR_ICMS_DIFAL      pai,
              PARAM_GUIA_PGTO          pgp,
              PARAM_DET_GUIA_IMP      pdgi,
              EMPRESA                 e              
      where aid.id                  =  ord.apuricmsdifal_id
        and pai.id                  =  aid.perapuricmsdifal_id
        and pgp.empresa_id          =  pai.empresa_id
        and pdgi.paramguiapgto_id   =  pgp.id
        and pdgi.tipoimp_id         =  pk_csf.fkg_Tipo_Imposto_id(2) -- ICMS-ST
        and pdgi.dm_origem          =  4                             -- Apuracao ICMS-ST
        and e.id                    =  pdgi.empresa_id_guia
        and aid.id                  =  en_apuricmsdifal_id
         )
   loop
   --
      vn_fase := 3.1;
      --
      vv_dt_vencimento := lpad(x.dia_vcto, 2, '0') || '/' || lpad(extract(month from x.dt_vcto),2, '0') || '/' || extract(year from x.dt_vcto);
      if not pk_csf.fkg_data_valida(vv_dt_vencimento, 'dd/mm/yyyy') then
         raise_application_error (-20101, 'O Parâmetro "PARAM_DET_GUIA_IMP.DIA_VCTO" informa um dia inválido para o mês de apuração - Revise o Parâmetro');
      end if;   
      --
      vn_fase := 3.2;
      --
      -- Popula a Variável de Tabela -- 
      pk_csf_api_gpi.gt_row_guia_pgto_imp.id                       := null;                          
      pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id               := x.empresa_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.usuario_id               := en_usuario_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_situacao              := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id           := x.tipoimp_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id            := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id     := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id                := x.pessoa_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_tipo                  := x.dm_tipo;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_origem                := x.dm_origem;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_via_impressa         := 1;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_ref                   := x.dt_ref;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_vcto                  := to_date(vv_dt_vencimento, 'dd/mm/yyyy');
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_princ                 := x.vl_rec;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_multa                 := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_juro                  := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_outro                 := 0;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.vl_total                 := x.vl_rec;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.obs                      := x.obs;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id_sefaz          := x.pessoa_id_sefaz;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.nro_tit_financ           := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dt_alteracao             := sysdate;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_ret_erp               := case pk_csf.fkg_parametro_geral_sistema(pk_csf.fkg_multorg_id_empresa(x.empresa_id), x.empresa_id, 'GUIA_PGTO', 'RET_ERP', 'LIBERA_AUTOM_GUIA_ERP') when '1' then 0 when '0' then 6 end;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.id_erp                   := null;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.apuricmsdifal_id         := en_apuricmsdifal_id;
      pk_csf_api_gpi.gt_row_guia_pgto_imp.planoconta_id            := x.planoconta_id;
      --
      vn_fase := 3.3;
      --
      -- Chama a procedure de integração e finalização da guia
      pk_csf_api_pgto_imp_ret.pkb_finaliza_pgto_imp_ret(est_log_generico    => vt_csf_log_generico,
                                                        en_empresa_id       => x.empresa_id,
                                                        en_dt_ini           => x.dt_inicio,
                                                        en_dt_fim           => x.dt_fim,
                                                        ev_cod_rec_cd_compl => null,
                                                        sn_guiapgtoimp_id   => vn_guiapgtoimp_id);
      --
      vn_fase := 3.4;
      --
      -- Trata se houve Erro na geração da Guia --
      if nvl(vt_csf_log_generico.count,0) > 0 then
         --
         vn_fase := 3.5;
         --
         update APUR_ICMS_DIFAL
            set dm_situacao_guia = 2 -- Erro
         where id = en_apuricmsdifal_id;
         --
      else
         --
         vn_fase := 3.6;
         --
         update APUR_ICMS_DIFAL
           set dm_situacao_guia = 1 -- Guia Gerada
         where id = en_apuricmsdifal_id;
         --
         vn_fase := 3.7;
         --
         update OBR_REC_APUR_ICMS_DIFAL t set
            t.guiapgtoimp_id = vn_guiapgtoimp_id
         where t.id = x.obrrecapuricmsdifal_id;  
         --
      end if;                                                           
      --
   end loop;   
   --
   commit;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms_difal.pkg_gera_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                          , ev_mensagem       => gv_mensagem_log
                                          , ev_resumo         => gv_resumo_log
                                          , en_tipo_log       => erro_de_sistema
                                          , en_referencia_id  => gt_row_apur_icms_difal.ID
                                          , ev_obj_referencia => gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo_log);
      --     
end pkg_gera_guia_pgto; 
--
-------------------------------------------------------------------------------------------------------
-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_apuricmsdifal_id  in apur_icms_difal.id%type)
is
   --
   vn_fase              number := 0;       
   vt_csf_log_generico  dbms_sql.number_table;
   --
begin
   --
   vn_fase := 1;
   --
   if gt_row_apur_icms_difal.id is null then
      --
      begin
         --
         select t.* 
           into gt_row_apur_icms_difal
         from APUR_ICMS_DIFAL t
         where t.id = en_apuricmsdifal_id;
         --
      exception
         when others then
            raise;
      end;
      --
      vn_fase := 2;
      --
      begin
         --
         select t.* 
           into gt_row_per_apur_icms_difal
         from PER_APUR_ICMS_DIFAL t
         where t.id = gt_row_apur_icms_difal.perapuricmsdifal_id;
         --
      exception
         when others then
            raise;
      end;
      --
   end if;
   --
   vn_fase := 3;
   --
   pk_csf_api_pgto_imp_ret.pkb_estorna_pgto_imp_ret(est_log_generico => vt_csf_log_generico,
                                                    en_empresa_id    => gt_row_per_apur_icms_difal.empresa_id,
                                                    en_dt_ini        => gt_row_per_apur_icms_difal.dt_inicio,
                                                    en_dt_fim        => gt_row_per_apur_icms_difal.dt_fim,
                                                    en_pgtoimpret_id => null);
   --
   vn_fase := 4;
   --
  
   if nvl(vt_csf_log_generico.count,0) > 0 then
      --
      vn_fase := 4.1;
      --
      update APUR_ICMS_DIFAL
         set dm_situacao_guia = 2 -- Erro
       where id = en_apuricmsdifal_id;
      --
      update GUIA_PGTO_IMP t set
        t.dm_situacao = 2 -- Erro de Validação
      where t.apuricmsdifal_id = en_apuricmsdifal_id;
      --
   else
      --
      vn_fase := 4.2;
      --
      update APUR_ICMS_DIFAL
         set dm_situacao_guia = 0 -- Guia Não Gerada
       where id = en_apuricmsdifal_id;
      --
      update GUIA_PGTO_IMP t set
        t.dm_situacao = 3 -- Cancelado
      where t.apuricmsdifal_id = en_apuricmsdifal_id;  
      --      
   end if;                                                           
   --  
   commit;
   --
exception
   when others then
      --
      gv_resumo_log := 'Erro na pk_apur_icms_difal.pkg_estorna_guia_pgto fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id => vn_loggenerico_id
                                          , ev_mensagem       => gv_mensagem_log
                                          , ev_resumo         => gv_resumo_log
                                          , en_tipo_log       => erro_de_sistema
                                          , en_referencia_id  => gt_row_apur_icms_difal.id
                                          , ev_obj_referencia => gv_obj_referencia
                                          );
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, gv_resumo_log);
      --                                                          
end pkg_estorna_guia_pgto; 
--
-------------------------------------------------------------------------------------------------------
end pk_apur_icms_difal;
/
