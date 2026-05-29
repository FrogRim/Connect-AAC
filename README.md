# Connect-AAC

자폐 및 지적장애인을 위한 AI 기반 보완대체의사소통(AAC) 모바일 애플리케이션입니다.

> Portfolio position: accessibility-focused mobile UI, AAC interaction flow, AI-assisted sentence recommendation.

## Problem

기존 AAC 도구는 사용자가 단어를 선택해 문장을 만들 수 있게 돕지만, 실제 대화 상황에서는 표현 후보가 부족하거나 입력 흐름이 느려질 수 있습니다. Connect-AAC는 큰 버튼, 높은 대비, 한국형 어휘 체계, AI 문장 추천, TTS를 결합해 더 직관적인 의사소통 경험을 만드는 것을 목표로 했습니다.

## What We Built

- Flutter 기반 AAC mobile UI
- 카테고리별 어휘 선택 흐름
- 한국형 손담 어휘 체계 기반 vocabulary structure
- 즐겨찾기와 개인화 설정
- 선택 단어 기반 AI 문장 추천
- TTS(Text-to-Speech) output flow
- Flask/AWS/PostgreSQL 기반 backend concept

## My Role

팀 프로젝트에서 Flutter 기반 프론트엔드와 접근성 중심 UI를 담당했습니다. 큰 버튼, 높은 대비, 쉬운 탐색, AAC 입력 흐름, TTS 사용 경험을 중심으로 구현했습니다.

## Stack

| Area | Stack |
| --- | --- |
| Mobile | Flutter, Dart |
| State/local data | Provider, Shared Preferences |
| Backend | Flask, AWS, PostgreSQL |
| AI | Hugging Face Transformers, fine-tuning concept |
| Accessibility | High contrast UI, large touch targets, TTS |

## Main Features

| Feature | Description |
| --- | --- |
| AAC input | 카테고리별 어휘 선택과 표현 조합 |
| Korean vocabulary | 한국형 손담 어휘 체계 기반 단어 구성 |
| AI recommendation | 선택 단어와 문맥 기반 문장 후보 생성 |
| TTS | 선택 단어/생성 문장을 음성으로 출력 |
| Personalization | 테마, 음성 설정, 즐겨찾기, 난이도 조정 |
| Accessible UI | 큰 버튼, 선명한 색 대비, 충분한 폰트 크기 |

## Run

```bash
flutter pub get
flutter run
```

Backend/API integration values should be configured locally and not committed.

## Repository Structure

```text
lib/
  data/       static data and sources
  models/     data models
  providers/  state management
  screens/    app screens
  services/   backend/API and TTS services
  utils/      helpers
  widgets/    reusable UI components
```

## Validation Evidence

| Area | Evidence |
| --- | --- |
| Frontend role | Flutter AAC UI implemented |
| Accessibility | large buttons, high contrast, readable type choices |
| AAC flow | category -> vocabulary -> sentence/TTS path |
| AI feature | sentence recommendation integrated into product concept |
| Team scope | frontend, backend, and AI recommendation roles separated |

## Demo / Screenshots

공개 가능한 앱 화면 캡처를 추가할 때 이 섹션에 배치합니다. 현재 README는 공개 가능한 기능, 역할, 구조 중심으로 정리했습니다.

## License

MIT License.
