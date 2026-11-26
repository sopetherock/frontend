// 백엔드 주소 단일 관리.
// 빌드/실행 시: --dart-define=BACKEND_URL=https://xxxx.lambda-url.ap-northeast-2.on.aws  (끝에 슬래시 없이)
// 지정하지 않으면 아래 기본값(로컬 개발용)을 사용.
const String kBackendUrl = String.fromEnvironment(
  'BACKEND_URL',
  defaultValue: 'http://172.21.21.229:3000',
);
const String kApiBase = '$kBackendUrl/api';
