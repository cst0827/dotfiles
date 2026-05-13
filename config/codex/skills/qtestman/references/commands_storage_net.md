#### disk_del
模擬硬碟拔出的動作。

(同 echo 1 > /sys/block/{diskName}/device/delete)

- 用法：
  - disk_del <login id> <disk>
- 變數取值：✔ 支援，<message>中可使用變數取值，需要用括弧$()刮起來。login id欄位必須是已登入ID，disk變數須符合eXdX的規範。
- 範例：
```QTestMan Script
 disk_del c1 e0d0
```

#### disk_rescan
disk_del後，模擬硬碟重插入的動作。 

(同echo - - - > /sys/class/scsi_host/{host}/scan)

- 用法：
  - disk_rescan <login id>
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 disk_rescan c1
```

#### nic_up

將指定的iface網路線接上。

(同ip link set eth0 up)

- 用法：
  - nic_up <login id> <iface>
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 nic_up c1 eth0
```

#### nic_down

將指定的iface網路線拔除。

(同ip link set eth0 up)

- 用法：
  - nic_down <login id> <iface>
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 nic_down c1 eth0
```

#### smb_login

將samba share mount到指定的磁碟代號上。

(同net use z: \\ip\share /USER:admin 1234)

- 用法：
  - smb_login <drive letter>: <share path>
  - smb_login <drive letter>: <share path> <user> <password>
- 說明：
  - <user> <password>：若未輸入，預設為admin / 1234
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 // 使用admin/12342登入後，把f1這個share mount到Z:
 smb_login z: \\192.168.168.100\f1 admin 1234

 // 使用admin/12342登入後，把f1這個share mount到Z:
 smb_login z: \\192.168.168.100\f1
```

#### smb_logout

將samba share umount掉。

(同net use z: /delete)

- 用法：
  - smb_logout <drive letter>:
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 // 把z: umount掉
 smb_logout z:
```

#### nfs_mount

將nfs share mount到指定的磁碟代號上，若windows版本不支援NFS，則會失敗。

(同mount ip:/nfs-share/share Z:)

- 用法：
  - nfs_mount <drive letter>: <ip> <share path>
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 nfs_mount z: 10.10.10.1 f1
```

#### nfs_umount

將nfs share umount掉。

(同umount z:)

- 用法：
  - nfs_umount <drive letter>:
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 // 把z: umount掉
 nfs_umount z:
```

#### iscsi_login

登入iSCSI target並把LUN都蒐集在變數中，此變數可使用在io_host及iocomp中。

- 用法：
  - iscsi_login <variable> <ip> <target>
  - iscsi_login <variable> <ip> <target> <lun num>
- 說明：
  - <lun num>：表示要取前幾個lun到變數中，若未輸入則預設為0表示全部。
- 變數取值：✔ 支援，<ip>、<target>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 iscsi_login $v1 192.168.10.100 target0   //取target0中全部的lun
 iscsi_login $v1 192.168.10.100 target0 2 //取target0中的前二個lun
```

#### iscsi_login_chap

CHAP版本的iscsi_login。

- 用法：
  - iscsi_login_chap <variable> <ip> <target> <user> <password>
  - iscsi_login_chap <variable> <ip> <target> <user> <password> <lun num>
- 說明：
  - <password>須超過12碼才符合Windows的限制。
  - <lun num>：表示要取前幾個lun到變數中，若未輸入則預設為0表示全部。
- 變數取值：✔ 支援，<ip>、<target>、<user>、<password>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 iscsi_login_chap $v1 192.168.10.100 target0 admin 1234   //取target0中全部的lun
 iscsi_login_chap $v1 192.168.10.100 target0 admin 1234 2 //取target0中的前二個lun
```

#### iscsi_logout

登出iSCSI target。

- 用法：
  - iscsi_logout <ip> <target>
- 變數取值：✔ 支援，<ip>、<target>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 iscsi_logout 192.168.10.100 target0
```

#### pd_init
對windows磁碟管理內的磁碟做「初始化」。 

- 用法：
  - pd_init <physical drive>
- 變數取值：✔ 支援，<physical drive>中可使用變數取值，需要用括弧$()刮起來。
```QTestMan Script
// 輸入physical drive編號
pd_init 2

// 直接輸入physical drive名稱
pd_init \\.\physicaldrive10

//使用變數取值
pd_init $(physicalDrive)

//可配合iscsi_init使用
iscsi_login $v1 192.168.10.100 target0
pd_init $(v1)
```

#### pd_online
對windows磁碟管理內的磁碟做「連線」。
- 用法：
  - pd_online
- 變數取值：✘ 不支援。
```QTestMan Script
pd_online
```

#### pd_rescan
對windows磁碟管理內的磁碟做「重新掃描」。
- 用法：
  - pd_rescan
- 變數取值：✘ 不支援。
```QTestMan Script
pd_rescan
```

### Macro

Macro可用任意字元來宣告。

- 宣告用法：%<Macro name> = <string>
- 取值用法：%(<Macro name>)
- 範例：
```QTestMan Script
 %POOL_NAME = pool_3
 cs c1 zpool create %(POOL_NAME)
```

include可用來import其他QS的macro。

- 用法：include <QS>
- 範例：
```QTestMan Script
// Include QTestMan上開啟的.qs的路徑下的test.qs
include macro_list.qs

// Include 絕對路徑之下的macro_list.qs
include d:\macro_list.qs

```

### Variable

可宣告變數，但只支援整數及字串，運算子則支援++ / -- / += / -= / = 。

- 整數變數用法：$<number variable> [=|++|--|+=|-=] <number>
- 範例：
```QTestMan Script
 $v1 = 10
 $v1 ++
 $v1 --
 $v1 += 2
 $v1 -= 2
 $v1 = 8
```

- 字串變數用法：$<string variable> [=] <string>
- 範例：
```QTestMan Script
 $v1 = abcdef
 $v1 = abc def 123
```

- 變數賦值變數用法：$<variable> [=] $<variable>
- 範例：
```QTestMan Script
 $v1 = abc
 $v2 = $v1
 
 $v1 = 123
 $v2 = $v1
 
 // 驗證機器是否為MBW
 cs $v1 c1 uname -a
 verify $v1 PerseusMBW
```

- 某些Command中支援變數取值(ex: cs)，但在取值時需用括弧$()包起來，請參考各個Command的使用說明。
- 用法：$(variable)
- 範例：
```QTestMan Script
 // 建立1000個volume
 $count = 1
 repeat 1000
 {
    cs c1 zfs create Pool1/Vol$(count)
    $count ++
 } 
```

### Control Flow

若沒有下大括弧{}，表示範圍只有一行。
