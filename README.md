# Lark MCP Server (SSE/HTTP)

Remote MCP server สำหรับ Lark/Feishu OpenAPI — ใช้กับ Claude (Messages API + MCP) หรือเครื่องมือที่รองรับ MCP

## Quick Start (Local)
```bash
cp .env.example .env
# เติม APP_ID, APP_SECRET
npm i
npm run dev
# เปิด http://localhost:8080/health
```

## Deploy บน Render Pro

1. เชื่อม GitHub repo นี้ → **New Web Service** → ใช้ `render.yaml`

2. ตั้ง ENV:
   - `APP_ID` (secret)
   - `APP_SECRET` (secret) 
   - `LARK_DOMAIN` (default: `https://open.larksuite.com`)
   - `LARK_MCP_TOOLS` (เช่น `im.v1.message.create,calendar.v4.calendarEvent.create`) — แนะนำให้จำกัดในช่วงแรก

3. Deploy เสร็จแล้วตรวจ:
   ```bash
   curl -s https://<your-render-app>.onrender.com/health
   ```

**หมายเหตุ**: เซิร์ฟเวอร์ MCP รันด้วย `npx @larksuiteoapi/lark-mcp mcp --transport sse --host 0.0.0.0 --port $PORT`

## ใช้กับ Claude (Messages API + MCP)

ตัวอย่าง body (ย่อ):

```json
{
  "model": "claude-3-7-sonnet-2025-xx",
  "max_tokens": 2000,
  "system": "คุณคือ Lark Operations Agent ของ Hypelive ...",
  "messages": [{ "role": "user", "content": "สวัสดี ช่วยส่งประกาศลงกลุ่มทีมหน่อย" }],
  "mcp": {
    "servers": [
      {
        "name": "lark-openapi",
        "type": "sse", 
        "url": "https://<your-render-app>.onrender.com"
      }
    ]
  }
}
```

## Troubleshooting

- **401/403**: ตรวจ scope/permission ของแอปใน Lark Developer Console และโหมด token (tenant vs user)
- **SSE timeout**: เพิ่ม retry/backoff ฝั่ง client; บน Render Pro ไม่มี idling แต่ network อาจวูบ  
- **ลดความสับสนของโมเดล**: ตั้ง `LARK_MCP_TOOLS` ให้เหลือเท่าที่ต้องใช้

## สำหรับ Bitable Only

ถ้าจะ "เปิดแค่ Bitable" ไว้เทสต์ ให้ตั้งค่า `LARK_MCP_TOOLS` แบบนี้:

### วิธีที่ง่ายสุด (แนะนำ)
```bash
LARK_MCP_TOOLS=preset.bitable.default
```

### วิธีกำหนดเป็นรายทูล (ถ้าต้องการเลือกเอง)
```bash
LARK_MCP_TOOLS=bitable.v1.app.create,bitable.v1.appTable.create,bitable.v1.appTable.list,bitable.v1.appTableField.list,bitable.v1.appTableRecord.create,bitable.v1.appTableRecord.search,bitable.v1.appTableRecord.update
```

## สิ่งที่ต้องมีเวลาเรียก Bitable จริง

เวลาให้ Claude เรียกทูลฝั่ง Bitable เช่น `...appTableRecord.create` ต้องเตรียม `app_token` และ `table_id` ให้ถูกต้อง รวมถึง payload `fields` ตาม schema ของตาราง (สิทธิ์ต้องเป็นระดับที่แก้ไขได้) — ตรงนี้เป็นข้อกำหนดของ OpenAPI ฝั่ง Bitable เองครับ