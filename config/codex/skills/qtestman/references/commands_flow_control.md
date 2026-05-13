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
