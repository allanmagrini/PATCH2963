create or replace package body csf_own.pk_csf_api_sc is

----------------------------------------------------------------------------
-- Função para verificar se existe registro de erro grvados no Log Generico
----------------------------------------------------------------------------
function fkg_ver_erro_log_generico_nfsc ( en_nota_fiscal_id in nota_fiscal.id%type )
        return number
is
  --
  vn_qtde      number := 0;
  --
begin
  --
  select count(1)
    into vn_qtde 
    from log_generico_nf ln,
         csf_tipo_log tc
   where ln.referencia_id = en_nota_fiscal_id        
     and tc.id = ln.csftipolog_id -- #73332
     and tc.dm_grau_sev   = 1;  -- erro 
  --
  if nvl(vn_qtde,0) > 0 then
     return 1;  -- erro
  else
     return 0;  -- só aviso/informação
  end if;   
  --
exception
  when no_data_found then
     return 0;
  when others then
     raise_application_error(-20101, 'Problemas em fkg_ver_erro_log_generico_nfsc. Erro = '||sqlerrm);
end fkg_ver_erro_log_generico_nfsc;

----------------------------------------------------------------
-- Procedimento que insere os dados adicionais da nota fiscal --
----------------------------------------------------------------
PROCEDURE PKB_INTEGR_NFINFOR_ADIC(EST_LOG_GENERICO_NF  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                ,EST_ROW_NFINFOR_ADIC IN OUT NOCOPY NFINFOR_ADIC%ROWTYPE
                                ,EN_CD_ORIG_PROC      IN ORIG_PROC.CD%TYPE DEFAULT NULL) IS
  --
  vn_fase               number := 0;
  vn_loggenerico_id     log_generico_nf.id%type;
  vn_dm_limpa_inf_compl number := 0;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(est_row_NFInfor_Adic.notafiscal_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 1.1;
     --
     gv_mensagem_log := 'Não informada a Nota Fiscal para relacionar as informações Adicionais.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 2;
  --
  if est_row_NFInfor_Adic.dm_tipo not in (0, 1, 2) then
     --
     vn_fase := 2.1;
     --
     gv_mensagem_log := '"Indicador do emitente da informação Complementar da Nota Fiscal" ('||est_row_NFInfor_Adic.dm_tipo||') está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  else
     --
     vn_fase := 2.2;
     --
     gv_dominio := null;
     --
     gv_dominio := pk_csf.fkg_dominio(ev_dominio => 'NFINFOR_ADIC.DM_TIPO'
                                     ,ev_vl      => est_row_NFInfor_Adic.dm_tipo);
     --
  end if;
  --
  vn_fase := 3;
  --
  if trim(est_row_NFInfor_Adic.campo) = '0' then
     --
     est_row_NFInfor_Adic.campo := null;
     --
  end if;
  --
  vn_fase := 4;
  -- Contribuinte
  if est_row_NFInfor_Adic.dm_tipo = 0 then
     -- Contribuinte
     --
     vn_fase := 4.1;
     --
     if trim(est_row_NFInfor_Adic.campo) is null then
        --
        vn_fase := 4.2;
        --
        if nvl(length(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1))),0) > 4000 then
           --
           vn_fase := 4.3;
           --
           gv_mensagem_log := 'Informações Complementares de interesse do Contribuinte ('||gv_dominio||') não podem ser maiores que 4000 caracteres.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        elsif trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1)) is null then
           --
           vn_fase := 4.4;
           --
           gv_mensagem_log := '"Informações Complementares da NF-e" de interesse do Contribuinte ('||est_row_NFInfor_Adic.conteudo||
                              ') não foi informada. Exemplo: Pedido de Venda, observações da nota, Dispositivo legal, etc.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        if length(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1))) < 10 then
           --
           vn_fase := 4.5;
           --
           gv_mensagem_log := '"Informações Complementares da NF-e" de interesse do Contribuinte ('||est_row_NFInfor_Adic.conteudo||
                              ') deve ter no mínimo 10 caracteres.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
     elsif trim(est_row_NFInfor_Adic.campo) is not null then
        --
        vn_fase := 4.6;
        --
        if nvl(length(est_row_NFInfor_Adic.campo), 0) > 20 then
           --
           vn_fase := 4.7;
           --
           gv_mensagem_log := '"Identificação do campo ('||gv_dominio||') não pode ser maior que 20 caracteres.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        vn_fase := 4.8;
        --
        if nvl(length(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1))),0) > 60 then
           --
           vn_fase := 4.9;
           --
           gv_mensagem_log := '"Conteúdo do campo ('||gv_dominio||') não pode ser maior que 60 caracteres.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        elsif trim(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1 ))) is null then
           --
           vn_fase := 4.10;
           --
           gv_mensagem_log := '"Conteúdo do campo ('||gv_dominio||') não pode ser nulo.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
     end if;
     --
  elsif est_row_NFInfor_Adic.dm_tipo = 1 then
     -- Fisco
     --
     vn_fase := 5.1;
     --
     if trim(est_row_NFInfor_Adic.campo) is null then
        --
        vn_fase := 5.2;
        --
        if nvl(length(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1 ))),0) > 2000 then
           --
           vn_fase := 5.3;
           --
           gv_mensagem_log := '"Informações Complementares de interesse do Fisco não podem ser maiores que 2000 caracteres.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        elsif trim(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1 ))) is null then
           --
           vn_fase := 5.4;
           --
           gv_mensagem_log := 'Informações Complementares de interesse do Fisco não foram informadas.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
     elsif trim(est_row_NFInfor_Adic.campo) is not null then
        --
        vn_fase := 5.5;
        --
        if nvl(length(est_row_NFInfor_Adic.campo), 0) > 20 then
           --
           vn_fase := 5.6;
           --
           gv_mensagem_log := '"Identificação do campo ('||gv_dominio||') não pode ser maior que 20 caracteres.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        vn_fase := 5.7;
        --
        if nvl(length(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1 ))),0) > 60 then
           --
           vn_fase := 5.8;
           --
           gv_mensagem_log := '"Conteúdo do campo ('||gv_dominio||') não pode ser maior que 60 caracteres.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        elsif trim(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1 ))) is null then
           --
           vn_fase := 5.9;
           --
           gv_mensagem_log := '"Conteúdo do campo ('||gv_dominio||') não pode ser nulo.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
     end if;
     --
  elsif est_row_NFInfor_Adic.dm_tipo = 2 then
     -- Processo
     --
     vn_fase := 6.1;
     --
     est_row_NFInfor_Adic.origproc_id := pk_csf.fkg_Orig_Proc_id(en_cd => en_cd_orig_proc);
     --
     vn_fase := 6.2;
     -- Valida a informação da origem do processo
     if nvl(est_row_NFInfor_Adic.origproc_id, 0) = 0 then
        --
        vn_fase := 6.3;
        --
        gv_mensagem_log := 'Código da Origem do Processo ('||en_cd_orig_proc||') está inválido.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
     vn_fase := 6.4;
     --
     if nvl(length(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1 ))),0) > 60 then
        --
        vn_fase := 6.5;
        --
        gv_mensagem_log := 'Número do processo não pode ser maior que 60 caracteres.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     elsif trim(trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1 ))) is null then
        --
        vn_fase := 6.6;
        --
        gv_mensagem_log := 'Número do processo não pode ser nulo.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 7;
  --
  -- Se não existe registro de Log e o Tipo de Integracao  1 (valida e insere)
  -- entao registra a informação Adicional da Nota Fiscal
  if nvl(est_log_generico_nf.count, 0) > 0 and 
     fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => est_row_NFInfor_Adic.notafiscal_id ) = 1 then
     --
     update nota_fiscal
        set dm_st_proc = 10
      where id = est_row_NFInfor_Adic.notafiscal_id;
     --
  end if;
  --
  vn_fase := 8;
  --
  est_row_NFInfor_Adic.campo := trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.campo));
  --
  begin
     --
     select e.dm_limpa_inf_compl
       into vn_dm_limpa_inf_compl
       from empresa e
      where e.id = gt_row_nota_fiscal.empresa_id;
     --
  exception
     when others then
        --
        vn_dm_limpa_inf_compl := 0;
        --
  end;
  --
  if vn_dm_limpa_inf_compl = 1 then
     -- SIM
     --
     est_row_NFInfor_Adic.conteudo := trim(pk_csf.fkg_converte(est_row_NFInfor_Adic.conteudo, 0, 1, 2, 1, 1 ));
     --
  else
     --
     est_row_NFInfor_Adic.conteudo := trim(pk_csf.fkg_converte( ev_string           => est_row_NFInfor_Adic.conteudo
                                                              , en_remove_spc_extra => 0
                                                              , en_ret_carac_espec  => 2 ));
     --
  end if;
  --
  vn_fase := 9;
  --
  if nvl(est_row_NFInfor_Adic.notafiscal_id, 0) > 0 and
     est_row_NFInfor_Adic.dm_tipo in (0, 1, 2) then
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 10;
        --
        select NFInforAdic_seq.nextval
          into est_row_NFInfor_Adic.id
          from dual;
        --
        vn_fase := 11;
        --
        insert into NFInfor_Adic
           (id
           ,notafiscal_id
           ,dm_tipo
           ,infcompdctofis_id
           ,campo
           ,conteudo
           ,origproc_id)
        values
           (est_row_NFInfor_Adic.id
           ,est_row_NFInfor_Adic.notafiscal_id
           ,est_row_NFInfor_Adic.dm_tipo
           ,est_row_NFInfor_Adic.infcompdctofis_id
           ,est_row_NFInfor_Adic.campo
           ,est_row_NFInfor_Adic.conteudo
           ,est_row_NFInfor_Adic.origproc_id);
        --
     else
        --
        vn_fase := 12;
        --
        update NFInfor_Adic
           set dm_tipo           = est_row_NFInfor_Adic.dm_tipo
              ,infcompdctofis_id = est_row_NFInfor_Adic.infcompdctofis_id
              ,campo             = est_row_NFInfor_Adic.campo
              ,conteudo          = est_row_NFInfor_Adic.conteudo
              ,origproc_id       = est_row_NFInfor_Adic.origproc_id
         where id = est_row_NFInfor_Adic.id;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_NFInfor_Adic fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFINFOR_ADIC;
------------------------------------------------------
-- Atualiza as informações complementares de cofins --
------------------------------------------------------
PROCEDURE PKB_INTEGR_NFCOMPLOPERCOF_FF(EST_LOG_GENERICO_NF     IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                     ,EN_NFCOMPLOPERCOFINS_ID IN NF_COMPL_OPER_COFINS.ID%TYPE
                                     ,EV_ATRIBUTO             IN VARCHAR2
                                     ,EV_VALOR                IN VARCHAR2
                                     ,EN_MULTORG_ID           IN MULT_ORG.ID%TYPE) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  vv_mensagem       varchar2(1000) := null;
  vn_dmtipocampo    ff_obj_util_integr.dm_tipo_campo%type;
  vn_cod_nat_rec_pc nat_rec_pc.cod%type := 0;
  vn_codst_id       cod_st.id%type := 0;
  vn_natrecpc_id    nat_rec_pc.id%type := 0;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if trim(ev_atributo) is null then
     --
     vn_fase := 2;
     --
     gv_mensagem_log := 'Informações Complementares de Cofins: "Atributo" deve ser informado.';
     --
     vn_loggenerico_id := null;
     --
     pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                   ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   ,ev_resumo           => gv_mensagem_log
                                   ,en_tipo_log         => erro_de_validacao
                                   ,en_referencia_id    => gn_referencia_id
                                   ,ev_obj_referencia   => gv_obj_referencia);
     --
     -- Armazena o "loggenerico_id" na memoria
     pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                      ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  --
  if trim(ev_valor) is null then
     --
     vn_fase := 4;
     --
     gv_mensagem_log := 'Informações Complementares de Cofins: "VALOR" referente ao atributo deve ser informado.';
     --
     vn_loggenerico_id := null;
     --
     pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                   ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   ,ev_resumo           => gv_mensagem_log
                                   ,en_tipo_log         => erro_de_validacao
                                   ,en_referencia_id    => gn_referencia_id
                                   ,ev_obj_referencia   => gv_obj_referencia);
     --
     -- Armazena o "loggenerico_id" na memoria
     pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                      ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 5;
  --
  vv_mensagem := pk_csf.fkg_ff_verif_campos(ev_obj_name => 'VW_CSF_NFCOMPLOPERCOFINS_FF'
                                           ,ev_atributo => trim(ev_atributo)
                                           ,ev_valor    => trim(ev_valor));
  --
  vn_fase := 6;
  --
  if vv_mensagem is not null then
     --
     vn_fase := 7;
     --
     gv_mensagem_log := vv_mensagem;
     --
     vn_loggenerico_id := null;
     --
     pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                   ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   ,ev_resumo           => gv_mensagem_log
                                   ,en_tipo_log         => erro_de_validacao
                                   ,en_referencia_id    => gn_referencia_id
                                   ,ev_obj_referencia   => gv_obj_referencia);
     --
     -- Armazena o "loggenerico_id" na memoria
     pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                      ,est_log_generico_nf => est_log_generico_nf);
     --
  else
     --
     vn_fase := 8;
     --
     vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo(ev_obj_name => 'VW_CSF_NFCOMPLOPERCOFINS_FF'
                                                        ,ev_atributo => trim(ev_atributo));
     --
     vn_fase := 9;
     --
     if trim(ev_atributo) = 'COD_NAT_REC_PC' then
        --
        vn_fase := 10;
        --
        if trim(ev_valor) is not null then
           --
           vn_fase := 11;
           --
           if vn_dmtipocampo = 1 then
              -- tipo de campo = 0-data, 1-numérico, 2-caractere
              --
              vn_fase := 12;
              --
              if trim(ev_atributo) = 'COD_NAT_REC_PC' then
                 --
                 vn_fase := 13;
                 --
                 begin
                    vn_cod_nat_rec_pc := pk_csf.fkg_ff_ret_vlr_number(ev_obj_name => 'VW_CSF_NFCOMPLOPERCOFINS_FF'
                                                                     ,ev_atributo => trim(ev_atributo)
                                                                     ,ev_valor    => trim(ev_valor));
                 exception
                    when others then
                       vn_cod_nat_rec_pc := null;
                 end;
                 --
                 vn_fase := 14;
                 --
                 begin
                    select nc.codst_id
                      into vn_codst_id
                      from nf_compl_oper_cofins nc
                     where nc.id = en_nfcomplopercofins_id;
                 exception
                    when others then
                       vn_codst_id := 0;
                 end;
                 --
                 vn_fase := 15;
                 --
                 begin
                    vn_natrecpc_id := pk_csf_efd_pc.fkg_codst_id_nat_rec_pc(en_multorg_id        => en_multorg_id
                                                                           ,en_natrecpc_codst_id => vn_codst_id
                                                                           ,en_natrecpc_cod      => vn_cod_nat_rec_pc);
                 exception
                    when others then
                       vn_natrecpc_id := null;
                 end;
                 --
              end if;
              --
              vn_fase := 16;
              --
              if trim(ev_atributo) = 'COD_NAT_REC_PC' and
                 nvl(vn_natrecpc_id, 0) <= 0 then
                 --
                 vn_fase := 17;
                 --
                 gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR ('||ev_valor||') informado está inválido.';
                 --
                 vn_loggenerico_id := null;
                 --
                 pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                               ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                               ,ev_resumo           => gv_mensagem_log
                                               ,en_tipo_log         => erro_de_validacao
                                               ,en_referencia_id    => gn_referencia_id
                                               ,ev_obj_referencia   => gv_obj_referencia);
                 --
                 -- Armazena o "loggenerico_id" na memoria
                 pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                                  ,est_log_generico_nf => est_log_generico_nf);
                 --
              end if;
              --
           else
              --
              vn_fase := 18;
              --
              gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
              --
              vn_loggenerico_id := null;
              --
              pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                            ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                            ,ev_resumo           => gv_mensagem_log
                                            ,en_tipo_log         => erro_de_validacao
                                            ,en_referencia_id    => gn_referencia_id
                                            ,ev_obj_referencia   => gv_obj_referencia);
              --
              -- Armazena o "loggenerico_id" na memoria
              pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                               ,est_log_generico_nf => est_log_generico_nf);
              --
           end if;
           --
        else
           --
           vn_fase := 19;
           --
           gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => erro_de_validacao
                                         ,en_referencia_id    => gn_referencia_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
     else
        --
        vn_fase := 20;
        --
        gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                      ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                      ,ev_resumo           => gv_mensagem_log
                                      ,en_tipo_log         => erro_de_validacao
                                      ,en_referencia_id    => gn_referencia_id
                                      ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                         ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 21;
  --
  if nvl(en_nfcomplopercofins_id, 0) = 0 then
     --
     vn_fase := 22;
     --
     gv_mensagem_log := 'Identificador do complemento da operação de COFINS não informado.';
     --
     vn_loggenerico_id := null;
     --
     pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                   ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   ,ev_resumo           => gv_mensagem_log
                                   ,en_tipo_log         => erro_de_validacao
                                   ,en_referencia_id    => gn_referencia_id
                                   ,ev_obj_referencia   => gv_obj_referencia);
     --
     -- Armazena o "loggenerico_id" na memoria
     pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                      ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 99;
  --
  if nvl(en_nfcomplopercofins_id, 0) > 0 and
     ev_atributo = 'COD_NAT_REC_PC' and vn_natrecpc_id is not null and
     vv_mensagem is null then
     --
     vn_fase := 99.1;
     --
     update nf_compl_oper_cofins nc
        set nc.natrecpc_id = vn_natrecpc_id
      where nc.id = en_nfcomplopercofins_id;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_nfcomplopercof_ff fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFCOMPLOPERCOF_FF;
-----------------------------------------------------
-- Integra as informações complementares de cofins --
-----------------------------------------------------
PROCEDURE PKB_INTEGR_NFCOMPL_OPERCOFINS(EST_LOG_GENERICO_NF        IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                      ,EST_ROW_NFCOMPL_OPERCOFINS IN OUT NOCOPY NF_COMPL_OPER_COFINS%ROWTYPE
                                      ,EV_CPF_CNPJ_EMIT           IN VARCHAR2
                                      ,EV_COD_ST                  IN COD_ST.COD_ST%TYPE
                                      ,EV_COD_BC_CRED_PC          IN BASE_CALC_CRED_PC.CD%TYPE
                                      ,EV_COD_CTA                 IN PLANO_CONTA.COD_CTA%TYPE
                                      ,EN_MULTORG_ID              IN MULT_ORG.ID%TYPE) IS
  --
  vn_fase               number := 0;
  vn_loggenerico_id     log_generico_nf.id%type;
  vn_empresa_id         empresa.id%type;
  vv_codmodfiscal       mod_fiscal.cod_mod%type;
  vn_dm_valida_cofins   empresa.dm_valida_cofins%type;
  --
BEGIN
  --
  vn_fase := 2;
  --
  if nvl(est_row_nfcompl_opercofins.notafiscal_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 2.1;
     --
     gv_mensagem_log := 'Não informada a Nota Fiscal para complemento de operação de COFINS.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  --
  if (ev_cod_st not between 50 and 56) and
     (ev_cod_st not between 60 and 66) and
     (ev_cod_st not between 70 and 75) and
     (ev_cod_st not between 98 and 99) then
     --
     vn_fase := 3.1;
     --
     gv_mensagem_log := '"Código da Situação Tributária de COFINS" ('||ev_cod_st||') deve estar entre 50 e 56, ou 60 e 66, ou 70 e 75, ou 98 e 99.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 4;
  -- Recupera o Código da Situação Tributária de COFINS
  est_row_nfcompl_opercofins.codst_id := pk_csf.fkg_cod_st_id(ev_cod_st     => ev_cod_st
                                                             ,en_tipoimp_id => pk_csf.fkg_tipo_imposto_id(en_cd => 5)); -- COFINS
  --
  vn_fase := 5;
  --
  if nvl(est_row_nfcompl_opercofins.codst_id, 0) <= 0 then
     --
     vn_fase := 5.1;
     --
     gv_mensagem_log := '"Código da Situação Tributária de COFINS" está inválido ('||ev_cod_st||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 6;
  -- Recuperar o Código do modelo fiscal da nota fiscal em questão
  vv_codmodfiscal := pk_csf.fkg_cod_mod_id(en_modfiscal_id => pk_csf.fkg_recup_modfisc_id_nf(en_notafiscal_id => est_row_nfcompl_opercofins.notafiscal_id));
  --
  vn_fase := 6.1;
  --
  -- Recupera se valida ou não cofins 
  vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj(en_multorg_id => en_multorg_id
                                                      ,ev_cpf_cnpj   => ev_cpf_cnpj_emit);
  --      
  if pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id => est_row_nfcompl_opercofins.notafiscal_id ) = 0 then -- emissão própria
     --
     vn_dm_valida_cofins := pk_csf.fkg_empresa_dmvalcofins_emis ( en_empresa_id => vn_empresa_id );
     --
  elsif pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id => est_row_nfcompl_opercofins.notafiscal_id  ) = 1 then -- terceiros
     --
     vn_dm_valida_cofins := pk_csf.fkg_empresa_dmvalcofins_terc ( en_empresa_id => vn_empresa_id );
     --
  else
     --
     vn_dm_valida_cofins := 1; -- sim
     --
  end if;        
  --
  if (ev_cod_st between 50 and 56) or (ev_cod_st between 60 and 66) then
     --
     vn_fase := 6.2;
     --
     if ev_cod_bc_cred_pc is null and
        vn_dm_valida_cofins = 1 and  -- valida cofins
        nvl(est_row_nfcompl_opercofins.vl_bc_cofins,0) > 0 and
        nvl(est_row_nfcompl_opercofins.aliq_cofins,0) > 0 then
        --
        vn_fase := 6.3;
        --
        gv_mensagem_log := '"Código da Base de Cálculo do Crédito" para COFINS não informado e existe base e aliquota para nota fiscal.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => INFORMACAO
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
            
     end if;   
     --
     if vv_codmodfiscal in ('06', '28', '29') and -- Código do modelo fiscal da nota fiscal em questão
        ev_cod_bc_cred_pc not in ('01', '02', '04', '13') then
        --
        vn_fase := 6.4;
        --
        gv_mensagem_log := '"Código da Base de cálculo do Crédito" para COFINS deve ser 01, 02, 04 ou 13, devido ao modelo fiscal da nota fiscal ser '||
                           '"06", "28" ou "29".';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     elsif vv_codmodfiscal in ('21', '22') and -- Código do modelo fiscal da nota fiscal em questão
           ev_cod_bc_cred_pc not in ('03', '13') then
        --
        vn_fase := 6.5;
        --
        gv_mensagem_log := '"Código da Base de cálculo do Crédito" para COFINS deve ser 03 ou 13, devido ao modelo fiscal da nota fiscal ser "21" ou "22".';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     elsif vv_codmodfiscal not in ('06', '21', '22', '28', '29') and -- Código do modelo fiscal da nota fiscal em questão
           ev_cod_bc_cred_pc not between 01 and 04 then
        --
        vn_fase := 6.6;
        --
        gv_mensagem_log := '"Código da Base de cálculo do Crédito" para COFINS deve estar entre 01 e 04.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 7;
  --
  -- Recuperar o identificador da base de calculo de crédito.
  est_row_nfcompl_opercofins.basecalccredpc_id := pk_csf_efd_pc.fkg_base_calc_cred_pc_id(ev_cd => ev_cod_bc_cred_pc);
  --
  vn_fase := 8;
  --
  if nvl(est_row_nfcompl_opercofins.basecalccredpc_id, 0) <= 0 and
     trim(ev_cod_bc_cred_pc) is not null then
     --
     vn_fase := 8.1;
     --
     gv_mensagem_log := '"Código da Base de cálculo do Crédito" para COFINS está inválido ('||ev_cod_bc_cred_pc||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 9;
  --
  -- Recuperar o identificador da empresa da nota fiscal.
  vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj(en_multorg_id => en_multorg_id
                                                      ,ev_cpf_cnpj   => ev_cpf_cnpj_emit);
  --
  vn_fase := 10;
  --
  -- Recuperar o identificador do plano de conta.
  est_row_nfcompl_opercofins.planoconta_id := pk_csf.fkg_plano_conta_id(ev_cod_cta    => ev_cod_cta
                                                                       ,en_empresa_id => vn_empresa_id);
  --
  vn_fase := 11;
  --
  if nvl(est_row_nfcompl_opercofins.planoconta_id, 0) <= 0 and
     trim(ev_cod_cta) is not null then
     --
     vn_fase := 11.1;
     --
     gv_mensagem_log := '"Código da conta analítica contábil debitada/creditada" para COFINS está inválida ('||ev_cod_cta||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 12;
  --
  if nvl(est_row_nfcompl_opercofins.vl_item, 0) < 0 then
     --
     vn_fase := 12.1;
     --
     gv_mensagem_log := '"Valor total dos itens" para COFINS não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 13;
  --
  if nvl(est_row_nfcompl_opercofins.vl_bc_cofins, 0) < 0 then
     --
     vn_fase := 13.1;
     --
     gv_mensagem_log := '"Valor da base de cálculo da COFINS" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 14;
  --
  if nvl(est_row_nfcompl_opercofins.aliq_cofins, 0) < 0 then
     --
     vn_fase := 14.1;
     --
     gv_mensagem_log := '"Alíquota da COFINS (em percentual)" não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 15;
  --
  if nvl(est_row_nfcompl_opercofins.vl_cofins, 0) < 0 then
     --
     vn_fase := 15.1;
     --
     gv_mensagem_log := '"Valor da COFINS" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 99;
  --
  if nvl(est_row_nfcompl_opercofins.notafiscal_id, 0) > 0 and
     nvl(est_row_nfcompl_opercofins.codst_id, 0) > 0 and
     nvl(est_row_nfcompl_opercofins.vl_item, 0) >= 0 and
     nvl(est_row_nfcompl_opercofins.vl_bc_cofins, 0) >= 0 and
     nvl(est_row_nfcompl_opercofins.aliq_cofins, 0) >= 0 and
     nvl(est_row_nfcompl_opercofins.vl_cofins, 0) >= 0 then
     --
     vn_fase := 99.1;
     -- Se for 1 insere se for 0 sao valida e atualiza
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 99.2;
        --
        select nfcomplopercofins_seq.nextval
          into est_row_nfcompl_opercofins.id
          from dual;
        --
        --
        vn_fase := 99.3;
        --
        insert into nf_compl_oper_cofins
           (id
           ,notafiscal_id
           ,codst_id
           ,vl_item
           ,basecalccredpc_id
           ,vl_bc_cofins
           ,aliq_cofins
           ,vl_cofins
           ,planoconta_id)
        values
           (est_row_nfcompl_opercofins.id
           ,est_row_nfcompl_opercofins.notafiscal_id
           ,est_row_nfcompl_opercofins.codst_id
           ,est_row_nfcompl_opercofins.vl_item
           ,est_row_nfcompl_opercofins.basecalccredpc_id
           ,est_row_nfcompl_opercofins.vl_bc_cofins
           ,est_row_nfcompl_opercofins.aliq_cofins
           ,est_row_nfcompl_opercofins.vl_cofins
           ,est_row_nfcompl_opercofins.planoconta_id);
        --
     else
        --
        vn_fase := 99.4;
        --
        update nf_compl_oper_cofins
           set codst_id          = est_row_nfcompl_opercofins.codst_id
              ,vl_item           = est_row_nfcompl_opercofins.vl_item
              ,basecalccredpc_id = est_row_nfcompl_opercofins.basecalccredpc_id
              ,vl_bc_cofins      = est_row_nfcompl_opercofins.vl_bc_cofins
              ,aliq_cofins       = est_row_nfcompl_opercofins.aliq_cofins
              ,vl_cofins         = est_row_nfcompl_opercofins.vl_cofins
              ,planoconta_id     = est_row_nfcompl_opercofins.planoconta_id
         where id = est_row_nfcompl_opercofins.id;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_nfcompl_opercofins fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFCOMPL_OPERCOFINS;

---------------------------------------------------
-- Atualiza as informações complementares de pis --
---------------------------------------------------

PROCEDURE PKB_INTEGR_NFCOMPLOPERPIS_FF(EST_LOG_GENERICO_NF  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                     ,EN_NFCOMPLOPERPIS_ID IN NF_COMPL_OPER_PIS.ID%TYPE
                                     ,EV_ATRIBUTO          IN VARCHAR2
                                     ,EV_VALOR             IN VARCHAR2
                                     ,EN_MULTORG_ID        IN MULT_ORG.ID%TYPE) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  vv_mensagem       varchar2(1000) := null;
  vn_dmtipocampo    ff_obj_util_integr.dm_tipo_campo%type;
  vn_cod_nat_rec_pc nat_rec_pc.cod%type := 0;
  vn_codst_id       cod_st.id%type := 0;
  vn_natrecpc_id    nat_rec_pc.id%type := 0;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if trim(ev_atributo) is null then
     --
     vn_fase := 2;
     --
     gv_mensagem_log := 'Informações Complementares de Pis: "Atributo" deve ser informado.';
     --
     vn_loggenerico_id := null;
     --
     pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                   ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   ,ev_resumo           => gv_mensagem_log
                                   ,en_tipo_log         => erro_de_validacao
                                   ,en_referencia_id    => gn_referencia_id
                                   ,ev_obj_referencia   => gv_obj_referencia);
     --
     -- Armazena o "loggenerico_id" na memoria
     pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                      ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  --
  if trim(ev_valor) is null then
     --
     vn_fase := 4;
     --
     gv_mensagem_log := 'Informações Complementares de Pis: "VALOR" referente ao atributo deve ser informado.';
     --
     vn_loggenerico_id := null;
     --
     pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                   ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   ,ev_resumo           => gv_mensagem_log
                                   ,en_tipo_log         => erro_de_validacao
                                   ,en_referencia_id    => gn_referencia_id
                                   ,ev_obj_referencia   => gv_obj_referencia);
     --
     -- Armazena o "loggenerico_id" na memoria
     pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                      ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 5;
  --
  vv_mensagem := pk_csf.fkg_ff_verif_campos(ev_obj_name => 'VW_CSF_NFCOMPLOPERPIS_FF'
                                           ,ev_atributo => trim(ev_atributo)
                                           ,ev_valor    => trim(ev_valor));
  --
  vn_fase := 6;
  --
  if vv_mensagem is not null then
     --
     vn_fase := 7;
     --
     gv_mensagem_log := vv_mensagem;
     --
     vn_loggenerico_id := null;
     --
     pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                   ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   ,ev_resumo           => gv_mensagem_log
                                   ,en_tipo_log         => erro_de_validacao
                                   ,en_referencia_id    => gn_referencia_id
                                   ,ev_obj_referencia   => gv_obj_referencia);
     --
     -- Armazena o "loggenerico_id" na memoria
     pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                      ,est_log_generico_nf => est_log_generico_nf);
     --
  else
     --
     vn_fase := 8;
     --
     vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo(ev_obj_name => 'VW_CSF_NFCOMPLOPERPIS_FF'
                                                        ,ev_atributo => trim(ev_atributo));
     --
     vn_fase := 9;
     --
     if trim(ev_atributo) = 'COD_NAT_REC_PC' then
        --
        vn_fase := 10;
        --
        if trim(ev_valor) is not null then
           --
           vn_fase := 11;
           --
           if vn_dmtipocampo = 1 then
              -- tipo de campo = 0-data, 1-numérico, 2-caractere
              --
              vn_fase := 12;
              --
              if trim(ev_atributo) = 'COD_NAT_REC_PC' then
                 --
                 vn_fase := 13;
                 --
                 begin
                    vn_cod_nat_rec_pc := pk_csf.fkg_ff_ret_vlr_number(ev_obj_name => 'VW_CSF_NFCOMPLOPERPIS_FF'
                                                                     ,ev_atributo => trim(ev_atributo)
                                                                     ,ev_valor    => trim(ev_valor));
                 exception
                    when others then
                       vn_cod_nat_rec_pc := null;
                 end;
                 --
                 vn_fase := 14;
                 --
                 begin
                    select nc.codst_id
                      into vn_codst_id
                      from nf_compl_oper_pis nc
                     where nc.id = en_nfcomploperpis_id;
                 exception
                    when others then
                       vn_codst_id := 0;
                 end;
                 --
                 vn_fase := 15;
                 --
                 begin
                    vn_natrecpc_id := pk_csf_efd_pc.fkg_codst_id_nat_rec_pc(en_multorg_id        => en_multorg_id
                                                                           ,en_natrecpc_codst_id => vn_codst_id
                                                                           ,en_natrecpc_cod      => vn_cod_nat_rec_pc);
                 exception
                    when others then
                       vn_natrecpc_id := null;
                 end;
                 --
              end if;
              --
              vn_fase := 16;
              --
              if trim(ev_atributo) = 'COD_NAT_REC_PC' and
                 nvl(vn_natrecpc_id, 0) <= 0 then
                 --
                 vn_fase := 17;
                 --
                 gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR ('||ev_valor||') informado está inválido.';
                 --
                 vn_loggenerico_id := null;
                 --
                 pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                               ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                               ,ev_resumo           => gv_mensagem_log
                                               ,en_tipo_log         => erro_de_validacao
                                               ,en_referencia_id    => gn_referencia_id
                                               ,ev_obj_referencia   => gv_obj_referencia);
                 --
                 -- Armazena o "loggenerico_id" na memoria
                 pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                                  ,est_log_generico_nf => est_log_generico_nf);
                 --
              end if;
              --
           else
              --
              vn_fase := 18;
              --
              gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
              --
              vn_loggenerico_id := null;
              --
              pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                            ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                            ,ev_resumo           => gv_mensagem_log
                                            ,en_tipo_log         => erro_de_validacao
                                            ,en_referencia_id    => gn_referencia_id
                                            ,ev_obj_referencia   => gv_obj_referencia);
              --
              -- Armazena o "loggenerico_id" na memoria
              pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                               ,est_log_generico_nf => est_log_generico_nf);
              --
           end if;
           --
        else
           --
           vn_fase := 19;
           --
           gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => erro_de_validacao
                                         ,en_referencia_id    => gn_referencia_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
     else
        --
        vn_fase := 20;
        --
        gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                      ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                      ,ev_resumo           => gv_mensagem_log
                                      ,en_tipo_log         => erro_de_validacao
                                      ,en_referencia_id    => gn_referencia_id
                                      ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                         ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 21;
  --
  if nvl(en_nfcomploperpis_id, 0) = 0 then
     --
     vn_fase := 22;
     --
     gv_mensagem_log := 'Identificador do complemento da operação de PIS não informado.';
     --
     vn_loggenerico_id := null;
     --
     pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                   ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                   ,ev_resumo           => gv_mensagem_log
                                   ,en_tipo_log         => erro_de_validacao
                                   ,en_referencia_id    => gn_referencia_id
                                   ,ev_obj_referencia   => gv_obj_referencia);
     --
     -- Armazena o "loggenerico_id" na memoria
     pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                      ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 99;
  --
  if nvl(en_nfcomploperpis_id, 0) > 0 and
     ev_atributo = 'COD_NAT_REC_PC' and vn_natrecpc_id is not null and
     vv_mensagem is null then
     --
     vn_fase := 99.1;
     --
     update nf_compl_oper_pis nc
        set nc.natrecpc_id = vn_natrecpc_id
      where nc.id = en_nfcomploperpis_id;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_nfcomploperpis_ff fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFCOMPLOPERPIS_FF;
--------------------------------------------------
-- Integra as informações complementares de pis --
--------------------------------------------------
PROCEDURE PKB_INTEGR_NFCOMPL_OPERPIS(EST_LOG_GENERICO_NF     IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                   ,EST_ROW_NFCOMPL_OPERPIS IN OUT NOCOPY NF_COMPL_OPER_PIS%ROWTYPE
                                   ,EV_CPF_CNPJ_EMIT        IN VARCHAR2
                                   ,EV_COD_ST               IN COD_ST.COD_ST%TYPE
                                   ,EV_COD_BC_CRED_PC       IN BASE_CALC_CRED_PC.CD%TYPE
                                   ,EV_COD_CTA              IN PLANO_CONTA.COD_CTA%TYPE
                                   ,EN_MULTORG_ID           IN MULT_ORG.ID%TYPE) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  vn_empresa_id     empresa.id%type;
  vv_codmodfiscal   mod_fiscal.cod_mod%type;
  vn_dm_valida_pis  empresa.dm_valida_pis%type;
  --
BEGIN
  --
  vn_fase := 2;
  --
  if nvl(est_row_nfcompl_operpis.notafiscal_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 2.1;
     --
     gv_mensagem_log := 'Não informada a Nota Fiscal para complemento de operação de PIS.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  --
  if (ev_cod_st not between 50 and 56) and
     (ev_cod_st not between 60 and 66) and
     (ev_cod_st not between 70 and 75) and
     (ev_cod_st not between 98 and 99) then
     --
     vn_fase := 3.1;
     --
     gv_mensagem_log := '"Código da Situação Tributária de PIS" inválido ('||ev_cod_st||') deve estar entre 50 e 56, ou 60 e 66, ou 70 e 75, ou 98 e 99.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 4;
  -- Recupera o Código da Situação Tributária de PIS
  est_row_nfcompl_operpis.codst_id := pk_csf.fkg_cod_st_id(ev_cod_st     => ev_cod_st
                                                          ,en_tipoimp_id => pk_csf.fkg_tipo_imposto_id(en_cd => 4)); -- PIS
  --
  vn_fase := 5;
  --
  if nvl(est_row_nfcompl_operpis.codst_id, 0) <= 0 then
     --
     vn_fase := 5.1;
     --
     gv_mensagem_log := '"Código da Situação Tributária de PIS" está inválido ('||ev_cod_st||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 6;
  -- Recuperar o Código do modelo fiscal da nota fiscal em questão
  vv_codmodfiscal := pk_csf.fkg_cod_mod_id(en_modfiscal_id => pk_csf.fkg_recup_modfisc_id_nf(en_notafiscal_id => est_row_nfcompl_operpis.notafiscal_id));
  --
  vn_fase := 6.1;
  --
  -- Recupera se valida ou não pis  
  vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj(en_multorg_id => en_multorg_id
                                                      ,ev_cpf_cnpj   => ev_cpf_cnpj_emit);
  --                
  if pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id => est_row_nfcompl_operpis.notafiscal_id ) = 0 then -- emissão própria
     --
     vn_dm_valida_pis := pk_csf.fkg_empresa_dmvalpis_emis ( en_empresa_id => vn_empresa_id );
     --
  elsif pk_csf.fkg_dmindemit_notafiscal ( en_notafiscal_id => est_row_nfcompl_operpis.notafiscal_id  ) = 1 then -- terceiros
     --
     vn_dm_valida_pis := pk_csf.fkg_empresa_dmvalpis_terc ( en_empresa_id => vn_empresa_id );
     --
  else
     --
     vn_dm_valida_pis := 1; -- sim
     --
  end if;
  --
  if (ev_cod_st between 50 and 56) or (ev_cod_st between 60 and 66) then
     --
     vn_fase := 6.2;
     --
     if ev_cod_bc_cred_pc is null and
        vn_dm_valida_pis = 1 and  -- valida pis
        nvl(est_row_nfcompl_operpis.vl_bc_pis,0) > 0 and
        nvl(est_row_nfcompl_operpis.aliq_pis,0) > 0 then
        --
        gv_mensagem_log := '"Código da Base de Cálculo do Crédito" para PIS não informado e existe base e aliquota para nota fiscal.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                            , ev_mensagem         => gv_cabec_log
                            , ev_resumo           => gv_mensagem_log
                            , en_tipo_log         => INFORMACAO
                            , en_referencia_id    => gn_referencia_id
                            , ev_obj_referencia   => gv_obj_referencia );
        -- Armazena o "loggenerico_id" na memória
        pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                               , est_log_generico_nf => est_log_generico_nf );
        --
     end if;      
     --
     if vv_codmodfiscal in ('06', '28', '29') and -- Código do modelo fiscal da nota fiscal em questão
        ev_cod_bc_cred_pc not in ('01', '02', '04', '13') then
        --
        vn_fase := 6.3;
        --
        gv_mensagem_log := '"Código da base de cálculo do Crédito" para PIS deve ser 01, 02, 04 ou 13, devido ao modelo fiscal da nota fiscal ser '||
                           '"06", "28" ou "29".';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     elsif vv_codmodfiscal in ('21', '22') and -- Código do modelo fiscal da nota fiscal em questão
           ev_cod_bc_cred_pc not in ('03', '13') then
        --
        vn_fase := 6.4;
        --
        gv_mensagem_log := '"Código da base de cálculo do crédito" para PIS deve ser 03 ou 13, devido ao modelo fiscal da nota fiscal ser "21" ou "22".';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     elsif vv_codmodfiscal not in ('06', '21', '22', '28', '29') and -- Código do modelo fiscal da nota fiscal em questão
           ev_cod_bc_cred_pc not between 01 and 04 then
        --
        vn_fase := 6.5;
        --
        gv_mensagem_log := '"Código da base de cálculo do crédito" para PIS deve estar entre 01 e 04.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 7;
  --
  -- Recuperar o identificador da base de cálculo de crédito.
  est_row_nfcompl_operpis.basecalccredpc_id := pk_csf_efd_pc.fkg_base_calc_cred_pc_id(ev_cd => ev_cod_bc_cred_pc);
  --
  vn_fase := 8;
  --
  if nvl(est_row_nfcompl_operpis.basecalccredpc_id, 0) <= 0 and
     trim(ev_cod_bc_cred_pc) is not null then
     --
     vn_fase := 8.1;
     --
     gv_mensagem_log := '"Código da base de cálculo do Crédito" para PIS está inválido ('||ev_cod_bc_cred_pc||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 9;
  --
  -- Recuperar o identificador da empresa da nota fiscal.
  vn_empresa_id := pk_csf.fkg_empresa_id_pelo_cpf_cnpj(en_multorg_id => en_multorg_id
                                                      ,ev_cpf_cnpj   => ev_cpf_cnpj_emit);
  --
  vn_fase := 10;
  --
  -- Recuperar o identificador do plano de conta.
  est_row_nfcompl_operpis.planoconta_id := pk_csf.fkg_plano_conta_id(ev_cod_cta    => ev_cod_cta
                                                                    ,en_empresa_id => vn_empresa_id);
  --
  vn_fase := 11;
  --
  if nvl(est_row_nfcompl_operpis.planoconta_id, 0) <= 0 and
     trim(ev_cod_cta) is not null then
     --
     vn_fase := 11.1;
     --
     gv_mensagem_log := '"Código da conta analítica contábil debitada/creditada" para PIS está inválido ('||ev_cod_cta||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 12;
  --
  if nvl(est_row_nfcompl_operpis.vl_item, 0) < 0 then
     --
     vn_fase := 12.1;
     --
     gv_mensagem_log := '"Valor total dos itens" para PIS não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 13;
  --
  if nvl(est_row_nfcompl_operpis.vl_bc_pis, 0) < 0 then
     --
     vn_fase := 13.1;
     --
     gv_mensagem_log := '"Valor da base de cálculo do PIS" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 14;
  --
  if nvl(est_row_nfcompl_operpis.aliq_pis, 0) < 0 then
     --
     vn_fase := 14.1;
     --
     gv_mensagem_log := '"Alíquota do PIS (em percentual)" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 15;
  --
  if nvl(est_row_nfcompl_operpis.vl_pis, 0) < 0 then
     --
     vn_fase := 15.1;
     --
     gv_mensagem_log := '"Valor do PIS" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 99;
  --
  if nvl(est_row_nfcompl_operpis.notafiscal_id, 0) > 0 and
     nvl(est_row_nfcompl_operpis.codst_id, 0) > 0 and
     nvl(est_row_nfcompl_operpis.vl_item, 0) >= 0 and
     nvl(est_row_nfcompl_operpis.vl_bc_pis, 0) >= 0 and
     nvl(est_row_nfcompl_operpis.aliq_pis, 0) >= 0 and
     nvl(est_row_nfcompl_operpis.vl_pis, 0) >= 0 then
     --
     vn_fase := 99.1;
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 99.2;
        --
        select nfcomploperpis_seq.nextval
          into est_row_nfcompl_operpis.id
          from dual;
        --
        vn_fase := 99.3;
        --
        insert into nf_compl_oper_pis
           (id
           ,notafiscal_id
           ,codst_id
           ,vl_item
           ,basecalccredpc_id
           ,vl_bc_pis
           ,aliq_pis
           ,vl_pis
           ,planoconta_id)
        values
           (est_row_nfcompl_operpis.id
           ,est_row_nfcompl_operpis.notafiscal_id
           ,est_row_nfcompl_operpis.codst_id
           ,est_row_nfcompl_operpis.vl_item
           ,est_row_nfcompl_operpis.basecalccredpc_id
           ,est_row_nfcompl_operpis.vl_bc_pis
           ,est_row_nfcompl_operpis.aliq_pis
           ,est_row_nfcompl_operpis.vl_pis
           ,est_row_nfcompl_operpis.planoconta_id);
        --
     else
        --
        vn_fase := 99.4;
        --
        update nf_compl_oper_pis
           set codst_id          = est_row_nfcompl_operpis.codst_id
              ,vl_item           = est_row_nfcompl_operpis.vl_item
              ,basecalccredpc_id = est_row_nfcompl_operpis.basecalccredpc_id
              ,vl_bc_pis         = est_row_nfcompl_operpis.vl_bc_pis
              ,aliq_pis          = est_row_nfcompl_operpis.aliq_pis
              ,vl_pis            = est_row_nfcompl_operpis.vl_pis
              ,planoconta_id     = est_row_nfcompl_operpis.planoconta_id
         where id = est_row_nfcompl_operpis.id;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_nfcompl_operpis fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFCOMPL_OPERPIS;

--------------------------------------------------
-- Integra as informações do registro analitico --
--------------------------------------------------

PROCEDURE PKB_INTEGR_NFREGIST_ANALIT(EST_LOG_GENERICO_NF     IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                   ,EST_ROW_NFREGIST_ANALIT IN OUT NOCOPY NFREGIST_ANALIT%ROWTYPE
                                   ,EV_COD_ST               IN COD_ST.COD_ST%TYPE
                                   ,EN_CFOP                 IN CFOP.CD%TYPE
                                   ,EV_COD_OBS              IN OBS_LANCTO_FISCAL.COD_OBS%TYPE
                                   ,EN_MULTORG_ID           IN MULT_ORG.ID%TYPE) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(est_row_nfregist_analit.notafiscal_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 1.1;
     --
     gv_mensagem_log := 'Não informada a Nota Fiscal para registro analítico de impostos.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 2;
  -- Recupera o Código da Situação Tributária de ICMS
  est_row_nfregist_analit.codst_id := pk_csf.fkg_Cod_ST_id(ev_cod_st     => ev_cod_st
                                                          ,en_tipoimp_id => pk_csf.fkg_Tipo_Imposto_id(en_cd => 1));
  --
  if nvl(est_row_nfregist_analit.codst_id, 0) <= 0 then
     --
     -- Recupera o Código da Situação Tributária de ICMS
     est_row_nfregist_analit.codst_id := pk_csf.fkg_Cod_ST_id(ev_cod_st     => ev_cod_st
                                                             ,en_tipoimp_id => pk_csf.fkg_Tipo_Imposto_id(en_cd => 10));
     --
  end if;
  --
  vn_fase := 2.1;
  --
  if nvl(est_row_nfregist_analit.codst_id, 0) <= 0 and
     trim(ev_cod_st) is not null then
     --
     vn_fase := 2.2;
     --
     gv_mensagem_log := '"Código da Situação Tributária de ICMS" está inválido ('||ev_cod_st||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  -- Recupera o CFOP
  est_row_nfregist_analit.cfop_id := pk_csf.fkg_cfop_id(en_cd => en_cfop);
  --
  vn_fase := 3.1;
  --
  if nvl(est_row_nfregist_analit.cfop_id, 0) <= 0 then
     --
     vn_fase := 3.2;
     --
     gv_mensagem_log := '"CFOP" informado está inválido ('||en_cfop||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 4;
  --
  if nvl(est_row_nfregist_analit.aliq_icms, 0) < 0 then
     --
     vn_fase := 4.1;
     --
     gv_mensagem_log := '"Alíquota de ICMS" não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 5;
  --
  if nvl(est_row_nfregist_analit.vl_operacao, 0) <= 0 then
     --
     vn_fase := 5.1;
     --
     gv_mensagem_log := '"Valor da operação de ICMS" não pode ser zero ou negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 6;
  --
  if nvl(est_row_nfregist_analit.vl_bc_icms, 0) < 0 then
     --
     vn_fase := 6.1;
     --
     gv_mensagem_log := '"Valor da base de cálculo do ICMS" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 7;
  --
  if nvl(est_row_nfregist_analit.vl_icms, 0) < 0 then
     --
     vn_fase := 7.1;
     --
     gv_mensagem_log := '"Valor do ICMS" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 8;
  --
  if nvl(est_row_nfregist_analit.vl_bc_icms_st, 0) < 0 then
     --
     vn_fase := 8.1;
     --
     gv_mensagem_log := '"Valor da base de cálculo do ICMS ST" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 9;
  --
  if nvl(est_row_nfregist_analit.vl_icms_st, 0) < 0 then
     --
     vn_fase := 9.1;
     --
     gv_mensagem_log := '"Valor do ICMS ST" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 10;
  --
  if nvl(est_row_nfregist_analit.vl_red_bc_icms, 0) < 0 then
     --
     est_row_nfregist_analit.vl_red_bc_icms := 0;
     --
  end if;
  --
  vn_fase := 11;
  --
  if nvl(est_row_nfregist_analit.vl_ipi, 0) < 0 then
     --
     vn_fase := 11.1;
     --
     gv_mensagem_log := '"Valor do IPI" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 12;
  --
  est_row_nfregist_analit.obslanctofiscal_id := pk_csf.fkg_id_obs_lancto_fiscal(en_multorg_id => en_multorg_id
                                                                               ,ev_cod_obs    => ev_cod_obs);
  --
  vn_fase := 13;
  --
  if nvl(est_row_nfregist_analit.obslanctofiscal_id, 0) <= 0 and
     trim(ev_cod_obs) is not null then
     --
     vn_fase := 13.1;
     --
     gv_mensagem_log := '"Código da observação do lançamento fiscal" está inválido ('||ev_cod_obs||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 14;
  --
  if nvl(est_row_nfregist_analit.dm_orig_merc, -1) not in (0, 1, 2, 3, 4, 5, 6, 7, 8) then
     --
     gv_mensagem_log := '"Origem da Mercadoria do Resumo de Impostos" está inválida ('||est_row_nfregist_analit.dm_orig_merc||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  if gv_cod_mod in ('21', '22')
     and gt_row_nota_fiscal.dt_emiss >= to_date('01/01/2017', 'dd/mm/rrrr')
     and nvl(est_row_nfregist_analit.dm_orig_merc, -1) not in (0)
     then
     --
     gv_mensagem_log := 'Código da Origem da Mercadoria inválido para documentos fiscais de código 21 e 22. Utilizar origem da Mercadoria 0 - Nacional).';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 15;
  --
  est_row_nfregist_analit.vl_operacao    := nvl(est_row_nfregist_analit.vl_operacao,0);
  est_row_nfregist_analit.vl_bc_icms     := nvl(est_row_nfregist_analit.vl_bc_icms,0);
  est_row_nfregist_analit.vl_icms        := nvl(est_row_nfregist_analit.vl_icms,0);
  est_row_nfregist_analit.vl_bc_icms_st  := nvl(est_row_nfregist_analit.vl_bc_icms_st,0);
  est_row_nfregist_analit.vl_icms_st     := nvl(est_row_nfregist_analit.vl_icms_st,0);
  est_row_nfregist_analit.vl_red_bc_icms := nvl(est_row_nfregist_analit.vl_red_bc_icms,0);
  est_row_nfregist_analit.vl_ipi         := nvl(est_row_nfregist_analit.vl_ipi,0);
  --
  vn_fase := 17;
  --
  if nvl(est_row_nfregist_analit.notafiscal_id, 0) > 0 and
     nvl(est_row_nfregist_analit.codst_id, 0) > 0 and
     nvl(est_row_nfregist_analit.cfop_id, 0) > 0 and
     nvl(est_row_nfregist_analit.dm_orig_merc, -1) in (0, 1, 2, 3, 4, 5, 6, 7, 8) then
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 18;
        --
        select nfregistanalit_seq.nextval
          into est_row_nfregist_analit.id
          from dual;
        --
        vn_fase := 19;
        --
        insert into nfregist_analit
           (id
           ,notafiscal_id
           ,codst_id
           ,cfop_id
           ,aliq_icms
           ,vl_operacao
           ,vl_bc_icms
           ,vl_icms
           ,vl_bc_icms_st
           ,vl_icms_st
           ,vl_red_bc_icms
           ,vl_ipi
           ,obslanctofiscal_id
           ,dm_orig_merc)
        values
           (est_row_nfregist_analit.id
           ,est_row_nfregist_analit.notafiscal_id
           ,est_row_nfregist_analit.codst_id
           ,est_row_nfregist_analit.cfop_id
           ,est_row_nfregist_analit.aliq_icms
           ,est_row_nfregist_analit.vl_operacao
           ,est_row_nfregist_analit.vl_bc_icms
           ,est_row_nfregist_analit.vl_icms
           ,est_row_nfregist_analit.vl_bc_icms_st
           ,est_row_nfregist_analit.vl_icms_st
           ,est_row_nfregist_analit.vl_red_bc_icms
           ,est_row_nfregist_analit.vl_ipi
           ,est_row_nfregist_analit.obslanctofiscal_id
           ,est_row_nfregist_analit.dm_orig_merc);
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_nfregist_analit fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFREGIST_ANALIT;
------------------------------------------------------------------
-- Atualiza as informações do registro analitico da nota fiscal --
------------------------------------------------------------------
PROCEDURE PKB_INTEGR_NFREGIST_ANALIT_FF(EST_LOG_GENERICO_NF  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                      ,EN_NFREGISTANALIT_ID IN NFREGIST_ANALIT.ID%TYPE
                                      ,EV_ATRIBUTO          IN VARCHAR2
                                      ,EV_VALOR             IN VARCHAR2) IS
  --
  vn_fase             number := 0;
  vn_loggenerico_id   log_generico_nf.id%type;
  vv_mensagem         varchar2(1000) := null;
  vn_dmtipocampo      ff_obj_util_integr.dm_tipo_campo%type;
  vn_vl_base_outro    nfregist_analit.vl_base_outro%type := 0;
  vn_vl_imp_outro     nfregist_analit.vl_imp_outro%type := 0;
  vn_vl_base_isenta   nfregist_analit.vl_base_isenta%type := 0;
  vn_aliq_aplic_outro nfregist_analit.aliq_aplic_outro%type := 0;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if trim(ev_atributo) is null then
     --
     vn_fase := 2;
     --
     gv_mensagem_log := 'Registro Analitico da Nota Fiscal: "Atributo" deve ser informado.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  --
  if trim(ev_valor) is null then
     --
     vn_fase := 4;
     --
     gv_mensagem_log := 'Registro Analitico da Nota Fiscal: "VALOR" referente ao atributo deve ser informado.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 5;
  --
  vv_mensagem := pk_csf.fkg_ff_verif_campos(ev_obj_name => 'VW_CSF_REG_NF_SERV_CONT_FF'
                                           ,ev_atributo => trim(ev_atributo)
                                           ,ev_valor    => trim(ev_valor));
  --
  vn_fase := 6;
  --
  if vv_mensagem is not null then
     --
     vn_fase := 7;
     --
     gv_mensagem_log := vv_mensagem;
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  else
     --
     vn_fase := 8;
     --
     vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo(ev_obj_name => 'VW_CSF_REG_NF_SERV_CONT_FF'
                                                        ,ev_atributo => trim(ev_atributo));
     --
     vn_fase := 9;
     --
     if trim(ev_atributo) = 'VL_BASE_OUTRO' or
        trim(ev_atributo) = 'VL_IMP_OUTRO' or
        trim(ev_atributo) = 'VL_BASE_ISENTA' or
        trim(ev_atributo) = 'ALIQ_APLIC_OUTRO' then
        --
        vn_fase := 10;
        --
        if trim(ev_valor) is not null then
           --
           vn_fase := 11;
           --
           if vn_dmtipocampo = 1 then
              -- tipo de campo = 0-data, 1-numérico, 2-caractere
              --
              vn_fase := 12;
              --
              if trim(ev_atributo) = 'VL_BASE_OUTRO' then
                 --
                 vn_fase := 13;
                 --
                 vn_vl_base_outro := pk_csf.fkg_ff_ret_vlr_number(ev_obj_name => 'VW_CSF_REG_NF_SERV_CONT_FF'
                                                                 ,ev_atributo => trim(ev_atributo)
                                                                 ,ev_valor    => trim(ev_valor));
                 --
              elsif trim(ev_atributo) = 'VL_IMP_OUTRO' then
                 --
                 vn_fase := 14;
                 --
                 vn_vl_imp_outro := pk_csf.fkg_ff_ret_vlr_number(ev_obj_name => 'VW_CSF_REG_NF_SERV_CONT_FF'
                                                                ,ev_atributo => trim(ev_atributo)
                                                                ,ev_valor    => trim(ev_valor));
                 --
              elsif trim(ev_atributo) = 'VL_BASE_ISENTA' then
                 --
                 vn_fase := 15;
                 --
                 vn_vl_base_isenta := pk_csf.fkg_ff_ret_vlr_number(ev_obj_name => 'VW_CSF_REG_NF_SERV_CONT_FF'
                                                                  ,ev_atributo => trim(ev_atributo)
                                                                  ,ev_valor    => trim(ev_valor));
                 --
              elsif trim(ev_atributo) = 'ALIQ_APLIC_OUTRO' then
                 --
                 vn_fase := 16;
                 --
                 vn_aliq_aplic_outro := pk_csf.fkg_ff_ret_vlr_number(ev_obj_name => 'VW_CSF_REG_NF_SERV_CONT_FF'
                                                                    ,ev_atributo => trim(ev_atributo)
                                                                    ,ev_valor    => trim(ev_valor));
                 --
              end if;
              --
              vn_fase := 17;
              --
              if nvl(vn_vl_base_outro, 0) < 0 or
                 nvl(vn_vl_imp_outro, 0) < 0 or
                 nvl(vn_vl_base_isenta, 0) < 0 or
                 nvl(vn_aliq_aplic_outro, 0) < 0 then
                 --
                 vn_fase := 18;
                 --
                 gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR ('||ev_valor||') informado não pode ser negativo.';
                 --
                 vn_loggenerico_id := null;
                 --
                 pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                    ,ev_mensagem         => gv_cabec_log
                                    ,ev_resumo           => gv_mensagem_log
                                    ,en_tipo_log         => erro_de_validacao
                                    ,en_referencia_id    => gn_referencia_id
                                    ,ev_obj_referencia   => gv_obj_referencia);
                 -- Armazena o "loggenerico_id" na memoria
                 pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                       ,est_log_generico_nf => est_log_generico_nf);
                 --
              end if;
              --
           else
              --
              vn_fase := 19;
              --
              gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
              --
              vn_loggenerico_id := null;
              --
              pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                 ,ev_mensagem         => gv_cabec_log
                                 ,ev_resumo           => gv_mensagem_log
                                 ,en_tipo_log         => erro_de_validacao
                                 ,en_referencia_id    => gn_referencia_id
                                 ,ev_obj_referencia   => gv_obj_referencia);
              -- Armazena o "loggenerico_id" na memoria
              pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                    ,est_log_generico_nf => est_log_generico_nf);
              --
           end if;
           --
        else
           --
           vn_fase := 20;
           --
           gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR deve ser maior do que zero (0).';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
     else
        --
        vn_fase := 21;
        --
        gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 22;
  --
  if nvl(en_nfregistanalit_id, 0) = 0 then
     --
     vn_fase := 23;
     --
     gv_mensagem_log := 'Identificador do imposto do item da nota fiscal de serviço contínuo não informado.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 99;
  --
  if nvl(en_nfregistanalit_id, 0) > 0 and 
     ev_atributo = 'VL_BASE_OUTRO' and
     vn_vl_base_outro is not null and 
     vv_mensagem is null then
     --
     vn_fase := 99.1;
     --
     update nfregist_analit na
        set na.vl_base_outro = vn_vl_base_outro
      where na.id = en_nfregistanalit_id;
     --
  elsif nvl(en_nfregistanalit_id, 0) > 0 and
        ev_atributo = 'VL_IMP_OUTRO' and 
        vn_vl_imp_outro is not null and
        vv_mensagem is null then
     --
     vn_fase := 99.2;
     --
     update nfregist_analit na
        set na.vl_imp_outro = vn_vl_imp_outro
      where na.id = en_nfregistanalit_id;
     --
  elsif nvl(en_nfregistanalit_id, 0) > 0 and
        ev_atributo = 'VL_BASE_ISENTA' and
        vn_vl_base_isenta is not null and 
        vv_mensagem is null then
     --
     vn_fase := 99.3;
     --
     update nfregist_analit na
        set na.vl_base_isenta = vn_vl_base_isenta
      where na.id = en_nfregistanalit_id;
     --
  elsif nvl(en_nfregistanalit_id, 0) > 0 and
        ev_atributo = 'ALIQ_APLIC_OUTRO' and
        vn_aliq_aplic_outro is not null and
        vv_mensagem is null then
     --
     vn_fase := 99.4;
     --
     update nfregist_analit na
        set na.aliq_aplic_outro = vn_aliq_aplic_outro
      where na.id = en_nfregistanalit_id;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_nfregist_analit_ff fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFREGIST_ANALIT_FF;
   
--------------------------------------------------
-- Integra as informações do registro analitico - Diferencial de Alíquota (DIFAL)
--------------------------------------------------

PROCEDURE PKB_INTEGR_NFREGIST_ANAL_DIFAL(EST_LOG_GENERICO_NF           IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                       ,EST_ROW_NFREGIST_ANALIT_DIFAL IN OUT NOCOPY NFREGIST_ANALIT_DIFAL%ROWTYPE) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(est_row_nfregist_analit_difal.nfregistanalit_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 1.1;
     --
     gv_mensagem_log := 'Não informado o registro analítico de impostos.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 2;
  --
  if nvl(est_row_nfregist_analit_difal.aliq_orig, -1) < 0 then
     --
     vn_fase := 2.1;
     --
     gv_mensagem_log := '"Alíquota do estado de origem do fornecedor" não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  --
  if nvl(est_row_nfregist_analit_difal.aliq_ie, -1) < 0 then
     --
     vn_fase := 3.1;
     --
     gv_mensagem_log := '"Alíquota interestadual da empresa" não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 4;
  --
  if nvl(est_row_nfregist_analit_difal.vl_bc_icms, -1) < 0 then
     --
     vn_fase := 4.1;
     --
     gv_mensagem_log := '"Base de cálculo do ICMS" não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 5;
  --
  if nvl(est_row_nfregist_analit_difal.vl_dif_aliq, -1) < 0 then
     --
     vn_fase := 5.1;
     --
     gv_mensagem_log := '"Valor do diferencial de alíquota" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 6;
  --
  est_row_nfregist_analit_difal.nfregistanalit_id := nvl(est_row_nfregist_analit_difal.nfregistanalit_id, 0);
  est_row_nfregist_analit_difal.aliq_orig         := nvl(est_row_nfregist_analit_difal.aliq_orig, -1);
  est_row_nfregist_analit_difal.aliq_ie           := nvl(est_row_nfregist_analit_difal.aliq_ie, -1);
  est_row_nfregist_analit_difal.vl_bc_icms        := nvl(est_row_nfregist_analit_difal.vl_bc_icms, -1);
  est_row_nfregist_analit_difal.vl_dif_aliq       := nvl(est_row_nfregist_analit_difal.vl_dif_aliq, -1);
  est_row_nfregist_analit_difal.dm_tipo           := 1; --1- Integrado
  --
  vn_fase := 7;
  --
  if nvl(est_row_nfregist_analit_difal.nfregistanalit_id, 0) > 0 and
     nvl(est_row_nfregist_analit_difal.aliq_orig, -1) >= 0 and
     nvl(est_row_nfregist_analit_difal.aliq_ie, -1) >= 0 and
     nvl(est_row_nfregist_analit_difal.vl_bc_icms, -1) >= 0 and
     nvl(est_row_nfregist_analit_difal.vl_dif_aliq, -1) >= 0 and
     nvl(est_row_nfregist_analit_difal.dm_tipo, 0) in (1, 2, 3, 4, 5) then
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 7.1;
        --
        select nfregistanalitdifal_seq.nextval
          into est_row_nfregist_analit_difal.id
          from dual;
        --
        vn_fase := 7.2;
        --
        insert into nfregist_analit_difal
           (id
           ,nfregistanalit_id
           ,aliq_orig
           ,aliq_ie
           ,vl_bc_icms
           ,vl_dif_aliq
           ,dm_tipo)
        values
           (est_row_nfregist_analit_difal.id
           ,est_row_nfregist_analit_difal.nfregistanalit_id
           ,est_row_nfregist_analit_difal.aliq_orig
           ,est_row_nfregist_analit_difal.aliq_ie
           ,est_row_nfregist_analit_difal.vl_bc_icms
           ,est_row_nfregist_analit_difal.vl_dif_aliq
           ,est_row_nfregist_analit_difal.dm_tipo);
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_nfregist_anal_difal fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFREGIST_ANAL_DIFAL;

---------------------------------------------------------------
-- Integra os dados da nota fiscal --
---------------------------------------------------------------
PROCEDURE PKB_INTEGR_NOTA_FISCAL ( EST_LOG_GENERICO_NF      IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                , EST_ROW_NOTA_FISCAL      IN OUT NOCOPY NOTA_FISCAL%ROWTYPE
                                , EV_COD_MOD               IN MOD_FISCAL.COD_MOD%TYPE
                                , EV_COD_MATRIZ            IN EMPRESA.COD_MATRIZ%TYPE DEFAULT NULL
                                , EV_COD_FILIAL            IN EMPRESA.COD_FILIAL%TYPE DEFAULT NULL
                                , EV_EMPRESA_CPF_CNPJ      IN VARCHAR2 DEFAULT NULL -- CPF/CNPJ DA EMPRESA
                                , EV_COD_PART              IN PESSOA.COD_PART%TYPE DEFAULT NULL
                                , EV_COD_NAT               IN NAT_OPER.COD_NAT%TYPE DEFAULT NULL
                                , EV_CD_SITDOCTO           IN SIT_DOCTO.CD%TYPE DEFAULT NULL
                                , EV_COD_INFOR             IN INFOR_COMP_DCTO_FISCAL.COD_INFOR%TYPE DEFAULT NULL
                                , EV_SIST_ORIG             IN SIST_ORIG.SIGLA%TYPE DEFAULT NULL
                                , EV_COD_UNID_ORG          IN UNID_ORG.CD%TYPE DEFAULT NULL
                                , EN_MULTORG_ID            IN MULT_ORG.ID%TYPE
                                , EN_EMPRESAINTEGRBANCO_ID IN EMPRESA_INTEGR_BANCO.ID%TYPE DEFAULT NULL
                                , EN_LOTEINTWS_ID          IN LOTE_INT_WS.ID%TYPE DEFAULT 0 ) IS
  --
  vn_fase            number := 0;
  vn_loggenerico_id  log_generico_nf.id%type;
  vn_dm_st_proc      Nota_Fiscal.dm_st_proc%TYPE := null;
  vn_qtde_nf         number := 0;
  vn_qtde_erro_chave number := null;
  vv_nro_proc        ret_evento_epec.nro_proc%type;
  vv_cod_stat        ret_evento_epec.cod_stat%type;
  vn_lim_emiss_nfe   estado.lim_emiss_nfe%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  -- Monta cabecalho do Log Generico
  gv_cabec_log := null;
  --
  if nvl(est_row_Nota_Fiscal.empresa_id, 0) <= 0 then
     --
     est_row_Nota_Fiscal.empresa_id := pk_csf.fkg_empresa_id2(en_multorg_id       => en_multorg_id
                                                             ,ev_cod_matriz       => ev_cod_matriz
                                                             ,ev_cod_filial       => ev_cod_filial
                                                             ,ev_empresa_cpf_cnpj => ev_empresa_cpf_cnpj);
     --
  end if;
  --
  vn_fase := 1.1;
  --
  if nvl(est_row_Nota_Fiscal.empresa_id, 0) > 0 or
     (ev_cod_matriz is not null and ev_cod_filial is not null) then
     --
     vn_fase := 1.2;
     --
     gv_cabec_log := 'Empresa: ' ||
                     pk_csf.fkg_nome_empresa(en_empresa_id => est_row_Nota_Fiscal.empresa_id);
     --
     gv_cabec_log := gv_cabec_log || chr(10);
     --
  end if;
  --
  vn_fase := 1.3;
  --
  if nvl(est_row_Nota_Fiscal.nro_nf, 0) > 0 then
     --
     gv_cabec_log := gv_cabec_log || 'Número: ' ||
                     est_row_Nota_Fiscal.nro_nf;
     --
     gv_cabec_log := gv_cabec_log || chr(10);
     --
  end if;
  --
  vn_fase := 1.4;
  --
  if est_row_Nota_Fiscal.serie is not null then
     --
     gv_cabec_log := gv_cabec_log || 'Serie: ' ||
                     est_row_Nota_Fiscal.serie;
     --
     gv_cabec_log := gv_cabec_log || chr(10);
     --
  end if;
  --
  vn_fase := 1.5;
  --
  if trim(ev_cod_mod) is not null then
     --
     gv_cabec_log := gv_cabec_log || 'Modelo: ' || ev_cod_mod;
     --
     gv_cabec_log := gv_cabec_log || chr(10);
     --
  end if;
  --
  vn_fase := 1.6;
  --
  if est_row_Nota_Fiscal.dt_emiss is not null then
     --
     gv_cabec_log := gv_cabec_log || 'Data de Emissao: ' ||
                     to_char(est_row_Nota_Fiscal.dt_emiss, 'dd/mm/yyyy');
     --
     gv_cabec_log := gv_cabec_log || chr(10);
     --
  end if;
  --
  gv_cabec_log := gv_cabec_log || 'operação: ' ||
                  pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_IND_OPER'
                                    ,ev_vl      => est_row_Nota_Fiscal.dm_ind_oper);
  --
  gv_cabec_log := gv_cabec_log || chr(10);
  --
  gv_cabec_log := gv_cabec_log || 'Indicador do Emitente: ' ||
                  pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_IND_EMIT'
                                    ,ev_vl      => est_row_Nota_Fiscal.dm_ind_emit);
  --
  gv_cabec_log := gv_cabec_log || chr(10);
  --
  if nvl(en_loteintws_id,0) > 0 then
     --
     gv_cabec_log := gv_cabec_log || 'Lote WS: ' || en_loteintws_id;
     --
     gv_cabec_log := gv_cabec_log || chr(10);
     --
  end if;
  --
  -- Atribui a empresa para registro no log
  gn_empresa_id := est_row_Nota_Fiscal.empresa_id;
  --
  vn_fase    := 1.7;
  vn_qtde_nf := 0;
  -- Verifica se a Nota Fiscal ja existe no sistema
  if nvl(est_row_Nota_Fiscal.id, 0) <= 0 then
     --
     vn_fase := 1.71;
     --
     if ev_cod_mod in ('06', '21', '22', '28', '29', '66') then
        --
        -- 06-Nota Fiscal/Conta de Energia Eletronica
        -- 21-Nota Fiscal de serviço de Comunicacao
        -- 22-Nota Fiscal de serviço de Telecomunicacao
        -- 28-Nota Fiscal/Conta de Fornecimento de Gas Canalizado
        -- 29-Nota Fiscal/Conta de Fornecimento de agua Canalizada
        -- 66-Nota Fiscal de Energia Elétrica Eletrônica - NF3e
        --
        vn_fase := 1.72;
        --
        est_row_Nota_Fiscal.id := pk_csf.fkg_busca_notafiscal_id(en_multorg_id      => en_multorg_id
                                                                ,en_empresa_id      => est_row_Nota_Fiscal.empresa_id
                                                                ,ev_cod_mod         => ev_cod_mod
                                                                ,ev_serie           => est_row_Nota_Fiscal.serie
                                                                ,en_nro_nf          => est_row_Nota_Fiscal.nro_nf
                                                                ,en_dm_ind_oper     => est_row_Nota_Fiscal.dm_ind_oper
                                                                ,en_dm_ind_emit     => est_row_Nota_Fiscal.dm_ind_emit
                                                                ,ev_cod_part        => ev_cod_part
                                                                ,en_dm_arm_nfe_terc => est_row_Nota_Fiscal.dm_arm_nfe_terc
                                                                ,ed_dt_emiss        => est_row_Nota_Fiscal.dt_emiss);
        --
     else
        --
        vn_fase := 1.73;
        --
        est_row_Nota_Fiscal.id := pk_csf.fkg_busca_notafiscal_id(en_multorg_id      => en_multorg_id
                                                                ,en_empresa_id      => est_row_Nota_Fiscal.empresa_id
                                                                ,ev_cod_mod         => ev_cod_mod
                                                                ,ev_serie           => est_row_Nota_Fiscal.serie
                                                                ,en_nro_nf          => est_row_Nota_Fiscal.nro_nf
                                                                ,en_dm_ind_oper     => est_row_Nota_Fiscal.dm_ind_oper
                                                                ,en_dm_ind_emit     => est_row_Nota_Fiscal.dm_ind_emit
                                                                ,ev_cod_part        => ev_cod_part
                                                                ,en_dm_arm_nfe_terc => est_row_Nota_Fiscal.dm_arm_nfe_terc);
        --
     end if;
     --
  else
     --
     vn_fase := 1.8;
     -- verifica se existe mais de uma nota para empresa, modelo, serie, nro, operação, emitente e participante
     begin
        --
        select count(1)
          into vn_qtde_nf
          from Nota_Fiscal nf
              ,Mod_Fiscal  mf
         where nf.empresa_id = est_row_Nota_Fiscal.empresa_id
           and nf.dm_ind_emit = est_row_Nota_Fiscal.dm_ind_emit
           and (nf.dm_ind_emit = 0 or
               nf.dm_ind_oper = est_row_Nota_Fiscal.dm_ind_oper)
           and nf.serie = est_row_Nota_Fiscal.serie
           and nf.nro_nf = est_row_Nota_Fiscal.nro_nf
           and trunc(nf.dt_emiss) = trunc(est_row_Nota_Fiscal.dt_emiss)
           and nf.dm_arm_nfe_terc = 0 -- não é de somente armazenamento
           and mf.id = nf.modfiscal_id
           and mf.cod_mod = ev_cod_mod
           and (nf.dm_ind_emit = 0 or
               (nf.dm_ind_emit = 1 and exists
                (select 1
                    from Pessoa p
                   where p.cod_part = trim(ev_cod_part)
                     and p.id = nf.pessoa_id)));
        --
     exception
        --
        when others then
           vn_qtde_nf := 0;
           --
     end;
     --
  end if;
  --
  vn_fase := 1.9;
  -- Se a nota não existe, já¡ atribui o ID
  if nvl(est_row_Nota_Fiscal.id, 0) <= 0 then
     --
     select notafiscal_seq.nextval
       into est_row_Nota_Fiscal.id
       from dual;
     --
  end if;
  --
  --| Seta o ID de referencia da Nota Fiscal
  pkb_seta_referencia_id(en_id => est_row_Nota_Fiscal.id);
  --
  vn_fase := 1.10;
  -- remove os logs anteriores
  delete from log_generico_nf
   where referencia_id = gn_referencia_id
     and obj_referencia = gv_obj_referencia;
  --
  vn_fase := 1.11;
  /*
  -- Teste identifica que a nota que estão sendo integrada ja possui ID em NOTA_FISCAL e ja existe mais de uma nota para empresa, modelo, serie, nro, operação, emitente e participante
  if nvl(vn_qtde_nf, 0) >= 1 then
     --
     vn_fase := 1.12;
     --
     gv_mensagem_log := 'Nota Fiscal ja foi integrada.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => est_row_Nota_Fiscal.id
                        ,ev_obj_referencia   => gv_obj_referencia);
     --
  end if;*/
  -------------------------------------------------------------------------------------------------------
  --
  vn_fase := 1.11;
  -- Valida se a empresa esta ativa
  if pk_csf.fkg_empresa_id_situacao(en_empresa_id => est_row_Nota_Fiscal.empresa_id) = 0 then
     --
     vn_fase := 1.111;
     --
     gv_mensagem_log := '"Empresa" ('||pk_csf.fkg_cod_nome_empresa_id(en_empresa_id => est_row_nota_fiscal.empresa_id)||') está inativa no sistema.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     --
  end if;
  --
  --
  vn_fase := 1.12;
  -- Valida se os dados do certificado estão ok
  if est_row_Nota_Fiscal.dm_ind_emit = 0 and 
     ev_cod_mod in ('55', '65') and
     pk_csf.fkg_empresa_id_certificado_ok(en_empresa_id => est_row_Nota_Fiscal.empresa_id) = false then
     --
     vn_fase := 1.121;
     --
     gv_mensagem_log := '"Empresa" ('||est_row_Nota_Fiscal.empresa_id||') está com os dados de certificado digital inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  -------------------------------------------------------------------------------------------------------
  --| Valida a informação da empresa
  vn_fase := 2;
  --
  -- Valida se a empresa valida
  if pk_csf.fkg_empresa_id_valido(en_empresa_id => est_row_Nota_Fiscal.empresa_id) = false then
     --
     vn_fase := 2.1;
     --
     gv_mensagem_log := '"Empresa" ('||est_row_Nota_Fiscal.empresa_id||') está incorreta.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  -------------------------------------------------------------------------------------------------------
  vn_fase := 2.2;
  --
  if nvl(est_row_Nota_Fiscal.nro_nf, 0) <= 0 then
     --
     vn_fase := 2.3;
     --
     gv_mensagem_log := '"Número da Nota Fiscal" ('||nvl(est_row_Nota_Fiscal.nro_nf,0)||') não pode ser zero ou negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  -------------------------------------------------------------------------------------------------------
  --
  vn_fase       := 3;
  vn_dm_st_proc := pk_csf.fkg_st_proc_nf(en_notafiscal_id => est_row_Nota_Fiscal.id);
  vn_fase       := 3.1;
  -- Verifica se a nota estão inutilizada
  if pk_csf.fkg_nf_inutiliza(en_empresa_id => est_row_Nota_Fiscal.empresa_id
                            ,ev_cod_mod    => ev_cod_mod
                            ,en_serie      => est_row_Nota_Fiscal.serie
                            ,en_nro_nf     => est_row_Nota_Fiscal.nro_nf) = 1 and
     est_row_Nota_Fiscal.dm_ind_emit = 0 and 
     ev_cod_mod in ('55', '65') then
     --
     vn_fase := 3.2;
     --
     gv_mensagem_log := 'Nota Fiscal está inutilizada no sistema.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     vn_fase := 3.21;
     --
     update inutiliza_nota_fiscal inf
        set dm_integr_nf = 0
      where inf.empresa_id = est_row_Nota_Fiscal.empresa_id
        and inf.serie = est_row_Nota_Fiscal.serie
        and est_row_nota_fiscal.nro_nf between inf.nro_ini and
            inf.nro_fim;
     --
     commit;
     --
     -- As rotinas que utilizarem esse processo deversao verificar no seu retorno se a variavel possue informações.
     -- Essa anulasao foi feita devido a pk_integr_nfe, pois as notas estão sendo recuperadas novamente, e gerando mais registros filhos da nota.
     -- Os itens e os outros dados, passavam a ser inclusao dos a mais cada vez que a nota passava por esse processo.
     est_row_Nota_Fiscal := null;
     goto sair_integr;
     --
  elsif vn_dm_st_proc in (1, 2, 3, 4, 6, 7, 8, 14) and
        est_row_Nota_Fiscal.dm_ind_emit = 0 and
        ev_cod_mod in ('55', '65') then
     -- se dm_st_proc for:
     -- 4-Nota Autorizada
     -- 6-Nota Denegada
     -- 7-Nota Cancelada
     -- 8-Nota Inutilizada
     --
     vn_fase := 3.3;
     --
     gv_dominio := null;
     --
     gv_dominio := pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_ST_PROC'
                                     ,ev_vl      => vn_dm_st_proc);
     --
     gv_mensagem_log := 'Nota Fiscal está com a Situação '||gv_dominio||', não pode ser integrada novamente.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     --
     vn_fase := 3.31;
     --
     -- As rotinas que utilizarem esse processo deversao verificar no seu retorno se a variavel possue informações.
     -- Essa anulacao foi feita devido a pk_integr_nfe, pois as notas estão sendo recuperadas novamente, e gerando mais registros filhos da nota.
     -- Os itens e os outros dados, passavam a ser inclusao a mais cada vez que a nota passava por esse processo.
     est_row_Nota_Fiscal := null;
     goto sair_integr;
     --
  else
     --
     vn_fase := 3.4;
     --
     -- Se o Tipo de Integracao 1 (valida e insere)
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        pkb_excluir_dados_nf(en_notafiscal_id => est_row_Nota_Fiscal.id);
        --
     end if;
     --
  end if;
  -------------------------------------------------------------------------------------------------------
  --| Valida informação do participante
  --
  vn_fase := 5;
  --
  if trim(ev_cod_part) is not null and
     (trim(ev_cod_part) <> trim(EV_EMPRESA_CPF_CNPJ)) then -- Verifica se ainda e diferente do CNPJ da empresa
     --
     vn_fase := 5.1;
     --
     est_row_Nota_Fiscal.pessoa_id := pk_csf.fkg_pessoa_id_cod_part(en_multorg_id => en_multorg_id
                                                                   ,ev_cod_part   => ev_cod_part);
     --
  end if;
  --
  vn_fase := 5.2;
  --
  -- Valida a informação da pessoa
  if nvl(est_row_Nota_Fiscal.pessoa_id, 0) > 0 then
     --
     vn_fase := 5.3;
     --
     if pk_csf.fkg_Pessoa_id_valido(en_pessoa_id => est_row_Nota_Fiscal.pessoa_id) = false then
        --
        vn_fase := 5.31;
        --
        gv_mensagem_log := '"Código do emitente da nota fiscal" ('||est_row_Nota_Fiscal.pessoa_id||') está incorreto.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 5.4;
  -- Se for NOta Fiscal de Emissao de Terceiros, obrigar a informação da PESSOA_ID
  if nvl(est_row_Nota_Fiscal.pessoa_id, 0) <= 0 and
     est_row_Nota_Fiscal.dm_ind_emit = 1 and -- Terceiros
     est_row_nota_fiscal.dm_arm_nfe_terc = 0 then -- não de armazenamento Fiscal
     --
     vn_fase := 5.5;
     --
     gv_mensagem_log := 'Favor informar o Participante da Nota Fiscal (Cliente, Fornecedor, Transportadora, etc.).';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  -------------------------------------------------------------------------------------------------------
  --| Valida informação da Situação do documento
  vn_fase := 6;
  --
  if est_row_Nota_Fiscal.dm_st_proc = 8 then
     -- Inutilizada
     --
     est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id(ev_cd => '05'); -- NF-e ou CT-e : Numeração inutilizada
     --
  elsif est_row_Nota_Fiscal.dm_st_proc = 7 then
     -- Cancelada
     --
     est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id(ev_cd => '02'); -- Documento cancelado
     --
  elsif est_row_Nota_Fiscal.dm_st_proc = 6 then
     -- Denegada
     --
     est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id(ev_cd => '04'); -- NF-e ou CT-e denegado
     --
  else
     --
     if est_row_Nota_Fiscal.dm_fin_nfe = 2 then
        -- NF-e complementar
        --
        if ev_cd_sitdocto in ('06', '07') then
           -- 06-Documento Fiscal Complementar, 07-Documento Fiscal Complementar extemporâneo.
           --
           est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id(ev_cd => ev_cd_sitdocto);
           --
        else
           --
           est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id(ev_cd => '06'); -- Documento Fiscal Complementar
           --
        end if;
        --
     else
        --
        if ev_cd_sitdocto in ('00', '08') then
           -- 00-Documento regular, 08-Documento Fiscal emitido com base em Regime Especial ou Norma Específica
           --
           est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id(ev_cd => ev_cd_sitdocto);
           --
        else
           --
           est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id(ev_cd => '00'); -- Documento regular
           --
        end if;
        --
     end if;
     --
  end if;
  --
  vn_fase := 6.1;
  -- valida a informação da Situação do documento fiscal
  if nvl(est_row_Nota_Fiscal.sitdocto_id, 0) <= 0 then
     --
     vn_fase := 6.2;
     --
     gv_mensagem_log := '"Situação do Documento Fiscal" ('||ev_cd_sitdocto||') estão incorreta.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.sitdocto_id := pk_csf.fkg_Sit_Docto_id(ev_cd => '00');
     --
  end if;
  --
  vn_fase := 6.3;
  --
  -- Valida se indicador da forma de pagamento estão correto
  if est_row_Nota_Fiscal.dm_ind_Pag not in (0, 1, 2, 9) then
     --
     vn_fase := 6.4;
     --
     gv_mensagem_log := '"Indicador da forma de pagamento" ('||est_row_Nota_Fiscal.dm_ind_Pag||') está incorreto.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dm_ind_Pag := 0;
     --
  end if;
  -------------------------------------------------------------------------------------------------------
  --| Valida informação do campo natoper_id
  --
  vn_fase := 7;
  --
  -- Se informou valor no ev_cod_nat valida a natureza da operação
  if trim(ev_cod_nat) is not null then
     --
     vn_fase := 7.1;
     --
     pk_csf.pkb_cria_nat_oper( ev_cod_nat    => ev_cod_nat
                             , ev_descr_nat  => trim(est_row_Nota_Fiscal.nat_Oper)
                             , en_multorg_id => en_multorg_id );
     --
     vn_fase := 7.2;
     --
     est_row_Nota_Fiscal.natoper_id := pk_csf.fkg_natoper_id_cod_nat( ev_cod_nat    => ev_cod_nat
                                                                    , en_multorg_id => en_multorg_id);
     --
  end if;
  --
  vn_fase := 7.3;
  --
  if trim(pk_csf.fkg_converte(est_row_Nota_Fiscal.nat_Oper)) is null then
     --
     vn_fase := 7.4;
     --
     gv_mensagem_log := '"Descrição da Natureza da operação" não foi informada.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  -------------------------------------------------------------------------------------------------------
  --| Valida informação do campo modfical_id
  vn_fase := 8;
  --
  est_row_Nota_Fiscal.modfiscal_id := pk_csf.fkg_Mod_Fiscal_id(ev_cod_mod => trim(ev_cod_mod));
  --
  vn_fase := 8.1;
  --
  -- Valida a informação do modelo fiscal
  if nvl(est_row_Nota_Fiscal.modfiscal_id, 0) <= 0 then
     --
     vn_fase := 8.2;
     --
     gv_mensagem_log := '"Modelo do documento fiscal" ('||ev_cod_mod||') está incorreto.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.modfiscal_id := pk_csf.fkg_Mod_Fiscal_id(ev_cod_mod => '55');
     --
  end if;
  -------------------------------------------------------------------------------------------------------
  --| Valida informação do campo dm_ind_emit
  --
  vn_fase := 9;
  --
  -- Valida se o Indicador da Emissao estão correto
  if est_row_Nota_Fiscal.dm_ind_emit not in (0, 1) then
     --
     vn_fase := 9.1;
     --
     gv_mensagem_log := '"Indicador do emitente da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_ind_emit||') está incorreto.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dm_ind_emit := 0;
     --
  end if;
  -------------------------------------------------------------------------------------------------------
  --| Valida informação do campo dm_ind_oper
  vn_fase := 10;
  -- Valida se o indicador da operação estão correto
  if est_row_Nota_Fiscal.dm_ind_oper not in (0, 1) then
     --
     vn_fase := 10.1;
     --
     gv_mensagem_log := '"Indicador do tipo de operação da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_ind_oper||') está incorreto.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dm_ind_oper := 0;
     --
  end if;
  --
  vn_fase := 10.2;
  --
  -- Valida se o tipo da nota "Saida" não pode ser emitida por terceiros
  if est_row_Nota_Fiscal.dm_ind_oper = 1 and
     est_row_Nota_Fiscal.dm_ind_emit = 1 then
     --
     vn_fase := 10.3;
     --
     gv_mensagem_log := 'Nota Fiscal do tipo saída e registrada como emitida por "terceiros".';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  -------------------------------------------------------------------------------------------------------
  --| Valida a informação do campo dt_emiss
  --
  vn_fase := 11;
  --
  if est_row_Nota_Fiscal.dt_emiss is null then
     --
     vn_fase := 11.1;
     --
     gv_mensagem_log := '"Data de Emissão da Nota Fiscal" deve ser informada.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dt_emiss := sysdate;
     --
  end if;
  --
  if to_char((est_row_Nota_Fiscal.dt_emiss), 'hh24:mi:ss') = '00:00:00' then
     --
     est_row_Nota_Fiscal.dt_emiss := to_date(to_char(est_row_Nota_Fiscal.dt_emiss
                                                    ,'dd/mm/rrrr') || ' ' ||
                                             to_char(sysdate
                                                    ,'hh24:mi:ss')
                                            ,'dd/mm/rrrr hh24:mi:ss');
     --
  end if;
  --
  vn_fase := 11.2;
  --
  -- Valida a data de Emissao, verif. se não e maior que a data atual
  if trunc(est_row_Nota_Fiscal.dt_emiss) > sysdate then
     --
     vn_fase := 11.3;
     --
     gv_mensagem_log := 'Data de Emissão ('||to_char(est_row_Nota_Fiscal.dt_emiss,'dd/mm/rrrr hh24:mi')||') está maior que a data atual.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 11.4;
  -- Valida a data de entrada e saida e menor que a data de Emissao em notas de Emissao propria e operação de saida
  if est_row_Nota_Fiscal.dm_ind_emit = 0 and
     est_row_Nota_Fiscal.dm_ind_oper = 1 and
     est_row_Nota_Fiscal.dt_sai_ent is not null and
     est_row_Nota_Fiscal.dt_sai_ent < est_row_Nota_Fiscal.dt_emiss then
     --
     vn_fase := 11.5;
     --
     est_row_Nota_Fiscal.dt_sai_ent := est_row_Nota_Fiscal.dt_emiss;
     --
  end if;
  --
  vn_fase := 11.6;
  --
  vn_lim_emiss_nfe := pk_csf.fkg_estado_lim_emiss_nfe(en_empresa_id => est_row_Nota_Fiscal.empresa_id);
  --
  vn_fase := 11.7;
  --
  /*
  if est_row_Nota_Fiscal.dm_ind_emit = 0 and
     (trunc(sysdate) - trunc(est_row_Nota_Fiscal.dt_emiss)) > nvl(vn_lim_emiss_nfe, 0) then
     --
     vn_fase := 11.8;
     --
     gv_mensagem_log := 'Data de Emissão fora do limite estabelecido ('||vn_lim_emiss_nfe||' dias).';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;*/
  --
  -------------------------------------------------------------------------------------------------------
  --| Valida informação da serie e numero da Nota Fiscal
  --
  vn_fase := 12;
  --
  -- Valida se a serie não foi informada
  if trim(est_row_Nota_Fiscal.serie) is null then
     --
     vn_fase := 12.1;
     --
     gv_mensagem_log := 'Série da Nota Fiscal deve ser informada.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.serie := '0';
     --
  end if;
  --
  vn_fase := 12.11;
  -- valida se a serie da NFe e alfanumerica (Teste anti-burro)
  if ev_cod_mod in ('55', '65') and pk_csf.fkg_is_numerico(ev_valor => est_row_Nota_Fiscal.serie) = false then
     --
     vn_fase := 12.12;
     --
     gv_mensagem_log := 'Série da NF-e informada ('||est_row_Nota_Fiscal.serie||') deve ser do tipo numérica.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 12.2;
  --
  -- Valida a se o nro_nf foi informado
  if nvl(est_row_Nota_Fiscal.nro_nf, 0) <= 0 and ev_cod_mod <> '99' then
     --
     vn_fase := 12.3;
     --
     gv_mensagem_log := 'Número da Nota Fiscal deve ser informado.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --  
  if length(trim(est_row_Nota_Fiscal.nro_nf)) > 9 then
     --
     vn_fase := 12.4;
     --
     gv_mensagem_log := '"Número da Nota Fiscal" ('||nvl(est_row_Nota_Fiscal.nro_nf,0)||') não pode ter mais do que 9 dígitos.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);   
  end if;
  --
  vn_fase := 13;
  --
  -------------------------------------------------------------------------------------------------------
  --| Valida informação do campo dm_st_proc
  vn_fase := 14;
  --
  -- Valida se a Situação do processo estão correta
  if est_row_Nota_Fiscal.dm_st_proc not in (0,1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,18,19,99) then
     --
     vn_fase := 14.1;
     --
     gv_mensagem_log := '"Situação do processo da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_st_proc||') está incorreta.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dm_st_proc := 10;
     --
  end if;
  --
  vn_fase := 14.2;
  --
  -- Valida informação do campo dt_st_proc
  if est_row_Nota_Fiscal.dt_st_proc is null then
     --
     est_row_Nota_Fiscal.dt_st_proc := sysdate;
     --
  end if;
  --
  vn_fase := 14.3;
  --
  if nvl(est_row_Nota_Fiscal.id, 0) > 0 then
     --
     vv_nro_proc := pk_csf.fkg_ret_evento_epec_proc_id(en_notafiscal_id => est_row_Nota_Fiscal.id);
     vv_cod_stat := pk_csf.fkg_ret_evento_epec_stat_id(en_notafiscal_id => est_row_Nota_Fiscal.id);
     --
     vn_fase := 14.4;
     --
     if vv_nro_proc is not null or vv_cod_stat = '485' then -- Rejeicao: Duplicidade de numeracao do EPEC (Modelo, CNPJ, Serie e Número)
        --
        vn_fase := 14.5;
        --
        est_row_Nota_Fiscal.dm_forma_emiss := 4;
        --
        gv_mensagem_log := '"Forma de Emissão da Nota Fiscal" não pode ser alterada, pois foi emitida em EPEC.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => informacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        --
     end if;
     --
  end if;
  --
  vn_fase := 14.6;
  --
  if est_row_Nota_Fiscal.dm_ind_emit = 0 and
     pk_csf.fkg_is_numerico(ev_valor => est_row_Nota_Fiscal.serie) = true then
     --
     if to_number(est_row_Nota_Fiscal.serie) >= 900 then
        --
        est_row_Nota_Fiscal.dm_forma_emiss := 3;
        --
     end if;
     --
  end if;
  --
  --| Valida informação do campo dm_forma_emiss
  --
  vn_fase := 15;
  -- Busca a forma de Emissao habilitada para a Empresa
  if nvl(est_row_Nota_Fiscal.dm_forma_emiss, 0) <= 0 then
     --
     est_row_Nota_Fiscal.dm_forma_emiss := pk_csf.fkg_forma_emiss_empresa(en_empresa_id => est_row_Nota_Fiscal.empresa_id);
     --
  end if;
  --
  vn_fase := 15.1;
  -- Valida a Forma de Emissao da Nota Fiscal
  if est_row_Nota_Fiscal.dm_forma_emiss not in (1, 2, 3, 4, 5, 6, 7, 8, 9) then
     --
     vn_fase := 15.2;
     --
     gv_mensagem_log := '"Forma de Emissão da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_forma_emiss||') está incorreta.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dm_forma_emiss := 1;
     --
  end if;
  --
  vn_fase := 15.4;
  --
  if est_row_Nota_Fiscal.dm_ind_emit = 0 and
     pk_csf.fkg_is_numerico(ev_valor => est_row_Nota_Fiscal.serie) = true then
     --
     vn_fase := 15.41;
     -- Valida serie para Emissao de NFe normal
     if to_number(est_row_Nota_Fiscal.serie) >= 890 and
        est_row_Nota_Fiscal.dm_forma_emiss in (1, 2, 4, 5, 6, 7, 8, 9) then
        --
        vn_fase := 15.42;
        --
        gv_mensagem_log := 'Série ('||est_row_Nota_Fiscal.serie||') da NFe não permitida para Emissão em modo '||
                           pk_csf.fkg_dominio(ev_dominio => 'NOTA_FISCAL.DM_FORMA_EMISS'
                                             ,ev_vl      => est_row_Nota_Fiscal.dm_forma_emiss)||'.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
     vn_fase := 15.43;
     -- Valida serie para Emissao de NFe em modo SCAN
     if to_number(est_row_Nota_Fiscal.serie) < 900 and
        est_row_Nota_Fiscal.dm_forma_emiss in (3) then
        --
        vn_fase := 15.44;
        --
        gv_mensagem_log := 'Série ('||est_row_Nota_Fiscal.serie||') da NFe não permitida para Emissão em modo SCAN.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
     vn_fase := 15.45;
     --
     if est_row_Nota_Fiscal.dm_proc_emiss = 2 -- Emissao de NF-e avulsa, pelo contribuinte com seu certificado digital, atraves do site do Fisco
        and (to_number(est_row_Nota_Fiscal.serie) < 890 and
        to_number(est_row_Nota_Fiscal.serie) > 899) then
        --
        vn_fase := 15.46;
        --
        gv_mensagem_log := 'Serie ('||est_row_Nota_Fiscal.serie||') da NFe não permitida para Emissão de NF-e avulsa, pelo contribuinte com seu '||
                           'certificado digital, através do site do Fisco.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  -------------------------------------------------------------------------------------------------------
  --
  vn_fase := 16;
  --
     if est_row_Nota_Fiscal.dm_ind_emit = 0 then
        -- Emissao própria sempre imprime
        est_row_Nota_Fiscal.dm_impressa := 0; -- não impressa
     else
        if est_row_Nota_Fiscal.dm_arm_nfe_terc = 1 then
           -- Armazena NFe/XML de Terceiro sempre imprimi
           est_row_Nota_Fiscal.dm_impressa := 0; -- não impressa
        else
           est_row_Nota_Fiscal.dm_impressa := 1; -- Impressa
        end if;
     end if;
     --
  --| Valida informação do campo dm_impressa
  --
  vn_fase := 16.1;
  --
  -- Valida informação do campo
  if est_row_Nota_Fiscal.dm_impressa not in (0, 1, 2, 3) then
     --
     vn_fase := 16.2;
     --
     gv_mensagem_log := '"Situação da Impressão da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_impressa||') está incorreta.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  -------------------------------------------------------------------------------------------------------
  --| Valida informação do campo dm_tp_impr
  vn_fase := 17;
  --
  -- Funcao retorna o tipo de ambiente parametrizado para a empresa
  est_row_Nota_Fiscal.dm_tp_impr := pk_csf.fkg_tp_impr_empresa(en_empresa_id => est_row_Nota_Fiscal.empresa_id);
  --
  vn_fase := 17.1;
  --
  -- Formato de Impressao do DANFE
  if est_row_Nota_Fiscal.dm_tp_impr not in (0, 1, 2, 3, 4, 5) then
     --
     vn_fase := 17.2;
     --
     gv_mensagem_log := '"Formato de Impressão do DANFE" ('||est_row_Nota_Fiscal.dm_tp_impr||') está incorreto.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dm_tp_impr := 1;
     --
  end if;
  -------------------------------------------------------------------------------------------------------
  --| Valida informação do campo dm_tp_amb
  --
  vn_fase := 18;
  --
  -- Função retorna o tipo de ambiente parametrizado para a empresa
  est_row_Nota_Fiscal.dm_tp_amb := pk_csf.fkg_tp_amb_empresa(en_empresa_id => est_row_Nota_Fiscal.empresa_id);
  --
  vn_fase := 18.1;
  --
  --| Valida Identificação do Ambiente
  if est_row_Nota_Fiscal.dm_tp_amb not in (1, 2) then
     --
     vn_fase := 18.2;
     --
     gv_mensagem_log := '"Identificação do Ambiente" ('||est_row_Nota_Fiscal.dm_tp_amb||') está incorreto.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dm_tp_amb := 2;
     --
  end if;
  -------------------------------------------------------------------------------------------------------
  --| Valida informação do campo dm_fin_nfe
  vn_fase := 19;
  -- Valida a Finalidade de Emissao da Nota Fiscal
  if nvl(est_row_Nota_Fiscal.dm_fin_nfe, -1) not in (1, 2, 3, 4) then
     --
     vn_fase := 19.1;
     --
     gv_mensagem_log := '"Finalidade de Emissão da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_fin_nfe||') está incorreta.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dm_fin_nfe := 1;
     --
  end if;
  --
  --| Valida informação do campo dm_proc_emiss
  vn_fase                           := 20;
  est_row_Nota_Fiscal.dm_proc_emiss := 0;
  --
  --| Valida informação da versao do processo
  vn_fase := 21;
  -- informa a versão do compliance
  est_row_Nota_Fiscal.vers_Proc := pk_csf.fkg_ultima_versao_sistema;
  --
  --| Valida informação da autorizacao do SEFAZ
  vn_fase := 22;
  -- Se não tem valor ou inconsistente, atribui que não foi aprovada
  if est_row_Nota_Fiscal.dm_aut_sefaz not in (0, 1) or
     nvl(est_row_Nota_Fiscal.dm_aut_sefaz, 0) = 0 then
     est_row_Nota_Fiscal.dm_aut_sefaz := 0;
  end if;
  --
  --| Valida informação do Código do IBGE da cidade
  vn_fase := 23;
  -- Valida o Código IBGE da Cidade
  if pk_csf.fkg_ibge_cidade(ev_ibge_cidade => est_row_Nota_Fiscal.cidade_ibge_emit) = false and 
     est_row_Nota_Fiscal.dm_ind_emit = 0 then -- Somente Emissao propria
     --
     vn_fase := 23.1;
     --
     est_row_Nota_Fiscal.cidade_ibge_emit := 1111111;
     --
     gv_mensagem_log := '"Código do Município de Ocorrência do Fato Gerador" ('||est_row_Nota_Fiscal.cidade_ibge_emit||') não informado ou inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     --   elsif est_row_Nota_Fiscal.cidade_ibge_emit is null
  elsif nvl(est_row_Nota_Fiscal.cidade_ibge_emit, 0) <= 0 then
     --
     vn_fase := 23.2;
     --
     est_row_Nota_Fiscal.cidade_ibge_emit := 1111111;
     --
  end if;
  --
  --| Valida informação do Código do IBGE do Estado
  vn_fase := 24;
  -- Valida o Código IBGE do UF
  if pk_csf.fkg_ibge_uf_valida(ev_ibge_estado => est_row_Nota_Fiscal.uf_ibge_emit) = false and
     est_row_Nota_Fiscal.dm_ind_emit = 0 then -- Emissao própria
     --
     vn_fase := 24.1;
     --
     est_row_Nota_Fiscal.uf_ibge_emit := 11;
     --
     gv_mensagem_log := '"Código da UF do emitente do Documento Fiscal" ('||est_row_Nota_Fiscal.uf_ibge_emit||') não informado ou inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     --   elsif est_row_Nota_Fiscal.uf_ibge_emit is null
  elsif nvl(est_row_Nota_Fiscal.uf_ibge_emit, 0) <= 0 then
     --
     vn_fase := 24.2;
     --
     est_row_Nota_Fiscal.uf_ibge_emit := 11;
     --
  end if;
  --
  vn_fase := 24.2;
  --
  if est_row_Nota_Fiscal.dm_ind_emit = 0 and -- Somente Emissao própria
     ev_cod_mod in ('55', '65') and 
     pk_csf.fkg_uf_ibge_igual_empresa(en_empresa_id  => est_row_Nota_Fiscal.empresa_id
                                     ,ev_ibge_estado => est_row_Nota_Fiscal.uf_ibge_emit) = false then
     --
     vn_fase := 24.3;
     --
     gv_mensagem_log := 'Erro de Integração: "Código da UF do emitente do Documento Fiscal" ('||est_row_Nota_Fiscal.uf_ibge_emit||
                        ') não é a mesma da empresa/unidade organizacional.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  -- Registra a data da entrada da Nota Fiscal no Sistema
  vn_fase := 25;
  --
  if est_row_Nota_Fiscal.dt_hr_ent_sist is null then
     --
     est_row_Nota_Fiscal.dt_hr_ent_sist := sysdate;
     --
  end if;
  --
  vn_fase := 26;
  --
  --| Monta Chave de Referência da Nota Fiscal
  -- valida a chave de acesso de NFe de Emissao propria
  if est_row_Nota_Fiscal.dm_ind_emit = 0 then
     -- Verifica se a chave foi informada pelo ERP
     if trim(est_row_Nota_Fiscal.nro_chave_nfe) is not null then
        --
        -- Valida se a informação da Chave estão correta
        --
        vn_fase := 26.1;
        --
        -- Se a Chave de Acesso ja existe para a Nota Fiscal, então valida a informação
        pkb_valida_chave_acesso(est_log_generico_nf => est_log_generico_nf
                               ,ev_nro_chave_nfe    => est_row_Nota_Fiscal.nro_chave_nfe
                               ,en_empresa_id       => est_row_Nota_Fiscal.empresa_id
                               ,ed_dt_emiss         => est_row_Nota_Fiscal.dt_emiss
                               ,ev_cod_mod          => ev_cod_mod
                               ,en_serie            => est_row_Nota_Fiscal.serie
                               ,en_nro_nf           => est_row_Nota_Fiscal.nro_nf
                               ,en_dm_forma_emiss   => est_row_Nota_Fiscal.dm_forma_emiss
                               ,sn_cNF_nfe          => est_row_Nota_Fiscal.cNF_nfe
                               ,sn_dig_verif_chave  => est_row_Nota_Fiscal.dig_verif_chave
                               ,sn_qtde_erro        => vn_qtde_erro_chave);
        --
        vn_fase := 26.2;
        -- Se encontrou erros na chave, cria uma nova
        if nvl(vn_qtde_erro_chave, 0) > 0 then
           --
           vn_fase := 26.3;
           --
           est_row_Nota_Fiscal.dig_verif_chave := null;
           --
           est_row_nota_fiscal.cnf_nfe := to_number(to_char(est_row_Nota_Fiscal.dt_emiss
                                                           ,'RRRRMMDD'));
           --
           pkb_integr_NFChave_Refer(est_log_generico_nf => est_log_generico_nf
                                   ,en_empresa_id       => est_row_Nota_Fiscal.empresa_id
                                   ,en_notafiscal_id    => est_row_Nota_Fiscal.id
                                   ,ed_dt_emiss         => est_row_Nota_Fiscal.dt_emiss
                                   ,ev_cod_mod          => ev_cod_mod
                                   ,en_serie            => est_row_Nota_Fiscal.serie
                                   ,en_nro_nf           => est_row_Nota_Fiscal.nro_nf
                                   ,en_dm_forma_emiss   => est_row_Nota_Fiscal.dm_forma_emiss
                                   ,esn_cNF_nfe         => est_row_nota_fiscal.cnf_nfe
                                   ,sn_dig_verif_chave  => est_row_Nota_Fiscal.dig_verif_chave
                                   ,sv_nro_chave_nfe    => est_row_Nota_Fiscal.nro_chave_nfe);
           --
           vn_fase := 26.4;
           -- Grava o log de criacao de uma nova chave
           gv_mensagem_log := 'Gerada uma nova Chave de Acesso.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => 1
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           --
        end if;
        --
     else
        --
        -- Verifica se ja existe chave para a Nota Fiscal, se não existir, cria a chave
        --
        vn_fase := 26.5;
        --
        est_row_nota_fiscal.cnf_nfe := to_number(to_char(est_row_Nota_Fiscal.dt_emiss
                                                        ,'RRRRMMDD'));
        --
        pkb_integr_NFChave_Refer(est_log_generico_nf => est_log_generico_nf
                                ,en_empresa_id       => est_row_Nota_Fiscal.empresa_id
                                ,en_notafiscal_id    => est_row_Nota_Fiscal.id
                                ,ed_dt_emiss         => est_row_Nota_Fiscal.dt_emiss
                                ,ev_cod_mod          => ev_cod_mod
                                ,en_serie            => est_row_Nota_Fiscal.serie
                                ,en_nro_nf           => est_row_Nota_Fiscal.nro_nf
                                ,en_dm_forma_emiss   => est_row_Nota_Fiscal.dm_forma_emiss
                                ,esn_cNF_nfe         => est_row_Nota_Fiscal.cNF_nfe
                                ,sn_dig_verif_chave  => est_row_Nota_Fiscal.dig_verif_chave
                                ,sv_nro_chave_nfe    => est_row_Nota_Fiscal.nro_chave_nfe);
        --
     end if;
     --
  --#73490
  else --terceiro
     -- Verifica se a chave foi informada pelo ERP
     if trim(est_row_Nota_Fiscal.nro_chave_nfe) is null 
       and  ev_cod_mod in ('66') then
       --
       vn_fase := 26.55;
       --
       gv_mensagem_log := 'Não foi informada a Chave de Acesso Nfe da nota fiscal de Terceiro Nro_Nf '||est_row_Nota_Fiscal.nro_nf||', serie '||est_row_Nota_Fiscal.serie
                           ||', Dt_emiss '||est_row_Nota_Fiscal.dt_emiss||', modelo '||ev_cod_mod||', que é obrigatória para este modelo. '||
                           '(Processo que gerou msg de erro: pk_csf_api_sc.pkb_integr_nota_fiscal / Fase: '||vn_fase||').';
       
       --
       vn_loggenerico_id := null;
       --
       pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                          ,ev_mensagem         => gv_cabec_log
                          ,ev_resumo           => gv_mensagem_log
                          ,en_tipo_log         => erro_de_validacao
                          ,en_referencia_id    => gn_referencia_id
                          ,ev_obj_referencia   => gv_obj_referencia);
       -- Armazena o "loggenerico_id" na memoria
       pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                             ,est_log_generico_nf => est_log_generico_nf);
       --
     end if;
     --
  end if;
  --
  vn_fase := 26.6;
  --
  if ev_cod_mod not in ('55', '65') and
     trim(est_row_Nota_Fiscal.nro_chave_nfe) is not null then
     --
     vn_fase := 26.7;
     --
     gv_mensagem_log := 'Não pode ser informada a chave de acesso para nota fiscal do modelo ('||ev_cod_mod||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 26.8;
  -- validacao NF-e: A chave da NF-e ja¡ existe com XML armazenado e estão cancelada
  if nvl(est_row_Nota_Fiscal.dm_ind_emit, 0) = 1 and
     trim(ev_cod_mod) = '55' and
     trim(est_row_Nota_Fiscal.nro_chave_nfe) is not null and
     fkg_xml_nota_fiscal_chv(ev_nro_chave_nfe => trim(est_row_Nota_Fiscal.nro_chave_nfe)) = true then
     --
     vn_fase := 26.9;
     --
     gv_mensagem_log := 'Através da Chave da NF-e de terceiro, foi encontrado XML armazenado com Situação de Cancelamento (chave = '||
                        trim(trim(est_row_Nota_Fiscal.nro_chave_nfe))||').';
     --
     vn_loggenerico_id := null;
     --
     pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                   ,ev_mensagem         => gv_cabec_log
                                   ,ev_resumo           => gv_mensagem_log
                                   ,en_tipo_log         => erro_de_validacao
                                   ,en_referencia_id    => gn_referencia_id
                                   ,ev_obj_referencia   => gv_obj_referencia);
     --
     -- Armazena o "loggenerico_id" na memoria
     pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                      ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 27;
  -- Valida o campo dm_st_email
  if est_row_Nota_Fiscal.dm_st_email not in (0, 1, 2, 3, 4) then
     --
     vn_fase := 27.1;
     --
     gv_mensagem_log := '"Situação de envio de e-mail da Nota Fiscal" ('||est_row_Nota_Fiscal.dm_st_email||') está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
     est_row_Nota_Fiscal.dm_st_email := 0;
     --
  else
     --
     vn_fase := 27.2;
     --
     est_row_Nota_Fiscal.dm_st_email := 0;
     --
  end if;
  --
  vn_fase := 28;
  --
  -- #69101 - retirado o zero da clausula not in.
  if nvl(est_row_Nota_Fiscal.dm_tp_assinante, 0) not in ( 1, 2, 3, 4, 5, 6) then
     est_row_Nota_Fiscal.dm_tp_assinante := 1;
  end if;
  --
  vn_fase := 29;
  --
  est_row_Nota_Fiscal.inforcompdctofiscal_id := pk_csf.fkg_Infor_Comp_Dcto_Fiscal_id(en_multorg_id => en_multorg_id
                                                                                    ,en_cod_infor  => ev_cod_infor);
  --
  if nvl(est_row_Nota_Fiscal.inforcompdctofiscal_id, 0) <= 0 and
     trim(ev_cod_infor) is not null then
     --
     vn_fase := 29.1;
     --
     gv_mensagem_log := '"Código da Informação do Documento Fiscal" ('||ev_cod_infor||') está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 30;
  -- Sistema de Origem
  est_row_Nota_Fiscal.sistorig_id := pk_csf.fkg_sist_orig_id(en_multorg_id => en_multorg_id
                                                            ,ev_sigla      => trim(ev_sist_orig));
  --
  vn_fase := 30.1;
  -- verifica se o sistema de origem não foi encontrado
  if nvl(est_row_Nota_Fiscal.sistorig_id, 0) <= 0 and
     trim(ev_sist_orig) is not null then
     --
     vn_fase := 30.2;
     --
     gv_mensagem_log := '"Sistema de Origem" ('||ev_sist_orig||') não está informado nas parametrizações do Compliance!';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 31;
  -- Unidade Organizacional
  est_row_Nota_Fiscal.unidorg_id := pk_csf.fkg_unig_org_id(en_empresa_id   => est_row_Nota_Fiscal.empresa_id
                                                          ,ev_cod_unid_org => trim(ev_cod_unid_org));
  --
  vn_fase := 31.1;
  --
  if nvl(est_row_Nota_Fiscal.unidorg_id, 0) <= 0 and
     trim(ev_cod_unid_org) is not null then
     --
     vn_fase := 31.2;
     --
     gv_mensagem_log := '"Unidade Organizacional" ('||ev_cod_unid_org||') não está relacionada a empresa ('||
                        pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => est_row_Nota_Fiscal.empresa_id)||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 32;
  -- valida o formato do campo "Hora de Saida/Entrada" se for informado
  if est_row_Nota_Fiscal.hora_sai_ent is not null then
     --
     if length(trim(est_row_Nota_Fiscal.hora_sai_ent)) <> 8 then
        --
        est_row_Nota_Fiscal.hora_sai_ent := 0 ||
                                            trim(est_row_Nota_Fiscal.hora_sai_ent);
        --
     end if;
     --
     vn_fase := 32.2;
     -- valida formato da hora
     if trim(pk_csf.fkg_vld_formato_hora(est_row_Nota_Fiscal.hora_sai_ent,'hh24:mi:ss')) is null then
        --
        vn_fase := 32.3;
        --
        gv_mensagem_log := '"Hora de Saída/Entrada" está com o formato inválido ('||est_row_Nota_Fiscal.hora_sai_ent||'), o correto e "HH:MM:SS".';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
     vn_fase := 32.4;
     --
     if est_row_Nota_Fiscal.dt_sai_ent is null then
        --
        vn_fase := 32.5;
        --
        gv_mensagem_log := 'Informar a "Data de Saída/Entrada" quando for informada a "Hora de Saída/Entrada".';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 33;
  --
  if est_row_Nota_Fiscal.nro_chave_cte_ref is not null then
     --
     vn_fase := 33.1;
     --
     if length(est_row_Nota_Fiscal.nro_chave_cte_ref) <> 44 then
        --
        gv_mensagem_log := '"Chave de acesso do CT-e referenciada" está inválida ('||est_row_Nota_Fiscal.nro_chave_cte_ref||').';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
     vn_fase := 33.2;
     --
     if substr(trim(est_row_Nota_Fiscal.nro_chave_cte_ref), 21, 2) <> '57' then
        --
        gv_mensagem_log := 'Modelo do CT-e referenciado diferente de 57. ('||est_row_Nota_Fiscal.nro_chave_cte_ref||').';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 34;
  -- Caso a forma de Emissao seja contingencia, informar Data e Justificativa de contingencia
  if nvl(est_row_Nota_Fiscal.dm_forma_emiss, 0) <> 1 then
     --
     if pk_csf.fkg_dt_cont_nf(en_notafiscal_id => est_row_Nota_Fiscal.id) is null then
        est_row_Nota_Fiscal.dt_cont := sysdate;
     end if;
     --
     if nvl(est_row_Nota_Fiscal.dm_forma_emiss, 0) in (2, 5, 9) then
        -- 2-ContingenciaFS ou 5-Contingencia FS-DA
        est_row_Nota_Fiscal.just_cont := 'Sem comunicacao de internet com a Sefaz';
     elsif nvl(est_row_Nota_Fiscal.dm_forma_emiss, 0) in (3) then
        -- 3-Contingencia SCAN
        est_row_Nota_Fiscal.just_cont := 'Sefaz fora do ar';
     elsif nvl(est_row_Nota_Fiscal.dm_forma_emiss, 0) in (4) then
        -- 4-Contingencia DPEC
        est_row_Nota_Fiscal.just_cont := 'DANFE impresso em contingencia - DPEC regularmente recebida pela Receita Federal do Brasil';
     elsif nvl(est_row_Nota_Fiscal.dm_forma_emiss, 0) in (6) then
        -- 6-Contingencia SVC-AN
        est_row_Nota_Fiscal.just_cont := 'DANFE impresso em contingencia SVC-AN regularmente recebida pela Receita Federal do Brasil';
     elsif nvl(est_row_Nota_Fiscal.dm_forma_emiss, 0) in (7) then
        -- 7-Contingencia SVC-RS
        est_row_Nota_Fiscal.just_cont := 'DANFE impresso em contingencia SVC-RS regularmente recebida pela Receita Federal do Brasil';
     end if;
     --
  end if;
  --
  vn_fase := 35;
  -- verifica usuario do ERP
  if trim(est_row_Nota_Fiscal.id_usuario_erp) is not null then
     --
     vn_fase := 35.1;
     --
     est_row_Nota_Fiscal.usuario_id := pk_csf.fkg_neo_usuario_id_conf_erp(en_multorg_id => en_multorg_id
                                                                         ,ev_id_erp     => trim(est_row_Nota_Fiscal.id_usuario_erp));
     --
     vn_fase := 35.2;
     --
     if nvl(est_row_Nota_Fiscal.usuario_id, 0) <= 0 then
        --
        est_row_Nota_Fiscal.id_usuario_erp := null;
        --
     else
        --
        gt_row_nota_fiscal.usuario_id := est_row_Nota_Fiscal.usuario_id;
        --
     end if;
     --
     vn_fase := 35.3;
     --
  end if;
  --
  est_row_Nota_Fiscal.versao := null;
  --
  -------------------------------------------------------------------------------------------------------
  vn_fase := 99;
  -- Se não teve erro na validacao, integra a nota fiscal
  -- Se não existe registro de Log e o Tipo de Integracao  1 (valida e insere)
  if nvl(est_log_generico_nf.count, 0) > 0 then
     -- Verifica se existe log de erro no processo
     if fkg_ver_erro_log_generico_nfsc( est_row_Nota_Fiscal.Id ) = 1 then
        --
        est_row_Nota_Fiscal.dm_st_proc := 10;
        --
     else
       --
        if est_row_Nota_Fiscal.dm_st_proc = 0 then
           est_row_Nota_Fiscal.dm_st_proc := 1;
        end if;
        --   
     end if;
  else
     --
     if est_row_Nota_Fiscal.dm_st_proc = 0 then
        est_row_Nota_Fiscal.dm_st_proc := 1;
     end if;
     --
  end if;
  --
  if est_row_nota_fiscal.dm_legado is null then
     --
     if est_row_nota_fiscal.dm_st_proc = 4 then -- Autorizada
        est_row_nota_fiscal.dm_legado := 1; -- Legado Autorizado
     elsif est_row_nota_fiscal.dm_st_proc = 6 then -- Denegada
           est_row_nota_fiscal.dm_legado := 2; -- Legado Denegado
     elsif est_row_nota_fiscal.dm_st_proc = 7 then -- Cancelada
           est_row_nota_fiscal.dm_legado := 3; -- Legado Cancelado
     elsif est_row_nota_fiscal.dm_st_proc = 8 then -- Inutilizada
           est_row_nota_fiscal.dm_legado := 4; -- Legado Inutilizado
     else
        est_row_nota_fiscal.dm_legado := 0; -- Não é Legado
     end if;
     --
  end if;
  --
  if to_char((est_row_Nota_Fiscal.dt_emiss), 'hh24:mi:ss') = '00:00:00' then
     --
     est_row_Nota_Fiscal.dt_emiss := to_date(to_char(est_row_Nota_Fiscal.dt_emiss
                                                    ,'dd/mm/rrrr') || ' ' || to_char(sysdate,'hh24:mi:ss'),'dd/mm/rrrr hh24:mi:ss');
     --
  end if;
  --
  if nvl(est_row_Nota_Fiscal.empresa_id, 0) > 0 and
     nvl(est_row_Nota_Fiscal.sitdocto_id, 0) > 0 and
     est_row_Nota_Fiscal.dm_ind_Pag in (0, 1, 2, 9) and
     nvl(est_row_Nota_Fiscal.modfiscal_id, 0) > 0 and
     est_row_Nota_Fiscal.dm_ind_emit in (0, 1) and
     est_row_Nota_Fiscal.dm_ind_oper in (0, 1) and
     est_row_Nota_Fiscal.dt_emiss is not null and
     est_row_Nota_Fiscal.serie is not null and
     est_row_Nota_Fiscal.dm_fin_nfe in (1, 2, 3, 4) and
     est_row_Nota_Fiscal.dm_proc_emiss in (0, 1, 2, 3) and
     trim(est_row_Nota_Fiscal.vers_Proc) is not null and
     est_row_Nota_Fiscal.dm_aut_sefaz in (0, 1) and
     nvl(est_row_Nota_Fiscal.cidade_ibge_emit, 0) > 0 and
     nvl(est_row_Nota_Fiscal.uf_ibge_emit, 0) > 0 and
     est_row_Nota_Fiscal.dt_hr_ent_sist is not null and
     est_row_Nota_Fiscal.dm_st_email in (0, 1, 2, 3) then
     --
     vn_fase := 99.1;
     --
     -- Calcula a quantidade de registros Totais integrados para ser
     -- mostrado na tela de agendamento.
     --
     if ev_cod_mod in ('06', '21', '22', '28', '29', '66') then
        --
        gv_cd_obj := '5'; -- Notas Fiscais de serviços Continuos (Agua, Luz, etc.)
        --
     elsif ev_cod_mod in ('55', '04', '01', '1B', '65') then
        --
        gv_cd_obj := '6'; -- Notas Fiscais Mercantis
        --
     elsif ev_cod_mod = '99' then
        --
        gv_cd_obj := '7'; -- Notas Fiscais de serviços EFD
        --
     end if;
     --
     begin
        pk_agend_integr.gvtn_qtd_total(gv_cd_obj) := nvl(pk_agend_integr.gvtn_qtd_total(gv_cd_obj),0) + 1;
     exception
        when others then
           null;
     end;
     --
     est_row_Nota_Fiscal.id_tag_nfe        := 'NFe' ||
                                              trim(est_row_Nota_Fiscal.nro_chave_nfe);
     est_row_Nota_Fiscal.pk_nitem          := trim(est_row_Nota_Fiscal.pk_nitem);
     est_row_Nota_Fiscal.nat_Oper          := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal.nat_Oper));
     est_row_Nota_Fiscal.Local_Embarq      := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal.Local_Embarq));
     est_row_Nota_Fiscal.nf_empenho        := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal.nf_empenho));
     est_row_Nota_Fiscal.pedido_compra     := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal.pedido_compra, 0, 1, 2, 1, 1));
     est_row_Nota_Fiscal.contrato_compra   := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal.contrato_compra));
     est_row_Nota_Fiscal.vers_Proc         := trim(est_row_Nota_Fiscal.vers_Proc);
     est_row_Nota_Fiscal.nro_chave_nfe     := trim(est_row_Nota_Fiscal.nro_chave_nfe);
     est_row_Nota_Fiscal.id_usuario_erp    := trim(est_row_Nota_Fiscal.id_usuario_erp);
     est_row_Nota_Fiscal.cod_cta           := trim(est_row_Nota_Fiscal.cod_cta);
     est_row_Nota_Fiscal.dm_st_integra     := nvl(est_row_Nota_Fiscal.dm_st_integra,0);
     est_row_Nota_Fiscal.vias_danfe_custom := nvl(est_row_Nota_Fiscal.vias_danfe_custom,0);
     est_row_Nota_Fiscal.nro_ord_emb       := trim(est_row_Nota_Fiscal.nro_ord_emb);
     --
     -- Se a nota fiscal ja existe, faz a atualizacao dos dados
     if pk_csf.fkg_existe_nf(en_nota_fiscal => est_row_Nota_Fiscal.id) = true then
        --
        vn_fase := 99.2;
        --
        -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_02 (carrega)
        gv_objeto := 'pk_csf_api_sc.pkb_integr_nota_fiscal'; 
        gn_fase   := vn_fase;
        --
        update Nota_Fiscal
           set empresa_id             = est_row_Nota_Fiscal.empresa_id
              ,pessoa_id              = est_row_Nota_Fiscal.pessoa_id
              ,sitdocto_id            = est_row_Nota_Fiscal.sitdocto_id
              ,natoper_id             = est_row_Nota_Fiscal.natoper_id
              ,lote_id                = null
              ,versao                 = est_row_Nota_Fiscal.versao
              ,id_tag_nfe             = est_row_Nota_Fiscal.id_tag_nfe
              ,pk_nitem               = est_row_Nota_Fiscal.pk_nitem
              ,nat_Oper               = est_row_Nota_Fiscal.nat_Oper
              ,dm_ind_Pag             = est_row_Nota_Fiscal.dm_ind_Pag
              ,modfiscal_id           = est_row_Nota_Fiscal.modfiscal_id
              ,dm_ind_emit            = est_row_Nota_Fiscal.dm_ind_emit
              ,dm_ind_oper            = est_row_Nota_Fiscal.dm_ind_oper
              ,dt_sai_ent             = est_row_Nota_Fiscal.dt_sai_ent
              ,dt_emiss               = est_row_Nota_Fiscal.dt_emiss
              ,nro_nf                 = est_row_Nota_Fiscal.nro_nf
              ,serie                  = est_row_Nota_Fiscal.serie
              ,UF_Embarq              = est_row_Nota_Fiscal.UF_Embarq
              ,Local_Embarq           = est_row_Nota_Fiscal.Local_Embarq
              ,nf_empenho             = est_row_Nota_Fiscal.nf_empenho
              ,pedido_compra          = est_row_Nota_Fiscal.pedido_compra
              ,contrato_compra        = est_row_Nota_Fiscal.contrato_compra
              ,dm_st_proc             = est_row_Nota_Fiscal.dm_st_proc
              ,dt_st_proc             = est_row_Nota_Fiscal.dt_st_proc
              ,dm_forma_emiss         = est_row_Nota_Fiscal.dm_forma_emiss
              ,dm_impressa            = est_row_Nota_Fiscal.dm_impressa
              ,dm_tp_impr             = est_row_Nota_Fiscal.dm_tp_impr
              ,dm_tp_amb              = est_row_Nota_Fiscal.dm_tp_amb
              ,dm_fin_nfe             = est_row_Nota_Fiscal.dm_fin_nfe
              ,dm_proc_emiss          = est_row_Nota_Fiscal.dm_proc_emiss
              ,vers_Proc              = est_row_Nota_Fiscal.vers_Proc
              ,dt_aut_sefaz           = est_row_Nota_Fiscal.dt_aut_sefaz
              ,dm_aut_sefaz           = est_row_Nota_Fiscal.dm_aut_sefaz
              ,cidade_ibge_emit       = est_row_Nota_Fiscal.cidade_ibge_emit
              ,uf_ibge_emit           = est_row_Nota_Fiscal.uf_ibge_emit
              ,dt_hr_ent_sist         = est_row_Nota_Fiscal.dt_hr_ent_sist
              ,nro_chave_nfe          = est_row_Nota_Fiscal.nro_chave_nfe
              ,cNF_nfe                = est_row_Nota_Fiscal.cNF_nfe
              ,dig_verif_chave        = est_row_Nota_Fiscal.dig_verif_chave
              ,dm_st_email            = est_row_Nota_Fiscal.dm_st_email
              ,id_usuario_erp         = est_row_Nota_Fiscal.id_usuario_erp
              ,impressora_id          = est_row_Nota_Fiscal.impressora_id
              ,usuario_id             = est_row_Nota_Fiscal.usuario_id
              ,sub_serie              = est_row_Nota_Fiscal.sub_serie
              ,inforcompdctofiscal_id = est_row_Nota_Fiscal.inforcompdctofiscal_id
              ,cod_cta                = est_row_Nota_Fiscal.cod_cta
              ,dm_tp_assinante        = est_row_Nota_Fiscal.dm_tp_assinante
              ,dm_st_integra          = est_row_Nota_Fiscal.dm_st_integra
              ,sistorig_id            = est_row_nota_fiscal.sistorig_id
              ,unidorg_id             = est_row_nota_fiscal.unidorg_id
              ,hora_sai_ent           = est_row_nota_fiscal.hora_sai_ent
              ,nro_chave_cte_ref      = est_row_nota_fiscal.nro_chave_cte_ref
              ,dt_cont                = est_row_nota_fiscal.dt_cont
              ,just_cont              = est_row_nota_fiscal.just_cont
              ,vias_danfe_custom      = est_row_Nota_Fiscal.vias_danfe_custom
              ,nro_ord_emb            = est_row_Nota_Fiscal.nro_ord_emb
              ,seq_nro_ord_emb        = est_row_Nota_Fiscal.seq_nro_ord_emb
              ,empresaintegrbanco_id  = en_empresaintegrbanco_id
              ,dm_legado              = est_row_nota_fiscal.dm_legado
         where id = est_row_Nota_Fiscal.id;
        --
        -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_02 (limpa)
        gv_objeto := null;
        gn_fase   := null;
        --
     else
        --
        vn_fase := 99.3;
        --
        if nvl(est_row_Nota_Fiscal.id, 0) = 0 then
           --
           select notafiscal_seq.nextval
             into est_row_Nota_Fiscal.id
             from dual;
           --
        end if;
        --
        vn_fase := 99.4;
        --
        -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_02 (carrega)
        gv_objeto := 'pk_csf_api_sc.pkb_integr_nota_fiscal'; 
        gn_fase   := vn_fase;
        --
        insert into Nota_Fiscal
           (id
           ,empresa_id
           ,pessoa_id
           ,sitdocto_id
           ,natoper_id
           ,lote_id
           ,versao
           ,id_tag_nfe
           ,pk_nitem
           ,nat_Oper
           ,dm_ind_Pag
           ,modfiscal_id
           ,dm_ind_emit
           ,dm_ind_oper
           ,dt_sai_ent
           ,dt_emiss
           ,nro_nf
           ,serie
           ,UF_Embarq
           ,Local_Embarq
           ,nf_empenho
           ,pedido_compra
           ,contrato_compra
           ,dm_st_proc
           ,dt_st_proc
           ,dm_forma_emiss
           ,dm_impressa
           ,dm_tp_impr
           ,dm_tp_amb
           ,dm_fin_nfe
           ,dm_proc_emiss
           ,vers_Proc
           ,dt_aut_sefaz
           ,dm_aut_sefaz
           ,cidade_ibge_emit
           ,uf_ibge_emit
           ,dt_hr_ent_sist
           ,nro_chave_nfe
           ,cNF_nfe
           ,dig_verif_chave
           ,dm_st_email
           ,id_usuario_erp
           ,impressora_id
           ,usuario_id
           ,dm_st_integra
           ,vias_danfe_custom
           ,sub_serie
           ,inforcompdctofiscal_id
           ,cod_cta
           ,dm_tp_assinante
           ,sistorig_id
           ,unidorg_id
           ,hora_sai_ent
           ,nro_chave_cte_ref
           ,dt_cont
           ,just_cont
           ,seq_nro_ord_emb
           ,nro_ord_emb
           ,empresaintegrbanco_id
           ,dm_legado)
        values
           (est_row_Nota_Fiscal.id
           ,est_row_Nota_Fiscal.empresa_id
           ,est_row_Nota_Fiscal.pessoa_id
           ,est_row_Nota_Fiscal.sitdocto_id
           ,est_row_Nota_Fiscal.natoper_id
           ,est_row_Nota_Fiscal.lote_id
           ,est_row_Nota_Fiscal.versao
           ,est_row_Nota_Fiscal.id_tag_nfe
           ,est_row_Nota_Fiscal.pk_nitem
           ,est_row_Nota_Fiscal.nat_Oper
           ,est_row_Nota_Fiscal.dm_ind_Pag
           ,est_row_Nota_Fiscal.modfiscal_id
           ,est_row_Nota_Fiscal.dm_ind_emit
           ,est_row_Nota_Fiscal.dm_ind_oper
           ,est_row_Nota_Fiscal.dt_sai_ent
           ,est_row_Nota_Fiscal.dt_emiss
           ,est_row_Nota_Fiscal.nro_nf
           ,est_row_Nota_Fiscal.serie
           ,est_row_Nota_Fiscal.UF_Embarq
           ,est_row_Nota_Fiscal.Local_Embarq
           ,est_row_Nota_Fiscal.nf_empenho
           ,est_row_Nota_Fiscal.pedido_compra
           ,est_row_Nota_Fiscal.contrato_compra
           ,est_row_Nota_Fiscal.dm_st_proc
           ,est_row_Nota_Fiscal.dt_st_proc
           ,est_row_Nota_Fiscal.dm_forma_emiss
           ,est_row_Nota_Fiscal.dm_impressa
           ,est_row_Nota_Fiscal.dm_tp_impr
           ,est_row_Nota_Fiscal.dm_tp_amb
           ,est_row_Nota_Fiscal.dm_fin_nfe
           ,est_row_Nota_Fiscal.dm_proc_emiss
           ,est_row_Nota_Fiscal.vers_Proc
           ,est_row_Nota_Fiscal.dt_aut_sefaz
           ,est_row_Nota_Fiscal.dm_aut_sefaz
           ,est_row_Nota_Fiscal.cidade_ibge_emit
           ,est_row_Nota_Fiscal.uf_ibge_emit
           ,est_row_Nota_Fiscal.dt_hr_ent_sist
           ,est_row_Nota_Fiscal.nro_chave_nfe
           ,est_row_Nota_Fiscal.cNF_nfe
           ,est_row_Nota_Fiscal.dig_verif_chave
           ,est_row_Nota_Fiscal.dm_st_email
           ,est_row_Nota_Fiscal.id_usuario_erp
           ,est_row_Nota_Fiscal.impressora_id
           ,est_row_Nota_Fiscal.usuario_id
           ,est_row_Nota_Fiscal.dm_st_integra
           ,est_row_Nota_Fiscal.vias_danfe_custom
           ,est_row_Nota_Fiscal.sub_serie
           ,est_row_Nota_Fiscal.inforcompdctofiscal_id
           ,est_row_Nota_Fiscal.cod_cta
           ,est_row_Nota_Fiscal.dm_tp_assinante
           ,est_row_Nota_Fiscal.sistorig_id
           ,est_row_Nota_Fiscal.unidorg_id
           ,est_row_Nota_Fiscal.hora_sai_ent
           ,est_row_Nota_Fiscal.nro_chave_cte_ref
           ,est_row_Nota_Fiscal.dt_cont
           ,est_row_Nota_Fiscal.just_cont
           ,est_row_Nota_Fiscal.seq_nro_ord_emb
           ,est_row_Nota_Fiscal.nro_ord_emb
           ,en_empresaintegrbanco_id
           ,est_row_nota_fiscal.dm_legado);
        --
        -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_02 (limpa)
        gv_objeto := null;
        gn_fase   := null;
        --
     end if;
     --
  end if; -- campos obrigatórios
  --
  <<sair_integr>>
  null;
  --
EXCEPTION
  when others then
     --
     if sqlcode = -1 then
        --
        est_row_Nota_Fiscal.id := pk_csf.fkg_busca_notafiscal_id(en_multorg_id      => en_multorg_id
                                                                ,en_empresa_id      => est_row_Nota_Fiscal.empresa_id
                                                                ,ev_cod_mod         => ev_cod_mod
                                                                ,ev_serie           => est_row_Nota_Fiscal.serie
                                                                ,en_nro_nf          => est_row_Nota_Fiscal.nro_nf
                                                                ,en_dm_ind_oper     => est_row_Nota_Fiscal.dm_ind_oper
                                                                ,en_dm_ind_emit     => est_row_Nota_Fiscal.dm_ind_emit
                                                                ,ev_cod_part        => ev_cod_part
                                                                ,en_dm_arm_nfe_terc => est_row_Nota_Fiscal.dm_arm_nfe_terc);
        --
        gv_mensagem_log := 'Aviso: Nota Fiscal já existe no sistema, não será re-integrada novamente!';
        --
        declare
           vn_loggenerico_id log_generico_nf.id%type;
        begin
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => est_row_Nota_Fiscal.id
                              ,ev_obj_referencia   => gv_obj_referencia);
        exception
           when others then
              null;
        end;
        --
        est_row_Nota_Fiscal.id := null;
        --
     else
        --
        gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal fase ('||vn_fase||'): '||sqlerrm;
        --
        declare
           vn_loggenerico_id log_generico_nf.id%type;
        begin
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
        exception
           when others then
              null;
        end;
        --
     end if;
     --
END PKB_INTEGR_NOTA_FISCAL;

-------------------------------------------------------------------------------------------------------

-- Integra as informações da Nota Fiscal de serviço - campos flex field
procedure pkb_integr_nota_fiscal_serv_ff ( est_log_generico_nf   in out nocopy  dbms_sql.number_table
                                     , en_notafiscal_id      in             nota_fiscal.id%type
                                     , ev_atributo           in             varchar2
                                     , ev_valor              in             varchar2 )
is
--
vn_fase                 number := 0;
vn_loggenericonf_id     log_generico_nf.id%type;
vn_dmtipocampo          ff_obj_util_integr.dm_tipo_campo%type;
vv_mensagem             varchar2(1000) := null;
vn_qtde_nf              number := 0;
vn_id_erp               nota_fiscal_compl.id_erp%type;
--
begin
--
vn_fase := 1;
--
gv_mensagem_log := null;
--
if ev_atributo is null then
  --
  vn_fase := 2;
  --
  gv_mensagem_log := 'Nota Fiscal de Serviço: "Atributo" deve ser informado.';
  --
  vn_loggenericonf_id := null;
  --
  pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                      , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                      , ev_resumo            => gv_mensagem_log
                      , en_tipo_log          => erro_de_validacao
                      , en_referencia_id     => gn_referencia_id
                      , ev_obj_referencia    => gv_obj_referencia );
  --
  -- Armazena o "loggenerico_id" na memória
  pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                         , est_log_generico_nf  => est_log_generico_nf );
  --
end if;
--
vn_fase := 3;
--
if ev_valor is null then
  --
  vn_fase := 3.1;
  --
  gv_mensagem_log := 'Nota Fiscal de Serviço: "VALOR" referente ao atributo deve ser informado.';
  --
  vn_loggenericonf_id := null;
  --
  pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                      , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                      , ev_resumo            => gv_mensagem_log
                      , en_tipo_log          => erro_de_validacao
                      , en_referencia_id     => gn_referencia_id
                      , ev_obj_referencia    => gv_obj_referencia );
  --
  -- Armazena o "loggenerico_id" na memória
  pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                         , est_log_generico_nf  => est_log_generico_nf );
  --
end if;
--
vn_fase := 4;
--
vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_NF_SERV_CONT_FF'
                                        , ev_atributo => ev_atributo
                                        , ev_valor    => ev_valor );
--
vn_fase := 4.1;
--
if vv_mensagem is not null then
  --
  vn_fase := 4.2;
  --
  gv_mensagem_log := vv_mensagem;
  --
  vn_loggenericonf_id := null;
  --
  pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                      , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                      , ev_resumo            => gv_mensagem_log
                      , en_tipo_log          => erro_de_validacao
                      , en_referencia_id     => gn_referencia_id
                      , ev_obj_referencia    => gv_obj_referencia );
  --
  -- Armazena o "loggenerico_id" na memória
  pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                         , est_log_generico_nf  => est_log_generico_nf );
  --
else
  --
  vn_fase := 5;
  --
  vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_NF_SERV_CONT_FF'
                                                     , ev_atributo => ev_atributo );
  --
  vn_fase := 6;
  --
  if trim(ev_atributo) = 'ID_ERP' then
     --
     vn_fase := 20;
     --
     if trim(ev_valor) is not null then
        --
        vn_fase := 20.1;
        --
        if vn_dmtipocampo = 1 then -- tipo de campo = numérico
           --
           vn_fase := 20.2;
           --
           if pk_csf.fkg_is_numerico( trim(ev_valor) ) then
             --
             vn_fase := 20.3;
             --
             vn_id_erp := pk_csf.fkg_ff_ret_vlr_number ( ev_obj_name => 'VW_CSF_NF_SERV_CONT_FF'
                                                       , ev_atributo => trim(ev_atributo)
                                                       , ev_valor    => trim(ev_valor)
                                                       );
             --
           else
               --
               vn_fase := 20.4;
               --
               gv_mensagem_log := 'O valor do campo "ID ERP" informado ('||ev_valor||') não é válido, deve conter apenas valores numéricos.';
               --
               vn_loggenericonf_id := null;
               --
               pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                                   , ev_mensagem       => gv_cabec_log
                                   , ev_resumo         => gv_mensagem_log
                                   , en_tipo_log       => erro_de_validacao
                                   , en_referencia_id  => gn_referencia_id
                                   , ev_obj_referencia => gv_obj_referencia );
               -- Armazena o "loggenerico_id" na memória
               pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                                   , est_log_generico_nf => est_log_generico_nf );
               --
           end if;
           --
        else
           --
           vn_fase := 20.5;
           --
           gv_mensagem_log := 'O valor do campo "ID ERP" informado não confere com o tipo de campo, deveria ser NUMÉRICO.';
           --
           vn_loggenericonf_id := null;
           --
           pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                               , ev_mensagem       => gv_cabec_log
                               , ev_resumo         => gv_mensagem_log
                               , en_tipo_log       => erro_de_validacao
                               , en_referencia_id  => gn_referencia_id
                               , ev_obj_referencia => gv_obj_referencia );
           -- Armazena o "loggenerico_id" na memória
           pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                               , est_log_generico_nf => est_log_generico_nf );
           --
        end if;
        --
     end if;
     --
  else
     --
     vn_fase := 28;
     --
     gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
     --
     vn_loggenericonf_id := null;
     --
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                         , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                         , ev_resumo            => gv_mensagem_log
                         , en_tipo_log          => ERRO_DE_VALIDACAO
                         , en_referencia_id     => gn_referencia_id
                         , ev_obj_referencia    => gv_obj_referencia );
     --
     -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf ( en_loggenericonf_id  => vn_loggenericonf_id
                            , est_log_generico_nf  => est_log_generico_nf );
     --
  end if;
  --
end if;
--
vn_fase := 99;
--
if nvl(est_log_generico_nf.count,0) > 0 and
  fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => en_notafiscal_id ) = 1 then
  --
  vn_fase := 99.1;
  --
  update nota_fiscal set dm_st_proc = 10
   where id = en_notafiscal_id;
  --
end if;
--
vn_fase := 99.2;
--
vn_fase := 99.5;
--
if nvl(en_notafiscal_id,0) > 0 and
  ev_atributo = 'ID_ERP' and
  nvl(vn_id_erp,0) > 0 and
  gv_mensagem_log is null then
  --
  vn_fase := 99.6;
  --
  begin
     --
     select count(1)
       into vn_qtde_nf
       from nota_fiscal_compl
      where notafiscal_id = en_notafiscal_id;
     --
  exception
     when others then
     vn_qtde_nf := 0;
  end;
  --
  if nvl(vn_qtde_nf,0) > 0 then
     --
     update nota_fiscal_compl ncs
        set ncs.id_erp = vn_id_erp
      where ncs.notafiscal_id = en_notafiscal_id;
     --
  else
     --
     insert into nota_fiscal_compl ( id
                                   , notafiscal_id
                                   , id_erp
                                   )
                            values ( notafiscalcompl_seq.nextval
                                   , en_notafiscal_id -- notafiscal_id
                                   , vn_id_erp -- cidademodfiscal_id
                                   );
     --  
  end if;
  --
end if;
--
vn_fase := 100;
--
<<sair_integr>>
null;
--
exception
when others then
  --
  gv_mensagem_log := 'Erro na pk_csf_api_nfs.pkb_integr_nota_fiscal_serv_ff fase('||vn_fase||'): '||sqlerrm;
  --
  declare
     vn_loggenericonf_id  log_generico_nf.id%TYPE;
  begin
     --
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                         , ev_mensagem          => gv_cabec_log || gv_cabec_log_item
                         , ev_resumo            => gv_mensagem_log
                         , en_tipo_log          => ERRO_DE_SISTEMA
                         , en_referencia_id     => gn_referencia_id
                         , ev_obj_referencia    => gv_obj_referencia );
     --
     -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenericonf_id
                            , est_log_generico_nf => est_log_generico_nf );
     --
  exception
     when others then
        null;
  end;
  --
end pkb_integr_nota_fiscal_serv_ff;

-------------------------------------------------------------------------------------------------------

-- | Integração do total da nota fiscal
PROCEDURE PKB_INTEGR_NOTA_FISCAL_TOTAL(EST_LOG_GENERICO_NF       IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                     ,EST_ROW_NOTA_FISCAL_TOTAL IN OUT NOCOPY NOTA_FISCAL_TOTAL%ROWTYPE) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(est_row_Nota_Fiscal_Total.notafiscal_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 1.1;
     --
     gv_mensagem_log := 'Não informada a Nota Fiscal para registro dos Totais.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 2;
  -- Valida informação da base de cálculo do ICMS
  if nvl(est_row_Nota_Fiscal_Total.vl_base_calc_icms, 0) < 0 then
     --
     vn_fase := 2.1;
     --
     gv_mensagem_log := '"Base de cálculo do ICMS" da Nota Fiscal não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  -- Valida informação do Valor Total do ICMS
  if nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_icms, 0) < 0 then
     --
     vn_fase := 3.1;
     --
     gv_mensagem_log := '"Valor Total do ICMS" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 4;
  -- Valida informação da base de cálculo do ICMS ST
  if nvl(est_row_Nota_Fiscal_Total.vl_base_calc_st, 0) < 0 then
     --
     vn_fase := 4.1;
     --
     gv_mensagem_log := '"Base de cálculo do ICMS ST" da Nota Fiscal não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 5;
  -- Valida informação do Valor Total do ICMS ST
  if nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_st, 0) < 0 then
     --
     vn_fase := 5.1;
     --
     gv_mensagem_log := '"Valor Total do ICMS ST" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 6;
  -- Valida informação do Valor Total dos produtos e serviços
  if nvl(est_row_Nota_Fiscal_Total.vl_total_item, 0) < 0 then
     --
     vn_fase := 6.1;
     --
     gv_mensagem_log := '"Valor Total dos produtos e serviços" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 7;
  -- Valida informação do Valor Total do Frete
  if nvl(est_row_Nota_Fiscal_Total.vl_frete, 0) < 0 then
     --
     vn_fase := 7.1;
     --
     gv_mensagem_log := '"Valor Total do Frete" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 8;
  -- Valida informação do Valor Total do Seguro
  if nvl(est_row_Nota_Fiscal_Total.vl_seguro, 0) < 0 then
     --
     vn_fase := 8.1;
     --
     gv_mensagem_log := '"Valor Total do Seguro" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 9;
  --
  -- Valida informação do Valor Total do II
  if nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_ii, 0) < 0 then
     --
     vn_fase := 10;
     --
     gv_mensagem_log := '"Valor Total do II" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 11;
  -- Valida informação do Valor Total do IPI
  if nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_ipi, 0) < 0 then
     --
     vn_fase := 11.1;
     --
     gv_mensagem_log := '"Valor Total do IPI" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 12;
  -- Valida informação do Valor do PIS
  if nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_pis, 0) < 0 then
     --
     vn_fase := 12.1;
     --
     gv_mensagem_log := '"Valor do PIS" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 13;
  -- Valida informação do Valor do COFINS
  if nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_cofins, 0) < 0 then
     --
     vn_fase := 13.1;
     --
     gv_mensagem_log := '"Valor do COFINS" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 14;
  -- Valida informação de Outras Despesas acessoias
  if nvl(est_row_Nota_Fiscal_Total.vl_outra_despesas, 0) < 0 then
     --
     vn_fase := 14.1;
     --
     gv_mensagem_log := '"Outras Despesas Acessórias" da Nota Fiscal não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 15;
  -- Valida informação do Valor Total da Nota Fiscal
  if nvl(est_row_Nota_Fiscal_Total.vl_total_nf, 0) < 0 then
     --
     vn_fase := 15.1;
     --
     gv_mensagem_log := '"Valor Total da Nota Fiscal" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 16;
  -- Valida informação do Valor Total dos serviços sob não incidencia ou não tributados pelo ICMS
  if nvl(est_row_Nota_Fiscal_Total.vl_serv_nao_trib, 0) < 0 then
     --
     vn_fase := 16.1;
     --
     gv_mensagem_log := '"Valor Total dos serviços sob não incidência ou não tributados pelo ICMS" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 17;
  -- Valida informação da base de cálculo do ISS
  if nvl(est_row_Nota_Fiscal_Total.vl_base_calc_iss, 0) < 0 then
     --
     vn_fase := 17.1;
     --
     gv_mensagem_log := '"Base de cálculo do ISS" da Nota Fiscal não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 18;
  -- Valida informação do Valor Total do ISS
  if nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_iss, 0) < 0 then
     --
     vn_fase := 18.1;
     --
     gv_mensagem_log := '"Valor Total do ISS" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 19;
  -- Valida informação do Valor do PIS sobre serviços
  if nvl(est_row_Nota_Fiscal_Total.vl_pis_iss, 0) < 0 then
     --
     vn_fase := 19.1;
     --
     gv_mensagem_log := '"Valor do PIS sobre serviços" da Nota Fiscal não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 20;
  -- Valida informação do Valor do COFINS sobre serviços
  if nvl(est_row_Nota_Fiscal_Total.vl_cofins_iss, 0) < 0 then
     --
     vn_fase := 20.1;
     --
     gv_mensagem_log := '"Valor do COFINS sobre serviços" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 21;
  -- Valida informação do Valor Retido de PIS
  if nvl(est_row_Nota_Fiscal_Total.vl_ret_pis, 0) < 0 then
     --
     vn_fase := 21.1;
     --
     gv_mensagem_log := '"Valor Retido de PIS" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 22;
  -- Valida informação do Valor Retido de COFINS
  if nvl(est_row_Nota_Fiscal_Total.vl_ret_cofins, 0) < 0 then
     --
     vn_fase := 22.1;
     --
     gv_mensagem_log := '"Valor Retido de COFINS" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 23;
  -- Valida informação do Valor Retido de CSLL
  if nvl(est_row_Nota_Fiscal_Total.vl_ret_csll, 0) < 0 then
     --
     vn_fase := 23.1;
     --
     gv_mensagem_log := '"Valor Retido de CSLL" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 24;
  -- Valida informação do base de cálculo do IRRF
  if nvl(est_row_Nota_Fiscal_Total.vl_base_calc_irrf, 0) < 0 then
     --
     vn_fase := 24.1;
     --
     gv_mensagem_log := '"Base de cálculo do IRRF" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 25;
  -- Valida informação do Valor Retido do IRRF
  if nvl(est_row_Nota_Fiscal_Total.vl_ret_irrf, 0) < 0 then
     --
     vn_fase := 25.1;
     --
     gv_mensagem_log := '"Valor Retido do IRRF" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 26;
  -- Valida informação do base de cálculo da Retencao da Previdencia Social
  if nvl(est_row_Nota_Fiscal_Total.vl_base_calc_ret_prev, 0) < 0 then
     --
     vn_fase := 26.1;
     --
     gv_mensagem_log := '"Base de cálculo da Retenção da Previdência Social" da Nota Fiscal não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 27;
  -- Valida informação do Valor da Retenção da Previdência Social
  if nvl(est_row_Nota_Fiscal_Total.vl_ret_prev, 0) < 0 then
     --
     vn_fase := 27.1;
     --
     gv_mensagem_log := '"Valor da Retenção da Previdência Social" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 28;
  -- Valida informado do Total de Serviços
  if nvl(est_row_Nota_Fiscal_Total.vl_total_serv, 0) < 0 then
     --
     vn_fase := 28.1;
     --
     gv_mensagem_log := '"Total de serviços" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 29;
  --
  if nvl(est_row_Nota_Fiscal_Total.vl_abat_nt, 0) < 0 then
     --
     vn_fase := 29.1;
     --
     gv_mensagem_log := '"Valor Abatimento não Tributado" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 30;
  --
  if nvl(est_row_Nota_Fiscal_Total.vl_forn, 0) < 0 then
     --
     vn_fase := 30.1;
     --
     gv_mensagem_log := '"Valor total fornecido/consumido" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 31;
  --
  if nvl(est_row_Nota_Fiscal_Total.vl_terc, 0) < 0 then
     --
     vn_fase := 31.1;
     --
     gv_mensagem_log := '"Valor total cobrado em nome de terceiros" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  vn_fase := 32;
  if nvl(est_row_Nota_Fiscal_Total.vl_servico, 0) < 0 then
     --
     vn_fase := 32.1;
     --
     gv_mensagem_log := '"Valor dos serviços" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 32.2;
  -- Valor Aproximado dos Tributos
  if nvl(est_row_Nota_Fiscal_Total.vl_tot_trib, 0) < 0 then
     --
     vn_fase := 32.3;
     --
     gv_mensagem_log := '"Valor Total Aproximado dos Tributos" da Nota Fiscal não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
   vn_fase := 32.4;
   --
   if nvl(est_row_Nota_Fiscal_Total.vl_pis_st,0) < 0 then
      --
      vn_fase := 32.5;
      --
      gv_mensagem_log := '"Valor Total do PIS retido por Situação Tributária" da Nota Fiscal não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                          , ev_mensagem         => gv_cabec_log
                          , ev_resumo           => gv_mensagem_log
                          , en_tipo_log         => erro_de_validacao
                          , en_referencia_id    => gn_referencia_id
                          , ev_obj_referencia   => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
   vn_fase := 32.6;

   if nvl(est_row_Nota_Fiscal_Total.vl_cofins_st,0) < 0 then
      --
      vn_fase := 32.7;
      --
      gv_mensagem_log := '"Valor Total do COFINS  retido por Situação Tributária" da Nota Fiscal não pode ser negativo.';
      --
      vn_loggenerico_id := null;
      --
      pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                          , ev_mensagem         => gv_cabec_log
                          , ev_resumo           => gv_mensagem_log
                          , en_tipo_log         => erro_de_validacao
                          , en_referencia_id    => gn_referencia_id
                          , ev_obj_referencia   => gv_obj_referencia );
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                             , est_log_generico_nf => est_log_generico_nf );
      --
   end if;
   --
  vn_fase := 33;
  --
  if est_row_Nota_Fiscal_Total.vl_serv_nao_trib = 0 then
     est_row_Nota_Fiscal_Total.vl_serv_nao_trib := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_base_calc_iss = 0 then
     est_row_Nota_Fiscal_Total.vl_base_calc_iss := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_imp_trib_iss = 0 then
     est_row_Nota_Fiscal_Total.vl_imp_trib_iss := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_pis_iss = 0 then
     est_row_Nota_Fiscal_Total.vl_pis_iss := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_cofins_iss = 0 then
     est_row_Nota_Fiscal_Total.vl_cofins_iss := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_ret_pis = 0 then
     est_row_Nota_Fiscal_Total.vl_ret_pis := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_ret_cofins = 0 then
     est_row_Nota_Fiscal_Total.vl_ret_cofins := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_ret_csll = 0 then
     est_row_Nota_Fiscal_Total.vl_ret_csll := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_base_calc_irrf = 0 then
     est_row_Nota_Fiscal_Total.vl_base_calc_irrf := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_ret_irrf = 0 then
     est_row_Nota_Fiscal_Total.vl_ret_irrf := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_base_calc_ret_prev = 0 then
     est_row_Nota_Fiscal_Total.vl_base_calc_ret_prev := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_ret_prev = 0 then
     est_row_Nota_Fiscal_Total.vl_ret_prev := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_total_serv = 0 then
     est_row_Nota_Fiscal_Total.vl_total_serv := null;
  end if;
  --
  if est_row_Nota_Fiscal_Total.vl_tot_trib = 0 then
     est_row_Nota_Fiscal_Total.vl_tot_trib := null;
  end if;
  --
  vn_fase := 34;
  --
  -- Se não exite registro de Log e o Tipo de Integração é 1 (valida e insere)
  -- então registra a informação do Total da Nota Fiscal
  if nvl(est_log_generico_nf.count, 0) > 0 and
     fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => est_row_Nota_Fiscal_Total.notafiscal_id ) = 1 then
         --
         -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (carrega)
         pk_csf_api.gv_objeto := 'pk_csf_api_sc.PKB_INTEGR_NOTA_FISCAL_TOTAL';
         pk_csf_api.gn_fase   := vn_fase;
         --
         update nota_fiscal
            set dm_st_proc = 10
          where id = est_row_Nota_Fiscal_Total.notafiscal_id;
         --
         -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (limpa)
         pk_csf_api.gv_objeto := null;
         pk_csf_api.gn_fase   := null;
         --
      end if;
  --
  vn_fase := 35;
  --
  est_row_Nota_Fiscal_Total.vl_base_calc_icms  := nvl(est_row_Nota_Fiscal_Total.vl_base_calc_icms
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_imp_trib_icms   := nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_icms
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_base_calc_st    := nvl(est_row_Nota_Fiscal_Total.vl_base_calc_st
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_imp_trib_st     := nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_st
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_total_item      := nvl(est_row_Nota_Fiscal_Total.vl_total_item
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_frete           := nvl(est_row_Nota_Fiscal_Total.vl_frete
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_seguro          := nvl(est_row_Nota_Fiscal_Total.vl_seguro
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_desconto        := nvl(est_row_Nota_Fiscal_Total.vl_desconto
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_imp_trib_ii     := nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_ii
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_imp_trib_ipi    := nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_ipi
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_imp_trib_pis    := nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_pis
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_imp_trib_cofins := nvl(est_row_Nota_Fiscal_Total.vl_imp_trib_cofins
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_outra_despesas  := nvl(est_row_Nota_Fiscal_Total.vl_outra_despesas
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_total_nf        := nvl(est_row_Nota_Fiscal_Total.vl_total_nf
                                                     ,0);
  est_row_Nota_Fiscal_Total.vl_pis_st          := nvl( est_row_Nota_Fiscal_Total.vl_pis_st,0);
  est_row_Nota_Fiscal_Total.vl_cofins_st       := nvl( est_row_Nota_Fiscal_Total.vl_cofins_st,0);
  --
  vn_fase := 36;
  --
  if nvl(est_row_Nota_Fiscal_Total.notafiscal_id, 0) > 0 then
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 37;
        --
        select notafiscaltotal_seq.nextval
          into est_row_Nota_Fiscal_Total.id
          from dual;
        --
        vn_fase := 38;
        --
        -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (carrega)
        pk_csf_api.gv_objeto := 'pk_csf_api_sc.PKB_INTEGR_NOTA_FISCAL_TOTAL';
        pk_csf_api.gn_fase   := vn_fase;
        --
        insert into Nota_Fiscal_Total
           (id
           ,notafiscal_id
           ,vl_base_calc_icms
           ,vl_imp_trib_icms
           ,vl_base_calc_st
           ,vl_imp_trib_st
           ,vl_total_item
           ,vl_frete
           ,vl_seguro
           ,vl_desconto
           ,vl_imp_trib_ii
           ,vl_imp_trib_ipi
           ,vl_imp_trib_pis
           ,vl_imp_trib_cofins
           ,vl_outra_despesas
           ,vl_total_nf
           ,vl_serv_nao_trib
           ,vl_base_calc_iss
           ,vl_imp_trib_iss
           ,vl_pis_iss
           ,vl_cofins_iss
           ,vl_ret_pis
           ,vl_ret_cofins
           ,vl_ret_csll
           ,vl_base_calc_irrf
           ,vl_ret_irrf
           ,vl_base_calc_ret_prev
           ,vl_ret_prev
           ,vl_total_serv
           ,vl_abat_nt
           ,vl_forn
           ,vl_terc
           ,vl_servico
           ,vl_tot_trib
           ,vl_pis_st
           ,vl_cofins_st
           )
        values
           (est_row_Nota_Fiscal_Total.id
           ,est_row_Nota_Fiscal_Total.notafiscal_id
           ,est_row_Nota_Fiscal_Total.vl_base_calc_icms
           ,est_row_Nota_Fiscal_Total.vl_imp_trib_icms
           ,est_row_Nota_Fiscal_Total.vl_base_calc_st
           ,est_row_Nota_Fiscal_Total.vl_imp_trib_st
           ,est_row_Nota_Fiscal_Total.vl_total_item
           ,est_row_Nota_Fiscal_Total.vl_frete
           ,est_row_Nota_Fiscal_Total.vl_seguro
           ,est_row_Nota_Fiscal_Total.vl_desconto
           ,est_row_Nota_Fiscal_Total.vl_imp_trib_ii
           ,est_row_Nota_Fiscal_Total.vl_imp_trib_ipi
           ,est_row_Nota_Fiscal_Total.vl_imp_trib_pis
           ,est_row_Nota_Fiscal_Total.vl_imp_trib_cofins
           ,est_row_Nota_Fiscal_Total.vl_outra_despesas
           ,est_row_Nota_Fiscal_Total.vl_total_nf
           ,est_row_Nota_Fiscal_Total.vl_serv_nao_trib
           ,est_row_Nota_Fiscal_Total.vl_base_calc_iss
           ,est_row_Nota_Fiscal_Total.vl_imp_trib_iss
           ,est_row_Nota_Fiscal_Total.vl_pis_iss
           ,est_row_Nota_Fiscal_Total.vl_cofins_iss
           ,est_row_Nota_Fiscal_Total.vl_ret_pis
           ,est_row_Nota_Fiscal_Total.vl_ret_cofins
           ,est_row_Nota_Fiscal_Total.vl_ret_csll
           ,est_row_Nota_Fiscal_Total.vl_base_calc_irrf
           ,est_row_Nota_Fiscal_Total.vl_ret_irrf
           ,est_row_Nota_Fiscal_Total.vl_base_calc_ret_prev
           ,est_row_Nota_Fiscal_Total.vl_ret_prev
           ,est_row_Nota_Fiscal_Total.vl_total_serv
           ,est_row_Nota_Fiscal_Total.vl_abat_nt
           ,est_row_Nota_Fiscal_Total.vl_forn
           ,est_row_Nota_Fiscal_Total.vl_terc
           ,est_row_Nota_Fiscal_Total.vl_servico
           ,est_row_Nota_Fiscal_Total.vl_tot_trib
           ,est_row_Nota_Fiscal_Total.vl_pis_st
           ,est_row_Nota_Fiscal_Total.vl_cofins_st
           );
        --
        -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (limpa)
        pk_csf_api.gv_objeto := null;
        pk_csf_api.gn_fase   := null;
        --
     else
        --
        vn_fase := 39;
        --
        -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (carrega)
        pk_csf_api.gv_objeto := 'pk_csf_api_sc.PKB_INTEGR_NOTA_FISCAL_TOTAL';
        pk_csf_api.gn_fase   := vn_fase;
        --
        update Nota_Fiscal_Total
           set vl_base_calc_icms     = est_row_Nota_Fiscal_Total.vl_base_calc_icms
              ,vl_imp_trib_icms      = est_row_Nota_Fiscal_Total.vl_imp_trib_icms
              ,vl_base_calc_st       = est_row_Nota_Fiscal_Total.vl_base_calc_st
              ,vl_imp_trib_st        = est_row_Nota_Fiscal_Total.vl_imp_trib_st
              ,vl_total_item         = est_row_Nota_Fiscal_Total.vl_total_item
              ,vl_frete              = est_row_Nota_Fiscal_Total.vl_frete
              ,vl_seguro             = est_row_Nota_Fiscal_Total.vl_seguro
              ,vl_desconto           = est_row_Nota_Fiscal_Total.vl_desconto
              ,vl_imp_trib_ii        = est_row_Nota_Fiscal_Total.vl_imp_trib_ii
              ,vl_imp_trib_ipi       = est_row_Nota_Fiscal_Total.vl_imp_trib_ipi
              ,vl_imp_trib_pis       = est_row_Nota_Fiscal_Total.vl_imp_trib_pis
              ,vl_imp_trib_cofins    = est_row_Nota_Fiscal_Total.vl_imp_trib_cofins
              ,vl_outra_despesas     = est_row_Nota_Fiscal_Total.vl_outra_despesas
              ,vl_total_nf           = est_row_Nota_Fiscal_Total.vl_total_nf
              ,vl_serv_nao_trib      = est_row_Nota_Fiscal_Total.vl_serv_nao_trib
              ,vl_base_calc_iss      = est_row_Nota_Fiscal_Total.vl_base_calc_iss
              ,vl_imp_trib_iss       = est_row_Nota_Fiscal_Total.vl_imp_trib_iss
              ,vl_pis_iss            = est_row_Nota_Fiscal_Total.vl_pis_iss
              ,vl_cofins_iss         = est_row_Nota_Fiscal_Total.vl_cofins_iss
              ,vl_ret_pis            = est_row_Nota_Fiscal_Total.vl_ret_pis
              ,vl_ret_cofins         = est_row_Nota_Fiscal_Total.vl_ret_cofins
              ,vl_ret_csll           = est_row_Nota_Fiscal_Total.vl_ret_csll
              ,vl_base_calc_irrf     = est_row_Nota_Fiscal_Total.vl_base_calc_irrf
              ,vl_ret_irrf           = est_row_Nota_Fiscal_Total.vl_ret_irrf
              ,vl_base_calc_ret_prev = est_row_Nota_Fiscal_Total.vl_base_calc_ret_prev
              ,vl_ret_prev           = est_row_Nota_Fiscal_Total.vl_ret_prev
              ,vl_total_serv         = est_row_Nota_Fiscal_Total.vl_total_serv
              ,vl_abat_nt            = est_row_Nota_Fiscal_Total.vl_abat_nt
              ,vl_forn               = est_row_Nota_Fiscal_Total.vl_forn
              ,vl_terc               = est_row_Nota_Fiscal_Total.vl_terc
              ,vl_servico            = est_row_Nota_Fiscal_Total.vl_servico
              ,vl_tot_trib           = est_row_Nota_Fiscal_Total.vl_tot_trib
              ,vl_pis_st             = est_row_Nota_Fiscal_Total.vl_pis_st
              ,vl_cofins_st          = est_row_Nota_Fiscal_Total.vl_cofins_st
         where id = est_row_Nota_Fiscal_Total.id;
        --
        -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (limpa)
        pk_csf_api.gv_objeto := null;
        pk_csf_api.gn_fase   := null;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal_Total fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NOTA_FISCAL_TOTAL;
---------------------------------------------------------------------------------
-- Procedimento que gera log da nota fiscal --
--------------------------------------------------------------------------------
PROCEDURE PKB_LOG_GENERICO_NF(SN_LOGGENERICONF_ID OUT NOCOPY LOG_GENERICO_NF.ID%TYPE
                            ,EV_MENSAGEM         IN LOG_GENERICO_NF.MENSAGEM%TYPE
                            ,EV_RESUMO           IN LOG_GENERICO_NF.RESUMO%TYPE
                            ,EN_TIPO_LOG         IN CSF_TIPO_LOG.CD_COMPAT%TYPE DEFAULT 1
                            ,EN_REFERENCIA_ID    IN LOG_GENERICO_NF.REFERENCIA_ID%TYPE DEFAULT NULL
                            ,EV_OBJ_REFERENCIA   IN LOG_GENERICO_NF.OBJ_REFERENCIA%TYPE DEFAULT NULL
                            ,EN_EMPRESA_ID       IN EMPRESA.ID%TYPE DEFAULT NULL
                            ,EN_DM_IMPRESSA      IN LOG_GENERICO_NF.DM_IMPRESSA%TYPE DEFAULT 0) IS
  --
  vn_fase          number := 0;
  vn_empresa_id    Empresa.Id%type;
  vn_csftipolog_id csf_tipo_log.id%type := null;
  pragma autonomous_transaction;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(gn_processo_id, 0) = 0 then
     select processo_seq.nextval into gn_processo_id from dual;
  end if;
  --
  vn_empresa_id := nvl(en_empresa_id, gn_empresa_id);
  --
  if nvl(en_tipo_log, 0) > 0 and ev_mensagem is not null then
     --
     vn_fase := 2;
     --
     vn_csftipolog_id := pk_csf.fkg_csf_tipo_log_id(en_tipo_log => en_tipo_log);
     --
     vn_fase := 3;
     --
     select loggenericonf_seq.nextval
       into sn_loggenericonf_id
       from dual;
     --
     vn_fase := 4;
     --
     insert into log_generico_nf
        (id
        ,processo_id
        ,dt_hr_log
        ,mensagem
        ,referencia_id
        ,obj_referencia
        ,resumo
        ,dm_impressa
        ,dm_env_email
        ,csftipolog_id
        ,empresa_id)
     values
        (sn_loggenericonf_id -- Valor de cada log de validacao
        ,gn_processo_id -- Valor ID do processo de Integracao
        ,sysdate -- Sempre atribui a data atual do sistema
        ,ev_mensagem -- Mensagem do log
        ,en_referencia_id -- Id de referência que gerou o log
        ,ev_obj_referencia -- Objeto do Banco que gerou o log
        ,ev_resumo
        ,en_dm_impressa
        ,0
        ,vn_csftipolog_id
        ,vn_empresa_id);
     --
     vn_fase := 5;
     --
     commit;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pk_csf_api.pkb_log_generico_nf fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico.id%type;
     begin
        pk_log_generico.pkb_log_generico(sn_loggenerico_id => vn_loggenerico_id
                                        ,ev_mensagem       => gv_cabec_log
                                        ,ev_resumo         => gv_mensagem_log
                                        ,en_tipo_log       => erro_de_sistema);
     exception
        when others then
           null;
     end;
     --
END PKB_LOG_GENERICO_NF;

PROCEDURE PKB_GT_LOG_GENERICO_NF(EN_LOGGENERICONF_ID IN LOG_GENERICO_NF.ID%TYPE
                               ,EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE) IS
  --
  i pls_integer;
  --
BEGIN
  --
  if nvl(en_loggenericonf_id, 0) > 0 then
     --
     i := nvl(est_log_generico_nf.count, 0) + 1;
     --
     est_log_generico_nf(i) := en_loggenericonf_id;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_gt_log_generico_nf: '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_sistema);
     exception
        when others then
           null;
     end;
     --
END PKB_GT_LOG_GENERICO_NF;

---------------------------------------------------------------------------------
-- Procedimento seta o "ID de Referencia" utilizado na validacao da informação --
---------------------------------------------------------------------------------
PROCEDURE PKB_SETA_REFERENCIA_ID(EN_ID IN NUMBER) IS
BEGIN
  --
  gn_referencia_id := en_id;
  --
END PKB_SETA_REFERENCIA_ID;

--------------------------------------------------
-- Procedimento exclui dados de uma nota fiscal --
--------------------------------------------------
PROCEDURE PKB_EXCLUIR_DADOS_NF(EN_NOTAFISCAL_ID IN NOTA_FISCAL.ID%TYPE) IS
  --
  vn_fase number := 0;
  --
  cursor c_cobr is
     select id
       from nota_fiscal_cobr
      where notafiscal_id = en_notafiscal_id;
  --
BEGIN
  --
  vn_fase := 1;
  -- Se informou a Nota Fiscal então exclui os dados dos filhos da Tabela Nota_Fiscal
  if nvl(en_notafiscal_id, 0) > 0 then
     --
     vn_fase := 2;
     -- exclui os impostos dos itens
     delete from Imp_ItemNf
            where itemnf_id in (select id
                                  from item_nota_fiscal
                                 where notafiscal_id = en_notafiscal_id);
     --
     vn_fase := 2.1;
     -- exclui os dados de impressão do item da nota
     delete from impr_item_nfsc
           where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 3;
     -- Itens da NF
     delete from Item_Nota_Fiscal
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 3.1;
     -- exclui os dados de impressão do cabeçalho da nota
     delete from impr_cab_nfsc
           where notafiscal_id = en_notafiscal_id;          
     --
     vn_fase := 4;
     -- informações de complemento da nota fiscal
     delete from nf_compl_serv where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 5;
     -- informações do cancelamento da NF
     delete from Nota_Fiscal_Canc
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 6;
     -- informações de totais da nota fiscal
     delete from Nota_Fiscal_Total
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 7;
     -- informações adicionais da NF
     delete from NFInfor_Adic where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 8;
     -- Destalhes das duplicatas da fatura
     for rec in c_cobr
     loop
        --
        exit when c_cobr%notfound or(c_cobr%notfound) is null;
        --
        vn_fase := 9;
        --
        delete from NFCobr_Dup where nfcobr_id = rec.id;
        --
     end loop;
     --
     vn_fase := 10;
     -- informações da fatura
     delete from Nota_Fiscal_Cobr
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 11;
     -- informações do Destinatário
     delete from Nota_Fiscal_Dest
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 12;
     -- informações do emitente
     delete from Nota_Fiscal_Emit
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 13;
     -- Resumo de Impostos
     delete from nfregist_analit
      where notafiscal_id = en_notafiscal_id;
     -- Terminal Faturado
     delete from nf_term_fat where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 14;
     -- Complemento de operação PIS/PASEP
     delete from nf_compl_oper_pis
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 15;
     -- Complemento de operação COFINS
     delete from nf_compl_oper_cofins
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 16;
     --
     delete from log_nota_fiscal
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 17;
     --
     delete from log_nf_serv_cont
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 18;
     --
     delete from hist_st_nota_fiscal
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 19;
     --
     delete from r_nf_nf where notafiscal_id2 = en_notafiscal_id;
     --
     vn_fase := 20;
     --
     delete from r_nf_nf where notafiscal_id1 = en_notafiscal_id;
     --
     vn_fase := 21;
     --
     delete from nf_aut_xml where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 22;
     --
     delete from hist_chave_nota_fiscal
      where notafiscal_id = en_notafiscal_id;
     --
     vn_fase := 23;
     --
     -- Impostos e retenção de origem da nota fiscal(tab da Calc. Fiscal)         
     delete from imp_itemnf_orig
      where notafiscal_id = en_notafiscal_id;
     --
  end if;
  --
  vn_fase := 24;
  --
  commit;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_excluir_dados_nf fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_sistema
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
     exception
        when others then
           null;
     end;
     --
END PKB_EXCLUIR_DADOS_NF;

----------------------------------------------------------
-- Procedimento valida a chave de acesso da Nota Fiscal --
----------------------------------------------------------
PROCEDURE PKB_VALIDA_CHAVE_ACESSO(EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                ,EV_NRO_CHAVE_NFE    IN NOTA_FISCAL.NRO_CHAVE_NFE%TYPE
                                ,EN_EMPRESA_ID       IN EMPRESA.ID%TYPE
                                ,ED_DT_EMISS         IN NOTA_FISCAL.DT_EMISS%TYPE
                                ,EV_COD_MOD          IN MOD_FISCAL.COD_MOD%TYPE
                                ,EN_SERIE            IN NOTA_FISCAL.SERIE%TYPE
                                ,EN_NRO_NF           IN NOTA_FISCAL.NRO_NF%TYPE
                                ,EN_DM_FORMA_EMISS   IN NOTA_FISCAL.DM_FORMA_EMISS%TYPE
                                ,SN_CNF_NFE          OUT NOTA_FISCAL.CNF_NFE%TYPE
                                ,SN_DIG_VERIF_CHAVE  OUT NOTA_FISCAL.DIG_VERIF_CHAVE%TYPE
                                ,SN_QTDE_ERRO        OUT NUMBER) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  -- informações da Chave de Acesso
  vv_uf_ibge_chave  varchar2(2) := null;
  vv_emissao_chave  varchar2(4) := null;
  vv_cnpj_chave     varchar2(14) := null;
  vv_cod_mod_chave  varchar2(2) := null;
  vv_serie_chave    varchar2(3) := null;
  vv_nro_nf_chave   varchar2(9) := null;
  vv_dm_forma_emiss varchar2(1) := null;
  -- informações usadas para comprar com a Chave de Acesso
  vv_cnpj            varchar2(14) := null;
  vv_uf_ibge         varchar2(2) := null;
  vn_dig_verif_chave Nota_Fiscal.dig_verif_chave%TYPE := null;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(en_nro_nf, 0) > 0 and ev_cod_mod in ('55', '57', '65') then
     --
     vn_fase := 2;
     --
     if ev_nro_chave_nfe is not null then
        --
        -- Valida a informação da Chave informada no ERP
        sn_qtde_erro := 0;
        --
        vn_fase := 3;
        -- Armaxena o valor do Código do ibge da chave
        vv_uf_ibge_chave := trim(substr(ev_nro_chave_nfe, 1, 2));
        --
        vn_fase := 4;
        --  Armazena o valor da Emissao da Chave
        vv_emissao_chave := trim(substr(ev_nro_chave_nfe, 3, 4));
        --
        vn_fase := 5;
        -- Armazena o valor do cnpj da chave
        vv_cnpj_chave := trim(substr(ev_nro_chave_nfe, 7, 14));
        --
        vn_fase := 6;
        -- Armazena o valor do modelo de docto da chave
        vv_cod_mod_chave := trim(substr(ev_nro_chave_nfe, 21, 2));
        --
        vn_fase := 7;
        -- Armazena do valor da serie da nota fiscal da chave
        vv_serie_chave := trim(substr(ev_nro_chave_nfe, 23, 3));
        --
        vn_fase := 8;
        -- Armazena o valor do numero da nota fiscal
        vv_nro_nf_chave := trim(substr(ev_nro_chave_nfe, 26, 9));
        --
        vn_fase := 8.1;
        -- Armazena a Forma de Emissao
        vv_dm_forma_emiss := trim(substr(ev_nro_chave_nfe, 35, 1));
        --
        vn_fase := 9;
        -- Armazena o valor do numero aleatorio
        sn_cNF_nfe := trim(substr(ev_nro_chave_nfe, 36, 8));
        --
        vn_fase := 10;
        -- Armazena o digito do chave
        sn_dig_verif_chave := to_number(substr(ev_nro_chave_nfe, 44, 1));
        --
        vn_fase := 11;
        -- recupera dados da Empresa
        begin
           --
           select lpad(es.ibge_estado, 2, '0')
                 ,(lpad(j.num_cnpj, 8, '0') ||
                  lpad(j.num_filial, 4, '0') ||
                  lpad(j.dig_cnpj, 2, '0')) cnpj
             into vv_uf_ibge
                 ,vv_cnpj
             from Empresa  e
                 ,Pessoa   p
                 ,cidade   c
                 ,estado   es
                 ,Juridica j
            where e.id = en_empresa_id
              and p.id = e.pessoa_id
              and c.id = p.cidade_id
              and es.id = c.estado_id
              and j.pessoa_id = p.id;
           --
        exception
           when others then
              --
              gv_mensagem_log := 'Erro ao recuperar os dados da Empresa para criar a Chave de Acesso.';
              --
              vn_loggenerico_id := null;
              --
              pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                 ,ev_mensagem         => gv_cabec_log
                                 ,ev_resumo           => gv_mensagem_log
                                 ,en_tipo_log         => erro_de_validacao
                                 ,en_referencia_id    => gn_referencia_id
                                 ,ev_obj_referencia   => gv_obj_referencia);
              -- Armazena o "loggenerico_id" na memoria
              pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                    ,est_log_generico_nf => est_log_generico_nf);
              --
        end;
        --
        -- Inicia a validacao dos dados da chave de acesso com os dados informados da Nota Fiscal
        --
        vn_fase := 12;
        -- Valida a informação do "Código da UF do emitente do Documento Fiscal"
        if vv_uf_ibge <> vv_uf_ibge_chave then
           --
           vn_fase := 12.1;
           --
           gv_mensagem_log := '"Código da UF do emitente" informado na Nota Fiscal ('||vv_uf_ibge||
                              ') está diferente do "Código da UF do emitente" da chave de acesso ('||vv_uf_ibge_chave||').';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           --
           sn_qtde_erro := nvl(sn_qtde_erro, 0) + 1;
           --
        end if;
        --
        vn_fase := 13;
        -- Valida a informação do "Ano e Mes de Emissao da NF-e"
        if to_char(ed_dt_emiss, 'YYMM') <> vv_emissao_chave then
           --
           vn_fase := 13.1;
           --
           gv_mensagem_log := '"Ano e Mês de Emissão" informado na Nota Fiscal ('||to_char(ed_dt_emiss,'YYMM')||') está diferente do "Ano e Mês de '||
                              'Emissão" da chave de acesso ('||vv_emissao_chave||').';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           --
           sn_qtde_erro := nvl(sn_qtde_erro, 0) + 1;
           --
        end if;
        --
        vn_fase := 14;
        -- Valida a informação do "CNPJ do emitente"
        if vv_cnpj <> vv_cnpj_chave then
           --
           vn_fase := 14.1;
           --
           gv_mensagem_log := '"CNPJ do emitente" informado na Nota Fiscal ('||vv_cnpj||') está diferente do "CNPJ do emitente" da chave de acesso ('||
                              vv_cnpj_chave||').';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           --
           sn_qtde_erro := nvl(sn_qtde_erro, 0) + 1;
           --
        end if;
        --
        vn_fase := 15;
        -- Valida a informação do Modelo do Documento Fiscal
        if ev_cod_mod <> vv_cod_mod_chave then
           --
           vn_fase := 15.1;
           --
           gv_mensagem_log := '"Modelo do Documento Fiscal" informado na Nota Fiscal ('||ev_cod_mod||
                              ') está diferente do "Modelo do Documento Fiscal" da chave de acesso('||vv_cod_mod_chave||').';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           --
           sn_qtde_erro := nvl(sn_qtde_erro, 0) + 1;
           --
        end if;
        --
        vn_fase := 16;
        --
        -- Valida a informação da serie do Documento Fiscal
        if lpad(en_serie, 3, '0') <> vv_serie_chave then
           --
           vn_fase := 16.1;
           --
           gv_mensagem_log := '"Série do Documento Fiscal" informado na Nota Fiscal ('||lpad(en_serie,3,'0')||
                              ') está diferente da "Série do Documento Fiscal" da chave de acesso ('||vv_serie_chave||').';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           --
           sn_qtde_erro := nvl(sn_qtde_erro, 0) + 1;
           --
        end if;
        --
        vn_fase := 17;
        -- Valida a informação do Número do Documento Fiscal
        if lpad(en_nro_nf, 9, '0') <> vv_nro_nf_chave then
           --
           vn_fase := 17.1;
           --
           gv_mensagem_log := '"Número do Documento Fiscal" informado na Nota Fiscal ('||lpad(en_nro_nf,9,'0')||
                              ') estão diferente do "Número do Documento Fiscal" da chave de acesso ('||vv_nro_nf_chave||').';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           --
           sn_qtde_erro := nvl(sn_qtde_erro, 0) + 1;
           --
        end if;
        --
        vn_fase := 17.2;
        -- valida a forma de Emissao
        if to_char(en_dm_forma_emiss) <> vv_dm_forma_emiss then
           --
           vn_fase := 17.3;
           --
           gv_mensagem_log := '"Forma de Emissão" informado na Nota Fiscal ('||lpad(en_dm_forma_emiss,9,'0')||
                              ') está diferente da "Forma de Emissão" da chave de acesso ('||vv_dm_forma_emiss||').';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           --
           sn_qtde_erro := nvl(sn_qtde_erro, 0) + 1;
           --
        end if;
        --
        vn_fase := 18;
        -- calcula o digito da chave
        vn_dig_verif_chave := pk_csf.fkg_mod_11(ev_codigo => substr(ev_nro_chave_nfe,1,43));
        --
        vn_fase := 19;
        -- Verifica se o digito da chave é diferente do digito calculado
        if vn_dig_verif_chave <> nvl(sn_dig_verif_chave, -1) then
           --
           vn_fase := 19.1;
           --
           gv_mensagem_log := 'Dígito verificador da Chave de Acesso calculado ('||vn_dig_verif_chave||') está diferente do dígito da chave de acesso ('||
                              sn_dig_verif_chave||').';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           --
           sn_qtde_erro := nvl(sn_qtde_erro, 0) + 1;
           --
        end if;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_valida_chave_acesso fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_VALIDA_CHAVE_ACESSO;

-------------------------------------------------
-- Procedimento integra a Chave da Nota Fiscal --
-------------------------------------------------
PROCEDURE PKB_INTEGR_NFCHAVE_REFER(EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                 ,EN_EMPRESA_ID       IN EMPRESA.ID%TYPE
                                 ,EN_NOTAFISCAL_ID    IN NOTA_FISCAL.ID%TYPE
                                 ,ED_DT_EMISS         IN NOTA_FISCAL.DT_EMISS%TYPE
                                 ,EV_COD_MOD          IN MOD_FISCAL.COD_MOD%TYPE
                                 ,EN_SERIE            IN NOTA_FISCAL.SERIE%TYPE
                                 ,EN_NRO_NF           IN NOTA_FISCAL.NRO_NF%TYPE
                                 ,EN_DM_FORMA_EMISS   IN NOTA_FISCAL.DM_FORMA_EMISS%TYPE
                                 ,ESN_CNF_NFE         IN OUT NOCOPY NOTA_FISCAL.CNF_NFE%TYPE
                                 ,SN_DIG_VERIF_CHAVE  OUT NOTA_FISCAL.DIG_VERIF_CHAVE%TYPE
                                 ,SV_NRO_CHAVE_NFE    OUT NOTA_FISCAL.NRO_CHAVE_NFE%TYPE) IS
  --
  vn_fase              number := 0;
  vv_cnpj              varchar2(14) := null;
  vv_uf_ibge           varchar2(2) := null;
  vn_loggenerico_id    log_generico_nf.id%type;
  vn_numero            number := null;
  vv_cd_versaowsdl_nfe versao_wsdl.cd%type;
  vn_cNF_nfe           Nota_Fiscal.cNF_nfe%TYPE := null;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(en_nro_nf, 0) > 0 and ev_cod_mod in ('55', '57', '65') then
     --
     vn_fase := 2;
     --
     sv_nro_chave_nfe := pk_csf.fkg_chave_nf(en_notafiscal_id => en_notafiscal_id);
     --
     vn_fase := 3;
     -- recupera dados da Empresa
     begin
        --
        select lpad(es.ibge_estado, 2, '0')
              ,(lpad(j.num_cnpj, 8, '0') || lpad(j.num_filial, 4, '0') ||
               lpad(j.dig_cnpj, 2, '0')) cnpj
          into vv_uf_ibge
              ,vv_cnpj
          from Empresa  e
              ,Pessoa   p
              ,cidade   c
              ,estado   es
              ,Juridica j
         where e.id = en_empresa_id
           and p.id = e.pessoa_id
           and c.id = p.cidade_id
           and es.id = c.estado_id
           and j.pessoa_id = p.id;
        --
     exception
        when others then
           --
           gv_mensagem_log := 'Erro ao recuperar os dados da Empresa para criar a Chave de Acesso.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
     end;
     --
     vn_fase := 4;
     --
     if nvl(en_notafiscal_id, 0) > 0 then
        vn_numero := to_number(substr(en_notafiscal_id, 2, 8));
     else
        vn_numero := en_nro_nf;
     end if;
     --
     vn_fase := 5;
     --
     -- verifica a versão ativa do WSDL
     vv_cd_versaowsdl_nfe := pk_csf.fkg_versaowsdl_nfe_estado(en_estado_id => pk_csf.fkg_Estado_ibge_id(ev_ibge_estado => vv_uf_ibge));
     --
     if vv_cd_versaowsdl_nfe = '1.10' then
        vn_cNF_nfe := esn_cNF_nfe;
     else
        vn_cNF_nfe := en_dm_forma_emiss || esn_cNF_nfe; --lpad ( esn_cNF_nfe, 8, '0' );
     end if;
     --
     vn_fase := 6;
     -- Monta a Chave antes de calcular o dígito
     sv_nro_chave_nfe := vv_uf_ibge || to_char(ed_dt_emiss, 'YYMM') ||
                         vv_cnpj || ev_cod_mod ||
                         lpad(en_serie, 3, '0') ||
                         lpad(en_nro_nf, 9, '0') ||
                         lpad(vn_cNF_nfe, 9, '0');
     --
     vn_fase := 7;
     --
     -- calculo do digito verificador ao modulo 11
     sn_dig_verif_chave := pk_csf.fkg_mod_11(ev_codigo => sv_nro_chave_nfe);
     --
     sv_nro_chave_nfe := to_char(sv_nro_chave_nfe || sn_dig_verif_chave);
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_NFChave_Refer fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFCHAVE_REFER;

--------------------------------------------------------------------------------------------------------------------------------
-- Funcao retorna o ID do XML do conhecimento de transporte atraves da chave de acesso, e retornar se o mesmo estiver cancelado
--------------------------------------------------------------------------------------------------------------------------------
FUNCTION FKG_XML_NOTA_FISCAL_CHV(EV_NRO_CHAVE_NFE IN NOTA_FISCAL.NRO_CHAVE_NFE%TYPE)
  RETURN BOOLEAN IS
  --
  vn_notafiscal_id nota_fiscal.id%type;
  --
BEGIN
  --
  begin
     select max(nf.id)
       into vn_notafiscal_id
       from nota_fiscal nf
      where nf.nro_chave_nfe = ev_nro_chave_nfe
        and nf.dm_arm_nfe_terc = 1;
  exception
     when others then
        vn_notafiscal_id := 0;
  end;
  --
  if nvl(vn_notafiscal_id, 0) <> 0 then
     --
     begin
        select nf.id
          into vn_notafiscal_id
          from nota_fiscal nf
         where nf.id = vn_notafiscal_id
           and nf.dm_st_proc = 7; -- cancelada
     exception
        when others then
           vn_notafiscal_id := 0;
     end;
     --
  end if;
  --
  if nvl(vn_notafiscal_id, 0) = 0 then
     return false;
  else
     return true;
  end if;
  --
exception
  when others then
     return false;
end fkg_xml_nota_fiscal_chv;

-------------------------------------------------------------------------------------------------------

-- Integra as informações de impostos do Item da Nota Fiscal -- Processo de impostos - campos flex field
procedure pkb_integr_imp_itemnf_ff ( est_log_generico_nf in out nocopy  dbms_sql.number_table
                               , en_impitemnf_id  in             imp_itemnf.id%type
                               , en_tipoimp_id    in             tipo_imposto.id%type
                               , en_cd_imp        in             tipo_imposto.cd%type
                               , ev_atributo      in             varchar2
                               , ev_valor         in             varchar2
                               , en_multorg_id    in             mult_org.id%type 
                               )
is
--
vn_fase           number := 0;
vn_loggenericonf_id log_generico_nf.id%type;
vv_sigla          tipo_imposto.sigla%type := null;
vn_tiporetimp_id  tipo_ret_imp.id%type := null;
vn_vl_deducao     imp_itemnf.vl_deducao%type := null;
vv_cod_receita           tipo_ret_imp_receita.cod_receita%type;
vn_tiporetimpreceita_id  tipo_ret_imp_receita.id%type;
vn_dmtipocampo    ff_obj_util_integr.dm_tipo_campo%type;
vv_cd_tiporetimp  tipo_ret_imp.cd%type;
vn_cod_nat_rec_pc nat_rec_pc.cod%type := 0;
vn_codst_id       cod_st.id%type := 0;
vn_natrecpc_id    nat_rec_pc.id%type := 0;
vv_mensagem       varchar2(1000) := null;
vn_notafiscal_id  nota_fiscal.id%type;
--
begin
--
vn_fase := 1;
--
gv_mensagem_log := null;
-- Recupera a sigla do Tipo de Imposto.
vv_sigla := pk_csf.fkg_tipo_imposto_sigla ( en_cd => en_cd_imp );
--
vn_fase := 2;
--
if ev_atributo is null then
  --
  vn_fase := 3;
  --
  gv_mensagem_log := 'Impostos do Item da Nota Fiscal: "Atributo" deve ser informado.';
  --
  vn_loggenericonf_id := null;
  --
  pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                   , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                   , ev_resumo          => gv_mensagem_log
                   , en_tipo_log        => erro_de_validacao
                   , en_referencia_id   => gn_referencia_id
                   , ev_obj_referencia  => gv_obj_referencia );
  --
  -- Armazena o "loggenerico_id" na memória
  pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                      , est_log_generico_nf  => est_log_generico_nf );
  --
end if;
--
vn_fase := 4;
--
if ev_valor is null then
  --
  vn_fase := 5;
  --
  gv_mensagem_log := 'Impostos do Item da Nota Fiscal: "VALOR" referente ao atributo deve ser informado.';
  --
  vn_loggenericonf_id := null;
  --
  pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                   , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                   , ev_resumo          => gv_mensagem_log
                   , en_tipo_log        => erro_de_validacao
                   , en_referencia_id   => gn_referencia_id
                   , ev_obj_referencia  => gv_obj_referencia );
  --
  -- Armazena o "loggenerico_id" na memória
  pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                      , est_log_generico_nf  => est_log_generico_nf );
  --
end if;
--
vn_fase := 6;
--
vv_mensagem := pk_csf.fkg_ff_verif_campos( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SC_FF'
                                        , ev_atributo => ev_atributo
                                        , ev_valor    => ev_valor );
--
vn_fase := 7;
--
if vv_mensagem is not null then
  --
  vn_fase := 8;
  --
  gv_mensagem_log := vv_mensagem;
  --
  vn_loggenericonf_id := null;
  --
  pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                   , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                   , ev_resumo          => gv_mensagem_log
                   , en_tipo_log        => erro_de_validacao
                   , en_referencia_id   => gn_referencia_id
                   , ev_obj_referencia  => gv_obj_referencia );
  --
  -- Armazena o "loggenerico_id" na memória
  pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                      , est_log_generico_nf  => est_log_generico_nf );
  --
else
  --
  vn_fase := 9;
  --
  vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SC_FF'
                                                     , ev_atributo => ev_atributo );
  --
  vn_fase := 10;
  --
  if ev_atributo = 'COD_RECEITA' and ev_valor is not null then
     --
     vn_fase := 11;
     --
     if vn_dmtipocampo = 2 then -- tipo de campo = caractere
        --
        vn_fase := 12;
        --
        vv_cod_receita := pk_csf.fkg_ff_ret_vlr_caracter ( ev_obj_name => 'VW_CSF_IMP_ITEMNF_SC_FF'
                                                         , ev_atributo => ev_atributo
                                                         , ev_valor    => ev_valor 
                                                         );
        --
        vn_fase := 13;
        --
        begin
           select ii.tiporetimp_id
             into vn_tiporetimp_id
             from imp_itemnf ii
            where ii.id = en_impitemnf_id;
        exception
           when others then
              vn_tiporetimp_id := 0;
        end;
        --
        if nvl(vn_tiporetimp_id,0) <= 0 then
           --
           begin
              --
              select min(r.id)
                into vn_tiporetimpreceita_id
                from tipo_ret_imp tri
                   , tipo_ret_imp_receita r
               where tri.multorg_id   = en_multorg_id
                 and tri.tipoimp_id   = en_tipoimp_id
                 and r.TIPORETIMP_ID  = tri.id
                 and r.cod_receita    = trim(vv_cod_receita);
              --
           exception
              when others then
                 vn_tiporetimpreceita_id := 0;
           end;
           --
        else
           --
           begin
              --
              select r.id
                into vn_tiporetimpreceita_id
                from tipo_ret_imp_receita r
               where r.TIPORETIMP_ID = vn_tiporetimp_id
                 and r.cod_receita = trim(vv_cod_receita);
              --
           exception
              when others then
                 vn_tiporetimpreceita_id := 0;
           end;
           --
        end if;
        --
        if nvl(vn_tiporetimpreceita_id,0) <= 0 then
           --
           vn_fase := 14;
           --
           gv_mensagem_log := 'Identificador do Código de "Receita do tipo de retenção de imposto" inválido de acordo com o "imposto" ('||
                              pk_csf.fkg_tipo_imp_sigla(en_id => en_tipoimp_id)||'), "tipo de retenção de imposto"(' || pk_csf.fkg_tipo_ret_imp_cd ( en_tiporetimp_id => vn_tiporetimp_id )
                                       || ') e "valor do atributo" ('||ev_valor||'), informados.';
           --
           vn_loggenericonf_id := null;
           --
           pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                            , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                            , ev_resumo         => gv_mensagem_log
                            , en_tipo_log       => erro_de_validacao
                            , en_referencia_id  => gn_referencia_id
                            , ev_obj_referencia => gv_obj_referencia );
           --
           -- Armazena o "loggenerico_id" na memória
           pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                               , est_log_generico_nf => est_log_generico_nf );
           --
        end if;
        --
     else
        --
        vn_fase := 15;
        --
        gv_mensagem_log := 'Para o atributo CD_TIPO_RET_IMP, o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
        --
        vn_loggenericonf_id := null;
        --
        pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenericonf_id
                         , ev_mensagem       => gv_cabec_log || gv_cabec_log_item
                         , ev_resumo         => gv_mensagem_log
                         , en_tipo_log       => erro_de_validacao
                         , en_referencia_id  => gn_referencia_id
                         , ev_obj_referencia => gv_obj_referencia );
        --
        -- Armazena o "loggenerico_id" na memória
        pkb_gt_log_generico_nf ( en_loggenericonf_id   => vn_loggenericonf_id
                            , est_log_generico_nf => est_log_generico_nf );
        --
     end if;
     --
  else
     --
     vn_fase := 28;
     --
     gv_mensagem_log := '"Atributo" ('||ev_atributo||') e "VALOR" ('||ev_valor||') relacionados, não especificados no processo.';
     --
     vn_loggenericonf_id := null;
     --
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                      , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                      , ev_resumo          => gv_mensagem_log
                      , en_tipo_log        => ERRO_DE_VALIDACAO
                      , en_referencia_id   => gn_referencia_id
                      , ev_obj_referencia  => gv_obj_referencia );
     --
     -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                         , est_log_generico_nf  => est_log_generico_nf );
     --
  end if;
  --
end if;
--
vn_fase := 29;
--
if nvl(en_impitemnf_id,0) = 0 then
  --
  vn_fase := 30;
  --
  gv_mensagem_log := 'Identificador do imposto do item da nota fiscal não informado para geração dos campos complementares (FF).';
  --
  vn_loggenericonf_id := null;
  --
  pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                   , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                   , ev_resumo          => gv_mensagem_log
                   , en_tipo_log        => erro_de_validacao
                   , en_referencia_id   => gn_referencia_id
                   , ev_obj_referencia  => gv_obj_referencia );
  --
  -- Armazena o "loggenerico_id" na memória
  pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                      , est_log_generico_nf  => est_log_generico_nf );
  --
end if;
--
vn_fase := 99;
--
-- Se não foi encontrato erro e o Tipo de Integração é 1 (Válida e insere)
-- então realiza a condição de inserir o imposto
begin
 select it.notafiscal_id 
   into vn_notafiscal_id
 from item_nota_fiscal it
where it.id in (select ii.itemnf_id 
                  from imp_itemnf ii
                 where ii.id = en_impitemnf_id );
exception
 when no_data_found then
   vn_notafiscal_id := null;
end;
if nvl(est_log_generico_nf.count,0) > 0 and
  fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => vn_notafiscal_id ) = 1 then
  --
  vn_fase := 99.1;
  --
  update nota_fiscal set dm_st_proc = 10
   where id = vn_notafiscal_id;
  --
end if;
--
vn_fase := 99.2;
--
if nvl(en_impitemnf_id,0) > 0 and
     ev_atributo = 'COD_RECEITA' and
     nvl(vn_tiporetimpreceita_id,0) <> 0 and
     gv_mensagem_log is null then
     --
     vn_fase := 99.5;
     --
     update imp_itemnf ii
        set ii.tiporetimpreceita_id = vn_tiporetimpreceita_id
      where id = en_impitemnf_id;
     --
end if;
--
vn_fase := 100;
--
<<sair_integr>>
null;
--
exception
when others then
  --
  gv_mensagem_log := 'Erro na pkb_integr_Imp_ItemNf_ff fase('||vn_fase||'): '||sqlerrm;
  --
  declare
     vn_loggenericonf_id  log_generico_nf.id%TYPE;
  begin
     --
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenericonf_id
                      , ev_mensagem        => gv_cabec_log || gv_cabec_log_item
                      , ev_resumo          => gv_mensagem_log
                      , en_tipo_log        => ERRO_DE_SISTEMA
                      , en_referencia_id   => gn_referencia_id
                      , ev_obj_referencia  => gv_obj_referencia );
     --
     -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenericonf_id
                         , est_log_generico_nf  => est_log_generico_nf );
     --
  exception
     when others then
        null;
  end;
  --
end pkb_integr_Imp_ItemNf_ff;

---------------------------------------------------------------
-- Integra as informações de impostos do Item da Nota Fiscal --
---------------------------------------------------------------
procedure pkb_integr_imp_itemnf(est_log_generico_nf in out nocopy dbms_sql.number_table
                              ,est_row_imp_itemnf  in out nocopy imp_itemnf%rowtype
                              ,en_cd_imp           in tipo_imposto.cd%type
                              ,ev_cod_st           in cod_st.cod_st%type
                              ,ev_cod_tipoRet      in varchar2
                              ,ev_cod_natRecPC     in number
                              ,en_notafiscal_id    in nota_fiscal.id%type
                              ,ev_sigla_estado     in estado.sigla_estado%type default null
                              ,en_multorg_id       in mult_org.id%type
                              ) IS
  --
  vn_fase                 number := 0;
  vn_loggenerico_id       log_generico_nf.id%type;
  vv_Sigla                Tipo_Imposto.Sigla%TYPE := null;
  vn_dm_rateia_ii_vl_item empresa.dm_rateia_ii_vl_item%type := null;
  vn_natRec               nat_rec_pc.id%type;
  vn_tipoRet              tipo_ret_imp.id%type;
  vn_notafiscal_id        nota_fiscal.id%type;
  --
begin
  --
  vn_fase := 2;
  --
  if nvl(est_row_Imp_ItemNf.itemnf_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 3;
     --
     gv_mensagem_log := 'Não informado ITEM da Nota Fiscal para registro dos Impostos.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 4;
  --
  -- Recupera o Tipo de Imposto, se não informado registra o erro de validacao
  if nvl(en_cd_imp, 0) > 0 then
     --
     vn_fase := 5;
     --
     est_row_Imp_ItemNf.tipoimp_id := pk_csf.fkg_Tipo_Imposto_id(en_cd => en_cd_imp);
     --
     vn_fase := 6;
     -- Se não encontrou o tipo de imposto registra o log
     if nvl(est_row_Imp_ItemNf.tipoimp_id, 0) = 0 then
        --
        vn_fase := 7;
        --
        gv_mensagem_log := '"Tipo de Imposto da Nota Fiscal" está inválido ('||en_cd_imp||').';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     else
        --
        vn_fase := 8;
        --
        vv_Sigla := pk_csf.fkg_Tipo_Imposto_Sigla(en_cd => en_cd_imp);
        --
        if(est_row_Imp_ItemNf.dm_tipo = 1) then
          begin
            select ret.id
                   into
                   vn_tipoRet
                 from tipo_ret_imp ret
            where ret.cd = trim(ev_cod_tipoRet)
              and ret.tipoimp_id = est_row_Imp_ItemNf.tipoimp_id
              and ret.multorg_id = en_multorg_id;
          exception
            when others then
              vn_tipoRet := null;
              gv_mensagem_log := '"Tipo de imposto informado como retenção, no entanto o código da retenção não encontrado ('||en_cd_imp||').';
              --
              vn_loggenerico_id := null;
              --
              pkb_log_generico_nf( sn_loggenericonf_id => vn_loggenerico_id
                                 , ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                                 , ev_resumo           => gv_mensagem_log
                                 , en_tipo_log         => erro_de_validacao
                                 , en_referencia_id    => gn_referencia_id
                                 , ev_obj_referencia   => gv_obj_referencia);
              -- Armazena o "loggenerico_id" na memoria
              pkb_gt_log_generico_nf( en_loggenericonf_id => vn_loggenerico_id
                                    , est_log_generico_nf => est_log_generico_nf);
          end;
          --
        end if;
        --
     end if;
     --
  else
     --
     vn_fase := 9;
     --
     gv_mensagem_log := '"Tipo de Imposto da Nota Fiscal" não informado.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 10;
  --
  if nvl(en_cd_imp, 0) = 1 -- ICMS
     and ev_cod_st = '40' -- Isenta
     and nvl(gt_row_Item_Nota_Fiscal.dm_mot_des_icms, 0) <= 0 then
     --
     est_row_Imp_ItemNf.vl_imp_trib := 0;
     --
  end if;
  --
  vn_fase := 11;
  --
  -- Recupera o Código de tributacao
  if ev_cod_st is not null and
     nvl(est_row_Imp_ItemNf.tipoimp_id, 0) > 0 then
     --
     vn_fase := 12;
     --
     -- Conforme o imposto, restorna o ID do Código da tributação
     est_row_Imp_ItemNf.codst_id := pk_csf.fkg_Cod_ST_id(ev_cod_st     => ev_cod_st
                                                        ,en_tipoimp_id => est_row_Imp_ItemNf.tipoimp_id);
     --
     vn_fase := 12.1;
     --
     if nvl(est_row_Imp_ItemNf.codst_id,0) > 0 then
       begin
         select
               id
               into
               vn_natRec
            from nat_rec_pc
          where cod = ev_cod_natRecPC
            and codst_id = est_row_Imp_ItemNf.codst_id;
       exception
         when others then
              vn_natRec := null; -- somente para pis e cofins
       end;
     end if;
  end if;
  --
  vn_fase := 13;
  -- Valida se o Código da Situação Tributária deveria ser obrigatario
  -- Se não tem CST e o imposto e 1-Icms, 3-IPI, 4-PIS ou 5-Cofins
  if nvl(est_row_Imp_ItemNf.codst_id, 0) <= 0 and
     est_row_Imp_ItemNf.dm_tipo = 0 and -- Imposto
     en_cd_imp in (case when gt_row_Nota_Fiscal_Emit.dm_reg_trib = 3 then 1 else 10 end -- Se o Regime tributario for 3-Normal, valida o 1-ICMS senão valida 10-SN - Simples Nacional
                  ,3
                  ,4
                  ,5
                  ,10) then -- 3-IPI, 4-PIS, 5-COFINS, 10-SN
     --
     vn_fase := 14;
     --
     gv_mensagem_log := 'Não foi informado o Código de Situação Tributária para o tipo de imposto '||vv_Sigla||'.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 15;
  --
  if nvl(est_row_Imp_ItemNf.codst_id, 0) <= 0 and
     en_cd_imp in (case when gt_row_Nota_Fiscal_Emit.dm_reg_trib = 3 then 1 else 10 end -- Se o Regime tributario for 3-Normal, valida o ICMS
                  ,3
                  ,4
                  ,5
                  ,6
                  ,10) and trim(ev_cod_st) is not null then
     --
     vn_fase := 16;
     --
     gv_mensagem_log := 'Código de Situação Tributária está inválido ('||ev_cod_st||') para o tipo de imposto '||vv_Sigla||'.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 17;
  --
  -- Valida informação do campo dm_tipo se Imposto ou Retencao
  if est_row_Imp_ItemNf.dm_tipo not in (0, 1) then
     --
     vn_fase := 18;
     --
     gv_mensagem_log := '"Tipo de Impostos da Nota Fiscal" ('||est_row_Imp_ItemNf.dm_tipo||') está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  --
  vn_fase := 19;
  --
  -- Validacoes de numeros negativos
  --
  if nvl(est_row_Imp_ItemNf.vl_base_calc, 0) < 0 then
     --
     vn_fase := 20;
     --
     gv_mensagem_log := '"Valor da base de cálculo de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.vl_base_calc||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 21;
  --
  if nvl(est_row_Imp_ItemNf.aliq_apli, 0) < 0 then
     --
     vn_fase := 22;
     --
     gv_mensagem_log := '"Alíquota de Imposto de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.aliq_apli||') não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 23;
  --
  if nvl(est_row_Imp_ItemNf.vl_imp_trib, 0) < 0 then
     --
     vn_fase := 24;
     --
     gv_mensagem_log := '"Valor do Imposto Tributado de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.vl_imp_trib||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 25;
  --
  if nvl(est_row_Imp_ItemNf.perc_reduc, 0) < 0 then
     --
     vn_fase := 26;
     --
     est_row_Imp_ItemNf.perc_reduc := 0;
     --
  end if;
  --
  vn_fase := 27;
  --
  if nvl(est_row_Imp_ItemNf.perc_adic, 0) < 0 then
     --
     vn_fase := 28;
     --
     gv_mensagem_log := '"Percentual Adicional de Imposto de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.perc_adic||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 29;
  --
  if nvl(est_row_Imp_ItemNf.qtde_base_calc_prod, 0) < 0 then
     --
     vn_fase := 30;
     --
     gv_mensagem_log := '"Base de cálculo por quantidade vendida de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.qtde_base_calc_prod||') não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 31;
  --
  if nvl(est_row_Imp_ItemNf.vl_aliq_prod, 0) < 0 then
     --
     vn_fase := 32;
     --
     gv_mensagem_log := '"Alíquota de Imposto (em reais) de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.vl_aliq_prod||') não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 33;
  -- não Atribui valores zerados para não ocorrer erro de XML
  if nvl(est_row_Imp_ItemNf.vl_base_calc, 0) > 0 or
     nvl(est_row_Imp_ItemNf.aliq_apli, 0) > 0 then
     --
     est_row_Imp_ItemNf.vl_base_calc        := nvl(est_row_Imp_ItemNf.vl_base_calc,0);
     est_row_Imp_ItemNf.aliq_apli           := nvl(est_row_Imp_ItemNf.aliq_apli,0);
     est_row_Imp_ItemNf.qtde_base_calc_prod := null;
     est_row_Imp_ItemNf.vl_aliq_prod        := null;
     --
  elsif nvl(est_row_Imp_ItemNf.qtde_base_calc_prod, 0) > 0 or
        nvl(est_row_Imp_ItemNf.vl_aliq_prod, 0) > 0 then
     --
     est_row_Imp_ItemNf.qtde_base_calc_prod := nvl(est_row_Imp_ItemNf.qtde_base_calc_prod,0);
     est_row_Imp_ItemNf.vl_aliq_prod        := nvl(est_row_Imp_ItemNf.vl_aliq_prod,0);
     est_row_Imp_ItemNf.vl_base_calc        := null;
     est_row_Imp_ItemNf.aliq_apli           := null;
     --
  else
     --
     est_row_Imp_ItemNf.vl_base_calc        := 0;
     est_row_Imp_ItemNf.aliq_apli           := 0;
     est_row_Imp_ItemNf.qtde_base_calc_prod := null;
     est_row_Imp_ItemNf.vl_aliq_prod        := null;
     --
  end if;
  --
  vn_fase := 34;
  --
  if nvl(est_row_Imp_ItemNf.vl_bc_st_ret, 0) < 0 then
     --
     vn_fase := 35;
     --
     gv_mensagem_log := '"Valor da BC do ICMS ST retido de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.vl_bc_st_ret||') não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 36;
  --
  if nvl(est_row_Imp_ItemNf.vl_icmsst_ret, 0) < 0 then
     --
     vn_fase := 37;
     --
     gv_mensagem_log := '"Valor do ICMS ST retido de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.vl_icmsst_ret||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 38;
  --
  if nvl(est_row_Imp_ItemNf.perc_bc_oper_prop, 0) < 0 then
     --
     vn_fase := 39;
     --
     gv_mensagem_log := '"Percentual da BC operação própria de '||vv_Sigla||'" ('||est_row_Imp_ItemNf.perc_bc_oper_prop||') não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 40;
  -- Se a UF foi informada, busca seu ID
  if trim(ev_sigla_estado) is not null then
     --
     vn_fase := 41;
     --
     est_row_Imp_ItemNf.estado_id := pk_csf.fkg_Estado_id(ev_sigla_estado => trim(ev_sigla_estado));
     --
     vn_fase := 42;
     --
     if nvl(est_row_Imp_ItemNf.estado_id, 0) <= 0 then
        --
        vn_fase := 43;
        --
        gv_mensagem_log := '"UF para qual e devido o ICMS ST" ('||ev_sigla_estado||') está invalida!';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
     vn_fase := 44;
     --
     if nvl(est_row_Imp_ItemNf.estado_id, 0) > 0 and
        nvl(est_row_Imp_ItemNf.perc_bc_oper_prop, 0) <= 0 then
        --
        est_row_Imp_ItemNf.perc_bc_oper_prop := null;
        --
     end if;
     --
  end if;
  --
  vn_fase := 45;
  --
  if nvl(est_row_Imp_ItemNf.vl_bc_st_dest, 0) < 0 then
     --
     vn_fase := 46;
     --
     gv_mensagem_log := '"Valor da BC do ICMS ST da UF destino" ('||est_row_Imp_ItemNf.vl_bc_st_dest||') não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 47;
  --
  if nvl(est_row_Imp_ItemNf.vl_icmsst_dest, 0) < 0 then
     --
     vn_fase := 48;
     --
     gv_mensagem_log := '"Valor do ICMS ST da UF destino" ('||est_row_Imp_ItemNf.vl_icmsst_dest||') não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 49;
  --
  -- Se não foi encontrado erro e o Tipo de Integracao 1 (Valida e insere)
  -- entao realiza a condicao de inserir o imposto
  begin
    select distinct it.notafiscal_id
      into vn_notafiscal_id
      from item_nota_fiscal it
     where it.id = est_row_Imp_ItemNf.itemnf_id;
  exception
    when no_data_found then
      vn_notafiscal_id := null;
  end;
  --
  if nvl(est_log_generico_nf.count, 0) > 0 and
     fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => vn_notafiscal_id ) = 1 then
     --
     update nota_fiscal
        set dm_st_proc = 10
      where id = vn_notafiscal_id;
     --
  end if;
  --
  vn_fase := 50;
  --
  est_row_Imp_ItemNf.vl_imp_trib := nvl(est_row_Imp_ItemNf.vl_imp_trib
                                       ,0);
  --
  vn_fase := 51;
  --
  begin
     --
     select dm_rateia_ii_vl_item
       into vn_dm_rateia_ii_vl_item
       from empresa
      where id = gt_row_Nota_Fiscal.empresa_id;
     --
  exception
     when others then
        vn_dm_rateia_ii_vl_item := 0;
  end;
  --
  vn_fase := 52;
  --
  if en_cd_imp = 7 -- Imposto de importacao
     and nvl(est_row_Imp_ItemNf.vl_imp_trib, 0) > 0 and
     nvl(vn_dm_rateia_ii_vl_item, 0) = 1 then
     -- Adidas
     --
     declare
        --
        vn_vl_unit       item_nota_fiscal.vl_unit_comerc%type := 0;
        vn_ii_unit       item_nota_fiscal.vl_unit_comerc%type := 0; -- imposto de importacao unitário
        vn_vl_item_bruto item_nota_fiscal.vl_item_bruto%type := 0;
        --
     begin
        --
        vn_fase := 53;
        --
        if nvl(est_row_Imp_ItemNf.vl_imp_trib, 0) > 0 then
           --
           vn_fase := 54;
           --
           vn_ii_unit       := round((nvl(est_row_Imp_ItemNf.vl_imp_trib
                                         ,0) / nvl(gt_row_Item_Nota_Fiscal.qtde_comerc
                                                   ,0))
                                    ,10);
           vn_vl_unit       := nvl(gt_row_Item_Nota_Fiscal.vl_unit_comerc
                                  ,0) - nvl(vn_ii_unit, 0);
           vn_vl_item_bruto := round((nvl(gt_row_Item_Nota_Fiscal.qtde_comerc
                                         ,0) * nvl(vn_vl_unit, 0))
                                    ,2);
           --
           vn_fase := 55;
           --
           update item_nota_fiscal
              set VL_UNIT_COMERC = vn_vl_unit
                 ,VL_ITEM_BRUTO  = vn_vl_item_bruto
                 ,VL_UNIT_TRIB   = vn_vl_unit
            where id = est_row_Imp_ItemNf.itemnf_id;
           --
        end if;
        --
     end;
     --
  end if;
  --
  est_row_Imp_ItemNf.vl_icms_oper  := 0;
  est_row_Imp_ItemNf.vl_icms_difer := 0;
  --
  vn_fase := 56;
  --
  if nvl(est_row_Imp_ItemNf.itemnf_id, 0) > 0 and
     nvl(est_row_Imp_ItemNf.tipoimp_id, 0) > 0 and
     est_row_Imp_ItemNf.dm_tipo in (0, 1) then
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 57;
        --
        select impitemnf_seq.nextval
          into est_row_Imp_ItemNf.id
          from dual;
        --
        vn_fase := 58;
        --
        insert into Imp_ItemNf
           (id
           ,itemnf_id
           ,tipoimp_id
           ,dm_tipo
           ,codst_id
           ,vl_base_calc
           ,aliq_apli
           ,vl_imp_trib
           ,perc_reduc
           ,perc_adic
           ,qtde_base_calc_prod
           ,vl_aliq_prod
           ,vl_bc_st_ret
           ,vl_icmsst_ret
           ,perc_bc_oper_prop
           ,estado_id
           ,vl_bc_st_dest
           ,vl_icmsst_dest
           ,vl_icms_oper
           ,vl_icms_difer
           ,tiporetimp_id
           ,natrecpc_id)
        values
           (est_row_Imp_ItemNf.id
           ,est_row_Imp_ItemNf.itemnf_id
           ,est_row_Imp_ItemNf.tipoimp_id
           ,est_row_Imp_ItemNf.dm_tipo
           ,est_row_Imp_ItemNf.codst_id
           ,est_row_Imp_ItemNf.vl_base_calc
           ,est_row_Imp_ItemNf.aliq_apli
           ,est_row_Imp_ItemNf.vl_imp_trib
           ,est_row_Imp_ItemNf.perc_reduc
           ,est_row_Imp_ItemNf.perc_adic
           ,est_row_Imp_ItemNf.qtde_base_calc_prod
           ,est_row_Imp_ItemNf.vl_aliq_prod
           ,est_row_Imp_ItemNf.vl_bc_st_ret
           ,est_row_Imp_ItemNf.vl_icmsst_ret
           ,est_row_Imp_ItemNf.perc_bc_oper_prop
           ,est_row_Imp_ItemNf.estado_id
           ,est_row_Imp_ItemNf.vl_bc_st_dest
           ,est_row_Imp_ItemNf.vl_icmsst_dest
           ,est_row_Imp_ItemNf.vl_icms_oper
           ,est_row_Imp_ItemNf.vl_icms_difer
           ,vn_tipoRet
           ,vn_natRec);
        --
     else
        --
        vn_fase := 59;
        --
        update Imp_ItemNf
           set tipoimp_id          = est_row_Imp_ItemNf.tipoimp_id
              ,dm_tipo             = est_row_Imp_ItemNf.dm_tipo
              ,codst_id            = est_row_Imp_ItemNf.codst_id
              ,vl_base_calc        = est_row_Imp_ItemNf.vl_base_calc
              ,aliq_apli           = est_row_Imp_ItemNf.aliq_apli
              ,vl_imp_trib         = est_row_Imp_ItemNf.vl_imp_trib
              ,perc_reduc          = est_row_Imp_ItemNf.perc_reduc
              ,perc_adic           = est_row_Imp_ItemNf.perc_adic
              ,qtde_base_calc_prod = est_row_Imp_ItemNf.qtde_base_calc_prod
              ,vl_aliq_prod        = est_row_Imp_ItemNf.vl_aliq_prod
              ,vl_bc_st_ret        = est_row_Imp_ItemNf.vl_bc_st_ret
              ,vl_icmsst_ret       = est_row_Imp_ItemNf.vl_icmsst_ret
              ,perc_bc_oper_prop   = est_row_Imp_ItemNf.perc_bc_oper_prop
              ,estado_id           = est_row_Imp_ItemNf.estado_id
              ,vl_bc_st_dest       = est_row_Imp_ItemNf.vl_bc_st_dest
              ,vl_icmsst_dest      = est_row_Imp_ItemNf.vl_icmsst_dest
              ,vl_icms_oper        = est_row_Imp_ItemNf.vl_icms_oper
              ,vl_icms_difer       = est_row_Imp_ItemNf.vl_icms_difer
              ,tiporetimp_id       = vn_tipoRet
              ,natrecpc_id         = vn_natRec
         where id = est_row_Imp_ItemNf.id;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_Imp_ItemNf fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_IMP_ITEMNF;

-----------------------------------------------------
-- Integra as informações dos itens da nota fiscal --
-----------------------------------------------------
procedure pkb_integr_item_nota_fiscal(est_log_generico_nf      in out nocopy dbms_sql.number_table
                                    ,est_row_item_nota_fiscal in out nocopy item_nota_fiscal%rowtype
                                    ,ev_cod_class             in varchar2
                                    ,en_multorg_id            in mult_org.id%type) is
  --
  vn_fase              number := 0;
  vn_loggenerico_id    log_generico_nf.id%type;
  vn_dm_valid_unid_med empresa.dm_valid_unid_med%type := null;
  vn_unidade_id_com    Unidade.id%TYPE;
  vn_unidade_id_trib   Unidade.id%TYPE;
  vn_dm_integr_item    empresa.dm_integr_item%type := null;
  vn_empresa_id        empresa.id%type;
  vv_ncmitemnf         item_nota_fiscal.cod_ncm%type;
  vv_codncm            ncm.cod_ncm%type;
  vn_ncmemp            empresa.dm_val_ncm_item%type;
  vn_id_codClass       class_cons_item_cont.id%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  vn_dm_valid_unid_med := pk_csf.fkg_empresa_valid_unid_med(en_empresa_id => gt_row_Nota_Fiscal.empresa_id);
  --
  vn_fase := 2;
  --
  gv_cabec_log_item := 'Nro: ' || est_row_Item_Nota_Fiscal.nro_item ||
                       ' Item: ' || est_row_Item_Nota_Fiscal.cod_item ||
                       ' - ' || est_row_Item_Nota_Fiscal.descr_item ||
                       chr(10);
  --
  if nvl(est_row_Item_Nota_Fiscal.notafiscal_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 3;
     --
     gv_mensagem_log := 'Não informada a Nota Fiscal para registro dos Produtos e Serviços.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 4;
  --
  -- Validar o campo dm_mod_base_calc
  if nvl(est_row_Item_Nota_Fiscal.dm_mod_base_calc, 0) not in (0, 1, 2, 3) then
     --
     vn_fase := 4.1;
     --
     gv_mensagem_log := '"Modalidade de determinação da BC do ICMS ITEM/PRODUTO da Nota Fiscal" ('||est_row_Item_Nota_Fiscal.dm_mod_base_calc||
                        ') está inválida.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 5;
  --
  -- Valida a informação do campo dm_mod_base_calc_st
  if est_row_Item_Nota_Fiscal.dm_mod_base_calc_st not in (0, 1, 2, 3, 4, 5, 6) then
     --
     vn_fase := 5.1;
     --
     gv_mensagem_log := '"Modalidade de determinação da BC do ICMS ST ITEM/PRODUTO da Nota Fiscal" ('||est_row_Item_Nota_Fiscal.dm_mod_base_calc_st||
                        ') está inválida.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 6;
  --
  -- Valida o campo nro_item
  if nvl(est_row_Item_Nota_Fiscal.nro_item, 0) <= 0 then
     --
     vn_fase := 6.1;
     --
     gv_mensagem_log := '"Número do ITEM da Nota Fiscal" ('||nvl(est_row_Item_Nota_Fiscal.nro_item,0)||') está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 7;
  --
  est_row_Item_Nota_Fiscal.cod_item := upper(est_row_Item_Nota_Fiscal.cod_item);
  -- Valida o campo cod_item
  if trim(est_row_Item_Nota_Fiscal.cod_item) is null then
     --
     vn_fase := 7.1;
     --
     gv_mensagem_log := '"Código do produto ou serviço da Nota Fiscal" não informado.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  else
     --
     vn_fase := 7.2;
     -- com o "Código do item" recupera do item_id
     est_row_Item_Nota_Fiscal.item_id := pk_csf.fkg_Item_id_conf_empr(en_empresa_id => pk_csf.fkg_empresa_notafiscal(en_notafiscal_id => est_row_Item_Nota_Fiscal.notafiscal_id)
                                                                     ,ev_cod_item   => trim(est_row_Item_Nota_Fiscal.cod_item));
     --
  end if;
  --
  vn_fase := 8;
  -- Valida o EAN
  if length(trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.CEAN))) not in (0, 8, 12, 13, 14) then
     --
     vn_fase := 8.1;
     --
     gv_mensagem_log := '"GTIN (Global Trade Item Number) do produto, antigo Código EAN ou Código de barras" inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 9;
  -- Valida o EAN
  if length(trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.CEAN_TRIB))) not in (0, 8, 12, 13, 14) then
     --
     vn_fase := 9.1;
     --
     gv_mensagem_log := '"GTIN (Global Trade Item Number) da unidade tributavel, antigo Código EAN ou Código de barras" inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 10;
  --
  -- Valida se o campo item_id e valido (Produto/serviço)
  if nvl(est_row_Item_Nota_Fiscal.item_id, 0) > 0 and pk_csf.fkg_item_id_valido(en_item_id => est_row_Item_Nota_Fiscal.item_id) = false then
     --
     vn_fase := 10.1;
     --
     gv_mensagem_log := '"Código do produto ou serviço da Nota Fiscal" inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 11;
  --
  -- Valida o campo descr_item
  if trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.descr_item)) is null then
     --
     vn_fase := 11.1;
     --
     gv_mensagem_log := '"Descriminação do produto ou serviço da Nota Fiscal" deve ser informada.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  --
  vn_fase := 12;
  --
  -- Valida informação do campo cfop
  est_row_Item_Nota_Fiscal.cfop_id := pk_csf.fkg_cfop_id(en_cd => est_row_Item_Nota_Fiscal.cfop);
  --
  vn_fase := 12.1;
  --
  if nvl(est_row_Item_Nota_Fiscal.cfop_id, 0) = 0 then
     --
     vn_fase := 12.2;
     --
     gv_mensagem_log := '"CFOP do produto ou serviço da Nota Fiscal" está inválido ('||est_row_Item_Nota_Fiscal.cfop||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 13;
  -- Valida informação do campo orig
  if est_row_Item_Nota_Fiscal.orig not in (0, 1, 2, 3, 4, 5, 6, 7, 8) then
     --
     vn_fase := 13.1;
     --
     gv_mensagem_log := '"Origem da mercadoria da Nota Fiscal" ('||est_row_Item_Nota_Fiscal.orig||') está inválida.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  if gv_cod_mod in ('21', '22')
     and gt_row_nota_fiscal.dt_emiss >= to_date('01/01/2017', 'dd/mm/rrrr')
     and nvl(est_row_Item_Nota_Fiscal.orig, -1) not in (0)
     then
     --
     gv_mensagem_log := 'Código da Origem da Mercadoria inválido para documentos fiscais de código 21 e 22. Utilizar origem da Mercadoria 0 - Nacional).';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 14;
  --
  -- Valida informação do campo cd_lista_serv
  if nvl(est_row_Item_Nota_Fiscal.cd_lista_serv, 0) > 0 then
     --
     vn_fase := 14.1;
     --
     est_row_Item_Nota_Fiscal.cd_lista_serv := replace(est_row_Item_Nota_Fiscal.cd_lista_serv
                                                      ,'.'
                                                      ,'');
     --
     vn_fase := 14.2;
     --
     if nvl(pk_csf.fkg_Tipo_servico_id(ev_cod_lst => est_row_Item_Nota_Fiscal.cd_lista_serv),0) = 0 then
        --
        vn_fase := 14.3;
        --
        gv_mensagem_log := '"Código do serviço do Item da Nota Fiscal" ('||est_row_Item_Nota_Fiscal.cd_lista_serv||') está inválido.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  ELSE
     --
     vn_fase := 14.4;
     --
     est_row_Item_Nota_Fiscal.cd_lista_serv := null;
     --
  end if;
  --
  vn_fase := 15;
  -- Valida a informação do campo cidade_ibge "Código do municipio de ocorrecia do fato gerador do ISSQN"
  if nvl(est_row_Item_Nota_Fiscal.cidade_ibge, 0) > 0 then
     --
     vn_fase := 15.1;
     --
     if pk_csf.fkg_ibge_cidade(ev_ibge_cidade => est_row_Item_Nota_Fiscal.cidade_ibge) = false then
        --
        vn_fase := 15.2;
        --
        gv_mensagem_log := '"Código do município de ocorrência do fato gerador do ISSQN" ('||est_row_Item_Nota_Fiscal.cidade_ibge||
                           ') está inválido.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 16;
  -- Valida o Código do Selo do IPI
  if est_row_Item_Nota_Fiscal.cod_selo_ipi is not null then
     --
     vn_fase := 16.1;
     --
     est_row_Item_Nota_Fiscal.selocontripi_id := pk_csf.fkg_Selo_Contr_IPI_id(est_row_Item_Nota_Fiscal.cod_selo_ipi);
     --
     vn_fase := 16.2;
     --
     if nvl(est_row_Item_Nota_Fiscal.selocontripi_id, 0) = 0 then
        --
        vn_fase := 16.3;
        --
        gv_mensagem_log := '"Código do Selo do IPI" ('||est_row_Item_Nota_Fiscal.cod_selo_ipi||') está inválido.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 17;
  -- Código de Enquadramento Legal do IPI
  if trim(est_row_Item_Nota_Fiscal.cod_enq_ipi) is null then
     --
     est_row_Item_Nota_Fiscal.cod_enq_ipi := '999'; -- informar 999 enquanto a tabela não for criada, pela RFB
     --
  end if;
  --
  vn_fase := 18;
  --
  -- Valida informação de Quantidade Comercial
  if nvl(est_row_Item_Nota_Fiscal.qtde_Comerc, 0) < 0 then
     --
     vn_fase := 18.1;
     --
     gv_mensagem_log := '"Quantidade Comercial" ('||est_row_Item_Nota_Fiscal.qtde_Comerc||') não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 19;
  -- Valida informação de Quantidade Comercial no caso de "Terceiro" não pode ser zero
  if nvl(est_row_Item_Nota_Fiscal.qtde_Comerc, 0) <= 0 and
     gt_row_nota_fiscal.dm_ind_emit = 1 and -- terceiros
     est_row_Item_Nota_Fiscal.cfop not in ('1600','1601','1602','1603','1605','2600','2603','5600','5601','5602','5603','5605','5606','6600','6603') then
     --
     vn_fase := 19.1;
     --
     gv_mensagem_log := 'Para NFe de terceiro, que não é de transferência de saldo, a "Quantidade Comercial" ('||est_row_Item_Nota_Fiscal.qtde_Comerc||
                        ') não pode ser negativa ou zero(0).';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 20;
  --
  -- Valida informação de Valor Unitário de comercialização
  if nvl(est_row_Item_Nota_Fiscal.vl_Unit_Comerc, 0) < 0 then
     --
     vn_fase := 20.1;
     --
     gv_mensagem_log := '"Valor unitário de comercialização" ('||est_row_Item_Nota_Fiscal.vl_Unit_Comerc||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 21;
  --
  -- Valida a informação de Valor Total Bruto dos Produtos ou Serviços
  if nvl(est_row_Item_Nota_Fiscal.vl_Item_Bruto, 0) < 0 then
     --
     vn_fase := 21.1;
     --
     gv_mensagem_log := '"Valor Total Bruto dos Produtos ou serviços" ('||est_row_Item_Nota_Fiscal.vl_Item_Bruto||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 22;
  --
  -- Valida a informação de Quantidade Tributável no caso de "Terceiro" não pode ser zero
  if nvl(est_row_Item_Nota_Fiscal.qtde_Trib, 0) <= 0 and
     gt_row_nota_fiscal.dm_ind_emit = 1 and --Terceiros
     est_row_Item_Nota_Fiscal.cfop not in ('1600','1601','1602','1603','1605','2600','2603','5600','5601','5602','5603','5605','5606','6600','6603') then
     --
     vn_fase := 22.1;
     --
     gv_mensagem_log := 'Para NFe de terceiro, que não é de transferência de saldo, a "Quantidade Tributável" ('||est_row_Item_Nota_Fiscal.qtde_Trib||
                        ') não pode ser negativa ou zero(0).';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 23;
  -- Valida a informação de Quantidade Tributavel
  if nvl(est_row_Item_Nota_Fiscal.qtde_Trib, 0) < 0 then
     --
     vn_fase := 23.1;
     --
     gv_mensagem_log := '"Quantidade Tributável" ('||est_row_Item_Nota_Fiscal.qtde_Trib||') não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 24;
  -- Valida a informação de Valor Unitario de tributacao
  if nvl(est_row_Item_Nota_Fiscal.vl_Unit_Trib, 0) < 0 then
     --
     vn_fase := 24.1;
     --
     gv_mensagem_log := '"Valor Unitário de tributação" ('||est_row_Item_Nota_Fiscal.vl_Unit_Trib||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 25;
  -- Valida a informação de Valor Total do Frete
  if nvl(est_row_Item_Nota_Fiscal.vl_Frete, 0) < 0 then
     --
     vn_fase := 25.1;
     --
     gv_mensagem_log := '"Valor Total do Frete" ('||est_row_Item_Nota_Fiscal.vl_Frete||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 26;
  -- Valida a informação de Valor Total do Seguro
  if nvl(est_row_Item_Nota_Fiscal.vl_Seguro, 0) < 0 then
     --
     vn_fase := 26.1;
     --
     gv_mensagem_log := '"Valor Total do Seguro" ('||est_row_Item_Nota_Fiscal.vl_Seguro||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 27;
  --
  -- Valida a informação de Valor do Desconto
  if nvl(est_row_Item_Nota_Fiscal.vl_Desc, 0) < 0 then
     --
     vn_fase := 27.1;
     --
     gv_mensagem_log := '"Valor do Desconto" ('||est_row_Item_Nota_Fiscal.vl_Desc||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 28;
  -- Valida se a informação de Valor Total Bruto dos Produtos ou serviços e maior ou igual a informação de Valor do Desconto
  if nvl(est_row_item_nota_fiscal.vl_item_bruto, 0) < nvl(est_row_item_nota_fiscal.vl_desc, 0) then
     --
     vn_fase := 28.1;
     --
     gv_mensagem_log := '"Valor Total Bruto dos Produtos ou serviços" ('||est_row_item_nota_fiscal.vl_item_bruto||') não pode ser menor que o "Valor do '||
                        'Desconto" ('||est_row_item_nota_fiscal.vl_desc||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 29;
  --
  -- Valida a informação de Valor das despesas aduaneiras
  if nvl(est_row_Item_Nota_Fiscal.vl_desp_adu, 0) < 0 then
     --
     vn_fase := 29.1;
     --
     gv_mensagem_log := '"Valor das despesas aduaneiras" ('||est_row_Item_Nota_Fiscal.vl_desp_adu||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  elsif nvl(est_row_Item_Nota_Fiscal.vl_desp_adu, 0) <= 0 then
     est_row_Item_Nota_Fiscal.vl_desp_adu := 0;
  end if;
  --
  vn_fase := 30;
  -- Valida a informação de Valor do Imposto sobre Operacoes Financeiras
  if nvl(est_row_Item_Nota_Fiscal.vl_iof, 0) < 0 then
     --
     vn_fase := 30.1;
     --
     gv_mensagem_log := '"Valor do Imposto sobre Operações Financeiras" ('||est_row_Item_Nota_Fiscal.vl_iof||') não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  elsif nvl(est_row_Item_Nota_Fiscal.vl_iof, 0) <= 0 then
     est_row_Item_Nota_Fiscal.vl_iof := 0;
  end if;
  --
  vn_fase := 31;
  --
  -- Valida informação do Indicador de apuracao do IPI
  --
  if nvl(est_row_Item_Nota_Fiscal.dm_ind_apur_ipi, 0) > -1 and
     est_row_Item_Nota_Fiscal.dm_ind_apur_ipi not in (0, 1) then
     --
     vn_fase := 31.1;
     --
     gv_mensagem_log := '"Indicador de Apuracão do IPI" ('||est_row_Item_Nota_Fiscal.dm_ind_apur_ipi||') do Item da Nota Fiscal está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 32;
  --
  est_row_Item_Nota_Fiscal.unid_com := trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.unid_com));
  --
  vn_fase := 33;
  -- Valida informação da Unidade Comercial
  if trim(est_row_Item_Nota_Fiscal.unid_com) is null then
     --
     vn_fase := 33.1;
     --
     gv_mensagem_log := '"Unidade Comercial" não foi informada.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 34;
  -- Verifica se a empresa valida unidade de medida, com o cadastro do Compliance
  if nvl(vn_dm_valid_unid_med, 0) = 1 then
     -- Sim
     --
     vn_fase := 34.1;
     -- valida unidade comercial
     vn_unidade_id_com := pk_csf.fkg_Unidade_id(en_multorg_id => en_multorg_id
                                               ,ev_sigla_unid => trim(est_row_Item_Nota_Fiscal.unid_com));
     --
     vn_fase := 34.2;
     --
     if nvl(vn_unidade_id_com, 0) <= 0 then
        --
        vn_fase := 34.3;
        --
        gv_mensagem_log := '"Unidade Comercial" não está cadastrada ('||trim(est_row_Item_Nota_Fiscal.unid_com)||').';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
     vn_fase := 34.4;
     -- valida unidade tributavel
     vn_unidade_id_trib := pk_csf.fkg_Unidade_id(en_multorg_id => en_multorg_id
                                                ,ev_sigla_unid => trim(est_row_Item_Nota_Fiscal.unid_trib));
     --
     vn_fase := 34.5;
     --
     if nvl(vn_unidade_id_trib, 0) <= 0 then
        --
        vn_fase := 34.6;
        --
        gv_mensagem_log := '"Unidade tributável" não está cadastrada ('||trim(est_row_Item_Nota_Fiscal.unid_trib)||').';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 35;
  --
  if nvl(est_row_Item_Nota_Fiscal.vl_outro, 0) < 0 then
     --
     vn_fase := 35.1;
     --
     gv_mensagem_log := '"Outras despesas acessórias" não pode ser negativa.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 36;
  --
  if nvl(est_row_Item_Nota_Fiscal.dm_ind_tot, 0) not in (0, 1) then
     --
     vn_fase := 36.1;
     --
     gv_mensagem_log := '"Indicador se valor do Item entra no valor total da NF-e" informado está inválido ('||est_row_Item_Nota_Fiscal.dm_ind_tot||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 37;
  --
  if nvl(est_row_Item_Nota_Fiscal.dm_mot_des_icms, 0) > 0 and
     est_row_Item_Nota_Fiscal.dm_mot_des_icms not in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 16, 90) then
     --
     vn_fase := 37.1;
     --
     gv_mensagem_log := '"Motivo da desonerado do ICMS" informado está inválido ('||est_row_Item_Nota_Fiscal.dm_mot_des_icms||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 38;
  -- Valor Aproximado dos Tributos
  if nvl(est_row_Item_Nota_Fiscal.vl_tot_trib_item, 0) < 0 then
     --
     vn_fase := 38.1;
     --
     gv_mensagem_log := '"Valor Aproximado dos Tributos" não pode ser negativo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 39;
  --
  if est_row_Item_Nota_Fiscal.vl_tot_trib_item = 0 then
     est_row_Item_Nota_Fiscal.vl_tot_trib_item := null;
  end if;
  --
  vn_fase := 40;
  -- Se informado motDesICMS = 7 CFOP não for 6109 ou 6110, limpa a desonerado
  if nvl(est_row_Item_Nota_Fiscal.dm_mot_des_icms, 0) = 7 and
     est_row_Item_Nota_Fiscal.cfop not in (6109, 6110) then
     --
     est_row_Item_Nota_Fiscal.dm_mot_des_icms := null;
     --
  end if;
  --
  vn_fase := 41;
  --
  if est_row_Item_Nota_Fiscal.dm_cod_trib_issqn is not null and
     est_row_Item_Nota_Fiscal.dm_cod_trib_issqn not in ('N', 'R', 'S', 'I') then
     --
     vn_fase := 41.1;
     --
     gv_mensagem_log := '"Código de tributacao do ISSQN" informado está inválido ('||est_row_Item_Nota_Fiscal.dm_cod_trib_issqn||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 42;
  --
  if nvl(est_row_Item_Nota_Fiscal.item_id, 0) <= 0 then
     --
     vn_fase := 42.1;
     --
     vn_empresa_id := pk_csf.fkg_empresa_notafiscal(en_notafiscal_id => est_row_Item_Nota_Fiscal.notafiscal_id);
     -- verifica se a empresa integra o item, quando não existir no cadastro
     vn_dm_integr_item := pk_csf.fkg_integritem_conf_empresa(en_empresa_id => vn_empresa_id);
     --
     vn_fase := 4.2;
     --
     if nvl(vn_dm_integr_item, 0) = 1 then
        -- ira integrar o item
        vn_fase := 42.3;
        --
        vn_unidade_id_com := pk_csf.fkg_Unidade_id(en_multorg_id => en_multorg_id
                                                  ,ev_sigla_unid => trim(est_row_Item_Nota_Fiscal.unid_com));
        --
        vn_fase := 42.4;
        if nvl(vn_unidade_id_com, 0) <= 0 then
           --
           vn_fase := 42.5;
           --
           pk_csf_api_cad.gt_row_unidade := null;
           --
           pk_csf_api_cad.gt_row_unidade.SIGLA_UNID := trim(est_row_Item_Nota_Fiscal.unid_com);
           pk_csf_api_cad.gt_row_unidade.DESCR      := 'Unidade: ' || trim(est_row_Item_Nota_Fiscal.unid_com);
           pk_csf_api_cad.gt_row_unidade.MULTORG_ID := en_multorg_id;
           pk_csf_api_cad.gt_row_unidade.DM_ST_PROC := 0;
           --
           pk_csf_api_cad.pkb_integr_unid_med(est_log_generico => est_log_generico_nf
                                             ,est_unidade      => pk_csf_api_cad.gt_row_unidade
                                             , en_empresa_id   => gt_row_nota_fiscal.empresa_id
                                             );
           --
        end if;
        --
        vn_fase := 42.6;
        --
        pk_csf_api_cad.gt_row_item              := null;
        pk_csf_api_cad.gt_row_item.cod_item     := trim(upper(est_row_Item_Nota_Fiscal.cod_item));
        pk_csf_api_cad.gt_row_item.descr_item   := est_row_Item_Nota_Fiscal.descr_item;
        pk_csf_api_cad.gt_row_item.dm_orig_merc := est_row_Item_Nota_Fiscal.orig;
        pk_csf_api_cad.gt_row_item.cod_barra    := est_row_Item_Nota_Fiscal.cean;
        pk_csf_api_cad.gt_row_item.cod_ant_item := null;
        pk_csf_api_cad.gt_row_item.aliq_icms    := 0;
        --
        vn_fase := 42.7;
        --
        pk_csf_api_cad.pkb_integr_item(est_log_generico => est_log_generico_nf
                                      ,est_item         => pk_csf_api_cad.gt_row_item
                                      ,en_multorg_id    => pk_csf.fkg_multorg_id_empresa(en_empresa_id => vn_empresa_id)
                                      ,ev_cpf_cnpj      => pk_csf.fkg_cnpj_ou_cpf_empresa(en_empresa_id => pk_csf.fkg_empresa_id_matriz(en_empresa_id => vn_empresa_id))
                                      ,ev_sigla_unid    => est_row_Item_Nota_Fiscal.unid_com
                                      ,ev_tipo_item     => '00'
                                      ,ev_cod_ncm       => est_row_Item_Nota_Fiscal.cod_ncm
                                      ,ev_cod_ex_tipi   => null
                                      ,ev_tipo_servico  => null
                                      , ev_cest_cd      => null
                                      );
        --
        vn_fase := 42.8;
        --
        if nvl(pk_csf_api_cad.gt_row_item.id, 0) > 0 and pk_csf.fkg_item_id_valido(en_item_id => pk_csf_api_cad.gt_row_item.id) = false then
           est_row_Item_Nota_Fiscal.item_id := null;
        else
           est_row_Item_Nota_Fiscal.item_id := pk_csf_api_cad.gt_row_item.id;
        end if;
        --
     end if;
     --
  end if;
  --
  vn_fase := 43;
  --
  begin
     select cl.id
       into vn_id_codclass
       from class_cons_item_cont cl
      where cl.cod_class = trim(ev_cod_class);
  exception
     when others then
        vn_id_codclass := null;
  end;
  --
  vn_fase := 44;
  --
  if pk_csf.fkg_cod_mod_id(en_modfiscal_id => pk_csf.fkg_recup_modfisc_id_nf(en_notafiscal_id => est_row_item_nota_fiscal.notafiscal_id)) in ('21','22')
     and gt_row_nota_fiscal.dm_ind_oper = 1
     and vn_id_codclass                 is null then
     --
     vn_fase := 44.1;
     --
     gv_mensagem_log := '"Código da Classificação do Consumo de Mercadoria/Serviço de Fornecimento Contínuo", deve ser informado e validado ('||ev_cod_class||
                        '), devido aos modelos de Notas "21-Nota Fiscal de Serviço de Comunicação", e "22-Nota Fiscal de Serviço de Telecomunicação".';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 45;
  -- Se não existe registro de Log e o Tipo de Integracao  1 (valida e integra)
  -- entao registra a informação do Item da Nota Fiscal
  if nvl(est_log_generico_nf.count, 0) > 0 and 
     fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => est_row_Item_Nota_Fiscal.notafiscal_id ) = 1 then
     --
     vn_fase := 45.1;
     --
     update nota_fiscal
        set dm_st_proc = 10
      where id = est_row_Item_Nota_Fiscal.notafiscal_id;
     --
  end if;
  --
  --Validando campo DM_IND_REC
  if est_row_Item_Nota_Fiscal.dm_ind_rec is not null
     and est_row_Item_Nota_Fiscal.dm_ind_rec not in(0, 1) then
     --
     gv_mensagem_log := 'Indicador do tipo de receita, contem valores inválidos. Valor informado: '
                     ||est_row_Item_Nota_Fiscal.dm_ind_rec||'. Valores validos (0,1).';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 45.2;
  --
  --Validando campo DM_IND_REC_COM
  if est_row_Item_Nota_Fiscal.dm_ind_rec_com is not null
     and est_row_Item_Nota_Fiscal.dm_ind_rec_com not in(0, 1, 2, 3, 4, 5, 9) then
     --
     gv_mensagem_log := 'Indicador do tipo de receita de comunicação/telecomunicação, contem valores inválidos. Valor informado: '
                     ||est_row_Item_Nota_Fiscal.dm_ind_rec_com||'. Valores validos (0,1,2,3,4,5,9).';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 46;
  --
  est_row_Item_Nota_Fiscal.cod_item       := trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.cod_item));
  est_row_Item_Nota_Fiscal.cean           := trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.cean));
  est_row_Item_Nota_Fiscal.descr_item     := trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.descr_item));
  est_row_Item_Nota_Fiscal.cod_ncm        := trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.cod_ncm));
  est_row_Item_Nota_Fiscal.genero         := trim(est_row_Item_Nota_Fiscal.genero);
  est_row_Item_Nota_Fiscal.cod_ext_ipi    := trim(est_row_Item_Nota_Fiscal.cod_ext_ipi);
  est_row_Item_Nota_Fiscal.Unid_Com       := trim(est_row_Item_Nota_Fiscal.Unid_Com);
  est_row_Item_Nota_Fiscal.qtde_Comerc    := nvl(est_row_Item_Nota_Fiscal.qtde_Comerc,0);
  est_row_Item_Nota_Fiscal.vl_Unit_Comerc := nvl(est_row_Item_Nota_Fiscal.vl_Unit_Comerc,0);
  est_row_Item_Nota_Fiscal.vl_Item_Bruto  := nvl(est_row_Item_Nota_Fiscal.vl_Item_Bruto,0);
  est_row_Item_Nota_Fiscal.cean_Trib      := trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.cean_Trib));
  est_row_Item_Nota_Fiscal.Unid_Trib      := trim(est_row_Item_Nota_Fiscal.Unid_Trib);
  est_row_Item_Nota_Fiscal.qtde_Trib      := nvl(est_row_Item_Nota_Fiscal.qtde_Trib,0);
  est_row_Item_Nota_Fiscal.vl_Unit_Trib   := nvl(est_row_Item_Nota_Fiscal.vl_Unit_Trib,0);
  est_row_Item_Nota_Fiscal.vl_Frete       := nvl(est_row_Item_Nota_Fiscal.vl_Frete,0);
  est_row_Item_Nota_Fiscal.vl_Seguro      := nvl(est_row_Item_Nota_Fiscal.vl_Seguro,0);
  est_row_Item_Nota_Fiscal.vl_Desc        := nvl(est_row_Item_Nota_Fiscal.vl_Desc,0);
  --
  est_row_Item_Nota_Fiscal.infAdProd := trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.infAdProd));
  --
  est_row_Item_Nota_Fiscal.dm_mod_base_calc := nvl(est_row_Item_Nota_Fiscal.dm_mod_base_calc,0);
  est_row_Item_Nota_Fiscal.cnpj_produtor    := lpad(trim(est_row_Item_Nota_Fiscal.cnpj_produtor),14,'0');
  est_row_Item_Nota_Fiscal.cl_enq_ipi       := trim(est_row_Item_Nota_Fiscal.cl_enq_ipi);
  est_row_Item_Nota_Fiscal.cod_selo_ipi     := trim(est_row_Item_Nota_Fiscal.cod_selo_ipi);
  est_row_Item_Nota_Fiscal.cod_enq_ipi      := trim(est_row_Item_Nota_Fiscal.cod_enq_ipi);
  est_row_Item_Nota_Fiscal.cd_lista_serv    := trim(est_row_Item_Nota_Fiscal.cd_lista_serv);
  est_row_Item_Nota_Fiscal.cod_cta          := trim(est_row_Item_Nota_Fiscal.cod_cta);
  est_row_Item_Nota_Fiscal.dm_ind_tot       := nvl(est_row_Item_Nota_Fiscal.dm_ind_tot,1);
  est_row_Item_Nota_Fiscal.pedido_compra    := trim(pk_csf.fkg_converte(replace(replace(est_row_Item_Nota_Fiscal.pedido_compra,'/',''),'\',''), 0, 1, 2, 1, 1));
  est_row_Item_Nota_Fiscal.item_pedido_compra := trim(pk_csf.fkg_converte(replace(replace(est_row_Item_Nota_Fiscal.item_pedido_compra,'/',''),'\',''), 0, 1, 2, 1, 1));
  est_row_Item_Nota_Fiscal.cfop             := nvl(est_row_Item_Nota_Fiscal.cfop,0);
  --
  est_row_Item_Nota_Fiscal.dm_ind_mov := 0;
  est_row_Item_Nota_Fiscal.dm_ind_tot := 0;
  --
  vn_fase := 47;
  --
  if nvl(est_row_Item_Nota_Fiscal.notafiscal_id, 0) > 0 and
     nvl(est_row_Item_Nota_Fiscal.nro_item, 0) > 0 and
     trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.cod_item)) is not null and
     est_row_Item_Nota_Fiscal.dm_ind_mov in (0, 1) and
     trim(pk_csf.fkg_converte(est_row_Item_Nota_Fiscal.descr_item)) is not null and
     nvl(est_row_Item_Nota_Fiscal.cfop_id, 0) > 0
     and nvl(est_row_Item_Nota_Fiscal.dm_ind_tot, 0) in (0, 1) then
     --
     vn_fase := 48;
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 49;
        --
        select itemnf_seq.nextval
          into est_row_Item_Nota_Fiscal.id
          from dual;
        --
        vn_fase := 50;
        --
        insert into Item_Nota_Fiscal
           (id
           ,notafiscal_id
           ,item_id
           ,nro_item
           ,cod_item
           ,dm_ind_mov
           ,cean
           ,descr_item
           ,cod_ncm
           ,genero
           ,cod_ext_ipi
           ,cfop_id
           ,cfop
           ,Unid_Com
           ,qtde_Comerc
           ,vl_Unit_Comerc
           ,vl_Item_Bruto
           ,cean_Trib
           ,Unid_Trib
           ,qtde_Trib
           ,vl_Unit_Trib
           ,vl_Frete
           ,vl_Seguro
           ,vl_Desc
           ,infAdProd
           ,orig
           ,dm_mod_base_calc
           ,dm_mod_base_calc_st
           ,cnpj_produtor
           ,qtde_selo_ipi
           ,vl_desp_adu
           ,vl_iof
           ,classenqipi_id
           ,cl_enq_ipi
           ,selocontripi_id
           ,cod_selo_ipi
           ,cod_enq_ipi
           ,cidade_ibge
           ,cd_lista_serv
           ,dm_ind_apur_ipi
           ,cod_cta
           ,classconsitemcont_id
           ,vl_outro
           ,dm_ind_tot
           ,pedido_compra
           ,item_pedido_compra
           ,dm_mot_des_icms
           ,dm_cod_trib_issqn
           ,vl_tot_trib_item
           ,dm_ind_rec
           ,dm_ind_rec_com)
        values
           (est_row_Item_Nota_Fiscal.id
           ,est_row_Item_Nota_Fiscal.notafiscal_id
           ,est_row_Item_Nota_Fiscal.item_id
           ,est_row_Item_Nota_Fiscal.nro_item
           ,est_row_Item_Nota_Fiscal.cod_item
           ,est_row_Item_Nota_Fiscal.dm_ind_mov
           ,est_row_Item_Nota_Fiscal.cean
           ,est_row_Item_Nota_Fiscal.descr_item
           ,est_row_Item_Nota_Fiscal.cod_ncm
           ,est_row_Item_Nota_Fiscal.genero
           ,est_row_Item_Nota_Fiscal.cod_ext_ipi
           ,est_row_Item_Nota_Fiscal.cfop_id
           ,est_row_Item_Nota_Fiscal.cfop
           ,est_row_Item_Nota_Fiscal.Unid_Com
           ,est_row_Item_Nota_Fiscal.qtde_Comerc
           ,est_row_Item_Nota_Fiscal.vl_Unit_Comerc
           ,est_row_Item_Nota_Fiscal.vl_Item_Bruto
           ,est_row_Item_Nota_Fiscal.cean_Trib
           ,est_row_Item_Nota_Fiscal.Unid_Trib
           ,est_row_Item_Nota_Fiscal.qtde_Trib
           ,est_row_Item_Nota_Fiscal.vl_Unit_Trib
           ,est_row_Item_Nota_Fiscal.vl_Frete
           ,est_row_Item_Nota_Fiscal.vl_Seguro
           ,est_row_Item_Nota_Fiscal.vl_Desc
           ,est_row_Item_Nota_Fiscal.infAdProd
           ,est_row_Item_Nota_Fiscal.orig
           ,est_row_Item_Nota_Fiscal.dm_mod_base_calc
           ,est_row_Item_Nota_Fiscal.dm_mod_base_calc_st
           ,est_row_Item_Nota_Fiscal.cnpj_produtor
           ,est_row_Item_Nota_Fiscal.qtde_selo_ipi
           ,est_row_Item_Nota_Fiscal.vl_desp_adu
           ,est_row_Item_Nota_Fiscal.vl_iof
           ,est_row_Item_Nota_Fiscal.classenqipi_id
           ,est_row_Item_Nota_Fiscal.cl_enq_ipi
           ,est_row_Item_Nota_Fiscal.selocontripi_id
           ,est_row_Item_Nota_Fiscal.cod_selo_ipi
           ,est_row_Item_Nota_Fiscal.cod_enq_ipi
           ,est_row_Item_Nota_Fiscal.cidade_ibge
           ,est_row_Item_Nota_Fiscal.cd_lista_serv
           ,est_row_Item_Nota_Fiscal.dm_ind_apur_ipi
           ,est_row_Item_Nota_Fiscal.cod_cta
           ,vn_id_codClass
           ,est_row_Item_Nota_Fiscal.vl_outro
           ,est_row_Item_Nota_Fiscal.dm_ind_tot
           ,est_row_Item_Nota_Fiscal.pedido_compra
           ,est_row_Item_Nota_Fiscal.item_pedido_compra
           ,est_row_Item_Nota_Fiscal.dm_mot_des_icms
           ,est_row_Item_Nota_Fiscal.dm_cod_trib_issqn
           ,est_row_Item_Nota_Fiscal.VL_TOT_TRIB_ITEM
           ,est_row_Item_Nota_Fiscal.dm_ind_rec
           ,est_row_Item_Nota_Fiscal.dm_ind_rec_com);
        --
     else
        --
        vn_fase := 51;
        --
        update Item_Nota_Fiscal
           set item_id             = est_row_Item_Nota_Fiscal.item_id
              ,nro_item            = est_row_Item_Nota_Fiscal.nro_item
              ,cod_item            = est_row_Item_Nota_Fiscal.cod_item
              ,dm_ind_mov          = est_row_Item_Nota_Fiscal.dm_ind_mov
              ,cean                = est_row_Item_Nota_Fiscal.cean
              ,descr_item          = est_row_Item_Nota_Fiscal.descr_item
              ,cod_ncm             = est_row_Item_Nota_Fiscal.cod_ncm
              ,genero              = est_row_Item_Nota_Fiscal.genero
              ,cod_ext_ipi         = est_row_Item_Nota_Fiscal.cod_ext_ipi
              ,cfop_id             = est_row_Item_Nota_Fiscal.cfop_id
              ,cfop                = est_row_Item_Nota_Fiscal.cfop
              ,Unid_Com            = est_row_Item_Nota_Fiscal.Unid_Com
              ,qtde_Comerc         = est_row_Item_Nota_Fiscal.qtde_Comerc
              ,vl_Unit_Comerc      = est_row_Item_Nota_Fiscal.vl_Unit_Comerc
              ,vl_Item_Bruto       = est_row_Item_Nota_Fiscal.vl_Item_Bruto
              ,cean_Trib           = est_row_Item_Nota_Fiscal.cean_Trib
              ,Unid_Trib           = est_row_Item_Nota_Fiscal.Unid_Trib
              ,qtde_Trib           = est_row_Item_Nota_Fiscal.qtde_Trib
              ,vl_Unit_Trib        = est_row_Item_Nota_Fiscal.vl_Unit_Trib
              ,vl_Frete            = est_row_Item_Nota_Fiscal.vl_Frete
              ,vl_Seguro           = est_row_Item_Nota_Fiscal.vl_Seguro
              ,vl_Desc             = est_row_Item_Nota_Fiscal.vl_Desc
              ,infAdProd           = est_row_Item_Nota_Fiscal.infAdProd
              ,orig                = est_row_Item_Nota_Fiscal.orig
              ,dm_mod_base_calc    = est_row_Item_Nota_Fiscal.dm_mod_base_calc
              ,dm_mod_base_calc_st = est_row_Item_Nota_Fiscal.dm_mod_base_calc_st
              ,cnpj_produtor       = est_row_Item_Nota_Fiscal.cnpj_produtor
              ,qtde_selo_ipi       = est_row_Item_Nota_Fiscal.qtde_selo_ipi
              ,vl_desp_adu         = est_row_Item_Nota_Fiscal.vl_desp_adu
              ,vl_iof              = est_row_Item_Nota_Fiscal.vl_iof
              ,classenqipi_id      = est_row_Item_Nota_Fiscal.classenqipi_id
              ,cl_enq_ipi          = est_row_Item_Nota_Fiscal.cl_enq_ipi
              ,selocontripi_id     = est_row_Item_Nota_Fiscal.selocontripi_id
              ,cod_selo_ipi        = est_row_Item_Nota_Fiscal.cod_selo_ipi
              ,cod_enq_ipi         = est_row_Item_Nota_Fiscal.cod_enq_ipi
              ,cidade_ibge         = est_row_Item_Nota_Fiscal.cidade_ibge
              ,cd_lista_serv       = est_row_Item_Nota_Fiscal.cd_lista_serv
              ,dm_ind_apur_ipi     = est_row_Item_Nota_Fiscal.dm_ind_apur_ipi
              ,cod_cta             = est_row_Item_Nota_Fiscal.cod_cta
              ,vl_outro            = est_row_Item_Nota_Fiscal.vl_outro
              ,dm_ind_tot          = est_row_Item_Nota_Fiscal.dm_ind_tot
              ,pedido_compra       = est_row_Item_Nota_Fiscal.pedido_compra
              ,item_pedido_compra  = est_row_Item_Nota_Fiscal.item_pedido_compra
              ,dm_mot_des_icms     = est_row_Item_Nota_Fiscal.dm_mot_des_icms
              ,dm_cod_trib_issqn   = est_row_Item_Nota_Fiscal.dm_cod_trib_issqn
              ,VL_TOT_TRIB_ITEM    = est_row_Item_Nota_Fiscal.VL_TOT_TRIB_ITEM
              ,dm_ind_rec          = est_row_Item_Nota_Fiscal.dm_ind_rec
              ,dm_ind_rec_com      = est_row_Item_Nota_Fiscal.dm_ind_rec_com
         where id = est_row_Item_Nota_Fiscal.id;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_Item_Nota_Fiscal fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_ITEM_NOTA_FISCAL;

----------------------------------------------------
-- Integra informações da cobranca da Nota Fiscal --
----------------------------------------------------
PROCEDURE PKB_INTEGR_NOTA_FISCAL_COBR(EST_LOG_GENERICO_NF      IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                    ,EST_ROW_NOTA_FISCAL_COBR IN OUT NOCOPY NOTA_FISCAL_COBR%ROWTYPE) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(est_row_Nota_Fiscal_Cobr.notafiscal_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 1.1;
     --
     gv_mensagem_log := 'Não informada a Nota Fiscal para relacionar aos Dados da Cobrança.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  vn_fase := 2;
  -- Valida o emitente do título
  if est_row_Nota_Fiscal_Cobr.dm_ind_emit not in (0, 1) then
     --
     vn_fase := 2.1;
     --
     gv_mensagem_log := '"Indicador do emitente de Dados da Cobrança da Nota Fiscal" ('||est_row_Nota_Fiscal_Cobr.dm_ind_emit||') está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  vn_fase := 3;
  -- Valida o tipo de título
  if est_row_Nota_Fiscal_Cobr.dm_ind_tit not in ('00', '01', '02', '03', '99') then
     --
     vn_fase := 3.1;
     --
     gv_mensagem_log := '"Tipo de título de Dados da Cobrança da Nota Fiscal" ('||est_row_Nota_Fiscal_Cobr.dm_ind_tit||') está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 4;
  --
  -- Valida informações do Valor Original da Fatura
  if nvl(est_row_Nota_Fiscal_Cobr.vl_orig, 0) < 0 then
     --
     vn_fase := 4.1;
     --
     gv_mensagem_log := '"Valor Original da Fatura da Cobrança da Nota Fiscal" não pode ser negativo ('||est_row_Nota_Fiscal_Cobr.vl_orig||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  else
     -- se for zero ocorre erro de XML
     vn_fase := 4.2;
     --
     if est_row_Nota_Fiscal_Cobr.vl_orig = 0 then
        est_row_Nota_Fiscal_Cobr.vl_orig := null;
     end if;
     --
  end if;
  --
  vn_fase := 5;
  --
  -- Valida informações do Valor do Desconto da Fatura
  if nvl(est_row_Nota_Fiscal_Cobr.vl_desc, 0) < 0 then
     --
     vn_fase := 5.1;
     --
     gv_mensagem_log := '"Valor do Desconto da Fatura da Cobrança da Nota Fiscal" não pode ser negativo ('||est_row_Nota_Fiscal_Cobr.vl_desc||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  else
     -- se for zero ocorre erro de XML
     vn_fase := 5.2;
     if est_row_Nota_Fiscal_Cobr.vl_desc = 0 then
        --
        est_row_Nota_Fiscal_Cobr.vl_desc := null;
        --
     end if;
     --
  end if;
  --
  vn_fase := 6;
  --
  -- Valida informações do Valor Líquido da Fatura
  if nvl(est_row_Nota_Fiscal_Cobr.vl_liq, 0) < 0 then
     --
     vn_fase := 6.1;
     --
     gv_mensagem_log := '"Valor Líquido da Fatura da Cobrança da Nota Fiscal" não pode ser negativo ('||est_row_Nota_Fiscal_Cobr.vl_liq||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  else
     -- se for zero ocorre erro de XML
     vn_fase := 6.2;
     --
     if est_row_Nota_Fiscal_Cobr.vl_liq = 0 then
        est_row_Nota_Fiscal_Cobr.vl_liq := null;
     end if;
     --
  end if;
  --
  vn_fase := 7;
  --
  if trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Cobr.descr_tit)) is null and
     est_row_Nota_Fiscal_Cobr.dm_ind_tit = '99' then
     --
     vn_fase := 7.1;
     --
     gv_mensagem_log := '"Descrição complementar do título de crédito" torna-se obrigatória quando o Tipo de Título é igual a 99-Outros.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 8;
  --
  -- Se não existe registro de Log e o Tipo de Integracao  1 (valida e insere)
  -- entao registra a informação da Fatura da Nota Fiscal
  if nvl(est_log_generico_nf.count, 0) > 0 and 
     fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => est_row_Nota_Fiscal_Cobr.notafiscal_id ) = 1 then
     --
     vn_fase := 9;
     --
     update nota_fiscal
        set dm_st_proc = 10
      where id = est_row_Nota_Fiscal_Cobr.notafiscal_id;
     --
  end if;
  --
  vn_fase := 10;
  --
  est_row_Nota_Fiscal_Cobr.nro_fat   := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Cobr.nro_fat));
  est_row_Nota_Fiscal_Cobr.descr_tit := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Cobr.descr_tit));
  est_row_Nota_Fiscal_Cobr.vl_orig   := nvl(est_row_Nota_Fiscal_Cobr.vl_orig
                                           ,0);
  est_row_Nota_Fiscal_Cobr.vl_liq    := nvl(est_row_Nota_Fiscal_Cobr.vl_liq
                                           ,0);
  --
  vn_fase := 11;
  --
  if nvl(est_row_Nota_Fiscal_Cobr.notafiscal_id, 0) > 0 and
     est_row_Nota_Fiscal_Cobr.dm_ind_emit in (0, 1) and
     est_row_Nota_Fiscal_Cobr.dm_ind_tit is not null and
     est_row_Nota_Fiscal_Cobr.nro_fat is not null then
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 12;
        --
        select nfcobr_seq.nextval
          into est_row_Nota_Fiscal_Cobr.id
          from dual;
        --
        vn_fase := 13;
        --
        insert into Nota_Fiscal_Cobr
           (id
           ,notafiscal_id
           ,dm_ind_emit
           ,dm_ind_tit
           ,nro_fat
           ,vl_orig
           ,vl_desc
           ,vl_liq
           ,descr_tit)
        values
           (est_row_Nota_Fiscal_Cobr.id
           ,est_row_Nota_Fiscal_Cobr.notafiscal_id
           ,est_row_Nota_Fiscal_Cobr.dm_ind_emit
           ,est_row_Nota_Fiscal_Cobr.dm_ind_tit
           ,trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Cobr.nro_fat))
           ,est_row_Nota_Fiscal_Cobr.vl_orig
           ,est_row_Nota_Fiscal_Cobr.vl_desc
           ,est_row_Nota_Fiscal_Cobr.vl_liq
           ,trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Cobr.descr_tit)));
        --
     else
        --
        vn_fase := 14;
        --
        update Nota_Fiscal_Cobr
           set dm_ind_emit = est_row_Nota_Fiscal_Cobr.dm_ind_emit
              ,dm_ind_tit  = est_row_Nota_Fiscal_Cobr.dm_ind_tit
              ,nro_fat     = est_row_Nota_Fiscal_Cobr.nro_fat
              ,vl_orig     = est_row_Nota_Fiscal_Cobr.vl_orig
              ,vl_desc     = est_row_Nota_Fiscal_Cobr.vl_desc
              ,vl_liq      = est_row_Nota_Fiscal_Cobr.vl_liq
              ,descr_tit   = est_row_Nota_Fiscal_Cobr.descr_tit
         where id = est_row_Nota_Fiscal_Cobr.id;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal_Cobr fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NOTA_FISCAL_COBR;

---------------------------------------------------------------------------------------------------------------------------------------
-- Integra as informações do Destinatário da Nota Fiscal                                                                             --
-- A API de Integracao do Destinatário da NFe, irá¡ verificar se houve algum erro de Integracao com os dados informados               --
-- do Destinatário, caso exista erro, verifica se a empresa "Utiliza o Endereço de Faturamento do Destinatário para Emissao de NFe", --
-- se utiliza, o endereco errado sera¡ substituido pelo registrado no Compliance NFe (Cadastro de Pessoas)                            --
---------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE PKB_INTEGR_NOTA_FISCAL_DEST(EST_LOG_GENERICO_NF      IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                    ,EST_ROW_NOTA_FISCAL_DEST IN OUT NOCOPY NOTA_FISCAL_DEST%ROWTYPE
                                    ,EV_COD_PART              IN PESSOA.COD_PART%TYPE
                                    ,EN_MULTORG_ID            IN MULT_ORG.ID%TYPE) IS
  --
  vn_fase                number := 0;
  vn_loggenerico_id      log_generico_nf.id%type;
  vn_dm_util_end_fat_nfe empresa.dm_util_end_fat_nfe%type := 0;
  vn_indice              number := 0;
  vn_pessoa_id           Pessoa.id%type;
  vt_log_generico_nf     dbms_sql.number_table;
  vn_atualiza_erro       number := 1; -- 0-não; 1-Sim
  vb_integr_edi          boolean := false;
  vv_email_usuario       neo_usuario.email%type := null;
  vv_cod_mod             mod_fiscal.cod_mod%type;
  vv_cnpj                nota_fiscal_dest.cnpj%type;
  vv_cpf                 nota_fiscal_dest.cpf%type;
  vv_ie                  nota_fiscal_dest.ie%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  vt_log_generico_nf.delete;
  --
  vn_fase := 1.1;
  --
  vv_cod_mod := pk_csf.fkg_cod_mod_id(en_modfiscal_id => gt_row_nota_fiscal.modfiscal_id);
  --
  -- Verifica se a nota fiscal não foi informada
  if nvl(est_row_Nota_Fiscal_Dest.notafiscal_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 1.2;
     --
     gv_mensagem_log := 'Não informado a Nota Fiscal para relacionar ao Destinatário.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 2;
  --
  -- Valida se o campo nome tem menos que 2 caracteres
  if nvl(length(trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.nome))),0) < 2 and 
     vv_cod_mod <> '65' then
     --
     vn_fase := 2.1;
     --
     gv_mensagem_log := '"Nome do Destinatário da Nota Fiscal" deve ter no mínimo dois caracteres ('||est_row_Nota_Fiscal_Dest.nome||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  vn_fase := 3;
  -- Valida informação do número do endereço do emitente
  if trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.nro)) is null and
     vv_cod_mod <> '65' then
     --
     vn_fase := 3.1;
     --
     gv_mensagem_log := '"Número do endereço" Destinatário da Nota Fiscal não informado.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  vn_fase := 4;
  -- Valida se o campo logradouro tem menos que 2 caracteres
  if nvl(length(trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.lograd))),0) < 2 and 
     vv_cod_mod <> '65' and
     pk_csf_api.gt_row_Nota_Fiscal.dm_ind_emit = 0 then -- Emissao Propria
     --
     vn_fase := 4.1;
     --
     gv_mensagem_log := '"Logradouro do Destinatário da Nota Fiscal" deve ter no mínimo dois caracteres ('||est_row_Nota_Fiscal_Dest.lograd||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  vn_fase := 5;
  -- Valida se o campo bairro tem menos que 2 caracteres
  if nvl(length(trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.bairro))),0) < 2 and vv_cod_mod <> '65' and
     pk_csf_api.gt_row_Nota_Fiscal.dm_ind_emit = 0 then -- Emissao Propria
     --
     vn_fase := 5.1;
     --
     gv_mensagem_log := '"Bairro do Destinatário da Nota Fiscal" deve ter no mínimo dois caracteres ('||est_row_Nota_Fiscal_Dest.bairro||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  vn_fase := 6;
  -- Valida se o campo cidade tem menos que 2 caracteres
  if nvl(length(trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.cidade))),0) < 2 and 
     vv_cod_mod <> '65' and
     pk_csf_api.gt_row_Nota_Fiscal.dm_ind_emit = 0 then -- Emissao Propria
     --
     vn_fase := 6.1;
     --
     gv_mensagem_log := '"Cidade do Destinatário da Nota Fiscal" deve ter no mínimo dois caracteres ('||est_row_Nota_Fiscal_Dest.cidade||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 7;
  --
  if est_row_Nota_Fiscal_Dest.uf is null and vv_cod_mod <> '65' then
     --
     gv_mensagem_log := '"Sigla da UF do Destinatário da Nota Fiscal" é obrigatória.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  if est_row_Nota_Fiscal_Dest.uf is not null then
     -- verifica se a UF é inválida
     if pk_csf.fkg_uf_valida(ev_sigla_estado => est_row_Nota_Fiscal_Dest.uf) = false then
        --
        vn_fase := 7.1;
        --
        gv_mensagem_log := '"Sigla da UF do Destinatário da Nota Fiscal" inválida ('||est_row_Nota_Fiscal_Dest.uf||').';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => vt_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 8;
  -- Se o campo UF = 'EX' atribui Exterior para cidade
  if est_row_Nota_Fiscal_Dest.uf = 'EX' then
     --
     vn_fase := 8.1;
     --
     est_row_Nota_Fiscal_Dest.cidade      := 'EXTERIOR';
     est_row_Nota_Fiscal_Dest.cidade_ibge := 9999999;
     --
  end if;
  vn_fase := 9;
  -- Valida o campo cidade_ibge
  if nvl(est_row_Nota_Fiscal_Dest.cidade_ibge, 0) <> 9999999 and
     est_row_Nota_Fiscal_Dest.cidade_ibge is not null then
     --
     vn_fase := 9.1;
     --
     if pk_csf.fkg_ibge_cidade(ev_ibge_cidade => est_row_Nota_Fiscal_Dest.cidade_ibge) = false then
        --
        vn_fase := 9.2;
        --
        gv_mensagem_log := '"Código IBGE da cidade do Destinatário da Nota Fiscal" inválido ('||est_row_Nota_Fiscal_Dest.cidade_ibge||').';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => vt_log_generico_nf);
        --
     end if;
     --
     vn_fase := 9.3;
     -- Valida se o IBGE da cidade pertence a sigla da UF
     if pk_csf.fkg_ibge_cidade_por_sigla_uf(en_ibge_cidade  => est_row_Nota_Fiscal_Dest.cidade_ibge
                                           ,ev_sigla_estado => est_row_Nota_Fiscal_Dest.uf) = false then
        --
        vn_fase := 9.4;
        --
        gv_mensagem_log := '"Código IBGE da cidade do Destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.cidade_ibge||
                           ') não pertence a sigla do estado ('||est_row_Nota_Fiscal_Dest.uf||').';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => vt_log_generico_nf);
        --
     end if;
     --
     vn_fase := 9.5;
     --
     if trim(est_row_Nota_Fiscal_Dest.cidade) is null and
        est_row_Nota_Fiscal_Dest.cidade_ibge is not null then
        -- Busca o nome da cidade conforme IBGE
        est_row_Nota_Fiscal_Dest.cidade := pk_csf.fkg_descr_cidade_conf_ibge(ev_ibge_cidade => est_row_Nota_Fiscal_Dest.cidade_ibge);
        --
     end if;
     --
     if trim(est_row_Nota_Fiscal_Dest.cidade) is null and
        vv_cod_mod <> '65' then
        est_row_Nota_Fiscal_Dest.cidade := 'NI';
     end if;
     --
  end if;
  --
  vn_fase := 9.6;
  --
  if trim(est_row_Nota_Fiscal_Dest.uf) <> 'EX' and
     est_row_Nota_Fiscal_Dest.cidade_ibge = 9999999 then
     --
     gv_mensagem_log := 'Código IBGE do município do Destinatário 9999999 não pertence ao estado '||trim(est_row_Nota_Fiscal_Dest.uf)||'.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 10;
  -- Se o Código do país for nulo, atribui 1058-Brasil
  if nvl(est_row_Nota_Fiscal_Dest.cod_pais, 0) <= 0 then
     --
     est_row_Nota_Fiscal_Dest.cod_pais := 1058;
     --
  end if;
  --
  vn_fase := 10.1;
  --
  if est_row_Nota_Fiscal_Dest.cod_pais = 1058 and
     est_row_Nota_Fiscal_Dest.uf = 'EX' and
     pk_csf_api.gt_row_Nota_Fiscal.dm_ind_emit = 0 then -- somente Emissao propria
     --
     gv_mensagem_log := '"Código do país do Destinatário da Nota Fiscal 1058 - Brasil" e sigla do estado estão inválidas ('||
                        est_row_Nota_Fiscal_Dest.uf||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 10.2;
  -- Valida o campo "cod_pais"
  if pk_csf.fkg_codpais_siscomex_valido(en_cod_siscomex => est_row_Nota_Fiscal_Dest.cod_pais) = false then
     --
     vn_fase := 10.3;
     --
     gv_mensagem_log := '"Código do país do Destinatário da Nota Fiscal" inválido ('||est_row_Nota_Fiscal_Dest.cod_pais||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  vn_fase := 10.4;
  --
  if trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.pais)) is null then
     --
     est_row_Nota_Fiscal_Dest.pais := 'Brasil';
     --
  end if;
  --   --
  vn_fase := 10.5;
  --
  -- Valida se o Parâmetro que habilita a Emissao da Nota Fiscal Eletrônica para Exportação estão setado para 0 = não
  --
  if nvl(pk_csf.fkg_perm_exp_pais_id(en_pais_id => pk_csf.fkg_Pais_siscomex_id(ev_cod_siscomex => est_row_Nota_Fiscal_Dest.cod_pais)),1) = 0 then
     --
     vn_fase := 10.6;
     --
     gv_mensagem_log := 'O "Código do Pais do Destinatário" ('||est_row_Nota_Fiscal_Dest.cod_pais||') não permite exportação.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase                     := 11;
  est_row_Nota_Fiscal_Dest.ie := trim(replace(replace(replace(replace(upper(est_row_Nota_Fiscal_Dest.ie),' ',''),'.',''),'-',''),'/',''));
  -- Valida se a inscricao estadual de produtor de Minas Gerais
  if trim(est_row_Nota_Fiscal_Dest.ie) is not null and
     est_row_Nota_Fiscal_Dest.uf = 'MG' then
     --
     vn_fase := 11.1;
     if upper(substr(trim(est_row_Nota_Fiscal_Dest.ie), 1, 2)) = 'PR' and
        to_number(substr(trim(est_row_Nota_Fiscal_Dest.ie), 3, 12)) not between 9999 and 99999999 then
        --
        gv_mensagem_log := '"Inscrição estadual de produtor para Minas Gerais do Destinatário da Nota Fiscal" ('||trim(est_row_Nota_Fiscal_Dest.ie)||
                           ') está inválida.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => vt_log_generico_nf);
        --
     end if;
  end if;
  --
  vn_fase := 11.2;
  --
  if trim(est_row_Nota_Fiscal_Dest.cnpj) = '00000000000000' or
     trim(est_row_Nota_Fiscal_Dest.cnpj) = '0' then
     est_row_Nota_Fiscal_Dest.cnpj := null;
  end if;
  --
  vn_fase := 11.3;
  --
  if trim(est_row_Nota_Fiscal_Dest.cpf) = '00000000000' or
     trim(est_row_Nota_Fiscal_Dest.cpf) = '0' then
     est_row_Nota_Fiscal_Dest.cpf := null;
  end if;
  --
  -- Se o estado for EX, entao limpa o CNPJ e IE
  if est_row_Nota_Fiscal_Dest.uf = 'EX' then
     --
     est_row_Nota_Fiscal_Dest.cnpj := null;
     est_row_Nota_Fiscal_Dest.cpf  := null;
     est_row_Nota_Fiscal_Dest.ie   := null;
     --
  end if;
  --
  vn_fase := 12;
  -- valida se CNPJ é numérico caso ele seja informado.
  if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null and pk_csf.fkg_is_numerico(ev_valor => est_row_Nota_Fiscal_Dest.cnpj) = false then
     --
     vn_fase := 12.1;
     --
     gv_mensagem_log := 'O "CNPJ do Destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.cnpj||
                        ') deve conter somente números considerando os zeros à esquerda.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 12.2;
  --
  -- Valida o CNPJ
  if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null and
     pk_csf.fkg_is_numerico(ev_valor => est_row_Nota_Fiscal_Dest.cnpj) = true and
     nvl(pk_valida_docto.fkg_valida_cpf_cgc(ev_numero => est_row_Nota_Fiscal_Dest.cnpj),0) = 0 then
     --
     vn_fase := 12.3;
     --
     gv_mensagem_log := 'O "CNPJ do Destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.cnpj||') está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 13;
  -- valida se CNPJ e numerico caso ele seja informado.
  if trim(est_row_Nota_Fiscal_Dest.cpf) is not null and pk_csf.fkg_is_numerico(ev_valor => est_row_Nota_Fiscal_Dest.cpf) = false then
     --
     vn_fase := 13.1;
     --
     gv_mensagem_log := 'O "CPF do Destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.cpf||
                        ') deve conter somente números considerando os zeros à esquerda.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 13.2;
  --
  -- Valida o CPF
  if trim(est_row_Nota_Fiscal_Dest.cpf) is not null and
     pk_csf.fkg_is_numerico(ev_valor => est_row_Nota_Fiscal_Dest.cpf) = true and
     nvl(pk_valida_docto.fkg_valida_cpf_cgc(ev_numero => est_row_Nota_Fiscal_Dest.cpf),0) = 0 then
     --
     vn_fase := 13.3;
     --
     gv_mensagem_log := 'O "CPF do Destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.cpf||') está inválido.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 14;
  --
  -- Valida inscricao Estadual
  if trim(est_row_Nota_Fiscal_Dest.ie) is not null and
     trim(est_row_Nota_Fiscal_Dest.uf) is not null and
     nvl(pk_valida_docto.fkg_valida_ie(ev_inscr_est => est_row_Nota_Fiscal_Dest.ie
                                      ,ev_estado    => est_row_Nota_Fiscal_Dest.uf),0) = 0 then
     --
     vn_fase := 14.1;
     --
     gv_mensagem_log := 'A "Inscrição Estadual do Destinatário da Nota Fiscal" ('||est_row_Nota_Fiscal_Dest.ie||') está inválida.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 14.2;
  --
  if trim(est_row_Nota_Fiscal_Dest.ie) like 'ISENT%' then
     --
     --est_row_Nota_Fiscal_Dest.ie := 'ISENTO';
     est_row_Nota_Fiscal_Dest.ie := null; -- Mudanca de regra para NFe 3.10
     --
  end if;
  --
  vn_fase := 15;
  --
  if trim(est_row_Nota_Fiscal_Dest.cnpj) = 'EXTERIOR' then
     est_row_Nota_Fiscal_Dest.cnpj := null;
  elsif trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
     est_row_Nota_Fiscal_Dest.cnpj := lpad(trim(est_row_Nota_Fiscal_Dest.cnpj),14,'0');
  end if;
  --
  vn_fase := 16;
  --
  if trim(est_row_Nota_Fiscal_Dest.cpf) = 'EXTERIOR' then
     est_row_Nota_Fiscal_Dest.cpf := null;
  elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
     est_row_Nota_Fiscal_Dest.cpf := lpad(trim(est_row_Nota_Fiscal_Dest.cpf),11,'0');
  end if;
  --
  -- Se o Destinatário nao e uma pessoa fisica o campo "IE" não pode ter os VALORES ISENTO ou ISENTA
  vn_fase := 17;
  --
  if trim(est_row_Nota_Fiscal_Dest.cpf) is not null and
     trim(upper(est_row_Nota_Fiscal_Dest.ie)) in ('ISENTO', 'ISENTA') then
     --
     est_row_Nota_Fiscal_Dest.ie := null;
     --
  end if;
  --
  vn_fase := 18;
  -- retira ponto e barra do telefone
  est_row_Nota_Fiscal_Dest.fone := replace(replace(replace(replace(replace(replace(est_row_Nota_Fiscal_Dest.fone,'.',''),'-',''),'*',''),'(',''),')',''),' ','');
  --
  vn_fase := 18.1;
  --
  if trim(est_row_Nota_Fiscal_Dest.fone) is not null and
     not length(trim(est_row_Nota_Fiscal_Dest.fone)) between 6 and 14 then
     --
     vn_fase := 18.2;
     --
     gv_mensagem_log := 'O tamanho do "fone" ('||est_row_Nota_Fiscal_Dest.fone||') do destinatário deve estar entre 6 a 14 caracteres.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 18.3;
  --
  if trim(est_row_Nota_Fiscal_Dest.fone) is not null and pk_csf.fkg_is_numerico(ev_valor => est_row_Nota_Fiscal_Dest.fone) = false then
     --
     vn_fase := 18.4;
     --
     gv_mensagem_log := 'O "Telefone do Destinatário" ('||est_row_Nota_Fiscal_Dest.fone||') deve ser composto de apenas números.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 18.5;
  --
  -- Valida se o cnpj e o cpf estão sendo informado em operacoes nacionais
  if trim(est_row_Nota_Fiscal_Dest.uf) <> 'EX' and
     trim(est_row_Nota_Fiscal_Dest.cnpj) is null and
     trim(est_row_Nota_Fiscal_Dest.cpf) is null and
     gt_row_Nota_Fiscal.dm_ind_emit = 0 then -- Emissao própria
     --
     vn_fase := 18.6;
     --
     gv_mensagem_log := 'O "CNPJ ou CPF do Destinatário" obrigatório em operações nacionais ('||est_row_Nota_Fiscal_Dest.uf||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => vt_log_generico_nf);
     --
  end if;
  --
  vn_fase := 19;
  -- Verifica se foram encontrados erros no cadastro do Destinatário da NFe
  if nvl(vt_log_generico_nf.count, 0) > 0 then
     --
     vn_fase := 19.1;
     --
     vn_dm_util_end_fat_nfe := pk_csf.fkg_empresa_util_end_fat_nfe(en_empresa_id => gt_row_Nota_Fiscal.empresa_id);
     --
     vn_fase := 19.2;
     --
     if nvl(vn_dm_util_end_fat_nfe, 0) = 1 then
        -- Sim utiliza
        --
        vn_fase := 19.3;
        --
        if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
           vn_fase      := 19.4;
           vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj( en_multorg_id => en_multorg_id
                                                        , en_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cnpj));
        elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
           vn_fase      := 19.5;
           vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj( en_multorg_id => en_multorg_id
                                                        , en_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cpf));
        end if;
        --
        vn_fase := 19.6;
        -- Se não achou um cadastro de PESSOA INTERNA, entao pega por Integracao
        if nvl(vn_pessoa_id, 0) <= 0 then
           --
           if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
              vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj(en_multorg_id => en_multorg_id
                                                           ,en_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cnpj));
           elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
              vn_pessoa_id := pk_csf.fkg_Pessoa_id_cpf_cnpj(en_multorg_id => en_multorg_id
                                                           ,en_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cpf));
           end if;
           --
        end if;
        --
        vn_fase := 19.7;
        -- Procura pelo CPF/CNPJ
        if nvl(vn_pessoa_id, 0) <= 0 then
           -- Verifica se existe o participante no Compliance NFe (procura pelo Código do participante e se não achar, pelo CPF/CNPJ)
           vn_pessoa_id := pk_csf.fkg_pessoa_id_cod_part(en_multorg_id => en_multorg_id
                                                        ,ev_cod_part   => ev_cod_part);
           --
        end if;
        --
        vn_fase := 19.8;
        -- Se exite participante, recupera os dados para o Destinatário, caso os dados não estejam completos, registra ERRO DE VALIDACAO
        if nvl(vn_pessoa_id, 0) <= 0 then
           --
           vn_fase := 19.9;
           --
           gv_mensagem_log := 'Não existe o registro do participante no Compliance, favor cadastrar e reenviar a Nota Fiscal.';
           --
           vn_loggenerico_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                              ,ev_mensagem         => gv_cabec_log
                              ,ev_resumo           => gv_mensagem_log
                              ,en_tipo_log         => erro_de_validacao
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        else
           -- Recupera os dados e valida se os mesmos estão corretos
           -- busca somente se o tipo de inclusão for 0-Interno, que foi cadastrado na solucao fiscal
           vn_fase := 19.10;
           --
           begin
              --
              select p.nome
                    ,p.lograd
                    ,p.nro
                    ,p.compl
                    ,p.bairro
                    ,c.descr
                    ,c.ibge_cidade
                    ,e.sigla_estado
                    ,p.cep
                    ,pa.cod_siscomex
                    ,pa.descr
                    ,p.fone
                into est_row_Nota_Fiscal_Dest.NOME
                    ,est_row_Nota_Fiscal_Dest.LOGRAD
                    ,est_row_Nota_Fiscal_Dest.NRO
                    ,est_row_Nota_Fiscal_Dest.COMPL
                    ,est_row_Nota_Fiscal_Dest.BAIRRO
                    ,est_row_Nota_Fiscal_Dest.CIDADE
                    ,est_row_Nota_Fiscal_Dest.CIDADE_IBGE
                    ,est_row_Nota_Fiscal_Dest.UF
                    ,est_row_Nota_Fiscal_Dest.CEP
                    ,est_row_Nota_Fiscal_Dest.COD_PAIS
                    ,est_row_Nota_Fiscal_Dest.PAIS
                    ,est_row_Nota_Fiscal_Dest.FONE
                from pessoa p
                    ,cidade c
                    ,estado e
                    ,pais   pa
               where p.id = vn_pessoa_id
                 and c.id = p.cidade_id
                 and e.id = c.estado_id
                 and pa.id = p.pais_id;
              --
           exception
              when others then
                 null;
           end;
           --
           vn_fase := 19.11;
           --
           if (trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.nome)) is null or
              trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.lograd)) is null or
              trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.nro)) is null or
              trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.bairro)) is null or
              trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.cidade)) is null or
              nvl(est_row_Nota_Fiscal_Dest.cidade_ibge, 0) <= 0 or
              trim(est_row_Nota_Fiscal_Dest.uf) is null) and
              vv_cod_mod <> '65' then
              --
              vn_fase := 19.12;
              --
              gv_mensagem_log := 'Participante com o cadastro incompleto no Compliance NFe! Por favor corrija e re-envie e Nota Fiscal.';
              --
              vn_loggenerico_id := null;
              --
              pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                 ,ev_mensagem         => gv_cabec_log
                                 ,ev_resumo           => gv_mensagem_log
                                 ,en_tipo_log         => erro_de_validacao
                                 ,en_referencia_id    => gn_referencia_id
                                 ,ev_obj_referencia   => gv_obj_referencia);
              -- Armazena o "loggenerico_id" na memoria
              pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                    ,est_log_generico_nf => est_log_generico_nf);
              --
           else
              --
              vn_fase := 19.13;
              --
              vn_atualiza_erro := 0; -- não atualiza os erros!
              --
              gv_mensagem_log := 'Participante da Nota Fiscal atualizado conforme cadastro de Pessoa do Compliance.';
              --
              vn_loggenerico_id := null;
              --
              pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                 ,ev_mensagem         => gv_cabec_log
                                 ,ev_resumo           => gv_mensagem_log
                                 ,en_tipo_log         => NOTA_FISCAL_INTEGRADA
                                 ,en_referencia_id    => gn_referencia_id
                                 ,ev_obj_referencia   => gv_obj_referencia);
              --
           end if;
           --
        end if;
        --
     end if;
     --
     vn_fase := 20;
     --
     if nvl(vn_atualiza_erro, 0) = 1 then
        -- Sim, atualiza os erros
        --
        vn_indice := nvl(vt_log_generico_nf.first, 0);
        --
        vn_fase := 20.1;
        --
        loop
           --
           vn_fase := 20.2;
           --
           if vn_indice = 0 then
              exit;
           end if;
           --
           vn_fase := 20.3;
           --
           vn_loggenerico_id := vt_log_generico_nf(vn_indice);
           --
           vn_fase := 20.4;
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                 ,est_log_generico_nf => est_log_generico_nf);
           --
           vn_fase := 20.5;
           --
           if vn_indice = vt_log_generico_nf.last then
              exit;
           else
              vn_indice := vt_log_generico_nf.next(vn_indice);
           end if;
           --
        end loop;
        --
     end if;
     --
  end if;
  --
  vn_fase := 21;
  -- Bloqueio de pessoas com algum tipo de restricao
  --
  if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
     --
     pkb_verif_pessoas_restricao(est_log_generico_nf => est_log_generico_nf
                                ,ev_cpf_cnpj         => trim(est_row_Nota_Fiscal_Dest.cnpj)
                                ,en_multorg_id       => en_multorg_id);
     --
  elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
     --
     pkb_verif_pessoas_restricao(est_log_generico_nf => est_log_generico_nf
                                ,ev_cpf_cnpj         => trim(est_row_Nota_Fiscal_Dest.cpf)
                                ,en_multorg_id       => en_multorg_id);
     --
  end if;
  --
  vn_fase := 22;
  --
  if trim(est_row_Nota_Fiscal_Dest.cnpj) is not null then
     -- trata a Integracao por EDI
     vb_integr_edi := pk_csf.fkg_integr_edi(en_multorg_id => en_multorg_id
                                           ,ev_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cnpj)
                                           ,en_dm_tipo    => 1); -- NFe
  elsif trim(est_row_Nota_Fiscal_Dest.cpf) is not null then
     -- trata a Integracao por EDI
     vb_integr_edi := pk_csf.fkg_integr_edi(en_multorg_id => en_multorg_id
                                           ,ev_cpf_cnpj   => trim(est_row_Nota_Fiscal_Dest.cpf)
                                           ,en_dm_tipo    => 1); -- NFe
  else
     vb_integr_edi := false;
  end if;
  --
  vn_fase := 23;
  --
  if vb_integr_edi then
     est_row_nota_fiscal_dest.dm_integr_edi := 0; -- não integrado por EDI
  else
     est_row_nota_fiscal_dest.dm_integr_edi := 2; -- sem efeito
  end if;
  --
  vn_fase := 99;
  --
  -- Se não existe registro de Log e o Tipo de Integracao 1 (insere e valida)
  -- entao registra a informação do Destinário da NF
  if nvl(est_log_generico_nf.count, 0) > 0 and 
     fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => est_row_Nota_Fiscal_Dest.notafiscal_id ) = 1 then
     --
     update nota_fiscal
        set dm_st_proc = 10
      where id = est_row_Nota_Fiscal_Dest.notafiscal_id;
     --
  end if;
  --
  est_row_Nota_Fiscal_Dest.nome        := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.nome));
  est_row_Nota_Fiscal_Dest.lograd      := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.lograd));
  est_row_Nota_Fiscal_Dest.nro         := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.nro));
  est_row_Nota_Fiscal_Dest.compl       := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.compl));
  est_row_Nota_Fiscal_Dest.bairro      := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.bairro));
  est_row_Nota_Fiscal_Dest.cidade      := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.cidade));
  est_row_Nota_Fiscal_Dest.cidade_ibge := nvl(est_row_Nota_Fiscal_Dest.cidade_ibge
                                             ,0);
  est_row_Nota_Fiscal_Dest.uf          := trim(est_row_Nota_Fiscal_Dest.uf);
  est_row_Nota_Fiscal_Dest.pais        := trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.pais));
  est_row_Nota_Fiscal_Dest.fone        := replace(trim(pk_csf.fkg_converte(est_row_Nota_Fiscal_Dest.fone))
                                                 ,' '
                                                 ,'');
  est_row_Nota_Fiscal_Dest.suframa     := trim(est_row_Nota_Fiscal_Dest.suframa);
  est_row_Nota_Fiscal_Dest.email       := trim(replace(replace(replace(est_row_Nota_Fiscal_Dest.email
                                                                      ,','
                                                                      ,';')
                                                              ,' ;'
                                                              ,'')
                                                      ,' '
                                                      ,''));
  est_row_Nota_Fiscal_Dest.email       := trim(replace(est_row_Nota_Fiscal_Dest.email
                                                      ,'@.com'
                                                      ,''));
  --
  -- limpa acentos de e-mail
  est_row_Nota_Fiscal_Dest.email := pk_csf.fkg_limpa_acento(ev_string => est_row_Nota_Fiscal_Dest.email);
  --
  if instr(est_row_Nota_Fiscal_Dest.email, '@') = 0 then
     est_row_Nota_Fiscal_Dest.email := null;
  end if;
  --
  if trim(est_row_Nota_Fiscal_Dest.email) = '@' then
     est_row_Nota_Fiscal_Dest.email := null;
  end if;
  --
  if trim(est_row_Nota_Fiscal_Dest.email) is null then
     --
     update nota_fiscal
        set dm_st_email = 3
      where id = est_row_Nota_Fiscal_Dest.notafiscal_id;
     --
  end if;
  --
  vv_cnpj := est_row_Nota_Fiscal_Dest.cnpj;
  vv_cpf  := est_row_Nota_Fiscal_Dest.cpf;
  vv_ie   := est_row_Nota_Fiscal_Dest.ie;
  --
  if nvl(est_row_Nota_Fiscal_Dest.notafiscal_id, 0) > 0 then
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 99.1;
        --
        select notafiscaldest_seq.nextval
          into est_row_Nota_Fiscal_Dest.id
          from dual;
        --
        vn_fase := 99.2;
        --
        begin
           insert into Nota_Fiscal_Dest
              (id
              ,notafiscal_id
              ,cnpj
              ,cpf
              ,nome
              ,lograd
              ,nro
              ,compl
              ,bairro
              ,cidade
              ,cidade_ibge
              ,uf
              ,cep
              ,cod_pais
              ,pais
              ,fone
              ,ie
              ,suframa
              ,email
              ,dm_integr_edi
              ,dm_ind_ie_dest)
           values
              (est_row_Nota_Fiscal_Dest.id
              ,est_row_Nota_Fiscal_Dest.notafiscal_id
              ,est_row_Nota_Fiscal_Dest.cnpj
              ,est_row_Nota_Fiscal_Dest.cpf
              ,est_row_Nota_Fiscal_Dest.nome
              ,est_row_Nota_Fiscal_Dest.lograd
              ,est_row_Nota_Fiscal_Dest.nro
              ,est_row_Nota_Fiscal_Dest.compl
              ,est_row_Nota_Fiscal_Dest.bairro
              ,est_row_Nota_Fiscal_Dest.cidade
              ,est_row_Nota_Fiscal_Dest.cidade_ibge
              ,est_row_Nota_Fiscal_Dest.uf
              ,est_row_Nota_Fiscal_Dest.cep
              ,est_row_Nota_Fiscal_Dest.cod_pais
              ,est_row_Nota_Fiscal_Dest.pais
              ,est_row_Nota_Fiscal_Dest.fone
              ,est_row_Nota_Fiscal_Dest.ie
              ,est_row_Nota_Fiscal_Dest.suframa
              ,est_row_Nota_Fiscal_Dest.email
              ,est_row_nota_fiscal_dest.dm_integr_edi
              ,est_row_Nota_Fiscal_Dest.dm_ind_ie_dest);
        exception
           when dup_val_on_index then
              --
              vn_fase := 99.3;
              --
              update Nota_Fiscal_Dest
                 set cnpj           = est_row_Nota_Fiscal_Dest.cnpj
                    ,cpf            = est_row_Nota_Fiscal_Dest.cpf
                    ,nome           = est_row_Nota_Fiscal_Dest.nome
                    ,lograd         = est_row_Nota_Fiscal_Dest.lograd
                    ,nro            = est_row_Nota_Fiscal_Dest.nro
                    ,compl          = est_row_Nota_Fiscal_Dest.compl
                    ,bairro         = est_row_Nota_Fiscal_Dest.bairro
                    ,cidade         = est_row_Nota_Fiscal_Dest.cidade
                    ,cidade_ibge    = est_row_Nota_Fiscal_Dest.cidade_ibge
                    ,uf             = est_row_Nota_Fiscal_Dest.uf
                    ,cep            = est_row_Nota_Fiscal_Dest.cep
                    ,cod_pais       = est_row_Nota_Fiscal_Dest.cod_pais
                    ,pais           = est_row_Nota_Fiscal_Dest.pais
                    ,fone           = est_row_Nota_Fiscal_Dest.fone
                    ,ie             = est_row_Nota_Fiscal_Dest.ie
                    ,suframa        = est_row_Nota_Fiscal_Dest.suframa
                    ,email          = est_row_Nota_Fiscal_Dest.email
                    ,dm_integr_edi  = est_row_nota_fiscal_dest.dm_integr_edi
                    ,dm_ind_ie_dest = est_row_Nota_Fiscal_Dest.dm_ind_ie_dest
               where id = est_row_Nota_Fiscal_Dest.id;
              --
           when others then
              --
              gv_mensagem_log := 'Erro ao atualizar - chave duplicada fase ('||vn_fase||'): '||sqlerrm;
              --
              declare
                 vn_loggenerico_id log_generico_nf.id%type;
              begin
                 pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                    ,ev_mensagem         => gv_cabec_log
                                    ,ev_resumo           => gv_mensagem_log
                                    ,en_tipo_log         => erro_de_validacao
                                    ,en_referencia_id    => gn_referencia_id
                                    ,ev_obj_referencia   => gv_obj_referencia);
              exception
                 when others then
                    null;
              end;
              --
        end;
        --
     else
        --
        vn_fase := 99.4;
        --
        update Nota_Fiscal_Dest
           set cnpj           = est_row_Nota_Fiscal_Dest.cnpj
              ,cpf            = est_row_Nota_Fiscal_Dest.cpf
              ,nome           = est_row_Nota_Fiscal_Dest.nome
              ,lograd         = est_row_Nota_Fiscal_Dest.lograd
              ,nro            = est_row_Nota_Fiscal_Dest.nro
              ,compl          = est_row_Nota_Fiscal_Dest.compl
              ,bairro         = est_row_Nota_Fiscal_Dest.bairro
              ,cidade         = est_row_Nota_Fiscal_Dest.cidade
              ,cidade_ibge    = est_row_Nota_Fiscal_Dest.cidade_ibge
              ,uf             = est_row_Nota_Fiscal_Dest.uf
              ,cep            = est_row_Nota_Fiscal_Dest.cep
              ,cod_pais       = est_row_Nota_Fiscal_Dest.cod_pais
              ,pais           = est_row_Nota_Fiscal_Dest.pais
              ,fone           = est_row_Nota_Fiscal_Dest.fone
              ,ie             = est_row_Nota_Fiscal_Dest.ie
              ,suframa        = est_row_Nota_Fiscal_Dest.suframa
              ,email          = est_row_Nota_Fiscal_Dest.email
              ,dm_integr_edi  = est_row_nota_fiscal_dest.dm_integr_edi
              ,dm_ind_ie_dest = est_row_Nota_Fiscal_Dest.dm_ind_ie_dest
         where id = est_row_Nota_Fiscal_Dest.id;
        --
     end if;
     --
     vn_fase := 99.5;
     --
     vv_email_usuario := pk_csf.fkg_usuario_email_conf_erp(en_multorg_id => en_multorg_id
                                                          ,ev_id_erp     => trim(gt_row_nota_fiscal.id_usuario_erp));
     --
     vn_fase := 99.6;
     --
     gt_row_nfdest_email := null;
     --
     gt_row_nfdest_email.notafiscaldest_id := est_row_Nota_Fiscal_Dest.id;
     gt_row_nfdest_email.email             := vv_email_usuario;
     gt_row_nfdest_email.dm_tipo_anexo     := 3; -- DANFE/XML
     gt_row_nfdest_email.dm_st_email       := 0; -- não enviado
     --
     if trim(vv_email_usuario) is not null then
        --
        pkb_integr_nfdest_email(est_log_generico_nf  => est_log_generico_nf
                               ,est_row_nfdest_email => gt_row_nfdest_email
                               ,en_notafiscal_id     => est_row_Nota_Fiscal_Dest.notafiscal_id);
        --
     end if;
     --
     --
     if nvl(vt_log_generico_nf.count, 0) <= 0 and
        pk_csf_api.gt_row_Nota_Fiscal.dm_ind_emit = 0 then -- Somente Emissao propria
        --
        -- chama procedimento de registro da pessoa Destinatário da Nota Fiscal
        pkb_reg_pessoa_dest_nf(est_log_generico_nf     => est_log_generico_nf
                              ,et_row_Nota_Fiscal_Dest => est_row_Nota_Fiscal_Dest
                              ,ev_cod_part             => ev_cod_part
                              ,ev_cnpj                 => vv_cnpj
                              ,ev_cpf                  => vv_cpf
                              ,ev_ie                   => vv_ie);
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal_Dest fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NOTA_FISCAL_DEST;

--------------------------------------------------------------------
-- Procedimento de registro da pessoa Destinatário da Nota Fiscal --
--------------------------------------------------------------------
PROCEDURE PKB_VERIF_PESSOAS_RESTRICAO(EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                    ,EV_CPF_CNPJ         IN CTRL_RESTR_PESSOA.CPF_CNPJ%TYPE
                                    ,EN_MULTORG_ID       IN CTRL_RESTR_PESSOA.MULTORG_ID%TYPE DEFAULT 0) IS
  --
  vn_fase           number := null;
  vn_loggenerico_id log_generico_nf.id%type;
  vn_multorg_id     mult_org.id%type;
  --
  cursor c_restricao(en_multorg_id number) is
     select crp.*
       from ctrl_restr_pessoa crp
      where crp.cpf_cnpj = ev_cpf_cnpj
        and crp.dm_situacao = 1 -- Ativo
        and pk_csf_api.gt_row_Nota_Fiscal.dt_emiss between crp.dt_ini and
            nvl(crp.dt_fin, sysdate)
        and crp.multorg_id = en_multorg_id
      order by crp.id;
  --
begin
  --
  if nvl(en_multorg_id, 0) = 0 then
     --
     vn_multorg_id := pk_csf.fkg_multorg_id(ev_multorg_cd => '1');
     --
  else
     --
     vn_multorg_id := en_multorg_id;
     --
  end if;
  --
  vn_fase := 1;
  --
  if trim(ev_cpf_cnpj) is not null and
     pk_csf_api.gt_row_Nota_Fiscal.dm_ind_emit = 0 then -- Emissao própria
     --
     vn_fase := 2;
     --
     for rec in c_restricao(vn_multorg_id)
     loop
        --
        vn_fase := 3;
        --
        gv_mensagem_log := 'Destinatário da nota fiscal está com a restrição: '||rec.mensagem||' no período de '||rec.dt_ini||' até '||rec.dt_fin||'.';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end loop;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_verif_pessoas_restricao fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_VERIF_PESSOAS_RESTRICAO;

----------------------------------------------------
-- Integra informações de email por tipo de anexo --
----------------------------------------------------
PROCEDURE PKB_INTEGR_NFDEST_EMAIL(EST_LOG_GENERICO_NF  IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                ,EST_ROW_NFDEST_EMAIL IN OUT NOCOPY NFDEST_EMAIL%ROWTYPE
                                ,EN_NOTAFISCAL_ID     IN NOTA_FISCAL.ID%TYPE) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(est_row_nfdest_email.notafiscaldest_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 1.1;
     --
     gv_mensagem_log := 'Não informado a Nota Fiscal para relacionar ao email por tipo de anexo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 2;
  --
  est_row_nfdest_email.email := trim(replace(replace(est_row_nfdest_email.email
                                                    ,','
                                                    ,';')
                                            ,' ;'
                                            ,''));
  --
  vn_fase := 2.1;
  --
  if est_row_nfdest_email.email is null then
     --
     vn_fase := 2.2;
     --
     gv_mensagem_log := 'Não informado o e-mail do Destinatário conforme o tipo de anexo.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  --
  if nvl(est_row_nfdest_email.dm_tipo_anexo, 0) not in (1, 2, 3) then
     --
     vn_fase := 3.1;
     --
     gv_mensagem_log := 'Tipo de anexo do e-mail está inválido ('||nvl(est_row_nfdest_email.dm_tipo_anexo,0)||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 99;
  --
  -- Se não existe registro de Log e o Tipo de Integracao 1 (valida e insere)
  -- entao registra o local de coleta/entrega da NF
  if nvl(est_log_generico_nf.count, 0) > 0 and 
     fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => en_notafiscal_id ) = 1 then
     --
     update nota_fiscal
        set dm_st_proc = 10
      where id = en_notafiscal_id;
     --
  end if;
  --
  vn_fase := 99.1;
  --
  if nvl(est_row_nfdest_email.notafiscaldest_id, 0) > 0 and
     est_row_nfdest_email.email is not null and
     nvl(est_row_nfdest_email.dm_tipo_anexo, 0) in (1, 2, 3) then
     --
     vn_fase := 99.2;
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 99.3;
        --
        select NFDESTEMAIL_SEQ.nextval
          into est_row_nfdest_email.id
          from dual;
        --
        vn_fase := 99.4;
        --
        insert into nfdest_email
           (id
           ,notafiscaldest_id
           ,email
           ,dm_tipo_anexo
           ,dm_st_email)
        values
           (est_row_nfdest_email.id
           ,est_row_nfdest_email.notafiscaldest_id
           ,est_row_nfdest_email.email
           ,est_row_nfdest_email.dm_tipo_anexo
           ,0 -- não enviado
            );
        --
     else
        --
        vn_fase := 99.5;
        --
        update nfdest_email
           set notafiscaldest_id = est_row_nfdest_email.notafiscaldest_id
              ,email             = est_row_nfdest_email.email
              ,dm_tipo_anexo     = est_row_nfdest_email.dm_tipo_anexo
              ,dm_st_email       = 0 -- não enviado
         where id = est_row_nfdest_email.id;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_nfdest_email fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFDEST_EMAIL;

--------------------------------------------------------------------
-- Procedimento de registro da pessoa Destinatário da Nota Fiscal --
--------------------------------------------------------------------
PROCEDURE PKB_REG_PESSOA_DEST_NF(EST_LOG_GENERICO_NF     IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                               ,ET_ROW_NOTA_FISCAL_DEST IN NOTA_FISCAL_DEST%ROWTYPE
                               ,EV_COD_PART             IN PESSOA.COD_PART%TYPE
                               ,EV_CNPJ                 IN NOTA_FISCAL_DEST.CNPJ%TYPE
                               ,EV_CPF                  IN NOTA_FISCAL_DEST.CPF%TYPE
                               ,EV_IE                   IN NOTA_FISCAL_DEST.IE%TYPE) IS
  --
  vt_log_generico_nf dbms_sql.number_table;
  vn_dm_atual_part   empresa.dm_atual_part%type;
  vn_fase            number := 0;
  vv_cod_part        pessoa.cod_part%type;
  vn_dm_tipo_incl    pessoa.dm_tipo_incl%type;
  vn_multorg_id      empresa.multorg_id%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  vt_log_generico_nf.delete;
  -- verifica se a empresa que emitiu a nota atualiza o cadastro do participante
  -- somente para notas de Emissao própria
  begin
     --
     select em.dm_atual_part
           ,em.multorg_id
       into vn_dm_atual_part
           ,vn_multorg_id
       from empresa em
      where em.id = gt_row_nota_fiscal.empresa_id;
     --
  exception
     when others then
        vn_dm_atual_part := 0;
        vn_multorg_id    := null;
  end;
  --
  vn_fase := 2;
  --
  if nvl(vn_dm_atual_part, 0) = 1 and
     gt_row_nota_fiscal.dm_ind_emit = 0 then
     --
     vn_fase := 3;
     --
     vv_cod_part := trim(ev_cod_part);
     --
     if trim(vv_cod_part) is null then
        --
        if trim(ev_cnpj) is not null then
           --
           vv_cod_part := et_row_Nota_Fiscal_Dest.uf || trim(ev_cnpj);
           --
        elsif trim(ev_cpf) is not null then
           --
           vv_cod_part := et_row_Nota_Fiscal_Dest.uf || trim(ev_cpf);
           --
        else
           --
           vv_cod_part := et_row_Nota_Fiscal_Dest.notafiscal_id;
           --
        end if;
        --
     end if;
     --
     if trim(vv_cod_part) is not null then
        --
        vn_fase := 4;
        --
        pk_csf_api_cad.gt_row_pessoa := null;
        --
        pk_csf_api_cad.gt_row_pessoa.dm_tipo_incl := 1; -- Externo, cadastrado na importacao dos dados
        pk_csf_api_cad.gt_row_pessoa.cod_part     := vv_cod_part;
        pk_csf_api_cad.gt_row_pessoa.nome         := substr(et_row_Nota_Fiscal_Dest.nome, 1, 60);
        pk_csf_api_cad.gt_row_pessoa.lograd       := substr(et_row_Nota_Fiscal_Dest.lograd, 1, 60);
        --
        vn_fase := 4.1;
        --
        pk_csf_api_cad.gt_row_pessoa.nro       := substr(et_row_Nota_Fiscal_Dest.nro
                                                        ,1
                                                        ,10);
        pk_csf_api_cad.gt_row_pessoa.cx_postal := null;
        pk_csf_api_cad.gt_row_pessoa.compl     := et_row_Nota_Fiscal_Dest.compl;
        pk_csf_api_cad.gt_row_pessoa.bairro    := et_row_Nota_Fiscal_Dest.bairro;
        --
        vn_fase := 4.2;
        --
        if nvl(et_row_Nota_Fiscal_Dest.cidade_ibge, 0) > 0 then
           pk_csf_api_cad.gt_row_pessoa.cidade_id := pk_csf.fkg_Cidade_ibge_id(ev_ibge_cidade => et_row_Nota_Fiscal_Dest.cidade_ibge);
        else
           pk_csf_api_cad.gt_row_pessoa.cidade_id := pk_csf.fkg_Cidade_ibge_id(ev_ibge_cidade => 9999999);
        end if;
        --
        vn_fase := 4.3;
        --
        pk_csf_api_cad.gt_row_pessoa.cep        := et_row_Nota_Fiscal_Dest.cep;
        pk_csf_api_cad.gt_row_pessoa.fone       := substr(et_row_Nota_Fiscal_Dest.fone
                                                         ,1
                                                         ,10);
        pk_csf_api_cad.gt_row_pessoa.fax        := null;
        pk_csf_api_cad.gt_row_pessoa.pais_id    := pk_csf.fkg_Pais_siscomex_id(ev_cod_siscomex => et_row_Nota_Fiscal_Dest.cod_pais);
        pk_csf_api_cad.gt_row_pessoa.multorg_id := vn_multorg_id;
        --
        vn_fase := 5;
        --
        if trim(ev_cnpj) is null and trim(ev_cpf) is null then
           --
           pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa := 2; -- EXTERIOR
           --
        elsif trim(ev_cnpj) is not null then
           --
           pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa := 1; -- JURIDICA
           --
        elsif trim(ev_cpf) is not null then
           --
           pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa := 0; -- FÍSICA
           --
        end if;
        --
        vn_fase := 6;
        --
        -- Procura pelo CPF/CNPJ
        if nvl(pk_csf_api_cad.gt_row_pessoa.id, 0) <= 0 then
           --
           vn_fase := 6.1;
           -- Verifica se existe o participante no Compliance NFe (procura pelo Código do participante e se não achar, pelo CPF/CNPJ)
           pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_pessoa_id_cod_part(en_multorg_id => vn_multorg_id
                                                                           ,ev_cod_part   => vv_cod_part);
           --
           vn_fase := 6.2;
           --
           if nvl(pk_csf_api_cad.gt_row_pessoa.id, 0) <= 0 then
              --
              vn_fase := 6.3;
              --
              if trim(ev_cnpj) is not null then
                 --
                 -- substituído para que recupere o cadastro mais recente de pessoa com a mesma sigla de estado do Destinatário
                 -- pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_Pessoa_id_cpf_cnpj ( en_cpf_cnpj => trim(ev_cnpj) );
                 --
                 vn_fase                         := 6.4;
                 pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_pessoa_id_cpf_cnpj_uf(en_multorg_id => vn_multorg_id
                                                                                    ,en_cpf_cnpj   => trim(ev_cnpj)
                                                                                    ,ev_uf         => et_row_nota_fiscal_dest.uf);
                 --
              elsif trim(ev_cpf) is not null then
                 --
                 -- recupere o cadastro mais recente de pessoa com a mesma sigla de estado do Destinatário
                 -- pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_Pessoa_id_cpf_cnpj ( en_cpf_cnpj => trim(ev_cpf) );
                 --
                 vn_fase                         := 6.5;
                 pk_csf_api_cad.gt_row_pessoa.id := pk_csf.fkg_Pessoa_id_cpf_cnpj_uf(en_multorg_id => vn_multorg_id
                                                                                    ,en_cpf_cnpj   => trim(ev_cpf)
                                                                                    ,ev_uf         => et_row_nota_fiscal_dest.uf);
                 --
              end if;
              --
           end if;
           --
        end if;
        --
        if nvl(pk_csf_api_cad.gt_row_pessoa.id, 0) > 0 then
           --
           vn_dm_tipo_incl := pk_csf.fkg_pessoa_id_dm_tipo_incl(en_pessoa_id => pk_csf_api_cad.gt_row_pessoa.id);
           --
        else
           vn_dm_tipo_incl := 1;
        end if;
        --
        vn_fase := 7;
        --
        if nvl(pk_csf_api_cad.gt_row_pessoa.id, 0) > 0 then
           --
           update nota_fiscal nf
              set nf.pessoa_id = pk_csf_api_cad.gt_row_pessoa.id
            where nf.id = et_row_nota_fiscal_dest.notafiscal_id
              and nf.dm_ind_emit = 0 -- Emissao própria
              and nf.pessoa_id <= 0;
           --
        end if;
        --
        vn_fase := 8;
        -- Somente atualiza pessoas incluidas por meio de Integracao
        if vn_dm_tipo_incl = 1 then
           --
           vn_fase := 9;
           -- Valida se o participante não está cadastrado como empresa
           if pk_csf.fkg_valida_part_empresa ( en_multorg_id => pk_csf_api_cad.gt_row_pessoa.multorg_id
                                             , ev_cod_part   => pk_csf_api_cad.gt_row_pessoa.cod_part ) = FALSE then
              -- chama procedimento de resgitro da pessoa
              pk_csf_api_cad.pkb_ins_atual_pessoa( est_log_generico => vt_log_generico_nf
                                                 , est_pessoa       => pk_csf_api_cad.gt_row_pessoa
                                                 , en_empresa_id    => gt_row_nota_fiscal.empresa_id
                                                 );
              --
           end if;
           --
           vn_fase := 10;
           --
           if nvl(pk_csf_api_cad.gt_row_pessoa.id, 0) > 0 then
              --
              vn_fase := 11;
              -- Faz o Registro de pessoa fisica/juridica
              if pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa = 0 then
                 -- Física
                 --
                 vn_fase := 12;
                 --
                 pk_csf_api_cad.gt_row_fisica := null;
                 --
                 pk_csf_api_cad.gt_row_fisica.pessoa_id := pk_csf_api_cad.gt_row_pessoa.id;
                 --
                 vn_fase := 13;
                 --
                 begin
                    --
                    pk_csf_api_cad.gt_row_fisica.num_cpf := to_number(substr(ev_cpf
                                                                            ,1
                                                                            ,9));
                    pk_csf_api_cad.gt_row_fisica.dig_cpf := to_number(substr(ev_cpf
                                                                            ,10
                                                                            ,2));
                    --
                 exception
                    when others then
                       --
                       gv_mensagem_log := 'Erro inconsistência no CPF do Destinatário da NFe (fase: '||vn_fase||' - pkb_reg_pessoa_dest_nf): '||sqlerrm;
                       --
                       declare
                          vn_loggenerico_id log_generico_nf.id%type;
                       begin
                          pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                             ,ev_mensagem         => gv_cabec_log
                                             ,ev_resumo           => gv_mensagem_log
                                             ,en_tipo_log         => erro_de_validacao
                                             ,en_referencia_id    => gn_referencia_id
                                             ,ev_obj_referencia   => gv_obj_referencia);
                          -- Armazena o "loggenerico_id" na memoria
                          pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                                ,est_log_generico_nf => est_log_generico_nf);
                       exception
                          when others then
                             null;
                       end;
                       --
                 end;
                 --
                 vn_fase := 14;
                 --
                 pk_csf_api_cad.gt_row_fisica.rg := null;
                 --
                 pk_csf_api_cad.pkb_ins_atual_fisica(est_log_generico => vt_log_generico_nf
                                                    ,est_fisica       => pk_csf_api_cad.gt_row_fisica
                                                    , en_empresa_id    => gt_row_nota_fiscal.empresa_id
                                                    );
                 --
              elsif pk_csf_api_cad.gt_row_pessoa.dm_tipo_pessoa = 1 then
                 -- Jurídica
                 --
                 vn_fase := 15;
                 --
                 pk_csf_api_cad.gt_row_juridica := null;
                 --
                 pk_csf_api_cad.gt_row_juridica.pessoa_id := pk_csf_api_cad.gt_row_pessoa.id;
                 --
                 vn_fase := 16;
                 --
                 begin
                    --
                    pk_csf_api_cad.gt_row_juridica.num_cnpj   := to_number(substr(ev_cnpj
                                                                                 ,1
                                                                                 ,8));
                    pk_csf_api_cad.gt_row_juridica.num_filial := to_number(substr(ev_cnpj
                                                                                 ,9
                                                                                 ,4));
                    pk_csf_api_cad.gt_row_juridica.dig_cnpj   := to_number(substr(ev_cnpj
                                                                                 ,13
                                                                                 ,2));
                    --
                 exception
                    when others then
                       --
                       gv_mensagem_log := 'Erro inconsistência no CNPJ do Destinatário da NFe (fase: '||vn_fase||' - pkb_reg_pessoa_dest_nf): '||sqlerrm;
                       --
                       declare
                          vn_loggenerico_id log_generico_nf.id%type;
                       begin
                          pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                             ,ev_mensagem         => gv_cabec_log
                                             ,ev_resumo           => gv_mensagem_log
                                             ,en_tipo_log         => erro_de_validacao
                                             ,en_referencia_id    => gn_referencia_id
                                             ,ev_obj_referencia   => gv_obj_referencia);
                          -- Armazena o "loggenerico_id" na memoria
                          pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                                ,est_log_generico_nf => est_log_generico_nf);
                       exception
                          when others then
                             null;
                       end;
                       --
                 end;
                 --
                 vn_fase := 17;
                 --
                 pk_csf_api_cad.gt_row_juridica.ie      := ev_ie;
                 pk_csf_api_cad.gt_row_juridica.iest    := null;
                 pk_csf_api_cad.gt_row_juridica.im      := null;
                 pk_csf_api_cad.gt_row_juridica.cnae    := null;
                 pk_csf_api_cad.gt_row_juridica.suframa := et_row_Nota_Fiscal_Dest.suframa;
                 --
                 vn_fase := 18;
                 --
                 pk_csf_api_cad.pkb_ins_atual_juridica(est_log_generico => vt_log_generico_nf
                                                      ,est_juridica     => pk_csf_api_cad.gt_row_juridica
                                                      , en_empresa_id    => gt_row_nota_fiscal.empresa_id
                                                      );
                 --
              end if;
              --
           end if;
           --
        end if;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_reg_pessoa_dest_nf fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_REG_PESSOA_DEST_NF;

-------------------------------------------------------------------------------------------------------
--| Procedimento valida informação do complemento do PIS nas notas fiscais de serviços
procedure pkb_val_nf_compl_oper_pis_sc(est_log_generico_nf in out nocopy dbms_sql.number_table,
                                       en_notafiscal_id    in nota_fiscal.id%TYPE,
                                       en_empresa_id       in empresa.id%type) is
  --
  vn_fase              number := 0;
  vn_loggenerico_id    log_generico_nf.id%type;
  vv_cod_st_cofins     cod_st.cod_st%type;
  vn_vl_bc_cofins      number;
  vb_existe_compl      boolean := false;
  vn_dm_valida_pis     number(1);
  vn_dm_emitente       number(1);
  vn_codst_id          nf_compl_oper_pis.codst_id%type;
  vn_basecalccredpc_id nf_compl_oper_pis.basecalccredpc_id%type;
  vn_aliq_pis          nf_compl_oper_pis.aliq_pis%type;
  vn_planoconta_id     nf_compl_oper_pis.planoconta_id%type;
  vn_qtde              number;
  --
  cursor c_compl_oper_pis_sc is
    select notafiscal_id,
           sum(nvl(vl_item, 0)) vl_item,
           sum(nvl(vl_pis, 0)) vl_pis
      from nf_compl_oper_pis
     where notafiscal_id = en_notafiscal_id
     group by notafiscal_id;
  --
  cursor c_soma_cst is
    select cst.cod_st, 
           sum(op.vl_bc_pis) vl_bc_pis
      from nf_compl_oper_pis op, 
           cod_st cst
     where op.notafiscal_id = en_notafiscal_id
       and cst.id           = op.codst_id
     group by cst.cod_st;
  --
  cursor c_qtde_chave is
    select oc.codst_id,
           oc.basecalccredpc_id,
           oc.aliq_pis,
           oc.planoconta_id,
           count(*) qtde
      from nf_compl_oper_pis oc
     where oc.notafiscal_id = en_notafiscal_id
     group by oc.codst_id,
              oc.basecalccredpc_id,
              oc.aliq_pis,
              oc.planoconta_id
    having count(*) > 1;
  --
begin
  --
  vn_fase := 1;
  --
  vn_dm_emitente := pk_csf.fkg_dmindemit_notafiscal(en_notafiscal_id => en_notafiscal_id);
  --
  if vn_dm_emitente = 1 then -- Terceiro
    --
    vn_dm_valida_pis := pk_csf_nfs.fkg_empresa_dmvalpisterc_nfs(en_empresa_id => en_empresa_id);
  else
    --
    vn_dm_valida_pis := pk_csf_nfs.fkg_empresa_dmvalpisemiss_nfs(en_empresa_id => en_empresa_id);
    --
  end if;
  --
  if nvl(en_notafiscal_id, 0) > 0 then
    --
    vn_fase := 2;
    --
    -- Informações do complemento do PIS para serviços continuos
    for rec in c_compl_oper_pis_sc loop
      --
      exit when c_compl_oper_pis_sc%notfound or(c_compl_oper_pis_sc%notfound) is null;
      --
      vn_fase := 3;
      --
      vb_existe_compl := true;
      --
      -- Observações: Em notas fiscais de serviço contínuos não existe item. Portanto, não tem como buscar o
      -- valor da base de pis na tabela imp_itemnf para comparar com a base de pis da tabela nf_compl_oper_pis.
      -- Os demais campos são validados na api de Integracao da tabela nf_compl_oper_cofins
      --
      -- Validacao: Valor do Serviço no Total da Nota igual ao Valor do Item no Compl. de PIS
      if nvl(rec.vl_item, 0) <> nvl(gt_row_nota_fiscal_total.vl_servico, 0) then
        --
        vn_fase := 3.1;
        --
        gv_mensagem_log := 'O "Vlr do Item no Compl. de PIS" (' || rec.vl_item || ') está divergente do "Vlr do Item no Total" (' || gt_row_nota_fiscal_total.vl_servico || ') da Nota Fiscal.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
      vn_fase := 3.2;
      --
      if rec.vl_pis <> gt_row_nota_fiscal_total.vl_imp_trib_pis then
        --
        vn_fase := 3.3;
        --
        gv_mensagem_log := 'O "Valor do Complemento do PIS" (' || rec.vl_pis || ') está divergente em relação ao "Valor Total do PIS" (' || gt_row_nota_fiscal_total.vl_imp_trib_pis || ') da Nota Fiscal.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
    end loop;
    --
    if vb_existe_compl = false and vn_dm_valida_pis = 1 then
      --
      vn_fase := 3.3;
      --
      gv_mensagem_log := 'Não foi encontrado o "Valor do Complemento do PIS" para a Nota Fiscal.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                     ev_mensagem         => gv_cabec_log,
                                     ev_resumo           => gv_mensagem_log,
                                     en_tipo_log         => erro_de_validacao,
                                     en_referencia_id    => en_notafiscal_id,
                                     ev_obj_referencia   => gv_obj_referencia);
      --
      -- Armazena o "loggenerico_id" na memoria
      pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                        est_log_generico_nf => est_log_generico_nf);
      --
    end if;
    --
    vn_fase := 4;
    --
    if vn_dm_valida_pis = 1 then
      --
      -- Verifica se os dados de COFINS são iguais aos de PIS
      for rec in c_soma_cst loop
        --
        exit when c_soma_cst%notfound or(c_soma_cst%notfound) is null;
        --
        vn_fase := 4.1;
        --
        begin
          select cst.cod_st, 
                 sum(oc.vl_bc_cofins) vl_bc_cofins
            into vv_cod_st_cofins, 
                 vn_vl_bc_cofins
            from nf_compl_oper_cofins oc, 
                 cod_st cst
           where oc.notafiscal_id = en_notafiscal_id
             and cst.cod_st       = rec.cod_st
             and cst.id           = oc.codst_id
           group by cst.cod_st;
        exception
          when others then
            vv_cod_st_cofins := null;
            vn_vl_bc_cofins  := 0;
        end;
        --
        vn_fase := 4.2;
        --
        if vv_cod_st_cofins is null then
          --
          gv_mensagem_log := 'Não informado o imposto de COFINS.';
          --
          vn_loggenerico_id := null;
          --
          pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                         ev_mensagem         => gv_cabec_log,
                                         ev_resumo           => gv_mensagem_log,
                                         en_tipo_log         => erro_de_validacao,
                                         en_referencia_id    => en_notafiscal_id,
                                         ev_obj_referencia   => gv_obj_referencia);
          --
          -- Armazena o "loggenerico_id" na memoria
          pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                            est_log_generico_nf => est_log_generico_nf);
          --
        else
          --
          vn_fase := 4.3;
          --
          if vv_cod_st_cofins <> rec.cod_st then
            --
            gv_mensagem_log := 'Código da Situação Tributária do COFINS (' || vv_cod_st_cofins || ') está diferente do Código da Situação Tributária do PIS (' || rec.cod_st || ' ).';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                           ev_mensagem         => gv_cabec_log,
                                           ev_resumo           => gv_mensagem_log,
                                           en_tipo_log         => erro_de_validacao,
                                           en_referencia_id    => en_notafiscal_id,
                                           ev_obj_referencia   => gv_obj_referencia);
            --
            -- Armazena o "loggenerico_id" na memoria
            pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                              est_log_generico_nf => est_log_generico_nf);
            --
          end if;
          --
          vn_fase := 4.4;
          --
          if nvl(vn_vl_bc_cofins, 0) <> nvl(rec.vl_bc_pis, 0) then
            --
            gv_mensagem_log := 'Valor da Base do COFINS (' || nvl(vn_vl_bc_cofins, 0) || ') está diferente do Valor da Base do PIS (' || nvl(rec.vl_bc_pis, 0) || ').';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                           ev_mensagem         => gv_cabec_log,
                                           ev_resumo           => gv_mensagem_log,
                                           en_tipo_log         => erro_de_validacao,
                                           en_referencia_id    => en_notafiscal_id,
                                           ev_obj_referencia   => gv_obj_referencia);
            --
            -- Armazena o "loggenerico_id" na memoria
            pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                              est_log_generico_nf => est_log_generico_nf);
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if; -- vn_dm_valida_pis = 1
    --
    vn_fase := 5;
    --
    if vn_dm_valida_pis = 1 then
      --
      vn_fase := 5.1;
      --
      open c_qtde_chave;
      fetch c_qtde_chave
        into vn_codst_id,
             vn_basecalccredpc_id,
             vn_aliq_pis,
             vn_planoconta_id,
             vn_qtde;
      close c_qtde_chave;
      --
      vn_fase := 5.2;
      --
      if nvl(vn_qtde, 0) > 1 then
        --
        gv_mensagem_log := 'Existe mais de um registro para o imposto agrupado por CST, Natureza de Base calculo, Alíquota e Plano de Conta. Verifique.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
    end if;
    --
  end if;
  --
exception
  when others then
    --
    gv_mensagem_log := 'Erro na pkb_val_nf_compl_oper_pis_sc fase (' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_nf.id%TYPE;
    begin
      --
      pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                     ev_mensagem         => gv_cabec_log,
                                     ev_resumo           => gv_mensagem_log,
                                     en_tipo_log         => erro_de_sistema,
                                     en_referencia_id    => en_notafiscal_id,
                                     ev_obj_referencia   => gv_obj_referencia);
      --
      -- Armazena o "loggenerico_id" na memoria
      pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                        est_log_generico_nf => est_log_generico_nf);
      --
    exception
      when others then
        null;
    end;
    --
end pkb_val_nf_compl_oper_pis_sc;

-------------------------------------------------------------------------------------------------------
--| Procedimento válida informação do complemento do cofins nas notas fiscais de serviço
procedure pkb_val_nf_comp_oper_cofins_sc(est_log_generico_nf in out nocopy dbms_sql.number_table,
                                         en_notafiscal_id    in nota_fiscal.id%type,
                                         en_empresa_id       in empresa.id%type) is
  --
  vn_fase              number := 0;
  vn_loggenerico_id    log_generico_nf.id%type;
  vv_cod_st_pis        cod_st.cod_st%type;
  vn_vl_bc_pis         number;
  vb_existe_compl      boolean := false;
  vn_dm_valida_cofins  number(1);
  vn_dm_emitente       number(1);
  vn_codst_id          nf_compl_oper_cofins.codst_id%type;
  vn_basecalccredpc_id nf_compl_oper_cofins.basecalccredpc_id%type;
  vn_aliq_cofins       nf_compl_oper_cofins.aliq_cofins%type;
  vn_planoconta_id     nf_compl_oper_cofins.planoconta_id%type;
  vn_qtde              number;
  --
  cursor c_compl_cofins_sc is
    select notafiscal_id,
           sum(nvl(vl_item, 0)) vl_item,
           sum(nvl(vl_cofins, 0)) vl_cofins
      from nf_compl_oper_cofins
     where notafiscal_id = en_notafiscal_id
     group by notafiscal_id;
  --
  cursor c_soma_cst is
    select cst.cod_st, 
           sum(oc.vl_bc_cofins) vl_bc_cofins
      from nf_compl_oper_cofins oc, 
           cod_st cst
     where oc.notafiscal_id = en_notafiscal_id
       and cst.id           = oc.codst_id
     group by cst.cod_st;
  --
  cursor c_qtde_chave is
    select oc.codst_id,
           oc.basecalccredpc_id,
           oc.aliq_cofins,
           oc.planoconta_id,
           count(1) qtde
      from nf_compl_oper_cofins oc
     where oc.notafiscal_id = en_notafiscal_id
     group by oc.codst_id,
              oc.basecalccredpc_id,
              oc.aliq_cofins,
              oc.planoconta_id
    having count(1) > 1;
  --
begin
  --
  vn_fase := 1;
  --
  vn_dm_emitente := pk_csf.fkg_dmindemit_notafiscal(en_notafiscal_id => en_notafiscal_id);
  --
  if vn_dm_emitente = 1 then -- Terceiro
    --
    vn_dm_valida_cofins := pk_csf_nfs.fkg_empresa_dmvalcofterc_nfs(en_empresa_id => en_empresa_id);
    --
  else
    --
    vn_dm_valida_cofins := pk_csf_nfs.fkg_empresa_dmvalcofemiss_nfs(en_empresa_id => en_empresa_id);
    --
  end if;
  --
  if nvl(en_notafiscal_id, 0) > 0 then
    --
    vn_fase := 2;
    --
    -- Informações do complemento do cofins para serviços contínuos
    for rec in c_compl_cofins_sc loop
      --
      exit when c_compl_cofins_sc%notfound or(c_compl_cofins_sc%notfound) is null;
      --
      vn_fase := 3;
      --
      vb_existe_compl := true;
      --
      -- Observações: Em notas fiscais de serviço contínuos não existe item. Portanto, não tem como buscar o
      -- valor da base de cofins na tabela imp_itemnf para comparar com a base de cofins da tabela nf_compl_oper_cofins.
      -- Os demais campos são validados na api de Integracao da tabela nf_compl_oper_cofins
      --
      -- Validacao: Valor do serviço no Total da Nota igual ao Valor do Item no Compl. de Cofins
      if nvl(rec.vl_item, 0) <> nvl(gt_row_nota_fiscal_total.vl_servico, 0) then
        --
        vn_fase := 3.1;
        --
        gv_mensagem_log := 'O "Vlr do Item no Compl. de COFINS" (' || rec.vl_item || ') está divergente do "Vlr do Item no Total" (' || gt_row_nota_fiscal_total.vl_servico || ') da Nota Fiscal.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
      vn_fase := 3.2;
      --
      if rec.vl_cofins <> gt_row_nota_fiscal_total.vl_imp_trib_cofins then
        --
        vn_fase := 3.3;
        --
        gv_mensagem_log := 'O "Valor do Complemento do COFINS" (' || rec.vl_cofins || ') está divergente em relação ao "Valor Total do COFINS" (' || gt_row_nota_fiscal_total.vl_imp_trib_cofins || ') da Nota Fiscal.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
    end loop;
    --
    if vb_existe_compl = false and vn_dm_valida_cofins = 1 then
      --
      vn_fase := 3.3;
      --
      gv_mensagem_log := 'Não foi encontrado o "Valor do Complemento do COFINS" para a Nota Fiscal.';
      --
      vn_loggenerico_id := null;
      --
      pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                     ev_mensagem         => gv_cabec_log,
                                     ev_resumo           => gv_mensagem_log,
                                     en_tipo_log         => erro_de_validacao,
                                     en_referencia_id    => en_notafiscal_id,
                                     ev_obj_referencia   => gv_obj_referencia);
      --
      -- Armazena o "loggenerico_id" na memoria
      pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                        est_log_generico_nf => est_log_generico_nf);
      --
    end if;
    --
    vn_fase := 4;
    --
    if vn_dm_valida_cofins = 1 then
      --
      -- Verifica se os dados de COFINS são iguais aos de PIS
      for rec in c_soma_cst loop
        --
        exit when c_soma_cst%notfound or(c_soma_cst%notfound) is null;
        --
        vn_fase := 4.1;
        --
        begin
          select cst.cod_st, 
                 sum(op.vl_bc_pis) vl_bc_pis
            into vv_cod_st_pis, 
                 vn_vl_bc_pis
            from nf_compl_oper_pis op, 
                 cod_st cst
           where op.notafiscal_id = en_notafiscal_id
             and cst.cod_st       = rec.cod_st 
             and cst.id           = op.codst_id
           group by cst.cod_st;
        exception
          when others then
            vv_cod_st_pis := null;
            vn_vl_bc_pis  := 0;
        end;
        --
        vn_fase := 4.2;
        --
        if vv_cod_st_pis is null then
          --
          gv_mensagem_log := 'Não informado o imposto de PIS.';
          --
          vn_loggenerico_id := null;
          --
          pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                         ev_mensagem         => gv_cabec_log,
                                         ev_resumo           => gv_mensagem_log,
                                         en_tipo_log         => erro_de_validacao,
                                         en_referencia_id    => en_notafiscal_id,
                                         ev_obj_referencia   => gv_obj_referencia);
          --
          -- Armazena o "loggenerico_id" na memoria
          pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                            est_log_generico_nf => est_log_generico_nf);
          --
        else
          --
          vn_fase := 4.3;
          --
          if vv_cod_st_pis <> rec.cod_st then
            --
            gv_mensagem_log := 'Código da Situação Tributária do PIS (' || vv_cod_st_pis || ') está diferente do Código da Situação Tributária do COFINS (' || rec.cod_st || ').';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                           ev_mensagem         => gv_cabec_log,
                                           ev_resumo           => gv_mensagem_log,
                                           en_tipo_log         => erro_de_validacao,
                                           en_referencia_id    => en_notafiscal_id,
                                           ev_obj_referencia   => gv_obj_referencia);
            --
            -- Armazena o "loggenerico_id" na memoria
            pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                              est_log_generico_nf => est_log_generico_nf);
            --
          end if;
          --
          vn_fase := 4.4;
          --
          if nvl(vn_vl_bc_pis, 0) <> nvl(rec.vl_bc_cofins, 0) then
            --
            gv_mensagem_log := 'Valor da Base do PIS (' || nvl(vn_vl_bc_pis, 0) || ') está diferente do Valor da Base do COFINS (' || nvl(rec.vl_bc_cofins, 0) || ').';
            --
            vn_loggenerico_id := null;
            --
            pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                           ev_mensagem         => gv_cabec_log,
                                           ev_resumo           => gv_mensagem_log,
                                           en_tipo_log         => erro_de_validacao,
                                           en_referencia_id    => en_notafiscal_id,
                                           ev_obj_referencia   => gv_obj_referencia);
            --
            -- Armazena o "loggenerico_id" na memoria
            pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                              est_log_generico_nf => est_log_generico_nf);
            --
          end if;
          --
        end if;
        --
      end loop;
      --
    end if; -- vn_dm_valida_cofins = 1
    --
    vn_fase := 5;
    --
    if vn_dm_valida_cofins = 1 then
      --
      vn_fase := 5.1;
      --
      open c_qtde_chave;
      fetch c_qtde_chave
        into vn_codst_id,
             vn_basecalccredpc_id,
             vn_aliq_cofins,
             vn_planoconta_id,
             vn_qtde;
      close c_qtde_chave;
      --
      vn_fase := 5.2;
      --
      if nvl(vn_qtde, 0) > 1 then
        --
        gv_mensagem_log := 'Existe mais de um registro para o imposto agrupado por CST, Natureza de Base calculo, Alíquota e Plano de Conta. Verifique.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
    end if; -- vn_dm_valida_cofins = 1
    --
  end if;
  --
exception
  when others then
    --
    gv_mensagem_log := 'Erro na pkb_val_nf_comp_oper_cofins_sc fase (' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_nf.id%TYPE;
    begin
      --
      pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                     ev_mensagem         => gv_cabec_log,
                                     ev_resumo           => gv_mensagem_log,
                                     en_tipo_log         => erro_de_sistema,
                                     en_referencia_id    => en_notafiscal_id,
                                     ev_obj_referencia   => gv_obj_referencia);
      --
      -- Armazena o "loggenerico_id" na memoria
      pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                        est_log_generico_nf => est_log_generico_nf);
      --
    exception
      when others then
        null;
    end;
    --
end pkb_val_nf_comp_oper_cofins_sc;

-------------------------------------------------------------------------------------------------------
--| Procedimento valida informação nos totais da nota fiscal de serviço
procedure pkb_valida_nota_fiscal_total(est_log_generico_nf in out nocopy dbms_sql.number_table
                                     ,en_notafiscal_id    in Nota_Fiscal.Id%TYPE) is
  --
  vn_fase           number := 0;
  vn_qtde           number := 0;
  vn_loggenerico_id log_generico_nf.id%TYPE;
  --
  cursor c_nota_fiscal_total is
     select *
       from nota_fiscal_total
      where notafiscal_id = en_notafiscal_id;
  --
begin
  --
  vn_fase := 1;
  --
  if nvl(en_notafiscal_id, 0) > 0 then
     --
     vn_fase := 2;
     --
     -- Busca registro no total da nfe
     Begin
        select count(a.id)
          into vn_qtde
          from nota_fiscal_total a
         where a.notafiscal_id = en_notafiscal_id;
     exception
        when others then
           vn_qtde := 0;
     end;
     --
     vn_fase := 2.1;
     --
     if nvl(vn_qtde, 0) <= 0 then
        --
        vn_fase := 2.2;
        --
        gv_mensagem_log := 'As informações sobre o Analítico das Notas Fiscais são obrigatórias.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                      ,ev_mensagem         => gv_cabec_log
                                      ,ev_resumo           => gv_mensagem_log
                                      ,en_tipo_log         => ERRO_DE_VALIDACAO
                                      ,en_referencia_id    => en_notafiscal_id
                                      ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                         ,est_log_generico_nf => est_log_generico_nf);
        --
     elsif nvl(vn_qtde, 0) > 1 then
        --
        vn_fase := 2.3;
        --
        gv_mensagem_log := 'Existe mais de um registro sobre as informações dos Totais da Nota Fiscal de Serviço Contínuo.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                      ,ev_mensagem         => gv_cabec_log
                                      ,ev_resumo           => gv_mensagem_log
                                      ,en_tipo_log         => ERRO_DE_VALIDACAO
                                      ,en_referencia_id    => en_notafiscal_id
                                      ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                         ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
     vn_fase := 2.4;
     --
     -- informações sobre os Totais da NF de Serviço Contínuos
     -- Ps.: As validações abaixo são excluívas das notas fiscais de serviços contínuos
     -- por isso não estão na api de Integracao da nota_fiscal_total.
     for rec in c_nota_fiscal_total
     loop
        exit when c_nota_fiscal_total%notfound or(c_nota_fiscal_total%notfound) is null;
        --
        vn_fase := 3;
        --
        -- validacao: O Valor do Total da NF é obrigatório nos serviços contínuos.
        if nvl(rec.vl_total_nf, 0) <= 0 then
           --
           vn_fase := 3.1;
           --
           gv_mensagem_log := 'O "Valor do Documento" ('||rec.vl_total_nf||') deve ser maior que zero.';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => ERRO_DE_VALIDACAO
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        vn_fase := 4;
        -- validacao: O Valor do serviço Continuo para Modelo doc entre 06, 28 e 29
        if gv_cod_mod in ('06', '28', '29') and
           nvl(rec.vl_forn, 0) <= 0 then
           --
           vn_fase := 4.1;
           --
           gv_mensagem_log := 'O "Valor Total serviço - Fornecido/Consumido" ('||rec.vl_forn||') deve ser maior que zero '||
                              'na Nota Fiscal de serviço Contínuo com modelo documento entre 06, 28 e 29.';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => ERRO_DE_VALIDACAO
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        vn_fase := 5;
        -- validacao: O Valor do serviço Continuo para Modelo doc entre 21 e 22
        if gv_cod_mod in ('21', '22') and 
           nvl(rec.vl_servico, 0) <= 0 then
           --
           vn_fase := 5.1;
           --
           gv_mensagem_log := 'O "Valor da Prestação de Serviço" ('||rec.vl_servico||') deve ser maior que zero '||
                              'na Nota Fiscal de Serviços Contínuos com modelo documento entre 21 e 22.';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => ERRO_DE_VALIDACAO
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
     end loop;
     --
  end if;
  --
exception
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_valida_nota_fiscal_total fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%TYPE;
     begin
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                      ,ev_mensagem         => gv_cabec_log
                                      ,ev_resumo           => gv_mensagem_log
                                      ,en_tipo_log         => ERRO_DE_SISTEMA
                                      ,en_referencia_id    => en_notafiscal_id
                                      ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                         ,est_log_generico_nf => est_log_generico_nf);
        --
     exception
        when others then
           null;
     end;
     --
end pkb_valida_nota_fiscal_total;

-------------------------------------------------------------------------------------------------------
--| Procedimento valida informação do analitico das notas fiscais de serviço contnuos
procedure pkb_valida_nf_reg_anal(est_log_generico_nf in out nocopy dbms_sql.number_table
                               ,en_notafiscal_id    in Nota_Fiscal.Id%TYPE) is
  --
  vn_fase           number := 0;
  vn_qtde           number := 0;
  vn_loggenerico_id log_generico_nf.id%TYPE;
  --
  cursor c_nf_reg_anal is
     select sum(nvl(vl_operacao, 0)) vl_operacao
           ,sum(nvl(vl_bc_icms, 0)) vl_bc_icms
           ,sum(nvl(vl_icms, 0)) vl_icms
           ,sum(nvl(vl_bc_icms_st, 0)) vl_bc_icms_st
           ,sum(nvl(vl_icms_st, 0)) vl_icms_st
           ,sum(nvl(vl_ipi, 0)) vl_ipi
       from nfregist_analit
      where notafiscal_id = en_notafiscal_id;
  --
  cursor c_nf_reg_anal2 is
     select *
       from nfregist_analit
      where notafiscal_id = en_notafiscal_id;
  --
begin
  vn_fase := 1;
  --
  if nvl(en_notafiscal_id, 0) > 0 then
     --
     vn_fase := 2;
     --
     -- Busca registro no analitico da nf
     Begin
        select count(1)
          into vn_qtde
          from nfregist_analit a
         where a.notafiscal_id = en_notafiscal_id;
     exception
        when others then
           vn_qtde := 0;
     end;
     --
     vn_fase := 2.1;
     --
     if nvl(vn_qtde, 0) <= 0 then
        --
        vn_fase := 2.2;
        --
        gv_mensagem_log := 'As informações sobre o resumo de ICMS é obrigatória.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                      ,ev_mensagem         => gv_cabec_log
                                      ,ev_resumo           => gv_mensagem_log
                                      ,en_tipo_log         => ERRO_DE_VALIDACAO
                                      ,en_referencia_id    => en_notafiscal_id
                                      ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                         ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
     -- validacao pelas somatórias: informações do analitico das notas fiscais de serviço contínuos
     for rec in c_nf_reg_anal
     loop
        exit when c_nf_reg_anal%notfound or(c_nf_reg_anal%notfound) is null;
        --
        vn_fase := 3;
        --
        -- validacao: Valor Total do Documento deve ser igual ao valor da operação no analítico
        if nvl(rec.vl_operacao, 0) <> nvl(gt_row_nota_fiscal_total.vl_total_nf, 0) then
           --
           vn_fase := 3.1;
           --
           gv_mensagem_log := 'O "Vlr Total da Nota Fiscal" ('||gt_row_nota_fiscal_total.vl_total_nf||') está divergente do '||
                              '"Vlr da operação" ('||rec.vl_operacao||') no Analítico da Nota Fiscal.';
           --
           vn_loggenerico_id := null;
           --
           -- Redmine #28722 - Trocar o erro de validação para informação no log
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => INFORMACAO -- ERRO_DE_VALIDACAO
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           --pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
           --                                 ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        vn_fase := 4;
        -- validacao: Valor da Base de ICMS no Total deve ser igual ao Valor Base de ICMS no analitico
        if nvl(rec.vl_bc_icms, 0) <> nvl(gt_row_nota_fiscal_total.vl_base_calc_icms, 0) then
           --
           vn_fase := 4.1;
           --
           gv_mensagem_log := 'O "Vlr da Base de ICMS no Total da Nota Fiscal" ('||gt_row_nota_fiscal_total.vl_base_calc_icms||') '||
                              'está divergente do "Vlr Base de ICMS" ('||rec.vl_bc_icms||') no Analítico da Nota Fiscal.';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => ERRO_DE_VALIDACAO
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        vn_fase := 5;
        -- validacao: Valor do ICMS no Total deve ser igual ao Valor ICMS no analitico
        if nvl(rec.vl_icms, 0) <> nvl(gt_row_nota_fiscal_total.vl_imp_trib_icms, 0) then
           --
           vn_fase := 5.1;
           --
           gv_mensagem_log := 'O "Vlr do ICMS no Total da Nota Fiscal" ('||gt_row_nota_fiscal_total.vl_imp_trib_icms||') está divergente do '||
                              '"Vlr do ICMS" ('||rec.vl_icms||') no Analítico da Nota Fiscal.';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => ERRO_DE_VALIDACAO
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        vn_fase := 6;
        -- validacao: Valor da Base do ICMS-ST no Total deve ser igual ao Valor da Base do ICMS-ST no analitico
        if nvl(rec.vl_bc_icms_st, 0) <> nvl(gt_row_nota_fiscal_total.vl_base_calc_st, 0) then
           --
           vn_fase := 6.1;
           --
           gv_mensagem_log := 'O "Vlr da Base de ICMS-ST no Total da Nota Fiscal" ('||gt_row_nota_fiscal_total.vl_base_calc_st||
                              ') está divergente do "Vlr da Base de ICMS-ST" ('||rec.vl_bc_icms_st||') no Analítico da Nota Fiscal.';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => ERRO_DE_VALIDACAO
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        vn_fase := 7;
        -- validacao: Valor do ICMS-ST no Total deve ser igual ao Valor do ICMS-ST no analítico
        if nvl(rec.vl_icms_st, 0) <> nvl(gt_row_nota_fiscal_total.vl_imp_trib_st, 0) then
           --
           vn_fase := 7.1;
           --
           gv_mensagem_log := 'O "Vlr do ICMS-ST no Total da Nota Fiscal" ('||gt_row_nota_fiscal_total.vl_imp_trib_st||
                              ') está divergente do "Vlr do ICMS-ST" ('||rec.vl_icms_st||') no Analítico da Nota Fiscal.';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => ERRO_DE_VALIDACAO
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
        vn_fase := 8;
        -- validacao: Valor do IPI no Total deve ser igual ao Valor do IPI no analitico
        if nvl(rec.vl_ipi, 0) <> nvl(gt_row_nota_fiscal_total.vl_imp_trib_ipi, 0) then
           --
           vn_fase := 8.1;
           --
           gv_mensagem_log := 'O "Vlr do IPI no Total da Nota Fiscal" ('||gt_row_nota_fiscal_total.vl_imp_trib_ipi||') está divergente do '||
                              '"Vlr do IPI" ('||rec.vl_ipi||') no Analítico da Nota Fiscal.';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => ERRO_DE_VALIDACAO
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
     end loop;
     --
     vn_fase := 9;
     -- informações do analítico das notas fiscais de serviços continuos
     -- Ps.: Essas informações de validacao não podem ser inseridas na na api de Integracao
     -- do analitico pq são validações específicas do tipo de modelo documentos das nf de
     -- serviços continuos.
     for rec2 in c_nf_reg_anal2
     loop
        exit when c_nf_reg_anal2%notfound or(c_nf_reg_anal2%notfound) is null;
        --
        vn_fase := 10;
        -- validacao ICMS para os modelos 06, 28 e 29: Se o Código da Situação tributário estiver entre 30, 40, 41, 50 e 60
        -- o valor da base de cálculo, aliquica e valor do icms deverá ser igual a zero.
        if gv_cod_mod in ('06', '28', '29') and
           pk_csf.fkg_Cod_ST_cod(en_id_st => rec2.codst_id) in ('30', '40', '41', '50', '60') then
           --
           vn_fase := 11;
           --
           if nvl(rec2.aliq_icms, 0) <> 0 then
              --
              vn_fase := 11.1;
              --
              gv_mensagem_log := 'A "Alíquota do ICMS" ('||rec2.aliq_icms||') não deverá ser informada para o Código da Situação Tributária '||
                                 pk_csf.fkg_cod_st_cod(en_id_st => rec2.codst_id)||'.';
              --
              vn_loggenerico_id := null;
              --
              pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                            ,ev_mensagem         => gv_cabec_log
                                            ,ev_resumo           => gv_mensagem_log
                                            ,en_tipo_log         => ERRO_DE_VALIDACAO
                                            ,en_referencia_id    => en_notafiscal_id
                                            ,ev_obj_referencia   => gv_obj_referencia);
              --
              -- Armazena o "loggenerico_id" na memoria
              pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                               ,est_log_generico_nf => est_log_generico_nf);
              --
           end if;
           --
           vn_fase := 12;
           --
           if nvl(rec2.vl_bc_icms, 0) <> 0 then
              --
              vn_fase := 12.1;
              --
              gv_mensagem_log := 'A "base de cálculo do ICMS" ('||rec2.vl_bc_icms||') não deverá ser informada para o Código da Situação Tributária '||
                                 pk_csf.fkg_cod_st_cod(en_id_st => rec2.codst_id)||'.';
              --
              vn_loggenerico_id := null;
              --
              pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                            ,ev_mensagem         => gv_cabec_log
                                            ,ev_resumo           => gv_mensagem_log
                                            ,en_tipo_log         => ERRO_DE_VALIDACAO
                                            ,en_referencia_id    => en_notafiscal_id
                                            ,ev_obj_referencia   => gv_obj_referencia);
              --
              -- Armazena o "loggenerico_id" na memoria
              pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                               ,est_log_generico_nf => est_log_generico_nf);
              --
           end if;
           --
           vn_fase := 13;
           --
           if nvl(rec2.vl_icms, 0) <> 0 then
              --
              vn_fase := 13.1;
              --
              gv_mensagem_log := 'O "Valor de ICMS" ('||rec2.vl_icms||') não deverá ser informado para o Código da Situação Tributária '||
                                 pk_csf.fkg_cod_st_cod(en_id_st => rec2.codst_id)||'.';
              --
              vn_loggenerico_id := null;
              --
              pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                            ,ev_mensagem         => gv_cabec_log
                                            ,ev_resumo           => gv_mensagem_log
                                            ,en_tipo_log         => ERRO_DE_VALIDACAO
                                            ,en_referencia_id    => en_notafiscal_id
                                            ,ev_obj_referencia   => gv_obj_referencia);
              --
              -- Armazena o "loggenerico_id" na memoria
              pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                               ,est_log_generico_nf => est_log_generico_nf);
              --
           end if;
           --
        end if;
        --
        --
        vn_fase := 14;
        --  validacao ICMS-ST: Se o Código da Situação tributário estiver entre 10, 30 ou 70
        -- A base de icms-st, aliq_st, valor do icms_st deverão ser maiores que zero.
        if gv_cod_mod in ('06', '28', '29') and 
           pk_csf.fkg_Cod_ST_cod(en_id_st => rec2.codst_id) not in ('10', '30', '70') then
           --
           vn_fase := 15;
           --
           if nvl(rec2.vl_bc_icms_st, 0) <> 0 then
              --
              vn_fase := 15.1;
              --
              gv_mensagem_log := 'A "Base de ICMS-ST" ('||rec2.vl_bc_icms_st||') não deverá ser informada para o Código da Situação Tributária '||
                                 pk_csf.fkg_cod_st_cod(en_id_st => rec2.codst_id)||'.';
              --
              vn_loggenerico_id := null;
              --
              pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                            ,ev_mensagem         => gv_cabec_log
                                            ,ev_resumo           => gv_mensagem_log
                                            ,en_tipo_log         => ERRO_DE_VALIDACAO
                                            ,en_referencia_id    => en_notafiscal_id
                                            ,ev_obj_referencia   => gv_obj_referencia);
              --
              -- Armazena o "loggenerico_id" na memoria
              pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                               ,est_log_generico_nf => est_log_generico_nf);
              --
           end if;
           --
           vn_fase := 16;
           --
           if nvl(rec2.vl_icms_st, 0) < 0 then
              --
              vn_fase := 16.1;
              --
              gv_mensagem_log := 'O "Valor de ICMS-ST" ('||rec2.vl_icms_st||') não deverá ser informado para o Código da Situação Tributária '||
                                 pk_csf.fkg_cod_st_cod(en_id_st => rec2.codst_id)||'.';
              --
              vn_loggenerico_id := null;
              --
              pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                            ,ev_mensagem         => gv_cabec_log
                                            ,ev_resumo           => gv_mensagem_log
                                            ,en_tipo_log         => ERRO_DE_VALIDACAO
                                            ,en_referencia_id    => en_notafiscal_id
                                            ,ev_obj_referencia   => gv_obj_referencia);
              --
              -- Armazena o "loggenerico_id" na memoria
              pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                               ,est_log_generico_nf => est_log_generico_nf);
              --
           end if;
           --
        end if;
        --
        vn_fase := 17;
        -- validacao - Redução da base de cálculo estiver entre 20 e 70
        -- Para todos os modelos documentos
        if pk_csf.fkg_Cod_ST_cod(en_id_st => rec2.codst_id) in ('20', '70') then
           --
           vn_fase := 18;
           --
           if nvl(rec2.vl_red_bc_icms, 0) <= 0 then
              --
              vn_fase := 18.1;
              --
              gv_mensagem_log := 'O "Valor de Redução da Base de ICMS" ('||rec2.vl_red_bc_icms||') deverá ser maior que zero '||
                                 'quando o Código da Situação Tributária estiver entre 20 e 70.';
              --
              vn_loggenerico_id := null;
              --
              pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                            ,ev_mensagem         => gv_cabec_log
                                            ,ev_resumo           => gv_mensagem_log
                                            ,en_tipo_log         => ERRO_DE_VALIDACAO
                                            ,en_referencia_id    => en_notafiscal_id
                                            ,ev_obj_referencia   => gv_obj_referencia);
              --
              -- Armazena o "loggenerico_id" na memoria
              pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                               ,est_log_generico_nf => est_log_generico_nf);
              --
           end if;
           --
        end if;
        --
     end loop;
     --
  end if;
  --
exception
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_valida_nf_reg_anal fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%TYPE;
     begin
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                      ,ev_mensagem         => gv_cabec_log
                                      ,ev_resumo           => gv_mensagem_log
                                      ,en_tipo_log         => ERRO_DE_SISTEMA
                                      ,en_referencia_id    => en_notafiscal_id
                                      ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                         ,est_log_generico_nf => est_log_generico_nf);
        --
     exception
        when others then
           null;
     end;
     --
end pkb_valida_nf_reg_anal;

-------------------------------------------------------------------------------------------------------
--| Procedimento valida informação de notas fiscais de serviço
procedure pkb_valida_nota_fiscal_sc(est_log_generico_nf in out nocopy dbms_sql.number_table,
                                    en_notafiscal_id    in Nota_Fiscal.Id%TYPE) is
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%TYPE;
  --
  cursor c_nota_fiscal_sc is
    select * 
      from nota_fiscal 
     where id = en_notafiscal_id;
  --
begin
  --
  vn_fase := 1;
  --
  if nvl(en_notafiscal_id, 0) > 0 then
    --
    vn_fase := 2;
    --
    -- informações das notas fiscais de serviços contínuos
    -- Ps.: Essas validações não foram inseridas na api de Integracao pq são validações são
    -- exclusivas para o modelo documentos das nf de serviços contínuos.
    for rec in c_nota_fiscal_sc loop
      exit when c_nota_fiscal_sc%notfound or(c_nota_fiscal_sc%notfound) is null;
      --
      vn_fase := 3;
      --
      -- Validacao: Os Códigos válidos para modelo documento são: 06, 08 e 29 nos serviços contínuos.
      if gv_cod_mod not in ('06', '21', '22', '28', '29', '66') then
        --
        vn_fase := 3.1;
        --
        gv_mensagem_log := 'O "Código do Modelo Documento" (' || pk_csf.fkg_cod_mod_id(en_modfiscal_id => rec.modfiscal_id) || ') está inválido para Notas Fiscais de Serviço Contínuo.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
      vn_fase := 4;
      --
      -- validacao: O Código da Situação do documento deve estar entre: 00, 01, 02, 03, 06, 07, 08 nos servicços contínuos
      -- para os codigos modelos documentos 06, 28 e 29.
      if gv_cod_mod in ('06', '28', '29') and pk_csf.fkg_Sit_Docto_cd(en_sitdoc_id => rec.sitdocto_id) not in ('00', '01', '02', '03', '06', '07', '08') then
        --
        vn_fase := 4.1;
        --
        gv_mensagem_log := 'O "Cód. da Sit. do Documento" (' || pk_csf.fkg_Sit_Docto_cd(en_sitdoc_id => rec.sitdocto_id) || ') está inválido p/ NF de Serviços Contínuos de modelo documentos: 06, 28 e 29.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
      vn_fase := 5;
      --
      -- validacao: O Código da Situação do documento deve estar entra: 00, 01, 02, 03, 06, 07, 08 nos servicços contínuos.
      -- Para os modelos documentos de Código 21 e 22
      if gv_cod_mod in ('21', '22') and pk_csf.fkg_Sit_Docto_cd(en_sitdoc_id => rec.sitdocto_id) not in ('00', '01', '02', '03', '08') then
        --
        vn_fase := 5.1;
        --
        gv_mensagem_log := 'O "Cód. da Sit. do Documento" (' || pk_csf.fkg_Sit_Docto_cd(en_sitdoc_id => rec.sitdocto_id) || ') está inválido p/ NF de Serviços Contínuos para modelos documentos: 21 e 22.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
      vn_fase := 6;
      --
      -- Valida apenas se ele foi informado.
      if nvl(rec.codconsitemcont_id, 0) > 0 then
        --
        vn_fase := 6.1;
        --
        -- validacao: Código da Classe de consumo de energia eletrica e gás canalizado.
        -- Valores válidos: 01, 02, 03, 04, 05, 06, 07, 08
        if gv_cod_mod in ('06', '28') and pk_csf_efd.fkg_id_cons_item_cont_cod(en_codconsitemcont_id => rec.codconsitemcont_id) not in ('01', '02', '03', '04', '05', '06', '07', '08') then
          --
          vn_fase := 6.2;
          --
          gv_mensagem_log := 'O "Código de Classe de consumo de energia elétrica ou gás" (' || pk_csf_efd.fkg_id_cons_item_cont_cod(en_codconsitemcont_id => rec.codconsitemcont_id) || ') está inválido para consumo de energia elétrica ou gás.';
          --
          vn_loggenerico_id := null;
          --
          pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                         ev_mensagem         => gv_cabec_log,
                                         ev_resumo           => gv_mensagem_log,
                                         en_tipo_log         => erro_de_validacao,
                                         en_referencia_id    => en_notafiscal_id,
                                         ev_obj_referencia   => gv_obj_referencia);
          --
          -- Armazena o "loggenerico_id" na memoria
          pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                            est_log_generico_nf => est_log_generico_nf);
          --
        end if;
        --
        vn_fase := 7;
        --
        -- validacao: Código da Classe para água canalizada.
        -- Valores válidos: Qualquer Código para o modelo documento 29
        if gv_cod_mod in ('29') and pk_csf_efd.fkg_id_cons_item_cont_cod(en_codconsitemcont_id => rec.codconsitemcont_id) is null then
          --
          vn_fase := 7.1;
          --
          gv_mensagem_log := 'O "Código de Classe de Consumo" (' || pk_csf_efd.fkg_id_cons_item_cont_cod(en_codconsitemcont_id => rec.codconsitemcont_id) || ') está inválido para água canalizada.';
          --
          vn_loggenerico_id := null;
          --
          pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                         ev_mensagem         => gv_cabec_log,
                                         ev_resumo           => gv_mensagem_log,
                                         en_tipo_log         => erro_de_validacao,
                                         en_referencia_id    => en_notafiscal_id,
                                         ev_obj_referencia   => gv_obj_referencia);
          --
          -- Armazena o "loggenerico_id" na memoria
          pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                            est_log_generico_nf => est_log_generico_nf);
          --
        end if;
        --
      end if;
      --
      vn_fase := 8;
      --
      -- validacao: O Código Tipo de Ligação, for informado, nas notas fiscais(saída)
      -- de modelo 06 ele deve seguir: 1 - Monofasico, 2 - Bifásico e 3 - Trifásico
      if gv_cod_mod in ('06') and rec.dm_ind_oper = 1 and nvl(rec.dm_tp_ligacao, 0) not in (1, 2, 3) then
        --
        vn_fase := 8.1;
        --
        gv_mensagem_log := 'O "Código de Tipo de Ligação" (' || rec.dm_tp_ligacao || ') está inválido para Energia Elétrica. Informar 1, 2 ou 3.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
      vn_fase := 9;
      --
      -- validacao: O Código de grupo de tensão, se informado para o modelo documento for 06,
      -- para notas fiscais de sáida, deve estar dentro dos Códigos de tensão citados abaixo.
      if gv_cod_mod in ('06') and rec.dm_ind_oper = 1 and nvl(trim(rec.dm_cod_grupo_tensao), '00') not in ('01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14') then
        --
        vn_fase := 10.1;
        --
        gv_mensagem_log := 'O "Código de Grupo de Tensão" (' || rec.dm_cod_grupo_tensao || ') está inválido para Energia Elétrica. Informar: ' || '"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13" ou "14".';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
      vn_fase := 10;
      --
      -- validacao: O Código Tipo de Assinante, for informado, nas notas fiscais de
      -- modelo 21 e 22 ele deve seguir os Códigos citados abaixo. 
      if gv_cod_mod in ('21', '22') and nvl(rec.dm_tp_assinante, 0) not in (0, 1, 2, 3, 4, 5, 6) then
        --
        vn_fase := 9.1;
        --
        gv_mensagem_log := 'O "Código de Tipo de Assinante" (' || rec.dm_tp_assinante || ') está inválido para Serviço de Comunicação e Telecomunicação. ' || 'Informar 1, 2, 3, 4, 5 ou 6.';
        --
        vn_loggenerico_id := null;
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                       ev_mensagem         => gv_cabec_log,
                                       ev_resumo           => gv_mensagem_log,
                                       en_tipo_log         => erro_de_validacao,
                                       en_referencia_id    => en_notafiscal_id,
                                       ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                          est_log_generico_nf => est_log_generico_nf);
        --
      end if;
      --
    end loop;
    --
  end if;
  --
exception
  when others then
    --
    gv_mensagem_log := 'Erro na pkb_valida_nota_fiscal_sc fase (' || vn_fase || '): ' || sqlerrm;
    --
    declare
      vn_loggenerico_id log_generico_nf.id%TYPE;
    begin
      --
      pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id,
                                     ev_mensagem         => gv_cabec_log,
                                     ev_resumo           => gv_mensagem_log,
                                     en_tipo_log         => erro_de_sistema,
                                     en_referencia_id    => en_notafiscal_id,
                                     ev_obj_referencia   => gv_obj_referencia);
      --
      -- Armazena o "loggenerico_id" na memoria
      pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id,
                                        est_log_generico_nf => est_log_generico_nf);
      --
    exception
      when others then
        null;
    end;
    --
end pkb_valida_nota_fiscal_sc;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Valida CFOP por Participante de NFSe - Validar CFOP por Participante
procedure pkb_valida_cfop_por_part(est_log_generico_nf in out nocopy dbms_sql.number_table
                                 ,en_notafiscal_id    in nota_fiscal.id%type) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  vn_dm_ind_oper    nota_fiscal.dm_ind_oper%type;
  vv_uf_emit        estado.sigla_estado%type;
  vv_uf_dest        estado.sigla_estado%type;
  vn_dummy          number := null;
  --
  -------------------------------------------------------------------------------------------------------
  -- Funcao que retorna se o cfop tem grupo no registro analitico
  -------------------------------------------------------------------------------------------------------
  function fkg_tem_grupo_cfop(en_notafiscal_id in nota_fiscal.id%type
                             ,en_grupo_cfop    in number) return number is
     --
     vn_ret number := 0;
     --
  begin
     --
     begin
        --
        select distinct 1
          into vn_ret
          from nfregist_analit na
              ,cfop            c
         where na.notafiscal_id = en_notafiscal_id
           and c.id = na.cfop_id
           and to_number(substr(c.cd, 1, 1)) <> en_grupo_cfop;
        --
     exception
        when others then
           vn_ret := 0;
     end;
     --
     return vn_ret;
     --
  exception
     when others then
        return 0;
  end fkg_tem_grupo_cfop;

  --
begin
  --
  vn_fase := 1;
  --
  if nvl(en_notafiscal_id, 0) > 0 then
     --
     vn_fase := 2;
     -- Recupera dados da nota e emitente
     begin
        --
        select nf.dm_ind_oper
              ,est.sigla_estado
          into vn_dm_ind_oper
              ,vv_uf_emit
          from nota_fiscal nf
              ,empresa     e
              ,pessoa      p
              ,cidade      cid
              ,estado      est
         where nf.id = en_notafiscal_id
           and e.id = nf.empresa_id
           and p.id = e.pessoa_id
           and cid.id = p.cidade_id
           and est.id = cid.estado_id;
        --
     exception
        when others then
           vn_dm_ind_oper := null;
           vv_uf_emit     := null;
     end;
     --
     vn_fase := 3;
     --
     -- Recupera dados do local de entrega da mercadoria
     begin
        --
        select est.sigla_estado
          into vv_uf_dest
          from nota_fiscal nf
              ,pessoa      p
              ,cidade      cid
              ,estado      est
         where nf.id = en_notafiscal_id
           and p.id = nf.pessoa_id
           and cid.id = p.cidade_id
           and est.id = cid.estado_id;
        --
     exception
        when others then
           vv_uf_dest := null;
     end;
     --
     vn_fase := 5;
     --
     if vn_dm_ind_oper in (0, 1) and 
        vv_uf_emit is not null and
        vv_uf_dest is not null then
        --
        vn_fase := 6;
        -- Verifica se a nota fiscal foi emitida dentro do estado
        if vv_uf_emit = vv_uf_dest then
           --
           vn_fase := 7;
           -- Se for entrada informar grupo 1 senão grupo 5
           vn_dummy := fkg_tem_grupo_cfop(en_notafiscal_id => en_notafiscal_id
                                         ,en_grupo_cfop    => case
                                                                 when vn_dm_ind_oper = 0 then
                                                                  1
                                                                 else
                                                                  5
                                                              end);
           --
        elsif vv_uf_emit <> vv_uf_dest and vv_uf_dest <> 'EX' then
           --
           vn_fase := 8;
           -- Se for entrada informar grupo 2 senão grupo 6
           vn_dummy := fkg_tem_grupo_cfop(en_notafiscal_id => en_notafiscal_id
                                         ,en_grupo_cfop    => case
                                                                 when vn_dm_ind_oper = 0 then
                                                                  2
                                                                 else
                                                                  6
                                                              end);
           --
        elsif vv_uf_dest = 'EX' then
           --
           vn_fase := 9;
           -- Se for entrada informar grupo 3 senão grupo 7
           vn_dummy := fkg_tem_grupo_cfop(en_notafiscal_id => en_notafiscal_id
                                         ,en_grupo_cfop    => case
                                                                 when vn_dm_ind_oper = 0 then
                                                                  3
                                                                 else
                                                                  7
                                                              end);
           --
        end if;
        --
        vn_fase := 10;
        --
        if nvl(vn_dummy, 0) > 0 then
           --
           vn_fase := 11;
           --
           gv_mensagem_log := 'CFOP informado no registro analítico está divergente para o participante da Nota Fiscal de Serviço Contínuo.';
           --
           vn_loggenerico_id := null;
           --
           pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                         ,ev_mensagem         => gv_cabec_log
                                         ,ev_resumo           => gv_mensagem_log
                                         ,en_tipo_log         => erro_de_validacao
                                         ,en_referencia_id    => en_notafiscal_id
                                         ,ev_obj_referencia   => gv_obj_referencia);
           --
           -- Armazena o "loggenerico_id" na memoria
           pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
           --
        end if;
        --
     end if;
     --
  end if;
  --
exception
  when others then
     --
     rollback;
     --
     gv_mensagem_log := 'Erro na pk_int_view_sc.pkb_valida_cfop_por_part fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                      ,ev_mensagem         => gv_cabec_log
                                      ,ev_resumo           => gv_mensagem_log
                                      ,en_tipo_log         => ERRO_DE_SISTEMA
                                      ,en_referencia_id    => en_notafiscal_id
                                      ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                         ,est_log_generico_nf => est_log_generico_nf);
        --
     exception
        when others then
           null;
     end;
     --
end pkb_valida_cfop_por_part;

-------------------------------------------------------------------------------------
-- Procedimento realiza a criação de registro analitico de impostos da Nota Fiscal --
-------------------------------------------------------------------------------------
PROCEDURE PKB_GERA_REGIST_ANALIT_IMP ( EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                 , EN_NOTAFISCAL_ID IN            NOTA_FISCAL.ID%TYPE ) IS
--
vn_fase            number := 0;
vn_tipo_integr     number;
vn_loggenerico_id  log_generico_nf.id%type;
vv_cod_st          cod_st.cod_st%type;
vn_cfop_cd         cfop.cd%type;
vn_vl_icms_deson   number;
--
vn_NfregistAnalit_id   Nfregist_Analit.ID%type; --#68345
vn_qtd_item            number; --#68345
--
cursor c_item is
select icms.codst_id
    , inf.cfop_id
    , c.cd cfop
    , inf.orig
    , case 
         when c.cd in (1551, 1556, 5929, 6929, 3551, 3949, 5602, 6602, 3556) then
            0
         else icms.aliq_apli 
      end aliq_icms
    , sum(nvl(inf.vl_item_bruto,0)) vl_item_bruto
    , sum(nvl(inf.vl_frete,0)) vl_frete
    , sum(nvl(inf.vl_seguro,0)) vl_seguro
    , sum(nvl(inf.vl_outro,0)) vl_outro
    , sum(nvl(inf.vl_desc,0)) vl_desc
    , sum( case
           when c.cd in (1551, 1556, 5929, 6929, 3551, 3949, 5602, 6602, 3556) then
              0
           when nvl(inf.DM_MOT_DES_ICMS,0) > 0 then
              0
           when cst.cod_st = '51'
              and nvl(icms.vl_base_calc,0) > 0
              and nvl(icms.vl_imp_trib,0) = 0
              then 0
           else nvl(icms.vl_base_calc,0)
           end ) vl_bc_icms
    , sum( case
           when c.cd in (1551, 1556, 5929, 6929, 3551, 3949, 5602, 6602, 3556) then
              0
           when nvl(inf.DM_MOT_DES_ICMS,0) > 0 then
              0
           else nvl(icms.vl_imp_trib,0)
           end ) vl_icms
    , sum( case
             when c.cd in (1551, 1556, 5929, 6929, 3551, 3949, 5602, 6602, 3556) then
                0
             when nvl(icms.perc_reduc,0) > 0 then
               nvl(inf.vl_item_bruto,0) - nvl(icms.vl_base_calc,0)
             else 0
             end
          ) vl_red_bc_icms
 from item_nota_fiscal inf
    , imp_itemnf       icms
    , tipo_imposto     ti
    , cod_st           cst
    , cfop             c
where inf.notafiscal_id = en_notafiscal_id
  and icms.itemnf_id    = inf.id
  and ti.id             = icms.tipoimp_id
  and ti.cd             in (1, 10) -- icms e Simples Nacional
  and cst.id            = icms.codst_id
  and c.id              = inf.cfop_id
group by icms.codst_id
    , inf.cfop_id
    , c.cd
    , inf.orig
    , case
         when c.cd in (1551, 1556, 5929, 6929, 3551, 3949, 5602, 6602, 3556) then
            0
         else icms.aliq_apli 
      end;
--
BEGIN
--
   vn_fase := 1;
   --
   --#68345
   begin
     select count(inf.id)
       into vn_qtd_item
       from item_nota_fiscal inf
          , imp_itemnf       imp
      where notafiscal_id   = en_notafiscal_id
       and imp.itemnf_id    = inf.id ;
   exception
   when others then  
       vn_qtd_item :=0;
   end;
   --
   vn_fase := 1.1;
   --
   if nvl(vn_qtd_item,0) = 0 then
     --#68345 caso não tenha item na nota fiscal, esta procedure naõ deve ser executada
     --
      gv_mensagem_log := 'Não foi recalculado o registro analítico.('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                             , ev_mensagem         => gv_mensagem_log
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => INFORMACAO
                             , en_referencia_id    => EN_NOTAFISCAL_ID
                             , ev_obj_referencia   => gv_obj_referencia );
      exception
         when others then
            null;
      end;
   else
    --
    begin
      select a.id
        into vn_NfregistAnalit_id
        from nfregist_analit a 
       where a.notafiscal_id = en_notafiscal_id;
    exception
    when others then  
        vn_NfregistAnalit_id := NULL;
    end;   
    --
    if vn_NfregistAnalit_id IS NOT NULL then 
      -- remove os registros antigos
      delete from nfregist_analit_difal
       where nfregistanalit_id = vn_NfregistAnalit_id;       
    -- 
    end if;
    --
vn_fase := 2;
-- remove os registros antigos
delete from nfregist_analit
where notafiscal_id = en_notafiscal_id;
--
vn_fase := 3;
-- Armazena o tipo de integração.
vn_tipo_integr := nvl(gn_tipo_integr,0);
--
vn_fase := 4;
-- Força integrar as informações do analítico pois elas foram excluídas
gn_tipo_integr := 1;
--
for rec in c_item
loop
  --
  exit when c_item%notfound or (c_item%notfound) is null;
  --
  vn_fase := 5;
  --
  gt_row_nfregist_analit := null;
  --
  vn_fase := 5.1;
--
  gt_row_nfregist_analit.notafiscal_id   := en_notafiscal_id;
  gt_row_nfregist_analit.codst_id        := rec.codst_id;
  gt_row_nfregist_analit.cfop_id         := rec.cfop_id;
  gt_row_nfregist_analit.aliq_icms       := rec.aliq_icms;
  gt_row_nfregist_analit.vl_bc_icms      := rec.vl_bc_icms;
  gt_row_nfregist_analit.vl_icms         := rec.vl_icms;
  gt_row_nfregist_analit.vl_red_bc_icms  := rec.vl_red_bc_icms;
  gt_row_nfregist_analit.dm_orig_merc    := rec.orig;
  --
  vn_fase := 5.2;
  -- recupera os valores de ICMS-ST
  begin
     select sum(imp.vl_base_calc)  vl_bc_icms_st
          , sum(imp.vl_imp_trib)   vl_icms_st
       into gt_row_nfregist_analit.vl_bc_icms_st
          , gt_row_nfregist_analit.vl_icms_st
       from item_nota_fiscal inf
          , imp_itemnf       imp_base
          , imp_itemnf       imp
          , tipo_imposto     ti
      where inf.notafiscal_id         = en_notafiscal_id
        and inf.cfop_id               = rec.cfop_id
        and inf.orig                  = rec.orig
        and imp_base.itemnf_id        = inf.id
        and imp_base.codst_id         = rec.codst_id
        and nvl(imp_base.aliq_apli,0) = nvl(rec.aliq_icms,0)
        and imp.itemnf_id             = inf.id
        and ti.id                     = imp.tipoimp_id
        and ti.cd                     = 2; -- icmsst
  exception
     when others then
        gt_row_nfregist_analit.vl_bc_icms_st := 0;
        gt_row_nfregist_analit.vl_icms_st    := 0;
  end;
  --
  vn_fase := 5.3;
  -- recupera os valores de IPI para gerar o valor da operação
  begin
     select sum(imp.vl_imp_trib)   vl_ipi
       into gt_row_nfregist_analit.vl_ipi
       from item_nota_fiscal inf
          , imp_itemnf       imp_base
          , imp_itemnf       imp
          , tipo_imposto     ti
      where inf.notafiscal_id         = en_notafiscal_id
        and inf.cfop_id               = rec.cfop_id
        and inf.orig                  = rec.orig
        and imp_base.itemnf_id        = inf.id
        and imp_base.codst_id         = rec.codst_id
        and nvl(imp_base.aliq_apli,0) = nvl(rec.aliq_icms,0)
        and imp.itemnf_id             = inf.id
        and ti.id                     = imp.tipoimp_id
        and ti.cd                     = 3; -- IPI
  exception
     when others then
        gt_row_nfregist_analit.vl_ipi := 0;
  end;
  --
  vn_fase := 5.4;
  --
  if rec.cfop not in (5929, 6929, 5602, 6602) then
     --
     begin
        --
        select sum(vl_icms_deson)
          into vn_vl_icms_deson
          from imp_itemnf imp
             , item_nota_fiscal inf
             , tipo_imposto ti
             , cod_st cs
         where inf.notafiscal_id    = en_notafiscal_id
           and inf.cfop_id          = rec.cfop_id
           and inf.orig             = rec.orig
           and imp.itemnf_id        = inf.id
           and imp.dm_tipo          = 0 -- 0-imposto
           and imp.codst_id         = rec.codst_id
           and nvl(imp.aliq_apli,0) = nvl(rec.aliq_icms,0)
           and imp.tipoimp_id       = ti.id
           and ti.cd                = 1
           and imp.codst_id         = cs.id
           and cs.cod_st in ('20', '30', '40', '41', '50', '70', '90'); -- ICMS
        --
     exception
        when others then
        --
        vn_vl_icms_deson := 0;
        --
     end;
     --
     gt_row_nfregist_analit.vl_operacao := round( (nvl(rec.vl_item_bruto,0) - nvl(rec.vl_desc,0) - nvl(vn_vl_icms_deson,0) )
                                               + nvl(rec.vl_frete,0)
                                               + nvl(rec.vl_seguro,0)
                                               + nvl(rec.vl_outro,0)
                                               + nvl(gt_row_nfregist_analit.vl_icms_st,0)
                                               + nvl(gt_row_nfregist_analit.vl_ipi,0)
                                               , 2);
     --
  else
     --
     gt_row_nfregist_analit.vl_operacao := 0;
     --
  end if;
  --
  vn_fase := 5.5;
  -- recupera os valores de IPI de acordo com CST e CFOP
  -- vv_cod_st_ipi in ('49','99') -> vn_vl_ipi := 0; -- Trata o 49 como IPI não recuperado, 99 como Outro IPI
  begin
     select nvl(sum(decode(cs.cod_st, '49', 0
                                    , '99', 0
                                          , nvl(imp.vl_imp_trib,0)
                                    )),0)
       into gt_row_nfregist_analit.vl_ipi
       from item_nota_fiscal inf
          , imp_itemnf       imp_base
          , imp_itemnf       imp
          , tipo_imposto     ti
          , cod_st           cs
          , cfop             cf
      where inf.notafiscal_id         = en_notafiscal_id
        and inf.cfop_id               = rec.cfop_id
        and inf.orig                  = rec.orig
        and inf.cfop             not in (1551, 1556, 5929, 6929, 3551, 3949, 5602, 6602, 3556)
        and imp_base.itemnf_id        = inf.id
        and imp_base.codst_id         = rec.codst_id
        and nvl(imp_base.aliq_apli,0) = nvl(rec.aliq_icms,0)
        and imp.itemnf_id             = inf.id
        and ti.id                     = imp.tipoimp_id
        and ti.cd                     = 3 -- IPI
        and cs.id                     = imp.codst_id
        and cf.id                     = inf.cfop_id;
  exception
     when others then
        gt_row_nfregist_analit.vl_ipi := 0;
  end;
  --
  vn_fase := 5.6;
  --
  vv_cod_st := pk_csf.fkg_cod_st_cod ( en_id_st => rec.codst_id );
  --
  vn_fase := 5.7;
  --
  vn_cfop_cd := pk_csf.fkg_cfop_cd ( en_cfop_id => rec.cfop_id );
  --
  vn_fase := 5.8;
  --
  pkb_integr_nfregist_analit ( est_log_generico_nf     => est_log_generico_nf
                             , est_row_nfregist_analit => gt_row_nfregist_analit
                             , ev_cod_st               => vv_cod_st
                             , en_cfop                 => vn_cfop_cd
                             , ev_cod_obs              => null
                             , en_multorg_id           => pk_csf.fkg_multorg_id_empresa(en_empresa_id => pk_csf.fkg_busca_empresa_nf(en_notafiscal_id => en_notafiscal_id)) );
  --
end loop;
--
vn_fase := 6;
-- Retorna o tipo de integração inicial
gn_tipo_integr := nvl(vn_tipo_integr,0);
--
  end if;
  --
EXCEPTION
when others then
  --
  rollback;
  --
  gv_mensagem_log := 'Erro na pkb_gera_regist_analit_imp fase('||vn_fase||'): '||sqlerrm;
  --
  declare
     vn_loggenerico_id  log_generico_nf.id%type;
  begin
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                      , ev_mensagem        => gv_cabec_log
                      , ev_resumo          => gv_mensagem_log
                      , en_tipo_log        => erro_de_validacao
                      , en_referencia_id   => gn_referencia_id
                      , ev_obj_referencia  => gv_obj_referencia );
     -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                         , est_log_generico_nf  => est_log_generico_nf );
     --
  exception
     when others then
        null;
  end;
  --
END PKB_GERA_REGIST_ANALIT_IMP;

--------------------------------------------
-- Procedimento de Ajuste do total da NFe --
--------------------------------------------
PROCEDURE PKB_AJUSTA_TOTAL_NF ( EN_NOTAFISCAL_ID IN NOTA_FISCAL.ID%TYPE ) IS
--
vn_fase                   number := 0;
vn_loggenerico_id         log_generico_nf.id%type;
vt_log_generico_nf           dbms_sql.number_table;
vn_qtde_total             number;
--
vn_dm_ind_emit            nota_fiscal.dm_ind_emit%type;
--
vn_vl_base_calc_icms      nota_fiscal_total.vl_base_calc_icms%type := 0;
vn_vl_imp_trib_icms       nota_fiscal_total.vl_imp_trib_icms%type := 0;
vn_vl_base_calc_st        nota_fiscal_total.vl_base_calc_st%type := 0;
vn_vl_imp_trib_st         nota_fiscal_total.vl_imp_trib_st%type := 0;
vn_vl_total_item          nota_fiscal_total.vl_total_item%type := 0;
vn_vl_frete               nota_fiscal_total.vl_frete%type := 0;
vn_vl_seguro              nota_fiscal_total.vl_seguro%type := 0;
vn_vl_desconto            nota_fiscal_total.vl_desconto%type := 0;
vn_vl_imp_trib_ii         nota_fiscal_total.vl_imp_trib_ii%type := 0;
vn_qtde_imp_trib_ii       number := 0;
vn_vl_imp_trib_ipi        nota_fiscal_total.vl_imp_trib_ipi%type := 0;
vn_vl_imp_trib_pis        nota_fiscal_total.vl_imp_trib_pis%type := 0;
vn_vl_imp_trib_cofins     nota_fiscal_total.vl_imp_trib_cofins%type := 0;
vn_vl_outra_despesas      nota_fiscal_total.vl_outra_despesas%type := 0;
vn_vl_total_nf            nota_fiscal_total.vl_total_nf%type := 0;
vn_vl_serv_nao_trib       nota_fiscal_total.vl_serv_nao_trib%type := 0;
vn_vl_base_calc_iss       nota_fiscal_total.vl_base_calc_iss%type := 0;
vn_vl_imp_trib_iss        nota_fiscal_total.vl_imp_trib_iss%type := 0;
vn_vl_pis_iss             nota_fiscal_total.vl_pis_iss%type := 0;
vn_vl_cofins_iss          nota_fiscal_total.vl_cofins_iss%type := 0;
vn_vl_total_serv          nota_fiscal_total.vl_total_serv%type := 0;
vn_vl_tot_trib            nota_fiscal_total.vl_tot_trib%type := 0;
vn_vl_icms_deson          nota_fiscal_total.vl_icms_deson%type := 0;
vn_vl_deducao             nota_fiscal_total.vl_deducao%type := 0;
vn_vl_desc_incond         nota_fiscal_total.vl_desc_incond%type := 0;
vn_vl_desc_cond           nota_fiscal_total.vl_desc_cond%type := 0;
vn_vl_outras_ret          nota_fiscal_total.vl_outras_ret%type := 0;
vn_vl_ret_iss             nota_fiscal_total.vl_ret_iss%type := 0;
vn_vl_ret_pis             nota_fiscal_total.vl_ret_pis%type := 0;
vn_vl_ret_cofins          nota_fiscal_total.vl_ret_cofins%type := 0;
vn_vl_ret_csll            nota_fiscal_total.vl_ret_csll%type := 0;
vn_vl_ret_irrf            nota_fiscal_total.vl_ret_irrf%type := 0;
vn_vl_base_calc_ret_prev  nota_fiscal_total.vl_base_calc_ret_prev%type := 0;
vn_vl_ret_prev            nota_fiscal_total.vl_ret_prev%type := 0;
vn_vl_pis_st              nota_fiscal_total.vl_pis_st%type := 0;
vn_vl_cofins_st           nota_fiscal_total.vl_cofins_st %type := 0;
--
vn_empresa_id             empresa.id%type;
vn_dm_ajusta_total_nf     empresa.dm_ajusta_total_nf%type := 0;
vn_qtde_cfop_3_7          number;
vn_NfregistAnalit_id      Nfregist_Analit.id%type;
--
BEGIN
--
vn_fase := 1;
--
if nvl(en_notafiscal_id,0) > 0 then
  --
  vn_fase := 2;
  --
  vn_empresa_id := pk_csf.fkg_empresa_notafiscal ( en_notafiscal_id => en_notafiscal_id );
  --
  vn_fase := 3;
  vn_dm_ajusta_total_nf := pk_csf.fkg_ajustatotalnf_empresa ( en_empresa_id => vn_empresa_id );
  --
  vn_fase := 4;
  --
  begin
     select count(1)
       into vn_qtde_cfop_3_7
       from item_nota_fiscal inf
      where notafiscal_id        = en_notafiscal_id
        and substr(inf.cfop,1,1) in (3, 7);
  exception
     when others then
        vn_qtde_cfop_3_7 := 0;
  end;
  --
  vn_fase := 5;
  --
  if nvl(vn_dm_ajusta_total_nf,0) <> 1 or
     nvl(vn_qtde_cfop_3_7,0) > 0 then   
	 --
	 goto sair_ajusta;
     --
  end if;  
  --  
  vn_fase := 6;
  --  
  -- verifica se existe a informação do total, caso não existir cria a linha em branco
  begin
     select count(1)
       into vn_qtde_total
       from nota_fiscal_total
      where notafiscal_id = en_notafiscal_id;
  exception
     when others then
        vn_qtde_total := 0;
  end;
  --
  vn_fase := 7;
  --
  if nvl(vn_qtde_total,0) <= 0 then
     --
     vn_fase := 7.1;
     --
     -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (carrega)
     pk_csf_api.gv_objeto := 'pk_csf_api_sc.PKB_AJUSTA_TOTAL_NF';
     pk_csf_api.gn_fase   := vn_fase;
     --
     insert into nota_fiscal_total ( ID
                                   , notafiscal_id
                                   )
                            values ( notafiscaltotal_seq.nextval -- ID
                                   , en_notafiscal_id
                                   );
     --
     -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (limpa)
     pk_csf_api.gv_objeto := null;
     pk_csf_api.gn_fase   := null;
     --
  end if;
  --
  vn_fase := 7.2;
  --
  begin
     --
     select dm_ind_emit
       into vn_dm_ind_emit
       from nota_fiscal
      where id = en_notafiscal_id;
     --
  exception
     when others then
        vn_dm_ind_emit := 0;
  end;
  --
  vn_fase := 7.3;
  --
  if vn_dm_ind_emit = 0 then -- Emissão Propria
     --
     vn_fase := 8;
     -- soma valores do item da nota fiscal
     begin
        select round(sum(inf.vl_item_bruto), 2)
             , sum(inf.vl_frete)
             , sum(inf.vl_seguro)
             , sum(inf.vl_desc)
             , sum(inf.vl_outro)
             , sum(inf.vl_tot_trib_item)
          into vn_vl_total_item
             , vn_vl_frete
             , vn_vl_seguro
             , vn_vl_desconto
             , vn_vl_outra_despesas
             , vn_vl_tot_trib
          from item_nota_fiscal inf
         where inf.notafiscal_id  = en_notafiscal_id;
           --and inf.cd_lista_serv is null;
     exception
        when others then
           vn_vl_total_item := 0;
           vn_vl_frete := 0;
           vn_vl_seguro := 0;
           vn_vl_desconto := 0;
           vn_vl_outra_despesas := 0;
           vn_vl_tot_trib := 0;
     end;
     --
     vn_fase := 9;
     --
     if nvl(gt_row_nota_fiscal_emit.dm_reg_trib, 0) <> 1 then
        -- Soma valores do ICMS
        begin
           select sum(imp.vl_base_calc)
                , sum(imp.vl_imp_trib)
             into vn_vl_base_calc_icms
                , vn_vl_imp_trib_icms
             from item_nota_fiscal  inf
                , imp_itemnf        imp
                , tipo_imposto      ti
                , cod_st            cst
            where inf.notafiscal_id  = en_notafiscal_id
              and imp.itemnf_id      = inf.id
              and imp.dm_tipo        = 0 -- 0-imposto, 1-retenção
              and ti.id              = imp.tipoimp_id
              and ti.cd              = 1 -- ICMS
              and cst.id             = imp.codst_id
              and cst.cod_st not in ('30', '40', '41', '50', '60');
        exception
           when others then
             vn_vl_base_calc_icms := 0;
              vn_vl_imp_trib_icms := 0;
        end;
        --
     else
        -- Soma valores do ICMS para Simples Nacional
        begin
           select sum(imp.vl_base_calc)
                , sum(imp.vl_imp_trib)
             into vn_vl_base_calc_icms
                , vn_vl_imp_trib_icms
             from item_nota_fiscal  inf
                , imp_itemnf        imp
                , tipo_imposto      ti
            where inf.notafiscal_id  = en_notafiscal_id
              and imp.itemnf_id      = inf.id
              and imp.dm_tipo        = 0 -- 0-imposto, 1-retenção
              and ti.id              = imp.tipoimp_id
              and ti.cd              = 1; -- ICMS
        exception
           when others then
              vn_vl_base_calc_icms := 0;
              vn_vl_imp_trib_icms := 0;
        end;
        --
     end if;
     --
     vn_fase := 10;
     -- soma valores do ICMS-ST
     begin
        select round( sum( decode( nf.dm_ind_emit, 1, nvl(imp_st.vl_base_calc, 0)
                                                    , decode(cst_icms.cod_st, '60', 0, nvl(imp_st.vl_base_calc, 0)) ) ), 2)
             , round( sum( decode( nf.dm_ind_emit, 1, nvl(imp_st.vl_imp_trib, 0)
                                                    , decode(cst_icms.cod_st, '60', 0, nvl(imp_st.vl_imp_trib, 0)) ) ), 2)
          into vn_vl_base_calc_st
             , vn_vl_imp_trib_st
          from nota_fiscal       nf
             , item_nota_fiscal  it
             , imp_itemnf        imp_st
             , tipo_imposto      ti
             , imp_itemnf        imp_icms
             , cod_st            cst_icms
             , tipo_imposto      ti_icms
         where nf.id              = en_notafiscal_id
           and it.notafiscal_id   = nf.id
           and imp_st.itemnf_id   = it.id
           and imp_st.dm_tipo     = 0 -- 0-imposto, 1-retenção
           and ti.id              = imp_st.tipoimp_id
           and ti.cd              = '2' --ICMS_ST
           and imp_icms.itemnf_id = it.id
           and imp_icms.dm_tipo   = 0 -- 0-imposto, 1-retenção
           and cst_icms.id        = imp_icms.codst_id
           and ti_icms.id         = imp_icms.tipoimp_id
           and ti_icms.cd        in ( '1' );
     exception
        when others then
           vn_vl_base_calc_st := 0;
           vn_vl_imp_trib_st := 0;
     end;
     --
     if nvl(vn_vl_base_calc_st,0) <= 0 and
        nvl(vn_vl_imp_trib_st,0) <= 0 then
        --
        begin
           --
           select round(sum(nvl(imp_st.vl_base_calc,0)),2)
                , round(sum(nvl(imp_st.vl_imp_trib,0)),2)
             into vn_vl_base_calc_st
                , vn_vl_imp_trib_st
             from item_nota_fiscal  it
                , imp_itemnf        imp_st
                , tipo_imposto      ti
                , imp_itemnf        imp_icms
                , tipo_imposto      ti_icms
            where it.notafiscal_id  = en_notafiscal_id
              and imp_st.itemnf_id  = it.id
              and imp_st.dm_tipo    = 0 -- 0-imposto, 1-retenção
              and ti.id             = imp_st.tipoimp_id
              and ti.cd             = '2' --ICMS_ST
              and it.id             = imp_icms.itemnf_id
              and imp_icms.dm_tipo  = 0 -- 0-imposto, 1-retenção
              and nvl(imp_icms.codst_id,0) > 0
              and ti_icms.id        = imp_icms.tipoimp_id
              and ti_icms.cd        = '10'; -- Somente Simples Nacional
              --
        exception
           when others then
              vn_vl_base_calc_st    := 0;
              vn_vl_imp_trib_st     := 0;
        end;
        --
     end if;
     --
     vn_fase := 11;
     -- soma valores do II
     begin
        select sum(imp.vl_imp_trib)
          into vn_vl_imp_trib_ii
          from item_nota_fiscal  inf
             , imp_itemnf        imp
             , tipo_imposto      ti
         where inf.notafiscal_id  = en_notafiscal_id
           and imp.itemnf_id      = inf.id
           and imp.dm_tipo        = 0 -- 0-imposto, 1-retenção
           and ti.id              = imp.tipoimp_id
           and ti.cd              = 7; -- II
     exception
        when others then
           vn_vl_imp_trib_ii := 0;
     end;
     --
     vn_fase := 12;
     -- qtde imposto de importação vn_qtde_imp_trib_ii
     begin
        select count(1)
          into vn_qtde_imp_trib_ii
          from item_nota_fiscal  inf
             , imp_itemnf        imp
             , tipo_imposto      ti
         where inf.notafiscal_id  = en_notafiscal_id
           and imp.itemnf_id      = inf.id
           and imp.dm_tipo        = 0 -- 0-imposto, 1-retenção
           and ti.id              = imp.tipoimp_id
           and ti.cd              = 7; -- II
     exception
        when others then
           vn_qtde_imp_trib_ii := 0;
     end;
     --
     vn_fase := 13;
     -- soma valores de IPI
     begin
        select sum(imp.vl_imp_trib)
          into vn_vl_imp_trib_ipi
          from item_nota_fiscal  inf
             , imp_itemnf        imp
             , tipo_imposto      ti
             , cod_st            cst
         where inf.notafiscal_id  = en_notafiscal_id
           and imp.itemnf_id      = inf.id
           and imp.dm_tipo        = 0 -- 0-imposto, 1-retenção
           and ti.id              = imp.tipoimp_id
           and ti.cd              = 3 -- IPI
           and cst.id             = imp.codst_id
           and cst.cod_st not in ('02', '03', '04', '05', '51', '52', '53', '54', '55');
     exception
        when others then
           vn_vl_imp_trib_ipi := 0;
     end;
     --
     vn_fase := 14;
     -- soma valores de PIS
     begin
        select sum(decode(nvl(inf.cd_lista_serv,0), 0, nvl(imp.vl_imp_trib,0), 0)) -- valor de item produto/mercadoria
             , sum(decode(nvl(inf.cd_lista_serv,0), 0, 0, nvl(imp.vl_imp_trib,0))) -- valor de item serviço
          into vn_vl_imp_trib_pis
             , vn_vl_pis_iss
          from item_nota_fiscal  inf
             , imp_itemnf        imp
             , tipo_imposto      ti
             , cod_st            cst
         where inf.notafiscal_id  = en_notafiscal_id
           and imp.itemnf_id      = inf.id
           and imp.dm_tipo        = 0 -- 0-imposto, 1-retenção
           and ti.id              = imp.tipoimp_id
           and ti.cd              = 4 -- PIS
           and cst.id             = imp.codst_id
           and cst.cod_st not in ('04', '05', '06', '07', '08', '09', '70', '71', '72', '73', '74', '75');
     exception
        when others then
           vn_vl_imp_trib_pis := 0;
           vn_vl_pis_iss      := 0;
     end;
     --
     -- soma valores de PIS Retido
     begin
        select sum(imp.vl_imp_trib)
          into vn_vl_ret_pis
          from item_nota_fiscal inf
             , imp_itemnf       imp
             , tipo_imposto     ti
         where inf.notafiscal_id = en_notafiscal_id
           and imp.itemnf_id     = inf.id
           and imp.dm_tipo       = 1 -- 0-imposto, 1-retenção
           and ti.id             = imp.tipoimp_id
           and ti.cd             = 4; -- PIS
     exception
        when others then
           vn_vl_ret_pis := 0;
     end;
     --
     vn_fase := 15;
     -- soma valores de COFINS
     begin
        select sum(decode(nvl(inf.cd_lista_serv,0), 0, nvl(imp.vl_imp_trib,0), 0)) -- valor de item produto/mercadoria
             , sum(decode(nvl(inf.cd_lista_serv,0), 0, 0, nvl(imp.vl_imp_trib,0))) -- valor de item serviço
          into vn_vl_imp_trib_cofins
             , vn_vl_cofins_iss
          from item_nota_fiscal  inf
             , imp_itemnf        imp
             , tipo_imposto      ti
             , cod_st            cst
         where inf.notafiscal_id  = en_notafiscal_id
           and imp.itemnf_id      = inf.id
           and imp.dm_tipo        = 0 -- 0-imposto, 1-retenção
           and ti.id              = imp.tipoimp_id
           and ti.cd              = 5 -- COFINS
           and cst.id             = imp.codst_id
           and cst.cod_st not in ('04', '05', '06', '07', '08', '09', '70', '71', '72', '73', '74', '75');
     exception
        when others then
           vn_vl_imp_trib_cofins := 0;
           vn_vl_cofins_iss      := 0;
     end;
     --
     -- soma valores de COFINS Retido
     begin
        select sum(imp.vl_imp_trib)
          into vn_vl_ret_cofins
          from item_nota_fiscal inf
             , imp_itemnf       imp
             , tipo_imposto     ti
         where inf.notafiscal_id = en_notafiscal_id
           and imp.itemnf_id     = inf.id
           and imp.dm_tipo       = 1 -- 0-imposto, 1-retenção
           and ti.id             = imp.tipoimp_id
           and ti.cd             = 5; -- COFINS
     exception
        when others then
           vn_vl_ret_cofins := 0;
     end;
     --
     vn_fase := 16;
     -- Valor Total dos itens de serviços
     begin
        select round(sum(it.vl_item_bruto), 2)
          into vn_vl_serv_nao_trib
          from item_nota_fiscal  it
         where it.notafiscal_id  = en_notafiscal_id
           and it.cd_lista_serv is not null;
     exception
        when others then
           vn_vl_serv_nao_trib := 0;
     end;
     -- soma valores de ISS
     begin
        select sum(imp.vl_base_calc)
             , sum(imp.vl_imp_trib)
          into vn_vl_base_calc_iss
             , vn_vl_imp_trib_iss
          from item_nota_fiscal inf
             , imp_itemnf       imp
             , tipo_imposto     ti
         where inf.notafiscal_id = en_notafiscal_id
           and imp.itemnf_id     = inf.id
           and imp.dm_tipo       = 0 -- 0-imposto, 1-retenção
           and ti.id             = imp.tipoimp_id
           and ti.cd             = 6; -- ISS
     exception
        when others then
           vn_vl_base_calc_iss := 0;
           vn_vl_imp_trib_iss  := 0;
     end;
     -- soma valores de ISS Retido
     begin
        select sum(imp.vl_imp_trib)
          into vn_vl_ret_iss
          from item_nota_fiscal inf
             , imp_itemnf       imp
             , tipo_imposto     ti
         where inf.notafiscal_id = en_notafiscal_id
           and imp.itemnf_id     = inf.id
           and imp.dm_tipo       = 1 -- 0-imposto, 1-retenção
           and ti.id             = imp.tipoimp_id
           and ti.cd             = 6; -- ISS
     exception
        when others then
           vn_vl_ret_iss := 0;
     end;
     --
     vn_fase := 16.1;
     --
     -- Soma da desoneração do ICMS
     begin
        --
        select sum(vl_icms_deson)
          into vn_vl_icms_deson
          from imp_itemnf imp
             , item_nota_fiscal inf
             , tipo_imposto ti
             , cod_st cs
         where inf.notafiscal_id = en_notafiscal_id
           and inf.id = imp.itemnf_id
           and imp.dm_tipo = 0 -- 0-imposto
           and imp.tipoimp_id = ti.id
           and ti.cd = 1
           and imp.codst_id = cs.id
           and cs.cod_st in ('20', '30', '40', '41', '50', '70', '90'); -- ICMS
        --
     exception
        when others then
           --
           vn_vl_icms_deson := 0;
           --
     end;
     --
     vn_fase := 17;
     -- Soma o total da nota fiscal
     vn_vl_total_nf := ( nvl(vn_vl_total_item,0) - nvl(vn_vl_desconto,0) - nvl(vn_vl_icms_deson,0) )
                       + nvl(vn_vl_imp_trib_st,0)
                       + nvl(vn_vl_frete,0)
                       + nvl(vn_vl_seguro,0)
                       + nvl(vn_vl_outra_despesas,0)
                       + nvl(vn_vl_imp_trib_ii,0)
                       + nvl(vn_vl_imp_trib_ipi,0);
                       --+ nvl(vn_vl_serv_nao_trib,0);
     --
     vn_fase := 18;
     -- soma valores dos itens de serviço da nota fiscal
     begin
        select sum(inf.vl_item_bruto)
          into vn_vl_total_serv
          from item_nota_fiscal inf
         where inf.notafiscal_id  = en_notafiscal_id
           and inf.cd_lista_serv is not null;
     exception
        when others then
           vn_vl_total_serv := 0;
     end;
     --
     vn_fase := 19;
     --
     begin
        --
        select sum(vl_deducao)
             , sum(vl_desc_incondicionado)
             , sum(vl_desc_condicionado)
             , sum(vl_outra_ret)
          into vn_vl_deducao
             , vn_vl_desc_incond
             , vn_vl_desc_cond
             , vn_vl_outras_ret
          from itemnf_compl_serv ics
             , item_nota_fiscal inf
         where inf.notafiscal_id = en_notafiscal_id
           and inf.id = ics.itemnf_id;
        --
     exception
        when others then
           --
           vn_vl_deducao     := 0;
           vn_vl_desc_incond := 0;
           vn_vl_desc_cond   := 0;
           vn_vl_outras_ret  := 0;
           --
     end;
     --
     -- Soma valor do CSLL Retido
     begin
        select sum(imp.vl_imp_trib)
          into vn_vl_ret_csll
          from item_nota_fiscal inf
             , imp_itemnf       imp
             , tipo_imposto     ti
         where inf.notafiscal_id = en_notafiscal_id
           and imp.itemnf_id     = inf.id
           and imp.dm_tipo       = 1 -- 0-imposto, 1-retenção
           and ti.id             = imp.tipoimp_id
           and ti.cd             = 11; -- CSLL
     exception
        when others then
           vn_vl_ret_csll := 0;
     end;
     --
     -- Soma valor do IRRF Retido
     begin
        select sum(imp.vl_imp_trib)
          into vn_vl_ret_irrf
          from item_nota_fiscal inf
             , imp_itemnf       imp
             , tipo_imposto     ti
         where inf.notafiscal_id = en_notafiscal_id
           and imp.itemnf_id     = inf.id
           and imp.dm_tipo       = 1 -- 0-imposto, 1-retenção
           and ti.id             = imp.tipoimp_id
           and ti.cd             = 12; -- IRRF
     exception
        when others then
           vn_vl_ret_irrf := 0;
     end;
     --
     -- Soma valor do INSS Retido
     begin
        select sum(imp.vl_base_calc)
             , sum(imp.vl_imp_trib)
          into vn_vl_base_calc_ret_prev
             , vn_vl_ret_prev
          from item_nota_fiscal inf
             , imp_itemnf       imp
             , tipo_imposto     ti
         where inf.notafiscal_id = en_notafiscal_id
           and imp.itemnf_id     = inf.id
           and imp.dm_tipo       = 1 -- 0-imposto, 1-retenção
           and ti.id             = imp.tipoimp_id
           and ti.cd             = 13; -- INSS
     exception
        when others then
           vn_vl_base_calc_ret_prev := 0;
           vn_vl_ret_prev := 0;
     end;
     --
     vn_fase := 20;
     -- atualiza dados
     -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (carrega)
     pk_csf_api.gv_objeto := 'pk_csf_api_sc.PKB_AJUSTA_TOTAL_NF';
     pk_csf_api.gn_fase   := vn_fase;
     --
     update nota_fiscal_total nt
     set nt.vl_base_calc_icms     = nvl(vn_vl_base_calc_icms,0)
       , nt.vl_imp_trib_icms      = nvl(vn_vl_imp_trib_icms,0)
       , nt.vl_base_calc_st       = nvl(vn_vl_base_calc_st,0)
       , nt.vl_imp_trib_st        = nvl(vn_vl_imp_trib_st,0)
       , nt.vl_total_item         = nvl(vn_vl_total_item,0)
       , nt.vl_frete              = nvl(vn_vl_frete,0)
       , nt.vl_seguro             = nvl(vn_vl_seguro,0)
       , nt.vl_desconto           = nvl(vn_vl_desconto,0)
       , nt.vl_imp_trib_ii        = nvl(vn_vl_imp_trib_ii,0)
       , nt.vl_imp_trib_ipi       = nvl(vn_vl_imp_trib_ipi,0)
       , nt.vl_imp_trib_pis       = nvl(vn_vl_imp_trib_pis,0)
       , nt.vl_imp_trib_cofins    = nvl(vn_vl_imp_trib_cofins,0)
       , nt.vl_outra_despesas     = nvl(vn_vl_outra_despesas,0)
       , nt.vl_total_nf           = nvl(vn_vl_total_nf,0)
       , nt.vl_serv_nao_trib      = nvl(vn_vl_serv_nao_trib,0)
       , nt.vl_base_calc_iss      = nvl(vn_vl_base_calc_iss,0)
       , nt.vl_imp_trib_iss       = nvl(vn_vl_imp_trib_iss,0)
       , nt.vl_pis_iss            = nvl(vn_vl_pis_iss,0)
       , nt.vl_cofins_iss         = nvl(vn_vl_cofins_iss,0)
       , nt.vl_ret_pis            = nvl(vn_vl_ret_pis,0)
       , nt.vl_ret_cofins         = nvl(vn_vl_ret_cofins,0)
       , nt.vl_ret_csll           = nvl(vn_vl_ret_csll,0)
       , nt.vl_ret_irrf           = nvl(vn_vl_ret_irrf,0)
       , nt.vl_base_calc_ret_prev = nvl(vn_vl_base_calc_ret_prev,0)
       , nt.vl_ret_prev           = nvl(vn_vl_ret_prev,0)
       , nt.vl_total_serv         = nvl(vn_vl_total_serv,0)
       , nt.vl_ret_iss            = nvl(vn_vl_ret_iss,0)
       , nt.vl_tot_trib           = nvl(vn_vl_tot_trib,0)
       , nt.vl_icms_deson         = nvl(vn_vl_icms_deson,0)
       , nt.vl_deducao            = nvl(vn_vl_deducao, 0)
       , nt.vl_desc_incond        = nvl(vn_vl_desc_incond, 0)
       , nt.vl_desc_cond          = nvl(vn_vl_desc_cond, 0)
       , nt.vl_outras_ret         = nvl(vn_vl_outras_ret, 0)
       , nt.vl_servico            = nvl(vn_vl_total_item,0) -- nvl(vn_vl_total_nf,0)
       , nt.vl_pis_st             = nvl(vn_vl_pis_st,0)
       , nt.vl_cofins_st          = nvl(vn_vl_cofins_st,0)
      where nt.notafiscal_id = en_notafiscal_id;
     --
     -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (limpa)
     pk_csf_api.gv_objeto := null;
     pk_csf_api.gn_fase   := null;
     --
     vn_fase := 20.1;
     --
     gt_row_nota_fiscal_total.vl_base_calc_icms   := vn_vl_base_calc_icms;
     gt_row_nota_fiscal_total.vl_imp_trib_icms    := vn_vl_imp_trib_icms;
     gt_row_nota_fiscal_total.vl_imp_trib_pis     := vn_vl_imp_trib_pis;
     gt_row_nota_fiscal_total.vl_imp_trib_cofins  := vn_vl_imp_trib_cofins;
     gt_row_nota_fiscal_total.vl_total_nf         := vn_vl_total_nf;
     gt_row_nota_fiscal_total.vl_forn             := nvl(vn_vl_total_item,0); -- vn_vl_total_nf;
     gt_row_nota_fiscal_total.vl_terc             := nvl(vn_vl_total_item,0); -- vn_vl_total_nf;
     gt_row_nota_fiscal_total.vl_servico          := nvl(vn_vl_total_item,0); -- vn_vl_total_nf;
     --
     vn_fase := 22;
     --
     vt_log_generico_nf.delete;
     --
     vn_fase := 23;
     --
     pkb_gera_regist_analit_imp ( est_log_generico_nf => vt_log_generico_nf
                                , en_notafiscal_id    => en_notafiscal_id );
else
   --| Terceiros
   vn_fase := 24;
   --
  --
  begin
     --
     select sum(vl_bc_icms)
          , sum(vl_icms)
          , sum(vl_operacao)
       into vn_vl_base_calc_icms
          , vn_vl_imp_trib_icms
          , vn_vl_total_nf
       from nfregist_analit
      where notafiscal_id = en_notafiscal_id;
     --
  exception
     when others then
        vn_vl_base_calc_icms := 0;
        vn_vl_imp_trib_icms  := 0;
        vn_vl_total_nf       := 0;
  end;
  --
  vn_fase := 25;
  --
  begin
     --
     select sum(nvl(vl_item,0)) -- recuperamos do PIS porque teoricamente o valor da COFINS deveria ser o mesmo
          , sum(nvl(vl_pis,0))
       into vn_vl_total_item
          , vn_vl_imp_trib_pis
       from nf_compl_oper_pis
      where notafiscal_id = en_notafiscal_id;
     --
  exception
     when others then
        vn_vl_total_item   := 0;
        vn_vl_imp_trib_pis := 0;
  end;
  --
  vn_fase := 26;
  --
  begin
     --
     select sum(nvl(vl_cofins,0))
       into vn_vl_imp_trib_cofins
       from nf_compl_oper_cofins
      where notafiscal_id = en_notafiscal_id;
     --
  exception
     when others then
        vn_vl_imp_trib_cofins := 0;
  end;
  --
  vn_fase := 27;
  --
  -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (carrega)
  pk_csf_api.gv_objeto := 'pk_csf_api_sc.PKB_AJUSTA_TOTAL_NF';
  pk_csf_api.gn_fase   := vn_fase;
  --
  update nota_fiscal_total set vl_base_calc_icms   = decode( nvl(vn_vl_base_calc_icms,0), 0, vl_base_calc_icms, nvl(vn_vl_base_calc_icms,0) ) 
                             , vl_imp_trib_icms    = decode( nvl(vn_vl_imp_trib_icms,0), 0, vl_imp_trib_icms, nvl(vn_vl_imp_trib_icms,0) )
                             , vl_imp_trib_pis     = vn_vl_imp_trib_pis
                             , vl_imp_trib_cofins  = vn_vl_imp_trib_cofins
                             , vl_total_nf         = decode( nvl(vn_vl_total_nf,0), 0 , vl_total_nf, nvl(vn_vl_total_nf,0) )
                             , vl_forn             = decode( nvl(vn_vl_total_item,0), 0, vl_forn, nvl(vn_vl_total_item,0) )    -- vn_vl_total_nf
                             , vl_terc             = decode( nvl(vn_vl_total_item,0), 0, vl_terc, nvl(vn_vl_total_item,0) )    -- vn_vl_total_nf
                             , vl_servico          = decode( nvl(vn_vl_total_item,0), 0, vl_servico, nvl(vn_vl_total_item,0) ) -- vn_vl_total_nf
   where notafiscal_id = en_notafiscal_id;
  --
  -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_Total_01 (limpa)
  pk_csf_api.gv_objeto := null;
  pk_csf_api.gn_fase   := null;
  --
  gt_row_nota_fiscal_total.vl_base_calc_icms   := vn_vl_base_calc_icms;
  gt_row_nota_fiscal_total.vl_imp_trib_icms    := vn_vl_imp_trib_icms;
  gt_row_nota_fiscal_total.vl_imp_trib_pis     := vn_vl_imp_trib_pis;
  gt_row_nota_fiscal_total.vl_imp_trib_cofins  := vn_vl_imp_trib_cofins;
  gt_row_nota_fiscal_total.vl_total_nf         := vn_vl_total_nf;
  gt_row_nota_fiscal_total.vl_forn             := vn_vl_total_item; -- vn_vl_total_nf;
  gt_row_nota_fiscal_total.vl_terc             := vn_vl_total_item; -- vn_vl_total_nf;
  gt_row_nota_fiscal_total.vl_servico          := vn_vl_total_item; -- vn_vl_total_nf;
  --
  end if;
  --
  <<sair_ajusta>>
  null;
end if;
--
EXCEPTION
   when others then
     --
     rollback;
     --
     gv_mensagem_log := 'Erro na pkb_ajusta_total_nf fase('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id  log_generico_nf.id%type;
     begin
        pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                         , ev_mensagem        => gv_cabec_log
                         , ev_resumo          => gv_mensagem_log
                         , en_tipo_log        => erro_de_validacao
                         , en_referencia_id   => EN_NOTAFISCAL_ID
                         , ev_obj_referencia  => 'NOTA_FISCAL' );
     exception
        when others then
           null;
     end;
     --
END PKB_AJUSTA_TOTAL_NF;

-------------------------------------------------------------------------
-- Procedimento de Ajuste do Total da NF seguindo parâmetro de empresa --
-------------------------------------------------------------------------
PROCEDURE PKB_AJUSTA_TOTAL_NF_EMPRESA ( EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                                  , EN_NOTAFISCAL_ID IN            NOTA_FISCAL.ID%TYPE ) IS
--
vn_fase                number := 0;
vn_loggenerico_id      log_generico_nf.id%type;
vn_empresa_id          empresa.id%type;
vn_dm_ajusta_total_nf  empresa.dm_ajusta_total_nf%type := 0;
vn_qtde_cfop_3_7       number;
--
begin
--
vn_fase := 1;
--
if nvl(en_notafiscal_id,0) > 0 then
  --
  vn_fase := 2;
  vn_empresa_id := pk_csf.fkg_empresa_notafiscal ( en_notafiscal_id => en_notafiscal_id );
  --
  vn_fase := 3;
  vn_dm_ajusta_total_nf := pk_csf.fkg_ajustatotalnf_empresa ( en_empresa_id => vn_empresa_id );
  --
  vn_fase := 4;
  --
  begin
     select count(1)
       into vn_qtde_cfop_3_7
       from item_nota_fiscal inf
      where notafiscal_id        = en_notafiscal_id
        and substr(inf.cfop,1,1) in (3, 7);
  exception
     when others then
        vn_qtde_cfop_3_7 := 0;
  end;
  --
  vn_fase := 5;
  --
  if nvl(vn_dm_ajusta_total_nf,0) = 1 and
     nvl(vn_qtde_cfop_3_7,0) <= 0 then -- Não tem itens de importação e exportação
     -- Ajusta os valores totais da Nota Fiscal
     --
vn_fase := 6;
-- chama processo de ajuste dos dados
pkb_ajusta_total_nf ( en_notafiscal_id => en_notafiscal_id );
--
  end if;
  --
end if;
--
EXCEPTION
when others then
  --
  rollback;
  --
  gv_mensagem_log := 'Erro na pkb_ajusta_total_nf_empresa fase('||vn_fase||'): '||sqlerrm;
  --
  declare
     vn_loggenerico_id  log_generico_nf.id%type;
  begin
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                      , ev_mensagem        => gv_cabec_log
                      , ev_resumo          => gv_mensagem_log
                      , en_tipo_log        => erro_de_validacao
                      , en_referencia_id   => gn_referencia_id
                      , ev_obj_referencia  => gv_obj_referencia );
     -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                         , est_log_generico_nf  => est_log_generico_nf );
  exception
     when others then
        null;
  end;
  --
END PKB_AJUSTA_TOTAL_NF_EMPRESA;

-------------------------------------------------------------------------
-- Procedimento de gerar o HASH de NFSC
PROCEDURE PKB_GERAR_HASH_NFSC ( EST_LOG_GENERICO_NF  IN  OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                          , EN_NOTAFISCAL_ID     IN  NOTA_FISCAL.ID%TYPE
                          )
IS
--
vn_fase              number := 0;
vn_empresa_id        empresa.id%type;
vn_pessoa_id         nota_fiscal.pessoa_id%type;
vv_cnpj              varchar2(14);
vn_nro_nf            nota_fiscal.nro_nf%type;
vn_vl_total_nf       nota_fiscal_total.vl_total_nf%type;
vn_vl_base_calc_icms nota_fiscal_total.vl_base_calc_icms%type;
vn_vl_imp_trib_icms  nota_fiscal_total.vl_imp_trib_icms%type;
vv_hash              nota_fiscal.hash%type;
vv_string            varchar2(255);
--
begin
--
vn_fase := 1;
--
if nvl(en_notafiscal_id,0) > 0 then
  --
  vn_fase := 2;
  --
  begin
     --
     select nf.empresa_id
          , nf.pessoa_id
          , nf.nro_nf
          , nd.cnpj
          , nft.vl_total_nf
          , nft.vl_base_calc_icms
          , nft.vl_imp_trib_icms
       into vn_empresa_id
          , vn_pessoa_id
          , vn_nro_nf
          , vv_cnpj
          , vn_vl_total_nf
          , vn_vl_base_calc_icms
          , vn_vl_imp_trib_icms
       from nota_fiscal       nf
          , nota_fiscal_total nft
          , nota_fiscal_dest  nd
      where nf.id               = en_notafiscal_id
        and nft.notafiscal_id   = nf.id
        and nd.notafiscal_id(+) = nf.id;
     --
  exception
     when others then
        vn_empresa_id        := 0;
        vn_pessoa_id         := 0;
        vv_cnpj              := null;
        vn_nro_nf            := 0;
        vn_vl_total_nf       := 0;
        vn_vl_base_calc_icms := 0;
        vn_vl_imp_trib_icms  := 0;
  end;
  --
  vn_fase := 2.1;
  --
  if vv_cnpj is null then -- não recuperou do destinatário
     vv_cnpj := pk_csf.fkg_cnpjcpf_pessoa_id(en_pessoa_id => vn_pessoa_id); -- recuperar da nota fiscal
  end if;
  --
  vn_fase := 2.2;
  --
  vv_string := lpad(vv_cnpj, 14, '0') || lpad(vn_nro_nf, 9, '0') || lpad( nvl(vn_vl_total_nf,0) * 100 , 12, '0') || lpad( nvl(vn_vl_base_calc_icms,0) * 100 , 12, '0') || lpad( nvl(vn_vl_imp_trib_icms,0) * 100 , 12, '0');
  --
  vn_fase := 2.3;
  --
  vv_hash := pk_csf.fkg_md5(vv_string);
  --
  vn_fase := 2.4;
  --
  update nota_fiscal
     set hash = vv_hash
   where id = en_notafiscal_id;
  --
  vn_fase := 2.5;
  --
  commit;
  --
end if;
--
EXCEPTION
when others then
  --
  rollback;
  --
  gv_mensagem_log := 'Erro na PKB_GERAR_HASH_NFSC fase('||vn_fase||'): '||sqlerrm;
  --
  declare
     vn_loggenerico_id  log_generico_nf.id%type;
  begin
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                      , ev_mensagem        => gv_cabec_log
                      , ev_resumo          => gv_mensagem_log
                      , en_tipo_log        => erro_de_validacao
                      , en_referencia_id   => gn_referencia_id
                      , ev_obj_referencia  => gv_obj_referencia );
     -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                         , est_log_generico_nf  => est_log_generico_nf );
  exception
     when others then
        null;
  end;
  --
END PKB_GERAR_HASH_NFSC;

----------------------------------------------------------------------------------
-- Procedimento para gerar a Informações Complementares de Tributos --
----------------------------------------------------------------------------------
PROCEDURE PKB_GERAR_INFO_TRIB ( EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                          , EN_NOTAFISCAL_ID IN            NOTA_FISCAL.ID%TYPE 
                          )
IS
--
vn_fase              number;
vv_inf_cpl_imp       nota_fiscal.inf_cpl_imp%type;
vv_inf_cpl_imp_item  item_nota_fiscal.inf_cpl_imp_item%type;
vn_dm_gera_tot_trib  empresa.dm_gera_tot_trib%type;
--
vn_vl_tot_trib_fed nota_fiscal_total.vl_tot_trib%type;
vn_vl_tot_trib_est nota_fiscal_total.vl_tot_trib%type;
vn_vl_tot_trib_mun nota_fiscal_total.vl_tot_trib%type;
vn_vl_icms_deson nota_fiscal_total.vl_icms_deson%type;

vn_vl_icms_uf_dest       nota_fiscal_total.vl_icms_uf_dest%type;
vn_vl_icms_uf_remet      nota_fiscal_total.vl_icms_uf_remet%type;
vn_vl_comb_pobr_uf_dest  nota_fiscal_total.vl_comb_pobr_uf_dest%type;

vn_vl_tot_trib_item_fed item_nota_fiscal.vl_tot_trib_item%type;
vn_vl_tot_trib_item_est item_nota_fiscal.vl_tot_trib_item%type;
vn_vl_tot_trib_item_mun item_nota_fiscal.vl_tot_trib_item%type;
vn_vl_icms_deson_item imp_itemnf.vl_icms_deson%type;
--
cursor c_inf is
select inf.*
    , nf.dm_ind_final
    , nf.empresa_id
 from nota_fiscal       nf
    , nota_fiscal_dest  nfd
    , item_nota_fiscal  inf
where nf.id               = en_notafiscal_id
  and nf.dm_ind_emit      = 0
  and nf.dm_arm_nfe_terc  = 0
  and nfd.notafiscal_id   = nf.id
  and inf.notafiscal_id   = nf.id
order by inf.nro_item;
--
begin
--
vn_fase := 1;
--
if nvl(en_notafiscal_id,0) > 0 then
  --
  vn_fase := 2;
  --
  vv_inf_cpl_imp      := null;
  vn_vl_tot_trib_fed  := 0;
  vn_vl_tot_trib_est  := 0;
  vn_vl_tot_trib_mun  := 0;
  vn_vl_icms_deson    := 0;
  --
  vn_fase := 3;
  --
  for rec in c_inf loop
     exit when c_inf%notfound or (c_inf%notfound) is null;
     --
     vn_fase := 4;
     --
     vv_inf_cpl_imp_item := null;
     --
     vn_fase := 2.1;
     --
     vn_dm_gera_tot_trib := pk_csf.fkg_empresa_gera_tot_trib ( en_empresa_id => rec.empresa_id );
     --
     begin
        --
        select sum( case
                      when ti.cd in (3, 4, 5, 7, 11, 12, 13) then
                         nvl(imp.vl_imp_trib,0)
                      else 0
                    end ) -- federal
             , sum( case
                      when ti.cd in (1, 2, 10) then
                         nvl(imp.vl_imp_trib,0)
                      else 0
                    end ) -- estadual
             , sum( case
                      when ti.cd in (6) then
                         nvl(imp.vl_imp_trib,0)
                      else 0
                    end ) -- municipal
             , sum( nvl(imp.vl_icms_deson,0) ) 
          into vn_vl_tot_trib_item_fed
             , vn_vl_tot_trib_item_est
             , vn_vl_tot_trib_item_mun
             , vn_vl_icms_deson_item
          from imp_itemnf imp
             , tipo_imposto ti
         where imp.itemnf_id = rec.id
           and imp.dm_tipo   = 0 -- Imposto
           and ti.id         = imp.tipoimp_id;
        --
     exception
        when others then
           vn_vl_tot_trib_item_fed := 0;
           vn_vl_tot_trib_item_est := 0;
           vn_vl_tot_trib_item_mun := 0;
           vn_vl_icms_deson_item   := 0;
     end;
     --
     vn_fase := 4.1;
     --
     if nvl(vn_vl_tot_trib_item_fed,0) > 0 then
        vv_inf_cpl_imp_item := vv_inf_cpl_imp_item || ' Valor dos Tributos Federais do Item: ' || trim(to_char(vn_vl_tot_trib_item_fed, '999g999g999g990d00'));
     end if;
     --
     if nvl(vn_vl_tot_trib_item_est,0) > 0 then
        vv_inf_cpl_imp_item := vv_inf_cpl_imp_item || ' Valor dos Tributos Estaduais do Item: ' || trim(to_char(vn_vl_tot_trib_item_est, '999g999g999g990d00'));
     end if;
     --
     if nvl(vn_vl_tot_trib_item_mun,0) > 0 then
        vv_inf_cpl_imp_item := vv_inf_cpl_imp_item || ' Valor dos Tributos Municipais do Item: ' || trim(to_char(vn_vl_tot_trib_item_mun, '999g999g999g990d00'));
     end if;
     --
     if nvl(vn_vl_icms_deson_item,0) > 0 then
        vv_inf_cpl_imp_item := vv_inf_cpl_imp_item || ' Valor do ICMS Desonerado do Item: ' || trim(to_char(vn_vl_icms_deson_item, '999g999g999g990d00'));
     end if;
     --
     vn_vl_tot_trib_fed  := nvl(vn_vl_tot_trib_fed,0) + nvl(vn_vl_tot_trib_item_fed,0);
     vn_vl_tot_trib_est  := nvl(vn_vl_tot_trib_est,0) + nvl(vn_vl_tot_trib_item_est,0);
     vn_vl_tot_trib_mun  := nvl(vn_vl_tot_trib_mun,0) + nvl(vn_vl_tot_trib_item_mun,0);
     vn_vl_icms_deson    := nvl(vn_vl_icms_deson,0) + nvl(vn_vl_icms_deson_item,0);
     --
     vn_fase := 4.2;
     --
     vv_inf_cpl_imp_item := trim(vv_inf_cpl_imp_item);
     -- Sim, calcula o Valor Aproximado dos Tributos por item e total da NFe
     if nvl(vn_dm_gera_tot_trib,0) in (1, 2, 3) then
        --
        update item_nota_fiscal set inf_cpl_imp_item = vv_inf_cpl_imp_item
         where id = rec.id;
        --
     end if;
     --
  end loop;
  --
  vn_fase := 5;
  --
  if nvl(vn_vl_tot_trib_fed,0) > 0 then
     vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor dos Tributos Federais: ' || trim(to_char(vn_vl_tot_trib_fed, '999g999g999g990d00'));
  end if;
  --
  if nvl(vn_vl_tot_trib_est,0) > 0 then
     vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor dos Tributos Estaduais: ' || trim(to_char(vn_vl_tot_trib_est, '999g999g999g990d00'));
  end if;
  --
  if nvl(vn_vl_tot_trib_mun,0) > 0 then
     vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor dos Tributos Municipais: ' || trim(to_char(vn_vl_tot_trib_mun, '999g999g999g990d00'));
  end if;
  --
  if nvl(vn_vl_icms_deson,0) > 0 then
     vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor do ICMS Desonerado: ' || trim(to_char(vn_vl_icms_deson, '999g999g999g990d00'));
  end if;
  --
  vn_fase := 6;
  --
  begin
     --
     select vl_icms_uf_dest
          , vl_icms_uf_remet
          , vl_comb_pobr_uf_dest
       into vn_vl_icms_uf_dest
          , vn_vl_icms_uf_remet
          , vn_vl_comb_pobr_uf_dest
       from nota_fiscal_total
      where notafiscal_id = en_notafiscal_id;
     --
  exception
     when others then
        vn_vl_icms_uf_dest       := 0;
        vn_vl_icms_uf_remet      := 0;
        vn_vl_comb_pobr_uf_dest  := 0;
  end;
  --
  vn_fase := 6.1;
  --
  if nvl(vn_vl_icms_uf_dest,0) > 0 then
     vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor total do ICMS de partilha para a UF do destinatário: ' || trim(to_char(vn_vl_icms_uf_dest, '999g999g999g990d00'));
  end if;
  --
  if nvl(vn_vl_icms_uf_remet,0) > 0 then
     vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor total do ICMS de partilha para a UF do remetente: ' || trim(to_char(vn_vl_icms_uf_remet, '999g999g999g990d00'));
  end if;
  --
  if nvl(vn_vl_comb_pobr_uf_dest,0) > 0 then
     vv_inf_cpl_imp := vv_inf_cpl_imp || ' Valor total do ICMS relativo Fundo de Combate a Pobreza (FCP) da UF de destino: ' || trim(to_char(vn_vl_comb_pobr_uf_dest, '999g999g999g990d00'));
  end if;
  --
  vn_fase := 7;
  --
  vv_inf_cpl_imp := trim(vv_inf_cpl_imp);
  --
     if nvl(vn_dm_gera_tot_trib,0) in (1, 2, 3) then
        --
        update nota_fiscal set inf_cpl_imp = vv_inf_cpl_imp
         where id = en_notafiscal_id;
        --
     end if;
  --
  commit;
  --
end if;
--
EXCEPTION
when others then
  --
  rollback;
  --
  gv_mensagem_log := 'Erro na PKB_GERAR_INFO_TRIB fase('||vn_fase||'): '||sqlerrm;
  --
  declare
     vn_loggenerico_id  log_generico_nf.id%type;
  begin
     pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                         , ev_mensagem         => gv_cabec_log
                         , ev_resumo           => gv_mensagem_log
                         , en_tipo_log         => erro_de_validacao
                         , en_referencia_id    => gn_referencia_id
                         , ev_obj_referencia   => gv_obj_referencia );
     -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf ( en_loggenericonf_id => vn_loggenerico_id
                            , est_log_generico_nf => est_log_generico_nf );
  exception
     when others then
        null;
  end;
  --
END PKB_GERAR_INFO_TRIB;

--------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Procedure que consiste os dados das notas fiscais de serviços continuos
procedure pkb_consiste_nfsc(est_log_generico_nf in out nocopy dbms_sql.number_table
                          ,en_notafiscal_id    in Nota_Fiscal.Id%TYPE) is
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%TYPE;
  vn_empresa_id     empresa.id%type;
  vn_dm_ind_emit    nota_fiscal.dm_ind_emit%type;
  --
begin
  --
  vn_fase := 1;
  -- Busca o Código Modelo Documento pois o
  -- layout de Integracao trata dos registros C500 e D500
  Begin
     select m.cod_mod
           ,l.empresa_id
          , l.dm_ind_emit
       into gv_cod_mod
           ,vn_empresa_id
          , vn_dm_ind_emit
       from nota_fiscal l
           ,mod_fiscal  m
      where l.id = en_notafiscal_id
        and l.modfiscal_id = m.id;
  exception
     when others then
        gv_cod_mod    := null;
        vn_empresa_id := 0;
        vn_dm_ind_emit := 0;
  end;
  --
  vn_fase := 1.1;
  --
  begin
     select nt.*
       into gt_row_nota_fiscal_total
       from nota_fiscal_total nt
      where nt.notafiscal_id = en_notafiscal_id;
  exception
     when others then
        gt_row_nota_fiscal_total := null;
  end;
  --
  commit;
  --
  vn_fase := 1.2;
  --
  if vn_dm_ind_emit = 0 then -- Emissão Propria
     --
     pkb_gera_regist_analit_imp ( est_log_generico_nf => est_log_generico_nf
                                , en_notafiscal_id => en_notafiscal_id 
                                );
     --
     -- Procedimento de ajuste de Total da Nota Fiscal
     pkb_ajusta_total_nf_empresa ( est_log_generico_nf => est_log_generico_nf
                                 , en_notafiscal_id => en_notafiscal_id 
                                 );
     --
     commit;
     --
     -- Procedimento de ajuste de Total da Nota Fiscal
     pkb_gerar_hash_nfsc ( est_log_generico_nf => est_log_generico_nf
                         , en_notafiscal_id => en_notafiscal_id
                         );
     --
  else
     --
     -- Procedimento de ajuste de Total da Nota Fiscal
     pkb_ajusta_total_nf_empresa ( est_log_generico_nf => est_log_generico_nf
                                 , en_notafiscal_id => en_notafiscal_id 
                                 );
     --
  end if;
  --
  -- Válida informação do complemento do cofins nas notas fiscais de serviço contínuos
  pkb_val_nf_comp_oper_cofins_sc(est_log_generico_nf => est_log_generico_nf
                                ,en_notafiscal_id    => en_notafiscal_id
                                ,en_empresa_id       => vn_empresa_id);
  --
  vn_fase := 2;
  -- Válida informação do complemento do pis nas notas fiscais de serviço contínuos
  pkb_val_nf_compl_oper_pis_sc(est_log_generico_nf => est_log_generico_nf
                              ,en_notafiscal_id    => en_notafiscal_id
                              ,en_empresa_id       => vn_empresa_id);
  --
  vn_fase := 3;
  -- Válida informação nos totais da nota fiscal de serviço
  pkb_valida_nota_fiscal_total(est_log_generico_nf => est_log_generico_nf
                              ,en_notafiscal_id    => en_notafiscal_id);
  --
  vn_fase := 4;
  -- Válida informação do analitico das notas fiscais de serviço contínuos
  pkb_valida_nf_reg_anal(est_log_generico_nf => est_log_generico_nf
                        ,en_notafiscal_id    => en_notafiscal_id);
  --
  vn_fase := 5;
  -- Válida informação nas notas fiscais de serviço
  pkb_valida_nota_fiscal_sc(est_log_generico_nf => est_log_generico_nf
                           ,en_notafiscal_id    => en_notafiscal_id);
  --
  vn_fase := 6;
  --
  pkb_valida_cfop_por_part(est_log_generico_nf => est_log_generico_nf
                          ,en_notafiscal_id    => en_notafiscal_id);
  --
  vn_fase := 7;
  --
  pkb_gerar_info_trib ( est_log_generico_nf => est_log_generico_nf
                      , en_notafiscal_id    => en_notafiscal_id
                      );
  --
  vn_fase := 8;
  --
  if nvl(est_log_generico_nf.count,0) > 0
     and gv_obj_referencia = 'NOTA_FISCAL'
     then
     --
     vn_fase := 9;
     --
     if fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => en_notafiscal_id ) = 1 then 
        update nota_fiscal nf
           set nf.dm_st_proc = 10
         where nf.id = en_notafiscal_id;
        --
        commit;
        --
     end if;
     --
  end if;
  --
  vn_fase := 10;
  -- Se não contôm erro de validacao, Grava o Log do Conhecimento de Transporte Integrado
  gv_mensagem_log := 'Nota Fiscal integrada';
  --
  if nvl(est_log_generico_nf.count, 0) = 0 then
     --
     gv_mensagem_log := gv_mensagem_log || ' e validada.';
     --
  end if;
  --
  pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                 , ev_mensagem         => gv_mensagem_log
                                 , ev_resumo           => gv_mensagem_log
                                 , en_tipo_log         => NOTA_FISCAL_INTEGRADA
                                 , en_referencia_id    => en_notafiscal_id
                                 , ev_obj_referencia   => 'NOTA_FISCAL'
                                 );
  --
exception
  when others then
     --
     rollback;
     --
     gv_mensagem_log := 'Erro na pkb_consiste_nfsc fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%TYPE;
     begin
        --
        pk_csf_api.pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                                      ,ev_mensagem         => gv_mensagem_log
                                      ,ev_resumo           => gv_mensagem_log
                                      ,en_tipo_log         => ERRO_DE_SISTEMA
                                      ,en_referencia_id    => en_notafiscal_id
                                      ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                         ,est_log_generico_nf => est_log_generico_nf);
        --
     exception
        when others then
           null;
     end;
     --
end pkb_consiste_nfsc;

-------------------------------------------------------------------------------------------------------
-- Procedimento valida o mult org de acordo com o COD e o HASH das tabelas Flex-Field
procedure pkb_val_atrib_multorg(est_log_generico    in out nocopy dbms_sql.number_table
                              ,ev_obj_name         in varchar2
                              ,ev_atributo         in varchar2
                              ,ev_valor            in varchar2
                              ,sv_cod_mult_org     out varchar2
                              ,sv_hash_mult_org    out varchar2
                              ,en_referencia_id    in log_generico_nf.referencia_id%type default null
                              ,ev_obj_referencia   in log_generico_nf.obj_referencia%type default null
                              ) is
  --
  vn_fase             number := 0;
  vn_loggenericonf_id log_generico_nf.id%type;
  vv_mensagem         varchar2(1000) := null;
  vn_dmtipocampo      ff_obj_util_integr.dm_tipo_campo%type;
  vv_hash_mult_org    mult_org.hash%type;
  vv_cod_mult_org     mult_org.cd%type;
  --
begin
  --
  vn_fase := 1;
  --
  gv_mensagem_log := null;
  --
  vn_fase := 2;
  --
  if trim(ev_valor) is null then
     --
     vn_fase := 3;
     --
     gv_mensagem_log := 'Código ou HASH da Mult-Organização (objeto: '|| ev_obj_name ||'):"VALOR" referente ao atributo deve ser informado.';
     --
     vn_loggenericonf_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id
                        ,ev_mensagem         => gv_mensagem_log
                        ,ev_resumo           => gv_cabec_log
                        ,en_tipo_log         => ERRO_DE_VALIDACAO
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenericonf_id
                           ,est_log_generico_nf => est_log_generico);
     --
  end if;
  --
  vn_fase := 4;
  --
  vv_mensagem := pk_csf.fkg_ff_verif_campos(ev_obj_name => ev_obj_name
                                           ,ev_atributo => trim(ev_atributo)
                                           ,ev_valor    => trim(ev_valor));
  --
  vn_fase := 5;
  --
  if vv_mensagem is not null then
     --
     vn_fase := 6;
     --
     gv_mensagem_log := vv_mensagem;
     --
     vn_loggenericonf_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id
                        ,ev_mensagem         => gv_mensagem_log
                        ,ev_resumo           => gv_cabec_log
                        ,en_tipo_log         => ERRO_DE_VALIDACAO
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenericonf_id
                           ,est_log_generico_nf => est_log_generico);
     --
  else
     --
     vn_fase := 7;
     --
     vn_dmtipocampo := pk_csf.fkg_ff_retorna_dmtipocampo(ev_obj_name => ev_obj_name
                                                        ,ev_atributo => trim(ev_atributo));
     --
     vn_fase := 8;
     --
     if trim(ev_valor) is not null then
        --
        vn_fase := 9;
        --
        if vn_dmtipocampo = 2 then
           -- tipo de campo = 0-data, 1-numôrico, 2-caractere
           --
           vn_fase := 10;
           --
           if trim(ev_atributo) = 'COD_MULT_ORG' then
              --
              vn_fase := 11;
              --
              begin
                 vv_cod_mult_org := pk_csf.fkg_ff_ret_vlr_caracter(ev_obj_name => ev_obj_name
                                                                  ,ev_atributo => trim(ev_atributo)
                                                                  ,ev_valor    => trim(ev_valor));
              exception
                 when others then
                    vv_cod_mult_org := null;
              end;
              --
           elsif trim(ev_atributo) = 'HASH_MULT_ORG' then
              --
              vn_fase := 12;
              --
              begin
                 vv_hash_mult_org := pk_csf.fkg_ff_ret_vlr_caracter(ev_obj_name => ev_obj_name
                                                                   ,ev_atributo => trim(ev_atributo)
                                                                   ,ev_valor    => trim(ev_valor));
              exception
                 when others then
                    vv_hash_mult_org := null;
              end;
              --
           end if;
           --
        else
           --
           vn_fase := 13;
           --
           gv_mensagem_log := 'Para o atributo '||ev_atributo||', o VALOR informado não confere com o tipo de campo, deveria ser CARACTERE.';
           --
           vn_loggenericonf_id := null;
           --
           pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id
                              ,ev_mensagem         => gv_mensagem_log
                              ,ev_resumo           => gv_cabec_log
                              ,en_tipo_log         => ERRO_DE_VALIDACAO
                              ,en_referencia_id    => gn_referencia_id
                              ,ev_obj_referencia   => gv_obj_referencia);
           -- Armazena o "loggenerico_id" na memoria
           pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenericonf_id
                                 ,est_log_generico_nf => est_log_generico);
           --
        end if;
        --
     end if;
     --
  end if;
  --
  vn_fase := 14;
  --
  sv_cod_mult_org := vv_cod_mult_org;
  --
  sv_hash_mult_org := vv_hash_mult_org;
  --
exception
  when others then
     --
     gv_mensagem_log := 'Erro na pk_csf_api.pkb_val_atrib_multorg fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenericonf_id log_generico.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id
                           ,ev_mensagem         => gv_mensagem_log
                           ,ev_resumo           => gv_cabec_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenericonf_id
                              ,est_log_generico_nf => est_log_generico);
     exception
        when others then
           null;
     end;
end pkb_val_atrib_multorg;

-------------------------------------------------------------------------------------------------------
procedure pkb_ret_multorg_id(est_log_generico    in out nocopy dbms_sql.number_table
                           ,ev_cod_mult_org     in mult_org.cd%type
                           ,ev_hash_mult_org    in mult_org.hash%type
                           ,sn_multorg_id       in out nocopy mult_org.id%type
                           ,en_referencia_id    in log_generico_nf.referencia_id%type default null
                           ,ev_obj_referencia   in log_generico_nf.obj_referencia%type default null
                           ) is
  vn_fase             number := 0;
  vv_multorg_hash     mult_org.hash%type;
  vn_multorg_id       mult_org.id%type;
  vn_loggenericonf_id Log_Generico_nf.id%type;
  vn_dm_obrig_integr    mult_org.dm_obrig_integr%type;
begin
  --
  vn_fase := 1;
  --
  begin
     --
     select mo.hash, mo.id, mo.dm_obrig_integr
       into vv_multorg_hash, vn_multorg_id, vn_dm_obrig_integr
       from mult_org mo
      where mo.cd = ev_cod_mult_org;
     --
     vn_fase := 2;
     --
  exception
     when no_data_found then
        --
        vn_fase := 3;
        --
        vv_multorg_hash := null;
        --
        vn_multorg_id := 0;
        --
     when others then
        --
        vn_fase := 4;
        --
        vv_multorg_hash := null;
        --
        vn_multorg_id := 0;
        --
        gv_mensagem_log := 'Problema ao tentar buscar o Mult Org. Fase: '||vn_fase;
        gv_cabec_log    := 'Código do MultOrg: '||ev_cod_mult_org||', Hash do MultOrg: '||ev_hash_mult_org||'.';
        --
        vn_loggenericonf_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id
                           ,ev_mensagem         => gv_mensagem_log
                           ,ev_resumo           => gv_cabec_log
                           ,en_tipo_log         => ERRO_DE_VALIDACAO
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenericonf_id
                              ,est_log_generico_nf => est_log_generico);
        --
  end;
  --
  vn_fase := 5;
  --
  if nvl(vn_multorg_id, 0) = 0 then
     gv_mensagem_log := 'O Mult Org de codigo: '||ev_cod_mult_org||', não existe.';
     --
     vn_loggenericonf_id := null;
     --
     vn_fase := 5.1;
     --
     if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
        --
        vn_fase := 5.2;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id
                           ,ev_mensagem         => gv_mensagem_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => informacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        --
     elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
        --
        vn_fase := 5.3;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id
                           ,ev_mensagem         => gv_mensagem_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => ERRO_DE_VALIDACAO
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenericonf_id
                              ,est_log_generico_nf => est_log_generico);
        --
     end if;
     --
  elsif vv_multorg_hash != ev_hash_mult_org then
     --
     vn_fase := 6;
     --
     gv_mensagem_log := 'O valor do Hash ('||ev_hash_mult_org||') do Mult Org: '||ev_cod_mult_org||'esta incorreto.';
     --
     vn_loggenericonf_id := null;
     --
     if vn_dm_obrig_integr = 0 then -- Não validar o multorg.
        --
        vn_fase := 6.1;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id
                           ,ev_mensagem         => gv_mensagem_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => informacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        --
     elsif vn_dm_obrig_integr = 1 then -- Validar o multorg.
        --
        vn_fase := 6.2;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenericonf_id
                           ,ev_mensagem         => gv_mensagem_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => ERRO_DE_VALIDACAO
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        --
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenericonf_id
                              ,est_log_generico_nf => est_log_generico);
        --
     end if;
     --
  end if;
  --
  vn_fase := 7;
  --
  sn_multorg_id := vn_multorg_id;
exception
  when others then
     raise_application_error(-20101
                            ,'Problemas ao validar Mult Org - pk_csf_api.pkb_ret_multorg_id. Fase: ' ||
                             vn_fase || ' Erro = ' || sqlerrm);
end pkb_ret_multorg_id;
   
------------------------------------------------------------------------------
-- Procedimento seta o tipo de Integracao que será feito                    --
-- 0 - Somente valida os dados e registra o Log de ocorrência               --
-- 1 - Valida os dados e registra o Log de ocorrência e insere a informação --
-- Todos os procedimentos de Integracao fazem referência a ele              --
------------------------------------------------------------------------------
PROCEDURE PKB_SETA_TIPO_INTEGR(EN_TIPO_INTEGR IN NUMBER) IS
BEGIN
  --
  gn_tipo_integr := en_tipo_integr;
  --
END PKB_SETA_TIPO_INTEGR;

-----------------------------------------------------------------------------------
-- Procedimento seta o objeto de referencia utilizado na validacao da informação --
-----------------------------------------------------------------------------------
PROCEDURE PKB_SETA_OBJ_REF(EV_OBJETO IN VARCHAR2) IS
BEGIN
  --
  gv_obj_referencia := upper(ev_objeto);
  --
END PKB_SETA_OBJ_REF;

-------------------------------------------------------------------
-- Procedimento integra as informação do emitente da Nota Fiscal --
-------------------------------------------------------------------
procedure pkb_integr_nota_fiscal_emit( ev_empresa       in empresa.id%type
                                    , en_notafiscal_id in nota_fiscal.id%type) is
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  vv_cnpj_cpf       varchar2(14) := null;
  vv_nome           pessoa.nome%type;
  vv_fantasia       pessoa.fantasia%type;
  vv_lograd         pessoa.lograd%type;
  vv_nro            pessoa.nro%type;
  vv_compl          pessoa.compl%type;
  vv_bairro         pessoa.bairro%type;
  vv_cidade         cidade.descr%type;
  vv_cidIbge        cidade.ibge_cidade%type;
  vv_uf             estado.sigla_estado%type;
  vv_cep            pessoa.cep%type;
  vv_codPais        pais.cod_siscomex%type;
  vv_paisDesc       pais.descr%type;
  vv_fone           pessoa.fone%type;
  vn_ie             juridica.ie%type;
  vn_iest           juridica.iest%type;
  vn_im             juridica.im%type;
  vn_cnae           juridica.cnae%type;
  vv_cnpj           varchar2(14);
  vn_idEmit         nota_fiscal_emit.id%type;
  --
begin
 --
 gv_mensagem_log := null;
 --
 vn_fase := 1;
 --
 begin
   select  p.nome
         , p.fantasia
         , p.lograd
         , p.nro
         , p.compl
         , p.bairro
         , cid.descr
         , cid.ibge_cidade
         , uf.sigla_estado
         , p.cep
         , ps.cod_siscomex
         , ps.descr
         , p.fone
         , j.ie
         , j.iest
         , j.im
         , j.cnae
         , lpad(j.num_cnpj, 8, 0) || lpad(j.num_filial, 4, 0) || lpad(j.dig_cnpj, 2, 0)
         into
           vv_nome
         , vv_fantasia
         , vv_lograd
         , vv_nro
         , vv_compl
         , vv_bairro
         , vv_cidade
         , vv_cidIbge
         , vv_uf
         , vv_cep
         , vv_codPais
         , vv_paisDesc
         , vv_fone
         , vn_ie
         , vn_iest
         , vn_im
         , vn_cnae
         , vv_cnpj
   from pessoa p
      , juridica j
      , empresa emp
      , cidade cid
      , estado uf
      , pais ps
     where p.id = emp.pessoa_id
       and emp.pessoa_id = j.pessoa_id
       and cid.id = p.cidade_id
       and uf.id = cid.estado_id
       and ps.id = uf.pais_id
       and emp.id = ev_empresa;
 exception
   when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal_Emit fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
     exception
        when others then
           null;
     end;
     --
 end;
 --
 vn_fase := 2;
 --
 begin
   select id
          into
          vn_idEmit
      from nota_fiscal_emit
   where notafiscal_id =  en_notafiscal_id;
 exception
   when no_data_found then
     vn_idEmit := null;
 end;
 --
 vn_fase := 3;
 --
 if(gv_mensagem_log is not null) then
   --
   if (nvl(gn_tipo_integr, 0) = 1 and nvl(vn_idEmit,0) = 0) then
     --
     vn_fase := 4;
     --
     select notafiscalemit_seq.nextval
      into vn_idEmit
     from dual;
     --
     vn_fase := 5;
     --
     insert into Nota_Fiscal_Emit
                ( id
                , notafiscal_id
                , nome
                , fantasia
                , lograd
                , nro
                , compl
                , bairro
                , cidade
                , cidade_ibge
                , uf
                , cep
                , cod_pais
                , pais
                , fone
                , ie
                , iest
                , im
                , cnae
                , cnpj
                , cpf
                , dm_reg_trib)
                values
                ( vn_idEmit
                , en_notafiscal_id
                , vv_nome
                , vv_fantasia
                , vv_lograd
                , vv_nro
                , vv_compl
                , vv_bairro
                , vv_cidade
                , vv_cidIbge
                , vv_uf
                , vv_cep
                , vv_codPais
                , vv_paisDesc
                , vv_fone
                , vn_ie
                , vn_iest
                , vn_im
                , vn_cnae
                , vv_cnpj
                , null
                , 3);
     --
   else
     --
     vn_fase := 6;
     --
     update Nota_Fiscal_Emit
           set nome        = vv_nome
              ,fantasia    = vv_fantasia
              ,lograd      = vv_lograd
              ,nro         = vv_nro
              ,compl       = vv_compl
              ,bairro      = vv_bairro
              ,cidade      = vv_cidade
              ,cidade_ibge = vv_cidIbge
              ,uf          = vv_uf
              ,cep         = vv_cep
              ,cod_pais    = vv_codPais
              ,pais        = vv_paisDesc
              ,fone        = vv_fone
              ,ie          = vn_ie
              ,iest        = vn_iest
              ,im          = vn_im
              ,cnae        = vn_cnae
              ,cnpj        = vv_cnpj
              ,cpf         = null
              ,dm_reg_trib = 3
         where id = vn_idEmit;
        --
   end if;
   --
 end if;
 --
 vn_fase := 7;
 --
exception
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_Nota_Fiscal_Emit fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
     exception
        when others then
           null;
     end;
     --
end pkb_integr_nota_fiscal_emit;
--------------------------------------------------------------
-- Funcao para validar as notas fiscais de serviço continuo --
--------------------------------------------------------------
function fkg_valida_nfsc(en_empresa_id     in empresa.id%type
                       ,ed_dt_ini         in date
                       ,ed_dt_fin         in date
                       ,ev_obj_referencia in log_generico_nf.obj_referencia%type
                       ,en_referencia_id  in log_generico_nf.referencia_id%type)
  return boolean is
  --
  vn_fase            number;
  vt_log_generico_nf dbms_sql.number_table;
  --
  cursor c_notas is
     select nf.id notafiscal_id
       from empresa     em
           ,nota_fiscal nf
           ,mod_fiscal  mf
      where em.id = en_empresa_id
        and nf.empresa_id = em.id
        and nf.dm_arm_nfe_terc = 0
        and nf.dm_st_proc = 4 -- Autorizada
        and ((nf.dm_ind_emit = 1 and
            trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between ed_dt_ini and
            ed_dt_fin) or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and
            trunc(nf.dt_emiss) between ed_dt_ini and ed_dt_fin) or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and
            em.dm_dt_escr_dfepoe = 0 and
            trunc(nf.dt_emiss) between ed_dt_ini and ed_dt_fin) or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and
            em.dm_dt_escr_dfepoe = 1 and
            trunc(nvl(nf.dt_sai_ent, nf.dt_emiss)) between ed_dt_ini and
            ed_dt_fin))
        and mf.id = nf.modfiscal_id
        --and mf.cod_mod in ('06', '29', '28', '21', '22', '66')
        and mf.obj_integr_cd in ('5') -- Busca apenas notas de Serviços contínuos
      order by nf.id;
  --
begin
  --
  vn_fase := 1;
  --
  pkb_seta_tipo_integr(en_tipo_integr => 0); -- 0-Valida e registra Log, 1-Valida, registra Log e insere a informação
  --
  pkb_seta_obj_ref(ev_objeto => ev_obj_referencia);
  --
  pkb_seta_referencia_id(en_id => en_referencia_id);
  --
  gv_mensagem_log            := 'validacao da Nota Fiscal';
  pk_csf_api_sc.gv_cabec_log := 'validacao da Nota Fiscal';
  --
  vn_fase := 2;
  --
  vt_log_generico_nf.delete;
  --
  for rec in c_notas
  loop
     --
     exit when c_notas%notfound or(c_notas%notfound) is null;
     --
     vn_fase := 3;
     --
     pk_csf_api_sc.pkb_consiste_nfsc(est_log_generico_nf => vt_log_generico_nf
                                    ,en_notafiscal_id    => rec.notafiscal_id);
     --
  end loop;
  --
  vn_fase := 4;
  --
  if nvl(vt_log_generico_nf.count, 0) > 0 then
     return false;
  else
     return true;
  end if;
  --
exception
  when others then
     raise_application_error(-20101
                            ,'Problemas em pk_int_view_sc.fkg_valida_nfsc (fase = ' ||
                             vn_fase || ' empresa_id = ' ||
                             en_empresa_id || ' período de ' ||
                             to_char(ed_dt_ini, 'dd/mm/yyyy') ||
                             ' até ' ||
                             to_char(ed_dt_fin, 'dd/mm/yyyy') ||
                             ' objeto = ' || ev_obj_referencia ||
                             ' referencia_id = ' || en_referencia_id ||
                             '). Erro = ' || sqlerrm);
end fkg_valida_nfsc;
--------------------------------------------------
-- Integra informações da Duplicata de Cobrança --
--------------------------------------------------
PROCEDURE PKB_INTEGR_NFCOBR_DUP(EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                              ,EST_ROW_NFCOBR_DUP  IN OUT NOCOPY NFCOBR_DUP%ROWTYPE
                              ,EN_NOTAFISCAL_ID    IN NOTA_FISCAL.ID%TYPE) IS
  --
  vn_fase           number := 0;
  vn_loggenerico_id log_generico_nf.id%type;
  --
BEGIN
  --
  vn_fase := 1;
  --
  if nvl(est_row_NFCobr_Dup.nfcobr_id, 0) = 0 and
     nvl(est_log_generico_nf.count, 0) = 0 then
     --
     vn_fase := 1.1;
     --
     gv_mensagem_log := 'Não existe Dados da Cobrança para a Duplicata.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 2;
  -- Valida informação do Número da Parcela
  if trim(est_row_NFCobr_Dup.nro_parc) is null then
     --
     vn_fase := 2.1;
     --
     gv_mensagem_log := 'Número da Parcela da Duplicata não foi informado.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 3;
  -- Valida informação do vencimento da Duplicata
  if est_row_NFCobr_Dup.dt_vencto is null then
     --
     vn_fase := 3.1;
     --
     gv_mensagem_log := 'Data de vencimento da Parcela da Duplicata não foi informada.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  elsif to_number(to_char(est_row_NFCobr_Dup.dt_vencto, 'RRRR')) > 2099 then
     --
     vn_fase := 3.2;
     --
     gv_mensagem_log := 'Data de vencimento da Parcela da Duplicata ('||to_char(est_row_NFCobr_Dup.dt_vencto,'dd/mm/rrrr')||
                        ') não pode ultrapassar o ano de 2099.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 4;
  -- Quando o indicador do emitente for "terceiros", a data do vencimento não pode ser menor que a data da Entrada ou Emissao
  if est_row_NFCobr_Dup.dt_vencto is null then
     --
     if pk_csf_api.gt_row_Nota_Fiscal.dm_ind_emit = 1 and -- terceiros
        est_row_NFCobr_Dup.dt_vencto < nvl(pk_csf_api.gt_row_Nota_Fiscal.dt_sai_ent,pk_csf_api.gt_row_Nota_Fiscal.dt_emiss) then
        --
        vn_fase := 4.1;
        --
        gv_mensagem_log := 'Data de vencimento da Parcela da Duplicata ('||to_char(est_row_NFCobr_Dup.dt_vencto,'dd/mm/rrrr')||') não pode ser menor '||
                           'que a data de Entrada ou Emissão ('||
                           to_char(nvl(pk_csf_api.gt_row_Nota_Fiscal.dt_sai_ent,pk_csf_api.gt_row_Nota_Fiscal.dt_emiss),'dd/mm/rrrr')||').';
        --
        vn_loggenerico_id := null;
        --
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
        --
     end if;
     --
  end if;
  --
  vn_fase := 5;
  --
  -- Valida informação do Valor da Duplicata
  if nvl(est_row_NFCobr_Dup.vl_dup, 0) <= 0 then
     --
     vn_fase := 5.1;
     --
     gv_mensagem_log := 'Valor da Parcela da Duplicata não pode ser zero ou negativo ('||nvl(est_row_NFCobr_Dup.vl_dup,0)||').';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
     --
  end if;
  --
  vn_fase := 6;
  -- Se o valor for zero, atribui nulo
  --if est_row_NFCobr_Dup.vl_dup = 0 then
  --   est_row_NFCobr_Dup.vl_dup := null; -- COmentado, porque se for "nulo" gera erro de XML
  --end if;
  --
  vn_fase := 7;
  --
  -- Se não existe registro de log e o Tipo de validacao 1 (valida e insere)
  -- então registra a Duplicata da Nota Fiscal
  if nvl(est_log_generico_nf.count, 0) > 0 and 
     fkg_ver_erro_log_generico_nfsc( en_nota_fiscal_id => en_notafiscal_id ) = 1 then
     --
     update nota_fiscal
        set dm_st_proc = 10
      where id = en_notafiscal_id;
     --
  end if;
  --
  vn_fase := 8;
  --
  if nvl(est_row_NFCobr_Dup.nfcobr_id, 0) > 0 and
     trim(pk_csf.fkg_converte(est_row_NFCobr_Dup.nro_parc)) is not null and
     est_row_NFCobr_Dup.dt_vencto is not null then
     --
     if nvl(gn_tipo_integr, 0) = 1 then
        --
        vn_fase := 9;
        --
        select nfcobrdup_seq.nextval
          into est_row_NFCobr_Dup.id
          from dual;
        --
        vn_fase := 10;
        --
        insert into NFCobr_Dup
           (id
           ,nfcobr_id
           ,nro_parc
           ,dt_vencto
           ,vl_dup)
        values
           (est_row_NFCobr_Dup.id
           ,est_row_NFCobr_Dup.nfcobr_id
           ,trim(pk_csf.fkg_converte(est_row_NFCobr_Dup.nro_parc))
           ,est_row_NFCobr_Dup.dt_vencto
           ,est_row_NFCobr_Dup.vl_dup);
        --
     else
        --
        vn_fase := 11;
        --
        update NFCobr_Dup
           set nro_parc  = trim(pk_csf.fkg_converte(est_row_NFCobr_Dup.nro_parc))
              ,dt_vencto = est_row_NFCobr_Dup.dt_vencto
              ,vl_dup    = est_row_NFCobr_Dup.vl_dup
         where id = est_row_NFCobr_Dup.id;
        --
     end if;
     --
  end if;
  --
EXCEPTION
  when others then
     --
     gv_mensagem_log := 'Erro na pkb_integr_NFCobr_Dup fase ('||vn_fase||'): '||sqlerrm;
     --
     declare
        vn_loggenerico_id log_generico_nf.id%type;
     begin
        pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memoria
        pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                              ,est_log_generico_nf => est_log_generico_nf);
     exception
        when others then
           null;
     end;
     --
END PKB_INTEGR_NFCOBR_DUP;
--------------------------------------------------------------
-- Procedimento integra as informações nota fiscal term fat --
--------------------------------------------------------------
procedure pkb_integr_nfTerm_fat(est_log_generico_nf  in OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                               , est_row_nfTerm_fat in out nf_term_fat%rowtype)
is
--
vn_fase    number := 0;
vn_loggenerico_id  log_generico.id%type;
vn_nf_term_fat_id  nf_term_fat.id%type;
--
begin
 --
 vn_fase := 1;
 --
 gv_mensagem_log := null;
 --
 if nvl(est_row_nfTerm_fat.notafiscal_id,0) = 0 and nvl(est_log_generico_nf.count,0) = 0 then
   --
   vn_fase := 1.1;
   --
   gv_mensagem_log := 'Não informada a nota fiscal para relacionar os dados da nf_term_fat';
   --
   vn_loggenerico_id := null;
   --
   pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                       ,ev_mensagem         => gv_cabec_log
                       ,ev_resumo           => gv_mensagem_log
                       ,en_tipo_log         => erro_de_validacao
                       ,en_referencia_id    => gn_referencia_id
                       ,ev_obj_referencia   => gv_obj_referencia);

   -- Armazena o "loggenerico_id" na memoria
   pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                      ,est_log_generico_nf => est_log_generico_nf);
   --
 end if;
 --
 if nvl(est_row_nfTerm_fat.dm_ind_serv,0) = 0 then
    --
vn_fase := 1.2;
--
    gv_mensagem_log := 'Nao informado o indicador do tipo de serviço, fase: '||vn_fase;
    --
    vn_loggenerico_id := null;
    --
    pkb_log_generico_nf(sn_loggenericonf_id  => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);

    -- Armazena o "loggenerico_id" na memória
    pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                         ,est_log_generico_nf => est_log_generico_nf);
    --
 end if;
 --
 if est_row_nfTerm_fat.dt_ini_serv is null then
    --
    vn_fase := 1.3;
--
gv_mensagem_log := 'Nao informada a data de início do serviço, fase: '||vn_fase;
--
    vn_loggenerico_id := null;
--
pkb_log_generico_nf(sn_loggenericonf_id  => vn_loggenerico_id
                        ,ev_mensagem         => gv_cabec_log
                        ,ev_resumo           => gv_mensagem_log
                        ,en_tipo_log         => erro_de_validacao
                        ,en_referencia_id    => gn_referencia_id
                        ,ev_obj_referencia   => gv_obj_referencia);

  -- Armazena o "loggenerico_id" na memória
  pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                         ,est_log_generico_nf => est_log_generico_nf);
  --
end if;
--
if est_row_nfTerm_fat.dt_fin_serv is null then
  --
  vn_fase := 1.4;
  --
  gv_mensagem_log := 'Nao informada a data fim do serviço, fase: '||vn_fase;
  --
  vn_loggenerico_id := null;
  --
  pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                     ,ev_mensagem         => gv_cabec_log
                     ,ev_resumo           => gv_mensagem_log
                     ,en_tipo_log         => erro_de_validacao
                     ,en_referencia_id    => gn_referencia_id
                     ,ev_obj_referencia   => gv_obj_referencia);

  -- Armazena o "loggenerico_id" na memória
  pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                         ,est_log_generico_nf => est_log_generico_nf);
  --
end if;
--
if nvl(est_row_nfTerm_fat.per_fiscal,'0') = '0' then
  --
  vn_fase := 1.5;
  --
  gv_mensagem_log := 'Não informado o período fiscal da prestação do serviço, fase: '||vn_fase;
  --
  vn_loggenerico_id := null;
  --
  pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                   ,ev_mensagem         => gv_cabec_log
                   ,ev_resumo           => gv_mensagem_log
                   ,en_tipo_log         => erro_de_validacao
                   ,en_referencia_id    => gn_referencia_id
                   ,ev_obj_referencia   => gv_obj_referencia);

  -- Armazena o "loggenerico_id" na memoria
  pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                         ,est_log_generico_nf => est_log_generico_nf);
  --
end if;
--
if nvl(est_row_nfTerm_fat.cod_area,'0') = '0' then
  --
  vn_fase := 1.6;
  --
  gv_mensagem_log := 'Não informado o código de área do terminal faturado, fase: '||vn_fase;
  --
  vn_loggenerico_id := null;
  --
  pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                   ,ev_mensagem         => gv_cabec_log
                   ,ev_resumo           => gv_mensagem_log
                   ,en_tipo_log         => erro_de_validacao
                   ,en_referencia_id    => gn_referencia_id
                   ,ev_obj_referencia   => gv_obj_referencia);

  -- Armazena o "loggenerico_id" na memoria
  pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                         ,est_log_generico_nf => est_log_generico_nf);
  --
end if;
--
-- campo est_row_nfterm_fat.terminal pode ser nulo, portanto não existe validação/verificação
--
if nvl(est_row_nfterm_fat.notafiscal_id,0) > 0 and
  est_row_nfterm_fat.dm_ind_serv in (0,1,2,3,4,9) then
  --
  if nvl(gn_tipo_integr,0) = 1  then
     --
     begin
        --
        select id
          into vn_nf_term_fat_id
          from nf_term_fat
         where notafiscal_id = est_row_nfTerm_fat.notafiscal_id
           and dm_ind_serv   = est_row_nfTerm_fat.dm_ind_serv
           and dt_ini_serv   = est_row_nfTerm_fat.dt_Ini_Serv
           and dt_fin_serv   = est_row_nfTerm_fat.dt_fin_serv
           and per_fiscal    = est_row_nfTerm_fat.per_fiscal
           and cod_area      = est_row_nfTerm_fat.cod_area
           and terminal      = est_row_nfTerm_fat.terminal;
           --
     exception
        when others then
           vn_nf_term_fat_id := 0;
     end;
     --
     vn_fase :=  1.8;
     --
     if nvl(vn_nf_term_fat_id, 0) <= 0 then
        --
        select nftermfat_seq.nextval into
            est_row_nfterm_fat.id
        from dual;
        --
        vn_fase := 1.9;
        --
        insert into nf_term_fat
        (id
        ,notafiscal_id
        ,dm_ind_serv
        ,dt_ini_serv
        ,dt_fin_serv
        ,per_fiscal
        ,cod_area
        ,terminal)
        values
        (est_row_nfTerm_fat.id
        ,est_row_nfTerm_fat.notafiscal_id
        ,est_row_nfTerm_fat.dm_ind_serv
        ,est_row_nfTerm_fat.dt_Ini_Serv
        ,est_row_nfTerm_fat.dt_fin_serv
        ,est_row_nfTerm_fat.per_fiscal
        ,est_row_nfTerm_fat.cod_area
        ,est_row_nfTerm_fat.terminal);
     --
     else
     --
        update nf_term_fat
               set  notafiscal_id = est_row_nfTerm_fat.notafiscal_id
                   ,dm_ind_serv   = est_row_nfTerm_fat.dm_ind_serv
                   ,dt_Ini_Serv   = est_row_nfTerm_fat.dt_Ini_Serv
                   ,dt_fin_serv   = est_row_nfTerm_fat.dt_fin_serv
                   ,per_fiscal    = est_row_nfTerm_fat.per_fiscal
                   ,cod_area      = est_row_nfTerm_fat.cod_area
                   ,terminal      = est_row_nfTerm_fat.terminal
         where id = vn_nf_term_fat_id;
     --
     end if;
     --
  else
     --
     vn_fase := 2;
     --
     update nf_term_fat
            set  notafiscal_id = est_row_nfTerm_fat.notafiscal_id
                ,dm_ind_serv   = est_row_nfTerm_fat.dm_ind_serv
                ,dt_Ini_Serv   = est_row_nfTerm_fat.dt_Ini_Serv
                ,dt_fin_serv   = est_row_nfTerm_fat.dt_fin_serv
                ,per_fiscal    = est_row_nfTerm_fat.per_fiscal
                ,cod_area      = est_row_nfTerm_fat.cod_area
                ,terminal      = est_row_nfTerm_fat.terminal
     where id = est_row_nfTerm_fat.id;
     --
  end if;
  --
end if;
--
commit;
--
exception
 when others then
 --
 gv_mensagem_log := 'Erro na pk_csf_api_sc fase ('||vn_fase||'): '||sqlerrm;
 --
 declare
   vn_loggenerico_id log_generico_nf.id%type;
   begin
     pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
        -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
   exception
     when others then
       null;
   end;
   --
end pkb_integr_nfTerm_fat;
----------------------------------------------------------------------
-- Procedimento para inserir as informações de cancelamento da nf
----------------------------------------------------------------------
procedure pkb_integr_nfCanc ( est_log_generico_nf in out nocopy dbms_sql.number_table
                          , est_row_nfCanc      in out nocopy nota_fiscal_canc%rowtype) is
 --
 vn_fase           number := 0;
 vn_loggenerico_id log_generico_nf.id%type;
 vn_nfCancId       number := 0;
 vn_dm_st_proc     nota_fiscal.dm_st_proc%type;
 vn_sitdocto_id    sit_docto.id%type;
 --
begin
--
vn_fase := 1;
--
gv_mensagem_log := null;
--
if nvl(est_row_nfCanc.notafiscal_id,'0') = '0' then
   --
   vn_fase := 2;
   --
   gv_mensagem_log := 'Nota fiscal não informada para relacionar na tabela NOTA_FISCAL_CANC';
   --
   vn_loggenerico_id := null;
   --
   pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                       ,ev_mensagem         => gv_cabec_log
                       ,ev_resumo           => gv_mensagem_log
                       ,en_tipo_log         => erro_de_validacao
                       ,en_referencia_id    => gn_referencia_id
                       ,ev_obj_referencia   => gv_obj_referencia);

   -- Armazena o "loggenerico_id" na memoria
   pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                      ,est_log_generico_nf => est_log_generico_nf);
   --
end if;
--
vn_fase := 3;
--
if est_row_nfCanc.dt_canc is null then
   --
   vn_fase := 4;
   --
   gv_mensagem_log := 'Data do cancelamento não informada.';
   --
   vn_loggenerico_id := null;
   --
   pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                       ,ev_mensagem         => gv_cabec_log
                       ,ev_resumo           => gv_mensagem_log
                       ,en_tipo_log         => erro_de_validacao
                       ,en_referencia_id    => gn_referencia_id
                       ,ev_obj_referencia   => gv_obj_referencia);

   -- Armazena o "loggenerico_id" na memoria
   pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                      ,est_log_generico_nf => est_log_generico_nf);
   --
end if;
--
vn_fase := 5;
--
if nvl(est_row_nfCanc.justif,'0') = '0' then
   --
   vn_fase := 6;
   --
   gv_mensagem_log := 'Justificativa do cancelamento não informado para relacionar na tabela NOTA_FISCAL_CANC';
   --
   vn_loggenerico_id := null;
   --
   pkb_log_generico_nf(sn_loggenericonf_id => vn_loggenerico_id
                       ,ev_mensagem         => gv_cabec_log
                       ,ev_resumo           => gv_mensagem_log
                       ,en_tipo_log         => erro_de_validacao
                       ,en_referencia_id    => gn_referencia_id
                       ,ev_obj_referencia   => gv_obj_referencia);

   -- Armazena o "loggenerico_id" na memoria
   pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                      ,est_log_generico_nf => est_log_generico_nf);
   --
end if;
--
vn_fase := 99;
--
if  nvl(est_row_nfCanc.notafiscal_id,'0') <> '0'
    and est_row_nfCanc.dt_canc is not null
    and nvl(est_row_nfCanc.justif,'0') <> '0' then
    --
    vn_fase := 99.1;
    --
    begin
      --
      select id 
             into 
             vn_nfCancId 
         from nota_fiscal_canc
     where notafiscal_id = est_row_nfCanc.notafiscal_id;
     --
     exception
       when others then
         vn_nfCancId := null;
    end;
    --
    vn_fase := 99.2;
    --
    if nvl(vn_nfCancId,'0') = '0' then
       --
       insert into nota_fiscal_canc ( id
                                    , notafiscal_id
                                    , dt_canc
                                    , justif )
                              values( notafiscalcanc_seq.nextval
                                    , est_row_nfCanc.notafiscal_id
                                    , est_row_nfCanc.dt_canc
                                    , est_row_nfCanc.justif);
       --
    else
       update nota_fiscal_canc set notafiscal_id = notafiscalcanc_seq.nextval
                                   , dt_canc     = est_row_nfCanc.dt_canc
                                   , justif      = est_row_nfCanc.justif
        where id = vn_nfCancId;
    end if;
    --
    vn_fase := 99.3;
    vn_dm_st_proc := pk_csf.fkg_st_proc_nf ( en_notafiscal_id => est_row_nfCanc.notafiscal_id );
    --
    vn_fase := 99.4;
    if nvl(est_log_generico_nf.count,0) <= 0 then
       --
       if nvl(vn_dm_st_proc,0) = 4 then
          --
          vn_fase := 99.41;
          vn_sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '02' ); -- Documento cancelado
          --
          vn_dm_st_proc := 7; -- Cancelado
          --
       else
          --
          vn_fase := 99.42;
          vn_sitdocto_id := pk_csf.fkg_Sit_Docto_id ( ev_cd => '04' ); -- NF-e ou CT-e denegado
          --
          vn_dm_st_proc := 8; -- Inutilizado
          --
       end if;
       --
    end if;
    --
    vn_fase := 99.5;
    --
    -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_02 (carrega)
    gv_objeto := 'pk_csf_api_sc.pkb_integr_nfCanc';
    gn_fase   := vn_fase;
    --
    update nota_fiscal set dm_st_proc    = vn_dm_st_proc
                         , sitdocto_id   = vn_sitdocto_id
                         , dm_st_integra = 8 -- Aguardando retorno para o ERP
     where id = est_row_nfCanc.notafiscal_id;
    --
    -- Variavel global usada no trigger T_A_I_U_Nota_Fiscal_02 (limpa)
    gv_objeto := null;
    gn_fase   := null;
    --
    commit;
    --
end if;
--
exception
when others then
  --
  pk_csf_api_sc.gv_mensagem_log := 'Erro na pk_csf_api_sc.pkb_integr_nfCanc fase ('||vn_fase||'): '||sqlerrm;
  --
  declare
    vn_loggenerico_id log_generico_nf.id%TYPE;
      begin
      --
      pk_csf_api_sc.pkb_log_generico_nf( sn_loggenericonf_id => vn_loggenerico_id
                                       , ev_mensagem         => pk_csf_api_sc.gv_mensagem_log
                                       , ev_resumo           => pk_csf_api_sc.gv_mensagem_log
                                       , en_tipo_log         => pk_csf_api_sc.ERRO_DE_SISTEMA
                                       , en_referencia_id    => est_row_nfCanc.notafiscal_id
                                       , ev_obj_referencia   => 'NOTA_FISCAL_CANC');
        --
        -- Armazena o "loggenerico_id" na memoria
        pk_csf_api_sc.pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                                            ,est_log_generico_nf => est_log_generico_nf);
        --
     exception
        when others then
           null;
     end;
     --
end pkb_integr_nfCanc;
----------------------------------------------------------------------
-- Procedimento para inserir as informações complementares na nf
----------------------------------------------------------------------
procedure pkb_integr_nfCompl ( est_log_generico_nf in out nocopy dbms_sql.number_table
                           , ev_cod_cons         in cod_cons_item_cont.cod_cons%type
                           , en_id_erp           in nota_fiscal_compl.id_erp%type
                           , est_row_nfcompl     in             nota_fiscal%rowtype
                           ) is
--
vn_fase           number := 0;
vn_loggenerico_id log_generico_nf.id%type;
vn_qtde           number := 0;
vn_cod_cons       nota_fiscal.codconsitemcont_id%type;
--
begin
  --
  vn_fase := 1;
  --
  if nvl(est_row_nfcompl.id,0) > 0 then
     --
     vn_fase := 2;
     --
     begin
       --
       select c.id
              into
              vn_cod_cons
           from cod_cons_item_cont c, mod_fiscal m
        where c.modfiscal_id = m.id
          and c.cod_cons = ev_cod_cons
          and m.especie = 'NFSC';
       --
     exception
       when others then
         vn_cod_cons := null;
     end;
     --
     vn_fase := 2.1;
     --
     update nota_fiscal nf set
            nf.hash                = est_row_nfcompl.hash
          , nf.codconsitemcont_id  = vn_cod_cons
          , nf.dm_tp_ligacao       = est_row_nfcompl.dm_tp_ligacao
          , nf.dm_cod_grupo_tensao = est_row_nfcompl.dm_cod_grupo_tensao
     where
       nf.id = est_row_nfcompl.id;
     --
     vn_fase := 2.2;
     --
     if nvl(en_id_erp,0) > 0 then
        --
        delete from nota_fiscal_compl
         where notafiscal_id = est_row_nfcompl.id;
        --
        vn_fase := 2.3;
        --
        insert into nota_fiscal_compl ( ID
                                      , NOTAFISCAL_ID
                                      , ID_ERP
                                      )
                               values ( notafiscalcompl_seq.nextval --ID
                                      , est_row_nfcompl.id -- NOTAFISCAL_ID
                                      , en_id_erp -- ID_ERP
                                      );
        --
     end if;
     --
  end if;
  --
  vn_fase := 3;
  --
  commit;
  --
exception
when others then
  --
  gv_mensagem_log := 'Erro na pk_csf_api_sc.pkb_integr_nfCompl fase('||vn_fase||'): '||sqlerrm;
  --
  declare
    vn_loggenerico_id log_generico_nf.id%type;
    begin
      pkb_log_generico_nf(sn_loggenericonf_id    => vn_loggenerico_id
                           ,ev_mensagem         => gv_cabec_log || gv_cabec_log_item
                           ,ev_resumo           => gv_mensagem_log
                           ,en_tipo_log         => erro_de_validacao
                           ,en_referencia_id    => gn_referencia_id
                           ,ev_obj_referencia   => gv_obj_referencia);
      -- Armazena o "loggenerico_id" na memória
      pkb_gt_log_generico_nf(en_loggenericonf_id => vn_loggenerico_id
                           ,est_log_generico_nf => est_log_generico_nf);
    exception
      when others then
        null;
    end;
   --
end pkb_integr_nfCompl;
----------------------------------------------------------------------
-- Procedimento que valida as informações adicionais da nota fiscal --
----------------------------------------------------------------------
procedure pkb_valida_infor_adic( EST_LOG_GENERICO_NF IN OUT NOCOPY DBMS_SQL.NUMBER_TABLE
                              ,EN_NOTAFISCAL_ID    IN NOTA_FISCAL.ID%TYPE ) IS
--
vn_fase           number := 0;
vn_loggenerico_id log_generico_nf.id%type;
vn_qtde           number := 0;
--
BEGIN
--
vn_fase := 1;
--
if nvl(en_notafiscal_id,0) > 0 then
  --
  vn_fase := 2;
  -- Verifica se as informações da TAG de grupo do campo de uso livre do contribuinte não ultrapassam 10 registros
  begin
     select count(1)
       into vn_qtde
       from nfinfor_adic na
      where na.notafiscal_id = en_notafiscal_id
        and na.dm_tipo       = 0 -- Contribuinte
        and na.campo    is not null;
  exception
     when others then
        vn_qtde := 0;
  end;
  --
  vn_fase := 3;
  --
  if nvl(vn_qtde,0) > 10 then
     --
     gv_mensagem_log := 'Não pode haver mais que 10 (dez) registros para a "TAG de grupo do campo de uso livre do contribuinte.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                      , ev_mensagem        => gv_cabec_log
                      , ev_resumo          => gv_mensagem_log
                      , en_tipo_log        => erro_de_validacao
                      , en_referencia_id   => gn_referencia_id
                      , ev_obj_referencia  => gv_obj_referencia );
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                         , est_log_generico_nf  => est_log_generico_nf );
     --
  end if;
  --
  vn_fase := 4;
  -- Valida se as informações da TAG de grupo do campo de uso livre do Fisco nao ultrapassam 10 registros
  begin
     select count(1)
       into vn_qtde
       from nfinfor_adic na
      where na.notafiscal_id = en_notafiscal_id
        and na.dm_tipo       = 1 -- Fisco
        and na.campo    is not null;
  exception
     when others then
        vn_qtde := 0;
  end;
  --
  vn_fase := 5;
  --
  if nvl(vn_qtde,0) > 10 then
     --
     gv_mensagem_log := 'Não pode haver mais que 10 (dez) registros para a "TAG de grupo do campo de uso livre do Fisco.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                      , ev_mensagem        => gv_cabec_log
                      , ev_resumo          => gv_mensagem_log
                      , en_tipo_log        => erro_de_validacao
                      , en_referencia_id   => gn_referencia_id
                      , ev_obj_referencia  => gv_obj_referencia );
     -- Armazena o "loggenerico_id" na memória
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                         , est_log_generico_nf  => est_log_generico_nf );
     --
  end if;
  --
  vn_fase := 6;
  -- Verifica se as informações da TAG de grupo do campo de uso livre do contribuinte não ultrapassam 10 registros
  begin
     select count(1)
       into vn_qtde
       from nfinfor_adic na
      where na.notafiscal_id = en_notafiscal_id
        and na.dm_tipo       = 0 -- Contribuinte
        and na.campo        is null;
  exception
     when others then
        vn_qtde := 0;
  end;
  --
  vn_fase := 7;
  --
  if nvl(vn_qtde,0) > 1 then
     --
     gv_mensagem_log := 'Não pode haver mais que 1 (um) registro para a "Informações Complementares de interesse do Contribuinte.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                      , ev_mensagem        => gv_cabec_log
                      , ev_resumo          => gv_mensagem_log
                      , en_tipo_log        => erro_de_validacao
                      , en_referencia_id   => gn_referencia_id
                      , ev_obj_referencia  => gv_obj_referencia );
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                         , est_log_generico_nf  => est_log_generico_nf );
     --
  end if;
  --
  vn_fase := 8;
  -- Valida se as informações da TAG de grupo do campo de uso livre do Fisco não ultrapassam 10 registros
  begin
     select count(1)
       into vn_qtde
       from nfinfor_adic na
      where na.notafiscal_id = en_notafiscal_id
        and na.dm_tipo       = 1 -- Fisco
        and na.campo        is null;
  exception
     when others then
        vn_qtde := 0;
  end;
  --
  vn_fase := 9;
  --
  if nvl(vn_qtde,0) > 1 then
     --
     gv_mensagem_log := 'Não pode haver mais que 1 (um) registro para a "informações Adicionais de Interesse do Fisco.';
     --
     vn_loggenerico_id := null;
     --
     pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                      , ev_mensagem        => gv_cabec_log
                      , ev_resumo          => gv_mensagem_log
                      , en_tipo_log        => erro_de_validacao
                      , en_referencia_id   => gn_referencia_id
                      , ev_obj_referencia  => gv_obj_referencia );
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                         , est_log_generico_nf  => est_log_generico_nf );
     --
  end if;
  --
end if;
--
exception
  when others then
  --
  gv_mensagem_log := 'Erro na pkb_valida_infor_adic fase('||vn_fase||'): '||sqlerrm;
  --
  declare
  vn_loggenerico_id  log_generico_nf.id%type;
  begin
      pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                     ,ev_mensagem        => gv_cabec_log
         ,ev_resumo          => gv_mensagem_log
         ,en_tipo_log        => erro_de_sistema
         ,en_referencia_id   => gn_referencia_id
         ,ev_obj_referencia  => gv_obj_referencia );
     -- Armazena o "loggenerico_id" na memoria
     pkb_gt_log_generico_nf ( en_loggenericonf_id    => vn_loggenerico_id
                         , est_log_generico_nf  => est_log_generico_nf );
  exception
     when others then
        null;
  end;
  --
end pkb_valida_infor_adic;
-------------------------------------------
-- Procedimento finaliza o Log Genérico --
-------------------------------------------
procedure pkb_finaliza_log_generico_nf is
begin
--
gn_processo_id := null;
--
exception
when others then
--
gv_mensagem_log := 'Erro na pkb_finaliza_log_generico_nf: '||sqlerrm;
--
declare
  vn_loggenerico_id  log_generico_nf.id%type;
  begin
    pkb_log_generico_nf ( sn_loggenericonf_id  => vn_loggenerico_id
                         ,ev_mensagem         => gv_cabec_log
                         ,ev_resumo           => gv_mensagem_log
                         ,en_tipo_log         => erro_de_sistema );
  exception
    when others then
      null;
  end;
  --
end pkb_finaliza_log_generico_nf;

end pk_csf_api_sc;
/
