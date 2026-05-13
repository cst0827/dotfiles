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
