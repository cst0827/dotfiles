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
