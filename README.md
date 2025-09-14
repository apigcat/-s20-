------------------------------------------------------------------------
[1]  samsung -s20-batter_control.sh
------------------------------------------------------------------------
主要是由于手机自带的过充保护不太实用，所以写了这个脚本
电量≥98%，停止充电
电量≤88%，开始充电
------------------------------------------------------------------------
#!/system/bin/sh
interval=60  # 检查间隔（秒）

while true; do
    s=$(cat /sys/class/power_supply/battery/capacity)  # 读取电量
    b=98  # 停止充电阈值
    c=88  # 开始充电阈值

    if [ "$s" -ge "$b" ]; then
        echo 1 > /sys/class/power_supply/battery/batt_slate_mode  # 电量≥98%，停止充电
    elif [ "$s" -le "$c" ]; then
        echo 0 > /sys/class/power_supply/battery/batt_slate_mode  # 电量≤88%，开始充电
    fi

    sleep "$interval"  # 等待60秒后再次检查
done
---------------------------------------------------------------------------
[2]  samsung -s20-batter_save.sh
---------------------------------------------------------------------------
主要是由于手机锁屏自动开启省电模式降低CPU频率达到省电，所以写了这个脚本
息屏后等待10秒 → 开省电（1）
# - 亮屏后等待10秒 → 关省电（0）
---------------------------------------------------------------------------
#!/system/bin/sh
# 功能：
# - 亮屏后等待10秒 → 关省电（0）
# - 息屏后等待10秒 → 开省电（1）

i=5    # 检测间隔（秒）
d=15   # 延迟时间（秒）

# 获取屏幕状态（1=亮屏，0=息屏）
s() {
    dumpsys power 2>/dev/null | grep -q "mWakefulness=Awake" && echo 1 || echo 0
}

# 设置省电模式（1=开，0=关）
p() {
    settings put global low_power "$1" 2>/dev/null
}

# 主循环
n=$(s)  # 当前状态
l=$n    # 上次状态
t=$(date +%s)  # 状态变更时间

while true; do
    n=$(s)
    c=$(date +%s)
    e=$((c - t))

    # 状态变化时重置计时
    if [ "$n" != "$l" ]; then
        l=$n
        t=$c
        sleep $i
        continue
    fi

    # 超时后切换
    if [ $e -ge $d ]; then
        p $((1 - n))  # 取反：亮屏→关省电（0），息屏→开省电（1）
    fi

    sleep $i
done
