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
