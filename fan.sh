#!/bin/sh


#设置运行状态文件
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#####配置文件部分#####
#设置风扇默认运行模式，1为全速，2为自动，运行过程中可以直接修改此文件来生效
MODE=2
#风扇控制针脚
set_control_pin=1

#设置开启风扇的最低温度
set_temp_min=25000
#设置风扇全速运行的温度
set_temp_max=36000
#设置风扇停止温度
set_temp_stop=20000

#设置最低转速时的pwm值
set_pwm_min=820
#设置最高转速时的pwm值
set_pwm_max=1023
#设置0转速时的pwm值
set_pwm_stop=0

#####配置文件部分#####

#开机风扇全速运行
gpio mode $set_control_pin pwm
gpio pwm $set_control_pin $set_pwm_max
sleep 4

run=0
#while 循环保持一直执行
while true
do
    #查询温度和负载
    tmp=`cat /sys/class/thermal/thermal_zone0/temp`
    load=`cat /proc/loadavg | awk '{print $1,$2,$3}'`

    #根据温度计算 pwm 值
    pwm=$((($tmp-$set_temp_min)*($set_pwm_max-$set_pwm_min)/($set_temp_max-$set_temp_min)+$set_pwm_min))
    if [ $pwm -le $set_pwm_min ] ;then
        pwm=$set_pwm_stop
    fi
    #设置pwm值上限
    if [ 1 -eq $MODE ] || [ $pwm -gt $set_pwm_max ] ;then
        run=1
        pwm=$set_pwm_max
    fi

    #当 智能模式 且 停转状态下启动风扇条件，全速启动风扇
    if [ 2 -eq $MODE ] && [ $tmp -gt $set_temp_min ] && [ 0 -eq $run ] ; then
        gpio pwm 1 $set_pwm_max
        run=1
        echo "`date "+%Y-%m-%d %H:%M:%S"` temp=$tmp pwm=$set_pwm_max MODE=$MODE CPU load=$load 到达启动风扇温度，满速启动风扇"
        sleep 2
    fi

    # 停止风扇
    if [ 0 -eq $run ]; then
        pwm=0
    fi

    #停止风扇运行
    if [ $MODE -eq 2 ] && [ $tmp -le $set_temp_stop ] && [ 1 -eq run ] ;then
        run=0
        gpio mode 1 pwm
        gpio pwm 1 $pwm
        echo "`date "+%Y-%m-%d %H:%M:%S"` temp=$tmp pwm=$pwm MODE=$MODE CPU load=$load 到达关闭风扇温度，停止风扇 "
    else
        gpio mode 1 pwm
        gpio pwm 1 $pwm
    fi
    awk=`cat /proc/loadavg | awk '{print $1,$2,$3}'`
    temp=`cat /sys/class/thermal/thermal_zone0/temp | awk '{print "CPU Temp:"(int($0) / 1000)}'`
    echo "`date "+%Y-%m-%d %H:%M:%S"` $loadavg $awk $temp "
    sleep 2
done