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