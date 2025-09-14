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