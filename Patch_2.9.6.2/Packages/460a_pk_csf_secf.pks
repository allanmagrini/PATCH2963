create or replace package csf_own.pk_csf_secf is

-------------------------------------------------------------------------------------------------------
-- Especifica��o do pacote de fun��es para o Sped ECF
--
-- Em 02/02/2021  - Luis Marques - 2.9.6-2 / 2.9.7
-- Redmine #75361 - Desenvolver estrutura para calculo do lucro da explora��o
-- Nova Fun��o    - fkg_ver_erro_log_generico_ecf - Verifica se existe erro no log generico do ECF para
--                  Lucro Explora��o.
--
-- Em 23/09/2020  - Luis Marques - 2.9.5
-- Redmine #66363 - Desenvolver registro Derex
-- Nova Fun��o    - fkg_tipo_moeda_id_valido - Fun��o verifica se a moeda para o tipo de tabela 
--                  (DM_TAB_MOEDA)-(0-Bacen/1-CBC) � valida.
--
-- Em 16/09/2020 - Eduardo Linden
-- Redmine #70754 - Troca do campo CNPJ para o registro Y560 - ECF (PL/SQL)
-- Troca do parametro en_empresa_id_estab para en_pessoa_id_part, como a troca da chave (PK).
-- Rotina alterada: fkg_detexpcomig_id
-- Liberado para Release 295 e os patchs 2.9.4.3 e 2.9.3.6.
--
-- Em 14/08/2020  - Igor/Armando
-- Redmine #69546 - Bloco M n�o considerando todos Centro de Custos
-- Rotina Alterada- fkg_demdifadiniig_id/fkg_ccr_lanc_part_id-> criacao parametro en_centrocusto_id.
--
-- Em 09/06/2020 - Eduardo Linden
-- Redmine #68446 - Tratar exception da fkg_tabdinecf_id
-- Inclus�o de clausula dt_fin is null
-- Rotina alterada: fkg_tabdinecf_id
-- Liberado na vers�o - Release 2.9.4 e patchs 2.9.3.3 e 2.9.2.6
--
-- Em 30/04/2020 - Eduardo Linden
-- Redmine #66921 - Gerar calculo do registro Y540 - SPED ECF (PL/SQL)
-- Fun��o retorna se cfop gera receita ou nao
-- Rotina criada: fkg_cfop_gera_rec
-- Liberado na vers�o - Release 2.9.4 e patchs 2.9.3.2 e 2.9.2.5
--
-- Em 10/02/2020 - Eduardo Linden
-- Redmine #64229 - Corre��o dos pontos discutidos para integra��o M300/350
-- Fun��o retorna o ID da tabela lanc_part_a_lalur conforme chave �nica
-- Rotina criada: fkg_lancpartalalur_id
-- Fun��o retorna o ID da tabela lanc_part_a_lacs conforme chave �nica
-- Rotina criada: fkg_lancpartalacs_id
-- Fun��o retorna o ID da tabela ccr_lanc_part_a_lalur conforme chave �nica
-- Rotina criada: fkg_ccrlancpartalalur_id
-- Fun��o retorna o ID da tabela ccr_lanc_part_a_lacs conforme chave �nica
-- Rotina criada: fkg_ccrlancpartalacs_id
-- Fun��o retorna o ID da tabela conta_part_b_lalur conforme chave �nica
-- Rotina criada: fkg_contapartblalur_id
-- Fun��o retorna o ID da tabela conta_part_b_lacs conforme chave �nica
-- Rotina criada: fkg_contapartblacs_id
-- Liberado na vers�o - Release_2.9.3, Patch_2.9.2.2 e Patch_2.9.1.5
--
-- Em 10/01/2020 - Eduardo Linden
-- Redmine #62823 - Desenvolvimento de integra��o para as tabelas definitivas - M300 e M350
-- Criada nova fun��o para localizar Id da tabela Abertura_Ecf.
-- Rotina Criada: fkg_busca_aberturaecf_id 
-- Criada nova function retorna id da tabela per_apur_lr atrav�s do id da tabela abertura_ecf e as datas de inicio e fim.
-- Rotina Criada: fkg_busca_perapurlr_id
--
-- === AS ALTERA��ES ABAIXO EST�O NA ORDEM CRESCENTE USADA ANTERIORMENTE ============================ --
--
-- Em 29/04/2016 - F�bio Tavares
-- Redmine #10831 - Fun��o que retorna o ID da Opera��es com o Exterior - Pessoa Vinculada
--
-- Em 02/05/2016 - F�bio Tavares
-- Redmine #11080 - Fun��o que retorna o ID da Opera��es com o Exterior - Pessoas N�o Vinculada.
--
-- Em 05/05/2016 - F�bio Tavares
-- Redmine #11128 - Fun��o que retorna o ID da Opera��es com o Exterior - Exporta��es (Entradas de Divisas)    
--
-- Em 24/05/2017 - F�bio Tavares
-- Redmine #30937 - Cria��o de Integra��o Table/view e Bloco dos registros do ECF
--
-- Em 27/09/2017 - F�bio Tavares
-- Redmine #34949 - Erro 3 ainda continua.
--
-- Em 21/11/2018 - Marcos Ferreira
-- Redmine #48912 - Tratamento Fun��o - pk_csf_secf.fkg_tabdinecf_id
-- Solicita��o: Melhorias na fun��o de retorno do Id da tabela din�mica
-- Altera��es: Considerar a busca de dados sem a utiliza��o do par�metro en_codentref_id, pois n�o est� sendo utilizado nos clientes
-- Procedures Alteradas: fkg_tabdinecf_id
--
-- Em 18/04/2019 - Eduardo Linden
-- Redmine #53486 - Altera��o registro M010
-- Cria��o de nova function para retorno do c�digo da tabela padr�o da Parte B.
-- Nova function: fkg_tabpdrrfb_id
--
-- Em 22/04/2018 - Eduardo Linden
-- Redmine #53500 - Altera��o registro X357
-- Fun��o que retorna o c�digo da tabela invest_diretas_ie
-- Nova function: fkg_investdiretasie_id
--
-------------------------------------------------------------------------------------------------------
-- Retorna a sigla do pais conforme o codigo informado do identificador
function fkg_pais_id_sigla_pais ( en_pais_id in pais.id%type
                                ) return pais.sigla_pais%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Identifica��o de S�cios ou Titular Y600
function fkg_identsocioig_id ( en_empresa_id          in empresa.id%type
                             , en_pessoa_id           in pessoa.id%type
                             , ed_dt_alt_soc          in ident_socio_ig.dt_alt_soc%type
                             , ev_dm_ind_qualif_socio in ident_socio_ig.dm_ind_qualif_socio%type
                             , en_pessoa_id_rptl      in ident_socio_ig.pessoa_id_rptl%type
                             ) return ident_socio_ig.id%type;
-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Demonstrativo do Livro Caixa - Q100
function fkg_demlivrocaixa_id ( en_empresa_id in abertura_ecf.id%type
                              , ed_dt_demon   in dem_livro_caixa.dt_demon%type
                              ) return dem_livro_caixa.id%type;
-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Informa��es de Optantes pelo Refis � Imunes ou Isentas Y682
function fkg_infooptrefisiiig_id ( en_aberturaecf_id in abertura_ecf.id%type
                                 , ev_dm_mes         in info_opt_refis_ii_ig.dm_mes%type
                                 ) return info_opt_refis_ii_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Informa��es de Optantes pelo PAES Y690
function pkb_infooptpaesig_id ( en_aberturaecf_id in abertura_ecf.id%type
                              , ev_dm_mes         in info_opt_paes_ig.dm_mes%type
                              ) return info_opt_paes_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Informa��es de Per�odos Anteriore - Y720
function fkg_infperantig_id ( en_empresa_id in empresa.id%type
                            , en_ano_ref    in inf_per_ant_ig.ano_ref%Type
                            ) return inf_per_ant_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Demonstrativo das Diferen�as na Ado��o Inicial Y665
function fkg_detinfooptrefislrapig_id ( en_infooptrefislrapig_id in info_opt_refis_lrap_ig.id%type
                                      , en_tabdinecf_id          in tab_din_ecf.id%type
                                      ) return det_info_opt_refis_lrap_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Demonstrativo das Diferen�as na Ado��o Inicial Y665
function fkg_demdifadiniig_id ( en_empresa_id     in empresa.id%type
                              , en_ano_ref        in dem_dif_ad_ini_ig.ano_ref%type
                              , en_planoconta_id  in plano_conta.id%type
                              , en_centrocusto_id in centro_custo.id%type --#69546
                              ) return dem_dif_ad_ini_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Detalhamento de Participa��es em Cons�rcios de Empresas Y650
function fkg_detpartconsemprig_id ( en_partconsemprig_id in part_cons_empr_ig.id%type
                                  , en_pessoa_id         in pessoa.id%type
                                  ) return det_part_cons_empr_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Participa��es em Cons�rcios de Empresas Y640
function fkg_partconsemprig_id ( en_empresa_id in empresa.id%type
                               , en_ano_ref    in part_cons_empr_ig.ano_ref%type
                               , en_pessoa_id  in pessoa.id%type
                               ) return part_cons_empr_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retornar o c�digo da tabela de Outras Informa��es (Lucro Presumido ou Lucro Arbitrado) Y672
function fkg_outrainflplaig_id ( en_empresa_id in empresa.id%type
                               , en_ano_ref    in outra_inf_lp_la_ig.ano_ref%type
                               ) return outra_inf_lp_la_ig.id%type;
-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Outras Informa��es (Lucro Real) Y671
function fkg_outrainflrig_id ( en_empresa_id in empresa.id%type
                             , en_ano_ref    in outra_inf_lr_ig.ano_ref%type
                             ) return outra_inf_lr_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Dados de Sucessoras Y660
function fkg_dadosucessoraig_id( en_empresa_id in empresa.id%type
                               , en_ano_ref    in dado_sucessora_ig.ano_ref%type
                               , en_pessoa_id  in pessoa.id%type
                               ) return dado_sucessora_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Fundos/Clubes de Investimento Y630
function fkg_fundoinvestig_id ( en_empresa_id in empresa.id%type                     
                              , en_ano_ref    in fundo_invest_ig.ano_ref%type
                              , en_pessoa_id  in pessoa.id%type
                              ) return fundo_invest_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Participa��es Avaliadas Pelo M�todo de Equival�ncia Patrimonial Y620
function fkb_partavameteqpatrig_id ( en_empresa_id   in empresa.id%type
                                   , en_ano_ref      in part_ava_met_eq_patr_ig.ano_ref%type
                                   , en_pessoa_id    in pessoa.id%type
                                   , ed_dt_evento    in part_ava_met_eq_patr_ig.dt_evento%type
                                   , en_dm_ind_relac in part_ava_met_eq_patr_ig.dm_ind_relac%type
                                   ) return part_ava_met_eq_patr_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Rendimentos de Dirigentes e Conselheiros � Imunes ou Isentas Y612
function fkg_renddirigiiig_id ( en_empresa_id in empresa.id%type
                              , en_ano_ref    in rend_dirig_ii_ig.ano_ref%type
                              , en_pessoa_id  in rend_dirig_ii_ig.pessoa_id%type
                              , ev_dm_qualif  in rend_dirig_ii_ig.dm_qualif%type
                              ) return rend_dirig_ii_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Ativos no Exterior Y590
function fkg_ativoexteriorig_id( en_empresa_id      in empresa.id%type
                               , en_ano_ref         in ativo_exterior_ig.ano_ref%type
                               , en_tipoativoecf_id in ativo_exterior_ig.tipoativoecf_id%type
                               , ev_discrim         in ativo_exterior_ig.discrim%type
                               ) return ativo_exterior_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Doa��es a Campanhas Eleitorais Y580
function fkg_doaccampeleitig_id ( en_empresa_id in empresa.id%type
                                , en_ano_ref    in dem_ir_csll_rf_ig.ano_ref%type
                                , en_pessoa_id  in pessoa.id%type 
                                ) return doac_camp_eleit_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Demonstrativo do Imposto de Renda e CSLL Retidos na Fonte Y570
function fkg_demircsllrfig_id ( en_empresa_id    in empresa.id%type
                              , en_ano_ref       in dem_ir_csll_rf_ig.ano_ref%type
                              , en_pessoa_id     in pessoa.id%type
                              , en_tiporetimp_id in tipo_ret_imp.id%type
                              ) return dem_ir_csll_rf_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela de Detalhamento das Exporta��es da Comercial Exportadora Y560
function fkg_detexpcomig_id ( en_empresa_id       in empresa.id%TYPE
                            , en_ano_ref          in det_exp_com_ig.ano_ref%type
                            /*, en_empresa_id_estab in empresa.id%TYPE*/
                            , en_pessoa_id_part   in det_exp_com_ig.pessoa_id_part%type
                            , en_ncm_id           in ncm.id%type
                            ) return det_exp_com_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela Vendas a Comercial Exportadora com Fim Espec�fico de Exporta��o Y550
function fkg_vendcomfimexpig_id ( en_empresa_id in empresa.id%TYPE
                                , en_ano_ref    in vend_com_fim_exp_ig.ano_ref%type
                                , en_pessoa_id  in pessoa.id%type
                                , en_ncm_id     in ncm.id%type
                                ) return vend_com_fim_exp_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Retorna o c�digo da tabela Discr. da Receita de Vendas dos Estab. por Ativ. Econ�mica Y540
function fkg_descrrecestabcnaeig_id ( en_empresa_id       in empresa.id%TYPE
                                    , en_ano_ref          in descr_rec_estab_cnae_ig.ano_ref%type
                                    , en_empresa_id_estab in empresa.id%TYPE
                                    , en_cnae_id          in cnae.id%type
                                    ) return descr_rec_estab_cnae_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela de Pagamentos/Recebimentos do Exterior ou de N�o Residentes Y520
function fkg_prextnresidig_id ( en_empresa_id    in empresa.id%TYPE
                              , en_ano_ref       in pr_ext_nresid_ig.ano_ref%TYPE
                              , en_pais_id       in pais.id%TYPE
                              , ev_dm_tip_ext    in pr_ext_nresid_ig.dm_tip_ext%TYPE
                              , en_dm_forma      in pr_ext_nresid_ig.dm_forma%TYPE
                              , en_natoperecf_id in nat_oper_ecf.id%TYPE
                              ) return pr_ext_nresid_ig.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela de �reas de Livre Com�rcio (ALC) (ZPE) X510
function fkg_arealivrecomie_id ( en_aberturaecf_id  in abertura_ecf.id%type
                               , en_tabdinecf_id    in tab_din_ecf.id%type
                               ) return area_livre_com_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela de Zonas de Processamento de Exporta��o (ZPE) X500
function fkg_zonaprocexpie_id ( en_aberturaecf_id in abertura_ecf.id%type
                              , en_tabdinecf_id   in tab_din_ecf.id%type
                              ) return zona_proc_exp_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela de P�lo Industrial de Manaus e Amaz�nia Ocidental X490
function fkg_pimanausamazocidie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                   , en_tabdinecf_id   in tab_din_ecf.id%type
                                   ) return pi_manaus_amaz_ocid_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela do Bloco X480
function fkg_infoextservie_id ( en_aberturaecf_id in abertura_ecf.id%type
                              , en_tabdinecf_id   in tab_din_ecf.id%type
                              ) return info_ext_serv_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela de Capacita��o de Inform�tica e Inclus�o Digital X470
function fkg_capinfincldigie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                , en_tabdinecf_id   in tab_din_ecf.id%type 
                                ) return cap_inf_incl_dig_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela de Inova��o Tecnol�gica e Desenvolvimento Tecnol�gico X460
function fkg_inovtecdesenvie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                , en_tabdinecf_id   in tab_din_ecf.id%type 
                                ) return inov_tec_desenv_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela de Pagamentos/Remessas Relat. a Servi�os, Juros e Divid. Recebidos do Brasil e do Exterior X450
function fkg_pagrelextie_id ( en_empresa_id in empresa.id%type
                            , en_ano_ref    in pag_rel_ext_ie.ano_ref%type
                            , en_pais_id    in pais.id%type
                            ) return pag_rel_ext_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela de Rend. Relat. a Serv., Juros e Divid. Receb. do Brasil e do Ext. X430
function fkg_rendrelrecebie_id ( en_empresa_id in empresa.id%type
                               , en_ano_ref    in rend_rel_receb_ie.ano_ref%type
                               , en_pais_id    in pais.id%type
                               ) return rend_rel_receb_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela de Royalties Rec. ou Pagos a Benef. do Brasil e do Ext. X420
function fkg_royrpbenfie_id ( en_empresa_id in empresa.id%type
                            , en_ano_ref    in roy_rp_benf_ie.ano_ref%type
                            , en_pais_id    in pais.id%type
                            , ev_dm_tip_roy in roy_rp_benf_ie.dm_tip_roy%type
                            ) return roy_rp_benf_ie.id%type;
                            
-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela Origem e Aplica��o de Recursos, Imunes e Isentas X390
function fkg_oraplreciiie_id ( en_aberturaecf_id in abertura_ecf.id%type
                             , en_tabdinecf_id   in tab_din_ecf.id%type
                             ) return or_apl_rec_ii_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela Com�rcio Eletr�nico � Informa��o de Homepage/Servidor
function fkg_comeletinfie_id ( en_empresa_id   in empresa.id%type
                             , en_ano_ref      in com_elet_inf_ie.ano_ref%type
                             , en_pais_id      in pais.id%type
                             ) return com_elet_inf_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela com_ele_ti_inf_vend_ie
function fkg_comeletiinfvendie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                  , en_tabdinecf_id   in tab_din_ecf.id%type
                                  ) return com_ele_ti_inf_vend_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela dem_prej_acm_ext_contr_ie
function fkg_demprejacmextcontrie_id ( en_identpartextie_id in ident_part_ext_ie.id%type
                                     ) return dem_prej_acm_ext_contr_ie.id%type;
-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela invest_diretas_ie
function fkg_investdiretasie_id ( en_identpartextie_id invest_diretas_ie.identpartextie_id%type,
                                  en_pais_id           invest_diretas_ie.pais_id%type,
                                  ev_nif_cnpj          invest_diretas_ie.nif_cnpj%type
                                  ) return invest_diretas_ie.id%type;   
-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela dem_estr_soc_ext_contr_ie
function fkg_demestrsocextcontrie_id ( en_identpartextie_id in ident_part_ext_ie.id%type
                                     ) return dem_estr_soc_ext_contr_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela DEM_REND_AP_EXT_CONTR_IE
function fkg_demrendapextcontrie_id ( en_identpartextie_id  in ident_part_ext_ie.id%type
                                    ) return DEM_REND_AP_EXT_CONTR_IE.id%type;
                                    
-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela dem_cons_ext_contr_ie
function fkg_demconsextcontrie_id ( en_identpartextie_id in ident_part_ext_ie.id%type
                                  ) return dem_cons_ext_contr_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela dem_res_ext_auf_col_rc_ie
function fkg_demresextaufcolrcie_id ( en_identpartextie_id  in ident_part_ext_ie.id%type
                                    ) return dem_res_ext_auf_col_rc_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela dem_resul_imp_ext_ie
function fkg_demresulimpextie_id ( en_identpartextie_id  in ident_part_ext_ie.id%type
                                 ) return dem_resul_imp_ext_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o c�digo da tabela part_ext_resul_apur_ie
function fkg_partextresulapurie_id ( en_identpartextie_id  in ident_part_ext_ie.id%type
                                   ) return part_ext_resul_apur_ie.id%type;

-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o C�digo da tabela ident_part_ext_ie

function fkg_identpartextie_id ( en_empresa_id  in ident_part_ext_ie.empresa_id%type 
                               , en_ano_ref     in ident_part_ext_ie.ano_ref%type    
                               , en_pessoa_id   in ident_part_ext_ie.pessoa_id%type  
                               , ev_nif         in ident_part_ext_ie.nif%type
                               ) return ident_part_ext_ie.id%type;


-------------------------------------------------------------------------------------------------------
-- Fun��o que retorna o ID da tabela oper_ext_contr_exp_ie

function fkg_operextcontrimpie_id ( en_operextimportacaoie_id   in oper_ext_importacao_ie.id%type
                                  , en_pessoa_id                in pessoa.id%type
                                  ) return oper_ext_contr_imp_ie.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que retorna o ID da tabela oper_ext_importacao_ie

function fkg_operextimportacaoie_id ( en_empresa_id              in empresa.id%type
                                    , en_ano_ref                 in oper_ext_importacao_ie.ano_ref%type
                                    , ev_num_ordem               in oper_ext_importacao_ie.num_ordem%type
                                    ) return oper_ext_importacao_ie.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que retorna o ID da tabela oper_ext_contr_exp_ie

function fkg_operextcontrexpie_id ( en_operextexportacaoie_id   in oper_ext_exportacao_ie.id%type
                                  , en_pessoa_id                in pessoa.id%type
                                  ) return oper_ext_contr_exp_ie.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que retorna o ID da tabela OPER_EXT_EXPORTACAO_IE

function fkg_operextexportacaoie_id ( en_empresa_id        in  empresa.id%type
                                    , en_ano_ref           in  oper_ext_exportacao_ie.ano_ref%type
                                    , ev_num_ordem         in  oper_ext_exportacao_ie.num_ordem%type
                                    ) return oper_ext_exportacao_ie.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que retorna o ID da tabela OPER_EXT_PESSOA_NVINC_IE

function fkg_operextpessoanvincie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                     , en_tabdinecf_id   in tab_din_ecf.id%type
                                     ) return oper_ext_pessoa_nvinc_ie.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que retorna o ID da tabela OPER_EXT_PESSOA_VINC_IE

function fkg_operextpessoavincie_id ( en_aberturaecf_id in abertura_ecf.id%type
                                    , en_tabdinecf_id in tab_din_ecf.id%type
                                    ) return oper_ext_pessoa_vinc_ie.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo da Vers�o Leiaute do Sped ECF

function fkg_cd_versaolayoutecf_id ( en_versaolayoutecf_id in versao_layout_ecf.id%type )
         return versao_layout_ecf.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna a "Vers�o" Leiaute do Sped ECF

function fkg_versao_versaolayoutecf_id ( en_versaolayoutecf_id in versao_layout_ecf.id%type )
         return versao_layout_ecf.versao%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da Vers�o Leiaute do Sped ECF conforme o C�digo

function fkg_id_versaolayoutecf_cd ( ev_versaolayoutecf_cd in versao_layout_ecf.cd%type )
         return versao_layout_ecf.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da Vers�o Leiaute do Sped ECF conforme o periodo

function fkg_id_versaolayoutecf_dt ( ed_dt_ini in date
                                   , ed_dt_fin in date 
                                   )
         return versao_layout_ecf.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o CD da Vers�o Leiaute do Sped ECF conforme o periodo

function fkg_cd_versaolayoutecf_dt ( ed_dt_ini in date
                                   , ed_dt_fin in date 
                                   )
         return versao_layout_ecf.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo da Natureza Juridica conforme ID

function fkg_cd_naturjurid_id ( en_naturjurid_id in natur_jurid.id%type )
         return natur_jurid.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da Natureza Juridica conforme o C�digo

function fkg_id_naturjurid_cd ( en_naturjurid_cd in natur_jurid.cd%type )
         return natur_jurid.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID Registro do SPED ECF conforme o C�digo

function fkg_id_registroecf_cod ( ev_registroecf_cod in registro_ecf.cod%TYPE )
         return registro_ecf.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo do Registro do SPED ECF conforme ID

function fkg_cod_registroecf_id ( en_registroecf_id in registro_ecf.id%TYPE )
         return registro_ecf.cod%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo + Descri��o do Registro do SPED ECF conforme ID

function fkg_texto_registroecf_id ( en_registroecf_id in registro_ecf.id%TYPE )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorno os dados da Tabela Dinamica do ECF conforme ID do registro

function fkg_tabdinecf_row ( en_tabdinecf_id in tab_din_ecf.id%type )
         return tab_din_ecf%rowtype;

-------------------------------------------------------------------------------------------------------
-- Fun��o de retorno do c�digo da Tabela Padr�o RFB -  Parte B

function fkg_tabpdrrfb_id( en_tabpdrrfb_id in tab_pb_rfb_part_b.id%type)
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorno os dados da "Configura��o do DE-PARA Tabela Dinamica do Sped ECF" (CONF_DP_TB_ECF) conforme ID do registro

function fkg_confdptbecf_id ( en_confdptbecf_id in conf_dp_tb_ecf.id%type )
         return conf_dp_tb_ecf%rowtype;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorno a descri��o da "Configura��o do DE-PARA Tabela Dinamica do Sped ECF" (CONF_DP_TB_ECF) conforme ID do registro

function fkg_texto_confdptbecf_id ( en_confdptbecf_id in conf_dp_tb_ecf.id%type )
         return varchar2;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID "Codigo de CNC" do SPED ECF conforme o C�digo

function fkg_id_codcnc_cd ( en_codcnc_cd in cod_cnc.cd%TYPE )
         return cod_cnc.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo do "Codigo de CNC" do SPED ECF conforme ID

function fkg_cd_codcnc_id ( en_codcnc_id in cod_cnc.id%TYPE )
         return cod_cnc.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID "Tipo Moeda" do SPED ECF conforme o C�digo

function fkg_id_tipomoeda_cd ( ev_tipomoeda_cd in tipo_moeda.cd%TYPE )
         return tipo_moeda.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo do "Codigo de CNC" do SPED ECF conforme ID

function fkg_cd_tipomoeda_id ( en_tipomoeda_id in tipo_moeda.id%TYPE )
         return tipo_moeda.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID "Natureza de Opera��o" do SPED ECF conforme o C�digo

function fkg_id_natoperecf_cd ( en_natoperecf_cd in nat_oper_ecf.cd%TYPE )
         return nat_oper_ecf.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo do "Natureza de Opera��o" do SPED ECF conforme ID

function fkg_cd_natoperecf_id ( en_natoperecf_id in nat_oper_ecf.id%TYPE )
         return nat_oper_ecf.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID "Tipos de Ativo" do SPED ECF conforme o C�digo

function fkg_id_tipoativoecf_cd ( ev_tipoativoecf_cd in tipo_ativo_ecf.cd%TYPE )
         return tipo_ativo_ecf.id%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o C�digo do "Tipos de Ativo" do SPED ECF conforme ID

function fkg_cd_tipoativoecf_id ( en_tipoativoecf_id in tipo_ativo_ecf.id%TYPE )
         return tipo_ativo_ecf.cd%TYPE;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna os dados da "Abertura" do SPED ECF conforme ID

function fkg_aberturaecf_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abertura_ecf%rowtype;

-------------------------------------------------------------------------------------------------------
-- Fun��o para localizar Id da tabela Abertura_Ecf.

function fkg_busca_aberturaecf_id ( en_empresa_id abertura_ecf.empresa_id%type
                               , ed_dt_ini     abertura_ecf.dt_ini%type
                               , ed_dt_fin     abertura_ecf.dt_fin%type)
                               return abertura_ecf.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna os dados da "Abertura - Parametros Tributaveis" do SPED ECF conforme ID

function fkg_abertecfparamtrib_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abert_ecf_param_trib%rowtype;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna os dados da "Abertura - Parametros Complementares" do SPED ECF conforme ID

function fkg_abertecfparamcompl_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abert_ecf_param_compl%rowtype;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna os dados da "Abertura - Parametros Gerais" do SPED ECF conforme ID

function fkg_abertecfparamgeral_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abert_ecf_param_geral%rowtype;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna os dados da Abertura - Par�metros de Identifica��o dos Tipos de Programa

function fkg_abertecfparidenttpprog_id ( en_aberturaecf_id in abertura_ecf.id%type )
                                       return abert_ecf_param_ident_tp_prog%rowtype;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna os dados da "Abertura - Parametros Dados Empresa" do SPED ECF conforme ID

function fkg_abertecfdados_id ( en_aberturaecf_id in abertura_ecf.id%TYPE )
         return abert_ecf_dados%rowtype;

-------------------------------------------------------------------------------------------------------

-- Fun��o recupera o C�digo de Identifica��o do registro com base no C�digo da Jurisdicao do Sped ECF

function fkg_jurisdicaosecf_id ( ev_jurisdicaosecf_cd in JURISDICAO_SECF.cd%type
                               ) return JURISDICAO_SECF.id%type;
         
-------------------------------------------------------------------------------------------------------

-- Fun��o recupera o C�digo da Jurisdicao do Sped ECF com base no C�digo de Identifica��o do registro

function fkg_cd_jurisdicaosecf ( en_jurisdicaosecf_id in JURISDICAO_SECF.ID%type 
                               ) return JURISDICAO_SECF.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o recupera a Indica��o da Forma de Apura��o da Estimativa
function fkg_vlr_mes_bal_red ( ev_dm_per_apur in varchar2 )
         return abert_ecf_param_trib.dm_mes_bal_red1%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o recupera a Forma de Tributa��o no Per�odo
function fkg_vlr_forma_trib_per ( ev_dm_per_apur in abert_ecf_param_trib.dm_mes_bal_red1%type )
         return abert_ecf_param_trib.dm_forma_trib_per1%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o c�digo ECF do "Tipo de C�digo de arquivo" por pais

function fkg_cd_ecf_pais_tipo_cod_arq ( en_pais_id        in pais.id%type
                                      )
         return pais_tipo_cod_arq.cd%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela PER_SLD_CC_ECD conforme chave �nica

function fkg_persldccecd_id ( en_aberturaecf_id  in per_sld_cc_ecd.aberturaecf_id%type
                            , ev_dm_per_apur     in per_sld_cc_ecd.dm_per_apur%type
                            , ed_dt_ini          in per_sld_cc_ecd.dt_ini%type
                            , ed_dt_fin          in per_sld_cc_ecd.dt_fin%type
                            )
         return per_sld_cc_ecd.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela PER_DEMON_BP conforme chave �nica

function fkg_perdemonbp_id ( en_aberturaecf_id  in per_demon_bp.aberturaecf_id%type
                           , ev_dm_per_apur     in per_demon_bp.dm_per_apur%type
                           , ed_dt_ini          in per_demon_bp.dt_ini%type
                           , ed_dt_fin          in per_demon_bp.dt_fin%type
                           )
         return per_demon_bp.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que verifica se existe o ID na tabela lcto_part_a_lacs_lalur
function fkg_lctopartalacslalur_id ( en_ccrlancpart_id     in ccr_lanc_part.id%type
                                   , en_intlctocontabil_id in int_lcto_contabil.id%type
                                   ) return lcto_part_a_lacs_lalur.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que verifica se existe o ID na tabela ccr_lanc_part
function fkg_ccr_lanc_part_id ( en_lancvlrtabdin_id in lanc_vlr_tab_din.id%type
                              , en_planoconta_id    in plano_conta.id%type
                              , en_centrocusto_id   in centro_custo.id%type --#69546
                              ) return ccr_lanc_part.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que verifica se existe o ID na tabela ccr_lanc_part
function fkg_contapartb_id ( en_lancvlrtabdin_id in lanc_vlr_tab_din.id%type
                           , en_planoconta_id    in plano_conta.id%type
                           ) return conta_part_b.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que verifica se existe o ID na tabela lanc_vlr_tab_din

function fkg_exist_lancvlrtabdin ( en_lancvlrtabdin_id in lanc_vlr_tab_din.id%type
                                   ) return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela lanc_vlr_tab_din conforme chave �nica

function fkg_lancvlrtabdin_id ( ed_dt_ini       in lanc_vlr_tab_din.dt_ini%type
                              , ed_dt_fin       in lanc_vlr_tab_din.dt_fim%type
                              , en_empresa_id   in empresa.id%type
                              , en_tabdinecf_id in tab_din_ecf.id%type
                              ) return lanc_vlr_tab_din.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela tab_din_ecf conforme chave �nica

function fkg_tabdinecf_id ( en_codentref_id    in  cod_ent_ref.id%type
                          , en_registroecf_id  in  registro_ecf.id%type
                          , ev_tabdinecf_cd    in  tab_din_ecf.cd%type
                          )
         return tab_din_ecf.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela cod_ent_ref conforme o codigo

function fkg_codentref_id ( ev_cod_ent_ref in cod_ent_ref.cod_ent_ref%type
                          ) return cod_ent_ref.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela PER_APUR_LR conforme chave �nica

function fkg_perapurlr_id ( en_aberturaecf_id  in per_apur_lr.aberturaecf_id%type
                          , ev_dm_per_apur     in per_apur_lr.dm_per_apur%type
                          , ed_dt_ini          in per_apur_lr.dt_ini%type
                          , ed_dt_fin          in per_apur_lr.dt_fin%type
                          )
         return per_apur_lr.id%type;

--------------------------------------------------------------------------------------------------------
-- Fun��o retorna id da tabela per_apur_lr atrav�s do id da tabela abertura_ecf e as datas de inicio e fim.
--
function fkg_busca_perapurlr_id (en_aberturaecf_id  in per_apur_lr.aberturaecf_id%type
                                ,ed_dt_ini          in per_apur_lr.dt_ini%type
                                ,ed_dt_fin          in per_apur_lr.dt_fin%type) return per_apur_lr.id%type;
                                
-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela PER_CALC_APUR_LR conforme chave �nica

function fkg_percalcapurlr_id ( en_aberturaecf_id  in per_calc_apur_lr.aberturaecf_id%type
                              , ev_dm_per_apur     in per_calc_apur_lr.dm_per_apur%type
                              , ed_dt_ini          in per_calc_apur_lr.dt_ini%type
                              , ed_dt_fin          in per_calc_apur_lr.dt_fin%type
                              )
         return per_calc_apur_lr.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o o n�mero de mes�s do "tipo de per�odo"

function fkg_meses_periodo ( ev_dm_per_apur in varchar2
                           , ed_dt_ini      in date
                           , ed_dt_fin      in date
                           )
         return number;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela PER_CALC_APUR_LP conforme chave �nica

function fkg_percalcapurlp_id ( en_aberturaecf_id  in per_calc_apur_lp.aberturaecf_id%type
                              , ev_dm_per_apur     in per_calc_apur_lp.dm_per_apur%type
                              , ed_dt_ini          in per_calc_apur_lp.dt_ini%type
                              , ed_dt_fin          in per_calc_apur_lp.dt_fin%type
                              )
         return per_calc_apur_lp.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela ctrl_saldo_part_b_lr conforme chave �nica
function fkg_ctrlsaldopartblr_id ( en_planoconta_id      in plano_conta.id%type
                                 , ev_dm_cod_tributo     in ctrl_saldo_part_b_lr.dm_cod_tributo%type
                                 )
         return ctrl_saldo_part_b_lr.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela PER_CALC_APUR_LA conforme chave �nica

function fkg_percalcapurla_id ( en_aberturaecf_id  in per_calc_apur_la.aberturaecf_id%type
                              , ev_dm_per_apur     in per_calc_apur_la.dm_per_apur%type
                              , ed_dt_ini          in per_calc_apur_la.dt_ini%type
                              , ed_dt_fin          in per_calc_apur_la.dt_fin%type
                              )
         return per_calc_apur_la.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o retorna o ID da tabela PER_CALC_APUR_II conforme chave �nica

function fkg_percalcapurii_id ( en_aberturaecf_id  in per_calc_apur_ii.aberturaecf_id%type
                              , ev_dm_per_apur     in per_calc_apur_ii.dm_per_apur%type
                              , ed_dt_ini          in per_calc_apur_ii.dt_ini%type
                              , ed_dt_fin          in per_calc_apur_ii.dt_fin%type
                              )
         return per_calc_apur_ii.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que retorna o ID da tabela INF_MULT_DECL_PAIS

function fkg_infmultdeclpais_id ( en_empresa_id in empresa.id%type
                                , en_ano_ref    in inf_mult_decl_pais.ano_ref%type
                                ) return inf_mult_decl_pais.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que verifica se existe o ID na tabela INF_MULT_DECL_PAIS

function fkg_exist_infmultdeclpais ( en_infmultdeclpais_id in inf_mult_decl_pais.id%type
                                   ) return boolean;

-------------------------------------------------------------------------------------------------------

-- Fun��o que verifica se recupera o c�digo de identifica��o do registro a partir

function fkg_declpaisapais_id ( en_infmultdeclpais_id in inf_mult_decl_pais.id%type
                              , en_jurisdicaosecf_id  in jurisdicao_secf.id%type
                              ) return decl_pais_a_pais.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que verifica se recupera o c�digo de identifica��o do registro da tabela decl_pais_a_pais_ent_integr a partir dos campos chave

function fkg_declpaisapaisentintegr_id ( en_declpaisapais_id       in decl_pais_a_pais.id%type
                                       , en_jurisdicaosecf_id      in jurisdicao_secf.id%type
                                       , ev_nome                   in varchar2
                                       , ev_tin                    in varchar2
                                       , en_jurisdicaosecf_id_tin  in jurisdicao_secf.id%type
                                       , ev_ni                     in varchar2
                                       , en_jurisdicaosecf_id_in   in jurisdicao_secf.id%type
                                       , ev_tipo_ni                in varchar2
                                       , ev_dm_tip_end             in varchar2
                                       , ev_endereco               in varchar2
                                       , ev_num_tel                in varchar2
                                       , ev_email                  in varchar2
                                       ) return decl_pais_a_pais_ent_integr.id%type;

------------------------------------------------------------------------------------------------------- 

-- Fun��o que verifica se recupera o c�digo de identifica��o do registro da tabela decl_pais_a_pais_obs_adic a partir dos campos chave
function fkg_declpaisapaisobsadic_id ( en_empresa_id        in empresa.id%type
                                     , ed_dt_ref            in decl_pais_a_pais_obs_adic.dt_ref%type
                                     , en_jurisdicaosecf_id in jurisdicao_secf.id%type
                                     ) return decl_pais_a_pais_obs_adic.id%type;

-------------------------------------------------------------------------------------------------------

-- Fun��o que Verifica se o ID ja existe na tabela decl_pais_a_pais_obs_adic
function fkg_verif_declpaisapaisobsadic ( en_declpaisapaisobsadic_id in decl_pais_a_pais_obs_adic.id%type
                                        ) return boolean;

-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID da tabela lanc_part_a_lalur conforme chave �nica
function fkg_lancpartalalur_id ( en_perapurlr_id  in lanc_part_a_lalur.perapurlr_id%type
                               , en_tabdinecf_id  in lanc_part_a_lalur.tabdinecf_id%type/*                               
                               , en_dm_tipo       in lanc_part_a_lalur.dm_tipo%type*/
                               )
         return lanc_part_a_lalur.id%type;
         
-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID da tabela lanc_part_a_lacs conforme chave �nica
function fkg_lancpartalacs_id ( en_perapurlr_id  in lanc_part_a_lacs.perapurlr_id%type
                               , en_tabdinecf_id  in lanc_part_a_lacs.tabdinecf_id%type/*
                               , en_dm_tipo       in lanc_part_a_lacs.dm_tipo%type*/
                               )
         return lanc_part_a_lacs.id%type;
                  
-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID da tabela ccr_lanc_part_a_lalur conforme chave �nica
function fkg_ccrlancpartalalur_id ( en_lancpartalalur_id  in ccr_lanc_part_a_lalur.lancpartalalur_id%type
                                  , en_planoconta_id  in ccr_lanc_part_a_lalur.planoconta_id%type
                                  , en_centrocusto_id in ccr_lanc_part_a_lalur.centrocusto_id%type
                                  )
         return ccr_lanc_part_a_lalur.id%type;
-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID da tabela ccr_lanc_part_a_lacs conforme chave �nica
function fkg_ccrlancpartalacs_id ( en_lancpartalacs_id  in ccr_lanc_part_a_lacs.lancpartalacs_id%type
                                 , en_planoconta_id  in ccr_lanc_part_a_lacs.planoconta_id%type
                                 , en_centrocusto_id in ccr_lanc_part_a_lacs.centrocusto_id%type
                                 )
         return ccr_lanc_part_a_lacs.id%type;
-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID da tabela conta_part_b_lalur conforme chave �nica
function fkg_contapartblalur_id ( en_lancpartalalur_id  in conta_part_b_lalur.lancpartalalur_id%type
                                 , en_planoconta_id  in conta_part_b_lalur.planoconta_id%type
                                 )
         return conta_part_b_lalur.id%type;
-------------------------------------------------------------------------------------------------------
-- Fun��o retorna o ID da tabela conta_part_b_lacs conforme chave �nica
function fkg_contapartblacs_id ( en_lancpartalacs_id  in conta_part_b_lacs.lancpartalacs_id%type
                               , en_planoconta_id     in conta_part_b_lacs.planoconta_id%type
                               )
         return conta_part_b_lacs.id%type;
-------------------------------------------------------------------------------------------------------
-- Fun��o retorna se cfop gera receita ou nao
function fkg_cfop_gera_rec (en_empresa_id in PARAM_CFOP_RECEITA_EMPRESA.EMPRESA_ID%type,
                            en_cfop_id    in PARAM_CFOP_RECEITA_EMPRESA.CFOP_ID%type)
                            return boolean ;     
-------------------------------------------------------------------------------------------------------
-- Fun��o retorna "true" se o c�digo da moeda para o codigo de tabela (DM_TAB_MOEDA) - (0-Bacen/1-CBC) pais 
-- for v�lido e "false" se n�o for, conforme ID

function fkg_tipo_moeda_id_valido ( en_tipo_moeda_id  in tipo_moeda.id%TYPE 
                                  , en_dm_tab_moeda   in tipo_moeda.dm_tab_moeda %TYPE )
         return boolean;

--------------------------------------------------------------------------------------------------------
-- Fun��o para verificar se existe registro de erro gravados no log_generico (ECF) - Lucro Explora��o

function fkg_ver_erro_log_generico_ecf( en_referencia_id in Log_Generico_inv.referencia_id%type )
         return number;
							
-------------------------------------------------------------------------------------------------------

end pk_csf_secf;
/
