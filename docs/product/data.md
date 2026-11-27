---
kind: data
---
# Dữ liệu

## Quan hệ

Thực thể Thú cưng nằm ở `modules/MD-01-pet-care/module.md` và thực thể Ví Xu nằm ở `modules/MD-02-coin-economy/module.md`.

```mermaid
erDiagram
    VI_XU["Ví Xu"] ||--o{ THU_CUNG["Thú cưng"] : "tích lũy và chi Xu cho"
```
