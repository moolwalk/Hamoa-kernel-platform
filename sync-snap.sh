NH_PROP_TREE=$(pwd)
KERNEL_WORKSPACE_PATH=$NH_PROP_TREE/kernel_platform

pushd $NH_PROP_TREE/hamoa-la-1-0_ap_standard_oem/COMPUTE.LA.1.0/LINUX/android
./sync_snap_v2.sh --prop_opt=chipcode_hf --tree_type=KERNEL.PLATFORM.5.0.r32 --workspace_path=$KERNEL_WORKSPACE_PATH --snap_release=$NH_PROP_TREE/hamoa-la-1-0_ap_standard_oem/COMPUTE.LA.1.0/LINUX/android/snap_release.xml --chipcode_customer_id=jy.ahn@samsung.com
popd