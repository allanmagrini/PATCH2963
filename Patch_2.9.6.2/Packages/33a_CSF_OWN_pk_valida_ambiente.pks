create or replace package csf_own.pk_valida_ambiente is

-------------------------------------------------------------------------------------------------------
-- Especifica��o do pacote da API para ler as notas fiscais com DM_ST_PROC = 0 (N�o validada)
-- e chamar os procedimentos para validar os dados
--
-- Em 12/02/2021      - Karina de Paula
-- Redmine #76077     - Erro valida��o e campo 'ITEM_NOTA_FISCAL.VL_ABAT_NT' sendo apagado na valida��o.
-- Rotina Alterada    - pkb_ler_Item_Nota_Fiscal => Incluidos os campos INF_CPL_IMP_ITEM, VL_ABAT_NT e COD_INF_ADIC_VLR_DECL nas chamadas da pkb_ler_Item_Nota_Fiscal
--
-- Em 02/02/2021      - Karina de Paula
-- Redmine #75655     - Looping na tabela CSF_OWN.CSF_CONS_SIT ap�s atualiza��o da 2.9.5.0 (NOVA AMERICA)
-- Rotina Alterada    - pkb_cons_nfe_terc_canc => Antes da chamada da pkb_ins_atu_csf_cons_sit foi exclu�da a busca a sequence da csf_cons_sit porque dentro da rotina
--                      pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit � criado um novo id, sendo esse n�o utilizado
--                    - pkb_processos_nfe/pkb_processos_nfe_mo => Alterada  chamada da pk_csf_api.pkb_relac_nfe_cons_sit para pk_csf_api_cons_sit.pkb_relac_nfe_cons_sit
-- Liberado na vers�o - Release_2.9.7, Patch_2.9.6.2 e Patch_2.9.5.5
--
-- Em 18/01/2020 - Eduardo Linden - 2.9.5-4 / 2.9.6-1 / 2.9.7
-- Redmine #71250 - Utiliza��o de campos em Open Interface
-- Inclus�o dos campos dm_ind_intermed e pessoa_id_intermed da tabela Nota_fiscal
-- Rotina Alterada - pkb_ler_Nota_Fiscal
--
-- Em 07/12/2020   - LuiZ ARMANDO - 2.9.5-2 / 2.9.6
-- Redmine         - N�O TEM
-- Rotina Alterada - pkb_ler_nfs_int_ws ADICIONADA 2 VARIAVEIS PARA VALIDAR SE UTILIZA RABBITMQ OU N�O
--
-- Em 20/11/2020   - Luis Marques - 2.9.4-5 / 2.9.5-2 / 2.9.6
-- Redmine #73420  - Campo "dm_st_proc" divergente do "sitdocto_id" (Notas denegadas)
-- Rotina Alterada - pkb_ler_Nota_Fiscal - Incluido ajuste no sitdocto_id para os DM_ST_PROC-(6-Denegado/7-Cancelado/8-Inutilizada).
--
-- Em 15/09/2020   - Luis Marques - 2.9.4-3 / 2.9.5
-- Redmine #71433  - Falha na execu��o pr�-valida��o da rotina 'PB_PREENCHE_ITEM_NF_CEAN'
-- Rotina Alterada - pkb_exec_rot_prog_pv_nf - Ajustada select de leitura o objeto de integra��o
--
-- Em 26/08/2019   - Allan Magrini - 2.9.3-5 / 2.9.4-2 / 2.9.5
-- Redmine #70231  -  Nfe em looping ap�s rejei��o de cancelamento
-- Rotina Alterada - pkb_ler_nfs_int_ws, pkb_ler_Nota_Fiscal Alterado os cursores c_nf e c_Nota_Fiscal para n�o retornar NF com o DM_CANC_SERVICO = 1
--
-- Em 21/08/2020   - Luis Marques - 2.9.3-5 / 2.9.4-2 / 2.9.4
-- Redmine #70750  - Analisar Procedure
-- Rotina Alterada - pkb_ler_Nota_Fiscal - Incluido o carregamento do campo "COD_CTA" da tabela "NOTA_FISCAL" para
--                   que a rotina de integra��o carregue definitivamente os valores digitados no campo.
--
-- Em 18/08/2020   - Karina de Paula
-- Redmine #69653  - Incluir objeto integra��o 16 na mesma valida��o do objeto 6
-- Rotina Alterada - pkb_ler_nfs_int_ws   => Inclu�do no select que verifica a qtd ainda pendente de dados a verifica��o de registro ainda sem notafiscal_id associada
--
-- Em 10/08/2020   - Armando
-- Redmine   - ajuste no objeto para trabalhar com RabbitMQ
--
-- Em 10/08/2020   - Karina de Paula
-- Redmine #69653  - Incluir objeto integra��o 16 na mesma valida��o do objeto 6
-- Rotina Alterada - pkb_int_ws         => Inclu�do o par�metro de entrada en_tipoobjintegr_id na chamada da pkb_ler_nfs_int_ws
--                   pkb_ler_nfs_int_ws => Inclu�do o par�metro de entrada en_tipoobjintegr_id. Alterado o c_nf para trazer dados da r_loteintws_envdocfiscal.
--                                         Alterado o select q busca id do objeto integra��o. Alterado o select q busca nf pendente do lote
--                 - pkb_exec_rot_prog_pv_nf => Alterado o select q busca id do objeto integra��o
--
-- Em 05/08/2019 - Allan Magrini
-- Redmine #70231   Nfe em looping ap�s rejei��o de cancelamento
-- Alterado o cursor c_nf para n�o retornar NF com o DM_CANC_SERVICO = 1  Rotinas pkb_ler_nfs_int_ws, pkb_ler_Nota_Fiscal
-- Liberado       - Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 03/08/2020  - Luiz Armando Azoni
-- Redmine 70050 - o update substituir� a chamada da pk_csf_api.pkb_reg_danfe_rec_armaz_terc na pk_vld_amb_mde
-- Altera��es     - pkb_ler_nota_fiscal
-- Liberado       - Release_2.9.5, Patch_2.9.4-2
--
-- Em 02/07/2020  - Karina de Paula
-- Redmine #57986 - [PLSQL] PIS e COFINS (ST e Retido) na NFe de Servi�os (Bras�lia)
-- Altera��es     - pkb_ler_Nota_Fiscal_Total => Inclus�o dos campos vl_pis_st e vl_cofins_st
-- Liberado       - Release_2.9.5, Patch_2.9.4.1 e Patch_2.9.3.4
--
-- Em 08/06/2020  - Karina de Paula
-- Redmine #62471 - Criar processo de valida��o da CSF_CONS_SIT
-- Altera��es     - pkb_cons_nfe_terc_canc => Retirado o insert na csf_cons_sit e inclu�da a chamada da pk_csf_api_cons_sit.pkb_ins_atu_csf_cons_sit
-- Liberado       - Release_2.9.4, Patch_2.9.3.3 e Patch_2.9.2.6
--
-- Em 06/05/2020  - Karina de Paula
-- Redmine #65401      - NF-e de emiss�o pr�pria autorizada indevidamente (CERRAD�O)
-- Altera��es          - Inclu�do para o gv_objeto o nome da package como valor default para conseguir retornar nos logs o objeto;
--                       Inclu�da a verifica��o "nf.dt_aut_sefaz is not null" nos cursores da rotinas: pk_valida_ambiente.pkb_reenvia_impressao_nfe e pk_valida_ambiente_nfs.pkb_reenvia_impressao_nfse;
--                       Inclu�do valor para as vari�veis globais gv_objeto e gn_fase
-- Liberado            - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- Em 17/04/2020 - Luis Marques - 2.9.2-4 / 2.9.3-1 / 2.9.4
-- Redmine #66934 - Integra��o NFe Legado - Novos Campo
-- Nova Procedure: pkb_ler_NF_Int_Legado_Ref - Criada nova procedure para ler notas Nfe Legado aprovadas (DM_ST_PROC=4)
--                 em que as notas referenciadas s� tenha chave referenciada gravada e mais nenhum campo para
--                 update na nota e acionamento da trigger "T_A_I_U_Nota_Fiscal_NF_REF_01" que decompoe a chave e 
--                 grava os dados da nota referenciada.
--
-- Em 09/04/2020 - Luis Marques - 2.9.2-4 / 2.9.3-1 / 2.9.4
-- Redmine #66484 - Inser��o de dados na nota_fiscal_referen
-- Altera��es: Colocada chamada publica na procedure "pkb_ler_nf_referen" que ser� usada na trigger 
--             "T_A_I_U_Nota_Fiscal_NF_REF_01". 
--             pkb_ler_nf_referen - Colocado verifica��o se a veri�vel gn_multorg_id � nula quando a procedure
--             for chamada da trigger "T_A_I_U_Nota_Fiscal_NF_REF_01" e carregar o valor do multiorg da empresa
--             do documento.
--
-- Em 18/03/2020 - Luis Marques
-- Distribui��es: Release 2.9.3
-- Rotina Alterada: pkb_ler_Imp_ItemNf - Incluido verifica��o se existe valor para os campos BC_ICMS_EFET, VL_ICMS_EFET,
--                  ALIQ_ICMS_EFET e PERC_RED_BC_ICMS_EFET e chamar procedure para valida��o e grava��o dos valores.
--
-- Em 13/03/20120 - Luiz Armando Azoni
-- Distribui��es: Patch 2.9.2-3 / Release 2.9.3 / Emergencial - Patch 2.9.1-6
-- Redmine #65999: Analisar erro localizado pela DBSI
-- Rotina: pkb_cons_nfe_terc_canc
-- Altera��es: Ajustando query para n�o gerar mais erro de insert null. ajustando performance da query
--
-- Em 04/03/20120 - Marcos Ferreira
-- Distribui��es: Patch 2.9.2-3 / Release 2.9.3 / Emergencial - Patch 2.9.2-2 
-- Redmine #65499: N�o Gravando Campo Drawback na Tabela
-- Rotina: pkb_ler_ItemNF_Dec_Impor
-- Altera��es: Inclus�o do campo NUM_ACDRAW no vetor gt_row_ItemNF_Dec_Impor
--
-- Em 03/03/20120 - Marcos Ferreira
-- Distribui��es: 2.9.2-3, 2.9.3
-- Redmine #65495 - Consulta de notas de terceiros canceladas com erro por nota de servi�o da Midas cancelada
-- Rotina: pkb_cons_nfe_terc_canc
-- Altera��es: Padroniza��o do c�digo modelo 55 e 65 no cursor c_dados
--
-- Em 06/01/2020 - Luis Marques
-- Redmine #63033 - Feed - problema continua
-- Rotina Alterada: pkb_ler_Nota_Fiscal - Colocado verifica��o se os log(s) gerados tem erro ou s�o s� de informa��o/alerta.
--
-- Em 08/10/2019 - Allan Magrini
-- Redmine 59745 - feed - n�o est� mais cancelando NF-e
-- Incluido no cursor c_Nota_Fiscal_Canc na valida��o do dm_st_proc o valor 0
-- Rotinas Alteradas: procedure pkb_ler_Nota_Fiscal_Canc
--
-- Em 27/09/2019 - Luis Marques
-- Redmine 59325 - Nova Chamada para integra��o multorg para nota fiscal NFCE - modelo 65
-- Rotinas Criadas: pkb_ler_NFCE_Integradas, pkb_ler_Nota_Fiscal_NFCE_Canc e pkb_integracao_nfce_mo para
--                  integra��o de notas NFCE modelo 65 separada dos demais modelos.
--
-- Em 19/09/2019 - Luis Marques
-- Redmine #58220 - Package de valida��o
-- Rotinas Criadas: pkb_ler_nfs_int_nfce_ws e pkb_int_nfce_ws - Para integra��o de notas mercantis modelo 65.
-- Rotinas Alteradas: pkb_ler_nfs_int_ws e pkb_int_ws - Para integra��o de notas mercantis todos os modelos 
--                    menos modelo 65.
--
-- Em 29/8/19 - Luiz Armando Azoni.
-- Ficha #58096 - Adequa��o da query do cursor c_Nota_Fiscal_Canc para considerar os valores do campo nf.dm_st_proc in (10,11,12,13,15,16,5,99)
-- caso a nota fiscal esteja com erro e for enviada uma solicita��o de cancelamento, a mesma ser� inutilizada desde que n�o existe protocolo de autoriza��o.
-- Rotina: pkb_ler_Nota_Fiscal_Canc.
--
-- Em 23/11/2012 - Angela In�s.
-- Ficha HD 64667 - Processo de valida��o de Impostos. Atualizar o status para notas fiscais de terceiros.
-- Rotina: pkb_ler_Nota_Fiscal.
--
-- Em 26/11/2012 - Rog�rio Silva.
-- Ficha HD 64482 - Processo de valida��o do diferencial de aliquota do item da nota fiscal.
-- Rotina: pkb_ler_itemnf_dif_aliq.
--
-- Em 04/06/2013 - Angela In�s.
-- Corre��o no processo de retorno da integra��o das notas - verificar se a mesma realmente j� foi inclu�da e n�o permitir a integra��o dos pr�ximos processos.
-- Rotina: pkb_ler_Nota_Fiscal.
--
-- Em 24/07/2013 - Angela In�s.
-- Corre��es nas mensagens.
--
-- Em 08/10/2013 - Rog�rio Silva
-- Redmine #1030
-- Cria��o do processo pkb_ler_nota_fiscal_mde para valida��o do MDE.
--
-- Em 16/08/2013
-- Redmine #1031, #1032 e #1035
-- Realizado a execu��o dos procedimentos procedure pkb_rel_cons_nfe_dest, procedure pkb_rel_down_nfe e procedure pkb_reg_aut_mde.
--
-- Em 07/08/2014 - Angela In�s.
-- Redmine #3712 - Corre��o nos processos - Eliminar o comando dbms_output.put_line.
--
-- Em 30/12/2014 - Angela In�s.
-- Redmine #5616 - Adequa��o dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 24/03/2015 - Leandro Savenhago.
-- Redmine #5374 - Adequa��o de valida��o de webservice.
--
-- Em 21/05/2015 - Rog�rio Silva.
-- Redmine #8054 - Implementar package pk_vld_amb_ws
--
-- Em 11/06/2015 - Rog�rio Silva.
-- Redmine #8232 - Processo de Registro de Log em Packages - Notas Fiscais Mercantis
--
-- Em 16/07/2015 - Rog�rio Silva.
-- Redmine #10005 - Nota em contingencia - DT_CONT vazio
--
-- Em 18/09/2015 - Leandro Savenhago
-- Redmine #8232 - NFE TERCEIRO cancelada no Compliance e autorizada na SEFAZ (SANTA F�)
-- Rotina: pkb_cons_nfe_terc_canc.
--
-- Em 02/12/2015 - Rog�rio Silva.
-- Redmine #13330 - Corrigir processo que cria consultas pra notas fiscais canceladas.
-- Rotina: pkb_cons_nfe_terc_canc.
--
-- Em 04/02/2016 - F�bio Tavares Santana.
-- Redmine #14985 - Adaptar a procedure pkb_ler_item_nota_fiscal para a valida��o do Flex-Field.
-- Rotina: pkb_cons_item_nota_fiscal.
--
-- Em 05/02/2016 - Rog�rio Silva
-- Redmine #13079 - Registro do N�mero do Lote de Integra��o Web-Service nos logs de valida��o
--
-- Em 18/03/2016 - Angela In�s.
-- Redmine #15929 - Corre��o no tipo de campo de Number para Caracter: item_nota_fiscal.cod_cest e item_nota_fiscal.nro_fci.
-- Rotina: pkb_ler_Item_Nota_Fiscal.
--
-- Em 27/04/2016 - Rog�rio Silva
-- Redmine #17979 - Erro ao executar package "Valida Ambiente"
--
-- Em 20/06/2016 - Leandro Savenhago.
-- Redmine #20441 - Altera��o dos processos de Valida��o e Integra��o Open-Interface do Compliance - Campo DM_LEGADO
-- Rotina: pkb_ler_Nota_Fiscal.
--
-- Em 11/01/2017 - Angela In�s.
-- Redmine #27197 - Atualizar o indicador de Legado para Notas Fiscais ao utilizar o processo de Valida��o de Ambiente.
-- Ao executar o processo de valida��o atrav�s da package "pk_valida_ambiente", a leitura da nota fiscal n�o est� considerando a informa��o do indicador de Legado
-- (dm_legado), ou seja, a leitura da nota fiscal n�o est� enviando para o processo de valida��o "pk_csf_api", o valor do campo indicador de Legado.
-- Rotina: pkb_ler_Nota_Fiscal.
--
-- Em 19/01/2017 - Marcos Garcia
-- Redmine # 27221 - Processo de Valida��o dos dados Complemento da Informa��o de Exporta��o do Item da NFe
-- Obs.: Rotina adicionada pkb_ler_itemnf_export_compl, responsavel por fazer a leitura do complemento da Informa��o de Exporta��o do Item da NFe.
--
-- Em 24/02/2017 - Leandro Savenhago
-- Redmine # 27221 - Processo de Valida��o dos dados Complemento da Informa��o de Exporta��o do Item da NFe
-- Obs.: Rotina adicionada pkb_ler_itemnf_export_compl, responsavel por fazer a leitura do complemento da Informa��o de Exporta��o do Item da NFe.
--
-- Em 10/03/2017 - F�bio Tavares
-- Redmine #29002 - Falha na gera��o DANFE (OTTO) - N�o estava sendo gerado a Danfe por conta de delay de resposta da SEFAZ
-- Rotina: pkb_reenvia_impressao_nfe
--
-- Em 31/05/2017 - Angela In�s.
-- Redmine #31474 - Analisar / Criar registro em Tipo obj integra��o para servi�o de Carta de Corre��o NF (CC-e NF).
-- Ao validar o objeto de integra��o de Notas Fiscais Mercantis (obj_integr.cd=6), criar a valida��o do tipo de objeto "Carta de Corre��o".
-- O processo ir� recuperar as cartas de corre��es de notas fiscais vinculadas com o lote WS. Ser�o recuperadas as cartas com situa��o "N�o validado" e
-- "Erro de valida��o" (nota_fiscal_cce.dm_st_proc=0,4). Ser�o inclu�dos ou alterados os registros da carta de corre��o (nota_fiscal_cce). O lote ficar� com
-- erro se houver alguma carta de corre��o com "Erro de valida��o" (nota_fiscal_cce.dm_st_proc=4). O lote ficar� aguardando envio se houver alguma carta de
-- corre��o como "N�o validado", "Validado" ou "Aguardando envio" (nota_fiscal_cce.dm_st_proc=0,1,2).
-- Rotinas: pkb_vld_nota_fiscal_cce e pkb_ler_nfs_int_ws.
--
-- Em 20/06/2017 - Angela In�s.
-- Redmine #32165 - Corre��o na valida��o da nota fiscal - situa��o quando a nota est� cancelada.
-- Ao identificar se a nota est� cancelada, n�o passar pelo processo de valida��o, por�m atualizar a situa��o da nota (nota_fiscal.dm_st_proc).
-- Rotina: pkb_ler_nota_fiscal.
--
-- Em 30/06/2017 - Angela In�s.
-- Redmine #32504 - Corre��o na valida��o da nota fiscal - situa��o, quando a nota est� cancelada.
-- Ao identificar se a nota est� cancelada, n�o passar pelo processo de valida��o, por�m atualizar a situa��o da nota (nota_fiscal.dm_st_proc).
-- A vari�vel utilizada para identificar se a nota est� cancelada estava incorreta no processo.
-- Rotina: pkb_ler_nota_fiscal.
--
-- Em 20/09/2017 - Leandro Savenhago
-- Redmine #34430 - Valida��o de Ambiente 06 � Nota Fiscal Mercantil NFe 4.00
--
-- Em 19/10/2017 - Marcelo Ono
-- Redmine #35656 - Inclus�o do par�metro de entrada empresa_id, para que seja filtrado a empresa do documento na execu��o das rotinas program�veis.
-- Rotina: pkb_exec_rot_prog_pv_nf.
--
-- Em 07/11/2017 - Leandro Savenhago
-- Descontinuado, pois j� faz isso na integra��o do documento fiscal 07/11/2017
-- pk_csf_api.pkb_cria_item_nfe_legado;
-- Rotina: pkb_processos_nfe.
--
-- Em 01/02/2018 - Leandro Savenhago
-- Redmine #38939 - Performance dos Processos PL-SQL na Nuvem
-- Separa��o de fila de execu��o por MultOrg
--
-- Em 06/02/2018 - Angela In�s.
-- Redmine #38940 - Performance dos Processos PL-SQL na Nuvem.
-- Realizar a implementa��o dos processos PL/SQL, para que na nuvem seja executados em paralelo, por Mult-Orgazizacao, utilizando DBMS-SCHEDULE.
-- Rotinas: pkb_integracao.
--
-- Em 09/02/2018 - Angela In�s.
-- Redmine #39291 - Rotinas Program�veis - Cliente CIP Bancos - Notas fiscais Mercantis, de Servi�o e de Servi�o Cont�nuo.
-- Alterar nos processos de valida��o de ambiente para Notas Fiscais Mercantis, de Servi�o e de Servi�o Cont�nuo, que s�o executadas atrav�s do Processo
-- Web-Service, a execu��o das rotinas program�veis.
-- Rotina: pkb_ler_nfs_int_ws.
--
-- Em 22/02/2018 - Marcelo Ono
-- Redmine #38773 - Corre��es e implementa��es nos processos do projeto REINF.
-- 1- Implementado processo na valida��o da Nota Fiscal para alterar o campo "DM_ENVIO" para "0-N�o Enviado";
-- Rotina: pkb_ler_Nota_Fiscal.
--
-- Em 26/06/2018 - Angela In�s.
-- Redmine #44376 - Corre��o na valida��o (ambiente) de NF Mercantil - Al�quota FCP.
-- No processo de valida��o de ambiente da nota fiscal mercantil, a valida��o do campo ALIQ_FCP da tabela de imposto IMP_ITEMNF, est� incorreta.
-- O campo � FlexField, e deve ser considerado as casas decimais que est�o no cadastro (ff_obj_util_integr). O campo � do tipo num�rico, com 3 casas inteiros e
-- 4 casas decimais. Na m�scara utilizada para formata��o do campo, est� sendo considerado "999,00", quando deveria utilizar "999,0000".
-- Rotina: pkb_ler_Imp_ItemNf.
--
-- Em 03/07/2018 - Marcelo Ono.
-- Redmine #41705 - Implementado a valida��o dos campos "tipo de servi�o Reinf e indicador do CPRB" no item da nota fiscal.
-- Rotina: pkb_ler_Item_Nota_Fiscal.
--
-- Em 24/07/2018 - Marcos Ferreira
-- Redmine #40179 - Integra��o de XML Legado de NFe n�o est� chamando as rotinas programaveis
-- Defeito: Ap�s importa��o do XML de NFE Legado, as tabelas item e unidade estavam ficando desatualziadas
-- Corre��o: Habilitado a chamada da procedure pk_csf_api.pkb_cria_item_nfe_legado que foi reformulada
-- Procedures alteradas pkb_processos_nfe e pkb_processos_nfe_mo
--
-- Em 17/10/2018 - Angela In�s.
-- Redmine #47891 - Atualiza��o do Valor de Abatimento N�o Tribut�vel - Nota Fiscal Total.
-- Incluir o registro na tabela de campos FlexField, ff_obj_util_integr, a nova coluna, relacionada com o Objeto VW_CSF_NOTA_FISCAL_TOTAL_FF.
-- Rotina: pkb_ler_nota_fiscal_total.
--
-- Em 24/12/2018 - Angela In�s.
-- Redmine #49824 - Processos de Integra��o e Valida��es de Nota Fiscal (v�rios modelos).
-- Incluir os processos de integra��o, valida��es api e ambiente, para a tabela/view VW_CSF_ITEMNF_RES_ICMS_ST e tabela ITEMNF_RES_ICMS_ST. Esse processo se
-- refere aos modelos de notas fiscais 01-Nota Fiscal, e 55-Nota Fiscal Eletr�nica, e s�o utilizados para montagem do Registro C176-Ressarcimento de ICMS e
-- Fundo de Combate � Pobreza (FCP) em Opera��es com Substitui��o Tribut�ria (C�digo 01, 55), do arquivo Sped Fiscal.
-- Rotinas: pkb_ler_item_nota_fiscal e pkb_ler_itemnf_res_icms_st.
--
-- Em 26/12/2018 - Angela In�s.
-- Redmine #49824 - Processos de Integra��o e Valida��es de Nota Fiscal (v�rios modelos).
-- Alterar os processos de integra��o, valida��es api e ambiente, que utilizam a Tabela/View VW_CSF_ITEM_NOTA_FISCAL_FF, para receber a coluna DM_MAT_PROP_TERC.
-- Rotina: pkb_ler_Item_Nota_Fiscal.
--
-- Em 23/01/2019 - Karina de Paula
-- Redmine #49691 - DMSTPROC alterando para 1 ap�s update em NFSE - Dr Consulta
-- Criadas as vari�veis globais gv_objeto e gn_fase para ser usada no trigger T_A_I_U_Nota_Fiscal_02 tb alterados os objetos q
-- alteram ou incluem dados na nota_fiscal.dm_st_proc para carregar popular as vari�veis
--
--
-- Em 01/02/2019 - Karina de Paula
-- Redmine #51038 - Criar campos no banco
-- Rotina Alterada: pkb_ler_Nota_Fiscal_Local => Inclu�dos os campos: nome, cep, cod_pais, desc_pais, fone e email
--                  pkb_ler_Nota_Fiscal       => Inclu�dos os campos: cod_mensagem e msg_sefaz
--                  pkb_ler_ItemNF_Med        =>
--
-- Em 06/02/2019 - Karina de Paula
-- Redmine #48956 - De acordo com a solicita��o, o Indicador de Pagamento passa a ser considerado na Forma de Pagamento, al�m da Nota Fiscal (cabe�alho).
-- Rotina Alterada: pkb_ler_nf_forma_pgto => Inclu�do o campo: dm_ind_pag
--
-- Em 18/02/2019 - Karina de Paula
-- Redmine #51625 - Alterar a integracao dos novos campos view VW_CSF_NOTA_FISCAL_LOCAL para VW_CSF_NOTA_FISCAL_LOCAL_FF
-- Rotina Alterada: pkb_ler_Nota_Fiscal_Local => Exclu�dos os campos: nome, cep, cod_pais, desc_pais, fone e email da integra��o padr�o e 
--                                               inclu�dos na integra��o Flex Field 
--
-- Em 29/04/2019 - Renan Alves
-- Redmine #53963 - Motivo da Isen��o Anvisa sendo trocado na valida��o
-- Foi alterado o valor de trim(rec.cod_anvisa) para trim(rec.mot_isen_anvisa) no momento de passar as
-- informa��es do par�metro ev_valor da pk_csf_api.pkb_integr_itemnf_med_ff.
-- Rotina: pkb_ler_ItemNF_Med   
--
-------------------------------------------------------------------------------------------------------
-- Vari�veis Globais
   gn_multorg_id   mult_org.id%type;
   gv_objeto       varchar2(300);
   gn_fase         number;
   -- INICIO 1979
   vb_entrou               boolean := false; -- 1979
   vn_util_rabbitmq        number := 0;-- vari�vel que receber� dados da param_geral_sistema.PARAM_NAME = 'UTILIZA_RABBIT_MQ'
   MODULO_SISTEMA          constant number := pk_csf.fkg_ret_id_modulo_sistema('INTEGRACAO');
   GRUPO_SISTEMA           constant number := pk_csf.fkg_ret_id_grupo_sistema(MODULO_SISTEMA, 'CTRL_FILAS');
   vn_empresa_id           empresa.id%type; 
   vn_multorg_id           mult_org.id%type;
   vv_erro                 varchar2(4000);
   -- FIM 1979
-------------------------------------------------------------------------------------------------------
-- Procedimento faz a leitura de uma NF para valida��o

procedure pkb_ler_Nota_Fiscal ( en_notafiscal_id in nota_fiscal.id%type
                              , en_loteintws_id  in lote_int_ws.id%type default 0
                              );

-------------------------------------------------------------------------------------------------------
--| Procedimento que inicia a valida��o de Notas Fiscais canceladas
procedure pkb_ler_Nota_Fiscal_Canc ( en_multorg_id in mult_org.id%type, en_notafiscal_id in nota_fiscal.id%type default null );
-------------------------------------------------------------------------------------------------------  
--| Procedimento que inicia a valida��o de Notas Fiscais
procedure pkb_integracao;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a valida��o de Notas Fiscais por MultOrg demais modelos menos modelo 65
procedure pkb_integracao_mo ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a valida��o de Notas Fiscais por MultOrg somente para NFCE modelo 65
procedure pkb_integracao_nfce_mo ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a valida��o de Processo de Notas Fiscais n�o relacionados a Emiss�o
procedure pkb_processos_nfe;

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a valida��o de Processo de Notas Fiscais n�o relacionados a Emiss�o por MultOrg
procedure pkb_processos_nfe_mo ( en_multorg_id  in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de valida��o de dados de Nota Fiscal de Mercantis, oriundos de Integra��o por Web-Service
procedure pkb_int_ws ( en_loteintws_id      in     lote_int_ws.id%type
                     , en_tipoobjintegr_id  in     tipo_obj_integr.id%type
                     , sn_erro              in out number
                     , sn_aguardar          out    number         -- 0-N�o; 1-Sim
                     );

-------------------------------------------------------------------------------------------------------
-- Procedimento faz a leirura das Notas Fiscais Refer�nciadas para Valida��o

procedure pkb_ler_nf_referen ( est_log_generico_nf       in out nocopy  dbms_sql.number_table
                             , en_notafiscal_id          in             Nota_Fiscal.id%TYPE  );

-------------------------------------------------------------------------------------------------------

end pk_valida_ambiente;
/
