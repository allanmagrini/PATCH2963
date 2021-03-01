create or replace package csf_own.pk_apur_icms_difal is
-------------------------------------------------------------------------------------------------------
--
-- Em 16/02/2021  - Allan Magrini
-- Distribui��es: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #75148 - Erros no registro E310 - divergencia de valores para a soma dos registros C101
-- Adicionado no select NFD.dm_ind_ie_dest <> 1
-- Rotinas: fkg_vl_tot_debitos_difal, fkg_vl_tot_deb_fcp  
--                    
-- Em 10/02/2021 - Marcos Ferreira
-- Distribui��es: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #74220 - Altera��o no processo de gera��o de Guia de Impostos Retidos
-- Rotinas Alteradas: pkg_gera_guia_pgto
-- Altera��o: Inclus�o do campo dm_origem nos cursores
--                  
-- Em 08/02/2021 - Marcos Ferreira
-- Distribui��es: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #73588 - Criar Origem de Dados para ISS Retido para Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 27/11/2020 - Marcos Ferreira
-- Distribui��es: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine 73369: Adicionar a parametriza��o da Conta Cont�bil que ser� vinculada a Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 24/11/2020  - Allan Magrini
-- Distribui��es: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine #72194 e 72668 - Sped de ICMS e IPI com Apura��o de Partilha para Contribuintes de ICMS
-- Alteradas o select que busca o valor vn_vl3_d
-- Rotinas: fkg_vl_tot_creditos_difal 
--
-- Em 09/10/2020     - Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #67653    - Extrema lentid�o no c�lculo de ICMS DIFAL
-- Rotinas Alteradas - pkb_apuracao_geral, pkb_validar_geral, pkb_apuracao, pkb_validar - Incluido chamada para
--                     procedure que carrega os dados em tabelas tempor�rias.
--                     fkg_vl_tot_debitos_difal, fkg_vl_tot_deb_fcp,
--                     fkg_vl_tot_creditos_difal, fkg_vl_tot_cred_fcp - Incluido nos select as tabelas tempor�rias
--                     que foram carregadas.
-- Rotina Incluida   - pkb_insert_tabela_tmp - Rotina que inclui os dados nas tabelas tempor�rias para apura��o e 
--                     valida��o.
--                     
-- Em 28/09/2020 - Marcos Ferreira
-- Distribui��es: 2.9.6 / 2.9.5-1 / 2.9.4-4
-- Redmine #70902: Gera��o de guia pela apura��o de ICMS-DIFAL
-- Rotinas Criadas: pkg_gera_guia_pgto,  pkg_estorna_guia_pgto
--
-- Em 07/07/2020 - Marcos Ferreira
-- Distribui��es: 2.9.4
-- Redmine #68776: Estrutura para integrar guia da PGTO_IMP_RET
-- Rotinas Alteradas: pkb_valida_apartir_01012017, pkb_valida_ate_31122016
-- Altera��es: Adequa��o a nova estrutura de tabela
--
-- Em 05/02/2020  - Allan Magrini
-- Redmine #64246 - Lentid�o no c�lculo de ICMS DIFAL
-- Alteradas as v�riaveis vn_vl1, vn_vl2, vn_vl3 de number para %type-- na valida colocada %type em todas as vari�veis
-- Rotinas: fkg_vl_tot_creditos_difal, pkb_valida_apartir_01012017
--
-- Em 06/08/2019  - Allan Magrini
-- Redmine #56999 - Erro no c�lculo da apura��o do ICMS - DIFAL 
-- Alterar os valores de datas inicial e final, do per�odo de apura��o, considerando a hora, colocando to_date na recupera��o dos valores dos documentos fiscais.
-- Rotinas: fkg_vl_tot_debitos_difal, fkg_vl_tot_deb_fcp, fkg_vl_tot_creditos_difal, fkg_vl_tot_cred_fcp, pkb_dados_per_apur_icms_difal e pkb_gerar_estados.
--
-- Em 16/07/2019  - Eduardo Linden
-- Redmine #56397 - Formato de data - Processo de gera��o dos estados Difal
-- Foi implementado a function pk_csf.fkg_param_global_csf_form_data e a variavel gv_formato_data para padronizar o
-- formato de data
-- Rotinas: pkb_dados_per_apur_icms_difal, pkb_dados_apur_icms_difal
--
-- Em 23/05/2019 - Luiz Armando Azoni.
-- Redmine #54653 - Erro na gera��o do ICMS Difal em ambiente de homologa��o..
-- Adicinado o comando execute immediate na pkb_validar_geral pois na Alta Genetics o formatado de data do banco � mm/dd/rrrr 
-- altear��o na formata��o da data na pkb_dados_per_apur_icms_difal para gt_row_per_apur_icms_difal.dt_fim    := to_date(gt_row_per_apur_icms_difal.dt_fim,'dd/mm/rrrr');
-- Rotinas: pk_apur_icms_difal.pkb_dados_per_apur_icms_difal.
--
-- Em 14/03/2019 - Angela In�s.
-- Redmine #52453 - Melhoria t�cnica no processo de gera��o e valida��o dos valores de Diferencial de Al�quota.
-- Alterar os valores de datas inicial e final, do per�odo de apura��o, considerando a hora, para evitar o comando TRUNC na recupera��o dos valores dos 
-- documentos fiscais.
-- Rotinas: fkg_vl_tot_debitos_difal, fkg_vl_tot_deb_fcp, fkg_vl_tot_creditos_difal, fkg_vl_tot_cred_fcp, pkb_dados_per_apur_icms_difal e pkb_gerar_estados.
--
-------------------------------------------------------------------------------------------------------
-- Ficou cardodado com a equipe que adicionaremos sempre a ultima altera��o no in�cio do arquivo.
-------------------------------------------------------------------------------------------------------
--
--| Especifica��o do pacote de procedimentos de Gera��o da Apura��o de ICMS DIFAL
--
-- Em 20/10/2016 - Angela In�s.
-- Redmine #20691 - Processo de Apura��o do ICMS-DIFAL.
-- Conforme altera��o do Sped ICMS/IPI 2.0.19, refazer o processo de Apura��o do ICMS-DIFAL.
-- Rotinas: pkb_apuracao, pkb_apura_ate_31122016, pkb_apura_apartir_01012017.
-- Rotinas: pkb_validar, pkb_valida_ate_31122016, pkb_valida_apartir_01012017.
--
-- Em 24/01/2017 - Angela In�s.
-- Redmine #27645 - Alterar o processo de apura��o do ICMS-DIFAL, com rela��o ao campo VL_TOT_CREDITOS_DIFAL.
-- Considerar os valores como sendo:
-- Quando o estado da empresa for igual ao estado da apura��o fazer: soma de vl_icms_uf_dest das notas fiscais de entrada e emiss�o pr�pria, e soma de
-- vl_icms_uf_remet das nots fiscais de entrada e terceiro/devolu��o.
-- Quando o estado da empresa n�o for igual ao estado da apura��o fazer: soma de vl_icms_uf_dest das notas fiscais de entrada e emiss�o pr�pria e de mesmo
-- estado de destinat�rio, e soma de vl_icms_uf_remet das notas fiscais de entrada e terceiro/devolu��o e de mesmo estado do emitente.
-- Rotina: fkg_vl_tot_creditos_difal.
--
-- Em 08/02/2017 - Angela In�s.
-- Redmine #28122 - Apura��o de ICMS Difal - Valor de Obriga��es a Recolher - Registro E316.
-- Validar os valores informados em Obriga��es a Recolher de acordo com Guia Pr�tico do Sped Fiscal ICMS/IPI.
-- A partir de 01/01/2017, a soma do valor das obriga��es deve ser igual ao somat�rio dos campos: VL_RECOL_DIFAL + DEB_ESP_DIFAL + VL_RECOL_FCP + DEB_ESP_FCP.
-- Rotina: pkb_valida_apartir_01012017.
--
-- Em 09/03/2017 - Angela In�s.
-- Redmine #29190 - Corre��o no valor total de cr�dito do ICMS referente a DIFAL.
-- 1) Recuperar o valor de ICMS destinat�rio (nota_fiscal_total.vl_icms_uf_dest), das notas de entrada, autorizadas e cuja UF do destinat�rio seja a mesma UF das
-- apura��es geradas no per�odo (nota_fiscal_dest.uf = estado/apur_icms_difal.estado_id).
-- 2) Recuperar o valor de ICMS remetente (nota_fiscal_total.vl_icms_uf_remet), das notas de entrada, autorizadas e cuja UF do emitente seja a mesma da UF
-- da empresa que gera o per�odo de apura��o de icms difal (nota_fiscal_dest.uf <> estado/empresa/per_apur_icms_difal).
-- Rotina: fkg_vl_tot_creditos_difal.
--
-- Em 10/04/2017 - Angela In�s.
-- Redmine #30135 - Atualizar a apura��o de ICMS-DIFAL - Valor de Cr�dito.
-- Alterar a Fun��o que retorna o "Valor total dos cr�ditos do ICMS DIFAL devido" referente ao diferencial de al�quota:
-- 1) Se a UF do estado da Empresa for igual a UF do estado da apura��o:
-- 1.1) Recuperar nota_fiscal_total.vl_icms_uf_remet, quando: nota fiscal autorizada, de emiss�o pr�pria, de entrada e de modelos ('01', '1B', '04', '55', '65', 
-- '06', '29', '28', '21', '22'), e ainda que os itens da nota fiscal tenham CFOP do tipo de opera��o sendo devolu��o (nota_fiscal/item_nota_fiscal/cfop/
-- tipo_operacao.cd=3).
-- 1.2) Recuperar nota_fiscal_total.vl_icms_uf_dest, quando: nota fiscal autorizada, de emiss�o pr�pria, de entrada e de modelos ('01', '1B', '04', '55', '65', 
-- '06', '29', '28', '21', '22'), e ainda que os itens da nota fiscal n�o tenham CFOP do tipo de opera��o sendo devolu��o (nota_fiscal/item_nota_fiscal/cfop/
-- tipo_operacao.cd<>3).
-- 1.3) Recuperar nota_fiscal_total.vl_icms_uf_dest, quando: nota fiscal autorizada, de terceiro, de entrada e de modelos ('01', '1B', '04', '55', '65', '06', 
-- '29', '28', '21', '22').
-- 1.4) Somar os valores dos 3 itens acima.
-- 2) Se a UF do estado da Empresa for diferente da UF do estado da apura��o:
-- 2.1) Recuperar nota_fiscal_total.vl_icms_uf_dest, quando: nota fiscal autorizada, de emiss�o pr�pria, de entrada e de modelos ('01', '1B', '04', '55', '65', 
-- '06', '29', '28', '21', '22'), e ainda que os itens da nota fiscal tenham CFOP do tipo de opera��o sendo devolu��o (nota_fiscal/item_nota_fiscal/cfop/
-- tipo_operacao.cd=3).
-- 2.2) Recuperar nota_fiscal_total.vl_icms_uf_remet, quando: nota fiscal autorizada, de emiss�o pr�pria, de entrada e de modelos ('01', '1B', '04', '55', '65', 
-- '06', '29', '28', '21', '22'), e ainda que os itens da nota fiscal n�o tenham CFOP do tipo de opera��o sendo devolu��o (nota_fiscal/item_nota_fiscal/cfop/
-- tipo_operacao.cd<>3).
-- 2.3) Recuperar nota_fiscal_total.vl_icms_uf_dest, quando: nota fiscal autorizada, de terceiro, de entrada e de modelos ('01', '1B', '04', '55', '65', '06', 
-- '29', '28', '21', '22').
-- 2.4) Somar os valores dos 3 itens acima.
-- Rotina: fkg_vl_tot_creditos_difal.
--
-------------------------------------------------------------------------------------------------------
-- Ficou cardodado com a equipe que adicionaremos sempre a ultima altera��o no in�cio do arquivo.
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

-- Declara��o de constantes

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
--| Procedimento valida as informa��es da Apura��o de IMCS DIFAL
procedure pkb_validar ( en_apuricmsdifal_id in apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a situa��o da Apura��o de IMCS DIFAL e volta para seu anterior
procedure pkb_desfazer ( en_apuricmsdifal_id in apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apura��o do ICMS DIFAL
procedure pkb_apuracao ( en_apuricmsdifal_id in apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento Valida a apura��o do ICMS DIFAL para todos os estados do per�odo
procedure pkb_validar_geral ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a apura��o do ICMS DIFAL para todos os estados do per�odo
procedure pkb_desfazer_geral ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apura��o do ICMS DIFAL para todos os estados do per�odo
procedure pkb_apuracao_geral ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
--| Processo de gera��o dos estados
procedure pkb_gerar_estados ( en_perapuricmsdifal_id in per_apur_icms_difal.id%type );

-------------------------------------------------------------------------------------------------------
-- Procedure para Gera��o da Guia de Pagamento de Imposto
procedure pkg_gera_guia_pgto (en_apuricmsdifal_id   in apur_icms_difal.id%type,
                              en_usuario_id         in neo_usuario.id%type);

-------------------------------------------------------------------------------------------------------

-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_apuricmsdifal_id  in apur_icms_difal.id%type);

-------------------------------------------------------------------------------------------------------
end pk_apur_icms_difal;
/
