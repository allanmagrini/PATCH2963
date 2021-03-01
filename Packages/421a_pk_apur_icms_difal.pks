create or replace package csf_own.pk_apur_icms_difal is
-------------------------------------------------------------------------------------------------------
--
-- Em 16/02/2021  - Allan Magrini
-- Distribuições: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #75148 - Erros no registro E310 - divergencia de valores para a soma dos registros C101
-- Adicionado no select NFD.dm_ind_ie_dest <> 1
-- Rotinas: fkg_vl_tot_debitos_difal, fkg_vl_tot_deb_fcp  
--                    
-- Em 10/02/2021 - Marcos Ferreira
-- Distribuições: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #74220 - Alteração no processo de geração de Guia de Impostos Retidos
-- Rotinas Alteradas: pkg_gera_guia_pgto
-- Alteração: Inclusão do campo dm_origem nos cursores
--                  
-- Em 08/02/2021 - Marcos Ferreira
-- Distribuições: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #73588 - Criar Origem de Dados para ISS Retido para Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 27/11/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine 73369: Adicionar a parametrização da Conta Contábil que será vinculada a Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 24/11/2020  - Allan Magrini
-- Distribuições: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine #72194 e 72668 - Sped de ICMS e IPI com Apuração de Partilha para Contribuintes de ICMS
-- Alteradas o select que busca o valor vn_vl3_d
-- Rotinas: fkg_vl_tot_creditos_difal 
--
-- Em 09/10/2020     - Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #67653    - Extrema lentidão no cálculo de ICMS DIFAL
-- Rotinas Alteradas - pkb_apuracao_geral, pkb_validar_geral, pkb_apuracao, pkb_validar - Incluido chamada para
--                     procedure que carrega os dados em tabelas temporárias.
--                     fkg_vl_tot_debitos_difal, fkg_vl_tot_deb_fcp,
--                     fkg_vl_tot_creditos_difal, fkg_vl_tot_cred_fcp - Incluido nos select as tabelas temporárias
--                     que foram carregadas.
-- Rotina Incluida   - pkb_insert_tabela_tmp - Rotina que inclui os dados nas tabelas temporárias para apuração e 
--                     validação.
--                     
-- Em 28/09/2020 - Marcos Ferreira
-- Distribuições: 2.9.6 / 2.9.5-1 / 2.9.4-4
-- Redmine #70902: Geração de guia pela apuração de ICMS-DIFAL
-- Rotinas Criadas: pkg_gera_guia_pgto,  pkg_estorna_guia_pgto
--
-- Em 07/07/2020 - Marcos Ferreira
-- Distribuições: 2.9.4
-- Redmine #68776: Estrutura para integrar guia da PGTO_IMP_RET
-- Rotinas Alteradas: pkb_valida_apartir_01012017, pkb_valida_ate_31122016
-- Alterações: Adequação a nova estrutura de tabela
--
-- Em 05/02/2020  - Allan Magrini
-- Redmine #64246 - Lentidão no cálculo de ICMS DIFAL
-- Alteradas as váriaveis vn_vl1, vn_vl2, vn_vl3 de number para %type-- na valida colocada %type em todas as variáveis
-- Rotinas: fkg_vl_tot_creditos_difal, pkb_valida_apartir_01012017
--
-- Em 06/08/2019  - Allan Magrini
-- Redmine #56999 - Erro no cálculo da apuração do ICMS - DIFAL 
-- Alterar os valores de datas inicial e final, do período de apuração, considerando a hora, colocando to_date na recuperação dos valores dos documentos fiscais.
-- Rotinas: fkg_vl_tot_debitos_difal, fkg_vl_tot_deb_fcp, fkg_vl_tot_creditos_difal, fkg_vl_tot_cred_fcp, pkb_dados_per_apur_icms_difal e pkb_gerar_estados.
--
-- Em 16/07/2019  - Eduardo Linden
-- Redmine #56397 - Formato de data - Processo de geração dos estados Difal
-- Foi implementado a function pk_csf.fkg_param_global_csf_form_data e a variavel gv_formato_data para padronizar o
-- formato de data
-- Rotinas: pkb_dados_per_apur_icms_difal, pkb_dados_apur_icms_difal
--
-- Em 23/05/2019 - Luiz Armando Azoni.
-- Redmine #54653 - Erro na geração do ICMS Difal em ambiente de homologação..
-- Adicinado o comando execute immediate na pkb_validar_geral pois na Alta Genetics o formatado de data do banco é mm/dd/rrrr 
-- altearção na formatação da data na pkb_dados_per_apur_icms_difal para gt_row_per_apur_icms_difal.dt_fim    := to_date(gt_row_per_apur_icms_difal.dt_fim,'dd/mm/rrrr');
-- Rotinas: pk_apur_icms_difal.pkb_dados_per_apur_icms_difal.
--
-- Em 14/03/2019 - Angela Inês.
-- Redmine #52453 - Melhoria técnica no processo de geração e validação dos valores de Diferencial de Alíquota.
-- Alterar os valores de datas inicial e final, do período de apuração, considerando a hora, para evitar o comando TRUNC na recuperação dos valores dos 
-- documentos fiscais.
-- Rotinas: fkg_vl_tot_debitos_difal, fkg_vl_tot_deb_fcp, fkg_vl_tot_creditos_difal, fkg_vl_tot_cred_fcp, pkb_dados_per_apur_icms_difal e pkb_gerar_estados.
--
-------------------------------------------------------------------------------------------------------
-- Ficou cardodado com a equipe que adicionaremos sempre a ultima alteração no início do arquivo.
-------------------------------------------------------------------------------------------------------
--
--| Especificação do pacote de procedimentos de Geração da Apuração de ICMS DIFAL
--
-- Em 20/10/2016 - Angela Inês.
-- Redmine #20691 - Processo de Apuração do ICMS-DIFAL.
-- Conforme alteração do Sped ICMS/IPI 2.0.19, refazer o processo de Apuração do ICMS-DIFAL.
-- Rotinas: pkb_apuracao, pkb_apura_ate_31122016, pkb_apura_apartir_01012017.
-- Rotinas: pkb_validar, pkb_valida_ate_31122016, pkb_valida_apartir_01012017.
--
-- Em 24/01/2017 - Angela Inês.
-- Redmine #27645 - Alterar o processo de apuração do ICMS-DIFAL, com relação ao campo VL_TOT_CREDITOS_DIFAL.
-- Considerar os valores como sendo:
-- Quando o estado da empresa for igual ao estado da apuração fazer: soma de vl_icms_uf_dest das notas fiscais de entrada e emissão própria, e soma de
-- vl_icms_uf_remet das nots fiscais de entrada e terceiro/devolução.
-- Quando o estado da empresa não for igual ao estado da apuração fazer: soma de vl_icms_uf_dest das notas fiscais de entrada e emissão própria e de mesmo
-- estado de destinatário, e soma de vl_icms_uf_remet das notas fiscais de entrada e terceiro/devolução e de mesmo estado do emitente.
-- Rotina: fkg_vl_tot_creditos_difal.
--
-- Em 08/02/2017 - Angela Inês.
-- Redmine #28122 - Apuração de ICMS Difal - Valor de Obrigações a Recolher - Registro E316.
-- Validar os valores informados em Obrigações a Recolher de acordo com Guia Prático do Sped Fiscal ICMS/IPI.
-- A partir de 01/01/2017, a soma do valor das obrigações deve ser igual ao somatório dos campos: VL_RECOL_DIFAL + DEB_ESP_DIFAL + VL_RECOL_FCP + DEB_ESP_FCP.
-- Rotina: pkb_valida_apartir_01012017.
--
-- Em 09/03/2017 - Angela Inês.
-- Redmine #29190 - Correção no valor total de crédito do ICMS referente a DIFAL.
-- 1) Recuperar o valor de ICMS destinatário (nota_fiscal_total.vl_icms_uf_dest), das notas de entrada, autorizadas e cuja UF do destinatário seja a mesma UF das
-- apurações geradas no período (nota_fiscal_dest.uf = estado/apur_icms_difal.estado_id).
-- 2) Recuperar o valor de ICMS remetente (nota_fiscal_total.vl_icms_uf_remet), das notas de entrada, autorizadas e cuja UF do emitente seja a mesma da UF
-- da empresa que gera o período de apuração de icms difal (nota_fiscal_dest.uf <> estado/empresa/per_apur_icms_difal).
-- Rotina: fkg_vl_tot_creditos_difal.
--
-- Em 10/04/2017 - Angela Inês.
-- Redmine #30135 - Atualizar a apuração de ICMS-DIFAL - Valor de Crédito.
-- Alterar a Função que retorna o "Valor total dos créditos do ICMS DIFAL devido" referente ao diferencial de alíquota:
-- 1) Se a UF do estado da Empresa for igual a UF do estado da apuração:
-- 1.1) Recuperar nota_fiscal_total.vl_icms_uf_remet, quando: nota fiscal autorizada, de emissão própria, de entrada e de modelos ('01', '1B', '04', '55', '65', 
-- '06', '29', '28', '21', '22'), e ainda que os itens da nota fiscal tenham CFOP do tipo de operação sendo devolução (nota_fiscal/item_nota_fiscal/cfop/
-- tipo_operacao.cd=3).
-- 1.2) Recuperar nota_fiscal_total.vl_icms_uf_dest, quando: nota fiscal autorizada, de emissão própria, de entrada e de modelos ('01', '1B', '04', '55', '65', 
-- '06', '29', '28', '21', '22'), e ainda que os itens da nota fiscal não tenham CFOP do tipo de operação sendo devolução (nota_fiscal/item_nota_fiscal/cfop/
-- tipo_operacao.cd<>3).
-- 1.3) Recuperar nota_fiscal_total.vl_icms_uf_dest, quando: nota fiscal autorizada, de terceiro, de entrada e de modelos ('01', '1B', '04', '55', '65', '06', 
-- '29', '28', '21', '22').
-- 1.4) Somar os valores dos 3 itens acima.
-- 2) Se a UF do estado da Empresa for diferente da UF do estado da apuração:
-- 2.1) Recuperar nota_fiscal_total.vl_icms_uf_dest, quando: nota fiscal autorizada, de emissão própria, de entrada e de modelos ('01', '1B', '04', '55', '65', 
-- '06', '29', '28', '21', '22'), e ainda que os itens da nota fiscal tenham CFOP do tipo de operação sendo devolução (nota_fiscal/item_nota_fiscal/cfop/
-- tipo_operacao.cd=3).
-- 2.2) Recuperar nota_fiscal_total.vl_icms_uf_remet, quando: nota fiscal autorizada, de emissão própria, de entrada e de modelos ('01', '1B', '04', '55', '65', 
-- '06', '29', '28', '21', '22'), e ainda que os itens da nota fiscal não tenham CFOP do tipo de operação sendo devolução (nota_fiscal/item_nota_fiscal/cfop/
-- tipo_operacao.cd<>3).
-- 2.3) Recuperar nota_fiscal_total.vl_icms_uf_dest, quando: nota fiscal autorizada, de terceiro, de entrada e de modelos ('01', '1B', '04', '55', '65', '06', 
-- '29', '28', '21', '22').
-- 2.4) Somar os valores dos 3 itens acima.
-- Rotina: fkg_vl_tot_creditos_difal.
--
-------------------------------------------------------------------------------------------------------
-- Ficou cardodado com a equipe que adicionaremos sempre a ultima alteração no início do arquivo.
-------------------------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------------------------

   gt_row_apur_icms_difal      apur_icms_difal%rowtype;
   gt_row_per_apur_icms_difal  per_apur_icms_difal%rowtype;
   gv_apur_sigla_estado        estado.sigla_estado%type;
   gv_sigla_estado_empresa     estado.sigla_estado%type;
   gn_dm_dt_escr_dfepoe        empresa.dm_dt_escr_dfepoe%type;
   gv_formato_data             param_global_csf.valor%type := null;

-------------------------------------------------------------------------------------------------------

-- Declaração de constantes

   ERRO_DE_VALIDACAO         CONSTANT NUMBER := 1;
   ERRO_DE_SISTEMA           CONSTANT NUMBER := 2;
   INFO_APUR_IMPOSTO         CONSTANT NUMBER := 33;

-------------------------------------------------------------------------------------------------------

   gv_cabec_log              log_generico.mensagem%type;
   gv_cabec_log_item         log_generico.mensagem%type;
   gv_mensagem_log           log_generico.mensagem%type;
   gv_resumo_log             log_generico.resumo%type;
   gv_obj_referencia         log_generico.obj_referencia%type default null;
   gn_referencia_id          log_generico.referencia_id%type := null;
   gv_geral                  varchar2(1) := null;     

-------------------------------------------------------------------------------------------------------
--| Procedimento valida as informações da Apuração de IMCS DIFAL
procedure pkb_validar ( en_apuricmsdifal_id in apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a situação da Apuração de IMCS DIFAL e volta para seu anterior
procedure pkb_desfazer ( en_apuricmsdifal_id in apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apuração do ICMS DIFAL
procedure pkb_apuracao ( en_apuricmsdifal_id in apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento Valida a apuração do ICMS DIFAL para todos os estados do período
procedure pkb_validar_geral ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a apuração do ICMS DIFAL para todos os estados do período
procedure pkb_desfazer_geral ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apuração do ICMS DIFAL para todos os estados do período
procedure pkb_apuracao_geral ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Processo de geração dos estados
procedure pkb_gerar_estados ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedure para Geração da Guia de Pagamento de Imposto
procedure pkg_gera_guia_pgto (en_apuricmsdifal_id   in apur_icms_difal.id%type,
                              en_usuario_id         in neo_usuario.id%type);

-------------------------------------------------------------------------------------------------------

-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_apuricmsdifal_id  in apur_icms_difal.id%type);

-------------------------------------------------------------------------------------------------------
end pk_apur_icms_difal;
/
