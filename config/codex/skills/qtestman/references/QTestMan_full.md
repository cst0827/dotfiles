# Overview

QTestMan是一個自動測試工具及平台。

- QTestMan Script (QS) 由Test Script及Test Plan組成。
- Test Script與Test Plan融為一體。
- Test Script透過各個Function Unit來實現。

## I/O Engine

- 可執行host端的fio進行I/O。
- 會有各種pattern可選擇，這也可以簡化fio測試，因為fio的使用並不簡易。

# QTestMan Script (QS)

- QTestMan Script (QS) 包含Test Plan及Test Script
- 註解使用'//'，而'/*...*/'不支援。
```QTestMan Script
# Test Item 1：XXX
// 註解
// 註解
code

# Test Item 2：XXX
code // 註解
```

## Test Plan

Test Plan的內容稱為Test Item

- Test Plan 的項目為巢狀結構，使用'#'作為開頭，子項目為'##', '###', 以此類推。只能在同一行，若需多行請用註解。
```QTestMan Script
# Test Item 1：XXX
code
## Test Item 1-1：XXX
code
## Test Item 1-2：XXX
code
### Test Item 1-2-1：XXX
code
### Test Item 1-2-2：XXX
code

# Test Item 2：XXX
code
```

- Test Item可用'#[x<number>]'來實現迴圈，ex: #[x10]
```QTestMan Script
// Test Item 1 跑10次
#[x10] Test Item 1：XXX
code
## Test Item 1-1：XXX
code
## Test Item 1-2：XXX
code
### Test Item 1-2-1：XXX
code
### Test Item 1-2-2：XXX
code
```

## Test Script

- Test Script的內容稱為Code。
- % 是Macro，注意取值時要用()包起來，例如 %(Macro)。
- $ 是Variable，部分Command支援，注意取值時要用()包起來，例如 $(Variable)。

### Command

以下是Test Script中可使用的command。

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

#### io_host

在host端執行I/O，可將結果存入變數，並且可利用if判斷結果。

Host需要安裝fio，檔案連結：[檔案:Fio-3.13-x64.zip](檔案:Fio-3.13-x64.zip) (Do not use 3.16 or 3.18)

- 用法：
  - io_host <path> <pattern> [&lt;time&gt;]
  - io_host <var_thro> <var_iops> <var_lat> <path> <pattern> [&lt;time&gt;]
- 說明：
  - <path>為測試的路徑，支援多重路徑，各個路徑使用 | 分開。
    - 若是file system，則<path>為目錄，而不是檔案。
    - 若是block device，則<path>為\\.\physicaldriveX，也可用iscsi_login的回傳變數來套用。
  - <pattern>由I/O Engine頁面中複製。可加入自訂參數[...]來覆蓋原參數 (Ex: --size=64G)，若有加自訂參數，則pattern可為空。
  - &lt;time&gt;為測試時間，若沒有輸入則預設180秒。
  - 將結果存入變數：
    - <var_thro>：Throughput，單位為MB/s。
    - <var_iops>：IOPS，單位為IOs/s。
    - <var_lat>：Latency，單位為us。
- 變數取值：✔ 支援，<path>及&lt;time&gt;中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // 一般用法
 io_host z:\ CIFS/NFS SeqRead 128K Random 300
 io_host z:\test CIFS/NFS SeqWrite 128K Cache-Hit Random
 io_host z: CIFS/NFS RandRead 4K Random 300
 io_host z:\|y:\ CIFS/NFS RandRead 4K Random 300
 io_host \\.\physicaldrive3 iSCSI SeqWrite 128K Random
 io_host \\.\physicaldrive3|\\.\physicaldrive4 iSCSI SeqWrite 128K Random

 // 將結果存在變數
 io_host $thro $iops $lat z: CIFS/NFS RandRead 4K Random 300

 // 自訂參數
 io_host z:\ CIFS/NFS SeqRead 128K Random [--size=64G --bs=4K] 300
 io_host z:\ [name=test --group_report --time_based --ramp_time=10 --runtime=180 --iodepth=64 --nrfiles=1 --buffered=0 --ioengine=windowsaio --filename=z\:/fio_file --numjobs=4 --rw=read --bs=128K --size=4G --offset_increment=4G] 300

 // 用if判斷結果
 io_host z: CIFS/NFS RandRead 4K Random 300
 if throughput < 3000  // 3000 MB/s
    fail
 if iops < 80000  // 80k
    fail
 if latency > 1000000  // 1000000us = 1s
    fail

```

#### io_host_nb

Non-blocking版本的io_host，注意這個指令無法用if判斷結果。

- 用法：
  - io_host_nb <path> <pattern> [&lt;time&gt;]
- 說明：
  - 請參考io_host
- 變數取值：✔ 支援，<path>及&lt;time&gt;&lt;time&gt;中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 io_host_nb z:\ CIFS/NFS SeqRead 128K Random 200
```

#### io_host_dc

會做data compare的io_host，功能較單純，不支援<pattern>。

- 用法：
  - io_host_dc <path> [write_only|verify_only] <pattern> [&lt;time&gt;]
- 說明：
  - <path>為測試的路徑，支援多重路徑，各個路徑使用 | 分開。
    - 若是file system，則<path>為目錄，而不是檔案。
    - 若是block device，則<path>為\\.\physicaldriveX，也可用iscsi_login的回傳變數來套用。
  - <pattern>由I/O Engine頁面中複製。可加入自訂參數[...]來覆蓋原參數 (Ex: --size=64G)，若有加自訂參數，則pattern可為空。
  - &lt;time&gt;為測試時間，若沒有輸入則預設180秒，若在&lt;time&gt;內已寫/讀完整個檔案，則會直接結束。
  - io_host_dc預設為write => verify的連續動作，可加write_only表示只write、或加verify_only表示只read verify。
    - Write + Verify：新增 --verify=md5 --do_verify=1
    - Write only：新增 --verify=md5 --do_verify=0 --verify_state_save=1
    - Verify only：新增 --verify=md5 --do_verify=1 --verify_only --verify_state_load=1
    - 以上皆需修改：--numjobs=1, --iodepth=1, size=100%，並移除--time_based, --ramp_time, --offset_increment

- 變數取值：✔ 支援，<path>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 io_host_dc z:\test CIFS/NFS RandWrite 4K Random 180
 io_host_dc z: CIFS/NFS RandWrite 4K Random write_only
 io_host_dc z: CIFS/NFS RandRead 4K Random verify_only
 io_host_dc \\.\physicaldrive3 iSCSI SeqWrite 128K Random 60
```

#### io_host_dc_nb
Non-blocking版本的io_host_dc。

- 用法：
  - io_host_dc_nb <path> [write_only|verify_only] <pattern> [&lt;time&gt;]
- 說明：
  - 請參考io_host_dc
  - io_host_dc_nb 因為測試需求所以在執行 fail 時也會停止 qs

- 變數取值：✔ 支援，<path>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 io_host_dc_nb z:\ CIFS/NFS RandRead 4K Random 180
 io_host_dc_nb \\.\physicaldrive3 iSCSI SeqWrite 128K Random 60
```

#### io_local

在local端執行I/O，可將結果存入變數，並且可利用if判斷結果。

- 用法：
  - io_local <login id> <path> <pattern> [&lt;time&gt;]
  - io_local <var_thro> <var_iops> <var_lat> <login id> <path> <pattern> [&lt;time&gt;]
- 說明：
  - <path>需為目錄而不是檔案。
  - <pattern>由I/O Engine頁面中複製。可加入自訂參數[...]來覆蓋原參數 (Ex: --size=64G)，若有加自訂參數，則pattern可為空。
  - &lt;time&gt;為測試時間，若沒有輸入則預設180秒。
  - 將結果存入變數：
    - <var_thro>：Throughput，單位為MB/s。
    - <var_iops>：IOPS，單位為IOs/s。
    - <var_lat>：Latency，單位為us。
- 變數取值：✔ 支援，<path>及&lt;time&gt;&lt;time&gt;中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // 一般用法
 io_local c1 /mnt/pool/Pool1/ File System SeqRead 128K Random 300
 io_local c1 /mnt/pool/Pool1/ File System SeqWrite 128K Cache-Hit Random
 io_local c1 /mnt/pool/Pool1 File System RandRead Random 4K 300
 io_local c1 /dev/zd10 Block RandWrite 4K Random

 // 將結果存在變數
 io_local $thro $iops $lat c1 /mnt/pool/Pool1 File System RandRead Random 4K 300

 // 自訂參數
 io_local c1 /mnt/pool/Pool1/ File System SeqRead 128K Random [--size=64G --bs=4K] 300

 // 用if判斷結果
 io_local c1 /mnt/pool/Pool1 File System RandRead Random 4K 300
 if throughput < 3000  // 3000 MB/s
    fail
 if iops < 80000  // 80k
    fail
 if latency > 1000000  // 1000000us = 1s
    fail
```

#### io_local_nb

Non-blocking版本的io_local，注意這個指令無法用if判斷結果。

- 用法：
  - io_local_nb <login id> <path> <pattern> [&lt;time&gt;]
- 說明：
  - 請參考io_local
- 變數取值：✔ 支援，<path>及&lt;time&gt;&lt;time&gt;中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 io_local_nb c1 /mnt/pool/Pool1/ File System SeqRead 128K Random 200
```

#### io_host_multi

可一次執行多個io_host，並可將結果存入變數，且可利用if判斷結果。

- 用法：
  - io_host_multi <io_host_1> <io_host_2> ...
  - io_host_multi <var_thro> <var_iops> <var_lat> <io_host_1> <io_host_2> ...
- 說明：
  - <io_host_x>同io_host，&lt;time&gt;一樣可加或不加，不可指定變數。
  - 可使用自訂參數[...]。
  - 將結果存入變數：
    - <var_thro>：Throughput，單位為MB/s。
    - <var_iops>：IOPS，單位為IOs/s。
    - <var_lat>：Latency，單位為us。
- 變數取值：✔ 支援，<io_host_x>中的<path>及&lt;time&gt;&lt;time&gt;中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // 將結果存在變數
 io_host_multi $thro $iops $lat io_host z:\ CIFS/NFS SeqRead 128K Random 300 z:\test CIFS/NFS SeqWrite 128K Cache-Hit Random 300

 // 用if判斷結果
 io_host_multi io_host z:\ CIFS/NFS SeqRead 128K Random 300 z:\test CIFS/NFS SeqWrite 128K Cache-Hit Random 300
 if throughput < 3000  // 3000 MB/s
    fail
 if iops < 80000  // 80k
    fail
 if latency > 1000000  // 1000000us = 1s
    fail

```

#### io_local_multi

可一次執行多個io_local，並可將結果存入變數，且可利用if判斷結果。

- 用法：
  - io_local_multi <io_local_1> <io_local_2>
  - io_local_multi <var_thro> <var_iops> <var_lat> <io_local_1> <io_local_2>
- 說明：
  - <io_local_x>同io_local，&lt;time&gt;一樣可加或不加，不可指定變數。
  - 可使用自訂參數[...]。
  - 將結果存入變數：
    - <var_thro>：Throughput，單位為MB/s。
    - <var_iops>：IOPS，單位為IOs/s。
    - <var_lat>：Latency，單位為us。
- 變數取值：✔ 支援，<io_local_x>中的<path>及&lt;time&gt;&lt;time&gt;中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // 將結果存在變數
 io_local_multi $thro $iops $lat io_local c1 /mnt/pool/Pool1/ File System SeqRead 128K Random 300 io_local c1 /mnt/pool/Pool1/ File System SeqWrite 128K Cache-Hit Random 300

 // 用if判斷結果
 io_local_multi io_local c1 /mnt/pool/Pool1/ File System SeqRead 128K Random 300 io_local c1 /mnt/pool/Pool1/ File System SeqWrite 128K Cache-Hit Random 300
 if throughput < 3000  // 3000 MB/s
    fail
 if iops < 80000  // 80k
    fail
 if latency > 1000000  // 1000000us = 1s
    fail
```

#### io_rate

可啟用I/O最大限制，可以是throughput或是iops，通常用來量測latency的時候使用，

(同fio rate=xxx或是fio rate_iops=xxx，其中xxx要除以numjobs才是真正總量。)

- 用法：
  - io_rate [throughput | iops] set <max>
  - io_rate [throughput | iops] <percentage>%
  - io_rate [throughput | iops] clear
- 說明：
  - 選擇要限制throughput或iops。
  - 先用set設定最大值。若不知道最大值多少，就需要先正常執行一次io_host。
  - 之後即可設定<percentage>%來實現最大限制。
  - 要關閉時，使用clear來做清除。
  - 若是沒有set設定最大值，就直接使用<percentage>%，則回傳失敗。
  - 在設定io_rate後，io_host / io_host_nb / io_local / io_local_nb不可使用自訂參數[...]。
- 變數取值：✔ 支援，<max>及<percentage>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // Throughput
 io_host $thro $iops $lat z:\ SeqRead 128K Non-Cache hit 300  // 100%
 io_rate throughput set $(thro)
 io_rate throughput 90%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 90%
 io_rate throughput 80%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 80%
 io_rate throughput 70%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 70%
 io_rate throughput 60%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 60%
 io_rate throughput 50%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 50%
 io_rate throughput 40%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 40%
 io_rate throughput 30%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 30%
 io_rate throughput 20%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 20%
 io_rate throughput 10%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 10%
 io_rate throughput clear

 // IOPS
 io_host $thro $iops $lat z:\ SeqRead 128K Non-Cache hit 300  // 100%
 io_rate iops set $(iops)
 io_rate iops 90%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 90%
 io_rate iops 80%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 80%
 io_rate iops 70%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 70%
 io_rate iops 60%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 60%
 io_rate iops 50%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 50%
 io_rate iops 40%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 40%
 io_rate iops 30%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 30%
 io_rate iops 20%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 20%
 io_rate iops 10%
 io_host z:\ SeqRead 128K Non-Cache hit 300  // 10%
 io_rate iops clear
```

#### iocomp_nb

在host端執行iocomp，無法取得執行結果。

(同start cmd /k iocomp \\.\physicaldrive3 && start cmd /k iocomp \\.\physicaldrive4)

Host需要有iocomp，可放置在QTestMan的目錄下，或是直接設定到PATH環境變數。

[檔案:IOCOMP.zip](檔案:IOCOMP.zip)

- 用法：
  - iocomp <path>
  - iocomp <path> &lt;time&gt;
- 說明：
  - <path>為\\.\physicaldriveX
  - <path>支援多重路徑，各個路徑使用 | 分開，也可用 [iscsi_login](http://wiki.qsan.com/wiki/index.php/QTestMan#iscsi_login) 的回傳變數來套用。
  - <[time>為測試時間，若沒有輸入則預設無窮秒。
- 變數取值：✔ 支援，<path>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // 跑單一drive
 iocomp_nb \\.\physicaldrive3

 // 跑多個drives
 iocomp_nb \\.\physicaldrive3|\\.\physicaldrive4

 // 跑多個drives，100秒後自動停止
 iocomp_nb \\.\physicaldrive3|\\.\physicaldrive4 100

 // 與iscsi_login一起使用
 iscsi_login $v1 192.168.10.100 target0
 iocomp_nb $v1
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

#### finject

[未完成] 開關fault inject，參數請在'Fault Injection'的頁面上設定，設定的值可儲存在QS裡。

- 用法：
  - finject [on | off]
- 說明：
  - on：開啟
  - off：關閉
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 // 開啟finject
 finject on
 
 // 關閉finject
 finject off
```

#### verify

比對最後一次output跟<pattern>，支援regular expression。

- 用法：
  - verify <pattern>
  - verify <variable> <pattern>
- 說明：
  - <pattern>：欲比對的pattern。
  - <variable>：與此變數比對，而不是跟最後一次output。
- 變數取值：✔ 支援，<pattern>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // 比對最後一次output是否含有'abc.*1234'
 verify abc.*1234

 // 比對最後一次output是否含有變數$v1
 verify $(v1)

 // 比對變數$v1是否含有'abc.*1234'
 verify $v1 abc.*1234
```

#### delay
讓QS的執行停下來等待若干秒，支援浮點數。

- 用法：
  - delay <seconds>
- 變數取值：✔ 支援，<seconds>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // 等待2秒
 delay 2

 // 等待0.5秒
 delay 0.5

 // 等待$v1秒
 delay $(v1)
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

#### date
顯示當前時間。

- 用法：
  - date
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 // 顯示當前時間 , output : 2021/11/19 07:15:58.441021
 date
```

#### wait_until

暫停QS並等待到指定的時間再繼續執行。

- 用法：
  - wait_until &lt;time&gt;
  - wait_until <date>&lt;time&gt;
- 說明：
  - <date>：YYY&lt;time&gt;Y/MM/DD&lt;time&gt; HH:MM
- 變數取值：✘ 不支援

- &lt;time&gt;範例：
```QTestMan Script
 // 等待至18:00
 wait_until 18:00

 // 等待至2021/02/17 18:00
 wait_until 2021/02/17 18:00

```

#### poll
Polling指定的<pattern>，支援regular expression。

- 用法：
  - poll <login id> <seconds> <pattern>
- 說明：
  - <seconds>：欲polling的秒數，若達到<seconds>秒就會fail並停止QS。若為0，則會無窮polling。
  - <seconds>支援浮點數。
- 變數取值：✔ 支援，<pattern>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // Polling "finish" pattern，若超過5秒就算fail。
 poll c1 5 finish
 
 // 無窮polling "reboot done" pattern。
 poll c1 0 reboot done

 // 無窮polling $v1 pattern。
 poll c1 0 $(v1)
```

#### poll_boot
Polling機器開機完成，開機完成的定義是UI已啟動。

- 用法：
  - poll_boot <ip>
  - poll_boot <ip> <seconds>
- 說明：
  - <seconds>：欲polling的秒數，若達到<seconds>秒就會fail並停止QS。若為0或是沒有填寫，則會無窮polling。
  - <seconds>支援浮點數。Z
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 // Polling 192.168.168.1這台機器開機完成，若超過5秒就算fail。
 poll_boot 192.168.168.1 5
 
 // 無窮polling 192.168.168.1這台機器開機完成。
 poll_boot 192.168.168.1

 // 無窮polling 192.168.168.1這台機器開機完成。
 poll_boot 192.168.168.1 0
```

#### errstop

可全域設定 command 若失敗時是否將 error 轉為 warning，預設為1。注：error 會引發 QS fail (QS 會停下來)，warning 則不會引發 QS fail (QS 不會停下來)。

當 command 結果為 warning 時，report 的 result 不會因此變為 fail。

- 用法：
  - errstop <0 | 1>
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 // smb_logout如果失敗也不要停下來。
 errstop 0
 smb_logout Z:
 errstop 1

 // 讓本poll若是timeout也不要停下來，pool完後再重設errstop。
 errstop 0
 poll c1 5 finish
 errstop 1

```

#### failstop

可全域設定若遇到 QS fail 時，QS 要不要停下來。

當 fail 發生時，report 的 result 仍然會是 fail，只是不會停下來。

- 用法：
  - failstop <0 | 1>
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 // 如果 command error，不會引發 QS fail，QS 不會停下來
 failstop 0
 cs undefined_console_id pwd
 failstop 1

 // 如果遇到 fail，不會引發 QS fail，QS 不會停下來
 failstop 0
 cs c1 uname
 verify unknown_string
 if unmatched // 這裡一定成立
     fail
 failstop 1

 // 如果 run 引發 fail，不會引發 QS fail，QS 不會停下來
 failstop 0
 run will_fail.qs
 failstop 1
```

#### msgbox
跳出視窗顯示訊息<message>，視窗上有OK按鈕，按了才會繼續跑QS。

- 用法：
  - msgbox <message>
- 說明：
  - <message>：欲顯示的訊息，為html格式，可自行使用html語法做修改。
- 變數取值：✔ 支援，<message>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // 跳出視窗顯示"Hello world"
 msgbox Hello world
 
 // 跳出視窗顯示變數$v1 => "Are you sure"
 $v1 = Are you sure?
 msgbox $(v1)

 // 也可使用HTML格式
 msgbox <span style="color: green;">Hello world</span><br>line two.

 // 視窗內秀出圖片
 msgbox <img src="photo.jpg">
```

#### msgbox_yn

跳出視窗顯示訊息<message>，視窗上有Yes/No按鈕，按了才會繼續跑QS。

- 用法：
  - msgbox_yn <variable> <message>
- 說明：
  - <variable>：Yes / No會被存入此變數，1為Yes，0為No。
  - <message>：欲顯示的訊息，為html格式，可自行使用html語法做修改。
- 變數取值：✔ 支援，<message>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 msgbox_yn $v1 Are you sure?
 msgbox_yn $v1 Are you $(v2)?
```

#### msgbox_input

跳出視窗顯示訊息<message>，視窗上有欄位可供輸入，輸入完按OK才會繼續跑QS。

- 用法：
  - msgbox_input <variable> <message>
- 說明：
  - <variable>：輸入的字串會被存入此變數。
  - <message>：欲顯示的訊息，為html格式，可自行使用html語法做修改。
- 變數取值：✔ 支援，<message>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 msgbox_input $v1 Please input the pool name.
 msgbox_input $v1 Please input $(v2)'s name.
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

#### ui_recorder

重播UI的操作。

- 用法：
  - ui_recorder <url> "<ui_recorder_code>"
- 說明：
  - "<ui_recorder_code>"：由UI recorder錄製完後生成，其中雙引號是由UI recorder自動生成。
- 變數取值：✔ 支援，<url>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // <url>使用ip
 ui_recorder http://192.168.10.10 "code_from_ui_recorder"

 // <url>使用domain/host name
 ui_recorder https://demo2.qsan.com "code_from_ui_recorder"

 // 變數取值
 $host = demo2.qsan.com
 ui_recorder http://$(host) "code_from_ui_recorder"

 // 變數取值
 $host = https://192.168.10.10
 ui_recorder $(host) "code_from_ui_recorder"

```

#### sendkey

送出鍵盤信號到console。

- 用法：
  - sendkey <login id> <key>
- 說明：
  - <key>：欲送出的按鍵。目前有：ctrl+c | enter | esc | space | tab | up | down | right | left。
  - 若<key>非上述的保留字，則會直接送出原字串。
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 // 送出方向鍵「上」
 sendkey c1 up

 // 送出ctrl C
 sendkey c1 ctrl+c

 // 送出ABCDE
 sendkey c1 ABCDE
```

#### echo

印訊息在下方的OUTPUT子視窗。

- 用法：
  - echo <message>
- 變數取值：✔ 支援，<message>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 echo hello world
 echo hello $(v1)
```

#### run

執行QS。

- 用法：
  - run <path>
  - run <path> <macro1> <macro2> ...
- 說明：
  - 若有指定<macro>，即可將現行QS中的macro帶進要執行的QS中執行 (若存在則覆蓋)。
  - 注意此處的<macro>不可以用括號括起來，因為是保留用法。
- 變數取值：✔ 支援，<path>及<macro>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // 執行QTestMan上開啟的.qs的路徑下的test.qs
 run test.qs

 // 執行絕對路徑之下的test.qs
 run d:\test.qs

 // [未實作]
 // 執行http server上的test.qs
 run http://qsan.com.tw/test.qs

 // 將macro帶進test.qs中
 %IP1 = 192.168.10.100
 %IP2 = 192.168.10.101
 run test.qs %IP1 %IP2 // 如果test.qs原本就有define %IP1 or %IP2，則會被覆蓋掉

 // 將macro帶進test.qs中
 $ip2 = 192.168.10.101
 run test.qs %IP1=169.254.0.235 %IP2 = $(ip2)  // 如果test.qs原本就有define %IP1 or %IP2，則會被覆蓋掉
```

#### stop

停止運行QS。

- 用法：
  - stop
  - stop <reason>
- 說明：
  - <reason>：停止時，會將此訊息印在下方OUTPUT子視窗。
- 變數取值：✔ 支援，<reason>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 stop
 
 stop unknown status

 stop stop because of $(v1)
```

#### end

該執行中的QS直接結束，若此QS是由run所執行，則原QS會繼續執行。

- 用法：end
- 變數取值：✘ 不支援
- 範例：
```QTestMan Script
 end
```

#### fail

跳出fail視窗，並停止運行QS。

- 用法：
  - fail
  - fail <reason>
- 說明：
  - <reason>：停止時，會跳出fail視窗並印出此訊息。
- 變數取值：✔ 支援，<reason>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 fail
 
 fail incorrect serial number

 fail fail because of $(v1)
```

#### random

生成隨機正整數，並放到<variable>中。

- 用法：
  - random <variable>
  - random <variable> <num>
  - random <variable> <num1> <num2>
- 說明：
  - <num>：數值為 0 ~ <num>，並放到<variable>中。
  - <num1> <num2>：數值為 <num1> ~ <num2>，並放到<variable>中。
  - 若以上皆未輸入，則為 0 ~ 極大值。
- 變數取值：✔ 支援，<number>、<num1>及<num2>中可使用變數取值，需要用括弧$()刮起來。
- 範例：
```QTestMan Script
 // $v1 = 0 ~ 極大值
 random $v1

 // $v1 = 0 ~ 15
 random $v1 15

 // $v1 = 21 ~ 55
 random $v1 21 55
```

#### report

設定report的檔名、及report內的Title與Note。

不適用於QTestMan GUI版手動執行測試的情況。

- 用法：
  - report name <file name/path>
  - report title &lt;title name&gt;
  - report note <note>
- 說明：
  - <file name> ：檔案名稱，可用絕對/相對路徑，其中相對路徑的根目錄為執行的QS，不須加入副檔名，會自動設為.html。
  - &lt;title name&gt;：即Title。
  - <note>：即Note，為html格式。
- 變數取值：✔ 支援，<file name>、&lt;title name&gt;、<note>中可使用變數取值，需要用括弧$()刮起來。
- 只適用於 QTestMan GUI 版 Command-Line 模式與 CLI 版。
- 範例：

```QTestMan Script
 // 一般用法
 report title EEPROM Test
 report name Test_EEPROM.html  // 修改Report名稱，Report會生成在qs相同路徑下
 report name Test_EEPROM       // 修改Report名稱，非.html時會自動帶入.html副檔名，Report會生成在qs相同路徑下
 
 // Report路徑調整
 report name ../daily/Test_EEPROM   // 修改Report名稱與生成路徑，Report會生成在相對於qs路徑的"../daily/"下
 report name ../daily/Test_EEPROM/  // 只修改生成路徑，Report會生成相對於qs路徑的"../daily/Test_EEPROM"下，檔名自動生成
 report name C:\daily/Test_EEPROM   // 使用絕對路徑，Report會生成在"C:\daily"下

 // 變數取值
 $serial = asse1152326
 report name File_$(serial)  // 會自動帶入.html副檔名

 // 可使用HTML格式
 report note Line one<br>Line two
```

#### chart_line

根據給定的座標及數值畫出折線圖，並儲存在report中。

- 用法：
  - chart_line &lt;title&gt; |<X-axis>:<Y-axis>|<x>:<y>|<x2>:<y2>|....
- 說明：
  - &lt;title&gt;：該折線圖標題。
  - <X-axis> <Y-axis>：X軸和Y軸的名稱。
  - <x> <y>：座標點的x、y軸數值。
- 變數取值：✔ 支援，<x> <y>中可使用變數取值，需要用括弧$()刮起來。
- 範例：

```QTestMan Script
 // 一般用法
 chart_line ChartTest |Xaxis:Yaxis|1:2|3:4|7:8|9:10

 // 變數取值用法
 $x1 = 1
 $y1 = 2
 $x2 = 3
 $y2 = 4
 chart_line ChartTest |Xaxis:Yaxis|$(x1):$(y1)|$(x2):$(y2)
```

[chart_line example](檔案:Chart line example.png)

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

#### if

判斷條件，支援巢狀用法。

- 範例：
```QTestMan Script
 if matched
 {
    if $v1 == 0
       fail
 }
```

##### 特殊保留字用法

- 判斷'verify'結果的用法：if [matched | unmatched]
- 範例：
```QTestMan Script
 cs $v1 c1 uname -a
 verify $v1 PerseusMBW
 if unmatched
 {
    fail incorrect model
 }
 
 cs $v1 uname -a
 verify $v1 PerseusMBW
 if unmatched
    fail
```

- 判斷'io_host'與'io_local'結果的用法：if [throughput | iops | latency] [== | != | >= | > | < | <=] 數值
- 範例：
```QTestMan Script
 io_host z:\ File System SeqRead 128K Random
 if throughput < 2000
    fail

 io_host z:\ File System RandRead 4K Random
 if iops < 2000
 {
    fail
 }
```

##### 變數用法

- 變數與整數比較的用法：if $v [== | != | >= | > | < | <=] number
- 範例：
```QTestMan Script
 // Example 1
 if $v1 >= 10
    fail

 // Example 2: 變數取值
 $v1 = 10
 $v2 = 20
 if $v1 < $(v2)
    echo $v1 is less than $v2
```

- 變數與字串比較的用法：if $v [== | !=] string
- 範例：
```QTestMan Script
 // Example 1
 $v1 = abc
 if $v1 != abc
    fail

 // Example 2: 變數取值
 $v1 = abc
 $v2 = abc
 if $v1 == $(v2)
    echo $v1 is equal to $v2
```

##### 常數用法

- 字串與字串比較的用法：if string [== | !=] string
- 範例：
```QTestMan Script
 // Example 1
 if ABC == ABC
    echo the same
 if ABC != ABC
    echo different

 // Example 2: %BYPASS macro等同字串，因為會在執行script前就直接被覆蓋。 (Macro任何情況都要透過%()取值)
 %BYPASS = 1
 if %(BYPASS) == 1
    end
```

#### repeat

迴圈，用來多次執行。<number>若不指定或為0表示無窮迴圈。

- 用法：repeat <number>
- 範例：
```QTestMan Script
 // 執行10次
 repeat 10
 {
    cs c1 ls
 }

 // 建立1000個zvol
 repeat 1000
 {
    cs c1 zfs create -V 10M p1/v$(count)
    $count++;
 }

 // 無窮迴圈
 repeat 0
    cs c1 ls

 // 無窮迴圈
 repeat
 {
    cs c1 ls
 }

 // 重複$v1次
 repeat $v1
 {
    cs c1 ls
 }

 // 巢狀
 repeat 10 {
    repeat 10 {
       echo go
    }
 }
```

#### break

用來跳脫迴圈，也可以跳脫test item，注意只會跳一層。

- 用法：break
- 範例：
```QTestMan Script
 // 跳脫迴圈
 repeat
 {
    cs c1 ls
    if $v1 == 3
       break
 }

 // 跳脫test item
 # Test Item 1
 break
```
