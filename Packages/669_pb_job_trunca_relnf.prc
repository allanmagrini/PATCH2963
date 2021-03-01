create or replace procedure csf_own.pb_job_trunca_relnf(ev_insert_del in varchar2 ) is
   --
   ------------------------------------------------------------------------------------------------------------------
   -- Em 24/02/2021  - Wendel Albino - Patch 295-5/ 296-2 / release 297
   -- Redmine #76535 - Incluir tabela rel_resumo_cfop para limpeza.
   -- incluida a limpeza da tabela REL_RESUMO_CFOP na procedure.
   --
   -- Em 15/02/2021  - Wendel Albino - Patch 295-5/ 296-2 / release 297
   -- Redmine #75908 - Extrema lentidão para geração do resumo de documentos fiscais
   -- Criacao procedure que cria ou apaga job scheduler para limpar a tabela rel_nf a cada semana
   -- PARAMETRO ev_insert_del : se o parametro for 'I' o job_scheduler será criado, se for 'D' os jobs serão apagados
   ------------------------------------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------------------------------------
   --
   vn_fase         number;
   vv_sql          varchar2(4000);
   vv_sql2         varchar2(4000);
   vn_qtde_job     number := 0 ;
   dt_exec         varchar2(50) := to_char(sysdate,'dd/mm/rrrr hh24:mi:ss');
   vv_job_name     varchar2(100)  := 'TRUNCATE_RELNF';
   vv_frequencia   varchar2(4000) := 'FREQ=DAILY;INTERVAL=2;BYHOUR=00;' ;
   --vv_frequencia   varchar2(4000) := 'Freq=Minutely;ByDay=Mon, Tue, Wed, Thu, Fri;ByHour=00, 06, 07, 08, 09, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23;ByMinute= 42,45,48,50,52;';
   --
   --
begin
  --
  vn_fase := 1;
  --
  if upper(ev_insert_del) = UPPER('I')  then
    --
    vn_fase     := 2;
    --
    begin
      --
      select count(1)
        into vn_qtde_job
        from user_scheduler_jobs
       where job_name = vv_job_name ;
    exception
      when others then
        raise_application_error(-20001, 'FALHA AO EXCUTAR O DBMS_SCHEDULER.DROP_JOB(' ||vv_job_name || '), ERRO:' || sqlerrm);
    end;
    --
    vn_fase := 3;
    --
    if vn_qtde_job = 0 then
      --
	  ----------------------------------------------
	  -- LIMPA As TABELAs REL_NF, REL_RESUMO_CFOP
	  ----------------------------------------------
      vn_fase := 4;
      vv_sql := null;
      --
      vv_sql := vv_sql || 'BEGIN ';
      vv_sql := vv_sql || ' DBMS_SCHEDULER.CREATE_JOB ( ';
      vv_sql := vv_sql || '   job_name        => ' || '''' || vv_job_name || '''';
      vv_sql := vv_sql || ' , job_type        => ' || '''' ||'PLSQL_BLOCK'|| '''';
      vv_sql := vv_sql || ' , job_action      => ' || '''' ||'begin execute immediate ''''TRUNCATE TABLE CSF_OWN.REL_NF''''; '
                                                                ||' execute immediate ''''TRUNCATE TABLE CSF_OWN.REL_RESUMO_CFOP''''; '
                                                           ||'end;'|| '''';
      vv_sql := vv_sql || ' , start_date      => ' || 'to_date(''' || dt_exec || ''' ,''dd/mm/rrrr hh24:mi:ss'')';
      vv_sql := vv_sql || ' , repeat_interval => ' || '''' || vv_frequencia || '''';
      VV_SQL := VV_SQL || ' , auto_drop       =>  false ';
      VV_SQL := VV_SQL || ' , enabled         =>  true); ';
      VV_SQL := VV_SQL || ' end;';
      --
      vn_fase := 5;
      --
      begin
        execute immediate vv_sql;
          exception
        when others then
          raise_application_error(-20101, 'PROBLEMAS AO CRIAR JOB EM PB_JOB_TRUNCA_RELNF:' || sqlerrm);
      end;
      --
      vn_fase := 6;
      --
      commit;
      --
    end if;
    --
  elsif upper(ev_insert_del) = UPPER('D') then
    --
    vv_sql2 := NULL ;
    --
    vn_fase := 10;
    --
    begin
      --
      select count(1)
        into vn_qtde_job
        from user_scheduler_jobs
       where job_name = vv_job_name
         and state <> 'running';
      --
      if vn_qtde_job > 0 then
        --
		vn_fase := 11;
		--
        begin
          vv_sql2 := 'begin dbms_scheduler.stop_job(job_name =>''' ||vv_job_name|| ''' ); end;';
          execute immediate vv_sql;
        exception
          when others then
            null;
        end;
        --
		vn_fase := 12;
		--
        begin
          vv_sql := 'begin dbms_scheduler.drop_job(job_name =>''' ||vv_job_name|| ''' ); end;';
          execute immediate vv_sql;
        exception
          when others then
            raise_application_error(-20060, 'por favor execute o processo novamente pois existe job em execução!! ' || sqlerrm);
        end;
      end if;
      --
    exception
      when others then
        raise_application_error(-20102,
                                'falha ao excutar o dbms_scheduler.drop_job(' ||vv_job_name|| '), erro: ' || sqlerrm);
    end;
    --
    COMMIT;
    --
	vn_fase := 13;
	--
  else
    null; -- não fazer nada.
  end if;
  --
exception
  when others then
    raise_application_error(-20103, 'problemas em PB_JOB_TRUNCA_RELNF:' ||  sqlerrm);
end pb_job_trunca_relnf;
/