create or replace package body csf_own.pk_relac_ped_nf is
--
----------------------------------------------------------------------------------------------------------
-- Procedimento para gravar o log_generico
----------------------------------------------------------------------------------------------------------
procedure pkb_grava_log_generico (en_referencia_id in log_generico_nf_ped.referencia_id%type
                                , en_tipo_log      in log_generico_nf_ped.csftipolog_id%type)
is
begin
   --
   pk_csf_api_pedido.pkb_log_generico_nf_ped ( sn_loggenericonfped_id   => gn_loggenerico_id
                                             , ev_mensagem              => gv_resumo_log || gv_mensagem_log
                                             , ev_resumo                => gv_mensagem_log
                                             , en_tipo_log              => en_tipo_log
                                             , en_referencia_id         => en_referencia_id
                                             , ev_obj_referencia        => gv_obj_referencia
                                             , en_empresa_id            => gn_empresa_id
                                             , en_dm_impressa           => 0
                                             );
   --
   if en_tipo_log in(ERRO_DE_VALIDACAO, ERRO_DE_SISTEMA) then
      gn_erro := gn_erro + 1;
   end if;
   --
end pkb_grava_log_generico;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que carrega os dados da nota fiscal
----------------------------------------------------------------------------------------------------------
procedure pkb_dados_imp_itemnf_ped ( en_itemnf_id     in item_nota_fiscal.id%type
                                   , en_itemnfped_id  in item_nf_ped.id%type
                                   , en_itempedido_id in item_pedido.id%type
                                   ) is
   --
   vn_fase              number := null;
   vn_impitemped_id     imp_itemped.id%type;
   vn_impitemnfped_id   imp_itemnf_ped.id%type;
   vb_existe_impinfp    boolean := False;
   vv_origem_imposto    varchar2(1) := 'N';
   --
begin
   --
   vn_fase := 1;
   --
   -- Busca pelo parametro do sistema se vai utilizar o imposto da nota ou do pedido
   gv_erro := '';
   if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => gn_multorg_id,
                                                 en_empresa_id => gn_empresa_id,
                                                 en_modulo_id  => MODULO_SISTEMA,
                                                 en_grupo_id   => GRUPO_PARAM_RECEB_NF,
                                                 ev_param_name => 'ORIGEM_IMPOSTO_NF',
                                                 sv_vlr_param  => vv_origem_imposto,
                                                 sv_erro       => gv_erro) then
      --
      gv_mensagem_log := 'Foi encontrado um erro ao buscar o parâmetro de origem do imposto da nota fiscal - pk_relac_ped_nf.pkb_dados_imp_itemnf_ped'||chr(13)||
                         'Erro Retornado: '||gv_erro;
      --
      pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
      --
   end if;
   --
   vn_fase := 2;
   --
   for rec_imp in c_imp ( en_itemnf_id ) loop
      exit when c_imp%notfound or (c_imp%notfound) is null;
      --
      vn_fase := 3;
      --
      if nvl(en_itempedido_id,0) > 0 then
         --
         vn_fase := 4;
         --
         if not pk_csf_pedido.fkg_retorna_impitemped_id ( en_itempedido_id  => en_itempedido_id
                                                        , en_tipoimp_id     => rec_imp.tipoimp_id
                                                        , sn_impitemped_id  => vn_impitemped_id
                                                        , sv_erro           => gv_mensagem_log) then

            --
            if gv_mensagem_log is not null then
               --
               pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
               --
            end if;
            --
         end if;
         --
      else
         --
         vn_fase := 5;
         --
         vn_impitemped_id := null;
         --
      end if;
      --
      vn_fase := 6;
      --
      -- Verifica se já existe a nota_fiscal_ped para inserir ou atualizar
      begin
         select distinct 1
            into gn_aux
         from imp_itemnf_ped iip
         where iip.itemnfped_id  = en_itemnfped_id
           and iip.tipoimp_id    = rec_imp.tipoimp_id
           and iip.dm_tipo       = rec_imp.dm_tipo;
         --
         vb_existe_impinfp := True;
         --
      exception
         when no_data_found then
            --
            vb_existe_impinfp := False;
            --
      end;
      --
      if not vb_existe_impinfp then
         begin
            select impitemnfped_seq.nextval
              into vn_impitemnfped_id
              from dual;
         exception
            when others then
               vn_impitemnfped_id := null;
         end;
         --
         insert into imp_itemnf_ped ( id
                                    , itemnfped_id
                                    , impitemnf_id
                                    , tipoimp_id
                                    , dm_tipo
                                    , vl_base_calc
                                    , aliq_apli
                                    , impitemped_id
                                    , vl_imp_trib
                                    , dt_ult_confronto)
                             values ( vn_impitemnfped_id
                                    , en_itemnfped_id
                                    , rec_imp.id
                                    , rec_imp.tipoimp_id
                                    , rec_imp.dm_tipo
                                    , case nvl(vv_origem_imposto,'N') when 'N' then rec_imp.vl_base_calc_nf else rec_imp.vl_base_calc_ped end
                                    , case nvl(vv_origem_imposto,'N') when 'N' then rec_imp.aliq_apli_nf else rec_imp.aliq_apli_ped end
                                    , vn_impitemped_id
                                    , case nvl(vv_origem_imposto,'N') when 'N' then rec_imp.vl_imp_trib_nf else rec_imp.vl_imp_trib_ped end
                                    , sysdate
                                    );
         -- Devido a trigger T_A_I_U_D_IMP_ITEMNF_PED_01 ser AUTONOMOUS_TRANSACTION, preciso comitar aqui
         commit;
         --
      else
         --
         update imp_itemnf_ped iip set
              itemnfped_id     =  en_itemnfped_id
            , impitemnf_id     =  rec_imp.id
            , tipoimp_id       =  rec_imp.tipoimp_id
            , dm_tipo          =  rec_imp.dm_tipo
            , vl_base_calc     =  case nvl(vv_origem_imposto,'N') when 'N' then rec_imp.vl_base_calc_nf else rec_imp.vl_base_calc_ped end
            , aliq_apli        =  case nvl(vv_origem_imposto,'N') when 'N' then rec_imp.aliq_apli_nf else rec_imp.aliq_apli_ped end
            , impitemped_id    =  vn_impitemped_id
            , vl_imp_trib      =  case nvl(vv_origem_imposto,'N') when 'N' then rec_imp.vl_imp_trib_nf else rec_imp.vl_imp_trib_ped end
            , dt_ult_confronto = sysdate
         where iip.itemnfped_id  = en_itemnfped_id
           and iip.tipoimp_id    = rec_imp.tipoimp_id
           and iip.dm_tipo       = rec_imp.dm_tipo
           and gt_row_notafiscal_ped.dm_st_proc  in (0,1,2,7)   -- Só permite atualizar os dados da nota se estiver com algum destes dm_st_proc
           and gt_row_notafiscal_ped.dm_edicao   = 0            -- Não permitir sobrepor os dados caso tenha tido edição por tela
           and rec_imp.dm_edicao                 = 0;           -- Não permitir sobrepor os dados caso tenha editado ou duplicado o item
         --
         commit;
         --
      end if;
      --
   end loop;
   --
   vn_fase := 7;
   --
   -- Insere os impostos padrões (zerados) mesmo não estando na nota
   begin
      insert into IMP_ITEMNF_PED(id,
                                 itemnfped_id,
                                 impitemnf_id,
                                 tipoimp_id,
                                 dm_tipo,
                                 vl_base_calc,
                                 aliq_apli,
                                 impitemped_id,
                                 vl_imp_trib)
      select impitemnfped_seq.nextval,
             vt.*
      from (
         select  en_itemnfped_id itemnfped_id
               , NULL            impitemnf_id
               , TI.ID           tipoimp_id
               , 0               dm_tipo        -- 0-IMPOSTO / 1-RETENÇÃO
               , 0               vl_base_calc
               , 0               aliq_apli
               , null            impitemped_id
               , 0               vl_imp_trib
           from TIPO_IMPOSTO TI
          where ti.cd in (1,2,3,4,5,6)
            and not exists (select 1
                             from IMP_ITEMNF_PED IIP
                            where iip.tipoimp_id = ti.id
                              and iip.dm_tipo    = 0
                              and itemnfped_id   = en_itemnfped_id)
         UNION ALL ---------------------------------------------------
         select  en_itemnfped_id itemnfped_id
               , NULL            impitemnf_id
               , TI.ID           tipoimp_id
               , 1               dm_tipo        -- 0-IMPOSTO / 1-RETENÇÃO
               , 0               vl_base_calc
               , 0               aliq_apli
               , null            impitemped_id
               , 0               vl_imp_trib
           from TIPO_IMPOSTO TI
          where ti.cd in (4,5,6,11,12,13,14)
            and not exists (select 1
                             from IMP_ITEMNF_PED IIP
                            where iip.tipoimp_id = ti.id
                              and iip.dm_tipo    = 1
                              and itemnfped_id   = en_itemnfped_id)
      )vt;
      --
      commit;
      --
   exception
     when no_data_found then
          null; -- caso não encontre imposto não fazer nada.
     when others then
         --
         gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_dados_imp_itemnf_ped fase(' || vn_fase || '):' || sqlerrm;
         pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_SISTEMA);
         --
   END;
   --
exception
   when others then
      --
      pk_csf_api_pedido.gv_cabec_log    := 'Inserção na tabela dos dados dos impostos da nota fiscal';
      pk_csf_api_pedido.gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_dados_imp_itemnf_ped fase(' || vn_fase || '):' || sqlerrm;
      --
      raise_application_error (-20101, pk_csf_api_pedido.gv_mensagem_log);
      --
end pkb_dados_imp_itemnf_ped;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que carrega os dados do item da nota fiscal
----------------------------------------------------------------------------------------------------------
procedure pkb_dados_item_nf_ped ( en_notafiscal_id    in nota_fiscal.id%type
                                , en_notafiscalped_id in nota_fiscal_ped.id%type
                                , en_pedido_id_orignf in pedido.id%type
                                ) is
   --
   vn_fase                   number          := null;
   vn_itempedido_id          item_pedido.id%type;
   vn_itemnfped_id           item_nf_ped.id%type;
   vn_dm_st_proc             item_nf_ped.dm_st_proc%type;
   vn_pedido_id_origitem     pedido.id%type;
   vn_item_id                item_nf_ped.item_id%type;
   vv_cod_item               item.cod_item%type;
   vv_descr_item             item.descr_item%type;   
   vn_qtd_itens_ins          number          := null;
   vb_existe_infp            boolean         := False;
   vn_fator_conversao        float           := 1;
   vn_vl_unit_convert        item_nf_ped.vl_unit_convert%type;
   vn_qtde_convert           item_nf_ped.qtde_convert%type;
   vt_row_item_pedido_sigla  pk_csf_pedido.c_item_pedido_sigla%rowtype;
   vt_row_qtde_convertida    pk_csf_pedido.c_qtde_convertida%rowtype;
   va_item_nf_ped            tb_item_nf_ped  := tb_item_nf_ped();
   --
begin
   --
   vn_fase := 1;
   --
   for rec_item in c_item ( en_notafiscal_id ) loop
      exit when c_item%notfound or (c_item%notfound) is null;
      --
      vn_item_id    := null;
      vv_cod_item   := null;
      vv_descr_item := null;
      --
      vn_fase := 2;
      --
      -- Tenta achar o número do pedido pelo ítem da nota --
      if trim(rec_item.i_pedido_compra) is not null then
         --
         vn_fase := 2.1;
         --
         if not pk_csf_pedido.fkg_retorna_ped_id ( en_empresa_id     => rec_item.nfempresa_id
                                                 , ev_nro_pedido     => rec_item.i_pedido_compra
                                                 , sn_pedido_id      => vn_pedido_id_origitem
                                                 , sn_finalidade_id  => gn_finalidade_id
                                                 , sn_dm_mod_frete   => gn_dm_mod_frete
                                                 , sv_erro           => gv_mensagem_log) then
           --
            if gv_mensagem_log is not null then
               --
               pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
               --
            end if;
            --
         end if;
      --   --
      end if;
      --
      vn_fase := 3;
      --
      -- Tenta achar o número do pedido pela nota --
      if nvl(vn_pedido_id_origitem,0) = 0 and trim(rec_item.n_pedido_compra) is not null then
         --
         vn_fase := 3.1;
         --
         if not pk_csf_pedido.fkg_retorna_ped_id ( en_empresa_id     => rec_item.nfempresa_id
                                                 , ev_nro_pedido     => rec_item.n_pedido_compra
                                                 , sn_pedido_id      => vn_pedido_id_origitem
                                                 , sn_finalidade_id  => gn_finalidade_id
                                                 , sn_dm_mod_frete   => gn_dm_mod_frete
                                                 , sv_erro           => gv_mensagem_log) then
            --
            if gv_mensagem_log is not null then
               --
               pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
               --
            end if;
            --
         end if;
         --
      end if;
      --
      --
      vn_fase := 5;
      --
      -- Caso tenha pedido vinculado, utilizar o item_id do pedido como padrão --
      if nvl(rec_item.itempedido_item_id,0) > 0 then      
         --      
         vn_item_id    := rec_item.itempedido_item_id;
         vv_cod_item   := rec_item.itempedido_cod_item;
         vv_descr_item := rec_item.itempedido_descr_item;
         --
      else
         --
         vn_fase := 6;
         --
         -- Caso não tenha vinculo do item_id, Recupera o Item_id da nota pela tabela de de-para
         vn_item_id    := rec_item.item_id;
         vv_cod_item   := rec_item.cod_item;
         vv_descr_item := rec_item.descr_item;
         --
      end if;
      --
      --
      if nvl(vn_item_id, 0) = 0 then
         --
         vn_item_id := pk_csf_pedido.fkg_retorna_item_id ( en_empresa_id  => rec_item.nfempresa_id
                                                         , ev_cnpj_cpf    => rec_item.cnpj_cpf
                                                         , ev_cod_item_nf => trim(rec_item.cod_item) );
         --
      end if;
      --
      vn_fase := 7;
      --
      vn_itempedido_id := null;
      --
      if nvl(rec_item.itempedido_id,0) > 0 then -- Vinculo Manual pela Tela
         --
         vn_itempedido_id :=  rec_item.itempedido_id;
         begin
            select ip.*, upper(un.sigla_unid)
              into vt_row_item_pedido_sigla
              from item_pedido ip
                 , unidade       un
             where un.id  = ip.unidade_id
               and ip.id  = vn_itempedido_id;
         exception
            when others then
               null;
         end;
         --
      elsif nvl(vn_pedido_id_origitem,0) > 0 then
         --
         vn_fase := 7.1;
         --
         if pk_csf_pedido.fkg_retorna_itemped_id ( en_pedido_id             => vn_pedido_id_origitem
                                                 , en_item_id               => vn_item_id
                                                 , en_nro_item              => rec_item.item_pedido_compra
                                                 , st_row_item_pedido_sigla => vt_row_item_pedido_sigla
                                                 , sv_erro                  => gv_mensagem_log) then
            --
            vn_itempedido_id := vt_row_item_pedido_sigla.id;
            --
         else
            --

            if gv_mensagem_log is not null then
               --
               pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
               --
            end if;
            --
         end if;
         --
      elsif nvl(vn_itempedido_id, 0) = 0 and nvl(en_pedido_id_orignf,0) > 0 then
         --
         vn_fase := 7.2;
         --
         if pk_csf_pedido.fkg_retorna_itemped_id ( en_pedido_id             => en_pedido_id_orignf
                                                 , en_item_id               => vn_item_id
                                                 , en_nro_item              => rec_item.item_pedido_compra
                                                 , st_row_item_pedido_sigla => vt_row_item_pedido_sigla
                                                 , sv_erro                  => gv_mensagem_log) then
            --
            vn_itempedido_id := vt_row_item_pedido_sigla.id;
            --
         else
            --
            if gv_mensagem_log is not null then
               --
               pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
               --
            end if;
            --
         end if;
         --
      end if;
      --
      vn_fase := 8;
      --
      -- Validação de deposito_id conforme parâmetro dm_obriga_deposito --
      if vt_row_item_pedido_sigla.dm_obriga_deposito = 1 and nvl(nvl(rec_item.depositoerp_id,vt_row_item_pedido_sigla.depositoerp_id),0) = 0 then
         --
         gv_mensagem_log := 'Para este documento é obrigatório informar o depósito';
         pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
         --
      end if;
      --
      vn_fase := 9;
      --
      if nvl(vn_itempedido_id,0) > 0 then
         --
         vn_fase := 9.1;
         --
         vn_dm_st_proc := 1; -- Não validado e com pedido
         --
      else
         --
         vn_fase := 9.2;
         --
         vn_dm_st_proc := 0; -- Não validado e sem pedido
         --
      end if;
      --
      vn_fase := 10;
      --
      -- Atualiza o item do pedido --
      update item_nf_ped i set
           i.item_id       = vn_item_id
         , i.itempedido_id = vn_itempedido_id
      where i.id  = rec_item.itemnfped_id;
      --
      vn_fase := 11;
      --
      -- Checa se já existe um parametro de recebimento informado manualmente --
      if gt_row_notafiscal_ped.dm_edicao = 1 and nvl(gt_row_notafiscal_ped.paramreceb_id,0) > 0 then
         --
         begin
            select ipr.*
                 , pr.multorg_id
                 , pr.cod_op_receb
                 , pr.descr_op_receb
                 , pr.dm_obriga_placa
                 , pr.dm_fin_nfe
                 , pr.dm_obriga_departamento
            into gt_row_c_param_receb_itm
            from param_receb       pr
               , item_param_receb ipr
            where ipr.paramreceb_id = pr.id
              and rownum = 1
              and pr.id  = gt_row_notafiscal_ped.paramreceb_id;
         exception
            when others then
               null;
         end;
         --
      else
         --
         vn_fase := 12;
         --
         -- Soma qtd de itens inseridos
         vn_qtd_itens_ins := nvl(vn_qtd_itens_ins,0) + 1;
         --
         if vn_qtd_itens_ins = 1 then
            --
            vn_fase := 13;
            --
            -- Chama function que retorna o parâmetro de recebimento para vincular na nota_fiscal_ped
            if pk_csf_pedido.fkg_ret_param_receb_nf ( en_multorg_id              => rec_item.multorg_id           -- Mult_org (id)                         - Obrigatório
                                                    , en_modfiscal_id            => rec_item.modfiscal_id         -- Modelo Fiscal (id)                    - Obrigatório
                                                    , en_dm_fin_nfe              => rec_item.dm_fin_nfe           -- Finalidade de Emissão da NF-e         - Opcional
                                                    , en_cfop_id                 => rec_item.cfop_id_itm_01       -- CFOP (id)                             - Opcional
                                                    , en_utilizacaofiscal_id     => rec_item.utilizacaofiscal_id  -- Utilização Fiscal                     - Opcional
                                                    , en_dm_mod_frete            => gn_dm_mod_frete               -- Modelo de Frete                       - Opcional
                                                    , en_dm_obrig_pedido         => null                          -- Obriga Pedido                         - Opcional
                                                    , en_finalidade_id           => gn_finalidade_id              -- Finalidade do Pedido                  - Opcional
                                                    , sgt_row_item_param_receb   => gt_row_c_param_receb_itm      -- Valores do Parâmetro (saída)          - Parâmetro de Saída
                                                    , sv_erro                    => gv_mensagem_log               -- Mensagem de erro (return false)       - Parâmetro de Saída
                                                    ) then
               --
               update nota_fiscal_ped n set
                  n.paramreceb_id = gt_row_c_param_receb_itm.paramreceb_id
               where n.id = en_notafiscalped_id
                 and gt_row_notafiscal_ped.dm_st_proc in (0,1,2,7)   -- Só poermite atualizar os dados da nota se estiver com algum destes dm_dt_proc
                 and gt_row_notafiscal_ped.dm_edicao   = 0;          -- Não permitir sobrepor os dados caso tenha tido edição por tela
               --
               commit;
               --
            else
               --
               if gv_mensagem_log is not null then
                  --
                  pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
                  --
               end if;
               --
            end if;
            --
         end if;
         --
      end if;
      --
      vn_fase := 14;
      --
      if nvl(vn_itempedido_id,0) > 0 then
         --
         -- Busca o fator de conversão cadatrado para o produto e a unidade de medida
         vn_fator_conversao := 0;
         begin
            vn_fator_conversao := pk_csf_pedido.fkg_retorna_fator_conversao ( en_multorg_id        =>  rec_item.multorg_id                                                  -- Mult-org onde está parametrizado o Fator e Conversão
                                                                            , ev_cnpj              =>  nvl(trim(gt_row_notafiscal_ped.cnpj), gv_cnpj)                       -- CNPJ do Fornecedor
                                                                            , en_item_id           =>  vn_item_id                                                           -- Item (Produto) convertido pela de_para_item_fornec
                                                                            , ev_sigla_unid_orig   =>  upper(nvl(trim(rec_item.unid_com_itemnfped),rec_item.unid_com))      -- Sigla da unidade do fornecedor (origem)
                                                                            , ev_sigla_unid_dest   =>  upper(vt_row_item_pedido_sigla.sigla_unid)                           -- Sigla da unidade do cliente    (destino)
                                                                            ) ;
         exception
           when others then
             gv_mensagem_log := 'Erro na busca do Fator de Conversão: '||sqlerrm;
             pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
         end;
         --
         --
         vn_fase := 15;
         --
         if vn_fator_conversao = 0 then
            --
            vn_fase := 16;
            --
            vn_vl_unit_convert := rec_item.vl_unit_comerc;
            vn_qtde_convert    := rec_item.qtde_comerc;
            --
         else
            --
            vn_fase := 17;
            --
            vn_vl_unit_convert := nvl(rec_item.vl_unit_comerc,0) * nvl(vn_fator_conversao,1);
            vn_qtde_convert    := nvl(rec_item.qtde_comerc,0)    * nvl(vn_fator_conversao,1);
            --
         end if;
         --
      else -- Se não tiver pedido, mantém os valores e quantidades da nota
         --
         vn_vl_unit_convert := nvl(rec_item.vl_unit_comerc,0);
         vn_qtde_convert    := nvl(rec_item.qtde_comerc,0);
         --
      end if;
      --
      vn_fase := 18;
      --
      -- Verifica se já existe a item_nf_ped para inserir ou atualizar
      begin
         select inp.id
           into vn_itemnfped_id
         from item_nf_ped inp
         where inp.notafiscalped_id = en_notafiscalped_id
           and inp.itemnf_id        = rec_item.itemnotafiscal_id
           and inp.nro_item         = rec_item.nro_item;
         --
         vb_existe_infp := True;
         --
      exception
         when no_data_found then
            --
            vb_existe_infp := False;
            --
      end;
      --
      vn_fase := 19;
      --
      -- Popula o array table do item para uso posterior
      va_item_nf_ped := null;
      select tp_item_nf_ped(id                  => vn_itemnfped_id
                          , notafiscalped_id    => en_notafiscalped_id
                          , itempedido_id       => vn_itempedido_id
                          , itemnf_id           => rec_item.itemnotafiscal_id
                          , item_id             => vn_item_id
                          , dm_st_proc          => vn_dm_st_proc
                          , qtde_comerc         => rec_item.qtde_comerc
                          , vl_item_bruto       => rec_item.vl_item_bruto
                          , vl_desc             => rec_item.vl_desc
                          , vl_frete            => rec_item.vl_frete
                          , vl_seguro           => rec_item.vl_seguro
                          , vl_outro            => rec_item.vl_outro
                          , cod_item            => vv_cod_item
                          , descr_item          => vv_descr_item
                          , unid_com            => rec_item.unid_com
                          , dt_ult_confronto    => sysdate
                          , nro_item            => rec_item.nro_item
                          , vl_unit_comerc      => rec_item.vl_unit_comerc
                          , vl_unit_convert     => vn_vl_unit_convert
                          , qtde_convert        => vn_qtde_convert
                          , vl_liquido          => null
                          , utilizacaofiscal_id => null
                          , unid_convert        => null
                          , depositoerp_id      => vt_row_item_pedido_sigla.depositoerp_id
                          , dm_obriga_deposito  => vt_row_item_pedido_sigla.dm_obriga_deposito
                          , departamento_id     => vt_row_item_pedido_sigla.departamento_id
                          , dm_edicao           => rec_item.dm_edicao
                          , tiposervico_id      => rec_item.tiposervico_id
                          , dup_itemnfped_id    => rec_item.dup_itemnfped_id
                            )
      bulk collect into va_item_nf_ped from dual;
      --
      -- Converte a quantidade e unidade de medida --
      vt_row_qtde_convertida := pk_csf_pedido.fkg_qtde_convertida ( en_itemnfped_id => null
                                                                  , et_itemnfped    => va_item_nf_ped
                                                                  , ev_atualiza     => 0);
      --
      vn_fase := 20;
      --
      -- Valida se existe a Unidade de Medida Convertida --
      if vt_row_qtde_convertida.unid_convert is null then
         --
         gv_mensagem_log := 'Não foi encontrado um Parâmetro de Conversão de Unidade de Medida para o Fornecedor' ||chr(13)||
                            ' - Caso a nota fiscal não tenha pedido, é obrigatório Cadastrar um Parâmetro de Conversão de Unidade de Medida Fornecedor com Padrão SIM';
         pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
         --      
      end if;
      --
      vn_fase := 21;
      --
      -- Valida se existe a Unidade de Medida cadastrada na tabela UNIDADE --
      if vt_row_qtde_convertida.unid_convert is not null and nvl(pk_csf.fkg_Unidade_id(rec_item.multorg_id, vt_row_qtde_convertida.unid_convert),0) = 0 then
         --
         gv_mensagem_log := 'Não foi econtrado uma unidade de medida cadastrada para o documento atual' ||chr(13)||
                            'Unidade de medida informada no documento: '||rec_item.unid_com;
         pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
         --
      end if;
      --
      vn_fase := 22;
      --
      -- Validação de departamento_id conforme parâmetro dm_obriga_departamento --
      if gt_row_c_param_receb_itm.dm_obriga_departamento = 1 and nvl(nvl(rec_item.departamento_id,vt_row_item_pedido_sigla.departamento_id),0) = 0 then
         --
         gv_mensagem_log := 'Para este documento é obrigatório informar o departamento';
         pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
         --
      end if;
      --
      vn_fase := 23;
      --
      -- Checa a existencia do registro para atualizar ou inserir
      if not vb_existe_infp then
         --
         vn_fase := 23.1;
         --
         begin
            select itemnfped_seq.nextval
              into vn_itemnfped_id
              from dual;
         exception
            when others then
               vn_itemnfped_id := null;
         end;
         --
         insert into item_nf_ped ( id
                                 , notafiscalped_id
                                 , itempedido_id
                                 , itemnf_id
                                 , item_id
                                 , dm_st_proc
                                 , qtde_comerc
                                 , vl_item_bruto
                                 , vl_desc
                                 , vl_frete
                                 , vl_seguro
                                 , vl_outro
                                 , cod_item
                                 , descr_item
                                 , unid_com
                                 , dt_ult_confronto
                                 , vl_unit_comerc
                                 , nro_item
                                 , vl_unit_convert
                                 , qtde_convert
                                 , unid_convert
                                 , depositoerp_id
                                 , dm_obriga_deposito
                                 , departamento_id
                                 )
                          values ( vn_itemnfped_id                             -- id
                                 , en_notafiscalped_id                         -- notafiscalped_id
                                 , vn_itempedido_id                            -- itempedido_id
                                 , rec_item.itemnotafiscal_id                  -- itemnf_id
                                 , vn_item_id                                  -- item_id
                                 , vn_dm_st_proc                               -- dm_st_proc
                                 , rec_item.qtde_comerc                        -- qtde_comerc
                                 , rec_item.vl_item_bruto                      -- vl_item_bruto
                                 , rec_item.vl_desc                            -- vl_desc
                                 , rec_item.vl_frete                           -- vl_frete
                                 , rec_item.vl_seguro                          -- vl_seguro
                                 , rec_item.vl_outro                           -- vl_outro
                                 , vv_cod_item                                 -- cod_item
                                 , vv_descr_item                               -- descr_item
                                 , rec_item.unid_com                           -- unid_com
                                 , sysdate                                     -- dt_ult_confronto
                                 , rec_item.vl_unit_comerc                     -- vl_unit_comerc
                                 , rec_item.nro_item                           -- nro_item
                                 , vn_vl_unit_convert                          -- vl_unit_convert
                                 , vt_row_qtde_convertida.qtde_convert         -- qtde_convert
                                 , vt_row_qtde_convertida.unid_convert         -- unid_convert
                                 , vt_row_item_pedido_sigla.depositoerp_id     -- depositoerp_id
                                 , vt_row_item_pedido_sigla.dm_obriga_deposito -- dm_obriga_deposito
                                 , vt_row_item_pedido_sigla.departamento_id    -- departamento_id
                                 );
         -- Devido a trigger T_A_I_U_D_IMP_ITEMNF_PED_01 ser AUTONOMOUS_TRANSACTION, preciso comitar aqui no insert
         commit;
         --
      else
         --
         vn_fase := 23.2;
         --
         update item_nf_ped inp set
                 notafiscalped_id     =  en_notafiscalped_id                         -- notafiscalped_id
               , itempedido_id        =  vn_itempedido_id                            -- itempedido_id
               , itemnf_id            =  rec_item.itemnotafiscal_id                  -- itemnf_id
               , item_id              =  vn_item_id                                  -- item_id
               , dm_st_proc           =  vn_dm_st_proc                               -- dm_st_proc
               , qtde_comerc          =  rec_item.qtde_comerc                        -- qtde_comerc
               , vl_item_bruto        =  rec_item.vl_item_bruto                      -- vl_item_bruto
               , vl_desc              =  rec_item.vl_desc                            -- vl_desc
               , vl_frete             =  rec_item.vl_frete                           -- vl_frete
               , vl_seguro            =  rec_item.vl_seguro                          -- vl_seguro
               , vl_outro             =  rec_item.vl_outro                           -- vl_outro
               , cod_item             =  vv_cod_item                                 -- cod_item
               , descr_item           =  vv_descr_item                               -- descr_item
               , unid_com             =  rec_item.unid_com                           -- unid_com
               , dt_ult_confronto     =  sysdate                                     -- dt_ult_confronto
               , vl_unit_comerc       =  rec_item.vl_unit_comerc                     -- vl_unit_comerc
               , nro_item             =  rec_item.nro_item                           -- nro_item
               , vl_unit_convert      =  vn_vl_unit_convert                          -- vl_unit_convert
               , qtde_convert         =  vt_row_qtde_convertida.qtde_convert         -- qtde_convert
               , unid_convert         =  vt_row_qtde_convertida.unid_convert         -- unid_convert
               , depositoerp_id       =  vt_row_item_pedido_sigla.depositoerp_id     -- depositoerp_id
               , dm_obriga_deposito   =  vt_row_item_pedido_sigla.dm_obriga_deposito -- dm_obriga_deposito
               , departamento_id      =  vt_row_item_pedido_sigla.departamento_id    -- departamento_id
           where inp.id                            = vn_itemnfped_id
             and gt_row_notafiscal_ped.dm_st_proc in (0,1,2,7)   -- Só poermite atualizar os dados da nota se estiver com algum destes dm_dt_proc
             and inp.dm_edicao   = 0;   -- Não permitir sobrepor os dados caso tenha tido edição por tela
         --
         commit;
         --
      end if;
      --
      vn_fase := 24;
      --
      -- Chama rotina para inserir dados na imp_itemnf_ped
      pkb_dados_imp_itemnf_ped ( en_itemnf_id     => rec_item.itemnotafiscal_id
                               , en_itemnfped_id  => nvl(vn_itemnfped_id, rec_item.itemnfped_id)
                               , en_itempedido_id => vn_itempedido_id
                               ) ;
      --
      -- Se não encontrou um item_id, dá erro de validação
      if nvl(gt_row_c_param_receb_itm.dm_obrig_pedido,0) = 0 and  nvl(vn_item_id,0) = 0 then
         --
         gv_mensagem_log := 'Não é possivel converter o código do item '||trim(vv_cod_item)||
                            ' do fornecedor '||rec_item.cnpj_cpf||'. Por favor, verifique o depara de item.';
         --
         pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
         --
      end if;
      --
   end loop;
   --
exception
   when others then
      --
      gv_mensagem_log   := 'Erro na pk_relac_ped_nf.pkb_dados_item_nf_ped fase(' || vn_fase || '):' || sqlerrm;
      raise_application_error (-20101, pk_csf_api_pedido.gv_mensagem_log);
      --
end pkb_dados_item_nf_ped;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que carrega os dados da nota fiscal
----------------------------------------------------------------------------------------------------------
procedure pkb_dados_notafiscal_ped ( en_notafiscal_id    in  nota_fiscal.id%type
                                   , en_notafiscalped_id in out nota_fiscal_ped.id%type)
is
   --
   vn_fase              number := null;
   vn_pedido_id_orignf  pedido.id%type;
   vn_notafiscalped_id  nota_fiscal_ped.id%type;
   vb_existe_nfp        boolean := False;
   --
   --
begin
   --
   vn_fase := 1;
   --
   for rec_nota in c_nota ( en_notafiscal_id ) loop
      exit when c_nota%notfound or (c_nota%notfound) is null;
      --
      vn_fase := 2;
      --
      -- Popula variáveis globais q serão usadas ao longo do processo
      gn_pessoa_id        := pk_csf.fkg_Pessoa_id_cpf_cnpj ( en_multorg_id  => rec_nota.multorg_id, en_cpf_cnpj => rec_nota.cnpj );
      gn_modfiscal_id     := rec_nota.modfiscal_id;    -- Modelo Fiscal (id)
      gv_cnpj             := rec_nota.cnpj;            -- CNPJ do emitente
      en_notafiscalped_id := rec_nota.id_nfp;          -- id da tabela nota_fiscal_ped
      --
      --
      vn_fase := 3;
      --
      -- Checa se a nota fiscal já existe --
      begin
         select nfp.id
            into vn_notafiscalped_id
         from nota_fiscal_ped nfp
         where nfp.notafiscal_id = rec_nota.id;
         --
         vb_existe_nfp := True;
         --
      exception
         when no_data_found then
            vb_existe_nfp := False;
      end;
      --
      vn_fase := 4;
      --
      -- Se não existe a nota Fiscal, insere
      if not vb_existe_nfp then
         --
         vn_fase := 5;
         --
         begin
            select notafiscalped_seq.nextval
              into vn_notafiscalped_id
              from dual;
            --
            pk_csf_api_pedido.gt_row_nfped.id := vn_notafiscalped_id;
            en_notafiscalped_id               := vn_notafiscalped_id;
            --
         exception
            when others then
               vn_notafiscalped_id := null;
         end;
         --
         if nvl(vn_notafiscalped_id,0) > 0 then
            gv_mensagem_log := 'Início do processo de confronto - NFe';
            pkb_grava_log_generico(vn_notafiscalped_id, INFORMACAO);
         end if;
         --
         if trim(rec_nota.pedido_compra) is not null then
            --
            vn_fase := 6;
            --
            if not pk_csf_pedido.fkg_retorna_ped_id ( en_empresa_id     => rec_nota.empresa_id
                                                    , ev_nro_pedido     => rec_nota.pedido_compra
                                                    , sn_pedido_id      => vn_pedido_id_orignf
                                                    , sn_finalidade_id  => gn_finalidade_id
                                                    , sn_dm_mod_frete   => gn_dm_mod_frete
                                                    , sv_erro           => gv_mensagem_log) then
               --
               if gv_mensagem_log is not null then
                  --
                  pkb_grava_log_generico(vn_notafiscalped_id, ERRO_DE_VALIDACAO);
                  --
               end if;
               --
            end if;
         --
         end if;
         --
         vn_fase := 7;
         --
         insert into nota_fiscal_ped ( id
                                     , notafiscal_id
                                     , empresa_id
                                     , pessoa_id
                                     , dm_st_proc
                                     , dt_emiss
                                     , pedido_compra
                                     , dm_ind_emit
                                     , dm_ind_oper
                                     , nro_nf
                                     , serie
                                     , dt_sai_ent
                                     , cnpj
                                     , modfiscal_id
                                     , nro_chave_nfe
                                     , sitdocto_id
                                     , vl_total_item
                                     , vl_frete
                                     , vl_seguro
                                     , vl_desconto
                                     , vl_outra_despesas
                                     , vl_total_nf
                                     , vl_imp_trib_pis
                                     , vl_imp_trib_cofins
                                     , vl_imp_trib_iss
                                     , vl_total_serv
                                     , vl_imp_trib_ipi
                                     , vl_imp_trib_icms
                                     , vl_imp_trib_st
                                     , vl_imp_trib_ii
                                     , paramreceb_id
                                     , placa
                                     , uf
                                     , dm_fin_nfe
                                     )
                              values ( vn_notafiscalped_id         -- id
                                     , rec_nota.id                 -- notafiscal_id
                                     , rec_nota.empresa_id         -- empresa_id
                                     , gn_pessoa_id                -- pessoa_id
                                     , 0                           -- dm_st_proc
                                     , rec_nota.dt_emiss           -- dt_emiss
                                     , rec_nota.pedido_compra      -- pedido_compra
                                     , rec_nota.dm_ind_emit        -- dm_ind_emit
                                     , rec_nota.dm_ind_oper        -- dm_ind_oper
                                     , rec_nota.nro_nf             -- nro_nf
                                     , rec_nota.serie              -- serie
                                     , rec_nota.dt_sai_ent         -- dt_sai_ent
                                     , rec_nota.cnpj               -- cnpj
                                     , rec_nota.modfiscal_id       -- modfiscal_id
                                     , rec_nota.nro_chave_nfe      -- nro_chave_nfe
                                     , rec_nota.sitdocto_id        -- sitdocto_id
                                     , rec_nota.vl_total_item      -- vl_total_item
                                     , rec_nota.vl_frete           -- vl_frete
                                     , rec_nota.vl_seguro          -- vl_seguro
                                     , rec_nota.vl_desconto        -- vl_desconto
                                     , rec_nota.vl_outra_despesas  -- vl_outra_despesas
                                     , rec_nota.vl_total_nf        -- vl_total_nf
                                     , rec_nota.vl_imp_trib_pis    -- vl_imp_trib_pis
                                     , rec_nota.vl_imp_trib_cofins -- vl_imp_trib_cofins
                                     , rec_nota.vl_imp_trib_iss    -- vl_imp_trib_iss
                                     , rec_nota.vl_total_serv      -- vl_total_serv
                                     , rec_nota.vl_imp_trib_ipi    -- vl_imp_trib_ipi
                                     , rec_nota.vl_imp_trib_icms   -- vl_imp_trib_icms
                                     , rec_nota.vl_imp_trib_st     -- vl_imp_trib_st
                                     , rec_nota.vl_imp_trib_ii     -- vl_imp_trib_ii
                                     , null                        -- paramreceb_id -- será atualizado no final do loop
                                     , rec_nota.placa              -- placa
                                     , rec_nota.uf                 -- uf
                                     , rec_nota.dm_fin_nfe         -- dm_fin_nfe
                                     );
         --
         -- Devido a trigger T_A_I_U_D_IMP_ITEMNF_PED_01 ser AUTONOMOUS_TRANSACTION, preciso comitar aqui
         commit;
         --
         select *
           into gt_row_notafiscal_ped
         from nota_fiscal_ped
         where id = vn_notafiscalped_id;
         --
      else
         --
         vn_fase := 8;
         --
         update nota_fiscal_ped set
              notafiscal_id        =   rec_nota.id                 -- notafiscal_id
            , empresa_id           =   rec_nota.empresa_id         -- empresa_id
            , pessoa_id            =   gn_pessoa_id                -- pessoa_id
            , dm_st_proc           =   0                           -- dm_st_proc
            , dt_emiss             =   rec_nota.dt_emiss           -- dt_emiss
            , pedido_compra        =   rec_nota.pedido_compra      -- pedido_compra
            , dm_ind_emit          =   rec_nota.dm_ind_emit        -- dm_ind_emit
            , dm_ind_oper          =   rec_nota.dm_ind_oper        -- dm_ind_oper
            , nro_nf               =   rec_nota.nro_nf             -- nro_nf
            , serie                =   rec_nota.serie              -- serie
            , dt_sai_ent           =   rec_nota.dt_sai_ent         -- dt_sai_ent
            , cnpj                 =   rec_nota.cnpj               -- cnpj
            , modfiscal_id         =   rec_nota.modfiscal_id       -- modfiscal_id
            , nro_chave_nfe        =   rec_nota.nro_chave_nfe      -- nro_chave_nfe
            , sitdocto_id          =   rec_nota.sitdocto_id        -- sitdocto_id
            , vl_total_item        =   rec_nota.vl_total_item      -- vl_total_item
            , vl_frete             =   rec_nota.vl_frete           -- vl_frete
            , vl_seguro            =   rec_nota.vl_seguro          -- vl_seguro
            , vl_desconto          =   rec_nota.vl_desconto        -- vl_desconto
            , vl_outra_despesas    =   rec_nota.vl_outra_despesas  -- vl_outra_despesas
            , vl_total_nf          =   rec_nota.vl_total_nf        -- vl_total_nf
            , vl_imp_trib_pis      =   rec_nota.vl_imp_trib_pis    -- vl_imp_trib_pis
            , vl_imp_trib_cofins   =   rec_nota.vl_imp_trib_cofins -- vl_imp_trib_cofins
            , vl_imp_trib_iss      =   rec_nota.vl_imp_trib_iss    -- vl_imp_trib_iss
            , vl_total_serv        =   rec_nota.vl_total_serv      -- vl_total_serv
            , vl_imp_trib_ipi      =   rec_nota.vl_imp_trib_ipi    -- vl_imp_trib_ipi
            , vl_imp_trib_icms     =   rec_nota.vl_imp_trib_icms   -- vl_imp_trib_icms
            , vl_imp_trib_st       =   rec_nota.vl_imp_trib_st     -- vl_imp_trib_st
            , vl_imp_trib_ii       =   rec_nota.vl_imp_trib_ii     -- vl_imp_trib_ii
            , paramreceb_id        =   null                        -- paramreceb_id -- será atualizado no final do loop
            , placa                =   rec_nota.placa              -- placa
            , uf                   =   rec_nota.uf                 -- uf
            , dm_fin_nfe           =   rec_nota.dm_fin_nfe         -- dm_fin_nfe
         where notafiscal_id = rec_nota.id
           and dm_st_proc    in (0,1,2,7)  -- Só permite atualizar os dados da nota se estiver com algum destes dm_st_proc
           and dm_edicao     = 0;          -- Não permitir sobrepor os dados caso tenha tido edição por tela
         --
         commit;
         --
         --
         vn_fase := 9;
         --
         select *
            into gt_row_notafiscal_ped
         from nota_fiscal_ped
           where notafiscal_id = rec_nota.id;
         --
      end if;
      --
      vn_fase := 10;
      --
      -- Chama rotina para inserir dados na item_nf_ped
      begin
         vn_notafiscalped_id := nvl(vn_notafiscalped_id,gt_row_notafiscal_ped.id);
         pkb_dados_item_nf_ped ( en_notafiscal_id    => rec_nota.id
                               , en_notafiscalped_id => vn_notafiscalped_id
                               , en_pedido_id_orignf => vn_pedido_id_orignf
                               );
      exception
        when others then
           gv_mensagem_log := 'Erro na chamada para montar os itens dos itens da nota fiscal ped - '|| sqlerrm;
           pkb_grava_log_generico(nvl(vn_notafiscalped_id,gt_row_notafiscal_ped.id), ERRO_DE_VALIDACAO);
      end;
      --
      vn_fase := 11;
      --
      -- Calcula os valores totais da nota fiscal --
      --
      pk_csf_pedido.pkb_recalcula_nfp(en_notafiscalped_id => gt_row_notafiscal_ped.id);
      --
      commit;
      --
   end loop;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_pedido.gv_cabec_log    := 'Inserção na tabela dos dados da nota fiscal';
      pk_csf_api_pedido.gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_dados_notafiscal_ped fase(' || vn_fase || '):' || sqlerrm;
      --
      raise_application_error (-20101, pk_csf_api_pedido.gv_mensagem_log);
      --
end pkb_dados_notafiscal_ped;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento de validação das Regras para Relacionar a Nota Fiscal ao Pedido
----------------------------------------------------------------------------------------------------------
procedure pkb_valid_regra ( en_empresa_id       in empresa.id%type
                          , en_notafiscal_id    in nota_fiscal.id%type
                          , en_notafiscalped_id in out nota_fiscal_ped.id%type
                          ) is
   --
   vn_fase                    number := null;
   vn_dm_st_proc              nota_fiscal_ped.dm_st_proc%type;
   vn_erro                    number;
   vn_qtd_itens               number := 0;
   vn_qtd_itens_vinculados    number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gn_erro := 0;
   gn_empresa_id  := en_empresa_id;
   --
   vn_fase := 2;
   --
   if nvl(en_notafiscal_id, 0) > 0 or nvl(en_notafiscalped_id, 0) > 0 then
      --
      vn_fase := 3;
      --
      begin
         pkb_dados_notafiscal_ped ( en_notafiscal_id    => en_notafiscal_id
                                  , en_notafiscalped_id => en_notafiscalped_id);
      exception
        when others then
           gv_mensagem_log := sqlerrm;
           pkb_grava_log_generico(en_notafiscal_id, ERRO_DE_VALIDACAO);
      end;
      --
      commit;
      --
   end if;
   --
   vn_fase := 5;
   --
   -- Checa os itens vinculados com pedido --
   if not pk_csf_pedido.fkg_chk_itens_vinculados(en_notafiscalped_id     => en_notafiscalped_id
                                               , sn_qtd_itens            => vn_qtd_itens
                                               , sn_qtd_itens_vinculados => vn_qtd_itens_vinculados
                                               , sv_erro                 => gv_erro) then
      --
      gv_mensagem_log := 'Erro ao tentar busacar a quantidade de itens vinculados com o pedido '||chr(13)||
                         'Erro Retornado: '||gv_erro;
      pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
      --
   end if;
   --
   vn_fase := 6;
   --
   -- Se a nota fiscal estiver cancelada, seta a nota fiscal ped como cancelada
   if pk_csf.fkg_st_proc_nf (en_notafiscal_id) = 7 then
      --
      vn_dm_st_proc := 3; -- Cancelada
      --
      --
   -- Se obrigar pedido e não encontrar pedido vinculado   
   elsif gt_row_c_param_receb_itm.dm_obrig_pedido = 1 and vn_qtd_itens_vinculados = 0 then
      --
      vn_dm_st_proc := 7; -- Pedido não encontrado
      --
   -- Se encontrou algum erro durante o processo, atualiza o status para erro de validação
   elsif gn_erro > 0 then
      --
      vn_dm_st_proc := 2; -- Erro de Validação
      --
   elsif nvl(en_notafiscalped_id,0) > 0 and nvl(gt_row_c_param_receb_itm.paramreceb_id, 0) > 0 and gn_erro = 0 and vn_qtd_itens_vinculados = vn_qtd_itens then
      -- Chama rotina de validação da regra de negócio se existir dados na nota_fiscal_ped e se a nota obriga pedido
      --
      vn_fase := 6.1;
      --
      pk_vld_regras_negoc.pkb_valida_regra ( en_empresa_id        => gn_empresa_id
                                           , en_notafiscalped_id  => en_notafiscalped_id
                                           , sn_erro              => vn_erro
                                           );
      --
      if nvl(vn_erro,0) > 0 then
         --
         vn_dm_st_proc := 2; -- Erro de Validação
         --
      else
         --
         vn_dm_st_proc := 5; -- Validado
         --
      end if;
      --
   elsif gt_row_c_param_receb_itm.dm_obrig_pedido = 0 and vn_qtd_itens_vinculados = 0 then
      -- Nota Writer (sem pedido)
      --
      vn_dm_st_proc := 5; -- Validado (sem pedido)
      --
   elsif vn_qtd_itens_vinculados < vn_qtd_itens then
      --
      vn_dm_st_proc   := 2; -- Não validada e sem pedido
      gv_mensagem_log := 'A nota fiscal possui itens sem vínculo com o pedido.';
      pkb_grava_log_generico(en_notafiscalped_id, ERRO_DE_VALIDACAO);
      --
   else
     --
     vn_dm_st_proc := 2; -- Erro de Validação
     --
   end if;
   --
   vn_fase := 7;
   --
   -- Se foi tudo validado, Libera a nota, itens, atualiza saldo recebido, etc...
   if vn_dm_st_proc = 5 then
      --
      pk_csf_api_pedido.pkb_libera_notafiscalped(en_notafiscalped_id, 0);
      --
   end if;
   --
   update nota_fiscal_ped n set
       n.dm_st_proc    = vn_dm_st_proc
   where n.id = en_notafiscalped_id;
   --
   update item_nf_ped i set
      i.dm_st_proc = vn_dm_st_proc
   where i.notafiscalped_id = en_notafiscalped_id;
   --
   IF VN_DM_ST_PROC = 3 THEN -- NOTA CANCELADA
      --
      PK_CSF_PEDIDO.PKB_RECALCULA_NFP(EN_NOTAFISCALPED_ID => EN_NOTAFISCALPED_ID);
      --
   END IF;
   --
   gv_mensagem_log := 'Término do processo de confronto - NFe';
   pkb_grava_log_generico(en_notafiscalped_id, INFORMACAO);
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_pedido.gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_valid_regra fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf_ped.id%TYPE;
      begin
         --
          pk_csf_api_pedido.pkb_log_generico_nf_ped ( sn_loggenericonfped_id   => vn_loggenerico_id
                                                    , ev_mensagem              => pk_csf_api_pedido.gv_cabec_log
                                                    , ev_resumo                => pk_csf_api_pedido.gv_mensagem_log
                                                    , en_tipo_log              => pk_csf_api_pedido.ERRO_DE_VALIDACAO
                                                    , en_referencia_id         => pk_csf_api_pedido.gt_row_nfped.id
                                                    , ev_obj_referencia        => pk_csf_api_pedido.gv_obj_referencia_nfped
                                                    , en_empresa_id            => en_empresa_id
                                                    , en_dm_impressa           => 0);
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_pedido.gv_mensagem_log);
      --
end pkb_valid_regra;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que identifica dados de pedido e de nota fiscal para relacionar
----------------------------------------------------------------------------------------------------------
procedure pkb_dados_ped_nf ( en_multorg_id mult_org.id%type ) is
   --
   vn_fase             number := null;
   vn_empresa_id       empresa.id%type;
   vn_notafiscalped_id nota_fiscal_ped.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   gn_multorg_id := en_multorg_id;
   --
   for rec_empresa in c_empresa ( en_multorg_id ) loop
      exit when c_empresa%notfound or (c_empresa%notfound) is null;
      --
      vn_empresa_id       := rec_empresa.id;
      --
      -- Busca parametrização da empresa
      if pk_csf_pedido.fkg_ret_param_habil_pedidos ( en_empresa_id => vn_empresa_id ) = 1
         and pk_csf_pedido.fkg_ret_param_habil_confronto ( en_empresa_id => vn_empresa_id ) = 1 then
         --
         for rec_nf in c_nf ( rec_empresa.id ) loop
            exit when c_nf%notfound or (c_nf%notfound) is null;
            --
            vn_notafiscalped_id := rec_nf.notafiscalped_id;
            --
            vn_fase := 2;
            --
            pkb_valid_regra ( en_empresa_id       => rec_empresa.id
                            , en_notafiscal_id    => rec_nf.notafiscal_id
                            , en_notafiscalped_id => vn_notafiscalped_id
                            );
            --
         end loop;
         --
      end if;
      --
   end loop;
   --
   vn_fase := 3;
   --
   -- Chama a rotina de validação do MDE --
   pkb_valida_mde;
   --
   commit;
   --
exception
   when others then
      --
      pk_csf_api_pedido.gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_dados_ped_nf fase(' || vn_fase || '):' || sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf_ped.id%TYPE;
      begin
         --
          pk_csf_api_pedido.pkb_log_generico_nf_ped ( sn_loggenericonfped_id   => vn_loggenerico_id
                                                    , ev_mensagem              => pk_csf_api_pedido.gv_cabec_log
                                                    , ev_resumo                => pk_csf_api_pedido.gv_mensagem_log
                                                    , en_tipo_log              => pk_csf_api_pedido.ERRO_DE_VALIDACAO
                                                    , en_referencia_id         => pk_csf_api_pedido.gt_row_nfped.id
                                                    , ev_obj_referencia        => pk_csf_api_pedido.gv_obj_referencia_nfped
                                                    , en_empresa_id            => vn_empresa_id
                                                    , en_dm_impressa           => 0);
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_csf_api_pedido.gv_mensagem_log);
      --
end pkb_dados_ped_nf;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que Libera o recebimento de uma nota fiscal com quantidade maior que o pedido, criando um novo item
----------------------------------------------------------------------------------------------------------
procedure pkb_libera_recebimento_maior ( en_itemnfped_id item_nf_ped.id%type )is
   --
   vn_fase                         number       := 0;
   vn_margem_tolerancia            number       := 0;
   vv_tipo_margem_tolerancia       varchar2(1)  := 'V'; -- Padrão V - (V)alor / (P)ercentual
   vn_fator_conversao              float        := 1;
   vn_item_id                      item.id%type := 0;
   vn_itemnfped_id                 number;
   vn_notafiscalped_id             nota_fiscal_ped.id%type;
   vn_fator_proporcao              number       := 0;
   vb_achou                        boolean      := False;
   --
begin
   --
   vn_fase := 1;
   --
   -- Busca parametro de margem de tolerância
   gv_erro := '';
   if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => gn_multorg_id,
                                                 en_empresa_id => gn_empresa_id,
                                                 en_modulo_id  => MODULO_SISTEMA,
                                                 en_grupo_id   => GRUPO_SISTEMA_TOLERANCIA,
                                                 ev_param_name => 'MARGEM_TOLERANCIA_FATOR_CONVERSAO',
                                                 sv_vlr_param  => vn_margem_tolerancia,
                                                 sv_erro       => gv_erro) then
      --
      gv_mensagem_log := 'Foi encontrado um erro ao buscar o parâmetro de margem de tolerância - pk_vld_regras_negoc.pkb_valida_unidade_medida'||chr(13)||
                         'Erro Retornado: '||gv_erro;
      --
      pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
      --
   end if;
   --
   vn_fase := 2;
   --
   -- Busca parametro de tipo de multiplicador de margem de tolerância
   gv_erro := '';
   if not pk_csf.fkg_ret_vl_param_geral_sistema (en_multorg_id => gn_multorg_id,
                                                 en_empresa_id => gn_empresa_id,
                                                 en_modulo_id  => MODULO_SISTEMA,
                                                 en_grupo_id   => GRUPO_SISTEMA_TOLERANCIA,
                                                 ev_param_name => 'MARGEM_TOLERANCIA_FATOR_CONVERSAO_TIPO',
                                                 sv_vlr_param  => vv_tipo_margem_tolerancia,
                                                 sv_erro       => gv_erro) then
      --
      gv_mensagem_log := 'Foi encontrado um erro ao buscar o tipo de multiplicador do parâmetro de margem de tolerância - pk_vld_regras_negoc.pkb_valida_unidade_medida'||chr(13)||
                         'Erro Retornado: '||gv_erro;
      --
      pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
      --
   end if;
   --
   vn_fase := 3;
   --
   -- Busca os dados do ítem a ser duplicado --
   for x in (select inp.id                       itemnfped_id
                  , upper(inp.unid_com)          cod_unid_nf
                  , upper(up.sigla_unid)         cod_unid_ped
                  , ip.item_id                   item_id_ped
                  , upper(inp.cod_item)          cod_item_nf
                  , upper(itp.cod_item)          cod_item_ped
                  , itp.descr_item               descr_item_ped
                  , p.pessoa_id                  pessoa_id
                  , p.empresa_id                 empresa_id
                  , up.multorg_id                multorg_id
                  , nfp.notafiscal_id            notafiscal_id
                  , nf.nro_nf                    nro_nf
                  , nf.serie                     serie
                  , p.nro_pedido                 nro_pedido
                  , inp.qtde_comerc              qtde_nf
                  , ip.qtd_recebido              qtde_recebido
                  , ip.qtd_itemped               qtde_pedido
                  , inp.notafiscalped_id         notafiscalped_id
                  , nvl(nfe.cnpj, nfe.cpf)       cnpj_cpf
             from ITEM_NF_PED        inp
                , NOTA_FISCAL_PED    nfp
                , NOTA_FISCAL         nf
                , NOTA_FISCAL_EMIT   nfe
                , ITEM_PEDIDO         ip
                , PEDIDO               p
                , UNIDADE             up
                , ITEM               itp
             where nfp.id            = inp.notafiscalped_id
               and nf.id             = nfp.notafiscal_id
               and nfe.notafiscal_id = nf.id
               and ip.id             = inp.itempedido_id
               and p.id              = ip.pedido_id
               and up.id             = itp.unidade_id
               and itp.id            = ip.item_id
               and inp.id            = en_itemnfped_id)
   loop
      --
      vb_achou := True;
      --
      vn_notafiscalped_id := x.notafiscalped_id;
      --
      vn_fase := 3.1;
      --
      -- Trata o Fator de Conversão entre pedido e nota --
      if x.cod_unid_nf = x.cod_unid_ped then
         --
         vn_fator_conversao := 1;
         --
      else
         --
         vn_fase := 3.11;
         --
         -- Testa se na nota veio um item que já temos cadastrado --
         vn_item_id := nvl(x.item_id_ped,0);
         --
         vn_fase := 3.12;
         --
         -- Caso a nota não tenha um item_id associado, busca na parametrizaão do De-Para
         if vn_item_id = 0 then
            --
            vn_item_id := pk_csf_pedido.fkg_retorna_item_id (en_empresa_id  => x.empresa_id,
                                                             ev_cnpj_cpf    => x.cnpj_cpf,
                                                             ev_cod_item_nf => x.cod_item_nf);
            --
         end if;
         --
         vn_fase := 3.13;
         --
         -- Segundo Passo: Checar se existe fator de conversão cadatrado para o produto e a unidade de medida
         vn_fator_conversao := pk_csf_pedido.fkg_retorna_fator_conversao (en_multorg_id      => x.multorg_id
                                                                        , ev_cnpj            => pk_csf.fkg_cnpj_notafiscalemit(x.notafiscal_id)
                                                                        , en_item_id         => vn_item_id
                                                                        , ev_sigla_unid_orig => x.cod_unid_nf
                                                                        , ev_sigla_unid_dest => x.cod_unid_ped);
         --
         vn_fase := 3.14;
         --
         -- Caso não encontre fator de conversão, utilizar o 1 como padrão --
         if vn_fator_conversao = 0 then
            --
            vn_fator_conversao := 1;
            --
         end if;
         --
      end if;
      --
      vn_fase := 4;
      --
      -- Calcula o fator de proporção para equalização das quantidades e valores
      --vn_fator_proporcao := x.qtde_pedido / (x.qtde_nf * vn_fator_conversao);
      vn_fator_proporcao := (x.qtde_pedido - x.qtde_recebido + ( x.qtde_nf  * vn_fator_conversao))  / (x.qtde_nf  * vn_fator_conversao);

      --
      vn_fase := 5;
      --
      -- Se o pedido já foi recebido na totalidade pela nota, não permite duplicar
      if x.qtde_pedido <= (x.qtde_recebido - ( x.qtde_nf  * vn_fator_conversao)) then
         --
         gv_mensagem_log := 'Não é possível duplicar este ítem, pois ele já foi recebido na totalidade';
         pkb_grava_log_generico(x.notafiscalped_id, INFORMACAO);
         --
      -- Se a quantidade da nota + a quantidade recebida for maior que a quantidade pedida duplica o item
      elsif  (x.qtde_nf * vn_fator_conversao)
         > (x.qtde_pedido + nvl(vn_margem_tolerancia,0) - x.qtde_recebido + ( x.qtde_nf * vn_fator_conversao))
      then
         --
         vn_fase := 5.1;
         --
         -- Insere uma segunda linha na item_nf_ped com a quantidade excedente sem pedido relacionado para um novo confronto
         vn_itemnfped_id := itemnfped_seq.nextval;
         insert into ITEM_NF_PED (id
                                , notafiscalped_id
                                , itempedido_id
                                , itemnf_id
                                , dm_st_proc
                                , qtde_comerc
                                , qtde_convert
                                , vl_item_bruto
                                , vl_desc
                                , vl_frete
                                , vl_seguro
                                , vl_outro
                                , cod_item
                                , descr_item
                                , unid_com
                                , unid_convert
                                , item_id
                                , dt_ult_confronto
                                , vl_unit_comerc
                                , vl_unit_convert
                                , vl_liquido
                                , dm_edicao
                                , nro_item
                                )
                                --
         select                   vn_itemnfped_id
                                , notafiscalped_id
                                , null
                                , itemnf_id
                                , 1               -- Não validado e sem pedido
                                , i.qtde_comerc   * (1 - vn_fator_proporcao)
                                , i.qtde_convert  * (1 - vn_fator_proporcao)
                                , i.vl_item_bruto * (1 - vn_fator_proporcao)
                                , i.vl_desc       * (1 - vn_fator_proporcao)
                                , i.vl_frete      * (1 - vn_fator_proporcao)
                                , i.vl_seguro     * (1 - vn_fator_proporcao)
                                , i.vl_outro      * (1 - vn_fator_proporcao)
                                , upper(cod_item)
                                , descr_item
                                , unid_com
                                , i.unid_convert
                                , item_id
                                , sysdate
                                , i.vl_unit_comerc
                                , i.vl_unit_convert
                                , i.vl_liquido   * (1 - vn_fator_proporcao)
                                , 2 -- dm_edicao = 2 -- Item Duplicado manualmente
                                , (select max(nro_item)+1 from item_nf_ped where notafiscalped_id = x.notafiscalped_id )
         from ITEM_NF_PED i
         where i.id = en_itemnfped_id;
         --
         commit; -- Devido as triggers AUTONOMOUS_TRANSACTION preciso commitar aqui !!
         --
         vn_fase := 5.2;
         --
         -- Seta o dm_st_proc do item Original --
         pk_vld_regras_negoc.pkb_seta_dmstproc_inp ( en_itemnfped_id, 4); -- Liberado Manualmente
         --
         vn_fase := 5.3;
         --
         -- Insere os impostos --
         if vn_itemnfped_id is not null then
            --
            vn_fase := 5.41;
            --
            begin
               --
               insert into imp_itemnf_ped ( id
                                          , itemnfped_id
                                          , impitemnf_id
                                          , tipoimp_id
                                          , dm_tipo
                                          , vl_base_calc
                                          , aliq_apli
                                          , impitemped_id
                                          , vl_imp_trib
                                          , dt_ult_confronto
                                          )
               select                       impitemnfped_seq.nextval
                                          , vn_itemnfped_id
                                          , null -- será atualizado depois. Inseri null só para conseguir dar o update seguinte sem afetar estes registros inseridos
                                          , a.tipoimp_id
                                          , a.dm_tipo
                                          , a.vl_base_calc * (1 - vn_fator_proporcao)
                                          , a.aliq_apli
                                          , a.impitemped_id
                                          , a.vl_imp_trib  * (1 - vn_fator_proporcao)
                                          , sysdate
                 from imp_itemnf_ped a
               where itemnfped_id = en_itemnfped_id;
               --
               commit; -- obrigatório para não dar deadlock na trigger T_A_I_U_D_IMP_ITEMNF_PED_01 com os updates abaixo
               --
               vn_fase := 5.42;
               --
               -- Atualiza a proporcionalização do registro original
               update imp_itemnf_ped i set
                    i.vl_base_calc      =  i.vl_base_calc  * vn_fator_proporcao
                  , i.vl_imp_trib       =  i.vl_imp_trib   * vn_fator_proporcao
                  , i.dt_ult_confronto  =  sysdate
               where i.itemnfped_id = en_itemnfped_id;
               --
               commit; -- Devido as triggers AUTONOMOUS_TRANSACTION preciso commitar aqui !!
               --
            exception
               when others then
                    gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_libera_recebimento_maior fase(' || vn_fase || '):' || sqlerrm;
                    --
                    pkb_grava_log_generico(x.notafiscalped_id, ERRO_DE_VALIDACAO);
            end;
            --
         end if;
         --
         vn_fase := 5.4;
         --
         -- Atualiza a Quantidade do item original com base no pedido -- precisou ficar por ultimo devido as triggers do imposto dar conflito de valores
         update item_nf_ped i set
              i.qtde_comerc       = i.qtde_comerc     * vn_fator_proporcao
            , i.qtde_convert      = i.qtde_convert    * vn_fator_proporcao
            , i.vl_item_bruto     = i.vl_item_bruto   * vn_fator_proporcao
            , i.vl_liquido        = i.vl_liquido      * vn_fator_proporcao
            , i.vl_desc           = i.vl_desc         * vn_fator_proporcao
            , i.vl_frete          = i.vl_frete        * vn_fator_proporcao
            , i.vl_seguro         = i.vl_seguro       * vn_fator_proporcao
            , i.vl_outro          = i.vl_outro        * vn_fator_proporcao
            , i.dm_edicao         = 2 -- item duplicado
         where i.id = en_itemnfped_id;
         --
         commit; -- Devido as triggers AUTONOMOUS_TRANSACTION preciso commitar aqui !!
         --
      else
         --
         vn_fase := 6;
         --
         gv_mensagem_log := 'Não é possível duplicar este ítem, pois não satisfaz a regra de recebimento';
         pkb_grava_log_generico(x.notafiscalped_id, INFORMACAO);
         --
      end if;
      --
   end loop;
   --
   vn_fase := 7;
   --
   -- Recalculo Geral das quantidades
   update item_nf_ped i set
        i.dt_ult_confronto = sysdate
   where i.id = en_itemnfped_id;
   --
   -- Recalcula a nota fiscal--
   pk_csf_pedido.pkb_recalcula_nfp(vn_notafiscalped_id);
   --
   commit;
   --
   if not vb_achou then
      --
      gv_mensagem_log := 'Este item não pode ser duplicado, pois provavelmente não tem um pedido associado';
      --
      pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
      --
   end if;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_libera_recebimento_maior fase(' || vn_fase || '):' || sqlerrm;
      --
      pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
      --
end pkb_libera_recebimento_maior;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que duplica um ítem de nota fiscal de serviço para liberar um recebimento a maior
----------------------------------------------------------------------------------------------------------
procedure pkb_duplica_item_nfs ( en_itemnfped_id in item_nf_ped.id%type
                               , en_vlr_item     in item_nf_ped.vl_item_bruto%type)
is
   --
   vn_fase   number := 0;
   vn_fator  float  := 0;
   --
begin
   --
   vn_fase := 1;
   --
   -- Valida parametros obrigatórios -- 
   if nvl(en_itemnfped_id, 0) = 0 then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_duplica_item_nfs'||chr(13)||
                         ' - Obrigatório informar o parâmetro en_itemnfped_id';
      --
      pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
      --                                                    
   end if;
   --
   if nvl(en_vlr_item, 0) = 0 then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_duplica_item_nfs'||chr(13)||
                         ' - Obrigatório informar o parâmetro en_vlr_item';
      --
      pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
      --                                                    
   end if;
   --
   if nvl(en_vlr_item, 0) < 0 then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_duplica_item_nfs'||chr(13)||
                         ' - O Parâmetro en_vlr_item não pode ser um número negativo';
      --
      pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
      --                                                    
   end if;
   --
   vn_fase := 2;
   --
   -- Pupula os dados do item informado --
   if not pk_csf_pedido.fkg_ret_gt_row_item_nf_ped (en_itemnfped_id     => en_itemnfped_id,
                                                    sgt_row_item_nf_ped => gt_row_item_nf_ped,
                                                    sv_erro             => gv_erro) then
   --
   gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_duplica_item_nfs fase(' || vn_fase || '):' || gv_erro;
   --
   pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
   --                                                    
   end if;
   --
   vn_fase := 3;
   --
   -- Calcula o fator de proporção mediante ao valor informado no parâmetro --
   vn_fator := en_vlr_item / gt_row_item_nf_ped.vl_item_bruto;
   --
   vn_fase := 4;
   --
   -- Cria o novo Ítem porporcional ao valor informado --
   gt_row_item_nf_ped.id := itemnfped_seq.nextval;  
   insert into item_nf_ped (id,
                            notafiscalped_id,
                            itempedido_id,
                            itemnf_id,
                            item_id,
                            dm_st_proc,
                            qtde_comerc,
                            vl_item_bruto,
                            vl_desc,
                            vl_frete,
                            vl_seguro,
                            vl_outro,
                            cod_item,
                            descr_item,
                            unid_com,
                            dt_ult_confronto,
                            nro_item,
                            vl_unit_comerc,
                            vl_unit_convert,
                            qtde_convert,
                            vl_liquido,
                            utilizacaofiscal_id,
                            unid_convert,
                            depositoerp_id,
                            dm_obriga_deposito,
                            departamento_id,
                            dm_edicao,
                            tiposervico_id,
                            dup_itemnfped_id)
   values (gt_row_item_nf_ped.id,
           gt_row_item_nf_ped.notafiscalped_id,
           null,
           gt_row_item_nf_ped.itemnf_id,
           gt_row_item_nf_ped.item_id,
           0,
           gt_row_item_nf_ped.qtde_comerc     * vn_fator,
           gt_row_item_nf_ped.vl_item_bruto   * vn_fator,
           gt_row_item_nf_ped.vl_desc         * vn_fator,
           gt_row_item_nf_ped.vl_frete        * vn_fator,
           gt_row_item_nf_ped.vl_seguro       * vn_fator,
           gt_row_item_nf_ped.vl_outro        * vn_fator,
           gt_row_item_nf_ped.cod_item,
           gt_row_item_nf_ped.descr_item,
           gt_row_item_nf_ped.unid_com,
           sysdate,
           (select max(nro_item) + 1 from item_nf_ped where notafiscalped_id = gt_row_item_nf_ped.notafiscalped_id),
           gt_row_item_nf_ped.vl_unit_comerc  * vn_fator,
           gt_row_item_nf_ped.vl_unit_convert * vn_fator,
           gt_row_item_nf_ped.qtde_convert    * vn_fator,
           gt_row_item_nf_ped.vl_liquido      * vn_fator,
           gt_row_item_nf_ped.utilizacaofiscal_id,
           gt_row_item_nf_ped.unid_convert,
           gt_row_item_nf_ped.depositoerp_id,
           gt_row_item_nf_ped.dm_obriga_deposito,
           gt_row_item_nf_ped.departamento_id,
           2, -- dm_edicao = 2 -- Item Duplicado manualmente,
           gt_row_item_nf_ped.tiposervico_id,
           en_itemnfped_id);
   --
   commit;        
   --
   vn_fase := 5;
   --
   -- Insere os impostos proporcionalizados --
   insert into imp_itemnf_ped (id,
                               itemnfped_id,
                               impitemnf_id,
                               tipoimp_id,
                               dm_tipo,
                               vl_base_calc,
                               aliq_apli,
                               impitemped_id,
                               vl_imp_trib,
                               dt_ult_confronto)
   select impitemnfped_seq.NextVal,
          gt_row_item_nf_ped.id,
          impitemnf_id,
          tipoimp_id,
          dm_tipo,
          vl_base_calc   * vn_fator,
          aliq_apli,
          impitemped_id,
          vl_imp_trib    * vn_fator,
          sysdate
   from imp_itemnf_ped ii 
   where ii.itemnfped_id = en_itemnfped_id;
   --
   commit;   
   --
   vn_fase := 6;
   --
   -- Atualiza o ítem original --
   update item_nf_ped i set
     i.qtde_comerc     = i.qtde_comerc     * (1-vn_fator),
     i.vl_item_bruto   = i.vl_item_bruto   * (1-vn_fator),
     i.vl_desc         = i.vl_desc         * (1-vn_fator),
     i.vl_frete        = i.vl_frete        * (1-vn_fator),
     i.vl_seguro       = i.vl_seguro       * (1-vn_fator),
     i.vl_outro        = i.vl_outro        * (1-vn_fator),
     i.vl_unit_comerc  = i.vl_unit_comerc  * (1-vn_fator),
     i.vl_unit_convert = i.vl_unit_convert * (1-vn_fator),
     i.qtde_convert    = i.qtde_convert    * (1-vn_fator),
     i.vl_liquido      = i.vl_liquido      * (1-vn_fator),
     i.dm_edicao       = 2
   where i.id = en_itemnfped_id;   
   --
   commit;
   --
   vn_fase := 7;
   --
   -- Atualiza os impostos originais
   update imp_itemnf_ped ii set
     ii.vl_base_calc = ii.vl_base_calc * (1-vn_fator),
     ii.vl_imp_trib  = ii.vl_imp_trib  * (1-vn_fator)
   where ii.itemnfped_id = en_itemnfped_id;
   --
   commit;
   --  
exception
   when others then
      --
      rollback;
      gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_duplica_item_nfs fase(' || vn_fase || '):' || sqlerrm;
      pkb_grava_log_generico(en_itemnfped_id, ERRO_DE_VALIDACAO);
      --
end pkb_duplica_item_nfs;                                 
--
--------------------------------------------------------
-- VALIDA A CRIAÇÃO DA NOTA_FISCAL_MDE  --
--------------------------------------------------------
procedure pkb_valida_mde ( en_notafiscalpe_id     nota_fiscal_ped.id%type default null
                         , en_tipoeventosefaz_cd  tipo_evento_sefaz.cd%type default null
                         , ea_justificativa       varchar2 default null
                         )
IS
   --
   vn_fase                number := 0;
   vn_tipoenventosefaz_id tipo_evento_sefaz.id%type;
   --
BEGIN
   --
   BEGIN

   vn_fase := 1;

   FOR X IN (
              -- VERIFICAÇÃO ANTES DA CHAMADA DA PKB_GRAVA_MDE
                SELECT DISTINCT NFPED.*
                  FROM MODULO_ERP ME
                      ,PARAM_RECEB_MODULO PRM
                      ,PARAM_RECEB        PR
                      ,NOTA_FISCAL_PED    NFPED
                      ,EMPRESA            EMP
                 WHERE 1=1
                   AND NFPED.EMPRESA_ID    = EMP.ID
                   AND PRM.PARAMRECEB_ID   = PR.ID
                   AND ME.ID               = PRM.MODULOERP_ID
                   AND NFPED.PARAMRECEB_ID = PR.ID
                   AND NFPED.ID            = NVL(EN_NOTAFISCALPE_ID, NFPED.ID)
                   AND NFPED.DM_ST_PROC    = 6 -- VALIDADO E LIDO PELO ERP
                   AND ME.MULTORG_ID       = EMP.MULTORG_ID--127 --EN_MULTORG_ID
                   AND NOT EXISTS (select 1
                                     from V_NF_PED_ST_RET_ERP A
                                    WHERE A.NOTAFISCALPED_ID = NFPED.ID
                                      AND A.DM_SITUACAO      = 2 -- ERRO DE PROCESSAMENTO
                                  )
                  AND NOT EXISTS (SELECT 1--MDE.*
                                    FROM NOTA_FISCAL_MDE MDE
                                   WHERE MDE.NOTAFISCAL_ID = NFPED.NOTAFISCAL_ID
                                     AND MDE.DM_SITUACAO IN (0, 1, 2, 3)
                                     AND MDE.TIPOEVENTOSEFAZ_ID IN (select ID
                                                                      from tipo_evento_sefaz
                                                                     where CD = NVL(EN_TIPOEVENTOSEFAZ_CD,'210200') --cd in (210200, 210210/*, 210220, 210240*/)
                                                                    )
                                 )
                   --#66872 Incluido filtro abaixo 
                   AND NFPED.MODFISCAL_ID IN (SELECT ID
                                                FROM MOD_FISCAL MF
                                               WHERE MF.COD_MOD IN ('55','65')
                                               )

             )
   LOOP
    vn_fase := 1;
   BEGIN
       SELECT ID
         INTO VN_TIPOENVENTOSEFAZ_ID
         FROM TIPO_EVENTO_SEFAZ
        WHERE CD = NVL(EN_TIPOEVENTOSEFAZ_CD,'210200');
     EXCEPTION
       WHEN OTHERS THEN
         gv_mensagem_log := 'Erro na PKB_VALIDA_MDE fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pk_csf_api.pkb_log_generico_nf (  sn_loggenericonf_id => vn_loggenerico_id
                                         , ev_mensagem         => gv_mensagem_log
                                         , ev_resumo           => gv_mensagem_log
                                         , en_tipo_log         => erro_de_validacao
                                         , ev_obj_referencia   => 'NOTA_FISCAL_MDE' );
      exception
         when others then
            null;
      end;
     END;
     --
     vn_fase := 2;
     --
     PK_CSF_API.PKB_GRAVA_MDE ( EN_NOTAFISCAL_ID      => X.NOTAFISCAL_ID
                              , EA_TIPOEVENTOSEFAZ_ID => VN_TIPOENVENTOSEFAZ_ID
                              , EA_JUSTIFICATIVA      => EA_JUSTIFICATIVA);
   END LOOP;
   EXCEPTION
     WHEN OTHERS THEN
       gv_mensagem_log := 'Erro na PKB_VALIDA_MDE fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         PK_CSF_API.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                             , ev_mensagem         => gv_mensagem_log
                             , ev_resumo           => gv_mensagem_log
                             , en_tipo_log         => erro_de_validacao
                             , ev_obj_referencia   => 'NOTA_FISCAL_MDE' );
      exception
         when others then
            null;
      end;
   END;
   --
EXCEPTION
   when others then
      --
      gv_mensagem_log := 'Erro na pkb_valida_mde fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  log_generico_nf.id%type;
      begin
         pk_csf_api.pkb_log_generico_nf ( sn_loggenericonf_id => vn_loggenerico_id
                                        , ev_mensagem         => gv_mensagem_log
                                        , ev_resumo           => gv_mensagem_log
                                        , en_tipo_log         => erro_de_validacao
                                        , ev_obj_referencia   => 'NOTA_FISCAL_MDE' );
      exception
         when others then
            null;
      end;
      --
end pkb_valida_mde;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento para resetar a Nota Fiscal e Reprocessá-la
----------------------------------------------------------------------------------------------------------
procedure pkb_reinicia_nfp ( en_notafiscalped_id  in nota_fiscal_ped.id%type) is
  --
  vn_fase number := 0;
  --
begin
   --
   vn_fase := 1;
   --
   -- Guarda os dados da NOTA_FISCAL_PED antes de apagar
   if not pk_csf_pedido.fkg_ret_gt_row_nota_fiscal_ped(en_notafiscalped_id     => en_notafiscalped_id,
                                                       en_itemnfped_id         => null,
                                                       sgt_row_nota_fiscal_ped => gt_row_notafiscal_ped,
                                                       sv_erro                 => gv_erro) then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_reinicia_nfp fase(' || vn_fase || '):' || gv_erro;
      pkb_grava_log_generico(en_notafiscalped_id, INFORMACAO);    
      goto sair_geral;  
      --
   end if;                                                    
   --
   vn_fase := 2;
   --
   -- Só é permitido reiniciar a nfp se o status foi erro de validação ou Pedido não encontrado
   if gt_row_notafiscal_ped.dm_st_proc not in (2,7) then
      --
      gv_mensagem_log := 'Somente é permitido reiniciar o documento se ele estiver com status "Erro de Validação" ou "Pedido não Encontrado"';
      pkb_grava_log_generico(en_notafiscalped_id, INFORMACAO);
      goto sair_geral;
      --
   end if;
   --
   vn_fase := 3;
   --
   -- Checa se tem conhecimento de transporte vinculado antes de startar o processo -- 
   for x in (
      select icp.conhectranspped_id
           , ctp.dm_st_proc
        from ITEM_NF_PED        inp
           , ITEM_CT_PED        icp
           , CONHEC_TRANSP_PED  ctp
      where 1=1  
        and icp.itemnfped_id     = inp.id
        and ctp.id               = icp.conhectranspped_id
        and inp.notafiscalped_id = en_notafiscalped_id)  
   loop
      --
      if x.dm_st_proc in (2,7) then
         --
         pk_relac_ped_ct.pkb_reinicia_cte ( en_conhectranspped_id => x.conhectranspped_id
                                          , eb_recria_cte         => false);
         --
      else
         --   
         gv_mensagem_log := 'Esta Nota Fiscal possui um CT-e vinculado, o qual não pode ser reiciniado - '||chr(13)||
                            'Somente é permitido reiniciar CTe se ele estiver com status "Erro de Validação" ou "Pedido não Encontrado"';
         pkb_grava_log_generico(en_notafiscalped_id, INFORMACAO);
         goto sair_geral;
         --
      end if; 
      --   
   end loop;     
   --
   vn_fase := 4;
   --
   -- Exclui os registros gerados para a nova geração
   delete LOG_GENERICO_NF_PED t
     where t.referencia_id = en_notafiscalped_id;
   --
   vn_fase := 5;
   --
   delete ct_inf_nfe_ped t
     where t.notafiscal_id in (select notafiscal_id
                                 from NOTA_FISCAL_PED t
                               where t.id = en_notafiscalped_id);
   --
   vn_fase := 6;
   --
   delete R_LOTEINTWS_NFPEDSTRETERP t
     where t.nfpedstreterp_id in (select id
                                    from nf_ped_st_ret_erp t
                                  where t.notafiscalped_id = en_notafiscalped_id);
   --
   vn_fase := 7;
   --
   delete NF_PED_ST_RET_ERP t
     where t.notafiscalped_id = en_notafiscalped_id;
   --
   vn_fase := 8;
   --
   delete IMP_ITEMNF_PED t
     where t.itemnfped_id in (select id
                                from ITEM_NF_PED t
                              where t.notafiscalped_id = en_notafiscalped_id);
   --
   vn_fase := 9;
   --
   delete ITEM_NF_PED t
     where t.notafiscalped_id = en_notafiscalped_id;
   --
   vn_fase := 10;
   --
   delete NOTA_FISCAL_PED t
     where t.id = en_notafiscalped_id;
   --
   vn_fase := 11;
   --
   -- Re-gera a nota_fiscal_ped
   pkb_valid_regra(en_empresa_id       => gt_row_notafiscal_ped.empresa_id,
                   en_notafiscal_id    => gt_row_notafiscal_ped.notafiscal_id,
                   en_notafiscalped_id => gn_aux);
   --
   --
   <<sair_geral>>
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_nf.pkb_reinicia_nfp fase(' || vn_fase || '):' || sqlerrm;
      pkb_grava_log_generico(en_notafiscalped_id, INFORMACAO);
      rollback;
      --
end pkb_reinicia_nfp;

----------------------------------------------------------------------------------------------------------
--
end pk_relac_ped_nf;
/
