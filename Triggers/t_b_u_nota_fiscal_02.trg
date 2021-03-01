create or replace trigger csf_own.t_b_u_nota_fiscal_02
before update
    on "CSF_OWN"."NOTA_FISCAL"
referencing old as old new as new
for each row
    when(
          old.dm_st_proc   in (4,7)    and
          new.dm_st_proc not in (4,7)  and 
          old.nfe_proc_xml is not null and
          new.dm_ind_emit = 0 and 
          new.modfiscal_id = 31 
        )
declare
   vn_multorg_id     mult_org.id%type;
   vv_multorg_cd     mult_org.cd%type;
   --
   vv_nome_servidor  varchar2(200);
   vv_instancia      varchar2(200);
   vv_maquina        varchar2(200);
   vv_ip_cliente     varchar2(200);
   vv_usuario_so     varchar2(200);
   vv_usuario_banco  varchar2(200);
   vv_PROGRAM    varchar2(32000);
   vn_usuario_id     neo_usuario.id%type;
   --
   vv_resumo         log_nota_fiscal.resumo%type;
   vv_mensagem       log_nota_fiscal.mensagem%type;
   --
   vn_notafiscal_id  nota_fiscal.id%type;
   --
   vv_acao           varchar2(30);
   vv_objeto         varchar2(300) := 'Objeto não identificado';
   vn_fase           number;
   --
   vn_qtde           number :=0;
   vv_erro           varchar2(4000);
   --
begin
   -------------------------------------------------------------------------------
   -- 
   -- Em 27/01/2021 - Wendel Albino
   -- #75567 permitido alterar se houver cnacelamento ou carta de correcao 
   -- 
   -- Armando 26/05/2020
   -- #73274 - verificação da troca do dm_st_proc quando o mesmo for 4 autorizado
   --
   -------------------------------------------------------------------------------
   vn_multorg_id := pk_csf.fkg_multorg_id_empresa (:new.empresa_id);
   vv_multorg_cd := pk_csf.fkg_multorg_cd         (vn_multorg_id);
   --
   -- recupera os dados do usuario logado
   begin
      select sys_context('USERENV', 'SERVER_HOST')   "Nome SERVIDOR"
           , sys_context('USERENV', 'INSTANCE_NAME') "Instância"
           , sys_context('USERENV', 'HOST')          "Maquina"
           , sys_context('USERENV', 'IP_ADDRESS')    "IP Cliente"
           , sys_context('USERENV', 'OS_USER')       "Usuário OS"
           , sys_context('USERENV', 'SESSION_USER')  "Usuario_banco"
        into vv_nome_servidor
           , vv_instancia
           , vv_maquina
           , vv_ip_cliente
           , vv_usuario_so
           , vv_usuario_banco
        from dual;
   exception
      when others then
         vv_nome_servidor  := 'Erro ao recuperar vlr';
         vv_instancia      := 'Erro ao recuperar vlr';
         vv_maquina        := 'Erro ao recuperar vlr';
         vv_ip_cliente     := 'Erro ao recuperar vlr';
         vv_usuario_so     := 'Erro ao recuperar vlr';
         vv_usuario_banco  := 'Erro ao recuperar vlr';
         vv_program        := 'Erro ao recuperar vlr';
   end;
   --
   -- recupera os dados do programa
   begin
      select sys_context('USERENV', 'PROGRAM')  "Comando_SQL"
        into vv_program
        from dual;
   exception
     when others then
      vv_program  := 'Programa nao encontrado.';
   end;
   --
   vv_acao := 'Tentativa de Alteração';
   --
   vv_objeto := pk_csf_api.gv_objeto || pk_valida_ambiente.gv_objeto || pk_integr_view.gv_objeto || pk_csf_api_sc.gv_objeto || pk_int_view_sc.gv_objeto || pk_vld_amb_sc.gv_objeto || pk_csf_api_nfs.gv_objeto || pk_valida_ambiente_nfs.gv_objeto || pk_integr_view_nfs.gv_objeto;
   vn_fase   := pk_csf_api.gn_fase   || pk_valida_ambiente.gn_fase   || pk_integr_view.gn_fase   || pk_csf_api_sc.gn_fase   || pk_int_view_sc.gn_fase   || pk_vld_amb_sc.gn_fase   || pk_csf_api_nfs.gn_fase   || pk_valida_ambiente_nfs.gn_fase   || pk_integr_view_nfs.gn_fase;
   --
   if vv_objeto is null then
     --
     vv_objeto := nvl(vv_objeto, 'Objeto não mapeado');
     vn_fase   := nvl(vn_fase, 0);
     --
   end if;
   --
   vv_resumo   := 'Log da T_B_U_Nota_Fiscal_02: Foi executado '|| vv_acao || ' na Nota Fiscal, pelo objeto ('||vv_objeto||'), na fase ('||vn_fase||')';
   vv_mensagem := 'Valores novos: ' ||
                  'dm_st_proc ('    ||  nvl(:new.dm_st_proc,0)||'), '||
                  'empresa_id ('    ||  :new.empresa_id       ||'), '||
                  'sitdocto_id  ('  ||  :new.sitdocto_id      ||'), '||
                  'lote_id ('       ||  :new.lote_id          ||'), '||
                  'inutilizanf_id ('||  :new.inutilizanf_id   ||'), '||
                  'dm_ind_emit ('   ||  :new.dm_ind_emit      ||'), '||
                  'dm_ind_oper ('   ||  :new.dm_ind_oper      ||'), '||
                  'dt_emiss ('      ||  :new.dt_emiss         ||'), '||
                  'nro_nf ('        ||  :new.nro_nf           ||'), '||
                  'serie ('         ||  :new.serie            ||'), '||
                  'dm_st_proc ('    ||  :new.dm_st_proc       ||'), '||
                  'dt_st_proc ('    ||  :new.dt_st_proc       ||'), '||
                  'dm_tp_amb ('     ||  :new.dm_tp_amb        ||'), '||
                  'dm_proc_emiss (' ||  :new.dm_proc_emiss    ||'), '||
                  'dt_aut_sefaz ('  ||  :new.dt_aut_sefaz     ||'), '||
                  'dm_aut_sefaz ('  ||  :new.dm_aut_sefaz     ||'), '||
                  'dt_hr_ent_sist ('||  :new.dt_hr_ent_sist   ||'), '||
                  'nro_protocolo (' ||  :new.nro_protocolo    ||'), '||
                  'msgwebserv_id (' ||  :new.msgwebserv_id    ||'), '||
                  'cod_msg ('       ||  :new.cod_msg          ||'), '||
                  'dm_envio_reinf ('||  :new.dm_envio_reinf   ||'), '||
                  'vv_PROGRAM     ('||   vv_program        ||').';
   --
   begin
      select id
        into vn_usuario_id
        from neo_usuario t
       where upper(t.login) = upper(vv_usuario_banco);
   exception
      when others then
         select id
           into vn_usuario_id
           from neo_usuario t
          where upper(t.login) = upper('admin');
   end;
   --
   vn_notafiscal_id := :new.id;
   --
   begin
       select count(1)
         into vn_qtde
         from ( select 1
                  from nota_fiscal_canc c -- verifica se tem cancelamento
                 where c.notafiscal_id = VN_NOTAFISCAL_ID
                union
                select 1
                  from nota_fiscal_cce    -- verifica se tem carta de correcao
                 where notafiscal_id = VN_NOTAFISCAL_ID
                 );
   exception
     when no_data_found then
         vn_qtde :=0;
     when others then
       vn_qtde := 0;
       vv_erro := sqlerrm;
    end;
   --
   pk_csf_api.pkb_inclui_log_nota_fiscal(  en_notafiscal_id => vn_notafiscal_id
                                         , ev_resumo        => vv_resumo
                                         , ev_mensagem      => nvl(vv_erro, vv_mensagem)  --||', Erro nota_fiscal_canc: '||vv_erro
                                         , en_usuario_id    => vn_usuario_id
                                         , ev_maquina       => vv_maquina );
   --
   -- #73274 if adicionado para monitorar alteração do dm_st_proc de 4 para 1 sem ter dados na tabela nota_fiscal_canc as empresas do if são da usina ester
   if vn_qtde = 0 then --and :new.empresa_id in (511,2957,2958,2959,2960,2961,2962,2963,2964,2965,2966,2967,2968,2969,2970,2971,2972,2973,2974) then
      :new.dm_st_proc := :old.dm_st_proc;
   end if;
   --   
   -- MANTER O XML DA NFE_PROC_XML
   :new.nfe_proc_xml := :old.nfe_proc_xml;
   --
end t_b_u_nota_fiscal_02;
/