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
