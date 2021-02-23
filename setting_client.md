# 客户端配置

## Windows 10 and 8.x

- 右键单击系统托盘中的无线/网络图标。
- 选择 **打开网络和共享中心**。或者，如果你使用 Windows 10 版本 1709 或以上，选择 **打开"网络和 Internet"设置**，然后在打开的页面中单击 **网络和共享中心**。
- 单击 **设置新的连接或网络**。
- 选择 **连接到工作区**，然后单击 **下一步**。
- 单击 **使用我的Internet连接 (VPN)**。
- 在 **Internet地址** 字段中输入`你的 VPN 服务器 IP`。
- 在 **目标名称** 字段中输入任意内容。单击 **创建**。
- 返回 **网络和共享中心**。单击左侧的 **更改适配器设置**。
- 右键单击新创建的 VPN 连接，并选择 **属性**。
- 单击 **安全** 选项卡，从 **VPN 类型** 下拉菜单中选择 "使用 IPsec 的第 2 层隧道协议 (L2TP/IPSec)"。
- 单击 **允许使用这些协议**。选中 "质询握手身份验证协议 (CHAP)" 和 "Microsoft CHAP 版本 2 (MS-CHAP v2)" 复选框。
- 单击 **高级设置** 按钮。
- 单击 **使用预共享密钥作身份验证** 并在 **密钥** 字段中输入`你的 VPN IPsec PSK`。
- 单击 **确定** 关闭 **高级设置**。
- 单击 **确定** 保存 VPN 连接的详细信息。

**注：** 在首次连接之前需要修改一次注册表，以解决 VPN 服务器 和/或 客户端与 NAT （比如家用路由器）的兼容问题。

- 适用于 Windows Vista, 7, 8.x 和 10

```bash
REG ADD HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f
```

- 仅适用于 Windows XP

```bash
REG ADD HKLM\SYSTEM\CurrentControlSet\Services\IPSec /v AssumeUDPEncapsulationContextOnSendRule /t REG_DWORD /d 0x2 /f
```

另外，某些个别的 Windows 系统配置禁用了 IPsec 加密，此时也会导致连接失败。要重新启用它，可以运行以下命令并重启。

- 适用于 Windows XP, Vista, 7, 8.x 和 10

```bash
REG ADD HKLM\SYSTEM\CurrentControlSet\Services\RasMan\Parameters /v ProhibitIpSec /t REG_DWORD /d 0x0 /f
```

要连接到 VPN：单击系统托盘中的无线/网络图标，选择新的 VPN 连接，然后单击 **连接**。如果出现提示，在登录窗口中输入 `你的 VPN 用户名` 和 `密码` ，并单击 **确定**。最后你可以到 <a href="https://www.ipchicken.com" target="_blank">这里</a> 检测你的 IP 地址，应该显示为`你的 VPN 服务器 IP`。


### Windows 7, Vista and XP

- 单击开始菜单，选择控制面板。
- 进入 **网络和Internet** 部分。
- 单击 **网络和共享中心**。
- 单击 **设置新的连接或网络**。
- 选择 **连接到工作区**，然后单击 **下一步**。
- 单击 **使用我的Internet连接 (VPN)**。
- 在 **Internet地址** 字段中输入`你的 VPN 服务器 IP`。
- 在 **目标名称** 字段中输入任意内容。
- 选中 **现在不连接；仅进行设置以便稍后连接** 复选框。
- 单击 **下一步**。
- 在 **用户名** 字段中输入`你的 VPN 用户名`。
- 在 **密码** 字段中输入`你的 VPN 密码`。
- 选中 **记住此密码** 复选框。
- 单击 **创建**，然后单击 **关闭** 按钮。
- 返回 **网络和共享中心**。单击左侧的 **更改适配器设置**。
- 右键单击新创建的 VPN 连接，并选择 **属性**。
- 单击 **选项** 选项卡，取消选中 **包括Windows登录域** 复选框。
- 单击 **安全** 选项卡，从 **VPN 类型** 下拉菜单中选择 "使用 IPsec 的第 2 层隧道协议 (L2TP/IPSec)"。
- 单击 **允许使用这些协议**。选中 "质询握手身份验证协议 (CHAP)" 和 "Microsoft CHAP 版本 2 (MS-CHAP v2)" 复选框。
- 单击 **高级设置** 按钮。
- 单击 **使用预共享密钥作身份验证** 并在 **密钥** 字段中输入`你的 VPN IPsec PSK`。
- 单击 **确定** 关闭 **高级设置**。
- 单击 **确定** 保存 VPN 连接的详细信息。


要连接到 VPN：单击系统托盘中的无线/网络图标，选择新的 VPN 连接，然后单击 **连接**。如果出现提示，在登录窗口中输入 `你的 VPN 用户名` 和 `密码` ，并单击 **确定**。最后你可以到 <a href="https://www.ipchicken.com" target="_blank">这里</a> 检测你的 IP 地址，应该显示为`你的 VPN 服务器 IP`。


## Android

- 启动 **设置** 应用程序。
- 单击 **网络和互联网**。或者，如果你使用 Android 7 或更早版本，在 **无线和网络** 部分单击 **更多...**。
- 单击 **VPN**。
- 单击 **添加VPN配置文件** 或窗口右上角的 **+**。
- 在 **名称** 字段中输入任意内容。
- 在 **类型** 下拉菜单选择 **L2TP/IPSec PSK**。
- 在 **服务器地址** 字段中输入`你的 VPN 服务器 IP`。
- 保持 **L2TP 密钥** 字段空白。
- 保持 **IPSec 标识符** 字段空白。
- 在 **IPSec 预共享密钥** 字段中输入`你的 VPN IPsec PSK`。
- 单击 **保存**。
- 单击新的VPN连接。
- 在 **用户名** 字段中输入`你的 VPN 用户名`。
- 在 **密码** 字段中输入`你的 VPN 密码`。
- 选中 **保存帐户信息** 复选框。
- 单击 **连接**。

VPN 连接成功后，会在通知栏显示图标。最后你可以到 <a href="https://www.ipchicken.com" target="_blank">这里</a> 检测你的 IP 地址，应该显示为`你的 VPN 服务器 IP`。


## iOS

- 进入设置 -> 通用 -> VPN。
- 单击 **添加VPN配置...**。
- 单击 **类型** 。选择 **L2TP** 并返回。
- 在 **描述** 字段中输入任意内容。
- 在 **服务器** 字段中输入`你的 VPN 服务器 IP`。
- 在 **帐户** 字段中输入`你的 VPN 用户名`。
- 在 **密码** 字段中输入`你的 VPN 密码`。
- 在 **密钥** 字段中输入`你的 VPN IPsec PSK`。
- 启用 **发送所有流量** 选项。
- 单击右上角的 **完成**。
- 启用 **VPN** 连接。

VPN 连接成功后，会在通知栏显示图标。最后你可以到 <a href="https://www.ipchicken.com" target="_blank">这里</a> 检测你的 IP 地址，应该显示为 `你的 VPN 服务器 IP`。
