import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { SMTPClient } from "https://deno.land/x/denomailer@1.6.0/mod.ts";

// SMTP 설정 환경 변수
const SMTP_HOSTNAME = Deno.env.get("SMTP_HOSTNAME") || "smtp.gmail.com";
const SMTP_PORT = parseInt(Deno.env.get("SMTP_PORT") || "587");
const SMTP_USERNAME = Deno.env.get("SMTP_USERNAME");
const SMTP_PASSWORD = Deno.env.get("SMTP_PASSWORD");
const FROM_EMAIL = Deno.env.get("FROM_EMAIL") || SMTP_USERNAME;
const FROM_NAME = Deno.env.get("FROM_NAME") || "Us App";

// CORS 헤더 상수
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Content-Type": "application/json",
};

interface InviteRequest {
  email: string;
  inviterName: string;
}

Deno.serve(async (req) => {
  // CORS preflight 처리
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Authorization 헤더 검증
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "인증이 필요합니다." }),
        {
          status: 401,
          headers: corsHeaders,
        },
      );
    }

    // SMTP 설정 확인
    if (!SMTP_USERNAME || !SMTP_PASSWORD) {
      console.error("SMTP 설정이 누락되었습니다.");
      return new Response(
        JSON.stringify({ error: "서버 설정 오류입니다." }),
        {
          status: 500,
          headers: corsHeaders,
        },
      );
    }

    // 모든 헤더 수집
    const headers: Record<string, string> = {};
    req.headers.forEach((value, key) => {
      headers[key] = value;
    });

    console.log("Request headers:", JSON.stringify(headers, null, 2));

    // arrayBuffer를 사용하여 body 읽기 시도
    let bodyText: string;
    try {
      const buffer = await req.arrayBuffer();
      const decoder = new TextDecoder();
      bodyText = decoder.decode(buffer);
      console.log("Body length:", bodyText.length);
      console.log("Body content:", bodyText);
    } catch (readError) {
      console.error("Body 읽기 실패:", readError);
      return new Response(
        JSON.stringify({
          error: "요청 본문을 읽을 수 없습니다.",
          details: readError instanceof Error ? readError.message : String(readError),
          headers: headers,
        }),
        {
          status: 400,
          headers: corsHeaders,
        },
      );
    }

    // JSON 파싱
    let body: InviteRequest;
    try {
      body = JSON.parse(bodyText) as InviteRequest;
    } catch (parseError) {
      console.error("JSON 파싱 실패:", parseError);
      return new Response(
        JSON.stringify({
          error: "잘못된 요청 형식입니다.",
          details: parseError instanceof Error ? parseError.message : String(parseError),
          bodyText: bodyText,
          headers: headers,
        }),
        {
          status: 400,
          headers: corsHeaders,
        },
      );
    }

    const { email, inviterName } = body;

    if (!email || !inviterName) {
      return new Response(
        JSON.stringify({
          error: "이메일과 초대자 이름이 필요합니다.",
          received: { email, inviterName }
        }),
        {
          status: 400,
          headers: corsHeaders,
        },
      );
    }

    console.log(`친구 초대 이메일 발송 시작: ${email} (초대자: ${inviterName})`);

    // SMTP 클라이언트 생성
    let client;
    try {
      console.log("SMTP 클라이언트 생성 중...");
      client = new SMTPClient({
        connection: {
          hostname: SMTP_HOSTNAME,
          port: SMTP_PORT,
          tls: true,
          auth: {
            username: SMTP_USERNAME,
            password: SMTP_PASSWORD,
          },
        },
      });
      console.log("SMTP 클라이언트 생성 완료");
    } catch (smtpClientError) {
      console.error("SMTP 클라이언트 생성 실패:", smtpClientError);
      throw new Error(`SMTP 클라이언트 생성 실패: ${smtpClientError instanceof Error ? smtpClientError.message : String(smtpClientError)}`);
    }

    // 이메일 발송
    try {
      console.log("이메일 발송 중...");
      await client.send({
        from: `${FROM_NAME} <${FROM_EMAIL}>`,
        to: email,
        subject: `${inviterName}님이 Us 앱에 초대했습니다!`,
        content: `안녕하세요!\n\n${inviterName}님이 Us 앱에서 친구 요청을 보냈습니다.\nUs는 친구들과의 약속을 쉽게 만들고 관리할 수 있는 소셜 캘린더 앱입니다.\n\n앱을 다운로드하고 가입하시면 ${inviterName}님의 친구 요청을 확인하실 수 있습니다.\n\n감사합니다.`,
      });
      console.log("이메일 발송 완료");
    } catch (sendError) {
      console.error("이메일 발송 실패:", sendError);
      throw new Error(`이메일 발송 실패: ${sendError instanceof Error ? sendError.message : String(sendError)}`);
    }

    try {
      await client.close();
      console.log("SMTP 연결 종료");
    } catch (closeError) {
      console.error("SMTP 연결 종료 실패:", closeError);
      // 연결 종료 실패는 무시
    }

    console.log(`친구 초대 이메일 발송 성공: ${email}`);

    return new Response(
      JSON.stringify({
        message: "초대 이메일이 성공적으로 발송되었습니다.",
      }),
      {
        status: 200,
        headers: corsHeaders,
      },
    );
  } catch (error) {
    console.error("친구 초대 처리 중 오류:", error);
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "알 수 없는 오류가 발생했습니다.",
        stack: error instanceof Error ? error.stack : undefined,
      }),
      {
        status: 500,
        headers: corsHeaders,
      },
    );
  }
});

function generateEmailTemplate(inviterName: string): string {
  return `
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Us 앱 초대</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f5f5f5;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f5f5f5; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 600px; background-color: #ffffff; border-radius: 12px; box-shadow: 0 2px 8px rgba(0,0,0,0.1);">
          <!-- 헤더 -->
          <tr>
            <td style="padding: 40px 40px 20px; text-align: center;">
              <h1 style="margin: 0; font-size: 28px; font-weight: 700; color: #1a1a1a;">
                Us
              </h1>
              <p style="margin: 8px 0 0; font-size: 14px; color: #666;">
                친구들과 함께하는 약속 관리 앱
              </p>
            </td>
          </tr>

          <!-- 본문 -->
          <tr>
            <td style="padding: 20px 40px;">
              <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 8px; text-align: center;">
                <p style="margin: 0; font-size: 18px; font-weight: 600; color: #ffffff;">
                  🎉
                </p>
                <h2 style="margin: 12px 0 0; font-size: 22px; font-weight: 600; color: #ffffff;">
                  ${inviterName}님이<br/>Us 앱에 초대했습니다!
                </h2>
              </div>

              <div style="padding: 30px 0;">
                <p style="margin: 0 0 16px; font-size: 16px; line-height: 1.6; color: #333;">
                  안녕하세요!
                </p>
                <p style="margin: 0 0 16px; font-size: 16px; line-height: 1.6; color: #333;">
                  <strong>${inviterName}</strong>님이 Us 앱에서 친구 요청을 보냈습니다.
                  Us는 친구들과의 약속을 쉽게 만들고 관리할 수 있는 소셜 캘린더 앱입니다.
                </p>

                <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 24px 0;">
                  <h3 style="margin: 0 0 12px; font-size: 16px; font-weight: 600; color: #1a1a1a;">
                    Us 앱으로 할 수 있는 일
                  </h3>
                  <ul style="margin: 0; padding-left: 20px; color: #555;">
                    <li style="margin: 8px 0; line-height: 1.5;">친구들과 약속을 쉽게 생성하고 공유</li>
                    <li style="margin: 8px 0; line-height: 1.5;">캘린더에서 모든 약속을 한눈에 확인</li>
                    <li style="margin: 8px 0; line-height: 1.5;">참석 여부를 실시간으로 확인</li>
                    <li style="margin: 8px 0; line-height: 1.5;">약속 장소를 지도에서 바로 확인</li>
                  </ul>
                </div>

                <!-- CTA 버튼 (나중에 딥링크 추가 가능) -->
                <table width="100%" cellpadding="0" cellspacing="0" style="margin: 30px 0;">
                  <tr>
                    <td align="center">
                      <div style="display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 16px 40px; border-radius: 8px; text-decoration: none;">
                        <span style="color: #ffffff; font-size: 16px; font-weight: 600; text-decoration: none;">
                          앱 다운로드하기
                        </span>
                      </div>
                      <p style="margin: 12px 0 0; font-size: 13px; color: #999;">
                        (iOS App Store / Google Play에서 "Us" 검색)
                      </p>
                    </td>
                  </tr>
                </table>

                <p style="margin: 24px 0 0; font-size: 14px; line-height: 1.6; color: #666;">
                  앱을 다운로드하고 가입하시면 ${inviterName}님의 친구 요청을 확인하실 수 있습니다.
                </p>
              </div>
            </td>
          </tr>

          <!-- 푸터 -->
          <tr>
            <td style="padding: 20px 40px 40px; text-align: center; border-top: 1px solid #e5e5e5;">
              <p style="margin: 0; font-size: 13px; color: #999;">
                이 이메일은 ${inviterName}님의 요청으로 발송되었습니다.
              </p>
              <p style="margin: 8px 0 0; font-size: 12px; color: #999;">
                © 2025 Us App. All rights reserved.
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
  `.trim();
}
