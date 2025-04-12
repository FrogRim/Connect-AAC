# API 명세

---

## 기본 정보

- 기본 URL: `https://api.connectaac.com/v1` 또는 `http://localhost:5000/api/v1`
- 인증 방식: JWT 토큰 (Authorization 헤더에 Bearer 토큰 포함)
- 응답 형식: JSON

## API 목록

### 1. 사용자 관리 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1.1 | 회원가입 | 새 사용자 등록 | POST | `/auth/register` | Content-Type: application/json | `{"username": "string", "email": "string", "password": "string", "preferred_language": "string"}` | `{"user_id": "string", "username": "string", "email": "string", "token": "string", "created_at": "datetime"}` | 비밀번호는 해싱 처리됨 |
| 1.2 | 로그인 | 사용자 인증 | POST | `/auth/login` | Content-Type: application/json | `{"email": "string", "password": "string"}` | `{"user_id": "string", "token": "string", "expires_at": "datetime"}` | 토큰 만료 시간 포함 |
| 1.3 | 로그아웃 | 사용자 세션 종료 | POST | `/auth/logout` | Authorization: Bearer {token} | - | `{"success": "boolean", "message": "string"}` | 현재 토큰 무효화 |
| 1.4 | 프로필 조회 | 사용자 정보 조회 | GET | `/users/profile` | Authorization: Bearer {token} | - | `{"user_id": "string", "username": "string", "email": "string", "preferred_language": "string", "created_at": "datetime", "last_login": "datetime"}` | - |
| 1.5 | 프로필 수정 | 사용자 정보 수정 | PUT | `/users/profile` | Authorization: Bearer {token}, Content-Type: application/json | `{"username": "string", "email": "string", "preferred_language": "string"}` | `{"user_id": "string", "username": "string", "email": "string", "preferred_language": "string", "updated_at": "datetime"}` | - |
| 1.6 | 비밀번호 변경 | 사용자 비밀번호 변경 | PUT | `/users/password` | Authorization: Bearer {token}, Content-Type: application/json | `{"current_password": "string", "new_password": "string"}` | `{"success": "boolean", "message": "string"}` | - |

### 2. 카테고리 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 2.1 | 카테고리 목록 조회 | 모든 카테고리 조회 | GET | `/categories` | Authorization: Bearer {token} | - | `{"categories": [{"category_id": "string", "name": "string", "icon_name": "string", "description": "string", "display_order": "int"}]}` | - |
| 2.2 | 카테고리 상세 조회 | 특정 카테고리 상세 정보 | GET | `/categories/{category_id}` | Authorization: Bearer {token} | - | `{"category_id": "string", "name": "string", "icon_name": "string", "description": "string", "display_order": "int"}` | - |
| 2.3 | 카테고리 생성 | 관리자용 카테고리 생성 | POST | `/admin/categories` | Authorization: Bearer {token}, Content-Type: application/json | `{"name": "string", "icon_name": "string", "description": "string", "display_order": "int"}` | `{"category_id": "string", "name": "string", "icon_name": "string", "description": "string", "display_order": "int"}` | 관리자 권한 필요 |
| 2.4 | 카테고리 수정 | 관리자용 카테고리 수정 | PUT | `/admin/categories/{category_id}` | Authorization: Bearer {token}, Content-Type: application/json | `{"name": "string", "icon_name": "string", "description": "string", "display_order": "int"}` | `{"category_id": "string", "name": "string", "icon_name": "string", "description": "string", "display_order": "int"}` | 관리자 권한 필요 |
| 2.5 | 카테고리 삭제 | 관리자용 카테고리 삭제 | DELETE | `/admin/categories/{category_id}` | Authorization: Bearer {token} | - | `{"success": "boolean", "message": "string"}` | 관리자 권한 필요 |

### 3. 어휘 항목 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 3.1 | 어휘 항목 목록 조회 | 모든 어휘 항목 조회 | GET | `/vocabulary` | Authorization: Bearer {token} | Query params: category_id(선택) | `{"items": [{"item_id": "string", "text": "string", "image_path": "string", "category_id": "string", "display_order": "int"}]}` | 카테고리 필터링 가능 |
| 3.2 | 카테고리별 어휘 조회 | 특정 카테고리의 어휘 항목 | GET | `/categories/{category_id}/vocabulary` | Authorization: Bearer {token} | - | `{"category": {"name": "string"}, "items": [{"item_id": "string", "text": "string", "image_path": "string", "display_order": "int"}]}` | - |
| 3.3 | 어휘 항목 상세 조회 | 특정 어휘 항목 상세 정보 | GET | `/vocabulary/{item_id}` | Authorization: Bearer {token} | - | `{"item_id": "string", "text": "string", "image_path": "string", "category_id": "string", "category_name": "string", "display_order": "int"}` | - |
| 3.4 | 어휘 항목 생성 | 관리자용 어휘 항목 생성 | POST | `/admin/vocabulary` | Authorization: Bearer {token}, Content-Type: application/json | `{"text": "string", "image_path": "string", "category_id": "string", "display_order": "int"}` | `{"item_id": "string", "text": "string", "image_path": "string", "category_id": "string", "display_order": "int"}` | 관리자 권한 필요 |
| 3.5 | 어휘 항목 수정 | 관리자용 어휘 항목 수정 | PUT | `/admin/vocabulary/{item_id}` | Authorization: Bearer {token}, Content-Type: application/json | `{"text": "string", "image_path": "string", "category_id": "string", "display_order": "int"}` | `{"item_id": "string", "text": "string", "image_path": "string", "category_id": "string", "display_order": "int"}` | 관리자 권한 필요 |
| 3.6 | 어휘 항목 삭제 | 관리자용 어휘 항목 삭제 | DELETE | `/admin/vocabulary/{item_id}` | Authorization: Bearer {token} | - | `{"success": "boolean", "message": "string"}` | 관리자 권한 필요 |
| 3.7 | 어휘 검색 | 어휘 항목 검색 | GET | `/vocabulary/search` | Authorization: Bearer {token} | Query params: query, category_id(선택) | `{"items": [{"item_id": "string", "text": "string", "image_path": "string", "category_id": "string", "category_name": "string"}]}` | 텍스트 기반 검색 |

### 4. 즐겨찾기 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 4.1 | 즐겨찾기 목록 조회 | 사용자의 즐겨찾기 조회 | GET | `/favorites` | Authorization: Bearer {token} | - | `{"favorites": [{"favorite_id": "string", "item_id": "string", "text": "string", "image_path": "string", "category_id": "string", "display_order": "int"}]}` | - |
| 4.2 | 즐겨찾기 추가 | 어휘 항목 즐겨찾기에 추가 | POST | `/favorites` | Authorization: Bearer {token}, Content-Type: application/json | `{"item_id": "string"}` | `{"favorite_id": "string", "item_id": "string", "user_id": "string", "created_at": "datetime"}` | - |
| 4.3 | 즐겨찾기 삭제 | 즐겨찾기에서 제거 | DELETE | `/favorites/{favorite_id}` | Authorization: Bearer {token} | - | `{"success": "boolean", "message": "string"}` | - |
| 4.4 | 즐겨찾기 순서 변경 | 즐겨찾기 표시 순서 변경 | PUT | `/favorites/order` | Authorization: Bearer {token}, Content-Type: application/json | `{"favorites": [{"favorite_id": "string", "display_order": "int"}]}` | `{"success": "boolean", "message": "string"}` | 여러 항목 순서 일괄 변경 |

### 5. 설정 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 5.1 | 설정 조회 | 사용자 설정 조회 | GET | `/settings` | Authorization: Bearer {token} | - | `{"setting_id": "string", "text_size": "float", "icon_size": "float", "theme_mode": "string", "tts_enabled": "boolean", "voice_type": "string", "speech_rate": "float"}` | - |
| 5.2 | 설정 저장 | 사용자 설정 저장/수정 | PUT | `/settings` | Authorization: Bearer {token}, Content-Type: application/json | `{"text_size": "float", "icon_size": "float", "theme_mode": "string", "tts_enabled": "boolean", "voice_type": "string", "speech_rate": "float"}` | `{"setting_id": "string", "text_size": "float", "icon_size": "float", "theme_mode": "string", "tts_enabled": "boolean", "voice_type": "string", "speech_rate": "float"}` | - |

### 6. 채팅 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 6.1 | 메시지 기록 조회 | 사용자 채팅 기록 조회 | GET | `/chat/messages` | Authorization: Bearer {token} | Query params: limit, offset | `{"messages": [{"message_id": "string", "content": "string", "message_type": "string", "created_at": "datetime", "is_ai": "boolean"}], "total_count": "int"}` | 페이지네이션 적용 |
| 6.2 | 메시지 전송 | 사용자가 챗봇에 메시지 전송 | POST | `/chat/messages` | Authorization: Bearer {token}, Content-Type: application/json | `{"content": "string", "message_type": "string"}` | `{"message_id": "string", "content": "string", "created_at": "datetime", "is_ai": false, "response": {"message_id": "string", "content": "string", "created_at": "datetime", "is_ai": true}}` | AI 응답 함께 반환 |
| 6.3 | 메시지 대화 삭제 | 메시지 기록 삭제 | DELETE | `/chat/messages` | Authorization: Bearer {token} | - | `{"success": "boolean", "message": "string"}` | 사용자의 전체 대화 기록 삭제 |

### 7. 최근 사용 기록 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 7.1 | 최근 사용 기록 조회 | 사용자의 최근 사용 어휘 | GET | `/recent-usage` | Authorization: Bearer {token} | Query params: limit | `{"items": [{"item_id": "string", "text": "string", "image_path": "string", "category_id": "string", "usage_count": "int", "last_used": "datetime"}]}` | 사용 빈도순 정렬 |
| 7.2 | 사용 기록 추가 | 어휘 항목 사용 기록 | POST | `/recent-usage` | Authorization: Bearer {token}, Content-Type: application/json | `{"item_id": "string"}` | `{"usage_id": "string", "item_id": "string", "usage_count": "int", "last_used": "datetime"}` | 이미 있으면 카운트 증가 |
| 7.3 | 사용 기록 삭제 | 특정 항목 사용 기록 삭제 | DELETE | `/recent-usage/{item_id}` | Authorization: Bearer {token} | - | `{"success": "boolean", "message": "string"}` | - |
| 7.4 | 모든 기록 삭제 | 사용자의 전체 사용 기록 삭제 | DELETE | `/recent-usage` | Authorization: Bearer {token} | - | `{"success": "boolean", "message": "string"}` | - |

### 8. 커스텀 어휘 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 8.1 | 커스텀 어휘 목록 | 사용자의 커스텀 어휘 조회 | GET | `/custom-vocabulary` | Authorization: Bearer {token} | Query params: category_id(선택) | `{"items": [{"custom_id": "string", "text": "string", "image_path": "string", "category_id": "string", "created_at": "datetime"}]}` | 카테고리별 필터링 가능 |
| 8.2 | 커스텀 어휘 상세 | 특정 커스텀 어휘 상세 정보 | GET | `/custom-vocabulary/{custom_id}` | Authorization: Bearer {token} | - | `{"custom_id": "string", "text": "string", "image_path": "string", "category_id": "string", "category_name": "string", "created_at": "datetime", "updated_at": "datetime"}` | - |
| 8.3 | 커스텀 어휘 생성 | 사용자 정의 어휘 생성 | POST | `/custom-vocabulary` | Authorization: Bearer {token}, Content-Type: multipart/form-data | Form data: text, category_id, image(파일) | `{"custom_id": "string", "text": "string", "image_path": "string", "category_id": "string", "created_at": "datetime"}` | 이미지 파일 업로드 |
| 8.4 | 커스텀 어휘 수정 | 사용자 정의 어휘 수정 | PUT | `/custom-vocabulary/{custom_id}` | Authorization: Bearer {token}, Content-Type: multipart/form-data | Form data: text, category_id, image(파일, 선택) | `{"custom_id": "string", "text": "string", "image_path": "string", "category_id": "string", "updated_at": "datetime"}` | 이미지 선택적 수정 |
| 8.5 | 커스텀 어휘 삭제 | 사용자 정의 어휘 삭제 | DELETE | `/custom-vocabulary/{custom_id}` | Authorization: Bearer {token} | - | `{"success": "boolean", "message": "string"}` | - |

### 9. 이미지 업로드 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 9.1 | 이미지 업로드 | 커스텀 이미지 업로드 | POST | `/upload/image` | Authorization: Bearer {token}, Content-Type: multipart/form-data | Form data: image(파일), type(용도) | `{"image_path": "string", "url": "string"}` | 이미지 URL 반환 |

### 10. 음성 합성(TTS) API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 10.1 | 텍스트 음성 변환 | 텍스트를 음성으로 변환 | POST | `/tts/synthesize` | Authorization: Bearer {token}, Content-Type: application/json | `{"text": "string", "voice_type": "string", "speech_rate": "float"}` | Binary audio file | audio/mpeg 형식 |
| 10.2 | 가용 음성 목록 | TTS에 사용 가능한 음성 유형 | GET | `/tts/voices` | Authorization: Bearer {token} | - | `{"voices": [{"id": "string", "name": "string", "language": "string", "gender": "string"}]}` | - |

### 11. 통계 API

| 번호 | 기능 | 설명 | 메소드 | REST API | Header | 입력 데이터 | 반환 데이터 | 기타 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 11.1 | 사용 통계 조회 | 사용자의 어휘 사용 통계 | GET | `/statistics/usage` | Authorization: Bearer {token} | Query params: period(day/week/month) | `{"most_used": [{"item_id": "string", "text": "string", "count": "int"}], "category_usage": [{"category_id": "string", "name": "string", "count": "int"}], "total_usage": "int"}` | 기간별 통계 |

## 에러 응답 형식

모든 API는 오류 발생 시 다음과 같은 형식으로 응답합니다:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": {}  // 추가 오류 정보 (선택)
  }
}

```

## 상태 코드

- 200: 성공
- 201: 리소스 생성 성공
- 400: 잘못된 요청
- 401: 인증 실패
- 403: 권한 없음
- 404: 리소스 없음
- 409: 충돌
- 500: 서버 오류