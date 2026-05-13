#### cs
直接把 <command> 透過 ssh 送到 NAS console。

- 用法：
  - cs <login id> <command>
  - cs <variable> <login id> <command>
- 說明：
  - <variable>：可將執行結果的output存入此變數。
  - <login id>：在使用cs前要先下 [login](http://wiki.qsan.com/wiki/index.php/QTestMan#login)，因為console可開多個，所以需要指定login id。
  - <command>：欲執行的command。
- 變數取值：✔ 支援，<command>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 cs c1 ls /tmp
 cs c1 touch /tmp/$(v1)_tmp_file

 // output存入變數$v1
 cs $v1 c1 ls /tmp
 cs $v1 c1 touch /tmp/$(v2)_tmp_file
```

#### cs_nb

Non-blocking版本的cs，不管結果直接回來，不支援output存入變數。

- 用法：
  - cs_nb <login id> <command>
- 說明：
  - 請參考cs
- 變數取值：✔ 支援，<command>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 cs_nb c1 ls /tmp
 cs_nb c1 touch /tmp/$(v1)_tmp_file
```

#### exec

透過windows command執行一串命令，若是命令失敗，會停止QS並fail。

- 用法：
  - exec <command>
  - exec <variable1> <command>
  - exec <variable1> <variable2> <command>
- 說明：
  - <command>：欲執行的command。
  - <variable1>：將return code存入此變數。
  - <variable2>：將output存入此變數。
- 變數取值：✔ 支援，<command>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 exec net use * /delete
 exec net use $(drive): \\ip\share /USER:admin 1234

 // Return code存入變數$rc
 exec $rc net use * /delete
 exec $rc net use $(drive): \\ip\share /USER:admin 1234

 // Return code與output存入變數$rc與$output，並verify
 exec $rc $output ping 192.168.128.254
 verify $rc ^0$
 if unmatched
     fail
 verify $output Lost = 0
 if unmatched
     fail
```

#### exec_nb

Non-blocking版本的exec，注意這個指令無法取得命令執行結果。

- 用法：
  - exec_nb <command>
- 說明：
  - <command>：欲執行的command。
- 變數取值：✔ 支援，<command>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 exec_nb net use * /delete
```

#### scp

將檔案透過ssh傳送到機器上。

- 用法：
  - scp <login id> &lt;source file&gt; <destination path>
- 說明：
  - <login id>：從[login](http://wiki.qsan.com/wiki/index.php/QTestMan#login) command取得的login id。
  - &lt;source file&gt;：欲傳送的文件位置，可採用相對路徑 (相對於當前執行QS) 或絕對路徑。
  - <destination path>：傳送目的地的完整路徑。
- 變數取值：✔ 支援，&lt;source file&gt; 和 <destination path> 中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 //相對路徑
 scp c1 test.txt /test.txt

 //絕對路徑
 scp c1 D:\test.txt /test.txt

 //變數取值
 $src = test.txt
 $dst = /test.txt
 scp c1 $(src) $(dst)
```

#### login
自動開啟console視窗並登入，因為可開多個console，所以需要指定login id跟ip。

- 用法：
  - login <login id> <ip>
  - login <login id> <ip> [nas | san | qsanos | neither]
  - login <login id> <ip> [nas | san | qsanos | neither] <user> <password>
  - login <login id> <ip> [nas | san | qsanos | neither] <user> <password> <secret>
- 說明：
  - <ip>：即ip，也可以為ip:port來指定port，如192.168.252.100:2222。
  - [nas | san | neither]：若不輸入，預設為nas。
    - 若指定nas，則預設 port : 2222，user : root, password : 1234, 登入後會執行 debug 的跳脫步驟，secret 為 QsanStor。
    - 若指定san，則預設 port : 22，user : admin, password : 1234, 登入後會執行 console_ui 的跳脫步驟，secret 為 QsanStor。
    - 若指定qsanos, 則預設 port : 22，user : root, password : 1234, 登入後會執行 debug 的跳脫步驟，secret 為 QsanStor。
    - 若指定neigher，port若沒輸入預設為22，登入後不會做任何事。
    - 注意：未來會取消不輸入預設為nas這項設定，可能改為不可不輸入、或是不輸入時預設為qsanos，因此即刻起盡可能不要不輸入。
  - <user> <password>：即帳號密碼，若不輸入則nas為root 1234，san為admin 1234。
  - <secret>：自行指定通關密語。
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 login c1 192.168.252.100:111 neither                   // default root 1234
 login c1 192.168.252.100 nas                           // default root 1234 QsanStor
 login c1 192.168.252.100 nas root 1234                 // default QsanStor
 login c1 192.168.252.100 nas root 1234 Qs@nStor
 login c1 192.168.252.100 san                           // default admin 1234 QsanStor
 login c1 192.168.252.100 san admin 12345678            // default QsanStor
 login c1 192.168.252.100 san admin 12345678 QsanStor
 login c1 192.168.252.100 qsanos                        // default root 1234 QsanStor
```

#### logout

登出並關閉視窗，console視窗會關閉。

- 用法：
  - logout <login id>
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 logout c1 
```
