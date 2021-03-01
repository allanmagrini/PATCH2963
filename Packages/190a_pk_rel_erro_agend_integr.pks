create or replace package csf_own.pk_rel_erro_agend_integr is

------------------------------------------------------------------------------------------
--
--| Especificação da package de relatório de erros do Agendamento de Integração
--
-- Em 17/02/2021   - Wendel Albino - Release 296 e os patchs 2.9.4.5 e 2.9.5.2
-- Redmine #76133  - Geração EFD PIS COFINS
-- Rotina Nova     - pkb_monta_bloco_m_pc - criada rotina nova para o objeto "57- Demais Documentos e Operações - Bloco M EFD Contribuições"
-- Rotina alterada - pkb_geracao --> inclusao do objeto "57"
--
-- Em 19/11/2020   - Wendel Albino - Release 296 e os patchs 2.9.4.5 e 2.9.5.2
-- Redmine #72944  - Falha na exportação .CSV - agendamento de Cadastros Gerais (DECHRA)
-- Rotina alterada - pkb_geracao --> inclusao do alter session set nls_date_format = 'dd/mm/yyyy' E inclsusao de to_char em algumas datas.
--
-- Em 16/09/2020 - Eduardo Linden
-- Redmine #70754 - Troca do campo CNPJ para o registro Y560 - ECF (PL/SQL) 
-- Troca do campo empresa_id_estab para pessoa_id_part na tabela det_exp_com_ig.
-- Rotina alterada - pkb_monta_rel_secf
-- Liberado para Release 295 e os patchs 2.9.4.3 e 2.9.3.6.
--
-- Em 16/09/2020   - Wendel Albino
-- Redmine #71510  - Notas de serviço nao integram
-- Rotina Alterada - pkb_monta_rel_nota_fiscal_efd -> incluido distinct no cursor de log_fiscal para nao trazer repeticoes de erros no mesmo dia.
--
-- Em 03/08/2020   - Wendel Albino
-- Redmine #70117  - Integração blocos X e Y - ECF
-- Rotina Alterada - pkb_monta_rel_secf -> cursor c_log inclusao de distinct para nao repetir descricao
--
-- Em 27/07/2020   - Wendel Albino
-- Redmine #69214  - Erro de validação no F600 sem causa aparente
-- Rotina Alterada - pkb_monta_rel_ddo-> validacao do cabecalho do bloco de log
--
-- Em 14/07/2020   - Wendel Albino
-- Redmine #69487  - Falha na integração NFCe - Todas empresas (VENANCIO)
-- Rotina Alterada - pkb_geracao => incluida a chamada do elsif vv_obj_integr_cd in ('13')-- Notas Fiscais Mercantis NFCe
--                 -  que chama a procedure pkb_monta_rel_nota_fiscal - ja usada pelo vv_obj_integr_cd in ('6')
--
-- Em 10/07/2020   - Wendel Albino
-- Redmine #68800  - Verificar count do Agn. Integr
-- Rotina Alterada - pkb_geracao => incluido procedure PKB_MONTA_REL_IMP_CRED_DCTF que busca erros 
--                 -   de CREDITOS de Impostos no padrão para DCTF no elsif vv_obj_integr_cd in ('46') 
--                 -   "Pagamento e Creditos de Impostos no padrão para DCTF"
--                 - pkb_monta_rel_pgto_imp_ret => alteracao no cursor c_fecha_fiscal, inclusao do valor de referencia "CRED_DCTF"
--
-- Em 17/03/2020   - Karina de Paula
-- Redmine #65984  - falha na geracao de arquivo csv
-- Rotina Alterada - pkb_geracao => Incluída o retorno do campo dt_termino
--                 - pkb_monta_rel_manad => o campo da estava trocado no type das datas ed_dt_ini_integr e ed_dt_fin_integr
--                 - Alterada as entradas incluindo novo parâmetro ed_dt_termino
--                 - Alterados todos os selects incluindo a ed_dt_termino
-- Liberado na Release_2.9.3.9, Patch_2.9.2.3 e Patch_2.9.1.6
--
-- Em 23/01/2020   - Karina de Paula
-- Redmine #62025  - Criar processo de integração de parametros ECF
-- Rotina Alterada - pkb_monta_rel_secf Incluído o objeto de integração CONF_DP_TB_ECF
--
-- Em 04/12/2012 - Angela Inês.
-- Ficha HD 63615 - Processo Ecredac.
--
-- Em 27/12/2012 - Angela Inês.
-- Ficha HD 65154 - Fechamento Fiscal por empresa.
-- Nas integrações em bloco, buscar nos "OBJ_INTEGR" os que estiverem ativos (coluna obj_integr.dm_tipo eliminada), considerar somente do tipo "Normal").
-- Considerar os objetos de integração com um único código e não verificar mais o dm_tipo, pois este estará no agendamento.
--
-- Em 17/04/2013 - Marcelo Ono
-- Ficha HD 64646 - Criado processo para geração dos logs na tabela (IMP_ERRO_AGEND_INTEGR), referente a integração do inventário.
--
-- Em 10/05/2013 - Angela Inês.
-- Ficha HD 66676 - Log de integração do cadastro de Plano de Contas.
-- Rotina: pkb_monta_rel_cad_geral.
--
-- Em 14/05/2013 - Angela Inês.
-- Ficha HD 66674 - Integração do Layout do Movimento Contábil com tipo de integração Integrador CSF e em Bloco.
-- Rotina: pkb_monta_rel_dados_contab.
--
-- Em 12/07/2013 - angela Inês.
-- Inclusão dos logs de Bens do Ativo Imobilizado que não geraram o Bem, somente o Log.
-- Rotina: pkb_monta_rel_cad_geral.
--
-- Em 13/08/2013 - Rogério Silva
-- Inclusão da geração de relatório de erro para:
--   Produção Diária de Usina,
--      Informações de Valores Agregados,
--      Controle de Creditos Fiscais de ICMS,
--      Informações da DIRF e
--      Total de operações com cartão.
-- Atividade Melhoria #538 redmine
--
-- Em 15/08/2013 - Rogério Silva
-- Inclusão da geração de relatório de erro do MANAD
-- Atividade Melhoria #538 redmine
--
-- Em 19/03/2014 - Angela Inês.
-- Redmine #2048 - Relatório de logs/inconsistências - Controle da Produção e do Estoque.
--
-- Em 24/02/2015 - Rogério Silva.
-- Redmine #6314 - Analisar os processos na qual a tabela UNIDADE é utilizada.
-- Rotinas: pkb_monta_rel_cad_geral e pkb_geracao
--
-- Em 11/06/2015 - Rogério Silva
-- Redmine #8257 - Package de Geração de Erros do Agendamento de Integração
--
-- Em 04/08/2015 - Angela Inês.
-- Redmine #10117 - Escrituração de documentos fiscais - Processos.
-- Inclusão do novo conceito de recuperação de data dos documentos fiscais para retorno dos registros.
--
-- Em 12/11/2015 - Rogério Silva
-- Redmine #12859 - Alterar procedimento de geração de relatório de erros.
--
-- Em 18/11/2015 - Leandro Savenhago
-- Redmine #12993 - ERRO NA EXPORTAÇÃO DO XLS OU PDF
--
-- Em 03/02/2016 - Fábio Tavares
-- Redmine #13042 - Objetos de Integração não estão sendo montados corretos.
--
-- Em 24/02/2016 - Rogério Silva
-- Redmine #15755 - Os logs de erros para pagamentos e recebimentos de impostos retidos não estão sendo gerados.
--
-- Em 15/03/2016 - Rogério Silva
-- Redmine #15937 - Não está integrando dados de trabalhador e nao dá erro
--
-- Em 17/03/2016 - Rogério Silva
-- Redmine #15981 -  erro na tela ao tentar exportar PDF do agendamento de integração
--
-- Em 29/03/2016 - Angela Inês.
-- Redmine #16974 - Apresentação do Log - Integração de Impostos Retidos.
-- A mensagem de log não está sendo reportada no relatório de erros (log_generico_pir), quando o registro não foi integração, ou seja, o registro ainda permanece
-- na view de integração.
-- Rotinas: pkb_monta_rel_imp_ret_rec_pc e pkb_monta_rel_pgto_imp_ret.
--
-- Em 06/05/2016 - Angela Inês.
-- Redmine #18567 - Correção na recuperação dos logs de Integração Contábil.
-- Alterar o processo de leitura dos logs do agendamento de Dados Contábeis, considerando os detalhes de lançamentos de saldo e os lançamentos de partida.
-- Através desses registros, recuperar os logs gerados no agendamento da integração.
-- Rotina: pkb_monta_rel_dados_contab.
--
-- Em 22/08/2016 - Angela Inês.
-- Redmine #22630 - Correção no processo de Integração - Blocos F - EFD-Contribuições.
-- Incluir a geração dos Logs dos Blocos F - Demais Documentos e Operações - Bloco F EFD Contribuições.
-- Rotina: pkb_monta_rel_ddo.
--
-- Em 30/09/2016 - Fábio Tavares
-- Redmine #23503 - Melhoria nos processos de geração de relatório alterando para apenas mostrar
-- os titulos apenas quando houver registros de cada objeto, caso contrario não será gerado nada.
--
-- Em 07/02/2017 - Fábio Tavares
-- Redmine #28098 - defeito geracao de relatorio de erro do agendamento de integracao
-- Rotina: pkb_monta_rel_ddo.
--
-- Em 09/03/2017 - Fábio Tavares
-- Redmine #28678 - Erro ao gerar PDF de erros de cadastros Gerais (Alta Genetics)
--
-- Em 05/06/2017 - Fábio Tavares
-- Redmine #31536 - Implementação da recuperação dos logs genericos do processo de integração de ECF.
-- Rotina: pkb_monta_tel_secf.
--
-- Em 07/06/2017 - Marcos Garcia
-- Redmine #30475 - Processos de Integração e Relatórios de Inconsistências - Processo de Fechamento Fiscal.
--
-- Em 28/06/2017 - Fábio Tavares
-- Redmine #32386 - Ajuste no Relatório de Erro do Agendamento de Integração para a DIPAM
-- Rotina: pkb_monta_rel_cad_geral.
--
-- Em 19/07/2017 - Marcos Garcia
-- Redmine #30475 - Avaliações nos Processos de Integração e Relatórios de Inconsistências - Processo de Fechamento Fiscal.
-- Criação da variavel global para armazenar o identificador do fechamento fiscal(Id da tabela csf_tipo_log)
-- Dentro do corpo foi criada a rotina que alimenta a mesma. pkb_incia_fecha_fiscal.
--
-- Em 24/08/2017 - Fábio Tavares
-- Redmine #33863 - Integração de Cadastros para o Sped Reinf - Erro de Agendamento
-- Rotina: pkb_monta_rel_cad_geral.
--
-- Em 10/10/2017 - Fábio Tavares
-- Redmine #33858 - Rel. Integração de dados do Sped Reinf - Erro de Agendamento
-- Rotina: pkb_monta_rel_reinf.
--
-- Em 08/06/2018 - Karina de Paula
-- Redmine #43781 - Falha ao exportar .csv/.pdf - Agendamento Integraçao (SANTA VITORIA)
-- Rotina Alterada: pkb_monta_rel_nota_fiscal - incluído modelo 57 no select q retorna as nfs
--
-- Em 15/08/2018 - Karina de Paula
-- Redmine #46018 - Erro de Integração - Logs
-- Rotina Alterada: pkb_monta_rel_infoexp - Alterada tabela log_generico para log_generico_ie
--
-- Em 08/10/2018 - Karina de Paula
-- Rotina Alterada: pkb_monta_rel_conhec_transp => Alterado o select principal para trazer tb dados de CT Legado
--
-- Em 17/12/2018 - Karina de Paula
-- Redmine #49684 - Erro ao exportar relatório de integração
-- Rotina Alterada: pkb_monta_rel_cad_geral => Alterados os selects dos cursores: c_item; c_log_item; c_pc; c_log_pc; c_hist
-- Foi alterado para melhoria de performance
--
-- Em 15/01/2019 - Eduardo Linden
-- Redmine #49826 - Processos de Integração e Validação do Controle de Produção e Estoque - Bloco K.
-- Rotina alterada: pkb_monta_rel_contr_prod_estq => Inclusão das novas tabelas relacionadas aos registros K no cursor c_fecha_fiscal.
--
-- Em 04/03/2019 - Karina de Paula
-- Redmine #49807 - LOG DE ERRO CIAP
-- Rotina Alterada: Foi incluído o parâmetro de entrada da data do agendamento (dt_agend) nas procedures internas q não tinham;
--                  Esse parâmetro de data foi incluído nos selects que não possuem o referencia_id para não trazer logs de erros
--                  de fechamento que não corresponde ao agendamento que está sendo executado;
--                  Foi alterado as cláusulas where que estavam comparando a variável ev_info_fechamento com o CD e não o ID do tipo de fechamento.
--
-- Em 07/03/2019 - Eduardo Linden
-- Redmine #52186 - Atualizar registro I200 - SPED Contabil
-- Rotina Alterada: pkb_monta_rel_dados_contab => Inclusão do  int_lcto_contabil.dt_lcto_ext no cursor c_lcto. Inclusão do mesmo para as chamadas das rotinas pkb_armaz_imprerroagendintegr.
--
-------------------------------------------------------------------------------------------------------------------------------

-- Constantes

   CR  CONSTANT VARCHAR2(4000) := CHR(13);
   LF  CONSTANT VARCHAR2(4000) := CHR(10);
   FINAL_DE_LINHA CONSTANT VARCHAR2(4000) := CR || LF;

-- Variaveis

   INFO_FECHAMENTO number;

-------------------------------------------------------------------------------------------------------

   type t_impr_erro_agend_integr is table of impr_erro_agend_integr%rowtype index by binary_integer;
   vt_impr_erro_agend_integr t_impr_erro_agend_integr;

------------------------------------------------------------------------------------------

--| Procedimento de inicio da geração do relatório de erros

procedure pkb_geracao ( en_agendintegr_id  in agend_integr.id%type
                      , en_objintegr_id    in obj_integr.id%type
                      , en_usuario_id      in neo_usuario.id%type
                      );

------------------------------------------------------------------------------------------

end pk_rel_erro_agend_integr;
/
