# การกำหนดทางเทคนิคและสถาปัตยกรรมการพัฒนาแอปพลิเคชัน ATR-BOOK

## เอกสารสรุปฉบับย่อ

- ดูสรุปสถาปัตยกรรมล่าสุดได้ที่ `docs/ATR-BOOK_SYSTEM_ARCHITECTURE.md`
- ดูโครงสร้างโฟลเดอร์สำหรับเริ่มพัฒนาได้ที่ `docs/PROJECT_STRUCTURE.md`


## บทนำ

การพัฒนานวัตกรรมซอฟต์แวร์ในยุคปัจจุบันมีความซับซ้อนและต้องการการบูรณาการเทคโนโลยีที่หลากหลายเข้าด้วยกัน แอปพลิเคชันสมุดบันทึกอัจฉริยะภายใต้ชื่อ "ATR-BOOK" (หรือตัวย่อ "ATR-BOOK") เป็นระบบที่ถูกออกแบบมาเพื่อยกระดับประสบการณ์การจดบันทึกแบบดั้งเดิมให้ก้าวหน้ายิ่งขึ้นด้วยการผสานรวมระบบปัญญาประดิษฐ์ (Artificial Intelligence) หัวใจหลักของระบบนี้คือความสามารถในการสร้างข้อความอัตโนมัติ (AI Text Generation) และการสังเคราะห์ข้อความให้เป็นเสียงพูด (Text-to-Speech หรือ TTS) นอกเหนือจากฟีเจอร์พื้นฐานของสมุดบันทึก เช่น การตั้งค่าแอปพลิเคชัน การแนบไฟล์ การบันทึกภาพ และการสร้างเอกสารในรูปแบบ PDF


> **สถานะต้นแบบปัจจุบัน:** ใน repository นี้เป็นต้นแบบหน้าจอรายการฟีเจอร์ (Feature Backlog) เพื่อใช้ทบทวนขอบเขตงานก่อนพัฒนาระบบจริง (ยังไม่ครอบคลุมฟีเจอร์ AI, TTS, แนบไฟล์ และส่งออก PDF ตามเอกสารเชิงสถาปัตยกรรมทั้งหมด)

รายงานฉบับนี้จัดทำขึ้นเพื่อเป็นเอกสารทางเทคนิคระดับสากลที่ครอบคลุมสถาปัตยกรรมซอฟต์แวร์ โครงสร้างโฟลเดอร์ โค้ดตัวอย่าง มาตรฐานการเขียนคำสั่งสำหรับให้ AI ช่วยเขียนโค้ด (AI Prompting Specifications) และเอกสารการบูรณาการผ่าน OpenAPI 3.1 เพื่อให้มั่นใจว่าระบบสามารถเปิดให้บริการได้ทั้งบนแพลตฟอร์มเว็บแอปพลิเคชัน (Web Application) และสามารถนำขึ้นเผยแพร่บน Google Play Store สำหรับอุปกรณ์แอนดรอยด์ (Android) ได้อย่างสมบูรณ์แบบ

## เทคโนโลยีหลักและกลยุทธ์การพัฒนาข้ามแพลตฟอร์ม

การกำหนดกรอบการทำงาน (Framework) เป็นขั้นตอนแรกที่มีความสำคัญอย่างยิ่งต่อความสำเร็จของโครงการ เพื่อตอบสนองข้อกำหนดที่ต้องการให้แอปพลิเคชันสามารถทำงานได้ทั้งบนเว็บและบนระบบปฏิบัติการแอนดรอยด์ การวิเคราะห์ข้อมูลเชิงสถาปัตยกรรมบ่งชี้ว่า **Flutter** เป็นเทคโนโลยีที่เหมาะสมที่สุดสำหรับการพัฒนาระบบนี้ กรอบการทำงาน Flutter ซึ่งพัฒนาโดยบริษัท Google ใช้ภาษาโปรแกรม Dart ในการเขียนคำสั่ง โดยมีจุดเด่นในการใช้ฐานรหัส (Codebase) เพียงชุดเดียวในการคอมไพล์ (Compile) ให้ออกมาเป็นแอปพลิเคชันที่สามารถทำงานได้แบบ Native บนหลากหลายแพลตฟอร์ม สำหรับระบบแอนดรอยด์ โค้ดจะถูกแปลงเป็นภาษาเครื่อง (ARM Machine Code) ในขณะที่บนเว็บ โค้ดจะถูกแปลงเป็น JavaScript และ WebAssembly ที่ได้รับการปรับแต่งมาอย่างละเอียดเพื่อประสิทธิภาพสูงสุด

การเลือกใช้กรอบการทำงานแบบข้ามแพลตฟอร์มนี้มีความจำเป็นอย่างยิ่งเมื่อแอปพลิเคชันต้องจัดการกับฟีเจอร์ที่มีความซับซ้อน เช่น การจัดการระบบไฟล์ การเข้าถึงฮาร์ดแวร์ของอุปกรณ์ (เช่น กล้องถ่ายรูปและพื้นที่จัดเก็บข้อมูลภายใน) และการเชื่อมต่อกับระบบปัญญาประดิษฐ์แบบเรียลไทม์

| ข้อกำหนดของฟีเจอร์ | ขีดความสามารถของระบบ Flutter | ประโยชน์เชิงสถาปัตยกรรม |
| :--- | :--- | :--- |
| **การส่งมอบข้ามแพลตฟอร์ม (Cross-Platform Delivery)** | สามารถคอมไพล์เป็นแพ็กเกจ Android (APK/AAB) และ Web (HTML/WASM) ได้จากโค้ดชุดเดียวกัน | ลดระยะเวลาในวงจรการพัฒนาซอฟต์แวร์และรับประกันความเท่าเทียมกันของฟีเจอร์ในทุกแพลตฟอร์ม |
| **ส่วนต่อประสานผู้ใช้ประสิทธิภาพสูง (High-Performance UI)** | ใช้เอนจินการเรนเดอร์ Impeller/Skia ที่สามารถทำงานได้ราบรื่นในระดับ 60-120 เฟรมต่อวินาที | การแสดงผลที่ลื่นไหลสำหรับอินเทอร์เฟซสมุดบันทึกที่ซับซ้อนและการตอบสนองของระบบปัญญาประดิษฐ์ที่เปลี่ยนแปลงตลอดเวลา |
| **การจัดการไฟล์และสื่อ (File and Media Handling)** | มีระบบนิเวศปลั๊กอินที่แข็งแกร่ง (เช่น `image_picker`, `file_picker`, `path_provider`) | สร้างมาตรฐานการเข้าถึงฮาร์ดแวร์ของอุปกรณ์โดยลดความแตกต่างของข้อจำกัดในแต่ละระบบปฏิบัติการ |
| **การสร้างเอกสาร PDF (PDF Generation)** | สามารถวาดเนื้อหาลงบนผืนผ้าใบ (Canvas) ได้โดยตรงผ่านแพ็กเกจ `pdf` | การเรนเดอร์เอกสารมีความแน่นอนและไม่ขึ้นอยู่กับระบบปฏิบัติการของเครื่องแม่ข่าย |

## สถาปัตยกรรมซอฟต์แวร์: Clean Architecture และ Feature-First Organization

ความมั่นคงของโครงสร้างระบบ ATR-BOOK ขึ้นอยู่กับการประยุกต์ใช้หลักการ **Clean Architecture** ร่วมกับการจัดระเบียบไดเรกทอรีแบบ **Feature-First** แนวคิด Clean Architecture จะช่วยให้เกิดการแยกความสนใจ (Separation of Concerns) อย่างชัดเจน โดยทำการแยกตรรกะทางธุรกิจ (Business Logic) ที่เป็นแกนหลักของแอปพลิเคชันออกจากกรอบการทำงานภายนอก ส่วนต่อประสานกับผู้ใช้ (User Interface) และ Application Programming Interface (API) ของบุคคลที่สาม การลดการพึ่งพากัน (Decoupling) ในลักษณะนี้เป็นสิ่งสำคัญอย่างยิ่งสำหรับแอปพลิเคชันที่บูรณาการระบบปัญญาประดิษฐ์ เนื่องจากผู้ให้บริการโมเดลภาษาขนาดใหญ่ (LLM) หรือเอนจินสังเคราะห์เสียง (TTS) อาจมีการเปลี่ยนแปลงได้ในอนาคต ซึ่งสถาปัตยกรรมที่ดีจะช่วยให้สามารถปรับเปลี่ยนผู้ให้บริการได้โดยไม่ต้องเขียนตรรกะหลักของระบบใหม่ทั้งหมด

การออกแบบสถาปัตยกรรมซอฟต์แวร์จะแบ่งออกเป็นเลเยอร์ (Layers) ที่มีความรับผิดชอบแตกต่างกันอย่างชัดเจน เลเยอร์ในสุดคือ **โดเมนเลเยอร์ (Domain Layer)** ซึ่งบรรจุกฎทางธุรกิจที่เป็นแกนกลาง เอนทิตี (Entities) เช่น `NotebookEntry` หรือ `AiConfiguration` และส่วนอินเทอร์เฟซของที่เก็บข้อมูล (Repository Interfaces) ที่เป็นนามธรรม เลเยอร์นี้จะต้องเป็นอิสระจากแพ็กเกจภายนอกทั้งหมด ถัดมาคือ **ดาต้าเลเยอร์ (Data Layer)** ที่รับผิดชอบในการนำอินเทอร์เฟซที่กำหนดไว้ในโดเมนเลเยอร์มาปฏิบัติจริง เลเยอร์นี้ทำหน้าที่จัดการการดึงและจัดเก็บข้อมูลจากฐานข้อมูลภายในเครื่อง (เช่น SQLite หรือ Hive) และ API ระยะไกล (เช่น จุดสิ้นสุดของระบบสร้างข้อความ AI และบริการ TTS) ส่วนนอกสุดคือ **พรีเซนเทชันเลเยอร์ (Presentation Layer)** ซึ่งประกอบด้วยองค์ประกอบส่วนต่อประสานกับผู้ใช้ (Widgets) และระบบจัดการสถานะ (State Management) ซึ่งจะตอบสนองต่อการเปลี่ยนแปลงสถานะและเรียกใช้งานยูสเคส (Use Cases) ที่กำหนดไว้ในโดเมนเลเยอร์

เพื่อเพิ่มความสามารถในการขยายระบบให้ถึงขีดสุด โครงการนี้ใช้โครงสร้างโฟลเดอร์แบบ **Feature-First** แทนที่จะจัดกลุ่มไฟล์ตามประเภทของเลเยอร์ทางเทคนิค ไฟล์ทั้งหมดจะถูกจัดกลุ่มตามฟีเจอร์ที่ไฟล์เหล่านั้นรับผิดชอบ โครงสร้างไฟล์และโฟลเดอร์ของระบบ ATR-BOOK ถูกกำหนดไว้ดังนี้:

```
atr_book/
├── android/                   # โฟลเดอร์การตั้งค่าแบบ Native สำหรับระบบ Android (สำหรับการอัปโหลดขึ้น Play Store)
├── web/                       # โฟลเดอร์การตั้งค่าแบบ Native สำหรับเว็บแอปพลิเคชัน (Web App)
├── lib/
│   ├── core/                  # ทรัพยากรส่วนกลางที่ใช้ร่วมกันทั้งแอปพลิเคชัน
│   │   ├── constants/         # ตัวแปรค่าคงที่ เช่น กุญแจ API, ข้อความสากล, และขนาดของเลย์เอาต์
│   │   ├── errors/            # คลาสข้อยกเว้น (Exceptions) และโมเดลความล้มเหลว (Failure Models)
│   │   ├── network/           # การตั้งค่าไคลเอนต์ HTTP และตัวดักจับการเรียกข้อมูล (Interceptors)
│   │   ├── theme/             # การตั้งค่ารูปแบบสีและตัวอักษรของแอปพลิเคชัน
│   │   └── utils/             # ฟังก์ชันช่วยเหลือ เช่น ระบบจัดการการขอสิทธิ์เข้าถึงฮาร์ดแวร์ (Permissions)
│   ├── features/              # โมดูลที่จัดระเบียบตามฟีเจอร์ (Feature-First)
│   │   ├── ai_assistant/      # ระบบจัดการปัญญาประดิษฐ์ (Text Generation และ TTS)
│   │   │   ├── data/
│   │   │   │   ├── datasources/ # โค้ดสำหรับติดต่อกับ API ของ LLM และ TTS ระยะไกล
│   │   │   │   ├── models/      # วัตถุรับส่งข้อมูล (Data Transfer Objects - DTOs) สำหรับการตอบกลับของ AI
│   │   │   │   └── repositories/# การนำอินเทอร์เฟซจาก Domain Layer มาเขียนเป็นโค้ดปฏิบัติการจริง
│   │   │   ├── domain/
│   │   │   │   ├── entities/    # วัตถุทางธุรกิจหลัก (เช่น AiPrompt, AudioResult)
│   │   │   │   ├── repositories/# อินเทอร์เฟซนามธรรมสำหรับบริการปัญญาประดิษฐ์
│   │   │   │   └── usecases/    # ตรรกะการดำเนินการ (เช่น GenerateTextUseCase)
│   │   │   └── presentation/
│   │   │       ├── controllers/ # ระบบจัดการสถานะ (State Management) สำหรับการโต้ตอบกับ AI
│   │   │       └── widgets/     # องค์ประกอบส่วนต่อประสานผู้ใช้ที่นำมาใช้ซ้ำได้สำหรับห้องแชทหรือเครื่องเล่นเสียง
│   │   ├── notebook/          # ฟีเจอร์หลักสำหรับการจัดการสมุดบันทึก
│   │   │   ├── data/          # การทำงานกับฐานข้อมูลในเครื่อง (สร้าง อ่าน อัปเดต ลบ ข้อมูลสมุดบันทึก)
│   │   │   ├── domain/        # เอนทิตีบันทึกและกฎทางธุรกิจ
│   │   │   └── presentation/  # หน้าจอแก้ไขบันทึกและหน้ารายการบันทึก
│   │   ├── document_export/   # ฟีเจอร์สำหรับการสร้างและส่งออกไฟล์ PDF
│   │   │   ├── data/          # ตรรกะการโต้ตอบกับระบบไฟล์
│   │   │   ├── domain/        # กฎการจัดรูปแบบโครงสร้างเอกสาร PDF
│   │   │   └── presentation/  # หน้าต่างการส่งออกและหน้าจอแสดงตัวอย่างเอกสาร
│   │   ├── media_attachment/  # ระบบจัดการการแนบภาพและไฟล์
│   │   └── settings/          # ฟีเจอร์การตั้งค่าแอปพลิเคชัน (ธีม, โมเดลเสียง TTS)
│   └── main.dart              # จุดเริ่มต้นการทำงานของแอปพลิเคชันและการฉีดการพึ่งพา (Dependency Injection)
```

การจัดหมวดหมู่โครงสร้างในลักษณะนี้ช่วยให้มั่นใจได้ว่านักพัฒนา หรือแม้แต่ตัวแทนปัญญาประดิษฐ์สำหรับการเขียนโค้ด (AI Coding Agents) สามารถแยกจุดโฟกัสไปที่ไดเรกทอรีเดียวเมื่อต้องการสร้างหรือแก้ไขฟีเจอร์ใดฟีเจอร์หนึ่ง ซึ่งเป็นการลดความเสี่ยงในการสร้างผลกระทบที่ไม่ได้ตั้งใจต่อโมดูลอื่นๆ ในระบบ

## ข้อกำหนดและรายละเอียดการพัฒนาฟีเจอร์หลัก

การพัฒนาขีดความสามารถหลักของ ATR-BOOK จำเป็นต้องมีการระบุตรรกะทางเทคนิคอย่างละเอียด โค้ดตัวอย่างในเอกสารส่วนนี้เขียนขึ้นด้วยภาษาโปรแกรม Dart โดยยึดตามมาตรฐานสากลและได้รับการออกแบบมาให้ปราศจากบริบททางธุรกิจที่ผูกมัดเฉพาะเจาะจง เพื่อให้ปัญญาประดิษฐ์สามารถทำความเข้าใจโครงสร้างและนำไปใช้ได้อย่างกว้างขวางและถูกต้องแม่นยำ

### 1. ระบบจัดการสื่อและการแนบไฟล์

การอนุญาตให้ผู้ใช้แอปพลิเคชันสามารถแนบไฟล์และจับภาพจากกล้องจำเป็นต้องมีการเข้าถึง API ของฮาร์ดแวร์อุปกรณ์ แพ็กเกจ `image_picker` ถูกนำมาใช้เพื่อสร้างมาตรฐานในกระบวนการนี้ ทั้งนี้ ในส่วนของระบบปฏิบัติการแอนดรอยด์ จำเป็นต้องมีการกำหนดสิทธิ์การเข้าถึงอย่างชัดเจนในไฟล์การตั้งค่า

การระบุข้อกำหนดในไฟล์ `AndroidManifest.xml` สำหรับแอปพลิเคชันบน Android เป็นไปตามมาตรฐานดังต่อไปนี้:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.CAMERA"/>
</manifest>
```

สำหรับการเขียนโค้ดบริการจัดการสื่อภายในแพลตฟอร์ม โค้ดตัวอย่างต่อไปนี้แสดงให้เห็นถึงโครงสร้างที่เป็นมาตรฐานระดับสากล ซึ่งสามารถจัดการข้อผิดพลาดและปรับปรุงประสิทธิภาพของภาพได้:

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// บริการสำหรับจัดการการเลือกสื่อจากพื้นที่จัดเก็บข้อมูลของอุปกรณ์หรือฮาร์ดแวร์กล้อง
class MediaAttachmentService {
  final ImagePicker _picker = ImagePicker();

  /// นำเสนอตัวเลือกให้ผู้ใช้เลือกภาพจากแหล่งที่มาที่ระบุ (กล้อง หรือ คลังภาพ)
  Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // พารามิเตอร์สำหรับการปรับคุณภาพรูปภาพเพื่อลดขนาดไฟล์
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Hardware interaction failure: $e');
    }
  }
}
```

บริการนี้ได้รวมระบบการบีบอัดภาพในตัวโดยตั้งค่า `imageQuality: 80` ซึ่งเป็นแนวปฏิบัติที่ดีที่สุดสำหรับการพัฒนาแอปพลิเคชันบนมือถือ เพื่อลดการใช้พื้นที่จัดเก็บข้อมูลภายในและประหยัดแบนด์วิดท์ในระหว่างการซิงโครไนซ์ข้อมูลขึ้นสู่ระบบคลาวด์ในอนาคต

### 2. การสร้างและส่งออกเอกสาร PDF

แอปพลิเคชันจำเป็นต้องมีความสามารถในการสร้างเอกสาร PDF ที่มีมาตรฐานจากรายการบันทึกในสมุด กระบวนการนี้ต้องรับมือกับความแตกต่างของระบบจัดการไฟล์ระหว่างแพลตฟอร์มเว็บและอุปกรณ์พกพา แพ็กเกจ `pdf` มอบเอนจินสำหรับการเรนเดอร์เอกสาร ในขณะที่ `path_provider` จะถูกใช้งานสำหรับระบบแอนดรอยด์ และไลบรารี `dart:html` จะถูกใช้งานสำหรับการทำงานบนเว็บ โครงสร้างการเขียนโค้ดเพื่อแก้ปัญหาการทำงานข้ามแพลตฟอร์มจะเป็นไปตามรูปแบบดังต่อไปนี้:

```dart
import 'dart:io';
import 'package:flutter/foundation.dart'; // สำหรับการตรวจสอบแพลตฟอร์มผ่านตัวแปร kIsWeb
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
// นำเข้าไลบรารีสำหรับจัดการไฟล์บนเว็บแบบมีเงื่อนไข เพื่อรักษาความสามารถในการคอมไพล์ข้ามแพลตฟอร์ม
import 'package:universal_html/html.dart' as html; 

/// บริการที่รับผิดชอบในการสร้างและบันทึกเอกสาร PDF
class DocumentExportService {
  
  /// สร้างเอกสาร PDF จากเนื้อหาและชื่อเรื่องที่กำหนด
  Future<Uint8List> generateDocument(String title, String content) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[ // Ensure this returns a list of widgets
            pw.Header(level: 0, text: title),
            pw.Paragraph(text: content),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  /// บันทึกข้อมูลไบต์ของ PDF ลงในระบบไฟล์ที่เหมาะสมกับแพลตฟอร์ม
  Future<void> saveDocument(Uint8List byteData, String fileName) async {
    final String fullFileName = '$fileName.pdf';

    if (kIsWeb) {
      // การดำเนินการสำหรับเว็บแอปพลิเคชัน (Web App)
      final blob = html.Blob([byteData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
       ..setAttribute('download', fullFileName)
       ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // การดำเนินการสำหรับแอนดรอยด์ (พื้นที่จัดเก็บไฟล์ภายในอุปกรณ์)
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = directory.path;
      final File file = File('$path/$fullFileName');
      await file.writeAsBytes(byteData);
    }
  }
}
```

การประมวลผลแบบมีเงื่อนไขผ่านตัวแปร `kIsWeb` ถือเป็นหัวใจสำคัญของกระบวนการนี้ สถาปัตยกรรมนี้รับประกันว่าโค้ดชุดเดียวกันจะสามารถสร้างคำสั่งการดาวน์โหลดผ่านเบราว์เซอร์เมื่อทำงานเป็นเว็บแอปพลิเคชัน ในขณะเดียวกันก็สามารถเขียนข้อมูลลงในพื้นที่ทราย (Sandbox Directory) ของแอปพลิเคชันบนอุปกรณ์แอนดรอยด์ได้อย่างปลอดภัย โดยไม่เกิดข้อผิดพลาดในการทำงานข้ามระบบปฏิบัติการ

### 3. การประสานงานของระบบสร้างข้อความและเสียงพูดด้วย AI (Text Generation & TTS Orchestration)

ความแตกต่างที่สำคัญของแอปพลิเคชัน ATR-BOOK คือการบูรณาการระบบปัญญาประดิษฐ์เข้ากับกระบวนการทำงาน สถาปัตยกรรมได้รับการออกแบบโดยใช้แนวคิด API-first design ซึ่งจะใช้ไคลเอนต์ HTTP มาตรฐานในการสื่อสารกับโมเดลภาษาขนาดใหญ่ (LLMs) และเซิร์ฟเวอร์สำหรับการอนุมานเสียง (TTS Inference Servers) การเชื่อมต่อกับระบบ AI ต้องดำเนินการผ่านคลาสพื้นที่เก็บข้อมูล (Repository Class) ใน Data Layer ดังต่อไปนี้:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// พื้นที่เก็บข้อมูลสำหรับการจัดการการสื่อสารกับ API ภายนอกของปัญญาประดิษฐ์
class AiIntegrationRepository {
  final String _baseUrl;
  final String _apiKey;

  AiIntegrationRepository({required String baseUrl, required String apiKey})
      : _baseUrl = baseUrl,
        _apiKey = apiKey;

  /// สร้างข้อความตอบกลับตามบริบทที่ผู้ใช้ระบุ
  Future<String> generateText(String prompt) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/generate'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'prompt': prompt,
        'temperature': 0.7,
        'max_tokens': 1500,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['output_text'] as String;
    } else {
      throw Exception('AI API returned an error: ${response.statusCode}');
    }
  }

  /// ร้องขอสตรีมเสียงสังเคราะห์จากข้อมูลข้อความ
  Future<List<int>> synthesizeSpeech(String text, String voiceModel) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/v1/synthesize'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'text': text,
        'voice_model': voiceModel,
      }),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('TTS Engine returned an error: ${response.statusCode}');
    }
  }
}
```

สำหรับการเล่นไฟล์เสียง TTS บนอุปกรณ์ของผู้ใช้งาน สถาปัตยกรรมระบบจะดึง Web Audio API มาใช้สำหรับแพลตฟอร์มเว็บ และใช้ตัวเล่นสื่อแบบ Native ผ่านแพ็กเกจข้ามแพลตฟอร์ม (เช่น `audioplayers` หรือ `flutter_tts`) สำหรับระบบแอนดรอยด์ การแยกระบบตรรกะการสร้างเสียง (API call) ออกจากระบบตรรกะการเล่นเสียง (UI interaction) เป็นสิ่งจำเป็นเพื่อรักษาขอบเขตที่ชัดเจนตามหลักการ Clean Architecture ซึ่งกระบวนการทางสถาปัตยกรรมแบบท่อ (Pipeline) ของ TTS นี้จะเริ่มจากการวิเคราะห์ข้อความ การสร้างแบบจำลองเสียงประสาท (Neural Speech Modeling) และการส่งมอบข้อมูลเสียง

### 4. ระบบการจัดการตั้งค่าแอปพลิเคชัน (Application Settings Management)

โมดูลการตั้งค่าของระบบรับหน้าที่ในการจัดเก็บความพึงพอใจและตัวเลือกของผู้ใช้งาน (เช่น การเลือกโมเดลเสียง TTS, ธีมมืดหรือสว่าง, หรือจุดสิ้นสุดของ API) โมดูลนี้พึ่งพาระบบจัดเก็บข้อมูลแบบคีย์-ค่า (Key-Value Store) ภายในเครื่อง เพื่อความรวดเร็วในการเข้าถึงและเรียกใช้งาน

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// จัดการพารามิเตอร์การกำหนดค่าแบบถาวรของแอปพลิเคชัน
class SettingsManager {
  static const String _themeKey = 'APP_THEME';
  static const String _voiceKey = 'TTS_VOICE_PREFERENCE';

  /// บันทึกค่าที่ต้องการจัดเก็บไว้ในอุปกรณ์
  Future<void> saveStringPreference(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// ดึงข้อมูลค่าที่จัดเก็บไว้ออกมาเพื่อใช้งาน
  Future<String?> getStringPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
```

## มาตรฐานข้อกำหนดทางเทคนิคสากลสำหรับการให้ AI เขียนโค้ด (Universal Technical Specifications for AI Code Generation)

ความท้าทายระดับสูงประการหนึ่งในการพัฒนาซอฟต์แวร์ยุคปัจจุบัน คือการควบคุมการทำงานของตัวแทนปัญญาประดิษฐ์สำหรับการเขียนโค้ด (AI Coding Agents เช่น Cursor, GitHub Copilot หรือ Cline) การป้อนคำสั่ง (Prompt) ด้วยภาษาธรรมชาติที่เต็มไปด้วยความคลุมเครือมักก่อให้เกิดปัญหาหนี้ทางเทคนิค (Technical Debt) โค้ดที่สร้างขึ้นอาจขาดโครงสร้าง ไม่เป็นไปตามมาตรฐาน หรือมีข้อผิดพลาดเชิงตรรกะ

มาตรฐานอุตสาหกรรมในปัจจุบันสำหรับการโต้ตอบกับโมเดลการสร้างรหัสขั้นสูง คือการใช้ข้อกำหนดที่จัดรูปแบบโครงสร้างอย่างเคร่งครัด เช่น YAML หรือ JSON รูปแบบ YAML ได้รับการยอมรับอย่างกว้างขวางว่ามีประสิทธิภาพสูง เนื่องจากมีโครงสร้างลำดับชั้นที่มนุษย์สามารถอ่านทำความเข้าใจได้ง่าย ในขณะเดียวกันก็ช่วยลดความซ้ำซ้อนของการใช้สัญลักษณ์ (Token-Heavy Syntax) ซึ่งช่วยประหยัดค่าใช้จ่ายในการประมวลผลผ่าน API โครงสร้างของ Prompt ที่ดีตามหลักวิศวกรรม (Prompt Engineering) จะต้องประกอบด้วยส่วนของกฎระเบียบ (Rule) ภาระงาน (Task) กรอบป้องกัน (Guardrails) ข้อมูลบริบท (Data) และรูปแบบผลลัพธ์ (Output Structure) อย่างชัดเจน

ข้อมูลสคีมา (Schemas) แบบ YAML ด้านล่างนี้เป็นตัวแทนของคำสั่งระดับสากลที่จำเป็นสำหรับปัญญาประดิษฐ์ เพื่อให้ AI สามารถสร้างโมดูลสำหรับ ATR-BOOK ได้อย่างเป็นอิสระและมีความแม่นยำสูง การใช้เทมเพลตเหล่านี้จะรับประกันว่าผลลัพธ์โค้ดที่ได้จะปฏิบัติตามมาตรฐานการเขียนโค้ดระดับโลกและแนวทางสถาปัตยกรรมที่กำหนดไว้ในเอกสารฉบับนี้อย่างเคร่งครัด โดยปราศจากบริบทที่ไม่จำเป็นติดไปกับตัวโค้ด

### โครงสร้างคำสั่งหลักสำหรับควบคุมระบบ (System Orchestration Prompt)

รูปแบบ YAML คำสั่งนี้เป็นจุดเริ่มต้นสำหรับสั่งการ AI ถึงกฎกติการะดับโลกของโครงการ เพื่อให้แน่ใจว่า AI เข้าใจถึงเทคโนโลยีที่ใช้ สถาปัตยกรรม และแบบแผนการเขียนโปรแกรมที่กำหนดไว้

```yaml
role_definition:
  persona: Senior Cross-Platform Software Architect
  expertise: [Flutter, Dart, Clean Architecture, SOLID, Android, Web, AI Integration]
  behavior: 
    - Output ONLY valid, compilable code without conversational filler.
    - Strictly adhere to SOLID principles and Clean Architecture.
    - Write code that conforms to global international standards and English nomenclature.

project_context:
  app_name: ATR-BOOK (atr-book)
  platforms: [Android, Web]
  framework: Flutter (Latest Stable Channel)
  architecture: 
    pattern: Feature-First Clean Architecture
    state_management: BLoC / Cubit
    layers: [Domain, Data, Presentation]

strict_coding_guidelines:
  language: English (for all variables, classes, methods, and inline comments)
  error_handling: Implement comprehensive try-catch blocks mapped to custom Failure models.
  platform_checks: Use `kIsWeb` from `flutter/foundation.dart` when handling file I/O to ensure cross-platform compatibility.
  documentation: Provide standard DartDoc (`///`) for all public classes and methods.

prohibited_actions:
  - Do not use deprecated Flutter widgets or methods.
  - Do not place business logic inside UI widgets.
  - Do not hardcode API keys or localized strings.
```

### โครงสร้างคำสั่งการพัฒนาฟีเจอร์: บริการปัญญาประดิษฐ์ (Feature Implementation Prompt: AI Services)

คำสั่งด้านล่างนี้ระบุข้อกำหนดเฉพาะเจาะจงสำหรับการสร้าง Data Layer ของการผสานรวมระบบปัญญาประดิษฐ์

```yaml
task_specification:
  action: Implement the Data Layer for the AI Assistant feature.
  target_directory: lib/features/ai_assistant/data/repositories/
  file_name: ai_repository_impl.dart

requirements:
  interfaces_to_implement:
    - name: IAiRepository
      methods:
        - Future<Either<Failure, String>> generateText(String prompt)
        - Future<Either<Failure, Uint8List>> synthesizeSpeech(String text)
  
  dependencies_to_inject:
    - http.Client (for network requests)
    - INetworkInfo (for connectivity checking)
  
  implementation_details:
    - Create a class named `AiRepositoryImpl` that implements `IAiRepository`.
    - Check network connectivity before making API calls. Return `NetworkFailure` if offline.
    - Handle HTTP response codes: Return `ServerFailure` for status codes other than 200.
    - Parse the JSON response deterministically using `jsonDecode`.

validation_criteria:
  - Code must be fully strongly-typed (no `dynamic` where avoidable).
  - Code must use the `fpdart` or `dartz` package for functional error handling (Either/Left/Right).
```

### โครงสร้างคำสั่งการพัฒนาฟีเจอร์: การส่งออกไฟล์ PDF (Feature Implementation Prompt: PDF Export)

คำสั่งนี้นำทาง AI ในการสร้างตัวส่งออกเอกสารแบบข้ามแพลตฟอร์มอย่างเป็นระบบ

```yaml
task_specification:
  action: Implement the PDF Export Service.
  target_directory: lib/features/document_export/data/
  file_name: pdf_export_service.dart

requirements:
  packages:
    - pdf: ^3.11.0
    - path_provider: ^2.1.0
    - universal_html: ^2.2.4
  
  methods:
    - name: exportNotebookEntry
      parameters: 
        - title (String)
        - content (String)
      behavior:
        - Generate a multi-page PDF document.
        - Add a standard header with the title.
        - Add the content as standard paragraphs.
        - Save the file as "atr-book-export.pdf".
        - Use conditional imports and `kIsWeb` to trigger an anchor element download on the web, and `getApplicationDocumentsDirectory` for Android.

validation_criteria:
  - The implementation must not crash on Web due to `dart:io` calls. Use conditional importing or `universal_io`.
```

การจัดเตรียมโครงสร้างรูปแบบ YAML ที่ไม่มีการระบุบริบททางธุรกิจเหล่านี้ ช่วยให้นักพัฒนาสามารถตัดความคลุมเครือของภาษาธรรมชาติออกไปได้อย่างสิ้นเชิง ตัวแทน AI จะทำหน้าที่เสมือนตัวแปลภาษาที่กำหนดค่าได้อย่างแน่นอน (Deterministic Compiler) ซึ่งจะแปลข้อกำหนดโครงสร้างให้กลายเป็นโค้ดสำหรับการใช้งานในระดับผลิตภัณท์มาตรฐานอุตสาหกรรมโดยอัตโนมัติ

## การบูรณาการและเชื่อมโยงข้อมูลกับแพลตฟอร์มอื่นผ่านมาตรฐาน OpenAPI 3.1 (Platform Integration & Interoperability)

เพื่อให้เกิดการเชื่อมโยงการใช้งานและบริการส่งต่อข้อมูลไปยังแพลตฟอร์มเว็บ ฐานข้อมูลของระบบอื่นๆ หรือการเปิดกว้างให้บุคคลที่สามสามารถบูรณาการเข้ากับระบบ ATR-BOOK เมื่อผู้ใช้งานระบบอื่นมีความต้องการ บริการหลังบ้าน (Backend Services) จำเป็นต้องมีการจัดทำเอกสารที่มีมาตรฐานสากล สคีมา API มาตรฐานช่วยให้แอปพลิเคชันภายนอกสามารถโต้ตอบเชิงโปรแกรมกับฟีเจอร์ปัญญาประดิษฐ์และการจัดการเอกสารของระบบได้อย่างมีประสิทธิภาพ

ข้อมูลต่อไปนี้เป็นเอกสารข้อกำหนดเชิงเทคนิคตามมาตรฐาน OpenAPI 3.1.0 สำหรับอธิบายการเชื่อมต่อปลายทางทั้งหมดในระบบ ATR-BOOK อย่างสมบูรณ์ สคีมานี้จัดเป็นมาตรฐานไวยากรณ์สากลที่เครื่องจักรสามารถอ่านได้ (Machine-readable) และมนุษย์สามารถทำความเข้าใจได้ ช่วยให้เกิดการสร้าง SDK สำหรับไคลเอนต์ (Client SDKs) ชุดทดสอบ และชุดเอกสารอัตโนมัติ ทำให้ผู้พัฒนาแพลตฟอร์มอื่นสามารถอ้างอิงและเชื่อมโยงข้อมูลเข้าด้วยกันได้อย่างถูกต้องแม่นยำตามไวยากรณ์โลก

```yaml
openapi: 3.1.0
info:
  title: ATR-BOOK API Integration Service
  description: >
    เอกสารข้อกำหนดมาตรฐาน API สำหรับระบบเซิร์ฟเวอร์หลังบ้านของแอปพลิเคชัน ATR-BOOK
    ระบบนี้เปิดให้มีการเชื่อมต่อภายนอกสำหรับการสร้างข้อความอัจฉริยะ (AI Text Generation),
    การสังเคราะห์เสียงจากข้อความ (TTS), และการซิงโครไนซ์ข้อมูลสมุดบันทึก
  version: 1.0.0
  contact:
    name: API Integration Team
    email: dev@atr-book.com
servers:
  - url: https://api.atr-book.com/v1
    description: สภาพแวดล้อมระบบปฏิบัติการจริง (Production Environment)

tags:
  - name: Artificial Intelligence
    description: จุดสิ้นสุดสำหรับการโต้ตอบกับ LLM และการประมวลผลข้อความ
  - name: Speech Synthesis
    description: จุดสิ้นสุดสำหรับการแปลงข้อความเป็นเสียงพูด (TTS)
  - name: Documents
    description: จุดสิ้นสุดสำหรับการจัดการและดึงข้อมูลเอกสารสมุดบันทึก

paths:
  /ai/generate:
    post:
      summary: Generate content via AI
      description: ส่งคำสั่งบริบท (Prompt) ไปยังเอนจิน AI เพื่อสร้างเนื้อหาสมุดบันทึก
      operationId: generateAiContent
      tags:
        - Artificial Intelligence
      security:
        - BearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/TextGenerationRequest'
      responses:
        '200':
          description: สร้างข้อความสำเร็จและส่งคืนข้อมูล
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/TextGenerationResponse'
        '400':
          description: พารามิเตอร์ของคำขอไม่ถูกต้อง
        '401':
          description: ปฏิเสธการเข้าถึง ตรวจพบว่าโทเค็น (Token) สูญหายหรือไม่ถูกต้อง

  /ai/synthesize:
    post:
      summary: Convert text to speech
      description: สร้างสตรีมไฟล์เสียง (Audio Stream) ตามข้อมูลข้อความที่นำเข้า
      operationId: synthesizeSpeech
      tags:
        - Speech Synthesis
      security:
        - BearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/SpeechSynthesisRequest'
      responses:
        '200':
          description: สร้างและจัดส่งสตรีมไฟล์เสียงเรียบร้อยแล้ว
          content:
            audio/mpeg:
              schema:
                type: string
                format: binary
        '500':
          description: เกิดข้อผิดพลาดในระบบเซิร์ฟเวอร์ขณะพยายามประมวลผลเสียง

components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    TextGenerationRequest:
      type: object
      required:
        - prompt
      properties:
        prompt:
          type: string
          description: ข้อความตามบริบทเพื่อชี้แนะกระบวนการประมวลผลของปัญญาประดิษฐ์
          example: "ช่วยสรุปข้อมูลเชิงเทคนิคเกี่ยวกับคอมพิวเตอร์ควอนตัม"
        max_length:
          type: integer
          description: จำนวนสูงสุดของโทเค็น (Tokens) หรือคำที่จะต้องสร้างขึ้น
          default: 500
        temperature:
          type: number
          format: float
          description: ตัวแปรสำหรับการควบคุมความผันผวนหรือความสร้างสรรค์ของระบบ
          default: 0.7

    TextGenerationResponse:
      type: object
      required:
        - output_text
        - metadata
      properties:
        output_text:
          type: string
          description: ผลลัพธ์ข้อมูลที่สร้างสำเร็จ
        metadata:
          type: object
          properties:
            tokens_used:
              type: integer
            processing_time_ms:
              type: integer

    SpeechSynthesisRequest:
      type: object
      required:
        - text
      properties:
        text:
          type: string
          description: ข้อมูลข้อความตัวอักษรเพื่อนำไปสังเคราะห์เป็นเสียง
          maxLength: 5000
        voice_id:
          type: string
          description: ตัวระบุประเภทของโมเดลเสียง
          example: "en-US-Standard-A"
        format:
          type: string
          enum: [mp3, wav, ogg]
          default: mp3
```

ข้อกำหนดนี้ยึดตามรูปแบบ OpenAPI 3.1 อย่างเป็นทางการ ซึ่งรวมถึงการใช้งาน JSON Schema Draft 2020-12 โดยทำหน้าที่เป็นสัญญาระดับสากลที่มีผลผูกพันทางเทคนิคระหว่างระบบหลังบ้านของ ATR-BOOK และไคลเอนต์ใดๆ ที่ดึงข้อมูลไปใช้ การใช้รหัสสถานะ HTTP ที่เป็นมาตรฐาน รูปแบบการรักษาความปลอดภัยด้วย `BearerAuth` และโครงสร้างอ้างอิงสคีมาแบบเข้มงวดผ่านการระบุตัวแปร `$ref` ล้วนเป็นปัจจัยสำคัญที่รับประกันว่าระบบการผสานรวม (Integration) ของผู้ใช้ระบบภายนอกจะเป็นไปอย่างราบรื่น ถูกต้องตามหลักไวยากรณ์คอมพิวเตอร์ และปราศจากข้อผิดพลาดในการเชื่อมโยงข้อมูล

## กลยุทธ์การทดสอบและการปรับใช้งานระบบ (Deployment and CI/CD Operations)

การนำแอปพลิเคชัน ATR-BOOK ไปปรับใช้งานบนเซิร์ฟเวอร์หรืออัปโหลดสู่แหล่งให้บริการแอปพลิเคชันจำเป็นต้องมีการกำหนดค่าที่เฉพาะเจาะจงสำหรับระบบปลายทางแต่ละประเภท ควบคู่ไปกับกระบวนการทดสอบการทำงานของหน่วยย่อยและระบบรวมทั้งหมด (Unit and Integration Testing) อย่างเข้มงวดเพื่อรับรองความมั่นคงของฟังก์ชันปัญญาประดิษฐ์

### การปรับใช้งานเว็บแอปพลิเคชัน (Web Application Deployment)

สำหรับแพลตฟอร์มเว็บ เอนจินของ Flutter จะทำการคอมไพล์โค้ดภาษา Dart ให้กลายเป็นโครงสร้าง WebAssembly (WASM) และ JavaScript ที่ได้รับการปรับแต่งประสิทธิภาพในระดับสูง เพื่อให้ได้ประสบการณ์ที่ลื่นไหล การวางท่อส่งซอฟต์แวร์ (Deployment Pipeline) ต้องมีการเพิ่มประสิทธิภาพการแคชทรัพยากร (Asset Caching) และกลยุทธ์การจัดเส้นทางสำหรับเว็บ

**กลยุทธ์การใช้ชุดคำสั่งสร้างเว็บ:**

```bash
# คอมไพล์เว็บแอปพลิเคชันโดยใช้ CanvasKit เพื่อคงความคมชัดและประสิทธิภาพของอินเทอร์เฟซผู้ใช้งานสูงสุด
flutter build web --web-renderer canvaskit --release
```

ระบบจะสร้างไดเรกทอรี `build/web/` ซึ่งจะบรรจุไฟล์และทรัพยากรแบบคงที่ (Static Assets) ทั้งหมด ไฟล์เหล่านี้สามารถถูกอัปโหลดขึ้นไปยังโครงข่ายการส่งมอบเนื้อหา (Content Delivery Networks หรือ CDN) หรือระบบบริการแบบ Serverless ได้อย่างไร้รอยต่อ

### การปรับใช้งานสำหรับ Google Play Store (Android Deployment)

การอัปโหลดแอปพลิเคชันขึ้นสู่ Google Play Store จำเป็นต้องคอมไพล์ระบบให้กลายเป็น Android App Bundle (AAB) รูปแบบนี้จะช่วยให้ระบบของ Google Play สามารถตรวจสอบและส่งมอบไฟล์ขนาดเล็กที่เหมาะสมกับสถาปัตยกรรมฮาร์ดแวร์เฉพาะรุ่น (เช่น ความละเอียดหน้าจอ หรือ สถาปัตยกรรมชิป ARM) ของผู้ใช้งานในขั้นปลายทางแต่ละรายได้

**กลยุทธ์การใช้ชุดคำสั่งสร้างแอนดรอยด์แอปพลิเคชัน:**

```bash
# คอมไพล์แอปพลิเคชันให้กลายเป็น App Bundle สำหรับปล่อยใช้งานจริง
flutter build appbundle --release --obfuscate --split-debug-info=./debug_info
```

จุดเด่นของชุดคำสั่งนี้คือตัวแปร `--obfuscate` ซึ่งเป็นวิธีปฏิบัติที่เป็นมาตรฐานระดับโลกด้านความปลอดภัย การทำกระบวนการ Obfuscation นี้จะซ่อนรูปโครงสร้างตรรกะของโปรแกรม ป้องกันไม่ให้ผู้ไม่ประสงค์ดีทำการทำวิศวกรรมย้อนกลับ (Reverse Engineering) ตรรกะของแอปพลิเคชัน และป้องกันการโจรกรรมรหัส API ของระบบปัญญาประดิษฐ์ที่ถูกฝังอยู่ภายในกระบวนการเชื่อมโยงข้อมูล กระบวนการส่งมอบทั้งหมดนี้ยังสามารถบูรณาการเข้ากับระบบ Google Play Developer API เพื่อช่วยในเรื่องของการเพิ่มหมายเลขเวอร์ชันการปล่อยอัปเดตแอปพลิเคชันอัตโนมัติ

## บทสรุปเชิงวิศวกรรม

สถาปัตยกรรมที่ระบุไว้ในเอกสารข้อมูลทางเทคนิคฉบับนี้ จัดทำขึ้นเพื่อใช้เป็นกรอบโครงสร้างที่เข้มงวด ทรงประสิทธิภาพ และสามารถปรับขยายตัวได้ สำหรับการก่อสร้างและพัฒนาแอปพลิเคชัน ATR-BOOK การอาศัยเทคโนโลยีข้ามแพลตฟอร์มร่วมกับหลักการออกแบบ Clean Architecture แบบ Feature-First ช่วยรับประกันในเรื่องความง่ายของการบำรุงรักษาระบบ และการปฏิบัติงานด้วยสมรรถนะสูงทั้งในสภาพแวดล้อมของเบราว์เซอร์บนเว็บและระบบปฏิบัติการแอนดรอยด์

นอกจากนี้ การรวบรวมคำสั่งโครงสร้าง YAML อย่างเป็นระบบ ได้ถูกพิสูจน์แล้วว่ามีบทบาทสำคัญในการสั่งการและควบคุมปัญญาประดิษฐ์ให้สามารถสร้างโมดูลที่ปราศจากการเกิดภาวะหลอนข้อมูล (Hallucination) หรือการเสื่อมถอยของตรรกะระบบ การผสานรวมสคีมาสากลระดับโลกของ OpenAPI 3.1 เข้ามาด้วย ยังช่วยวางรากฐานอันแข็งแกร่งให้แก่ระบบนิเวศน์ซอฟต์แวร์ ATR-BOOK พร้อมที่จะบูรณาการระบบฐานข้อมูลกับการปฏิบัติงานภายในและระบบเครือข่ายภายนอกอย่างไร้ขีดจำกัด ตอกย้ำถึงภาพลักษณ์ของการเป็นแพลตฟอร์มสมุดบันทึกดิจิทัลอัจฉริยะที่ขับเคลื่อนด้วยขุมพลังปัญญาประดิษฐ์แห่งยุคอนาคตได้อย่างแท้จริง

## แนวทางการออกแบบแบบปรับเปลี่ยนด้วย Window Size Class

`Window Size Class` คือชุดจุดแบ่ง (breakpoints) ของพื้นที่แสดงผลที่กำหนดไว้ล่วงหน้า เพื่อช่วยให้การออกแบบ พัฒนา และทดสอบ UI แบบ Responsive/Adaptive ทำได้เป็นระบบมากขึ้น โดยแยกการพิจารณา **ความกว้าง** และ **ความสูง** ออกจากกัน

โดยทั่วไปการออกแบบแอปมักพิจารณา “ความกว้าง” เป็นหลัก เพราะหน้าจอมีการเลื่อนแนวตั้งได้ง่ายกว่า อย่างไรก็ตาม ในบางกรณี (เช่น มือถือแนวนอน) ควรพิจารณา “ความสูง” ร่วมด้วย

### กลุ่มขนาดตามความกว้าง

| ขนาดคลาส | ช่วงค่า |
|---|---|
| Compact | `< 600dp` |
| Medium | `600dp ≤ width < 840dp` |
| Expanded | `840dp ≤ width < 1200dp` |
| Large | `1200dp ≤ width < 1600dp` |
| Extra Large | `≥ 1600dp` |

### กลุ่มขนาดตามความสูง

| ขนาดคลาส | ช่วงค่า |
|---|---|
| Compact | `< 480dp` |
| Medium | `480dp ≤ height < 900dp` |
| Expanded | `≥ 900dp` |

> หมายเหตุ: แอปจำนวนมากสามารถสร้าง UI แบบปรับเปลี่ยนได้โดยดูเพียงความกว้างของหน้าต่าง แต่กรณีพื้นที่แนวตั้งจำกัด (เช่น แนวนอนบนมือถือ/แท็บเล็ต) การดูความสูงร่วมด้วยจะช่วยหลีกเลี่ยงเลย์เอาต์ที่ไม่เหมาะสม เช่น two-pane ในพื้นที่เตี้ยเกินไป

### หลักคิดสำคัญ

- Window Size Class **ไม่ใช่** ตรรกะแยกชนิดอุปกรณ์ (เช่น `isTablet`) แต่คือการวัด “พื้นที่หน้าต่างที่แอปใช้งานได้จริง”
- ขนาดหน้าต่างของแอปอาจเปลี่ยนระหว่างใช้งานได้ตลอดเวลา เช่น หมุนหน้าจอ, split-screen, ปรับขนาดหน้าต่างบน ChromeOS หรือพับ/กางอุปกรณ์
- ดังนั้น UI ควรตอบสนองแบบไดนามิกตามค่าขนาดหน้าต่างที่เปลี่ยนแปลง

### ตัวอย่างใน Jetpack Compose

คำนวณ `WindowSizeClass` ปัจจุบันจาก `currentWindowAdaptiveInfo()`:

```kotlin
val windowSizeClass = currentWindowAdaptiveInfo().windowSizeClass
```

หากต้องการรองรับช่วง Large และ Extra Large ให้เปิด `supportLargeAndXLargeWidth = true`

```kotlin
@Composable
fun MyApp(
    windowSizeClass: WindowSizeClass = currentWindowAdaptiveInfo(
        supportLargeAndXLargeWidth = true
    ).windowSizeClass
) {
    val showTopAppBar = windowSizeClass.isHeightAtLeastBreakpoint(
        WindowSizeClass.HEIGHT_DP_MEDIUM_LOWER_BOUND
    )

    MyScreen(
        showTopAppBar = showTopAppBar,
    )
}
```

### แนวทางการทดสอบ

- ทดสอบอย่างน้อยที่จุดแบ่งความกว้าง Compact, Medium และ Expanded
- หากเริ่มจากเลย์เอาต์มือถือ ให้ขยายไปที่ Expanded ก่อน (เพราะมีพื้นที่มากสุด)
- จากนั้นค่อยออกแบบรูปแบบที่เหมาะกับ Medium และพิจารณาเพิ่มเลย์เอาต์เฉพาะทางเมื่อจำเป็น

แหล่งอ้างอิงหลัก:

- Material 3: Window size classes
- Android Developers: Adaptive layouts (Compose/View)
