#!/bin/bash
DBNAME='gpadmin'
LASTDATE='2020-05-27'
PDATE=`date +%Y-%m-%d\ %H:%M:%S`
#echo "nohup bash /tmp/xunjian.sh >/tmp/xunjian.`date +%Y-%m-%d` 2>&1 &"
psql -d $DBNAME -Atc "SELECT DISTINCT hostname FROM pg_catalog.gp_segment_configuration;" > /tmp/gphostnames
psql -d $DBNAME -Atc "SELECT DISTINCT hostname FROM pg_catalog.gp_segment_configuration where content <> '-1';" > /tmp/gpseghostnames
mkdir -p /tmp/xunjian/
# 查看物理CPU个数
echo '#############################查看物理CPU个数'
gpssh -f /tmp/gphostnames cat /proc/cpuinfo| grep "physical id"| sort| uniq
echo '#############################查看物理CPU个数'
echo '#############################其中的physical id就是每个物理CPU的ID，能找到几个physical id就代表计算机实际有几个CPU'
echo ' '
echo ' '
echo ' '
echo ' '
#查看每个物理CPU中core的个数,即核数
echo \#############################查看每个物理CPU中core的个数,即核数
echo 其中的core id指的是每个物理CPU下的cpu核的id,能找到几个core id就代表计算机有几个核心
gpssh -f /tmp/gphostnames cat /proc/cpuinfo| grep "cpu cores"| uniq
echo \#############################查看每个物理CPU中core的个数,即核数
echo ' '
echo ' '
echo ' '
echo ' '
#查看逻辑CPU的个数
echo \#############################查看逻辑CPU的个数
echo 操作系统可以使用逻辑CPU来模拟出真实CPU的效果。
echo ' '
echo 在之前没有多核处理器的时候，一个CPU只有一个核，而现在有了多核技术，其效果就好像把多个CPU集中在一个CPU上。
echo ' '
echo 当计算机没有开启超线程时，逻辑CPU的个数就是计算机的核数。而当超线程开启后，逻辑CPU的个数是核数的两倍。
echo ' '
echo 实际上逻辑CPU的数量就是平时称呼的几核几线程中的线程数量，在linux的cpuinfo中逻辑CPU数就是processor的数量。
echo ' '
gpssh -f /tmp/gphostnames cat /proc/cpuinfo| grep "processor"
echo \#############################查看逻辑CPU的个数
echo ' '
echo ' '
echo ' '
echo ' '
#查看CPU信息（型号）
echo '#############################查看CPU信息（型号）'
gpssh -f /tmp/gphostnames cat /proc/cpuinfo | grep name  
echo '#############################查看CPU信息（型号）'
echo ' '
echo ' '
echo ' '
echo ' '


#查看内 存信息
echo '#############################查看内 存信息'
#gpssh -f /tmp/gphostnames cat /proc/meminfo|grep MemTotal
gpssh -f /tmp/gphostnames free -h
echo '#############################查看内 存信息'
echo ' '
echo ' '
echo ' '
echo ' '
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################hosts file discrepancy check'
gpssh -f /tmp/gphostnames  md5sum /etc/hosts;
echo '#############################hosts file discrepancy check'
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################Synchronization check'
gpssh -f /tmp/gphostnames date
echo '#############################Synchronization check'
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################System kernel version check'
gpssh -f /tmp/gphostnames uname -a
echo '#############################System kernel version check'
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################System version check'
gpssh -f /tmp/gphostnames cat /etc/redhat-release
echo '#############################System version check'
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################postgres version check'
psql -d postgres -c "select version();"
echo '#############################postgres version check'
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################GP version check'
psql -d postgres -c "select * from gp_version_at_initdb;"
echo '#############################GP version check'
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################Cluster health'
gpstate -e
echo '#############################Cluster health'
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################Log check'
find $MASTER_DATA_DIRECTORY/pg_log -newermt "$LASTDATE" ! -newermt "$PDATE" -type f | xargs cat | grep $DBNAME | grep FATAL|grep -v 'pg_hba.conf'
echo '#############################Log check'
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################DB_name view'
psql -d postgres -l
echo '#############################DB_name view'
echo ' '
echo ' '
echo ' '
echo ' '
echo '#############################master space usage view'
df -h
echo ''
echo ''
df -ih
echo '#############################master space usage view'
echo ''
echo ''
echo ''
echo ''
echo '#############################all hosts data space usage view'
gpssh -f /tmp/gphostnames df -h | grep data
echo '#############################all hosts data space usage view'
echo ''
echo ''
echo ''
echo ''


echo \#############################Mirror enabled
psql -d postgres -c "select * from gp_segment_configuration ;"
echo \#############################Mirror enabled
echo ''
echo ''
echo ''
echo ''
echo \#############################Standby Master check
gpstate -f
echo \#############################Standby Master check
echo ' '
echo ' '
echo ' '
echo ' '
echo \#############################Node downtime history check
psql -d $DBNAME -c "SELECT * FROM gp_configuration_history WHERE time > '$LASTDATE'::timestamp;"
echo \#############################Node downtime history check
echo ''
echo ''
echo ''
echo ''

echo \#############################gpcheck Parameter setting test
gpcheck -f /tmp/gphostnames
echo \#############################gpcheck Parameter setting test
echo ''
echo ''
echo ''
echo ''
echo \#############################GP Parameter checking
gpconfig -s max_connections
gpconfig -s max_connections
gpconfig -s max_prepared_transactions
gpconfig -s max_fsm_relations
gpconfig -s max_fsm_pages
gpconfig -s gp_vmem_protect_limit
gpconfig -s gp_interconnect_setup_timeout
gpconfig -s stats_queue_level
gpconfig -s work_mem
gpconfig -s gp_fault_action
echo \#############################GP Parameter checking
echo ''
echo ''
echo ''
echo ''
echo \#############################GP User information
psql -d $DBNAME -c "
SELECT 
     rolname, 
	   rolsuper, 
	   rolinherit, 
	   rolcreaterole, 
	   rolcanlogin, 
	   rolconnlimit, 
	   rolresqueue, 
	   oid 
FROM pg_catalog.pg_roles 
ORDER BY 8;
"
echo \#############################GP User information
echo ''
echo ''
echo ''
echo ''
echo \#############################Check the resource queue
psql -d $DBNAME -c "SELECT * FROM pg_resqueue;"
echo \#############################Check the resource queue
echo ''
echo ''
echo ''
echo ''
 
echo \#############################Check resource queue status
psql -d $DBNAME -c "SELECT * FROM pg_resqueue_status;"
echo \#############################Check resource queue status
echo ''
echo ''
echo ''
echo ''
echo \#############################Collect statistics, automatically skip the table with no change of Statistics
echo "您本次要执行全库统计信息更新吗?" 
echo "请执行：analyzedb -d $DBNAME"
echo \#############################Collect statistics, automatically skip the table with no change of Statistics
echo ''
echo ''
echo ''
echo ''
echo \#############################通过该视图显示出当前数据库需要进行analyze的表
psql -d $DBNAME -c " SELECT count(*) FROM gp_toolkit.gp_stats_missing WHERE smisize = 'f'; "
echo ''
echo ''
psql -d $DBNAME -c " SELECT smischema,count(*) FROM gp_toolkit.gp_stats_missing WHERE smisize = 'f' GROUP BY 1; "
echo \#############################通过该视图显示出当前数据库需要进行analyze的表
echo ''
echo ''
echo ''
echo ''
echo \#################################存储过程创建语句
>/tmp/plpythonun.sql
cat<<endof>>/tmp/plpythonun.sql
create  language plpythonu;

CREATE OR REPLACE FUNCTION gp_toolkit.gp_table_file_info() RETURNS SETOF VARCHAR[] AS \$\$
import os
_rslt = plpy.execute("""select current_database() dbname, inet_server_port() port;""")
(_dbname, _port) = (_rslt[0]["dbname"], _rslt[0]["port"])
_rslt = plpy.execute("""select oid,dattablespace from pg_database where datname = '%s';""" % (_dbname))
(_dboid, _dbspc) = (_rslt[0]["oid"], _rslt[0]["dattablespace"])
def getSqlValue(_sql):
    _utility = "PGOPTIONS='-c gp_session_role=utility' psql -v ON_ERROR_STOP=1"
    _cmd="""%s -d '%s' -p %s -tAXF '|' 2>&1 <<_END_OF_SQL
%s
_END_OF_SQL
""" % (_utility, _dbname, _port, _sql)
    try:
        val=os.popen(_cmd).read()
        return val.strip()
    except Exception, e:
        plpy.error(str(e))
_dftpath = getSqlValue("""show data_directory""") + "/base/" + _dboid + "/"
_rslt = plpy.execute("""select t.oid,trim(n.location_1)||'/'||t.oid||'/'||'%s'||'/' path
    from pg_tablespace t,pg_filespace f,gp_persistent_filespace_node n
    where t.spcfsoid = f.oid and f.oid = n.filespace_oid;""" % (_dboid))
_spcarray = []
_spcarray.append([1663, _dftpath])
for _row in _rslt:
    (_spcoid, _spcpath) = (_row["oid"], _row["path"])
    if not(os.path.exists(_spcpath)):
        continue
    if os.path.isfile(_spcpath):
        continue
    _spcarray.append([_spcoid, _spcpath])
_sizemap = {}
for _spcinfo in _spcarray:
    (_spcoid, _spcpath) = (_spcinfo[0], _spcinfo[1])
    _lscmd = """ls -lL --full-time %s|awk '{print \$9"\t"\$5"\t"\$6" "\$7}'|grep '^[0-9]'|sort -n""" % (_spcpath)
    _rslt = os.popen(_lscmd).read().strip()
    if _rslt == "":
        continue
    for _row in _rslt.split("\n"):
        (_relfile, _size, _time) = _row.split("\t")
        _relfile = _relfile.split(".")[0]
        _key = str(_spcoid) + "-" + _relfile
        if _sizemap.has_key(_key):
            _sizemap[_key] = [_sizemap[_key][0] + int(_size), _sizemap[_key][1] + 1, _sizemap[_key][2] + "\n" + _time]
        else:
            _sizemap[_key] = [int(_size),1,_time]
_rslt = plpy.execute("""select n.nspname,c.relname,c.reltablespace,c.relfilenode,c.relstorage
    from pg_class c, pg_namespace n where c.relnamespace = n.oid
    and c.relkind = 'r' and c.relstorage <> 'x' and c.reltablespace <> 1664 and not c.relhassubclass
    and n.nspname not like E'pg\_temp\_%' and n.nspname not like E'pg\_toast\_temp\_%';""")
for _row in _rslt:
    (_nspname, _relname, _relspc) = (_row["nspname"], _row["relname"], _row["reltablespace"])
    (_relfile, _storage) = ( _row["relfilenode"], _row["relstorage"])
    if _relspc == "0":
        _relspc = _dbspc
    _key = _relspc + "-" + _relfile
    if _sizemap.has_key(_key):
        if _storage == "h":
            yield (_nspname, _relname, _sizemap[_key][0], _sizemap[_key][1], _sizemap[_key][2])
        else:
            yield (_nspname, _relname, _sizemap[_key][0], _sizemap[_key][1], None)
    else:
        yield (_nspname, _relname, 0, 0, None)
\$\$ LANGUAGE PLPYTHONU;
endof
var_function=`psql -d gpadmin -Atc "\\df gp_toolkit.gp_table_file_info()"|wc -l`
if [ $var_function == 1 ];
then
  echo "已创建函数:"
else 
echo "需要创建函数"
psql -d $DBNAME -f /tmp/plpythonun.sql
fi
echo \#################################存储过程创建语句
echo ''
echo ''
echo ''
echo ''

echo \#############################数据倾斜情况
#psql -d $DBNAME -c"
#SELECT * FROM gp_toolkit.gp_skew_idle_fractions WHERE siffraction>=0.5 ORDER BY 4 desc;
psql -d $DBNAME -c "
select nspname, relname,maxsize/minsize as tableskew from (
select nspname, relname, tablesize, filecount, expectfilecount,
    filecount / expectfilecount filecountratio, minsize, maxsize, fileflag from (
    select size[1] as nspname, size[2] as relname,
        sum(size[3]::bigint) tablesize,string_agg(size[3],','), sum(size[4]::bigint) filecount,
        min(size[3]::bigint) minsize,
        max(size[3]::bigint) maxsize,
        md5(string_agg(size[5],E'\n' order by segment_id)) fileflag from (
        select gp_toolkit.gp_table_file_info() size, gp_segment_id segment_id from gp_dist_random('gp_id')
     ) x group by 1,2
) x left join (
    select nspname, relname, decode(relstorage, 'c', attcount, 1) * y.segs expectfilecount from (
        select nspname, relname, relstorage, count(*) attcount
        from pg_namespace n, pg_class c, pg_attribute a
        where n.oid = c.relnamespace and c.oid = a.attrelid
        and c.relkind = 'r' and c.relstorage <> 'x' and c.reltablespace <> 1664 and not c.relhassubclass
        and n.nspname not like E'pg\_temp\_%' and n.nspname not like E'pg\_toast\_temp\_%'
        group by 1,2,3
    ) x, (
        select count(*) as segs from gp_segment_configuration where role = 'p' and content <> -1
    ) y
) y using(nspname, relname) order by 6 desc
)ccc  where minsize > 0 order by maxsize/minsize desc limit 20;
" ;
echo \#############################数据倾斜情况
echo ''
echo ''
echo ''
echo ''
echo \#############################通过以下SQL语句，查询出当前膨胀较为严重的表的信息：
psql -d $DBNAME -c "
select ''||nspname||'.'||relname||';' as tablename,filecountratio  from (
select nspname, relname, tablesize, filecount, expectfilecount,
    filecount / expectfilecount filecountratio, minsize, maxsize, fileflag from (
    select size[1] as nspname, size[2] as relname,
        sum(size[3]::bigint) tablesize,string_agg(size[3],','), sum(size[4]::bigint) filecount,
        min(size[3]::bigint) minsize,
        max(size[3]::bigint) maxsize,
        md5(string_agg(size[5],E'\n' order by segment_id)) fileflag from (
        select gp_toolkit.gp_table_file_info() size, gp_segment_id segment_id from gp_dist_random('gp_id')
     ) x group by 1,2
) x left join (
    select nspname, relname, decode(relstorage, 'c', attcount, 1) * y.segs expectfilecount from (
        select nspname, relname, relstorage, count(*) attcount
        from pg_namespace n, pg_class c, pg_attribute a
        where n.oid = c.relnamespace and c.oid = a.attrelid
        and c.relkind = 'r' and c.relstorage <> 'x' and c.reltablespace <> 1664 and not c.relhassubclass
        and n.nspname not like E'pg\_temp\_%' and n.nspname not like E'pg\_toast\_temp\_%'
        group by 1,2,3
    ) x, (
        select count(*) as segs from gp_segment_configuration where role = 'p' and content <> -1
    ) y
) y using(nspname, relname) order by 6 desc
)ccc  order by filecountratio desc limit 1000;
";
psql -d $DBNAME -c "
SET client_min_messages = warning;
select 'vacuum analyze '||nspname||'.'||relname||';'  from (
select nspname, relname, tablesize, filecount, expectfilecount,
    filecount / expectfilecount filecountratio, minsize, maxsize, fileflag from (
    select size[1] as nspname, size[2] as relname,
        sum(size[3]::bigint) tablesize,string_agg(size[3],','), sum(size[4]::bigint) filecount,
        min(size[3]::bigint) minsize,
        max(size[3]::bigint) maxsize,
        md5(string_agg(size[5],E'\n' order by segment_id)) fileflag from (
        select gp_toolkit.gp_table_file_info() size, gp_segment_id segment_id from gp_dist_random('gp_id')
     ) x group by 1,2
) x left join (
    select nspname, relname, decode(relstorage, 'c', attcount, 1) * y.segs expectfilecount from (
        select nspname, relname, relstorage, count(*) attcount
        from pg_namespace n, pg_class c, pg_attribute a
        where n.oid = c.relnamespace and c.oid = a.attrelid
        and c.relkind = 'r' and c.relstorage <> 'x' and c.reltablespace <> 1664 and not c.relhassubclass
        and n.nspname not like E'pg\_temp\_%' and n.nspname not like E'pg\_toast\_temp\_%'
        group by 1,2,3
    ) x, (
        select count(*) as segs from gp_segment_configuration where role = 'p' and content <> -1
    ) y
) y using(nspname, relname) order by 6 desc
)ccc  where  filecountratio > 3 order by filecountratio desc;
" > /tmp/xunjian/filecountratio_vacuum.sql
echo \#############################通过以下SQL语句，查询出当前膨胀较为严重表的信息：
echo ''
echo ''
echo ''
echo ''
echo \############################# 前20张大表检查通过以下分析语句，显示出当前数据库表大小
echo \#############################（即实际的磁盘页面占用数量超过预定的页面占用数量）：
psql -d $DBNAME -c "
/*
SELECT tabs.nspname AS schema_name,
COALESCE(parts.tablename, tabs.relname) AS table_name,
ROUND(SUM(sotaidtablesize) / 1024 / 1024, 3) AS table_MB,
ROUND(SUM(sotaidtablesize) / 1024 / 1024 / 1024, 3) AS table_GB,
ROUND(SUM(sotaididxsize) / 1024 / 1024 / 1024, 3) AS index_GB,
ROUND(SUM(sotaididxsize) / 1024 / 1024, 3) AS index_MB
FROM gp_toolkit.gp_size_of_table_and_indexes_disk sotd, (select c.oid, c.relname, n.nspname from pg_class c,
pg_namespace n where n.oid = c.relnamespace and c.relname not like '%_err') tabs
LEFT JOIN pg_partitions parts ON tabs.nspname = parts.schemaname AND tabs.relname = parts.partitiontablename where sotd .sotaidoid = tabs.oid
GROUP BY tabs.nspname, COALESCE(parts.tablename, tabs.relname)
having ROUND(SUM(sotaidtablesize) / 1024 / 1024 / 1024, 3) > 3
ORDER by 4 desc limit 20;
*/
select ''||nspname||'.'||relname||';' ,round(tablesize::NUMERIC/1024/1024/1024)||'GB' as tablesize_ from (
select nspname, relname, tablesize, filecount, expectfilecount,
    filecount / expectfilecount filecountratio, minsize, maxsize, fileflag from (
    select size[1] as nspname, size[2] as relname,
        sum(size[3]::bigint) tablesize,string_agg(size[3],','), sum(size[4]::bigint) filecount,
        min(size[3]::bigint) minsize,
        max(size[3]::bigint) maxsize,
        md5(string_agg(size[5],E'\n' order by segment_id)) fileflag from (
        select gp_toolkit.gp_table_file_info() size, gp_segment_id segment_id from gp_dist_random('gp_id')
     ) x group by 1,2
) x left join (
    select nspname, relname, decode(relstorage, 'c', attcount, 1) * y.segs expectfilecount from (
        select nspname, relname, relstorage, count(*) attcount
        from pg_namespace n, pg_class c, pg_attribute a
        where n.oid = c.relnamespace and c.oid = a.attrelid
        and c.relkind = 'r' and c.relstorage <> 'x' and c.reltablespace <> 1664 and not c.relhassubclass
        and n.nspname not like E'pg\_temp\_%' and n.nspname not like E'pg\_toast\_temp\_%'
        group by 1,2,3
    ) x, (
        select count(*) as segs from gp_segment_configuration where role = 'p' and content <> -1
    ) y
) y using(nspname, relname) order by 6 desc
)ccc   order by tablesize desc limit 20;
" ;


psql -d $DBNAME -Atc "
select ''||nspname||'.'||relname||';' ,round(tablesize::NUMERIC/1024/1024/1024)||'GB' as tablesize_ from (
select nspname, relname, tablesize, filecount, expectfilecount,
    filecount / expectfilecount filecountratio, minsize, maxsize, fileflag from (
    select size[1] as nspname, size[2] as relname,
        sum(size[3]::bigint) tablesize,string_agg(size[3],','), sum(size[4]::bigint) filecount,
        min(size[3]::bigint) minsize,
        max(size[3]::bigint) maxsize,
        md5(string_agg(size[5],E'\n' order by segment_id)) fileflag from (
        select gp_toolkit.gp_table_file_info() size, gp_segment_id segment_id from gp_dist_random('gp_id')
     ) x group by 1,2
) x left join (
    select nspname, relname, decode(relstorage, 'c', attcount, 1) * y.segs expectfilecount from (
        select nspname, relname, relstorage, count(*) attcount
        from pg_namespace n, pg_class c, pg_attribute a
        where n.oid = c.relnamespace and c.oid = a.attrelid
        and c.relkind = 'r' and c.relstorage <> 'x' and c.reltablespace <> 1664 and not c.relhassubclass
        and n.nspname not like E'pg\_temp\_%' and n.nspname not like E'pg\_toast\_temp\_%'
        group by 1,2,3
    ) x, (
        select count(*) as segs from gp_segment_configuration where role = 'p' and content <> -1
    ) y
) y using(nspname, relname) order by 6 desc
)ccc   order by tablesize desc limit 20;
" > /tmp/xunjian/big20table.sql

echo \############################# 前20张检查通过以下分析语句，显示出当前数据库表大小
echo \#############################（即实际的磁盘页面占用数量超过预定的页面占用数量）：
echo ''
echo ''
echo ''
echo ''
echo \#############################系统表膨胀检查
psql -d $DBNAME -c "SELECT pg_size_pretty(pg_total_relation_size('pg_attribute'));"
psql -d $DBNAME -c "SELECT pg_size_pretty(pg_relation_size('pg_attribute'));"
psql -d $DBNAME -c "SELECT count(*) FROM pg_attribute;"
psql -d $DBNAME -c "SELECT pg_size_pretty(pg_relation_size('pg_class'));"
psql -d $DBNAME -c "SELECT count(*) FROM pg_class;"
echo \#############################系统表膨胀检查
echo ''
echo ''
echo ''
echo ''
echo \#############################表类型检查
psql -d $DBNAME -c "SELECT relstorage,count(*) FROM pg_class WHERE relkind ='r' GROUP BY 1 ORDER BY 2;"
echo \#############################表类型检查
echo ''
echo ''
echo ''
echo ''
echo \#############################默认分区检查
#psql -d $DBNAME -c "
#select 'select count(*) from '||partitionschemaname||'.'||partitiontablename||';' from pg_partitions
#where partitionisdefault=true;
#"
psql -d $DBNAME -Atc "SELECT '\"SELECT count(*) FROM '||partitionschemaname||'.'||partitiontablename||';\"' FROM pg_partitions WHERE partitionisdefault=true;" | xargs -i psql -d $DBNAME -ec {}
echo \#############################默认分区检查
echo ''
echo ''
echo ''
echo ''

echo \#############################磁盘速度检查
echo "您要执行磁盘速度测试吗？将写两倍内存到对应磁盘目录下"
echo "gpcheckperf -f /tmp/gpseghostnames  -r ds -D -d /tmp -d /tmp"
echo \#############################磁盘速度检查
echo ''
echo ''
echo ''
echo ''

echo \#############################网络检查
echo "您要执行网络速度测试吗?很快"
echo "gpcheckperf  -f /tmp/gphostnames -r N -d /tmp"
echo \#############################网络检查
echo ''
echo ''
echo ''
echo ''

echo \#################################前100个大sql，耗时排序
var_version=`psql -d gpperfmon -Atc "select substr(version(),position('base' in version())+5,1);"`
if [ $var_version == 4 ];
then
     echo "GP4版本"
psql -d gpperfmon -c "
select trunc(extract(epoch FROM (tfinish-tstart))::numeric/60/60,2)||'(h)' as duration ,tfinish,tstart,query_text from public.queries_history where tstart is not null order by duration desc limit 100;
";
psql -d gpperfmon -c "
select trunc(extract(epoch FROM (tfinish-tstart))::numeric/60/60,2)||'(h)' as duration ,tfinish,tstart,query_text from public.queries_history where tstart is not null order by duration desc limit 100;
" >> /tmp/xunjian/xunjian_timetop100sql.txt
else 
      echo "GP5版本"
psql -d gpperfmon -c "
select trunc(extract(epoch FROM (tfinish-tstart))::numeric/60/60,2)||'(h)' as duration ,tfinish,tstart,query_text from gpmetrics.queries_history where tstart is not null order by duration desc limit 100;
";
psql -d gpperfmon -c "
select trunc(extract(epoch FROM (tfinish-tstart))::numeric/60/60,2)||'(h)' as duration ,tfinish,tstart,query_text from gpmetrics.queries_history where tstart is not null order by duration desc limit 100;
" >> /tmp/xunjian/xunjian_timetop100sql.txt
fi
echo \#################################前100个大sql，耗时排序
echo ''
echo ''
echo ''
echo ''

echo \#################################当前锁状态
psql -d $DBNAME -c "
select locktype, database, c.relname, l.relation, l.transactionid,  l.pid, l.mode, l.granted, a.current_query 
from pg_locks l, pg_class c, pg_stat_activity a where l.relation=c.oid and l.pid=a.procpid order by c.relname;
";
psql -d $DBNAME -c "
select locktype, database, c.relname, l.relation, l.transactionid,  l.pid, l.mode, l.granted, a.current_query 
from pg_locks l, pg_class c, pg_stat_activity a where l.relation=c.oid and l.pid=a.procpid order by c.relname; ;
" > /tmp/xunjian/xunjian_lock.txt
echo \#################################当前锁状态
echo ''
echo ''
echo ''
echo ''



echo \#################################用户所占资源级别，及用户资源组级别
psql -d $DBNAME -c "
SELECT * FROM gp_toolkit.gp_resgroup_config;
";
echo \#################################用户所占资源级别，及用户资源组级别
echo ''
echo ''
echo ''
echo ''


echo \#################################资源组与用户的对应关系
psql -d $DBNAME -c "
SELECT rolname, rsgname FROM pg_roles, pg_resgroup
     WHERE pg_roles.rolresgroup=pg_resgroup.oid;
";
echo \#################################资源组与用户的对应关系
echo ''
echo ''
echo ''
echo ''



echo \#################################当前活动语句的状态，及所属资源组
psql -d $DBNAME -c "
SELECT current_query, waiting, rsgname, rsgqueueduration
     FROM pg_stat_activity;
";
psql -d $DBNAME -c "
select * FROM pg_stat_activity;
";


echo \#################################当前活动语句的状态，及所属资源组
echo ''
echo ''
echo ''
echo ''


echo \#################################资源组与锁与当前sql的关联
psql -d $DBNAME -c "
SELECT rolname, g.rsgname, procpid, waiting, current_query, datname
     FROM pg_roles, gp_toolkit.gp_resgroup_status g, pg_stat_activity
     WHERE pg_roles.rolresgroup=g.groupid
        AND pg_stat_activity.usename=pg_roles.rolname;
";
echo \#################################资源组与锁与当前sql的关联
echo ''
echo ''
echo ''
echo ''


#命令帮助样例
echo '#############################命令帮助样例'
echo "\h alter table;"
echo '#############################命令帮助样例'
echo ' '
echo ' '
echo ' '
echo ' '
echo \#############################Node downtime history check
psql -d $DBNAME -c "SHOW ALL;" > /tmp/xunjian/gpconfig.txt
echo \#############################Node downtime history check
echo ''
echo ''
echo ''
echo ''

echo \#############################单个sql可以使用的初始分配内存,和可用最大内存
psql -d $DBNAME -c "SHOW ALL;"|grep statement_mem 
echo \#############################单个sql可以使用的初始分配内存,和可用最大内存
echo ''
echo ''
echo ''
echo ''

echo \#############################单个sql可以使用的初始分配内存,和可用最大内存
psql -d $DBNAME -c "SHOW ALL;"|grep gp_vmem_protect_limit 
echo \#############################单个sql可以使用的初始分配内存,和可用最大内存
echo ''
echo ''
echo ''
echo ''

echo \#############################linux内存最大可提交比例
more /etc/sysctl.conf |grep vm.overcommit_ratio|grep -v more
more /proc/sys/vm/overcommit_ratio
echo \#############################linux内存最大可提交比例
echo ''
echo ''
echo ''
echo ''

#psql -d $DBNAME -c "SHOW ALL;"|grep max_statement_mem |awk {print'$3'}
echo \#############################每个查询最多可以使用MB 内存
echo 每个查询最多可以使用MB 内存，之后将溢出到磁盘。 
echo ''
echo 若想安全的增大 gp_statement_mem，要么增大 gp_vmem_protect_limit，要么降低并发。
echo '' 
echo 要增大 gp_vmem_protect_limit，必须增加物理内存和/或交换空间，或者降低单个主机上运行的段数据库个数。 
echo '' 
echo 请注意，为集群添加更多的段数据库实例并不能解决内存不足的问题，除非引入更多新主机来降低了单个主机上运行的段数据库的个数。
echo ''
gp_vmem_protect_limit=`psql -d $DBNAME -c "SHOW ALL;"|grep gp_vmem_protect_limit|awk {print'\$3'}`
overcommit_ratio=`more /etc/sysctl.conf |grep vm.overcommit_ratio|grep -v more|awk {print'\$3'}`
max_expected_concurrent_queries=4
rt="psql -d $DBNAME -Atc \"select round($gp_vmem_protect_limit*$overcommit_ratio*0.01/$max_expected_concurrent_queries,0)\""
echo 请执行一下语句：
echo $rt
echo \#############################每个查询最多可以使用MB 内存
echo ''
echo ''
echo ''
echo ''


