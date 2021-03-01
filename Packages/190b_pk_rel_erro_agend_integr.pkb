create or replace package body csf_own.pk_rel_erro_agend_integr is

------------------------------------------------------------------------------------------
--| Corpo da package de relatório de erros do Agendamento de Integração
------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Procedimento grava as informações do relatório
------------------------------------------------------------------------------------------
procedure pkb_grava_imprerroagendintegr
is
   --
   vn_fase       number := 0;
   PRAGMA AUTONOMOUS_TRANSACTION;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(vt_impr_erro_agend_integr.count,0) > 0 then
      --
      vn_fase := 2;
      --
      forAll i in 1 .. vt_impr_erro_agend_integr.count
         insert into impr_erro_agend_integr values vt_impr_erro_agend_integr(i);
      --
      vn_fase := 3;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_grava_imprerroagendintegr ('||vn_fase||'): '||sqlerrm);
end pkb_grava_imprerroagendintegr;
------------------------------------------------------------------------------------------
-- Procedimento que armazena a estrutura do relatorio
------------------------------------------------------------------------------------------
procedure pkb_armaz_imprerroagendintegr ( en_agendintegr_id  in agend_integr.id%type
                                        , en_objintegr_id    in obj_integr.id%type
                                        , en_usuario_id      in neo_usuario.id%type
                                        , el_texto           in impr_erro_agend_integr.texto%type
                                        )
is
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
begin
   --
   vn_fase := 1;
   --
   if el_texto is not null then
      --
      vn_fase := 2;
      --
      i := nvl(vt_impr_erro_agend_integr.count,0) + 1;
      --
      vn_fase := 3;
      --
      select imprerroagendintegr_seq.nextval
        into vt_impr_erro_agend_integr(i).id
        from dual;
      --
      vn_fase := 4;
      --
      vt_impr_erro_agend_integr(i).usuario_id      := en_usuario_id;
      vt_impr_erro_agend_integr(i).agendintegr_id  := en_agendintegr_id;
      vt_impr_erro_agend_integr(i).objintegr_id    := en_objintegr_id;
      vt_impr_erro_agend_integr(i).texto           := el_texto || FINAL_DE_LINHA;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_armaz_imprerroagendintegr ('||vn_fase||'): '||sqlerrm);
end pkb_armaz_imprerroagendintegr;
------------------------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Demais Documentos e Operações - Bloco F EFD Contribuições
------------------------------------------------------------------------------------------------------------
procedure pkb_monta_rel_ddo ( en_agendintegr_id in agend_integr.id%type
                            , en_objintegr_id   in obj_integr.id%type
                            , en_usuario_id     in neo_usuario.id%type
                            , ed_dt_ini_integr  in agend_integr.dt_ini_integr%type
                            , ed_dt_fin_integr  in agend_integr.dt_fin_integr%type
                            , en_empresa_id     in empresa.id%type
                            , en_dm_tipo        in agend_integr.dm_tipo%type
                            , en_multorg_id     in mult_org.id%type
                            , ed_dt_agend       in agend_integr.dt_agend%type
                            , ed_dt_termino     in item_agend_integr.dt_termino%type
                            )
is
   --
   vn_fase          number := 0;
   vl_texto         impr_erro_agend_integr.texto%type;
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number := 0;
   -- Registros Bloco F800
   cursor c_ddo_f800 is
   select em.id empresa_id
        , cd.id creddecoreventopc_id
        , cd.dm_ind_nat_even
        , cd.dt_evento
        , cd.cnpj_suced
        , cd.pa_cont_cred
        , cd.tipocredpc_id
     from empresa              em
        , cred_decor_evento_pc cd
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and cd.empresa_id = em.id
      and cd.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and cd.dt_evento  between ed_dt_ini_integr and ed_dt_fin_integr
    order by em.id
        , cd.dm_ind_nat_even
        , cd.dt_evento;
   -- Registros Bloco F700
   cursor c_ddo_f700 is
   select em.id empresa_id
        , dd.id deducaodiversapc_id
        , trunc(to_date(dd.mes_ref||'/'||dd.ano_ref,'MM/YYYY')) mes_ano_ref
        , dd.dm_ind_ori_ded
        , dd.dm_ind_nat_ded
     from empresa            em
        , deducao_diversa_pc dd
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and dd.empresa_id = em.id
      and dd.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and trunc(to_date(dd.mes_ref||'/'||dd.ano_ref,'MM/YYYY')) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , trunc(to_date(dd.mes_ref||'/'||dd.ano_ref,'MM/YYYY'));
   -- Registros Bloco F600
   cursor c_ddo_f600 is
   select em.id empresa_id
        , cr.id contrretfontepc_id
        , cr.dm_ind_nat_ret
        , cr.dt_ret
        , cr.cnpj
     from empresa            em
        , contr_ret_fonte_pc cr
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and cr.empresa_id = em.id
      and cr.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and cr.dt_ret between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , cr.dm_ind_nat_ret
        , cr.dt_ret;
   -- Registros Blocos F560/F569
   cursor c_ddo_f560 is
   select em.id empresa_id
        , co.id consopinspcrcompaum_id
        , co.dt_ref
        , co.codst_id_pis
        , co.codst_id_cofins
     from empresa                 em
        , cons_op_ins_pcrcomp_aum co
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and co.empresa_id = em.id
      and co.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and co.dt_ref between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , co.dt_ref;
   -- Registros Blocos F550/F559
   cursor c_ddo_f550 is
   select em.id empresa_id
        , co.id consoperinspcrcomp_id
        , co.dt_ref
        , co.codst_id_pis
        , co.codst_id_cofins
     from empresa                em
        , cons_oper_ins_pc_rcomp co
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and co.empresa_id = em.id
      and co.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and co.dt_ref between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , co.dt_ref;
   -- Registros Blocos F525
   cursor c_ddo_f525 is
   select em.id empresa_id
        , cr.id comprecdetrc_id
        , cr.dt_ref
        , cr.dm_ind_rec
     from empresa         em
        , comp_rec_det_rc cr
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and cr.empresa_id = em.id
      and cr.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and cr.dt_ref between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , cr.dt_ref;
   -- Registros Blocos F510/F519
   cursor c_ddo_f510 is
   select em.id empresa_id
        , co.id consoperinspcrcaum_id
        , co.dt_ref
        , co.codst_id_pis
        , co.codst_id_cofins
     from empresa         em
        , cons_oper_ins_pc_rc_aum co
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and co.empresa_id = em.id
      and co.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and co.dt_ref between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , co.dt_ref;
   -- Registros Blocos F500/F509
   cursor c_ddo_f500 is
   select em.id empresa_id
        , co.id consoperinspcrc_id
        , co.dt_ref
        , co.codst_id_pis
        , co.codst_id_cofins
     from empresa             em
        , cons_oper_ins_pc_rc co
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and co.empresa_id = em.id
      and co.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and co.dt_ref between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , co.dt_ref;
   -- Registros Blocos F200/F205/F210/F211
   cursor c_ddo_f200 is
   select em.id empresa_id
        , oa.id operativimobvend_id
        , oa.dm_ind_oper
        , oa.dm_unid_imob
        , oa.ident_emp
        , oa.cpf_cnpj_adqu
        , oa.dt_oper
     from empresa             em
        , oper_ativ_imob_vend oa
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and oa.empresa_id = em.id
      and oa.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and oa.dt_oper between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , oa.dt_oper;
   -- Registros Blocos F150
   cursor c_ddo_f150 is
   select em.id empresa_id
        , cp.id credpresestabertpc_id
        , cp.basecalccredpc_id
        , trunc(to_date(cp.mes_ref||'/'||cp.ano_ref,'MM/YYYY')) mes_ano_ref
        , cp.codst_id_pis
        , cp.codst_id_cofins
     from empresa                em
        , cred_pres_est_abert_pc cp
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and cp.empresa_id = em.id
      and cp.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and trunc(to_date(cp.mes_ref||'/'||cp.ano_ref,'MM/YYYY')) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , trunc(to_date(cp.mes_ref||'/'||cp.ano_ref,'MM/YYYY'));
   -- Registros Blocos F120/F129
   cursor c_ddo_f120 is
   select em.id empresa_id
        , ba.id bemativimobopercredpc_id
        , ba.basecalccredpc_id
        , ba.dm_tipo_oper
        , trunc(to_date(ba.mes_ref||'/'||ba.ano_ref,'MM/YYYY')) mes_ano_ref
        , ba.codst_id_pis
        , ba.codst_id_cofins
     from empresa                    em
        , bem_ativ_imob_oper_cred_pc ba
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and ba.empresa_id = em.id
      and ba.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and trunc(to_date(ba.mes_ref||'/'||ba.ano_ref,'MM/YYYY')) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , trunc(to_date(ba.mes_ref||'/'||ba.ano_ref,'MM/YYYY'));
   -- Registros Blocos F100/F110
   cursor c_ddo_f100 is
   select em.id empresa_id
        , dd.id demdocopergercc_id
        , dd.dm_ind_oper
        , dd.dt_oper
        , dd.codst_id_pis
        , dd.codst_id_cofins
     from empresa             em
        , dem_doc_oper_ger_cc dd
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and dd.empresa_id = em.id
      and dd.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and dd.dt_oper between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by em.id
        , dd.dt_oper;
   --
   cursor c_log( en_referencia_id  in number
               , ev_obj_referencia in varchar2 ) is
   select lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
    where lg.referencia_id  = en_referencia_id
      and lg.obj_referencia = ev_obj_referencia;
   --
   cursor c_log_ddo is
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'CRED_DECOR_EVENTO_PC' -- Bloco F800
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from cred_decor_evento_pc cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'DEDUCAO_DIVERSA_PC' -- BLOCO F700
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from deducao_diversa_pc cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'CONTR_RET_FONTE_PC' -- BLOCO F600
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from contr_ret_fonte_pc cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'CONS_OP_INS_PCRCOMP_AUM' -- BLOCO F560/F569
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from cons_op_ins_pcrcomp_aum cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'CONS_OPER_INS_PC_RCOMP' -- BLOCO F550/F559
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from cons_oper_ins_pc_rcomp cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'COMP_REC_DET_RC' -- BLOCO F525
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from comp_rec_det_rc cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'CONS_OPER_INS_PC_RC_AUM' -- BLOCO F510/F519
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from cons_oper_ins_pc_rc_aum cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'CONS_OPER_INS_PC_RC' -- BLOCO F500/F509
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from cons_oper_ins_pc_rc cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'OPER_ATIV_IMOB_VEND' -- BLOCO F200/F205/F210/F211
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from oper_ativ_imob_vend cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'CRED_PRES_EST_ABERT_PC' -- BLOCO F150
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from cred_pres_est_abert_pc cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia    = 'BEM_ATIV_IMOB_OPER_CRED_PC' -- BLOCO F120/F129
      and tl.id                = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from bem_ativ_imob_oper_cred_pc cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_ddo lg
        , csf_tipo_log     tl
    where lg.obj_referencia    = 'DEM_DOC_OPER_GER_CC' -- BLOCO F100/F110
      and tl.id                = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from dem_doc_oper_ger_cc cd
                       where cd.id = nvl(lg.referencia_id,0));
   --
   --Logs de fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_ddo lg
           , csf_tipo_log     tl
       where lg.empresa_id = en_empresa_id
         and lg.referencia_id is null
         and lg.obj_referencia in('CRED_DECOR_EVENTO_PC', 'DEDUCAO_DIVERSA_PC', 'CONTR_RET_FONTE_PC', 'CONS_OP_INS_PCRCOMP_AUM',
                                  'CONS_OPER_INS_PC_RCOMP', 'COMP_REC_DET_RC', 'CONS_OPER_INS_PC_RC_AUM', 'CONS_OPER_INS_PC_RC',
                                  'OPER_ATIV_IMOB_VEND', 'CRED_PRES_EST_ABERT_PC', 'BEM_ATIV_IMOB_OPER_CRED_PC', 'DEM_DOC_OPER_GER_CC'
                                 )
         and tl.id               = lg.csftipolog_id
         and tl.id               in (ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
       order by lg.id;
   --
   procedure pkb_identificacao_reg ( el_texto in impr_erro_agend_integr.texto%type ) is
   begin
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => el_texto
                                    );
      --
   exception
     when others then
        null;
   end pkb_identificacao_reg;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 0; -- Indicar que sera a primeira interação do cursor
   -- Registros Bloco F800
   --
   -- Fazendo o titulo e cabeçalho do relatório.
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'Demais Documentos e Operações - Bloco F EFD Contribuições.'
                                 );
   --
   vn_fase := 1.2;
   --
 /*  -- Montando o cabeçalho generico.
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'MODULO;EMPRESA;DATA;RESUMO;MENSAGEM'
                                 );
 */  --
   vn_fase := 1.3;
   --
   for r_ddo_f800 in c_ddo_f800
   loop
      --
      exit when c_ddo_f800%notfound or (c_ddo_f800%notfound) is null;
      --
      vn_fase := 2;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f800.empresa_id );
      --
      vn_fase := 3;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f800.creddecoreventopc_id
                        , ev_obj_referencia => 'CRED_DECOR_EVENTO_PC' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            vn_fase := 5;
            --
            pkb_identificacao_reg ( el_texto => 'Integração do bloco F800');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;EVENTO;DT_EVENTO;CNPJ_SUCEDIDA;PERIODO_APURA;TIPO_CRED;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 6;
         --
         vl_texto := 'Integração do bloco F800;'||
                     vv_dados_empresa||';'||
                     --pk_csf.fkg_dominio('CRED_DECOR_EVENTO_PC.DM_IND_NAT_EVEN', r_ddo_f800.dm_ind_nat_even)||';'||
                     r_ddo_f800.dt_evento||';'||
                     --r_ddo_f800.cnpj_suced||';'||
                     --to_char(r_ddo_f800.pa_cont_cred,'mm/rrrr')||';'||
                     --pk_csf_efd_pc.fkg_cd_tipo_cred_pc(r_ddo_f800.tipocredpc_id)||'-'||pk_csf_efd_pc.fkg_descr_tipo_cred_pc(r_ddo_f800.tipocredpc_id)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 7;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 8;
   --vn_first_reg := 1; -- Indicar que sera a primeira interação do cursor
   --
   -- Registros Bloco F700
   for r_ddo_f700 in c_ddo_f700
   loop
      --
      exit when c_ddo_f700%notfound or (c_ddo_f700%notfound) is null;
      --
      vn_fase := 9;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f700.empresa_id );
      --
      vn_fase := 10;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f700.deducaodiversapc_id
                        , ev_obj_referencia => 'DEDUCAO_DIVERSA_PC' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 11;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            vn_fase := 12;
            --
            pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Deduções Diversas - F700');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_REFER;ORIG_DEDUCAO;NATUR_DEDUCAO;RESUMO;MENSAGEM'
                                          );
             --
             vn_first_reg := 0;
             --
         end if;
         --
         vn_fase := 13;
         --
         vl_texto := 'Informações dos logs de Integração de Deduções Diversas - F700;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f700.mes_ano_ref,'mm/rrrr')||';'||
                     --pk_csf.fkg_dominio('DEDUCAO_DIVERSA_PC.DM_IND_ORI_DED', r_ddo_f700.dm_ind_ori_ded)||';'||
                     --pk_csf.fkg_dominio('DEDUCAO_DIVERSA_PC.DM_IND_NAT_DED', r_ddo_f700.dm_ind_nat_ded)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 14;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 15;
   --vn_first_reg := 1;
   --
   -- Registros Bloco F600
   for r_ddo_f600 in c_ddo_f600
   loop
      --
      exit when c_ddo_f600%notfound or (c_ddo_f600%notfound) is null;
      --
      vn_fase := 16;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f600.empresa_id );
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f600.contrretfontepc_id
                        , ev_obj_referencia => 'CONTR_RET_FONTE_PC' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 17;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Contribuições Retida na Fonte - F600');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_RETENCAO;NATUR_RETENCAO;CNPJ;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 18;
         --
         vl_texto := 'Informações dos logs de Integração de Contribuições Retida na Fonte - F600;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f600.dt_ret,'dd/mm/rrrr')||';'||
                     --pk_csf.fkg_dominio('CONTR_RET_FONTE_PC.DM_IND_NAT_RET', r_ddo_f600.dm_ind_nat_ret)||';'||
                     --r_ddo_f600.cnpj||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 19;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 20;
   --vn_first_reg := 1;
   --
   vn_fase := 21;
   -- Registros Bloco F560
   for r_ddo_f560 in c_ddo_f560
   loop
      --
      exit when c_ddo_f560%notfound or (c_ddo_f560%notfound) is null;
      --
      vn_fase := 22;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f560.empresa_id );
      --
      vn_fase := 23;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f560.consopinspcrcompaum_id
                        , ev_obj_referencia => 'CONS_OP_INS_PCRCOMP_AUM' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 24;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de competência (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F560');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_REFER;CST_PIS;CST_COFINS;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 25;
         --
         vl_texto := 'Informações dos logs de Integração de Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de competência (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F560;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f560.dt_ref,'dd/mm/rrrr')||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f560.codst_id_pis)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f560.codst_id_cofins)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 26;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 26;
   --vn_first_reg := 1;
   --
   vn_fase := 28;
   -- Registros Bloco F550
   for r_ddo_f550 in c_ddo_f550
   loop
      --
      exit when c_ddo_f550%notfound or (c_ddo_f550%notfound) is null;
      --
      vn_fase := 29;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f550.empresa_id );
      --
      vn_fase := 30;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f550.consoperinspcrcomp_id
                        , ev_obj_referencia => 'CONS_OPER_INS_PC_RCOMP' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
             --
             pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de Competência - F550');
             -- monta a identificação dos títulos
             pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                           , en_objintegr_id   => en_objintegr_id
                                           , en_usuario_id     => en_usuario_id
                                           , el_texto          => 'EMPRESA;DT_REFER;CST_PIS;CST_COFINS;RESUMO;MENSAGEM'
                                           );
             --
             vn_first_reg := 0;
             --
         end if;
         --
         vn_fase := 31;
         --
         vl_texto := 'Informações dos logs de Integração de Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de Competência - F550;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f550.dt_ref,'dd/mm/rrrr')||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f550.codst_id_pis)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f550.codst_id_cofins)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 32;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 33;
   --vn_first_reg := 1;
   --
   -- Registros Bloco F525
   for r_ddo_f525 in c_ddo_f525
   loop
      --
      exit when c_ddo_f525%notfound or (c_ddo_f525%notfound) is null;
      --
      vn_fase := 34;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f525.empresa_id );
      --
      vn_fase := 35;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f525.comprecdetrc_id
                        , ev_obj_referencia => 'COMP_REC_DET_RC' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 36;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Composição da Receita Escriturada no período - Detalhamento da Receita Recebida pelo Regime de Caixa - F525');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_REFER;IND_RECEITA;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 37;
         --
         vl_texto := 'Informações dos logs de Integração de Composição da Receita Escriturada no período - Detalhamento da Receita Recebida pelo Regime de Caixa - F525;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f525.dt_ref,'dd/mm/rrrr')||';'||
                     --pk_csf.fkg_dominio('COMP_REC_DET_RC.DM_IND_REC', r_ddo_f525.dm_ind_rec)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 38;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 39;
   --vn_first_reg := 1;
   --
   -- Registros Bloco F510
   for r_ddo_f510 in c_ddo_f510
   loop
      --
      exit when c_ddo_f510%notfound or (c_ddo_f510%notfound) is null;
      --
      vn_fase := 40;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f510.empresa_id );
      --
      vn_fase := 41;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f510.consoperinspcrcaum_id
                        , ev_obj_referencia => 'CONS_OPER_INS_PC_RC_AUM' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 42;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de caixa (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F510');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_REFER;CST_PIS;CST_COFINS;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 43;
         --
         vl_texto := 'Informações dos logs de Integração de Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de caixa (Apuração da contribuição por unidade de medida de produto, alíquota em reais) - F510;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f510.dt_ref,'dd/mm/rrrr')||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f510.codst_id_pis)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f510.codst_id_cofins)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 44;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 45;
   --vn_first_reg := 1;
   -- Registros Bloco F500
   for r_ddo_f500 in c_ddo_f500
   loop
      --
      exit when c_ddo_f500%notfound or (c_ddo_f500%notfound) is null;
      --
      vn_fase := 46;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f500.empresa_id );
      --
      vn_fase := 47;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f500.consoperinspcrc_id
                        , ev_obj_referencia => 'CONS_OPER_INS_PC_RC' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 48;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de caixa - F500');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_REFER;CST_PIS;CST_COFINS;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := 'Informações dos logs de Integração de Consolidação das Operações da Pessoa Jurídica Submetida ao Regime de Tributação com Base no Lucro Presumido - Incidência do PIS/COFINS pelo regime de caixa - F500;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f500.dt_ref,'dd/mm/rrrr')||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f500.codst_id_pis)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f500.codst_id_cofins)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 49;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 50;
   --vn_first_reg := 1;
   -- Registros Bloco F200
   for r_ddo_f200 in c_ddo_f200
   loop
      --
      exit when c_ddo_f200%notfound or (c_ddo_f200%notfound) is null;
      --
      vn_fase := 51;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f200.empresa_id );
      --
      vn_fase := 52;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f200.operativimobvend_id
                        , ev_obj_referencia => 'OPER_ATIV_IMOB_VEND' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 53;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Operações da Atividade Imobiliária - Unidade Imobiliária Vendida - F200');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_OPER;IND_OPERACAO;UNIDADE;IDENTIFICADOR;ADQUIRENTE;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 54;
         --
         vl_texto := 'Informações dos logs de Integração de Operações da Atividade Imobiliária - Unidade Imobiliária Vendida - F200;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f200.dt_oper,'dd/mm/rrrr')||';'||
                     --pk_csf.fkg_dominio('OPER_ATIV_IMOB_VEND.DM_IND_OPER', r_ddo_f200.dm_ind_oper)||';'||
                     --pk_csf.fkg_dominio('OPER_ATIV_IMOB_VEND.DM_UNID_IMOB', r_ddo_f200.dm_unid_imob)||';'||
                     --r_ddo_f200.ident_emp||';'||
                     --r_ddo_f200.cpf_cnpj_adqu||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 55;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 56;
   --vn_first_reg := 1;
   -- Registros Bloco F150
   for r_ddo_f150 in c_ddo_f150
   loop
      --
      exit when c_ddo_f150%notfound or (c_ddo_f150%notfound) is null;
      --
      vn_fase := 57;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f150.empresa_id );
      --
      vn_fase := 58;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f150.credpresestabertpc_id
                        , ev_obj_referencia => 'CRED_PRES_EST_ABERT_PC' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            vn_fase := 59;
            --
            pkb_identificacao_reg ( el_texto => 'Integração do bloco F150');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_REFER;BASE_CALC_CRED;CST_PIS;CST_COFINS;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 60;
         --
         vl_texto := 'Integração do bloco F150;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f150.mes_ano_ref,'dd/mm/rrrr')||';'||
                     --pk_csf_efd_pc.fkg_base_calc_cred_pc_cd(r_ddo_f150.basecalccredpc_id)||'-'||pk_csf_efd_pc.fkg_descr_basecalccredpc(r_ddo_f150.basecalccredpc_id)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f150.codst_id_pis)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f150.codst_id_cofins)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 61;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 62;
   --vn_first_reg := 1;
   -- Registros Bloco f120
   for r_ddo_f120 in c_ddo_f120
   loop
      --
      exit when c_ddo_f120%notfound or (c_ddo_f120%notfound) is null;
      --
      vn_fase := 63;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f120.empresa_id );
      --
      vn_fase := 64;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f120.bemativimobopercredpc_id
                        , ev_obj_referencia => 'BEM_ATIV_IMOB_OPER_CRED_PC' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Bens do Ativo Imobilizado operacoes gerados de credito Pis/Cofins F120/F130');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_REFER;BASE_CALC_CRED;TIPO_OPER;CST_PIS;CST_COFINS;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 65;
         --
         vl_texto := 'Informações dos logs de Integração de Bens do Ativo Imobilizado operacoes gerados de credito Pis/Cofins F120/F130;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f120.mes_ano_ref,'dd/mm/rrrr')||';'||
                     --pk_csf.fkg_dominio('BEM_ATIV_IMOB_OPER_CRED_PC.DM_TIPO_OPER',r_ddo_f120.dm_tipo_oper)||';'||
                     --pk_csf_efd_pc.fkg_base_calc_cred_pc_cd(r_ddo_f120.basecalccredpc_id)||'-'||pk_csf_efd_pc.fkg_descr_basecalccredpc(r_ddo_f120.basecalccredpc_id)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f120.codst_id_pis)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f120.codst_id_cofins)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 66;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 67;
   --vn_first_reg := 1;
   -- Registros Bloco f100
   for r_ddo_f100 in c_ddo_f100
   loop
      --
      exit when c_ddo_f100%notfound or (c_ddo_f100%notfound) is null;
      --
      vn_fase := 68;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_ddo_f100.empresa_id );
      --
      vn_fase := 69;
      --
      for r_log in c_log( en_referencia_id  => r_ddo_f100.demdocopergercc_id
                        , ev_obj_referencia => 'DEM_DOC_OPER_GER_CC' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            vn_fase := 70;
            --
            pkb_identificacao_reg ( el_texto => 'Informações dos logs de Integração de Demais Documentos e Operações Geradoras de Contribuiçõo e Creditos F100');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DT_OPER;TIPO_OPER;CST_PIS;CST_COFINS;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 71;
         --
         vl_texto := 'Informações dos logs de Integração de Demais Documentos e Operações Geradoras de Contribuiçõo e Creditos F100;'||
                     vv_dados_empresa||';'||
                     to_char(r_ddo_f100.dt_oper,'dd/mm/rrrr')||';'||
                     --pk_csf.fkg_dominio('DEM_DOC_OPER_GER_CC.DM_IND_OPER',r_ddo_f100.dm_ind_oper)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f100.codst_id_pis)||';'||
                     --pk_csf.fkg_cod_st_cod(r_ddo_f100.codst_id_cofins)||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 72;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 73;
   --   
   --#69214 inicia o cabecalho
   vn_first_reg := 1;
   -- Gerar todos os logs - DDO
   for r_log_ddo in c_log_ddo
   loop
      --
      exit when c_log_ddo%notfound or (c_log_ddo%notfound) is null;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;DATA_HR_LOG;RESUMO;MENSAGEM;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 74;
      --
      -- #69214 ajuste excel
      vl_texto := r_log_ddo.tipo||';'||
                  to_char(r_log_ddo.dt_hr_log,'dd/mm/rrrr') ||';'||
                  pk_csf.fkg_converte(r_log_ddo.resumo)     ||';'||
                  pk_csf.fkg_converte(r_log_ddo.mensagem)   ||';';
      --
      vn_fase := 75;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 75;
   --
   --#69214 inicia o cabecalho
   vn_first_reg := 1;
   --
   --Logs de fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => rec.empresa_id);
      --
      --#69214 incluida cabecalho generico somente aqui.
      if nvl(vn_first_reg,0) = 1 then
        -- Montando o cabeçalho generico.
        pkb_armaz_imprerroagendintegr (en_agendintegr_id => en_agendintegr_id
                                     , en_objintegr_id   => en_objintegr_id
                                     , en_usuario_id     => en_usuario_id
                                     , el_texto          => 'MODULO;EMPRESA;DATA;RESUMO;MENSAGEM'
                                     );
        --
        vn_first_reg := 0;
        --
      end if;
      --
      vl_texto := null;
      vl_texto := 'Informação sobre o fechamento fiscal' || ';'
               || vv_dados_empresa|| ';'
                                  || ';'
               || pk_csf.fkg_converte(rec.resumo) || ';'
               || pk_csf.fkg_converte(rec.mensagem)|| ';';
      --
      vn_fase := 75.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_ddo ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_ddo;

-------------------------------------------------------------------------------------------
-- Procedimento para a geração dos dados de erro do Bloco I
-------------------------------------------------------------------------------------------
procedure pkb_monta_rel_blocoi ( en_agendintegr_id in agend_integr.id%type
                               , en_objintegr_id   in obj_integr.id%type
                               , en_usuario_id     in neo_usuario.id%type
                               , ed_dt_ini_integr  in agend_integr.dt_ini_integr%type
                               , ed_dt_fin_integr  in agend_integr.dt_fin_integr%type
                               , en_empresa_id     in empresa.id%type
                               , en_dm_tipo        in agend_integr.dm_tipo%type
                               , en_multorg_id     in mult_org.id%type
                               )
is
   --
   vn_fase          number;
   vn_first_reg     number;
   --
   vv_dados_empresa varchar2(255);
   --
   vl_texto         impr_erro_agend_integr.texto%type;
   --
begin
   --
   null;
   --
exception
   when others then
      --
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_blocoi ('||vn_fase||'): '||sqlerrm);
      --
end pkb_monta_rel_blocoi;

------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Controle da produção e do estoque
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_contr_prod_estq ( en_agendintegr_id in agend_integr.id%type
                                        , en_objintegr_id   in obj_integr.id%type
                                        , en_usuario_id     in neo_usuario.id%type
                                        , ed_dt_ini_integr  in agend_integr.dt_ini_integr%type
                                        , ed_dt_fin_integr  in agend_integr.dt_fin_integr%type
                                        , en_empresa_id     in empresa.id%type
                                        , en_dm_tipo        in agend_integr.dm_tipo%type
                                        , en_multorg_id     in mult_org.id%type
                                        , ed_dt_agend       in agend_integr.dt_agend%type
                                        , ed_dt_termino     in item_agend_integr.dt_termino%type
                                        )
is
   --
   vn_fase          number := 0;
   vl_texto         impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number := 0;
   --
   cursor c_per is
   select pc.id
        , pc.empresa_id
        , pc.dt_ini
        , pc.dt_fin
     from empresa              e
        , per_contr_prod_estq  pc
    where e.multorg_id = en_multorg_id
      and pc.empresa_id = e.id
      and pc.dm_st_proc = 2 -- 0-Não validado, 1-Validado, 2-Erro de validação
      and ( en_dm_tipo not in (1) or (pc.empresa_id = en_empresa_id) )
      and pc.dt_ini >= ed_dt_ini_integr
      and pc.dt_fin <= ed_dt_fin_integr
    order by pc.id;
   --
   cursor c_log ( en_referencia_id in log_generico_cpe.id%type ) is
   select lgc.*
     from log_generico_cpe  lgc
        , csf_tipo_log  tl
    where lgc.referencia_id  = en_referencia_id
      and lgc.obj_referencia = 'PER_CONTR_PROD_ESTQ'
      and tl.id              = lgc.csftipolog_id
      and tl.cd_compat       in ('1','2')
    order by lgc.id;
   --
   --log fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_cpe lg
           , csf_tipo_log     tl
       where lg.referencia_id is null
         and lg.empresa_id = en_empresa_id
         and lg.obj_referencia in ( 'CORR_APONT_EST'
                                  , 'CORR_APONT_RET_INS'
                                  , 'CORR_APONT_REG'
                                  , 'REPR_REPA_MERC_CONS_RET'
                                  , 'REPR_REPA_PROD_INS'
                                  , 'INDUSTR_EM_TERC'
                                  , 'INDUSTR_POR_TERC'
                                  , 'INSUMO_CONS'
                                  , 'ITEM_PRODUZ'
                                  , 'DESMON_MERC_ITEM_DEST'
                                  , 'DESMON_MERC_ITEM_ORIG'
                                  , 'OUTR_MOVTO_INTER_MERC'
                                  , 'ESTQ_ESCRIT'
                                  , 'PER_CONTR_PROD_ESTQ'
                                  , 'PROD_CJTA_ORDPROD'
                                  , 'PROD_CJTA_ITEMPROD'
                                  , 'PROD_CJTA_INSCONS'
                                  , 'PROD_CJTA_INDTERC'
                                  , 'PROD_CJTA_INDTERC_IP'
                                  , 'PROD_CJTA_INDTERC_IC'
                                  )
         and tl.id               = lg.csftipolog_id
         and tl.id               in (ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_per loop
      exit when c_per%notfound or (c_per%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 4;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 5;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'Informações dos logs de Integração de Período de controle da produção e do estoque'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;DATA_INICIAL;DATA_FINAL;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || rec.dt_ini || ';'
                     || rec.dt_fin || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';'
                     || pk_csf.fkg_converte(rec2.mensagem) || ';';
         --
         vn_fase := 6;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 7;
   --
   --Log fechamento fiscal
   vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id (en_empresa_id => en_empresa_id);
   --
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or(c_fecha_fiscal%notfound) is null;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'Informações dos logs de Integração de Período de controle da produção e do estoque'
                                       );
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'EMPRESA;DATA_INICIAL;DATA_FINAL;RESUMO;MENSAGEM'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)   || ';'
               || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 7.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_contr_prod_estq ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_contr_prod_estq;
------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Informações da DIRF
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_dirf ( en_agendintegr_id  in agend_integr.id%type
                             , en_objintegr_id    in obj_integr.id%type
                             , en_usuario_id      in neo_usuario.id%type
                             , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                             , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                             , en_empresa_id      in empresa.id%type
                             , en_dm_tipo         in agend_integr.dm_tipo%type
                             , en_multorg_id      in mult_org.id%type
                             , ed_dt_agend        in agend_integr.dt_agend%type
                             , ed_dt_termino      in item_agend_integr.dt_termino%type
                             )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   vn_first_reg      number := 0;
   --
   vv_dados_empresa varchar2(255) := null;
   vv_cod_part      pessoa.cod_part%type := null;
   --
   cursor c_dirf is
   select ird.id
        , ird.empresa_id
        , ird.pessoa_id
        , ird.ano_ref
     from empresa       e
        , inf_rend_dirf ird
    where e.multorg_id    = en_multorg_id
      and ird.empresa_id  = e.id
      and ird.dm_situacao = 2
      and ( en_dm_tipo not in (1) or (ird.empresa_id = en_empresa_id) )
      and to_date( ird.ano_ref ,'YYYY') between to_date(ed_dt_ini_integr,'YYYY') and to_date(ed_dt_fin_integr,'YYYY')
    order by ird.id;
   --
   cursor c_log ( en_referencia_id in log_generico_ird.id%type ) is
   select lgi.*
     from log_generico_ird  lgi
        , csf_tipo_log  tl
    where lgi.referencia_id     = en_referencia_id
      and lgi.obj_referencia    = 'INF_REND_DIRF'
      and tl.id                 = lgi.csftipolog_id
      and tl.cd_compat          in ('1','2')
    order by lgi.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_dirf loop
      exit when c_dirf%notfound or (c_dirf%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      -- recupera o código do participante
      vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Informações dos logs de Integração de Informes de Rendimentos da DIRF'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;COD_PART;ANO_REF;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 4;
         --
         vl_texto := vv_dados_empresa || ';'
                     || vv_cod_part || ';'
                     || rec.ano_ref || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';'
                     || pk_csf.fkg_converte(rec2.mensagem) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_dirf ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_dirf;
--------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Retenções ocorridas nos recebimentos
--------------------------------------------------------------------------------------
procedure pkb_monta_rel_imp_ret_rec_pc ( en_agendintegr_id  in agend_integr.id%type
                                       , en_objintegr_id    in obj_integr.id%type
                                       , en_usuario_id      in neo_usuario.id%type
                                       , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                                       , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                                       , en_empresa_id      in empresa.id%type
                                       , en_dm_tipo         in agend_integr.dm_tipo%type
                                       , ed_dt_agend        in agend_integr.dt_agend%type
                                       , ed_dt_termino      in item_agend_integr.dt_termino%type
                                       )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   vn_first_reg    number := null;
   --
   vv_dados_empresa varchar2(255) := null;
   vv_cod_part      pessoa.cod_part%type;
   --
   cursor c_retrecpc is
   select irrp.id
        , irrp.empresa_id
        , irrp.pessoa_id
        , irrp.dt_ret
        , irrp.ident_rec
     from imp_ret_rec_pc irrp
    where irrp.dm_st_proc = 2
      and ( en_dm_tipo not in (1) or (irrp.empresa_id = en_empresa_id) )
      and trunc(irrp.dt_ret) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by irrp.id;
   --
   cursor c_log ( en_referencia_id in log_generico_pir.id%type ) is
   select lgp.*
     from log_generico_pir lgp
        , csf_tipo_log     tl
    where lgp.referencia_id  = en_referencia_id
      and lgp.obj_referencia = 'IMP_RET_REC_PC'
      and tl.id              = lgp.csftipolog_id
      and tl.cd_compat      in ('1','2');
   --
   cursor c_log_pir is
   select lgp.*
     from log_generico_pir lgp
        , csf_tipo_log     tl
    where lgp.obj_referencia    = 'IMP_RET_REC_PC'
      and tl.id                 = lgp.csftipolog_id
      and tl.cd_compat         in ('1','2')
      and trunc(lgp.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgp.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and lgp.referencia_id   is not null
      and not exists (select irrp.id
                        from imp_ret_rec_pc irrp
                       where irrp.id = lgp.referencia_id);
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_retrecpc loop
      exit when c_retrecpc%notfound or (c_retrecpc%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;DATA_HR_LOG;EMPRESA;COD_PART;DATA_RETENCAO;IDENT_REC;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 4;
         --
         vl_texto := 'IMP_RET_REC_PC;'
                     || rec2.dt_hr_log || ';'
                     || vv_dados_empresa || ';'
                     || vv_cod_part || ';'
                     || to_char(rec.dt_ret, 'dd/mm/rrrr') || ';'
                     || rec.ident_rec || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   vn_first_reg := 1;
   --
   for rec2 in c_log_pir
   loop
      --
      exit when c_log_pir%notfound or (c_log_pir%notfound) is null;
      --
      vn_fase := 6;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;DATA_HR_LOG;EMPRESA;COD_PART;DATA_RETENCAO;IDENT_REC;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 7;
      --
      vl_texto := 'IMP_RET_REC_PC'                     ||';'||
                  to_char(rec2.dt_hr_log,'dd/mm/rrrr') ||';;;;'||
                  pk_csf.fkg_converte(rec2.resumo)     ||';'||
                  pk_csf.fkg_converte(rec2.mensagem)   ||';';
      --
      vn_fase := 7.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_imp_ret_rec_pc ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_imp_ret_rec_pc;
-------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Creditos de Impostos no padrão para DCTF
-------------------------------------------------------------------------------------------
--#68800 inclusao da proc nova 
procedure pkb_monta_rel_imp_cred_dctf (  en_agendintegr_id  in agend_integr.id%type
                                       , en_objintegr_id    in obj_integr.id%type
                                       , en_usuario_id      in neo_usuario.id%type
                                       , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                                       , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                                       , en_empresa_id      in empresa.id%type
                                       , en_dm_tipo         in agend_integr.dm_tipo%type
                                       , ed_dt_agend        in agend_integr.dt_agend%type
                                       , ed_dt_termino      in item_agend_integr.dt_termino%type                                                                    
                                       )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   vn_first_reg    number := null;
   --
   vv_dados_empresa varchar2(255) := null;
   vv_cod_part      pessoa.cod_part%type;
   --
   cursor c_cred_dctf is
   select i.id
         ,i.empresa_id
         ,i.pessoa_id
         ,i.dt_periodo_apur
     from imp_cred_dctf i
    where i.empresa_id = en_empresa_id
      and i.dm_situacao = 2 --erro
      and trunc(i.dt_periodo_apur) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by i.id;
   --   
   cursor c_log ( en_referencia_id in log_generico_pir.id%type ) is
   select lgp.*
     from log_generico_pir lgp
        , csf_tipo_log     tl
    where lgp.referencia_id  = en_referencia_id
      and lgp.obj_referencia = 'CRED_DCTF' 
      and tl.id              = lgp.csftipolog_id
      and tl.cd_compat      in ('1','2')
      and trunc(lgp.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgp.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      ;
   --
   cursor c_log_pir is
   select lgp.*
     from log_generico_pir lgp
        , csf_tipo_log     tl
    where lgp.obj_referencia    = 'CRED_DCTF'
      and tl.id                 = lgp.csftipolog_id
      and tl.cd_compat         in ('1','2')
      and trunc(lgp.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgp.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and lgp.referencia_id   is not null
      and not exists (select icd.id
                        from imp_cred_dctf icd
                       where icd.id = lgp.referencia_id)
     ;
   --
   cursor c_log_pir2 is
   select distinct lgp.empresa_id, to_char(dt_hr_log,'dd/mm/rrrr') dt_hr_log, lgp.resumo, lgp.mensagem
     from log_generico_pir lgp
        , csf_tipo_log     tl
    where lgp.obj_referencia    = 'CRED_DCTF'
      and tl.id                 = lgp.csftipolog_id
      and tl.cd_compat         in ('1','2')
      and trunc(lgp.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgp.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and lgp.referencia_id is null
      ;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_cred_dctf loop
      exit when c_cred_dctf%notfound or (c_cred_dctf%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;DATA_HR_LOG;EMPRESA;COD_PART;DATA_RETENCAO;IDENT_REC;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 4;
         --
         vl_texto := 'CRED_DCTF;'
                     || rec2.dt_hr_log || ';'
                     || vv_dados_empresa || ';'
                     || vv_cod_part || ';'
                     || to_char(rec.dt_periodo_apur, 'dd/mm/rrrr') || ';'
                     || rec.dt_periodo_apur || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   vn_first_reg := 1;
   --
   for rec3 in c_log_pir
   loop
      --
      exit when c_log_pir%notfound or (c_log_pir%notfound) is null;
      --
      vn_fase := 6;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;DATA_HR_LOG;EMPRESA;COD_PART;DATA_RETENCAO;IDENT_REC;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 7;
      --
      vl_texto := 'CRED_DCTF'                     ||';'||
                  to_char(rec3.dt_hr_log,'dd/mm/rrrr') ||';;;;'||
                  pk_csf.fkg_converte(rec3.resumo)     ||';'||
                  pk_csf.fkg_converte(rec3.mensagem)   ||';';
      --
      vn_fase := 7.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 8;
   vn_first_reg := 1;
   --
   for rec4 in c_log_pir2
   loop
      --
      exit when c_log_pir2%notfound or (c_log_pir2%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec4.empresa_id );
      --
      vn_fase := 9;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;DATA_HR_LOG;EMPRESA;COD_PART;DATA_RETENCAO;IDENT_REC;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 10;
      --
      vl_texto := 'CRED_DCTF'                           ||';'||
                  rec4.dt_hr_log                        ||';'||
                  vv_dados_empresa                      ||';;;'||
                  pk_csf.fkg_converte(rec4.resumo)      ||';'||
                  pk_csf.fkg_converte(rec4.mensagem)    ||';';
      --
      vn_fase := 7.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_imp_cred_dctf ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_imp_cred_dctf;
--------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Pagamento de Impostos no padrão para DCTF
--------------------------------------------------------------------------------------------
procedure pkb_monta_rel_pgto_imp_ret ( en_agendintegr_id  in agend_integr.id%type
                                     , en_objintegr_id    in obj_integr.id%type
                                     , en_usuario_id      in neo_usuario.id%type
                                     , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                                     , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                                     , en_empresa_id      in empresa.id%type
                                     , en_dm_tipo         in agend_integr.dm_tipo%type
                                     , ed_dt_agend        in agend_integr.dt_agend%type
                                     , ed_dt_termino      in item_agend_integr.dt_termino%type
                                     )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number        := null;
   --
   cursor c_pgtoimpret is
   select pir.id
        , pir.empresa_id
        , pir.nro_doc
        , pir.dt_pgto
     from pgto_imp_ret pir
    where pir.dm_situacao = 2
      and ( en_dm_tipo not in (1) or (pir.empresa_id = en_empresa_id) )
      and trunc(nvl(pir.dt_docto, pir.dt_pgto)) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
      --and trunc(pir.dt_pgto) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by pir.id;
   --
   cursor c_log ( en_referencia_id in log_generico_pir.id%type ) is
   select lgp.*
     from log_generico_pir lgp
        , csf_tipo_log     tl
    where lgp.referencia_id  = en_referencia_id
      and lgp.obj_referencia = 'PGTO_IMP_RET'
      and tl.id              = lgp.csftipolog_id
      and tl.cd_compat      in ('1','2');
   --
   cursor c_log_pir is
   select lgp.*
     from log_generico_pir lgp
        , csf_tipo_log     tl
    where lgp.obj_referencia    = 'PGTO_IMP_RET'
      and tl.id                 = lgp.csftipolog_id
      and tl.cd_compat         in ('1','2')
      and trunc(lgp.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgp.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and lgp.referencia_id    is not null
      and not exists (select pir.id
                        from pgto_imp_ret pir
                       where pir.id = lgp.referencia_id);
   --
   cursor c_log_pir2 is
   select distinct to_char(dt_hr_log,'dd/mm/rrrr') dt_hr_log, lgp.resumo, lgp.mensagem
     from log_generico_pir lgp
        , csf_tipo_log     tl
    where lgp.obj_referencia    = 'PGTO_IMP_RET'
      and tl.id                 = lgp.csftipolog_id
      and tl.cd_compat         in ('1','2')
      and trunc(lgp.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgp.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and lgp.referencia_id is null
      ;
   
   --Log fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_pir lg
           , csf_tipo_log     tl
       where lg.referencia_id    is null
         and lg.empresa_id        = en_empresa_id
         and lg.obj_referencia   in ('IMP_RET_REC_PC', 'PGTO_IMP_RET','CRED_DCTF')--#68800 incluido cred_dctf
         and tl.id                = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   --
   for rec in c_pgtoimpret loop
      exit when c_pgtoimpret%notfound or (c_pgtoimpret%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'TIPO;DATA_HR_LOG;VAZIO;VAZIO;VAZIO;RESUMO;MENSAGEM;'
                                 );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := null;
         --
         vl_texto := 'PGTO_IMP_RET;'
                     || rec2.dt_hr_log || ';;;;'
                     || pk_csf.fkg_converte(rec2.resumo) || ';'
                     || pk_csf.fkg_converte(rec2.mensagem) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   for rec2 in c_log_pir
   loop
      --
      exit when c_log_pir%notfound or (c_log_pir%notfound) is null;
      --
      vn_fase := 7;
      --
      if nvl(vn_first_reg,0) = 1 then
        --
        pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                             , en_objintegr_id   => en_objintegr_id
                             , en_usuario_id     => en_usuario_id
                             , el_texto          => 'TIPO;DATA_HR_LOG;VAZIO;VAZIO;VAZIO;RESUMO;MENSAGEM;'
                             );
        --
        vn_first_reg := 0;
        --
      end if;
      --
      vl_texto := null;
      --
      vl_texto := 'PGTO_IMP_RET'                       ||';'||
                  to_char(rec2.dt_hr_log,'dd/mm/rrrr') ||';;;;'||
                  pk_csf.fkg_converte(rec2.resumo)     ||';'||
                  pk_csf.fkg_converte(rec2.mensagem)   ||';';
      --
      vn_fase := 7.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 8;
   --
   for rec4 in c_log_pir2
   loop
      --
      exit when c_log_pir2%notfound or (c_log_pir2%notfound) is null;
      --
      vn_fase := 9;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;DATA_HR_LOG;VAZIO;VAZIO;VAZIO;RESUMO;MENSAGEM;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 10;
      --
      vl_texto := 'PGTO_IMP_RET'                       ||';'||
                  rec4.dt_hr_log                       ||';;;;'||
                  pk_csf.fkg_converte(rec4.resumo)     ||';'||
                  pk_csf.fkg_converte(rec4.mensagem)   ||';';
      --
      vn_fase := 7.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --   
   --Log fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id (en_empresa_id => rec.empresa_id);
      --
      if nvl(vn_first_reg,0) = 1 then
        --
        pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                             , en_objintegr_id   => en_objintegr_id
                             , en_usuario_id     => en_usuario_id
                             , el_texto          => 'TIPO;DATA_HR_LOG;VAZIO;VAZIO;VAZIO;RESUMO;MENSAGEM;'
                             );
        --
        vn_first_reg := 0;
        --
      end if;
      --
      vl_texto := null;
      --
      vl_texto := 'Informação de fechamento fiscal' || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)   || ';'
               || pk_csf.fkg_converte(rec.mensagem) ||';';
      --
      vn_fase := 8.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_pgto_imp_ret ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_pgto_imp_ret;
------------------------------------------------------------------------------------------
-- Procedimento para geração do relatório de erro do MANAD
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_manad ( en_agendintegr_id  in agend_integr.id%type
                              , en_objintegr_id    in obj_integr.id%type
                              , en_usuario_id      in neo_usuario.id%type
                              , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                              , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                              , en_multorg_id      in mult_org.id%type
                              , ed_dt_agend        in agend_integr.dt_agend%type
                              , ed_dt_termino      in item_agend_integr.dt_termino%type
                              )
is
   --
   vn_fase                number := 0;
   vl_texto               impr_erro_agend_integr.texto%type;
   vv_dados_empresa       varchar2(255) := null;
   vv_cod_reg_trab        trabalhador.cod_reg_trab%type    := null;
   --
   vv_cod_ltc             lotacao_folha.cod_ltc%type       := null;
   vv_cod_rubrica         rubrica_folha.cod_rubrica%type   := null;
   vd_dt_cont             cont_folha_pgto.dt_cont%type     := null;
   --
   vv_cod_cta             plano_conta.cod_cta%type         := null;
   vv_cod_ccus            centro_custo.cod_ccus%type       := null;
   vn_ano                 inf_folha_pgto.ano%type          := null;
   vn_mes                 inf_folha_pgto.mes%type          := null;
   --
   vn_dm_ind_fl           mestre_folha_pgto.dm_ind_fl%type := null;
   vd_dt_comp             mestre_folha_pgto.dt_comp%type   := null;
   vn_first_reg           number := null;
   vn_first_title         number := null;
   --
   vn_empresa_id          empresa.id%type;
   --
   cursor c_trabalhador is
   select lgi.resumo
        , lgi.mensagem
        , lgi.referencia_id
     from log_generico_ifp lgi
    where lgi.obj_referencia   = 'TRABALHADOR'
      and trunc(lgi.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgi.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lgi.resumo;
   --
   cursor c_lotacao_folha is
   select lgi.resumo
        , lgi.mensagem
        , lgi.referencia_id
     from log_generico_ifp lgi
    where lgi.obj_referencia   = 'LOTACAO_FOLHA'
      and trunc(lgi.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgi.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lgi.resumo;
   --
   cursor c_rubrica_folha is
   select lgi.resumo
        , lgi.mensagem
        , lgi.referencia_id
     from log_generico_ifp lgi
    where lgi.obj_referencia   = 'RUBRICA_FOLHA'
      and trunc(lgi.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgi.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lgi.resumo;
   --
   cursor c_cont_folha_pgto is
   select lgi.resumo
        , lgi.mensagem
        , lgi.referencia_id
     from log_generico_ifp lgi
    where lgi.obj_referencia   = 'CONT_FOLHA_PGTO'
      and trunc(lgi.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgi.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lgi.resumo;
   --
   cursor c_item_folha_pgto is
   select lgi.resumo
        , lgi.mensagem
     from log_generico_ifp lgi
    where lgi.obj_referencia   = 'ITEM_FOLHA_PGTO'
      and trunc(lgi.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgi.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lgi.resumo;
   --
   cursor c_mestre_folha_pgto is
   select lgi.resumo
        , lgi.mensagem
        , lgi.referencia_id
     from log_generico_ifp lgi
    where lgi.obj_referencia   = 'MESTRE_FOLHA_PGTO'
      and trunc(lgi.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgi.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lgi.resumo;
   --
   cursor c_inf_folha_pgto is
   select lgi.resumo
        , lgi.mensagem
        , lgi.referencia_id
     from log_generico_ifp lgi
    where lgi.obj_referencia   = 'INF_FOLHA_PGTO'
      and trunc(lgi.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgi.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lgi.resumo;
   --
   cursor c_geral is -- Este cursor ira buscar quando a referencia_id não existir na tabela final.
   select 'VW_CSF_TRABALHADOR' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ifp lg
     where lg.obj_referencia = 'TRABALHADOR'
       and lg.referencia_id is not null
       and not exists (select *
                         from trabalhador tr
                        where tr.id = lg.referencia_id)
    union
    select 'VW_CSF_LOTACAO_FOLHA' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ifp lg
     where lg.obj_referencia = 'LOTACAO_FOLHA'
       and lg.referencia_id is not null
       and not exists (select *
                         from lotacao_folha lf
                        where lf.id = lg.referencia_id)
    union
    select 'VW_CSF_RUBRICA_FOLHA' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ifp lg
     where lg.obj_referencia = 'RUBRICA_FOLHA'
       and lg.referencia_id is not null
       and not exists (select *
                         from rubrica_folha rf
                        where rf.id = lg.referencia_id)
    union
    select 'VW_CSF_CONT_FOLHA_PGTO' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ifp lg
     where lg.obj_referencia = 'CONT_FOLHA_PGTO'
       and lg.referencia_id is not null
       and not exists (select *
                         from cont_folha_pgto cf
                        where cf.id = lg.referencia_id)
    union
    select 'VW_CSF_ITEM_FOLHA_PGTO' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ifp lg
     where lg.obj_referencia = 'ITEM_FOLHA_PGTO'
       and lg.referencia_id is not null
       and not exists (select *
                         from item_folha_pgto it
                        where it.id = lg.referencia_id)
    union
    select 'VW_CSF_MESTRE_FOLHA_PGTO' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ifp lg
     where lg.obj_referencia = 'MESTRE_FOLHA_PGTO'
       and lg.referencia_id is not null
       and not exists (select *
                         from mestre_folha_pgto mf
                        where mf.id = lg.referencia_id)
    union
    select 'VW_CSF_INF_FOLHA_PGTO' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ifp lg
     where lg.obj_referencia = 'INF_FOLHA_PGTO'
       and lg.referencia_id is not null
       and not exists (select *
                         from inf_folha_pgto inf
                        where inf.id = lg.referencia_id);
   --
   -- Log fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_ifp lg
           , csf_tipo_log     tl
       where lg.referencia_id    is null
         and lg.empresa_id       = en_empresa_id
         and lg.obj_referencia   = 'TRABALHADOR'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   --vn_first_reg := 1;
   --
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'Relatório de Agendamento de Integração referente ao Objeto MANAD'
                                 );
   --
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'TIPO;RESUMO;MENSAGEM;'
                                 );
   --
   vn_fase := 2;
   -- monta o relatório dos erros do trabalhador
   for rec in c_trabalhador loop
      exit when c_trabalhador%notfound or (c_trabalhador%notfound) is null;
      --
      vn_fase := 2.1;
      --
      vv_dados_empresa := null;
      vv_cod_reg_trab  := null;
      --
      vn_fase := 2.2;
      --
      begin
         --
         select pk_csf.fkg_cnpj_ou_cpf_empresa ( tr.empresa_id )
              , tr.cod_reg_trab
           into vv_dados_empresa
              , vv_cod_reg_trab
           from trabalhador tr
          where tr.id = rec.referencia_id;
         --
      exception
         when others then
           vv_dados_empresa := null;
           vv_cod_reg_trab  := null;
      end;
      --
      vn_fase := 2.3;
      --
      if vv_dados_empresa is not null and
         vv_cod_reg_trab is not null then
         --
         /*
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'Informações dos logs de Integração de trabalhadores'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;RESUMO;MENSAGEM;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         */
         --
         vl_texto := 'VW_CSF_TRABALHADOR'              ||';'||
                     pk_csf.fkg_converte(rec.resumo)   ||';'||
                     pk_csf.fkg_converte(rec.mensagem) ||';';

         --
         vn_fase := 2.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 3;
   --vn_first_title := 1;
   -- monta o relatório dos erros da lotação da folha
   for rec in c_lotacao_folha loop
      exit when c_lotacao_folha%notfound or ( c_lotacao_folha%notfound) is null;
      --
      vn_fase := 3.1;
      --
      vv_dados_empresa := null;
      vv_cod_ltc       := null;
      --
      vn_fase := 3.2;
      --
      begin
         --
         select pk_csf.fkg_cnpj_ou_cpf_empresa ( lf.empresa_id )
              , lf.cod_ltc
           into vv_dados_empresa
              , vv_cod_ltc
           from lotacao_folha lf
          where lf.id    = rec.referencia_id;
         --
      exception
         when others then
            vv_dados_empresa := null;
            vv_cod_ltc       := null;
      end;
      --
      vn_fase := 3.3;
      --
      if vv_dados_empresa is not null and
         vv_cod_ltc is not null then
         --
         /*
         if nvl(vn_first_title,0) = 1 then
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'Informações dos logs de Integração de Lotação da Folha'
                                          );
            --
            vn_first_title := 0;
            --
         end if;

         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;RESUMO;MENSAGEM;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         */
         --
         vl_texto := 'VW_CSF_LOTACAO_FOLHA'            ||';'||
                     pk_csf.fkg_converte(rec.resumo)   ||';'||
                     pk_csf.fkg_converte(rec.mensagem) ||';';
         --
         vn_fase := 3.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 4;
   --vn_first_title := 1;
   --
   -- monta o relatório dos erros de rubricas da folha
   for rec in c_rubrica_folha loop
      exit when c_rubrica_folha%notfound or (c_rubrica_folha%notfound) is null;
      --
      vn_fase := 4.1;
      --
      vv_dados_empresa  := null;
      vv_cod_rubrica    := null;
      --
      vn_fase := 4.2;
      --
      begin
         --
         select pk_csf.fkg_cnpj_ou_cpf_empresa ( rf.empresa_id )
              , rf.cod_rubrica
           into vv_dados_empresa
              , vv_cod_rubrica
           from rubrica_folha rf
          where rf.id     = rec.referencia_id;
         --
      exception
         when others then
            vv_dados_empresa  := null;
            vv_cod_rubrica    := null;
      end;
      --
      vn_fase := 4.3;
      --
      if vv_dados_empresa is not null and
         vv_cod_rubrica   is not null then
         --
         /*
         if nvl(vn_first_title,0) = 1 then
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'Informações dos logs de Integração de Rubricas da Folha'
                                          );
            --
            vn_first_title := 0;
            --
         end if;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;RESUMO;MENSAGEM;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         */
         --
         vl_texto := 'VW_CSF_RUBRICA_FOLHA'            ||';'||
                     pk_csf.fkg_converte(rec.resumo)   ||';'||
                     pk_csf.fkg_converte(rec.mensagem) ||';';
         --
         vn_fase := 4.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 5;
   --vn_first_title := 1;
   -- monta o relatório dos erros da contabilização das rubricas da folha de pagamento
   for rec in c_cont_folha_pgto loop
      exit when c_cont_folha_pgto%notfound or (c_cont_folha_pgto%notfound) is null;
      --
      vn_fase := 5.1;
      --
      vv_dados_empresa := null;
      vv_cod_rubrica   := null;
      vd_dt_cont       := null;
      vv_cod_ltc       := null;
      vv_cod_cta       := null;
      vv_cod_ccus      := null;
      --
      vn_fase := 5.2;
      --
      begin
         --
         select pk_csf.fkg_cnpj_ou_cpf_empresa ( rf.empresa_id )
              , rf.cod_rubrica
              , cf.dt_cont
              , lf.cod_ltc
              , pc.cod_cta
              , cc.cod_ccus
           into vv_dados_empresa
              , vv_cod_rubrica
              , vd_dt_cont
              , vv_cod_ltc
              , vv_cod_cta
              , vv_cod_ccus
           from cont_folha_pgto cf
              , rubrica_folha   rf
              , lotacao_folha   lf
              , plano_conta     pc
              , centro_custo    cc
          where cf.id                    = rec.referencia_id
            and cf.rubricafolha_id       = rf.id
            and lf.id    (+)             = cf.lotacaofolha_id
            and cf.planoconta_id         = pc.id
            and cc.id    (+)             = cf.centrocusto_id;
         --
      exception
         when others then
            vv_dados_empresa := null;
            vv_cod_rubrica   := null;
            vd_dt_cont       := null;
            vv_cod_ltc       := null;
            vv_cod_cta       := null;
            vv_cod_ccus      := null;
      end;
      --
      vn_fase := 5.3;
      --
      if vv_dados_empresa is not null and
         vv_cod_rubrica   is not null and
         vd_dt_cont is not null and
         vv_cod_ltc is not null and
         vv_cod_cta is not null and
         vv_cod_ccus is not null then
         --
         /*
         if nvl(vn_first_title,0) = 1 then
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'Informações dos logs de Integração de erros da contabilização das rubricas da folha de pagamento.'
                                          );
            --
            vn_first_title := 0;
            --
         end if;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;RESUMO;MENSAGEM;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         */
         --
         vl_texto := 'VW_CSF_CONT_FOLHA_PGTO'          ||';'||
                     pk_csf.fkg_converte(rec.resumo)   ||';'||
                     pk_csf.fkg_converte(rec.mensagem) ||';';
         --
         vn_fase := 5.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 6;
   --vn_first_title := 1;
   --
   -- monta o relatório dos erros dos itens da folha de pagamento
   for rec in c_item_folha_pgto loop
      exit when c_item_folha_pgto%notfound or (c_item_folha_pgto%notfound) is null;
      --
      vn_fase := 6.1;
      --
      /*
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;RESUMO;MENSAGEM;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'VW_CSF_ITEM_FOLHA_PGTO'          ||';'||
                  pk_csf.fkg_converte(rec.resumo)   ||';'||
                  pk_csf.fkg_converte(rec.mensagem) ||';';
      --
      vn_fase := 6.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 7;
   -- monta o relatório dos erros do mestre da folha de pagamento
   for rec in c_mestre_folha_pgto loop
      exit when c_mestre_folha_pgto%notfound or (c_mestre_folha_pgto%notfound) is null;
      --
      vn_fase := 7.1;
      --
      vv_dados_empresa := null;
      vn_dm_ind_fl     := null;
      vv_cod_ltc       := null;
      vv_cod_reg_trab  := null;
      vd_dt_comp       := null;
      --
      vn_fase := 7.2;
      --
      begin
         --
         select pk_csf.fkg_cnpj_ou_cpf_empresa ( mf.empresa_id )
              , mf.dm_ind_fl
              , lf.cod_ltc
              , tr.cod_reg_trab
              , mf.dt_comp
           into vv_dados_empresa
              , vn_dm_ind_fl
              , vv_cod_ltc
              , vv_cod_reg_trab
              , vd_dt_comp
           from mestre_folha_pgto mf
              , lotacao_folha     lf
              , trabalhador       tr
          where mf.id              = rec.referencia_id
            and lf.id   (+)        = mf.lotacaofolha_id
            and mf.trabalhador_id  = tr.id;
         --
      exception
         when others then
            vv_dados_empresa := null;
            vn_dm_ind_fl     := null;
            vv_cod_ltc       := null;
            vv_cod_reg_trab  := null;
            vd_dt_comp       := null;
      end;
      --
      if vv_dados_empresa is not null and
         nvl(vn_dm_ind_fl,0) = 0 and
         vv_cod_ltc is not null and
         vd_dt_comp is not null then
         --
         /*
         if nvl(vn_first_title,0) = 1 then
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'Informações dos logs de Integração de mestre da folha de pagamento'
                                          );
            --
            vn_first_title := 0;
            --
         end if;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;RESUMO;MENSAGEM;'
                                          );
            --
            vn_first_reg := 0;
         end if;
         */
         --
         vl_texto := 'VW_CSF_MESTRE_FOLHA_PGTO'        ||';'||
                     pk_csf.fkg_converte(rec.resumo)   ||';'||
                     pk_csf.fkg_converte(rec.mensagem) ||';';
         --
         vn_fase := 7.3;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 8;
   --vn_first_title := 1;
   --
   -- monta o relatório dos erros das informações da folha de pagamento
   for rec in c_inf_folha_pgto loop
      exit when c_inf_folha_pgto%notfound or (c_inf_folha_pgto%notfound) is null;
      --
      vn_fase := 8.1;
      --
      vv_dados_empresa := null;
      vn_ano           := null;
      vn_mes           := null;
      --
      vn_fase := 8.2;
      --
      begin
         --
         select pk_csf.fkg_cnpj_ou_cpf_empresa ( ifp.empresa_id )
              , ifp.ano
              , ifp.mes
           into vv_dados_empresa
              , vn_ano
              , vn_mes
           from inf_folha_pgto ifp
          where ifp.id     = rec.referencia_id;
         --
      exception
         when others then
            vv_dados_empresa := null;
            vn_ano           := null;
            vn_mes           := null;
      end;
      --
      vn_fase := 8.3;
      --
      if vv_dados_empresa is not null and
         nvl(vn_ano,0) = 0 and
         nvl(vn_mes,0) = 0 then
         --
         /*
         if nvl(vn_first_title,0) = 1 then
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'Informações dos logs de Integração de informações da folha de pagamento'
                                          );
            --
            vn_first_title := 0;
            --
         end if;
         */
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;RESUMO;MENSAGEM;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := 'VW_CSF_INF_FOLHA_PGTO'           ||';'||
                     pk_csf.fkg_converte(rec.resumo)   ||';'||
                     pk_csf.fkg_converte(rec.mensagem) ||';';
         --
         vn_fase := 8.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 9;
   vn_first_title := 1;
   --
   -- monta o relatório dos erros dos itens da folha de pagamento
   for rec in c_geral loop
      exit when c_geral%notfound or (c_geral%notfound) is null;
      --
      vn_fase := 9.1;
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'Informações dos logs de Integração de itens da folha de pagamento'
                                       );
         --
         vn_first_title := 0;
         --
      end if;
      */
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;RESUMO;MENSAGEM;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vl_texto := pk_csf.fkg_converte(rec.tipo) || ';' || pk_csf.fkg_converte(rec.resumo) || ';' || pk_csf.fkg_converte(rec.mensagem)||';';
      --
      vn_fase := 9.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 10;
   --Recuperando o identificador da empresa integrante
   begin
      --
      select ai.empresa_id
        into vn_empresa_id
        from agend_integr ai
       where ai.id = en_agendintegr_id;
      --
   exception
      when others then
         --
         vn_empresa_id := null;
         --
   end;
   --
   if nvl(vn_empresa_id, 0) > 0 then
      --
      --Logs do fechamento fiscal
      for rec in c_fecha_fiscal(en_empresa_id => vn_empresa_id, ev_info_fechamento => info_fechamento) loop
         exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
         --
         vv_dados_empresa := pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => rec.empresa_id);
         --
         vl_texto := null;
         vl_texto := 'Informação sobre fechamento Fiscal'
                  || ' - '
                  || vv_dados_empresa
                  || ';'
                  || pk_csf.fkg_converte(rec.resumo)
                  ||';'
                  || pk_csf.fkg_converte(rec.mensagem)
                  ||';';
         --
         vn_fase := 10.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_manad ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_manad;
------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Total de operações com cartão
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_tot_op_cart ( en_agendintegr_id  in agend_integr.id%type
                                    , en_objintegr_id    in obj_integr.id%type
                                    , en_usuario_id      in neo_usuario.id%type
                                    , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                                    , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                                    , en_empresa_id      in empresa.id%type
                                    , en_dm_tipo         in agend_integr.dm_tipo%type
                                    , en_multorg_id      in mult_org.id%type
                                    , ed_dt_agend        in agend_integr.dt_agend%type
                                    , ed_dt_termino      in item_agend_integr.dt_termino%type
                                    )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vv_cod_part      pessoa.cod_part%type := null;
   vn_first_reg     number               := 0;
   --
   cursor c_tot_op_cart is
   select toc.id
        , toc.empresa_id
        , toc.pessoa_id
        , toc.mes
        , toc.ano
     from empresa e
        , total_oper_cartao toc
    where e.multorg_id = en_multorg_id
      and toc.empresa_id = e.id
      and toc.dm_st_proc = 2
      and ( en_dm_tipo not in (1) or (toc.empresa_id = en_empresa_id) )
      and trunc(to_date( toc.mes || '/' || toc.ano ,'MM/YYYY')) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by toc.id;
   --
   cursor c_log ( en_referencia_id in log_generico_toc.id%type ) is
   select lgt.*
     from log_generico_toc  lgt
        , csf_tipo_log  tl
    where lgt.referencia_id     = en_referencia_id
      and lgt.obj_referencia    = 'TOTAL_OPER_CARTAO'
      and tl.id                 = lgt.csftipolog_id
      and tl.cd_compat          in ('1','2')
    order by lgt.id;
   --
   --Log de fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_toc lg
           , csf_tipo_log     tl
       where lg.referencia_id    is null
         and lg.empresa_id       = en_empresa_id
         and lg.obj_referencia   = 'TOTAL_OPER_CARTAO'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_tot_op_cart loop
      exit when c_tot_op_cart%notfound or (c_tot_op_cart%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      -- recupera o código do participante
      vv_cod_part := pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => rec.pessoa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'Informações dos logs de Integração de dos totais das Operações com cartão de Credito e/ou Debito - 1600'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'EMPRESA;COD_PART;MES;ANO;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || vv_cod_part || ';'
                     || rec.mes || ';'
                     || rec.ano || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';'
                     || pk_csf.fkg_converte(rec2.mensagem) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   --log fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id (en_empresa_id => rec.empresa_id);
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'Informações dos logs de Integração de dos totais das Operações com cartão de Credito e/ou Debito - 1600'
                                       );
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'EMPRESA;COD_PART;MES;ANO;RESUMO;MENSAGEM'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 5.1;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)   || ';'
               || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 5.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_tot_op_cart ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_tot_op_cart;
------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Controle de Creditos Fiscais de ICMS
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_cf_icms ( en_agendintegr_id  in agend_integr.id%type
                                , en_objintegr_id    in obj_integr.id%type
                                , en_usuario_id      in neo_usuario.id%type
                                , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                                , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                                , en_empresa_id      in empresa.id%type
                                , en_dm_tipo         in agend_integr.dm_tipo%type
                                , en_multorg_id      in mult_org.id%type
                                , ed_dt_agend        in agend_integr.dt_agend%type
                                , ed_dt_termino      in item_agend_integr.dt_termino%type
                                )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vv_cod_aj_apur   cod_aj_saldo_apur_icms.cod_aj_apur%type := null;
   vn_first_reg     number := 1;
   --
   cursor c_cf_icms is
   select cfi.id
        , cfi.empresa_id
        , cfi.codajsaldoapuricms_id
        , cfi.mes
        , cfi.ano
     from empresa e
        , contr_cred_fiscal_icms cfi
    where e.multorg_id = en_multorg_id
      and cfi.empresa_id = e.id
      and cfi.dm_st_proc = 2
      and ( en_dm_tipo not in (1) or (cfi.empresa_id = en_empresa_id) )
      and trunc(to_date( cfi.mes || '/' || cfi.ano ,'MM/YYYY')) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by cfi.id;
   --
   cursor c_log ( en_referencia_id in log_generico_ccf.id%type ) is
   select lgc.*
     from log_generico_ccf  lgc
        , csf_tipo_log  tl
    where lgc.referencia_id     = en_referencia_id
      and lgc.obj_referencia    = 'CONTR_CRED_FISCAL_ICMS'
      and tl.id                 = lgc.csftipolog_id
      and tl.cd_compat          in ('1','2')
    order by lgc.id;
   --
   --Log fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_ccf lg
           , csf_tipo_log     tl
       where lg.referencia_id    is null
         and lg.empresa_id       = en_empresa_id
         and lg.obj_referencia   = 'CONTR_CRED_FISCAL_ICMS'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_cf_icms loop
      exit when c_cf_icms%notfound or (c_cf_icms%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      -- recupera o código do ajuste de apuração do ICMS
      vv_cod_aj_apur := pk_csf_cf_icms.fkg_cod_aj_apur ( en_codajsaldoapuricms_id => rec.codajsaldoapuricms_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            vn_fase := 4.1;
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Tabela de Controle de Creditos Fiscais ICMS - registro 1200'
                                          );
            --
            vn_fase := 4.2;
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;COD_AJ_APUR;MES;ANO;RESUMO;MENSAGEM'
                                          );
            --
            vn_fase := 4.3;
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || vv_cod_aj_apur || ';'
                     || rec.mes || ';'
                     || rec.ano || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';'
                     || pk_csf.fkg_converte(rec2.mensagem) || ';';
         --
         vn_fase := 4.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   --log fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id (en_empresa_id => rec.empresa_id);
      --
      if nvl(vn_first_reg,0) = 1 then
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'Tabela de Controle de Creditos Fiscais ICMS - registro 1200'
                                       );
         --
         vn_fase := 4.2;
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'EMPRESA;COD_AJ_APUR;MES;ANO;RESUMO;MENSAGEM'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 5.1;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)   || ';'
               || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 5.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_cf_icms ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_cf_icms;
------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Informações de Valores Agregados
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_iva ( en_agendintegr_id  in agend_integr.id%type
                            , en_objintegr_id    in obj_integr.id%type
                            , en_usuario_id      in neo_usuario.id%type
                            , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                            , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                            , en_empresa_id      in empresa.id%type
                            , en_dm_tipo         in agend_integr.dm_tipo%type
                            , en_multorg_id      in mult_org.id%type
                            , ed_dt_agend        in agend_integr.dt_agend%type
                            , ed_dt_termino      in item_agend_integr.dt_termino%type
                            )
is
   --
   vn_fase        number := 0;
   vl_texto       impr_erro_agend_integr.texto%type;
   vn_first_reg   number := 0;
   --
   vv_dados_empresa varchar2(255)           := null;
   vv_cod_item      item.cod_item%type      := null;
   vv_ibge_cidade   cidade.ibge_cidade%type := null;
   --
   cursor c_iva is
   select iva.id
        , iva.empresa_id
        , iva.item_id
        , iva.cidade_id
        , iva.mes
        , iva.ano
     from empresa e
        , inf_valor_agreg iva
    where e.multorg_id = en_multorg_id
      and iva.empresa_id = e.id
      and iva.dm_st_proc = 2
      and ( en_dm_tipo not in (1) or (iva.empresa_id = en_empresa_id) )
      and trunc(to_date( iva.mes || '/' || iva.ano ,'MM/YYYY')) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by iva.id;
   --
   cursor c_log ( en_referencia_id in log_generico_iva.id%type ) is
   select lgi.*
     from log_generico_iva  lgi
        , csf_tipo_log  tl
    where lgi.referencia_id    = en_referencia_id
      and lgi.obj_referencia   = 'INF_VALOR_AGREG'
      and tl.id                = lgi.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by lgi.id;
   --
   --Log de fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_iva lg
           , csf_tipo_log     tl
       where lg.referencia_id    is null
         and lg.empresa_id       = en_empresa_id
         and lg.obj_referencia   = 'INF_VALOR_AGREG'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_iva loop
      exit when c_iva%notfound or (c_iva%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      -- recupera o código do item
      vv_cod_item := pk_csf.fkg_Item_cod ( en_item_id => rec.item_id );
      --
      -- recupera o ibge da cidade
      vv_ibge_cidade := pk_csf.fkg_ibge_cidade_id ( en_cidade_id => rec.cidade_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            -- Identificação da tabela
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Tabela de Informação sobre valores agregados - Registro : 1400'
                                          );
            --
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;COD_ITEM;IBGE_CIDADE;MES;ANO;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || vv_cod_item || ';'
                     || vv_ibge_cidade || ';'
                     || rec.mes || ';'
                     || rec.ano || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';'
                     || pk_csf.fkg_converte(rec2.mensagem) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   --Log fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      if nvl(vn_first_reg,0) = 1 then
         --
         -- Identificação da tabela
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'Tabela de Informação sobre valores agregados - Registro : 1400'
                                       );
         --
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'EMPRESA;COD_ITEM;IBGE_CIDADE;MES;ANO;RESUMO;MENSAGEM'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 5.1;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)  || ';'
               || pk_csf.fkg_converte(rec.mensagem)|| ';';
      --
      vn_fase := 5.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_iva ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_iva;
------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Produção Diaria de Usina
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_pdu ( en_agendintegr_id  in agend_integr.id%type
                            , en_objintegr_id    in obj_integr.id%type
                            , en_usuario_id      in neo_usuario.id%type
                            , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                            , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                            , en_empresa_id      in empresa.id%type
                            , en_dm_tipo         in agend_integr.dm_tipo%type
                            , en_multorg_id      in mult_org.id%type
                            , ed_dt_agend        in agend_integr.dt_agend%type
                            , ed_dt_termino      in item_agend_integr.dt_termino%type
                            )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number := null;
   --
   cursor c_pdu is
   select pdu.id
        , pdu.empresa_id
        , pdu.dm_cod_prod
        , pdu.dt_prod
     from empresa e
        , prod_dia_usina pdu
    where e.multorg_id = en_multorg_id
      and pdu.empresa_id = e.id
      and pdu.dm_st_proc = 2
      and ( en_dm_tipo not in (1) or (pdu.empresa_id = en_empresa_id) )
      and trunc(pdu.dt_prod) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by pdu.id;
   --
   cursor c_log ( en_referencia_id in log_generico_pdu.id%type ) is
   select lgp.*
     from log_generico_pdu  lgp
        , csf_tipo_log  tl
    where lgp.referencia_id    = en_referencia_id
      and lgp.obj_referencia   = 'PROD_DIA_USINA'
      and tl.id                = lgp.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by lgp.id;
   --
   -- Log de fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_pdu lg
           , csf_tipo_log     tl
       where lg.referencia_id    is null
         and lg.empresa_id       = en_empresa_id
         and lg.obj_referencia   = 'PROD_DIA_USINA'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_pdu loop
      exit when c_pdu%notfound or (c_pdu%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- Identificação da tabela
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Produção diaria da Usina Regitro 1390 e 1391 do Sped Fiscal'
                                          );
            --
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;DM_COD_PROD;DT_PROD;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || rec.dm_cod_prod || ';'
                     || to_char(rec.dt_prod, 'dd/mm/rrrr') || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';'
                     || pk_csf.fkg_converte(rec2.mensagem) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   -- Log de fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      if nvl(vn_first_reg,0) = 1 then
         -- Identificação da tabela
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'Produção diaria da Usina Regitro 1390 e 1391 do Sped Fiscal'
                                       );
         --
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'EMPRESA;DM_COD_PROD;DT_PROD;RESUMO;MENSAGEM'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)
               || ';'
               || pk_csf.fkg_converte(rec.mensagem)
               || ';';
      --
      vn_fase := 5.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_pdu ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_pdu;
------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro dos dados contábeis
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_dados_contab ( en_agendintegr_id  in agend_integr.id%type
                                     , en_objintegr_id    in obj_integr.id%type
                                     , en_usuario_id      in neo_usuario.id%type
                                     , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                                     , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                                     , en_empresa_id      in empresa.id%type
                                     , en_dm_tipo         in agend_integr.dm_tipo%type
                                     , en_multorg_id      in mult_org.id%type
                                     , ed_dt_agend        in agend_integr.dt_agend%type
                                     , ed_dt_termino      in item_agend_integr.dt_termino%type
                                     )
is
   --
   vn_fase          number := 0;
   vl_texto         impr_erro_agend_integr.texto%type;
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number        := null;
   --
   -- INT_DET_SALDO_PERIODO
   cursor c_det is
   select id.id
        , id.empresa_id
        , id.dt_ini
        , id.dt_fim
        , pc.cod_cta
        , cc.cod_ccus
        , id.vl_sld_ini
        , id.vl_sld_fin
        , id.vl_deb
        , id.vl_cred
     from empresa               em
        , int_det_saldo_periodo id
        , plano_conta           pc
        , centro_custo          cc
    where ((en_dm_tipo not in (1)) -- 1-Empresa Logada, 2-Bloco, 3-Todas as empresas, 4-Oracle EBS R12, 5-Oracle EBS R12 - ODI
            or
           (em.id = en_empresa_id))
      and em.multorg_id    = en_multorg_id
      and id.empresa_id    = em.id
      and id.dm_st_proc    = 2 -- 0-Não Validado, 1-Validado, 2-Erro de Validação
      and trunc(id.dt_ini) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
      and pc.id(+)         = id.planoconta_id
      and cc.id(+)         = id.centrocusto_id
    order by id.id;
   --
   -- LOG: INT_DET_SALDO_PERIODO(com referecia_id)
   cursor c_log_det ( en_referencia_id in log_generico_dc.referencia_id%type ) is
   select lg.*
     from log_generico_dc lg
        , csf_tipo_log    ct
    where lg.referencia_id  = en_referencia_id
      and lg.obj_referencia = 'INT_DET_SALDO_PERIODO'
      and ct.id             = lg.csftipolog_id
      and ct.cd_compat      in ('1','2')
    order by lg.id;
   --
   -- Log: int_det_saldo_periodo (sem referencia_id)/fechamento fiscal
      cursor c_log_det_null(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select *
        from ( select lg.*
                 from log_generico_dc lg
                    , csf_tipo_log ct
                where lg.empresa_id       = en_empresa_id
                  and lg.referencia_id    is null
                  and lg.obj_referencia   = 'INT_DET_SALDO_PERIODO'
                  and ct.id               = lg.csftipolog_id
                  and ct.cd_compat        in('1', '2')
                  and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
                  and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
               union
               select lg.*
                 from log_generico_dc lg
                    , csf_tipo_log ct
                where lg.empresa_id       = en_empresa_id
                  and lg.referencia_id    is null
                  and lg.obj_referencia   = 'INT_DET_SALDO_PERIODO'
                  and ct.id               = lg.csftipolog_id
                  and ct.id               in(ev_info_fechamento)
                  and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
                  and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
                  )
      order by id;
   --
   -- INT_LCTO_CONTABIL
   cursor c_lcto is
   select il.id
        , il.empresa_id
        , il.num_lcto
        , il.dt_lcto
        , il.vl_lcto
        , il.dt_lcto_ext
     from empresa           em
        , int_lcto_contabil il
    where ((en_dm_tipo not in (1)) -- 1-Empresa Logada, 2-Bloco, 3-Todas as empresas, 4-Oracle EBS R12, 5-Oracle EBS R12 - ODI
            or
           (em.id = en_empresa_id))
      and em.multorg_id    = en_multorg_id
      and il.empresa_id    = em.id
      and il.dm_st_proc    = 2 -- 0-Não Validado, 1-Validado, 2-Erro de Validação
      and trunc(il.dt_lcto) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by il.id;
   --
   -- LOG: INT_LCTO_CONTABIL(com referencia_id)
   cursor c_log_lcto ( en_referencia_id in log_generico_dc.referencia_id%type ) is
   select lg.*
     from log_generico_dc lg
        , csf_tipo_log    ct
    where lg.referencia_id  = en_referencia_id
      and lg.obj_referencia = 'INT_LCTO_CONTABIL'
      and ct.id             = lg.csftipolog_id
      and ct.cd_compat      in ('1','2')
    order by lg.id;
   --
   -- Log INT_LCTO_CONTABIL(sem referencia_id)
   cursor c_log_lcto_null(en_empresa_id in number, ev_info_fechamento in varchar2) is
    select *
      from ( select lg.*
               from log_generico_dc lg
                  , csf_tipo_log ct
              where lg.empresa_id       = en_empresa_id
                and lg.referencia_id    is null
                and lg.obj_referencia   = 'INT_LCTO_CONTABIL'
                and ct.id               = lg.csftipolog_id
                and ct.cd_compat        in('1', '2')
                and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
                and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
             union
             select lg.*
               from log_generico_dc lg
                  , csf_tipo_log ct
              where lg.empresa_id       = en_empresa_id
                and lg.referencia_id    is null
                and lg.obj_referencia   = 'INT_LCTO_CONTABIL'
                and ct.id               = lg.csftipolog_id
                and ct.id               in(ev_info_fechamento)
                and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
                and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
                 )
    order by id;
   --
   procedure pkb_identificacao_reg ( el_texto in impr_erro_agend_integr.texto%type ) is
   begin
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => el_texto
                                    );
      --
   exception
     when others then
        null;
   end pkb_identificacao_reg;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   pkb_identificacao_reg ( el_texto => 'Relatório de Erro do objeto de Integração Dados Contábeis.');
   --
   for rec in c_det
   loop
      --
      exit when c_det%notfound or (c_det%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 4;
      --
      for rec2 in c_log_det(en_referencia_id => rec.id)
      loop
         --
         exit when c_log_det%notfound or (c_log_det%notfound) is null;
         --
         vn_fase := 5;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            --pkb_identificacao_reg ( el_texto => 'Tabela de Integração do Detalhe dos Saldos Periodicos');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'TIPO;EMPRESA;DT_INI;DT_FIM;COD_CTA;COD_CCUS;VL_SLD_INI;VL_SLD_FIN;VL_DEB;VL_CRED;RESUMO;MENSAGEM'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := 'INT_DET_SALDO_PERIODO;'||
                     vv_dados_empresa||';'||
                     to_char(rec.dt_ini,'dd/mm/rrrr')||';'||
                     to_char(rec.dt_fim,'dd/mm/rrrr')||';'||
                     rec.cod_cta||';'||
                     rec.cod_ccus||';'||
                     trim(to_char(rec.vl_sld_ini,'999G999G999G999G990D00'))||';'||
                     trim(to_char(rec.vl_sld_fin,'999G999G999G999G990D00'))||';'||
                     trim(to_char(rec.vl_deb,'999G999G999G999G990D00'))||';'||
                     trim(to_char(rec.vl_cred,'999G999G999G999G990D00'))||';'||
                     pk_csf.fkg_converte(rec2.resumo)||';'||
                     pk_csf.fkg_converte(rec2.mensagem)||';';
         --
         vn_fase := 6;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 6.1;
   --
   --| Gerando logs que não possuem referencia_id (INT_DET_SALDO_PERIODO).
   for rec in c_log_det_null(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_log_det_null%notfound or (c_log_det_null%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      if nvl(vn_first_reg,0) = 1 then
         --
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;EMPRESA;DT_INI;DT_FIM;COD_CTA;COD_CCUS;VL_SLD_INI;VL_SLD_FIN;VL_DEB;VL_CRED;RESUMO;MENSAGEM'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 6.2;
      --
      vl_texto := 'INT_DET_SALDO_PERIODO;'
               || vv_dados_empresa || ';'
               || ed_dt_ini_integr || ';'
               || ed_dt_fin_integr || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo) || ';'
               || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 6.3;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 7;
   vn_first_reg := 1;
   -- monta os erros de lançamentos contábeis
   for rec in c_lcto loop
      exit when c_lcto%notfound or ( c_lcto%notfound) is null;
      --
      vn_fase := 9;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 10;
      --
      for rec2 in c_log_lcto(en_referencia_id => rec.id)
      loop
         --
         exit when c_log_lcto%notfound or (c_log_lcto%notfound) is null;
         --
         vn_fase := 11;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            --pkb_identificacao_reg ( el_texto => 'Tabela de Integração de Lancamento Contabil');
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'TIPO;EMPRESA;NUM_LCTO;DT_LCTO;DT_LCTO_EXT;VL_LCTO;RESUMO;MENSAGEM;;;;;;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := 'INT_LCTO_CONTABIL;'||
                     vv_dados_empresa||';'||
                     rec.num_lcto||';'||
                     to_char(rec.dt_lcto,'dd/mm/rrrr')||';'||
                     trim(to_char(rec.vl_lcto,'999G999G999G999G990D00'))||';'||
                     to_char(rec.dt_lcto_ext,'dd/mm/rrrr')||';'||
                     pk_csf.fkg_converte(rec2.resumo)||';'||
                     pk_csf.fkg_converte(rec2.mensagem)||';'
                     ||';'
                     ||';'
                     ||';'
                     ||';'
                     ||';';
         --
         vn_fase := 12;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 13;
   --
   --montando relatório com erros para registros sem referencia_id(INT_LCTO_CONTABIL)
   for rec in c_log_lcto_null(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_log_lcto_null%notfound or (c_log_lcto_null%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      if nvl(vn_first_reg,0) = 1 then
         --
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;EMPRESA;NUM_LCTO;DT_LCTO;VL_LCTO;RESUMO;MENSAGEM;;;;;;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 13.1;
      --
      vl_texto := 'INT_LCTO_CONTABIL;'
               || vv_dados_empresa || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo) || ';'
               || pk_csf.fkg_converte(rec.mensagem) || ';'
               ||';'
               ||';'
               ||';'
               ||';'
               ||';';
      --
      vn_fase := 13.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_dados_contab ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_dados_contab;
------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro do ecredac
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_ecredac ( en_agendintegr_id  in agend_integr.id%type
                                , en_objintegr_id    in obj_integr.id%type
                                , en_usuario_id      in neo_usuario.id%type
                                , ed_dt_agend        in agend_integr.dt_agend%type
                                , ed_dt_termino      in item_agend_integr.dt_termino%type
                                , en_multorg_id      in mult_org.id%type
                                )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   vv_dados_empresa        varchar2(255) := null;
   vn_first_reg            number := 0;
   vn_first_title          number := 0;
   --
   vn_nro_op               op_cab.nro_op%type := null;
   vn_seq                  mov_op.seq%type    := null;
   vd_dt                   date               := null;
   vv_cod_item             item.cod_item%type := null;
   --
   vn_empresa_id           empresa.id%type;
   --
   cursor c_op_cab is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'OP_CAB'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_mov_op is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'MOV_OP'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_movop_itemnf is
   select lge.resumo
        , lge.mensagem
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'MOVOP_ITEMNF'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_prod_op is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'PROD_OP'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_prod_op_detalhe is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'PROD_OP_DETALHE'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_prodop_movop is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'PRODOP_MOVOP'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_frete_itemnf is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'FRETE_ITEMNF'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_mov_transf is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'MOV_TRANSF'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_enq_leg_cred_acm_icms_sp is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'ENQ_LEG_CRED_ACM_ICMS_SP'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_itemnf_cod_legal is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'ITEMNF_COD_LEGAL'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_itemnf_nao_gera_est is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'ITEMNF_NAO_GERA_EST'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_movto_estq is
   select lge.resumo
        , lge.mensagem
        , lge.referencia_id
     from log_generico_ecredac lge
    where lge.obj_referencia   = 'MOVTO_ESTQ'
      and trunc(lge.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lge.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lge.resumo;
   --
   cursor c_geral is  -- Este cursor ira buscar quando a referencia_id não existir na tabela final.
   select 'OP_CAB' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'OP_CAB'
       and lg.referencia_id is not null
       and not exists (select *
                         from op_cab oc
                        where oc.id = lg.referencia_id)
    union
    select 'MOV_OP' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'MOV_OP'
       and lg.referencia_id is not null
       and not exists (select *
                         from mov_op mo
                        where mo.id = lg.referencia_id)
    union
    select 'MOVOP_ITEMNF' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'MOVOP_ITEMNF'
       and lg.referencia_id is not null
       and not exists (select *
                         from movop_itemnf mi
                        where mi.id = lg.referencia_id)
    union
    select 'PROD_OP' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'PROD_OP'
       and lg.referencia_id is not null
       and not exists (select *
                         from prod_op po
                        where po.id = lg.referencia_id)
    union
    select 'PROD_OP_DETALHE' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'PROD_OP_DETALHE'
       and lg.referencia_id is not null
       and not exists (select *
                         from prod_op_detalhe po
                        where po.id = lg.referencia_id)
    union
    select 'PRODOP_MOVOP' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'PRODOP_MOVOP'
       and lg.referencia_id is not null
       and not exists (select *
                         from prodop_movop pm
                        where pm.id = lg.referencia_id)
    union
    select 'FRETE_ITEMNF' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'FRETE_ITEMNF'
       and lg.referencia_id is not null
       and not exists (select *
                         from frete_itemnf fi
                        where fi.id = lg.referencia_id)
    union
    select 'MOV_TRANSF' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'MOV_TRANSF'
       and lg.referencia_id is not null
       and not exists (select *
                         from mov_transf mt
                        where mt.id = lg.referencia_id)
    union
    select 'ENQ_LEG_CRED_ACM_ICMS_SP' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'ENQ_LEG_CRED_ACM_ICMS_SP'
       and lg.referencia_id is not null
       and not exists (select *
                         from enq_leg_cred_acm_icms_sp el
                        where el.id = lg.referencia_id)
    union
    select 'ITEMNF_COD_LEGAL' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'ITEMNF_COD_LEGAL'
       and lg.referencia_id is not null
       and not exists (select *
                         from itemnf_cod_legal ic
                        where ic.id = lg.referencia_id)
    union
    select 'ITEMNF_NAO_GERA_EST' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'ITEMNF_NAO_GERA_EST'
       and lg.referencia_id is not null
       and not exists (select *
                         from itemnf_nao_gera_est ing
                        where ing.id = lg.referencia_id)
    union
    select 'MOVTO_ESTQ' tipo
         , lg.resumo
         , lg.mensagem
      from log_generico_ecredac lg
     where lg.obj_referencia = 'MOVTO_ESTQ'
       and lg.referencia_id is not null
       and not exists (select *
                         from movto_estq mo
                        where mo.id = lg.referencia_id);
   --
   --Log de fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_ecredac lg
           , csf_tipo_log         tl
       where lg.empresa_id = en_empresa_id
         and lg.referencia_id is null
         and lg.obj_referencia in('MOVTO_ESTQ', 'ITEMNF_NAO_GERA_EST', 'ITEMNF_COD_LEGAL',
                                  'ENQ_LEG_CRED_ACM_ICMS_SP', 'MOV_TRANSF', 'FRETE_ITEMNF', 'PRODOP_MOVOP',
                                  'PROD_OP_DETALHE', 'PROD_OP', 'MOVOP_ITEMNF', 'MOV_OP', 'OP_CAB'
                                 )
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
   procedure pkb_identificacao_reg ( el_texto in impr_erro_agend_integr.texto%type ) is
   begin
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => el_texto
                                    );
      --
   exception
     when others then
        null;
   end pkb_identificacao_reg;
   --
begin
   --
   vn_fase := 1;
   --
   pkb_identificacao_reg ( el_texto => 'Relatório de Erro de integração do Objeto ECREDAC' );
   --
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                 , en_objintegr_id    => en_objintegr_id
                                 , en_usuario_id      => en_usuario_id
                                 , el_texto           => 'TIPO;RESUMO;MENSAGEM;'
                                 );
   --
   -- monta os erros de ordens de produção
   for rec in c_op_cab loop
      exit when c_op_cab%notfound or (c_op_cab%notfound) is null;
      --
      vn_fase := 2.1;
      --
      vv_dados_empresa := null;
      vn_nro_op        := null;
      vd_dt            := null;
      --
      vn_fase := 2.2;
      --
      begin
         --
         select pk_csf.fkg_cod_nome_empresa_id ( oc.empresa_id )
              , oc.nro_op
              , oc.dt
           into vv_dados_empresa
              , vn_nro_op
              , vd_dt
           from op_cab oc
          where oc.id  = rec.referencia_id;
         --
      exception
         when others then
            vv_dados_empresa := null;
            vn_nro_op        := null;
            vd_dt            := null;
      end;
      --
      vn_fase := 2.3;
      --
      if vv_dados_empresa is not null and
         nvl(vn_nro_op,0) = 0 and
         vd_dt is not null then
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'TIPO;RESUMO;MENSAGEM;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := 'OP_CAB'                           || ';' ||
                     pk_csf.fkg_converte(rec.resumo)    || ';' ||
                     pk_csf.fkg_converte(rec.mensagem)  || ';';
         --
         vn_fase := 2.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 3;
   --vn_first_title := 1;
   -- montar os erros de movimentações das ordens de produção
   for rec in c_mov_op loop
      exit when c_mov_op%notfound or (c_mov_op%notfound) is null;
      --
      vn_fase := 3.1;
      --
      vv_dados_empresa := null;
      vn_nro_op        := null;
      vn_seq           := null;
      vd_dt            := null;
      --
      vn_fase := 3.2;
      --
      begin
         --
         select pk_csf.fkg_cod_nome_empresa_id ( oc.empresa_id )
              , oc.nro_op
              , mo.seq
              , mo.dt
           into vv_dados_empresa
              , vn_nro_op
              , vn_seq
              , vd_dt
           from mov_op mo
              , op_cab oc
          where mo.id       = rec.referencia_id
            and mo.opcab_id = oc.id;
          --
      exception
         when others then
            vv_dados_empresa := null;
            vn_nro_op        := null;
            vn_seq           := null;
            vd_dt            := null;
      end;
      --
      vn_fase := 3.3;
      --
      if vv_dados_empresa is not null and
         nvl(vn_nro_op,0) = 0 and
         nvl(vn_seq,0) = 0 and
         vd_dt is not null then
         --
         /*
         if nvl(vn_first_title,0) = 1 then
            -- monta a identificação dos títulos
            pkb_identificacao_reg ( el_texto => 'Tabela de movimentação de insumos da ordem de produção' );
            --
            vn_first_title := 0;
            --
         end if;
         */
         --
         vl_texto := 'MOV_OP'                           || ';' ||
                     pk_csf.fkg_converte(rec.resumo)    || ';' ||
                     pk_csf.fkg_converte(rec.mensagem)  || ';';
         --
         vn_fase := 3.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 4;
   --vn_first_title := 1;
   --
   -- monta os erros de produções das ordens de produção
   for rec in c_prod_op loop
      exit when c_prod_op%notfound or (c_prod_op%notfound) is null;
      --
      vn_fase := 4.1;
      --
      vv_dados_empresa    := null;
      vn_nro_op           := null;
      vn_seq              := null;
      vd_dt               := null;
      --
      vn_fase := 4.2;
      --
      begin
         --
         select pk_csf.fkg_cod_nome_empresa_id ( oc.empresa_id )
              , oc.nro_op
              , po.seq
              , po.dt
           into vv_dados_empresa
              , vn_nro_op
              , vn_seq
              , vd_dt
           from prod_op po
              , op_cab oc
          where po.id       = rec.referencia_id
            and po.opcab_id = oc.id;
         --
      exception
         when others then
            vv_dados_empresa   := null;
            vn_nro_op          := null;
            vn_seq             := null;
            vd_dt              := null;
      end;
      --
      vn_fase := 4.3;
      --
      if vv_dados_empresa is not null and
         nvl(vn_nro_op,0) = 0 and
         nvl(vn_seq,0) = 0 and
         vd_dt is not null then
         --
         /*
         if nvl(vn_first_title,0) = 1 then
            -- monta a identificação dos títulos
            pkb_identificacao_reg ( el_texto => 'Tabela de registro da produção da ordem' );
            --
            vn_first_title := 0;
            --
         end if;
         */
         --
         vl_texto := 'PROD_OP'                          || ';' ||
                     pk_csf.fkg_converte(rec.resumo)    || ';' ||
                     pk_csf.fkg_converte(rec.mensagem)  || ';';
         --
         vn_fase := 4.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 5;
   --vn_first_title := 1;
   --
   -- monta os erros de produções das ordens de produção e detalhes
   for rec in c_prod_op_detalhe loop
      exit when c_prod_op_detalhe%notfound or (c_prod_op_detalhe%notfound) is null;
      --
      vn_fase := 5.1;
      --
      vv_dados_empresa  := null;
      vn_nro_op         := null;
      vn_seq            := null;
      vd_dt             := null;
      vv_cod_item       := null;
      --
      vn_fase := 5.2;
      --
      begin
         --
         select pk_csf.fkg_cod_nome_empresa_id ( oc.empresa_id )
              , oc.nro_op
              , po.seq
              , po.dt
              , it.cod_item
           into vv_dados_empresa
              , vn_nro_op
              , vn_seq
              , vd_dt
              , vv_cod_item
           from prod_op_detalhe pod
              , item            it
              , prod_op         po
              , op_cab          oc
          where pod.id             = rec.referencia_id
            and pod.item_id_insumo = it.id
            and pod.prodop_id      = po.id
            and po.opcab_id        = oc.id;
         --
      exception
         when others then
            vv_dados_empresa  := null;
            vn_nro_op         := null;
            vn_seq            := null;
            vd_dt             := null;
            vv_cod_item       := null;
      end;
      --
      vn_fase := 5.3;
      --
      if vv_dados_empresa is not null and
         nvl(vn_nro_op,0) = 0 and
         nvl(vn_seq,0) = 0 and
         vd_dt is not null and
         vv_cod_item is not null then
         --
         /*
         if nvl(vn_first_title,0) = 1 then
            -- monta a identificação dos títulos
            pkb_identificacao_reg ( el_texto => 'Tabela de detalhamento da produção - insumos utilizados' );
            --
            vn_first_title := 0;
            --
         end if;
         */
         --
         vl_texto := 'PROD_OP_DETALHE'                  || ';' ||
                     pk_csf.fkg_converte(rec.resumo)    || ';' ||
                     pk_csf.fkg_converte(rec.mensagem)  || ';';
         --
         vn_fase := 5.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end if;
      --
   end loop;
   --
   vn_fase := 6;
   --vn_first_title := 1;
   --
   -- monta os erros de movimentações de estoque manuais
   for rec in c_movto_estq loop
      exit when c_movto_estq%notfound or (c_movto_estq%notfound) is null;
      --
      vn_fase := 6.1;
      --
      vv_dados_empresa := null;
      vv_cod_item      := null;
      vd_dt            := null;
      --
      vn_fase := 6.2;
      --
      begin
         --
         select pk_csf.fkg_cod_nome_empresa_id ( me.empresa_id )
              , it.cod_item
              , me.dt
           into vv_dados_empresa
              , vv_cod_item
              , vd_dt
           from movto_estq me
              , item  it
          where me.id             = rec.referencia_id
            and me.item_id_insumo = it.id;
         --
      exception
         when others then
            --
            vv_dados_empresa := null;
            vv_cod_item      := null;
            vd_dt            := null;
      end;
      --
      vn_fase := 6.3;
      --
      if vv_dados_empresa is not null and
         vv_cod_item is not null and
         vd_dt is not null then
         --
         /*
         if nvl(vn_first_title,0) = 1 then
            -- monta a identificação dos títulos
            pkb_identificacao_reg ( el_texto => 'Tabela de movimentação de produtos em estoque - lancamentos manuais' );
            --
            vn_first_title := 0;
            --
         end if;
         */
         --
         vl_texto := 'MOVTO_ESTQ'                       || ';' ||
                     pk_csf.fkg_converte(rec.resumo)    || ';' ||
                     pk_csf.fkg_converte(rec.mensagem)  || ';';
         --
         vn_fase := 6.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
      end if;
      --
   end loop;
   --
   vn_fase := 7;
   --
   -- monta os erros de movimentações de estoque manuais
   for rec in c_geral loop
      exit when c_geral%notfound or (c_geral%notfound) is null;
      --
      vn_fase := 7.1;
      --
      vl_texto := pk_csf.fkg_converte(rec.tipo) || ';' || pk_csf.fkg_converte(rec.resumo) || ';' || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 7.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 8;
   -- monta os erros de movimentações das ordens de produção com itens de notas fiscais
   for rec in c_movop_itemnf loop
      exit when c_movop_itemnf%notfound or (c_movop_itemnf%notfound) is null;
      --
      vn_fase := 8.1;
      --
      vl_texto := 'MOVOP_ITEMNF;' || pk_csf.fkg_converte(rec.resumo) || ';' || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 8.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 9;
   -- monta os erros de produções das ordens de produções e movimentações das ordens de produções
   for rec in c_prodop_movop loop
      exit when c_prodop_movop%notfound or (c_prodop_movop%notfound) is null;
      --
      vn_fase := 9.1;
      --
      vl_texto := 'PRODOP_MOVOP;' || pk_csf.fkg_converte(rec.resumo) || ';' || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 9.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 10;
   -- monta os erros de fretes e itens de notas fiscais
   for rec in c_frete_itemnf loop
      exit when c_frete_itemnf%notfound or (c_frete_itemnf%notfound) is null;
      --
      vn_fase := 10.1;
      --
      vl_texto := 'FRETE_ITEMNF;' || pk_csf.fkg_converte(rec.resumo) || ';' || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 10.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 11;
   -- monta os erros de movimentações das transferências
   for rec in c_mov_transf loop
      exit when c_mov_transf%notfound or (c_mov_transf%notfound) is null;
      --
      vn_fase := 11.1;
      --
      vl_texto := 'MOV_TRANSF;' || pk_csf.fkg_converte(rec.resumo) || ';' || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 11.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 12;
   -- monta os erros de códigos de enquadramentos legais
   for rec in c_enq_leg_cred_acm_icms_sp loop
      exit when c_enq_leg_cred_acm_icms_sp%notfound or (c_enq_leg_cred_acm_icms_sp%notfound) is null;
      --
      vn_fase := 12.1;
      --
      vl_texto := 'ENQ_LEG_CRED_ACM_ICMS_SP;' || pk_csf.fkg_converte(rec.resumo) || ';' || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 12.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 13;
   -- monta os erros de itens de notas fiscais de códigos legais de enquadramento
   for rec in c_itemnf_cod_legal loop
      exit when c_itemnf_cod_legal%notfound or (c_itemnf_cod_legal%notfound) is null;
      --
      vn_fase := 13.1;
      --
      vl_texto := 'ITEMNF_COD_LEGAL;' || pk_csf.fkg_converte(rec.resumo) || ';' || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 13.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 14;
   -- monta os erros de itens de notas fiscais que não geram estoque
   for rec in c_itemnf_nao_gera_est loop
      exit when c_itemnf_nao_gera_est%notfound or (c_itemnf_nao_gera_est%notfound) is null;
      --
      vn_fase := 14.1;
      --
      vl_texto := 'ITEMNF_NAO_GERA_EST;' || pk_csf.fkg_converte(rec.resumo) || ';' || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 14.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 15;
   --
   begin
      --
      select ai.empresa_id
        into vn_empresa_id
        from agend_integr ai
       where ai.id = en_agendintegr_id;
      --
   exception
      when others then
         --
         vn_empresa_id := null;
         --
   end;
   --
   vn_fase := 16;
   --
   --Logs de fechamento fiscal
   if nvl(vn_empresa_id, 0) > 0 then
      --
      for rec in c_fecha_fiscal(en_empresa_id => vn_empresa_id, ev_info_fechamento => info_fechamento) loop
         exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
         --
         vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => vn_empresa_id);
         --
         vl_texto := null;
         --
         vl_texto := vv_dados_empresa||' - '|| pk_csf.fkg_converte(rec.obj_referencia)
                  || ';'
                  || pk_csf.fkg_converte(rec.resumo)
                  || ';'
                  || pk_csf.fkg_converte(rec.mensagem)
                  || ';';
         --
         vn_fase := 16.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_ecredac ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_ecredac;

------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro de integração de Escrituração Contabil Sped ECF
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_secf ( en_agendintegr_id in agend_integr.id%type
                             , en_objintegr_id   in obj_integr.id%type
                             , en_usuario_id     in neo_usuario.id%type
                             , ed_dt_ini_integr  in agend_integr.dt_ini_integr%type
                             , ed_dt_fin_integr  in agend_integr.dt_fin_integr%type
                             , en_empresa_id     in empresa.id%type
                             , en_dm_tipo        in agend_integr.dm_tipo%type
                             , en_multorg_id     in mult_org.id%type
                             , ed_dt_agend       in agend_integr.dt_agend%type
                             , ed_dt_termino     in item_agend_integr.dt_termino%type
                             )
is
   --
   vn_fase          number := 0;
   vl_texto         impr_erro_agend_integr.texto%type;
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number := 0;
   --
   cursor c_din_ecf is
   select em.id empresa_id
        , lv.id lancvlrtabdin_id
        , lv.dt_ini
        , lv.dt_fim
        , lv.tabdinecf_id
     from lanc_vlr_tab_din          lv
        , empresa                   em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and lv.empresa_id = em.id
      and lv.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and lv.dt_ini >= ed_dt_ini_integr
      and lv.dt_fim <= ed_dt_fin_integr
    order by em.id
        , lv.dt_ini;
   -- Registro do bloco w300
   cursor c_w300 is
   select em.id empresa_id
        , dp.id declpaisapaisobsadic_id
        , dp.dt_ref
        , dp.jurisdicaosecf_id
     from decl_pais_a_pais_obs_adic dp
        , empresa                   em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and dp.empresa_id = em.id
      and dp.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and dp.dt_ref between ed_dt_ini_integr and ed_dt_fin_integr
    order by em.id
        , dp.dt_ref;
   --
   cursor c_w100 is
   select em.id empresa_id
        , im.id infmultdeclpais_id
        , im.ano_ref
     from inf_mult_decl_pais im
        , empresa            em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and im.empresa_id = em.id
      and im.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(im.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , im.ano_ref;
   -- Identificação de Sócios ou Titular y600
   cursor c_y600 is
   select em.id empresa_id
        , id.pessoa_id
        , id.dt_alt_soc
        , id.dm_ind_qualif_socio
        , id.pessoa_id_rptl
        , id.id identsocioig_id
     from ident_socio_ig id
        , empresa        em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and id.empresa_id = em.id
      and id.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and id.dt_alt_soc between ed_dt_ini_integr and ed_dt_fin_integr
    order by em.id
        , id.dt_alt_soc;
   --
   -- Q100
   cursor c_q100 is
   select dl.id demlivrocaixa_id
        , em.id empresa_id
        , dl.dt_demon
     from dem_livro_caixa dl
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and dl.empresa_id = em.id
      and dl.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and dl.dt_demon between ed_dt_ini_integr and ed_dt_fin_integr
    order by em.id
        , dl.dt_demon;
   --
   --  Y682  Não tem dominio de situacao
   --  Y800  Não tem dominio de situacao
   --
   cursor c_Y720 is
   select em.id empresa_id
        , ipa.id infperantig_id
        , ipa.ano_ref
     from inf_per_ant_ig ipa
        , empresa        em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and ipa.empresa_id = em.id
      and ipa.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(ipa.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , ipa.ano_ref;
   --
   cursor c_y672 is
   select oif.id outrainflplaig_id
        , em.id empresa_id
        , oif.ano_ref
     from outra_inf_lp_la_ig oif
        , empresa            em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and oif.empresa_id = em.id
      and oif.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(oif.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , oif.ano_ref;
   --
   cursor c_y671 is
   select oil.id outrainflrig_id
        , em.id empresa_id
        , oil.ano_ref
     from outra_inf_lr_ig oil
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and oil.empresa_id = em.id
      and oil.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(oil.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , oil.ano_ref;
   --
   cursor c_Y665 is
   select dd.id demdifadiniig_id
        , em.id empresa_id
        , dd.ano_ref
        , dd.planoconta_id
        , dd.centrocusto_id
     from dem_dif_ad_ini_ig dd
        , empresa           em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and dd.empresa_id = em.id
      and dd.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(dd.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , dd.ano_ref;
   --
   cursor c_y660 is
   select ds.id dadosucessoraig_id
        , em.id empresa_id
        , ds.ano_ref
        , ds.pessoa_id
     from dado_sucessora_ig ds
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and ds.empresa_id = em.id
      and ds.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(ds.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , ds.ano_ref
        , ds.pessoa_id;
   --
   cursor c_y640 is
   select pc.id partconsemprig_id
        , em.id empresa_id
        , pc.ano_ref
        , pc.pessoa_id
     from part_cons_empr_ig pc
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and pc.empresa_id = em.id
      and pc.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(pc.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , pc.ano_ref
        , pc.pessoa_id;
   --
   cursor c_y630 is
   select fi.id fundoinvestig_id
        , em.id empresa_id
        , fi.ano_ref
        , fi.pessoa_id
     from fundo_invest_ig fi
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and fi.empresa_id = em.id
      and fi.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(fi.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , fi.ano_ref
        , fi.pessoa_id;
   --
   cursor c_y620 is
   select pa.id partavameteqpatrig_id
        , em.id empresa_id
        , pa.ano_ref
        , pa.pessoa_id
        , pa.dt_evento
        , pa.dm_ind_relac
     from part_ava_met_eq_patr_ig pa
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and pa.empresa_id = em.id
      and pa.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(pa.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , pa.ano_ref
        , pa.pessoa_id;
   --
   cursor c_Y612 is
   select rd.id renddirigiiig_id
        , em.id empresa_id
        , rd.ano_ref
        , rd.pessoa_id
        , rd.dm_qualif
     from rend_dirig_ii_ig rd
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and rd.empresa_id = em.id
      and rd.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(rd.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , rd.ano_ref
        , rd.pessoa_id;
   --
   cursor c_y590 is
   select ae.id ativoexteriorig_id
        , em.id empresa_id
        , ae.ano_ref
        , ae.tipoativoecf_id
        , ae.discrim
     from ativo_exterior_ig ae
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and ae.empresa_id = em.id
      and ae.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(ae.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , ae.ano_ref;
   --
   cursor c_y580 is
    select dc.id doaccampeleitig_id
         , em.id empresa_id
         , dc.ano_ref
         , dc.pessoa_id
     from doac_camp_eleit_ig dc
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and dc.empresa_id = em.id
      and dc.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(dc.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , dc.ano_ref
        , dc.pessoa_id;
   --
   cursor c_y570 is
   select di.id demircsllrfig_id
        , em.id empresa_id
        , di.ano_ref
        , di.pessoa_id
        , di.tiporetimp_id
    from dem_ir_csll_rf_ig di
       , empresa         em
   where em.multorg_id = en_multorg_id
     and (en_dm_tipo not in (1)
          or
         (em.id = en_empresa_id) )
     and di.empresa_id = em.id
     and di.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
     and to_char(to_date(di.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
   order by em.id
       , di.ano_ref
       , di.pessoa_id;
   --
   cursor c_y560 is
   select de.id detexpcomig_id
        , em.id empresa_id
        , de.ano_ref
        /*, de.empresa_id_estab*/
        , de.pessoa_id_part
        , de.ncm_id
    from det_exp_com_ig de
        , empresa         em
   where em.multorg_id = en_multorg_id
     and (en_dm_tipo not in (1)
          or
         (em.id = en_empresa_id) )
     and de.empresa_id = em.id
     and de.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Er ro de validação
     and to_char(to_date(de.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
   order by em.id
       , de.ano_ref;
   --
   cursor c_y550 is
   select vc.id vendcomfimexpig_id
        , em.id empresa_id
        , vc.ano_ref
        , vc.pessoa_id
        , vc.ncm_id
     from vend_com_fim_exp_ig vc
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and vc.empresa_id = em.id
      and vc.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(vc.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , vc.ano_ref
        , vc.pessoa_id;
   --
   cursor c_y540 is
    select dr.id descrrecestabcnaeig_id
         , em.id empresa_id
         , dr.ano_ref
         , dr.empresa_id_estab
         , dr.cnae_id
      from descr_rec_estab_cnae_ig dr
         , empresa         em
     where em.multorg_id = en_multorg_id
       and (en_dm_tipo not in (1)
            or
           (em.id = en_empresa_id) )
       and dr.empresa_id = em.id
       and dr.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
       and to_char(to_date(dr.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
     order by em.id
         , dr.ano_ref
         , dr.empresa_id_estab;
   --   EMPRESA_ID, ANO_REF, PAIS_ID, DM_TIP_EXT, DM_FORMA, NATOPERECF_ID
   cursor c_y520 is
   select pe.id prextnresidig_id
         , em.id empresa_id
         , pe.ano_ref
         , pe.pais_id
         , pe.dm_tip_ext
         , pe.dm_forma
         , pe.natoperecf_id
      from pr_ext_nresid_ig pe
         , empresa         em
     where em.multorg_id = en_multorg_id
       and (en_dm_tipo not in (1)
            or
           (em.id = en_empresa_id) )
       and pe.empresa_id = em.id
       and pe.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
       and to_char(to_date(pe.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
     order by em.id
         , pe.ano_ref
         , pe.pais_id;
   --
   cursor c_X450 is
   select pr.id pagrelextie_id
        , em.id empresa_id
        , pr.ano_ref
        , pr.pais_id
     from pag_rel_ext_ie pr
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and pr.empresa_id = em.id
      and pr.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(pr.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , pr.ano_ref
        , pr.pais_id;
   --
   cursor c_x430 is
   select rr.id rendrelrecebie_id
        , em.id empresa_id
        , rr.ano_ref
        , rr.pais_id
     from rend_rel_receb_ie rr
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and rr.empresa_id = em.id
      and rr.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(rr.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , rr.ano_ref
        , rr.pais_id;
   --
   cursor c_x420 is
   select rr.id royrpbenfie_id
        , em.id empresa_id
        , rr.ano_ref
        , rr.pais_id
     from roy_rp_benf_ie rr
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and rr.empresa_id = em.id
      and rr.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(rr.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , rr.ano_ref
        , rr.pais_id;
   --
   cursor c_x410 is
   select ce.id comeletinfie_id
        , em.id empresa_id
        , ce.ano_ref
        , ce.pais_id
     from com_elet_inf_ie ce
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and ce.empresa_id = em.id
      and ce.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(ce.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , ce.ano_ref
        , ce.pais_id;
   --
   cursor c_x340 is
   select ip.id identpartextie_id
        , em.id empresa_id
        , ip.ano_ref
        , ip.pessoa_id
        , ip.nif
     from ident_part_ext_ie ip
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and ip.empresa_id = em.id
      and ip.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(ip.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , ip.ano_ref
        , ip.pessoa_id;
   --
   cursor c_x320 is
   select oe.id operextimportacaoie_id
        , em.id empresa_id
        , oe.ano_ref
        , oe.num_ordem
     from oper_ext_importacao_ie oe
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and oe.empresa_id = em.id
      and oe.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(oe.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , oe.ano_ref
        , oe.num_ordem;
   --
   cursor c_x300 is
   select oe.id operextexportacaoie_id
        , em.id empresa_id
        , oe.ano_ref
        , oe.num_ordem
     from oper_ext_exportacao_ie oe
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and oe.empresa_id = em.id
      and oe.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and to_char(to_date(oe.ano_ref,'yyyy'),'yyyy') between to_char(ed_dt_ini_integr,'yyyy') and to_char(ed_dt_ini_integr,'yyyy')
    order by em.id
        , oe.ano_ref
        , oe.num_ordem;
   --
   /* NÃO TEM SITUACAO
   cursor c_x280 is
   select ai.id ativincenieecf_id
        , em.id empresa_id
        , ai.dm_ind_ativ
        , ai.dm_ind_proj
        , ai.dt_vig_ini
        , ai.dt_vig_fim
     from ativ_incen_ie_ecf ai
        , empresa         em
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and ai.empresa_id = em.id
      and ai.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and ai.dt_vig_ini >= ed_dt_ini_integr
      and ai.dt_vig_fin <= ed_dt_fin_integr
    order by em.id
        , ai.dt_vig_ini;
   */
   --
   cursor c_log( en_referencia_id  in number
               , ev_obj_referencia in varchar2 ) is
   select distinct --#70117 inclusao de distinct para nao repetir descricao
          lg.resumo
        , lg.mensagem
     from log_generico lg
    where lg.referencia_id  = en_referencia_id
      and lg.obj_referencia = ev_obj_referencia;
   --
   cursor c_log_secf is
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia    = 'DEM_LIVRO_CAIXA' -- Bloco Q100
      and lg.empresa_id        = en_empresa_id
      and tl.id                = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select dl.id
                        from dem_livro_caixa dl
                       where dl.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia    = 'ATIV_INCEN_IE_ECF' -- Bloco X280
      and lg.empresa_id        = en_empresa_id
      and tl.id                = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select ai.id
                        from ativ_incen_ie_ecf ai
                       where ai.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia    = 'OPER_EXT_EXPORTACAO_IE' -- Bloco X300
      and lg.empresa_id        = en_empresa_id
      and tl.id                = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select oe.id
                        from oper_ext_exportacao_ie oe
                       where oe.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'OPER_EXT_IMPORTACAO_IE' -- Bloco X320
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select oe.id
                        from oper_ext_importacao_ie oe
                       where oe.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'IDENT_PART_EXT_IE ' -- Bloco X340
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select ip.id
                        from ident_part_ext_ie ip
                       where ip.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'COM_ELET_INF_IE' -- Bloco x410
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select ce.id
                        from com_elet_inf_ie ce
                       where ce.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'ROY_RP_BENF_IE' -- Bloco X420
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select rr.id
                        from roy_rp_benf_ie rr
                       where rr.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'REND_REL_RECEB_IE' -- Bloco X430
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select oe.id
                        from rend_rel_receb_ie oe
                       where oe.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'PAG_REL_EXT_IE' -- Bloco X450
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select oe.id
                        from pag_rel_ext_ie oe
                       where oe.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'PR_EXT_NRESID_IG' -- Bloco Y520
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select oe.id
                        from pr_ext_nresid_ig oe
                       where oe.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'DESCR_REC_ESTAB_CNAE_IG' -- Bloco Y540
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select dr.id
                        from descr_rec_estab_cnae_ig dr
                       where dr.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'VEND_COM_FIM_EXP_IG' -- Bloco Y550
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select vc.id
                        from vend_com_fim_exp_ig vc
                       where vc.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'DET_EXP_COM_IG' -- Bloco Y560
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select de.id
                        from det_exp_com_ig de
                       where de.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'DEM_IR_CSLL_RF_IG' -- Bloco Y570
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select di.id
                        from dem_ir_csll_rf_ig di
                       where di.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'DOAC_CAMP_ELEIT_IG' -- Bloco Y580
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select dc.id
                        from doac_camp_eleit_ig dc
                       where dc.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'ATIVO_EXTERIOR_IG' -- Bloco Y590
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select ae.id
                        from ativo_exterior_ig ae
                       where ae.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'IDENT_SOCIO_IG' -- Bloco Y600
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select iso.id
                        from ident_socio_ig iso
                       where iso.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'REND_DIRIG_II_IG' -- Bloco Y612
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select oe.id
                        from rend_dirig_ii_ig oe
                       where oe.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'PART_AVA_MET_EQ_PATR_IG' -- Bloco Y620
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select pa.id
                        from part_ava_met_eq_patr_ig pa
                       where pa.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'FUNDO_INVEST_IG' -- Bloco Y630
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select fi.id
                        from fundo_invest_ig fi
                       where fi.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'PART_CONS_EMPR_IG' -- Bloco Y640
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select pc.id
                        from part_cons_empr_ig pc
                       where pc.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'DADO_SUCESSORA_IG' -- Bloco y665
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select ds.id
                        from dado_sucessora_ig ds
                       where ds.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'OUTRA_INF_LR_IG' -- Bloco Y671
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select oi.id
                        from outra_inf_lr_ig oi
                       where oi.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'OUTRA_INF_LP_LA_IG' -- Bloco X280
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select oi.id
                        from outra_inf_lp_la_ig oi
                       where oi.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'INFO_OPT_PAES_IG' -- Bloco  Y690
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select io.id
                        from info_opt_paes_ig io
                       where io.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'INF_PER_ANT_IG' -- Bloco Y720
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select ip.id
                        from inf_per_ant_ig ip
                       where ip.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'INF_MULT_DECL_PAIS' -- Bloco  W100
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select im.id
                        from inf_mult_decl_pais im
                       where im.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'DECL_PAIS_A_PAIS_OBS_ADIC' -- Bloco  W300
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select ip.id
                        from decl_pais_a_pais_obs_adic ip
                       where ip.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico     lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'LANC_VLR_TAB_DIN' -- Bloco  Dinâmico
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select ip.id
                        from lanc_vlr_tab_din ip
                       where ip.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico     lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'CONF_DP_TB_ECF' -- Parâmetros
      and lg.empresa_id       = en_empresa_id
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat        in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select ip.id
                        from conf_dp_tb_ecf ip
                       where ip.id = nvl(lg.referencia_id,0));
   --
   --Log fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico lg
           , csf_tipo_log tl
       where lg.referencia_id  is null
         and lg.empresa_id     = en_empresa_id
         and lg.obj_referencia in ( 'LANC_VLR_TAB_DIN'
                                  , 'DECL_PAIS_A_PAIS_OBS_ADIC'
                                  , 'INF_MULT_DECL_PAIS'
                                  , 'INF_PER_ANT_IG'
                                  , 'INFO_OPT_PAES_IG'
                                  , 'OUTRA_INF_LP_LA_IG'
                                  , 'OUTRA_INF_LR_IG'
                                  , 'DEM_DIF_AD_INI_IG'
                                  , 'DADO_SUCESSORA_IG'
                                  , 'PART_CONS_EMPR_IG'
                                  , 'FUNDO_INVEST_IG'
                                  , 'PART_AVA_MET_EQ_PATR_IG'
                                  , 'REND_DIRIG_II_IG'
                                  , 'IDENT_SOCIO_IG'
                                  , 'ATIVO_EXTERIOR_IG'
                                  , 'DOAC_CAMP_ELEIT_IG'
                                  , 'DEM_IR_CSLL_RF_IG'
                                  , 'DET_EXP_COM_IG'
                                  , 'VEND_COM_FIM_EXP_IG'
                                  , 'DESCR_REC_ESTAB_CNAE_IG'
                                  , 'PR_EXP_NRESID_IG'
                                  , 'PAG_REL_EXT_IE'
                                  , 'REND_REL_RECEB_IE'
                                  , 'ROY_RP_BENF_IE'
                                  , 'COM_ELET_INF_IE'
                                  , 'IDENT_PART_EXT_IE'
                                  , 'OPER_EXT_IMPORTACAO_IE'
                                  , 'OPER_EXT_EXPORTACAO_IE'
                                  , 'ATIV_INCEN_IE_ECF'
                                  , 'DEM_LIVRO_CAIXA'
                                  , 'CONF_DP_TB_ECF'
                                  )
         and tl.id               = lg.csftipolog_id
         and tl.id               in (ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
       order by lg.id;
   --
   procedure pkb_identificacao_reg ( el_texto in impr_erro_agend_integr.texto%type ) is
   begin
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => el_texto
                                    );
      --
   exception
     when others then
        null;
   end pkb_identificacao_reg;
   --
begin
   --
   vn_fase := 1;
   -- Registros Bloco F800
   --
   -- Fazendo o titulo e cabeçalho do relatório.
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'Escrituração Contábil Fiscal - SPED ECF'
                                 );
   --
   vn_fase := 1.2;
   --
   -- Montando o cabeçalho generico.
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'MODULO;EMPRESA;IDENT. REGISTRO;RESUMO;MENSAGEM'
                                 );
   --
   for r_w300 in c_w300
   loop
      --
      exit when c_w300%notfound or (c_w300%notfound) is null;
      --
      vn_fase := 2;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_w300.empresa_id );
      --
      vn_fase := 3;
      --
      for r_log in c_log( en_referencia_id  => r_w300.declpaisapaisobsadic_id
                        , ev_obj_referencia => 'DECL_PAIS_A_PAIS_OBS_ADIC' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         vl_texto := 'Integração do bloco W300 - DECL_PAIS_A_PAIS_OBS_ADIC;'||
                     vv_dados_empresa||';'||
                     'DT_REF: ' || r_w300.dt_ref|| ' JURISDICAOSECF_ID: '|| r_w300.jurisdicaosecf_id ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 5;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 6;
   --
   for r_w100 in c_w100
   loop
      --
      exit when c_w100%notfound or (c_w100%notfound) is null;
      --
      vn_fase := 7;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_w100.empresa_id );
      --
      vn_fase := 8;
      --
      for r_log in c_log( en_referencia_id  => r_w100.infmultdeclpais_id
                        , ev_obj_referencia => 'INF_MULT_DECL_PAIS' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 9;
         --
         vl_texto := 'Integração do bloco W100 - INF_MULT_DECL_PAIS;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: ' ||r_w100.ano_ref||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 10;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 11;
   --
   for r_y600 in c_y600
   loop
      --
      exit when c_y600%notfound or (c_y600%notfound) is null;
      --
      vn_fase := 12;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y600.empresa_id );
      --
      vn_fase := 13;
      --
      for r_log in c_log( en_referencia_id  => r_y600.identsocioig_id
                        , ev_obj_referencia => 'IDENT_SOCIO_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 14;
         --
         vl_texto := 'Integração do bloco Y600 - IDENT_SOCIO_IG;'||
                     vv_dados_empresa||';'||
                     'PESSOA_ID: '|| r_y600.pessoa_id || 'DT_ALT_SOC: ' ||r_y600.dt_alt_soc|| ' DM_IND_QUALIF_SOCIO: '||r_y600.dm_ind_qualif_socio ||
                     'PESSOA_ID_RPTL: ' ||r_y600.pessoa_id_rptl ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 15;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 16;
   --
   for r_q100 in c_q100
   loop
      --
      exit when c_q100%notfound or (c_q100%notfound) is null;
      --
      vn_fase := 17;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_q100.empresa_id );
      --
      vn_fase := 18;
      --
      for r_log in c_log( en_referencia_id  => r_q100.demlivrocaixa_id
                        , ev_obj_referencia => 'DEM_LIVRO_CAIXA' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 19;
         --
         vl_texto := 'Integração do bloco Q100 - DEM_LIVRO_CAIXA;'||
                     vv_dados_empresa||';'||
                     'DT_DEMON: '|| r_q100.dt_demon ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 20;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 21;
   --
   for r_y720 in c_y720
   loop
      --
      exit when c_y720%notfound or (c_y720%notfound) is null;
      --
      vn_fase := 22;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y720.empresa_id );
      --
      vn_fase := 23;
      --
      for r_log in c_log( en_referencia_id  => r_y720.infperantig_id
                        , ev_obj_referencia => 'INF_PER_ANT_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 24;
         --
         vl_texto := 'Integração do bloco Y720 - INF_PER_ANT_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y720.ano_ref ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 25;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 25;
   --
   for r_y672 in c_y672
   loop
      --
      exit when c_y672%notfound or (c_y672%notfound) is null;
      --
      vn_fase := 26;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y672.empresa_id );
      --
      vn_fase := 27;
      --
      for r_log in c_log( en_referencia_id  => r_y672.outrainflplaig_id
                        , ev_obj_referencia => 'OUTRA_INF_LP_LA_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 28;
         --
         vl_texto := 'Integração do bloco Y672 - OUTRA_INF_LP_LA_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y672.ano_ref ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 29;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 30;
   --
   for r_y671 in c_y671
   loop
      --
      exit when c_y671%notfound or (c_y671%notfound) is null;
      --
      vn_fase := 31;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y671.empresa_id );
      --
      vn_fase := 32;
      --
      for r_log in c_log( en_referencia_id  => r_y671.outrainflrig_id
                        , ev_obj_referencia => 'OUTRA_INF_LR_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 33;
         --
         vl_texto := 'Integração do bloco Y671 - OUTRA_INF_LR_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y671.ano_ref ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 34;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 35;
   --
   for r_y665 in c_y665
   loop
      --
      exit when c_y665%notfound or (c_y665%notfound) is null;
      --
      vn_fase := 36;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y665.empresa_id );
      --
      vn_fase := 37;
      --
      for r_log in c_log( en_referencia_id  => r_y665.demdifadiniig_id
                        , ev_obj_referencia => 'DEM_DIF_AD_INI_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 38;
         --
         vl_texto := 'Integração do bloco Y665 - DEM_DIF_AD_INI_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y665.ano_ref ||' PLANOCONTA_ID: ' || r_y665.planoconta_id || ' CENTROCUSTO_ID: ' || r_y665.centrocusto_id ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 39;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 40;
   --
   for r_y660 in c_y660
   loop
      --
      exit when c_y660%notfound or (c_y660%notfound) is null;
      --
      vn_fase := 41;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y660.empresa_id );
      --
      vn_fase := 42;
      --
      for r_log in c_log( en_referencia_id  => r_y660.dadosucessoraig_id
                        , ev_obj_referencia => 'DADO_SUCESSORA_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 43;
         --
         vl_texto := 'Integração do bloco Y660 - DADO_SUCESSORA_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y660.ano_ref ||' PESSOA_ID: ' || r_y660.pessoa_id ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 44;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 45;
   --
   for r_y640 in c_y640
   loop
      --
      exit when c_y640%notfound or (c_y640%notfound) is null;
      --
      vn_fase := 46;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y640.empresa_id );
      --
      vn_fase := 47;
      --
      for r_log in c_log( en_referencia_id  => r_y640.partconsemprig_id
                        , ev_obj_referencia => 'PART_CONS_EMPR_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 48;
         --
         vl_texto := 'Integração do bloco Y640 - PART_CONS_EMPR_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y640.ano_ref ||' PESSOA_ID: ' || r_y640.pessoa_id ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 49;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 50;
   --
   for r_y630 in c_y630
   loop
      --
      exit when c_y630%notfound or (c_y630%notfound) is null;
      --
      vn_fase := 51;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y630.empresa_id );
      --
      vn_fase := 52;
      --
      for r_log in c_log( en_referencia_id  => r_y630.fundoinvestig_id
                        , ev_obj_referencia => 'FUNDO_INVEST_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 53;
         --
         vl_texto := 'Integração do bloco Y630 - FUNDO_INVEST_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y630.ano_ref ||' PESSOA_ID: ' || r_y630.pessoa_id ||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 54;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 55;
   --
   for r_y620 in c_y620
   loop
      --
      exit when c_y620%notfound or (c_y620%notfound) is null;
      --
      vn_fase := 56;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y620.empresa_id );
      --
      vn_fase := 57;
      --
      for r_log in c_log( en_referencia_id  => r_y620.partavameteqpatrig_id
                        , ev_obj_referencia => 'PART_AVA_MET_EQ_PATR_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 58;
         --
         vl_texto := 'Integração do bloco Y620 - PART_AVA_MET_EQ_PATR_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y620.ano_ref ||' PESSOA_ID: ' || r_y620.pessoa_id || ' DT_EVENTO: ' || r_y620.dt_evento ||
                     ' DM_IND_RELAC: ' || r_y620.dm_ind_relac || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 59;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 60;
   --
   for r_y612 in c_Y612
   loop
      --
      exit when c_Y612%notfound or (c_Y612%notfound) is null;
      --
      vn_fase := 61;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y612.empresa_id );
      --
      vn_fase := 62;
      --
      for r_log in c_log( en_referencia_id  => r_y612.renddirigiiig_id
                        , ev_obj_referencia => 'REND_DIRIG_II_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 63;
         --
         vl_texto := 'Integração do bloco Y612 - REND_DIRIG_II_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y612.ano_ref ||' PESSOA_ID: ' || r_y612.pessoa_id || ' DM_QUALIF: ' || r_y612.dm_qualif || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 64;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 65;
   --
   for r_y590 in c_y590
   loop
      --
      exit when c_y590%notfound or (c_y590%notfound) is null;
      --
      vn_fase := 66;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y590.empresa_id );
      --
      vn_fase := 67;
      --
      for r_log in c_log( en_referencia_id  => r_y590.ativoexteriorig_id
                        , ev_obj_referencia => 'ATIVO_EXTERIOR_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 68;
         --
         vl_texto := 'Integração do bloco Y590 - ATIVO_EXTERIOR_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y590.ano_ref || ' TIPOATIVOECF_ID: ' || r_y590.tipoativoecf_id || ' DISCRIM: ' || r_y590.discrim || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 69;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 70;
   --
   for r_y580 in c_y580
   loop
      --
      exit when c_y580%notfound or (c_y580%notfound) is null;
      --
      vn_fase := 71;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y580.empresa_id );
      --
      vn_fase := 72;
      --
      for r_log in c_log( en_referencia_id  => r_y580.doaccampeleitig_id
                        , ev_obj_referencia => 'DOAC_CAMP_ELEIT_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 73;
         --
         vl_texto := 'Integração do bloco Y580 - DOAC_CAMP_ELEIT_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y580.ano_ref ||' PESSOA_ID: ' || r_y580.pessoa_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 74;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 75;
   --
   for r_y570 in c_y570
   loop
      --
      exit when c_y570%notfound or (c_y570%notfound) is null;
      --
      vn_fase := 76;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y570.empresa_id );
      --
      vn_fase := 77;
      --
      for r_log in c_log( en_referencia_id  => r_y570.demircsllrfig_id
                        , ev_obj_referencia => 'DEM_IR_CSLL_RF_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 78;
         --
         vl_texto := 'Integração do bloco Y570 - DEM_IR_CSLL_RF_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y570.ano_ref ||' PESSOA_ID: ' || r_y570.pessoa_id ||' TIPORETIMP_ID: ' || r_y570.tiporetimp_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 79;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 80;
   --
   for r_y560 in c_y560
   loop
      --
      exit when c_y560%notfound or (c_y560%notfound) is null;
      --
      vn_fase := 81;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y560.empresa_id );
      --
      vn_fase := 82;
      --
      for r_log in c_log( en_referencia_id  => r_y560.detexpcomig_id
                        , ev_obj_referencia => 'DET_EXP_COM_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 83;
         --
         vl_texto := 'Integração do bloco Y560 - DET_EXP_COM_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y560.ano_ref ||' PESSOA_ID_PART: ' || r_y560.pessoa_id_part ||' NCM_ID: ' || r_y560.ncm_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 84;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 85;
   --
   for r_y550 in c_y550
   loop
      --
      exit when c_y550%notfound or (c_y550%notfound) is null;
      --
      vn_fase := 86;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y550.empresa_id );
      --
      vn_fase := 87;
      --
      for r_log in c_log( en_referencia_id  => r_y550.vendcomfimexpig_id
                        , ev_obj_referencia => 'VEND_COM_FIM_EXP_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 88;
         --
         vl_texto := 'Integração do bloco Y550 - VEND_COM_FIM_EXP_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y550.ano_ref ||' PESSOA_ID: ' || r_y550.pessoa_id ||' NCM_ID: ' || r_y550.ncm_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 89;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 90;
   --
   for r_y540 in c_y540
   loop
      --
      exit when c_y540%notfound or (c_y540%notfound) is null;
      --
      vn_fase := 91;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y540.empresa_id );
      --
      vn_fase := 92;
      --
      for r_log in c_log( en_referencia_id  => r_y540.descrrecestabcnaeig_id
                        , ev_obj_referencia => 'DESCR_REC_ESTAB_CNAE_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 93;
         --
         vl_texto := 'Integração do bloco Y540 - DESCR_REC_ESTAB_CNAE_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y540.ano_ref ||' EMPRESA_ID_ESTAB: ' || r_y540.empresa_id_estab ||' CNAE_ID: ' || r_y540.CNAE_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 94;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 95;
   --
   for r_y520 in c_y520
   loop
      --
      exit when c_y520%notfound or (c_y520%notfound) is null;
      --
      vn_fase := 96;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_y520.empresa_id );
      --
      vn_fase := 97;
      --
      for r_log in c_log( en_referencia_id  => r_y520.prextnresidig_id
                        , ev_obj_referencia => 'PR_EXT_NRESID_IG' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 98;
         --
         vl_texto := 'Integração do bloco Y520 - PR_EXT_NRESID_IG;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_y520.ano_ref ||' PAIS_ID: ' || r_y520.pais_id ||' DM_TIP_EXT: ' || r_y520.dm_tip_ext ||
                     ' DM_FORMA: ' || r_y520.dm_forma || ' NATOPERECF_ID: ' || r_y520.natoperecf_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 99;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 99.1;
   --
   for r_x450 in c_X450
   loop
      --
      exit when c_X450%notfound or (c_X450%notfound) is null;
      --
      vn_fase := 99.2;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_x450.empresa_id );
      --
      vn_fase := 99.3;
      --
      for r_log in c_log( en_referencia_id  => r_x450.pagrelextie_id
                        , ev_obj_referencia => 'PAG_REL_EXT_IE' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 99.4;
         --
         vl_texto := 'Integração do bloco x450 - PAG_REL_EXT_IE;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_x450.ano_ref ||' PAIS_ID: ' || r_x450.pais_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 99.5;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 99.6;
   --
   for r_x430 in c_x430
   loop
      --
      exit when c_x430%notfound or (c_x430%notfound) is null;
      --
      vn_fase := 99.7;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_x430.empresa_id );
      --
      vn_fase := 99.8;
      --
      for r_log in c_log( en_referencia_id  => r_x430.rendrelrecebie_id
                        , ev_obj_referencia => 'REND_REL_RECEB_IE' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 99.9;
         --
         vl_texto := 'Integração do bloco x430 - REND_REL_RECEB_IE;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_x430.ano_ref ||' PAIS_ID: ' || r_x430.pais_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 99.10;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 99.11;
   --
   for r_x420 in c_x420
   loop
      --
      exit when c_x420%notfound or (c_x420%notfound) is null;
      --
      vn_fase := 99.12;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_x420.empresa_id );
      --
      vn_fase := 99.13;
      --
      for r_log in c_log( en_referencia_id  => r_x420.royrpbenfie_id
                        , ev_obj_referencia => 'ROY_RP_BENF_IE' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 99.14;
         --
         vl_texto := 'Integração do bloco x420 - ROY_RP_BENF_IE;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_x420.ano_ref ||' PAIS_ID: ' || r_x420.pais_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 99.15;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 99.16;
   --
   for r_x410 in c_x410
   loop
      --
      exit when c_x410%notfound or (c_x410%notfound) is null;
      --
      vn_fase := 99.17;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_x410.empresa_id );
      --
      vn_fase := 99.18;
      --
      for r_log in c_log( en_referencia_id  => r_x410.comeletinfie_id
                        , ev_obj_referencia => 'COM_ELET_INF_IE' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 99.19;
         --
         vl_texto := 'Integração do bloco x410 - COM_ELET_INF_IE;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_x410.ano_ref ||' PAIS_ID: ' || r_x410.pais_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 99.20;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 99.21;
   --
   for r_x340 in c_x340
   loop
      --
      exit when c_x340%notfound or (c_x340%notfound) is null;
      --
      vn_fase := 99.22;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_x340.empresa_id );
      --
      vn_fase := 99.23;
      --
      for r_log in c_log( en_referencia_id  => r_x340.identpartextie_id
                        , ev_obj_referencia => 'IDENT_PART_EXT_IE' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 99.24;
         --
         vl_texto := 'Integração do bloco X340 - IDENT_PART_EXT_IE;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_x340.ano_ref ||' PESSOA_ID: ' || r_x340.pessoa_id || ' NIF: ' || r_x340.nif || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 99.25;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 99.26;
   --
   for r_x320 in c_x320
   loop
      --
      exit when c_x320%notfound or (c_x320%notfound) is null;
      --
      vn_fase := 99.27;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_x320.empresa_id );
      --
      vn_fase := 99.28;
      --
      for r_log in c_log( en_referencia_id  => r_x320.operextimportacaoie_id
                        , ev_obj_referencia => 'OPER_EXT_IMPORTACAO_IE' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 99.29;
         --
         vl_texto := 'Integração do bloco X320 - OPER_EXT_IMPORTACAO_IE;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_x320.ano_ref ||' NUM_ORDEM: ' || r_x320.num_ordem || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 99.30;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 99.31;
   --
   for r_x300 in c_x300
   loop
      --
      exit when c_x300%notfound or (c_x300%notfound) is null;
      --
      vn_fase := 99.32;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_x300.empresa_id );
      --
      vn_fase := 99.33;
      --
      for r_log in c_log( en_referencia_id  => r_x300.operextexportacaoie_id
                        , ev_obj_referencia => 'OPER_EXT_EXPORTACAO_IE' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 99.34;
         --
         vl_texto := 'Integração do bloco X320 - OPER_EXT_EXPORTACAO_IE;'||
                     vv_dados_empresa||';'||
                     'ANO_REF: '|| r_x300.ano_ref ||' NUM_ORDEM: ' || r_x300.num_ordem || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 99.35;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 99.36;
   -- c_din_ecf
   for r_din_ecf in c_din_ecf
   loop
      --
      exit when c_din_ecf%notfound or (c_din_ecf%notfound) is null;
      --
      vn_fase := 99.37;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_din_ecf.empresa_id );
      --
      vn_fase := 99.38;
      --
      for r_log in c_log( en_referencia_id  => r_din_ecf.lancvlrtabdin_id
                        , ev_obj_referencia => 'LANC_VLR_TAB_DIN' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 99.39;
         --
         vl_texto := 'Integração das Views Dinâmicas do ECF - LANC_VLR_TAB_DIN;'||
                     vv_dados_empresa||';'||
                     'DT_INI: '|| to_date(r_din_ecf.dt_ini,'dd/mm/yyyy') ||'DT_FIM: '|| to_date(r_din_ecf.dt_fim,'dd/mm/yyyy') ||
                     ' TABDINECF_ID: ' || r_din_ecf.tabdinecf_id || ';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 99.40;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   for rec in c_log_secf
   loop
     exit when c_log_secf%notfound or (c_log_secf%notfound) is null;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;REFERENCIA_ID;DT_HR_LOG;RESUMO;MENSAGEM;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vl_texto := rec.tipo||';'||
                  ';'|| --referencia_id null;
                  --r_log_ddo.tipo||';'||
                  to_char(rec.dt_hr_log,'dd/mm/rrrr') ||';'||
                  pk_csf.fkg_converte(rec.resumo)     ||';'||
                  pk_csf.fkg_converte(rec.mensagem)   ||';';
      --
      vn_fase := 75;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 76;
   --
   --Log fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id (en_empresa_id => rec.empresa_id);
      --
      vl_texto := null;
      vl_texto := 'Informação - fechamento fiscal;'
               || vv_dados_empresa || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)   ||';'
               || pk_csf.fkg_converte(rec.mensagem) ||';';
      --
      vn_fase := 77;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_tel_secf ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_secf;

------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro de usuário
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_usuario ( en_agendintegr_id  in agend_integr.id%type
                                , en_objintegr_id    in obj_integr.id%type
                                , en_usuario_id      in neo_usuario.id%type
                                , ed_dt_agend        in agend_integr.dt_agend%type
                                , ed_dt_termino      in item_agend_integr.dt_termino%type
                                , en_multorg_id      in mult_org.id%type
                                )
is
   --
   vn_fase      number := 0;
   vl_texto     impr_erro_agend_integr.texto%type;
   vn_first_reg number := 0;
   --
   cursor c_usu is
   select u.*
     from neo_usuario u
    where u.dm_st_proc  = 2
      and u.multorg_id  = en_multorg_id
    order by u.id;
   --
   cursor c_log ( en_referencia_id in log_generico_usu.id%type ) is
   select lgu.*
     from log_generico_usu  lgu
    where lgu.referencia_id     = en_referencia_id
      and lgu.obj_referencia    = 'NEO_USUARIO'
      and trunc(lgu.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgu.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
    order by lgu.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_usu loop
      exit when c_usu%notfound or (c_usu%notfound) is null;
      --
      vn_fase := 3;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Logs de Erros do Usuario'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'LOGIN;NOME;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := rec.login || ';'
                     || rec.nome || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_usuario ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_usuario;
------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro de ciap
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_ciap ( en_agendintegr_id  in agend_integr.id%type
                             , en_objintegr_id    in obj_integr.id%type
                             , en_usuario_id      in neo_usuario.id%type
                             , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                             , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                             , en_empresa_id      in empresa.id%type
                             , en_dm_tipo         in agend_integr.dm_tipo%type
                             , en_multorg_id      in mult_org.id%type
                             , ed_dt_agend        in agend_integr.dt_agend%type
                             , ed_dt_termino      in item_agend_integr.dt_termino%type
                             )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number        := 0;
   --
   cursor c_ciap is
   select iac.id
        , iac.empresa_id
        , iac.dt_ini
        , iac.dt_fin
     from empresa e
        , icms_atperm_ciap iac
    where e.multorg_id      = en_multorg_id
      and iac.empresa_id    = e.id
      and iac.dm_st_proc    = 2
      and ( en_dm_tipo      not in (1) or (iac.empresa_id = en_empresa_id) )
      and trunc(iac.dt_ini) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by iac.id;
   --
   cursor c_log ( en_referencia_id in log_generico_ciap.id%type ) is
   select lgc.*
     from log_generico_ciap  lgc
        , csf_tipo_log  tl
    where lgc.referencia_id    = en_referencia_id
      and lgc.obj_referencia   = 'ICMS_ATPERM_CIAP'
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by lgc.id;
   --
   -- Log fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_ciap lg
           , csf_tipo_log      tl
       where lg.empresa_id       = en_empresa_id
         and lg.referencia_id    is null
         and lg.obj_referencia   = 'ICMS_ATPERM_CIAP'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_ciap loop
      exit when c_ciap%notfound or (c_ciap%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Tabela CADASTRO DE BENS OU COMPONENTES DO ATIVO IMOBILIZADO - 0300'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;DATA_INICIAL;DATA_FINAL;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || to_char(rec.dt_ini, 'dd/mm/rrrr') || ';'
                     || to_char(rec.dt_fin, 'dd/mm/rrrr') || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   --Log de fehamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => en_empresa_id);
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'Tabela CADASTRO DE BENS OU COMPONENTES DO ATIVO IMOBILIZADO - 0300'
                                       );
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'EMPRESA;DATA_INICIAL;DATA_FINAL;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 5.1;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)
               || ';';
      --
      vn_fase := 5.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_ciap ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_ciap;
------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Notas Fiscais de Serviços EFD
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_nota_fiscal_efd ( en_agendintegr_id    in agend_integr.id%type
                                        , en_objintegr_id      in obj_integr.id%type
                                        , en_usuario_id        in neo_usuario.id%type
                                        , ed_dt_ini_integr     in agend_integr.dt_ini_integr%type
                                        , ed_dt_fin_integr     in agend_integr.dt_fin_integr%type
                                        , en_empresa_id        in empresa.id%type
                                        , en_dm_tipo           in agend_integr.dm_tipo%type
                                        , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type
                                        , en_multorg_id        in mult_org.id%type
                                        , ed_dt_agend          in agend_integr.dt_agend%type
                                        , ed_dt_termino        in item_agend_integr.dt_termino%type
                                        )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number := 0;
   --
   cursor c_nf is
   select nf.id
        , nf.empresa_id
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , p.cod_part
        , mf.cod_mod
        , nf.serie
        , nf.nro_nf
        , nf.dt_sai_ent
        , nf.dt_emiss
     from empresa     e
        , nota_fiscal nf
        , mod_fiscal  mf
        , pessoa      p
    where e.multorg_Id = en_multorg_id
      and nf.empresa_id = e.id
      and nf.dm_st_proc not in (4, 6, 7, 8, 20)
      and ( en_dm_tipo not in (1) or (nf.empresa_id = en_empresa_id) )
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)))
      and mf.id      = nf.modfiscal_id
      and mf.cod_mod in ('99', 'ND')
      and p.id(+)    = nf.pessoa_id
    order by nf.id;
   --
   cursor c_log ( en_referencia_id in log_generico_nf.id%type ) is
   select lgn.*
     from log_generico_nf  lgn
        , csf_tipo_log  tl
    where lgn.referencia_id  = en_referencia_id
      and lgn.obj_referencia = 'NOTA_FISCAL'
      and tl.id              = lgn.csftipolog_id
      and tl.cd_compat       in ('1','2')
    order by lgn.id;
   --
   -- Log fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select distinct lg.empresa_id, trunc(lg.dt_hr_log) dt_hr_log  , lg.resumo
      --lg.* -- #71510 inclusao distinct para nao repetir dados da mesma data
        from log_generico_nf lg
           , csf_tipo_log    tl
       where lg.referencia_id    is null
         and lg.empresa_id       = en_empresa_id
         and lg.obj_referencia   = 'NOTA_FISCAL'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by trunc(lg.dt_hr_log);
      --lg.id; -- #71510
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Informações de logs da tabela de Notas Fiscais de Serviços EFD'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;DM_IND_EMIT;DM_IND_OPER;COD_PART;COD_MOD;SERIE;NRO_NF;DATA_EMISSAO;DATA_SAI_ENT;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || pk_csf.fkg_dominio( 'NOTA_FISCAL.DM_IND_EMIT', rec.dm_ind_emit ) || ';'
                     || pk_csf.fkg_dominio( 'NOTA_FISCAL.DM_IND_OPER', rec.dm_ind_oper ) || ';'
                     || rec.cod_part || ';'
                     || rec.cod_mod || ';'
                     || rec.serie || ';'
                     || rec.nro_nf || ';'
                     || to_char(rec.dt_emiss, 'dd/mm/rrrr') || ';'
                     || to_char(rec.dt_sai_ent, 'dd/mm/rrrr') || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   --Log fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id (en_empresa_id => rec.empresa_id);
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'Informações de logs da tabela de Notas Fiscais de Serviços EFD'
                                       );
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'EMPRESA;DM_IND_EMIT;DM_IND_OPER;COD_PART;COD_MOD;SERIE;NRO_NF;DATA_EMISSAO;DATA_SAI_ENT;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)
               || ';';
      --
      vn_fase := 5.1;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_nota_fiscal_efd ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_nota_fiscal_efd;
------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Notas Fiscais Mercantis
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_nota_fiscal ( en_agendintegr_id    in agend_integr.id%type
                                    , en_objintegr_id      in obj_integr.id%type
                                    , en_usuario_id        in neo_usuario.id%type
                                    , ed_dt_ini_integr     in agend_integr.dt_ini_integr%type
                                    , ed_dt_fin_integr     in agend_integr.dt_fin_integr%type
                                    , en_empresa_id        in empresa.id%type
                                    , en_dm_tipo           in agend_integr.dm_tipo%type
                                    , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type
                                    , en_multorg_id        in mult_org.id%type
                                    , ed_dt_agend          in agend_integr.dt_agend%type
                                    , ed_dt_termino        in item_agend_integr.dt_termino%type
                                    )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number := 0;
   --
   cursor c_nf is
   select nf.id
        , nf.empresa_id
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , p.cod_part
        , mf.cod_mod
        , nf.serie
        , nf.nro_nf
        , nf.dt_sai_ent
        , nf.dt_emiss
     from empresa     e
        , nota_fiscal nf
        , mod_fiscal  mf
        , pessoa      p
    where e.multorg_Id = en_multorg_id
      and nf.empresa_id = e.id
      and nf.dm_st_proc not in (4, 6, 7, 8)
      and ( en_dm_tipo not in (1) or (nf.empresa_id = en_empresa_id) )
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)))
      and mf.id       = nf.modfiscal_id
      and mf.cod_mod in ('01', '1B', '04', '55', '65', '57')
      and p.id(+)     = nf.pessoa_id
    order by nf.id;
   --
   cursor c_log ( en_referencia_id in log_generico_nf.id%type ) is
   select lgn.*
     from log_generico_nf  lgn
        , csf_tipo_log  tl
    where lgn.referencia_id  = en_referencia_id
      and lgn.obj_referencia = 'NOTA_FISCAL'
      and tl.id              = lgn.csftipolog_id
      and tl.cd_compat       in ('1','2')
    order by lgn.id;
   --
   -- Logs (fechamento periodo fiscal)
   cursor c_log_null(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lgn.*
        from log_generico_nf lgn
           , csf_tipo_log    tl
       where lgn.empresa_id       = en_empresa_id
         and lgn.referencia_id    is null
         and lgn.obj_referencia   = 'NOTA_FISCAL'
         and tl.id                = lgn.csftipolog_id
         and tl.id                in(ev_info_fechamento)
         and trunc(lgn.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lgn.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lgn.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Informações de logs da tabela de Notas Fiscais Mercantis'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;DM_IND_EMIT;DM_IND_OPER;COD_PART;COD_MOD;SERIE;NRO_NF;DATA_EMISSAO;DATA_SAI_ENT;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || pk_csf.fkg_dominio( 'NOTA_FISCAL.DM_IND_EMIT', rec.dm_ind_emit ) || ';'
                     || pk_csf.fkg_dominio( 'NOTA_FISCAL.DM_IND_OPER', rec.dm_ind_oper ) || ';'
                     || rec.cod_part || ';'
                     || rec.cod_mod || ';'
                     || rec.serie || ';'
                     || rec.nro_nf || ';'
                     || to_char(rec.dt_emiss, 'dd/mm/rrrr') || ';'
                     || to_char(rec.dt_sai_ent, 'dd/mm/rrrr') || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   -- Recuperando logs(fechamento fiscal)
   for rec in c_log_null(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_log_null%notfound or (c_log_null%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id (en_empresa_id => rec.empresa_id);
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'Informações de logs da tabela de Notas Fiscais Mercantis'
                                       );
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'EMPRESA;DM_IND_EMIT;DM_IND_OPER;COD_PART;COD_MOD;SERIE;NRO_NF;DATA_EMISSAO;DATA_SAI_ENT;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 6;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)
               || ';';
      --
      vn_fase := 7;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_nota_fiscal ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_nota_fiscal;
------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Notas Fiscais de Serviços Contínuos (Água, Luz, etc.)
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_nota_fiscal_sc ( en_agendintegr_id    in agend_integr.id%type
                                       , en_objintegr_id      in obj_integr.id%type
                                       , en_usuario_id        in neo_usuario.id%type
                                       , ed_dt_ini_integr     in agend_integr.dt_ini_integr%type
                                       , ed_dt_fin_integr     in agend_integr.dt_fin_integr%type
                                       , en_empresa_id        in empresa.id%type
                                       , en_dm_tipo           in agend_integr.dm_tipo%type
                                       , en_dm_dt_escr_dfepoe in empresa.dm_dt_escr_dfepoe%type
                                       , en_multorg_id        in mult_org.id%type
                                       , ed_dt_agend          in agend_integr.dt_agend%type
                                       , ed_dt_termino        in item_agend_integr.dt_termino%type
                                       )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number := 0;
   --
   cursor c_nf is
   select nf.id
        , nf.empresa_id
        , nf.dm_ind_emit
        , nf.dm_ind_oper
        , p.cod_part
        , mf.cod_mod
        , nf.serie
        , nf.nro_nf
        , nf.dt_sai_ent
        , nf.dt_emiss
     from empresa     e
        , nota_fiscal nf
        , mod_fiscal  mf
        , pessoa      p
    where e.multorg_id = en_multorg_id
      and nf.empresa_Id = e.id
      and nf.dm_st_proc not in (4, 6, 7, 8)
      and ( en_dm_tipo not in (1) or (nf.empresa_id = en_empresa_id) )
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and en_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)))
      and mf.id       = nf.modfiscal_id
      and mf.cod_mod in ('06', '21', '22', '28', '29')
      and p.id(+)     = nf.pessoa_id
    order by nf.id;
   --
   cursor c_log ( en_referencia_id in log_generico_nf.id%type ) is
   select lgn.*
     from log_generico_nf  lgn
        , csf_tipo_log  tl
    where lgn.referencia_id  = en_referencia_id
      and lgn.obj_referencia = 'NOTA_FISCAL'
      and tl.id              = lgn.csftipolog_id
      and tl.cd_compat       in ('1','2')
    order by lgn.id;
   --
   -- Log de fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_nf lg
           , csf_tipo_log    tl
       where lg.empresa_id       = en_empresa_id
         and lg.referencia_id    is null
         and lg.obj_referencia   = 'NOTA_FISCAL'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_nf loop
      exit when c_nf%notfound or (c_nf%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Informações de logs da tabela de Notas Fiscais de Serviços Contínuos (Água, Luz, etc.)'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;DM_IND_EMIT;DM_IND_OPER;COD_PART;COD_MOD;SERIE;NRO_NF;DATA_EMISSAO;DATA_SAI_ENT;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || pk_csf.fkg_dominio( 'NOTA_FISCAL.DM_IND_EMIT', rec.dm_ind_emit ) || ';'
                     || pk_csf.fkg_dominio( 'NOTA_FISCAL.DM_IND_OPER', rec.dm_ind_oper ) || ';'
                     || rec.cod_part || ';'
                     || rec.cod_mod || ';'
                     || rec.serie || ';'
                     || rec.nro_nf || ';'
                     || to_char(rec.dt_emiss, 'dd/mm/rrrr') || ';'
                     || to_char(rec.dt_sai_ent, 'dd/mm/rrrr') || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   -- Recuperando o log de fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id (en_empresa_id => rec.empresa_id);
      --
      vn_fase := 5.1;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'Informações de logs da tabela de Notas Fiscais de Serviços Contínuos (Água, Luz, etc.)'
                                       );
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'EMPRESA;DM_IND_EMIT;DM_IND_OPER;COD_PART;COD_MOD;SERIE;NRO_NF;DATA_EMISSAO;DATA_SAI_ENT;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 5.2;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)
               || ';';
      --
      vn_fase := 5.3;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_nota_fiscal_sc ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_nota_fiscal_sc;
------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro de conhecimento de transporte
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_conhec_transp ( en_agendintegr_id  in agend_integr.id%type
                                      , en_objintegr_id    in obj_integr.id%type
                                      , en_usuario_id      in neo_usuario.id%type
                                      , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                                      , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                                      , en_empresa_id      in empresa.id%type
                                      , en_dm_tipo         in agend_integr.dm_tipo%type
                                      , en_multorg_id      in mult_org.id%type
                                      , ed_dt_agend        in agend_integr.dt_agend%type
                                      , ed_dt_termino      in item_agend_integr.dt_termino%type
                                      )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg     number := 0;
   --
   cursor c_ct is
   select ct.id
        , ct.empresa_id
        , ct.dm_ind_emit
        , ct.dm_ind_oper
        , p.cod_part
        , mf.cod_mod
        , ct.serie
        , ct.subserie
        , ct.nro_ct
        , ct.dt_sai_ent
        , ct.dt_hr_emissao
     from empresa        e
        , conhec_transp  ct
        , mod_fiscal     mf
        , pessoa         p
    where e.id           = ct.empresa_id
      and mf.id          = ct.modfiscal_id
      and p.id(+)        = ct.pessoa_id
      and ct.empresa_id  = nvl(en_empresa_id, ct.empresa_id)
      and trunc(nvl(ct.dt_sai_ent, ct.dt_hr_emissao)) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
      and e.multorg_id   = en_multorg_id
    order by ct.id;
   --
   cursor c_log ( en_referencia_id in log_generico_ct.id%type ) is
   select lgc.*
     from log_generico_ct  lgc
        , csf_tipo_log  tl
    where lgc.referencia_id     = en_referencia_id
      and lgc.obj_referencia    = 'CONHEC_TRANSP'
      and tl.id                 = lgc.csftipolog_id
      and tl.cd_compat          in ('1','2')
    order by lgc.id;
   --
   --Log de fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fehcamento in varchar2) is
      select lg.*
        from log_generico_ct lg
           , csf_tipo_log    tl
       where lg.empresa_id       = en_empresa_id
         and lg.referencia_id    is null
         and lg.obj_referencia   = 'CONHEC_TRANSP'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fehcamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      order by lg.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_ct loop
      exit when c_ct%notfound or (c_ct%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Informações de logs de Conhecimento de Transporte'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;DM_IND_EMIT;DM_IND_OPER;COD_PART;COD_MOD;SERIE;SUBSERIE;NRO_CT;DATA_EMISSAO;DATA_SAI_ENT;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';' -- EMPRESA
                     || pk_csf.fkg_dominio( 'CONHEC_TRANSP.DM_IND_EMIT', rec.dm_ind_emit ) || ';' -- DM_IND_EMIT
                     || pk_csf.fkg_dominio( 'CONHEC_TRANSP.DM_IND_OPER', rec.dm_ind_oper ) || ';' -- DM_IND_OPER
                     || rec.cod_part || ';' -- COD_PART
                     || rec.cod_mod || ';' -- COD_PART
                     || rec.serie || ';' -- SERIE
                     || rec.subserie || ';' -- SUBSERIE
                     || rec.nro_ct || ';' -- NRO_CT
                     || to_char(rec.dt_hr_emissao, 'dd/mm/rrrr') || ';' -- DATA_EMISSAO
                     || to_char(rec.dt_sai_ent, 'dd/mm/rrrr') || ';' -- DATA_SAI_ENT
                     || pk_csf.fkg_converte(rec2.resumo) || ';'; -- RESUMO
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   -- Recuperando o log do fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fehcamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id (en_empresa_id => rec.empresa_id);
      --
      vn_fase := 5.1;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'Informações de logs de Conhecimento de Transporte'
                                       );
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'EMPRESA;DM_IND_EMIT;DM_IND_OPER;COD_PART;COD_MOD;SERIE;SUBSERIE;NRO_CT;DATA_EMISSAO;DATA_SAI_ENT;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               ||  pk_csf.fkg_converte(rec.resumo)
               ||';';
      --
      vn_fase := 5.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_conhec_transp ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_conhec_transp;
------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro de cupom fiscal
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_cupom_fiscal ( en_agendintegr_id  in agend_integr.id%type
                                     , en_objintegr_id    in obj_integr.id%type
                                     , en_usuario_id      in neo_usuario.id%type
                                     , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                                     , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                                     , en_empresa_id      in empresa.id%type
                                     , en_dm_tipo         in agend_integr.dm_tipo%type
                                     , en_multorg_id      in mult_org.id%type
                                     , ed_dt_agend        in agend_integr.dt_agend%type
                                     , ed_dt_termino      in item_agend_integr.dt_termino%type
                                     )
   is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   vn_first_reg number := 0;
   --
   vv_dados_empresa varchar2(255) := null;
   vv_cod_mod      mod_fiscal.cod_mod%type;
   vv_ecf_mod      equip_ecf.ecf_mod%type;
   vv_ecf_fab      equip_ecf.ecf_fab%type;
   vn_ecf_cx       equip_ecf.ecf_cx%type;
   --
   cursor c_cf is
   select r.*
        , mf.cod_mod
        , ee.empresa_id
        , ee.ecf_mod
        , ee.ecf_fab
        , ee.ecf_cx
     from reducao_z_ecf  r
        , equip_ecf      ee
        , mod_fiscal     mf
        , empresa        e
    where r.dm_st_proc   = 2 -- erros de validação
      and trunc(r.dt_doc) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
      and ee.id          = r.equipecf_id
      and ( en_dm_tipo not in (1) or (ee.empresa_id = en_empresa_id) )
      and mf.id          = ee.modfiscal_id
      and e.id           = ee.empresa_id
      and e.multorg_Id   = en_multorg_id
    order by r.id;
   --
   cursor c_log ( en_referencia_id in log_generico_cf.id%type ) is
   select lgc.*
     from log_generico_cf  lgc
        , csf_tipo_log  tl
    where lgc.referencia_id     = en_referencia_id
      and lgc.obj_referencia    = 'REDUCAO_Z_ECF'
      and tl.id                 = lgc.csftipolog_id
      and tl.cd_compat          in ('1','2')
    order by lgc.id;
   --
   -- Log de fechamento fiscal
   cursor c_fecha_fiscal(en_empresa_id in number, ev_info_fechamento in varchar2) is
      select lg.*
        from log_generico_cf lg
           , csf_tipo_log    tl
       where lg.empresa_id       = en_empresa_id
         and lg.referencia_id    is null
         and lg.obj_referencia   = 'REDUCAO_Z_ECF'
         and tl.id               = lg.csftipolog_id
         and tl.id               in(ev_info_fechamento)
         and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
         and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
       order by lg.id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_cf loop
      exit when c_cf%notfound or (c_cf%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Informações de logs da Redução Z do ECF - C405/D355'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;MOD_FISCAL;ECF_MOD;ECF_FAB;ECF_CX;DT_DOC;CRO;CRZ;NUM_COO_FIN;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || rec.cod_mod || ';'
                     || rec.ecf_mod || ';'
                     || rec.ecf_fab || ';'
                     || rec.ecf_cx || ';'
                     || to_char(rec.DT_DOC, 'dd/mm/rrrr') || ';'
                     || rec.CRO || ';'
                     || rec.CRZ || ';'
                     || rec.NUM_COO_FIN || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   --Fechamento fiscal
   for rec in c_fecha_fiscal(en_empresa_id => en_empresa_id, ev_info_fechamento => info_fechamento) loop
      exit when c_fecha_fiscal%notfound or (c_fecha_fiscal%notfound) is null;
      --
      vv_dados_empresa :=  pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => en_empresa_id);
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'Informações de logs da Redução Z do ECF - C405/D355'
                                       );
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'EMPRESA;MOD_FISCAL;ECF_MOD;ECF_FAB;ECF_CX;DT_DOC;CRO;CRZ;NUM_COO_FIN;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vl_texto := null;
      vl_texto := vv_dados_empresa
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo)
               || ';';
      --
      vn_fase := 6;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_cupom_fiscal ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_cupom_fiscal;
------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro de inventário
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_invent ( en_agendintegr_id  in agend_integr.id%type
                               , en_objintegr_id    in obj_integr.id%type
                               , en_usuario_id      in neo_usuario.id%type
                               , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                               , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                               , en_empresa_id      in empresa.id%type
                               , en_dm_tipo         in agend_integr.dm_tipo%type
                               , en_multorg_id      in mult_org.id%type
                               , ed_dt_agend        in agend_integr.dt_agend%type
                               , ed_dt_termino      in item_agend_integr.dt_termino%type
                               )
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   vn_first_reg   number := 0;
   --
   vv_dados_empresa varchar2(255) := null;
   vv_cod_item      item.cod_item%type;
   vv_descr_item    item.descr_item%type;
   vv_sigla_unid    unidade.sigla_unid%type;
   --
   cursor c_inv is
   select i.*
     from empresa e
        , inventario i
    where e.multorg_id = en_multorg_id
      and i.empresa_id = e.id
      and i.dm_st_proc = 2 -- erros de validação
      and ( en_dm_tipo not in (1) or (i.empresa_id = en_empresa_id) )
      and trunc(i.dt_ref) between trunc(ed_dt_ini_integr) and trunc(ed_dt_fin_integr)
    order by i.id;
   --
   cursor c_log ( en_referencia_id in log_generico_inv.id%type ) is
   select lgi.*
     from log_generico_inv  lgi
        , csf_tipo_log  tl
    where lgi.referencia_id    = en_referencia_id
      and lgi.obj_referencia   = 'INVENTARIO'
      and tl.id                = lgi.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by lgi.id;
   --
   cursor c_log_inv(ev_info_fechamento in varchar2) is
    select *
      from ( select lgi.*
               from log_generico_inv  lgi
                  , csf_tipo_log  tl
              where lgi.referencia_id    is null
                and lgi.obj_referencia   = 'INVENTARIO'
                and tl.id                = lgi.csftipolog_id
                and tl.cd_compat         in ('1','2')
                and trunc(lgi.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
                and trunc(lgi.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
              union
              select lgi.*
               from log_generico_inv  lgi
                  , csf_tipo_log  tl
              where lgi.referencia_id    is null
                and lgi.obj_referencia   = 'INVENTARIO'
                and tl.id                = lgi.csftipolog_id
                and tl.id                in (ev_info_fechamento)
                and trunc(lgi.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
                and trunc(lgi.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
                )
    order by id;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_inv loop
      exit when c_inv%notfound or (c_inv%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.1;
      -- recupera dados do produto
      begin
         --
         select i.cod_item
              , i.descr_item
           into vv_cod_item
              , vv_descr_item
           from item i
          where i.id = rec.item_id;
         --
      exception
         when others then
            vv_cod_item := null;
            vv_descr_item := null;
      end;
      --
      vn_fase := 3.2;
      --
      vv_sigla_unid := pk_csf.fkg_Unidade_sigla ( en_unidade_id => rec.unidade_id );
      --
      vn_fase := 3.3;
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Informações dos logs do inventario de itens'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;CODIGO;DESCRICAO;UNIDADE;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || vv_cod_item || ';'
                     || vv_descr_item || ';'
                     || vv_sigla_unid || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 5;
   --
   -- Executa esse processo quando não existe um inventário
   for rec3 in c_log_inv(ev_info_fechamento => info_fechamento) loop
         exit when c_log_inv%notfound or (c_log_inv%notfound) is null;
         --
         vn_fase := 5.1;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Informações dos logs do inventario de itens'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;CODIGO;DESCRICAO;UNIDADE;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         -- recupera dados da empresa
         vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => en_empresa_id );
         --
         vn_fase := 5.2;
         --
         vl_texto := vv_dados_empresa || ';'  -- Dados da empresa
                  || ''               || ';'  -- Código do item
                  || ''               || ';'  -- Descrição do item
                  || ''               || ';'  -- Unidade do item
                  || pk_csf.fkg_converte(rec3.resumo) || ';'; -- Resumo do log_generico
         --
         vn_fase := 5.3;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_invent ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_invent;
------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro de cadastros gerais
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_cad_geral ( en_agendintegr_id  in agend_integr.id%type
                                  , en_objintegr_id    in obj_integr.id%type
                                  , en_usuario_id      in neo_usuario.id%type
                                  , ed_dt_agend        in agend_integr.dt_agend%type
                                  , ed_dt_termino      in item_agend_integr.dt_termino%type
                                  , en_multorg_id      in mult_org.id%type
                                  )
is
   --
   vn_fase        number := 0;
   vl_texto       impr_erro_agend_integr.texto%type;
   vn_first_reg   number := 0;
   vn_first_title number := 0;
   --
   vv_dados_empresa      varchar2(255) := null;
   --
   cursor c_pessoa is
   select p.cod_part
        , p.nome
        , lgc.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from pessoa        p
        , log_generico_cad  lgc
        , csf_tipo_log  tl
    where p.multorg_id         = en_multorg_id
      and p.id                 = lgc.referencia_id
      and lgc.obj_referencia   = 'PESSOA'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by p.cod_part;
   --
   cursor c_unid is
   select lgc.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from unidade       u
        , log_generico_cad  lgc
        , csf_tipo_log  tl
    where u.multorg_id         = en_multorg_id
      and u.id                 = lgc.referencia_id
      and lgc.obj_referencia   = 'UNIDADE'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by u.sigla_unid;
   --
   cursor c_item is
   select i.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from item              i
        , log_generico_cad  lgc
    where i.id                 = lgc.referencia_id
      and lgc.obj_referencia   = 'ITEM'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and exists ( select *
                     from csf_tipo_log tl
                    where tl.cd_compat      in ('1','2')
                      and lgc.csftipolog_id = tl.id )
      and exists ( select 1
                     from empresa e
                    where e.multorg_id = en_multorg_id
                      and i.empresa_id = e.id )
    order by i.cod_item;
   --
   cursor c_log_item is
   select lgc.resumo
        , lgc.mensagem
     from log_generico_cad  lgc
    where 1 = 1
      and lgc.obj_referencia    = 'ITEM'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists ( select 1
                         from item i
                        where i.id = lgc.referencia_id )
      and exists ( select 1
                     from empresa e
                    where e.multorg_id = en_multorg_id
                      and lgc.empresa_id = e.id )
      and exists ( select 1
                     from csf_tipo_log  tl
                    where tl.cd_compat      in ('1','2')
                      and lgc.csftipolog_id = tl.id )
    order by 1;
   --
   cursor c_bem is
   select bai.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from bem_ativo_imob  bai
        , log_generico_cad    lgc
        , csf_tipo_log  tl
        , empresa e
    where bai.empresa_id       = e.id
      and e.multorg_id         = en_multorg_id
      and lgc.referencia_id    = bai.id
      and lgc.obj_referencia   = 'BEM_ATIVO_IMOB'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by bai.cod_ind_bem;
   --
   cursor c_log_bem is
   select lgc.resumo
        , lgc.mensagem
     from log_generico_cad  lgc
        , csf_tipo_log      tl
        , empresa           e
    where lgc.empresa_id       = e.id
      and e.multorg_id         = en_multorg_id
      and lgc.obj_referencia   = 'BEM_ATIVO_IMOB'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
      and not exists (select bai.id
                        from bem_ativo_imob bai
                       where bai.id = lgc.referencia_id)
    order by 1;
   --
   cursor c_natoper is
   select no.cod_nat
        , no.descr_nat
        , lgc.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from nat_oper        no
        , log_generico_cad    lgc
        , csf_tipo_log  tl
    where no.multorg_id        = en_multorg_id
      and no.id                = lgc.referencia_id
      and lgc.obj_referencia   = 'NAT_OPER'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by no.cod_nat;
   --
   cursor c_infor is
   select icdf.cod_infor
        , icdf.txt
        , lgc.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from infor_comp_dcto_fiscal        icdf
        , log_generico_cad    lgc
        , csf_tipo_log  tl
    where icdf.multorg_id      = en_multorg_id
      and icdf.id              = lgc.referencia_id
      and lgc.obj_referencia   = 'INFOR_COMP_DCTO_FISCAL'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by icdf.cod_infor;
   --
   cursor c_obs_fiscal is
   select olf.cod_obs
        , olf.txt
        , lgc.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from obs_lancto_fiscal        olf
        , log_generico_cad    lgc
        , csf_tipo_log  tl
    where olf.multorg_id       = en_multorg_id
      and olf.id               = lgc.referencia_id
      and lgc.obj_referencia   = 'OBS_LANCTO_FISCAL'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by olf.cod_obs;
   --
   cursor c_pc is
   select pc.cod_cta
        , pc.descr_cta
        , pc.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from plano_conta       pc
        , log_generico_cad  lgc
    where pc.id                 = lgc.referencia_id
      and lgc.obj_referencia    = 'PLANO_CONTA'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and exists ( select 1
                     from empresa e
                    where e.multorg_id  = en_multorg_id
                      and pc.empresa_id = e.id )
      and exists ( select 1
                     from csf_tipo_log  tl
                    where tl.cd_compat      in ('1','2')
                      and lgc.csftipolog_id = tl.id )
    order by pc.cod_cta;
   --
   cursor c_log_pc is
   select lgc.resumo
        , lgc.mensagem
        , lgc.empresa_id
     from log_generico_cad    lgc
    where (lgc.referencia_id is null or lgc.referencia_id not in (select id
                                                                    from plano_conta))
      and lgc.obj_referencia    = 'PLANO_CONTA'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and exists ( select 1
                     from empresa e
                    where e.multorg_id = en_multorg_id
                      and lgc.empresa_id = e.id )
      and exists ( select 1
                     from csf_tipo_log  tl
                    where tl.cd_compat      in ('1','2')
                      and lgc.csftipolog_id = tl.id )
    order by 1;
   --
   cursor c_cc is
   select cc.cod_ccus
        , cc.descr_ccus
        , lgc.resumo
        , lgc.mensagem
        , lgc.empresa_id
     from centro_custo    cc
        , log_generico_cad    lgc
        , csf_tipo_log  tl
        , empresa e
    where cc.empresa_id        = e.id
      and e.multorg_id         = en_multorg_id
      and cc.id                = lgc.referencia_id
      and lgc.obj_referencia   = 'CENTRO_CUSTO'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by cc.cod_ccus;
   --
   cursor c_hist is
   select hp.cod_hist
        , hp.descr_hist
        , hp.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from hist_padrao       hp
        , log_generico_cad  lgc
    where hp.id                = lgc.referencia_id
      and lgc.obj_referencia   = 'HIST_PADRAO'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and exists ( select 1
                     from empresa e
                    where e.multorg_id  = en_multorg_id
                      and hp.empresa_id = e.id )
      and exists ( select 1
                     from csf_tipo_log  tl
                    where tl.cd_compat      in ('1','2')
                      and lgc.csftipolog_id = tl.id )
    order by hp.cod_hist;
   --
   cursor c_aglut is
   select ac.cod_agl
        , ac.descr_agl
        , ac.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from aglut_contabil     ac
        , log_generico_cad   lgc
        , csf_tipo_log       tl
        , empresa e
    where ac.empresa_id        = e.id
      and e.multorg_id         = en_multorg_id
      and ac.id                = lgc.referencia_id
      and lgc.obj_referencia   = 'AGLUT_CONTABIL'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by ac.cod_agl;
   --
   cursor c_log_agl is
   select lgc.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from log_generico_cad    lgc
        , csf_tipo_log        tl
        , empresa             e
    where lgc.empresa_id       = e.id
      and e.multorg_id         = en_multorg_id
      and (lgc.referencia_id   is null or lgc.referencia_id not in (select id
                                                                     from aglut_contabil))
      and lgc.obj_referencia   = 'AGLUT_CONTABIL'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by 1;
   --
   cursor c_fci is
   select afa.nro_sequencia
        , af.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from abertura_fci     af
        , abertura_fci_arq afa
        , log_generico_cad    lgc
        , csf_tipo_log  tl
        , empresa e
    where af.empresa_id        = e.id
      and e.multorg_id         = en_multorg_id
      and af.id                = lgc.referencia_id
      and lgc.obj_referencia   = 'ABERTURA_FCI'
      and af.id                = afa.aberturafci_id
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by afa.nro_sequencia;
   --
   cursor c_log_fci is
   select lgc.empresa_id
        , lgc.resumo
        , lgc.mensagem
     from log_generico_cad    lgc
        , csf_tipo_log  tl
        , empresa e
    where lgc.empresa_id       = e.id
      and e.multorg_id         = en_multorg_id
      and (lgc.referencia_id is null or lgc.referencia_id not in (select id
                                                                    from abertura_fci))
      and lgc.obj_referencia   = 'ABERTURA_FCI'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                = lgc.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by 1;
   --
   cursor c_log_dipam is
   select lgc.empresa_id
        , lgc.resumo
        , lgc.dt_hr_log
        , lgc.mensagem
     from log_generico_cad    lgc
        , csf_tipo_log  tl
        , empresa e
    where lgc.empresa_id       = e.id
      and e.multorg_id         = en_multorg_id
      and (lgc.referencia_id is null or lgc.referencia_id not in (select id
                                                                    from param_dipamgia))
      and lgc.obj_referencia    = 'PARAM_DIPAMGIA'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                 = lgc.csftipolog_id
      and tl.cd_compat          in ('1','2')
    order by 1;
   --
   cursor c_log_reinf is
   select lgc.empresa_id
        , lgc.resumo
        , lgc.dt_hr_log
        , lgc.mensagem
     from log_generico_cad    lgc
        , csf_tipo_log  tl
        , empresa e
    where lgc.empresa_id       = e.id
      and e.multorg_id         = en_multorg_id
      and (lgc.referencia_id is null or lgc.referencia_id not in (select id
                                                                    from proc_adm_efd_reinf))
      and lgc.obj_referencia    = 'PROC_ADM_EFD_REINF'
      and trunc(lgc.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgc.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                 = lgc.csftipolog_id
      and tl.cd_compat          in ('1','2')
    order by 1;
   --
   procedure pkb_identificacao_reg ( el_texto in impr_erro_agend_integr.texto%type ) is
   begin
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => el_texto
                                    );
      --
   exception
     when others then
        null;
   end pkb_identificacao_reg;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 0;
   vn_first_title := 0;
   --
   -- Fazendo o titulo e cabeçalho do relatório.
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'Relatório de Erro - Objeto de Integração Cadastro Gerais.'
                                 );
   --
   vn_fase := 1.2;
   --
   -- Montando o cabeçalho generico.
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'MODULO;EMPRESA;DATA;RESUMO;MENSAGEM'
                                 );
   --
   --
   -- monta os erros de pessoa
   for rec in c_pessoa loop
      exit when c_pessoa%notfound or (c_pessoa%notfound) is null;
      --
      vn_fase := 2.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração da tabela PESSOA');
      end if;
      --
      vn_fase := 2.2;
      --
      if nvl(vn_first_reg,0) = 1 then
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'PESSOA;'
               || vv_dados_empresa || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo) || ';'
               || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 2.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 3;
   -- monta os erros de unidade de medida
   --vn_first_title := 1;
   --
   for rec in c_unid loop
      exit when c_unid%notfound or (c_unid%notfound) is null;
      --
      vn_fase := 3.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração da tabela UNIDADE');
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'UNIDADE;'||
                  vv_dados_empresa || ';'
                  || ';' ||
                  pk_csf.fkg_converte(rec.resumo) || ';' ||
                  pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 3.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 4;
   --vn_first_title := 1;
   --vn_first_reg   := 1;
   -- monta os erros de item (produtos/serviços)
   for rec in c_item loop
      exit when c_item%notfound or (c_item%notfound) is null;
      --
      vn_fase := 4.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração da tabela ITEM');
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'ITEM;' ||
                  vv_dados_empresa || ';' ||
                  ';' ||
                  pk_csf.fkg_converte(rec.resumo) || ';'||
                  pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 4.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 4.3;
   -- monta os erros de item (produtos/serviços)
   for rec in c_log_item loop
      exit when c_log_item%notfound or (c_log_item%notfound) is null;
      --
      vn_fase := 4.4;
      --
      /*
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      */
      --
      vl_texto := 'ITEM;' || ';' ||
                  ';' ||
                  ';' ||
                  pk_csf.fkg_converte(replace(rec.resumo, chr(10), ' ') ) || ';' ||
                  pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 4.5;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 5;
   --vn_first_title := 1;
   --
   -- monta os erros de bem do ativo imobilizado
   for rec in c_bem loop
      exit when c_bem%notfound or (c_bem%notfound) is null;
      --
      vn_fase := 5.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração da tabela BEM_ATIVO_IMOB');
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'BEM_ATIVO_IMOB;' ||
                  vv_dados_empresa || ';'||
                  ';' ||
                  pk_csf.fkg_converte(rec.resumo) || ';' ||
                  pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 5.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 5.3;
   --vn_first_title := 1;
   -- monta os erros de bem do ativo imobilizado sem a geração do bem, somente o log
   for rec in c_log_bem loop
      exit when c_log_bem%notfound or (c_log_bem%notfound) is null;
      --
      vn_fase := 5.4;
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração do bem do ativo imobilizado sem a geração do bem');
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'BEM_ATIVO_IMOB;'  -- Tipo
               || ''      || ';'     -- empresa_id
               || ''      || ';'     -- dt_hr_log
               || pk_csf.fkg_converte(rec.resumo) || ';' -- Resumo do log_generico
               || pk_csf.fkg_converte(rec.mensagem) || ';'; -- Resumo do log_generico

      --
      vn_fase := 5.5;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 6;
   --vn_first_title := 1;
   -- monta os erros de natureza da operacao
   for rec in c_natoper loop
      exit when c_natoper%notfound or (c_natoper%notfound) is null;
      --
      vn_fase := 6.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de natureza da operação');
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'NAT_OPER;'
               || vv_dados_empresa || ';'
               || ';' -- dt_hr_log
               || pk_csf.fkg_converte(rec.resumo) || ';'
               || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 6.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 7;
   --vn_first_title := 1;
   -- monta os erros de informação complementar do documento fiscal
   for rec in c_infor loop
      exit when c_infor%notfound or (c_infor%notfound) is null;
      --
      vn_fase := 7.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de complementar do documento fiscal');
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      --
      vl_texto := 'INFOR_COMP_DCTO_FISCAL;'
               || vv_dados_empresa ||';'
               || '' || ';'
               || pk_csf.fkg_converte(rec.resumo) || ';'
               || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 7.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 8;
   -- vn_first_title := 0;
   -- monta os erros de observação do lançamento fiscal
   for rec in c_obs_fiscal loop
      exit when c_obs_fiscal%notfound or (c_obs_fiscal%notfound) is null;
      --
      vn_fase := 8.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de observação do lançamento fiscal');
         --
         vn_first_title := 0;
         --
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'OBS_LANCTO_FISCAL;'
               || vv_dados_empresa || ';'
               || '' || ';'
               || pk_csf.fkg_converte(rec.resumo) || ';'
               || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 8.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 9;
   --vn_first_title := 1;
   --vn_first_reg   := 1;
   -- monta os erros de plano de contas
   for rec in c_pc loop
      exit when c_pc%notfound or (c_pc%notfound) is null;
      --
      vn_fase := 9.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de plano de conta');
         --
         vn_first_title := 0;
         --
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'PLANO_CONTA;'
                || vv_dados_empresa|| ';'
                || ';'
                || pk_csf.fkg_converte(rec.resumo) || ';'
                || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 9.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 10;
   --vn_first_title := 1;
   --vn_first_reg   := 1;
   -- Executa esse processo quando não existe um plano de conta integrado
   for r_reg in c_log_pc
   loop
      --
      exit when c_log_pc%notfound or (c_log_pc%notfound) is null;
      --
      vn_fase := 10.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_reg.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de plano de conta');
         --
         vn_first_title := 0;
         --
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'PLANO_CONTA;'  -- Tipo
               || vv_dados_empresa || ';'  -- Código da conta
               || ''      || ';'  -- Descrição da conta
               || pk_csf.fkg_converte(r_reg.resumo) || ';' -- Resumo do log_generico
               || pk_csf.fkg_converte(r_reg.mensagem) || ';'; -- Resumo do log_generico
      --
      vn_fase := 10.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 11;
   --vn_first_title := 1;
   -- monta os erros de centro de custo
   for rec in c_cc loop
      exit when c_cc%notfound or (c_cc%notfound) is null;
      --
      vn_fase := 11.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de centro de custo');
         --
         vn_first_title := 0;
         --
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'CENTRO_CUSTO;'
                || vv_dados_empresa ||';'
                || ';'
                || pk_csf.fkg_converte(rec.resumo) || ';'
                || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 11.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 12;
   --vn_first_title := 1;
   -- monta os erros de história padrão
   for rec in c_hist loop
      exit when c_hist%notfound or (c_hist%notfound) is null;
      --
      vn_fase := 12.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de observação do lançamento fiscal');
         --
         vn_first_title := 0;
         --
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'HIST_PADRAO;'
               || vv_dados_empresa || ';'
               || ';'
               || pk_csf.fkg_converte(rec.resumo) || ';'
               || pk_csf.fkg_converte(rec.resumo) || ';';
      --
      vn_fase := 12.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 13;
   --vn_first_title := 1;
   --
   for rec in c_aglut loop
    exit when c_aglut%notfound or (c_aglut%notfound) is null;
      --
      vn_fase := 13.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de aglutinação contabil');
         --
         vn_first_title := 0;
         --
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'AGLUT_CONTABIL;'
                || vv_dados_empresa
                || ';'
                || pk_csf.fkg_converte(rec.resumo) || ';'
                || pk_csf.fkg_converte(rec.mensagem) || ';';
      --
      vn_fase := 13.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   -- Executa esse processo quando não existe uma aglutinação integrado
   for r_reg in c_log_agl
   loop
      --
      exit when c_log_agl%notfound or (c_log_agl%notfound) is null;
      --
      vn_fase := 13.3;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_reg.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de aglutinação contabil');
         --
         vn_first_title := 0;
         --
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;CODIGO;DESCRICAO;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'AGLUT_CONTABIL;'  -- Tipo
               || vv_dados_empresa || ';'  -- Código da conta
               || ''      || ';'  -- Descrição da conta
               || pk_csf.fkg_converte(r_reg.resumo) || ';'
               || pk_csf.fkg_converte(r_reg.mensagem) || ';'; -- Resumo do log_generico
      --
      vn_fase := 13.4;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   --vn_first_reg := 1;
   --vn_first_title := 1;
   --
   for rec in c_fci loop
    exit when c_fci%notfound or (c_aglut%notfound) is null;
      --
      vn_fase := 14.1;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      /*
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de legado do FCI');
         --
         vn_first_title := 0;
         --
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;NRO_SEQUENCIA;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      */
      --
      vl_texto := 'ABERTURA_FCI;'
               || vv_dados_empresa
               || ';'
               || pk_csf.fkg_converte(rec.resumo) ||';'
               || pk_csf.fkg_converte(rec.mensagem) ||';';
      --
      vn_fase := 14.2;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   for r_reg in c_log_fci
   loop
      --
      exit when c_log_fci%notfound or (c_log_fci%notfound) is null;
      --
      vn_fase := 14.3;
      --
      if nvl(vn_first_title,0) = 1 then
         --
         pkb_identificacao_reg ( el_texto => 'Informações de logs da integração de legado do FCI');
         --
         vn_first_title := 0;
         --
      end if;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => 'TIPO;NRO_SEQUENCIA;RESUMO;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vl_texto := 'ABERTURA_FCI;'  -- Tipo
               || ''      || ';'  -- Código da conta
               || ''      || ';'  -- Descrição da conta
               || pk_csf.fkg_converte(r_reg.resumo) || ';'; -- Resumo do log_generico
      --
      vn_fase := 14.4;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 15;
   --
   for r_reg in c_log_dipam
   loop
      --
      exit when c_log_dipam%notfound or (c_log_dipam%notfound) is null;
      --MODULO;EMPRESA;DATA;RESUMO;MENSAGEM
      --
      vl_texto := 'PARAM_DIPAMGIA;'  -- Tipo
               || pk_csf.fkg_nome_empresa ( en_empresa_id => r_reg.empresa_id)     || ';'  -- Código da conta
               || to_date(r_reg.DT_HR_LOG, 'dd/mm/yyyy')  || ';'  -- Descrição da conta
               || pk_csf.fkg_converte(r_reg.resumo) || ';' -- Resumo do log_generico
               || pk_csf.fkg_converte(r_reg.mensagem) || ';'; -- Resumo do log_generico
      --
      vn_fase := 15.4;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 16;
   --
   for r_reg in c_log_reinf
   loop
      --
      exit when c_log_reinf%notfound or (c_log_reinf%notfound) is null;
      --MODULO;EMPRESA;DATA;RESUMO;MENSAGEM
      --
      vl_texto := 'PROC_ADM_EFD_REINF;'  -- Tipo
               || pk_csf.fkg_nome_empresa ( en_empresa_id => r_reg.empresa_id)     || ';'  -- Código da conta
               || to_date(r_reg.DT_HR_LOG, 'dd/mm/yyyy')  || ';'  -- Descrição da conta
               || pk_csf.fkg_converte(r_reg.resumo) || ';' -- Resumo do log_generico
               || pk_csf.fkg_converte(r_reg.mensagem) || ';'; -- Resumo do log_generico
      --
      vn_fase := 15.4;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_cad_geral ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_cad_geral;

------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro do EFD-REINF
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_reinf ( en_agendintegr_id in agend_integr.id%type
                              , en_objintegr_id   in obj_integr.id%type
                              , en_usuario_id     in neo_usuario.id%type
                              , ed_dt_ini_integr  in agend_integr.dt_ini_integr%type
                              , ed_dt_fin_integr  in agend_integr.dt_fin_integr%type
                              , ed_dt_agend       in agend_integr.dt_agend%type
                              , ed_dt_termino     in item_agend_integr.dt_termino%type
                              , en_empresa_id     in empresa.id%type
                              , en_dm_tipo        in agend_integr.dm_tipo%type
                              , en_multorg_id     in mult_org.id%type
                              )
is
   --
   vn_fase      number := 0;
   vl_texto     impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg number := 0;
   --
   -- Recursos Recebidos
   cursor c_rreceb is
   select em.id empresa_id
        , rr.id recrecebassdesp_id
        , rr.dt_ref
        , rr.pessoa_id_orig
     from empresa            em
        , rec_receb_ass_desp rr
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and rr.empresa_id = em.id
      and rr.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and rr.dt_ref  between ed_dt_ini_integr and ed_dt_fin_integr
    order by rr.dt_ref;
   --
   -- Recursos Repassados
   cursor c_rrep is
   select em.id empresa_id
        , rr.id recrepassdesp_id
        , rr.dt_ref
        , rr.pessoa_id_desp
     from empresa            em
        , rec_rep_ass_desp rr
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and rr.empresa_id = em.id
      and rr.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and rr.dt_ref  between ed_dt_ini_integr and ed_dt_fin_integr
    order by rr.dt_ref;
   --
   -- Comercialização de produtor Rural
   cursor c_comer is
   select em.id empresa_id
        , cp.id comerprodruralpjagr_id
        , cp.dt_ref
     from empresa            em
        , comer_prod_rural_pj_agr cp
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and cp.empresa_id = em.id
      and cp.dm_st_proc = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and cp.dt_ref  between ed_dt_ini_integr and ed_dt_fin_integr
    order by cp.dt_ref;
   --
   -- Recursos de Espetáculo Desportivo
   cursor c_rec is
   select em.id empresa_id
        , rc.id recespdesport_id
        , rc.dt_ref
     from empresa            em
        , rec_esp_desport rc
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and rc.empresa_id = em.id
      and rc.dm_situacao = 2 -- 0-Não validada, 1-Validada, 2-Erro de validação
      and rc.dt_ref  between ed_dt_ini_integr and ed_dt_fin_integr
    order by rc.dt_ref;
   --
   -- Parametros de itens x Classificações de Tipos de Serviços
   cursor c_emp is
   select em.id empresa_id
        , ei.id empritemtpservreinf_id
        , ei.tiposervreinf_id
     from empresa            em
        , empr_item_tpservreinf ei
    where em.multorg_id = en_multorg_id
      and (en_dm_tipo not in (1)
           or
          (em.id = en_empresa_id) )
      and ei.empresa_id = em.id;
   --
   cursor c_log( en_referencia_id  in number
               , ev_obj_referencia in varchar2 ) is
   select lg.resumo
        , lg.mensagem
     from log_generico_reinf lg
    where lg.referencia_id  = en_referencia_id
      and lg.obj_referencia = ev_obj_referencia;
   --
   cursor c_log_reinf is
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_reinf lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'REC_RECEB_ASS_DESP' -- Bloco R-2030
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from rec_receb_ass_desp cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_reinf lg
        , csf_tipo_log     tl
    where lg.obj_referencia   = 'REC_REP_ASS_DESP' -- Bloco R-2040
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from rec_rep_ass_desp cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_reinf lg
        , csf_tipo_log       tl
    where lg.obj_referencia   = 'COMER_PROD_RURAL_PJ_AGR' -- Bloco R-2050
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from comer_prod_rural_pj_agr cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_reinf lg
        , csf_tipo_log       tl
    where lg.obj_referencia   = 'REC_ESP_DESPORT' -- Bloco R-3010
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from rec_esp_desport cd
                       where cd.id = nvl(lg.referencia_id,0))
   union
   select lg.obj_referencia tipo
        , lg.dt_hr_log
        , lg.resumo
        , lg.mensagem
     from log_generico_reinf lg
        , csf_tipo_log       tl
    where lg.obj_referencia   = 'EMPR_ITEM_TPSERVREINF' -- Bloco R-3010
      and tl.id               = lg.csftipolog_id
      and tl.cd_compat       in ('1','2')
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and not exists (select cd.id
                        from empr_item_tpservreinf cd
                       where cd.id = nvl(lg.referencia_id,0));
   --
begin
   --
   vn_fase := 1;
   -- Fazendo o titulo e cabeçalho do relatório.
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'Escrituração Fiscal Digital de Retenções e Outras Informações Fiscais EFD-REINF.'
                                 );
   --
   vn_fase := 1.2;
   --
   -- Montando o cabeçalho generico.
   pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'MODULO;EMPRESA;DATA;RESUMO;MENSAGEM'
                                 );
   --
   vn_fase := 2;
   --
   for r_rreceb in c_rreceb
   loop
      --
      exit when c_rreceb%notfound or (c_rreceb%notfound) is null;
      --
      vn_fase := 2;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_rreceb.empresa_id );
      --
      vn_fase := 3;
      --
      for r_log in c_log( en_referencia_id  => r_rreceb.recrecebassdesp_id
                        , ev_obj_referencia => 'REC_RECEB_ASS_DESP' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         vl_texto := 'Integração de Recursos Recebidos por Associação Desportiva - R2030;'||
                     vv_dados_empresa||';'||
                     r_rreceb.dt_ref||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 7;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 8;
   --
   for r_rrep in c_rrep
   loop
      --
      exit when c_rrep%notfound or (c_rrep%notfound) is null;
      --
      vn_fase := 9;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_rrep.empresa_id );
      --
      vn_fase := 10;
      --
      for r_log in c_log( en_referencia_id  => r_rrep.recrepassdesp_id
                        , ev_obj_referencia => 'REC_REP_ASS_DESP' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 11;
         --
         vl_texto := 'Integração de Recursos Repassados para Associação Desportiva - R2040;'||
                     vv_dados_empresa||';'||
                     r_rrep.dt_ref||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 12;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 13;
   --
   for r_comer in c_comer
   loop
      --
      exit when c_comer%notfound or (c_comer%notfound) is null;
      --
      vn_fase := 14;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_comer.empresa_id );
      --
      vn_fase := 15;
      --
      for r_log in c_log( en_referencia_id  => r_comer.comerprodruralpjagr_id
                        , ev_obj_referencia => 'COMER_PROD_RURAL_PJ_AGR' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 16;
         --
         vl_texto := 'Comercialização da Produção por Produtor Rural PJ/Agroindústria - R2050;'||
                     vv_dados_empresa||';'||
                     r_comer.dt_ref||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 17;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 18;
   --
   for r_rec in c_rec
   loop
      --
      exit when c_rec%notfound or (c_rec%notfound) is null;
      --
      vn_fase := 14;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_rec.empresa_id );
      --
      vn_fase := 15;
      --
      for r_log in c_log( en_referencia_id  => r_rec.recespdesport_id
                        , ev_obj_referencia => 'REC_ESP_DESPORT' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 16;
         --
         vl_texto := 'Comercialização da Produção por Produtor Rural PJ/Agroindústria - R2050;'||
                     vv_dados_empresa||';'||
                     r_rec.dt_ref||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 17;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 18;
   -- c_emp
   for r_emp in c_emp
   loop
      --
      exit when c_emp%notfound or (c_emp%notfound) is null;
      --
      vn_fase := 19;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => r_emp.empresa_id );
      --
      vn_fase := 15;
      --
      for r_log in c_log( en_referencia_id  => r_emp.empritemtpservreinf_id
                        , ev_obj_referencia => 'EMPR_ITEM_TPSERVREINF' )
      loop
         --
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 16;
         --
         vl_texto := 'Parâmetros de Itens x Classificação do Tipo de Serviços;'||
                     vv_dados_empresa||';'||
                     null||';'||
                     pk_csf.fkg_converte(r_log.resumo)||';'||
                     pk_csf.fkg_converte(r_log.mensagem)||';';
         --
         vn_fase := 17;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   for rec in c_log_reinf
   loop
     exit when c_log_reinf%notfound or (c_log_reinf%notfound) is null;
      --
      if nvl(vn_first_reg,0) = 1 then
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;REFERENCIA_ID;DT_HR_LOG;RESUMO;MENSAGEM;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vl_texto := rec.tipo||';'||
                  ';'|| --referencia_id null;
                  --r_log_ddo.tipo||';'||
                  to_char(rec.dt_hr_log,'dd/mm/rrrr') ||';'||
                  pk_csf.fkg_converte(rec.resumo)     ||';'||
                  pk_csf.fkg_converte(rec.mensagem)   ||';';
      --
      vn_fase := 75;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , el_texto          => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_reinf ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_reinf;

------------------------------------------------------------------------------------------
-- procedimento para geração dos dados de erro de informação de exportação
------------------------------------------------------------------------------------------
procedure pkb_monta_rel_infoexp ( en_agendintegr_id  in agend_integr.id%type
                                , en_objintegr_id    in obj_integr.id%type
                                , en_usuario_id      in neo_usuario.id%type
                                , ed_dt_agend        in agend_integr.dt_agend%type
                                , ed_dt_termino      in item_agend_integr.dt_termino%type
                                , en_multorg_id      in mult_org.id%type
                                )
is
   --
   vn_fase      number := 0;
   vl_texto     impr_erro_agend_integr.texto%type;
   --
   vv_dados_empresa varchar2(255) := null;
   vn_first_reg number := 0;
   --
   cursor c_infoexp is
   select ie.*
     from infor_exportacao ie
        , empresa e
    where ie.dm_st_proc  = 2
      and ie.empresa_id = e.id
      and e.multorg_id  = en_multorg_id
    order by ie.id;
   --
   cursor c_log ( en_referencia_id in log_generico.id%type ) is
   select lg.*
     from log_generico_ie lg
        , csf_tipo_log    tl
    where lg.referencia_id     =  en_referencia_id
      and lg.obj_referencia    =  'INFOR_EXPORTACAO'
      and trunc(lg.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lg.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and tl.id                =  lg.csftipolog_id
      and tl.cd_compat         in ('1','2')
    order by lg.id;
   --
begin
   --
   vn_fase      := 1;
   vn_first_reg := 1;
   --
   for rec in c_infoexp loop
      exit when c_infoexp%notfound or (c_infoexp%notfound) is null;
      --
      vn_fase := 3;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      for rec2 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         vn_fase := 4;
         --
         if nvl(vn_first_reg,0) = 1 then
            -- monta a identificação dos títulos
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'Logs de Erros de informação de exportação.'
                                          );
            --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                          , en_objintegr_id    => en_objintegr_id
                                          , en_usuario_id      => en_usuario_id
                                          , el_texto           => 'EMPRESA;DM_IND_DOC;NRO_DE;DT_DE;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vl_texto := vv_dados_empresa || ';'
                     || rec.dm_ind_doc || ';'
                     || rec.nro_de || ';'
                     || rec.dt_de || ';'
                     || pk_csf.fkg_converte(rec2.resumo) || ';';
         --
         vn_fase := 4.1;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_rel_infoexp ('||vn_fase||'): '||sqlerrm);
end pkb_monta_rel_infoexp;
--
------------------------------------------------------------------------------------------------------------
-- Procedimento para geração dos dados de erro de Demais Documentos e Operações - Bloco M EFD Contribuições
------------------------------------------------------------------------------------------------------------
--#76133 inclusao da proc nova
procedure pkb_monta_bloco_m_pc ( en_agendintegr_id  in agend_integr.id%type
                               , en_objintegr_id    in obj_integr.id%type
                               , en_usuario_id      in neo_usuario.id%type
                               , ed_dt_ini_integr   in agend_integr.dt_ini_integr%type
                               , ed_dt_fin_integr   in agend_integr.dt_fin_integr%type
                               , en_empresa_id      in empresa.id%type
                               , en_dm_tipo         in agend_integr.dm_tipo%type
                               , en_multorg_id      in mult_org.id%type
                               , ed_dt_agend        in agend_integr.dt_agend%type
                               , ed_dt_termino      in item_agend_integr.dt_termino%type
                               )                               
is
   --
   vn_fase    number := 0;
   vl_texto   impr_erro_agend_integr.texto%type;
   vn_first_reg    number := null;
   --
   vv_dados_empresa varchar2(255) := null;
   vv_cod_part      pessoa.cod_part%type;
   --
   -- cursor da integracao da pkb_inf_adic_dif_pc;
   cursor c_inf_adic_dif_pc is
    select iadp.id       id_inf
          ,pp.empresa_id
          ,dp.id         id_det
          ,cp.id         id_conscontr_pc
          ,'PIS'         tipo
          ,iadp.Cnpj     COD_PART
          ,PP.DT_INI
          ,PP.DT_FIN
      from per_cons_contr_pis pp
         , cons_contr_pis     cp
         , det_cons_contr_pis dp
         , inf_adic_dif_pis   iadp
         , empresa            em
     where em.multorg_id          = en_multorg_id
       and (en_dm_tipo not in (1) or (em.id = en_empresa_id) )
       and pp.empresa_id          = em.id
       and pp.id                  = cp.perconscontrpis_id
       and cp.id                  = dp.conscontrpis_id
       and pp.empresa_id          = en_empresa_id
       and pp.dt_ini              >= ed_dt_ini_integr
       and pp.dt_fin              <= ed_dt_fin_integr
       and iadp.detconscontrpis_id = dp.id
       and cp.dm_situacao in (2,4)   --Situação: 0-Aberto; 1-Calculada; 2-Erro no cálculo; 3-Processada; 4-Erro de validação
    union
    select iadc.id       id_inf
          ,pc.empresa_id
          ,dc.id         id_det
          ,cc.id         id_conscontr_pc
          ,'COFINS'      tipo
          ,iadc.Cnpj     COD_PART
          ,PC.DT_INI
          ,PC.DT_FIN
      from per_cons_contr_cofins pc
         , cons_contr_cofins     cc
         , det_cons_contr_cofins dc
         , inf_adic_dif_cofins   iadc
         , empresa               em
     where em.multorg_id      = en_multorg_id
       and (en_dm_tipo not in (1) or (em.id = en_empresa_id) )
       and pc.empresa_id      = em.id
       and pc.id              = cc.perconscontrcofins_id
       and cc.id              = dc.conscontrcofins_id
       and pc.empresa_id      = en_empresa_id
       and pc.dt_ini          >= ed_dt_ini_integr
       and pc.dt_fin          <= ed_dt_fin_integr
       and iadc.detconscontrcofins_id = dc.id
       and cc.dm_situacao in (2,4)   --Situação: 0-Aberto; 1-Calculada; 2-Erro no cálculo; 3-Processada; 4-Erro de validação
    order by 1;
   --
   -- cursor da integracao da pkb_contr_pis_dif_per_ant
   cursor c_contr_pis_dif_per_ant is
    select p.id
         , p.empresa_id
         , p.per_apur
      from contr_pis_dif_per_ant p
         , empresa               em
     where em.multorg_id         = en_multorg_id
       and (en_dm_tipo not in (1) or (em.id = en_empresa_id) )
       and p.empresa_id          = em.id
       and p.empresa_id          = en_empresa_id
       and p.dt_ini              >= ed_dt_ini_integr
       and p.dt_fin              <= ed_dt_fin_integr
       and p.dm_situacao         in (2,4)   --Situação: 0-Aberto; 1-Calculada; 2-Erro no cálculo; 3-Processada; 4-Erro de validação
       ;
   -- cursor da integracao da pkb_contr_cofins_dif_per_ant
   cursor c_contr_cofins_dif_per_ant is
    select p.id
         , p.empresa_id
         , p.per_apur
      from contr_COFINS_dif_per_ant p
         , empresa               em
     where em.multorg_id         = en_multorg_id
       and (en_dm_tipo not in (1) or (em.id = en_empresa_id) )
       and p.empresa_id          = em.id
       and p.empresa_id          = en_empresa_id
       and p.dt_ini              >= ed_dt_ini_integr
       and p.dt_fin              <= ed_dt_fin_integr
       and p.dm_situacao         in (2,4)   --Situação: 0-Aberto; 1-Calculada; 2-Erro no cálculo; 3-Processada; 4-Erro de validação
       ;
   -- cursor de log com referencia_id
   cursor c_log ( en_referencia_id in log_generico_ibmpc.id%type ) is
     select distinct lgp.*
       from log_generico_ibmpc lgp
          , csf_tipo_log     tl
      where lgp.referencia_id  = en_referencia_id
        and lgp.obj_referencia = 'INF_BLOCO_M_PC'
        and tl.id              = lgp.csftipolog_id
        and tl.cd_compat      in ('1','2')
        and trunc(lgp.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
        and trunc(lgp.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
        ;
   -- cursor de log com referencia_id mas que nao integrou nas originais
   cursor c_log_ibmpc is
   select distinct lgp.*
     from log_generico_ibmpc lgp
        , csf_tipo_log     tl
    where lgp.obj_referencia    = 'INF_BLOCO_M_PC'
      and tl.id                 = lgp.csftipolog_id
      and tl.cd_compat         in ('1','2')
      and trunc(lgp.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgp.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and lgp.referencia_id   is not null
      and (not exists (select iadp.id
                        from inf_adic_dif_pis iadp
                       where iadp.id = lgp.referencia_id)
           or not exists (select iadc.id
                        from inf_adic_dif_cofins iadc
                       where iadc.id = lgp.referencia_id)
          )
      ;
    -- cursor de log SEM referencia_id
   cursor c_log_ibmpc2 is
   select distinct lgp.empresa_id, to_char(dt_hr_log,'dd/mm/rrrr') dt_hr_log, lgp.resumo, lgp.mensagem
     from log_generico_ibmpc lgp
        , csf_tipo_log     tl
    where lgp.obj_referencia    = 'INF_BLOCO_M_PC'
      and tl.id                 = lgp.csftipolog_id
      and tl.cd_compat         in ('1','2')
      and trunc(lgp.dt_hr_log) >= trunc(to_date(ed_dt_agend,'dd/mm/yyyy'))
      and trunc(lgp.dt_hr_log) <= nvl(trunc(to_date(ed_dt_termino,'dd/mm/yyyy')),trunc(to_date(ed_dt_agend,'dd/mm/yyyy')))
      and lgp.referencia_id is null
      ;
   --
begin
   --
   vn_fase := 1;
   vn_first_reg := 1;
   --
   for rec in c_inf_adic_dif_pc loop
      exit when c_inf_adic_dif_pc%notfound or (c_inf_adic_dif_pc%notfound) is null;
      --
      vn_fase := 1.1;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 1.2;
      --
      for rec2 in c_log(rec.id_inf) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
            --
            --cria o cabecalho
            pkb_armaz_imprerroagendintegr (  en_agendintegr_id => en_agendintegr_id
                                           , en_objintegr_id   => en_objintegr_id
                                           , en_usuario_id     => en_usuario_id
                                           , el_texto          => 'Relatório de Erros de integração de Demais Documentos e Operações - Bloco M EFD Contribuições.'
                                           );
			      --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;CONTRIBUICAO;DATA_HR_LOG;EMPRESA;DATA_INI;DATA_FIN;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 1.3;
         --
         vl_texto := 'INF_BLOCO_M_PC;'
                     || rec.TIPO || ';'
                     || rec2.dt_hr_log || ';'
                     || vv_dados_empresa || ';'
                     || to_char(rec.DT_INI, 'dd/mm/rrrr') || ';'
                     || to_char(rec.DT_FIN, 'dd/mm/rrrr') || ';'
                     || pk_csf.fkg_converte(rec2.resumo)  || ';';
         --
         vn_fase := 1.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 2;
   vn_first_reg := 1;
   --
   for rec in c_contr_pis_dif_per_ant loop
      exit when c_contr_pis_dif_per_ant%notfound or (c_contr_pis_dif_per_ant%notfound) is null;
      --
      vn_fase := 2.1;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 2.2;
      --
      for rec1 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
            --cria o cabecalho
            pkb_armaz_imprerroagendintegr (  en_agendintegr_id => en_agendintegr_id
                                           , en_objintegr_id   => en_objintegr_id
                                           , en_usuario_id     => en_usuario_id
                                           , el_texto          => 'Relatório de Erros de integração de Demais Documentos e Operações - Bloco M EFD Contribuições.'
                                           );
			      --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;CONTRIBUICAO;DATA_HR_LOG;EMPRESA;ID_PER_APUR;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 2.3;
         --
         vl_texto := 'INF_BLOCO_M_PC;'
                     || 'PIS' || ';'
                     || rec1.dt_hr_log || ';'
                     || vv_dados_empresa || ';'
                     || rec.per_apur || ';'
                     || pk_csf.fkg_converte(rec1.resumo)  || ';';
         --
         vn_fase := 2.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 3;
   vn_first_reg := 1;
   --
   for rec in c_contr_cofins_dif_per_ant loop
      exit when c_contr_cofins_dif_per_ant%notfound or (c_contr_cofins_dif_per_ant%notfound) is null;
      --
      vn_fase := 3.1;
      -- recupera dados da empresa
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec.empresa_id );
      --
      vn_fase := 3.2;
      --
      for rec1 in c_log(rec.id) loop
         exit when c_log%notfound or (c_log%notfound) is null;
         --
         if nvl(vn_first_reg,0) = 1 then
            --cria o cabecalho
            pkb_armaz_imprerroagendintegr (  en_agendintegr_id => en_agendintegr_id
                                           , en_objintegr_id   => en_objintegr_id
                                           , en_usuario_id     => en_usuario_id
                                           , el_texto          => 'Relatório de Erros de integração de Demais Documentos e Operações - Bloco M EFD Contribuições.'
                                           );
			      --
            pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                          , en_objintegr_id   => en_objintegr_id
                                          , en_usuario_id     => en_usuario_id
                                          , el_texto          => 'TIPO;CONTRIBUICAO;DATA_HR_LOG;EMPRESA;ID_PER_APUR;RESUMO;'
                                          );
            --
            vn_first_reg := 0;
            --
         end if;
         --
         vn_fase := 3.3;
         --
         vl_texto := 'INF_BLOCO_M_PC;'
                     || 'COFINS' || ';'
                     || rec1.dt_hr_log || ';'
                     || vv_dados_empresa || ';'
                     || rec.per_apur || ';'
                     || pk_csf.fkg_converte(rec1.resumo)  || ';';
         --
         vn_fase := 3.4;
         --
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                       , en_objintegr_id    => en_objintegr_id
                                       , en_usuario_id      => en_usuario_id
                                       , el_texto           => vl_texto
                                       );
         --
      end loop;
      --
   end loop;
   --
   vn_fase := 4;
   vn_first_reg := 1;
   --
   for rec3 in c_log_ibmpc
   loop
      --
      exit when c_log_ibmpc%notfound or (c_log_ibmpc%notfound) is null;
      --
      vn_fase := 4.1;
      --
      if nvl(vn_first_reg,0) = 1 then
         --cria o cabecalho
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'Relatório de Erros de integração de Demais Documentos e Operações - Bloco M EFD Contribuições.'
                                      );
		     --
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;DATA_HR_LOG;RESUMO;MENSAGEM;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 4.2;
      --
      vl_texto := 'INF_BLOCO_M_PC'                     ||';'||
                  to_char(rec3.dt_hr_log,'dd/mm/rrrr') ||';'||
                  pk_csf.fkg_converte(rec3.resumo)     ||';'||
                  pk_csf.fkg_converte(rec3.mensagem)   ||';';
      --
      vn_fase := 4.3;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
   vn_fase := 5;
   vn_first_reg := 1;
   --
   for rec4 in c_log_ibmpc2
   loop
      --
      exit when c_log_ibmpc2%notfound or (c_log_ibmpc2%notfound) is null;
      --
      vv_dados_empresa := pk_csf.fkg_cod_nome_empresa_id ( en_empresa_id => rec4.empresa_id );
      --
      vn_fase := 5.1;
      --
      if nvl(vn_first_reg,0) = 1 then
          --cria o cabecalho
          pkb_armaz_imprerroagendintegr (  en_agendintegr_id => en_agendintegr_id
                                         , en_objintegr_id   => en_objintegr_id
                                         , en_usuario_id     => en_usuario_id
                                         , el_texto          => 'Relatório de Erros de integração de Demais Documentos e Operações - Bloco M EFD Contribuições.'
                                        );
         --
         -- monta a identificação dos títulos
         pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                       , en_objintegr_id   => en_objintegr_id
                                       , en_usuario_id     => en_usuario_id
                                       , el_texto          => 'TIPO;DATA_HR_LOG;EMPRESA;RESUMO;MENSAGEM;'
                                       );
         --
         vn_first_reg := 0;
         --
      end if;
      --
      vn_fase := 5.2;
      --
      vl_texto := 'INF_BLOCO_M_PC'                      ||';'||
                  rec4.dt_hr_log                        ||';'||
                  vv_dados_empresa                      ||';'||
                  pk_csf.fkg_converte(rec4.resumo)      ||';'||
                  pk_csf.fkg_converte(rec4.mensagem)    ||';';
      --
      vn_fase := 5.3;
      --
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id  => en_agendintegr_id
                                    , en_objintegr_id    => en_objintegr_id
                                    , en_usuario_id      => en_usuario_id
                                    , el_texto           => vl_texto
                                    );
      --
   end loop;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_monta_bloco_m_pc ('||vn_fase||'): '||sqlerrm);
end pkb_monta_bloco_m_pc;
--
------------------------------------------------------------------------------------------
-- Procedimento de inicio da geração do relatório de erros
------------------------------------------------------------------------------------------
procedure pkb_geracao ( en_agendintegr_id  in agend_integr.id%type
                      , en_objintegr_id    in obj_integr.id%type
                      , en_usuario_id      in neo_usuario.id%type
                      )
is
   --
   vn_fase              number := 0;
   vd_dt_agend          agend_integr.dt_agend%type;
   vd_dt_termino        item_agend_integr.dt_termino%type;
   vn_empresa_id        empresa.id%type;
   vv_obj_integr_cd     obj_integr.cd%type;
   vn_dm_tipo           agend_integr.dm_tipo%type;
   vd_dt_ini_integr     agend_integr.dt_ini_integr%type;
   vd_dt_fin_integr     agend_integr.dt_fin_integr%type;
   vn_multorg_id        mult_org.id%type;
   vn_dm_dt_escr_dfepoe empresa.dm_dt_escr_dfepoe%type;
   --
begin
   --#72944
    BEGIN
      EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD/MM/YYYY'' ';
    END;
   --
   vn_fase := 1;
   -- apaga os dados
   delete from impr_erro_agend_integr
    where agendintegr_id  = en_agendintegr_id
      and objintegr_id    = en_objintegr_id
      and usuario_id      = en_usuario_id;
   --
   commit;
   --
   vt_impr_erro_agend_integr.delete;
   --
   vn_fase := 2;
   -- recupera dados para identificar o tipo de relatório
   begin
      --
      select to_char(ai.dt_agend,'DD/MM/YYYY')--#72944
           , to_char(iai.dt_termino,'DD/MM/YYYY')--#72944
           , ai.empresa_id
           , oi.cd
           , ai.dm_tipo
           , ai.dt_ini_integr
           , ai.dt_fin_integr
        into vd_dt_agend
           , vd_dt_termino
           , vn_empresa_id
           , vv_obj_integr_cd
           , vn_dm_tipo
           , vd_dt_ini_integr
           , vd_dt_fin_integr
        from agend_integr      ai
           , item_agend_integr iai
           , obj_integr        oi
       where ai.id              = en_agendintegr_id
         and iai.agendintegr_id = ai.id
         and oi.id              = iai.objintegr_id
         and oi.id              = en_objintegr_id;
      --
   exception
      when others then --#72944
         raise_application_error(-20101, 'Erro ao recuperar os dados do agendendamento de integracao ('
                                ||vn_fase||'): Agendintegr_id: '||en_agendintegr_id|| ' - Objintegr_id  '||en_objintegr_id|| ' - Erro : '||sqlerrm);
   end;
   --
   vn_fase := 3;
   --
   vn_multorg_id        := pk_csf.fkg_multorg_id_empresa ( en_empresa_id => vn_empresa_id );
   vn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => vn_empresa_id );
   --
   vn_fase := 3.1;
   --
   --|Iniciando variavel que guarda o identificador do fechamento fiscal.
   info_fechamento := pk_csf.fkg_retorna_csftipolog_id(ev_cd => 'INFO_FECHAMENTO');
   --
   vn_fase := 4;
   -- inicia geração de arquivos
   if vv_obj_integr_cd in ('1') then -- Cadastros Gerais
      --
      vn_fase := 4.1;
      --
      pkb_monta_rel_cad_geral ( en_agendintegr_id => en_agendintegr_id
                              , en_objintegr_id   => en_objintegr_id
                              , en_usuario_id     => en_usuario_id
                              , ed_dt_agend       => to_char(vd_dt_agend,'DD/MM/YYYY')--#72944
                              , ed_dt_termino     => to_char(vd_dt_termino,'DD/MM/YYYY')--#72944
                              , en_multorg_id     => vn_multorg_id
                              );
      --
   elsif vv_obj_integr_cd in ('2') then -- Inventario de produtos
      --
      vn_fase := 4.2;
      --
      pkb_monta_rel_invent ( en_agendintegr_id => en_agendintegr_id
                           , en_objintegr_id   => en_objintegr_id
                           , en_usuario_id     => en_usuario_id
                           , ed_dt_ini_integr  => vd_dt_ini_integr
                           , ed_dt_fin_integr  => vd_dt_fin_integr
                           , en_empresa_id     => vn_empresa_id
                           , en_dm_tipo        => vn_dm_tipo
                           , en_multorg_id     => vn_multorg_id
                           , ed_dt_agend       => vd_dt_agend
                           , ed_dt_termino     => vd_dt_termino
                           );
      --
   elsif vv_obj_integr_cd in ('3') then -- Cupom Fiscal
      --
      vn_fase := 4.3;
      --
      pkb_monta_rel_cupom_fiscal ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , ed_dt_ini_integr  => vd_dt_ini_integr
                                 , ed_dt_fin_integr  => vd_dt_fin_integr
                                 , en_empresa_id     => vn_empresa_id
                                 , en_dm_tipo        => vn_dm_tipo
                                 , en_multorg_id     => vn_multorg_id
                                 , ed_dt_agend       => vd_dt_agend
                                 , ed_dt_termino     => vd_dt_termino
                                 );
      --
   elsif vv_obj_integr_cd in ('4') then -- Conhecimento de Transporte
      --
      vn_fase := 4.4;
      --
      pkb_monta_rel_conhec_transp ( en_agendintegr_id => en_agendintegr_id
                                  , en_objintegr_id   => en_objintegr_id
                                  , en_usuario_id     => en_usuario_id
                                  , ed_dt_ini_integr  => vd_dt_ini_integr
                                  , ed_dt_fin_integr  => vd_dt_fin_integr
                                  , en_empresa_id     => vn_empresa_id
                                  , en_dm_tipo        => vn_dm_tipo
                                  , en_multorg_id     => vn_multorg_id
                                  , ed_dt_agend       => vd_dt_agend
                                  , ed_dt_termino     => vd_dt_termino
                                  );
      --
   elsif vv_obj_integr_cd in ('5') then -- Notas Fiscais de Serviços Contínuos (Água, Luz, etc.)
      --
      vn_fase := 4.5;
      --
      pkb_monta_rel_nota_fiscal_sc ( en_agendintegr_id    => en_agendintegr_id
                                   , en_objintegr_id      => en_objintegr_id
                                   , en_usuario_id        => en_usuario_id
                                   , ed_dt_ini_integr     => vd_dt_ini_integr
                                   , ed_dt_fin_integr     => vd_dt_fin_integr
                                   , en_empresa_id        => vn_empresa_id
                                   , en_dm_tipo           => vn_dm_tipo
                                   , en_dm_dt_escr_dfepoe => vn_dm_dt_escr_dfepoe
                                   , en_multorg_id        => vn_multorg_id
                                   , ed_dt_agend          => vd_dt_agend
                                   , ed_dt_termino        => vd_dt_termino
                                   );
      --
   elsif vv_obj_integr_cd in ('6') then -- Notas Fiscais Mercantis
      --
      vn_fase := 4.6;
      --
      pkb_monta_rel_nota_fiscal ( en_agendintegr_id    => en_agendintegr_id
                                , en_objintegr_id      => en_objintegr_id
                                , en_usuario_id        => en_usuario_id
                                , ed_dt_ini_integr     => vd_dt_ini_integr
                                , ed_dt_fin_integr     => vd_dt_fin_integr
                                , en_empresa_id        => vn_empresa_id
                                , en_dm_tipo           => vn_dm_tipo
                                , en_dm_dt_escr_dfepoe => vn_dm_dt_escr_dfepoe
                                , en_multorg_id        => vn_multorg_id
                                , ed_dt_agend          => vd_dt_agend
                                , ed_dt_termino        => vd_dt_termino
                                );
      --
   elsif vv_obj_integr_cd in ('7') then -- Notas Fiscais de Serviços EFD
      --
      vn_fase := 4.7;
      --
      pkb_monta_rel_nota_fiscal_efd ( en_agendintegr_id    => en_agendintegr_id
                                    , en_objintegr_id      => en_objintegr_id
                                    , en_usuario_id        => en_usuario_id
                                    , ed_dt_ini_integr     => vd_dt_ini_integr
                                    , ed_dt_fin_integr     => vd_dt_fin_integr
                                    , en_empresa_id        => vn_empresa_id
                                    , en_dm_tipo           => vn_dm_tipo
                                    , en_dm_dt_escr_dfepoe => vn_dm_dt_escr_dfepoe
                                    , en_multorg_id        => vn_multorg_id
                                    , ed_dt_agend          => vd_dt_agend
                                    , ed_dt_termino        => vd_dt_termino
                                    );
      --
   elsif vv_obj_integr_cd in ('8') then -- CIAP
      --
      vn_fase := 4.8;
      --
      pkb_monta_rel_ciap ( en_agendintegr_id => en_agendintegr_id
                         , en_objintegr_id   => en_objintegr_id
                         , en_usuario_id     => en_usuario_id
                         , ed_dt_ini_integr  => vd_dt_ini_integr
                         , ed_dt_fin_integr  => vd_dt_fin_integr
                         , en_empresa_id     => vn_empresa_id
                         , en_dm_tipo        => vn_dm_tipo
                         , en_multorg_id     => vn_multorg_id
                         , ed_dt_agend       => vd_dt_agend
                         , ed_dt_termino     => vd_dt_termino
                         );
	  --
   elsif vv_obj_integr_cd in ('9') then -- Ecredac
      --
      vn_fase := 4.10;
      --
      pkb_monta_rel_ecredac ( en_agendintegr_id => en_agendintegr_id
                            , en_objintegr_id   => en_objintegr_id
                            , en_usuario_id     => en_usuario_id
                            , ed_dt_agend       => vd_dt_agend
                            , ed_dt_termino     => vd_dt_termino
                            , en_multorg_id     => vn_multorg_id
                            );
    -- #69487 inclusao da chamada deste tipo de nota
   elsif vv_obj_integr_cd in ('13') then -- Notas Fiscais Mercantis NFCe
      --
      vn_fase := 4.6;
      --
      pkb_monta_rel_nota_fiscal ( en_agendintegr_id    => en_agendintegr_id
                                , en_objintegr_id      => en_objintegr_id
                                , en_usuario_id        => en_usuario_id
                                , ed_dt_ini_integr     => vd_dt_ini_integr
                                , ed_dt_fin_integr     => vd_dt_fin_integr
                                , en_empresa_id        => vn_empresa_id
                                , en_dm_tipo           => vn_dm_tipo
                                , en_dm_dt_escr_dfepoe => vn_dm_dt_escr_dfepoe
                                , en_multorg_id        => vn_multorg_id
                                , ed_dt_agend          => vd_dt_agend
                                , ed_dt_termino        => vd_dt_termino
                                );
    --
   elsif vv_obj_integr_cd in ('19') then -- Usuários
      --
      vn_fase := 4.9;
      --
      pkb_monta_rel_usuario ( en_agendintegr_id => en_agendintegr_id
                            , en_objintegr_id   => en_objintegr_id
                            , en_usuario_id     => en_usuario_id
                            , ed_dt_agend       => vd_dt_agend
                            , ed_dt_termino     => vd_dt_termino
                            , en_multorg_id     => vn_multorg_id
                            );
      --
   elsif vv_obj_integr_cd in ('27') then -- Escrituração Contábil Sped ECF
      --
      vn_fase := 4.11;
      --
      pkb_monta_rel_secf ( en_agendintegr_id => en_agendintegr_id
                         , en_objintegr_id   => en_objintegr_id
                         , en_usuario_id     => en_usuario_id
                         , ed_dt_ini_integr  => vd_dt_ini_integr
                         , ed_dt_fin_integr  => vd_dt_fin_integr
                         , en_empresa_id     => vn_empresa_id
                         , en_dm_tipo        => vn_dm_tipo
                         , en_multorg_id     => vn_multorg_id
                         , ed_dt_agend       => vd_dt_agend
                         , ed_dt_termino     => vd_dt_termino
                         );
      --
   elsif vv_obj_integr_cd in ('32') then -- Dados Contábeis
      --
      vn_fase := 4.12;
      --
      pkb_monta_rel_dados_contab ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , ed_dt_ini_integr  => vd_dt_ini_integr
                                 , ed_dt_fin_integr  => vd_dt_fin_integr
                                 , en_empresa_id     => vn_empresa_id
                                 , en_dm_tipo        => vn_dm_tipo
                                 , en_multorg_id     => vn_multorg_id
                                 , ed_dt_agend       => vd_dt_agend
                                 , ed_dt_termino     => vd_dt_termino
                                 );
      --
   elsif vv_obj_integr_cd in ('33') then -- Produção Diária de Usina
      --
      vn_fase := 4.13;
      --
      pkb_monta_rel_pdu ( en_agendintegr_id => en_agendintegr_id
                        , en_objintegr_id   => en_objintegr_id
                        , en_usuario_id     => en_usuario_id
                        , ed_dt_ini_integr  => vd_dt_ini_integr
                        , ed_dt_fin_integr  => vd_dt_fin_integr
                        , en_empresa_id     => vn_empresa_id
                        , en_dm_tipo        => vn_dm_tipo
                        , en_multorg_id     => vn_multorg_id
                        , ed_dt_agend       => vd_dt_agend
                        , ed_dt_termino     => vd_dt_termino
                        );
      --
   elsif vv_obj_integr_cd in ('36') then -- Informações de Valores Agregados
      --
      vn_fase := 4.14;
      --
      pkb_monta_rel_iva ( en_agendintegr_id => en_agendintegr_id
                        , en_objintegr_id   => en_objintegr_id
                        , en_usuario_id     => en_usuario_id
                        , ed_dt_ini_integr  => vd_dt_ini_integr
                        , ed_dt_fin_integr  => vd_dt_fin_integr
                        , en_empresa_id     => vn_empresa_id
                        , en_dm_tipo        => vn_dm_tipo
                        , en_multorg_id     => vn_multorg_id
                        , ed_dt_agend       => vd_dt_agend
                        , ed_dt_termino     => vd_dt_termino
                        );
      --
   elsif vv_obj_integr_cd in ('39') then -- Controle de Creditos Fiscais de ICMS
      --
      vn_fase := 4.15;
      --
      pkb_monta_rel_cf_icms ( en_agendintegr_id => en_agendintegr_id
                            , en_objintegr_id   => en_objintegr_id
                            , en_usuario_id     => en_usuario_id
                            , ed_dt_ini_integr  => vd_dt_ini_integr
                            , ed_dt_fin_integr  => vd_dt_fin_integr
                            , en_empresa_id     => vn_empresa_id
                            , en_dm_tipo        => vn_dm_tipo
                            , en_multorg_id     => vn_multorg_id
                            , ed_dt_agend       => vd_dt_agend
                            , ed_dt_termino     => vd_dt_termino
                            );
      --
   elsif vv_obj_integr_cd in ('42') then -- Total de operações com cartão
      --
      vn_fase := 4.16;
      --
      pkb_monta_rel_tot_op_cart ( en_agendintegr_id => en_agendintegr_id
                                , en_objintegr_id   => en_objintegr_id
                                , en_usuario_id     => en_usuario_id
                                , ed_dt_ini_integr  => vd_dt_ini_integr
                                , ed_dt_fin_integr  => vd_dt_fin_integr
                                , en_empresa_id     => vn_empresa_id
                                , en_dm_tipo        => vn_dm_tipo
                                , en_multorg_id     => vn_multorg_id
                                , ed_dt_agend       => vd_dt_agend
                                , ed_dt_termino     => vd_dt_termino
                                );
      --
   elsif vv_obj_integr_cd in ('45') then -- MANAD (Informações de folhas de pagamento)
      --
      vn_fase := 4.17;
      --
      pkb_monta_rel_manad ( en_agendintegr_id => en_agendintegr_id
                          , en_objintegr_id   => en_objintegr_id
                          , en_usuario_id     => en_usuario_id
                          , ed_dt_ini_integr  => vd_dt_ini_integr
                          , ed_dt_fin_integr  => vd_dt_fin_integr
                          , en_multorg_id     => vn_multorg_id
                          , ed_dt_agend       => vd_dt_agend
                          , ed_dt_termino     => vd_dt_termino
                          );
      --
   elsif vv_obj_integr_cd in ('46') then -- Pagamento de Impostos no padrão para DCTF
      --
      vn_fase := 4.18;
      --
      --cria o cabecalho
      pkb_armaz_imprerroagendintegr ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , el_texto          => 'Relatório de Erros de integração de Pagamento de Impostos Retidos.'
                                 );
                                 
      --verifica se tem erros de pagamento retido                        
      pkb_monta_rel_pgto_imp_ret ( en_agendintegr_id => en_agendintegr_id
                                 , en_objintegr_id   => en_objintegr_id
                                 , en_usuario_id     => en_usuario_id
                                 , ed_dt_ini_integr  => vd_dt_ini_integr
                                 , ed_dt_fin_integr  => vd_dt_fin_integr
                                 , en_empresa_id     => vn_empresa_id
                                 , en_dm_tipo        => vn_dm_tipo
                                 , ed_dt_agend       => vd_dt_agend
                                 , ed_dt_termino     => vd_dt_termino
                                 );
      --
      vn_fase := 4.19;
      --
      --verifica se tem erros de pagamento retido pc 
      pkb_monta_rel_imp_ret_rec_pc ( en_agendintegr_id => en_agendintegr_id
                                   , en_objintegr_id   => en_objintegr_id
                                   , en_usuario_id     => en_usuario_id
                                   , ed_dt_ini_integr  => vd_dt_ini_integr
                                   , ed_dt_fin_integr  => vd_dt_fin_integr
                                   , en_empresa_id     => vn_empresa_id
                                   , en_dm_tipo        => vn_dm_tipo
                                   , ed_dt_agend       => vd_dt_agend
                                   , ed_dt_termino     => vd_dt_termino
                                   );
                                   
      vn_fase := 4.20;
      --
      --verifica se tem erros de credito de imposto 
      pkb_monta_rel_imp_cred_dctf (  en_agendintegr_id => en_agendintegr_id
                                   , en_objintegr_id   => en_objintegr_id
                                   , en_usuario_id     => en_usuario_id
                                   , ed_dt_ini_integr  => vd_dt_ini_integr
                                   , ed_dt_fin_integr  => vd_dt_fin_integr
                                   , en_empresa_id     => vn_empresa_id
                                   , en_dm_tipo        => vn_dm_tipo
                                   , ed_dt_agend       => vd_dt_agend
                                   , ed_dt_termino     => vd_dt_termino
                                   );    
   --
   elsif vv_obj_integr_cd in ('47') then -- Informações da DIRF
      --
      vn_fase := 4.21;
      --
      pkb_monta_rel_dirf ( en_agendintegr_id => en_agendintegr_id
                         , en_objintegr_id   => en_objintegr_id
                         , en_usuario_id     => en_usuario_id
                         , ed_dt_ini_integr  => vd_dt_ini_integr
                         , ed_dt_fin_integr  => vd_dt_fin_integr
                         , en_empresa_id     => vn_empresa_id
                         , en_dm_tipo        => vn_dm_tipo
                         , en_multorg_id     => vn_multorg_id
                         , ed_dt_agend       => vd_dt_agend
                         , ed_dt_termino     => vd_dt_termino
                         );
      --
   elsif vv_obj_integr_cd in ('48') then -- Controle da Produção e do Estoque - Bloco K
      --
      vn_fase := 4.22;
      --
      pkb_monta_rel_contr_prod_estq ( en_agendintegr_id => en_agendintegr_id
                                    , en_objintegr_id   => en_objintegr_id
                                    , en_usuario_id     => en_usuario_id
                                    , ed_dt_ini_integr  => vd_dt_ini_integr
                                    , ed_dt_fin_integr  => vd_dt_fin_integr
                                    , en_empresa_id     => vn_empresa_id
                                    , en_dm_tipo        => vn_dm_tipo
                                    , en_multorg_id     => vn_multorg_id
                                    , ed_dt_agend       => vd_dt_agend
                                    , ed_dt_termino     => vd_dt_termino
                                    );
      --
   elsif vv_obj_integr_cd in ('50') then -- Demais Documentos e Operações - Bloco F EFD Contribuições
      --
      vn_fase := 4.23;
      --
      pkb_monta_rel_ddo ( en_agendintegr_id => en_agendintegr_id
                        , en_objintegr_id   => en_objintegr_id
                        , en_usuario_id     => en_usuario_id
                        , ed_dt_ini_integr  => vd_dt_ini_integr
                        , ed_dt_fin_integr  => vd_dt_fin_integr
                        , en_empresa_id     => vn_empresa_id
                        , en_dm_tipo        => vn_dm_tipo
                        , en_multorg_id     => vn_multorg_id
                        , ed_dt_agend       => vd_dt_agend
                        , ed_dt_termino     => vd_dt_termino
                        );
      --
   elsif vv_obj_integr_cd in ('51') then -- Bloco I
      --
      /*vn_fase := 4.24;
      --
      pkb_monta_rel_blocoi ( en_agendintegr_id => en_agendintegr_id
                           , en_objintegr_id   => en_objintegr_id
                           , en_usuario_id     => en_usuario_id
                           , ed_dt_ini_integr  => vd_dt_ini_integr
                           , ed_dt_fin_integr  => vd_dt_fin_integr
                           , en_empresa_id     => vn_empresa_id
                           , en_dm_tipo        => vn_dm_tipo
                           , en_multorg_id     => vn_multorg_id
                           , ed_dt_agend       => vd_dt_agend
                           );
      */
      --
      null;
      --
   elsif vv_obj_integr_cd in ('52') then -- DIMOB
      --
      null;
      --
   elsif vv_obj_integr_cd in ('53') then -- Informações sobre exportação
      --
      vn_fase := 4.25;
      --
      pkb_monta_rel_infoexp ( en_agendintegr_id => en_agendintegr_id
                            , en_objintegr_id   => en_objintegr_id
                            , en_usuario_id     => en_usuario_id
                            , ed_dt_agend       => vd_dt_agend
                            , ed_dt_termino     => vd_dt_termino
                            , en_multorg_id     => vn_multorg_id
                            );
      --
   elsif vv_obj_integr_cd in ('55') then -- EFD-REINF - Retenções e Outras Informações Fiscais
      --
      vn_fase := 4.26;
      --
      pkb_monta_rel_reinf ( en_agendintegr_id => en_agendintegr_id
                          , en_objintegr_id   => en_objintegr_id
                          , en_usuario_id     => en_usuario_id
                          , ed_dt_ini_integr  => vd_dt_ini_integr
                          , ed_dt_fin_integr  => vd_dt_fin_integr
                          , ed_dt_agend       => vd_dt_agend
                          , ed_dt_termino     => vd_dt_termino
                          , en_empresa_id     => vn_empresa_id
                          , en_dm_tipo        => vn_dm_tipo
                          , en_multorg_id     => vn_multorg_id
                          );
      --
   -- #76133 - Inclusão do pacote de integração de Bloco M do EFD PC
   elsif vv_obj_integr_cd in ('57') then -- Demais Documentos e Operações - Bloco M EFD Contribuições
     --
     vn_fase := 4.28;
     --
     pkb_monta_bloco_m_pc (  en_agendintegr_id    => en_agendintegr_id
                           , en_objintegr_id      => en_objintegr_id
                           , en_usuario_id        => en_usuario_id
                           , ed_dt_ini_integr     => vd_dt_ini_integr
                           , ed_dt_fin_integr     => vd_dt_fin_integr
                           , en_empresa_id        => vn_empresa_id
                           , en_dm_tipo           => vn_dm_tipo
                           , en_multorg_id        => vn_multorg_id
                           , ed_dt_agend       => vd_dt_agend
                           , ed_dt_termino     => vd_dt_termino
                           );
     --
   end if;
   --
   vn_fase := 5;
   -- grava as informações do relatório
   pkb_grava_imprerroagendintegr;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_rel_erro_agend_integr.pkb_geracao ('||vn_fase||'): '||sqlerrm);
end pkb_geracao;

------------------------------------------------------------------------------------------

end pk_rel_erro_agend_integr;
/
