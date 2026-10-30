# AXMART PC CARE — FINAL PRODUCT SPEC v2.0

2026-10-30 KST | Gemini 두 차례 의견 통합 / 총괄 아키텍처 기준서
상위 브랜드: AXMART³ (AXMART CUBE) = 플랫폼 및 사이트
개별 제품: AXMART PC CARE = Windows PC·USB 겸용 진단·복구 지원 제품
대상 저장소/브랜치: hibi89/AX_MART / feature/pc-care-usb
소스 기준(문서 반영 전): ce25889de59645402a73fce71ca9ceecbbb7363d
상태: **최종 목표 기능 설계**. 코드/실기기/시장성 검증 완료를 뜻하지 않음.

## 1. 한 문장 정의와 가치

설치 없이 Windows PC의 폴더나 USB에서 직접 실행하는 **시스템 건강검진 + 오류 증거 분석 + 수리점 전달용 1페이지 보고서/QR + 안전한 WinRE 사용자 파일 백업 지원 + 명시적 승인형 제한 복구 안내** 도구.

사용자가 해결할 일은 단순 청소가 아니라 (1) 무엇이 고장 의심인지 (2) 어떤 근거로 판단했는지 (3) 어떤 데이터부터 지킬지 (4) 수리점·지인에게 무엇을 전달할지 (5) 어떤 조치를 안전하게 할 수 있는지 파악하는 것이다.

경쟁력 가설: 한국어 증거 해설, 실제 사고의 시간축 재구성, 수리점 상담 준비, 비상 파일 백업 지원, 완전 오프라인 포터블. 이점은 아직 사용성/가격 실험으로 입증되지 않았으며 '상위 1%'·'2만~3만원 반드시 구매'·'사기 방지 보증'은 마케팅에서 금지.

## 2. 기술 스택과 구동 범위

- 기본 OS: 지원되는 Windows 11 x64 + Windows PowerShell 5.1. Windows 10 22H2 x64는 지원 종료 공지와 호환성 테스트를 갖춘 제한적 대상. ARM64/Windows Server/32bit는 검증 전 미지원.
- Collector, Normalizer, Analyzer, Reporter, Repair Gate: PowerShell 5.1. 시작 메뉴/WinRE 진입점: CMD. 프론트: 단일 로컬 HTML/CSS + 내장 JavaScript. 결과: UTF-8 JSON/HTML 파일 및 수동 인쇄. 개발·테스트용 Python은 사용자 배포 파일에 불필요.
- 계정/서버/클라우드 AI/원격 로그/자동 업로드/상주 모니터/필수 네트워크/필수 외부 라이브러리 없음.
- Windows 부팅 가능: 같은 폴더를 내장 SSD에서나 USB에서 사용자가 수동 실행. 처음부터 관리자 자동 승격 금지. 표준 권한으로 가능한 진단을 실행하고 추가 권한이 필요한 항목은 미확인 또는 별도 승인 유도.
- Windows 부팅 실패: Microsoft 정식 WinRE(내장 또는 공식 복구 미디어)에 사용자가 진입해 USB의 CMD 복구 모드 수동 실행. AXMART ZIP 자체는 부팅 가능한 Windows 이미지가 아님.
- 진단은 OS 설정/부트/파티션/원본 개인 파일을 수정하지 않는다. 다만 로컬 보고서를 작성하므로 '디스크 쓰기 0'이라고 표시하면 안 된다.
- 코드 서명·SmartScreen/Defender 경고, 서드파티 소프트웨어 라이선스, USB 드라이브 문자 변경, 보고서 저장 실패/용량 제한은 릴리스 게이트에서 다룬다.

## 3. 최종 5대 제품 모듈

### HEALTH — 평상시 PC 건강검진 [Release A]

H01. Windows 에디션·버전·빌드·부팅 시각·권한 상태.
H02. 고정 드라이브/볼륨의 총량, 사용량, 가용 용량 및 여유 부족 경고(자동 파일 삭제 없음).
H03. Windows Storage API의 Get-PhysicalDisk/StorageReliabilityCounter 기반 장치 건강 경고, 지원되는 온도·Wear 관찰값. 장치별 API 미지원/값 미확인은 '확인 불가'. Wear 값을 멋대로 '남은 SSD 수명%'라고 변환하지 않는다.
H04. 이벤트 41(Kernel-Power), 6008, 1001(BugCheck 공급자 확인), 스토리지/파일시스템 관련 이벤트. 접근 거부·빈 로그·조회 한도 절단을 서로 구별.
H05. Windows Update 실패와 최근 설치·변경 정보, 일부 드라이버 오류 장치 표시.
H06. 노트북 배터리 설계 용량/완충 용량/사용 정보. 배터리가 없거나 powercfg 지원이 없으면 해당 없음/미지원. 필요 시 batteryreport는 지정 로컬 파일에만 생성.
H07. Microsoft Defender 관찰 정보, 타사 백신 여부 미확인 표시.
H08. 반복 검사 이력 로컬 보관/삭제 및 중요 신호 변화 비교.

표시: 위험 / 주의 / 관찰 범위 내 특이사항 없음 / 검사 불가. 위험도, 데이터 수집완전성, 근거 수준은 별도. 건강점수 92/100 같은 임의 점수 금지.
v1 제외: 레지스트리 청소, 일괄 드라이버 업데이트, 자동 파일 삭제, 상주 실시간 감시, 수상한 성능부스터, 광범위 네트워크 최적화.

### ANALYZE — 사고 재구성·원인 후보 근거 [Release A]

파이프라인: 데이터 수집 -> 공통 사건 포맷 -> 중복 종료 사건 그룹화 -> 시각/로그 상관관계 -> 위험/근거/한계 -> 한국어 권장 행동.
- BugCheck 관련 이벤트 1001의 **기록 시각**은 실제 장애 발생 시각이 아닐 수 있으므로 구별. 41과 6008은 같은 종료를 중복 표기할 수 있다.
- EventID/Provider/기록 시간/기간 및 원인 후보의 근거를 표시. 원본 이벤트 메시지 전체는 수집·저장하지 않는다.
- 예시: BugCheck 기록과 스토리지 오류/SMART 경고가 함께 있으면 백업 및 추가 저장장치 검사 우선. 물리적 고장이나 메인보드 교체 필요·불필요를 확정하지 않는다.
- 예시: 업데이트 직후 충돌은 '업데이트 관련성 확인 필요'이지 인과 확정이 아니다.
- ntoskrnl.exe 표기만으로 NVIDIA 드라이버 충돌 확정 금지. '게임 튕김의 80%는 드라이버' 등 검증되지 않은 비율 금지.
- 로컬 규칙 엔진을 작은 독립 테스트 가능한 함수로 구현. 오탐/누락/타임존/로그 기록 지연/권한 부재/기간 상한/대량 로그 단위 테스트 필수.
- 전문가용 WinDbg 원본 메모리 덤프 분석은 v1 기본 제외(추후 명시적 로컬 선택 옵션).

### REPORT — 엔지니어 제출용 1페이지 + PDF + QR [Release A 핵심 차별화]

R01. 한 페이지로 인쇄되는 CSS print 레이아웃. 사용자 브라우저의 '인쇄 → PDF로 저장' 사용. 별도 PDF 엔진·외부 클라우드 없음.
R02. 내용: 검사 날짜와 버전/검사 범위, 사용자가 입력한 증상(선택), 확인된 Event ID/발생시각, 장치 관찰값, 위험도·근거수준·확인 불가, 원인 후보와 반대 가능성, 권장 백업·추가 검사 순서, 수리점에 질문할 2~4개 항목.
R03. '덤탱이 방지'라는 홍보 프레이밍은 직접 사용하지 않고 **수리 상담 체크리스트**로 구현. 특정 부품의 교체가 불필요함을 확정하거나 '공식 엔지니어 인증/진단 합격증'처럼 표시하지 않음.
R04. QR은 오프라인에서만 로컬 생성, 사용자가 명시적으로 생성 선택. QR 내용의 미리보기 제공. 기본적으로 요약된 장애 종류/시각·근거 한계·권장 다음 행동만 사용.
R05. 개인정보 기본 제거: 사용자 이름, 전체 경로, 디스크 시리얼, 장치/BitLocker 식별자, 원문 로그·메모리 덤프, 암호·복구키, 개인 파일 내용 포함 금지. 최대 페이로드 byte 수와 오류 정정 한도에 맞게 유효성 검증(예: 250 UTF-8 bytes 목표, 실제 QR 인코더 검증 후 확정); 무단 절단 금지.
R06. QR 이미지는 텍스트 전달 수단이며 누군가 촬영하면 공유 가능함을 고지. 자동 카카오톡 전송·서버 POST·데이터 업로드 금지. QR 코드 로컬 라이브러리의 라이선스 검토.
R07. 동일 내용을 복사 가능한 짧은 텍스트로도 제공; QR이 지원되지 않으면 인쇄/텍스트만 제공.
R08. SHA256 파일 체크섬은 패키지 전송 중 변조 탐지 보조일 뿐 보고서의 의학/법률/공식 인증이 아님.

### RESCUE — WinRE 중요 파일 USB 백업 보조 [Release B 조건부]

**목적:** Windows가 부팅되지 않더라도 접근 가능한 사용자 파일을 별도 외장 저장장치로 복사하게 돕는다. 고장난 디스크의 완전 복구·암호 해제·Windows OS 복구는 수행하지 않는다.

상태기계: 환경 점검 -> Windows 설치 및 사용자 프로필 후보 확인 -> 소스 폴더 선택 -> 대상 물리 외장장치 지정 -> 사전 검사(잠금/용량/파일시스템/원본 상태) -> 백업 내용 미리보기 -> 백업·위험 승인 2단계 -> 제한 복사 -> 사후 결과 확인 -> 실패/부분완료 구분.

S01. WinRE CMD 내 별도 START_RESCUE.cmd (개발 예정). 복구 키를 프로그램에 입력하지 않음. BitLocker 볼륨 잠김 시 **자동 해제/키 수집/키 로그/우회 없이 중단**, 소유자에게 Microsoft 공식 복구 절차 안내.
S02. Desktop/Documents/Pictures/Downloads 등 사용자가 선택한 프로필 폴더만 기본 대상으로 제공. 사용자 계정 다수, 폴더 위치 변경, OneDrive 리디렉션/온라인 전용 파일, EFS, junction/symlink, 접근 권한 오류는 정확히 구분해 사용자에게 알림.
S03. 대상은 **소스와 다른 물리적 저장장치**로 확실하게 식별되어야 한다. 볼륨 문자만 다르다는 이유로 인정하지 않는다. WinRE 환경에서 물리디스크 확인 불가능하면 자동 복사 차단, 수동 지원 가이드만 제공.
S04. 사전에 대상 잔여 공간, 예상 파일 크기, FAT32 단일 파일 4GiB 제한, USB 연결 상태를 확인. 미확인/부족하면 자동 복사 금지. 임시 디스크 쓰기/파티션 포맷 금지.
S05. 백업 대상은 새로운 빈 고유 디렉터리만 허용. 덮어쓰기·대상 삭제·원본 소유권 변경·미러링/이동 금지.
S06. 해당 WinRE에 실제 명령이 존재하는지 확인 후 Robocopy 등의 안전한 제한 모드 사용. /MIR, /PURGE, /MOVE, /MOV, bootrec, bcdboot, diskpart clean, chkdsk /f /r 사용 금지. junction 제외, 재시도 횟수/대기 시간을 짧게 제한.
S07. Robocopy 종료 코드 >=8은 복사 오류 포함. 0~7도 완료를 단정하지 않으며 복사된 파일 수·바이트/오류 내역, 필요하면 샘플 혹은 전체 해시로 확인. USB 분리/읽기오류·전원중단 시 '부분 완료/추가 검증 필요'.
S08. 원본 HDD/SSD가 물리적으로 고장 의심이면 무리한 전체 파일 복사를 자동 시작하지 않고 전문 복구를 우선 안내.
S09. **Release A에는 WinRE 읽기 전용 상태 확인만 제공.** WinRE/BitLocker/장치 다중 구성/중단/누락/실제 복사 데이터 검증이 모두 통과한 경우에 한하여 Release B의 복사 기능 공개. 미검증이면 제품에 비상 백업 기능을 완성품처럼 광고하지 않는다.
S10. 핵심 버튼은 '백업 준비 검사'이지 '한 번에 무조건 파일 살리기'가 아니다.

### RECOVER — 수리 승인 및 Windows 공식 복구 가이드

C01. 정상 Windows의 관리자 별도 실행기를 통해 DISM 검사 전용/실제 수리, SFC VerifyOnly/Scannow를 역할 분리.
C02. 정상 저장장치 상태·하드웨어 경고·백업 여부·관리자 권한·두 차례 명시 승인 확인 전 시스템 변경 없음. 모호한 저장장치 상태는 fail-closed. 실제 수리는 스냅샷/백업 VM에서 먼저 검증.
C03. Quick Machine Recovery, Point-in-time restore, Startup Repair, Windows Update 복구 재설치, System Restore는 **Microsoft 공식 기능으로 연결하는 상태별 가이드**. 무인 WinRE 조작/자동 초기화 금지.
C04. QMR은 지원 Windows 11 빌드와 네트워크 등의 조건이 있으며, 빌드만 충족한다고 '활성화됨' 단정 금지. PITR은 개인 파일·키·앱·설정이 복원 시점으로 되돌아갈 수 있으므로 데이터 손실 경고 필수. 판별 공식 인터페이스가 없으면 '확인 불가'.
C05. DDU 및 그래픽 드라이버 클린 재설치는 v1 자동화·동봉 금지; 필요 시 공식 드라이버/안전모드의 수동 가이드만 제공, 제3자 DDU 라이선스/안전 테스트 후 전문가 모드 검토.

## 4. 사용자 UI 구조

- 홈: 전체 진단 시작 / 장애 분석 / 결과 / 1페이지 수리 상담표 / 복구 가이드. RESCUE는 일반 Windows에서 'WinRE 진입 안내'만 표시.
- HEALTH: OS, 디스크, 이벤트, 배터리, 업데이트 등 수집 상태와 '정상 신호/주의/위험/미확인' 차이.
- ANALYZE: 사건 타임라인, 근거 목록, 가능한 해석과 대안, 위험하거나 금지할 행동.
- REPORT: 인쇄/PDF(브라우저), 개인정보 필터/공유용 텍스트/QR, 사용자가 이전 검사 삭제 가능.
- RECOVER: 백업 완료 확인, 권한 요청, 명확한 승인. HTML 보고서 자체에서 고권한 명령 실행 불가.
- 디자인: 사용자가 승인한 다크 퍼플/민트 테크 포스터를 UI 디자인 시스템 기준으로 사용. **이미지의 92점 등 가상 수치와 .exe 목업을 실제 제품 성능으로 주장하지 않는다.**
- HTML/JS는 자급식 로컬 정적 파일, CDN 없음. file:// 환경의 별도 JSON fetch 제약을 피하고 PowerShell에서 HTML에 필요한 값만 안전하게 삽입, HTML 인코딩·JS 데이터 안전 직렬화 검증.

## 5. 데이터 계약·개인정보 보호

- versioned JSON schema: schemaVersion, productVersion, generatedAt, OS summary, permissions, collectionState, observations, incidents, evidence, assessment, limitations, recommendations.
- 수집 상태: collected / no-match / truncated / unavailable / denied / unsupported. 이벤트 조회 실패를 0건으로 표기 금지.
- 기본 동작 로컬 보고서만 생성. Windows 환경에서는 서버/계정/텔레메트리 없음. 보고서 저장 위치 사용자에게 표시. 개인정보 포함 가능 내용은 공유 전에 검토.
- 사용자가 검사 이력을 선택적으로 삭제, 결과 공유는 매번 명시적으로 선택.
- WinRE에서 BCD/BitLocker 상태 출력은 장치 식별 정보를 포함할 수 있으므로 QR/인쇄 기본 공유값과 분리.
- 다운로드 ZIP에 REPORTS, 백업 파일, 고객 원본 로그, 비밀키/환경 파일 절대 혼입하지 않음.

## 6. 최종 배포 구조(목표, 기존 파일과 다름)

START_PC_CARE.cmd (비관리자 홈) / RUN_HEALTH_CHECK.cmd (현재 존재) / RUN_SELF_TEST.cmd (현재 존재)
core/collector.ps1 / core/normalizer.ps1 / core/analyzer.ps1 / core/reporter.ps1
core/repair.ps1 (별도 승인형) / ui/ (자급식 CSS/JS/경량 QR)
recovery/WINRE_READ_ONLY.cmd (현재 존재) / recovery/START_RESCUE.cmd (Release B 예정)
REPORTS/ (실행 후 사용자 로컬 저장만, 배포 제외) / docs/ / MANIFEST-SHA256.txt

- 기존 프로젝트 구조/스크립트를 바로 이동하거나 깨지 말고 단계적으로 리팩터링, 과거 실행기의 호환 유지.
- Windows 사용자에게 Python/Node 설치 요구 없음. WinRE PowerShell·Robocopy 기본 존재를 무조건 가정하지 않으며 CMD에서 도구 지원 유무를 실제 확인.
- 최종 ZIP 목표 1~3MB(최적화 목표, 실측 전 확정 금지). 1MB 미만을 보장하지 않음.
- 정기 진단 소요 30~180초 목표(환경 의존, 실측 전). Rescue는 복사할 파일 용량에 따라 별도.
- USB 앱은 소형 매체에 보관 가능하나 **파일 Rescue는 별도 물리적 외장 저장장치에 충분한 용량이 필요**, 복구 USB 별도.
- Windows 10은 일반 지원 종료된 상태이므로 지속적인 호환성을 약속하지 않음.

## 7. 구현 순서와 공수 (기기/VM 준비 가정)

| 단계 | 구성 | 추정 |
|---|---|---|
| P0 | 현재 수집기 안정화·PowerShell 5.1·권한/로그 오류 회귀 | 7~11h |
| P1 | 배터리/업데이트/스토리지와 사고 시각 그룹화·증거 분석 | 12~20h |
| P2 | 고급 HTML UI·1페이지 프린트/PDF·개인정보 최소 QR | 12~20h |
| P3 | WinRE Rescue 안전 상태기계·파일 복사/검증 | 16~28h |
| P4 | 승인형 제한 복구·가이드·이력·ZIP/manifest | 8~14h |
| QA | Windows/USB/WinRE/BitLocker/VM 실패·부분 복사·보안 테스트 | 22~42h |
| 합계 | Release A+B 범위 | **77~135h** |

소스 작성과 실제 Windows 합격은 별개. RESCUE 자동 복사가 막히는 환경에서는 별도 테스트/설계가 필요하므로 더 길어질 수 있음.

## 8. 출시·QA 게이트

Release A: 기본 진단, 증거 분석, 한 장 요약·인쇄/PDF·로컬 QR, 수리 안내 및 **WinRE 읽기 전용 정보만**. 안전 테스트 후 무료 베타.
Release B: WinRE 선택 파일 복사 지원. A와 독립 승인/실증 게이트를 통과한 경우에만 포함·출시.

### 테스트 필수
1. Windows 11 x64 다른 기종/권한, USB FAT32/NTFS, 로컬 폴더, 경로 공백/한글, 읽기 전용 저장소·공간 부족.
2. 이벤트 41/6008 중복, 1001 지연 기록, 권한 거부/로그 없음/조회 절단, 인과 단정 오탐 테스트.
3. 디스크 건강 Unknown/Warning, Wear 미지원/단위 검증, 배터리 없음, Windows Update 정보 미지원.
4. Print CSS 1페이지 한글/긴 오류/폰트, PDF 저장, QR 스캔(텍스트/UTF-8/오프라인/개인정보), 내보내기 전 필터.
5. WinRE BitLocker 잠김, 공식 복구키 사용 안내, 다른 물리 디스크 증명 실패, 목적지 용량 부족, FAT32 큰 파일, OneDrive 링크, EFS, junction, 긴 경로, 다중 프로필, 원본 손상/USB 분리/전원 중단, 파일 수·크기·해시 검사.
6. Robocopy 종료 코드별 분기 및 부분 복사 시 성공 표시 금지. 사용자 원본 파일 수정/삭제 0건.
7. 백업 미확인·관리자 거부·디스크 상태 불명·수리 취소 시 DISM/SFC 실제 수리 호출 0회. VM 스냅샷 기반 위험 테스트.
8. 외부 자동 통신/원격 개인정보 전송 0. 고객 데이터가 패키지·GitHub에 혼입되지 않는지 확인.
9. 실제 ZIP SHA-256, 서명/SmartScreen·백신 오탐·PowerShell 정책, 사용성 테스트와 장애 시 수동 복구 안내.
10. 검증된 Git 커밋 SHA와 배포 ZIP/테스트 증거 1:1 연결, 기능별 실제 작동 여부 문서화.

### 금지 문구 및 기능
'SSD 수명 94% 남음' 임의 해석, '모든 고장 원인 정확히 진단', '부품 교체 불필요 보증', '수리비 사기 방지 인증', 'BitLocker 자동 해제', '원클릭 무조건 파일 복구', 'USB만 꽂으면 부팅', '윈도우 100% 복구', 'WinRE에서 PowerShell은 반드시 실행됨' 등.
파티션 포맷/청소, BCD 부트로더 자동 변경, 강제 재부팅, CHKDSK /f /r 무조건 호출, DDU 자동 실행, Windows 무인 초기화는 v1 제외.

## 9. 두 Gemini 제안에 대한 결정표

- 수리점 제출용 1페이지 인쇄/PDF: **최우선 채택**. 공식 인증서·사기 판정은 제외.
- 오프라인 QR 오류 요약: **채택**, 개인정보 최소·명시적 생성·실제 QR 스캔 검증.
- WinRE USB 비상 백업: **조건부 채택**, 안전 상태기계·2중 승인·백업 검증 실패시 미지원.
- BitLocker 자동 키 입력/잠금해제: **제외**.
- Windows 11 QMR/PITR 상태: **보수적 공식 안내**, 신뢰 가능한 판별 불가시 활성화 단정 금지.
- 안전모드/DDU 자동화: **출시 제외**. 별도 수동 가이드만 검토.
- Anti-Scam Report: **수리 상담용 객관 증거/질문**으로 표현을 변경하여 채택.
- 최초 실행 관리자 자동승격, 임의 92점, 클라우드 종속, 일괄 클리너: **제외**.

## 10. 현재 구현과 미구현

현재 GitHub에 코드 존재: CMD Windows 읽기 전용 시작, PowerShell OS/디스크/이벤트/Defender 진단, 저장장치 상태·BugCheck HTML/JSON, DISM/SFC 백업+명시 승인형 코드, WinRE CMD 읽기 전용 보조, Windows 스모크 테스트 진입점, Python 내부 ZIP·SHA 검증.
**Windows 10/11 실기기, WinRE, 실제 복구와 결함 재현 아직 미검증**.

미구현: 정식 홈 UI, 고급 이벤트 상관관계/오탐 테스트, 업데이트·배터리 수집·상태 비교, 엔지니어 1페이지 출력, 오프라인 QR, WinRE 파일 복사/완료 검증, QMR/PITR 지원여부 판별, 사용자 완성 ZIP/코드 서명. 이번 문서는 **설계 기록일 뿐 코드 구현이나 제품 출시가 아님**.

## 11. 공식 기술 참고문서

Windows RE: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-recovery-environment--windows-re--technical-reference
BitLocker Recovery: https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/bitlocker-recovery-guide-plan
Robocopy options/errors: https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy
QMR: https://learn.microsoft.com/en-us/windows/configuration/quick-machine-recovery/
PITR: https://learn.microsoft.com/en-us/windows/configuration/quick-machine-recovery/point-in-time-restore
PowerCFG: https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options

## 12. 최종 서명
**기획 방향:** 건강검진에서 끝나지 않고, 고장 원인 근거 해설 + 수리점 상담자료 + 안전한 사고 수습을 제공한다.
**출시 안전성:** Release A/B 분리. 비상 파일 복사는 강한 조건을 만족해야만 허용.
**성공 지표:** 테스트된 설명의 정확성, 오류·미확인 표시, 사용자 원본 보존, 한 페이지 전달성, 제한 없는 오프라인 실행, 안전한 중단/실패 처리.
