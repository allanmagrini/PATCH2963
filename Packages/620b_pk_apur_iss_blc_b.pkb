create or replace package body csf_own.pk_apur_iss_blc_b
is
----------------------------------------------------------------------------------------------------------------------
/*Procedimento de registro de log de erros na validação*/
procedure pkb_log_apur_iss(sn_logapuriss_id out nocopy log_apur_iss.id%type,
                           en_apuriss_id    in log_apur_iss.apuriss_id%type,
                           ev_resumo        in log_apur_iss.resumo%type,
                           ev_mensagem      in log_apur_iss.mensagem%type,
                           ev_usuario_id    in log_apur_iss.usuario_id%type,
                           ev_maquina       in log_apur_iss.maquina%type) is
  --
  vn_fase number := 0;
  pragma autonomous_transaction;
  vn_logapuriss_id log_apur_iss.id%type;
  vn_usuario_id    log_apur_iss.usuario_id%type;
  vv_maquina       log_apur_iss.maquina%type;
  --
begin
  --
  vn_fase := 1;
  --
  if ev_mensagem is not null then
    --
    vn_fase := 2;
    --
    select logapuriss_seq.nextval 
      into sn_logapuriss_id 
      from dual;
    --
    vn_fase := 3;
    --
    insert into log_apur_iss
      (id, 
       apuriss_id, 
       dt_hr_log, 
       resumo, 
       mensagem, 
       usuario_id, 
       maquina)
    values
      (sn_logapuriss_id, -- Identificador do registro de Log - Mensagens da Apuração do ISS.
       en_apuriss_id, -- Identificador da Apuração do ISS.
       sysdate, -- Data e hora do log/alteração.
       ev_resumo, -- Resumo do log/alteração..
       ev_mensagem, -- Mensagem do log/alteração
       ev_usuario_id, -- Identificador do usuário conectado.
       ev_maquina); -- Máquina do usuário conectado.
    --
    commit;
    --
  end if;
  --
exception
  when others then
    --
    gv_resumo_log   := 'Erro em pk_apur_iss_blc_b.pkb_log_apur_iss';
    gv_mensagem_log := 'Erro na pk_apur_iss_blc_b.pkb_log_apur_iss fase(' || vn_fase || '): ' || sqlerrm;
    --
    if ev_usuario_id is null then
      vn_usuario_id := pk_csf.fkg_usuario_id(ev_login => 'admin');
    end if;
    --      
    if vv_maquina is null then
      --        
      vv_maquina := sys_context('USERENV', 'HOST');
      --
      if vv_maquina is null then
        --
        vv_maquina := 'Servidor';
        --
      end if;
      --         
    end if;
    --           
    begin
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => en_apuriss_id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --
    exception
      when others then
        null;
    end;
    --
END pkb_log_apur_iss;
----------------------------------------------------------------------------------------------------------------------
/*Procedimento para obter o registro da tabela Apur_iss a partir do ID enviado por parametro. */
procedure pkb_dados_apur_iss(en_apur_iss_id in apur_iss.id%type,
                             ev_usuario_id  in log_apur_iss.usuario_id%type,
                             ev_maquina     in log_apur_iss.maquina%type) is
  --
  vn_fase          number := 0;
  vn_logapuriss_id log_apur_iss.id%type;
  --
  cursor c_apur_iss is
    select ai.* 
      from apur_iss ai 
     where ai.id = en_apur_iss_id;
  --
begin
  --
  vn_fase := 1;
  --
  gt_row_apur_iss := null;
  --
  if nvl(en_apur_iss_id, 0) > 0 then
    --
    vn_fase := 2;
    --
    open c_apur_iss;
    fetch c_apur_iss
      into gt_row_apur_iss;
    close c_apur_iss;
    --
  end if;
  --
exception
  when others then
    --
    gv_resumo_log   := 'Erro em pk_apur_iss_blc_b.pkb_dados_apur_iss';
    gv_mensagem_log := 'Erro em pk_apur_iss_blc_b.pkb_dados_apur_iss fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    begin
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => gt_row_apur_iss.id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --
    exception
      when others then
        null;
    end;
    --
    raise_application_error(-20101, gv_mensagem_log);
    --
end pkb_dados_apur_iss;
----------------------------------------------------------------------------------------------------------------------
/*Função para valida se há registro na tabela deducao_iss.*/
function fkg_valida_deducao_iss(en_apur_iss_id in apur_iss.id%type) return number is
  --
  vn_count number;
  --
begin
  --  
  vn_count := 0;
  --
  select count(1)
    into vn_count
    from deducao_iss
   where apuriss_id = en_apur_iss_id;
  --  
  return vn_count;
  --     
exception
  when no_data_found then
    return 0;
  when others then
    raise_application_error(-20101, 'Erro na fkg_valida_deducao_iss:' || sqlerrm);
end fkg_valida_deducao_iss;
----------------------------------------------------------------------------------------------------------------------
/*Função para valida se há registro na tabela abertura_efd*/
function fkg_valida_efd_abertura(en_empr_id in abertura_efd.empresa_id%type,
                                 ed_dt_ini  in abertura_efd.dt_ini%type,
                                 ed_dt_fim  in abertura_efd.dt_fim%type) return number is
  --
  vn_count number;
  --
begin
  --  
  vn_count := 0;
  --
  select count(1)
    into vn_count
    from abertura_efd
   where empresa_id  = en_empr_id
     and dt_ini      = ed_dt_ini
     and dt_fim      = ed_dt_fim
     and dm_situacao = 4; /* 4 - Gerado Arquivo*/
  --  
  return vn_count;
  --     
exception
  when no_data_found then
    return 0;
  when others then
    raise_application_error(-20101, 'Erro na fkg_valida_efd_abertura:' || sqlerrm);
end;

----------------------------------------------------------------------------------------------------------------------
/* Recuperar as informações das notas fiscais de serviço, conforme definição no item “B470-Apuração do ISS”, referente ao título “Descrição Funcional”. */
----------------------------------------------------------------------------------------------------------------------
procedure pkb_gerar_dados(en_apuriss_id in apur_iss.id%type,
                          ev_usuario_id in log_apur_iss.usuario_id%type,
                          ev_maquina    in log_apur_iss.maquina%type) is
  --
  vn_fase               number;
  vn_escr_dfepoe        number;
  vn_vl_cont_total      nota_fiscal_total.vl_total_serv%type; /* A - Valor total referente às prestações de serviço do período */
  vn_vl_mat_terc_total  item_nota_fiscal.vl_item_bruto%type; /* B - Valor total do material fornecido por terceiros na prestação do serviço */
  vn_vl_mat_prop_total  item_nota_fiscal.vl_item_bruto%type; /* C - Valor do material próprio utilizado na prestação do serviço */
  vn_vl_bc_iss_rt_total imp_itemnf.vl_base_calc%type; /* H - Valor total da base de cálculo de retenção do ISS referente às prestações do declarante. */
  vn_vl_iss_total       imp_itemnf.vl_imp_trib%type; /* I - Valor total do ISS destacado */
  vn_vl_iss_rt_total    imp_itemnf.vl_imp_trib%type; /* J - Valor total do ISS retido pelo tomador nas prestações do declarante */
  vn_vl_ded_total       nota_fiscal_total.vl_deducao%type; /* K - Valor total das deduções do ISS próprio */
  vn_vl_iss_st_total    imp_itemnf.vl_imp_trib%type; /* M - Valor total do ISS substituto a recolher pelas aquisições do declarante (tomador) */
  vn_logapuriss_id      log_apur_iss.id%type;
  --
  vn_vl_total_nf        nota_fiscal_total.vl_total_nf%type;
  vn_vl_serv_nao_trib   nota_fiscal_total.vl_serv_nao_trib%type;
  --  
  vn_vl_sub             number(15, 2); /* D - Valor total das subempreitadas */
  vn_vl_isnt            number(15, 2); /* E - Valor total das operações isentas ou não-tributadas pelo ISS - Resultado da equação (A - B - C) */
  vn_vl_ded_bc          number(15, 2); /* F - Valor total das deduções da base de cálculo (B + C + D + E)  - Somatória dos campos (B + C + D + E)  */
  vn_vl_bc_iss          number(15, 2); /* G - Valor total da base de cálculo do ISS - Resultado da equação (A - F) */
  vn_vl_iss_rec         number(15, 2); /* L - Valor total apurado do ISS próprio a recolher (I - J - K) - Resultado da equação (I - J - K) */
  vn_vl_iss_rec_uni     number(15, 2); /* N - Valor do ISS próprio a recolher pela Sociedade Uniprofissional */
  vn_vl_bc_iss_rt       imp_itemnf.vl_base_calc%type;
  vn_vl_iss_rt          imp_itemnf.vl_imp_trib%type;
  vn_vl_iss_st          imp_itemnf.vl_imp_trib%type;
  --  
  vn_dm_mat_prop_terc   item_nota_fiscal.dm_mat_prop_terc%type;
  vn_vl_cont            nota_fiscal_total.vl_total_serv%type;
  --
  cursor c_nf(v_empr_id           abertura_efd.empresa_id%type,
              v_dt_ini            date,
              v_dt_fim            date,
              v_dm_dt_escr_dfepoe number) is   
    select nft.vl_total_serv as vl_cont,
           decode(nf.dm_ind_emit, 0, nft.vl_deducao, 0) as vl_ded,
           nf.id notafiscal_id,
           nf.dm_ind_emit,
           nft.vl_total_nf,
           nft.vl_serv_nao_trib,
           mf.cod_mod 
      from nota_fiscal       nf,
           pessoa            pe,
           mod_fiscal        mf,
           sit_docto         sd,
           nota_fiscal_total nft
     where nf.empresa_id      = v_empr_id
       and nf.sitdocto_id     = sd.id
       and nf.modfiscal_id    = mf.id
       and nft.notafiscal_id  = nf.id
       and nf.dm_arm_nfe_terc = 0
       and nf.dm_st_proc      in (4, 14)
       and mf.cod_mod         in ('01', '03', '3B', '04', '08', '55', '65','99')
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(v_dt_ini) and trunc(v_dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(v_dt_ini) and trunc(v_dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and v_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(v_dt_ini) and trunc(v_dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and v_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(v_dt_ini) and trunc(v_dt_fim)))
       and pe.id = nf.pessoa_id
       and exists ( select 1
                      from item_nota_fiscal inf,
                           imp_itemnf       iin,
                           tipo_imposto     ti
                     where inf.notafiscal_id = nf.id
                       and iin.itemnf_id(+)  = inf.id
                       and iin.tipoimp_id    = ti.id
                       and ti.cd             = 6 ); --ISS	   
     /*and not exists (select 1 
                         from pessoa_tipo_param pt,
                              tipo_param        tp
                              valor_tipo_param  vt
                        where pt.pessoa_id    = pe.id
                          and tp.id           = pt.tipoparam_id
                          and tp.cd           = '13' -- Natureza/Setor da Pessoa
                          and vt.tipoparam_id = pt.tipoparam_id
                          and vt.id           = pt.valortipoparam_id
                          and vt.cd           = 1 -- Setor Publico*/
  --
  cursor c_item_nf(v_notafiscal_id nota_fiscal.id%type) is
    select distinct decode(inf.dm_mat_prop_terc, 0, inf.vl_item_bruto, 0) as vl_mat_terc,
           decode(inf.dm_mat_prop_terc, 1, inf.vl_item_bruto, 0) as vl_mat_prop,
           case
             when nf.dm_ind_emit = 0 and iin.dm_tipo = 0 then
                nvl(iin.vl_imp_trib, 0)
           end vl_iss,
           case
             when nf.dm_ind_emit = 0 and iin.dm_tipo = 1 then
                nvl(iin.vl_base_calc, 0)
           end vl_base_calc_ret,  
           case
             when nf.dm_ind_emit = 0 and iin.dm_tipo = 1 then
               nvl(iin.vl_imp_trib, 0)
           end vl_iss_ret,
           case
             when nf.dm_ind_emit = 1 and iin.dm_tipo = 1 then
               nvl(iin.vl_imp_trib, 0)
           end vl_iss_st,
           inf.id itemnf_id
      from nota_fiscal      nf,
           item_nota_fiscal inf,
           imp_itemnf       iin,
           tipo_imposto     ti
     where nf.id             = v_notafiscal_id
       and inf.notafiscal_id = nf.id
       and iin.itemnf_id(+)  = inf.id
       and iin.dm_tipo       in (0, 1) -- 0 - Imposto / 1 - Retenção 
       and iin.tipoimp_id    = ti.id
       and ti.cd             = 6; -- ISS
  --     
begin
  --
  vn_fase := 1;
  --
  pkb_dados_apur_iss(en_apuriss_id, ev_usuario_id, ev_maquina);
  -- 
  vn_fase := 2;
  --
  if fkg_valida_efd_abertura(gt_row_apur_iss.empresa_id,
                             gt_row_apur_iss.dt_inicio,
                             gt_row_apur_iss.dt_fim) = 0 then
    --
    vn_fase := 3;
    --
    if gt_row_apur_iss.dm_situacao in (0, 1) then
      --
      vn_fase := 4;
      --
      vn_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa(en_empresa_id => gt_row_apur_iss.empresa_id);
      --  
      vn_fase := 5;
      --
      vn_vl_cont_total      := 0;
      vn_vl_mat_terc_total  := 0;
      vn_vl_mat_prop_total  := 0;
      vn_vl_bc_iss_rt_total := 0;
      vn_vl_iss_total       := 0;
      vn_vl_iss_rt_total    := 0;
      vn_vl_ded_total       := 0;
      vn_vl_iss_st_total    := 0;
      vn_vl_sub             := 0;
      vn_vl_isnt            := 0;
      vn_vl_ded_bc          := 0;
      vn_vl_bc_iss          := 0;
      vn_vl_iss_rec         := 0;
      vn_vl_iss_rec_uni     := 0;
      vn_vl_iss_rt          := 0;
      vn_vl_bc_iss_rt       := 0;
      --
      vn_vl_serv_nao_trib   := 0;
      vn_vl_total_nf        := 0;
      --      
      vn_fase := 6;
      --
      for rec_nf in c_nf(gt_row_apur_iss.empresa_id,
                         gt_row_apur_iss.dt_inicio,
                         gt_row_apur_iss.dt_fim,
                         vn_escr_dfepoe) loop
        exit when c_nf%notfound or(c_nf%notfound) is null;
        --   
        vn_fase := 6.1;
        --
        begin        
            select distinct inf.dm_mat_prop_terc 
            into vn_dm_mat_prop_terc
           from item_nota_fiscal inf 
           where inf.notafiscal_id = rec_nf.notafiscal_id;  
        exception 
		     when others then
		      null;
		    end;
        --
        vn_vl_cont:= nvl(rec_nf.vl_cont, 0);
        --
        if rec_nf.cod_mod = '99' and nvl(vn_dm_mat_prop_terc,0) = 0
          then 
           vn_vl_cont := 0; 
        end if;
        --  
        vn_vl_cont_total    := vn_vl_cont_total + vn_vl_cont; /* A*/
        vn_vl_ded_total     := vn_vl_ded_total + nvl(rec_nf.vl_ded, 0); /* K*/
        vn_vl_total_nf      := vn_vl_total_nf + nvl(rec_nf.vl_total_nf, 0);
        vn_vl_serv_nao_trib := vn_vl_serv_nao_trib + nvl(rec_nf.vl_serv_nao_trib, 0);
        --     
        for rec_item_nf in c_item_nf(rec_nf.notafiscal_id) loop
          exit when c_item_nf%notfound or(c_item_nf%notfound) is null;
          --
          vn_fase := 6.2;
          --      
          vn_vl_bc_iss_rt := 0;
          vn_vl_iss_rt    := 0;
          --
          /*begin
            select nvl(iin.vl_base_calc, 0), 
                   nvl(iin.vl_imp_trib, 0)
              into vn_vl_bc_iss_rt, 
                   vn_vl_iss_rt
              from imp_itemnf iin, 
                   tipo_imposto ti
             where iin.itemnf_id  = rec_item_nf.itemnf_id
               and iin.dm_tipo    = 1 -- Retenção
               and iin.tipoimp_id = ti.id
               and ti.cd          = 6; -- ISS
          exception
            when others then
              vn_vl_bc_iss_rt := 0;
              vn_vl_iss_rt    := 0;
          end;*/
          --
          vn_vl_mat_terc_total  := 0; --vn_vl_mat_terc_total + nvl(rec_item_nf.vl_mat_terc, 0); /* B */  -- Consultor José Hipolito solicitou zerar
          vn_vl_mat_prop_total  := 0; --vn_vl_mat_prop_total + nvl(rec_item_nf.vl_mat_prop, 0); /* C */  -- Consultor José Hipolito solicitou zerar
          vn_vl_bc_iss_rt_total := vn_vl_bc_iss_rt_total + nvl(rec_item_nf.vl_base_calc_ret, 0); /* H */
          vn_vl_iss_total       := vn_vl_iss_total + nvl(rec_item_nf.vl_iss, 0); /* I */
          vn_vl_iss_rt_total    := vn_vl_iss_rt_total + nvl(rec_item_nf.vl_iss_ret, 0); /* J */
          vn_vl_iss_st_total    := vn_vl_iss_st_total + nvl(rec_item_nf.vl_iss_st, 0); /* N */
        --
        end loop; -- c_item_nf
        --
        vn_fase := 6.3;
        --
        begin
          insert into r_apuriss_nf
            select rapurissnf_seq.nextval,
                   en_apuriss_id,
                   rec_nf.notafiscal_id
              from dual;
        exception
          when dup_val_on_index then
            null;
        end;
        --
        vn_fase := 6.4;
        --
        commit;
        --
        vn_fase := 6.5;
        --
      end loop; -- c_nf
      --   
      vn_fase := 7;
      --
      --vn_vl_isnt := abs(vn_vl_cont_total - vn_vl_mat_terc_total - vn_vl_mat_prop_total); /*Resultado da equação (A - B - C) */
      --vn_vl_isnt    := vn_vl_total_nf - vn_vl_mat_terc_total - vn_vl_mat_prop_total;
      if (nvl(vn_vl_mat_terc_total, 0) + nvl(vn_vl_mat_prop_total, 0)) > 0 then
        --
        vn_vl_isnt := vn_vl_cont_total - vn_vl_mat_terc_total - vn_vl_mat_prop_total;
        --
      else
        --
        vn_vl_isnt := 0;
        --
      end if;
      --
      vn_vl_ded_bc  := vn_vl_mat_terc_total + vn_vl_mat_prop_total + vn_vl_sub + vn_vl_isnt; /* Somatória dos campos (B + C + D + E) */
      vn_vl_bc_iss  := abs(vn_vl_cont_total - vn_vl_ded_bc); /* Resultado da equação (A - F) */
      vn_vl_iss_rec := abs(vn_vl_iss_total - vn_vl_iss_rt_total - vn_vl_ded_total); /* Resultado da equação (I - J - K) */
      -- 
      vn_fase := 8;
      --
      update apur_iss
         set dm_situacao    = 1 /* Situação: 1-Gerado os dados */,
             vl_cont        = nvl(vn_vl_cont_total, 0),
             vl_mat_terc    = nvl(vn_vl_mat_terc_total, 0),
             vl_mat_prop    = nvl(vn_vl_mat_prop_total, 0),
             vl_sub         = nvl(vn_vl_sub, 0),
             vl_isnt        = nvl(vn_vl_isnt, 0),
             vl_ded_bc      = nvl(vn_vl_ded_bc, 0),
             vl_bc_iss      = nvl(vn_vl_bc_iss, 0),
             vl_bc_iss_rt   = nvl(vn_vl_bc_iss_rt_total, 0),
             vl_iss         = nvl(vn_vl_iss_total, 0),
             vl_iss_rt      = nvl(vn_vl_iss_rt_total, 0),
             vl_ded         = nvl(vn_vl_ded_total, 0),
             vl_iss_rec     = nvl(vn_vl_iss_rec, 0),
             vl_iss_st      = nvl(vn_vl_iss_st_total, 0),
             vl_iss_rec_uni = nvl(vn_vl_iss_rec_uni, 0)
       where id             = gt_row_apur_iss.id;
      --
      commit;
      --
    else
      --       
      vn_fase := 9;
      --      
      gv_resumo_log   := 'Erro ao gerar o registro de Apuração de ISS.';
      gv_mensagem_log := 'O registro não poderá ser gerado novamente. Favor exclui-lo para gerar os dados novamente.';
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => gt_row_apur_iss.id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --        
    end if;
    -- 
  else
    --     
    vn_fase := 10;
    --      
    gv_resumo_log   := 'Erro ao excluir o registro de Apuração de ISS.';
    gv_mensagem_log := 'O registro não pode excluido, pois já foi gerado o arquivo SPED ICMS/IPI.';
    --
    pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                     en_apuriss_id    => gt_row_apur_iss.id,
                     ev_resumo        => gv_resumo_log,
                     ev_mensagem      => gv_mensagem_log,
                     ev_usuario_id    => ev_usuario_id,
                     ev_maquina       => ev_maquina);
    --                      
  end if;
  --      
exception
  when others then
    --
    gv_mensagem_log := 'Erro em pk_apur_iss_blc_b.pkb_gerar_dados fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    begin
      update apur_iss
         set dm_situacao = 2 -- Erro na geração dos dados
       where id          = gt_row_apur_iss.id;
      commit;
    end;
    --      
    gv_resumo_log   := 'Erro em pk_apur_iss_blc_b.pkb_gerar_dados';
    gv_mensagem_log := 'Erro em pk_apur_iss_blc_b.pkb_gerar_dados fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    begin
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => gt_row_apur_iss.id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --
    exception
      when others then
        null;
    end;
    --
    raise_application_error(-20101, gv_mensagem_log);
    --   
end pkb_gerar_dados;

----------------------------------------------------------------------------------------------------------------------
/* Validar os valores dos campos que são fórmulas e/ou totalizadores. Verificar a definição funcional e o manual do Sped Fiscal. Essa validação irá envolver as informações da tabela DEDUCAO_ISS. */
----------------------------------------------------------------------------------------------------------------------
procedure pkb_validar(en_apuriss_id in apur_iss.id%type,
                      ev_usuario_id in log_apur_iss.usuario_id%type,
                      ev_maquina    in log_apur_iss.maquina%type) is
  ---
  vn_fase                 number;
  vn_escr_dfepoe          number;
  vn_vl_cont_total        nota_fiscal_total.vl_total_serv%type; /* A - Valor total referente às prestações de serviço do período*/
  vn_vl_mat_terc_total    item_nota_fiscal.vl_item_bruto%type; /* B - Valor total do material fornecido por terceiros na prestação do serviço*/
  vn_vl_mat_prop_total    item_nota_fiscal.vl_item_bruto%type; /* C - Valor do material próprio utilizado na prestação do serviço*/
  vn_vl_bc_iss_rt_total   imp_itemnf.vl_base_calc%type; /* H - Valor total da base de cálculo de retenção do ISS referente às prestações do declarante.*/
  vn_vl_iss_total         imp_itemnf.vl_imp_trib%type; /* I - Valor total do ISS destacado*/
  vn_vl_iss_rt_total      imp_itemnf.vl_imp_trib%type; /* J - Valor total do ISS retido pelo tomador nas prestações do declarante*/
  vn_vl_ded_total         nota_fiscal_total.vl_deducao%type; /* K - Valor total das deduções do ISS próprio */
  vn_vl_iss_st_total      imp_itemnf.vl_imp_trib%type; /* M - Valor total do ISS substituto a recolher pelas aquisições do declarante (tomador)*/
  vn_vl_ded_total_deducao deducao_iss.vl_ded%type;
  ---  
  vn_vl_sub_total         number(15, 2); /* D - Valor total das subempreitadas*/
  vn_vl_isnt_total        number(15, 2); /* E - Valor total das operações isentas ou não-tributadas pelo ISS - Resultado da equação (A - B - C)*/
  vn_vl_ded_bc_total      number(15, 2); /* F - Valor total das deduções da base de cálculo (B + C + D + E)  - Somatória dos campos (B + C + D + E)  */
  vn_vl_bc_iss_total      number(15, 2); /* G - Valor total da base de cálculo do ISS - Resultado da equação (A - F)*/
  vn_vl_iss_rec_total     number(15, 2); /* L - Valor total apurado do ISS próprio a recolher (I - J - K) - Resultado da equação (I - J - K)*/
  vn_vl_iss_rec_uni_total number(15, 2); /* N - Valor do ISS próprio a recolher pela Sociedade Uniprofissional*/
  vn_ok                   number(1); /*0 - ok / 1 - Nok*/
  vn_vl_bc_iss_rt         imp_itemnf.vl_base_calc%type;
  vn_vl_iss_rt            imp_itemnf.vl_imp_trib%type;
  vn_dm_situacao          apur_iss.dm_situacao%type;
  vn_logapuriss_id        log_apur_iss.id%type;
  vv_msg                  log_apur_iss.mensagem%type;
  --   
  vn_dm_mat_prop_terc   item_nota_fiscal.dm_mat_prop_terc%type;
  vn_vl_cont            nota_fiscal_total.vl_total_serv%type;
  -- 
  cursor c_ded_iss(vn_apuriss_id in deducao_iss.apuriss_id%type) is
    select di.* 
      from deducao_iss di 
     where di.apuriss_id = vn_apuriss_id;
  -- 
  cursor c_nf(v_empr_id           abertura_efd.empresa_id%type,
              v_dt_ini            date,
              v_dt_fim            date,
              v_dm_dt_escr_dfepoe number) is
    select nft.vl_total_serv as vl_cont,
           decode(nf.dm_ind_emit, 0, nft.vl_deducao, 0) as vl_ded,
           nf.id notafiscal_id,
           nf.dm_ind_emit,
           nft.vl_total_nf,
           nft.vl_serv_nao_trib,
           mf.cod_mod 
      from nota_fiscal       nf,
           pessoa            pe,
           mod_fiscal        mf,
           sit_docto         sd,
           nota_fiscal_total nft
     where nf.empresa_id      = v_empr_id
       and nf.sitdocto_id     = sd.id
       and nf.modfiscal_id    = mf.id
       and nft.notafiscal_id  = nf.id
       and nf.dm_arm_nfe_terc = 0
       and nf.dm_st_proc      in (4, 14)
       and mf.cod_mod         in ('01', '03', '3B', '04', '08', '55', '65','99')
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(v_dt_ini) and trunc(v_dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(v_dt_ini) and trunc(v_dt_fim))  
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and v_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(v_dt_ini) and trunc(v_dt_fim)) 
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and v_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between trunc(v_dt_ini) and trunc(v_dt_fim)))
       and pe.id              = nf.pessoa_id
       and exists ( select 1
                      from item_nota_fiscal inf,
                           imp_itemnf       iin,
                           tipo_imposto     ti
                     where inf.notafiscal_id = nf.id
                       and iin.itemnf_id(+)  = inf.id
                       and iin.tipoimp_id    = ti.id
                       and ti.cd             = 6 ); --ISS
    /*and not exists (select 1 
                        from pessoa_tipo_param pt,
                             tipo_param        tp,
                             valor_tipo_param  vt
                       where pt.pessoa_id    = pe.id
                         and tp.id           = pt.tipoparam_id
                         and tp.cd           = '13' -- Natureza/Setor da Pessoa
                         and vt.tipoparam_id = pt.tipoparam_id
                         and vt.id           = pt.valortipoparam_id
                         and vt.cd           = 1 -- Setor Publico */
  --
  cursor c_item_nf(v_notafiscal_id nota_fiscal.id%type) is
    select distinct decode(inf.dm_mat_prop_terc, 0, inf.vl_item_bruto, 0) as vl_mat_terc,
           decode(inf.dm_mat_prop_terc, 1, inf.vl_item_bruto, 0) as vl_mat_prop,
           case
             when nf.dm_ind_emit = 0 and iin.dm_tipo = 0 then
              nvl(iin.vl_imp_trib, 0)
           end vl_iss,
           case
             when nf.dm_ind_emit = 0 and iin.dm_tipo = 1 then
              nvl(iin.vl_base_calc, 0)
           end vl_base_calc_ret,
           case
             when nf.dm_ind_emit = 0 and iin.dm_tipo = 1 then
              nvl(iin.vl_imp_trib, 0)
           end vl_iss_ret,
           case
             when nf.dm_ind_emit = 1 and iin.dm_tipo = 1 then
              nvl(iin.vl_imp_trib, 0)
           end vl_iss_st,
           inf.id itemnf_id
      from nota_fiscal      nf,
           item_nota_fiscal inf,
           imp_itemnf       iin,
           tipo_imposto     ti
     where nf.id             = v_notafiscal_id
       and inf.notafiscal_id = nf.id
       and iin.itemnf_id(+)  = inf.id
       and iin.dm_tipo       in (0, 1) -- 0 - Imposto / 1 - Retenção 
       and iin.tipoimp_id    = ti.id
       and ti.cd             = 6; -- ISS
  --  
begin
  --
  vn_fase := 1;
  --
  pkb_dados_apur_iss(en_apuriss_id, ev_usuario_id, ev_maquina);
  --
  vn_vl_ded_total_deducao := 0;
  --
  if fkg_valida_deducao_iss(gt_row_apur_iss.id) > 0 then
    --    
    for rec_ded_iss in c_ded_iss(gt_row_apur_iss.id) loop
      exit when c_ded_iss%notfound or(c_ded_iss%notfound) is null;
      --
      vn_fase := 1.1;
      --
      /*0 - ok / 1 - Nok*/
      vn_ok  := 0;
      vv_msg := null;
      --           
      if rec_ded_iss.dm_ind_ded not in (0, 1, 2, 9) then
        vn_ok  := 1;
        vv_msg := 'Indicador do tipo de dedução só pode ter os seguintes valores: 0, 1, 2, 9';
      end if;
      --      
      vn_fase := 1.2;
      --
      if rec_ded_iss.dm_ind_obr not in (0, 1, 2) then
        --
        vn_ok := 1;
        --
        if vv_msg is null then
          --
          vv_msg := 'Indicador da origem do processo só pode ter os seguintes valores: 0, 1, 2, 9';
          --
        else
          --
          vv_msg := vv_msg || '; Indicador da origem do processo só pode ter os seguintes valores: 0, 1, 2, 9';
          --
        end if;
        --
      end if;
      --       
      vn_fase := 1.3;
      --
      if rec_ded_iss.dm_ind_proc not in (0, 1, 2, 9) then
        --
        vn_ok := 1;
        --
        if vv_msg is null then
          --
          vv_msg := 'Indicador da obrigação só pode ter os seguintes valores: 0, 1, 2';
          --
        else
          --
          vv_msg := vv_msg || '; Indicador da obrigação só pode ter os seguintes valores: 0, 1, 2';
          --
        end if;
        --
      end if;
      --         
      vn_fase := 1.4;
      --
      if nvl(rec_ded_iss.vl_ded, 0) < 0 then
        --
        vn_ok := 1;
        --
        if vv_msg is null then
          --
          vv_msg := 'Valor da dedução não pode ser negativo';
          --
        else
          --
          vv_msg := vv_msg || '; Valor da dedução não pode ser negativo';
          --
        end if;
        --
      end if;
      --
      vn_fase := 1.5;
      --
      vn_vl_ded_total_deducao := vn_vl_ded_total_deducao + rec_ded_iss.vl_ded;
      --      
      vn_fase := 1.6;
      --
      if vn_ok = 1 then
        --
        gv_resumo_log   := 'Erro de validação na dedução de ISS.';
        gv_mensagem_log := 'Verificar os seguintes valores: ' || vv_msg;
        -- 
      elsif vn_ok = 0 then
        --
        gv_resumo_log   := 'Validação na dedução de ISS OK.';
        gv_mensagem_log := 'Validação na dedução de ISS OK.';
        --                                      
      end if;
      --       
      vn_fase := 1.7;
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => gt_row_apur_iss.id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --
    end loop; --c_ded_iss  
    -- 
  else
    --    
    vn_fase := 1.8;
    --
    gv_resumo_log := 'Não foi encontrado registro de Dedução de ISS associado a Apuração';
    --
    gv_mensagem_log := 'Não foi encontrado registro de Dedução de ISS associado a Apuração.';
    --
    pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                     en_apuriss_id    => gt_row_apur_iss.id,
                     ev_resumo        => gv_resumo_log,
                     ev_mensagem      => gv_mensagem_log,
                     ev_usuario_id    => ev_usuario_id,
                     ev_maquina       => ev_maquina);
    --                        
  end if;
  --  
  vn_fase := 2;
  --
  vn_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa(en_empresa_id => gt_row_apur_iss.empresa_id);
  --   
  vn_fase                 := 3;
  vn_ok                   := 0;
  vn_dm_situacao          := 0;
  vn_vl_cont_total        := 0;
  vn_vl_mat_terc_total    := 0;
  vn_vl_mat_prop_total    := 0;
  vn_vl_bc_iss_rt_total   := 0;
  vn_vl_iss_total         := 0;
  vn_vl_iss_rt_total      := 0;
  vn_vl_ded_total         := 0;
  vn_vl_iss_st_total      := 0;
  vn_VL_SUB_total         := 0;
  vn_VL_ISNT_total        := 0;
  vn_VL_DED_BC_total      := 0;
  vn_VL_BC_ISS_total      := 0;
  vn_VL_ISS_REC_total     := 0;
  vn_VL_ISS_REC_UNI_total := 0;
  vv_msg                  := null;
  --      
  vn_fase := 4;
  --
  for rec_nf in c_nf(gt_row_apur_iss.empresa_id,
                     gt_row_apur_iss.dt_inicio,
                     gt_row_apur_iss.dt_fim,
                     vn_escr_dfepoe) loop
    exit when c_nf%notfound or(c_nf%notfound) is null;
    --   
    vn_fase := 4.1;
    --  
    begin        
        select distinct inf.dm_mat_prop_terc 
        into vn_dm_mat_prop_terc
       from item_nota_fiscal inf 
       where inf.notafiscal_id = rec_nf.notafiscal_id;  
    exception 
     when others then
      null;
    end;
    --
    vn_vl_cont:= nvl(rec_nf.vl_cont, 0);
    --
    if rec_nf.cod_mod = '99' and nvl(vn_dm_mat_prop_terc,0) = 0
      then 
       vn_vl_cont := 0; 
    end if;
    --  
    vn_vl_cont_total := vn_vl_cont_total + vn_vl_cont; /* A*/
    --vn_vl_cont_total := vn_vl_cont_total + nvl(rec_nf.vl_cont, 0); /* A */
    vn_vl_ded_total  := vn_vl_ded_total + nvl(rec_nf.vl_ded, 0); /* K */
    --  
    for rec_item_nf in c_item_nf(rec_nf.notafiscal_id) loop
      exit when c_item_nf%notfound or(c_item_nf%notfound) is null;
      --
      vn_fase := 6.2;
      --      
      vn_vl_bc_iss_rt := 0;
      vn_vl_iss_rt    := 0;
      --
      /*begin
        select nvl(iin.vl_base_calc, 0), 
               nvl(iin.vl_imp_trib, 0)
          into vn_vl_bc_iss_rt, 
               vn_vl_iss_rt
          from imp_itemnf iin, 
               tipo_imposto ti
         where iin.itemnf_id  = rec_item_nf.itemnf_id
           and iin.dm_tipo    = 1 -- Retenção
           and iin.tipoimp_id = ti.id
           and ti.cd          = 6; -- ISS
      exception
        when others then
          vn_vl_bc_iss_rt := 0;
          vn_vl_iss_rt    := 0;
      end;*/
      --
      vn_vl_mat_terc_total  := 0; --vn_vl_mat_terc_total + nvl(rec_item_nf.vl_mat_terc, 0); /* B */  -- Consultor José Hipolito solicitou zerar
      vn_vl_mat_prop_total  := 0; --vn_vl_mat_prop_total + nvl(rec_item_nf.vl_mat_prop, 0); /* C */  -- Consultor José Hipolito solicitou zerar
      vn_vl_bc_iss_rt_total := vn_vl_bc_iss_rt_total + nvl(rec_item_nf.vl_base_calc_ret, 0); /* H */
      vn_vl_iss_total       := vn_vl_iss_total + nvl(rec_item_nf.vl_iss, 0); /* I */
      vn_vl_iss_rt_total    := vn_vl_iss_rt_total + nvl(rec_item_nf.vl_iss_ret, 0); /* J */
      vn_vl_iss_st_total    := vn_vl_iss_st_total + nvl(rec_item_nf.vl_iss_st, 0); /* N */
    --
    end loop; -- c_item_nf
  --
  end loop; --c_nf
  --   
  vn_fase := 5;
  --
  --vn_vl_isnt_total    := abs(vn_vl_cont_total - vn_vl_mat_terc_total - vn_vl_mat_prop_total); /*Resultado da equação (A - B - C) */
  if (nvl(vn_vl_mat_terc_total, 0) + nvl(vn_vl_mat_prop_total, 0)) > 0 then
    --
    vn_vl_isnt_total := vn_vl_cont_total - vn_vl_mat_terc_total - vn_vl_mat_prop_total;
    --
  else
    --
    vn_vl_isnt_total := 0;
    --
  end if;
  --
  vn_vl_ded_bc_total  := vn_vl_mat_terc_total + vn_vl_mat_prop_total + vn_vl_sub_total + vn_vl_isnt_total; /* Somatória dos campos (B + C + D + E) */
  vn_vl_bc_iss_total  := abs(vn_vl_cont_total - vn_vl_ded_bc_total); /* Resultado da equação (A - F) */
  vn_vl_iss_rec_total := abs(vn_vl_iss_total - vn_vl_iss_rt_total - vn_vl_ded_total); /* Resultado da equação (I - J - K) */
  -- 
  vn_fase := 6;
  --
  /* Valor total referente às prestações de serviço do período */
  if gt_row_apur_iss.vl_cont <> vn_vl_cont_total then
    --     
    vn_ok  := 1;
    vv_msg := 'Valor total referente às prestações de serviço do período';
    --     
  end if;
  --    
  vn_fase := 7;
  --
  /* Valor total do material fornecido por terceiros na prestação do serviço */
  if gt_row_apur_iss.vl_mat_terc <> vn_vl_mat_terc_total then
    --     
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total do material fornecido por terceiros na prestação do serviço';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total do material fornecido por terceiros na prestação do serviço';
      --
    end if;
    --     
  end if;
  --     
  vn_fase := 8;
  --
  /* Valor do material próprio utilizado na prestação do serviço */
  if gt_row_apur_iss.vl_mat_prop <> vn_vl_mat_prop_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor do material próprio utilizado na prestação do serviço';
      --
    else
      --
      vv_msg := vv_msg || '; Valor do material próprio utilizado na prestação do serviço';
      --
    end if;
    --           
  end if;
  --    
  vn_fase := 9;
  --
  /* Valor total das subempreitadas */
  if gt_row_apur_iss.vl_sub <> vn_vl_sub_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total das subempreitadas';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total das subempreitadas';
      --
    end if;
    --   
  end if;
  --    
  vn_fase := 10;
  --
  /* Valor total das operações isentas ou não-tributadas pelo ISS */
  if gt_row_apur_iss.vl_isnt <> vn_VL_ISNT_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total das operações isentas ou não-tributadas pelo ISS';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total das operações isentas ou não-tributadas pelo ISS';
      --
    end if;
    --  
  end if;
  --    
  vn_fase := 11;
  --
  /* Valor total das deduções da base de cálculo */
  if gt_row_apur_iss.vl_ded_bc <> vn_vl_ded_bc_total then  
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total das deduções da base de cálculo';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total das deduções da base de cálculo';
      --
    end if;
    --  
  end if;
  --    
  vn_fase := 12;
  --
  /* Valor total da base de cálculo do ISS */
  if gt_row_apur_iss.vl_bc_iss <> vn_vl_bc_iss_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total da base de cálculo do ISS';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total da base de cálculo do ISS';
      --
    end if;
    -- 
  end if;
  --    
  vn_fase := 13;
  --
  /* Valor total da base de cálculo de retenção do ISS referente às prestações do declarante. */
  if gt_row_apur_iss.vl_bc_iss_rt <> vn_vl_bc_iss_rt_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total da base de cálculo de retenção do ISS referente às prestações do declarante';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total da base de cálculo de retenção do ISS referente às prestações do declarante';
      --
    end if;
    -- 
  end if;
  --    
  vn_fase := 14;
  --
  /* Valor total do ISS destacado */
  if gt_row_apur_iss.vl_iss <> vn_vl_iss_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total do ISS destacado';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total do ISS destacado';
      --
    end if;
    -- 
  end if;
  --    
  vn_fase := 15;
  --
  /* Valor total do ISS retido pelo tomador nas prestações do declarante */
  if gt_row_apur_iss.vl_iss_rt <> vn_vl_iss_rt_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total do ISS retido pelo tomador nas prestações do declarante';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total do ISS retido pelo tomador nas prestações do declarante';
      --
    end if;
    --
  end if;
  --    
  vn_fase := 16;
  --
  /* Valor total das deduções do ISS próprio */
  if gt_row_apur_iss.vl_ded <> vn_vl_ded_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total das deduções do ISS próprio';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total das deduções do ISS próprio';
      --
    end if;
    --
  end if;
  --    
  vn_fase := 17;
  --
  /* Valor total apurado do ISS próprio a recolher */
  if gt_row_apur_iss.VL_ISS_REC <> vn_vl_iss_rec_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total apurado do ISS próprio a recolher';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total apurado do ISS próprio a recolher';
      --
    end if;
    --
  end if;
  --    
  vn_fase := 18;
  --
  /* Valor total do ISS substituto a recolher pelas aquisições do declarante (tomador) */
  if gt_row_apur_iss.vl_iss_st <> vn_vl_iss_st_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total do ISS substituto a recolher pelas aquisições do declarante (tomador)';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total do ISS substituto a recolher pelas aquisições do declarante (tomador)';
      --
    end if;
    --
  end if;
  --    
  vn_fase := 19;
  --
  /* Valor do ISS próprio a recolher pela Sociedade Uniprofissional */
  if gt_row_apur_iss.vl_iss_rec_uni <> vn_vl_iss_rec_uni_total then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor do ISS próprio a recolher pela Sociedade Uniprofissional';
      --
    else
      --
      vv_msg := vv_msg || '; Valor do ISS próprio a recolher pela Sociedade Uniprofissional';
      --
    end if;
    --
  end if;
  --   
  vn_fase := 20;
  --
  /* Valor total das deduções do ISS próprio - comparação entre B470 e B460. */
  if gt_row_apur_iss.vl_ded <> vn_vl_ded_total_deducao then
    --       
    vn_ok := 1;
    --
    if vv_msg is null then
      --
      vv_msg := 'Valor total das deduções do ISS próprio na Apuração de ISS está diferente do valor na Dedução de ISS';
      --
    else
      --
      vv_msg := vv_msg || '; Valor total das deduções do ISS próprio na Apuração de ISS está diferente do valor na Dedução de ISS';
      --
    end if;
    --
  end if;
  --      
  vn_fase := 21;
  --
  /*0 - ok / 1 - Nok*/
  if vn_ok = 0 then
    --     
    vn_dm_situacao := 3; /*3-Validada*/
    --      
    gv_resumo_log   := 'Validação na apuração de ISS OK.';
    gv_mensagem_log := 'Validação na apuração de ISS OK.';
    --       
  elsif vn_ok = 1 then
    --   
    vn_dm_situacao := 4; /*4-Erro de validação*/
    --      
    gv_resumo_log   := 'Erro de validação na apuração de ISS.';
    gv_mensagem_log := 'Verificar os seguintes valores: ' || vv_msg;
    --      
  end if;
  --  
  vn_fase := 22;
  --
  /*Situação (dm_situacao): 0-Aberta; 1-Gerado os dados; 2-Erro na geração dos dados; 3-Validada; 4-Erro de validação.*/
  update apur_iss
     set dm_situacao = vn_dm_situacao
   where id          = gt_row_apur_iss.id;
  --
  commit;
  --
  vn_fase := 23;
  --
  pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                   en_apuriss_id    => gt_row_apur_iss.id,
                   ev_resumo        => gv_resumo_log,
                   ev_mensagem      => gv_mensagem_log,
                   ev_usuario_id    => ev_usuario_id,
                   ev_maquina       => ev_maquina);
  --
exception
  when others then
    --
    gv_mensagem_log := 'Erro em pk_apur_iss_blc_b.pkb_validar fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    update apur_iss
       set dm_situacao = 4 /*4-Erro de validação*/
     where id          = gt_row_apur_iss.id;
    commit;
    --      
    gv_resumo_log   := 'Erro em pk_apur_iss_blc_b.pkb_validar';
    gv_mensagem_log := 'Erro em pk_apur_iss_blc_b.pkb_validar fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    begin
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => gt_row_apur_iss.id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --
    exception
      when others then
        null;
    end;
    --
    raise_application_error(-20101, gv_mensagem_log);
    --   
end pkb_validar;
----------------------------------------------------------------------------------------------------------------------
/*Verificar a situação atual e voltar para anterior, alterando as informações das tabelas de Apuração do ISS.*/
procedure pkb_desfazer(en_apuriss_id in apur_iss.id%type,
                       ev_usuario_id in log_apur_iss.usuario_id%type,
                       ev_maquina    in log_apur_iss.maquina%type) is
  --
  vn_fase          number;
  vn_logapuriss_id log_apur_iss.id%type;
  --
begin
  --
  vn_fase := 1;
  --
  pkb_dados_apur_iss(en_apuriss_id, EV_USUARIO_ID, EV_MAQUINA);
  --
  vn_fase := 2;
  --
  /*Situação (dm_situacao): 0 - Aberta; 1 - Gerado os dados; 2 - Erro na geração dos dados; 3 - Validada; 4 - Erro de validação.*/
  if gt_row_apur_iss.dm_situacao = 1 then -- 1 - Gerado os dados*/
    --
    update apur_iss
       set dm_situacao    = 0, -- 0 - Aberta
           vl_cont        = null,
           vl_mat_terc    = null,
           vl_mat_prop    = null,
           vl_sub         = null,
           vl_isnt        = null,
           vl_ded_bc      = null,
           vl_bc_iss      = null,
           vl_bc_iss_rt   = null,
           vl_iss         = null,
           vl_iss_rt      = null,
           vl_ded         = null,
           vl_iss_rec     = null,
           vl_iss_st      = null,
           vl_iss_rec_uni = null
     where id             = gt_row_apur_iss.id;
    --     
    delete 
      from r_apuriss_nf 
     where apuriss_id = gt_row_apur_iss.id;
    --     
    delete 
      from log_apur_iss
     where apuriss_id = gt_row_apur_iss.id;
    --     
  end if;
  --  
  vn_fase := 3;
  --
  if gt_row_apur_iss.dm_situacao = 2 then -- 2 - Erro na geração dos dados
    -- 
    update apur_iss
       set dm_situacao = 0 -- 0 - Aberta
     where id          = gt_row_apur_iss.id;  
    --       
  end if;
  --
  vn_fase := 4;
  --
  if gt_row_apur_iss.dm_situacao = 3 then -- 3 - Validada
    --        
    update apur_iss
       set dm_situacao = 1 -- 1 - Gerado os dados
     where id          = gt_row_apur_iss.id;
    --          
  end if;
  --  
  vn_fase := 5;
  --
  if gt_row_apur_iss.dm_situacao = 4 then -- 4 - Erro de validação.
    --         
    update apur_iss
       set dm_situacao = 1 -- 1 - Gerado os dados
     where id          = gt_row_apur_iss.id;
    --          
  end if;
  ---    
  commit;
  --    
exception
  when others then
    --
    gv_mensagem_log := 'Erro em pk_apur_iss_blc_b.pkb_desfazer fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    update apur_iss
       set dm_situacao = 4 /*4-Erro de validação*/
     where id          = gt_row_apur_iss.id;
    commit;
    --      
    gv_resumo_log   := 'Erro em pk_apur_iss_blc_b.pkb_desfazer';
    gv_mensagem_log := 'Erro em pk_apur_iss_blc_b.pkb_desfazer fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    begin
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => gt_row_apur_iss.id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --
    exception
      when others then
        null;
    end;
    --
    raise_application_error(-20101, gv_mensagem_log);
    --      
end pkb_desfazer;
----------------------------------------------------------------------------------------------------------------------
/*Excluir os registros da tabela APUR_ISS, desde que não tenha arquivo gerado no mesmo período, tabela ABERTURA_EFD.*/
procedure pkb_excluir_apur(en_apuriss_id in apur_iss.id%type,
                           ev_usuario_id in log_apur_iss.usuario_id%type,
                           ev_maquina    in log_apur_iss.maquina%type) is
  --  
  vn_fase          number;
  vn_valid         number;
  vn_logapuriss_id log_apur_iss.id%type;
  --   
begin
  --
  vn_fase := 1;
  --
  pkb_dados_apur_iss(en_apuriss_id, EV_USUARIO_ID, EV_MAQUINA);
  --  
  if fkg_valida_efd_abertura(gt_row_apur_iss.empresa_id, gt_row_apur_iss.dt_inicio, gt_row_apur_iss.dt_fim) = 0 then
    --    
    vn_fase := 2;
    --
    delete from r_apuriss_nf where apuriss_id = gt_row_apur_iss.id;
    --
    vn_fase := 3;
    --
    delete from deducao_iss where apuriss_id = gt_row_apur_iss.id;
    --
    vn_fase := 4;
    --
    delete from log_apur_iss where apuriss_id = gt_row_apur_iss.id;
    --
    vn_fase := 5;
    --
    delete from apur_iss where id = gt_row_apur_iss.id;
    --    
    commit;
    --  
  else
    --
    vn_fase := 3;
    --      
    gv_resumo_log   := 'Erro ao excluir o registro de Apuração de ISS.';
    gv_mensagem_log := 'O registro não pode excluido, pois já foi gerado o arquivo SPED ICMS/IPI.';
    --
    pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                     en_apuriss_id    => gt_row_apur_iss.id,
                     ev_resumo        => gv_resumo_log,
                     ev_mensagem      => gv_mensagem_log,
                     ev_usuario_id    => ev_usuario_id,
                     ev_maquina       => ev_maquina);
    --                      
  end if;
  -- 
exception
  when others then
    --     
    rollback;
    --
    update apur_iss
       set dm_situacao = 4 /*4-Erro de validação*/
     where id          = gt_row_apur_iss.id;
    commit;
    --      
    gv_resumo_log   := 'Erro em pk_apur_iss_blc_b.en_deducaoiss_id';
    gv_mensagem_log := 'Erro em pk_apur_iss_blc_b.en_deducaoiss_id fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    begin
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => gt_row_apur_iss.id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --
    exception
      when others then
        null;
    end;
    --
    raise_application_error(-20101, gv_mensagem_log);
    --      
end pkb_excluir_apur;
----------------------------------------------------------------------------------------------------------------------
/*Excluir os registros da tabela e DEDUCAO_ISS, desde que não tenha arquivo gerado no mesmo período, tabela ABERTURA_EFD.*/
procedure pkb_excluir_ded(en_deducaoiss_id in deducao_iss.id%type,
                          ev_usuario_id    in log_apur_iss.usuario_id%type,
                          ev_maquina       in log_apur_iss.maquina%type) is
  -- 
  vn_fase          number;
  vn_apuriss_id    apur_iss.id%type;
  vn_logapuriss_id log_apur_iss.id%type;
  --
begin
  --
  vn_fase       := 1;
  --
  vn_apuriss_id := 0;
  --
  begin   
    select apuriss_id
      into vn_apuriss_id
      from deducao_iss
     where id = en_deducaoiss_id;
  exception
    when no_data_found then
      vn_apuriss_id := 0;
  end;
  -- 
  vn_fase := 2;
  --
  if vn_apuriss_id <> 0 then
    --    
    vn_fase := 3;
    --
    pkb_dados_apur_iss(vn_apuriss_id, EV_USUARIO_ID, EV_MAQUINA);
    --
    vn_fase := 4;
    --
    if fkg_valida_efd_abertura(gt_row_apur_iss.empresa_id, gt_row_apur_iss.dt_inicio, gt_row_apur_iss.dt_fim) = 0 then
      --
      vn_fase := 5;
      --
      delete 
        from deducao_iss 
       where id = en_deducaoiss_id;
      commit;
      --   
    else
      -- 
      vn_fase         := 6;
      gv_resumo_log   := 'Erro ao excluir o registro de Apuração de ISS.';
      gv_mensagem_log := 'O registro não pode excluido, pois já foi gerado o arquivo SPED ICMS/IPI.';
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => gt_row_apur_iss.id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --   
    end if;
    --   
  else
    --    
    vn_fase         := 7;
    --
    gv_mensagem_log := 'O ID da tabela de Apuração de ISS não foi encontrado.';
    raise_application_error(-20101, gv_mensagem_log);
    --      
  end if;
  --     
exception
  when others then
    --
    rollback;
    --
    update apur_iss
       set dm_situacao = 4 /*4-Erro de validação*/
     where id          = gt_row_apur_iss.id;
    commit;
    --      
    gv_resumo_log   := 'Erro em pk_apur_iss_blc_b.pkb_excluir_ded';
    gv_mensagem_log := 'Erro em pk_apur_iss_blc_b.pkb_excluir_ded fase ( ' || vn_fase || ' ):' || sqlerrm;
    --
    begin
      --
      pkb_log_apur_iss(sn_logapuriss_id => vn_logapuriss_id,
                       en_apuriss_id    => gt_row_apur_iss.id,
                       ev_resumo        => gv_resumo_log,
                       ev_mensagem      => gv_mensagem_log,
                       ev_usuario_id    => ev_usuario_id,
                       ev_maquina       => ev_maquina);
      --
    exception
      when others then
        null;
    end;
    --
    raise_application_error(-20101, gv_mensagem_log);
    --     
end pkb_excluir_ded;
----------------------------------------------------------------------------------------------------------------------
end pk_apur_iss_blc_b;
/
