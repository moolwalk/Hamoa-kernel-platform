RELEASE_TAG=r00019.2
NH_PROP_TREE=$(dirname "$(realpath "$0")")/kernel_platform

mkdir -p "$NH_PROP_TREE"
git clone -b $RELEASE_TAG --depth 1 https://qpm-git.qualcomm.com/home2/git/samsung-electronics/hamoa-la-1-0_ap_standard_oem.git
