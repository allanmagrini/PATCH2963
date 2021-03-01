create or replace package body csf_own.pk_csf_gpi is

----------------------------------------------------------------------------------------------------
-- Pacote de Funções da Guia de Pagamento de Impostos  
----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------
-- Função que verifica se já existe o código identificador no banco
function fkg_exist_guiapgtoimp ( en_guiapgtoimp_id in guia_pgto_imp.id%type 
                               ) return boolean
is
   --
   vn_exist                    number;
   --
begin
   --
   vn_exist := 0;
   --
   begin
      --
      select 1
        into vn_exist
        from guia_pgto_imp
       where id = en_guiapgtoimp_id;
      --
   exception
      when others then
        vn_exist := 0;
   end;
   --
   if nvl(vn_exist,0) = 0 then
      return false;
   else
      return true;
   end if;
   --
end fkg_exist_guiapgtoimp;

-----------------------------------------------------------------------
-- Função que retorna o código identificador da tabela guia_pgto_imp
function fkg_guiapgtoimp_id ( en_empresa_id           in empresa.id%type
                            , en_pessoa_id            in pessoa.id%type
                            , en_tipoimposto_id       in tipo_imposto.id%type
                            , en_tiporetimp_id        in tipo_ret_imp.id%type
                            , en_tiporetimpreceita_id in tipo_ret_imp_receita.id%type
                            , ed_dt_vcto              in guia_pgto_imp.dt_vcto%type
                            , en_notafiscal_id        in nota_fiscal.id%type   default null
                            , en_conhectransp_id      in conhec_transp.id%type default null
                            ) return guia_pgto_imp.id%type
is
   --
   vn_guiapgtoimp_id        guia_pgto_imp.id%type;
   --
begin
   --
   vn_guiapgtoimp_id := null;
   --
   if nvl(en_empresa_id,0) > 0
    and nvl(en_pessoa_id,0) > 0
    and nvl(en_tipoimposto_id,0) > 0
    and trim(ed_dt_vcto) is not null then
      --
      select id
        into vn_guiapgtoimp_id 
        from guia_pgto_imp gpi
       where empresa_id           = en_empresa_id
         and pessoa_id            = en_pessoa_id
         and tipoimposto_id       = en_tipoimposto_id
         and ((tiporetimp_id is null         and en_tiporetimp_id is null)         or (tiporetimp_id = en_tiporetimp_id))
         and ((tiporetimpreceita_id is null  and en_tiporetimpreceita_id is null)         or (tiporetimpreceita_id = en_tiporetimpreceita_id))
         and dt_vcto              = ed_dt_vcto
         and nvl(gpi.notafiscal_id,0)   = nvl(en_notafiscal_id,0)
         and nvl(gpi.conhectransp_id,0) = nvl(en_conhectransp_id,0);
      --
   end if;
   --
   return vn_guiapgtoimp_id;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_guiapgtoimp_id:' || sqlerrm);
end fkg_guiapgtoimp_id;

-----------------------------------------------------------------------
-- Função que retorna o código identificador da tabela tipo_ret_imp_receita
function fkg_tiporetimpreceita_cd ( en_tiporetimpreceita_id in tipo_ret_imp_receita.id%type
                                  ) return tipo_ret_imp_receita.cod_receita%type
is
   --
   vv_cod_receita                 tipo_ret_imp_receita.cod_receita%type;
   --
begin
   --
   vv_cod_receita := null;
   --
   if nvl(en_tiporetimpreceita_id,0) > 0 then
      --
      select cod_receita
        into vv_cod_receita
        from tipo_ret_imp_receita
       where id = en_tiporetimpreceita_id;
      --
   end if;
   --
   return vv_cod_receita;
   --
exception
   when no_data_found then
      return null;
   when others then
      raise_application_error(-20101, 'Erro na fkg_tiporetimpreceita_cd:' || sqlerrm);
end fkg_tiporetimpreceita_cd;

end pk_csf_gpi;
/
