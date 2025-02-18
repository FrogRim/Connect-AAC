# Connect-AAC 

### **1. 개요**
Connect-AAC는 **자폐 및 지적 장애인들이 일반인과 원활하게 소통할 수 있도록 돕는 AI 기반 보완대체의사소통(AAC) 애플리케이션**입니다. 기존 AAC의 한계를 극복하고, **손담(몸짓상징), 아이콘, 텍스트, 음성을 AI를 통해 변환**하여 장애인과 일반인 간의 자유로운 대화를 지원합니다.

### **2. 주요 기능**

#### ✅ **1) AAC ↔ 자연어 실시간 변환 (핵심 기능)**
- 장애인이 AAC(손담, 아이콘, 텍스트)로 표현한 내용을 **자연어 텍스트 및 음성으로 변환**하여 일반인에게 전달.
- 일반인이 입력한 자연어(텍스트, 음성)를 **AAC 형식(손담, 아이콘, 텍스트)으로 변환**하여 장애인이 쉽게 이해하도록 변환.
- 🏠🚗➡️ → "저는 집에 가고 싶어요" / "어디 가고 싶어요?" → 🏥🍽️🏡

#### ✅ **2) AI 기반 문맥 이해 및 추천 시스템**
- 사용자의 **자주 사용하는 표현을 분석하여 추천 목록 자동 생성**.
- 실시간 감정 분석을 통해 대화 흐름을 원활하게 조절.

#### ✅ **3) 실시간 음성 ↔ 텍스트 변환**
- **음성 입력 지원(STT)**: 일반인의 음성을 분석하여 텍스트 및 AAC 변환.
- **텍스트 → 음성 변환(TTS)**: 장애인의 입력을 음성으로 변환하여 일반인에게 전달.
- Google Speech-to-Text API 또는 AWS Polly 연동 가능.

#### ✅ **4) 긴급 요청 기능 (Emergency Mode)**
- 장애인이 "도와주세요" 버튼을 누르면 **보호자 또는 구조요청 자동 전송**.
- **GPS 기반 실시간 위치 공유**.

#### ✅ **5) 오프라인에서도 사용 가능**
- AI 모델을 디바이스 내에서 실행 가능하도록 최적화 (ONNX 변환 + 양자화 적용).
- 인터넷 연결이 없는 환경에서도 주요 기능 사용 가능.
- 앱 업데이트 시 최신 AI 모델 자동 다운로드.

### **3. 기술 스택**
- **프론트엔드**: Flutter (iOS, Android 크로스플랫폼 지원)
- **백엔드**: AWS Lambda + FastAPI (경량 서버리스 환경)
- **AI 모델**: Phi-3 (Microsoft) 기반 LLM Fine-tuning
- **음성 변환**: AWS Polly, Google STT API
- **데이터 저장**: AWS DynamoDB (사용자 맞춤 데이터 저장)
- **배포**: ONNX 모델을 활용한 오프라인 실행 지원

### **4. 사용 예시**
- 장애인: "배고파요" (AAC 선택) → AI 변환 → "저는 배가 고파요" (텍스트 + 음성 출력)
- 일반인: "뭐 먹고 싶어요?" (음성 입력) → AI 변환 → 🍔 🍕 🍜 (AAC 아이콘 변환)
- 긴급 상황: "위험해요" (AAC 선택) → 보호자에게 GPS 위치와 함께 긴급 메시지 자동 전송

### **5. 기대 효과**
✅ **장애인이 손담/AAC를 사용하면 AI가 자연어로 변환하여 일반인과 소통 가능**  
✅ **일반인의 입력을 AAC 형식(아이콘, 손담)으로 변환하여 장애인이 이해 가능**  
✅ **음성 ↔ 텍스트 변환 기능을 통해 실시간 대화 지원**  
✅ **사용자의 개별 행동 패턴을 학습하여 맞춤형 추천 시스템 제공**  
✅ **오프라인에서도 작동 가능하여 언제 어디서든 사용 가능**  

### **6. 결론**
Connect-AAC는 단순한 AAC 앱이 아니라, **장애인과 비장애인 간의 원활한 소통을 가능하게 하는 AI 기반 커뮤니케이션 도구**입니다.

🚀 **다음 단계**:  
1. AI 모델 최적화 및 학습 데이터 확장  
2. 음성 변환 기능 강화 및 실시간 API 연동  
3. UI/UX 개선 및 실제 사용자 테스트 진행  



