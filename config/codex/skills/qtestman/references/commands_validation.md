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
