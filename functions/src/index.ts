// functions/src/index.ts

import * as functions from "firebase-functions";
import { GoogleGenerativeAI } from "@google/generative-ai";

// Lấy API Key từ biến môi trường (an toàn)
// Chúng ta sẽ set biến này ở Bước 4
const API_KEY = functions.config().gemini.key;

// Khởi tạo model Gemini
const genAI = new GoogleGenerativeAI(API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-pro" });

// Tạo một "Callable Function"
export const askGemini = functions.https.onCall(async (data, context) => {
  // 1. Kiểm tra xem người dùng đã đăng nhập chưa
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Bạn phải đăng nhập để sử dụng tính năng này."
    );
  }

  // 2. Lấy câu hỏi từ app Flutter
  const userPrompt = data.prompt;
  const contextData = data.contextData; // Dữ liệu ngữ cảnh

  if (!userPrompt) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Không có nội dung câu hỏi."
    );
  }

  try {
    // 3. Xây dựng Prompt hoàn chỉnh
    const fullPrompt = `
      CHỈ THỊ HỆ THỐNG: 
      Bạn là một chuyên gia tư vấn tài chính cá nhân tên là FinBot. 
      Bạn thân thiện, thông minh và đưa ra lời khuyên dựa trên dữ liệu. 
      Hãy trả lời ngắn gọn, tập trung vào việc giúp người dùng tiết kiệm tiền.

      DỮ LIỆU NGỮ CẢNH: 
      ${contextData || "Không có dữ liệu ngữ cảnh."}

      CÂU HỎI CỦA NGƯỜI DÙNG: 
      ${userPrompt}
    `;

    // 4. Gọi Gemini API
    const result = await model.generateContent(fullPrompt);
    const response = await result.response;
    const text = response.text();

    // 5. Trả kết quả về cho app Flutter
    return { answer: text };

  } catch (error) {
    console.error("Lỗi khi gọi Gemini API:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Không thể xử lý yêu cầu, vui lòng thử lại."
    );
  }
});