> **[OWNER-FINAL-BLUEPRINT-100 | 2026-11-13 KST | 사용자 확정]** 공식 최종완성률은 **사용자 최종설계도 전체 = 100%** 기준으로만 산정. 작업자·총괄이 임의 설계 범위·가중치·수용조건 축소/수정 금지. 해커톤 MVP, 합성/CI, P85/P95 같은 기술 마일스톤을 공식 최종완성률로 부르면 안 된다. 최종설계 요구 ID→소스→정확 SHA 검증·미검증→승인 가중치 100점 추적표와 대조. 근거가 없으면 공식 `UNASSESSED(재산정 대기)`; 과거 수치는 내부 역사 지표로 보존. 해총 `kmong-productization` 최종완성률 원장에 결과 동기화. 기존 [작업중]/등록이력·RELEASE HOLD 변경 금지. [공통 정본](https://github.com/hibi89/hackathon-command-center-2026/blob/kmong-productization/docs/strategy/FINAL_BLUEPRINT_COMPLETION_STANDARD_20261113.md). 정책 커밋은 기능 완료나 점수 확정이 아니다.

> **[KMONG_WORK_TARGET_GATE_20261112 | 사용자 최신 확정 | 필수 작업 규칙]** 이 저장소에서 크몽 상품·육성 후보를 작업하는 모든 AI 담당자는 새 채팅·`ㄱ` 시작 시 이 문구를 읽고 적용한다.
> - 실제 개발/수정/테스트 착수 즉시 [해총 크몽 최종완성률·후보 상태표](https://github.com/hibi89/hackathon-command-center-2026/blob/kmong-productization/docs/audits/KMONG_16_CURRENT_20261111.md)의 **해당 상품명 옆에 `**[작업중]**`을 표시하고 GitHub 커밋**한다. 확정 단계 목표(예: 95%)와 검증 기준을 제품 STATUS/HANDOFF에 남긴다.
> - **목표 완성률 달성 전에는 [작업중]을 삭제하지 않는다.** 일시중단·종료·보류·다른 제품 전환·담당 채팅 변경도 삭제 사유가 아니다. 예전 '전환·중단 시 삭제' 지시는 폐기한다.
> - **검증된 목표치에 도달한 뒤에만** 기능 SHA·PASS/FAIL/SKIP·미검증을 기록하고 자기 표시를 제거·커밋한다. 목표 하향/변경으로 표식 제거 시 사용자 명시 승인 필요. 다른 담당자 표시·기존 수치·RELEASE HOLD 보존.
> - 표식은 목표 미달 상태를 의미하며 **실시간 실행 증명은 아니다**. 허브 최신 HEAD 확인 후 안전하게 반영, 실패 시 `KMONG_HUB_SYNC_PENDING` 기록. 자동 동기화 없음. 크몽 외 작업에는 표시 불필요.

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
