create or replace package body csf_own.pk_vld_amb_gpi is

----------------------------------------------------------------------------------------------------
-- Pacote da Validação do Ambiente de Guia de Pagamento de Imposto
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--| Procedure inicia os parâmetros do DIMOB (Locação)
----------------------------------------------------------------------------------------------------
procedure pkb_inicia_guia_pgto_imp ( en_guiapgtoimp_id  in guia_pgto_imp.id%type )
is
   --
begin
   --
   select g.*
     into pk_csf_api_gpi.gt_row_guia_pgto_imp
     from guia_pgto_imp g
    where g.id = en_guiapgtoimp_id;
   --
exception
   when others then
      pk_csf_api_gpi.gt_row_guia_pgto_imp := null;
end pkb_inicia_guia_pgto_imp;

----------------------------------------------------------------------------------------------------
-- Procedimento de validação da tabela de guia_pgto_imp
procedure pkb_ler_guia_pgto_imp ( en_guiapgtoimp_id   in            guia_pgto_imp.id%type
                                , sn_erro             in out nocopy number -- 0-Não; 1-Sim
                                , en_loteintws_id     in            lote_int_ws.id%type default 0
                                , ev_cod_rec_cd_compl in            guia_pgto_imp_compl_gen.cod_receita%type default null
                                )
is
   --
   vn_fase             number := null;
   vn_loggenerico_id   log_generico_gpi.id%type;
   vt_csf_log_generico dbms_sql.number_table;
   vn_guiapgtoimp_id   guia_pgto_imp.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_guiapgtoimp_id,0) > 0 then
      --
      pkb_inicia_guia_pgto_imp ( en_guiapgtoimp_id => en_guiapgtoimp_id );
      --
      vn_fase := 2;
      --
      gn_multorg_id := pk_csf.fkg_multorg_id_empresa(en_empresa_id => pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id );
      --
      vn_fase := 3;
      --
      pk_csf_api_gpi.pkb_seta_obj_ref ( ev_objeto => 'GUIA_PGTO_IMP' );
      --
      vn_fase := 3.1;
      --
      if nvl(pk_csf_api_gpi.gt_row_guia_pgto_imp.id,0) > 0 then
         --
         if nvl(pk_csf_api_gpi.gt_row_guia_pgto_imp.dm_situacao,-1) in (0,2) then
            --
            vn_fase := 3.2;
            --
            -- seta o tipo de integração que será feito
            -- 0 - Válida e Atualiza os dados
            -- 1 - Válida os dados e registra o Log de ocorrência e insere a informação
            -- Todos os procedimentos de integração fazem referência a ele
            pk_csf_api_gpi.pkb_seta_tipo_integr ( en_tipo_integr => 0 );
            --
            vn_fase := 3.3;
            --
            pk_csf_api_gpi.pkb_integr_guia_pgto_imp ( est_log_generico_gpi  => vt_csf_log_generico
                                                    , est_row_guia_pgto_imp => pk_csf_api_gpi.gt_row_guia_pgto_imp
                                                    , en_empresa_id         => pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id
                                                    , en_multorg_id         => pk_csf.fkg_multorg_id_empresa ( en_empresa_id => pk_csf_api_gpi.gt_row_guia_pgto_imp.empresa_id)
                                                    , ev_cod_part           => pk_csf.fkg_pessoa_cod_part ( en_pessoa_id => pk_csf_api_gpi.gt_row_guia_pgto_imp.pessoa_id)
                                                    , en_tipimp_cd          => pk_csf.fkg_Tipo_Imposto_cd ( en_tipoimp_id => pk_csf_api_gpi.gt_row_guia_pgto_imp.tipoimposto_id )
                                                    , ev_tiporetimp_cd      => pk_csf.fkg_tipo_ret_imp_cd ( en_tiporetimp_id => pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimp_id )
                                                    , ev_cod_rec_cd         => pk_csf_gpi.fkg_tiporetimpreceita_cd ( en_tiporetimpreceita_id => pk_csf_api_gpi.gt_row_guia_pgto_imp.tiporetimpreceita_id )
                                                    , ev_cod_rec_cd_compl   => ev_cod_rec_cd_compl
                                                    , sn_guiapgtoimp_id     => vn_guiapgtoimp_id
                                                    );
            --
            if nvl(vt_csf_log_generico.count,0) > 0 then
               --
               sn_erro := 1;
               --
               update guia_pgto_imp
                  set dm_situacao = 2 -- Erro de validação
                where id = pk_csf_api_gpi.gt_row_guia_pgto_imp.id;
               --
            else
               --
               sn_erro := 0;
               --
               update guia_pgto_imp
                  set dm_situacao = 1 -- Validado
                where id = pk_csf_api_gpi.gt_row_guia_pgto_imp.id;
               --
            end if;
            --
            commit;
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
     pk_csf_api_gpi.gv_mensagem_log := 'Erro na pkb_ler_guia_pgto_imp fase(' || vn_fase || '): ' || sqlerrm;
     --
     declare
        vn_loggenerico_id  log_generico_gpi.id%TYPE;
     begin
        --
        pk_csf_api_gpi.pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                                            , ev_mensagem             => pk_csf_api_gpi.gv_mensagem_log
                                            , ev_resumo               => pk_csf_api_gpi.gv_mensagem_log
                                            , en_tipo_log             => pk_csf_api_gpi.ERRO_DE_SISTEMA
                                            , en_referencia_id        => en_guiapgtoimp_id
                                            , ev_obj_referencia       => pk_csf_api_gpi.gv_obj_referencia );
        --
     exception
        when others then
           null;
     end;
     --
     raise_application_error (-20101, pk_csf_api_gpi.gv_mensagem_log);
     --
end pkb_ler_guia_pgto_imp;

----------------------------------------------------------------------------------------------------
--Procedimento de validação de guia de pgto de Importação

procedure pkb_vld_guia_pgto_imp ( en_guiapgtoimp_id   in            guia_pgto_imp.id%type
                                , sn_erro             in out nocopy number
                                , en_loteintws_id     in            lote_int_ws.id%type default 0
                                , ev_cod_rec_cd_compl in            guia_pgto_imp_compl_gen.cod_receita%type default null
                                ) 
is
   --
   vn_fase                      number;
   --
begin
   --
   vn_fase := 1;
   --
   if nvl(en_guiapgtoimp_id,0) > 0 then
      --
      vn_fase := 2;
      --
      pkb_ler_guia_pgto_imp ( en_guiapgtoimp_id   => en_guiapgtoimp_id
                            , sn_erro             => sn_erro
                            , en_loteintws_id     => en_loteintws_id
                            , ev_cod_rec_cd_compl => ev_cod_rec_cd_compl
                            );
      --
   end if;
   --
exception
  when others then
     --
     pk_csf_api_gpi.gv_mensagem_log := 'Erro na pkb_vld_guia_pgto_imp fase(' || vn_fase || '): ' || sqlerrm;
     --
     declare
        vn_loggenerico_id  log_generico_gpi.id%TYPE;
     begin
        --
        pk_csf_api_gpi.pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                                            , ev_mensagem             => pk_csf_api_gpi.gv_mensagem_log
                                            , ev_resumo               => pk_csf_api_gpi.gv_mensagem_log
                                            , en_tipo_log             => pk_csf_api_gpi.ERRO_DE_SISTEMA
                                            , en_referencia_id        => en_guiapgtoimp_id
                                            , ev_obj_referencia       => pk_csf_api_gpi.gv_obj_referencia );
        --
     exception
        when others then
           null;
     end;
     --
     raise_application_error (-20101, pk_csf_api_gpi.gv_mensagem_log);
     --
end pkb_vld_guia_pgto_imp;

----------------------------------------------------------------------------------------------------
-- Procedimento que valida a guia de pgto de Impostos
procedure pkb_vld_guia_pgto_imp ( en_guiapgtoimp_id in guia_pgto_imp.id%type )
is
   --
   vn_fase                number := null;
   vn_erro                number := 0;
   vn_loggenerico_id      log_generico.id%type;
   --
begin
   --
   vn_fase := 1;
   --
   pkb_vld_guia_pgto_imp ( en_guiapgtoimp_id => en_guiapgtoimp_id
                         , sn_erro           => vn_erro
                         );
   --
exception
  when others then
     --
     pk_csf_api_gpi.gv_mensagem_log := 'Erro na pkb_vld_guia_pgto_imp fase(' || vn_fase || '): ' || sqlerrm;
     --
     declare
        vn_loggenerico_id  log_generico_gpi.id%TYPE;
     begin
        --
        pk_csf_api_gpi.pkb_log_generico_gpi ( sn_loggenericogpi_id  => vn_loggenerico_id
                                            , ev_mensagem             => pk_csf_api_gpi.gv_mensagem_log
                                            , ev_resumo               => pk_csf_api_gpi.gv_mensagem_log
                                            , en_tipo_log             => pk_csf_api_gpi.ERRO_DE_SISTEMA
                                            , en_referencia_id        => en_guiapgtoimp_id
                                            , ev_obj_referencia       => pk_csf_api_gpi.gv_obj_referencia );
        --
     exception
        when others then
           null;
     end;
     --
     raise_application_error (-20101, pk_csf_api_gpi.gv_mensagem_log);
     --
end pkb_vld_guia_pgto_imp;

end pk_vld_amb_gpi;
/