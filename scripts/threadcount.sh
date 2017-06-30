ps huH p `ps aux|grep java|grep -v grep|awk '{print $2}'`|wc -l
