const { onRequest } = require("firebase-functions/v2/https");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { getAuth } = require("firebase-admin/auth");

var serviceAccount = require("./account.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = getAuth();

// 글로벌 옵션 설정
setGlobalOptions({
  timeoutSeconds: 10,
  memory: "256MiB",
  region: "asia-northeast3", // 서울 리전 (선택사항)
});

exports.createCustomToken = onRequest(async (request, response) => {
  // CORS 설정 (필요한 경우)
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Methods", "POST");
  response.set("Access-Control-Allow-Headers", "Content-Type");

  if (request.method === "OPTIONS") {
    response.status(204).send("");
    return;
  }

  const user = request.body;
  let uid = `kakao:::${user.userId}`;

  try {
    await auth.updateUser(uid, user);
  } catch (error) {
    user["uid"] = uid;
    await auth.createUser(user);
  }

  try {
    const token = await auth.createCustomToken(uid);

    const result = {
      status: "SUCCESS",
      code: "0000",
      message: "성공",
      data: token,
    };
    response.send(result);
  } catch (error) {
    console.log("Error creating custom token:", error);
    response.sendStatus(400);
  }
});
