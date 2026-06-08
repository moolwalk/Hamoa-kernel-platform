# Repo 기반의 code-linaro에서 git repository들을 추출하기
다음 두 스크립트를 이용하여 code-linaro의 .repo project를 sync 받고, 위 sub project들의 .git repository들을 추출할 수 있습니다.

|스크립트|설명|
|---|---|
|sync-code-linaro.sh|AU_TAG와 manifest URL을 지정하여 repo project를 sync 받을 수 있습니다.|
|extract-git.sh|.git 폴더를 포함하는 sub-project들 중의 하나를 .git repository로 추출합니다.|

KERNEL_PLATFORM.5.0 project의 경우, repo sync한 후의 코드 크기는 20GB 정도이지만, commit history(.repo 폴더)는 120GB에 달하므로, 작업 전에 disk 용량을 150GB 정도 확보해야 합니다.
|폴더|크기|설명|
|---|---|---| 
|kernel_platform|	20GB | source tree |
|.repo|	120GB	| commit history |

1. code-linaro의 repo를 sync 합니다. 
```
./sync-code-linaro.sh --manifest-url https://git.codelinaro.org/clo/la/kernelplatform/manifest --au-tag-name AU_LINUX_KERNEL.PLATFORM.5.0.R32.00.00.00.205.015.xml
```
2. 필요한 .git project들을 각각 추출합니다. 아래 명령에 의해 ./extracted 폴더 밑에 common,soc-repo,devicetree,edk2 등의 단일 repository들이 각각 추출됩니다.
```
./extract-git.sh kernel_platform/common
./extract-git.sh kernel_platform/soc-repo
./extract-git.sh kernel_platform/qcom/opensource/devicetree
./extract-git.sh kernel_platform/bootable/bootloader/edk2
```
3. (optional)code-linaro를 sync 한 PC와 git push할 PC가 다른 경우, 다음과 같이 각각의 repository를 압축하여 전달할 수 있습니다.
```
tar -czvf kernelplatform_common.tar.gz
tar -czvf kernelplatform_soc-repo.tar.gz
tar -czvf kernelplatform_devicetree.tar.gz
tar -czvf kernelplatform_edk2.tar.gz
```
