# set -xe
function arrange_dual_screen() {
	local EXT_SCREEN=`displayplacer list | grep -B2 "external screen" | sed -nr "s/Persistent screen id: ([A-Z0-9-]+)/\1/p"`
	displayplacer "id:$EXT_SCREEN res:3840x2160 scaling:off origin:(-932,-2160) degree:0"
}
swap_screens=$1

count_monitor=$(displayplacer list|grep "external"|wc -l)

if [ $count_monitor == 1 ]
then
    arrange_dual_screen
fi


if [ $count_monitor == 2 ]
then
    c=1
    for eid in `displayplacer list|grep external -B2|grep Persistent|awk '{print $4}'`
    do
        export eid${c}=$eid
        let c=c+1
    done
    
    if [ ! -z $swap_screens ]
    then
        id1=$eid2
        id2=$eid1
    else
        id1=$eid1
        id2=$eid2
    fi
    displayplacer  "id:${id1} res:3840x2160 hz:60 color_depth:4 scaling:off origin:(-2978,-2160) degree:0" "id:${id2} res:3840x2160 hz:60 color_depth:4 scaling:off origin:(862,-2160) degree:0"
fi
