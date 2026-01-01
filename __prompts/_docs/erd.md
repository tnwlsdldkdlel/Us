# 모바일 앱 "Us" 데이터베이스 ERD(개체-관계 다이어그램) 설계

PRD(제품 요구사항 명세서)에 정의된 기능들을 기반으로 "Us" 앱의 데이터베이스 구조를 설계했습니다.

## 1. 설계 원칙: 논리적 외래키 사용

본 ERD는 확장성과 성능을 고려하여 물리적 외래키(Foreign Key Constraint)를 사용하지 않고, 애플리케이션 레벨에서 데이터의 관계를 관리하는 **논리적 외래키** 방식을 채택합니다.

- **물리적 외래키**: 데이터베이스가 직접 테이블 간의 관계 무결성을 강제하는 방식입니다.
- **논리적 외래키**: `user_id`, `appointment_id` 와 같이 관계를 나타내는 필드는 유지하되, 데이터베이스에 제약조건을 설정하지 않습니다. 데이터의 정합성은 애플리케이션 코드(ORM 등)를 통해 보장합니다. 이 방식은 데이터베이스의 부하를 줄이고, 분산 환경 및 마이크로서비스 아키텍처에서 더 유연하게 대처할 수 있는 장점이 있습니다.

## 2. 핵심 개체(Entities) 및 속성(Attributes)

### 2.1. Users (회원)

사용자 정보를 저장하는 테이블입니다.

- **user_id (PK)**: 사용자 고유 식별자 (기본 키)
- **email**: 이메일 주소 (로그인 및 친구 추가 시 사용)
- **nickname**: 앱 내에서 사용할 별명
- **profile_image_url**: 프로필 사진 이미지 주소
- **social_provider**: 소셜 로그인 제공자 (예: 'GOOGLE', 'APPLE')
- **created_at**: 가입 일시
- **updated_at**: 마지막 정보 수정 일시

### 2.2. Friendships (친구 관계)

두 사용자 간의 친구 관계 및 상태를 저장하는 테이블입니다.

- **friendship_id (PK)**: 친구 관계 고유 식별자 (기본 키)
- **requester_id**: 친구 요청을 보낸 사용자 ID (Users.user_id를 논리적으로 참조)
- **addressee_id**: 친구 요청을 받은 사용자 ID (Users.user_id를 논리적으로 참조)
- **status**: 친구 관계 상태 ('REQUESTED', 'ACCEPTED', 'REJECTED')
- **created_at**: 관계 생성 일시
- **updated_at**: 관계 상태 변경 일시
- 상태 전환 규칙: `REQUESTED` → `ACCEPTED`(수락) 또는 `REQUESTED` → `REJECTED`(거절)로만 이동합니다.
- `REJECTED` 상태 레코드는 이력 보존을 위해 유지하되, 친구/보낸·받은 요청 목록에는 노출하지 않습니다.
- 거절된 뒤 동일 사용자가 다시 요청하면 기존 레코드를 재사용해 `status` 를 `REQUESTED` 로 되돌리고, `requester_id`/`updated_at` 를 최신 정보로 갱신합니다.
- 가입자가 아닌 이메일 대상자는 별도 행을 생성하지 않으며 Supabase Functions를 통해 초대 메일만 발송합니다.

### 2.3. FriendInvites (친구 초대)

가입하지 않은 친구에게 전송한 초대 정보를 저장하는 테이블입니다.

- **invite_id (PK)**: 초대 고유 식별자 (기본 키)
- **inviter_id**: 초대를 보낸 사용자 ID (Users.user_id를 논리적으로 참조)
- **invitee_email**: 초대를 받은 이메일 주소
- **status**: 초대 상태 ('INVITED', 'COMPLETED', 'CANCELLED', 'EXPIRED', 'FAILED')
- **created_at**: 초대 생성 일시
- **updated_at**: 상태 변경 일시
- **expires_at**: 초대 만료 일시 (기본 14일 후)
- **completed_at**: 초대가 친구 요청으로 전환된 일시 (선택적)

초대는 14일이 경과하면 `EXPIRED` 로 갱신하며, 수신자가 가입하면 자동으로 `friendships` 의 `REQUESTED` 상태로 전환하고 초대 레코드는 `COMPLETED` 로 업데이트합니다. 초대 메일 전송과 레코드 생성은 동일 트랜잭션으로 처리하며, 하루에 동일 사용자가 보낼 수 있는 초대는 20건으로 제한합니다.

### 2.4. Appointments (약속)

생성된 약속의 상세 정보를 저장하는 테이블입니다.

- **appointment_id (PK)**: 약속 고유 식별자 (기본 키)
- **creator_id**: 약속을 생성한 사용자 ID (Users.user_id를 논리적으로 참조)
- **title**: 약속 이름
- **appointment_time**: 약속 시간
- **location_name**: 장소 이름 (예: "카카오프렌즈 강남플래그십")
- **address**: 전체 주소
- **latitude**: 위도
- **longitude**: 경도
- **created_at**: 약속 생성 일시
- **updated_at**: 약속 수정 일시

### 2.5. Appointment_Participants (약속 참여자)

어떤 사용자가 어떤 약속에 참여하는지를 연결하는 매핑 테이블입니다.

- **participant_id (PK)**: 참여 정보 고유 식별자 (기본 키)
- **appointment_id**: 참여할 약속 ID (Appointments.appointment_id를 논리적으로 참조)
- **user_id**: 참여하는 사용자 ID (Users.user_id를 논리적으로 참조)
- **rsvp_status**: 참석 여부 ('ATTENDING', 'DECLINED', 'PENDING')
- **created_at**: 참여 정보 생성 일시
- **updated_at**: 참석 여부 변경 일시

### 2.6. Comments (댓글)

약속 상세 화면의 게시판 댓글 정보를 저장하는 테이블입니다.

- **comment_id (PK)**: 댓글 고유 식별자 (기본 키)
- **appointment_id**: 댓글이 달린 약속 ID (Appointments.appointment_id를 논리적으로 참조)
- **user_id**: 댓글을 작성한 사용자 ID (Users.user_id를 논리적으로 참조)
- **content**: 댓글 내용
- **created_at**: 댓글 작성 일시
- **updated_at**: 댓글 수정 일시

## 3. 개체 관계 다이어그램 (ERD)

```
erDiagram
erDiagram
    Users ||--o{ Friendships : "requests"
    Users ||--o{ Friendships : "receives"
    Users ||--o{ FriendInvites : "sends"
    Users ||--o{ Appointments : "creates"
    Users ||--o{ Appointment_Participants : "participates in"
    Users ||--o{ Comments : "writes"

    FriendInvites }o--|| Users : "inviter"
    FriendInvites }o--|| Users : "invitee (email)"
    FriendInvites ||--o{ Friendships : "converts to"
    Appointments ||--|{ Appointment_Participants : "has"
    Appointments ||--|{ Comments : "has"

    Users {
        string user_id PK
        string email
        string nickname
        string profile_image_url
        string social_provider
        datetime created_at
        datetime updated_at
    }

    Friendships {
        string friendship_id PK
        string requester_id
        string addressee_id
        string status
        datetime created_at
        datetime updated_at
    }

    FriendInvites {
        string invite_id PK
        string inviter_id
        string invitee_email
        string status
        datetime created_at
        datetime updated_at
        datetime expires_at
        datetime completed_at
    }

    Appointments {
        string appointment_id PK
        string creator_id
        string title
        datetime appointment_time
        string location_name
        string address
        float latitude
        float longitude
        datetime created_at
        datetime updated_at
    }

    Appointment_Participants {
        string participant_id PK
        string appointment_id
        string user_id
        string rsvp_status
        datetime created_at
        datetime updated_at
    }

    Comments {
        string comment_id PK
        string appointment_id
        string user_id
        string content
        datetime created_at
        datetime updated_at
    }
```

- `PK`: Primary Key (기본 키)
- `||--o{`: 1:N 관계 (한 명의 유저는 여러 친구 요청을 보내거나 받을 수 있음)
- `||--|{`: 1:N 관계 (하나의 약속은 여러 참여자와 댓글을 가질 수 있음)

- `FriendInvites` 레코드는 초대한 사용자가 `Users` 를 통해 가입하면 자동으로 `Friendships` 의 `REQUESTED` 상태로 전환됩니다.
