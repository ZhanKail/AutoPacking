#!/bin/bash
# 打包须知
# 修改以下三个标志需要修改的路径, projectDir 是你存放项目的位置
# 使用该脚本时候请不要使用 Xcode 编译或者运行 APP, 否则可能出现失败

# 1.Configuration Info

# 项目路径 需修改
projectDir="xxx"

# 打包生成路径 建议桌面路径
ipaPath="xxx"

# 图标文件路径 需修改
IconPath="xxx"

# 以下文件需放在 ipaPath 路径下
Entitlements=$ipaPath/Entitlements.plist

# Provisioning Profile 需修改 查看本地配置文件
PROVISIONING_PROFILE="xxx"

# 版本号 需要修改
BundleVersion="xxx"

# 选择打包序号 多选则以空格隔开 如("1" "2" "3")
appPackNum=("1")

# -------------------------------------------------------------- #

# 配置App信息数组 格式:"学校名字(和工程中SchoolInfo.Plist对应)" "icon"
#Schemes:
#          项目名称   appIcon名称
#        1.xxx AppIcon-xxx
#        2.xxx AppIcon-xxx
#        3.xxx AppIcon-xxx

# -------------------------------------------------------------- #

# 打包个数
appPackNumLength=${#appPackNum[*]}

appInfos=(
          "xxx" "AppIcon-name" "AppDownLoadName"
          ...
          )

appInfosLength=${#appInfos[*]}

# Scheme Name
schemeName="xxx"

# Code Sign ID
CODE_SIGN_IDENTITY="iPhone Distribution: xxx co., LTD"

# 生成 APP 路径
buildDir="build/Release-iphoneos"

# 开始时间
beginTime=`date +%s`

# 创建打包目录
mkdir ${ipaPath}/AllPack

# 本地存放全部 IPA 的路径
AllIPAPackPath="${ipaPath}/AllPack"

# 清除缓存
rm -rf $projectDir/$buildDir

# 先创建 payload 文件夹
mkdir ~/Desktop/Payload

# 使用的时候要关掉自动签名 改为手动签名
# Build 生成 APP
xcodebuild -workspace ${projectDir}/xxx.xcworkspace -scheme ${schemeName} -configuration Release clean -sdk iphoneos build CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" PROVISIONING_PROFILE="${PROVISIONING_PROFILE}" SYMROOT="${projectDir}/build"

exit()
if [[ $? = 0 ]]; then
  echo "\033[31m 编译成功\n \033[0m"
else
  echo "\033[31m 编译失败\n \033[0m"
fi

# 移动编译生成的 app 到桌面的 Payload 文件夹下
 cp -Rf ${projectDir}/${buildDir}/${schemeName}.app ~/Desktop/Payload

# ----自定义打包----
for (( j=0; j<$appPackNumLength; j++)); do i=`expr ${appPackNum[$j]} - 1` i=`expr $i \* 3`

# App Bundle Name (CFBundleName)
appName=${appInfos[${i}]}

# App DisPlay Name
appDisplayName=${appInfos[${i}]}

# App Icon Name
appIconName=${appInfos[$i+1]}

# App Download Name
appDownloadName=${appInfos[$i+2]}

# 创建不同学校 ipa 目录
mkdir $AllIPAPackPath/$appName
rm -rf $AllIPAPackPath/$appName/*

echo "\033[31m 学校名字:$appName 学校Icon:$appIconName 下载名字:$appDownloadName\n \033[0m"

# 将对应的 icon 复制到需要修改的 app 的目录下
cp -Rf $IconPath/$appName/* $ipaPath/Payload/xxx.app

if [[ $? = 0 ]]; then
 echo "\033[31m 修改 icon 成功\033[0m"
else
 echo "\033[31m 修改 icon 失败\033[0m"
fi

# 修改 Plist
defaults write $ipaPath/Payload/xxx.app/xxx.plist "CFBundleName" $appName
defaults write $ipaPath/Payload/xxx.app/xxx.plist "CFBundleDisplayName" $appDisplayName
defaults write $ipaPath/Payload/xxx.app/info.plist "CFBundleName" $appName
defaults write $ipaPath/Payload/xxx.app/info.plist "CFBundleDisplayName" $appDisplayName

if [[ $? = 0 ]]; then
  echo "\033[31m 修改 Plist 成功\033[0m"
else
  echo "\033[31m 修改 Plist 失败\033[0m"
fi

# 重签名
xattr -cr $ipaPath/Payload/xxx.app
codesign -f -s "iPhone Distribution: xxx technology co., LTD" --entitlements $Entitlements $ipaPath/Payload/xxx.app
if [[ $? = 0 ]]; then
echo "\033[31m 签名成功\n \033[0m"
else
echo "\033[31m 签名失败\n \033[0m"
fi

# 生成 ipa
xcrun -sdk iphoneos -v PackageApplication ~/Desktop/Payload/xxx.app -o ${ipaPath}/$appDownloadName.ipa

if [[ $? = 0 ]]; then
  echo "\033[31m \n 生成 IPA 成功 \n\n\n\n\n\033[0m"
else
  echo "\033[31m \n 生成 IPA 失败 \n\n\n\n\n\033[0m"
fi


# 记得在ipa路径出加上打包的时间:https://www.xxx.com.cn/schoolUpload/version_update/ios/2017-11-2/$appDownloadName.ipa</string>
currentDate=date +"%Y-%m-%d"
# 创建 Plist
plist_path=$AllIPAPackPath/$appName/$appDownloadName.plist

cat << EOF > $plist_path
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<string>https://www.xxx.com.cn/schoolUpload/version_update/ios/$currentDate/$appDownloadName.ipa</string>
				</dict>
				<dict>
					<key>kind</key>
					<string>display-image</string>
					<key>url</key>
					<string>https://www.xxx.com.cn/schoolUpload/version_update/ios/icon/${appIconName}.png</string>
				</dict>
				<dict>
					<key>kind</key>
					<string>full-size-image</string>
					<key>url</key>
					<string>https://www.xxx.com.cn/schoolUpload/version_update/ios/icon/${appIconName}.png</string>
				</dict>
			</array>
			<key>metadata</key>
			<dict>
				<key>bundle-identifier</key>
				<string>com.xxx</string>
				<key>bundle-version</key>
				<string>$BundleVersion</string>
				<key>kind</key>
				<string>software</string>
				<key>title</key>
				<string>$appDownloadName</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>
EOF

# 移动
mv ${ipaPath}/$appDownloadName.ipa ${AllIPAPackPath}/$appName

# 结束时间
endTime=`date +%s`
echo -e "\033[0;31;40m打包时间$[ endTime - beginTime ]秒"
