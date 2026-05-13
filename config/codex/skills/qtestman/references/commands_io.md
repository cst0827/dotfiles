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
