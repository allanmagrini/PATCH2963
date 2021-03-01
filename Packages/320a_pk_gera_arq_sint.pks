create or replace package csf_own.pk_gera_arq_sint is
---------------------------------------------------------------------------------------------------------------
-- Especificacao do pacote de procedimentos de criacao do arquivo do sintegra
--
-- Em 24/02/2021   - Wendel Albino - Patch 2.9.5-5/ 2.9.6-2/ release 297
-- Redmine #75073  - Arquivo do SINTEGRA não está gerando
-- Rotina alterada - PKB_INSERT_TABELA_TMP -> criacao de procedure nova para gravar registros temporarios 0050 e 0074 para ganho de performance.
--                 - PKB_GERA_ARQUIVO_SINT -> inclusao da ifs para nao chamar a pk_csf_api quando nao houver itens. criacao log no exception.
--                 - PKB_MONTA_REG_0050/ PKB_MONTA_REG_0074 -> alteracao dos selects do cursor para buscar nas tabelas temporarias (tmp_sintegra_reg_0050,tmp_sintegra_reg_0074)
--
-- Em 18/11/2020   - Joao Carlos.
-- Ficha #73294    - As notas inutilizadas integradas pelo ERP do cliente, não estavam sendo exportadas para o arquivos do DIEF,
--                 - somente as notas alteradas como inutilizadas estavam sendo exportadas
-- Rotina alterada - PKB_MONTA_REG_0050 e PKB_ARMAZ_REG_0050
--
-- Em 26/10/2020 - Joao Carlos.
-- Ficha #72485 - Ao exportar o DIEF MA as NFs inutilizadas estao sendo exportadas com valor, com isso altera o Livro do DIEF,
-- inserida condicao, para que os valores das NFs inutilizadas, sejam zerados.
--
-- Em 09/11/2012 - Angela Ines.
-- Ficha HD 59771 - Considerar 14 caracteres para o codigo do produto, em todos os registros.
-- N?o considerar 00 nos codigos dos tipos de registros (exemplo: 0010, deve ser 10);
-- Considerar as notas fiscais de modelo 04 e 55 para o registro 50.
--
-- Em 15/07/2013 - Angela Inês.
-- Redmine Atividade #376 - Islaine/Leandro - Geração do Arquivo do Sintegra - Ficha 66797.
-- Não gerar os registro 0054 e 0075 para modelo de Nota 21 - NF Serv.Comun.
-- Rotina: pkb_monta_reg_0054.
-- Eliminado os comentários de rotinas que não geram os dados - limpeza geral do código.
-- Caso seja necessário verificar pelo repositório.
--
-- Em 08/08/2013 - Angela Inês.
-- Redmine Atividade #376 - Islaine/Leandro - Geração do Arquivo do Sintegra - Ficha 66797.
-- Não gerar os registro 0054 e 0075 para modelo de Nota 21 - NF Serv.Comun.
-- Processo de notas fiscais de serviço contínuo.
-- Rotina: pkb_monta_reg_0054.
--
-- Em 21/08/2013 - Angela Inês.
-- Redmine #451 - Validação de informações Fiscais.
-- Inclusão do processo de validação das notas fiscais, dos conhecimentos de transporte e dos cupons fiscais.
-- Rotina: pkb_validar.
--
-- Em 16/09/2013 - Angela Inês.
-- Redmine #649 - Recuperação dos cupons fiscais.
-- O processo do Sintegra foi alterado para considerar reducao_z_ecf.dm_st_proc = 1 (validado).
-- Rotinas: pkb_monta_reg_0060m, pkb_monta_reg_0060a, pkb_monta_reg_0060d, pkb_monta_reg_0060i e pkb_monta_reg_0060r.
--
-- Em 11/11/2013 - Angela Inês.
-- Redmine #1397 - Sintegra, erro na geração - Ficha ServiceDesk 17196.
-- Erro Tipo Erro Total - Registro tipo 53 ¿ Contêm dois ou mais registros para um DF com mesmo CFOP Rejeição 100.
-- Rotina: pkb_monta_reg_0053.
--
-- Em 13/11/2013 - Angela Inês.
-- Redmine #1421 - Alteração: Incluir '0' antes do cnpj para completar 14 posições nos tipos de registro 88-sms e 88-sme.
-- Rotinas: pkb_armaz_reg_0088_sme e pkb_armaz_reg_0088_sms.
--
-- Em 11/12/2013 - Angela Inês.
-- Emilinada as funções de validação dos documentos fiscais.
-- Rotina: pkb_validar.
--
-- Em 13/12/2013 - Angela Inês.
-- Redmine #1602 - Processo Sintegra. Rejeição do arquivo texto gerado.
-- Correção no processo do registro 51:
-- Montar o registro tipo 51 com espaços ou zeros quando não houver informações de notas fiscais. Arquivo zerado, sem movimentação.
--
-- Em 20/02/2014 - Angela Inês.
-- Redmine #1924 - Validador envia mensagens de erro com diferença nos totalizadores dos cupons.
-- 1) Para os valores analíticos dos documentos fiscais não considerar os registros cancelados de acordo com a situação do documento.
-- Rotinas: pkb_monta_reg_0060m, pkb_monta_reg_0060a, pkb_monta_reg_0060d, pkb_monta_reg_0060i e pkb_monta_reg_0060r.
--
--
-- Em 04/12/2014 - Leandro Savenhago.
-- HelpDesk #1629 -
-- Rotina: PKB_MONTA_REG_0076 - Corrigido a definição do tipo de variável v_subserie e v_serie, criado indice para melhoria de performance
--
-- Em 11/06/2015 - Rogério Silva.
-- Redmine #8226 - Processo de Registro de Log em Packages - LOG_GENERICO
--
-- Em 30/07/2015 - Rogério Silva
-- Redmine #10211 - Códigos de País - IBGE e SISCOMEX. Geração do Sintegra.
--
-- Em 30/07 e 14/08/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 27/10/2016 - Angela Inês.
-- Redmine #24781 - Correção na Montagem do Registro Tipo 51 - Valores de IPI - Arquivo Sintegra.
-- Se houve Apuração de IPI para a empresa em questão e período do arquivo, montar o registro 51, caso contrário não montar o registro.
-- Rotina: pkb_monta_reg_0051.
--
-- Em 27/10/2016 - Angela Inês.
-- Redmine #24782 - Correção na Montagem do Registro Tipo 51 - Valores de IPI - Arquivo Sintegra.
-- 1) No processo atual, consideramos a Apuração do IPI para montagem do registro 51, a partir da Release 275, eliminar a consideração com a Apuração do IPI.
-- 2) Menu: Sped/Cadastro/Participantes, Aba Parâmetros. Quando o Tipo de parâmetro for 10-Indicador de Tipo de Atividade e o Valor for 0-Industrial ou Equiparado
-- a Industrial, montar o registro 51, caso contrário não montar o registro.
-- Rotina: pkb_monta_reg_0051.
--
-- Em 21/03/2017 - Fábio Tavares.
-- Redmine #29160 - VALIDAPR COM ERRO NO TOTALIZADOR
-- Rotinas: pkb_monta_reg_0010 e pkb_monta_reg_0090.
--
-- Em 21/07/2017 - Angela Inês.
-- Redmine #33011 - Alterar o processo de geração do arquivo Sintegra.
-- 1) Atualizar o valor do campo 6-Número de registros tipo 90, do Registro 90, para quantidade total de linhas do registros 90, em todas as linhas do registro 90.
-- 2) As linhas do tipo de registro 90 devem ser somadas para o final da linha como total do registro 99, pois a primeira linha do registro 90 não estava sendo
-- somada.
-- 3) Ordenar as notas fiscais de modelo: '01-NF', '04-NF Produtor Rural', '55-NFe', '65-NF Energia Elétrica', '06-NF Serv.Telecomun' e '22-NF Serv.Telecomun';
-- por número de nota (nota_fiscal.nro_nf), e seu identificador (nota_fiscal.id), e em seguida por número de item de nota fiscal (item_nota_fiscal.nro_item), e
-- não pelo identificador do item da nota fiscal (item_nota_fiscal.id).
-- Rotinas: pkb_monta_reg_0054 e pkb_monta_reg_0090.
--
-- Em 14/09/2017 - Leandro
-- Redmine #34620 - Geração do Sintegra sem NFe Complementar (Omega Amazon)
-- Considerado nas pesquisas de dados de Nota Fiscal, todas as codições de "Situacao do Documento Fiscal"
--
-- Em 09/11/2017 - Leandro
-- Redmine #34020 - Geração de Sintegra consideração o Indicados da Natureza
--
-- Em 22/01/2018 - Angela Inês.
-- Redmine #38740 - Correção nos processos de Informação Sobre Exportação - Recuperação dos registros.
-- Alterar os objetos que utilizam a tabela de Informação Sobre Exportação e considerar a DATA DE AVERBAÇÃO (DT_AVB) ao invés de considerar a DATA DA
-- DECLARAÇÃO (DT_DE), para recuperação dos registros.
-- Rotina: pkb_monta_reg_0085.
--
-- Em 23/01/2019 - Angela Inês.
-- Redmine #48915 - ICMS FCP e ICMS FCP ST.
-- Atribuir os campos referente aos valores de FCP que são retornados na função de valores do Item da Nota Fiscal (pkb_vlr_fiscal_item_nf).
--
-- Em 29/01/2019 - Marcos Ferreira
-- Redmine #49524 - Funcionalidade - Base Isenta e Outros de Conhecimento de Transporte cuja emissão é própria
-- Solicitação: Alterar a chamda da procedure pk_csf_api_d100.pkb_vlr_fiscal_ct_d100 para pk_csf_ct.pkb_vlr_fiscal_ct
-- Procedures Alteradas: pkb_monta_reg_0070
--
---------------------------------------------------------------------------------------------------------------

   -- registro tipo 10
   type tab_reg_0010 is record ( tipo                  number(02)  -- campo 1
                               , cnpj                varchar2(14)  -- campo 2
                               , ie                  varchar2(14)  -- campo 3
                               , nome_contrib        varchar2(35)  -- campo 4
                               , nome_mun            varchar2(30)  -- campo 5
                               , uf                  varchar2(02)  -- campo 6
                               , fax                   number(10)  -- campo 7
                               , dt_ini                number(08)  -- campo 8
                               , dt_fin                number(08)  -- campo 9
                               , dm_ident_conv       varchar2(01)  -- campo 10
                               , dm_ident_nat        varchar2(01)  -- campo 11
                               , dm_fin_arq          varchar2(01)  -- campo 12
                               );

   type t_tab_reg_0010 is table of tab_reg_0010 index by binary_integer;
   vt_tab_reg_0010 t_tab_reg_0010;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 11
   type tab_reg_0011 is record ( tipo                   number(02)  -- campo 1
                               , logradouro           varchar2(34)  -- campo 2
                               , numero                 number(05)  -- campo 3
                               , complemento          varchar2(22)  -- campo 4
                               , bairro               varchar2(15)  -- campo 5
                               , cep                    number(08)  -- campo 6
                               , nome_contato         varchar2(28)  -- campo 7
                               , telefone               number(12)  -- campo 8
                               );

   type t_tab_reg_0011 is table of tab_reg_0011 index by binary_integer;
   vt_tab_reg_0011 t_tab_reg_0011;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 50
   type tab_reg_0050 is record ( tipo                     number(02)  -- campo 1
                               , cnpj                   varchar2(14)  -- campo 2
                               , ie                     varchar2(14)  -- campo 3
                               , dt_emis_receb            number(08)  -- campo 4
                               , uf                     varchar2(02)  -- campo 5
                               , modelo                   number(02)  -- campo 6
                               , serie                  varchar2(03)  -- campo 7
                               , numero                   number(06)  -- campo 8
                               , cfop                     number(04)  -- campo 9
                               , emitente               varchar2(01)  -- campo 10
                               , valor_total              number(13)  -- campo 11
                               , base_calculo_icms        number(13)  -- campo 12
                               , valor_icms               number(13)  -- campo 13
                               , isenta_nao_tributada     number(13)  -- campo 14
                               , outras                   number(13)  -- campo 15
                               , aliquota                 number(04)  -- campo 16
                               , situacao               varchar2(01)  -- campo 17
                               );

   type t_tab_reg_0050 is table of tab_reg_0050 index by binary_integer;
   type t_bi_tab_reg_0050 is table of t_tab_reg_0050 index by binary_integer;
   type t_tri_tab_reg_0050 is table of t_bi_tab_reg_0050 index by binary_integer;
   vt_tri_tab_reg_0050 t_tri_tab_reg_0050;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 51
   type tab_reg_0051 is record ( tipo                     number(02)  -- campo 1
                               , cnpj                   varchar2(14)  -- campo 2
                               , ie                     varchar2(14)  -- campo 3
                               , dt_emis_receb            number(08)  -- campo 4
                               , uf                     varchar2(02)  -- campo 5
                               , serie                  varchar2(03)  -- campo 7
                               , numero                   number(06)  -- campo 8
                               , cfop                     number(04)  -- campo 9
                               , valor_total              number(13)  -- campo 10
                               , valor_ipi                number(13)  -- campo 11
                               , isenta_nao_trib_ipi      number(13)  -- campo 12
                               , outras_ipi               number(13)  -- campo 13
                               , brancos                varchar2(20)  -- campo 14
                               , situacao               varchar2(01)  -- campo 15
                               );

   type t_tab_reg_0051 is table of tab_reg_0051 index by binary_integer;
   vt_tab_reg_0051 t_tab_reg_0051;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 53
   type tab_reg_0053 is record ( tipo                         number(02)  -- campo 1
                               , cnpj                       varchar2(14)  -- campo 2
                               , ie                         varchar2(14)  -- campo 3
                               , dt_emis_receb                number(08)  -- campo 4
                               , uf                         varchar2(02)  -- campo 5
                               , modelo                       number(02)  -- campo 6
                               , serie                      varchar2(03)  -- campo 7
                               , numero                       number(06)  -- campo 8
                               , cfop                         number(04)  -- campo 9
                               , emitente                   varchar2(01)  -- campo 10
                               , base_calculo_icms_st         number(13)  -- campo 11
                               , icms_retido                  number(13)  -- campo 12
                               , despesas_acessorias          number(13)  -- campo 13
                               , situacao                   varchar2(01)  -- campo 14
                               , cod_antecipacao            varchar2(01)  -- campo 15
                               , brancos                    varchar2(29)  -- campo 16
                               );

   type t_tab_reg_0053 is table of tab_reg_0053 index by binary_integer;
   vt_tab_reg_0053 t_tab_reg_0053;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 54
   type tab_reg_0054 is record ( tipo                         number(02)  -- campo 1
                               , cnpj                       varchar2(14)  -- campo 2
                               , modelo                       number(02)  -- campo 3
                               , serie                      varchar2(03)  -- campo 4
                               , numero                       number(06)  -- campo 5
                               , cfop                         number(04)  -- campo 6
                               , cst                        varchar2(03)  -- campo 7
                               , numero_item                  number(03)  -- campo 8
                               , codigo_produto_servico     varchar2(14)  -- campo 9
                               , quantidade                   number(11)  -- campo 10
                               , valor_produto                number(12)  -- campo 11
                               , valor_desc_desp_acess        number(12)  -- campo 12
                               , base_calc_icms               number(12)  -- campo 13
                               , base_calc_icms_st            number(12)  -- campo 14
                               , valor_ipi                    number(12)  -- campo 15
                               , aliq_icms                    number(04)  -- campo 16
                               );

   type t_tab_reg_0054 is table of tab_reg_0054 index by binary_integer;
   vt_tab_reg_0054 t_tab_reg_0054;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 55
   type tab_reg_0055 is record ( tipo                         number(02)  -- campo 1
                               , cnpj                       varchar2(14)  -- campo 2
                               , ie                         varchar2(14)  -- campo 3
                               , data_gnre                    number(08)  -- campo 4
                               , uf_substituto              varchar2(02)  -- campo 5
                               , uf_favorecida              varchar2(02)  -- campo 6
                               , banco_gnre                   number(03)  -- campo 7
                               , agencia_gnre                 number(04)  -- campo 8
                               , numero_gnre                varchar2(20)  -- campo 9
                               , valor_gnre                   number(13)  -- campo 10
                               , data_vencimento              number(08)  -- campo 11
                               , mes_ano_ref                  number(06)  -- campo 12
                               , num_conv_prot_merc         varchar2(30)  -- campo 13
                               );

   type t_tab_reg_0055 is table of tab_reg_0055 index by binary_integer;
   vt_tab_reg_0055 t_tab_reg_0055;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 56
   type tab_reg_0056 is record ( tipo                          number(02)  -- campo 1
                               , cnpj_cpf                    varchar2(14)  -- campo 2
                               , modelo                        number(02)  -- campo 3
                               , serie                       varchar2(03)  -- campo 4
                               , numero                        number(06)  -- campo 5
                               , cfop                          number(04)  -- campo 6
                               , cst                           number(03)  -- campo 7
                               , numero_item                   number(03)  -- campo 8
                               , cod_prod_serv               varchar2(14)  -- campo 9
                               , tipo_operacao                 number(01)  -- campo 10
                               , cnpj_concessionaria         varchar2(14)  -- campo 11
                               , aliquota_ipi                  number(04)  -- campo 12
                               , chassi                      varchar2(17)  -- campo 13
                               , brancos                     varchar2(39)  -- campo 13
                               );

   type t_tab_reg_0056 is table of tab_reg_0056 index by binary_integer;
   vt_tab_reg_0056 t_tab_reg_0056;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 57
   type tab_reg_0057 is record (  tipo               number(02)  -- campo 1
                               ,  cnpj             varchar2(14)  -- campo 2
                               ,  ie               varchar2(14)  -- campo 3
                               ,  modelo             number(02)  -- campo 4
                               ,  serie            varchar2(03)  -- campo 5
                               ,  numero             number(06)  -- campo 6
                               ,  cfop               number(04)  -- campo 7
                               ,  cst              varchar2(03)  -- campo 8
                               ,  numero_item        number(03)  -- campo 9
                               ,  cod_prod         varchar2(14)  -- campo 10
                               ,  num_lote_prod    varchar2(20)  -- campo 11
                               ,  branco           varchar2(41)  -- campo 12
                               );

   type t_tab_reg_0057 is table of tab_reg_0057 index by binary_integer;
   vt_tab_reg_0057 t_tab_reg_0057;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 60M
   type tab_reg_0060M is record (  tipo                            number(02)  -- campo 1
                                 , subtipo                       varchar2(01)  -- campo 2
                                 , data_emissao                    number(08)  -- campo 3
                                 , num_serie_fabr                varchar2(20)  -- campo 4
                                 , num_ord_sequencial_equip        number(03)  -- campo 5
                                 , modelo_doc_fiscal             varchar2(02)  -- campo 6
                                 , num_cont_ord_oper_ini_dia       number(06)  -- campo 7
                                 , num_cont_ord_oper_fim_dia       number(06)  -- campo 8
                                 , num_cont_red_z                  number(06)  -- campo 9
                                 , cont_reinicio_oper              number(03)  -- campo 10
                                 , valor_venda_bruta               number(16)  -- campo 11
                                 , valor_tot_geral_equip           number(16)  -- campo 12
                                 , brancos                       varchar2(37)  -- campo 13
                                 );

   type t_tab_reg_0060M is table of tab_reg_0060M index by binary_integer;
   vt_tab_reg_0060M t_tab_reg_0060M;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 60A
   type tab_reg_0060A is record (  tipo                            number(02)  -- campo 1
                                 , subtipo                       varchar2(01)  -- campo 2
                                 , data_emissao                    number(08)  -- campo 3
                                 , num_serie_fabr                varchar2(20)  -- campo 4
                                 , sit_trib_aliq                 varchar2(04)  -- campo 5
                                 , valor_acum_tot_parc             number(12)  -- campo 6
                                 , brancos                       varchar2(79)  -- campo 7
                                 );

   type t_tab_reg_0060A is table of tab_reg_0060A index by binary_integer;
   type t_bi_tab_reg_0060A is table of t_tab_reg_0060A index by binary_integer;
   vt_bi_tab_reg_0060A t_bi_tab_reg_0060A;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 60D
   type tab_reg_0060D is record (  tipo                            number(02)  -- campo 1
                                 , subtipo                       varchar2(01)  -- campo 2
                                 , data_emissao                    number(08)  -- campo 3
                                 , num_serie_fabr                varchar2(20)  -- campo 4
                                 , codigo_produto_servico        varchar2(14)  -- campo 5
                                 , quantidade                      number(13)  -- campo 6
                                 , valor_merc_prod_serv            number(16)  -- campo 7
                                 , base_calc_icms                  number(16)  -- campo 8
                                 , sit_trib_aliq                 varchar2(04)  -- campo 9
                                 , valor_icms                      number(13)  -- campo 10
                                 , brancos                       varchar2(19)  -- campo 11
                                 );

   type t_tab_reg_0060D is table of tab_reg_0060D index by binary_integer;
   type t_bi_tab_reg_0060D is table of t_tab_reg_0060D index by binary_integer;
   type t_tri_tab_reg_0060D is table of t_bi_tab_reg_0060D index by binary_integer;
   vt_tri_tab_reg_0060D t_tri_tab_reg_0060D;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 60 I
   type tab_reg_0060I is record (  tipo                            number(02)  -- campo 1
                                 , subtipo                       varchar2(01)  -- campo 2
                                 , data_emissao                    number(08)  -- campo 3
                                 , num_serie_fabr                varchar2(20)  -- campo 4
                                 , modelo_doc_fiscal             varchar2(02)  -- campo 5
                                 , nro_ord_doc_fisc                number(06)  -- campo 6
                                 , num_item                        number(03)  -- campo 7
                                 , cod_merc_prod_serv            varchar2(14)  -- campo 8
                                 , quantidade                      number(13)  -- campo 9
                                 , vl_merc_prod                    number(13)  -- campo 10
                                 , base_calc_icms                  number(12)  -- campo 11
                                 , sit_trib_aliq                 varchar2(04)  -- campo 12
                                 , valor_icms                      number(12)  -- campo 13
                                 , brancos                       varchar2(16)  -- campo 14
                                 );

   type t_tab_reg_0060I is table of tab_reg_0060I index by binary_integer;
   type t_bi_tab_reg_0060I is table of t_tab_reg_0060I index by binary_integer;
   vt_bi_tab_reg_0060I t_bi_tab_reg_0060I;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 60R
   type tab_reg_0060R is record (  tipo                            number(02)  -- campo 1
                                 , subtipo                       varchar2(01)  -- campo 2
                                 , mes_ano_emissao                 number(06)  -- campo 3
                                 , cod_merc_prod                 varchar2(14)  -- campo 4
                                 , quantidade                      number(13)  -- campo 5
                                 , vl_merc_prod                    number(16)  -- campo 6
                                 , base_calc_icms                  number(16)  -- campo 7
                                 , sit_trib_aliq                 varchar2(04)  -- campo 8
                                 , brancos                       varchar2(54)  -- campo 9
                                 );

   type t_tab_reg_0060R is table of tab_reg_0060R index by binary_integer;
   vt_tab_reg_0060R t_tab_reg_0060R;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 61
   type tab_reg_0061 is record (  tipo                          number(02)  -- campo 1
                                 ,brancos_1                   varchar2(14)  -- campo 2
                                 ,brancos_2                   varchar2(14)  -- campo 3
                                 ,data_emissao                  number(08)  -- campo 4
                                 ,modelo                        number(02)  -- campo 5
                                 ,serie                       varchar2(03)  -- campo 6
                                 ,subserie                    varchar2(02)  -- campo 7
                                 ,num_ini_ord                   number(06)  -- campo 8
                                 ,num_fim_ord                   number(06)  -- campo 9
                                 ,valor_total                   number(13)  -- campo 10
                                 ,base_calc_icms                number(13)  -- campo 11
                                 ,valor_icms                    number(12)  -- campo 42
                                 ,isenta_nao_tributadas         number(13)  -- campo 13
                                 ,outras                        number(13)  -- campo 14
                                 ,aliquota                      number(04)  -- campo 15
                                 ,branco_3                    varchar2(01)  -- campo 16
                                 );

   type t_tab_reg_0061 is table of tab_reg_0061 index by binary_integer;
   vt_tab_reg_0061 t_tab_reg_0061;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 61R
   type tab_reg_0061R is record ( tipo                             number(02)  -- campo 1
                                 ,mestre_analit_res              varchar2(01)  -- campo 2
                                 ,mes_ano_emissao                  number(06)  -- campo 3
                                 ,cod_prod                       varchar2(14)  -- campo 4
                                 ,quantidade                       number(13)  -- campo 5
                                 ,valor_bruto_produto              number(16)  -- campo 6
                                 ,base_calc_icms                   number(16)  -- campo 7
                                 ,aliquota_produto                 number(04)  -- campo 8
                                 ,brancos                        varchar2(54)  -- campo 9
                                 );

   type t_tab_reg_0061R is table of tab_reg_0061R index by binary_integer;
   vt_tab_reg_0061R t_tab_reg_0061R;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 70
   type tab_reg_0070 is record (    tipo                             number(02)  -- campo 1
                                   ,cnpj                           varchar2(14)  -- campo 2
                                   ,ie                             varchar2(14)  -- campo 3
                                   ,dt_emiss_utiliz                  number(08)  -- campo 4
                                   ,uf                             varchar2(02)  -- campo 5
                                   ,modelo                           number(02)  -- campo 6
                                   ,serie                          varchar2(01)  -- campo 7
                                   ,subserie                       varchar2(02)  -- campo 8
                                   ,numero                           number(06)  -- campo 9
                                   ,cfop                             number(04)  -- campo 10
                                   ,vl_tot_doc_fisc                  number(13)  -- campo 11
                                   ,base_calc_icms                   number(14)  -- campo 12
                                   ,vl_icms                          number(14)  -- campo 13
                                   ,isenta_nao_tribut                number(14)  -- campo 14
                                   ,outras                           number(14)  -- campo 15
                                   ,cif_fob_outros                   number(01)  -- campo 16
                                   ,situacao                       varchar2(01)  -- campo 17
                                   );

   type t_tab_reg_0070 is table of tab_reg_0070 index by binary_integer;
   vt_tab_reg_0070 t_tab_reg_0070;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 71
   type tab_reg_0071 is record (    tipo                       number(02)  -- campo 1
                                   ,cnpj_tomador             varchar2(14)  -- campo 2
                                   ,ie_tomador               varchar2(14)  -- campo 3
                                   ,data_emissao               number(08)  -- campo 4
                                   ,uf_tomador               varchar2(02)  -- campo 5
                                   ,modelo                     number(02)  -- campo 6
                                   ,serie                    varchar2(01)  -- campo 7
                                   ,subserie                 varchar2(02)  -- campo 8
                                   ,numero                     number(06)  -- campo 9
                                   ,uf_rem_dest_nf           varchar2(02)  -- campo 10
                                   ,cnpj_rem_dest_nf         varchar2(14)  -- campo 11
                                   ,ie_rem_dest_nf           varchar2(14)  -- campo 12
                                   ,data_emissao_nf            number(08)  -- campo 13
                                   ,modelo_nf                varchar2(02)  -- campo 14
                                   ,serie_nf                 varchar2(03)  -- campo 15
                                   ,num_nf                     number(06)  -- campo 16
                                   ,valor_tot_nf               number(14)  -- campo 17
                                   ,brancos                  varchar2(12)  -- campo 18
                                   );

   type t_tab_reg_0071 is table of tab_reg_0071 index by binary_integer;
   vt_tab_reg_0071 t_tab_reg_0071;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 74
   type tab_reg_0074 is record (    tipo                            number(02)  -- campo 1
                                   ,data_inventario                 number(08)  -- campo 2
                                   ,cod_prod                      varchar2(14)  -- campo 3
                                   ,quantidade                      number(13)  -- campo 4
                                   ,valor_prod                      number(13)  -- campo 5
                                   ,cod_posse_merc_invent         varchar2(01)  -- campo 6
                                   ,cnpj_possuidor_prop           varchar2(14)  -- campo 7
                                   ,ie_possuidor_prop             varchar2(14)  -- campo 8
                                   ,uf_possuidor_prop             varchar2(02)  -- campo 9
                                   ,brancos                       varchar2(45)  -- campo 10
                                   );

   type t_tab_reg_0074 is table of tab_reg_0074 index by binary_integer;
   vt_tab_reg_0074 t_tab_reg_0074;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 75
   type tab_reg_0075 is record (    tipo                  number(02)  -- campo 1
                                   ,data_inicial          number(08)  -- campo 2
                                   ,data_final            number(08)  -- campo 3
                                   ,cod_produto_serv    varchar2(14)  -- campo 4
                                   ,cod_ncm             varchar2(08)  -- campo 5
                                   ,descricao           varchar2(53)  -- campo 6
                                   ,unid_med_comerc     varchar2(06)  -- campo 7
                                   ,aliquota_ipi          number(05)  -- campo 8
                                   ,aliquota_icms         number(04)  -- campo 9
                                   ,red_base_calc_icms    number(05)  -- campo 10
                                   ,base_calc_icms_st     number(13)  -- campo 11
                                   );

   type t_tab_reg_0075 is table of tab_reg_0075 index by binary_integer;
   vt_tab_reg_0075 t_tab_reg_0075;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 76
   type tab_reg_0076 is record (    tipo                       number(02)  -- campo 1
                                   ,cnpj_cpf                 varchar2(14)  -- campo 2
                                   ,ie                       varchar2(14)  -- campo 3
                                   ,modelo                     number(02)  -- campo 4
                                   ,serie                    varchar2(02)  -- campo 5
                                   ,subserie                 varchar2(02)  -- campo 6
                                   ,numero                     number(10)  -- campo 7
                                   ,cfop                       number(04)  -- campo 8
                                   ,tipo_receita               number(01)  -- campo 9
                                   ,data_emissao_receb         number(08)  -- campo 10
                                   ,uf                       varchar2(02)  -- campo 11
                                   ,valor_total                number(13)  -- campo 12
                                   ,base_calc_icms             number(13)  -- campo 13
                                   ,valor_icms                 number(12)  -- campo 14
                                   ,isenta_nao_tribut          number(12)  -- campo 15
                                   ,outras                     number(12)  -- campo 16
                                   ,aliquota                   number(02)  -- campo 17
                                   ,situacao                 varchar2(01)  -- campo 18
                                   );

   type t_tab_reg_0076 is table of tab_reg_0076 index by binary_integer;
   vt_tab_reg_0076 t_tab_reg_0076;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 77
   type tab_reg_0077 is record (    tipo                       number(02)  -- campo 1
                                   ,cnpj_cpf                 varchar2(14)  -- campo 2
                                   ,modelo                     number(02)  -- campo 3
                                   ,serie                    varchar2(02)  -- campo 4
                                   ,subserie                 varchar2(02)  -- campo 5
                                   ,numero                     number(10)  -- campo 6
                                   ,cfop                       number(04)  -- campo 7
                                   ,tipo_receita               number(01)  -- campo 8
                                   ,num_item                   number(03)  -- campo 9
                                   ,cod_serv                 varchar2(11)  -- campo 10
                                   ,quantidade                 number(13)  -- campo 11
                                   ,vl_servico                 number(12)  -- campo 12
                                   ,vl_desc_acess              number(12)  -- campo 13
                                   ,base_calc_icms             number(12)  -- campo 14
                                   ,aliquota_icms              number(02)  -- campo 15
                                   ,cnpj_mf                  varchar2(14)  -- campo 16
                                   ,cod_num_terminal           number(10)  -- campo 17
                                   );

   type t_tab_reg_0077 is table of tab_reg_0077 index by binary_integer;
   vt_tab_reg_0077 t_tab_reg_0077;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 85
   type tab_reg_0085 is record (    tipo                        varchar2(02)  -- campo 1
                                   ,decl_exportacao               number(11)  -- campo 2
                                   ,dt_decl                       number(08)  -- campo 3
                                   ,nat_exportacao              varchar2(01)  -- campo 4
                                   ,reg_exportacao                number(12)  -- campo 5
                                   ,data_registro                 number(08)  -- campo 6
                                   ,conhecimento_embarque       varchar2(16)  -- campo 7
                                   ,dt_conhecimento               number(08)  -- campo 8
                                   ,tipo_conhecimento             number(02)  -- campo 9
                                   ,pais                          number(04)  -- campo 10
                                   ,reservado                     number(08)  -- campo 11
                                   ,dt_averb_decl_exp             number(08)  -- campo 12
                                   ,nf_exportacao                 number(06)  -- campo 13
                                   ,dt_emissao                    number(08)  -- campo 14
                                   ,modelo                        number(02)  -- campo 15
                                   ,serie                         number(03)  -- campo 16
                                   ,brancos                     varchar2(19)  -- campo 17
                                   );

   type t_tab_reg_0085 is table of tab_reg_0085 index by binary_integer;
   vt_tab_reg_0085 t_tab_reg_0085;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 86
   type tab_reg_0086 is record (    tipo                 varchar2(02)  -- campo 1
                                   ,reg_exportacao         number(12)  -- campo 2
                                   ,dt_registro            number(08)  -- campo 3
                                   ,cnpj_remetente       varchar2(14)  -- campo 4
                                   ,ie_remetente         varchar2(14)  -- campo 5
                                   ,uf                   varchar2(02)  -- campo 6
                                   ,numero_nf              number(06)  -- campo 7
                                   ,dt_emissao             number(08)  -- campo 8
                                   ,modelo                 number(02)  -- campo 9
                                   ,serie                varchar2(03)  -- campo 10
                                   ,cod_produto          varchar2(14)  -- campo 11
                                   ,quantidade             number(11)  -- campo 12
                                   ,vl_unit_prod           number(12)  -- campo 13
                                   ,vl_prod                number(12)  -- campo 14
                                   ,relacionamento         number(01)  -- campo 15
                                   ,brancos              varchar2(05)  -- campo 16
                                   );

   type t_tab_reg_0086 is table of tab_reg_0086 index by binary_integer;
   vt_tab_reg_0086 t_tab_reg_0086;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 88 - detalhe 01
   type tab_reg_0088_01 is record ( tipo                 varchar2(02)
                                  , detalhe              varchar2(02)
                                  , periodo              varchar2(6)
                                  , tipo_oper            varchar2(1)
                                  , descricao            varchar2(49)
                                  , cfop                 number(4)
                                  , uf                   varchar2(2)
                                  , unid_com             varchar2(6)
                                  , qtde                 number(11)
                                  , vl_contabil          number(13)
                                  , vl_base_calc_icms    number(13)
                                  , vl_icms              number(13)
                                  , aliq                 number(4)
                                  );

   type t_tab_reg_0088_01 is table of tab_reg_0088_01 index by binary_integer;
   vt_tab_reg_0088_01 t_tab_reg_0088_01;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 88 - detalhe 02
   type tab_reg_0088_02 is record ( tipo                 varchar2(02)  -- campo 1
                                  , detalhe              varchar2(02)
                                  , periodo              varchar2(6)
                                  , tipo_oper            varchar2(1)
                                  , descricao            varchar2(49)
                                  , cfop                 number(4)
                                  , unid_com             varchar2(6)
                                  , qtde                 number(11)
                                  , insentivo_fiscal     varchar2(1)
                                  , vl_contabil          number(13)
                                  , vl_base_calc_icms    number(13)
                                  , vl_icms              number(13)
                                  , aliq                 number(4)
                                  );

   type t_tab_reg_0088_02 is table of tab_reg_0088_02 index by binary_integer;
   vt_tab_reg_0088_02 t_tab_reg_0088_02;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 88 - detalhe CF
   type tab_reg_0088_cf is record ( tipo                 varchar2(02)  -- campo 1
                                  , subtipo              varchar2(02)
                                  , dt_emis              varchar2(8)
                                  , num_serie_fabr       varchar2(20)
                                  , cod_mod              varchar2(2)
                                  , num_coo_fin          number(6)
                                  , nro_nf               number(6)
                                  , vl_total             number(14)
                                  , vl_bc_icms           number(13)
                                  , vl_icms              number(13)
                                  , sit_trib             varchar2(4)
                                  , branco               varchar2(36)
                                  );

   type t_tab_reg_0088_cf is table of tab_reg_0088_cf index by binary_integer;
   vt_tab_reg_0088_cf t_tab_reg_0088_cf;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 88 - detalhe IT
   type tab_reg_0088_it is record ( tipo                 varchar2(02)  -- campo 1
                                  , subtipo              varchar2(02)
                                  , dt_emis              varchar2(8)
                                  , num_fabr_ecf         varchar2(20)
                                  , num_ord_seq_ecf      number(3)
                                  , tipo_ecf             varchar2(5)
                                  , vl_acm_final         number(16)
                                  , vl_cro               number(6)
                                  , data_inter_tec       varchar2(8)
                                  , ini_term_inter_tec   number(1)
                                  , ind_perda            varchar2(1)
                                  , mot_inter_tec        varchar2(1)
                                  , nro_memor_fiscal_ant number(16)
                                  , nro_memor_fiscal_nova number(16)
                                  , branco                varchar2(29)
                                  );

   type t_tab_reg_0088_it is table of tab_reg_0088_it index by binary_integer;
   vt_tab_reg_0088_it t_tab_reg_0088_it;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 88 - detalhe SME
   type tab_reg_0088_sme is record ( tipo                 varchar2(02)  -- campo 1
                                  , subtipo              varchar2(3)
                                  , cnpj                 varchar2(14)
                                  , ie                   varchar2(14)
                                  , mensagem             varchar2(34)
                                  , branco               varchar2(59)
                                  );

   type t_tab_reg_0088_sme is table of tab_reg_0088_sme index by binary_integer;
   vt_tab_reg_0088_sme t_tab_reg_0088_sme;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 88 - detalhe SMS
   type tab_reg_0088_sms is record ( tipo                 varchar2(02)  -- campo 1
                                  , subtipo              varchar2(3)
                                  , cnpj                 varchar2(14)
                                  , ie                   varchar2(14)
                                  , mensagem             varchar2(34)
                                  , branco               varchar2(59)
                                  );

   type t_tab_reg_0088_sms is table of tab_reg_0088_sms index by binary_integer;
   vt_tab_reg_0088_sms t_tab_reg_0088_sms;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 88 - detalhe EC
   type tab_reg_0088_ec is record ( tipo                 varchar2(02)  -- campo 1
                                  , subtipo              varchar2(2)
                                  , nome                 varchar2(39)
                                  , cpf                  number(11)
                                  , crc                  varchar2(10)
                                  , fone                 number(11)
                                  , email                varchar2(50)
                                  , dm_altera            number(1)
                                  );

   type t_tab_reg_0088_ec is table of tab_reg_0088_ec index by binary_integer;
   vt_tab_reg_0088_ec t_tab_reg_0088_ec;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 88 - detalhe SF
   type tab_reg_0088_sf is record ( tipo                 varchar2(02)  -- campo 1
                                  , subtipo              varchar2(2)
                                  , nome_empr            varchar2(35)
                                  , cnpj_empr            varchar2(14)
                                  , cpf_tec              varchar2(11)
                                  , fone                 number(11)
                                  , email                varchar2(50)
                                  , dm_altera            number(1)
                                  );

   type t_tab_reg_0088_sf is table of tab_reg_0088_sf index by binary_integer;
   vt_tab_reg_0088_sf t_tab_reg_0088_sf;

   ------------------------------------------------------------------------------------------------------------
   -- registro tipo 90
   type tab_reg_0090 is record (    tipo                      number(02)     -- campo 1
                                   ,cgc_mf                    number(14)     -- campo 2
                                   ,ie                      varchar2(14)     -- campo 3
                                   ,total                   varchar2(32000)  -- campo 4
                                   ,num_reg_tipo_90           number(01)     -- campo 5
                                   );

   type t_tab_reg_0090 is table of tab_reg_0090 index by binary_integer;
   vt_tab_reg_0090 t_tab_reg_0090;

   ------------------------------------------------------------------------------

   type t_estr_arq_sintegra is table of estr_arq_sintegra%rowtype index by binary_integer;
   vt_estr_arq_sintegra     t_estr_arq_sintegra;

   ------------------------------------------------------------------------------------------------------------
   -- Funcao formata o valor na mascara deseja pelo usuario
   function fkg_formata_num ( en_num in number  , ev_mascara in varchar2  ) return varchar2;

   ------------------------------------------------------------------------------------------------------------
   -- Procedimento inicia montagem da estrutura do arquivo texto do Sintegra
   procedure pkb_gera_arquivo_sint ( en_aberturasint_id in abertura_sintegra.id%type );

   -------------------------------------------------------------------------------------------------------
   -- Procedimento para validar
   procedure pkb_validar ( en_aberturasint_id in abertura_sintegra.id%type );

   -------------------------------------------------------------------------------------------------------
   -- Procedimento de desfazer a situação da geração
   procedure pkb_desfazer ( en_aberturasint_id in abertura_sintegra.id%type );
   --
   procedure pkb_monta_reg_0010;
   procedure pkb_monta_reg_0011;
   procedure pkb_monta_reg_0050;
   procedure pkb_monta_reg_0051;
   procedure pkb_monta_reg_0053;
   procedure pkb_monta_reg_0054;
   procedure pkb_monta_reg_0056;
   procedure pkb_monta_reg_0057;
   procedure pkb_monta_reg_0060M;
   procedure pkb_monta_reg_0060A;
   procedure pkb_monta_reg_0060D;
   procedure pkb_monta_reg_0060I;
   procedure pkb_monta_reg_0060R;
   procedure pkb_monta_reg_0070 ;
   procedure pkb_monta_reg_0074 ;
   procedure pkb_monta_reg_0075 ( en_item_id in item.id%Type );
   procedure pkb_monta_reg_0076 ;
   procedure pkb_monta_reg_0085 ;
   procedure pkb_monta_reg_0086 ;
   procedure pkb_monta_reg_0088_sme;
   procedure pkb_monta_reg_0088_sms;
   procedure pkb_monta_reg_0088_ec;
   procedure pkb_monta_reg_0088_sf;
   procedure pkb_monta_reg_0090 ;
   --
   procedure pkb_armaz_reg_0010;
   procedure pkb_armaz_reg_0011;
   procedure pkb_armaz_reg_0050;
   procedure pkb_armaz_reg_0051;
   procedure pkb_armaz_reg_0053;
   procedure pkb_armaz_reg_0054;
   procedure pkb_armaz_reg_0056;
   procedure pkb_armaz_reg_0057;
   procedure pkb_armaz_reg_0060M;
   procedure pkb_armaz_reg_0060R;
   procedure pkb_armaz_reg_0070 ;
   procedure pkb_armaz_reg_0074 ;
   procedure pkb_armaz_reg_0075 ;
   procedure pkb_armaz_reg_0076 ;
   procedure pkb_armaz_reg_0085 ;
   procedure pkb_armaz_reg_0086 ;
   procedure pkb_armaz_reg_0088_01;
   procedure pkb_armaz_reg_0088_02;
   procedure pkb_armaz_reg_0088_cf;
   procedure pkb_armaz_reg_0088_it;
   procedure pkb_armaz_reg_0088_sme;
   procedure pkb_armaz_reg_0088_sms;
   procedure pkb_armaz_reg_0088_ec;
   procedure pkb_armaz_reg_0088_sf;
   procedure pkb_armaz_reg_0090 ;
   --
   procedure pkb_grava_estr_arq_sint ;

   ------------------------------------------------------------------------------------------------------------
   --| Variaveis globais utilizadas na geracao do arquivo

   gl_conteudo          estr_arq_sintegra.conteudo%type;
   gt_row_abertura_sint abertura_sintegra%rowtype;
   gn_dm_dt_escr_dfepoe empresa.dm_dt_escr_dfepoe%type;
   gn_qtde_ent          number := 0;
   gn_qtde_sai          number := 0;
   gn_0090_tp_total     number;
   --
   gv_mensagem          log_generico.mensagem%type;
   gn_referencia_id     log_generico.referencia_id%type;
   gv_obj_referencia    log_generico.obj_referencia%type;
   gv_resumo            log_generico.resumo%type;
   --
   gn_estado_id         estado.id%type;
   gv_sigla_estado      estado.sigla_estado%type;
   --
   -------------------------------------------------------------------------------------------------------------
   /*   Todos os registros devem conter no final de cada linha do arquivo digital, ap?s o caractere delimitador
   Pipe acima mencionado, os caracteres "CR" (Carriage Return) e "LF" (Line Feed) correspondentes a
   "retorno do carro" e "salto de linha" (CR e LF: caracteres 13 e 10, respectivamente, da Tabela ASCII).     */

   CR                CONSTANT VARCHAR2(4000) := CHR(13);
   LF                CONSTANT VARCHAR2(4000) := CHR(10);
   FINAL_DE_LINHA    CONSTANT VARCHAR2(4000) := CR || LF;
   erro_de_validacao constant number := 1;

   -------------------------------------------------------------------------------------------------------------

end pk_gera_arq_sint;
/
