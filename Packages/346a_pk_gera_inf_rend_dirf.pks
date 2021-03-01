create or replace package csf_own.pk_gera_inf_rend_dirf is
-------------------------------------------------------------------------------------------------------
--
--| Especificação do pacote de procedimentos de Geração de Informe de Rendimentos da DIRF      
--
-- Em 23/02/2021 - Allan Magrini
-- Distribuições: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #76506 - Retenção 5979 não está sendo transmitida para os informes de rendimentos
-- Rotina Alterada: pkb_gera_ird_docto_fiscal - adicionado a condição no cursor c_pcc and  and tri.cd in (5952,5979) 
-- 
-- Em 06/11/2020 - Joao Pinheiro
-- Redmine #70522 - Geração DIRF
-- Rotina Alterada: pkb_gera_ird_docto_fiscal - adicionado a condicao and tri.cd not in ('2372','2484') -- Geração DIRF sem o código 2484
--  
-- Em 29/04/2020 - Luis Marques
-- Redmine #67070 - Geração de Informe de rendimento com Valor Duplicado
-- Rotina Alterada: pkb_gera_ird_docto_fiscal - Ajustado os cursores "c_pcc" e "c_imp_ret" pois estavam gerando o 
--                  mesmo valor causando o valor duplicado.
--
-- Em 28/01/2020 - Luis Marques
-- Redmine #39308 - Geração da DIRF - Parametrizar data de geração.
-- Rotina Alterada: pkb_gera_ird_docto_fiscal - Incluido leitura do parametro de datas para leitura dos dados 
--                  dos documentos para geração da DIRF.
--
-- Em 27/01/2020 - Luis Marques
-- Redmine #55500 - Parametro para geração de registro na DIRF
-- Rotina Alterada: pkb_gera_ird_docto_fiscal - Não será criado parametro será ajustado o cursor de leitura
--                  dos pagamentos impostos retidos para considerar apenas 11-CSLL/12-IRRF/14-PCC e 
--                  4-PIS e 5-cofins com codgio de retenção 5952.
--
-- Em 14/08/2019 - Luis Marques
-- Redmine #57523 - Mudar SELECT do Cursor recupera apenas os impostos de PIS/COFINS/CSLL
-- Rotina: pkb_gera_ird_docto_fiscal - Ajustado cursor que recupera apenas os impostos de PIS/COFINS/CSLL para burcar 
--         por dt_docto no lugar de dt_pgto
--
-- Em 27/06/2019 - Luiz Armando Azoni.
-- Redmine #55727 - Adequação do cursor c_pcc da pkb_gera_ird_docto_fiscal alterando o campo do select de pir.dt_pgto para pir.dt_docto
--
-- Em 14/06/2019 - Luis Marques.
-- Redmine #55301 - Ajustes na geração do arquivo da DIRF (Registro RTDP - IDREC|3208)
--                  Criado procedimento para gravar deduções de dependentes.
--
-- Rotinas: pkb_criar_inf_rend_dirf, pkb_reg_valores, pkb_gera_ird_docto_fiscal
--
-- Em 13/12/2013 - Angela Inês.       
-- Redmine #1558 - Processo DIRF. Correções:
-- 1) Excluir os registros das tabelas de relatórios de pessoas física e jurídica ao desfazer a situação.
-- Rotina: pkb_desfazer.
-- 2) Para os Impostos PIS / COFINS / CSLL, deverá ser considerado a data do PAGAMENTO como Rendimento Tributável.
-- Rotina: pkb_gera_ird_docto_fiscal.
-- 3) Valores mensais duplicados. Os valores foram integrados já duplicados, não houveram alterações nos processos.
-- Somar a base de cálculo somente se for diferente entre os impostos.
-- Rotina: pkb_gera_ird_docto_fiscal.
--
-- Em 23/12/2013 - Angela Inês.
-- Redmine #1654 - Verificar processos incorretos da DIRF enviados por email.
-- Alterações:
-- 1) Rotina: pk_gera_inf_rend_dirf.pkb_gera_ird_docto_fiscal.
-- Existem valores de lançamentos na mesma data para os impostos PIS/COFINS/CSLL e não estavam sendo somados por estarem com os mesmos valores.
-- Alteramos o cursor que recupera os dados somando por número de documento.
-- 2) Rotina: pk_gera_inf_rend_dirf.pkb_gera_ird_docto_fiscal.
-- Existem tipos de retenções de impostos que devem ser gerados pela data de pagamento e não pela data do documento: 3208, 0588.
-- Alteramos o cursor recuperando as datas de pagamento para os tipos de retenção 3208 e 0588, para IRRF.
-- 3) Rotina: pk_csf_api_dirf.pkb_integr_inf_rend_dirf_mensa.
-- Na alteração do valor de rendimento do mês 02, a variável utilizada estava sendo a mesma do mês 01.
--
-- Em 30/01/2014 - Angela Inês.
-- Redemine #1849 - Suporte - Karina/Aceco.
-- Validação do arquivo DIRF no PVA incorreta. Alterações:
-- 1) Incluir a recuperação das notas fiscais de serviço (99) e mercantil (55) no processo de geração dos informes de rendimento.
-- 2) Considerar um ID de tipo de retenção de imposto quando o CD for o mesmo para os impostos PIS/COFINS/CSLL na recuperação dos documentos fiscais.
-- 3) Não considerar os impostos retidos de INSS e ISS dos documentos fiscais. Considerar somente IRRF, PIS, COFINS e CSLL.
-- 4) Recuperação dos pagamentos de impostos: Considerar na sequencia data de pagamento depois data de vencimento para os tipos de retenção 3208 e 0588,
--    e para os outros, considerar na sequencia data de documento depois data de vencimento. Agrupar os valores por data completa.
-- Rotina: pk_gera_inf_rend_dirf.pkb_gera_ird_docto_fiscal.
--
-- Em 07/01/2015 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 13/03/2015 - Rogério Silva.
-- Redmine #6985 - Falha na montagem do arquivo DIRF (ACECO)
--
-- Em 10/06/2015 - Rogério Silva
-- Redmine #8252 - Processo de Registro de Log em Packages - Informações da DIRF
--
-- Em 30/07/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 05/02/2016 - Angela Inês.
-- Redmine #15124 - Correção nos processos de Geração de Dados da DIRF.
-- Processo de geração de dados para a DIRF: considerar o ANO_CALENDÁRIO, para recuperar as notas fiscais com os impostos etidos. 
-- Está sendo utilizado o ano de Referência.
-- Rotina: pkb_gera_ird_docto_fiscal.
--
-- Em 02/02/2017 - Angela Inês.
-- Redmine #27938 - Alterar geração de dados da DIRF.
-- Alterar o processo de geração de dados para DIRF passando a não recuperar dos pagamentos de impostos retidos os registros de impostos INSS e ISS.
-- Rotina: pkb_gera_ird_docto_fiscal.
--
-- Em 07/02/2017 - Angela Inês.
-- Redmine #28059 - Geração dos dados de Informe de Rendimento - DIRF.
-- Na geração dos dados de informe de rendimento, considerar a data de entrada e saída (nota_fiscal.dt_sai_ent) e se estiver nula, considerar a data de
-- emissão (nota_fiscal.dt_emiss), para armazenar os valores.
-- Rotina: pkb_gera_ird_docto_fiscal.
--
-- Em 14/03/2017 - Fábio Tavares.
-- Redmine #29257 - Erro ao Desprocessar dados da Gera Dados DIRF - Foi adicionado o delete da tabela r_loteintws_ird
-- Rotina: pkb_desfazer
--
-- Em 29/11/2017 - Marcelo Ono.
-- Redmine #36941 - Correção no processo de geração de dados da DIRF.
-- Gerar as informações mensais de rendimento dos impostos (PIS/COFINS/CSLL) da DIRF pela data do documento.
-- Rotina: pkb_gera_ird_docto_fiscal.
--
-- Em 01/12/2017 - Marcelo Ono.
-- Redmine #37096 - Correção no processo de geração de dados da DIRF.
-- Filtrar as informações mensais de rendimento dos impostos (PIS/COFINS/CSLL) da DIRF pela data do documento.
-- Rotina: pkb_gera_ird_docto_fiscal.
--
-- Em 08/02/2018 - Angela Inês.
-- Redmine #39300 - Correção na geração da DIRF - Data de Documento e Pagamento.
-- Na geração dos dados para DIRF utilizamos o Ano da Data de Documento (dt_docto), e se estiver nula/branco, utilizamos o Ano da Data de Vencimento (dt_vcto),
-- para comparar com o Ano do Calendário (gera_inf_rend_dirf.ano_calend). Essa modificação foi feita através da atividade #36940 - Consultora/Viviane.
-- Antes dessa alteração utilizávamos o Ano da Data de Pagamento (dt_pgto), e se estiver nula/branco, utilizamos o Ano da Data de Vencimento (dt_vcto), para
-- comparar com o Ano do Calendário (gera_inf_rend_dirf.ano_calend). Voltar o processo utilizando a Data de Pagamento.
-- Rotina: pkb_gera_ird_docto_fiscal.
--
-- Em 21/03/2018 - Karina de Paula
-- Redmine #40004 - Geração do Pdf de Informe de Rendimento com valores indevidos.
-- Incluído verificação se existe informes de rendimento incluídos manualmente para a empresa, ano referência e ano calendário que 
-- foi solicitado a exclusão da geração dos informes. Esses registros devem ser excluídos manualmente.
-- Rotina Alterada: pkb_desfazer
--
-- Em 27/03/2018 -  Karina de Paula
-- Redmine #40991 - Verificar OBJ_Referencia que deve ser utilizado na tela "Geração de dados - DIRF"
-- Alterada o valor que estava sendo enviado para a variável global gv_obj_referencia := 'GERACAO_DIRF';
-- Rotina Alterada: pkb_desfazer
--
-- Em 27/03/2018 -  Karina de Paula
-- Redmine #41087 - Melhorar a mensagem de desfazer - Incluído o cod_part na mensagem
-- Rotina Alterada: pkb_desfazer
--
-- Em 25/10/2018 - Karina de Paula
-- Redmine #39990 - Adpatar o processo de geração da DIRF para gerar os registros referente a pagamento de rendimentos a participantes localizados no exterior
-- Rotina Alterada: pkb_criar_inf_rend_dirf / pkb_reg_valores => Incluído rotina para registros RPDE (inf_rend_dirf_rpde)
--
-- Em 19/12/2018 - Karina de Paula
-- Redmine #49719 - Geração de dados da DIRF com erro de geração e não apresenta logs na tela.
-- Rotina Alterada: pkb_gera_ird_docto_fiscal => Alterada a claúsula Group by do select do cursor c_imp_ret
-- Antigo:
-- , decode(tri.cd, '3208', nvl(pir.dt_pgto, pir.dt_vcto)
--                , '0588', nvl(pir.dt_pgto, pir.dt_vcto))
-- Novo:
-- , decode(tri.cd, '3208', nvl(pir.dt_pgto, pir.dt_vcto)
--                , '0588', nvl(pir.dt_pgto, pir.dt_vcto)
--                ,  nvl(pir.dt_docto, pir.dt_vcto))
--
-- Em 21/02/2019 - Renan Alves
-- #51684 - Geração de Informe de Rendimentos
-- Alteração: Foi comentado os cursores C_ITEMNF e C_IMPITEMNF.
--            Foi criado uma variável para para retornar o MULTORG da empresa utilizada, para
--            geração da DIRF.
-- Rotina: pkb_gera_ird_docto_fiscal
--
-- Em 26/02/2019 - Renan Alves
-- #51919 - Erro na geração de dados - dirf
-- Alteração: Foi acrescentado uma verificação antes de criar os registros RPDE
-- Rotina: pkb_criar_inf_rend_dirf
-- 
-------------------------------------------------------------------------------------------------------
--
   erro_de_sistema       number;
--
-- Variáveis globais
   gv_mensagem_log       log_generico_ird.mensagem%TYPE;
   gv_cabec_log          log_generico_ird.mensagem%TYPE;
   gn_referencia_id      log_generico_ird.referencia_id%type := null;
   gv_obj_referencia     log_generico_ird.obj_referencia%type default 'INF_REND_DIRF';
   gn_dt_ref_imp_ret     varchar2(1);   
--
--| registros de impostos retidos
   type tab_csf_imp_ret is record ( tiporetimp_id  number
                                  , pessoa_id      number
                                  , ano            number(4)
                                  , mes            number(2)
                                  , vl_rend_01     number(15,2)
                                  , vl_ir_01       number(15,2)
                                  , vl_rend_02     number(15,2)
                                  , vl_ir_02       number(15,2)
                                  , vl_rend_03     number(15,2)
                                  , vl_ir_03       number(15,2)
                                  , vl_rend_04     number(15,2)
                                  , vl_ir_04       number(15,2)
                                  , vl_rend_05     number(15,2)
                                  , vl_ir_05       number(15,2)
                                  , vl_rend_06     number(15,2)
                                  , vl_ir_06       number(15,2)
                                  , vl_rend_07     number(15,2)
                                  , vl_ir_07       number(15,2)
                                  , vl_rend_08     number(15,2)
                                  , vl_ir_08       number(15,2)
                                  , vl_rend_09     number(15,2)
                                  , vl_ir_09       number(15,2)
                                  , vl_rend_10     number(15,2)
                                  , vl_ir_10       number(15,2)
                                  , vl_rend_11     number(15,2)
                                  , vl_ir_11       number(15,2)
                                  , vl_rend_12     number(15,2)
                                  , vl_ir_12       number(15,2)
                                  );
--
   type t_tab_csf_imp_ret is table of tab_csf_imp_ret index by varchar2(14);      -- binary_integer;
   type t_bi_tab_csf_imp_ret is table of t_tab_csf_imp_ret index by varchar2(14); -- binary_integer;
   vt_bi_tab_csf_imp_ret t_bi_tab_csf_imp_ret;
--
--| registros de deducao de dependentes
   type tab_csf_imp_ded_dep is record ( tiporetimp_id  number
                                      , pessoa_id      number
                                      , ano            number(4)
                                      , mes            number(2)
                                      , vl_dedu_01     number(15,2)
                                      , vl_dedu_02     number(15,2)
                                      , vl_dedu_03     number(15,2)
                                      , vl_dedu_04     number(15,2)
                                      , vl_dedu_05     number(15,2)
                                      , vl_dedu_06     number(15,2)
                                      , vl_dedu_07     number(15,2)
                                      , vl_dedu_08     number(15,2)
                                      , vl_dedu_09     number(15,2)
                                      , vl_dedu_10     number(15,2)
                                      , vl_dedu_11     number(15,2)
                                      , vl_dedu_12     number(15,2)
                                      );
--
   type t_tab_csf_imp_ded_dep is table of tab_csf_imp_ded_dep index by varchar2(14);      -- binary_integer;
   type t_bi_tab_csf_imp_ded_dep is table of t_tab_csf_imp_ded_dep index by varchar2(14); -- binary_integer;
   vt_bi_tab_csf_imp_ded_dep t_bi_tab_csf_imp_ded_dep;
--
-------------------------------------------------------------------------------------------------------
-- Rendimentos pag os a residentes ou domiciliados no exterior (RPDE)
--
   type tab_csf_imp_ret_rpde is record ( pessoa_id      number
                                       , dm_tipo_rend   number(3)
                                       , dm_fonte_pag   number(3)
                                       , dm_forma_trib  number(2)
                                       , data_pgto      date
                                       , vl_rend_pago   number(15,2)
                                       , vl_imp_ret     number(15,2)
                                       );
   --
   /*type t_tab_rpde is table of tp_rpde index by binary_integer;
   vt_tab_rpde t_tab_rpde; */
   type t_tab_csf_imp_ret_rpde is table of tab_csf_imp_ret_rpde index by varchar2(14);      -- binary_integer;
   type t_bi_tab_csf_imp_ret_rpde is table of t_tab_csf_imp_ret_rpde index by varchar2(14); -- binary_integer;
   vt_bi_tab_csf_imp_ret_rpde t_bi_tab_csf_imp_ret_rpde;

-------------------------------------------------------------------------------------------------------

   gt_row_gera_inf_rend_dirf gera_inf_rend_dirf%rowtype;

-------------------------------------------------------------------------------------------------------
--| Procedimento de geração dos dados
procedure pkb_geracao ( en_gerainfrenddirf_id in gera_inf_rend_dirf.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento de desfazer a geração
procedure pkb_desfazer ( en_gerainfrenddirf_id in gera_inf_rend_dirf.id%type );

-------------------------------------------------------------------------------------------------------

end pk_gera_inf_rend_dirf;
/
