create or replace package body csf_own.pk_gera_arq_sint is

-----------------------------------------------------------------------------------------
-- Especificacao do pacote de procedimentos de criacao do arquivo do sintegra - set/12 --
-----------------------------------------------------------------------------------------

------------------------------------------------
-- Procedimento recupera os dados de uma pessoa
------------------------------------------------
PROCEDURE PKB_RECUP_DADOS_PESSOA ( EN_PESSOA_ID  IN  PESSOA.ID%TYPE
                                 , SV_CPF_CNPJ   OUT VARCHAR2
                                 , SV_IE         OUT VARCHAR2
                                 , SV_UF         OUT VARCHAR2
                                 ) IS
   --
   vv_cpf_cnpj   varchar2(14) := '0';
   vv_ie         varchar2(14) := 'ISENTO';
   vv_uf         varchar2(2) := 'EX';
   --
BEGIN
   --
   if nvl(en_pessoa_id,0) > 0 then
      -- recupera o estado
      begin
        select nvl(est.sigla_estado,null) uf
          into vv_uf
          from pessoa  pes
             , cidade  cid
             , estado  est
         where pes.id = en_pessoa_id
           and cid.id = pes.cidade_id
           and est.id = cid.estado_id;
      exception
         when others then
            vv_uf := 'EX';
      end;
      -- recupera o CNPJ (caso for juridica)
      begin
         select (lpad(j.num_cnpj,8,'0')||lpad(j.num_filial,4,'0')||lpad(j.dig_cnpj,2,'0'))
              , j.ie
           into vv_cpf_cnpj
              , vv_ie
           from juridica j
          where j.pessoa_Id = en_pessoa_id;
      exception
         when others then
            vv_cpf_cnpj := null;
            vv_ie := null;
      end;
      --
      if trim(vv_cpf_cnpj) is null then
         --
         begin
            select (lpad(f.num_cpf,9,'0')||lpad(f.dig_cpf,2,'0'))
              into vv_cpf_cnpj
              from fisica f
             where f.pessoa_id = en_pessoa_id;
         exception
            when others then
               vv_cpf_cnpj := null;
         end;
         --
      end if;
      --
      if trim(vv_cpf_cnpj) is null or
         trim(vv_uf) = 'EX' then
         vv_cpf_cnpj := '0';
      end if;
      --
      if trim(vv_ie) is null then
         vv_ie := 'ISENTO';
      end if;
      --
   end if;
   --
   sv_cpf_cnpj := vv_cpf_cnpj;
   sv_ie       := vv_ie;
   sv_uf       := vv_uf;
   --
EXCEPTION
   when others then
      sv_cpf_cnpj := '0';
      sv_ie       := 'ISENTO';
      sv_uf       := 'EX';
END PKB_RECUP_DADOS_PESSOA;

----------------------------------------------------------------------------------
-- Função formata o valor na mascara deseja pelo usuário
----------------------------------------------------------------------------------
FUNCTION FKG_FORMATA_NUM ( EN_NUM     IN NUMBER
                         , EV_MASCARA IN VARCHAR2 )
   RETURN VARCHAR2 IS
BEGIN
   --
   if trim(ev_mascara) is not null then
      return rtrim(ltrim(to_char(en_num, ev_mascara)));
   else
      return null;
   end if;
   --
EXCEPTION
   when others then
      return null;
END FKG_FORMATA_NUM;

-------------------------------------------------------------------------------------------------------
-- Função retorna o ID do registro_SINTEGRA conforme COD
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_REGISTRO_SINT_ID ( EV_CD  IN REGISTRO_SINTEGRA.CD%TYPE )
   RETURN REGISTRO_SINTEGRA.ID%TYPE IS
   --
   vn_id  registro_sintegra.id%type;
   --
BEGIN
   --
   select id
     into vn_id
     from registro_sintegra
    where cd = ev_cd;
   --
   return vn_id;
   --
EXCEPTION
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_arq_sint.fkg_registro_sint_id: '||sqlerrm);
END FKG_REGISTRO_SINT_ID;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0050
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0050 RETURN NUMBER IS
   --
   vn_qtde         number := 0;
   vn_indice       pls_integer := 0;
   vn_indice_bi    pls_integer := 0;
   vn_indice_tri   pls_integer := 0;
   --
BEGIN
   --
   vn_indice := nvl(vt_tri_tab_reg_0050.first,0);
   vn_qtde   := 0;
   --
   loop
      --
      if nvl(vn_indice,-1) = -1 then
         exit;
      end if;
      --
      vn_indice_bi := nvl(vt_tri_tab_reg_0050(vn_indice).first,0);
      --
      loop
         --
         if nvl(vn_indice_bi,-1) = -1 then
            exit;
         end if;
         --
         vn_indice_tri := nvl(vt_tri_tab_reg_0050(vn_indice)(vn_indice_bi).first,0);
         --
         loop
            --
            if nvl(vn_indice_tri,-1) = -1 then
               exit;
            end if;
            --
            vn_qtde := nvl(vn_qtde,0) + 1;
            --
            if vn_indice_tri = vt_tri_tab_reg_0050(vn_indice)(vn_indice_bi).last then
               exit;
            else
               vn_indice_tri := vt_tri_tab_reg_0050(vn_indice)(vn_indice_bi).next(vn_indice_tri);
            end if;
            --
         end loop;
         --
         if vn_indice_bi = vt_tri_tab_reg_0050(vn_indice).last then
            exit;
         else
            vn_indice_bi := vt_tri_tab_reg_0050(vn_indice).next(vn_indice_bi);
         end if;
         --
      end loop;
      --
      if vn_indice = vt_tri_tab_reg_0050.last then
         exit;
      else
         vn_indice := vt_tri_tab_reg_0050.next(vn_indice);
      end if;
      --
   end loop;
   --
   return nvl(vn_qtde,0);
   --
EXCEPTION
   when others then
     return 0;
END FKG_QTDE_LINHA_REG_0050;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0051
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0051 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0051.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0051;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0053
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0053 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0053.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0053;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0054
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0054 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0054.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0054;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0055
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0055 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0055.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0055;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0056
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0056 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0056.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0056;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0057
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0057 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0057.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0057;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0060M
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0060m RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0060M.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0060m;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0060A
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0060a RETURN NUMBER IS
   --
   vn_qtde       number := 0;
   vn_indice     pls_integer := 0;
   vn_indice_bi  pls_integer := 0;
   --
BEGIN
   --
   vn_indice := nvl(vt_bi_tab_reg_0060A.first,0);
   vn_qtde   := 0;
   --
   loop
      --
      if nvl(vn_indice,-1) = -1 then
         exit;
      end if;
      --
      vn_indice_bi := nvl(vt_bi_tab_reg_0060A(vn_indice).first,0);
      --
      loop
         --
         if nvl(vn_indice_bi,-1) = -1 then
            exit;
         end if;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         --
         if vn_indice_bi = vt_bi_tab_reg_0060A(vn_indice).last then
            exit;
         else
            vn_indice_bi := vt_bi_tab_reg_0060A(vn_indice).next(vn_indice_bi);
         end if;
         --
      end loop;
      --
      if vn_indice = vt_bi_tab_reg_0060A.last then
         exit;
      else
         vn_indice := vt_bi_tab_reg_0060A.next(vn_indice);
      end if;
      --
   end loop;
   --
   return nvl(vn_qtde,0);
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0060a;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0060D
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0060d RETURN NUMBER IS
   --
   vn_qtde       number := 0;
   vn_indice     pls_integer := 0;
   vn_indice_bi  pls_integer := 0;
   vn_indice_tri pls_integer := 0;
   --
BEGIN
   --
   vn_indice := nvl(vt_tri_tab_reg_0060D.first,-1);
   vn_qtde := 0;
   --
   loop
      --
      if nvl(vn_indice,-1) = -1 then
         exit;
      end if;
      --
      vn_indice_bi := nvl(vt_tri_tab_reg_0060D(vn_indice).first,-1);
      --
      loop
         --
         if nvl(vn_indice_bi,-1) = -1 then
            exit;
         end if;
         --
         vn_indice_tri := nvl(vt_tri_tab_reg_0060D(vn_indice)(vn_indice_bi).first,-1);
         --
         loop
            --
            if nvl(vn_indice_tri,-1) = -1 then
               exit;
            end if;
            --
            vn_qtde := nvl(vn_qtde,0) + 1;
            --
            if vn_indice_tri = vt_tri_tab_reg_0060D(vn_indice)(vn_indice_bi).last then
               exit;
            else
               vn_indice_tri := vt_tri_tab_reg_0060D(vn_indice)(vn_indice_bi).next(vn_indice_tri);
            end if;
            --
         end loop;
         --
         if vn_indice_bi = vt_tri_tab_reg_0060D(vn_indice).last then
            exit;
         else
            vn_indice_bi := vt_tri_tab_reg_0060D(vn_indice).next(vn_indice_bi);
         end if;
         --
      end loop;
      --
      if vn_indice = vt_tri_tab_reg_0060D.last then
         exit;
      else
         vn_indice := vt_tri_tab_reg_0060D.next(vn_indice);
      end if;
      --
   end loop;
   --
   return nvl(vn_qtde,0);
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0060d;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0060I
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0060i RETURN NUMBER IS
   --
   vn_qtde       number := 0;
   vn_indice     pls_integer := 0;
   vn_indice_bi  pls_integer := 0;
   --
BEGIN
   --
   vn_indice := nvl(vt_bi_tab_reg_0060I.first,0);
   vn_qtde := 0;
   --
   loop
      --
      if nvl(vn_indice,-1) = -1 then
         exit;
      end if;
      --
      vn_indice_bi := nvl(vt_bi_tab_reg_0060I(vn_indice).first,0);
      --
      loop
         --
         if nvl(vn_indice_bi,-1) = -1 then
            exit;
         end if;
         --
         vn_qtde := nvl(vn_qtde,0) + 1;
         --
         if vn_indice_bi = vt_bi_tab_reg_0060I(vn_indice).last then
            exit;
         else
            vn_indice_bi := vt_bi_tab_reg_0060I(vn_indice).next(vn_indice_bi);
         end if;
         --
      end loop;
      --
      if vn_indice = vt_bi_tab_reg_0060I.last then
         exit;
      else
         vn_indice := vt_bi_tab_reg_0060I.next(vn_indice);
      end if;
      --
   end loop;
   --
   return nvl(vn_qtde,0);
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0060i;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0060R
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0060r RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0060R.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0060r;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0061
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0061 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0061.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0061;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0061R
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0061r RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0061R.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0061r;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0070
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0070 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0070.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0070;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0071
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0071 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0071.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0071;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0074
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0074 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0074.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0074;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0075
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0075 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0075.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0075;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0076
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0076 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0076.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0076;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0077
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0077 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0077.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0077;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0085
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0085 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0085.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0085;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0086
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0086 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0086.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0086;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0088
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0088 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0088_01.count,0)
              + nvl(vt_tab_reg_0088_02.count,0)
              + nvl(vt_tab_reg_0088_cf.count,0)
              + nvl(vt_tab_reg_0088_it.count,0)
              + nvl(vt_tab_reg_0088_sme.count,0)
              + nvl(vt_tab_reg_0088_sms.count,0)
              + nvl(vt_tab_reg_0088_ec.count,0)
              + nvl(vt_tab_reg_0088_sf.count,0);
   --
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0088;

-------------------------------------------------------------------------------------------------------
-- Função retorna a quantidade de linhas do registro 0090
-------------------------------------------------------------------------------------------------------
FUNCTION FKG_QTDE_LINHA_REG_0090 RETURN NUMBER IS
   --
   vn_qtde  number := 0;
   --
BEGIN
   --
   vn_qtde := nvl(vt_tab_reg_0090.count,0);
   return vn_qtde;
   --
EXCEPTION
   when others then
      return 0;
END FKG_QTDE_LINHA_REG_0090;

----------------------------------------------------------------------------------
-- Inicia dados
----------------------------------------------------------------------------------
PROCEDURE PKB_INICIA_DADOS IS
BEGIN
   --
   vt_tab_reg_0010.delete;
   vt_tab_reg_0011.delete;
   vt_tri_tab_reg_0050.delete;
   vt_tab_reg_0051.delete;
   vt_tab_reg_0053.delete;
   vt_tab_reg_0054.delete;
   vt_tab_reg_0055.delete;
   vt_tab_reg_0056.delete;
   vt_tab_reg_0057.delete;
   vt_tab_reg_0060M.delete;
   vt_bi_tab_reg_0060A.delete;
   vt_tri_tab_reg_0060D.delete;
   vt_bi_tab_reg_0060I.delete;
   vt_tab_reg_0060R.delete;
   vt_tab_reg_0061.delete;
   vt_tab_reg_0061R.delete;
   vt_tab_reg_0070.delete;
   vt_tab_reg_0071.delete;
   vt_tab_reg_0074.delete;
   vt_tab_reg_0075.delete;
   vt_tab_reg_0076.delete;
   vt_tab_reg_0077.delete;
   vt_tab_reg_0085.delete;
   vt_tab_reg_0086.delete;
   --
   vt_tab_reg_0088_01.delete;
   vt_tab_reg_0088_02.delete;
   vt_tab_reg_0088_cf.delete;
   vt_tab_reg_0088_it.delete;
   vt_tab_reg_0088_sme.delete;
   vt_tab_reg_0088_sms.delete;
   vt_tab_reg_0088_ec.delete;
   vt_tab_reg_0088_sf.delete;
   --
   vt_tab_reg_0090.delete;
   --
   vt_estr_arq_sintegra.delete;
   --
END PKB_INICIA_DADOS;

----------------------------------------------------------------------------------
-- Procedimento inicia os valores das váriaveis globais
----------------------------------------------------------------------------------
PROCEDURE PKB_INICIA_PARAM ( EN_ABERTURASINT_ID IN ABERTURA_SINTEGRA.ID%TYPE ) IS
   --
   vn_fase  number := 0;
   --
BEGIN
   --
   vn_fase := 1;
   gt_row_abertura_sint := null;
   vn_fase := 2;
   --
   select sint.*
     into gt_row_abertura_sint
     from abertura_sintegra sint
    where sint.id = en_aberturasint_id;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_inicia_param fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => en_aberturasint_id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_INICIA_PARAM;

-------------------------------------------------------------------------------------------------------
-- Excluir os registros anteriores
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_EXCLUIR_ARQ_SINT IS
   --
   vn_fase  number := 0;
   --
BEGIN
   --
   vn_fase := 1;
   --
   delete from estr_arq_sintegra
    where aberturasintegra_id = gt_row_abertura_sint.id;
   --
   vn_fase := 2;
   --
   commit;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_excluir_arq_sint fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_EXCLUIR_ARQ_SINT;

-------------------------------------------------------------------------------------------------------
-- procedimento alimenta os arrays do SINTEGRA
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_ARRAY_SINT IS
   --
   vn_fase  number := 0;
   --
BEGIN
   --
   vn_fase := 1;
   pkb_monta_reg_0010;
   --
   vn_fase := 2;
   pkb_monta_reg_0011;
   --
   vn_fase := 3;
   pkb_monta_reg_0050;
   --
   vn_fase := 4;
   pkb_monta_reg_0051;
    --
   vn_fase := 5;
   pkb_monta_reg_0053;
   --
   vn_fase := 6;
   pkb_monta_reg_0054;
   --
   vn_fase := 7;
   pkb_monta_reg_0056;
   --
   vn_fase := 8;
   pkb_monta_reg_0057;
   --
   vn_fase := 9;
   pkb_monta_reg_0060M;
   --
   vn_fase := 10;
   pkb_monta_reg_0060A;
   --
   vn_fase := 11;
   pkb_monta_reg_0060D;
   --
   vn_fase := 12;
   pkb_monta_reg_0060I;
   --
   vn_fase := 13;
   pkb_monta_reg_0060R;
   --
   vn_fase := 14;
   pkb_monta_reg_0070;
   --
   vn_fase := 15;
   pkb_monta_reg_0074;
   --
   vn_fase := 16;
   pkb_monta_reg_0076;
   --
   vn_fase := 17;
   pkb_monta_reg_0085;
   --
   vn_fase := 18;
   pkb_monta_reg_0086;
   --
   vn_fase := 19;
   pkb_monta_reg_0088_sme;
   --
   vn_fase := 20;
   pkb_monta_reg_0088_sms;
   --
   vn_fase := 21;
   pkb_monta_reg_0088_ec;
   --
   vn_fase := 22;
   pkb_monta_reg_0088_sf;
   --
   vn_fase := 23;
   pkb_monta_reg_0090;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_array_sint fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_ARRAY_SINT;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0010: CABECALHO
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0010 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
   cursor c_sint is
      select '10'                                 tipo
           , nvl(lpad(jur.num_cnpj,8,0) ||lpad(jur.num_filial,4,0) || lpad(jur.dig_cnpj,2, 0) , 0)  cnpj
           , nvl(jur.ie,'ISENTO')                 ie
           , nvl(est.sigla_estado,' ')            uf
           , pes.nome                             nome_contrib
           , cid.descr                            nome_mun
           , pes.fax                              fax
           , gt_row_abertura_sint.dt_ini          dt_ini
           , gt_row_abertura_sint.dt_fin          dt_fin
           , gt_row_abertura_sint.dm_ident_conv   dm_ident_conv
           , gt_row_abertura_sint.dm_ident_nat    dm_ident_nat
           , gt_row_abertura_sint.dm_fin_arq      dm_fin_arq
        from empresa  emp
           , pessoa   pes
           , cidade   cid
           , estado   est
           , juridica jur
       where emp.id        = gt_row_abertura_sint.empresa_id
         and emp.pessoa_id = pes.id
         and pes.id        = jur.pessoa_id
         and pes.cidade_id = cid.id
         and cid.estado_id = est.id;
   --
BEGIN
   --
   vn_fase := 1;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 3;
      --
      vt_tab_reg_0010(i).tipo          := rec.tipo;
      vt_tab_reg_0010(i).cnpj          := nvl(substr(rec.cnpj,1,14),' ');
      vt_tab_reg_0010(i).ie            := nvl(substr(trim(rec.ie),1,14),' ');
      vt_tab_reg_0010(i).nome_contrib  := nvl(substr(rec.nome_contrib,1,35),' ');
      vt_tab_reg_0010(i).nome_mun      := nvl(substr(rec.nome_mun,1,30),' ');
      vt_tab_reg_0010(i).uf            := nvl(substr(rec.uf,1,02),' ');
      vt_tab_reg_0010(i).fax           := nvl(substr(rec.fax,1,10), 0 );
      vt_tab_reg_0010(i).dt_ini        := lpad(to_number(to_char(rec.dt_ini,'rrrrmmdd')),8,0);
      vt_tab_reg_0010(i).dt_fin        := lpad(to_number(to_char(rec.dt_fin,'rrrrmmdd')),8,0);
      vt_tab_reg_0010(i).dm_ident_conv := nvl(substr(rec.dm_ident_conv,1,01),' ');
      vt_tab_reg_0010(i).dm_ident_nat  := nvl(substr(rec.dm_ident_nat,1,01),' ');
      vt_tab_reg_0010(i).dm_fin_arq    := nvl(substr(rec.dm_fin_arq,1,01),' ');
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0010;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0011: IDENTIFICACAO DA EMPRESA
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0011 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
   cursor c_sint is
   select '11'         tipo
         , pes.lograd  logradouro
         , pes.nro     numero
         , pes.compl   complemento
         , pes.bairro  bairro
         , pes.cep     cep
         , pes.nome    nome_contato
         , pes.fone    telefone
     from  empresa emp
         , pessoa  pes
    where  emp.id        = gt_row_abertura_sint.empresa_id
      and  emp.pessoa_id = pes.id;
   --
BEGIN
   --
   vn_fase := 1;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 3;
      --
      vt_tab_reg_0011(i).tipo       := rec.tipo;
      vt_tab_reg_0011(i).logradouro := nvl(substr(rec.logradouro,1,34),' ');
      --
      vn_fase := 4;
      --
      if pk_csf.fkg_is_numerico(rec.numero) then
         vt_tab_reg_0011(i).numero := nvl(substr(rec.numero,1,05),0);
      else
         vt_tab_reg_0011(i).numero := 1;
      end if;
      --
      vn_fase := 5;
      --
      vt_tab_reg_0011(i).complemento  := nvl(substr(rec.complemento,1,22),' ');
      vt_tab_reg_0011(i).bairro       := nvl(substr(rec.bairro,1,05),' ');
      vt_tab_reg_0011(i).cep          := nvl(to_number(substr(replace(replace(replace(rec.cep, ' ', ''),'.',''),'-',''),1,08)),0);
      --
      --vt_tab_reg_0011(i).nome_contato := nvl(substr(rec.nome_contato,1,28),' ');
      -- recupera dados do contador
      begin
         --
         select substr(pe.nome, 1, 28)
           into vt_tab_reg_0011(i).nome_contato
           from pessoa pe
              , contador co
              , contador_empresa ce
          where ce.empresa_id  = gt_row_abertura_sint.empresa_id
            and ce.dm_situacao = 1 -- 0-inativo, 1-ativo
            and co.id          = ce.contador_id
            and pe.id          = co.pessoa_id
            and rownum         = 1;
         --
      exception
         when others then
            vt_tab_reg_0011(i).nome_contato     := ' ';
      end;
      --
      vt_tab_reg_0011(i).telefone     := nvl(substr(replace(replace(replace(replace(replace(rec.telefone, ' ', ''), '-', ''), ')', ''), '(', ''), '.', ''),1,12),0);
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0011 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0011;

---------------------------------------------------------------------
--| Procedimento para popular as tabelas temporárias --#75073
---------------------------------------------------------------------
procedure PKB_INSERT_TABELA_TMP is
--
vn_fase  number := 0;
--
begin
    --
    vn_fase := 1;
    --
    -- insere registro 0050
    begin
     insert /*+ append */
      into csf_own.tmp_sintegra_reg_0050
        (select csf_own.tmpsintegrareg0050_seq.nextval  id
               , (case when nf.dm_ind_emit = 1 then
                           trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                      when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                           trunc(nf.dt_emiss)
                      when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 then
                           trunc(nf.dt_emiss)
                      when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                           trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                      else
                           trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                 end) dt_emis_receb
               , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                       when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
                  end) numero
               , replace(nf.serie, '*', '')     serie
               , mf.cod_mod                     modelo
               , nvl(inf.id, 0)                 itemnf_id -- #73294
               , decode( sdc.cd ,'00' , 'N'
                                ,'01' , 'E'
                                ,'02' , 'S'
                                ,'03' , 'X'
                                ,'04' , '2'
                                ,'05' , '4'
                                , 'N'
                                   ) situacao
               , decode(nf.dm_ind_emit, 0, 'P',
                                        1, 'T') emitente
               , nvl(nf.pessoa_id, 0)           pessoa_id -- #73294
               , nvl(inf.cfop, 0)               cfop      -- #73294
               , nf.id                          notafiscal_id
               , nf.dm_ind_oper
               , cid.estado_id                  estado_id
               , nf.dm_st_proc
            from nota_fiscal       nf
               , mod_fiscal        mf
               , item_nota_fiscal  inf
               , sit_docto         sdc
               , pessoa            p
               , cidade            cid
           where nf.empresa_id      = gt_row_abertura_sint.empresa_id
             and nf.dm_st_proc     in (4,7,8) -- Autorizada/cancelada/inutilizada
             and nf.dm_arm_nfe_terc = 0
             and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
                   or
                  (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
                   or
                  (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
                   or
                  (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
             and mf.id              = nf.modfiscal_id
             and mf.cod_mod        in ('01', '04', '55', '65', '06', '21', '22') -- NF, NF Produtor Rural, NFe, NF Energia Elétrica, NF Serv.Comun., NF Serv.Telecomun.
             and nf.sitdocto_id     = sdc.id
             and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
             and inf.notafiscal_id (+)  = nf.id        -- #73294
             and p.id              (+)  = nf.pessoa_id -- #73294
             and cid.id            (+)  = p.cidade_id  -- #73294
             and (cid.estado_id         = nvl(null, cid.estado_id)
                  or (cid.estado_id     is null
                      and nf.dm_st_proc = 8))          -- #73294
         );
    end;
    --
    COMMIT;
    --
    vn_fase := 2;
    --
    -- insere registro 0074
    begin
     insert /*+ append */
      into csf_own.tmp_sintegra_reg_0074
        (select csf_own.tmpsintegrareg0074_seq.nextval  id
               , tipo
               , data_inventario
               , cod_prod
               , cod_posse_merc_invent
               , pessoa_id
               , item_id
               , quantidade
               , valor_prod
               , empresa_id
        from (select  '74'                          tipo
                     , inv.dt_inventario            data_inventario
                     , substr(ite.cod_item,1,14)    cod_prod
                     , decode(inv.dm_ind_prop, 0, 1
                                 , 1, 2
                                 , 2, 3
                                 , 1 )              cod_posse_merc_invent
                     , inv.pessoa_id                pessoa_id
                     , inv.item_id                  item_id
                     , sum(inv.qtde)                quantidade
                     , sum(nvl(inv.vl_item,0))      valor_prod
                     , inv.empresa_id               empresa_id
                  from inventario inv
                     , item       ite
                   where inv.empresa_id                 = gt_row_abertura_sint.empresa_id
                   and trunc(inv.dt_inventario) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)
                   and inv.item_id                      = ite.id
                   group by
                      '74'
                     , inv.dt_inventario
                     , substr(ite.cod_item,1,14)
                     , decode(inv.dm_ind_prop, 0, 1
                                 , 1, 2
                                 , 2, 3
                                 , 1 )
                     , inv.pessoa_id
                     , inv.item_id
					 , inv.empresa_id      
                      )
                );
    end;
    --
    COMMIT;
    --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.PKB_INSERT_TABELA_TMP fase('||vn_fase||'): '||sqlerrm;

      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                           , ev_mensagem        => pk_log_generico.gv_mensagem
                                           , ev_resumo          => 'Erro ao gerar as tabelas temporarias do registro 0050 e 0074'
                                           , en_tipo_log        => pk_log_generico.erro_de_sistema
                                           , en_referencia_id   => gt_row_abertura_sint.id
                                           , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_INSERT_TABELA_TMP;

-----------------------------------------------------------------------------------------
-- Montar o registro 0050
-----------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0050 IS
   --
   vn_fase                    number := 0;
   vb_achou                   boolean;
   i                          pls_integer;
   v_dt_emissao               number;
   v_modelo                   mod_fiscal.cod_mod%type;
   v_serie                    nota_fiscal.serie%type;
   v_numero                   nota_fiscal.nro_nf%type;
   v_emitente                 varchar2(01);
   v_situacao                 varchar2(01);
   v_cnpj                     varchar2(14);
   v_ie                       varchar2(14);
   v_uf                       varchar2(02);
   v_cfop                     number(04);
   v_valor_total              number(15,2);
   v_base_calculo_icms        number(15,2);
   v_valor_icms               number(15,2);
   v_isenta_nao_tributada     number(15,2);
   v_outras                   number(15,2);
   v_aliquota                 number;
   -- valores nao usados neste registro
   v_cod_st_icms              number;
   v_vl_base_calc_icmsst      number;
   v_vl_imp_trib_icmsst       number;
   v_cod_st_ipi               number;
   v_vl_base_calc_ipi         number;
   v_aliq_ipi                 number;
   v_vl_imp_trib_ipi          number;
   v_vl_bc_isenta_ipi         number;
   v_vl_bc_outra_ipi          number;
   v_ipi_nao_recup            number;
   v_outro_ipi                number;
   vn_vl_imp_nao_dest_ipi     number;
   vn_vl_fcp_icmsst           number;
   vn_aliq_fcp_icms           number;
   vn_vl_fcp_icms             number;
   -- somatorias
   vn_notafiscal_id_old       nota_fiscal.id%type;
   --#75073
   vv_estado                  estado.sigla_estado%type;
   vv_resumo                  varchar2(4000);
   --
   --#75073 alteracao do cursor para ler a tmp
 /*  cursor c_sint is
    select (case when nf.dm_ind_emit = 1 then
                     trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                     trunc(nf.dt_emiss)
                when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 then
                     trunc(nf.dt_emiss)
                when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                     trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                else
                     trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
           end) dt_emis_receb
         , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                 when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
            end) numero
         , replace(nf.serie, '*', '')     serie
         , mf.cod_mod                     modelo
         , nvl(inf.id, 0)                 itemnf_id -- #73294
         , decode( sdc.cd ,'00' , 'N'
                          ,'01' , 'E'
                          ,'02' , 'S'
                          ,'03' , 'X'
                          ,'04' , '2'
                          ,'05' , '4'
                          , 'N'
                             ) situacao
         , decode(nf.dm_ind_emit, 0, 'P',
                                  1, 'T') emitente
         , nvl(nf.pessoa_id, 0)           pessoa_id -- #73294
         , nvl(inf.cfop, 0)               cfop      -- #73294
         , nf.id                          notafiscal_id
         , nf.dm_ind_oper
      from nota_fiscal       nf
         , mod_fiscal        mf
         , item_nota_fiscal  inf
         , sit_docto         sdc
         , pessoa            p
         , cidade            cid
     where nf.empresa_id      = gt_row_abertura_sint.empresa_id
       and nf.dm_st_proc     in (4,7,8) -- Autorizada/cancelada/inutilizada
       and nf.dm_arm_nfe_terc = 0
       and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
             or
            (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
       and mf.id              = nf.modfiscal_id
       and mf.cod_mod        in ('01', '04', '55', '65', '06', '21', '22') -- NF, NF Produtor Rural, NFe, NF Energia Elétrica, NF Serv.Comun., NF Serv.Telecomun.
       and nf.sitdocto_id     = sdc.id
       and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
       and inf.notafiscal_id (+)  = nf.id        -- #73294
       and p.id              (+)  = nf.pessoa_id -- #73294
       and cid.id            (+)  = p.cidade_id  -- #73294
       and (cid.estado_id         = nvl(gn_estado_id, cid.estado_id)
            or (cid.estado_id     is null
                and nf.dm_st_proc = 8))          -- #73294

                ;
  */ --
   --
   cursor c_sint is
    select  dt_emis_receb
          , numero
          , serie
          , modelo
          , itemnf_id
          , situacao
          , emitente
          , pessoa_id
          , cfop
          , notafiscal_id
          , dm_ind_oper
          , estado_id
          , dm_st_proc
      from csf_own.tmp_sintegra_reg_0050 a
     where a.estado_id     = nvl(gn_estado_id,a.estado_id)
     order by dt_emis_receb, modelo, serie, numero, cfop;
   --
   cursor c_det_cfop_sc is
   select (case when nf.dm_ind_emit = 1 then
                     trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                     trunc(nf.dt_emiss)
                when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 then
                     trunc(nf.dt_emiss)
                when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                     trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                else
                     trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
           end) dt_emis_receb
        , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
            end) numero
        , replace(nf.serie, '*', '')     serie
        , mf.cod_mod                     modelo
        , nf.id       notafiscal_id
        , decode( sdc.cd ,'00' , 'N'
                         ,'01' , 'E'
                         ,'02' , 'S'
                         ,'03' , 'X'
                         ,'04' , '2'
                         ,'05' , '4'
                         , 'N'
                         ) situacao
        , decode(nf.dm_ind_emit, 0, 'P',
                                 1, 'T') emitente
        , nf.pessoa_id
        , r.id               nfregistanalit_id
        , nf.dm_ind_oper
     from nota_fiscal     nf
        , mod_fiscal      mf
        , nfregist_analit r
        , sit_docto       sdc
        , pessoa            p
        , cidade            cid
    where nf.empresa_id      = gt_row_abertura_sint.empresa_id
      and nf.dm_st_proc      = 4
      and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
            or
           (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
      and nf.dm_arm_nfe_terc = 0
      and mf.id              = nf.modfiscal_id
      and mf.cod_mod        in ('06', '21', '22')
      and r.notafiscal_id    = nf.id
      and nf.sitdocto_id     = sdc.id
      and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
      and p.id               = nf.pessoa_id
      and cid.id             = p.cidade_id
      and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
    order by 1, mf.cod_mod, nf.serie, nf.nro_nf;
   --
BEGIN
   --
   vn_fase := 1;
   --
   vb_achou                   := false;
   v_cnpj                     := null;
   v_ie                       := null;
   v_uf                       := null;
   v_cfop                     := 0;
   v_valor_total              := 0;
   v_base_calculo_icms        := 0;
   v_valor_icms               := 0;
   v_isenta_nao_tributada     := 0;
   v_outras                   := 0;
   v_aliquota                 := 0;
   -- valores nao usados neste registro
   v_cod_st_icms              := 0;
   v_vl_base_calc_icmsst      := 0;
   v_vl_imp_trib_icmsst       := 0;
   v_cod_st_ipi               := 0;
   v_vl_base_calc_ipi         := 0;
   v_aliq_ipi                 := 0;
   v_vl_imp_trib_ipi          := 0;
   v_vl_bc_isenta_ipi         := 0;
   v_vl_bc_outra_ipi          := 0;
   v_ipi_nao_recup            := 0;
   v_outro_ipi                := 0;
   --
   i := 0;
   vn_notafiscal_id_old := 0;
   --
   vv_resumo := null ;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      if nvl(vn_notafiscal_id_old,0) <> nvl(rec.notafiscal_id,0) then
         i := i + 1;
         vn_notafiscal_id_old := rec.notafiscal_id;
      end if;
      --
      vn_fase := 2;
      --
      if rec.dm_ind_oper = 0 then
         gn_qtde_ent := nvl(gn_qtde_ent,0) + 1;
      else
         gn_qtde_sai := nvl(gn_qtde_sai,0) + 1;
      end if;
      --
      vn_fase := 3;
      -- Grava as variaveis do cursor
      v_dt_emissao := lpad(to_number(to_char(rec.dt_emis_receb,'rrrrmmdd')),8,0);
      v_modelo     := rec.modelo;
      v_serie      := nvl(trim(rec.serie), '0');
      --
      vn_fase := 4;
      --
      if not pk_csf.fkg_is_numerico(v_serie) then
         v_serie := ' ';
      end if;
      --
      vn_fase := 5;
      --
      v_numero   := rec.numero;
      v_emitente := rec.emitente;
      v_situacao := rec.situacao;
      --
      vn_fase := 6;
      --
      if rpad(trim(v_serie), 3, '0') = '000' then
         v_serie := ' ';
      end if;
      --
      vn_fase := 7;
      -- Busca cnpj, ie e uf
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 8;
      -- #75073 validacao se item esta preenchido antes de chamar a api
      if rec.itemnf_id > 0 then
        --
        -- Busca valores do item na package
        pk_csf_api.pkb_vlr_fiscal_item_nf( en_itemnf_id           => rec.itemnf_id
                                         , sn_cfop                => v_cfop
                                         , sn_vl_operacao         => v_valor_total
                                         , sv_cod_st_icms         => v_cod_st_icms           -- nao utilizado
                                         , sn_vl_base_calc_icms   => v_base_calculo_icms
                                         , sn_aliq_icms           => v_aliquota
                                         , sn_vl_imp_trib_icms    => v_valor_icms
                                         , sn_vl_base_calc_icmsst => v_vl_base_calc_icmsst   -- nao utilizado
                                         , sn_vl_imp_trib_icmsst  => v_vl_imp_trib_icmsst    -- nao utilizado
                                         , sn_vl_bc_isenta_icms   => v_isenta_nao_tributada
                                         , sn_vl_bc_outra_icms    => v_outras
                                         , sv_cod_st_ipi          => v_cod_st_ipi             -- nao utilizado
                                         , sn_vl_base_calc_ipi    => v_vl_base_calc_ipi       -- nao utilizado
                                         , sn_aliq_ipi            => v_aliq_ipi               -- nao utilizado
                                         , sn_vl_imp_trib_ipi     => v_vl_imp_trib_ipi        -- nao utilizado
                                         , sn_vl_bc_isenta_ipi    => v_vl_bc_isenta_ipi       -- nao utilizado
                                         , sn_vl_bc_outra_ipi     => v_vl_bc_outra_ipi        -- nao utilizado
                                         , sn_ipi_nao_recup       => v_ipi_nao_recup          -- nao utilizado
                                         , sn_outro_ipi           => v_outro_ipi
                                         , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi
                                         , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                         , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                         , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                         );           -- nao utilizado
      end if;
      --
      vn_fase := 9;
      --
      v_aliquota := nvl(v_aliquota,0);
      --
      vn_fase := 10;
      --
      begin
         --
         vb_achou := vt_tri_tab_reg_0050(i)(rec.cfop).exists(v_aliquota);
         --
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 11;
      --
      if vb_achou then
         vn_fase := 11.1;
         -- Atualiza dados
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).valor_total          := nvl(vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).valor_total,0) + nvl(to_number(replace(replace(to_char( nvl(v_valor_total,0)       , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).base_calculo_icms    := nvl(vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).base_calculo_icms,0) + nvl(to_number(replace(replace(to_char( nvl(v_base_calculo_icms,0)    , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).valor_icms           := nvl(vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).valor_icms,0) + nvl(to_number(replace(replace(to_char( nvl(v_valor_icms,0)          , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).isenta_nao_tributada := nvl(vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).isenta_nao_tributada,0) + nvl(to_number(replace(replace(to_char( nvl(v_isenta_nao_tributada,0)  , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).outras               := nvl(vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).outras,0) + nvl(to_number(replace(replace(to_char( nvl(v_outras,0)           , '9999999999990D99'),',',''),'.','')),0);
         --
      else
         vn_fase := 11.2;
         -- cria dados
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).tipo                 := '50';
         vn_fase := 11.21;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).cnpj                 := nvl(v_cnpj,'0');
         vn_fase := 11.22;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).ie                   := v_ie;
         vn_fase := 11.23;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).dt_emis_receb        := v_dt_emissao;
         vn_fase := 11.24;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).uf                   := v_uf;
         vn_fase := 11.25;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).modelo               := v_modelo;
         vn_fase := 11.26;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).serie                := v_serie;
         vn_fase := 11.3;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).numero               := v_numero;
         vn_fase := 11.31;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).cfop                 := v_cfop;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).emitente             := v_emitente;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).valor_total          := nvl(to_number(replace(replace(to_char( nvl(v_valor_total,0)       , '9999999999990D99'),',',''),'.','')),0);
         vn_fase := 11.3;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).base_calculo_icms    := nvl(to_number(replace(replace(to_char( nvl(v_base_calculo_icms,0)    , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).valor_icms           := nvl(to_number(replace(replace(to_char( nvl(v_valor_icms,0)          , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).isenta_nao_tributada := nvl(to_number(replace(replace(to_char( nvl(v_isenta_nao_tributada,0)  , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).outras               := nvl(to_number(replace(replace(to_char( nvl(v_outras,0)           , '9999999999990D99'),',',''),'.','')),0);
         vn_fase := 11.5;
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).aliquota             := nvl(to_number(replace(replace(to_char( nvl(v_aliquota ,0)            , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(rec.cfop)(v_aliquota).situacao             := v_situacao;
         --
      end if;
      --
   end loop;
   --
   vn_fase := 12;
   -- Serviços continuos
   for rec in c_det_cfop_sc
   loop
      --
      exit when c_det_cfop_sc%notfound or (c_det_cfop_sc%notfound) is null;
      --
      if nvl(vn_notafiscal_id_old,0) <> nvl(rec.notafiscal_id,0) then
         i := i + 1;
         vn_notafiscal_id_old := rec.notafiscal_id;
      end if;

      vn_fase := 13;
      --
      if rec.dm_ind_oper = 0 then
         gn_qtde_ent := nvl(gn_qtde_ent,0) + 1;
      else
         gn_qtde_sai := nvl(gn_qtde_sai,0) + 1;
      end if;
      --
      vn_fase := 14;
      -- Grava as variaveis do cursor
      v_dt_emissao := lpad(to_number(to_char(rec.dt_emis_receb,'rrrrmmdd')),8,0);
      v_modelo     := rec.modelo;
      v_serie      := nvl(trim(rec.serie), '0');
      --
      vn_fase := 15;
      --
      if not pk_csf.fkg_is_numerico(v_serie) then
         v_serie := ' ';
      end if;
      --
      vn_fase := 16;
      --
      v_numero   := rec.numero;
      v_emitente := rec.emitente;
      v_situacao := rec.situacao;
      --
      vn_fase := 17;
      --
      if rpad(trim(v_serie), 3, '0') = '000' then
         v_serie := ' ';
      end if;
      --
      vn_fase := 18;
      -- Busca cnpj, ie e uf
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 19;
      -- #75073 validacao se item esta preenchido antes de chamar a api
      if nvl(rec.nfregistanalit_id,0) > 0 then
        --
        -- Busca valores do item na package
        -- Recupera valores fiscais (ICMS/ICMS-ST/IPI) de uma nota fiscal de serviço continuo
        pk_csf_api.pkb_vlr_fiscal_nfsc ( en_nfregistanalit_id => rec.nfregistanalit_id
                                       , sv_cod_st_icms       => v_cod_st_icms
                                       , sn_cfop              => v_cfop
                                       , sn_aliq_icms         => v_aliquota
                                       , sn_vl_operacao       => v_valor_total
                                       , sn_vl_bc_icms        => v_base_calculo_icms
                                       , sn_vl_icms           => v_valor_icms
                                       , sn_vl_bc_icmsst      => v_vl_base_calc_icmsst
                                       , sn_vl_icms_st        => v_vl_imp_trib_icmsst
                                       , sn_vl_ipi            => v_vl_imp_trib_ipi
                                       , sn_vl_bc_isenta_icms => v_isenta_nao_tributada
                                       , sn_vl_bc_outra_icms  => v_outras );
        --
      end if;
      --
      vn_fase := 20;
      --
      v_aliquota := nvl(v_aliquota,0);
      --
      vn_fase := 21;
      --
      begin
         --
         vb_achou := vt_tri_tab_reg_0050(i)(v_cfop).exists(v_aliquota);
         --
      exception
         when others then
            vb_achou := false;
      end;
      --
      vn_fase := 22;
      --
      if vb_achou then
         -- Atualiza dados
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).valor_total          := nvl(vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).valor_total,0) + nvl(to_number(replace(replace(to_char( nvl(v_valor_total,0)       , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).base_calculo_icms    := nvl(vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).base_calculo_icms,0) + nvl(to_number(replace(replace(to_char( nvl(v_base_calculo_icms,0)    , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).valor_icms           := nvl(vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).valor_icms,0) + nvl(to_number(replace(replace(to_char( nvl(v_valor_icms,0)          , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).isenta_nao_tributada := nvl(vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).isenta_nao_tributada,0) + nvl(to_number(replace(replace(to_char( nvl(v_isenta_nao_tributada,0)  , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).outras               := nvl(vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).outras,0) + nvl(to_number(replace(replace(to_char( nvl(v_outras,0)           , '9999999999990D99'),',',''),'.','')),0);
         --
      else
         -- cria dados
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).tipo                 := '50';
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).cnpj                 := nvl(v_cnpj,'0');
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).ie                   := v_ie;
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).dt_emis_receb        := v_dt_emissao;
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).uf                   := v_uf;
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).modelo               := v_modelo;
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).serie                := v_serie;
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).numero               := v_numero;
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).cfop                 := v_cfop;
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).emitente             := v_emitente;
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).valor_total          := nvl(to_number(replace(replace(to_char( nvl(v_valor_total,0)       , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).base_calculo_icms    := nvl(to_number(replace(replace(to_char( nvl(v_base_calculo_icms,0)    , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).valor_icms           := nvl(to_number(replace(replace(to_char( nvl(v_valor_icms,0)          , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).isenta_nao_tributada := nvl(to_number(replace(replace(to_char( nvl(v_isenta_nao_tributada,0)  , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).outras               := nvl(to_number(replace(replace(to_char( nvl(v_outras,0)           , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).aliquota             := nvl(to_number(replace(replace(to_char( nvl(v_aliquota ,0)            , '9999999999990D99'),',',''),'.','')),0);
         vt_tri_tab_reg_0050(i)(v_cfop)(v_aliquota).situacao             := v_situacao;
         --
      end if;
      --
   end loop;
   --
EXCEPTION
   when others then
      --#75073
      pk_log_generico.gv_mensagem := ' Erro na pkb_monta_reg_0050 fase('||vn_fase||'): '||sqlerrm;
      --
      if gn_estado_id is not null then
        vv_estado := pk_csf.fkg_Estado_id_sigla(gn_estado_id);
      end if ;
      --
      vv_resumo := 'Erro na geracao do arquivo sintegra. Objeto de banco : pk_gera_arq_sint.pkb_monta_reg_0050 fase('||vn_fase||'). Segue valores do registro com erro :'
                    || ' Estado = '|| vv_estado
                    || ' cnpj = '|| nvl(v_cnpj,'0')
                    || ' / ie = '|| v_ie
                    || ' / dt_emis_receb = '|| v_dt_emissao
                    || ' / uf = '|| v_uf
                    || ' / modelo = '|| v_modelo
                    || ' / serie = '|| v_serie
                    || ' / numero = '|| v_numero
                    || ' / cfop = '|| v_cfop
                    || ' / emitente = '|| v_emitente
                    || ' / valor_total = '|| nvl(to_number(replace(replace(to_char( nvl(v_valor_total,0) , '9999999999990D99'),',',''),'.','')),0)
                    || ' / base_calculo_icms = '|| nvl(to_number(replace(replace(to_char( nvl(v_base_calculo_icms,0), '9999999999990D99'),',',''),'.','')),0)
                    || ' / valor_icms = '|| nvl(to_number(replace(replace(to_char( nvl(v_valor_icms,0) , '9999999999990D99'),',',''),'.','')),0)
                    || ' / isenta_nao_tributada =  '|| nvl(to_number(replace(replace(to_char( nvl(v_isenta_nao_tributada,0)  , '9999999999990D99'),',',''),'.','')),0)
                    || ' / outras = '|| nvl(to_number(replace(replace(to_char( nvl(v_outras,0) , '9999999999990D99'),',',''),'.','')),0)
                    || ' / aliquota = '|| nvl(to_number(replace(replace(to_char( nvl(v_aliquota ,0) , '9999999999990D99'),',',''),'.','')),0)
                    || ' / situacao = '|| v_situacao
                    || ' . Verifique o valor dos campos ,sua obrigatoriedade e seus respctivos tamanhos no arquivo.'
                    ;
      --
      declare
         vn_loggenerico_id  log_generico.id%type;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => vv_resumo --null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      begin
       update abertura_sintegra
         set dm_situacao = 4 -- Erro na geração do arquivo
       where id = gt_row_abertura_sint.id;
       commit;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0050;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0051: DOCUMENTOS FISCAIS - IPI
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0051 IS
   --
   vn_fase                    number := 0;
   vv_existe                  varchar2(1) := 'N';
   i                          pls_integer;
   --
   v_dt_emissao               number;
   v_serie                    nota_fiscal.serie%type;
   v_numero                   nota_fiscal.nro_nf%type;
   v_situacao                 varchar2(01);
   v_cnpj                     varchar2(14);
   v_ie                       varchar2(14);
   v_uf                       varchar2(02);
   v_cfop                     number(04);
   v_existe_cfop              number(04);
   v_valor_total              number(15,2);
   v_vl_imp_trib_ipi          number(15,2);
   v_vl_bc_isenta_ipi         number(15,2);
   v_outro_ipi                number(15,2);
   vn_vl_imp_nao_dest_ipi     number;
   vn_vl_fcp_icmsst           number;
   vn_aliq_fcp_icms           number;
   vn_vl_fcp_icms             number;
   -- valores nao usados neste registro
   v_cod_st_icms              number;
   v_vl_base_calc_icmsst      number;
   v_vl_imp_trib_icmsst       number;
   v_cod_st_ipi               number;
   v_vl_base_calc_ipi         number;
   v_aliq_ipi                 number;
   v_ipi_nao_recup            number;
   v_base_calculo_icms        number;
   v_valor_icms               number;
   v_isenta_nao_tributada     number;
   v_vl_bc_outra_ipi          number;
   v_outras                   number;
   v_aliquota                 number;
   -- somatorias
   v_vl_valor_total           number(15,2);
   v_vl_tot_ipi               number(15,2);
   v_tot_outras               number(15,2);
   v_inicio                   varchar2(01);
   vn_notafiscal_id           nota_fiscal.id%type;
   --
   cursor c_sint is
      select (case when nf.dm_ind_emit = 1 then
                        trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                   when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                        trunc(nf.dt_emiss)
                   when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 then
                        trunc(nf.dt_emiss)
                   when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                        trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                   else
                        trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
              end) dt_emis_receb
           , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
              end) numero
           , replace(nf.serie, '*', '')     serie
           , inf.id                         itemnf_id
           , decode( sdc.cd ,'00' , 'N'
                            ,'01' , 'E'
                            ,'02' , 'S'
                            ,'03' , 'X'
                            ,'04' , '2'
                            ,'05' , '4'
                            , 'N'
                            ) situacao
           , nf.pessoa_id                   pessoa_id
           , decode(nf.dm_ind_emit, 0, 'P',
                                    1, 'T') emitente
           , inf.cfop                       cfop
           , nf.id notafiscal_id
        from nota_fiscal      nf
           , mod_fiscal       mf
           , item_nota_fiscal inf
           , sit_docto        sdc
           , pessoa            p
           , cidade            cid
       where nf.empresa_id      = gt_row_abertura_sint.empresa_id
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
         and nf.dm_st_proc     in (4,7,8) -- Autorizada/cancelada/inutilizada
         and nf.dm_arm_nfe_terc = 0
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '04', '55', '65', '06', '21', '22') -- NF, NF Produtor Rural, NFe, NF Energia Elétrica, NF Serv.Comun., NF Serv.Telecomun.
         and nf.sitdocto_id     = sdc.id
         and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
         and inf.notafiscal_id  = nf.id
         and p.id               = nf.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
    order by 1, mf.cod_mod, nf.serie, nf.nro_nf, inf.cfop;
   --
BEGIN
   --
   vn_fase := 1;
   --
   begin
      select 'S' -- Sim, existe parâmetro de que a empresa é contribuinte do IPI, portanto deve ser montado o registro 51
        into vv_existe
        from empresa           em
           , pessoa_tipo_param pt
           , tipo_param        tp
           , valor_tipo_param  vt
       where em.id           = gt_row_abertura_sint.empresa_id
         and pt.pessoa_id    = em.pessoa_id
         and tp.id           = pt.tipoparam_id
         and tp.cd           = 10 -- Indicador de tipo de atividade
         and vt.tipoparam_id = tp.id
         and vt.cd           = 0; -- Industrial ou equiparado a industrial
   exception
      when others then
         vv_existe := 'N'; -- Não existe parâmetro de que a empresa é contribuinte do IPI, portanto não deve ser montado o registro 51
   end;
   --
   if vv_existe = 'S' then -- Sim, existe parâmetro de que a empresa é contribuinte do IPI, portanto deve ser montado o registro 51
      --
      v_cnpj                := null;
      v_ie                  := null;
      v_uf                  := null;
      v_cfop                := 0;
      v_valor_total         := 0;
      v_vl_imp_trib_ipi     := 0;
      v_vl_bc_isenta_ipi    := 0;
      v_outro_ipi           := 0;
      -- valores nao usados neste registro
      v_cod_st_icms         := 0;
      v_vl_base_calc_icmsst := 0;
      v_vl_imp_trib_icmsst  := 0;
      v_base_calculo_icms   := 0;
      v_valor_icms          := 0;
      v_aliquota            := 0;
      v_cod_st_ipi          := 0;
      v_vl_base_calc_ipi    := 0;
      v_aliq_ipi            := 0;
      v_ipi_nao_recup       := 0;
      v_vl_bc_outra_ipi     := 0;
      -- somatorias
      v_vl_valor_total      := 0;
      v_vl_tot_ipi          := 0;
      v_tot_outras          := 0;
      v_inicio              := 'S';
      vn_notafiscal_id      := -1;
      v_existe_cfop         := 0;
      --
      i := 0;
      --
      for rec in c_sint
      loop
         --
         exit when c_sint%notfound or(c_sint%notfound) is null;
         --
         vn_fase := 2;
         --
         if vn_notafiscal_id <> rec.notafiscal_id then
            --
            vn_fase := 3;
            --
            if v_inicio = 'S' then
               --
               vn_fase := 4;
               -- Grava as variaveis do cursor
               v_dt_emissao := lpad(to_number(to_char(rec.dt_emis_receb,'rrrrmmdd')),8,0);
               v_serie      := nvl(trim(rec.serie), '0');
               --
               vn_fase := 5;
               --
               if not pk_csf.fkg_is_numerico(v_serie) then
                  v_serie := ' ';
               end if;
               --
               vn_fase := 6;
               --
               v_numero   := rec.numero;
               v_situacao := rec.situacao;
               --
               vn_fase := 7;
               --
               if rpad(v_serie, 3, '0') = '000' then
                  v_serie := ' ';
               end if;
               --
               vn_fase := 8;
               -- Busca cnpj, ie e uf
               pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                                     , sv_cpf_cnpj  => v_cnpj
                                     , sv_ie        => v_ie
                                     , sv_uf        => v_uf );
               --
               vn_fase := 9;
               -- Busca valores do item na package
               pk_csf_api.pkb_vlr_fiscal_item_nf( en_itemnf_id           => rec.itemnf_id
                                                , sn_cfop                => v_cfop
                                                , sn_vl_operacao         => v_valor_total
                                                , sv_cod_st_icms         => v_cod_st_icms           -- nao utilizado
                                                , sn_vl_base_calc_icms   => v_base_calculo_icms     -- nao utilizado
                                                , sn_aliq_icms           => v_aliquota              -- nao utilizado
                                                , sn_vl_imp_trib_icms    => v_valor_icms            -- nao utilizado
                                                , sn_vl_base_calc_icmsst => v_vl_base_calc_icmsst   -- nao utilizado
                                                , sn_vl_imp_trib_icmsst  => v_vl_imp_trib_icmsst    -- nao utilizado
                                                , sn_vl_bc_isenta_icms   => v_isenta_nao_tributada  -- nao utilizado
                                                , sn_vl_bc_outra_icms    => v_outras                -- nao utilizado
                                                , sv_cod_st_ipi          => v_cod_st_ipi            -- nao utilizado
                                                , sn_vl_base_calc_ipi    => v_vl_base_calc_ipi      -- nao utilizado
                                                , sn_aliq_ipi            => v_aliq_ipi              -- nao utilizado
                                                , sn_vl_imp_trib_ipi     => v_vl_imp_trib_ipi
                                                , sn_vl_bc_isenta_ipi    => v_vl_bc_isenta_ipi
                                                , sn_vl_bc_outra_ipi     => v_vl_bc_outra_ipi       -- nao utilizado
                                                , sn_ipi_nao_recup       => v_ipi_nao_recup         -- nao utilizado
                                                , sn_outro_ipi           => v_outro_ipi
                                                , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi
                                                , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                                , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                                , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                                );
               --
               vn_fase := 10;
               -- Armazena os valores
               v_vl_valor_total := nvl(v_vl_valor_total,0) + nvl(v_valor_total,0);
               v_vl_tot_ipi     := nvl(v_vl_tot_ipi,0)     + nvl(v_vl_imp_trib_ipi,0);
               v_tot_outras     := nvl(v_tot_outras,0)     + nvl(v_outro_ipi,0);
               --
               vn_fase := 11;
               -- Atualiza as variaveis
               v_existe_cfop    := rec.cfop;
               v_inicio         := 'N';
               vn_notafiscal_id := rec.notafiscal_id;
               --
            else
               --
               vn_fase := 12;
               -- Grava os valores anteriores
               i := nvl(i,0) + 1;
               --
               vt_tab_reg_0051(i).tipo          := '51';
               vt_tab_reg_0051(i).cnpj          := nvl(v_cnpj,'0');
               vt_tab_reg_0051(i).ie            := nvl(v_ie,' ');
               vt_tab_reg_0051(i).dt_emis_receb := v_dt_emissao;
               vt_tab_reg_0051(i).uf            := nvl(v_uf,' ');
               vt_tab_reg_0051(i).serie         := nvl(trim(v_serie),'0');
               --
               vn_fase := 13;
               --
               if rpad(vt_tab_reg_0051(i).serie, 3, '0') = '000' then
                  vt_tab_reg_0051(i).serie := ' ';
               end if;
               --
               vn_fase := 14;
               --
               vt_tab_reg_0051(i).numero              := nvl(v_numero,0);
               vt_tab_reg_0051(i).cfop                := v_cfop;
               vt_tab_reg_0051(i).valor_total         := nvl(to_number(replace(replace(to_char(v_vl_valor_total     , '9999999999990D99'),',',''),'.','')),0);
               vt_tab_reg_0051(i).valor_ipi           := nvl(to_number(replace(replace(to_char(v_vl_tot_ipi         , '9999999999990D99'),',',''),'.','')),0);
               vt_tab_reg_0051(i).isenta_nao_trib_ipi := nvl(to_number(replace(replace(to_char(v_vl_bc_isenta_ipi   , '9999999999990D99'),',',''),'.','')),0);
               vt_tab_reg_0051(i).outras_ipi          := nvl(to_number(replace(replace(to_char(v_tot_outras         , '9999999999990D99'),',',''),'.','')),0);
               vt_tab_reg_0051(i).brancos             := ' ';
               vt_tab_reg_0051(i).situacao            := v_situacao;
               --
               vn_fase := 15;
               -- Limpar variaveis
               v_vl_valor_total := 0;
               v_vl_tot_ipi     := 0;
               v_tot_outras     := 0;
               --
               vn_fase := 16;
               -- Grava as variaveis novas do cursor
               v_dt_emissao := lpad(to_number(to_char(rec.dt_emis_receb,'rrrrmmdd')),8,0);
               v_serie      := nvl(trim(rec.serie) ,'0');
               --
               vn_fase := 17;
               --
               if not pk_csf.fkg_is_numerico(v_serie) then
                  v_serie := ' ';
               end if;
               --
               vn_fase := 18;
               --
               v_numero   := rec.numero;
               v_situacao := rec.situacao;
               --
               vn_fase := 19;
               --
               if rpad(v_serie, 3, '0') = '000' then
                  v_serie := ' ';
               end if;
               --
               vn_fase := 20;
               -- Busca cnpj, ie e uf
               pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                                     , sv_cpf_cnpj  => v_cnpj
                                     , sv_ie        => v_ie
                                     , sv_uf        => v_uf );
               --
               vn_fase := 21;
               -- Busca valores do icms
               pk_csf_api.pkb_vlr_fiscal_item_nf( en_itemnf_id           => rec.itemnf_id
                                                , sn_cfop                => v_cfop
                                                , sn_vl_operacao         => v_valor_total
                                                , sv_cod_st_icms         => v_cod_st_icms           -- nao utilizado
                                                , sn_vl_base_calc_icms   => v_base_calculo_icms     -- nao utilizado
                                                , sn_aliq_icms           => v_aliquota              -- nao utilizado
                                                , sn_vl_imp_trib_icms    => v_valor_icms            -- nao utilizado
                                                , sn_vl_base_calc_icmsst => v_vl_base_calc_icmsst   -- nao utilizado
                                                , sn_vl_imp_trib_icmsst  => v_vl_imp_trib_icmsst    -- nao utilizado
                                                , sn_vl_bc_isenta_icms   => v_isenta_nao_tributada  -- nao utilizado
                                                , sn_vl_bc_outra_icms    => v_outras                -- nao utilizado
                                                , sv_cod_st_ipi          => v_cod_st_ipi            -- nao utilizado
                                                , sn_vl_base_calc_ipi    => v_vl_base_calc_ipi      -- nao utilizado
                                                , sn_aliq_ipi            => v_aliq_ipi              -- nao utilizado
                                                , sn_vl_imp_trib_ipi     => v_vl_imp_trib_ipi
                                                , sn_vl_bc_isenta_ipi    => v_vl_bc_isenta_ipi
                                                , sn_vl_bc_outra_ipi     => v_vl_bc_outra_ipi       -- nao utilizado
                                                , sn_ipi_nao_recup       => v_ipi_nao_recup         -- nao utilizado
                                                , sn_outro_ipi           => v_outro_ipi
                                                , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi
                                                , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                                , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                                , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                                );
               --
               vn_fase := 22;
               -- Armazena os valores
               v_vl_valor_total := nvl(v_vl_valor_total,0) + nvl(v_valor_total,0);
               v_vl_tot_ipi     := nvl(v_vl_tot_ipi,0)     + nvl(v_vl_imp_trib_ipi,0);
               v_tot_outras     := nvl(v_tot_outras,0)     + nvl(v_outro_ipi,0);
               --
               vn_fase := 23;
               -- Atualiza as variaveis
               v_existe_cfop    := rec.cfop;
               vn_notafiscal_id := rec.notafiscal_id;
               --
            end if;
            --
         else
            --
            vn_fase := 24;
            --
            if v_existe_cfop <> rec.cfop then
               --
               vn_fase := 25;
               -- Grava os valores anteriores
               i := nvl(i,0) + 1;
               --
               vt_tab_reg_0051(i).tipo          := '51';
               vt_tab_reg_0051(i).cnpj          := nvl(v_cnpj,'0');
               vt_tab_reg_0051(i).ie            := nvl(v_ie,' ');
               vt_tab_reg_0051(i).dt_emis_receb := v_dt_emissao;
               vt_tab_reg_0051(i).uf            := nvl(v_uf,' ');
               vt_tab_reg_0051(i).serie         := nvl(trim(v_serie),'0');
               --
               vn_fase := 26;
               --
               if rpad(vt_tab_reg_0051(i).serie, 3, '0') = '000' then
                  vt_tab_reg_0051(i).serie := ' ';
               end if;
               --
               vn_fase := 27;
               --
               vt_tab_reg_0051(i).numero              := nvl(v_numero,0);
               vt_tab_reg_0051(i).cfop                := v_cfop;
               vt_tab_reg_0051(i).valor_total         := nvl(to_number(replace(replace(to_char(v_vl_valor_total     , '9999999999990D99'),',',''),'.','')),0);
               vt_tab_reg_0051(i).valor_ipi           := nvl(to_number(replace(replace(to_char(v_vl_tot_ipi         , '9999999999990D99'),',',''),'.','')),0);
               vt_tab_reg_0051(i).isenta_nao_trib_ipi := nvl(to_number(replace(replace(to_char(v_vl_bc_isenta_ipi   , '9999999999990D99'),',',''),'.','')),0);
               vt_tab_reg_0051(i).outras_ipi          := nvl(to_number(replace(replace(to_char(v_tot_outras         , '9999999999990D99'),',',''),'.','')),0);
               vt_tab_reg_0051(i).brancos             := ' ';
               vt_tab_reg_0051(i).situacao            := v_situacao;
               --
               vn_fase := 28;
               -- Limpar variaveis
               v_vl_valor_total := 0;
               v_vl_tot_ipi     := 0;
               v_tot_outras     := 0;
               --
               vn_fase := 29;
               -- Grava as variaveis novas do cursor
               v_dt_emissao := lpad(to_number(to_char(rec.dt_emis_receb,'rrrrmmdd')),8,0);
               v_serie      := nvl(trim(rec.serie),'0');
               v_numero     := rec.numero;
               v_situacao   := rec.situacao;
               --
               vn_fase := 30;
               --
               if rpad(v_serie, 3, '0') = '000' then
                  v_serie := ' ';
               end if;
               --
               vn_fase := 31;
               -- Busca cnpj, ie e uf
               pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                                     , sv_cpf_cnpj  => v_cnpj
                                     , sv_ie        => v_ie
                                     , sv_uf        => v_uf );
               --
               vn_fase := 32;
               -- Busca valores do icms
               pk_csf_api.pkb_vlr_fiscal_item_nf( en_itemnf_id           => rec.itemnf_id
                                                , sn_cfop                => v_cfop
                                                , sn_vl_operacao         => v_valor_total
                                                , sv_cod_st_icms         => v_cod_st_icms           -- nao utilizado
                                                , sn_vl_base_calc_icms   => v_base_calculo_icms     -- nao utilizado
                                                , sn_aliq_icms           => v_aliquota              -- nao utilizado
                                                , sn_vl_imp_trib_icms    => v_valor_icms            -- nao utilizado
                                                , sn_vl_base_calc_icmsst => v_vl_base_calc_icmsst   -- nao utilizado
                                                , sn_vl_imp_trib_icmsst  => v_vl_imp_trib_icmsst    -- nao utilizado
                                                , sn_vl_bc_isenta_icms   => v_isenta_nao_tributada  -- nao utilizado
                                                , sn_vl_bc_outra_icms    => v_outras                -- nao utilizado
                                                , sv_cod_st_ipi          => v_cod_st_ipi            -- nao utilizado
                                                , sn_vl_base_calc_ipi    => v_vl_base_calc_ipi      -- nao utilizado
                                                , sn_aliq_ipi            => v_aliq_ipi              -- nao utilizado
                                                , sn_vl_imp_trib_ipi     => v_vl_imp_trib_ipi
                                                , sn_vl_bc_isenta_ipi    => v_vl_bc_isenta_ipi
                                                , sn_vl_bc_outra_ipi     => v_vl_bc_outra_ipi       -- nao utilizado
                                                , sn_ipi_nao_recup       => v_ipi_nao_recup         -- nao utilizado
                                                , sn_outro_ipi           => v_outro_ipi
                                                , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi
                                                , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                                , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                                , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                                );
               --
               vn_fase := 33;
               -- Armazena os valores
               v_vl_valor_total := nvl(v_vl_valor_total,0)       + nvl(v_valor_total,0);
               v_vl_tot_ipi     := nvl(v_vl_tot_ipi,0)           + nvl(v_vl_imp_trib_ipi,0);
               v_tot_outras     := nvl(v_tot_outras,0)           + nvl(v_outro_ipi,0);
               --
               vn_fase := 34;
               -- Atualiza as variaveis
               v_existe_cfop    := rec.cfop;
               vn_notafiscal_id := rec.notafiscal_id;
               --
            else
               --
               vn_fase := 35;
               -- Grava as variaveis do cursor
               v_dt_emissao := lpad(to_number(to_char(rec.dt_emis_receb,'rrrrmmdd')),8,0);
               v_serie      := nvl(trim(rec.serie),'0');
               --
               vn_fase := 36;
               --
               if not pk_csf.fkg_is_numerico(v_serie) then
                  v_serie := ' ';
               end if;
               --
               vn_fase := 37;
               --
               v_numero   := rec.numero;
               v_situacao := rec.situacao;
               --
               vn_fase := 38;
               --
               if rpad(v_serie,3,'0') = '000' then
                  v_serie := ' ';
               end if;
               --
               vn_fase := 39;
               -- Busca cnpj, ie e uf
               pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                                     , sv_cpf_cnpj  => v_cnpj
                                     , sv_ie        => v_ie
                                     , sv_uf        => v_uf );
               --
               vn_fase := 40;
               -- Busca valores do item na package
               pk_csf_api.pkb_vlr_fiscal_item_nf( en_itemnf_id           => rec.itemnf_id
                                                , sn_cfop                => v_cfop
                                                , sn_vl_operacao         => v_valor_total
                                                , sv_cod_st_icms         => v_cod_st_icms           -- nao utilizado
                                                , sn_vl_base_calc_icms   => v_base_calculo_icms     -- nao utilizado
                                                , sn_aliq_icms           => v_aliquota              -- nao utilizado
                                                , sn_vl_imp_trib_icms    => v_valor_icms            -- nao utilizado
                                                , sn_vl_base_calc_icmsst => v_vl_base_calc_icmsst   -- nao utilizado
                                                , sn_vl_imp_trib_icmsst  => v_vl_imp_trib_icmsst    -- nao utilizado
                                                , sn_vl_bc_isenta_icms   => v_isenta_nao_tributada  -- nao utilizado
                                                , sn_vl_bc_outra_icms    => v_outras                -- nao utilizado
                                                , sv_cod_st_ipi          => v_cod_st_ipi            -- nao utilizado
                                                , sn_vl_base_calc_ipi    => v_vl_base_calc_ipi      -- nao utilizado
                                                , sn_aliq_ipi            => v_aliq_ipi              -- nao utilizado
                                                , sn_vl_imp_trib_ipi     => v_vl_imp_trib_ipi
                                                , sn_vl_bc_isenta_ipi    => v_vl_bc_isenta_ipi
                                                , sn_vl_bc_outra_ipi     => v_vl_bc_outra_ipi       -- nao utilizado
                                                , sn_ipi_nao_recup       => v_ipi_nao_recup         -- nao utilizado
                                                , sn_outro_ipi           => v_outro_ipi
                                                , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi
                                                , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                                , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                                , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                                );
               --
               vn_fase := 41;
               -- Armazena os valores
               v_vl_valor_total := nvl(v_vl_valor_total,0)       + nvl(v_valor_total,0);
               v_vl_tot_ipi     := nvl(v_vl_tot_ipi,0)           + nvl(v_vl_imp_trib_ipi,0);
               v_tot_outras     := nvl(v_tot_outras,0)           + nvl(v_outro_ipi,0);
               --
               vn_fase := 42;
               -- Atualiza as variaveis
               v_existe_cfop    := rec.cfop;
               v_inicio         := 'N';
               vn_notafiscal_id := rec.notafiscal_id;
               --
            end if;
            --
         end if;
         --
      end loop;
      --
      vn_fase := 43;
      -- Grava os ultimos valores armazenados
      i := nvl(i,0) + 1;
      --
      vt_tab_reg_0051(i).tipo          := '51';
      vt_tab_reg_0051(i).cnpj          := nvl(v_cnpj,'0');
      vt_tab_reg_0051(i).ie            := nvl(v_ie,' ');
      vt_tab_reg_0051(i).dt_emis_receb := v_dt_emissao;
      vt_tab_reg_0051(i).uf            := nvl(v_uf,' ');
      vt_tab_reg_0051(i).serie         := nvl(trim(v_serie),'0');
      --
      vn_fase := 44;
      --
      if rpad(vt_tab_reg_0051(i).serie, 3, '0') = '000' then
         vt_tab_reg_0051(i).serie := ' ';
      end if;
      --
      vn_fase := 45;
      --
      vt_tab_reg_0051(i).numero              := nvl(v_numero,0);
      vt_tab_reg_0051(i).cfop                := v_cfop;
      vt_tab_reg_0051(i).valor_total         := nvl(to_number(replace(replace(to_char(v_vl_valor_total,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0051(i).valor_ipi           := nvl(to_number(replace(replace(to_char(v_vl_tot_ipi,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0051(i).isenta_nao_trib_ipi := nvl(to_number(replace(replace(to_char(v_vl_bc_isenta_ipi,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0051(i).outras_ipi          := nvl(to_number(replace(replace(to_char(v_tot_outras,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0051(i).brancos             := ' ';
      vt_tab_reg_0051(i).situacao            := v_situacao;
      --
   end if; -- vv_existe = 'S' -- Sim, existe parâmetro de que a empresa é contribuinte do IPI, portanto deve ser montado o registro 51
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0051 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0051;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0053: DOCUMENTOS FISCAIS - SUBSTITUICAO TRIBUTARIA
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0053 IS
   --
   vn_fase                    number := 0;
   i                          pls_integer;
   --
   v_dt_emissao               number;
   v_modelo                   mod_fiscal.cod_mod%type;
   v_serie                    nota_fiscal.serie%type;
   v_numero                   nota_fiscal.nro_nf%type;
   v_emitente                 varchar2(01);
   v_situacao                 varchar2(01);
   v_cnpj                     varchar2(14);
   v_ie                       varchar2(14);
   v_uf                       varchar2(02);
   v_cfop                     number(04);
   v_existe_cfop              number(04);
   v_vl_base_calc_icmsst      number(15,2);
   v_vl_imp_trib_icmsst       number(15,2);
   vl_despesas_acessorias     number(15,2);
   -- valores nao usados neste registro
   v_outras                   number;
   v_valor_total              number;
   v_cod_st_icms              number;
   v_base_calculo_icms        number;
   v_valor_icms               number;
   v_isenta_nao_tributada     number;
   v_aliquota                 number;
   v_cod_st_ipi               number;
   v_vl_base_calc_ipi         number;
   v_aliq_ipi                 number;
   v_vl_imp_trib_ipi          number;
   v_vl_bc_isenta_ipi         number;
   v_vl_bc_outra_ipi          number;
   v_ipi_nao_recup            number;
   v_outro_ipi                number;
   vn_vl_imp_nao_dest_ipi     number;
   vn_vl_fcp_icmsst           number;
   vn_aliq_fcp_icms           number;
   vn_vl_fcp_icms             number;
   -- somatorias
   v_vl_tot_base_calc_icmsst  number(15,2);
   v_vl_tot_imp_trib_st       number(15,2);
   v_tot_outras               number(15,2);
   --
   cursor c_sint is
      select (case when nf.dm_ind_emit = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  else
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
             end) dt_emis_receb
           , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
               end) numero
           , replace(nf.serie, '*', '')     serie
           , mf.cod_mod                     modelo
           , sum(nvl(inf.vl_frete ,0) + nvl(inf.vl_seguro,0) + nvl(inf.vl_outro ,0)) vl_despesas_acessorias
           , decode(nf.dm_ind_emit, 0, 'P',
                                    1, 'T') emitente
           , decode( sdc.cd ,'00' , 'N'
                            ,'01' , 'E'
                            ,'02' , 'S'
                            ,'03' , 'X'
                            ,'04' , '2'
                            ,'05' , '4'
                            , 'N'
                            ) situacao
           , nf.pessoa_id                 pessoa_id
           , ' ' cod_antecipacao
           , nf.id notafiscal_id
           , inf.cfop_id
        from nota_fiscal       nf
           , mod_fiscal        mf
           , item_nota_fiscal  inf
           , sit_docto         sdc
           , pessoa            p
           , cidade            cid
       where nf.empresa_id      = gt_row_abertura_sint.empresa_id
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
         and nf.dm_st_proc     in (4, 7, 8) -- Autorizada/cancelada/inutilizada
         and nf.dm_arm_nfe_terc = 0
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '04', '55', '65', '06', '21', '22') -- NF, NF Produtor Rural, NFe, NF Energia Elétrica, NF Serv.Comun., NF Serv.Telecomun.
         and inf.notafiscal_id  = nf.id
         and nf.sitdocto_id     = sdc.id
         and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
         and p.id               = nf.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       group by (case when nf.dm_ind_emit = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  else
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
             end)
           , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
               end)
           , replace(nf.serie, '*', '')
           , mf.cod_mod
           , decode(nf.dm_ind_emit, 0, 'P',
                                    1, 'T')
           , decode( sdc.cd ,'00' , 'N'
                            ,'01' , 'E'
                            ,'02' , 'S'
                            ,'03' , 'X'
                            ,'04' , '2'
                            ,'05' , '4'
                            , 'N'
                            )
           , nf.pessoa_id
           , nf.id
           , inf.cfop_id
    order by 1 -- dt_emis_receb
           , 7 -- emitente
           , 2; -- nro_nf
   --
   cursor c_sint_item( en_notafiscal_id in nota_fiscal.id%type
                     , en_cfop_id       in cfop.id%type ) is
      select inf.id  itemnf_id
           , (nvl(inf.vl_frete ,0) + nvl(inf.vl_seguro,0) + nvl(inf.vl_outro ,0)) vl_despesas_acessorias
        from item_nota_fiscal inf
       where inf.notafiscal_id = en_notafiscal_id
         and inf.cfop_id       = en_cfop_id;
   --
   cursor c_det_cfop_sc is
      select (case when nf.dm_ind_emit = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  else
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
             end) dt_emis_receb
           , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
               end) numero
           , replace(nf.serie, '*', '')     serie
           , mf.cod_mod                     modelo
           , nf.id       notafiscal_id
           , decode( sdc.cd ,'00' , 'N'
                            ,'01' , 'E'
                            ,'02' , 'S'
                            ,'03' , 'X'
                            ,'04' , '2'
                            ,'05' , '4'
                            , 'N'
                            ) situacao
           , decode(nf.dm_ind_emit, 0, 'P',
                                    1, 'T') emitente
           , nf.pessoa_id
           , r.id nfregistanalit_id
           , c.cd cfop
        from nota_fiscal     nf
           , mod_fiscal      mf
           , nfregist_analit r
           , sit_docto       sdc
           , cfop c
           , pessoa            p
           , cidade            cid
       where nf.empresa_id      = gt_row_abertura_sint.empresa_id
         and nf.dm_st_proc      = 4
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
         and nf.dm_arm_nfe_terc = 0
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('06', '29', '28', '21', '22')
         and r.notafiscal_id    = nf.id
         and nf.SITDOCTO_ID     = sdc.id
         and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
         and c.id               = r.cfop_id
         and p.id               = nf.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       order by 1;
   --
BEGIN
   --
   vn_fase := 1;
   --
   v_cnpj                 := null;
   v_ie                   := null;
   v_uf                   := null;
   v_cfop                 := 0;
   --
   v_vl_base_calc_icmsst  := 0;
   v_vl_imp_trib_icmsst   := 0;
   vl_despesas_acessorias := 0;
   -- valores nao usados neste registro
   v_outras               := 0;
   v_valor_total          := 0;
   v_cod_st_icms          := 0;
   v_base_calculo_icms    := 0;
   v_valor_icms           := 0;
   v_isenta_nao_tributada := 0;
   v_aliquota             := 0;
   v_cod_st_ipi           := 0;
   v_vl_base_calc_ipi     := 0;
   v_aliq_ipi             := 0;
   v_vl_imp_trib_ipi      := 0;
   v_vl_bc_isenta_ipi     := 0;
   v_vl_bc_outra_ipi      := 0;
   v_ipi_nao_recup        := 0;
   v_outro_ipi            := 0;
   -- somatorias
   v_vl_tot_base_calc_icmsst := 0;
   v_vl_tot_imp_trib_st      := 0;
   v_tot_outras              := 0;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      v_dt_emissao := lpad(to_number(to_char(rec.dt_emis_receb,'rrrrmmdd')),8,0);
      v_modelo     := rec.modelo;
      v_serie      := nvl(trim(rec.serie),'0');
      --
      vn_fase := 3;
      --
      if not pk_csf.fkg_is_numerico(v_serie) then
         v_serie := ' ';
      end if;
      --
      vn_fase := 4;
      --
      v_numero      := rec.numero;
      v_emitente    := rec.emitente;
      v_situacao    := rec.situacao;
      v_existe_cfop := 0;
      --
      vn_fase := 5;
      --
      if rpad(v_serie, 3, '0') = '000' then
         v_serie := ' ';
      end if;
      --
      vn_fase := 6;
      --
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 7;
      -- busca valores do icmsst dos itens da nota
      v_vl_tot_base_calc_icmsst := 0;
      v_vl_tot_imp_trib_st      := 0;
      v_tot_outras              := 0;
      --
      for r_reg in c_sint_item( en_notafiscal_id => rec.notafiscal_id
                              , en_cfop_id       => rec.cfop_id )
      loop
         --
         exit when c_sint_item%notfound or(c_sint_item%notfound) is null;
         --
         vn_fase := 8;
         --
         pk_csf_api.pkb_vlr_fiscal_item_nf( en_itemnf_id           => r_reg.itemnf_id
                                          , sn_cfop                => v_cfop
                                          , sn_vl_operacao         => v_valor_total            -- nao utilizado
                                          , sv_cod_st_icms         => v_cod_st_icms            -- nao utilizado
                                          , sn_vl_base_calc_icms   => v_base_calculo_icms      -- nao utilizado
                                          , sn_aliq_icms           => v_aliquota               -- nao utilizado
                                          , sn_vl_imp_trib_icms    => v_valor_icms             -- nao utilizado
                                          , sn_vl_base_calc_icmsst => v_vl_base_calc_icmsst
                                          , sn_vl_imp_trib_icmsst  => v_vl_imp_trib_icmsst
                                          , sn_vl_bc_isenta_icms   => v_isenta_nao_tributada   -- nao utilizado
                                          , sn_vl_bc_outra_icms    => v_outras                 -- nao utilizado
                                          , sv_cod_st_ipi          => v_cod_st_ipi             -- nao utilizado
                                          , sn_vl_base_calc_ipi    => v_vl_base_calc_ipi       -- nao utilizado
                                          , sn_aliq_ipi            => v_aliq_ipi               -- nao utilizado
                                          , sn_vl_imp_trib_ipi     => v_vl_imp_trib_ipi        -- nao utilizado
                                          , sn_vl_bc_isenta_ipi    => v_vl_bc_isenta_ipi       -- nao utilizado
                                          , sn_vl_bc_outra_ipi     => v_vl_bc_outra_ipi        -- nao utilizado
                                          , sn_ipi_nao_recup       => v_ipi_nao_recup          -- nao utilizado
                                          , sn_outro_ipi           => v_outro_ipi
                                          , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi   -- nao utilizado
                                          , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                          , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                          , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                          );
         --
         vn_fase := 9;
         --
         v_vl_tot_base_calc_icmsst := nvl(v_vl_tot_base_calc_icmsst,0) + nvl(v_vl_base_calc_icmsst,0);
         v_vl_tot_imp_trib_st      := nvl(v_vl_tot_imp_trib_st,0) + nvl(v_vl_imp_trib_icmsst,0);
         v_tot_outras              := nvl(v_tot_outras,0) + nvl(r_reg.vl_despesas_acessorias,0);
         --
      end loop;
      --
      vn_fase := 10;
      --
      if nvl(v_vl_tot_imp_trib_st,0) > 0 then
         --
         vn_fase := 11;
         --
         i := nvl(i,0) + 1;
         --
         vn_fase := 12;
         --
         vt_tab_reg_0053(i).tipo          := '53';
         vt_tab_reg_0053(i).cnpj          := nvl(v_cnpj,'0');
         vt_tab_reg_0053(i).ie            := v_ie;
         vt_tab_reg_0053(i).dt_emis_receb := v_dt_emissao;
         vt_tab_reg_0053(i).uf            := v_uf;
         vt_tab_reg_0053(i).modelo        := v_modelo;
         vt_tab_reg_0053(i).serie         := nvl(trim(v_serie),'0');
         --
         vn_fase := 13;
         --
         if rpad(vt_tab_reg_0053(i).serie, 3, '0') = '000' then
            vt_tab_reg_0053(i).serie := ' ';
         end if;
         --
         vn_fase := 14;
         --
         vt_tab_reg_0053(i).numero               := v_numero;
         vt_tab_reg_0053(i).cfop                 := v_cfop;
         vt_tab_reg_0053(i).emitente             := v_emitente;
         vt_tab_reg_0053(i).base_calculo_icms_st := nvl(to_number(replace(replace(to_char(v_vl_tot_base_calc_icmsst,'9999999999990D99'),',',''),'.','')),0);
         vt_tab_reg_0053(i).icms_retido          := nvl(to_number(replace(replace(to_char(v_vl_tot_imp_trib_st,'9999999999990D99'),',',''),'.','')),0);
         vt_tab_reg_0053(i).despesas_acessorias  := nvl(to_number(replace(replace(to_char(v_tot_outras,'9999999999990D99'),',',''),'.','')),0);
         vt_tab_reg_0053(i).situacao             := v_situacao;
         vt_tab_reg_0053(i).cod_antecipacao      := rec.cod_antecipacao;
         vt_tab_reg_0053(i).brancos              := ' ';
         --
      end if;
      --
   end loop;
   --
   vn_fase := 15;
   --
   v_cnpj                 := null;
   v_ie                   := null;
   v_uf                   := null;
   v_cfop                 := 0;
   --
   v_vl_base_calc_icmsst  := 0;
   v_vl_imp_trib_icmsst   := 0;
   vl_despesas_acessorias := 0;
   -- valores nao usados neste registro
   v_outras               := 0;
   v_valor_total          := 0;
   v_cod_st_icms          := 0;
   v_base_calculo_icms    := 0;
   v_valor_icms           := 0;
   v_isenta_nao_tributada := 0;
   v_aliquota             := 0;
   -- somatorias
   v_vl_tot_imp_trib_st   := 0;
   v_tot_outras           := 0;
   --
   vn_fase := 16;
   --
   for rec in c_det_cfop_sc
   loop
      --
      exit when c_det_cfop_sc%notfound or (c_det_cfop_sc%notfound) is null;
      --
      vn_fase := 17;
      --
      v_dt_emissao := lpad(to_number(to_char(rec.dt_emis_receb,'rrrrmmdd')),8,0);
      v_modelo     := rec.modelo;
      v_serie      := nvl(trim(rec.serie),'0');
      --
      vn_fase := 18;
      --
      if not pk_csf.fkg_is_numerico(v_serie) then
         v_serie := ' ';
      end if;
      --
      vn_fase := 19;
      --
      v_numero      := rec.numero;
      v_emitente    := rec.emitente;
      v_situacao    := rec.situacao;
      v_existe_cfop := 0;
      --
      vn_fase := 20;
      --
      if rpad(v_serie, 3, '0') = '000' then
         v_serie := ' ';
      end if;
      --
      vn_fase := 21;
      --
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 22;
      -- busca valores do icms
      pk_csf_api.pkb_vlr_fiscal_nfsc ( en_nfregistanalit_id => rec.nfregistanalit_id
                                     , sv_cod_st_icms       => v_cod_st_icms
                                     , sn_cfop              => v_cfop
                                     , sn_aliq_icms         => v_aliquota
                                     , sn_vl_operacao       => v_valor_total
                                     , sn_vl_bc_icms        => v_base_calculo_icms
                                     , sn_vl_icms           => v_valor_icms
                                     , sn_vl_bc_icmsst      => v_vl_base_calc_icmsst
                                     , sn_vl_icms_st        => v_vl_imp_trib_icmsst
                                     , sn_vl_ipi            => v_vl_imp_trib_ipi
                                     , sn_vl_bc_isenta_icms => v_isenta_nao_tributada
                                     , sn_vl_bc_outra_icms  => v_outras );
      --
      vn_fase := 23;
      --
      v_vl_tot_imp_trib_st := nvl(v_vl_tot_imp_trib_st,0) + nvl(v_vl_imp_trib_icmsst,0);
      v_tot_outras         := nvl(v_tot_outras,0) + 0;
      --
      vn_fase := 24;
      --
      if nvl(v_vl_imp_trib_icmsst,0) > 0 then
         --
         vn_fase := 25;
         --
         i := nvl(i,0) + 1;
         --
         vn_fase := 26;
         --
         vt_tab_reg_0053(i).tipo          := '53';
         vt_tab_reg_0053(i).cnpj          := nvl(v_cnpj,'0');
         vt_tab_reg_0053(i).ie            := v_ie;
         vt_tab_reg_0053(i).dt_emis_receb := v_dt_emissao;
         vt_tab_reg_0053(i).uf            := v_uf;
         vt_tab_reg_0053(i).modelo        := v_modelo;
         vt_tab_reg_0053(i).serie         := nvl(trim(v_serie),'0');
         --
         vn_fase := 27;
         --
         if rpad(vt_tab_reg_0053(i).serie, 3, '0') = '000' then
            vt_tab_reg_0053(i).serie := ' ';
         end if;
         --
         vn_fase := 28;
         --
         vt_tab_reg_0053(i).numero               := v_numero;
         vt_tab_reg_0053(i).cfop                 := v_cfop;
         vt_tab_reg_0053(i).emitente             := v_emitente;
         vt_tab_reg_0053(i).base_calculo_icms_st := nvl(to_number(replace(replace(to_char(v_vl_base_calc_icmsst , '9999999999990D99'),',',''),'.','')),0);
         vt_tab_reg_0053(i).icms_retido          := nvl(to_number(replace(replace(to_char(v_vl_tot_imp_trib_st  , '9999999999990D99'),',',''),'.','')),0);
         vt_tab_reg_0053(i).despesas_acessorias  := nvl(to_number(replace(replace(to_char(v_tot_outras          , '9999999999990D99'),',',''),'.','')),0);
         vt_tab_reg_0053(i).situacao             := v_situacao;
         vt_tab_reg_0053(i).cod_antecipacao      := ' ';
         vt_tab_reg_0053(i).brancos              := ' ';
         --
      end if;
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0053 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0053;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0054: PRODUTO
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0054 IS
   --
   vn_fase                   number := 0;
   i                         pls_integer;
   --
   v_modelo                  mod_fiscal.cod_mod%type;
   v_serie                   nota_fiscal.serie%type;
   v_numero                  nota_fiscal.nro_nf%type;
   v_cnpj                    varchar2(14);
   v_cfop                    number(04);
   v_existe_cfop             number(04);
   v_cod_st_icms             varchar2(03);
   v_base_calculo_icms       number(15,2);
   v_vl_base_calc_icmsst     number(15,2);
   v_vl_imp_trib_ipi         number(15,2);
   v_aliquota                number(15,2);
   -- valores nao usados neste registro
   v_valor_total             number(15,2);
   v_valor_icms              number(15,2);
   v_isenta_nao_tributada    number(15,2);
   v_outras                  number(15,2);
   v_vl_imp_trib_icmsst      number(15,2);
   v_cod_st_ipi              number;
   v_vl_base_calc_ipi        number(15,2);
   v_aliq_ipi                number(15,2);
   v_vl_bc_isenta_ipi        number(15,2);
   v_vl_bc_outra_ipi         number(15,2);
   v_ipi_nao_recup           number(15,2);
   v_outro_ipi               number(15,2);
   vn_vl_imp_nao_dest_ipi    number(15,2);
   vn_vl_fcp_icmsst          number;
   vn_aliq_fcp_icms          number;
   vn_vl_fcp_icms            number;
   -- somatorias
   v_vl_tot_imp_trib_ipi     number(15,2);
   v_ie                      juridica.ie%type;
   v_uf                      estado.sigla_estado%type;
   vv_codigo_produto_servico varchar2(4);
   --
   cursor c_sint is
      select distinct
             (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
              end) numero
           , inf.id                         itemnf_id
           , replace(nf.serie, '*', '')     serie
           , mf.cod_mod                     modelo
           , inf.NRO_ITEM                   numero_item
           , substr(nvl(it.COD_ITEM,inf.COD_ITEM),1,14)      codigo_produto_servico
           , length(nvl(to_number(replace(replace(trim(to_char(nvl(qtde_trib,0),'99999999999999999999990D999')),',',''),'.','')),0)) tamanho_qtde
           , trunc(inf.QTDE_TRIB, 3)        quantidade
           , inf.vl_item_bruto              valor_produto
           , inf.vl_desc                    valor_desc_desp_acess
           , inf.orig
           , nf.pessoa_id                   pessoa_id
           , nf.id                          notafiscal_id
           , inf.item_Id
        from nota_fiscal      nf
           , mod_fiscal       mf
           , item_nota_fiscal inf
           , sit_docto        sdc
           , item             it
           , pessoa            p
           , cidade            cid
       where nf.empresa_id      = gt_row_abertura_sint.empresa_id
         and nf.dm_st_proc     in (4) -- Autorizada/cancelada/inutilizada
         and nf.dm_arm_nfe_terc = 0
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '04', '55', '65', '06', '22') -- NF, NF Produtor Rural, NFe, NF Energia Elétrica, NF Serv.Telecomun.
         and nf.SITDOCTO_ID     = sdc.id
         and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
         and inf.notafiscal_id  = nf.id
         and it.id              = inf.item_id
         and p.id               = nf.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       order by 1 -- nro_nf
           --, inf.id
           , nf.id
           , inf.nro_item;
   --
   cursor c_det_cfop_sc is
      select (case when nf.dm_ind_emit = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  else
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
             end) dt_emis_receb
           , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
              end) numero
           , replace(nf.serie, '*', '')     serie
           , mf.cod_mod                     modelo
           , nf.id       notafiscal_id
           , decode( sdc.cd ,'00' , 'N'
                            ,'01' , 'E'
                            ,'02' , 'S'
                            ,'03' , 'X'
                            ,'04' , '2'
                            ,'05' , '4'
                            , 'N'
                            ) situacao
           , decode(nf.dm_ind_emit, 0, 'P',
                                    1, 'T') emitente
           , nf.pessoa_id
           , r.id nfregistanalit_id
           , c.cd cfop
        from nota_fiscal     nf
           , mod_fiscal      mf
           , nfregist_analit r
           , sit_docto       sdc
           , cfop c
           , pessoa            p
           , cidade            cid
       where nf.empresa_id      = gt_row_abertura_sint.empresa_id
         and nf.dm_st_proc      = 4
         and nf.dm_arm_nfe_terc = 0
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('06', '22')
         and r.notafiscal_id    = nf.id
         and nf.sitdocto_id     = sdc.id
         and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
         and c.id               = r.cfop_id
         and p.id               = nf.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       order by 1;
   --
BEGIN
   --
   vn_fase := 1;
   --
   v_cnpj                 := null;
   v_cfop                 := 0;
   v_cod_st_icms          := null;
   v_base_calculo_icms    := 0;
   v_vl_base_calc_icmsst  := 0;
   v_vl_imp_trib_ipi      := 0;
   v_aliquota             := 0;
   -- valores nao usados neste registro
   v_valor_total          := 0;
   v_valor_icms           := 0;
   v_isenta_nao_tributada := 0;
   v_outras               := 0;
   v_vl_imp_trib_icmsst   := 0;
   v_cod_st_ipi           := 0;
   v_vl_base_calc_ipi     := 0;
   v_aliq_ipi             := 0;
   v_vl_bc_isenta_ipi     := 0;
   v_vl_bc_outra_ipi      := 0;
   v_ipi_nao_recup        := 0;
   v_outro_ipi            := 0;
   -- somatorias
   v_vl_tot_imp_trib_ipi  := 0;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      v_modelo := rec.modelo;
      v_serie  := nvl(trim(rec.serie),'0');
      --
      vn_fase := 3;
      --
      if not pk_csf.fkg_is_numerico(v_serie) then
         v_serie := ' ';
      end if;
      --
      vn_fase := 4;
      --
      v_numero      := rec.numero;
      v_existe_cfop := 0;
      --
      vn_fase := 5;
      --
      if rpad(v_serie, 3, '0') = '000' then
         v_serie := ' ';
      end if;
      --
      vn_fase := 6;
      --
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 7;
      -- busca valores do icms
      pk_csf_api.pkb_vlr_fiscal_item_nf( en_itemnf_id           => rec.itemnf_id
                                       , sn_cfop                => v_cfop
                                       , sn_vl_operacao         => v_valor_total            -- nao utilizado
                                       , sv_cod_st_icms         => v_cod_st_icms
                                       , sn_vl_base_calc_icms   => v_base_calculo_icms
                                       , sn_aliq_icms           => v_aliquota
                                       , sn_vl_imp_trib_icms    => v_valor_icms             -- nao utilizado
                                       , sn_vl_base_calc_icmsst => v_vl_base_calc_icmsst
                                       , sn_vl_imp_trib_icmsst  => v_vl_imp_trib_icmsst     -- nao utilizado
                                       , sn_vl_bc_isenta_icms   => v_isenta_nao_tributada   -- nao utilizado
                                       , sn_vl_bc_outra_icms    => v_outras                 -- nao utilizado
                                       , sv_cod_st_ipi          => v_cod_st_ipi             -- nao utilizado
                                       , sn_vl_base_calc_ipi    => v_vl_base_calc_ipi       -- nao utilizado
                                       , sn_aliq_ipi            => v_aliq_ipi               -- nao utilizado
                                       , sn_vl_imp_trib_ipi     => v_vl_imp_trib_ipi
                                       , sn_vl_bc_isenta_ipi    => v_vl_bc_isenta_ipi       -- nao utilizado
                                       , sn_vl_bc_outra_ipi     => v_vl_bc_outra_ipi        -- nao utilizado
                                       , sn_ipi_nao_recup       => v_ipi_nao_recup          -- nao utilizado
                                       , sn_outro_ipi           => v_outro_ipi
                                       , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi
                                       , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                       , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                       , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                       );           -- nao utilizado
      --
      vn_fase := 8;
      --
      v_vl_tot_imp_trib_ipi := nvl(v_vl_tot_imp_trib_ipi,0) + nvl(v_vl_imp_trib_ipi,0);
      --
      vn_fase := 9;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 10;
      --
      vt_tab_reg_0054(i).tipo   := '54';
      vt_tab_reg_0054(i).cnpj   := nvl(v_cnpj,'0');
      vt_tab_reg_0054(i).modelo := v_modelo;
      vt_tab_reg_0054(i).serie  := nvl(trim(v_serie),'0');
      --
      vn_fase := 11;
      --
      if rpad(vt_tab_reg_0054(i).serie, 3, '0') = '000' then
         vt_tab_reg_0054(i).serie := ' ';
      end if;
      --
      vn_fase := 12;
      --
      vt_tab_reg_0054(i).numero                 := v_numero;
      vt_tab_reg_0054(i).cfop                   := v_cfop;
      vt_tab_reg_0054(i).cst                    := rpad( (rec.orig || trim(v_cod_st_icms)), 3, '0');
      vt_tab_reg_0054(i).numero_item            := rec.numero_item;
      vt_tab_reg_0054(i).codigo_produto_servico := rec.codigo_produto_servico;
      --
      vn_fase := 13;
      --
      if rec.tamanho_qtde > 11 then
         --
         vn_fase := 14;
         vt_tab_reg_0054(i).quantidade := substr(nvl(to_number(replace(replace(trim(to_char(nvl(rec.quantidade,0),'99999999999999999999990D999')),',',''),'.','')),0),-rec.tamanho_qtde,11);
         --
      else
         --
         vn_fase := 15;
         vt_tab_reg_0054(i).quantidade := nvl(replace(replace(trim(to_char(nvl(rec.quantidade,0),'99999999999999999999990D999')),',',''),'.',''),0);
         --
      end if;
      --
      vn_fase := 16;
      --
      vt_tab_reg_0054(i).valor_produto         := nvl(to_number(replace(replace(to_char(nvl(rec.valor_produto,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0054(i).valor_desc_desp_acess := nvl(to_number(replace(replace(to_char(nvl(rec.valor_desc_desp_acess,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0054(i).base_calc_icms        := nvl(to_number(replace(replace(to_char(nvl(v_base_calculo_icms,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0054(i).base_calc_icms_st     := nvl(to_number(replace(replace(to_char(nvl(v_vl_base_calc_icmsst,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0054(i).valor_ipi             := nvl(to_number(replace(replace(to_char(nvl(v_vl_tot_imp_trib_ipi,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0054(i).aliq_icms             := nvl(to_number(replace(replace(to_char(nvl(v_aliquota,0),'9999999999990D99'),',',''),'.','')),0);
      --
      vn_fase := 17;
      --
      pkb_monta_reg_0075( en_item_id => rec.item_id );
      --
   end loop;
   --
   vn_fase := 18;
   --
   v_cnpj                 := null;
   v_cfop                 := 0;
   v_cod_st_icms          := null;
   v_base_calculo_icms    := 0;
   v_vl_base_calc_icmsst  := 0;
   v_vl_imp_trib_ipi      := 0;
   v_aliquota             := 0;
   -- valores nao usados neste registro
   v_valor_total          := 0;
   v_valor_icms           := 0;
   v_isenta_nao_tributada := 0;
   v_outras               := 0;
   v_vl_imp_trib_icmsst   := 0;
   -- somatorias
   v_vl_tot_imp_trib_ipi  := 0;
   --
   vn_fase := 19;
   --Serviços COntinuos
   for rec in c_det_cfop_sc
   loop
      --
      exit when c_det_cfop_sc%notfound or (c_det_cfop_sc%notfound) is null;
      --
      vn_fase := 20;
      --
      v_modelo := rec.modelo;
      v_serie  := nvl(trim(rec.serie),'0');
      --
      vn_fase := 21;
      --
      if not pk_csf.fkg_is_numerico(v_serie) then
         v_serie := ' ';
      end if;
      --
      vn_fase := 22;
      --
      v_numero      := rec.numero;
      v_existe_cfop := 0;
      --
      vn_fase := 23;
      --
      if rpad(v_serie, 3, '0') = '000' then
         v_serie := ' ';
      end if;
      --
      vn_fase := 24;
      --
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 25;
      -- busca valores do icms
      pk_csf_api.pkb_vlr_fiscal_nfsc( en_nfregistanalit_id => rec.nfregistanalit_id
                                    , sv_cod_st_icms       => v_cod_st_icms
                                    , sn_cfop              => v_cfop
                                    , sn_aliq_icms         => v_aliquota
                                    , sn_vl_operacao       => v_valor_total
                                    , sn_vl_bc_icms        => v_base_calculo_icms
                                    , sn_vl_icms           => v_valor_icms
                                    , sn_vl_bc_icmsst      => v_vl_base_calc_icmsst
                                    , sn_vl_icms_st        => v_vl_imp_trib_icmsst
                                    , sn_vl_ipi            => v_vl_imp_trib_ipi
                                    , sn_vl_bc_isenta_icms => v_isenta_nao_tributada
                                    , sn_vl_bc_outra_icms  => v_outras );
      --
      vn_fase := 26;
      --
      v_vl_tot_imp_trib_ipi := nvl(v_vl_tot_imp_trib_ipi,0) + nvl(v_vl_imp_trib_ipi,0);
      --
      vn_fase := 27;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 28;
      --
      vt_tab_reg_0054(i).tipo   := '54';
      vt_tab_reg_0054(i).cnpj   := nvl(v_cnpj,'0');
      vt_tab_reg_0054(i).modelo := v_modelo;
      vt_tab_reg_0054(i).serie  := nvl(trim(v_serie),'0');
      --
      vn_fase := 29;
      --
      if rpad(vt_tab_reg_0054(i).serie, 3, '0') = '000' then
         vt_tab_reg_0054(i).serie := ' ';
      end if;
      --
      vn_fase := 30;
      --
      vt_tab_reg_0054(i).numero      := v_numero;
      vt_tab_reg_0054(i).cfop        := v_cfop;
      vt_tab_reg_0054(i).cst         := rpad(('0'||trim(v_cod_st_icms)),3,'0');
      vt_tab_reg_0054(i).numero_item := 1;
      --
      vn_fase := 31;
      --
      vv_codigo_produto_servico := 'SC' || v_modelo;
      vt_tab_reg_0054(i).codigo_produto_servico := vv_codigo_produto_servico;
      vt_tab_reg_0054(i).quantidade := 1;
      --
      vn_fase := 32;
      --
      vt_tab_reg_0054(i).valor_produto         := nvl(to_number(replace(replace(to_char(nvl(v_valor_total,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0054(i).valor_desc_desp_acess := 0;
      vt_tab_reg_0054(i).base_calc_icms        := nvl(to_number(replace(replace(to_char(nvl(v_base_calculo_icms,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0054(i).base_calc_icms_st     := nvl(to_number(replace(replace(to_char(nvl(v_vl_base_calc_icmsst,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0054(i).valor_ipi             := nvl(to_number(replace(replace(to_char(nvl(v_vl_tot_imp_trib_ipi,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0054(i).aliq_icms             := nvl(to_number(replace(replace(to_char(nvl(v_aliquota,0),'9999999999990D99'),',',''),'.','')),0);
      --
      vn_fase := 33;
      --
      if vv_codigo_produto_servico = 'SC06' then
         --
         vn_fase := 34;
         vt_tab_reg_0075(10000000).tipo               := '75';
         vt_tab_reg_0075(10000000).data_inicial       := substr( lpad(to_number(to_char(gt_row_abertura_sint.dt_ini,'rrrrmmdd')),8,0),1,08);
         vt_tab_reg_0075(10000000).data_final         := substr( lpad(to_number(to_char(gt_row_abertura_sint.dt_fin,'rrrrmmdd')),8,0),1,08);
         vt_tab_reg_0075(10000000).cod_produto_serv   := vv_codigo_produto_servico;
         vt_tab_reg_0075(10000000).cod_ncm            := '99999999';
         vt_tab_reg_0075(10000000).descricao          := vv_codigo_produto_servico;
         vt_tab_reg_0075(10000000).unid_med_comerc    := 'UN';
         vt_tab_reg_0075(10000000).aliquota_ipi       := 0;
         vt_tab_reg_0075(10000000).aliquota_icms      := 0;
         vt_tab_reg_0075(10000000).red_base_calc_icms := 0;
         vt_tab_reg_0075(10000000).base_calc_icms_st  := 0;
         --
      elsif vv_codigo_produto_servico = 'SC21' then
            --
            vn_fase := 35;
            vt_tab_reg_0075(10000001).tipo               := '75';
            vt_tab_reg_0075(10000001).data_inicial       := substr( lpad(to_number(to_char(gt_row_abertura_sint.dt_ini,'rrrrmmdd')),8,0),1,08);
            vt_tab_reg_0075(10000001).data_final         := substr( lpad(to_number(to_char(gt_row_abertura_sint.dt_fin,'rrrrmmdd')),8,0),1,08);
            vt_tab_reg_0075(10000001).cod_produto_serv   := vv_codigo_produto_servico;
            vt_tab_reg_0075(10000001).cod_ncm            := '99999999';
            vt_tab_reg_0075(10000001).descricao          := vv_codigo_produto_servico;
            vt_tab_reg_0075(10000001).unid_med_comerc    := 'UN';
            vt_tab_reg_0075(10000001).aliquota_ipi       := 0;
            vt_tab_reg_0075(10000001).aliquota_icms      := 0;
            vt_tab_reg_0075(10000001).red_base_calc_icms := 0;
            vt_tab_reg_0075(10000001).base_calc_icms_st  := 0;
            --
      elsif vv_codigo_produto_servico = 'SC22' then
            --
            vn_fase := 36;
            vt_tab_reg_0075(10000002).tipo               := '75';
            vt_tab_reg_0075(10000002).data_inicial       := substr( lpad(to_number(to_char(gt_row_abertura_sint.dt_ini,'rrrrmmdd')),8,0),1,08);
            vt_tab_reg_0075(10000002).data_final         := substr( lpad(to_number(to_char(gt_row_abertura_sint.dt_fin,'rrrrmmdd')),8,0),1,08);
            vt_tab_reg_0075(10000002).cod_produto_serv   := vv_codigo_produto_servico;
            vt_tab_reg_0075(10000002).cod_ncm            := '99999999';
            vt_tab_reg_0075(10000002).descricao          := vv_codigo_produto_servico;
            vt_tab_reg_0075(10000002).unid_med_comerc    := 'UN';
            vt_tab_reg_0075(10000002).aliquota_ipi       := 0;
            vt_tab_reg_0075(10000002).aliquota_icms      := 0;
            vt_tab_reg_0075(10000002).red_base_calc_icms := 0;
            vt_tab_reg_0075(10000002).base_calc_icms_st  := 0;
            --
      end if;
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0054 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0054;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0056: OPERACOES COM VEICULOS AUTOMOTORES NOVOS
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0056 IS
   --
   vn_fase                 number := 0;
   i                       pls_integer;
   --
   v_modelo                mod_fiscal.cod_mod%type;
   v_serie                 nota_fiscal.serie%type;
   v_numero                nota_fiscal.nro_nf%type;
   v_cnpj                  varchar2(14);
   v_cfop                  number(04);
   v_existe_cfop           number(04);
   v_cod_st_icms           varchar2(03);
   v_aliq_ipi              number(04);
   v_cnpj_cpf              varchar2(14);
   -- valores nao usados neste registro
   v_base_calculo_icms     number;
   v_vl_base_calc_icmsst   number;
   v_vl_imp_trib_ipi       number;
   v_aliquota              number;
   v_valor_total           number;
   v_valor_icms            number;
   v_isenta_nao_tributada  number;
   v_outras                number;
   v_vl_imp_trib_icmsst    number;
   v_cod_st_ipi            number;
   v_vl_base_calc_ipi      number;
   v_vl_bc_isenta_ipi      number;
   v_vl_bc_outra_ipi       number;
   v_ipi_nao_recup         number;
   v_outro_ipi             number;
   vn_vl_imp_nao_dest_ipi  number;
   vn_vl_fcp_icmsst        number;
   vn_aliq_fcp_icms        number;
   vn_vl_fcp_icms          number;
   --
   v_ie                    juridica.ie%type;
   v_uf                    estado.sigla_estado%type;
   --
   cursor c_sint is
      select distinct
             (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
               end) numero
           , inf.id                         itemnf_id
           , replace(nf.serie, '*', '')     serie
           , mf.cod_mod                     modelo
           , inf.NRO_ITEM                   numero_item
           , substr(inf.COD_ITEM,1,14)      cod_prod_serv
           , itv.DM_TP_OPER                 tipo_operacao
           , itv.CNPJ_CONCES                cnpj_concessionaria
           , itv.CHASSI                     chassi
           , nf.pessoa_id                   pessoa_id
           , inf.orig
        from nota_fiscal      nf
           , mod_fiscal       mf
           , item_nota_fiscal inf
           , sit_docto        sdc
           , itemnf_veic      itv
           , pessoa            p
           , cidade            cid
       where nf.empresa_id      = gt_row_abertura_sint.empresa_id
         and nf.dm_st_proc     in (4,7,8) -- Autorizada/cancelada/inutilizada
         and nf.dm_arm_nfe_terc = 0
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '04', '55', '65', '06', '21', '22') -- NF, NF Produtor Rural, NFe, NF Energia Elétrica, NF Serv.Comun., NF Serv.Telecomun.
         and inf.notafiscal_id  = nf.id
         and nf.SITDOCTO_ID     = sdc.id
         and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
         and inf.id             = itv.itemnf_id
         and p.id               = nf.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       order by 1
           , inf.id;
   --
BEGIN
   --
   vn_fase := 1;
   --
   v_cnpj                 := null;
   v_cfop                 := 0;
   v_cod_st_icms          := null;
   v_aliq_ipi             := 0;
   v_cnpj_cpf             := null;
   -- valores nao usados neste registro
   v_base_calculo_icms    := 0;
   v_vl_base_calc_icmsst  := 0;
   v_vl_imp_trib_ipi      := 0;
   v_aliquota             := 0;
   v_valor_total          := 0;
   v_valor_icms           := 0;
   v_isenta_nao_tributada := 0;
   v_outras               := 0;
   v_vl_imp_trib_icmsst   := 0;
   v_cod_st_ipi           := 0;
   v_vl_base_calc_ipi     := 0;
   v_vl_bc_isenta_ipi     := 0;
   v_vl_bc_outra_ipi      := 0;
   v_ipi_nao_recup        := 0;
   v_outro_ipi            := 0;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      v_modelo      := rec.modelo;
      v_serie       := nvl(trim(rec.serie),'0');
      v_numero      := rec.numero;
      v_existe_cfop := 0;
      --
      vn_fase := 3;
      --
      if rpad(v_serie, 3, '0') = '000' then
         v_serie := ' ';
      end if;
      --
      vn_fase := 4;
      --
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 5;
      -- se nao tiver cnpj, busca o cpf
      if v_cnpj is null then
         v_cnpj_cpf := null;
      end if;
      --
      vn_fase := 6;
      -- busca valores do icms
      pk_csf_api.pkb_vlr_fiscal_item_nf( en_itemnf_id           => rec.itemnf_id
                                       , sn_cfop                => v_cfop
                                       , sn_vl_operacao         => v_valor_total            -- nao utilizado
                                       , sv_cod_st_icms         => v_cod_st_icms
                                       , sn_vl_base_calc_icms   => v_base_calculo_icms      -- nao utilizado
                                       , sn_aliq_icms           => v_aliquota               -- nao utilizado
                                       , sn_vl_imp_trib_icms    => v_valor_icms             -- nao utilizado
                                       , sn_vl_base_calc_icmsst => v_vl_base_calc_icmsst    -- nao utilizado
                                       , sn_vl_imp_trib_icmsst  => v_vl_imp_trib_icmsst     -- nao utilizado
                                       , sn_vl_bc_isenta_icms   => v_isenta_nao_tributada   -- nao utilizado
                                       , sn_vl_bc_outra_icms    => v_outras                 -- nao utilizado
                                       , sv_cod_st_ipi          => v_cod_st_ipi             -- nao utilizado
                                       , sn_vl_base_calc_ipi    => v_vl_base_calc_ipi       -- nao utilizado
                                       , sn_aliq_ipi            => v_aliq_ipi
                                       , sn_vl_imp_trib_ipi     => v_vl_imp_trib_ipi        -- nao utilizado
                                       , sn_vl_bc_isenta_ipi    => v_vl_bc_isenta_ipi       -- nao utilizado
                                       , sn_vl_bc_outra_ipi     => v_vl_bc_outra_ipi        -- nao utilizado
                                       , sn_ipi_nao_recup       => v_ipi_nao_recup          -- nao utilizado
                                       , sn_outro_ipi           => v_outro_ipi
                                       , sn_vl_imp_nao_dest_ipi => vn_vl_imp_nao_dest_ipi
                                       , sn_vl_fcp_icmsst       => vn_vl_fcp_icmsst
                                       , sn_aliq_fcp_icms       => vn_aliq_fcp_icms
                                       , sn_vl_fcp_icms         => vn_vl_fcp_icms
                                       );           -- nao utilizado
      --
      vn_fase := 7;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 8;
      --
      vt_tab_reg_0056(i).tipo     := '56';
      vt_tab_reg_0056(i).cnpj_cpf := nvl(v_cnpj_cpf ,'0');
      vt_tab_reg_0056(i).modelo   := v_modelo;
      vt_tab_reg_0056(i).serie    := nvl(trim(v_serie),'0');
      --
      vn_fase := 9;
      --
      if rpad(vt_tab_reg_0056(i).serie, 3, '0') = '000' then
         vt_tab_reg_0056(i).serie := ' ';
      end if;
      --
      vn_fase := 10;
      --
      vt_tab_reg_0056(i).numero              := v_numero;
      vt_tab_reg_0056(i).cfop                := v_cfop;
      vt_tab_reg_0056(i).cst                 := (rec.orig||v_cod_st_icms);
      vt_tab_reg_0056(i).numero_item         := nvl(rec.numero_item,0);
      vt_tab_reg_0056(i).cod_prod_serv       := nvl(rec.cod_prod_serv,' ');
      vt_tab_reg_0056(i).tipo_operacao       := nvl(rec.tipo_operacao,0);
      vt_tab_reg_0056(i).cnpj_concessionaria := nvl(rec.cnpj_concessionaria,'0');
      vt_tab_reg_0056(i).aliquota_ipi        := nvl(to_number(replace(replace(to_char(nvl(v_aliq_ipi,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0056(i).chassi              := nvl(rec.chassi,' ');
      vt_tab_reg_0056(i).brancos             := ' ';
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0056 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0056;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0057: NÚMERO DE LOTE DE FABRICAÇÃO DE PRODUTO
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0057 IS
   --
   vn_fase         number := 0;
   i               pls_integer;
   --
   v_modelo        mod_fiscal.cod_mod%type;
   v_serie         nota_fiscal.serie%type;
   v_numero        nota_fiscal.nro_nf%type;
   v_cnpj          varchar2(14);
   v_ie            varchar2(14);
   v_cfop          number(04);
   v_existe_cfop   number(04);
   v_cod_st_icms   varchar2(03);
   v_uf            estado.sigla_estado%type;
   --
   cursor c_sint is
      select distinct
             (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
               end) numero
           , replace(nf.serie, '*', '')     serie
           , mf.cod_mod                     modelo
           , inf.id                         itemnf_id
           , nf.pessoa_id                   pessoa_id
           , inf.NRO_ITEM                   numero_item
           , substr(inf.cod_item,1,14)      cod_prod
           , itm.nro_lote                   num_lote_prod
           , inf.orig
        from nota_fiscal      nf
           , mod_fiscal       mf
           , item_nota_fiscal inf
           , sit_docto        sdc
           , itemnf_med       itm
           , pessoa            p
           , cidade            cid
       where nf.empresa_id      = gt_row_abertura_sint.empresa_id
         and nf.dm_st_proc     in (4,7,8) -- Autorizada/cancelada/inutilizada
         and nf.dm_arm_nfe_terc = 0
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('01', '04', '55', '65', '06', '21', '22') -- NF, NF Produtor Rural, NFe, NF Energia Elétrica, NF Serv.Comun., NF Serv.Telecomun.
         and inf.notafiscal_id  = nf.id
         and nf.sitdocto_id     = sdc.id
         and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
         and inf.id             = itm.itemnf_id
         and p.id               = nf.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       order by 1
           , inf.id;
   --
BEGIN
   --
   vn_fase := 1;
   --
   v_cnpj                 := null;
   v_ie                   := null;
   v_cfop                 := 0;
   v_cod_st_icms          := null;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      v_modelo      := rec.modelo;
      v_serie       := nvl(trim(rec.serie),'0');
      v_numero      := rec.numero;
      v_existe_cfop := 0;
      --
      vn_fase := 3;
      --
      if rpad(v_serie, 3, '0') = '000' then
         v_serie := ' ';
      end if;
      --
      vn_fase := 4;
      --
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 5;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 6;
      --
      vt_tab_reg_0057(i).tipo   := '57';
      vt_tab_reg_0057(i).cnpj   := nvl(v_cnpj,'0');
      vt_tab_reg_0057(i).ie     := v_ie;
      vt_tab_reg_0057(i).modelo := v_modelo;
      vt_tab_reg_0057(i).serie  := nvl(trim(v_serie),'0');
      --
      vn_fase := 7;
      --
      if rpad(vt_tab_reg_0057(i).serie, 3, '0') = '000' then
         vt_tab_reg_0057(i).serie := ' ';
      end if;
      --
      vn_fase := 8;
      --
      vt_tab_reg_0057(i).numero        := v_numero;
      vt_tab_reg_0057(i).cfop          := v_cfop;
      vt_tab_reg_0057(i).cst           := (rec.orig||v_cod_st_icms);
      vt_tab_reg_0057(i).numero_item   := nvl(rec.numero_item,0);
      vt_tab_reg_0057(i).cod_prod      := nvl(rec.cod_prod,' ');
      vt_tab_reg_0057(i).num_lote_prod := nvl(rec.num_lote_prod,' ');
      vt_tab_reg_0057(i).branco        := ' ';
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0057 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0057;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0060: Mestre (60M): IDENTIFICADOR DO EQUIPAMENTO.
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0060M IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
   cursor c_sint is
      select distinct '60'               tipo
           , 'M'                         subtipo
           , rze.dt_doc                  data_emissao
           , eqe.ecf_fab                 num_serie_fabr
           , rze.crz                     num_ord_sequencial_equip
           , mdf.cod_mod                 modelo_doc_fiscal
           , rze.cro                     num_cont_ord_oper_ini_dia
           , rze.num_coo_fin             num_cont_ord_oper_fim_dia
           , rze.crz                     num_cont_red_z
           , rze.cro                     cont_reinicio_oper
           , rze.vl_brt                  valor_venda_bruta
           , rze.vl_grande_total_fin     valor_tot_geral_equip
           , ' '                         brancos
           , rze.id                      reducaozecf_id
        from equip_ecf           eqe
           , reducao_z_ecf       rze
           , mod_fiscal          mdf
           , doc_fiscal_emit_ecf dfe
           , sit_docto           sd
       where eqe.empresa_id          = gt_row_abertura_sint.empresa_id
         and eqe.modfiscal_id        = mdf.id
         and eqe.id                  = rze.equipecf_id
         and trunc(rze.dt_doc) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)
         and rze.dm_st_proc          = 1 -- Validada
         and dfe.reducaozecf_id      = rze.id
         and sd.id                   = dfe.sitdocto_id
         and sd.cd              not in ('02','03','04','05') -- cancelados
       order by rze.dt_doc
           , rze.crz;
   --
BEGIN
   --
   vn_fase := 1;
   --
   i := 0;
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      gn_qtde_sai := nvl(gn_qtde_sai,0) + 1;
      --
      i := rec.reducaozecf_id;
      --
      vn_fase := 3;
      --
      vt_tab_reg_0060M(i).tipo                      := rec.tipo;
      vt_tab_reg_0060M(i).subtipo                   := nvl(rec.subtipo,' ');
      vt_tab_reg_0060M(i).data_emissao              := lpad(to_number(to_char(rec.data_emissao,'rrrrmmdd')),8,0);
      vt_tab_reg_0060M(i).num_serie_fabr            := rec.num_serie_fabr;
      --
      vn_fase := 3.1;
      --
      vt_tab_reg_0060M(i).num_ord_sequencial_equip  := nvl(substr(rec.num_ord_sequencial_equip, 1, 3),0);
      vt_tab_reg_0060M(i).modelo_doc_fiscal         := nvl(rec.modelo_doc_fiscal,' ');
      vt_tab_reg_0060M(i).num_cont_ord_oper_ini_dia := nvl(rec.num_cont_ord_oper_ini_dia,0);
      vt_tab_reg_0060M(i).num_cont_ord_oper_fim_dia := nvl(rec.num_cont_ord_oper_fim_dia,0);
      --
      vn_fase := 3.2;
      --
      vt_tab_reg_0060M(i).num_cont_red_z            := nvl(rec.num_cont_red_z,0);
      vt_tab_reg_0060M(i).cont_reinicio_oper        := nvl(rec.cont_reinicio_oper,0);
      --
      vn_fase := 3.3;
      --
      vt_tab_reg_0060M(i).valor_venda_bruta         := nvl(to_number(replace(replace(to_char(nvl(rec.valor_venda_bruta,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0060M(i).valor_tot_geral_equip     := nvl(to_number(replace(replace(to_char(nvl(rec.valor_tot_geral_equip,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0060M(i).brancos                   := rpad(rec.brancos,37,' ');
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0060M fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0060M;

--------------------------------------------------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0060A: Analítico (60A): Identificador de cada Situação Tributária no final do dia de cada equipamento emissor de cupom fiscal
--------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0060A IS
   --
   vn_fase                 number := 0;
   i                       pls_integer;
   j                       pls_integer;
   vb_existe               boolean;
   -- valores nao usados neste registro
   vv_sit_trib_aliq        varchar2(4);
   --
   cursor c_sint is
      select distinct '60'                    tipo
           , 'A'                              subtipo
           , rze.dt_doc                       data_emissao
           , eqe.ecf_fab                      num_serie_fabr
           , tot.cod_tot
           , tpr.vlr_acum_tot                 valor_acum_tot_parc
           , ' '                              brancos
           , rze.id reducaozecf_id
           , tpr.id totparcredzecf_id
        from equip_ecf          eqe
           , reducao_z_ecf      rze
           , tot_parc_red_z_ecf tpr
           , tot_parc_red_z     tot
       where eqe.empresa_id          = gt_row_abertura_sint.empresa_id
         and eqe.id                  = rze.equipecf_id
         and trunc(rze.dt_doc) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)
         and rze.dm_st_proc          = 1 -- Validada
         and rze.id                  = tpr.reducaozecf_id
         and tpr.totparcredz_id      = tot.id
         and tot.cod_tot        not in ('AT', 'AS', 'OPNF', 'DO', 'AO', 'IOF')
       order by rze.dt_doc;
   --
   cursor c_sint2 is
      select '60'                    tipo
           , 'A'                     subtipo
           , rze.dt_doc              data_emissao
           , eqe.ecf_fab             num_serie_fabr
           , ( lpad(nvl(case
                          when cst.cod_st not in ( '30', '40', '41', '50', '60', '51', '90' ) then
                               nvl(i.aliq_icms,0)
                          else 0
                         end
                       , 0) * 100, 4, '0') ) cod_tot
           , nvl(i.vl_item,0)                valor_acum_tot_parc
           , ' '                             brancos
           , rze.id reducaozecf_id
           , d.id docfiscalemitecf_Id
        from equip_ecf              eqe
           , reducao_z_ecf          rze
           , doc_fiscal_emit_ecf    d
           , sit_docto              sd
           , it_doc_fiscal_emit_ecf i
           , cod_st                 cst
       where eqe.empresa_id          = gt_row_abertura_sint.empresa_id
         and eqe.id                  = rze.equipecf_id
         and trunc(rze.dt_doc) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)
         and rze.dm_st_proc          = 1 -- Validada
         and d.reducaozecf_id        = rze.id
         and sd.id                   = d.sitdocto_id
         and sd.cd              not in ('02','03','04','05') -- cancelados
         and i.docfiscalemitecf_id   = d.id
         and nvl(i.qtde_canc,0)     <= 0
         and nvl(i.aliq_icms,0)      > 0
         and cst.id                  = i.codst_id
       order by rze.dt_doc;
   --
BEGIN
   --
   vn_fase := 1;
   --
   i := 0;
   j := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      vv_sit_trib_aliq := null;
      --
      if upper(rec.cod_tot) in ('CAN-T', 'CAN-S', 'CAN-O') then
         --
         vv_sit_trib_aliq := 'CANC';
         j := 50000;
         --
      elsif rec.cod_tot in ('DT', 'DS', 'DO') then
         --
         vv_sit_trib_aliq := 'DESC';
         j := 40000;
         --
      elsif rec.cod_tot like 'S%' then
         --
         vv_sit_trib_aliq := 'ISS';
         j := 30000;
         --
      elsif rec.cod_tot like 'F%' then
         --
         vv_sit_trib_aliq := 'F';
         j := 20000;
         --
      elsif rec.cod_tot like 'I%' then
         --
         vv_sit_trib_aliq := 'I';
         j := 10000;
         --
      elsif rec.cod_tot like 'N%' then
         --
         vv_sit_trib_aliq := 'N';
         j := 0;
         --
      elsif rec.cod_tot like 'A%' then
         --
         vv_sit_trib_aliq := 'N';
         j := 0;
         --
      elsif pk_csf.fkg_is_numerico(substr(rec.cod_tot, -4, 4)) then
         --
         vv_sit_trib_aliq := substr(rec.cod_tot, -4, 4);
         j := to_number(vv_sit_trib_aliq);
         --
      else
         --
         vv_sit_trib_aliq := 'N';
         j := 0;
         --
      end if;
      --
      vn_fase := 3;
      --
      i := rec.reducaozecf_id;
      --
      vn_fase := 4;
      --
      if j not between 1 and 9999 then
         --
         vn_fase := 5;
         --
         begin
            --
            vb_existe := vt_bi_tab_reg_0060A(i).exists(j);
            --
         exception
            when others then
               vb_existe := false;
         end;
         --
         vn_fase := 6;
         --
         if not vb_existe then
            --
            vt_bi_tab_reg_0060A(i)(j).tipo                := rec.tipo;
            vt_bi_tab_reg_0060A(i)(j).subtipo             := nvl(rec.subtipo,' ');
            vt_bi_tab_reg_0060A(i)(j).data_emissao        := lpad(to_number(to_char(rec.data_emissao,'rrrrmmdd')),8,0);
            vt_bi_tab_reg_0060A(i)(j).num_serie_fabr      := rec.num_serie_fabr;
            vt_bi_tab_reg_0060A(i)(j).sit_trib_aliq       := rpad(vv_sit_trib_aliq, 4,' ');
            vt_bi_tab_reg_0060A(i)(j).valor_acum_tot_parc := nvl(rec.valor_acum_tot_parc,0) * 100;
            vt_bi_tab_reg_0060A(i)(j).brancos             := rpad(rec.brancos, 79, ' ');
            --
         else
            --
            vt_bi_tab_reg_0060A(i)(j).valor_acum_tot_parc := nvl(vt_bi_tab_reg_0060A(i)(j).valor_acum_tot_parc,0) + nvl(rec.valor_acum_tot_parc,0) * 100;
            --
         end if;
         --
      end if;
      --
   end loop;
   --
   vn_fase := 7;
   -- pega os valores baseados no item do cupom
   for rec in c_sint2
   loop
      --
      exit when c_sint2%notfound or(c_sint2%notfound) is null;
      --
      vn_fase := 8;
      --
      vv_sit_trib_aliq := null;
      --
      if upper(rec.cod_tot) in ('CAN-T', 'CAN-S', 'CAN-O') then
         --
         vv_sit_trib_aliq := 'CANC';
         j := 50000;
         --
      elsif rec.cod_tot in ('DT', 'DS', 'DO') then
         --
         vv_sit_trib_aliq := 'DESC';
         j := 40000;
         --
      elsif rec.cod_tot like 'S%' then
         --
         vv_sit_trib_aliq := 'ISS';
         j := 30000;
         --
      elsif rec.cod_tot like 'F%' then
         --
         vv_sit_trib_aliq := 'F';
         j := 20000;
         --
      elsif rec.cod_tot like 'I%' then
         --
         vv_sit_trib_aliq := 'I';
         j := 10000;
         --
      elsif rec.cod_tot like 'N%' then
         --
         vv_sit_trib_aliq := 'N';
         j := 0;
         --
      elsif rec.cod_tot like 'A%' then
         --
         vv_sit_trib_aliq := 'N';
         j := 0;
         --
      elsif pk_csf.fkg_is_numerico( rec.cod_tot ) then
         --
         vv_sit_trib_aliq := rec.cod_tot;
         j := to_number(vv_sit_trib_aliq);
         --
      else
         --
         vv_sit_trib_aliq := 'N';
         j := 0;
         --
      end if;
      --
      vn_fase := 9;
      --
      i := rec.reducaozecf_id;
      --
      vn_fase := 10;
      --
      begin
         --
         vb_existe := vt_bi_tab_reg_0060A(i).exists(j);
         --
      exception
         when others then
            vb_existe := false;
      end;
      --
      vn_fase := 11;
      --
      if not vb_existe then
         --
         vt_bi_tab_reg_0060A(i)(j).tipo                := rec.tipo;
         vt_bi_tab_reg_0060A(i)(j).subtipo             := nvl(rec.subtipo,' ');
         vt_bi_tab_reg_0060A(i)(j).data_emissao        := lpad(to_number(to_char(rec.data_emissao,'rrrrmmdd')),8,0);
         vt_bi_tab_reg_0060A(i)(j).num_serie_fabr      := rec.num_serie_fabr;
         vt_bi_tab_reg_0060A(i)(j).sit_trib_aliq       := rpad(vv_sit_trib_aliq, 4,' ');
         vt_bi_tab_reg_0060A(i)(j).valor_acum_tot_parc := nvl(rec.valor_acum_tot_parc,0) * 100;
         vt_bi_tab_reg_0060A(i)(j).brancos             := rpad(rec.brancos, 79, ' ');
         --
      else
         --
         vt_bi_tab_reg_0060A(i)(j).valor_acum_tot_parc := nvl(vt_bi_tab_reg_0060A(i)(j).valor_acum_tot_parc,0) + nvl(rec.valor_acum_tot_parc,0) * 100;
         --
      end if;
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0060A fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0060A;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0060D: Resumo Diário
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0060D IS
   --
   vn_fase                 number := 0;
   i                       pls_integer;
   j                       pls_integer;
   k                       pls_integer;
   vb_achou                boolean;
   --
   cursor c_sint is
      select rze.id                           reducaozecf_id
           , dfe.dt_doc                       data_emissao
           , eqe.ecf_fab                      num_serie_fabr
           , ite.id                           item_id
           , substr(ite.cod_item,1,14)        codigo_produto_servico
           , case
                when cst.cod_st not in ( '30', '40', '41', '50', '60', '51', '90' ) then
                    nvl(ite.aliq_icms,0)
                else 0
              end aliq_icms
           , sum(idf.qtde)                    quantidade
           , sum(idf.vl_item)                 valor_merc_prod_serv
        from equip_ecf              eqe
           , reducao_z_ecf          rze
           , doc_fiscal_emit_ecf    dfe
           , sit_docto              sd
           , it_doc_fiscal_emit_ecf idf
           , item                   ite
           , cod_st                 cst
       where eqe.empresa_id          = gt_row_abertura_sint.empresa_id
         and eqe.id                  = rze.equipecf_id
         and trunc(rze.dt_doc) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)
         and rze.dm_st_proc          = 1 -- Validada
         and rze.id                  = dfe.reducaozecf_id
         and sd.id                   = dfe.sitdocto_id
         and sd.cd              not in ('02','03','04','05') -- cancelados
         and dfe.id                  = idf.docfiscalemitecf_id
         and idf.item_id             = ite.id
         and cst.id                  = idf.codst_id
       group by rze.id
           , dfe.dt_doc
           , eqe.ecf_fab
           , ite.id
           , substr(ite.cod_item,1,14)
           , case
                when cst.cod_st not in ( '30', '40', '41', '50', '60', '51', '90' ) then
                    nvl(ite.aliq_icms,0)
                else 0
              end
       order by rze.id
           , ite.id
           , 6;
   --
BEGIN
   --
   vn_fase := 1;
   --
   vb_achou := false;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      i := rec.reducaozecf_id;
      j := rec.item_id;
      k := nvl(rec.aliq_icms,0);
      --
      vn_fase := 3;
      --
      begin
         --
         vb_achou := vt_tri_tab_reg_0060D(i)(j).exists(k);
         --
      exception
         when others then
            vb_achou := false;
      end;
      --
      if not vb_achou then
         --
         vn_fase := 4;
         --
         vt_tri_tab_reg_0060D(i)(j)(k).tipo                   := '60';
         vt_tri_tab_reg_0060D(i)(j)(k).subtipo                := 'D';
         vt_tri_tab_reg_0060D(i)(j)(k).data_emissao           := lpad(to_number(to_char(rec.data_emissao,'rrrrmmdd')),8,0);
         vt_tri_tab_reg_0060D(i)(j)(k).num_serie_fabr         := rec.num_serie_fabr;
         vt_tri_tab_reg_0060D(i)(j)(k).codigo_produto_servico := rec.codigo_produto_servico;
         vt_tri_tab_reg_0060D(i)(j)(k).quantidade             := nvl(rec.quantidade ,0) * 1000;
         vt_tri_tab_reg_0060D(i)(j)(k).valor_merc_prod_serv   := nvl(to_number(replace(replace(to_char(rec.valor_merc_prod_serv,'9999999999990D99'),',',''),'.','')),0);
         --
         vn_fase := 5;
         --
         if nvl(rec.aliq_icms,0) > 0 then
            --
            vt_tri_tab_reg_0060D(i)(j)(k).base_calc_icms := nvl(to_number(replace(replace(to_char(rec.valor_merc_prod_serv,'9999999999990D99'),',',''),'.','')),0);
            vt_tri_tab_reg_0060D(i)(j)(k).sit_trib_aliq  := lpad(rec.aliq_icms * 100, 4, '0');
            vt_tri_tab_reg_0060D(i)(j)(k).valor_icms     := nvl(to_number(replace(replace(to_char( (nvl(rec.valor_merc_prod_serv,0) * (nvl(rec.aliq_icms,0)/100) ) ,'9999999999990D99'),',',''),'.','')),0);
            --
         else
            --
            vt_tri_tab_reg_0060D(i)(j)(k).base_calc_icms := 0;
            vt_tri_tab_reg_0060D(i)(j)(k).sit_trib_aliq  := 'N';
            vt_tri_tab_reg_0060D(i)(j)(k).valor_icms     := 0;
            --
         end if;
         --
      else
         --
         vn_fase := 6;
         --
         vt_tri_tab_reg_0060D(i)(j)(k).quantidade           := nvl(vt_tri_tab_reg_0060D(i)(j)(k).quantidade,0) + nvl(rec.quantidade ,0) * 1000;
         vt_tri_tab_reg_0060D(i)(j)(k).valor_merc_prod_serv := nvl(vt_tri_tab_reg_0060D(i)(j)(k).valor_merc_prod_serv,0) + nvl(to_number(replace(replace(to_char(rec.valor_merc_prod_serv,'9999999999990D99'),',',''),'.','')),0);
         --
         vn_fase := 7;
         --
         if nvl(rec.aliq_icms,0) > 0 then
            --
            vt_tri_tab_reg_0060D(i)(j)(k).base_calc_icms := nvl(vt_tri_tab_reg_0060D(i)(j)(k).base_calc_icms,0) + nvl(to_number(replace(replace(to_char(rec.valor_merc_prod_serv,'9999999999990D99'),',',''),'.','')),0);
            vt_tri_tab_reg_0060D(i)(j)(k).valor_icms     := nvl(vt_tri_tab_reg_0060D(i)(j)(k).valor_icms,0) + nvl(to_number(replace(replace(to_char( (nvl(rec.valor_merc_prod_serv,0) * (nvl(rec.aliq_icms,0)/100) ) ,'9999999999990D99'),',',''),'.','')),0);
            --
         else
            --
            vt_tri_tab_reg_0060D(i)(j)(k).base_calc_icms := 0;
            vt_tri_tab_reg_0060D(i)(j)(k).valor_icms     := 0;
            --
         end if;
         --
      end if;
      --
      vn_fase := 8;
      --
      vt_tri_tab_reg_0060D(i)(j)(k).brancos := lpad(' ',19,' ');
      --
      vn_fase := 9;
      --
      pkb_monta_reg_0075( en_item_id => rec.item_id );
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0060D fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0060D;

-------------------------------------------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0060I : Item do documento fiscal emitido por Terminal Ponto de Venda (PDV) ou equipamento Emissor de Cupom Fiscal (ECF)
--------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0060I IS
   --
   vn_fase                 number := 0;
   i                       pls_integer;
   j                       pls_integer;
   --
   v_dt_emissao            number;
   vn_num_item             number;
   vn_nro_ord_doc_fisc_ant number;
   --
   cursor c_sint is
      select distinct '60'                tipo
           , 'I'                          subtipo
           , dfe.dt_doc                   data_emissao
           , eqe.ecf_fab                  num_serie_fabr
           , mdf.cod_mod                  modelo_doc_fiscal
           , dfe.num_doc                  nro_ord_doc_fisc
           , idf.id                       num_item
           , ite.id                       item_id
           , substr(ite.cod_item,1,14)    cod_merc_prod_serv
           , idf.qtde                     quantidade
           , idf.vl_item                  vl_merc_prod
           , idf.aliq_icms
           , cst.cod_st
           , ' '                          brancos
           , rze.id reducaozecf_id
           , idf.id itdocfiscalemitecf_id
           , idf.qtde_canc
        from equip_ecf               eqe
           , reducao_z_ecf           rze
           , doc_fiscal_emit_ecf     dfe
           , sit_docto               sd
           , it_doc_fiscal_emit_ecf  idf
           , mod_fiscal              mdf
           , item                    ite
           , cod_st                  cst
       where eqe.empresa_id          = gt_row_abertura_sint.empresa_id
         and eqe.modfiscal_id        = mdf.id
         and eqe.id                  = rze.equipecf_id
         and trunc(rze.dt_doc) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)
         and rze.dm_st_proc          = 1 -- Validada
         and rze.id                  = dfe.reducaozecf_id
         and sd.id                   = dfe.sitdocto_id
         and sd.cd              not in ('02','03','04','05') -- cancelados
         and dfe.id                  = idf.docfiscalemitecf_id
         and idf.item_id             = ite.id
         and cst.id                  = idf.codst_id
       order by dfe.dt_doc
           , rze.id
           , dfe.num_doc
           , idf.id;
   --
BEGIN
   --
   vn_fase := 1;
   --
   i := 0;
   vn_nro_ord_doc_fisc_ant := -1;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      v_dt_emissao := lpad(to_number(to_char(rec.data_emissao,'rrrrmmdd')),8,0);
      --
      i := rec.reducaozecf_id;
      j := rec.itdocfiscalemitecf_id;
      --
      vn_fase := 3;
      --
      if rec.nro_ord_doc_fisc <> vn_nro_ord_doc_fisc_ant then
         vn_num_item := 1;
         vn_nro_ord_doc_fisc_ant := rec.nro_ord_doc_fisc;
      else
         vn_num_item := nvl(vn_num_item,0) + 1;
      end if;
      --
      vn_fase := 4;
      --
      vt_bi_tab_reg_0060I(i)(j).tipo               := rec.tipo;
      vt_bi_tab_reg_0060I(i)(j).subtipo            := nvl(rec.subtipo ,' ');
      vt_bi_tab_reg_0060I(i)(j).data_emissao       := v_dt_emissao;
      vt_bi_tab_reg_0060I(i)(j).num_serie_fabr     := rec.num_serie_fabr;
      vt_bi_tab_reg_0060I(i)(j).modelo_doc_fiscal  := nvl(rec.modelo_doc_fiscal ,' ');
      vt_bi_tab_reg_0060I(i)(j).nro_ord_doc_fisc   := nvl(rec.nro_ord_doc_fisc,0);
      vt_bi_tab_reg_0060I(i)(j).num_item           := nvl(vn_num_item,0);
      vt_bi_tab_reg_0060I(i)(j).cod_merc_prod_serv := rec.cod_merc_prod_serv;
      vt_bi_tab_reg_0060I(i)(j).quantidade         := nvl(rec.quantidade  ,0) * 1000;
      --
      vn_fase := 5;
      --
      if nvl(rec.vl_merc_prod,0) <= 0 then
         vt_bi_tab_reg_0060I(i)(j).vl_merc_prod := 1;
      else
         vt_bi_tab_reg_0060I(i)(j).vl_merc_prod := nvl(to_number(replace(replace(to_char(rec.vl_merc_prod,'99999999990D99'),',',''),'.','')),0);
      end if;
      --
      vn_fase := 6;
      --
      if nvl(rec.qtde_canc,0) <= 0 then
         --
         vn_fase := 7;
         --
         if nvl(rec.aliq_icms,0) > 0 and
            rec.cod_st not in ( '30', '40', '41', '50', '60', '51', '90' ) then
            --
            vt_bi_tab_reg_0060I(i)(j).base_calc_icms := nvl(to_number(replace(replace(to_char(rec.vl_merc_prod,'99999999990D99'),',',''),'.','')),0);
            vt_bi_tab_reg_0060I(i)(j).sit_trib_aliq  := lpad( (nvl(rec.aliq_icms,0) * 100), 4, '0' );
            vt_bi_tab_reg_0060I(i)(j).valor_icms     := nvl(to_number(replace(replace(to_char( nvl(rec.vl_merc_prod,0) * (nvl(rec.aliq_icms,0)/100),'99999999990D99'),',',''),'.','')),0);
            --
         else
            --
            vt_bi_tab_reg_0060I(i)(j).base_calc_icms := 0;
            vt_bi_tab_reg_0060I(i)(j).sit_trib_aliq  := 'N';
            vt_bi_tab_reg_0060I(i)(j).valor_icms     := 0;
            --
         end if;
         --
      else
         --
         vn_fase := 8;
         --
         vt_bi_tab_reg_0060I(i)(j).base_calc_icms := 0;
         vt_bi_tab_reg_0060I(i)(j).sit_trib_aliq  := 'CANC';
         vt_bi_tab_reg_0060I(i)(j).valor_icms     := 0;
         --
      end if;
      --
      vn_fase := 9;
      --
      vt_bi_tab_reg_0060I(i)(j).brancos := lpad(rec.brancos, 16, ' ');
      --
      vn_fase := 10;
      --
      pkb_monta_reg_0075( en_item_id => rec.item_id );
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0060I fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0060I;

----------------------------------------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0060R : Registro de mercadoria/produto ou serviço processado em equipamento Emissor de Cupom Fiscal - Resumo Mensal
----------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0060R IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
   cursor c_sint is
      select to_char(dfe.dt_doc,'MMRRRR') mes_ano_emissao
           , ite.id                       item_id
           , substr(ite.cod_item,1,14)    cod_merc_prod
           , case
                when cst.cod_st not in ( '30', '40', '41', '50', '60', '51', '90' ) then
                     idf.aliq_icms
                else 0
              end aliq_icms
           , sum(idf.qtde)                       quantidade
           , sum(idf.vl_item)                    vl_merc_prod
        from equip_ecf              eqe
           , reducao_z_ecf          rze
           , doc_fiscal_emit_ecf    dfe
           , sit_docto              sd
           , it_doc_fiscal_emit_ecf idf
           , item                   ite
           , cod_st                 cst
       where eqe.empresa_id          = gt_row_abertura_sint.empresa_id
         and eqe.id                  = rze.equipecf_id
         and trunc(rze.dt_doc) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)
         and rze.dm_st_proc          = 1 -- Validada
         and rze.id                  = dfe.reducaozecf_id
         and sd.id                   = dfe.sitdocto_id
         and sd.cd              not in ('02','03','04','05') -- cancelados
         and dfe.id                  = idf.docfiscalemitecf_id
         and idf.item_id             = ite.id
         and cst.id                  = idf.codst_id
       group by to_char(dfe.dt_doc,'MMRRRR')
           , ite.id
           , substr(ite.cod_item,1,14)
           , case
                when cst.cod_st not in ( '30', '40', '41', '50', '60', '51', '90' ) then
                     idf.aliq_icms
                else 0
              end
       order by to_char(dfe.dt_doc,'MMRRRR');
   --
BEGIN
   --
   vn_fase := 1;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 3;
      --
      vt_tab_reg_0060R(i).tipo            := '60';
      vt_tab_reg_0060R(i).subtipo         := 'R';
      vt_tab_reg_0060R(i).mes_ano_emissao := nvl(TO_NUMBER(rec.mes_ano_emissao),0);
      vt_tab_reg_0060R(i).cod_merc_prod   := nvl(rec.cod_merc_prod ,' ');
      vt_tab_reg_0060R(i).quantidade      := nvl(rec.quantidade,0);
      vt_tab_reg_0060R(i).vl_merc_prod    := nvl(to_number(replace(replace(to_char(rec.vl_merc_prod,'9999999999990D99'),',',''),'.','')),0);
      --
      vn_fase := 4;
      --
      if nvl(rec.aliq_icms,0) > 0 then
         vt_tab_reg_0060R(i).base_calc_icms := nvl(to_number(replace(replace(to_char(rec.vl_merc_prod,'9999999999990D99'),',',''),'.','')),0);
         vt_tab_reg_0060R(i).sit_trib_aliq  := lpad( nvl(rec.aliq_icms,0) * 100, 4, '0');
      else
         vt_tab_reg_0060R(i).base_calc_icms := 0;
         vt_tab_reg_0060R(i).sit_trib_aliq  := 'N';
      end if;
      --
      vn_fase := 5;
      --
      vt_tab_reg_0060R(i).brancos := lpad(' ',54,' ');
      --
      vn_fase := 6;
      --
      pkb_monta_reg_0075( en_item_id => rec.item_id );
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0060R fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0060R;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0070
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0070 IS
   --
   vn_fase                number := 0;
   i                      pls_integer;
   --
   v_cnpj                 varchar2(14);
   v_ie                   varchar2(14);
   v_uf                   varchar2(02);
   vv_cod_st_icms         cod_st.cod_st%type;
   vn_cfop                cfop.cd%type;
   vn_aliq_icms           ct_reg_anal.aliq_icms%type;
   vn_vl_opr              ct_reg_anal.vl_opr%type;
   vn_vl_bc_icms          ct_reg_anal.vl_bc_icms%type;
   vn_vl_icms             ct_reg_anal.vl_icms%type;
   vn_vl_bc_isenta_icms   number;
   vn_vl_bc_outra_icms    number;
   --
   cursor c_sint is
      select distinct '70'                      tipo
           , trunc(nvl(cht.dt_sai_ent,cht.dt_hr_emissao)) dt_emiss_utiliz
           , mdf.modelo                         modelo
           , replace(cht.serie, '*', '')        serie
           , cht.subserie                       subserie
           , (case when length(cht.nro_ct) >= 6 then substr(cht.nro_ct, -6,6)
                   when length(cht.nro_ct) < 6  then substr(cht.nro_ct, -length(cht.nro_ct),6)
              end) numero
           , cra.cfop_id
           , 0                                  cif_fob_outros --a opção "0" = OUTROS,  nos casos em que não se aplica a informação de cláusula CIF ou FOB
           , decode( cht.sitdocto_id, 1, 'N'
                                    , 3, 'S'
                                    , 2, 'E'
                                    , 4, 'X'
                                    , 5, '2'
                                    , 6, '4' ) situacao
           , cht.pessoa_id                     pessoa_id
           , cht.uf_ibge_emit                  uf_ibge_emit
           , cht.id conhectransp_id
           , cra.id ctreganal_id
        from conhec_transp           cht
           , mod_fiscal              mdf
           , ct_reg_anal             cra
           , pessoa            p
           , cidade            cid
       where cht.empresa_id      = gt_row_abertura_sint.empresa_id
         and cht.dm_arm_cte_terc = 0
         and ((cht.dm_ind_emit = 1 and trunc(nvl(cht.dt_sai_ent,cht.dt_hr_emissao)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (cht.dm_ind_emit = 0 and cht.dm_ind_oper = 1 and trunc(cht.dt_hr_emissao) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (cht.dm_ind_emit = 0 and cht.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(cht.dt_hr_emissao) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (cht.dm_ind_emit = 0 and cht.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(cht.dt_sai_ent,cht.dt_hr_emissao)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
         and cht.modfiscal_id    = mdf.id
         and mdf.cod_mod        in ('07','08','09','10','11','26','27','57')
         and cht.id              = cra.conhectransp_id
         and p.id               = cht.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       order by cht.id
           , cra.id;
   --
BEGIN
   --
   vn_fase := 1;
   --
   v_cnpj               := null;
   v_ie                 := null;
   v_uf                 := null;
   vv_cod_st_icms       := 0;
   vn_cfop              := 0;
   vn_aliq_icms         := 0;
   vn_vl_opr            := 0;
   vn_vl_bc_icms        := 0;
   vn_vl_icms           := 0;
   vn_vl_bc_isenta_icms := 0;
   vn_vl_bc_outra_icms  := 0;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      i := nvl(i,0) + 1;
      --
      gn_qtde_ent := nvl(gn_qtde_ent,0) + 1;
      --
      vn_fase := 3;
      -- recupera vl_tot_documento fiscal por conhecimento de transporte
      pk_csf_ct.pkb_vlr_fiscal_ct( en_ctreganal_id      => rec.ctreganal_id
                                            , sv_cod_st_icms       => vv_cod_st_icms
                                            , sn_cfop              => vn_cfop
                                            , sn_aliq_icms         => vn_aliq_icms
                                            , sn_vl_opr            => vn_vl_opr
                                            , sn_vl_bc_icms        => vn_vl_bc_icms
                                            , sn_vl_icms           => vn_vl_icms
                                            , sn_vl_bc_isenta_icms => vn_vl_bc_isenta_icms
                                            , sn_vl_bc_outra_icms  => vn_vl_bc_outra_icms );
      --
      vn_fase := 4;
      -- busca cnpj, ie e uf
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 5;
      --
      vt_tab_reg_0070(i).tipo := '70';
      vt_tab_reg_0070(i).cnpj := v_cnpj;
      vt_tab_reg_0070(i).ie   := v_ie;
      --
      vn_fase := 6;
      --
      vt_tab_reg_0070(i).dt_emiss_utiliz := lpad(to_number(to_char(rec.dt_emiss_utiliz,'rrrrmmdd')),8,0);
      vt_tab_reg_0070(i).uf              := v_uf;
      vt_tab_reg_0070(i).modelo          := nvl(rec.modelo,0);
      --
      vn_fase := 7;
      --
      if rec.modelo = '57' then
         vt_tab_reg_0070(i).serie := nvl(trim(to_char(substr(rec.serie,1,1))),'0');
      else
         vt_tab_reg_0070(i).serie := 'U';
      end if;
      --
      vn_fase := 8;
      --
      if rpad(vt_tab_reg_0070(i).serie, 3, '0') = '000' then
         vt_tab_reg_0070(i).serie := ' ';
      end if;
      --
      vn_fase := 9;
      --
      vt_tab_reg_0070(i).subserie          := nvl(rec.subserie,' ');
      vt_tab_reg_0070(i).numero            := substr(lpad(rec.numero, 9, '0'), -6, 6);
      vt_tab_reg_0070(i).cfop              := vn_cfop;
      vt_tab_reg_0070(i).vl_tot_doc_fisc   := nvl(to_number(replace(replace(to_char( vn_vl_opr,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0070(i).base_calc_icms    := nvl(to_number(replace(replace(to_char( vn_vl_bc_icms,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0070(i).vl_icms           := nvl(to_number(replace(replace(to_char( vn_vl_icms,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0070(i).isenta_nao_tribut := nvl(to_number(replace(replace(to_char( vn_vl_bc_isenta_icms,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0070(i).outras            := nvl(to_number(replace(replace(to_char( vn_vl_bc_outra_icms,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0070(i).cif_fob_outros    := nvl(rec.cif_fob_outros,0);
      vt_tab_reg_0070(i).situacao          := rec.situacao;
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0070;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0074 : REGISTRO DE INVENTÁRIO
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0074 IS
   --
   vn_fase           number := 0;
   i                 pls_integer;
   v_cnpj            varchar2(14);
   v_ie              juridica.ie%type;
   v_uf              varchar2(02);
   v_data_inventario number;
   --#75073
   cursor c_sint is
  /*    select distinct '74'                tipo
           , inv.dt_inventario            data_inventario
           , substr(ite.cod_item,1,14)    cod_prod
           , decode(inv.dm_ind_prop, 0, 1
                                   , 1, 2
                                   , 2, 3
                                   , 1 )  cod_posse_merc_invent
           , inv.pessoa_id                pessoa_id
           , inv.item_id
           , sum(inv.qtde)                quantidade
           , sum(nvl(inv.vl_item,0))      valor_prod
        from inventario inv
           , item       ite
       where inv.empresa_id                 = gt_row_abertura_sint.empresa_id
         and trunc(inv.dt_inventario) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)
         and inv.item_id                    = ite.id
       group by '74'
           , inv.dt_inventario
           , substr(ite.cod_item,1,14)
           , decode(inv.dm_ind_prop, 0, 1
                                   , 1, 2
                                   , 2, 3
                                   , 1 )
           , inv.pessoa_id
           , inv.item_id
       order by inv.dt_inventario
           , substr(ite.cod_item,1,14);
  */ --
   --
   select distinct tipo
           , data_inventario
           , cod_prod
           , cod_posse_merc_invent
           , pessoa_id
           , item_id
           , quantidade
           , valor_prod
           , empresa_id
        from csf_own.TMP_SINTEGRA_REG_0074
       where empresa_id                 = gt_row_abertura_sint.empresa_id
         and trunc(data_inventario) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)
       order by data_inventario
              , cod_prod;
   --
BEGIN
   --
   vn_fase := 1;
   v_cnpj  := null;
   v_uf    := null;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      v_data_inventario := lpad(to_number(to_char(rec.data_inventario,'rrrrmmdd')),8,0);
      --
      vn_fase := 3;
      --
      if rec.pessoa_id is not null then
         --
         vn_fase := 4;
         -- busca cnpj, ie e uf
         pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                               , sv_cpf_cnpj  => v_cnpj
                               , sv_ie        => v_ie
                               , sv_uf        => v_uf );
         --
      else
         --
         vn_fase := 5;
         -- Pega dados da empresa
         begin
            select nvl(lpad(jur.num_cnpj,8,0) ||lpad(jur.num_filial,4,0) || lpad(jur.dig_cnpj,2, 0) , 0)  cnpj
                 , nvl(est.sigla_estado,null) uf
              into v_cnpj
                 , v_uf
              from empresa  e
                 , pessoa   pes
                 , cidade   cid
                 , estado   est
                 , juridica jur
             where e.id   = gt_row_abertura_sint.empresa_id
               and pes.id = e.pessoa_id
               and cid.id = pes.cidade_id
               and est.id = cid.estado_id
               and pes.id = jur.pessoa_id;
         exception
            when others then
               v_cnpj := null;
               v_uf   := null;
         end;
         --
         v_ie := ' ';
         --
      end if;
      --
      vn_fase := 6;
      -- Se o UF for "EX", o CNPJ deve ser "zero"
      if v_uf = 'EX' then
         v_cnpj := '0';
         v_ie := 'ISENTO';
      end if;
      --
      vn_fase := 7;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 8;
      --
      vt_tab_reg_0074(i).tipo                  := rec.tipo;
      vt_tab_reg_0074(i).data_inventario       := v_data_inventario;
      vt_tab_reg_0074(i).cod_prod              := nvl(rec.cod_prod,' ');
      vt_tab_reg_0074(i).quantidade            := nvl(to_number(replace(replace(to_char( rec.quantidade,'9999999999990D999'),',',''),'.','')),0);
      vt_tab_reg_0074(i).valor_prod            := nvl(to_number(replace(replace(to_char( rec.valor_prod,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0074(i).cod_posse_merc_invent := nvl(to_char(rec.cod_posse_merc_invent),' ');
      vt_tab_reg_0074(i).cnpj_possuidor_prop   := nvl(v_cnpj,'0');
      vt_tab_reg_0074(i).ie_possuidor_prop     := nvl(v_ie,' ');
      vt_tab_reg_0074(i).uf_possuidor_prop     := nvl(v_uf,' ');
      vt_tab_reg_0074(i).brancos               := ' ';
      --
      vn_fase := 9;
      --
      pkb_monta_reg_0075( en_item_id => rec.item_id );
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0074 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0074;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0075 : CODIGO DE PRODUTO OU SERVICO
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0075 ( EN_ITEM_ID IN ITEM.ID%TYPE ) IS
   --
   vn_fase                number := 0;
   i                      pls_integer;
   v_aliq_ipi             number(15,2);
   v_aliquota             number(15,2);
   v_vl_base_calc_icmsst  number(15,2);
   vv_cod_item            item.cod_item%type;
   --
   cursor c_dado is
   select trim(it.cod_item)
     from item it
    where it.id = en_item_id;
   --
   procedure pkb_cria_0075
   is
   --
   cursor c_sint is
      select distinct '75'                      tipo
           , trunc(gt_row_abertura_sint.dt_ini) data_inicial
           , trunc(gt_row_abertura_sint.dt_fin) data_final
           , itm.id                             itemnf_id
           , substr(itm.cod_item,1,14)          cod_produto_serv
           , ncm.COD_NCM                        cod_ncm
           , itm.descr_item                     descricao
           , uni.sigla_unid                     unid_med_comerc
           , 0                                  red_base_calc_icms
        from item    itm
           , ncm     ncm
           , unidade uni
       where itm.id         = en_item_id
         and itm.unidade_id = uni.id
         and itm.ncm_id     = ncm.id(+)
       order by itm.id
           , substr(itm.cod_item,1,14);
   --
   begin
      --
      for rec in c_sint
      loop
         --
         exit when c_sint%notfound or(c_sint%notfound) is null;
         --
         vn_fase := 2;
         --
         vt_tab_reg_0075(en_item_id).tipo               := '75';
         vt_tab_reg_0075(en_item_id).data_inicial       := substr( lpad(to_number(to_char(rec.data_inicial,'rrrrmmdd')),8,0),1,08);
         vt_tab_reg_0075(en_item_id).data_final         := substr( lpad(to_number(to_char(rec.data_final,'rrrrmmdd')),8,0),1,08);
         vt_tab_reg_0075(en_item_id).cod_produto_serv   := substr( nvl(rec.cod_produto_serv,' '),1,14);
         vt_tab_reg_0075(en_item_id).cod_ncm            := substr( nvl(rec.cod_ncm,' '),1,08);
         vt_tab_reg_0075(en_item_id).descricao          := substr( nvl(rec.descricao,' '),1,53);
         vt_tab_reg_0075(en_item_id).unid_med_comerc    := substr( nvl(rec.unid_med_comerc,' '),1,06);
         vt_tab_reg_0075(en_item_id).aliquota_ipi       := substr( nvl(to_number(replace(replace(to_char( v_aliq_ipi,'9999999999990D99'),',',''),'.','')),0),1,05);
         vt_tab_reg_0075(en_item_id).aliquota_icms      := substr( nvl(to_number(replace(replace(to_char( v_aliquota,'9999999999990D99'),',',''),'.','')),0),1,04);
         vt_tab_reg_0075(en_item_id).red_base_calc_icms := substr( nvl(to_number(replace(replace(to_char( rec.red_base_calc_icms,'9999999999990D99'),',',''),'.','')),0) ,1,05);
         vt_tab_reg_0075(en_item_id).base_calc_icms_st  := substr( nvl(to_number(replace(replace(to_char( v_vl_base_calc_icmsst,'9999999999990D99'),',',''),'.','')),0) ,1,13);
         --
      end loop;
      --
   end pkb_cria_0075;
   --
BEGIN
   --
   vn_fase := 1;
   --
   v_aliq_ipi             := 0;
   v_aliquota             := 0;
   v_vl_base_calc_icmsst  := 0;
   --
   if nvl(en_item_id,0) > 0 then
      --
      vn_fase := 1.1;
      --
      open c_dado;
      fetch c_dado into vv_cod_item;
      close c_dado;
      --
      i := nvl(vt_tab_reg_0075.first,0);
      --
      loop
         --
         if nvl(i,0) = 0 then
            --
            pkb_cria_0075;
            --
            exit;
            --
         end if;
         --
         if trim(vt_tab_reg_0075(i).cod_produto_serv) = trim(vv_cod_item) then
            --
            exit;
            --
         end if;
         --
         if i = vt_tab_reg_0075.last then
            --
            pkb_cria_0075;
            --
            exit;
            --
         else
            --
            i := vt_tab_reg_0075.next(i);
            --
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0075 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0075;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0076 : NOTA FISCAL DE SERVICOS DE COMUNICACAO      (MOD. 21) nas prestacoes de servico
--                         NOTA FISCAL DE SERVICOS DE TELECOMUNICACOES (MOD. 22) nas prestacoes de servico
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0076 IS
   --
   vn_fase                number := 0;
   --
   v_data_emissao_receb   number;
   v_modelo               mod_fiscal.cod_mod%type;
   v_serie                nota_fiscal.serie%type;
   v_subserie             varchar2(5);
   v_numero               nota_fiscal.nro_nf%type;
   v_situacao             varchar2(01);
   --
   i                      pls_integer;
   v_cnpj                 varchar2(14);
   v_ie                   varchar2(14);
   v_uf                   varchar2(02);
   v_cnpj_cpf             varchar2(14);
   v_cfop                 number(04);
   v_existe_cfop          number(04);
   v_valor_total          number(15,2);
   v_base_calculo_icms    number(15,2);
   v_valor_icms           number(15,2);
   v_isenta_nao_tributada number(15,2);
   v_outras               number(15,2);
   v_aliquota             number(15,2);
   -- valores nao usados neste registro
   v_cod_st_icms          number;
   v_vl_base_calc_icmsst  number;
   v_vl_imp_trib_icmsst   number;
   v_vl_imp_trib_ipi      number;
   -- somatorias
   v_vl_valor_total       number(15,2);
   v_vl_tot_icms          number(15,2);
   v_tot_isenta_nao_trib  number(15,2);
   v_tot_outras           number(15,2);
   --
   cursor c_sint is
      select distinct
             (case when nf.dm_ind_emit = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 then
                       trunc(nf.dt_emiss)
                  when nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 then
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
                  else
                       trunc(nvl(nf.dt_sai_ent,nf.dt_emiss))
             end) data_emissao_receb
           , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
               end) numero
           , nf.serie                       serie
           , nf.sub_serie                   subserie
           , mf.cod_mod                     modelo
           , 2                              tipo_receita
           , decode( sdc.cd ,'00' , 'N'
                            ,'01' , 'E'
                            ,'02' , 'S'
                            ,'03' , 'X'
                            ,'04' , '2'
                            ,'05' , '4'
                            , 'N'
                            ) situacao
           , nf.pessoa_id                 pessoa_id
           , r.id nfregistanalit_id
        from nota_fiscal     nf
           , mod_fiscal      mf
           , sit_docto       sdc
           , nfregist_analit r
           , pessoa            p
           , cidade            cid
       where nf.empresa_id      = gt_row_abertura_sint.empresa_id
         and nf.dm_st_proc     in (4,7,8) -- Autorizada/cancelada/inutilizada
         and nf.dm_arm_nfe_terc = 0
         and ((nf.dm_ind_emit = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 1 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 0 and trunc(nf.dt_emiss) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin))
               or
              (nf.dm_ind_emit = 0 and nf.dm_ind_oper = 0 and gn_dm_dt_escr_dfepoe = 1 and trunc(nvl(nf.dt_sai_ent,nf.dt_emiss)) between trunc(gt_row_abertura_sint.dt_ini) and trunc(gt_row_abertura_sint.dt_fin)))
         and mf.id              = nf.modfiscal_id
         and mf.cod_mod        in ('21', '22')
         and nf.sitdocto_id     = sdc.id
         and sdc.cd            in ('00','01','02','03','04','05', '06', '07', '08')
         and r.notafiscal_id    = nf.id
         and p.id               = nf.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       order by 2 -- nro_nf
           , r.id;
   --
BEGIN
   --
   vn_fase := 1;
   --
   v_cnpj                 := null;
   v_ie                   := null;
   v_uf                   := null;
   v_cnpj_cpf             := null;
   v_cfop                 := 0;
   v_valor_total          := 0;
   v_base_calculo_icms    := 0;
   v_valor_icms           := 0;
   v_isenta_nao_tributada := 0;
   v_outras               := 0;
   v_aliquota             := 0;
   -- valores nao usados neste registro
   v_cod_st_icms          := 0;
   v_vl_base_calc_icmsst  := 0;
   v_vl_imp_trib_icmsst   := 0;
   v_vl_imp_trib_ipi      := 0;
   -- somatorias
   v_vl_valor_total       := 0;
   v_vl_tot_icms          := 0;
   v_tot_isenta_nao_trib  := 0;
   v_tot_outras           := 0;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      gn_qtde_ent := nvl(gn_qtde_ent,0) + 1;
      --
      v_data_emissao_receb := nvl(lpad(to_number(to_char(rec.data_emissao_receb,'rrrrmmdd')),8,0),0);
      v_modelo             := nvl(rec.modelo,' ');
      v_serie              := nvl(trim(rec.serie),'0');
      v_subserie           := nvl(to_char(rec.subserie),' ');
      v_numero             := nvl(rec.numero,0);
      v_situacao           := nvl(rec.situacao,' ');
      v_existe_cfop        := 0;
      --
      vn_fase := 3;
      --
      if rpad(v_serie, 3, '0') = '000' then
         v_serie := ' ';
      end if;
      --
      vn_fase := 4;
      --
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 5;
      -- busca valores do icms
      pk_csf_api.pkb_vlr_fiscal_nfsc( en_nfregistanalit_id => rec.nfregistanalit_id
                                    , sv_cod_st_icms       => v_cod_st_icms
                                    , sn_cfop              => v_cfop
                                    , sn_aliq_icms         => v_aliquota
                                    , sn_vl_operacao       => v_valor_total
                                    , sn_vl_bc_icms        => v_base_calculo_icms
                                    , sn_vl_icms           => v_valor_icms
                                    , sn_vl_bc_icmsst      => v_vl_base_calc_icmsst
                                    , sn_vl_icms_st        => v_vl_imp_trib_icmsst
                                    , sn_vl_ipi            => v_vl_imp_trib_ipi
                                    , sn_vl_bc_isenta_icms => v_isenta_nao_tributada
                                    , sn_vl_bc_outra_icms  => v_outras );
      --
      vn_fase := 6;
      --
      v_vl_valor_total      := nvl(v_vl_valor_total,0) + nvl(v_valor_total,0);
      v_vl_tot_icms         := nvl(v_vl_tot_icms,0) + nvl(v_valor_icms,0);
      v_tot_isenta_nao_trib := nvl(v_tot_isenta_nao_trib,0) + nvl(v_isenta_nao_tributada,0);
      v_tot_outras          := nvl(v_tot_outras,0) + nvl(v_outras,0);
      --
      vn_fase := 7;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 8;
      --
      vt_tab_reg_0076(i).tipo     := '76';
      vt_tab_reg_0076(i).cnpj_cpf := nvl(v_cnpj_cpf,'0');
      vt_tab_reg_0076(i).ie       := nvl(v_ie,' ');
      vt_tab_reg_0076(i).modelo   := nvl(v_modelo,0);
      vt_tab_reg_0076(i).serie    := substr(nvl(trim(to_char(v_serie)),'0'),1,2);
      --
      vn_fase := 9;
      --
      if rpad(vt_tab_reg_0076(i).serie, 3, '0') = '000' then
         vt_tab_reg_0076(i).serie := ' ';
      end if;
      --
      vn_fase := 10;
      --
      vt_tab_reg_0076(i).subserie           := substr(nvl(to_char(v_subserie),' '),1,2);
      vt_tab_reg_0076(i).numero             := nvl(v_numero,0);
      vt_tab_reg_0076(i).cfop               := nvl(v_cfop,0);
      vt_tab_reg_0076(i).tipo_receita       := nvl(rec.tipo_receita,0);
      vt_tab_reg_0076(i).data_emissao_receb := nvl(v_data_emissao_receb,0);
      vt_tab_reg_0076(i).uf                 := nvl(v_uf,' ');
      vt_tab_reg_0076(i).valor_total        := nvl(to_number(replace(replace(to_char( nvl(v_vl_valor_total,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0076(i).base_calc_icms     := nvl(to_number(replace(replace(to_char( nvl(v_base_calculo_icms,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0076(i).valor_icms         := nvl(to_number(replace(replace(to_char( nvl(v_vl_tot_icms,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0076(i).isenta_nao_tribut  := nvl(to_number(replace(replace(to_char( nvl(v_tot_isenta_nao_trib,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0076(i).outras             := nvl(to_number(replace(replace(to_char( nvl(v_tot_outras,0),'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0076(i).aliquota           := nvl(to_number(v_aliquota),0);
      vt_tab_reg_0076(i).situacao           := nvl(to_char(v_situacao),' ');
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0076 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0076;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0085 :  Informacoes de Exportacoes
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0085 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
   cursor c_sint is
      select distinct '85'                                            tipo
           , ife.nro_de                                               decl_exportacao
           , to_char(to_date(ife.dt_de ,'dd/mm/rrrr'),'rrrrmmdd')     dt_decl
           , case
                when (ife.dm_nat_exp = 0 and ife.dm_ind_doc = 0) then 1  -- Declaracao de Exportacao Direta
                when (ife.dm_nat_exp = 0 and ife.dm_ind_doc = 1) then 3  -- Declaracao de Exportacao Indireta
                when (ife.dm_nat_exp = 1 and ife.dm_ind_doc = 0) then 2  -- Declaracao Simplificada de Exportacao Direta
                when (ife.dm_nat_exp = 1 and ife.dm_ind_doc = 1) then 4  -- Declaracao Simplificada de Exportacao Indireta
             end                                                      nat_exportacao
           , ife.nro_re                                               reg_exportacao
           , to_char(to_date(ife.dt_re ,'dd/mm/rrrr'),'rrrrmmdd')     data_registro
           , ife.chc_emb                                              conhecimento_embarque
           , to_char(to_date(ife.dt_chc,'dd/mm/rrrr'),'rrrrmmdd')     dt_conhecimento
           , ife.dm_tp_chc                                            tipo_conhecimento
           , 0                                                        reservado
           , ptca.cd                                                  pais
           , to_char(to_date(ife.dt_avb,'dd/mm/rrrr'),'rrrrmmdd')     dt_averb_decl_exp
           , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
              end) nf_exportacao
           , to_char(to_date(nf.dt_emiss,'dd/mm/rrrr'),'rrrrmmdd')    dt_emissao
           , mdf.modelo                                               modelo
           , nf.serie                                                 serie
           , ' '                                                      brancos
        from infor_exportacao         ife
           , infor_export_nota_fiscal ine
           , oper_export_ind_nf       oen
           , nota_fiscal              nf
           , item_nota_fiscal         ite
           , mod_fiscal               mdf
           , pais_tipo_cod_arq        ptca
           , tipo_cod_arq             tca
           , empresa e
           , pessoa            p
           , cidade            cid
       where ife.empresa_id     = gt_row_abertura_sint.empresa_id
         and trunc(ife.dt_avb)  between trunc(gt_row_abertura_sint.dt_ini)
                                    and trunc(gt_row_abertura_sint.dt_fin)
         --and trunc(ife.dt_re)   between trunc(gt_row_abertura_sint.dt_ini)
         --                           and trunc(gt_row_abertura_sint.dt_fin)
         and ife.id             = ine.inforexportacao_id
         and ine.id             = oen.inforexportnotafiscal_id
         and ine.notafiscal_id  = nf.id
         and ite.notafiscal_id  = nf.id
         and ine.itemnf_id      = ite.id
         and nf.modfiscal_id    = mdf.id
         and ptca.pais_id       = ife.pais_id
         and ptca.tipocodarq_id = tca.id
         and tca.cd             = '18'
         and p.id               = e.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       order by ife.nro_de;
   --
BEGIN
   --
   vn_fase := 1;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 3;
      --
      vt_tab_reg_0085(i).tipo                  := nvl(rec.tipo,' ');
      vt_tab_reg_0085(i).decl_exportacao       := nvl(rec.decl_exportacao,0);
      vt_tab_reg_0085(i).dt_decl               := nvl(to_number(rec.dt_decl),0);
      vt_tab_reg_0085(i).nat_exportacao        := nvl(to_char(rec.nat_exportacao),' ');
      vt_tab_reg_0085(i).reg_exportacao        := nvl(rec.reg_exportacao,0);
      vt_tab_reg_0085(i).data_registro         := nvl(to_number(rec.data_registro),0);
      vt_tab_reg_0085(i).conhecimento_embarque := nvl(rec.conhecimento_embarque,' ');
      vt_tab_reg_0085(i).dt_conhecimento       := nvl(to_number(rec.dt_conhecimento),0);
      vt_tab_reg_0085(i).tipo_conhecimento     := nvl(to_number(rec.tipo_conhecimento),0);
      vt_tab_reg_0085(i).pais                  := nvl(rec.pais,0);
      vt_tab_reg_0085(i).reservado             := nvl(rec.reservado,0);
      vt_tab_reg_0085(i).dt_averb_decl_exp     := nvl(to_number(rec.dt_averb_decl_exp),0);
      vt_tab_reg_0085(i).nf_exportacao         := nvl(rec.nf_exportacao,0);
      vt_tab_reg_0085(i).dt_emissao            := nvl(to_number(rec.dt_emissao),0);
      vt_tab_reg_0085(i).modelo                := nvl(rec.modelo,0);
      vt_tab_reg_0085(i).serie                 := nvl(trim(rec.serie),0);
      --
      vn_fase := 4;
      --
      if rpad(vt_tab_reg_0085(i).serie, 3, '0') = '000' then
         vt_tab_reg_0085(i).serie := ' ';
      end if;
      --
      vn_fase := 5;
      --
      vt_tab_reg_0085(i).brancos := nvl(rec.brancos,' ');
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0085 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0085;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0086 : Informações Complementares de Exportações
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0086 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   v_cnpj   varchar2(14);
   v_ie     varchar2(14);
   v_uf     varchar2(02);
   --
   cursor c_sint is
      select distinct '86'                                                        tipo
           , ife.nro_re                                                           reg_exportacao
           , to_char(to_date(ife.dt_re ,'dd/mm/rrrr'),'rrrrmmdd')                 dt_registro
           , (case when length(nf.nro_nf) >= 6 then substr(nf.nro_nf, -6,6)
                   when length(nf.nro_nf) < 6  then substr(nf.nro_nf, -length(nf.nro_nf),6)
               end) numero_nf
           , to_char(to_date(nf.dt_emiss,'dd/mm/rrrr'),'rrrrmmdd')                dt_emissao
           , mdf.modelo                                                           modelo
           , nf.serie                                                             serie
           , substr(ite.cod_item,1,14)                                            cod_produto
           , oen.qtd                                                              quantidade
           , ite.vl_unit_comerc                                                   vl_unit_prod
           , (nvl(ite.vl_unit_comerc,0) * nvl(oen.qtd,0)  )                       vl_prod
           , 0                                                                    relacionamento
           , ' '                                                                  brancos
           , nf.pessoa_id                                                         pessoa_id
        from infor_exportacao         ife
           , infor_export_nota_fiscal ine
           , oper_export_ind_nf       oen
           , nota_fiscal              nf
           , item_nota_fiscal         ite
           , mod_fiscal               mdf
           , empresa e
           , pessoa            p
           , cidade            cid
       where ife.empresa_id    = gt_row_abertura_sint.empresa_id
         and trunc(ife.dt_re)  between trunc(gt_row_abertura_sint.dt_ini)
                                   and trunc(gt_row_abertura_sint.dt_fin)
         and ife.id            = ine.inforexportacao_id
         and ine.id            = oen.inforexportnotafiscal_id
         and ine.notafiscal_id = nf.id
         and ite.notafiscal_id = nf.id
         and ine.itemnf_id     = ite.id
         and nf.modfiscal_id   = mdf.id
         and p.id               = e.pessoa_id
         and cid.id             = p.cidade_id
         and cid.estado_id      = nvl(gn_estado_id, cid.estado_id)
       order by ife.nro_re;
   --
BEGIN
   --
   vn_fase := 1;
   v_cnpj  := null;
   v_ie    := null;
   v_uf    := null;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or(c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      pkb_recup_dados_pessoa( en_pessoa_id => rec.pessoa_id
                            , sv_cpf_cnpj  => v_cnpj
                            , sv_ie        => v_ie
                            , sv_uf        => v_uf );
      --
      vn_fase := 3;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 4;
      --
      vt_tab_reg_0086(i).tipo           := nvl(rec.tipo,' ');
      vt_tab_reg_0086(i).reg_exportacao := nvl(rec.reg_exportacao,0);
      vt_tab_reg_0086(i).dt_registro    := nvl(to_number(rec.dt_registro),0);
      vt_tab_reg_0086(i).cnpj_remetente := nvl(v_cnpj,'0');
      vt_tab_reg_0086(i).ie_remetente   := nvl(v_ie,' ');
      vt_tab_reg_0086(i).uf             := nvl(v_uf,' ');
      vt_tab_reg_0086(i).numero_nf      := nvl(rec.numero_nf,0);
      vt_tab_reg_0086(i).dt_emissao     := nvl(to_number(rec.dt_emissao),0);
      vt_tab_reg_0086(i).modelo         := nvl(rec.modelo,0);
      vt_tab_reg_0086(i).serie          := nvl(trim(rec.serie),'0');
      --
      vn_fase := 5;
      --
      if rpad(vt_tab_reg_0086(i).serie, 3, '0') = '000' then
         vt_tab_reg_0086(i).serie := ' ';
      end if;
      --
      vn_fase := 6;
      --
      vt_tab_reg_0086(i).cod_produto    := nvl(rec.cod_produto,' ');
      vt_tab_reg_0086(i).quantidade     := nvl(to_number(replace(replace(to_char( rec.quantidade,'9999999999990D999'),',',''),'.','')),0);
      vt_tab_reg_0086(i).vl_unit_prod   := nvl(to_number(replace(replace(to_char( rec.vl_unit_prod,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0086(i).vl_prod        := nvl(to_number(replace(replace(to_char( rec.vl_prod,'9999999999990D99'),',',''),'.','')),0);
      vt_tab_reg_0086(i).relacionamento := nvl(rec.relacionamento,0);
      vt_tab_reg_0086(i).brancos        := nvl(rec.brancos,' ');
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0086 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0086;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0088 (SME): INFORMAÇÃO SOBRE MÊS SEM MOVIMENTO DE ENTRADAS
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0088_SME IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   v_cnpj   varchar2(14);
   v_ie     varchar2(14);
   v_uf     varchar2(02);
   --
BEGIN
   --
   vn_fase := 1;
   v_cnpj  := null;
   v_ie    := null;
   v_uf    := null;
   --
   begin
      select (lpad(j.num_cnpj,8,'0')||lpad(j.num_filial,4,'0')||lpad(j.dig_cnpj,2,'0'))
           , j.ie
           , est.sigla_estado
        into v_cnpj
           , v_ie
           , v_uf
        from empresa  e
           , pessoa   p
           , cidade   cid
           , estado   est
           , juridica j
       where e.id        = gt_row_abertura_sint.empresa_id
         and p.id        = e.pessoa_id
         and cid.id      = p.cidade_id
         and est.id      = cid.estado_id
         and j.pessoa_id = p.id;
   exception
      when others then
         v_cnpj := null;
         v_ie   := null;
         v_uf   := null;
   end;
   --
   vn_fase := 2;
   --
   if trim(v_uf) not in ('MS', 'MT') then
      return;
   end if;
   --
   vn_fase := 3;
   --
   if nvl(gn_qtde_ent,0) > 0 then
      return;
   end if;
   --
   vn_fase := 4;
   --
   i := 1;
   --
   vt_tab_reg_0088_sme(i).tipo     := '88';
   vt_tab_reg_0088_sme(i).subtipo  := 'SME';
   vt_tab_reg_0088_sme(i).cnpj     := v_cnpj;
   vt_tab_reg_0088_sme(i).ie       := v_ie;
   vt_tab_reg_0088_sme(i).mensagem := 'Sem movimento de entradas';
   vt_tab_reg_0088_sme(i).branco   := ' ';
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0088_sme fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0088_SME;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0088 (SMS): INFORMAÇÃO SOBRE MÊS SEM MOVIMENTO DE SAÍDAS
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0088_SMS IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   v_cnpj   varchar2(14);
   v_ie     varchar2(14);
   v_uf     varchar2(02);
   --
BEGIN
   --
   vn_fase := 1;
   v_cnpj  := null;
   v_ie    := null;
   v_uf    := null;
   --
   begin
      select (lpad(j.num_cnpj,8,'0')||lpad(j.num_filial,4,'0')||lpad(j.dig_cnpj,2,'0'))
           , j.ie
           , est.sigla_estado
        into v_cnpj
           , v_ie
           , v_uf
        from empresa  e
           , pessoa   p
           , cidade   cid
           , estado   est
           , juridica j
       where e.id        = gt_row_abertura_sint.empresa_id
         and p.id        = e.pessoa_id
         and cid.id      = p.cidade_id
         and est.id      = cid.estado_id
         and j.pessoa_id = p.id;
   exception
      when others then
         v_cnpj := null;
         v_ie   := null;
         v_uf   := null;
   end;
   --
   vn_fase := 2;
   --
   if trim(v_uf) not in ('MS', 'MT') then
      return;
   end if;
   --
   vn_fase := 3;
   --
   if nvl(gn_qtde_sai,0) > 0 then
      return;
   end if;
   --
   vn_fase := 4;
   --
   i := 1;
   --
   vt_tab_reg_0088_sms(i).tipo     := '88';
   vt_tab_reg_0088_sms(i).subtipo  := 'SMS';
   vt_tab_reg_0088_sms(i).cnpj     := v_cnpj;
   vt_tab_reg_0088_sms(i).ie       := v_ie;
   vt_tab_reg_0088_sms(i).mensagem := 'Sem movimento de saidas';
   vt_tab_reg_0088_sms(i).branco   := ' ';
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0088_sms fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0088_SMS;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0088 (EC): Informação sobre dados do contabilista do contribuinte
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0088_EC IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   v_uf     varchar2(02);
   --
BEGIN
   --
   vn_fase := 1;
   v_uf    := null;
   --
   begin
      select est.sigla_estado
        into v_uf
        from empresa  e
           , pessoa   p
           , cidade   cid
           , estado   est
           , juridica j
       where e.id        = gt_row_abertura_sint.empresa_id
         and p.id        = e.pessoa_id
         and cid.id      = p.cidade_id
         and est.id      = cid.estado_id
         and j.pessoa_id = p.id;
   exception
      when others then
         v_uf := null;
   end;
   --
   vn_fase := 2;
   --
   if trim(v_uf) not in ('MS', 'MT') then
      return;
   end if;
   --
   vn_fase := 3;
   --
   i := 1;
   --
   vt_tab_reg_0088_ec(i).tipo    := '88';
   vt_tab_reg_0088_ec(i).subtipo := 'EC';
   --
   vn_fase := 4;
   --
   begin
      select p.nome
           , (lpad(f.num_cpf,9,'0')||lpad(f.dig_cpf,2,'0'))
           , trim(replace(replace(replace(replace(c.crc, '/', ''), '\', ''), '-', ''), '.', ''))
        into vt_tab_reg_0088_ec(i).nome
           , vt_tab_reg_0088_ec(i).cpf
           , vt_tab_reg_0088_ec(i).crc
        from contador_empresa ce
           , contador         c
           , pessoa           p
           , fisica           f
       where ce.empresa_id  = gt_row_abertura_sint.empresa_id
         and ce.dm_situacao = 1
         and c.id           = ce.contador_id
         and p.id           = c.pessoa_id
         and f.pessoa_id    = p.id
         and rownum         = 1;
   exception
      when others then
         vt_tab_reg_0088_ec(i).nome := ' ';
         vt_tab_reg_0088_ec(i).cpf  := 0;
         vt_tab_reg_0088_ec(i).crc  := ' ';
   end;
   --
   vn_fase := 5;
   --
   vt_tab_reg_0088_ec(i).fone      := 0;
   vt_tab_reg_0088_ec(i).email     := ' ';
   vt_tab_reg_0088_ec(i).dm_altera := 1; -- Não
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0088_ec fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0088_EC;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0088 (SF): Informação sobre dados da empresa/do técnico produtor do software
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0088_SF IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   v_uf     varchar2(02);
   --
BEGIN
   --
   vn_fase := 1;
   v_uf    := null;
   --
   begin
      select est.sigla_estado
        into v_uf
        from empresa  e
           , pessoa   p
           , cidade   cid
           , estado   est
           , juridica j
       where e.id        = gt_row_abertura_sint.empresa_id
         and p.id        = e.pessoa_id
         and cid.id      = p.cidade_id
         and est.id      = cid.estado_id
         and j.pessoa_id = p.id;
   exception
      when others then
         v_uf := null;
   end;
   --
   vn_fase := 2;
   --
   if trim(v_uf) not in ('MS', 'MT') then
      return;
   end if;
   --
   vn_fase := 3;
   --
   i := 1;
   --
   vt_tab_reg_0088_sf(i).tipo      := '88';
   vt_tab_reg_0088_sf(i).subtipo   := 'SF';
   vt_tab_reg_0088_sf(i).nome_empr := 'COMPLIANCE IT INFORMATICA LTDA';
   vt_tab_reg_0088_sf(i).cnpj_empr := '10586963000172';
   vt_tab_reg_0088_sf(i).cpf_tec   := '22263505865';
   vt_tab_reg_0088_sf(i).fone      := 1630138467;
   vt_tab_reg_0088_sf(i).email     := 'cliente@compliancefiscal.com.br';
   vt_tab_reg_0088_sf(i).dm_altera := 1; -- Não
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0088_sf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0088_SF;

-------------------------------------------------------------------------------------------------------
-- monta o REGISTRO 0090 : totalizacao do arquivo
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_REG_0090 IS
   --
   vn_fase             number := 0;
   i                   pls_integer;
   --
   vn_qtde_reg_0050    number := 0;
   vn_qtde_reg_0051    number := 0;
   vn_qtde_reg_0053    number := 0;
   vn_qtde_reg_0054    number := 0;
   vn_qtde_reg_0055    number := 0;
   vn_qtde_reg_0056    number := 0;
   vn_qtde_reg_0057    number := 0;
   vn_qtde_reg_0060    number := 0;
   --
   vn_qtde_reg_0060m   number := 0;
   vn_qtde_reg_0060a   number := 0;
   vn_qtde_reg_0060d   number := 0;
   vn_qtde_reg_0060i   number := 0;
   vn_qtde_reg_0060r   number := 0;
   --
   vn_qtde_reg_0061    number := 0;
   vn_qtde_reg_0070    number := 0;
   vn_qtde_reg_0071    number := 0;
   vn_qtde_reg_0074    number := 0;
   vn_qtde_reg_0075    number := 0;
   vn_qtde_reg_0076    number := 0;
   vn_qtde_reg_0077    number := 0;
   vn_qtde_reg_0085    number := 0;
   vn_qtde_reg_0086    number := 0;
   vn_qtde_reg_0088    number := 0;
   --
   vn_qtde_reg_0060_v  number := 0;
   vn_qtde_reg_0061_v  number := 0;
   vn_qtde_geral       number := 0;
   --
   vv_0090_tp_total   varchar2(2000) := null;
   vn_num_reg_tipo_90 number;
   -- cursor recupera dados empresa
   cursor c_sint is
      select '90'   tipo
           , lpad(jur.num_cnpj,8,0)||lpad(jur.num_filial,4,0)||lpad(jur.dig_cnpj,2,0) cgc_mf
           , jur.ie ie
        from pessoa            pes
           , juridica          jur
           , empresa           emp
           , abertura_sintegra sint
       where sint.id       = gt_row_abertura_sint.id
         and pes.id        = jur.pessoa_id
         and jur.pessoa_id = emp.pessoa_id
         and emp.id        = sint.empresa_id;
   --
BEGIN
   --
   vn_fase := 1;
   vt_tab_reg_0090.delete;
   --
   i := 0;
   --
   for rec in c_sint
   loop
      --
      exit when c_sint%notfound or (c_sint%notfound) is null;
      --
      vn_fase := 2;
      --
      i := nvl(i,0) + 1;
      --
      vn_fase := 3;
      -- recupera qtds de registros de cada tipo de arquivo
      vn_qtde_reg_0060m := fkg_qtde_linha_reg_0060M;
      vn_qtde_reg_0060a := fkg_qtde_linha_reg_0060A;
      vn_qtde_reg_0060d := fkg_qtde_linha_reg_0060D;
      vn_qtde_reg_0060i := fkg_qtde_linha_reg_0060I;
      vn_qtde_reg_0060r := fkg_qtde_linha_reg_0060R;
      --
      vn_fase := 4;
      --
      vn_qtde_reg_0060_v := nvl(fkg_qtde_linha_reg_0060M,0) +
                            nvl(fkg_qtde_linha_reg_0060A,0) +
                            nvl(fkg_qtde_linha_reg_0060D,0) +
                            nvl(fkg_qtde_linha_reg_0060I,0) +
                            nvl(fkg_qtde_linha_reg_0060R,0);
      --
      vn_fase := 5;
      --
      vn_qtde_reg_0061_v := nvl(fkg_qtde_linha_reg_0061 ,0) +
                            nvl(fkg_qtde_linha_reg_0061R,0);
      --
      vn_fase := 6;
      --
      vv_0090_tp_total := null;
      --
      vn_fase := 7;
      vn_qtde_reg_0050 := nvl(fkg_qtde_linha_reg_0050,0);
      if nvl(vn_qtde_reg_0050,0) > 0 then
         vv_0090_tp_total := '50' || lpad( nvl(vn_qtde_reg_0050,0),8,0);
      end if;
      --
      vn_fase := 8;
      vn_qtde_reg_0051 := nvl(fkg_qtde_linha_reg_0051,0);
      if nvl(vn_qtde_reg_0051,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '51' || lpad( nvl(vn_qtde_reg_0051,0),8,0);
      end if;
      --
      vn_fase := 9;
      vn_qtde_reg_0053 := nvl(fkg_qtde_linha_reg_0053,0);
      if nvl(vn_qtde_reg_0053,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '53' || lpad( nvl(vn_qtde_reg_0053,0),8,0);
      end if;
      --
      vn_fase := 10;
      vn_qtde_reg_0054 := nvl(fkg_qtde_linha_reg_0054,0);
      if nvl(vn_qtde_reg_0054,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '54' || lpad( nvl(vn_qtde_reg_0054,0),8,0);
      end if;
      --
      vn_fase := 11;
      vn_qtde_reg_0055 := nvl(fkg_qtde_linha_reg_0055,0);
      if nvl(vn_qtde_reg_0055,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '55' || lpad( nvl(vn_qtde_reg_0055,0),8,0);
      end if;
      --
      vn_fase := 12;
      vn_qtde_reg_0056 := nvl(fkg_qtde_linha_reg_0056,0);
      if nvl(vn_qtde_reg_0056,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '56' || lpad( nvl(vn_qtde_reg_0056,0),8,0);
      end if;
      --
      vn_fase := 13;
      vn_qtde_reg_0057 := nvl(fkg_qtde_linha_reg_0057,0);
      if nvl(vn_qtde_reg_0057,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '57' || lpad( nvl(vn_qtde_reg_0057,0),8,0);
      end if;
      --
      vn_fase := 14;
      vn_qtde_reg_0060 := nvl(vn_qtde_reg_0060_v,0);
      if nvl(vn_qtde_reg_0060,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '60' || lpad( nvl(vn_qtde_reg_0060,0),8,0);
      end if;
      --
      vn_fase := 15;
      vn_qtde_reg_0061 := nvl(vn_qtde_reg_0061_v,0);
      if nvl(vn_qtde_reg_0061,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '61' || lpad( nvl(vn_qtde_reg_0061,0),8,0);
      end if;
      --
      vn_fase := 16;
      --
      vn_num_reg_tipo_90 := 0;
      --
      if trim(vv_0090_tp_total) is not null then
         -- grava arquivo
         vn_fase := 16.1;
         --
         vn_num_reg_tipo_90 := nvl(vn_num_reg_tipo_90,0) + 1;
         vn_qtde_geral      := nvl(vn_qtde_geral,0) + 1;
         --
         vt_tab_reg_0090(1).tipo            := rec.tipo;
         vt_tab_reg_0090(1).cgc_mf          := lpad(substr(rec.cgc_mf,1 ,14),14,0);
         vt_tab_reg_0090(1).ie              := rpad(substr(rec.ie,1 ,14),14,' ');
         vt_tab_reg_0090(1).total           := rpad(vv_0090_tp_total,95,' ');
         -- Esse valor será alterado/atualizado no final do processo, pois deve conter o total de registros 90 em todas as linhas de registro 90.
         vt_tab_reg_0090(1).num_reg_tipo_90 := vn_num_reg_tipo_90;
         --
      end if;
      --
      vn_fase := 17;
      --
      vv_0090_tp_total := null;
      --
      vn_fase := 18;
      vn_qtde_reg_0070 := nvl(fkg_qtde_linha_reg_0070,0);
      if nvl(vn_qtde_reg_0070,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '70' || lpad( nvl(vn_qtde_reg_0070,0),8,0);
      end if;
      --
      vn_fase := 19;
      vn_qtde_reg_0071 := nvl(fkg_qtde_linha_reg_0071,0);
      if nvl(vn_qtde_reg_0071,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '71' || lpad( nvl(vn_qtde_reg_0071,0),8,0);
      end if;
      --
      vn_fase := 20;
      vn_qtde_reg_0074 := nvl(fkg_qtde_linha_reg_0074,0);
      if nvl(vn_qtde_reg_0074,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '74' || lpad( nvl(vn_qtde_reg_0074,0),8,0);
      end if;
      --
      vn_fase := 21;
      vn_qtde_reg_0075 := nvl(fkg_qtde_linha_reg_0075,0);
      if nvl(vn_qtde_reg_0075,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '75' || lpad( nvl(vn_qtde_reg_0075,0),8,0);
      end if;
      --
      vn_fase := 22;
      vn_qtde_reg_0076 := nvl(fkg_qtde_linha_reg_0076,0);
      if nvl(vn_qtde_reg_0076,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '76' || lpad( nvl(vn_qtde_reg_0076,0),8,0);
      end if;
      --
      vn_fase := 23;
      vn_qtde_reg_0077 := nvl(fkg_qtde_linha_reg_0077,0);
      if nvl(vn_qtde_reg_0077,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '77' || lpad( nvl(vn_qtde_reg_0077,0),8,0);
      end if;
      --
      vn_fase := 24;
      vn_qtde_reg_0085 := nvl(fkg_qtde_linha_reg_0085,0);
      if nvl(vn_qtde_reg_0085,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '85' || lpad( nvl(vn_qtde_reg_0085,0),8,0);
      end if;
      --
      vn_fase := 25;
      vn_qtde_reg_0086 := nvl(fkg_qtde_linha_reg_0086,0);
      if nvl(vn_qtde_reg_0086,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '86' || lpad( nvl(vn_qtde_reg_0086,0),8,0);
      end if;
      --
      vn_fase := 26;
      vn_qtde_reg_0088 := nvl(fkg_qtde_linha_reg_0088,0);
      --
      vn_fase := 27;
      if nvl(vn_qtde_reg_0088,0) > 0 then
         vv_0090_tp_total := vv_0090_tp_total || '88' || lpad( nvl(vn_qtde_reg_0088,0),8,0);
      end if;
      --
      vn_fase := 28;
      vn_qtde_geral := nvl(vn_qtde_geral,0) + nvl(vt_tab_reg_0010.count,0) + nvl(vt_tab_reg_0011.count,0) +
                       nvl(vn_qtde_reg_0050,0) + nvl(vn_qtde_reg_0051,0) + nvl(vn_qtde_reg_0053,0) + nvl(vn_qtde_reg_0054,0) + nvl(vn_qtde_reg_0056,0) +
                       nvl(vn_qtde_reg_0057,0) + nvl(vn_qtde_reg_0060,0) + nvl(vn_qtde_reg_0070,0) + nvl(vn_qtde_reg_0074,0) + nvl(vn_qtde_reg_0075,0) +
                       nvl(vn_qtde_reg_0076,0) + nvl(vn_qtde_reg_0085,0) + nvl(vn_qtde_reg_0086,0) + nvl(vn_qtde_reg_0088,0);
      --
      vn_fase := 29;
      --
      if nvl(vn_qtde_geral,0) > 0 then
         --
         vn_qtde_geral    := nvl(vn_qtde_geral,0) + 1;
         vv_0090_tp_total := vv_0090_tp_total || '99' || lpad(nvl(vn_qtde_geral,0),8,0);
         --
      end if;
      --
      vn_fase := 30;
      vn_num_reg_tipo_90 := nvl(vn_num_reg_tipo_90,0) + 1;
      -- grava arquivo
      vt_tab_reg_0090(2).tipo            := rec.tipo;
      vt_tab_reg_0090(2).cgc_mf          := lpad(substr(rec.cgc_mf,1 ,14),14,0);
      vt_tab_reg_0090(2).ie              := rpad(substr(trim(rec.ie),1 ,14),14,' ');
      vt_tab_reg_0090(2).total           := rpad(vv_0090_tp_total,95, ' ');
      vt_tab_reg_0090(2).num_reg_tipo_90 := vn_num_reg_tipo_90;
      --
      -- Esse valor é atualizado no final do processo, pois deve conter o total de registros 90 em todas as linhas de registro 90.
      vt_tab_reg_0090(1).num_reg_tipo_90 := vn_num_reg_tipo_90;
      --
      vn_fase := 31;
      vv_0090_tp_total := null;
      --
   end loop;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_reg_0090 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_REG_0090;

------------------------------------------------------------------------------------
-- Procedimento grava as informações da estrutura do arquivo do Sintegra
------------------------------------------------------------------------------------
PROCEDURE PKB_GRAVA_ESTR_ARQ_SINT IS
   --
   vn_fase  number := 0;
   pragma   autonomous_transaction;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_estr_arq_sintegra.count,0) > 0 then
      --
      vn_fase := 2;
      --
      forAll i in 1 .. vt_estr_arq_sintegra.count
         insert into estr_arq_sintegra values vt_estr_arq_sintegra(i);
      --
      vn_fase := 3;
      --
      commit;
      --
   end if;
   --
EXCEPTION
   when others then
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_grava_estr_arq_sint fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_GRAVA_ESTR_ARQ_SINT;

-------------------------------------------------------------------------------------------------------
-- Procedimento que armazena a estrutura do arquivo da Sintegra em um array
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_ESTR_ARQ_SINT ( EV_REG_BLC   IN REGISTRO_SINTEGRA.CD%TYPE
                                  , EL_CONTEUDO  IN ESTR_ARQ_SINTEGRA.CONTEUDO%TYPE ) IS
   --
   vn_fase    number := 0;
   vn_indice  number := 0;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if ev_reg_blc is not null and el_conteudo is not null then
      --
      vn_fase := 2;
      vn_indice := nvl(vt_estr_arq_sintegra.count,0) + 1;
      vn_fase := 3;
      --
      select estrarqsintegra_seq.nextval
        into vt_estr_arq_sintegra(vn_indice).id
        from dual;
      --
      vn_fase := 4;
      vt_estr_arq_sintegra(vn_indice).aberturasintegra_id := gt_row_abertura_sint.id;
      vt_estr_arq_sintegra(vn_indice).registrosintegra_id := fkg_registro_sint_id( ev_cd => ev_reg_blc );
      vt_estr_arq_sintegra(vn_indice).sequencia           := vn_indice;
      vt_estr_arq_sintegra(vn_indice).conteudo            := el_conteudo || final_de_linha;
      vt_estr_arq_sintegra(vn_indice).estado_id           := gn_estado_id;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_estr_arq_sint fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );

      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_ESTR_ARQ_SINT;

-------------------------------------------------------------------------------------------------------
-- procedimento monta estrutura do arquivo do SINTEGRA
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_MONTA_ESTR_ARQ_SINT IS
   --
   vn_fase  number := 0;
   --
BEGIN
   -- Armazena em arquivo dados
   vn_fase := 1;
   pkb_armaz_reg_0010;
   --
   vn_fase := 2;
   pkb_armaz_reg_0011;
   --
   vn_fase := 3;
   pkb_armaz_reg_0050;
   --
   vn_fase := 4;
   pkb_armaz_reg_0051;
   --
   vn_fase := 5;
   pkb_armaz_reg_0053;
   --
   vn_fase := 6;
   pkb_armaz_reg_0054;
   --
   vn_fase := 7;
   pkb_armaz_reg_0056;
   --
   vn_fase := 8;
   pkb_armaz_reg_0057;
   --
   vn_fase := 9;
   pkb_armaz_reg_0060M;
   --
   vn_fase := 10;
   pkb_armaz_reg_0060R;
   --
   vn_fase := 11;
   pkb_armaz_reg_0070;
   --
   vn_fase := 12;
   pkb_armaz_reg_0074;
   --
   vn_fase := 13;
   pkb_armaz_reg_0075;
   --
   vn_fase := 14;
   pkb_armaz_reg_0076;
   --
   vn_fase := 15;
   pkb_armaz_reg_0085;
   --
   vn_fase := 16;
   pkb_armaz_reg_0086;
   --
   vn_fase := 17;
   pkb_armaz_reg_0088_01;
   --
   vn_fase := 18;
   pkb_armaz_reg_0088_02;
   --
   vn_fase := 19;
   pkb_armaz_reg_0088_cf;
   --
   vn_fase := 20;
   pkb_armaz_reg_0088_it;
   --
   vn_fase := 21;
   pkb_armaz_reg_0088_sme;
   --
   vn_fase := 22;
   pkb_armaz_reg_0088_sms;
   --
   vn_fase := 23;
   pkb_armaz_reg_0088_ec;
   --
   vn_fase := 24;
   pkb_armaz_reg_0088_sf;
   --
   vn_fase := 25;
   pkb_armaz_reg_0090;
   -----------------------------------------------------------
   -- grava as informações da estrutura do arquivo do Sintegra
   -----------------------------------------------------------
   vn_fase := 26;
   pkb_grava_estr_arq_sint;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_monta_estr_arq_sint fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_MONTA_ESTR_ARQ_SINT;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0010: ABERTURA DO ARQUIVO DIGITAL E IDENTIFICAÇÃO DA ENTIDADE
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0010 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0010.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0010.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase     := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0010(i).tipo;
         gl_conteudo := gl_conteudo || lpad(substr( vt_tab_reg_0010(i).cnpj,1,14),14,0 );
         gl_conteudo := gl_conteudo || rpad(substr( vt_tab_reg_0010(i).ie,1,14),14,' ');
         gl_conteudo := gl_conteudo || rpad(substr( vt_tab_reg_0010(i).nome_contrib,1,35),35,' ');
         gl_conteudo := gl_conteudo || rpad(substr( vt_tab_reg_0010(i).nome_mun,1,30),30,' ');
         gl_conteudo := gl_conteudo || rpad(substr( vt_tab_reg_0010(i).uf,1,02),02,' ');
         gl_conteudo := gl_conteudo || rpad(substr( vt_tab_reg_0010(i).fax,1,10),10,0);
         gl_conteudo := gl_conteudo || lpad( vt_tab_reg_0010(i).dt_ini,8,0);
         gl_conteudo := gl_conteudo || lpad( vt_tab_reg_0010(i).dt_fin,8,0);
         gl_conteudo := gl_conteudo || lpad(substr( vt_tab_reg_0010(i).dm_ident_conv,1,01),01,' ');
         gl_conteudo := gl_conteudo || lpad(substr( vt_tab_reg_0010(i).dm_ident_nat,1,01),01,' ');
         gl_conteudo := gl_conteudo || lpad(substr( vt_tab_reg_0010(i).dm_fin_arq,1,01),01,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '10' -- '0010'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0010.last then
            exit;
         else
            i := vt_tab_reg_0010.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0010 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0010;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0011:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0011 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0011.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0011.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase     := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0011(i).tipo;
         gl_conteudo := gl_conteudo || rpad(substr( vt_tab_reg_0011(i).logradouro,1,34),34,' ');
         gl_conteudo := gl_conteudo || lpad(substr( vt_tab_reg_0011(i).numero,1,05),05,0);
         gl_conteudo := gl_conteudo || rpad(substr( vt_tab_reg_0011(i).complemento,1,22),22,' ');
         gl_conteudo := gl_conteudo || rpad(substr( vt_tab_reg_0011(i).bairro,1,15),15,' ');
         gl_conteudo := gl_conteudo || lpad(substr( vt_tab_reg_0011(i).cep,1,08),08,0);
         gl_conteudo := gl_conteudo || rpad(substr( vt_tab_reg_0011(i).nome_contato,1,28),28,' ');
         gl_conteudo := gl_conteudo || lpad(substr( vt_tab_reg_0011(i).telefone,1,12),12,0);
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '11' -- '0011'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0011.last then
            exit;
         else
            i := vt_tab_reg_0011.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0011 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0011;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0050:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0050 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   j        pls_integer;
   k        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tri_tab_reg_0050.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(nvl(vt_tri_tab_reg_0050.first,0), -1);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,-1) = -1 then
            exit;
         end if;
         --
         j := nvl(vt_tri_tab_reg_0050(i).first, -1);
         --
         vn_fase := 5;
         --
         loop
            --
            vn_fase := 6;
            --
            if nvl(j,-1) = -1 then
               exit;
            end if;
            --
            vn_fase := 7;
            k := nvl(vt_tri_tab_reg_0050(i)(j).first, -1);
            --
            loop
               --
               vn_fase := 8;
               --
               if nvl(k,-1) = -1 then
                  exit;
               end if;
               --
               vn_fase := 9;
               --
               gl_conteudo := null;
               gl_conteudo := gl_conteudo || vt_tri_tab_reg_0050(i)(j)(k).tipo;
               gl_conteudo := gl_conteudo || lpad(substr(vt_tri_tab_reg_0050(i)(j)(k).cnpj,1,14 ),14,0);
               gl_conteudo := gl_conteudo || rpad(substr(vt_tri_tab_reg_0050(i)(j)(k).ie,1,14),14,' ');
               gl_conteudo := gl_conteudo || lpad( vt_tri_tab_reg_0050(i)(j)(k).dt_emis_receb,8,0);
               gl_conteudo := gl_conteudo || rpad(substr(vt_tri_tab_reg_0050(i)(j)(k).uf,1,2),2,' ');
               gl_conteudo := gl_conteudo || lpad(substr(vt_tri_tab_reg_0050(i)(j)(k).modelo,1,2),2,0);
               gl_conteudo := gl_conteudo || rpad(substr(vt_tri_tab_reg_0050(i)(j)(k).serie,1,3),3,' ');
               gl_conteudo := gl_conteudo || lpad(substr(vt_tri_tab_reg_0050(i)(j)(k).numero,1,6),6,0);
               --
               -- Caso cfop seja 0(zero) ou nulo, entrar com cfop fixo (5102)     #73294
               if nvl(substr(vt_tri_tab_reg_0050(i)(j)(k).cfop, 1, 4), 0) = 0 then
                 gl_conteudo := gl_conteudo || lpad(5102, 4, 0);
               else
                 gl_conteudo := gl_conteudo || lpad(substr(vt_tri_tab_reg_0050(i)(j)(k).cfop, 1, 4), 4, 0);
               end if;
               --
               gl_conteudo := gl_conteudo || rpad(substr(vt_tri_tab_reg_0050(i)(j)(k).emitente,1,1),1,' ');
               --
               -- Zerar valores para as NFs Inutilizadas #72485
               if nvl(substr(vt_tri_tab_reg_0050(i)(j)(k).situacao, 1, 1), 0) = '4' then
                 gl_conteudo := gl_conteudo || lpad(0, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(0, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(0, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(0, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(0, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(0, 4, 0);
               else
                 gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0050(i)(j)(k).valor_total, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0050(i)(j)(k).base_calculo_icms, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0050(i)(j)(k).valor_icms, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0050(i)(j)(k).isenta_nao_tributada, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0050(i)(j)(k).outras, 13, 0);
                 gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0050(i)(j)(k).aliquota, 4, 0);
               end if;
               --
               gl_conteudo := gl_conteudo || lpad(substr(vt_tri_tab_reg_0050(i)(j)(k).situacao,1,1),1,' ');
               --
               vn_fase := 10;
               --
               pkb_armaz_estr_arq_sint( ev_reg_blc  => '50' -- '0050'
                                      , el_conteudo => gl_conteudo );
               --
               vn_fase := 11;
               --
               if k = vt_tri_tab_reg_0050(i)(j).last then
                  exit;
               else
                  k := vt_tri_tab_reg_0050(i)(j).next(k);
               end if;
               --
            end loop;
            --
            vn_fase := 12;
            --
            if j = vt_tri_tab_reg_0050(i).last then
               exit;
            else
               j := vt_tri_tab_reg_0050(i).next(j);
            end if;
            --
         end loop;
         --
         vn_fase := 13;
         --
         if i = vt_tri_tab_reg_0050.last then
            exit;
         else
            i := vt_tri_tab_reg_0050.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0050 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0050;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0051:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0051 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0051.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0051.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0051(i).tipo;
         gl_conteudo := gl_conteudo || lpad(substr(nvl(vt_tab_reg_0051(i).cnpj,0),1,14),14,0);
         gl_conteudo := gl_conteudo || rpad(substr(nvl(vt_tab_reg_0051(i).ie,' '),1,14),14,' ');
         --
         if vt_tab_reg_0051(i).dt_emis_receb is null then
            gl_conteudo := gl_conteudo || '        '; -- preencher com 8 espaços
         else
            gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0051(i).dt_emis_receb,8,0);
         end if;
         --
         gl_conteudo := gl_conteudo || rpad(substr(nvl(vt_tab_reg_0051(i).uf,' '),1,2),2,' ');
         gl_conteudo := gl_conteudo || rpad(substr(nvl(vt_tab_reg_0051(i).serie,' '),1,3),3,' ');
         gl_conteudo := gl_conteudo || lpad(substr(nvl(vt_tab_reg_0051(i).numero,0),1,6),6,0);
         gl_conteudo := gl_conteudo || lpad(substr(nvl(vt_tab_reg_0051(i).cfop,0),1,4),4,0);
         --
         -- Zerar valores para as NFs Inutilizadas #72485
         if nvl(substr(vt_tab_reg_0051(i).situacao, 1, 1), 0) = '4' then
           gl_conteudo := gl_conteudo || lpad(0, 13, 0);
           gl_conteudo := gl_conteudo || lpad(0, 13, 0);
           gl_conteudo := gl_conteudo || lpad(0, 13, 0);
           gl_conteudo := gl_conteudo || lpad(0, 13, 0);
         else
           gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0051(i).valor_total, 0), 13, 0);
           gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0051(i).valor_ipi, 0), 13, 0);
           gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0051(i).isenta_nao_trib_ipi, 0), 13, 0);
           gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0051(i).outras_ipi, 0), 13, 0);
         end if;
         --
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0051(i).brancos,' '),20,' ');
         gl_conteudo := gl_conteudo || lpad(substr(nvl(vt_tab_reg_0051(i).situacao,' '),1,1),1,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '51' -- '0051'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0051.last then
            exit;
         else
            i := vt_tab_reg_0051.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0051 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0051;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0053:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0053 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0053.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0053.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0053(i).tipo;
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0053(i).cnpj,1,14),14,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0053(i).ie,1,14),14,' ');
         gl_conteudo := gl_conteudo || lpad( vt_tab_reg_0053(i).dt_emis_receb,8,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0053(i).uf,1,2),2,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0053(i).modelo,1,2),2,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0053(i).serie,1,3),3,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0053(i).numero,1,6),6,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0053(i).cfop,1,4),4,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0053(i).emitente,1,1),1,' ');
         --
         -- Zerar valores para as NFs Inutilizadas #72485
         if nvl(substr(vt_tab_reg_0053(i).situacao, 1, 1), 0) = '4' then
           gl_conteudo := gl_conteudo || lpad(0, 13, 0);
           gl_conteudo := gl_conteudo || lpad(0, 13, 0);
           gl_conteudo := gl_conteudo || lpad(0, 13, 0);
         else
           gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0053(i).base_calculo_icms_st, 13, 0);
           gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0053(i).icms_retido, 13, 0);
           gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0053(i).despesas_acessorias, 13, 0);
         end if;
         --
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0053(i).situacao,1,1),1,' ');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0053(i).cod_antecipacao,1,' ');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0053(i).brancos,29,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '53' -- '0053'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0053.last then
            exit;
         else
            i := vt_tab_reg_0053.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0053 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0053;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0054:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0054 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0054.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0054.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0054(i).tipo;
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0054(i).cnpj,1,14),14,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0054(i).modelo,1,02),2,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0054(i).serie,1,03),3,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0054(i).numero,1,06),6,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0054(i).cfop,1,04),4,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0054(i).cst,1,03),03,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0054(i).numero_item,1,03),03,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0054(i).codigo_produto_servico,1,14),14,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0054(i).quantidade,1,11),11,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0054(i).valor_produto,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0054(i).valor_desc_desp_acess,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0054(i).base_calc_icms,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0054(i).base_calc_icms_st,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0054(i).valor_ipi,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0054(i).aliq_icms,04,0);
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '54' -- '0054'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0054.last then
            exit;
         else
            i := vt_tab_reg_0054.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0054 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0054;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0056:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0056 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0056.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0056.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0056(i).tipo;
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0056(i).cnpj_cpf,1,14),14,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0056(i).modelo,1,02),02,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0056(i).serie,1,03),03,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0056(i).numero,1,06),06,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0056(i).cfop,1,04),04,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0056(i).cst,1,03),03,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0056(i).numero_item,1,03),03,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0056(i).cod_prod_serv,1,14),14,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0056(i).tipo_operacao,1,01),01,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0056(i).cnpj_concessionaria,1,14),14,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0056(i).aliquota_ipi,4,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0056(i).chassi,1,17),17,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0056(i).brancos,1,39),39,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '56' -- '0056'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0056.last then
            exit;
         else
            i := vt_tab_reg_0056.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0056 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0056;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0057:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0057 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0057.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0057.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0057(i).tipo;
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0057(i).cnpj,1,14),14,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0057(i).ie,1,14),14,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0057(i).modelo,1,02),02,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0057(i).serie,1,03),03,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0057(i).numero,1,06),06,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0057(i).cfop,1,04),04,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0057(i).cst,1,03),03,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0057(i).numero_item,1,03),03,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0057(i).cod_prod,1,14),14,' ');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0057(i).num_lote_prod,1,20),20,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0057(i).branco,1,41),41,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '57' -- '0057'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0057.last then
            exit;
         else
            i := vt_tab_reg_0057.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0057 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0057;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0060M:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0060M IS
   --
   vn_fase  number := 0;
   vn_qtde  number;
   i        pls_integer;
   j        pls_integer;
   k        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0060M.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0060M.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0060M(i).tipo;
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0060M(i).subtipo,1,01),01,' ' );
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0060M(i).data_emissao,8,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0060M(i).num_serie_fabr,1,20),20,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0060M(i).num_ord_sequencial_equip,1,03),03,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0060M(i).modelo_doc_fiscal,1,02),02,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0060M(i).num_cont_ord_oper_ini_dia,1,06),06,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0060M(i).num_cont_ord_oper_fim_dia,1,06),06,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0060M(i).num_cont_red_z,1,06),06,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0060M(i).cont_reinicio_oper,1,03),03,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0060M(i).valor_venda_bruta,16,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0060M(i).valor_tot_geral_equip,16,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0060M(i).brancos,1,37),37,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '60M' -- '0060M'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         -- Registro de 60A
         begin
            vn_qtde := nvl(vt_bi_tab_reg_0060A(i).count,-1);
         exception
            when others then
               vn_qtde := 0;
         end;
         --
         vn_fase := 8;
         --
         if nvl(vn_qtde,0) > 0 then
            --
            vn_fase := 9;
            j := nvl(vt_bi_tab_reg_0060A(i).first,-1);
            --
            loop
               --
               vn_fase := 10;
               gl_conteudo := null;
               --
               if nvl(j,-1) = -1 then
                  exit;
               end if;
               --
               vn_fase := 11;
               --
               gl_conteudo := gl_conteudo || vt_bi_tab_reg_0060A(i)(j).tipo;
               gl_conteudo := gl_conteudo || rpad(substr(vt_bi_tab_reg_0060A(i)(j).subtipo,1,01),01,' ');
               gl_conteudo := gl_conteudo || lpad(vt_bi_tab_reg_0060A(i)(j).data_emissao,8,0);
               gl_conteudo := gl_conteudo || rpad(substr(vt_bi_tab_reg_0060A(i)(j).num_serie_fabr,1,20),20,' ');
               gl_conteudo := gl_conteudo || lpad(nvl( vt_bi_tab_reg_0060A(i)(j).sit_trib_aliq,' '),04,' ');
               gl_conteudo := gl_conteudo || lpad(vt_bi_tab_reg_0060A(i)(j).valor_acum_tot_parc,12,'0');
               gl_conteudo := gl_conteudo || lpad(' ',79,' ');
               --
               vn_fase := 12;
               pkb_armaz_estr_arq_sint( ev_reg_blc  => '60A' -- '0060A'
                                      , el_conteudo => gl_conteudo );
               --
               vn_fase := 13;
               --
               if j = vt_bi_tab_reg_0060A(i).last then
                  exit;
               else
                  j := vt_bi_tab_reg_0060A(i).next(j);
               end if;
               --
            end loop;
            --
         end if;
         --
         vn_fase := 14;
         -- Registro 60D
         begin
            vn_qtde := nvl(vt_tri_tab_reg_0060D(i).count,-1);
         exception
            when others then
               vn_qtde := 0;
         end;
         --
         vn_fase := 15;
         --
         if nvl(vn_qtde,0) > 0 then
            --
            vn_fase := 16;
            j := nvl(vt_tri_tab_reg_0060D(i).first,-1);
            --
            loop
               --
               vn_fase := 17;
               --
               if nvl(j,-1) = -1 then
                  exit;
               end if;
               --
               vn_fase := 18;
               --
               begin
                  vn_qtde := nvl(vt_tri_tab_reg_0060D(i)(j).count,-1);
               exception
                  when others then
                     vn_qtde := 0;
               end;
               --
               vn_fase := 19;
               --
               if nvl(vn_qtde,0) > 0 then
                  --
                  vn_fase := 20;
                  k := nvl(vt_tri_tab_reg_0060D(i)(j).first,-1);
                  --
                  loop
                     --
                     vn_fase := 21;
                     --
                     if nvl(k,-1) = -1 then
                        exit;
                     end if;
                     --
                     vn_fase := 22;
                     gl_conteudo := null;
                     gl_conteudo := gl_conteudo || vt_tri_tab_reg_0060D(i)(j)(k).tipo;
                     gl_conteudo := gl_conteudo || rpad(substr(vt_tri_tab_reg_0060D(i)(j)(k).subtipo,1,01),01,' ');
                     gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0060D(i)(j)(k).data_emissao,8,0);
                     gl_conteudo := gl_conteudo || rpad(substr(vt_tri_tab_reg_0060D(i)(j)(k).num_serie_fabr,1,20),20,' ');
                     gl_conteudo := gl_conteudo || rpad(vt_tri_tab_reg_0060D(i)(j)(k).codigo_produto_servico ,14,' ');
                     gl_conteudo := gl_conteudo || lpad(nvl(vt_tri_tab_reg_0060D(i)(j)(k).quantidade,0),13,'0');
                     gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0060D(i)(j)(k).valor_merc_prod_serv,16,0);
                     gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0060D(i)(j)(k).base_calc_icms,16,0);
                     gl_conteudo := gl_conteudo || rpad(nvl(vt_tri_tab_reg_0060D(i)(j)(k).sit_trib_aliq,' '),04,' ');
                     gl_conteudo := gl_conteudo || lpad(vt_tri_tab_reg_0060D(i)(j)(k).valor_icms,13,0);
                     gl_conteudo := gl_conteudo || lpad(' ',19,' ');
                     --
                     vn_fase := 23;
                     pkb_armaz_estr_arq_sint( ev_reg_blc  => '60D' -- '0060D'
                                            , el_conteudo => gl_conteudo );
                     --
                     vn_fase := 24;
                     --
                     if k = vt_tri_tab_reg_0060D(i)(j).last then
                        exit;
                     else
                        k := vt_tri_tab_reg_0060D(i)(j).next(k);
                     end if;
                     --
                  end loop;
                  --
               end if;
               --
               vn_fase := 25;
               --
               if j = vt_tri_tab_reg_0060D(i).last then
                  exit;
               else
                  j := vt_tri_tab_reg_0060D(i).next(j);
               end if;
               --
            end loop;
            --
         end if;
         --
         vn_fase := 26;
         -- Registro 60I
         begin
            vn_qtde := nvl(vt_bi_tab_reg_0060I(i).count,-1);
         exception
            when others then
               vn_qtde := 0;
         end;
         --
         vn_fase := 27;
         --
         if nvl(vn_qtde,0) > 0 then
            --
            vn_fase := 28;
            j := nvl(vt_bi_tab_reg_0060I(i).first,-1);
            --
            loop
               --
               vn_fase := 29;
               gl_conteudo := null;
               --
               if nvl(j,-1) = -1 then
                  exit;
               end if;
               --
               vn_fase := 30;
               --
               gl_conteudo := gl_conteudo || vt_bi_tab_reg_0060I(i)(j).tipo;
               gl_conteudo := gl_conteudo || rpad(substr(vt_bi_tab_reg_0060I(i)(j).subtipo,1,01),01,' ');
               gl_conteudo := gl_conteudo || lpad(vt_bi_tab_reg_0060I(i)(j).data_emissao,8,0);
               gl_conteudo := gl_conteudo || lpad(substr(vt_bi_tab_reg_0060I(i)(j).num_serie_fabr,1,20),20,' ');
               gl_conteudo := gl_conteudo || lpad(substr(vt_bi_tab_reg_0060I(i)(j).modelo_doc_fiscal,1,02),02,' ');
               gl_conteudo := gl_conteudo || lpad(substr(vt_bi_tab_reg_0060I(i)(j).nro_ord_doc_fisc,1,06),06,'0');
               gl_conteudo := gl_conteudo || lpad(vt_bi_tab_reg_0060I(i)(j).num_item,03,'0');
               gl_conteudo := gl_conteudo || rpad(vt_bi_tab_reg_0060I(i)(j).cod_merc_prod_serv,14,' ');
               gl_conteudo := gl_conteudo || lpad(vt_bi_tab_reg_0060I(i)(j).quantidade,13,'0');
               gl_conteudo := gl_conteudo || lpad(vt_bi_tab_reg_0060I(i)(j).vl_merc_prod,13,0);
               gl_conteudo := gl_conteudo || lpad(vt_bi_tab_reg_0060I(i)(j).base_calc_icms,12,0);
               gl_conteudo := gl_conteudo || rpad(vt_bi_tab_reg_0060I(i)(j).sit_trib_aliq,4,' ');
               gl_conteudo := gl_conteudo || lpad(vt_bi_tab_reg_0060I(i)(j).valor_icms,12,0);
               gl_conteudo := gl_conteudo || lpad(' ',16,' ');
               --
               vn_fase := 31;
               pkb_armaz_estr_arq_sint( ev_reg_blc  => '60I' -- '0060I'
                                      , el_conteudo => gl_conteudo );
               --
               vn_fase := 32;
               --
               if j = vt_bi_tab_reg_0060I(i).last then
                  exit;
               else
                  j := vt_bi_tab_reg_0060I(i).next(j);
               end if;
               --
            end loop;
            --
         end if;
         --
         vn_fase := 33;
         --
         if i = vt_tab_reg_0060M.last then
            exit;
         else
            i := vt_tab_reg_0060M.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0060M fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0060M;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0060R:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0060R IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0060R.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0060R.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0060R(i).tipo;
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0060R(i).subtipo,1,01),01,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0060R(i).mes_ano_emissao,1,06),06,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0060R(i).cod_merc_prod,1,14),14,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0060R(i).quantidade,1,13),13,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0060R(i).vl_merc_prod,16,0);
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0060R(i).base_calc_icms,0),16,'0');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0060R(i).sit_trib_aliq,1,04),04,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0060R(i).brancos,1,54),54,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '60R' -- '0060R'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0060R.last then
            exit;
         else
            i := vt_tab_reg_0060R.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0060R fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0060R;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0070:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0070 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0070.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0070.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0070(i).tipo;
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0070(i).cnpj,1,14),14,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0070(i).ie,1,14),14,' ');
         gl_conteudo := gl_conteudo || lpad( vt_tab_reg_0070(i).dt_emiss_utiliz,8,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0070(i).uf,1,2),2,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0070(i).modelo,1,2),2,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0070(i).serie,1,1),1,' ');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0070(i).subserie,1,2),2,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0070(i).numero,1,6),6,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0070(i).cfop,1,4),4,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0070(i).vl_tot_doc_fisc,13,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0070(i).base_calc_icms,14,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0070(i).vl_icms,14,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0070(i).isenta_nao_tribut,14,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0070(i).outras,14,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0070(i).cif_fob_outros,1,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0070(i).situacao,1,1),1,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '70' -- '0070'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0070.last then
            exit;
         else
            i := vt_tab_reg_0070.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0070 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0070;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0074:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0074 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0074.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0074.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0074(i).tipo;
         gl_conteudo := gl_conteudo || lpad( vt_tab_reg_0074(i).data_inventario,8,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0074(i).cod_prod,1,14),14,' ');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0074(i).quantidade,13,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0074(i).valor_prod,13,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0074(i).cod_posse_merc_invent,1,1),1,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0074(i).cnpj_possuidor_prop,1,14),14,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0074(i).ie_possuidor_prop,1,14),14,' ');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0074(i).uf_possuidor_prop,1,2),2,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0074(i).brancos,1,45),45,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '74' -- '0074'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0074.last then
            exit;
         else
            i := vt_tab_reg_0074.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0074 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0074;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0075:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0075 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0075.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0075.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := vt_tab_reg_0075(i).tipo;
         gl_conteudo := gl_conteudo || lpad( vt_tab_reg_0075(i).data_inicial,8,0);
         gl_conteudo := gl_conteudo || lpad( vt_tab_reg_0075(i).data_final,8,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0075(i).cod_produto_serv,1,14),14,' ');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0075(i).cod_ncm,1,8),8,' ');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0075(i).descricao,1,53),53,' ');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0075(i).unid_med_comerc,1,6),6,' ');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0075(i).aliquota_ipi,5,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0075(i).aliquota_icms,4,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0075(i).red_base_calc_icms,5,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0075(i).base_calc_icms_st,13,0);
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '75' -- '0075'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0075.last then
            exit;
         else
            i := vt_tab_reg_0075.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0075 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0075;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0076:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0076 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0076.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0076.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || vt_tab_reg_0076(i).tipo;
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0076(i).cnpj_cpf,1,14),14,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0076(i).ie,1,14),14,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0076(i).modelo,1,02),02,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0076(i).serie,1,02),02,' ');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0076(i).subserie,1,02),02,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0076(i).numero,1,10),10,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0076(i).cfop,1,04),04,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0076(i).tipo_receita,1,01),01,0);
         gl_conteudo := gl_conteudo || lpad( vt_tab_reg_0076(i).data_emissao_receb,8,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0076(i).uf,1,2),2,' ');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0076(i).valor_total,13,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0076(i).base_calc_icms,13,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0076(i).valor_icms,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0076(i).isenta_nao_tribut,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0076(i).outras,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0076(i).aliquota,2,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0076(i).situacao,1,1),1,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '76' -- '0076'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0076.last then
            exit;
         else
            i := vt_tab_reg_0076.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0076 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0076;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0085: Informações de Exportações
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0085 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0085.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0085.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).tipo,1,02),02,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).decl_exportacao,1,11),11,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).dt_decl,1,08),08,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0085(i).nat_exportacao,1,01),01,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).reg_exportacao,1,12),12,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).data_registro,1,08),08,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).conhecimento_embarque,1,16),16,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).dt_conhecimento,1,08),08,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).tipo_conhecimento,1,02),02,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).pais,1,04),04,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).reservado,1,08),08,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).dt_averb_decl_exp,1,08),08,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).nf_exportacao,1,06),06,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).dt_emissao,1,08),08,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).modelo,1,02),02,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).serie,1,03),03, ' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0085(i).brancos,1,19),19,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '85' -- '0085'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0085.last then
            exit;
         else
            i := vt_tab_reg_0085.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0085 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0085;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0086: Informações Complementares de Exportações
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0086 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase := 1;
   --
   if nvl(vt_tab_reg_0086.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0086.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         gl_conteudo := null;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0086(i).tipo,1,02),02,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0086(i).reg_exportacao,1,12),12,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0086(i).dt_registro,1,08),08,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0086(i).cnpj_remetente,1,14),14,0);
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0086(i).ie_remetente,1,14),14,' ');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0086(i).uf,1,02),02,' ');
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0086(i).numero_nf,1,06),06,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0086(i).dt_emissao,1,08),08,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0086(i).modelo,1,02),02,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0086(i).serie,1,03),03,' ');
         gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0086(i).cod_produto,1,14),14,' ');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0086(i).quantidade,11,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0086(i).vl_unit_prod,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0086(i).vl_prod,12,0);
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0086(i).relacionamento,01,0);
         gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0086(i).brancos,1,05),05,' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '86' -- '0086'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0086.last then
            exit;
         else
            i := vt_tab_reg_0086.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0086 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0086;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o registro tipo 88 - detalhe 01
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0088_01 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase     := 1;
   gl_conteudo := null;
   --
   if nvl(vt_tab_reg_0088_01.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0088_01.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := vt_tab_reg_0088_01(i).tipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_01(i).detalhe;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_01(i).periodo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_01(i).tipo_oper;
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_01(i).descricao), 49, ' ');
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_01(i).cfop;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_01(i).uf;
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_01(i).unid_com), 6, ' ');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_01(i).qtde,0), 11, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_01(i).vl_contabil,0), 13, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_01(i).vl_base_calc_icms,0), 13, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_01(i).vl_icms,0), 13, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_01(i).aliq,0), 4, '0');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '88' -- '0088'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0088_01.last then
            exit;
         else
            i := vt_tab_reg_0088_01.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0088_01 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0088_01;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o registro tipo 88 - detalhe 02
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0088_02 IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase     := 1;
   gl_conteudo := null;
   --
   if nvl(vt_tab_reg_0088_02.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0088_02.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := vt_tab_reg_0088_02(i).tipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_02(i).detalhe;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_02(i).periodo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_02(i).tipo_oper;
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_02(i).descricao), 49, ' ');
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_02(i).cfop;
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_02(i).unid_com), 6, ' ');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_02(i).qtde,0), 11, '0');
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_02(i).insentivo_fiscal;
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_02(i).vl_contabil,0), 13, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_02(i).vl_base_calc_icms,0), 13, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_02(i).vl_icms,0), 13, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_02(i).aliq,0), 4, '0');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '88' -- '0088'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0088_02.last then
            exit;
         else
            i := vt_tab_reg_0088_02.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0088_02 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0088_02;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o registro tipo 88 - detalhe cf
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0088_CF IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase     := 1;
   gl_conteudo := null;
   --
   if nvl(vt_tab_reg_0088_cf.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0088_cf.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := vt_tab_reg_0088_cf(i).tipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_cf(i).subtipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_cf(i).dt_emis;
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_cf(i).num_serie_fabr), 20, ' ');
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_cf(i).cod_mod;
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0088_cf(i).num_coo_fin, 6, '0');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0088_cf(i).nro_nf, 6, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_cf(i).vl_total,0), 14, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_cf(i).vl_bc_icms,0), 13, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_cf(i).vl_icms,0), 13, '0');
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_cf(i).sit_trib), 4, ' ');
         gl_conteudo := gl_conteudo || rpad(' ', 36, ' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '88' -- '0088'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0088_cf.last then
            exit;
         else
            i := vt_tab_reg_0088_cf.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0088_cf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0088_CF;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o registro tipo 88 - detalhe IT
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0088_IT IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase     := 1;
   gl_conteudo := null;
   --
   if nvl(vt_tab_reg_0088_it.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0088_it.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := vt_tab_reg_0088_it(i).tipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_it(i).subtipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_cf(i).dt_emis;
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_cf(i).num_serie_fabr), 20, ' ');
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_cf(i).cod_mod;
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0088_cf(i).num_coo_fin, 6, '0');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0088_cf(i).nro_nf, 6, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_cf(i).vl_total,0), 14, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_cf(i).vl_bc_icms,0), 13, '0');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_cf(i).vl_icms,0), 13, '0');
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_cf(i).sit_trib), 4, ' ');
         gl_conteudo := gl_conteudo || rpad(' ', 36, ' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '88' -- '0088'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0088_it.last then
            exit;
         else
            i := vt_tab_reg_0088_it.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0088_it fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0088_IT;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o registro tipo 88 - detalhe SME
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0088_SME IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase     := 1;
   gl_conteudo := null;
   --
   if nvl(vt_tab_reg_0088_sme.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0088_sme.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := vt_tab_reg_0088_sme(i).tipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_sme(i).subtipo;
         gl_conteudo := gl_conteudo || lpad(trim(vt_tab_reg_0088_sme(i).cnpj), 14, '0');
         -- gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sme(i).cnpj), 14, ' ');
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sme(i).ie), 14, ' ');
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sme(i).mensagem), 34, ' ');
         gl_conteudo := gl_conteudo || rpad(' ', 59, ' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '88' -- '0088'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0088_sme.last then
            exit;
         else
            i := vt_tab_reg_0088_sme.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0088_sme fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0088_SME;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o registro tipo 88 - detalhe SMS
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0088_SMS IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase     := 1;
   gl_conteudo := null;
   --
   if nvl(vt_tab_reg_0088_sms.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0088_sms.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := vt_tab_reg_0088_sms(i).tipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_sms(i).subtipo;
         gl_conteudo := gl_conteudo || lpad(trim(vt_tab_reg_0088_sms(i).cnpj), 14, '0');
         -- gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sms(i).cnpj), 14, ' ');
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sms(i).ie), 14, ' ');
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sms(i).mensagem), 34, ' ');
         gl_conteudo := gl_conteudo || rpad(' ', 59, ' ');
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '88' -- '0088'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0088_sms.last then
            exit;
         else
            i := vt_tab_reg_0088_sms.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0088_sms fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0088_SMS;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o registro tipo 88 - detalhe EC
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0088_EC IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase     := 1;
   gl_conteudo := null;
   --
   if nvl(vt_tab_reg_0088_ec.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0088_ec.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := vt_tab_reg_0088_ec(i).tipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_ec(i).subtipo;
         gl_conteudo := gl_conteudo || rpad(vt_tab_reg_0088_ec(i).nome, 39, ' ');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0088_ec(i).cpf, 11, '0');
         gl_conteudo := gl_conteudo || rpad(vt_tab_reg_0088_ec(i).crc, 10, ' ');
         gl_conteudo := gl_conteudo || lpad(vt_tab_reg_0088_ec(i).fone, 11, '0');
         gl_conteudo := gl_conteudo || rpad(vt_tab_reg_0088_ec(i).email, 50, ' ');
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_ec(i).dm_altera;
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '88' -- '0088'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0088_ec.last then
            exit;
         else
            i := vt_tab_reg_0088_ec.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0088_ec fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0088_EC;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o registro tipo 88 - detalhe SF
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0088_SF IS
   --
   vn_fase  number := 0;
   i        pls_integer;
   --
BEGIN
   --
   vn_fase     := 1;
   gl_conteudo := null;
   --
   if nvl(vt_tab_reg_0088_sf.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0088_sf.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         gl_conteudo := vt_tab_reg_0088_sf(i).tipo;
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_sf(i).subtipo;
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sf(i).nome_empr), 35, ' ');
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sf(i).cnpj_empr), 14, ' ');
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sf(i).cpf_tec), 11, ' ');
         gl_conteudo := gl_conteudo || lpad(nvl(vt_tab_reg_0088_sf(i).fone,0), 11, '0');
         gl_conteudo := gl_conteudo || rpad(trim(vt_tab_reg_0088_sf(i).email), 50, ' ');
         gl_conteudo := gl_conteudo || vt_tab_reg_0088_sf(i).dm_altera;
         --
         vn_fase := 6;
         --
         pkb_armaz_estr_arq_sint( ev_reg_blc  => '88' -- '0088'
                                , el_conteudo => gl_conteudo );
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0088_sf.last then
            exit;
         else
            i := vt_tab_reg_0088_sf.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0088_sf fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0088_SF;

-------------------------------------------------------------------------------------------------------
-- Armazena em arquivo o REGISTRO 0090:
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_ARMAZ_REG_0090 IS
   --
   vn_fase number := 0;
   i       pls_integer;
   --
BEGIN
   --
   vn_fase     := 1;
   gl_conteudo := null;
   --
   if nvl(vt_tab_reg_0090.count,0) > 0 then
      --
      vn_fase := 2;
      --
      i := nvl(vt_tab_reg_0090.first,0);
      --
      vn_fase := 3;
      --
      loop
         --
         vn_fase := 4;
         --
         if nvl(i,0) = 0 then
            exit;
         end if;
         --
         vn_fase := 5;
         --
         if nvl(vt_tab_reg_0090(i).tipo,0) > 0 then
            --
            gl_conteudo := lpad(substr(vt_tab_reg_0090(i).tipo,1,02),02,' ');
            gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0090(i).cgc_mf,1,14),14,0);
            gl_conteudo := gl_conteudo || rpad(substr(vt_tab_reg_0090(i).ie,1,14),14,' ');
            gl_conteudo := gl_conteudo || vt_tab_reg_0090(i).total;
            gl_conteudo := gl_conteudo || lpad(substr(vt_tab_reg_0090(i).num_reg_tipo_90,1,01),01,0);
            --
            vn_fase := 6;
            --
            pkb_armaz_estr_arq_sint( ev_reg_blc  => '90' -- '0090'
                                   , el_conteudo => gl_conteudo );
            --
         end if;
         --
         vn_fase := 7;
         --
         if i = vt_tab_reg_0090.last then
            exit;
         else
            i := vt_tab_reg_0090.next(i);
         end if;
         --
      end loop;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_armaz_reg_0090 fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_ARMAZ_REG_0090;

-------------------------------------------------------------------------------------------------------
-- Procedimento do arquivo SINTEGRA
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_GERA_ARQUIVO_SINT ( EN_ABERTURASINT_ID IN ABERTURA_SINTEGRA.ID%TYPE ) IS
   --
   vn_fase  number := 0;
   --
   cursor c_est is
   select * from estado e
    order by sigla_estado;
   --
BEGIN
   --
   vn_fase := 1;
   --
   begin
       update abertura_sintegra
         set dm_situacao = 5 -- Em geracao...
       where id = en_aberturasint_id;
       commit;
   end;
   --
   pkb_inicia_dados;
   --
   vn_fase := 2;
   --
   pkb_inicia_param( en_aberturasint_id => en_aberturasint_id );
   --
   vn_fase := 3;
   --
   if nvl(gt_row_abertura_sint.id,0) > 0 then
      --
      vn_fase := 4;
      --
      gn_dm_dt_escr_dfepoe := pk_csf.fkg_dmdtescrdfepoe_empresa( en_empresa_id => gt_row_abertura_sint.empresa_id );
      --
      vn_fase := 5;
      -- excluir os registros anteriores
      pkb_excluir_arq_sint;
      --
      vn_fase := 5.1;
      --
      --#75073
      -- chama insert temporaria
      pkb_insert_tabela_tmp;
      --
      if nvl(gt_row_abertura_sint.dm_ident_nat,0) = 3 then -- Totalidade das operações do informante
         --
         gn_estado_id := null;
         gv_sigla_estado := null;
         --
         vn_fase := 6;
         -- procedimento alimenta os arrays do sintegra
         pkb_monta_array_sint;
         --
         vn_fase := 7;
         -- procedimento monta estrutura do arquivo do sintegra
         pkb_monta_estr_arq_sint;
         --
      else
         --
         vn_fase := 8;
         --
         for rec in c_est loop
            exit when c_est%notfound or (c_est%notfound) is null;
            --
            vn_fase := 8.1;
            --
            gn_estado_id     := rec.id;
            gv_sigla_estado  := rec.sigla_estado;
            --
            pkb_inicia_dados;
            --
            vn_fase := 8.2;
            -- 1-Interestaduais somente operações sujeitas ao regime de Substituição Tributária
            -- 2-Interestaduais - operações com ou sem Substituição Tributária
            --
            -- procedimento alimenta os arrays do sintegra
            pkb_monta_array_sint;
            --
            vn_fase := 8.3;
            -- procedimento monta estrutura do arquivo do sintegra
            pkb_monta_estr_arq_sint;
            --
         end loop;
         --
      end if;
      --
      vn_fase := 99;
      --
      update abertura_sintegra
         set dm_situacao = 3 -- Gerado Arquivo
       where id = en_aberturasint_id;
      --
      vn_fase := 99.1;
      --
      commit;
      --
      pkb_inicia_dados;
      --
   end if;
   --
EXCEPTION
   when others then
   --
      Begin
       update abertura_sintegra
         set dm_situacao = 4 -- Erro na geração do arquivo
       where id = gt_row_abertura_sint.id;
       commit;
      end;
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_gera_arquivo_sint fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => gt_row_abertura_sint.id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_GERA_ARQUIVO_SINT;

-------------------------------------------------------------------------------------------------------
-- Procedimento para validar
-------------------------------------------------------------------------------------------------------
PROCEDURE PKB_VALIDAR ( EN_ABERTURASINT_ID IN ABERTURA_SINTEGRA.ID%TYPE ) IS
   --
   vn_fase            number := 0;
   vn_loggenerico_id  Log_Generico.id%TYPE;
   --
BEGIN
   --
   vn_fase := 1;
   --
   pkb_inicia_param( en_aberturasint_id => en_aberturasint_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_abertura_sint.id,0) > 0 and
      gt_row_abertura_sint.dm_situacao = 0 then -- Não GErado
      --
      vn_fase           := 3;
      gv_mensagem       := 'Validação da Abertura do Sintegra do período de '||to_char(gt_row_abertura_sint.dt_ini,'dd/mm/rrrr')||' até '||
                           to_char(gt_row_abertura_sint.dt_fin,'dd/mm/rrrr');
      gn_referencia_id  := gt_row_abertura_sint.id;
      gv_obj_referencia := 'ABERTURA_SINTEGRA';
      gv_resumo         := null;
      --
      vn_fase := 4;
      --
      if gv_resumo is null then
         --
         vn_fase := 5;
         --
         update abertura_sintegra
            set dm_situacao = 2 -- Validado
          where id = en_aberturasint_id;
         --
      else
         --
         vn_fase := 6;
         --
         update abertura_sintegra
            set dm_situacao = 1 -- Erro de validação
          where id = en_aberturasint_id;
         --
      end if;
      --
      vn_fase := 7;
      --
      commit;
      --
   end if;
   --
EXCEPTION
   when others then
      --
      pk_log_generico.gv_mensagem := 'Erro na pk_gera_arq_sint.pkb_validar fase('||vn_fase||'): '||sqlerrm;
      --
      declare
         vn_loggenerico_id  Log_Generico.id%TYPE;
      begin
         --
         pk_log_generico.pkb_log_generico ( sn_loggenerico_id  => vn_loggenerico_id
                                     , ev_mensagem        => pk_log_generico.gv_mensagem
                                     , ev_resumo          => null
                                     , en_tipo_log        => pk_log_generico.erro_de_sistema
                                     , en_referencia_id   => en_aberturasint_id
                                     , ev_obj_referencia  => 'ABERTURA_SINTEGRA' );
         --
      exception
         when others then
            null;
      end;
      --
      raise_application_error (-20101, pk_log_generico.gv_mensagem);
      --
END PKB_VALIDAR;

-------------------------------------------------------------------------------------------------------
-- Procedimento de desfazer a situação da geração
-------------------------------------------------------------------------------------------------------
procedure pkb_desfazer ( en_aberturasint_id in abertura_sintegra.id%type ) is
   --
   vn_fase number := 0;
   --
   --#75073
   cursor c_delete is
     select rowid as chave
       from estr_arq_sintegra
      where aberturasintegra_id = en_aberturasint_id;
   --
   type type_cursor is table of c_delete%rowtype index by binary_integer;
   r_delete    type_cursor;
   --
BEGIN
   --
   vn_fase := 1;
   -- recupera parâmetros da geração da gia
   pkb_inicia_param( en_aberturasint_id => en_aberturasint_id );
   --
   vn_fase := 2;
   --
   if nvl(gt_row_abertura_sint.id,0) > 0 then
      --
      vn_fase := 3;
      --
      if nvl(gt_row_abertura_sint.dm_situacao,0) in (3,4,5) then -- 3-Gerado Arquivo/4-Erro na geração do arquivo/ 5-em geracao
         --
         vn_fase := 4;
         --
         --#75073
         begin
           open c_delete;
             loop
               fetch c_delete bulk collect into r_delete limit 10000;
                forall i in 1 .. r_delete.count
                  delete from estr_arq_sintegra
                   where rowid = r_delete(i).chave;
                commit;
              exit when c_delete%notfound;
            end loop;
           close c_delete;
         exception
           when others then
             raise_application_error(-20101, 'Erro ao tentar deletar registros da tabela estr_arq_sintegra - fase('||vn_fase||'): '||sqlerrm);
         end;
         --
         vn_fase := 5;
         --
         begin
           update abertura_sintegra set dm_situacao = 2 -- Validado
            where id = en_aberturasint_id;
         exception
           when others then
             raise_application_error(-20101, 'Erro ao tentar alterar situacao para 2 (Validado) da tabela estr_arq_sintegra - fase('||vn_fase||'): '||sqlerrm);
         end;
         --
      elsif nvl(gt_row_abertura_sint.dm_situacao,0) in (1,2) then -- 1-Erro de validação/2-Gerado Arquivo
         --
         vn_fase := 6;
         --
         begin
           update abertura_sintegra set dm_situacao = 0 -- Não Gerado
            where id = en_aberturasint_id;
         exception
           when others then
             raise_application_error(-20101, 'Erro ao tentar alterar situacao para 0 (Não Gerado) da tabela estr_arq_sintegra - fase('||vn_fase||'): '||sqlerrm);
         end;
         --
      end if;
      --
      vn_fase := 7;
      --
      commit;
      --
   end if;
   --
exception
   when others then
      raise_application_error(-20101, 'Erro na pk_gera_arq_sint.pkb_desfazer fase('||vn_fase||'): '||sqlerrm);
end pkb_desfazer;

-------------------------------------------------------------------------------------------------------

END PK_GERA_ARQ_SINT;
/