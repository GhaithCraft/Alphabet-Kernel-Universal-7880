#!/system/bin/sh
# 
# Init MoRoKernel
#

# $BB 
if [ -e /su/xbin/$BB ]; then
	BB=/su/xbin/$BB;
else if [ -e /sbin/$BB ]; then
	BB=/sbin/$BB;
else
	BB=/system/xbin/$BB;
fi;
fi;

# Define logfile path
MORO_LOGFILE="/data/moro-kernel.log"

# maintain log file history
$BB rm $MORO_LOGFILE.3
$BB mv $MORO_LOGFILE.2 $MORO_LOGFILE.3
$BB mv $MORO_LOGFILE.1 $MORO_LOGFILE.2
$BB mv $MORO_LOGFILE $MORO_LOGFILE.1

# Initialize the log file (chmod to make it readable also via /sdcard link)
$BB echo $(date) "MoRo-Kernel initialisation started" > $MORO_LOGFILE
$BB chmod 777 $MORO_LOGFILE
$BB cat /proc/version >> $MORO_LOGFILE
$BB echo "=========================" >> $MORO_LOGFILE
$BB grep ro.build.version /system/build.prop >> $MORO_LOGFILE
$BB echo "=========================" >> $MORO_LOGFILE


# Mount
$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,rw /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,rw /;

#-------------------------
# FAKE KNOX 0
#-------------------------

/sbin/resetprop -v -n ro.boot.warranty_bit "0"
/sbin/resetprop -v -n ro.warranty_bit "0"
$BB echo $(date) "Enabled Fake Knox 0" >> $MORO_LOGFILE


#-------------------------
# FLAGS FOR SAFETYNET
#-------------------------

/sbin/resetprop -n ro.boot.veritymode "enforcing"
/sbin/resetprop -n ro.boot.verifiedbootstate "green"
/sbin/resetprop -n ro.boot.flash.locked "1"
/sbin/resetprop -n ro.boot.ddrinfo "00000001"
$BB echo $(date) "Enabled Flags for safety net" >> $MORO_LOGFILE


#-------------------------
# TWEAKS
#-------------------------

    # Speed
    $BB echo "0" > /sys/module/lowmemorykiller/parameters/debug_level;
    $BB echo "0" > $parameter/parameters/debug_mask;
    $BB echo "NO_AFFINE_WAKEUPS " > /sys/kernel/debug/sched_features
    $BB echo "ARCH_POWER " >> /sys/kernel/debug/sched_features
    $BB echo "CACHE_HOT_BUDDY " >> /sys/kernel/debug/sched_features
    $BB echo "NO_DOUBLE_TICK " >> /sys/kernel/debug/sched_features
    $BB echo "NO_FORCE_SD_OVERLAP " >> /sys/kernel/debug/sched_features
    $BB echo "GENTLE_FAIR_SLEEPERS " >> /sys/kernel/debug/sched_features
    $BB echo "NO_HRTICK " >> /sys/kernel/debug/sched_features
    $BB echo "LAST_BUDDY " >> /sys/kernel/debug/sched_features
    $BB echo "LB_BIAS " >> /sys/kernel/debug/sched_features
    $BB echo "NO_LB_MIN " >> /sys/kernel/debug/sched_features
    $BB echo "NO_NEW_FAIR_SLEEPERS " >> /sys/kernel/debug/sched_features
    $BB echo "NO_NEXT_BUDDY " >> /sys/kernel/debug/sched_features
    $BB echo "NONTASK_POWER " >> /sys/kernel/debug/sched_features
    $BB echo "NO_NORMALIZED_SLEEPERS " >> /sys/kernel/debug/sched_features
    $BB echo "NO_OWNER_SPIN " >> /sys/kernel/debug/sched_features
    $BB echo "RT_RUNTIME_SHARE " >> /sys/kernel/debug/sched_features
    $BB echo "START_DEBIT " >> /sys/kernel/debug/sched_features
    $BB echo "TTWU_QUEUE " >> /sys/kernel/debug/sched_features
    $BB echo "NO_WAKEUP_OVERLAP " >> /sys/kernel/debug/sched_feature
    $BB echo "WAKEUP_PREEMPTION " >> /sys/kernel/debug/sched_features
    $BB killall -9 com.google.android.gms
    $BB killall -9 com.google.android.gms.persistent
    $BB killall -9 com.google.process.gapps
    $BB killall -9 com.google.android.gsf
    $BB killall -9 com.google.android.gsf.persistent


$BB echo $(date) "Enabled tweaks" >> $MORO_LOGFILE


#-------------------------
# KERNEL INIT VALUES
#-------------------------

    


#-------------------------


# Unmount
$BB mount -t rootfs -o remount,ro rootfs;
$BB mount -o remount,ro /system;
$BB mount -o remount,rw /data;
$BB mount -o remount,ro /;
