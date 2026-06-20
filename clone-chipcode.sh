RELEASE_TAG=r00019.2
BARE_CLONE=--bare
NH_PROP_TREE=$(dirname "$(realpath "$0")")/kernel_platform

mkdir -p "$NH_PROP_TREE"
git clone -b $RELEASE_TAG  $BARE_CLONE https://qpm-git.qualcomm.com/home2/git/samsung-electronics/hamoa-la-1-0_ap_standard_oem.git

