create or replace package body csf_own.pk_csf_efd is

-------------------------------------------------------------------------------------------------------

-- Função retorna o Código da versão o leiaute da EFD conforme ID

function fkg_cdversao_layout_efd ( en_id  in versao_layout_efd.id%type )
         return versao_layout_efd.cd%type
is

   vn_cd versao_layout_efd.cd%type;

begin
   --
   select vl.cd
     into vn_cd
     from versao_layout_efd vl
    where vl.id = en_id;
   --
   return vn_cd;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cdversao_layout_efd: ' || sqlerrm );
end fkg_cdversao_layout_efd;

-------------------------------------------------------------------------------------------------------

-- Função retorna a versão o leiaute da EFD conforme ID

function fkg_versao_layout_efd ( en_id  in versao_layout_efd.id%type )
         return versao_layout_efd.versao%type
is

   vv_versao versao_layout_efd.versao%type;

begin
   --
   select vl.versao
     into vv_versao
     from versao_layout_efd vl
    where vl.id = en_id;
   --
   return vv_versao;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_versao_layout_efd: ' || sqlerrm );
end fkg_versao_layout_efd;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do leiaute da EFD conforme VERSAO

function fkg_versao_layout_efd_id ( en_cdversao in versao_layout_efd.cd%type
                                  , ev_versao   in versao_layout_efd.versao%type )
         return versao_layout_efd.id%type
is
   --
   vn_id versao_layout_efd.id%type;
   --
begin
   --
   select vl.id
     into vn_id
     from versao_layout_efd vl
    where vl.cd     = en_cdversao
      and vl.versao = ev_versao;
   --
   return vn_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_versao_layout_efd_id: ' || sqlerrm );
end fkg_versao_layout_efd_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o COD do registro_efd conforme ID

function fkg_registro_efd_cod ( en_id  in registro_efd.id%type )
         return registro_efd.cod%type
is

   vv_cod registro_efd.cod%type;

begin
   --
   select cod
     into vv_cod
     from registro_efd
    where id = en_id;
   --
   return vv_cod;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_registro_efd_cod: ' || sqlerrm );
end fkg_registro_efd_cod;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID do registro_efd conforme COD

function fkg_registro_efd_id ( ev_cod  in registro_efd.cod%type )
         return registro_efd.id%type
is

   vn_id registro_efd.id%type;

begin
   --
   select id
     into vn_id
     from registro_efd
    where cod = ev_cod;
   --
   return vn_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_registro_efd_id: ' || sqlerrm );
end fkg_registro_efd_id;

-------------------------------------------------------------------------------------------------------
--#69348 inclusao
-- Função retorna o ID da tabela COD_INF_ADIC_VLR_DECL (Tabela de informações adicionais da apuracão, valores declaratorios (registro E115 do Sped Fiscal))

function fkg_cod_inf_adic_id ( ev_cod_inf  in cod_inf_adic_vlr_decl.cod_inf_adic%type
                                      , ed_dt_ini   in cod_inf_adic_vlr_decl.dt_ini%type
                                      , ed_dt_fin   in cod_inf_adic_vlr_decl.dt_fin%type )
         return cod_inf_adic_vlr_decl.id%type
is
   --
   vn_codinfadicvlrdecl_id   cod_inf_adic_vlr_decl.id%type;
   --
begin
   --
   select co.id
     into vn_codinfadicvlrdecl_id
     from cod_inf_adic_vlr_decl co
    where 1=1
      -- feito desta forma para não ter que alterar a pk_csf_api
      and (upper(co.id)   = upper(ev_cod_inf) or upper(co.cod_inf_adic) = upper(ev_cod_inf))
      and co.dt_ini       <= ed_dt_ini
      and (co.dt_fin is null or co.dt_fin >= ed_dt_fin);
   --
   return vn_codinfadicvlrdecl_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_inf_adic_id: ' || sqlerrm );
end fkg_cod_inf_adic_id;

---------------------------------------------------------------------------------------------------------
--#69348 inclusao
-- Função retorna o COD_INF_ADIC da tabela COD_INF_ADIC_VLR_DECL (Tabela de informações adicionais da apuracão, valores declaratorios (registro E115 do Sped Fiscal))

function fkg_cod_inf_adic_cod_inf ( en_id  in cod_inf_adic_vlr_decl.id%type )
         return cod_inf_adic_vlr_decl.cod_inf_adic%type
is

   vv_cod_inf_adic  cod_inf_adic_vlr_decl.cod_inf_adic%type;

begin
   --
   select cod_inf_adic
     into vv_cod_inf_adic
     from cod_inf_adic_vlr_decl
    where id = en_id;
   --
   return vv_cod_inf_adic;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_inf_adic_cod_inf: ' || sqlerrm );
end fkg_cod_inf_adic_cod_inf;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela COD_OCOR_AJ_ICMS (Ajustes e Informações de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_id ( ev_cod_aj  in cod_ocor_aj_icms.cod_aj%type
                                 , ed_dt_ini  in cod_ocor_aj_icms.dt_ini%type
                                 , ed_dt_fin  in cod_ocor_aj_icms.dt_fin%type )
         return cod_ocor_aj_icms.id%type
is
   --
   vn_codocorajicms_id  cod_ocor_aj_icms.id%type;
   --
begin
   --
   select co.id
     into vn_codocorajicms_id
     from cod_ocor_aj_icms co
    where upper(co.cod_aj) = upper(ev_cod_aj)
      and co.dt_ini       <= ed_dt_ini
      and (co.dt_fin is null or co.dt_fin >= ed_dt_fin);
   --
   return vn_codocorajicms_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_ocor_aj_icms_id: ' || sqlerrm );
end fkg_cod_ocor_aj_icms_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o COD_AJ da tabela COD_OCOR_AJ_ICMS (Ajustes e Informações de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_cod_aj ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.cod_aj%type
is

   vv_cod_aj  cod_ocor_aj_icms.cod_aj%type;

begin
   --
   select cod_aj
     into vv_cod_aj
     from cod_ocor_aj_icms
    where id = en_id;
   --
   return vv_cod_aj;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_ocor_aj_icms_cod_aj: ' || sqlerrm );
end fkg_cod_ocor_aj_icms_cod_aj;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_REFLEXO_APUR da tabela COD_OCOR_AJ_ICMS (Ajustes e Informações de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_ref_apur ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.dm_reflexo_apur%type
is

   vn_dm_reflexo_apur  cod_ocor_aj_icms.dm_reflexo_apur%type;

begin
   --
   select dm_reflexo_apur
     into vn_dm_reflexo_apur
     from cod_ocor_aj_icms
    where id = en_id;
   --
   return vn_dm_reflexo_apur;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_ocor_aj_icms_ref_apur: ' || sqlerrm );
end fkg_cod_ocor_aj_icms_ref_apur;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_TIPO_APUR da tabela COD_OCOR_AJ_ICMS (Ajustes e Informações de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_tp_apur ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.dm_tipo_apur%type
is

   vn_dm_tipo_apur  cod_ocor_aj_icms.dm_tipo_apur%type;

begin
   --
   select dm_tipo_apur
     into vn_dm_tipo_apur
     from cod_ocor_aj_icms
    where id = en_id;
   --
   return vn_dm_tipo_apur;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_ocor_aj_icms_tp_apur: ' || sqlerrm );
end fkg_cod_ocor_aj_icms_tp_apur;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_RESPONS da tabela COD_OCOR_AJ_ICMS (Ajustes e Informações de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_resp ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.dm_respons%type
is

   vn_dm_respons  cod_ocor_aj_icms.dm_respons%type;

begin
   --
   select dm_respons
     into vn_dm_respons
     from cod_ocor_aj_icms
    where id = en_id;
   --
   return vn_dm_respons;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_ocor_aj_icms_resp: ' || sqlerrm );
end fkg_cod_ocor_aj_icms_resp;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_INFL_REC da tabela COD_OCOR_AJ_ICMS (Ajustes e Informações de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_infl ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.dm_infl_rec%type
is

   vn_dm_infl_rec  cod_ocor_aj_icms.dm_infl_rec%type;

begin
   --
   select dm_infl_rec
     into vn_dm_infl_rec
     from cod_ocor_aj_icms
    where id = en_id;
   --
   return vn_dm_infl_rec;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_ocor_aj_icms_infl: ' || sqlerrm );
end fkg_cod_ocor_aj_icms_infl;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_ORIG_TRIB da tabela COD_OCOR_AJ_ICMS (Ajustes e Informações de Valores Provenientes de Documento Fiscal)

function fkg_cod_ocor_aj_icms_orig ( en_id  in cod_ocor_aj_icms.id%type )
         return cod_ocor_aj_icms.dm_orig_trib%type
is

   vn_dm_orig_trib  cod_ocor_aj_icms.dm_orig_trib%type;

begin
   --
   select dm_orig_trib
     into vn_dm_orig_trib
     from cod_ocor_aj_icms
    where id = en_id;
   --
   return vn_dm_orig_trib;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_ocor_aj_icms_orig: ' || sqlerrm );
end fkg_cod_ocor_aj_icms_orig;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela COD_CONS_ITEM_CONT (Codificação do Consumo de Mercadorias/Serviços de Fornecimento Continuo)

function fkg_cod_cons_item_cont_id ( ev_cod_mod   in mod_fiscal.cod_mod%type
                                   , ev_cod_cons  in cod_cons_item_cont.cod_cons%type )
         return cod_cons_item_cont.id%type
is

   vn_codconsitemcont_id cod_cons_item_cont.id%type;

begin
   --
   select id
     into vn_codconsitemcont_id
     from cod_cons_item_cont
    where modfiscal_id = pk_csf.fkg_Mod_Fiscal_id(ev_cod_mod)
      and cod_cons     = ev_cod_cons;
   --
   return vn_codconsitemcont_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_cons_item_cont_id: ' || sqlerrm );
end fkg_cod_cons_item_cont_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código da tabela COD_CONS_ITEM_CONT (Codificação do Consumo de Mercadorias/Serviços de Fornecimento Continuo)
-- através do seu ID

function fkg_id_cons_item_cont_cod ( en_codconsitemcont_id in cod_cons_item_cont.id%type )
         return cod_cons_item_cont.cod_cons%type
is

   vv_cod_cons cod_cons_item_cont.cod_cons%type;

begin
   --
   if nvl(en_codconsitemcont_id, 0) > 0 then
      --
      select cod_cons
        into vv_cod_cons
        from cod_cons_item_cont
       where id  = en_codconsitemcont_id;
      --
   end if;
   --
   return vv_cod_cons;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_id_cons_item_cont_cod: ' || sqlerrm );
end fkg_id_cons_item_cont_cod;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela CLASS_CONS_ITEM_CONT (classificação do Consumo de Mercadorias/Serviços de Fornecimento Continuo)

function fkg_class_cons_item_cont_id ( ev_cod_class  in class_cons_item_cont.cod_class%type )
         return class_cons_item_cont.id%type
is

   vn_classconsitemcont_id  class_cons_item_cont.id%type;

begin
   --
   select id
     into vn_classconsitemcont_id
     from class_cons_item_cont
    where cod_class = ev_cod_class;
   --
   return vn_classconsitemcont_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_class_cons_item_cont_id: ' || sqlerrm );
end fkg_class_cons_item_cont_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela COD_AJ_SALDO_APUR_ICMS (ajustes da apuração de ICMS)

function fkg_cod_aj_saldo_apur_icms_id ( ev_cod_aj_apur  in cod_aj_saldo_apur_icms.cod_aj_apur%type
                                       , ed_dt_ini       in cod_aj_saldo_apur_icms.dt_ini%type
                                       , ed_dt_fin       in cod_aj_saldo_apur_icms.dt_fin%type )
         return cod_aj_saldo_apur_icms.id%type
is
   --
   vn_codajsaldoapuricms_id cod_aj_saldo_apur_icms.id%type;
   --
begin
   --
   select ca.id
     into vn_codajsaldoapuricms_id
     from cod_aj_saldo_apur_icms ca
    where ca.cod_aj_apur = ev_cod_aj_apur
      and ca.dt_ini     <= ed_dt_ini
      and (ca.dt_fin is null or ca.dt_fin >= ed_dt_fin);
   --
   return vn_codajsaldoapuricms_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_aj_saldo_apur_icms_id: ' || sqlerrm );
end fkg_cod_aj_saldo_apur_icms_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_APUR da tabela COD_AJ_SALDO_APUR_ICMS (ajustes da apuração de ICMS)

function fkg_cod_aj_saldo_apur_icms_apu ( en_id  in cod_aj_saldo_apur_icms.id%type )
         return cod_aj_saldo_apur_icms.dm_apur%type
is

   vn_dm_apur cod_aj_saldo_apur_icms.dm_apur%type;

begin
   --
   select dm_apur
     into vn_dm_apur
     from cod_aj_saldo_apur_icms
    where id = en_id;
   --
   return vn_dm_apur;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_aj_saldo_apur_icms_apu: ' || sqlerrm );
end fkg_cod_aj_saldo_apur_icms_apu;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_UTIL da tabela COD_AJ_SALDO_APUR_ICMS (ajustes da apuração de ICMS)

function fkg_cod_aj_saldo_apur_icms_utl ( en_id  in cod_aj_saldo_apur_icms.id%type )
         return cod_aj_saldo_apur_icms.dm_util%type
is

   vn_dm_util cod_aj_saldo_apur_icms.dm_util%type;

begin
   --
   select dm_util
     into vn_dm_util
     from cod_aj_saldo_apur_icms
    where id = en_id;
   --
   return vn_dm_util;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_aj_saldo_apur_icms_utl: ' || sqlerrm );
end fkg_cod_aj_saldo_apur_icms_utl;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela COD_INF_ADIC_VLR_DECL (informações adicionais da apuração, valores declaratórios)

function fkg_cod_inf_adic_vlr_decl_id ( ev_cod_inf_adic  in cod_inf_adic_vlr_decl.cod_inf_adic%type )
         return cod_inf_adic_vlr_decl.id%type
is

   vn_codinfadicvlrdecl_id cod_inf_adic_vlr_decl.id%type;
   
begin
   --
   select id
     into vn_codinfadicvlrdecl_id
     from cod_inf_adic_vlr_decl
    where cod_inf_adic = ev_cod_inf_adic;
   --
   return vn_codinfadicvlrdecl_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_inf_adic_vlr_decl_id: ' || sqlerrm );
end fkg_cod_inf_adic_vlr_decl_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela COD_AJ_APUR_IPI (código de ajuste de IPI)

function fkg_cod_aj_apur_ipi_id ( ev_cod_aj in cod_aj_apur_ipi.cod_aj%type )
         return cod_aj_apur_ipi.id%type
is

   vn_codajapuripi_id  cod_aj_apur_ipi.id%type;

begin
   --
   select id
     into vn_codajapuripi_id
     from cod_aj_apur_ipi
    where cod_aj = ev_cod_aj;
   --
   return vn_codajapuripi_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_aj_apur_ipi_id: ' || sqlerrm );
end fkg_cod_aj_apur_ipi_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o DM_NATUR da tabela COD_AJ_APUR_IPI (código de ajuste de IPI)

function fkg_cod_aj_apur_ipi_natur ( en_id in cod_aj_apur_ipi.id%type )
         return cod_aj_apur_ipi.dm_natur%type
is

   vn_dm_natur  cod_aj_apur_ipi.dm_natur%type;

begin
   --
   select dm_natur
     into vn_dm_natur
     from cod_aj_apur_ipi
    where id = en_id;
   --
   return vn_dm_natur;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_aj_apur_ipi_natur: ' || sqlerrm );
end fkg_cod_aj_apur_ipi_natur;

-------------------------------------------------------------------------------------------------------

-- Função retorna o ID da tabela TIPO_UTIL (TIPOS DE UTILIZAÇÃO DOS CRÉDITOS FISCAIS ICMS)

function fkg_tipo_util_id ( ev_cd  in tipo_util.cd%type )
         return tipo_util.id%type
is

   vn_tipoutil_id  tipo_util.id%type;

begin
   --
   select id
     into vn_tipoutil_id
     from tipo_util
    where cd = ev_cd;
   --
   return vn_tipoutil_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tipo_util_id: ' || sqlerrm );
end fkg_tipo_util_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o COD_IND_BEM da tabela BEM_ATIVO_IMOB

function fkg_bem_ativo_imob_cod_ind_bem ( en_bemativoimob_id in bem_ativo_imob.id%type )
         return bem_ativo_imob.cod_ind_bem%type
is

   vv_cod_ind_bem bem_ativo_imob.cod_ind_bem%type := null;

begin
   --
   if nvl(en_bemativoimob_id, 0) > 0 then
      --
      select cod_ind_bem
        into vv_cod_ind_bem
        from bem_ativo_imob
        where id = en_bemativoimob_id;
      --
    end if;     
   --
   return vv_cod_ind_bem;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_bem_ativo_imob_cod_ind_bem: ' || sqlerrm );
end fkg_bem_ativo_imob_cod_ind_bem;

-------------------------------------------------------------------------------------------------------

-- Função retorna o Conteúdo anterior do campo da tabelaalter_pessoa através do ID

function fkg_cont_ant_id ( en_alterpessoa_id in alter_pessoa.id%type )
         return alter_pessoa.cont_ant%type
is

   vv_cont_ant  alter_pessoa.cont_ant%type;

begin
   --
   if nvl(en_alterpessoa_id,0) > 0 then
      --
      select trim(cont_ant)
        into vv_cont_ant
        from alter_pessoa  ap
       where ap.id  = en_alterpessoa_id;
      --
   end if;
   --
   return vv_cont_ant;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cont_ant_id: ' || sqlerrm );
end fkg_cont_ant_id;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código do ajuste da tabela COD_AJ_SALDO_APUR_ICMS através do identificador

function fkg_cod_codajsaldoapuricms ( en_codajsaldoapuricms_id in cod_aj_saldo_apur_icms.id%type )
         return cod_aj_saldo_apur_icms.cod_aj_apur%type
is
   --
   vv_cod_aj_apur cod_aj_saldo_apur_icms.cod_aj_apur%type;
   --
begin
   --
   select ca.cod_aj_apur
     into vv_cod_aj_apur
     from cod_aj_saldo_apur_icms ca
    where ca.id = en_codajsaldoapuricms_id;
   --
   return vv_cod_aj_apur;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_codajsaldoapuricms: '||sqlerrm );
end fkg_cod_codajsaldoapuricms;

-------------------------------------------------------------------------------------------------------

-- Função retorna o código de informação através do identificador da tabela COD_INF_ADIC_VLR_DECL

function fkg_cod_codinfadicvlrdecl ( en_codinfadicvlrdecl_id in cod_inf_adic_vlr_decl.id%type )
         return cod_inf_adic_vlr_decl.cod_inf_adic%type
is
   --
   vv_cod_inf_adic cod_inf_adic_vlr_decl.cod_inf_adic%type;
   --
begin
   --
   select ci.cod_inf_adic
     into vv_cod_inf_adic
     from cod_inf_adic_vlr_decl ci
    where ci.id = en_codinfadicvlrdecl_id;
   --
   return vv_cod_inf_adic;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_cod_codinfadicvlrdecl: ' || sqlerrm );
end fkg_cod_codinfadicvlrdecl;

-------------------------------------------------------------------------------------------------------

-- Função para recuperar o código IPM (Índice de participação dos municípios) relacionado com empresa e item/produto.

function fkg_recup_cod_ipm_item ( en_empresa_id in empresa.id%type
                                , en_item_id    in item.id%type
                                , en_estado     in estado.id%type )
         return param_ipm.cod_ipm%type
is
   --
   vv_cod_ipm param_ipm.cod_ipm%type;
   --
begin
   --
   begin
      select pi.cod_ipm
        into vv_cod_ipm
        from param_ipm_item pt
           , param_ipm      pi
       where pt.empresa_id = en_empresa_id
         and pt.item_id    = en_item_id
         and pi.id         = pt.paramipm_id
         and pi.estado_id  = en_estado;
   exception
      when no_data_found then
         vv_cod_ipm := null;
      when others then
         raise_application_error(-20101, 'Problemas ao recuperar Código IPM - fkg_recup_cod_ipm_item - en_empresa_id = '||en_empresa_id||' en_item_id = '||
                                         en_item_id||'. Erro: '||sqlerrm);
   end;
   --
   return (vv_cod_ipm);
   --
exception
   when others then
      raise_application_error(-20101, 'Problemas em pk_csf_efd.fkg_recup_cod_ipm_item: '||sqlerrm);
end fkg_recup_cod_ipm_item;

-------------------------------------------------------------------------------------------------------

-- Função retorna os Parâmetros do Sped ICMS/IPI da Empresa
function fkg_param_efd_icms_ipi ( en_empresa_id in empresa.id%type
                                )
         return param_efd_icms_ipi%rowtype
is
   --
   vt_row_param_efd_icms_ipi param_efd_icms_ipi%rowtype;
   --
begin
   --
   select * into vt_row_param_efd_icms_ipi
     from param_efd_icms_ipi
    where empresa_id = en_empresa_id;
   --
   return vt_row_param_efd_icms_ipi;
   --
exception
   when others then
      return null;
end fkg_param_efd_icms_ipi;

-------------------------------------------------------------------------------------------------------

end pk_csf_efd;
/
