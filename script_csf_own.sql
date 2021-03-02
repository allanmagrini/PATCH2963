------------------------------------------------------------------------------------------
Prompt INI Patch 2.9.6.3 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------

insert into csf_own.versao_sistema ( ID
                                   , VERSAO
                                   , DT_VERSAO
                                   )
                            values ( csf_own.versaosistema_seq.nextval -- ID
                                   , '2.9.6.3'                         -- VERSAO
                                   , sysdate                           -- DT_VERSAO
                                   )
/

commit
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70422: Criar tabela de apuração de ISS Geral
--------------------------------------------------------------------------------------------------------------------------------------
-- APUR_ISS_SIMPLIFICADA --
declare
   vn_existe_tab number := null;
begin
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('APUR_ISS_SIMPLIFICADA');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      execute immediate 'CREATE TABLE CSF_OWN.APUR_ISS_SIMPLIFICADA
                           ( ID                    NUMBER                     NOT NULL,
                             EMPRESA_ID            NUMBER                     NOT NULL,
                             DT_INICIO             DATE                       NOT NULL,
                             DT_FIM                DATE,
                             DM_SITUACAO           NUMBER(1)        DEFAULT 0 NOT NULL,
                             VL_ISS_PROPRIO        NUMBER(15,2),
                             VL_ISS_RETIDO         NUMBER(15,2),
                             VL_ISS_TOTAL          NUMBER(15,2),
                             GUIAPGTOIMP_ID_PROP   NUMBER,
                             GUIAPGTOIMP_ID_RET    NUMBER,
                             DM_SITUACAO_GUIA      NUMBER(1)        DEFAULT 0 NOT NULL,
                             CONSTRAINT APURISSSIMPLIFICADA_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
                           )TABLESPACE CSF_DATA';
      --
   end if;
   --
   -- COMMENTS --
   begin
      execute immediate 'comment on table CSF_OWN.APUR_ISS_SIMPLIFICADA                        is ''Tabela de Apuração de ISS Geral (todos municipios, exceto Brasilia)''';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.ID                    is ''Sequencial da tabela APURISSSIMPLIFICADA_SEQ''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DT_INICIO             is ''Identificador da empresa''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.EMPRESA_ID            is ''Data inicial da apuracão do iss''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DT_FIM                is ''Data final da apuracão do iss''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DM_SITUACAO           is ''Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação''';
   exception
      when others then
         null;
   end;   
   --  
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_PROPRIO        is ''Valor do ISS próprio sobre serviços prestados''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_RETIDO         is ''Valor do ISS retido sobre serviços tomados''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_TOTAL          is ''Valor Total do ISS  - soma de Proprio + Retido''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.GUIAPGTOIMP_ID_PROP   is ''Identificador da guia de ISS Proprio''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.GUIAPGTOIMP_ID_RET    is ''Identificador da guia de ISS Retido''';
   exception
      when others then
         null;
   end;   
   --   
   begin
      execute immediate 'comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA      is ''Situacao da Guia de Pagamento: 0:Nao gerada / 1:Guia Gerada / 2:Erro na Geracao da Guia''';
   exception
      when others then
         null;
   end;   
   --   
   -- CONTRAINTS --  
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_EMPRESA_FK         foreign key (EMPRESA_ID)          references CSF_OWN.EMPRESA (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_GUIAPGTOIMP01_FK   foreign key (GUIAPGTOIMP_ID_PROP) references CSF_OWN.GUIA_PGTO_IMP (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_GUIAPGTOIMP02_FK   foreign key (GUIAPGTOIMP_ID_RET)  references CSF_OWN.GUIA_PGTO_IMP (ID)';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_DMSITUACAO_CK      check (DM_SITUACAO IN (0,1,2,3,4))';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add constraint APURISSSIMP_DMSITUACAOGUIA_CK   check (DM_SITUACAO_GUIA in (0,1,2))';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add constraint APURISSSIMPLIFICADA_UK unique (EMPRESA_ID, DT_INICIO, DT_FIM)   using index TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   -- INDEX --
   begin
      execute immediate 'create index APURISSSIMP_EMPRESA_IX        on CSF_OWN.APUR_ISS_SIMPLIFICADA (EMPRESA_ID)           TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'create index APURISSSIMP_GUIAPGTOIMP01_IX  on CSF_OWN.APUR_ISS_SIMPLIFICADA (GUIAPGTOIMP_ID_PROP)  TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'create index APURISSSIMP_GUIAPGTOIMP02_IX  on CSF_OWN.APUR_ISS_SIMPLIFICADA (GUIAPGTOIMP_ID_RET)   TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --
   begin
      execute immediate 'create index APURISSSIMP_DMSITUACAOGUIA_IX on CSF_OWN.APUR_ISS_SIMPLIFICADA (DM_SITUACAO_GUIA)     TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;   
   --   
   -- SEQUENCE --
   begin
      execute immediate '
         CREATE SEQUENCE CSF_OWN.APURISSSIMPLIFICADA_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE';
   exception
     when others then
        if sqlcode = -955 then
           null;
        else
          raise;
        end if;
   end;
   --   
   begin
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'APURISSSIMPLIFICADA_SEQ'
                                  , 'APUR_ISS_SIMPLIFICADA'
                                  );
   exception
      when dup_val_on_index then
         null;
   end;
   --
   -- DOMINIO: APUR_ISS_SIMPLIFICADA.DM_SITUACAO -------------------------------------------------------------
   --'Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação'
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '0',
                                  'Aberta',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '1',
                                  'Calculada',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '2',
                                  'Erro',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '3',
                                  'Validada',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO',
                                  '4',
                                  'Erro de Validação',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   -- DOMINIO: APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA ------------------------------------------------------------- 
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA',
                                  '0',
                                  'Não Gerada',
                                  DOMINIO_SEQ.NEXTVAL);
      --
      COMMIT;
      --   
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA',
                                  '1',
                                  'Guia Gerada',
                                  DOMINIO_SEQ.NEXTVAL);
      --
      COMMIT;
      --   
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA',
                                  '2',
                                  'Erro na Geração da Guia',
                                  DOMINIO_SEQ.NEXTVAL);
      --
      COMMIT;
      --   
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --   
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 73052S. Criacao da tabela APUR_ISS_SIMPLIFICADA. Erro: ' || sqlerrm);
end;
/

grant select, insert, update, delete   on CSF_OWN.APUR_ISS_SIMPLIFICADA     to CSF_WORK
/

grant select                           on CSF_OWN.APURISSSIMPLIFICADA_SEQ   to CSF_WORK
/

COMMIT
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #70422: Criar tabela de apuração de ISS Geral
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70422: Criar tabela de apuração de ISS Geral
--------------------------------------------------------------------------------------------------------------------------------------
-- LOG_GENERICO_APUR_ISS --
declare
   vn_existe_tab number := null;
begin
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('LOG_GENERICO_APUR_ISS');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      execute immediate 'CREATE TABLE CSF_OWN.LOG_GENERICO_APUR_ISS(   
         id             NUMBER not null,
         empresa_id     NUMBER,
         processo_id    NUMBER not null,
         dt_hr_log      DATE not null,
         referencia_id  NUMBER,
         obj_referencia VARCHAR2(30),
         resumo         VARCHAR2(4000),
         mensagem       VARCHAR2(4000) not null,
         dm_impressa    NUMBER(1) not null,
         dm_env_email   NUMBER(1) not null,
         csftipolog_id  NUMBER not null,
         CONSTRAINT LOGGENERICOAPURISS_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
       )TABLESPACE CSF_DATA';
      --
   end if;
   --
   -- COMMENTS --
   begin
      execute immediate 'comment on table CSF_OWN.LOG_GENERICO_APUR_ISS  is ''Tabela de Log Genérico da apuração do ISS''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.id             is ''Identificador do registro - LOGGENERICOAPURISS_SEQ''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.empresa_id     is ''ID relacionado a tabela EMPRESA''' ;
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.processo_id    is ''Id do processo''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.dt_hr_log      is ''Data de geração do log''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.referencia_id  is ''ID de referencia do registro''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.obj_referencia is ''Nome do objeto de referencia''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.resumo         is ''Resumo do log''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.mensagem       is ''Mensagem detalhada''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.dm_impressa    is ''Valores válidos: 0-Não; 1-Sim''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.dm_env_email   is ''Valores válidos: 0-Não; 1-Sim''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.LOG_GENERICO_APUR_ISS.csftipolog_id  is ''ID relacionado a tabela CSF_TIPO_LOG''';
   exception
      when others then
         null;
   end;
   --
   -- INDEX --
   begin
      execute immediate 'create index LOGGENAPURISS_CSFTIPOLOG_IX on CSF_OWN.LOG_GENERICO_APUR_ISS (CSFTIPOLOG_ID) tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index LOGGENAPURISS_EMPRESA_IX    on CSF_OWN.LOG_GENERICO_APUR_ISS (EMPRESA_ID)    tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index LOGGENAPURISS_IX01          on CSF_OWN.LOG_GENERICO_APUR_ISS (OBJ_REFERENCIA, REFERENCIA_ID, DT_HR_LOG)  tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   -- CONSTRAINTS --
   begin
      execute immediate 'alter table CSF_OWN.LOG_GENERICO_APUR_ISS add constraint LOGGENAPURISS_CSFTIPOLOG_FK   foreign key (CSFTIPOLOG_ID) references CSF_OWN.CSF_TIPO_LOG (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.LOG_GENERICO_APUR_ISS add constraint LOGGENAPURISS_EMPRESA_FK      foreign key (EMPRESA_ID)    references CSF_OWN.EMPRESA (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.LOG_GENERICO_APUR_ISS  add constraint LOGGENAPURISS_DMENVEMAIL_CK  check (DM_ENV_EMAIL IN (0,1))';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.LOG_GENERICO_APUR_ISS  add constraint LOGGENAPURISS_DMIMPRESSA_CK  check (DM_IMPRESSA IN(0,1))';
   exception
      when others then
         null;
   end;
   --
   -- SEQUENCE --
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.LOGGENERICOAPURISS_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE
      ';
   EXCEPTION
     WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
           NULL;
        ELSE
          RAISE;
        END IF;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'LOGGENERICOAPURISS_SEQ'
                                  , 'LOG_GENERICO_APUR_ISS'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   -- DOMINIO: LOG_GENERICO_APUR_ISS.DM_ENV_EMAIL -------------------------------------------------------------
   --'Valores válidos: 0-Não; 1-Sim'
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('LOG_GENERICO_APUR_ISS.DM_ENV_EMAIL',
                                  '0',
                                  'Não',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('LOG_GENERICO_APUR_ISS.DM_ENV_EMAIL',
                                  '1',
                                  'Sim',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   -- DOMINIO: LOG_GENERICO_APUR_ISS.DM_IMPRESSA -------------------------------------------------------------
   --'Valores válidos: 0-Não; 1-Sim'
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('LOG_GENERICO_APUR_ISS.DM_IMPRESSA',
                                  '0',
                                  'Não',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('LOG_GENERICO_APUR_ISS.DM_IMPRESSA',
                                  '1',
                                  'Sim',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 70422. Criacao da tabela LOG_GENERICO_APUR_ISS. Erro: ' || sqlerrm);
end;
/

grant select, insert, update, delete   on CSF_OWN.LOG_GENERICO_APUR_ISS     to CSF_WORK
/

grant select                           on CSF_OWN.LOGGENERICOAPURISS_SEQ    to CSF_WORK
/

COMMIT
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Fim Redmine #70422: Criar tabela de apuração de ISS Geral
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #65266: Especificacao funcional - Tabela PARAM_GUIA_PGTO
--------------------------------------------------------------------------------------------------------------------------------------
-- PARAM_DET_GUIA_IMP --
declare
   vn_existe_tab number := null;
begin
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('PARAM_GUIA_PGTO');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      execute immediate '
         CREATE TABLE CSF_OWN.PARAM_GUIA_PGTO(
            ID                 NUMBER not null,
            EMPRESA_ID         NUMBER not null,
            DM_UTIL_RET_ERP    NUMBER(1) not null,
            DM_GERA_NRO_TIT    NUMBER(1) not null,
            NRO_ULT_TIT_FIN    NUMBER,
            DT_ALTERACAO       DATE default (SYSDATE) not null,
            CONSTRAINT PARAMGUIAPGTO_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
         )TABLESPACE CSF_DATA';
      --   
   end if;
   --
   -- COMMENTS --
   begin
      execute immediate 'comment on table CSF_OWN.PARAM_GUIA_PGTO                   is ''Parametro de guias de pagamentos''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.id               is ''Sequencial da tabela PARAMGUIAPGTO_SEQ''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.empresa_id       is ''ID relacionado a tabela EMPRESA''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.dm_util_ret_erp  is ''Utiliza retorno com ERP: 0=Não / 1=Sim''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.dm_gera_nro_tit  is ''Indica se deve haver controle numérico sequencial nas guias de pagamento - isso será retornado ao ERP: 0=Não / 1 = Sim''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.nro_ult_tit_fin  is ''Numero do ultimo titulo. Só deve ser preenchido quando sistema controlar numeração de titulos''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_GUIA_PGTO.dt_alteracao     is ''Data da ultima alteração''';
   exception
      when others then
         null;
   end;
   --
   -- CONSTRAINTS --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_GUIA_PGTO  add constraint PARAMGUIAPGTO_EMPRESA_FK foreign key (EMPRESA_ID)  references EMPRESA (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_GUIA_PGTO  add constraint PARAMGUIAPGTO_DMGERANROTIT_CK  check (DM_GERA_NRO_TIT IN (0, 1))';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_GUIA_PGTO  add constraint PARAMGUIAPGTO_DMUTILRETERP_CK  check (DM_UTIL_RET_ERP IN (0, 1))';
   exception
      when others then
         null;
   end;
   --
   -- INDEXES --
   begin
      execute immediate 'create index PARAMGUIAPGTO_DMGERANROTIT_IX on CSF_OWN.PARAM_GUIA_PGTO (DM_GERA_NRO_TIT)  tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PARAMGUIAPGTO_DMUTILRETERP_IX on CSF_OWN.PARAM_GUIA_PGTO (DM_UTIL_RET_ERP)  tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PARAMGUIAPGTO_EMPRESAID_IX on CSF_OWN.PARAM_GUIA_PGTO (EMPRESA_ID)          tablespace CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   -- SEQUENCE --
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.PARAMGUIAPGTO_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE
      ';
   EXCEPTION
     WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
           NULL;
        ELSE
          RAISE;
        END IF;
   END;          
   --
   BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'PARAMGUIAPGTO_SEQ'
                                  , 'PARAM_GUIA_PGTO'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                                
   --
   -- DOMINIO: PARAM_GUIA_PGTO.DM_GERA_NRO_TIT ------------------------------------------------------------- 
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_GUIA_PGTO.DM_GERA_NRO_TIT',
                                  '0',
                                  'Não',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_GUIA_PGTO.DM_GERA_NRO_TIT',
                                  '1',
                                  'Sim',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script #65266. Criacao da tabela PARAM_GUIA_PGTO. Erro: ' || sqlerrm);
end;
/

-- GRANTS --
grant select, insert, update, delete   on CSF_OWN.PARAM_GUIA_PGTO     to CSF_WORK
/

grant select                           on CSF_OWN.PARAMGUIAPGTO_SEQ   to CSF_WORK
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #65266: Especificacao funcional - Tabela PARAM_GUIA_PGTO
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #65266: Especificacao funcional - Tabela PARAM_DET_GUIA_IMP
--------------------------------------------------------------------------------------------------------------------------------------
-- PARAM_DET_GUIA_IMP --
declare
   vn_existe_tab number := null;
begin
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('PARAM_DET_GUIA_IMP');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      execute immediate '
         CREATE TABLE CSF_OWN.PARAM_DET_GUIA_IMP
         (
           ID                    NUMBER          NOT NULL,
           PARAMGUIAPGTO_ID      NUMBER          NOT NULL,
           TIPOIMP_ID            NUMBER          NOT NULL,
           DM_TIPO               NUMBER(1)       NOT NULL,
           DM_ORIGEM             NUMBER(2)       NOT NULL,
           NRO_VIA_IMPRESSA      NUMBER(3)           NULL,
           EMPRESA_ID_GUIA       NUMBER              NULL,
           OBS                   VARCHAR2(500)       NULL,
           PESSOA_ID_SEFAZ       NUMBER              NULL,
           TIPORETIMP_ID         NUMBER              NULL,
           TIPORETIMPRECEITA_ID  NUMBER              NULL,
           DIA_VCTO              NUMBER(2)           NULL,
           CONSTRAINT PARAMDETGUIAIMP_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
         ) TABLESPACE CSF_DATA';
      --   
   end if;
   -- COMMENTS --
   begin
      execute immediate 'comment on table CSF_OWN.PARAM_DET_GUIA_IMP                     is ''Detalhamento por impostos de parametros da guia de pagamento''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.ID                 is ''Sequencial da tabela PARAMDETGUIAIMP_SEQ''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.PARAMGUIAPGTO_ID   is ''ID relacionado a tabela PARAM_GUIA_PGTO''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.TIPOIMP_ID         is ''ID relacionado a tabela TIPO_IMPOSTO''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.DM_TIPO            is ''Tipo da Guia: 1-GPS; 2-DARF; 3-GARE; 4-GNRE; 5-OUTROS''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.DM_ORIGEM          is ''Origem dos dados: 1-Imposto Retido; 2-Apuração IPI; 3-Apuração ICMS; 4-Apuracao ICMS-ST; 5-Sub-Apuração ICMS; 6-Apuração ICMS-DIFAL; 7-Apuração PIS; 8-Apuração COFINS; 9-Apuração de ISS; 10-INSS Retido em Nota Serviço; 11-Apuração IRPJ; 12-Apuração CSLL''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.NRO_VIA_IMPRESSA   is ''Numero de vias que serão impressas caso recurso esteja em uso''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.EMPRESA_ID_GUIA    is ''ID relacionado a tabela EMPRESA na qual deve ser criada a guia, por exemplo ID da matriz. Se tiver vazio pegará do parametro principal''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.OBS                is ''Observação que deve sair descrita na guia''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.PESSOA_ID_SEFAZ    is ''ID relacionado a tabela PESSOA que possui o direito de receber o valor do titulo financeiro ou guia, no caso sera a Receita Federal, Estadual ou Municipal''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.tiporetimp_id      is ''Código de recolhimento principal''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.tiporetimpreceita_id is ''Complemento do códIgo de recolhimento - no caso de Darf onde esses 2 dígitos indica o período''';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'comment on column CSF_OWN.PARAM_DET_GUIA_IMP.dia_vcto is ''Dia de vencimento do pagamento da guia''';
   exception
      when others then
         null;
   end;   
   --
   -- CONSTRAINTS --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_PARAMGUIAPGTO_FK  foreign key (PARAMGUIAPGTO_ID) references CSF_OWN.PARAM_GUIA_PGTO (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_TIPOIMPID_FK      foreign key (TIPOIMP_ID)       references CSF_OWN.TIPO_IMPOSTO (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_EMPRESAIDGUIA_FK  foreign key (EMPRESA_ID_GUIA)  references CSF_OWN.EMPRESA (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_PESSOAIDSEFAZ_FK  foreign key (PESSOA_ID_SEFAZ)  references CSF_OWN.PESSOA (ID)';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_DMTIPO_CK         check (DM_TIPO IN (1,2,3,4,5))';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_DMORIGEM_CK       check (DM_ORIGEM IN (1,2,3,4,5,6,7,8,9,10,11,12))';
   exception
      when others then
         null;
   end;
   --
   -- INDEXES --
   begin
      execute immediate 'create index PDETGUIAIMP_PARAMGUIAPGTO_IX  on CSF_OWN.PARAM_DET_GUIA_IMP (PARAMGUIAPGTO_ID)  TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_TIPOIMPID_IX      on CSF_OWN.PARAM_DET_GUIA_IMP (TIPOIMP_ID)        TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_EMPRESAIDGUIA_IX  on CSF_OWN.PARAM_DET_GUIA_IMP (EMPRESA_ID_GUIA)   TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_PESSOAIDSEFAZ_IX  on CSF_OWN.PARAM_DET_GUIA_IMP (PESSOA_ID_SEFAZ)   TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_DMTIPO_IX         on CSF_OWN.PARAM_DET_GUIA_IMP (DM_TIPO)           TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   begin
      execute immediate 'create index PDETGUIAIMP_DMORIGEM_IX       on CSF_OWN.PARAM_DET_GUIA_IMP (DM_ORIGEM)         TABLESPACE CSF_INDEX';
   exception
      when others then
         null;
   end;
   --
   -- SEQUENCE --
   BEGIN
      EXECUTE IMMEDIATE '
         CREATE SEQUENCE CSF_OWN.PARAMDETGUIAIMP_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE
      ';
   EXCEPTION
     WHEN OTHERS THEN
        IF SQLCODE = -955 THEN
           NULL;
        ELSE
          RAISE;
        END IF;
   END;          
   --
   BEGIN
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , 'PARAMDETGUIAIMP_SEQ'
                                  , 'PARAM_DET_GUIA_IMP'
                                  );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                                
   --
   -- DOMINIO: PARAM_DET_GUIA_IMP.DM_TIPO ------------------------------------------------------------- 
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '1',
                                  'GPS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '2',
                                  'DARF',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '3',
                                  'GARE',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '4',
                                  'GNRE',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_TIPO',
                                  '5',
                                  'OUTROS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   -- DOMINIO: PARAM_DET_GUIA_IMP.DM_ORIGEM ------------------------------------------------------------- 
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '1',
                                  'Imposto Retido',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '2',
                                  'Apuração IPI',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '3',
                                  'Apuração ICMS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '4',
                                  'Apuracao ICMS-ST',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '5',
                                  'Sub-Apuração ICMS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '6',
                                  'Apuração ICMS-DIFAL',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '7',
                                  'Apuração PIS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '8',
                                  'Apuração COFINS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '9',
                                  'Apuração de ISS',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '10',
                                  'INSS Retido em Nota Serviço',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '11',
                                  'Apuração IRPJ',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;                               
   --
   BEGIN
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                  VL,
                                  DESCR,
                                  ID)
                          VALUES ('PARAM_DET_GUIA_IMP.DM_ORIGEM',
                                  '12',
                                  'Apuração CSLL',
                                  DOMINIO_SEQ.NEXTVAL);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         NULL;
   END;
   --
   COMMIT;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script #65266. Criacao da tabela PARAM_DET_GUIA_IMP. Erro: ' || sqlerrm);
end;
/
--
grant select, insert, update, delete   on CSF_OWN.PARAM_DET_GUIA_IMP     to CSF_WORK
/

grant select                           on CSF_OWN.PARAMDETGUIAIMP_SEQ    to CSF_WORK
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #65266: Especificacao funcional - Tabela PARAM_DET_GUIA_IMP
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add cidade_id NUMBER');
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add planoconta_id NUMBER');
   --
   pExec_Imed('comment on column CSF_OWN.PARAM_DET_GUIA_IMP.cidade_id  is ''ID relacionado com a tabela CIDADE''');
   --
   pExec_Imed('comment on column CSF_OWN.PARAM_DET_GUIA_IMP.planoconta_id  is ''ID relacionado com a tabela PLANO_CONTA''');
   --
   pExec_Imed('create index PDETGUIAIMP_CIDADE_IX on CSF_OWN.PARAM_DET_GUIA_IMP (CIDADE_ID) tablespace CSF_INDEX');
   --
   pExec_Imed('create index PDETGUIAIMP_PLANOCONTA_IX on CSF_OWN.PARAM_DET_GUIA_IMP (PLANOCONTA_ID) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add constraint PDETGUIAIMP_CIDADE_FK foreign key (CIDADE_ID) references CIDADE (ID)');
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add constraint PDETGUIAIMP_PLANOCONTA_FK foreign key (PLANOCONTA_ID)  references PLANO_CONTA (ID)');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add nro_tit_financ NUMBER(15)');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add dt_alteracao DATE default sysdate not null');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add dm_ret_erp NUMBER(1) default 0 not null');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add id_erp NUMBER(15)');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_situacao       is ''Situacao: 0-Nao Validado; 1-Validado; 2-Erro de Validacao; 3-Cancelado''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.pessoa_id         is ''ID relacionado a tabela PESSOA devedora do titulo''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_tipo           is ''Tipo da Guia: 1-GPS; 2-DARF; 3-GARE; 4-GNRE; 5-OUTROS''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_origem         is ''Origem dos dados: 0-Manual; 1-Imposto Retido; 2-Apuração IPI; 3-Apuração ICMS; 4-Apuracao ICMS-ST; 5-Sub-Apuração ICMS; 6-Apuração ICMS-DIFAL; 7-Apuração PIS; 8-Apuração COFINS; 9-Apuração de ISS; 10-INSS Retido em Nota Serviço; 11-Apuração IRPJ; 12-Apuração CSLL''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.nro_via_impressa  is ''Número de vias impressas''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dt_ref            is ''Data de Referencia ou Periodo de Apuracao''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.obs               is ''Observação qualquer sobre a guia''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.pessoa_id_sefaz   is ''ID relacionado a tabela PESSOA que possui o direito de receber o valor do titulo financeiro ou guia, no caso sera a Receita Federal, Estadual ou Municipal''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.nro_tit_financ    is ''Numero do titulo financeiro que sera gerado no ERP caso o mesmo permita''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_ret_erp        is ''Indicador de retorno de registro para o ERP: 0-Nao retornado; 1-Retornado ao ERP; 2-Gerado titulo ERP; 3-Falha ao gerar titulo ERP; 4-Titulo cancelado ERP; 5-Erro ao cancelar titulo ERP''');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.id_erp            is ''Identificador numerico do registro financeiro no ERP''');
   --
   pExec_Imed('create index GUIAPGTOIMP_PESSOAIDSEFAZ_FK_I on CSF_OWN.GUIA_PGTO_IMP (PESSOA_ID_SEFAZ) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint GUIAPGTOIMP_PESSOAID_SEFAZ_FK foreign key (PESSOA_ID_SEFAZ) references PESSOA (ID)');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  drop constraint GUIAPGTOIMP_ORIGEM_CK');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint  GUIAPGTOIMP_ORIGEM_CK    check (DM_ORIGEM in (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12))');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  drop constraint GUIAPGTOIMP_SITUACAO_CK');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint  GUIAPGTOIMP_SITUACAO_CK  check (DM_SITUACAO in (0, 1, 2, 3))');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  drop constraint GUIAPGTOIMP_TIPO_CK');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint  GUIAPGTOIMP_TIPO_CK      check (DM_TIPO in (1, 2, 3, 4, 5))');
   --
   pExec_Imed('alter table CSF_OWN.APUR_IRPJ_CSLL_PARCIAL add dm_situacao_guia NUMBER(1) default 0');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_IRPJ_CSLL_PARCIAL.dm_situacao_guia  is ''Situacao da Guia de Pagamento: 0:Nao gerada / 1:Guia Gerada / 2:Erro na Geracao da Guia''');
   --
   pExec_Imed('alter table CSF_OWN.APUR_IRPJ_CSLL_PARCIAL  add constraint APURIRPJCSLLP_DMSITUACAOG_CK check (DM_SITUACAO_GUIA in (0,1,2))');
   --
   pExec_Imed('create index APURIRPJCSLLP_DMSITUACAOG_IX on APUR_IRPJ_CSLL_PARCIAL (DM_SITUACAO_GUIA) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.PGTO_IMP_RET add guiapgtoimp_id NUMBER');
   --
   pExec_Imed('comment on column CSF_OWN.PGTO_IMP_RET.guiapgtoimp_id is ''ID que relaciona a tabela GUIA_PGTO_IMP''');
   --
   pExec_Imed('alter table CSF_OWN.PGTO_IMP_RET add constraint PGTOIMPRET_GUIAPGTOIMP_FK foreign key (GUIAPGTOIMP_ID) references GUIA_PGTO_IMP (ID)');
   --
   pExec_Imed('create index PGTOIMPRET_GUIAPGTOIMP_IX on CSF_OWN.PGTO_IMP_RET (GUIAPGTOIMP_ID) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.APURACAO_ICMS_ST add dm_situacao_guia NUMBER default 0');
   --
   pExec_Imed('comment on column APURACAO_ICMS_ST.dm_situacao_guia is ''Situação de geração da guia de pagamento" e com as opções : "0=Não Gerada / 1=Guia Gerada / 2=Erro na Geração da Guia''');
   --
   pExec_Imed('alter table CSF_OWN.APURACAO_ICMS add constraint APURACAOICMS_DMSITUACAOGUIA_CK check (DM_SITUACAO_GUIA IN (0,1,2))');
   --
   pExec_Imed('create index APURICMSST_DMSITUACAOGUIA_IX on CSF_OWN.APURACAO_ICMS_ST (DM_SITUACAO_GUIA) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.OBRIG_REC_APUR_ICMS_ST add guiapgtoimp_id NUMBER');
   --
   pExec_Imed('comment on column CSF_OWN.OBRIG_REC_APUR_ICMS_ST.guiapgtoimp_id  is ''Relacionamento com a tabela GUIA_PGTO_IMP''');
   --
   pExec_Imed('alter table CSF_OWN.OBRIG_REC_APUR_ICMS_ST add constraint OBRECAPICMSST_GUIAPGTOIMP_FK foreign key (GUIAPGTOIMP_ID)  references GUIA_PGTO_IMP (ID)');
   --
   pExec_Imed('create index CSF_OWN.OBRECAPICMSST_GUIAPGTOIMP_IX on OBRIG_REC_APUR_ICMS_ST (GUIAPGTOIMP_ID) tablespace CSF_INDEX');
   --
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 70422 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70422: Criar tabela de apuração de ISS Geral
--------------------------------------------------------------------------------------------------------------------------------------
-- APUR_ISS_SIMPLIFICADA --
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --
   pExec_Imed('CREATE TABLE CSF_OWN.APUR_ISS_SIMPLIFICADA
                           ( ID                    NUMBER                     NOT NULL,
                             EMPRESA_ID            NUMBER                     NOT NULL,
                             DT_INICIO             DATE                       NOT NULL,
                             DT_FIM                DATE,
                             DM_SITUACAO           NUMBER(1)        DEFAULT 0 NOT NULL,
                             VL_ISS_PROPRIO        NUMBER(15,2),
                             VL_ISS_RETIDO         NUMBER(15,2),
                             VL_ISS_TOTAL          NUMBER(15,2),
                             GUIAPGTOIMP_ID_PROP   NUMBER,
                             GUIAPGTOIMP_ID_RET    NUMBER,
                             DM_SITUACAO_GUIA      NUMBER(1)        DEFAULT 0 NOT NULL,
                             CONSTRAINT APURISSSIMPLIFICADA_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
                           )TABLESPACE CSF_DATA');
   -- COMMENTS --
   --
   pExec_Imed('comment on table CSF_OWN.APUR_ISS_SIMPLIFICADA                        is ''Tabela de Apuração de ISS Geral (todos municipios, exceto Brasilia)''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.ID                    is ''Sequencial da tabela APURISSSIMPLIFICADA_SEQ''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DT_INICIO             is ''Identificador da empresa''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.EMPRESA_ID            is ''Data inicial da apuracão do iss''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DT_FIM                is ''Data final da apuracão do iss''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DM_SITUACAO           is ''Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_PROPRIO        is ''Valor do ISS próprio sobre serviços prestados''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_RETIDO         is ''Valor do ISS retido sobre serviços tomados''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.VL_ISS_TOTAL          is ''Valor Total do ISS  - soma de Proprio + Retido''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.GUIAPGTOIMP_ID_PROP   is ''Identificador da guia de ISS Proprio''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.GUIAPGTOIMP_ID_RET    is ''Identificador da guia de ISS Retido''');
   --   
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA      is ''Situacao da Guia de Pagamento: 0:Nao gerada / 1:Guia Gerada / 2:Erro na Geracao da Guia''');
   --   
   -- CONTRAINTS --  
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_EMPRESA_FK         foreign key (EMPRESA_ID)          references CSF_OWN.EMPRESA (ID)');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_GUIAPGTOIMP01_FK   foreign key (GUIAPGTOIMP_ID_PROP) references CSF_OWN.GUIA_PGTO_IMP (ID)');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_GUIAPGTOIMP02_FK   foreign key (GUIAPGTOIMP_ID_RET)  references CSF_OWN.GUIA_PGTO_IMP (ID)');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA  add constraint APURISSSIMP_DMSITUACAO_CK      check (DM_SITUACAO IN (0,1,2,3,4))');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add constraint APURISSSIMP_DMSITUACAOGUIA_CK   check (DM_SITUACAO_GUIA in (0,1,2))');
   --   
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add constraint APURISSSIMPLIFICADA_UK unique (EMPRESA_ID, DT_INICIO, DT_FIM)   using index TABLESPACE CSF_INDEX');
   --   
   -- INDEX --
   pExec_Imed('create index APURISSSIMP_EMPRESA_IX        on CSF_OWN.APUR_ISS_SIMPLIFICADA (EMPRESA_ID)           TABLESPACE CSF_INDEX');
   --   
   pExec_Imed('create index APURISSSIMP_GUIAPGTOIMP01_IX  on CSF_OWN.APUR_ISS_SIMPLIFICADA (GUIAPGTOIMP_ID_PROP)  TABLESPACE CSF_INDEX');
   --   
   pExec_Imed('create index APURISSSIMP_GUIAPGTOIMP02_IX  on CSF_OWN.APUR_ISS_SIMPLIFICADA (GUIAPGTOIMP_ID_RET)   TABLESPACE CSF_INDEX');
   --   
   pExec_Imed('create index APURISSSIMP_DMSITUACAOGUIA_IX on CSF_OWN.APUR_ISS_SIMPLIFICADA (DM_SITUACAO_GUIA)     TABLESPACE CSF_INDEX');
   --
   -- SEQUENCE --
   pExec_Imed('
       CREATE SEQUENCE CSF_OWN.APURISSSIMPLIFICADA_SEQ
         INCREMENT BY 1
         START WITH   1
         NOMINVALUE
         NOMAXVALUE
         NOCYCLE
         NOCACHE');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , ''APURISSSIMPLIFICADA_SEQ''
                                  , ''APUR_ISS_SIMPLIFICADA''
                                  )');

   --
   -- DOMINIO: APUR_ISS_SIMPLIFICADA.DM_SITUACAO -------------------------------------------------------------
   --'Situacão: 0-aberta; 1-Calculada; 2-Erro de calculo; 3-Validada; 4-Erro de validação'
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
               VL,
              DESCR,
              ID)
      VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
              ''0'',
              ''Aberta'',
              DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
                                     ''1'',
                                     ''Calculada'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
                                     ''2'',
                                     ''Erro'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
                                     ''3'',
                                     ''Validada'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO'',
                                     ''4'',
                                     ''Erro de Validação'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --
   -- DOMINIO: APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA ------------------------------------------------------------- 
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA'',
                                     ''0'',
                                     ''Não Gerada'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA'',
                                     ''1'',
                                     ''Guia Gerada'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --   
   pExec_Imed('
      INSERT INTO CSF_OWN.DOMINIO(DOMINIO,
                                     VL,
                                     DESCR,
                                     ID)
                             VALUES (''APUR_ISS_SIMPLIFICADA.DM_SITUACAO_GUIA'',
                                     ''2'',
                                     ''Erro na Geração da Guia'',
                                     DOMINIO_SEQ.NEXTVAL)');
   --
   -- GRANTS --
   pExec_Imed('grant select, insert, update, delete   on CSF_OWN.APUR_ISS_SIMPLIFICADA     to CSF_WORK');
   --   
   pExec_Imed('grant select                           on CSF_OWN.APURISSSIMPLIFICADA_SEQ   to CSF_WORK');
   --   
   commit;
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script 70422 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #70422: Criar tabela de apuração de ISS Geral
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70422: Criar tabela de apuração de ISS Geral
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add pessoa_id_sefaz number');
   --
   pExec_Imed('comment on column CSF_OWN.PARAM_DET_GUIA_IMP.PESSOA_ID_SEFAZ    is ''ID relacionado a tabela PESSOA que possui o direito de receber o valor do titulo financeiro ou guia, no caso sera a Receita Federal, Estadual ou Municipal''');
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP  add constraint PDETGUIAIMP_PESSOAIDSEFAZ_FK  foreign key (PESSOA_ID_SEFAZ)  references CSF_OWN.PESSOA (ID)');
   --
   pExec_Imed('create index PDETGUIAIMP_PESSOAIDSEFAZ_IX  on CSF_OWN.PARAM_DET_GUIA_IMP (PESSOA_ID_SEFAZ)   TABLESPACE CSF_INDEX');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #65266 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #65266: Especificacao funcional - Tabela PARAM_DET_GUIA_IMP
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #68776: Estrutura para integrar guia da PGTO_IMP_RET
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add aberturaefdpc_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.aberturaefdpc_id is ''ID da abertura_efd_pc caso seja gerado pela tela de Geração do EFD Pis/Cofins''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint GUIAPGTOIMP_ABERTURAEFDPC_FK foreign key (ABERTURAEFDPC_ID) references CSF_OWN.ABERTURA_EFD_PC (ID)');
   --
   pExec_Imed('create index GUIAPGTOIMP_ABERTURAEFDPC_IX on CSF_OWN.GUIA_PGTO_IMP (aberturaefdpc_id) tablespace CSF_INDEX');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #68773 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #68773: Estrutura de tabelas e procedures
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70669: Ajuste em tabelas de apuração
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add apuracaoicmsst_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.apuracaoicmsst_id  is ''ID da tabela APURACAO_ICMS_ST gerada pela tela de Apuração do ICMS''');
   --
   pExec_Imed('create index GUIAPGTOIMP_APURACAOICMSST_IX on CSF_OWN.GUIA_PGTO_IMP (apuracaoicmsst_id) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_APURACAOICMSST_FK foreign key (APURACAOICMSST_ID) references APURACAO_ICMS_ST (ID)');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #70669 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #70669: Ajuste em tabelas de apuração
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #70902: Geração de guia pela apuração de ICMS-DIFAL
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add apuricmsdifal_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.apuricmsdifal_id is ''ID da tabela APUR_ICMS_DIFAL gerada pela tela de Apuração do ICMS DIFAL''');
   --
   pExec_Imed('create index GUIAPGTOIMP_APURICMSDIFAL_IX on CSF_OWN.GUIA_PGTO_IMP (apuricmsdifal_id) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_APURICMSDIFAL_FK foreign key (APURICMSDIFAL_ID)  references CSF_OWN.APUR_ICMS_DIFAL (ID)');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #70902 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #70902: Geração de guia pela apuração de ICMS-DIFAL
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #72646: Geração de guia a partir de apuração de IR e CSLL
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add aberturaecf_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.aberturaecf_id is ''ID da tabela ABERTURA_ECF caso seja gerado pela tela de Geração do ECF''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP  add constraint GUIAPGTOIMP_ABERTURAECF_FK foreign key (ABERTURAECF_ID) references CSF_OWN.ABERTURA_ECF (ID)');
   --
   pExec_Imed('create index GUIAPGTOIMP_ABERTURAECF_IX on CSF_OWN.GUIA_PGTO_IMP (aberturaecf_id) tablespace CSF_INDEX');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #72646 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #72646: Geração de guia a partir de apuração de IR e CSLL
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine Melhoria #73443: Inclusão de colunas cidade_id e planoconta_id nas tabelas de guia
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add planoconta_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.planoconta_id is ''ID relacionado com a tabela PLANO_CONTA''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_PLANOCONTA_FK foreign key (PLANOCONTA_ID) references CSF_OWN.PLANO_CONTA (id)');
   --
   pExec_Imed('create index GUIAPGTOIMP_PLANOCONTA_IX on CSF_OWN.GUIA_PGTO_IMP (PLANOCONTA_ID) tablespace CSF_INDEX');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #73443 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine Melhoria #73443: Inclusão de colunas cidade_id e planoconta_id nas tabelas de guia
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #72795: Geração de guia a partir de retenção de INSS em documento fiscal
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add gerguiapgtoimp_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.gerguiapgtoimp_id is ''ID relacionado com a tabela GER_GUIA_PGTO_IMP''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_GERGUIAPGTOIMP_FK foreign key (gerguiapgtoimp_id) references GER_GUIA_PGTO_IMP (id)');
   --
   pExec_Imed('create index GUIAPGTOIMP_GERGUIAPGTOIMP_IX on CSF_OWN.GUIA_PGTO_IMP (gerguiapgtoimp_id) tablespace CSF_INDEX');
   --
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #72795 - Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #72795: Geração de guia a partir de retenção de INSS em documento fiscal
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #73506: Detalhamento de ISS por municipio
--------------------------------------------------------------------------------------------------------------------------------------
declare
   vn_existe_tab number := null;
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   select count(*)
     into vn_existe_tab
     from SYS.ALL_TABLES a
    where upper(a.OWNER)       = upper('CSF_OWN')
      and upper(a.TABLE_NAME)  = upper('APUR_ISS_OUT_MUN ');
   --
   if nvl(vn_existe_tab,0) = 0 then
      --
      pExec_Imed('CREATE TABLE CSF_OWN.APUR_ISS_OUT_MUN (
         ID                      NUMBER        NOT NULL,
         APURISSSIMPLIFICADA_ID  NUMBER        NOT NULL,
         CIDADE_ID               NUMBER        NOT NULL,
         VL_ISS_RETIDO           NUMBER(15,2)      NULL,
         GUIAPGTOIMP_ID          NUMBER            NULL,
         CONSTRAINT APURISSOUTMUN_PK PRIMARY KEY(ID) USING INDEX TABLESPACE CSF_INDEX
         ) TABLESPACE CSF_DATA');
      --
   end if;
   --
   -- COMMENTS --
   pExec_Imed('comment on table CSF_OWN.APUR_ISS_OUT_MUN                         is ''Apuração de ISS devido a outros municipios''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.id                     is ''Sequencial da tabela APURISSOUTMUN_SEQ''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.apurisssimplificada_id is ''Id relacionado a tabela APUR_ISS_SIMPLIFICADA - Relacionado a apuração de ISS simplificada''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.cidade_id              is ''Id relacionado a tabela CIDADE - Cidade onde o ISS é devido''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.vl_iss_retido          is ''Valor do ISS Retido''');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_OUT_MUN.guiapgtoimp_id         is ''Id Relacionado a tabela GUIA_PGTO_IMP - Identificador da guia de ISS Proprio e relacionado a guia de pagamento''');
   --
   -- CONTRAINTS --
   pExec_Imed('alter table CSF_OWN.APUR_ISS_OUT_MUN add constraint APURISSOUTMUN_APURISSSIMPL_FK foreign key (APURISSSIMPLIFICADA_ID) references CSF_OWN.APUR_ISS_SIMPLIFICADA (ID)');
   --
   pExec_Imed('alter table CSF_OWN.APUR_ISS_OUT_MUN add constraint APURISSOUTMUN_CIDADE_FK       foreign key (CIDADE_ID)              references CSF_OWN.CIDADE (ID)');   
   --
   pExec_Imed('alter table CSF_OWN.APUR_ISS_OUT_MUN add constraint APURISSOUTMUN_GUIAPGTOIMP_FK  foreign key (GUIAPGTOIMP_ID)         references CSF_OWN.GUIA_PGTO_IMP (ID)');
   --
   pExec_Imed('alter table CSF_OWN.APUR_ISS_OUT_MUN add constraint APURISSOUTMUN_UK unique (APURISSSIMPLIFICADA_ID, CIDADE_ID)');
   --
   -- INDEX --
   pExec_Imed('create index APURISSOUTMUN_APURISSSIMPL_IX on CSF_OWN.APUR_ISS_OUT_MUN (APURISSSIMPLIFICADA_ID) tablespace CSF_INDEX');
   --
   pExec_Imed('create index APURISSOUTMUN_CIDADE_IX       on CSF_OWN.APUR_ISS_OUT_MUN (CIDADE_ID)              tablespace CSF_INDEX');
   --
   pExec_Imed('create index APURISSOUTMUN_GUIAPGTOIMP_IX  on CSF_OWN.APUR_ISS_OUT_MUN (GUIAPGTOIMP_ID)         tablespace CSF_INDEX');
   --
   -- SEQUENCE --
   pExec_Imed('
      CREATE SEQUENCE CSF_OWN.APURISSOUTMUN_SEQ
      INCREMENT BY 1
      START WITH   1
      NOMINVALUE
      NOMAXVALUE
      NOCYCLE
      NOCACHE');
   --
   pExec_Imed('
      INSERT INTO CSF_OWN.SEQ_TAB ( id
                                  , sequence_name
                                  , table_name
                                  )
                           values ( CSF_OWN.seqtab_seq.nextval
                                  , ''APURISSOUTMUN_SEQ''
                                  , ''APUR_ISS_OUT_MUN''
                                  )');   
   --
   commit;
   --
   --GRANTS --
   pExec_Imed('grant select, insert, update, delete on CSF_OWN.APUR_ISS_OUT_MUN to CSF_WORK');
   --
   pExec_Imed('grant select on CSF_OWN.APURISSOUTMUN_SEQ to CSF_WORK');
   --
   -- Criar coluna VL_ISS_RET_OUT_MUN na tabela APUR_ISS_SIMPLIFICADA com a descrição "Valor Total de ISS Retido devido a outros municipios".
   pExec_Imed('alter table CSF_OWN.APUR_ISS_SIMPLIFICADA add vl_iss_ret_out_mun number(15,2)');
   --
   pExec_Imed('comment on column CSF_OWN.APUR_ISS_SIMPLIFICADA.vl_iss_ret_out_mun  is ''Valor Total de ISS Retido devido a outros municipios''');
   --
   -- Criação de coluna de relacionamento com a GUIA_PGTO_IMP
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add apurissoutmun_id number');
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.apurissoutmun_id  is ''ID relacionado com a tabela APUR_ISS_OUT_MUN''');
   --
   pExec_Imed('create index GUIAPGTOIMP_APURISSOUTMUN_IX on CSF_OWN.GUIA_PGTO_IMP (apurissoutmun_id) tablespace CSF_INDEX');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_APURISSOUTMUN_FK foreign key (apurissoutmun_id)  references CSF_OWN.APUR_ISS_OUT_MUN (id)');
   --
exception 
   when others then
      raise_application_error(-20001, 'Erro no script #73506. Criacao da tabela APUR_ISS_OUT_MUN. Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #73506: Detalhamento de ISS por municipio
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #73509: Parametro LIBERA_AUTOM_GUIA_ERP
--------------------------------------------------------------------------------------------------------------------------------------
declare 
   vn_modulo_id   number := 0;
   vn_grupo_id    number := 0;
   vn_param_id    number := 0;
   vn_usuario_id  number := null;
begin
   
   -- MODULO DO SISTEMA --
   begin
      select ms.id
        into vn_modulo_id
      from CSF_OWN.MODULO_SISTEMA ms
      where ms.cod_modulo = 'GUIA_PGTO';
   exception
      when no_data_found then
         vn_modulo_id := 0;
      when others then
         goto SAIR_SCRIPT;   
   end;
   --
   if vn_modulo_id = 0 then
      --
      insert into CSF_OWN.MODULO_SISTEMA
      values(CSF_OWN.MODULOSISTEMA_SEQ.NEXTVAL, 'GUIA_PGTO', 'Módulo de gestão de Guias de Pagamentos', 'Módulo que será responsável por gerenciar e retornar ao ERP guias de pagamentos de tributos após apuração ou digitação')
      returning id into vn_modulo_id;
      --
   end if;
   --
   -- GRUPO DO SISTEMA --
   begin
      select gs.id
        into vn_grupo_id
      from CSF_OWN.GRUPO_SISTEMA gs
      where gs.modulo_id = vn_modulo_id
        and gs.cod_grupo = 'RET_ERP';
   exception
      when no_data_found then
         vn_grupo_id := 0;
      when others then
         goto SAIR_SCRIPT;   
   end;
   --
   if vn_grupo_id = 0 then
      --
      insert into CSF_OWN.GRUPO_SISTEMA
      values(CSF_OWN.GRUPOSISTEMA_SEQ.NextVal, vn_modulo_id, 'RET_ERP', 'Grupo de parametros relacionados ao retorno que guia para ERP', 'Grupo de parametros relacionados ao retorno que guia para ERP')
      returning id into vn_grupo_id;
      --
   end if; 
   --  
   -- PARAMETRO DO SISTEMA --
   for x in (select * from mult_org m where m.dm_situacao = 1)
   loop
      begin
         select pgs.id
           into vn_param_id
         from CSF_OWN.PARAM_GERAL_SISTEMA pgs  -- UK: MULTORG_ID, EMPRESA_ID, MODULO_ID, GRUPO_ID, PARAM_NAME
         where pgs.multorg_id = x.id
           and pgs.empresa_id is null
           and pgs.modulo_id  = vn_modulo_id
           and pgs.grupo_id   = vn_grupo_id
           and pgs.param_name = 'LIBERA_AUTOM_GUIA_ERP';
      exception
         when no_data_found then
            vn_param_id := 0;
         when others then
            goto SAIR_SCRIPT;   
      end;
      --
      --
      if vn_param_id = 0 then
         --
         -- Busca o usuário respondável pelo Mult_org
         begin
            select id
              into vn_usuario_id
            from CSF_OWN.NEO_USUARIO nu
            where upper(nu.login) = 'ADMIN';
         exception
            when no_data_found then
               begin
                  select min(id)
                    into vn_usuario_id
                  from CSF_OWN.NEO_USUARIO nu
                  where nu.multorg_id = x.id;
               exception
                  when others then
                     goto SAIR_SCRIPT;
               end;
         end;
         --
         insert into CSF_OWN.PARAM_GERAL_SISTEMA
         values( CSF_OWN.PARAMGERALSISTEMA_SEQ.NextVal
               , x.id
               , null
               , vn_modulo_id
               , vn_grupo_id
               , 'LIBERA_AUTOM_GUIA_ERP'
               , 'Indica se irá haver liberação automatica de retorno ao ERP assim que a guia for criada. Ao ativar o parametro, o campo GUIA_PGTO_IMP.DM_RET_ERP é criado com valor 0-Nao retornado, caso esteja desativado, o campo citado é criado como 6-Aguardando liberação e só será alterado com ação do usuário. Valores possiveis: 0=Não / 1=Sim.'
               , '1'
               , vn_usuario_id
               , sysdate);
         --
      end if;   
      --
   end loop;   
   --
   commit;
   --
   <<SAIR_SCRIPT>>
   rollback;
end;
/

declare
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   -- Dominio GUIA_PGTO_IMP.DM_RET_ERP
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','0','Nao retornado');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','1','Retornado ao ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','2','Gerado titulo ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','3','Falha ao gerar titulo ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','4','Titulo cancelado ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','5','Erro ao cancelar titulo ERP');
   pk_csf.pkb_cria_dominio('GUIA_PGTO_IMP.DM_RET_ERP','6','Aguardando liberação');   
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.dm_ret_erp is ''Indicador de retorno de registro para o ERP: 0-Nao retornado; 1-Retornado ao ERP; 2-Gerado titulo ERP; 3-Falha ao gerar titulo ERP; 4-Titulo cancelado ERP; 5-Erro ao cancelar titulo ERP; 6-Aguardando liberação''');
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP drop constraint GUIAPGTOIMP_DMRETERP_CK');
   --   
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_DMRETERP_CK check (DM_RET_ERP in (1,2,3,4,5,6))');
   --
   commit;
   --
end;   
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #73509: Parametro LIBERA_AUTOM_GUIA_ERP
--------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #73588: Criar Origem de Dados para ISS Retido para Guia de Pagamento
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   vn_fase number := 0;
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   -- 
   vn_fase := 1;
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add cod_receita VARCHAR2(10)');
   --
   vn_fase := 2;
   --
   pExec_Imed('comment on column CSF_OWN.PARAM_DET_GUIA_IMP.cod_receita is ''Esse campo será usado como parametro de preenchimento do GUIA_PGTO_IMP_COMPL_GEN.COD_RECEITA em impostos que não tem dados na TIPO_RET_IMP'';');
   --
   vn_fase := 3;
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP_COMPL_GEN add constraint GUIAPGTOIMPCOMPLGEN_UK unique (GUIAPGTOIMP_ID) using index tablespace CSF_INDEX');
   --
   commit;
   --   
exception
   when others then
      raise_application_error(-20001, 'Erro no script #73588 - Fase:. '||vn_fase||' Erro: ' || sqlerrm);
end;
/
--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #73588: Criar Origem de Dados para ISS Retido para Guia de Pagamento
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #75455: Erro ao gerar guia de INSS com base em Notas de serviço
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   vn_fase number := 0;
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   -- 
   vn_fase := 1;
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add notafiscal_id   number');
   -- 
   vn_fase := 2;
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add conhectransp_id number');
   -- 
   vn_fase := 3;
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.notafiscal_id   is ''ID relacionado com a tabela NOTA_FISCAL''');
   -- 
   vn_fase := 4;
   --
   pExec_Imed('comment on column CSF_OWN.GUIA_PGTO_IMP.conhectransp_id is ''ID relacionado com a tabela CONHEC_TRANSP''');
   -- 
   vn_fase := 5;
   --
   pExec_Imed('create index GUIAPGTOIMP_NOTAFISCAL_IX   on CSF_OWN.GUIA_PGTO_IMP (NOTAFISCAL_ID)   tablespace CSF_INDEX');
   -- 
   vn_fase := 6;
   --
   pExec_Imed('create index GUIAPGTOIMP_CONHECTRANSP_IX on CSF_OWN.GUIA_PGTO_IMP (CONHECTRANSP_ID) tablespace CSF_INDEX');
   -- 
   vn_fase := 7;
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_NOTAFISCAL_FK   foreign key (NOTAFISCAL_ID)   references CSF_OWN.NOTA_FISCAL   (ID)');
   -- 
   vn_fase := 8;
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP add constraint GUIAPGTOIMP_CONHECTRANSP_FK foreign key (CONHECTRANSP_ID) references CSF_OWN.CONHEC_TRANSP (ID)');
   --
   commit;         
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script #75455 - Fase:. '||vn_fase||' Erro: ' || sqlerrm);
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #75455: Erro ao gerar guia de INSS com base em Notas de serviço
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Início Redmine #76210: Alteração na apuração de ISS Simplificada para adequar à Apuração de ISS de outro municipio
--------------------------------------------------------------------------------------------------------------------------------------
declare
   --
   vn_fase number := 0;
   vv_sql  long;
   --
   procedure pExec_Imed(ev_sql long) is
   begin
      --
      begin
         execute immediate ev_sql;
      exception
         when others then
            null;
      end;      
      --
   end pExec_Imed;
   --
begin
   -- 
   vn_fase := 1;
   --
   vv_sql := '
      update CSF_OWN.DOMINIO d 
             set d.descr = ''Apuração de ISS Próprio''
      where d.dominio = ''GUIA_PGTO_IMP.DM_ORIGEM'' 
        and d.vl      = ''9''';
   --     
   pExec_Imed(vv_sql);
   --
   vn_fase := 2;
   --   
   pExec_Imed('call csf_own.pk_csf.pkb_cria_dominio(''GUIA_PGTO_IMP.DM_ORIGEM'', ''13'', ''Apuração de ISS Outros Municípios'')');
   --
   --   
   vn_fase := 3;
   --
   pExec_Imed('alter table CSF_OWN.GUIA_PGTO_IMP drop constraint GUIAPGTOIMP_ORIGEM_CK');
   --
   --
   vn_fase := 4;
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add constraint GUIAPGTOIMP_ORIGEM_CK check (DM_ORIGEM IN (1,2,3,4,5,6,7,8,9,10,11,12,13))');
   --
   -- 
   vn_fase := 5;
   --
   vv_sql := '
      update CSF_OWN.DOMINIO d 
             set d.descr = ''Apuração de ISS Próprio''
      where d.dominio = ''PARAM_DET_GUIA_IMP.DM_ORIGEM'' 
        and d.vl      = ''9''';
   --     
   pExec_Imed(vv_sql);
   --
   --
   vn_fase := 6;
   --   
   pExec_Imed('call csf_own.pk_csf.pkb_cria_dominio(''PARAM_DET_GUIA_IMP.DM_ORIGEM'', ''13'', ''Apuração de ISS Outros Municípios'')');
   --
   --
   vn_fase := 7;
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP drop constraint PDETGUIAIMP_DMORIGEM_CK');
   --
   --
   vn_fase := 8;
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add constraint PDETGUIAIMP_DMORIGEM_CK check (DM_ORIGEM IN (1,2,3,4,5,6,7,8,9,10,11,12,13))');
   --
   --
   vn_fase := 9;
   --
   pExec_Imed('alter table CSF_OWN.PARAM_DET_GUIA_IMP add constraint PARAMDETGUIAIMP_UK unique (PARAMGUIAPGTO_ID, TIPOIMP_ID, DM_TIPO, DM_ORIGEM, EMPRESA_ID_GUIA, TIPORETIMP_ID, TIPORETIMPRECEITA_ID, CIDADE_ID, COD_RECEITA) novalidate');
   --
   --
   commit;         
   --
exception
   when others then
      raise_application_error(-20001, 'Erro no script #75455 - Fase:. '||vn_fase||' Erro: ' || sqlerrm);
end;
/

--------------------------------------------------------------------------------------------------------------------------------------
Prompt Término Redmine #76210: Alteração na apuração de ISS Simplificada para adequar à Apuração de ISS de outro municipio
--------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
Prompt FIM Patch 2.9.6.3 - Alteracoes no CSF_OWN
------------------------------------------------------------------------------------------
