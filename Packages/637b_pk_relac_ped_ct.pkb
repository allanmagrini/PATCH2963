create or replace package body csf_own.pk_relac_ped_ct  is
--
----------------------------------------------------------------------------------------------------------
-- Procedimento para gravar o log_generico
----------------------------------------------------------------------------------------------------------
procedure pkb_grava_log_generico ( en_referencia_id in log_generico_ct_ped.referencia_id%type
                                 , en_tipo_log      in log_generico_ct_ped.csftipolog_id%type)
is
--
begin
   --
   pk_csf_api_pedido.pkb_log_generico_ct_ped ( sn_loggenericoctped_id   => gn_loggenerico_id
                                             , ev_mensagem              => gv_resumo_log || gv_mensagem_log
                                             , ev_resumo                => gv_mensagem_log
                                             , en_tipo_log              => en_tipo_log
                                             , en_referencia_id         => en_referencia_id
                                             , ev_obj_referencia        => gv_obj_referencia
                                             , en_empresa_id            => gn_empresa_id
                                             , en_dm_impressa           => 0
                                             );
   --
   if en_tipo_log in (ERRO_DE_VALIDACAO, ERRO_DE_SISTEMA) then
      gn_erro := gn_erro + 1;
   end if;
   --
end pkb_grava_log_generico;
--
----------------------------------------------------------------------------------------------------------
-- Função que retorna o item_pedido.id
----------------------------------------------------------------------------------------------------------
function fkg_ret_itempedido_id (en_itemnfped_id      in item_nf_ped.id%type 
                              , en_itempedido_id     in item_pedido.id%type
                              , st_item_pedido      out item_pedido%rowtype
                              , sv_erro             out varchar2) return boolean 
is
   --
   vn_fase  number  := 0;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_itempedido_id, 0) > 0 then
      begin
         select *
           into st_item_pedido
         from item_pedido
         where id = en_itempedido_id;
      exception
         when no_data_found then
            sv_erro := 'Não foi localizado um pedido para o Conhecimento de Transporte';
            return false;
         when others then
            sv_erro := 'Problemas ao localizar o item do pedido - (Fase: '||vn_fase||') - Erro Retornado: '||sqlerrm;
            return false;
      end;       
      --
   elsif nvl(en_itemnfped_id, 0) > 0 then
      --
      begin
         --
         select ip.* 
            into st_item_pedido
            from item_pedido      ip
               , item_nf_ped       inp
         where inp.itempedido_id = ip.id
           and inp.id            = en_itemnfped_id;
           --
      exception
         when no_data_found then
            sv_erro := 'Não foi localizado um pedido para o Conhecimento de Transporte';
            return false;
         when others then
            sv_erro := 'Problemas ao localizar o item do pedido - (Fase: '||vn_fase||') - Erro Retornado: '||sqlerrm;
            return false;
      end;   
      --
   else
      --
      sv_erro := 'Não foi localizado um pedido para o Conhecimento de Transporte';
      return false;
      --
   end if;   
   --   
   return true;
   --
end fkg_ret_itempedido_id;
--
----------------------------------------------------------------------------------------------------------
-- Função que retorna o proximo nro_item do item_ct_ped
----------------------------------------------------------------------------------------------------------
function fkg_ret_proximo_nro_item (en_conhectranspped_id in conhec_transp_ped.id%type ) return number
is
  vn_nro_item number := 1;
begin
   --
   begin
      select nvl(max(nro_item),0) + 1
        into vn_nro_item
        from item_ct_ped
      where conhectranspped_id = en_conhectranspped_id; 
   exception
      when others then
         vn_nro_item := 1;
   end;
   --
   return vn_nro_item;
   --
end fkg_ret_proximo_nro_item;
--
----------------------------------------------------------------------------------------------------------
-- Função que Checa se todos os itens do Conhecimento de Transporte tem vinculo com itens de pedido
----------------------------------------------------------------------------------------------------------
function fkg_chk_iten_vinculado_pedido ( en_conhectranspped_id     in conhec_transp_ped.id%type
                                       , sn_qtd_itens             out number
                                       , sn_qtd_itens_vinculados  out number
                                       , sv_erro                  out varchar2
                                  ) return boolean is
   --
begin
   --
   begin
      select count(1)                                       qtd_itens
           , sum(decode(nvl(i.itempedido_id, 0), 0, 0, 1))  qtd_itens_vinculados
      into sn_qtd_itens, sn_qtd_itens_vinculados
         from item_ct_ped i
      where i.conhectranspped_id = en_conhectranspped_id;
   exception
      when others then
         sv_erro := 'Erro não tratado na função fkg_chk_itens_vinculados' ||chr(13)||
                    'Erro Retornado: '||sqlerrm;
         return false;
   end;
   --
   return true;
   --
end fkg_chk_iten_vinculado_pedido;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que carrega os dados do item do conhecimento de transporte
----------------------------------------------------------------------------------------------------------
procedure pkb_dados_item_ct_ped ( en_conhectransp_id    in conhec_transp.id%type
                                , en_conhectranspped_id in conhec_transp_ped.id%type
                                ) is
   --
   vn_fase                number := null;
   vn_itempedido_id       item_pedido.id%type;
   vn_itemctped_id        item_ct_ped.id%type;
   vn_dm_st_proc          item_ct_ped.dm_st_proc%type;
   vb_existe_ictp         boolean := False;
   vv_unidade_pedido      unidade.sigla_unid%type;
   vv_unidade_cte         unidade.sigla_unid%type;
   vt_item_ct_ped         item_ct_ped%rowtype;
   --
begin
   --
   vn_fase := 1;
   --
   for rec_item in c_item(en_conhectransp_id, en_conhectranspped_id) loop
      --
      gn_referencia_id := rec_item.conhectranspped_id;
      --
      --
      vn_fase := 2;
      --        
      -- Verifica se já existe a item_ct_ped para inserir ou atualizar
      begin
         --
         vt_item_ct_ped  := null;
         vn_itemctped_id := null;
         --
         select inp.*
           into vt_item_ct_ped
         from item_ct_ped inp  -- UK: CONHECTRANSPPED_ID, ITEMPEDIDO_ID, ITEMNFPED_ID, TIPOIMP_ID, NRO_CHAVE_NFE_REF, NRO_ITEM
         where inp.conhectranspped_id       = rec_item.conhectranspped_id
           and nvl(inp.itempedido_id,0)     = nvl(rec_item.itempedido_id,0)
           and nvl(inp.itemnfped_id,0)      = nvl(rec_item.itemnfped_id,0)
           and nvl(inp.tipoimp_id,0)        = nvl(rec_item.tipoimp_id,0)
           and nvl(inp.nro_chave_nfe_ref,0) = nvl(rec_item.nro_chave_nfe,0)
           and nvl(inp.nro_item,0)          = nvl(rec_item.nro_item,0)
           and rownum = 1;
         --
         vb_existe_ictp  := True;
         vn_itemctped_id := vt_item_ct_ped.id;
         --
      exception
         when no_data_found then
            vb_existe_ictp := False;
      end;
      --
      vn_fase := 3;
      --
      -- Busca o pedido pela nota fiscal vinculada ao CT-e --
      --
      vn_itempedido_id   := null;
      gt_row_item_pedido := null;
      --
      --
      vn_fase := 4;
      --
      if fkg_ret_itempedido_id (en_itemnfped_id     => rec_item.itemnfped_id
                              , en_itempedido_id    => vt_item_ct_ped.itempedido_id                      
                              , st_item_pedido      => gt_row_item_pedido
                              , sv_erro             => gv_erro) then
         --
         vn_itempedido_id := gt_row_item_pedido.id;
         --
      end if;
      --
      vn_fase := 5;
      --        
      -- Chama function que retorna o parâmetro de recebimento para vincular na nota_fiscal_ped
      if not pk_csf_pedido.fkg_ret_param_receb_ct ( en_multorg_id              => rec_item.multorg_id                                                           -- Mult_org (id)                              - Obrigatório
                                                  , en_modfiscal_id            => rec_item.modfiscal_id                                                         -- Modelo Fiscal (id)                         - Obrigatório
                                                  , en_dm_fin_nfe              => null                                                                          -- Identificador da finalidade da Nota Fiscal - Opcional
                                                  , en_cfop_id                 => rec_item.cfop_id                                                              -- CFOP (id)                                  - Opcional
                                                  , en_utilizacaofiscal_id     => rec_item.utilizacaofiscal_id                                                  -- Utilização Fiscal                          - Opcional
                                                  , en_dm_mod_frete            => null                                                                          -- Modelo de Frete                            - Opcional
                                                  , en_dm_obrig_pedido         => null                                                                          -- Obriga Pedido                              - Opcional
                                                  , en_finalidade_id           => gn_finalidade_id                                                              -- Finalidade do Pedido                       - Opcional
                                                  , en_dm_ind_emit             => nvl(rec_item.dm_ind_emit, 1)                                                  -- Nota vinculada é emiss. propria/terceiros  - Opcional -- 08/10/2019 - por determinação do Thiago denadai, se for nulo, considerar 1
                                                  , en_item_id                 => gt_row_item_pedido.item_id                                                    -- Busca por item                             - Opcional
                                                  , en_dm_vlr_prev_frete       => case when nvl(gt_row_item_pedido.vlr_frete,0) > 0 then 1 else 0 end           -- Indica se o frete foi previsto no pedido   - Opcional
                                                  , sgt_row_item_param_receb   => gt_row_c_param_receb_itm                                                      -- Valores do Parâmetro (saída)
                                                  , sv_erro                    => gv_mensagem_log                                                               -- Mensagem de erro (return false)
                                                  ) then
         --
         if gv_mensagem_log is not null then
            --
            pkb_grava_log_generico(nvl(rec_item.conhectranspped_id, en_conhectransp_id), ERRO_DE_VALIDACAO);
            --
         end if;
         --
      end if;         
      --
      vn_fase := 6;
      --
      -- Ser não achou pedido vinculado pela nota fiscal, tenta achar pedido vinculado manualmente
      if nvl(vn_itempedido_id, 0) = 0 and nvl(vt_item_ct_ped.itempedido_id,0) > 0 then
         --
         vn_itempedido_id := vt_item_ct_ped.itempedido_id;
         --
      end if;
      --
      vn_fase := 7;
      --
      -- Conversão unidade de medida: DM_COD_UNID - Codigo da Unidade de Medida: 00-M3; 01-KG; 02-TON; 03-UNIDADE; 04-LITROS
      if nvl(vn_itempedido_id,0) > 0 and rec_item.dm_cod_unid in ('01', '02') then
         --
         vv_unidade_pedido := pk_csf.fkg_unidade_sigla(gt_row_item_pedido.unidade_id);
         vv_unidade_cte    := case rec_item.dm_cod_unid when '01' then 'KG' else 'TON' end;
         --
      end if;   
      --
      vn_fase := 8;
      --
      -- Validação de departamento_id conforme parâmetro dm_obriga_departamento --
      if gt_row_c_param_receb_itm.dm_obriga_departamento = 1 and nvl(vt_item_ct_ped.departamento_id,0) = 0 then
         --
         gv_mensagem_log := 'Para este documento é obrigatório informar o departamento';
         pkb_grava_log_generico(en_conhectranspped_id, ERRO_DE_VALIDACAO);
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
      if not vb_existe_ictp then
         --
         vn_fase := 10.1;
         --
         begin
            select itemctped_seq.nextval
              into vn_itemctped_id
              from dual;
         exception
            when others then
               vn_itemctped_id := null;
         end;
         --
         insert into item_ct_ped ( id
                                 , conhectranspped_id
                                 , itempedido_id
                                 , itemnfped_id
                                 , vl_prest_serv
                                 , vl_receb
                                 , tipoimp_id
                                 , codst_id
                                 , vl_base_calc
                                 , aliq_apli
                                 , vl_imp_trib
                                 , vl_total_merc
                                 , vl_carga_averb
                                 , dm_cod_unid
                                 , tipo_medida
                                 , qtde_carga
                                 , dm_st_proc
                                 , dt_ult_confronto
                                 , utilizacaofiscal_id
                                 , vl_desc
                                 , vl_unit_transp
                                 , vl_unit_convert
                                 , departamento_id
                                 , depositoerp_id
                                 , nro_chave_nfe_ref
                                 , nro_item
                                 )
                          values ( vn_itemctped_id                        -- id
                                 , rec_item.conhectranspped_id            -- conhectranspped_id
                                 , vn_itempedido_id                       -- itempedido_id
                                 , rec_item.itemnfped_id                  -- itemnfped_id
                                 , rec_item.vl_prest_serv                 -- vl_prest_serv
                                 , rec_item.vl_receb                      -- vl_receb
                                 , rec_item.tipoimp_id                    -- tipoimp_id
                                 , rec_item.codst_id                      -- codst_id
                                 , rec_item.vl_base_calc                  -- vl_base_calc
                                 , rec_item.aliq_apli                     -- aliq_apli
                                 , rec_item.vl_imp_trib                   -- vl_imp_trib
                                 , rec_item.vl_total_merc                 -- vl_total_merc
                                 , rec_item.vl_carga_averb                -- vl_carga_averb
                                 , rec_item.dm_cod_unid                   -- dm_cod_unid
                                 , rec_item.tipo_medida                   -- tipo_medida
                                 , rec_item.qtde_carga                    -- qtde_carga
                                 , vn_dm_st_proc                          -- dm_st_proc
                                 , sysdate                                -- dt_ult_confronto
                                 , gt_row_item_pedido.utilizacaofiscal_id -- utilizacaofiscal_id
                                 , 0                                      -- vl_desc
                                 , 0                                      -- vl_unit_transp
                                 , 0                                      -- vl_unit_convert
                                 , gt_row_item_pedido.departamento_id     -- departamento_id
                                 , rec_item.depositoerp_id                -- depositoerp_id
                                 , rec_item.nro_chave_nfe                 -- nro_chave_nfe
                                 , fkg_ret_proximo_nro_item(rec_item.conhectranspped_id));
         --
      else
         --
         vn_fase := 10.2;
         --
         update item_ct_ped inp set 
               conhectranspped_id   = rec_item.conhectranspped_id
             , itempedido_id        = vn_itempedido_id
             , vl_prest_serv        = rec_item.vl_prest_serv
             , vl_receb             = rec_item.vl_receb
             , tipoimp_id           = rec_item.tipoimp_id        
             , codst_id             = rec_item.codst_id          
             , vl_base_calc         = rec_item.vl_base_calc      
             , aliq_apli            = rec_item.aliq_apli         
             , vl_imp_trib          = rec_item.vl_imp_trib       
             , vl_total_merc        = rec_item.vl_total_merc     
             , vl_carga_averb       = rec_item.vl_carga_averb    
             , dm_cod_unid          = rec_item.dm_cod_unid       
             , tipo_medida          = rec_item.tipo_medida       
             , qtde_carga           = rec_item.qtde_carga        
             , dm_st_proc           = vn_dm_st_proc
             , dt_ult_confronto     = sysdate
             , utilizacaofiscal_id  = gt_row_item_pedido.utilizacaofiscal_id
             , departamento_id      = gt_row_item_pedido.departamento_id
             , nro_chave_nfe_ref    = rec_item.nro_chave_nfe
          where inp.id                             = vn_itemctped_id
            and gt_row_conhectransp_ped.dm_st_proc in (0,1)       -- Só permite atualizar os dados da nota se estiver com algum destes dm_dt_proc
            and gt_row_conhectransp_ped.dm_edicao   = 0;          -- Não permitir sobrepor os dados caso tenha tido edição por tela
         --
      end if;
      --
      vn_fase := 11;
      --
      -- Atualiza o PARAMRECEB_ID do CONHEC_TRANSP_PED --
      update CONHEC_TRANSP_PED set
          paramreceb_id = gt_row_c_param_receb_itm.paramreceb_id
      where id                                  = gt_row_conhectransp_ped.id
        and gt_row_conhectransp_ped.dm_st_proc in (0,1)       -- Só permite atualizar os dados da nota se estiver com algum destes dm_dt_proc
        and gt_row_conhectransp_ped.dm_edicao   = 0;          -- Não permitir sobrepor os dados caso tenha tido edição por tela
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      gv_resumo_log   := 'Inserção na tabela dos dados dos itens da nota fiscal';
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_dados_item_ct_ped fase(' || vn_fase || '):' || sqlerrm;
      pkb_grava_log_generico(gn_referencia_id, ERRO_DE_VALIDACAO);
      --
end pkb_dados_item_ct_ped;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que popula a tabela de relacionamento entre conhecimento de transporte e nota fiscal
----------------------------------------------------------------------------------------------------------
procedure pkb_dados_ctinfnfe_ped ( en_conhectransp_id conhec_transp.id%type ) is
   --
   vn_fase number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   -- Gera os dados da tabela CT_INF_NFE_PED
   insert into CT_INF_NFE_PED (ID,
                               CONHECTRANSPPED_ID,
                               NOTAFISCAL_ID)
   select ctinfnfeped_seq.nextval, ctp.id, nf.id notafiscal_id
      from CT_INF_NFE        cin
         , CONHEC_TRANSP_PED ctp
         , NOTA_FISCAL        nf
   where ctp.conhectransp_id   = cin.conhectransp_id
     and nf.nro_chave_nfe      = cin.nro_chave_nfe
     and (
           (nf.dm_arm_nfe_terc = 1 and nf.dm_ind_emit = 1)
      or
           (nf.dm_arm_nfe_terc = 0 and nf.dm_ind_emit = 0)
         )
     and cin.conhectransp_id   = en_conhectransp_id
     and not exists(
        select 1
          from CT_INF_NFE_PED cc
        where cc.conhectranspped_id = ctp.id
          and cc.notafiscal_id      = nf.id);
   --
   commit;
   --
exception 
   when others then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_dados_ctinfnfe_ped fase(' || vn_fase || '):' || sqlerrm;
      pkb_grava_log_generico(gn_referencia_id, ERRO_DE_VALIDACAO);
      --
end pkb_dados_ctinfnfe_ped;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que carrega os dados da nota fiscal
----------------------------------------------------------------------------------------------------------
procedure pkb_dados_conhectransp_ped ( en_conhectransp_id     in  conhec_transp.id%type
                                     , sn_conhectranspped_id out  conhec_transp_ped.id%type)
is
   --
   vn_fase                  number := null;
   vn_conhectranspped_id    conhec_transp_ped.id%type;
   vb_existe_ctp            boolean := False;
   --
begin
   --
   vn_fase := 1;
   --
   for rec_ct in c_ct ( en_conhectransp_id ) loop
      exit when c_ct%notfound or (c_ct%notfound) is null;
      --
      gn_referencia_id := rec_ct.conhectranspped_id;
      --
      vn_fase := 2;
      --
      -- Checa se o conhecimento de transporte já existe --
      begin
         select distinct 1
            into gn_aux
           from conhec_transp_ped ctp
          where ctp.conhectransp_id = rec_ct.conhectransp_id;
         --
         vb_existe_ctp := True;
         --
      exception
         when no_data_found then
            vb_existe_ctp := False;
      end;
      --
      vn_fase := 3;
      --
      -- Se não existe o Conhecimento de Transporte, insere
      if not vb_existe_ctp then
         --
         vn_fase := 4.1;
         --
         begin
            select conhectranspped_seq.nextval
              into vn_conhectranspped_id
              from dual;
            --
            pk_csf_api_pedido.gt_row_ctped.id := vn_conhectranspped_id;
            sn_conhectranspped_id             := vn_conhectranspped_id;
            gn_referencia_id                  := vn_conhectranspped_id;
            --
         exception
            when others then
               vn_conhectranspped_id := null;
         end;
         --
         vn_fase := 4.2;
         --
         insert into conhec_transp_ped ( id
                                       , conhectransp_id
                                       , empresa_id
                                       , modfiscal_id
                                       , dt_receb
                                       , paramreceb_id
                                       , dm_edicao
                                       , dm_st_proc 
                                       , placa
                                       , uf
                                       )
                                values ( vn_conhectranspped_id                         -- id
                                       , rec_ct.conhectransp_id                        -- conhectransp_id
                                       , rec_ct.empresa_id                             -- empresa_id
                                       , rec_ct.modfiscal_id                           -- modfiscal_id
                                       , rec_ct.dt_receb                               -- dt_receb
                                       , gt_row_c_param_receb_itm.paramreceb_id         -- paramreceb_id
                                       , 0                                             -- dm_edicao
                                       , 0                                             -- dm_st_proc
                                       , rec_ct.placa
                                       , rec_ct.uf
                                       );
         --
      else
         --
         vn_fase := 4.3;
         --
         sn_conhectranspped_id := rec_ct.conhectranspped_id;
         --
         update conhec_transp_ped set   
               conhectransp_id = rec_ct.conhectransp_id
             , empresa_id      = rec_ct.empresa_id
             , modfiscal_id    = rec_ct.modfiscal_id
             , dt_receb        = rec_ct.dt_receb
             , paramreceb_id   = gt_row_c_param_receb_itm.paramreceb_id
             , dm_edicao       = rec_ct.dm_edicao
             , dm_st_proc      = 0
             , placa           = rec_ct.placa
             , uf              = rec_ct.uf
         where conhectransp_id = rec_ct.conhectransp_id
           and dm_st_proc      in (0,1,2,7)  -- Só permite atualizar os dados da nota se estiver com algum destes dm_st_proc
           and dm_edicao       = 0;          -- Não permitir sobrepor os dados caso tenha tido edição por tela
         --
      end if;
      --
      commit;
      --
      vn_fase := 5;
      --
      select *
        into gt_row_conhectransp_ped
        from conhec_transp_ped
       where conhectransp_id = rec_ct.conhectransp_id;
      --      
      --
      vn_fase := 6;
      --
      -- Chama a rotina para inserir os dados na ct_inf_nfe_ped
      pkb_dados_ctinfnfe_ped ( en_conhectransp_id    => rec_ct.conhectransp_id );
      --
      vn_fase := 7;
      --
      -- Chama rotina para inserir dados na item_ct_ped
      pkb_dados_item_ct_ped ( en_conhectransp_id    => rec_ct.conhectransp_id
                            , en_conhectranspped_id => gt_row_conhectransp_ped.id
                            );
      --
      -- Recalcula os Totais do Conhecimento de Transporte
      pk_csf_pedido.pkb_recalcula_ctp(en_conhectranspped_id => gt_row_conhectransp_ped.id);
      --
      commit;
      --
   end loop;
   --
exception
   when others then
      --
      gv_resumo_log   := 'Inserção na tabela dos dados da nota fiscal';
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_dados_conhectransp_ped fase(' || vn_fase || '):' || sqlerrm;
      pkb_grava_log_generico(gn_referencia_id, ERRO_DE_VALIDACAO);
      --
end pkb_dados_conhectransp_ped;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento de validação das Regras para Relacionar o Conhecimento de Transporte ao Pedido
----------------------------------------------------------------------------------------------------------
procedure pkb_valid_regra ( en_empresa_id         in empresa.id%type
                          , en_conhectransp_id    in conhec_transp.id%type
                          , en_conhectranspped_id in out conhec_transp_ped.id%type
                          ) is
   --
   vn_fase                          number := null;
   vn_dm_st_proc                    conhec_transp_ped.dm_st_proc%type;
   vn_qtd_itens                     number := 0;
   vn_qtd_iten_vinculado_pedidos    number := 0;
   --
begin
   --
   vn_fase := 1;
   --
   gn_erro                  := 0;
   gn_empresa_id            := en_empresa_id;
   gt_row_c_param_receb_itm := null;
   --
   vn_fase := 2;
   --
   if nvl(en_conhectransp_id, 0) > 0 or nvl(en_conhectranspped_id, 0) > 0 then
      --
      vn_fase := 3;
      --
      pkb_dados_conhectransp_ped ( en_conhectransp_id    => en_conhectransp_id
                                 , sn_conhectranspped_id => en_conhectranspped_id);
      --
   end if;
   --
   vn_fase := 4;
   --
   -- Checa os itens vinculados com pedido --
   if not fkg_chk_iten_vinculado_pedido(en_conhectranspped_id   => en_conhectranspped_id
                                      , sn_qtd_itens            => vn_qtd_itens
                                      , sn_qtd_itens_vinculados => vn_qtd_iten_vinculado_pedidos
                                      , sv_erro                 => gv_erro) then
      --
      gv_mensagem_log := 'Erro ao tentar busacar a quantidade de itens vinculados com o pedido '||chr(13)||
                         'Erro Retornado: '||gv_erro;
      pkb_grava_log_generico(en_conhectranspped_id, ERRO_DE_VALIDACAO);
      --
   end if;  
   --
   vn_fase := 5;
   --
   -- Trata o DM_ST_PROC --
   -- Se o conhecimento de transporte estiver cancelado, cancela o conhecimento de transporte ped. 
   if pk_csf.fkg_st_proc_ct (en_conhectransp_id) = 7 then
      --
      vn_dm_st_proc := 3;
      --
   -- Caso tenha erro retornado nos processos anteriores dá erro de validação
   elsif gn_erro > 0 then
      --
      vn_fase := 5.1;
      --
      vn_dm_st_proc := 2; -- Erro de Validação
      --
   -- Se tem parametro de recebimento, todos os itens tem vinculo com pedido, Passa pelo processo de validação de regras --
   elsif nvl(en_conhectranspped_id, 0) > 0 and nvl(gt_row_c_param_receb_itm.paramreceb_id, 0) > 0 and gn_erro = 0 and vn_qtd_iten_vinculado_pedidos = vn_qtd_itens then
      --
      vn_fase := 5.2;
      --
      pk_vld_regras_negoc_cte.pkb_valida_regra ( en_empresa_id          => gn_empresa_id
                                               , en_conhectranspped_id  => en_conhectranspped_id
                                               , sn_erro                => gn_erro
                                               );
      --
      if nvl(gn_erro,0) > 0 then
         --
         vn_dm_st_proc := 2; -- Erro de Validação
         --
      else
         --
         vn_dm_st_proc := 5; -- Validado
         --
      end if;
      --
   --
   -- Se não obriga pedido e não tem pedido vinculado, seta como validado sem pedido --
   elsif nvl(gt_row_c_param_receb_itm.dm_obrig_pedido,0) = 0 and vn_qtd_iten_vinculado_pedidos = 0 then
      --
      vn_fase := 5.3;
      --
      vn_dm_st_proc := 5; -- Validado (sem pedido)
      --
   --
   -- Se obriga pedido e não tem pedido vinculado, seta como pedido não encontrado --
   elsif nvl(gt_row_c_param_receb_itm.dm_obrig_pedido,0) = 1 and vn_qtd_iten_vinculado_pedidos = 0 then
      --
      vn_fase := 5.4;
      --
      vn_dm_st_proc := 7; -- Pedido não encontrado
      --
   --
   -- Se tem algum item sem vinculo com pedido, seta como não validado e grava log
   elsif vn_qtd_iten_vinculado_pedidos < vn_qtd_itens then
      --
      vn_fase := 5.5;
      --
      vn_dm_st_proc   := 2; -- Erro de Validação
      gv_mensagem_log := 'O Conhecimento de Transporte possui itens sem vínculo com o pedido.';
      pkb_grava_log_generico(en_conhectranspped_id, ERRO_DE_VALIDACAO);
      --
   -- Se não encontrou nenhuma situação impeditiva, seta como validado
   else
     --
     vn_dm_st_proc := 5; -- Validado
     --
   end if;  
   --
   vn_fase := 6;
   --
   -- Atualiza o DM_ST_PROC --
   update conhec_transp_ped c set
      c.dm_st_proc = vn_dm_st_proc
   where c.id = en_conhectranspped_id;   
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_valid_regra fase(' || vn_fase || '):' || sqlerrm;
      pkb_grava_log_generico(gn_referencia_id, ERRO_DE_VALIDACAO);
      --
end pkb_valid_regra;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que identifica dados de pedido e do conhecimento de transporte para relacionar
----------------------------------------------------------------------------------------------------------
procedure pkb_dados_ped_ct ( en_multorg_id mult_org.id%type ) is
   --
   vn_fase        number := null;
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
      for rec_ct in c_inicia_ct ( rec_empresa.id ) loop
         exit when c_inicia_ct%notfound or (c_inicia_ct%notfound) is null;
         --
         vn_fase := 2;
         --
         pkb_valid_regra ( en_empresa_id         => rec_empresa.id
                         , en_conhectransp_id    => rec_ct.conhectransp_id
                         , en_conhectranspped_id => rec_ct.conhectranspped_id
                         );
         --
      end loop;
      --
   end loop;
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_dados_ped_ct fase(' || vn_fase || '):' || sqlerrm;
      pkb_grava_log_generico(gn_referencia_id, ERRO_DE_VALIDACAO);
      --
end pkb_dados_ped_ct;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento para resetar o Conhecimento de Transporte e Reprocessá-lo
----------------------------------------------------------------------------------------------------------
procedure pkb_reinicia_cte ( en_conhectranspped_id  in conhec_transp_ped.id%type
                           , eb_recria_cte          in boolean default true) is
  --
  vt_conhec_trans_ped conhec_transp_ped%rowtype;
  vn_fase             number := 0;
  --
begin
   --
   vn_fase := 1;
   --
   -- Busca os dados do CT-e
   begin
      select t.* 
         into vt_conhec_trans_ped
         from conhec_transp_ped t
      where t.id = en_conhectranspped_id;
   exception
      when others then
         null;
   end;
   --
   vn_fase := 2;
   --
   -- Só é permitido reiniciar o CT-e se estiver com Status (erro de validação e Pedido não encontrado)
   if vt_conhec_trans_ped.dm_st_proc not in (2,7) then
      --
      gv_mensagem_log := 'Somente é permitido reiniciar o documento se ele estiver com status "Erro de Validação" ou "Pedido não Encontrado"';
      pkb_grava_log_generico(en_conhectranspped_id, INFORMACAO);
      goto sair_geral;
      --
   end if;
   --
   vn_fase := 3;
   --
   -- Exclui os registros gerados para a nova geração
   delete LOG_GENERICO_CT_PED t 
      where t.referencia_id = en_conhectranspped_id;
   --   
   vn_fase := 4;
   --
   delete ITEM_CT_PED t 
      where t.conhectranspped_id = en_conhectranspped_id;
   --   
   vn_fase := 5;
   --
   delete CT_INF_NFE_PED t 
      where t.conhectranspped_id = en_conhectranspped_id;
   --   
   vn_fase := 6;
   --
   delete R_LOTEINTWS_CTPEDSTRETERP t 
      where t.ctpedstreterp_id in (select tt.id 
                                     from CT_PED_ST_RET_ERP tt
                                   where tt.conhectranspped_id = en_conhectranspped_id);
   --
   vn_fase := 7;
   --
   delete CT_PED_ST_RET_ERP t
      where t.conhectranspped_id = en_conhectranspped_id;
   --
   vn_fase := 8;
   --
   delete CONHEC_TRANSP_PED where id = en_conhectranspped_id;
   --
   vn_fase := 9;
   --
   -- Gera os dados do Cte novamente
   if eb_recria_cte then
      --
      pkb_valid_regra ( en_empresa_id         => vt_conhec_trans_ped.empresa_id
                      , en_conhectransp_id    => vt_conhec_trans_ped.conhectransp_id
                      , en_conhectranspped_id => vt_conhec_trans_ped.id);
      --                   
   end if;
   --
   <<sair_geral>>
   --
   commit;
   --
exception
   when others then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_reinicia_cte fase(' || vn_fase || '):' || sqlerrm;
      pkb_grava_log_generico(gn_referencia_id, INFORMACAO);
      rollback;
      --
end pkb_reinicia_cte;
--
----------------------------------------------------------------------------------------------------------
-- Procedimento que duplica um ítem do CTe para liberar um recebimento a maior
----------------------------------------------------------------------------------------------------------
procedure pkb_duplica_item_cte ( en_itemctped_id in item_ct_ped.id%type
                               , en_vlr_item     in item_ct_ped.vl_prest_serv%type)
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
   if nvl(en_itemctped_id, 0) = 0 then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_duplica_item_cte'||chr(13)||
                         ' - Obrigatório informar o parâmetro en_itemctped_id';
      --
      pkb_grava_log_generico(en_itemctped_id, ERRO_DE_VALIDACAO);
      --                                                    
   end if;
   --
   if nvl(en_vlr_item, 0) = 0 then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_duplica_item_cte'||chr(13)||
                         ' - Obrigatório informar o parâmetro en_vlr_item';
      --
      pkb_grava_log_generico(en_itemctped_id, ERRO_DE_VALIDACAO);
      --                                                    
   end if;
   --
   if nvl(en_vlr_item, 0) < 0 then
      --
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_duplica_item_cte'||chr(13)||
                         ' - O Parâmetro en_vlr_item não pode ser um número negativo';
      --
      pkb_grava_log_generico(en_itemctped_id, ERRO_DE_VALIDACAO);
      --                                                    
   end if;
   --
   vn_fase := 2;
   --
   -- Pupula os dados do item informado --
   if not pk_csf_pedido.fkg_ret_gt_row_item_ct_ped (en_itemctped_id     => en_itemctped_id,
                                                    sgt_row_item_ct_ped => gt_row_item_ct_ped,
                                                    sv_erro             => gv_erro) then
   --
   gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_duplica_item_cte fase(' || vn_fase || '):' || gv_erro;
   --
   pkb_grava_log_generico(en_itemctped_id, ERRO_DE_VALIDACAO);
   --                                                    
   end if;
   --
   vn_fase := 3;
   --
   -- Calcula o fator de proporção mediante ao valor informado no parâmetro --
   vn_fator := en_vlr_item / gt_row_item_ct_ped.vl_prest_serv;
   --
   vn_fase := 4;
   --
   -- Cria o novo Ítem porporcional ao valor informado --
   gt_row_item_ct_ped.id := itemctped_seq.nextval;
   insert into item_ct_ped (id,
                            conhectranspped_id,
                            itempedido_id,
                            itemnfped_id,
                            vl_prest_serv,
                            vl_receb,
                            tipoimp_id,
                            codst_id,
                            vl_base_calc,
                            aliq_apli,
                            vl_imp_trib,
                            vl_total_merc,
                            vl_carga_averb,
                            dm_cod_unid,
                            tipo_medida,
                            qtde_carga,
                            dm_st_proc,
                            dt_ult_confronto,
                            utilizacaofiscal_id,
                            vl_desc,
                            vl_unit_transp,
                            vl_unit_convert,
                            vl_liquido,
                            departamento_id,
                            depositoerp_id,
                            nro_chave_nfe_ref,
                            dup_itemctped_id,
                            nro_item)
   values (gt_row_item_ct_ped.id,
           gt_row_item_ct_ped.conhectranspped_id,
           gt_row_item_ct_ped.itempedido_id,
           gt_row_item_ct_ped.itemnfped_id,
           gt_row_item_ct_ped.vl_prest_serv   * vn_fator,
           gt_row_item_ct_ped.vl_receb        * vn_fator,
           gt_row_item_ct_ped.tipoimp_id,
           gt_row_item_ct_ped.codst_id,
           gt_row_item_ct_ped.vl_base_calc    * vn_fator,
           gt_row_item_ct_ped.aliq_apli,
           gt_row_item_ct_ped.vl_imp_trib     * vn_fator,
           gt_row_item_ct_ped.vl_total_merc   * vn_fator,
           gt_row_item_ct_ped.vl_carga_averb  * vn_fator,
           gt_row_item_ct_ped.dm_cod_unid,
           gt_row_item_ct_ped.tipo_medida,
           gt_row_item_ct_ped.qtde_carga      * vn_fator,
           0,                                                     --dm_st_proc
           sysdate,                                               --dt_ult_confronto
           gt_row_item_ct_ped.utilizacaofiscal_id,
           gt_row_item_ct_ped.vl_desc         * vn_fator,
           gt_row_item_ct_ped.vl_unit_transp  * vn_fator,
           gt_row_item_ct_ped.vl_unit_convert * vn_fator,
           gt_row_item_ct_ped.vl_liquido      * vn_fator,
           gt_row_item_ct_ped.departamento_id,
           gt_row_item_ct_ped.depositoerp_id,
           gt_row_item_ct_ped.nro_chave_nfe_ref,
           en_itemctped_id,
           fkg_ret_proximo_nro_item(gt_row_item_ct_ped.conhectranspped_id));
   --
   commit;        
   --
   vn_fase := 5;
   --
   -- Atualiza o ítem original --
   update item_ct_ped i set
     i.vl_prest_serv     = i.vl_prest_serv     * (1-vn_fator),
     i.vl_receb          = i.vl_receb          * (1-vn_fator),
     i.vl_base_calc      = i.vl_base_calc      * (1-vn_fator),
     i.vl_imp_trib       = i.vl_imp_trib       * (1-vn_fator),
     i.vl_total_merc     = i.vl_total_merc     * (1-vn_fator),
     i.vl_carga_averb    = i.vl_carga_averb    * (1-vn_fator),
     i.qtde_carga        = i.qtde_carga        * (1-vn_fator),
     i.vl_desc           = i.vl_desc           * (1-vn_fator),
     i.vl_unit_transp    = i.vl_unit_transp    * (1-vn_fator),
     i.vl_unit_convert   = i.vl_unit_convert   * (1-vn_fator),
     i.vl_liquido        = i.vl_liquido        * (1-vn_fator)
   where i.id = en_itemctped_id;   
   --
   commit;
   --
exception
   when others then
      --
      rollback;
      gv_mensagem_log := 'Erro na pk_relac_ped_ct.pkb_duplica_item_cte fase(' || vn_fase || '):' || sqlerrm;
      pkb_grava_log_generico(en_itemctped_id, ERRO_DE_VALIDACAO);
      --
end pkb_duplica_item_cte;
--
----------------------------------------------------------------------------------------------------------
end pk_relac_ped_ct;
/
