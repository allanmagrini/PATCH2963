create or replace package csf_own.pk_integr_view_nfs is

-------------------------------------------------------------------------------------------------------
-- Especificação do pacote de integração de Notas Fiscais de Serviço a partir de leitura de views
--
-- Em 10/08/2020   - Luis Marques - 2.9.5
-- Redmine #58588  - Alterar tamanho de campo NRO_NF
--                 - Ajuste em todos os types campo "NRO_NF" de 9 para 30 para notas de serviços.
--
-- Em 16/09/2020   - Wendel Albino
-- Redmine #71510  - Notas de serviço nao integram
-- Rotina Alterada - pkb_ler_nota_fiscal_serv - alteracao do local dos contadores de qtd 
--
-- Em 26/08/2020  - Karina de Paula
-- Redmine #70837 - integração nfs-e
-- Alterações     - pkb_ler_nota_fiscal_serv => Inclusão do domínio 17 na verificação dos valores da variável vn_dm_st_proc
--                - pkb_ler_nota_fiscal_serv => Exclusão da chamada da pk_csf_api.pkb_excluir_dados_nf, já existe a chamada dessa rotina
--                  na pk_csf_api_nfs, ser chamada dos dois pontos pode gerar exclusão de dados filhos da nf antes da finalização da validação
--                  Nas rotinas da nf mercantil e nfce essa rotina tb somente é chamada na API
-- Liberado       - Release_2.9.5, Patch_2.9.4.2 e Patch_2.9.3.5
--
-- Em 06/05/2020  - Karina de Paula
-- Redmine #65401 - NF-e de emissão própria autorizada indevidamente (CERRADÃO)
-- Alterações     - Incluído para o gv_objeto o nome da package como valor default para conseguir retornar nos logs o objeto;
-- Liberado       - Release_2.9.4, Patch_2.9.3.2 e Patch_2.9.2.5
--
-- Em 16/03/2020 - Eduardo Linden
-- Redmine #65710 - Integração NFSe Emissão Própria no Padrão Open Interface - Campo Natureza da Operação
-- Inclusão de leitura e retorno do valor campo cod_nat
-- Rotina Alterada: pkb_ler_nf_serv_ff, pkb_ler_nota_fiscal_serv e pkb_ler_nota_fiscal_serv_ff
-- Disponivel para Release 2.9.3.9 e os patchs 2.9.1.6 e 2.9.2.3.
--
-- Em 16/03/2020 - Luis Marques - 2.9.3
-- Redmine #63776 - Integração de NFSe - Aumentar Campo Razao Social do Destinatário e Logradouro
--                  Ajustado tamanho dos campos nome e lograd no type "vt_tab_csf_nf_dest_serv".
--
-- Em 28/02/2020 - Eduardo Linden
-- Redmine #65370 - Problema de agendamento - contadores zerados.
-- Rotina Alterada: pkb_ler_nota_fiscal_serv - inclusão de geração de log para tabela log_generico_nf e assim
--                                             identificar o problema com os contadores de registros na integração.
-- Disponivel para Release 2.9.3.7 e patchs 2.9.1.6 e 2.9.2.3
--
-- Em 22/01/2020 - Luis Marques
-- Redmine #63755 - Falha na integração Open Interface - Emissão Própria
-- Rotina Alterada: pkb_ler_nota_fiscal_serv - Retirada validação para nota de emissão propria DM_IND_EMIT = 0 e 
--                  modelo 99 será colocado na PK_CSF_API_NFS na integração dos campos flex-field 
--                  (pk_csf_api_nfs.pkb_integr_nota_fiscal_serv_ff) verificando o DM_LEGADO x DM_ST_PROC 
--                  para atualizar o DM_ST_PROC do documento.
-- 
-- Em 24/10/2019 - Allan Magrini
-- Redmine #60308 - Avaliar o processo de integração de nota de serviço
-- Foi incluido o campo cidade_id na hora de gravar na tabela itemnf_compl_serv, fase 4.2           
-- Rotina Alterada    -  pkb_ler_itemnf_compl_serv
--
-- Em 09/10/2019        - Karina de Paula
-- Redmine #52654/59814 - Alterar todas as buscar na tabela PESSOA para retornar o MAX ID
-- Rotinas Alteradas    - Trocada a função pk_csf.fkg_cnpj_empresa_id pela pk_csf.fkg_empresa_id_cpf_cnpj
-- NÃO ALTERE A REGRA DESSAS ROTINAS SEM CONVERSAR COM EQUIPE
--
-- Em 17/09/2019               - Karina de Paula
-- Redmine #58226/58769/58836  - feed - retorno para NFe
-- Rotina Alterada             - pkb_ret_infor_erp_neo  => Incluída a desativiação das viewSs VW_CSF_RESP_NFS_ERP e VW_CSF_RESP_NFS_ERP_FF quando estiver ATIVADA a VW_CSF_RESP_NFS_ERP_NEO
-- As alterações feitas inicialmente foram perdidas em função de uma atualização indevida minha
--
-- Em 24/08/2019        - Karina de Paula
-- Redmine #59095/59203 - Criar integração da VW_CSF_NOTA_FISCAL_SERV_FF
-- Rotina Alterada      - pkb_ler_nf_serv_cod_mod_ff => mudado nome para pkb_ler_nf_serv_ff para que possa ser usado p qq campos FF e incluído o campo NRO_AUT_NFS
--                        pk_csf_api_nfs.pkb_integr_nota_fiscal_serv_ff => não foi alterada pq já tratava o campo NRO_AUT_NFS
--                        pkb_ler_nota_fiscal_serv_ff => Incluido o campo NRO_AUT_NFS
--
-- Em 22/08/2019 - Karina de Paula
-- Redmine #53545 - Criar VW unica para retorno ao ERP
-- Rotina Alterada: Criada a nova procedure pkb_int_infor_erp_neo para integração da view VW_CSF_RESP_NF_ERP_NEO
--                  Criada a nova procedure pkb_ret_infor_erp_neo para integração da view VW_CSF_RESP_NF_ERP_NEO
--                  fkg_ret_dm_st_proc_erp    => Incluído o novo parâmetro de entrada ev_obj_name para poder ser usado também pela nova view VW_CSF_RESP_NF_ERP_NEO
--                                               e incluída a verificação pk_csf.fkg_existe_obj_util_integr
--                  pkb_ret_infor_erro_nf_erp => Retirado da função interna fkg_existe_log a chamada da pk_csf.fkg_existe_obj_util_integr porque já é chamada
--                                               no início do processo da pkb_ret_infor_erro_nf_erp
--                                            => Criado o parâmetro de entrada ev_obj para que possa ser usado para as duas views:
--                                               VW_CSF_RESP_NF_ERP e VW_CSF_RESP_NF_ERP_NEO
--                                            => Incluídos novos campos COD_MSG e ID_ERP para retorno na view VW_CSF_RESP_NF_ERP_NEO
--                  pkb_integracao/pkb_integr_multorg/pkb_gera_retorno => Incluída a chamada da pkb_int_infor_erp_neo e pkb_ret_infor_erp_neo
--
-- Em 26/07/2019 - Luis Marques
-- Redmine #56729 - feed - CT-e e NFS-e ainda ficam com erro de validação
-- Rotina Alterada: pkb_ler_nota_fiscal_serv
--                  Ajustada verificação do log_generico para não deixar o documento com DM_ST_PROC errado.
--
-- Em 23/07/2019 - Luis Marques
-- Redmine #56565 - feed - Mensagem de ADVERTENCIA está deixando documento com ERRO DE VALIDAÇÂO
-- Rotina alterada: pkb_ler_nota_fiscal_serv
--                  Alterado para colocar verificação de falta de Codigo de base de calculo de PIS/COFINS
--                  como advertencia e não marcar o documento com erro de validação se for só esse log.
--   
-- EM 24/06/2019 - Luis Marques
-- Redmine #55214 - feed - não retornou os campos desejados
-- Atualizando proceimento para ler conforme cid do destinatario
-- Rotina: pkb_ler_nf_dest_serv
--
-- ===== AS ALTERAÇÕES ABAIXO ESTÃO NA ORDEM ANTIGA - CRESCENTE ======================================================== --
--
-- Em 03/09/2012 - Angela Inês.
-- 1) Eliminar os espaços a direita e a esquerda da coluna SERIE.
--
-- Em 17/09/2012 - Angela Inês - Ficha HD 63072.
-- 1) Não considerar se a nota de serviço é de terceiros para verificar a situação de retorno de ERP - inclusão do parâmetro DBLINK.
--    Rotina: fkg_ret_dm_st_proc_erp.
-- 2) Inclusão do processo de integração de Impostos Retidos - Processo Flex Field (FF).
-- 3) Considerar o identificador da nota fiscal para alterar o registro de retorno.
--    Rotina: pkb_ret_infor_erp.
--
-- Em 18/10/2012 - Angela Inês.
-- Ficha HD 64002 - Manter a coluna dm_st_proc da view de integração para as notas fiscais de emissão própria quando a mesma não estiver com dm_st_proc = 0.
--
-- Em 28/12/2012 - Angela Inês.
-- Ficha HD 65154 - Fechamento Fiscal por empresa.
-- Verificar a data de último fechamento fiscal, não permitindo integrar, se a data estiver posterior ao período em questão.
--
-- Em 04/03/2013
-- Sem Ficha HD - Processo feito para a Alta Genetics
-- Foi comentado o PRAGMA no processo pk_integr_view_nfs.pkb_ret_infor_erro_nf_erp.
--
-- Em 06/03/2013
-- Sem Ficha HD - Processo feito para a Alta Genetics
-- Foi comentado o PRAGMA no processo pk_integr_view_nfs.pkb_ret_infor_erp e pk_integr_view_nfs.pkb_int_infor_erp.
-- Alterado a função pk_integr_view_nfs.fkg_ret_dm_st_proc_erp para a condição where somente pelo id da nota ao invés da chave.
--
-- Em 03/05/2013 - Angela Inês.
-- Ficha HD 66678 - Islaine - Integração de NFS de Serviço não está setando campo owner.
-- Rotinas: pkb_integr_periodo, pkb_integr_periodo_geral
--
-- Em 26/02/2014 - Angela Inês.
-- Redmine #2087 - Passar a gerar log no agendamento quando a data do documento estiver no período da data de fechamento.
-- Rotina: pkb_ler_nota_fiscal_serv.
--
--
-- Em 08/09/2014 - Leandro Savenhago.
-- Redmine #4164 - Problema de Integração de NFSe.
-- Rotina/Alteração: pkb_ler_nota_fiscal_serv - Retirado a consição de pesquisa fixa DM_ST_PROC in (0, 4, 7).
--                   pkb_excluir_nfs - criada a funcionalidade
--                   pkb_int_infor_erp - Alterada a rotina para implementar o procedimento "pkb_excluir_nfs"
--                   pkb_ret_infor_erp: Alterado a rotina para que caso não exista registro na tabela VW_CSF_RESP_NF_ERP,
                                    -- alteração do campo DM_ST_INTEGRA da tabela NOTA_FISCAL para 7-Integração por view de banco de dados, para incluir novamente o registro.
--
-- Em 05/11/2014 - Rogério Silva
-- Redmine #5020 - Processo de contagem de registros integrados do ERP (Agendamento de integração)
--
-- Em 12/10/2014 - Rogério Silva
-- Redmine #5508 - Desenvolver tratamento no processo de contagem de dados
--
-- Em 06/01/2015 - Angela Inês.
-- Redmine #5616 - Adequação dos objetos que utilizam dos novos conceitos de Mult-Org.
--
-- Em 12/01/2015 - Rogério Silva.
-- Redmine #5705 - Retorno de Informação de NFSe como Flex-Field.
-- Rotinas: pkb_int_ret_infor_erp_ff, fkg_existe_registro e fkg_monta_obj.
--
-- Em 03/02/2015 - Rogério Silva.
-- Redmine #6177 - Erro na integração de NFS
-- Rotina: pkb_ler_nf_cobr_dup
--
-- Em 02/06/2015 - Rogério Silva.
-- Redmine #8233 - Processo de Registro de Log em Packages - Notas Fiscais de Serviços EFD
--
-- Em 01/07/2015 - Rogério Silva.
-- Redmine #9707 - Avaliar os processos que utilizam empresa_integr_banco.dm_ret_infor_integr: variáveis locais e globais.
--
-- Em 30/07/2015 - Rogério Silva.
-- Redmine #9832 - Alteração do processo de Integração Open Interface Table/View
--
-- Em 07/08/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 28/03/2016 - Rogério Silva.
-- Redmine #16933 - Alteração no processo de retorno de NFS-e
--
-- Em 29/08/2016 - Angela Inês.
-- Redmine #22691 - Código CNAE - NFSe Campinas.
-- Aumentar o tamanho do campo CNAE para 9 caracteres.
--
-- Em 02/09/2016
-- Desenvolvedor: Marcos Garcia
-- Redmine #22304 - Alterar os processos de integração/validação.
-- Foi alterado a manipulação dos campos Fone e Fax, por conta da alteração dos mesmos em tabelas de integração.
--
-- Em 08/09/2016 - Rogério Silva.
-- Redmine #23264 - Retirar a declaração "PRAGMA AUTONOMOUS_TRANSACTION" de todo o processo de integração de NFS-e.
--
-- Em 01/03/2017 - Leandro Savenhago
-- Redmine 28832- Implementar o "Parâmetro de Formato de Data Global para o Sistema".
-- Implementar o "Parâmetro de Formato de Data Global para o Sistema".
--
-- Em 06/06/2017 - Leandro Savenhago
-- Redmine 31613- Processo de Emissão de NFSe não está gerando lote completo para disponibilizar resposta ao SIC
-- Rotina: pkb_int_infor_erp - atualizar o COD_PART, mesmo que em emissão própria
--
-- Em 16/06/2017 - Marcos Garcia
-- Redmine #30475 - Avaliações nos Processos de Integração e Relatórios de Inconsistências - Processo de Fechamento Fiscal.
-- Atividade: Parametrização do log com o tipo 39-fechamento fiscal
--            referencia_id nula, obj_referencia = a tabela atual no momento da integração e a empresa solicitante da integração.
--            Log de fechamento fiscal aparecerá nos relatórios de integração.
--
-- Em 28/06/2017 - Angela Inês.
-- Redmine #32409 - Correção técnica no processo de Integração de Notas Fiscais de Serviço.
-- Eliminar o comando PRAGMA do processo de Integração de Notas Fiscais de Serviço.
-- Rotinas: Todas.
--
--  Em 30/06/2017 - Leandro Savenhago
-- Redmine #31839 - CRIAÇÃO DOS OBJETOS DE INTEGRAÇÃO - STAFE
-- Criação do Procedimento PKB_STAFE
--
-- Em 19/07/2017 - Marcos Garcia
-- Redmine# 30475 - Avaliações nos Processos de Integração e Relatórios de Inconsistências - Processo de Fechamento Fiscal.
-- Criação da variavel global info_fechamento, que é alimentada antes do inicio das integrações
-- com o identificador do fechamento fiscal.(csf_tipo_log).
--
-- Em 27/09/2017 - Angela Inês.
-- Redmine #35027 - Correção na View de retorno de Nota fiscal de serviço - Código de Verificação NFS.
-- No processo de integração de retorno de nota fiscal, as informações de Flex_field (id_erp, cod_verif_nfs), estão sendo gerados corretamente. Porém o código de
-- verificação (cod_verif_nfs), só existe após o retorno da prefeitura, e nem sempre essa informação já existe no momento da integração. Após receber essa
-- informação, temos o processo de retorno da prefeitura que estar atualizando esse código na view de retorno Flex-field.
-- Avaliando o processo com o Leandro, o mesmo, orientou que esse processo deve estar, também, no processo de retorno da prefeitura.
-- Correção: executar no processo de retorno da prefeitura, a atualização dos campos flex-field da view de retorno.
-- Rotina: pkb_ret_infor_erp.
--
-- Em 09/10/2017 - Fábio Tavares
-- Redmine #33828 - Integração Complementar de NFS para o Sped Reinf
-- Rotina: Adicionar as novas views do REINF
--
-- Em 19/10/2017 - Angela Inês.
-- Redmine #35651 - Precisamos que a informação da coluna "COD_PART" seja gravada com o mesmo valor nas tabelas W_CSF_RESP_NFS_ERP e W_CSF_RESP_NFS_ERP_FF.
-- Precisamos que a informação da coluna "COD_PART" seja gravada com NULL nas tabelas W_CSF_RESP_NFS_ERP e W_CSF_RESP_NFS_ERP_FF.
-- Rotina: pkb_int_infor_erp.
--
-- Em 08/11/2017 - Fábio Tavares
-- Redmine #36321 - Correção no processo de validação de notas fiscais de serviço
-- Rotina: pkb_ler_nfs_det_constr_civil
--
-- Em 13/11/2017 - Angela Inês.
-- Redmine #36474 - Correção no processo de retorno em TXT da Nota Fiscal de Serviço.
-- Para que o processo de retorno em TXT aconteça, o processo de integração deverá ser alterado, gravando espaço na coluna COD_PART quando for NULL.
-- Rotinas: pkb_int_infor_erp e pkb_int_ret_infor_erp_ff.
--
-- Em 14/11/2017 - Angela Inês.
-- Redmine #36496 - Correção técnica no processo de Integração de NFS - Processo de Retorno.
-- O valor "espaço", (' '), gravado na coluna COD_PART das views de retorno, VW_CSF_RESP_NFS_ERP e VW_CSF_RESP_NFS_ERP_FF, deve estar envolvido com aspas
-- simples, devido ao comando dinâmico.
-- Rotinas: pkb_int_infor_erp e pkb_int_ret_infor_erp_ff.
--
-- Em 17/11/2017 - Marcos Garcia
-- Redmine Implementação de Flex-Field VW_CSF_NF_CANC_SERV_FF.ID_ERP
-- Implementações por conta do novo valor para os campo flex-field.
-- rotina: pkb_ler_nf_canc_serv_ff.
--
-- Em 12/12/2017 - Angela Inês.
-- Redmine #37484 - Correção na integração de notas fiscais de serviço - Duplicatas.
-- Considerar as duplicatas que possuem a data de vencimento maior ou igual a data de emissão da nota fiscal.
-- Rotina: pkb_ler_nf_cobr_dup.
--
-- Em 15/01/2018 - Karina de Paula
-- Redmine #38184 - Alterada a pkb_ler_nota_fiscal_serv para integrar informações do complemento do serviço pk_csf_api_nfs.gt_row_nf_compl_serv
-- pkb_int_ret_infor_erp_ff - Alterado o union incluindo atributo NRO_AUT_NFS
--
-- Em 29/01/2018 - Karina de Paula
-- Redmine #38953 - Retirada a function pk_csf.fkg_converte do tratamento do campo SERIE nos objetos pkb_int_ret_infor_erp_ff e fkg_existe_registro
--
-- Em 01/02/2018 - Angela Inês.
-- Redmine #39079 - Integração Open-Interface de Nota Fiscal Serviço EFD por Job Scheduller.
-- Rotina: pkb_integr_multorg.
--
-- Em 02/02/2018 - Karina de Paula
-- Redmine #39012 - Integração da nota fiscal de serviço - validação do campo CNAE.
-- Alterada a rotina pkb_ler_nota_fiscal_serv
--
-- Em 06/06/2018 - Marcelo Ono
-- Redmine #43088 - Implementado a integração de informações de impostos adicionais de aposentadoria especial.
-- Rotina: pkb_ler_imp_itemnf_serv, pkb_ler_imp_adic_apos_esp_serv.
--
-- Em 06/08/2018 - Marcos Ferreira
-- Redmine #33155 - Adaptar Layout de Inttegração de Nota Fiscais de Serviço para novo campo.
-- Rotina: pkb_ler_nf_dest_serv
-- Inclusão do campo "id_estrangeiro" na rotina de integração
--
-- Em 15/08/2018 - Angela Inês.
-- Redmine #46001 - Correções: Relatório de documentos fiscais (Item) e Integração de Notas Fiscais de Serviço.
-- A alteração do campo PESSOA_ID em NOTA_FISCAL foi feita através da atividade/redmine #39012 - Integração da nota fiscal de serviço - validação do campo CNAE.
-- Na integração da nota fiscal de serviço está sendo atribuído, erroneamente, o identificador do pessoa da empresa vinculado com a nota fiscal.
-- Tecnicamente: nota_fiscal.empresa_id, empresa.pessoa_id => nota_fiscal.pessoa_id.
-- Nesse momento do processo temos que deixar o campo como NULO (nota_fiscal.pessoa_id), pois o mesmo será atualizado através do Código do Participante enviado na
-- view de integração. Tecnicamente: vw_csf_nota_fiscal_serv.cod_part, recuperar com o mult-org da empresa em questão e com o código do participante, na tabela
-- pessoa. Encontrando o identificador (pessoa.cod_part=vw_csf_nota_fiscal_serv.cod_part,pessoa.id), o campo na nota fiscal será atualizado(nota_fiscal.pessoa_id).
-- Rotina: pkb_ler_nota_fiscal_serv.
--
-- Em 25/08/2018 - Angela Inês.
-- Redmine #46371 - Agendamento de Integração cujo Tipo seja "Todas as Empresas".
-- Incluir o identificador do Mult-Org como parâmetro de entrada (mult_org.id), para Agendamento de Integração como sendo do Tipo "Todas as Empresas".
-- Rotina: pkb_integr_periodo_geral.
--
-- Em 18/12/2018 - Karina de Paula
-- Redmine 49790 - Erro na Integração de notas de serviço na Stone
-- Rotina Alterada: Todas as rotinas que usam o valor "SERIE" na montagem de sql dinamico em todas as clausulas (select/where/order by)
-- Esse erro já havia ocorrido com o mesmo cliente e foi corrigido em janeiro/2018 pela atividade 38953. Mas, na época somente foi
-- alteradas as rotinas solicitadas.
-- Retirada a function pk_csf.fkg_converte
--
-- Em 07/01/2019 - Karina de Paula
-- Redmine #49124 - Layout de Nota Fiscal de Servico campos nro_nfs e dt_emiss_nfs
-- Rotina Alterada: pkb_int_ret_infor_erp_ff => Retirado o union que do atributo NRO_AUT_NFS q foi incluído no Redmine(38184)
--                                              O NRO_AUT_NFS não é um valor de atributo para a view VW_CSF_RESP_NFS_ERP_FF 
--
-- Em 23/01/2019 - Karina de Paula
-- Redmine #49691 - DMSTPROC alterando para 1 após update em NFSE - Dr Consulta
-- Criadas as variáveis globais gv_objeto e gn_fase para ser usada no trigger T_A_I_U_Nota_Fiscal_02 tb alterados os objetos q 
-- alteram ou incluem dados na nota_fiscal.dm_st_proc para carregar popular as variáveis
--
-- Em 25/02/2019 - Karina de Paula
-- Redmine #51882 - Incluir exclusao dos dados da view VW_CSF_NOTA_FISCAL_CANC_FF nos objetos que chamam a exclusao da VW_CSF_NOTA_FISCAL_CANC
-- Rotina Alterada: pkb_ler_Nota_Fiscal_Canc.pkb_excluir_canc => Incluído delete da view VW_CSF_NF_CANC_SERV_FF
--
-- Em 18/03/2019 - Angela Inês.
-- Redmine #46056 - Processo de Integração de NF de Serviço.
-- Eliminar das rotinas pk_integr_view_nfs.pkb_ler_nota_fiscal_serv e pk_valida_ambiente.pkb_ler_nota_fiscal_serv, o select que recupera as informações de IBGE
-- da cidade da empresa da nota fiscal, e incluir na rotina pk_csf_api_nfs.pkb_integr_itemnf_compl_serv.
-- Variáveis utilizadas: gv_ibge_cidade_empr e gv_cod_mod.
-- Rotina: pkb_ler_nota_fiscal_serv.
--
-- Em 29/03/2019 - Karina de Paula
-- Redmine #52894 - feed - nao está gerando informações na tabela imp_itemnf_orig
-- Rotina Alterada: pkb_ler_nota_fiscal_serv => Incluída a verificação das variáveis vn_dm_guarda_imp_orig e vn_existe_dados
--
-- Em 02/04/2019 - Karina de Paula
-- Redmine #52997 - feed - erro na integração do imposto
-- Rotina Criada: Rotinas da calculadora fiscal
--
--
---------------------------------------------------------------------------------------------------------------------------------------------------

--| informações de notas fiscais de serviços não integradas
   -- Nível - 0
   type tab_csf_nota_fiscal_serv is record ( cpf_cnpj_emit       varchar2(14)
                                           , dm_ind_emit         number(1)
                                           , dm_ind_oper         number(1)
                                           , cod_part            varchar2(60)
                                           , serie               varchar2(3)
                                           , nro_nf              number(30)
                                           , subserie            number(3)
                                           , dt_emiss            date
                                           , dt_exe_serv         date
                                           , dt_sai_ent          date
                                           , sit_docto           varchar2(2)
                                           , chv_nfse            varchar2(60)
                                           , dm_ind_pag          number(1)
                                           , dm_nat_oper         number(1)
                                           , dm_tipo_rps         number(1)
                                           , dm_status_rps       number(1)
                                           , nro_rps_subst       number(9)
                                           , serie_rps_subst     varchar2(3)
                                           , dm_st_proc          number(2)
                                           , sist_orig           varchar2(10)
                                           , unid_org            varchar2(20) 
                                           );
   --
   type t_tab_csf_nota_fiscal_serv is table of tab_csf_nota_fiscal_serv index by binary_integer;
   vt_tab_csf_nota_fiscal_serv t_tab_csf_nota_fiscal_serv;
--
--| informações dos Itens de Serviço Prestado.
   -- Nível - 1
   type tab_csf_itemnf_compl_serv is record ( cpf_cnpj_emit           varchar2(14)
                                            , dm_ind_emit             number(1)
                                            , dm_ind_oper             number(1)
                                            , cod_part                varchar2(60)
                                            , serie                   varchar2(3)
                                            , nro_nf                  number(30)
                                            , nro_item                number
                                            , cod_item                varchar2(60)
                                            , descr_item              varchar2(2000)
                                            , cfop                    number(4)
                                            , vl_servico              number(15,2)
                                            , vl_desc_incondicionado  number(15,2)
                                            , vl_desc_condicionado    number(15,2)
                                            , vl_deducao              number(15,2)
                                            , vl_outra_ret            number(15,2)
                                            , cnae                    varchar2(9)
                                            , cd_lista_serv           number(4)
                                            , cod_trib_municipio      varchar2(20)
                                            , nat_bc_cred             varchar2(2)
                                            , dm_ind_orig_cred        number(1)
                                            , dt_pag_pis              date
                                            , dt_pag_cofins           date
                                            , dm_loc_exe_serv         number(1)
                                            , dm_trib_mun_prest       number(1)
                                            , cidade_ibge             number(7)
                                            , cod_cta                 varchar2(60)
                                            , cod_ccus                varchar2(30)
                                            );
   --
   type t_tab_csf_itemnf_compl_serv is table of tab_csf_itemnf_compl_serv index by binary_integer;
   vt_tab_csf_itemnf_compl_serv t_tab_csf_itemnf_compl_serv;
--
--| Informações dos Itens de Serviço Prestado - campos flex-field.
   -- Nível - 1
   type tab_csf_itnf_compl_serv_ff is record ( cpf_cnpj_emit           varchar2(14)
                                             , dm_ind_emit             number(1)
                                             , dm_ind_oper             number(1)
                                             , cod_part                varchar2(60)
                                             , serie                   varchar2(3)
                                             , nro_nf                  number(30)
                                             , nro_item                number
                                             , atributo                varchar2(30)
                                             , valor                   varchar2(255)
                                             );
   --
   type t_tab_csf_itnf_compl_serv_ff is table of tab_csf_itnf_compl_serv_ff index by binary_integer;
   vt_tab_csf_itnf_compl_serv_ff t_tab_csf_itnf_compl_serv_ff;
--
--| informações de imposto do serviço
   -- Nível - 2
   type tab_csf_imp_itemnf_serv is record ( cpf_cnpj_emit           varchar2(14)
                                          , dm_ind_emit             number(1)
                                          , dm_ind_oper             number(1)
                                          , cod_part                varchar2(60)
                                          , serie                   varchar2(3)
                                          , nro_nf                  number(30)
                                          , nro_item                number
                                          , cod_imposto             number(3)
                                          , dm_tipo                 number(1)
                                          , cod_st                  varchar2(2)
                                          , vl_base_calc            number(15,2)
                                          , aliq_apli               number(5,2)
                                          , vl_imp_trib             number(15,2)
                                          );
   --
   type t_tab_csf_imp_itemnf_serv is table of tab_csf_imp_itemnf_serv index by binary_integer;
   vt_tab_csf_imp_itemnf_serv t_tab_csf_imp_itemnf_serv;
--| informações de imposto do serviço - processo FF
   -- Nível - 1
   type tab_csf_imp_itemnf_serv_ff is record ( cpf_cnpj_emit varchar2(14)
                                             , dm_ind_emit   number(1)
                                             , dm_ind_oper   number(1)
                                             , cod_part      varchar2(60)
                                             , serie         varchar2(3)
                                             , nro_nf        number(30)
                                             , nro_item      number
                                             , cod_imposto   number(3)
                                             , dm_tipo       number(1)
                                             , atributo      varchar2(30)
                                             , valor         varchar2(255)
                                             );
   --
   type t_tab_csf_imp_itemnf_serv_ff is table of tab_csf_imp_itemnf_serv_ff index by binary_integer;
   vt_tab_csf_imp_itemnf_serv_ff t_tab_csf_imp_itemnf_serv_ff;
--
--
--| informações de impostos adicionais de aposentadoria especial
   -- Nível - 3
   type tab_csf_imp_adicaposespserv is record ( cpf_cnpj_emit varchar2(14)
                                              , dm_ind_emit   number(1)
                                              , dm_ind_oper   number(1)
                                              , cod_part      varchar2(60)
                                              , serie         varchar2(3)
                                              , nro_nf        number(30)
                                              , nro_item      number
                                              , cod_imposto   number(3)
                                              , dm_tipo       number(1)
                                              , percentual    number(3)
                                              , vl_adicional  number(14,2)
                                              );
   --
   type t_tab_csf_imp_adicaposespserv is table of tab_csf_imp_adicaposespserv index by binary_integer;
   vt_tab_csf_imp_adicaposespserv t_tab_csf_imp_adicaposespserv;
--
--| informações de observação da nota fiscal
   -- Nível - 1
   type tab_csf_nfinfor_adic_serv is record ( cpf_cnpj_emit           varchar2(14)
                                            , dm_ind_emit             number(1)
                                            , dm_ind_oper             number(1)
                                            , cod_part                varchar2(60)
                                            , serie                   varchar2(3)
                                            , nro_nf                  number(30)
                                            , dm_tipo                 number(1)
                                            , campo                   varchar2(256)
                                            , conteudo                varchar2(4000)
                                            , orig_proc               number(1)
                                            );
   --
   type t_tab_csf_nfinfor_adic_serv is table of tab_csf_nfinfor_adic_serv index by binary_integer;
   vt_tab_csf_nfinfor_adic_serv t_tab_csf_nfinfor_adic_serv;
--
--| informações Tomador do Serviço
   -- Nível - 1
   type tab_csf_nf_dest_serv is record ( cpf_cnpj_emit           varchar2(14)
                                       , dm_ind_emit             number(1)
                                       , dm_ind_oper             number(1)
                                       , cod_part                varchar2(60)
                                       , serie                   varchar2(3)
                                       , nro_nf                  number(30)
                                       , cnpj                    varchar2(14)
                                       , cpf                     varchar2(11)
                                       , nome                    varchar2(150)
                                       , lograd                  varchar2(150)
                                       , nro                     varchar2(10)
                                       , compl                   varchar2(60)
                                       , bairro                  varchar2(60)
                                       , cidade                  varchar2(60)
                                       , cidade_ibge             number(7)
                                       , uf                      varchar2(2)
                                       , cep                     number(8)
                                       , cod_pais                number(4)
                                       , pais                    varchar2(60)
                                       , fone                    varchar2(14) --varchar2(13)
                                       , ie                      varchar2(14)
                                       , suframa                 varchar2(9)
                                       , email                   varchar2(60)
                                       , im                      varchar2(15)
                                       , id_estrangeiro          varchar2(20)
                                       );
   --
   type t_tab_csf_nf_dest_serv is table of tab_csf_nf_dest_serv index by binary_integer;
   vt_tab_csf_nf_dest_serv t_tab_csf_nf_dest_serv;
--
--| informações sobre o intermediario do serviço
   -- Nível - 1
   type tab_csf_nf_inter_serv is record ( cpf_cnpj_emit           varchar2(14)
                                        , dm_ind_emit             number(1)
                                        , dm_ind_oper             number(1)
                                        , cod_part                varchar2(60)
                                        , serie                   varchar2(3)
                                        , nro_nf                  number(30)
                                        , nome                    varchar2(115)
                                        , inscr_munic             varchar2(15)
                                        , cpf_cnpj                varchar2(14)
                                        );
   --
   type t_tab_csf_nf_inter_serv is table of tab_csf_nf_inter_serv index by binary_integer;
   vt_tab_csf_nf_inter_serv t_tab_csf_nf_inter_serv;
--
--| informações sobre os detalhes da contrução civil
   -- Nível - 1
   type tab_csf_nfs_det_cc is record ( cpf_cnpj_emit           varchar2(14)
                                     , dm_ind_emit             number(1)
                                     , dm_ind_oper             number(1)
                                     , cod_part                varchar2(60)
                                     , serie                   varchar2(3)
                                     , nro_nf                  number(30)
                                     , cod_obra                varchar2(15)
                                     , nro_art                 varchar2(15)
                                     , nro_cno                 number(14)
                                     , dm_ind_obra             number
                                     );
   --
   type t_tab_csf_nfs_det_cc is table of tab_csf_nfs_det_cc index by binary_integer;
   vt_tab_csf_nfs_det_cc t_tab_csf_nfs_det_cc;
--
--| informações das duplicatas da cobrança
   -- Nível - 1
   type tab_csf_nf_cobr_dup is record ( cpf_cnpj_emit           varchar2(14)
                                      , dm_ind_emit             number(1)
                                      , dm_ind_oper             number(1)
                                      , cod_part                varchar2(60)
                                      , serie                   varchar2(3)
                                      , nro_nf                  number(30)
                                      , nro_fat                 varchar2(60)
                                      , nro_parc                varchar2(60)
                                      , dt_vencto               date
                                      , vl_dup                  number(15,2)
                                      );
   --
   type t_tab_csf_nf_cobr_dup is table of tab_csf_nf_cobr_dup index by binary_integer;
   vt_tab_csf_nf_cobr_dup t_tab_csf_nf_cobr_dup;
--
--| informações do complemento do serviço
   -- Nível - 1
   type tab_csf_nf_compl_serv is record ( cpf_cnpj_emit           varchar2(14)
                                        , dm_ind_emit             number(1)
                                        , dm_ind_oper             number(1)
                                        , cod_part                varchar2(60)
                                        , serie                   varchar2(3)
                                        , nro_nf                  number(30)
                                        , id_erp                  number
                                        );
   --
   type t_tab_csf_nf_compl_serv is table of tab_csf_nf_compl_serv index by binary_integer;
   vt_tab_csf_nf_compl_serv t_tab_csf_nf_compl_serv;
--
--| informações para o cancelamento da nota fiscal
   -- Nível - 1
   type tab_csf_nf_canc_serv is record ( cpf_cnpj_emit           varchar2(14)
                                       , dm_ind_emit             number(1)
                                       , dm_ind_oper             number(1)
                                       , cod_part                varchar2(60)
                                       , serie                   varchar2(3)
                                       , nro_nf                  number(30)
                                       , dt_canc                 date
                                       , justif                  varchar2(255)
                                       );
   --
   type t_tab_csf_nf_canc_serv is table of tab_csf_nf_canc_serv index by binary_integer;
   vt_tab_csf_nf_canc_serv t_tab_csf_nf_canc_serv;
--
--| informações Flex Field de notas fiscais de serviços não integradas
   type tab_csf_nota_fiscal_serv_ff is record ( cpf_cnpj_emit       varchar2(14)
                                              , dm_ind_emit         number(1)
                                              , dm_ind_oper         number(1)
                                              , cod_part            varchar2(60)
                                              , serie               varchar2(3)
                                              , nro_nf              number(30)
                                              , atributo            varchar2(30)
                                              , valor               varchar2(255)
                                              );
   --
   type t_tab_csf_nota_fiscal_serv_ff is table of tab_csf_nota_fiscal_serv_ff index by binary_integer;
   vt_tab_csf_nota_fiscal_serv_ff t_tab_csf_nota_fiscal_serv_ff;
--    
--| informações Flex Field para o cancelamento da nota fiscal
   type tab_csf_nf_canc_serv_ff is record ( cpf_cnpj_emit       varchar2(14)
                                          , dm_ind_emit         number(1)
                                          , dm_ind_oper         number(1)
                                          , cod_part            varchar2(60)
                                          , serie               varchar2(3)
                                          , nro_nf              number(30)
                                          , atributo            varchar2(30)
                                          , valor               varchar2(255)
                                          );
   --
   type t_tab_csf_nf_canc_serv_ff is table of tab_csf_nf_canc_serv_ff index by binary_integer;
   vt_tab_csf_nf_canc_serv_ff t_tab_csf_nf_canc_serv_ff;
--
--| Informações de Processos administrativos/Judiciario do REINF relacionado a nota fiscal de Serviço
   type tab_csf_nf_proc_reinf is record ( cpf_cnpj_emit               varchar2(14)
                                        , dm_ind_emit                 number(1)
                                        , dm_ind_oper                 number(1)
                                        , cod_part                    varchar2(60)
                                        , serie                       varchar2(3)
                                        , nro_nf                      number(30)
                                        , dm_tp_proc                  number(1)
                                        , nro_proc                    varchar2(21)
                                        , cod_susp                    number(14)
                                        , dm_ind_proc_ret_adic        varchar2(1)
                                        , valor                       number(14,2)
                                        );
  --
   type t_tab_csf_nf_proc_reinf is table of tab_csf_nf_proc_reinf index by binary_integer;
   vt_tab_csf_nf_proc_reinf t_tab_csf_nf_proc_reinf;
--
-------------------------------------------------------------------------------------------------------

   gv_sql           varchar2(4000) := null;
   gv_where         varchar2(4000) := null;
   gd_dt_ini_integr date := null;
   gv_resumo        log_generico_nf.resumo%type := null;
   gv_cabec_nf      varchar2(4000) := null;

-------------------------------------------------------------------------------------------------------

   gv_aspas                   char(1) := null;
   gv_nome_dblink             empresa.nome_dblink%type := null;
   gv_sist_orig               sist_orig.sigla%type := null;
   gv_owner_obj               empresa.owner_obj%type := null;
   gd_formato_dt_erp          empresa.formato_dt_erp%type := null;
   gv_cd_obj                  obj_integr.cd%type := '7';
   gn_multorg_id              mult_org.id%type;
   gn_empresaintegrbanco_id   empresa_integr_banco.id%type;
   gv_formato_data            param_global_csf.valor%type := null;
   gn_empresa_id              empresa.id%type;
   --
   gv_objeto                  varchar2(300);
   gn_fase                    number;
   --
   info_fechamento number;

-------------------------------------------------------------------------------------------------------

--| Procedimento Gera o Retorno para o ERP
procedure pkb_gera_retorno ( ev_sist_orig in varchar2 default null );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais de Serviços
procedure pkb_integracao ( ev_sist_orig in varchar2 default null );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais de Serviços através do Mult-Org.
--| Esse processo estará sendo executado por JOB SCHEDULER, especifícamente para Ambiente Amazon.
--| A rotina deverá executar o mesmo procedimento da rotina pkb_integracao, porém com a identificação da mult-org.
procedure pkb_integr_multorg ( en_multorg_id in mult_org.id%type );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais de Serviços por empresa e período

procedure pkb_integr_periodo ( en_empresa_id  in  empresa.id%type
                             , ed_dt_ini      in  date
                             , ed_dt_fin      in  date );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração Normal de Notas Fiscais de Serviço recuperando todas as empresas

procedure pkb_integr_periodo_normal ( ed_dt_ini      in  date
                                    , ed_dt_fin      in  date
                                    );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais de Serviço por período

procedure pkb_integr_periodo_geral ( en_multorg_id in mult_org.id%type
                                   , ed_dt_ini     in date
                                   , ed_dt_fin     in date
                                   );

-------------------------------------------------------------------------------------------------------

--| Procedimento que inicia a integração de Notas Fiscais Eletrônicas de Emissão Própria
-- por meio da integração por Bloco
procedure pkb_int_bloco ( en_paramintegrdados_id  in param_integr_dados.id%type
                        , ed_dt_ini               in date default null
			, ed_dt_fin               in date default null
			, en_empresa_id           in empresa.id%type default null
                        );

-------------------------------------------------------------------------------------------------------

end pk_integr_view_nfs;
/
