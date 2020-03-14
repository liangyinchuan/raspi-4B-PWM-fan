# raspi-4B-PWM-fan
树莓派4B 根据cpu温度控制风扇散热速率快慢


在网上查阅了很多这样的案例，但是大多是设计方案，没有实例，好多设计看起来也不太理想，所以自己动手实践了一下，如果能帮助到你，希望点击一个【 Star 】


## 一、开发材料
	1. 树莓派4B （我的是4B）
	2. 5V 双风扇
	3. NPN 型三极管 我买的是 S8050
	4. 杜邦线公对母
	5. 电烙铁
	6. 焊锡丝少许

## 二、硬件DIY连接
	1. 风扇负极焊接在三极管集电极上
	2. 风扇正极直连 5V 引脚（5V）
	3. 三极管发射极连接在树莓派接地引脚（0V）
	4. 三极管基极连接树莓派 GPIO.1 引脚（PWM 控制引脚）

## 三、程序部分（详细移步代码，这里只对配置项做说明）
```
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
```

PWM控制针脚设置和温度部分应该很好理解，这里说明一下 set_pwm_min ，由于不同风扇规格不同，启动电流和电压区别也很大，我的风扇需要将 pwm 值设置到800，风扇才能维持运行（一个转一个歇着。。。），820时才都运行，所以有使用该方案的，需要根据具体风扇进行调节

## 四、程序运行
```
##安装代码
git clone https://github.com/liangyinchuan/raspi-4B-PWM-fan.git

##脚本赋予执行权限
cd raspi-4B-PWM-fan && sudo chmod 755 fan.sh

##调试运行（注意：日志文件需要提前创建下）
sudo ~/fan.sh >> /home/pi/log/fan.log

##调试代码正常无误后 添加开机自启
sudo vim /etc/rc.local

##在 exit 前添加如下命令：
sudo /home/pi/fan.sh >> /home/pi/log/fan.log

##重启 pi4
sudo init 6

##注：本程序使用C语言编写的wiringPi库，树莓派没有安装的，请预先安装，具体安装命令如下：
sudo apt-get install git-core gcc automake autoconf libtool make
git clone git://git.drogon.net/wiringPi
cd wiringPi
git pull origin
./build
gpio -v
##最后一条命令 查看库版本，测试是否安装成功
```
