create or replace package csf_own.pk_apur_icms_st is

-------------------------------------------------------------------------------------------------------
--| Especifica��o do pacote de procedimentos de Gera��o da Apura��o de ICMS-ST
--
-- Em 12/02/2021 - Allan Magrini
-- Distribui��es: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #75986: SPED Fiscal sem gerar o registro E250
-- Na fase 22 adicionado (or nvl(gt_row_apuracao_icms_st.Vl_Deb_Esp_St,0) > 0) para alterar o tipo para 1 com opera��es de st
-- Rotina Alterada: pkb_apuracao
--
-- Em 10/02/2021 - Marcos Ferreira
-- Distribui��es: 2.9.7 / 2.9.6-2 / 2.9.5-5
-- Redmine #75460: Considerar estado para gera��o da Guia de ICMS-ST
-- Rotinas Alteradas: pkg_gera_guia_pgto
-- Altera��o: Gera��o da guia agrupado por Estado.
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
-- Em 15/01/2021     - Jo�o Carlos
-- Distribui��es     - 2.9.7 / 2.9.6-1 / 2.9.5-4
-- Redmine #74943    - Adicionar condi��o de pesquisa ct.sigla_uf_ini = gv_apur_sigla_estado no select que
--                   - popula a vari�vel vn_vl_icms3
-- Rotinas Alteradas - fkg_soma_deb_esp_st_197
--
-- Em 27/11/2020 - Marcos Ferreira
-- Distribui��es: 2.9.6 / 2.9.5-2 / 2.9.4-5
-- Redmine 73369: Adicionar a parametriza��o da Conta Cont�bil que ser� vinculada a Guia de Pagamento
-- Rotinas Alteradas: pkg_gera_guia_pgto
--
-- Em 13/11/2020 - Allan Magrini
-- Distribui��es: 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #71702: Campo DEB_ESP_ST da apura��o de ICMS-ST n�o considera CTe's
-- foi alterado no select para buscar o valor vn_vl_icms3, a valida��o => dm_tipo_apur = 1
-- Rotina Alterada: fkg_soma_deb_esp_st_197
--
-- Em 16/10/2020 - Allan Magrini
-- Distribui��es: 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #71702: Campo DEB_ESP_ST da apura��o de ICMS-ST n�o considera CTe's
-- foi incluido select para buscar o valor vn_vl_icms3 na tabelas de cte igual ao da pk_apur_icms
-- Rotina Alterada: fkg_soma_deb_esp_st_197
--
-- Em 06/10/2020   - Luis Marques - 2.9.4-4 / 2.9.5-1 / 2.9.6
-- Redmine #71047  - Apura��o de ICMS-ST Carregando valor pra UF errada
-- Fun��o Alterada - fkg_soma_deb_esp_st_197 - Ajustado para notas fiscais com DM_IND_EMIT 1 (Terceiros) ser lido a
--                   tabela "NOTA_FISCAL_DEST" para trazer a UF.
--
-- Em 23/09/2020 - Marcos Ferreira
-- Distribui��es: 2.9.5 / 2.9.4-3 / 2.9.3-6
-- Redmine #70669: Ajuste em tabelas de apura��o
-- Rotinas Criadas: pkg_gera_guia_pgto,  pkg_estorna_guia_pgto
--
-- Em 18/02/2020 - Renan Alves
-- Redmine #64568 - Valores de ICMS ST do C197 n�o est�o sendo preenchidos na apura��o
-- Foi alterado a condi��o que verifica a situa��o do documento nos dois selects, onde a mesma estava 
-- com a condi��o IN, que encontrava-se incorreta trazendo apenas documentos cancelados (02 e 03), foi
-- alterado para NOT IN.
-- Rotina: fkg_soma_aj_creditos_st
--
-- Em 19/12/2018 - Angela In�s.
-- Redmine #49849 - Ajuste nos valores do Imposto ICMS-ST incluindo os valores de FCP.
-- Na Apura��o do ICMS-ST, incluir a soma do valor de FCP do Imposto ICMS-ST, ao Valor Tributado de ICMS-ST, para os campos: Valor "04-VL_DEVOL_ST: Valor total
-- do ICMS ST de devolu��o de mercadorias", Valor "05-VL_RESSARC_ST: Valor total do ICMS ST de ressarcimentos", Valor "06-VL_OUT_CRED_ST: Valor total de Ajustes
-- "Outros cr�ditos ST" e �Estorno de d�bitos ST�", Valor "08-VL_RETEN�AO_ST: Valor Total do ICMS retido por Substitui��o Tribut�ria", e Valor "15-DEB_ESP_ST: 
-- Valores recolhidos ou a recolher, extraapura��o".
-- Rotinas: fkg_soma_devol_st, fkg_soma_ressarc_st, fkg_soma_out_cred_st_c190, fkg_soma_ret_st_c190_cd590, e fkg_soma_deb_esp_st.
--
-- Em 20/06/2017 - Marcos Garcia
-- Redmine #32010 - Processo de valida��o para dados complementares de apura��o de icms-st gia RJ.
-- Caso a empresa corrente no processo for do estado do Rio de Janeiro, sofrer� algumas valida��es
-- utilizando os campos complementares da tabela AJUST_APUR_ICMSST_GIA.
--
-- Em 12/02/2016 - Angela In�s.
-- Redmine #15372 - Corre��o na Apura��o de ICMS e Gera��o do SPED Fiscal - Registro E200.
-- Alterar a apura��o de icms-st, recuperando tamb�m os estados atrav�s das IEs de Substitutos (ie_subst).
-- Rotina: pkb_gerar_estados.
--
-- Em 07/12/2015 - Leandro Savenhago.
-- Redmine #8048 - Processo de Apura��o de ICMS-ST - Performance.
-- Rotina: pkb_gerar_estados - Separado os UNION em cursores independentes
--
-- Em 27/07/2015 - Angela In�s.
-- Redmine #10117 - Escritura��o de documentos fiscais - Processos.
-- Inclus�o do novo conceito de recupera��o de data dos documentos fiscais para retorno dos registros.
--
-- Em 11/06/2015 - Rog�rio Silva.
-- Redmine #8226 - Processo de Registro de Log em Packages - LOG_GENERICO
--
-- Em 23/05/2014 - Angela In�s.
-- Redmine ##2912 - Processo de Apura��o de ICMS-ST. Implementar a seguinte valida��o:
-- Caso exista registro na tabela "AJUST_APUR_ICMSST_GIA", a soma dos valores deve ser igual ao campo VL_AJ_APUR da tabela AJUST_APURACAO_ICMS_ST.
-- Rotina: pkb_validar.
--
-- Em 13/06/2013 - Angela In�s.
-- Verificar todas as rotinas que recuperam UF para gerar os Estados corretamente.
-- Na fun��o que recupera o valor do icms-st de reten��o, foi corrigido a recupera��o dos dados da tebal nfregist_analit.
-- Rotinas: pkb_gerar_estados e fkg_soma_ret_st_c190_cd590.
--
-- Em 25/04/2013 - Marcelo Ono
-- Ficha HD 66660 - Alterado processo para recupera��o do estado pela Tabela (NOTA_FISCAL), relacionadas com as Tabelas (NOTA_FISCAL_DEST/NOTA_FISCAL_EMIT)
-- Rotinas: fkg_soma_bc_ret_st_c190_cd590, fkg_soma_devol_st, fkg_soma_ressarc_st, fkg_soma_out_cred_st_c190, fkg_soma_aj_creditos_st, fkg_soma_ret_st_c190_cd590, 
-- fkg_soma_aj_debitos_st, fkg_soma_deducoes_st_c197, fkg_soma_deb_esp_st, fkg_soma_deb_esp_st_197
--
-- Em 24/10/2012 - Angela In�s.
-- Ficha HD 63562 - Alterar a package PK_APUR_ICMSST, para que passe a alimentar a coluna "vl_base_calc_icms_st"
-- (Valor da Base de C�lculo do ICMS retido por Substitui��o Tribut�ria). Foi necess�rio criar essa coluna para atender as GIAs.
-- Rotinas: fkg_soma_bc_ret_st_c190_cd590, fkg_soma_bc_retencao_st_c690, fkg_soma_bc_retencao_st_c791, fkg_soma_bc_retencao_st_d690, fkg_soma_bc_retencao_st_d697.
--
-- Em 13/01/2012 - Angela In�s.
-- Corrigir mensagem de erro no processo pkb_validar_dados - concatenar os valores e n�o somar.
-- Linha da corre��o:
-- Valida��o: Verifica se as obriga��es de imposto ST a recolher foram lan�adas
-- corretamente com o valor de ICMS-ST a recolher na apura��o de ICMS-ST.
--
-------------------------------------------------------------------------------------------------------

   gt_row_apuracao_icms_st   apuracao_icms_st%rowtype;
   gt_row_per_apur_icms_st   per_apur_icms_st%rowtype;
   gv_apur_sigla_estado      estado.sigla_estado%type;
   gn_dm_dt_escr_dfepoe      empresa.dm_dt_escr_dfepoe%type;

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

-------------------------------------------------------------------------------------------------------
--| Procedimento valida as informa��es da Apura��o de IMCS_ST
procedure pkb_validar ( en_apuracaoicmsst_id in apuracao_icms_st.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a situa��o da Apura��o de IMCS_ST e volta para seu anterior
procedure pkb_desfazer ( en_apuracaoicmsst_id in apuracao_icms_st.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apura��o do IMCS_ST
procedure pkb_apuracao ( en_apuracaoicmsst_id in apuracao_icms_st.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento Valida a apura��o do ICMS_ST para todos os estados do per�odo
procedure pkb_validar_geral ( en_perapuricmsst_id in per_apur_icms_st.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento desfaz a apura��o do ICMS_ST para todos os estados do per�odo
procedure pkb_desfazer_geral ( en_perapuricmsst_id in per_apur_icms_st.id%type );

-------------------------------------------------------------------------------------------------------
--| Procedimento faz a apura��o do ICMS_ST para todos os estados do per�odo
procedure pkb_apuracao_geral ( en_perapuricmsst_id in per_apur_icms_st.id%type );

-------------------------------------------------------------------------------------------------------
--| Processo de gera��o dos estados
procedure pkb_gerar_estados ( en_perapuricmsst_id in per_apur_icms_st.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedure para Gera��o da Guia de Pagamento de Imposto
procedure pkg_gera_guia_pgto (en_apuracaoicmsst_id  in apuracao_icms_st.id%type,
                              en_usuario_id         in neo_usuario.id%type);

-------------------------------------------------------------------------------------------------------

-- Procedure para Estorno da Guia de Pagamento de Imposto
procedure pkg_estorna_guia_pgto (en_apuracaoicmsst_id  in apuracao_icms_st.id%type);

-------------------------------------------------------------------------------------------------------

end pk_apur_icms_st;
/
