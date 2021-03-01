create or replace package csf_own.pk_csf_api_cons_sit is
--
-- Especificação do pacote de validação da CSF_CONS_SIT
--
-- Em 02/02/2021      - Karina de Paula
-- Redmine #75655     - Looping na tabela CSF_OWN.CSF_CONS_SIT após atualização da 2.9.5.0 (NOVA AMERICA)
-- Rotina Alterada    - pkb_ins_atu_csf_cons_sit  => Incluído o select que busca a sequence da tabela csf_cons_sit 
--                    - pkb_ins_atu_ct_cons_sit   => Incluído o select que busca a sequence da tabela ct_cons_sit                       
--                    - pkb_integr_cons_chave_nfe => Excluído esse ponto que busca a sequence da csf_cons_sit porque dentro da rotina 
--                      pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit é criado um novo id, sendo esse não utilizado  
--                    - pkb_integr_ct_cons_sit    => Excluído esse ponto que busca a sequence da ct_cons_sit porque dentro da rotina 
--                      Retirado o null que carregava para as variáveis pk_csf_api_cons_sit.gt_row_csf_cons_sit e pk_csf_api_ct_sit.gt_row_ct_cons_sit pq gerava erro de falta de dados
--                    - Carregado valor para as variáveis: gv_obj_referencia, gv_obj_referencia_ct e gn_referencia_id 
--                    - pkb_ins_atu_csf_cons_sit  => Incluida a verificacao se ja existe registro pq estava gerando duplicacao 
--                    - pkb_integr_cons_chave_nfe / pkb_valid_cons_chave_nfe => Retirada a verificação (nvl(est_log_generico_nf.count,0) = 0) pq impedia de gerar todos os logs de erro de uma só vez 
--                    - pkb_integr_ct_cons_sit / pkb_valid_ct_cons_sit       => Retirada a verificação (nvl(est_log_generico_ct.count,0) = 0) pq impedia de gerar todos os logs de erro de uma só vez
--                    - pkb_valid_cons_chave_nfe / pkb_valid_ct_cons_sit => Retirada a verificação de duplicação pq já é executada na  pk_integr_view e na pkb_ins_atu_csf_cons_sit/pkb_ins_atu_ct_cons_sit 
--                    - pkb_relac_nfe_cons_sit => retirada essa rotina da pk_csf_api e trazida para essa pk pq é uma rotina da CSF_CONS_SIT
--                    - fkg_ck_nota_fiscal_mde_registr/fkg_checa_existe_chave => retirada essa rotina da pk_csf_api e trazida para essa pk pq é uma rotina da CSF_CONS_SIT
-- Liberado na versão - Release_2.9.7, Patch_2.9.6.2 e Patch_2.9.5.5
--
-- Em 18/11/2020      - Karina de Paula
-- Redmine #71682     - Looping na tabela CSF_OWN.CSF_CONS_SIT após atualização da 2.9.4.1 (NOVA AMERICA)
-- Rotina Alterada    - pkb_valid_cons_chave_nfe e pkb_valid_ct_cons_sit => Alterada a verificação do valor retornado da função pk_csf.fkg_Estado_ibge_id
-- Liberado na versão - Release_2.9.6, Patch_2.9.5.2 e Patch_2.9.4.5
--
-- Em 20/10/2020   - Luiz Armando/Luis Marques - 2.9.5-1 / 2.9.6
-- Redmine #72513  - Alerta DBSI
-- Rotina Alterada - pkb_ins_atu_ct_cons_sit - Colocação de NVL nas colunas "dm_rec_fisico","dm_integr_erp", "dm_st_integra"
--
-- Em 14/09/2020   - Karina de Paula
-- Redmine #67105  - Criar processo de validação da CT_CONS_SIT
-- Rotina Criada   - pkb_integr_ct_cons_sit      => Rotina criada para ficar no lugar da rotina excluída pk_csf_api_ct.pkb_integr_ct_cons_sit
--                 -                                Inserida chamada da validação da chave(pkb_valid_ct_cons_sit) e rotina de inserção e atualização (pkb_ins_atu_ct_cons_sit)
--                 - pkb_integr_ct_cons_sit      => Passa a integrar o valor da DM_SITUACAO como "0 - Aguardando validação"
--                 - pkb_log_generico_conssit_ct => Criada para gerar o log p ct
--                 - pkb_valid_ct_cons_sit       => Rotina criada para validação da chave do ct
--                 - pkb_ins_atu_ct_cons_sit     => Rotina criada para inserção e atualização dos dados na ct_cons_sit
-- Liberado        - Release_2.9.5
--
-- Em 07/08/2020      - Karina de Paula
-- Redmine #70213     - Erro ORA-6544 [pevm_peruws_callback-1] [1400] [] [] [] [] [] [] [] [] [] [] (NOVA AMERICA)
-- Rotina Alterada    - pkb_integr_cons_chave_nfe => Retirada a (pk_csf_api_cons_sit.gt_row_csf_cons_sit recebendo null) pq estava gerando
--                    - erro na est_row_csf_cons_sit.chnfe que tb ficava null
--                    - pkb_log_generico_conssit  => A exception estava chamando a sí mesma, gerando um loop infinito
-- Liberado na versão - Release_2.9.4, Patch_2.9.4.1 e Patch_2.9.3.4
--                      Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 24/04/2020      - Karina de Paula
-- Redmine #62471     - Criar processo de validação da CSF_CONS_SIT
-- Redmine #63341     - Erro na integração da chave persiste
-- Criação da package de validação da CSF_CONS_SIT
-- Liberado na versão - Release_2.9.4, Patch_2.9.3.1 e Patch_2.9.2.4
--
-- ====================================================================================================================== --
--
-- Variáveis globais
   gv_resumo           log_generico_nf.resumo%type;
   gv_mensagem         log_generico_nf.mensagem%type;
   gn_processo_id      log_generico_nf.processo_id%TYPE := null;
   gn_empresa_id       empresa.id%type;
   --
   gn_tipo_integr      number := null;
   gv_obj_referencia    log_generico_nf.obj_referencia%type := 'CSF_CONS_SIT';
   gv_obj_referencia_ct log_generico_nf.obj_referencia%type := 'CT_CONS_SIT';
   gn_referencia_id    log_generico_nf.referencia_id%type := null;
   gv_objeto           varchar2(300);
   gn_fase             number;
   gt_row_csf_cons_sit csf_cons_sit%rowtype;
   gt_row_ct_cons_sit  ct_cons_sit%rowtype;
   --
-- Declaração de constantes
   erro_de_validacao   constant number :=  1;
   erro_de_sistema     constant number :=  2;
   informacao          constant number := 35;
   cons_sit_nfe_sefaz  constant number := 30;
--
-- ====================================================================================================================== --
-- Checa se existe consulta pendente ou consulta no dia de chave de acesso nfe
function fkg_checa_chave_envio_pendente (ev_nro_chave_nfe nota_fiscal.nro_chave_nfe%type) return number;
--
-- ====================================================================================================================== --
-- Checa se existe a mesma chave em outro registro com DM_SITUACAO IN (0,1)
function fkg_checa_existe_chave (ev_nro_chave_nfe nota_fiscal.nro_chave_nfe%type) return number;
--
-- ====================================================================================================================== --
-- Checa se a NOTA_FISCAL_MDE já existe registrado e vinculado a NFe
function fkg_ck_nota_fiscal_mde_registr( en_notafiscal_id       in nota_fiscal_mde.notafiscal_id%type
                                       , en_tipoeventosefaz_id  in nota_fiscal_mde.tipoeventosefaz_id%type) return boolean;
--
-- ====================================================================================================================== --
-- Procedimento de atualização da tabela CSF_CONS_SIT
procedure pkb_ins_atu_csf_cons_sit ( est_row_csf_cons_sit in out nocopy csf_cons_sit%rowtype
                                   , ev_campo_atu         in varchar2
                                   , en_tp_rotina         in number
                                   , ev_rotina_orig       in varchar2
                                   );
--
-- ====================================================================================================================== --
-- Procedimento de validação dos dados da chave da nf
procedure pkb_valid_cons_chave_nfe ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                   , est_row_csf_cons_sit in out nocopy  csf_cons_sit%rowtype
                                   , en_multorg_id        in             mult_org.id%type
                                   , ev_rotina            in             varchar2 default null
                                   );
--
-- ====================================================================================================================== --
-- Procedimento de integração de consulta chave nfe
procedure pkb_integr_cons_chave_nfe ( est_log_generico_nf  in out nocopy  dbms_sql.number_table
                                    , est_row_csf_cons_sit in out nocopy  csf_cons_sit%rowtype
                                    , ev_cpf_cnpj_emit     in             varchar2
                                    , en_multorg_id        in             mult_org.id%type
                                    , ev_rotina            in             varchar2 default null
                                    );
--
-- ====================================================================================================================== --
-- Procedimento de atualização do campo NOTAFISCAL_ID da tabela CSF_CONS_SIT
-- Pega todos os registros que o campo NOTAFISCAL_ID estão nulos, verifica se sua chave de acesso existe
-- na tabela NOTA_FISCAL, se exitir relaciona o campo NOTA_FISCAL.ID com campo CSF_CONS_SIT.NOTAFISCCAL_ID
procedure pkb_relac_nfe_cons_sit ( en_multorg_id  in mult_org.id%type );
--
-- ====================================================================================================================== --
-- Procedimento de atualização da tabela CT_CONS_SIT                                 
procedure pkb_ins_atu_ct_cons_sit ( est_row_ct_cons_sit in out nocopy ct_cons_sit%rowtype
                                  , ev_campo_atu        in varchar2
                                  , en_tp_rotina        in number
                                  , ev_rotina_orig      in varchar2
                                  );
--
-- ====================================================================================================================== --
-- Procedimento de validação dos dados da chave da ct
procedure pkb_valid_ct_cons_sit ( est_log_generico_ct in out nocopy  dbms_sql.number_table
                                , est_row_ct_cons_sit in out nocopy  ct_cons_sit%rowtype
                                , en_multorg_id       in             mult_org.id%type
                                , ev_rotina           in             varchar2 default null
                                );
--
-- ====================================================================================================================== --
-- Procedimento de integração de consulta chave ct
procedure pkb_integr_ct_cons_sit ( est_log_generico_ct in out nocopy  dbms_sql.number_table
                                 , est_row_ct_cons_sit in out nocopy  ct_cons_sit%rowtype
                                 , ev_cpf_cnpj_emit    in             varchar2
                                 , en_multorg_id       in             mult_org.id%type
                                 , ev_rotina           in             varchar2 default null
                                 );
--
-- ====================================================================================================================== --
--
end pk_csf_api_cons_sit;
/