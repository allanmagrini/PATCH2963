create or replace package csf_own.pk_vld_amb_ws is

-------------------------------------------------------------------------------------------------------
--| Especificação do pacote de procedimentos de Validação de Ambiente de Web-Service
-------------------------------------------------------------------------------------------------------
--
-- Em 27/02/2021   - Armando
-- Redmine   - ADICIONANDO O OBJETO DE INTEGRAÇÃO 16
-- 			 - cursor c_dados is DA PK_VALIDAR_LOTE_EMISS_ST_REC
--	  	     - cursor c_dados is DA PK_VALIDAR_LOTE_EMISS_ST_PROC
--
-- Em 10/08/2020   - Armando
-- Redmine   - ajuste no objeto para trabalhar com RabbitMQ
--
-- Em 07/12/2020   - LuiZ ARMANDO - 2.9.5-2 / 2.9.6
-- Redmine         - NÃO TEM
-- Rotina Alterada - pkb_validar_lote_emiss_st_rec ADICIONADA CONDIÇÃO NO CURSOR (cursor c_dados is ) PARA CONSIDERAR A UTLIZAÇÃO OU NÃO DO RABBITMQ
--
-- Em 01/10/2020   - Armando/Luis Marqies - 2.9.4-4 / 2.9.5-1 / 2.9.5
-- Redmine #71897  - Integração de CTe - Emissão Própria - Documento Autorizado Adicionado por Gabriel 19 dias atrás. 
--                   Atualizado aproximadamente 6 horas atrás.
-- Rotina Alterada - pkb_validar_lote_int_ws - Incluido chamada para pkb_int_ws da pk_vld_amb_d100 para conhecimento
--                   de tranporte tipo de objeto de integração (1,3)

-- Em 17/09/2020   - Luis Marques - 2.9.4-3 / 2.9.5
-- Redmine #71544  - Integração WS DM_ST_PROC não muda status
-- Rotina Alterada - pkb_validar_lote_nao_emissao   => Incluído o novo objeto de integração "13" no if para chamada da pkb_validar_lote_int_ws
--                 - pkb_validar_lote_emiss_st_rec  => Incluído o novo objeto de integração "13" no if para chamada da pkb_validar_lote_int_ws
--                 - pkb_validar_lote_emiss_st_proc => Incluído o novo objeto de integração "13" no if para chamada da pkb_validar_lote_int_ws
--
-- Em 10/08/2020   - Karina de Paula
-- Redmine #69653  - Incluir objeto integração 16 na mesma validação do objeto 6
-- Rotina Alterada - pkb_exclui_lote                => Incluída a rotina de delete para o novo objeto de integração "16"
--                 - pkb_validar_lote_int_ws        => Incluído o novo objeto de integração "16" junto com o if do objeto "6"
--                 - pkb_validar_lote_nao_emissao   => Incluído o novo objeto de integração "16" no if para chamada da pkb_validar_lote_int_ws
--                 - pkb_validar_lote_emiss_st_rec  => Incluído o novo objeto de integração "16" no if para chamada da pkb_validar_lote_int_ws
--                 - pkb_validar_lote_emiss_st_proc => Incluído o novo objeto de integração "16" no if para chamada da pkb_validar_lote_int_ws
-- Liberado        - Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 16/06/2020   - Allan Magrini
-- Redmine #63759  - Chamada para validação de lotes WS de cupom SAT
-- Incluido na fase 3.4 a chamada para validação pk_vld_amb_cup_sat.pkb_int_ws
-- Rotina Alterada - pkb_validar_lote_int_ws
--
-- Em 15/06/2020   - Karina de Paula
-- Redmine #68495  - Chamar a nova pk para a calculadora fiscal
-- Rotina Alterada - pkb_validar_lote_int_ws => Incluída a chamada da pk_vld_amb_calc_fiscal.pkb_int_ws
-- Liberado        - Release_2.9.4, Patch_2.9.3.3 e Patch_2.9.2.6
--
-- Em 17/02/2020   - Allan Magrini
-- Redmine #63759  - Chamada para validação de lotes WS de cupom SAT
-- Incluido na fase 3.3 a chamada para validação pk_vld_amb_cup_sat.pkb_int_ws
-- Rotina Alterada - pkb_validar_lote_int_ws
--
-- Em 27/11/2019   - Karina de Paula
-- Redmine #60469  - Criar tipo de objeto Emissão Própria NFCE
-- Rotina Alterada - pkb_validar_lote_int_ws => Incluída a chamada da pk_valida_ambiente.pkb_int_nfce_ws como novo objeto de integração 13
--                   Retirada o if incluído temporariamente pela atividade #60217
--
-- Em 24/10/2019 - LUIZ ARMANDO AZONI
-- Redmine #60142 - GOLIVE USJ
-- ADEQUAÇÃO DA pkb_validar_lote_nao_emissao ALTERANDO A CONDIÇÃO
-- DE if vv_objintegr_cd not in ( '4', '5', '6', '7', '56' ) then
-- PARA if vv_objintegr_cd not in ( '4', '5', '6', '7' ) then
-- Rotina alterada: pkb_validar_lote_nao_emissao
-- Comentado chamada da procedure PK_VLD_AMB_WS.pkb_validar_lote_nao_emissao
--
-- Em 24/10/2019 - Marcos Ferreira
-- Redmine #60142 - GOLIVE USJ
-- Inclusão da chamada da rotina valida ambiente para o Gestão de Pedidos de Compra
-- Rotina alterada: pkb_validar_lote_int_ws
-- Comentado chamada da procedure pk_vld_amb_pedido.pkb_int_ws
--
-- Em 23/10/2019   - Karina de Paula
-- Redmine #60217  - Avaliar o retorno do WS
-- Rotina Alterada - pkb_validar_lote_int_ws => alterada para que qdo a variável vn_aguardar já estiver
-- com valor "1", não seja chamada a segunda rotina que é específica para as notas fiscais do MODELO 65
--
-- Em 21/10/2019 - Marcos Ferreira
-- Redmine #60142 - Remover Objetos Gestão de Pedidos de Compras
-- Inclusão de exclusão de registros lote_int_ws relacionados à tabela  r_loteintws_cred_dctf
-- Rotina alterada: pkb_validar_lote_int_ws
-- Comentado chamada da procedure pk_vld_amb_pedido.pkb_int_ws
--
-- Em 18/10/2019 - Eduardo Linden
-- Redmine #58798 - Adaptar tabela de lote de crédito para DCTF para processo de validação
-- Inclusão de exclusão de registros lote_int_ws relacionados à tabela  r_loteintws_cred_dctf
-- Rotina alterada: pkb_exclui_lote
--
-- Em 27/09/2019 - Luis Marques
-- Redmine #59325 - Nova Chamada para integração multorg para nota fiscal NFCE - modelo 65
-- Rotina Alterada - pkb_validar_lote_int_ws - Incluido chamada para notas fiscais modelo 65.
--
-- Em 04/09/2019   - Karina de Paula
-- Redmine #52227  - Tratamento no retorno da rejeição 204 (FRONERI)
-- Rotina Alterada - pkb_seta_st_proc => Foi incluida a verificacao se existe nota fiscal com codigo de msg 204 para manter o lote em processamento
-- Obs.: A ideia inicial era incluir um novo dominio na tabela msg_webserv para identificar os codigos que seriam tratados com essa excessao, mas
-- por orientacao da equipe JAVA pediram para q a tabela nao fosse alterada
--
-- ====== INCLUIR AS ALATERACOES ACIMA EM ORDEM DECRESCENTE ======================================================================= --
--
-- Em 20/05/2015 - Rogério Silva.
-- Redmine #8054 - Implementar package pk_vld_amb_ws
--
-- Em 22/05/2015 - Rogério Silva.
-- Redmine #8226 - Processo de Registro de Log em Packages - LOG_GENERICO
--
-- Em 07/11/2016  - Marcos Garcia
-- Redmine #22787 - Processo para excluir lotes sem referencia
-- Rotina         - pkb_exclui_lote
--
-- Em 24/05/2017  - Leandro Savenhago
-- Solicitar apenas 10 lotes por vez para validar
-- Rotina         - pkb_validar
--
-- Em 12/07/2017 - Angela Inês.
-- Redmine #32811 - Validação das Notas Fiscais - Ambiente WebService.
-- Alterar no processo pk_vld_amb_ws.pkb_validar_lote_emiss_st_rec/pkb_validar_lote_int_ws, a situação do lote para 2-Em processamento, depois que os registros
-- forem validados, ou seja, depois de passarem pelos processos de validação relacionados aos lotes.
--
-- Em 20/07/2017 - Angela Inês.
-- Redmine #32992 - Revisar procedimento publicos da package 431-pk_vld_amb_ws.
-- Retirar a condição para recuperar os 10 lotes (comando rownum), e tratando os lotes dentro do contexto de recuperação de objetos para cada procedimento.
-- Os procedimentos continuaram a recuperar 10 lotes por Mult-Org, porém 10 lotes relacionados aos objetos de cada procedimento.
-- Rotinas: pkb_validar_lote_nao_emissao e pkb_validar_lote_emiss_st_rec.
--
-- Em 29/08/2017 - Leandro Savenhago.
-- Retirado o log para informar que o lote esta em processamento
-- Rotinas: pkb_validar_lote_int_ws.
--
-- Em 12/02/2017 - Fábio Tavares.
-- Ajuste PK_VLD_AMB_WS para integração Bloco F600
-- Rotinas: pkb_validar_lote_int_ws.
--
-- Em 22/09/2017 - Angela Inês.
-- Redmine #34907 - Correção no processo de validação através de lote WebService.
-- Alterar a validação de ambiente WebService incluindo a chamada da rotina que valida os dados da integração de exportação, objeto 53, através de lote
-- WebService.
-- Rotina: pkb_validar_lote_int_ws.
--
-- Em 10/10/2017 - Fábio Tavares
-- Redmine #33822 - Integração de dados do Sped Reinf - Valida Ambiente
-- Rotina: pkb_validar_lote_int_ws.
--
-- Em 01/02/2018 - Leandro Savenhago
-- Redmine #33822 - Integração de dados do Sped Reinf - Valida Ambiente
--
-- Em 16/02/2018 - Angela Inês.
-- Redmine #39509 - Acompanhar os processos criados - Performance - Amazon HML.
-- Devido ao trabalho de performance - criação do Job Scheduller, eliminar o contador do processo: pkb_validar_lote_nao_emissao.
--
-- Em 26/02/2018 - Angela Inês.
-- Redmine #39509 - Acompanhar os processos criados - Performance - Amazon HML.
-- Devido ao trabalho de performance - criação do Job Scheduller, eliminar o contador do processo: pkb_validar_lote_emiss_st_rec.
--
-- Em 27/03/2018 - Angela Inês.
-- Redmine #41000 - Incluir os relacionamentos faltantes para exclusão do Lote.
-- 1) Objeto de Integração = 27-Escrituração Contábil Fiscal - SPED ECF: incluir as tabelas de relacionamento com LOTE_INT_WS.
-- 2) Objeto de Integração = 55-EFD-REINF - Retenções e Outras Informações Fiscais: incluir as tabelas de relacionamento com LOTE_INT_WS.
-- 3) Objeto de Integração = 1-Cadastros Gerais: incluir as tabelas de relacionamento com LOTE_INT_WS.
-- Rotina: pkb_exclui_lote.
--
-- Em 25/05/2018 - Marcos Fereira
-- Redmine: #43316 - LOTES GERADOS NÃO ESTÃO APARECENDO NO COMPLIANCE
-- Problema: Os Lotes rejeitados estão sendo excluídos da tabela lot_int_ws, gerando problema para o cliente conferir a integração
-- Solução: Em Reunião com Carlos e equipe PL foi decidido comentar a chamada da procedure pkb_exclui_lote
--          até a definição de um processo de para exclusão por períodos de lotes antigos
--
-- Em 10/12/2018 - Marcos Ferreira
-- Redmine #49530 - Integração Web Service Layout Dimob - Validação dos Registro
-- Solicitação: Implementar Validação Dimob para Integração WebServices
-- Procedures Alteradas: pkb_validar_lote_int_ws
--
-- Em 15/03/2019 - Karina de Paula
-- Redmine #52621 - Desenvolvimento - Novo processo de validação dos dados de integração
-- Rotina Alterada: pkb_validar_lote_int_ws => Incluir novo objeto de integração "PEDIDOS" (pk_vld_amb_pedido.pkb_int_ws)
--
-- ====== INCLUIR AS ALATERACOES ACIMA EM ORDEM DECRESCENTE ======================================================================= --
--
-- Variaveis Globais
   --
   gn_empresa_id   empresa.id%type;
   --
--
-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração não tem relação com a Emissão de Documentos Fiscais
procedure pkb_validar_lote_nao_emissao ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------


procedure pkb_validar_lote_int_ws ( en_loteintws_id in lote_int_ws.id%type);
  
---------------------------------------------------------------------------------------------------------
-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração não tem relação com a Emissão de Documentos Fiscais
procedure pkb_vld_lote_nao_emissao;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração tem relação com a Emissão de Documentos Fiscais
-- e Situação "1-Recebido", sempre de 10 em 10
procedure pkb_validar_lote_emiss_st_rec ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração tem relação com a Emissão de Documentos Fiscais
-- e Situação "1-Recebido", sempre de 10 em 10
procedure pkb_vld_lote_emiss_st_rec;

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração tem relação com a Emissão de Documentos Fiscais
-- e Situação "2-Em Processamento"
procedure pkb_validar_lote_emiss_st_proc ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

-- Procedimento de validar os registros de integração recebidos em Lotes de Integração Web-Service,
-- onde os Tipos de Objetos de Integração tem relação com a Emissão de Documentos Fiscais
-- e Situação "2-Em Processamento"
procedure pkb_vld_lote_emiss_st_proc;

-------------------------------------------------------------------------------------------------------

end pk_vld_amb_ws;
/
