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
