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
