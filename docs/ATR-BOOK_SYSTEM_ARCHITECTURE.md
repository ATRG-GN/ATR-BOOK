# ATR-BOOK: System Architecture Blueprint

เอกสารนี้สรุปกรอบสถาปัตยกรรมระดับระบบสำหรับ **ATR-BOOK (สมุดบันทึกอัจฉริยะ)** โดยเน้นความสามารถในการขยายตัว (Scalable) และการบูรณาการ AI แบบครบวงจร

## 1) สถาปัตยกรรมระดับระบบ (System Architecture)


> สถานะโค้ดปัจจุบันใน repository นี้ยังเป็นต้นแบบหน้ารายการฟีเจอร์เพียงหน้าเดียว (`lib/main.dart`)
> เอกสารฉบับนี้จึงควรถูกมองเป็น **สถาปัตยกรรมเป้าหมาย (target architecture)**
> สำหรับการขยายระบบในระยะถัดไป

ATR-BOOK ใช้แนวทาง **Clean Architecture** ควบคู่กับ **Feature-First Structure** เพื่อให้ทีมพัฒนาสามารถแยกความรับผิดชอบของแต่ละส่วนได้ชัดเจน ทดสอบได้ง่าย และเปลี่ยนเทคโนโลยีได้โดยกระทบธุรกิจน้อยที่สุด

### 1.1 Domain Layer
- เป็นแกนกลางของธุรกิจ ประกอบด้วย `Entities`, `Value Objects`, `Use Cases`
- ไม่มี dependency ไปยัง framework ภายนอก
- นิยาม contract ของ repository (interface) เพื่อให้ business logic ไม่ผูกติดกับแหล่งข้อมูลจริง

### 1.2 Data Layer
- ทำหน้าที่เชื่อม Domain กับแหล่งข้อมูลจริง
- ประกอบด้วย `Repository Implementations`, `Data Sources`, `DTO/Mappers`
- รองรับทั้ง
  - **Local**: SQLite/Hive สำหรับข้อมูลโน้ต การตั้งค่า และแคช
  - **Remote**: API สำหรับ LLM/TTS รวมถึงระบบ Authentication

### 1.3 Presentation Layer
- ส่วน UI และการจัดการ state
- ใช้ **BLoC/Cubit** สำหรับ state management
- แยกตาม feature เช่น `notes`, `settings`, `ai_assistant`, `export`

---

## 2) เทคโนโลยีหลัก (Core Tech Stack)

### 2.1 Flutter Cross-platform
- พัฒนาด้วย Flutter โค้ดฐานเดียว (single codebase)
- **Android**: build เป็น ARM machine code (`AAB/APK`) เพื่อประสิทธิภาพระดับ native
- **Web**: compile เป็น JavaScript + WASM พร้อมใช้ CanvasKit renderer เพื่อ UI fidelity สูง

การกำหนด **Framework** เป็นขั้นตอนสำคัญในการประเมินความสำเร็จของโครงการ เพราะทำให้สามารถวิเคราะห์ความต้องการของระบบได้ครบทั้งเชิงฟังก์ชันและเชิงประสบการณ์ผู้ใช้ (UX) โดยในบริบทของ ATR-BOOK ได้สรุปว่า **Flutter** เป็นเทคโนโลยีที่เหมาะสมที่สุดสำหรับการพัฒนาระบบนี้ เนื่องจากเป็นเฟรมเวิร์กของ Google ที่ใช้ภาษา **Dart** และรองรับแนวคิด **single codebase** เพื่อคอมไพล์ออกเป็นแอปแบบ native ได้หลายแพลตฟอร์ม ทั้งโค้ดเครื่องแบบ **ARM machine code** (Android) รวมถึงโค้ด **JavaScript** และ **WebAssembly** (Web) จึงตอบโจทย์ด้านประสิทธิภาพและคุณภาพการแสดงผลในระดับสูงสุด

### 2.2 AI Integration
- เชื่อมต่อ **Large Language Models (LLM)** สำหรับการสร้างข้อความ
- เชื่อมต่อ **Neural Speech Modeling (TTS)** สำหรับสังเคราะห์เสียงพูด
- ออกแบบฝั่งแอปให้รองรับการเปลี่ยน provider ได้ (provider-agnostic)

---

## 3) แนวทางการพัฒนาฟีเจอร์สำคัญ (Implementation Guidelines)

### 3.1 Media & File Handling
- ใช้ `image_picker` และ `file_picker`
- กำหนด Android permissions ใน `AndroidManifest.xml` อย่างชัดเจน
- บีบอัดภาพอัตโนมัติ `quality: 80` เพื่อลดขนาดไฟล์และประหยัด bandwidth

### 3.2 PDF Export แบบข้ามแพลตฟอร์ม
- ใช้ conditional flow ด้วย `kIsWeb`
- **Web**: สร้างไฟล์ดาวน์โหลดผ่าน `Blob` + `AnchorElement`
- **Android**: บันทึกไฟล์ลง Application Sandbox โดย `path_provider`

### 3.3 AI Orchestration (Text + Speech)
- วางระบบแบบ **API-first** บนมาตรฐาน **OpenAPI 3.1**
- รองรับ token handling, timeout, retry และ latency budgeting
- แยก service สำหรับ text generation และ speech synthesis อย่างอิสระ

#### รายละเอียดเชิงปฏิบัติ (Recommended Orchestration Flow)

1) **Streaming-first Text Generation**
- ในระดับ `Repository` ให้ expose เป็น `Stream<String>` (chunked response)
- ในระดับ `UseCase` สามารถ map stream เป็น domain events เช่น `GenerationStarted`, `GenerationChunkReceived`, `GenerationCompleted`
- ในระดับ UI ให้เรนเดอร์ข้อความแบบ incremental เพื่อลดความรู้สึก latency (perceived performance)

2) **Token Budgeting + Context Compression**
- เพิ่ม `TokenEstimator` ใน domain/service layer สำหรับคำนวณ token ก่อนยิง API
- หากเกิน budget ที่กำหนด ให้ใช้กลยุทธ์ `Summarize-to-Shorten`:
  - สรุปบริบทเดิมเป็น memory summary
  - แนบ summary + recent turns เพื่อรักษาความต่อเนื่องของบทสนทนา
- กำหนดนโยบาย fallback เป็นลำดับ: truncate -> summarize -> ask-user-confirm (กรณี prompt ยาวผิดปกติ)

3) **TTS Pipelining + Prefetching**
- แบ่งข้อความเป็น sentence/phrase queue
- เล่นเสียงชิ้นปัจจุบันพร้อม prefetch เสียงชิ้นถัดไปแบบ async
- ใช้ buffer threshold (เช่นมีเสียงล่วงหน้าอย่างน้อย 1 ชิ้น) เพื่อลดช่องว่างระหว่างประโยค
- กรณีเครือข่ายช้า ให้ fallback เป็น text-only mode พร้อมแจ้งสถานะผู้ใช้

4) **Reliability Controls**
- timeout เฉพาะจุด (connect/read/total)
- retry แบบ exponential backoff เฉพาะ error ที่ recover ได้
- circuit breaker เบื้องต้นสำหรับ provider ที่ล่มชั่วคราว
- เก็บ metrics: time-to-first-token, completion latency, tts buffering gap

### 3.4 BLoC State Model สำหรับ AI Assistant

เพื่อคงหลัก Clean Architecture ให้ state machine อยู่ในชั้น presentation แต่พึ่งพา use case ที่แยกชัดใน domain

- **Events**
  - `PromptSubmitted`
  - `SpeechSynthesisRequested`
  - `GenerationCancelled`
  - `RetryRequested`

- **States**
  - `AiIdle`
  - `AiGenerating(progress, partialText)`
  - `AiSpeaking(currentSentence, queueDepth)`
  - `AiSuccess(fullText, audioRefs)`
  - `AiFailure(errorModel, canRetry)`

- **แนวทางตัดสินใจเมื่อเกิดความผิดพลาด**
  - ความผิดพลาดเชิงเครือข่ายชั่วคราว -> ให้ BLoC trigger retry ตาม policy
  - ความผิดพลาดเชิงสิทธิ์ (401/403) -> ส่งออกเป็น domain auth failure เพื่อบังคับ refresh/login
  - ความผิดพลาดถาวร -> emit `AiFailure` พร้อมข้อความที่ map แล้วสำหรับ UI

---

## 4) AI Prompting Specifications (YAML-based Structural Prompts)

ATR-BOOK รองรับการกำกับ AI Coding Agent ผ่าน prompt แบบมีโครงสร้าง เพื่อลด hallucination และควบคุมคุณภาพสถาปัตยกรรม

### 4.1 System Orchestration Prompt
- ระบุบทบาท (persona) เป็น software architect
- กำหนด strict rules: SOLID, Clean Architecture, testability, dependency direction

### 4.2 Feature Implementation Prompt
- ระบุ interface ที่ต้องสร้าง/ใช้ให้ชัดเจน
- ระบุ dependency injection points
- ระบุข้อกำหนดเรื่อง error handling, state transitions และ acceptance criteria

---

## 5) Interoperability & API Contract

กำหนดสัญญาการเชื่อมต่อด้วย **OpenAPI 3.1.0**

### 5.1 Endpoints
- `POST /ai/generate` : สร้างข้อความ
- `POST /ai/synthesize` : สร้างเสียงสังเคราะห์ (`audio/mpeg`)

### 5.2 Security
- ใช้ **JWT Bearer Authentication**
- แยก access token lifecycle ออกจาก business use case
- รองรับ token refresh และ error mapping กลับสู่ domain failure

---

## 6) Deployment Strategy

### 6.1 Web
- Build ด้วย renderer คุณภาพสูง: `--web-renderer canvaskit`

### 6.2 Android
- Build production ด้วย:
  - `flutter build appbundle`
  - `--obfuscate`
- เพื่อเพิ่มความปลอดภัยจาก reverse engineering และลดความเสี่ยงการรั่วไหลของรายละเอียด implementation

---

## 7) Suggested Folder Skeleton (Feature-first + Clean)

```text
lib/
  core/
    network/
    error/
    utils/
  features/
    notes/
      domain/
      data/
      presentation/
    ai_assistant/
      domain/
      data/
      presentation/
    tts/
      domain/
      data/
      presentation/
    export/
      domain/
      data/
      presentation/
```

โครงสร้างนี้ช่วยให้ขยายระบบเป็นรายฟีเจอร์ได้ง่าย และรักษา dependency direction ตามหลัก Clean Architecture อย่างชัดเจน
