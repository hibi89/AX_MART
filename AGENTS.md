> **[KMONG_WORK_IN_PROGRESS_20261112 — 크몽 필수 지침 / 소유자 승인]** 이 저장소에서 크몽 상품 또는 육성 후보 작업을 담당하면 새 채팅·`ㄱ` 재개 시 이 `AGENTS.md`를 반드시 읽는다.
> - **실제 상품 개발·수정·테스트/검증 착수 시 즉시:** 중앙 `hibi89/hackathon-command-center-2026`의 `kmong-productization` 브랜치 [최종완성률 및 작업 현황 표](https://github.com/hibi89/hackathon-command-center-2026/blob/kmong-productization/docs/audits/KMONG_16_CURRENT_20261111.md)에서 **담당 제품명 바로 옆에 `**[작업중]**`**을 작성하고 실제 GitHub 커밋을 확인한다. 같은 저장소에 상품이 여럿이면 현재 담당 상품만 표시. 활성 16종 외 PREP·FFAX·Factory AX 등의 후보는 같은 문서의 별도 후보 작업 상태 표에서 표시한다.
> - **검증된 목표 완성률 달성 / 종료 / 중단 / 보류 / 다른 상품으로 작업 전환 시 즉시:** 자신의 `[작업중]`만 제거해 GitHub 커밋을 확인한다. 다른 채팅이 작업 중인 표식은 임의 변경하지 않는다. 중앙 최신 HEAD를 먼저 읽고 동시 갱신을 보존한다.
> - 중앙 기록 쓰기 실패 시 제품 `STATUS.md`·`HANDOFF.md`와 답변에 **`KMONG_HUB_SYNC_PENDING`**을 기록한다. 자동 실시간 동기화가 없고, 표식은 완성률 상향·판매/배포 승인이나 작업 자동 실행을 의미하지 않는다. 실제 검증 근거 없이는 숫자를 변경하지 않는다.

# AXMART³ (AXMART CUBE) 작업 원칙

- 기존 시안과 정상 데이터를 보호하며 UI 변경은 사용자가 승인한 범위에서 수행.
- 백엔드 미구현 상태를 실제 거래 가능하다고 표시하지 않는다.
- 실제 작성된 코드가 있는 제품만 표시하며 미검증 제품에 허위 가격·다운로드·후기·판매량·고객사 로고를 표시하지 않는다.
- 작업 전 main HEAD, Cloudflare Pages 연결·권한, 보안과 비용 확인.
- 배포 Ready와 운영 정상은 구분, Production SHA와 실제 렌더링을 검증.
- 중요한 작업 후 STATUS.md, HANDOFF.md 최신화.

- 추가 확정: 가상 상품·가격·후기·등록 수치·샘플 장바구니를 공개하지 않는다. 제품은 실제 코드 검증 자료가 있는 경우만 표기하고 개발 중은 판매·다운로드 금지.
- 제품 상태(실제 사용 검증/미검증)를 화면에 명시한다. Cloudflare 배포 성공과 실서비스 정상 검증을 별도 판정한다.

- 공식 플랫폼명은 AXMART³(AXMART CUBE), 첫 제품명은 AXMART PC CARE. 기술 저장소/배포 프로젝트명은 이전 식별자 그대로 유지.
- 사용자 승인 다크 퍼플·민트 UI 포스터는 디자인 지침이며 실측 점수/완성 UI가 아니다.

## Kmong final-product completion sync (2026-11-11)
After actual code/test work, reconcile exact SHA, tests and provisional final-product percentage in AX_MART STATUS/HANDOFF and hibi89/hackathon-command-center-2026 kmong-productization (current 16 list, KMONG_PRODUCTIZATION, STATUS, HANDOFF). No automatic cross-chat sync. On failure record KMONG_HUB_SYNC_PENDING; no false success. Real payment, customer data, rights, production remain approval-gated.
