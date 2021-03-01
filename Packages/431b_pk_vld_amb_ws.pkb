create or replace package body csf_own.pk_vld_amb_ws is

-------------------------------------------------------------------------------------------------------
--| Corpo do pacote de procedimentos de Validação de Ambiente de Web-Service
-------------------------------------------------------------------------------------------------------

-- Procedimento para alterar o Situação do Processo do Lote de Integração Web-Service
procedure pkb_seta_st_proc ( en_loteintws_id     in lote_int_ws.id%type
                           , en_dm_st_proc       in lote_int_ws.dm_st_proc%type
                           )
is
   --
   vn_existe_nf number default 0;
   --
begin
   --
   begin
      -- Verifica se existe para o lote notas fiscais com codigo de msg 204 para manter o lote em processamento
      select count(*)
        into vn_existe_nf
        from r_loteintws_nf rl
           , nota_fiscal    nf
           , msg_webserv    mw
       where nf.id           = rl.notafiscal_id
         and mw.id           = nf.msgwebserv_id
         and mw.cd           = 204  -- Rejeição: Duplicidade de NF-e/CT-e
         and rl.loteintws_id = en_loteintws_id;
      --
   exception
      when others then
         vn_existe_nf := 0;
   end;
   --
   if nvl(vn_existe_nf,0) > 0 and en_dm_st_proc = 4 then
      --
      update lote_int_ws
         set dm_st_proc = 2 -- 2 - Em Processamento
           , dt_hr_proc = sysdate
       where id = en_loteintws_id;
      --
   else
      --
      update lote_int_ws
         set dm_st_proc = en_dm_st_proc
           , dt_hr_proc = sysdate
       where id = en_loteintws_id;
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_vld_amb_ws.pkb_seta_st_proc: ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_log_generico.gv_mensagem
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.erro_de_sistema
                                          , en_referencia_id   => en_loteintws_id
                                          , ev_obj_referencia  => 'LOTE_INT_WS'
                                          );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_seta_st_proc;
--
----------------------------------------------------------------------
--|Processo que exclui lotes sem vinculo com a tabela de referência|--
----------------------------------------------------------------------
procedure pkb_exclui_lote ( en_tipoobjintegr_id in tipo_obj_integr.id%type
                          , en_loteintws_id     in lote_int_ws.id%type
                          , ev_cod_obj          in obj_integr.cd%type )
  is
  --
  vn_fase         number := 0;
  --
  vv_cod_tipo_obj tipo_obj_integr.cd%type;
  --

begin
   --
   vn_fase := 1;
   --
   begin
      --
      select toi.cd
        into vv_cod_tipo_obj
        from tipo_obj_integr toi
       where toi.id = en_tipoobjintegr_id;
      --
   exception
      when others then
         --
         vv_cod_tipo_obj := null;
         --
   end;
   --
   vn_fase := 2;
   --
   if vv_cod_tipo_obj is not null then
      --
      vn_fase := 3;
      --
      if ev_cod_obj = '1' then --|Cadastros gerais|--
         --
         vn_fase := 4;
         --
         if vv_cod_tipo_obj = '1' then --Participantes--
            --
            vn_fase := 4.1;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pessoa rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '2' then --Unidades de Medidas--
            --
            vn_fase := 4.2;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_unidade rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '3' then --Produtos/serviços
            --
            vn_fase := 4.3;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_item rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '4' then --Grupos de patrimonio--
            --
            vn_fase := 4.4;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_grupopat rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '5' then --Bens do ativo imobilizado--
            --
            vn_fase := 4.5;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_bai rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '6' then --Natureza da operação/prestação
            --
            vn_fase := 4.6;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_natoper rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '7' then --Informações complementar do documento fiscal--
            --
            vn_fase := 4.7;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_icdf rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '8' then --Observação do lançamento fiscal--
            --
            vn_fase := 4.8;
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_olf rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '9' then --Plano de contas contábeis--
            --
            vn_fase := 4.9;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '10' then --Centro de custos--
            --
            vn_fase := 4.10;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_cc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '11' then --Histórico padrão dos lançamentos contábeis--
            --
            vn_fase := 4.11;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_hp rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '12' then --Parâmetros de Cálculo de ICMS-ST--
            --
            vn_fase := 4.12;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_ipicmsst rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '13' then --Ficha de Conteúdo de Importação--
            --
            vn_fase := 4.13;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_abertfci rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '14' then --Aglutinação Contábil--
            --
            vn_fase := 4.14;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_aglcont rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '15' then --Parâmetros DE-PARA de Item de Fornecedor para Emp. Usuária--
            --
            vn_fase := 4.15;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pie rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '16' then --Parâmetros de Conversão de NFe--
            --
            vn_fase := 4.16;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pofe rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '17' then --Parâmetros DE-PARA DIPAM--
            --
            vn_fase := 4.17;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pdipgia rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '18' then --Cadastro de Processos Administrativos do EFD-REINF--
            --
            vn_fase := 4.18;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_paefdreinf rl
                                 where rl.loteintws_id = li.id );
            --
         end if;
         --
      elsif ev_cod_obj = '2' then --|Inventário de estoque de produtos|--
         --
         vn_fase := 5;
         --
         delete
           from lote_int_ws li
           where li.id = en_loteintws_id
             and li.dm_st_proc not in (1, 2)
             and not exists ( select 1
                                from r_loteintws_inventario rl
                               where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '3' then --|Cupom fiscal|--
         --
         vn_fase := 6;
         --
         delete
           from lote_int_ws li
           where li.id = en_loteintws_id
             and not exists ( select 1
                                from r_loteintws_redzecf rl
                               where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '12' then --|Cupom fiscal Sat|--
         --
         vn_fase := 6.1;
         --
         delete
           from r_loteintws_cupomsat li
           where li.loteintws_id = en_loteintws_id
             and not exists ( select 1
                                from r_loteintws_redzecf rl
                               where rl.loteintws_id = li.id );                            
                               
         --
      elsif ev_cod_obj = '4' then --|Conhecimento de transporte|--
         --
         vn_fase := 7;
         --
         delete
           from lote_int_ws li
           where li.id = en_loteintws_id
             and li.dm_st_proc not in (1, 2)
             and not exists ( select 1
                                from r_loteintws_ct rl
                               where rl.loteintws_id = li.id )
             and not exists ( select 1
                                from r_loteintws_ict rli
                               where rli.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '5' then --|Notas fiscais de serviço continuo|--
         --
         vn_fase := 8;
         --
         delete
           from lote_int_ws li
           where li.id = en_loteintws_id
             and li.dm_st_proc not in (1, 2)
             and not exists ( select 1
                                from r_loteintws_nf rl
                               where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '6' then --|Notas fiscais mercantis|--
         --
         vn_fase := 9;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_nf rl
                              where rl.loteintws_id = li.id )
             and not exists ( select 1
                                from r_loteintws_inf rli
                               where rli.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '7' then --|Notas fiscais de serviço EFD|--
         --
         vn_fase := 10;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_nf rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '8' then --|CIAP|--
         --
         vn_fase := 11;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_ciap rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '9' then --|Crédito acumulado de ICMS - Ecredac|--
         --
         vn_fase := 12;
         --
         if vv_cod_tipo_obj = '1' then --Integração de ordem de produção--
            --
            vn_fase := 12.1;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_opcab rl
                                 where rl.loteintws_id = li.id );
           --
         elsif vv_cod_tipo_obj = '2' then --Integração de rateio direto do frete--
            --
            vn_fase := 12.2;
            --
            null; --NÃO DISPONIVEL NO WEB SERVICE--
            --
         elsif vv_cod_tipo_obj = '3' then --Integração de movimentações de produto--
            --
            vn_fase := 12.3;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_movtransf rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '4' then --Integração dos códigos do enquadramento legal--
            --
            vn_fase := 12.4;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_ecredac rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '5' then  --Itens de notas fiscais com código de enquadramento legal--
            --
            vn_fase := 12.5;
            --
            null; --NÃO DISPONIVEL NO WEB SERVICE--
            --
         elsif vv_cod_tipo_obj = '6' then --Itens de notas fiscais de entrada que não geram estoque--
            --
            vn_fase := 12.6;
            --
            null; --NÃO DIPONIVEL NO WEB SERVICE--
            --
         end if;
         --
      elsif ev_cod_obj = '16' then --|XML Sefaz - Nota Fiscal Mercantil|--
         --
         vn_fase := 13.1;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_envdocfiscal re
                              where re.loteintws_id = li.id )
             and not exists ( select 1
                                from r_loteintws_inf rli
                               where rli.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '19' then --|Usuário|--
         --
         vn_fase := 13.2;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_usuario rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '26' then --|Calculadora fiscal|--
         --
         vn_fase := 14;
         --
         if vv_cod_tipo_obj = '1' then -- Parâmetro de CFOP por Tipo de Imposto nível Global
            --
            vn_fase := 14.1;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_cfoptipoimp rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '2' then -- Parâm. de Aliq. Imposto por NCM: IPI/PIS/COFINS nivel Global
            --
            vn_fase := 14.2;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_aliqtpimpncm rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '3' then -- Parâm. de Parâmetros de Cálculo de ICMS ST nível Global
            --
            vn_fase := 14.3;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pcicmsst rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '4' then -- Parâmetros de Cálculo de ICMS nível Global
            --
            vn_fase := 14.4;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pcicms rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '5' then -- Parâm. de Partilha de ICMS entre Estados nível global
            --
            vn_fase := 14.5;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_cfopparticmsest rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '6' then -- Parâmetros de Cálculo de ISS nível global
            --
            vn_fase := 14.6;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pciss rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '7' then -- Parâmetro de Cálculo de Retido nível global
            --
            vn_fase := 14.7;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pcret rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '8' then -- Par. Aliq. Imp. por NCM: Tratar IPI/PIS/COFINS nivel Empresa
            --
            vn_fase := 14.8;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_altincmemp rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '9' then -- Parâmetros de Cálculo de ICMS ST nível Empresa
            --
            vn_fase := 14.9;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pcicmsstemp rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '10' then -- Parâmetros de Cálculo de ICMS nível Empresa
            --
            vn_fase := 14.10;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_picmsintercf rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '13' then -- Solicitação de Cálculo de Impostos para um Documento Fiscal
            --
            vn_fase := 14.11;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_soliccalc rl
                                 where rl.loteintws_id = li.id )
               and not exists ( select 1
                                  from r_loteintws_pcicmsemp rlp
                                 where rlp.loteintws_id = li.id );
            --
         end if;
         --
      elsif ev_cod_obj = '27' then --|Escrituração Contábil Fiscal - SPED ECF|--
         --
         vn_fase := 15;
         --
         if vv_cod_tipo_obj = '1' then -- Lançamentos de Valores para os Registros de Tabela Dinâmica
            --
            vn_fase := 15.1;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_lvtd rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '2' then -- Demonstrativo do Livro Caixa - Q100
            --
            vn_fase := 15.2;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_dlc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '3' then -- Ativ. Incentivadas de PJ em Geral para Inf. Econômicas X280
            --
            vn_fase := 15.3;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_aiie rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '4' then -- Operações com o Ext. – Exportações (Entr. de Divisas) X300
            --
            vn_fase := 15.4;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_oeeie rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '5' then -- Operações com o Exterior – Import. (Saída de Divisas) X320
            --
            vn_fase := 15.5;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_oeiie rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '6' then -- Identificação da Participação no Exterior - X340
            --
            vn_fase := 15.6;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_ipeie rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '7' then -- Comércio Eletrônico – Informação de Homepage/Servidor X410
            --
            vn_fase := 15.7;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_ceiie rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '8' then -- Royalties Receb. ou Pagos Benef. do Brasil e do Exter. X420
            --
            vn_fase := 15.8;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_rrbie rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '9' then -- Rend. Relativos Serv. Juros Div. Rec. do Brasil e Ext. X430
            --
            vn_fase := 15.9;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_rrrie rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '10' then -- Pag./Rem. Relat. Serv. Juros Divid. Receb. Brasil Ext. X450
            --
            vn_fase := 15.10;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_preie rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '11' then -- Pagamentos/Recebimentos do Exterior ou Não Residentes Y520
            --
            vn_fase := 15.11;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_penig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '12' then -- Discr. da Rec. de Vendas dos Estab. por Ativ. Econ. Y540
            --
            vn_fase := 15.12;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_drecig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '13' then -- Vendas a Comerc. Exportadora com Fim Específico de Exp. Y550
            --
            vn_fase := 15.13;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_vcfeig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '14' then -- Detalhamento das Exportações da Comercial Exportadora Y560
            --
            vn_fase := 15.14;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_decig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '15' then -- Demonstr. do Imposto de Renda e CSLL Retidos na Fonte Y570
            --
            vn_fase := 15.15;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_dicrfig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '16' then -- Doações a Campanhas Eleitorais Y580
            --
            vn_fase := 15.16;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_dceig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '17' then -- Ativos no Exterior Y590
            --
            vn_fase := 15.17;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_aeig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '18' then -- Identificação de Sócios ou Titular Y600
            --
            vn_fase := 15.18;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_isig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '19' then -- Rendimentos de Dirig. e Conselheiros–Imunes ou Isentas Y612
            --
            vn_fase := 15.19;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_rdiiig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '20' then -- Participações Avaliadas Pelo Mét. de Equivalência Patr. Y620
            --
            vn_fase := 15.20;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pameqpig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '21' then -- Fundos/Clubes de Investimento Y630
            --
            vn_fase := 15.21;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_fiig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '22' then -- Participações em Consórcios de Empresas Y640
            --
            vn_fase := 15.22;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pceig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '23' then -- Dados de Sucessoras Y660
            --
            vn_fase := 15.23;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_dsig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '24' then -- Demonstrativo das Diferenças na Adoção Inicial Y665
            --
            vn_fase := 15.24;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_ddaiig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '25' then -- Outras Informações (Lucro Real) Y671
            --
            vn_fase := 15.25;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_oilrig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '26' then -- Outras Informações (Lucro Presumido ou Lucro Arbitrado) Y672
            --
            vn_fase := 15.26;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_oilplaig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '27' then -- Optantes pelo Paes - Y690
            --
            vn_fase := 15.27;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_iopig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '28' then -- Tabela de Informações de Períodos Anteriore - Y720
            --
            vn_fase := 15.28;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_ipaig rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '29' then -- Inf. sobre Grupo Mult. Ent. Decl. - Decl. País-a-País W100
            --
            vn_fase := 15.29;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_imdp rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '30' then -- Observações Adicionais - Declaração País-a-País W300
            --
            vn_fase := 15.30;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_dpapoa rl
                                 where rl.loteintws_id = li.id );
            --
         end if;
         --
      elsif ev_cod_obj in('31','32') then --|Dados contabeis|--
         --
         vn_fase := 16;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_idsp rl
                              where rl.loteintws_id = li.id )
            and not exists ( select 1
                               from r_loteintws_ilc rli
                              where rli.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '33' then --|Produção diaria da usina|--
         --
         vn_fase := 17;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_pdu rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '36' then --|Informações de valores agregados|--
         --
         vn_fase := 18;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_iva rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '39' then --|Controle de créditos fiscais de ICMS|--
         --
         vn_fase := 19;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_ccficms rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '42' then --|Total de operações com cartão|--
         --
         vn_fase := 20;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_toc rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '45' then --|Informações da folha de pagamento|--
         --
         vn_fase := 21;
         --
         if vv_cod_tipo_obj = '1' then --informações de cadastro de trabalhadores--
            --
            vn_fase := 21.1;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_trab rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '2' then --Informações da lotação da folha de pagamento--
            --
            vn_fase := 21.2;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_lf rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '3' then --Informações rubricas da folha de pagamento--
            --
            vn_fase := 21.3;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_rf rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '4' then --Mestre da folha de pagamento--
            --
            vn_fase := 21.4;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_mfp rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '5' then --Informações da folha de pagamento--
            --
            vn_fase := 21.5;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_ifp rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '6' then --Contabilização da folha de pagamento--
            --
            vn_fase := 21.6;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_cfp rl
                                 where rl.loteintws_id = li.id );
            --
         end if;
         --
      elsif ev_cod_obj = '46' then --|Pagamentos de impostos no padrão para DCTF|--
         --
         vn_fase := 22;
         --
         if vv_cod_tipo_obj = '1' then --Pagamentos de impostos retidos(pcc)
            --
            vn_fase := 22.1;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_pir rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '2' then --Impostos retidossobre receita de serviços--
            --
            vn_fase := 22.2;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_irrpc rl
                                 where rl.loteintws_id = li.id );
            --
          elsif vv_cod_tipo_obj = '3' then -- Creditos DCTF
            --
            vn_fase := 22.3;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_cred_dctf cd
                                 where cd.loteintws_id = li.id );
            -- 
         end if;
         --
      elsif ev_cod_obj = '47' then --|Informações da DIRF|--
         --
         vn_fase := 23;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_ird rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '48' then --|Controle de produção de estoque|--
         --
         vn_fase := 24;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_pcpe rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '49' then --|Solicitação de consulta de cadastro|--
         --
         vn_fase := 25;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_scc rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '50' then --|Demais documentos e operações - Bloco F EFD contribuições|--
         --
         vn_fase := 26;
         --
         if vv_cod_tipo_obj = '1' then --Demais Doc. e Oper. Geradoras de Contribuições e Créditos--
            --
            vn_fase := 26.1;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_demdocopcc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '2' then --Bens Incorp.At.Imob.-Oper.Gerad.Créd.base Enc.Depr./Amort.--
            --
            vn_fase := 26.2;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_bematmobpc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '4' then --Crédito Presumido sobre Estoque de Abertura--
            --
            vn_fase := 26.3;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_cpeabertpc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '5' then --Operações da Ativ. Imobiliária - Unidade Imobiliária Vendida--
            --
            vn_fase := 26.4;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_oaimobvend rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '6' then --CONS.OP.PJ RG.TRIB.LUCRO PRES. INC. PIS/PASEP COF.REG.CX.--
            --
            vn_fase := 26.5;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_coipcrc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '7' then --CONS.OP.PJ RG.TRIB.LUCRO PRES.–REG.CX.(AP.CONTR.UN.MED.PR.)--
            --
            vn_fase := 26.6;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_coipcrcaum rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '8' then --Comp.Rec.Escrit.no Per.- Det.da Rec.Recebida pelo Reg.de cx.--
            --
            vn_fase := 26.7;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_crdrc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '9' then --CONS.OP.PJ RG.TRIB.LUCRO PRES.- INC.PIS/COF. REG COMPET.--
            --
            vn_fase := 26.8;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_coircomp rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '10' then --CONS.OP.PJ RG.TRIB.LUCRO PRES.-PIS/COF.REG.COMP-AP.UN.MED.PR--
            --
            vn_fase := 26.9;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_coircompaum rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '11' then --Contribuição Retida na Fonte--
            --
            vn_fase := 26.10;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_crfpc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '12' then --Deduções Diversas--
            --
            vn_fase := 26.11;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_deddpc rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '13' then --Créd. Decorrentes de Eventos de Incorporação, Fusão e Cisão--
            --
            vn_fase := 26.12;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_cdepc rl
                                 where rl.loteintws_id = li.id );
            --
         end if;
         --
      elsif ev_cod_obj = '51' then --|Integração de informações do Bloco I da EFD contribuições|--
         --
         vn_fase := 27;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_ibipc rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '52' then --|Declaração de informações imoiliarias - DIMOB|--
         --
         vn_fase := 28;
         --
         if vv_cod_tipo_obj = '1' then --Locação de imoveis - DIMOB--
            --
            vn_fase := 28.1;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_locacao rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '2' then --Incorporação de construção de imoveis - DIMOB--
            --
            vn_fase := 28.2;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_fic rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '3' then --Ficha de intermediáio da venda de imoveis - DIMOB--
            --
            vn_fase := 28.3;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_fiv rl
                                 where rl.loteintws_id = li.id );
            --
         end if;
         --
      elsif ev_cod_obj = '53' then --|Informações sobre exportação|--
         --
         vn_fase := 29;
         --
         delete
           from lote_int_ws li
          where li.id = en_loteintws_id
            and li.dm_st_proc not in (1, 2)
            and not exists ( select 1
                               from r_loteintws_ie rl
                              where rl.loteintws_id = li.id );
         --
      elsif ev_cod_obj = '55' then --|EFD-REINF - Retenções e Outras Informações Fiscais|--
         --
         vn_fase := 30;
         --
         if vv_cod_tipo_obj = '1' then --Recursos Recebidos por Associação Desportiva - R-2030--
            --
            vn_fase := 30.1;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_rrad rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '2' then --Recursos Repassados para Associação Desportiva - R-2040--
            --
            vn_fase := 30.2;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_rrpad rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '3' then --Comerc. da Produção por Prod. Rural PJ/Agroindústria - R2050--
            --
            vn_fase := 30.3;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_cprpja rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '4' then --Receita de Espetáculo Desportivo - R-3010--
            --
            vn_fase := 30.4;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_red rl
                                 where rl.loteintws_id = li.id );
            --
         elsif vv_cod_tipo_obj = '5' then --Parâmetros de Itens x Classificação do Tipo de Serviço REINF--
            --
            vn_fase := 30.5;
            --
            delete
              from lote_int_ws li
             where li.id = en_loteintws_id
               and li.dm_st_proc not in (1, 2)
               and not exists ( select 1
                                  from r_loteintws_eitsr rl
                                 where rl.loteintws_id = li.id );
            --
         end if;
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
      rollback;
      --
      raise_application_error(-20001, 'Erro na pk_vld_amb_ws.pkb_exclui_lote fase('||vn_fase||').'||SQLerrm);
      --
end pkb_exclui_lote;

-------------------------------------------------------------------------------------------------------
-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service
procedure pkb_validar_lote_int_ws ( en_loteintws_id in lote_int_ws.id%type)
is
   --
   vn_fase             number;
   vn_erro             number;
   vn_aguardar         number;
   vv_objintegr_cd     obj_integr.cd%type;
   vv_tipoobjintegr_cd tipo_obj_integr.cd%type;
   vn_loggenerico_id   Log_Generico.id%TYPE;
   vn_dm_st_proc       lote_int_ws.dm_st_proc%type;
   vn_tipoobjintegr_id tipo_obj_integr.id%type;
   --inicio 1979
   vn_util_rabbitmq        number := 0;-- variável que receberá dados da param_geral_sistema.PARAM_NAME = 'UTILIZA_RABBIT_MQ'
   MODULO_SISTEMA          constant number := pk_csf.fkg_ret_id_modulo_sistema('INTEGRACAO');
   GRUPO_SISTEMA           constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'CTRL_FILAS');
   vn_multorg_id           mult_org.id%type;
   vv_erro                 varchar2(4000);
   -- fim 1979
begin
   --
   vn_fase := 1;
   --
   if nvl(en_loteintws_id,0) > 0 then
      --
      begin
         select tipoobjintegr_id
           into vn_tipoobjintegr_id
           from lote_int_ws
          where id = en_loteintws_id;
      exception
         when others then
         vn_tipoobjintegr_id := 0;
      end;
         --
      if nvl(vn_tipoobjintegr_id,0) > 0 then
         --
         vn_fase := 2;
         --
         vn_aguardar := 0; -- Sempre dados do lote processado
         vn_erro     := 0;
         --
         vn_fase := 2.1;
         --
         begin
            --
            select oi.cd
                 , toi.cd
              into vv_objintegr_cd
                 , vv_tipoobjintegr_cd
              from tipo_obj_integr  toi
                 , obj_integr       oi
             where toi.id = vn_tipoobjintegr_id
               and oi.id  = toi.objintegr_id;
            --
         exception
            when others then
               vv_objintegr_cd     := null;
               vv_tipoobjintegr_cd := null;
         end;
         --
         vn_fase := 3;
         --
         if vv_objintegr_cd = '1' then -- Cadastros Gerais
            --
            vn_fase := 3.1;
            -- Procedimento de validação de dados de Cadastro, oriundos de Integração por Web-Service
            pk_vld_amb_cad.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                      , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                      , sn_erro              => vn_erro
                                      );
            --
         elsif vv_objintegr_cd = '2' then -- Inventário de estoque de produtos
            --
            vn_fase := 3.2;
            -- Procedimento de validação de dados de Inventário, oriundos de Integração por Web-Service
            pk_vld_inv.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                  , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                  , sn_erro              => vn_erro
                                  );
            --
         elsif vv_objintegr_cd = '3' then -- 
            --
            vn_fase := 3.3;
            --
            pk_vld_amb_ecf.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                      , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                      , sn_erro              => vn_erro
                                      );                                    
            --
          elsif vv_objintegr_cd = '12' then -- Cupom Fiscal
            --
            vn_fase := 3.4;
             --
            pk_vld_amb_cup_sat.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                          , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                          , sn_erro              => vn_erro
                                          );                          
             
                                     
            --
         elsif vv_objintegr_cd = '4' then -- Conhecimento de Transporte
            --
            vn_fase := 3.4;
            --
            if vv_tipoobjintegr_cd in ('1', '3') then -- Emissão Própria de Conhecimento de Transporte
               --
               vn_fase := 3.31;
               --
               pk_valida_ambiente_ct.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                                , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                                , sn_erro              => vn_erro
                                                , sn_aguardar          => vn_aguardar
                                                );
               --
               vn_fase := 3.311;
               --			   
               pk_vld_amb_d100.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                          , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                          , sn_erro              => vn_erro
                                          );												
               --
            elsif vv_tipoobjintegr_cd = '2' then -- Terceiros de Conhecimento de Transporte
               --
               vn_fase := 3.32;
               --
               pk_vld_amb_d100.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                          , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                          , sn_erro              => vn_erro
                                          );
               --
            else
               --
               vn_fase := 3.39;
               --
            end if;
            --
         elsif vv_objintegr_cd = '5' then -- Notas Fiscais de Serviços Contínuos (Água, Luz, etc.)
            --
            vn_fase := 3.5;
            -- Procedimento de validação de dados de Notas Fiscais de Serviços Continuos, oriundos de Integração por Web-Service
            pk_vld_amb_sc.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                     , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                     , sn_erro              => vn_erro
                                     );
            --
         elsif vv_objintegr_cd in ('6','16') then -- 6-Notas Fiscais Mercantis  / 16-XML Sefaz - Nota Fiscal Mercantil
            --
            vn_fase := 3.6;
            --
	    -- Notas Fiscais demais modelos menos modelo 65
            pk_valida_ambiente.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                          , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                          , sn_erro              => vn_erro
                                          , sn_aguardar          => vn_aguardar
                                          );
            --
         elsif vv_objintegr_cd = '7' then -- Notas Fiscais de Serviços EFD
            --
            vn_fase := 3.7;
            --
            pk_valida_ambiente_nfs.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                              , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                              , sn_erro              => vn_erro
                                              , sn_aguardar          => vn_aguardar
                                              );
            --
         elsif vv_objintegr_cd = '8' then -- C. I. A. P.
            --
            vn_fase := 3.8;
            --
            pk_vld_amb_ciap.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                       , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                       , sn_erro              => vn_erro
                                       );
            --
         elsif vv_objintegr_cd = '9' then -- Crédito Acumulado de ICMS SP
            --
            vn_fase := 3.9;
            --
            pk_valida_ecredac.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                         , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                         , sn_erro              => vn_erro
                                         );
            --
         elsif vv_objintegr_cd = '13' then -- Notas Fiscais Mercantis NFCE (modelo 65)
            --
            vn_fase := 3.10;
            --
            pk_valida_ambiente_nfce.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                               , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                               , sn_erro              => vn_erro
                                               , sn_aguardar          => vn_aguardar
                                               );
            --
         elsif vv_objintegr_cd = '19' then -- Usuários
            --
            vn_fase := 3.11;
            --
            pk_vld_amb_usuario.pkb_int_ws ( en_loteintws_id  => en_loteintws_id
                                          , sn_erro          => vn_erro
                                          );
            --
         elsif vv_objintegr_cd = '26' then -- Calculadora Fiscal
            --
            vn_fase := 3.12;
            --
            pk_vld_amb_calc_fiscal.pkb_int_ws ( en_loteintws_id     => en_loteintws_id
                                              , en_tipoobjintegr_id => vn_tipoobjintegr_id
                                              , sn_erro             => vn_erro
                                              );
            --
         elsif vv_objintegr_cd = '27' then -- SPED ECF
            --
            vn_fase := 3.13;
            --
            pk_vld_amb_secf.pkb_int_ws ( en_loteintws_id     => en_loteintws_id
                                       , en_tipoobjintegr_id => vn_tipoobjintegr_id
                                       , sn_erro             => vn_erro
                                       );
            --
         elsif vv_objintegr_cd = '32' then -- Dados Contábil
            --
            vn_fase := 3.14;
            --
            pk_vld_amb_ecd.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                      , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                      , sn_erro              => vn_erro
                                      );
            --
         elsif vv_objintegr_cd = '33' then -- Produção Diária de Usina
            --
            vn_fase := 3.15;
            --
            pk_vld_amb_prod_dia_usina.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                                 , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                                 , sn_erro              => vn_erro
                                                 );
            --
         elsif vv_objintegr_cd = '36' then -- Informações de Valores Agregados
            --
            vn_fase := 3.16;
            --
            pk_vld_iva.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                  , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                  , sn_erro              => vn_erro
                                  );
            --
         elsif vv_objintegr_cd = '39' then -- Controle de Creditos Fiscais de ICMS
            --
            vn_fase := 3.17;
            --
            pk_vld_cf_icms.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                      , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                      , sn_erro              => vn_erro
                                      );
            --
         elsif vv_objintegr_cd = '42' then -- Total de Operações com Cartão
            --
            vn_fase := 3.18;
            --
            pk_vld_tot_op_cart.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                          , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                          , sn_erro              => vn_erro
                                          );
            --
         elsif vv_objintegr_cd = '45' then -- Informacoes da Folha de Pagamento
            --
            vn_fase := 3.19;
            --
            pk_vld_manad.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                    , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                    , sn_erro              => vn_erro
                                    );
            --
         elsif vv_objintegr_cd = '46' then -- Pagamento de Impostos no padrao para DCTF
            --
            vn_fase := 3.20;
            --
            pk_vld_pgto_imp_ret.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                           , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                           , sn_erro              => vn_erro
                                           );
            --
         elsif vv_objintegr_cd = '47' then -- Informações da DIRF
            --
            vn_fase := 3.21;
            --
            pk_vld_amb_dirf.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                       , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                       , sn_erro              => vn_erro
                                       );
            --
         elsif vv_objintegr_cd = '48' then -- Controle da Produção e do Estoque
            --
            vn_fase := 3.22;
            --
            pk_vld_amb_cpe.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                      , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                      , sn_erro              => vn_erro
                                      );
            --
         elsif vv_objintegr_cd = '49' then -- Solicitação de consulta de cadastros
            --
            vn_fase := 3.23;
            --
            pk_vld_amb_cons_cad.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                           , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                           , sn_erro              => vn_erro
                                           , sn_aguardar          => vn_aguardar
                                           );
         elsif vv_objintegr_cd = '50' then -- Demais Documento e Obrigações
            --
            vn_fase := 3.24;
            --
            pk_vld_amb_ddo.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                      , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                      , sn_erro              => vn_erro
                                      );
         elsif vv_objintegr_cd = '52' then -- Declaração de Informações Imobiliárias - DIMOB
            --
            vn_fase := 3.25;
            --
            pk_vld_amb_dimob.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                        , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                        , sn_erro              => vn_erro
                                        , sn_aguardar          => vn_aguardar
                                        );
            --
         elsif vv_objintegr_cd = '53' then -- Informações Sobre Exportação
            --
            vn_fase := 3.26;
            --
            pk_vld_infexp.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                     , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                     , sn_erro              => vn_erro
                                     );
            --
         elsif vv_objintegr_cd = '55' then -- EFD-REINF
            --
            vn_fase := 3.27;
            --
            pk_vld_amb_reinf.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                        , en_tipoobjintegr_id  => vn_tipoobjintegr_id
                                        , sn_erro              => vn_erro
                                        );
            --
         elsif vv_objintegr_cd = '56' then -- PEDIDOS
            --
            vn_fase := 3.28;
            --
            pk_vld_amb_pedido.pkb_int_ws ( en_loteintws_id      => en_loteintws_id
                                         , ev_tipoobjintegr_cd  => vv_tipoobjintegr_cd
                                         , sn_erro              => vn_erro
                                         , sn_aguardar          => vn_aguardar
                                         );
            --
         else
            --
            vn_fase := 3.99;
            --
            pk_log_generico.gv_mensagem := 'Objeto de integração "' || vv_objintegr_cd || '", não implementado para integração por web-service.';
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => pk_log_generico.gv_mensagem
                                             , ev_resumo          => pk_log_generico.gv_mensagem
                                             , en_tipo_log        => pk_log_generico.informacao
                                             , en_referencia_id   => en_loteintws_id
                                             , ev_obj_referencia  => 'LOTE_INT_WS'
                                             );
            --
         end if;
         --
         if nvl(vn_aguardar,0) <= 0 then
            --
            vn_fase := 4;
            --
            if nvl(vn_erro,0) = 1 then
               --
               vn_dm_st_proc := 4; --Processado com Erro
               --
            else
               --
               vn_dm_st_proc := 3; --Processado
               --
            end if;
            --
            vn_fase := 4.1;
            --
            if vv_objintegr_cd <> '6'
               or vn_dm_st_proc <> 3
               or vv_tipoobjintegr_cd <> '1' 
               OR vn_util_rabbitmq = 0 then
               --
            pkb_seta_st_proc ( en_loteintws_id     => en_loteintws_id
                             , en_dm_st_proc       => vn_dm_st_proc
                             );
            --
            end if;
            --
            vn_fase := 4.2;
            --
            pk_log_generico.gv_mensagem := 'Finalizado a validação dos registros.';
            --
            pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                             , ev_mensagem        => pk_log_generico.gv_mensagem
                                             , ev_resumo          => pk_log_generico.gv_mensagem
                                             , en_tipo_log        => pk_log_generico.informacao
                                             , en_referencia_id   => en_loteintws_id
                                             , ev_obj_referencia  => 'LOTE_INT_WS'
                                             );
            --
         else -- nvl(vn_aguardar,0) <= 0 -- nesse momento, alterar a situação do lote para 2-Em Processamento
            --
            vn_fase := 4.3;
            --
            -- Alteração lote para "2-Em Processamento"
            pkb_seta_st_proc ( en_loteintws_id     => en_loteintws_id
                             , en_dm_st_proc       => 2 -- Em Processamento
                             );
            --
            vn_fase := 4.4;
            --
            -- inicio 1979
              begin
                 select distinct multorg_id
               into vn_multorg_id
               from lote_int_ws
                  where id = en_loteintws_id;
            exception
            when no_data_found then
                 declare
                 vn_loggenerico_id  log_generico.id%TYPE;
                begin
                 --
                 pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                  , ev_mensagem        => 'Mult_org não encontrado. erro: '||sqlerrm
                                  , ev_resumo          => 'Mult_org não encontrado. Entrar em contato com o Suporte!'
                                  , en_tipo_log        => pk_log_generico.erro_de_sistema
                                  , en_referencia_id   => en_loteintws_id
                                  , ev_obj_referencia  => 'LOTE_INT_WS'
                                  );
                 --
                exception
                 when others then
                  null;
                end;
            when others then 
                 declare
                 vn_loggenerico_id  log_generico.id%TYPE;
                begin
                 --
                 pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                  , ev_mensagem        => 'Falha ao recuperar o Mult_org. erro: '||sqlerrm
                                  , ev_resumo          => 'Falha ao recuperar o Mult_org. Entrar em contato com o Suporte!'
                                  , en_tipo_log        => pk_log_generico.erro_de_sistema
                                  , en_referencia_id   => en_loteintws_id
                                  , ev_obj_referencia  => 'LOTE_INT_WS'
                                  );
                 --
                exception
                 when others then
                  null;
                end;
            end;
            --
            -- Busca o Parametro para checar se 
    		--INI 1979
		    if not pk_csf.fkg_ret_vl_param_geral_sistema ( en_multorg_id => vn_multorg_id,
														   en_empresa_id => null,
														   en_modulo_id  => MODULO_SISTEMA,
														   en_grupo_id   => GRUPO_SISTEMA,
														   ev_param_name => 'UTILIZA_RABBIT_MQ',
														   sv_vlr_param  => vn_util_rabbitmq,
														   sv_erro       => vv_erro) then
			  --
			  vn_util_rabbitmq := 0;
			  --
			 end if; 
			 -- FIM 1979
			--
			if vv_objintegr_cd = '6' and vv_tipoobjintegr_cd = '1' and vn_util_rabbitmq = 1 then --1979
               --
               pk_csf_rabbitmq.pb_valida_loteintws(en_loteintws_id);
               --
            end if;
      			
            --fim 1979
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
      pkb_seta_st_proc ( en_loteintws_id     => en_loteintws_id
                       , en_dm_st_proc       => 5 -- Rejeitado
                       );
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_vld_amb_cad.pkb_validar_lote_int_ws fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_log_generico.gv_mensagem
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.erro_de_sistema
                                          , en_referencia_id   => en_loteintws_id
                                          , ev_obj_referencia  => 'LOTE_INT_WS'
                                          );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_validar_lote_int_ws;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração não tem relação com a Emissão de Documentos Fiscais
procedure pkb_validar_lote_nao_emissao ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase             number;
   vn_erro             number;
   vn_aguardar         number;
   en_loteintws_id     lote_int_ws.id%type;
   vv_objintegr_cd     obj_integr.cd%type;
   vv_tipoobjintegr_cd tipo_obj_integr.cd%type;
   vn_loggenerico_id   Log_Generico.id%TYPE;
   vn_dm_st_proc       lote_int_ws.dm_st_proc%type;
   --vn_qtde             number := 0;
   --
   cursor c_dados is
   select l.id                loteintws_id
        , l.multorg_id
        , l.tipoobjintegr_id
     from lote_int_ws  l
    where 1 = 1
      and l.multorg_id       = en_multorg_id
      and l.dm_st_proc       in (1, 2) -- Recebido/Em Processamento
      and l.dm_processa_xml  = 1 -- Sim
    order by l.id;
   --
begin
   --
   vn_fase := 1;
   --
   --vn_qtde := 0;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
      begin
         --
         select oi.cd
           into vv_objintegr_cd
           from tipo_obj_integr  toi
              , obj_integr       oi
          where toi.id = rec.tipoobjintegr_id
            and oi.id  = toi.objintegr_id;
         --
      exception
         when others then
            vv_objintegr_cd := null;
      end;
      --
      vn_fase := 2.1;
      --
      vv_tipoobjintegr_cd := pk_csf.fkg_tipoobjintegr_cd ( en_tipoobjintegr_id => rec.tipoobjintegr_id );
      --
      vn_fase := 2.2;
      --
      if vv_objintegr_cd not in ( '4', '5', '6', '7', '13', '16' ) then
         --
         --vn_qtde := nvl(vn_qtde,0) + 1;
         --
         pkb_validar_lote_int_ws ( en_loteintws_id      => rec.loteintws_id );
         --
         --if nvl(vn_qtde,0) = 10 then -- ler 10 lotes por vez, para eliminar o rownum do cursor de leitura dos lotes
         --   exit;
         --end if;
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      pkb_seta_st_proc ( en_loteintws_id     => en_loteintws_id
                       , en_dm_st_proc       => 5 -- Rejeitado
                       );
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_vld_amb_cad.pkb_validar_lote_nao_emissao fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_log_generico.gv_mensagem
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.erro_de_sistema
                                          , en_referencia_id   => en_loteintws_id
                                          , ev_obj_referencia  => 'LOTE_INT_WS'
                                          );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_validar_lote_nao_emissao;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração não tem relação com a Emissão de Documentos Fiscais
procedure pkb_vld_lote_nao_emissao
is
   --
   vn_fase             number;
   vn_erro             number;
   --
   cursor c_mo is
   select mo.*
     from mult_org     mo
    where 1 = 1
      and mo.dm_situacao     = 1 -- Ativo
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   for rec_mo in c_mo loop
      exit when c_mo%notfound or (c_mo%notfound) is null;
      --
      vn_fase := 2;
      --
      pkb_validar_lote_nao_emissao ( en_multorg_id => rec_mo.id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_vld_amb_cad.pkb_vld_lote_nao_emissao fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_log_generico.gv_mensagem
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.erro_de_sistema
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => 'LOTE_INT_WS'
                                          );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_vld_lote_nao_emissao;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração tem relação com a Emissão de Documentos Fiscais
-- e Situação "1-Recebido", sempre de 10 em 10
procedure pkb_validar_lote_emiss_st_rec ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase             number;
   vn_erro             number;
   vn_aguardar         number;
   en_loteintws_id     lote_int_ws.id%type;
   vv_objintegr_cd     obj_integr.cd%type;
   vv_tipoobjintegr_cd tipo_obj_integr.cd%type;
   vn_loggenerico_id   Log_Generico.id%TYPE;
   vn_dm_st_proc       lote_int_ws.dm_st_proc%type;
   --vn_qtde             number := 0;
   vn_util_rabbitmq        number := 0;-- variável que receberá dados da param_geral_sistema.PARAM_NAME = 'UTILIZA_RABBIT_MQ'
   MODULO_SISTEMA          constant number := pk_csf.fkg_ret_id_modulo_sistema('INTEGRACAO');
   GRUPO_SISTEMA           constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'CTRL_FILAS');
   vv_erro                 varchar2(4000);
   --
   cursor c_dados is
   SELECT L.ID                LOTEINTWS_ID
        , L.MULTORG_ID
        , L.TIPOOBJINTEGR_ID
     FROM LOTE_INT_WS  L
        , TIPO_OBJ_INTEGR  TOI
        , OBJ_INTEGR       OI
      WHERE 1=1
      AND (vn_util_rabbitmq    = 0 AND OI.CD IN ( '4', '5', '6', '7','16' ) 
           OR vn_util_rabbitmq = 1 AND OI.CD IN ('7' ) ) -- O OBJ_INTEGR.CD in 4,5,6 FOI COMENTADO POIS SERÂ¿ TRATADO NO RABBITMQ / AZONI 26/06/2020
      AND L.DM_ST_PROC       IN (1) -- RECEBIDO
      AND L.DM_PROCESSA_XML  = 1 -- SIM
      AND TOI.OBJINTEGR_ID   = OI.ID
      AND L.TIPOOBJINTEGR_ID = TOI.ID
      AND L.MULTORG_ID       = EN_MULTORG_ID
    ORDER BY L.ID;
   --
begin
   --
   vn_fase := 1;
   --
   --vn_qtde := 0;
   --
   if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => en_multorg_id,
                                                 en_empresa_id => NULL,
                                                 en_modulo_id  => MODULO_SISTEMA,
                                                 en_grupo_id   => GRUPO_SISTEMA,
                                                 ev_param_name => 'UTILIZA_RABBIT_MQ',
                                                 sv_vlr_param  => vn_util_rabbitmq,
                                                 sv_erro       => vv_erro) then
          --
      vn_util_rabbitmq := 0;
      --
   end if;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
         --
         --vn_qtde := nvl(vn_qtde,0) + 1;
         --
         pkb_validar_lote_int_ws ( en_loteintws_id => rec.loteintws_id);
         --
         --if nvl(vn_qtde,0) = 10 then -- ler 10 lotes por vez, para eliminar o rownum do cursor de leitura dos lotes
         --   exit;
         --end if;
         --
   end loop;
   --
exception
   when others then
      --
      pkb_seta_st_proc ( en_loteintws_id     => en_loteintws_id
                       , en_dm_st_proc       => 5 -- Rejeitado
                       );
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_vld_amb_cad.pkb_validar_lote_emiss_st_rec fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_log_generico.gv_mensagem
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.erro_de_sistema
                                          , en_referencia_id   => en_loteintws_id
                                          , ev_obj_referencia  => 'LOTE_INT_WS'
                                          );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_validar_lote_emiss_st_rec;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração tem relação com a Emissão de Documentos Fiscais
-- e Situação "1-Recebido", sempre de 10 em 10
procedure pkb_vld_lote_emiss_st_rec
is
   --
   vn_fase             number;
   vn_erro             number;
   --
   cursor c_mo is
   select mo.*
     from mult_org     mo
    where 1 = 1
      and mo.dm_situacao     = 1 -- Ativo
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   for rec_mo in c_mo loop
      exit when c_mo%notfound or (c_mo%notfound) is null;
      --
      vn_fase := 2;
      --
      pkb_validar_lote_emiss_st_rec ( en_multorg_id => rec_mo.id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_vld_amb_cad.pkb_vld_lote_emiss_st_rec fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_log_generico.gv_mensagem
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.erro_de_sistema
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => 'LOTE_INT_WS'
                                          );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_vld_lote_emiss_st_rec;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração tem relação com a Emissão de Documentos Fiscais
-- e Situação "2-Em Processamento"
procedure pkb_validar_lote_emiss_st_proc ( en_multorg_id in mult_org.id%type )
is
   --
   vn_fase             number;
   vn_erro             number;
   vn_aguardar         number;
   en_loteintws_id     lote_int_ws.id%type;
   vv_objintegr_cd     obj_integr.cd%type;
   vv_tipoobjintegr_cd tipo_obj_integr.cd%type;
   vn_loggenerico_id   Log_Generico.id%TYPE;
   vn_dm_st_proc       lote_int_ws.dm_st_proc%type;
   vn_util_rabbitmq        number := 0;-- variável que receberá dados da param_geral_sistema.PARAM_NAME = 'UTILIZA_RABBIT_MQ'
   MODULO_SISTEMA          constant number := pk_csf.fkg_ret_id_modulo_sistema('INTEGRACAO');
   GRUPO_SISTEMA           constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'CTRL_FILAS');
   vn_multorg_id           mult_org.id%type;
   vv_erro                 varchar2(4000);
   --
   cursor c_mo is
   select mo.*
     from mult_org     mo
    where 1 = 1
      and mo.dm_situacao     = 1 -- Ativo
    order by 1;
   --
   cursor c_dados is
    SELECT L.ID                LOTEINTWS_ID
        , L.MULTORG_ID
        , L.TIPOOBJINTEGR_ID
     FROM LOTE_INT_WS  L
        , TIPO_OBJ_INTEGR  TOI
        , OBJ_INTEGR       OI
      WHERE 1=1
      AND OI.CD IN ( '4', '5', '6', '7','13','16')
      AND L.DM_ST_PROC       = 2 -- RECEBIDO
      AND L.DM_PROCESSA_XML  = 1 -- SIM
      AND TOI.OBJINTEGR_ID   = OI.ID
      AND L.TIPOOBJINTEGR_ID = TOI.ID
      AND L.MULTORG_ID       = EN_MULTORG_ID
      AND (vn_util_rabbitmq = 0 or (vn_util_rabbitmq = 1 and (OI.CD <> '6' OR TOI.CD NOT IN ('1','3'))))
    ORDER BY L.ID;
   --
begin
   --
   vn_fase := 1;
   --
   if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => en_multorg_id,
                               en_empresa_id => null,
                               en_modulo_id  => MODULO_SISTEMA,
                               en_grupo_id   => GRUPO_SISTEMA,
                               ev_param_name => 'UTILIZA_RABBIT_MQ',
                               sv_vlr_param  => vn_util_rabbitmq,
                               sv_erro       => vv_erro) then
          --
          vn_util_rabbitmq := 0;
          --
   end if;
   --
   vn_fase := 1.2;
   --
   for rec in c_dados loop
      exit when c_dados%notfound or (c_dados%notfound) is null;
      --
      vn_fase := 2;
      --
         --
         pkb_validar_lote_int_ws ( en_loteintws_id => rec.loteintws_id);
         --
   end loop;
   --
exception
   when others then
      --
      pkb_seta_st_proc ( en_loteintws_id     => en_loteintws_id
                       , en_dm_st_proc       => 5 -- Rejeitado
                       );
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_vld_amb_cad.pkb_validar_lote_emiss_st_proc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_log_generico.gv_mensagem
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.erro_de_sistema
                                          , en_referencia_id   => en_loteintws_id
                                          , ev_obj_referencia  => 'LOTE_INT_WS'
                                          );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_validar_lote_emiss_st_proc;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração tem relação com a Emissão de Documentos Fiscais
-- e Situação "2-Em Processamento"
procedure pkb_vld_lote_emiss_st_proc
is
   --
   vn_fase             number;
   vn_erro             number;
   --
   cursor c_mo is
   select mo.*
     from mult_org     mo
    where 1 = 1
      and mo.dm_situacao     = 1 -- Ativo
    order by 1;
   --
begin
   --
   vn_fase := 1;
   --
   for rec_mo in c_mo loop
      exit when c_mo%notfound or (c_mo%notfound) is null;
      --
      vn_fase := 2;
      --
      pkb_validar_lote_emiss_st_proc ( en_multorg_id => rec_mo.id );
      --
   end loop;
   --
exception
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_vld_amb_cad.pkb_vld_lote_emiss_st_proc fase(' || vn_fase || '): ' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                          , ev_mensagem        => pk_log_generico.gv_mensagem
                                          , ev_resumo          => pk_log_generico.gv_mensagem
                                          , en_tipo_log        => pk_log_generico.erro_de_sistema
                                          , en_referencia_id   => null
                                          , ev_obj_referencia  => 'LOTE_INT_WS'
                                          );
         --
      exception
         when others then
            null;
      end;
      --
end pkb_vld_lote_emiss_st_proc;

-------------------------------------------------------------------------------------------------------

end pk_vld_amb_ws;
/
